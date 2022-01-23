# -*- coding: utf-8 -*-
from distutils.command.config import config
import os, configparser
import psycopg2
from qgis.core import *
from qgis.gui import QgsLayerTreeView
from qgis.PyQt.QtWidgets import QMessageBox,QCheckBox,QHBoxLayout
from .connection import *
from .installation import plugin_view_syntax,feature_subclasses
from collections import OrderedDict
from .constants import *
import itertools
from collections import Counter



def is_connected(dbLoader):
    database = dbLoader.dlg.cbxConnToExist.currentData()
    conn = None
    try:
        dbLoader.conn = connect(database) #Open the connection
        cur = dbLoader.conn.cursor()
        cur.execute("SHOW server_version;")
        version = cur.fetchone()
        database.s_version= version[0]

    except (Exception, psycopg2.DatabaseError) as error:
        print(error)
    finally:
        if dbLoader.conn is not None:
            cur.close()

    return 1

def is_3dcitydb(dbLoader):
    """ Checks if current database has specific 3DCityDB requirements.\n
    Requiremnt list:
        > Extentions: postgis, uuid-ossp, postgis_sfcgal
        > Schemas: citydb_pkg
        > Tables: cityobject, building, surface_geometry
        

    """ 
    #Check conditions for a valid the 3DCityDB structure. 
    # ALL MUST BE TRUE
    # NOTE: this is an oversimplified test! there are countless conditions where the requirements are met but the structure is broken.
    conditions_met = {  'postgis':False, 'postgis_sfcgal':False, 'uuid-ossp':False,             #Extentions
                        'citydb_pkg':False,                                                     #Schemas
                        'cityobject':False,'building':False,'surface_geometry':False}           #Tables

                        

    database = dbLoader.dlg.cbxConnToExist.currentData()
		

    cur = dbLoader.conn.cursor() 
    # get all tables with theirs schemas    
    cur.execute("""SELECT table_name
                    FROM information_schema.tables
                    WHERE table_schema != 'pg_catalog'
                    AND table_schema != 'information_schema'
                    AND table_type='BASE TABLE'
                """)
    tables = cur.fetchall()
    cur.close()

    cur = dbLoader.conn.cursor()
    #Get all schemas
    cur.execute("SELECT schema_name FROM information_schema.schemata")
    schemas = cur.fetchall()
    cur.close()

    cur = dbLoader.conn.cursor() 
    #Get all extentions
    cur.execute("SELECT extname FROM pg_extension")
    extentions = cur.fetchall()
    cur.close()
    
    #extention check
    for pair in extentions:
        if 'postgis' in pair: conditions_met['postgis']=True
        elif 'postgis_sfcgal' in pair: conditions_met['postgis_sfcgal']=True
        elif 'uuid-ossp' in pair: conditions_met['uuid-ossp']=True
        

    #schema check
    for pair in schemas:
        if 'citydb_pkg' in pair:
            conditions_met['citydb_pkg']=True

    #table check
    for pair in tables:
        if 'cityobject' in pair: conditions_met['cityobject']=True
        elif 'building' in pair: conditions_met['building']=True
        elif 'citydb_pkg' in pair: conditions_met['citydb_pkg']=True
        elif 'surface_geometry' in pair: conditions_met['surface_geometry']=True


    for condition in conditions_met:
        if not conditions_met[condition]:
            return condition
        
    cur = dbLoader.conn.cursor()  
    cur.execute("SELECT version FROM citydb_pkg.citydb_version();")
    version= cur.fetchall()
    cur.close()
    database.c_version= version[0][0]

    return 1

def get_schemas(dbLoader):
    database = dbLoader.dlg.cbxConnToExist.currentData()
    conn = None
    try:

        # create a cursor
        cur = dbLoader.conn.cursor()

        #Get all schemas
        cur.execute("SELECT schema_name,'' FROM information_schema.schemata WHERE schema_name != 'information_schema' AND NOT schema_name LIKE '%pg%' ORDER BY schema_name ASC")
        schemas = cur.fetchall()

        schemas,empty=zip(*schemas)
        dbLoader.schemas = schemas

    except (Exception, psycopg2.DatabaseError) as error:
        print(error)
    finally:
        if dbLoader.conn is not None:
            # close the communication with the PostgreSQL
            cur.close()

def fill_schema_box(dbLoader):
    dbLoader.dlg.cbxScema.clear()
    dbLoader.dlg.cbxScema.addItems(sorted(dbLoader.schemas)) 

def instantiate_objects(dbLoader,features):

    
    for feature, schema in features:

        if feature == building_table:
            feature_obj = Building()
            for sub in feature_obj.subFeatures_table_name:
                if sub == buildingOuterInstallation_table:
                    subfeature_obj = BuildingInstallation()
                elif sub == buildingPart_table:
                    subfeature_obj = BuildingPart()
                elif sub == thematicSurfaces_table:
                    subfeature_obj = BuildingThematic()
                else: continue
                feature_obj.subFeatures_objects.append(subfeature_obj) 
        elif feature == dtm_table:
            feature_obj = Relief()
            for sub in feature_obj.subFeatures_table_name:
                if sub == reliefTIN_table:
                    subfeature_obj = TINRelief()
                feature_obj.subFeatures_objects.append(subfeature_obj) 
        elif feature == vegetation_table:
            feature_obj = Vegetation()
        else: continue
        dbLoader.container_obj.append(feature_obj)

def check_schema(dbLoader):
    database = dbLoader.dlg.cbxConnToExist.currentData()


    #NOTE: the above list is currently (19/01/22) limited to what makes sense for now. Check citygml docs to see the complete list
 
    conn = None
    try:

        #Get schema stored in 'schema combobox'
        schema=dbLoader.dlg.cbxScema.currentText()
    
        cur=dbLoader.conn.cursor()

        #Check if current schema has cityobject, building features.
        cur.execute(f"""SELECT table_name, table_schema FROM information_schema.tables 
                        WHERE table_schema = '{schema}' 
                        AND table_name SIMILAR TO '%{get_postgres_array(feature_tables)}%'
                        ORDER BY table_name ASC""")
        feature_response= cur.fetchall() #All tables relevant to the thematic surfaces
        cur.close()

        instantiate_objects(dbLoader,feature_response)


        for feature in dbLoader.container_obj:
            dbLoader.dlg.qcbxFeature.addItem(feature.alias,feature)  

    except (Exception, psycopg2.DatabaseError) as error:
        print(error)
    finally:
        if dbLoader.conn is not None:
            # close the communication with the PostgreSQL
            #cur.close()
            pass
    

    return 1

def create_subfeatures_widgets(dbLoader):
    feature = dbLoader.dlg.qcbxFeature.currentData()

    row=-1
    col=0
    try:
        for c,subfeature in enumerate(feature.subFeatures_objects):
            assert feature.subFeatures_objects #NOTE:22-01-2022 I want to catch features that don't have subfeatures and notify the user. BUT i don't think it works as intended
            check_box= QCheckBox(subfeature.alias)
            check_box.stateChanged.connect(dbLoader.evt_checkBox_stateChanged)
            if c%3==0:
                row+=1
                col=0
            dbLoader.dlg.gridLayout_2.addWidget(check_box,row,col)
            if c==0:dbLoader.dlg.gbxSubFeatures.setDisabled(False)
            col+=1
    except AssertionError as msg:
        dbLoader.show_Qmsg(f'<b>{msg}</b> doesn\'t have any sub-features',msg_type=Qgis.Info)
        return 0

    

def delete_all_sufeatures_widgets(dbLoader):
    for w in reversed(range(dbLoader.dlg.gridLayout_2.count())):
        dbLoader.dlg.gridLayout_2.itemAt(w).widget().setParent(None)


def get_checked_subfeatures(dbLoader):
    selected_feature = dbLoader.dlg.qcbxFeature.currentData()
    subfeatures = [dbLoader.dlg.gridLayout_2.itemAt(w).widget() for w in reversed(range(dbLoader.dlg.gridLayout_2.count()))]
    checked_subfeatures=[]
    for sub in subfeatures: 
        if sub.isChecked():

            obj_inx=[subfeat.alias for subfeat in selected_feature.subFeatures_objects].index(sub.text())
            checked_subfeatures.append(selected_feature.subFeatures_objects[obj_inx])
    return checked_subfeatures


def check_geometry(dbLoader):
    conn = None
    database = dbLoader.dlg.cbxConnToExist.currentData()
    schema = dbLoader.dlg.cbxScema.currentText()
    feature = dbLoader.dlg.qcbxFeature.currentData()
    extents=dbLoader.dlg.qgrbExtent.outputExtent().asWktPolygon() 

    checked_subfeature_tables = get_checked_subfeatures(dbLoader)
    feature_all_lvls = [feature]+checked_subfeature_tables


    try:

        total_count=0
        
        msg=''
        for element in feature_all_lvls:
            cur=dbLoader.conn.cursor()
            #Get amount of thematic features and subfeatures inside the extents 
            if element.view_name == 'part':
                            cur.execute(f"""SELECT count(*),'' 
                            FROM {schema}.cityobject co
                            JOIN {schema}.{element.table_name} bg 
                            ON co.id = bg.id
                            WHERE ST_Contains(ST_GeomFromText('{extents}',28992),envelope)
                            AND bg.objectclass_id = {element.class_id}""")
            else:
                cur.execute(f"""SELECT count(*),'' 
                            FROM {schema}.cityobject co
                            JOIN {schema}.{element.table_name} bg 
                            ON co.id = bg.id
                            WHERE ST_Contains(ST_GeomFromText('{extents}',28992),envelope)""")
            count=cur.fetchone()
            cur.close()
            count,empty=count
            element.count=count
            total_count+=count

            if element.is_feature: 
                msg+=f"\u2116 of '{element.alias}' objects: {element.count}\n"
            else: 
                msg+=f"   \u2116 of '{element.alias}' objects: {element.count}\n"


            current_lod= None
            add_lod=None
            add_types=[]
            add_geometries={}
            for view in element.views:
                
                cur=dbLoader.conn.cursor()
                #Get geometry columns
                cur.execute(f"""SELECT count(*),'' FROM qgis_pkg.{view.name}
                                WHERE ST_Contains(ST_GeomFromText('{extents}',28992),ST_Force2D(geom))""") #TODO: DONT HARDCODE SRID
                count=cur.fetchone()
                cur.close()
 
                if count[0]: #NOT 0
                    if  current_lod != view.lod:
                        if current_lod and add_types: #check if they are NOT empty
                            add_types=[]

                        current_lod= view.lod
                        add_types.append(view.type)
                        add_geometries[current_lod]=add_types

                    else:
                        add_types.append(view.type)
                        add_geometries[current_lod]=add_types

            element.lods=add_geometries
            
            
        
        lod_intersection=[]
        for element in feature_all_lvls:
            lod_intersection.append(set(element.lods.keys()))
        res=sorted(set.intersection(*lod_intersection))



        types=[]
        for element in feature_all_lvls:
            for lod in res:
                if type(element.lods[lod])==type([]):
                    for i in element.lods[lod]:
                        types.append(i)
                else:
                    types.append(element.lods[lod])
        

        counter=Counter(types)

        types=[]
        for key in counter.keys():
            if counter[key] >= len(feature_all_lvls): #NOTE: this >= seems suspicius
                types.append(key)

        for key,values in geometry_rep.items():
            if key in res:
                add_types=[]
                for v in values:
                    if v in types:
                        add_types.append(table_to_alias(v,'type'))
                dbLoader.dlg.cbxGeometryLvl.addItem(table_to_alias(key,'lod'),add_types)       
                    

        #Guard against importing many feutures
        if total_count>20000:
            QMessageBox.warning(dbLoader.dlg,"Warning", f"Too many features set to be imported ({total_count})!\n"
                                                        f"This could hinder perfomance and even cause frequent crashes.\n{msg}") #TODO: justify it better with storage size to 
        else:
            QMessageBox.information(dbLoader.dlg,"Info", msg)
            if count == 0:
                cur.close()
                return 2

    except (Exception, psycopg2.DatabaseError) as error:
        print(error)
    finally:
        if dbLoader.conn is not None:
            # close the communication with the PostgreSQL
            #cur.close()
            pass
    

    return 3


def fieldVisibility (layer,fname):
    setup = QgsEditorWidgetSetup('Hidden', {})
    for i, column in enumerate(layer.fields()):
        if column.name()==fname:
            layer.setEditorWidgetSetup(i, setup)
            break
        else:
            continue

def value_rel_widget(AllowMulti= False, AllowNull= True, FilterExpression='',
                    Layer= '', Key= '', Value= '',
                    NofColumns= 1, OrderByValue= False, UseCompleter= False):

    config =   {'AllowMulti': AllowMulti,
                'AllowNull': AllowNull,
                'FilterExpression':FilterExpression,
                'Layer': Layer,
                'Key': Key,
                'Value': Value,
                'NofColumns': NofColumns,
                'OrderByValue': OrderByValue,
                'UseCompleter': UseCompleter}
    return QgsEditorWidgetSetup(type= 'ValueRelation',config= config)

    
def create_lookup_relations(layer):
    for field in layer.fields():
        field_name = field.name()
        field_idx = layer.fields().indexOf(field_name)

        assertion_msg="ValueRelation Error: layer '{}' doesn\'t exist in project. This layers is also being imported with every layer import (if it doesn\'t already exist)."
        if field_name == 'relative_to_water':
            target_layer = QgsProject.instance().mapLayersByName('lu_relative_to_water')
            assert target_layer, assertion_msg.format('lu_relative_to_water')
            layer.setEditorWidgetSetup(field_idx,value_rel_widget(Layer= target_layer[0].id(), Key= 'code_value', Value= 'code_name'))  
        elif field_name == 'relative_to_terrain':
            target_layer = QgsProject.instance().mapLayersByName('lu_relative_to_terrain')
            assert target_layer, assertion_msg.format('lu_relative_to_terrain')
            layer.setEditorWidgetSetup(field_idx,value_rel_widget(Layer= target_layer[0].id(), Key= 'code_value', Value= 'code_name'))   
        elif field_name == 'class':
            target_layer = QgsProject.instance().mapLayersByName('lu_building_class')
            assert target_layer, assertion_msg.format('lu_building_class')
            layer.setEditorWidgetSetup(field_idx,value_rel_widget(Layer= target_layer[0].id(), Key= 'code_value', Value= 'code_name'))
        elif field_name == 'function':
            target_layer = QgsProject.instance().mapLayersByName('lu_building_function_usage')
            assert target_layer, assertion_msg.format('lu_building_function_usage')
            layer.setEditorWidgetSetup(field_idx,value_rel_widget(Layer= target_layer[0].id(), Key= 'code_value', Value= 'code_name', OrderByValue=True, AllowMulti=True, NofColumns=4, FilterExpression="codelist_name  =  'NL BAG Gebruiksdoel'"))
        
        elif field_name == 'usage':
            target_layer = QgsProject.instance().mapLayersByName('lu_building_function_usage')
            assert target_layer, assertion_msg.format('lu_building_function_usage')
            layer.setEditorWidgetSetup(field_idx,value_rel_widget(Layer= target_layer[0].id(), Key= 'code_value', Value= 'code_name', OrderByValue=True, AllowMulti=True, NofColumns=4, FilterExpression="codelist_name  =  'NL BAG Gebruiksdoel'"))
            
  

def create_relations(layer):
    project = QgsProject.instance()
    layer_configuration = layer.editFormConfig()
    layer_root_container = layer_configuration.invisibleRootContainer()
    
    curr_layer = project.mapLayersByName(layer.name())[0]
    genericAtt_layer = project.mapLayersByName("cityobject_genericattrib")
    assert genericAtt_layer, f"Layer: '{'cityobject_genericattrib'}' doesn\'t exist in project. This layers should also being imported with every layer import (if it doesn't already exist). 17-01-2021 It is not imported automatically yet, so DONT DELETE THE LAYER."


    rel = QgsRelation()
    rel.setReferencedLayer(curr_layer.id())
    rel.setReferencingLayer(genericAtt_layer[0].id())
    rel.addFieldPair('cityobject_id','id')
    rel.generateId()
    rel.setName('re_'+layer.name())
    rel.setStrength(0)
    assert rel.isValid(), "RelationError: Relation is NOT valid, Check ids and field names"
    QgsProject.instance().relationManager().addRelation(rel)

    relation_field = QgsAttributeEditorRelation(rel, layer_root_container)
    relation_field.setLabel("Generic Attributes")
    relation_field.setShowLabel(True)
    layer_root_container.addChildElement(relation_field)

    layer.setEditFormConfig(layer_configuration)
    create_lookup_relations(layer)

def group_has_layer(group,layer_name):
    if layer_name in [child.name() for child in group.children()] : return True
    return False


def import_lookups(dbLoader): #NOTE: make lookups as a CLASS ???? hmm
    lookup_group_name = "Look-up tables"
    

    selected_db=dbLoader.dlg.cbxConnToExist.currentData()
    selected_feature=dbLoader.dlg.qcbxFeature.currentText()
    cur=dbLoader.conn.cursor()

    root= QgsProject.instance().layerTreeRoot()
    if not root.findGroup(lookup_group_name): node_lookups = root.addGroup(lookup_group_name)
    else: node_lookups= root.findGroup(lookup_group_name)

    #Get all existing look-up tables from database
    cur.execute(f"""SELECT table_name,'' FROM information_schema.tables 
                    WHERE table_schema = 'qgis_pkg' AND table_name LIKE 'lu_%';
                    """)
    lookups=cur.fetchall()
    cur.close()
    lookups,empty=zip(*lookups)
    
    for table in lookups:
        if not group_has_layer(node_lookups,table):
            uri = QgsDataSourceUri()
            uri.setConnection(selected_db.host,selected_db.port,selected_db.database_name,selected_db.username,selected_db.password)
            uri.setDataSource(aSchema= 'qgis_pkg',aTable= f'{table}',aGeometryColumn= None,aKeyColumn= '')
            layer = QgsVectorLayer(uri.uri(False), f"{table}", "postgres")
            node_lookups.addLayer(layer)
            QgsProject.instance().addMapLayer(layer,False)

    order_ToC(node_lookups)

def import_generics(dbLoader):

    selected_db=dbLoader.dlg.cbxConnToExist.currentData()
    selected_schema=dbLoader.dlg.cbxScema.currentText()
    selected_feature=dbLoader.dlg.qcbxFeature.currentText()
    extents=dbLoader.dlg.qgrbExtent.outputExtent().asWktPolygon() #Readable for debugging

    root= QgsProject.instance().layerTreeRoot()
    group_to_assign = root.findGroup(selected_db.database_name)


    generics_layer_name = "cityobject_genericattrib"

    if not group_has_layer(group_to_assign,generics_layer_name):
        uri = QgsDataSourceUri()
        uri.setConnection(selected_db.host,selected_db.port,selected_db.database_name,selected_db.username,selected_db.password)
        uri.setDataSource(aSchema= f'{selected_schema}',aTable= f'{generics_layer_name}',aGeometryColumn= None,aKeyColumn= '')
        layer = QgsVectorLayer(uri.uri(False), f"{generics_layer_name}", "postgres")
        group_to_assign.addLayer(layer)
        QgsProject.instance().addMapLayer(layer,False)


def create_layers(dbLoader,view):
    selected_db=dbLoader.dlg.cbxConnToExist.currentData()
    selected_schema=dbLoader.dlg.cbxScema.currentText()
    selected_feature=dbLoader.dlg.qcbxFeature.currentText()
    selected_geometryLvl=dbLoader.dlg.cbxGeometryLvl.currentText()
    selected_geometryType=dbLoader.dlg.cbxGeomteryType.currentText()
    extents=dbLoader.dlg.qgrbExtent.outputExtent().asWktPolygon() #Readable for debugging

    #SELECT UpdateGeometrySRID('roads','geom',4326);
    uri = QgsDataSourceUri()
    uri.setConnection(selected_db.host,selected_db.port,selected_db.database_name,selected_db.username,selected_db.password)
    uri.setDataSource(aSchema= 'qgis_pkg',aTable= f'{view}',aGeometryColumn= 'geom',aSql=f"ST_Contains(ST_GeomFromText('{extents}',28992),ST_Force2D(geom))",aKeyColumn= 'id')
    vlayer = QgsVectorLayer(uri.uri(False), f"{view}", "postgres")

    vlayer.setCrs(QgsCoordinateReferenceSystem('EPSG:28992'))#TODO: Dont hardcode it
    #fieldVisibility(vlayer,'geom') 

    return vlayer

def send_to_top_ToC(root,group):
    move_group =  group.clone()
    root.insertChildNode(0, move_group)
    root.removeChildNode(group)


def order_ToC(group):

    #### Germán Carrillo: https://gis.stackexchange.com/questions/397789/sorting-layers-by-name-in-one-specific-group-of-qgis-layer-tree ########
    LayerNamesEnumDict=lambda listCh:{listCh[q[0]].name()+str(q[0]):q[1] for q in enumerate(listCh)}
        
    # group instead of root
    mLNED = LayerNamesEnumDict(group.children())
    mLNEDkeys = OrderedDict(sorted(LayerNamesEnumDict(group.children()).items(), reverse=False)).keys()

    mLNEDsorted = [mLNED[k].clone() for k in mLNEDkeys]
    group.insertChildNodes(0,mLNEDsorted)  # group instead of root
    for n in mLNED.values():
        group.removeChildNode(n)  # group instead of root
    #############################################################################################################################
    group.setExpanded(True)
    for child in group.children():
        if isinstance(child, QgsLayerTreeGroup):
            order_ToC(child)
        else: return None


def import_layer(dbLoader): #NOTE: ONLY BUILDINGS

    selected_db=dbLoader.dlg.cbxConnToExist.currentData()
    selected_schema=dbLoader.dlg.cbxScema.currentText() 
    selected_feature = dbLoader.dlg.qcbxFeature.currentData() #3dcitydb table name
    print("Feature:",selected_feature)

    selected_subFeatures= get_checked_subfeatures(dbLoader)
    print("Subfeature:",selected_subFeatures)
    
    selected_geometryLvl=dbLoader.dlg.cbxGeometryLvl.currentText()
    selected_geometryType=dbLoader.dlg.cbxGeomteryType.currentText()
    extents=dbLoader.dlg.qgrbExtent.outputExtent().asWktPolygon() #Readable for debugging
    print("LOD:",selected_geometryLvl)
    print("Type:",selected_geometryType)

    cons=Constants()
    views_tree= cons.views_features_subFeatures


    conn = None

    try:

        root = QgsProject.instance().layerTreeRoot()
        if not root.findGroup(selected_db.database_name): node_database = root.addGroup(selected_db.database_name)
        else: node_database = root.findGroup(selected_db.database_name)

        if not node_database.findGroup(selected_schema): node_schema = node_database.addGroup(selected_schema)
        else: node_schema = node_database.findGroup(selected_schema)

        if not node_schema.findGroup(selected_feature.alias): node_feature = node_schema.addGroup(selected_feature.alias)
        else: node_feature = node_schema.findGroup(selected_feature.alias)

        if not node_feature.findGroup(selected_geometryLvl): node_flod = node_feature.addGroup(selected_geometryLvl)
        else: node_flod = node_feature.findGroup(selected_geometryLvl)

        for subFeatures in selected_subFeatures:
            if not node_feature.findGroup(subFeatures.alias): node_subFeature = node_feature.addGroup(subFeatures.alias)
            else: node_subFeature = node_feature.findGroup(subFeatures.alias)

            if not node_subFeature.findGroup(selected_geometryLvl): node_slod = node_subFeature.addGroup(selected_geometryLvl)
            else: node_slod = node_subFeature.findGroup(selected_geometryLvl)

        feature_views={selected_feature: selected_feature.get_view(  schema=selected_schema,
                                                    feature=selected_feature.view_name,
                                                    subfeature=None,
                                                    lod=alias_to_viewSyntax(selected_geometryLvl,'lod'),
                                                    g_type=alias_to_viewSyntax(selected_geometryType,'type'))
                        }
        subfeature_views={subFeature:   subFeature.get_view( schema=selected_schema,
                                                feature=selected_feature.view_name,
                                                subfeature=subFeature.view_name,
                                                lod=alias_to_viewSyntax(selected_geometryLvl,'lod'),
                                                g_type=alias_to_viewSyntax(selected_geometryType,'type')) for subFeature in selected_subFeatures
                            }

 
        feature_views.update(subfeature_views)


        for element,views in feature_views.items():
            for view in views:
                import_lookups(dbLoader)
                vlayer = create_layers(dbLoader,view.name)
                import_generics(dbLoader)

                if not vlayer or not vlayer.isValid():
                    dbLoader.show_Qmsg('Layer failed to load properly',msg_type=Qgis.Critical)
                else:
                    # if vlayer.featureCount()==0:
                    #     continue
                    #dbLoader.iface.mainWindow().blockSignals(True)
                    QgsProject.instance().addMapLayer(vlayer,False)
                    
                    if element.is_feature: node_flod.addLayer(vlayer)
                    else: 
                        #if thematicSurfaces_in_view in view.subfeature:

                       
                        node_subFeature= node_feature.findGroup(element.alias)
                        node_lod = node_subFeature.findGroup(table_to_alias(view.lod,'lod'))
                        node_lod.addLayer(vlayer)

                    dbLoader.iface.mainWindow().blockSignals(False) #NOTE: Temp solution to avoid undefined CRS pop up. IT IS DEFINED
                    dbLoader.show_Qmsg('Success!!')

                    vlayer.loadNamedStyle('/home/konstantinos/.local/share/QGIS/QGIS3/profiles/default/python/plugins/citydb_loader/forms_style.qml')
                    create_relations(vlayer)
        #Its important to first order the ToC and then send it to the top. 
        order_ToC(node_database)     
        send_to_top_ToC(root,node_database)

    except (Exception, psycopg2.DatabaseError) as error:
        print(error)
        dbLoader.show_Qmsg('Import failed! Check Log Messages',msg_type=Qgis.Critical)
    finally:
        if dbLoader.conn is not None:
            # close the communication with the PostgreSQL
            #cur.close()
            pass
            
    

#TODO: Check if Commit is needed after every query execution https://www.psycopg.org/docs/faq.html

#TODO: drop view when layer is removed from project
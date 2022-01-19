# -*- coding: utf-8 -*-
from distutils.command.config import config
import os, configparser
import psycopg2
from qgis.core import *
from qgis.gui import QgsLayerTreeView
from qgis.PyQt.QtWidgets import QMessageBox
from .connection import *
from .installation import plugin_view_syntax,feature_subclasses
from collections import OrderedDict




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


def check_schema(dbLoader):
    database = dbLoader.dlg.cbxConnToExist.currentData()

    features_names=["City Object","Building","DTM","Tunnel","Bridge","Water Bodies","Vegetation Objects", "City Furniture", "Land Use"] #Named after their main corresponding table name from the 3DCityDB.
    features_tables=["cityobject","building","relief_feature","tunnel","bridge","waterbody","solitary_vegetat_object", "city_furniture", "land_use"]  #Named after their main corresponding table name from the 3DCityDB.
    features_array='{"cityobject","building","relief_feature","tunnel","bridge","waterbody","solitary_vegetat_object", "city_furniture", "land_use"}' #TODO:19/01/2022 FIND A BETTER WAY TO GET THIS. I WANT TO USE IT AS AN ARRAY

    #NOTE: the above list is currently (19/01/22) limited to what makes sense for now. Check citygml docs to see the complete list
 
    conn = None
    try:

        #Get schema stored in 'schema combobox'
        schema=dbLoader.dlg.cbxScema.currentText()
    
        cur=dbLoader.conn.cursor()

        #Check if current schema has cityobject, building features.
        cur.execute(f"""SELECT table_name, table_schema FROM information_schema.tables 
                        WHERE table_schema = '{schema}' 
                        AND table_name = ANY('{features_array}')
                        ORDER BY table_name ASC""")
        feature_response= cur.fetchall()
        cur.close()
        features_names_status = list(map(list, zip(features_names,[False]*len(features_tables))))
        features_dict = dict(zip(features_tables,features_names_status))
        for t, s in feature_response:
            if t in features_tables:
                features_dict[t][1]=True
        
        
        features_to_display=[]
        #NOTE:TODO: This for loop below seems redundunt check if its easier to just append the list to the above for loop
        for f_table in features_dict:
            print(f_table,features_dict[f_table])
            if not features_dict[f_table][1]:
                cur.close()
                return 0
            else:
                features_to_display.append(features_dict[f_table][0])
        
        dbLoader.dlg.qcbxFeature.clear()
        dbLoader.dlg.qcbxFeature.addItems(features_to_display)

    except (Exception, psycopg2.DatabaseError) as error:
        print(error)
    finally:
        if dbLoader.conn is not None:
            # close the communication with the PostgreSQL
            #cur.close()
            pass
    

    return 1

def check_geometry(dbLoader):
    conn = None
    database = dbLoader.dlg.cbxConnToExist.currentData()
    schema = dbLoader.dlg.cbxScema.currentText()
    feature = dbLoader.dlg.qcbxFeature.currentText()
    extents=dbLoader.dlg.qgrbExtent.outputExtent().asWktPolygon() 

    try:


        cur=dbLoader.conn.cursor()

        #Get amount of features inside the extents 
        cur.execute(f"""SELECT count(*),'' 
                        FROM {schema}.cityobject co
                        JOIN {schema}.{feature} bg 
                        ON co.id = bg.id
                        WHERE ST_Contains(ST_GeomFromText('{extents}',28992),envelope)""")
        count=cur.fetchone()
        cur.close()
        count,empty=count

        #Guard against importing many feutures
        if count>3000:
            QMessageBox.warning(dbLoader.dlg,"Warning", f"Too many features set to be imported ({count})!\n"
                                                    "This could hinder perfomance and even cause frequent crashes.") #TODO: justify it better with storage size to 
        else:
            QMessageBox.information(dbLoader.dlg,"Info", f"{count} '{feature}' features contained in current extent.")
            if count == 0:
                cur.close()
                return 2
        cur=dbLoader.conn.cursor()
        #Get geometry columns
        cur.execute(f"""SELECT column_name,'' 
                        FROM information_schema.columns 
                        WHERE table_name = '{feature}' 
                        AND table_schema = '{schema}' 
                        AND column_name 
                        LIKE 'lod%%id'""")

        columns=cur.fetchall()
        cur.close()
        columns,empty=zip(*columns)
        
        cur=dbLoader.conn.cursor()
        cur.execute(f"SELECT * FROM {schema}.thematic_surface;")
        hasThematic = cur.fetchone()
        if hasThematic:

            #Get amount of features inside the extents #TODO: select from a list of columns
            cur.execute(f"""SELECT  bg.lod0_footprint_id, bg.lod0_roofprint_id, bg.lod1_multi_surface_id,bg.lod1_solid_id, bg.lod2_multi_surface_id,
                                    bg.lod2_solid_id,th.lod2_multi_surface_id
                            FROM {schema}.cityobject co
                            JOIN {schema}.{feature} bg ON co.id = bg.id
                            JOIN {schema}.thematic_surface th ON th.building_id = bg.id;
                        """)
            
        else:
            cur.execute(f"""SELECT  bg.lod0_footprint_id, bg.lod0_roofprint_id, bg.lod1_multi_surface_id,bg.lod1_solid_id, bg.lod2_multi_surface_id,
                                    bg.lod2_solid_id,NULL
                            FROM {schema}.cityobject co
                            JOIN {schema}.{feature} bg ON co.id = bg.id;""")
        attributes=cur.fetchall()
        cur.close()


        geometry_lvls={ 'LOD0':{'Footprint':False, 'Roofprint':False},
                        'LOD1':{'Multi-surface':False,"Solid":False},
                        'LOD2':{'Multi-surface':False,"Solid":False,"Thematic surface":False}
                    }

        dbLoader.dlg.cbxGeometryLvl.clear()
        dbLoader.dlg.cbxGeomteryType.clear()
        
        lod0=[]
        lod1=[]
        lod2=[]

        for feature in attributes:
            
            if feature[0] is not None:
                if not geometry_lvls['LOD0']['Footprint']:
                    lod0.append('Footprint')
                    geometry_lvls['LOD0']['Footprint']=True
                else: continue

            if feature[1] is not None:  
                if not geometry_lvls['LOD0']['Roofprint']:
                    lod0.append('Roofprint')
                    geometry_lvls['LOD0']['Roofprint']=True
                else: continue

            if feature[2] is not None:
                if not geometry_lvls['LOD1']['Multi-surface']:
                    lod1.append('Multi-surface')
                    geometry_lvls['LOD1']['Multi-surface']=True
                else: continue

            if feature[3] is not None:
                if not geometry_lvls['LOD1']['Solid']:
                    lod1.append('Solid')
                    geometry_lvls['LOD1']['Solid']=True
                else: continue

            if feature[4] is not None:
                if not geometry_lvls['LOD2']['Multi-surface']:
                    lod2.append('Multi-surface')
                    geometry_lvls['LOD2']['Multi-surface']=True
                else: continue

            if feature[5] is not None:
                if not geometry_lvls['LOD2']['Solid']:
                    lod2.append('Solid')
                    geometry_lvls['LOD2']['Solid']=True
                else: continue
            
            if feature[6] is not None:
                if not geometry_lvls['LOD2']['Thematic surface']:
                    lod2.append('Thematic surface')
                    geometry_lvls['LOD2']['Thematic surface']=True
                else: continue


        lvls = {'LoD0':lod0,'LoD1':lod1,'LoD2':lod2}
        for lvl,types in lvls.items():
            if lvl:
                dbLoader.dlg.cbxGeometryLvl.addItem(lvl,types) #TODO: Dont like this harcoding


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
    selected_feature = dbLoader.dlg.qcbxFeature.currentText()
    selected_geometryLvl=dbLoader.dlg.cbxGeometryLvl.currentText()
    selected_geometryType=dbLoader.dlg.cbxGeomteryType.currentText()
    extents=dbLoader.dlg.qgrbExtent.outputExtent().asWktPolygon() #Readable for debugging

    conn = None

    try:

        

        if selected_geometryType == "Thematic surface":
            query_view=[f'{selected_schema}_bdg_closuresurface_lod2_multisurf',
                        f'{selected_schema}_bdg_groundsurface_lod2_multisurf',
                        f'{selected_schema}_bdg_outerceilingsurface_lod2_multisurf',
                        f'{selected_schema}_bdg_outerfloorsurface_lod2_multisurf',
                        f'{selected_schema}_bdg_outerinstallation_lod2_multisurf',
                        f'{selected_schema}_bdg_roofsurface_lod2_multisurf',
                        f'{selected_schema}_bdg_wallsurface_lod2_multisurf']
        else:
            building_view=f'{selected_schema}_{plugin_view_syntax[selected_feature]}_{plugin_view_syntax[selected_geometryLvl]}_{plugin_view_syntax[selected_geometryType]}'
            building_parts_view=f'{selected_schema}_{plugin_view_syntax[selected_feature]}_part_{plugin_view_syntax[selected_geometryLvl]}_{plugin_view_syntax[selected_geometryType]}'
            query_view=[building_view,building_parts_view]

        layer_name= f'{selected_schema}_{selected_feature}_{selected_geometryLvl}_{selected_geometryType}'
        
        root = QgsProject.instance().layerTreeRoot()
        if not root.findGroup(selected_db.database_name): node_database = root.addGroup(selected_db.database_name)
        else: node_database = root.findGroup(selected_db.database_name)

        if not node_database.findGroup(selected_schema): node_schema = node_database.addGroup(selected_schema)
        else: node_schema = node_database.findGroup(selected_schema)

        if not node_schema.findGroup(selected_feature): node_feature = node_schema.addGroup(selected_feature)
        else: node_feature = node_schema.findGroup(selected_feature)

        if not node_feature.findGroup(selected_geometryLvl): node_lod = node_feature.addGroup(selected_geometryLvl)
        else: node_lod = node_feature.findGroup(selected_geometryLvl)


                

        
        #if not node_feature.findGroup(selected_geometryLvl): node_lod = node_feature.addGroup(selected_geometryLvl)

            
        for view in query_view:
            import_lookups(dbLoader)
            vlayer = create_layers(dbLoader,view)

            if not vlayer or not vlayer.isValid():
                dbLoader.show_Qmsg('Layer failed to load properly',msg_type=Qgis.Critical)
            else:
                if vlayer.featureCount()==0:
                    continue
                dbLoader.iface.mainWindow().blockSignals(True)
                QgsProject.instance().addMapLayer(vlayer,False)

                if selected_geometryType == 'Thematic surface':
                    if not node_feature.findGroup("ThematicSurfaces"): node_them = node_lod.addGroup("ThematicSurfaces")
                    else: node_them = root.findGroup("ThematicSurfaces")
                    node_them.addLayer(vlayer)
                else: node_lod.addLayer(vlayer)
                

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
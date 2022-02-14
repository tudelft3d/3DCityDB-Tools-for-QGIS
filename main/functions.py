# -*- coding: utf-8 -*-
from distutils.command.config import config
import os, configparser
from gpg import Data
import psycopg2
from pyrsistent import b
from qgis.core import *
from qgis.gui import QgsLayerTreeView
from qgis.PyQt.QtWidgets import QMessageBox,QCheckBox,QHBoxLayout
from qgis.PyQt.QtGui import QStandardItemModel
from .connection import *
from qgis.PyQt.QtCore import *
from collections import OrderedDict
from .constants import *
import itertools
from collections import Counter









def create_features_checkboxes(dbLoader):
    module = dbLoader.dlg.cbxModule.currentData()

    row=-1
    col=0
    try:
        for c,feature in enumerate(module.features):
            #assert feature.subFeatures_objects #NOTE:22-01-2022 I want to catch features that don't have subfeatures and notify the user. BUT i don't think it works as intended
            check_box= QCheckBox(feature.alias)
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

    

def delete_all_features_widgets(dbLoader,layout):
    for w in reversed(range(layout.count())):
        layout.itemAt(w).widget().setParent(None)


def get_checked_features(dbLoader,layout):
    selected_module = dbLoader.dlg.cbxModule.currentData()
    check_boxes = [layout.itemAt(w).widget() for w in reversed(range(layout.count()))]
    checked_features=[]
    for feature in check_boxes: 
        if feature.isChecked():
            obj_inx=[feat.alias for feat in selected_module.features].index(feature.text())
            checked_features.append(selected_module.features[obj_inx])
    return checked_features

def get_checked_types(dbLoader,layout):
    check_boxes = [layout.itemAt(w).widget() for w in reversed(range(layout.count()))]
    checked_types=[]
    for representation in check_boxes: 
        if representation.isChecked():
            checked_types.append(representation)
    return checked_types






def check_geometry(dbLoader):
    conn = None
    database = dbLoader.dlg.cbxExistingConnection.currentData()
    schema = dbLoader.dlg.cbxScema.currentText()
    feature = dbLoader.dlg.cbxModule.currentData()
    extents=dbLoader.dlg.qgbxExtent.outputExtent().asWktPolygon() 

    checked_subfeature_tables = get_checked_features(dbLoader)
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
                            WHERE ST_Intersects(ST_GeomFromText('{extents}',28992),envelope)
                            AND bg.objectclass_id = {element.class_id}""")
            else:
                cur.execute(f"""SELECT count(*),'' 
                            FROM {schema}.cityobject co
                            JOIN {schema}.{element.table_name} bg 
                            ON co.id = bg.id
                            WHERE ST_Intersects(ST_GeomFromText('{extents}',28992),envelope)""")
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
                                WHERE ST_Intersects(ST_GeomFromText('{extents}',28992),ST_Force2D(geom))""") #TODO: DONT HARDCODE SRID
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
                dbLoader.dlg.cbxLod.addItem(table_to_alias(key,'lod'),add_types)       
                    

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
    

    selected_db=dbLoader.dlg.cbxExistingConnection.currentData()
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

    selected_db=dbLoader.dlg.cbxExistingConnection.currentData()
    selected_schema=dbLoader.dlg.cbxSchema.currentText()

    extents=dbLoader.dlg.qgbxExtent.outputExtent().asWktPolygon() #Readable for debugging

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
    selected_db=dbLoader.dlg.cbxExistingConnection.currentData()
    extents=dbLoader.dlg.qgbxExtent.outputExtent().asWktPolygon() #Readable for debugging

    #SELECT UpdateGeometrySRID('roads','geom',4326);
    uri = QgsDataSourceUri()
    uri.setConnection(selected_db.host,selected_db.port,selected_db.database_name,selected_db.username,selected_db.password)
    uri.setDataSource(aSchema= 'qgis_pkg',aTable= f'{view}',aGeometryColumn= 'geom',aSql=f"ST_Intersects(ST_GeomFromText('{extents}',28992),ST_Force2D(geom))",aKeyColumn= 'id')
    vlayer = QgsVectorLayer(uri.uri(False), f"{view}", "postgres")

    vlayer.setCrs(QgsCoordinateReferenceSystem('EPSG:28992'))#TODO: Dont hardcode it
    #fieldVisibility(vlayer,'geom') 

    return vlayer

def send_to_top_ToC(group):
    root = QgsProject.instance().layerTreeRoot()
    move_group =  group.clone()
    root.insertChildNode(0, move_group)
    root.removeChildNode(group)

def get_node_database(dbLoader):
    selected_db = dbLoader.dlg.cbxExistingConnection.currentData()
    root = QgsProject.instance().layerTreeRoot()
    return root.findGroup(selected_db.database_name)

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

def build_ToC(dbLoader,view):
    selected_db = dbLoader.dlg.cbxExistingConnection.currentData()

    root = QgsProject.instance().layerTreeRoot()
    if not root.findGroup(selected_db.database_name): node_database = root.addGroup(selected_db.database_name)
    else: node_database = root.findGroup(selected_db.database_name)

    if not node_database.findGroup(view.schema): node_schema = node_database.addGroup(view.schema)
    else: node_schema = node_database.findGroup(view.schema)

    if not node_schema.findGroup(view.module): node_module = node_schema.addGroup(view.module)
    else: node_module = node_schema.findGroup(view.module)

    if not node_module.findGroup(view.root_feature): node_feature = node_module.addGroup(view.root_feature)
    else: node_feature = node_module.findGroup(view.root_feature)

    if not node_feature.findGroup(view.lod): node_lod = node_feature.addGroup(view.lod)
    else: node_lod = node_feature.findGroup(view.lod)

    return node_lod


def get_checkedItemsData(ccbx):
    checked_items = []
    for idx in range(ccbx.count()):
        if ccbx.itemCheckState(idx) == 2: #is Checked
            checked_items.append(ccbx.itemData(idx))
    return checked_items

def import_layer(dbLoader): #NOTE: ONLY BUILDINGS
    checked_views = get_checkedItemsData(dbLoader.dlg.ccbxFeatures)
    #checked_views = dbLoader.dlg.ccbxFeatures.checkedItemsData() NOTE: this builtin method works only for string types. Check https://qgis.org/api/qgscheckablecombobox_8cpp_source.html line 173
    print(checked_views)

    counter= 0
    layers_to_import=[]
    for view in checked_views:
        node= build_ToC(dbLoader,view)
        vlayer = create_layers(dbLoader,view.view_name)
        counter+=vlayer.featureCount()
        if not vlayer or not vlayer.isValid():
            dbLoader.show_Qmsg('Layer failed to load properly',msg_type=Qgis.Critical)
            return None
        layers_to_import.append(vlayer)
        node.addLayer(vlayer)


    if counter>100:
        res= QMessageBox.question(dbLoader.dlg,"Warning", f"Too many features set to be imported ({counter})!\n"
                                                    f"This could hinder perfomance and even cause frequent crashes.\nDo you want to continue?") 
        if res == 16384:                                           
            for layer in layers_to_import:
                QgsProject.instance().addMapLayer(layer,False)
                dbLoader.show_Qmsg('Success!!')
        else: return None
    else: 
        for layer in layers_to_import:
            QgsProject.instance().addMapLayer(layer,False)
            dbLoader.show_Qmsg('Success!!')

    group_node= get_node_database(dbLoader)        
    order_ToC(group_node)     
    send_to_top_ToC(group_node)        
        #vlayer.loadNamedStyle('/home/konstantinos/.local/share/QGIS/QGIS3/profiles/default/python/plugins/citydb_loader/forms/forms_style.qml') #TODO: this needs to be platform independent

    # conn = None

    # try:

    #     root = QgsProject.instance().layerTreeRoot()
    #     if not root.findGroup(selected_db.database_name): node_database = root.addGroup(selected_db.database_name)
    #     else: node_database = root.findGroup(selected_db.database_name)

    #     if not node_database.findGroup(selected_schema): node_schema = node_database.addGroup(selected_schema)
    #     else: node_schema = node_database.findGroup(selected_schema)

    #     if not node_schema.findGroup(selected_feature.alias): node_feature = node_schema.addGroup(selected_feature.alias)
    #     else: node_feature = node_schema.findGroup(selected_feature.alias)

    #     if not node_feature.findGroup(selected_geometryLvl): node_flod = node_feature.addGroup(selected_geometryLvl)
    #     else: node_flod = node_feature.findGroup(selected_geometryLvl)

    #     for subFeatures in selected_subFeatures:
    #         if not node_feature.findGroup(subFeatures.alias): node_subFeature = node_feature.addGroup(subFeatures.alias)
    #         else: node_subFeature = node_feature.findGroup(subFeatures.alias)

    #         if not node_subFeature.findGroup(selected_geometryLvl): node_slod = node_subFeature.addGroup(selected_geometryLvl)
    #         else: node_slod = node_subFeature.findGroup(selected_geometryLvl)

    #     feature_views={selected_feature: selected_feature.get_view(  schema=selected_schema,
    #                                                 feature=selected_feature.view_name,
    #                                                 subfeature=None,
    #                                                 lod=alias_to_viewSyntax(selected_geometryLvl,'lod'),
    #                                                 g_type=alias_to_viewSyntax(selected_geometryType,'type'))
    #                     }
    #     subfeature_views={subFeature:   subFeature.get_view( schema=selected_schema,
    #                                             feature=selected_feature.view_name,
    #                                             subfeature=subFeature.view_name,
    #                                             lod=alias_to_viewSyntax(selected_geometryLvl,'lod'),
    #                                             g_type=alias_to_viewSyntax(selected_geometryType,'type')) for subFeature in selected_subFeatures
    #                         }

 
    #     feature_views.update(subfeature_views)


    #     for element,views in feature_views.items():
    #         for view in views:
    #             import_lookups(dbLoader)
    #             vlayer = create_layers(dbLoader,view.name)
    #             import_generics(dbLoader)

    #             if not vlayer or not vlayer.isValid():
    #                 dbLoader.show_Qmsg('Layer failed to load properly',msg_type=Qgis.Critical)
    #             else:
    #                 # if vlayer.featureCount()==0:
    #                 #     continue
    #                 #dbLoader.iface.mainWindow().blockSignals(True)
    #                 QgsProject.instance().addMapLayer(vlayer,False)
                    
    #                 if element.is_feature: node_flod.addLayer(vlayer)
    #                 else: 
    #                     #if thematicSurfaces_in_view in view.subfeature:

                       
    #                     node_subFeature= node_feature.findGroup(element.alias)
    #                     node_lod = node_subFeature.findGroup(table_to_alias(view.lod,'lod'))
    #                     node_lod.addLayer(vlayer)

    #                 dbLoader.iface.mainWindow().blockSignals(False) #NOTE: Temp solution to avoid undefined CRS pop up. IT IS DEFINED
    #                 dbLoader.show_Qmsg('Success!!')

    #                 vlayer.loadNamedStyle('/home/konstantinos/.local/share/QGIS/QGIS3/profiles/default/python/plugins/citydb_loader/forms/forms_style.qml') #TODO: this needs to be platform independent
    #                 create_relations(vlayer)
    #     #Its important to first order the ToC and then send it to the top. 
    #     order_ToC(node_database)     
    #     send_to_top_ToC(root,node_database)

    # except (Exception, psycopg2.DatabaseError) as error:
    #     print(error)
    #     dbLoader.show_Qmsg('Import failed! Check Log Messages',msg_type=Qgis.Critical)
    # finally:
    #     if dbLoader.conn is not None:
    #         # close the communication with the PostgreSQL
    #         #cur.close()
    #         pass
            
    

#TODO: Check if Commit is needed after every query execution https://www.psycopg.org/docs/faq.html

#TODO: drop view when layer is removed from project
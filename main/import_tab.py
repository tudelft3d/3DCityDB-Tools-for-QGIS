"""Import tab docstring"""
from importlib_metadata import metadata
from qgis.PyQt.QtWidgets import QLabel
from .constants import *
from .functions import *
from . import sql


 



def count_objects(dbLoader,view_name):

    try:
        cur=dbLoader.conn.cursor()
        cur.execute(f"""SELECT count(*),'' from qgis_pkg.{view_name}""")
        count=cur.fetchone()
        cur.close()
        count,empty=count
        return count
    except (Exception, psycopg2.DatabaseError) as error:
        print('In import_tab.count_objects:',error)
        cur.close()


def has_matviews(dbLoader) -> bool:
    mat_views = sql.fetch_mat_views(dbLoader)

    # Check if qgis_pkg has materialised views.
    if mat_views:
        return True
    return False
    
        

def fill_FeatureType_box(dbLoader):

    instantiate_objects(dbLoader)


    for FeatureType_obj in dbLoader.FeatureType_container.values():

        for view in FeatureType_obj.views:
            if view.n_selected>0:
                dbLoader.dlg.cbxFeatureType.addItem(FeatureType_obj.alias,FeatureType_obj)
            break   

def instantiate_objects(dbLoader):

    colnames,metadata = sql.fetch_layer_metadata(dbLoader)
    metadata_dict_list= [dict(zip(colnames,values)) for values in metadata]

    
    dbLoader.FeatureType_container = {
        "Building": FeatureType(alias='Building'),
        "Relief": FeatureType(alias="Relief"),
        "CityFurniture": FeatureType(alias="CityFurniture"),
        "LandUse": FeatureType(alias="LandUse"),
        "WaterBody": FeatureType(alias="WaterBody"),
        "Vegetation": FeatureType(alias='Vegetation'),
        "Generics": FeatureType(alias='Generics')
        }


    for metadata_dict in metadata_dict_list:
        
        #keys:  id,schema_name,feature_type,lod,root_class,layer_name,n_features,
        #       mv_name, v_name,qml_file,creation_data,refresh_date
        if metadata_dict["n_features"]==0: continue
        if metadata_dict["refresh_date"] is None: continue
        curr_FeatureType_obj=dbLoader.FeatureType_container[metadata_dict['feature_type']]
        view = View(*metadata_dict.values())
        curr_FeatureType_obj.views.append(view)
        sql.exec_view_counter(dbLoader,view)
        

def fill_lod_box(dbLoader):
    selected_FeatureType = dbLoader.dlg.cbxFeatureType.currentData()
    if not selected_FeatureType: return None
    geom_set=set()

    for view in selected_FeatureType.views:
        geom_set.add(view.lod)
            

    for lod in sorted(list(geom_set)):
        dbLoader.dlg.cbxLod.addItem(lod,lod)

def fill_features_box(dbLoader):
    selected_lod = dbLoader.dlg.cbxLod.currentText()
    selected_FeatureType = dbLoader.dlg.cbxFeatureType.currentData()
    
    if not selected_FeatureType: return None

    try:
        for view in selected_FeatureType.views:
            if view.lod == selected_lod:
                if view.n_selected > 0:
                    dbLoader.dlg.ccbxFeatures.addItemWithCheckState(f'{view.layer_name} ({view.n_selected})',0, userData=view)#{view.view_name:(view.FeatureType,view.schema,view.lod,view.root_feature)})

#TODO: 05-02-2021 Add separator between different features NOTE:REMEMBER: don't use method 'setSeparator', it adds a custom separtor to join string of selected items

    except AssertionError as msg:
        err = f"<b>{msg}</b> doesn\'t have any sub-features"
        QgsMessageLog.logMessage("At import_tab.py>'fill_features_box':\nERROR_MESSAGE: " + err, tag="3DCityDB-Loader",level=Qgis.Info,notifyUser=True)
        return 0

def get_view_obj_amount(dbLoader,view):
    try:
        extents = dbLoader.dlg.qgbxExtent.outputExtent().asWktPolygon()
        cur=dbLoader.conn.cursor()
        cur.callproc('qgis_pkg.view_counter',(view.view_name,extents))
        count=cur.fetchone()[0]
        cur.close()
        view.selected_count=count
        return count

    except (Exception, psycopg2.DatabaseError) as error:
        QgsMessageLog.logMessage("At import_tab.py>'get_view_obj_amount':\nERROR_MESSAGE: "+str(error),tag="3DCityDB-Loader",level=Qgis.Critical,notifyUser=True)
        dbLoader.conn.rollback()
        cur.close()
        return None

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

def get_attForm_child(container, child_name):
    for child in container.children():
        if child.name()== child_name:
            return child


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
    rel.setReferencedLayer(id= curr_layer.id())
    rel.setReferencingLayer(id= genericAtt_layer[0].id())
    rel.addFieldPair(referencingField= 'cityobject_id', referencedField= 'id')
    rel.generateId()
    rel.setName('re_'+layer.name())
    rel.setStrength(0)
    if rel.isValid():
        QgsProject.instance().relationManager().addRelation(rel)
        QgsMessageLog.logMessage(message=f"Create relation: {rel.name()}",tag="3DCityDB-Loader",level=Qgis.Success,notifyUser=True)
    else:
        QgsMessageLog.logMessage(message=f"Invalid relation: {rel.name()}",tag="3DCityDB-Loader",level=Qgis.Critical,notifyUser=True)


    container_GA = get_attForm_child(container=layer_root_container, child_name='Generic Attributes')
    container_GA.clear()

    relation_field = QgsAttributeEditorRelation(relation= rel, parent= container_GA)
    relation_field.setLabel("Generic Attributes")
    relation_field.setShowLabel(False)
    container_GA.addChildElement(relation_field)

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
            if layer or layer.isValid():
                node_lookups.addLayer(layer)
                QgsProject.instance().addMapLayer(layer,False)
                QgsMessageLog.logMessage(message=f"Look-up table import: {table}",tag="3DCityDB-Loader",level=Qgis.Success,notifyUser=True)
            else:
                QgsMessageLog.logMessage(message=f"Look-up table failed to properly load: {table}",tag="3DCityDB-Loader",level=Qgis.Critical,notifyUser=True)
            
            
        

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
        if layer or layer.isValid():
            layer.setEditorWidgetSetup(15,QgsEditorWidgetSetup('TextEdit',{})) #Force to Text Edit (instead of automatic relation widget) NOTE: harcoded index (15: cityobject_id)
            group_to_assign.addLayer(layer)
            QgsProject.instance().addMapLayer(layer,False)
            QgsMessageLog.logMessage(message=f"Layer import: {generics_layer_name}",tag="3DCityDB-Loader",level=Qgis.Success,notifyUser=True)
        else:
            QgsMessageLog.logMessage(message=f"Layer failed to properly load: {generics_layer_name}",tag="3DCityDB-Loader",level=Qgis.Critical,notifyUser=True)
 


def create_layers(dbLoader,v_view):
    selected_db=dbLoader.dlg.cbxExistingConnection.currentData()
    extents=dbLoader.dlg.qgbxExtent.outputExtent().asWktPolygon() #Readable for debugging

    #SELECT UpdateGeometrySRID('roads','geom',4326);
    uri = QgsDataSourceUri()
    uri.setConnection(selected_db.host,selected_db.port,selected_db.database_name,selected_db.username,selected_db.password)
    uri.setDataSource(aSchema= 'qgis_pkg',aTable= f'{v_view}',aGeometryColumn= 'geom',aSql=f"ST_GeomFromText('{extents}') && ST_Envelope(geom)",aKeyColumn= 'id')
    vlayer = QgsVectorLayer(uri.uri(False), f"{v_view}", "postgres")

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

    if not node_database.findGroup(view.schema_name): node_schema = node_database.addGroup(view.schema_name)
    else: node_schema = node_database.findGroup(view.schema_name)

    if not node_schema.findGroup(f'FeatureType: {view.feature_type}'): node_FeatureType = node_schema.addGroup(f'FeatureType: {view.feature_type}')
    else: node_FeatureType = node_schema.findGroup(f'FeatureType: {view.feature_type}')

    if not node_FeatureType.findGroup(view.root_class): node_feature = node_FeatureType.addGroup(view.root_class)
    else: node_feature = node_FeatureType.findGroup(view.root_class)

    if not node_feature.findGroup(view.lod): node_lod = node_feature.addGroup(view.lod)
    else: node_lod = node_feature.findGroup(view.lod)

    return node_lod

def get_checkedItemsData(ccbx):
    checked_items = []
    for idx in range(ccbx.count()):
        if ccbx.itemCheckState(idx) == 2: #is Checked
            checked_items.append(ccbx.itemData(idx))
    return checked_items

def import_layers(dbLoader,checked_views):
    for view in checked_views:
        #Building the Table of Contents Tree
        node= build_ToC(dbLoader,view)
        import_lookups(dbLoader)
        vlayer = create_layers(dbLoader,view.v_name)
        import_generics(dbLoader)


        if vlayer or vlayer.isValid():
            QgsMessageLog.logMessage(message=f"Layer import: {view.v_name}",tag="3DCityDB-Loader",level=Qgis.Success,notifyUser=True)
        else:
            QgsMessageLog.logMessage(message=f"Layer failed to properly load: {view.v_name}",tag="3DCityDB-Loader",level=Qgis.Critical,notifyUser=True)
            return False


        node.addLayer(vlayer)
        QgsProject.instance().addMapLayer(vlayer,False)
        
        vlayer.loadNamedStyle(view.qml_path)
        create_relations(vlayer)
    return True
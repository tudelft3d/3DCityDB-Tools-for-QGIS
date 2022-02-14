
from tkinter.ttk import Separator
from pandas import isnull
from qgis.PyQt.QtWidgets import QLabel
from qgis.PyQt import QtCore
from .constants import *
from .functions import *


 



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

def count_objects_in_bbox(dbLoader,checked_features,extents): #NOTE: obsolete? delete it
    selected_module = dbLoader.dlg.cbxModule.currentData()

    for feature in checked_features:
        for view in feature.views:
            cur=dbLoader.conn.cursor()
            cur.execute(f"""SELECT count(*),'' from qgis_pkg.{view.name} t
                        WHERE ST_Intersects(ST_GeomFromText('{extents}',28992), t.geom)""")
            count=cur.fetchone()
            cur.close()
            count,empty=count
            view.count = count  

def fill_module_box(dbLoader):

    modules=instantiate_objects(dbLoader)
    if not modules: return None

    for module_obj in modules.values():    

        for feature in module_obj.features.values():
            for view in feature.views:
                if view.count>0:
                    dbLoader.dlg.cbxModule.addItem(module_obj.alias,module_obj)
                    break
            else: 
                continue
            break   

def instantiate_objects(dbLoader):
    try:
        cur=dbLoader.conn.cursor()
        cur.execute(f"""SELECT * FROM qgis_pkg.metadata""")
        metadata=cur.fetchall()
        colnames = [desc[0] for desc in cur.description]
        cur.close()
    except (Exception, psycopg2.DatabaseError) as error:
        QgsMessageLog.logMessage("At import_tab.py>'instantiate_objects':\nERROR_MESSAGE: "+str(error),tag="3DCityDB-Loader",level=Qgis.Critical,notifyUser=True)
        dbLoader.conn.rollback()
        cur.close()
        return None

    metadata_dict_list= [dict(zip(colnames,f)) for f in metadata]
    
    dbLoader.module_container=   { "Building": Module(alias='Building',features={  "Building": Building(),
                                                                                "BuildingPart": BuildingPart(),
                                                                                "BuildingInstallation": BuildingInstallation(),
                                                                                "BuildingFurniture": BuildingFurniture()}),
                                "Vegetation": Module(alias='Vegetation', features= {"Vegetation": Vegetation(),
                                                                                    "PlantCover": PlantCover()})}

    dbLoader.module_container
    for metadata_dict in metadata_dict_list:
        
        #keys: id,module,root_feature,schema,lod,alias,layer_name,object_count
        if metadata_dict['object_count']==0:continue
        curr_module_obj=dbLoader.module_container[metadata_dict['module']]
        curr_feature = curr_module_obj.features[metadata_dict['root_feature']]
        curr_feature.views.append(View(*metadata_dict.values()))

    return dbLoader.module_container

def fill_lod_box(dbLoader):
    selected_module = dbLoader.dlg.cbxModule.currentData()
    if not selected_module: return None
    geom_set=set()
    geom_set_=set()
    for feature in selected_module.features.values():
        for view in feature.views:
            geom_set.add(view.lod)
            geom_set_.add(alias_to_viewSyntax(view.lod,'lod'))
            
    avalibale_lods = dict(zip(sorted(list(geom_set)),sorted(list(geom_set_))))

    for alias,lod in avalibale_lods.items():
        dbLoader.dlg.cbxLod.addItem(alias,lod)

def fill_features_box(dbLoader):
    selected_lod = dbLoader.dlg.cbxLod.currentText()
    selected_module = dbLoader.dlg.cbxModule.currentData()
    
    if not selected_module: return None

    try:
        c=0
        for c,feature in enumerate(selected_module.features.values()):
            for view in feature.views:
                if view.lod == selected_lod:  
                    count=get_view_obj_amount(dbLoader,view)
                    if count > 0:
                        dbLoader.dlg.ccbxFeatures.addItemWithCheckState(f'{view.alias} ({count})',0, userData=view)#{view.view_name:(view.module,view.schema,view.lod,view.root_feature)})

#TODO: 05-02-2021 Add separator between different features NOTE:REMEMBER: don't use method 'setSeparator', it adds a custom separtor to join string of selected items

    except AssertionError as msg:
        dbLoader.show_Qmsg(f'<b>{msg}</b> doesn\'t have any sub-features',msg_type=Qgis.Info)
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

def set_counter_label(dbLoader): #NOTE: obsolete? delete it

    checked_types = get_checked_types(dbLoader,dbLoader.dlg.gridLayout_4)
    checked_features = get_checked_features(dbLoader,dbLoader.dlg.gridLayout_2)
    selected_lod=dbLoader.dlg.cbxLod.currentText()

    msg=''
    total_count=0
    for feature in checked_features:
        for view in feature.views:
            if view.lod==alias_to_viewSyntax(selected_lod,'lod'):
                if view.representation in checked_types:
                    total_count+=view.count
                    msg+=f"    \u2116 of '{feature.alias}' objects represented as {view.representation}: {view.count}\n"
                else:
                    total_count+=view.count
                    msg+=f"\u2116 of '{feature.alias}' objects: {view.count}\n"
    label= QLabel()
    warning_icon=":/plugins/citydb_loader/icons/warning_icon.svg"
    info_icon=":/plugins/citydb_loader/icons/info_icon.svg"
    
    html="""
    <html>
    <head/>
        <body>
            <p>
            <img src="{icon_path}" width="20" height="20"/>
            <br/>{message}
            </p>
        </body>
    </html>"""

    if total_count>20000:
        label.setText(html.format(icon_path = warning_icon,message= msg))
    else:
        label.setText(html.format(icon_path = info_icon,message= msg))
    dbLoader.dlg.formLayout.addWidget(label)

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
            group_to_assign.addLayer(layer)
            QgsProject.instance().addMapLayer(layer,False)
            QgsMessageLog.logMessage(message=f"Layer import: {generics_layer_name}",tag="3DCityDB-Loader",level=Qgis.Success,notifyUser=True)
        else:
            QgsMessageLog.logMessage(message=f"Layer failed to properly load: {generics_layer_name}",tag="3DCityDB-Loader",level=Qgis.Critical,notifyUser=True)
 


def create_layers(dbLoader,view):
    selected_db=dbLoader.dlg.cbxExistingConnection.currentData()
    extents=dbLoader.dlg.qgbxExtent.outputExtent().asWktPolygon() #Readable for debugging

    #SELECT UpdateGeometrySRID('roads','geom',4326);
    uri = QgsDataSourceUri()
    uri.setConnection(selected_db.host,selected_db.port,selected_db.database_name,selected_db.username,selected_db.password)
    uri.setDataSource(aSchema= 'qgis_pkg',aTable= f'{view}',aGeometryColumn= 'geom',aSql=f"ST_GeomFromText('{extents}') && ST_Envelope(geom)",aKeyColumn= 'id')
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

    if not node_schema.findGroup(f'Module: {view.module}'): node_module = node_schema.addGroup(f'Module: {view.module}')
    else: node_module = node_schema.findGroup(f'Module: {view.module}')

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

def import_layers(dbLoader,checked_views):
    for view in checked_views:
        #Building the Table of Contents Tree
        node= build_ToC(dbLoader,view)
        import_lookups(dbLoader)
        vlayer = create_layers(dbLoader,view.view_name)
        import_generics(dbLoader)


        if vlayer or vlayer.isValid():
            QgsMessageLog.logMessage(message=f"Layer import: {view.view_name}",tag="3DCityDB-Loader",level=Qgis.Success,notifyUser=True)
        else:
            QgsMessageLog.logMessage(message=f"Layer failed to properly load: {view.view_name}",tag="3DCityDB-Loader",level=Qgis.Critical,notifyUser=True)
            return False


        node.addLayer(vlayer)
        QgsProject.instance().addMapLayer(vlayer,False)
        
        vlayer.loadNamedStyle('/home/konstantinos/.local/share/QGIS/QGIS3/profiles/default/python/plugins/citydb_loader/forms/forms_style.qml') #TODO: this needs to be platform independent
        create_relations(vlayer)
    return True
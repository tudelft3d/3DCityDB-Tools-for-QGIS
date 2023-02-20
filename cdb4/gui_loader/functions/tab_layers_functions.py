"""This module contains functions that relate to the 'Import Tab' (in the GUI look for the plugin logo).
These functions are usually called from widget_setup functions relating to child widgets of the 'Import Tab'.
"""
from __future__ import annotations
from typing import TYPE_CHECKING
if TYPE_CHECKING:       
    from ...gui_loader.loader_dialog import CDB4LoaderDialog
    from ..other_classes import FeatureType

from collections import OrderedDict
from qgis.core import (QgsProject, QgsMessageLog, QgsEditorWidgetSetup, 
                        QgsVectorLayer, QgsDataSourceUri, QgsAttributeEditorElement,
                        QgsAttributeEditorRelation, Qgis, QgsLayerTreeGroup,
                        QgsRelation, QgsAttributeEditorContainer, QgsMapLayer)

from ..other_classes import CDBLayer
from .. import loader_constants as c
from . import sql

def has_matviews(dlg: CDB4LoaderDialog) -> bool:
    """Function that checks the existence of materialised views in the database.

    *   :returns: Whether the database has populated mat views.
        :rtype: bool
    """
    # Get materialised views names.
    mat_views = sql.fetch_mat_views(dlg)

    # Check if materialised views names exist.
    if mat_views:
        return True
    return False


def add_layers_to_register(dlg: CDB4LoaderDialog) -> None:
    """Function to instantiate python objects from the 'layer_metadata' table in the usr_schema.
    """
    # Clean up the layers in the registry from previous runs
    feat_type: FeatureType
    for feat_type in dlg.FeatureTypesRegistry.values():
        feat_type.layers = [] # Empty the list the will contain CDBLayer objects

    # Get field names and metadata values from server.
    col_names, layer_metadata = sql.fetch_layer_metadata(dlg, dlg.USR_SCHEMA, dlg.CDB_SCHEMA)

    # Format metadata into a list of dictionaries where each element is a layer.
    layer_metadata_dict_items: list = [dict(zip(col_names, values)) for values in layer_metadata]

    for layer_metadata_dict_item in layer_metadata_dict_items:
        # keys: id, cdb_schema, layer_type, feature_type, lod, root_class, curr_class, layer_name, 
        #       av_name, gv_name, n_features, creation_data, refresh_date,
        #       qml_form, qml_symb, qml_3d, 
        #       qml_form_with_path, qml_symb_with_path, qml_3d_with_path
        #       n_selected

        if layer_metadata_dict_item["n_features"] == 0:        # ignore those layers that have no features
            continue
        if layer_metadata_dict_item["refresh_date"] is None:   # ignore those layers that have not been refreshed
            continue

        # Create a Layer object with all the values extracted from 'layer_metadata'.
        layer = CDBLayer(*layer_metadata_dict_item.values())

        # Count the number of features that the layer has in the current extents.
        sql.exec_gview_counter(dlg, layer) # Stores number in layer.n_selected.

        # Get the FeatureType object of the current layer
        curr_FeatureType: FeatureType = dlg.FeatureTypesRegistry[layer_metadata_dict_item['feature_type']]

        # Add the view to the FeatureObject views list
        curr_FeatureType.layers.append(layer)

    return None


def fill_feature_type_box(dlg: CDB4LoaderDialog) -> None:
    """Function that fills out the 'Feature Types' combo box.
    Uses the 'layer_metadata' table in usr_schema to instantiate useful python objects
    """
    # Create 'Feature Type' and 'View' objects
    add_layers_to_register(dlg)
    
    ft: FeatureType
    layer: CDBLayer

    # Clear from previous runs
    dlg.cbxFeatureType.clear()

    # Add only those Feature Types that have at least one view containing > 0 features.
    for key, ft in dlg.FeatureTypesRegistry.items():
        for layer in ft.layers:
            if layer.n_selected > 0:
                dlg.cbxFeatureType.addItem(key, ft)
                # The first FeatureType object added in 'cbxFeatureType' emits a 'currentIndexChanged' signal.
                break # We need only one view to have > 0 features.


def fill_lod_box(dlg: CDB4LoaderDialog) -> None:
    """Function that fills out the 'Geometry Level' combo box (LoD).
    """
    # Get 'FeatureType' object from combo box data.
    selected_ft: FeatureType = dlg.cbxFeatureType.currentData()
    if not selected_ft:
        return None

    geom_set = set() # To store the unique lods.
    layer: CDBLayer
    for layer in selected_ft.layers:
        geom_set.add(layer.lod)

    # Clean from previous runs
    dlg.cbxLod.clear()

    # Add lod string into both text and data holder of combo box.
    for lod in sorted(list(geom_set)):
        # The first LoD string added in 'cbxLod' emits a 'currentIndexChanged' signal.
       dlg.cbxLod.addItem(lod, lod)


def fill_layers_box(dlg: CDB4LoaderDialog) -> None:
    """Function that fills the 'Layers' checkable combo box.
    """
    selected_ft: FeatureType
    # Get current 'Feature Type' from widget.
    selected_ft = dlg.cbxFeatureType.currentData()

    # Get current 'LoD' from widget.
    selected_lod = dlg.cbxLod.currentText()

    if not selected_ft or not selected_lod:
        return None

    # Clear from previous run
    dlg.ccbxLayers.clear()

    layer: CDBLayer
    #selected_FeatureType: FeatureTypeLayersGroup
    for layer in selected_ft.layers:
        if layer.lod == selected_lod:
            if layer.n_selected > 0:
                dlg.ccbxLayers.addItemWithCheckState(
                    text=f'{layer.layer_name} ({layer.n_selected})',
                    state=0,
                    userData=layer)
    # TODO: 05-02-2021 Add separator between different features
    # REMEMBER: don't use method 'setSeparator', it adds a custom separator to join string of selected items


def value_rel_widget(
        AllowMulti: bool = False,
        AllowNull: bool = True,
        FilterExpression: str = "",
        Layer: str = "",
        Key: str = "",
        Value: str = "",
        NofColumns: int = 1,
        OrderByValue: bool = False,
        UseCompleter: bool = False) -> QgsEditorWidgetSetup:
    """Function to setup the configuration dictionary for the 'ValueRelation' widget.
    .. Note:this function could probably be generalized for all available
    ..      widgets of 'attribute from', but there is not need for this yet.

    *   :returns: The object to set up the widget (ValueRelation)
        :rtype: QgsEditorWidgetSetup
    """
    config = {'AllowMulti': AllowMulti,
              'AllowNull': AllowNull,
              'FilterExpression':FilterExpression,
              'Layer': Layer,
              'Key': Key,
              'Value': Value,
              'NofColumns': NofColumns,
              'OrderByValue': OrderByValue,
              'UseCompleter': UseCompleter}
              
    return QgsEditorWidgetSetup(type='ValueRelation', config=config)


def get_attForm_child(container: QgsAttributeEditorContainer, child_name: str) -> QgsAttributeEditorElement:
    """Function that retrieves a child object from an 'attribute form' container.
    
    *   :param container: An attribute form container object.
        :type container: QgsAttributeEditorContainer

    *   :param child_name: The name of the child to be found.
        :type child_name: str

    *   :returns: The 'attribute form' child element (when found)
        :type child_name: QgsAttributeEditorElement | None
    """
    for child in container.children():
        if child.name() == child_name:
            return child
    return None


def create_layer_relation_to_lookup_tables(dlg: CDB4LoaderDialog, layer: QgsVectorLayer) -> None:
    """Function that sets up the ValueRelation widget for the look-up tables.
    #Note: Currently the look-up table names are hardcoded.

    *   :param layer: Layer to search for and set up its 'Value Relation' widget according to the look-up tables.
        :type layer: QgsVectorLayer
    """
    # Isolate the layer's ToC environment to avoid grabbing the first layer encountered in the WHOLE ToC.
    root = QgsProject.instance().layerTreeRoot()
    db_node = root.findGroup(dlg.DB.database_name)
    schema_node = db_node.findGroup("@".join([dlg.DB.username, dlg.CDB_SCHEMA]))
    look_node = schema_node.findGroup("Look-up tables")
    look_layers = look_node.findLayers()
    enum_layer_id = [i.layerId() for i in look_layers if c.enumerations_table in i.layerId()][0]

    #assertion_msg = "Layer '{}' doesn\'t exist in project. This layer is also imported with every layer (if it doesn\'t already exist)."
    #assert enum_layer_id, assertion_msg.format(f'{dlg.CDB_SCHEMA}_v_enumeration_value')
    #QgsMessageLog.logMessage(f"enum_layer_id: {enum_layer_id}", "3DCityDB-Loader", level=Qgis.Info)

    for field in layer.fields():
        field_name = field.name()
        field_idx = layer.fields().indexOf(field_name)
        if field_name == 'relative_to_terrain':
            layer.setEditorWidgetSetup(field_idx, value_rel_widget(Layer=enum_layer_id, Key='value', Value='description', FilterExpression="data_model = 'CityGML 2.0' AND name = 'RelativeToTerrainType'"))
        elif field_name == 'relative_to_water':
            layer.setEditorWidgetSetup(field_idx, value_rel_widget(Layer=enum_layer_id, Key='value', Value='description', FilterExpression="data_model = 'CityGML 2.0' AND name = 'RelativeToWaterType'"))


def create_layer_relation_to_genericattrib_table(dlg: CDB4LoaderDialog, layer: QgsVectorLayer) -> None:
    """Function to set up the relation for an input layer (e.g. a view).
    - A new relation object is created that references the generic attributes.
    - Relations are also set for 'Value Relation' widget.

    *   :param layer: vector layer to set up the relationships for.
        :type layer: QgsVectorLayer
    """
    # Get the layer configuration
    layer_configuration = layer.editFormConfig()
    layer_root_container = layer_configuration.invisibleRootContainer()

    # Isolate the layers' ToC environment to avoid grabbing the first layer encountered in the WHOLE ToC.
    root = QgsProject.instance().layerTreeRoot()
    db_node = root.findGroup(dlg.DB.database_name)
    schema_node = db_node.findGroup("@".join([dlg.DB.username,dlg.CDB_SCHEMA]))
    generics_node = schema_node.findGroup("Generic Attributes")
    genericAtt_layer = generics_node.findLayers()[0]

    #assertion_msg = "Layer '{}' doesn\'t exist in project. This layer is also  imported with every layer (if it doesn\'t already exist)."
    #assert genericAtt_layer, assertion_msg.format(f'{dlg.CDB_SCHEMA}_cityobject_generic_attrib')

    # Create new Relation object for referencing generic attributes table
    rel = QgsRelation()
    rel.setReferencedLayer(id=layer.id())  # i.e. the (QGIS  internal) id of the CityObject layer
    rel.setReferencingLayer(id=genericAtt_layer.layerId()) # i.e. the (QGIS  internal) id of the CityObject layer
    rel.addFieldPair(referencingField='cityobject_id', referencedField='id')
    rel.generateId() # i.e. the (QGIS  internal) id of the relation object
    rel.setName('re_' + layer.name())

    #QgsMessageLog.logMessage(f"QGIS version {dlg.QGIS_VERSION_MAJOR}.{dlg.QGIS_VERSION_MINOR}", dlg.PLUGIN_NAME, level=Qgis.Info)



    ## Till QGIS 3.26 the argument of setStrength is numeric, from QGIS 3.28 it is an enumeration
    if dlg.QGIS_VERSION_MAJOR == 3 and dlg.QGIS_VERSION_MINOR < 28:
        rel.setStrength(0) # integer, 0 is association, 1 composition
    else:
        rel_strength = Qgis.RelationshipStrength(0) # integer, 0 is association, 1 composition
        #print(rel_strength)
        rel.setStrength(rel_strength)

    #QgsMessageLog.logMessage(f"**** The current relation has strength: {rel.strength()}", dlg.PLUGIN_NAME, level=Qgis.Info)  

    if rel.isValid(): # Success
        QgsProject.instance().relationManager().addRelation(rel)
        QgsMessageLog.logMessage(
            message=f"Create relation: {rel.name()}",
            tag=dlg.PLUGIN_NAME,
            level=Qgis.Success,
            notifyUser=True)
    else:
        QgsMessageLog.logMessage(
            message=f"Invalid relation: {rel.name()}",
            tag=dlg.PLUGIN_NAME,
            level=Qgis.Critical,
            notifyUser=True)

    # Find and store 'Generic Attributes' 'attribute form' element.
    container_GA = get_attForm_child(container=layer_root_container, child_name='Generic Attributes')
    # Clean the element before inserting the relation
    container_GA.clear()

    # Create an 'attribute form' relation object from the 'relation' object
    relation_field = QgsAttributeEditorRelation(relation=rel, parent=container_GA)
    relation_field.setLabel("Generic Attributes")
    relation_field.setShowLabel(False) # No point setting a label then.
    # Add the relation to the 'Generic Attributes' container (tab).
    container_GA.addChildElement(relation_field)

    # Commit?
    layer.setEditFormConfig(layer_configuration)


def is_layer_already_in_ToC_group(group: QgsLayerTreeGroup, layer_name: str) -> bool:
    """Function that checks whether a specific group has a specific underlying layer (by name).

    *   :param group: Node object to check for layer existence.
        :type group: QgsLayerTreeGroup

    *   :param layer_name: Layer name to check if it exists.
        :type layer_name: str

    *   :returns: Search result.
        :rtype: bool
    """
    if layer_name in [child.name() for child in group.children()]:
        return True
    return False


def add_lookup_tables_to_ToC(dlg: CDB4LoaderDialog) -> None:
    """Function to import the look-up tables into the qgis project.
    """
    # Just to shorten the variables names.
    db = dlg.DB
    cdb_schema: str = dlg.CDB_SCHEMA
    usr_schema: str = dlg.USR_SCHEMA

    # Add look-up tables into their own group in ToC.
    node_cdb_schema = QgsProject.instance().layerTreeRoot().findGroup("@".join([db.username, cdb_schema]))

    lookups_node = add_group_node_to_ToC(parent_node=node_cdb_schema, child_name="Look-up tables")

    # Get look-up tables names from the server.
    lookup_tables = sql.fetch_lookup_tables(dlg)

    for lookup_table in lookup_tables:
        # Create ONLY new layers.
        if not is_layer_already_in_ToC_group(group=lookups_node, layer_name=f"{dlg.CDB_SCHEMA}_{lookup_table}"):
            uri = QgsDataSourceUri()
            uri.setConnection(db.host, db.port, db.database_name, db.username, db.password)
            uri.setDataSource(aSchema=usr_schema, aTable=lookup_table, aGeometryColumn=None, aKeyColumn="id")
            layer = QgsVectorLayer(uri.uri(False), f"{cdb_schema}_{lookup_table}", "postgres")
            if layer or layer.isValid(): # Success
                lookups_node.addLayer(layer)
                QgsProject.instance().addMapLayer(layer, False)
                QgsMessageLog.logMessage(
                    message=f"Look-up table import: {cdb_schema}_{lookup_table}",
                    tag=dlg.PLUGIN_NAME,
                    level=Qgis.Success, notifyUser=True)
            else: # Fail
                QgsMessageLog.logMessage(
                    message=f"Look-up table failed to properly load: {cdb_schema}_{lookup_table}",
                    tag=dlg.PLUGIN_NAME,
                    level=Qgis.Critical, notifyUser=True)

    # After loading all look-ups, sort them by name.
    sort_ToC(lookups_node)


def add_genericattrib_table_to_ToC(dlg: CDB4LoaderDialog) -> None:
    """Function to import the 'generic attributes' table into the qgis project.
    """
    # Just to shorten the variables names.
    db = dlg.DB
    cdb_schema = dlg.CDB_SCHEMA

    # Add generics tables into their own group in ToC.
    root = QgsProject.instance().layerTreeRoot().findGroup("@".join([db.username, cdb_schema]))
    generics_node = add_group_node_to_ToC(parent_node=root, child_name=c.generics_alias)

    # Add it ONLY if it doesn't already exists.
    if not is_layer_already_in_ToC_group(generics_node, f"{dlg.CDB_SCHEMA}_{c.generics_table}"):
        uri = QgsDataSourceUri()
        uri.setConnection(db.host, db.port, db.database_name, db.username, db.password)
        uri.setDataSource(aSchema=cdb_schema,
            aTable=c.generics_table,
            aGeometryColumn=None,
            aKeyColumn="")
        layer = QgsVectorLayer(uri.uri(False), f"{dlg.CDB_SCHEMA}_{c.generics_table}", "postgres")
        if layer or layer.isValid(): # Success
            # NOTE: Force cityobject_id to Text Edit (relation widget, automatically set by qgis)
            # WARNING: hardcoded index (15: cityobject_id)
            layer.setEditorWidgetSetup(15, QgsEditorWidgetSetup('TextEdit',{}))

            generics_node.addLayer(layer)
            QgsProject.instance().addMapLayer(layer, False)

            QgsMessageLog.logMessage(
                message=f"Layer import: {dlg.CDB_SCHEMA}_{c.generics_table}",
                tag=dlg.PLUGIN_NAME,
                level=Qgis.Success,
                notifyUser=True)
        else:
            QgsMessageLog.logMessage(
                message=f"Layer failed to properly load: {dlg.CDB_SCHEMA}_{c.generics_table}",
                tag=dlg.PLUGIN_NAME,
                level=Qgis.Critical,
                notifyUser=True)


def create_qgis_vector_layer(dlg: CDB4LoaderDialog, layer_name: str) -> QgsVectorLayer:
    """Function that creates a PostgreSQL layer based on the input layer name. This function is used to import
    updatable views from the usr_schema queried to the selected spatial extents.

    *   :param v_name: View name to connect to server.
        :type v_name: str

    *   :returns: the created layer object
        :rtype: QgsVectorLayer
    """
    # Shorten the variable names.
    db = dlg.DB
    usr_schema = dlg.USR_SCHEMA
    extents = dlg.QGIS_EXTENTS.asWktPolygon()
    crs = dlg.CRS

    uri = QgsDataSourceUri()
    uri.setConnection(db.host, db.port, db.database_name, db.username, db.password)

    if dlg.QGIS_EXTENTS == dlg.LAYER_EXTENTS:  
        # No need to apply a spatial filter in QGIS
        uri.setDataSource(aSchema=usr_schema, aTable=layer_name, aGeometryColumn="geom", aKeyColumn="id")
    else:
        uri.setDataSource(aSchema=usr_schema, aTable=layer_name, aGeometryColumn="geom", aSql=f"ST_GeomFromText('{extents}') && geom", aKeyColumn="id")

    new_layer = QgsVectorLayer(uri.uri(False), layer_name, "postgres")
    new_layer.setCrs(crs)

    return new_layer


def send_to_ToC_top(group: QgsLayerTreeGroup) -> None: 
    """Function that send the input group to the top of the project's 'Table of Contents' tree.
    #NOTE: this function could be generalized to accept ToC index location as a parameter (int).
    """
    # According to qgis docs, this is the prefered way.
    root = QgsProject.instance().layerTreeRoot()
    move_group =  group.clone()
    root.insertChildNode(0, move_group)
    root.removeChildNode(group)


def send_to_ToC_bottom(node: QgsLayerTreeGroup) -> None:
    """Function that send the input group to the bottom of the project's 'Table of Contents' tree.
    #NOTE: this function could be generalized to accept ToC index location as a parameter (int).
    """
    group = None
    names = [ch.name() for ch in node.children()]
    if 'FeatureType: Relief' in names:
        for c,i in enumerate(node.children()):
            if 'FeatureType: Relief' == i.name():
                group = i
                break
        if group:
            idx=len(node.children())-2
            move_group =  group.clone()
            node.insertChildNode(idx, move_group)
            node.removeChildNode(group)
        return None
    
    for child in node.children():
        send_to_ToC_bottom(child)


def get_citydb_node(dlg: CDB4LoaderDialog) -> QgsLayerTreeGroup:
    """Function that finds the citydb node in the project's 'Table of Contents' tree (by name).

    *   :returns: citydb node (qgis group)
        :rtype: QgsLayerTreeGroup
    """
    root = QgsProject.instance().layerTreeRoot()
    cdb_node = root.findGroup(dlg.DB.database_name)
    return cdb_node


def sort_ToC(group: QgsLayerTreeGroup) -> None:
    """Recursive function to sort the entire 'Table of Contents' tree,
    including both groups and underlying layers.
    """
    # Germán Carrillo BEGIN: https://gis.stackexchange.com/questions/397789/sorting-layers-by-name-in-one-specific-group-of-qgis-layer-tree #
    LayerNamesEnumDict = lambda listCh:{listCh[q[0]].name() + str(q[0]):q[1] for q in enumerate(listCh)}

    # group instead of root
    mLNED = LayerNamesEnumDict(group.children())
    mLNEDkeys = OrderedDict(sorted(LayerNamesEnumDict(group.children()).items(), reverse=False)).keys()

    mLNEDsorted = [mLNED[k].clone() for k in mLNEDkeys]
    group.insertChildNodes(0,mLNEDsorted)  # group instead of root
    for n in mLNED.values():
        group.removeChildNode(n)  # group instead of root
    # Germán Carrillo END #

    group.setExpanded(True)
    for child in group.children():
        if isinstance(child, QgsLayerTreeGroup):
            sort_ToC(child)
        else: return None
    return None


def add_group_node_to_ToC(parent_node: QgsLayerTreeGroup, child_name: str) -> QgsLayerTreeGroup:
    """Function that adds a node (group) into the qgis project 'Table of Contents' tree (by name).
    It also checks if the node already exists and returns it.

    *   :param parent_node: A node on which the new node is going to be added
            (or returned if it already exists).
        :type parent_node: QgsLayerTreeGroup

    *   :param child_name: A string name of the new or existing node (group).
        :type child_name: str

    *   :returns: The newly created node object (or the existing one).
        :rtype: QgsLayerTreeGroup
    """
    # node_name group (e.g. test_db)
    if not parent_node.findGroup(child_name):
        # Create group
        node = parent_node.addGroup(child_name)
    else:
        # Get existing group
        node = parent_node.findGroup(child_name)
    return node


def add_layer_node_to_ToC(dlg: CDB4LoaderDialog, layer: CDBLayer) -> QgsLayerTreeGroup:
    """Function that populates the project's 'Table of Contents' tree.

    *   :param view: The view used to build the ToC.
        :type view: View

    *   :returns: The node (group) where the view is going to be added.
        :rtype: QgsLayerTreeGroup
    """
    root = QgsProject.instance().layerTreeRoot()
    # Database group (e.g. delft)
    node_cdb = add_group_node_to_ToC(parent_node=root, child_name=dlg.DB.database_name)
    # Schema group (e.g. citydb)
    node_cdb_schema = add_group_node_to_ToC(parent_node=node_cdb, child_name="@".join([dlg.DB.username, layer.cdb_schema]))
    # FeatureType group (e.g. Building)
    node_featureType = add_group_node_to_ToC(parent_node=node_cdb_schema, child_name=f"FeatureType: {layer.feature_type}")
    # Feature group (e.g. Building Part)
    node_feature = add_group_node_to_ToC(parent_node=node_featureType, child_name=layer.root_class)
    # LoD group (e.g. lod2)
    node_lod = add_group_node_to_ToC(parent_node=node_feature, child_name=layer.lod)

    return node_lod # Node where the view has been added


def add_selected_layers_to_ToC(dlg: CDB4LoaderDialog, layers: list) -> bool:
    """Function to imports the selected layer(s) in the user's qgis project.

    *   :param layers: A list containing View object that correspond to the server views.
        :type layers: list(View)

    *   :returns: The import attempt result
        :rtype: bool
    """
    if not layers:
        # nothing to do
        return None # Exit

    # Just to shorten the variables names.
    db = dlg.DB
    cdb_schema: str = dlg.CDB_SCHEMA

    root = QgsProject.instance().layerTreeRoot()
    node_cdb: QgsLayerTreeGroup = root.findGroup(db.database_name)
    node_cdb_schema: QgsLayerTreeGroup = None
    node_featureType: QgsLayerTreeGroup = None
    node_feature: QgsLayerTreeGroup = None
    node_lod: QgsLayerTreeGroup = None

    lookup_found: bool = False
    genattrib_found: bool = False
    layer_found: bool = False

    if node_cdb:
        node_cdb_schema = root.findGroup("@".join([db.username, cdb_schema]))
        if node_cdb_schema:
            # Check whether the generic attribute table is already loaded
            node_genatt = node_cdb_schema.findGroup(c.generics_alias)
            if node_genatt:
                ga_layers: list = node_genatt.findLayers()
                for ga_layer in ga_layers:  
                    if ga_layer.name() == "_".join([cdb_schema, c.generics_table]):
                        genattrib_found = True

            # Check whether the generic attribute table is already loaded
            node_lookup = node_cdb_schema.findGroup("Look-up tables")
            if node_lookup:
                lu_layers: list = node_lookup.findLayers()
                for lu_layer in lu_layers:  
                    if lu_layer.name() == "_".join([cdb_schema, c.enumerations_table]):
                        lookup_found = True
        else:
            node_cdb_schema = add_group_node_to_ToC(node_cdb, "@".join([db.username, cdb_schema]))
    else:
        node_cdb = add_group_node_to_ToC(root, db.database_name)
        node_cdb_schema = add_group_node_to_ToC(node_cdb, "@".join([db.username, cdb_schema]))

    # Get the look-up tables if they are not already loaded 
    if not genattrib_found:
        node_genatt = add_group_node_to_ToC(node_cdb_schema, c.generics_alias) 
        add_lookup_tables_to_ToC(dlg)
    else:
        #QgsMessageLog.logMessage(f"Generic attributes table already loaded: skipping", dlg.PLUGIN_NAME, level=Qgis.Info, notifyUser=True)
        pass

    # Get the generic attributes table if it is not already loaded 
    if not lookup_found:
        node_lookup = add_group_node_to_ToC(node_cdb_schema, "Look-up tables") 
        add_genericattrib_table_to_ToC(dlg)
    else:
        #QgsMessageLog.logMessage(f"Look-up tables already loaded: skipping", dlg.PLUGIN_NAME, level=Qgis.Info, notifyUser=True)
        pass

    # Start loading the selected layer(s)
    layer: CDBLayer
    for layer in layers:
        # print(layer.__dict__)
        # Check if the layer has already been loaded before
        layer_found = False
        node_featureType = node_cdb_schema.findGroup(f"FeatureType: {layer.feature_type}")
        if node_featureType:
            node_feature = node_featureType.findGroup(layer.root_class)
            if node_feature:
                node_lod = node_feature.findGroup(layer.lod)
                if node_lod:
                    existing_layers: list = node_lod.findLayers()
                    for existing_layer in existing_layers:
                        if existing_layer.name() == layer.layer_name:
                            layer_found = True

        if layer_found:
            QgsMessageLog.logMessage(f"Layer {layer.layer_name} already in Layer Tree: skip reloading", dlg.PLUGIN_NAME, level=Qgis.Info, notifyUser=True)
            continue

        # Build the Table of Contents Tree or Restructure it.
        node_lod = add_layer_node_to_ToC(dlg, layer)

        new_layer: QgsVectorLayer = create_qgis_vector_layer(dlg, layer_name=layer.layer_name)

        if new_layer or new_layer.isValid(): # Success
            QgsMessageLog.logMessage(
                message=f"Layer imported: {layer.layer_name}",
                tag=dlg.PLUGIN_NAME,
                level=Qgis.Success,
                notifyUser=True)
        else: # Fail
            QgsMessageLog.logMessage(
                message=f"Failed to properly load: {layer.layer_name}",
                tag=dlg.PLUGIN_NAME,
                level=Qgis.Critical,
                notifyUser=True)
            return False

        # Set the layer as read-only if the current cdb_schema is read only
        if dlg.CDBSchemaPrivileges == "ro":
            new_layer.setReadOnly()

        # Attach 'attribute form' from QML file.
        if layer.qml_form:
            new_layer.loadNamedStyle(theURI=layer.qml_form_with_path, categories=QgsMapLayer.Fields|QgsMapLayer.Forms)
            # otherwise: categories=QgsMapLayer.AllStyleCategories

        # Attach 'symbology' from QML file.
        if layer.qml_symb:
            new_layer.loadNamedStyle(layer.qml_symb_with_path, categories=QgsMapLayer.Symbology)

        if dlg.cbxEnable3D.isChecked():
            # Attach '3d symbology' from QML file.
            if layer.qml_3d:
                new_layer.loadNamedStyle(layer.qml_3d_with_path, categories=QgsMapLayer.Symbology3D)
        else:
            # Deactivate 3D renderer to avoid crashes and slow downs.
            new_layer.setRenderer3D(None)

        # Insert the layer to the assigned group
        node_lod.addLayer(new_layer)
        QgsProject.instance().addMapLayer(new_layer, False)

        # Setup the relations for this layer to the look-up (enumeration) tables
        create_layer_relation_to_lookup_tables(dlg, layer=new_layer)

        # Setup the relations for this layer to the generic attributes table
        create_layer_relation_to_genericattrib_table(dlg, layer=new_layer)

    return True # All went well

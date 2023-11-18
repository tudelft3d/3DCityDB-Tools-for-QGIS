"""This module contains functions that relate to the 'Import Tab' (in the GUI look for the plugin logo).
These functions are usually called from widget_setup functions relating to child widgets of the 'Import Tab'.
"""
from __future__ import annotations
from typing import TYPE_CHECKING, Union, cast, Iterable, Optional
if TYPE_CHECKING:       
    from ...gui_loader.loader_dialog import CDB4LoaderDialog
    from ..other_classes import FeatureType, CDBDetailView, EnumConfig 

from collections import OrderedDict
from qgis.core import (QgsProject, QgsMessageLog, QgsEditorWidgetSetup, 
                        QgsVectorLayer, QgsDataSourceUri, QgsAttributeEditorElement,
                        QgsAttributeEditorRelation, Qgis, QgsLayerTreeGroup,
                        QgsRelation, QgsAttributeEditorContainer, QgsMapLayer, QgsLayerTreeLayer)

from ..other_classes import CDBLayer, CodeListConfig
from .. import loader_constants as c
from . import sql

def populate_codelist_config_registry(dlg: CDB4LoaderDialog, codelist_set_name: str = None) -> None:
    """Function to create the dictionary containing Codelist Lookup Config metadata.
    """
    ####################################
    # codelist_set_name = ["CityGML 2.0"]
    ####################################

    if not codelist_set_name:
        return None # Exit, nothing to do

    # This is a list of named tuples, extracted from the db sorting by gen_name
    config_metadata = sql.get_codelist_lookup_config(dlg, codelist_set_name)
    if not config_metadata:
        return None # Exit, nothing to do
    # print(config_metadata)

    config_metadata_keys = [(elem.source_class, elem.source_table, elem.source_column) for elem in config_metadata]
    # Sort
    config_metadata_keys.sort(key=lambda x: (x[0], x[1], x[2]), reverse=False)
    # print(config_metadata_keys)

    config_metadata_values = [CodeListConfig(*elem) for elem in config_metadata]
    # Sort
    config_metadata_values.sort(key=lambda x: (x.source_class, x.source_table, x.source_column))

    dlg.CodeListConfigRegistry: dict = {}
    dlg.CodeListConfigRegistry = dict(zip(config_metadata_keys, config_metadata_values))

    # print('Initializing:\n', dlg.CodeListConfigRegistry)
    # print('Initializing:\n', dlg.CodeListConfigRegistry[("Building", "building", "class")].__dict__)

    return None


def add_layers_to_feature_type_registry(dlg: CDB4LoaderDialog) -> None:
    """Function to instantiate python objects from the 'layer_metadata' table in the usr_schema.
    """
    # Clean up the layers in the registry from previous runs
    feat_type: FeatureType
    for feat_type in dlg.FeatureTypesRegistry.values():
        feat_type.layers = [] # Empty the list the will contain CDBLayer objects

    # Get field names and metadata values from server.
    col_names, layer_metadata = sql.get_layer_metadata(dlg)

    # Format metadata into a list of dictionaries where each element is a layer.
    layer_metadata_dict_items: list = [dict(zip(col_names, values)) for values in layer_metadata]

    for layer_metadata_dict_item in layer_metadata_dict_items:
        # keys: id, cdb_schema, layer_type, feature_type, lod, root_class, curr_class, layer_name, 
        #       gv_name, av_name, n_features, creation_data, refresh_date,
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
        sql.exec_gview_counter(dlg=dlg, layer=layer) # Stores number in layer.n_selected.

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
    add_layers_to_feature_type_registry(dlg)
    
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


def get_attForm_child(container: QgsAttributeEditorContainer, child_name: str) -> QgsAttributeEditorElement:
    """Function that retrieves a child object from an 'attribute form' container.
    
    *   :param container: An attribute form container object.
        :type container: QgsAttributeEditorContainer

    *   :param child_name: The name of the child to be found.
        :type child_name: str

    *   :returns: The 'attribute form' child element (when found)
        :type child_name: QgsAttributeEditorElement | None
    """
    # print('looking for ', child_name)
    for child in container.children():
        # print(child.name())
        if child.name() == child_name:
            return child
    return None


def send_to_ToC_top(group: QgsLayerTreeGroup) -> None: 
    """Function that send the input group to the top of the project's 'Table of Contents' tree.
    #NOTE: this function could be generalized to accept ToC index location as a parameter (int).
    """
    # According to qgis docs, this is the prefered way.
    root = QgsProject.instance().layerTreeRoot()
    move_group =  group.clone()
    root.insertChildNode(index=0, node=move_group)
    root.removeChildNode(node=group)


def send_to_ToC_bottom(node: QgsLayerTreeGroup) -> None:
    """Function that send the input group to the bottom of the project's 'Table of Contents' tree.
    # NOTE: this function could be generalized to accept ToC index location as a parameter (int).
    """
    group = None
    names = [child.name() for child in node.children()]
    if 'FeatureType: Relief' in names:
        for c,i in enumerate(node.children()):
            if i.name() == 'FeatureType: Relief':
                group = i
                break
        if group:
            idx=len(node.children())-2
            move_group = group.clone()
            node.insertChildNode(index=idx, node=move_group)
            node.removeChildNode(node=group)
        return None
    
    for child in node.children():
        send_to_ToC_bottom(child)


def get_citydb_node(dlg: CDB4LoaderDialog) -> QgsLayerTreeGroup:
    """Function that finds the citydb node in the project's 'Table of Contents' tree (by name).

    *   :returns: citydb node
        :rtype: QgsLayerTreeGroup
    """

    root = QgsProject.instance().layerTreeRoot()
    cdb_node = root.findGroup(dlg.DB.db_toc_node_label)
    # cdb_node = root.findGroup(dlg.DB.database_name)
    return cdb_node


def get_all_dv_and_lu_nodes(dlg: CDB4LoaderDialog) -> list[QgsLayerTreeGroup]:
    """Function that finds the citydb node in the project's 'Table of Contents' tree (by name).

    *   :returns: citydb node (qgis group)
        :rtype: QgsLayerTreeGroup
    """

    root = QgsProject.instance().layerTreeRoot()
    group_nodes = root.findGroups(recursive=True) # Get all Group nodes, also those containing the dv and lu tables
    dv_lu_nodes: list[QgsLayerTreeGroup] = []

    if len(group_nodes) != 0:
        for group_node in group_nodes:
            if group_node.name() == c.detail_views_group_alias or group_node.name() == c.lookup_tables_group_alias:
                dv_lu_nodes.append(group_node)
            else:
                # nothing to add
                pass

    return dv_lu_nodes


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
    group.insertChildNodes(0, mLNEDsorted)  # group instead of root
    for n in mLNED.values():
        group.removeChildNode(n)  # group instead of root
    # Germán Carrillo END #

    group.setExpanded(True)
    for child in group.children():
        if isinstance(child, QgsLayerTreeGroup):
            sort_ToC(child)
        else: 
            return None

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

    # Database group (e.g. delft @ localhost:5432)
    node_cdb = add_group_node_to_ToC(parent_node=root, child_name=dlg.DB.db_toc_node_label)
    # Database group (e.g. delft)
    # node_cdb = add_group_node_to_ToC(parent_node=root, child_name=dlg.DB.database_name)
    
    # Schema group (e.g. citydb)
    node_cdb_schema = add_group_node_to_ToC(parent_node=node_cdb, child_name="@".join([dlg.DB.username, layer.cdb_schema]))
    # FeatureType group (e.g. Building)
    node_featureType = add_group_node_to_ToC(parent_node=node_cdb_schema, child_name=f"FeatureType: {layer.feature_type}")
    # Feature group (e.g. Building Part)
    node_feature = add_group_node_to_ToC(parent_node=node_featureType, child_name=layer.root_class)
    # LoD group (e.g. lod2)
    node_lod = add_group_node_to_ToC(parent_node=node_feature, child_name=layer.lod)

    return node_lod # Node where the view has been added


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


def create_layer_relation_to_dv_address(dlg: CDB4LoaderDialog, layer: QgsVectorLayer, dv_gen_name: str) -> None:
    """Function to set up the relations for an input layer (e.g. a view).
    - New relation objects are created that reference the detail views of the address(es) tables.
    - Relations are also set for 'Value Relation' widget.

    *   :param layer: vector layer to set up the relationships for.
        :type layer: QgsVectorLayer
    """
    dv_gen_names: list = [k for k in dlg.DetailViewsRegistry.keys() if k.startswith("address_")]
    # print("dv_gen_names", dv_gen_names)

    if dv_gen_name not in dv_gen_names:
        # We're creating relations that may not be valid, so exit.
        return None

    # dv: CDBDetailView
    dv = [v for k,v in dlg.DetailViewsRegistry.items() if k == dv_gen_name][0]

    # Isolate the layers' ToC environment to avoid grabbing the first layer encountered in the WHOLE ToC.
    root = QgsProject.instance().layerTreeRoot()

    db_node = root.findGroup(dlg.DB.db_toc_node_label)
    # db_node = root.findGroup(dlg.DB.database_name)
    
    schema_node = db_node.findGroup("@".join([dlg.DB.username,dlg.CDB_SCHEMA]))
    detail_views_node = schema_node.findGroup(c.detail_views_group_alias)
    dv_layers: list = detail_views_node.findLayers()
    # print("dv_layers", dv_layers)
    # dv_layer: QgsLayerTreeLayer
    dv_layer = [elem for elem in cast(Iterable[QgsLayerTreeLayer], dv_layers) if elem.name().endswith(dv.gen_name)][0] # it should be only one!
    # print("dv_layer", dv_layer)

    # Create new Relation object
    rel = QgsRelation()
    rel.setReferencedLayer(id=layer.id())  # i.e. the (QGIS  internal) id of the CityObject layer
    rel.setReferencingLayer(id=dv_layer.layerId()) # i.e. the (QGIS  internal) id of the Address layer
    rel.addFieldPair(referencingField='cityobject_id', referencedField='id')
    rel.setName(name='re_' + layer.name() + "_" + dv_layer.name())    
    rel.setId(id="id_" + rel.name())

    # Till QGIS 3.26 the argument of setStrength is numeric, from QGIS 3.28 it is an enumeration
    if dlg.QGIS_VERSION_MAJOR == 3 and dlg.QGIS_VERSION_MINOR < 28:
        rel.setStrength(0) # integer, 0 is association, 1 composition
    else:
        # rel_strength = Qgis.RelationshipStrength(0) # integer, 0 is association, 1 composition
        rel_strength = Qgis.RelationshipStrength.Association # New way of defining it, as enumeration
        # print(rel_strength)
        rel.setStrength(rel_strength)

    # print("rel.is_valid", rel.isValid())
    if rel.isValid(): # Success
        QgsProject.instance().relationManager().addRelation(rel)
    else:
        msg: str = f"Invalid relation: {rel.name()}"
        QgsMessageLog.logMessage(message=msg, tag=dlg.PLUGIN_NAME, level=Qgis.MessageLevel.Critical, notifyUser=True)

    # ###############################################
    # Now start working on the form attached to the layer
    if dlg.settings.enable_ui_based_forms is False:

        # Get the layer configuration
        layer_configuration = layer.editFormConfig()
        # print('layer_configuration', layer_configuration)

        # Get the root container of all objects contained in the form (widgets, etc.)
        layer_root_container = layer_configuration.invisibleRootContainer()
        # print('layer_root_container', layer_root_container)

        # Find the element containing the "Generic Attributes" in the form.
        container_dv = get_attForm_child(container=layer_root_container, child_name=dv.form_tab_name)
        # Clean the element before inserting the relation
        container_dv.clear()

        # Create an 'attribute form' relation object from the 'relation' object
        relation_field = QgsAttributeEditorRelation(relation=rel, parent=container_dv)
        relation_field.setLabel(c.detail_views_group_alias)
        relation_field.setShowLabel(False) # No point setting a label then.
        # Add the relation to the 'Address(es)' container (tab).
        container_dv.addChildElement(relation_field)

        layer.setEditFormConfig(layer_configuration)
       
    return None


def create_layer_relation_to_dv_ext_ref(dlg: CDB4LoaderDialog, layer: QgsVectorLayer) -> None:
    """Function to set up the relations for an input layer (e.g. a view).
    - New relation objects are created that reference the detail views of the address(es) tables.
    - Relations are also set for 'Value Relation' widget.

    *   :param layer: vector layer to set up the relationships for.
        :type layer: QgsVectorLayer
    """
    detail_views: list = [v for k,v in dlg.DetailViewsRegistry.items() if k.startswith("ext_ref_")]

    # Isolate the layers' ToC environment to avoid grabbing the first layer encountered in the WHOLE ToC.
    root = QgsProject.instance().layerTreeRoot()

    db_node = root.findGroup(dlg.DB.db_toc_node_label)
    # db_node = root.findGroup(dlg.DB.database_name)

    schema_node = db_node.findGroup("@".join([dlg.DB.username,dlg.CDB_SCHEMA]))
    detail_views_node = schema_node.findGroup(c.detail_views_group_alias)
    dv_layers: list = detail_views_node.findLayers()

    # Get the layer configuration
    layer_configuration = layer.editFormConfig()
    # print('layer_configuration', layer_configuration)
    # Get the root container of all objects contained in the form (widgets, etc.)
    layer_root_container = layer_configuration.invisibleRootContainer()
    # print('layer_root_container', layer_root_container)

    dv: CDBDetailView
    for dv in detail_views:

        dv_layer: QgsLayerTreeLayer
        dv_layer = [elem for elem in dv_layers if elem.name().endswith(dv.gen_name)][0] # it should be only one!
        
        # Create new Relation object
        rel = QgsRelation()
        rel.setReferencedLayer(id=layer.id())  # i.e. the (QGIS  internal) id of the CityObject layer
        rel.setReferencingLayer(id=dv_layer.layerId()) # i.e. the (QGIS  internal) id of the Address layer
        rel.addFieldPair(referencingField='cityobject_id', referencedField='id')
        rel.setName(name='re_' + layer.name() + "_" + dv_layer.name())
        rel.setId(id="id_" + rel.name())

        # Till QGIS 3.26 the argument of setStrength is numeric, from QGIS 3.28 it is an enumeration
        if dlg.QGIS_VERSION_MAJOR == 3 and dlg.QGIS_VERSION_MINOR < 28:
            rel.setStrength(0) # integer, 0 is association, 1 composition
        else:
            rel_strength = Qgis.RelationshipStrength(0) # integer, 0 is association, 1 composition
            # print(rel_strength)
            rel.setStrength(rel_strength)

        # print("rel.is_valid", rel.isValid())
        if rel.isValid(): # Success
            QgsProject.instance().relationManager().addRelation(rel)
        else:
            msg: str = f"Invalid relation: {rel.name()}"
            QgsMessageLog.logMessage(message=msg, tag=dlg.PLUGIN_NAME, level=Qgis.MessageLevel.Critical, notifyUser=True)

        # Now set up the tab in the qml tab of the attribute form attached to the layer
        if dlg.settings.enable_ui_based_forms is False:

            # Find the element containing the "Gen Attrib (XXXX)" tab in the form.
            container_dv = get_attForm_child(container=layer_root_container, child_name=dv.form_tab_name)
            # Clean the element before inserting the relation
            container_dv.clear()

            # Create an 'attribute form' relation object from the 'relation' object
            relation_field = QgsAttributeEditorRelation(relation=rel, parent=container_dv)
            relation_field.setLabel(c.detail_views_group_alias)
            relation_field.setShowLabel(False) # No point setting a label then.
            # Add the relation to the 'Address(es)' container (tab).
            container_dv.addChildElement(relation_field)

    layer.setEditFormConfig(layer_configuration)


def create_layer_relation_to_dv_gen_attrib(dlg: CDB4LoaderDialog, layer: QgsVectorLayer) -> None:
    """Function to set up the relations for an input layer (e.g. a view).
    - New relation objects are created that reference the detail views of the address(es) tables.
    - Relations are also set for 'Value Relation' widget.

    *   :param layer: vector layer to set up the relationships for.
        :type layer: QgsVectorLayer
    """
    detail_views: list = [v for k,v in dlg.DetailViewsRegistry.items() if k.startswith("gen_attrib_")]

    # Isolate the layers' ToC environment to avoid grabbing the first layer encountered in the WHOLE ToC.
    root = QgsProject.instance().layerTreeRoot()

    db_node = root.findGroup(dlg.DB.db_toc_node_label)
    # db_node = root.findGroup(dlg.DB.database_name)
    
    schema_node = db_node.findGroup("@".join([dlg.DB.username,dlg.CDB_SCHEMA]))
    detail_views_node = schema_node.findGroup(c.detail_views_group_alias)
    dv_layers: list = detail_views_node.findLayers()

    # Get the layer configuration
    layer_configuration = layer.editFormConfig()
    # print('layer_configuration', layer_configuration)
    # Get the root container of all objects contained in the form (widgets, etc.)
    layer_root_container = layer_configuration.invisibleRootContainer()
    # print('layer_root_container', layer_root_container)

    dv: CDBDetailView
    # print("----------Registry")
    # for k, dv in dlg.DetailViewsRegistry.items():
    #     print(k, "--", dv.name, dv.curr_class, dv.gen_name, dv.form_tab_name)

    # print("----------Selection")
    # for dv in detail_views:
    #     print(dv.curr_class, dv.gen_name, dv.form_tab_name)

    for dv in detail_views:

        dv_layer: QgsLayerTreeLayer
        dv_layer = [elem for elem in dv_layers if elem.name().endswith(dv.gen_name)][0] # it should be only one!
        
        # Create new Relation object
        rel = QgsRelation()
        rel.setReferencedLayer(id=layer.id())  # i.e. the (QGIS  internal) id of the CityObject layer
        rel.setReferencingLayer(id=dv_layer.layerId()) # i.e. the (QGIS  internal) id of the Address layer
        rel.addFieldPair(referencingField='cityobject_id', referencedField='id')
        rel.setName(name='re_' + layer.name() + "_" + dv_layer.name())
        rel.setId(id="id_" + rel.name())

        # Till QGIS 3.26 the argument of setStrength is numeric, from QGIS 3.28 it is an enumeration
        if dlg.QGIS_VERSION_MAJOR == 3 and dlg.QGIS_VERSION_MINOR < 28:
            rel.setStrength(0) # integer, 0 is association, 1 composition
        else:
            rel_strength = Qgis.RelationshipStrength(0) # integer, 0 is association, 1 composition
            # print(rel_strength)
            rel.setStrength(rel_strength)

        # print("rel.is_valid", rel.isValid())
        if rel.isValid(): # Success
            QgsProject.instance().relationManager().addRelation(rel)
        else:
            msg: str = f"Invalid relation: {rel.name()}"
            QgsMessageLog.logMessage(message=msg, tag=dlg.PLUGIN_NAME, level=Qgis.MessageLevel.Critical, notifyUser=True)

        # Now set up the tab in the qml tab of the attribute form attached to the layer
        if dlg.settings.enable_ui_based_forms is False:

            # Find the element containing the "Gen Attrib (XXXX)" tab in the form.
            container_dv = get_attForm_child(container=layer_root_container, child_name=dv.form_tab_name)
            # Clean the element before inserting the relation
            container_dv.clear()

            # Create an 'attribute form' relation object from the 'relation' object
            relation_field = QgsAttributeEditorRelation(relation=rel, parent=container_dv)
            relation_field.setLabel(c.detail_views_group_alias)
            relation_field.setShowLabel(False) # No point setting a label then.
            # Add the relation to the 'Address(es)' container (tab).
            container_dv.addChildElement(relation_field)

    layer.setEditFormConfig(layer_configuration)
        
    return None


def qgsEditorWidgetSetup_factory(lu_config: Union[EnumConfig, CodeListConfig], layer_id: str) -> QgsEditorWidgetSetup:
    """Function to setup the configuration dictionary for the 'ValueRelation' widget.

        *   :returns: The object to set up the widget (ValueRelation)
        :rtype: QgsEditorWidgetSetup
    """
    config = {'AllowMulti': lu_config.allow_multi,
            'AllowNull': lu_config.allow_null,
            'FilterExpression': lu_config.filter_expression,
            'Layer': layer_id,
            'Key': lu_config.key_column,
            'Value': lu_config.value_column,
            'NofColumns': lu_config.num_columns,
            'OrderByValue': lu_config.order_by_value,
            'UseCompleter': lu_config.use_completer}
            
    return QgsEditorWidgetSetup(type='ValueRelation', config=config)


def create_layer_relation_to_enumerations(dlg: CDB4LoaderDialog, layer: QgsVectorLayer, layer_metadata: CDBLayer) -> None:
    """Function that sets up the ValueRelation widget for the look-up tables.

    *   :param layer: Layer to search for and set up its 'Value Relation' widget according to the look-up tables.
        :type layer: QgsVectorLayer
    """
    if not layer_metadata.enum_cols:
        return None # Exit, there are no enumerations to link to this layer

    # Isolate the layer's ToC environment to avoid grabbing the first layer encountered in the WHOLE ToC.
    root = QgsProject.instance().layerTreeRoot()

    db_node = root.findGroup(dlg.DB.db_toc_node_label)
    # db_node = root.findGroup(dlg.DB.database_name)

    schema_node = db_node.findGroup("@".join([dlg.DB.username, dlg.CDB_SCHEMA]))
    enums_node = schema_node.findGroup(c.lookup_tables_group_alias)
    enum_layers = enums_node.findLayers()
    enum_layer_id = [i.layerId() for i in enum_layers if c.enumerations_table in i.layerId()][0]

    # Create a dictionary with field names and field index
    fields_dict = {}
    for field in layer.fields():
        field_name = field.name()
        field_idx = layer.fields().indexOf(field_name)
        fields_dict[field_name] = field_idx
    # print(fields_dict)

    for enum_table, enum_col in layer_metadata.enum_cols:
        # This sets 'relative_to_terrain' and 'relative_to_water'
        if enum_table == "cityobject":
            lu_config: EnumConfig = dlg.EnumConfigRegistry[("CityObject", enum_table, enum_col)]
            field_idx = fields_dict[enum_col]            
            layer.setEditorWidgetSetup(field_idx, qgsEditorWidgetSetup_factory(lu_config, enum_layer_id))
        else:
            pass


def create_layer_relation_to_codelists(dlg: CDB4LoaderDialog, layer: QgsVectorLayer, layer_metadata: CDBLayer) -> None:
    """Function that sets up the ValueRelation widget for the look-up tables.

    *   :param layer: Layer to search for and set up its 'Value Relation' widget according to the look-up tables.
        :type layer: QgsVectorLayer
    """
    if not layer_metadata.codelist_cols:
        return None # Exit, there are no codelists to link to this layer

    # Isolate the layer's ToC environment to avoid grabbing the first layer encountered in the WHOLE ToC.
    root = QgsProject.instance().layerTreeRoot()

    db_node = root.findGroup(dlg.DB.db_toc_node_label)
    # db_node = root.findGroup(dlg.DB.database_name)
    
    schema_node = db_node.findGroup("@".join([dlg.DB.username, dlg.CDB_SCHEMA]))
    cls_node = schema_node.findGroup(c.lookup_tables_group_alias)
    cl_layers = cls_node.findLayers()
    cl_layer_id = [i.layerId() for i in cl_layers if c.codelists_table in i.layerId()][0]

    # Create a dictionary with field names and field index
    fields_dict = {}
    for field in layer.fields():
        field_name = field.name()
        field_idx = layer.fields().indexOf(field_name)
        fields_dict[field_name] = field_idx
    # print(fields_dict)

    for cl_table, cl_col in layer_metadata.codelist_cols:
        cl_class = layer_metadata.curr_class
        lu_config: CodeListConfig = dlg.CodeListConfigRegistry.get((cl_class, cl_table, cl_col), None)

        if not lu_config:
            # print("No codelist found for this key:", (cl_class, cl_table, cl_col))
            pass
        else:
            field_idx = fields_dict[cl_col]            
            layer.setEditorWidgetSetup(field_idx, qgsEditorWidgetSetup_factory(lu_config, cl_layer_id))

    return None


def add_lookup_tables_to_ToC(dlg: CDB4LoaderDialog) -> None:
    """Function to import the look-up tables into the qgis project.
    """
    # Just to shorten the variables names.
    db = dlg.DB
    cdb_schema: str = dlg.CDB_SCHEMA
    usr_schema: str = dlg.USR_SCHEMA

    # Add look-up tables into their own group in ToC.
    node_cdb_schema = QgsProject.instance().layerTreeRoot().findGroup("@".join([db.username, cdb_schema]))

    lookups_node = add_group_node_to_ToC(parent_node=node_cdb_schema, child_name=c.lookup_tables_group_alias)

    # Get look-up tables names from the server.
    lookup_tables = sql.list_lookup_tables(dlg=dlg)

    for lookup_table in lookup_tables:
        # Create ONLY new layers.
        if not is_layer_already_in_ToC_group(group=lookups_node, layer_name=f"{dlg.CDB_SCHEMA}_{lookup_table}"):
            uri = QgsDataSourceUri()
            uri.setConnection(aHost=db.host, aPort=db.port, aDatabase=db.database_name, aUsername=db.username, aPassword=db.password)
            uri.setDataSource(aSchema=usr_schema, aTable=lookup_table, aGeometryColumn=None, aKeyColumn="id")
            layer = QgsVectorLayer(path=uri.uri(False), baseName=f"{cdb_schema}_{lookup_table}", providerLib="postgres")
            if layer or layer.isValid(): # Success
                lookups_node.addLayer(layer)
                QgsProject.instance().addMapLayer(layer, False)
                # msg: str = f"Look-up table import: {cdb_schema}_{lookup_table}"
                # QgsMessageLog.logMessage(message=msg, tag=dlg.PLUGIN_NAME, level=Qgis.MessageLevel.Critical, notifyUser=True)
            else: # Fail
                msg: str = f"Look-up table failed to properly load: {cdb_schema}_{lookup_table}"
                QgsMessageLog.logMessage(message=msg, tag=dlg.PLUGIN_NAME, level=Qgis.MessageLevel.Critical, notifyUser=True)

    # After loading all look-ups, sort them by name.
    sort_ToC(lookups_node)

    return None


def add_detail_view_tables_to_ToC(dlg: CDB4LoaderDialog) -> None:
    """Function to import the 'detail view' tables into the qgis project.
    """
    # Just to shorten the variables names.
    db = dlg.DB
    cdb_schema = dlg.CDB_SCHEMA
    usr_schema = dlg.USR_SCHEMA
    extents = dlg.QGIS_EXTENTS.asWktPolygon()
    crs = dlg.CRS

    # Add generics tables into their own group in ToC.
    root = QgsProject.instance().layerTreeRoot().findGroup("@".join([db.username, cdb_schema]))
    detail_view_node = add_group_node_to_ToC(parent_node=root, child_name=c.detail_views_group_alias)

    dv: CDBDetailView
    for dv in dlg.DetailViewsRegistry.values():

        # Check that the detail view is not already loaded
        if not is_layer_already_in_ToC_group(detail_view_node, dv.name):

            uri = QgsDataSourceUri()
            uri.setConnection(aHost=db.host, aPort=db.port, aDatabase=db.database_name, aUsername=db.username, aPassword=db.password)

            if dv.has_geom:
                if dlg.QGIS_EXTENTS == dlg.LAYER_EXTENTS:
                    # No need to add the spatial filter
                    uri.setDataSource(aSchema=usr_schema, aTable=dv.name, aGeometryColumn="geom", aKeyColumn="id")
                else:
                    uri.setDataSource(aSchema=usr_schema, aTable=dv.name, aGeometryColumn="geom", aSql=f"ST_GeomFromText('{extents}') && geom", aKeyColumn="id")
                # Create a spatial detail view as QgsVectorLayer
                dv_layer = QgsVectorLayer(path=uri.uri(False), baseName=dv.name, providerLib="postgres")
                dv_layer.setCrs(crs)
            else:
                uri.setDataSource(aSchema=usr_schema, aTable=dv.name, aGeometryColumn=None, aKeyColumn="id")
                # Create a non-spatial detail view as QgsVectorLayer (but without geometry)
                dv_layer = QgsVectorLayer(path=uri.uri(False), baseName=dv.name, providerLib="postgres")

            if dv_layer or dv_layer.isValid(): # Success
                # Add the qml-based forms
                if dv.qml_form:
                    #print(dv.qml_form_with_path)
                    dv_layer.loadNamedStyle(theURI=dv.qml_form_with_path, loadFromLocalDb=False, categories=QgsMapLayer.StyleCategory.Fields|QgsMapLayer.StyleCategory.Forms)
                    #dv_layer.loadNamedStyle(theURI=dv.qml_form_with_path, categories=QgsMapLayer.Fields|QgsMapLayer.Forms)
                    #print('qui si blocca')
                    # otherwise: categories=QgsMapLayer.AllStyleCategories

                # Get the index of the field "cityobject"
                # This is needed to avoid a warning in the Log telling us that the cityobject field
                # is missing the relation in its configuration
                co_idx: int = dv_layer.fields().indexOf("cityobject_id")
                # print(f"co_id of {detail_view_name} id {co_idx}")
                dv_layer.setEditorWidgetSetup(index=co_idx, setup=QgsEditorWidgetSetup('TextEdit',{}))

                # Set the layer as read-only if the current cdb_schema is read only
                if dlg.CDBSchemaPrivileges == "ro":
                    dv_layer.setReadOnly()

                # Add to layer tree node
                detail_view_node.addLayer(dv_layer)
                QgsProject.instance().addMapLayer(dv_layer, False)

            else:
                msg: str = f"Detail view '{dv.name}' is not valid"
                QgsMessageLog.logMessage(message=msg, tag=dlg.PLUGIN_NAME, level=Qgis.MessageLevel.Critical, notifyUser=True)

    return None


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
    uri.setConnection(aHost=db.host, aPort=db.port, aDatabase=db.database_name, aUsername=db.username, aPassword=db.password)

    if dlg.QGIS_EXTENTS == dlg.LAYER_EXTENTS:  
        # No need to apply a spatial filter in QGIS
        uri.setDataSource(aSchema=usr_schema, aTable=layer_name, aGeometryColumn="geom", aKeyColumn="id")
    else:
        uri.setDataSource(aSchema=usr_schema, aTable=layer_name, aGeometryColumn="geom", aSql=f"ST_GeomFromText('{extents}') && geom", aKeyColumn="id")

    new_layer = QgsVectorLayer(uri.uri(False), layer_name, "postgres")
    new_layer.setCrs(crs)

    return new_layer
    

def add_selected_layers_to_ToC(dlg: CDB4LoaderDialog, layers: list[CDBLayer]) -> int:
    """Function to imports the selected layer(s) in the user's qgis project.

    *   :param layers: A list containing View object that correspond to the server views.
        :type layers: list(CDBLayer)

    *   :returns: The number of actually imported layers (excluding those already loaded)
        :rtype: int

    """
    import_counter: int = 0
    if not layers:
        # nothing to do
        return import_counter # Exit with zero imported layers.

    # Just to shorten the variables names.
    db = dlg.DB
    cdb_schema: str = dlg.CDB_SCHEMA

    root = QgsProject.instance().layerTreeRoot()
    node_cdb: QgsLayerTreeGroup = root.findGroup(db.db_toc_node_label)
    node_cdb_schema: QgsLayerTreeGroup = None
    node_featureType: QgsLayerTreeGroup = None
    node_feature: QgsLayerTreeGroup = None
    node_lod: QgsLayerTreeGroup = None

    lookup_found: bool = False
    detail_views_found: bool = False
    layer_found: bool = False

    if node_cdb:
        node_cdb_schema = root.findGroup("@".join([db.username, cdb_schema]))
        if node_cdb_schema:
            # Check whether the generic attribute table is already loaded
            node_dv = node_cdb_schema.findGroup(c.detail_views_group_alias)
            if node_dv:
                dv_layers: list = node_dv.findLayers()
                if len(dv_layers) == len(dlg.DetailViewsRegistry):
                    detail_views_found = True

            # Check whether the look-up table for enumerations is already loaded
            node_lookup = node_cdb_schema.findGroup(c.lookup_tables_group_alias)
            if node_lookup:
                lu_layers: list = node_lookup.findLayers()
                for lu_layer in lu_layers:  
                    if lu_layer.name() == "_".join([cdb_schema, c.enumerations_table]):
                        lookup_found = True
        else:
            node_cdb_schema = add_group_node_to_ToC(node_cdb, "@".join([db.username, cdb_schema]))
    else:
        node_cdb = add_group_node_to_ToC(root, db.db_toc_node_label)
        node_cdb_schema = add_group_node_to_ToC(node_cdb, "@".join([db.username, cdb_schema]))

    # Load the generic attributes table if it is not already loaded 
    if not detail_views_found:
        node_dv = add_group_node_to_ToC(node_cdb_schema, c.detail_views_group_alias)
        add_detail_view_tables_to_ToC(dlg)
    else:
        # msg: str = "Generic attributes table already loaded: skipping"
        # QgsMessageLog.logMessage(message=msg, tag=dlg.PLUGIN_NAME, level=Qgis.MessageLevel.Info, notifyUser=True)
        pass

    # Load the look-up tables if they are not already loaded 
    if not lookup_found:
        node_lookup = add_group_node_to_ToC(node_cdb_schema, c.lookup_tables_group_alias) 
        add_lookup_tables_to_ToC(dlg)
    else:
        # msg: str = "Look-up tables already loaded: skipping"
        # QgsMessageLog.logMessage(message=msg, tag=dlg.PLUGIN_NAME, level=Qgis.MessageLevel.Info, notifyUser=True)
        pass

    # Start loading the selected layer(s)
    for layer in layers:
        # Check if the layer has already been loaded before
        layer_found = False
        node_featureType = node_cdb_schema.findGroup(f"FeatureType: {layer.feature_type}")
        if node_featureType:
            node_feature = node_featureType.findGroup(layer.root_class)
            if node_feature:
                node_lod = node_feature.findGroup(layer.lod)
                if node_lod:
                    existing_layers = node_lod.findLayers()
                    for existing_layer in existing_layers:
                        if existing_layer.name() == layer.layer_name:
                            layer_found = True

        if layer_found:
            msg: str = f"Layer {layer.layer_name} already in Layer Tree: skip reloading"
            QgsMessageLog.logMessage(message=msg, tag=dlg.PLUGIN_NAME, level=Qgis.MessageLevel.Info, notifyUser=True)
            # Memory refresher: The "continue" statement rejects all the remaining statements
            # in the current iteration of the loop and moves the control back to the top of the loop
            continue

        # Build the Table of Contents Tree or Restructure it.
        node_lod = add_layer_node_to_ToC(dlg, layer)

        new_layer: QgsVectorLayer = create_qgis_vector_layer(dlg, layer_name=layer.layer_name)

        if new_layer or new_layer.isValid(): # Success
            pass
        else: # Fail
            msg: str = f"Failed to properly load: {layer.layer_name}"
            QgsMessageLog.logMessage(message=msg, tag=dlg.PLUGIN_NAME, level=Qgis.MessageLevel.Critical, notifyUser=True)
            return False

        # Set the layer as read-only if the current cdb_schema is read only
        if dlg.CDBSchemaPrivileges == "ro":
            new_layer.setReadOnly()

        ###########################################################################################
        # To use "normal" (old) forms, simply set the value to FALSE in the dlg.settings.
        # See the default in class LoaderDefaultSettings (see other_classes.py)
        ###########################################################################################
        if dlg.settings.enable_ui_based_forms is False:
            # Attach 'attribute form' from QML file.
            if layer.qml_form:
                new_layer.loadNamedStyle(theURI=layer.qml_form_with_path, loadFromLocalDb=False, categories=QgsMapLayer.StyleCategory.Fields|QgsMapLayer.StyleCategory.Forms)
                # otherwise: categories=QgsMapLayer.AllStyleCategories

            # Attach 'symbology' from QML file.
            if layer.qml_symb:
                new_layer.loadNamedStyle(layer.qml_symb_with_path, loadFromLocalDb=False, categories=QgsMapLayer.StyleCategory.Symbology)

            if dlg.cbxEnable3D.isChecked():
                # Attach '3d symbology' from QML file.
                if layer.qml_3d:
                    new_layer.loadNamedStyle(layer.qml_3d_with_path, loadFromLocalDb=False, categories=QgsMapLayer.StyleCategory.Symbology3D)
            else:
                # Deactivate 3D renderer to avoid crashes and slow downs.
                new_layer.setRenderer3D(None)

            # Insert the layer to the assigned group
            node_lod.addLayer(new_layer)
            QgsProject.instance().addMapLayer(new_layer, False)

            # Filter out those layers that are not cityobjects and for which there is no need for the Generic Attributes link
            if layer.curr_class != "Address":  # might change to: not in ["Address", "...", "..."]

                if layer.curr_class in ["Building", "BuildingPart"]:
                    create_layer_relation_to_dv_address(dlg, layer=new_layer, dv_gen_name="address_bdg")
                elif layer.curr_class == "BuildingDoor":
                    create_layer_relation_to_dv_address(dlg, layer=new_layer, dv_gen_name="address_bdg_door")
                if layer.curr_class in ["Bridge", "BridgePart"]:
                    create_layer_relation_to_dv_address(dlg, layer=new_layer, dv_gen_name="address_bri")
                elif layer.curr_class == "BridgeDoor":
                    create_layer_relation_to_dv_address(dlg, layer=new_layer, dv_gen_name="address_bri_door")
        
                # Now, for all layers that are CityObjects
                create_layer_relation_to_dv_gen_attrib(dlg, layer=new_layer)
                create_layer_relation_to_dv_ext_ref(dlg, layer=new_layer)

                # Setup the relations for this layer to the look-up tables
                create_layer_relation_to_enumerations(dlg, layer=new_layer, layer_metadata=layer)
                create_layer_relation_to_codelists(dlg, layer=new_layer, layer_metadata=layer)
            
            # Finally, increment the counter after loading the layer and all the associated stuff
            import_counter += 1

        else:
            # This is where we may decide to deal with ui-based attribute forms
            pass

    # Return the number of layers that have been really loaded.
    # print(f"Imported {import_counter} layers into QGIS")
    return import_counter 

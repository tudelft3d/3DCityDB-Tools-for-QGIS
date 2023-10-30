"""This module contains functions that relate to the 'Connection Tab'
"""
from __future__ import annotations
from typing import TYPE_CHECKING
if TYPE_CHECKING:       
    from ...gui_loader.loader_dialog import CDB4LoaderDialog

from ...shared.functions import general_functions as gen_f
from ..other_classes import FeatureType, CDBDetailView, EnumConfig
from .. import loader_constants as c
from . import tab_layers_widget_functions as tl_wf
from . import tab_settings_widget_functions as ts_wf
from . import sql


def fill_cdb_schemas_box(dlg: CDB4LoaderDialog, cdb_schemas: tuple = None) -> None:
    """Function that fills the 'Citydb schema(s)' combo box.
    """
    # Clean combo box from previous leftovers.
    dlg.cbxSchema.clear()

    if not cdb_schemas:
        # Disable the combobox
        dlg.cbxSchema.setDisabled(True)
        dlg.lblSchema.setDisabled(True)
    else:
        for cdb_schema in cdb_schemas:
            label: str = f"{cdb_schema.cdb_schema} ({cdb_schema.priv_type})"
            dlg.cbxSchema.addItem(label, userData=cdb_schema)
        if not dlg.cbxSchema.isEnabled():
            # Enable the combobox
            dlg.cbxSchema.setDisabled(False)
            dlg.lblSchema.setDisabled(False)
   
    # REMEMBER: don't use method 'setSeparator', it adds a custom separator to join string of selected items
    return None


def fill_cdb_schemas_box_feat_count(dlg: CDB4LoaderDialog, cdb_schemas: tuple = None) -> None:
    """Function that fills the 'Citydb schema(s)' combo box.
    """
    # Clean combo box from previous leftovers.
    dlg.cbxSchema.clear()

    if not cdb_schemas:
        # Disable the combobox
        dlg.cbxSchema.setDisabled(True)
        dlg.lblSchema.setDisabled(True)
    else:
        for cdb_schema in cdb_schemas:
            label: str = f"{cdb_schema.cdb_schema} ({cdb_schema.priv_type}): {cdb_schema.co_number} CityObjects"
            dlg.cbxSchema.addItem(label, userData=cdb_schema)
        if not dlg.cbxSchema.isEnabled():
            # Enable the combobox
            dlg.cbxSchema.setDisabled(False)
            dlg.lblSchema.setDisabled(False)
   
    # REMEMBER: don't use method 'setSeparator', it adds a custom separator to join string of selected items
    return None


def fill_feature_types_box(dlg: CDB4LoaderDialog) -> None:
    """Function that fills feature types checkable combo box
    """
    # Clear combo box from previous entries
    dlg.cbxFeatType.clear()
    dlg.cbxFeatType.setDefaultText('Select feature type(s)')

    feat_types = []
    # Currently, we do not support CityObjectGroup Features, so we must filter them out
    feat_types: list = [ft for ft in dlg.FeatureTypesRegistry.values() if ft.exists and ft.name != "CityObjectGroup"]
    # Eventually, THIS will be the correct line of code.
    # feat_types: list = [ft for ft in dlg.FeatureTypesRegistry.values() if ft.exists]

    if len(feat_types) == 0: 
        dlg.cbxFeatType.setDefaultText('None available')
        # Disable the combobox
        dlg.cbxFeatType.setDisabled(True) 
    else:
        ft: FeatureType            
        for ft in feat_types:
            label:str = ft.name
            dlg.cbxFeatType.addItemWithCheckState(
                # text=f'{layer.layer_name} ({layer.n_selected})',
                text=label, # must be a string!!
                state=0,
                userData=label) # this is the value retrieved later for picking the selected ones
            dlg.cbxFeatType.model().sort(0)
        if not dlg.cbxFeatType.isEnabled():
            dlg.cbxFeatType.setDisabled(False)
    
    return None


def initialize_feature_type_registry(dlg: CDB4LoaderDialog) -> None:
    """Function to create the dictionary containing Feature Type metadata.
    """
    dlg.FeatureTypesRegistry: dict = {}
        
    dlg.FeatureTypesRegistry: dict = {
        "Bridge"          : FeatureType(name="Bridge"         , alias='bridge'         ),
        "Building"        : FeatureType(name="Building"       , alias='building'       ),
        "CityFurniture"   : FeatureType(name="CityFurniture"  , alias='cityfurniture'  ),
        "CityObjectGroup" : FeatureType(name="CityObjectGroup", alias='cityobjectgroup'),
        "Generics"        : FeatureType(name="Generics"       , alias='generics'       ),
        "LandUse"         : FeatureType(name="LandUse"        , alias='landuse'        ),
        "Relief"          : FeatureType(name="Relief"         , alias='relief'         ),
        "Transportation"  : FeatureType(name="Transportation" , alias='transportation' ),
        "Tunnel"          : FeatureType(name="Tunnel"         , alias='tunnel'         ),
        "Vegetation"      : FeatureType(name="Vegetation"     , alias='vegetation'     ),
        "WaterBody"       : FeatureType(name="WaterBody"      , alias='waterbody'      )
        }

    return None


def update_feature_type_registry_exists(dlg: CDB4LoaderDialog) -> None:
    """Function to update the dictionary containing Feature Type metadata for the current cdb_schema.
    """
    # Get the list (tuple) of available Feature Types in the current cdb_schema
    feat_types: tuple = sql.fetch_feature_types_checker(dlg)

    ft: FeatureType
    # Reset the status from potential previous checks
    for ft in dlg.FeatureTypesRegistry.values():
        ft.exists = False

    # Set to true only for those Feature Types that exist
    for feat_type in feat_types:
        ft = dlg.FeatureTypesRegistry[feat_type]
        ft.exists = True

    return None


def update_feature_type_registry_is_selected(dlg: CDB4LoaderDialog) -> None:
    """Function to update the dictionary containing Feature Type metadata for the current cdb_schema.
    """
    # Get the list (tuple) of available Feature Types in the current cdb_schema
    feat_types: list = gen_f.get_checkedItemsData(dlg.cbxFeatType)

    ft: FeatureType
    # Reset the status from potential previous selections
    for ft in dlg.FeatureTypesRegistry.values():
        ft.is_selected = False

    # Set to true only for those Feature Types that are selected
    for feat_type in feat_types:
       ft = dlg.FeatureTypesRegistry[feat_type]
       ft.is_selected = True

    return None


def populate_detail_views_registry(dlg: CDB4LoaderDialog) -> None:
    """Function to create the dictionary containing Detail Views metadata.
    """
    # This is a list of named tuples, extracted from the db sorting by gen_name
    detail_views_metadata: list = sql.fetch_detail_view_metadata(dlg)
    # print(detail_views_metadata)

    detail_views_keys = [elem.gen_name for elem in detail_views_metadata]
    # Sort by gen_name
    detail_views_keys.sort()

    detail_views_values = [CDBDetailView(*elem) for elem in detail_views_metadata]
    # Sort by gen_name as well
    detail_views_values.sort(key=lambda x: x.gen_name)

    dlg.DetailViewsRegistry: dict = {}
    dlg.DetailViewsRegistry = dict(zip(detail_views_keys, detail_views_values))
    
    # print('Initializing:<br>', dlg.DetailViewsRegistry)
    # print('Initializing:<br>', dlg.DetailViewsRegistry["address_bdg"].__dict__)
    # print('Initializing:<br>', dlg.DetailViewsRegistry["gen_attrib_integer"].__dict__)

    return None


def populate_enum_config_registry(dlg: CDB4LoaderDialog) -> None:
    """Function to create the dictionary containing Enumeration Lookup Config metadata.
    """
    # This is a list of named tuples, extracted from the db sorting by gen_name
    config_metadata: list = sql.fetch_enum_lookup_config(dlg)
    # print(config_metadata)

    config_metadata_keys = [(elem.source_class, elem.source_table, elem.source_column) for elem in config_metadata]
    # Sort
    config_metadata_keys.sort(key=lambda x: (x[0], x[1], x[2]), reverse=False)
    # print(config_metadata_keys)

    config_metadata_values = [EnumConfig(*elem) for elem in config_metadata]
    # Sort
    config_metadata_values.sort(key=lambda x: (x.source_class, x.source_table, x.source_column))

    dlg.EnumConfigRegistry: dict = {}
    dlg.EnumConfigRegistry = dict(zip(config_metadata_keys, config_metadata_values))

    # print('Initializing:<br>', dlg.EnumLookupConfigRegistry)
    # print('Initializing:<br>', dlg.EnumLookupConfigRegistry[(None, "CityObject", "relative_to_water")].__dict__)
    # print('Initializing:<br>', dlg.EnumLookupConfig["gen_attrib_integer"].__dict__)

    return None


def check_layers_status(dlg: CDB4LoaderDialog) -> bool:
    """ Function that takes care of:
        1) checking whether layers were created, i.e. they exist or not
        2) Depending on this, checking whether they were refreshed
        3) Setting up the Connection Tab GUI elements accordingly
        4) Setting up the Layer Tab GUI elements accordingly

    Returns a boolean telling whether layers exist or not
    """
    # Check if user package has already some layers corresponding to the current schema.
    has_layers_in_current_schema: bool = sql.exec_has_layers_for_cdb_schema(dlg)

    if not has_layers_in_current_schema: # There are no layers
        # Set the labels in the connection tab: There are no layers
        dlg.lblLayerExist_out.setText(c.failure_html.format(text=c.SCHEMA_LAYER_FAIL_MSG.format(sch=dlg.CDB_SCHEMA)))
        dlg.checks.layers_exist = False
        # There are no layers to refresh at all
        dlg.lblLayerRefr_out.clear()
        dlg.checks.layers_refreshed = False

        # Enable the BaseMap groupbox, so the user can select the extents
        dlg.gbxBasemap.setDisabled(False)
        dlg.qgbxExtents.setDisabled(False)
        dlg.btnCityExtents.setDisabled(False)
        dlg.btnGeoCoder.setDisabled(False)
        dlg.btnRefreshCDBExtents.setDisabled(False)

        # Enable the Feature (Type) Selection groupbox
        dlg.gbxFeatSel.setDisabled(False)
        # Enable the Create Layers button
        dlg.btnCreateLayers.setDisabled(False)
        # Disable Refresh layers button
        dlg.btnRefreshLayers.setDisabled(True)
        # Disable the Drop Layers button (there is nothing to drop)
        dlg.btnDropLayers.setDisabled(True)
    
    else:   # There are already layers from before

        # Set the labels in the connection tab: There are layers
        dlg.lblLayerExist_out.setText(c.success_html.format(text=c.SCHEMA_LAYER_MSG.format(sch=dlg.CDB_SCHEMA)))
        dlg.checks.layers_exist = True

        # Now check whether layers were already refreshed/populated
        refresh_date = sql.fetch_layer_metadata(dlg, cols_list=["refresh_date"])
        # Extract a date.
        date = list(set(refresh_date[1]))[0][0]

        if not date:  # The layers do already exist but were NOT (yet) refreshed/populated
            # Set the labels in the connection tab
            dlg.lblLayerRefr_out.setText(c.failure_html.format(text=c.REFR_LAYERS_FAIL_MSG))
            dlg.checks.layers_refreshed = False

        else: # The layers do already exist, AND have already been refreshed/populated
            dlg.lblLayerRefr_out.setText(c.success_html.format(text=c.REFR_LAYERS_MSG.format(date=date)))
            dlg.checks.layers_refreshed = True


        # In both cases that the layers already exist:
        # Disable everything but the Refresh button and the MapCanvas 
        dlg.gbxBasemap.setDisabled(False)
        dlg.qgbxExtents.setDisabled(True)
        dlg.btnCityExtents.setDisabled(True)
        dlg.btnGeoCoder.setDisabled(True)
        # But keep the RefreshExtents button enabled, in case it is needed!
        dlg.btnRefreshCDBExtents.setDisabled(False)

        # Disable the Feature Selection and Layer Create button
        dlg.gbxFeatSel.setDisabled(True)
        dlg.btnCreateLayers.setDisabled(True)
        # Activate the Layer Refresh button
        dlg.btnRefreshLayers.setDisabled(False)
        # Enable the Drop Layers button
        dlg.btnDropLayers.setDisabled(False)

    # Check that DB is configured correctly. If so, enable all following buttons etc.
    if dlg.checks.are_requirements_fulfilled():

        # Initialize the detail view registry
        populate_detail_views_registry(dlg)
        # Initialize the enum_lookup_config_registry
        populate_enum_config_registry(dlg)

        # We are done here with the 'User Connection' tab, we can now activate the Layer Tab
        # Set up the Layers Tab
        dlg.lblInfoText.setText(dlg.lblInfoText.init_text.format(db=dlg.DB.database_name, usr=dlg.DB.username, sch=dlg.CDB_SCHEMA))
        dlg.lblInfoText.setDisabled(False)
        tl_wf.gbxBasemapL_setup(dlg)
        dlg.gbxBasemapL.setDisabled(False)
        dlg.qgbxExtentsL.setDisabled(False)
        dlg.btnLayerExtentsL.setDisabled(False)
        dlg.tabLayers.setDisabled(False)
        dlg.btnImport.setDisabled(True)

        # Fill the combo box with the codelist selection
        CityGML_codelist_set_names: list = sql.fetch_CityGML_codelist_set_names(dlg)
        # print("Initializing combo box with:", codelist_set_names)
        if CityGML_codelist_set_names:
            tl_wf.fill_CityGML_codelist_selection_box(dlg, CityGML_codelist_set_names)

        # TO DO
        #
        # Add similar step to retrieve ADE codelist set
        #
        # if dlg.ADE_PREFIX:
        #     ADE_codelist_set_names: list = sql.fetch_ADE_codelist_set_names(dlg)
        #     # print("Initializing combo box with:", codelist_set_names)
        #     if ADE_codelist_set_names:
        #         tl_wf.fill_ADE_codelist_selection_box(dlg, ADE_codelist_set_names)            

    else:
        tl_wf.tabLayers_reset(dlg) # it disables itself, too

    return has_layers_in_current_schema
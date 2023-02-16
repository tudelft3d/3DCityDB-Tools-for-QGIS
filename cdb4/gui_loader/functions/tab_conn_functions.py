"""This module contains functions that relate to the 'Connection Tab'
"""
from __future__ import annotations
from typing import TYPE_CHECKING
if TYPE_CHECKING:       
    from ...gui_loader.loader_dialog import CDB4LoaderDialog

from ....cdb_tools_main import CDBToolsMain # Used only to add the type of the function parameters
from ...shared.functions import general_functions as gen_f
from ..other_classes import FeatureType
from .. import loader_constants as c
from . import tab_layers_widget_functions as tl_wf
from . import sql

def fill_cdb_schemas_box(dlg: CDB4LoaderDialog, cdb_schemas: tuple = None) -> None:
    """Function that fills the 'Citydb schema(s)' checkable combo box.
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
        refresh_date = sql.fetch_layer_metadata(dlg, usr_schema=dlg.USR_SCHEMA, cdb_schema=dlg.CDB_SCHEMA, cols_list=["refresh_date"])
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
        # Also enables the settings tab
        dlg.tabSettings.setDisabled(False)

    else:
        tl_wf.tabLayers_reset(dlg) # it disables itself, too

    return has_layers_in_current_schema
"""This module contains functions that relate to the 'Connection Tab'
(in the GUI look for the elephant).

These functions are usually called from widget_setup functions
relating to child widgets of the 'Connection Tab'.
"""
from __future__ import annotations
from typing import TYPE_CHECKING  #, Union
if TYPE_CHECKING:       
    from ...gui_deleter.deleter_dialog import CDB4DeleterDialog

from qgis.core import Qgis, QgsMessageLog, QgsRectangle, QgsWkbTypes
from qgis.gui import QgsRubberBand
from qgis.PyQt.QtCore import Qt
from qgis.PyQt.QtWidgets import QMessageBox

from ..other_classes import TopClassFeature, FeatureType
from .. import deleter_constants as c
from . import tab_conn_widget_functions as tc_wf
from . import tab_settings_widget_functions as ts_wf
from . import canvas, sql

def fill_cdb_schemas_box(dlg: CDB4DeleterDialog, cdb_schemas: tuple = None) -> None:
    """Function that fills the 'Citydb schema(s)' checkable combo box.
    """
    # Clean combo box from previous leftovers.
    dlg.cbxSchema.clear()
    #dlg.cbxSchema.setDefaultText('Select citydb schema')

    if not cdb_schemas:
        # dlg.cbxSchema.setDefaultText('None available')
        # Disable the combobox
        dlg.cbxSchema.setDisabled(True)
        dlg.lblSchema.setDisabled(True)
    else:
        for cdb_schema in cdb_schemas:
            # label: str = f"{cdb_schema.cdb_schema} ({cdb_schema.priv_type})"
            label: str = f"{cdb_schema.cdb_schema}"
            # dlg.cbxSchema.addItem(cdb_schema, True)
            dlg.cbxSchema.addItem(label, userData=cdb_schema.cdb_schema)
        if not dlg.cbxSchema.isEnabled():
            # Enable the combobox
            dlg.cbxSchema.setDisabled(False)
            dlg.lblSchema.setDisabled(False)
   
    # REMEMBER: don't use method 'setSeparator', it adds a custom separator to join string of selected items
    return None


def fill_top_class_features_box(dlg: CDB4DeleterDialog) -> None:
    """Function that fills the top class features checkable combo box

    """
    # Clear combo box from previous entries
    dlg.ccbxTopClass.clear()
    dlg.ccbxTopClass.setDefaultText('Select top-class feature(s)')

    top_class_features: list = [rcf for rcf in dlg.TopClassFeaturesRegistry.values() if rcf.exists]

    if len(top_class_features) == 0: 
        dlg.ccbxTopClass.setDefaultText('None available')
        # Disable the combobox
        dlg.ccbxTopClass.setDisabled(True)
    else:
        rcf: TopClassFeature
        for rcf in top_class_features:
            label = f"{rcf.name} ({rcf.n_features})" 
            dlg.ccbxTopClass.addItemWithCheckState(
                text=label,
                state=0,
                userData=rcf) # this is the value retrieved later
        # Reorder items alphabetically
        dlg.ccbxTopClass.model().sort(0)
    return None


def fill_feature_types_box(dlg: CDB4DeleterDialog) -> None:
    """Function that fills feature types checkable combo box
    """
    # Clear combo box from previous entries
    dlg.ccbxFeatType.clear()
    dlg.ccbxFeatType.setDefaultText('Select feature type(s)')

    feat_types: list = [ft for ft in dlg.FeatureTypesRegistry.values() if ft.exists]

    if len(feat_types) == 0: 
        dlg.ccbxFeatType.setDefaultText('None available')
        # Disable the combobox
        dlg.ccbxFeatType.setDisabled(True) 
    else:
        ft: FeatureType
        for ft in feat_types:
            label = f"{ft.name} ({ft.n_features})" 
            dlg.ccbxFeatType.addItemWithCheckState(
                text=label,
                state=0,
                userData=ft) # this is the value retrieved later
        # Reorder items alphabetically
        dlg.ccbxFeatType.model().sort(0)
    return None


def initialise_top_class_features_registry(dlg: CDB4DeleterDialog) -> None:
    """Function to create the dictionary containing Feature Type metadata.
    """
    # Clean up from possible previous runs
    dlg.TopClassFeaturesRegistry: dict = {}
    
    dlg.TopClassFeaturesRegistry = {
        "Bridge"                   : TopClassFeature(name="Bridge"                  , objectclass_id = 64, feature_type = "Bridge"          , del_function= "del_bridge"),
        "Building"                 : TopClassFeature(name="Building"                , objectclass_id = 26, feature_type = "Building"        , del_function= "del_building"),
        "CityFurniture"            : TopClassFeature(name="CityFurniture"           , objectclass_id = 21, feature_type = "CityFurniture"   , del_function= "del_city_furniture"),
        "CityObjectGroup"          : TopClassFeature(name="CityObjectGroup"         , objectclass_id = 23, feature_type = "CityObjectGroup" , del_function= "del_cityobjectgroup"),
        "GenericCityObject"        : TopClassFeature(name="GenericCityObject"       , objectclass_id =  5, feature_type = "Generics"        , del_function= "del_generic_cityobject"),
        "LandUse"                  : TopClassFeature(name="LandUse"                 , objectclass_id =  4, feature_type = "LandUse"         , del_function= "del_land_use"),
        "ReliefFeature"            : TopClassFeature(name="ReliefFeature"           , objectclass_id = 14, feature_type = "Relief"          , del_function= "del_relief_feature"),
        "TINRelief"                : TopClassFeature(name="TINRelief"               , objectclass_id = 16, feature_type = "Relief"          , del_function= "del_tin_relief"),
        "MassPointRelief"          : TopClassFeature(name="MassPointRelief"         , objectclass_id = 17, feature_type = "Relief"          , del_function= "del_masspoint_relief"),
        "BreaklineRelief"          : TopClassFeature(name="BreaklineRelief"         , objectclass_id = 18, feature_type = "Relief"          , del_function= "del_relief_component"),
        "RasterRelief"             : TopClassFeature(name="RasterRelief"            , objectclass_id = 19, feature_type = "Relief"          , del_function= "del_raster_relief"),
        "TransportationComplex"    : TopClassFeature(name="TransportationComplex"   , objectclass_id = 42, feature_type = "Transportation"  , del_function= "del_transportation_complex"),
        "Track"                    : TopClassFeature(name="Track"                   , objectclass_id = 43, feature_type = "Transportation"  , del_function= "del_transportation_complex"),
        "Railway"                  : TopClassFeature(name="Railway"                 , objectclass_id = 44, feature_type = "Transportation"  , del_function= "del_transportation_complex"),
        "Road"                     : TopClassFeature(name="Road"                    , objectclass_id = 45, feature_type = "Transportation"  , del_function= "del_transportation_complex"),
        "Square"                   : TopClassFeature(name="Square"                  , objectclass_id = 46, feature_type = "Transportation"  , del_function= "del_transportation_complex"),
        "Tunnel"                   : TopClassFeature(name="Tunnel"                  , objectclass_id = 85, feature_type = "Tunnel"          , del_function= "del_tunnel"),
        "SolitaryVegetationObject" : TopClassFeature(name="SolitaryVegetationObject", objectclass_id =  7, feature_type = "Vegetation"      , del_function= "del_solitary_vegetat_object"),
        "PlantCover"               : TopClassFeature(name="PlantCover"              , objectclass_id =  8, feature_type = "Vegetation"      , del_function= "del_plant_cover"),
        "WaterBody"                : TopClassFeature(name="WaterBody"               , objectclass_id =  9, feature_type = "WaterBody"       , del_function= "del_waterbody")
        }

    return None


def update_top_class_features_registry_exists(dlg: CDB4DeleterDialog, top_class_features: list) -> None:
    """Function to update the dictionary containing Feature Type metadata for the current cdb_schema.

    top_class_features is a list of named tuples (feature_type, top_class, objectclass_id, n_feature)
    """
    # # Get the list (of namedtuples) of available Top-class features the current cdb_schema
    # top_class_features: list = sql.fetch_top_class_features_counter(dlg)

    tcf: TopClassFeature
    top_class_feature: TopClassFeature
    # Reset the status from potential previous checks
    for tcf in dlg.TopClassFeaturesRegistry.values():
        tcf.exists = False
        tcf.n_features = 0 

    # Set to true only for those Feature Types that exist

    for top_class_feature in top_class_features:
        tcf = dlg.TopClassFeaturesRegistry[top_class_feature.root_class]
        tcf.exists = True
        tcf.n_features = top_class_feature.n_feature 
    return None


def update_top_class_features_is_selected(dlg: CDB4DeleterDialog, sel_top_class_features) -> None:
    """Function to update the dictionary containing Feature Type metadata for the current cdb_schema.
    """
    rcf: TopClassFeature
    # Reset the status from potential previous checks
    for rcf in dlg.TopClassFeaturesRegistry.values():
        rcf.is_selected = False

    if len(sel_top_class_features) != 0:
        # Set to true only for those Feature Types that are selected
        for top_class_feature in sel_top_class_features:
            rcf = dlg.TopClassFeaturesRegistry[top_class_feature.name]
            rcf.is_selected = True

    return None


def initialize_feature_types_registry(dlg: CDB4DeleterDialog) -> None:
    """Function to create the dictionary containing Feature Type metadata.
    """
    # Clean up from possible previous runs
    dlg.FeatureTypesRegistry: dict = {}

    dlg.FeatureTypesRegistry = {
        "Bridge"          : FeatureType(name="Bridge"          , alias='bridge'         ),
        "Building"        : FeatureType(name="Building"        , alias='building'       ),
        "CityFurniture"   : FeatureType(name="CityFurniture"   , alias='cityfurniture'  ),
        "CityObjectGroup" : FeatureType(name="CityObjectGroup" , alias='cityobjectgroup'),
        "Generics"        : FeatureType(name="Generics"        , alias='generics'       ),
        "LandUse"         : FeatureType(name="LandUse"         , alias='landuse'        ),
        "Relief"          : FeatureType(name="Relief"          , alias='relief'         ),
        "Transportation"  : FeatureType(name="Transportation"  , alias='transportation' ),
        "Tunnel"          : FeatureType(name="Tunnel"          , alias='tunnel'         ),
        "Vegetation"      : FeatureType(name="Vegetation"      , alias='vegetation'     ),
        "WaterBody"       : FeatureType(name="WaterBody"       , alias='waterbody'      )
        }

    return None


def update_feature_type_registry_exists(dlg: CDB4DeleterDialog) -> None:
    """Function to update the dictionary containing Feature Type metadata for the current cdb_schema.
    """
    ft: FeatureType
    # Reset the status from potential previous checks
    for ft in dlg.FeatureTypesRegistry.values():
        ft.exists = False
        ft.n_features = 0

    rcf_existing = []
    rcf_existing = [rcf for rcf in dlg.TopClassFeaturesRegistry.values() if rcf.exists is True]

    # Set to true only for those Feature Types that exist and sum the values to get the total
    rcf: TopClassFeature 
    for rcf in rcf_existing:
        ft = dlg.FeatureTypesRegistry[rcf.feature_type]
        ft.exists = True
        ft.n_features += rcf.n_features 

    return None


def update_feature_type_registry_is_selected(dlg: CDB4DeleterDialog, sel_feat_types: list) -> None:
    """Function to update the dictionary containing Feature Type metadata for the current cdb_schema.
    """
    ft: FeatureType
    # Reset the status from potential previous selections
    for ft in dlg.FeatureTypesRegistry.values():
        ft.is_selected = False

    if len(sel_feat_types) != 0:
        # Set to true only for those Feature Types that are selected
        for feat_type in sel_feat_types:
            ft = dlg.FeatureTypesRegistry[feat_type.name]
            ft.is_selected = True

    return None


def refresh_extents(dlg: CDB4DeleterDialog) ->  None:
    """Function to update the extents of the cdb_schema after deleting data.
    """
    # Recompute the extents
    is_geom_null, x_min, y_min, x_max, y_max, srid = sql.exec_compute_cdb_schema_extents(dlg)
    srid = None # Discard unneeded variable.

    if not is_geom_null:

        cdb_extents_old: QgsRectangle = dlg.CDB_SCHEMA_EXTENTS
        cdb_extents_new = QgsRectangle()
        cdb_extents_new.set(x_min, y_min, x_max, y_max, False)

        if cdb_extents_new == cdb_extents_old:
            # 1) Take care of the bboxes

            # Reset the magenta and the current extents to the cdb_extents
            dlg.DELETE_EXTENTS = dlg.CDB_SCHEMA_EXTENTS
            dlg.CURRENT_EXTENTS = dlg.CDB_SCHEMA_EXTENTS

            # Reset the rubber band
            dlg.RUBBER_DELETE.reset()
            # Re-add the rubber band
            canvas.insert_rubber_band(band=dlg.RUBBER_DELETE, extents=dlg.DELETE_EXTENTS, crs=dlg.CRS, width=2, color=c.DELETE_EXTENTS_COLOUR)

            # Just in case, (Re)zoom to the rubber band of the new cdb_extents.
            # Fires evt_qgbxExtents_ext_changed and evt_canvas_ext_changed
            canvas.zoom_to_extents(canvas=dlg.CANVAS, extents=dlg.CDB_SCHEMA_EXTENTS)

            QgsMessageLog.logMessage(f"Extents of '{dlg.CDB_SCHEMA}' are unchanged.", dlg.PLUGIN_NAME, level=Qgis.Info, notifyUser=True)

            # 2) Update the registries
            refresh_registries(dlg)

            return None # Exit

        else:
            # The extents have changed. Show them on the map as dashed line
            # 1) Take care of the bboxes

            # Before resetting the bboxes, show the new ones
            cdb_extents_new_wkt: str = cdb_extents_new.asWktPolygon()
            temp_cdb_extents_new: QgsRectangle = QgsRectangle().fromWkt(cdb_extents_new_wkt)

            # Create new rubber band
            cdb_extents_new_rubber_band: QgsRubberBand = QgsRubberBand(dlg.CANVAS, QgsWkbTypes.PolygonGeometry)
            cdb_extents_new_rubber_band.setLineStyle(Qt.DashLine)

            # Drop the old magenta one
            dlg.RUBBER_DELETE.reset()

            # Insert the dashed bounding box
            canvas.insert_rubber_band(band=cdb_extents_new_rubber_band, extents=cdb_extents_new, crs=dlg.CRS, width=3, color=c.CDB_EXTENTS_COLOUR)

            vis_extents: QgsRectangle = QgsRectangle(cdb_extents_old)
            vis_extents.combineExtentWith(cdb_extents_new)

            canvas.zoom_to_extents(canvas=dlg.CANVAS, extents=vis_extents)

            # Inform the user
            msg: str = f"Extents of '{dlg.CDB_SCHEMA}' have changed, the blue dashed line represents the new ones. They will be automatically updated."
            QMessageBox.information(dlg, "Extents changed!", msg)

            # Update the the cdb_extents in the extents table in PostgreSQL
            sql.exec_upsert_extents(dlg=dlg, bbox_type=c.CDB_SCHEMA_EXT_TYPE, extents_wkt_2d_poly=cdb_extents_new_wkt)

            # Define the new cdb_extents
            dlg.CDB_SCHEMA_EXTENTS = temp_cdb_extents_new

            # Drop the dashed bbox 
            cdb_extents_new_rubber_band.reset()
            # Drop the old cdb_extents
            dlg.RUBBER_CDB_SCHEMA.reset()

            # Re-Reset the other extents to the new ones
            dlg.CDB_SCHEMA_EXTENTS = temp_cdb_extents_new
            dlg.DELETE_EXTENTS = temp_cdb_extents_new
            dlg.CURRENT_EXTENTS = temp_cdb_extents_new

            canvas.insert_rubber_band(band=dlg.RUBBER_CDB_SCHEMA, extents=dlg.CDB_SCHEMA_EXTENTS, crs=dlg.CRS, width=3, color=c.CDB_EXTENTS_COLOUR)

            # Set up the canvas to the new extents of the cdb_schema.
            # Fires evt_qgbxExtents_ext_changed and evt_canvas_ext_changed
            canvas.canvas_setup(dlg=dlg, canvas=dlg.CANVAS, extents=cdb_extents_new, crs=dlg.CRS, clear=True)

            return None

    else:
        # Inform the user
        msg: str = f"Citydb schema '{dlg.CDB_SCHEMA}' is now empty and will disappear from the drop down menu till new data are loaded."
        QMessageBox.information(dlg, "All features deleted", msg)
        QgsMessageLog.logMessage(msg, dlg.PLUGIN_NAME, level=Qgis.Info, notifyUser=True)

        # Reset to null the cdb_extents in the extents table in PostgreSQL
        sql.exec_upsert_extents(dlg=dlg, bbox_type=c.CDB_SCHEMA_EXT_TYPE, extents_wkt_2d_poly=None)
        # Reset to null the layer extents in table usr_schema.extents in PostgreSQL
        sql.exec_upsert_extents(dlg=dlg, bbox_type=c.LAYER_EXT_TYPE, extents_wkt_2d_poly=None)

        # Clean up everything, the user must start again now. There is nothing to do.
        ts_wf.tabSettings_reset(dlg)
        tc_wf.tabConnection_reset(dlg)

        # Close the current open connection.
        if dlg.conn is not None:
            dlg.conn.close()


    return None


def refresh_registries(dlg: CDB4DeleterDialog) ->  None:
    """Function to set up the 'Feature Selection' groupbox, when it is checked.
    """
    # Overview
    # 1) set the bounding box (depending on whether the gbxBasemap is enabled or not)
    # 2) get the available top-class features in the proper bbox from the database
    # 3) set up/update the top-class features registry
    # 4) set up/update the Feature Type registry
    # 5) fill the top-class features checkable combobox
    # 6) fill the feature type checkable combobox    
    # 7) Now we are ready for the user to choose and click the delete selected features button.

    curr_extents_poly_wkt: str = None
    curr_extents = QgsRectangle()

    # 1) set the bounding box (depending on whether the gbxBasemap is enabled or not)
    if dlg.gbxBasemap.isChecked():
        if dlg.CURRENT_EXTENTS == dlg.CDB_SCHEMA_EXTENTS:
            curr_extents = None
            curr_extents_poly_wkt = None
        else:
            curr_extents = dlg.CURRENT_EXTENTS
            curr_extents_poly_wkt: str = curr_extents.asWktPolygon()
    else:
        curr_extents = None
        curr_extents_poly_wkt = None

    # 2) get the available top-class features in the proper bbox from the database
    # function returns a list of named tuples (feature_type, root_class, objectclass_id, n_feature)
    top_class_features = sql.fetch_top_class_features_counter(dlg, curr_extents_poly_wkt)
    # print('\n\ntop_class_features', top_class_features)

    # 3) set up/update the top-class feature registry (exists)
    update_top_class_features_registry_exists(dlg, top_class_features)

    # 4) set up/update the Feature Type registry (exists)
    update_feature_type_registry_exists(dlg)

    # 5) Fill the top-class checkable combobox
    fill_top_class_features_box(dlg)

    # 6) Fill the Feature type checkable combobox 
    fill_feature_types_box(dlg)

    # msg: str = f"Registries of '{dlg.CDB_SCHEMA}' updated."
    # QgsMessageLog.logMessage(msg, dlg.PLUGIN_NAME, level=Qgis.Info, notifyUser=True)
    # print(msg)

    # Now the user is ready to select from the combo boxes and finally delete.

    return None
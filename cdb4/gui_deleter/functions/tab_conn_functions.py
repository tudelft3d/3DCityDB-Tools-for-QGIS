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

from ..other_classes import TopLevelFeature, FeatureType
from .. import deleter_constants as c
from . import tab_conn_widget_functions as tc_wf
from . import tab_settings_widget_functions as ts_wf
from . import canvas, sql

def fill_cdb_schemas_box(dlg: CDB4DeleterDialog, cdb_schemas: tuple = None) -> None:
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
            label: str = f"{cdb_schema.cdb_schema}"
            dlg.cbxSchema.addItem(label, userData=cdb_schema.cdb_schema)
        if not dlg.cbxSchema.isEnabled():
            # Enable the combobox
            dlg.cbxSchema.setDisabled(False)
            dlg.lblSchema.setDisabled(False)
   
    # REMEMBER: don't use method 'setSeparator', it adds a custom separator to join string of selected items
    return None


def fill_top_level_features_box(dlg: CDB4DeleterDialog) -> None:
    """Function that fills the top class features checkable combo box

    """
    # Clear combo box from previous entries
    dlg.ccbxTopLevelClass.clear()
    dlg.ccbxTopLevelClass.setDefaultText('Select top-level feature(s)')

    top_level_features: list = [rcf for rcf in dlg.TopLevelFeaturesRegistry.values() if rcf.exists]

    if len(top_level_features) == 0: 
        dlg.ccbxTopLevelClass.setDefaultText('None available')
        # Disable the combobox
        dlg.ccbxTopLevelClass.setDisabled(True)
    else:
        tlf: TopLevelFeature
        for tlf in top_level_features:
            label = f"{tlf.name} ({tlf.n_features})" 
            dlg.ccbxTopLevelClass.addItemWithCheckState(
                text=label,
                state=0,
                userData=tlf) # this is the value retrieved later
        # Reorder items alphabetically
        dlg.ccbxTopLevelClass.model().sort(0)
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
    dlg.TopLevelFeaturesRegistry: dict = {}
    
    dlg.TopLevelFeaturesRegistry = {
        "Bridge"                   : TopLevelFeature(name="Bridge"                  , objectclass_id = 64, feature_type = "Bridge"          , del_function= "del_bridge"),
        "Building"                 : TopLevelFeature(name="Building"                , objectclass_id = 26, feature_type = "Building"        , del_function= "del_building"),
        "CityFurniture"            : TopLevelFeature(name="CityFurniture"           , objectclass_id = 21, feature_type = "CityFurniture"   , del_function= "del_city_furniture"),
        "CityObjectGroup"          : TopLevelFeature(name="CityObjectGroup"         , objectclass_id = 23, feature_type = "CityObjectGroup" , del_function= "del_cityobjectgroup"),
        "GenericCityObject"        : TopLevelFeature(name="GenericCityObject"       , objectclass_id =  5, feature_type = "Generics"        , del_function= "del_generic_cityobject"),
        "LandUse"                  : TopLevelFeature(name="LandUse"                 , objectclass_id =  4, feature_type = "LandUse"         , del_function= "del_land_use"),
        "ReliefFeature"            : TopLevelFeature(name="ReliefFeature"           , objectclass_id = 14, feature_type = "Relief"          , del_function= "del_relief_feature"),
        "TINRelief"                : TopLevelFeature(name="TINRelief"               , objectclass_id = 16, feature_type = "Relief"          , del_function= "del_tin_relief"),
        "MassPointRelief"          : TopLevelFeature(name="MassPointRelief"         , objectclass_id = 17, feature_type = "Relief"          , del_function= "del_masspoint_relief"),
        "BreaklineRelief"          : TopLevelFeature(name="BreaklineRelief"         , objectclass_id = 18, feature_type = "Relief"          , del_function= "del_relief_component"),
        "RasterRelief"             : TopLevelFeature(name="RasterRelief"            , objectclass_id = 19, feature_type = "Relief"          , del_function= "del_raster_relief"),
        "TransportationComplex"    : TopLevelFeature(name="TransportationComplex"   , objectclass_id = 42, feature_type = "Transportation"  , del_function= "del_transportation_complex"),
        "Track"                    : TopLevelFeature(name="Track"                   , objectclass_id = 43, feature_type = "Transportation"  , del_function= "del_transportation_complex"),
        "Railway"                  : TopLevelFeature(name="Railway"                 , objectclass_id = 44, feature_type = "Transportation"  , del_function= "del_transportation_complex"),
        "Road"                     : TopLevelFeature(name="Road"                    , objectclass_id = 45, feature_type = "Transportation"  , del_function= "del_transportation_complex"),
        "Square"                   : TopLevelFeature(name="Square"                  , objectclass_id = 46, feature_type = "Transportation"  , del_function= "del_transportation_complex"),
        "Tunnel"                   : TopLevelFeature(name="Tunnel"                  , objectclass_id = 85, feature_type = "Tunnel"          , del_function= "del_tunnel"),
        "SolitaryVegetationObject" : TopLevelFeature(name="SolitaryVegetationObject", objectclass_id =  7, feature_type = "Vegetation"      , del_function= "del_solitary_vegetat_object"),
        "PlantCover"               : TopLevelFeature(name="PlantCover"              , objectclass_id =  8, feature_type = "Vegetation"      , del_function= "del_plant_cover"),
        "WaterBody"                : TopLevelFeature(name="WaterBody"               , objectclass_id =  9, feature_type = "WaterBody"       , del_function= "del_waterbody")
        }

    return None


def update_top_level_features_registry_exists(dlg: CDB4DeleterDialog, top_level_features: list) -> None:
    """Function to update the dictionary containing Feature Type metadata for the current cdb_schema.

    top_class_features is a list of named tuples (feature_type, top_class, objectclass_id, n_feature)
    """
    # # Get the list (of namedtuples) of available top-level features the current cdb_schema
    # top_class_features: list = sql.fetch_top_class_features_counter(dlg)

    tlf: TopLevelFeature
    top_level_feature: TopLevelFeature
    # Reset the status from potential previous checks
    for tlf in dlg.TopLevelFeaturesRegistry.values():
        tlf.exists = False
        tlf.n_features = 0 

    # Set to true only for those Feature Types that exist

    for top_level_feature in top_level_features:
        tlf = dlg.TopLevelFeaturesRegistry[top_level_feature.root_class]
        tlf.exists = True
        tlf.n_features = top_level_feature.n_feature 
    return None


def update_top_class_features_is_selected(dlg: CDB4DeleterDialog, sel_top_class_features) -> None:
    """Function to update the dictionary containing Feature Type metadata for the current cdb_schema.
    """
    rcf: TopLevelFeature
    # Reset the status from potential previous checks
    for rcf in dlg.TopLevelFeaturesRegistry.values():
        rcf.is_selected = False

    if len(sel_top_class_features) != 0:
        # Set to true only for those Feature Types that are selected
        for top_class_feature in sel_top_class_features:
            rcf = dlg.TopLevelFeaturesRegistry[top_class_feature.name]
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

    tlf_existing = []
    tlf_existing = [rcf for rcf in dlg.TopLevelFeaturesRegistry.values() if rcf.exists is True]

    # Set to true only for those Feature Types that exist and sum the values to get the total
    tlf: TopLevelFeature 
    for tlf in tlf_existing:
        ft = dlg.FeatureTypesRegistry[tlf.feature_type]
        ft.exists = True
        ft.n_features += tlf.n_features 

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

            QgsMessageLog.logMessage(f"Extents of '{dlg.CDB_SCHEMA}' are unchanged.", dlg.PLUGIN_NAME, level=Qgis.MessageLevel.Info, notifyUser=True)

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

            # Set up the canvas to the new extents of the cdb_schema.
            # Fires evt_qgbxExtents_ext_changed and evt_canvas_ext_changed
            canvas.canvas_setup(dlg=dlg, canvas=dlg.CANVAS, extents=cdb_extents_new, crs=dlg.CRS, clear=True)

            canvas.insert_rubber_band(band=dlg.RUBBER_CDB_SCHEMA, extents=dlg.CDB_SCHEMA_EXTENTS, crs=dlg.CRS, width=3, color=c.CDB_EXTENTS_COLOUR)

            return None

    else:
        # Inform the user
        msg: str = f"Citydb schema '{dlg.CDB_SCHEMA}' is now empty and will disappear from the drop down menu till new data are loaded."
        QMessageBox.information(dlg, "All features deleted", msg)
        QgsMessageLog.logMessage(msg, dlg.PLUGIN_NAME, level=Qgis.MessageLevel.Info, notifyUser=True)

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
    # 2) get the available top-level features in the proper bbox from the database
    # 3) set up/update the top-level features registry
    # 4) set up/update the Feature Type registry
    # 5) fill the top-level features checkable combobox
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

    # 2) get the available top-level features in the proper bbox from the database
    # function returns a list of named tuples (feature_type, root_class, objectclass_id, n_feature)
    top_level_features = sql.fetch_top_level_features_counter(dlg, curr_extents_poly_wkt)
    # print('top_class_features', top_class_features)

    # 3) set up/update the top-level feature registry (exists)
    update_top_level_features_registry_exists(dlg, top_level_features)

    # 4) set up/update the Feature Type registry (exists)
    update_feature_type_registry_exists(dlg)

    # 5) Fill the top-level checkable combobox
    fill_top_level_features_box(dlg)

    # 6) Fill the Feature type checkable combobox 
    fill_feature_types_box(dlg)

    # msg: str = f"Registries of '{dlg.CDB_SCHEMA}' updated."
    # QgsMessageLog.logMessage(msg, dlg.PLUGIN_NAME, level=Qgis.MessageLevel.Info, notifyUser=True)
    # print(msg)

    # Now the user is ready to select from the combo boxes and finally delete.

    return None
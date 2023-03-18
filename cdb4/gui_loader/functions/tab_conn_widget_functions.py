"""This module contains reset functions for each QT widgets.

The logic behind all of the functions is to reset widgets as individual
objects or as block of objects, depending on the needs.

The reset functions consist of clearing text or changed text to original state,
clearing widget items or selections and deactivating widgets.
"""
from __future__ import annotations
from typing import TYPE_CHECKING
if TYPE_CHECKING:       
    from ...gui_loader.loader_dialog import CDB4LoaderDialog
    from ..other_classes import FeatureType

from qgis.core import QgsProject, QgsGeometry, QgsRectangle, QgsCoordinateReferenceSystem

from ...shared.functions import general_functions as gen_f
from .. import loader_constants as c
from . import canvas, sql

FILE_LOCATION = gen_f.get_file_relative_path(file=__file__)

####################################################
## Setup widget functions for 'User Connection' tab
####################################################

def gbxBasemap_setup(dlg: CDB4LoaderDialog) ->  None:
    """Function to setup the 'Basemap' groupbox.
    It uses an additional canvas instance to store an OSM map from which extents can be extracted
    for further spatial queries.
    The basemap is zoomed-in to the cdb_extent (i.e. the extents of the whole city model).
    """
    ###############
    if not dlg.CRS:
        print("In gbxBasemap_setup", dlg.CRS, dlg.CRS_is_geographic)
    else:
        print("In gbxBasemap_setup", dlg.CRS.postgisSrid(), dlg.CRS_is_geographic)
    ###############

    cdb_extents_wkt: str = None

    # Get the crs_id stored in the selected {cdb_schema}
    srid: int = sql.fetch_cdb_schema_srid(dlg)
    # Format CRS variable as QGIS Epsg code.
    crs: str = ":".join(["EPSG", str(srid)]) # e.g. EPSG:28992
    # Store the crs into the plugin variable
    dlg.CRS = QgsCoordinateReferenceSystem(crs)
    dlg.CRS_is_geographic = dlg.CRS.isGeographic()
    print("In gbxBasemap_setup: CRS_from database", dlg.CRS.postgisSrid(), dlg.CRS_is_geographic)

    while not cdb_extents_wkt:

        # Get the extents stored in server.
        cdb_extents_wkt: str = sql.fetch_precomputed_extents(dlg, ext_type=c.CDB_SCHEMA_EXT_TYPE)

        # Extents could be None (not computed yet).
        if not cdb_extents_wkt:
            # There are no precomputed extents for the cdb_schema, so compute them "for real" (bbox of all cityobjects).
            # This function automatically upserts the bbox to the table of the precomputed extents in the usr_schema
            sql.exec_upsert_extents(dlg=dlg, bbox_type=c.CDB_SCHEMA_EXT_TYPE, extents_wkt_2d_poly=None)

    # Check whether the layer extents were already computed and stored in the database before
    layer_extents_wkt: str = None
    layer_extents_wkt = sql.fetch_precomputed_extents(dlg, ext_type=c.LAYER_EXT_TYPE)
   
    if not layer_extents_wkt:
        layer_extents_wkt = cdb_extents_wkt

    dlg.CDB_SCHEMA_EXTENTS = QgsRectangle.fromWkt(cdb_extents_wkt)
    dlg.LAYER_EXTENTS = QgsRectangle.fromWkt(layer_extents_wkt)

    # Test if the layers bbox is the same or smaller, to set the current extents
    cdb_extents_poly = QgsGeometry.fromWkt(cdb_extents_wkt)
    layer_extents_poly = QgsGeometry.fromWkt(layer_extents_wkt)
    if cdb_extents_poly.equals(layer_extents_poly):
        dlg.CURRENT_EXTENTS = dlg.CDB_SCHEMA_EXTENTS
    else:
        dlg.CURRENT_EXTENTS = dlg.LAYER_EXTENTS

    # Draw the canvas
    # First setup and update canvas with the OSM map on cdb_schema extents and crs, (this fires the gbcExtent event)
    canvas.canvas_setup(dlg=dlg, canvas=dlg.CANVAS, extents=dlg.CURRENT_EXTENTS, crs=dlg.CRS, clear=True)

    # Second, create polygon rubber band corresponding to the cdb_schema extents
    canvas.insert_rubber_band(band=dlg.RUBBER_CDB_SCHEMA, extents=dlg.CDB_SCHEMA_EXTENTS, crs=dlg.CRS, width=3, color=c.CDB_EXTENTS_COLOUR)

    # Third, create polygon rubber band corresponding to the layers extents
    canvas.insert_rubber_band(band=dlg.RUBBER_LAYERS, extents=dlg.LAYER_EXTENTS, crs=dlg.CRS, width=3, color=c.LAYER_EXTENTS_COLOUR)

    # Zoom to the cdb_schema extents
    canvas.zoom_to_extents(canvas=dlg.CANVAS, extents=dlg.CDB_SCHEMA_EXTENTS)

    return None


####################################################
## Reset widget functions for 'User Connection' tab
####################################################

def tabConnection_reset(dlg: CDB4LoaderDialog) -> None:
    """Function to reset the 'Connection' tab and all dependent widgets.
    """
    # Close the current open connection.
    if dlg.conn is not None:
        dlg.conn.close()

    gbxDatabase_reset(dlg)
    gbxConnStatus_reset(dlg)
    gbxBasemap_reset(dlg)
    gbxFeatSel_reset(dlg)
    
    btnCreateLayers_reset(dlg)
    dlg.gbxFeatSel.setDisabled(True)

    btnRefreshLayers_reset(dlg)
    btnDropLayers_reset(dlg)
    dlg.btnCloseConn.setDisabled(True)

    return None


def gbxDatabase_reset(dlg: CDB4LoaderDialog) -> None:
    """Function to reset the 'Database' groupbox.
    """
    dlg.cbxSchema.clear()
    dlg.cbxSchema.setDisabled(True)
    dlg.lblSchema.setDisabled(True)

    return None


def gbxConnStatus_reset(dlg: CDB4LoaderDialog) -> None:
    """Function to reset the 'Connection status' groupbox
    """
    dlg.gbxConnStatus.setDisabled(True)
    dlg.lblConnToDb_out.clear()
    dlg.lblPostInst_out.clear()
    dlg.lbl3DCityDBInst_out.clear()
    dlg.lblMainInst_out.clear()
    dlg.lblUserInst_out.clear()
    dlg.lblLayerExist_out.clear()
    dlg.lblLayerRefr_out.clear()

    return None


def gbxBasemap_reset(dlg: CDB4LoaderDialog) -> None:
    """Function to reset the 'Basemap (OSM)' groupbox
    """
    dlg.gbxBasemap.setDisabled(True)
    dlg.btnRefreshCDBExtents.setText(dlg.btnRefreshCDBExtents.init_text)
    dlg.btnCityExtents.setText(dlg.btnCityExtents.init_text)

    # Remove extent rubber bands.
    if dlg.RUBBER_CDB_SCHEMA:
        dlg.RUBBER_CDB_SCHEMA.reset()
    if dlg.RUBBER_LAYERS:        
        dlg.RUBBER_LAYERS.reset()
    if dlg.RUBBER_QGIS_L:
        dlg.RUBBER_QGIS_L.reset()

    # Clear map registry from OSM layers.
    registryLayers = [i.id() for i in QgsProject.instance().mapLayers().values() if c.OSM_NAME == i.name()]
    QgsProject.instance().removeMapLayers(registryLayers)

    # Refresh to show to re-render the canvas (as empty).
    dlg.CANVAS.refresh()
    # dlg.CANVAS.destroy()

    return None


def gbxFeatSel_reset(dlg: CDB4LoaderDialog) -> None:
    """Function to reset the 'Feature Selection' groupbox.
    """
    ft: FeatureType
    # Reset the status from potential previous selections to the default one
    for ft in dlg.FeatureTypesRegistry.values():
        ft.is_selected = True

    # Clear comboboxes
    dlg.cbxFeatType.clear()
    # Disable comboboxes
    dlg.cbxFeatType.setDisabled(True)
    # Uncheck the combobox itself
    dlg.gbxFeatSel.setChecked(False)

    return None


def btnCreateLayers_reset(dlg: CDB4LoaderDialog) -> None:
    """Function to reset the 'Create layers' pushButton.
    """
    dlg.btnCreateLayers.setDisabled(True)
    dlg.btnCreateLayers.setText(dlg.btnCreateLayers.init_text)

    return None


def btnRefreshLayers_reset(dlg: CDB4LoaderDialog) -> None:
    """Function to reset the 'Refresh layers' pushButton.
    """
    dlg.btnRefreshLayers.setDisabled(True)
    dlg.btnRefreshLayers.setText(dlg.btnRefreshLayers.init_text)

    return None


def btnDropLayers_reset(dlg: CDB4LoaderDialog) -> None:
    """Function to reset the 'Drop layers' pushButton.
    """
    dlg.btnDropLayers.setDisabled(True)

    return None
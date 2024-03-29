"""This module contains reset functions for each QT widgets.

The logic behind all of the functions is to reset widgets as individual
objects or as block of objects, depending on the needs.

The reset functions consist of clearing text or changed text to original state,
clearing widget items or selections and deactivating widgets.
"""
from __future__ import annotations
from typing import TYPE_CHECKING, cast, Iterable
if TYPE_CHECKING:       
    from ...gui_deleter.deleter_dialog import CDB4DeleterDialog

from qgis.PyQt.QtWidgets import QMessageBox
from qgis.core import Qgis, QgsProject, QgsMessageLog, QgsGeometry, QgsRectangle, QgsCoordinateReferenceSystem, QgsMapLayer

from ...shared.functions import general_functions as gen_f
from ...shared.dataTypes import BBoxType
from .. import deleter_constants as c
from . import canvas, sql

FILE_LOCATION = gen_f.get_file_relative_path(file=__file__)

####################################################
## Setup widget functions for 'User Connection' tab
####################################################

# In 'Basemap (OMS)' groupBox.
def gbxBasemap_setup(dlg: CDB4DeleterDialog) ->  None:
    """Function to setup the 'Basemap' groupbox.
    It uses an additional canvas instance to store an OSM map from which extents can be extracted
    for further spatial queries.
    The basemap is zoomed-in to the cdb_extent (i.e. the extents of the whole city model).
    """

    # Get the crs_id stored in the selected {cdb_schema}
    srid = sql.get_cdb_schema_srid(dlg=dlg)
    # Format CRS variable as QGIS Epsg code.
    crs: str = ":".join(["EPSG", str(srid)]) # e.g. EPSG:28992
    # Store the crs into the plugin variable
    dlg.CRS = QgsCoordinateReferenceSystem(crs)
    dlg.CRS_is_geographic = dlg.CRS.isGeographic()
    # print(f"In gbxBasemap_setup: CRS from database {dlg.CRS.postgisSrid()}, is geographic? {dlg.CRS_is_geographic}")

    cdb_extents_wkt = sql.get_precomputed_cdb_schema_extents(dlg=dlg)
    if not cdb_extents_wkt:
        sql.upsert_extents(dlg=dlg, bbox_type=BBoxType.CDB_SCHEMA, extents_wkt_2d_poly=None)
        cdb_extents_wkt = sql.get_precomputed_cdb_schema_extents(dlg=dlg)
        if not cdb_extents_wkt:
            # Something went wrong on the server when computin the bbox
            msg: str = f"Something went wrong while computing the extents on the server."
            QMessageBox.critical(dlg, "Uups, server... not serving!", msg)
            QgsMessageLog.logMessage(msg, dlg.PLUGIN_NAME, level=Qgis.MessageLevel.Critical, notifyUser=True)
            return None

    # while not cdb_extents_wkt:
    #     # Get the extents stored in server.
    #     cdb_extents_wkt = sql.get_precomputed_cdb_schema_extents(dlg=dlg)
    #     # Extents could be None (not computed yet).
    #     if not cdb_extents_wkt:
    #         # There are no precomputed extents for the cdb_schema, so compute them "for real" (bbox of all cityobjects)'.
    #         # This function automatically upsert the bbox to the table of the precomputed extents in the usr_schema
    #         sql.upsert_extents(dlg=dlg, bbox_type=BBoxType.CDB_SCHEMA, extents_wkt_2d_poly=None)

    delete_extents_wkt = cdb_extents_wkt

    dlg.CDB_SCHEMA_EXTENTS = QgsRectangle.fromWkt(cdb_extents_wkt)
    dlg.DELETE_EXTENTS = QgsRectangle.fromWkt(delete_extents_wkt)

    # Test if the delete extents are the same or smaller, to set the current extents
    cdb_extents_poly = QgsGeometry.fromWkt(cdb_extents_wkt)
    delete_extents_poly = QgsGeometry.fromWkt(delete_extents_wkt)
    if cdb_extents_poly.equals(delete_extents_poly):
        dlg.CURRENT_EXTENTS = dlg.CDB_SCHEMA_EXTENTS
    else:
        dlg.CURRENT_EXTENTS = dlg.DELETE_EXTENTS

    # Draw the canvas
    # First set up and update canvas with the OSM map on cdb_schema extents and crs (this fires the gbcExtent event)
    canvas.canvas_setup(dlg=dlg, canvas=dlg.CANVAS, extents=dlg.CURRENT_EXTENTS, crs=dlg.CRS, clear=True)

    # Second, create polygon rubber band corresponding to the cdb_schema extents
    canvas.insert_rubber_band(band=dlg.RUBBER_CDB_SCHEMA, extents=dlg.CDB_SCHEMA_EXTENTS, crs=dlg.CRS, width=3, color=c.CDB_EXTENTS_COLOUR)

    # Third, create polygon rubber band corresponding to the delete extents
    canvas.insert_rubber_band(band=dlg.RUBBER_DELETE, extents=dlg.DELETE_EXTENTS, crs=dlg.CRS, width=3, color=c.DELETE_EXTENTS_COLOUR)

    # Zoom to the cdb_schema extents (blue box)
    canvas.zoom_to_extents(canvas=dlg.CANVAS, extents=dlg.CDB_SCHEMA_EXTENTS)

    return None


####################################################
## Reset widget functions for 'User Connection' tab
####################################################

def tabConnection_reset(dlg: CDB4DeleterDialog) -> None:
    """Function to reset the 'Connection' tab.
    Resets: gbxConnStatus and gbxDatabase.
    """
    gbxDatabase_reset(dlg=dlg)
    gbxConnStatus_reset(dlg=dlg)

    gbxCleanUpSchema_reset(dlg=dlg)
    gbxBasemap_reset(dlg=dlg)
    gbxFeatSel_reset(dlg=dlg)
    
    dlg.btnCloseConn.setDisabled(True)

    return None


def gbxDatabase_reset(dlg: CDB4DeleterDialog) -> None:
    """Function to reset the 'Database' groupbox (in Connection tab).
    """
    dlg.cbxSchema.clear()
    dlg.cbxSchema.setDisabled(True)
    dlg.lblSchema.setDisabled(True)

    return None


def gbxCleanUpSchema_reset(dlg: CDB4DeleterDialog) -> None:
    """Function to reset the 'Connection status' groupbox
    """
    dlg.gbxCleanUpSchema.setChecked(False)
    dlg.gbxCleanUpSchema.setDisabled(True)

    dlg.btnCleanUpSchema.setText(dlg.btnCleanUpSchema.init_text)

    return None


def gbxBasemap_reset(dlg: CDB4DeleterDialog) -> None:
    """Function to reset the 'Basemap (OSM)' groupbox
    """
    dlg.gbxBasemap.setChecked(False)
    dlg.gbxBasemap.setDisabled(True)

    # Reset the button text to initial values
    dlg.btnRefreshCDBExtents.setText(dlg.btnRefreshCDBExtents.init_text)
    dlg.btnCityExtents.setText(dlg.btnCityExtents.init_text)

    # Remove extent rubber bands
    if dlg.RUBBER_CDB_SCHEMA:
        dlg.RUBBER_CDB_SCHEMA.reset()
    if dlg.RUBBER_DELETE:
        dlg.RUBBER_DELETE.reset()

    # Clear map registry from OSM layers.
    registryLayers = [i.id() for i in cast(Iterable[QgsMapLayer], QgsProject.instance().mapLayers().values()) if c.OSM_NAME == i.name()]

    QgsProject.instance().removeMapLayers(layerIds=registryLayers)
    # Refresh to show to re-render the canvas (as empty).
    dlg.CANVAS.refresh()

    return None


def gbxFeatSel_reset(dlg: CDB4DeleterDialog) -> None:
    """Function to reset the 'Feature Selection' groupbox (in 'User Connection' tab).
    """
    dlg.gbxFeatType.setChecked(False)
    dlg.gbxTopLevelClass.setChecked(False)
    gbxFeatType_reset(dlg=dlg)
    gbxTopLevelClass_reset(dlg=dlg)

    dlg.gbxFeatSel.setChecked(False)
    dlg.gbxFeatSel.setDisabled(True)

    dlg.btnDelSelFeatures.setDisabled(True)

    # dlg.ckbAddSpatialFilter.setChecked(False)

    return None


def gbxFeatType_reset(dlg: CDB4DeleterDialog) -> None:
    """Function to reset the 'Feature Type' groupbox (in 'User Connection' tab).
    """
    dlg.gbxFeatType.setDisabled(True)
    dlg.ccbxFeatType.clear() # This clears also the default text
    dlg.ckbFeatTypeAll.setChecked(False)
    dlg.ccbxFeatType.setDefaultText('Select feature type(s)')
    dlg.ccbxFeatType.setDisabled(True)

    return None


def gbxTopLevelClass_reset(dlg: CDB4DeleterDialog) -> None:
    """Function to reset the 'top-level Feature' groupbox (in 'User Connection' tab).
    """
    dlg.gbxTopLevelClass.setDisabled(True)
    dlg.ccbxTopLevelClass.clear() # This clears also the default text
    dlg.ckbTopLevelClassAll.setChecked(False)
    dlg.ccbxTopLevelClass.setDefaultText('Select top-level feature(s)')
    dlg.ccbxTopLevelClass.setDisabled(True)
    
    return None


def gbxConnStatus_reset(dlg: CDB4DeleterDialog) -> None:
    """Function to reset the 'Connection status' groupbox
    """
    dlg.gbxConnStatus.setDisabled(True)
    dlg.lblConnToDb_out.clear()
    dlg.lblPostInst_out.clear()
    dlg.lbl3DCityDBInst_out.clear()
    dlg.lblMainInst_out.clear()
    dlg.lblUserInst_out.clear()

    return None


def workaround_gbxFeatType(dlg: CDB4DeleterDialog) -> None:
    ##########################################
    # This is to take care of a bizarre behaviour of 
    # the groupbox not keeping the status of the child
    # combobox that gets activated once we add items
    ##########################################
    dlg.ccbxFeatType.setDisabled(False)
    dlg.gbxFeatType.setDisabled(False)
    dlg.ccbxFeatType.setDisabled(True)
    dlg.gbxFeatType.setDisabled(True)

    return None


def workaround_gbxTopLevelClass(dlg: CDB4DeleterDialog) -> None:
    ##########################################
    # This is to take care of a bizarre behaviour of 
    # the groupbox not keeping the status of the child
    # combobox that gets activated once we add items
    ##########################################
    dlg.ccbxTopLevelClass.setDisabled(False)
    dlg.gbxTopLevelClass.setDisabled(False)
    dlg.ccbxTopLevelClass.setDisabled(True)
    dlg.gbxTopLevelClass.setDisabled(True)

    return None
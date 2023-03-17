"""This module contains reset functions for each QT widgets.

The logic behind all of the functions is to reset widgets as individual
objects or as block of objects, depending on the needs.

The reset functions consist of clearing text or changed text to original state,
clearing widget items or selections and deactivating widgets.
"""
from __future__ import annotations
from typing import TYPE_CHECKING
if TYPE_CHECKING:       
    from ...gui_deleter.deleter_dialog import CDB4DeleterDialog

from qgis.core import QgsProject, QgsGeometry, QgsRectangle, QgsCoordinateReferenceSystem
from qgis.PyQt.QtCore import Qt

from ...shared.functions import general_functions as gen_f
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
    cdb_extents_wkt: str = None

    # Get the crs_id stored in the selected {cdb_schema}
    srid: int = sql.fetch_cdb_schema_srid(dlg)
    # Format CRS variable as QGIS Epsg code.
    crs: str = ":".join(["EPSG", str(srid)]) # e.g. EPSG:28992
    # Storethe crs into the plugin variable
    dlg.CRS = QgsCoordinateReferenceSystem(crs)
    # print("CRS from database",dlg.CRS.postgisSrid())
    dlg.CRS_is_geographic = dlg.CRS.isGeographic()
    # print("CRS_from database: is_geographic?",dlg.CRS.isGeographic())

    while not cdb_extents_wkt:

        # Get the extents stored in server.
        cdb_extents_wkt: str = sql.fetch_precomputed_extents(dlg, usr_schema=dlg.USR_SCHEMA, cdb_schema=dlg.CDB_SCHEMA, ext_type=c.CDB_SCHEMA_EXT_TYPE)

        # Extents could be None (not computed yet).
        if not cdb_extents_wkt:
            # There are no precomputed extents for the cdb_schema, so compute them "for real" (bbox of all cityobjects)'.
            # This function automatically upsert the bbox to the table of the precomputed extents in the usr_schema
            sql.exec_upsert_extents(dlg=dlg, bbox_type=c.CDB_SCHEMA_EXT_TYPE, extents_wkt_2d_poly=None)

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

    # Draw the cdb extents in the canvas
    # First, create polygon rubber band corresponding to the cdb_schema extents
    canvas.insert_rubber_band(band=dlg.RUBBER_CDB_SCHEMA, extents=dlg.CDB_SCHEMA_EXTENTS, crs=dlg.CRS, width=3, color=c.CDB_EXTENTS_COLOUR)

    # First, create polygon rubber band corresponding to the cdb_schema extents
    canvas.insert_rubber_band(band=dlg.RUBBER_DELETE, extents=dlg.DELETE_EXTENTS, crs=dlg.CRS, width=3, color=c.DELETE_EXTENTS_COLOUR)

    # Then update canvas with cdb_schema extents and crs, this fires the gbcExtent event
    canvas.canvas_setup(dlg=dlg, canvas=dlg.CANVAS, extents=dlg.CURRENT_EXTENTS, crs=dlg.CRS, clear=True)

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
    gbxDatabase_reset(dlg)
    gbxConnStatus_reset(dlg)

    gbxCleanUpSchema_reset(dlg)
    gbxBasemap_reset(dlg)
    gbxFeatSel_reset(dlg)
    
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

    # Remove extent rubber bands.
    dlg.RUBBER_CDB_SCHEMA.reset()
    dlg.RUBBER_DELETE.reset()

    # Clear map registry from OSM layers.
    registryLayers = [i.id() for i in QgsProject.instance().mapLayers().values() if c.OSM_NAME == i.name()]
    QgsProject.instance().removeMapLayers(registryLayers)
    # Refresh to show to re-render the canvas (as empty).
    dlg.CANVAS.refresh()

    return None


def gbxFeatSel_reset(dlg: CDB4DeleterDialog) -> None:
    """Function to reset the 'Feature Selection' groupbox (in 'User Connection' tab).
    """
    dlg.gbxFeatType.setChecked(False)
    dlg.gbxTopClass.setChecked(False)
    gbxFeatType_reset(dlg)
    gbxTopClass_reset(dlg)

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


def gbxTopClass_reset(dlg: CDB4DeleterDialog) -> None:
    """Function to reset the 'Top-class Feature' groupbox (in 'User Connection' tab).
    """
    dlg.gbxTopClass.setDisabled(True)
    dlg.ccbxTopClass.clear() # This clears also the default text
    dlg.ckbTopClassAll.setChecked(False)
    dlg.ccbxTopClass.setDefaultText('Select top-class feature(s)')
    dlg.ccbxTopClass.setDisabled(True)
    
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


def workaround_gbxTopClass(dlg: CDB4DeleterDialog) -> None:
    ##########################################
    # This is to take care of a bizarre behaviour of 
    # the groupbox not keeping the status of the child
    # combobox that gets activated once we add items
    ##########################################
    dlg.ccbxTopClass.setDisabled(False)
    dlg.gbxTopClass.setDisabled(False)
    dlg.ccbxTopClass.setDisabled(True)
    dlg.gbxTopClass.setDisabled(True)

    return None
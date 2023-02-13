"""This module contains reset functions for each QT widgets.

The logic behind all of the functions is to reset widgets as individual
objects or as block of objects, depending on the needs.

The reset functions consist of clearing text or changed text to original state,
clearing widget items or selections and deactivating widgets.
"""
from qgis.core import QgsProject, QgsGeometry, QgsRectangle, QgsCoordinateReferenceSystem
from qgis.PyQt.QtCore import Qt

from ....cdb_tools_main import CDBToolsMain # Used only to add the type of the function parameters

from ...shared.functions import general_functions as gen_f

from .. import deleter_constants as c

from . import canvas, sql

FILE_LOCATION = gen_f.get_file_relative_path(file=__file__)

####################################################
## Setup widget functions for 'User Connection' tab
####################################################

# In 'Basemap (OMS)' groupBox.
def gbxBasemapC_setup(cdbMain: CDBToolsMain) ->  None:
    """Function to setup the 'Basemap' groupbox.
    It uses an additional canvas instance to store an OSM map from which extents can be extracted
    for further spatial queries.
    The basemap is zoomed-in to the cdb_extent (i.e. the extents of the whole city model).
    """
    dlg = cdbMain.deleter_dlg
    cdb_extents_wkt: str = None

    while not cdb_extents_wkt:

        # Get the extents stored in server.
        cdb_extents_wkt: str = sql.fetch_precomputed_extents(cdbMain, usr_schema=cdbMain.USR_SCHEMA, cdb_schema=cdbMain.CDB_SCHEMA, ext_type=c.CDB_SCHEMA_EXT_TYPE)

        # Extents could be None (not computed yet).
        if not cdb_extents_wkt:
            # There are no precomputed extents for the cdb_schema, so compute them "for real" (bbox of all cityobjects)'.
            # This function automatically upsert the bbox to the table of the precomputed extents in the usr_schema
            sql.exec_upsert_extents(cdbMain=cdbMain, bbox_type=c.CDB_SCHEMA_EXT_TYPE, extents_wkt_2d_poly=None)

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

    # Get the crs_id stored in the selected {cdb_schema}
    srid: int = sql.fetch_cdb_schema_srid(cdbMain)

    # Format CRS variable as QGIS EPSG code.
    crs: str = ":".join(["EPSG", str(srid)]) # e.g. EPSG:28992
    # Store the crs into the plugin variable
    dlg.CRS = QgsCoordinateReferenceSystem(crs)

    # Draw the cdb extents in the canvas
    # First, create polygon rubber band corresponding to the cdb_schema extents
    canvas.insert_rubber_band(band=dlg.RUBBER_CDB_SCHEMA_C, extents=dlg.CDB_SCHEMA_EXTENTS, crs=dlg.CRS, width=3, color=c.CDB_EXTENTS_COLOUR)

    # First, create polygon rubber band corresponding to the cdb_schema extents
    canvas.insert_rubber_band(band=dlg.RUBBER_DELETE_C, extents=dlg.DELETE_EXTENTS, crs=dlg.CRS, width=3, color=c.DELETE_EXTENTS_COLOUR)

    # Then update canvas with cdb_schema extents and crs, this fires the gbcExtent event
    canvas.canvas_setup(cdbMain=cdbMain, canvas=dlg.CANVAS_C, extents=dlg.CURRENT_EXTENTS, crs=dlg.CRS, clear=True)

    # Zoom to the cdb_schema extents (blue box)
    canvas.zoom_to_extents(canvas=dlg.CANVAS_C, extents=dlg.CDB_SCHEMA_EXTENTS)

    return None


####################################################
## Reset widget functions for 'User Connection' tab
####################################################

def tabConnection_reset(cdbMain: CDBToolsMain) -> None:
    """Function to reset the 'Connection' tab.
    Resets: gbxConnStatusC and gbxDatabase.
    """
    dlg = cdbMain.deleter_dlg

    gbxDatabase_reset(cdbMain)
    gbxConnStatus_reset(cdbMain)

    gbxCleanUpSchema_reset(cdbMain)
    gbxBasemapC_reset(cdbMain)
    gbxFeatSel_reset(cdbMain)
    
    dlg.btnCloseConnC.setDisabled(True)

    # # Close the current open connection.
    # if cdbMain.conn is not None:
    #     cdbMain.conn.close()

    return None


def gbxDatabase_reset(cdbMain: CDBToolsMain) -> None:
    """Function to reset the 'Database' groupbox (in Connection tab).
    """
    dlg = cdbMain.deleter_dlg

    dlg.cbxSchema.clear()
    dlg.cbxSchema.setDisabled(True)
    dlg.lblSchema.setDisabled(True)

    return None


def gbxCleanUpSchema_reset(cdbMain: CDBToolsMain) -> None:
    """Function to reset the 'Connection status' groupbox
    """
    dlg = cdbMain.deleter_dlg

    dlg.gbxCleanUpSchema.setChecked(False)
    dlg.gbxCleanUpSchema.setDisabled(True)

    dlg.btnCleanUpSchema.setText(dlg.btnCleanUpSchema.init_text)

    return None


def gbxBasemapC_reset(cdbMain: CDBToolsMain) -> None:
    """Function to reset the 'Basemap (OSM)' groupbox
    """
    dlg = cdbMain.deleter_dlg

    dlg.gbxBasemapC.setChecked(False)
    dlg.gbxBasemapC.setDisabled(True)

    # Reset the button text to initial values
    dlg.btnRefreshCDBExtents.setText(dlg.btnRefreshCDBExtents.init_text)
    dlg.btnCityExtents.setText(dlg.btnCityExtents.init_text)

    # Remove extent rubber bands.
    dlg.RUBBER_CDB_SCHEMA_C.reset()
    dlg.RUBBER_DELETE_C.reset()

    # Clear map registry from OSM layers.
    registryLayers = [i.id() for i in QgsProject.instance().mapLayers().values() if c.OSM_NAME == i.name()]
    QgsProject.instance().removeMapLayers(registryLayers)
    # Refresh to show to re-render the canvas (as empty).
    dlg.CANVAS_C.refresh()

    return None


def gbxFeatSel_reset(cdbMain: CDBToolsMain) -> None:
    """Function to reset the 'Feature Selection' groupbox (in 'User Connection' tab).
    """
    dlg = cdbMain.deleter_dlg

    dlg.gbxFeatType.setChecked(False)
    dlg.gbxRootClass.setChecked(False)
    gbxFeatType_reset(cdbMain)
    gbxRootClass_reset(cdbMain)

    dlg.gbxFeatSel.setChecked(False)
    dlg.gbxFeatSel.setDisabled(True)

    dlg.btnDelSelFeatures.setDisabled(True)

    # dlg.ckbAddSpatialFilter.setChecked(False)

    return None


def gbxFeatType_reset(cdbMain: CDBToolsMain) -> None:
    """Function to reset the 'Feature Type' groupbox (in 'User Connection' tab).
    """
    dlg = cdbMain.deleter_dlg

    dlg.gbxFeatType.setDisabled(True)
    dlg.ccbxFeatType.clear() # This clears also the default text
    dlg.ckbFeatTypeAll.setChecked(False)
    dlg.ccbxFeatType.setDefaultText('Select feature type(s)')
    dlg.ccbxFeatType.setDisabled(True)

    return None


def gbxRootClass_reset(cdbMain: CDBToolsMain) -> None:
    """Function to reset the 'Root-Class Feature' groupbox (in 'User Connection' tab).
    """
    dlg = cdbMain.deleter_dlg

    dlg.gbxRootClass.setDisabled(True)
    dlg.ccbxRootClass.clear() # This clears also the default text
    dlg.ckbRootClassAll.setChecked(False)
    dlg.ccbxRootClass.setDefaultText('Select root-class feature(s)')
    dlg.ccbxRootClass.setDisabled(True)
    
    return None


def gbxConnStatus_reset(cdbMain: CDBToolsMain) -> None:
    """Function to reset the 'Connection status' groupbox
    """
    dlg = cdbMain.deleter_dlg

    dlg.gbxConnStatusC.setDisabled(True)
    dlg.lblConnToDbC_out.clear()
    dlg.lblPostInstC_out.clear()
    dlg.lbl3DCityDBInstC_out.clear()
    dlg.lblMainInstC_out.clear()
    dlg.lblUserInstC_out.clear()

    return None


def workaround_gbxFeatType(cdbMain: CDBToolsMain) -> None:
    ##########################################
    # This is to take care of a bizarre behaviour of 
    # the groupbox not keeping the status of the child
    # combobox that gets activated once we add items
    ##########################################
    dlg = cdbMain.deleter_dlg

    dlg.ccbxFeatType.setDisabled(False)
    dlg.gbxFeatType.setDisabled(False)
    dlg.ccbxFeatType.setDisabled(True)
    dlg.gbxFeatType.setDisabled(True)

    return None


def workaround_gbxRootClass(cdbMain: CDBToolsMain) -> None:
    ##########################################
    # This is to take care of a bizarre behaviour of 
    # the groupbox not keeping the status of the child
    # combobox that gets activated once we add items
    ##########################################
    dlg = cdbMain.deleter_dlg

    dlg.ccbxRootClass.setDisabled(False)
    dlg.gbxRootClass.setDisabled(False)
    dlg.ccbxRootClass.setDisabled(True)
    dlg.gbxRootClass.setDisabled(True)

    return None
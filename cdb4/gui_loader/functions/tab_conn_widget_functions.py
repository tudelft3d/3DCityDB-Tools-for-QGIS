"""This module contains reset functions for each QT widgets.

The logic behind all of the functions is to reset widgets as individual
objects or as block of objects, depending on the needs.

The reset functions consist of clearing text or changed text to original state,
clearing widget items or selections and deactivating widgets.
"""
from qgis.core import QgsProject, QgsGeometry, QgsRectangle, QgsCoordinateReferenceSystem

from ....cdb_tools_main import CDBToolsMain # Used only to add the type of the function parameters

from ...shared.functions import general_functions as gen_f

from ..other_classes import FeatureType
from .. import loader_constants as c

from . import canvas, sql

FILE_LOCATION = gen_f.get_file_relative_path(file=__file__)

####################################################
## Setup widget functions for 'User Connection' tab
####################################################

def gbxBasemapC_setup(cdbMain: CDBToolsMain) ->  None:
    """Function to setup the 'Basemap' groupbox.
    It uses an additional canvas instance to store an OSM map from which extents can be extracted
    for further spatial queries.
    The basemap is zoomed-in to the cdb_extent (i.e. the extents of the whole city model).
    """
    dlg = cdbMain.loader_dlg
    cdb_extents_wkt: str = None

    while not cdb_extents_wkt:

        # Get the extents stored in server.
        cdb_extents_wkt: str = sql.fetch_precomputed_extents(cdbMain, usr_schema=cdbMain.USR_SCHEMA, cdb_schema=cdbMain.CDB_SCHEMA, ext_type=c.CDB_SCHEMA_EXT_TYPE)

        # Extents could be None (not computed yet).
        if not cdb_extents_wkt:
            # There are no precomputed extents for the cdb_schema, so compute them "for real" (bbox of all cityobjects)'.
            # This function automatically upsert the bbox to the table of the precomputed extents in the usr_schema
            sql.exec_upsert_extents(cdbMain=cdbMain, bbox_type=c.CDB_SCHEMA_EXT_TYPE, extents_wkt_2d_poly=None)

    # Check whether the layer extents were already computed and stored in the database before
    layer_extents_wkt: str = None
    layer_extents_wkt = sql.fetch_precomputed_extents(cdbMain, usr_schema=cdbMain.USR_SCHEMA, cdb_schema=cdbMain.CDB_SCHEMA, ext_type=c.LAYER_EXT_TYPE)
   
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

    # Get the crs_id stored in the selected {cdb_schema}
    srid: int = sql.fetch_cdb_schema_srid(cdbMain)

    # Format CRS variable as QGIS Epsg code.
    crs: str = ":".join(["EPSG", str(srid)]) # e.g. EPSG:28992
    # Storethe crs into the plugin variable
    dlg.CRS = QgsCoordinateReferenceSystem(crs)

    # Draw the cdb extents in the canvas
    # First, create polygon rubber band corresponding to the cdb_schema extents
    canvas.insert_rubber_band(band=dlg.RUBBER_CDB_SCHEMA_C, extents=dlg.CDB_SCHEMA_EXTENTS, crs=dlg.CRS, width=3, color=c.CDB_EXTENTS_COLOUR)

    # First, create polygon rubber band corresponding to the cdb_schema extents
    canvas.insert_rubber_band(band=dlg.RUBBER_LAYERS_C, extents=dlg.LAYER_EXTENTS, crs=dlg.CRS, width=3, color=c.LAYER_EXTENTS_COLOUR)

    # Then update canvas with cdb_schema extents and crs, this fires the gbcExtent event (of C or L)
    canvas.canvas_setup(cdbMain=cdbMain, canvas=dlg.CANVAS_C, extents=dlg.CURRENT_EXTENTS, crs=dlg.CRS, clear=True)

    # Zoom to the cdb_schema extents
    canvas.zoom_to_extents(canvas=dlg.CANVAS_C, extents=dlg.CDB_SCHEMA_EXTENTS)

    return None


####################################################
## Reset widget functions for 'User Connection' tab
####################################################

def tabConnection_reset(cdbMain: CDBToolsMain) -> None:
    """Function to reset the 'Connection' tab.
    Resets: gbxConnStatusC and gbxDatabase.
    """
    dlg = cdbMain.loader_dlg

    # Close the current open connection.
    if cdbMain.conn is not None:
        cdbMain.conn.close()

    gbxDatabase_reset(cdbMain)
    gbxConnStatus_reset(cdbMain)
    gbxBasemapC_reset(cdbMain)
    gbxFeatSel_reset(cdbMain)
    
    btnCreateLayers_reset(cdbMain)
    dlg.gbxFeatSel.setDisabled(True)

    btnRefreshLayers_reset(cdbMain)
    btnDropLayers_reset(cdbMain)
    dlg.btnCloseConnC.setDisabled(True)


def gbxDatabase_reset(cdbMain: CDBToolsMain) -> None:
    """Function to reset the 'Database' groupbox (in Connection tab).
    """
    dlg = cdbMain.loader_dlg

    dlg.cbxSchema.clear()
    dlg.cbxSchema.setDisabled(True)
    dlg.lblSchema.setDisabled(True)


def gbxConnStatus_reset(cdbMain: CDBToolsMain) -> None:
    """Function to reset the 'Connection status' groupbox
    """
    dlg = cdbMain.loader_dlg

    dlg.gbxConnStatusC.setDisabled(True)
    dlg.lblConnToDbC_out.clear()
    dlg.lblPostInstC_out.clear()
    dlg.lbl3DCityDBInstC_out.clear()
    dlg.lblMainInstC_out.clear()
    dlg.lblUserInstC_out.clear()
    dlg.lblLayerExist_out.clear()
    dlg.lblLayerRefr_out.clear()


def gbxBasemapC_reset(cdbMain: CDBToolsMain) -> None:
    """Function to reset the 'Basemap (OSM)' groupbox
    """
    dlg = cdbMain.loader_dlg

    dlg.gbxBasemapC.setDisabled(True)
    dlg.btnRefreshCDBExtents.setText(dlg.btnRefreshCDBExtents.init_text)
    dlg.btnCityExtents.setText(dlg.btnCityExtents.init_text)

    # Remove extent rubber bands.
    dlg.RUBBER_CDB_SCHEMA_C.reset()
    dlg.RUBBER_LAYERS_C.reset()
    dlg.RUBBER_QGIS_L.reset()

    # Clear map registry from OSM layers.
    registryLayers = [i.id() for i in QgsProject.instance().mapLayers().values() if c.OSM_NAME == i.name()]
    QgsProject.instance().removeMapLayers(registryLayers)
    # Refresh to show to re-render the canvas (as empty).
    dlg.CANVAS_C.refresh()


def gbxFeatSel_reset(cdbMain: CDBToolsMain) -> None:
    """Function to reset the 'Feature Selection' groupbox (in 'User Connection' tab).
    """
    dlg = cdbMain.loader_dlg

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


def btnCreateLayers_reset(cdbMain: CDBToolsMain) -> None:
    """Function to reset the 'Create layers' pushButton (in 'User Connection' tab).
    """
    dlg = cdbMain.loader_dlg

    dlg.btnCreateLayers.setDisabled(True)
    dlg.btnCreateLayers.setText(dlg.btnCreateLayers.init_text)


def btnRefreshLayers_reset(cdbMain: CDBToolsMain) -> None:
    """Function to reset the 'Refresh layers' pushButton (in 'User Connection' tab).
    """
    dlg = cdbMain.loader_dlg

    dlg.btnRefreshLayers.setDisabled(True)
    dlg.btnRefreshLayers.setText(dlg.btnRefreshLayers.init_text)


def btnDropLayers_reset(cdbMain: CDBToolsMain) -> None:
    """Function to reset the 'Drop layers' pushButton (in 'User Connection' tab).
    """
    dlg = cdbMain.loader_dlg

    dlg.btnDropLayers.setDisabled(True)
    # dlg.btnDropLayers.setText(dlg.btnDropLayers.init_text)



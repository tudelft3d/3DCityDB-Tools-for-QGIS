"""This module contains reset functions for each QT widget in the GUI of the
plugin.

The logic behind all of the functions is to reset widgets as individual
objects or as block of objects, depending on the needs.

These function help declutter the widget_setup.py from repetitive code.

The reset functions consist of clearing text or changed text to original state,
clearing widget items or selections and deactivating widgets.
"""

from qgis.core import QgsProject, QgsRectangle, QgsCoordinateReferenceSystem
from qgis.PyQt.QtCore import Qt
import psycopg2


from ....cdb_loader import CDBLoader # Used only to add the type of the function parameters
#from ..cdb4_loader_dialog import CDB4LoaderDialog # Used only to add the type of the function parameters

from ...shared.functions import general_functions as gen_f
from ... import cdb4_constants as c

from . import canvas, sql

FILE_LOCATION = gen_f.get_file_relative_path(file=__file__)

####################################################
## Setup widget functions for 'User Connection' tab
####################################################

# In 'Basemap (OMS)' groupBox.
def gbxBasemapC_setup(cdbLoader: CDBLoader) ->  None:
    """Function to setup the 'Basemap' groupbox.
    It uses an additional canvas instance to store an OSM map from which extents can be extracted
    for further spatial queries.
    The basemap is zoomed-in to the cdb_extent (i.e. the extents of the whole city model).
    """
    dlg = cdbLoader.loader_dlg
    try:
        extents_exist: bool = False

        while not extents_exist:

            # Get the extents stored in server.
            cdb_extents_wkt: str = sql.fetch_precomputed_extents(cdbLoader, usr_schema=cdbLoader.USR_SCHEMA, cdb_schema=cdbLoader.CDB_SCHEMA, ext_type=c.CDB_SCHEMA_EXT_TYPE)

            # Extents could be None (not computed yet). In the case, see the else
            if cdb_extents_wkt:
                extents_exist = True
                cdb_extents: QgsRectangle = QgsRectangle().fromWkt(cdb_extents_wkt)

                # Get the crs_id stored in the selected {cdb_schema}
                srid: int = sql.fetch_cdb_schema_srid(cdbLoader)
                # Format CRS variable as QGIS Epsg code.
                crs: str = ":".join(["EPSG", str(srid)]) # e.g. EPSG:28992

                # Assign the crs into the plugin variable
                dlg.CRS = QgsCoordinateReferenceSystem(crs)
                # Store the extents into plugin variables.
                dlg.CURRENT_EXTENTS = cdb_extents
                dlg.CDB_SCHEMA_EXTENTS_BLUE = cdb_extents

                # Draw the cdb extents in the canvas
                # First, create polygon rubber band corresponding to the cdb_schema extents
                canvas.insert_rubber_band(band=dlg.RUBBER_CDB_SCHEMA_BLUE_C, extents=dlg.CDB_SCHEMA_EXTENTS_BLUE, crs=dlg.CRS, width=3, color=Qt.blue)

                # Then update canvas with cdb_schema extents and crs
                canvas.canvas_setup(cdbLoader=cdbLoader, canvas=dlg.CANVAS_C, extents=dlg.CDB_SCHEMA_EXTENTS_BLUE, crs=dlg.CRS, clear=True)

                # Zoom to the cdb_schema extents (blue box)
                canvas.zoom_to_extents(canvas=dlg.CANVAS_C, extents=dlg.CDB_SCHEMA_EXTENTS_BLUE)

            else: 
                # There are no precomputed extents for the cdb_schema, so compute them "for real" (bbox of all cityobjects)'.
                # This function automatically upsert the bbox to the table of the precomputed extents in the usr_schema
                sql.exec_upsert_extents(cdbLoader=cdbLoader, usr_schema=cdbLoader.USR_SCHEMA, cdb_schema=cdbLoader.CDB_SCHEMA, bbox_type=c.CDB_SCHEMA_EXT_TYPE, extents_wkt_2d_poly=None)

                # Check that it has been actually done, i.e. the cdb_extents are now available to be read in the next iteration.
                cdb_extents_test: str = sql.fetch_precomputed_extents(cdbLoader=cdbLoader, usr_schema=cdbLoader.USR_SCHEMA, cdb_schema=cdbLoader.CDB_SCHEMA, ext_type=c.CDB_SCHEMA_EXT_TYPE)
                if not cdb_extents_test:
                    raise Exception(f'Function {cdbLoader.QGIS_PKG_SCHEMA}.compute_cdb_schema_extents() returned: None')

    except (Exception, psycopg2.Error) as error:
        # Send error to QGIS Message Log panel.
        gen_f.critical_log(
            func=gbxBasemapC_setup,
            location=FILE_LOCATION,
            header=f"Retrieving extents of schema {cdbLoader.CDB_SCHEMA}",
            error=error)
        cdbLoader.conn.rollback()
        return False


####################################################
## Reset widget functions for 'User Connection' tab
####################################################

def tabConnection_reset(cdbLoader: CDBLoader) -> None:
    """Function to reset the 'Connection' tab.
    Resets: gbxConnStatusC and gbxDatabase.
    """
    dlg = cdbLoader.loader_dlg

    # Close the current open connection.
    if cdbLoader.conn is not None:
        cdbLoader.conn.close()

    gbxDatabase_reset(cdbLoader)
    gbxConnStatus_reset(cdbLoader)
    gbxBasemapC_reset(cdbLoader)
    btnCreateLayers_reset(cdbLoader)
    btnRefreshLayers_reset(cdbLoader)
    btnDropLayers_reset(cdbLoader)
    dlg.btnCloseConnC.setDisabled(True)


def gbxDatabase_reset(cdbLoader: CDBLoader) -> None:
    """Function to reset the 'Database' groupbox (in Connection tab).
    """
    dlg = cdbLoader.loader_dlg

    dlg.cbxSchema.clear()
    dlg.cbxSchema.setDisabled(True)
    dlg.lblSchema.setDisabled(True)


def gbxConnStatus_reset(cdbLoader: CDBLoader) -> None:
    """Function to reset the 'Connection status' groupbox
    """
    dlg = cdbLoader.loader_dlg

    dlg.gbxConnStatusC.setDisabled(True)
    dlg.lblConnToDbC_out.clear()
    dlg.lblPostInstC_out.clear()
    dlg.lbl3DCityDBInstC_out.clear()
    dlg.lblMainInstC_out.clear()
    dlg.lblUserInstC_out.clear()
    dlg.lblLayerExist_out.clear()
    dlg.lblLayerRefr_out.clear()


def gbxBasemapC_reset(cdbLoader: CDBLoader) -> None:
    """Function to reset the 'Basemap (OSM)' groupbox
    """
    dlg = cdbLoader.loader_dlg

    dlg.gbxBasemapC.setDisabled(True)
    dlg.btnRefreshCDBExtents.setText(dlg.btnRefreshCDBExtents.init_text)
    dlg.btnCityExtentsC.setText(dlg.btnCityExtentsC.init_text)

    # Remove extent rubber bands.
    dlg.RUBBER_CDB_SCHEMA_BLUE_C.reset()
    dlg.RUBBER_LAYERS_RED_C.reset()
    dlg.RUBBER_QGIS_GREEN_L.reset()

    # Clear map registry from OSM layers.
    registryLayers = [i.id() for i in QgsProject.instance().mapLayers().values() if c.OSM_NAME == i.name()]
    QgsProject.instance().removeMapLayers(registryLayers)
    # Refresh to show to re-render the canvas (as empty).
    dlg.CANVAS_C.refresh()


def cgbxOptions_reset(cdbLoader: CDBLoader) -> None:
    """Function to reset the 'Advanced option' groupbox (in 'User Connection' tab).
    """
    dlg = cdbLoader.loader_dlg

    #dlg.cgbxOptions.setCollapsed(True)
    #dlg.cgbxOptions.setDisabled(True)
    gbxSimplifyGeom_reset(cdbLoader)


def gbxSimplifyGeom_reset(cdbLoader: CDBLoader) -> None:
    """Function to reset the 'Simplify geometries' groupbox (in 'User Connection' tab).
    """
    dlg = cdbLoader.loader_dlg

    #dlg.gbxSimplifyGeom.setChecked(False)
    dlg.qspbDecimalPrec.setValue(dlg.settings.simp_geom_dec_prec)
    dlg.qspbMinArea.setValue(dlg.settings.simp_geom_min_area)


def btnCreateLayers_reset(cdbLoader: CDBLoader) -> None:
    """Function to reset the 'Create layers' pushButton (in 'User Connection' tab).
    """
    dlg = cdbLoader.loader_dlg

    dlg.btnCreateLayers.setDisabled(True)
    dlg.btnCreateLayers.setText(dlg.btnCreateLayers.init_text)


def btnRefreshLayers_reset(cdbLoader: CDBLoader) -> None:
    """Function to reset the 'Refresh layers' pushButton (in 'User Connection' tab).
    """
    dlg = cdbLoader.loader_dlg

    dlg.btnRefreshLayers.setDisabled(True)
    dlg.btnRefreshLayers.setText(dlg.btnRefreshLayers.init_text)


def btnDropLayers_reset(cdbLoader: CDBLoader) -> None:
    """Function to reset the 'Drop layers' pushButton (in 'User Connection' tab).
    """
    dlg = cdbLoader.loader_dlg

    dlg.btnDropLayers.setDisabled(True)
    dlg.btnDropLayers.setText(dlg.btnDropLayers.init_text)


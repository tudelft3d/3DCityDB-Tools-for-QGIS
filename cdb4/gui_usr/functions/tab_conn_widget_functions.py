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

from ... import cdb4_constants as c

from . import canvas, sql

FILE_LOCATION = c.get_file_relative_path(file=__file__)

####################################################
## Setup widget functions for 'User Connection' tab
####################################################

# In 'Basemap (OMS)' groupBox.
def gbxBasemapC_setup(cdbLoader: CDBLoader, canvas_widget) ->  None:
    """Function to setup the 'Basemap' groupbox.
    It uses an additional canvas instance to store an OSM map
    from which extents can be extracted for further spatial queries.

    The basemap is zoomed-in to the city model's extents.
    """

    try:
        extents_exist = False
        while not extents_exist:

            # Get the extents stored in server.
            extents = sql.fetch_extents(
                cdbLoader,
                usr_schema=cdbLoader.USR_SCHEMA,
                cdb_schema=cdbLoader.CDB_SCHEMA,
                ext_type=c.CDB_SCHEMA_EXT_TYPE)

            # Extents might be None (not computed yet).
            if extents:
                extents_exist = True

                # Get the crs stored in the selected {cdb_schema}
                crs = sql.fetch_crs(cdbLoader)

                # Format CRS variable as QGIS Epsg code.
                crs = ":".join(["EPSG",str(crs)]) # e.g. EPSG:28992
                cdbLoader.CRS = QgsCoordinateReferenceSystem(crs)

                # Store extents into plugin variables.
                cdbLoader.CURRENT_EXTENTS = QgsRectangle.fromWkt(extents)
                cdbLoader.CDB_SCHEMA_EXTENTS = QgsRectangle.fromWkt(extents)

                # # Draw the extents in the canvas
                # # Create polygon rubber band corresponding to the extents
                canvas.insert_rubber_band(
                    band=cdbLoader.RUBBER_SCHEMA_C,
                    extents=cdbLoader.CDB_SCHEMA_EXTENTS,
                    crs=cdbLoader.CRS,
                    width=3,
                    color=Qt.blue)
                
                # Update canvas with schema extents and crs
                canvas.canvas_setup(
                    cdbLoader,
                    canvas=canvas_widget,
                    extents=cdbLoader.CDB_SCHEMA_EXTENTS,
                    crs=cdbLoader.CRS)

                # Put extents coordinates into the widget.
                #dbLoader.usr_dlg.qgbxExtentsC.setOutputExtentFromUser(dbLoader.CDB_SCHEMA_EXTENTS,dbLoader.CRS)

                # Zoom to these extents.
                canvas_widget.zoomToFeatureExtent(cdbLoader.CDB_SCHEMA_EXTENTS)
            
            else: # Compute the extents.
                sql.exec_compute_schema_extents(cdbLoader)
                if not sql.fetch_extents(
                            cdbLoader,
                            usr_schema=cdbLoader.USR_SCHEMA,
                            cdb_schema=cdbLoader.CDB_SCHEMA,
                            ext_type=c.CDB_SCHEMA_EXT_TYPE):
                    raise Exception('Function {c.MAIN_PKG_NAME}.compute_schema_extent() returned: None')

    except (Exception, psycopg2.Error) as error:
        # Send error to QGIS Message Log panel.
        c.critical_log(
            func=gbxBasemapC_setup,
            location=FILE_LOCATION,
            header="Retrieving extents",
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

    # Close the current open connection.
    if cdbLoader.conn is not None:
        cdbLoader.conn.close()

    gbxDatabase_reset(cdbLoader)
    gbxConnStatus_reset(cdbLoader)
    gbxBasemapC_reset(cdbLoader)
    cgbxOptions_reset(cdbLoader)
    btnCreateLayers_reset(cdbLoader)
    btnRefreshLayers_reset(cdbLoader)
    btnDropLayers_reset(cdbLoader)
    cdbLoader.usr_dlg.btnCloseConnC.setDisabled(True)


def gbxDatabase_reset(cdbLoader: CDBLoader) -> None:
    """Function to reset the 'Database' groupbox (in Connection tab)."""

    cdbLoader.usr_dlg.cbxSchema.clear()
    cdbLoader.usr_dlg.cbxSchema.setDisabled(True)
    cdbLoader.usr_dlg.lblSchema.setDisabled(True)


def gbxConnStatus_reset(cdbLoader: CDBLoader) -> None:
    """Function to reset the 'Connection status' groupbox
    """

    cdbLoader.usr_dlg.gbxConnStatusC.setDisabled(True)
    cdbLoader.usr_dlg.lblConnToDbC_out.clear()
    cdbLoader.usr_dlg.lblPostInstC_out.clear()
    cdbLoader.usr_dlg.lbl3DCityDBInstC_out.clear()
    cdbLoader.usr_dlg.lblMainInstC_out.clear()
    cdbLoader.usr_dlg.lblUserInstC_out.clear()
    cdbLoader.usr_dlg.lblSupport_out.clear()
    cdbLoader.usr_dlg.lblLayerRefr_out.clear()


def gbxBasemapC_reset(cdbLoader: CDBLoader) -> None:
    """Function to reset the 'Basemap (OSM)' groupbox
    """

    cdbLoader.usr_dlg.gbxBasemapC.setDisabled(True)
    cdbLoader.usr_dlg.btnCityExtentsC.setText(cdbLoader.usr_dlg.btnCityExtentsC.init_text)

    # Remove extent rubber bands.
    cdbLoader.RUBBER_SCHEMA_C.reset()
    cdbLoader.RUBBER_LAYERS_C.reset()
    cdbLoader.RUBBER_USER.reset()

    # Clear map registry from OSM layers.
    registryLayers = [i.id() for i in QgsProject.instance().mapLayers().values() if c.OSM_NAME == i.name()]
    QgsProject.instance().removeMapLayers(registryLayers)
    # Refresh to show to re-render the canvas (as empty).
    cdbLoader.CANVAS_C.refresh()


def cgbxOptions_reset(cdbLoader: CDBLoader) -> None:
    """Function to reset the 'Advanced option' groupbox
    (in 'User Connection' tab).
    """
    cdbLoader.usr_dlg.cgbxOptions.setCollapsed(True)
    cdbLoader.usr_dlg.cgbxOptions.setDisabled(True)
    gbxSimplifyGeom_reset(cdbLoader)


def gbxSimplifyGeom_reset(cdbLoader: CDBLoader) -> None:
    """Function to reset the 'Simplify geometries' groupbox
    (in 'User Connection' tab).
    """
    cdbLoader.usr_dlg.gbxSimplifyGeom.setChecked(False)
    cdbLoader.usr_dlg.qspbDecimalPrec.setValue(c.DEC_PREC)
    cdbLoader.usr_dlg.qspbMinArea.setValue(c.MIN_AREA)


def btnCreateLayers_reset(cdbLoader: CDBLoader) -> None:
    """Function to reset the 'Create layers' pushButton (in 'User Connection' tab)."""

    cdbLoader.usr_dlg.btnCreateLayers.setDisabled(True)
    cdbLoader.usr_dlg.btnCreateLayers.setText(cdbLoader.usr_dlg.btnCreateLayers.init_text)


def btnRefreshLayers_reset(cdbLoader: CDBLoader) -> None:
    """Function to reset the 'Refresh layers' pushButton (in 'User Connection' tab)."""

    cdbLoader.usr_dlg.btnRefreshLayers.setDisabled(True)
    cdbLoader.usr_dlg.btnRefreshLayers.setText(cdbLoader.usr_dlg.btnRefreshLayers.init_text)


def btnDropLayers_reset(cdbLoader: CDBLoader) -> None:
    """Function to reset the 'Drop layers' pushButton (in 'User Connection' tab)."""

    cdbLoader.usr_dlg.btnDropLayers.setDisabled(True)
    cdbLoader.usr_dlg.btnDropLayers.setText(cdbLoader.usr_dlg.btnDropLayers.init_text)


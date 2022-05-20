from qgis.core import QgsRectangle, QgsCoordinateReferenceSystem
from qgis.core import QgsGeometry
from qgis.PyQt.QtCore import Qt
from qgis.PyQt.QtWidgets import QMessageBox
import psycopg2

from .. import constants as c
from .. import connection
from ..proc_functions import pf_userconn_tab as usr_tab
from ..proc_functions import threads, sql, canvas
from . import ws_layers_tab as lrs_setup
from . import widget_reset

FILE_LOCATION = c.get_file_location(file=__file__)

# In 'Connection' groupBox.
def cbxExistingConnC_setup(dbLoader) -> None:
    """Function to setup the gui after a change signal is emitted from
    the cbxExistingConnC comboBox.

    This function runs every time the current selection of 'Existing Connection'
    changes.

    (in 'User Connection' tab)
    """

    # Variable to store the plugin's main dialog
    dlg = dbLoader.dlg

    widget_reset.reset_tabConnection(dbLoader)

    dlg.gbxDatabase.setDisabled(False)
    dlg.btnConnectToDbC.setText(dlg.btnConnectToDbC.init_text.format(db=dbLoader.DB.database_name))
    dlg.btnConnectToDbC.setDisabled(False)
    dlg.lblConnectToDB.setDisabled(False)


    # Close the current open connection.
    if dbLoader.conn is not None:
        dbLoader.conn.close()

    widget_reset.reset_tabLayers(dbLoader)
    #widget_reset.reset_tabDbAdmin(dbLoader)

# In 'Database' groupBox.
def btnConnectToDbC_setup(dbLoader) -> None:
    """Function to setup the gui after a click signal is emitted from
    the btnConnectToDbC pushButton.

    This function runs every time the 'Connect to {db}' button is pressed.

    (in 'User Connection' tab)
    """

    # Variable to store the plugin's main dialog.
    dlg = dbLoader.dlg

    #In 'Connection Status' groupbox
    dlg.gbxConnStatusC.setDisabled(False)
    dlg.btnCloseConnC.setDisabled(False)

    # Attempt to connect to the database
    successful_connection = connection.open_connection(dbLoader)

    if successful_connection:
        # Show database name
        dlg.lblConnToDbC_out.setText(c.success_html.format(
            text=dbLoader.DB.database_name))
        dbLoader.DB.green_db_conn = True

        if dbLoader.DB.s_version is not None:
            # Show server version
            dlg.lblPostInstC_out.setText(c.success_html.format(
                text=dbLoader.DB.s_version))
            dbLoader.DB.green_post_inst=True
        else:
            dlg.lblPostInstC_out.setText(c.failure_html.format(
                text=c.POST_FAIL_MSG))
            dbLoader.DB.green_post_inst=True
            return None

        # Check that database has 3DCityDB installed.
        if usr_tab.is_3dcitydb(dbLoader):
            version_major = int(dbLoader.DB.c_version.split(".")[0])
            if version_major >= c.MIN_VERSION:
                # Show 3DCityDB version
                dlg.lbl3DCityDBInstC_out.setText(c.success_html.format(
                    text=dbLoader.DB.c_version))
                dbLoader.DB.green_citydb_inst = True
            else:
                dlg.lbl3DCityDBInstC_out.setText(c.crit_warning_html.format(
                    text=f"{dbLoader.DB.c_version} (minimum major version: {c.MIN_VERSION})"))
                dbLoader.DB.green_citydb_inst = False
                return None

        else:
            dlg.lbl3DCityDBInstC_out.setText(c.failure_html.format(
                text=c.CITYDB_FAIL_MSG))
            dbLoader.DB.green_citydb_inst = False
            return None

        # Check if main package (schema) is installed in database.
        has_main_inst = sql.has_main_pkg(dbLoader)
        if has_main_inst:
            dlg.lblMainInstC_out.clear()

            # Get qgis_pkg version.
            full_version = f"(v.{sql.exec_qgis_pkg_version(dbLoader)})"
            # Show message in Connection Status
            dlg.lblMainInstC_out.setText(c.success_html.format(text=" ".join([c.INST_MSG,full_version]).format(pkg=c.MAIN_PKG_NAME)))
            dbLoader.DB.green_main_inst = True
            # Enable schema comboBox
            dlg.cbxSchema.setDisabled(False)
            dlg.lblSchema.setDisabled(False)


            # Get schema name for user
            sql.exec_create_qgis_usr_schema_name(dbLoader)

            # Get 3DCityDB schemas from database
            #schemas = sql.exec_get_feature_schemas(dbLoader)
            schemas = sql.exec_list_cdb_schemas(dbLoader)

            # Fill schema combo box
            usr_tab.fill_schema_box(dbLoader, schemas=schemas)
            # At this point,filling the schema box, activates the 'evt_cbxSchema_changed' event.
            # So if you're following the code line by line, go to citydb_loader.py>evt_cbxSchema_changed or at 'cbxSchema_setup' function below
        else:
            dlg.lblMainInstC_out.setText(c.failure_html.format(text=c.INST_FAIL_MSG).format(pkg=c.MAIN_PKG_NAME))
            dbLoader.DB.green_main_inst = False
            return None



    else: # Connection failed!
        widget_reset.reset_gbxConnStatusC(dbLoader)
        dlg.gbxConnStatusC.setDisabled(False)

        dlg.lblConnToDbC_out.setText(c.failure_html.format(
            text=c.CONN_FAIL_MSG))
        dbLoader.DB.green_connection=False

        dlg.lblPostInstC_out.setText(c.failure_html.format(
            text=c.POST_FAIL_MSG))
        dbLoader.DB.green_s_version=False

        return None
    return None

def cbxSchema_setup(dbLoader) -> None:
    """Function to setup the gui after an 'indexChanged' signal is emitted from
    the cbxSchema combo box.

    This function runs every time the selected schema is changed.

    (in 'User Connection' tab)
    """

    # By now, the schema variable must have be assigned.
    if not dbLoader.dlg.cbxSchema.currentData():
        return None

    # Clear status of previous schema.
    dbLoader.dlg.lblUserInstC_out.clear()
    dbLoader.dlg.lblSupport_out.clear()
    dbLoader.dlg.lblLayerRefr_out.clear()

    dbLoader.dlg.btnRefreshLayers.setText(dbLoader.dlg.btnRefreshLayers.init_text.format(sch=dbLoader.SCHEMA))
    dbLoader.dlg.btnCityExtentsC.setText(dbLoader.dlg.btnCityExtentsC.init_text.format(sch=dbLoader.SCHEMA))
    dbLoader.dlg.btnCreateLayers.setText(dbLoader.dlg.btnCreateLayers.init_text.format(sch=dbLoader.SCHEMA))
    dbLoader.dlg.btnDropLayers.setText(dbLoader.dlg.btnDropLayers.init_text.format(sch=dbLoader.SCHEMA))



    # Check if user package (schema) is installed in database.
    has_user_inst = sql.has_user_pkg(dbLoader)
    if has_user_inst:
        dbLoader.dlg.lblUserInstC_out.setText(
            c.success_html.format(text=c.INST_MSG.format(pkg=dbLoader.USER_SCHEMA)))
        dbLoader.DB.green_user_inst = True

        dbLoader.dlg.gbxBasemapC.setDisabled(False)
        dbLoader.dlg.cgbxOptions.setDisabled(False)
        
        dbLoader.dlg.btnCreateLayers.setDisabled(False)
        

        # Setup the 'Basemap (OSM)' groupbox.
        gbxBasemapC_setup(dbLoader,dbLoader.CANVAS_C)
        # Check if there are precomputed layer extents in the database.
        mview_exts = sql.fetch_extents(dbLoader,
            from_schema=dbLoader.USER_SCHEMA,
            for_schema=dbLoader.SCHEMA,
            ext_type=c.MAT_VIEW_EXT_TYPE)
        if mview_exts:
            # Put extents coordinates into the widget. Singal emitted for qgbxExtentsC.
            dbLoader.dlg.qgbxExtentsC.setOutputExtentFromUser(QgsRectangle.fromWkt(mview_exts),dbLoader.CRS)


    else:
        dbLoader.dlg.lblUserInstC_out.setText(c.failure_html.format(text=c.INST_FAIL_MSG.format(
                pkg=dbLoader.USER_SCHEMA)))
        dbLoader.DB.green_user_inst = False
        return None

    # Check if user package has views corresponding to the current schema (layers).
    has_schema_support = sql.exec_support_for_schema(dbLoader)
    if has_schema_support:
        dbLoader.dlg.lblSupport_out.setText(
            c.success_html.format(text=c.SCHEMA_SUPP_MSG.format(
                sch=dbLoader.SCHEMA)))
        dbLoader.DB.green_schema_supp = True

        dbLoader.dlg.btnRefreshLayers.setDisabled(False)

        dbLoader.dlg.btnDropLayers.setDisabled(False)
        
    else:
        dbLoader.dlg.lblSupport_out.setText(c.failure_html.format(text=c.SCHEMA_SUPP_FAIL_MSG.format(
                sch=dbLoader.SCHEMA)))
        dbLoader.DB.green_schema_supp = False
        return None

    # Check if the materialised views are populated.
    refresh_date = sql.fetch_layer_metadata(dbLoader, from_schema=dbLoader.USER_SCHEMA,for_schema=dbLoader.SCHEMA,cols="refresh_date")
    # Extract a date.
    date =list(set(refresh_date[1]))[0][0]
    if date:
        dbLoader.dlg.lblLayerRefr_out.setText(
            c.success_html.format(text=c.REFR_LAYERS_MSG.format(
                date=date)))
        dbLoader.DB.green_refresh_date = True
    else:
        dbLoader.dlg.lblLayerRefr_out.setText(c.failure_html.format(text=c.REFR_LAYERS_FAIL_MSG))
        dbLoader.DB.green_refresh_date = False
        return None

    # Check that DB is configured correctly.
    if dbLoader.DB.meets_requirements():
        dbLoader.dlg.tabLayers.setDisabled(False)
        dbLoader.dlg.lblInfoText.setDisabled(False)
        dbLoader.dlg.lblInfoText.setText(dbLoader.dlg.lblInfoText.init_text.format(db=dbLoader.DB.database_name,
        usr=dbLoader.DB.username,sch=dbLoader.SCHEMA))
        dbLoader.dlg.gbxBasemap.setDisabled(False)
        dbLoader.dlg.qgbxExtents.setDisabled(False)
        dbLoader.dlg.btnCityExtents.setDisabled(False)
        dbLoader.dlg.btnCityExtents.setText(dbLoader.dlg.btnCityExtents.init_text.format(sch="layers extents"))
    
        lrs_setup.gbxBasemap_setup(dbLoader,dbLoader.CANVAS)

        # We are done here with the 'User Connection' tab.


# In 'Basemap (OMS)' groupBox.
def gbxBasemapC_setup(dbLoader,canvas_widget) ->  None:
    """Function to setup the 'Basemap' groupbox.
    It uses an additional canvas instance to store an OSM map
    from which extents can be extracted for further spatial queries.

    The basemap is zoomed-in the city model's entents.

    (in 'User Connection' tab)
    """

    try:
        extents_exist = False
        while not extents_exist:

            # Get the extents stored in server.
            extents = sql.fetch_extents(dbLoader,
                from_schema=dbLoader.USER_SCHEMA,
                for_schema=dbLoader.SCHEMA,
                ext_type=c.SCHEMA_EXT_TYPE)

            # Extents might be None (not computed yet).
            if extents:
                extents_exist = True

                # Get the crs stored in server.
                crs = sql.fetch_crs(dbLoader)

                # Format CRS variable as QGIS epsg code.
                crs = ":".join(["EPSG",str(crs)]) # e.g. EPSG:28992
                dbLoader.CRS = QgsCoordinateReferenceSystem(crs)


                # Store extents into plugin variables.
                dbLoader.EXTENTS = QgsRectangle.fromWkt(extents)
                dbLoader.SCHEMA_EXTENTS = QgsRectangle.fromWkt(extents)

                # # Draw the extents in the canvas
                # # Create polygon rubber band corespoding to the extents
                canvas.insert_rubber_band(band=dbLoader.RUBBER_SCHEMA_C,
                    extents=dbLoader.SCHEMA_EXTENTS,
                    crs=dbLoader.CRS,
                    width=3,
                    color=Qt.blue)
                
                # Update canvas with schema extents and crs
                canvas.canvas_setup(dbLoader,
                    canvas=canvas_widget,
                    extents=dbLoader.SCHEMA_EXTENTS,
                    crs=dbLoader.CRS)

                # Put extents coordinates into the widget.
                #dbLoader.dlg.qgbxExtentsC.setOutputExtentFromUser(dbLoader.SCHEMA_EXTENTS,dbLoader.CRS)

                # Zoom to these extents.
                canvas_widget.zoomToFeatureExtent(dbLoader.SCHEMA_EXTENTS)
            
            else: # Compute the extents.
                sql.exec_compute_schema_extents(dbLoader)
                if not sql.fetch_extents(dbLoader,
                    from_schema=dbLoader.USER_SCHEMA,
                    for_schema=dbLoader.SCHEMA,
                    ext_type=c.SCHEMA_EXT_TYPE):
                    raise Exception('compute_schema_extent server function returned None')


    except (Exception, psycopg2.Error) as error:

        # Send error to QGIS Message Log panel.
        c.critical_log(func=gbxBasemapC_setup,
            location=FILE_LOCATION,
            header="Fetching extents",
            error=error)
        dbLoader.conn.rollback()
        return False

def qgbxExtentsC_setup(dbLoader) -> None: 
    """Function to setup the gui after an extentChanged signal is emitted from
    one of the qgbxExtentsC's embedded pushbuttons.
    (e.g. 'Calculate from Layer', 'Map Canvas Extent','Draw on Canvas'*)
    Fills the 'Feature Type' widget.

    This function runs every time the extents in the widget change.

    (in 'Layers' tab)
    """
    # NOTE: 'Draw on Canvas'* has an undesired effect.
    # There is a hardcoded True value that causes the parent dialog to
    # toggle its visibility to let the user draw. But in our case
    # the parent dialog contains the canvas that we need to draw on.
    # Re-opening the plugin allows us to draw in the canvas but with the
    # caveat that the drawing tool never closes (also cause some qgis crashes).
    # https://github.com/qgis/QGIS/blob/master/src/gui/qgsextentgroupbox.cpp
    # https://github.com/qgis/QGIS/blob/master/src/gui/qgsextentwidget.h
    # line 251 extentDrawn function
    # https://qgis.org/pyqgis/3.16/gui/QgsExtentGroupBox.html
    # https://qgis.org/pyqgis/3.16/gui/QgsExtentWidget.html


    # Update extents variable with the ones that fired the signal.
    dbLoader.EXTENTS = dbLoader.dlg.qgbxExtentsC.outputExtent()
    if dbLoader.EXTENTS.isNull() or dbLoader.SCHEMA_EXTENTS.isNull():
        return None

    # Draw the extents in the addtional canvas (basemap)
    canvas.insert_rubber_band(band=dbLoader.RUBBER_LAYERS_C,
        extents=dbLoader.EXTENTS,
        crs=dbLoader.CRS,
        width=2,
        color=Qt.red)

    # Compare original extents with user defined ones.
    lrs_exts= QgsGeometry.fromRect(dbLoader.EXTENTS)
    orig_exts= QgsGeometry.fromRect(dbLoader.SCHEMA_EXTENTS)

    # Check validity of user extents relative to the City Model's extents.
    if not lrs_exts.intersects(orig_exts):
        QMessageBox.critical(dbLoader.dlg,
            "Warning",
            "No data can be found here!\n"
            f"Pick a region inside '{dbLoader.SCHEMA}' extents (blue area).")
        return None
    else:
        dbLoader.VIEWS_EXTENTS = dbLoader.EXTENTS

def btnCityExtentsC_setup(dbLoader) -> None:
    """Function to setup the gui after a click signal is emitted from
    the btnCityExtents pushButton.

    This function runs every time the 'Set to {sch} schema' button
    is pressed.

    (in 'User Connection' tab)
    """

    # Get the extents stored in server (already computed at this point).
    extents = sql.fetch_extents(dbLoader,
        from_schema=dbLoader.USER_SCHEMA,
        for_schema=dbLoader.SCHEMA,
        ext_type=c.SCHEMA_EXT_TYPE)
    assert extents, "Extents don't exist but should have been aleady computed!"

    # Convert extents format to QgsRectangle object.
    extents = QgsRectangle.fromWkt(extents)
    # Update extents in plugin variable.
    dbLoader.EXTENTS = extents

    # Put extents coordinates into the widget.
    dbLoader.dlg.qgbxExtentsC.setOutputExtentFromUser(dbLoader.EXTENTS,dbLoader.CRS)
    # At this point an extentChanged signal is emitted.
    
    # Zoom to these extents.
    dbLoader.CANVAS_C.zoomToFeatureExtent(extents)

def btnCreateLayers_setup(dbLoader) -> None:

    threads.create_layers_thread(dbLoader)

    # Update the mat vies extents in the corresponding table in the server.
    sql.exec_upsert_extents(dbLoader,
        usr_schema=dbLoader.USER_SCHEMA,
        cdb_schema=dbLoader.SCHEMA,
        bbox_type=c.MAT_VIEW_EXT_TYPE,
        extents=dbLoader.VIEWS_EXTENTS.asWktPolygon())

    refresh_date = []
    while not refresh_date: # Loop to allow for 'layer creation' thread to finish. Seems hacky...
        # Check if the materialised views are populated. # NOTE: Duplicate code!
        refresh_date = sql.fetch_layer_metadata(dbLoader, from_schema=dbLoader.USER_SCHEMA,for_schema=dbLoader.SCHEMA,cols="refresh_date")
        # Extract a date.
        refresh_date = list(set(refresh_date[1]))

    date = refresh_date[0][0] # Extract date.
    if date:
        dbLoader.dlg.lblLayerRefr_out.setText(
            c.success_html.format(text=c.REFR_LAYERS_MSG.format(
                date=date)))
        dbLoader.DB.green_refresh_date = True
    else:
        dbLoader.dlg.lblLayerRefr_out.setText(c.failure_html.format(text=c.REFR_LAYERS_FAIL_MSG))
        dbLoader.DB.green_refresh_date = False
        return None

def btnRefreshLayers_setup(dbLoader) -> None:

    res= QMessageBox.question(dbLoader.dlg,"Layer Refresh", c.REFRESH_QUERY)
    if res == 16384: #YES
        threads.refresh_views_thread(dbLoader)


def btnDropLayers_setup(dbLoader) -> None:

    threads.drop_layers_thread(dbLoader)


"""This module contains set-up functions for each QT widget in the GUI of the
plugin. The functions are called as events from signals.

The logic behind all of the functions is that are responsible to configure
the plugin, depending on the emitted signal of a widget.

The set-up can consist of many things but it is mainly responsible to
activate/deactivate widgets, reset widgets, change informative text,
call other functions, execute back-end operations and more.

Example: When another 'Existing Connection' is selected, then the signal
'currentIndexChanged' is emitted from the 'cbxExistingConnection' widget.
The event listening to this signal executes the function
'cbxExistingConnection_setup' which is responsible for the set-up."""

import time

from qgis.core import QgsRectangle, QgsCoordinateReferenceSystem
from qgis.core import QgsGeometry, QgsWkbTypes, QgsRasterLayer
from qgis.core import Qgis, QgsProject ,QgsMessageLog
from qgis.gui import QgsRubberBand
from qgis.PyQt.QtWidgets import QMessageBox
from qgis.PyQt.QtGui import QColor
from qgis.PyQt.QtCore import Qt
import psycopg2

from . import installation
from . import connection_tab
from . import constants
from . import threads
from . import import_tab
from . import widget_reset
from . import sql


# Connection tab
def cbxExistingConnection_setup(dbLoader) -> None:
    """Function to setup the gui after a change signal is emitted from
    the cbxExistingConnection comboBox.

    This function runs every time the current selection of 'Existing Connection'
    changes.
    """

    # Variable to store the plugin's main dialog
    dialog = dbLoader.dlg

    # In 'Database' groupbox.
    dialog.gbxDatabase.setDisabled(False)

    # TODO: create and set to init_text for btnConnectToDB (like btnInstallDB).
    dialog.btnConnectToDB.setText(f"Connect to '{dbLoader.DB.database_name}'")
    dialog.btnConnectToDB.setDisabled(False)
    dialog.lblConnectToDB.setDisabled(False)

    widget_reset.reset_gbxDatabase(dbLoader=dbLoader)

    # In 'Connection Status' groupbox
    widget_reset.reset_gbxConnectionStatus(dbLoader=dbLoader)

    # In 'User Type' groupbox
    widget_reset.reset_gbxUserType(dbLoader=dbLoader)

    # Close the current open connection.
    if dbLoader.conn is not None:
        dbLoader.conn.close()

    # In 'Import' tab
    widget_reset.reset_tabImport(dbLoader)

    # In 'Settings' tab
    widget_reset.reset_tabSettings(dbLoader)

def btnConnectToDB_setup(dbLoader) -> None:
    """Function to setup the gui after a click signal is emitted from
    the btnConnectToDB pushButton.

    This function runs every time the 'Connect to {DB}' button is pressed.
    """

    # Variable to store the plugin's main dialog
    dialog = dbLoader.dlg

    #In 'Connection Status' groupbox
    dialog.gbxConnectionStatus.setDisabled(False)

    # Attempt to connect to the database
    successful_connection = connection_tab.open_connection(dbLoader)

    if successful_connection:

        # Show database name
        dialog.lblConnectedToDB_out.setText(constants.success_html.format(
            text=dbLoader.DB.database_name))
        dbLoader.DB.green_connection=True

        if dbLoader.DB.s_version is not None:
            # Show server version
            dialog.lblServerVersion_out.setText(constants.success_html.format(
                text=dbLoader.DB.s_version))
            dbLoader.DB.green_s_version=True

        # Check that database has 3DCityDB installed.
        if connection_tab.is_3dcitydb(dbLoader):
            # Show 3DCityDB version
            dialog.lbl3DCityDBVersion_out.setText(constants.success_html.format(
                text=dbLoader.DB.c_version))
            dbLoader.DB.green_c_verison=True
        else:
            # Show fail message
            dialog.lbl3DCityDBVersion_out.setText(constants.failure_html.format(
                text="3DCityDB is not installed!"))
            dbLoader.DB.green_c_verison=False

        # Enable schema comboBox
        dialog.cbxSchema.setDisabled(False)
        dialog.lblSchema.setDisabled(False)

        # Get 3DCityDB schemas from database 
        #schemas = sql.exec_get_feature_schemas(dbLoader)
        schemas = connection_tab.get_schemas(dbLoader)

        # Fill schema combo box
        connection_tab.fill_schema_box(dbLoader, schemas=schemas)
        # At this point,filling the schema box, activates the 'evt_cbxSchema_changed' event. 
        # So if you're following the code line by line, go to citydb_loader.py>evt_cbxSchema_changed or at 'cbxSchema_setup' function below

    else: # Connection failed!

        dialog.lblConnectedToDB_out.setText(constants.failure_html.format(
            text="Unsucessful connection"))
        dbLoader.DB.green_connection=False

        dialog.lblServerVersion_out.setText(constants.failure_html.format(
            text=''))
        dbLoader.DB.green_s_version=False

        widget_reset.reset_gbxDatabase(dbLoader)

def cbxSchema_setup(dbLoader) -> None:
    """Function to setup the gui after an 'indexChanged' signal is emitted from
    the cbxSchema combo box.

    This function runs every time the selected schema is changed.
    """

    # By now, the schema variable must have be assigned.
    assert dbLoader.SCHEMA, "Somehting went wrong,dbLoader.SCHEMA is None or False"

    # In 'Connection Status' groupbox
    dbLoader.dlg.lblInstall.setText(constants.lblInstall_text.format(
        schema=dbLoader.SCHEMA))
    dbLoader.dlg.lblUserPrivileges_out.clear()

    # Get the urer's privileges 
    privileges_dict=sql.fetch_table_privileges(dbLoader)

    if not privileges_dict: # An error occured
        dbLoader.dlg.lblInstall_out.clear()
        dbLoader.DB.green_privileges=False

        # Show failure in 'connection status.'
        dbLoader.dlg.lblUserPrivileges_out.setText(constants.failure_html.format(text='An error occured assesing privileges. See log'))

    # Get only the effective privileges
    dbLoader.availiable_privileges = connection_tab.true_privileges(privileges_dict)

    # Show effective privileges in 'connection status'.
    dbLoader.dlg.lblUserPrivileges_out.setText(constants.success_html.format(text=dbLoader.availiable_privileges))
    dbLoader.DB.green_privileges=True


    # Clear installation label from previous text.
    dbLoader.dlg.lblInstall_out.clear()

    # Check if qgis_pkg is installed in database.
    has_qgispkg = sql.has_plugin_pkg(dbLoader)
    if has_qgispkg:
        # Check if qgis_pkg has generated views for the current schema.
        qgispkg_supports_schema = sql.exec_support_for_schema(dbLoader)
    else:
        dbLoader.dlg.lblInstall_out.setText(constants.crit_warning_html.format(text='qgis_pkg is not installed!\n\tRequires installation!'))
        dbLoader.DB.green_installation=False
        # Prompt user to install qgis_pkg, plugin cannot work without it!
        installation.installation_query(dbLoader,f"Database '{dbLoader.DB.database_name}' requires 'qgis_pkg' to be installed with contents mapping '{dbLoader.SCHEMA}' schema.\nDo you want to proceed?",origin=dbLoader.dlg.lblInstallLoadingCon)
        # Check if qgis_pkg has generated views for the current schema. True!
        qgispkg_supports_schema = sql.exec_support_for_schema(dbLoader)


    if has_qgispkg and qgispkg_supports_schema: # This is what we want!
        dbLoader.dlg.lblInstall_out.setText(constants.success_html.format(text='qgis_pkg is already installed!'))
        dbLoader.DB.green_installation=True

    # NOTE: Installing for additional schema is not yet implemented.
    elif has_qgispkg and not qgispkg_supports_schema: 
        dbLoader.dlg.lblInstall_out.setText(constants.crit_warning_html.format(text=f'qgis_pkg is already installed but NOT for {dbLoader.SCHEMA}!\n\tRequires installation!'))
        dbLoader.DB.green_installation=False
        # temporarily does nothing.
        # installation_query(dbLoader,f"'qgis_pkg' needs to be enhanced with contents mapping '{selected_schema}' schema.\nDo you want to proceed?")


def gbxUserType_setup(dbLoader,user_type):

    
    print(f'I am {user_type}')

    #dbLoader.CANVAS.scene().removeItem(dbLoader.RUBBER_EXTS)

    selected_schema=dbLoader.dlg.cbxSchema.currentText()
    widget_reset.reset_tabImport(dbLoader)
    
    dbLoader.dlg.tabImport.setDisabled(False)
    dbLoader.dlg.lblDbSchema.setText(dbLoader.dlg.lblDbSchema.init_text.format(Database=dbLoader.DB.database_name,Schema=selected_schema))
    dbLoader.dlg.lblDbSchema.setDisabled(False)
    
    dbLoader.dlg.tabSettings.setDisabled(False)
    tabSettings_setup(dbLoader,user_type)
    
    gbxBasemap_setup(dbLoader)    
    dbLoader.dlg.gbxBasemap.setCollapsed(False)


    # Check qgis_pkg for materialised views
    if import_tab.has_matviews(dbLoader) == False:
        res = QMessageBox.question(dbLoader.dlg,"Warning",
        f"Views need to be created in qgis_pkg!\n"
        f"Do you want to proceed?") 
        if res == 16384: # YES
            # Install mat views
            sql.exec_create_mview(dbLoader)
            # Install updatable views
            sql.exec_create_updatable_views(dbLoader)
        else: 
            return None

    # Prompt user to refreash the materilised views.
    res = QMessageBox.question(dbLoader.dlg,
        "Notice", 
        f"Do you want to refresh the materilised views?!\n"
                f"Note that this process takes a lot of time!") 
    if res == 16384: # YES
        # Move focus to Settings Tab.
        dbLoader.dlg.wdgMain.setCurrentIndex(2)
        # Refreash views. Initiates worker thread for loading animation.
        threads.refresh_views_thread(dbLoader)
    else: 
        # Move focus to Import Tab.
        dbLoader.dlg.wdgMain.setCurrentIndex(1)


    
    
### Import tab
def gbxBasemap_setup(dbLoader, extents: QgsRectangle = None) ->  None:

    try:
        extents_exist = False
        while not extents_exist:

            # Get the extents stored in server.
            extents = sql.fetch_extents(dbLoader,
                type=constants.SCHEMA_EXT_TYPE)

            # Extents might be None (not computed yet).
            if extents:
                extents_exist = True

                crs = sql.fetch_crs(dbLoader)
                
                # Format CRS variable as QGIS epsg code.
                crs = ":".join(["EPSG",str(crs)]) # e.g. EPSG:28992
                dbLoader.CRS = QgsCoordinateReferenceSystem(crs)

                # Convert extents format to QgsRectangle object.
                extents = QgsRectangle.fromWkt(extents)
                # Store extents into plugin variables.
                dbLoader.EXTENTS = extents
                dbLoader.SCHEMA_EXTENTS = extents

                # Move canvas widget in the layout containing the extents.
                dbLoader.dlg.verticalLayout_5.addWidget(dbLoader.CANVAS)
                #dbLoader.CANVAS.show()

                # Setting up CRS, extents, basemap for the canvas.
                CANVAS_setup(dbLoader, extents=extents)

                # Put extents coordinates into the widget.
                dbLoader.dlg.qgbxExtent.setOutputExtentFromUser(dbLoader.EXTENTS,dbLoader.CRS)
                
                # Zoom to these extents.
                dbLoader.CANVAS.zoomToFeatureExtent(extents)
            # Compute the extents.
            else:
                sql.exec_compute_schema_extents(dbLoader)


    except (Exception, psycopg2.Error) as error:
        # Get the location to show in log where an issue happenes
        FUNCTION_NAME = cbxSchema_setup.__name__
        FILE_LOCATION = constants.get_file_location(file=__file__)
        LOCATION = ">".join([FILE_LOCATION,FUNCTION_NAME])

        # Specify in the header the type of error and where it happend.
        header = constants.log_errors.format(type="Fetching extents", loc=LOCATION)

        # Show the error in the log panel. Should open it even if its closed.
        QgsMessageLog.logMessage(message=header + str(error),
            tag="3DCityDB-Loader",
            level=Qgis.Critical,
            notifyUser=True)
        
        dbLoader.conn.rollback()
        return False

def CANVAS_setup(dbLoader,
        extents: QgsRectangle) -> None:
    """Function to set up the additional map canvas that shows the extents.

    For the base map it uses a google maps WMS layer
    
    NOTE: CRS is set from the dbLoader.CRS variable. So DON'T use this function
    until dbLoader.CRS is properly set.

    *   :param dbLoader: Main plugin class

        :type dbLoader: DBLoader

    *   :param extents: Extents to focus the canvas on.

        :type extents: QgsRectangle
    """

    # Set CRS and extents of the canvas
    dbLoader.CANVAS.setDestinationCrs(dbLoader.CRS)
    dbLoader.CANVAS.setExtent(extents,True)

    # Create WMS "pseudo-layer" to set as the basemap of the canvas
    # pseudo means that the lays is not going to be added to the legentd.
    vlayer = QgsRasterLayer(constants.OSM_URI,
        baseName="OSM Basemap",
        providerType="wms")

    # Make sure that the layer can load properly
    assert vlayer.isValid()

    # Add layer to the registry
    QgsProject.instance().addMapLayer(vlayer, addToLegend=False)

    # Set the map canvas layer set.
    dbLoader.CANVAS.setLayers([vlayer])

    # Draw the extents in the canvas
    # Create polygon rubber band corespoding to the extents
    rb = QgsRubberBand(dbLoader.CANVAS, QgsWkbTypes.PolygonGeometry)
    extents_geometry = QgsGeometry.fromRect(extents)
    rb.setToGeometry(extents_geometry,dbLoader.CRS)
    rb.setColor(QColor(Qt.blue))
    rb.setWidth(3)
    rb.setFillColor(Qt.transparent)

def insert_rubber_band(dbLoader,
        extents: QgsRectangle,
        color: Qt.GlobalColor = Qt.red) -> None:
    """Function that insert a rubber band correspoding to an extent.
    
    The rubber band is inserted into the additional map canvas created
    to show the extents.

    Use different color to represent differnt extent types
    e.g.    
    +   Qt.blue = pre-computed extents
    +   Qt.red = User defined extents, pressing the buttons

        or from qgis_pkg.extents
    +   Qt.blue = db_schema extents
    +   Qt.red = m_view extents
    +   Qt.green = qgis extents


    *   :param extents: Extents to focus the canvas on.

        :type extents: QgsRectangle

    *   :param color: Color to paint the extents.

        :type color: GlobalColor
    """

    # Remove previous rubber band extents before creating new ones. 
    if dbLoader.RUBBER_EXTS:
        dbLoader.CANVAS.scene().removeItem(dbLoader.RUBBER_EXTS)

    # Create polygon rubber band corespoding to the extents
    dbLoader.RUBBER_EXTS = QgsRubberBand(dbLoader.CANVAS, QgsWkbTypes.PolygonGeometry)
    extents_geometry = QgsGeometry.fromRect(extents)
    dbLoader.RUBBER_EXTS.setToGeometry(extents_geometry,dbLoader.CRS)
    dbLoader.RUBBER_EXTS.setColor(QColor(color))
    dbLoader.RUBBER_EXTS.setWidth(2)
    dbLoader.RUBBER_EXTS.setFillColor(Qt.transparent)

    # Zoom to these rubber band.
    dbLoader.CANVAS.zoomToFeatureExtent(dbLoader.EXTENTS)

def btnCityExtents_setup(dbLoader):
    
    
    # Get the extents stored in server (already computed at this point).
    extents = sql.fetch_extents(dbLoader, 
        type=constants.SCHEMA_EXT_TYPE)

    assert extents, "Extents don't exist but should have been aleady computed!"

    # Convert extents format to QgsRectangle object.
    extents = QgsRectangle.fromWkt(extents)
    # Update extents in plugin variable.
    dbLoader.EXTENTS = extents


    # Put extents coordinates into the widget.
    dbLoader.dlg.qgbxExtent.setOutputExtentFromUser(dbLoader.EXTENTS,dbLoader.CRS)

def qgbxExtent_setup(dbLoader):
    dbLoader.dlg.cbxFeatureType.clear()
    dbLoader.dlg.gbxParameters.setDisabled(False)

    # NOTE: Draw on Canvas has an undesired effect.
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
 
    # Update extents variable with recalculated ones.
    dbLoader.EXTENTS = dbLoader.dlg.qgbxExtent.outputExtent()

    # Draw the extents in the canvas
    insert_rubber_band(dbLoader, extents=dbLoader.EXTENTS, color=Qt.red)
    usr= QgsGeometry.fromRect(dbLoader.EXTENTS)
    orig= QgsGeometry.fromRect(dbLoader.SCHEMA_EXTENTS)

    if not usr.intersects(orig):
        QMessageBox.critical(dbLoader.dlg,"Warning", f"No data can be found here!\n"
                                                    f"Pick a region in the blue area.") 
        return None


    t0 = time.time()
    # Operations cascade to a lot of functions from here!
    import_tab.fill_FeatureType_box(dbLoader)
    t1 = time.time()
    print("time to excectute events from signals emited by \na change of extents: ",t1-t0)

def cbxFeatureType_setup(dbLoader):
    dbLoader.dlg.cbxLod.clear()
    dbLoader.dlg.cbxLod.setDisabled(False)
    import_tab.fill_lod_box(dbLoader)

def cbxLod_setup(dbLoader):
    dbLoader.dlg.gbxFeatures.setDisabled(False)
    dbLoader.dlg.ccbxFeatures.clear()
    dbLoader.dlg.ccbxFeatures.setDefaultText("Select availiable features to import")
    import_tab.fill_features_box(dbLoader)
             
def ccbxFeatures_setup(dbLoader):

    checked_views= dbLoader.dlg.ccbxFeatures.checkedItems()

    if checked_views:
        dbLoader.dlg.btnImport.setDisabled(False)
        dbLoader.dlg.btnImport.setText(dbLoader.dlg.btnImport.init_text.format(num=len(checked_views)))
    else: 
        dbLoader.dlg.btnImport.setText(dbLoader.dlg.btnImport.init_text)
        dbLoader.dlg.btnImport.setDisabled(True)

def btnImport_setup(dbLoader):
    checked_views = import_tab.get_checkedItemsData(dbLoader.dlg.ccbxFeatures)
    #checked_views = dbLoader.dlg.ccbxFeatures.checkedItemsData() NOTE: this builtin method works only for string types. Check https://qgis.org/api/qgscheckablecombobox_8cpp_source.html line 173

    counter= 0
    for view in checked_views:
        view.n_selected+=counter
    if counter>100:
        res= QMessageBox.question(dbLoader.dlg,"Warning", f"Too many features set to be imported ({counter})!\n"
                                                    f"This could hinder perfomance and even cause frequent crashes.\nDo you want to continue?") 
        if res == 16384: # YES
            success=import_tab.import_layers(dbLoader,checked_views)   
        else: return None #Import Cancelled
    else: 
        success=import_tab.import_layers(dbLoader,checked_views)

    if not success: 
        QgsMessageLog.logMessage(message="Something went wrong!",tag="3DCityDB-Loader",level=Qgis.Critical,notifyUser=True)
        return None
    


    group_node= import_tab.get_node_database(dbLoader)        
    import_tab.order_ToC(group_node)     
    import_tab.send_to_top_ToC(group_node)        
    
    QgsMessageLog.logMessage(message="",tag="3DCityDB-Loader",level=Qgis.Success,notifyUser=True)


### Settings tab
def tabSettings_setup(dbLoader,user_type):

    selected_schema=dbLoader.dlg.cbxSchema.currentText()



    if user_type=='Viewer':        
        widget_reset.reset_tabSettings(dbLoader)

    elif user_type=='Editor':
        dbLoader.dlg.btnInstallDB.setText(dbLoader.dlg.btnInstallDB.init_text.format(DB=dbLoader.DB.database_name,SC=selected_schema))
        dbLoader.dlg.btnInstallDB.setDisabled(False)

        dbLoader.dlg.btnUnInstallDB.setText(dbLoader.dlg.btnUnInstallDB.init_text.format(DB=dbLoader.DB.database_name,SC=selected_schema))
        dbLoader.dlg.btnUnInstallDB.setDisabled(False)

        dbLoader.dlg.btnClearDB.setText(dbLoader.dlg.btnClearDB.init_text.format(DB=dbLoader.DB.database_name))
        dbLoader.dlg.btnClearDB.setDisabled(False)
   
        dbLoader.dlg.btnRefreshViews.setText(dbLoader.dlg.btnRefreshViews.init_text.format(DB=dbLoader.DB.database_name,SC=selected_schema))
        dbLoader.dlg.btnRefreshViews.setDisabled(False)

    dbLoader.dlg.gbxExtent.setDisabled(False)

def btnRefreshViews_setup(dbLoader):
    cur = dbLoader.conn.cursor()
    message= "This is going to take a while! Do you want to proceed?"
    res= QMessageBox.question(dbLoader.dlg,"Refreshing Views", message)
    
    if res == 16384: #YES   
        threads.refresh_views_thread(dbLoader)
        
def btnInstallDB_setup(dbLoader):
    installation.installation_query(dbLoader, "This is going to take a while! Do you want to proceed?",origin=dbLoader.dlg.lblLoadingInstall)

def btnClearDB_setup(dbLoader):
    installation.uninstall_pkg(dbLoader)
    widget_reset.reset_tabImport(dbLoader)
    widget_reset.reset_tabConnection(dbLoader)
    dbLoader.dlg.btnClearDB.setDisabled(True)
    dbLoader.dlg.btnClearDB.setText(dbLoader.dlg.btnClearDB.init_text)

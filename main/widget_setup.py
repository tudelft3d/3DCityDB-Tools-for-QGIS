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

from qgis.PyQt.QtCore import Qt
from qgis.PyQt.QtGui import QColor
from qgis.PyQt.QtWidgets import QMessageBox
from qgis.core import QgsRectangle, QgsCoordinateReferenceSystem
from qgis.core import QgsGeometry, QgsWkbTypes, QgsRasterLayer
from qgis.core import Qgis, QgsProject ,QgsMessageLog
from qgis.gui import QgsRubberBand, QgsMapCanvas
import psycopg2

from . import connection_tab
from . import constants
from . import import_tab
from . import installation
from . import sql
from . import threads
from . import widget_reset


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
        schemas = sql.fetch_schemas(dbLoader)

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
    if not dbLoader.dlg.cbxSchema.currentData():
        return None

    # In 'Connection Status' groupbox
    dbLoader.dlg.lblInstall.setText(constants.lblInstall_text.format(
        schema=dbLoader.SCHEMA))
    dbLoader.dlg.lblUserPrivileges_out.clear()

    # Get the user's privileges.
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
        installation.installation_query(dbLoader,f"Database '{dbLoader.DB.database_name}' requires 'qgis_pkg' to be installed with contents mapping '{dbLoader.SCHEMA}' schema.\nDo you want to proceed?")

        if dbLoader.DB.green_installation:
            # Check if qgis_pkg has generated views for the current schema. True!
            qgispkg_supports_schema = sql.exec_support_for_schema(dbLoader)
            has_qgispkg = True


    if has_qgispkg and qgispkg_supports_schema: # This is what we want!
        dbLoader.dlg.lblInstall_out.setText(constants.success_html.format(text='qgis_pkg is already installed!'))
        dbLoader.DB.green_installation=True

    # NOTE: Installing for additional schema is not yet implemented.
    elif has_qgispkg and not qgispkg_supports_schema:
        dbLoader.dlg.lblInstall_out.setText(constants.crit_warning_html.format(text=f'qgis_pkg is already installed but NOT for {dbLoader.SCHEMA}!\n\tRequires installation!'))
        dbLoader.DB.green_installation=False
        # temporarily does nothing.
        # installation_query(dbLoader,f"'qgis_pkg' needs to be enhanced with contents mapping '{selected_schema}' schema.\nDo you want to proceed?")

def gbxUserType_setup(dbLoader,user_type) -> None:
    """Function to setup the gui after an 'indexChanged' signal is emitted from
    the cbxSchema combo box.

    This function runs every time the view or editor box is checked.

    *   :param user_type: Types of user. Either 'Viewer' or 'Editor'

        :type user_type: str

    ..  Note user types are not fully imeplemented yet.
    ..  (20-02-2022) Currently it doesn't work as intended but is required.
    """

    # Clean 'Import' tab from previous runs.
    widget_reset.reset_tabImport(dbLoader)

    # Enable 'Import' tab.
    dbLoader.dlg.tabImport.setDisabled(False)

    # Show current database and schema in gui.
    dbLoader.dlg.lblDbSchema.setText(dbLoader.dlg.lblDbSchema.init_text.format(
        Database=dbLoader.DB.database_name,
        Schema=dbLoader.SCHEMA))
    dbLoader.dlg.lblDbSchema.setDisabled(False)

    # Enable 'Settings' tab.
    dbLoader.dlg.tabSettings.setDisabled(False)

    # Setup settings based on user type.
    tabSettings_setup(dbLoader,user_type)

    # Enable 'Extents' group box.
    dbLoader.dlg.gbxExtent.setDisabled(False)

    # Expand 'Basemap' groupbox.
    dbLoader.dlg.gbxBasemap.setCollapsed(False)

    # Setup the 'Basemap' groupbox.
    gbxBasemap_setup(dbLoader)




    # Check qgis_pkg for materialised views.
    if not import_tab.has_matviews(dbLoader):
        # Prompt user to install views.
        res = QMessageBox.question(dbLoader.dlg,
        "Warning",
        "Views need to be created in qgis_pkg!\n"
        "Do you want to proceed?")
        if res == 16384: # User said YES
            # Install mat views
            sql.exec_create_mview(dbLoader)
            # Install updatable views
            sql.exec_create_updatable_views(dbLoader)

    # Prompt user to refresh the materilised views.
    # NOTE: asking user to refresh every time might be annoying.
    res = QMessageBox.question(dbLoader.dlg,
        "Notice",
        "Do you want to refresh the materilised views?!\n"
        "Note that this process takes a lot of time!")
    if res == 16384: # User said YES
        # Move focus to Settings Tab.
        dbLoader.dlg.wdgMain.setCurrentIndex(2)
        # Refreash views. Initiates worker thread for loading animation.
        threads.refresh_views_thread(dbLoader) # Takes a lot of time!
    else:
        # Move focus to 'Import' Tab.
        dbLoader.dlg.wdgMain.setCurrentIndex(1)

# Import tab
def gbxBasemap_setup(dbLoader) ->  None:
    """Function to setup the 'Basemap' groupbox.
    It uses an additional canvas instance to store an OSM map
    from which extents can be extracted for further spatial queries.

    The basemap is zoomed-in the city model's entents.
    """

    try:
        extents_exist = False
        while not extents_exist:

            # Get the extents stored in server.
            extents = sql.fetch_extents(dbLoader,
                ext_type=constants.SCHEMA_EXT_TYPE)
            print(extents)

            # Extents might be None (not computed yet).
            if extents:
                extents_exist = True

                # Get the crs stored in server.
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

                # Draw the extents in the canvas
                # Create polygon rubber band corespoding to the extents
                rb = QgsRubberBand(dbLoader.CANVAS, QgsWkbTypes.PolygonGeometry)
                extents_geometry = QgsGeometry.fromRect(extents)
                rb.setToGeometry(extents_geometry,dbLoader.CRS)
                rb.setColor(QColor(Qt.blue))
                rb.setWidth(3)
                rb.setFillColor(Qt.transparent)

                # Put extents coordinates into the widget.
                dbLoader.dlg.qgbxExtent.setOutputExtentFromUser(dbLoader.EXTENTS,dbLoader.CRS)

                # Setting up CRS, extents, basemap for the canvas.
                CANVAS_setup(dbLoader, extents=extents)



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

def CANVAS_setup(dbLoader, extents: QgsRectangle) -> None:
    """Function to set up the additional map canvas that shows the extents.

    For the base map it uses a google maps WMS layer

    Note: CRS is set from the dbLoader.CRS variable. So DON'T use this function
    until dbLoader.CRS is properly set.

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

def btnCityExtents_setup(dbLoader) -> None:
    """Function to setup the gui after a click signal is emitted from
    the btnCityExtents pushButton.

    This function runs every time the 'Compute from City Model' button
    is pressed.
    """

    # Get the extents stored in server (already computed at this point).
    extents = sql.fetch_extents(dbLoader, ext_type=constants.SCHEMA_EXT_TYPE)
    assert extents, "Extents don't exist but should have been aleady computed!"

    # Convert extents format to QgsRectangle object.
    extents = QgsRectangle.fromWkt(extents)
    # Update extents in plugin variable.
    dbLoader.EXTENTS = extents

    # Put extents coordinates into the widget.
    dbLoader.dlg.qgbxExtent.setOutputExtentFromUser(dbLoader.EXTENTS,dbLoader.CRS)
    # At this point an extentChanged signal is emitted.

def qgbxExtent_setup(dbLoader) -> None:
    """Function to setup the gui after an extentChanged signal is emitted from
    one of the qgbxExtent's embedded pushbuttons.
    (e.g. 'Calculate from Layer', 'Map Canvas Extent','Draw on Canvas'*)
    Fills the 'Feature Type' widget.

    This function runs every time the extents in the widget change.
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

    # Enable 'Parameters' groupbox.
    dbLoader.dlg.gbxParameters.setDisabled(False)

    # Clear 'Feature Type' combo box from previous runs.
    dbLoader.dlg.cbxFeatureType.clear()

    # Update extents variable with the ones that fired the signal.
    dbLoader.EXTENTS = dbLoader.dlg.qgbxExtent.outputExtent()

    # Draw the extents in the addtional canvas (basemap)
    insert_rubber_band(dbLoader, extents=dbLoader.EXTENTS, color=Qt.red)

    # Compare original extents with user defined ones.
    usr_exts= QgsGeometry.fromRect(dbLoader.EXTENTS)
    orig_exts= QgsGeometry.fromRect(dbLoader.SCHEMA_EXTENTS)

    # Check validity of user extents relative to the City Model's extents.
    if not usr_exts.intersects(orig_exts):
        QMessageBox.critical(dbLoader.dlg,
            "Warning",
            "No data can be found here!\n"
            "Pick a region in the blue area.")
        return None

    t0 = time.time()
    # Operations cascade to a lot of functions from here!

    # Based on the selected extents fill out the Feature Types combo box.
    import_tab.fill_FeatureType_box(dbLoader)
    t1 = time.time()
    print("time to excectute events from signals emited by \na change of extents: ",t1-t0)
    return None

def cbxFeatureType_setup(dbLoader) -> None:
    """Function to setup the gui after a 'currentIndexChanged' signal is
    emitted from cbxFeatureType. Fills the 'LoD' widget.

    This function runs every time the selected Feature Type in the widget
    changes.
    """

    # Clear 'Geometry Level' combo box from previous runs.
    dbLoader.dlg.cbxLod.clear()

    # Enable 'Geometry Level' combo box
    dbLoader.dlg.cbxLod.setDisabled(False)

    # Fill out the LoDs, based on the selected extents and Feature Type.
    import_tab.fill_lod_box(dbLoader)

def cbxLod_setup(dbLoader) -> None:
    """Function to setup the gui after a 'currentIndexChanged' signal is
    emitted from cbxLod. Fills the 'features' widget.

    This function runs every time the selected LoD in the widget
    changes.
    """

    # Enable 'Features to Import' group box.
    dbLoader.dlg.gbxFeatures.setDisabled(False)

    # Clear 'Features' checkable combo box from previous runs.
    dbLoader.dlg.ccbxFeatures.clear()
    # Revert to initial text.
    dbLoader.dlg.ccbxFeatures.setDefaultText(constants.ccbxFeatures_text)

    # Fill out the features.
    import_tab.fill_features_box(dbLoader)

def ccbxFeatures_setup(dbLoader) -> None:
    """Function to setup the gui after a 'checkedItemsChanged' signal is
    emitted from ccbxFeatures. Shows selected layers with their number of
    features..

    This function runs every time a layer is selected in the widget.
    """

    # Get all the selected layers (views).
    checked_views = dbLoader.dlg.ccbxFeatures.checkedItems()

    if checked_views:
        # Enable 'Import' pushbutton.
        dbLoader.dlg.btnImport.setDisabled(False)
        # Show layer name accompanied with number of features.
        dbLoader.dlg.btnImport.setText(dbLoader.dlg.btnImport.init_text.format(num=len(checked_views)))
    else:
        # Revert to inital text and disable 'Import' pushbutton
        dbLoader.dlg.btnImport.setText(dbLoader.dlg.btnImport.init_text)
        dbLoader.dlg.btnImport.setDisabled(True)

def btnImport_setup(dbLoader) -> None:
    """Function to setup the gui after a click signal is emitted from
    the btnImport pushButton.

    This function runs every time the 'Import' button is pressed.
    """

    # Get the data that is checked from 'ccbxFeatures'
    # Remebmer widget hold items in the form of (view_name,View_object)
    checked_views = import_tab.get_checkedItemsData(dbLoader.dlg.ccbxFeatures)
    #checked_views = dbLoader.dlg.ccbxFeatures.checkedItemsData() NOTE: this builtin method works only for string types. Check https://qgis.org/api/qgscheckablecombobox_8cpp_source.html line 173

    # Get the total number of features to be imported.
    counter = 0
    for view in checked_views:
        counter += view.n_selected

    # Wrarn user when too many features are to be imported. (Subjective value).
    if counter>20000:
        res= QMessageBox.question(dbLoader.dlg,
            "Warning",
            f"Too many features set to be imported ({counter})!\n"
            "This could hinder perfomance and even cause frequent crashes.\n"
            "Do you want to continue?")
        if res == 16384: # YES
            success = import_tab.import_layers(dbLoader,layers=checked_views)
        else: return None #Import Cancelled
    else:
        success = import_tab.import_layers(dbLoader,layers=checked_views)

    if not success:
        QgsMessageLog.logMessage(message="Something went wrong on Import!",
            tag="3DCityDB-Loader",
            level=Qgis.Critical,
            notifyUser=True)
        return None


    # Structure 'Table of Contents' tree.
    db_group = import_tab.get_node_database(dbLoader)
    import_tab.sort_ToC(db_group)
    import_tab.send_to_top_ToC(db_group)

    # A final success message.
    QgsMessageLog.logMessage(message="",tag="3DCityDB-Loader",level=Qgis.Success,notifyUser=True)
    return None

### Settings tab
def tabSettings_setup(dbLoader,user_type: str) -> None:
    """Function to setup the gui for 'Settings' tab based on user type.

    This function runs every time the view or editor box is checked.

    *   :param user_types: 'Viewer' or 'Editor'

        :type user_types: str

    ..  Note user types are not fully imeplemented yet.
    ..  (20-02-2022) Currently it doesn't work as intended
    """
    # Viewers can't make use of the settings.
    if user_type=='Viewer':
        widget_reset.reset_tabSettings(dbLoader)

    # Editors CAN make use of the settings
    elif user_type=='Editor':

        # setup and enable 'Install' button.
        dbLoader.dlg.btnInstallDB.setText(dbLoader.dlg.btnInstallDB.init_text.format(
            DB=dbLoader.DB.database_name,
            SC=dbLoader.SCHEMA))
        dbLoader.dlg.btnInstallDB.setDisabled(False)

        # setup and enable 'Uninstall' button.
        dbLoader.dlg.btnUnInstallDB.setText(dbLoader.dlg.btnUnInstallDB.init_text.format(
            DB=dbLoader.DB.database_name,
            SC=dbLoader.SCHEMA))
        dbLoader.dlg.btnUnInstallDB.setDisabled(False)

        # setup and enable 'Clear' button.
        dbLoader.dlg.btnClearDB.setText(dbLoader.dlg.btnClearDB.init_text.format(
            DB=dbLoader.DB.database_name))
        dbLoader.dlg.btnClearDB.setDisabled(False)

        # setup and enable 'Refresh' button.
        dbLoader.dlg.btnRefreshViews.setText(dbLoader.dlg.btnRefreshViews.init_text.format(
            DB=dbLoader.DB.database_name,
            SC=dbLoader.SCHEMA))
        dbLoader.dlg.btnRefreshViews.setDisabled(False)

def btnRefreshViews_setup(dbLoader) -> None:
    """Function to setup the gui after a click signal is emitted from
    the btnRefreshViews pushButton.

    This function runs every time the 'Refresh Views' button is pressed.
    """

    # Assert that user REALLY want to refresh the views.
    message= "This is going to take a while! Do you want to proceed?"
    res= QMessageBox.question(dbLoader.dlg,"Refreshing Views", message)

    if res == 16384: #YES
        threads.refresh_views_thread(dbLoader)

def btnInstallDB_setup(dbLoader) -> None:
    """Function to setup the gui after a click signal is emitted from
    the btnInstallDB pushButton.

    This function runs every time the 'Install DB' button is pressed.

    It installs the plugin package by executing an installation script.
    """

    installation.installation_query(dbLoader, "This is going to replace any previous installation! Do you want to proceed?")

def btnClearDB_setup(dbLoader) -> None:
    """Function to setup the gui after a click signal is emitted from
    the btnClearDB pushButton.

    This function runs every time the 'Clear DB' button is pressed.

    It drops the plugin package from the server entirely.
    """

    # Drop package.
    installation.uninstall_pkg(dbLoader)

    # Pluggin can't function without its package, so reset everything.
    widget_reset.reset_tabImport(dbLoader)
    widget_reset.reset_tabConnection(dbLoader)

    # Don't let the user clear a clean Database.
    dbLoader.dlg.btnClearDB.setDisabled(True)
    # Revert to initial button text.
    dbLoader.dlg.btnClearDB.setText(dbLoader.dlg.btnClearDB.init_text)

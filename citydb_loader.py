# -*- coding: utf-8 -*-
"""
/***************************************************************************
 DBLoader
                                 A QGIS plugin
                    This is an experimental plugin for 3DCityDB.
 Generated by Plugin Builder: http://g-sherman.github.io/Qgis-Plugin-Builder/
                              -------------------
        begin                : 2021-09-30
        git sha              : $Format:%H$
        copyright            : (C) 2021 by Konstantinos Pantelios
        email                : konstantinospantelios@yahoo.com
 ***************************************************************************/

/***************************************************************************
 *                                                                         *
 *   This program is free software; you can redistribute it and/or modify  *
 *   it under the terms of the GNU General Public License as published by  *
 *   the Free Software Foundation; either version 2 of the License, or     *
 *   (at your option) any later version.                                   *
 *                                                                         *
 ***************************************************************************/
"""


import os.path
import typing

from qgis.PyQt.QtCore import QSettings, QTranslator, QCoreApplication
from qgis.PyQt.QtGui import QIcon
from qgis.PyQt.QtWidgets import QAction, QWidget
from qgis.core import QgsCoordinateReferenceSystem, QgsRectangle
from qgis.gui import QgisInterface, QgsMapCanvas, QgsRubberBand
import psycopg2

from .resources import qInitResources
from .citydb_loader_dialog import DBLoaderDialog # Main dialog
from .main import connection
from .main import constants
from .main import widget_reset
from .main import widget_setup


class DBLoader:
    """QGIS Plugin Implementation. Main class."""

    plugin_package = constants.PLUGIN_PKG_NAME

    def __init__(self, iface: QgisInterface) -> None:
        """DBLoader class Constructor.

        *   :param iface: An interface instance that will be passed to this
                class which provides the hook by which you can manipulate the
                QGIS application at run time.

            :type iface: QgsInterface
        """
        # Initialize Qt resources from file resources.py.
        qInitResources()

        # Variable to store the main dialog of the plugin.
        self.dlg: DBLoaderDialog = None

        # Variable to store the existing connection object.
        self.DB: connection.Connection = None

        # Variable to store the existing schema name.
        self.SCHEMA: str = None

        # Variable to store the selected extents.
        self.EXTENTS: QgsRectangle = iface.mapCanvas().extent()

        # Variable to store the City Model's extents.
        self.SCHEMA_EXTENTS: QgsRectangle = iface.mapCanvas().extent()

        # Variable to store the selected crs.
        self.CRS: QgsCoordinateReferenceSystem
        self.CRS = iface.mapCanvas().mapSettings().destinationCrs()

        # Variable to store a rubberband formed by the current extents.
        self.RUBBER_EXTS: QgsRubberBand = None

        # Variable to store an additional canvas (to show the extents).
        self.CANVAS: QgsMapCanvas = QgsMapCanvas()
        self.CANVAS.enableAntiAliasing(True)


        # Variable to store all availiable FeatureTypes.
        # The availiability is defined by the existance of at least one feature.
        # instance inside the current selected extents (bboox).
        self.FeatureType_container: dict = {}

        # Variable to store all abailiable privileges.
        # CAUSION: This is not yet fully implemented. Might change.
        self.availiable_privileges: dict = {}

        # Variable to store the current open connection of a database.
        self.conn: psycopg2.connection = None

        # Variable referencing to the QGIS interface.
        self.iface: QgisInterface = iface

        # initialize plugin directory.
        self.plugin_dir: str = os.path.dirname(__file__) # = PLUGIN_PATH
        # initialize locale.
        locale = QSettings().value("locale/userLocale")[0:2]
        locale_path = os.path.join(
            self.plugin_dir,
            "i18n",
            "DBLoader_{}.qm".format(locale))

        if os.path.exists(locale_path):
            self.translator = QTranslator()
            self.translator.load(locale_path)
            QCoreApplication.installTranslator(self.translator)

        # Declare instance attributes.
        self.actions: list = []

        # Check if plugin was started the first time in current QGIS session.
        # Must be set in initGui() to survive plugin reloads.
        self.first_start: bool = True

    def tr(self, message: str ) -> str:
        """Get the translation for a string using Qt translation API.

        We implement this ourselves since we do not inherit QObject.

        *   :param message: String for translation.

            :type message: str

        *   :returns: Translated version of message.

            :rtype: str
        """
        return QCoreApplication.translate("DBLoader", message)

    def add_action(self,
            icon_path: str,
            txt: str,
            callback: typing.Callable[...,None],
            enabled_flag: bool = True,
            add_to_menu: bool = True,
            add_to_toolbar: bool = True,
            status_tip: typing.Optional[str] = None,
            whats_this: typing.Optional[str] = None,
            parent: typing.Optional[QWidget] = None) -> QAction:
        """Add a toolbar icon to the toolbar.

        *   :param icon_path: Path to the icon for this action. Can be a
                resource path (e.g. ":/plugins/foo/bar.png") or a normal
                file system path.

            :type icon_path: str

        *   :param txt: Text that should be shown in menu items for this
                action.

            :type txt: str

        *   :param callback: Function to be called when the action is
                triggered.

            :type callback: function

        *   :param enabled_flag: A flag indicating if the action should be
                enabled by default. Defaults to True.

            :type enabled_flag: bool

        *   :param add_to_menu: Flag indicating whether the action should also
                be added to the menu. Defaults to True.

            :type add_to_menu: bool

        *   :param add_to_toolbar: Flag indicating whether the action should
                also be added to the toolbar. Defaults to True.

            :type add_to_toolbar: bool

        *   :param status_tip: Optional text to show in a popup when mouse
                pointer hovers over the action.

            :type status_tip: str

        *   :param whats_this: Optional text to show in the status bar when the
                mouse pointer hovers over the action.

            :type whats_this: str

        *   :param parent: Parent widget for the new action. Defaults None.

            :type parent: QWidget

        *   :returns: The action that was created. Note that the action is also
                added to self.actions list.

            :rtype: QAction
        """

        # Create icon from referenced path in resources file.
        icon = QIcon(icon_path)

        # Create action object
        action = QAction(icon=icon, text=txt, parent=parent)

        # Signal to run plugin when clicked (execute main method: run())
        action.triggered.connect(callback)

        # Set the name of the action
        action.setObjectName(txt)

        # Set the action as enabled (not grayed out)
        action.setEnabled(enabled_flag)

        if status_tip is not None:
            action.setStatusTip(statusTip=status_tip)

        if whats_this is not None:
            action.setWhatsThis(what=whats_this)

        # Adds plugin to "Database" toolbar.
        if add_to_toolbar:
            self.iface.addDatabaseToolBarIcon(qAction=action)

        # Adds plugin to "Database" menu.
        if add_to_menu:
            # In order to add the plugin into the database menu we
            # follow the 'hacky' approach below to bypass possibly a bug:
            #
            # The bug: Using the method addPluginToDatabaseMenu causes
            # the plugin to be inserted in a submenu of itself
            # 3DCityDB-Loader > 3DCityDB-Loader which we don't want.
            # However using the addAction method to insert the plugin directly,
            # causes the database menu to 'pop out' of the menu ribbon in a
            # hidden state. Note that this method, for some bizarre reason,
            # works for all the menus except the database menu.
            # Using the addPluginToDatabaseMenu method BEFORE the addAction
            # method seems to bypass this issue. Needs further investigation.

            # Add the action to the database menu (bug countermeasure)
            self.iface.addPluginToDatabaseMenu(name=txt, action=action)

            # Add the action to the database menu
            self.iface.databaseMenu().addAction(action)

            #Now that we made sure that the bug didn't occure, remove it.
            self.iface.removePluginDatabaseMenu(name=txt,action=action)

        self.actions.append(action)

        return action

    def initGui(self) -> None:
        """Create the menu entries and toolbar icons inside the QGIS GUI."""

        # The icon path is set from the compiled resources file (in main dir).
        icon_path = ":/plugins/citydb_loader/icons/plugin_icon.png"
        self.add_action(
            icon_path=icon_path,
            txt=self.tr("3DCityDB-Loader"),
            callback=self.run,
            parent=self.iface.mainWindow())

        # will be set False in run()
        self.first_start = True

    def unload(self) -> None:
        """Removes the plugin menu item and icon from QGIS GUI."""

        for action in self.actions:
            self.iface.removeDatabaseToolBarIcon(qAction=action)
            self.iface.databaseMenu().removeAction(action)

    def run(self) -> None:
        """Run main method that performs all the real work.

        -   Creates the plugin's dialogs
        -   Instantiates the plugin's main class (DBLoaderDialog) with its guis
        -   Setups the plugin's signals
        -   Exectutes the main dialog
        """

        # Only create GUI ONCE in callback,
        # so that it will only load when the plugin is started.
        if self.first_start:
            self.first_start = False

            # Create the dialog with elements (after translation).
            self.dlg = DBLoaderDialog()

            # Enhance various Qt Objects with their initial text.
            # This is used in order to revent to the original state
            # in reset operations when original text has already changed.
            self.dlg.btnInstallDB.init_text = constants.btnInstallDB_text
            self.dlg.btnUnInstallDB.init_text= constants.btnUnInstallDB_text
            self.dlg.btnClearDB.init_text = constants.btnClearDB_text
            self.dlg.btnRefreshViews.init_text = constants.btnRefreshViews_text
            self.dlg.lblDbSchema.init_text = constants.lblDbSchema_text
            self.dlg.btnImport.init_text = constants.btnImport_text
            self.dlg.lblInstall.init_text = constants.lblInstall_text

    #----------################################################################
    #-SIGNALS--################################################################
    #-(start)--################################################################

            # 'Connection' group box signals (in 'Connection' tab)
            self.dlg.cbxExistingConnection.currentIndexChanged.connect(
                self.evt_cbxExistingConnection_changed)
            self.dlg.btnNewConnection.clicked.connect(
                self.evt_btnNewConnection_clicked)

            # 'Database' group box signals (in 'Connection' tab)
            self.dlg.btnConnectToDB.clicked.connect(
                self.evt_btnConnectToDB_clicked)
            self.dlg.cbxSchema.currentIndexChanged.connect(
                self.evt_cbxSchema_changed)

            # 'User Type' group box signals (in 'Connection' tab)
            self.dlg.rdViewer.clicked.connect(self.evt_rdViewer_clicked)
            self.dlg.rdEditor.clicked.connect(self.evt_rdEditor_clicked)


            # Link the addition canvas to the extents qgroupbox and
            # enable "MapCanvasExtent" options (Byproduct).
            self.dlg.qgbxExtent.setMapCanvas(canvas=self.CANVAS,
                drawOnCanvasOption = False)
            # Draw on Canvas tool is disabled. Check Note on widget_setup.py

            self.dlg.qgbxExtent.setOutputCrs(outputCrs=self.CRS)


            # 'Extent' groupbox signals (in 'Import' tab)
            self.dlg.btnCityExtents.clicked.connect(
                self.evt_btnCityExtents_clicked)
            self.CANVAS.extentsChanged.connect(self.evt_canvas_extChanged)
            self.dlg.qgbxExtent.extentChanged.connect(
                self.evt_qgbxExtent_extChanged)

            # 'Parameters' groupbox signals (in 'Import' tab)
            self.dlg.cbxFeatureType.currentIndexChanged.connect(
                self.evt_cbxFeatureType_changed)
            self.dlg.cbxLod.currentIndexChanged.connect(
                self.evt_cbxLod_changed)

            # 'Features to Import' groupbox signals (in 'Import' tab)
            self.dlg.ccbxFeatures.checkedItemsChanged.connect(
                self.evt_ccbxFeatures_changed)
            self.dlg.btnImport.clicked.connect(
                self.evt_btnImport_clicked)

            # 'Installation' groupbox signals (in 'Settings' tab)
            self.dlg.btnInstallDB.clicked.connect(
                self.evt_btnInstallDB_clicked)
            self.dlg.btnUnInstallDB.clicked.connect(
                self.evt_btnUnInstallDB_clicked)
            self.dlg.btnClearDB.clicked.connect(
                self.evt_btnClearDB_clicked)

            # 'Database' groupbox signals (in 'Settings' tab)
            self.dlg.btnRefreshViews.clicked.connect(
                self.evt_btnRefreshViews_clicked)

    #----------################################################################
    #-SIGNALS--################################################################
    #--(end)---################################################################


            print("Initial start > This should be printed ONLY once")

            # Get existing connections from QGIS profile settings.
            connection.get_postgres_conn(self) # Stored in self.conn

        # Show the dialog
        self.dlg.show()

        # Run the dialog event loop.
        self.dlg.exec_()

    #----------################################################################
    #--EVENTS--################################################################
    #-(start)--################################################################

    # 'Connection' group box events (in 'Connection' tab)
    def evt_cbxExistingConnection_changed(self) -> None:
        """Event that is called when the 'Existing Connection'
        comboBox (cbxExistingConnection) current index chages.
        """

        # Set the current database connection object variable
        self.DB = self.dlg.cbxExistingConnection.currentData()
        widget_setup.cbxExistingConnection_setup(self)

    def evt_btnNewConnection_clicked(self) -> None:
        """Event that is called when the 'New Connection' pushButton
        (btnNewConnection) is pressed.

        Resposible to add VALID new connection to the 'Existing connections'.
        """

        # Create/Show/Execture additional dialog for the new connection
        dlgConnector = connection.DlgConnector()
        dlgConnector.show()
        dlgConnector.exec_()

        # Add new connection to the Existing connections
        if dlgConnector.new_connection:
            self.dlg.cbxExistingConnection.addItem(
                text=f"{dlgConnector.new_connection.connection_name}",
                userData=dlgConnector.new_connection)

    # 'Database' group box events (in 'Connection' tab)
    def evt_btnConnectToDB_clicked(self) -> None:
        """Event that is called when the current 'Connect to {DB}' pushButton
        (btnConnectToDB) is pressed.
        """

        widget_setup.btnConnectToDB_setup(self)

    def evt_cbxSchema_changed(self) -> None:
        """Event that is called when the 'schemas' comboBox (cbxSchema)
        current index chages.

        Checks if the connection + schema meet the necessary requirements.
        """

        # Set the current schema variable
        self.SCHEMA = self.dlg.cbxSchema.currentText()

        res = widget_setup.cbxSchema_setup(self)
        if not res:
            widget_reset.reset_tabImport(self)
            widget_reset.reset_tabSettings(self)

        # We can proceed ONLY if the necessary requirements are met.
        if self.DB.meets_requirements():
            self.dlg.gbxUserType.setDisabled(False)

            # Allow user type selection depending on privileges.
            # CAUSION: Privileges are not fully imeplemented yet.
            if all(
                priv in self.availiable_privileges
            for priv in constants.priviledge_types):
                self.dlg.rdEditor.setDisabled(False)
                self.dlg.rdViewer.setDisabled(False)
            elif any(p == "SELECT" for p in self.availiable_privileges):
                self.dlg.rdEditor.setDisabled(True)
                self.dlg.rdViewer.setDisabled(False)
        else:
            widget_reset.reset_gbxUserType(self)
            self.dlg.gbxUserType.setDisabled(True)

    def evt_update_bar(self,step,text) -> None:
        """Function to setup the progress bar upon update.
        Important: Progress Bar need to be already created
        in dbLoader.msg_bar: QgsMessageBar and
        dbLoader.bar: QProgressBar.

        *   :param step: Current value of the progress

            :type step: int

        *   :param text: Text to display on the bar

            :type text: str

        .. This event is not liked to any widet_setup function
        .. as it isn't responsible for changes in different
        .. widgets in the gui.
        """
        progress_bar = self.dlg.bar

        # Show text instead of completed percentage.
        if text:
            progress_bar.setFormat(text)
        # Update progress with current step
        progress_bar.setValue(step)


    # 'User Type' group box events (in 'Connection' tab)
    def evt_rdViewer_clicked(self) -> None:
        """Event that is called when the current 'Viewer' radioButton
        (rdViewer) is checked.

        ..  Note user types are not fully imeplemented yet.
        ..  (20-02-2022) Currently it doesn't work as intended
        """

        widget_setup.gbxUserType_setup(self,user_type=self.dlg.rdViewer.text())

    def evt_rdEditor_clicked(self) -> None:
        """Event that is called when the current 'Editor' radioButton
        (rdEditor) is checked.

        ..  Note user types are not fully imeplemented yet.
        ..  (20-02-2022) Currently it doesn't work as intended
        """

        widget_setup.gbxUserType_setup(self,user_type=self.dlg.rdEditor.text())

    # 'Extents' group box events (in 'Import' tab)
    def evt_btnCityExtents_clicked(self) -> None:
        """Event that is called when the current 'Calculate from City model'
        pushButton (btnCityExtents) is pressed.
        """

        widget_setup.btnCityExtents_setup(self)

    def evt_canvas_extChanged(self) -> None:
        """Event that is called when the current canvas extents (pan over map)
        changes.

        Reads the new current extents from the map and sets it in the 'Extents'
        (QgsExtentGroupBox) widget.
        """

        # Get canvas's current extent
        extent: QgsRectangle = self.CANVAS.extent()

        # Set the current extent to show in the 'extent' widget.
        self.dlg.qgbxExtent.setCurrentExtent(
            currentExtent=extent,
            currentCrs=self.CRS)
        self.dlg.qgbxExtent.setOutputCrs(outputCrs=self.CRS)

    def evt_qgbxExtent_extChanged(self) -> None:
        """Event that is called when the 'Extents' groubBox (qgbxExtent)
        extent changes.
        """

        widget_setup.qgbxExtent_setup(self)

    # 'Parameters' group box events (in 'Import' tab)
    def evt_cbxFeatureType_changed(self) -> None:
        """Event that is called when the 'Feature Type'comboBox (cbxFeatureType)
        current index chages.
        """

        widget_setup.cbxFeatureType_setup(self)

    def evt_cbxLod_changed(self) -> None:
        """Event that is called when the 'Geometry Level'comboBox (cbxLod)
        current index chages.
        """

        widget_setup.cbxLod_setup(self)

    # 'Features to Import' group box events (in 'Import' tab)
    def evt_ccbxFeatures_changed(self) -> None:
        """Event that is called when the 'Availiable Features'
        checkableComboBox (ccbxFeatures) current index chages.
        """

        widget_setup.ccbxFeatures_setup(self)

    def evt_btnImport_clicked(self) -> None:
        """Event that is called when the 'Import Features' pushButton
        (btnImport) is pressed.
        """

        widget_setup.btnImport_setup(self)
        # Here is the final step.
        # Meaning that user did everything and can now close
        # the window to continue working outside the plugin.

    # 'Installation' group box events (in 'Settings' tab)
    def evt_btnInstallDB_clicked(self) -> None:
        """Event that is called when the 'Install' pushButton
        (btnInstallDB) is pressed.
        """

        widget_setup.btnInstallDB_setup(self)

    def evt_btnUnInstallDB_clicked(self) -> None:
        """Event that is called when the 'Uninstall' pushButton
        (btnUnInstallDB) is pressed.
        """
        print("BTN Does nothing")
        # installation.uninstall_views(self,
        #     schema=self.dlg.cbxSchema.currentText())

    def evt_btnClearDB_clicked(self) -> None:
        """Event that is called when the 'Clear All' pushButton
        (btnClearDB) is pressed.
        """

        widget_setup.btnClearDB_setup(self)


    # 'Database' group box events (in 'Settings' tab)
    def evt_btnRefreshViews_clicked(self) -> None:
        """Event that is called when the 'Referesh all Views' pushButton
        (btnRefreshViews) is pressed.
        """

        widget_setup.btnRefreshViews_setup(self)

    #----------################################################################
    #--EVENTS--################################################################
    #--(end)---################################################################


#NOTE: extent groupbox doesnt work for manual user input
#for every value change in any of the 4 inputs the extent signal is emited

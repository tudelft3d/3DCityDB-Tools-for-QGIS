"""
/***************************************************************************
 Class CDBToolsMain
 
        This is a QGIS plugin for the CityGML 3D City Database.

        begin                : 2021-09-30
        git sha              : $Format:%H$
        author(s)            : Giorgio Agugiaro
                               Konstantinos Pantelios
        email                : g.agugiaro@tudelft.nl
                               konstantinospantelios@yahoo.com
 ***************************************************************************/

/***************************************************************************
 *                                                                         *
   Copyright 2021 Giorgio Agugiaro, Konstantinos Pantelios

   Licensed under the Apache License, Version 2.0 (the "License");
   you may not use this file except in compliance with the License.
   You may obtain a copy of the License at

       http://www.apache.org/licenses/LICENSE-2.0

   Unless required by applicable law or agreed to in writing, software
   distributed under the License is distributed on an "AS IS" BASIS,
   WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
   See the License for the specific language governing permissions and
   limitations under the License.
 *                                                                         *
 ***************************************************************************/
"""

from __future__ import annotations
from typing import TYPE_CHECKING, Union
if TYPE_CHECKING:       
    from .cdb4.gui_admin.admin_dialog import CDB4AdminDialog
    from .cdb4.gui_loader.loader_dialog import CDB4LoaderDialog
    from .cdb4.gui_deleter.deleter_dialog import CDB4DeleterDialog    
    from .gui_about.about_dialog import CDBAboutDialog
 
import os.path
import typing
import webbrowser

from qgis.PyQt.QtCore import Qt, QSettings, QTranslator, QCoreApplication
from qgis.PyQt.QtGui import QIcon
from qgis.PyQt.QtWidgets import QAction, QWidget, QMessageBox, QMenu
from qgis.core import Qgis, QgsMessageLog
from qgis.gui import QgisInterface

from .resources import qInitResources
from . import cdb_tools_main_constants as main_c

class CDBToolsMain:
    """QGIS Plugin Implementation. Main class.
    """

    def __init__(self, iface: QgisInterface) -> None:
        """CDBToolsMain class Constructor.

        *   :param iface: An interface instance that will be passed to this
                class which provides the hook by which you can manipulate the
                QGIS application at run time.

            :type iface: QgsInterface
        """
        # Variable referencing to the QGIS interface.
        self.iface: QgisInterface = iface

        # Initialize Qt resources from file resources.py.
        qInitResources()

        # initialize plugin full path (including plugin directory).
        self.PLUGIN_ABS_PATH: str = main_c.PLUGIN_PATH
        self.QGIS_PKG_SCHEMA: str = main_c.QGIS_PKG_SCHEMA

        self.PLUGIN_NAME: str = main_c.PLUGIN_NAME_LABEL

        self.PLUGIN_VERSION_MAJOR: int = main_c.PLUGIN_VERSION_MAJOR
        self.PLUGIN_VERSION_MINOR: int = main_c.PLUGIN_VERSION_MINOR
        self.PLUGIN_VERSION_REV:   int = main_c.PLUGIN_VERSION_REV
        self.PLUGIN_VERSION_TXT:   str = ".".join([str(self.PLUGIN_VERSION_MAJOR), str(self.PLUGIN_VERSION_MINOR), str(self.PLUGIN_VERSION_REV)])

        # QGIS current version
        self.QGIS_VERSION_STR: str = Qgis.version() 
        self.QGIS_VERSION_MAJOR: int = int(self.QGIS_VERSION_STR.split(".")[0])
        self.QGIS_VERSION_MINOR: int = int(self.QGIS_VERSION_STR.split(".")[1])
        self.QGIS_VERSION_REV:   int = int(self.QGIS_VERSION_STR.split(".")[2].split("-")[0])

        ######################################################
        # Only for testing purposes
        # self.QGIS_VERSION_MINOR = 26
        # print (f"test minor version: {self.QGIS_VERSION_MINOR}")
        ######################################################

        # Is QGIS supported by the plugin?
        self.IS_QGIS_SUPPORTED: bool = None
        self.first_check_QGIS_supported: bool = True        

        # Welcome message upon (re)loading
        msg: str = f"<br><br>------ WELCOME! -------<br>You are using the <b>{self.PLUGIN_NAME} v. {self.PLUGIN_VERSION_TXT}</b> plugin running on <b>QGIS v. {self.QGIS_VERSION_MAJOR}.{self.QGIS_VERSION_MINOR}.{self.QGIS_VERSION_REV}</b>.<br>-----------------------------<br>"
        QgsMessageLog.logMessage(msg, self.PLUGIN_NAME, level=Qgis.Info, notifyUser=False)

        # Variable to store the loader dialog of the plugin.
        self.loader_dlg: CDB4LoaderDialog = None
        # Check if plugin was started the first time in current QGIS session.
        self.first_start_loader: bool = True

        # Variable to store the deleter dialog of the plugin.
        self.deleter_dlg: CDB4DeleterDialog = None
        # Check if plugin was started the first time in current QGIS session.
        self.first_start_deleter: bool = True

        # Variable to store the admin dialog of the plugin.
        self.admin_dlg: CDB4AdminDialog = None
        # Check if plugin was started the first time in current QGIS session.
        self.first_start_admin: bool = True

        # Variable to store the about dialog of the plugin.
        self.about_dlg: CDBAboutDialog = None
        # Check if plugin was started the first time in current QGIS session.
        self.first_start_about: bool = True

        self.DialogRegistry: dict = {}

        # initialize locale.
        #locale = QSettings().value("locale/userLocale")[0:2]
        #locale_path = os.path.join(self.PLUGIN_ABS_PATH, "i18n", "CDBToolsMain_{}.qm".format(locale))
        #if os.path.exists(locale_path):
        #    self.translator = QTranslator()
        #    self.translator.load(locale_path)
        #    QCoreApplication.installTranslator(self.translator)

        # Declare instance attributes.
        self.actions: list = []


    def tr(self, message: str) -> str:
        """Get the translation for a string using Qt translation API. We implement this ourselves since we do not inherit QObject. 

        *   :param message: String for translation.
            :type message: str

        *   :returns: Translated version of message.
            :rtype: str
        """
        return QCoreApplication.translate("3DCityDB Manager", message)


    def add_action(self,
            icon_path: str,
            txt: str,
            callback: typing.Callable[..., None],
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
        # Set the action as enabled (not greyed out)
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
            # In order to add the plugin into the database menu we follow the 'hacky' approach below to bypass possibly a bug:
            #
            # The bug: Using the method addPluginToDatabaseMenu causes
            # the plugin to be inserted in a submenu of itself
            # 3DCityDB-Tools > 3DCityDB-Tools which we don't want.
            # However using the addAction method to insert the plugin directly,
            # causes the database menu to 'pop out' of the menu ribbon in a
            # hidden state. Note that this method, for some bizarre reasons,
            # works for all the menus except the database menu.
            # Using the addPluginToDatabaseMenu method BEFORE the addAction
            # method seems to bypass this issue. 
            # 
            # TODO Needs further investigation.

            # Add the action to the database menu (bug countermeasure)
            self.iface.addPluginToDatabaseMenu(name=self.PLUGIN_NAME, action=action)

            # Add the action to the database menu
            # self.iface.databaseMenu().addAction(action)

            # Now that we made sure that the bug didn't occur, remove it.
            # self.iface.removePluginDatabaseMenu(name=txt, action=action)

        self.actions.append(action)

        return action


    def initGui(self) -> None:
        """Create the menu entries and toolbar icons inside the QGIS GUI.
        """
        # ########## TO BE UNCOMMENTED IF/WHEN WE WILL ADD SUBMENUS
        # plugin_sub_menu_names: list = ["Submenu Name 1"] # to be substituted at a later time with a constant
        # # Multiple QMenu objects accumulate if we do not remove them
        # qmenu_list = []
        # qmenu_list: list = [i for i in self.iface.mainWindow().findChildren(QMenu) if i.title() in plugin_sub_menu_names]
        # if qmenu_list:
        #     print("Deleting submenus:")            
        #     # print([i.title() for i in qmenu_list])
        #     # print([i for i in qmenu_list])
        #     for item in qmenu_list:
        #         m_action = item.menuAction()
        #         item.removeAction(m_action)
        #         m_action.deleteLater()
        #         item.deleteLater()

        # Multiple QMenu objects may accumulate if we do not remove them
        # qmenu_list = []
        # qmenu_list: list = [i for i in self.iface.mainWindow().findChildren(QMenu) if i.title() == main_c.PLUGIN_NAME_LABEL]
        # if qmenu_list:
        #     print("Menus:")  
        #     print([i for i in qmenu_list])
            # print([i.title() for i in qmenu_list])
            # for item in qmenu_list:
            #     m_action = item.menuAction()
            #     item.removeAction(m_action)
            #     m_action.deleteLater()
            #     item.deleteLater()
            #     pass

        # The icon path is set from the compiled resources file (in main dir), or directly with path to the file.
        # admin_icon_path   = ":/plugins/citydb_loader/icons/settings_icon.svg"
        loader_icon_path  = os.path.join(self.PLUGIN_ABS_PATH, "icons", "loader_icon.png")
        deleter_icon_path = os.path.join(self.PLUGIN_ABS_PATH, "icons", "deleter_icon.png")
        admin_icon_path   = os.path.join(self.PLUGIN_ABS_PATH, "icons", "admin_icon.png")
        usrguide_icon_path= os.path.join(self.PLUGIN_ABS_PATH, "icons", "help_icon.png")
        about_icon_path   = os.path.join(self.PLUGIN_ABS_PATH, "icons", "info_icon.png")

        # Loader Dialog
        self.add_action(
            icon_path = loader_icon_path,
            #txt = self.tr(self.PLUGIN_NAME_LOADER),
            txt = main_c.DLG_NAME_LOADER_LABEL,
            callback = self.run_loader,
            parent = self.iface.mainWindow(),
            add_to_menu = True,
            add_to_toolbar = True) # Default: True

        # Deleter Dialog
        self.add_action(
            icon_path = deleter_icon_path,
            #txt = self.tr(self.PLUGIN_NAME_DELETER),
            txt = main_c.DLG_NAME_DELETER_LABEL,
            callback = self.run_deleter,
            parent = self.iface.mainWindow(),
            add_to_menu = True,
            add_to_toolbar = True) # Default: True

        # Admin Dialog
        self.add_action(
            icon_path = admin_icon_path,
            txt = main_c.DLG_NAME_ADMIN_LABEL,
            callback = self.run_admin,
            parent = self.iface.mainWindow(),
            add_to_menu = True,
            add_to_toolbar = False) # Default: False (but useful to set it to True in development mode).

        # Add separator
        sep: QAction = QAction() # must create a new object every time!
        sep.setSeparator(True)
        sep.setParent(self.iface.mainWindow())
        self.iface.addPluginToDatabaseMenu(name=self.PLUGIN_NAME, action=sep)
        self.actions.append(sep)

        # User guide link
        self.add_action(
            icon_path = usrguide_icon_path,
            txt = main_c.DLG_NAME_USRGUIDE_LABEL,
            callback = self.run_usrguide,
            parent = self.iface.mainWindow(),
            add_to_menu = True,
            add_to_toolbar = False) # Default: False

        # About Dialog - Leave this at the end, so it will be the last icon.
        self.add_action(
            icon_path = about_icon_path,
            txt = main_c.DLG_NAME_ABOUT_LABEL,
            callback = self.run_about,
            parent = self.iface.mainWindow(),
            add_to_menu = True,
            add_to_toolbar = True) # Default: False

        #####################################################################
        #####################################################################

        # qmenu_list = []
        # qmenu_list = [i for i in self.iface.mainWindow().findChildren(QMenu) if i.title() in [main_c.PLUGIN_NAME_LABEL]]
        # # print("Picking menus")
        # # print([i for i in qmenu_list])
        # # print("Picked menu")
        # plugin_menu = qmenu_list[0]        
        # # print(plugin_menu)
        
        # ############### Create submenu root entry
        # plugin_sub_menu_name = plugin_sub_menu_names[0]
        # plugin_sub_menu = plugin_menu.addMenu(plugin_sub_menu_name)
        # plugin_sub_menu.setIcon(QIcon(loader_icon_path))

        # ############### Add submenu container entry
        # action_name = "Do something!"
        # ac1 = plugin_sub_menu.addAction(action_name) # Its parent is the plugin_sub_menu
        # ac1.setIcon(QIcon(loader_icon_path))
        # ac1.triggered.connect(self.run_test_action)
        # ac1.setEnabled(True)
        # self.actions.append(ac1)

        ################ Add submenu entry 1
        # action_name = "Do something else!"
        # ac1 = plugin_sub_menu.addAction(action_name) # Its parent is the plugin_sub_menu
        # ac1.setIcon(QIcon(loader_icon_path))
        # ac1.triggered.connect(self.run_test_action2)
        # ac1.setEnabled(True)
        # self.actions.append(ac1)

        # Print list of actions, the "empty" ones are the separators
        # print("-- Actions")
        # print([i.text() for i in self.actions])


    def unload(self) -> None:
        """Removes the plugin menu item and icon from QGIS GUI.
        """
        for action in self.actions:
            self.iface.removeDatabaseToolBarIcon(qAction=action)
            self.iface.removePluginDatabaseMenu(name=self.PLUGIN_NAME, action=action)
        return None


    # def run_test_action(self) -> None:
    #     print("This is a simple test")
    #     return None


    # def run_test_action2(self) -> None:
    #     print("This is another simple test")
    #     return None


    def run_loader(self) -> None:
        """Run method that performs all the real work.
        -   Creates the plugin dialog
        -   Instantiates the plugin main class (CDB4LoaderDialog) with its GUI
        -   Sets up the plugin signals
        -   Executes the dialog
        """
        from .cdb4.gui_loader.loader_dialog import CDB4LoaderDialog # Loader dialog
        from .cdb4.gui_db_connector.functions import conn_functions as conn_f

        # Check once if the QGIS version is supported
        if self.first_check_QGIS_supported:
            self.first_check_QGIS_supported = False
            self.check_QGIS_version()

        # Only create GUI ONCE in callback,
        # so that it will only load when the plugin is started.
        if self.first_start_loader:
            self.first_start_loader = False

            # Create the dialog with elements (after translation).
            self.loader_dlg = CDB4LoaderDialog(cdbMain=self)

            # Replace empty graphics view widget with Map canvas.
            self.loader_dlg.gLayoutBasemap.replaceWidget(self.loader_dlg.gvCanvas, self.loader_dlg.CANVAS)
            self.loader_dlg.vLayoutBasemapL.replaceWidget(self.loader_dlg.gvCanvasL, self.loader_dlg.CANVAS_L)

            # Remove empty graphics View widget from dialog.
            self.loader_dlg.gvCanvas.setParent(None)
            self.loader_dlg.gvCanvasL.setParent(None)

        # Get existing connections from QGIS profile settings.
        # They are added to the combo box (cbxExistingConn), and 
        # an event is fired (dlg.evt_cbxExistingConn_changed())
        conn_f.get_qgis_postgres_conn_list(self.loader_dlg)

        self.DialogRegistry.update({self.loader_dlg.DIALOG_VAR_NAME: self.loader_dlg})

        self.check_concurrent_connections(self.loader_dlg)

        # Set the window modality.
        # Desired mode: When this dialogue is open, inputs in any other windows are blocked.
        # self.loader_dlg.setWindowModality(Qt.ApplicationModal) # i.e. 0, The window blocks input to other windows.
        self.loader_dlg.setWindowModality(Qt.NonModal) # i.e. 0, The window does not block input to other windows.

        # Show the dialog
        self.loader_dlg.show()
        # Run the dialog event loop.
        res = self.loader_dlg.exec_()

        if not res: # Dialog has been closed (X button was pressed)
            # Unlike with the admin Dialog, do not reset the GUI: the user may reopen it and use the same settings
            pass

        return None


    def run_deleter(self) -> None:
        """Run method that performs all the real work.
        -   Creates the plugin dialog
        -   Instantiates the plugin main class (CDB4DeleterDialog) with its GUI
        -   Sets up the plugin signals
        -   Executes the dialog
        """
        from .cdb4.gui_deleter.deleter_dialog import CDB4DeleterDialog # Deleter dialog
        from .cdb4.gui_db_connector.functions import conn_functions as conn_f        

        # Check once if the QGIS version is supported
        if self.first_check_QGIS_supported:
            self.first_check_QGIS_supported = False
            self.check_QGIS_version()

        # Only create GUI ONCE in callback, so that it will only load when the plugin is started.
        if self.first_start_deleter:
            self.first_start_deleter = False

            # Create the dialog with elements (after translation).
            self.deleter_dlg = CDB4DeleterDialog(cdbMain=self)

            # Replace empty graphics view widget with Map canvas.
            self.deleter_dlg.gLayoutBasemap.replaceWidget(self.deleter_dlg.gvCanvas, self.deleter_dlg.CANVAS)

            # Remove empty graphics View widget from dialog.
            self.deleter_dlg.gvCanvas.setParent(None)

        # Get existing connections from QGIS profile settings.
        # They are added to the combo box (cbxExistingConn), and 
        # an event is fired (dlg.evt_cbxExistingConn_changed())
        conn_f.get_qgis_postgres_conn_list(self.deleter_dlg) # Stored in self.conn

        self.DialogRegistry.update({self.deleter_dlg.DIALOG_VAR_NAME: self.deleter_dlg})

        self.check_concurrent_connections(self.deleter_dlg)

        # Set the window modality.
        # Desired mode: When this dialogue is open, inputs in any other windows are blocked.
        # self.deleter_dlg.setWindowModality(Qt.ApplicationModal) # The window blocks input from other windows.
        self.deleter_dlg.setWindowModality(Qt.NonModal) # i.e. 0, The window does not block input to other windows.

        # Show the dialog
        self.deleter_dlg.show()
        # Run the dialog event loop.
        res = self.deleter_dlg.exec_()

        if not res: # Dialog has been closed (X button was pressed)
            # Unlike with the admin Dialog, do not reset the GUI: the user may reopen it and use the same settings
            pass
        
        return None


    def run_admin(self) -> None:
        """Run method that performs all the real work.
        -   Creates the plugin dialog
        -   Instantiates the plugin main class (CDB4AdminDialog) with its GUI
        -   Sets up the plugin signals
        -   Executes the dialog
        """
        from .cdb4.gui_admin.admin_dialog import CDB4AdminDialog # Admin dialog
        from .cdb4.gui_db_connector.functions import conn_functions as conn_f

        # Check once if the QGIS version is supported
        if self.first_check_QGIS_supported:
            self.first_check_QGIS_supported = False
            self.check_QGIS_version()

        # Only create GUI ONCE in callback, so that it will only load when the plugin is started.
        if self.first_start_admin:
            self.first_start_admin = False
            # Create the dialog with elements (after translation).
            self.admin_dlg = CDB4AdminDialog()

        # Get existing connections from QGIS profile settings.
        # They are added to the combo box (cbxExistingConn), and 
        # an event is fired (dlg.evt_cbxExistingConn_changed())
        conn_f.get_qgis_postgres_conn_list(self.admin_dlg) # Stored in self.conn

        self.DialogRegistry.update({self.admin_dlg.DIALOG_VAR_NAME: self.admin_dlg})

        if len(self.DialogRegistry) > 1:
            close_dlg: bool = False
            close_conn: bool = False

            dlg: Union[CDB4AdminDialog, CDB4DeleterDialog, CDB4LoaderDialog]

            # Check whether there are open dialogs and open connections
            for key, dlg in self.DialogRegistry.items():
                if key != self.admin_dlg.DIALOG_VAR_NAME:
                    if dlg.isVisible():
                        close_dlg = True
                    if dlg.conn:
                        if dlg.conn.closed == 0:
                            close_conn = True

            # If so, inform the user and then close them.
            if close_dlg or close_conn:
                msg: str = f"In order to launch the '{self.admin_dlg.DIALOG_NAME}', you must first close all active connections and - if applicable - exit from other open {self.PLUGIN_NAME} GUI dialogs. If you choose to proceed, they will be automatically closed.\n\nDo you want to continue?"
                res = QMessageBox.question(self.admin_dlg, "Concurrent dialogs", msg)
                if res == QMessageBox.Yes: #16384: #YES

                    for key, dlg in self.DialogRegistry.items():
                        if key != self.admin_dlg.DIALOG_VAR_NAME:
                            if dlg:
                                if dlg.conn:
                                    if dlg.conn.closed == 0:
                                        dlg.conn.close() # close connection (if open)
                                dlg.dlg_reset_all() # reset dialog
                                dlg.close() # or dlg.reject()

                else:
                    return None # Exit and do nothing

        # Set the window modality.
        # Desired mode: When this dialogue is open, inputs in any other windows are blocked.
        self.admin_dlg.setWindowModality(Qt.ApplicationModal) # i.e The window is modal to the application and blocks input to all windows.
        # self.admin_dlg.setWindowModality(Qt.NonModal) # i.e. 0, The window does not block input to other windows.

        # Show the dialog
        self.admin_dlg.show()
        # Run the dialog event loop.
        res = self.admin_dlg.exec_()
      
        if not res: # Dialog has been closed (X button was pressed)
            # Reset the dialog widgets. (Closes the current open connection.)
            self.admin_dlg.dlg_reset_all() 
            if self.admin_dlg.conn:
                self.admin_dlg.conn.close()

        return None
    

    def run_usrguide(self) -> None:
        """ Opens the default web browser with the PDF file containing the installation and user guide.
        
        Qt offers PyQt5.QtWebEngineWidgets (QWebEngineView, QWebEngineSettings) but they are not
        available from pyQGIS

        NOTE: webbrowser will be removed from Python v. 3.13 (QGIS using 3.9 at the moment...)
        """
        print(main_c.URL_PDF_USER_GUIDE)
        webbrowser.open_new_tab(main_c.URL_PDF_USER_GUIDE)

        return None


    def run_about(self) -> None:
        """Run method that performs all the real work.
        -   Creates the plugin dialog
        -   Instantiates the plugin class (CDBAboutDialog) with its GUI
        -   Sets up the plugin signals
        -   Executes the dialog
        """
        from .gui_about.about_dialog import CDBAboutDialog # About dialog

        # Only create GUI ONCE in callback, so that it will only load when the plugin is started.
        if self.first_start_about:
            self.first_start_about = False
            # Create the dialog with elements (after translation).
            self.about_dlg = CDBAboutDialog()

        # Set the window modality.
        #self.about_dlg.setWindowModality(Qt.ApplicationModal) # i.e The window is modal to the application and blocks input to all windows.
        self.about_dlg.setWindowModality(Qt.NonModal) # i.e. 0, The window does not block input to other windows.

        # Show the dialog
        self.about_dlg.show()
        # Run the dialog event loop.
        res = self.about_dlg.exec_()
      
        if not res: # Dialog has been closed (X button was pressed)
            # Reset the dialog widget.
            self.about_dlg.close() 

        return None


    def check_concurrent_connections(self, dlg: Union[CDB4DeleterDialog, CDB4LoaderDialog]) -> None:
        """ Before opening a user dialog (e.g. the Loader or the Deleter), it checks whether
        the CDB4AdminDialog is open and whether its connection is open. If so, and the users wants to proceed,
        they are both closed.
        """
        if len(self.DialogRegistry) > 1:
            close_admin_dlg: bool = False
            close_admin_conn: bool = False
            if main_c.DLG_VAR_NAME_ADMIN in self.DialogRegistry:
                if self.admin_dlg.isVisible():
                    close_admin_dlg = True
                if self.admin_dlg.conn:
                    if self.admin_dlg.conn.closed == 0:
                        close_admin_conn = True

            if close_admin_dlg:
                msg: str = f"In order to launch the '{dlg.DIALOG_NAME}', you must first close the '{self.admin_dlg.DIALOG_NAME}'. If you choose to proceed, it will be automatically closed.\n\nDo you want to continue?"
                res = QMessageBox.question(dlg, "Concurrent dialogs", msg)
                if res == 16384: #YES
                    if close_admin_conn:
                        self.admin_dlg.conn.close()
                    if close_admin_dlg:
                        self.admin_dlg.dlg_reset_all()
                        self.admin_dlg.close()

            return None


    def check_QGIS_version(self) -> None:
        """ Check if QGIS is supported by the plug-in (LTR versions)
        """
        if self.QGIS_VERSION_MINOR in main_c.QGIS_LTR:
            self.IS_QGIS_SUPPORTED = True
        else:
            self.IS_QGIS_SUPPORTED = False
        #print(f"Is QGIS supported? {self.IS_QGIS_SUPPORTED}")

        if not self.IS_QGIS_SUPPORTED:
            v_supp = " and ".join(tuple(["3." + str(i) for i in main_c.QGIS_LTR]))
            msg: str = f"You are using <b>QGIS v. {self.QGIS_VERSION_MAJOR}.{self.QGIS_VERSION_MINOR}.{self.QGIS_VERSION_REV}</b>, for which the <b>{self.PLUGIN_NAME}</b> plug-in is not thorougly tested. You can still use the plug-in (and it will generally work fine!), but you may encounter some unexpected behaviour.<br><br>You are suggested to use a <b>QGIS LTR (Long Term Release) version</b>.<br>Currently, these versions are supported: <b>{v_supp}</b>!"
            QMessageBox.warning(None, "Unsupported QGIS version", msg, QMessageBox.Ok)

        return None
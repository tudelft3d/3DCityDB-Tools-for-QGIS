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
from typing import TYPE_CHECKING, Union, Optional, Callable
if TYPE_CHECKING:       
    from .cdb4.gui_admin.admin_dialog import CDB4AdminDialog
    from .cdb4.gui_loader.loader_dialog import CDB4LoaderDialog
    from .cdb4.gui_deleter.deleter_dialog import CDB4DeleterDialog    
    from .shared.gui_about.about_dialog import CDBAboutDialog
 
import os.path
import platform

from qgis.PyQt.QtCore import Qt, QSettings, QTranslator, QCoreApplication, QT_VERSION_STR
from qgis.PyQt.QtGui import QIcon
from qgis.PyQt.QtWidgets import QAction, QWidget, QMessageBox, QMenu
from qgis.core import Qgis, QgsSettings, QgsMessageLog
from qgis.gui import QgisInterface

from . import cdb_tools_main_constants as main_c
from .shared.functions import shared_functions as sh_f
from .cdb4.gui_db_connector.other_classes import DBConnectionInfo


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

        # Determine the platform we are running on

        # Get the system/OS name, such as 'Linux', 'Darwin', 'Java', 'Windows'.
        # An empty string is returned if the value cannot be determined.
        self.PLATFORM_SYSTEM: str = platform.system()
        # print("Plaform system is:", self.PLATFORM_SYSTEM)

        ######################################################
        # Only for testing purposes
        # self.PLATFORM_SYSTEM: str = "Linux"
        # print("Plaform system is:", self.PLATFORM_SYSTEM)
        ######################################################

        # initialize plugin full path (including plugin directory).
        self.URL_GITHUB_PLUGIN: str = main_c.URL_GITHUB_PLUGIN
        self.PLUGIN_ABS_PATH: str = main_c.PLUGIN_ABS_PATH
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
        # PLEASE NOTE: Rich text support is not recognised anymore and stripped from msg strings since 3.40 of QgsMeesageLog.
        msg: str = f"\n\n------ WELCOME! -------\nYou are using the {self.PLUGIN_NAME} v. {self.PLUGIN_VERSION_TXT} plug-in for Qt {QT_VERSION_STR} running on QGIS v. {self.QGIS_VERSION_MAJOR}.{self.QGIS_VERSION_MINOR}.{self.QGIS_VERSION_REV} on a {self.PLATFORM_SYSTEM} machine.\n-----------------------------\n"
 
        QgsMessageLog.logMessage(msg, self.PLUGIN_NAME, level=Qgis.MessageLevel.Info, notifyUser=False)

        self.StoredConns = self.list_qgis_postgres_stored_conns()
        # print("self.StoredConns", self.StoredConns)

        # Variable to store the loader dialog of the plugin.
        self.loader_dlg: CDB4LoaderDialog = None
        # Check if plugin was started the first time in current QGIS session.
        self.first_start_loader: bool = True
        self.MENU_LABEL_LOADER: str = main_c.MENU_LABEL_LOADER
        self.DLG_NAME_LOADER: str = main_c.DLG_NAME_LOADER

        # Variable to store the deleter dialog of the plugin.
        self.deleter_dlg: CDB4DeleterDialog = None
        # Check if plugin was started the first time in current QGIS session.
        self.first_start_deleter: bool = True
        self.MENU_LABEL_DELETER: str = main_c.MENU_LABEL_DELETER
        self.DLG_NAME_DELETER: str = main_c.DLG_NAME_DELETER

        # Variable to store the admin dialog of the plugin.
        self.admin_dlg: CDB4AdminDialog = None
        # Check if plugin was started the first time in current QGIS session.
        self.first_start_admin: bool = True
        self.MENU_LABEL_ADMIN: str = main_c.MENU_LABEL_ADMIN
        self.DLG_NAME_ADMIN: str = main_c.DLG_NAME_ADMIN

        # Variable to store the about dialog of the plugin.
        self.about_dlg: CDBAboutDialog = None
        # Check if plugin was started the first time in current QGIS session.
        self.first_start_about: bool = True
        self.MENU_LABEL_ABOUT: str = main_c.MENU_LABEL_ABOUT
        self.DLG_NAME_ABOUT: str = main_c.DLG_NAME_ABOUT

        self.DialogRegistry: dict[str, Union[CDB4AdminDialog, CDB4DeleterDialog, CDB4LoaderDialog]] = {}

        # initialize locale.
        # locale = QSettings().value("locale/userLocale")[0:2]
        # locale_path = os.path.join(self.PLUGIN_ABS_PATH, "i18n", "CDBToolsMain_{}.qm".format(locale))
        # if os.path.exists(locale_path):
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
        return QCoreApplication.translate("3DCityDB Tools", message)


    def add_action(self,
            icon_path: str,
            txt: str,
            callback: Callable[..., None],
            enabled_flag: bool = True,
            add_to_menu: bool = True,
            add_to_toolbar: bool = True,
            status_tip: Optional[str] = None,
            whats_this: Optional[str] = None,
            parent: Optional[QWidget] = None) -> QAction:
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
        action.triggered.connect(slot=callback)
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
        icon_path_loader  = os.path.join(self.PLUGIN_ABS_PATH, "icons", "loader_icon.png")
        icon_path_deleter = os.path.join(self.PLUGIN_ABS_PATH, "icons", "deleter_icon.png")
        icon_path_admin   = os.path.join(self.PLUGIN_ABS_PATH, "icons", "admin_icon.png")
        icon_path_usrguide= os.path.join(self.PLUGIN_ABS_PATH, "icons", "help_icon.png")
        icon_path_about   = os.path.join(self.PLUGIN_ABS_PATH, "icons", "info_icon.png")

        # Loader Dialog
        self.add_action(
            icon_path = icon_path_loader,
            #txt = self.tr(self.PLUGIN_NAME_LOADER),
            txt = self.MENU_LABEL_LOADER,
            callback = self.run_loader,
            parent = self.iface.mainWindow(),
            add_to_menu = True,
            add_to_toolbar = True) # Default: True

        # Deleter Dialog
        self.add_action(
            icon_path = icon_path_deleter,
            txt = main_c.MENU_LABEL_DELETER,
            callback = self.run_deleter,
            parent = self.iface.mainWindow(),
            add_to_menu = True,
            add_to_toolbar = True) # Default: True

        # Admin Dialog
        self.add_action(
            icon_path = icon_path_admin,
            txt = self.MENU_LABEL_ADMIN,
            callback = self.run_admin,
            parent = self.iface.mainWindow(),
            add_to_menu = True,
            add_to_toolbar = True)

        # Add separator
        sep: QAction = QAction() # must create a new object every time!
        sep.setSeparator(True)
        sep.setParent(self.iface.mainWindow())
        self.iface.addPluginToDatabaseMenu(name=self.PLUGIN_NAME, action=sep)
        self.actions.append(sep)

        # User guide link
        self.add_action(
            icon_path = icon_path_usrguide,
            txt = main_c.MENU_LABEL_USRGUIDE,
            callback = self.run_usr_guide,
            parent = self.iface.mainWindow(),
            add_to_menu = True,
            add_to_toolbar = False)

        # About Dialog - Leave this at the end, so it will be the last icon.
        self.add_action(
            icon_path = icon_path_about,
            txt = self.MENU_LABEL_ABOUT,
            callback = self.run_about,
            parent = self.iface.mainWindow(),
            add_to_menu = True,
            add_to_toolbar = True)

        #####################################################################
        #
        # For submenus, you must also uncomment the parts at the beginning of this function
        #
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

        # ############### Add submenu to root/container entry
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

        # Check once if the QGIS version is supported
        if self.first_check_QGIS_supported:
            self.first_check_QGIS_supported = False
            self.check_QGIS_version()

        # Get/refresh the existing connections list from QGIS profile settings.
        stored_conns = self.list_qgis_postgres_stored_conns()

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

            if stored_conns != self.StoredConns:
                # print('Changes in connection list')
                self.StoredConns = stored_conns

            # 1st run: box to be filled anyway
            # Add the connection list to the combo box (cbxExistingConn) 
            # An event is fired (dlg.evt_cbxExistingConn_changed())
            # It closes all exiting connections, and resets the dialog.
            self.fill_connection_list_box(dlg=self.loader_dlg, stored_conns=self.StoredConns)

        else:
            if stored_conns != self.StoredConns:
                # print('Nth run: Changes in connection list')
                self.StoredConns = stored_conns
                # N-th run: to be carried out only in case of changes
                # Add the connection list to the combo box (cbxExistingConn) 
                # An event is fired (dlg.evt_cbxExistingConn_changed())
                # It closes all exiting connections, and resets the dialog.
                self.fill_connection_list_box(dlg=self.loader_dlg, stored_conns=self.StoredConns)
            else:
                # No need to refresh the connection list box, no event is fired
                # The Connection remains open and all settings are still there.
                # print('Nth run: No changes in connection list')
                pass

        self.DialogRegistry.update({self.DLG_NAME_LOADER: self.loader_dlg})

        self.check_concurrent_connections(self.loader_dlg)

        # Set the window modality.
        # Desired mode: When this dialogue is open, inputs in any other windows are blocked.
        # self.loader_dlg.setWindowModality(Qt.WindowModality.ApplicationModal) # i.e. The window blocks input to other windows.
        self.loader_dlg.setWindowModality(Qt.WindowModality.NonModal) # i.e. The window does not block input to other windows.

        # Show the dialog
        self.loader_dlg.show()
        # Run the dialog event loop.
        res = self.loader_dlg.exec()

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

        # Check once if the QGIS version is supported
        if self.first_check_QGIS_supported:
            self.first_check_QGIS_supported = False
            self.check_QGIS_version()

        # Get/refresh the existing connections list from QGIS profile settings.
        stored_conns = self.list_qgis_postgres_stored_conns()

        # Only create GUI ONCE in callback, so that it will only load when the plugin is started.
        if self.first_start_deleter:
            self.first_start_deleter = False

            # Create the dialog with elements (after translation).
            self.deleter_dlg = CDB4DeleterDialog(cdbMain=self)

            # Replace empty graphics view widget with Map canvas.
            self.deleter_dlg.gLayoutBasemap.replaceWidget(self.deleter_dlg.gvCanvas, self.deleter_dlg.CANVAS)

            # Remove empty graphics View widget from dialog.
            self.deleter_dlg.gvCanvas.setParent(None)

            if stored_conns != self.StoredConns:
                # print('Changes in connection list')
                self.StoredConns = stored_conns

            self.fill_connection_list_box(dlg=self.deleter_dlg, stored_conns=self.StoredConns)

        else:
            if stored_conns != self.StoredConns:
                self.StoredConns = stored_conns
                self.fill_connection_list_box(dlg=self.deleter_dlg, stored_conns=self.StoredConns)

        self.DialogRegistry.update({self.DLG_NAME_DELETER: self.deleter_dlg})

        self.check_concurrent_connections(self.deleter_dlg)

        # Set the window modality.
        # Desired mode: When this dialogue is open, inputs in any other windows are blocked.
        # self.deleter_dlg.setWindowModality(Qt.WindowModality.ApplicationModal) # The window blocks input from other windows.
        self.deleter_dlg.setWindowModality(Qt.WindowModality.NonModal) # i.e. 0, The window does not block input to other windows.

        # Show the dialog
        self.deleter_dlg.show()
        # Run the dialog event loop.
        res = self.deleter_dlg.exec()

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

        # Check once if the QGIS version is supported
        if self.first_check_QGIS_supported:
            self.first_check_QGIS_supported = False
            self.check_QGIS_version()

        # Get/refresh the existing connections list from QGIS profile settings.
        stored_conns = self.list_qgis_postgres_stored_conns()

        # Only create GUI ONCE in callback, so that it will only load when the plugin is started.
        if self.first_start_admin:
            self.first_start_admin = False
            # Create the dialog with elements (after translation).
            self.admin_dlg = CDB4AdminDialog(cdbMain=self)

            if stored_conns != self.StoredConns:
                self.StoredConns = stored_conns

            self.fill_connection_list_box(dlg=self.admin_dlg, stored_conns=self.StoredConns)

        else:
            if stored_conns != self.StoredConns:
                self.StoredConns = stored_conns
                self.fill_connection_list_box(dlg=self.admin_dlg, stored_conns=self.StoredConns)

        self.DialogRegistry.update({self.DLG_NAME_ADMIN: self.admin_dlg})

        if len(self.DialogRegistry) > 1:
            close_dlg: bool = False
            close_conn: bool = False

            # Check whether there are open dialogs and open connections
            for key, dlg in self.DialogRegistry.items():
                if key != self.DLG_NAME_ADMIN:
                    if dlg.isVisible():
                        close_dlg = True
                    if dlg.conn:
                        if dlg.conn.closed == 0:
                            close_conn = True

            # If so, inform the user and then close them.
            if close_dlg or close_conn:
                msg: str = f"In order to launch the '{self.MENU_LABEL_ADMIN}', you must first close all active connections and - if applicable - exit from other open {self.PLUGIN_NAME} GUI dialogs.\nIf you choose to proceed, they will be automatically closed.\n\nDo you want to continue?"
                res = QMessageBox.question(self.admin_dlg, "Concurrent dialogs", msg)
                if res == QMessageBox.StandardButton.Yes:

                    for key, dlg in self.DialogRegistry.items():
                        if key != self.DLG_NAME_ADMIN:
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
        self.admin_dlg.setWindowModality(Qt.WindowModality.ApplicationModal) # i.e. The window is modal to the application and blocks input to all windows.
        # self.admin_dlg.setWindowModality(Qt.WindowModality.NonModal) # i.e. The window does not block input to other windows.

        # Show the dialog
        self.admin_dlg.show()
        # Run the dialog event loop.
        res = self.admin_dlg.exec()
      
        if not res: # Dialog has been closed (X button was pressed)
            # Reset the dialog widgets. (Closes the current open connection.)
            self.admin_dlg.dlg_reset_all() 
            if self.admin_dlg.conn:
                self.admin_dlg.conn.close()

        return None
    

    def run_usr_guide(self) -> None:
        """ Opens the PDF containing the User Guide of the plugin
        For Windows OS: Opens the default web browser with the PDF file containing the installation and user guide.
        Otherwise: Opens the url to the PDF in GitHub.
        """
        file_name: str = "3DCityDB-Tools_UserGuide.pdf"
        url = "/".join([self.URL_GITHUB_PLUGIN, "blob", "v." + self.PLUGIN_VERSION_TXT, "manuals", file_name])
        sh_f.open_online_url(url=url)

        return None


    def run_about(self) -> None:
        """Run method that performs all the real work.
        -   Creates the plugin dialog
        -   Instantiates the plugin class (CDBAboutDialog) with its GUI
        -   Sets up the plugin signals
        -   Executes the dialog
        """
        from .shared.gui_about.about_dialog import CDBAboutDialog # About dialog

        # Only create GUI ONCE in callback, so that it will only load when the plugin is started.
        if self.first_start_about:
            self.first_start_about = False
            # Create the dialog with elements (after translation).
            self.about_dlg = CDBAboutDialog(cdbMain=self)

        # Set the window modality.
        #self.about_dlg.setWindowModality(Qt.WindowModality.ApplicationModal) # i.e The window is modal to the application and blocks input to all windows.
        self.about_dlg.setWindowModality(Qt.WindowModality.NonModal) # i.e. 0, The window does not block input to other windows.

        # Show the dialog
        self.about_dlg.show()
        # Run the dialog event loop.
        res = self.about_dlg.exec()
      
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
            if main_c.DLG_NAME_ADMIN in self.DialogRegistry:
                if self.admin_dlg.isVisible():
                    close_admin_dlg = True
                if self.admin_dlg.conn:
                    if self.admin_dlg.conn.closed == 0:
                        close_admin_conn = True

            if close_admin_dlg:
                msg: str = f"In order to launch the '{dlg.DLG_NAME_LABEL}', you must first close the '{self.admin_dlg.DLG_NAME_LABEL}'. If you choose to proceed, it will be automatically closed.\n\nDo you want to continue?"
                res = QMessageBox.question(dlg, "Concurrent dialogs", msg)
                if res == QMessageBox.StandardButton.Yes:
                    if close_admin_conn:
                        self.admin_dlg.conn.close()
                    if close_admin_dlg:
                        self.admin_dlg.dlg_reset_all()
                        self.admin_dlg.close()

            return None


    def check_QGIS_version(self) -> None:
        """ Check if QGIS is supported by the plug-in (LTR versions)
        """
        # ****** For testing purposed only
        #from qgis.PyQt.QtCore import QT_VERSION_STR, PYQT_VERSION_STR
        #print("Qt: v.", QT_VERSION_STR,"\tPyQt5: v.", PYQT_VERSION_STR)        
        #self.QGIS_VERSION_MINOR = 46
        # ********************************

        if self.QGIS_VERSION_MINOR in main_c.QGIS3_VERSION_MINOR:
            self.IS_QGIS_SUPPORTED = True
        else:
            self.IS_QGIS_SUPPORTED = False
            # print(f"Is QGIS supported? {self.IS_QGIS_SUPPORTED}")

            lowest_supported_minor_version :int = min(main_c.QGIS3_VERSION_MINOR)
            #print('lowest_supported_minor_version', lowest_supported_minor_version)

            if self.QGIS_VERSION_MINOR < lowest_supported_minor_version:
                msg_rich: str = f"You are using <b>QGIS v. {self.QGIS_VERSION_MAJOR}.{self.QGIS_VERSION_MINOR}.{self.QGIS_VERSION_REV}</b>, which is not supported anymore and for which the <b>{self.PLUGIN_NAME}</b> plug-in is not thorougly tested. You can still use the plug-in, but you may encounter some unexpected behaviour.<br><br>You are suggested to use a more recent version of <b>QGIS LTR (Long Term Release)</b>.<br>"

            else:
                msg_rich: str = f"You are using <b>QGIS v. {self.QGIS_VERSION_MAJOR}.{self.QGIS_VERSION_MINOR}.{self.QGIS_VERSION_REV}</b>, for which the <b>{self.PLUGIN_NAME}</b> plug-in is not thorougly tested. You can still use the plug-in (and it will generally work fine!), but you may encounter some unexpected behaviour.<br><br>You are suggested to use a <b>QGIS LTR (Long Term Release) version</b>.<br>"

            v_length = len(main_c.QGIS3_VERSION_MINOR)
            if v_length == 1:
                v_supp_txt =f"3.{main_c.QGIS3_VERSION_MINOR[0]}" 
                msg_rich = msg_rich + f"Currently, only this version is supported: <b>{v_supp_txt}</b>!"
            else:
                if v_length == 2:
                    v_supp_txt = f"3.{main_c.QGIS3_VERSION_MINOR[0]} and 3.{main_c.QGIS3_VERSION_MINOR[1]}"
                elif v_length >= 3:
                    v_supp_txt = ", ".join(tuple(["3." + str(val) for i, val in enumerate(main_c.QGIS3_VERSION_MINOR) if i < (v_length - 1)]))                
                    v_supp_txt = f"{v_supp_txt} and 3.{main_c.QGIS3_VERSION_MINOR[-1]}"
                msg_rich = msg_rich + f"Currently, these versions are supported: <b>{v_supp_txt}</b>!"

            QMessageBox.warning(None, "Unsupported QGIS version", msg_rich, QMessageBox.StandardButton.Ok)

        return None


    def fill_connection_list_box(self, dlg: Union[CDB4LoaderDialog, CDB4DeleterDialog, CDB4AdminDialog], 
                                stored_conns: Optional[list[tuple[str, dict]]] = None
                                ) -> None:
        """Function that fills the the 'cbxExistingConn' combobox
        """
        # Clear the contents of the comboBox from previous runs
        dlg.cbxExistingConn.clear()

        if stored_conns:
            # Get database connection settings for every stored connection
            for stored_conn_name, stored_conn_params in stored_conns:

                label: str = stored_conn_name
                # Create object
                db_conn_info = DBConnectionInfo()

                # Populate the object attributes BEGIN
                db_conn_info.connection_name   = label
                db_conn_info.database_name     = stored_conn_params['database']
                db_conn_info.host              = stored_conn_params['host']
                db_conn_info.port              = stored_conn_params['port']
                db_conn_info.username          = stored_conn_params['username']
                db_conn_info.password          = stored_conn_params['password']
                db_conn_info.db_toc_node_label = stored_conn_params['db_toc_node_label']
                # Populate the object attributes END

                dlg.cbxExistingConn.addItem(label, userData=db_conn_info)

        return None


    def list_qgis_postgres_stored_conns(self) -> Optional[list[tuple[str, dict]]]:
        """Function that reads the QGIS user settings to look for existing connections
        It results in a list[tuple[str, dict]]
        """
        # Create a QgsSettings object to access the settings
        qgis_settings = QgsSettings()

        # Navigate to PostgreSQL connection settings
        qgis_settings.beginGroup(prefix='PostgreSQL/connections')

        # Get all stored connection names
        stored_conn_list = qgis_settings.childGroups()
        # print('stored_connections', stored_connections)

        stored_conns = []

        # Get database connection settings for every stored connection
        for stored_conn in stored_conn_list:

            db_conn_info_dict = dict()

            qgis_settings.beginGroup(prefix=stored_conn)
            # Populate the object BEGIN
            db_conn_info_dict['database']          = qgis_settings.value(key='database')
            db_conn_info_dict['host']              = qgis_settings.value(key='host')
            db_conn_info_dict['port']              = qgis_settings.value(key='port')
            db_conn_info_dict['username']          = qgis_settings.value(key='username')
            db_conn_info_dict['password']          = qgis_settings.value(key='password')
            db_conn_info_dict['db_toc_node_label'] = qgis_settings.value(key='database') + " @ " + qgis_settings.value(key='host') + ":" + str(qgis_settings.value(key='port'))

            # print('read from stored conns', db_conn_info_dict['db_toc_node_label'])

            # Populate the object END
            qgis_settings.endGroup()

            t: tuple[str, dict] = (stored_conn, db_conn_info_dict)
            stored_conns: list[tuple[str, dict]]
            stored_conns.append(t)
        
        stored_conns.sort()
        # stored_conns.sort(reverse=True)
        # print(stored_conns)

        return stored_conns



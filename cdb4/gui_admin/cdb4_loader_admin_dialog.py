# -*- coding: utf-8 -*-
"""
/***************************************************************************
 CDB4LoaderAdminDialog
                                 A QGIS plugin
                This is a plugin for the CityGML 3D City Database.
 Generated by Plugin Builder: http://g-sherman.github.io/Qgis-Plugin-Builder/
                             -------------------
        begin                : 2021-09-30
        git sha              : $Format:%H$
        author(s)            : Konstantinos Pantelios
                               Giorgio Agugiaro
        email                : konstantinospantelios@yahoo.com
                               g.agugiaro@tudelft.nl
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

from qgis.core import Qgis, QgsMessageLog

import os
from qgis.PyQt import uic, QtWidgets

from qgis.gui import QgsMessageBar
from qgis.PyQt.QtWidgets import QMessageBox

from ...cdb_loader import CDBLoader # Used only to add the type of the function parameters

from ..gui_db_connector.db_connection_dialog import DBConnectorDialog
from ..gui_db_connector.functions import conn_functions as conn_f

from .. import cdb4_constants as c
from .functions import tab_conn_widget_functions as wf

from .functions import sql
from .functions import qgis_pkg_installation as inst
from ..shared.functions import sql as sh_sql

# This loads the .ui file so that PyQt can populate the plugin
# with the elements from Qt Designer
FORM_CLASS, _ = uic.loadUiType(os.path.join(os.path.dirname(__file__), "ui", "cdb4_loader_admin_dialog.ui"))

class CDB4LoaderAdminDialog(QtWidgets.QDialog, FORM_CLASS):
    """Administrator Dialog class of the plugin.
    The GUI is imported from an external .ui xml
    """

    def __init__(self, cdbLoader, parent=None):
        """Constructor."""
        super(CDB4LoaderAdminDialog, self).__init__(parent)
        # Set up the user interface from Designer through FORM_CLASS.
        # After self.setupUi() you can access any designer object by doing
        # self.<objectname>, and you can use autoconnect slots

        self.setupUi(self)

        # Initialize some properties.
        # This is used in order to revert to the original state
        # in reset operations when original text has already changed.
        self.btnConnectToDb.init_text = c.btnConnectToDbC_t
        self.btnMainInst.init_text = c.btnMainInst_t
        self.btnMainUninst.init_text=  c.btnMainUninst_t
        self.btnUsrInst.init_text = c.btnUsrInst_t
        self.btnUsrUninst.init_text = c.btnUsrUninst_t

        #- SIGNALS  (start)  ################################################################

        # 'Connection' group box signals
        self.cbxExistingConn.currentIndexChanged.connect(lambda: self.evt_cbxExistingConn_changed(cdbLoader))
        self.btnNewConn.clicked.connect(lambda: self.evt_btnNewConn_clicked(cdbLoader))
        self.btnConnectToDb.clicked.connect(lambda: self.evt_btnConnectToDb_clicked(cdbLoader))

        # 'Main Installation' group box signals
        self.btnMainInst.clicked.connect(lambda: self.evt_btnMainInst_clicked(cdbLoader))
        self.btnMainUninst.clicked.connect(lambda: self.evt_btnMainUninst_clicked(cdbLoader))

        # 'User Installation' group box signals
        self.cbxUser.currentIndexChanged.connect(lambda: self.evt_cbxUser_changed(cdbLoader))
        self.btnUsrInst.clicked.connect(lambda: self.evt_btnUsrInst_clicked(cdbLoader))
        self.btnUsrUninst.clicked.connect(lambda: self.evt_btnUsrUninst_clicked(cdbLoader))
        
        # Close connection button
        self.btnCloseConn.clicked.connect(lambda: self.evt_btnCloseConn_clicked(cdbLoader))

        #-SIGNALS  (end)  ################################################################

    #-EVENT FUNCTIONS (begin)  #####################################################################

    #'Connection' group box events
    def evt_cbxExistingConn_changed(self, cdbLoader: CDBLoader) -> None:
        """Event that is called when the 'Existing Connection' comboBox (cbxExistingConn) current index changes.
        This function runs every time the current selection of 'Existing Connection' changes.
        """
        # Set the current database connection object variable
        cdbLoader.DB = self.cbxExistingConn.currentData()
        if not cdbLoader.DB:
            return None
        
        # Variable to store the plugin main dialog
        dlg = cdbLoader.admin_dlg
        db_name = cdbLoader.DB.database_name

        # Close the current open connection.
        if cdbLoader.conn is not None:
            cdbLoader.conn.close()

        # Reset the Database Administration tab from previous other content.
        wf.tabDbAdmin_reset(cdbLoader) # disables it

        # Enable tab.
        dlg.tabDbAdmin.setDisabled(False)

        # Enable button to connect.
        dlg.btnConnectToDb.setText(dlg.btnConnectToDb.init_text.format(db=db_name))
        dlg.btnConnectToDb.setDisabled(False)

    
    def evt_btnNewConn_clicked(self, cdbLoader: CDBLoader) -> None:
        """Event that is called when the 'New Connection' pushButton (btnNewConn) is pressed.
        Responsible to add VALID new connection to the 'Existing connections'.
        """
        # Bypass the input blockade for the connector dialogue.
        self.setWindowModality(1)

        # Create/Show/Execute additional dialog for the new connection
        dlgConnector = DBConnectorDialog()
        dlgConnector.setWindowModality(2)
        dlgConnector.show()
        dlgConnector.exec_()

        # Variable to store the plugin main dialog.
        dlg = cdbLoader.admin_dlg

        # Add new connection to the Existing connections
        if dlgConnector.new_connection:
            dlg.cbxExistingConn.addItem(f"{dlgConnector.new_connection.connection_name}", dlgConnector.new_connection)
            #dlgConnector.close()

        # Re-set the input blockage
        self.setWindowModality(2)


    def evt_btnConnectToDb_clicked(self, cdbLoader: CDBLoader) -> None:
        """Event that is called when the current 'Connect to {db}' pushButton
        (btnConnectToDb) is pressed.
        """
        # Variable to store the plugin main dialog.
        dlg = cdbLoader.admin_dlg
        db = cdbLoader.DB

        error_msg: str = None

        # Enable 'Connection Status' group box.
        dlg.gbxConnStatus.setDisabled(False)
        dlg.btnCloseConn.setDisabled(False)

        # -------------------------------------------------------------------------------------------
        # Series of tests to be carried out when I connect as admin.
        #
        # 1) Can I connect to the database?
        #        if yes: Is the PostgreSQL version >= 10? 
        #           If yes, continue
        #           if no, exit
        #        If yes: is the user a superuser?
        #            if yes, continue
        #            if no, exit
        #        if no, exit
        # 2) Is the 3DCityDB installed? 
        #       If yes, is it v. 4?
        #           If yes, continue
        #           iF no, exit
        #       If no, exit


        # 3) Is the QGIS Package already installed?
        #       if yes: Is it a compatible version?
        #                if yes, continue
        #                if no, inform the user that an upgrade is required
        #       if no: continue and offer to install
        # -------------------------------------------------------------------------------------------


        # 1) Can I connect to the database?

        # Attempt to connect to the database, returns True/False, and if successful, store connection in cdbLoader.conn
        # Additionally, set cdbLoader.DB.pg_server_version
        is_connection_successful: bool = conn_f.open_and_set_connection(cdbLoader, cdbLoader.PLUGIN_NAME_ADMIN)

        if is_connection_successful:
            # Show database name
            dlg.lblConnToDb_out.setText(c.success_html.format(text=db.database_name))
            
            # Check that the PosgreSQL version is supported (i.e. >= v. 10.0)
            postgres_major_version: int = int(db.pg_server_version.split(".")[0])

            # Only for debugging purposes
            #postgres_major_version: int = 9

            if postgres_major_version >= c.PG_MIN_VERSION:
                # Show PostgreSQL version in green and continue (all fine)
                dlg.lblPostInst_out.setText(c.success_html.format(text=db.pg_server_version))
            else:
                dlg.lblPostInst_out.setText(c.failure_html.format(text=c.PG_VERSION_UNSUPPORTED_MSG))

                error_msg = f"You are connecting to PostgreSQL version {db.pg_server_version}. This version is not supported, you need v.{c.PG_MIN_VERSION} or higher."
                #QgsMessageLog.logMessage(error_msg, main_c.PLUGIN_NAME, level=Qgis.Critical)
                QMessageBox.critical(dlg, "Unsupported PostgreSQL version", error_msg)

                wf.tabDbAdmin_reset(cdbLoader)
                return None # Exit

            # Check whether the user is an admin.
            is_superuser: bool = sql.is_superuser(cdbLoader)

            if not is_superuser:
                error_msg = f"User '{db.username}' is not a database superuser. Please contact your database administrator."
                #QgsMessageLog.logMessage(error_msg, main_c.PLUGIN_NAME, level=Qgis.Critical)
                QMessageBox.critical(dlg, "Insufficient user privileges", error_msg)

                wf.tabDbAdmin_reset(cdbLoader)
                return None # Exit

        else: # Connection failed!
            wf.gbxConnStatus_reset(cdbLoader)
            dlg.gbxConnStatusC.setDisabled(False)
            dlg.lblConnToDb_out.setText(c.failure_html.format(text=c.CONN_FAIL_MSG))
            dlg.lblPostInst_out.setText(c.failure_html.format(text=c.PG_SERVER_FAIL_MSG))

            wf.tabDbAdmin_reset(cdbLoader)
            return None # Exit

        # 2) Is the 3DCityDB installed? 

        # Check that database has 3DCityDB installed.
        is_3dcitydb_installed: bool = sql.is_3dcitydb_installed(cdbLoader)

        # Only for debugging purposes
        #is_3dcitydb_installed = False

        if is_3dcitydb_installed:

            citydb_version_major: int = int(db.citydb_version.split(".")[0])

            # Only for debugging purposes
            #citydb_version_major: int = 3

            if citydb_version_major == c.CDB_MIN_VERSION:
                # Show 3DCityDB version
                dlg.lbl3DCityDBInst_out.setText(c.success_html.format(text=db.citydb_version))
            else:
                dlg.lbl3DCityDBInst_out.setText(c.crit_warning_html.format(text=f"{db.citydb_version} (required v. {c.CDB_MIN_VERSION}.x)"))
                #cdbLoader.DB.green_citydb_inst = False

                error_msg = f"The current version of the 3D City Database installed in this database is v. {db.citydb_version} and is not supported. You need 3D City Database v. {c.CDB_MIN_VERSION}.x."
                #QgsMessageLog.logMessage(error_msg, main_c.PLUGIN_NAME, level=Qgis.Critical)
                QMessageBox.critical(dlg, "Unsupported 3D City Database version", error_msg)

                wf.tabDbAdmin_reset(cdbLoader)
                return None
        else:
            dlg.lbl3DCityDBInst_out.setText(c.failure_html.format(text=c.CDB_FAIL_MSG))

            error_msg = f"The 3D City Database is not installed in this database."
            #QgsMessageLog.logMessage(error_msg, main_c.PLUGIN_NAME, level=Qgis.Critical)
            QMessageBox.critical(dlg, "No 3DCityDB found", error_msg)

            wf.tabDbAdmin_reset(cdbLoader)
            return None # Exit

        #From here on, no need to exit the function anymore with return None.

        # 3) Is the QGIS Package already installed?

        # Fill out the labels of the buttons, no matter what.
        dlg.btnMainInst.setText(dlg.btnMainInst.init_text.format(db=db.database_name))
        dlg.btnMainUninst.setText(dlg.btnMainUninst.init_text.format(db=db.database_name))
        # Enable 'Main installation' group box.
        dlg.gbxMainInst.setDisabled(False)

        # Check if the qgis_pkg schema (main installation) is installed in database.
        is_qgis_pkg_installed: bool = sh_sql.is_qgis_pkg_installed(cdbLoader)

        # Only for debugging purposes
        #is_qgis_pkg_installed: bool = False

        if is_qgis_pkg_installed:
           
            # Get the current qgis_pkg version and check that it is compatible.
            qgis_pkg_curr_version: tuple = sh_sql.exec_qgis_pkg_version(cdbLoader)
            
            qgis_pkg_curr_version_txt      : str = qgis_pkg_curr_version[0]
            qgis_pkg_curr_version_major    : int = qgis_pkg_curr_version[2]
            qgis_pkg_curr_version_minor    : int = qgis_pkg_curr_version[3]
            qgis_pkg_curr_version_minor_rev: int = qgis_pkg_curr_version[4]

            # Only for testing purposes
            #qgis_pkg_curr_version_txt      : str = "0.7.3"
            #qgis_pkg_curr_version_major    : int = 0
            #qgis_pkg_curr_version_minor    : int = 7
            #qgis_pkg_curr_version_minor_rev: int = 3

            # Check that the QGIS Package version is >= than the minimum required for this versin of the plugin (see cdb4_constants.py)
            if (qgis_pkg_curr_version_major == c.QGIS_PKG_MIN_VERSION_MAJOR) and \
                (qgis_pkg_curr_version_minor == c.QGIS_PKG_MIN_VERSION_MINOR) and \
                (qgis_pkg_curr_version_minor_rev >= c.QGIS_PKG_MIN_VERSION_MINOR_REV):

                # Show message in Connection Status the Qgis Package is installed (and version)
                dlg.lblMainInst_out.setText(c.success_html.format(text=c.INST_MSG + " (v. " + qgis_pkg_curr_version_txt + ")").format(pkg=cdbLoader.QGIS_PKG_SCHEMA))

                # Deactivate install button
                dlg.btnMainInst.setDisabled(True)
                # Activate-uninstall button
                dlg.btnMainUninst.setDisabled(False)

                # Get users from database.
                usrs: tuple = sql.fetch_list_qgis_pkg_usrgroup_members(cdbLoader)
                wf.fill_users_box(cdbLoader, usrs)

                # Set the current user schema name for the current user (superuser).
                sh_sql.exec_create_qgis_usr_schema_name(cdbLoader)

            else:
                # wrong version of QGIS Package
                dlg.lblMainInst_out.setText(c.warning_html.format(text=c.INST_FAIL_VERSION_MSG))

                # Dectivate the install button
                dlg.btnMainInst.setDisabled(True)
                # Activate the uninstall button
                dlg.btnMainUninst.setDisabled(False)

                error_msg = f"The QGIS Package (v. {qgis_pkg_curr_version_txt}) installed in this database is obsolete. Please upgrade before continuing! Uninstall it and replace it with the newer v. {c.QGIS_PKG_MIN_VERSION_TXT} provided herewith."
                QgsMessageLog.logMessage(error_msg, cdbLoader.PLUGIN_NAME, level=Qgis.Warning)
                QMessageBox.warning(dlg, "Unsupported QGIS Package version", error_msg)
 
        else:
            # QGIS Package is not installed
            dlg.lblMainInst_out.setText(c.crit_warning_html.format(text=c.INST_FAIL_MSG.format(pkg=cdbLoader.QGIS_PKG_SCHEMA)))

            # Activate the install button
            dlg.btnMainInst.setDisabled(False)
            # Deactivate the uninstall button
            dlg.btnMainUninst.setDisabled(True)


    # Admin 'Installation' group box events
    def evt_btnMainInst_clicked(self, cdbLoader: CDBLoader) -> None:
        """Event that is called when the 'Install to database' pushButton (btnMainInst) is pressed.
        """
        inst.installation_query(cdbLoader, c.INST_QUERY.format(pkg=cdbLoader.QGIS_PKG_SCHEMA), "main")


    def evt_btnMainUninst_clicked(self, cdbLoader: CDBLoader) -> None:
        """Event that is called when the 'Uninstall from database' pushButton (btnMainUninst) is pressed.
        """
        inst.uninstallation_query(cdbLoader, c.UNINST_QUERY.format(pkg=cdbLoader.QGIS_PKG_SCHEMA), "main")


    # User 'Installation' group box events
    def evt_cbxUser_changed(self, cdbLoader: CDBLoader) -> None:
        """Event that is called when the 'Selected User' comboBox (cbxUser) current index changes.
        """
        dlg = cdbLoader.admin_dlg

        # Update current users and user_schema variables.
        cdbLoader.USER = dlg.cbxUser.currentText()

        if not cdbLoader.USER:
            return None
        
        sh_sql.exec_create_qgis_usr_schema_name(cdbLoader, usr_name=cdbLoader.USER)
    
        # Enable 'User installation' group box.
        dlg.gbxUserInst.setDisabled(False)
        dlg.btnUsrInst.setText(dlg.btnUsrInst.init_text.format(usr=cdbLoader.USER))
        dlg.btnUsrUninst.setText(dlg.btnUsrUninst.init_text.format(usr=cdbLoader.USER))

        # Check if user package (schema) is installed in database.
        is_usr_pkg_installed: bool = sh_sql.is_usr_schema_installed(cdbLoader)
        if is_usr_pkg_installed:
            dlg.lblUserInst_out.setText(c.success_html.format(text=c.INST_MSG.format(pkg=cdbLoader.USR_SCHEMA)))
            dlg.btnUsrUninst.setDisabled(False)
        else:
            dlg.lblUserInst_out.setText(c.crit_warning_html.format(text=c.INST_FAIL_MSG.format(pkg=cdbLoader.USR_SCHEMA)))
            dlg.btnUsrUninst.setDisabled(True)


    def evt_btnUsrInst_clicked(self, cdbLoader: CDBLoader) -> None:
        """Event that is called when the 'Create schema for user' pushButton (btnUsrInst) is pressed.
        """
        dlg = cdbLoader.admin_dlg

        res = inst.installation_query(cdbLoader, c.INST_QUERY.format(pkg=cdbLoader.USR_SCHEMA), "user")
        if not res: # Query was canceled by user, or error occurred.
            return None

        # Create QgsMessageBar instance.
        dlg.msg_bar = QgsMessageBar()
        # Add the message bar into the input layer and position.
        dlg.vLayoutUsrInst.insertWidget(2, dlg.msg_bar)

        if sh_sql.is_usr_schema_installed(cdbLoader):

            # Replace with Success msg.
            msg = dlg.msg_bar.createMessage(c.INST_SUCC_MSG.format(pkg=cdbLoader.USR_SCHEMA))
            dlg.msg_bar.pushWidget(msg, Qgis.Success, 5)

            # Inform user
            dlg.lblUserInst_out.setText(c.success_html.format(text=c.INST_MSG.format(pkg=cdbLoader.USR_SCHEMA)))
            QgsMessageLog.logMessage(
                    message=c.INST_SUCC_MSG.format(pkg=cdbLoader.USR_SCHEMA),
                    tag=cdbLoader.PLUGIN_NAME,
                    level=Qgis.Success,
                    notifyUser=True)
        else:
            # Replace with Failure msg.
            msg = dlg.msg_bar.createMessage(c.INST_ERROR_MSG.format(pkg=cdbLoader.USR_SCHEMA))
            dlg.msg_bar.pushWidget(msg, Qgis.Critical, 5)

            # Inform user
            dlg.lblUserInst_out.setText(c.crit_warning_html.format(text=c.INST_FAIL_MSG.format(pkg=cdbLoader.USR_SCHEMA)))
            QgsMessageLog.logMessage(
                    message=c.INST_ERROR_MSG.format(pkg=cdbLoader.USR_SCHEMA),
                    tag=cdbLoader.PLUGIN_NAME,
                    level=Qgis.Critical,
                    notifyUser=True)


    def evt_btnUsrUninst_clicked(self, cdbLoader: CDBLoader) -> None:
        """Event that is called when the 'Drop schema for user' pushButton
        (btnUsrUninst) is pressed.
        """
        res = inst.uninstallation_query(cdbLoader, c.UNINST_QUERY.format(pkg=cdbLoader.USR_SCHEMA), "user")
        if not res: # Query was cancelled by user, or error occurred.
            return None


    def evt_btnCloseConn_clicked(self, cdbLoader: CDBLoader) -> None:
        """Event that is called when the 'Close current connection' pushButton
        (btnCloseConn) is pressed.
        """
        wf.tabDbAdmin_reset(cdbLoader)

    #-EVENT FUNCTIONS (end) #####################################################################
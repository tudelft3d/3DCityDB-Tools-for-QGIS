"""This module contains operations that relate to time consuming
processes like installation or mainly refresh views.

The purpose of this module is to hint the user that a heavy process is
running in the background, so that they don't think that the plugin crashed,
or froze.

The plugin runs on single thread, meaning that in such processes the plugin
'freezes' until completion. But without warning or visual cue the user could
think that it broke.

To avoid this module provides two visuals cues.
1. Progress bar.
2. Disabling the entire plugin (gray-out to ignore signals from panic clicking)

This is done by assigning a working thread for the
heavy process. In the main thread the progress bar is assigned to
update following the heavy process taking place in the worker thread.
"""
from __future__ import annotations
from typing import TYPE_CHECKING
if TYPE_CHECKING:       
    from ...gui_admin.admin_dialog import CDB4AdminDialog
    from psycopg2.extensions import connection as pyconn

import os
import time
from qgis.PyQt.QtCore import QObject, QThread, pyqtSignal
from qgis.PyQt.QtWidgets import QMessageBox
from qgis.core import Qgis, QgsMessageLog
import psycopg2, psycopg2.sql as pysql

from ...gui_db_connector.functions import conn_functions as conn_f
from ...shared.functions import sql as sh_sql, general_functions as gen_f
from ..functions.tab_install_functions import initialize_feature_type_registry
from .. import admin_constants as c
from . import tab_install_widget_functions as ti_wf
from . import sql

FILE_LOCATION = gen_f.get_file_relative_path(file=__file__)

#####################################################################################
##### QGIS PACKAGE INSTALL ##########################################################
#####################################################################################

def run_install_qgis_pkg_thread(dlg: CDB4AdminDialog, sql_scripts_path: str, qgis_pkg_schema: str) -> None:
    """Function that installs the plugin package (qgis_pkg) in the database
    by branching a new Worker thread to execute the operation on.

    *   :param path: The relative path to the directory storing the
            SQL installation scripts (e.g. ./cdb_loader/cdb4/ddl_scripts/postgresql)
        :type path: str
    
    *   :param pkg: The package (schema) name that's installed
        :type pkg: str
    """
    if qgis_pkg_schema == dlg.QGIS_PKG_SCHEMA:
        # Add a new progress bar to follow the installation procedure.
        for index in range(dlg.vLayoutTabInstall.count()):
            widget = dlg.vLayoutTabInstall.itemAt(index).widget()
            if not widget:
                continue # Needed to avoid errors with layouts, vertical spacers, etc.
            if widget.objectName() == "gbxMainInst":
                # Add a new progress bar to follow the deletion procedure.
                dlg.create_progress_bar(layout=dlg.vLayoutTabInstall, position=index+1)
                break

    # Create new thread object.
    dlg.thread = QThread()
    # Instantiate worker object for the operation.
    dlg.worker = QgisPackageInstallWorker(dlg=dlg, sql_scripts_path=sql_scripts_path)
    # Move worker object to be executed on the new thread.
    dlg.worker.moveToThread(dlg.thread)

    #-SIGNALS--(start)--################################################################
    # Anti-panic clicking: Disable widgets to avoid queuing signals.
    dlg.thread.started.connect(lambda: dlg.gbxConnection.setDisabled(True))
    dlg.thread.started.connect(lambda: dlg.gbxUserInstCont.setDisabled(True))  

    dlg.thread.started.connect(lambda: dlg.btnCloseConn.setDisabled(True))  

    # Execute worker's 'run' method.
    dlg.thread.started.connect(dlg.worker.install_thread)

    # Capture progress to show in bar.
    dlg.worker.sig_progress.connect(dlg.evt_update_bar)

    # Get rid of worker and thread objects.
    dlg.worker.sig_finished.connect(dlg.thread.quit)
    dlg.worker.sig_finished.connect(dlg.worker.deleteLater)
    dlg.thread.finished.connect(dlg.thread.deleteLater)

    # Re-enable the GUI
    dlg.thread.finished.connect(lambda: dlg.gbxConnection.setDisabled(False))
    dlg.thread.finished.connect(lambda: dlg.gbxUserInstCont.setDisabled(False))  

    dlg.thread.finished.connect(lambda: dlg.btnCloseConn.setDisabled(False)) 

    dlg.thread.finished.connect(dlg.msg_bar.clearWidgets)

    # On installation status
    dlg.worker.sig_success.connect(lambda: evt_qgis_pkg_install_success(dlg, qgis_pkg_schema))
    dlg.worker.sig_fail.connect(lambda: evt_qgis_pkg_install_fail(dlg, qgis_pkg_schema))
    #-SIGNALS--(end)---################################################################

    # Initiate worker thread
    dlg.thread.start()


class QgisPackageInstallWorker(QObject):
    """Class to assign Worker that executes the 'installation scripts'
    to install the QGIS Package (qgis_pkg) into the database.
    """
    # Create custom signals.
    sig_finished = pyqtSignal()
    sig_progress = pyqtSignal(int, str)
    sig_success = pyqtSignal()
    sig_fail = pyqtSignal()

    def __init__(self, dlg: CDB4AdminDialog, sql_scripts_path: str):
        super().__init__()
        self.dlg = dlg
        self.sql_scripts_path: str = sql_scripts_path

    def install_thread(self) -> None:
        """Execution method that installs the qgis_pkg. SQL scripts are run
        directly using the execution method. No psql app needed.
        """
        # Procedure overview:
        # 1) Install the ddl scripts in numbered order (from 010 onwards)
        # 2) Check the Settings (Default Users). If enabled, follow the choices set there
            # - Install the selected default user(s) (qgis_user_ro, qgis_user_rw)
            # - create their user_schemas
        # 3) If required, grant them (default) privileges: ro or rw on all existing cdb_schemas

        dlg = self.dlg

        # Flag to help us break from a failing installation.
        fail_flag: bool = False

        # Get an alphabetical ordered list of the script names. Important: Keep the order with number prefixes.
        install_scripts: list[str] = sorted(os.listdir(path=self.sql_scripts_path))

        # Check that we read some files!
        if not install_scripts:
            fail_flag = True
            self.sig_fail.emit()
            self.sig_finished.emit()
            return None
        else:
            install_scripts_num: int = len(install_scripts)

        # Check the Settings (Default Users)
        def_usr_name_suffixes: list[str] = []
        def_usr_access_suffixes: list[str] = []
        install_users_num: int = 0
        set_privileges_num: int = 0


        if dlg.gbxDefaultUsers.isEnabled():
            if dlg.ckbUserRO.isChecked():
                def_usr_name_suffixes.append('ro')
                install_users_num += 1
                if dlg.ckbUserROAccess.isChecked():
                    def_usr_access_suffixes.append('ro')
                    set_privileges_num += 1
            if dlg.ckbUserRW.isChecked():
                def_usr_name_suffixes.append('rw')
                install_users_num += 1
                if dlg.ckbUserRWAccess.isChecked():
                    def_usr_access_suffixes.append('rw')
                    set_privileges_num += 1

        # Set progress bar goal
        steps_tot = install_scripts_num + install_users_num + set_privileges_num
        dlg.bar.setMaximum(steps_tot)

        curr_step: int = 0

        try:
            # Open new temp session, reserved for installation.
            temp_conn = conn_f.open_db_connection(db_connection=dlg.DB, app_name=" ".join([dlg.DLG_NAME_LABEL, "(QGIS Package Installation)"]))
            with temp_conn:

                # Start measuring time
                time_start = time.time()

                # 1) Install the DDL scripts
                for script in install_scripts:

                    # Update progress bar
                    msg = f"Installing: '{script}'"
                    curr_step += 1
                    self.sig_progress.emit(curr_step, msg)

                    try:
                        with temp_conn.cursor() as cur:
                            with open(os.path.join(self.sql_scripts_path, script), "r") as sql_script:
                                cur.execute(sql_script.read())
                        temp_conn.commit() # Actually no need of it, automatically committed in the with

                    except (Exception, psycopg2.Error) as error:
                        temp_conn.rollback()
                        fail_flag = True
                        gen_f.critical_log(
                            func=self.install_thread,
                            location=FILE_LOCATION,
                            header="Installing QGIS Package ddl scripts",
                            error=error)
                        self.sig_fail.emit()
                        break # Exit from the loop

                # 2) Install the DEFAULT users and create their usr_schemas
                if install_users_num == 0:
                    pass
                else:
                    for suf in def_usr_name_suffixes:
                        # Prepare the name of the user
                        usr_name = "_".join(["qgis_user", suf])

                        query = pysql.SQL("""
                            SELECT {_qgis_pkg_schema}.create_default_qgis_pkg_user({_priv_type});
                        """).format(
                            _qgis_pkg_schema = pysql.Identifier(dlg.QGIS_PKG_SCHEMA),
                            _priv_type = pysql.Literal(suf)
                        )                    

                        query2 = pysql.SQL("""
                            SELECT {_qgis_pkg_schema}.create_qgis_usr_schema({_usr_name});
                        """).format(
                            _qgis_pkg_schema = pysql.Identifier(dlg.QGIS_PKG_SCHEMA),
                            _usr_name = pysql.Literal(usr_name)
                        ) 

                        # Update progress bar
                        msg = f"Creating user: '{usr_name}'"
                        curr_step += 1
                        self.sig_progress.emit(curr_step, msg)

                        try:
                            with temp_conn.cursor() as cur:
                                cur.execute(query)
                                cur.execute(query2)
                            temp_conn.commit()

                        except (Exception, psycopg2.Error) as error:
                            temp_conn.rollback()
                            fail_flag = True
                            gen_f.critical_log(
                                func=self.install_thread,
                                location=FILE_LOCATION,
                                header=f"Creating QGIS Package default user '{usr_name}'",
                                error=error)
                            self.sig_fail.emit()
                            break # Exit from the loop

                # 3) If required, grant them (default) privileges: ro or rw on all existing cdb_schemas
                if set_privileges_num == 0:
                    pass
                else:
                    for suf in def_usr_access_suffixes:
                        # Prepare the nale of the user
                        usr_name = "_".join(["qgis_user", suf])

                        query = pysql.SQL("""
                            SELECT {_qgis_pkg_schema}.grant_qgis_usr_privileges(usr_name := {_usr_name}, priv_type := {_priv_type}, cdb_schema := NULL);
                        """).format(
                            _qgis_pkg_schema = pysql.Identifier(self.dlg.QGIS_PKG_SCHEMA),
                            _usr_name = pysql.Literal(usr_name),
                            _priv_type = pysql.Literal(suf)
                        )                    

                        # Update progress bar with current step and script.
                        msg = f"Setting privileges for user: '{usr_name}'"
                        curr_step += 1
                        self.sig_progress.emit(curr_step, msg)

                        try:
                            with temp_conn.cursor() as cur:
                                cur.execute(query)
                            temp_conn.commit()

                        except (Exception, psycopg2.Error) as error:
                            temp_conn.rollback()
                            fail_flag = True
                            gen_f.critical_log(
                                func=self.install_thread,
                                location=FILE_LOCATION,
                                header=f"Granting {suf} privileges to user {usr_name}",
                                error=error)
                            self.sig_fail.emit()
                            break # Exit from the loop

                # Measure elapsed time
                print(f"Installation of the QGIS Package completed in {round((time.time() - time_start), 4)} seconds")


        except (Exception, psycopg2.Error) as error:
            temp_conn.rollback()
            fail_flag = True
            gen_f.critical_log(
                func=self.install_thread,
                location=FILE_LOCATION,
                header="Establishing temporary connection",
                error=error)
            self.sig_fail.emit()

        # No FAIL = SUCCESS
        if not fail_flag:
            self.sig_success.emit()

        self.sig_finished.emit()
        # Close connection
        temp_conn.close()
        return None

#--EVENTS  (start)  ##############################################################

def evt_qgis_pkg_install_success(dlg: CDB4AdminDialog, pkg: str) -> None:
    """Event that is called when the thread executing the installation finishes successfully.

    Shows success message at dlg.msg_bar: QgsMessageBar
    Shows success message in Connection Status groupbox
    Shows success message in QgsMessageLog
    """
    if sh_sql.is_qgis_pkg_installed(dlg=dlg):
        # Replace with Success msg.
        msg = dlg.msg_bar.createMessage(c.INST_SUCC_MSG.format(pkg=pkg))
        dlg.msg_bar.pushWidget(msg, Qgis.MessageLevel.Success, 5)

        # Show database name
        dlg.lblConnToDb_out.setText(c.success_html.format(text=dlg.DB.database_name))

        # Get the version of the newly installed QGIS Package
        # Named tuple: full_version, major_version, minor_version, minor_revision, code_name, release_date
        qgis_pkg_curr_version = sh_sql.get_qgis_pkg_version(dlg=dlg)
        # print("Installed QGIS Package version: ", qgis_pkg_curr_version)

        qgis_pkg_curr_version_txt      : str = qgis_pkg_curr_version.version         # e.g. 0.9.1
        #qgis_pkg_curr_version_major    : int = qgis_pkg_curr_version.major_version   # e.g. 0
        #qgis_pkg_curr_version_minor    : int = qgis_pkg_curr_version.minor_version   # e.g. 9
        #qgis_pkg_curr_version_minor_rev: int = qgis_pkg_curr_version.minor_revision  # e.g. 1

        # Update the label regarding the QGIS Package Installation
        dlg.lblMainInst_out.setText(c.success_html.format(text=c.INST_SUCC_MSG + " (v. " + qgis_pkg_curr_version_txt + ")").format(pkg=dlg.QGIS_PKG_SCHEMA))

        # Inform user
        QgsMessageLog.logMessage(message=c.INST_SUCC_MSG.format(pkg=pkg), tag=dlg.PLUGIN_NAME, level=Qgis.MessageLevel.Success, notifyUser=True)

        # Finish (re)setting up the GUI
        ti_wf.setup_post_qgis_pkg_installation(dlg)

    else:
        evt_qgis_pkg_install_fail(dlg=dlg, pkg=pkg)


def evt_qgis_pkg_install_fail(dlg: CDB4AdminDialog, pkg: str) -> None:
    """Event that is called when the thread executing the installation
    emits a fail signal meaning that something went wrong with installation.

    It prompt the user to clear the installation before trying again.
    .. Not sure if this is necessary as in every installation the package
    .. is dropped to replace it with a new one.

    Shows fail message at dlg.msg_bar: QgsMessageBar
    Shows fail message in Connection Status groupbox
    Shows fail message in QgsMessageLog
    """
    # Replace with Failure msg.
    msg = dlg.msg_bar.createMessage(c.INST_FAIL_MSG.format(pkg=pkg))
    dlg.msg_bar.pushWidget(msg, Qgis.MessageLevel.Critical, 5)

    # Inform user
    dlg.lblMainInst_out.setText(c.failure_html.format(text=c.INST_FAIL_MSG.format(pkg=pkg)))
    QgsMessageLog.logMessage(message=c.INST_FAIL_MSG.format(pkg=pkg), tag=dlg.PLUGIN_NAME, level=Qgis.MessageLevel.Critical, notifyUser=True)

    # Drop corrupted installation.
    sql.drop_db_schema(dlg=dlg, schema=dlg.QGIS_PKG_SCHEMA, close_connection=False)

    # Fisish (re)setting up the GUI
    ti_wf.setup_post_qgis_pkg_uninstallation(dlg=dlg)

#--EVENTS  (end) ################################################################

#####################################################################################
##### QGIS PACKAGE UNINSTALL ########################################################
#####################################################################################

def run_uninstall_qgis_pkg_thread(dlg: CDB4AdminDialog) -> None:
    """Function that uninstalls the qgis_pkg schema from the database
    by branching a new Worker thread to execute the operation on.
    """
    # Add a new progress bar to follow the installation procedure.
    for index in range(dlg.vLayoutTabInstall.count()):
        widget = dlg.vLayoutTabInstall.itemAt(index).widget()
        if not widget:
            continue # Needed to avoid errors with layouts, vertical spacers, etc.
        if widget.objectName() == "gbxMainInst":
            # Add a new progress bar to follow the deletion procedure.
            dlg.create_progress_bar(layout=dlg.vLayoutTabInstall, position=index+1)
            break

    # Create new thread object.
    dlg.thread = QThread()
    # Instantiate worker object for the operation.
    dlg.worker = QgisPackageUninstallWorker(dlg=dlg)
    # Move worker object to the be executed on the new thread.
    dlg.worker.moveToThread(dlg.thread)

    #-SIGNALS--(start)--################################################################
    # Anti-panic clicking: Disable widgets to avoid queuing signals.
    dlg.thread.started.connect(lambda: dlg.gbxConnection.setDisabled(True))
    dlg.thread.started.connect(lambda: dlg.gbxUserInstCont.setDisabled(True))  

    dlg.thread.started.connect(lambda: dlg.btnCloseConn.setDisabled(True))  

    # Execute worker's 'run' method.
    dlg.thread.started.connect(dlg.worker.uninstall_thread)

    # Capture progress to show in bar.
    dlg.worker.sig_progress.connect(dlg.evt_update_bar)

    # Get rid of worker and thread objects.
    dlg.worker.sig_finished.connect(dlg.thread.quit)
    dlg.worker.sig_finished.connect(dlg.worker.deleteLater)
    dlg.thread.finished.connect(dlg.thread.deleteLater)

    # Re-enable the GUI
    dlg.thread.finished.connect(lambda: dlg.gbxConnection.setDisabled(False))
    dlg.thread.finished.connect(lambda: dlg.gbxUserInstCont.setDisabled(False))  

    dlg.thread.finished.connect(lambda: dlg.btnCloseConn.setDisabled(False)) 

    dlg.thread.finished.connect(dlg.msg_bar.clearWidgets)

    # On installation status
    dlg.worker.sig_success.connect(lambda: evt_qgis_pkg_uninstall_success(dlg))
    dlg.worker.sig_fail.connect(lambda: evt_qgis_pkg_uninstall_fail(dlg))
    #-SIGNALS--(end)---################################################################

    # Initiate worker thread
    dlg.thread.start()


class QgisPackageUninstallWorker(QObject):
    """Class to assign Worker that executes the 'uninstallation scripts'
    to uninstall the plugin package (qgis_pkg) from the database.
    """
    # Create custom signals.
    sig_finished = pyqtSignal()
    sig_progress = pyqtSignal(int, str)
    sig_success = pyqtSignal()
    sig_fail = pyqtSignal()

    def __init__(self, dlg: CDB4AdminDialog):
        super().__init__()
        self.dlg = dlg

    def uninstall_thread(self):

        # Named tuple: version, full_version, major_version, minor_version, minor_revision, code_name, release_date
        qgis_pkg_curr_version = sh_sql.get_qgis_pkg_version(dlg=self.dlg)
        # print(f"Uninstalling QGIS Package version: {qgis_pkg_curr_version}")

        # print(qgis_pkg_curr_version)
        qgis_pkg_curr_version_major    : int = qgis_pkg_curr_version.major_version   # e.g. 0
        qgis_pkg_curr_version_minor    : int = qgis_pkg_curr_version.minor_version   # e.g. 8
        qgis_pkg_curr_version_revision : int = qgis_pkg_curr_version.minor_revision   # e.g. 1

        if all((qgis_pkg_curr_version_major <= 0,
                qgis_pkg_curr_version_minor <= 8)):
            
            print("Uninstalling QGIS Package up to v. 0.8.x")
            self.uninstall_thread_qgis_pkg_till_08()

        elif all((qgis_pkg_curr_version_major == 0,
                qgis_pkg_curr_version_minor == 9)):
            
            print("Uninstalling QGIS Package v. 0.9.x")
            self.uninstall_thread_qgis_pkg_09()

        elif all((qgis_pkg_curr_version_major == 0,
                qgis_pkg_curr_version_minor == 10,
                qgis_pkg_curr_version_revision <= c.QGIS_PKG_MIN_VERSION_MINOR_REV)):
            
            print("Uninstalling QGIS Package v. [0.10.x]")
            # Initialize the FeatureTypeRegistry
            initialize_feature_type_registry(dlg=self.dlg)
            # print("FeatureTypesRegistry initialized")
            # print(self.dlg.FeatureTypesRegistry)

            self.uninstall_thread_qgis_pkg_current()
        else:
            # Inform the user that the detected versio cannot be uninstalled
            msg: str = "The currently installed version of the QGIS Package cannot be uninstalled using this version of the QGIS Package Administrator."
            QMessageBox.warning(self, "Connection error", msg)
            QgsMessageLog.logMessage(message=msg, tag=self.dlg.PLUGIN_NAME, level=Qgis.MessageLevel.Warning, notifyUser=True)

        return None


    def uninstall_thread_qgis_pkg_till_08(self):
        """Execution method that uninstalls the QGIS Package (older version, till 0.8.x).
        """
        dlg = self.dlg
        # Flag to help us break from a failing installation.
        fail_flag: bool = False
        qgis_pkg_schema: str = self.dlg.QGIS_PKG_SCHEMA

        # Get users
        usr_names_all = sql.list_qgis_pkg_usrgroup_members(dlg=dlg)
        usr_names: list[str] = []
        if usr_names_all:
            usr_names = [elem for elem in usr_names_all if elem != 'postgres']
        else:
            usr_names = [elem for elem in usr_names_all]

        # Get usr_schemas
        usr_schemas = sql.list_usr_schemas(dlg=dlg)

        # Get cdb_schemas
        cdb_schemas = sql.list_all_cdb_schemas(dlg=dlg)

        drop_layers_funcs: list[str] = [
            "drop_layers_bridge",
            "drop_layers_building",
            "drop_layers_cityfurniture",
            "drop_layers_generics",
            "drop_layers_landuse",
            "drop_layers_relief",
            "drop_layers_transportation",
            "drop_layers_tunnel",
            "drop_layers_vegetation",
            "drop_layers_waterbody",
            ]

        if not usr_names:
            usr_names_num = 0
        else:
            usr_names_num = len(usr_names)

        if not usr_schemas:
            usr_schemas_num = 0
        else:
            usr_schemas_num = len(usr_schemas)

        if not cdb_schemas:
            cdb_schemas_num = 0
        else:
            cdb_schemas_num = len(cdb_schemas)

        # Set progress bar goal (number of actions):
        # 1) revoke privileges: usr_names_num (all but postgres)
        # 2) drop layers: usr_names_num x cdb_schemas_num x drop_functions_num #IDEALLY: usr_schemas_num x cdb_schemas_num x drop_functions_num
        # 3) drop usr schemas: usr_schemas_num 
        # 4) drop 'qgis_pkg': 1
        # TOTAL = usr_names_num + usr_schemas_num x (cdb_schemas_num x drop_functions_num + 1) + 1

        steps_tot = usr_names_num + usr_names_num * cdb_schemas_num * len(drop_layers_funcs) + usr_schemas_num + 1
        dlg.bar.setMaximum(steps_tot)

        curr_step: int = 0

        try:
            temp_conn = conn_f.open_db_connection(db_connection=dlg.DB, app_name=" ".join([dlg.DLG_NAME_LABEL, "(QGIS Package Uninstallation)"]))
            with temp_conn:

                # 1) revoke privileges: for all users
                if usr_names_num == 0:
                    pass # nothing to do 
                else:
                    for usr_name in usr_names:

                        query = pysql.SQL("""
                            SELECT {_qgis_pkg_schema}.revoke_qgis_usr_privileges(usr_name := {_usr_name}, cdb_schema := NULL);
                            """).format(
                            _qgis_pkg_schema = pysql.Identifier(dlg.QGIS_PKG_SCHEMA),
                            _usr_name = pysql.Literal(usr_name)
                            )

                        # Update progress bar
                        msg = f"Revoking privileges from user: {usr_name}"
                        curr_step += 1
                        self.sig_progress.emit(curr_step, msg)

                        try:
                            with temp_conn.cursor() as cur:
                                cur.execute(query)
                            temp_conn.commit()

                        except (Exception, psycopg2.Error) as error:
                            temp_conn.rollback()
                            fail_flag = True
                            gen_f.critical_log(
                                func=self.uninstall_thread,
                                location=FILE_LOCATION,
                                header="Revoking privileges from users",
                                error=error)
                            self.sig_fail.emit()

                # 2) drop layers:  usr_names_num x cdb_schemas_num x drop_functions_num
                if usr_names_num == 0 or cdb_schemas_num == 0:
                    pass # nothing to do 
                else:
                    for usr_name in usr_names:
                        # Get current user's schema
                        usr_schema = sh_sql.create_qgis_usr_schema_name(dlg, usr_name)
                        for cdb_schema in cdb_schemas:
                            for drop_layers_func in drop_layers_funcs:

                                query = pysql.SQL("""
                                    SELECT {_qgis_pkg_schema}.{_drop_layers_func}({_usr_name},{_cdb_schema});
                                    """).format(
                                    _qgis_pkg_schema = pysql.Identifier(qgis_pkg_schema),
                                    _drop_layers_func = pysql.Identifier(drop_layers_func),
                                    _usr_name = pysql.Literal(usr_name),
                                    _cdb_schema = pysql.Literal(cdb_schema)
                                    )

                                # Update progress bar
                                msg = f"In {usr_schema}: dropping layers for {cdb_schema}"
                                curr_step += 1
                                self.sig_progress.emit(curr_step, msg)

                                try:
                                    with temp_conn.cursor() as cur:
                                        cur.execute(query)
                                    temp_conn.commit()

                                except (Exception, psycopg2.Error) as error:
                                    fail_flag = True
                                    gen_f.critical_log(
                                        func=self.uninstall_thread,
                                        location=FILE_LOCATION,
                                        header="Dropping layers",
                                        error=error)
                                    temp_conn.rollback()
                                    self.sig_fail.emit()

                # 3) drop usr_schemas
                if usr_schemas_num == 0:
                    pass # nothing to do 
                else:
                    for usr_schema in usr_schemas:
                        query = pysql.SQL("""
                        DROP SCHEMA IF EXISTS {_usr_schema} CASCADE;
                        """).format(
                        _usr_schema = pysql.Identifier(usr_schema)
                        )

                        # Update progress bar
                        msg = " ".join(["Dropping user schema:", usr_schema])
                        curr_step += 1
                        self.sig_progress.emit(curr_step, msg)

                        try:
                            with temp_conn.cursor() as cur:
                                cur.execute(query)
                            temp_conn.commit()

                        except (Exception, psycopg2.Error) as error:
                            fail_flag = True
                            gen_f.critical_log(
                                func=self.uninstall_thread,
                                location=FILE_LOCATION,
                                header=f"Dropping user schema {usr_schema}",
                                error=error)
                            temp_conn.rollback()
                            self.sig_fail.emit()

                # 4) Drop "qgis_pkg" schema
                query = pysql.SQL("""
                    DROP SCHEMA IF EXISTS {_qgis_pkg_schema} CASCADE;
                    """).format(
                    _qgis_pkg_schema = pysql.Identifier(qgis_pkg_schema)
                    )

                # Update progress bar
                msg = " ".join(["Dropping schema:", qgis_pkg_schema])
                curr_step += 1
                self.sig_progress.emit(curr_step, msg)

                try:
                    with temp_conn.cursor() as cur:
                        cur.execute(query)
                    temp_conn.commit()

                except (Exception, psycopg2.Error) as error:
                    temp_conn.rollback()
                    fail_flag = True
                    gen_f.critical_log(
                        func=self.uninstall_thread,
                        location=FILE_LOCATION,
                        header=f"Dropping QGIS Package schema '{qgis_pkg_schema}'",
                        error=error)
                    self.sig_fail.emit()

        except (Exception, psycopg2.Error) as error:
            temp_conn.rollback()
            fail_flag = True
            gen_f.critical_log(
                func=self.uninstall_thread_qgis_pkg_till_08,
                location=FILE_LOCATION,
                header="Establishing temporary connection",
                error=error)
            self.sig_fail.emit()

        # No FAIL = SUCCESS
        if not fail_flag:
            self.sig_success.emit()

        self.sig_finished.emit()
        # Close temp connection
        temp_conn.close()
        return None


    def uninstall_thread_qgis_pkg_09(self):
        """Execution method that uninstalls the QGIS Package (current version).
        """
        dlg = self.dlg
        # Flag to help us break from a failing installation.
        fail_flag: bool = False
        qgis_pkg_schema: str = dlg.QGIS_PKG_SCHEMA

        # Overview of the procedure:
        # 1) revoke privileges: for all users (except postgres or superusers)
        # 2) drop feature types (layers)
        # 3) drop usr_schemas
        # 4) drop qgis_pkg schema

        # Get required information
        
        curr_usr = dlg.DB.username # this is a superuser, as he has succesfully logged in and is using the GUI.

        # Get users that are members of the group
        usr_names_all = sql.list_qgis_pkg_usrgroup_members(dlg=dlg)
        # print("usr_names_all:", usr_names_all)
        
        usr_names: list[str] = []
        usr_names_su: list[str] = ["postgres"]

        if usr_names_all:
            usr_names = [elem for elem in usr_names_all if elem != 'postgres']
            if curr_usr != "postgres":
                usr_names = [elem for elem in usr_names_all if elem != curr_usr]
                usr_names_su.append(curr_usr)

        # print("usr_names:", usr_names)
        # print("usr_names_su:", usr_names_su)

        drop_tuples = sql.list_feature_types(dlg=dlg, usr_schema=None) # get 'em all!!
        # print("uninstall drop_tuples:", drop_tuples)

        # Get usr_schemas
        usr_schemas = sql.list_usr_schemas(dlg=dlg)
        # print("uninstall usr_schemas:", usr_schemas)

        # Set progress bar goal:
        # revoke privileges: 1 x len(usr_names) actions
        # reset privileges for superusers: 1 * len(usr_names_su) actions
        # drop feature types (layers): len(drop_tuples)
        # drop usr_schemas: 1 x len(usr_schemas)
        # drop the qgis_pkg_usrgroup_*: +1
        # drop 'qgis_pkg': +1

        if not usr_names:
            usr_names_num: int = 0
        else:
            usr_names_num: int = len(usr_names)

        usr_names_su_num: int = len(usr_names) # Will always be at least 1 because of "postgres" user.

        if not drop_tuples:
            drop_tuples_num: int = 0
        else:
            drop_tuples_num: int = len(drop_tuples)

        if not usr_schemas:
            usr_schemas_num: int = 0
        else:
            usr_schemas_num: int = len(usr_schemas)

        steps_tot = usr_names_num + usr_names_su_num + drop_tuples_num + usr_schemas_num + 2
        dlg.bar.setMaximum(steps_tot)

        curr_step: int = 0

        try:
            # Open new temp session, reserved for installation.
            temp_conn = conn_f.open_db_connection(db_connection=dlg.DB, app_name=" ".join([dlg.DLG_NAME_LABEL, "(QGIS Package Uninstallation)"]))
            with temp_conn:

                # 1) revoke privileges: for all normal users
                if usr_names_num == 0:
                    pass # nothing to do 
                else:
                    for usr_name in usr_names:

                        query = pysql.SQL("""
                            SELECT {_qgis_pkg_schema}.revoke_qgis_usr_privileges(usr_name := {_usr_name}, cdb_schemas := NULL);
                            """).format(
                            _qgis_pkg_schema = pysql.Identifier(dlg.QGIS_PKG_SCHEMA),
                            _usr_name = pysql.Literal(usr_name)
                            )

                        # Update progress bar
                        msg: str = f"Revoking privileges from user: {usr_name}"
                        curr_step += 1
                        self.sig_progress.emit(curr_step, msg)

                        try:
                            with temp_conn.cursor() as cur:
                                cur.execute(query)
                            temp_conn.commit()               

                        except (Exception, psycopg2.Error) as error:
                            temp_conn.rollback()
                            fail_flag = True
                            gen_f.critical_log(
                                func=self.uninstall_thread,
                                location=FILE_LOCATION,
                                header="Revoking privileges from users",
                                error=error)
                            self.sig_fail.emit()

                # 2) reset privileges for superusers ("postgres" and, in case, the current user)
                if usr_names_su_num == 0:
                    pass # nothing to do 
                else:
                    for usr_name in usr_names_su:

                        query = pysql.SQL("""
                            SELECT {_qgis_pkg_schema}.grant_qgis_usr_privileges(usr_name := {_usr_name}, priv_type := 'rw', cdb_schemas := NULL);
                            """).format(
                            _qgis_pkg_schema = pysql.Identifier(dlg.QGIS_PKG_SCHEMA),
                            _usr_name = pysql.Literal(usr_name)
                            )

                        # Update progress bar
                        msg = f"Resetting privileges for user: {usr_name}"
                        curr_step += 1
                        self.sig_progress.emit(curr_step, msg)

                        try:
                            with temp_conn.cursor() as cur:
                                cur.execute(query)
                            temp_conn.commit()               

                        except (Exception, psycopg2.Error) as error:
                            temp_conn.rollback()
                            fail_flag = True
                            gen_f.critical_log(
                                func=self.uninstall_thread,
                                location=FILE_LOCATION,
                                header=f"Resetting privileges from superusers",
                                error=error)
                            self.sig_fail.emit()

                # 3) drop feature types (layers)
                if drop_tuples_num == 0:
                    pass # nothing to do 
                else:
                    #ft: FeatureType
                    for usr_schema, cdb_schema, feat_type in drop_tuples:
                        ft = dlg.FeatureTypesRegistry[feat_type]
                        module_drop_func = ft.layers_drop_function

                        # Prepare the query for the drop_layer_{*} function
                        # E.g. qgis_pkg.drop_layers_building(usr_schema, cdb_schema)
                        query = pysql.SQL("""
                            SELECT {_qgis_pkg_schema}.{_module_drop_func}({_usr_schema},{_cdb_schema});
                            """).format(
                            _qgis_pkg_schema = pysql.Identifier(qgis_pkg_schema),
                            _module_drop_func = pysql.Identifier(module_drop_func),
                            _usr_schema = pysql.Literal(usr_schema),
                            _cdb_schema = pysql.Literal(cdb_schema)
                            )

                        # Update progress bar
                        msg = f"In {usr_schema}: dropping {feat_type} layers for {cdb_schema}"
                        curr_step += 1
                        self.sig_progress.emit(curr_step, msg)

                        try:
                            with temp_conn.cursor() as cur:
                                cur.execute(query)
                            temp_conn.commit()

                        except (Exception, psycopg2.Error) as error:
                            fail_flag = True
                            gen_f.critical_log(
                                func=self.uninstall_thread,
                                location=FILE_LOCATION,
                                header="Dropping layers",
                                error=error)
                            temp_conn.rollback()
                            self.sig_fail.emit()

                # 4) drop usr_schemas
                if usr_schemas_num == 0:
                    pass # nothing to do 
                else:
                    for usr_schema in usr_schemas:

                        query = pysql.SQL("""
                            DROP SCHEMA IF EXISTS {_usr_schema} CASCADE;
                            """).format(
                            _usr_schema = pysql.Identifier(usr_schema)
                            )

                        # Update progress bar
                        msg = f"Dropped user schema: {usr_schema}"
                        curr_step += 1
                        self.sig_progress.emit(curr_step, msg)

                        try:
                            with temp_conn.cursor() as cur:
                                cur.execute(query)
                            temp_conn.commit()

                        except (Exception, psycopg2.Error) as error:
                            temp_conn.rollback()
                            fail_flag = True
                            gen_f.critical_log(
                                func=self.uninstall_thread,
                                location=FILE_LOCATION,
                                header="Dropping user schemas",
                                error=error)
                            self.sig_fail.emit()

                # 5) Drop database group
                if not self.dlg.GROUP_NAME:
                    self.dlg.GROUP_NAME = sql.create_qgis_pkg_usrgroup_name(dlg=dlg)

                query = pysql.SQL("""
                    DROP ROLE IF EXISTS {_qgis_pkg_usrgroup};
                    """).format(
                    _qgis_pkg_usrgroup = pysql.Identifier(dlg.GROUP_NAME)
                    )

                # Update progress bar
                msg = f"Dropping group {dlg.GROUP_NAME}"
                curr_step += 1
                self.sig_progress.emit(curr_step, msg)

                try:
                    with temp_conn.cursor() as cur:
                        cur.execute(query)
                    temp_conn.commit()

                except (Exception, psycopg2.Error) as error:
                    temp_conn.rollback()
                    fail_flag = True
                    gen_f.critical_log(
                        func=self.uninstall_thread,
                        location=FILE_LOCATION,
                        header=f"Dropping group '{dlg.GROUP_NAME}'",
                        error=error)
                    self.sig_fail.emit()

                # 6) drop qgis_pkg schema
                query = pysql.SQL("""
                    DROP SCHEMA IF EXISTS {_qgis_pkg_schema} CASCADE;
                    """).format(
                    _qgis_pkg_schema = pysql.Identifier(qgis_pkg_schema)
                    )

                # Update progress bar with current step and script.
                msg = "Dropping QGIS Package schema"
                curr_step += 1            
                self.sig_progress.emit(curr_step, msg)

                try:
                    with temp_conn.cursor() as cur:
                        cur.execute(query)
                    temp_conn.commit()

                except (Exception, psycopg2.Error) as error:
                    temp_conn.rollback()
                    fail_flag = True
                    gen_f.critical_log(
                        func=self.uninstall_thread,
                        location=FILE_LOCATION,
                        header=f"Dropping QGIS Package schema '{qgis_pkg_schema}'",
                        error=error)
                    self.sig_fail.emit()

        except (Exception, psycopg2.Error) as error:
            temp_conn.rollback()
            fail_flag = True
            gen_f.critical_log(
                func=self.uninstall_thread_qgis_pkg_09,
                location=FILE_LOCATION,
                header="Establishing temporary connection",
                error=error)

        # No FAIL = SUCCESS
        if not fail_flag:
            self.sig_success.emit()

        self.sig_finished.emit()
        # Close temp connection
        temp_conn.close()
        return None


    def uninstall_thread_qgis_pkg_current(self):
        """Execution method that uninstalls the QGIS Package (current version).
        """
        dlg = self.dlg
        # Flag to help us break from a failing installation.
        fail_flag: bool = False
        qgis_pkg_schema: str = dlg.QGIS_PKG_SCHEMA

        # Overview of the procedure:
        # 1) revoke privileges: for all users (except postgres or superusers)
        # 2) revoke privileges for postgres or superusers
        # 3) drop feature types (layers)
        # 4) drop the detail views (dv_ views)
        # 5) drop usr_schemas
        # 6) drop ga_indices
        # 7) drop qgis_usr_group_* group 
        # 8) drop qgis_pkg schema

        # Get required information
       
        curr_usr = dlg.DB.username # this is a superuser, as he has succesfully logged in and is using the GUI.

        # Get users that are members of the group
        usr_names_all = sql.list_qgis_pkg_usrgroup_members(dlg=dlg)
        # print("usr_names_all:", usr_names_all)
        
        usr_names: list[str] = []
        usr_names_su: list[str] = ["postgres"]

        if usr_names_all:
            usr_names = [elem for elem in usr_names_all if elem != "postgres"]
            if curr_usr != "postgres":
                usr_names = [elem for elem in usr_names_all if elem != curr_usr]
                usr_names_su.append(curr_usr)

        # print("usr_names:", usr_names)
        # print("usr_names_su:", usr_names_su)

        #drop_tuples: list[tuple[str, str, str]] = []
        drop_tuples = sql.list_feature_types(dlg=dlg, usr_schema=None) # get 'em all!!
        # print("uninstall drop_tuples:", drop_tuples)

        drop_detail_views: list[tuple[str, str]] = [] 
        if drop_tuples:
            # Extract only usr_schema and citydb_schema, without repetitions. It will look like:
            # [('qgis_giorgio', 'alderaan'), ('qgis_giorgio', 'citydb'), ('qgis_user_rw', 'alderaan'), ('qgis_user_rw', 'rh')]
            drop_detail_views = [*set([item[0:2] for item in drop_tuples])]
            # print("drop_detail_views", drop_detail_views)

        # Get usr_schemas
        # usr_schemas: tuple[str, ...] = ()
        usr_schemas = sql.list_usr_schemas(dlg=dlg)
        # print("uninstall usr_schemas:", usr_schemas)

        # Get all cdb_schemas
        # cdb_schemas: tuple[str]
        cdb_schemas = sql.list_all_cdb_schemas(dlg=dlg)
        # print("Existing cdb_schemas:", cdb_schemas)

        # Set progress bar goal:
        # 1) revoke privileges: 1 x len(usr_names) actions
        # 2) reset privileges for superusers: 1 * len(usr_names_su) actions
        # 3) drop feature types (layers): len(drop_tuples)
        # 4) drop detail views : 1 x len(cdb_schemas)
        # 5) drop usr_schemas: 1 x len(usr_schemas)
        # 6) drop ga_indices: 1 x len(cdb_schemas)
        # 7) drop the qgis_pkg_usrgroup_*: + 1
        # 8) drop 'qgis_pkg': +1

        if not usr_names:
            usr_names_num: int = 0
        else:
            usr_names_num: int = len(usr_names)

        usr_names_su_num: int = len(usr_names) # Will always be at least 1 because of "postgres" user.

        if not drop_tuples:
            drop_tuples_num: int = 0
        else:
            drop_tuples_num: int = len(drop_tuples)

        if not drop_detail_views:
            drop_detail_views_num: int = 0
        else:
            drop_detail_views_num: int = len(drop_detail_views)

        if not usr_schemas:
            usr_schemas_num: int = 0
        else:
            usr_schemas_num: int = len(usr_schemas)

        if not cdb_schemas:
            cdb_schemas_num: int = 0
        else:
            cdb_schemas_num: int = len(cdb_schemas)


        steps_tot: int = usr_names_num + usr_names_su_num + drop_tuples_num + drop_detail_views_num + usr_schemas_num + cdb_schemas_num + 2
        dlg.bar.setMaximum(steps_tot)

        curr_step: int = 0

        temp_conn: pyconn
        try:
            # Open new temp session, reserved for installation.
            temp_conn = conn_f.open_db_connection(db_connection=dlg.DB, app_name=" ".join([dlg.DLG_NAME_LABEL, "(QGIS Package Uninstallation)"]))
            with temp_conn:
                # Start measuring time
                time_start = time.time()

                # 1) revoke privileges: for all normal users
                if usr_names_num > 0:
                    for usr_name in usr_names:

                        query = pysql.SQL("""
                            SELECT {_qgis_pkg_schema}.revoke_qgis_usr_privileges(usr_name := {_usr_name}, cdb_schemas := NULL);
                            """).format(
                            _qgis_pkg_schema = pysql.Identifier(dlg.QGIS_PKG_SCHEMA),
                            _usr_name = pysql.Literal(usr_name)
                            )

                        # Update progress bar
                        msg = f"Revoking privileges from user: {usr_name}"
                        curr_step += 1
                        self.sig_progress.emit(curr_step, msg)

                        try:
                            with temp_conn.cursor() as cur:
                                cur.execute(query)
                            temp_conn.commit()               

                        except (Exception, psycopg2.Error) as error:
                            temp_conn.rollback()
                            fail_flag = True
                            gen_f.critical_log(
                                func=self.uninstall_thread_qgis_pkg_current,
                                location=FILE_LOCATION,
                                header="Revoking privileges from users",
                                error=error)
                            self.sig_fail.emit()

                print("Revoking privileges for users: done")

                # 2) reset privileges for superusers ("postgres" and, in case, the current user)
                if usr_names_su_num > 0:
                    for usr_name in usr_names_su:

                        query = pysql.SQL("""
                            SELECT {_qgis_pkg_schema}.grant_qgis_usr_privileges(usr_name := {_usr_name}, priv_type := 'rw', cdb_schemas := NULL);
                            """).format(
                            _qgis_pkg_schema = pysql.Identifier(dlg.QGIS_PKG_SCHEMA),
                            _usr_name = pysql.Literal(usr_name)
                            )

                        # Update progress bar
                        msg = f"Resetting privileges for user: {usr_name}"
                        curr_step += 1
                        self.sig_progress.emit(curr_step, msg)

                        try:
                            with temp_conn.cursor() as cur:
                                cur.execute(query)
                            temp_conn.commit()               

                        except (Exception, psycopg2.Error) as error:
                            temp_conn.rollback()
                            fail_flag = True
                            gen_f.critical_log(
                                func=self.uninstall_thread_qgis_pkg_current,
                                location=FILE_LOCATION,
                                header="Resetting privileges from superusers",
                                error=error)
                            self.sig_fail.emit()

                print("Revoking privileges for superusers: done")

                # 3) drop feature types (layers)
                if drop_tuples_num > 0:
                    for usr_schema, cdb_schema, feat_type in drop_tuples:
                        ft = dlg.FeatureTypesRegistry[feat_type]
                        module_drop_func = ft.layers_drop_function

                        # Prepare the query for the drop_layer_{*} function
                        # E.g. qgis_pkg.drop_layers_building(usr_schema, cdb_schema)
                        query = pysql.SQL("""
                            SELECT {_qgis_pkg_schema}.{_module_drop_func}({_usr_schema},{_cdb_schema});
                            """).format(
                            _qgis_pkg_schema = pysql.Identifier(qgis_pkg_schema),
                            _module_drop_func = pysql.Identifier(module_drop_func),
                            _usr_schema = pysql.Literal(usr_schema),
                            _cdb_schema = pysql.Literal(cdb_schema)
                            )

                        # Update progress bar
                        msg = f"In {usr_schema}: dropping {feat_type} layers for {cdb_schema}"
                        curr_step += 1
                        self.sig_progress.emit(curr_step, msg)

                        try:
                            with temp_conn.cursor() as cur:
                                cur.execute(query)
                            temp_conn.commit()

                        except (Exception, psycopg2.Error) as error:
                            fail_flag = True
                            gen_f.critical_log(
                                func=self.uninstall_thread_qgis_pkg_current,
                                location=FILE_LOCATION,
                                header="Dropping layers",
                                error=error)
                            temp_conn.rollback()
                            self.sig_fail.emit()

                print("Dropping layers: done")

                # 4) drop detail views (dt_* views)
                if drop_detail_views_num > 0:
                    for usr_schema, cdb_schema in drop_detail_views:

                        query = pysql.SQL("""
                            SELECT {_qgis_pkg_schema}.drop_detail_view({_usr_schema},{_cdb_schema} );
                            """).format(
                            _qgis_pkg_schema = pysql.Identifier(dlg.QGIS_PKG_SCHEMA),
                            _usr_schema = pysql.Literal(usr_schema),
                            _cdb_schema = pysql.Literal(cdb_schema)
                            )

                        # Update progress bar
                        msg = f"In {usr_schema}: dropping detail views for {cdb_schema}"
                        curr_step += 1
                        self.sig_progress.emit(curr_step, msg)

                        try:
                            with temp_conn.cursor() as cur:
                                cur.execute(query)
                            temp_conn.commit()

                        except (Exception, psycopg2.Error) as error:
                            fail_flag = True
                            gen_f.critical_log(
                                func=self.uninstall_thread_qgis_pkg_current,
                                location=FILE_LOCATION,
                                header="Dropping detail views",
                                error=error)
                            temp_conn.rollback()
                            self.sig_fail.emit()
                            break

                print("Dropping detail views: done")

                # 5) drop usr_schemas
                if usr_schemas_num > 0:
                    for usr_schema in usr_schemas:

                        query = pysql.SQL("""
                            DROP SCHEMA IF EXISTS {_usr_schema} CASCADE;
                            """).format(
                            _usr_schema = pysql.Identifier(usr_schema)
                            )

                        # Update progress bar
                        msg = f"Dropped user schema: {usr_schema}"
                        curr_step += 1
                        self.sig_progress.emit(curr_step, msg)

                        try:
                            with temp_conn.cursor() as cur:
                                cur.execute(query)
                            temp_conn.commit()

                        except (Exception, psycopg2.Error) as error:
                            temp_conn.rollback()
                            fail_flag = True
                            gen_f.critical_log(
                                func=self.uninstall_thread_qgis_pkg_current,
                                location=FILE_LOCATION,
                                header="Dropping user schemas",
                                error=error)
                            self.sig_fail.emit()

                print("Dropping usr_schemas: done")

                # 7) Drop ga_indices
                if cdb_schemas_num > 0:
                    for cdb_schema in cdb_schemas:

                        query = pysql.SQL("""
                            SELECT {_qgis_pkg_schema}.drop_ga_indices({_cdb_schema});
                            """).format(
                            _qgis_pkg_schema = pysql.Identifier(dlg.QGIS_PKG_SCHEMA),
                            _cdb_schema = pysql.Literal(cdb_schema)
                            )

                        # Update progress bar
                        msg = f"Dropped ga indices from: {cdb_schema}"
                        curr_step += 1
                        self.sig_progress.emit(curr_step, msg)

                        try:
                            with temp_conn.cursor() as cur:
                                cur.execute(query)
                            temp_conn.commit()

                        except (Exception, psycopg2.Error) as error:
                            temp_conn.rollback()
                            fail_flag = True
                            gen_f.critical_log(
                                func=self.uninstall_thread_qgis_pkg_current,
                                location=FILE_LOCATION,
                                header="Dropping indices in generic attribute tables",
                                error=error)
                            self.sig_fail.emit()

                print("Dropping ga indices: done")

                # 8) Drop database group
                if not self.dlg.GROUP_NAME:
                    # Create the name and assign it to the variable
                    self.dlg.GROUP_NAME = sql.create_qgis_pkg_usrgroup_name(dlg=dlg)

                query = pysql.SQL("""
                    DROP ROLE IF EXISTS {_qgis_pkg_usrgroup};
                    """).format(
                    _qgis_pkg_usrgroup = pysql.Identifier(dlg.GROUP_NAME)
                    )

                # Update progress bar
                msg = f"Dropping group {dlg.GROUP_NAME}"
                curr_step += 1
                self.sig_progress.emit(curr_step, msg)

                try:
                    with temp_conn.cursor() as cur:
                        cur.execute(query)
                    temp_conn.commit()

                except (Exception, psycopg2.Error) as error:
                    temp_conn.rollback()
                    fail_flag = True
                    gen_f.critical_log(
                        func=self.uninstall_thread_qgis_pkg_current,
                        location=FILE_LOCATION,
                        header=f"Dropping group '{dlg.GROUP_NAME}'",
                        error=error)
                    self.sig_fail.emit()

                print("Dropping database group: done")

                # 9) drop qgis_pkg schema
                query = pysql.SQL("""
                    DROP SCHEMA IF EXISTS {_qgis_pkg_schema} CASCADE;
                    """).format(
                    _qgis_pkg_schema = pysql.Identifier(qgis_pkg_schema)
                    )

                # Update progress bar with current step and script.
                msg = "Dropping QGIS Package schema"
                curr_step += 1            
                self.sig_progress.emit(curr_step, msg)

                try:
                    with temp_conn.cursor() as cur:
                        cur.execute(query)
                    temp_conn.commit()

                except (Exception, psycopg2.Error) as error:
                    temp_conn.rollback()
                    fail_flag = True
                    gen_f.critical_log(
                        func=self.uninstall_thread_qgis_pkg_current,
                        location=FILE_LOCATION,
                        header=f"Dropping QGIS Package schema '{qgis_pkg_schema}'",
                        error=error)
                    self.sig_fail.emit()

                print("Dropping qgis_pkg schema: done")

                # Measure elapsed time
                print(f"Uninstallation of the QGIS Package completed in {round((time.time() - time_start), 4)} seconds")

        except (Exception, psycopg2.Error) as error:
            # temp_conn.rollback()
            fail_flag = True
            gen_f.critical_log(
                func=self.uninstall_thread_qgis_pkg_current,
                location=FILE_LOCATION,
                header="Establishing temporary connection",
                error=error)

        # No FAIL = SUCCESS
        if not fail_flag:
            self.sig_success.emit()

        self.sig_finished.emit()
        # Close temp connection
        temp_conn.close()
        return None


#--EVENTS  (start)  ##############################################################

def evt_qgis_pkg_uninstall_success(dlg: CDB4AdminDialog) -> None:
    """Event that is called when the thread executing the uninstallation finishes successfully.

    Shows success message at dlg.msg_bar: QgsMessageBar
    Shows success message in Connection Status groupbox
    Shows success message in QgsMessageLog
    """

    qgis_pkg_schema = dlg.QGIS_PKG_SCHEMA

    is_qgis_pkg_installed = sh_sql.is_qgis_pkg_installed(dlg=dlg)

    ######### FOR DEBUGGING PURPOSES ONLY ##########
    # is_qgis_pkg_installed = False
    ################################################

    if is_qgis_pkg_installed:
        # QGIS Package was NOT successfully removed
        evt_qgis_pkg_uninstall_fail(dlg=dlg)
    else:
        # QGIS Package was successfully removed
        # Replace with Success msg.
        msg = dlg.msg_bar.createMessage(c.UNINST_SUCC_MSG.format(pkg=qgis_pkg_schema))
        dlg.msg_bar.pushWidget(msg, Qgis.MessageLevel.Success, 5)

        # Inform user
        dlg.lblMainInst_out.setText(c.crit_warning_html.format(text=c.INST_FAIL_MSG.format(pkg=qgis_pkg_schema)))
        QgsMessageLog.logMessage(
                message=c.UNINST_SUCC_MSG.format(pkg=qgis_pkg_schema),
                tag=dlg.PLUGIN_NAME,
                level=Qgis.MessageLevel.Success,
                notifyUser=True)

        # Clear the label in the connection status groupbox
        dlg.lblUserInst_out.clear()

        # Finish (re)setting up the GUI
        ti_wf.setup_post_qgis_pkg_uninstallation(dlg=dlg)

    return None


def evt_qgis_pkg_uninstall_fail(dlg: CDB4AdminDialog) -> None:
    """Event that is called when the thread executing the uninstallation
    emits a fail signal meaning that something went wrong with uninstallation.

    Shows fail message at dlg.msg_bar: QgsMessageBar
    Shows fail message in Connection Status groupbox
    Shows fail message in QgsMessageLog
    """
    error: str = 'Uninstallation error'

    # Replace with Failure msg.
    msg = dlg.msg_bar.createMessage(error)
    dlg.msg_bar.pushWidget(msg, Qgis.MessageLevel.Critical, 5)

    # Update the label in the connection status
    dlg.lblMainInst_out.setText(c.failure_html.format(text=error))

    # Inform user
    QgsMessageLog.logMessage(message=error, tag=dlg.PLUGIN_NAME, level=Qgis.MessageLevel.Critical, notifyUser=True)
    
    return None

#--EVENTS  (end) ################################################################

#####################################################################################
##### USR SCHEMA DROP ###############################################################
#####################################################################################

def run_drop_usr_schema_thread(dlg: CDB4AdminDialog) -> None:
    """Function that uninstalls the {usr_schema} from the database
    by branching a new Worker thread to execute the operation on.
    """
    # Add a new progress bar to follow the installation procedure.
    dlg.create_progress_bar(layout=dlg.vLayoutUserInstGroup, position=2)

    # Create new thread object.
    dlg.thread = QThread()
    # Instantiate worker object for the operation.
    dlg.worker = DropUsrSchemaWorker(dlg=dlg)
    # Move worker object to the be executed on the new thread.
    dlg.worker.moveToThread(dlg.thread)

    #-SIGNALS--(start)#########################################################
    # Anti-panic clicking: Disable widgets to avoid queuing signals.
    # ...

    # Execute worker's 'run' method.
    dlg.thread.started.connect(dlg.worker.drop_usr_schema_thread)

    # Capture progress to show in bar.
    dlg.worker.sig_progress.connect(dlg.evt_update_bar)

    # Get rid of worker and thread objects.
    dlg.worker.sig_finished.connect(dlg.thread.quit)
    dlg.worker.sig_finished.connect(dlg.worker.deleteLater)
    dlg.thread.finished.connect(dlg.thread.deleteLater)

    # Re-enable the GUI
    dlg.thread.finished.connect(dlg.msg_bar.clearWidgets)

    # On installation status
    dlg.worker.sig_success.connect(lambda: evt_usr_schema_drop_success(dlg))
    dlg.worker.sig_fail.connect(lambda: evt_usr_schema_drop_fail(dlg))
    #-SIGNALS--(end)############################################################

    # Initiate worker thread
    dlg.thread.start()


class DropUsrSchemaWorker(QObject):
    """Class to assign Worker that drops a user schema from the database and all associated activities.
    """
    # Create custom signals.
    sig_finished = pyqtSignal()
    sig_progress = pyqtSignal(int, str)
    sig_success = pyqtSignal()
    sig_fail = pyqtSignal()

    def __init__(self, dlg: CDB4AdminDialog):
        super().__init__()
        self.dlg = dlg


    def drop_usr_schema_thread(self):
        """Execution method that uninstalls the {usr_schema} from the current database
        """
         # Flag to help us break from a failing installation.
        dlg = self.dlg
        fail_flag: bool = False
        qgis_pkg_schema = dlg.QGIS_PKG_SCHEMA
        
        usr_name: str = dlg.cbxUser.currentText()
        is_superuser = sql.is_superuser(dlg=dlg, usr_name=usr_name)

        usr_schema = dlg.USR_SCHEMA

        # drop_tuples: list = [tuple[str, str, str]] = [ListFeatureTypes]
        # Named tuples consisting of usr_schema, cdb_schema, feature type
        drop_tuples = sql.list_feature_types(dlg=dlg, usr_schema=dlg.USR_SCHEMA)
        # print("drop_tuples", drop_tuples)
        
        drop_detail_views: list[tuple[str, str]] = []
        if drop_tuples:
            # Extract only usr_schema and citydb_schema, without repetitions. It will look like:
            # [('qgis_giorgio', 'alderaan'), ('qgis_giorgio', 'citydb'), ('qgis_user_rw', 'alderaan'), ('qgis_user_rw', 'rh')]
            drop_detail_views = [*set([item[0:2] for item in drop_tuples])]
            # print("drop_detail_views", drop_detail_views)

        # Overview of the procedure:
        # 1a) revoke privileges for selected user
        # 1b) reset privileges for superuser(s)
        # 2) drop feature types (layers)
        # 3) drop detail views (dt_* views)
        # 4) drop usr_schema of the selected user

        # Set progress bar goal:
        # reset/revoke privileges: 1 action
        # drop feature types (layers): len(drop_tuples)
        # drop detail views: len(drop_detail_views)
        # drop usr schema: 1

        usr_names_num = 1

        if not drop_tuples:
            drop_tuples_num = 0
        else:
            drop_tuples_num = len(drop_tuples)

        if not drop_detail_views:
            drop_detail_views_num: int = 0
        else:
            drop_detail_views_num: int = len(drop_detail_views)

        steps_tot = usr_names_num + drop_detail_views_num + drop_tuples_num + 1
        dlg.bar.setMaximum(steps_tot)

        curr_step: int = 0

        try:
            # Open new temp session, reserved for usr_schema installation.
            temp_conn = conn_f.open_db_connection(db_connection=dlg.DB, app_name=" ".join([dlg.DLG_NAME_LABEL, "(User schema Uninstallation)"]))
            with temp_conn:

                # Start measuring time
                time_start = time.time()

                if is_superuser:
                    # 1b) reset privileges for superuser for all cdb_schemas
                    query = pysql.SQL("""
                        SELECT {_qgis_pkg_schema}.grant_qgis_usr_privileges(usr_name := {_usr_name}, priv_type := 'rw', cdb_schema := NULL);
                        """).format(
                        _qgis_pkg_schema = pysql.Identifier(dlg.QGIS_PKG_SCHEMA),
                        _usr_name = pysql.Literal(usr_name)
                        )

                else:
                    # 1a) revoke privileges for selected user from all cdb_schemas
                    query = pysql.SQL("""
                        SELECT {_qgis_pkg_schema}.revoke_qgis_usr_privileges(usr_name := {_usr_name}, cdb_schema := NULL);
                        """).format(
                        _qgis_pkg_schema = pysql.Identifier(dlg.QGIS_PKG_SCHEMA),
                        _usr_name = pysql.Literal(usr_name)
                        )

                # Update progress bar
                msg = f"Revoking/resetting privileges of user: {usr_name}"
                curr_step += 1
                self.sig_progress.emit(curr_step, msg)

                try:
                    with temp_conn.cursor() as cur:
                        cur.execute(query)
                    temp_conn.commit()

                except (Exception, psycopg2.Error) as error:
                    temp_conn.rollback()
                    fail_flag = True
                    gen_f.critical_log(
                        func=self.drop_usr_schema_thread,
                        location=FILE_LOCATION,
                        header=f"Revoking privileges from user '{usr_name}",
                        error=error)
                    self.sig_fail.emit()

                # 2) drop feature types (layers)
                if drop_tuples_num == 0:
                    pass
                else:
                    for usr_schema, cdb_schema, feat_type in drop_tuples:

                        # ft: FeatureType
                        ft = dlg.FeatureTypesRegistry[feat_type]
                        module_drop_func = ft.layers_drop_function

                        query = pysql.SQL("""
                            SELECT {_qgis_pkg_schema}.{_module_drop_func}({_usr_name},{_cdb_schema});
                            """).format(
                            _qgis_pkg_schema = pysql.Identifier(qgis_pkg_schema),
                            _module_drop_func = pysql.Identifier(module_drop_func),
                            _usr_name = pysql.Literal(usr_name),
                            _cdb_schema = pysql.Literal(cdb_schema)
                            )

                        # Update progress bar
                        msg = f"In {usr_schema}: dropping {feat_type} layers for {cdb_schema}"
                        curr_step += 1
                        self.sig_progress.emit(curr_step, msg)

                        try:
                            with temp_conn.cursor() as cur:
                                cur.execute(query)
                            temp_conn.commit()

                        except (Exception, psycopg2.Error) as error:
                            temp_conn.rollback()
                            fail_flag = True
                            gen_f.critical_log(
                                func=self.drop_usr_schema_thread,
                                location=FILE_LOCATION,
                                header="Dropping layers",
                                error=error)
                            self.sig_fail.emit()

                # 3) drop detail views (dt_* views)
                if drop_detail_views_num == 0:
                    pass
                else:
                    for usr_schema, cdb_schema in drop_detail_views:

                        query = pysql.SQL("""
                            SELECT {_qgis_pkg_schema}.drop_detail_view({_usr_schema},{_cdb_schema});
                            """).format(
                            _qgis_pkg_schema = pysql.Identifier(dlg.QGIS_PKG_SCHEMA),
                            _usr_schema = pysql.Literal(usr_name),
                            _cdb_schema = pysql.Literal(cdb_schema)
                            )

                        # Update progress bar
                        msg = f"In {usr_schema}: dropping detail views for {cdb_schema}"
                        curr_step += 1
                        self.sig_progress.emit(curr_step, msg)

                        try:
                            with temp_conn.cursor() as cur:
                                cur.execute(query)
                            temp_conn.commit()

                        except (Exception, psycopg2.Error) as error:
                            fail_flag = True
                            gen_f.critical_log(
                                func=self.drop_usr_schema_thread,
                                location=FILE_LOCATION,
                                header="Dropping detail views",
                                error=error)
                            temp_conn.rollback()
                            self.sig_fail.emit()

                # 4) drop usr_schema
                query = pysql.SQL("""
                    DROP SCHEMA IF EXISTS {_usr_schema} CASCADE;
                    """).format(
                    _usr_schema = pysql.Identifier(usr_schema)
                    )

                # Update progress bar with current step and script.
                msg = f"Dropping user schema: {usr_schema}"
                curr_step += 1
                self.sig_progress.emit(curr_step, msg)

                try:
                    with temp_conn.cursor() as cur:
                        cur.execute(query)
                    temp_conn.commit()

                except (Exception, psycopg2.Error) as error:
                    temp_conn.rollback()
                    fail_flag = True
                    gen_f.critical_log(
                        func=self.drop_usr_schema_thread,
                        location=FILE_LOCATION,
                        header="Dropping user schema '{usr_schema}'",
                        error=error)
                    self.sig_fail.emit()

                # Measure elapsed time
                print(f"Dropping user schema completed in {round((time.time() - time_start), 4)} seconds")


        except (Exception, psycopg2.Error) as error:
            temp_conn.rollback()
            fail_flag = True
            gen_f.critical_log(
                func=self.drop_usr_schema_thread,
                location=FILE_LOCATION,
                header="Establishing temporary connection",
                error=error)
            self.sig_fail.emit()

        # No FAIL = SUCCESS
        if not fail_flag:
            self.sig_success.emit()

        self.sig_finished.emit()
        # Close temp connection
        temp_conn.close()
        return None

#--EVENTS  (start)  ##############################################################

def evt_usr_schema_drop_success(dlg: CDB4AdminDialog) -> None:
    """Event that is called when the thread executing the uninstallation
    finishes successfully.

    Shows success message at dlg.msg_bar: QgsMessageBar
    Shows success message in Connection Status groupbox
    Shows success message in QgsMessageLog
    """
    usr_schema = dlg.USR_SCHEMA

    if not sh_sql.is_usr_schema_installed(dlg=dlg):
        # Replace with Success msg.
        msg = dlg.msg_bar.createMessage(c.UNINST_SUCC_MSG.format(pkg=usr_schema))
        dlg.msg_bar.pushWidget(widget=msg, level=Qgis.MessageLevel.Success, duration=5)

        # Inform user
        dlg.lblUserInst_out.setText(c.crit_warning_html.format(text=c.INST_FAIL_MSG.format(pkg=usr_schema)))
        QgsMessageLog.logMessage(
                message=c.UNINST_SUCC_MSG.format(pkg=usr_schema),
                tag=dlg.PLUGIN_NAME,
                level=Qgis.MessageLevel.Success,
                notifyUser=True)

        # Enable the remove from group button
        dlg.btnRemoveUserFromGrp.setDisabled(False)
        # Enable the user Installation button
        dlg.btnUsrInst.setDisabled(False)
        # Disable the the user Uninstallation button
        dlg.btnUsrUninst.setDisabled(True)
        
        # Reset and disable the user privileges groupbox
        ti_wf.gbxPriv_reset(dlg=dlg) # this also disables it.

    else:
        evt_usr_schema_drop_fail(dlg=dlg)


def evt_usr_schema_drop_fail(dlg: CDB4AdminDialog) -> None:
    """Event that is called when the thread executing the uninstallation
    emits a fail signal meaning that something went wrong with uninstallation.

    Shows fail message at dlg.msg_bar: QgsMessageBar
    Shows fail message in Connection Status groupbox
    Shows fail message in QgsMessageLog
    """
    error: str ='Error uninstalling the user schema.'

    # Replace with Failure msg.
    msg = dlg.msg_bar.createMessage(error)
    dlg.msg_bar.pushWidget(widget=msg, level=Qgis.MessageLevel.Critical, duration=5)

    # Inform user
    dlg.lblUserInst_out.setText(error)
    QgsMessageLog.logMessage(
            message=error,
            tag=dlg.PLUGIN_NAME,
            level=Qgis.MessageLevel.Critical,
            notifyUser=True)

    # Disable the remove from group button
    dlg.btnRemoveUserFromGrp.setDisabled(True)
    # Disable the user Installation button
    dlg.btnUsrInst.setDisabled(True)
    # Enable the the user Uninstallation button
    dlg.btnUsrUninst.setDisabled(False)

#--EVENTS  (end) ################################################################


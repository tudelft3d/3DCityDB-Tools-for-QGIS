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

import os

from qgis.PyQt.QtCore import QObject, QThread, pyqtSignal
from qgis.core import Qgis, QgsMessageLog
import psycopg2

from ....cdb_loader import CDBLoader # Used only to add the type of the function parameters

from ... import cdb4_constants as c
from ...gui_db_connector.functions import conn_functions as conn_f

from . import sql
from . import tab_conn_widget_functions as wf
from ...shared.functions import sql as sh_sql

class QgisPKGInstallWorker(QObject):
    """Class to assign Worker that executes the 'installation scripts'
    to install the plugin package (qgis_pkg) in the database.
    """
    # Create custom signals.
    sig_finished = pyqtSignal()
    sig_progress = pyqtSignal(str, int, str)
    sig_success = pyqtSignal()
    sig_fail = pyqtSignal()

    def __init__(self, cdbLoader: CDBLoader, sql_scripts_path):
        super().__init__()
        self.plugin = cdbLoader
        self.sql_scripts_path = sql_scripts_path

    def install_thread(self):
        """Execution method that installs the qgis_pkg. SQL scripts are run
        directly using the execution method. No psql app needed.
        """
        # Flag to help us break from a failing installation.
        fail_flag: bool = False

        # Get an alphabetical ordered list of the script names. Important: Keep the order with number prefixes.
        install_scripts: list = sorted(os.listdir(self.sql_scripts_path))

        # Set progress bar goal
        self.plugin.admin_dlg.bar.setMaximum(len(install_scripts))

        # Open new temp session, reserved for installation.
        with conn_f.connect(db_connection=self.plugin.DB, app_name=" ".join([self.plugin.PLUGIN_NAME_ADMIN, "(Installation)"])) as conn:
            for s, script in enumerate(install_scripts, start=1):

                # Update progress bar with current step and script.
                text = " ".join(["Installing:", script])
                #self.sig_progress.emit("admin_dlg", s, text)
                self.sig_progress.emit(self.plugin.ADMIN_DLG, s, text)
                try:
                    with conn.cursor() as cursor:
                        with open(os.path.join(self.sql_scripts_path, script), "r") as sql_script:
                            cursor.execute(sql_script.read())
                    conn.commit()

                except (Exception, psycopg2.DatabaseError) as error:
                    print(error)
                    fail_flag = True
                    conn.rollback()
                    self.sig_fail.emit()
                    break

        # No FAIL = SUCCESS
        if not fail_flag:
            self.sig_success.emit()
        self.sig_finished.emit()


def install_qgis_pkg_thread(cdbLoader: CDBLoader, sql_scripts_path: str, qgis_pkg_schema: str) -> None:
    """Function that installs the plugin package (qgis_pkg) in the database
    by branching a new Worker thread to execute the operation on.

    *   :param path: The relative path to the directory storing the
            SQL installation scripts (e.g. ./citydb_loader/cdb4/ddl_scripts/postgresql)
        :type path: str
    
    *   :param pkg: The package (schema) name that's installed
        :type pkg: str
    """
    dlg = cdbLoader.admin_dlg

    if qgis_pkg_schema == cdbLoader.QGIS_PKG_SCHEMA:
        # Add a new progress bar to follow the installation procedure.
        cdbLoader.create_progress_bar(dialog=dlg, layout=dlg.vLayoutMainInst, position=-1)

    # Create new thread object.
    cdbLoader.thread = QThread()
    # Instantiate worker object for the operation.
    cdbLoader.worker = QgisPKGInstallWorker(cdbLoader, sql_scripts_path)
    # Move worker object to the be executed on the new thread.
    cdbLoader.worker.moveToThread(cdbLoader.thread)

    #-SIGNALS--################################################################
    #-(start)--################################################################

    # Execute worker's 'run' method.
    cdbLoader.thread.started.connect(cdbLoader.worker.install_thread)

    # Capture progress to show in bar.
    cdbLoader.worker.sig_progress.connect(cdbLoader.evt_update_bar)

    # Get rid of worker and thread objects.
    cdbLoader.worker.sig_finished.connect(cdbLoader.thread.quit)
    cdbLoader.worker.sig_finished.connect(cdbLoader.worker.deleteLater)
    cdbLoader.thread.finished.connect(cdbLoader.thread.deleteLater)

    # On installation status
    cdbLoader.worker.sig_success.connect(lambda: ev_qgis_pkg_install_success(cdbLoader, qgis_pkg_schema))
    cdbLoader.worker.sig_fail.connect(lambda: ev_qgis_pkg_install_fail(cdbLoader, qgis_pkg_schema))

    #-SIGNALS--################################################################
    #--(end)---################################################################

    # Initiate worker thread
    cdbLoader.thread.start()


class QgisPKGUninstallWorker(QObject):
    """Class to assign Worker that executes the 'uninstallation scripts'
    to uninstall the plugin package (qgis_pkg) from the database.
    """
    # Create custom signals.
    sig_finished = pyqtSignal()
    sig_progress = pyqtSignal(str, int, str)
    sig_success = pyqtSignal()
    sig_fail = pyqtSignal()

    def __init__(self, cdbLoader: CDBLoader):
        super().__init__()
        self.plugin = cdbLoader

    def uninstall_thread(self):
        """Execution method that uninstalls the plugin package for support of the default schema.
        """
        # Flag to help us break from a failing installation.
        fail_flag: bool = False

        # Get users and cdb_schemas
        usrs: tuple = sql.fetch_list_qgis_pkg_usrgroup_members(cdbLoader=self.plugin)
        cdb_schemas, dummy = sh_sql.exec_list_cdb_schemas_all(cdbLoader=self.plugin)
        dummy = None # discard byproduct
        qgis_pkg_schema: str = self.plugin.QGIS_PKG_SCHEMA

        # Set progress bar goal:
        # revoke privileges - 1 x users_num actions
        # drop layers - users_num x modules_num x cdbschemas_num actions
        # drop usr schemas - 1 x users_num actions
        # drop 'qgis_pkg' - 1 actions

        curr_step: int
        steps_no = (len(usrs) * (1+1)) + (len(usrs) * len(c.drop_layers_funcs) * len(cdb_schemas)) + 1
        self.plugin.admin_dlg.bar.setMaximum(steps_no)
        try:
            curr_step = 0
            for usr_name in usrs:
                # Get current user's schema
                usr_schema: str = sh_sql.exec_create_qgis_usr_schema_name(self.plugin, usr_name)

                #NOTE: duplicate code (see DropUserSchemaWorker)
                # Revoke privileges from ALL cdb_schemas, (also the empty ones)
                sql.exec_revoke_qgis_usr_privileges(cdbLoader=self.plugin, usr_name=usr_name, cdb_schema=None)
                # Update progress bar with current step and script.
                text = " ".join(["Revoking privileges from user:", usr_name])
                curr_step += 1
                #self.sig_progress.emit("admin_dlg", curr_step, text)
                self.sig_progress.emit(self.plugin.ADMIN_DLG, curr_step, text)

                for cdb_schema in cdb_schemas:
                    with conn_f.connect(db_connection=self.plugin.DB, app_name=f"{conn_f.connect.__defaults__[0]} (Dropping Layers)") as conn:
                        for module_drop_func in c.drop_layers_funcs:
                            with conn.cursor() as cursor:
                                cursor.callproc(f"{qgis_pkg_schema}.{module_drop_func}", [usr_name, cdb_schema])
                            conn.commit()
                            # Update progress bar with current step and script.
                            text = " ".join(["Dropping layers:", module_drop_func])
                            curr_step += 1
                            #self.sig_progress.emit("admin_dlg", curr_step, text)
                            self.sig_progress.emit(self.plugin.ADMIN_DLG, curr_step, text)

                # Drop qgis_{usr} schema
                sql.exec_drop_db_schema(cdbLoader=self.plugin, schema=usr_schema, close_connection=False)
                # Update progress bar with current step and script.
                text = " ".join(["Dropping user schema:", usr_schema])
                curr_step += 1
                #self.sig_progress.emit("admin_dlg", curr_step, text)
                self.sig_progress.emit(self.plugin.ADMIN_DLG, curr_step, text)

            # Drop "qgis_pkg" schema
            sql.exec_drop_db_schema(cdbLoader=self.plugin, schema=qgis_pkg_schema, close_connection=False)
            # Update progress bar with current step and script.
            text = " ".join(["Dropping QGIS Package schema:", qgis_pkg_schema])
            curr_step += 1
            #self.sig_progress.emit("admin_dlg", curr_step, text)
            self.sig_progress.emit(self.plugin.ADMIN_DLG, curr_step, text)

        except (Exception, psycopg2.DatabaseError) as error:
            print(error)
            fail_flag = True
            conn.rollback()
            self.sig_fail.emit()

        # No FAIL = SUCCESS
        if not fail_flag:
            self.sig_success.emit()
        self.sig_finished.emit()


def uninstall_qgis_pkg_thread(cdbLoader: CDBLoader) -> None:
    """Function that uninstalls the qgis_pkg schema from the database
    by branching a new Worker thread to execute the operation on.
    """
    dlg = cdbLoader.admin_dlg

    # Add a new progress bar to follow the installation procedure.
    cdbLoader.create_progress_bar(dialog=dlg, layout=dlg.vLayoutMainInst, position=-1)

    # Create new thread object.
    cdbLoader.thread = QThread()
    # Instantiate worker object for the operation.
    cdbLoader.worker = QgisPKGUninstallWorker(cdbLoader)
    # Move worker object to the be executed on the new thread.
    cdbLoader.worker.moveToThread(cdbLoader.thread)

    #-SIGNALS--################################################################
    #-(start)--################################################################

    # Execute worker's 'run' method.
    cdbLoader.thread.started.connect(cdbLoader.worker.uninstall_thread)

    # Capture progress to show in bar.
    cdbLoader.worker.sig_progress.connect(cdbLoader.evt_update_bar)

    # Get rid of worker and thread objects.
    cdbLoader.worker.sig_finished.connect(cdbLoader.thread.quit)
    cdbLoader.worker.sig_finished.connect(cdbLoader.worker.deleteLater)
    cdbLoader.thread.finished.connect(cdbLoader.thread.deleteLater)

    # On installation status
    cdbLoader.worker.sig_success.connect(lambda: ev_qgis_pkg_uninstall_success(cdbLoader))
    cdbLoader.worker.sig_fail.connect(lambda: ev_qgis_pkg_uninstall_fail(cdbLoader))

    #-SIGNALS--################################################################
    #--(end)---################################################################

    # Initiate worker thread
    cdbLoader.thread.start()


class DropUsrSchemaWorker(QObject):
    """Class to assign Worker that drops a user schema from the database and all associated activities.
    """
    # Create custom signals.
    sig_finished = pyqtSignal()
    sig_progress = pyqtSignal(str, int, str)
    sig_success = pyqtSignal()
    sig_fail = pyqtSignal()

    def __init__(self, cdbLoader: CDBLoader):
        super().__init__()
        self.plugin = cdbLoader

    def drop_usr_schema_thread(self):
        """Execution method that uninstalls the {usr_schema} from the current database
        """
         # Flag to help us break from a failing installation.
        fail_flag: bool = False

        usr_name: str = self.plugin.admin_dlg.cbxUser.currentText()
        usr_schema: str = self.plugin.USR_SCHEMA
        cdb_schemas, dummy = sh_sql.exec_list_cdb_schemas_all(cdbLoader=self.plugin)
        dummy = None # discard byproduct
        qgis_pkg_schema: str = self.plugin.QGIS_PKG_SCHEMA

        # Set progress bar goal:
        # revoke privileges - 1 actions
        # drop layers - modules_num x cdbschemas_num actions
        # drop usr schema - 1 actions

        curr_step: int
        steps_no = 1 + (len(c.drop_layers_funcs) * len(cdb_schemas)) + 1
        self.plugin.admin_dlg.bar.setMaximum(steps_no)
        try:
            curr_step = 0
            # Revoke privileges from ALL cdb_schemas (also the empty ones)
            sql.exec_revoke_qgis_usr_privileges(cdbLoader=self.plugin, usr_name=usr_name, cdb_schema=None)
            # Update progress bar with current step and script.
            text = " ".join(["Revoking privileges from user:", usr_name])
            curr_step += 1
            #self.sig_progress.emit("admin_dlg", curr_step, text)
            self.sig_progress.emit(self.plugin.ADMIN_DLG, curr_step, text)

            for cdb_schema in cdb_schemas:
                with conn_f.connect(db_connection=self.plugin.DB, app_name=f"{conn_f.connect.__defaults__[0]} (Dropping layers)") as conn:
                    for module_drop_func in c.drop_layers_funcs:
                        with conn.cursor() as cursor:
                            cursor.callproc(f"{qgis_pkg_schema}.{module_drop_func}", [usr_name, cdb_schema])
                        conn.commit()
                        # Update progress bar with current step and script.
                        text = " ".join(["Dropping layers:", module_drop_func])
                        curr_step += 1
                        #self.sig_progress.emit("admin_dlg", curr_step, text)
                        self.sig_progress.emit(self.plugin.ADMIN_DLG, curr_step, text)

            # Drop user schema
            sql.exec_drop_db_schema(cdbLoader=self.plugin, schema=usr_schema, close_connection=False)
            # Update progress bar with current step and script.
            text = " ".join(["Dropping user schema:", usr_schema])
            curr_step += 1
            #self.sig_progress.emit("admin_dlg", curr_step, text)
            self.sig_progress.emit(self.plugin.ADMIN_DLG, curr_step, text)

        except (Exception, psycopg2.DatabaseError) as error:
            print(error)
            fail_flag = True
            conn.rollback()
            self.sig_fail.emit()

        # No FAIL = SUCCESS
        if not fail_flag:
            self.sig_success.emit()
        self.sig_finished.emit()


def drop_usr_schema_thread(cdbLoader: CDBLoader) -> None:
    """Function that uninstalls the {usr_schema} from the database
    by branching a new Worker thread to execute the operation on.
    """
    dlg = cdbLoader.admin_dlg

    # Add a new progress bar to follow the installation procedure.
    cdbLoader.create_progress_bar(dialog=dlg, layout=dlg.vLayoutUsrInst, position=-1)

    # Create new thread object.
    cdbLoader.thread = QThread()
    # Instantiate worker object for the operation.
    cdbLoader.worker = DropUsrSchemaWorker(cdbLoader)
    # Move worker object to the be executed on the new thread.
    cdbLoader.worker.moveToThread(cdbLoader.thread)

    #-SIGNALS--(start)#########################################################

    # Execute worker's 'run' method.
    cdbLoader.thread.started.connect(cdbLoader.worker.drop_usr_schema_thread)

    # Capture progress to show in bar.
    cdbLoader.worker.sig_progress.connect(cdbLoader.evt_update_bar)

    # Get rid of worker and thread objects.
    cdbLoader.worker.sig_finished.connect(cdbLoader.thread.quit)
    cdbLoader.worker.sig_finished.connect(cdbLoader.worker.deleteLater)
    cdbLoader.thread.finished.connect(cdbLoader.thread.deleteLater)

    # On installation status
    cdbLoader.worker.sig_success.connect(lambda: ev_usr_schema_drop_success(cdbLoader))
    cdbLoader.worker.sig_fail.connect(lambda: ev_usr_schema_drop_fail(cdbLoader))

    #-SIGNALS--(end)############################################################

    # Initiate worker thread
    cdbLoader.thread.start()

#--EVENTS  (start)  ##############################################################


def ev_qgis_pkg_install_success(cdbLoader: CDBLoader, pkg: str) -> None:
    """Event that is called when the thread executing the installation finishes successfully.

    Shows success message at cdbLoader.usr_dlg.msg_bar: QgsMessageBar
    Shows success message in Connection Status groupbox
    Shows success message in QgsMessageLog
    """
    dlg = cdbLoader.admin_dlg

    # Remove progress bar
    dlg.msg_bar.clearWidgets()

    if sh_sql.is_qgis_pkg_installed(cdbLoader):
        # Replace with Success msg.
        msg = dlg.msg_bar.createMessage(c.INST_SUCC_MSG.format(pkg=pkg))
        dlg.msg_bar.pushWidget(msg, Qgis.Success, 5)

        # Inform user
        dlg.lblMainInst_out.setText(c.success_html.format(text=c.INST_MSG + " (v. " + c.QGIS_PKG_MIN_VERSION_TXT + ")").format(pkg=cdbLoader.QGIS_PKG_SCHEMA))
        QgsMessageLog.logMessage(
                message=c.INST_SUCC_MSG.format(pkg=pkg),
                tag=cdbLoader.PLUGIN_NAME,
                level=Qgis.Success,
                notifyUser=True)

        dlg.btnMainInst.setDisabled(True)
        dlg.btnMainUninst.setDisabled(False)

        # Get users from database.
        usrs = sql.fetch_list_qgis_pkg_usrgroup_members(cdbLoader)
        wf.fill_users_box(cdbLoader,usrs)
    else:
        ev_qgis_pkg_install_fail(cdbLoader, pkg)


def ev_qgis_pkg_install_fail(cdbLoader: CDBLoader, pkg: str) -> None:
    """Event that is called when the thread executing the installation
    emits a fail signal meaning that something went wrong with installation.

    It prompt the user to clear the installation before trying again.
    .. Not sure if this is necessary as in every installation the package
    .. is dropped to replace it with a new one.

    Shows fail message at cdbLoader.usr_dlg.msg_bar: QgsMessageBar
    Shows fail message in Connection Status groupbox
    Shows fail message in QgsMessageLog
    """
    dlg = cdbLoader.admin_dlg

    # Remove progress bar
    dlg.msg_bar.clearWidgets()

    # Replace with Failure msg.
    msg = dlg.msg_bar.createMessage(c.INST_ERROR_MSG.format(pkg=pkg))
    dlg.msg_bar.pushWidget(msg, Qgis.Critical, 5)

    # Inform user
    dlg.lblMainInst_out.setText(c.failure_html.format(text=c.INST_FAIL_MSG.format(pkg=pkg)))
    QgsMessageLog.logMessage(
            message=c.INST_ERROR_MSG.format(pkg=pkg),
            tag=cdbLoader.PLUGIN_NAME,
            level=Qgis.Critical,
            notifyUser=True)

    # Drop corrupted installation.
    sql.exec_drop_db_schema(cdbLoader, schema=cdbLoader.QGIS_PKG_SCHEMA, close_connection=False)
    dlg.btnMainUninst.setDisabled(True)


def ev_qgis_pkg_uninstall_success(cdbLoader: CDBLoader) -> None:
    """Event that is called when the thread executing the uninstallation  finishes successfully.

    Shows success message at cdbLoader.usr_dlg.msg_bar: QgsMessageBar
    Shows success message in Connection Status groupbox
    Shows success message in QgsMessageLog
    """
    dlg = cdbLoader.admin_dlg

    # Remove progress bar
    dlg.msg_bar.clearWidgets()

    qgis_pkg_schema = cdbLoader.QGIS_PKG_SCHEMA

    if not sh_sql.is_qgis_pkg_installed(cdbLoader):
        # Replace with Success msg.
        msg = dlg.msg_bar.createMessage(c.UNINST_SUCC_MSG.format(pkg=qgis_pkg_schema))
        dlg.msg_bar.pushWidget(msg, Qgis.Success, 5)

        # Inform user
        dlg.lblMainInst_out.setText(c.crit_warning_html.format(text=c.INST_FAIL_MSG.format(pkg=qgis_pkg_schema)))
        QgsMessageLog.logMessage(
                message=c.UNINST_SUCC_MSG.format(pkg=qgis_pkg_schema),
                tag=cdbLoader.PLUGIN_NAME,
                level=Qgis.Success,
                notifyUser=True)
 
        dlg.btnMainUninst.setDisabled(True)
        dlg.btnMainInst.setDisabled(False)
        dlg.lblUserInst_out.clear()
        wf.gbxUserInst_reset(cdbLoader)
    else:
        ev_qgis_pkg_uninstall_fail(cdbLoader, qgis_pkg_schema)


def ev_qgis_pkg_uninstall_fail(cdbLoader: CDBLoader, error: str = 'error') -> None:
    """Event that is called when the thread executing the uninstallation
    emits a fail signal meaning that something went wrong with uninstallation.

    Shows fail message at cdbLoader.usr_dlg.msg_bar: QgsMessageBar
    Shows fail message in Connection Status groupbox
    Shows fail message in QgsMessageLog
    """
    dlg = cdbLoader.admin_dlg

    # Remove progress bar
    dlg.msg_bar.clearWidgets()

    # Replace with Failure msg.
    msg = dlg.msg_bar.createMessage(error)
    dlg.msg_bar.pushWidget(msg, Qgis.Critical, 5)

    # Inform user
    dlg.lblMainInst_out.setText(error)
    QgsMessageLog.logMessage(
            message=error,
            tag=cdbLoader.PLUGIN_NAME,
            level=Qgis.Critical,
            notifyUser=True)


def ev_usr_schema_drop_success(cdbLoader: CDBLoader) -> None:
    """Event that is called when the thread executing the uninstallation
    finishes successfully.

    Shows success message at cdbLoader.admin_dlg.msg_bar: QgsMessageBar
    Shows success message in Connection Status groupbox
    Shows success message in QgsMessageLog
    """
    dlg = cdbLoader.admin_dlg

    # Remove progress bar
    dlg.msg_bar.clearWidgets()

    usr_schema = cdbLoader.USR_SCHEMA

    if not sh_sql.is_usr_schema_installed(cdbLoader):
        # Replace with Success msg.
        msg = dlg.msg_bar.createMessage(c.UNINST_SUCC_MSG.format(pkg=usr_schema))
        dlg.msg_bar.pushWidget(msg, Qgis.Success, 5)

        # Inform user
        dlg.lblUserInst_out.setText(c.crit_warning_html.format(text=c.INST_FAIL_MSG.format(pkg=usr_schema)))
        QgsMessageLog.logMessage(
                message=c.UNINST_SUCC_MSG.format(pkg=usr_schema),
                tag=cdbLoader.PLUGIN_NAME,
                level=Qgis.Success,
                notifyUser=True)
        dlg.btnUsrUninst.setDisabled(True)
    else:
        ev_usr_schema_drop_fail(cdbLoader, usr_schema)


def ev_usr_schema_drop_fail(cdbLoader: CDBLoader, error: str ='error') -> None:
    """Event that is called when the thread executing the uninstallation
    emits a fail signal meaning that something went wrong with uninstallation.


    Shows fail message at cdbLoader.admin_dlg.msg_bar: QgsMessageBar
    Shows fail message in Connection Status groupbox
    Shows fail message in QgsMessageLog
    """
    dlg = cdbLoader.admin_dlg

    # Remove progress bar
    dlg.msg_bar.clearWidgets()

    # Replace with Failure msg.
    msg = dlg.msg_bar.createMessage(error)
    dlg.msg_bar.pushWidget(msg, Qgis.Critical, 5)

    # Inform user
    dlg.lblUserInst_out.setText(error)
    QgsMessageLog.logMessage(
            message=error,
            tag=cdbLoader.PLUGIN_NAME,
            level=Qgis.Critical,
            notifyUser=True)
    dlg.btnUsrUninst.setDisabled(False)

#--EVENTS  (end) ################################################################


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

from qgis.PyQt.QtCore import QObject,QThread,pyqtSignal, Qt
from qgis.PyQt.QtWidgets import QProgressBar, QVBoxLayout
from qgis.core import Qgis, QgsMessageLog
from qgis.gui import QgsMessageBar
import psycopg2

from ....cdb_loader import CDBLoader # Used only to add the type of the function parameters

from ... import cdb4_constants as c
from ...gui_db_connector.functions import conn_functions as conn_f

from . import sql
from . import tab_conn_widget_functions as wf

def create_progress_bar(dialog, layout: QVBoxLayout, position: int) -> None:
    """Function that creates a QProgressBar embedded into
    a QgsMessageBar, in a specific position in the GUI.

    *   :param layout: QLayout of the gui where the bar is to be
            assigned.

        :type layout: QBoxLayout

    *   :param position: The place (index) in the layout to place
            the progress bar

        :type position: int

    """

    # Create QgsMessageBar instance.
    dialog.msg_bar = QgsMessageBar()

    # Add the message bar into the input layer and position.
    layout.insertWidget(position, dialog.msg_bar)

    # Create QProgressBar instance into QgsMessageBar.
    dialog.bar = QProgressBar(parent=dialog.msg_bar)

    # Setup progress bar.
    dialog.bar.setAlignment(Qt.AlignLeft|Qt.AlignVCenter)
    dialog.bar.setStyleSheet("text-align: left;")

    # Show progress bar in message bar.
    dialog.msg_bar.pushWidget(dialog.bar, Qgis.Info)

class QgisPkgInstallationWorker(QObject):
    """Class to assign Worker that executes the 'installation scripts'
    to install the plugin package (qgis_pkg) in the database."""

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
        fail_flag = False

        # Get an alphabetical ordered list of the script names.
        # Important: Keep the order with number prefixes.
        install_scripts = sorted(os.listdir(self.sql_scripts_path))

        # Set progress bar goal
        self.plugin.admin_dlg.bar.setMaximum(len(install_scripts))

        # Open new temp session, reserved for installation.
        with conn_f.connect(db_connection=self.plugin.DB, app_name=" ".join([self.plugin.PLUGIN_NAME_ADMIN, "(Installation)"])) as conn:
            for s, script in enumerate(install_scripts, start=1):

                # Update progress bar with current step and script.
                text = " ".join(["Installing:", script])
                self.sig_progress.emit("admin", s, text)
                try:
                    # Attempt direct sql injection.
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
            SQL installation scripts
            (e.g. ./citydb_loader/sql_scripts/postgresql)

        :type path: str
    
    *   :param pkg: The package (schema) name that's installed

        :type pkg: str
    """

    if qgis_pkg_schema == cdbLoader.QGIS_PKG_SCHEMA:
        # Add a new progress bar to follow the installation procedure.
        create_progress_bar(
            dialog=cdbLoader.admin_dlg,
            layout=cdbLoader.admin_dlg.vLayoutMainInst,
            position=1)

    # Create new thread object.
    cdbLoader.thread = QThread()
    # Instantiate worker object for the operation.
    cdbLoader.worker = QgisPkgInstallationWorker(cdbLoader, sql_scripts_path)
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
    cdbLoader.worker.sig_success.connect(lambda: ev_install_success(cdbLoader, qgis_pkg_schema))
    cdbLoader.worker.sig_fail.connect(lambda: ev_install_fail(cdbLoader, qgis_pkg_schema))

    #-SIGNALS--################################################################
    #--(end)---################################################################

    # Initiate worker thread
    cdbLoader.thread.start()

class QgisPkgUnInstallationWorker(QObject):

    # Create custom signals.
    sig_finished = pyqtSignal()
    sig_progress = pyqtSignal(str, int, str)
    sig_success = pyqtSignal()
    sig_fail = pyqtSignal()

    def __init__(self, cdbLoader: CDBLoader):
        super().__init__()
        self.plugin = cdbLoader

    def uninstall_thread(self):
        """Execution method that uninstalls the plugin package for
        support of the default schema.
        """
        # Flag to help us break from a failing installation.
        fail_flag = False

        # Get users and cdb_schemas
        users = sql.fetch_list_qgis_pkg_usrgroup_members(self.plugin)
        cdb_schemas = sql.fetch_list_cdb_schemas(self.plugin, False)

        # Set progress bar goal:
        # revoke privileges - 1 x users_num actions
        # drop layers - users_num x modules_num x cdbschemas_num actions
        # drop usr schemas - 1 x users_num actions
        # drop 'qgis_pkg' - 1 actions

        steps_no = (len(users) * (1+1)) + (len(users) * len(c.drop_layers_funcs) * len(cdb_schemas)) + 1
        self.plugin.admin_dlg.bar.setMaximum(steps_no)
        try:
            curr_step = 0
            for user_name in users:
                # Get current user's schema
                usr_schema = sql.exec_create_qgis_usr_schema_name(self.plugin, user_name)

                #NOTE: duplicate code (see DropUserSchemaWorker)
                # Revoke privileges from ALL cdb_schemas, (also the empty ones)
                sql.exec_revoke_qgis_usr_privileges(self.plugin, user_name, None)
                # Update progress bar with current step and script.
                text = " ".join(["Revoking privileges from user:", user_name])
                curr_step += 1
                self.sig_progress.emit("admin", curr_step, text)

                for schema in cdb_schemas:
                    # Drop layers: 10
                    with conn_f.connect(db_connection=self.plugin.DB, app_name=f"{conn_f.connect.__defaults__[0]} (Dropping Layers)") as conn:
                        for module_func in c.drop_layers_funcs:
                            # Attempt direct SQL injection.
                            with conn.cursor() as cursor:
                                cursor.callproc(f"{self.plugin.QGIS_PKG_SCHEMA}.{module_func}", [user_name, schema])
                            conn.commit()
                            # Update progress bar with current step and script.
                            text = " ".join(["Dropping layers:", module_func])
                            curr_step += 1
                            self.sig_progress.emit("admin", curr_step, text)

                #Drop user schema
                sql.exec_drop_db_schema(self.plugin, usr_schema, False)
                # Update progress bar with current step and script.
                text = " ".join(["Dropping user schema:", usr_schema])
                curr_step += 1
                self.sig_progress.emit("admin", curr_step, text)

            #Drop "qgis_pkg"
            sql.exec_drop_db_schema(self.plugin, self.plugin.QGIS_PKG_SCHEMA, False)
            # Update progress bar with current step and script.
            text = " ".join(["Dropping main schema:", self.plugin.QGIS_PKG_SCHEMA])
            curr_step += 1
            self.sig_progress.emit("admin", curr_step, text)

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

    # Add a new progress bar to follow the installation procedure.
    create_progress_bar(
        dialog=cdbLoader.admin_dlg,
        layout=cdbLoader.admin_dlg.vLayoutMainInst,
        position=-1)

    # Create new thread object.
    cdbLoader.thread = QThread()
    # Instantiate worker object for the operation.
    cdbLoader.worker = QgisPkgUnInstallationWorker(cdbLoader)
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
    cdbLoader.worker.sig_success.connect(lambda: ev_uninstall_success(cdbLoader))
    cdbLoader.worker.sig_fail.connect(lambda: ev_uninstall_fail(cdbLoader))

    #-SIGNALS--################################################################
    #--(end)---################################################################

    # Initiate worker thread
    cdbLoader.thread.start()

class DropUsrSchemaWorker(QObject):

    # Create custom signals.
    sig_finished = pyqtSignal()
    sig_progress = pyqtSignal(str, int, str)
    sig_success = pyqtSignal()
    sig_fail = pyqtSignal()

    def __init__(self, cdbLoader: CDBLoader):
        super().__init__()
        self.plugin = cdbLoader

    def drop_thread(self):
        """Execution method that uninstalls the {usr_schema} from the current database"""
        
        # Flag to help us break from a failing installation.
        fail_flag = False

        usr_name = self.plugin.admin_dlg.cbxUser.currentText()
        usr_schema = self.plugin.USR_SCHEMA
        cdb_schemas = sql.fetch_list_cdb_schemas(self.plugin, False)

        # Set progress bar goal:
        # revoke privileges - 1 actions
        # drop layers - modules_num x cdbschemas_num actions
        # drop usr schema - 1 actions

        steps_no = 1 + (len(c.drop_layers_funcs) * len(cdb_schemas)) + 1
        self.plugin.admin_dlg.bar.setMaximum(steps_no)
        try:
            curr_step = 0
            
            # Revoke privileges from ALL cdb_schemas (also the empty ones)
            sql.exec_revoke_qgis_usr_privileges(self.plugin, usr_name, None)

            # Update progress bar with current step and script.
            text = " ".join(["Revoking privileges from user:", usr_name])
            curr_step += 1
            self.sig_progress.emit("admin", curr_step, text)

            for schema in cdb_schemas:
                # Drop layers: 10
                with conn_f.connect(db_connection=self.plugin.DB, app_name=f"{conn_f.connect.__defaults__[0]} (Dropping layers)") as conn:
                    for module_func in c.drop_layers_funcs:
                        # Attempt direct SQL injection.
                        with conn.cursor() as cursor:
                            cursor.callproc(f"{self.plugin.QGIS_PKG_SCHEMA}.{module_func}", [usr_name, schema])
                        conn.commit()
                        # Update progress bar with current step and script.
                        text = " ".join(["Dropping layers:", module_func])
                        curr_step += 1
                        self.sig_progress.emit("admin", curr_step, text)

            #Drop user schema
            sql.exec_drop_db_schema(self.plugin, usr_schema, False)
            # Update progress bar with current step and script.
            text = " ".join(["Dropping user schema:", usr_schema])
            curr_step += 1
            self.sig_progress.emit("admin", curr_step, text)

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

    # Add a new progress bar to follow the installation procedure.
    create_progress_bar(
        dialog=cdbLoader.admin_dlg,
        layout=cdbLoader.admin_dlg.vLayoutUsrInst,
        position=-1)

    # Create new thread object.
    cdbLoader.thread = QThread()
    # Instantiate worker object for the operation.
    cdbLoader.worker = DropUsrSchemaWorker(cdbLoader)
    # Move worker object to the be executed on the new thread.
    cdbLoader.worker.moveToThread(cdbLoader.thread)

    #-SIGNALS--(start)#########################################################

    # Execute worker's 'run' method.
    cdbLoader.thread.started.connect(cdbLoader.worker.drop_thread)

    # Capture progress to show in bar.
    cdbLoader.worker.sig_progress.connect(cdbLoader.evt_update_bar)

    # Get rid of worker and thread objects.
    cdbLoader.worker.sig_finished.connect(cdbLoader.thread.quit)
    cdbLoader.worker.sig_finished.connect(cdbLoader.worker.deleteLater)
    cdbLoader.thread.finished.connect(cdbLoader.thread.deleteLater)

    # On installation status
    cdbLoader.worker.sig_success.connect(lambda: ev_drop_success(cdbLoader))
    cdbLoader.worker.sig_fail.connect(lambda: ev_drop_fail(cdbLoader))

    #-SIGNALS--(end)############################################################


    # Initiate worker thread
    cdbLoader.thread.start()

#--EVENTS  (start)  ##############################################################

def ev_install_success(cdbLoader: CDBLoader, pkg: str) -> None:
    """Event that is called when the thread executing the installation
    finishes successfully.

    Shows success message at cdbLoader.usr_dlg.msg_bar: QgsMessageBar
    Shows success message in Connection Status groupbox
    Shows success message in QgsMessageLog
    """

    # Remove progress bar
    cdbLoader.admin_dlg.msg_bar.clearWidgets()

    if sql.is_qgis_pkg_intalled(cdbLoader):
        # Replace with Success msg.
        msg = cdbLoader.admin_dlg.msg_bar.createMessage(c.INST_SUCC_MSG.format(pkg=pkg))
        cdbLoader.admin_dlg.msg_bar.pushWidget(msg, Qgis.Success, 5)

        # Inform user
        cdbLoader.admin_dlg.lblMainInst_out.setText(c.success_html.format(text=c.INST_MSG.format(pkg=pkg)))
        QgsMessageLog.logMessage(
                message=c.INST_SUCC_MSG.format(pkg=pkg),
                tag=cdbLoader.PLUGIN_NAME,
                level=Qgis.Success,
                notifyUser=True)
        cdbLoader.admin_dlg.btnMainUninst.setDisabled(False)

        # Get users from database.
        users = sql.fetch_list_qgis_pkg_usrgroup_members(cdbLoader)
        wf.fill_users_box(cdbLoader,users)
    else:
        ev_install_fail(cdbLoader, pkg)

def ev_install_fail(cdbLoader: CDBLoader, pkg: str) -> None:
    """Event that is called when the thread executing the installation
    emits a fail signal meaning that something went wrong with installation.

    It prompt the user to clear the installation before trying again.
    .. Not sure if this is necessary as in every installation the package
    .. is dropped to replace it with a new one.

    Shows fail message at cdbLoader.usr_dlg.msg_bar: QgsMessageBar
    Shows fail message in Connection Status groupbox
    Shows fail message in QgsMessageLog
    """

    # Remove progress bar
    cdbLoader.admin_dlg.msg_bar.clearWidgets()

    # Replace with Failure msg.
    msg = cdbLoader.admin_dlg.msg_bar.createMessage(c.INST_ERROR_MSG.format(pkg=pkg))
    cdbLoader.admin_dlg.msg_bar.pushWidget(msg, Qgis.Critical, 5)

    # Inform user
    cdbLoader.admin_dlg.lblMainInst_out.setText(c.failure_html.format(text=c.INST_FAIL_MSG.format(pkg=pkg)))
    QgsMessageLog.logMessage(
            message=c.INST_ERROR_MSG.format(pkg=pkg),
            tag=cdbLoader.PLUGIN_NAME,
            level=Qgis.Critical,
            notifyUser=True)

    # Drop corrupted installation.
    sql.exec_drop_db_schema(cdbLoader, schema=cdbLoader.QGIS_PKG_SCHEMA, close_connection=False)
    cdbLoader.admin_dlg.btnMainUninst.setDisabled(True)

def ev_uninstall_success(cdbLoader: CDBLoader) -> None:
    """Event that is called when the thread executing the uninstallation
    finishes successfully.

    Shows success message at cdbLoader.usr_dlg.msg_bar: QgsMessageBar
    Shows success message in Connection Status groupbox
    Shows success message in QgsMessageLog
    """

    # Remove progress bar
    cdbLoader.admin_dlg.msg_bar.clearWidgets()

    qgis_pkg_schema = cdbLoader.QGIS_PKG_SCHEMA

    if not sql.is_qgis_pkg_intalled(cdbLoader):
        # Replace with Success msg.
        msg = cdbLoader.admin_dlg.msg_bar.createMessage(c.UNINST_SUCC_MSG.format(pkg=qgis_pkg_schema))
        cdbLoader.admin_dlg.msg_bar.pushWidget(msg, Qgis.Success, 5)

        # Inform user
        cdbLoader.admin_dlg.lblMainInst_out.setText(c.crit_warning_html.format(text=c.INST_FAIL_MSG.format(pkg=qgis_pkg_schema)))
        QgsMessageLog.logMessage(
                message=c.UNINST_SUCC_MSG.format(pkg=qgis_pkg_schema),
                tag=cdbLoader.PLUGIN_NAME,
                level=Qgis.Success,
                notifyUser=True)
 
        cdbLoader.admin_dlg.btnMainUninst.setDisabled(True)
        cdbLoader.admin_dlg.lblUserInst_out.clear()
        wf.gbxUserInst_reset(cdbLoader)
    else:
        ev_uninstall_fail(cdbLoader, qgis_pkg_schema)

def ev_uninstall_fail(cdbLoader: CDBLoader, error='error') -> None:
    """Event that is called when the thread executing the uninstallation
    emits a fail signal meaning that something went wrong with uninstallation.

    Shows fail message at cdbLoader.usr_dlg.msg_bar: QgsMessageBar
    Shows fail message in Connection Status groupbox
    Shows fail message in QgsMessageLog
    """

    # Remove progress bar
    cdbLoader.admin_dlg.msg_bar.clearWidgets()

    # Replace with Failure msg.
    msg = cdbLoader.admin_dlg.msg_bar.createMessage(error)
    cdbLoader.admin_dlg.msg_bar.pushWidget(msg, Qgis.Critical, 5)

    # Inform user
    cdbLoader.admin_dlg.lblMainInst_out.setText(error)
    QgsMessageLog.logMessage(
            message=error,
            tag=cdbLoader.PLUGIN_NAME,
            level=Qgis.Critical,
            notifyUser=True)

def ev_drop_success(cdbLoader: CDBLoader) -> None:
    """Event that is called when the thread executing the uninstallation
    finishes successfully.

    Shows success message at cdbLoader.admin_dlg.msg_bar: QgsMessageBar
    Shows success message in Connection Status groupbox
    Shows success message in QgsMessageLog
    """

    # Remove progress bar
    cdbLoader.admin_dlg.msg_bar.clearWidgets()

    usr_schema = cdbLoader.USR_SCHEMA

    if not sql.is_usr_pkg_installed(cdbLoader):
        # Replace with Success msg.
        msg = cdbLoader.admin_dlg.msg_bar.createMessage(c.UNINST_SUCC_MSG.format(pkg=usr_schema))
        cdbLoader.admin_dlg.msg_bar.pushWidget(msg, Qgis.Success, 5)

        # Inform user
        cdbLoader.admin_dlg.lblUserInst_out.setText(c.crit_warning_html.format(text=c.INST_FAIL_MSG.format(pkg=usr_schema)))
        QgsMessageLog.logMessage(
                message=c.UNINST_SUCC_MSG.format(pkg=usr_schema),
                tag=cdbLoader.PLUGIN_NAME,
                level=Qgis.Success,
                notifyUser=True)
        cdbLoader.admin_dlg.btnUsrUninst.setDisabled(True)
    else:
        ev_drop_fail(cdbLoader, usr_schema)

def ev_drop_fail(cdbLoader: CDBLoader, error='error') -> None:
    """Event that is called when the thread executing the uninstallation
    emits a fail signal meaning that something went wrong with uninstallation.


    Shows fail message at cdbLoader.admin_dlg.msg_bar: QgsMessageBar
    Shows fail message in Connection Status groupbox
    Shows fail message in QgsMessageLog
    """

    # Remove progress bar
    cdbLoader.admin_dlg.msg_bar.clearWidgets()

    # Replace with Failure msg.
    msg = cdbLoader.admin_dlg.msg_bar.createMessage(error)
    cdbLoader.admin_dlg.msg_bar.pushWidget(msg, Qgis.Critical, 5)

    # Inform user
    cdbLoader.admin_dlg.lblUserInst_out.setText(error)
    QgsMessageLog.logMessage(
            message=error,
            tag=cdbLoader.PLUGIN_NAME,
            level=Qgis.Critical,
            notifyUser=True)
    cdbLoader.admin_dlg.btnUsrUninst.setDisabled(False)

#--EVENTS  (end) ################################################################


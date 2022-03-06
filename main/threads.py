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
from qgis.PyQt.QtWidgets import QProgressBar, QBoxLayout
from qgis.core import Qgis, QgsMessageLog
from qgis.gui import QgsMessageBar
import psycopg2

from .connection import connect
from . import constants as c
from . import sql


class RefreshMatViewsWorker(QObject):
    """Class to assign Worker that executes the 'refresh_mview'
    function from qgis_pkg in the server, into an additional thread."""

    # Create custom signals.
    finished = pyqtSignal()
    progress = pyqtSignal(int,str)
    fail = pyqtSignal()

    def __init__(self,dbLoader):
        super().__init__()
        self.plg = dbLoader


    def refresh_all_mat_views(self):
        """Execution method that refreshes the materialized views in the
        server (for a specific schema).
        """

        # Get feature types from layer_metadata table.
        cols_to_featch = ",".join(["feature_type","mv_name"])
        col,ftype_mview = sql.fetch_layer_metadata(self.plg,cols=cols_to_featch)
        col = None # Discard byproduct.

        # Set progress bar goal
        self.plg.dlg.bar.setMaximum(len(ftype_mview))

        # Open new temp session, reserved for mat refresh.
        with connect(db=self.plg.DB, app_name=f"{connect.__defaults__[0]} (Rrefresh)") as conn:
            for s, (ftype, mview) in enumerate(ftype_mview):

                # Update progress bar with current step and text.
                text = " ".join(["Refreshing materialized views of:",ftype])
                self.progress.emit(s,text)
                print(s,ftype,mview)
                try:
                    with conn.cursor() as cur:
                        cur.callproc(f"{c.PLUGIN_PKG_NAME}.refresh_mview",[None,mview])
                    conn.commit()

                    # time.sleep(0.05) # Use this for debuging instead of waiting for mats.

                except (Exception, psycopg2.DatabaseError) as error:
                    print("At 'refresh_all_mat_views' in threads.py: ",error)
                    conn.rollback()
                    self.fail.emit()


        self.finished.emit()

def refresh_views_thread(dbLoader) -> None:
    """Function that refreshes the materilised views in the database
    by braching a new Worker thread to execute the operation on.
    """

    # Add a new progress bar to follow the installation procedure.
    create_progress_bar(dbLoader,
        layout=dbLoader.dlg.verticalLayout_SettingsTab,
        position=2)

    # Create new thread object.
    dbLoader.thread = QThread()
    # Instantiate worker object for the operation.
    dbLoader.worker = RefreshMatViewsWorker(dbLoader)
    # Move worker object to the be executed on the new thread.
    dbLoader.worker.moveToThread(dbLoader.thread)

    #----------################################################################
    #-SIGNALS--################################################################
    #-(start)--################################################################

    # Disable widgets to avoid queuing signals.
    dbLoader.thread.started.connect(lambda: dbLoader.dlg.gbxInstall.setDisabled(True))
    dbLoader.thread.started.connect(lambda: dbLoader.dlg.gbxDatabaseSettings.setDisabled(True))
    dbLoader.thread.started.connect(lambda: dbLoader.dlg.tabImport.setDisabled(True))
    dbLoader.thread.started.connect(lambda: dbLoader.dlg.tabConnection.setDisabled(True))

    # Execute worker's 'run' method.
    dbLoader.thread.started.connect(dbLoader.worker.refresh_all_mat_views)

    # Capture progress to show in bar.
    dbLoader.worker.progress.connect(dbLoader.evt_update_bar)

    # Get rid of worker and thread objects.
    dbLoader.worker.finished.connect(dbLoader.thread.quit)
    dbLoader.worker.finished.connect(dbLoader.worker.deleteLater)
    dbLoader.thread.finished.connect(dbLoader.thread.deleteLater)

    # Enable widgets.
    dbLoader.thread.finished.connect(lambda: dbLoader.dlg.gbxInstall.setDisabled(False))
    dbLoader.thread.started.connect(lambda: dbLoader.dlg.gbxDatabaseSettings.setDisabled(False))
    dbLoader.thread.finished.connect(lambda: dbLoader.dlg.tabImport.setDisabled(False))
    dbLoader.thread.finished.connect(lambda: dbLoader.dlg.tabConnection.setDisabled(False))

    dbLoader.worker.finished.connect(lambda: refresh_success(dbLoader))

    #----------################################################################
    #-SIGNALS--################################################################
    #-(end)--##################################################################

    # Initiate worker thread
    dbLoader.thread.start()


class PkgInstallationWorker(QObject):
    """Class to assign Worker that executes the 'installation scripts'
    to install the plugin package (qgis_pkg) in the database."""

    # Create custom signals.
    finished = pyqtSignal()
    progress = pyqtSignal(int,str)
    success = pyqtSignal()
    fail = pyqtSignal()

    def __init__(self,dbLoader,path):
        super().__init__()
        self.plg = dbLoader
        self.path=path

    def install_thread(self):
        """Execution method that installs the plugin package for
        support of the default schema. Sql scripts are installed
        directly using the execution method. No psql app needed.
        """
        # Flag to help us break from a failing installation.
        fail_flag = False

        # Get an alphabetocal ordered list of the script names.
        # Important: Keep the order with number prefixes.
        install_scripts = sorted(os.listdir(self.path))

        # Set progress bar goal
        self.plg.dlg.bar.setMaximum(len(install_scripts))

        # Open new temp session, reserved for installation.
        with connect(db=self.plg.DB,app_name=f"{connect.__defaults__[0]} (Installation)") as conn:
            for s,script in enumerate(install_scripts,start=1):

                # Update progress bar with current step and script.
                text = " ".join(["Installing:",script])
                self.progress.emit(s,text)
                try:
                    # Attempt direct sql injection.
                    with conn.cursor() as cursor:
                        with open(os.path.join(self.path,script),"r") as sql_script:
                            cursor.execute(sql_script.read())
                    conn.commit()


                except (Exception, psycopg2.DatabaseError) as error:
                    print("At 'install_dbSettings_thread' in threads.py: ",script,error)
                    fail_flag = True
                    conn.rollback()
                    self.fail.emit()
                    break

        # No FAIL = SUCCESS
        if not fail_flag:
            self.success.emit()
        self.finished.emit()

def install_pkg_thread(dbLoader, path: str) -> None:
    """Function that installs the plugin package (qgis_pkg) in the database
    by braching a new Worker thread to execute the operation on.

    *   :param path: The absolute path to the directory storing the
            sql installation scripts (e.g. ./citydb_loader/qgis_pkg/postgresql)

        :type path: str
    """

    # Add a new progress bar to follow the installation procedure.
    create_progress_bar(dbLoader,
        layout=dbLoader.dlg.verticalLayout_ConnectionTab,
        position=3)

    # Create new thread object.
    dbLoader.thread = QThread()
    # Instantiate worker object for the operation.
    dbLoader.worker = PkgInstallationWorker(dbLoader,path)
    # Move worker object to the be executed on the new thread.
    dbLoader.worker.moveToThread(dbLoader.thread)

    #----------################################################################
    #-SIGNALS--################################################################
    #-(start)--################################################################

    # Execute worker's 'run' method.
    dbLoader.thread.started.connect(dbLoader.worker.install_thread)

    # Capture progress to show in bar.
    dbLoader.worker.progress.connect(dbLoader.evt_update_bar)

    # Get rid of worker and thread objects.
    dbLoader.worker.finished.connect(dbLoader.thread.quit)
    dbLoader.worker.finished.connect(dbLoader.worker.deleteLater)
    dbLoader.thread.finished.connect(dbLoader.thread.deleteLater)

    # On installation status
    dbLoader.worker.success.connect(lambda: install_success(dbLoader))
    dbLoader.worker.fail.connect(lambda: install_fail(dbLoader))

    #----------################################################################
    #-SIGNALS--################################################################
    #--(end)---################################################################

    # Initiate worker thread
    dbLoader.thread.start()

#----------################################################################
#--EVENTS--################################################################
#-(start)--################################################################

def refresh_success(dbLoader) -> None:
    """Event that is called when the thread executing the refresh
    finishes successfuly.

    Shows success message at dbLoader.dlg.msg_bar: QgsMessageBar
    Shows success message in Connection Status groupbox
    Shows success message in QgsMessageLog
    """

    # Remove progress bar
    dbLoader.dlg.msg_bar.clearWidgets()

    # Replace with Success msg.
    msg= dbLoader.dlg.msg_bar.createMessage("Materialized views have been refreshed successfully!")
    dbLoader.dlg.msg_bar.pushWidget(msg, Qgis.Success, 5)

    # Inform user
    dbLoader.dlg.lblInstall_out.setText(c.success_html.format(text="Materialized views have been refreshed successfully!"))
    QgsMessageLog.logMessage(message="Materialized views have been refreshed successfully!",
            tag="3DCityDB-Loader",
            level=Qgis.Success,
            notifyUser=True)

def install_success(dbLoader) -> None:
    """Event that is called when the thread executing the installation
    finishes successfuly.

    Shows success message at dbLoader.dlg.msg_bar: QgsMessageBar
    Shows success message in Connection Status groupbox
    Shows success message in QgsMessageLog
    """

    # Enable 'User Types'
    dbLoader.dlg.gbxUserType.setDisabled(False)

    # Make instllation success known to connection object.
    dbLoader.DB.green_installation = True

    # Remove progress bar
    dbLoader.dlg.msg_bar.clearWidgets()

    # Replace with Success msg.
    msg= dbLoader.dlg.msg_bar.createMessage("'qgis_pkg' has been installed successfully!")
    dbLoader.dlg.msg_bar.pushWidget(msg, Qgis.Success, 5)

    # Inform user
    dbLoader.dlg.lblInstall_out.setText(c.success_html.format(text="qgis_pkg is already installed!"))
    QgsMessageLog.logMessage(message="'qgis_pkg' has been installed successfully!",
            tag="3DCityDB-Loader",
            level=Qgis.Success,
            notifyUser=True)

def install_fail(dbLoader) -> None:
    """Event that is called when the thread executing the installation
    emits a fail signal meaning that something went wront with installation.

    It prompt the user to clear the installation before trying again.
    .. Not sure if this is necessary as in every installation the package
    .. is dropped to replace it with a new one.

    Shows fail message at dbLoader.dlg.msg_bar: QgsMessageBar
    Shows fail message in Connection Status groupbox
    Shows fail message in QgsMessageLog
    """

    dbLoader.DB.green_installation=False
    dbLoader.dlg.btnClearDB.setDisabled(False)
    dbLoader.dlg.btnClearDB.setText("Clear corrupted installation!")

    # Remove progress bar
    dbLoader.dlg.msg_bar.clearWidgets()

    # Replace with Failure msg.
    msg= dbLoader.dlg.msg_bar.createMessage("'qgis_pkg' installation failed!")
    dbLoader.dlg.msg_bar.pushWidget(msg, Qgis.Critical, 5)

    # Inform user
    dbLoader.dlg.lblInstall_out.setText(c.failure_html.format(text="'qgis_pkg' installation failed!"))
    QgsMessageLog.logMessage(message="qgis_pkg installation failed!",
            tag="3DCityDB-Loader",
            level=Qgis.Critical,
            notifyUser=True)

    # Drop corrupted installation.
    sql.drop_package(dbLoader,close_connection=False)

#----------################################################################
#--EVENTS--################################################################
#--(end)---################################################################

def create_progress_bar(dbLoader, layout: QBoxLayout, position: int) -> None:
    """Function that creates a QProgressBar embedded into
    a QgsMessageBar, in a specific position in the gui.

    *   :param layout: QLayout of the gui where the bar is to be
            assigned.

        :type layout: QBoxLayout

    *   :param position: The place (index) in the layout to place
            the progress bar

        :type position: int

    """

    dialog = dbLoader.dlg

    # Create QgsMessageBar instance.
    dialog.msg_bar = QgsMessageBar()

    # Add the message bar into the input layer and position.
    layout.insertWidget(position,dialog.msg_bar)

    # Create QProgressBar instance into QgsMessageBar.
    dialog.bar = QProgressBar(parent=dialog.msg_bar)

    # Setup progress bar.
    dialog.bar.setAlignment(Qt.AlignLeft|Qt.AlignVCenter)
    dialog.bar.setStyleSheet("text-align: left;")

    # Show progress bar in message bar.
    dialog.msg_bar.pushWidget(dialog.bar, Qgis.Info)

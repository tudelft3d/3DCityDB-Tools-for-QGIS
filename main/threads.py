"""This module contains operations that relate to time consuming
processes like installation or mainly refresh views.

The purpose of this module is to hint the user that a heavy process is
running in the background, so that they don't think that the plugin crashed,
or froze.

The plugin runs on single thread, meaning that in such processes the plugin
'freezes' until completion. But without warning or visual cue the user could
think that it broke.

To avoid this module provides two visuals cues.
1. Loading animation
2. Disabling the entire plugin (gray-out to ignore signals from panic clicking)

This is done by assigning a working thread for the
heavy process. In the main thread the loading animation is assigned to
play as long as the heavy process takes place in the worker thread.
"""


import time
import subprocess

from qgis.PyQt.QtCore import QObject,QThread,pyqtSignal
from qgis.PyQt.QtWidgets import QLabel
from qgis.core import Qgis, QgsMessageLog
import psycopg2

from . import constants as c


class RefreshMatViewsWorker(QObject):
    """Class to assign Worker that executes the 'refresh_mview'
    function from qgis_pkg in the server, into an additional thread."""

    # Create custom signals.
    finished = pyqtSignal()
    fail = pyqtSignal()

    def __init__(self,dbLoader):
        super().__init__()
        self.plg = dbLoader
        self.conn = dbLoader.conn


    def refresh_all_mat_views(self):
        """Execution method that refreshes the materlised views in the
        server (for a specific schema).
        """
        try:
            with self.conn.cursor() as cur:
                cur.callproc("qgis_pkg.refresh_mview",[self.plg.SCHEMA])
            self.conn.commit()

            #time.sleep(10) # Use this for debugin instead waiting for mats.

        except (Exception, psycopg2.DatabaseError) as error:
            print("At 'refresh_all_mat_views' in threads.py: ",error)
            self.conn.rollback()
            self.fail.emit()
        self.finished.emit()

def refresh_views_thread(dbLoader) -> None:
    """Function that refreshes the materilised view in the database
    by braching a new Worker thread to execute the operation on.
    """

    # Create new thread object.
    dbLoader.thread = QThread()
    # Instantiate worker object for the operation.
    dbLoader.worker = RefreshMatViewsWorker(dbLoader)
    # Move worker object to the be executed on the new thread.
    dbLoader.worker.moveToThread(dbLoader.thread)

    #----------################################################################
    #-SIGNALS--################################################################
    #-(start)--################################################################

    # Disable plugin to ignore signals from panic clicking.
    dbLoader.thread.started.connect(lambda: dbLoader.dlg.wdgMain.setDisabled(True))

    # Initiate loading animations.
    dbLoader.thread.started.connect(lambda:start_LoadingAnimation(dbLoader,label=dbLoader.dlg.lblLoadingRefresh))
    dbLoader.thread.started.connect(lambda:start_LoadingAnimation(dbLoader,label=dbLoader.dlg.lblInstallLoadingCon))

    # Execute worker's 'run' method.
    dbLoader.thread.started.connect(dbLoader.worker.refresh_all_mat_views)

    # Get rid of worker and thread objects.
    dbLoader.worker.finished.connect(dbLoader.thread.quit)
    dbLoader.worker.finished.connect(dbLoader.worker.deleteLater)
    dbLoader.thread.finished.connect(dbLoader.thread.deleteLater)

    # Stop loading animations.
    dbLoader.thread.finished.connect(lambda: stop_LoadingAnimation(dbLoader,label=dbLoader.dlg.lblLoadingRefresh))
    dbLoader.thread.finished.connect(lambda: stop_LoadingAnimation(dbLoader,label=dbLoader.dlg.lblInstallLoadingCon))
    # Enable again the plugin
    dbLoader.thread.finished.connect(lambda: dbLoader.dlg.wdgMain.setDisabled(False))
    # Move focus to the 'Import' tab.
    dbLoader.thread.finished.connect(lambda: dbLoader.dlg.wdgMain.setCurrentIndex(1))

    #----------################################################################
    #-SIGNALS--################################################################
    #-(end)--################################################################

    # Initiate worker thread
    dbLoader.thread.start()


class PkgInstallationWorker(QObject):
    """Class to assign Worker that executes the 'installation script'
    to install the plugin package (qgis_pkg) in the database"""

    # Create custom signals.
    finished = pyqtSignal()
    fail = pyqtSignal()

    def __init__(self,path,password):
        super().__init__()
        self.path=path
        self.password=password

    def install_thread(self):
        """Execution method that installs the plugin package for
        support of the default schema.
        """

        try:
            p = subprocess.Popen(self.path, stdin = subprocess.PIPE,
                                        stdout=subprocess.PIPE,
                                        stderr=subprocess.PIPE,
                                        universal_newlines=True)
            output,e = p.communicate(f'{self.password}\n')

        except (Exception, psycopg2.DatabaseError) as error:
            print("At 'install_dbSettings_thread' in threads.py: ",error)
            self.fail.emit()

        self.finished.emit()

# NOTE: if installing qgis_pkg doesn't refreash automatically the views,
# then the operation is fast enough to not need to run on a separate thread.
def install_pkg_thread(dbLoader, path: str, password:str) -> None:
    """Function that installs the plugin package (qgis_pkg) in the database
    by braching a new Worker thread to execute the operation on.
    """

    # Create new thread object.
    dbLoader.thread = QThread()
    # Instantiate worker object for the operation.
    dbLoader.worker = PkgInstallationWorker(path,password)
    # Move worker object to the be executed on the new thread.
    dbLoader.worker.moveToThread(dbLoader.thread)

    #----------################################################################
    #-SIGNALS--################################################################
    #-(start)--################################################################

    # Disable plugin to ignore signals from panic clicking.
    dbLoader.thread.started.connect(lambda: dbLoader.dlg.wdgMain.setDisabled(True))

    # Initiate loading animations.
    dbLoader.thread.started.connect(lambda:start_LoadingAnimation(dbLoader,label=dbLoader.dlg.lblLoadingInstall))
    dbLoader.thread.started.connect(lambda:start_LoadingAnimation(dbLoader,label=dbLoader.dlg.lblInstallLoadingCon))

    # Execute worker's 'run' method.
    dbLoader.thread.started.connect(dbLoader.worker.install_thread)

    # Stop loading animations.
    dbLoader.thread.finished.connect(lambda: stop_LoadingAnimation(dbLoader,label=dbLoader.dlg.lblLoadingInstall))
    dbLoader.thread.finished.connect(lambda: stop_LoadingAnimation(dbLoader,label=dbLoader.dlg.lblInstallLoadingCon))

    # Get rid of worker and thread objects.
    dbLoader.worker.finished.connect(dbLoader.thread.quit)
    dbLoader.worker.finished.connect(dbLoader.worker.deleteLater)
    dbLoader.thread.finished.connect(dbLoader.thread.deleteLater)

    # Enable again the plugin
    dbLoader.thread.finished.connect(lambda: dbLoader.dlg.wdgMain.setDisabled(False))

    # On installation status
    dbLoader.thread.finished.connect(lambda: install_success(dbLoader))
    dbLoader.worker.fail.connect(lambda: install_fail(dbLoader))


    #----------################################################################
    #-SIGNALS--################################################################
    #--(end)---################################################################

    # Initiate worker thread
    dbLoader.thread.start()

#----------################################################################
#--EVENTS--################################################################
#-(start)--################################################################

def install_success(dbLoader) -> None:
    """Event that is called when the thread executing the installation
    finishes successfuly.
    """

    # Enable 'User Types'
    dbLoader.dlg.gbxUserType.setDisabled(False)

    # Inform user
    dbLoader.dlg.lblInstall_out.setText(c.success_html.format(text='qgis_pkg is already installed!'))
    QgsMessageLog.logMessage(message="qgis_pkg has been installed successfully!",
            tag="3DCityDB-Loader",
            level=Qgis.Success,
            notifyUser=True)

    # Make instllation success known to connection object.
    dbLoader.DB.green_installation = True

def install_fail(dbLoader) -> None:
    """Event that is called when the thread executing the installation
    emits a fail signal meaning that something went wront with installation.

    It prompt the user to clear the installation before trying again.
    .. Not sure if this is necessary as in every installation the package
    .. is dropped to replace it with a new one.
    """
    dbLoader.DB.green_installation=False
    dbLoader.dlg.btnClearDB.setDisabled(False)
    dbLoader.dlg.btnClearDB.setText("Clear corrupted installation!")

    # Inform user
    dbLoader.dlg.lblInstall_out.setText(c.failure_html.format(text="qgis_pkg installation failed!"))
    QgsMessageLog.logMessage(message="qgis_pkg installation failed!",
            tag="3DCityDB-Loader",
            level=Qgis.Critical,
            notifyUser=True)

    # Move focus to 'Setting' tab.
    dbLoader.dlg.wdgMain.setCurrentIndex(2)

def start_LoadingAnimation(dbLoader,label: QLabel) -> None:
    """Function that starts playing the loading gif
    in the input label.

    *   :param label: label QT object where the animation is displayed.

        :type label: QLabel
    """

    label.setMovie(dbLoader.dlg.movie)
    # Reveal hidden label to play the animation on.
    label.setHidden(False)
    dbLoader.dlg.movie.start()

def stop_LoadingAnimation(dbLoader,label: QLabel):
    """Function that stops playing the loading gif
    in the input label. Make sure this function follows
    function 'start_LoadingAnimation' or that a movie is
    already playing in the input label.

    *   :param label: label QT object where the animation is playing.

        :type label: QLabel
    """

    dbLoader.dlg.movie.stop()
    # Hide label widget.
    label.setHidden(True)

#----------################################################################
#--EVENTS--################################################################
#--(end)---################################################################

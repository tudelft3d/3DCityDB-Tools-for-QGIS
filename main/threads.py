"""This module contains operations that relate to the time consuming 
processes like installation or mainly refresh views.

The purpose of this module is to hint the user that a heavy process is 
running in the background, so that they don't think that the plugin crashed,
or froze.

The plugin runs on single thread, meaning that in such processes the plugin 
'freezes' until completion. But without warning or visual cue the user could
think that it broke. 

To avoid this module provied two visuals cues.
1. Loading animation
2. Disabling the entire plugin (gray-out) 

This is done by assigning a working thread for the 
heavy process. In the main thread the loading animation is assigned to 
play as long as the heavy process takes place in the worker thread.
"""

import psycopg2
from qgis.PyQt.QtCore import QObject,QThread,pyqtSignal
from qgis.core import Qgis
from .constants import *
import time,subprocess

#TODO: catch errors in Workers to display 

class RefreshMatViewsWorker(QObject):
    finished = pyqtSignal()
    fail = pyqtSignal()
    def __init__(self,dbLoader):
        super().__init__()
        self.conn = dbLoader.conn

    def refresh_all_mat_views(self):
        """Long-running task."""
        try:
            with self.conn.cursor() as cur:
                cur.callproc("qgis_pkg.refresh_mview")
            self.conn.commit()

            #time.sleep(10) # Use this for debugin instead

        except (Exception, psycopg2.DatabaseError) as error:
            print("At 'refresh_all_mat_views' in threads.py: ",error)
            self.fail.emit()
        self.finished.emit()

def refresh_views_thread(dbLoader):
    dbLoader.thread = QThread()
    dbLoader.worker = RefreshMatViewsWorker(dbLoader)
    dbLoader.worker.moveToThread(dbLoader.thread)

    dbLoader.thread.started.connect(lambda: dbLoader.dlg.wdgMain.setDisabled(True))
    dbLoader.thread.started.connect(lambda:start_LoadingAnimation(dbLoader,label=dbLoader.dlg.lblLoadingRefresh))
    dbLoader.thread.started.connect(lambda:start_LoadingAnimation(dbLoader,label=dbLoader.dlg.lblInstallLoadingCon))
    dbLoader.thread.started.connect(dbLoader.worker.refresh_all_mat_views)

    dbLoader.worker.finished.connect(dbLoader.thread.quit)
    dbLoader.worker.finished.connect(dbLoader.worker.deleteLater)
    dbLoader.thread.finished.connect(dbLoader.thread.deleteLater)
    
    #dbLoader.thread.finished.connect(lambda: succ(dbLoader))
    dbLoader.thread.finished.connect(lambda: stop_LoadingAnimation(dbLoader,label=dbLoader.dlg.lblLoadingRefresh))
    dbLoader.thread.finished.connect(lambda: stop_LoadingAnimation(dbLoader,label=dbLoader.dlg.lblInstallLoadingCon))
    dbLoader.thread.finished.connect(lambda: dbLoader.dlg.wdgMain.setDisabled(False))
    dbLoader.thread.finished.connect(lambda: dbLoader.dlg.wdgMain.setCurrentIndex(1))
    

    dbLoader.thread.start()
    

class PkgInstallationWorker(QObject):
    finished = pyqtSignal()
    fail = pyqtSignal()
    def __init__(self,path,password):
        super().__init__()
        self.path=path
        self.password=password

    def install_dbSettings_thread(self):
        """Long-running task."""

        #time.sleep(3)
        try:
            p = subprocess.Popen(self.path, stdin = subprocess.PIPE,
                                        stdout=subprocess.PIPE ,
                                        stderr=subprocess.PIPE ,
                                        universal_newlines=True)
            output,e = p.communicate(f'{self.password}\n')
        except (Exception, psycopg2.DatabaseError) as error:
            print("At 'install_dbSettings_thread' in threads.py: ",error)
            self.fail.emit()

        self.finished.emit()

def install_pkg_thread(dbLoader,path,password,origin):
    dbLoader.thread = QThread()
    dbLoader.worker = PkgInstallationWorker(path,password)
    dbLoader.worker.moveToThread(dbLoader.thread)

    dbLoader.thread.started.connect(lambda: dbLoader.dlg.wdgMain.setDisabled(True))
    if origin == dbLoader.dlg.lblLoadingInstall:
        dbLoader.thread.started.connect(lambda:start_LoadingAnimation(dbLoader,label=dbLoader.dlg.lblLoadingInstall))
        dbLoader.thread.finished.connect(lambda: stop_LoadingAnimation(dbLoader,label=dbLoader.dlg.lblLoadingInstall))

    elif origin== dbLoader.dlg.lblInstallLoadingCon:
        dbLoader.thread.started.connect(lambda:start_LoadingAnimation(dbLoader,label=dbLoader.dlg.lblInstallLoadingCon))
        dbLoader.thread.finished.connect(lambda: stop_LoadingAnimation(dbLoader,label=dbLoader.dlg.lblInstallLoadingCon))
        
    dbLoader.thread.started.connect(dbLoader.worker.install_dbSettings_thread)

    dbLoader.worker.finished.connect(dbLoader.thread.quit)
    dbLoader.worker.finished.connect(dbLoader.worker.deleteLater)
    dbLoader.thread.finished.connect(dbLoader.thread.deleteLater)
    dbLoader.thread.finished.connect(lambda: dbLoader.dlg.wdgMain.setDisabled(False))
    dbLoader.thread.finished.connect(lambda: install_success(dbLoader))
    dbLoader.worker.fail.connect(lambda: install_fail(dbLoader))

    dbLoader.thread.start()


def install_success(dbLoader):
    dbLoader.dlg.gbxUserType.setDisabled(False)
    dbLoader.dlg.lblInstall_out.setText(success_html.format(text='qgis_pkg is already installed!'))
    dbLoader.dlg.cbxExistingConnection.currentData().has_installation = True
    dbLoader.connection_status['Install']=True
    dbLoader.schemas.append(dbLoader.plugin_package)
    return True
def install_fail(dbLoader):
    dbLoader.connection_status['Install']=False
    dbLoader.dlg.btnClearDB.setDisabled(False)
    dbLoader.dlg.btnClearDB.setText(f'Clear corrupted installation!')  
    dbLoader.dlg.wdgMain.setCurrentIndex(2)


def start_LoadingAnimation(dbLoader,label):
    """ Starts loading gif in a hidden label and optionally disables ovelaying group object"""
    label.setMovie(dbLoader.dlg.movie)
    label.setHidden(False)
    dbLoader.dlg.movie.start()


def stop_LoadingAnimation(dbLoader,label):
    """ Stops loading gif and hides the label. Optionally enables ovelaying group object"""
    dbLoader.dlg.movie.stop()
    label.setHidden(True)


def results(dbLoader):

    # for notice in dbLoader.conn.notices: #NOTE: It may take notices from other procs
    #     QgsMessageLog.logMessage(notice,tag="3DCityDB-Loader",level= Qgis.Info)

    msg = dbLoader.dlg.gbxInstall.bar.createMessage( u'Views have been succesfully updated' )
    dbLoader.dlg.gbxInstall.bar.clearWidgets()
    dbLoader.dlg.gbxInstall.bar.pushWidget(msg, Qgis.Success, duration=4)
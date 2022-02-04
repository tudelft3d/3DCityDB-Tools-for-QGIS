from qgis.PyQt.QtCore import QObject,QThread,pyqtSignal
from qgis.core import Qgis
import time

#TODO: catch errors in Workers to display 

class RefreshMatViewsWorker(QObject):
    finished = pyqtSignal()
    progress = pyqtSignal(int)
    def __init__(self,cursor):
        super().__init__()
        self.cur=cursor

    def refresh_all_mat_views(self):
        """Long-running task."""
        for i in range(5):
            time.sleep(1)

        #self.cur.callproc("qgis_pkg.refresh_materialized_view")
        self.finished.emit()

def refresh_views_thread(dbLoader,cursor):
    dbLoader.thread = QThread()
    dbLoader.worker = RefreshMatViewsWorker(cursor)
    dbLoader.worker.moveToThread(dbLoader.thread)

    dbLoader.thread.started.connect(lambda: dbLoader.dlg.wdgMain.setDisabled(True))
    dbLoader.thread.started.connect(lambda:start_LoadingAnimation(dbLoader,label=dbLoader.dlg.lblLoadingRefresh))
    dbLoader.thread.started.connect(dbLoader.worker.refresh_all_mat_views)

    dbLoader.worker.finished.connect(dbLoader.thread.quit)
    dbLoader.worker.finished.connect(dbLoader.worker.deleteLater)
    dbLoader.thread.finished.connect(dbLoader.thread.deleteLater)
    
    #dbLoader.thread.finished.connect(lambda: succ(dbLoader))
    dbLoader.thread.finished.connect(lambda: stop_LoadingAnimation(dbLoader,label=dbLoader.dlg.lblLoadingRefresh))
    dbLoader.thread.finished.connect(lambda: dbLoader.dlg.wdgMain.setDisabled(False))

    dbLoader.thread.start()

class PkgInstallationWorker(QObject):
    finished = pyqtSignal()
    progress = pyqtSignal(int)
    def __init__(self,path):
        super().__init__()
        self.path=path

    def install_dbSettings_thread(self):
        """Long-running task."""
        for i in range(2):
            time.sleep(1)

        # subprocess.Popen(self.path, stdin = subprocess.PIPE,
        #                             stdout=subprocess.PIPE ,
        #                             stderr=subprocess.PIPE ,
        #                             universal_newlines=True)
        self.finished.emit()

def install_pkg_thread(dbLoader,cursor,origin):
    dbLoader.thread = QThread()
    dbLoader.worker = PkgInstallationWorker(cursor)
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
    #dbLoader.thread.finished.connect(lambda: succ(dbLoader))
    
    dbLoader.thread.start()





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
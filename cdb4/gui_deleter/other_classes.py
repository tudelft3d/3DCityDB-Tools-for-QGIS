import os.path, requests
from qgis.PyQt import QtWidgets, uic
from qgis.core import QgsCoordinateTransform,QgsCoordinateReferenceSystem,QgsProject,QgsPointXY
from .. import cdb4_constants as c
from ..shared.functions import general_functions as gen_f
from ...cdb_loader import CDBLoader
from .functions.sql import fetch_cdb_schema_srid as get_srid
from qgis.PyQt.QtCore import QObject, QThread, pyqtSignal, QRunnable, QThreadPool



FILE_LOCATION = gen_f.get_file_relative_path(__file__)
FORM_CLASS1, _ = uic.loadUiType(os.path.join(os.path.dirname(__file__), "ui", "cdb4_geocoder_dialog.ui"))

class Signals(QObject):
    progress = pyqtSignal(int)
    finished = pyqtSignal()
    enable_canvas = pyqtSignal(bool)

class DeleteWorker(QObject):
    signals = Signals()

    def __init__(self, cdbLoader: CDBLoader):
        super().__init__()
        self.plugin = cdbLoader

    def delete_features(self):
        with self.plugin.conn.cursor() as cur:
            for i,idx in enumerate(self.plugin.fids):
                cur.execute(f'''SELECT {self.plugin.CDB_SCHEMA}.del_cityobject({idx})''')
                self.signals.progress.emit(i)
        self.plugin.conn.commit()
        self.signals.finished.emit()
        self.signals.enable_canvas.emit(True)

    def cleanup(self):
        with self.plugin.conn.cursor() as cur:
            delete_query = f"""SELECT {self.plugin.CDB_SCHEMA}.cleanup_schema()"""
            cur.execute(delete_query)
        self.plugin.conn.commit()


FORM_CLASS2, _ = uic.loadUiType(os.path.join(os.path.dirname(__file__), "ui", "cdb4_geo_dialog.ui"))
class CDBGeoDialog(QtWidgets.QDialog, FORM_CLASS2):

    def __init__(self, cdbLoader: CDBLoader, parent=None):
        super(CDBGeoDialog, self).__init__(parent)
        from queue import Queue
        self.setupUi(self)
        self.lineEditPlaceName.setPlaceholderText('Enter place name eg. Delft,Netherlands')
        self.btnGeocode.clicked.connect(lambda: self.evt_btnGeocode_clicked(cdbLoader))
        self.btnOk.clicked.connect(lambda: self.evt_btnOK_clicked(cdbLoader))
        self.queue = Queue()

    def evt_btnGeocode_clicked(self, cdbLoader: CDBLoader):

        dlg = cdbLoader.deleter_dlg
        url = 'https://nominatim.openstreetmap.org/search?q='
        url = ''.join([url, self.lineEditPlaceName.text(), '&limit=50&format=json'])
        nominatim = None
        try:
            nominatim = requests.get(url).json()
        except:
            res = QtWidgets.QMessageBox.information(dlg, "Geocode Unsuccessful",
                                                    "Please check your internet connection.")
            if res == 1024:
                return
        self.transformer = QgsCoordinateTransform(QgsCoordinateReferenceSystem('EPSG:4326'),
                                             QgsCoordinateReferenceSystem(f'EPSG:{get_srid(cdbLoader)}'),
                                             QgsProject.instance())
        if len(nominatim):
            not_in_bbox = True
            matches = 0
            match_idx = []
            for idx,place in enumerate(nominatim):
                if not_in_bbox:
                    wgs_location = [float(place[key]) for key in place if key in ['lat', 'lon']]
                    point = QgsPointXY(wgs_location[1], wgs_location[0])

                    point = self.transformer.transform(point)
                    if dlg.CDB_SCHEMA_EXTENTS_BLUE.contains(point):
                        if len(nominatim) == 1:
                            dlg.CANVAS_C.zoomByFactor(scaleFactor=0.5, center=point)
                            self.close()
                            return
                        else:
                            self.cbxGeocodeMatches.addItem(place['display_name'])
                            match_idx.append(idx)
                            matches += 1
            if matches == 0:
                res = QtWidgets.QMessageBox.information(dlg, "Geocode Unsuccessful",
                                                        f"Place outside {cdbLoader.CDB_SCHEMA} extent, please refine your place name.")
                if res == 1024:
                    return
            else:
                self.stackedWidget.setCurrentIndex(1)
                self.queue.put(match_idx)
                self.queue.put(nominatim)
        else:
            res = QtWidgets.QMessageBox.information(dlg, "Geocode Unsuccessful",
                                                    "0 matches found. Please refine your place name")
            if res == 1024:
                return

    def evt_btnOK_clicked(self,cdbLoader):

        dlg = cdbLoader.deleter_dlg
        match_idx = self.queue.get()
        nominatim = self.queue.get()
        for idx in match_idx:
            if nominatim[idx]['display_name'] == self.cbxGeocodeMatches.currentText():
                wgs_location = [float(nominatim[idx][key]) for key in nominatim[idx] if key in ['lat', 'lon']]
                point = QgsPointXY(wgs_location[1], wgs_location[0])
                point = self.transformer.transform(point)
                dlg.CANVAS_C.zoomByFactor(scaleFactor=0.5, center=point)
                self.close()
                break








class DeleterDialogRequirements:
    def __init__(self):
        self.is_conn_successful: bool = False
        self.is_postgis_installed: bool = False
        self.is_3dcitydb_installed: bool = False
        self.is_qgis_pkg_installed: bool = False
        self.is_usr_pkg_installed: bool = False
        self.layers_exist: bool = False
        self.layers_refreshed: bool = False

    def __str__(self):
        return_str: str = \
            f"Is the connection to the database established? {self.is_conn_successful}\n" + \
            f"Is PostGIS installed? {self.is_postgis_installed}\n" + \
            f"Is the 3DCityDB installed? {self.is_3dcitydb_installed}\n" + \
            f"Is the QGIS Package installed? {self.is_qgis_pkg_installed}\n" + \
            f"Is the user schema installed? {self.is_usr_pkg_installed}\n" + \
            f"Have layers been created? {self.layers_exist}\n" + \
            f"Have layers been refreshed? {self.layers_refreshed}\n"
        return return_str


    def are_requirements_fulfilled(self) -> bool:
        """Method that is used to check whether layers can be loaded in the ""Layers' tab"

        *   :returns: The plugin's readiness to finally load layers.
            :rtype: bool
        """
        if all((self.is_conn_successful,
                self.is_postgis_installed,
                self.is_3dcitydb_installed,
                self.is_qgis_pkg_installed,
                self.is_usr_pkg_installed,
                self.layers_exist,
                self.layers_refreshed)):
            return True
        return False

    
class DeleterDialogSettings:
    "TODO: these settings will be read from a setting.ini file stored in the QGIS plugin directory"

    def __init__(self):
        pass

    def __str__(self):
        return_str: str = None

        return return_str


'''
class DelWorker(QRunnable):

    def __init__(self,cdbLoader,q):
        super().__init__()
        self.plugin = cdbLoader
        self.queue = q
        self.count = 0
        self.signal = Signals()

    def run(self):
        while True:
            try:
                with self.plugin.conn.cursor() as cur:
                    cur.execute(fSELECT {self.plugin.CDB_SCHEMA}.del_cityobject({self.queue.get()}))
                    self.count += 1
                    b = self.count
                    self.signal.progress.emit(b)
                self.plugin.conn.commit()
            except:
                continue
            else:
                self.queue.task_done()
                self.signal.enable_canvas.emit(False)
'''

'''
class CDBGeocoderDialog(QtWidgets.QDialog, FORM_CLASS1):

    def __init__(self, cdbLoader: CDBLoader, parent=None):
        super(CDBGeocoderDialog, self).__init__(parent)

        self.setupUi(self)
        self.lineEditPlaceName.setPlaceholderText('Enter place name eg. Delft,Netherlands')
        self.btnGeocode.clicked.connect(lambda: self.evt_btnGeocode_clicked(cdbLoader))

    def evt_btnGeocode_clicked(self,cdbLoader: CDBLoader):

        dlg = cdbLoader.deleter_dlg
        url = 'https://nominatim.openstreetmap.org/search?q='
        url = ''.join([url,self.lineEditPlaceName.text(),'&limit=50&format=json'])
        nominatim = None
        try:
            nominatim = requests.get(url).json()
        except:
            res = QtWidgets.QMessageBox.information(dlg, "Geocode Unsuccessful", "Please check your internet connection.")
            if res == 1024:
                return

        if len(nominatim):
            not_in_bbox = True
            matches = 0
            for place in nominatim:
                if not_in_bbox:
                    wgs_location = [float(place[key]) for key in place if key in ['lat','lon']]
                    point = QgsPointXY(wgs_location[1],wgs_location[0])
                    transformer = QgsCoordinateTransform(QgsCoordinateReferenceSystem('EPSG:4326'),
                                                         QgsCoordinateReferenceSystem(f'EPSG:{get_srid(cdbLoader)}'),
                                                         QgsProject.instance())
                    point = transformer.transform(point)
                    if dlg.CDB_SCHEMA_EXTENTS_BLUE.contains(point):
                        #not_in_bbox = False
                        dlg.CANVAS_C.zoomByFactor(scaleFactor=0.5,center=point)
                        matches += 1
            if matches == 0:
                res = QtWidgets.QMessageBox.information(dlg, "Geocode Unsuccessful",f"Place outside {cdbLoader.CDB_SCHEMA} extent, please refine your place name.")
                if res == 1024:
                    return
            else:
                pass
        else:
            res = QtWidgets.QMessageBox.information(dlg, "Geocode Unsuccessful","0 matches found. Please refine your place name")
            if res == 1024:
                return

        self.close()
'''
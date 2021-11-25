
from qgis.PyQt.QtWidgets import *
from qgis.core import Qgis
from .connector_dialog import Ui_dlgConnector




class DlgConnector(QDialog, Ui_dlgConnector):
    def __init__(self):
        super(DlgConnector, self).__init__()
        self.setupUi(self)

        self.btnConnect.clicked.connect(self.evt_btnConnect_clicked)

        


    def evt_btnConnect_clicked(self):
        #TODO: make the connection:
        a = 0
        if a:    
            QMessageBox.information(self,"Connection Established", "Connection to <insert db name here> established successfuly!")
        else:
            QMessageBox.critical(self,"Connection Fail", "Connection to <insert db name here> failed!")
            return 
        #TODO: for failing case add code to catch the error and print some usefull msg 

        self.close()
        
    
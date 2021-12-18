
from qgis.PyQt.QtWidgets import *
from qgis.core import Qgis
from .connector_dialog import Ui_dlgConnector
from .connection import *





class DlgConnector(QDialog, Ui_dlgConnector):
    def __init__(self):
        super(DlgConnector, self).__init__()
        self.setupUi(self)

        self.btnConnect.clicked.connect(self.evt_btnConnect_clicked)
        self.new_connection = None
        


    def evt_btnConnect_clicked(self):
        connectionInstance = connection()

        connectionInstance.connection_name = self.ledConnName.text()
        connectionInstance.host = self.ledHost.text()
        connectionInstance.port = self.ledPort.text()
        connectionInstance.database_name = self.ledDb.text()
        connectionInstance.username = self.ledUserName.text()
        connectionInstance.password = self.qledPassw.text()
        if self.checkBox.isEnabled: connectionInstance.store_creds=True 
        

        try:
            connect(connectionInstance)
            self.new_connection = connectionInstance

            self.gbxConnDet.bar.pushMessage("Success","Connection is valid! You can find it in 'existing connection' box.",level=Qgis.Success, duration=3)
            if self.checkBox.isEnabled: 
                self.store_credetials()

        except (Exception, psycopg2.DatabaseError) as error:
            print(error)
            self.gbxConnDet.bar.pushMessage("Error",'Connection failed!',level=Qgis.Critical, duration=5)

    def store_credetials(self): #TODO: Notify user that his connection parameter are stored localy in his .ini file
        new_setttings = QgsSettings()
        con_path= f'PostgreSQL/connections/{self.new_connection.connection_name}'

        new_setttings.setValue(f'{con_path}/database',self.new_connection.database_name)
        new_setttings.setValue(f'{con_path}/host',self.new_connection.host)
        new_setttings.setValue(f'{con_path}/port',self.new_connection.port)
        new_setttings.setValue(f'{con_path}/username',self.new_connection.username)
        new_setttings.setValue(f'{con_path}/password',self.new_connection.password)
        
    
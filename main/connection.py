from qgis.core import QgsSettings
from ..dialog.connector_dialog import Ui_dlgConnector
from qgis.core import Qgis
from qgis.PyQt.QtWidgets import QDialog
import psycopg2

class DlgConnector(QDialog, Ui_dlgConnector):
    def __init__(self):
        super(DlgConnector, self).__init__()
        self.setupUi(self)

        self.btnConnect.clicked.connect(self.evt_btnConnect_clicked)
        self.new_connection = None
        


    def evt_btnConnect_clicked(self):
        connectionInstance = Connection()

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



class Connection:
    """Class to store connection information"""
    def __init__(self): 
        self.connection_name=None
        self.database_name=None
        self.host=None
        self.port=None
        self.username=None
        self.password='*****'
        self.store_creds=False
        self.is_active=None
        self.s_version=None
        self.c_version=None
        self.id=id(self)
        self.hex_location=hex(self.id)

        self.green_connection=False
        self.green_s_version=False
        self.green_c_verison=False
        self.green_privileges=False
        self.green_installation=False
        

    def __str__(self):
        print(f"connection name: {self.connection_name}") 
        print(f"db name: {self.database_name}")
        print(f"host:{self.host}")
        print(f"port:{self.port}")
        print(f"username:{self.username}")
        print(f"password:{self.password[0]}{self.password[1]}*****")
        print(f"id:{self.id}")
        print(f"DB version:{self.s_version}")
        print(f"3DCityDB version:{self.c_version}")
        print(f"hex location:{self.hex_location}")
        print(f"to store:{self.store_creds}")
        return('\n')
    
    def meets_requirements(self):
        if all((self.green_connection,
                self.green_s_version,
                self.green_c_verison,
                self.green_privileges,
                self.green_installation)): return True
        return False
    # def add_to_collection(self,db_collection):
    #     db_collection.append(self)

def get_postgres_conn(dbLoader):
    """Function that reads the QGIS user settings to look for existing connections"""

    # Clear the contents of the comboBox from previous runs
    dbLoader.dlg.cbxExistingConnection.clear()

    qsettings = QgsSettings()

    #Navigate to postgres connection settings 
    qsettings.beginGroup('PostgreSQL/connections')

    #Get all stored connection names 
    connections=qsettings.childGroups()

    #Get database connection settings for every stored connection
    for c in connections:

        connectionInstance = Connection()

        qsettings.beginGroup(c)

        connectionInstance.connection_name = c
        connectionInstance.database_name = qsettings.value('database')
        connectionInstance.host = qsettings.value('host')
        connectionInstance.port = qsettings.value('port')
        connectionInstance.username = qsettings.value('username')
        connectionInstance.password = qsettings.value('password')

        dbLoader.dlg.cbxExistingConnection.addItem(f'{c}',connectionInstance)
        qsettings.endGroup()

    return None

def connect(db):
    """Open a connection to postgres database"""

    return psycopg2.connect(dbname= db.database_name,
                            user= db.username,
                            password= db.password,
                            host= db.host,
                            port= db.port)

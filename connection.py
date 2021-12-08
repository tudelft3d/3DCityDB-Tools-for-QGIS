from qgis.core import QgsSettings
import psycopg2

class connection:
    """Class to store connection information"""
    def __init__(self): 
        self.connection_name=None
        self.database_name=None
        self.host=None
        self.port=None
        self.username=None
        self.password='*****'
        self.store_creds=None
        self.is_active=None
        self.s_version=None
        self.c_version=None
        self.id=id(self)
        self.hex_location=hex(self.id)
        

    def __str__(self):
        print(f"connection name: {self.connection_name}") 
        print(f"db name: {self.database_name}")
        print(f"host:{self.host}")
        print(f"port:{self.port}")
        print(f"username:{self.user}")
        print(f"password:{self.password[0]}{self.password[1]}*****")
        print(f"id:{self.id}")
        print(f"DB version:{self.s_version}")
        print(f"3DCityDB version:{self.c_version}")
        print(f"hex location:{self.hex_location}")
        return('\n')
    
    # def add_to_collection(self,db_collection):
    #     db_collection.append(self)

def get_postgres_conn(dbLoader):
    """Function that reads the QGIS user settings to look for existing connections"""

    # Clear the contents of the comboBox from previous runs
    dbLoader.dlg.cbxConnToExist.clear()

    qsettings = QgsSettings()

    #Navigate to postgres connection settings 
    qsettings.beginGroup('PostgreSQL/connections')

    #Get all stored connection names 
    connections=qsettings.childGroups()

    #Get database connection settings for every stored connection
    for c in connections:

        connectionInstance = connection()

        qsettings.beginGroup(c)

        connectionInstance.connection_name = c
        connectionInstance.database_name = qsettings.value('database')
        connectionInstance.host = qsettings.value('host')
        connectionInstance.port = qsettings.value('port')
        connectionInstance.username = qsettings.value('username')
        connectionInstance.password = qsettings.value('password')

        dbLoader.dlg.cbxConnToExist.addItem(f'{c}',connectionInstance)
        qsettings.endGroup()

    return None

def connect(db):
    """Open a connection to postgres database"""

    return psycopg2.connect(dbname= db.database_name,
                            user= db.username,
                            password= db.password,
                            host= db.host,
                            port= db.port)

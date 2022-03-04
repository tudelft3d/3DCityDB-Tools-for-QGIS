"""This module contains classes and functions related to the connections."""


from qgis.PyQt.QtWidgets import QDialog
from qgis.core import Qgis,QgsSettings
import psycopg2

from .. import connector_dialog
from . import constants as c

class DlgConnector(QDialog, connector_dialog.Ui_dlgConnector):
    """Connector Dialog. This dialog pops-up when a user requests
    to make a new connection.
    """

    def __init__(self):
        super(DlgConnector, self).__init__()
        self.setupUi(self)

        # Connect signals
        self.btnConnect.clicked.connect(self.evt_btnConnect_clicked)

        # Connection object variable
        self.new_connection: Connection = None

    def evt_btnConnect_clicked(self):
        """Event that is called when the current 'Connect' pushButton
        (btnConnect) is pressed.
        """
        #TODO: get the following code in a widget_setup function.
        # BE consistent with your the code structure

        # Instantiate a connection object
        connectionInstance = Connection()

        # Update connection attributes parameters from 'Line Edit' user info
        connectionInstance.connection_name = self.ledConnName.text()
        connectionInstance.host = self.ledHost.text()
        connectionInstance.port = self.ledPort.text()
        connectionInstance.database_name = self.ledDb.text()
        connectionInstance.username = self.ledUserName.text()
        connectionInstance.password = self.qledPassw.text()
        if self.checkBox.isEnabled:
            connectionInstance.store_creds=True

        try:
            # Attempt to open connection
            connect(connectionInstance)
            self.new_connection = connectionInstance

            self.gbxConnDet.bar.pushMessage("Success","Connection is valid! You can find it in 'existing connection' box.",level=Qgis.Success, duration=3)
            if self.checkBox.isEnabled:
                self.store_credetials()

        except (Exception, psycopg2.DatabaseError) as error:
            print(error)
            self.gbxConnDet.bar.pushMessage("Error",'Connection failed!',
                level=Qgis.Critical,
                duration=5)

    def store_credetials(self):
        """Function that stores the user's parameters
        in the user's profile settings for future use.
        """
        #TODO: Warn user that his connection parameter are stored localy in his .ini file

        new_setttings = QgsSettings()
        con_path= f'PostgreSQL/connections/{self.new_connection.connection_name}'

        new_setttings.setValue(f'{con_path}/database',self.new_connection.database_name)
        new_setttings.setValue(f'{con_path}/host',self.new_connection.host)
        new_setttings.setValue(f'{con_path}/port',self.new_connection.port)
        new_setttings.setValue(f'{con_path}/username',self.new_connection.username)
        new_setttings.setValue(f'{con_path}/password',self.new_connection.password)

class Connection:
    """Class to store connection information."""

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
        print('\n')

    def meets_requirements(self) -> bool:
        """Method that ca be used to check if the connection
        is ready for plugin use.

        *   :returns: The connection's readiness status to work with
                the plugin.

            :rtype: bool
        """
        if all((self.green_connection,
                self.green_s_version,
                self.green_c_verison,
                self.green_privileges,
                self.green_installation)):
            return True
        return False

def get_postgres_conn(dbLoader) -> None:
    """Function that reads the QGIS user settings to look for
    existing connections

    All found existing connection are store in 'Connection'
    objects and can be found and accessed from 'cbxExistingConnection'
    widget"""

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

def connect(db: Connection, app_name: str = c.PLUGIN_NAME):
    """Open a connection to postgres database.

    *   :param db: The connection custom object

        :rtype: Connection
 
    *   :param app_name: A name for the session

        :rtype: str

    *   :returns: The connection psycopg2 object (opened)

        :rtype: psycopg2.connection
    """

    return psycopg2.connect(dbname= db.database_name,
                            user= db.username,
                            password= db.password,
                            host= db.host,
                            port= db.port,
                            application_name= app_name)


###
#from qgis.core import QgsMessageLog, Qgis
###

import psycopg2
from qgis.core import QgsSettings

from .... import main_constants as main_c
from ....cdb_loader import CDBLoader  # Used only to add the type of the function parameters
from ...shared.functions import general_functions as gen_f
from ..connection import Connection
from . import sql

FILE_LOCATION = gen_f.get_file_relative_path(__file__)

def get_qgis_postgres_conn_list(cdbLoader: CDBLoader) -> None:
    """Function that reads the QGIS user settings to look for existing connections

    All existing connections are stored in a 'Connection'
    objects and can be found and accessed from 'cbxExistingConnC'
    or 'cbxExistingConn' widget
    """
    # Clear the contents of the comboBox from previous runs
    if cdbLoader.usr_dlg:
        cdbLoader.usr_dlg.cbxExistingConnC.clear()
    if cdbLoader.admin_dlg:
        cdbLoader.admin_dlg.cbxExistingConn.clear()

    qsettings = QgsSettings()

    # Navigate to PostgreSQL connection settings
    qsettings.beginGroup('PostgreSQL/connections')

    # Get all stored connection names
    stored_connections = qsettings.childGroups()

    # Get database connection settings for every stored connection
    for conn in stored_connections:

        connectionInstance = Connection()

        qsettings.beginGroup(conn)

        connectionInstance.connection_name = conn
        connectionInstance.database_name = qsettings.value('database')
        connectionInstance.host = qsettings.value('host')
        connectionInstance.port = qsettings.value('port')
        connectionInstance.username = qsettings.value('username')
        connectionInstance.password = qsettings.value('password')
        
        qsettings.endGroup()

        # For 'User Connection' tab.
        if cdbLoader.usr_dlg:
            cdbLoader.usr_dlg.cbxExistingConnC.addItem(f'{conn}', connectionInstance)
        # For 'Database Administration' tab.
        if cdbLoader.admin_dlg:
            cdbLoader.admin_dlg.cbxExistingConn.addItem(f'{conn}', connectionInstance)

def connect(db_connection: Connection, app_name: str = main_c.PLUGIN_NAME):
    """Open a connection to postgres database.

    *   :param db: The connection custom object
        :rtype: Connection
 
    *   :param app_name: A name for the session
        :rtype: str

    *   :returns: The connection psycopg2 object (opened)
        :rtype: psycopg2.connection
    """
    return psycopg2.connect(
            dbname           = db_connection.database_name,
            user             = db_connection.username,
            password         = db_connection.password,
            host             = db_connection.host,
            port             = db_connection.port,
            application_name = app_name)

def open_and_set_connection(cdbLoader: CDBLoader, app_name: str = main_c.PLUGIN_NAME) -> bool:
    """Opens a connection using the parameters stored in CDBLoader.DB
    and retrieves the server version. The server version is stored
    in 'pg_server_version' attribute of the Connection object.

    *   :param app_name: A name for the session
        :rtype: str

    *   :returns: connection attempt results
        :rtype: bool
    """
    try:
        # Open and set the connection.
        cdbLoader.conn = connect(db_connection=cdbLoader.DB, app_name=app_name)
        cdbLoader.conn.commit() # This seems redundant.

        # Get server version.
        version: str = sql.fetch_posgresql_server_version(cdbLoader)

        # Store version into the connection object.
        cdbLoader.DB.pg_server_version = version

    except (Exception, psycopg2.Error) as error:
        gen_f.critical_log(
            func=open_and_set_connection,
            location=FILE_LOCATION,
            header="Attempting connection",
            error=error)
        cdbLoader.conn.rollback()
        return False

    return True
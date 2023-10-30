from __future__ import annotations
from typing import TYPE_CHECKING, Union
if TYPE_CHECKING:
    from ....cdb_tools_main import CDBToolsMain
    from ...gui_admin.admin_dialog import CDB4AdminDialog
    from ...gui_loader.loader_dialog import CDB4LoaderDialog
    from ...gui_deleter.deleter_dialog import CDB4DeleterDialog

import psycopg2
from psycopg2.extensions import connection as pyconn
from qgis.core import QgsSettings

from qgis.PyQt.QtWidgets import QMessageBox, QPushButton

from .... import cdb_tools_main_constants as main_c
from ...shared.functions import general_functions as gen_f
from ..other_classes import Connection
from . import sql

FILE_LOCATION = gen_f.get_file_relative_path(__file__)

def get_qgis_postgres_conn_list(dlg: Union[CDB4LoaderDialog, CDB4DeleterDialog, CDB4AdminDialog]) -> None:
    """Function that reads the QGIS user settings to look for existing connections

    All existing connections are stored in a 'Connection'
    objects and can be found and accessed from 'cbxExistingConnC'
    or 'cbxExistingConn' widget
    """
    # Clear the contents of the comboBox from previous runs
    dlg.cbxExistingConn.clear()

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

        dlg.cbxExistingConn.addItem(f'{conn}', connectionInstance)
    
    return None


def create_db_connection(db_connection: Connection, app_name: str = main_c.PLUGIN_NAME_LABEL) -> pyconn:
    """Create a new database session and returns a new instance of the psycopg connection class.

    *   :param db: The connection custom object
        :rtype: Connection
 
    *   :param app_name: A name for the session
        :rtype: str

    *   :returns: The connection psycopg2 object (opened)
        :rtype: psycopg2.extensions.connection
    """
    open_conn: pyconn = None

    try:
        open_conn = psycopg2.connect(dbname          = db_connection.database_name,
                                    user             = db_connection.username,
                                    password         = db_connection.password,
                                    host             = db_connection.host,
                                    port             = db_connection.port,    
                                    application_name = app_name)
        
        return open_conn
    
    except (Exception, psycopg2.Error) as error:
        gen_f.critical_log(
            func=create_db_connection,
            location=FILE_LOCATION,
            header="Invalid connection settings",
            error=error)


def open_connection(dlg: Union[CDB4LoaderDialog, CDB4DeleterDialog, CDB4AdminDialog], app_name: str = main_c.PLUGIN_NAME_LABEL) -> bool:
    """Opens a connection using the parameters stored in dlg.DB
    and retrieves the server version. The server version is stored
    in 'pg_server_version' attribute of the Connection object.

    *   :param app_name: A name for the session
        :rtype: str

    *   :returns: connection attempt results
        :rtype: bool
    """
    dlg.conn: pyconn = None
    
    # Open and set the connection.
    dlg.conn = create_db_connection(db_connection=dlg.DB, app_name=app_name)
    
    if dlg.conn:
        dlg.conn.commit() # This seems redundant.
        # Get server version.
        version: str = sql.fetch_posgresql_server_version(dlg)
        # Store version into the connection object.
        dlg.DB.pg_server_version = version
        return True
    else:
        return False


def check_connection_uniqueness(dlg: Union[CDB4LoaderDialog, CDB4DeleterDialog], cdbMain: CDBToolsMain) -> bool:
    """
    """
    is_unique: bool = True
    curr_DB: Connection = dlg.DB
    curr_CDB_SCHEMA: str = dlg.CDB_SCHEMA
    curr_DIALOG_NAME: str = dlg.DLG_NAME
    no_admin_dlgs: list = []

    no_admin_dlgs = [dlg for k,dlg in cdbMain.DialogRegistry.items() if k not in [main_c.DLG_NAME_ADMIN, curr_DIALOG_NAME]]

    # Conditions: 
    # 1) Connection exists, is open
    # 2) Same connection variables (database, usr)
    # 3) Same selected cdb_schema

    if no_admin_dlgs:
        for dlg in no_admin_dlgs:
            if dlg.conn:
                if dlg.conn.closed == 0:
                    if dlg.CDB_SCHEMA:
                        if all((curr_DB.host == dlg.DB.host,
                                curr_DB.database_name == dlg.DB.database_name,
                                curr_DB.username == dlg.DB.username,
                                curr_CDB_SCHEMA == dlg.CDB_SCHEMA,
                            )):
                            is_unique = False
                            break

    # print(is_unique)
    if is_unique:
        return is_unique
    else:
        # ask what to do: wait or close the other?
        # Create buttons
        btnProceed = QPushButton()
        btnProceed.setText('Proceed')
        btnWait = QPushButton()
        btnWait.setText('Wait')

        # Create message box
        msgBox = QMessageBox()
        msgBox.setIcon(QMessageBox.Warning)
        msgBox.setText(f"You are already connected to schema '{dlg.CDB_SCHEMA}' in the '{dlg.DLG_NAME_LABEL}' GUI.<br><br>You can either:<br>- Proceed (i.e. automatically close the other connection), or<br>- Wait (i.e. manually close the other connection)")
        msgBox.setWindowTitle("Concurrent connection")
        msgBox.addButton(btnWait, QMessageBox.RejectRole)
        msgBox.addButton(btnProceed, QMessageBox.ActionRole)
        msgBox.setDefaultButton(btnWait)

        msgBox.exec()
        res = msgBox.clickedButton()
        if res == btnProceed:
            # print('Proceed and close automatically')
            dlg.conn.close()
            dlg.dlg_reset_all()
            return True
        elif res == btnWait:
            # print('Wait and close manually')
            return is_unique
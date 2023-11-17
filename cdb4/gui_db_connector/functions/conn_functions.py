from __future__ import annotations
from typing import TYPE_CHECKING, Union, Optional
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
from ..other_classes import DBConnectionInfo
from . import sql

FILE_LOCATION = gen_f.get_file_relative_path(file=__file__)


def list_qgis_postgres_stored_conns() -> Optional[list[tuple[str, dict]]]:
    """Function that reads the QGIS user settings to look for existing connections
    It results in a list[tuple[str, dict]]
    """
    # Create a QgsSettings object to access the settings
    qgis_settings = QgsSettings()

    # Navigate to PostgreSQL connection settings
    qgis_settings.beginGroup(prefix='PostgreSQL/connections')

    # Get all stored connection names
    stored_conn_list = qgis_settings.childGroups()
    # print('stored_connections', stored_connections)

    stored_conns = []

    # Get database connection settings for every stored connection
    for stored_conn in stored_conn_list:

        db_conn_info_dict = dict()

        qgis_settings.beginGroup(prefix=stored_conn)
        # Populate the object BEGIN
        db_conn_info_dict['database']          = qgis_settings.value(key='database')
        db_conn_info_dict['host']              = qgis_settings.value(key='host')
        db_conn_info_dict['port']              = qgis_settings.value(key='port')
        db_conn_info_dict['username']          = qgis_settings.value(key='username')
        db_conn_info_dict['password']          = qgis_settings.value(key='password')
        db_conn_info_dict['db_toc_node_label'] = qgis_settings.value(key='database') + " @ " + qgis_settings.value(key='host') + ":" + str(qgis_settings.value(key='port'))

        print('read from stored conns', db_conn_info_dict['db_toc_node_label'])

        # Populate the object END
        qgis_settings.endGroup()

        t: tuple[str, dict] = (stored_conn, db_conn_info_dict)
        stored_conns: list[tuple[str, dict]]
        stored_conns.append(t)
    
    stored_conns.sort()
    # stored_conns.sort(reverse=True)
    # print(stored_conns)

    return stored_conns


def fill_connection_list_box(dlg: Union[CDB4LoaderDialog, CDB4DeleterDialog, CDB4AdminDialog], 
                             stored_conns: Optional[list[tuple[str, dict]]] = None
                             ) -> None:
    """Function that fills the the 'cbxExistingConn' combobox
    """
    # Clear the contents of the comboBox from previous runs
    dlg.cbxExistingConn.clear()

    if stored_conns:
        # Get database connection settings for every stored connection
        for stored_conn_name, stored_conn_params in stored_conns:

            label: str = stored_conn_name
            # Create object
            db_conn_info = DBConnectionInfo()
            # Populate the object attributes BEGIN
            db_conn_info.connection_name   = label
            db_conn_info.database_name     = stored_conn_params['database']
            db_conn_info.host              = stored_conn_params['host']
            db_conn_info.port              = stored_conn_params['port']
            db_conn_info.username          = stored_conn_params['username']
            db_conn_info.password          = stored_conn_params['password']
            db_conn_info.db_toc_node_label = stored_conn_params['db_toc_node_label']
            # db_conn_info.db_toc_node_label = stored_conn_params['database'] + " @ " + stored_conn_params['host'] + ":" +  str(stored_conn_params['port'])
            # Populate the object attributes END

            dlg.cbxExistingConn.addItem(label, userData=db_conn_info)
    
    return None


def create_db_connection(db_connection: DBConnectionInfo, app_name: str = main_c.PLUGIN_NAME_LABEL) -> pyconn:
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
        version = sql.get_posgresql_server_version(dlg=dlg)
        # Store version into the connection object.
        dlg.DB.pg_server_version = version
        return True
    else:
        return False


def check_connection_uniqueness(dlg: Union[CDB4LoaderDialog, CDB4DeleterDialog], cdbMain: CDBToolsMain) -> bool:
    """
    """
    is_unique: bool = True
    curr_DB: DBConnectionInfo = dlg.DB
    curr_CDB_SCHEMA = dlg.CDB_SCHEMA
    curr_DIALOG_NAME = dlg.DLG_NAME

    non_admin_dlgs = []
    non_admin_dlgs = [dlg for k, dlg in cdbMain.DialogRegistry.items() if k not in [main_c.DLG_NAME_ADMIN, curr_DIALOG_NAME]]

    # Conditions: 
    # 1) Connection exists, is open
    # 2) Same connection variables (database, usr)
    # 3) Same selected cdb_schema

    if non_admin_dlgs:
        for dlg in non_admin_dlgs:
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
        return True
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
            return False
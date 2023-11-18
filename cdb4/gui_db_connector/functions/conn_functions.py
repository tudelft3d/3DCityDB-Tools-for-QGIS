from __future__ import annotations
from typing import TYPE_CHECKING, Union
if TYPE_CHECKING:
    from ....cdb_tools_main import CDBToolsMain
    from ...gui_admin.admin_dialog import CDB4AdminDialog
    from ...gui_loader.loader_dialog import CDB4LoaderDialog
    from ...gui_deleter.deleter_dialog import CDB4DeleterDialog

import psycopg2
from psycopg2.extensions import connection as pyconn
# from qgis.core import QgsSettings

from qgis.PyQt.QtWidgets import QMessageBox, QPushButton

from .... import cdb_tools_main_constants as main_c
from ...shared.functions import general_functions as gen_f
from ..other_classes import DBConnectionInfo

FILE_LOCATION = gen_f.get_file_relative_path(file=__file__)


def open_db_connection(db_connection: DBConnectionInfo, app_name: str = main_c.PLUGIN_NAME_LABEL) -> pyconn:
    """Create a new database session and returns a new instance of the psycopg connection class.

    *   :param db_connection: The connection custom object
        :rtype: DBConnectionInfo
 
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
            func=open_db_connection,
            location=FILE_LOCATION,
            header="Invalid connection settings",
            error=error)


def get_posgresql_server_version(dlg: Union[CDB4LoaderDialog, CDB4DeleterDialog, CDB4AdminDialog]) -> str:
    """SQL query that reads and retrieves the server version.

    *   :returns: PostgreSQL server version as string (e.g. 14.6)
        :rtype: str
    """
    try:
        with dlg.conn.cursor() as cur:
            cur.execute(query="""SHOW server_version;""")
            version = str(cur.fetchone()[0]) # Tuple has trailing comma.
        dlg.conn.commit()
        return version

    except (Exception, psycopg2.Error) as error:
        dlg.conn.rollback()
        gen_f.critical_log(
            func=get_posgresql_server_version,
            location=FILE_LOCATION,
            header="Retrieving PostgreSQL server version",
            error=error)


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
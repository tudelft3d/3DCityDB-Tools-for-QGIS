"""This module contains functions that relate to the server side operations.
These functions are responsible to communicate and fetch data from
the database with sql queries or sql function calls.
"""
from __future__ import annotations
from typing import TYPE_CHECKING, Union, Optional
if TYPE_CHECKING:       
    from ...gui_admin.admin_dialog import CDB4AdminDialog
    from ...gui_loader.loader_dialog import CDB4LoaderDialog
    from ...gui_deleter.deleter_dialog import CDB4DeleterDialog
    from ...shared.dataTypes import QgisPKGVersion

import psycopg2, psycopg2.sql as pysql
from psycopg2.extras import NamedTupleCursor
from qgis.core import Qgis, QgsMessageLog

from .... import cdb_tools_main_constants as main_c
from . import general_functions as gen_f

FILE_LOCATION = gen_f.get_file_relative_path(file=__file__)

def get_3dcitydb_version(dlg: Union[CDB4AdminDialog, CDB4LoaderDialog, CDB4DeleterDialog]) -> str:
    """SQL query that reads and retrieves the 3DCityDB version.

    *   :returns: 3DCityDB version.
        :rtype: str
    """
    try:
        with dlg.conn.cursor() as cur:
            cur.execute("""SELECT version FROM citydb_pkg.citydb_version();""")
            version: str = cur.fetchone()[0] # Tuple has trailing comma.
        dlg.conn.commit()

        return version

    except (Exception, psycopg2.Error) as error:
        gen_f.critical_log(
            func=get_3dcitydb_version,
            location=FILE_LOCATION,
            header="Retrieving 3DCityDB version",
            error=error)
        dlg.conn.rollback()


def create_qgis_usr_schema_name(dlg: Union[CDB4AdminDialog, CDB4LoaderDialog, CDB4DeleterDialog], usr_name: Optional[str] = None) -> str:
    """Calls the qgis_pkg function that derives the name of the usr_schema from the usr_name.
    """
    if usr_name is None:
        usr_name: str = dlg.DB.username

    query = pysql.SQL("""
        SELECT {_qgis_pkg_schema}.create_qgis_usr_schema_name({_usr_name});
        """).format(
        _qgis_pkg_schema = pysql.Identifier(dlg.QGIS_PKG_SCHEMA),
        _usr_name = pysql.Literal(usr_name)
        )

    try:
        with dlg.conn.cursor() as cur:
            cur.execute(query)
            usr_schema: str = cur.fetchone()[0] # Trailing comma
        dlg.conn.commit()

        # Asign the value to the variable in the plugin
        dlg.USR_SCHEMA = usr_schema

        return usr_schema

    except (Exception, psycopg2.Error) as error:
        gen_f.critical_log(
            func=create_qgis_usr_schema_name,
            location=FILE_LOCATION,
            header=f"Deriving user schema name for user {usr_name}",
            error=error)
        dlg.conn.rollback()


def is_qgis_pkg_installed(dlg: Union[CDB4AdminDialog, CDB4LoaderDialog, CDB4DeleterDialog]) -> bool:
    """SQL query that searches for schema 'qgis_pkg' in the current database

    *   :returns: Search result
        :rtype: bool
    """
    query = pysql.SQL("""
        SELECT schema_name 
        FROM information_schema.schemata 
        WHERE schema_name = {_qgis_pkg_schema};
        """).format(
        _qgis_pkg_schema = pysql.Literal(dlg.QGIS_PKG_SCHEMA)
        )

    try:
        with dlg.conn.cursor() as cur:
            cur.execute(query)
            res = cur.fetchone()
        dlg.conn.commit()

        if res:
            return True
        return False

    except (Exception, psycopg2.Error) as error:
        gen_f.critical_log(
            func=is_qgis_pkg_installed,
            location=FILE_LOCATION,
            header=f"Searching for schema {dlg.QGIS_PKG_SCHEMA} in current database",
            error=error)
        dlg.conn.rollback()


def get_qgis_pkg_version(dlg: Union[CDB4AdminDialog, CDB4LoaderDialog, CDB4DeleterDialog]) -> QgisPKGVersion:
    """SQL function that retrieves the qgis_pkg version

    *   :returns: The qgis_pkg version as named tuple:
        version, full_version, major_version, minor_version, minor_revision, code_name, release_date.
    *   :rtype: QgisPKGVersion - NamedTuple[str, str, int, int, int, str, str]
    """
    
    query = pysql.SQL("""
        SELECT * FROM {_qgis_pkg_schema}.qgis_pkg_version();
        """).format(
        _qgis_pkg_schema = pysql.Identifier(dlg.QGIS_PKG_SCHEMA)
        )

    try:
        with dlg.conn.cursor(cursor_factory=NamedTupleCursor) as cur:
            cur.execute(query)
            # this is a named tuple containing: 
            # version, full_version, major_version, minor_version, minor_revision, code_name, release_date
            version: QgisPKGVersion = cur.fetchone()
        dlg.conn.commit()
        return version

    except (Exception, psycopg2.Error) as error:
        gen_f.critical_log(
            func=get_qgis_pkg_version,
            location=FILE_LOCATION,
            header=f"Retrieving {dlg.QGIS_PKG_SCHEMA} version",
            error=error)
        dlg.conn.rollback()


def is_usr_schema_installed(dlg: Union[CDB4AdminDialog, CDB4LoaderDialog, CDB4DeleterDialog]) -> bool:
    """SQL query that checks whether schema qgis_{usr} is installed in the current database.

    *   :returns: Search result
        :rtype: bool
    """
    query = pysql.SQL("""
        SELECT schema_name 
        FROM information_schema.schemata 
        WHERE schema_name = {_usr_schema};
        """).format(
        _usr_schema = pysql.Literal(dlg.USR_SCHEMA)
        )

    try:
        with dlg.conn.cursor() as cur:
            cur.execute(query)
            usr_schema = cur.fetchone()
        dlg.conn.commit()

        if usr_schema:
            return True
        return False

    except (Exception, psycopg2.Error) as error:
        gen_f.critical_log(
            func=is_usr_schema_installed,
            location=FILE_LOCATION,
            header=f"Checking whether schema '{dlg.USR_SCHEMA}' is installed in current database",
            error=error)
        dlg.conn.rollback()


def upsert_plugin_settings(dlg: Union[CDB4AdminDialog, CDB4LoaderDialog, CDB4DeleterDialog], usr_schema: str, dialog_name: str, settings_list: list[dict]) -> Optional[int]:
    """SQL function that upserts the settings to the qgis_xxx.settings table

    *   :returns: None
        :rtype:
    """
    # "settings_list is a list of dictionaries structured as follows:
    # The data_type is integer, the data_value is any, but will be converted to string
    # settings_list = [
    # {'name' : "minArea", 'data_type' : 2, 'data_value' : '15', 'label': 'info text....'},
    # {'name' : "decPrec", 'data_type' : 2, 'data_value' : '3' , 'label': 'info text....'},
    # ... etc.
    # ]

    for s in settings_list:
        for k, v in s.items():
            if k == "data_value":
                s.update({k: str(v)})

    query = pysql.SQL("""
        SELECT {_qgis_pkg_schema}.upsert_settings({_usr_schema},{_dialog_name},{_name},{_data_type},{_data_value},{_description});
        """).format(
            _qgis_pkg_schema = pysql.Identifier(dlg.QGIS_PKG_SCHEMA),
            _usr_schema = pysql.Literal(usr_schema),
            _dialog_name = pysql.Literal(dialog_name),
            _name = pysql.Placeholder("name"),
            _data_type = pysql.Placeholder("data_type"),
            _data_value = pysql.Placeholder("data_value"),
            _description = pysql.Placeholder("label")
        )

    try:
        with dlg.conn.cursor() as cur:
            # the cur.executemany drops by default all results, so we cannot get anything back for checking
            # Check the psycopg documentation for more details.
            # Therefore we stay with the normal iteration over cur.execute of a single query.
            # cur.executemany(query, settings_list)
            for setting in settings_list:
                cur.execute(query,  setting)

            last_upserted_id = cur.fetchone()[0]
        dlg.conn.commit()

        # print("Last upserted id:", res)

        if not last_upserted_id:
            return None
        else:
            return last_upserted_id

    except (Exception, psycopg2.Error):
        QgsMessageLog.logMessage(f"Could not upsert values to table {usr_schema}.settings.", main_c.PLUGIN_NAME_LABEL, level=Qgis.MessageLevel.Warning)
        dlg.conn.rollback()


def get_plugin_settings(dlg: Union[CDB4AdminDialog, CDB4LoaderDialog, CDB4DeleterDialog], usr_schema: str, dialog_name: str) -> list[dict]:
    """SQL function that reads settings from the qgis_xxx.settings table

    *   :returns: list
        :rtype: list(dict)
    """
    # "settings_list is a list of dictionaries structured as follows:
    # The data_type is integer, the data_value is read as string but will be converted
    # settings_list = [
    # {'name' : "decPrec", 'data_type' : 2, 'data_value' : 3},
    # {'name' : "minArea", 'data_type' : 3, 'data_value' : 0.001},
    # ... etc.
    # ]

    query = pysql.SQL("""
        SELECT name, data_type, data_value
        FROM {_usr_schema}.settings
        WHERE dialog_name = {_dialog_name};
        """).format(
            _usr_schema = pysql.Identifier(usr_schema),
            _dialog_name = pysql.Literal(dialog_name)
        )

    try:
        with dlg.conn.cursor() as cur:
            cur.execute(query)
            col_names = [desc[0] for desc in cur.description]
            res = cur.fetchall()
        dlg.conn.commit()

        settings_list = [dict(zip(col_names, values)) for values in res]

        for s in settings_list:
            dt = s["data_type"]
            v = s["data_value"]
            if dt == 1:
                pass # nothing to do, it's already a string
            elif dt == 2:
                s["data_value"] = int(v)
            elif dt == 3:
                s["data_value"] = float(v)
            elif dt == 4:
                s["data_value"] = bool(int(v))
            elif dt == 5:
                pass # to do in case of date or other data types
            else:
                pass

        # print("Retrieved from db:\n", settings_list)

        return settings_list

    except (Exception, psycopg2.Error):
        QgsMessageLog.logMessage(f"Could not retrieve values from table {usr_schema}.settings.", main_c.PLUGIN_NAME_LABEL, level=Qgis.MessageLevel.Warning)
        dlg.conn.rollback()

    return None

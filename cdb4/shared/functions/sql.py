"""This module contains functions that relate to the server side operations.

These functions are responsible to communicate and fetch data from
the database with sql queries or sql function calls.
"""
import psycopg2
from qgis.core import Qgis, QgsMessageLog

from ....cdb_loader import CDBLoader  # Used only to add the type of the function parameters
from . import general_functions as gen_f

FILE_LOCATION = gen_f.get_file_relative_path(file=__file__)

def fetch_3dcitydb_version(cdbLoader: CDBLoader) -> str:
    """SQL query that reads and retrieves the 3DCityDB version.

    *   :returns: 3DCityDB version.
        :rtype: str
    """
    try:
        with cdbLoader.conn.cursor() as cur:
            cur.execute(query="""SELECT version FROM citydb_pkg.citydb_version();""")
            version: str = cur.fetchone()[0] # Tuple has trailing comma.
        cdbLoader.conn.commit()
        return version

    except (Exception, psycopg2.Error) as error:
        gen_f.critical_log(
            func=fetch_3dcitydb_version,
            location=FILE_LOCATION,
            header="Retrieving 3DCityDB version",
            error=error)
        cdbLoader.conn.rollback()

def exec_create_qgis_usr_schema_name(cdbLoader: CDBLoader, usr_name: str = None) -> str:
    """Calls the qgis_pkg function that derives the name of the usr_schema from the usr_name.
    """
    if usr_name is None:
        usr_name: str = cdbLoader.DB.username

    try:
        with cdbLoader.conn.cursor() as cur:
            cur.callproc(f"""{cdbLoader.QGIS_PKG_SCHEMA}.create_qgis_usr_schema_name""", [usr_name])
            usr_schema: str = cur.fetchone()[0] # Trailing comma
        cdbLoader.USR_SCHEMA = usr_schema
        cdbLoader.conn.commit()
        return usr_schema

    except (Exception, psycopg2.Error) as error:
        gen_f.critical_log(
            func=exec_create_qgis_usr_schema_name,
            location=FILE_LOCATION,
            header=f"Deriving user schema name for user {usr_name}",
            error=error)
        cdbLoader.conn.rollback()

def is_qgis_pkg_installed(cdbLoader: CDBLoader) -> bool:
    """SQL query that searches for schema 'qgis_pkg' in the current database

    *   :returns: Search result
        :rtype: bool
    """
    try:
        with cdbLoader.conn.cursor() as cur:
            # Search for qgis_pkg schema
            cur.execute(query=f"""SELECT schema_name FROM information_schema.schemata WHERE schema_name = '{cdbLoader.QGIS_PKG_SCHEMA}';""")
            pkg_name = cur.fetchone()
        cdbLoader.conn.commit()

        if pkg_name:
            return True
        return False

    except (Exception, psycopg2.Error) as error:
        gen_f.critical_log(
            func=is_qgis_pkg_installed,
            location=FILE_LOCATION,
            header=f"Searching for schema {cdbLoader.QGIS_PKG_SCHEMA} in current database",
            error=error)
        cdbLoader.conn.rollback()

def exec_qgis_pkg_version(cdbLoader: CDBLoader) -> tuple:
    """SQL function that reads and retrieves the qgis_pkg version

    *   :returns: The qgis_pkg version.
        :rtype: tuple
    """
    try:
        with cdbLoader.conn.cursor() as cur:
            cur.callproc(f"""{cdbLoader.QGIS_PKG_SCHEMA}.qgis_pkg_version""", [])
            version: tuple = cur.fetchone() # this is a tuple containing: version, full_version, major_version, minor_version, minor_revision, code_name, release_date
        cdbLoader.conn.commit()
        return version

    except (Exception, psycopg2.Error) as error:
        gen_f.critical_log(
            func=exec_qgis_pkg_version,
            location=FILE_LOCATION,
            header=f"Retrieving {cdbLoader.QGIS_PKG_SCHEMA} version",
            error=error)
        cdbLoader.conn.rollback()

def is_usr_schema_installed(cdbLoader: CDBLoader) -> bool:
    """SQL query that checks whether schema qgis_{usr} is installed in the current database.

    *   :returns: Search result
        :rtype: bool
    """
    try:
        with cdbLoader.conn.cursor() as cur:
            # Get qgis_{user} schema from database
            cur.execute(query=f"""SELECT schema_name FROM information_schema.schemata WHERE schema_name = '{cdbLoader.USR_SCHEMA}';""")
            usr_schema = cur.fetchone()
        cdbLoader.conn.commit()

        if usr_schema:
            return True
        return False

    except (Exception, psycopg2.Error) as error:
        gen_f.critical_log(
            func=is_usr_schema_installed,
            location=FILE_LOCATION,
            header=f"Checking whether schema '{cdbLoader.USR_SCHEMA}' is installed in current database",
            error=error)
        cdbLoader.conn.rollback()

def exec_list_cdb_schemas_all(cdbLoader: CDBLoader, only_non_empty: bool = False) -> tuple:
    """SQL function that reads and retrieves all cdb_schemas, even the empty ones

    *   :returns: A list with all cdb_schemas in the database
        :rtype: tuple(str)
    """
    try:
        with cdbLoader.conn.cursor() as cur:
            cur.callproc(f"""{cdbLoader.QGIS_PKG_SCHEMA}.list_cdb_schemas""", [only_non_empty])
            result = cur.fetchall()
        cdbLoader.conn.commit()
        schema_names = tuple(zip(*result))[0] # trailing comma
        schema_nums = tuple(zip(*result))[1] # trailing comma        

    except (Exception, psycopg2.Error):
        QgsMessageLog.logMessage(f"No citydb schemas could be retrieved from the database.", cdbLoader.PLUGIN_NAME, level=Qgis.Warning)
        cdbLoader.conn.rollback()
        schema_names = tuple() # create an empty tuple
        schema_nums = tuple()  # create an empty tuple

    return schema_names, schema_nums






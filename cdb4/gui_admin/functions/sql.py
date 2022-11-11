"""This module contains functions that relate to the server side operations.
They communicate and fetch data from the database with sql queries or sql function calls.
"""
import psycopg2

from ....cdb_loader import CDBLoader # Used only to add the type of the function parameters
from ...shared.functions import general_functions as gen_f
from ...shared.functions import sql as sh_sql

FILE_LOCATION = gen_f.get_file_relative_path(file=__file__)

def fetch_list_usr_schemas(cdbLoader: CDBLoader) -> tuple:
    """SQL function that retrieves the database usr_schemas

    *   :returns: A list with all usr_schemas in the database
        :rtype: list(str)
    """
    try:
        with cdbLoader.conn.cursor() as cur:
            cur.callproc(f"""{cdbLoader.QGIS_PKG_SCHEMA}.list_usr_schemas""",[])
            schemas = cur.fetchall()
        schemas = tuple(zip(*schemas))[0] # trailing comma
        cdbLoader.conn.commit()
        return schemas

    except (Exception, psycopg2.Error) as error:
        gen_f.critical_log(
            func=fetch_list_usr_schemas,
            location=FILE_LOCATION,
            header="Retrieving list of usr_schemas",
            error=error)
        cdbLoader.conn.rollback()

def is_3dcitydb_installed(cdbLoader: CDBLoader) -> bool:
    """Function that checks whether the current database has the 
    3DCityDB installed. The check is done by querying the 3DCityDB
    version from citydb_pkg.version().

    On 3DCityDB absence a database error is emitted which means that
    it is not installed.
    """
    version: str = sh_sql.fetch_3dcitydb_version(cdbLoader)

    if version: # Could be None
        # Store version into the connection object.
        cdbLoader.DB.citydb_version = version
        return True
    return False

def is_superuser(cdbLoader: CDBLoader) -> bool:
    """SQL query that determines whether the connecting user has administrations privileges.

    *   :returns: Admin status
        :rtype: bool
    """
    try:
        with cdbLoader.conn.cursor() as cur:
            cur.execute(query= f"""SELECT 1 FROM pg_user WHERE usesuper IS TRUE AND usename = '{cdbLoader.DB.username}';""")
            result_bool = cur.fetchone() # as (1,) or None
        cdbLoader.conn.commit()
        if result_bool:
            return result_bool[0]
        return None

    except (Exception, psycopg2.Error) as error:
        gen_f.critical_log(
            func=is_superuser,
            location=FILE_LOCATION,
            header=f"Checking whether user is a database superuser",
            error=error)
        cdbLoader.conn.rollback()    

def fetch_list_qgis_pkg_usrgroup_members(cdbLoader: CDBLoader) -> tuple:
    """SQL function that retrieves the members of the database group "qgis_usrgroup"

    *   :returns: A list with user members of group "qgis_usrgroup"
        :rtype: tuple(str)
    """
    try:
        with cdbLoader.conn.cursor() as cur:
            cur.callproc(f"""{cdbLoader.QGIS_PKG_SCHEMA}.list_qgis_pkg_usrgroup_members""", [])
            users = cur.fetchall()
        users = tuple(zip(*users))[0] # trailing comma
        cdbLoader.conn.commit()
        return users

    except (Exception, psycopg2.Error) as error:
        gen_f.critical_log(
            func=fetch_list_qgis_pkg_usrgroup_members,
            location=FILE_LOCATION,
            header="Retrieving list of available users",
            error=error)
        cdbLoader.conn.rollback()
  
def exec_create_qgis_usr_schema(cdbLoader: CDBLoader) -> None:
    """Calls the qgis_pkg function that creates the {usr_schema} for a selected user.
    """
    user: str = cdbLoader.admin_dlg.cbxUser.currentText()
    
    try:
        with cdbLoader.conn.cursor() as cur:
            # Execute server function to create the qgis_{usr} schema
            cur.callproc(f"""{cdbLoader.QGIS_PKG_SCHEMA}.create_qgis_usr_schema""",[user])
        cdbLoader.conn.commit()

    except (Exception, psycopg2.Error) as error:
        gen_f.critical_log(
            func=exec_create_qgis_usr_schema,
            location=FILE_LOCATION,
            header=f"Creating user schema for {user}",
            error=error)
        cdbLoader.conn.rollback()

def exec_revoke_qgis_usr_privileges(cdbLoader: CDBLoader, usr_name: str, cdb_schema: str) -> None:
    """Calls the qgis_pkg function that revokes the user privileges.
    """
    try:
        with cdbLoader.conn.cursor() as cur:
            # Revoke user privileges
            cur.callproc(f"""{cdbLoader.QGIS_PKG_SCHEMA}.revoke_qgis_usr_privileges""",[usr_name, cdb_schema])
        cdbLoader.conn.commit()

    except (Exception, psycopg2.Error) as error:
        gen_f.critical_log(
            func=exec_revoke_qgis_usr_privileges,
            location=FILE_LOCATION,
            header=f"Revoking privileges of user {usr_name} for schema {cdb_schema}.",
            error=error)
        cdbLoader.conn.rollback()

def exec_drop_db_schema(cdbLoader: CDBLoader, schema: str, close_connection: bool = True) -> None:
    """SQL query that drops plugin packages from the database.
    As the plugin cannot function without its package, the function
    also closes the connection.

    *   :param schema: The package (schema) to drop (e.g. qgis_pkg)
        :type schema: str

    *   :param close_connection: After dropping the plugin package,
            it is not possible to work with the plugin, so the default
            state is True.
        :type close_connection: bool
    """
    try:
        with cdbLoader.conn.cursor() as cur:
            cur.execute(f"""DROP SCHEMA IF EXISTS "{schema}" CASCADE;""")
        cdbLoader.conn.commit()

        if close_connection:
            cdbLoader.conn.close()

    except (Exception, psycopg2.Error) as error:
        gen_f.critical_log(
            func=exec_drop_db_schema,
            location=FILE_LOCATION,
            header="Dropping schema {schema} from current database",
            error=error)
        cdbLoader.conn.rollback()
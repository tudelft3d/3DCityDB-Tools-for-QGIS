"""This module contains functions that relate to the server side
operations.

These functions are responsible to communicate and fetch data from
the database with sql queries or sql function calls.
"""

#from qgis.core import QgsMessageLog, Qgis

import psycopg2

from ....cdb_loader import CDBLoader # Used only to add the type of the function parameters

from ... import cdb4_constants as c

FILE_LOCATION = c.get_file_relative_path(file=__file__)

def is_3dcitydb_installed(cdbLoader: CDBLoader) -> bool:
    """Function that checks whether the current database has the 
    3DCityDB installed. The check is done by querying the 3DCityDB
    version from citydb_pkg.version(). The version is stored
    in 'citydb_version' attribute of the Connection object.

    On 3DCityDB absence a database error is emitted which means that
    it is not installed.

    Note for future 3DCityDB versions: this function MUST be updated
    for every change in the above mentioned 3DCitydb function's name
    or schema.
    """

    # Get 3DCityDB version
    version = fetch_3dcitydb_version(cdbLoader)

    if version: # Could be None
        # Store version into the connection object.
        cdbLoader.DB.citydb_version = version
        return True
    return False

def fetch_3dcitydb_version(cdbLoader: CDBLoader) -> str:
    """SQL query that reads and retrieves the 3DCityDB version.
    *   :returns: 3DCityDB version.

        :rtype: str
    """
    try:
        with cdbLoader.conn.cursor() as cur:
            cur.execute(query="""
                                SELECT version
                                FROM citydb_pkg.citydb_version();
                                """)
            version = cur.fetchone()[0] # Tuple has trailing comma.
        cdbLoader.conn.commit()
        return version

    except (Exception, psycopg2.Error) as error:
        # Send error to QGIS Message Log panel.
        c.critical_log(
            func=fetch_3dcitydb_version,
            location=FILE_LOCATION,
            header="Retrieving 3DCityDB version",
            error=error)
        cdbLoader.conn.rollback()

def is_superuser(cdbLoader: CDBLoader) -> bool:
    """SQL query that determines whether the connecting user
    has administrations privileges.
    *   :returns: Admin status

        :rtype: bool
    """
    try:
        with cdbLoader.conn.cursor() as cur:
            cur.execute(query= f"""
                                SELECT 1 FROM pg_user 
                                WHERE usesuper IS TRUE 
                                AND usename = '{cdbLoader.DB.username}';
                                """)
            result_bool = cur.fetchone() # as (1,) or None
        cdbLoader.conn.commit()
        if result_bool:
            return result_bool[0]
        return None

    except (Exception, psycopg2.Error) as error:
        # Send error to QGIS Message Log panel.
        print(error)
        c.critical_log(
            func=is_superuser,
            location=FILE_LOCATION,
            header=f"Checking whether user is a database superuser",
            error=error)
        cdbLoader.conn.rollback()    

def fetch_qgis_pkg_version(cdbLoader: CDBLoader) -> str:
    """SQL function that reads and retrieves the qgis_pkg version

    *   :returns: The qgis_pkg version.

        :rtype: str
    """
    try:
        with cdbLoader.conn.cursor() as cur:
            #Get all schemas
            cur.callproc(f"{cdbLoader.QGIS_PKG_SCHEMA}.qgis_pkg_version", [])
            full_version = cur.fetchone()[0]
        cdbLoader.conn.commit()
        return full_version

    except (Exception, psycopg2.Error) as error:
        # Send error to QGIS Message Log panel.
        c.critical_log(
            func=fetch_qgis_pkg_version,
            location=FILE_LOCATION,
            header=f"Retrieving {cdbLoader.QGIS_PKG_SCHEMA} version",
            error=error)
        cdbLoader.conn.rollback()

def fetch_list_cdb_schemas(cdbLoader: CDBLoader, not_empty=True) -> tuple:
    """SQL function that reads and retrieves the database
    cdb_schemas

    *   :returns: A list with all cdb_schemas in the database

        :rtype: list(str)
    """
    try:
        with cdbLoader.conn.cursor() as cur:
            #Get all schemas
            cur.callproc(f"{cdbLoader.QGIS_PKG_SCHEMA}.list_cdb_schemas", [not_empty])
            schemas = cur.fetchall()
        schemas = tuple(zip(*schemas))[0] # trailing comma
        cdbLoader.conn.commit()
        return schemas

    except (Exception, psycopg2.Error) as error:
        # Send error to QGIS Message Log panel.
        c.critical_log(
            func=fetch_list_cdb_schemas,
            location=FILE_LOCATION,
            header="Retrieving list of available cdb_schemas",
            error=error)
        cdbLoader.conn.rollback()
    
def fetch_list_qgis_pkg_usrgroup_members(cdbLoader: CDBLoader) -> tuple:
    """SQL function that retrieves the members of the database 
    group "qgis_usrgroup"

    *   :returns: A list with user members of group "qgis_usrgroup"

        :rtype: list(str)
    """
    try:
        with cdbLoader.conn.cursor() as cur:
            #Get all schemas
            cur.callproc(f"{cdbLoader.QGIS_PKG_SCHEMA}.list_qgis_pkg_usrgroup_members", [])
            users = cur.fetchall()
        users = tuple(zip(*users))[0] # trailing comma
        cdbLoader.conn.commit()
        return users

    except (Exception, psycopg2.Error) as error:
        # Send error to QGIS Message Log panel.
        c.critical_log(
            func=fetch_list_qgis_pkg_usrgroup_members,
            location=FILE_LOCATION,
            header="Retrieving list of available users",
            error=error)
        cdbLoader.conn.rollback()

def fetch_list_usr_schemas(cdbLoader: CDBLoader) -> tuple:
    """SQL function that retrieves the database usr_schemas

    *   :returns: A list with all usr_schemas in the database

        :rtype: list(str)
    """
    try:
        with cdbLoader.conn.cursor() as cur:
            cur.callproc(f"{cdbLoader.QGIS_PKG_SCHEMA}.list_usr_schemas",[])
            schemas = cur.fetchall()
        schemas = tuple(zip(*schemas))[0] # trailing comma
        cdbLoader.conn.commit()
        return schemas

    except (Exception, psycopg2.Error) as error:
        # Send error to QGIS Message Log panel.
        c.critical_log(
            func=fetch_list_usr_schemas,
            location=FILE_LOCATION,
            header="Retrieving list of usr_schemas",
            error=error)
        cdbLoader.conn.rollback()
  
def exec_create_qgis_usr_schema(cdbLoader: CDBLoader) -> None:
    """Calls the qgis_pkg function that creates the {usr_schema} for a selected user."""

    user = cdbLoader.admin_dlg.cbxUser.currentText()
    
    try:
        with cdbLoader.conn.cursor() as cur:
            # Execute server function to create the {usr_schema}
            cur.callproc(f"{cdbLoader.QGIS_PKG_SCHEMA}.create_qgis_usr_schema",[user])
        cdbLoader.conn.commit()

    except (Exception, psycopg2.Error) as error:
        # Send error to QGIS Message Log panel.
        c.critical_log(
            func=exec_create_qgis_usr_schema,
            location=FILE_LOCATION,
            header=f"Creating user schema for {user}",
            error=error)
        cdbLoader.conn.rollback()

def exec_create_qgis_usr_schema_name(cdbLoader: CDBLoader, usr_name: str = None) -> None:
    """Calls the qgis_pkg function that derives the name of the usr_schema from the usr_name."""

    if usr_name is None:
        usr_name = cdbLoader.DB.username

    try:
        with cdbLoader.conn.cursor() as cur:
            # Execute server function to compute the schema's extents
            cur.callproc(f"{cdbLoader.QGIS_PKG_SCHEMA}.create_qgis_usr_schema_name",[usr_name])
            usr_schema = cur.fetchone()[0] # Trailing comma
        cdbLoader.USR_SCHEMA = usr_schema
        cdbLoader.conn.commit()
        return usr_schema

    except (Exception, psycopg2.Error) as error:
        # Send error to QGIS Message Log panel.
        c.critical_log(
            func=exec_create_qgis_usr_schema_name,
            location=FILE_LOCATION,
            header=f"Deriving user schema name for user {usr_name}",
            error=error)
        cdbLoader.conn.rollback()

def exec_revoke_qgis_usr_privileges(cdbLoader: CDBLoader, usr_name, cdb_schema) -> None:
    """Calls the qgis_pkg function that revokes the user privileges."""

    try:
        with cdbLoader.conn.cursor() as cur:
            # Revoke user privileges
            cur.callproc(f"{cdbLoader.QGIS_PKG_SCHEMA}.revoke_qgis_usr_privileges",[usr_name, cdb_schema])
        cdbLoader.conn.commit()

    except (Exception, psycopg2.Error) as error:
        # Send error to QGIS Message Log panel.
        c.critical_log(
            func=exec_revoke_qgis_usr_privileges,
            location=FILE_LOCATION,
            header=f"Revoking privileges of user {usr_name} for schema {cdb_schema}.",
            error=error)
        cdbLoader.conn.rollback()

def is_qgis_pkg_intalled(cdbLoader: CDBLoader) -> bool:
    """SQL query that searches for schema 'qgis_pkg' in the current database

    *   :returns: Search result

        :rtype: bool
    """

    try:
        # Create cursor.
        with cdbLoader.conn.cursor() as cur:
            # Search for qgis_pkg schema
            cur.execute(query=f"""
                                SELECT schema_name 
                                FROM information_schema.schemata 
	                            WHERE schema_name = '{cdbLoader.QGIS_PKG_SCHEMA}';
                                """)
            pkg_name = cur.fetchone()
        cdbLoader.conn.commit()

        if pkg_name:
            return True
        return False

    except (Exception, psycopg2.Error) as error:
        # Send error to QGIS Message Log panel.
        c.critical_log(
            func=is_qgis_pkg_intalled,
            location=FILE_LOCATION,
            header=f"Searching for schema {cdbLoader.QGIS_PKG_SCHEMA} in current database",
            error=error)
        cdbLoader.conn.rollback()

def is_usr_pkg_installed(cdbLoader: CDBLoader) -> bool:
    """SQL query that searches for user package in the database
    'qgis_user'.

    *   :returns: Search result

        :rtype: bool
    """

    try:
        with cdbLoader.conn.cursor() as cur:
            # Get package name from database
            cur.execute(query=f"""
                                SELECT schema_name 
                                FROM information_schema.schemata 
	                            WHERE schema_name = '{cdbLoader.USR_SCHEMA}';
                                """)
            pkg_name = cur.fetchone()
        cdbLoader.conn.commit()
        if pkg_name:
            return True
        return False

    except (Exception, psycopg2.Error) as error:
        # Send error to QGIS Message Log panel.
        c.critical_log(
            func=is_usr_pkg_installed,
            location=FILE_LOCATION,
            header="Searching for user package",
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
        # Send error to QGIS Message Log panel.
        c.critical_log(
            func=exec_drop_db_schema,
            location=FILE_LOCATION,
            header="Dropping schema {schema} from current database",
            error=error)
        cdbLoader.conn.rollback()


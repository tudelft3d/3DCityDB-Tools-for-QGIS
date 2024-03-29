"""This module contains functions that relate to the server side operations.
They communicate and fetch data from the database with sql queries or sql function calls.
"""
from __future__ import annotations
from typing import TYPE_CHECKING, Optional, Literal, Union
if TYPE_CHECKING:       
    from ...gui_admin.admin_dialog import CDB4AdminDialog
    from ...shared.dataTypes import CDBSchemaPrivs, ListFeatureTypes, CDBPrivType

import psycopg2, psycopg2.sql as pysql
from psycopg2.extras import NamedTupleCursor

from ...shared.functions import general_functions as gen_f
from ...shared.functions import sql as sh_sql

FILE_LOCATION = gen_f.get_file_relative_path(file=__file__)

def is_superuser(dlg: CDB4AdminDialog, usr_name: str) -> bool:
    """SQL query that determines whether the connecting user has administrations privileges.

    *   :returns: Admin status
        :rtype: bool
    """
    # Think whether you can use the function in the qgis_pkg or not, 
    # because we may not have installed the qgis_pkg yet.
    # This one does not depend on the qgis_pkg
    
    query = pysql.SQL("""
        SELECT 1 FROM pg_user WHERE usesuper IS TRUE AND usename = {_usr_name};
        """).format(
        _usr_name = pysql.Literal(usr_name)
        )

    try:
        with dlg.conn.cursor() as cur:
            cur.execute(query)
            res = cur.fetchone() # returns (1,) or None
        dlg.conn.commit()

        if res:
            return True
        else:
            return False

    except (Exception, psycopg2.Error) as error:
        gen_f.critical_log(
            func=is_superuser,
            location=FILE_LOCATION,
            header=f"Checking whether the current user '{usr_name}' is a database superuser",
            error=error)
        dlg.conn.rollback()  


def create_qgis_pkg_usrgroup_name(dlg: CDB4AdminDialog) -> str:
    """SQL function that retrieves the name of the qgis_pkg_usrgroup_* group
    associated to the current database

    *   :returns: The name of the group
        :rtype: str
    """
    query = pysql.SQL("""
        SELECT * FROM {_qgis_pkg_schema}.create_qgis_pkg_usrgroup_name();
        """).format(
        _qgis_pkg_schema = pysql.Identifier(dlg.QGIS_PKG_SCHEMA),
        )

    try:
        with dlg.conn.cursor() as cur:
            cur.execute(query)
            grp_name = cur.fetchone()[0] # without [0] returns ("grp_name",) or None
        dlg.conn.commit()

        # Asign the value to the variable in the plugin
        dlg.GROUP_NAME = grp_name
        # print('Group name (assigned):', dlg.GROUP_NAME)
        return grp_name

    except (Exception, psycopg2.Error) as error:
        gen_f.critical_log(
            func=create_qgis_pkg_usrgroup_name,
            location=FILE_LOCATION,
            header="Retrieving the name of the qgis_pkg_usrgroup_*",
            error=error)
        dlg.conn.rollback()


def list_usr_schemas(dlg: CDB4AdminDialog) -> Union[tuple[str, ...], tuple[()]]:
    """SQL function that retrieves the database usr_schemas

    *   :returns: A tuple with all usr_schemas in the database
        :rtype: Union[tuple[str, ...], tuple[()]]
    """
    query = pysql.SQL("""
        SELECT * FROM {_qgis_pkg_schema}.list_usr_schemas();
        """).format(
        _qgis_pkg_schema = pysql.Identifier(dlg.QGIS_PKG_SCHEMA),
        )

    try:
        with dlg.conn.cursor() as cur:
            cur.execute(query)
            res = cur.fetchall() # [("schema1",), ("schema2",), ...]
        dlg.conn.commit()

        if res:
            usr_schemas: tuple[str, ...]
            usr_schemas = tuple(zip(*res))[0]
            # Alternatively
            # schemas = tuple(elem[0] for elem in cast(Iterable[tuple[str, ...]], res))
        else:
            usr_schemas = ()

    except (Exception, psycopg2.Error) as error:
        gen_f.critical_log(
            func=list_usr_schemas,
            location=FILE_LOCATION,
            header="Retrieving list of usr_schemas",
            error=error)
        dlg.conn.rollback()
        usr_schemas = () # create an empty tuple

    return usr_schemas

def list_all_cdb_schemas(dlg: CDB4AdminDialog) -> Union[tuple[str, ...], tuple[()]]:
    """SQL function that reads and retrieves all cdb_schemas, also the empty ones,

    *   :returns: Tuple of cdb_schemas
        :rtype: tuple[str, ...]
    """
    query = pysql.SQL("""
            SELECT cdb_schema FROM {_qgis_pkg_schema}.list_cdb_schemas(only_non_empty := False);
            """).format(
            _qgis_pkg_schema = pysql.Identifier(dlg.QGIS_PKG_SCHEMA)
            )

    try:
        with dlg.conn.cursor() as cur:
            cur.execute(query)
            res = cur.fetchall()
        dlg.conn.commit()

        if res:
            cdb_schemas: tuple[str, ...]
            cdb_schemas = tuple(zip(*res))[0] # trailing comma
        else:
            cdb_schemas = ()

    except (Exception, psycopg2.Error) as error:
        gen_f.critical_log(
            func=list_all_cdb_schemas,
            location=FILE_LOCATION,
            header="No citydb schema could be retrieved from the database.",
            error=error)
        dlg.conn.rollback()
        cdb_schemas = () # create an empty tuple

    return cdb_schemas


def list_cdb_schemas_privs(dlg: CDB4AdminDialog, usr_name: str) -> list[CDBSchemaPrivs]:
    """SQL function that retrieves the database cdb_schemas for the current database, 
    included the privileges status for the selected usr_name

    *   :returns: A list of named tuples with all usr_schemas, the number of available cityobecjts, 
         and the user's privileges for each cdb_schema in the current database
        :rtype: list[tuple(cdb_schema, is_empty, priv_type)]
    """
    query = pysql.SQL("""
        SELECT cdb_schema, is_empty, priv_type FROM {_qgis_pkg_schema}.list_cdb_schemas_privs({_usr_name});
        """).format(
        _qgis_pkg_schema = pysql.Identifier(dlg.QGIS_PKG_SCHEMA),
        _usr_name = pysql.Literal(usr_name)
        )

    try:
        with dlg.conn.cursor(cursor_factory=NamedTupleCursor) as cur:
            cur.execute(query)
            res = cur.fetchall()
        dlg.conn.commit()

        # print('from database:', res)

        if not res:
            res = []

        return res
    
    except (Exception, psycopg2.Error) as error:
        gen_f.critical_log(
            func=list_cdb_schemas_privs,
            location=FILE_LOCATION,
            header="Retrieving list of cdb_schemas with their privileges",
            error=error)
        dlg.conn.rollback()

      
def list_qgis_pkg_usrgroup_members(dlg: CDB4AdminDialog) -> Union[tuple[str, ...], tuple[()]]:
    """SQL function that retrieves the members of the database group "qgis_usrgroup"

    *   :returns: A tuple with user members of group "qgis_usrgroup"
        :rtype: Union[tuple[str, ...], tuple[()]]
    """
    query = pysql.SQL("""
        SELECT * FROM {_qgis_pkg_schema}.list_qgis_pkg_usrgroup_members();
        """).format(
        _qgis_pkg_schema = pysql.Identifier(dlg.QGIS_PKG_SCHEMA)
        )

    try:
        with dlg.conn.cursor() as cur:
            cur.execute(query)
            res = cur.fetchall()
        dlg.conn.commit()

        if not res:
            usr_names = ()
        else:
            usr_names: tuple[str, ...]
            usr_names = tuple(zip(*res))[0]

        return usr_names

    except (Exception, psycopg2.Error) as error:
        gen_f.critical_log(
            func=list_qgis_pkg_usrgroup_members,
            location=FILE_LOCATION,
            header="Retrieving list of available users",
            error=error)
        dlg.conn.rollback()


def list_qgis_pkg_non_usrgroup_members(dlg: CDB4AdminDialog) -> Union[tuple[str, ...], tuple[()]]:
    """SQL function that retrieves the members of the database
    that do not belong to the group "qgis_usrgroup"

    *   :returns: A tuple with usr_names
        :rtype: tuple[str, ...]
    """
    query = pysql.SQL("""
        SELECT * FROM {_qgis_pkg_schema}.list_qgis_pkg_non_usrgroup_members();
        """).format(
        _qgis_pkg_schema = pysql.Identifier(dlg.QGIS_PKG_SCHEMA)
        )

    try:
        with dlg.conn.cursor() as cur:
            cur.execute(query)
            res = cur.fetchall()
        dlg.conn.commit()

        # print('Result from list NON group members()', res)

        if not res:
            usr_names = ()
        else:
            usr_names: tuple[str, ...]
            usr_names = tuple(zip(*res))[0]
            # usr_names = tuple(elem[0] for elem in cast(Iterable[tuple[str]], res))
        
        return usr_names

    except (Exception, psycopg2.Error) as error:
        gen_f.critical_log(
            func=list_qgis_pkg_non_usrgroup_members,
            location=FILE_LOCATION,
            header="Retrieving list of available users",
            error=error)
        dlg.conn.rollback()


def add_user_to_qgis_pkg_usrgroup(dlg: CDB4AdminDialog, usr_name: str) -> None:
    """SQL function that add the user to database group "qgis_usrgroup"
    """
    query = pysql.SQL("""
	    SELECT {_qgis_pkg_schema}.add_user_to_qgis_pkg_usrgroup({_usr_name});
        """).format(
        _qgis_pkg_schema = pysql.Identifier(dlg.QGIS_PKG_SCHEMA),
        _usr_name = pysql.Literal(usr_name)
        )

    try:
        with dlg.conn.cursor() as cur:
            cur.execute(query)
        dlg.conn.commit()
        return None

    except (Exception, psycopg2.Error) as error:
        gen_f.critical_log(
            func=add_user_to_qgis_pkg_usrgroup,
            location=FILE_LOCATION,
            header=f"Adding '{usr_name}' to the 'qgis_pkg_usrgroup_*' corresponding to the current database",
            error=error)
        dlg.conn.rollback()


def remove_user_from_qgis_pkg_usrgroup(dlg: CDB4AdminDialog, usr_name: str) -> None:
    """SQL function that add the user to database group "qgis_usrgroup"
    """
    query = pysql.SQL("""
	    SELECT {_qgis_pkg_schema}.remove_user_from_qgis_pkg_usrgroup({_usr_name});
        """).format(
        _qgis_pkg_schema = pysql.Identifier(dlg.QGIS_PKG_SCHEMA),
        _usr_name = pysql.Literal(usr_name)
        )

    try:
        with dlg.conn.cursor() as cur:
            cur.execute(query)
        dlg.conn.commit()
        return None

    except (Exception, psycopg2.Error) as error:
        gen_f.critical_log(
            func=remove_user_from_qgis_pkg_usrgroup,
            location=FILE_LOCATION,
            header=f"Removing user '{usr_name}' from group '{dlg.GROUP_NAME}'",
            error=error)
        dlg.conn.rollback()


def create_qgis_usr_schema(dlg: CDB4AdminDialog) -> None:
    """Calls the qgis_pkg function that creates the {usr_schema} for a selected user.
    """
    usr_name = dlg.cbxUser.currentText()
    # Prepare the query to create the qgis_{usr} schema
    query = pysql.SQL("""
        SELECT {_qgis_pkg_schema}.create_qgis_usr_schema({_usr_name});
        """).format(
        _qgis_pkg_schema = pysql.Identifier(dlg.QGIS_PKG_SCHEMA),
        _usr_name = pysql.Literal(usr_name)
        )

    try:
        with dlg.conn.cursor() as cur:
            cur.execute(query)
        dlg.conn.commit()

    except (Exception, psycopg2.Error) as error:
        gen_f.critical_log(
            func=create_qgis_usr_schema,
            location=FILE_LOCATION,
            header=f"Creating user schema for {usr_name}",
            error=error)
        dlg.conn.rollback()


def revoke_qgis_usr_privileges(dlg: CDB4AdminDialog, usr_name: str, cdb_schemas: Optional[list[str]] = None) -> None:
    """Calls the qgis_pkg function that revokes the user privileges.
    
    - priv_type: str MUST be either 'rw' or 'ro'
    - cdb_schemas: is a list[str] with one or more cdb_schemas, or None, which stands for ALL existing ones
    """
    query = pysql.SQL("""
        SELECT {_qgis_pkg_schema}.revoke_qgis_usr_privileges(usr_name := {_usr_name}, cdb_schemas := {_cdb_schemas});
        """).format(
        _qgis_pkg_schema = pysql.Identifier(dlg.QGIS_PKG_SCHEMA),
        _usr_name = pysql.Literal(usr_name),
        _cdb_schemas = pysql.Literal(cdb_schemas)
        )

    try:
        with dlg.conn.cursor() as cur:
            cur.execute(query)
        dlg.conn.commit()

    except (Exception, psycopg2.Error) as error:
        if not cdb_schemas:
            msg: str = f"Revoking privileges of ALL cdb_schemas from user '{usr_name}'"
        else:
            msg: str = f"Revoking privileges of cdb_schemas {cdb_schemas} from user '{usr_name}'"
        gen_f.critical_log(
            func=revoke_qgis_usr_privileges,
            location=FILE_LOCATION,
            header=msg,
            error=error)
        dlg.conn.rollback()


def grant_qgis_usr_privileges(dlg: CDB4AdminDialog, 
                              usr_name: str, 
                              priv_type: Literal[CDBPrivType.READ_ONLY, CDBPrivType.READ_WRITE], 
                              cdb_schemas: Optional[list[str]] = None
                              ) -> None:
    """Calls the qgis_pkg function that grants the user privileges.

    - priv_type: Literal[CDBPrivType.READ_ONLY, CDBPrivType.READ_WRITE] (i.e. must be either 'ro' or 'rw')
    - cdb_schemas: is a list[str] with one or more cdb_schemas, or None, which stands for ALL existing ones
    """

    # Get the value associated to the enumeration member
    priv_type_value = priv_type.value

    query = pysql.SQL("""
        SELECT {_qgis_pkg_schema}.grant_qgis_usr_privileges(usr_name:= {_usr_name}, priv_type := {_priv_type}, cdb_schemas := {_cdb_schemas});
        """).format(
        _qgis_pkg_schema = pysql.Identifier(dlg.QGIS_PKG_SCHEMA),
        _usr_name = pysql.Literal(usr_name),
        _priv_type = pysql.Literal(priv_type_value),
        _cdb_schemas = pysql.Literal(cdb_schemas)
        )

    try:
        with dlg.conn.cursor() as cur:
            cur.execute(query)
        dlg.conn.commit()

    except (Exception, psycopg2.Error) as error:
        if not cdb_schemas:
            msg: str = f"Granting privileges to user '{usr_name}' for ALL cdb_schemas"
        else:
            msg: str = f"Granting privileges to user '{usr_name}' for cdb_schemas: {cdb_schemas}"
        gen_f.critical_log(
            func=grant_qgis_usr_privileges,
            location=FILE_LOCATION,
            header=msg,
            error=error)
        dlg.conn.rollback()


def drop_db_schema(dlg: CDB4AdminDialog, schema: str, close_connection: bool = True) -> None:
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
    query = pysql.SQL("""
        DROP SCHEMA IF EXISTS {_schema} CASCADE;
        """).format(
        _schema = pysql.Identifier(schema)
        )

    try:
        with dlg.conn.cursor() as cur:
            cur.execute(query)
        dlg.conn.commit()

        if close_connection:
            dlg.conn.close()

    except (Exception, psycopg2.Error) as error:
        gen_f.critical_log(
            func=drop_db_schema,
            location=FILE_LOCATION,
            header=f"Dropping schema {schema} from current database",
            error=error)
        dlg.conn.rollback()


def list_feature_types(dlg: CDB4AdminDialog, usr_schema: Optional[str] = None) -> list[ListFeatureTypes]:
    """SQL query that retrieves available feature types from table qgis_{usr}.layer_metadata,
    either for all existing usr_schemas, or only for the one in the parameter.
    
    *   :returns: list of (Named)tuples containing the name of the usr_schema, cdb_schema, feature type.
        :rtype: list[ListFeatureType], NamedTuple, i.e. list[tuple[str, str, str]]
    """
    query = pysql.SQL("""
        SELECT * FROM {_qgis_pkg_schema}.list_feature_types({_usr_schema});
        """).format(
        _qgis_pkg_schema = pysql.Identifier(dlg.QGIS_PKG_SCHEMA),
        _usr_schema = pysql.Literal(usr_schema)
        )

    try:
        with dlg.conn.cursor(cursor_factory=NamedTupleCursor) as cur:
            cur.execute(query)
            res = cur.fetchall()
        dlg.conn.commit()

        if not res:
            return []
        else:
            return res

    except (Exception, psycopg2.Error) as error:
        gen_f.critical_log(
            func=list_feature_types,
            location=FILE_LOCATION,
            header=f"Retrieving unique cdb_schemas and Feature Types in {dlg.USR_SCHEMA}.layer_metadata",
            error=error)
        dlg.conn.rollback()
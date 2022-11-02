"""This module contains functions that relate to the server side
operations.

These functions are responsible to communicate and fetch data from
the database with sql queries or sql function calls.
"""


from qgis.core import Qgis,QgsMessageLog

import psycopg2

from ....cdb_loader import CDBLoader # Used only to add the type of the function parameters

from .... import main_constants as main_c
from ... import cdb4_constants as c

FILE_LOCATION = c.get_file_relative_path(file=__file__)

def fetch_server_version(cdbLoader: CDBLoader) -> str:
    """SQL query that reads and retrieves the server version.
    *   :returns: Server version.

        :rtype: str
    """
    try:
         # Create cursor.
        with cdbLoader.conn.cursor() as cur:
            # Get server to fetch its version
            cur.execute(query="SHOW server_version;")
            version = cur.fetchone()[0] # Tuple has trailing comma.
        cdbLoader.conn.commit()
        return version

    except (Exception, psycopg2.Error) as error:
        # Send error to QGIS Message Log panel.
        c.critical_log(
            func=fetch_server_version,
            location=FILE_LOCATION,
            header="Retrieving PostgreSQL server version",
            error=error)
        cdbLoader.conn.rollback()


def fetch_3dcitydb_version(cdbLoader: CDBLoader) -> str:
    """SQL query that reads and retrieves the 3DCityDB version.
    *   :returns: 3DCityDB version.

        :rtype: str
    """
    try:
        with cdbLoader.conn.cursor() as cur:
            cur.execute(query="""
                                SELECT version FROM citydb_pkg.citydb_version();
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


def fetch_extents(cdbLoader: CDBLoader, usr_schema: str, cdb_schema: str, ext_type: str) -> str:
    """SQL query that reads and retrieves extents stored in {usr_schema}.extents
    *   :returns: Extents as WKT or None if the entry is empty.

        :rtype: str
    """
    try:
        # Create cursor.
        with cdbLoader.conn.cursor() as cur:
            # Get db_schema extents from server as WKT.
            cur.execute(query= f"""
                                SELECT ST_AsText(envelope) 
                                FROM "{usr_schema}".extents 
                                WHERE cdb_schema = '{cdb_schema}'
                                AND bbox_type = '{ext_type}';
                                """)
            extents = cur.fetchone()
            # extents = (None,) when the envelope is Null,
            # BUT extents = None when the query returns NO results.
            if type(extents) == tuple:
                extents=extents[0] # Get None without trailing comma.

        cdbLoader.conn.commit()
        return extents

    except (Exception, psycopg2.Error) as error:
        # Send error to QGIS Message Log panel.
        c.critical_log(
            func=fetch_extents,
            location=FILE_LOCATION,
            header="Retrieving extents",
            error=error)
        cdbLoader.conn.rollback()


def fetch_crs(cdbLoader: CDBLoader) -> int:
    """SQL query that reads and retrieves the current schema's srid from
    {cdb_schema}.database_srs
    *   :returns: srid number

        :rtype: int
    """
    try:
        with cdbLoader.conn.cursor() as cur:
            # Get database srid.
            cur.execute(query= f"""
                                SELECT srid 
                                FROM "{cdbLoader.CDB_SCHEMA}".database_srs 
                                LIMIT 1;
                                """)
            srid = cur.fetchone()[0] # Tuple has trailing comma.
        cdbLoader.conn.commit()
        return srid

    except (Exception, psycopg2.Error) as error:
        # Send error to QGIS Message Log panel.
        c.critical_log(
            func=fetch_crs,
            location=FILE_LOCATION,
            header="Retrieving srid",
            error=error)
        cdbLoader.conn.rollback()
 

def exec_qgis_pkg_version(cdbLoader: CDBLoader) -> str:
    """SQL function that reads and retrieves the qgis_pkg version

    *   :returns: The qgis_pkg version.

        :rtype: str
    """
    try:
        with cdbLoader.conn.cursor() as cur:
            #Get all schemas
            cur.callproc(f"{main_c.QGIS_PKG_SCHEMA}.qgis_pkg_version", [])
            full_version = cur.fetchone()[0]
        cdbLoader.conn.commit()
        return full_version

    except (Exception, psycopg2.Error) as error:
        # Send error to QGIS Message Log panel.
        c.critical_log(
            func=exec_qgis_pkg_version,
            location=FILE_LOCATION,
            header=f"Retrieving {main_c.QGIS_PKG_SCHEMA} version",
            error=error)
        cdbLoader.conn.rollback()

def exec_list_cdb_schemas_all(cdbLoader: CDBLoader) -> tuple:
    """SQL function that reads and retrieves all cdb_schemas, even the empty ones

    *   :returns: A list with all cdb_schemas in the database

        :rtype: list(str)
    """
    try:
        with cdbLoader.conn.cursor() as cur:
            #Get all schemas
            cur.callproc(f"{main_c.QGIS_PKG_SCHEMA}.list_cdb_schemas_new", [False])
            result = cur.fetchall()
        cdbLoader.conn.commit()
        schema_names = tuple(zip(*result))[0] # trailing comma
        schema_nums = tuple(zip(*result))[1] # trailing comma        

    except (Exception, psycopg2.Error):
        # Send warning to QGIS Message Log panel.
        QgsMessageLog.logMessage(f"No citydb schemas could be retrieved from the database.","3DCityDB-Loader", level=Qgis.Warning)
        cdbLoader.conn.rollback()
        schema_names = tuple()
        schema_nums = tuple()

    return schema_names, schema_nums


def exec_list_qgis_pkg_usrgroup_members(cdbLoader: CDBLoader) -> tuple:
    """SQL function that retrieves the members of the database 
    group "qgis_usrgroup"

    *   :returns: A list with user members of group "qgis_usrgroup"

        :rtype: list(str)
    """
    try:
        with cdbLoader.conn.cursor() as cur:
            #Get all schemas
            cur.callproc(f"{main_c.QGIS_PKG_SCHEMA}.list_qgis_pkg_usrgroup_members", [])
            users = cur.fetchall()
        users = tuple(zip(*users))[0] # trailing comma
        cdbLoader.conn.commit()
        return users

    except (Exception, psycopg2.Error) as error:
        # Send error to QGIS Message Log panel.
        c.critical_log(
            func=exec_list_qgis_pkg_usrgroup_members,
            location=FILE_LOCATION,
            header="Retrieving list of available users",
            error=error)
        cdbLoader.conn.rollback()


def exec_list_usr_schemas(cdbLoader: CDBLoader) -> tuple:
    """SQL function that retrieves the database usr_schemas

    *   :returns: A list with all usr_schemas in the database

        :rtype: list(str)
    """
    try:
        with cdbLoader.conn.cursor() as cur:
            cur.callproc(f"{main_c.QGIS_PKG_SCHEMA}.list_usr_schemas",[])
            schemas = cur.fetchall()
        schemas = tuple(zip(*schemas))[0] # trailing comma
        cdbLoader.conn.commit()
        return schemas

    except (Exception, psycopg2.Error) as error:
        # Send error to QGIS Message Log panel.
        c.critical_log(
            func=exec_list_usr_schemas,
            location=FILE_LOCATION,
            header="Retrieving list of usr_schemas",
            error=error)
        cdbLoader.conn.rollback()


def fetch_layer_metadata(cdbLoader: CDBLoader, usr_schema: str, cdb_schema: str, cols="*") -> tuple:
    """SQL query that retrieves the current schema's layer metadata
    from {usr_schema}.layer_metadata table. By default it retrieves all columns.

    *   :param cols: The columns to retrieve from the table.
            Note: to fetch multiple columns use:
            ",".join([col1,col2,col3])
        :type cols: str

    *   :returns: metadata of the layers combined with a collection of
        the attributes names

        :rtype: tuple(attribute_names, metadata)
    """
    try:
        with cdbLoader.conn.cursor() as cur:
            cur.execute(f"""
                        SELECT {cols} FROM "{usr_schema}".layer_metadata
                        WHERE cdb_schema = '{cdb_schema}'
                        ORDER BY feature_type, lod, root_class, layer_name;
                        """)
            metadata = cur.fetchall()
            # Attribute names
            colnames = [desc[0] for desc in cur.description]
        cdbLoader.conn.commit()
        return colnames, metadata

    except (Exception, psycopg2.Error) as error:
        # Send error to QGIS Message Log panel.
        c.critical_log(
            func=fetch_layer_metadata,
            location=FILE_LOCATION,
            header="Retrieving layers metadata",
            error=error)
        cdbLoader.conn.rollback()


def fetch_lookup_tables(cdbLoader: CDBLoader) -> tuple:
    """SQL query that retrieves look-up tables from {usr_schema}.

    *   :returns: Look up tables names

        :rtype: tuple(str)
    """
    try:
        with cdbLoader.conn.cursor() as cur:
            #Get all existing look-up tables from database
            cur.execute(f"""
                        SELECT table_name,''
                        FROM information_schema.tables
                        WHERE table_schema = '{cdbLoader.USR_SCHEMA}'
						AND table_type = 'VIEW'
                        AND (table_name LIKE '%codelist%'
                        OR table_name LIKE '%enumeration%');
                        """)
            lookups=cur.fetchall()
        cdbLoader.conn.commit()
        lookups,empty=zip(*lookups)
        return lookups

    except (Exception, psycopg2.Error) as error:
        # Send error to QGIS Message Log panel.
        c.critical_log(
            func=fetch_lookup_tables,
            location=FILE_LOCATION,
            header="Retrieving look-up tables with enumerations and codelists",
            error=error)
        cdbLoader.conn.rollback()


def exec_compute_schema_extents(cdbLoader: CDBLoader) -> None:
    """Calls the qgis_pkg function that computes the schema extents.

    *   :returns: x_min, y_min, x_max, y_max, srid

        :rtype: tuple
    """
    try:
        with cdbLoader.conn.cursor() as cur:
            # Execute server function to compute the schema's extents
            cur.callproc(f"{main_c.QGIS_PKG_SCHEMA}.compute_schema_extents",[cdbLoader.USR_SCHEMA, cdbLoader.CDB_SCHEMA])
            x_min, y_min, x_max, y_max, srid, upserted_id = cur.fetchone()
        upserted_id = None # Not needed.
        cdbLoader.conn.commit()
        return x_min, y_min, x_max, y_max, srid

    except (Exception, psycopg2.Error) as error:
        # Send error to QGIS Message Log panel.
        c.critical_log(
            func=exec_compute_schema_extents,
            location=FILE_LOCATION,
            header="Computing extents of the selected cdb_schema",
            error=error)
        cdbLoader.conn.rollback()


def exec_view_counter(cdbLoader: CDBLoader, view: c.View) -> int:
    """Calls the qgis_pkg function that counts the number of
    geometry objects found within the selected extents.

    *   :returns: Number of objects.

        :rtype: int
    """

    try:
        # Convert QgsRectanlce into WKT polygon format
        extents = cdbLoader.CURRENT_EXTENTS.asWktPolygon()
        with cdbLoader.conn.cursor() as cur:
            # Execute server function to get the number of objects in extents.
            cur.callproc(f"{main_c.QGIS_PKG_SCHEMA}.view_counter",[
                cdbLoader.USR_SCHEMA, 
                cdbLoader.CDB_SCHEMA, 
                view.mv_name, 
                extents])
            count = cur.fetchone()[0] # Tuple has trailing comma.
        cdbLoader.conn.commit()

        # Assign the result to the view object.
        view.n_selected = count
        return count

    except (Exception, psycopg2.Error) as error:
        # Send error to QGIS Message Log panel.
        c.critical_log(
            func=exec_view_counter,
            location=FILE_LOCATION,
            header=f"Counting number of objects in view {view.mv_name}",
            error=error)
        cdbLoader.conn.rollback()


def exec_has_layers_for_cdbschema(cdbLoader: CDBLoader) -> bool:
    """Calls the qgis_pkg function that determines whether the {usr_schema} has views
    regarding the current {cdb_schema}.
    *   :returns: Support status

        :rtype: bool
    """
    try:
        with cdbLoader.conn.cursor() as cur:
            # Execute function to find if qgis_pkg supports current schema.
            cur.callproc(f"{main_c.QGIS_PKG_SCHEMA}.support_for_schema",[cdbLoader.USR_SCHEMA, cdbLoader.CDB_SCHEMA])
            result_bool = cur.fetchone()[0] # Tuple has trailing comma.
        cdbLoader.conn.commit()
        return result_bool

    except (Exception, psycopg2.Error) as error:
        # Send error to QGIS Message Log panel.
        c.critical_log(
            func=exec_has_layers_for_cdbschema,
            location=FILE_LOCATION,
            header="Checking support for schema",
            error=error)
        cdbLoader.conn.rollback()


def exec_upsert_extents(cdbLoader: CDBLoader, usr_schema: str, cdb_schema: str, bbox_type, extents) -> None:
    """
    TOfill
    """
    # Get corner coordinates
    # y_min = str(extents.yMinimum())
    # x_min = str(extents.xMinimum())
    # y_max = str(extents.yMaximum())
    # x_max = str(extents.xMaximum())
    # extents = "{"+",".join([x_min,y_min,x_max,y_max])+"}"

    try:
        with cdbLoader.conn.cursor() as cur:
            # Execute function to find if qgis_pkg supports current schema.
            cur.callproc(f"{main_c.QGIS_PKG_SCHEMA}.upsert_extents",[usr_schema, cdb_schema, bbox_type, extents])
        cdbLoader.conn.commit()

    except (Exception, psycopg2.Error) as error:
        # Send error to QGIS Message Log panel.
        c.critical_log(
            func=exec_upsert_extents,
            location=FILE_LOCATION,
            header=f"Upserting '{bbox_type}' extents",
            error=error)
        cdbLoader.conn.rollback()
   

def exec_create_qgis_usr_schema_name(cdbLoader: CDBLoader, usr_name: str = None) -> None:
    """Calls the qgis_pkg function that derives the name of the usr_schema from the usr_name."""

    if usr_name is None:
        usr_name = cdbLoader.DB.username

    try:
        with cdbLoader.conn.cursor() as cur:
            cur.callproc(f"{main_c.QGIS_PKG_SCHEMA}.create_qgis_usr_schema_name",[usr_name])
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


def fetch_mat_views(cdbLoader: CDBLoader) -> list:
    """SQL query that retrieves the current schema's
    materialised views from pg_matviews
    *   :returns: Materialized view dictionary with view name as keys and
            populated status as value.

        :rtype: dict{str,bool}
    """

    # NOTE: might need to set it as schema dependent.
    try:
        with cdbLoader.conn.cursor() as cur:
            # Select the views that are populated.
            cur.execute(query=f"""
                                SELECT matViewname, ispopulated 
                                FROM pg_matviews
                                WHERE schemaname = '{main_c.QGIS_PKG_SCHEMA}';
                                """)
            mat_views = cur.fetchall()
            mat_views, status = list(zip(*mat_views))
            mat_views = dict(zip(mat_views,status))
        cdbLoader.conn.commit()
        return mat_views

    except (Exception, psycopg2.Error) as error:
        # Send error to QGIS Message Log panel.
        c.critical_log(
            func=fetch_mat_views,
            location=FILE_LOCATION,
            header="Retrieving list of materialized views",
            error=error)
        cdbLoader.conn.rollback()


def refresh_mat_view(cdbLoader: CDBLoader, connection, m_view) -> None:
    """SQL query that refreshes a materialized view in {usr_schema}"""

    try:
        with connection.cursor() as cur:
            cur.execute(query=f"""REFRESH MATERIALIZED VIEW "{cdbLoader.USR_SCHEMA}"."{m_view}";""")
            cur.execute(query=f"""
                                UPDATE "{cdbLoader.USR_SCHEMA}".layer_metadata
                                SET refresh_date = clock_timestamp()
                                WHERE mv_name = '{m_view}';
                                """)
        cdbLoader.conn.commit()

    except (Exception, psycopg2.Error) as error:
        # Send error to QGIS Message Log panel.
        c.critical_log(
            func=refresh_mat_view,
            location=FILE_LOCATION,
            header=f"Refreshing materialized view {m_view} in schema {cdbLoader.USR_SCHEMA}",
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
	                            WHERE schema_name = '{main_c.QGIS_PKG_SCHEMA}';
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
            header=f"Searching for schema {main_c.QGIS_PKG_SCHEMA} in current database",
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
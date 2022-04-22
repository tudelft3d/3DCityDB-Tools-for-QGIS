"""This module contains functions that relate to the server side
operations.

These functions are responsible to communicate and fetch data from
the database with sql queries all sql function calls.
"""
#TODO: Catching error and logging code block seems too repretive,
# could probably set it as a function

import psycopg2

from .. import constants as c

FILE_LOCATION = c.get_file_location(file=__file__)

def fetch_server_version(dbLoader) -> str:
    """SQL query thar reads and retrieves the server's version.
    *   :returns: Server version.

        :rtype: str
    """
    try:
         # Create cursor.
        with dbLoader.conn.cursor() as cur:
            # Get server to fetch its version
            cur.execute(query="SHOW server_version;")
            version = cur.fetchone()[0] # Tuple has trailing comma.
        dbLoader.conn.commit()
        return version

    except (Exception, psycopg2.Error) as error:
        # Send error to QGIS Message Log panel.
        c.critical_log(func=fetch_server_version,
            location=FILE_LOCATION,
            header="Fetching server version",
            error=error)
        dbLoader.conn.rollback()

def fetch_3dcitydb_version(dbLoader) -> str:
    """SQL query thar reads and retrieves the 3DCityDB's version.
    *   :returns: 3DCityDB version.

        :rtype: str
    """
    try:
         # Create cursor.
        with dbLoader.conn.cursor() as cur:
            # Get server to fetch its version
            cur.execute(query="""
                                SELECT  version
                                FROM citydb_pkg.citydb_version();
                                """)
            version = cur.fetchone()[0] # Tuple has trailing comma.
        dbLoader.conn.commit()
        return version

    except (Exception, psycopg2.Error) as error:
        # Send error to QGIS Message Log panel.
        c.critical_log(func=fetch_3dcitydb_version,
            location=FILE_LOCATION,
            header="Fetching 3DCityDB version",
            error=error)
        dbLoader.conn.rollback()

def fetch_extents(dbLoader, from_schema: str, for_schema:str, ext_type: str) -> str:
    """SQL query thar reads and retrieves extents stored in qgis_pkg.extents
    *   :returns: Extents as WKT or None if the entry is empty.

        :rtype: str
    """
    try:
        # Create cursor.
        with dbLoader.conn.cursor() as cur:
            # Get db_schema extents from server as WKT.
            cur.execute(query= f"""
                                SELECT ST_AsText(envelope) 
                                FROM {from_schema}.extents 
                                WHERE cdb_schema = '{for_schema}'
                                AND bbox_type = '{ext_type}';
                                """)
            extents = cur.fetchone()
            # extents = (None,) when the envelope is Null,
            # BUT extents = None when the query returns NO results.
            if type(extents) == tuple:
                extents=extents[0] # Get None without trailing comma.

        dbLoader.conn.commit()
        return extents

    except (Exception, psycopg2.Error) as error:
        # Send error to QGIS Message Log panel.
        c.critical_log(func=fetch_extents,
            location=FILE_LOCATION,
            header="Fetching extents",
            error=error)
        dbLoader.conn.rollback()

def fetch_crs(dbLoader) -> int:
    """SQL query thar reads and retrieves the current schema's srid from
    {schema}.database_srs
    *   :returns: srid number

        :rtype: int
    """
    try:
        with dbLoader.conn.cursor() as cur:
            # Get database srid.
            cur.execute(query= f"""
                                SELECT srid 
                                FROM {dbLoader.SCHEMA}.database_srs 
                                LIMIT 1;
                                """)
            srid = cur.fetchone()[0] # Tuple has trailing comma.
        dbLoader.conn.commit()
        return srid

    except (Exception, psycopg2.Error) as error:
        # Send error to QGIS Message Log panel.
        c.critical_log(func=fetch_crs,
            location=FILE_LOCATION,
            header="Fetching srid",
            error=error)
        dbLoader.conn.rollback()

def exec_qgis_pkg_version(dbLoader) -> str:
    """SQL function thar reads and retrieves the qgis_pkg version

    *   :returns: The qgis_pkg verison.

        :rtype: str
    """
    try:
        with dbLoader.conn.cursor() as cur:
            #Get all schemas
            cur.callproc(f"{c.MAIN_PKG_NAME}.qgis_pkg_version",[])
            full_version = cur.fetchone()[0]
        dbLoader.conn.commit()
        return full_version

    except (Exception, psycopg2.Error) as error:
        # Send error to QGIS Message Log panel.
        c.critical_log(func=exec_qgis_pkg_version,
            location=FILE_LOCATION,
            header=f"Fetching {c.MAIN_PKG_NAME} verison",
            error=error)
        dbLoader.conn.rollback()

def exec_list_cdb_schemas(dbLoader) -> tuple:
    """SQL function thar reads and retrieves the database's
    data schemas. (citydb)

    *   :returns: A list with all the data schemas in DB

        :rtype: list(str)
    """
    try:
        with dbLoader.conn.cursor() as cur:
            #Get all schemas
            cur.callproc(f"{c.MAIN_PKG_NAME}.list_cdb_schemas",[])
            schemas = cur.fetchall()
        schemas = tuple(zip(*schemas))[0] # trailing comma
        dbLoader.conn.commit()
        return schemas

    except (Exception, psycopg2.Error) as error:
        # Send error to QGIS Message Log panel.
        c.critical_log(func=exec_list_cdb_schemas,
            location=FILE_LOCATION,
            header="Fetching data schemas",
            error=error)
        dbLoader.conn.rollback()

def exec_list_qgis_pkg_usrgroup_members(dbLoader) -> tuple:
    """SQL function thar reads and retrieves the database's
    data schemas. (citydb)

    *   :returns: A list with all the data schemas in DB

        :rtype: list(str)
    """
    try:
        with dbLoader.conn.cursor() as cur:
            #Get all schemas
            cur.callproc(f"{c.MAIN_PKG_NAME}.list_qgis_pkg_usrgroup_members",[])
            users = cur.fetchall()
        users = tuple(zip(*users))[0] # trailing comma
        dbLoader.conn.commit()
        return users

    except (Exception, psycopg2.Error) as error:
        # Send error to QGIS Message Log panel.
        c.critical_log(func=exec_list_qgis_pkg_usrgroup_members,
            location=FILE_LOCATION,
            header="Fetching availiable users",
            error=error)
        dbLoader.conn.rollback()

def exec_list_usr_schemas(dbLoader) -> tuple:
    """SQL function thar reads and retrieves the database's
    data schemas. (citydb)

    *   :returns: A list with all the data schemas in DB

        :rtype: list(str)
    """
    try:
        with dbLoader.conn.cursor() as cur:
            #Get all schemas
            cur.callproc(f"{c.MAIN_PKG_NAME}.list_usr_schemas",[])
            schemas = cur.fetchall()
        schemas = tuple(zip(*schemas))[0] # trailing comma
        dbLoader.conn.commit()
        return schemas

    except (Exception, psycopg2.Error) as error:
        # Send error to QGIS Message Log panel.
        c.critical_log(func=exec_list_usr_schemas,
            location=FILE_LOCATION,
            header="Fetching user schemas",
            error=error)
        dbLoader.conn.rollback()

def fetch_layer_metadata(dbLoader, from_schema, for_schema, cols = "*") -> tuple:
    """SQL query thar reads and retrieves the current schema's layer metadata
    from qgis_pkg.layer_metadata table. By default it fetchs all columns.



    *   :param cols: The columns to retrieve from the table.
            Note: to fetch multiple columns use:
            ",".join([col1,col2,col3])
        :type cols: str

    *   :returns: metadata of the layers combined with a collection of
        the attributes names

        :rtype: tuple(attribute_names,metadata)
    """
    try:
        with dbLoader.conn.cursor() as cur:
            cur.execute(f"""
                        SELECT {cols} FROM {from_schema}.layer_metadata
                        WHERE cdb_schema = '{for_schema}'
                        ORDER BY feature_type, lod, root_class, layer_name;
                        """)
            metadata = cur.fetchall()
            # Attribute names
            colnames = [desc[0] for desc in cur.description]
        dbLoader.conn.commit()
        return colnames, metadata

    except (Exception, psycopg2.Error) as error:
        # Send error to QGIS Message Log panel.
        c.critical_log(func=fetch_layer_metadata,
            location=FILE_LOCATION,
            header="Fetching layer metadata",
            error=error)
        dbLoader.conn.rollback()

def fetch_lookup_tables(dbLoader) -> tuple:
    """SQL query thar reads and retrieves lookup tables from qgis_pkg.

    *   :returns: Look up tables names

        :rtype: tuple(str)
    """
    try:
        with dbLoader.conn.cursor() as cur:
            #Get all existing look-up tables from database
            cur.execute(f"""
                        SELECT table_name,''
                        FROM information_schema.tables
                        WHERE table_schema = '{dbLoader.USER_SCHEMA}'
						AND table_type = 'VIEW'
                        AND (table_name LIKE '%codelist%'
                        OR table_name LIKE '%enumeration%');
                        """)
            lookups=cur.fetchall()
        dbLoader.conn.commit()
        lookups,empty=zip(*lookups)
        return lookups

    except (Exception, psycopg2.Error) as error:
        # Send error to QGIS Message Log panel.
        c.critical_log(func=fetch_lookup_tables,
            location=FILE_LOCATION,
            header="Fetching lookup tables",
            error=error)
        dbLoader.conn.rollback()

def fetch_codelist_id(dbLoader,root_class: str, lu_type: str) -> int:
    """SQL query thar reads and retrieves the id from codelist
    table for a specifc class and type.

    *   :param root_class: Class name to filter out the id

        :type root_class: str

    *   :param lu_type: Type of attribute to filter out the id
            from [Class,Function,Usage].

        :type root_class: str

    *   :returns: Look up tables names

        :rtype: tuple(str)
    """
    try:
        with dbLoader.conn.cursor() as cur:
            #Get all existing look-up tables from database
            cur.execute(f"""
                        SELECT id FROM {c.MAIN_PKG_NAME}.codelist
                        WHERE name LIKE '%{root_class}%'||'%{lu_type}%';
                        """)
            code_id = cur.fetchone()[0] # tuple with trailing comma.
        dbLoader.conn.commit()
        return code_id

    except (Exception, psycopg2.Error) as error:
        # Send error to QGIS Message Log panel.
        c.critical_log(func=fetch_codelist_id,
            location=FILE_LOCATION,
            header="Fetching codelist id",
            error=error)
        dbLoader.conn.rollback()

def exec_compute_schema_extents(dbLoader) -> None:
    """SQL qgis_pkg function that computes the schema's extents.

    *   :returns: x_min, y_min, x_max, y_max, srid

        :rtype: tuple
    """
    try:
        with dbLoader.conn.cursor() as cur:
            # Execute server function to compute the schema's extents
            cur.callproc(f"{c.MAIN_PKG_NAME}.compute_schema_extents",[dbLoader.USER_SCHEMA,dbLoader.SCHEMA])
            x_min, y_min, x_max, y_max, srid, upserted_id = cur.fetchone()
        upserted_id = None # Not needed.
        dbLoader.conn.commit()
        return x_min, y_min, x_max, y_max, srid

    except (Exception, psycopg2.Error) as error:
        # Send error to QGIS Message Log panel.
        c.critical_log(func=exec_compute_schema_extents,
            location=FILE_LOCATION,
            header="Computing extents",
            error=error)
        dbLoader.conn.rollback()

def exec_create_mview(dbLoader) -> None:
    """SQL qgis_pkg function that creates the schema's
    materialised views.
    """
    try:
        with dbLoader.conn.cursor() as cur:
            # Execute server function to compute the schema's extents
            cur.callproc("qgis_pkg.create_mview",[dbLoader.SCHEMA])
        dbLoader.conn.commit()

    except (Exception, psycopg2.Error) as error:
        # Send error to QGIS Message Log panel.
        c.critical_log(func=exec_create_mview,
            location=FILE_LOCATION,
            header="Creating mat views",
            error=error)
        dbLoader.conn.rollback()

def exec_create_updatable_views(dbLoader) -> None:
    """SQL qgis_pkg function that creates the schema's
    updatable views.
    """
    try:
        with dbLoader.conn.cursor() as cur:
            # Execute server function to compute the schema's extents.
            cur.callproc("qgis_pkg.create_updatable_views",[dbLoader.SCHEMA])
        dbLoader.conn.commit()

    except (Exception, psycopg2.Error) as error:
        # Send error to QGIS Message Log panel.
        c.critical_log(func=exec_create_updatable_views,
            location=FILE_LOCATION,
            header="Creating upd views",
            error=error)
        dbLoader.conn.rollback()

def exec_view_counter(dbLoader, view: c.View) -> int:
    """SQL qgis_pkg function that computes the number of
    geometry objects found in selecte extents.

    *   :returns: Number of objects.

        :rtype: int
    """

    try:
        # Convert QgsRectanlce into WKT polygon format
        extents = dbLoader.EXTENTS.asWktPolygon()
        with dbLoader.conn.cursor() as cur:
            # Execute server function to get the number of objects in extents.
            cur.callproc(f"{c.MAIN_PKG_NAME}.view_counter",[dbLoader.USER_SCHEMA,view.mv_name,extents])
            count = cur.fetchone()[0] # Tuple has trailing comma.
        dbLoader.conn.commit()

        # Assign the result to the view object.
        view.n_selected = count
        return count

    except (Exception, psycopg2.Error) as error:
        # Send error to QGIS Message Log panel.
        c.critical_log(func=exec_view_counter,
            location=FILE_LOCATION,
            header=f"Coutning view {view.mv_name}",
            error=error)
        dbLoader.conn.rollback()

def exec_get_table_privileges(dbLoader) -> dict:
    """SQL qgis_pkg function that reads and retrieves the current schema's table
    privileges.
    Note!: This functions is probably wont be used at all, as it requires that
    qgis_pkg is already installed, but the approach requires its execution
    before checking whether the qgis_pkg is installed or not.
    *   :returns: Table privileges

        :rtype: dict{str:bool}
    """
    try:
        with dbLoader.conn.cursor() as cur:
            # Execute server function to get the citydb schemas.
            cur.callproc("qgis_pkg.get_table_privileges")
            privileges_bool = cur.fetchone()
            colnames = [desc[0] for desc in cur.description]
            privileges_dict= dict(zip([col.upper() for col in colnames],privileges_bool))
        dbLoader.conn.commit()
        return privileges_dict

    except (Exception, psycopg2.Error) as error:
        # Send error to QGIS Message Log panel.
        c.critical_log(func=exec_get_table_privileges,
            location=FILE_LOCATION,
            header="Getting privileges",
            error=error)
        dbLoader.conn.rollback()

def exec_support_for_schema(dbLoader) -> bool:
    """SQL qgis_pkg function that determines if qgis_pkg has views
    regarding the current schema.
    *   :returns: Support status

        :rtype: bool
    """
    try:
        with dbLoader.conn.cursor() as cur:
            # Execute function to find if qgis_pkg supports current schema.
            cur.callproc(f"{c.MAIN_PKG_NAME}.support_for_schema",[dbLoader.USER_SCHEMA,dbLoader.SCHEMA])
            result_bool = cur.fetchone()[0] # Tuple has trailing comma.
        dbLoader.conn.commit()
        return result_bool

    except (Exception, psycopg2.Error) as error:
        # Send error to QGIS Message Log panel.
        c.critical_log(func=exec_support_for_schema,
            location=FILE_LOCATION,
            header="Getting support for schema",
            error=error)
        dbLoader.conn.rollback()

def exec_upsert_extents(dbLoader, usr_schema, cdb_schema, bbox_type, extents) -> None:
    """
    TOfill
    """
    # Get cornern coordinates
    # y_min = str(extents.yMinimum())
    # x_min = str(extents.xMinimum())
    # y_max = str(extents.yMaximum())
    # x_max = str(extents.xMaximum())
    # extents = "{"+",".join([x_min,y_min,x_max,y_max])+"}"

    try:
        with dbLoader.conn.cursor() as cur:
            # Execute function to find if qgis_pkg supports current schema.
            cur.callproc(f"{c.MAIN_PKG_NAME}.upsert_extents",[usr_schema,cdb_schema,bbox_type,extents])
        dbLoader.conn.commit()

    except (Exception, psycopg2.Error) as error:
        # Send error to QGIS Message Log panel.
        c.critical_log(func=exec_upsert_extents,
            location=FILE_LOCATION,
            header=f"Upserting '{bbox_type}' extents",
            error=error)
        dbLoader.conn.rollback()
    
def exec_create_qgis_usr_schema(dbLoader) -> None:
    """SQL qgis_pkg function that creates the user's schema."""

    try:
        with dbLoader.conn.cursor() as cur:
            # Execute server function to compute the schema's extents
            cur.callproc(f"{c.MAIN_PKG_NAME}.create_qgis_usr_schema",[dbLoader.DB.username])
        dbLoader.conn.commit()

    except (Exception, psycopg2.Error) as error:
        # Send error to QGIS Message Log panel.
        c.critical_log(func=exec_create_qgis_usr_schema,
            location=FILE_LOCATION,
            header=f"Creating user schema for {dbLoader.DB.username}",
            error=error)
        dbLoader.conn.rollback()

def exec_create_qgis_usr_schema_name(dbLoader, usr_name = None) -> None:
    """SQL qgis_pkg function that generates the user's schema name."""
    if usr_name is None:
        usr_name = dbLoader.DB.username

    try:
        with dbLoader.conn.cursor() as cur:
            # Execute server function to compute the schema's extents
            cur.callproc(f"{c.MAIN_PKG_NAME}.create_qgis_usr_schema_name",[usr_name])
            usr_schema = cur.fetchone()[0] # Trailing comma
        dbLoader.USER_SCHEMA = usr_schema
        dbLoader.conn.commit()

    except (Exception, psycopg2.Error) as error:
        # Send error to QGIS Message Log panel.
        c.critical_log(func=exec_create_qgis_usr_schema_name,
            location=FILE_LOCATION,
            header=f"Creating user schema name for {usr_name}",
            error=error)
        dbLoader.conn.rollback()
    
def fetch_mat_views(dbLoader) -> list:
    """SQL query thar reads and retrieves the current schema's
    materialised views from pg_matviews
    *   :returns: Materialized view dictionary with view name as keys and
            populated status as value.

        :rtype: dict{str,bool}
    """
    # NOTE: might need to set it as schema dependent.
    try:
        with dbLoader.conn.cursor() as cur:
            # Get database srid.
            cur.execute(query= f"""
                                SELECT matViewname, ispopulated 
                                FROM pg_matviews
                                WHERE schemaname = '{c.MAIN_PKG_NAME}';
                                """)
            mat_views = cur.fetchall()
            mat_views, status = list(zip(*mat_views))
            mat_views = dict(zip(mat_views,status))

        dbLoader.conn.commit()

        return mat_views

    except (Exception, psycopg2.Error) as error:
        # Send error to QGIS Message Log panel.
        c.critical_log(func=fetch_mat_views,
            location=FILE_LOCATION,
            header="Fetching mat views",
            error=error)
        dbLoader.conn.rollback()

def refresh_mat_view(dbLoader,connection, m_view):
    try:
        with connection.cursor() as cur:
            # Get database srid.
            cur.execute(query= f"""
                                REFRESH MATERIALIZED VIEW "{dbLoader.USER_SCHEMA}"."{m_view}";
                                """)
            cur.execute(query= f"""
                                UPDATE {dbLoader.USER_SCHEMA}.layer_metadata
                                SET refresh_date = clock_timestamp()
                                WHERE mv_name = '{m_view}'""")

        dbLoader.conn.commit()


    except (Exception, psycopg2.Error) as error:
        # Send error to QGIS Message Log panel.
        c.critical_log(func=refresh_mat_view,
            location=FILE_LOCATION,
            header=f"Refreshing mat view: {m_view}",
            error=error)
        dbLoader.conn.rollback()

def has_main_pkg(dbLoader) -> bool:
    """SQL query that searches for the main plugin pagkage in the database
    'qgis_pkg'.

    *   :returns: Search result

        :rtype: bool
    """

    try:

        # Create cursor.
        with dbLoader.conn.cursor() as cur:
            # Get package name from database
            cur.execute(query= f"""
                                SELECT schema_name 
                                FROM information_schema.schemata 
	                            WHERE schema_name = '{c.MAIN_PKG_NAME}';
                                """)
            pkg_name = cur.fetchone()
        dbLoader.conn.commit()

        if pkg_name:
            return True
        return False

    except (Exception, psycopg2.Error) as error:
        # Send error to QGIS Message Log panel.
        c.critical_log(func=has_main_pkg,
            location=FILE_LOCATION,
            header="Searching for main package",
            error=error)
        dbLoader.conn.rollback()

def has_user_pkg(dbLoader) -> bool:
    """SQL query that searches for user package in the database
    'qgis_user'.

    *   :returns: Search result

        :rtype: bool
    """

    try:

        # Create cursor.
        with dbLoader.conn.cursor() as cur:
            # Get package name from database
            cur.execute(query= f"""
                                SELECT schema_name 
                                FROM information_schema.schemata 
	                            WHERE schema_name = '{dbLoader.USER_SCHEMA}';
                                """)
            pkg_name = cur.fetchone()
        dbLoader.conn.commit()
        if pkg_name:
            return True
        return False

    except (Exception, psycopg2.Error) as error:
        # Send error to QGIS Message Log panel.
        c.critical_log(func=has_user_pkg,
            location=FILE_LOCATION,
            header="Searching for user package",
            error=error)
        dbLoader.conn.rollback()

def drop_package(dbLoader, schema: str, close_connection:bool = True) -> None:
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
        with dbLoader.conn.cursor() as cur:
            cur.execute(f"""DROP SCHEMA IF EXISTS {schema} CASCADE;""")
        dbLoader.conn.commit()

        if close_connection:
            dbLoader.conn.close()

    except (Exception, psycopg2.Error) as error:
        # Send error to QGIS Message Log panel.
        c.critical_log(func=drop_package,
            location=FILE_LOCATION,
            header="Dropping package",
            error=error)
        dbLoader.conn.rollback()

# def schema_has_features(dbLoader, schema: str) -> bool: #NOTE: TO be deleted
#     """SQL query that searches schema for CityGML features.

#     *   :param schema: Schema to check if it has CityGML feature tables

#         :type schema: str

#     *   :returns: Search result

#         :rtype: bool
#     """

#     try:
#         # Create cursor.
#         with dbLoader.conn.cursor() as cur:
#             # Get package name from database
#             cur.execute(f"""
#                         SELECT table_name FROM information_schema.tables
#                         WHERE table_schema = '{schema}'
#                         AND table_name SIMILAR TO '{c.get_postgres_array(c.features_tables)}'
#                         ORDER BY table_name ASC
#                         """)
#             feature_response= cur.fetchall() #All tables relevant to the thematic surfaces
#         dbLoader.conn.commit()

#         if feature_response:
#             return True
#         return False

#     except (Exception, psycopg2.Error) as error:
#         # Send error to QGIS Message Log panel.
#         c.critical_log(func=schema_has_features,
#             location=FILE_LOCATION,
#             header="Getting schema features",
#             error=error)
#         dbLoader.conn.rollback()

# def fetch_users(dbLoader) -> dict: NOTE: TO BE DELETED
#     """SQL query thar reads and retrieves the current database's
#     users accompanied with their superuser status
#     *   :returns: Database users with user name as keys and
#             superuser as value.

#         :rtype: dict{str,bool}
#     """

#     try:
#         with dbLoader.conn.cursor() as cur:
#             # Get database srid.
#             cur.execute(query=  """
#                                 SELECT usename, usesuper
#                                 FROM pg_catalog.pg_user;
#                                 """)
#             users = cur.fetchall()
#             users, status = list(zip(*users))
#             users = dict(zip(users,status))

#         dbLoader.conn.commit()

#         return users

#     except (Exception, psycopg2.Error) as error:
#         # Send error to QGIS Message Log panel.
#         c.critical_log(func=fetch_users,
#             location=FILE_LOCATION,
#             header="Fetching users",
#             error=error)
#         dbLoader.conn.rollback()
"""This module contains functions that relate to the server side
operations.

These functions are responsible to communicate and fetch data from
the database with sql queries all sql function calls.
"""
#TODO: Catching error and logging code block seems too repretive,
# could probably set it as a function

import psycopg2

from . import constants as c

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

def fetch_extents(dbLoader, ext_type: str) -> str:
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
                                FROM qgis_pkg.extents 
                                WHERE schema_name = '{dbLoader.SCHEMA}'
                                AND bbox_type = '{ext_type}';
                                """)
            extents = cur.fetchone()[0] # Tuple has trailing comma.
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

def fetch_table_privileges(dbLoader) -> dict:
    """SQL query thar reads and retrieves the user's
    privileges and their effectiveness.
    *   :returns: Table privileges

        :rtype: dict{str:bool}
    """
    try:

        with dbLoader.conn.cursor() as cur:
            cur.execute(f"""
            WITH t AS (
            SELECT concat('{dbLoader.SCHEMA}','.',i.table_name)::varchar 
            AS qualified_table_name
            FROM information_schema.tables AS i
            WHERE table_schema = '{dbLoader.SCHEMA}' 
                AND table_type = 'BASE TABLE'
            ) SELECT
            t.qualified_table_name,
            pg_catalog.has_table_privilege(current_user, t.qualified_table_name, 'DELETE')     AS delete_priv,
            pg_catalog.has_table_privilege(current_user, t.qualified_table_name, 'SELECT')     AS select_priv,
            pg_catalog.has_table_privilege(current_user, t.qualified_table_name, 'REFERENCES') AS references_priv,
            pg_catalog.has_table_privilege(current_user, t.qualified_table_name, 'TRIGGER')    AS trigger_priv,
            pg_catalog.has_table_privilege(current_user, t.qualified_table_name, 'TRUNCATE')   AS truncate_priv,
            pg_catalog.has_table_privilege(current_user, t.qualified_table_name, 'UPDATE')     AS update_priv,
            pg_catalog.has_table_privilege(current_user, t.qualified_table_name, 'INSERT')     AS insert_priv
            FROM t;""")
            privileges_bool = cur.fetchone()
        dbLoader.conn.commit()

        # Get privileges name from columns
        colnames = [desc[0] for desc in cur.description]
        privileges_dict = dict(zip([col.upper() for col in colnames],privileges_bool))

        # Kyes: priv name (e.g. delete_priv) Values: status (e.g. True)
        return privileges_dict
    except (Exception, psycopg2.Error) as error:
        # Send error to QGIS Message Log panel.
        c.critical_log(func=fetch_table_privileges,
            location=FILE_LOCATION,
            header="Fetching privileges",
            error=error)
        dbLoader.conn.rollback()

def fetch_schemas(dbLoader) -> tuple:
    """SQL query thar reads and retrieves the database's
    schemas.

    *   :returns: A list with all the schemas in DB

        :rtype: list(str)
    """
    try:
        with dbLoader.conn.cursor() as cur:
            #Get all schemas
            cur.execute("""
                        SELECT schema_name,'' 
                        FROM information_schema.schemata 
                        WHERE schema_name != 'information_schema' 
                        AND NOT schema_name LIKE '%pg%' 
                        ORDER BY schema_name ASC
                        """)
            schemas = cur.fetchall()
        schemas, empty = tuple(zip(*schemas))
        dbLoader.conn.commit()
        return schemas

    except (Exception, psycopg2.Error) as error:
        # Send error to QGIS Message Log panel.
        c.critical_log(func=fetch_schemas,
            location=FILE_LOCATION,
            header="Fetching all schemas",
            error=error)
        dbLoader.conn.rollback()

def fetch_layer_metadata(dbLoader, cols = "*") -> tuple:
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
                        SELECT {cols} FROM {c.PLUGIN_PKG_NAME}.layer_metadata
                        WHERE schema_name = '{dbLoader.SCHEMA}'
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
                        WHERE table_schema = '{c.PLUGIN_PKG_NAME}' 
                        AND table_name LIKE 'codelist%'
                        OR table_name LIKE 'enumeration%';
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
                        SELECT id FROM {c.PLUGIN_PKG_NAME}.codelist
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
            cur.callproc("qgis_pkg.compute_schema_extents",[dbLoader.SCHEMA])
            x_min, y_min, x_max, y_max, srid, upserted_id= cur.fetchone()
        upserted_id = None # Not needed.
        dbLoader.conn.commit()
        return x_min, y_min, x_max, y_max, srid

    except (Exception, psycopg2.Error) as error:
        # Send error to QGIS Message Log panel.
        c.critical_log(func=fetch_crs,
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
            cur.callproc("qgis_pkg.view_counter",[view.v_name,extents])
            count = cur.fetchone()[0] # Tuple has trailing comma.
        dbLoader.conn.commit()

        # Assign the result to the view object.
        view.n_selected = count
        return count

    except (Exception, psycopg2.Error) as error:
        # Send error to QGIS Message Log panel.
        c.critical_log(func=exec_view_counter,
            location=FILE_LOCATION,
            header="Coutning view n_selected",
            error=error)
        dbLoader.conn.rollback()

def exec_get_feature_schemas(dbLoader) -> tuple:
    """SQL qgis_pkg function that reads and retrieves the current database's
    3DCityDB schemas.
    Note: it returns ONLY the schemas responsible of storing the city model.

    *   :returns: Schemas (e.g. citydb)

        :rtype: tuple
    """
    try:
        with dbLoader.conn.cursor() as cur:
            # Execute server function to get the citydb schemas.
            cur.callproc("qgis_pkg.get_feature_schemas")
            schemas = cur.fetchall() # list of tuples with trailing commas
            schemas = list(zip(*schemas))[0]
        dbLoader.conn.commit()
        return schemas

    except (Exception, psycopg2.Error) as error:
        # Send error to QGIS Message Log panel.
        c.critical_log(func=exec_get_feature_schemas,
            location=FILE_LOCATION,
            header="Getting 3DCityDB schemas",
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
            cur.callproc("qgis_pkg.support_for_schema",[dbLoader.SCHEMA])
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
                                WHERE schemaname = '{c.PLUGIN_PKG_NAME}';
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

def has_plugin_pkg(dbLoader) -> bool:
    """SQL query that searches for qgis_pkg in the database.
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
	                            WHERE schema_name = '{c.PLUGIN_PKG_NAME}';
                                """)
            pkg_name = cur.fetchone()
        dbLoader.conn.commit()

        if pkg_name:
            return True
        return False

    except (Exception, psycopg2.Error) as error:
        # Send error to QGIS Message Log panel.
        c.critical_log(func=has_plugin_pkg,
            location=FILE_LOCATION,
            header="Searching package",
            error=error)
        dbLoader.conn.rollback()

def drop_package(dbLoader, close_connection:bool = True) -> None:
    """SQL query that drops plugin package from the database.

    As plugin cannot function without its package, the function
    also closes the connection.

    *   :param close_connection: After droping the plugin package,
            it is not possible to work with the plugin, so the default
            state is True.

        :type close_connection: boll
    """

    try:
        with dbLoader.conn.cursor() as cur:
            cur.execute(f"""DROP SCHEMA {c.PLUGIN_PKG_NAME} CASCADE;""")
        dbLoader.conn.commit()

        if close_connection:
            dbLoader.conn.close()

    except (Exception, psycopg2.Error) as error:
        # Send error to QGIS Message Log panel.
        c.critical_log(func=drop_package,
            location=FILE_LOCATION,
            header="Droping package",
            error=error)
        dbLoader.conn.rollback()

def schema_has_features(dbLoader, schema: str) -> bool:
    """SQL query that searches schema for CityGML features.

    *   :param schema: Schema to check if it has CityGML feature tables

        :type schema: str

    *   :returns: Search result

        :rtype: bool
    """

    try:
        # Create cursor.
        with dbLoader.conn.cursor() as cur:
            # Get package name from database
            cur.execute(f"""
                        SELECT table_name FROM information_schema.tables
                        WHERE table_schema = '{schema}'
                        AND table_name SIMILAR TO '{c.get_postgres_array(c.features_tables)}'
                        ORDER BY table_name ASC
                        """)
            feature_response= cur.fetchall() #All tables relevant to the thematic surfaces
        dbLoader.conn.commit()

        if feature_response:
            return True
        return False

    except (Exception, psycopg2.Error) as error:
        # Send error to QGIS Message Log panel.
        c.critical_log(func=schema_has_features,
            location=FILE_LOCATION,
            header="Getting schema features",
            error=error)
        dbLoader.conn.rollback()

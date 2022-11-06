"""This module contains functions that relate to the server side operations.

These functions are responsible to communicate and fetch data from
the database with sql queries or sql function calls.
"""
import psycopg2
from ....cdb_loader import CDBLoader # Used only to add the type of the function parameters
from ... import cdb4_constants as c

FILE_LOCATION = c.get_file_relative_path(file=__file__)

def fetch_extents(cdbLoader: CDBLoader, usr_schema: str, cdb_schema: str, ext_type: str) -> str:
    """SQL query that reads and retrieves extents stored in {usr_schema}.extents

    *   :returns: Extents as WKT or None if the entry is empty.
        :rtype: str
    """
    extents: str
    try:
        with cdbLoader.conn.cursor() as cur:
            # Get db_schema extents from server as WKT.
            cur.execute(query= f"""
                                SELECT ST_AsText(envelope) FROM "{usr_schema}".extents 
                                WHERE cdb_schema = '{cdb_schema}' AND bbox_type = '{ext_type}';
                                """)
            res_extents = cur.fetchone()
            # res_extents = (None,) when the envelope is Null,
            # BUT res_extents = None when the query returns NO results.
            if type(res_extents) == tuple:
                extents = res_extents[0] # Get the value without trailing comma.

        cdbLoader.conn.commit()
        return extents

    except (Exception, psycopg2.Error) as error:
        c.critical_log(
            func=fetch_extents,
            location=FILE_LOCATION,
            header="Retrieving extents",
            error=error)
        cdbLoader.conn.rollback()

def fetch_crs(cdbLoader: CDBLoader) -> int:
    """SQL query that reads and retrieves the current schema's srid from {cdb_schema}.database_srs

    *   :returns: srid number
        :rtype: int
    """
    srid: int
    try:
        with cdbLoader.conn.cursor() as cur:
            # Get database srid
            cur.execute(query= f"""SELECT srid FROM "{cdbLoader.CDB_SCHEMA}".database_srs LIMIT 1;""")
            srid = cur.fetchone()[0] # Tuple has trailing comma.
        cdbLoader.conn.commit()
        return srid

    except (Exception, psycopg2.Error) as error:
        c.critical_log(
            func=fetch_crs,
            location=FILE_LOCATION,
            header="Retrieving srid",
            error=error)
        cdbLoader.conn.rollback()

def fetch_layer_metadata(cdbLoader: CDBLoader, usr_schema: str, cdb_schema: str, cols="*") -> tuple:
    """SQL query that retrieves the current schema's layer metadata
    from {usr_schema}.layer_metadata table. By default it retrieves all columns.

    *   :param cols: The columns to retrieve from the table.
            Note: to fetch multiple columns use: ",".join([col1,col2,col3])
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
                        SELECT table_name,'' FROM information_schema.tables
                        WHERE table_schema = '{cdbLoader.USR_SCHEMA}'
						AND table_type = 'VIEW' AND (table_name LIKE '%codelist%' OR table_name LIKE '%enumeration%');
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

def exec_compute_schema_extents(cdbLoader: CDBLoader) -> tuple:
    """Calls the qgis_pkg function that computes the schema extents.

    *   :returns: x_min, y_min, x_max, y_max, srid
        :rtype: tuple
    """
    try:
        with cdbLoader.conn.cursor() as cur:
            # Execute server function to compute the schema's extents
            cur.callproc(f"""{cdbLoader.QGIS_PKG_SCHEMA}.compute_schema_extents""",[cdbLoader.USR_SCHEMA, cdbLoader.CDB_SCHEMA])
            x_min, y_min, x_max, y_max, srid, upserted_id = cur.fetchone()
        upserted_id = None # Not needed.
        cdbLoader.conn.commit()
        return x_min, y_min, x_max, y_max, srid

    except (Exception, psycopg2.Error) as error:
        c.critical_log(
            func=exec_compute_schema_extents,
            location=FILE_LOCATION,
            header="Computing extents of the selected cdb_schema",
            error=error)
        cdbLoader.conn.rollback()

def exec_view_counter(cdbLoader: CDBLoader, layer: c.Layer) -> int:
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
            cur.callproc(f"""{cdbLoader.QGIS_PKG_SCHEMA}.view_counter""",[cdbLoader.USR_SCHEMA, cdbLoader.CDB_SCHEMA, layer.mv_name, extents])
            count = cur.fetchone()[0] # Tuple has trailing comma.
        cdbLoader.conn.commit()

        # Assign the result to the view object.
        layer.n_selected = count
        return count

    except (Exception, psycopg2.Error) as error:
        c.critical_log(
            func=exec_view_counter,
            location=FILE_LOCATION,
            header=f"Counting number of objects in view {layer.mv_name}",
            error=error)
        cdbLoader.conn.rollback()

def exec_has_layers_for_cdb_schema(cdbLoader: CDBLoader) -> bool:
    """Calls the qgis_pkg function that determines whether the {usr_schema} has views
    regarding the current {cdb_schema}.

    *   :returns: status
        :rtype: bool
    """
    try:
        with cdbLoader.conn.cursor() as cur:
            # Execute function to find if qgis_pkg supports current schema.
            cur.callproc(f"""{cdbLoader.QGIS_PKG_SCHEMA}.support_for_schema""",[cdbLoader.USR_SCHEMA, cdbLoader.CDB_SCHEMA])
            result_bool = cur.fetchone()[0] # Tuple has trailing comma.
        cdbLoader.conn.commit()
        return result_bool

    except (Exception, psycopg2.Error) as error:
        c.critical_log(
            func=exec_has_layers_for_cdb_schema,
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
            cur.callproc(f"""{cdbLoader.QGIS_PKG_SCHEMA}.upsert_extents""",[usr_schema, cdb_schema, bbox_type, extents])
        cdbLoader.conn.commit()

    except (Exception, psycopg2.Error) as error:
        c.critical_log(
            func=exec_upsert_extents,
            location=FILE_LOCATION,
            header=f"Upserting '{bbox_type}' extents",
            error=error)
        cdbLoader.conn.rollback()

def fetch_mat_views(cdbLoader: CDBLoader) -> dict:
    """SQL query that retrieves the current cdb_schema's materialised views from pg_matviews

    *   :returns: Materialized view dictionary with view name as keys and populated status as value.
        :rtype: dict{str,bool}
    """
    try:
        with cdbLoader.conn.cursor() as cur:
            # Select the views
            cur.execute(query=f"""SELECT matViewname, ispopulated FROM pg_matviews WHERE schemaname = '{cdbLoader.QGIS_PKG_SCHEMA}';""")
            mat_views = cur.fetchall()
            mat_views, status = list(zip(*mat_views))
            mat_views = dict(zip(mat_views,status))
        cdbLoader.conn.commit()
        return mat_views

    except (Exception, psycopg2.Error) as error:
        c.critical_log(
            func=fetch_mat_views,
            location=FILE_LOCATION,
            header="Retrieving list of materialized views",
            error=error)
        cdbLoader.conn.rollback()

def refresh_mat_view(cdbLoader: CDBLoader, connection, matview_name: str) -> None:
    """SQL query that refreshes a materialized view in {usr_schema}
    """
    try:
        with connection.cursor() as cur:
            cur.execute(query=f"""REFRESH MATERIALIZED VIEW "{cdbLoader.USR_SCHEMA}"."{matview_name}";""")
            cur.execute(query=f"""
                                UPDATE "{cdbLoader.USR_SCHEMA}".layer_metadata
                                SET refresh_date = clock_timestamp()
                                WHERE mv_name = '{matview_name}';
                                """)
        cdbLoader.conn.commit()

    except (Exception, psycopg2.Error) as error:
        c.critical_log(
            func=refresh_mat_view,
            location=FILE_LOCATION,
            header=f"Refreshing materialized view {matview_name} in schema {cdbLoader.USR_SCHEMA}",
            error=error)
        cdbLoader.conn.rollback()
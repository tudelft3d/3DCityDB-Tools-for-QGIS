"""This module contains functions that relate to the server side operations.

These functions are responsible to communicate and fetch data from
the database with sql queries or sql function calls.
"""
import psycopg2, psycopg2.sql as pysql
from psycopg2.extras import NamedTupleCursor

from ....cdb_tools_main import CDBToolsMain  # Used only to add the type of the function parameters
from ..other_classes import CDBLayer

from ...shared.functions import general_functions as gen_f

FILE_LOCATION = gen_f.get_file_relative_path(file=__file__)

def exec_list_cdb_schemas_extended(cdbMain: CDBToolsMain) -> list:
    """SQL function that retrieves the database cdb_schemas for the current database, 
    included the privileges status for the selected usr_name

    *   :returns: A list of named tuples with all usr_schemas, the number of available cityobecjts, 
         and the user's privileges for each cdb_schema in the current database
        :rtype: list(tuple(cdb_schema, co_number, priv_type))
    """
    query = pysql.SQL("""
        SELECT cdb_schema, co_number, priv_type FROM {_qgis_pkg_schema}.list_cdb_schemas_with_privileges({_usr_name});
        """).format(
        _qgis_pkg_schema = pysql.Identifier(cdbMain.QGIS_PKG_SCHEMA),
        _usr_name = pysql.Literal(cdbMain.DB.username)
        )

    try:
        with cdbMain.conn.cursor(cursor_factory=NamedTupleCursor) as cur:
            cur.execute(query)
            res = cur.fetchall()
        cdbMain.conn.commit()

        if not res:
            res = []
            return res
        else:
            return res
    
    except (Exception, psycopg2.Error) as error:
        gen_f.critical_log(
            func=exec_list_cdb_schemas_extended,
            location=FILE_LOCATION,
            header="Retrieving list of cdb_schemas with their privileges",
            error=error)
        cdbMain.conn.rollback()


def fetch_precomputed_extents(cdbMain: CDBToolsMain, usr_schema: str, cdb_schema: str, ext_type: str) -> str:
    """SQL query that reads and retrieves extents stored in {usr_schema}.extents

    *   :returns: Extents as WKT or None if the entry is empty.
        :rtype: str
    """
    # Get cdb_schema extents from server as WKT.
    query = pysql.SQL("""
        SELECT ST_AsText(envelope) FROM {_usr_schema}.extents 
        WHERE cdb_schema = {_cdb_schema} AND bbox_type = {_ext_type};
        """).format(
        _usr_schema = pysql.Identifier(usr_schema),
        _cdb_schema = pysql.Literal(cdb_schema),
        _ext_type = pysql.Literal(ext_type)
        )

    try:
        with cdbMain.conn.cursor() as cur:
            cur.execute(query)
            extents = cur.fetchone()
            # extents = (None,) when the envelope is Null,
            # BUT extents = None when the query returns NO results.
            if type(extents) == tuple:
                extents = extents[0] # Get the value without trailing comma.

        cdbMain.conn.commit()
        return extents

    except (Exception, psycopg2.Error) as error:
        gen_f.critical_log(
            func=fetch_precomputed_extents,
            location=FILE_LOCATION,
            header=f"Retrieving extents of schema {cdb_schema}",
            error=error)
        cdbMain.conn.rollback()


def fetch_cdb_schema_srid(cdbMain: CDBToolsMain) -> int:
    """SQL query that reads and retrieves the current schema's srid from {cdb_schema}.database_srs

    *   :returns: srid number
        :rtype: int
    """
    # Get database srid
    query = pysql.SQL("""
        SELECT srid FROM {_cdb_schema}.database_srs LIMIT 1;
        """).format(
        _cdb_schema = pysql.Identifier(cdbMain.CDB_SCHEMA)
        )
   
    try:
        with cdbMain.conn.cursor() as cur:

            cur.execute(query)
            srid = cur.fetchone()[0] # Tuple has trailing comma.
        cdbMain.conn.commit()
        return srid

    except (Exception, psycopg2.Error) as error:
        gen_f.critical_log(
            func=fetch_cdb_schema_srid,
            location=FILE_LOCATION,
            header="Retrieving srid",
            error=error)
        cdbMain.conn.rollback()


def fetch_layer_metadata(cdbMain: CDBToolsMain, usr_schema: str, cdb_schema: str, cols_list: list=["*"]) -> tuple:
    """SQL query that retrieves the current schema's layer metadata from {usr_schema}.layer_metadata table. 
    By default it retrieves all columns.

    *   :param cols: The columns to retrieve from the table.
            Note: to fetch multiple columns use: ",".join([col1,col2,col3])
        :type cols: str

    *   :returns: metadata of the layers combined with a collection of
        the attributes names
        :rtype: tuple(attribute_names, metadata)
    """
    if cols_list == ["*"]:
        query = pysql.SQL("""
                        SELECT * FROM {_usr_schema}.layer_metadata
                        WHERE cdb_schema = {_cdb_schema}
                        ORDER BY feature_type, lod, root_class, layer_name;
                        """).format(
                        _usr_schema = pysql.Identifier(usr_schema),
                        _cdb_schema = pysql.Literal(cdb_schema)
                        )
    else:
        query = pysql.SQL("""
                    SELECT {_cols} FROM {_usr_schema}.layer_metadata
                    WHERE cdb_schema = {_cdb_schema}
                    ORDER BY feature_type, lod, root_class, layer_name;
                    """).format(
                    _cols = pysql.SQL(', ').join(pysql.Identifier(col) for col in cols_list),
                    _usr_schema = pysql.Identifier(usr_schema),
                    _cdb_schema = pysql.Literal(cdb_schema)
                    )

    try:
        with cdbMain.conn.cursor() as cur:
            cur.execute(query)
            metadata = cur.fetchall()
            # Attribute names
            colnames = [desc[0] for desc in cur.description]
        cdbMain.conn.commit()
        return colnames, metadata

    except (Exception, psycopg2.Error) as error:
        gen_f.critical_log(
            func=fetch_layer_metadata,
            location=FILE_LOCATION,
            header="Retrieving layers metadata",
            error=error)
        cdbMain.conn.rollback()


def fetch_lookup_tables(cdbMain: CDBToolsMain) -> tuple:
    """SQL query that retrieves look-up tables from {usr_schema}.

    *   :returns: Look up tables names
        :rtype: tuple(str)
    """
    # Prepare query to get all existing look-up tables from the database
    query = pysql.SQL("""
        SELECT table_name FROM information_schema.tables
        WHERE table_schema = {_usr_schema}
        AND table_type = 'VIEW' AND (table_name LIKE '%codelist%' OR table_name LIKE '%enumeration%');
        """).format(
        _usr_schema = pysql.Literal(cdbMain.USR_SCHEMA)
        )

    try:
        with cdbMain.conn.cursor() as cur:
            cur.execute(query)
            res=cur.fetchall()
        cdbMain.conn.commit()

        lookups = tuple(elem[0] for elem in res)
        return lookups

    except (Exception, psycopg2.Error) as error:
        # Send error to QGIS Message Log panel.
        gen_f.critical_log(
            func=fetch_lookup_tables,
            location=FILE_LOCATION,
            header="Retrieving look-up tables with enumerations and codelists",
            error=error)
        cdbMain.conn.rollback()


def exec_compute_cdb_schema_extents(cdbMain: CDBToolsMain) -> tuple:
    """Calls the qgis_pkg function that computes the cdb_schema extents.

    *   :returns: is_geom_null, x_min, y_min, x_max, y_max, srid
        :rtype: tuple
    """
    # Prepar query to execute server function to compute the schema's extents
    query = pysql.SQL("""
        SELECT * FROM {_qgis_pkg_schema}.compute_cdb_schema_extents({_cdb_schema});
        """).format(
        _qgis_pkg_schema = pysql.Identifier(cdbMain.QGIS_PKG_SCHEMA),
        _cdb_schema = pysql.Literal(cdbMain.CDB_SCHEMA)
        )

    try:
        with cdbMain.conn.cursor() as cur:
            cur.execute(query)
            #cur.callproc(f"""{cdbMain.QGIS_PKG_SCHEMA}.compute_cdb_schema_extents""",[cdbMain.CDB_SCHEMA])
            values = cur.fetchone()
            cdbMain.conn.commit()
            if values:
                is_geom_null, x_min, y_min, x_max, y_max, srid = values
                return is_geom_null, x_min, y_min, x_max, y_max, srid
            else:
                return None

    except (Exception, psycopg2.Error) as error:
        gen_f.critical_log(
            func=exec_compute_cdb_schema_extents,
            location=FILE_LOCATION,
            header=f"Computing extents of the schema '{cdbMain.CDB_SCHEMA}'",
            error=error)
        cdbMain.conn.rollback()


def exec_gview_counter(cdbMain: CDBToolsMain, layer: CDBLayer) -> int:
    """Calls the qgis_pkg function that counts the number of geometry objects found within the selected extents.

    *   :returns: Number of objects.
        :rtype: int
    """
    # Convert QgsRectanlce into WKT polygon format
    extents: str = cdbMain.loader_dlg.CURRENT_EXTENTS.asWktPolygon()
    
    # Prepare query to execute server function to get the number of objects in extents.
    query = pysql.SQL("""
        SELECT {_qgis_pkg_schema}.gview_counter({_usr_schema},{_cdb_schema},{_gv_name},{_extents});
        """).format(
        _qgis_pkg_schema = pysql.Identifier(cdbMain.QGIS_PKG_SCHEMA),
        _usr_schema = pysql.Literal(cdbMain.USR_SCHEMA),
        _cdb_schema = pysql.Literal(cdbMain.CDB_SCHEMA),
        _gv_name = pysql.Literal(layer.gv_name),  
        _extents = pysql.Literal(extents)
        )

    try:
        with cdbMain.conn.cursor() as cur:
            cur.execute(query)
            # cur.callproc(f"""{cdbMain.QGIS_PKG_SCHEMA}.gview_counter""",[cdbMain.USR_SCHEMA, cdbMain.CDB_SCHEMA, layer.gv_name, extents])
            count = cur.fetchone()[0] # Tuple has trailing comma.
        cdbMain.conn.commit()

        # Assign the result to the view object.
        layer.n_selected = count
        return count

    except (Exception, psycopg2.Error) as error:
        gen_f.critical_log(
            func=exec_gview_counter,
            location=FILE_LOCATION,
            header=f"Counting number of geometries objects in layer {layer.layer_name} (via gview {layer.gv_name})",
            error=error)
        cdbMain.conn.rollback()


def exec_has_layers_for_cdb_schema(cdbMain: CDBToolsMain) -> bool:
    """Calls the qgis_pkg function that determines whether the {usr_schema} has layers
    regarding the current {cdb_schema}.

    *   :returns: status
        :rtype: bool
    """
    # Prepare query to check if there are already layers for the current cdb_schema
    query = pysql.SQL("""
        SELECT {_qgis_pkg_schema}.has_layers_for_cdb_schema({_usr_schema},{_cdb_schema});
        """).format(
        _qgis_pkg_schema = pysql.Identifier(cdbMain.QGIS_PKG_SCHEMA),
        _usr_schema = pysql.Literal(cdbMain.USR_SCHEMA),
        _cdb_schema = pysql.Literal(cdbMain.CDB_SCHEMA)
        )

    try:
        with cdbMain.conn.cursor() as cur:
            cur.execute(query)
            result_bool = cur.fetchone()[0] # Tuple has trailing comma.
        cdbMain.conn.commit()
        return result_bool

    except (Exception, psycopg2.Error) as error:
        gen_f.critical_log(
            func=exec_has_layers_for_cdb_schema,
            location=FILE_LOCATION,
            header=f"Checking whether layers already exist for schema {cdbMain.CDB_SCHEMA}",
            error=error)
        cdbMain.conn.rollback()


def exec_upsert_extents(cdbMain: CDBToolsMain, bbox_type: str, extents_wkt_2d_poly: str) -> int:
    """Calls a QGIS Package function to insert (or update) the extents geometry in table qgis_{usr}.extents.

    *   :param bbox_type: one of ['db_schema', 'm_view', 'qgis']
        :type bbox_type: str

    *   :param extents_2d_poly: wkt of a polygon, 2D and withouth SRID
        :type extents_2d_poly: str

    *   :returns: upserted_id
        :rtype: int
    """
    # Prepare query to upsert the extents of the current cdb_schema
    query = pysql.SQL("""
        SELECT {_qgis_pkg_schema}.upsert_extents({_usr_schema},{_cdb_schema},{_bbox_type},{_extents});
        """).format(
        _qgis_pkg_schema = pysql.Identifier(cdbMain.QGIS_PKG_SCHEMA),
        _usr_schema = pysql.Literal(cdbMain.USR_SCHEMA),
        _cdb_schema = pysql.Literal(cdbMain.CDB_SCHEMA),
        _bbox_type = pysql.Literal(bbox_type),
        _extents = pysql.Literal(extents_wkt_2d_poly)
        )

    try:
        with cdbMain.conn.cursor() as cur:
            cur.execute(query)
            upserted_id = cur.fetchone()[0] # Tuple has trailing comma.
            # upserted_id = cur.callproc(f"""{cdbMain.QGIS_PKG_SCHEMA}.upsert_extents""",[usr_schema, cdb_schema, bbox_type, extents_wkt_2d_poly])
        cdbMain.conn.commit()
        if upserted_id:
            return upserted_id
        else:
            return None

    except (Exception, psycopg2.Error) as error:
        gen_f.critical_log(
            func=exec_upsert_extents,
            location=FILE_LOCATION,
            header=f"Upserting '{bbox_type}' extents",
            error=error)
        cdbMain.conn.rollback()


def fetch_mat_views(cdbMain: CDBToolsMain) -> dict:
    """SQL query that retrieves the current cdb_schema's materialised views from pg_matviews

    *   :returns: Materialized view dictionary with view name as keys and populated status as value.
        :rtype: dict{str,bool}
    """
    # Prepare query to get the list of materialized views for the current cdb_schema
    query = pysql.SQL("""
        SELECT matViewname, ispopulated 
        FROM pg_matviews 
        WHERE schemaname = {_qgis_pkg_schema};
        """).format(
        _qgis_pkg_schema = pysql.Literal(cdbMain.QGIS_PKG_SCHEMA)
        )

    try:
        with cdbMain.conn.cursor() as cur:
            cur.execute(query)
            # cur.execute(query=f"""SELECT matViewname, ispopulated FROM pg_matviews WHERE schemaname = '{cdbMain.QGIS_PKG_SCHEMA}';""")
            mat_views = cur.fetchall()
            mat_views, status = list(zip(*mat_views))
            mat_views = dict(zip(mat_views,status))
        cdbMain.conn.commit()
        return mat_views

    except (Exception, psycopg2.Error) as error:
        gen_f.critical_log(
            func=fetch_mat_views,
            location=FILE_LOCATION,
            header="Retrieving list of materialized views",
            error=error)
        cdbMain.conn.rollback()


def fetch_feature_types_checker(cdbMain: CDBToolsMain) -> tuple:
    """SQL query that retrieves the available feature types 

    *   :returns: Dictionary with feature type as key and populated status as boolean value.
        :rtype: tuple
    """
    dlg = cdbMain.loader_dlg

    if dlg.CDB_SCHEMA_EXTENTS == dlg.LAYER_EXTENTS:
        extents = None
    else:
        # Convert QgsRectangle into WKT polygon format
        extents: str = dlg.CURRENT_EXTENTS.asWktPolygon()  

    query = pysql.SQL("""
        SELECT feature_type 
        FROM qgis_pkg.feature_type_checker({_cdb_schema},{_extents}) 
        WHERE exists_in_db IS TRUE 
        ORDER BY feature_type;
        """).format(
        _cdb_schema = pysql.Literal(cdbMain.CDB_SCHEMA),
        _extents = pysql.Literal(extents)
        )  

    try:
        with cdbMain.conn.cursor() as cur:
            cur.execute(query)
            result = cur.fetchall()
        cdbMain.conn.commit()
        feat_types = tuple(zip(*result))[0]
        return feat_types

    except (Exception, psycopg2.Error) as error:
        cdbMain.conn.rollback()
        gen_f.critical_log(
            func=fetch_feature_types_checker,
            location=FILE_LOCATION,
            header="Retrieving list of available feature types in selected area",
            error=error)


def fetch_unique_feature_types_in_layer_metadata(cdbMain: CDBToolsMain) -> tuple:
    """SQL query that retrieves the available feature types 

    *   :returns: Dictionary with feature type as key and populated status as boolean value.
        :rtype: tuple
    """
    query = pysql.SQL("""
        SELECT DISTINCT feature_type 
        FROM {_usr_schema}.layer_metadata
        WHERE cdb_schema = {_cdb_schema}
        ORDER BY feature_type ASC;
        """).format(
        _usr_schema = pysql.Identifier(cdbMain.USR_SCHEMA),
        _cdb_schema = pysql.Literal(cdbMain.CDB_SCHEMA)
        )

    try:
        with cdbMain.conn.cursor() as cur:
            cur.execute(query)
            res = cur.fetchall()
        cdbMain.conn.commit()

        if not res:
            return None
        else:
            feat_types = tuple(elem[0] for elem in res)
            # print(feat_types)
            return feat_types

    except (Exception, psycopg2.Error) as error:
        gen_f.critical_log(
            func=fetch_unique_feature_types_in_layer_metadata,
            location=FILE_LOCATION,
            header=f"Retrieving unique Feature Types in {cdbMain.USR_SCHEMA}.layer_metadata for cdb_schema {cdbMain.CDB_SCHEMA}",
            error=error)
        cdbMain.conn.rollback()


def count_cityobjects_in_cdb_schema(cdbMain: CDBToolsMain) -> int:
    """SQL query that retrieves the number of cityobjects in the current cdb_schema 

    *   :returns: number of cityobjects in the current cdb_schema.
        :rtype: integer
    """
    query = pysql.SQL("""
        SELECT count(id) AS co_number FROM {_cdb_schema}.cityobject;
        """).format(
        _cdb_schema = pysql.Identifier(cdbMain.CDB_SCHEMA)
        )

    try:
        with cdbMain.conn.cursor() as cur:
            cur.execute(query)
            res = cur.fetchone()[0]
        cdbMain.conn.commit()

        return res

    except (Exception, psycopg2.Error) as error:
        gen_f.critical_log(
            func=fetch_unique_feature_types_in_layer_metadata,
            location=FILE_LOCATION,
            header=f"Retrieving number of cityobjects in cdb_schema {cdbMain.CDB_SCHEMA}",
            error=error)
        cdbMain.conn.rollback()


    
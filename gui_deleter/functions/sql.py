"""This module contains functions that relate to the server side operations.

These functions are responsible to communicate and fetch data from
the database with sql queries or sql function calls.
"""
import psycopg2

from ....cdb_loader import CDBLoader  # Used only to add the type of the function parameters

from ...shared.functions import general_functions as gen_f

FILE_LOCATION = gen_f.get_file_relative_path(file=__file__)


def get_root_classes(cdbLoader, extent):
    with cdbLoader.conn.cursor() as cur:
        root_class_query = f'''SELECT distinct classname
                               FROM {cdbLoader.CDB_SCHEMA}.objectclass as oc
                               JOIN {cdbLoader.CDB_SCHEMA}.cityobject as co 
                               ON oc.id = co.objectclass_id
                               WHERE (co.envelope && ST_MakeEnvelope({extent.xMinimum()}, {extent.yMinimum()}, 
                               {extent.xMaximum()}, {extent.yMaximum()},28992))
                               AND oc.is_toplevel = 1'''
        cur.execute(root_class_query)
        return [f[0] for f in cur.fetchall()]

def fetch_precomputed_extents(cdbLoader: CDBLoader, usr_schema: str, cdb_schema: str, ext_type: str) -> str:
    """SQL query that reads and retrieves extents stored in {usr_schema}.extents

    *   :returns: Extents as WKT or None if the entry is empty.
        :rtype: str
    """
    try:
        with cdbLoader.conn.cursor() as cur:
            # Get cdb_schema extents from server as WKT.
            cur.execute(query= f"""
                                   SELECT ST_AsText(envelope) FROM "{usr_schema}".extents 
                                   WHERE cdb_schema = '{cdb_schema}' AND bbox_type = '{ext_type}';
                                """)
            extents = cur.fetchone()
            # extents = (None,) when the envelope is Null,
            # BUT extents = None when the query returns NO results.
            if type(extents) == tuple:
                extents = extents[0] # Get the value without trailing comma.

        cdbLoader.conn.commit()
        return extents

    except (Exception, psycopg2.Error) as error:
        gen_f.critical_log(
            func=fetch_precomputed_extents,
            location=FILE_LOCATION,
            header=f"Retrieving extents of schema {cdb_schema}",
            error=error)
        cdbLoader.conn.rollback()


def fetch_cdb_schema_srid(cdbLoader: CDBLoader) -> int:
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
        gen_f.critical_log(
            func=fetch_cdb_schema_srid,
            location=FILE_LOCATION,
            header="Retrieving srid",
            error=error)
        cdbLoader.conn.rollback()


def fetch_layer_metadata(cdbLoader: CDBLoader, usr_schema: str, cdb_schema: str, cols: str="*") -> tuple:
    """SQL query that retrieves the current schema's layer metadata from {usr_schema}.layer_metadata table. 
    By default it retrieves all columns.

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
        gen_f.critical_log(
            func=fetch_layer_metadata,
            location=FILE_LOCATION,
            header="Retrieving layers metadata",
            error=error)
        cdbLoader.conn.rollback()


def exec_compute_cdb_schema_extents(cdbLoader: CDBLoader) -> tuple:
    """Calls the qgis_pkg function that computes the cdb_schema extents.

    *   :returns: is_geom_null, x_min, y_min, x_max, y_max, srid
        :rtype: tuple
    """
    try:
        with cdbLoader.conn.cursor() as cur:
            # Execute server function to compute the schema's extents
            cur.callproc(f"""{cdbLoader.QGIS_PKG_SCHEMA}.compute_cdb_schema_extents""",[cdbLoader.CDB_SCHEMA])
            values = cur.fetchone()
            cdbLoader.conn.commit()
            if values:
                is_geom_null, x_min, y_min, x_max, y_max, srid = values
                return is_geom_null, x_min, y_min, x_max, y_max, srid
            else:
                return None

    except (Exception, psycopg2.Error) as error:
        gen_f.critical_log(
            func=exec_compute_cdb_schema_extents,
            location=FILE_LOCATION,
            header=f"Computing extents of the schema '{cdbLoader.CDB_SCHEMA}'",
            error=error)
        cdbLoader.conn.rollback()


def exec_upsert_extents(cdbLoader: CDBLoader, usr_schema: str, cdb_schema: str, bbox_type: str, extents_wkt_2d_poly: str) -> int:
    """Calls a QGIS Package function to insert (or update) the extents geometry in table qgis_{usr}.extents.

    *   :param bbox_type: one of ['db_schema', 'm_view', 'qgis']
        :type bbox_type: str

    *   :param extents_2d_poly: wkt of a polygon, 2D and withouth SRID
        :type extents_2d_poly: str

    *   :returns: upserted_id
        :rtype: int
    """
    try:
        with cdbLoader.conn.cursor() as cur:
            upserted_id = cur.callproc(f"""{cdbLoader.QGIS_PKG_SCHEMA}.upsert_extents""",[usr_schema, cdb_schema, bbox_type, extents_wkt_2d_poly])
        cdbLoader.conn.commit()
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
        cdbLoader.conn.rollback()

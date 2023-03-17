"""This module contains functions that relate to the server side operations.

These functions are responsible to communicate and fetch data from
the database with sql queries or sql function calls.
"""
from __future__ import annotations
from typing import TYPE_CHECKING  #, Union
if TYPE_CHECKING:       
    from ...gui_deleter.deleter_dialog import CDB4DeleterDialog

import psycopg2, psycopg2.sql as pysql
from psycopg2.extras import NamedTupleCursor

from ...shared.functions import general_functions as gen_f

FILE_LOCATION = gen_f.get_file_relative_path(file=__file__)

def exec_list_cdb_schemas_extended(dlg: CDB4DeleterDialog) -> list:
    """SQL function that retrieves the database cdb_schemas for the current database, 
    included the privileges status for the selected usr_name

    *   :returns: A list of named tuples with all usr_schemas, the number of available cityobecjts, 
         and the user's privileges for each cdb_schema in the current database
        :rtype: list(tuple(cdb_schema, co_number, priv_type))
    """
    query = pysql.SQL("""
        SELECT cdb_schema, co_number, priv_type FROM {_qgis_pkg_schema}.list_cdb_schemas_with_privileges({_usr_name});
        """).format(
        _qgis_pkg_schema = pysql.Identifier(dlg.QGIS_PKG_SCHEMA),
        _usr_name = pysql.Literal(dlg.DB.username)
        )

    try:
        with dlg.conn.cursor(cursor_factory=NamedTupleCursor) as cur:
            cur.execute(query)
            res = cur.fetchall()
        dlg.conn.commit()

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
        dlg.conn.rollback()


def is_superuser(dlg: CDB4DeleterDialog) -> bool:
    """SQL query that determines whether the connecting user has administrations privileges.

    *   :returns: Admin status
        :rtype: bool
    """
    # Think whether you can use the function in the qgis_pkg or not, 
    # because we may have not yet installed the qgis_pkg
    # This one does not depend on the qgis_pkg

    query = pysql.SQL("""
        SELECT 1 FROM pg_user WHERE usesuper IS TRUE AND usename = {_usr_name};
        """).format(
        _usr_name = pysql.Literal(dlg.DB.username)
        )

    try:
        with dlg.conn.cursor() as cur:
            cur.execute(query)
            res = cur.fetchone() # as (1,) or None
        dlg.conn.commit()

        if res:
            return True
        else:
            return False

    except (Exception, psycopg2.Error) as error:
        gen_f.critical_log(
            func=is_superuser,
            location=FILE_LOCATION,
            header=f"Checking whether the current user is a database superuser",
            error=error)
        dlg.conn.rollback()


def fetch_precomputed_extents(dlg: CDB4DeleterDialog, usr_schema: str, cdb_schema: str, ext_type: str) -> str:
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
        with dlg.conn.cursor() as cur:
            cur.execute(query)
            extents = cur.fetchone()
            # extents = (None,) when the envelope is Null,
            # BUT extents = None when the query returns NO results.
            if type(extents) == tuple:
                extents = extents[0] # Get the value without trailing comma.

        dlg.conn.commit()
        return extents

    except (Exception, psycopg2.Error) as error:
        gen_f.critical_log(
            func=fetch_precomputed_extents,
            location=FILE_LOCATION,
            header=f"Retrieving extents of schema {cdb_schema}",
            error=error)
        dlg.conn.rollback()


def fetch_cdb_schema_srid(dlg: CDB4DeleterDialog) -> int:
    """SQL query that reads and retrieves the current schema's srid from {cdb_schema}.database_srs

    *   :returns: srid number
        :rtype: int
    """
    # Get database srid
    query = pysql.SQL("""
        SELECT srid FROM {_cdb_schema}.database_srs LIMIT 1;
        """).format(
        _cdb_schema = pysql.Identifier(dlg.CDB_SCHEMA)
        )
   
    try:
        with dlg.conn.cursor() as cur:

            cur.execute(query)
            srid = cur.fetchone()[0] # Tuple has trailing comma.
        dlg.conn.commit()
        return srid

    except (Exception, psycopg2.Error) as error:
        gen_f.critical_log(
            func=fetch_cdb_schema_srid,
            location=FILE_LOCATION,
            header="Retrieving srid",
            error=error)
        dlg.conn.rollback()


def exec_compute_cdb_schema_extents(dlg: CDB4DeleterDialog) -> tuple:
    """Calls the qgis_pkg function that computes the cdb_schema extents.

    *   :returns: is_geom_null, x_min, y_min, x_max, y_max, srid
        :rtype: tuple
    """
    # Prepare query to execute server function to compute the schema's extents
    query = pysql.SQL("""
        SELECT * FROM {_qgis_pkg_schema}.compute_cdb_schema_extents({_cdb_schema});
        """).format(
        _qgis_pkg_schema = pysql.Identifier(dlg.QGIS_PKG_SCHEMA),
        _cdb_schema = pysql.Literal(dlg.CDB_SCHEMA)
        )

    try:
        with dlg.conn.cursor() as cur:
            cur.execute(query)
            values = cur.fetchone()
            dlg.conn.commit()
            if values:
                is_geom_null, x_min, y_min, x_max, y_max, srid = values
                return is_geom_null, x_min, y_min, x_max, y_max, srid
            else:
                return None

    except (Exception, psycopg2.Error) as error:
        gen_f.critical_log(
            func=exec_compute_cdb_schema_extents,
            location=FILE_LOCATION,
            header=f"Computing extents of the schema '{dlg.CDB_SCHEMA}'",
            error=error)
        dlg.conn.rollback()


def exec_upsert_extents(dlg: CDB4DeleterDialog, bbox_type: str, extents_wkt_2d_poly: str) -> int:
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
        SELECT {_qgis_pkg_schema}.upsert_extents({_usr_schema},{_cdb_schema},{_bbox_type},{_extents},{_is_geographic});
        """).format(
        _qgis_pkg_schema = pysql.Identifier(dlg.QGIS_PKG_SCHEMA),
        _usr_schema = pysql.Literal(dlg.USR_SCHEMA),
        _cdb_schema = pysql.Literal(dlg.CDB_SCHEMA),
        _bbox_type = pysql.Literal(bbox_type),
        _extents = pysql.Literal(extents_wkt_2d_poly),
        _is_geographic = pysql.Literal(dlg.CRS_is_geographic)
        )

    try:
        with dlg.conn.cursor() as cur:
            cur.execute(query)
            upserted_id = cur.fetchone()[0] # Tuple has trailing comma.
        dlg.conn.commit()
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
        dlg.conn.rollback()


def fetch_feature_types_checker(dlg: CDB4DeleterDialog) -> tuple:
    """SQL query that retrieves the available feature types 

    *   :returns: Dictionary with feature type as key and populated status as boolean value.
        :rtype: tuple
    """
    if dlg.CDB_SCHEMA_EXTENTS == dlg.DELETE_EXTENTS:
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
        _cdb_schema = pysql.Literal(dlg.CDB_SCHEMA),
        _extents = pysql.Literal(extents)
        )  

    try:
        with dlg.conn.cursor() as cur:
            cur.execute(query)
            result = cur.fetchall()
        dlg.conn.commit()
        feat_types = tuple(zip(*result))[0]
        return feat_types

    except (Exception, psycopg2.Error) as error:
        gen_f.critical_log(
            func=fetch_feature_types_checker,
            location=FILE_LOCATION,
            header="Retrieving list of available feature types in selected area",
            error=error)
        dlg.conn.rollback()


def cleanup_cdb_schema(dlg: CDB4DeleterDialog) -> bool:
    """SQL query that cleans up the cdb_schema (truncates all tables) in the current database
    """
    query = pysql.SQL("""
        SELECT {_qgis_pgk_schema}.cleanup_schema({_cdb_schema});
        """).format(
        _qgis_pgk_schema = pysql.Identifier(dlg.QGIS_PKG_SCHEMA),
        _cdb_schema = pysql.Literal(dlg.CDB_SCHEMA)
        )

    try:
        with dlg.conn.cursor() as cur:
            cur.execute(query)
            res = cur.execute(query)
        dlg.conn.commit()
        # print('from database:', res) # should be None is all goes well
        return True
    
    except (Exception, psycopg2.Error) as error:
        dlg.conn.rollback()
        gen_f.critical_log(
            func=cleanup_cdb_schema,
            location=FILE_LOCATION,
            header=f"Cleaning up cdb_schema '{dlg.CDB_SCHEMA}'",
            error=error)
        return False


def fetch_top_class_features_counter(dlg: CDB4DeleterDialog, extents_wkt_2d: str) -> list:
    """SQL query that retrieves the number of available top-class features 

    *   :returns: List of named tuples, each one corresponding to a record.
        :rtype: list of named tuples (RECORD)
    """
    top_class_features = [] # empty list

    query = pysql.SQL("""
        SELECT feature_type, root_class, objectclass_id, n_feature 
        FROM qgis_pkg.root_class_counter({_cdb_schema},{_extents}) 
        WHERE n_feature > 0 
        ORDER BY feature_type, root_class;
        """).format(
        _cdb_schema = pysql.Literal(dlg.CDB_SCHEMA),
        _extents = pysql.Literal(extents_wkt_2d)
        )  

    try:
        with dlg.conn.cursor(cursor_factory=NamedTupleCursor) as cur:
            cur.execute(query)
            res = cur.fetchall()
        dlg.conn.commit()
        # print ("from the db", res)

        if not res:
            top_class_features = []
        else: 
            top_class_features = res
        
        return top_class_features 

    except (Exception, psycopg2.Error) as error:
        dlg.conn.rollback()
        gen_f.critical_log(
            func=fetch_top_class_features_counter,
            location=FILE_LOCATION,
            header="Retrieving list and quantity of available top-class features in selected area",
            error=error)
        

       

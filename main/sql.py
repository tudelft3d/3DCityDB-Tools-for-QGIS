"""This module contains functions that relate to the server side
operations.

These functions are responsible to communicate and fetch data from
the database with sql queries all sql function calls.
"""
#TODO: Catching error and logging code block seems too repretive,
# could probably set it as a function

import time

from qgis.core import QgsMessageLog, Qgis
import psycopg2


from . import constants

FILE_LOCATION = constants.get_file_location(file=__file__)

def fetch_extents(dbLoader, type: str) -> str:
    """SQL query thar reads and retrieves extents stored in qgis_pkg.extents
    *   :returns: Extents as WKT or None if the entry is empty.
        
        :rtype: str
    """
    try:
        t0 = time.time()
    
        # Create cursor.
        with dbLoader.conn.cursor() as cur:
            # Get db_schema extents from server as WKT.
            cur.execute(query= f"""  
                                SELECT ST_AsText(envelope) 
                                FROM qgis_pkg.extents 
                                WHERE schema_name = '{dbLoader.SCHEMA}'
                                AND bbox_type = '{type}';
                                """)
            extents = cur.fetchone()[0] # Tuple has trailing comma.
        dbLoader.conn.commit()

        t1 = time.time()
        print("time to fetch extents from server: ",t1-t0)
        
        return extents

    except (Exception, psycopg2.Error) as error:
        # Get the location to show in log where an issue happens
        function_name = fetch_extents.__name__
        location = ">".join([FILE_LOCATION,function_name])

        # Specify in the header the type of error and where it happend.
        header = constants.log_errors.format(type="Fetching extents", loc=location)

        # Show the error in the log panel. Should open it even if its closed.
        QgsMessageLog.logMessage(message=header + str(error),
            tag="3DCityDB-Loader",
            level=Qgis.Critical,
            notifyUser=True)
        cur.close()
        dbLoader.conn.rollback()
        return False


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
        # Get the location to show in log where an issue happens
        function_name = fetch_crs.__name__
        location = ">".join([FILE_LOCATION,function_name])

        # Specify in the header the type of error and where it happend.
        header = constants.log_errors.format(type="Fetching srid", loc=location)

        # Show the error in the log panel. Should open it even if its closed.
        QgsMessageLog.logMessage(message=header + str(error),
            tag="3DCityDB-Loader",
            level=Qgis.Critical,
            notifyUser=True)
        cur.close()
        dbLoader.conn.rollback()
        return False

def fetch_layer_metadata(dbLoader) -> tuple:
    try:
        t0 = time.time()
        with dbLoader.conn.cursor() as cur:
            cur.execute(f"""
                        SELECT * FROM qgis_pkg.layer_metadata
                        WHERE schema_name = '{dbLoader.SCHEMA}'
                        AND n_features > 0;
                        """)
            metadata=cur.fetchall()
            colnames = [desc[0] for desc in cur.description]
        dbLoader.conn.commit()


        t1 = time.time()
        print("time to fetch metadata from server: ",t1-t0)
        return colnames, metadata

    except (Exception, psycopg2.Error) as error:
        # Get the location to show in log where an issue happens
        function_name = fetch_layer_metadata.__name__
        location = ">".join([FILE_LOCATION,function_name])

        # Specify in the header the type of error and where it happend.
        header = constants.log_errors.format(type="Fetching layer metadata",
            loc=location)

        # Show the error in the log panel. Should open it even if its closed.
        QgsMessageLog.logMessage(message=header + str(error),
            tag="3DCityDB-Loader",
            level=Qgis.Critical,
            notifyUser=True)
        cur.close()
        dbLoader.conn.rollback()
        return False

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
        # Get the location to show in log where an issue happens
        function_name = fetch_crs.__name__
        location = ">".join([FILE_LOCATION,function_name])

        # Specify in the header the type of error and where it happend.
        header = constants.log_errors.format(type="Computing extents", loc=location)

        # Show the error in the log panel. Should open it even if its closed.
        QgsMessageLog.logMessage(message=header + str(error),
            tag="3DCityDB-Loader",
            level=Qgis.Critical,
            notifyUser=True)
        cur.close()
        dbLoader.conn.rollback()
        return False

def exec_create_mview(dbLoader) -> tuple:
    """SQL qgis_pkg function that creates the schema's 
    materialised views.
    """
    try:    
        with dbLoader.conn.cursor() as cur:
            # Execute server function to compute the schema's extents 
            cur.callproc("qgis_pkg.create_mview",[dbLoader.SCHEMA])
        dbLoader.conn.commit()

    except (Exception, psycopg2.Error) as error:
        # Get the location to show in log where an issue happens
        function_name = exec_create_mview.__name__
        location = ">".join([FILE_LOCATION,function_name])

        # Specify in the header the type of error and where it happend.
        header = constants.log_errors.format(type="Creating mat views",
            loc=location)

        # Show the error in the log panel. Should open it even if its closed.
        QgsMessageLog.logMessage(message=header + str(error),
            tag="3DCityDB-Loader",
            level=Qgis.Critical,
            notifyUser=True)
        cur.close()
        dbLoader.conn.rollback()
        return False

def exec_create_updatable_views(dbLoader) -> tuple:
    """SQL qgis_pkg function that creates the schema's 
    updatable views.
    """
    try:    
        with dbLoader.conn.cursor() as cur:
            # Execute server function to compute the schema's extents.
            cur.callproc("qgis_pkg.create_updatable_views",[dbLoader.SCHEMA])
        dbLoader.conn.commit()

    except (Exception, psycopg2.Error) as error:
        # Get the location to show in log where an issue happens
        function_name = exec_create_updatable_views.__name__
        location = ">".join([FILE_LOCATION,function_name])

        # Specify in the header the type of error and where it happend.
        header = constants.log_errors.format(type="Creating upd views",
            loc=location)

        # Show the error in the log panel. Should open it even if its closed.
        QgsMessageLog.logMessage(message=header + str(error),
            tag="3DCityDB-Loader",
            level=Qgis.Critical,
            notifyUser=True)
        cur.close()
        dbLoader.conn.rollback()
        return False

def exec_view_counter(dbLoader, view: constants.View) -> int:
    
    try:
        # Convert QgsRectanlce into WKT polygon format
        extents = dbLoader.EXTENTS.asWktPolygon()

        t0 = time.time()
        with dbLoader.conn.cursor() as cur:
            # Execute server function to get the number of objects in extents.
            cur.callproc("qgis_pkg.view_counter",[view.v_name,extents])
            count = cur.fetchone()[0] # Tuple has trailing comma.
        dbLoader.conn.commit()
        

        t1 = time.time()
        print("time to count view objs from server: ",t1-t0)
        # Assign the result to the view object.
        view.n_selected = count
        return count

    except (Exception, psycopg2.Error) as error:
        # Get the location to show in log where an issue happens
        function_name = exec_view_counter.__name__
        location = ">".join([FILE_LOCATION,function_name])

        # Specify in the header the type of error and where it happend.
        header = constants.log_errors.format(type="Coutning view n_selected",
            loc=location)

        # Show the error in the log panel. Should open it even if its closed.
        QgsMessageLog.logMessage(message=header + str(error),
            tag="3DCityDB-Loader",
            level=Qgis.Critical,
            notifyUser=True)
        cur.close()
        dbLoader.conn.rollback()
        return False


def fetch_mat_views(dbLoader) -> list:
    """SQL query thar reads and retrieves the current schema's
    materialised views from pg_matviews
    *   :returns: Materialized view with populated status 
        
        :rtype: list
    """
    try:
        t0 = time.time()
        with dbLoader.conn.cursor() as cur:
            # Get database srid.
            cur.execute(query= f"""
                                SELECT matViewname, ispopulated 
                                FROM pg_matviews
                                WHERE schemaname = 'qgis_pkg';
                                """)
            mat_views = cur.fetchall()
        dbLoader.conn.commit()

        t1 = time.time()
        print("time to fetch mat views from server: ",t1-t0)
        return mat_views

    except (Exception, psycopg2.Error) as error:
        # Get the location to show in log where an issue happens
        function_name = fetch_mat_views.__name__
        location = ">".join([FILE_LOCATION,function_name])

        # Specify in the header the type of error and where it happend.
        header = constants.log_errors.format(type="Fetching mat views",
             loc=location)

        # Show the error in the log panel. Should open it even if its closed.
        QgsMessageLog.logMessage(message=header + str(error),
            tag="3DCityDB-Loader",
            level=Qgis.Critical,
            notifyUser=True)
        cur.close()
        dbLoader.conn.rollback()
        return False



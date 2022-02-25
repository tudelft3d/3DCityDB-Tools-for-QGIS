"""This module contains functions that relate to the 'Connection Tab'
(in the GUI look for the elephant).

These functions are usually called from widget_setup functions 
relating to child widgets of the 'Connection Tab'.
"""

from .connection import connect
from . import constants
from qgis.core import QgsMessageLog,Qgis
import psycopg2

def open_connection(dbLoader) -> bool:
    """Opens a connection using the parameters stored in DBLoader.DB
    and retrieves the server's verison

    *   :returns: connection attempt results

        :rtype: bool
    """

    try:
        # Open the connection.
        dbLoader.conn = connect(dbLoader.DB)

        # Create cursor.
        with dbLoader.conn.cursor() as cur:
            # Get server to fetch its version
            cur.execute(query="SHOW server_version;")
            version = cur.fetchone()[0] # Tuple has trailing comma.
            dbLoader.conn.commit()

        # Store verison into the connection object.
        dbLoader.DB.s_version = version

    except (Exception, psycopg2.Error) as error:
        # Get the location to show in log where an issue happenes
        FUNCTION_NAME = open_connection.__name__
        FILE_LOCATION = constants.get_file_location(file=__file__)
        LOCATION = ">".join([FILE_LOCATION,FUNCTION_NAME])

        # Specify in the header the type of error and where it happend.
        header = constants.log_errors.format(type="Connection", loc=LOCATION)

        # Show the error in the log panel. Should open it even if its closed.
        QgsMessageLog.logMessage(message=header + str(error),
            tag="3DCityDB-Loader",
            level=Qgis.Critical,
            notifyUser=True)
        cur.close()
        dbLoader.conn.rollback()
        return False

    return True

def is_3dcitydb(dbLoader):
    """ Checks if current database has specific 3DCityDB requirements.\n
    Requiremnt list:
        > Extentions: postgis, uuid-ossp, postgis_sfcgal
        > Schemas: citydb_pkg
        > Tables: cityobject, building, surface_geometry
        

    """ 
    database = dbLoader.dlg.cbxExistingConnection.currentData()
    try:
        cur = dbLoader.conn.cursor()  
        cur.execute("SELECT version FROM citydb_pkg.citydb_version();")
        version= cur.fetchall()
        cur.close()
        database.c_version= version[0][0]
        return 1

    except (Exception, psycopg2.DatabaseError) as error:
        print(error)
        dbLoader.conn.rollback()
        cur.close()


def get_schemas(dbLoader):
    """Gets all schemas that exist in database"""

    try:
        cur = dbLoader.conn.cursor()

        #Get all schemas
        cur.execute("SELECT schema_name,'' FROM information_schema.schemata WHERE schema_name != 'information_schema' AND NOT schema_name LIKE '%pg%' ORDER BY schema_name ASC")
        schemas = cur.fetchall()
        cur.close()
        
        schemas,empty=zip(*schemas)
        dbLoader.schemas = list(schemas)

    except (Exception, psycopg2.DatabaseError) as error:
        print("At 'get_schemas:",error)
        dbLoader.conn.rollback()
        cur.close()

def fill_schema_box(dbLoader):
    """Fils schema combo box with ONLY those schemas that contain the feature tables (citydb: YES, public: NO)"""
    dbLoader.dlg.cbxSchema.clear()

    for schema in dbLoader.schemas: 
        res = schema_has_features(dbLoader,schema,constants.features_tables)
        if res:
            dbLoader.dlg.cbxSchema.addItem(schema,res)

def schema_has_features(dbLoader,schema,features):
    cur=dbLoader.conn.cursor() #TODO move this to sql
    try:
        cur.execute(f"""SELECT table_name, table_schema FROM information_schema.tables 
                        WHERE table_schema = '{schema}' 
                        AND table_name SIMILAR TO '{constants.get_postgres_array(features)}'
                        ORDER BY table_name ASC""")
        feature_response= cur.fetchall() #All tables relevant to the thematic surfaces
        cur.close()
        return feature_response

    except (Exception, psycopg2.DatabaseError) as error:
        print('In connection_tab.schema_has_box',error)
        cur.close()

def schema_privileges(dbLoader):
    selected_schema = dbLoader.dlg.cbxSchema.currentText()
    if not selected_schema: return
    try:
        cur = dbLoader.conn.cursor()
        #Get all schemas
        cur.execute(f""" 
        WITH "schemas"("schema") AS (
        SELECT n.nspname AS "name"
            FROM pg_catalog.pg_namespace n
            WHERE n.nspname !~ '^pg_'
                AND n.nspname <> 'information_schema'
        ) SELECT
        pg_catalog.has_schema_privilege(current_user, "schema", 'CREATE') AS "create",
        pg_catalog.has_schema_privilege(current_user, "schema", 'USAGE') AS "usage"
        FROM "schemas"
        WHERE schema='{selected_schema}';""")
        privileges_bool = cur.fetchone()
        colnames = [desc[0] for desc in cur.description]
        privileges_dict= dict(zip(colnames.upper(),privileges_bool))
        
        return privileges_dict

    except (Exception, psycopg2.DatabaseError) as error:
        dbLoader.iface.messageBar().pushMessage(str(error), level=Qgis.Critical,duration=10)
        QgsMessageLog.logMessage("At connection_tab.py>'schema_privileges':\nerror_message: "+str(error),tag="3DCityDB-Loader",level=Qgis.Critical,notifyUser=True)
        dbLoader.conn.rollback()
        cur.close()
        return None
    
def table_privileges(dbLoader):
    selected_schema = dbLoader.dlg.cbxSchema.currentText()
    try:
        cur = dbLoader.conn.cursor()
        #Get all schemas
        cur.execute(f""" 
        WITH "tables"("table") AS (
        SELECT table_name FROM information_schema.tables 
	    WHERE table_schema = '{selected_schema}' AND table_type = 'BASE TABLE'
        ) SELECT
        pg_catalog.has_table_privilege(current_user, "table", 'DELETE') AS "delete",
        pg_catalog.has_table_privilege(current_user, "table", 'SELECT') AS "select",
        pg_catalog.has_table_privilege(current_user, "table", 'REFERENCES') AS "references",
        pg_catalog.has_table_privilege(current_user, "table", 'TRIGGER') AS "trigger",
        pg_catalog.has_table_privilege(current_user, "table", 'TRUNCATE') AS "truncate",
        pg_catalog.has_table_privilege(current_user, "table", 'UPDATE') AS "update",
        pg_catalog.has_table_privilege(current_user, "table", 'INSERT') AS "insert"
        FROM "tables";""")
        privileges_bool = cur.fetchone()
        colnames = [desc[0] for desc in cur.description]
        privileges_dict= dict(zip([col.upper() for col in colnames],privileges_bool))
        
        return privileges_dict

    except (Exception, psycopg2.DatabaseError) as error:
        dbLoader.iface.messageBar().pushMessage(str(error), level=Qgis.Critical,duration=10)
        QgsMessageLog.logMessage("At connection_tab.py>'table_privileges':\nerror_message: "+str(error),tag="3DCityDB-Loader",level=Qgis.Critical,notifyUser=True)
        dbLoader.conn.rollback()
        cur.close()
        return None

def true_privileges(allpriv_dict):
    true_privileges=[]
    for key, value in allpriv_dict.items():
        if value == True:
            true_privileges.append(key)
    return true_privileges



def successful_connection_tab(dbLoader):

    dbLoader.dlg.tbImport.setDisabled(False)
    dbLoader.dlg.btnClearDB.setDisabled(False)
    text= dbLoader.dlg.btnClearDB.currentText()
    dbLoader.dlg.btnClearDB.setText(text.format(DB="dbLoader.dlg.cbxExistingConnection.currentData().database_name"))
    dbLoader.dlg.grbSchema.setDisabled(False)
    dbLoader.dlg.grbFeature.setDisabled(True)
    dbLoader.dlg.grbGeometry.setDisabled(True)
    dbLoader.dlg.gbxExtent.setDisabled(True)
    dbLoader.dlg.wdgMain.setCurrentIndex(1) #Auto-Move to Import tab



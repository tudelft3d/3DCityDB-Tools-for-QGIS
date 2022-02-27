"""This module contains functions that relate to the 'Connection Tab'
(in the GUI look for the elephant).

These functions are usually called from widget_setup functions 
relating to child widgets of the 'Connection Tab'.
"""

from .connection import connect
from . import sql
from . import constants
from qgis.core import QgsMessageLog,Qgis
import psycopg2

def open_connection(dbLoader) -> bool:
    """Opens a connection using the parameters stored in DBLoader.DB
    and retrieves the server's verison. The server version is stored
    in 's_version' attribute of the Connection object.

    *   :returns: connection attempt results

        :rtype: bool
    """

    try:
        # Open the connection.
        dbLoader.conn = connect(dbLoader.DB)
        dbLoader.conn.commit() # This seems redundant.

        # Get server version.
        version = sql.fetch_server_version(dbLoader)

        # Store verison into the connection object.
        dbLoader.DB.s_version = version

    except (Exception, psycopg2.Error) as error:
        # Get the location to show in log where an issue happenes
        FUNCTION_NAME = open_connection.__name__
        FILE_LOCATION = constants.get_file_location(file=__file__)
        LOCATION = ">".join([FILE_LOCATION,FUNCTION_NAME])

        # Specify in the header the type of error and where it happend.
        header = constants.log_errors.format(type="Attempting connection", loc=LOCATION)

        # Show the error in the log panel. Should open it even if its closed.
        QgsMessageLog.logMessage(message=header + str(error),
            tag="3DCityDB-Loader",
            level=Qgis.Critical,
            notifyUser=True)
        dbLoader.conn.rollback()
        return False

    return True

def is_3dcitydb(dbLoader) -> bool:
    """Function that checks if the current database has 
    3DCityDB installed. The check is done by querying the 3DCityDB
    version from citydb_pkg.version().

    On 3DCityDB absence a database error is emited which means that 
    it is not installed.

    Note for future 3DCityDB version: this function MUST be updated
    for every change in the abovementioned 3DCitydb function's name 
    or schema.
    """
    
    # Get 3DCityDB version
    version = sql.fetch_3dcitydb_version(dbLoader)

    if version: # Could be None
        # Store verison into the connection object.
        dbLoader.DB.c_version = version
        return True
    return False


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
        return schemas

    except (Exception, psycopg2.DatabaseError) as error:
        print("At 'get_schemas:",error)
        dbLoader.conn.rollback()
        cur.close()

def fill_schema_box(dbLoader, schemas: tuple) -> None:
    """Function that fills schema combo box with the provided schemas."""

    # Clear combo box from previous entries
    dbLoader.dlg.cbxSchema.clear()

    for schema in schemas: 
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
        WITH t AS (
		SELECT concat('{selected_schema}','.',i.table_name)::varchar AS qualified_table_name
		FROM information_schema.tables AS i
		WHERE table_schema = '{selected_schema}' 
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
        colnames = [desc[0] for desc in cur.description]
        privileges_dict= dict(zip([col.upper() for col in colnames],privileges_bool))
        
        return privileges_dict

    except (Exception, psycopg2.DatabaseError) as error:
        dbLoader.iface.messageBar().pushMessage(str(error), level=Qgis.Critical,duration=10)
        QgsMessageLog.logMessage("At connection_tab.py>'table_privileges':\nerror_message: "+str(error),tag="3DCityDB-Loader",level=Qgis.Critical,notifyUser=True)
        dbLoader.conn.rollback()
        cur.close()
        return None

def true_privileges(allpriv_dict: dict) -> list:
    """Function that returns the effective privieges names.
    From a dictionary dict{str,bool} coming from sql.fetch_table_privileges().

    *   :param allpriv_dict: Dicitonary containg a collection of user
        privileges as keys and their effectiveness as values.

        :type allpriv_dict: dict{str,bool}

    *   :returns: Effective user privileges
  
        :rtype: list
    """

    true_privileges=[]
    for priv_name, status in allpriv_dict.items():
        if status == True:
            true_privileges.append(priv_name)
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



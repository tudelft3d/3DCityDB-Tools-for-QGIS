from .connection import connect
import psycopg2

def is_connected(dbLoader):
    database = dbLoader.dlg.cbxExistingConnection.currentData()
    try:
        dbLoader.conn = connect(database) #Open the connection
        cur = dbLoader.conn.cursor()
        cur.execute("SHOW server_version;")
        version = cur.fetchone()
        database.s_version= version[0]

    except (Exception, psycopg2.DatabaseError) as error:
        print(error)
    finally:
        if dbLoader.conn is not None:
            cur.close()

    return 1

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

def has_schema_privileges(dbLoader):
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
        cur.close()
        if all(privileges_bool): return True

    except (Exception, psycopg2.DatabaseError) as error:
        print("At 'has_schema_privileges':",error)
        dbLoader.conn.rollback()
        cur.close()
    
def has_table_privileges(dbLoader):
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
        
        if all(privileges_bool): return True

    except (Exception, psycopg2.DatabaseError) as error:
        print("At 'has_table_privileges':",error)
        dbLoader.conn.rollback()
        cur.close()




def successful_connection_tab(dbLoader):

    dbLoader.dlg.tbImport.setDisabled(False)
    dbLoader.dlg.btnClearDB.setDisabled(False)
    dbLoader.dlg.btnClearDB.setText(f'Clear {dbLoader.dlg.cbxExistingConnection.currentData().database_name} from plugin contents')
    dbLoader.dlg.grbSchema.setDisabled(False)
    dbLoader.dlg.grbFeature.setDisabled(True)
    dbLoader.dlg.grbGeometry.setDisabled(True)
    dbLoader.dlg.grbExtent.setDisabled(True)
    dbLoader.dlg.wdgMain.setCurrentIndex(1) #Auto-Move to Import tab
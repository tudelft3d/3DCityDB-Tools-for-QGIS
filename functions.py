# -*- coding: utf-8 -*-
import os, configparser
import psycopg2
from qgis.core import QgsApplication, QgsVectorLayer, QgsProject, QgsDataSourceUri
from qgis.PyQt.QtWidgets import QMessageBox

class database_cred:
    def __init__(self,connection_name,database): 
        self.connection_name=connection_name
        self.database_name=database
        self.host=None
        self.port=None
        self.user=None
        self.password='*****'
        self.store_creds=None
        self.is_active=None
        self.id=id(self)
        self.hex_location=hex(self.id)
        

    def __str__(self):
        print(f"connection name: {self.connection_name}") 
        print(f"db name: {self.database_name}")
        print(f"host:{self.host}")
        print(f"port:{self.port}")
        print(f"user:{self.user}")
        print(f"password:{self.password[0]}{self.password[1]}*****")
        print(f"id:{self.id}")
        print(f"hex location:{self.hex_location}")
        return('\n')
    
    def add_to_collection(self,db_collection):
        db_collection.append(self)

def get_postgres_conn(dbLoader):
    """ Reads QGIS3.ini to get saved user connection parameters of postgres databases""" 

    #Current active profile directory #TODO: check if path exists #os.path.exists(my_path)
    profile_dir = QgsApplication.qgisSettingsDirPath()
    ini_path=os.path.join(profile_dir,"QGIS","QGIS3.ini")
    ini_path=os.path.normpath(ini_path)

    # Clear the contents of the comboBox from previous runs
    dbLoader.dlg.btnConnToExist.clear()

    

    parser = configparser.ConfigParser()

    #Makes path 'Case Sensitive'
    parser.optionxform = str 

    parser.read(ini_path)

    db_collection = []
    for key in parser['PostgreSQL']:
        current_connection_name = str(key).split("\\")[1] #NOTE: seems too hardcoded, might break in the feature if .ini structure changes
        
        #Show database and connection name into combobox
        if 'database' in str(key):
            database_cred
            database = parser['PostgreSQL'][key]

            #Create DB instance based on current connection. This IF (and the rest) is visited only once per connection  
            db_instance =database_cred(current_connection_name,database)
            db_instance.add_to_collection(db_collection)

            dbLoader.dlg.btnConnToExist.addItem(f'{current_connection_name}',db_instance)#hex(id(db_instance)))
            
        if 'host' in str(key):
            host = parser['PostgreSQL'][key]
            db_instance.host=host

        if 'port' in str(key):
            port = parser['PostgreSQL'][key]
            db_instance.port=port

        if 'user' in str(key):
            user = parser['PostgreSQL'][key]
            db_instance.user=user

        if 'password' in str(key): 
            password = parser['PostgreSQL'][key]
            db_instance.password=password
 
    #NOTE: the above implementation works but feels unstable! Test it 

    return db_collection

def connect(db):

    # connect to the PostgreSQL server
    connection = psycopg2.connect(dbname= db.database_name,
                            user= db.user,
                            password= db.password,
                            host= db.host,
                            port= db.port)
    return connection

def connect_and_check(dbLoader):
    """ Connect to the PostgreSQL database server """
    database = dbLoader.dlg.btnConnToExist.currentData()
    conn = None
    try:

        conn = connect(database)
		
        # create a cursor
        cur = conn.cursor()
        
        # get all tables with theirs schemas    inspired from https://www.codedrome.com/reading-postgresql-database-schemas-with-python/ (access on 27/11/21)
        cur.execute("""SELECT table_schema,table_name
                      FROM information_schema.tables
                      WHERE table_schema != 'pg_catalog'
                      AND table_schema != 'information_schema'
                      AND table_type='BASE TABLE'
                      ORDER BY table_schema,table_name""")
        table_schema = cur.fetchall() #NOTE: For some reason it can't get ALL the schemas

        #Get all schemas
        cur.execute("SELECT schema_name FROM information_schema.schemata")
        schema = cur.fetchall()

	    # # get all tables
        # cur.execute("""SELECT table_name
        #               FROM information_schema.tables
        #               WHERE table_schema != 'pg_catalog'
        #               AND table_schema != 'information_schema'
        #               AND table_type='BASE TABLE'
        #               ORDER BY table_name""")
        # tables = cur.fetchall()


        #Check conditions for a valid the 3DCityDB structure. NOTE: this is an oversimplified test! there are countless conditions where the requirements are met but the structure is broken.
        exists = {'cityobject':False,'building':False,'citydb_pkg':False,'objectclass':False} #TODO: add PostGIS and other extentions to the check  
        
        #table check
        for pair in table_schema: #TODO: break the pair to table, schema 
            if 'cityobject' in pair:
                exists['cityobject']=True
            if 'building' in pair:
                exists['building']=True
            if 'citydb_pkg' in pair:
                exists['citydb_pkg']=True
            if 'objectclass' in pair:
                exists['objectclass']=True
        #chema check
        for pair in schema:
            if 'citydb_pkg' in pair:
                exists['citydb_pkg']=True
        
        if not (exists['cityobject'] and exists['building'] and exists['citydb_pkg' and exists['objectclass']]):
            # close the communication with the PostgreSQL
            cur.close()
            conn.close()
            return 0

	
    except (Exception, psycopg2.DatabaseError) as error:
        print(error)
    finally:
        if conn is not None:
            # close the communication with the PostgreSQL
            cur.close()
            conn.close()
    return 1

def fill_schema_box(dbLoader):
    database = dbLoader.dlg.btnConnToExist.currentData()
    conn = None
    try:

        conn = connect(database)

        # create a cursor
        cur = conn.cursor()

        #Get all schemas
        cur.execute("SELECT schema_name,'' FROM information_schema.schemata WHERE schema_name != 'information_schema' AND NOT schema_name LIKE '%pg%' ORDER BY schema_name ASC")
        schemas = cur.fetchall()

        schemas,empty=zip(*schemas)

        dbLoader.dlg.cbxScema.clear()
        dbLoader.dlg.cbxScema.addItems(sorted(schemas))

    except (Exception, psycopg2.DatabaseError) as error:
        print(error)
    finally:
        if conn is not None:
            # close the communication with the PostgreSQL
            cur.close()
            conn.close()
    return 1

def check_schema(dbLoader):
    database = dbLoader.dlg.btnConnToExist.currentData()

    features={'cityobject':False,'building':False} #Named after their main corresponding table name from the 3DCityDB.
    #NOTE: the above list is currently (28/11/21) restricted only to cityobject->building.  
 
    conn = None
    try:

        conn = connect(database)

        #Get schema stored in 'schema combobox'
        schema=dbLoader.dlg.cbxScema.currentText()
    
        cur=conn.cursor()

        #Check if current schema has cityobject, building features.
        cur.execute(f"""SELECT table_name, table_schema FROM information_schema.tables 
                        WHERE table_schema = '{schema}' 
                        AND table_name = '{list(features.keys())[0]}' OR table_name = '{list(features.keys())[1]}'
                        ORDER BY table_name ASC""")
        feature_table= cur.fetchall()

        for t, s in feature_table:
            if t in list(features.keys()):
                features[t]=True
        
        features_to_display=[]
        #NOTE: This only works for the two features (cityobject,building). In the future if more features are added adjust the code so that it breaks only when cityboject is not found
        for f in features:
            if not features[f]:
                cur.close()
                conn.close()
                return 0
            else:
                features_to_display.append(f)
        
        # Add to combobox ONLY cityobject features
        features_to_display.remove('cityobject')
        dbLoader.dlg.qcbxFeature.clear()
        dbLoader.dlg.qcbxFeature.addItems(features_to_display)

    except (Exception, psycopg2.DatabaseError) as error:
        print(error)
    finally:
        if conn is not None:
            # close the communication with the PostgreSQL
            #cur.close()
            pass
    cur.close()
    conn.close()
    return 1

def check_geometry(dbLoader):
    conn = None
    database = dbLoader.dlg.btnConnToExist.currentData()
    schema = dbLoader.dlg.cbxScema.currentText()
    feature = dbLoader.dlg.qcbxFeature.currentText()
    extents=dbLoader.dlg.qgrbExtent.outputExtent().asWktPolygon() 

    try:

        conn = connect(database)
        cur=conn.cursor()

        #Get amount of features inside the extents 
        cur.execute(f"""SELECT count(*),'' 
                        FROM {schema}.cityobject co
                        JOIN {schema}.{feature} bg 
                        ON co.id = bg.id
                        WHERE ST_Contains(ST_GeomFromText('{extents}',28992),envelope)""")
        count=cur.fetchone()
        count,empty=count

        #Guard against importing many feutures
        if count>3000:
            QMessageBox.warning(dbLoader.dlg,"Warning", f"Too many features set to be import ({count})'!\n"
                                                    "This could hinder perfomance and even cause frequent crashes.") #TODO: justify it better with storage size to 
        else:
            QMessageBox.information(dbLoader.dlg,"Info", f"{count} '{feature}' features contained in current extent.")
            if count == 0:
                cur.close()
                conn.close()
                return 2
        #Get geometry columns
        cur.execute(f"""SELECT column_name,'' 
                        FROM information_schema.columns 
                        WHERE table_name = '{feature}' 
                        AND table_schema = '{schema}' 
                        AND column_name 
                        LIKE 'lod%%id'""")

        columns=cur.fetchall()
        columns,empty=zip(*columns)

        #Get amount of features inside the extents #TODO: select from a list of columns
        cur.execute(f"""SELECT lod0_footprint_id, lod0_roofprint_id, lod1_multi_surface_id,lod1_solid_id,
                        lod2_multi_surface_id,lod2_solid_id
                        FROM {schema}.cityobject co
                        JOIN {schema}.{feature} bg 
                        ON co.id = bg.id""")
        attributes=cur.fetchall()


        geometry_lvls={ 'LOD0':{'Footprint':False, 'Roofprint':False},
                        'LOD1':{'Muilti_surface':False,"Solid":False},
                        'LOD2':{'Muilti_surface':False,"Solid":False}}

        dbLoader.dlg.cbxGeometryLvl.clear()
        dbLoader.dlg.cbxGeomteryType.clear()
        
        lod0=[]
        lod1=[]
        lod2=[]

        for feature in attributes:
            if feature[0] is not None:
                if not geometry_lvls['LOD0']['Footprint']:
                    lod0.append('Footprint')
                    geometry_lvls['LOD0']['Footprint']=True
                else: continue

            if feature[1] is not None:  
                if not geometry_lvls['LOD0']['Roofprint']:
                    lod0.append('Roofprint')
                    geometry_lvls['LOD0']['Roofprint']=True
                else: continue

            if feature[2] is not None:
                if not geometry_lvls['LOD1']['Muilti_surface']:
                    lod1.append('Muilti_surface')
                    geometry_lvls['LOD1']['Muilti_surface']=True
                else: continue

            if feature[3] is not None:
                if not geometry_lvls['LOD1']['Solid']:
                    lod1.append('Solid')
                    geometry_lvls['LOD1']['Solid']=True
                else: continue

            if feature[4] is not None:
                if not geometry_lvls['LOD2']['Muilti_surface']:
                    lod2.append('Muilti_surface')
                    geometry_lvls['LOD2']['Muilti_surface']=True
                else: continue

            if feature[5] is not None:
                if not geometry_lvls['LOD2']['Solid']:
                    lod2.append('Solid')
                    geometry_lvls['LOD2']['Solid']=True
                else: continue

        lvls = {'LoD0':lod0,'LoD1':lod1,'LoD2':lod2}
        for lvl,types in lvls.items():
            if lvl:
                dbLoader.dlg.cbxGeometryLvl.addItem(lvl,types) #TODO: Dont like this harcoding


    except (Exception, psycopg2.DatabaseError) as error:
        print(error)
    finally:
        if conn is not None:
            # close the communication with the PostgreSQL
            #cur.close()
            pass
    cur.close()
    conn.close()
    return 3

#NOTE: currently only works for footpirnts #TODO:Create Different Updatable view for every geometry lvl/type combination
def import_layer(dbLoader): 
    selected_db=dbLoader.dlg.btnConnToExist.currentData()
    selected_schema=dbLoader.dlg.cbxScema.currentText()
    selected_feature=dbLoader.dlg.qcbxFeature.currentText()
    selected_geometryLvl=dbLoader.dlg.cbxGeometryLvl.currentText()
    selected_geometryLvl=dbLoader.dlg.cbxGeomteryType.currentText()
    extents=dbLoader.dlg.qgrbExtent.outputExtent().asWktPolygon()
    view_name= 'v_building'

    conn = None
    conn = connect(selected_db)
    cur=conn.cursor()

    #Get layer view containg all attributes from feature 
    cur.execute(f"""CREATE OR REPLACE VIEW {selected_schema}.{view_name} AS
                    SELECT row_number() OVER (ORDER BY o.id) as gid, o.id, o.envelope, b.class, b.year_of_construction, b.lod0_footprint_id, g.geometry
                    FROM {selected_schema}.cityobject o
                    JOIN {selected_schema}.{selected_feature} b ON o.id=b.id
                    JOIN {selected_schema}.surface_geometry g ON g.parent_id=b.lod0_footprint_id;
                """)
    
    conn.commit()
    cur.close()
    conn.close()

    #Create view to import based on user attributes


    uri = QgsDataSourceUri()
    uri.setConnection(selected_db.host,selected_db.port,selected_db.database_name,selected_db.user,selected_db.password)
    #params: schema, table, geometry, [subset], primary key
    uri.setDataSource(aSchema= selected_schema,aTable= f'{view_name}',aGeometryColumn= 'geometry',aSql=f"ST_Contains(ST_GeomFromText('{extents}',28992),envelope)", aKeyColumn='gid')
    vlayer = QgsVectorLayer(uri.uri(False), f"{selected_feature}", "postgres")
    QgsProject.instance().addMapLayer(vlayer)



    





#NOTE:TODO: for every event and every check of database, a new connection Opens/Closes. 
#Maybe find a way to keep the connection open until the plugin ultimately closes
# -*- coding: utf-8 -*-
import os, configparser
import psycopg2
from qgis.core import QgsApplication, QgsVectorLayer, QgsProject, QgsDataSourceUri, QgsCoordinateReferenceSystem,Qgis
from qgis.PyQt.QtWidgets import QMessageBox
from .connection import *




def is_connected(dbLoader):
    database = dbLoader.dlg.cbxConnToExist.currentData()
    conn = None
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
        
        for version 3.X
    """ 
    #Check conditions for a valid the 3DCityDB structure. 
    # ALL MUST BE TRUE
    # NOTE: this is an oversimplified test! there are countless conditions where the requirements are met but the structure is broken.
    conditions_met = {  'postgis':False, 'postgis_sfcgal':False, 'uuid-ossp':False,             #Extentions
                        'citydb_pkg':False,                                                     #Schemas
                        'cityobject':False,'building':False,'surface_geometry':False}           #Tables

                        

    database = dbLoader.dlg.cbxConnToExist.currentData()
		

    cur = dbLoader.conn.cursor() 
    # get all tables with theirs schemas    
    cur.execute("""SELECT table_name
                    FROM information_schema.tables
                    WHERE table_schema != 'pg_catalog'
                    AND table_schema != 'information_schema'
                    AND table_type='BASE TABLE'
                """)
    tables = cur.fetchall()
    cur.close()

    cur = dbLoader.conn.cursor()
    #Get all schemas
    cur.execute("SELECT schema_name FROM information_schema.schemata")
    schemas = cur.fetchall()
    cur.close()

    cur = dbLoader.conn.cursor() 
    #Get all extentions
    cur.execute("SELECT extname FROM pg_extension")
    extentions = cur.fetchall()
    cur.close()
    
    #extention check
    for pair in extentions:
        if 'postgis' in pair: conditions_met['postgis']=True
        elif 'postgis_sfcgal' in pair: conditions_met['postgis_sfcgal']=True
        elif 'uuid-ossp' in pair: conditions_met['uuid-ossp']=True
        

    #schema check
    for pair in schemas:
        if 'citydb_pkg' in pair:
            conditions_met['citydb_pkg']=True

    #table check
    for pair in tables:
        if 'cityobject' in pair: conditions_met['cityobject']=True
        elif 'building' in pair: conditions_met['building']=True
        elif 'citydb_pkg' in pair: conditions_met['citydb_pkg']=True
        elif 'surface_geometry' in pair: conditions_met['surface_geometry']=True


    for condition in conditions_met:
        if not conditions_met[condition]:
            return condition
        
    cur = dbLoader.conn.cursor()  
    cur.execute("SELECT version FROM citydb_pkg.citydb_version();")
    version= cur.fetchall()
    cur.close()
    database.c_version= version[0][0]

    return 1

def get_schemas(dbLoader):
    database = dbLoader.dlg.cbxConnToExist.currentData()
    conn = None
    try:

        # create a cursor
        cur = dbLoader.conn.cursor()

        #Get all schemas
        cur.execute("SELECT schema_name,'' FROM information_schema.schemata WHERE schema_name != 'information_schema' AND NOT schema_name LIKE '%pg%' ORDER BY schema_name ASC")
        schemas = cur.fetchall()

        schemas,empty=zip(*schemas)
        dbLoader.schemas = schemas

    except (Exception, psycopg2.DatabaseError) as error:
        print(error)
    finally:
        if dbLoader.conn is not None:
            # close the communication with the PostgreSQL
            cur.close()

def fill_schema_box(dbLoader):
    dbLoader.dlg.cbxScema.clear()
    dbLoader.dlg.cbxScema.addItems(sorted(dbLoader.schemas))


def check_schema(dbLoader):
    database = dbLoader.dlg.cbxConnToExist.currentData()

    features={'cityobject':False,'building':False} #Named after their main corresponding table name from the 3DCityDB.
    #NOTE: the above list is currently (28/11/21) restricted only to cityobject->building.  
 
    conn = None
    try:

        #Get schema stored in 'schema combobox'
        schema=dbLoader.dlg.cbxScema.currentText()
    
        cur=dbLoader.conn.cursor()

        #Check if current schema has cityobject, building features.
        cur.execute(f"""SELECT table_name, table_schema FROM information_schema.tables 
                        WHERE table_schema = '{schema}' 
                        AND table_name = '{list(features.keys())[0]}' OR table_name = '{list(features.keys())[1]}'
                        ORDER BY table_name ASC""")
        feature_table= cur.fetchall()
        cur.close()

        for t, s in feature_table:
            if t in list(features.keys()):
                features[t]=True
        
        features_to_display=[]
        #NOTE: This only works for the two features (cityobject,building). In the future if more features are added adjust the code so that it breaks only when cityboject is not found
        for f in features:
            if not features[f]:
                cur.close()

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
        if dbLoader.conn is not None:
            # close the communication with the PostgreSQL
            #cur.close()
            pass
    

    return 1

def check_geometry(dbLoader):
    conn = None
    database = dbLoader.dlg.cbxConnToExist.currentData()
    schema = dbLoader.dlg.cbxScema.currentText()
    feature = dbLoader.dlg.qcbxFeature.currentText()
    extents=dbLoader.dlg.qgrbExtent.outputExtent().asWktPolygon() 

    try:


        cur=dbLoader.conn.cursor()

        #Get amount of features inside the extents 
        cur.execute(f"""SELECT count(*),'' 
                        FROM {schema}.cityobject co
                        JOIN {schema}.{feature} bg 
                        ON co.id = bg.id
                        WHERE ST_Contains(ST_GeomFromText('{extents}',28992),envelope)""")
        count=cur.fetchone()
        cur.close()
        count,empty=count

        #Guard against importing many feutures
        if count>3000:
            QMessageBox.warning(dbLoader.dlg,"Warning", f"Too many features set to be imported ({count})!\n"
                                                    "This could hinder perfomance and even cause frequent crashes.") #TODO: justify it better with storage size to 
        else:
            QMessageBox.information(dbLoader.dlg,"Info", f"{count} '{feature}' features contained in current extent.")
            if count == 0:
                cur.close()
                return 2
        cur=dbLoader.conn.cursor()
        #Get geometry columns
        cur.execute(f"""SELECT column_name,'' 
                        FROM information_schema.columns 
                        WHERE table_name = '{feature}' 
                        AND table_schema = '{schema}' 
                        AND column_name 
                        LIKE 'lod%%id'""")

        columns=cur.fetchall()
        cur.close()
        columns,empty=zip(*columns)
        
        cur=dbLoader.conn.cursor()
        cur.execute(f"SELECT * FROM {schema}.thematic_surface;")
        hasThematic = cur.fetchone()
        if hasThematic:

            #Get amount of features inside the extents #TODO: select from a list of columns
            cur.execute(f"""SELECT  bg.lod0_footprint_id, bg.lod0_roofprint_id, bg.lod1_multi_surface_id,bg.lod1_solid_id, bg.lod2_multi_surface_id,
                                    bg.lod2_solid_id,th.lod2_multi_surface_id
                            FROM {schema}.cityobject co
                            JOIN {schema}.{feature} bg ON co.id = bg.id
                            JOIN {schema}.thematic_surface th ON th.building_id = bg.id;
                        """)
            
        else:
            cur.execute(f"""SELECT  bg.lod0_footprint_id, bg.lod0_roofprint_id, bg.lod1_multi_surface_id,bg.lod1_solid_id, bg.lod2_multi_surface_id,
                                    bg.lod2_solid_id,NULL
                            FROM {schema}.cityobject co
                            JOIN {schema}.{feature} bg ON co.id = bg.id;""")
        attributes=cur.fetchall()
        cur.close()


        geometry_lvls={ 'LOD0':{'Footprint':False, 'Roofprint':False},
                        'LOD1':{'Multi-surface':False,"Solid":False},
                        'LOD2':{'Multi-surface':False,"Solid":False,"Thematic surface":False}
                    }

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
                if not geometry_lvls['LOD1']['Multi-surface']:
                    lod1.append('Multi-surface')
                    geometry_lvls['LOD1']['Multi-surface']=True
                else: continue

            if feature[3] is not None:
                if not geometry_lvls['LOD1']['Solid']:
                    lod1.append('Solid')
                    geometry_lvls['LOD1']['Solid']=True
                else: continue

            if feature[4] is not None:
                if not geometry_lvls['LOD2']['Multi-surface']:
                    lod2.append('Multi-surface')
                    geometry_lvls['LOD2']['Multi-surface']=True
                else: continue

            if feature[5] is not None:
                if not geometry_lvls['LOD2']['Solid']:
                    lod2.append('Solid')
                    geometry_lvls['LOD2']['Solid']=True
                else: continue
            
            if feature[6] is not None:
                if not geometry_lvls['LOD2']['Thematic surface']:
                    lod2.append('Thematic surface')
                    geometry_lvls['LOD2']['Thematic surface']=True
                else: continue


        lvls = {'LoD0':lod0,'LoD1':lod1,'LoD2':lod2}
        for lvl,types in lvls.items():
            if lvl:
                dbLoader.dlg.cbxGeometryLvl.addItem(lvl,types) #TODO: Dont like this harcoding


    except (Exception, psycopg2.DatabaseError) as error:
        print(error)
    finally:
        if dbLoader.conn is not None:
            # close the communication with the PostgreSQL
            #cur.close()
            pass
    

    return 3

#NOTE: currently only works for lod0 footpirnts, lod1 solid, lod2 solid, lod2 thematic   #TODO:Create Different Updatable view for every geometry lvl/type combination
def import_layer(dbLoader): 
    selected_db=dbLoader.dlg.cbxConnToExist.currentData()
    selected_schema=dbLoader.dlg.cbxScema.currentText()
    selected_feature=dbLoader.dlg.qcbxFeature.currentText()
    selected_geometryLvl=dbLoader.dlg.cbxGeometryLvl.currentText()
    selected_geometryType=dbLoader.dlg.cbxGeomteryType.currentText()
    extents=dbLoader.dlg.qgrbExtent.outputExtent().asWktPolygon() #Readable for debugging
    building_attr=  """
                                b.id, o.gmlid,
                                o.envelope,
                                b.class,
                                b.function, b.usage,
                                b.year_of_construction, b.year_of_demolition,
                                b.roof_type,
                                b.measured_height,measured_height_unit,
                                b.storeys_above_ground, b.storeys_below_ground,
                                b.storey_heights_above_ground, b.storey_heights_ag_unit,
                                b.storey_heights_below_ground, b.storey_heights_bg_unit
                    """
    conn = None

    try:

        # cur=dbLoader.conn.cursor()

        if selected_geometryLvl == 'LoD0':
            if selected_geometryType == 'Footprint':
                query_view='v_building_lod0_footprint'
                
                # sql_update_func =  f"""
                #                 CREATE OR REPLACE FUNCTION {selected_schema}.tr_upd_v_building ()
                #                 RETURNS trigger AS $$
                #                 DECLARE
                #                 updated_id integer;
                #                 BEGIN
                #                 UPDATE {selected_schema}.cityobject AS t1 SET
                #                 gmlid                          = NEW.gmlid,
                #                 envelope                       = NEW.envelope

                #                 WHERE t1.id = OLD.id RETURNING id INTO updated_id;

                #                 UPDATE {selected_schema}.{selected_feature} AS t2 SET
                #                 class                       = NEW.class,
                #                 function                    = NEW.function,
                #                 usage                       = NEW.usage,
                #                 year_of_construction        = NEW.year_of_construction,
                #                 year_of_demolition          = NEW.year_of_demolition,
                #                 roof_type                   = NEW.roof_type,
                #                 measured_height             = NEW.measured_height,
                #                 measured_height_unit        = NEW.measured_height_unit,
                #                 storeys_above_ground        = NEW.storeys_above_ground,
                #                 storeys_below_ground        = NEW.storeys_below_ground,
                #                 storey_heights_above_ground = NEW.storey_heights_above_ground,
                #                 storey_heights_ag_unit      = NEW.storey_heights_ag_unit,
                #                 storey_heights_below_ground = NEW.storey_heights_below_ground,
                #                 storey_heights_bg_unit      = NEW.storey_heights_bg_unit
                #                 WHERE t2.id = updated_id;
                #                 RETURN NEW;
                #                 EXCEPTION
                #                 WHEN OTHERS THEN RAISE NOTICE '{selected_schema}.tr_upd_v_building(id: %): %', OLD.id, SQLERRM;
                #                 END;
                #                 $$ LANGUAGE plpgsql;
                #                 COMMENT ON FUNCTION {selected_schema}.tr_upd_v_building IS 'Update record in view {view_name}';
                #                 """

                # sql_trigger =  f""" 
                #                     CREATE TRIGGER         tr_upd_v_building
                #                     INSTEAD OF UPDATE ON {selected_schema}.{view_name}
                #                     FOR EACH ROW
                #                     EXECUTE PROCEDURE {selected_schema}.tr_upd_v_building();
                #                     COMMENT ON TRIGGER tr_upd_v_building ON {selected_schema}.{view_name} IS 'Fired upon update of view {selected_schema}.{view_name}';
                #                 """
                        
            elif selected_geometryType == 'Roofprint': #NOTE: roofprint is not tested on real data case 
                query_view='v_building_lod0_roofprint'
        # elif selected_geometryLvl == 'LoD1':
        #     if selected_geometryType == 'Solid':
        #         view_name+='_lod1_solid'
        #         sql_view = f"""CREATE VIEW {selected_schema}.{view_name} AS
        #                         SELECT row_number() over() AS view_id,
        #                         {building_attr},
        #                         geom.solid_geometry as geometry
        #                         FROM {selected_schema}.{selected_feature} b
        #                         JOIN {selected_schema}.cityobject o ON o.id=b.id
        #                         JOIN {selected_schema}.surface_geometry geom ON geom.root_id=b.lod1_solid_id
        #                         WHERE geom.solid_geometry IS NOT NULL;
        #                     """
        #     elif selected_geometryType == 'Multi-surface': #TODO
        #         view_name+='_lod1_multisurface'
        #         sql_view = f"""CREATE VIEW {selected_schema}.{view_name} AS
        #                         SELECT row_number() over() AS view_id,
        #                         {building_attr},
        #                         geom.geometry
        #                         FROM {selected_schema}.{selected_feature} b
        #                         JOIN {selected_schema}.cityobject o ON o.id=b.id
        #                         JOIN {selected_schema}.surface_geometry geom ON geom.root_id=b.lod1_multi_surface_id
        #                         WHERE geom.geometry IS NOT NULL;
        #                     """
        # elif selected_geometryLvl == 'LoD2':
        #     if selected_geometryType == 'Solid':
        #         view_name+='_lod2_solid'
        #         sql_view = f"""CREATE VIEW {selected_schema}.{view_name} AS
        #                         SELECT row_number() over() AS view_id,
        #                         {building_attr},
        #                         geom.solid_geometry as geometry
        #                         FROM {selected_schema}.{selected_feature} b
        #                         JOIN {selected_schema}.cityobject o ON o.id=b.id
        #                         JOIN {selected_schema}.surface_geometry geom ON geom.root_id=b.lod2_solid_id
        #                         WHERE geom.solid_geometry IS NOT NULL;
        #                     """
        #     elif selected_geometryType == 'Multi-surface': #TODO
        #         view_name+='_lod2_multisurface'
        #         sql_view = f"""CREATE VIEW {selected_schema}.{view_name} AS
        #                         SELECT row_number() over() AS view_id,
        #                         {building_attr},
        #                         geom.geometry
        #                         FROM {selected_schema}.{selected_feature} b
        #                         JOIN {selected_schema}.cityobject o ON o.id=b.id
        #                         JOIN {selected_schema}.surface_geometry geom ON geom.root_id=b.lod2_multi_surface_id
        #                         WHERE geom.geometry IS NOT NULL;
        #                     """
        #     elif selected_geometryType == "Thematic surface":
        #         view_name+='_lod2_thematic'
        #         sql_view = f"""CREATE VIEW {selected_schema}.{view_name} AS
        #                         SELECT row_number() over() AS view_id,
        #                         {building_attr},
        #                         ST_COLLECT(geom.geometry) as geometry
        #                         FROM {selected_schema}.{selected_feature} b
        #                         JOIN {selected_schema}.cityobject o ON o.id=b.id
        #                         JOIN {selected_schema}.thematic_surface th ON th.building_id = b.id 
        #                         JOIN {selected_schema}.surface_geometry geom ON geom.root_id = th.lod2_multi_surface_id
        #                         WHERE geom.geometry IS NOT NULL
        #                         GROUP BY b.id,o.gmlid,o.envelope;
        #                     """

        #Get layer view containg all attributes from feature 
        #cur.execute(f'DROP VIEW IF EXISTS {selected_schema}.{view_name};')
        #cur.execute(f'DROP FUNCTION IF EXISTS {selected_schema}.tr_upd_v_building CASCADE;')
        #cur.execute(f'DROP TRIGGER IF EXISTS tr_upd_v_building ON {selected_schema}.{view_name};')
        #cur.execute(sql_view)
        #cur.execute(sql_update_func)
        #cur.execute(sql_trigger)
        #dbLoader.conn.commit()
        #cur.close()


        #Create view to import based on user attributes
        dbLoader.iface.mainWindow().blockSignals(True)

        uri = QgsDataSourceUri()
        uri.setConnection(selected_db.host,selected_db.port,selected_db.database_name,selected_db.username,selected_db.password)
        #params: schema, table, geometry, [subset], primary key
        uri.setDataSource(aSchema= selected_schema,aTable= f'{query_view}',aGeometryColumn= 'geometry',aSql=f"ST_Contains(ST_GeomFromText('{extents}',28992),ST_Force2D(envelope))",aKeyColumn= 'view_id')
        vlayer = QgsVectorLayer(uri.uri(False), f"{selected_schema}_{selected_feature}_{selected_geometryLvl}_{selected_geometryType}", "postgres")
        crs = vlayer.crs()
        crs.createFromId(28992)  #TODO: Dont hardcode it
        vlayer.setCrs(crs)

        QgsProject.instance().addMapLayer(vlayer)
        dbLoader.iface.mainWindow().blockSignals(False) #NOTE: Temp solution to avoid undefined CRS pop up. IT IS DEFINED
        
        if not vlayer or not vlayer.isValid():
            dbLoader.show_Qmsg('Layer failed to load properly',msg_type=Qgis.Critical)
        else:
            dbLoader.show_Qmsg('Success!!')

    except (Exception, psycopg2.DatabaseError) as error:
        print(error)
        dbLoader.show_Qmsg('Import failed! Check Log Messages',msg_type=Qgis.Critical)
    finally:
        if dbLoader.conn is not None:
            # close the communication with the PostgreSQL
            #cur.close()
            pass
            
    

#TODO: Check if Commit is needed after every query execution https://www.psycopg.org/docs/faq.html

#TODO: drop view when layer is removed from project
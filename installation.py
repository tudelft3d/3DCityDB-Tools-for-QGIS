import psycopg2
import time
from qgis.PyQt.QtWidgets import QProgressBar
from qgis.PyQt.QtCore import *
from qgis.core import Qgis, QgsMessageLog

global building_attr
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
global view_names
view_names = {'lod0_f':['v_building_lod0_footprint'],'lod0_r':['v_building_lod0_roofprint'],
            'lod1_s':['v_building_lod1_solid'],'lod1_m':['v_building_lod1_multisurface'],
            'lod2_s':['v_building_lod2_solid','v_buildinginstallation_lod2_solid'],
            'lod2_m':['v_building_lod2_multisurface','v_buildinginstallation_lod2_multisurface'],
            'lod2_th':['v_building_lod2_roofsurface','v_building_lod2_wallsurface','v_building_lod2_groundsurface','v_building_lod2_closuresurface','v_building_lod2_ceilingsurface','v_building_lod2_interiorwallsurface','v_building_lod2_floorsurface','v_building_lod2_outerceilingsurface','v_building_lod2_outerfloorsurface']}

def install_upd_function():
    # sql_update_func =  f"""
    #                 CREATE OR REPLACE FUNCTION citydb_pkg.tr_upd_v_building ()
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
    pass
def install_tr_upd():
    # sql_trigger =  f""" 
    #                     CREATE TRIGGER         tr_upd_v_building
    #                     INSTEAD OF UPDATE ON {selected_schema}.{view_name}
    #                     FOR EACH ROW
    #                     EXECUTE PROCEDURE {selected_schema}.tr_upd_v_building();
    #                     COMMENT ON TRIGGER tr_upd_v_building ON {selected_schema}.{view_name} IS 'Fired upon update of view {selected_schema}.{view_name}';
    #                 """
    pass

def install_lod0_footprint(cursor,schema):

    sql_create = f"""
                    CREATE OR REPLACE VIEW {schema}.{view_names['lod0_f'][0]} AS
                    SELECT row_number() over() AS view_id,
                    {building_attr},
                    geom.geometry
                    FROM {schema}.building b
                    JOIN {schema}.cityobject o ON o.id=b.id
                    JOIN {schema}.surface_geometry geom ON geom.root_id=b.lod0_footprint_id
                    WHERE geom.geometry IS NOT NULL;
                """

    try:

        cursor.execute(sql_create)
        QgsMessageLog.logMessage(f"installed view '{view_names['lod0_f']}' for schema: '{schema}'",level=Qgis.Success)
    except (Exception, psycopg2.DatabaseError) as error:
        print(error)
        QgsMessageLog.logMessage(f"installed view '{view_names['lod0_f']}' for schema: '{schema}' FAILED",level=Qgis.Critical)


def install_lod0_roofprint(cursor,schema):

    sql_create = f"""
                CREATE OR REPLACE VIEW {schema}.{view_names['lod0_r'][0]} AS
                SELECT row_number() over() AS view_id,
                {building_attr},
                geom.geometry
                FROM {schema}.building b
                JOIN {schema}.cityobject o ON o.id=b.id
                JOIN {schema}.surface_geometry geom ON geom.root_id=b.lod0_roofprint_id
                WHERE geom.geometry IS NOT NULL;
            """
    try:

        cursor.execute(sql_create)
        QgsMessageLog.logMessage(f"installed view '{view_names['lod0_r']}' for schema: '{schema}'",level=Qgis.Success)
    except (Exception, psycopg2.DatabaseError) as error:
        print(error)
        QgsMessageLog.logMessage(f"installed view '{view_names['lod0_r']}' for schema: '{schema}' FAILED",level=Qgis.Critical)
        

def install_lod1_solid(cursor,schema):

    sql_create = f"""
                    CREATE OR REPLACE VIEW {schema}.{view_names['lod1_s'][0]} AS
                    SELECT row_number() over() AS view_id,
                    {building_attr},
                    geom.solid_geometry as geometry
                    FROM {schema}.building b
                    JOIN {schema}.cityobject o ON o.id=b.id
                    JOIN {schema}.surface_geometry geom ON geom.root_id=b.lod1_solid_id
                    WHERE geom.solid_geometry IS NOT NULL;
                """
     
    try:
        cursor.execute(sql_create)
        QgsMessageLog.logMessage(f"installed view '{view_names['lod1_s']}' for schema: '{schema}'",level=Qgis.Success)
    except (Exception, psycopg2.DatabaseError) as error:
        print(error)
        QgsMessageLog.logMessage(f"installed view '{view_names['lod1_s']}' for schema: '{schema}' FAILED",level=Qgis.Critical)

def install_lod1_multisurface(cursor,schema):

    sql_create = f"""
                    CREATE OR REPLACE VIEW {schema}.{view_names['lod1_m'][0]} AS
                    SELECT row_number() over() AS view_id,
                    {building_attr},
                    geom.geometry
                    FROM {schema}.building b
                    JOIN {schema}.cityobject o ON o.id=b.id
                    JOIN {schema}.surface_geometry geom ON geom.root_id=b.lod1_multi_surface_id
                    WHERE geom.geometry IS NOT NULL;
                """
    try:
        cursor.execute(sql_create)
        QgsMessageLog.logMessage(f"installed view '{view_names['lod1_m']}' for schema: '{schema}'",level=Qgis.Success)
    except (Exception, psycopg2.DatabaseError) as error:
        print(error)
        QgsMessageLog.logMessage(f"installed view '{view_names['lod1_m']}' for schema: '{schema}' FAILED",level=Qgis.Critical)

    

def install_lod2_solid(cursor,schema):


    sql_building =f"""
                    CREATE OR REPLACE VIEW {schema}.{view_names['lod2_s'][0]} AS
                    SELECT row_number() over() AS view_id,
                    {building_attr},
                    geom.solid_geometry as geometry
                    FROM {schema}.building b
                    JOIN {schema}.cityobject o ON o.id=b.id
                    JOIN {schema}.surface_geometry geom ON geom.root_id=b.lod2_solid_id
                    WHERE geom.solid_geometry IS NOT NULL;
                """

    sql_build_install = f"""
                CREATE OR REPLACE VIEW {schema}.{view_names['lod2_s'][1]} AS
                SELECT row_number() over() AS view_id,
                bi.id, bi.class,bi.function, bi.usage, o.envelope, geom.solid_geometry AS geometry
                FROM {schema}.building_installation bi
                JOIN {schema}.cityobject o ON o.id = bi.id
                JOIN {schema}.surface_geometry geom ON geom.cityobject_id=bi.id
                WHERE geom.solid_geometry IS NOT NULL;
                """
    

    try:
        cursor.execute(sql_building)
        cursor.execute(sql_build_install)
        QgsMessageLog.logMessage(f"installed view '{view_names['lod2_s']}' for schema: '{schema}'",level=Qgis.Success)
    except (Exception, psycopg2.DatabaseError) as error:
        print(error)
        QgsMessageLog.logMessage(f"installed view '{view_names['lod2_s']}' for schema: '{schema}' FAILED",level=Qgis.Critical)


def install_lod2_multisurface(cursor,schema):    


    sql_building = f"""
                    CREATE OR REPLACE VIEW {schema}.{view_names['lod2_m'][0]} AS
                    SELECT row_number() over() AS view_id,
                    {building_attr},
                    geom.geometry
                    FROM {schema}.building b
                    JOIN {schema}.cityobject o ON o.id=b.id
                    JOIN {schema}.surface_geometry geom ON geom.root_id=b.lod2_multi_surface_id
                    WHERE geom.geometry IS NOT NULL;
                    """
    sql_build_install = f"""
                    CREATE OR REPLACE VIEW {schema}.{view_names['lod2_m'][1]} AS
                    SELECT row_number() over() AS view_id,
                    bi.id, bi.class,bi.function, bi.usage, o.envelope, geom.geometry
                    FROM {schema}.building_installation bi
                    JOIN {schema}.cityobject o ON o.id = bi.id
                    JOIN {schema}.surface_geometry geom ON geom.cityobject_id=bi.id
                    WHERE geom.geometry IS NOT NULL;
                    """


    
    try:
        
        cursor.execute(sql_building)
        cursor.execute(sql_build_install)
        QgsMessageLog.logMessage(f"installed view '{view_names['lod2_m']}' for schema: '{schema}'",level=Qgis.Success)
    except (Exception, psycopg2.DatabaseError) as error:
        print(error)
        QgsMessageLog.logMessage(f"installed view '{view_names['lod2_m']}' for schema: '{schema}' FAILED",level=Qgis.Critical)


def install_lod2_thematic(cursor,schema):

    #sql_drop = f"DROP VIEW IF EXISTS {schema}.{view_names['lod2_th']};"
    sql_body = f""" AS
                    SELECT row_number() over() AS view_id,
                    {building_attr},
                    geom.geometry
                    FROM {schema}.building b
                    JOIN {schema}.cityobject o ON o.id=b.id
                    JOIN {schema}.thematic_surface th ON th.building_id = b.id 
                    JOIN {schema}.surface_geometry geom ON geom.root_id=th.lod2_multi_surface_id
                    JOIN {schema}.objectclass oc ON th.objectclass_id = oc.id
                    WHERE geom.geometry IS NOT NULL AND oc.classname = """

    sql_roof = f"""CREATE OR REPLACE VIEW {schema}.{view_names['lod2_th'][0]}"""

    sql_wall = f"""CREATE OR REPLACE VIEW {schema}.{view_names['lod2_th'][1]}"""

    sql_ground = f"""CREATE OR REPLACE VIEW {schema}.{view_names['lod2_th'][2]}"""

    sql_closure = f"""CREATE OR REPLACE VIEW {schema}.{view_names['lod2_th'][3]}"""

    sql_ceiling = f"""CREATE OR REPLACE VIEW {schema}.{view_names['lod2_th'][4]}"""

    sql_int_wall = f"""CREATE OR REPLACE VIEW {schema}.{view_names['lod2_th'][5]}"""

    sql_floor = f"""CREATE OR REPLACE VIEW {schema}.{view_names['lod2_th'][6]}"""

    sql_out_ceiling = f"""CREATE OR REPLACE VIEW {schema}.{view_names['lod2_th'][7]}"""

    sql_out_floor = f"""CREATE OR REPLACE VIEW {schema}.{view_names['lod2_th'][8]}"""


    try:
       # cursor.execute(sql_drop)
        cursor.execute(sql_roof+sql_body+"'BuildingRoofSurface'")
        cursor.execute(sql_wall+sql_body+"'BuildingWallSurface'")
        cursor.execute(sql_ground+sql_body+"'BuildingGroundSurface'")
        cursor.execute(sql_closure+sql_body+"'BuildingClosureSurface'")
        cursor.execute(sql_ceiling+sql_body+"'BuildingCeilingSurface'")
        cursor.execute(sql_int_wall+sql_body+"'InteriorBuildingWallSurface'")
        cursor.execute(sql_floor+sql_body+"'BuildingFloorSurface'")
        cursor.execute(sql_out_ceiling+sql_body+"'OuterBuildingCeilingSurface'")
        cursor.execute(sql_out_floor+sql_body+"'OuterBuildingFloorSurface'")

        QgsMessageLog.logMessage(f"installed view '{view_names['lod2_th']}' for schema: '{schema}'",level=Qgis.Success)
    except (Exception, psycopg2.DatabaseError) as error:
        print(error)
        QgsMessageLog.logMessage(f"installed view '{view_names['lod2_th']}' for schema: '{schema}' FAILED",level=Qgis.Critical)
def install_views(dbLoader):
    
    cur = dbLoader.conn.cursor()
    for schema in dbLoader.schemas:

        if schema not in ['public','citydb_pkg']:

            install_lod0_footprint(cur,schema)
            install_lod0_roofprint(cur,schema)
            install_lod1_solid(cur,schema)
            install_lod1_multisurface(cur,schema)
            install_lod2_solid(cur,schema)
            install_lod2_multisurface(cur,schema)
            install_lod2_thematic(cur,schema)
            print(f'installing view for: {schema}')
            dbLoader.conn.commit()
            


    cur.close()
    dbLoader.dlg.cbxConnToExist.currentData().has_installation=True
    
def uninstall_views(dbLoader):

    progress = QProgressBar(dbLoader.dlg.gbxInstall.bar)
    progress.setMaximum(len(dbLoader.schemas))
    progress.setAlignment(Qt.AlignLeft|Qt.AlignVCenter)
    dbLoader.dlg.gbxInstall.bar.pushWidget(progress, Qgis.Info)

    selected_db = dbLoader.dlg.cbxConnToExist.currentData()
    cur = dbLoader.conn.cursor()
    for count,schema in enumerate(dbLoader.schemas): #TODO: Catch DB errors
        print(f"uninstalling view from: {schema}")
        for view in view_names['lod0_f']:
            cur.execute(f"""DROP VIEW IF EXISTS {schema}.{view}""")
        for view in view_names['lod0_r']:
            cur.execute(f"""DROP VIEW IF EXISTS {schema}.{view}""")
        for view in view_names['lod1_s']:
            cur.execute(f"""DROP VIEW IF EXISTS {schema}.{view}""")
        for view in view_names['lod1_m']:
            cur.execute(f"""DROP VIEW IF EXISTS {schema}.{view}""")
        for view in view_names['lod2_s']:
            cur.execute(f"""DROP VIEW IF EXISTS {schema}.{view}""")
        for view in view_names['lod2_m']:
            cur.execute(f"""DROP VIEW IF EXISTS {schema}.{view}""")
        for view in view_names['lod2_th']:
            cur.execute(f"""DROP VIEW IF EXISTS {schema}.{view}""")
        #cur.execute(f"""DROP VIEW IF EXISTS {schema}.{view_names['lod2_th']}""")
        progress.setValue(count+1)
    dbLoader.conn.commit()

    msg = dbLoader.dlg.gbxInstall.bar.createMessage( u'Database has been cleared' )
    dbLoader.dlg.gbxInstall.bar.clearWidgets()
    dbLoader.dlg.gbxInstall.bar.pushWidget(msg, Qgis.Success, duration=4)
      
    selected_db.has_installation = False
                     
            
                   
    
                    

def check_install(dbLoader):
    """
    Check if current database has all the necessary view installed.
    This function helps to avoid new installation on top of existing ones (case when the plugin runs from start)
    """
    cur = dbLoader.conn.cursor()
    for schema in dbLoader.schemas:
        if schema not in ['public','citydb_pkg']:
            for view in view_names['lod0_f']:
                sql=    f"""
                        SELECT EXISTS(
                            SELECT FROM information_schema.tables
                            WHERE table_schema='{schema}'
                            AND table_name='{view}'
                            )
                        """
                
                cur.execute(sql)
                res = cur.fetchone()[0]
                print('res',res,schema)
                if not res:
                    cur.close()
                    return False 
    cur.close()
    return True
    

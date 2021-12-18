import psycopg2
from qgis.PyQt.QtWidgets import QMessageBox

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
view_names = {'lod0_f':'v_building_lod0_footprint','lod0_r':'v_building_lod0_roofprint',
            'lod1_s':'v_building_lod1_solid','lod1_m':'v_building_lod2_multisurface',
            'lod2_s':'v_building_lod2_solid','lod2_m':'v_building_lod2_multisurface', 'lod2_th':''}

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

    sql_drop = f"DROP VIEW IF EXISTS {schema}.{view_names['lod0_f']};"
    sql_create = f"""
                    CREATE OR REPLACE VIEW {schema}.{view_names['lod0_f']} AS
                    SELECT row_number() over() AS view_id,
                    {building_attr},
                    geom.geometry
                    FROM {schema}.building b
                    JOIN {schema}.cityobject o ON o.id=b.id
                    JOIN {schema}.surface_geometry geom ON geom.root_id=b.lod0_footprint_id
                    WHERE geom.geometry IS NOT NULL;
                """

    try:
        cursor.execute(sql_drop)
        cursor.execute(sql_create)
    except (Exception, psycopg2.DatabaseError) as error:
        print(error)


def install_lod0_roofprint(cursor,schema):

    sql_drop = f"DROP VIEW IF EXISTS {schema}.{view_names['lod0_r']};"
    sql_create = f"""
                CREATE VIEW {schema}.{view_names['lod0_r']} AS
                SELECT row_number() over() AS view_id,
                {building_attr},
                geom.geometry
                FROM {schema}.building b
                JOIN {schema}.cityobject o ON o.id=b.id
                JOIN {schema}.surface_geometry geom ON geom.root_id=b.lod0_roofprint_id
                WHERE geom.geometry IS NOT NULL;
            """
    try:
        cursor.execute(sql_drop)
        cursor.execute(sql_create)
    except (Exception, psycopg2.DatabaseError) as error:
        print(error)
        

def install_lod1_solid(cursor,schema):

    sql_drop = f"DROP VIEW IF EXISTS {schema}.{view_names['lod1_s']};"
    sql_create = f"""
                    CREATE VIEW {schema}.{view_names['lod1_s']} AS
                    SELECT row_number() over() AS view_id,
                    {building_attr},
                    geom.solid_geometry as geometry
                    FROM {schema}.building b
                    JOIN {schema}.cityobject o ON o.id=b.id
                    JOIN {schema}.surface_geometry geom ON geom.root_id=b.lod1_solid_id
                    WHERE geom.solid_geometry IS NOT NULL;
                """
     
    try:
        cursor.execute(sql_drop)
        cursor.execute(sql_create)
    except (Exception, psycopg2.DatabaseError) as error:
        print(error)
def install_lod1_multisurface(cursor,schema):

    sql_drop = f"DROP VIEW IF EXISTS {schema}.{view_names['lod1_m']};"
    sql_create = f"""
                    CREATE VIEW {schema}.{view_names['lod1_m']} AS
                    SELECT row_number() over() AS view_id,
                    {building_attr},
                    geom.geometry
                    FROM {schema}.building b
                    JOIN {schema}.cityobject o ON o.id=b.id
                    JOIN {schema}.surface_geometry geom ON geom.root_id=b.lod1_multi_surface_id
                    WHERE geom.geometry IS NOT NULL;
                """
    try:
        cursor.execute(sql_drop)
        cursor.execute(sql_create)
    except (Exception, psycopg2.DatabaseError) as error:
        print(error)
    

def install_lod2_solid(cursor,schema):

    sql_drop = f"DROP VIEW IF EXISTS {schema}.{view_names['lod2_s']};"
    sql_create =f"""
                    CREATE VIEW {schema}.{view_names['lod2_s']} AS
                    SELECT row_number() over() AS view_id,
                    {building_attr},
                    geom.solid_geometry as geometry
                    FROM {schema}.building b
                    JOIN {schema}.cityobject o ON o.id=b.id
                    JOIN {schema}.surface_geometry geom ON geom.root_id=b.lod2_solid_id
                    WHERE geom.solid_geometry IS NOT NULL;
                """

    try:
        cursor.execute(sql_drop)
        cursor.execute(sql_create)
    except (Exception, psycopg2.DatabaseError) as error:
        print(error)

def install_lod2_multisurface(cursor,schema):    

    sql_drop = f"DROP VIEW IF EXISTS {schema}.{view_names['lod2_m']};"
    sql_create = f"""
                    CREATE VIEW {schema}.{view_names['lod2_m']} AS
                    SELECT row_number() over() AS view_id,
                    {building_attr},
                    geom.geometry
                    FROM {schema}.building b
                    JOIN {schema}.cityobject o ON o.id=b.id
                    JOIN {schema}.surface_geometry geom ON geom.root_id=b.lod2_multi_surface_id
                    WHERE geom.geometry IS NOT NULL;
                    """
    try:
        cursor.execute(sql_drop)
        cursor.execute(sql_create)
    except (Exception, psycopg2.DatabaseError) as error:
        print(error)


def install_views(dbLoader):
    
    cur = dbLoader.conn.cursor()
    for schema in dbLoader.schemas:
        print(schema)
        if schema not in ['public','citydb_pkg']:

            install_lod0_footprint(cur,schema)
            install_lod0_roofprint(cur,schema)
            install_lod1_solid(cur,schema)
            install_lod1_multisurface(cur,schema)
            install_lod2_solid(cur,schema)
            install_lod2_multisurface(cur,schema)
            print('installing')
            dbLoader.conn.commit()


    cur.close()
    dbLoader.dlg.cbxConnToExist.currentData().has_installation=True
    
def uninstall_views():
    pass

def check_install(dbLoader):
    """
    Check if current database has all the necessary view installed.
    This function helps to avoid new installation on top of existing ones (case when the plugin runs from start)
    """
    cur = dbLoader.conn.cursor()
    for schema in dbLoader.schemas:
        if schema not in ['public','citydb_pkg']:

            sql=    f"""
                    SELECT EXISTS(
                        SELECT FROM information_schema.tables
                        WHERE table_schema='{schema}'
                        AND (
                            table_name='{view_names['lod0_f']}'
                        OR  table_name='{view_names['lod0_r']}'
                        OR  table_name='{view_names['lod1_s']}'
                        OR  table_name='{view_names['lod1_m']}'
                        OR  table_name='{view_names['lod2_s']}'
                        OR  table_name='{view_names['lod2_m']}'
                            )
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
    

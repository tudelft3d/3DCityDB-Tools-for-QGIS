--#######################################
CREATE OR REPLACE FUNCTION qgis_pkg.get_all_schemas()
    RETURNS TABLE(schema information_schema.sql_identifier)
    LANGUAGE 'plpgsql'
    
AS $$
begin
	RETURN QUERY SELECT schema_name
	FROM information_schema.schemata 
	WHERE schema_name != 'information_schema' 
	AND NOT schema_name LIKE '%pg%' ORDER BY schema_name ASC;
end;
$$;


CREATE OR REPLACE FUNCTION qgis_pkg.get_feature_schemas()
    RETURNS TABLE(schema information_schema.sql_identifier)
    LANGUAGE 'plpgsql'
--#####################################
AS $$
declare
feature_tables constant varchar := '(cityobject|building|tunnel|tin_relief|bridge|
waterbody|solitary_vegetat_object|land_use|)'; --Ideally should check for all 60+x tables (for v.4.x)
begin
	RETURN QUERY SELECT DISTINCT(table_schema) FROM information_schema.tables  
	WHERE table_name SIMILAR TO feature_tables
	ORDER BY table_schema ASC;
end;
$$;

--########################################

CREATE OR REPLACE FUNCTION qgis_pkg.get_main_schemas()
    RETURNS TABLE(schema information_schema.sql_identifier)
    LANGUAGE 'plpgsql'
    
AS $$
declare
feature_tables constant varchar := '(cityobject|building|tunnel|tin_relief|bridge|
waterbody|solitary_vegetat_object|land_use|)'; --Ideally should check for all 60+x tables (for v.4.x)
begin
	RETURN QUERY SELECT DISTINCT(table_schema) FROM information_schema.tables  
	WHERE table_name SIMILAR TO feature_tables
	ORDER BY table_schema ASC;
end;
$$;

--########################################

CREATE OR REPLACE FUNCTION qgis_pkg.get_table_privileges(schema varchar)
    RETURNS TABLE(delete_priv boolean, select_priv boolean, referenc_priv boolean, trigger_priv boolean, truncuat_priv boolean, update_priv boolean, insert_priv boolean)
    LANGUAGE 'plpgsql'
    
AS $$
begin
	RETURN QUERY
         WITH "tables"("table") AS (
        SELECT table_name FROM information_schema.tables 
	    WHERE table_schema = schema AND table_type = 'BASE TABLE'
        ) SELECT
        pg_catalog.has_table_privilege(current_user, "table", 'DELETE') AS "delete",
        pg_catalog.has_table_privilege(current_user, "table", 'SELECT') AS "select",
        pg_catalog.has_table_privilege(current_user, "table", 'REFERENCES') AS "references",
        pg_catalog.has_table_privilege(current_user, "table", 'TRIGGER') AS "trigger",
        pg_catalog.has_table_privilege(current_user, "table", 'TRUNCATE') AS "truncate",
        pg_catalog.has_table_privilege(current_user, "table", 'UPDATE') AS "update",
        pg_catalog.has_table_privilege(current_user, "table", 'INSERT') AS "insert"
        FROM "tables";
end;
$$;

--#####################################
CREATE OR REPLACE FUNCTION qgis_pkg.view_counter(view_name varchar,extents varchar)
    RETURNS int
    LANGUAGE 'plpgsql'
    
AS $$
declare 
counter int := 0;
begin
IF EXISTS(
		SELECT table_name from information_schema.tables
		WHERE table_name = view_name) 
THEN
	EXECUTE FORMAT('SELECT count(t.geom) FROM qgis_pkg._g_%I t
	WHERE ST_GeomFromText(%L,28992) && ST_Envelope(t.geom)',view_name,extents)
	INTO counter;
END IF;
	
RETURN counter;
end;
$$;

CREATE OR REPLACE FUNCTION qgis_pkg.view_counter(view_name varchar)
    RETURNS int
    LANGUAGE 'plpgsql'
    
AS $$
declare 
counter int := 0;
begin
IF EXISTS(
		SELECT table_name from information_schema.tables
		WHERE table_name = view_name) 
THEN
	EXECUTE FORMAT('SELECT count(geom) FROM qgis_pkg._g_%I',view_name)
	INTO counter;
END IF;

RETURN counter;
end;
$$;


DROP TABLE IF EXISTS qgis_pkg.metadata;
CREATE TABLE qgis_pkg.metadata (
  id SERIAL,
  module VARCHAR(255),
  root_feature VARCHAR(255),
  schema VARCHAR(255),
  lod VARCHAR(10),
  alias VARCHAR(255),
  layer_name VARCHAR(255),
  object_count INT,
  PRIMARY KEY (id)
);

INSERT INTO qgis_pkg.metadata (module,root_feature,schema,lod,alias,layer_name,object_count)
VALUES
--BUILDING
('Building','Building',	'citydb','LoD0','Building',			            'citydb_building_lod0',qgis_pkg.view_counter('citydb_building_lod0')),
('Building','Building',	'citydb','LoD0','Building FootPrint',		    'citydb_building_lod0_footprint',qgis_pkg.view_counter('citydb_building_lod0_footprint')),
('Building','Building',	'citydb','LoD0','Building RoofEdge',		    'citydb_building_lod0_roofedge',qgis_pkg.view_counter('citydb_building_lod0_roofedge')),
('Building','Building',	'citydb','LoD1','Building',			            'citydb_building_lod1',qgis_pkg.view_counter('citydb_building_lod1')),
('Building','Building',	'citydb','LoD2','Building',			            'citydb_building_lod2',qgis_pkg.view_counter('citydb_building_lod2')),
('Building','Building',	'citydb','LoD2','Building GroundSurface',	    'citydb_building_lod2_themsurf_groundsurface',qgis_pkg.view_counter('citydb_building_lod2_themsurf_groundsurface')),
('Building','Building',	'citydb','LoD2','Building WallSurface',	        'citydb_building_lod2_themsurf_wallsurface',qgis_pkg.view_counter('citydb_building_lod2_themsurf_wallsurface')),
('Building','Building',	'citydb','LoD2','Building RoofSurface',	        'citydb_building_lod2_themsurf_roofsurface',qgis_pkg.view_counter('citydb_building_lod2_themsurf_roofsurface')),
('Building','Building',	'citydb','LoD2','Building OuterCeilingSurface', 'citydb_building_lod2_themsurf_outerceilingsurface',qgis_pkg.view_counter('citydb_building_lod2_themsurf_outerceilingsurface')),
('Building','Building',	'citydb','LoD2','Building OuterFloorSurface',   'citydb_building_lod2_themsurf_outerfloorsurface',qgis_pkg.view_counter('citydb_building_lod2_themsurf_outerfloorsurface')),
('Building','Building',	'citydb','LoD2','Building ClosureSurface',	    'citydb_building_lod2_themsurf_closuresurface',qgis_pkg.view_counter('citydb_building_lod2_themsurf_closuresurface')),
('Building','Building',	'citydb','LoD3','Building',			            'citydb_building_lod3',qgis_pkg.view_counter('citydb_building_lod3')),
('Building','Building',	'citydb','LoD3','Building GroundSurface',	    'citydb_building_lod3_themsurf_groundsurface',qgis_pkg.view_counter('citydb_building_lod3_themsurf_groundsurface')),
('Building','Building',	'citydb','LoD3','Building WallSurface',	        'citydb_building_lod3_themsurf_wallsurface',qgis_pkg.view_counter('citydb_building_lod3_themsurf_wallsurface')),
('Building','Building',	'citydb','LoD3','Building RoofSurface',         'citydb_building_lod3_themsurf_roofsurface',qgis_pkg.view_counter('citydb_building_lod3_themsurf_roofsurface')),
('Building','Building',	'citydb','LoD3','Building OuterCeilingSurface', 'citydb_building_lod3_themsurf_outerceilingsurface',qgis_pkg.view_counter('citydb_building_lod3_themsurf_outerceilingsurface')),
('Building','Building',	'citydb','LoD3','Building OuterFloorSurface',   'citydb_building_lod3_themsurf_outerfloorsurface',qgis_pkg.view_counter('citydb_building_lod3_themsurf_outerfloorsurface')),
('Building','Building',	'citydb','LoD3','Building ClosureSurface',	    'citydb_building_lod3_themsurf_closuresurface',qgis_pkg.view_counter('citydb_building_lod3_themsurf_closuresurface')),
('Building','Building',	'citydb','LoD4','Building',			            'citydb_building_lod4',qgis_pkg.view_counter('citydb_building_lod4')),
('Building','Building',	'citydb','LoD4','Building GroundSurface',	    'citydb_building_lod4_themsurf_groundsurface',qgis_pkg.view_counter('citydb_building_lod4_themsurf_groundsurface')),
('Building','Building',	'citydb','LoD4','Building WallSurface',	        'citydb_building_lod4_themsurf_wallsurface',qgis_pkg.view_counter('citydb_building_lod4_themsurf_wallsurface')),
('Building','Building',	'citydb','LoD4','Building RoofSurface',	        'citydb_building_lod4_themsurf_roofsurface',qgis_pkg.view_counter('citydb_building_lod4_themsurf_roofsurface')),
('Building','Building',	'citydb','LoD4','Building OuterCeilingSurface', 'citydb_building_lod4_themsurf_outerceilingsurface',qgis_pkg.view_counter('citydb_building_lod4_themsurf_outerceilingsurface')),
('Building','Building',	'citydb','LoD4','Building OuterFloorSurface',   'citydb_building_lod4_themsurf_outerfloorsurface',qgis_pkg.view_counter('citydb_building_lod4_themsurf_outerfloorsurface')),
('Building','Building',	'citydb','LoD4','Building ClosureSurface',	    'citydb_building_lod4_themsurf_closuresurface',qgis_pkg.view_counter('citydb_building_lod4_themsurf_closuresurface')),
--BUILDING PART
('Building','BuildingPart',	'citydb','LoD0','BuildingPart',                     'citydb_building_part_lod0',qgis_pkg.view_counter('citydb_building_part_lod0')),
('Building','BuildingPart',	'citydb','LoD0','BuildingPart FootPrint',           'citydb_building_part_lod0_footprint',qgis_pkg.view_counter('citydb_building_part_lod0_footprint')),
('Building','BuildingPart',	'citydb','LoD0','BuildingPart RoofEdge',            'citydb_building_part_lod0_roofedge',qgis_pkg.view_counter('citydb_building_part_lod0_roofedge')),
('Building','BuildingPart',	'citydb','LoD1','BuildingPart',                     'citydb_building_part_lod1',qgis_pkg.view_counter('citydb_building_part_lod1')),
('Building','BuildingPart',	'citydb','LoD2','BuildingPart',                     'citydb_building_part_lod2',qgis_pkg.view_counter('citydb_building_part_lod2')),
('Building','BuildingPart',	'citydb','LoD2','BuildingPart GroundSurface',       'citydb_building_part_lod2_themsurf_groundsurface',qgis_pkg.view_counter('citydb_building_part_lod2_themsurf_groundsurface')),
('Building','BuildingPart',	'citydb','LoD2','BuildingPart WallSurface',         'citydb_building_part_lod2_themsurf_wallsurface',qgis_pkg.view_counter('citydb_building_part_lod2_themsurf_wallsurface')),
('Building','BuildingPart',	'citydb','LoD2','BuildingPart RoofSurface',         'citydb_building_part_lod2_themsurf_roofsurface',qgis_pkg.view_counter('citydb_building_part_lod2_themsurf_roofsurface')),
('Building','BuildingPart',	'citydb','LoD2','BuildingPart OuterCeilingSurface', 'citydb_building_part_lod2_themsurf_outerceilingsurface',qgis_pkg.view_counter('citydb_building_part_lod2_themsurf_outerceilingsurface')),
('Building','BuildingPart',	'citydb','LoD2','BuildingPart OuterFloorSurface',   'citydb_building_part_lod2_themsurf_outerfloorsurface',qgis_pkg.view_counter('citydb_building_part_lod2_themsurf_outerfloorsurface')),
('Building','BuildingPart',	'citydb','LoD2','BuildingPart ClosureSurface',      'citydb_building_part_lod2_themsurf_closuresurface',qgis_pkg.view_counter('citydb_building_part_lod2_themsurf_closuresurface')),
('Building','BuildingPart',	'citydb','LoD3','BuildingPart',                     'citydb_building_part_lod3',qgis_pkg.view_counter('citydb_building_part_lod3')),
('Building','BuildingPart',	'citydb','LoD3','BuildingPart GroundSurface',       'citydb_building_part_lod3_themsurf_groundsurface',qgis_pkg.view_counter('citydb_building_part_lod3_themsurf_groundsurface')),
('Building','BuildingPart',	'citydb','LoD3','BuildingPart WallSurface',         'citydb_building_part_lod3_themsurf_wallsurface',qgis_pkg.view_counter('citydb_building_part_lod3_themsurf_wallsurface')),
('Building','BuildingPart',	'citydb','LoD3','BuildingPart RoofSurface',         'citydb_building_part_lod3_themsurf_roofsurface',qgis_pkg.view_counter('citydb_building_part_lod3_themsurf_roofsurface')),
('Building','BuildingPart',	'citydb','LoD3','BuildingPart OuterCeilingSurface', 'citydb_building_part_lod3_themsurf_outerceilingsurface',qgis_pkg.view_counter('citydb_building_part_lod3_themsurf_outerceilingsurface')),
('Building','BuildingPart',	'citydb','LoD3','BuildingPart OuterFloorSurface',   'citydb_building_part_lod3_themsurf_outerfloorsurface',qgis_pkg.view_counter('citydb_building_part_lod3_themsurf_outerfloorsurface')),
('Building','BuildingPart',	'citydb','LoD3','BuildingPart ClosureSurface',      'citydb_building_part_lod3_themsurf_closuresurface',qgis_pkg.view_counter('citydb_building_part_lod3_themsurf_closuresurface')),
('Building','BuildingPart',	'citydb','LoD4','BuildingPart',                     'citydb_building_part_lod4',qgis_pkg.view_counter('citydb_building_lod4')),
('Building','BuildingPart',	'citydb','LoD4','BuildingPart GroundSurface',       'citydb_building_part_lod4_themsurf_groundsurface',qgis_pkg.view_counter('citydb_building_part_lod4_themsurf_groundsurface')),
('Building','BuildingPart',	'citydb','LoD4','BuildingPart WallSurface',         'citydb_building_part_lod4_themsurf_wallsurface',qgis_pkg.view_counter('citydb_building_part_lod4_themsurf_wallsurface')),
('Building','BuildingPart',	'citydb','LoD4','BuildingPart RoofSurface',         'citydb_building_part_lod4_themsurf_roofsurface',qgis_pkg.view_counter('citydb_building_part_lod4_themsurf_roofsurface')),
('Building','BuildingPart',	'citydb','LoD4','BuildingPart OuterCeilingSurface', 'citydb_building_part_lod4_themsurf_outerceilingsurface',qgis_pkg.view_counter('citydb_building_part_lod4_themsurf_outerceilingsurface')),
('Building','BuildingPart',	'citydb','LoD4','BuildingPart OuterFloorSurface',   'citydb_building_part_lod4_themsurf_outerfloorsurface',qgis_pkg.view_counter('citydb_building_part_lod4_themsurf_outerfloorsurface')),
('Building','BuildingPart',	'citydb','LoD4','BuildingPart ClosureSurface',      'citydb_building_part_lod4_themsurf_outerfloorsurface',qgis_pkg.view_counter('citydb_building_part_lod4_themsurf_outerfloorsurface')),
--Building Installation
('Building','BuildingInstallation','citydb','LoD2','BuildingInstallation ',                     'citydb_building_installation_lod2',qgis_pkg.view_counter('citydb_building_installation_lod2')),
('Building','BuildingInstallation','citydb','LoD2','BuildingInstallation Implicit',             'citydb_building_installation_lod2_implicitrep',qgis_pkg.view_counter('citydb_building_installation_lod2_implicitrep')),
('Building','BuildingInstallation','citydb','LoD2','BuildingInstallation GroundSurface',        'citydb_building_installation_lod2_themsurf_groundsurface',qgis_pkg.view_counter('citydb_building_installation_lod2_themsurf_groundsurface')),
('Building','BuildingInstallation','citydb','LoD2','BuildingInstallation WallSurface',          'citydb_building_installation_lod2_themsurf_wallsurface',qgis_pkg.view_counter('citydb_building_installation_lod2_themsurf_wallsurface')),
('Building','BuildingInstallation','citydb','LoD2','BuildingInstallation RoofSurface',          'citydb_building_installation_lod2_themsurf_roofsurface',qgis_pkg.view_counter('citydb_building_installation_lod2_themsurf_roofsurface')),
('Building','BuildingInstallation','citydb','LoD2','BuildingInstallation OuterCeilingSurface',  'citydb_building_installation_lod2_themsurf_outerceilingsurface',qgis_pkg.view_counter('citydb_building_installation_lod2_themsurf_outerceilingsurface')),
('Building','BuildingInstallation','citydb','LoD2','BuildingInstallation OuterFloorSurface',    'citydb_building_installation_lod2_themsurf_outerfloorsurface',qgis_pkg.view_counter('citydb_building_installation_lod2_themsurf_outerfloorsurface')),
('Building','BuildingInstallation','citydb','LoD2','BuildingInstallation ClosureSurface',       'citydb_building_installation_lod2_themsurf_closuresurface',qgis_pkg.view_counter('citydb_building_installation_lod2_themsurf_closuresurface')),
('Building','BuildingInstallation','citydb','LoD3','BuildingInstallation ',                     'citydb_building_installation_lod3',qgis_pkg.view_counter('citydb_building_installation_lod3')),
('Building','BuildingInstallation','citydb','LoD3','BuildingInstallation Implicit',             'citydb_building_installation_lod3_implicitrep',qgis_pkg.view_counter('citydb_building_installation_lod3_implicitrep')),
('Building','BuildingInstallation','citydb','LoD3','BuildingInstallation GroundSurface',        'citydb_building_installation_lod3_themsurf_groundsurface',qgis_pkg.view_counter('citydb_building_installation_lod3_themsurf_groundsurface')),
('Building','BuildingInstallation','citydb','LoD3','BuildingInstallation WallSurface',          'citydb_building_installation_lod3_themsurf_wallsurface',qgis_pkg.view_counter('citydb_building_installation_lod3_themsurf_wallsurface')),
('Building','BuildingInstallation','citydb','LoD3','BuildingInstallation RoofSurface',          'citydb_building_installation_lod3_themsurf_roofsurface',qgis_pkg.view_counter('citydb_building_installation_lod3_themsurf_roofsurface')),
('Building','BuildingInstallation','citydb','LoD3','BuildingInstallation OuterCeilingSurface',  'citydb_building_installation_lod3_themsurf_outerceilingsurface',qgis_pkg.view_counter('citydb_building_installation_lod3_themsurf_outerceilingsurface')),
('Building','BuildingInstallation','citydb','LoD3','BuildingInstallation OuterFloorSurface',    'citydb_building_installation_lod3_themsurf_outerfloorsurface',qgis_pkg.view_counter('citydb_building_installation_lod3_themsurf_outerfloorsurface')),
('Building','BuildingInstallation','citydb','LoD3','BuildingInstallation ClosureSurface',       'citydb_building_installation_lod3_themsurf_closuresurface',qgis_pkg.view_counter('citydb_building_installation_lod3_themsurf_closuresurface')),
('Building','BuildingInstallation','citydb','LoD4','BuildingInstallation ',                     'citydb_building_installation_lod4',qgis_pkg.view_counter('citydb_building_installation_lod4')),
('Building','BuildingInstallation','citydb','LoD4','BuildingInstallation Implicit',             'citydb_building_opening_lod3_window_implicitrep',qgis_pkg.view_counter('citydb_building_installation_lod4_implicitrep')),
('Building','BuildingInstallation','citydb','LoD4','BuildingInstallation GroundSurface',        'citydb_building_installation_lod4_themsurf_groundsurface',qgis_pkg.view_counter('citydb_building_installation_lod4_themsurf_groundsurface')),
('Building','BuildingInstallation','citydb','LoD4','BuildingInstallation WallSurface',          'citydb_building_installation_lod4_themsurf_wallsurface',qgis_pkg.view_counter('citydb_building_installation_lod4_themsurf_wallsurface')),
('Building','BuildingInstallation','citydb','LoD4','BuildingInstallation RoofSurface',          'citydb_building_installation_lod4_themsurf_roofsurface',qgis_pkg.view_counter('citydb_building_installation_lod4_themsurf_roofsurface')),
('Building','BuildingInstallation','citydb','LoD4','BuildingInstallation OuterCeilingSurface',  'citydb_building_installation_lod4_themsurf_outerceilingsurface',qgis_pkg.view_counter('citydb_building_installation_lod4_themsurf_outerceilingsurface')),
('Building','BuildingInstallation','citydb','LoD4','BuildingInstallation OuterFloorSurface',    'citydb_building_installation_lod4_themsurf_outerfloorsurface',qgis_pkg.view_counter('citydb_building_installation_lod4_themsurf_outerfloorsurface')),
('Building','BuildingInstallation','citydb','LoD4','BuildingInstallation ClosureSurface',       'citydb_building_installation_lod4_themsurf_closuresurface',qgis_pkg.view_counter('citydb_building_installation_lod4_themsurf_closuresurface')),
--Building Opening
('Building','BuildingOpening','citydb','LoD3','BuildingOpening ',                   'citydb_building_opening_lod3',qgis_pkg.view_counter('citydb_building_opening_lod3')),
('Building','BuildingOpening','citydb','LoD3','BuildingOpening Window',             'citydb_building_opening_lod3_window',qgis_pkg.view_counter('citydb_building_opening_lod3_window')),
('Building','BuildingOpening','citydb','LoD3','BuildingOpening Window Implicit',    'citydb_building_opening_lod3_window_implicitrep',qgis_pkg.view_counter('citydb_building_opening_lod3_window_implicitrep')),
('Building','BuildingOpening','citydb','LoD3','BuildingOpening Door',               'citydb_building_opening_lod3_door',qgis_pkg.view_counter('citydb_building_opening_lod3_door')),
('Building','BuildingOpening','citydb','LoD3','BuildingOpening Door Implicit',      'citydb_building_opening_lod3_window_implicitrep',qgis_pkg.view_counter('citydb_building_opening_lod3_door_implicitrep')),
('Building','BuildingOpening','citydb','LoD4','BuildingOpening ',                   'citydb_building_opening_lod4',qgis_pkg.view_counter('citydb_building_opening_lod4')),
('Building','BuildingOpening','citydb','LoD4','BuildingOpening Window',             'citydb_building_opening_lod4_window',qgis_pkg.view_counter('citydb_building_opening_lod4_window')),
('Building','BuildingOpening','citydb','LoD4','BuildingOpening Window Implicit',    'citydb_building_opening_lod3_window_implicitrep',qgis_pkg.view_counter('citydb_building_opening_lod4_window_implicitrep')),
('Building','BuildingOpening','citydb','LoD4','BuildingOpening Door',               'citydb_building_opening_lod4_door',qgis_pkg.view_counter('citydb_building_opening_lod4_door')),
('Building','BuildingOpening','citydb','LoD4','BuildingOpening Door Implicit',      'citydb_building_opening_lod3_window_implicitrep',qgis_pkg.view_counter('citydb_building_opening_lod4_door_implicitrep')),
--Building Room
('Building','BuildingRoom','citydb','LoD4','BuildingRoom',                      'citydb_building_room_lod4',qgis_pkg.view_counter('citydb_building_room_lod4')),
('Building','BuildingRoom','citydb','LoD4','BuildingRoom CeilingSurface',       'citydb_building_room_lod4_themsurf_ceilingsurface',qgis_pkg.view_counter('citydb_building_room_lod4_themsurf_ceilingsurface')),
('Building','BuildingRoom','citydb','LoD4','BuildingRoom InteriorWallSurface',  'citydb_building_room_lod4_themsurf_intwallsurface',qgis_pkg.view_counter('citydb_building_room_lod4_themsurf_intwallsurface')),
('Building','BuildingRoom','citydb','LoD4','BuildingRoom FloorSurface',         'citydb_building_room_lod4_themsurf_floorsurface',qgis_pkg.view_counter('citydb_building_room_lod4_themsurf_floorsurface')),
--Building Interior Installation
('Building','BuildingIntInstallation','citydb','LoD4','BuildingIntInstallation',                        'citydb_building_intinstallation_lod4',qgis_pkg.view_counter('citydb_building_intinstallation_lod4')),
('Building','BuildingIntInstallation','citydb','LoD4','BuildingIntInstallation Implicit',               'citydb_building_opening_lod3_window_implicitrep',qgis_pkg.view_counter('citydb_building_intinstallation_lod4_implicitrep')),
('Building','BuildingIntInstallation','citydb','LoD4','BuildingIntInstallation CeilingSurface',         'citydb_building_intinstallation_lod4_themsurf_ceilingsurface',qgis_pkg.view_counter('citydb_building_intinstallation_lod4_themsurf_ceilingsurface')),
('Building','BuildingIntInstallation','citydb','LoD4','BuildingIntInstallation InteriorWallSurface',    'citydb_building_intinstallation_lod4_hemsurf_intwallsurface',qgis_pkg.view_counter('citydb_building_intinstallation_lod4_hemsurf_intwallsurface')),
('Building','BuildingIntInstallation','citydb','LoD4','BuildingIntInstallation FloorSurface',           'citydb_building_intinstallation_lod4_themsurf_floorsurface',qgis_pkg.view_counter('citydb_building_intinstallation_lod4_themsurf_floorsurface')),
--Building Furniture
('Building','BuildingFurniture','citydb','LoD4','BuildingFurniture',            'citydb_building_furniture_lod4',qgis_pkg.view_counter('citydb_building_furniture_lod4')),
('Building','BuildingFurniture','citydb','LoD4','BuildingFurniture Implicit',   'citydb_building_furniture_lod4',qgis_pkg.view_counter('citydb_building_furniture_lod4')),
--Vegetation Solitary Object
('Vegetation','Vegetation','citydb','LoD1','Vegetation',            'citydb_solitary_vegetat_object_lod1',qgis_pkg.view_counter('citydb_solitary_vegetat_object_lod1')),
('Vegetation','Vegetation','citydb','LoD1','Vegetation Implicit',   'citydb_solitary_vegetat_object_lod1_implicitrep',qgis_pkg.view_counter('citydb_solitary_vegetat_object_lod1_implicitrep')),
('Vegetation','Vegetation','citydb','LoD2','Vegetation',            'citydb_solitary_vegetat_object_lod2',qgis_pkg.view_counter('citydb_solitary_vegetat_object_lod2')),
('Vegetation','Vegetation','citydb','LoD2','Vegetation Implicit',   'citydb_solitary_vegetat_object_lod2_implicitrep',qgis_pkg.view_counter('citydb_solitary_vegetat_object_lod2_implicitrep')),
('Vegetation','Vegetation','citydb','LoD3','Vegetation',            'citydb_solitary_vegetat_object_lod3',qgis_pkg.view_counter('citydb_solitary_vegetat_object_lod3')),
('Vegetation','Vegetation','citydb','LoD3','Vegetation Implicit',   'citydb_solitary_vegetat_object_lod3_implicitrep',qgis_pkg.view_counter('citydb_solitary_vegetat_object_lod3_implicitrep')),
('Vegetation','Vegetation','citydb','LoD4','Vegetation',            'citydb_solitary_vegetat_object_lod4',qgis_pkg.view_counter('citydb_solitary_vegetat_object_lod4')),
('Vegetation','Vegetation','citydb','LoD4','Vegetation Implicit',   'citydb_solitary_vegetat_object_lod4_implicitrep',qgis_pkg.view_counter('citydb_solitary_vegetat_object_lod4_implicitrep')),
--Plant Cover
('Vegetation','PlantCover','citydb','LoD1','PlantCover',   'citydb_plant_cover_lod1',qgis_pkg.view_counter('citydb_plant_cover_lod1')),
('Vegetation','PlantCover','citydb','LoD2','PlantCover',   'citydb_plant_cover_lod2',qgis_pkg.view_counter('citydb_plant_cover_lod2')),
('Vegetation','PlantCover','citydb','LoD3','PlantCover',   'citydb_plant_cover_lod3',qgis_pkg.view_counter('citydb_plant_cover_lod3')),
('Vegetation','PlantCover','citydb','LoD4','PlantCover',   'citydb_plant_cover_lod4',qgis_pkg.view_counter('citydb_plant_cover_lod4'));

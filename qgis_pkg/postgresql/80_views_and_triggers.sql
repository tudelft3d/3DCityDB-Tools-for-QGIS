-- ****************************************************************************
-- ****************************************************************************
--
--
-- CREATE VIEWS for attributes, linked to materialised views of geometries
--
--
-- ****************************************************************************
-- ****************************************************************************

DO $MAINBODY$
DECLARE
BEGIN

----------------------------------------------------------------
-- Create FUNCTION QGIS_PKG.CREATE_UPDATABLE_VIEWS
----------------------------------------------------------------
DROP FUNCTION IF EXISTS    qgis_pkg.create_updatable_views(varchar, geometry) CASCADE;
CREATE OR REPLACE FUNCTION qgis_pkg.create_updatable_views(
citydb_schema 		varchar DEFAULT 'citydb',
mview_bbox			geometry DEFAULT NULL
) 
RETURNS integer AS $$
DECLARE
srid_id			integer; 
r RECORD;
s RECORD;
t RECORD;
u RECORD;
tr RECORD;
l_name			varchar;
view_name		varchar;
mview_name 		varchar;
sql_statement 	varchar;
sql_co_atts		varchar;
trigger_f varchar;

BEGIN

EXECUTE format('SELECT srid FROM citydb.database_srs LIMIT 1') INTO srid_id;
RAISE NOTICE 'Srid in schema is: %', srid_id;

sql_co_atts := '
  co.id::bigint,
  co.gmlid,
  co.gmlid_codespace,
  co.name,
  co.name_codespace,
  co.description,
  co.creation_date,
  co.termination_date,
  co.relative_to_terrain,
  co.relative_to_water,
  co.last_modification_date,
  co.updating_person,
  co.reason_for_update,
  co.lineage,';

---------------------------------------------------------------
-- Create VIEW for BUILDING(PART)S
---------------------------------------------------------------
FOR r IN 
	SELECT * FROM (VALUES
	('Building'::varchar, 26::integer, 'bdg'::varchar),
	('BuildingPart'     , 25         , 'bdg_part')		   
	) AS t(class_name, class_id, class_label)
LOOP
	FOR s IN 
		SELECT * FROM (VALUES
		('lod0'::varchar,	'LoD0'::varchar),
		('lod0_footprint',	'LoD0 Footprint'),
		('lod0_roofedge',	'LoD0 Roofedge'),
		('lod1',			'LoD1'),
		('lod2',			'LoD2'),
		('lod3',			'LoD3'),
		('lod4',			'LoD4')		
		) AS t(suffix, lodx_name)
	LOOP

view_name  := concat(citydb_schema,'_',r.class_label,'_',s.suffix);
mview_name := concat('_g_',view_name);

sql_statement := concat('
DROP VIEW IF EXISTS    qgis_pkg.',view_name,' CASCADE;
CREATE OR REPLACE VIEW qgis_pkg.',view_name,' AS
SELECT',sql_co_atts,
CASE WHEN r.class_name = 'BuildingPart' THEN '
  o.building_parent_id,
  o.building_root_id,'
ELSE
 NULL
END,'
  o.class,
  o.class_codespace,
  string_to_array(o.function, ''--/\--'')::varchar[] AS function,
  string_to_array(o.function_codespace, ''--/\--'')::varchar[] AS function_codespace,  
  string_to_array(o.usage, ''--/\--'')::varchar[] AS usage,
  string_to_array(o.usage_codespace, ''--/\--'')::varchar[] AS usage_codespace, 
  o.year_of_construction,
  o.year_of_demolition,
  o.roof_type,
  o.roof_type_codespace,
  o.measured_height,
  o.measured_height_unit,
  o.storeys_above_ground,
  o.storeys_below_ground,
  o.storey_heights_above_ground,
  o.storey_heights_ag_unit,
  o.storey_heights_below_ground,
  o.storey_heights_bg_unit,
  g.geom::geometry(MultiPolygonZ,',srid_id,')
FROM
	qgis_pkg.',mview_name,' AS g 
	INNER JOIN ',citydb_schema,'.cityobject AS co ON (g.co_id = co.id AND co.objectclass_id = ',r.class_id,')
  	INNER JOIN ',citydb_schema,'.building AS o ON (o.id = co.id AND o.objectclass_id = ',r.class_id,');
COMMENT ON VIEW qgis_pkg.',view_name,' IS ''View of ',r.class_name,' ',s.lodx_name,''';
');
EXECUTE sql_statement;

-- ********* BEGIN TRIGGERS
		FOR tr IN 
			SELECT * FROM (VALUES
			('ins'::varchar,	'insert'::varchar,	'INSERT'::varchar),
			('upd',				'update',			'UPDATE'),
			('del',				'delete',			'DELETE')	
			) AS t(tr_short, tr_small, tr_cap)
		LOOP

trigger_f := concat('tr_',tr.tr_short,'_building()');

sql_statement := concat('
DROP TRIGGER IF EXISTS tr_',tr.tr_short,'_',view_name,' ON qgis_pkg.',view_name,';
CREATE TRIGGER         tr_',tr.tr_short,'_',view_name,'
	INSTEAD OF ',tr.tr_cap,' ON qgis_pkg.',view_name,'
	FOR EACH ROW
	EXECUTE PROCEDURE qgis_pkg.',trigger_f,';
COMMENT ON TRIGGER tr_',tr.tr_short,'_',view_name,' ON qgis_pkg.',view_name,' IS ''Fired upon ',tr.tr_small,' into view qgis_pkg.',view_name,''';
');
EXECUTE sql_statement;
		END LOOP; -- end loop trigger operation list
-- ********* END TRIGGERS

	END LOOP; -- end loop building/part 

---------------------------------------------------------------
-- Create VIEW for BUILDING(PART)S_THEMATIC_SURFACES
---------------------------------------------------------------
	FOR s IN 
		SELECT * FROM (VALUES
		('lod2',			'LoD2'),
		('lod3',			'LoD3'),
		('lod4',			'LoD4')		
		) AS t(suffix, lodx_label)
	LOOP
		FOR t IN 
			SELECT * FROM (VALUES
			('RoofSurface'::varchar , 33::integer, 'roofsurf'::varchar),
			('WallSurface'			, 34		 , 'wallsurf'),
			('GroundSurface'		, 35		 , 'groundsurf'),
			('ClosureSurface'		, 36		 , 'closuresurf'),
			('OuterCeilingSurface'	, 60		 , 'outerceilingsurf'),
			('OuterFloorSurface'	, 61		 , 'outerfloorsurf')
			) AS t(themsurf_name, class_id, themsurf_label)
		LOOP

view_name  := concat(citydb_schema,'_',r.class_label,'_',s.suffix,'_',t.themsurf_label);
mview_name := concat('_g_',view_name);

sql_statement := concat('
DROP VIEW IF EXISTS    qgis_pkg.',view_name,' CASCADE;
CREATE OR REPLACE VIEW qgis_pkg.',view_name,' AS
SELECT',sql_co_atts,'
  o.building_id,
  g.geom::geometry(MultiPolygonZ,',srid_id,')
FROM
	qgis_pkg.',mview_name,' AS g 
	INNER JOIN ',citydb_schema,'.cityobject AS co ON (g.co_id = co.id AND co.objectclass_id = ',t.class_id,')
  	INNER JOIN ',citydb_schema,'.thematic_surface AS o ON (o.id = co.id AND o.objectclass_id = ',t.class_id,');
COMMENT ON VIEW qgis_pkg.',view_name,' IS ''View of (',r.class_name,') ',s.lodx_label,' ',t.themsurf_name,''';
');
EXECUTE sql_statement;

-- ********* BEGIN TRIGGERS
		FOR tr IN 
			SELECT * FROM (VALUES
			('ins'::varchar,	'insert'::varchar,	'INSERT'::varchar),
			('upd',				'update',			'UPDATE'),
			('del',				'delete',			'DELETE')	
			) AS t(tr_short, tr_small, tr_cap)
		LOOP

trigger_f := concat('tr_',tr.tr_short,'_building_thematic_surface()');

sql_statement := concat('
DROP TRIGGER IF EXISTS tr_',tr.tr_short,'_',view_name,' ON qgis_pkg.',view_name,';
CREATE TRIGGER         tr_',tr.tr_short,'_',view_name,'
	INSTEAD OF ',tr.tr_cap,' ON qgis_pkg.',view_name,'
	FOR EACH ROW
	EXECUTE PROCEDURE qgis_pkg.',trigger_f,';
COMMENT ON TRIGGER tr_',tr.tr_short,'_',view_name,' ON qgis_pkg.',view_name,' IS ''Fired upon ',tr.tr_small,' into view qgis_pkg.',view_name,''';
');
EXECUTE sql_statement;
		END LOOP; -- end loop trigger operation list
-- ********* END TRIGGERS

		END LOOP; -- loop building / part thematic surfaces types
	END LOOP; -- loop building / part thematic surfaces lod

---------------------------------------------------------------
-- Create VIEW for OUTER_BUILDING(PART)_INSTALLATION
---------------------------------------------------------------
	FOR s IN 
		SELECT * FROM (VALUES
		('BuildingInstallation'::varchar, 27::integer, 'out_inst'::varchar)
		) AS t(class_name, class_id, class_label)
	LOOP
		FOR t IN 
			SELECT * FROM (VALUES
			('LoD2'::varchar, 'lod2'::varchar),
			('LoD3'			, 'lod3'),
			('LoD4'			, 'lod4')		
			) AS t(lodx_name, lodx_label)
		LOOP

view_name  := concat(citydb_schema,'_',r.class_label,'_',s.class_label,'_',t.lodx_label);
mview_name := concat('_g_',view_name);

sql_statement := concat('
DROP VIEW IF EXISTS    qgis_pkg.',view_name,' CASCADE;
CREATE OR REPLACE VIEW qgis_pkg.',view_name,' AS
SELECT',sql_co_atts,'
  o.class,
  o.class_codespace,
  string_to_array(o.function, ''--/\--'')::varchar[] AS function,
  string_to_array(o.function_codespace, ''--/\--'')::varchar[] AS function_codespace,  
  string_to_array(o.usage, ''--/\--'')::varchar[] AS usage,
  string_to_array(o.usage_codespace, ''--/\--'')::varchar[] AS usage_codespace,
  o.building_id,
  g.geom::geometry(MultiPolygonZ,',srid_id,')
FROM
	qgis_pkg.',mview_name,' AS g 
	INNER JOIN ',citydb_schema,'.cityobject AS co ON (g.co_id = co.id AND co.objectclass_id = ',s.class_id,')
  	INNER JOIN ',citydb_schema,'.building_installation AS o ON (o.id = co.id AND o.objectclass_id = ',s.class_id,');
COMMENT ON VIEW qgis_pkg.',view_name,' IS ''View of (',r.class_name,') ',s.class_name,' ',t.lodx_name,''';
');
EXECUTE sql_statement;

-- ********* BEGIN TRIGGERS
		FOR tr IN 
			SELECT * FROM (VALUES
			('ins'::varchar,	'insert'::varchar,	'INSERT'::varchar),
			('upd',				'update',			'UPDATE'),
			('del',				'delete',			'DELETE')	
			) AS t(tr_short, tr_small, tr_cap)
		LOOP

trigger_f := concat('tr_',tr.tr_short,'_building_installation()');

sql_statement := concat('
DROP TRIGGER IF EXISTS tr_',tr.tr_short,'_',view_name,' ON qgis_pkg.',view_name,';
CREATE TRIGGER         tr_',tr.tr_short,'_',view_name,'
	INSTEAD OF ',tr.tr_cap,' ON qgis_pkg.',view_name,'
	FOR EACH ROW
	EXECUTE PROCEDURE qgis_pkg.',trigger_f,';
COMMENT ON TRIGGER tr_',tr.tr_short,'_',view_name,' ON qgis_pkg.',view_name,' IS ''Fired upon ',tr.tr_small,' into view qgis_pkg.',view_name,''';
');
EXECUTE sql_statement;
		END LOOP; -- end loop trigger operation list
-- ********* END TRIGGERS

---------------------------------------------------------------
-- Create VIEW for OUTER_BUILDING(PART)INSTALLATION_THEMATIC_SURFACES
---------------------------------------------------------------
			FOR u IN 
				SELECT * FROM (VALUES
				('RoofSurface'::varchar , 33::integer, 'roofsurf'::varchar),
				('WallSurface'			, 34		 , 'wallsurf'),
				('GroundSurface'		, 35		 , 'groundsurf'),
				('ClosureSurface'		, 36		 , 'closuresurf'),
				('OuterCeilingSurface'	, 60		 , 'outerceilingsurf'),
				('OuterFloorSurface'	, 61		 , 'outerfloorsurf')
				) AS t(themsurf_name, class_id, themsurf_label)
			LOOP

view_name  := concat(citydb_schema,'_',r.class_label,'_',s.class_label,'_',t.lodx_label,'_',u.themsurf_label);
mview_name := concat('_g_',view_name);

sql_statement := concat('
DROP VIEW IF EXISTS    qgis_pkg.',view_name,' CASCADE;
CREATE OR REPLACE VIEW qgis_pkg.',view_name,' AS
SELECT',sql_co_atts,'
  o.building_installation_id,
  g.geom::geometry(MultiPolygonZ,',srid_id,')
FROM
	qgis_pkg.',mview_name,' AS g 
	INNER JOIN ',citydb_schema,'.cityobject AS co ON (g.co_id = co.id AND co.objectclass_id = ',u.class_id,')
  	INNER JOIN ',citydb_schema,'.thematic_surface AS o ON (o.id = co.id AND o.objectclass_id = ',u.class_id,');
COMMENT ON VIEW qgis_pkg.',view_name,' IS ''View of (',r.class_name,') ',s.class_name,' ',t.lodx_name,' ',u.themsurf_label,''';
');
EXECUTE sql_statement;

-- ********* BEGIN TRIGGERS
		FOR tr IN 
			SELECT * FROM (VALUES
			('ins'::varchar,	'insert'::varchar,	'INSERT'::varchar),
			('upd',				'update',			'UPDATE'),
			('del',				'delete',			'DELETE')	
			) AS t(tr_short, tr_small, tr_cap)
		LOOP

trigger_f := concat('tr_',tr.tr_short,'_building_thematic_surface()');

sql_statement := concat('
DROP TRIGGER IF EXISTS tr_',tr.tr_short,'_',view_name,' ON qgis_pkg.',view_name,';
CREATE TRIGGER         tr_',tr.tr_short,'_',view_name,'
	INSTEAD OF ',tr.tr_cap,' ON qgis_pkg.',view_name,'
	FOR EACH ROW
	EXECUTE PROCEDURE qgis_pkg.',trigger_f,';
COMMENT ON TRIGGER tr_',tr.tr_short,'_',view_name,' ON qgis_pkg.',view_name,' IS ''Fired upon ',tr.tr_small,' into view qgis_pkg.',view_name,''';
');
EXECUTE sql_statement;
		END LOOP; -- end loop trigger operation list
-- ********* END TRIGGERS


			END LOOP; -- bdg outer installation thematic surface

		END LOOP; -- bdg outer installation lod
	END LOOP; -- bdg outer installation


---------------------------------------------------------------
-- Create VIEW for INT_BUILDING(PART)_INSTALLATION
---------------------------------------------------------------
	FOR s IN 
		SELECT * FROM (VALUES
		('IntBuildingInstallation'::varchar, 28::integer, 'int_inst'::varchar)
		) AS t(class_name, class_id, class_label)
	LOOP
		FOR t IN 
			SELECT * FROM (VALUES
			('LoD4'::varchar, 'lod4'::varchar)
			) AS t(lodx_name, lodx_label)
		LOOP

view_name  := concat(citydb_schema,'_',r.class_label,'_',s.class_label,'_',t.lodx_label);
mview_name := concat('_g_',view_name);

sql_statement := concat('
DROP VIEW IF EXISTS    qgis_pkg.',view_name,' CASCADE;
CREATE OR REPLACE VIEW qgis_pkg.',view_name,' AS
SELECT',sql_co_atts,'
  o.class,
  o.class_codespace,
  string_to_array(o.function, ''--/\--'')::varchar[] AS function,
  string_to_array(o.function_codespace, ''--/\--'')::varchar[] AS function_codespace,  
  string_to_array(o.usage, ''--/\--'')::varchar[] AS usage,
  string_to_array(o.usage_codespace, ''--/\--'')::varchar[] AS usage_codespace,
  o.building_id,
  g.geom::geometry(MultiPolygonZ,',srid_id,')
FROM
	qgis_pkg.',mview_name,' AS g 
	INNER JOIN ',citydb_schema,'.cityobject AS co ON (g.co_id = co.id AND co.objectclass_id = ',s.class_id,')
  	INNER JOIN ',citydb_schema,'.building_installation AS o ON (o.id = co.id AND o.objectclass_id = ',s.class_id,');
COMMENT ON VIEW qgis_pkg.',view_name,' IS ''View of (',r.class_name,') ',s.class_name,' ',t.lodx_name,''';
');
EXECUTE sql_statement;

-- ********* BEGIN TRIGGERS
		FOR tr IN 
			SELECT * FROM (VALUES
			('ins'::varchar,	'insert'::varchar,	'INSERT'::varchar),
			('upd',				'update',			'UPDATE'),
			('del',				'delete',			'DELETE')	
			) AS t(tr_short, tr_small, tr_cap)
		LOOP

trigger_f := concat('tr_',tr.tr_short,'_building_installation()');

sql_statement := concat('
DROP TRIGGER IF EXISTS tr_',tr.tr_short,'_',view_name,' ON qgis_pkg.',view_name,';
CREATE TRIGGER         tr_',tr.tr_short,'_',view_name,'
	INSTEAD OF ',tr.tr_cap,' ON qgis_pkg.',view_name,'
	FOR EACH ROW
	EXECUTE PROCEDURE qgis_pkg.',trigger_f,';
COMMENT ON TRIGGER tr_',tr.tr_short,'_',view_name,' ON qgis_pkg.',view_name,' IS ''Fired upon ',tr.tr_small,' into view qgis_pkg.',view_name,''';
');
EXECUTE sql_statement;
		END LOOP; -- end loop trigger operation list
-- ********* END TRIGGERS

---------------------------------------------------------------
-- Create VIEW for INT_BUILDING(PART)_INSTALLATION_THEMATIC_SURFACES
---------------------------------------------------------------
			FOR u IN 
				SELECT * FROM (VALUES
				('RoofSurface'::varchar , 33::integer, 'roofsurf'::varchar),
				('WallSurface'			, 34		 , 'wallsurf'),
				('GroundSurface'		, 35		 , 'groundsurf'),
				('ClosureSurface'		, 36		 , 'closuresurf'),
				('OuterCeilingSurface'	, 60		 , 'outerceilingsurf'),
				('OuterFloorSurface'	, 61		 , 'outerfloorsurf')
				) AS t(themsurf_name, class_id, themsurf_label)
			LOOP

view_name  := concat(citydb_schema,'_',r.class_label,'_',s.class_label,'_',t.lodx_label,'_',u.themsurf_label);
mview_name := concat('_g_',view_name);

sql_statement := concat('
DROP VIEW IF EXISTS    qgis_pkg.',view_name,' CASCADE;
CREATE OR REPLACE VIEW qgis_pkg.',view_name,' AS
SELECT',sql_co_atts,'
  o.building_installation_id,
  g.geom::geometry(MultiPolygonZ,',srid_id,')
FROM
	qgis_pkg.',mview_name,' AS g 
	INNER JOIN ',citydb_schema,'.cityobject AS co ON (g.co_id = co.id AND co.objectclass_id = ',u.class_id,')
  	INNER JOIN ',citydb_schema,'.thematic_surface AS o ON (o.id = co.id AND o.objectclass_id = ',u.class_id,');
COMMENT ON VIEW qgis_pkg.',view_name,' IS ''View of (',r.class_name,') ',s.class_name,' ',t.lodx_name,' ',u.themsurf_label,''';
');
EXECUTE sql_statement;

-- ********* BEGIN TRIGGERS
		FOR tr IN 
			SELECT * FROM (VALUES
			('ins'::varchar,	'insert'::varchar,	'INSERT'::varchar),
			('upd',				'update',			'UPDATE'),
			('del',				'delete',			'DELETE')	
			) AS t(tr_short, tr_small, tr_cap)
		LOOP

trigger_f := concat('tr_',tr.tr_short,'_building_thematic_surface()');

sql_statement := concat('
DROP TRIGGER IF EXISTS tr_',tr.tr_short,'_',view_name,' ON qgis_pkg.',view_name,';
CREATE TRIGGER         tr_',tr.tr_short,'_',view_name,'
	INSTEAD OF ',tr.tr_cap,' ON qgis_pkg.',view_name,'
	FOR EACH ROW
	EXECUTE PROCEDURE qgis_pkg.',trigger_f,';
COMMENT ON TRIGGER tr_',tr.tr_short,'_',view_name,' ON qgis_pkg.',view_name,' IS ''Fired upon ',tr.tr_small,' into view qgis_pkg.',view_name,''';
');
EXECUTE sql_statement;
		END LOOP; -- end loop trigger operation list
-- ********* END TRIGGERS

			END LOOP; -- bdg outer installation thematic surface

		END LOOP; -- bdg outer installation lod
	END LOOP; -- bdg outer installation

---------------------------------------------------------------
-- Create VIEW for ROOM
---------------------------------------------------------------
	FOR s IN 
		SELECT * FROM (VALUES
		('Room'::varchar, 41::integer, 'room'::varchar)
		) AS t(class_name, class_id, class_label)
	LOOP

view_name  := concat(citydb_schema,'_',r.class_label,'_',s.class_label,'_lod4');
mview_name := concat('_g_',view_name);

sql_statement := concat('
DROP VIEW IF EXISTS    qgis_pkg.',view_name,' CASCADE;
CREATE OR REPLACE VIEW qgis_pkg.',view_name,' AS
SELECT',sql_co_atts,'
  o.class,
  o.class_codespace,
  string_to_array(o.function, ''--/\--'')::varchar[] AS function,
  string_to_array(o.function_codespace, ''--/\--'')::varchar[] AS function_codespace,  
  string_to_array(o.usage, ''--/\--'')::varchar[] AS usage,
  string_to_array(o.usage_codespace, ''--/\--'')::varchar[] AS usage_codespace,
  o.building_id,
  g.geom::geometry(MultiPolygonZ,',srid_id,')
FROM
	qgis_pkg.',mview_name,' AS g 
	INNER JOIN ',citydb_schema,'.cityobject AS co ON (g.co_id = co.id AND co.objectclass_id = ',s.class_id,')
  	INNER JOIN ',citydb_schema,'.room AS o ON (o.id = co.id AND o.objectclass_id = ',s.class_id,');
COMMENT ON VIEW qgis_pkg.',view_name,' IS ''View of (',r.class_name,') ',s.class_name,' LoD4'';
');
EXECUTE sql_statement;

---------------------------------------------------------------
-- Create VIEW for ROOM_THEMATIC_SURFACES
---------------------------------------------------------------
		FOR t IN 
			SELECT * FROM (VALUES
			('CeilingSurface'::varchar , 30::integer, 'ceilingsurf'::varchar),
			('InteriorWall'			   , 31		 	, 'intwallsurf'),
			('FloorSurface'			   , 32		    , 'floorsurf')
			) AS t(themsurf_name, class_id, themsurf_label)
		LOOP

view_name  := concat(citydb_schema,'_',r.class_label,'_',s.class_label,'_lod4_',t.themsurf_label);
mview_name := concat('_g_',view_name);

sql_statement := concat('
DROP VIEW IF EXISTS    qgis_pkg.',view_name,' CASCADE;
CREATE OR REPLACE VIEW qgis_pkg.',view_name,' AS
SELECT',sql_co_atts,'
  o.room_id,
  g.geom::geometry(MultiPolygonZ,',srid_id,')
FROM
	qgis_pkg.',mview_name,' AS g 
	INNER JOIN ',citydb_schema,'.cityobject AS co ON (g.co_id = co.id AND co.objectclass_id = ',s.class_id,')
  	INNER JOIN ',citydb_schema,'.thematic_surface AS o ON (o.id = co.id AND o.objectclass_id = ',s.class_id,');
COMMENT ON VIEW qgis_pkg.',view_name,' IS ''View of (',r.class_name,') ',s.class_name,' LoD4 ',t.themsurf_label,''';
');
EXECUTE sql_statement;

-- ********* BEGIN TRIGGERS
		FOR tr IN 
			SELECT * FROM (VALUES
			('ins'::varchar,	'insert'::varchar,	'INSERT'::varchar),
			('upd',				'update',			'UPDATE'),
			('del',				'delete',			'DELETE')	
			) AS t(tr_short, tr_small, tr_cap)
		LOOP

trigger_f := concat('tr_',tr.tr_short,'_building_thematic_surface()');

sql_statement := concat('
DROP TRIGGER IF EXISTS tr_',tr.tr_short,'_',view_name,' ON qgis_pkg.',view_name,';
CREATE TRIGGER         tr_',tr.tr_short,'_',view_name,'
	INSTEAD OF ',tr.tr_cap,' ON qgis_pkg.',view_name,'
	FOR EACH ROW
	EXECUTE PROCEDURE qgis_pkg.',trigger_f,';
COMMENT ON TRIGGER tr_',tr.tr_short,'_',view_name,' ON qgis_pkg.',view_name,' IS ''Fired upon ',tr.tr_small,' into view qgis_pkg.',view_name,''';
');
EXECUTE sql_statement;
		END LOOP; -- end loop trigger operation list
-- ********* END TRIGGERS

		END LOOP; -- room thematic surfaces loop
	END LOOP; -- room loop

---------------------------------------------------------------
-- Create VIEW for DOOR/WINDOW
---------------------------------------------------------------
	FOR s IN 
		SELECT * FROM (VALUES
		('Window'::varchar, 38::integer, 'window'::varchar),
		('Door'           , 39         , 'door')		
		) AS t(class_name, class_id, class_label)
	LOOP
		FOR t IN 
			SELECT * FROM (VALUES
			('LoD3'::varchar, 'lod3'::varchar),
			('LoD4'			, 'lod4')		
			) AS t(lodx_name, lodx_label)
		LOOP

view_name  := concat(citydb_schema,'_',r.class_label,'_',s.class_label,'_',t.lodx_label);
mview_name := concat('_g_',view_name);

sql_statement := concat('
DROP VIEW IF EXISTS    qgis_pkg.',view_name,' CASCADE;
CREATE OR REPLACE VIEW qgis_pkg.',view_name,' AS
SELECT',sql_co_atts,'
  o.thematic_surface_id,
  g.geom::geometry(MultiPolygonZ,',srid_id,')
FROM
	qgis_pkg.',mview_name,' AS g 
	INNER JOIN ',citydb_schema,'.cityobject AS co ON (g.co_id = co.id AND co.objectclass_id = ',s.class_id,')
  	INNER JOIN ',citydb_schema,'.opening_to_them_surface AS o ON (o.opening_id = co.id);
COMMENT ON VIEW qgis_pkg.',view_name,' IS ''View of (',r.class_name,') ',s.class_name,' ',t.lodx_label,''';
');
EXECUTE sql_statement;

		END LOOP; -- bgd window/door lod
	END LOOP; -- bgd window/door

---------------------------------------------------------------
-- Create VIEW for BUILDING(PART)_FURNITURE
---------------------------------------------------------------
	FOR s IN 
		SELECT * FROM (VALUES
		('BuildingFurniture'::varchar, 40::integer, 'furniture'::varchar)		
		) AS t(class_name, class_id, class_label)
	LOOP

view_name  := concat(citydb_schema,'_',r.class_label,'_',s.class_label,'_lod4');
mview_name := concat('_g_',view_name);

sql_statement := concat('
DROP VIEW IF EXISTS    qgis_pkg.',view_name,' CASCADE;
CREATE OR REPLACE VIEW qgis_pkg.',view_name,' AS
SELECT',sql_co_atts,'
  o.class,
  o.class_codespace,
  string_to_array(o.function, ''--/\--'')::varchar[] AS function,
  string_to_array(o.function_codespace, ''--/\--'')::varchar[] AS function_codespace,  
  string_to_array(o.usage, ''--/\--'')::varchar[] AS usage,
  string_to_array(o.usage_codespace, ''--/\--'')::varchar[] AS usage_codespace,
  o.room_id,
  g.geom::geometry(MultiPolygonZ,',srid_id,')
FROM
	qgis_pkg.',mview_name,' AS g 
	INNER JOIN ',citydb_schema,'.cityobject AS co ON (g.co_id = co.id AND co.objectclass_id = ',s.class_id,')
  	INNER JOIN ',citydb_schema,'.building_furniture AS o ON (o.id = co.id AND o.objectclass_id = ',s.class_id,');
COMMENT ON VIEW qgis_pkg.',view_name,' IS ''View of (',r.class_name,') ',s.class_name,' LoD4'';
');
EXECUTE sql_statement;

	END LOOP; -- building furniture

END LOOP; -- loop building / part

---------------------------------------------------------------
-- Create VIEW for SOLITARY_VEGETATION_OBJECT
---------------------------------------------------------------
FOR r IN 
	SELECT * FROM (VALUES
	('SolitaryVegetationObject'::varchar, 7::integer, 'sol_veg_obj'::varchar)
	) AS t(class_name, class_id, class_label)
LOOP
	FOR s IN 
		SELECT * FROM (VALUES
		('LoD1'::varchar, 'lod1'::varchar),
		('LoD2'			, 'lod2'),
		('LoD3'			, 'lod3'),
		('LoD4'			, 'lod4')		
		) AS t(lodx_name, lodx_label)
	LOOP

view_name  := concat(citydb_schema,'_',r.class_label,'_',s.lodx_label);
mview_name := concat('_g_',view_name);

sql_statement := concat('
DROP VIEW IF EXISTS    qgis_pkg.',view_name,' CASCADE;
CREATE OR REPLACE VIEW qgis_pkg.',view_name,' AS
SELECT',sql_co_atts,'
  o.class,
  o.class_codespace,
  string_to_array(o.function, ''--/\--'')::varchar[] AS function,
  string_to_array(o.function_codespace, ''--/\--'')::varchar[] AS function_codespace,  
  string_to_array(o.usage, ''--/\--'')::varchar[] AS usage,
  string_to_array(o.usage_codespace, ''--/\--'')::varchar[] AS usage_codespace,
  o.species,            
  o.species_codespace, 
  o.height,
  o.height_unit,
  o.trunk_diameter,
  o.trunk_diameter_unit,
  o.crown_diameter,
  o.crown_diameter_unit,
  g.geom::geometry(MultiPolygonZ,',srid_id,')
FROM
	qgis_pkg.',mview_name,' AS g 
	INNER JOIN ',citydb_schema,'.cityobject AS co ON (g.co_id = co.id AND co.objectclass_id = ',r.class_id,')
  	INNER JOIN ',citydb_schema,'.solitary_vegetat_object AS o ON (o.id = co.id AND o.objectclass_id = ',r.class_id,');
COMMENT ON VIEW qgis_pkg.',view_name,' IS ''View of ',r.class_name,' ',s.lodx_name,''';
');
EXECUTE sql_statement;

-- ********* BEGIN TRIGGERS
		FOR tr IN 
			SELECT * FROM (VALUES
			('ins'::varchar,	'insert'::varchar,	'INSERT'::varchar),
			('upd',				'update',			'UPDATE'),
			('del',				'delete',			'DELETE')	
			) AS t(tr_short, tr_small, tr_cap)
		LOOP

trigger_f := concat('tr_',tr.tr_short,'_solitary_vegetat_object()');

sql_statement := concat('
DROP TRIGGER IF EXISTS tr_',tr.tr_short,'_',view_name,' ON qgis_pkg.',view_name,';
CREATE TRIGGER         tr_',tr.tr_short,'_',view_name,'
	INSTEAD OF ',tr.tr_cap,' ON qgis_pkg.',view_name,'
	FOR EACH ROW
	EXECUTE PROCEDURE qgis_pkg.',trigger_f,';
COMMENT ON TRIGGER tr_',tr.tr_short,'_',view_name,' ON qgis_pkg.',view_name,' IS ''Fired upon ',tr.tr_small,' into view qgis_pkg.',view_name,''';
');
EXECUTE sql_statement;
		END LOOP; -- end loop trigger operation list
-- ********* END TRIGGERS

	END LOOP; -- solitary_vegetat_object lod
END LOOP; -- solitary_vegetat_object

---------------------------------------------------------------
-- Create VIEW for PLANT_COVER
---------------------------------------------------------------
FOR r IN 
	SELECT * FROM (VALUES
	('PlantCover'::varchar, 7::integer, 'plant_cover'::varchar)
	) AS t(class_name, class_id, class_label)
LOOP
	FOR s IN 
		SELECT * FROM (VALUES
		('LoD1'::varchar, 'lod1'::varchar),
		('LoD2'			, 'lod2'),
		('LoD3'			, 'lod3'),
		('LoD4'			, 'lod4')		
		) AS t(lodx_name, lodx_label)
	LOOP

view_name  := concat(citydb_schema,'_',r.class_label,'_',s.lodx_label);
mview_name := concat('_g_',view_name);

sql_statement := concat('
DROP VIEW IF EXISTS    qgis_pkg.',view_name,' CASCADE;
CREATE OR REPLACE VIEW qgis_pkg.',view_name,' AS
SELECT',sql_co_atts,'
  o.class,
  o.class_codespace,
  string_to_array(o.function, ''--/\--'')::varchar[] AS function,
  string_to_array(o.function_codespace, ''--/\--'')::varchar[] AS function_codespace,  
  string_to_array(o.usage, ''--/\--'')::varchar[] AS usage,
  string_to_array(o.usage_codespace, ''--/\--'')::varchar[] AS usage_codespace,
  o.average_height,
  o.average_height_unit,
  g.geom::geometry(MultiPolygonZ,',srid_id,')
FROM
	qgis_pkg.',mview_name,' AS g 
	INNER JOIN ',citydb_schema,'.cityobject AS co ON (g.co_id = co.id AND co.objectclass_id = ',r.class_id,')
  	INNER JOIN ',citydb_schema,'.plant_cover AS o ON (o.id = co.id AND o.objectclass_id = ',r.class_id,');
COMMENT ON VIEW qgis_pkg.',view_name,' IS ''View of ',r.class_name,' ',s.lodx_name,''';
');
EXECUTE sql_statement;

	END LOOP; -- plant_cover lod
END LOOP; -- plant_cover

---------------------------------------------------------------
-- Create VIEW for LAND_USE
---------------------------------------------------------------
FOR r IN 
	SELECT * FROM (VALUES
	('LandUse'::varchar, 4::integer, 'land_use'::varchar)
	) AS t(class_name, class_id, class_label)
LOOP
	FOR s IN 
		SELECT * FROM (VALUES
		('LoD0'::varchar, 'lod0'::varchar),
		('LoD1'			, 'lod1'),
		('LoD2'			, 'lod2'),
		('LoD3'			, 'lod3'),
		('LoD4'			, 'lod4')		
		) AS t(lodx_name, lodx_label)
	LOOP

view_name  := concat(citydb_schema,'_',r.class_label,'_',s.lodx_label);
mview_name := concat('_g_',view_name);

sql_statement := concat('
DROP VIEW IF EXISTS    qgis_pkg.',view_name,' CASCADE;
CREATE OR REPLACE VIEW qgis_pkg.',view_name,' AS
SELECT',sql_co_atts,'
  o.class,
  o.class_codespace,
  string_to_array(o.function, ''--/\--'')::varchar[] AS function,
  string_to_array(o.function_codespace, ''--/\--'')::varchar[] AS function_codespace,  
  string_to_array(o.usage, ''--/\--'')::varchar[] AS usage,
  string_to_array(o.usage_codespace, ''--/\--'')::varchar[] AS usage_codespace,
  g.geom::geometry(MultiPolygonZ,',srid_id,')
FROM
	qgis_pkg.',mview_name,' AS g 
	INNER JOIN ',citydb_schema,'.cityobject AS co ON (g.co_id = co.id AND co.objectclass_id = ',r.class_id,')
  	INNER JOIN ',citydb_schema,'.land_use AS o ON (o.id = co.id AND o.objectclass_id = ',r.class_id,');
COMMENT ON VIEW qgis_pkg.',view_name,' IS ''View of ',r.class_name,' ',s.lodx_name,''';
');
EXECUTE sql_statement;

	END LOOP; -- land use lod
END LOOP;  -- land use

---------------------------------------------------------------
-- Create VIEW for GENERIC_CITY_OBJECT
---------------------------------------------------------------
FOR r IN 
	SELECT * FROM (VALUES
	('GenericCityObject'::varchar, 5::integer, 'gen_cityobject'::varchar)
	) AS t(class_name, class_id, class_label)
LOOP
	FOR s IN 
		SELECT * FROM (VALUES
		('LoD0'::varchar, 'lod0'::varchar),
		('LoD1'			, 'lod1'),
		('LoD2'			, 'lod2'),
		('LoD3'			, 'lod3'),
		('LoD4'			, 'lod4')		
		) AS t(lodx_name, lodx_label)
	LOOP

view_name  := concat(citydb_schema,'_',r.class_label,'_',s.lodx_label);
mview_name := concat('_g_',view_name);

sql_statement := concat('
DROP VIEW IF EXISTS    qgis_pkg.',view_name,' CASCADE;
CREATE OR REPLACE VIEW qgis_pkg.',view_name,' AS
SELECT',sql_co_atts,'
  o.class,
  o.class_codespace,
  string_to_array(o.function, ''--/\--'')::varchar[] AS function,
  string_to_array(o.function_codespace, ''--/\--'')::varchar[] AS function_codespace,  
  string_to_array(o.usage, ''--/\--'')::varchar[] AS usage,
  string_to_array(o.usage_codespace, ''--/\--'')::varchar[] AS usage_codespace,
  g.geom::geometry(MultiPolygonZ,',srid_id,')
FROM
	qgis_pkg.',mview_name,' AS g 
	INNER JOIN ',citydb_schema,'.cityobject AS co ON (g.co_id = co.id AND co.objectclass_id = ',r.class_id,')
  	INNER JOIN ',citydb_schema,'.generic_cityobject AS o ON (o.id = co.id AND o.objectclass_id = ',r.class_id,');
COMMENT ON VIEW qgis_pkg.',view_name,' IS ''View of ',r.class_name,' ',s.lodx_name,''';
');
EXECUTE sql_statement;

	END LOOP; -- generic cityobject lod
END LOOP;  -- generic cityobject


---------------------------------------------------------------
-- Create VIEW for CITY_FURNITURE
---------------------------------------------------------------
FOR r IN 
	SELECT * FROM (VALUES
	('CityFurniture'::varchar, 21::integer, 'city_furniture'::varchar)
	) AS t(class_name, class_id, class_label)
LOOP
	FOR s IN 
		SELECT * FROM (VALUES
		('LoD1'::varchar, 'lod1'::varchar),
		('LoD2'			, 'lod2'),
		('LoD3'			, 'lod3'),
		('LoD4'			, 'lod4')		
		) AS t(lodx_name, lodx_label)
	LOOP

view_name  := concat(citydb_schema,'_',r.class_label,'_',s.lodx_label);
mview_name := concat('_g_',view_name);

sql_statement := concat('
DROP VIEW IF EXISTS    qgis_pkg.',view_name,' CASCADE;
CREATE OR REPLACE VIEW qgis_pkg.',view_name,' AS
SELECT',sql_co_atts,'
  o.class,
  o.class_codespace,
  string_to_array(o.function, ''--/\--'')::varchar[] AS function,
  string_to_array(o.function_codespace, ''--/\--'')::varchar[] AS function_codespace,  
  string_to_array(o.usage, ''--/\--'')::varchar[] AS usage,
  string_to_array(o.usage_codespace, ''--/\--'')::varchar[] AS usage_codespace,
  g.geom::geometry(MultiPolygonZ,',srid_id,')
FROM
	qgis_pkg.',mview_name,' AS g 
	INNER JOIN ',citydb_schema,'.cityobject AS co ON (g.co_id = co.id AND co.objectclass_id = ',r.class_id,')
  	INNER JOIN ',citydb_schema,'.city_furniture AS o ON (o.id = co.id AND o.objectclass_id = ',r.class_id,');
COMMENT ON VIEW qgis_pkg.',view_name,' IS ''View of ',r.class_name,' ',s.lodx_name,''';
');
EXECUTE sql_statement;

	END LOOP; -- city furniture lod
END LOOP;  -- city furniture



---------------------------------------------------------------
-- Create VIEW for RELIEF_FEATURE
---------------------------------------------------------------
FOR r IN 
	SELECT * FROM (VALUES
	('ReliefFeature'::varchar, 14::integer, 'relief_feature'::varchar)
	) AS t(class_name, class_id, class_label)
LOOP
	FOR s IN 
		SELECT * FROM (VALUES
		('LoD0'::varchar, 'lod0'::varchar, 0::integer),
		('LoD1'			, 'lod1'		 , 1),
		('LoD2'			, 'lod2'		 , 2),
		('LoD3'			, 'lod3'		 , 3),
		('LoD4'			, 'lod4'		 , 4)			
		) AS t(lodx_name, lodx_label, lodx_integer)
	LOOP

view_name  := concat(citydb_schema,'_',r.class_label,'_',s.lodx_label);
mview_name := concat('_g_',view_name);

sql_statement := concat('
DROP VIEW IF EXISTS    qgis_pkg.',view_name,' CASCADE;
CREATE OR REPLACE VIEW qgis_pkg.',view_name,' AS
SELECT',sql_co_atts,'
  o.lod,
  g.geom::geometry(MultiPolygonZ,',srid_id,')
FROM
	qgis_pkg.',mview_name,' AS g 
	INNER JOIN ',citydb_schema,'.cityobject AS co ON (g.co_id = co.id AND co.objectclass_id = ',r.class_id,')
  	INNER JOIN ',citydb_schema,'.relief_feature AS o ON (o.id = co.id AND o.objectclass_id = ',r.class_id,');
COMMENT ON VIEW qgis_pkg.',view_name,' IS ''View of ',r.class_name,' ',s.lodx_name,''';
');
EXECUTE sql_statement;

-- ********* BEGIN TRIGGERS
		FOR tr IN 
			SELECT * FROM (VALUES
			('ins'::varchar,	'insert'::varchar,	'INSERT'::varchar),
			('upd',				'update',			'UPDATE'),
			('del',				'delete',			'DELETE')	
			) AS t(tr_short, tr_small, tr_cap)
		LOOP

trigger_f := concat('tr_',tr.tr_short,'_relief_feature()');

sql_statement := concat('
DROP TRIGGER IF EXISTS tr_',tr.tr_short,'_',view_name,' ON qgis_pkg.',view_name,';
CREATE TRIGGER         tr_',tr.tr_short,'_',view_name,'
	INSTEAD OF ',tr.tr_cap,' ON qgis_pkg.',view_name,'
	FOR EACH ROW
	EXECUTE PROCEDURE qgis_pkg.',trigger_f,';
COMMENT ON TRIGGER tr_',tr.tr_short,'_',view_name,' ON qgis_pkg.',view_name,' IS ''Fired upon ',tr.tr_small,' into view qgis_pkg.',view_name,''';
');
EXECUTE sql_statement;
		END LOOP; -- end loop trigger operation list
-- ********* END TRIGGERS

	END LOOP; -- relief feature lod
END LOOP; -- relief feature

---------------------------------------------------------------
-- Create VIEW for TIN_RELIEF
---------------------------------------------------------------
FOR r IN 
	SELECT * FROM (VALUES
	('TINRelief'::varchar, 16::integer, 'tin_relief'::varchar)
	) AS t(class_name, class_id, class_label)
LOOP
	FOR s IN 
		SELECT * FROM (VALUES
		('LoD0'::varchar, 'lod0'::varchar, 0::integer),
		('LoD1'			, 'lod1'		 , 1),
		('LoD2'			, 'lod2'		 , 2),
		('LoD3'			, 'lod3'		 , 3),
		('LoD4'			, 'lod4'		 , 4)			
		) AS t(lodx_name, lodx_label, lodx_integer)
	LOOP

view_name  := concat(citydb_schema,'_',r.class_label,'_',s.lodx_label);
mview_name := concat('_g_',view_name);

sql_statement := concat('
DROP VIEW IF EXISTS    qgis_pkg.',view_name,' CASCADE;
CREATE OR REPLACE VIEW qgis_pkg.',view_name,' AS
SELECT',sql_co_atts,'
  o.lod,
  o2.max_length,
  02.max_length_unit,
  g.geom::geometry(MultiPolygonZ,',srid_id,')
FROM
	qgis_pkg.',mview_name,' AS g 
	INNER JOIN ',citydb_schema,'.cityobject AS co ON (g.co_id = co.id AND co.objectclass_id = ',r.class_id,')
	INNER JOIN ',citydb_schema,'.relief_component AS o ON (o.id = co.id AND o.objectclass_id = ',r.class_id,')	
  	INNER JOIN ',citydb_schema,'.tin_relief AS o2 ON (o2.id = co.id AND o2.objectclass_id = ',r.class_id,');
COMMENT ON VIEW qgis_pkg.',view_name,' IS ''View of ',r.class_name,' ',s.lodx_name,''';
');
EXECUTE sql_statement;

-- ********* BEGIN TRIGGERS
		FOR tr IN 
			SELECT * FROM (VALUES
			('ins'::varchar,	'insert'::varchar,	'INSERT'::varchar),
			('upd',				'update',			'UPDATE'),
			('del',				'delete',			'DELETE')	
			) AS t(tr_short, tr_small, tr_cap)
		LOOP

trigger_f := concat('tr_',tr.tr_short,'_tin_relief()');

sql_statement := concat('
DROP TRIGGER IF EXISTS tr_',tr.tr_short,'_',view_name,' ON qgis_pkg.',view_name,';
CREATE TRIGGER         tr_',tr.tr_short,'_',view_name,'
	INSTEAD OF ',tr.tr_cap,' ON qgis_pkg.',view_name,'
	FOR EACH ROW
	EXECUTE PROCEDURE qgis_pkg.',trigger_f,';
COMMENT ON TRIGGER tr_',tr.tr_short,'_',view_name,' ON qgis_pkg.',view_name,' IS ''Fired upon ',tr.tr_small,' into view qgis_pkg.',view_name,''';
');
EXECUTE sql_statement;
		END LOOP; -- end loop trigger operation list
-- ********* END TRIGGERS

	END LOOP; -- tin relief lod
END LOOP;  -- tin relief



-- ***********************
-- WATERBODY MODULE
-- ***********************

---------------------------------------------------------------
-- Create VIEW FOR WATERBODY
---------------------------------------------------------------

FOR r IN 
	SELECT * FROM (VALUES
	('WaterBody'::varchar, 9::integer, 'waterbody'::varchar)
	) AS t(class_name, class_id, class_label)
LOOP

	FOR s IN 
		SELECT * FROM (VALUES
		('LoD0'::varchar, 'lod0'::varchar),
		('LoD1'			, 'lod1'),		
		('LoD2'			, 'lod2'),
		('LoD3'			, 'lod3'),	
		('LoD4'			, 'lod4')		
		) AS t(lodx_name, lodx_label)
	LOOP

view_name  := concat(citydb_schema,'_',r.class_label,'_',s.lodx_label);
mview_name := concat('_g_',view_name);

sql_statement := concat('
DROP VIEW IF EXISTS    qgis_pkg.',view_name,' CASCADE;
CREATE OR REPLACE VIEW qgis_pkg.',view_name,' AS
SELECT',sql_co_atts,'
  o.class,
  o.class_codespace,
  string_to_array(o.function, ''--/\--'')::varchar[] AS function,
  string_to_array(o.function_codespace, ''--/\--'')::varchar[] AS function_codespace,  
  string_to_array(o.usage, ''--/\--'')::varchar[] AS usage,
  string_to_array(o.usage_codespace, ''--/\--'')::varchar[] AS usage_codespace,
  g.geom::geometry(MultiPolygonZ,',srid_id,')
FROM
	qgis_pkg.',mview_name,' AS g 
	INNER JOIN ',citydb_schema,'.cityobject AS co ON (g.co_id = co.id AND co.objectclass_id = ',r.class_id,')
	INNER JOIN ',citydb_schema,'.waterbody AS o ON (o.id = co.id AND o.objectclass_id = ',r.class_id,');	
COMMENT ON VIEW qgis_pkg.',view_name,' IS ''View of ',r.class_name,' ',s.lodx_name,''';
');
EXECUTE sql_statement;

	END LOOP; -- waterbody lod

	FOR s IN 
		SELECT * FROM (VALUES
		('LoD2'::varchar, 'lod2'::varchar),
		('LoD3'			, 'lod3'),	
		('LoD4'			, 'lod4')		
		) AS t(lodx_name, lodx_label)
	LOOP

		FOR u IN 
			SELECT * FROM (VALUES
			('WaterSurface'::varchar,	11::integer,'watersurf'::varchar),
			('WaterGroundSurface',		12,			'watergroundsurf'),
			('WaterClosureSurface',		13,			'waterclosuresurf')
			) AS t(themsurf_name, class_id, themsurf_label)
		LOOP

view_name  := concat(citydb_schema,'_',r.class_label,'_',s.lodx_label,'_',u.themsurf_label);
mview_name := concat('_g_',view_name);

sql_statement := concat('
DROP VIEW IF EXISTS    qgis_pkg.',view_name,' CASCADE;
CREATE OR REPLACE VIEW qgis_pkg.',view_name,' AS
SELECT',sql_co_atts,
CASE WHEN u.themsurf_name = 'WaterSurface' THEN '
  water_level,
  water_level_codespace,'
ELSE 
	NULL
END,'
  wtw.waterbody_id,
  g.geom::geometry(MultiPolygonZ,',srid_id,')
FROM
	qgis_pkg.',mview_name,' AS g 
	INNER JOIN ',citydb_schema,'.cityobject AS co ON (g.co_id = co.id AND co.objectclass_id = ',u.class_id,')
  	INNER JOIN ',citydb_schema,'.waterboundary_surface AS o ON (o.id = co.id AND o.objectclass_id = ',u.class_id,')
	INNER JOIN ',citydb_schema,'.waterbod_to_waterbnd_srf AS wtw ON (wtw.waterboundary_surface_id = co.id);
COMMENT ON VIEW qgis_pkg.',view_name,' IS ''View of ',r.class_name,' ',s.lodx_label,' ',u.themsurf_name,''';
');
EXECUTE sql_statement;

		END LOOP; -- waterbody thematic surface
	END LOOP; -- waterbody thematic surface lod
END LOOP; -- waterbody

-- **************************
RETURN 1;
EXCEPTION
	WHEN QUERY_CANCELED THEN
		RAISE EXCEPTION 'qgis_pkg.create_updatable_views(): Error QUERY_CANCELED';
	WHEN OTHERS THEN
		RAISE EXCEPTION 'qgis_pkg.create_updatable_views(): %', SQLERRM;
END;
$$ LANGUAGE plpgsql;
COMMENT ON FUNCTION qgis_pkg.create_updatable_views(varchar, geometry) IS 'Installs the updatable views for the selected citydb schema';

-- Installs the views for the citydb default schema.
PERFORM qgis_pkg.create_updatable_views();

--**************************
RAISE NOTICE E'\n\nDone\n\n';
END $MAINBODY$;
--**************************

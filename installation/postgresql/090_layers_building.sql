-- ***********************************************************************
--
--      QGIS Package for the CityGML 3D City Database (for PostgreSQL)
--
--
--                        Copyright 2022
--
-- Delft University of Technology, The Netherlands
-- 3D Geoinformation Group
-- https://3d.bk.tudelft.nl/
-- 
-- Licensed under the Apache License, Version 2.0 (the "License");
-- you may not use this file except in compliance with the License.
-- You may obtain a copy of the License at
-- 
--     http://www.apache.org/licenses/LICENSE-2.0
--     
-- Unless required by applicable law or agreed to in writing, software
-- distributed under the License is distributed on an "AS IS" BASIS,
-- WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
-- See the License for the specific language governing permissions and
-- limitations under the License.
--
-- Author: Giorgio Agugiaro
-- Delft University of Technology, The Netherlands
-- 3D Geoinformation Group
-- https://3d.bk.tudelft.nl/gagugiaro/
--
-- ***********************************************************************
--
-- This script installs a function that generates the SQL script to
-- create all layers of CityGML module "Building". 
--
-- ***********************************************************************

----------------------------------------------------------------
-- Create FUNCTION QGIS_PKG.GENERATE_SQL_LAYERS_BUILDING
----------------------------------------------------------------
DROP FUNCTION IF EXISTS    qgis_pkg.generate_sql_layers_building(varchar, varchar, integer, integer, numeric, geometry, boolean) CASCADE;
CREATE OR REPLACE FUNCTION qgis_pkg.generate_sql_layers_building(
usr_name            varchar,
cdb_schema 			varchar,
perform_snapping 	integer,
digits 				integer,
area_poly_min 		numeric,
mview_bbox			geometry,
force_layer_creation boolean 
) 
RETURNS text AS $$
DECLARE
feature_type CONSTANT varchar := 'Building';
usr_schema      	varchar := (SELECT qgis_pkg.create_qgis_usr_schema_name(usr_name));
usr_names_array     varchar[] := (SELECT array_agg(s.usr_name) FROM qgis_pkg.list_qgis_pkg_usrgroup_members() AS s);
usr_schemas_array 	varchar[] := (SELECT array_agg(s.usr_schema) FROM qgis_pkg.list_usr_schemas() AS s);
cdb_schemas_array 	varchar[] := (SELECT array_agg(s.cdb_schema) FROM qgis_pkg.list_cdb_schemas() AS s); 
srid_id         	integer;
qi_cdb_schema varchar; ql_cdb_schema varchar;
qi_usr_schema varchar; ql_usr_schema varchar;
qi_usr_name varchar; ql_usr_name varchar;
num_features    	bigint;
l_name 			varchar;
view_name varchar; ql_view_name varchar; qi_view_name varchar;
mview_name varchar; qi_mview_name varchar; ql_mview_name varchar;
qml_file_name 	varchar;
trig_f_suffix   varchar;
r RECORD; s RECORD; t RECORD; u RECORD;
sql_mview_count text := NULL;
sql_where 		text := NULL;
sql_upd			text := NULL;
sql_ins			text := NULL;
sql_trig		text := NULL;
sql_layer	 	text := NULL;
sql_statement	text := NULL;
sql_co_atts varchar := '
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
sql_cfu_atts varchar := '
  o.class,
  o.class_codespace,
  string_to_array(o.function, ''--/\--'')::varchar[] AS function,
  string_to_array(o.function_codespace, ''--/\--'')::varchar[] AS function_codespace,  
  string_to_array(o.usage, ''--/\--'')::varchar[] AS usage,
  string_to_array(o.usage_codespace, ''--/\--'')::varchar[] AS usage_codespace,';

BEGIN

-- Check if the usr_name exists AND is group of the "qgis_pkg_usrgroup";
-- The check to avoid if it is null has been already carried out by 
-- function qgis_pkg.create_qgis_usr_schema_name(usr_name) during DECLARE
IF NOT usr_name = ANY(usr_names_array) THEN
	RAISE EXCEPTION 'usr_name is invalid. It must be an existing database user AND member of role (group) "qgis_pkg_usrgroup"';
END IF;

-- Check if the usr_schema exists (must habe been created before)
-- No need to check if it is NULL.
IF NOT usr_schema = ANY(usr_schemas_array) THEN
	RAISE EXCEPTION 'usr_schema does not exist. Please create it beforehand';
END IF;

-- Check if the cdb_schema exists
IF (cdb_schema IS NULL) OR (NOT cdb_schema = ANY(cdb_schemas_array)) THEN
	RAISE EXCEPTION 'cdb_schema is invalid. It must correspond to an existing citydb schema';
END IF;

-- Add quote identifier and literal for later user.
qi_cdb_schema := quote_ident(cdb_schema);
ql_cdb_schema := quote_literal(cdb_schema);
qi_usr_name   := quote_ident(usr_name);
ql_usr_name   := quote_literal(usr_name);
qi_usr_schema := quote_ident(usr_schema);
ql_usr_schema := quote_literal(usr_schema);

-- Prepare fixed part of SQL statements
sql_upd := concat('
DELETE FROM ',qi_usr_schema,'.layer_metadata AS l WHERE l.cdb_schema = ',ql_cdb_schema,' AND l.feature_type = ''',feature_type,''';
INSERT INTO ',qi_usr_schema,'.layer_metadata 
(n_features, cdb_schema, feature_type, qml_file, lod, root_class, layer_name, creation_date, mv_name, v_name)
VALUES');

-- Get the srid from the cdb_schema
EXECUTE format('SELECT srid FROM %I.database_srs LIMIT 1', cdb_schema) INTO srid_id;

-- Check that the srid is the same if the mview_box
IF ST_SRID(mview_bbox) IS NULL OR ST_SRID(mview_bbox) <> srid_id THEN
	sql_where := NULL;
ELSE
	sql_where := concat('AND ST_MakeEnvelope(', floor(ST_XMin(mview_bbox)),', ', floor(ST_YMin(mview_bbox)),', ', ceil(ST_XMax(mview_bbox)),', ',	ceil(ST_YMax(mview_bbox)),', ',	srid_id,') && co.envelope');
END IF;

RAISE NOTICE 'For module "%" and user "%": creating layers in usr_schema "%" for cdb_schema "%"', feature_type, qi_usr_name, qi_usr_schema, qi_cdb_schema;

sql_layer := NULL; sql_ins := NULL; sql_trig := NULL;

FOR r IN 
	SELECT * FROM (VALUES
	('Building'::varchar, 26::integer, 'bdg'::varchar),
	('BuildingPart'     , 25         , 'bdg_part')	
	) AS t(class_name, class_id, class_label)
LOOP

---------------------------------------------------------------
-- Create LAYER BUILDING(PART)_LOD0
---------------------------------------------------------------
	FOR t IN 
		SELECT * FROM (VALUES
		('LoD0'::varchar, 'lod0'::varchar)		
		) AS t(lodx_name, lodx_label)
	LOOP

-- First check if there are any features at all in the database schema
sql_mview_count := concat('
SELECT 
	count(foo.n_features) AS n_features 
FROM (
	SELECT o.id AS n_features
	FROM 
		',qi_cdb_schema,'.building AS o
		INNER JOIN ',qi_cdb_schema,'.cityobject AS co ON (o.id = co.id AND o.objectclass_id = ',r.class_id,' ',sql_where,')
	WHERE
		o.',t.lodx_label,'_footprint_id IS NOT NULL OR o.',t.lodx_label,'_roofprint_id IS NOT NULL
) AS foo;
');
EXECUTE sql_mview_count INTO num_features;

RAISE NOTICE 'Found % features for % %', num_features, r.class_name, t.lodx_name;

l_name         := concat(r.class_label,'_',t.lodx_label);
view_name      := concat(cdb_schema,'_',l_name);
mview_name     := concat('_g_',view_name);
qi_mview_name  := quote_ident(mview_name); ql_mview_name := quote_literal(mview_name);
qi_view_name   := quote_ident(view_name); ql_view_name := quote_literal(view_name);
qml_file_name  := concat(r.class_label,'_form.qml');
trig_f_suffix := 'building';

IF (num_features > 0) OR (force_layer_creation IS TRUE) THEN

--------------------
-- MATERIALIZED VIEW
--------------------
sql_layer := concat(sql_layer, qgis_pkg.generate_sql_matview_header(qi_usr_schema,qi_mview_name),'
	SELECT
		sg.cityobject_id::bigint AS co_id,
		ST_Collect(qgis_pkg.ST_snap_poly_to_grid(sg.geometry,',perform_snapping,',',digits,',',area_poly_min,'))::geometry(MultiPolygonZ, ',srid_id,') AS geom
	FROM (
		SELECT
			b1.',t.lodx_label,'_footprint_id AS sg_id
		FROM
			',qi_cdb_schema,'.building AS b1
			INNER JOIN ',qi_cdb_schema,'.cityobject AS co ON (co.id = b1.id AND b1.objectclass_id = ',r.class_id,' ',sql_where,')
		UNION
		SELECT
			b2.',t.lodx_label,'_roofprint_id AS sg_id
		FROM
			',qi_cdb_schema,'.building AS b2
			INNER JOIN ',qi_cdb_schema,'.cityobject AS co ON (co.id = b2.id AND b2.objectclass_id = ',r.class_id,' ',sql_where,')
		) AS b
		INNER JOIN ',qi_cdb_schema,'.surface_geometry AS sg ON (sg.root_id = b.sg_id AND sg.geometry IS NOT NULL)
	GROUP BY sg.cityobject_id
WITH NO DATA;
COMMENT ON MATERIALIZED VIEW ',qi_usr_schema,'.',qi_mview_name,' IS ''Mat. view of ',r.class_name,' ',t.lodx_name,' in schema ',qi_cdb_schema,''';
',qgis_pkg.generate_sql_matview_footer(qi_usr_name, qi_usr_schema, qi_mview_name, ql_view_name));

-------
-- VIEW
-------
sql_layer := concat(sql_layer, qgis_pkg.generate_sql_view_header(qi_usr_schema, qi_view_name),'
SELECT',
sql_co_atts,
CASE WHEN r.class_name = 'BuildingPart' THEN '
  o.building_parent_id,
  o.building_root_id,'
ELSE
 NULL
END,
sql_cfu_atts,'
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
	',qi_usr_schema,'.',qi_mview_name,' AS g 
	INNER JOIN ',qi_cdb_schema,'.cityobject AS co ON (g.co_id = co.id AND co.objectclass_id = ',r.class_id,')
  	INNER JOIN ',qi_cdb_schema,'.building AS o ON (o.id = co.id AND o.objectclass_id = ',r.class_id,');
COMMENT ON VIEW ',qi_usr_schema,'.',qi_view_name,' IS ''View of ',r.class_name,' ',t.lodx_name,' in schema ',qi_cdb_schema,''';
ALTER TABLE ',qi_usr_schema,'.',qi_view_name,' OWNER TO ',qi_usr_name,';
');

-- Add triggers to make view updatable
sql_trig := concat(sql_trig,qgis_pkg.generate_sql_triggers(view_name, trig_f_suffix, usr_name, usr_schema));
-- Add entry to update table layer_metadata
sql_ins := concat(sql_ins,'
(',num_features,',',ql_cdb_schema,',''',feature_type,''',''',qml_file_name,''',''',t.lodx_label,''',''',r.class_name,''',''',l_name,''',clock_timestamp(),',ql_mview_name,',',ql_view_name,'),');
ELSE
sql_layer := concat(sql_layer, qgis_pkg.generate_sql_matview_else(qi_usr_schema, qi_mview_name, ql_view_name));
END IF;

---------------------------------------------------------------
-- Create LAYER BUILDING(PART)_LOD0_FOOTPRINT/ROOFEDGE
---------------------------------------------------------------
		FOR u IN 
			SELECT * FROM (VALUES
			('footprint'::varchar, 'footprint'::varchar),
			('roofedge'          , 'roofprint')   
			) AS t(themsurf_name, themsurf_label)
		LOOP

-- First check if there are any features at all in the database schema
sql_mview_count := concat('
SELECT count(o.id) AS n_features
FROM 
	',qi_cdb_schema,'.building AS o
	INNER JOIN ',qi_cdb_schema,'.cityobject AS co ON (o.id = co.id AND o.objectclass_id = ',r.class_id,' ',sql_where,')
WHERE
	o.',t.lodx_label,'_',u.themsurf_label,'_id IS NOT NULL;
');
EXECUTE sql_mview_count INTO num_features;

RAISE NOTICE 'Found % features for % % %', num_features, r.class_name, t.lodx_name, u.themsurf_name;

l_name         := concat(r.class_label,'_',t.lodx_label,'_',u.themsurf_name);
view_name      := concat(cdb_schema,'_',l_name);
mview_name     := concat('_g_',view_name);
qi_mview_name  := quote_ident(mview_name); ql_mview_name := quote_literal(mview_name);
qi_view_name   := quote_ident(view_name); ql_view_name := quote_literal(view_name);
qml_file_name  := concat(r.class_label,'_form.qml');
trig_f_suffix := 'building';

IF (num_features > 0) OR (force_layer_creation IS TRUE) THEN

--------------------
-- MATERIALIZED VIEW
--------------------
sql_layer := concat(sql_layer, qgis_pkg.generate_sql_matview_header(qi_usr_schema,qi_mview_name),'
	SELECT
		sg.cityobject_id::bigint AS co_id,
		ST_Collect(qgis_pkg.ST_snap_poly_to_grid(sg.geometry,',perform_snapping,',',digits,',',area_poly_min,'))::geometry(MultiPolygonZ, ',srid_id,') AS geom
	FROM
		',qi_cdb_schema,'.building AS o
		INNER JOIN ',qi_cdb_schema,'.cityobject AS co ON (o.id = co.id AND o.objectclass_id = ',r.class_id,' ',sql_where,') 
		INNER JOIN ',qi_cdb_schema,'.surface_geometry AS sg ON (sg.root_id = o.',t.lodx_label,'_',u.themsurf_label,'_id AND sg.geometry IS NOT NULL)
	GROUP BY sg.cityobject_id
WITH NO DATA;
COMMENT ON MATERIALIZED VIEW ',qi_usr_schema,'.',qi_mview_name,' IS ''Mat. view of (',r.class_name,') ',t.lodx_name,' ',u.themsurf_name,' in schema ',qi_cdb_schema,''';
',qgis_pkg.generate_sql_matview_footer(qi_usr_name, qi_usr_schema, qi_mview_name, ql_view_name));

-------
-- VIEW
-------
sql_layer := concat(sql_layer, qgis_pkg.generate_sql_view_header(qi_usr_schema, qi_view_name),'
SELECT',
sql_co_atts,
CASE WHEN r.class_name = 'BuildingPart' THEN '
  o.building_parent_id,
  o.building_root_id,'
ELSE
 NULL
END,
sql_cfu_atts,' 
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
	',qi_usr_schema,'.',qi_mview_name,' AS g 
	INNER JOIN ',qi_cdb_schema,'.cityobject AS co ON (g.co_id = co.id AND co.objectclass_id = ',r.class_id,')
  	INNER JOIN ',qi_cdb_schema,'.building AS o ON (o.id = co.id AND o.objectclass_id = ',r.class_id,');
COMMENT ON VIEW ',qi_usr_schema,'.',qi_view_name,' IS ''View of ',r.class_name,' ',t.lodx_name,' ',u.themsurf_name,' in schema ',qi_cdb_schema,''';
ALTER TABLE ',qi_usr_schema,'.',qi_view_name,' OWNER TO ',qi_usr_name,';
');

-- Add triggers to make view updatable
sql_trig := concat(sql_trig,qgis_pkg.generate_sql_triggers(view_name, trig_f_suffix, usr_name, usr_schema));
-- Add entry to update table layer_metadata
sql_ins := concat(sql_ins,'
(',num_features,',',ql_cdb_schema,',''',feature_type,''',''',qml_file_name,''',''',t.lodx_label,''',''',r.class_name,''',''',l_name,''',clock_timestamp(),',ql_mview_name,',',ql_view_name,'),');
ELSE
sql_layer := concat(sql_layer, qgis_pkg.generate_sql_matview_else(qi_usr_schema, qi_mview_name, ql_view_name));
END IF;

			END LOOP; -- building lod0 footprint/roofprint
	END LOOP; -- building lod0

---------------------------------------------------------------
-- Create LAYER BUILDING(PART)_LOD1
---------------------------------------------------------------
	FOR t IN 
		SELECT * FROM (VALUES
		('LoD1'::varchar, 'lod1'::varchar)		
		) AS t(lodx_name, lodx_label)
	LOOP
	
-- First check if there are any features at all in the database schema
sql_mview_count := concat('
SELECT count(o.id) AS n_features
FROM 
	',qi_cdb_schema,'.building AS o
	INNER JOIN ',qi_cdb_schema,'.cityobject AS co ON (o.id = co.id AND o.objectclass_id = ',r.class_id,' ',sql_where,')
WHERE
	o.',t.lodx_label,'_multi_surface_id IS NOT NULL OR o.',t.lodx_label,'_solid_id IS NOT NULL
');
EXECUTE sql_mview_count INTO num_features;

RAISE NOTICE 'Found % features for % %', num_features, r.class_name, t.lodx_name;

l_name         := concat(r.class_label,'_',t.lodx_label);
view_name      := concat(cdb_schema,'_',l_name);
mview_name     := concat('_g_',view_name);
qi_mview_name  := quote_ident(mview_name); ql_mview_name := quote_literal(mview_name);
qi_view_name   := quote_ident(view_name); ql_view_name := quote_literal(view_name);
qml_file_name  := concat(r.class_label,'_form.qml');
trig_f_suffix := 'building';

IF (num_features > 0) OR (force_layer_creation IS TRUE) THEN

--------------------
-- MATERIALIZED VIEW
--------------------
sql_layer := concat(sql_layer, qgis_pkg.generate_sql_matview_header(qi_usr_schema,qi_mview_name),'
	SELECT
		sg.cityobject_id::bigint AS co_id,
		ST_Collect(qgis_pkg.ST_snap_poly_to_grid(sg.geometry,',perform_snapping,',',digits,',',area_poly_min,'))::geometry(MultiPolygonZ, ',srid_id,') AS geom
	FROM (
		SELECT
			o.id AS co_id, 	
			CASE
				WHEN o.',t.lodx_label,'_solid_id IS NOT NULL THEN o.lod1_solid_id
				ELSE o.',t.lodx_label,'_multi_surface_id
			END	AS sg_id 
		FROM 
			',qi_cdb_schema,'.building AS o
			INNER JOIN ',qi_cdb_schema,'.cityobject AS co ON (o.id=co.id AND o.objectclass_id = ',r.class_id,' ',sql_where,') 
		WHERE			
			o.',t.lodx_label,'_solid_id IS NOT NULL OR o.',t.lodx_label,'_multi_surface_id IS NOT NULL
		) AS foo
		INNER JOIN ',qi_cdb_schema,'.surface_geometry AS sg ON (sg.root_id = foo.sg_id AND sg.geometry IS NOT NULL)
	GROUP BY sg.cityobject_id
WITH NO DATA;
COMMENT ON MATERIALIZED VIEW ',qi_usr_schema,'.',qi_mview_name,' IS ''Mat. view of ',r.class_name,' ',t.lodx_name,' in schema ',qi_cdb_schema,''';
',qgis_pkg.generate_sql_matview_footer(qi_usr_name, qi_usr_schema, qi_mview_name, ql_view_name));

-------
-- VIEW
-------
sql_layer := concat(sql_layer, qgis_pkg.generate_sql_view_header(qi_usr_schema, qi_view_name),'
SELECT',
sql_co_atts,
CASE WHEN r.class_name = 'BuildingPart' THEN '
  o.building_parent_id,
  o.building_root_id,'
ELSE
 NULL
END,
sql_cfu_atts,' 
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
	',qi_usr_schema,'.',qi_mview_name,' AS g 
	INNER JOIN ',qi_cdb_schema,'.cityobject AS co ON (g.co_id = co.id AND co.objectclass_id = ',r.class_id,')
  	INNER JOIN ',qi_cdb_schema,'.building AS o ON (o.id = co.id AND o.objectclass_id = ',r.class_id,');
COMMENT ON VIEW ',qi_usr_schema,'.',qi_view_name,' IS ''View of (',r.class_name,') ',t.lodx_name,' in schema ',qi_cdb_schema,''';
ALTER TABLE ',qi_usr_schema,'.',qi_view_name,' OWNER TO ',qi_usr_name,';
');

-- Add triggers to make view updatable
sql_trig := concat(sql_trig,qgis_pkg.generate_sql_triggers(view_name, trig_f_suffix, usr_name, usr_schema));
-- Add entry to update table layer_metadata
sql_ins := concat(sql_ins,'
(',num_features,',',ql_cdb_schema,',''',feature_type,''',''',qml_file_name,''',''',t.lodx_label,''',''',r.class_name,''',''',l_name,''',clock_timestamp(),',ql_mview_name,',',ql_view_name,'),');
ELSE
sql_layer := concat(sql_layer, qgis_pkg.generate_sql_matview_else(qi_usr_schema, qi_mview_name, ql_view_name));
END IF;

	END LOOP; -- building lod1

---------------------------------------------------------------
-- Create LAYER BUILDING(PART)_LOD2-4
---------------------------------------------------------------
	FOR t IN 
		SELECT * FROM (VALUES
		('LoD2'::varchar, 'lod2'::varchar),
		('LoD3'			, 'lod3'),
		('LoD4'			, 'lod4')		
		) AS t(lodx_name, lodx_label)
	LOOP

-- First check if there are any features at all in the database schema
sql_mview_count := concat('
SELECT 
	count(foo.n_features) AS n_features 
FROM (
	SELECT o.id AS n_features
	FROM 
		',qi_cdb_schema,'.building AS o
		INNER JOIN ',qi_cdb_schema,'.cityobject AS co ON (o.id = co.id AND o.objectclass_id = ',r.class_id,' ',sql_where,')
	WHERE
		o.',t.lodx_label,'_multi_surface_id IS NOT NULL OR o.',t.lodx_label,'_solid_id IS NOT NULL
	UNION
	SELECT DISTINCT o.building_id AS n_features
	FROM 
		',qi_cdb_schema,'.thematic_surface AS o
		INNER JOIN ',qi_cdb_schema,'.cityobject AS co ON (o.id = co.id ',sql_where,')
		INNER JOIN ',qi_cdb_schema,'.building AS b ON (o.building_id = b.id AND b.objectclass_id = ',r.class_id,')
	WHERE
		o.',t.lodx_label,'_multi_surface_id IS NOT NULL
) AS foo;
');
EXECUTE sql_mview_count INTO num_features;

RAISE NOTICE 'Found % features for % %', num_features, r.class_name, t.lodx_name;

l_name         := concat(r.class_label,'_',t.lodx_label);
view_name      := concat(cdb_schema,'_',l_name);
mview_name     := concat('_g_',view_name);
qi_mview_name  := quote_ident(mview_name); ql_mview_name := quote_literal(mview_name);
qi_view_name   := quote_ident(view_name); ql_view_name := quote_literal(view_name);
qml_file_name  := concat(r.class_label,'_form.qml');
trig_f_suffix := 'building';

IF (num_features > 0) OR (force_layer_creation IS TRUE) THEN

--------------------
-- MATERIALIZED VIEW
--------------------
sql_layer := concat(sql_layer, qgis_pkg.generate_sql_matview_header(qi_usr_schema,qi_mview_name),'
	SELECT
		foo2.co_id::bigint AS co_id,
		ST_Collect(qgis_pkg.ST_snap_poly_to_grid(sg.geometry,',perform_snapping,',',digits,',',area_poly_min,'))::geometry(MultiPolygonZ, ',srid_id,') AS geom
	FROM (
		SELECT
			foo.co_id,
			unnest(foo.sg_id_array) AS sg_id
		FROM (
			SELECT
				coalesce(o.id, ts_t.co_id) as co_id,
				CASE 
					WHEN ts_t.sg_id_array IS NOT NULL THEN ts_t.sg_id_array
					WHEN o.',t.lodx_label,'_solid_id IS NOT NULL THEN ARRAY[o.',t.lodx_label,'_solid_id]
					ELSE ARRAY[o.',t.lodx_label,'_multi_surface_id]
				END AS sg_id_array 
			FROM 
				',qi_cdb_schema,'.building AS o
				INNER JOIN ',qi_cdb_schema,'.cityobject AS co ON (o.id = co.id AND o.objectclass_id= ',r.class_id,' ',sql_where,')
				FULL OUTER JOIN (
					SELECT ts.building_id AS co_id, array_agg(ts.',t.lodx_label,'_multi_surface_id) AS sg_id_array 
					FROM 
						',qi_cdb_schema,'.thematic_surface AS ts
						INNER JOIN ',qi_cdb_schema,'.cityobject AS co ON (co.id = ts.id ',sql_where,')
						INNER JOIN ',qi_cdb_schema,'.building AS b1 ON (ts.building_id = b1.id AND b1.objectclass_id = ',r.class_id,')	
					GROUP BY ts.building_id
					) AS ts_t ON (ts_t.co_id = o.id)
			) AS foo
		) AS foo2
		INNER JOIN ',qi_cdb_schema,'.surface_geometry AS sg ON (sg.root_id = foo2.sg_id AND sg.geometry IS NOT NULL)
	GROUP BY foo2.co_id
WITH NO DATA;
COMMENT ON MATERIALIZED VIEW ',qi_usr_schema,'.',qi_mview_name,' IS ''Mat. view of ',r.class_name,' ',t.lodx_name,' in schema ',qi_cdb_schema,''';
',qgis_pkg.generate_sql_matview_footer(qi_usr_name, qi_usr_schema, qi_mview_name, ql_view_name));

-------
-- VIEW
-------
sql_layer := concat(sql_layer, qgis_pkg.generate_sql_view_header(qi_usr_schema, qi_view_name),'
SELECT',
sql_co_atts,
CASE WHEN r.class_name = 'BuildingPart' THEN '
  o.building_parent_id,
  o.building_root_id,'
ELSE
 NULL
END,
sql_cfu_atts,' 
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
	',qi_usr_schema,'.',qi_mview_name,' AS g 
	INNER JOIN ',qi_cdb_schema,'.cityobject AS co ON (g.co_id = co.id AND co.objectclass_id = ',r.class_id,')
  	INNER JOIN ',qi_cdb_schema,'.building AS o ON (o.id = co.id AND o.objectclass_id = ',r.class_id,');
COMMENT ON VIEW ',qi_usr_schema,'.',qi_view_name,' IS ''View of ',r.class_name,' ',t.lodx_name,' in schema ',qi_cdb_schema,''';
ALTER TABLE ',qi_usr_schema,'.',qi_view_name,' OWNER TO ',qi_usr_name,';
');

-- Add triggers to make view updatable
sql_trig := concat(sql_trig,qgis_pkg.generate_sql_triggers(view_name, trig_f_suffix, usr_name, usr_schema));
-- Add entry to update table layer_metadata
sql_ins := concat(sql_ins,'
(',num_features,',',ql_cdb_schema,',''',feature_type,''',''',qml_file_name,''',''',t.lodx_label,''',''',r.class_name,''',''',l_name,''',clock_timestamp(),',ql_mview_name,',',ql_view_name,'),');
ELSE
sql_layer := concat(sql_layer, qgis_pkg.generate_sql_matview_else(qi_usr_schema, qi_mview_name, ql_view_name));
END IF;

---------------------------------------------------------------
-- Create LAYER BUILDING(PART)_LOD2-4_THEMATIC SURFACES
---------------------------------------------------------------
		FOR u IN 
			SELECT * FROM (VALUES
			('BuildingRoofSurface'::varchar , 33::integer, 'roofsurf'::varchar),
			('BuildingWallSurface'			, 34		 , 'wallsurf'),
			('BuildingGroundSurface'		, 35		 , 'groundsurf'),
			('BuildingClosureSurface'		, 36		 , 'closuresurf'),
			('OuterBuildingCeilingSurface'	, 60		 , 'outerceilingsurf'),
			('OuterBuildingFloorSurface'	, 61		 , 'outerfloorsurf')
			) AS t(class_name, class_id, class_label)
		LOOP

-- First check if there are any features at all in the database schema
sql_mview_count := concat('
SELECT count(o.id) AS n_features
FROM 
	',qi_cdb_schema,'.thematic_surface AS o
	INNER JOIN ',qi_cdb_schema,'.cityobject AS co ON (o.id = co.id AND o.objectclass_id = ',u.class_id,' ',sql_where,')
	INNER JOIN ',qi_cdb_schema,'.building AS b ON (o.building_id = b.id AND b.objectclass_id = ',r.class_id,')
WHERE
	o.',t.lodx_label,'_multi_surface_id IS NOT NULL;
');
EXECUTE sql_mview_count INTO num_features;

RAISE NOTICE 'Found % features for % % %', num_features, r.class_name, t.lodx_name, u.class_name;

l_name         := concat(r.class_label,'_',t.lodx_label,'_',u.class_label);
view_name      := concat(cdb_schema,'_',l_name);
mview_name     := concat('_g_',view_name);
qi_mview_name  := quote_ident(mview_name); ql_mview_name := quote_literal(mview_name);
qi_view_name   := quote_ident(view_name); ql_view_name := quote_literal(view_name);
qml_file_name  := concat(r.class_label,'_thematic_surface_form.qml');
trig_f_suffix := 'thematic_surface';

IF (num_features > 0) OR (force_layer_creation IS TRUE) THEN

--------------------
-- MATERIALIZED VIEW
--------------------
sql_layer := concat(sql_layer, qgis_pkg.generate_sql_matview_header(qi_usr_schema,qi_mview_name),'
	SELECT
		sg.cityobject_id::bigint AS co_id,
		ST_Collect(qgis_pkg.ST_snap_poly_to_grid(sg.geometry,',perform_snapping,',',digits,',',area_poly_min,'))::geometry(MultiPolygonZ, ',srid_id,') AS geom
	FROM
		',qi_cdb_schema,'.thematic_surface AS o
		INNER JOIN ',qi_cdb_schema,'.cityobject AS co ON (o.id = co.id AND o.objectclass_id = ',u.class_id,' ',sql_where,')		
		INNER JOIN ',qi_cdb_schema,'.building AS b ON (o.building_id = b.id AND b.objectclass_id = ',r.class_id,')
		INNER JOIN ',qi_cdb_schema,'.surface_geometry AS sg ON (sg.root_id = o.',t.lodx_name,'_multi_surface_id AND sg.geometry IS NOT NULL)
	GROUP BY sg.cityobject_id
WITH NO DATA;
COMMENT ON MATERIALIZED VIEW ',qi_usr_schema,'.',qi_mview_name,' IS ''Mat. view of (',r.class_name,') ',t.lodx_name,' ',u.class_name,' in schema ',qi_cdb_schema,''';
',qgis_pkg.generate_sql_matview_footer(qi_usr_name, qi_usr_schema, qi_mview_name, ql_view_name));

-------
-- VIEW
-------
sql_layer := concat(sql_layer, qgis_pkg.generate_sql_view_header(qi_usr_schema, qi_view_name),'
SELECT',
sql_co_atts,'
  o.building_id,
  g.geom::geometry(MultiPolygonZ,',srid_id,')
FROM
	',qi_usr_schema,'.',qi_mview_name,' AS g 
	INNER JOIN ',qi_cdb_schema,'.cityobject AS co ON (g.co_id = co.id AND co.objectclass_id = ',u.class_id,')
  	INNER JOIN ',qi_cdb_schema,'.thematic_surface AS o ON (o.id = co.id AND o.objectclass_id = ',u.class_id,');
COMMENT ON VIEW ',qi_usr_schema,'.',qi_view_name,' IS ''View of (',r.class_name,') ',t.lodx_name,' ',u.class_name,' in schema ',qi_cdb_schema,''';
ALTER TABLE ',qi_usr_schema,'.',qi_view_name,' OWNER TO ',qi_usr_name,';
');

-- Add triggers to make view updatable
sql_trig := concat(sql_trig,qgis_pkg.generate_sql_triggers(view_name, trig_f_suffix, usr_name, usr_schema));
-- Add entry to update table layer_metadata
sql_ins := concat(sql_ins,'
(',num_features,',',ql_cdb_schema,',''',feature_type,''',''',qml_file_name,''',''',t.lodx_label,''',''',r.class_name,''',''',l_name,''',clock_timestamp(),',ql_mview_name,',',ql_view_name,'),');
ELSE
sql_layer := concat(sql_layer, qgis_pkg.generate_sql_matview_else(qi_usr_schema, qi_mview_name, ql_view_name));
END IF;

		END LOOP; -- building lod2-4 thematic surfaces
	END LOOP; -- building lod2-4

---------------------------------------------------------------
-- Create LAYER BUILDING(PART)_LOD2-4_BUILDING INSTALLATION
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

sql_mview_count := concat('
SELECT 
	count(foo.n_features) AS n_features 
FROM (
	SELECT 
		o.id AS n_features
	FROM 
		',qi_cdb_schema,'.building_installation AS o
		INNER JOIN ',qi_cdb_schema,'.cityobject AS co ON (o.id = co.id AND o.objectclass_id = ',s.class_id,' ',sql_where,')
		INNER JOIN ',qi_cdb_schema,'.building AS b ON (b.id = o.building_id AND b.objectclass_id = ',r.class_id,')
	WHERE
		o.',t.lodx_label,'_brep_id IS NOT NULL OR o.',t.lodx_label,'_implicit_rep_id IS NOT NULL
	UNION
	SELECT DISTINCT 
		o.building_installation_id AS n_features
	FROM 
		',qi_cdb_schema,'.thematic_surface AS o
		INNER JOIN ',qi_cdb_schema,'.cityobject AS co ON (o.id = co.id ',sql_where,')
		INNER JOIN ',qi_cdb_schema,'.building_installation AS bi ON (bi.id = o.building_installation_id AND bi.objectclass_id = ',s.class_id,')		
		INNER JOIN ',qi_cdb_schema,'.building AS b ON (b.id = bi.building_id AND b.objectclass_id = ',r.class_id,')
	WHERE
		o.',t.lodx_label,'_multi_surface_id IS NOT NULL
) AS foo;
');
EXECUTE sql_mview_count INTO num_features;

RAISE NOTICE 'Found % features for (%) % %', num_features, r.class_name, s.class_name, t.lodx_name;

l_name         := concat(r.class_label,'_',s.class_label,'_',t.lodx_label);
view_name      := concat(cdb_schema,'_',l_name);
mview_name     := concat('_g_',view_name);
qi_mview_name  := quote_ident(mview_name); ql_mview_name := quote_literal(mview_name);
qi_view_name   := quote_ident(view_name); ql_view_name := quote_literal(view_name);
qml_file_name  := concat('bdg_out_installation_form.qml');
trig_f_suffix := 'building_installation';

IF (num_features > 0) OR (force_layer_creation IS TRUE) THEN

--------------------
-- MATERIALIZED VIEW
--------------------
sql_layer := concat(sql_layer, qgis_pkg.generate_sql_matview_header(qi_usr_schema,qi_mview_name),'
	SELECT 
		foo2.co_id AS co_id,
		st_collect(qgis_pkg.ST_snap_poly_to_grid(sg.geometry,',perform_snapping,',',digits,',',area_poly_min,'))::geometry(MultiPolygonZ, ',srid_id,') AS geom
	FROM ( 
			SELECT 
				foo.co_id,
				unnest(foo.sg_id_array) AS sg_id
			FROM ( 
					SELECT
						coalesce(o.id, ts_t.co_id) as co_id,
						CASE
							WHEN ts_t.sg_id_array IS NOT NULL THEN ts_t.sg_id_array
							ELSE ARRAY[o.',t.lodx_label,'_brep_id]
						END AS sg_id_array
					FROM 
						',qi_cdb_schema,'.building_installation AS o
						INNER JOIN ',qi_cdb_schema,'.cityobject AS co ON (o.id = co.id AND o.objectclass_id = ',s.class_id,' ',sql_where,')
						INNER JOIN ',qi_cdb_schema,'.building AS b ON (o.building_id = b.id AND b.objectclass_id = ',r.class_id,')						
						FULL OUTER JOIN (
							SELECT
								o.building_installation_id AS co_id,
								array_agg(o.',t.lodx_label,'_multi_surface_id) AS sg_id_array
							FROM 
								',qi_cdb_schema,'.thematic_surface AS o
								INNER JOIN ',qi_cdb_schema,'.cityobject AS co ON (co.id = o.id ',sql_where,')
								INNER JOIN ',qi_cdb_schema,'.building AS b ON (o.building_id = b.id AND b.objectclass_id = ',r.class_id,')
							WHERE 
								o.building_installation_id IS NOT NULL
							GROUP BY o.building_installation_id
						) AS ts_t ON (ts_t.co_id = o.id)
					WHERE
						o.',t.lodx_label,'_implicit_rep_id IS NULL
				) AS foo
	   ) AS foo2
	INNER JOIN ',qi_cdb_schema,'.surface_geometry AS sg ON (sg.root_id = foo2.sg_id AND sg.geometry IS NOT NULL)
	GROUP BY foo2.co_id
	UNION');
sql_layer := concat(sql_layer,'	
	SELECT
		o.id::bigint AS co_id,
		ST_SetSRID(
			ST_Translate(
				ST_Affine(ST_Collect(sg.implicit_geometry),
					split_part(',t.lodx_label,'_implicit_transformation, '' '', 1)::double precision,
					split_part(',t.lodx_label,'_implicit_transformation, '' '', 2)::double precision,
					split_part(',t.lodx_label,'_implicit_transformation, '' '', 3)::double precision,
					split_part(',t.lodx_label,'_implicit_transformation, '' '', 5)::double precision,
					split_part(',t.lodx_label,'_implicit_transformation, '' '', 6)::double precision,
					split_part(',t.lodx_label,'_implicit_transformation, '' '', 7)::double precision,
					split_part(',t.lodx_label,'_implicit_transformation, '' '', 9)::double precision,
					split_part(',t.lodx_label,'_implicit_transformation, '' '', 10)::double precision,
					split_part(',t.lodx_label,'_implicit_transformation, '' '', 11)::double precision,
					split_part(',t.lodx_label,'_implicit_transformation, '' '', 4)::double precision,
					split_part(',t.lodx_label,'_implicit_transformation, '' '', 8)::double precision,
					split_part(',t.lodx_label,'_implicit_transformation, '' '', 12)::double precision
					),
			   ST_X(o.',t.lodx_label,'_implicit_ref_point)::double precision,
			   ST_Y(o.',t.lodx_label,'_implicit_ref_point)::double precision,
			   ST_Z(o.',t.lodx_label,'_implicit_ref_point)::double precision
			),
			',srid_id,')::geometry(MultiPolygonZ, ',srid_id,') AS geom
	FROM 
		',qi_cdb_schema,'.building_installation AS o
		INNER JOIN ',qi_cdb_schema,'.cityobject AS co ON (o.id = co.id AND o.objectclass_id = ',s.class_id,' ',sql_where,')
		INNER JOIN ',qi_cdb_schema,'.building AS b ON (b.id = o.building_id AND b.objectclass_id = ',r.class_id,')
		INNER JOIN ',qi_cdb_schema,'.implicit_geometry AS ig ON (ig.id = o.',t.lodx_label,'_implicit_rep_id)
		INNER JOIN ',qi_cdb_schema,'.surface_geometry AS sg ON (sg.root_id = ig.relative_brep_id AND sg.implicit_geometry IS NOT NULL)
	WHERE
		o.',t.lodx_label,'_implicit_rep_id IS NOT NULL
	GROUP BY o.id
WITH NO DATA;
COMMENT ON MATERIALIZED VIEW ',qi_usr_schema,'.',qi_mview_name,' IS ''Mat. view of (',r.class_name,') ',s.class_name,' ',t.lodx_name,' in schema ',qi_cdb_schema,''';
',qgis_pkg.generate_sql_matview_footer(qi_usr_name, qi_usr_schema, qi_mview_name, ql_view_name));

-------
-- VIEW
-------
sql_layer := concat(sql_layer, qgis_pkg.generate_sql_view_header(qi_usr_schema, qi_view_name),'
SELECT',
sql_co_atts,
sql_cfu_atts,'
  o.building_id,
  g.geom::geometry(MultiPolygonZ,',srid_id,')
FROM
	',qi_usr_schema,'.',qi_mview_name,' AS g 
	INNER JOIN ',qi_cdb_schema,'.cityobject AS co ON (g.co_id = co.id AND co.objectclass_id = ',s.class_id,')
  	INNER JOIN ',qi_cdb_schema,'.building_installation AS o ON (o.id = co.id AND o.objectclass_id = ',s.class_id,')
	INNER JOIN ',qi_cdb_schema,'.building AS b ON (b.id = o.building_id AND b.objectclass_id = ',r.class_id,');
COMMENT ON VIEW ',qi_usr_schema,'.',qi_view_name,' IS ''View of (',r.class_name,') ',s.class_name,' ',t.lodx_name,' in schema ',qi_cdb_schema,''';
ALTER TABLE ',qi_usr_schema,'.',qi_view_name,' OWNER TO ',qi_usr_name,';
');

-- Add triggers to make view updatable
sql_trig := concat(sql_trig,qgis_pkg.generate_sql_triggers(view_name, trig_f_suffix, usr_name, usr_schema));
-- Add entry to update table layer_metadata
sql_ins := concat(sql_ins,'
(',num_features,',',ql_cdb_schema,',''',feature_type,''',''',qml_file_name,''',''',t.lodx_label,''',''',r.class_name,''',''',l_name,''',clock_timestamp(),',ql_mview_name,',',ql_view_name,'),');
ELSE
sql_layer := concat(sql_layer, qgis_pkg.generate_sql_matview_else(qi_usr_schema, qi_mview_name, ql_view_name));
END IF;

---------------------------------------------------------------
-- Create LAYER BUILDING(PART)_LOD2-4_BUILDING INSTALLATION_THEMATIC_SURFACE
---------------------------------------------------------------
			FOR u IN 
				SELECT * FROM (VALUES
				('BuildingRoofSurface'::varchar , 33::integer, 'roofsurf'::varchar),
				('BuildingWallSurface'			, 34		 , 'wallsurf'),
				('BuildingGroundSurface'		, 35		 , 'groundsurf'),
				('BuildingClosureSurface'		, 36		 , 'closuresurf'),
				('OuterBuildingCeilingSurface'	, 60		 , 'outerceilingsurf'),
				('OuterBuildingFloorSurface'	, 61		 , 'outerfloorsurf')
				) AS t(class_name, class_id, class_label)
			LOOP

sql_mview_count := concat('
SELECT 
	count(o.id) AS n_features
FROM 
	',qi_cdb_schema,'.thematic_surface AS o
	INNER JOIN ',qi_cdb_schema,'.cityobject AS co ON (o.id = co.id AND o.objectclass_id = ',u.class_id,' ',sql_where,')
	INNER JOIN ',qi_cdb_schema,'.building_installation AS bi ON (bi.id = o.building_installation_id AND bi.objectclass_id = ',s.class_id,')
	INNER JOIN ',qi_cdb_schema,'.building AS b ON (b.id = o.building_id AND b.objectclass_id = ',r.class_id,')
WHERE
	o.',t.lodx_label,'_multi_surface_id IS NOT NULL;
');
EXECUTE sql_mview_count INTO num_features;

RAISE NOTICE 'Found % features for (%) % % %', num_features, r.class_name, s.class_name, t.lodx_name, u.class_name;

l_name         := concat(r.class_label,'_',s.class_label,'_',t.lodx_label,'_',u.class_label);
view_name      := concat(cdb_schema,'_',l_name);
mview_name     := concat('_g_',view_name);
qi_mview_name  := quote_ident(mview_name); ql_mview_name := quote_literal(mview_name);
qi_view_name   := quote_ident(view_name); ql_view_name := quote_literal(view_name);
qml_file_name  := concat('bdg_out_installation_thematic_surface_form.qml');
trig_f_suffix := 'thematic_surface';

IF (num_features > 0) OR (force_layer_creation IS TRUE) THEN

--------------------
-- MATERIALIZED VIEW
--------------------
sql_layer := concat(sql_layer, qgis_pkg.generate_sql_matview_header(qi_usr_schema,qi_mview_name),'
	SELECT
		sg.cityobject_id::bigint AS co_id,
		ST_Collect(qgis_pkg.ST_snap_poly_to_grid(sg.geometry,',perform_snapping,',',digits,',',area_poly_min,'))::geometry(MultiPolygonZ,',srid_id,') AS geom
	FROM
		',qi_cdb_schema,'.thematic_surface AS o
		INNER JOIN ',qi_cdb_schema,'.cityobject AS co ON (o.id = co.id AND o.objectclass_id = ',u.class_id,' ',sql_where,') 
		INNER JOIN ',qi_cdb_schema,'.building_installation AS bi ON (o.building_installation_id = bi.id AND bi.objectclass_id = ',s.class_id,')
		INNER JOIN ',qi_cdb_schema,'.building AS b ON (o.building_id = b.id AND b.objectclass_id = ',r.class_id,')		
		INNER JOIN ',qi_cdb_schema,'.surface_geometry AS sg ON (sg.root_id = o.',t.lodx_name,'_multi_surface_id  AND sg.geometry IS NOT NULL)
	GROUP BY sg.cityobject_id
WITH NO DATA;
COMMENT ON MATERIALIZED VIEW ',qi_usr_schema,'.',qi_mview_name,' IS ''Mat. view of (',r.class_name,') ',s.class_name,' ',t.lodx_name,' ',u.class_name,' in schema ',qi_cdb_schema,''';
',qgis_pkg.generate_sql_matview_footer(qi_usr_name, qi_usr_schema, qi_mview_name, ql_view_name));

-------
-- VIEW
-------
sql_layer := concat(sql_layer, qgis_pkg.generate_sql_view_header(qi_usr_schema, qi_view_name),'
SELECT',
sql_co_atts,'
  o.building_installation_id,
  g.geom::geometry(MultiPolygonZ,',srid_id,')
FROM
	',qi_usr_schema,'.',qi_mview_name,' AS g 
	INNER JOIN ',qi_cdb_schema,'.cityobject AS co ON (g.co_id = co.id AND co.objectclass_id = ',u.class_id,')
	INNER JOIN ',qi_cdb_schema,'.thematic_surface AS o ON (o.id = co.id AND o.objectclass_id = ',u.class_id,')
  	INNER JOIN ',qi_cdb_schema,'.building_installation AS bi ON (bi.id = o.building_installation_id AND bi.objectclass_id = ',s.class_id,')
	INNER JOIN ',qi_cdb_schema,'.building AS b ON (b.id = bi.building_id AND b.objectclass_id = ',r.class_id,');
COMMENT ON VIEW ',qi_usr_schema,'.',qi_view_name,' IS ''View of (',r.class_name,') ',s.class_name,' ',t.lodx_name,' ',u.class_name,' in schema ',qi_cdb_schema,''';
ALTER TABLE ',qi_usr_schema,'.',qi_view_name,' OWNER TO ',qi_usr_name,';
');

-- Add triggers to make view updatable
sql_trig := concat(sql_trig,qgis_pkg.generate_sql_triggers(view_name, trig_f_suffix, usr_name, usr_schema));
-- Add entry to update table layer_metadata
sql_ins := concat(sql_ins,'
(',num_features,',',ql_cdb_schema,',''',feature_type,''',''',qml_file_name,''',''',t.lodx_label,''',''',r.class_name,''',''',l_name,''',clock_timestamp(),',ql_mview_name,',',ql_view_name,'),');
ELSE
sql_layer := concat(sql_layer, qgis_pkg.generate_sql_matview_else(qi_usr_schema, qi_mview_name, ql_view_name));
END IF;

			END LOOP; -- end loop outer building installation thematic surfaces lod 2-4
		END LOOP; -- building installation lod2-4
	END LOOP; -- building installation

---------------------------------------------------------------
-- Create LAYER BUILDING(PART)_OPENING_LOD3-4
---------------------------------------------------------------
	FOR s IN 
		SELECT * FROM (VALUES
		('BuildingWindow'::varchar, 38::integer, 'window'::varchar),
		('BuildingDoor'           , 39         , 'door')		
		) AS t(class_name, class_id, class_label)
	LOOP
		FOR t IN 
			SELECT * FROM (VALUES
			('LoD3'::varchar, 'lod3'::varchar),
			('LoD4'			, 'lod4')		
			) AS t(lodx_name, lodx_label)
		LOOP

sql_mview_count := concat('
	SELECT 
		count(o.id) AS n_features
	FROM 
		',qi_cdb_schema,'.opening AS o
		INNER JOIN ',qi_cdb_schema,'.cityobject AS co ON (o.id = co.id AND o.objectclass_id = ',s.class_id,' ',sql_where,')
		INNER JOIN ',qi_cdb_schema,'.opening_to_them_surface AS ots ON (ots.opening_id = o.id)
		INNER JOIN ',qi_cdb_schema,'.thematic_surface AS ts ON (ts.id = ots.thematic_surface_id)
		INNER JOIN ',qi_cdb_schema,'.building AS b ON (b.id = ts.building_id AND b.objectclass_id = ',r.class_id,')
	WHERE
		o.',t.lodx_label,'_multi_surface_id IS NOT NULL OR o.',t.lodx_label,'_implicit_rep_id IS NOT NULL;
');
EXECUTE sql_mview_count INTO num_features;

RAISE NOTICE 'Found % features for (%) % %', num_features, r.class_name, s.class_name, t.lodx_name;

l_name         := concat(r.class_label,'_',s.class_label,'_',t.lodx_label);
view_name      := concat(cdb_schema,'_',l_name);
mview_name     := concat('_g_',view_name);
qi_mview_name  := quote_ident(mview_name); ql_mview_name := quote_literal(mview_name);
qi_view_name   := quote_ident(view_name); ql_view_name := quote_literal(view_name);
qml_file_name  := concat('bdg_opening_form.qml');
trig_f_suffix := 'opening';

IF (num_features > 0) OR (force_layer_creation IS TRUE) THEN

--------------------
-- MATERIALIZED VIEW
--------------------
sql_layer := concat(sql_layer, qgis_pkg.generate_sql_matview_header(qi_usr_schema,qi_mview_name),'
	SELECT
		sg.cityobject_id::bigint AS co_id,
		ST_Collect(qgis_pkg.ST_snap_poly_to_grid(sg.geometry,',perform_snapping,',',digits,',',area_poly_min,'))::geometry(MultiPolygonZ,',srid_id,') AS geom
	FROM
		',qi_cdb_schema,'.opening AS o
		INNER JOIN ',qi_cdb_schema,'.cityobject AS co ON (o.id = co.id AND o.objectclass_id = ',s.class_id,' ',sql_where,')
		INNER JOIN ',qi_cdb_schema,'.opening_to_them_surface AS ots ON (ots.opening_id = o.id)
		INNER JOIN ',qi_cdb_schema,'.thematic_surface AS ts ON (ts.id = ots.thematic_surface_id)
		INNER JOIN ',qi_cdb_schema,'.building AS b ON (b.id = ts.building_id AND b.objectclass_id = ',r.class_id,')
		INNER JOIN ',qi_cdb_schema,'.surface_geometry sg ON sg.root_id = o.',t.lodx_name,'_multi_surface_id  AND sg.geometry IS NOT NULL
	WHERE
		o.',t.lodx_name,'_implicit_rep_id IS NULL
	GROUP BY sg.cityobject_id
	UNION');
sql_layer := concat(sql_layer,'
	SELECT
		o.id::bigint AS co_id,
		ST_SetSRID(
			ST_Translate(
				ST_Affine(ST_Collect(sg.implicit_geometry),
					split_part(',t.lodx_label,'_implicit_transformation, '' '', 1)::double precision,
					split_part(',t.lodx_label,'_implicit_transformation, '' '', 2)::double precision,
					split_part(',t.lodx_label,'_implicit_transformation, '' '', 3)::double precision,
					split_part(',t.lodx_label,'_implicit_transformation, '' '', 5)::double precision,
					split_part(',t.lodx_label,'_implicit_transformation, '' '', 6)::double precision,
					split_part(',t.lodx_label,'_implicit_transformation, '' '', 7)::double precision,
					split_part(',t.lodx_label,'_implicit_transformation, '' '', 9)::double precision,
					split_part(',t.lodx_label,'_implicit_transformation, '' '', 10)::double precision,
					split_part(',t.lodx_label,'_implicit_transformation, '' '', 11)::double precision,
					split_part(',t.lodx_label,'_implicit_transformation, '' '', 4)::double precision,
					split_part(',t.lodx_label,'_implicit_transformation, '' '', 8)::double precision,
					split_part(',t.lodx_label,'_implicit_transformation, '' '', 12)::double precision
					),
			   ST_X(o.',t.lodx_label,'_implicit_ref_point)::double precision,
			   ST_Y(o.',t.lodx_label,'_implicit_ref_point)::double precision,
			   ST_Z(o.',t.lodx_label,'_implicit_ref_point)::double precision
			),
			',srid_id,')::geometry(MultiPolygonZ, ',srid_id,') AS geom
	FROM 
		',qi_cdb_schema,'.opening AS o
		INNER JOIN ',qi_cdb_schema,'.cityobject AS co ON (o.id = co.id AND o.objectclass_id = ',s.class_id,' ',sql_where,')		
		INNER JOIN ',qi_cdb_schema,'.opening_to_them_surface AS ots ON (ots.opening_id = o.id)
		INNER JOIN ',qi_cdb_schema,'.thematic_surface AS ts ON (ts.id = ots.thematic_surface_id)
		INNER JOIN ',qi_cdb_schema,'.building AS b ON (b.id = ts.building_id AND b.objectclass_id = ',r.class_id,')	
		INNER JOIN ',qi_cdb_schema,'.implicit_geometry AS ig ON (ig.id = o.',t.lodx_name,'_implicit_rep_id) 
		INNER JOIN ',qi_cdb_schema,'.surface_geometry AS sg ON (sg.root_id = ig.relative_brep_id AND sg.implicit_geometry IS NOT NULL)
	WHERE
		o.',t.lodx_name,'_implicit_rep_id IS NOT NULL
	GROUP BY o.id
WITH NO DATA;
COMMENT ON MATERIALIZED VIEW ',qi_usr_schema,'.',qi_mview_name,' IS ''Mat. view of (',r.class_name,') ',s.class_name,' ',t.lodx_name,' in schema ',qi_cdb_schema,''';
',qgis_pkg.generate_sql_matview_footer(qi_usr_name, qi_usr_schema, qi_mview_name, ql_view_name));

-------
-- VIEW
-------
sql_layer := concat(sql_layer, qgis_pkg.generate_sql_view_header(qi_usr_schema, qi_view_name),'
SELECT',
sql_co_atts,'
  ots.thematic_surface_id,
  g.geom::geometry(MultiPolygonZ,',srid_id,')
FROM
	',qi_usr_schema,'.',qi_mview_name,' AS g 
	INNER JOIN ',qi_cdb_schema,'.cityobject AS co ON (g.co_id = co.id AND co.objectclass_id = ',s.class_id,')
  	INNER JOIN ',qi_cdb_schema,'.opening_to_them_surface AS ots ON (ots.opening_id = co.id)
--	INNER JOIN ',qi_cdb_schema,'.opening AS o ON (o.id = co.id AND o.objectclass_id = ',s.class_id,')
-- 	INNER JOIN ',qi_cdb_schema,'.opening_to_them_surface AS ots ON (ots.opening_id = o.id)
	INNER JOIN ',qi_cdb_schema,'.thematic_surface AS ts ON (ts.id = ots.thematic_surface_id)
	INNER JOIN ',qi_cdb_schema,'.building AS b ON (b.id = ts.building_id AND b.objectclass_id = ',r.class_id,');
COMMENT ON VIEW ',qi_usr_schema,'.',qi_view_name,' IS ''View of (',r.class_name,') ',s.class_name,' ',t.lodx_name,' in schema ',qi_cdb_schema,''';
ALTER TABLE ',qi_usr_schema,'.',qi_view_name,' OWNER TO ',qi_usr_name,';
');

-- Add triggers to make view updatable
sql_trig := concat(sql_trig,qgis_pkg.generate_sql_triggers(view_name, trig_f_suffix, usr_name, usr_schema));
-- Add entry to update table layer_metadata
sql_ins := concat(sql_ins,'
(',num_features,',',ql_cdb_schema,',''',feature_type,''',''',qml_file_name,''',''',t.lodx_label,''',''',r.class_name,''',''',l_name,''',clock_timestamp(),',ql_mview_name,',',ql_view_name,'),');
ELSE
sql_layer := concat(sql_layer, qgis_pkg.generate_sql_matview_else(qi_usr_schema, qi_mview_name, ql_view_name));
END IF;

		END LOOP; -- opening lod3-4

	END LOOP; -- opening

---------------------------------------------------------------
-- Create LAYER BUILDING(PART)_ROOM_LOD4
---------------------------------------------------------------
	FOR s IN 
		SELECT * FROM (VALUES
		('Room'::varchar, 41::integer, 'room'::varchar)	
		) AS t(class_name, class_id, class_label)
	LOOP
		FOR t IN 
			SELECT * FROM (VALUES
			('LoD4'::varchar, 'lod4'::varchar)
			) AS t(lodx_name, lodx_label)
		LOOP

sql_mview_count := concat('
SELECT 
	count(o.id) AS n_features
FROM 
	',qi_cdb_schema,'.room AS o
	INNER JOIN ',qi_cdb_schema,'.cityobject AS co ON (o.id = co.id AND o.objectclass_id = ',s.class_id,' ',sql_where,')
	INNER JOIN ',qi_cdb_schema,'.building AS b ON (b.id = o.building_id AND b.objectclass_id = ',r.class_id,')
WHERE
	o.',t.lodx_label,'_multi_surface_id IS NOT NULL OR o.',t.lodx_label,'_solid_id IS NOT NULL;
');
EXECUTE sql_mview_count INTO num_features;

RAISE NOTICE 'Found % features for (%) % %', num_features, r.class_name, s.class_name, t.lodx_name;

l_name         := concat(r.class_label,'_',s.class_label,'_',t.lodx_label);
view_name      := concat(cdb_schema,'_',l_name);
mview_name     := concat('_g_',view_name);
qi_mview_name  := quote_ident(mview_name); ql_mview_name := quote_literal(mview_name);
qi_view_name   := quote_ident(view_name); ql_view_name := quote_literal(view_name);
qml_file_name  := concat('bdg_room_form.qml');
trig_f_suffix := 'room';

IF (num_features > 0) OR (force_layer_creation IS TRUE) THEN

--------------------
-- MATERIALIZED VIEW
--------------------
sql_layer := concat(sql_layer, qgis_pkg.generate_sql_matview_header(qi_usr_schema,qi_mview_name),'
	SELECT
		foo2.co_id::bigint AS co_id,
		ST_Collect(qgis_pkg.ST_snap_poly_to_grid(sg.geometry,',perform_snapping,',',digits,',',area_poly_min,'))::geometry(MultiPolygonZ, ',srid_id,') AS geom	
	FROM (
		SELECT
			foo.co_id,
			unnest(foo.sg_id_array) AS sg_id
		FROM (
			SELECT
				coalesce(o.id, ts_t.co_id) as co_id,
				CASE 
					WHEN ts_t.sg_id_array IS NOT NULL THEN ts_t.sg_id_array
					WHEN o.',t.lodx_label,'_solid_id IS NOT NULL THEN ARRAY[o.',t.lodx_label,'_solid_id]
					ELSE ARRAY[o.',t.lodx_label,'_multi_surface_id]
				END AS sg_id_array 
			FROM 
				',qi_cdb_schema,'.room AS o
				INNER JOIN ',qi_cdb_schema,'.cityobject AS co ON (o.id = co.id AND o.objectclass_id = ',s.class_id,' ',sql_where,')
				INNER JOIN ',qi_cdb_schema,'.building AS b ON (b.id = o.building_id AND b.objectclass_id = ',r.class_id,')
				FULL OUTER JOIN (
					SELECT ts.room_id AS co_id, array_agg(ts.',t.lodx_label,'_multi_surface_id) AS sg_id_array 
					FROM 
						',qi_cdb_schema,'.thematic_surface AS ts
						INNER JOIN ',qi_cdb_schema,'.cityobject AS co ON (co.id = ts.id ',sql_where,')
						INNER JOIN ',qi_cdb_schema,'.room AS r ON (ts.room_id = r.id AND r.objectclass_id = ',s.class_id,' ',sql_where,')
						INNER JOIN ',qi_cdb_schema,'.building AS b1 ON (b1.id = r.building_id AND b1.objectclass_id = ',r.class_id,')						
					GROUP BY ts.room_id
					) AS ts_t ON (ts_t.co_id = o.id)
			) AS foo
		) AS foo2
		INNER JOIN ',qi_cdb_schema,'.surface_geometry AS sg ON (sg.root_id = foo2.sg_id AND sg.geometry IS NOT NULL)
	GROUP BY foo2.co_id
WITH NO DATA;
COMMENT ON MATERIALIZED VIEW ',qi_usr_schema,'.',qi_mview_name,' IS ''Mat. view of (',r.class_name,') ',s.class_name,' ',t.lodx_name,' in schema ',qi_cdb_schema,''';
',qgis_pkg.generate_sql_matview_footer(qi_usr_name, qi_usr_schema, qi_mview_name, ql_view_name));

-------
-- VIEW
-------
sql_layer := concat(sql_layer, qgis_pkg.generate_sql_view_header(qi_usr_schema, qi_view_name),'
SELECT',
sql_co_atts,
sql_cfu_atts,'
  o.building_id,
  g.geom::geometry(MultiPolygonZ,',srid_id,')
FROM
	',qi_usr_schema,'.',qi_mview_name,' AS g 
	INNER JOIN ',qi_cdb_schema,'.cityobject AS co ON (g.co_id = co.id AND co.objectclass_id = ',s.class_id,')
  	INNER JOIN ',qi_cdb_schema,'.room AS o ON (o.id = co.id AND o.objectclass_id = ',s.class_id,')	
  	INNER JOIN ',qi_cdb_schema,'.building AS b ON (b.id = o.building_id AND b.objectclass_id = ',r.class_id,');
COMMENT ON VIEW ',qi_usr_schema,'.',qi_view_name,' IS ''View of (',r.class_name,') ',s.class_name,' ',t.lodx_name,' in schema ',qi_cdb_schema,''';
ALTER TABLE ',qi_usr_schema,'.',qi_view_name,' OWNER TO ',qi_usr_name,';
');

-- Add triggers to make view updatable
sql_trig := concat(sql_trig,qgis_pkg.generate_sql_triggers(view_name, trig_f_suffix, usr_name, usr_schema));
-- Add entry to update table layer_metadata
sql_ins := concat(sql_ins,'
(',num_features,',',ql_cdb_schema,',''',feature_type,''',''',qml_file_name,''',''',t.lodx_label,''',''',r.class_name,''',''',l_name,''',clock_timestamp(),',ql_mview_name,',',ql_view_name,'),');
ELSE
sql_layer := concat(sql_layer, qgis_pkg.generate_sql_matview_else(qi_usr_schema, qi_mview_name, ql_view_name));
END IF;

---------------------------------------------------------------
-- Create LAYER BUILDING(PART)_ROOM_LOD4_THEMATIC_SURFACES
---------------------------------------------------------------
			FOR u IN 
				SELECT * FROM (VALUES
				('BuildingCeilingSurface'::varchar	, 30::integer	, 'ceilingsurf'::varchar),
				('InteriorBuildingWallSurface'		, 31		 	, 'intwallsurf'),
				('BuildingFloorSurface'				, 32		    , 'floorsurf')
				) AS t(class_name, class_id, class_label)
			LOOP

sql_mview_count := concat('
SELECT
	count(o.id) AS n_features
FROM 
	',qi_cdb_schema,'.thematic_surface AS o
	INNER JOIN ',qi_cdb_schema,'.cityobject AS co ON (co.id = o.id AND o.objectclass_id = ',u.class_id,' ',sql_where,')
	INNER JOIN ',qi_cdb_schema,'.room AS r ON (r.id = o.room_id AND r.objectclass_id = ',s.class_id,')
	INNER JOIN ',qi_cdb_schema,'.building AS b ON (b.id = r.building_id AND b.objectclass_id = ',r.class_id,')
WHERE
	o.',t.lodx_label,'_multi_surface_id IS NOT NULL;
');
EXECUTE sql_mview_count INTO num_features;

RAISE NOTICE 'Found % features for (%) % % %', num_features, r.class_name, s.class_name, t.lodx_name, u.class_label;

l_name         := concat(r.class_label,'_',s.class_label,'_',t.lodx_label,'_',u.class_label);
view_name      := concat(cdb_schema,'_',l_name);
mview_name     := concat('_g_',view_name);
qi_mview_name  := quote_ident(mview_name); ql_mview_name := quote_literal(mview_name);
qi_view_name   := quote_ident(view_name); ql_view_name := quote_literal(view_name);
qml_file_name  := concat('bdg_room_thematic_surface_form.qml');
trig_f_suffix := 'thematic_surface';

IF (num_features > 0) OR (force_layer_creation IS TRUE) THEN

--------------------
-- MATERIALIZED VIEW
--------------------
sql_layer := concat(sql_layer, qgis_pkg.generate_sql_matview_header(qi_usr_schema,qi_mview_name),'
	SELECT
		sg.cityobject_id::bigint AS co_id,
		ST_Collect(qgis_pkg.ST_snap_poly_to_grid(sg.geometry,',perform_snapping,',',digits,',',area_poly_min,'))::geometry(MultiPolygonZ, ',srid_id,') AS geom
	FROM
		',qi_cdb_schema,'.thematic_surface AS o
		INNER JOIN ',qi_cdb_schema,'.cityobject AS co ON (o.id = co.id AND o.objectclass_id = ',u.class_id,' ',sql_where,') 
		INNER JOIN ',qi_cdb_schema,'.room AS r ON (r.id = o.room_id AND r.objectclass_id = ',s.class_id,')
		INNER JOIN ',qi_cdb_schema,'.building AS b ON (b.id = r.building_id AND b.objectclass_id = ',r.class_id,')		
		INNER JOIN ',qi_cdb_schema,'.surface_geometry AS sg ON (sg.root_id = o.',t.lodx_name,'_multi_surface_id  AND sg.geometry IS NOT NULL)
	GROUP BY sg.cityobject_id
WITH NO DATA;
COMMENT ON MATERIALIZED VIEW ',qi_usr_schema,'.',qi_mview_name,' IS ''Mat. view of (',r.class_name,') ',s.class_name,' ',t.lodx_name,' ',u.class_name,' in schema ',qi_cdb_schema,''';
',qgis_pkg.generate_sql_matview_footer(qi_usr_name, qi_usr_schema, qi_mview_name, ql_view_name));

-------
-- VIEW
-------
sql_layer := concat(sql_layer, qgis_pkg.generate_sql_view_header(qi_usr_schema, qi_view_name),'
SELECT',
sql_co_atts,'
  o.room_id,
  g.geom::geometry(MultiPolygonZ,',srid_id,')
FROM
	',qi_usr_schema,'.',qi_mview_name,' AS g 
	INNER JOIN ',qi_cdb_schema,'.cityobject AS co ON (g.co_id = co.id AND co.objectclass_id = ',u.class_id,')
  	INNER JOIN ',qi_cdb_schema,'.thematic_surface AS o ON (o.id = co.id AND o.objectclass_id = ',u.class_id,')
	INNER JOIN ',qi_cdb_schema,'.room AS r ON (r.id = o.room_id AND r.objectclass_id = ',s.class_id,')
	INNER JOIN ',qi_cdb_schema,'.building AS b ON (b.id = r.building_id AND b.objectclass_id = ',r.class_id,');
COMMENT ON VIEW ',qi_usr_schema,'.',qi_view_name,' IS ''View of (',r.class_name,') ',s.class_name,' ',t.lodx_name,' ',u.class_name,' in schema ',qi_cdb_schema,''';
ALTER TABLE ',qi_usr_schema,'.',qi_view_name,' OWNER TO ',qi_usr_name,';
');

-- Add triggers to make view updatable
sql_trig := concat(sql_trig,qgis_pkg.generate_sql_triggers(view_name, trig_f_suffix, usr_name, usr_schema));
-- Add entry to update table layer_metadata
sql_ins := concat(sql_ins,'
(',num_features,',',ql_cdb_schema,',''',feature_type,''',''',qml_file_name,''',''',t.lodx_label,''',''',r.class_name,''',''',l_name,''',clock_timestamp(),',ql_mview_name,',',ql_view_name,'),');
ELSE
sql_layer := concat(sql_layer, qgis_pkg.generate_sql_matview_else(qi_usr_schema, qi_mview_name, ql_view_name));
END IF;

			END LOOP; -- room lod4 thematic surfaces
		END LOOP; -- room lod4
	END LOOP; -- room

---------------------------------------------------------------
-- Create LAYER BUILDING(PART)_INT_BUILDING_INSTALLATION_LOD4
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

sql_mview_count := concat('
SELECT 
	count(foo.n_features) AS n_features 
FROM (
	SELECT 
		o.id AS n_features
	FROM 
		',qi_cdb_schema,'.building_installation AS o
		INNER JOIN ',qi_cdb_schema,'.cityobject AS co ON (o.id = co.id AND o.objectclass_id = ',s.class_id,' ',sql_where,')
		INNER JOIN ',qi_cdb_schema,'.building AS b ON (b.id = o.building_id AND b.objectclass_id = ',r.class_id,')
	WHERE
		o.',t.lodx_label,'_brep_id IS NOT NULL OR o.',t.lodx_label,'_implicit_rep_id IS NOT NULL
	UNION
	SELECT DISTINCT 
		o.building_installation_id AS n_features
	FROM 
		',qi_cdb_schema,'.thematic_surface AS o
		INNER JOIN ',qi_cdb_schema,'.cityobject AS co ON (o.id = co.id ',sql_where,')
		INNER JOIN ',qi_cdb_schema,'.building_installation AS bi ON (bi.id = o.building_installation_id AND bi.objectclass_id = ',s.class_id,')		
		INNER JOIN ',qi_cdb_schema,'.building AS b ON (b.id = bi.building_id AND b.objectclass_id = ',r.class_id,')
	WHERE
		o.',t.lodx_label,'_multi_surface_id IS NOT NULL
) AS foo;
');
EXECUTE sql_mview_count INTO num_features;

RAISE NOTICE 'Found % features for (%) % %', num_features, r.class_name, s.class_name, t.lodx_name;

l_name         := concat(r.class_label,'_',s.class_label,'_',t.lodx_label);
view_name      := concat(cdb_schema,'_',l_name);
mview_name     := concat('_g_',view_name);
qi_mview_name  := quote_ident(mview_name); ql_mview_name := quote_literal(mview_name);
qi_view_name   := quote_ident(view_name); ql_view_name := quote_literal(view_name);
qml_file_name  := concat('bdg_int_installation_form.qml');
trig_f_suffix := 'building_installation';

IF (num_features > 0) OR (force_layer_creation IS TRUE) THEN

--------------------
-- MATERIALIZED VIEW
--------------------
sql_layer := concat(sql_layer, qgis_pkg.generate_sql_matview_header(qi_usr_schema,qi_mview_name),'
	SELECT 
		foo2.co_id AS co_id,
		st_collect(qgis_pkg.ST_snap_poly_to_grid(sg.geometry,',perform_snapping,',',digits,',',area_poly_min,'))::geometry(MultiPolygonZ, ',srid_id,') AS geom
	FROM ( 
			SELECT 
				foo.co_id,
				unnest(foo.sg_id_array) AS sg_id
			FROM ( 
					SELECT
						coalesce(o.id, ts_t.co_id) as co_id,
						CASE
							WHEN ts_t.sg_id_array IS NOT NULL THEN ts_t.sg_id_array
							ELSE ARRAY[o.',t.lodx_label,'_brep_id]
						END AS sg_id_array
					FROM 
						',qi_cdb_schema,'.building_installation AS o
						INNER JOIN ',qi_cdb_schema,'.cityobject AS co ON (o.id = co.id AND o.objectclass_id = ',s.class_id,' ',sql_where,')
						INNER JOIN ',qi_cdb_schema,'.building AS b ON (o.building_id = b.id AND b.objectclass_id = ',r.class_id,')						
						FULL OUTER JOIN (
							SELECT
								o.building_installation_id AS co_id,
								array_agg(o.',t.lodx_label,'_multi_surface_id) AS sg_id_array
							FROM 
								',qi_cdb_schema,'.thematic_surface AS o
								INNER JOIN ',qi_cdb_schema,'.cityobject AS co ON (co.id = o.id ',sql_where,')
								INNER JOIN ',qi_cdb_schema,'.building AS b ON (o.building_id = b.id AND b.objectclass_id = ',r.class_id,')
							WHERE 
								o.building_installation_id IS NOT NULL
							GROUP BY o.building_installation_id
						) AS ts_t ON (ts_t.co_id = o.id)
					WHERE
						o.',t.lodx_label,'_implicit_rep_id IS NULL
				) AS foo
	   ) AS foo2
	INNER JOIN ',qi_cdb_schema,'.surface_geometry AS sg ON (sg.root_id = foo2.sg_id AND sg.geometry IS NOT NULL)
	GROUP BY foo2.co_id
	UNION');
sql_layer := concat(sql_layer,'	
	SELECT
		o.id::bigint AS co_id,
		ST_SetSRID(
			ST_Translate(
				ST_Affine(ST_Collect(sg.implicit_geometry),
					split_part(',t.lodx_label,'_implicit_transformation, '' '', 1)::double precision,
					split_part(',t.lodx_label,'_implicit_transformation, '' '', 2)::double precision,
					split_part(',t.lodx_label,'_implicit_transformation, '' '', 3)::double precision,
					split_part(',t.lodx_label,'_implicit_transformation, '' '', 5)::double precision,
					split_part(',t.lodx_label,'_implicit_transformation, '' '', 6)::double precision,
					split_part(',t.lodx_label,'_implicit_transformation, '' '', 7)::double precision,
					split_part(',t.lodx_label,'_implicit_transformation, '' '', 9)::double precision,
					split_part(',t.lodx_label,'_implicit_transformation, '' '', 10)::double precision,
					split_part(',t.lodx_label,'_implicit_transformation, '' '', 11)::double precision,
					split_part(',t.lodx_label,'_implicit_transformation, '' '', 4)::double precision,
					split_part(',t.lodx_label,'_implicit_transformation, '' '', 8)::double precision,
					split_part(',t.lodx_label,'_implicit_transformation, '' '', 12)::double precision
					),
			   ST_X(o.',t.lodx_label,'_implicit_ref_point)::double precision,
			   ST_Y(o.',t.lodx_label,'_implicit_ref_point)::double precision,
			   ST_Z(o.',t.lodx_label,'_implicit_ref_point)::double precision
			),
			',srid_id,')::geometry(MultiPolygonZ, ',srid_id,') AS geom
	FROM 
		',qi_cdb_schema,'.building_installation AS o
		INNER JOIN ',qi_cdb_schema,'.cityobject AS co ON (o.id = co.id AND o.objectclass_id = ',s.class_id,' ',sql_where,')
		INNER JOIN ',qi_cdb_schema,'.building AS b ON (b.id = o.building_id AND b.objectclass_id = ',r.class_id,')
		INNER JOIN ',qi_cdb_schema,'.implicit_geometry AS ig ON (ig.id = o.',t.lodx_label,'_implicit_rep_id)
		INNER JOIN ',qi_cdb_schema,'.surface_geometry AS sg ON (sg.root_id = ig.relative_brep_id AND sg.implicit_geometry IS NOT NULL)
	WHERE
		o.',t.lodx_label,'_implicit_rep_id IS NOT NULL
	GROUP BY o.id
WITH NO DATA;
COMMENT ON MATERIALIZED VIEW ',qi_usr_schema,'.',qi_mview_name,' IS ''Mat. view of (',r.class_name,') ',s.class_name,' ',t.lodx_name,' in schema ',qi_cdb_schema,''';
',qgis_pkg.generate_sql_matview_footer(qi_usr_name, qi_usr_schema, qi_mview_name, ql_view_name));

-------
-- VIEW
-------
sql_layer := concat(sql_layer, qgis_pkg.generate_sql_view_header(qi_usr_schema, qi_view_name),'
SELECT',
sql_co_atts,
sql_cfu_atts,'
  o.building_id,
  g.geom::geometry(MultiPolygonZ,',srid_id,')
FROM
	',qi_usr_schema,'.',qi_mview_name,' AS g 
	INNER JOIN ',qi_cdb_schema,'.cityobject AS co ON (g.co_id = co.id AND co.objectclass_id = ',s.class_id,')
  	INNER JOIN ',qi_cdb_schema,'.building_installation AS o ON (o.id = co.id AND o.objectclass_id = ',s.class_id,')
	INNER JOIN ',qi_cdb_schema,'.building AS b ON (b.id = o.building_id AND b.objectclass_id = ',r.class_id,');
COMMENT ON VIEW ',qi_usr_schema,'.',qi_view_name,' IS ''View of (',r.class_name,') ',s.class_name,' ',t.lodx_name,' in schema ',qi_cdb_schema,''';
ALTER TABLE ',qi_usr_schema,'.',qi_view_name,' OWNER TO ',qi_usr_name,';
');

-- Add triggers to make view updatable
sql_trig := concat(sql_trig,qgis_pkg.generate_sql_triggers(view_name, trig_f_suffix, usr_name, usr_schema));
-- Add entry to update table layer_metadata
sql_ins := concat(sql_ins,'
(',num_features,',',ql_cdb_schema,',''',feature_type,''',''',qml_file_name,''',''',t.lodx_label,''',''',r.class_name,''',''',l_name,''',clock_timestamp(),',ql_mview_name,',',ql_view_name,'),');
ELSE
sql_layer := concat(sql_layer, qgis_pkg.generate_sql_matview_else(qi_usr_schema, qi_mview_name, ql_view_name));
END IF;

---------------------------------------------------------------
-- Create LAYER BUILDING(PART)_INT_BUILDING_INSTALLATION_LOD4_THEMATIC_SURFACES
---------------------------------------------------------------
			FOR u IN 
				SELECT * FROM (VALUES
				('BuildingCeilingSurface'::varchar	, 30::integer	, 'ceilingsurf'::varchar),
				('InteriorBuildingWallSurface'		, 31		 	, 'intwallsurf'),
				('BuildingFloorSurface'				, 32		    , 'floorsurf'),
				('BuildingRoofSurface'				, 33			, 'roofsurf'),
				('BuildingWallSurface'				, 34		 	, 'wallsurf'),
				('BuildingGroundSurface'			, 35		 	, 'groundsurf'),
				('BuildingClosureSurface'			, 36		 	, 'closuresurf'),
				('OuterBuildingCeilingSurface'		, 60		 	, 'outerceilingsurf'),
				('OuterBuildingFloorSurface'		, 61		 	, 'outerfloorsurf')				
				) AS t(class_name, class_id, class_label)
			LOOP

sql_mview_count := concat('
SELECT 
	count(o.id) AS n_features
FROM 
	',qi_cdb_schema,'.thematic_surface AS o
	INNER JOIN ',qi_cdb_schema,'.cityobject AS co ON (o.id = co.id AND o.objectclass_id = ',u.class_id,' ',sql_where,')
	INNER JOIN ',qi_cdb_schema,'.building_installation AS bi ON (bi.id = o.building_installation_id AND bi.objectclass_id = ',s.class_id,')
	INNER JOIN ',qi_cdb_schema,'.building AS b ON (b.id = o.building_id AND b.objectclass_id = ',r.class_id,')
WHERE
	o.',t.lodx_label,'_multi_surface_id IS NOT NULL;
');
EXECUTE sql_mview_count INTO num_features;

RAISE NOTICE 'Found % features for (%) % % %', num_features, r.class_name, s.class_name, t.lodx_name, u.class_name;

l_name         := concat(r.class_label,'_',s.class_label,'_',t.lodx_label,'_',u.class_label);
view_name      := concat(cdb_schema,'_',l_name);
mview_name     := concat('_g_',view_name);
qi_mview_name  := quote_ident(mview_name); ql_mview_name := quote_literal(mview_name);
qi_view_name   := quote_ident(view_name); ql_view_name := quote_literal(view_name);
qml_file_name  := concat('bdg_int_inst_thematic_surface_form.qml');
trig_f_suffix := 'thematic_surface';

IF (num_features > 0) OR (force_layer_creation IS TRUE) THEN

--------------------
-- MATERIALIZED VIEW
--------------------
sql_layer := concat(sql_layer, qgis_pkg.generate_sql_matview_header(qi_usr_schema,qi_mview_name),'
	SELECT
		sg.cityobject_id::bigint AS co_id,
		ST_Collect(qgis_pkg.ST_snap_poly_to_grid(sg.geometry,',perform_snapping,',',digits,',',area_poly_min,'))::geometry(MultiPolygonZ,',srid_id,') AS geom
	FROM
		',qi_cdb_schema,'.thematic_surface AS o
		INNER JOIN ',qi_cdb_schema,'.cityobject AS co ON (o.id = co.id AND o.objectclass_id = ',u.class_id,' ',sql_where,') 
		INNER JOIN ',qi_cdb_schema,'.building_installation AS bi ON (o.building_installation_id = bi.id AND bi.objectclass_id = ',s.class_id,')
		INNER JOIN ',qi_cdb_schema,'.building AS b ON (o.building_id = b.id AND b.objectclass_id = ',r.class_id,')		
		INNER JOIN ',qi_cdb_schema,'.surface_geometry AS sg ON (sg.root_id = o.',t.lodx_name,'_multi_surface_id  AND sg.geometry IS NOT NULL)
	GROUP BY sg.cityobject_id
WITH NO DATA;
COMMENT ON MATERIALIZED VIEW ',qi_usr_schema,'.',qi_mview_name,' IS ''Mat. view of (',r.class_name,') ',s.class_name,' ',t.lodx_name,' ',u.class_name,' in schema ',qi_cdb_schema,''';
',qgis_pkg.generate_sql_matview_footer(qi_usr_name, qi_usr_schema, qi_mview_name, ql_view_name));

-------
-- VIEW
-------
sql_layer := concat(sql_layer, qgis_pkg.generate_sql_view_header(qi_usr_schema, qi_view_name),'
SELECT',
sql_co_atts,'
  o.building_installation_id,
  g.geom::geometry(MultiPolygonZ,',srid_id,')
FROM
	',qi_usr_schema,'.',qi_mview_name,' AS g 
	INNER JOIN ',qi_cdb_schema,'.cityobject AS co ON (g.co_id = co.id AND co.objectclass_id = ',u.class_id,')
	INNER JOIN ',qi_cdb_schema,'.thematic_surface AS o ON (o.id = co.id AND o.objectclass_id = ',u.class_id,')
  	INNER JOIN ',qi_cdb_schema,'.building_installation AS bi ON (bi.id = o.building_installation_id AND bi.objectclass_id = ',s.class_id,')
	INNER JOIN ',qi_cdb_schema,'.building AS b ON (b.id = bi.building_id AND b.objectclass_id = ',r.class_id,');
COMMENT ON VIEW ',qi_usr_schema,'.',qi_view_name,' IS ''View of (',r.class_name,') ',s.class_name,' ',t.lodx_name,' ',u.class_name,' in schema ',qi_cdb_schema,''';
ALTER TABLE ',qi_usr_schema,'.',qi_view_name,' OWNER TO ',qi_usr_name,';
');

-- Add triggers to make view updatable
sql_trig := concat(sql_trig,qgis_pkg.generate_sql_triggers(view_name, trig_f_suffix, usr_name, usr_schema));
-- Add entry to update table layer_metadata
sql_ins := concat(sql_ins,'
(',num_features,',',ql_cdb_schema,',''',feature_type,''',''',qml_file_name,''',''',t.lodx_label,''',''',r.class_name,''',''',l_name,''',clock_timestamp(),',ql_mview_name,',',ql_view_name,'),');
ELSE
sql_layer := concat(sql_layer, qgis_pkg.generate_sql_matview_else(qi_usr_schema, qi_mview_name, ql_view_name));
END IF;

			END LOOP; -- int building installation lod4 thematic surfaces
		END LOOP; -- int building installation lod4
	END LOOP; -- int building installation

---------------------------------------------------------------
-- Create LAYER BUILDING(PART)_BUILDING_FURNITURE_LOD4
---------------------------------------------------------------
	FOR s IN 
		SELECT * FROM (VALUES
		('BuildingFurniture'::varchar, 40::integer, 'furniture'::varchar)	
		) AS t(class_name, class_id, class_label)
	LOOP
		FOR t IN 
			SELECT * FROM (VALUES
			('LoD4'::varchar, 'lod4'::varchar)
			) AS t(lodx_name, lodx_label)
		LOOP

sql_mview_count := concat('
SELECT 
	count(o.id) AS n_features
FROM 
	',qi_cdb_schema,'.building_furniture AS o
	INNER JOIN ',qi_cdb_schema,'.cityobject AS co ON (o.id = co.id AND o.objectclass_id = ',s.class_id,' ',sql_where,')
	INNER JOIN ',qi_cdb_schema,'.room AS r ON (r.id = o.room_id)
	INNER JOIN ',qi_cdb_schema,'.building AS b ON (b.id = r.building_id AND b.objectclass_id = ',r.class_id,')
WHERE
	o.',t.lodx_label,'_brep_id IS NOT NULL OR o.',t.lodx_label,'_implicit_rep_id IS NOT NULL;
');
EXECUTE sql_mview_count INTO num_features;

RAISE NOTICE 'Found % features for (%) % %', num_features, r.class_name, s.class_name, t.lodx_name;

l_name         := concat(r.class_label,'_',s.class_label,'_',t.lodx_label);
view_name      := concat(cdb_schema,'_',l_name);
mview_name     := concat('_g_',view_name);
qi_mview_name  := quote_ident(mview_name); ql_mview_name := quote_literal(mview_name);
qi_view_name   := quote_ident(view_name); ql_view_name := quote_literal(view_name);
qml_file_name  := concat('bdg_furniture_form.qml');
trig_f_suffix := 'building_furniture';

IF (num_features > 0) OR (force_layer_creation IS TRUE) THEN

--------------------
-- MATERIALIZED VIEW
--------------------
sql_layer := concat(sql_layer, qgis_pkg.generate_sql_matview_header(qi_usr_schema,qi_mview_name),'
	SELECT 
		sg.cityobject_id::bigint AS co_id,
		st_collect(qgis_pkg.ST_snap_poly_to_grid(sg.geometry,',perform_snapping,',',digits,',',area_poly_min,'))::geometry(MultiPolygonZ, ',srid_id,') AS geom
	FROM
		',qi_cdb_schema,'.building_furniture AS o
		INNER JOIN ',qi_cdb_schema,'.cityobject AS co ON (co.id = o.id AND o.objectclass_id = ',s.class_id,' ',sql_where,')
		INNER JOIN ',qi_cdb_schema,'.room AS r ON (r.id = o.room_id)
		INNER JOIN ',qi_cdb_schema,'.building AS b ON (b.id = r.building_id AND b.objectclass_id = ',r.class_id,')
		INNER JOIN ',qi_cdb_schema,'.surface_geometry AS sg ON (sg.root_id = o.',t.lodx_label,'_brep_id AND sg.geometry IS NOT NULL)
	WHERE
		o.',t.lodx_label,'_brep_id IS NOT NULL
	GROUP BY sg.cityobject_id
	UNION');
sql_layer := concat(sql_layer,'	
	SELECT
		o.id::bigint AS co_id,
		ST_SetSRID(
			ST_Translate(
				ST_Affine(ST_Collect(sg.implicit_geometry),
					split_part(',t.lodx_label,'_implicit_transformation, '' '', 1)::double precision,
					split_part(',t.lodx_label,'_implicit_transformation, '' '', 2)::double precision,
					split_part(',t.lodx_label,'_implicit_transformation, '' '', 3)::double precision,
					split_part(',t.lodx_label,'_implicit_transformation, '' '', 5)::double precision,
					split_part(',t.lodx_label,'_implicit_transformation, '' '', 6)::double precision,
					split_part(',t.lodx_label,'_implicit_transformation, '' '', 7)::double precision,
					split_part(',t.lodx_label,'_implicit_transformation, '' '', 9)::double precision,
					split_part(',t.lodx_label,'_implicit_transformation, '' '', 10)::double precision,
					split_part(',t.lodx_label,'_implicit_transformation, '' '', 11)::double precision,
					split_part(',t.lodx_label,'_implicit_transformation, '' '', 4)::double precision,
					split_part(',t.lodx_label,'_implicit_transformation, '' '', 8)::double precision,
					split_part(',t.lodx_label,'_implicit_transformation, '' '', 12)::double precision
					),
			   ST_X(o.',t.lodx_label,'_implicit_ref_point)::double precision,
			   ST_Y(o.',t.lodx_label,'_implicit_ref_point)::double precision,
			   ST_Z(o.',t.lodx_label,'_implicit_ref_point)::double precision
			),
			',srid_id,')::geometry(MultiPolygonZ, ',srid_id,') AS geom
	FROM 
		',qi_cdb_schema,'.building_furniture AS o
		INNER JOIN ',qi_cdb_schema,'.cityobject AS co ON (co.id = o.id AND o.objectclass_id = ',s.class_id,' ',sql_where,')
		INNER JOIN ',qi_cdb_schema,'.room AS r ON (r.id = o.room_id)		
		INNER JOIN ',qi_cdb_schema,'.building AS b ON (b.id = r.building_id AND b.objectclass_id = ',r.class_id,')
		INNER JOIN ',qi_cdb_schema,'.implicit_geometry AS ig ON (ig.id = o.',t.lodx_label,'_implicit_rep_id)
		INNER JOIN ',qi_cdb_schema,'.surface_geometry AS sg ON (sg.root_id = ig.relative_brep_id AND sg.implicit_geometry IS NOT NULL)
	WHERE
		o.',t.lodx_label,'_brep_id IS NULL AND o.',t.lodx_label,'_implicit_rep_id IS NOT NULL
	GROUP BY o.id
WITH NO DATA;
COMMENT ON MATERIALIZED VIEW ',qi_usr_schema,'.',qi_mview_name,' IS ''Mat. view of (',r.class_name,') ',s.class_name,' ',t.lodx_name,' in schema ',qi_cdb_schema,''';
',qgis_pkg.generate_sql_matview_footer(qi_usr_name, qi_usr_schema, qi_mview_name, ql_view_name));

-------
-- VIEW
-------
sql_layer := concat(sql_layer, qgis_pkg.generate_sql_view_header(qi_usr_schema, qi_view_name),'
SELECT',
sql_co_atts,
sql_cfu_atts,'
  o.room_id,
  r.building_id,
  g.geom::geometry(MultiPolygonZ,',srid_id,')
FROM
	',qi_usr_schema,'.',qi_mview_name,' AS g 
	INNER JOIN ',qi_cdb_schema,'.cityobject AS co ON (g.co_id = co.id AND co.objectclass_id = ',s.class_id,')
  	INNER JOIN ',qi_cdb_schema,'.building_furniture AS o ON (o.id = co.id AND o.objectclass_id = ',s.class_id,')
  	INNER JOIN ',qi_cdb_schema,'.room AS r ON (r.id = o.room_id)	
	INNER JOIN ',qi_cdb_schema,'.building AS b ON (b.id = r.building_id AND b.objectclass_id = ',r.class_id,');
COMMENT ON VIEW ',qi_usr_schema,'.',qi_view_name,' IS ''View of (',r.class_name,') ',s.class_name,' ',t.lodx_name,' in schema ',qi_cdb_schema,''';
ALTER TABLE ',qi_usr_schema,'.',qi_view_name,' OWNER TO ',qi_usr_name,';
');

-- Add triggers to make view updatable
sql_trig := concat(sql_trig,qgis_pkg.generate_sql_triggers(view_name, trig_f_suffix, usr_name, usr_schema));
-- Add entry to update table layer_metadata
sql_ins := concat(sql_ins,'
(',num_features,',',ql_cdb_schema,',''',feature_type,''',''',qml_file_name,''',''',t.lodx_label,''',''',r.class_name,''',''',l_name,''',clock_timestamp(),',ql_mview_name,',',ql_view_name,'),');
ELSE
sql_layer := concat(sql_layer, qgis_pkg.generate_sql_matview_else(qi_usr_schema, qi_mview_name, ql_view_name));
END IF;

		END LOOP; -- building furniture lod4
	END LOOP; -- building furniture
END LOOP;  -- building

-- substitute last comma with semi-colon
IF sql_ins IS NOT NULL THEN
	sql_ins := concat(sql_upd, substr(sql_ins,1, length(sql_ins)-1), ';');
END IF;
-- create the final sql statement
sql_statement := concat(sql_layer, sql_trig, sql_ins);

RETURN sql_statement;
EXCEPTION
	WHEN QUERY_CANCELED THEN
		RAISE EXCEPTION 'qgis_pkg.generate_sql_layers_building(): Error QUERY_CANCELED';
	WHEN OTHERS THEN
		RAISE EXCEPTION 'qgis_pkg.generate_sql_layers_building(): %', SQLERRM;
END;
$$ LANGUAGE plpgsql;
COMMENT ON FUNCTION qgis_pkg.generate_sql_layers_building(varchar, varchar, integer, integer, numeric, geometry, boolean) IS 'Generate SQL script to create layers for module Building';

--SELECT qgis_pkg.create_layers_building(usr_name := 'qgis_user_ro', cdb_schema := 'citydb3',
--	bbox_corners_array := NULL,  -- THIS IS THE DEFAULT
--	bbox_corners_array := ARRAY[220000, 481400, 220900, 482300],
--	bbox_corners_array := '{220177, 481471, 220755, 482133}',
--	force_layer_creation := FALSE);

--SELECT qgis_pkg.refresh_mviews_building(usr_schema := 'qgis_user_ro', cdb_schema := 'citydb3'); 
--SELECT qgis_pkg.drop_layers_building(usr_schema := 'qgis_user_ro', cdb_schema := 'citydb3'); 

--**************************
DO $MAINBODY$
DECLARE
BEGIN
RAISE NOTICE E'\n\nDone\n\n';
END $MAINBODY$;
--**************************
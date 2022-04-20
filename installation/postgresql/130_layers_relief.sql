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
-- create all layers of CityGML module "Relief". 
--
-- ***********************************************************************

----------------------------------------------------------------
-- Create FUNCTION QGIS_PKG.GENERATE_SQL_LAYERS_RELIEF
----------------------------------------------------------------
DROP FUNCTION IF EXISTS    qgis_pkg.generate_sql_layers_relief(varchar, varchar, integer, integer, numeric, geometry, boolean) CASCADE;
CREATE OR REPLACE FUNCTION qgis_pkg.generate_sql_layers_relief(
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
feature_type CONSTANT varchar := 'Relief';
usr_schema      	varchar := (SELECT qgis_pkg.create_qgis_usr_schema_name(usr_name));
srid_id         	integer := (SELECT srid FROM citydb.database_srs LIMIT 1);
usr_names_array     varchar[] := (SELECT array_agg(s.usr_name) FROM qgis_pkg.list_qgis_pkg_usrgroup_members() AS s);
usr_schemas_array 	varchar[] := (SELECT array_agg(s.usr_schema) FROM qgis_pkg.list_usr_schemas() AS s);
cdb_schemas_array 	varchar[] := (SELECT array_agg(s.cdb_schema) FROM qgis_pkg.list_cdb_schemas() AS s); 
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

IF ST_SRID(mview_bbox) IS NULL OR ST_SRID(mview_bbox) <> srid_id THEN
	sql_where := NULL;
ELSE
	sql_where := concat('AND ST_MakeEnvelope(', floor(ST_XMin(mview_bbox)),', ', floor(ST_YMin(mview_bbox)),', ', ceil(ST_XMax(mview_bbox)),', ',	ceil(ST_YMax(mview_bbox)),', ',	srid_id,') && co.envelope');
END IF;

RAISE NOTICE 'For module "%" and user "%": creating layers in usr_schema "%" for cdb_schema "%"', feature_type, qi_usr_name, qi_usr_schema, qi_cdb_schema;

sql_layer := NULL; sql_ins := NULL; sql_trig := NULL;

---------------------------------------------------------------
-- Create LAYER RELIEF_FEATURE_LOD0-4
---------------------------------------------------------------
FOR r IN 
	SELECT * FROM (VALUES
	('ReliefFeature'::varchar, 14::integer, 'relief_feat'::varchar)
	) AS t(class_name, class_id, class_label)
LOOP
	FOR t IN 
		SELECT * FROM (VALUES
		('LoD0'::varchar, 'lod0'::varchar),
		('LoD1'			, 'lod1'),
		('LoD2'			, 'lod2'),
		('LoD3'			, 'lod3'),
		('LoD4'			, 'lod4')			
		) AS t(lodx_name, lodx_label)
	LOOP

-- First check if there are any features at all in the database schema
sql_mview_count := concat('
SELECT count(o.id) AS n_features
FROM 
	',qi_cdb_schema,'.relief_feature AS o
	INNER JOIN ',qi_cdb_schema,'.cityobject AS co ON (o.id = co.id AND o.objectclass_id = ',r.class_id,' ',sql_where,')
WHERE
	o.lod = ',right(t.lodx_label,1),'
');
EXECUTE sql_mview_count INTO num_features;

RAISE NOTICE 'Found % features for % %', num_features, r.class_name, t.lodx_name;

l_name         := concat(r.class_label,'_',t.lodx_label);
view_name      := concat(cdb_schema,'_',l_name);
mview_name     := concat('_g_',view_name);
qi_mview_name  := quote_ident(mview_name); ql_mview_name := quote_literal(mview_name);
qi_view_name   := quote_ident(view_name); ql_view_name := quote_literal(view_name);
qml_file_name  := concat(r.class_label,'_form.qml');
trig_f_suffix := 'relief_feature';

IF (num_features > 0) OR (force_layer_creation IS TRUE) THEN

--------------------
-- MATERIALIZED VIEW
--------------------
sql_layer := concat(sql_layer, qgis_pkg.generate_sql_matview_header(qi_usr_schema, qi_mview_name),'
	SELECT
		o.id::bigint AS co_id,
		co.envelope::geometry(PolygonZ, ',srid_id,') AS geom	
	FROM
		',qi_cdb_schema,'.relief_feature AS o
		INNER JOIN ',qi_cdb_schema,'.cityobject AS co ON (o.id = co.id AND o.objectclass_id = ',r.class_id,' ',sql_where,')
	WHERE
		o.lod = ',right(t.lodx_label,1),'
WITH NO DATA;
COMMENT ON MATERIALIZED VIEW ',qi_usr_schema,'.',qi_mview_name,' IS ''Mat. view of ',r.class_name,' ',t.lodx_name,' in schema ',qi_cdb_schema,''';
',qgis_pkg.generate_sql_matview_footer(qi_usr_name, qi_usr_schema, qi_mview_name, ql_view_name));

-------
-- VIEW
-------
sql_layer := concat(sql_layer, qgis_pkg.generate_sql_view_header(qi_usr_schema, qi_view_name),'
SELECT',sql_co_atts,'
  o.lod,
  g.geom::geometry(PolygonZ,',srid_id,')
FROM
	',qi_usr_schema,'.',qi_mview_name,' AS g 
	INNER JOIN ',qi_cdb_schema,'.cityobject AS co ON (g.co_id = co.id AND co.objectclass_id = ',r.class_id,')
  	INNER JOIN ',qi_cdb_schema,'.relief_feature AS o ON (o.id = co.id AND o.objectclass_id = ',r.class_id,')
WHERE
	o.lod = ',right(t.lodx_label,1),';
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

	END LOOP; -- relief feature lod
END LOOP;  -- relief feature
--------------------------------------------------------
--------------------------------------------------------

---------------------------------------------------------------
-- Create LAYER TIN_RELIEF_LOD0-4
---------------------------------------------------------------
FOR r IN 
	SELECT * FROM (VALUES
	('TINRelief'::varchar, 16::integer, 'tin_relief'::varchar)
	) AS t(class_name, class_id, class_label)
LOOP
	FOR t IN 
		SELECT * FROM (VALUES
		('LoD0'::varchar, 'lod0'::varchar),
		('LoD1'			, 'lod1'),
		('LoD2'			, 'lod2'),
		('LoD3'			, 'lod3'),
		('LoD4'			, 'lod4')			
		) AS t(lodx_name, lodx_label)
	LOOP

-- First check if there are any features at all in the database schema
sql_mview_count := concat('
SELECT count(o.id) AS n_features
FROM 
	',qi_cdb_schema,'.tin_relief AS o
	INNER JOIN ',qi_cdb_schema,'.cityobject AS co ON (o.id = co.id AND o.objectclass_id = ',r.class_id,' ',sql_where,')
	INNER JOIN ',qi_cdb_schema,'.relief_component AS o2 ON (o2.id = o.id AND o2.lod = ',right(t.lodx_label,1),');
');
EXECUTE sql_mview_count INTO num_features;

RAISE NOTICE 'Found % features for % %', num_features, r.class_name, t.lodx_name;

l_name         := concat(r.class_label,'_',t.lodx_label);
view_name      := concat(cdb_schema,'_',l_name);
mview_name     := concat('_g_',view_name);
qi_mview_name  := quote_ident(mview_name); ql_mview_name := quote_literal(mview_name);
qi_view_name   := quote_ident(view_name); ql_view_name := quote_literal(view_name);
qml_file_name  := concat(r.class_label,'_form.qml');
trig_f_suffix := 'tin_relief';

IF (num_features > 0) OR (force_layer_creation IS TRUE) THEN

--------------------
-- MATERIALIZED VIEW
--------------------
sql_layer := concat(sql_layer, qgis_pkg.generate_sql_matview_header(qi_usr_schema, qi_mview_name),'
	SELECT
		sg.cityobject_id::bigint AS co_id,
		ST_Collect(qgis_pkg.ST_snap_poly_to_grid(sg.geometry,',perform_snapping,',',digits,',',area_poly_min,'))::geometry(MultiPolygonZ, ',srid_id,') AS geom	
	FROM
		',qi_cdb_schema,'.tin_relief AS o
		INNER JOIN ',qi_cdb_schema,'.cityobject AS co ON (o.id = co.id AND o.objectclass_id = ',r.class_id,' ',sql_where,')
		INNER JOIN ',qi_cdb_schema,'.relief_component AS o2 ON (o2.id = o.id AND o2.lod = ',right(t.lodx_label,1),')
		INNER JOIN ',qi_cdb_schema,'.surface_geometry AS sg ON (sg.root_id = o.surface_geometry_id AND sg.geometry IS NOT NULL) 
	GROUP BY sg.cityobject_id
WITH NO DATA;
COMMENT ON MATERIALIZED VIEW ',qi_usr_schema,'.',qi_mview_name,' IS ''Mat. view of ',r.class_name,' ',t.lodx_name,' in schema ',qi_cdb_schema,''';
',qgis_pkg.generate_sql_matview_footer(qi_usr_name, qi_usr_schema, qi_mview_name, ql_view_name));

-------
-- VIEW
-------
sql_layer := concat(sql_layer, qgis_pkg.generate_sql_view_header(qi_usr_schema, qi_view_name),'
SELECT',sql_co_atts,'
  o.lod,
  o2.max_length,
  o2.max_length_unit,  
  g.geom::geometry(MultiPolygonZ,',srid_id,')
FROM
	',qi_usr_schema,'.',qi_mview_name,' AS g 
	INNER JOIN ',qi_cdb_schema,'.cityobject AS co ON (g.co_id = co.id AND co.objectclass_id = ',r.class_id,')
	INNER JOIN ',qi_cdb_schema,'.relief_component AS o ON (o.id = co.id AND o.objectclass_id = ',r.class_id,' AND o.lod = ',right(t.lodx_label,1),')	
  	INNER JOIN ',qi_cdb_schema,'.tin_relief AS o2 ON (o2.id = co.id AND o2.objectclass_id = ',r.class_id,');
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

	END LOOP; -- tin relief lod
END LOOP;  -- tin feature
--------------------------------------------------------
--------------------------------------------------------

---------------------------------------------------------------
-- Create LAYER RASTER_RELIEF_LOD0-4
---------------------------------------------------------------
--------------------------------------------------------
--------------------------------------------------------

---------------------------------------------------------------
-- Create LAYER MASSPOINT_RELIEF_LOD0-4
---------------------------------------------------------------
--------------------------------------------------------
--------------------------------------------------------

---------------------------------------------------------------
-- Create LAYER BREAKLINE_RELIEF_LOD0-4
---------------------------------------------------------------
--------------------------------------------------------
--------------------------------------------------------

-- substitute last comma with semi-colon
IF sql_ins IS NOT NULL THEN
	sql_ins := concat(sql_upd, substr(sql_ins,1, length(sql_ins)-1), ';');
END IF;
-- create the final sql statement
sql_statement := concat(sql_layer, sql_trig, sql_ins);

RETURN sql_statement;
EXCEPTION
	WHEN QUERY_CANCELED THEN
		RAISE EXCEPTION 'qgis_pkg.generate_sql_layers_relief(): Error QUERY_CANCELED';
	WHEN OTHERS THEN
		RAISE EXCEPTION 'qgis_pkg.generate_sql_layers_relief(): %', SQLERRM;
END;
$$ LANGUAGE plpgsql;
COMMENT ON FUNCTION qgis_pkg.generate_sql_layers_relief(varchar, varchar, integer, integer, numeric, geometry, boolean) IS 'Generate SQL script to create layers for module LandUse';

--SELECT qgis_pkg.create_layers_relief(usr_name := 'qgis_user_ro', cdb_schema := 'citydb3',
--	cdb_schema         := 'citydb3',
--	bbox_corners_array := NULL,  -- THIS IS THE DEFAULT
--	bbox_corners_array := ARRAY[220000, 481400, 220900, 482300],
--	bbox_corners_array := '{220177, 481471, 220755, 482133}',
--	force_layer_creation := FALSE);

--SELECT qgis_pkg.refresh_mviews_relief(usr_schema := 'qgis_user_ro', cdb_schema := 'citydb3'); 
--SELECT qgis_pkg.drop_layers_relief(usr_schema := 'qgis_user_ro', cdb_schema := 'citydb3'); 

--**************************
DO $MAINBODY$
DECLARE
BEGIN
RAISE NOTICE E'\n\nDone\n\n';
END $MAINBODY$;
--**************************
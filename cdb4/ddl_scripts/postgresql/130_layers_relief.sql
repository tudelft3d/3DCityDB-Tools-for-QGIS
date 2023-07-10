-- ***********************************************************************
--
--      QGIS Package for the CityGML 3D City Database (for PostgreSQL)
--
--
--                        Copyright 2023
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
feature_type		CONSTANT varchar := 'Relief';
l_type				CONSTANT varchar := 'VectorLayer';
qgis_user_group_name CONSTANT varchar := (SELECT qgis_pkg.create_qgis_pkg_usrgroup_name());
usr_schema      	CONSTANT varchar := (SELECT qgis_pkg.create_qgis_usr_schema_name(usr_name));
usr_names_array     CONSTANT varchar[] := (SELECT array_agg(s.usr_name) FROM qgis_pkg.list_qgis_pkg_usrgroup_members() AS s);
usr_schemas_array 	CONSTANT varchar[] := (SELECT array_agg(s.usr_schema) FROM qgis_pkg.list_usr_schemas() AS s);
cdb_schemas_array 	CONSTANT varchar[] := (SELECT array_agg(s.cdb_schema) FROM qgis_pkg.list_cdb_schemas() AS s); 
srid                integer;
num_features    	bigint;
root_class			varchar; curr_class varchar;
ql_feature_type varchar := quote_literal(feature_type);
ql_l_type varchar := quote_literal(l_type);
qi_cdb_schema varchar; ql_cdb_schema varchar;
qi_usr_schema varchar; ql_usr_schema varchar;
qi_usr_name varchar; ql_usr_name varchar;
l_name varchar; ql_l_name varchar; qi_l_name varchar;
--av_name varchar; ql_av_name varchar; qi_av_name varchar;
gv_name varchar; qi_gv_name varchar; ql_gv_name varchar;
qml_form_name 	varchar := NULL;
qml_symb_name 	varchar := NULL;
qml_3d_name 	varchar := NULL;
trig_f_suffix   varchar := NULL;
r RECORD; s RECORD; t RECORD; u RECORD;
sql_feat_count	text := NULL;
sql_where 		text := NULL;
sql_upd			text := NULL;
sql_ins			text := NULL;
sql_trig		text := NULL;
sql_layer	 	text := NULL;
sql_statement	text := NULL;

co_enum_cols_array	varchar[][] := ARRAY[['cityobject', 'relative_to_terrain'],['cityobject', 'relative_to_water']];
codelist_cols_array	varchar[][] = NULL;

sql_co_atts CONSTANT varchar := '
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
	RAISE EXCEPTION 'usr_name is invalid. It must be an existing database user AND member of role (group) "%"', qgis_user_group_name;
END IF;

-- Check if the usr_schema exists (must habe been created before)
-- No need to check if it is NULL.
IF NOT usr_schema = ANY(usr_schemas_array) THEN
	RAISE EXCEPTION 'usr_schema "%" does not exist. Please create it beforehand', usr_schema;
END IF;

-- Check if the cdb_schema exists
IF (cdb_schema IS NULL) OR (NOT cdb_schema = ANY(cdb_schemas_array)) THEN
	RAISE EXCEPTION 'cdb_schema "%" is invalid. It must correspond to an existing citydb schema', cdb_schema;
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
DELETE FROM ',qi_usr_schema,'.layer_metadata AS l WHERE l.cdb_schema = ',ql_cdb_schema,' AND l.layer_type = ',ql_l_type,' AND l.feature_type = ',ql_feature_type,';
INSERT INTO ',qi_usr_schema,'.layer_metadata 
(cdb_schema, layer_type, feature_type, root_class, class, lod, layer_name, gv_name, n_features, creation_date, qml_form, qml_symb, qml_3d, enum_cols, codelist_cols)
VALUES');

-- Get the srid from the cdb_schema
EXECUTE format('SELECT srid FROM %I.database_srs LIMIT 1', cdb_schema) INTO srid;

-- Check that the srid is the same if the mview_box
IF ST_SRID(mview_bbox) IS NULL OR ST_SRID(mview_bbox) <> srid THEN
	sql_where := NULL;
ELSE
	sql_where := concat('AND ST_MakeEnvelope(',ST_XMin(mview_bbox),',',ST_YMin(mview_bbox),',',ST_XMax(mview_bbox),',',ST_YMax(mview_bbox),',',srid,') && co.envelope');
END IF;

RAISE NOTICE 'For module "%" and user "%": creating layers in usr_schema "%" for cdb_schema "%"', feature_type, qi_usr_name, qi_usr_schema, qi_cdb_schema;

sql_layer := NULL; sql_ins := NULL; sql_trig := NULL;

root_class := 'ReliefFeature';
---------------------------------------------------------------
-- Create LAYER RELIEF_FEATURE_LOD0-4
---------------------------------------------------------------
FOR r IN 
	SELECT * FROM (VALUES
	('ReliefFeature'::varchar, qgis_pkg.class_name_to_class_id(cdb_schema, 'ReliefFeature', NULL)::integer, 'rel_feat'::varchar)
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
sql_feat_count := concat('
SELECT count(o.id) AS n_features
FROM 
	',qi_cdb_schema,'.relief_feature AS o
	INNER JOIN ',qi_cdb_schema,'.cityobject AS co ON (o.id = co.id AND o.objectclass_id = ',r.class_id,' ',sql_where,')
WHERE
	o.lod = ',right(t.lodx_label,1),'
');
EXECUTE sql_feat_count INTO num_features;

RAISE NOTICE 'Found % features for % %', num_features, r.class_name, t.lodx_name;

curr_class := r.class_name;
l_name			:= concat(cdb_schema,'_',r.class_label,'_',t.lodx_label);
--av_name			:= concat('_a_',cdb_schema,'_rel_feat');
gv_name			:= concat('_g_',l_name);
qml_form_name  := 'rel_feat_form.qml';
qml_symb_name  := 'poly_dark_green_semi_transp_symb.qml';
qml_3d_name    := 'poly_dark_green_semi_transp_3d.qml';
trig_f_suffix := 'relief_feature';
qi_l_name  := quote_ident(l_name); ql_l_name := quote_literal(l_name);
qi_gv_name  := quote_ident(gv_name); ql_gv_name := quote_literal(gv_name);
--qi_av_name   := quote_ident(av_name); ql_av_name := quote_literal(av_name);

IF (num_features > 0) OR (force_layer_creation IS TRUE) THEN

--------------------
-- MATERIALIZED VIEW (for geom)
--------------------
sql_layer := concat(sql_layer, qgis_pkg.generate_sql_matview_header(qi_usr_schema, qi_gv_name),'
	SELECT
		o.id::bigint AS co_id,
		co.envelope::geometry(PolygonZ, ',srid,') AS geom	
	FROM
		',qi_cdb_schema,'.relief_feature AS o
		INNER JOIN ',qi_cdb_schema,'.cityobject AS co ON (o.id = co.id AND o.objectclass_id = ',r.class_id,' ',sql_where,')
	WHERE
		o.lod = ',right(t.lodx_label,1),'
WITH NO DATA;
COMMENT ON MATERIALIZED VIEW ',qi_usr_schema,'.',qi_gv_name,' IS ''Mat. view of ',r.class_name,' ',t.lodx_name,' in schema ',qi_cdb_schema,''';
',qgis_pkg.generate_sql_matview_footer(qi_usr_name, qi_usr_schema, ql_l_name, qi_gv_name));

-------
--  VIEW (for atts + geom)
-------
sql_layer := concat(sql_layer, qgis_pkg.generate_sql_view_header(qi_usr_schema, qi_l_name),'
SELECT',sql_co_atts,'
  o.lod,
  g.geom::geometry(PolygonZ,',srid,')
FROM
	',qi_usr_schema,'.',qi_gv_name,' AS g 
	INNER JOIN ',qi_cdb_schema,'.cityobject AS co ON (g.co_id = co.id AND co.objectclass_id = ',r.class_id,')
  	INNER JOIN ',qi_cdb_schema,'.relief_feature AS o ON (o.id = co.id AND o.objectclass_id = ',r.class_id,')
WHERE
	o.lod = ',right(t.lodx_label,1),';
COMMENT ON VIEW ',qi_usr_schema,'.',qi_l_name,' IS ''View of ',r.class_name,' ',t.lodx_name,' in schema ',qi_cdb_schema,''';
ALTER TABLE ',qi_usr_schema,'.',qi_l_name,' OWNER TO ',qi_usr_name,';
');

-- Add triggers to make view updatable
sql_trig := concat(sql_trig,qgis_pkg.generate_sql_triggers(usr_schema, l_name, trig_f_suffix));
-- Add entry to update table layer_metadata
sql_ins := concat(sql_ins,'
(',ql_cdb_schema,',',ql_l_type,',',ql_feature_type,',',quote_literal(root_class),',',quote_literal(curr_class),',',quote_literal(t.lodx_label),',',ql_l_name,',',ql_gv_name,',',num_features,',clock_timestamp(),',quote_literal(qml_form_name),',',quote_literal(qml_symb_name),',',quote_literal(qml_3d_name),',',quote_nullable(co_enum_cols_array),',',quote_nullable(codelist_cols_array),'),');

ELSE
sql_layer := concat(sql_layer, qgis_pkg.generate_sql_matview_else(qi_usr_schema, ql_cdb_schema, ql_l_type, ql_l_name, qi_gv_name));
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
	('TINRelief'::varchar, qgis_pkg.class_name_to_class_id(cdb_schema, 'TINRelief', NULL)::integer, 'rel_tin'::varchar)
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
sql_feat_count := concat('
SELECT count(o.id) AS n_features
FROM 
	',qi_cdb_schema,'.tin_relief AS o
	INNER JOIN ',qi_cdb_schema,'.cityobject AS co ON (o.id = co.id AND o.objectclass_id = ',r.class_id,' ',sql_where,')
	INNER JOIN ',qi_cdb_schema,'.relief_component AS o2 ON (o2.id = o.id AND o2.lod = ',right(t.lodx_label,1),');
');
EXECUTE sql_feat_count INTO num_features;

RAISE NOTICE 'Found % features for % %', num_features, r.class_name, t.lodx_name;

curr_class := r.class_name;
l_name			:= concat(cdb_schema,'_',r.class_label,'_',t.lodx_label);
--av_name			:= concat('_a_',cdb_schema,'_rel_tin');
gv_name			:= concat('_g_',l_name);
qml_form_name  := 'rel_tin_form.qml';
qml_symb_name  := 'poly_dark_green_symb.qml';
qml_3d_name    := 'poly_dark_green_3d.qml';
trig_f_suffix := 'tin_relief';
qi_l_name  := quote_ident(l_name); ql_l_name := quote_literal(l_name);
qi_gv_name  := quote_ident(gv_name); ql_gv_name := quote_literal(gv_name);
--qi_av_name   := quote_ident(av_name); ql_av_name := quote_literal(av_name);

IF (num_features > 0) OR (force_layer_creation IS TRUE) THEN

--------------------
-- MATERIALIZED VIEW (for geom)
--------------------
sql_layer := concat(sql_layer, qgis_pkg.generate_sql_matview_header(qi_usr_schema, qi_gv_name),'
	SELECT
		sg.cityobject_id::bigint AS co_id,
		ST_Collect(qgis_pkg.ST_snap_poly_to_grid(sg.geometry,',perform_snapping,',',digits,',',area_poly_min,'))::geometry(MultiPolygonZ, ',srid,') AS geom	
	FROM
		',qi_cdb_schema,'.tin_relief AS o
		INNER JOIN ',qi_cdb_schema,'.cityobject AS co ON (o.id = co.id AND o.objectclass_id = ',r.class_id,' ',sql_where,')
		INNER JOIN ',qi_cdb_schema,'.relief_component AS o2 ON (o2.id = o.id AND o2.lod = ',right(t.lodx_label,1),')
		INNER JOIN ',qi_cdb_schema,'.surface_geometry AS sg ON (sg.root_id = o.surface_geometry_id AND sg.geometry IS NOT NULL) 
	GROUP BY sg.cityobject_id
WITH NO DATA;
COMMENT ON MATERIALIZED VIEW ',qi_usr_schema,'.',qi_gv_name,' IS ''Mat. view of ',r.class_name,' ',t.lodx_name,' in schema ',qi_cdb_schema,''';
',qgis_pkg.generate_sql_matview_footer(qi_usr_name, qi_usr_schema, ql_l_name, qi_gv_name));

-------
--  VIEW (for atts + geom)
-------
sql_layer := concat(sql_layer, qgis_pkg.generate_sql_view_header(qi_usr_schema, qi_l_name),'
SELECT',sql_co_atts,'
  o.lod,
  o2.max_length,
  o2.max_length_unit,  
  g.geom::geometry(MultiPolygonZ,',srid,')
FROM
	',qi_usr_schema,'.',qi_gv_name,' AS g 
	INNER JOIN ',qi_cdb_schema,'.cityobject AS co ON (g.co_id = co.id AND co.objectclass_id = ',r.class_id,')
	INNER JOIN ',qi_cdb_schema,'.relief_component AS o ON (o.id = co.id AND o.objectclass_id = ',r.class_id,' AND o.lod = ',right(t.lodx_label,1),')	
  	INNER JOIN ',qi_cdb_schema,'.tin_relief AS o2 ON (o2.id = co.id AND o2.objectclass_id = ',r.class_id,');
COMMENT ON VIEW ',qi_usr_schema,'.',qi_l_name,' IS ''View of ',r.class_name,' ',t.lodx_name,' in schema ',qi_cdb_schema,''';
ALTER TABLE ',qi_usr_schema,'.',qi_l_name,' OWNER TO ',qi_usr_name,';
');

-- Add triggers to make view updatable
sql_trig := concat(sql_trig,qgis_pkg.generate_sql_triggers(usr_schema, l_name, trig_f_suffix));
-- Add entry to update table layer_metadata
sql_ins := concat(sql_ins,'
(',ql_cdb_schema,',',ql_l_type,',',ql_feature_type,',',quote_literal(root_class),',',quote_literal(curr_class),',',quote_literal(t.lodx_label),',',ql_l_name,',',ql_gv_name,',',num_features,',clock_timestamp(),',quote_literal(qml_form_name),',',quote_literal(qml_symb_name),',',quote_literal(qml_3d_name),',',quote_nullable(co_enum_cols_array),',',quote_nullable(codelist_cols_array),'),');

ELSE
sql_layer := concat(sql_layer, qgis_pkg.generate_sql_matview_else(qi_usr_schema, ql_cdb_schema, ql_l_type, ql_l_name, qi_gv_name));
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
FOR r IN 
	SELECT * FROM (VALUES
	('MassPointRelief'::varchar, qgis_pkg.class_name_to_class_id(cdb_schema, 'MassPointRelief', NULL)::integer, 'rel_masspoint'::varchar)
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
sql_feat_count := concat('
SELECT count(o.id) AS n_features
FROM 
	',qi_cdb_schema,'.masspoint_relief AS o
	INNER JOIN ',qi_cdb_schema,'.cityobject AS co ON (o.id = co.id AND o.objectclass_id = ',r.class_id,' ',sql_where,')
	INNER JOIN ',qi_cdb_schema,'.relief_component AS o2 ON (o2.id = o.id AND o2.lod = ',right(t.lodx_label,1),');
');
EXECUTE sql_feat_count INTO num_features;

RAISE NOTICE 'Found % features for % %', num_features, r.class_name, t.lodx_name;

curr_class := r.class_name;
l_name			:= concat(cdb_schema,'_',r.class_label,'_',t.lodx_label);
--av_name			:= concat('_a_',cdb_schema,'_rel_masspoint');
gv_name			:= concat('_g_',l_name);
qml_form_name  := 'rel_masspoint_form.qml';
qml_symb_name  := 'point_black_symb.qml';
qml_3d_name    := 'point_black_3d.qml';
trig_f_suffix := 'masspoint_relief';
qi_l_name  := quote_ident(l_name); ql_l_name := quote_literal(l_name);
qi_gv_name  := quote_ident(gv_name); ql_gv_name := quote_literal(gv_name);
--qi_av_name   := quote_ident(av_name); ql_av_name := quote_literal(av_name);

IF (num_features > 0) OR (force_layer_creation IS TRUE) THEN

--------------------
-- MATERIALIZED VIEW (for geom)
--------------------
sql_layer := concat(sql_layer, qgis_pkg.generate_sql_matview_header(qi_usr_schema, qi_gv_name),'
	SELECT
		o.id::bigint AS co_id,
		o.relief_points::geometry(MultiPointZ, ',srid,') AS geom	
	FROM
		',qi_cdb_schema,'.masspoint_relief AS o
		INNER JOIN ',qi_cdb_schema,'.cityobject AS co ON (o.id = co.id AND o.objectclass_id = ',r.class_id,' ',sql_where,')
		INNER JOIN ',qi_cdb_schema,'.relief_component AS o2 ON (o2.id = o.id AND o2.lod = ',right(t.lodx_label,1),')
WITH NO DATA;
COMMENT ON MATERIALIZED VIEW ',qi_usr_schema,'.',qi_gv_name,' IS ''Mat. view of ',r.class_name,' ',t.lodx_name,' in schema ',qi_cdb_schema,''';
',qgis_pkg.generate_sql_matview_footer(qi_usr_name, qi_usr_schema, ql_l_name, qi_gv_name));

-------
--  VIEW (for atts + geom)
-------
sql_layer := concat(sql_layer, qgis_pkg.generate_sql_view_header(qi_usr_schema, qi_l_name),'
SELECT',sql_co_atts,'
  o.lod,
  g.geom::geometry(MultiPointZ,',srid,')
FROM
	',qi_usr_schema,'.',qi_gv_name,' AS g 
	INNER JOIN ',qi_cdb_schema,'.cityobject AS co ON (g.co_id = co.id AND co.objectclass_id = ',r.class_id,')
	INNER JOIN ',qi_cdb_schema,'.relief_component AS o ON (o.id = co.id AND o.objectclass_id = ',r.class_id,' AND o.lod = ',right(t.lodx_label,1),')	
  	INNER JOIN ',qi_cdb_schema,'.masspoint_relief AS o2 ON (o2.id = co.id AND o2.objectclass_id = ',r.class_id,');
COMMENT ON VIEW ',qi_usr_schema,'.',qi_l_name,' IS ''View of ',r.class_name,' ',t.lodx_name,' in schema ',qi_cdb_schema,''';
ALTER TABLE ',qi_usr_schema,'.',qi_l_name,' OWNER TO ',qi_usr_name,';
');

-- Add triggers to make view updatable
sql_trig := concat(sql_trig,qgis_pkg.generate_sql_triggers(usr_schema, l_name, trig_f_suffix));
-- Add entry to update table layer_metadata
sql_ins := concat(sql_ins,'
(',ql_cdb_schema,',',ql_l_type,',',ql_feature_type,',',quote_literal(root_class),',',quote_literal(curr_class),',',quote_literal(t.lodx_label),',',ql_l_name,',',ql_gv_name,',',num_features,',clock_timestamp(),',quote_literal(qml_form_name),',',quote_literal(qml_symb_name),',',quote_literal(qml_3d_name),',',quote_nullable(co_enum_cols_array),',',quote_nullable(codelist_cols_array),'),');

ELSE
sql_layer := concat(sql_layer, qgis_pkg.generate_sql_matview_else(qi_usr_schema, ql_cdb_schema, ql_l_type, ql_l_name, qi_gv_name));
END IF;

	END LOOP; -- masspoint relief lod
END LOOP;  -- masspoint relief feature
--------------------------------------------------------
--------------------------------------------------------

---------------------------------------------------------------
-- Create LAYER BREAKLINE_RELIEF_LOD0-4
---------------------------------------------------------------
FOR r IN 
	SELECT * FROM (VALUES
	('BreaklineRelief'::varchar, qgis_pkg.class_name_to_class_id(cdb_schema, 'BreaklineRelief', NULL)::integer, 'rel_breakline'::varchar)
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
sql_feat_count := concat('
SELECT count(o.id) AS n_features
FROM 
	',qi_cdb_schema,'.breakline_relief AS o
	INNER JOIN ',qi_cdb_schema,'.cityobject AS co ON (o.id = co.id AND o.objectclass_id = ',r.class_id,' ',sql_where,')
	INNER JOIN ',qi_cdb_schema,'.relief_component AS o2 ON (o2.id = o.id AND o2.lod = ',right(t.lodx_label,1),')
WHERE o.ridge_or_valley_lines IS NOT NULL OR o.break_lines IS NOT NULL;
');
EXECUTE sql_feat_count INTO num_features;

RAISE NOTICE 'Found % features for % %', num_features, r.class_name, t.lodx_name;

curr_class := r.class_name;
l_name			:= concat(cdb_schema,'_',r.class_label,'_',t.lodx_label);
--av_name			:= concat('_a_',cdb_schema,'_rel_breakline');
gv_name			:= concat('_g_',l_name);
qml_form_name  := 'rel_breakline_form.qml';
qml_symb_name  := 'line_black_symb.qml';
qml_3d_name    := 'line_black_3d.qml';
trig_f_suffix := 'breakline_relief';
qi_l_name  := quote_ident(l_name); ql_l_name := quote_literal(l_name);
qi_gv_name  := quote_ident(gv_name); ql_gv_name := quote_literal(gv_name);
--qi_av_name   := quote_ident(av_name); ql_av_name := quote_literal(av_name);

IF (num_features > 0) OR (force_layer_creation IS TRUE) THEN

--------------------
-- MATERIALIZED VIEW (for geom)
--------------------
sql_layer := concat(sql_layer, qgis_pkg.generate_sql_matview_header(qi_usr_schema, qi_gv_name),'
	SELECT
		foo.co_id::bigint,
		ST_Union(foo.geom)::geometry(MultiLineStringZ,',srid,') AS geom
	FROM (
		SELECT
			o.id::bigint AS co_id,
			o.break_lines AS geom	
		FROM
			',qi_cdb_schema,'.breakline_relief AS o
			INNER JOIN ',qi_cdb_schema,'.cityobject AS co ON (o.id = co.id AND o.objectclass_id = ',r.class_id,' ',sql_where,')
			INNER JOIN ',qi_cdb_schema,'.relief_component AS o2 ON (o2.id = o.id AND o2.lod = ',right(t.lodx_label,1),')
		WHERE o.break_lines IS NOT NULL
		UNION
		SELECT
			o.id::bigint AS co_id,
			o.ridge_or_valley_lines AS geom	
		FROM
			',qi_cdb_schema,'.breakline_relief AS o
			INNER JOIN ',qi_cdb_schema,'.cityobject AS co ON (o.id = co.id AND o.objectclass_id = ',r.class_id,' ',sql_where,')
			INNER JOIN ',qi_cdb_schema,'.relief_component AS o2 ON (o2.id = o.id AND o2.lod = ',right(t.lodx_label,1),')
		WHERE o.ridge_or_valley_lines IS NOT NULL
		) AS foo
	GROUP BY foo.co_id
WITH NO DATA;
COMMENT ON MATERIALIZED VIEW ',qi_usr_schema,'.',qi_gv_name,' IS ''Mat. view of ',r.class_name,' ',t.lodx_name,' in schema ',qi_cdb_schema,''';
',qgis_pkg.generate_sql_matview_footer(qi_usr_name, qi_usr_schema, ql_l_name, qi_gv_name));

-------
--  VIEW (for atts + geom)
-------
sql_layer := concat(sql_layer, qgis_pkg.generate_sql_view_header(qi_usr_schema, qi_l_name),'
SELECT',sql_co_atts,'
  o.lod,
  g.geom::geometry(MultiLineStringZ,',srid,')
FROM
	',qi_usr_schema,'.',qi_gv_name,' AS g 
	INNER JOIN ',qi_cdb_schema,'.cityobject AS co ON (g.co_id = co.id AND co.objectclass_id = ',r.class_id,')
	INNER JOIN ',qi_cdb_schema,'.relief_component AS o ON (o.id = co.id AND o.objectclass_id = ',r.class_id,' AND o.lod = ',right(t.lodx_label,1),')	
  	INNER JOIN ',qi_cdb_schema,'.breakline_relief AS o2 ON (o2.id = co.id AND o2.objectclass_id = ',r.class_id,')
	WHERE o2.ridge_or_valley_lines IS NOT NULL OR o2.break_lines IS NOT NULL;
COMMENT ON VIEW ',qi_usr_schema,'.',qi_l_name,' IS ''View of ',r.class_name,' ',t.lodx_name,' in schema ',qi_cdb_schema,''';
ALTER TABLE ',qi_usr_schema,'.',qi_l_name,' OWNER TO ',qi_usr_name,';
');

-- Add triggers to make view updatable
sql_trig := concat(sql_trig,qgis_pkg.generate_sql_triggers(usr_schema, l_name, trig_f_suffix));
-- Add entry to update table layer_metadata
sql_ins := concat(sql_ins,'
(',ql_cdb_schema,',',ql_l_type,',',ql_feature_type,',',quote_literal(root_class),',',quote_literal(curr_class),',',quote_literal(t.lodx_label),',',ql_l_name,',',ql_gv_name,',',num_features,',clock_timestamp(),',quote_literal(qml_form_name),',',quote_literal(qml_symb_name),',',quote_literal(qml_3d_name),',',quote_nullable(co_enum_cols_array),',',quote_nullable(codelist_cols_array),'),');

ELSE
sql_layer := concat(sql_layer, qgis_pkg.generate_sql_matview_else(qi_usr_schema, ql_cdb_schema, ql_l_type, ql_l_name, qi_gv_name));
END IF;

		FOR u IN 
			SELECT * FROM (VALUES
			('break_lines'::varchar	, 'break_lines'::varchar),
			('ridge_or_valley_lines', 'ridge_or_valley_lines')   
			) AS t(break_line_name, break_line_label)
		LOOP

-- First check if there are any features at all in the database schema
sql_feat_count := concat('
SELECT count(o.id) AS n_features
FROM 
	',qi_cdb_schema,'.breakline_relief AS o
	INNER JOIN ',qi_cdb_schema,'.cityobject AS co ON (o.id = co.id AND o.objectclass_id = ',r.class_id,' ',sql_where,')
	INNER JOIN ',qi_cdb_schema,'.relief_component AS o2 ON (o2.id = o.id AND o2.lod = ',right(t.lodx_label,1),')
WHERE o.',u.break_line_name,' IS NOT NULL;
');
EXECUTE sql_feat_count INTO num_features;

RAISE NOTICE 'Found % features for % % %', num_features, r.class_name, t.lodx_name, u.break_line_name;

curr_class := r.class_name;
l_name			:= concat(cdb_schema,'_',r.class_label,'_',t.lodx_label,'_',u.break_line_label);
--av_name			:= concat('_a_',cdb_schema,'_rel_breakline');
gv_name			:= concat('_g_',l_name);
qml_form_name  := 'rel_breakline_form.qml';
qml_symb_name  := 'line_black_symb.qml';
qml_3d_name    := 'line_black_3d.qml';
trig_f_suffix := 'breakline_relief';
qi_l_name  := quote_ident(l_name); ql_l_name := quote_literal(l_name);
qi_gv_name  := quote_ident(gv_name); ql_gv_name := quote_literal(gv_name);
--qi_av_name   := quote_ident(av_name); ql_av_name := quote_literal(av_name);

IF (num_features > 0) OR (force_layer_creation IS TRUE) THEN

--------------------
-- MATERIALIZED VIEW (for geom)
--------------------
sql_layer := concat(sql_layer, qgis_pkg.generate_sql_matview_header(qi_usr_schema, qi_gv_name),'
SELECT
	o.id::bigint AS co_id,
	o.',u.break_line_name,'::geometry(MultiLineStringZ, ',srid,') AS geom	
FROM
	',qi_cdb_schema,'.breakline_relief AS o
	INNER JOIN ',qi_cdb_schema,'.cityobject AS co ON (o.id = co.id AND o.objectclass_id = ',r.class_id,' ',sql_where,')
	INNER JOIN ',qi_cdb_schema,'.relief_component AS o2 ON (o2.id = o.id AND o2.lod = ',right(t.lodx_label,1),')
WHERE o.',u.break_line_name,' IS NOT NULL
WITH NO DATA;
COMMENT ON MATERIALIZED VIEW ',qi_usr_schema,'.',qi_gv_name,' IS ''Mat. view of ',r.class_name,' ',t.lodx_name,' ',u.break_line_label,' in schema ',qi_cdb_schema,''';
',qgis_pkg.generate_sql_matview_footer(qi_usr_name, qi_usr_schema, ql_l_name, qi_gv_name));

-------
--  VIEW (for atts + geom)
-------
sql_layer := concat(sql_layer, qgis_pkg.generate_sql_view_header(qi_usr_schema, qi_l_name),'
SELECT',sql_co_atts,'
  o.lod,
  g.geom::geometry(MultiLineStringZ,',srid,')
FROM
	',qi_usr_schema,'.',qi_gv_name,' AS g 
	INNER JOIN ',qi_cdb_schema,'.cityobject AS co ON (g.co_id = co.id AND co.objectclass_id = ',r.class_id,')
	INNER JOIN ',qi_cdb_schema,'.relief_component AS o ON (o.id = co.id AND o.objectclass_id = ',r.class_id,' AND o.lod = ',right(t.lodx_label,1),')	
  	INNER JOIN ',qi_cdb_schema,'.breakline_relief AS o2 ON (o2.id = co.id AND o2.objectclass_id = ',r.class_id,')
	WHERE o2.',u.break_line_name,' IS NOT NULL;
COMMENT ON VIEW ',qi_usr_schema,'.',qi_l_name,' IS ''View of ',r.class_name,' ',t.lodx_name,' ',u.break_line_label,' in schema ',qi_cdb_schema,''';
ALTER TABLE ',qi_usr_schema,'.',qi_l_name,' OWNER TO ',qi_usr_name,';
');

-- Add triggers to make view updatable
sql_trig := concat(sql_trig,qgis_pkg.generate_sql_triggers(usr_schema, l_name, trig_f_suffix));
-- Add entry to update table layer_metadata
sql_ins := concat(sql_ins,'
(',ql_cdb_schema,',',ql_l_type,',',ql_feature_type,',',quote_literal(root_class),',',quote_literal(curr_class),',',quote_literal(t.lodx_label),',',ql_l_name,',',ql_gv_name,',',num_features,',clock_timestamp(),',quote_literal(qml_form_name),',',quote_literal(qml_symb_name),',',quote_literal(qml_3d_name),',',quote_nullable(co_enum_cols_array),',',quote_nullable(codelist_cols_array),'),');

ELSE
sql_layer := concat(sql_layer, qgis_pkg.generate_sql_matview_else(qi_usr_schema, ql_cdb_schema, ql_l_type, ql_l_name, qi_gv_name));
END IF;

		END LOOP; -- loop break_lines or ridge_or_valley_lines

	END LOOP; -- breakline relief lod
END LOOP;  -- breakline relief feature

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
COMMENT ON FUNCTION qgis_pkg.generate_sql_layers_relief(varchar, varchar, integer, integer, numeric, geometry, boolean) IS 'Generate SQL script to create layers for module Relief';
REVOKE EXECUTE ON FUNCTION qgis_pkg.generate_sql_layers_relief(varchar, varchar, integer, integer, numeric, geometry, boolean) FROM public;


--**************************
DO $MAINBODY$
DECLARE
BEGIN
RAISE NOTICE E'\n\nDone\n\n';
END $MAINBODY$;
--**************************
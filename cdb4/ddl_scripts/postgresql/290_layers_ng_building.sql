--***********************************************************************
--
--      QGIS Package for the CityGML 3D City Database (for PostgreSQL)
--
--
--                        Copyright 2022
--
-- Delft University of Technology, The Netherlands
-- 3D Geoinformation Group
-- https://3d.bk.tudelft.nl
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
-- Author: Tendai Mbwanda
-- 	   MSc Geomatics
--	   Delft University of Technology, The Netherlands
-- 
--
-- ***********************************************************************
--
-- This script installs a function that generates the SQL script to
-- create all layers of CityGML module "Building". 
--
-- ***********************************************************************
DROP FUNCTION IF EXISTS qgis_pkg.create_qgis_pkg_usrgroup_name() CASCADE;
CREATE OR REPLACE FUNCTION qgis_pkg.create_qgis_pkg_usrgroup_name(
	)
    RETURNS character varying
    LANGUAGE 'plpgsql'
    COST 100
    VOLATILE PARALLEL UNSAFE
AS $BODY$
DECLARE
qgis_pkg_usrgroup_prefix CONSTANT varchar := 'qgis_pkg_usrgroup_';
qgis_pkg_usrgroup_name varchar; 

BEGIN
qgis_pkg_usrgroup_name := concat(qgis_pkg_usrgroup_prefix, current_database());

RETURN qgis_pkg_usrgroup_name;

EXCEPTION
	WHEN QUERY_CANCELED THEN
		RAISE EXCEPTION 'qgis_pkg.create_qgis_pkg_usrgroup_name(): Error QUERY_CANCELED';
  WHEN OTHERS THEN 
		RAISE NOTICE 'qgis_pkg.create_qgis_pkg_usrgroup_name(): %', SQLERRM;
END;
$BODY$;

ALTER FUNCTION qgis_pkg.create_qgis_pkg_usrgroup_name()
    OWNER TO postgres;

GRANT EXECUTE ON FUNCTION qgis_pkg.create_qgis_pkg_usrgroup_name() TO postgres;

REVOKE ALL ON FUNCTION qgis_pkg.create_qgis_pkg_usrgroup_name() FROM PUBLIC;

COMMENT ON FUNCTION qgis_pkg.create_qgis_pkg_usrgroup_name()
    IS 'Creates the name of the qgis_pkg database group for the current database';


DROP FUNCTION IF EXISTS qgis_pkg.list_qgis_pkg_usrgroup_members() CASCADE;
CREATE OR REPLACE FUNCTION qgis_pkg.list_qgis_pkg_usrgroup_members(
	)
    RETURNS TABLE(usr_name character varying) 
    LANGUAGE 'plpgsql'
    COST 100
    VOLATILE PARALLEL UNSAFE
    ROWS 1000

AS $BODY$
DECLARE
qgis_pkg_usrgroup_name CONSTANT varchar := (SELECT qgis_pkg.create_qgis_pkg_usrgroup_name());

BEGIN

RETURN QUERY
	SELECT i.grantee::varchar AS usr_name
	FROM information_schema.applicable_roles AS i
	WHERE quote_ident(i.role_name) = quote_ident(qgis_pkg_usrgroup_name)
	ORDER BY i.grantee ASC;

EXCEPTION
	WHEN QUERY_CANCELED THEN
		RAISE EXCEPTION 'qgis_pkg.list_qgis_pkg_usrgroup_members(): Error QUERY_CANCELED';
  WHEN OTHERS THEN 
		RAISE NOTICE 'qgis_pkg.list_qgis_pkg_usrgroup_members(): %', SQLERRM;
END;
$BODY$;

ALTER FUNCTION qgis_pkg.list_qgis_pkg_usrgroup_members()
    OWNER TO postgres;

GRANT EXECUTE ON FUNCTION qgis_pkg.list_qgis_pkg_usrgroup_members() TO postgres;

REVOKE ALL ON FUNCTION qgis_pkg.list_qgis_pkg_usrgroup_members() FROM PUBLIC;

COMMENT ON FUNCTION qgis_pkg.list_qgis_pkg_usrgroup_members()
    IS 'List all database users that belong to the group (''qgis_pkg_usrgroup_*'') assigned to the current database';

----------------------------------------------------------------
-- Create FUNCTION QGIS_PKG.GENERATE_SQL_LAYERS_BUILDING
----------------------------------------------------------------
DROP FUNCTION IF EXISTS    qgis_pkg.generate_sql_layers_ng_building(varchar, varchar, integer, integer, numeric, geometry, boolean, varchar) CASCADE;
CREATE OR REPLACE FUNCTION qgis_pkg.generate_sql_layers_ng_building(usr_name varchar,cdb_schema	varchar,perform_snapping integer,digits integer,
								    area_poly_min numeric,mview_bbox geometry,force_layer_creation boolean,ade_prefix varchar) 
RETURNS text AS $$
DECLARE
feature_type CONSTANT varchar := 'Building';
l_type				varchar := 'VectorLayer';

qgis_user_group_name CONSTANT varchar := (SELECT qgis_pkg.create_qgis_pkg_usrgroup_name());

usr_schema      	varchar := (SELECT qgis_pkg.create_qgis_usr_schema_name(usr_name));
usr_names_array     varchar[] := (SELECT array_agg(s.usr_name) FROM qgis_pkg.list_qgis_pkg_usrgroup_members() AS s);
usr_schemas_array 	varchar[] := (SELECT array_agg(s.usr_schema) FROM qgis_pkg.list_usr_schemas() AS s);
cdb_schemas_array 	varchar[] := (SELECT array_agg(s.cdb_schema) FROM qgis_pkg.list_cdb_schemas() AS s);

srid                integer;
num_features    	bigint;

root_class			varchar;
curr_class			varchar;

ql_feature_type varchar := quote_literal(feature_type);
ql_l_type varchar := quote_literal(l_type);
qi_cdb_schema varchar; ql_cdb_schema varchar;
qi_usr_schema varchar; ql_usr_schema varchar;
qi_usr_name varchar; ql_usr_name varchar; ql_ade_prefix varchar;
l_name varchar; ql_l_name varchar; qi_l_name varchar;
av_name varchar; ql_av_name varchar; qi_av_name varchar;
gv_name varchar; qi_gv_name varchar; ql_gv_name varchar;
qml_form_name 	varchar := NULL;

qml_symb_name 	varchar := NULL;
qml_3d_name 	varchar := NULL;
trig_f_suffix   varchar := NULL;
r RECORD; s RECORD; t RECORD; u RECORD;
sql_feat_count	text := NULL;
sql_where 	text := NULL;
sql_upd		text := NULL;
sql_ins		text := NULL;
sql_trig	text := NULL;
sql_layer 	text := NULL;
sql_statement	text := NULL;
enum_cols_array varchar[][] := ARRAY[['cityobject','relative_to_terrain'],['cityobject','relative_to_water'],['ng_building','constructionweight']];
codelist_cols_array varchar[][] := ARRAY[['ng_building','buildingtype']];
them_surf_code varchar[][] := NULL;
-- This variable is just to avoid writing and writing the view attributes too many times.
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
-- This variable is just to avoid writing and writing the view attributes too many times.
sql_cfu_atts varchar := '
  o.class,
  o.class_codespace,
  string_to_array(o.function, ''--/\--'')::varchar[] AS function,
  string_to_array(o.function_codespace, ''--/\--'')::varchar[] AS function_codespace,  
  string_to_array(o.usage, ''--/\--'')::varchar[] AS usage,
  string_to_array(o.usage_codespace, ''--/\--'')::varchar[] AS usage_codespace,';

BEGIN
-- Check if the usr_name exists;
-- The check to avoid if it is null has been already carried out by 
-- function qgis_pkg.create_qgis_usr_schema_name(usr_name) during DECLARE
IF NOT usr_name = ANY(usr_names_array) THEN
	RAISE EXCEPTION 'usr_name is invalid. It must be an existing database user AND member of role (group) "%"', qgis_user_group_name;
END IF;

-- Check if the usr_schema exists (must have been created before)
-- No need to check if it is NULL.
IF NOT usr_schema = ANY(usr_schemas_array) THEN
	RAISE EXCEPTION 'usr_schema "%" does not exist. Please create it beforehand', usr_schema;
END IF;

-- Check if the cdb_schema exists
IF (cdb_schema IS NULL) OR (NOT cdb_schema = ANY(cdb_schemas_array)) THEN
	RAISE EXCEPTION 'cdb_schema "%" is invalid. It must correspond to an existing citydb schema', cdb_schema;
END IF;

-- Add quote identifier (qi_) and quote literal (ql_) for later user in dynamic queries.
qi_cdb_schema := quote_ident(cdb_schema);
ql_cdb_schema := quote_literal(cdb_schema);
qi_usr_name   := quote_ident(usr_name);
ql_usr_name   := quote_literal(usr_name);
qi_usr_schema := quote_ident(usr_schema);
ql_usr_schema := quote_literal(usr_schema);
ql_ade_prefix := quote_literal(ade_prefix);

-- Prepare fixed part of SQL statements
-- Remove previous entries from the layer_metadata Table, and insert it again.
sql_upd := concat('
DELETE FROM ',qi_usr_schema,'.layer_metadata AS l WHERE l.cdb_schema = ',ql_cdb_schema,' AND l.feature_type = ',ql_feature_type,' AND l.layer_name LIKE ',quote_literal('%ng_bdg%'),';
INSERT INTO ',qi_usr_schema,'.layer_metadata 
(cdb_schema, ade_prefix, layer_type, feature_type, root_class, class, lod, layer_name, av_name, gv_name, n_features, creation_date, qml_form, qml_symb, qml_3d, enum_cols, codelist_cols)
VALUES');

-- Get the srid from the cdb_schema
-- We do it here, and not immediately in the DECLARE session, because we must first check that the cdb_name exists.
EXECUTE format('SELECT srid FROM %I.database_srs LIMIT 1', cdb_schema) INTO srid;

-- Check the mview bbox (the red bbox from the plugin, for example)
-- Check that the srid is the same if the mview_box
-- Prepare the slq where part to be added to the queries, if the bbox is needed.
IF ST_SRID(mview_bbox) IS NULL OR ST_SRID(mview_bbox) <> srid THEN
	-- No bbox where condition
	sql_where := NULL;
ELSE
	-- Yes, we will perform also a spatial query based on the envelope column in the CITYOBJECT table
	sql_where := concat('AND ST_MakeEnvelope(', floor(ST_XMin(mview_bbox)),', ', floor(ST_YMin(mview_bbox)),', ', ceil(ST_XMax(mview_bbox)),', ',	ceil(ST_YMax(mview_bbox)),', ',	srid,') && co.envelope');
END IF;

RAISE NOTICE 'For module "%" and user "%": creating layers in usr_schema "%" for cdb_schema "%"', feature_type, qi_usr_name, qi_usr_schema, qi_cdb_schema;

-- Initialize variables.
sql_layer := NULL; sql_ins := NULL; sql_trig := NULL;

root_class := 'Building';
---------------------------------------------------------------
-- Create LAYER BUILDING(PART)
---------------------------------------------------------------
-- Iterate the whole process for buildings AND building parts.
-- We also need to get the proper objectclass_id from table OBJECTCLASS
FOR r IN 
	SELECT * FROM (VALUES
	('Building'::varchar, qgis_pkg.class_name_to_class_id(cdb_schema, 'Building', NULL)::integer, 'ng_bdg'::varchar),
	('BuildingPart'     , qgis_pkg.class_name_to_class_id(cdb_schema, 'BuildingPart', NULL)     , 'ng_bdg_part')	
	) AS t(class_name, class_id, class_label)
LOOP


---------------------------------------------------------------
-- Create LAYER BUILDING(PART)_LOD0 (Polygon-based layers)
---------------------------------------------------------------
	FOR t IN 
		SELECT * FROM (VALUES
		('LoD0'::varchar, 'lod0'::varchar)		
		) AS t(lodx_name, lodx_label)
	LOOP

-- First check if there are any features at all in the database schema
sql_feat_count := concat('
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
EXECUTE sql_feat_count INTO num_features;

RAISE NOTICE 'Found % features for % %', num_features, r.class_name, t.lodx_name;

curr_class := r.class_name;
l_name			:= concat(cdb_schema,'_',r.class_label,'_',t.lodx_label);
av_name			:= concat('_a_',cdb_schema,'_ng_building');
gv_name			:= concat('_g_',l_name);
qml_form_name  := concat(r.class_label,'_form.qml');
qml_symb_name  := 'poly_red_symb.qml';
qml_3d_name    := 'poly_red_3d.qml';
trig_f_suffix := 'ng_building';
qi_l_name  := quote_ident(l_name); ql_l_name := quote_literal(l_name);
qi_gv_name  := quote_ident(gv_name); ql_gv_name := quote_literal(gv_name);
qi_av_name   := quote_ident(av_name); ql_av_name := quote_literal(av_name);

IF (num_features > 0) OR (force_layer_creation IS TRUE) THEN

--------------------
-- MATERIALIZED VIEW (for geom)
--------------------
sql_layer := concat(sql_layer, qgis_pkg.generate_sql_matview_header(qi_usr_schema,qi_gv_name),'
	SELECT
		sg.cityobject_id::bigint AS co_id,
		ST_Collect(qgis_pkg.ST_snap_poly_to_grid(sg.geometry,',perform_snapping,',',digits,',',area_poly_min,'))::geometry(MultiPolygonZ, ',srid,') AS geom
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
COMMENT ON MATERIALIZED VIEW ',qi_usr_schema,'.',qi_gv_name,' IS ''Mat. view of ',r.class_name,' ',t.lodx_name,' in schema ',qi_cdb_schema,''';
',qgis_pkg.generate_sql_matview_footer(qi_usr_name, qi_usr_schema, ql_l_name, qi_gv_name));

-------
--  VIEW (for atts + geom)
-------
sql_layer := concat(sql_layer, qgis_pkg.generate_sql_view_header(qi_usr_schema, qi_l_name),'
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
  ngc.id AS ng_co_id,
  ngb.id AS ng_b_id,
  ngb.buildingtype,
  ngb.buildingtype_codespace,
  ngb.constructionweight,
  g.geom::geometry(MultiPolygonZ,',srid,')  -- This comes from the MATERIALIZED VIEW created few lines before.
FROM
	',qi_usr_schema,'.',qi_gv_name,' AS g 	-- This is the MATERIALIZED VIEW created few lines before.
	INNER JOIN ',qi_cdb_schema,'.cityobject AS co ON (g.co_id = co.id AND co.objectclass_id = ',r.class_id,')
  	INNER JOIN ',qi_cdb_schema,'.building AS o ON (o.id = co.id AND o.objectclass_id = ',r.class_id,')
	LEFT OUTER JOIN ',qi_cdb_schema,'.ng_building AS ngb ON o.id = ngb.id
	LEFT OUTER JOIN ',qi_cdb_schema,'.ng_cityobject AS ngc ON ngb.id = ngc.id;
COMMENT ON VIEW ',qi_usr_schema,'.',qi_l_name,' IS ''View of ',r.class_name,' ',t.lodx_name,' in schema ',qi_cdb_schema,''';
ALTER TABLE ',qi_usr_schema,'.',qi_l_name,' OWNER TO ',qi_usr_name,';
');

-- Add triggers to make view updatable
-- The SQL part is actually composed by these simple functions (in 010_functions.sql file)
sql_trig := concat(sql_trig,qgis_pkg.generate_sql_triggers(usr_schema, l_name, trig_f_suffix));
-- Add entry to update table layer_metadata
sql_ins := concat(sql_ins,'
(',ql_cdb_schema,',',ql_ade_prefix,',',ql_l_type,',',ql_feature_type,',',quote_literal(root_class),',',quote_literal(curr_class),',',quote_literal(t.lodx_label),',',ql_l_name,',',ql_av_name,',',ql_gv_name,',',num_features,',clock_timestamp(),',quote_literal(qml_form_name),',',quote_literal(qml_symb_name),',',quote_literal(qml_3d_name),',',quote_nullable(enum_cols_array),',',quote_nullable(codelist_cols_array),'),');
ELSE
sql_layer := concat(sql_layer, qgis_pkg.generate_sql_matview_else(qi_usr_schema, ql_cdb_schema, ql_l_type, ql_l_name, qi_gv_name));
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
sql_feat_count := concat('
SELECT count(o.id) AS n_features
FROM 
	',qi_cdb_schema,'.building AS o
	INNER JOIN ',qi_cdb_schema,'.cityobject AS co ON (o.id = co.id AND o.objectclass_id = ',r.class_id,' ',sql_where,')
WHERE
	o.',t.lodx_label,'_',u.themsurf_label,'_id IS NOT NULL;
');
EXECUTE sql_feat_count INTO num_features;

RAISE NOTICE 'Found % features for % % %', num_features, r.class_name, t.lodx_name, u.themsurf_name;

curr_class := r.class_name;
l_name			:= concat(cdb_schema,'_',r.class_label,'_',t.lodx_label,'_',u.themsurf_name);
av_name			:= concat('_a_',cdb_schema,'_ng_building');
gv_name			:= concat('_g_',l_name);
qml_form_name  := concat(r.class_label,'_form.qml');
qml_symb_name  := 'poly_red_symb.qml';
qml_3d_name    := 'poly_red_3d.qml';
trig_f_suffix := 'ng_building';
qi_l_name  := quote_ident(l_name); ql_l_name := quote_literal(l_name);
qi_gv_name  := quote_ident(gv_name); ql_gv_name := quote_literal(gv_name);
qi_av_name   := quote_ident(av_name); ql_av_name := quote_literal(av_name);

IF (num_features > 0) OR (force_layer_creation IS TRUE) THEN

--------------------
-- MATERIALIZED VIEW (for geom)
--------------------
sql_layer := concat(sql_layer, qgis_pkg.generate_sql_matview_header(qi_usr_schema,qi_gv_name),'
	SELECT
		sg.cityobject_id::bigint AS co_id,
		ST_Collect(qgis_pkg.ST_snap_poly_to_grid(sg.geometry,',perform_snapping,',',digits,',',area_poly_min,'))::geometry(MultiPolygonZ, ',srid,') AS geom
	FROM
		',qi_cdb_schema,'.building AS o
		INNER JOIN ',qi_cdb_schema,'.cityobject AS co ON (o.id = co.id AND o.objectclass_id = ',r.class_id,' ',sql_where,') 
		INNER JOIN ',qi_cdb_schema,'.surface_geometry AS sg ON (sg.root_id = o.',t.lodx_label,'_',u.themsurf_label,'_id AND sg.geometry IS NOT NULL)
	GROUP BY sg.cityobject_id
WITH NO DATA;
COMMENT ON MATERIALIZED VIEW ',qi_usr_schema,'.',qi_gv_name,' IS ''Mat. view of (',r.class_name,') ',t.lodx_name,' ',u.themsurf_name,' in schema ',qi_cdb_schema,''';
',qgis_pkg.generate_sql_matview_footer(qi_usr_name, qi_usr_schema, ql_l_name, qi_gv_name));

-------
--  VIEW (for atts + geom)
-------
sql_layer := concat(sql_layer, qgis_pkg.generate_sql_view_header(qi_usr_schema, qi_l_name),'
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
  ngc.id AS ng_co_id,
  ngb.id AS ng_b_id,
  ngb.buildingtype,
  ngb.buildingtype_codespace,
  ngb.constructionweight,
  g.geom::geometry(MultiPolygonZ,',srid,')
FROM
	',qi_usr_schema,'.',qi_gv_name,' AS g 
	INNER JOIN ',qi_cdb_schema,'.cityobject AS co ON (g.co_id = co.id AND co.objectclass_id = ',r.class_id,')
        INNER JOIN ',qi_cdb_schema,'.building AS o ON (o.id = co.id AND o.objectclass_id = ',r.class_id,')
        LEFT OUTER JOIN ',qi_cdb_schema,'.ng_building AS ngb ON o.id = ngb.id
        LEFT OUTER JOIN ',qi_cdb_schema,'.ng_cityobject AS ngc ON ngb.id = ngc.id;
COMMENT ON VIEW ',qi_usr_schema,'.',qi_l_name,' IS ''View of ',r.class_name,' ',t.lodx_name,' ',u.themsurf_name,' in schema ',qi_cdb_schema,''';
ALTER TABLE ',qi_usr_schema,'.',qi_l_name,' OWNER TO ',qi_usr_name,';
');

-- Add triggers to make view updatable
sql_trig := concat(sql_trig,qgis_pkg.generate_sql_triggers(usr_schema, l_name, trig_f_suffix));
-- Add entry to update table layer_metadata
sql_ins := concat(sql_ins,'
(',ql_cdb_schema,',',ql_ade_prefix,',',ql_l_type,',',ql_feature_type,',',quote_literal(root_class),',',quote_literal(curr_class),',',quote_literal(t.lodx_label),',',ql_l_name,',',ql_av_name,',',ql_gv_name,',',num_features,',clock_timestamp(),',quote_literal(qml_form_name),',',quote_literal(qml_symb_name),',',quote_literal(qml_3d_name),',',quote_nullable(enum_cols_array),',',quote_nullable(codelist_cols_array),'),');
ELSE
sql_layer := concat(sql_layer, qgis_pkg.generate_sql_matview_else(qi_usr_schema, ql_cdb_schema, ql_l_type, ql_l_name, qi_gv_name));
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
sql_feat_count := concat('
SELECT count(o.id) AS n_features
FROM 
	',qi_cdb_schema,'.building AS o
	INNER JOIN ',qi_cdb_schema,'.cityobject AS co ON (o.id = co.id AND o.objectclass_id = ',r.class_id,' ',sql_where,')
WHERE
	o.',t.lodx_label,'_multi_surface_id IS NOT NULL OR o.',t.lodx_label,'_solid_id IS NOT NULL
');
EXECUTE sql_feat_count INTO num_features;

RAISE NOTICE 'Found % features for % %', num_features, r.class_name, t.lodx_name;

curr_class := r.class_name;
l_name			:= concat(cdb_schema,'_',r.class_label,'_',t.lodx_label);
av_name			:= concat('_a_',cdb_schema,'_ng_building');
gv_name			:= concat('_g_',l_name);
qml_form_name  := concat(r.class_label,'_form.qml');
qml_symb_name  := 'poly_red_symb.qml';
qml_3d_name    := 'poly_red_3d.qml';
trig_f_suffix := 'ng_building';
qi_l_name  := quote_ident(l_name); ql_l_name := quote_literal(l_name);
qi_gv_name  := quote_ident(gv_name); ql_gv_name := quote_literal(gv_name);
qi_av_name   := quote_ident(av_name); ql_av_name := quote_literal(av_name);

IF (num_features > 0) OR (force_layer_creation IS TRUE) THEN

--------------------
-- MATERIALIZED VIEW (for geom)
--------------------
sql_layer := concat(sql_layer, qgis_pkg.generate_sql_matview_header(qi_usr_schema,qi_gv_name),'
	SELECT
		sg.cityobject_id::bigint AS co_id,
		ST_Collect(qgis_pkg.ST_snap_poly_to_grid(sg.geometry,',perform_snapping,',',digits,',',area_poly_min,'))::geometry(MultiPolygonZ, ',srid,') AS geom
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
COMMENT ON MATERIALIZED VIEW ',qi_usr_schema,'.',qi_gv_name,' IS ''Mat. view of ',r.class_name,' ',t.lodx_name,' in schema ',qi_cdb_schema,''';
',qgis_pkg.generate_sql_matview_footer(qi_usr_name, qi_usr_schema, ql_l_name, qi_gv_name));

-------
--  VIEW (for atts + geom)
-------
sql_layer := concat(sql_layer, qgis_pkg.generate_sql_view_header(qi_usr_schema, qi_l_name),'
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
  ngc.id AS ng_co_id,
  ngb.id AS ng_b_id,
  ngb.buildingtype,
  ngb.buildingtype_codespace,
  ngb.constructionweight,
  g.geom::geometry(MultiPolygonZ,',srid,')
FROM
	',qi_usr_schema,'.',qi_gv_name,' AS g 
	INNER JOIN ',qi_cdb_schema,'.cityobject AS co ON (g.co_id = co.id AND co.objectclass_id = ',r.class_id,')
        INNER JOIN ',qi_cdb_schema,'.building AS o ON (o.id = co.id AND o.objectclass_id = ',r.class_id,')
        LEFT OUTER JOIN ',qi_cdb_schema,'.ng_building AS ngb ON o.id = ngb.id
        LEFT OUTER JOIN ',qi_cdb_schema,'.ng_cityobject AS ngc ON ngb.id = ngc.id;
COMMENT ON VIEW ',qi_usr_schema,'.',qi_l_name,' IS ''View of (',r.class_name,') ',t.lodx_name,' in schema ',qi_cdb_schema,''';
ALTER TABLE ',qi_usr_schema,'.',qi_l_name,' OWNER TO ',qi_usr_name,';
');

-- Add triggers to make view updatable
sql_trig := concat(sql_trig,qgis_pkg.generate_sql_triggers(usr_schema, l_name, trig_f_suffix));
-- Add entry to update table layer_metadata
sql_ins := concat(sql_ins,'
(',ql_cdb_schema,',',ql_ade_prefix,',',ql_l_type,',',ql_feature_type,',',quote_literal(root_class),',',quote_literal(curr_class),',',quote_literal(t.lodx_label),',',ql_l_name,',',ql_av_name,',',ql_gv_name,',',num_features,',clock_timestamp(),',quote_literal(qml_form_name),',',quote_literal(qml_symb_name),',',quote_literal(qml_3d_name),',',quote_nullable(enum_cols_array),',',quote_nullable(codelist_cols_array),'),');
ELSE
sql_layer := concat(sql_layer, qgis_pkg.generate_sql_matview_else(qi_usr_schema, ql_cdb_schema, ql_l_type, ql_l_name, qi_gv_name));
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
sql_feat_count := concat('
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
EXECUTE sql_feat_count INTO num_features;

RAISE NOTICE 'Found % features for % %', num_features, r.class_name, t.lodx_name;

curr_class := r.class_name;
l_name			:= concat(cdb_schema,'_',r.class_label,'_',t.lodx_label);
av_name			:= concat('_a_',cdb_schema,'_ng_building');
gv_name			:= concat('_g_',l_name);
qml_form_name  := concat(r.class_label,'_form.qml');
qml_symb_name  := 'poly_red_symb.qml';
qml_3d_name    := 'poly_red_3d.qml';
trig_f_suffix := 'ng_building';
qi_l_name  := quote_ident(l_name); ql_l_name := quote_literal(l_name);
qi_gv_name  := quote_ident(gv_name); ql_gv_name := quote_literal(gv_name);
qi_av_name   := quote_ident(av_name); ql_av_name := quote_literal(av_name);

IF (num_features > 0) OR (force_layer_creation IS TRUE) THEN

--------------------
-- MATERIALIZED VIEW (for geom)
--------------------
sql_layer := concat(sql_layer, qgis_pkg.generate_sql_matview_header(qi_usr_schema,qi_gv_name),'
	SELECT
		foo2.co_id::bigint AS co_id,
		ST_Collect(qgis_pkg.ST_snap_poly_to_grid(sg.geometry,',perform_snapping,',',digits,',',area_poly_min,'))::geometry(MultiPolygonZ, ',srid,') AS geom
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
COMMENT ON MATERIALIZED VIEW ',qi_usr_schema,'.',qi_gv_name,' IS ''Mat. view of ',r.class_name,' ',t.lodx_name,' in schema ',qi_cdb_schema,''';
',qgis_pkg.generate_sql_matview_footer(qi_usr_name, qi_usr_schema, ql_l_name, qi_gv_name));

-------
--  VIEW (for atts + geom)
-------
sql_layer := concat(sql_layer, qgis_pkg.generate_sql_view_header(qi_usr_schema, qi_l_name),'
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
  ngc.id AS ng_co_id,
  ngb.id AS ng_b_id,
  ngb.buildingtype,
  ngb.buildingtype_codespace,
  ngb.constructionweight,
  g.geom::geometry(MultiPolygonZ,',srid,')
FROM
	',qi_usr_schema,'.',qi_gv_name,' AS g 
	INNER JOIN ',qi_cdb_schema,'.cityobject AS co ON (g.co_id = co.id AND co.objectclass_id = ',r.class_id,')
        INNER JOIN ',qi_cdb_schema,'.building AS o ON (o.id = co.id AND o.objectclass_id = ',r.class_id,')
        LEFT OUTER JOIN ',qi_cdb_schema,'.ng_building AS ngb ON o.id = ngb.id
        LEFT OUTER JOIN ',qi_cdb_schema,'.ng_cityobject AS ngc ON ngb.id = ngc.id;
COMMENT ON VIEW ',qi_usr_schema,'.',qi_l_name,' IS ''View of ',r.class_name,' ',t.lodx_name,' in schema ',qi_cdb_schema,''';
ALTER TABLE ',qi_usr_schema,'.',qi_l_name,' OWNER TO ',qi_usr_name,';
');

-- Add triggers to make view updatable
sql_trig := concat(sql_trig,qgis_pkg.generate_sql_triggers(usr_schema, l_name, trig_f_suffix));
-- Add entry to update table layer_metadata
sql_ins := concat(sql_ins,'
(',ql_cdb_schema,',',ql_ade_prefix,',',ql_l_type,',',ql_feature_type,',',quote_literal(root_class),',',quote_literal(curr_class),',',quote_literal(t.lodx_label),',',ql_l_name,',',ql_av_name,',',ql_gv_name,',',num_features,',clock_timestamp(),',quote_literal(qml_form_name),',',quote_literal(qml_symb_name),',',quote_literal(qml_3d_name),',',quote_nullable(enum_cols_array),',',quote_nullable(codelist_cols_array),'),');
ELSE
	sql_layer := concat(sql_layer, qgis_pkg.generate_sql_matview_else(qi_usr_schema, ql_cdb_schema, ql_l_type, ql_l_name, qi_gv_name));
END IF;

---------------------------------------------------------------
-- Create LAYER BUILDING(PART)_LOD2-4_THEMATIC SURFACES
---------------------------------------------------------------
		FOR u IN 
			SELECT * FROM (VALUES
			('BuildingRoofSurface'::varchar , qgis_pkg.class_name_to_class_id(cdb_schema, 'BuildingRoofSurface', NULL)::integer, 'roofsurf'::varchar),
			('BuildingWallSurface'			, qgis_pkg.class_name_to_class_id(cdb_schema, 'BuildingWallSurface'			, NULL), 'wallsurf'),
			('BuildingGroundSurface'		, qgis_pkg.class_name_to_class_id(cdb_schema, 'BuildingGroundSurface'		, NULL), 'groundsurf'),
			('BuildingClosureSurface'		, qgis_pkg.class_name_to_class_id(cdb_schema, 'BuildingClosureSurface'		, NULL), 'closuresurf'),
			('OuterBuildingCeilingSurface'	, qgis_pkg.class_name_to_class_id(cdb_schema, 'OuterBuildingCeilingSurface'	, NULL), 'outerceilingsurf'),
			('OuterBuildingFloorSurface'	, qgis_pkg.class_name_to_class_id(cdb_schema, 'OuterBuildingFloorSurface'	, NULL), 'outerfloorsurf')
			) AS t(class_name, class_id, class_label)
		LOOP

-- First check if there are any features at all in the database schema
sql_feat_count := concat('
SELECT count(o.id) AS n_features
FROM 
	',qi_cdb_schema,'.thematic_surface AS o
	INNER JOIN ',qi_cdb_schema,'.cityobject AS co ON (o.id = co.id AND o.objectclass_id = ',u.class_id,' ',sql_where,')
	INNER JOIN ',qi_cdb_schema,'.building AS b ON (o.building_id = b.id AND b.objectclass_id = ',r.class_id,')
        LEFT OUTER JOIN ',qi_cdb_schema,'.ng_building AS ngb ON o.id = ngb.id
        LEFT OUTER JOIN ',qi_cdb_schema,'.ng_cityobject AS ngc ON ngb.id = ngc.id
WHERE
	o.',t.lodx_label,'_multi_surface_id IS NOT NULL;
');
EXECUTE sql_feat_count INTO num_features;

RAISE NOTICE 'Found % features for % % %', num_features, r.class_name, t.lodx_name, u.class_name;

curr_class := u.class_name;
l_name			:= concat(cdb_schema,'_',r.class_label,'_',t.lodx_label,'_',u.class_label);
av_name			:= concat('_a_',cdb_schema,'_ng_building_them_surf');
gv_name			:= concat('_g_',l_name);
qml_form_name  := 'ng_bdg_them_surf_form.qml';
qml_symb_name  := 'poly_red_semi_transp_symb.qml';
qml_3d_name    := 'poly_red_semi_transp_3d.qml';
trig_f_suffix := 'ng_thematic_surface';
qi_l_name  := quote_ident(l_name); ql_l_name := quote_literal(l_name);
qi_gv_name  := quote_ident(gv_name); ql_gv_name := quote_literal(gv_name);
qi_av_name   := quote_ident(av_name); ql_av_name := quote_literal(av_name);

IF (num_features > 0) OR (force_layer_creation IS TRUE) THEN

--------------------
-- MATERIALIZED VIEW (for geom)
--------------------
sql_layer := concat(sql_layer, qgis_pkg.generate_sql_matview_header(qi_usr_schema,qi_gv_name),'
	SELECT
		sg.cityobject_id::bigint AS co_id,
		ST_Collect(qgis_pkg.ST_snap_poly_to_grid(sg.geometry,',perform_snapping,',',digits,',',area_poly_min,'))::geometry(MultiPolygonZ, ',srid,') AS geom
	FROM
		',qi_cdb_schema,'.thematic_surface AS o
		INNER JOIN ',qi_cdb_schema,'.cityobject AS co ON (o.id = co.id AND o.objectclass_id = ',u.class_id,' ',sql_where,')		
		INNER JOIN ',qi_cdb_schema,'.building AS b ON (o.building_id = b.id AND b.objectclass_id = ',r.class_id,')
		INNER JOIN ',qi_cdb_schema,'.surface_geometry AS sg ON (sg.root_id = o.',t.lodx_name,'_multi_surface_id AND sg.geometry IS NOT NULL)
	GROUP BY sg.cityobject_id
WITH NO DATA;
COMMENT ON MATERIALIZED VIEW ',qi_usr_schema,'.',qi_gv_name,' IS ''Mat. view of (',r.class_name,') ',t.lodx_name,' ',u.class_name,' in schema ',qi_cdb_schema,''';
',qgis_pkg.generate_sql_matview_footer(qi_usr_name, qi_usr_schema, ql_l_name, qi_gv_name));

-------
--  VIEW (for atts + geom)
-------
sql_layer := concat(sql_layer, qgis_pkg.generate_sql_view_header(qi_usr_schema, qi_l_name),'
SELECT',
sql_co_atts,'
  o.building_id,
  ngco.id AS ng_co_id,
  g.geom::geometry(MultiPolygonZ,',srid,')
FROM
	',qi_usr_schema,'.',qi_gv_name,' AS g 
	INNER JOIN ',qi_cdb_schema,'.cityobject AS co ON (g.co_id = co.id AND co.objectclass_id = ',u.class_id,')
  	INNER JOIN ',qi_cdb_schema,'.thematic_surface AS o ON (o.id = co.id AND o.objectclass_id = ',u.class_id,')
	LEFT OUTER JOIN ',qi_cdb_schema,'.ng_cityobject AS ngco ON o.id = ngco.id;
COMMENT ON VIEW ',qi_usr_schema,'.',qi_l_name,' IS ''View of (',r.class_name,') ',t.lodx_name,' ',u.class_name,' in schema ',qi_cdb_schema,''';
ALTER TABLE ',qi_usr_schema,'.',qi_l_name,' OWNER TO ',qi_usr_name,';
');

-- Add triggers to make view updatable
sql_trig := concat(sql_trig,qgis_pkg.generate_sql_triggers(usr_schema, l_name, trig_f_suffix));
-- Add entry to update table layer_metadata
sql_ins := concat(sql_ins,'
(',ql_cdb_schema,',',ql_ade_prefix,',',ql_l_type,',',ql_feature_type,',',quote_literal(root_class),',',quote_literal(curr_class),',',quote_literal(t.lodx_label),',',ql_l_name,',',ql_av_name,',',ql_gv_name,',',num_features,',clock_timestamp(),',quote_literal(qml_form_name),',',quote_literal(qml_symb_name),',',quote_literal(qml_3d_name),',',quote_nullable((enum_cols_array)[1:2]),',',quote_nullable(them_surf_code),'),');
ELSE
sql_layer := concat(sql_layer, qgis_pkg.generate_sql_matview_else(qi_usr_schema, ql_cdb_schema, ql_l_type, ql_l_name, qi_gv_name));
END IF;

		END LOOP; -- building lod2-4 thematic surfaces
	END LOOP; -- building lod2-4

-- HERE I REMOVED LOTS OF OTHER STUFF FOR ALL OTHER CLASSES (ROOM, ETC)

END LOOP;  -- building

-- substitute last comma with semi-colon
IF sql_ins IS NOT NULL THEN
	sql_ins := concat(sql_upd, substr(sql_ins,1, length(sql_ins)-1), ';');
END IF;
-- create the final sql statement
sql_statement := concat(sql_layer, sql_trig, sql_ins);
RAISE NOTICE '%s',sql_statement;
RETURN sql_statement;
EXCEPTION
	WHEN QUERY_CANCELED THEN
		RAISE EXCEPTION 'qgis_pkg.generate_sql_layers_ng_building(): Error QUERY_CANCELED';
	WHEN OTHERS THEN
		RAISE EXCEPTION 'qgis_pkg.generate_sql_layers_ng_building(): %', SQLERRM;
END;
$$ LANGUAGE plpgsql;
COMMENT ON FUNCTION qgis_pkg.generate_sql_layers_ng_building(varchar, varchar, integer, integer, numeric, geometry, boolean, varchar) IS 'Generate SQL script to create layers for module Building';
REVOKE EXECUTE ON FUNCTION qgis_pkg.generate_sql_layers_ng_building(varchar, varchar, integer, integer, numeric, geometry, boolean, varchar) FROM public;

---------------------------------------------------------------------
-- CREATE FUNCTION qgis_pkg.generate_sql_layers_ng_usagezone
---------------------------------------------------------------------
DROP FUNCTION IF EXISTS qgis_pkg.generate_sql_layers_ng_usagezone(varchar,varchar,integer,integer,numeric,geometry,boolean) CASCADE;
DROP FUNCTION IF EXISTS qgis_pkg.generate_sql_layers_ng_usagezone(varchar,varchar,integer,integer,numeric,geometry,boolean,varchar) CASCADE;
CREATE OR REPLACE FUNCTION qgis_pkg.generate_sql_layers_ng_usagezone(usr_name varchar,cdb_schema varchar,perform_snapping integer,digits integer,
								     area_poly_min numeric,mview_bbox geometry,force_layer_creation boolean,ade_prefix varchar)
RETURNS text AS $$
DECLARE
	feature_type CONSTANT varchar := 'Building';
	l_type				varchar := 'VectorLayerNoGeom';

	qgis_user_group_name CONSTANT varchar := (SELECT qgis_pkg.create_qgis_pkg_usrgroup_name());

	usr_schema      	varchar := (SELECT qgis_pkg.create_qgis_usr_schema_name(usr_name));
	usr_names_array     varchar[] := (SELECT array_agg(s.usr_name) FROM qgis_pkg.list_qgis_pkg_usrgroup_members() AS s);
	usr_schemas_array 	varchar[] := (SELECT array_agg(s.usr_schema) FROM qgis_pkg.list_usr_schemas() AS s);
	cdb_schemas_array 	varchar[] := (SELECT array_agg(s.cdb_schema) FROM qgis_pkg.list_cdb_schemas() AS s);

	srid                integer;
	num_features    	bigint;

	root_class			varchar;
	curr_class			varchar;
	lod varchar;
	ql_feature_type varchar := quote_literal(feature_type);
	ql_l_type varchar := quote_literal(l_type);
	qi_cdb_schema varchar; ql_cdb_schema varchar;
	qi_usr_schema varchar; ql_usr_schema varchar; ql_ade_prefix varchar;
	qi_usr_name varchar; ql_usr_name varchar;ql_class varchar;
	l_name varchar; ql_l_name varchar; qi_l_name varchar;
	av_name varchar; ql_av_name varchar; qi_av_name varchar;
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
	enum_cols_array varchar[][] := ARRAY[['cityobject','relative_to_terrain'],['cityobject','relative_to_water']];
	codelist_cols_array varchar[][] := ARRAY[['ng_usagezone','usagezonetype']];
	sql_co_atts varchar := 'co.id::bigint,co.gmlid,co.gmlid_codespace,co.name,
				co.name_codespace,co.description,co.creation_date,
				co.termination_date,co.last_modification_date,
				relative_to_terrain,relative_to_water,
				co.updating_person,co.reason_for_update,co.lineage,';

BEGIN
	-- check if user name exists
	IF NOT usr_name = ANY(usr_names_array) THEN
	RAISE EXCEPTION 'usr_name is invalid. It must be an existing database user and member of role (group) "%"',qgis_user_group_name;
	END IF;
	
	-- check if usr_schema exists
	IF NOT usr_schema = ANY(usr_schemas_array) THEN
	RAISE EXCEPTION 'usr_schema % does not exist. Please create it beforehand',usr_schema;
	END IF;
	
	-- check if cdb_schema exists
	IF NOT cdb_schema = ANY(cdb_schemas_array)  THEN
	RAISE EXCEPTION 'cdb_schema % is invalid. It must correspond to an existing city db schema',cdb_schema;
	END IF;

	-- add quote identifier (qi_) and quote literal (ql_) for later user in dynamic queries.
	qi_cdb_schema := quote_ident(cdb_schema);
	ql_cdb_schema := quote_literal(cdb_schema);
	qi_usr_name   := quote_ident(usr_name);
	ql_usr_name   := quote_literal(usr_name);
	qi_usr_schema := quote_ident(usr_schema);
	ql_usr_schema := quote_literal(usr_schema);
	ql_class := quote_literal('UsageZone');
	ql_ade_prefix := quote_literal(ade_prefix);

	-- Prepare fixed part of SQL statements
	-- Remove previous entries from the layer_metadata Table, and insert it again.
	sql_upd := concat('
	DELETE FROM ',qi_usr_schema,'.layer_metadata AS l WHERE l.cdb_schema = ',ql_cdb_schema,' AND l.feature_type = ',ql_feature_type,' AND l.class = ',quote_literal('UsageZone'),';
	INSERT INTO ',qi_usr_schema,'.layer_metadata 
	(cdb_schema, ade_prefix, layer_type, feature_type, root_class, class, lod, layer_name, av_name, gv_name, n_features, creation_date, qml_form, qml_symb, qml_3d, enum_cols, codelist_cols)
	VALUES');
	
	RAISE NOTICE 'For module "%" and user "%": creating layers in usr_schema "%" for cdb_schema "%"', feature_type, qi_usr_name, qi_usr_schema, qi_cdb_schema;
	
	-- Initialize variables.
	sql_layer := NULL; sql_ins := NULL; sql_trig := NULL;
	root_class := feature_type;

	-----------------------------------------------------------
	-- CREATE LAYER USAGEZONE
	-----------------------------------------------------------
	sql_feat_count := concat('
		SELECT COUNT(nguz.id) FROM ',qi_cdb_schema,'.ng_usagezone AS nguz
		INNER JOIN ',qi_cdb_schema,'.cityobject AS co ON nguz.id = co.id 
	');
	
        EXECUTE sql_feat_count INTO num_features;
	
	RAISE NOTICE 'Found % features for UsageZone',num_features; 
	
	curr_class := 'UsageZone';
	lod := 'lodx';
	l_name := concat(cdb_schema,'_ng_usagezone_lodx');
	av_name := concat('_a_',cdb_schema,'_ng_usagezone');
	gv_name := concat(' ');
	qml_form_name := 'ng_usagezone_form.qml';
	qml_symb_name := ' ';
	qml_3d_name := ' ';
	trig_f_suffix := 'ng_usagezone';
	qi_l_name := quote_ident(l_name);
	ql_l_name := quote_literal(l_name);
	qi_av_name := quote_ident(av_name);
	ql_av_name := quote_literal(av_name);
	qi_gv_name := quote_ident(gv_name);
	ql_gv_name := quote_literal(gv_name);

	IF (num_features > 0) OR (force_layer_creation IS TRUE) THEN

		----------------------------------------------------
		-- VIEW FOR ATTRIBUTES
		----------------------------------------------------
		
		sql_layer := concat(sql_layer,qgis_pkg.generate_sql_view_header(qi_usr_schema,qi_l_name),'
			SELECT
			nguz.id AS co_id,
			ngco.id AS ng_co_id,',
			sql_co_atts,'
			nguz.building_usagezone_id,
			nguz.coolingschedule_id,
			nguz.heatingschedule_id,
			nguz.thermalzone_contains_id,
			nguz.usagezonetype,
			nguz.usagezonetype_codespace,
			nguz.ventilationschedule_id
			FROM ',qi_cdb_schema,'.ng_usagezone AS nguz
			INNER JOIN ',qi_cdb_schema,'.cityobject AS co ON nguz.id = co.id 
			LEFT OUTER JOIN ',qi_cdb_schema,'.ng_cityobject AS ngco ON co.id = ngco.id;
			COMMENT ON VIEW ',qi_usr_schema,'.',qi_l_name,' IS ''View of UsageZone LoDx in schema ',qi_cdb_schema,''';
			ALTER TABLE ',qi_usr_schema,'.',qi_l_name,' OWNER TO ',qi_usr_name,';
		');
		-- Add triggers to make view updatable
		sql_trig := concat(sql_trig,qgis_pkg.generate_sql_triggers(usr_schema, l_name, trig_f_suffix));
		
		-- Add entry to update table layer_metadata
		sql_ins := concat(sql_ins,'
			(',ql_cdb_schema,',',ql_ade_prefix,',',ql_l_type,',',ql_feature_type,',',quote_literal(root_class),',',quote_literal(curr_class),',',quote_literal(lod),',
			 ',ql_l_name,',',ql_av_name,',',ql_gv_name,',',num_features,',clock_timestamp(),',quote_literal(qml_form_name),',',quote_literal(qml_symb_name),',',quote_literal(qml_3d_name),',
			 ',quote_nullable(enum_cols_array),',',quote_nullable(codelist_cols_array),'),');
		
	ELSE
		sql_layer := concat(sql_layer, qgis_pkg.generate_sql_matview_else(qi_usr_schema, ql_cdb_schema, ql_l_type, ql_l_name, qi_gv_name));
	END IF;	
	
	IF sql_ins IS NOT NULL THEN
		sql_ins := concat(sql_upd, substr(sql_ins,1, length(sql_ins)-1), ';');
	END IF;
	
	sql_statement := concat(sql_layer,sql_trig,sql_ins);
	RETURN sql_statement;
END;
$$ LANGUAGE plpgsql;	
COMMENT ON FUNCTION qgis_pkg.generate_sql_layers_ng_usagezone(varchar,varchar,integer,integer,numeric,geometry,boolean,varchar) IS 'Generate SQL script to create layers for class UsageZone';
REVOKE EXECUTE ON FUNCTION qgis_pkg.generate_sql_layers_ng_usagezone(varchar,varchar,integer,integer,numeric,geometry,boolean,varchar) FROM public; 	

---------------------------------------------------------------------
-- CREATE FUNCTION qgis_pkg.generate_sql_layers_ng_facilities
---------------------------------------------------------------------
DROP FUNCTION IF EXISTS qgis_pkg.generate_sql_layers_ng_facilities(varchar,varchar,integer,integer,numeric,geometry,boolean,varchar) CASCADE;
CREATE OR REPLACE FUNCTION qgis_pkg.generate_sql_layers_ng_facilities(usr_name varchar,cdb_schema varchar,perform_snapping integer,digits integer,
								      area_poly_min numeric,mview_bbox geometry,force_layer_creation boolean,ade_prefix varchar)
RETURNS text AS $$
DECLARE
	feature_type CONSTANT varchar := 'Building';
	l_type				varchar := 'VectorLayerNoGeom';

	qgis_user_group_name CONSTANT varchar := (SELECT qgis_pkg.create_qgis_pkg_usrgroup_name());

	usr_schema      	varchar := (SELECT qgis_pkg.create_qgis_usr_schema_name(usr_name));
	usr_names_array     varchar[] := (SELECT array_agg(s.usr_name) FROM qgis_pkg.list_qgis_pkg_usrgroup_members() AS s);
	usr_schemas_array 	varchar[] := (SELECT array_agg(s.usr_schema) FROM qgis_pkg.list_usr_schemas() AS s);
	cdb_schemas_array 	varchar[] := (SELECT array_agg(s.cdb_schema) FROM qgis_pkg.list_cdb_schemas() AS s);

	srid                integer;
	num_features    	bigint;

	root_class			varchar;
	curr_class			varchar;
	lod varchar;
	ql_feature_type varchar := quote_literal(feature_type);
	ql_l_type varchar := quote_literal(l_type);
	qi_cdb_schema varchar; ql_cdb_schema varchar;
	qi_usr_schema varchar; ql_usr_schema varchar; ql_ade_prefix varchar;
	qi_usr_name varchar; ql_usr_name varchar;ql_class varchar;
	l_name varchar; ql_l_name varchar; qi_l_name varchar;
	av_name varchar; ql_av_name varchar; qi_av_name varchar;
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
	enum_cols_array varchar[][] := ARRAY[['cityobject','relative_to_terrain'],['cityobject','relative_to_water']];
	codelist_cols_array varchar[][] := NULL;
	sql_co_atts varchar := 'co.id::bigint,co.gmlid,co.gmlid_codespace,co.name,
				co.name_codespace,co.description,co.creation_date,
				co.termination_date,co.last_modification_date,
				relative_to_terrain,relative_to_water,
				co.updating_person,co.reason_for_update,co.lineage,';

BEGIN
	-- check if user name exists
	IF NOT usr_name = ANY(usr_names_array) THEN
	RAISE EXCEPTION 'usr_name is invalid. It must be an existing database user and member of role (group) "%"',qgis_user_group_name;
	END IF;
	
	-- check if usr_schema exists
	IF NOT usr_schema = ANY(usr_schemas_array) THEN
	RAISE EXCEPTION 'usr_schema % does not exist. Please create it beforehand',usr_schema;
	END IF;
	
	-- check if cdb_schema exists
	IF NOT cdb_schema = ANY(cdb_schemas_array)  THEN
	RAISE EXCEPTION 'cdb_schema % is invalid. It must correspond to an existing city db schema',cdb_schema;
	END IF;

	-- add quote identifier (qi_) and quote literal (ql_) for later user in dynamic queries.
	qi_cdb_schema := quote_ident(cdb_schema);
	ql_cdb_schema := quote_literal(cdb_schema);
	qi_usr_name   := quote_ident(usr_name);
	ql_usr_name   := quote_literal(usr_name);
	qi_usr_schema := quote_ident(usr_schema);
	ql_usr_schema := quote_literal(usr_schema);
	ql_class := quote_literal('Facilities');
	ql_ade_prefix := quote_literal(ade_prefix);

	-- Prepare fixed part of SQL statements
	-- Remove previous entries from the layer_metadata Table, and insert it again.
	sql_upd := concat('
	DELETE FROM ',qi_usr_schema,'.layer_metadata AS l WHERE l.cdb_schema = ',ql_cdb_schema,' AND l.feature_type = ',ql_feature_type,' AND l.class = ',quote_literal('Facilities'),';
	INSERT INTO ',qi_usr_schema,'.layer_metadata 
	(cdb_schema, ade_prefix, layer_type, feature_type, root_class, class, lod, layer_name, av_name, gv_name, n_features, creation_date, qml_form, qml_symb, qml_3d, enum_cols, codelist_cols)
	VALUES');

	RAISE NOTICE 'For module "%" and user "%": creating layers in usr_schema "%" for cdb_schema "%"', feature_type, qi_usr_name, qi_usr_schema, qi_cdb_schema;
	
	-- Initialize variables.
	sql_layer := NULL; sql_ins := NULL; sql_trig := NULL;
	root_class := feature_type;

	-----------------------------------------------------------
	-- CREATE LAYER FACILITIES
	-----------------------------------------------------------
	sql_feat_count := concat('
		SELECT COUNT(ngf.id) FROM ',qi_cdb_schema,'.ng_facilities AS ngf
		INNER JOIN ',qi_cdb_schema,'.cityobject AS co ON ngf.id = co.id
	');
	
        EXECUTE sql_feat_count INTO num_features;
	
	RAISE NOTICE 'Found % features for Facilities',num_features; 
	
	curr_class := 'Facilities';
	lod := 'lodx';
	l_name := concat(cdb_schema,'_ng_facilities_lodx');
	av_name := concat('_a_',cdb_schema,'_ng_facilities');
	gv_name := concat(' ');
	qml_form_name := 'ng_facilities_form.qml';
	qml_symb_name := ' ';
	qml_3d_name := ' ';
	trig_f_suffix := 'ng_facilities';
	qi_l_name := quote_ident(l_name);
	ql_l_name := quote_literal(l_name);
	qi_av_name := quote_ident(av_name);
	ql_av_name := quote_literal(av_name);
	qi_gv_name := quote_ident(gv_name);
	ql_gv_name := quote_literal(gv_name);

	IF (num_features > 0) OR (force_layer_creation IS TRUE) THEN

		----------------------------------------------------
		-- VIEW FOR ATTRIBUTES
		----------------------------------------------------
		
		sql_layer := concat(sql_layer,qgis_pkg.generate_sql_view_header(qi_usr_schema,qi_l_name),'
			SELECT
			ngf.id AS co_id,',
			sql_co_atts,'
			ngf.heatdissipation_id,
			ngf.objectclass_id,
			ngf.operationschedule_id,
			ngf.usagezone_equippedwith_id
			FROM ',qi_cdb_schema,'.ng_facilities AS ngf
			INNER JOIN ',qi_cdb_schema,'.cityobject AS co ON ngf.id = co.id 
			LEFT OUTER JOIN ',qi_cdb_schema,'.ng_cityobject AS ngco ON co.id = ngco.id;
			COMMENT ON VIEW ',qi_usr_schema,'.',qi_l_name,' IS ''View of Facilities LoDx in schema ',qi_cdb_schema,''';
			ALTER TABLE ',qi_usr_schema,'.',qi_l_name,' OWNER TO ',qi_usr_name,';
		');
		-- Add triggers to make view updatable
		sql_trig := concat(sql_trig,qgis_pkg.generate_sql_triggers(usr_schema, l_name, trig_f_suffix));
		
		-- Add entry to update table layer_metadata
		sql_ins := concat(sql_ins,'
			(',ql_cdb_schema,',',ql_ade_prefix,',',ql_l_type,',',ql_feature_type,',',quote_literal(root_class),',',quote_literal(curr_class),',',quote_literal(lod),',
			 ',ql_l_name,',',ql_av_name,',',ql_gv_name,',',num_features,',clock_timestamp(),',quote_literal(qml_form_name),',',quote_literal(qml_symb_name),',',quote_literal(qml_3d_name),',
			 ',quote_nullable(enum_cols_array),',',quote_nullable(codelist_cols_array),'),');
		
		ELSE
			sql_layer := concat(sql_layer, qgis_pkg.generate_sql_matview_else(qi_usr_schema, ql_cdb_schema, ql_l_type, ql_l_name, qi_gv_name));
		END IF;	
	
	IF sql_ins IS NOT NULL THEN
		sql_ins := concat(sql_upd, substr(sql_ins,1, length(sql_ins)-1), ';');
	END IF;
	
	sql_statement := concat(sql_layer,sql_trig,sql_ins);
	RETURN sql_statement;
END;
$$ LANGUAGE plpgsql;	
COMMENT ON FUNCTION qgis_pkg.generate_sql_layers_ng_facilities(varchar,varchar,integer,integer,numeric,geometry,boolean,varchar) IS 'Generate SQL script to create layers for class Facilities';
REVOKE EXECUTE ON FUNCTION qgis_pkg.generate_sql_layers_ng_facilities(varchar,varchar,integer,integer,numeric,geometry,boolean,varchar) FROM public; 	

---------------------------------------------------------------------
-- CREATE FUNCTION qgis_pkg.generate_sql_layers_ng_occupants
---------------------------------------------------------------------
DROP FUNCTION IF EXISTS qgis_pkg.generate_sql_layers_ng_occupants(varchar,varchar,integer,integer,numeric,geometry,boolean,varchar) CASCADE;
CREATE OR REPLACE FUNCTION qgis_pkg.generate_sql_layers_ng_occupants(usr_name varchar,cdb_schema varchar,perform_snapping integer,digits integer,
								     area_poly_min numeric,mview_bbox geometry,force_layer_creation boolean,ade_prefix varchar)
RETURNS text AS $$
DECLARE
	feature_type CONSTANT varchar := 'Building';
	l_type				varchar := 'DetailViewNoGeom';

	qgis_user_group_name CONSTANT varchar := (SELECT qgis_pkg.create_qgis_pkg_usrgroup_name());

	usr_schema      	varchar := (SELECT qgis_pkg.create_qgis_usr_schema_name(usr_name));
	usr_names_array     varchar[] := (SELECT array_agg(s.usr_name) FROM qgis_pkg.list_qgis_pkg_usrgroup_members() AS s);
	usr_schemas_array 	varchar[] := (SELECT array_agg(s.usr_schema) FROM qgis_pkg.list_usr_schemas() AS s);
	cdb_schemas_array 	varchar[] := (SELECT array_agg(s.cdb_schema) FROM qgis_pkg.list_cdb_schemas() AS s);

	srid                integer;
	num_features    	bigint;

	root_class			varchar;
	curr_class			varchar;
	lod varchar;
	ql_feature_type varchar := quote_literal(feature_type);
	ql_l_type varchar := quote_literal(l_type);
	qi_cdb_schema varchar; ql_cdb_schema varchar;
	qi_usr_schema varchar; ql_usr_schema varchar; ql_ade_prefix varchar;
	qi_usr_name varchar; ql_usr_name varchar;ql_class varchar;
	l_name varchar; ql_l_name varchar; qi_l_name varchar;
	av_name varchar; ql_av_name varchar; qi_av_name varchar;
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
	enum_cols_array varchar[][] := NULL;
	codelist_cols_array varchar[][] := NULL;
	sql_co_atts varchar := 'co.id::bigint,co.gmlid,co.gmlid_codespace,co.name,
				co.name_codespace,co.description,co.creation_date,
				co.termination_date,co.last_modification_date,
				co.updating_person,co.reason_for_update,co.lineage,';

BEGIN
	-- check if user name exists
	IF NOT usr_name = ANY(usr_names_array) THEN
	RAISE EXCEPTION 'usr_name is invalid. It must be an existing database user and member of role (group) "%"',qgis_user_group_name;
	END IF;
	
	-- check if usr_schema exists
	IF NOT usr_schema = ANY(usr_schemas_array) THEN
	RAISE EXCEPTION 'usr_schema % does not exist. Please create it beforehand',usr_schema;
	END IF;
	
	-- check if cdb_schema exists
	IF NOT cdb_schema = ANY(cdb_schemas_array)  THEN
	RAISE EXCEPTION 'cdb_schema % is invalid. It must correspond to an existing city db schema',cdb_schema;
	END IF;

	-- add quote identifier (qi_) and quote literal (ql_) for later user in dynamic queries.
	qi_cdb_schema := quote_ident(cdb_schema);
	ql_cdb_schema := quote_literal(cdb_schema);
	qi_usr_name   := quote_ident(usr_name);
	ql_usr_name   := quote_literal(usr_name);
	qi_usr_schema := quote_ident(usr_schema);
	ql_usr_schema := quote_literal(usr_schema);
	ql_class := quote_literal('Occupants');
	ql_ade_prefix := quote_literal(ade_prefix);

	-- Prepare fixed part of SQL statements
	-- Remove previous entries from the layer_metadata Table, and insert it again.
	sql_upd := concat('
	DELETE FROM ',qi_usr_schema,'.layer_metadata AS l WHERE l.cdb_schema = ',ql_cdb_schema,' AND l.feature_type = ',ql_feature_type,' AND l.class = ',quote_literal('Occupants'),';
	INSERT INTO ',qi_usr_schema,'.layer_metadata 
	(cdb_schema, ade_prefix, layer_type, feature_type, root_class, class, lod, layer_name, gv_name, av_name, n_features, creation_date, qml_form, qml_symb, qml_3d, enum_cols, codelist_cols)
	VALUES');
	
	RAISE NOTICE 'For module "%" and user "%": creating layers in usr_schema "%" for cdb_schema "%"', feature_type, qi_usr_name, qi_usr_schema, qi_cdb_schema;
	
	-- Initialize variables.
	sql_layer := NULL; sql_ins := NULL; sql_trig := NULL;
	root_class := feature_type;

	-----------------------------------------------------------
	-- CREATE LAYER OCCUPANTS
	-----------------------------------------------------------
	sql_feat_count := concat('
		SELECT COUNT(ngo.id) FROM ',qi_cdb_schema,'.ng_occupants AS ngo
		INNER JOIN ',qi_cdb_schema,'.cityobject AS co ON ngo.id = co.id
	');

	EXECUTE sql_feat_count INTO num_features;

	RAISE NOTICE 'Found % features for Occupants',num_features; 

	curr_class := 'Occupants';
	lod := 'lodx';
	l_name := concat(cdb_schema,'_ng_occupants_lodx');
	av_name := concat('_a_',cdb_schema,'_ng_occupants');
	gv_name := ' ';
	qml_form_name := 'ng_occupants_form.qml';
	qml_symb_name := ' ';
	qml_3d_name := ' ';
	trig_f_suffix := 'ng_occupants';
	qi_l_name := quote_ident(l_name);
	ql_l_name := quote_literal(l_name);
	qi_av_name := quote_ident(av_name);
	ql_av_name := quote_literal(av_name);
	qi_gv_name := quote_ident(gv_name);
	ql_gv_name := quote_literal(gv_name);

	IF (num_features > 0) OR (force_layer_creation IS TRUE) THEN

		----------------------------------------------------
		-- VIEW FOR ATTRIBUTES
		----------------------------------------------------
		
		sql_layer := concat(sql_layer,qgis_pkg.generate_sql_view_header(qi_usr_schema,qi_l_name),'
			SELECT ',
		        sql_co_atts,'
			ngo.heatdissipation_id,
			ngo.numberofoccupants,
			ngo.occupancyrate_id,
			ngo.usagezone_occupiedby_id
			FROM ',qi_cdb_schema,'.ng_occupants AS ngo
			INNER JOIN ',qi_cdb_schema,'.cityobject AS co ON ngo.id = co.id;
			COMMENT ON VIEW ',qi_usr_schema,'.',qi_l_name,' IS ''View of Occupants LoDx in schema ',qi_cdb_schema,''';
			ALTER TABLE ',qi_usr_schema,'.',qi_l_name,' OWNER TO ',qi_usr_name,';
		');
		-- Add triggers to make view updatable
		sql_trig := concat(sql_trig,qgis_pkg.generate_sql_triggers(usr_schema, l_name, trig_f_suffix));
		
		-- Add entry to update table layer_metadata
		sql_ins := concat(sql_ins,'
			(',ql_cdb_schema,',',ql_ade_prefix,',',ql_l_type,',',ql_feature_type,',',quote_literal(root_class),',',quote_literal(curr_class),',',quote_literal(lod),',
			 ',ql_l_name,',',ql_gv_name,',',ql_av_name,',',num_features,',clock_timestamp(),',quote_literal(qml_form_name),',',quote_literal(qml_symb_name),',',quote_literal(qml_3d_name),',
			 ',quote_nullable(enum_cols_array),',',quote_nullable(codelist_cols_array),'),');
		
		ELSE
			sql_layer := concat(sql_layer, qgis_pkg.generate_sql_matview_else(qi_usr_schema, ql_cdb_schema, ql_l_type, ql_l_name, qi_gv_name));
		END IF;	
	
	IF sql_ins IS NOT NULL THEN
		sql_ins := concat(sql_upd, substr(sql_ins,1, length(sql_ins)-1), ';');
	END IF;
	
	sql_statement := concat(sql_layer,sql_trig,sql_ins);
	RETURN sql_statement;
END;
$$ LANGUAGE plpgsql;	
COMMENT ON FUNCTION qgis_pkg.generate_sql_layers_ng_occupants(varchar,varchar,integer,integer,numeric,geometry,boolean,varchar) IS 'Generate SQL script to create layers for class Occupants';
REVOKE EXECUTE ON FUNCTION qgis_pkg.generate_sql_layers_ng_occupants(varchar,varchar,integer,integer,numeric,geometry,boolean,varchar) FROM public; 

------------------------------------------------------------------------
-- CREATE FUNCTION qgis_pkg.generate_sql_layers_ng_thermalzone
------------------------------------------------------------------------

DROP FUNCTION IF EXISTS qgis_pkg.generate_sql_layers_ng_thermalzone(varchar,varchar,integer,integer,numeric,geometry,boolean,varchar) CASCADE;
CREATE OR REPLACE FUNCTION qgis_pkg.generate_sql_layers_ng_thermalzone(usr_name varchar,cdb_schema varchar,perform_snapping integer,digits integer,
								       area_poly_min numeric,mview_bbox geometry,force_layer_creation boolean,ade_prefix varchar)
RETURNS text AS $$
DECLARE
	feature_type CONSTANT varchar := 'Building';
	l_type				varchar := 'VectorLayer';
	qgis_user_group_name CONSTANT varchar := (SELECT qgis_pkg.create_qgis_pkg_usrgroup_name());
	usr_schema      	varchar := (SELECT qgis_pkg.create_qgis_usr_schema_name(usr_name));
	usr_names_array     varchar[] := (SELECT array_agg(s.usr_name) FROM qgis_pkg.list_qgis_pkg_usrgroup_members() AS s);
	usr_schemas_array 	varchar[] := (SELECT array_agg(s.usr_schema) FROM qgis_pkg.list_usr_schemas() AS s);
	cdb_schemas_array 	varchar[] := (SELECT array_agg(s.cdb_schema) FROM qgis_pkg.list_cdb_schemas() AS s);
	srid                integer;
	num_features    	bigint;
	root_class			varchar;
	curr_class			varchar;
	ql_feature_type varchar := quote_literal(feature_type);
	ql_l_type varchar := quote_literal(l_type);
	qi_cdb_schema varchar; ql_cdb_schema varchar;
	qi_usr_schema varchar; ql_usr_schema varchar; ql_ade_prefix varchar;
	qi_usr_name varchar; ql_usr_name varchar;ql_class varchar;
	l_name varchar; ql_l_name varchar; qi_l_name varchar;
	av_name varchar; ql_av_name varchar; qi_av_name varchar;
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
	enum_cols_array varchar[][] := ARRAY[['cityobject','relative_to_terrain'],['cityobject','relative_to_water']];
	codelist_cols_array varchar[][] := NULL;
	sql_co_atts varchar := 'co.id::bigint,co.gmlid,co.gmlid_codespace,co.name,
				co.name_codespace,co.description,co.creation_date,
				co.termination_date,co.relative_to_terrain,
				co.relative_to_water,co.last_modification_date,
				co.updating_person,co.reason_for_update,co.lineage,';

BEGIN
	-- check if user name exists
	IF NOT usr_name = ANY(usr_names_array) THEN
	RAISE EXCEPTION 'usr_name is invalid. It must be an existing database user and member of role (group) "%"',qgis_user_group_name;
	END IF;
	
	-- check if usr_schema exists
	IF NOT usr_schema = ANY(usr_schemas_array) THEN
	RAISE EXCEPTION 'usr_schema % does not exist. Please create it beforehand',usr_schema;
	END IF;
	
	-- check if cdb_schema exists
	IF NOT cdb_schema = ANY(cdb_schemas_array)  THEN
	RAISE EXCEPTION 'cdb_schema % is invalid. It must correspond to an existing city db schema',cdb_schema;
	END IF;

	-- add quote identifier (qi_) and quote literal (ql_) for later user in dynamic queries.
	qi_cdb_schema := quote_ident(cdb_schema);
	ql_cdb_schema := quote_literal(cdb_schema);
	qi_usr_name   := quote_ident(usr_name);
	ql_usr_name   := quote_literal(usr_name);
	qi_usr_schema := quote_ident(usr_schema);
	ql_usr_schema := quote_literal(usr_schema);
	ql_class := quote_literal('ThermalZone');
	ql_ade_prefix := quote_literal(ade_prefix);

	-- Prepare fixed part of SQL statements
	-- Remove previous entries from the layer_metadata Table, and insert it again.
	sql_upd := concat('
	DELETE FROM ',qi_usr_schema,'.layer_metadata AS l WHERE l.cdb_schema = ',ql_cdb_schema,' AND l.feature_type = ',ql_feature_type,' AND l.class LIKE ',quote_literal('Thermal%'),';
	INSERT INTO ',qi_usr_schema,'.layer_metadata 
	(cdb_schema, ade_prefix, layer_type, feature_type, root_class, class, lod, layer_name, av_name, gv_name, n_features, creation_date, qml_form, qml_symb, qml_3d, enum_cols, codelist_cols)
	VALUES');

	-- Get the srid from the cdb_schema
	EXECUTE format('SELECT srid FROM %I.database_srs LIMIT 1', cdb_schema) INTO srid;

	-- Check the mview bbox (the red bbox from the plugin, for example)
	-- Check that the srid is the same if the mview_box
	-- Prepare the slq where part to be added to the queries, if the bbox is needed.
	IF ST_SRID(mview_bbox) IS NULL OR ST_SRID(mview_bbox) <> srid THEN
	-- No bbox where condition
	sql_where := NULL;
	ELSE
	-- Yes, we will perform also a spatial query based on the envelope column in the CITYOBJECT table
	sql_where := concat('AND ST_MakeEnvelope(', floor(ST_XMin(mview_bbox)),', ', floor(ST_YMin(mview_bbox)),', ', ceil(ST_XMax(mview_bbox)),', ',	ceil(ST_YMax(mview_bbox)),', ',	srid,')
		  	     && co.envelope');
	END IF;
	
	RAISE NOTICE 'For module "%" and user "%": creating layers in usr_schema "%" for cdb_schema "%"', feature_type, qi_usr_name, qi_usr_schema, qi_cdb_schema;
	
	-- Initialize variables.
	sql_layer := NULL; sql_ins := NULL; sql_trig := NULL;
	root_class := feature_type;

	------------------------------------------------------------
	-- CREATE LAYER THERMALZONE
	------------------------------------------------------------
	FOR r IN 
		SELECT * FROM (VALUES
		('ThermalZone','50013'::integer,'tz'::varchar)
		) AS t(class_name,class_id,class_label)
	LOOP
		---------------------------------------------------
		-- LODX (new LOD for non-CityGML features)
		---------------------------------------------------
		FOR t IN 
			SELECT * FROM (VALUES
			('LoDX'::varchar,'lodx'::varchar))
			AS t(lodx_name,lodx_label)
		LOOP
		-- BOTH LOOPS NOT NECESSARY
		-- CAN BE REFACTORED LATER

			-- check if there are any features at all in the db schema
			sql_feat_count := concat('
				SELECT COUNT(*) FROM ',qi_cdb_schema,'.ng_thermalzone AS tz
				INNER JOIN ',qi_cdb_schema,'.cityobject AS co ON (tz.id = co.id ',sql_where,')
			');
			EXECUTE sql_feat_count INTO num_features;
			RAISE NOTICE 'Found % features for % %',num_features,r.class_name,t.lodx_name;
			curr_class := r.class_name;
			l_name := concat(cdb_schema,'_ng_thermalzone_lodx');
			av_name := concat('_a_',cdb_schema,'_ng_thermalzone_lodx');
			gv_name := concat('_g_',l_name);
			qml_form_name := concat('ng_thermalzone_form.qml');
			qml_symb_name := 'poly_red_symb.qml';
			qml_3d_name := 'poly_red_3d.qml';
			trig_f_suffix := 'ng_thermalzone';
			qi_l_name := quote_ident(l_name);
			ql_l_name := quote_literal(l_name);
			qi_gv_name := quote_ident(gv_name);
			ql_gv_name := quote_literal(gv_name);
			qi_av_name := quote_ident(av_name);
			ql_av_name := quote_literal(av_name);
			
			IF (num_features > 0) OR (force_layer_creation IS TRUE) THEN
			-------------------------------------------------------------------
			-- MATERIALIZED VIEW FOR GEOMETRY (thermalzone id == cityobject id)
			-------------------------------------------------------------------
			sql_layer := concat(sql_layer,qgis_pkg.generate_sql_matview_header(qi_usr_schema,qi_gv_name),'
					    WITH itab2 AS
						(
							SELECT itab.id,st_collect(itab.geom)::geometry AS geom
							FROM 
								(
									SELECT tz.id,((st_dump(sg.solid_geometry)).geom) as geom
									FROM ',qi_cdb_schema,'.ng_thermalzone AS tz
									JOIN ',qi_cdb_schema,'.surface_geometry AS sg
									ON tz.volumegeometry_id = sg.id
									WHERE sg.solid_geometry IS NOT null
								) AS itab
							GROUP BY itab.id
						),
						itab3 AS
						(
							SELECT tz.id,st_collect(sg.geometry) AS geom
							FROM ',qi_cdb_schema,'.ng_thermalboundary AS tb
							INNER JOIN ',qi_cdb_schema,'.ng_thermalzone AS tz
							ON tb.thermalzone_boundedby_id = tz.id
							INNER JOIN ',qi_cdb_schema,'.surface_geometry AS sg
							ON tb.surfacegeometry_id = sg.root_id
							WHERE sg.geometry IS NOT null
							GROUP BY tz.id
						)
					    SELECT tz.id AS co_id,
					    CASE
						WHEN tz.volumegeometry_id IS null THEN 
							(SELECT itab3.geom FROM itab3 WHERE itab3.id = tz.id)
						ELSE 
							(SELECT itab2.geom FROM itab2 WHERE itab2.id = tz.id)
					    END AS geom
					    FROM ',qi_cdb_schema,'.ng_thermalzone AS tz
					    WITH NO DATA;
					    COMMENT ON MATERIALIZED VIEW ',qi_usr_schema,'.',qi_gv_name,' IS ''Mat. view of ',r.class_name,' ',t.lodx_name,' in schema ',qi_cdb_schema,''';',
					    qgis_pkg.generate_sql_matview_footer(qi_usr_name,qi_usr_schema,ql_l_name,qi_gv_name));
			-------------------------------------------------------------
			-- VIEW FOR ATTRIBUTES + GEOMETRY
			-------------------------------------------------------------
			-- attributes obtained from ng_thermalzone
			sql_layer := concat(sql_layer,qgis_pkg.generate_sql_view_header(qi_usr_schema,qi_l_name),'
					    SELECT
				            ngco.id AS ng_co_id,',
					    sql_co_atts,
					    'tz.building_thermalzone_id,
					     tz.infiltrationrate,
					     tz.infiltrationrate_uom,
					     tz.iscooled,
					     tz.isheated,
					     g.geom::geometry(MultiPolygonZ,',srid,')
					     FROM ',qi_usr_schema,'.',qi_gv_name,' AS g
					     INNER JOIN ',qi_cdb_schema,'.cityobject AS co ON g.co_id = co.id
					     INNER JOIN ',qi_cdb_schema,'.ng_thermalzone AS tz ON g.co_id = tz.id
					     LEFT OUTER JOIN ',qi_cdb_schema,'.ng_cityobject AS ngco ON tz.id = ngco.id;
					     COMMENT ON VIEW ',qi_usr_schema,'.',qi_l_name,' IS ''View of ',r.class_name,' ',t.lodx_name,' in schema ',qi_cdb_schema,''';
					     ALTER TABLE ',qi_usr_schema,'.',qi_l_name,' OWNER TO ',qi_usr_name,';
			');	
			
			-- add triggers to make the view updatable
			sql_trig := concat(sql_trig,qgis_pkg.generate_sql_triggers(usr_schema,l_name,trig_f_suffix));	
			sql_ins := concat(sql_ins,'
				(',ql_cdb_schema,',',ql_ade_prefix,',',ql_l_type,',',ql_feature_type,',',quote_literal(root_class),',',quote_literal(curr_class),',',quote_literal(t.lodx_label),',
				 ',ql_l_name,',',ql_av_name,',',ql_gv_name,',',num_features,',clock_timestamp(),',quote_literal(qml_form_name),',',quote_literal(qml_symb_name),',
				 ',quote_literal(qml_3d_name),',',quote_nullable(enum_cols_array),',',quote_nullable(codelist_cols_array),'),');
			ELSE
				sql_layer := concat(sql_layer,qgis_pkg.generate_matview_else(qi_usr_schema,ql_cdb_schema,ql_l_type,ql_l_name,qi_gv_name));
			END IF;
			
		END LOOP; -- lodX 

	END LOOP; -- thermalzone
	
	IF sql_ins IS NOT NULL THEN
		sql_ins := concat(sql_upd, substr(sql_ins,1, length(sql_ins)-1), ';');
	END IF;
	
	sql_statement := concat(sql_layer,sql_trig,sql_ins);
	RETURN sql_statement;
END;
$$ LANGUAGE plpgsql;	
COMMENT ON FUNCTION qgis_pkg.generate_sql_layers_ng_thermalzone(varchar,varchar,integer,integer,numeric,geometry,boolean,varchar) IS 'Generate SQL script to create layers for class ThermalZone';
REVOKE EXECUTE ON FUNCTION qgis_pkg.generate_sql_layers_ng_thermalzone(varchar,varchar,integer,integer,numeric,geometry,boolean,varchar) FROM public; 	

--------------------------------------------------------------------------
-- CREATE FUNCTION qgis_pkg.generate_sql_layers_ng_thermalboundary
--------------------------------------------------------------------------
DROP FUNCTION IF EXISTS qgis_pkg.generate_sql_layers_ng_thermalboundary(varchar,varchar,integer,integer,numeric,geometry,boolean,varchar) CASCADE;
CREATE OR REPLACE FUNCTION qgis_pkg.generate_sql_layers_ng_thermalboundary(usr_name varchar,cdb_schema varchar,perform_snapping integer,digits integer,
								           area_poly_min numeric,mview_bbox geometry,force_layer_creation boolean,ade_prefix varchar)
RETURNS text AS $$
DECLARE
	feature_type CONSTANT varchar := 'Building';
	l_type				varchar := 'VectorLayer';

	qgis_user_group_name CONSTANT varchar := (SELECT qgis_pkg.create_qgis_pkg_usrgroup_name());

	usr_schema      	varchar := (SELECT qgis_pkg.create_qgis_usr_schema_name(usr_name));
	usr_names_array     varchar[] := (SELECT array_agg(s.usr_name) FROM qgis_pkg.list_qgis_pkg_usrgroup_members() AS s);
	usr_schemas_array 	varchar[] := (SELECT array_agg(s.usr_schema) FROM qgis_pkg.list_usr_schemas() AS s);
	cdb_schemas_array 	varchar[] := (SELECT array_agg(s.cdb_schema) FROM qgis_pkg.list_cdb_schemas() AS s);

	srid                integer;
	num_features    	bigint;

	root_class			varchar;
	curr_class			varchar;

	ql_feature_type varchar := quote_literal(feature_type);
	ql_l_type varchar := quote_literal(l_type);
	qi_cdb_schema varchar; ql_cdb_schema varchar;
	qi_usr_schema varchar; ql_usr_schema varchar; ql_ade_prefix varchar;
	qi_usr_name varchar; ql_usr_name varchar;ql_class varchar;
	l_name varchar; ql_l_name varchar; qi_l_name varchar;
	av_name varchar; ql_av_name varchar; qi_av_name varchar;
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
	enum_cols_array varchar[][] := ARRAY[['cityobject','relative_to_terrain'],['cityobject','relative_to_water'],['ng_thermalboundary','thermalboundarytype']];
	codelist_cols_array varchar[][] := NULL;
	sql_co_atts varchar := 'co.id::bigint,co.gmlid,co.gmlid_codespace,co.name,
				co.name_codespace,co.description,co.creation_date,
				co.termination_date,co.relative_to_terrain,
				co.relative_to_water,co.last_modification_date,
				co.updating_person,co.reason_for_update,co.lineage,';

BEGIN
	-- check if user name exists
	IF NOT usr_name = ANY(usr_names_array) THEN
	RAISE EXCEPTION 'usr_name is invalid. It must be an existing database user and member of role (group) "%"',qgis_user_group_name;
	END IF;
	
	-- check if usr_schema exists
	IF NOT usr_schema = ANY(usr_schemas_array) THEN
	RAISE EXCEPTION 'usr_schema % does not exist. Please create it beforehand',usr_schema;
	END IF;
	
	-- check if cdb_schema exists
	IF NOT cdb_schema = ANY(cdb_schemas_array)  THEN
	RAISE EXCEPTION 'cdb_schema % is invalid. It must correspond to an existing city db schema',cdb_schema;
	END IF;

	-- add quote identifier (qi_) and quote literal (ql_) for later user in dynamic queries.
	qi_cdb_schema := quote_ident(cdb_schema);
	ql_cdb_schema := quote_literal(cdb_schema);
	qi_usr_name   := quote_ident(usr_name);
	ql_usr_name   := quote_literal(usr_name);
	qi_usr_schema := quote_ident(usr_schema);
	ql_usr_schema := quote_literal(usr_schema);
	ql_class := quote_literal('ThermalBoundary');
	ql_ade_prefix = quote_literal(ade_prefix);
	
	-- Prepare fixed part of SQL statements
	-- Remove previous entries from the layer_metadata Table, and insert it again.
	sql_upd := concat('
	--DELETE FROM ',qi_usr_schema,'.layer_metadata AS l WHERE l.cdb_schema = ',ql_cdb_schema,' AND l.feature_type = ',ql_feature_type,' AND l.layer_name LIKE  ',quote_literal('Thermal%'),';
	INSERT INTO ',qi_usr_schema,'.layer_metadata 
	(cdb_schema, ade_prefix, layer_type, feature_type, root_class, class, lod, layer_name, av_name, gv_name, n_features, creation_date, qml_form, qml_symb, qml_3d, enum_cols, codelist_cols)
	VALUES');

	-- Get the srid from the cdb_schema
	EXECUTE format('SELECT srid FROM %I.database_srs LIMIT 1', cdb_schema) INTO srid;

	-- Check the mview bbox (the red bbox from the plugin, for example)
	-- Check that the srid is the same if the mview_box
	-- Prepare the slq where part to be added to the queries, if the bbox is needed.
	IF ST_SRID(mview_bbox) IS NULL OR ST_SRID(mview_bbox) <> srid THEN
	-- No bbox where condition
	sql_where := NULL;
	ELSE
	-- Yes, we will perform also a spatial query based on the envelope column in the CITYOBJECT table
	sql_where := concat('AND ST_MakeEnvelope(', floor(ST_XMin(mview_bbox)),', ', floor(ST_YMin(mview_bbox)),', ', ceil(ST_XMax(mview_bbox)),', ',	ceil(ST_YMax(mview_bbox)),', ',	srid,')
		  	     && co.envelope');
	END IF;
	
	RAISE NOTICE 'For module "%" and user "%": creating layers in usr_schema "%" for cdb_schema "%"', feature_type, qi_usr_name, qi_usr_schema, qi_cdb_schema;
	
	-- Initialize variables.
	sql_layer := NULL; sql_ins := NULL; sql_trig := NULL;
	root_class := feature_type;

	--------------------------------------------------------------------
	-- CREATE LAYER THERMALBOUNDARY
	--------------------------------------------------------------------
	FOR r IN 
		SELECT * FROM (VALUES
		('ThermalBoundary','50011'::integer,'tb'::varchar)
		) AS t(class_name,class_id,class_label)
	LOOP
		---------------------------------------------------
		-- LODX (new LOD for non-CityGML features)
		---------------------------------------------------
		FOR t IN
			SELECT * FROM (VALUES
			('LoDX','lodx')
			) AS t(lodx_name,lodx_label)
		LOOP
		-- BOTH LOOPS NOT NECESSARY
		-- CAN BE REFACTORED LATER

			sql_feat_count := concat('
				SELECT COUNT(*) AS n_features FROM ',qi_cdb_schema,'.ng_thermalboundary AS tb
				INNER JOIN ',qi_cdb_schema,'.cityobject AS co ON (tb.id = co.id ',sql_where,')
				INNER JOIN ',qi_cdb_schema,'.surface_geometry AS sg ON co.id = sg.cityobject_id
				WHERE sg.geometry IS NOT NULL
			');
			EXECUTE sql_feat_count INTO num_features;
			RAISE NOTICE 'Found % features for %',num_features,r.class_name;
			curr_class := r.class_name;
			l_name := concat(cdb_schema,'_ng_thermalboundary_lodx');
			av_name	:= concat('_a_',cdb_schema,'_ng_thermalboundary');
			gv_name := concat('_g_',l_name);
			qml_form_name := concat('ng_thermalboundary_form.qml');
			qml_symb_name := 'poly_red_symb.qml';
			qml_3d_name := 'poly_red_3d.qml';
			trig_f_suffix := 'ng_thermalboundary';
			qi_l_name := quote_ident(l_name);
			ql_l_name := quote_literal(l_name);
			qi_gv_name := quote_ident(gv_name);
			ql_gv_name := quote_literal(gv_name);
			qi_av_name := quote_ident(av_name);
			ql_av_name := quote_literal(av_name);

			IF (num_features > 0) OR (force_layer_creation IS TRUE) THEN

			------------------------------------------------------------
			-- MATERIALIZED VIEW FOR GEOMETRY
			------------------------------------------------------------
			sql_layer := concat(sql_layer,qgis_pkg.generate_sql_matview_header(qi_usr_schema,qi_gv_name),'
				SELECT sg.cityobject_id AS co_id, 
				       ST_Collect(qgis_pkg.ST_snap_poly_to_grid(sg.geometry,',perform_snapping,',',digits,',',area_poly_min,'))::geometry(MultiPolygonZ,',srid,') AS geom
				FROM ',qi_cdb_schema,'.ng_thermalboundary AS tb
				INNER JOIN ',qi_cdb_schema,'.cityobject AS co ON (tb.id = co.id ',sql_where,')
				INNER JOIN ',qi_cdb_schema,'.surface_geometry AS sg ON co.id = sg.cityobject_id
				WHERE sg.geometry IS NOT NULL
				GROUP BY sg.cityobject_id
				WITH NO DATA;
				COMMENT ON MATERIALIZED VIEW ',qi_usr_schema,'.',qi_gv_name,' IS ''Mat. view of ',r.class_name,' ',t.lodx_name,' in schema ',qi_cdb_schema,''';',
				qgis_pkg.generate_sql_matview_footer(qi_usr_name,qi_usr_schema,ql_l_name,qi_gv_name));
			
			------------------------------------------------------------
			-- VIEW FOR ATTRIBUTES + GEOMETRY
			------------------------------------------------------------
			sql_layer := concat(sql_layer,qgis_pkg.generate_sql_view_header(qi_usr_schema,qi_l_name),'
				SELECT
				ngco.id AS ng_co_id,',
				sql_co_atts,'
				tb.area,
				tb.area_uom,
				tb.azimuth,
				tb.azimuth_uom,
				tb.construction_id,
				tb.inclination,
				tb.inclination_uom,
				tb.thermalboundarytype,
				tb.thermalzone_boundedby_id,
				g.geom::geometry(MultiPolygonZ,',srid,')
				FROM ',qi_usr_schema,'.',qi_gv_name,' AS g
				INNER JOIN ',qi_cdb_schema,'.ng_thermalboundary as tb ON g.co_id = tb.id
				INNER JOIN ',qi_cdb_schema,'.cityobject AS co ON tb.id = co.id
				LEFT OUTER JOIN ',qi_cdb_schema,'.ng_cityobject AS ngco ON co.id = ngco.id;
				COMMENT ON VIEW ',qi_usr_schema,'.',qi_l_name,' IS ''View of ',r.class_name,' ',t.lodx_name,' in schema ',qi_cdb_schema,''';
				ALTER TABLE ',qi_usr_schema,'.',qi_l_name,' OWNER TO ',qi_usr_name,';
			');
			
			-- Add triggers to make view updatable
			sql_trig := concat(sql_trig,qgis_pkg.generate_sql_triggers(usr_schema, l_name, trig_f_suffix));
			-- Add entry to update table layer_metadata
			sql_ins := concat(sql_ins,'
				(',ql_cdb_schema,',',ql_ade_prefix,',',ql_l_type,',',ql_feature_type,',',quote_literal(root_class),',',quote_literal(curr_class),',',quote_literal(t.lodx_label),',
				 ',ql_l_name,',',ql_av_name,',',ql_gv_name,',',num_features,',clock_timestamp(),',quote_literal(qml_form_name),',',quote_literal(qml_symb_name),',
				 ',quote_literal(qml_3d_name),',',quote_nullable(enum_cols_array),',',quote_nullable(codelist_cols_array),'),');
			ELSE
				sql_layer := concat(sql_layer, qgis_pkg.generate_sql_matview_else(qi_usr_schema, ql_cdb_schema, ql_l_type, ql_l_name, qi_gv_name));
			END IF;	

		END LOOP; -- lodx
	END LOOP; -- thermalboundary

	IF sql_ins IS NOT NULL THEN
		sql_ins := concat(sql_upd, substr(sql_ins,1, length(sql_ins)-1), ';');
	END IF;

	sql_statement := concat(sql_layer,sql_trig,sql_ins);
	RETURN sql_statement;
END;
$$ LANGUAGE plpgsql;	
COMMENT ON FUNCTION qgis_pkg.generate_sql_layers_ng_thermalboundary(varchar,varchar,integer,integer,numeric,geometry,boolean,varchar) IS 'Generate SQL script to create layers for class ThermalBoundary';
REVOKE EXECUTE ON FUNCTION qgis_pkg.generate_sql_layers_ng_thermalboundary(varchar,varchar,integer,integer,numeric,geometry,boolean,varchar) FROM public; 	

---------------------------------------------------------------------
-- CREATE FUNCTION qgis_pkg.generate_sql_layers_ng_thermalopening
---------------------------------------------------------------------
DROP FUNCTION IF EXISTS qgis_pkg.generate_sql_layers_ng_thermalopening(varchar,varchar,integer,integer,numeric,geometry,boolean,varchar) CASCADE;
CREATE OR REPLACE FUNCTION qgis_pkg.generate_sql_layers_ng_thermalopening(usr_name varchar,cdb_schema varchar,perform_snapping integer,digits integer,
								          area_poly_min numeric,mview_bbox geometry,force_layer_creation boolean,ade_prefix varchar)
RETURNS text AS $$
DECLARE
	feature_type CONSTANT varchar := 'Building';
	l_type				varchar := 'VectorLayer';

	qgis_user_group_name CONSTANT varchar := (SELECT qgis_pkg.create_qgis_pkg_usrgroup_name());
	usr_schema      	varchar := (SELECT qgis_pkg.create_qgis_usr_schema_name(usr_name));
	usr_names_array     varchar[] := (SELECT array_agg(s.usr_name) FROM qgis_pkg.list_qgis_pkg_usrgroup_members() AS s);
	usr_schemas_array 	varchar[] := (SELECT array_agg(s.usr_schema) FROM qgis_pkg.list_usr_schemas() AS s);
	cdb_schemas_array 	varchar[] := (SELECT array_agg(s.cdb_schema) FROM qgis_pkg.list_cdb_schemas() AS s);

	srid                integer;
	num_features    	bigint;
	root_class			varchar;
	curr_class			varchar;
	lod varchar;
	ql_feature_type varchar := quote_literal(feature_type);
	ql_l_type varchar := quote_literal(l_type);
	qi_cdb_schema varchar; ql_cdb_schema varchar;
	qi_usr_schema varchar; ql_usr_schema varchar; ql_ade_prefix varchar;
	qi_usr_name varchar; ql_usr_name varchar;ql_class varchar;
	l_name varchar; ql_l_name varchar; qi_l_name varchar;
	av_name varchar; ql_av_name varchar; qi_av_name varchar;
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
	enum_cols_array varchar[][] := ARRAY[['cityobject','relative_to_terrain'],['cityobject','relative_to_water']];
	codelist_cols_array varchar[][] := NULL;
	sql_co_atts varchar := 'co.id::bigint,co.gmlid,co.gmlid_codespace,co.name,
				co.name_codespace,co.description,co.creation_date,
				co.termination_date,co.relative_to_terrain,
				co.relative_to_water,co.last_modification_date,
				co.updating_person,co.reason_for_update,co.lineage,';

BEGIN
	-- check if user name exists
	IF NOT usr_name = ANY(usr_names_array) THEN
	RAISE EXCEPTION 'usr_name is invalid. It must be an existing database user and member of role (group) "%"',qgis_user_group_name;
	END IF;
	
	-- check if usr_schema exists
	IF NOT usr_schema = ANY(usr_schemas_array) THEN
	RAISE EXCEPTION 'usr_schema % does not exist. Please create it beforehand',usr_schema;
	END IF;
	
	-- check if cdb_schema exists
	IF NOT cdb_schema = ANY(cdb_schemas_array)  THEN
	RAISE EXCEPTION 'cdb_schema % is invalid. It must correspond to an existing city db schema',cdb_schema;
	END IF;

	-- add quote identifier (qi_) and quote literal (ql_) for later user in dynamic queries.
	qi_cdb_schema := quote_ident(cdb_schema);
	ql_cdb_schema := quote_literal(cdb_schema);
	qi_usr_name   := quote_ident(usr_name);
	ql_usr_name   := quote_literal(usr_name);
	qi_usr_schema := quote_ident(usr_schema);
	ql_usr_schema := quote_literal(usr_schema);
	ql_class := quote_literal('ThermalOpening');
	ql_ade_prefix := quote_literal(ade_prefix);

	-- Prepare fixed part of SQL statements
	-- Remove previous entries from the layer_metadata Table, and insert it again.
	sql_upd := concat('
	--DELETE FROM ',qi_usr_schema,'.layer_metadata AS l WHERE l.cdb_schema = ',ql_cdb_schema,' AND l.feature_type = ',ql_feature_type,' AND l.layer_name LIKE  ',quote_literal('Thermal%'),';
	INSERT INTO ',qi_usr_schema,'.layer_metadata 
	(cdb_schema, ade_prefix, layer_type, feature_type, root_class, class, lod, layer_name, av_name, gv_name, n_features, creation_date, qml_form, qml_symb, qml_3d, enum_cols, codelist_cols)
	VALUES');

	-- Get the srid from the cdb_schema
	EXECUTE format('SELECT srid FROM %I.database_srs LIMIT 1', cdb_schema) INTO srid;

	-- Check the mview bbox (the red bbox from the plugin, for example)
	-- Check that the srid is the same if the mview_box
	-- Prepare the slq where part to be added to the queries, if the bbox is needed.
	IF ST_SRID(mview_bbox) IS NULL OR ST_SRID(mview_bbox) <> srid THEN
	-- No bbox where condition
	sql_where := NULL;
	ELSE
	-- Yes, we will perform also a spatial query based on the envelope column in the CITYOBJECT table
	sql_where := concat('AND ST_MakeEnvelope(', floor(ST_XMin(mview_bbox)),', ', floor(ST_YMin(mview_bbox)),', ', ceil(ST_XMax(mview_bbox)),', ',	ceil(ST_YMax(mview_bbox)),', ',	srid,')
		  	     && co.envelope');
	END IF;
	
	RAISE NOTICE 'For module "%" and user "%": creating layers in usr_schema "%" for cdb_schema "%"', feature_type, qi_usr_name, qi_usr_schema, qi_cdb_schema;
	
	-- Initialize variables.
	sql_layer := NULL; sql_ins := NULL; sql_trig := NULL;
	root_class := feature_type;

	-----------------------------------------------------------
	-- CREATE LAYER THERMALOPENING
	-----------------------------------------------------------
	sql_feat_count := concat('
		SELECT COUNT(*) FROM ',qi_cdb_schema,'.ng_thermalopening AS ngto
		INNER JOIN ',qi_cdb_schema,'.cityobject AS co ON (ngto.id = co.id ',sql_where,')
		INNER JOIN ',qi_cdb_schema,'.surface_geometry AS sg ON co.id = sg.cityobject_id
		WHERE sg.geometry IS NOT NULL
	');
	EXECUTE sql_feat_count INTO num_features;
	RAISE NOTICE 'Found % features for ThermalOpening',num_features; 
	curr_class := 'ThermalOpening';
	lod := 'lodx';
	l_name := concat(cdb_schema,'_ng_thermalopening_lodx');
	av_name := concat('_a_',cdb_schema,'_ng_thermalopening');
	gv_name := concat('_g_',l_name);
	qml_form_name := 'ng_thermalopening_form.qml';
	qml_symb_name := 'poly_red_semi_transp_symb.qml';
	qml_3d_name := 'poly_red_transp_3d.qml';
	trig_f_suffix := 'ng_thermalopening';
	qi_l_name := quote_ident(l_name);
	ql_l_name := quote_literal(l_name);
	qi_av_name := quote_ident(av_name);
	ql_av_name := quote_literal(av_name);
	qi_gv_name := quote_ident(gv_name);
	ql_gv_name := quote_literal(gv_name);

	IF (num_features > 0) OR (force_layer_creation IS TRUE) THEN

		----------------------------------------------------
		-- MATERIALIZED VIEW FOR GEOMETRY
		----------------------------------------------------
	
		sql_layer := concat(sql_layer,qgis_pkg.generate_sql_matview_header(qi_usr_schema,qi_gv_name),'
			SELECT ngto.id AS co_id,
			       ST_Collect(qgis_pkg.ST_snap_poly_to_grid(sg.geometry,',perform_snapping,',',digits,',',area_poly_min,'))::geometry(MultiPolygonZ,',srid,') AS geom
			FROM ',qi_cdb_schema,'.ng_thermalopening AS ngto
			INNER JOIN ',qi_cdb_schema,'.cityobject AS co ON (ngto.id = co.id ',sql_where,')
			INNER JOIN ',qi_cdb_schema,'.surface_geometry AS sg ON co.id = sg.cityobject_id
			WHERE sg.geometry IS NOT NULL
			GROUP BY ngto.id
			WITH NO DATA;
			COMMENT ON MATERIALIZED VIEW ',qi_usr_schema,'.',qi_gv_name,' IS ''Mat. view of ThermalOpening LoDx in schema ',qi_cdb_schema,''';',
			qgis_pkg.generate_sql_matview_footer(qi_usr_name,qi_usr_schema,ql_l_name,qi_gv_name)
		);
		
		----------------------------------------------------
		-- VIEW FOR ATTRIBUTES + GEOMETRY
		----------------------------------------------------
		
		sql_layer := concat(sql_layer,qgis_pkg.generate_sql_view_header(qi_usr_schema,qi_l_name),'
			SELECT
			ngco.id AS ng_co_id,',
			sql_co_atts,'
			ngto.area,
			ngto.area_uom,
			ngto.construction_id,
			ngto.thermalboundary_contains_id,
			g.geom::geometry(MultiPolygonZ,',srid,')
			FROM ',qi_usr_schema,'.',qi_gv_name,' AS g
			INNER JOIN ',qi_cdb_schema,'.ng_thermalopening AS ngto ON g.co_id = ngto.id
			INNER JOIN ',qi_cdb_schema,'.cityobject AS co ON (ngto.id = co.id ',sql_where,')
			LEFT OUTER JOIN ',qi_cdb_schema,'.ng_cityobject AS ngco ON co.id = ngco.id;
			COMMENT ON VIEW ',qi_usr_schema,'.',qi_l_name,' IS ''View of ThermalOpening LoDx in schema ',qi_cdb_schema,''';
			ALTER TABLE ',qi_usr_schema,'.',qi_l_name,' OWNER TO ',qi_usr_name,';
		');
		-- Add triggers to make view updatable
		sql_trig := concat(sql_trig,qgis_pkg.generate_sql_triggers(usr_schema, l_name, trig_f_suffix));
		
		-- Add entry to update table layer_metadata
		sql_ins := concat(sql_ins,'
			(',ql_cdb_schema,',',ql_ade_prefix,',',ql_l_type,',',ql_feature_type,',',quote_literal(root_class),',',quote_literal(curr_class),',',quote_literal(lod),',
			 ',ql_l_name,',',ql_av_name,',',ql_gv_name,',',num_features,',clock_timestamp(),',quote_literal(qml_form_name),',',quote_literal(qml_symb_name),',
			 ',quote_literal(qml_3d_name),',',quote_nullable(enum_cols_array),',',quote_nullable(codelist_cols_array),'),');
		
		ELSE
			sql_layer := concat(sql_layer, qgis_pkg.generate_sql_matview_else(qi_usr_schema, ql_cdb_schema, ql_l_type, ql_l_name, qi_gv_name));
		END IF;	
	
	IF sql_ins IS NOT NULL THEN
		sql_ins := concat(sql_upd, substr(sql_ins,1, length(sql_ins)-1), ';');
	END IF;
	
	sql_statement := concat(sql_layer,sql_trig,sql_ins);
	RETURN sql_statement;
END;
$$ LANGUAGE plpgsql;	
COMMENT ON FUNCTION qgis_pkg.generate_sql_layers_ng_thermalopening(varchar,varchar,integer,integer,numeric,geometry,boolean,varchar) IS 'Generate SQL script to create layers for class ThermalOpening';
REVOKE EXECUTE ON FUNCTION qgis_pkg.generate_sql_layers_ng_thermalopening(varchar,varchar,integer,integer,numeric,geometry,boolean,varchar) FROM public; 	

---------------------------------------------------------------------
-- CREATE FUNCTION qgis_pkg.generate_sql_layers_ng_weatherstation
---------------------------------------------------------------------
DROP FUNCTION IF EXISTS qgis_pkg.generate_sql_layers_ng_weatherstation(varchar,varchar,integer,integer,numeric,geometry,boolean) CASCADE;
CREATE OR REPLACE FUNCTION qgis_pkg.generate_sql_layers_ng_weatherstation(usr_name varchar,cdb_schema varchar,perform_snapping integer,digits integer,
								          area_poly_min numeric,mview_bbox geometry,force_layer_creation boolean)
RETURNS text AS $$
DECLARE
	feature_type CONSTANT varchar := 'WeatherStation';
	l_type varchar := 'VectorLayer';

	qgis_user_group_name CONSTANT varchar := (SELECT qgis_pkg.create_qgis_pkg_usrgroup_name());

	usr_schema varchar := (SELECT qgis_pkg.create_qgis_usr_schema_name(usr_name));
	usr_names_array varchar[] := (SELECT array_agg(s.usr_name) FROM qgis_pkg.list_qgis_pkg_usrgroup_members() AS s);
	usr_schemas_array varchar[] := (SELECT array_agg(s.usr_schema) FROM qgis_pkg.list_usr_schemas() AS s);
	cdb_schemas_array varchar[] := (SELECT array_agg(s.cdb_schema) FROM qgis_pkg.list_cdb_schemas() AS s);

	srid integer;
	num_features bigint;

	root_class varchar;
	curr_class varchar;
	lod varchar;
	ql_feature_type varchar := quote_literal(feature_type);
	ql_l_type varchar := quote_literal(l_type);
	qi_cdb_schema varchar; ql_cdb_schema varchar;
	qi_usr_schema varchar; ql_usr_schema varchar;
	qi_usr_name varchar; ql_usr_name varchar;
	l_name varchar; ql_l_name varchar; qi_l_name varchar;
	av_name varchar; ql_av_name varchar; qi_av_name varchar;
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
	enum_cols_array varchar[][] := NULL;
	codelist_cols_array varchar[][] := NULL;
	sql_co_atts varchar := 'co.id::bigint,co.gmlid,co.gmlid_codespace,co.name,
				co.name_codespace,co.description,co.creation_date,
				co.termination_date,co.relative_to_terrain,
				co.relative_to_water,co.last_modification_date,
				co.updating_person,co.reason_for_update,co.lineage,';

BEGIN
	-- check if user name exists
	IF NOT usr_name = ANY(usr_names_array) THEN
	RAISE EXCEPTION 'usr_name is invalid. It must be an existing database user and member of role (group) "%"',qgis_user_group_name;
	END IF;
	
	-- check if usr_schema exists
	IF NOT usr_schema = ANY(usr_schemas_array) THEN
	RAISE EXCEPTION 'usr_schema % does not exist. Please create it beforehand',usr_schema;
	END IF;
	
	-- check if cdb_schema exists
	IF NOT cdb_schema = ANY(cdb_schemas_array)  THEN
	RAISE EXCEPTION 'cdb_schema % is invalid. It must correspond to an existing city db schema',cdb_schema;
	END IF;

	-- add quote identifier (qi_) and quote literal (ql_) for later user in dynamic queries.
	qi_cdb_schema := quote_ident(cdb_schema);
	ql_cdb_schema := quote_literal(cdb_schema);
	qi_usr_name   := quote_ident(usr_name);
	ql_usr_name   := quote_literal(usr_name);
	qi_usr_schema := quote_ident(usr_schema);
	ql_usr_schema := quote_literal(usr_schema);
	
	-- Prepare fixed part of SQL statements
	-- Remove previous entries from the layer_metadata Table, and insert it again.
	sql_upd := concat('
	DELETE FROM ',qi_usr_schema,'.layer_metadata AS l WHERE l.cdb_schema = ',ql_cdb_schema,' AND l.layer_type = ',ql_l_type,' AND l.feature_type = ',ql_feature_type,';
	INSERT INTO ',qi_usr_schema,'.layer_metadata 
	(cdb_schema, ade_prefix, layer_type, feature_type, root_class, class, lod, layer_name, av_name, gv_name, n_features, creation_date, qml_form, qml_symb, qml_3d, enum_cols, codelist_cols)
	VALUES');

	-- Get the srid from the cdb_schema
	EXECUTE format('SELECT srid FROM %I.database_srs LIMIT 1', cdb_schema) INTO srid;

	-- Check the mview bbox (the red bbox from the plugin, for example)
	-- Check that the srid is the same if the mview_box
	-- Prepare the slq where part to be added to the queries, if the bbox is needed.
	IF ST_SRID(mview_bbox) IS NULL OR ST_SRID(mview_bbox) <> srid THEN
	-- No bbox where condition
	sql_where := NULL;
	ELSE
	-- Yes, we will perform also a spatial query based on the envelope column in the CITYOBJECT table
	sql_where := concat(' AND ST_Contains(
					ST_MakeEnvelope(', floor(ST_XMin(mview_bbox)),', ', floor(ST_YMin(mview_bbox)),', ', ceil(ST_XMax(mview_bbox)),', ',	ceil(ST_YMax(mview_bbox)),', ',	srid,'),
		  	  	        ngws.position)
	');
	END IF;
	
	RAISE NOTICE 'For module "%" and user "%": creating layers in usr_schema "%" for cdb_schema "%"', feature_type, qi_usr_name, qi_usr_schema, qi_cdb_schema;
	
	-- Initialize variables.
	sql_layer := NULL; sql_ins := NULL; sql_trig := NULL;
	root_class := feature_type;
	
	----------------------------------------------------------
	-- CREATE LAYER WEATHERSTATION
	----------------------------------------------------------
	sql_feat_count := concat('
		SELECT COUNT(*) FROM ',qi_cdb_schema,'.ng_weatherstation AS ngws
		INNER JOIN ',qi_cdb_schema,'.cityobject AS co
		ON (ngws.id = co.id ',sql_where,')
	');
	EXECUTE sql_feat_count INTO num_features;
	RAISE NOTICE 'Found % features for WeatherStation LoDx',num_features;
	curr_class := 'WeatherStation';
	lod := 'lodx';
	l_name := concat(cdb_schema,'_ng_weatherstation_lodx');
	av_name := concat('_a_',cdb_schema,'_ng_weatherstation');
	gv_name := concat('_g_',l_name);
	qml_form_name := 'ng_weatherstation_form.qml';
	qml_symb_name := 'point_red_symb.qml';
	qml_3d_name := 'point_red_3d.qml';
	trig_f_suffix := 'ng_weatherstation';
	qi_l_name := quote_ident(l_name);
	ql_l_name := quote_literal(l_name);
	qi_av_name := quote_ident(av_name);
	ql_av_name := quote_literal(av_name);
	qi_gv_name := quote_ident(gv_name);
	ql_gv_name := quote_literal(gv_name);

	IF (num_features > 0) OR (force_layer_creation IS TRUE) THEN

		----------------------------------------------------
		-- MATERIALIZED VIEW FOR GEOMETRY
		----------------------------------------------------
		
		sql_layer := concat(sql_layer,qgis_pkg.generate_sql_matview_header(qi_usr_schema,qi_gv_name),'
			SELECT ngws.id AS co_id, ngws.position AS geom
			FROM ',qi_cdb_schema,'.ng_weatherstation AS ngws
			',sql_where,'
			WITH NO DATA;
			COMMENT ON MATERIALIZED VIEW ',qi_usr_schema,'.',qi_gv_name,' IS ''Mat. view of WeatherStation LoDx  in schema ',qi_cdb_schema,''';',
			qgis_pkg.generate_sql_matview_footer(qi_usr_name,qi_usr_schema,ql_l_name,qi_gv_name)
		);
		
		----------------------------------------------------
		-- VIEW FOR ATTRIBUTES + GEOMETRY
		----------------------------------------------------
		sql_layer := concat(sql_layer,qgis_pkg.generate_sql_view_header(qi_usr_schema,qi_l_name),'
			SELECT
			ngco.id AS ng_co_id,',
			sql_co_atts,'
			ngws.genericapplicationpropertyof,
			ngws.stationname,
			g.geom
			FROM ',qi_usr_schema,'.',qi_gv_name,' AS g
			INNER JOIN ',qi_cdb_schema,'.ng_weatherstation AS ngws ON g.co_id = ngws.id
			INNER JOIN ',qi_cdb_schema,'.cityobject AS co ON ngws.id = co.id
			LEFT OUTER JOIN ',qi_cdb_schema,'.ng_cityobject AS ngco ON co.id = ngco.id;
		        COMMENT ON VIEW ',qi_usr_schema,'.',qi_l_name,' IS ''View of WeatherStation LoDx in schema ',qi_cdb_schema,''';
			ALTER TABLE ',qi_usr_schema,'.',qi_l_name,' OWNER TO ',qi_usr_name,';
		');
		-- Add triggers to make view updatable
		sql_trig := concat(sql_trig,qgis_pkg.generate_sql_triggers(usr_schema, l_name, trig_f_suffix));
		
		-- Add entry to update table layer_metadata
		sql_ins := concat(sql_ins,'
			(',ql_cdb_schema,',',quote_literal('ng'),',',ql_l_type,',',ql_feature_type,',',quote_literal(root_class),',',quote_literal(curr_class),',',quote_literal(lod),',
			 ',ql_l_name,',',ql_av_name,',',ql_gv_name,',',num_features,',clock_timestamp(),',quote_literal(qml_form_name),',',quote_literal(qml_symb_name),',
			 ',quote_literal(qml_3d_name),',',quote_nullable(enum_cols_array),',',quote_nullable(codelist_cols_array),'),');
		
		ELSE
			sql_layer := concat(sql_layer, qgis_pkg.generate_sql_matview_else(qi_usr_schema, ql_cdb_schema, ql_l_type, ql_l_name, qi_gv_name));
		END IF;	

	IF sql_ins IS NOT NULL THEN
		sql_ins := concat(sql_upd, substr(sql_ins,1, length(sql_ins)-1), ';');
	END IF;
	
	sql_statement := concat(sql_layer,sql_trig,sql_ins);
	RETURN sql_statement;
END;
$$ LANGUAGE plpgsql;	
COMMENT ON FUNCTION qgis_pkg.generate_sql_layers_ng_weatherstation(varchar,varchar,integer,integer,numeric,geometry,boolean) IS 'Generate SQL script to create layers for class WeatherStation';
REVOKE EXECUTE ON FUNCTION qgis_pkg.generate_sql_layers_ng_weatherstation(varchar,varchar,integer,integer,numeric,geometry,boolean) FROM public; 	
		
---------------------------------------------------------------------
-- CREATE FUNCTION qgis_pkg.generate_sql_layers_ng_weatherdata
---------------------------------------------------------------------
DROP FUNCTION IF EXISTS qgis_pkg.generate_sql_layers_ng_weatherdata(varchar,varchar,integer,integer,numeric,geometry,boolean,varchar) CASCADE;
CREATE OR REPLACE FUNCTION qgis_pkg.generate_sql_layers_ng_weatherdata(usr_name varchar,cdb_schema varchar,perform_snapping integer,digits integer,
								          area_poly_min numeric,mview_bbox geometry,force_layer_creation boolean,ade_prefix varchar)
RETURNS text AS $$
DECLARE
	feature_type CONSTANT varchar := ' ';
	l_type varchar := 'DetailView';

	qgis_user_group_name CONSTANT varchar := (SELECT qgis_pkg.create_qgis_pkg_usrgroup_name());

	usr_schema varchar := (SELECT qgis_pkg.create_qgis_usr_schema_name(usr_name));
	usr_names_array varchar[] := (SELECT array_agg(s.usr_name) FROM qgis_pkg.list_qgis_pkg_usrgroup_members() AS s);
	usr_schemas_array varchar[] := (SELECT array_agg(s.usr_schema) FROM qgis_pkg.list_usr_schemas() AS s);
	cdb_schemas_array varchar[] := (SELECT array_agg(s.cdb_schema) FROM qgis_pkg.list_cdb_schemas() AS s);

	srid integer;
	num_features bigint;

	root_class varchar;
	curr_class varchar;
	lod varchar;
	ql_feature_type varchar := quote_literal(feature_type);
	ql_l_type varchar := quote_literal(l_type);
	qi_cdb_schema varchar; ql_cdb_schema varchar;
	qi_usr_schema varchar; ql_usr_schema varchar;
	qi_usr_name varchar; ql_usr_name varchar; ql_ade_prefix varchar;
	l_name varchar; ql_l_name varchar; qi_l_name varchar;
	av_name varchar; ql_av_name varchar; qi_av_name varchar;
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
	enum_cols_array varchar[][] := ARRAY[['ng_weatherdata','weatherdatatype']];
	codelist_cols_array varchar[][] := NULL;
	sql_co_atts varchar := 'co.id::bigint,co.gmlid,co.gmlid_codespace,co.name,
				co.name_codespace,co.description,co.creation_date,
				co.termination_date,co.last_modification_date,
				co.updating_person,co.reason_for_update,co.lineage,';

BEGIN
	-- check if user name exists
	IF NOT usr_name = ANY(usr_names_array) THEN
	RAISE EXCEPTION 'usr_name is invalid. It must be an existing database user and member of role (group) "%"',qgis_user_group_name;
	END IF;
	
	-- check if usr_schema exists
	IF NOT usr_schema = ANY(usr_schemas_array) THEN
	RAISE EXCEPTION 'usr_schema % does not exist. Please create it beforehand',usr_schema;
	END IF;
	
	-- check if cdb_schema exists
	IF NOT cdb_schema = ANY(cdb_schemas_array)  THEN
	RAISE EXCEPTION 'cdb_schema % is invalid. It must correspond to an existing city db schema',cdb_schema;
	END IF;

	-- add quote identifier (qi_) and quote literal (ql_) for later user in dynamic queries.
	qi_cdb_schema := quote_ident(cdb_schema);
	ql_cdb_schema := quote_literal(cdb_schema);
	qi_usr_name   := quote_ident(usr_name);
	ql_usr_name   := quote_literal(usr_name);
	qi_usr_schema := quote_ident(usr_schema);
	ql_usr_schema := quote_literal(usr_schema);
	ql_ade_prefix := quote_literal(ade_prefix);
	
	-- Prepare fixed part of SQL statements
	-- Remove previous entries from the layer_metadata Table, and insert it again.
	sql_upd := concat('
	DELETE FROM ',qi_usr_schema,'.layer_metadata AS l WHERE l.cdb_schema = ',ql_cdb_schema,' AND l.class = ',quote_literal('WeatherData'),';
	INSERT INTO ',qi_usr_schema,'.layer_metadata 
	(cdb_schema, ade_prefix, layer_type, feature_type, root_class, class, lod, layer_name, av_name, gv_name, n_features, creation_date, qml_form, qml_symb, qml_3d, enum_cols, codelist_cols)
	VALUES');

	-- Get the srid from the cdb_schema
	EXECUTE format('SELECT srid FROM %I.database_srs LIMIT 1', cdb_schema) INTO srid;

	-- Check the mview bbox (the red bbox from the plugin, for example)
	-- Check that the srid is the same if the mview_box
	-- Prepare the slq where part to be added to the queries, if the bbox is needed.
	IF ST_SRID(mview_bbox) IS NULL OR ST_SRID(mview_bbox) <> srid THEN
		-- No bbox where condition
		sql_where := NULL;
	ELSE
		-- Yes, we will perform also a spatial query based on the envelope column in the CITYOBJECT table
		sql_where := concat('AND ST_MakeEnvelope(', floor(ST_XMin(mview_bbox)),', ', floor(ST_YMin(mview_bbox)),', ', ceil(ST_XMax(mview_bbox)),', ',	ceil(ST_YMax(mview_bbox)),', ',	srid,')
		  	     && co.envelope');
	END IF;
	
	RAISE NOTICE 'For module "%" and user "%": creating layers in usr_schema "%" for cdb_schema "%"', feature_type, qi_usr_name, qi_usr_schema, qi_cdb_schema;
	
	-- Initialize variables.
	sql_layer := NULL; sql_ins := NULL; sql_trig := NULL;
	root_class := ' ';
		
	---------------------------------------------------------
	-- CREATE LAYER WEATHERDATA
	---------------------------------------------------------
	sql_feat_count := concat('
		SELECT COUNT(*) FROM ',qi_cdb_schema,'.ng_weatherdata AS ngwd
		INNER JOIN ',qi_cdb_schema,'.cityobject AS co 
		ON (ngwd.cityobject_weatherdata_id = co.id ',sql_where,')
	');
	EXECUTE sql_feat_count INTO num_features;
	RAISE NOTICE 'Found % features for WeatherData LoDx',num_features;
	curr_class := 'WeatherData';
	lod := 'lodx';
	l_name := concat(cdb_schema,'_ng_weatherdata_lodx');
	av_name := concat('_a_',cdb_schema,'_ng_weatherdata');
	gv_name := concat('_g_',l_name);
	qml_form_name := 'ng_weatherdata_form.qml';
	qml_symb_name := 'point_red_symb,qml';
	qml_3d_name := 'point_red_3d.qml';
	trig_f_suffix := 'ng_weatherdata';
	qi_l_name := quote_ident(l_name);
	ql_l_name := quote_literal(l_name);
	qi_av_name := quote_ident(av_name);
	ql_av_name := quote_literal(av_name);
	qi_gv_name := quote_ident(gv_name);
	ql_gv_name := quote_literal(gv_name);

	IF (num_features > 0) OR (force_layer_creation IS TRUE) THEN

		----------------------------------------------------
		-- MATERIALIZED VIEW FOR GEOMETRY
		----------------------------------------------------
		sql_layer := concat(sql_layer,qgis_pkg.generate_sql_matview_header(qi_usr_schema,qi_gv_name),'
			WITH itab3 AS(
				SELECT itab2.co_id,itab2.geom FROM (
				SELECT itab.co_id,unnest(itab.point_array) AS geom
				FROM
					(
						SELECT ngws.id AS co_id,array_agg(ngws.position) AS point_array
						FROM ',qi_cdb_schema,'.ng_weatherstation AS ngws
						INNER JOIN ',qi_cdb_schema,'.ng_weatherdata AS ngwd
						ON ngws.id = ngwd.cityobject_weatherdata_id
						GROUP BY ngws.id
					) AS itab
				) AS itab2	
			)
			SELECT DISTINCT(ngwd.id) AS co_id,
			CASE
				WHEN ngwd.position IS null THEN itab3.geom
				ELSE
					ngwd.position
				END AS geom
			FROM ',qi_cdb_schema,'.ng_weatherdata AS ngwd
			INNER JOIN itab3 ON ngwd.cityobject_weatherdata_id = itab3.co_id
			WHERE itab3.geom IS NOT null
			WITH NO DATA;
			COMMENT ON MATERIALIZED VIEW ',qi_usr_schema,'.',qi_gv_name,' IS ''Mat. view of WeatherData in schema ',qi_cdb_schema,''';',
			qgis_pkg.generate_sql_matview_footer(qi_usr_name,qi_usr_schema,ql_l_name,qi_gv_name));
		
		---------------------------------------------------
		-- VIEW FOR ATTRIBUTES + GEOMETRY
		---------------------------------------------------
		sql_layer := concat(sql_layer,qgis_pkg.generate_sql_view_header(qi_usr_schema,qi_l_name),'
			SELECT ',
			sql_co_atts,'
			ngwd.cityobject_weatherdata_id,
			ngwd.values_id,
			ngwd.weatherdatatype,
			ngwd.position,
			ngwd.weatherstation_parameter_id,
			g.geom
			FROM ',qi_usr_schema,'.',qi_gv_name,' AS g
			INNER JOIN ',qi_cdb_schema,'.ng_weatherdata AS ngwd ON (g.co_id = ngwd.id)
			INNER JOIN ',qi_cdb_schema,'.cityobject AS co ON (ngwd.id = co.id ',sql_where,');
			COMMENT ON VIEW ',qi_usr_schema,'.',qi_l_name,' IS ''View of WeatherData LoDx in schema ',qi_cdb_schema,''';
			ALTER TABLE ',qi_usr_schema,'.',qi_l_name,' OWNER TO ',qi_usr_name,';
		');
		-- add triggers to make view updatable
		sql_trig := concat(sql_trig,qgis_pkg.generate_sql_triggers(usr_schema, l_name, trig_f_suffix));
		
		-- Add entry to update table layer_metadata
		sql_ins := concat(sql_ins,'
			(',ql_cdb_schema,',',ql_ade_prefix,',',ql_l_type,',',ql_feature_type,',',quote_literal(root_class),',',quote_literal(curr_class),',',quote_literal(lod),',
			 ',ql_l_name,',',ql_av_name,',',ql_gv_name,',',num_features,',clock_timestamp(),',quote_literal(qml_form_name),',',quote_literal(qml_symb_name),',
			 ',quote_literal(qml_3d_name),',',quote_nullable(enum_cols_array),',',quote_nullable(codelist_cols_array),'),');
		
		ELSE
			sql_layer := concat(sql_layer, qgis_pkg.generate_sql_matview_else(qi_usr_schema, ql_cdb_schema, ql_l_type, ql_l_name, qi_gv_name));
		END IF;	
	
	IF sql_ins IS NOT NULL THEN
		sql_ins := concat(sql_upd, substr(sql_ins,1, length(sql_ins)-1), ';');
	END IF;
	
	sql_statement := concat(sql_layer,sql_trig,sql_ins);
	RETURN sql_statement;
END;
$$ LANGUAGE plpgsql;	
COMMENT ON FUNCTION qgis_pkg.generate_sql_layers_ng_weatherdata(varchar,varchar,integer,integer,numeric,geometry,boolean,varchar) IS 'Generate SQL script to create layers for class WeatherData';
REVOKE EXECUTE ON FUNCTION qgis_pkg.generate_sql_layers_ng_weatherdata(varchar,varchar,integer,integer,numeric,geometry,boolean,varchar) FROM public; 	

-------------------------------------------------------------------
-- CREATE FUNCTION qgis_pkg.generate_sql_ng_energydemand
-------------------------------------------------------------------

DROP FUNCTION IF EXISTS qgis_pkg.generate_sql_layers_ng_energydemand(varchar,varchar,integer,integer,numeric,geometry,boolean,varchar) CASCADE;
CREATE OR REPLACE FUNCTION qgis_pkg.generate_sql_layers_ng_energydemand(usr_name varchar,cdb_schema varchar,perform_snapping integer,digits integer,
									area_poly_min numeric,mview_bbox geometry,force_layer_creation boolean,ade_prefix varchar)
RETURNS text AS $$
DECLARE

	feature_type CONSTANT varchar := ' ';
	l_type varchar := 'DetailViewNoGeom';
	qgis_user_group_name CONSTANT varchar := (SELECT qgis_pkg.create_qgis_pkg_usrgroup_name());
	usr_schema varchar := (SELECT qgis_pkg.create_qgis_usr_schema_name(usr_name));
	usr_names_array varchar[] := (SELECT array_agg(s.usr_name) FROM qgis_pkg.list_qgis_pkg_usrgroup_members() AS s);
	usr_schemas_array varchar[] := (SELECT array_agg(s.usr_schema) FROM qgis_pkg.list_usr_schemas() AS s);
	cdb_schemas_array varchar[] := (SELECT array_agg(s.cdb_schema) FROM qgis_pkg.list_cdb_schemas() AS s);
	srid integer;
	num_features bigint;
	root_class varchar;
	curr_class varchar;
	lod varchar;
	ql_feature_type varchar := quote_literal(feature_type);
	ql_l_type varchar := quote_literal(l_type);
	qi_cdb_schema varchar; ql_cdb_schema varchar;
	qi_usr_schema varchar; ql_usr_schema varchar;
	qi_usr_name varchar; ql_usr_name varchar; ql_ade_prefix varchar;
	l_name varchar; ql_l_name varchar; qi_l_name varchar;
	av_name varchar; ql_av_name varchar; qi_av_name varchar;
	gv_name varchar; qi_gv_name varchar; ql_gv_name varchar;
	qml_form_name 	varchar := NULL;
	qml_symb_name 	varchar := NULL;
	qml_3d_name 	varchar := NULL;
	trig_f_suffix   varchar := NULL;
	r RECORD; s RECORD; t RECORD; u RECORD;
	sql_feat_count	text := NULL;
	sql_upd			text := NULL;
	sql_ins			text := NULL;
	sql_trig		text := NULL;
	sql_layer	 	text := NULL;
	sql_statement	text := NULL;
	enum_cols_array varchar[][] := ARRAY[['ng_energydemand','enduse']];
	codelist_cols_array varchar[][] := ARRAY[['ng_energydemand','energycarriertype']];
	sql_co_atts varchar := 'co.id::bigint,co.gmlid,co.gmlid_codespace,co.name,
				co.name_codespace,co.description,co.creation_date,
				co.termination_date,co.last_modification_date,
				co.updating_person,co.reason_for_update,co.lineage,';

BEGIN
	-- check if user name exists
	IF NOT usr_name = ANY(usr_names_array) THEN
	RAISE EXCEPTION 'usr_name is invalid. It must be an existing database user and member of role (group) "%"',qgis_user_group_name;
	END IF;
	
	-- check if usr_schema exists
	IF NOT usr_schema = ANY(usr_schemas_array) THEN
	RAISE EXCEPTION 'usr_schema % does not exist. Please create it beforehand',usr_schema;
	END IF;
	
	-- check if cdb_schema exists
	IF NOT cdb_schema = ANY(cdb_schemas_array)  THEN
	RAISE EXCEPTION 'cdb_schema % is invalid. It must correspond to an existing city db schema',cdb_schema;
	END IF;

	-- add quote identifier (qi_) and quote literal (ql_) for later user in dynamic queries.
	qi_cdb_schema := quote_ident(cdb_schema);
	ql_cdb_schema := quote_literal(cdb_schema);
	qi_usr_name   := quote_ident(usr_name);
	ql_usr_name   := quote_literal(usr_name);
	qi_usr_schema := quote_ident(usr_schema);
	ql_usr_schema := quote_literal(usr_schema);
	ql_ade_prefix := quote_literal(ade_prefix);
	
	-- Prepare fixed part of SQL statements
	-- Remove previous entries from the layer_metadata Table, and insert it again.
	sql_upd := concat('
	DELETE FROM ',qi_usr_schema,'.layer_metadata AS l WHERE l.cdb_schema = ',ql_cdb_schema,' AND l.class = ',quote_literal('EnergyDemand'),';
	INSERT INTO ',qi_usr_schema,'.layer_metadata 
	(cdb_schema, ade_prefix, layer_type, feature_type, root_class, class, lod, layer_name, av_name, gv_name, n_features, creation_date, qml_form, qml_symb, qml_3d, enum_cols, codelist_cols)
	VALUES');

	RAISE NOTICE 'For module "%" and user "%": creating layers in usr_schema "%" for cdb_schema "%"', feature_type, qi_usr_name, qi_usr_schema, qi_cdb_schema;
	
	-- Initialize variables.
	sql_layer := NULL; sql_ins := NULL; sql_trig := NULL;
	root_class := feature_type;

	----------------------------------------------------------
	-- CREATE LAYER ENERGYDEMAND
	----------------------------------------------------------
	
	sql_feat_count := concat('
		SELECT COUNT(nged.id) FROM ',qi_cdb_schema,'.ng_energydemand AS nged
	');
	EXECUTE sql_feat_count INTO num_features;

	RAISE NOTICE 'Found % features for EnergyDemand',num_features;

	curr_class := 'EnergyDemand';
	lod := 'lodx';
	l_name := concat(cdb_schema,'_ng_energydemand_lodx');
	av_name := concat('_a_',cdb_schema,'_ng_energydemand');
	gv_name := ' ';
	qml_form_name := 'ng_energydemand_form.qml';
	qml_symb_name := ' ';
	qml_3d_name := ' ';
	trig_f_suffix := 'ng_energydemand';
	qi_l_name := quote_ident(l_name);
	ql_l_name := quote_literal(l_name);
	qi_av_name := quote_ident(av_name);
	ql_av_name := quote_literal(av_name);
	qi_gv_name := quote_ident(gv_name);
	ql_gv_name := quote_literal(gv_name);

	IF (num_features > 0) OR (force_layer_creation IS TRUE) THEN
		
		----------------------------------------------------
		-- VIEW FOR ATTRIBUTES
		----------------------------------------------------
		sql_layer := concat(sql_layer,qgis_pkg.generate_sql_view_header(qi_usr_schema,qi_l_name),'
			SELECT * FROM ',qi_cdb_schema,'.ng_energydemand;
			COMMENT ON VIEW ',qi_usr_schema,'.',qi_l_name,' IS ''View of EnergyDemand in schema ',qi_cdb_schema,''';
			ALTER TABLE ',qi_usr_schema,'.',qi_l_name,' OWNER TO ',qi_usr_name,';
		');

		-- add triggers to make view updatable		
		sql_trig := concat(sql_trig,qgis_pkg.generate_sql_triggers(usr_schema, l_name, trig_f_suffix));
		
		-- Add entry to update table layer_metadata
		sql_ins := concat(sql_ins,'
			(',ql_cdb_schema,',',ql_ade_prefix,',',ql_l_type,',',ql_feature_type,',',quote_literal(root_class),',',quote_literal(curr_class),',',quote_literal(lod),',
			 ',ql_l_name,',',ql_av_name,',',ql_gv_name,',',num_features,',clock_timestamp(),',quote_literal(qml_form_name),',',quote_literal(qml_symb_name),',
			 ',quote_literal(qml_3d_name),',',quote_nullable(enum_cols_array),',',quote_nullable(codelist_cols_array),'),');
	
	ELSE
		sql_layer := concat(sql_layer,qgis_pkg.generate_sql_matview_else(qi_usr_schema,ql_cdb_schema,ql_l_type,ql_l_name,qi_gv_name));
	END IF;
	
	IF sql_ins IS NOT NULL THEN
		sql_ins := concat(sql_upd, substr(sql_ins,1, length(sql_ins)-1), ';');
	END IF;
	
	sql_statement := concat(sql_layer,sql_trig,sql_ins);
	RETURN sql_statement;
END;
$$ LANGUAGE plpgsql;	
COMMENT ON FUNCTION qgis_pkg.generate_sql_layers_ng_energydemand(varchar,varchar,integer,integer,numeric,geometry,boolean,varchar) IS 'Generate SQL script to create layers for class EnergyDemand';
REVOKE EXECUTE ON FUNCTION qgis_pkg.generate_sql_layers_ng_energydemand(varchar,varchar,integer,integer,numeric,geometry,boolean,varchar) FROM public; 	

-------------------------------------------------------------------
-- CREATE FUNCTION qgis_pkg.generate_sql_ng_dailyschedule
-------------------------------------------------------------------

DROP FUNCTION IF EXISTS qgis_pkg.generate_sql_layers_ng_dailyschedule(varchar,varchar,integer,integer,numeric,geometry,boolean,varchar) CASCADE;
CREATE OR REPLACE FUNCTION qgis_pkg.generate_sql_layers_ng_dailyschedule(usr_name varchar,cdb_schema varchar,perform_snapping integer,digits integer,
									 area_poly_min numeric,mview_bbox geometry,force_layer_creation boolean,ade_prefix varchar)
RETURNS text AS $$
DECLARE

	feature_type CONSTANT varchar := ' ';
	l_type varchar := 'DetailViewNoGeom';
	qgis_user_group_name CONSTANT varchar := (SELECT qgis_pkg.create_qgis_pkg_usrgroup_name());
	usr_schema varchar := (SELECT qgis_pkg.create_qgis_usr_schema_name(usr_name));
	usr_names_array varchar[] := (SELECT array_agg(s.usr_name) FROM qgis_pkg.list_qgis_pkg_usrgroup_members() AS s);
	usr_schemas_array varchar[] := (SELECT array_agg(s.usr_schema) FROM qgis_pkg.list_usr_schemas() AS s);
	cdb_schemas_array varchar[] := (SELECT array_agg(s.cdb_schema) FROM qgis_pkg.list_cdb_schemas() AS s);
	srid integer;
	num_features bigint;
	root_class varchar;
	curr_class varchar;
	lod varchar;
	ql_feature_type varchar := quote_literal(feature_type);
	ql_l_type varchar := quote_literal(l_type);
	qi_cdb_schema varchar; ql_cdb_schema varchar;
	qi_usr_schema varchar; ql_usr_schema varchar;
	qi_usr_name varchar; ql_usr_name varchar; ql_ade_prefix varchar;
	l_name varchar; ql_l_name varchar; qi_l_name varchar;
	av_name varchar; ql_av_name varchar; qi_av_name varchar;
	gv_name varchar; qi_gv_name varchar; ql_gv_name varchar;
	qml_form_name 	varchar := NULL;
	qml_symb_name 	varchar := NULL;
	qml_3d_name 	varchar := NULL;
	trig_f_suffix   varchar := NULL;
	r RECORD; s RECORD; t RECORD; u RECORD;
	sql_feat_count	text := NULL;
	sql_upd			text := NULL;
	sql_ins			text := NULL;
	sql_trig		text := NULL;
	sql_layer	 	text := NULL;
	sql_statement	text := NULL;
	enum_cols_array varchar[][] := ARRAY[['ng_dailyschedule','daytype']];
	codelist_cols_array varchar[][] := NULL;

BEGIN
	-- check if user name exists
	IF NOT usr_name = ANY(usr_names_array) THEN
	RAISE EXCEPTION 'usr_name is invalid. It must be an existing database user and member of role (group) "%"',qgis_user_group_name;
	END IF;
	
	-- check if usr_schema exists
	IF NOT usr_schema = ANY(usr_schemas_array) THEN
	RAISE EXCEPTION 'usr_schema % does not exist. Please create it beforehand',usr_schema;
	END IF;
	
	-- check if cdb_schema exists
	IF NOT cdb_schema = ANY(cdb_schemas_array)  THEN
	RAISE EXCEPTION 'cdb_schema % is invalid. It must correspond to an existing city db schema',cdb_schema;
	END IF;

	-- add quote identifier (qi_) and quote literal (ql_) for later user in dynamic queries.
	qi_cdb_schema := quote_ident(cdb_schema);
	ql_cdb_schema := quote_literal(cdb_schema);
	qi_usr_name   := quote_ident(usr_name);
	ql_usr_name   := quote_literal(usr_name);
	qi_usr_schema := quote_ident(usr_schema);
	ql_usr_schema := quote_literal(usr_schema);
	ql_ade_prefix := quote_literal(ade_prefix);

	-- Prepare fixed part of SQL statements
	-- Remove previous entries from the layer_metadata Table, and insert it again.
	sql_upd := concat('
	DELETE FROM ',qi_usr_schema,'.layer_metadata AS l WHERE l.cdb_schema = ',ql_cdb_schema,' AND l.class = ',quote_literal('DailySchedule'),';
	INSERT INTO ',qi_usr_schema,'.layer_metadata 
	(cdb_schema, ade_prefix, layer_type, feature_type, root_class, class, lod, layer_name, av_name, gv_name, n_features, creation_date, qml_form, qml_symb, qml_3d, enum_cols, codelist_cols)
	VALUES');

	RAISE NOTICE 'For module "%" and user "%": creating layers in usr_schema "%" for cdb_schema "%"', feature_type, qi_usr_name, qi_usr_schema, qi_cdb_schema;
	
	-- Initialize variables.
	sql_layer := NULL; sql_ins := NULL; sql_trig := NULL;
	root_class := feature_type;

	----------------------------------------------------------
	-- CREATE LAYER DAILYSCHEDULE
	----------------------------------------------------------
	
	sql_feat_count := concat('
		SELECT COUNT(ngds.id) FROM ',qi_cdb_schema,'.ng_dailyschedule AS ngds
	');
	EXECUTE sql_feat_count INTO num_features;

	RAISE NOTICE 'Found % features for DailySchedule',num_features;

	curr_class := 'DailySchedule';
	lod := 'lodx';
	l_name := concat(cdb_schema,'_ng_dailyschedule_lodx');
	av_name := concat('_a_',cdb_schema,'_ng_dailyschedule');
	gv_name := ' ';
	qml_form_name := 'ng_dailyschedule_form.qml';
	qml_symb_name := ' ';
	qml_3d_name := ' ';
	trig_f_suffix := 'ng_dailyschedule';
	qi_l_name := quote_ident(l_name);
	ql_l_name := quote_literal(l_name);
	qi_av_name := quote_ident(av_name);
	ql_av_name := quote_literal(av_name);
	qi_gv_name := quote_ident(gv_name);
	ql_gv_name := quote_literal(gv_name);

	IF (num_features > 0) OR (force_layer_creation IS TRUE) THEN
		
		----------------------------------------------------
		-- VIEW FOR ATTRIBUTES
		----------------------------------------------------
		sql_layer := concat(sql_layer,qgis_pkg.generate_sql_view_header(qi_usr_schema,qi_l_name),'
			SELECT * FROM ',qi_cdb_schema,'.ng_dailyschedule;
			COMMENT ON VIEW ',qi_usr_schema,'.',qi_l_name,' IS ''View of DailySchedule in schema ',qi_cdb_schema,''';
			ALTER TABLE ',qi_usr_schema,'.',qi_l_name,' OWNER TO ',qi_usr_name,';
		');

		-- add triggers to make view updatable		
		sql_trig := concat(sql_trig,qgis_pkg.generate_sql_triggers(usr_schema, l_name, trig_f_suffix));
		
		-- Add entry to update table layer_metadata
		sql_ins := concat(sql_ins,'
			(',ql_cdb_schema,',',ql_ade_prefix,',',ql_l_type,',',ql_feature_type,',',quote_literal(root_class),',',quote_literal(curr_class),',',quote_literal(lod),',
			 ',ql_l_name,',',ql_av_name,',',ql_gv_name,',',num_features,',clock_timestamp(),',quote_literal(qml_form_name),',',quote_literal(qml_symb_name),',
			 ',quote_literal(qml_3d_name),',',quote_nullable(enum_cols_array),',',quote_nullable(codelist_cols_array),'),');
	
	ELSE
		sql_layer := concat(sql_layer,qgis_pkg.generate_sql_matview_else(qi_usr_schema,ql_cdb_schema,ql_l_type,ql_l_name,qi_gv_name));
	END IF;
	
	IF sql_ins IS NOT NULL THEN
		sql_ins := concat(sql_upd, substr(sql_ins,1, length(sql_ins)-1), ';');
	END IF;
	
	sql_statement := concat(sql_layer,sql_trig,sql_ins);
	RETURN sql_statement;
END;
$$ LANGUAGE plpgsql;	
COMMENT ON FUNCTION qgis_pkg.generate_sql_layers_ng_dailyschedule(varchar,varchar,integer,integer,numeric,geometry,boolean,varchar) IS 'Generate SQL script to create layers for class DailySchedule';
REVOKE EXECUTE ON FUNCTION qgis_pkg.generate_sql_layers_ng_dailyschedule(varchar,varchar,integer,integer,numeric,geometry,boolean,varchar) FROM public; 	

-------------------------------------------------------------------
-- CREATE FUNCTION qgis_pkg.generate_sql_ng_periodofyear
-------------------------------------------------------------------

DROP FUNCTION IF EXISTS qgis_pkg.generate_sql_layers_ng_periodofyear(varchar,varchar,integer,integer,numeric,geometry,boolean,varchar) CASCADE;
CREATE OR REPLACE FUNCTION qgis_pkg.generate_sql_layers_ng_periodofyear(usr_name varchar,cdb_schema varchar,perform_snapping integer,digits integer,
									area_poly_min numeric,mview_bbox geometry,force_layer_creation boolean,ade_prefix varchar)
RETURNS text AS $$
DECLARE

	feature_type CONSTANT varchar := ' ';
	l_type varchar := 'DetailViewNoGeom';
	qgis_user_group_name CONSTANT varchar := (SELECT qgis_pkg.create_qgis_pkg_usrgroup_name());
	usr_schema varchar := (SELECT qgis_pkg.create_qgis_usr_schema_name(usr_name));
	usr_names_array varchar[] := (SELECT array_agg(s.usr_name) FROM qgis_pkg.list_qgis_pkg_usrgroup_members() AS s);
	usr_schemas_array varchar[] := (SELECT array_agg(s.usr_schema) FROM qgis_pkg.list_usr_schemas() AS s);
	cdb_schemas_array varchar[] := (SELECT array_agg(s.cdb_schema) FROM qgis_pkg.list_cdb_schemas() AS s);
	srid integer;
	num_features bigint;
	root_class varchar;
	curr_class varchar;
	lod varchar;
	ql_feature_type varchar := quote_literal(feature_type);
	ql_l_type varchar := quote_literal(l_type);
	qi_cdb_schema varchar; ql_cdb_schema varchar;
	qi_usr_schema varchar; ql_usr_schema varchar;
	qi_usr_name varchar; ql_usr_name varchar; ql_ade_prefix varchar;
	l_name varchar; ql_l_name varchar; qi_l_name varchar;
	av_name varchar; ql_av_name varchar; qi_av_name varchar;
	gv_name varchar; qi_gv_name varchar; ql_gv_name varchar;
	qml_form_name 	varchar := NULL;
	qml_symb_name 	varchar := NULL;
	qml_3d_name 	varchar := NULL;
	trig_f_suffix   varchar := NULL;
	r RECORD; s RECORD; t RECORD; u RECORD;
	sql_feat_count	text := NULL;
	sql_upd			text := NULL;
	sql_ins			text := NULL;
	sql_trig		text := NULL;
	sql_layer	 	text := NULL;
	sql_statement	text := NULL;
	enum_cols_array varchar[][] := NULL;
	codelist_cols_array varchar[][] := NULL;

BEGIN
	-- check if user name exists
	IF NOT usr_name = ANY(usr_names_array) THEN
	RAISE EXCEPTION 'usr_name is invalid. It must be an existing database user and member of role (group) "%"',qgis_user_group_name;
	END IF;
	
	-- check if usr_schema exists
	IF NOT usr_schema = ANY(usr_schemas_array) THEN
	RAISE EXCEPTION 'usr_schema % does not exist. Please create it beforehand',usr_schema;
	END IF;
	
	-- check if cdb_schema exists
	IF NOT cdb_schema = ANY(cdb_schemas_array)  THEN
	RAISE EXCEPTION 'cdb_schema % is invalid. It must correspond to an existing city db schema',cdb_schema;
	END IF;

	-- add quote identifier (qi_) and quote literal (ql_) for later user in dynamic queries.
	qi_cdb_schema := quote_ident(cdb_schema);
	ql_cdb_schema := quote_literal(cdb_schema);
	qi_usr_name   := quote_ident(usr_name);
	ql_usr_name   := quote_literal(usr_name);
	qi_usr_schema := quote_ident(usr_schema);
	ql_usr_schema := quote_literal(usr_schema);
	ql_ade_prefix := quote_literal(ade_prefix);
	
	-- Prepare fixed part of SQL statements
	-- Remove previous entries from the layer_metadata Table, and insert it again.
	sql_upd := concat('
	DELETE FROM ',qi_usr_schema,'.layer_metadata AS l WHERE l.cdb_schema = ',ql_cdb_schema,' AND l.class = ',quote_literal('PeriodOfYear'),';
	INSERT INTO ',qi_usr_schema,'.layer_metadata 
	(cdb_schema, ade_prefix, layer_type, feature_type, root_class, class, lod, layer_name, av_name, gv_name, n_features, creation_date, qml_form, qml_symb, qml_3d, enum_cols, codelist_cols)
	VALUES');

	RAISE NOTICE 'For module "%" and user "%": creating layers in usr_schema "%" for cdb_schema "%"', feature_type, qi_usr_name, qi_usr_schema, qi_cdb_schema;
	
	-- Initialize variables.
	sql_layer := NULL; sql_ins := NULL; sql_trig := NULL;
	root_class := feature_type;
	
	-----------------------------------------------------
	-- CREATE LAYER PERIODOFYEAR
	-----------------------------------------------------
	sql_feat_count := concat('
		SELECT COUNT(ngpoy.id) FROM 
		',qi_cdb_schema,'.ng_periodofyear AS ngpoy
	');
	EXECUTE sql_feat_count INTO num_features;
	RAISE NOTICE 'Found % features for PeriofOfYear LoDx',num_features;

	curr_class := 'PeriodOfYear';
	lod := 'lodx';
	l_name := concat(cdb_schema,'_ng_periodofyear_lodx');
	av_name := concat('_a_',cdb_schema,'_ng_periodofyear');
	gv_name := ' ';
	qml_form_name := 'ng_periodofyear_form.qml';
	qml_symb_name := ' ';
	qml_3d_name := ' ';
	trig_f_suffix := 'ng_periodofyear';
	qi_l_name := quote_ident(l_name);
	ql_l_name := quote_literal(l_name);
	qi_av_name := quote_ident(av_name);
	ql_av_name := quote_literal(av_name);
	qi_gv_name := quote_ident(gv_name);
	ql_gv_name := quote_literal(gv_name);

	IF (num_features > 0) OR (force_layer_creation IS TRUE) THEN
		
		----------------------------------------------------
		-- VIEW FOR ATTRIBUTES
		----------------------------------------------------
		sql_layer := concat(sql_layer,qgis_pkg.generate_sql_view_header(qi_usr_schema,qi_l_name),'
			SELECT 
			ngpoy.id,
			ngpoy.schedule_periodofyear_id,
			ngpoy.timeperiodprop_beginposition,
			ngpoy.timeperiodproper_endposition
			FROM ',qi_cdb_schema,'.ng_periodofyear AS ngpoy;
			COMMENT ON VIEW ',qi_usr_schema,'.',qi_l_name,' IS ''View of PeriodOfYear in schema ',qi_cdb_schema,''';
			ALTER TABLE ',qi_usr_schema,'.',qi_l_name,' OWNER TO ',qi_usr_name,';
		');
	
		-- add triggers to make view updatable
		sql_trig := concat(sql_trig,qgis_pkg.generate_sql_triggers(usr_schema, l_name, trig_f_suffix));
		
		-- Add entry to update table layer_metadata
		sql_ins := concat(sql_ins,'
			(',ql_cdb_schema,',',ql_ade_prefix,',',ql_l_type,',',ql_feature_type,',',quote_literal(root_class),',',quote_literal(curr_class),',',quote_literal(lod),',
			 ',ql_l_name,',',ql_av_name,',',ql_gv_name,',',num_features,',clock_timestamp(),',quote_literal(qml_form_name),',',quote_literal(qml_symb_name),',
			 ',quote_literal(qml_3d_name),',',quote_nullable(enum_cols_array),',',quote_nullable(codelist_cols_array),'),');

	ELSE
		sql_layer := concat(sql_layer,qgis_pkg.generate_sql_matview_else(qi_usr_schema,ql_cdb_schema,ql_l_type,ql_l_name,qi_gv_name));
	END IF;
	
	IF sql_ins IS NOT NULL THEN
		sql_ins := concat(sql_upd, substr(sql_ins,1, length(sql_ins)-1), ';');
	END IF;
	
	sql_statement := concat(sql_layer,sql_trig,sql_ins);
	RETURN sql_statement;
END;
$$ LANGUAGE plpgsql;	
COMMENT ON FUNCTION qgis_pkg.generate_sql_layers_ng_periodofyear(varchar,varchar,integer,integer,numeric,geometry,boolean,varchar) IS 'Generate SQL script to create layers for class PeriodOfYear';
REVOKE EXECUTE ON FUNCTION qgis_pkg.generate_sql_layers_ng_periodofyear(varchar,varchar,integer,integer,numeric,geometry,boolean,varchar) FROM public; 	

-------------------------------------------------------------------
-- CREATE FUNCTION qgis_pkg.generate_sql_ng_regulartimeseries
-------------------------------------------------------------------
DROP FUNCTION IF EXISTS qgis_pkg.generate_sql_layers_ng_regulartimeseries(varchar,varchar,integer,integer,numeric,geometry,boolean,varchar) CASCADE;
CREATE OR REPLACE FUNCTION qgis_pkg.generate_sql_layers_ng_regulartimeseries(usr_name varchar,cdb_schema varchar,perform_snapping integer,digits integer,
								          area_poly_min numeric,mview_bbox geometry,force_layer_creation boolean,ade_prefix varchar)
RETURNS text AS $$
DECLARE

	feature_type CONSTANT varchar := ' ';
	l_type varchar := 'DetailViewNoGeom';
	qgis_user_group_name CONSTANT varchar := (SELECT qgis_pkg.create_qgis_pkg_usrgroup_name());
	usr_schema varchar := (SELECT qgis_pkg.create_qgis_usr_schema_name(usr_name));
	usr_names_array varchar[] := (SELECT array_agg(s.usr_name) FROM qgis_pkg.list_qgis_pkg_usrgroup_members() AS s);
	usr_schemas_array varchar[] := (SELECT array_agg(s.usr_schema) FROM qgis_pkg.list_usr_schemas() AS s);
	cdb_schemas_array varchar[] := (SELECT array_agg(s.cdb_schema) FROM qgis_pkg.list_cdb_schemas() AS s);
	srid integer;
	num_features bigint;
	root_class varchar;
	curr_class varchar;
	lod varchar;
	ql_feature_type varchar := quote_literal(feature_type);
	ql_l_type varchar := quote_literal(l_type);
	qi_cdb_schema varchar; ql_cdb_schema varchar;
	qi_usr_schema varchar; ql_usr_schema varchar;
	qi_usr_name varchar; ql_usr_name varchar; ql_ade_prefix varchar;
	l_name varchar; ql_l_name varchar; qi_l_name varchar;
	av_name varchar; ql_av_name varchar; qi_av_name varchar;
	gv_name varchar; qi_gv_name varchar; ql_gv_name varchar;
	qml_form_name 	varchar := NULL;
	qml_symb_name 	varchar := NULL;
	qml_3d_name 	varchar := NULL;
	trig_f_suffix   varchar := NULL;
	r RECORD; s RECORD; t RECORD; u RECORD;
	sql_feat_count	text := NULL;
	sql_where		text := NULL;
	sql_upd			text := NULL;
	sql_ins			text := NULL;
	sql_trig		text := NULL;
	sql_layer	 	text := NULL;
	sql_statement	text := NULL;
	enum_cols_array varchar[][] := ARRAY[['ng_timeseries','timevaluesprop_acquisitionme'],['ng_timeseries','timevaluesprop_interpolation']];
	codelist_cols_array varchar[][] := NULL;
	sql_co_atts varchar := 'co.id::bigint,co.gmlid,co.gmlid_codespace,co.name,
				co.name_codespace,co.description,co.creation_date,
				co.termination_date,co.last_modification_date,
				co.updating_person,co.reason_for_update,co.lineage,';

BEGIN
	-- check if user name exists
	IF NOT usr_name = ANY(usr_names_array) THEN
	RAISE EXCEPTION 'usr_name is invalid. It must be an existing database user and member of role (group) "%"',qgis_user_group_name;
	END IF;
	
	-- check if usr_schema exists
	IF NOT usr_schema = ANY(usr_schemas_array) THEN
	RAISE EXCEPTION 'usr_schema % does not exist. Please create it beforehand',usr_schema;
	END IF;
	
	-- check if cdb_schema exists
	IF NOT cdb_schema = ANY(cdb_schemas_array)  THEN
	RAISE EXCEPTION 'cdb_schema % is invalid. It must correspond to an existing city db schema',cdb_schema;
	END IF;

	-- add quote identifier (qi_) and quote literal (ql_) for later user in dynamic queries.
	qi_cdb_schema := quote_ident(cdb_schema);
	ql_cdb_schema := quote_literal(cdb_schema);
	qi_usr_name   := quote_ident(usr_name);
	ql_usr_name   := quote_literal(usr_name);
	qi_usr_schema := quote_ident(usr_schema);
	ql_usr_schema := quote_literal(usr_schema);
	ql_ade_prefix := quote_literal(ade_prefix);
	
	-- Prepare fixed part of SQL statements
	-- Remove previous entries from the layer_metadata Table, and insert it again.
	sql_upd := concat('
	DELETE FROM ',qi_usr_schema,'.layer_metadata AS l WHERE l.cdb_schema = ',ql_cdb_schema,' AND l.class LIKE ',quote_literal('RegularTimeSerie%'),';
	INSERT INTO ',qi_usr_schema,'.layer_metadata 
	(cdb_schema, ade_prefix, layer_type, feature_type, root_class, class, lod, layer_name, av_name, gv_name, n_features, creation_date, qml_form, qml_symb, qml_3d, enum_cols, codelist_cols)
	VALUES');

	RAISE NOTICE 'For module "%" and user "%": creating layers in usr_schema "%" for cdb_schema "%"', feature_type, qi_usr_name, qi_usr_schema, qi_cdb_schema;
	
	--Initialise variables 
	sql_layer := NULL; sql_ins := NULL; sql_trig := NULL;
	root_class := feature_type;

	-----------------------------------------------------------
	-- CREATE LAYER REGULARTIMESERIES
	-----------------------------------------------------------
	sql_feat_count := concat('
		SELECT COUNT(ngrts.id) 
		FROM ',qi_cdb_schema,'.ng_regulartimeseries AS ngrts
		INNER JOIN ',qi_cdb_schema,'.cityobject AS co
		ON ngrts.id = co.id
	');
	EXECUTE sql_feat_count INTO num_features;
	RAISE NOTICE 'Found % features for RegularTimeSeries',num_features;
	
	curr_class := 'RegularTimeSeries';
	lod := 'lodx';
	l_name := concat(cdb_schema,'_ng_regulartimeseries_lodx');
	av_name := concat('_a_',cdb_schema,'_ng_regulartimeseries');
	gv_name := ' ';
	qml_form_name := 'ng_regulartimeseries_form.qml';
	qml_symb_name := ' ';
	qml_3d_name := ' ';
	trig_f_suffix := 'ng_regulartimeseries';
	qi_l_name := quote_ident(l_name);
	ql_l_name := quote_literal(l_name);
	qi_av_name := quote_ident(av_name);
	ql_av_name := quote_literal(av_name);
	qi_gv_name := quote_ident(gv_name);
	ql_gv_name := quote_literal(gv_name);

	IF (num_features > 0) OR (force_layer_creation IS TRUE) THEN
		
		----------------------------------------------------
		-- VIEW FOR ATTRIBUTES
		----------------------------------------------------
		sql_layer := concat(sql_layer,qgis_pkg.generate_sql_view_header(qi_usr_schema,qi_l_name),'
			SELECT 
			ngrts.id,
			ngrts.timeinterval,
			co.gmlid,
			co.name,
			co.description,
			co.creation_date,
			co.last_modification_date,
			co.updating_person,
			ngrts.timeinterval_factor,
			ngrts.timeinterval_radix,
			ngrts.timeinterval_unit,
  			ngrts.timeperiodprop_beginposition,
			ngrts.timeperiodproper_endposition,
			ngrts.values_,
			ngrts.values_uom,
			ngts.timevaluesprop_acquisitionme,
			ngts.timevaluesprop_interpolation,
			ngts.timevaluesprop_qualitydescri,
			ngts.timevaluesprop_thematicdescr,
			ngts.timevaluespropertiest_source
			FROM ',qi_cdb_schema,'.ng_regulartimeseries AS ngrts
			INNER JOIN ',qi_cdb_schema,'.ng_timeseries AS ngts
			ON ngrts.id = ngts.id
			INNER JOIN ',qi_cdb_schema,'.cityobject AS co
			ON (ngrts.id = co.id ',sql_where,');
			COMMENT ON VIEW ',qi_usr_schema,'.',qi_l_name,' IS ''View of RegularTimeSeries in schema ',qi_cdb_schema,''';
			ALTER TABLE ',qi_usr_schema,'.',qi_l_name,' OWNER TO ',qi_usr_name,';
		');
		-- add triggers to make view updatable
		sql_trig := concat(sql_trig,qgis_pkg.generate_sql_triggers(usr_schema, l_name, trig_f_suffix));
		
		-- Add entry to update table layer_metadata
		sql_ins := concat(sql_ins,'
			(',ql_cdb_schema,',',ql_ade_prefix,',',ql_l_type,',',ql_feature_type,',',quote_literal(root_class),',',quote_literal(curr_class),',',quote_literal(lod),',
			 ',ql_l_name,',',ql_av_name,',',ql_gv_name,',',num_features,',clock_timestamp(),',quote_literal(qml_form_name),',',quote_literal(qml_symb_name),',
			 ',quote_literal(qml_3d_name),',',quote_nullable(enum_cols_array),',',quote_nullable(codelist_cols_array),'),');
		
	ELSE
		sql_layer := concat(sql_layer,qgis_pkg.generate_sql_matview_else(qi_usr_schema,ql_cdb_schema,ql_l_type,ql_l_name,qi_gv_name));
	END IF;
	
	IF sql_ins IS NOT NULL THEN
		sql_ins := concat(sql_upd, substr(sql_ins,1, length(sql_ins)-1), ';');
	END IF;
	
	sql_statement := concat(sql_layer,sql_trig,sql_ins);
	RETURN sql_statement;
END;
$$ LANGUAGE plpgsql;	
COMMENT ON FUNCTION qgis_pkg.generate_sql_layers_ng_regulartimeseries(varchar,varchar,integer,integer,numeric,geometry,boolean,varchar) IS 'Generate SQL script to create layers for class RegularTimeSeries';
REVOKE EXECUTE ON FUNCTION qgis_pkg.generate_sql_layers_ng_regulartimeseries(varchar,varchar,integer,integer,numeric,geometry,boolean,varchar) FROM public; 	

-------------------------------------------------------------------
-- CREATE FUNCTION qgis_pkg.generate_sql_ng_regulartimeseriesfile
-------------------------------------------------------------------
DROP FUNCTION IF EXISTS qgis_pkg.generate_sql_layers_ng_regulartimeseriesfile(varchar,varchar,integer,integer,numeric,geometry,boolean,varchar) CASCADE;
CREATE OR REPLACE FUNCTION qgis_pkg.generate_sql_layers_ng_regulartimeseriesfile(usr_name varchar,cdb_schema varchar,perform_snapping integer,digits integer,
								          	 area_poly_min numeric,mview_bbox geometry,force_layer_creation boolean,ade_prefix varchar)
RETURNS text AS $$
DECLARE

	feature_type CONSTANT varchar := ' ';
	l_type varchar := 'DetailViewNoGeom';
	qgis_user_group_name CONSTANT varchar := (SELECT qgis_pkg.create_qgis_pkg_usrgroup_name());
	usr_schema varchar := (SELECT qgis_pkg.create_qgis_usr_schema_name(usr_name));
	usr_names_array varchar[] := (SELECT array_agg(s.usr_name) FROM qgis_pkg.list_qgis_pkg_usrgroup_members() AS s);
	usr_schemas_array varchar[] := (SELECT array_agg(s.usr_schema) FROM qgis_pkg.list_usr_schemas() AS s);
	cdb_schemas_array varchar[] := (SELECT array_agg(s.cdb_schema) FROM qgis_pkg.list_cdb_schemas() AS s);
	srid integer;
	num_features bigint;
	root_class varchar;
	curr_class varchar;
	lod varchar;
	ql_feature_type varchar := quote_literal(feature_type);
	ql_l_type varchar := quote_literal(l_type);
	qi_cdb_schema varchar; ql_cdb_schema varchar;
	qi_usr_schema varchar; ql_usr_schema varchar;
	qi_usr_name varchar; ql_usr_name varchar; ql_ade_prefix varchar;
	l_name varchar; ql_l_name varchar; qi_l_name varchar;
	av_name varchar; ql_av_name varchar; qi_av_name varchar;
	gv_name varchar; qi_gv_name varchar; ql_gv_name varchar;
	qml_form_name 	varchar := NULL;
	qml_symb_name 	varchar := NULL;
	qml_3d_name 	varchar := NULL;
	trig_f_suffix   varchar := NULL;
	r RECORD; s RECORD; t RECORD; u RECORD;
	sql_feat_count	text := NULL;
	sql_where		text := NULL;
	sql_upd			text := NULL;
	sql_ins			text := NULL;
	sql_trig		text := NULL;
	sql_layer	 	text := NULL;
	sql_statement	text := NULL;
	enum_cols_array varchar[][] := ARRAY[['ng_timeseries','timevaluesprop_acquisitionme'],['ng_timeseries','timevaluesprop_interpolation']];
	codelist_cols_array varchar[][] := NULL;
	sql_co_atts varchar := 'co.id::bigint,co.gmlid,co.gmlid_codespace,co.name,
				co.name_codespace,co.description,co.creation_date,
				co.termination_date,co.last_modification_date,
				co.updating_person,co.reason_for_update';

BEGIN
	-- check if user name exists
	IF NOT usr_name = ANY(usr_names_array) THEN
	RAISE EXCEPTION 'usr_name is invalid. It must be an existing database user and member of role (group) "%"',qgis_user_group_name;
	END IF;
	
	-- check if usr_schema exists
	IF NOT usr_schema = ANY(usr_schemas_array) THEN
	RAISE EXCEPTION 'usr_schema % does not exist. Please create it beforehand',usr_schema;
	END IF;
	
	-- check if cdb_schema exists
	IF NOT cdb_schema = ANY(cdb_schemas_array)  THEN
	RAISE EXCEPTION 'cdb_schema % is invalid. It must correspond to an existing city db schema',cdb_schema;
	END IF;

	-- add quote identifier (qi_) and quote literal (ql_) for later user in dynamic queries.
	qi_cdb_schema := quote_ident(cdb_schema);
	ql_cdb_schema := quote_literal(cdb_schema);
	qi_usr_name   := quote_ident(usr_name);
	ql_usr_name   := quote_literal(usr_name);
	qi_usr_schema := quote_ident(usr_schema);
	ql_usr_schema := quote_literal(usr_schema);
	ql_ade_prefix := quote_literal(ade_prefix);
	
	-- Prepare fixed part of SQL statements
	-- Remove previous entries from the layer_metadata Table, and insert it again.
	sql_upd := concat('
	--DELETE FROM ',qi_usr_schema,'.layer_metadata AS l WHERE l.cdb_schema = ',ql_cdb_schema,' AND l.class = ',quote_literal('RegularTimeSeriesFile'),';
	INSERT INTO ',qi_usr_schema,'.layer_metadata 
	(cdb_schema, ade_prefix, layer_type, feature_type, root_class, class, lod, layer_name, av_name, gv_name, n_features, creation_date, qml_form, qml_symb, qml_3d, enum_cols, codelist_cols)
	VALUES');

	RAISE NOTICE 'For module "%" and user "%": creating layers in usr_schema "%" for cdb_schema "%"', feature_type, qi_usr_name, qi_usr_schema, qi_cdb_schema;
	
	--Initialise variables 
	sql_layer := NULL; sql_ins := NULL; sql_trig := NULL;
	root_class := feature_type;

	-----------------------------------------------------------
	-- CREATE LAYER REGULARTIMESERIESFILE
	-----------------------------------------------------------
	sql_feat_count := concat('
		SELECT COUNT(ngrtsf.id) 
		FROM ',qi_cdb_schema,'.ng_regulartimeseriesfile AS ngrtsf
		INNER JOIN ',qi_cdb_schema,'.cityobject AS co
		ON ngrtsf.id = co.id 
	');
	EXECUTE sql_feat_count INTO num_features;
	RAISE NOTICE 'Found % features for RegularTimeSeriesFile',num_features;
	
	curr_class := 'RegularTimeSeriesFile';
	lod := 'lodx';
	l_name := concat(cdb_schema,'_ng_regulartimeseriesfile_lodx');
	av_name := concat('_a_',cdb_schema,'_ng_reguartimeseriesfile');
	gv_name := ' ';
	qml_form_name := 'ng_regulartimeseriesfile_form.qml';
	qml_symb_name := ' ';
	qml_3d_name := ' ';
	trig_f_suffix := 'ng_regulartimeseriesfile';
	qi_l_name := quote_ident(l_name);
	ql_l_name := quote_literal(l_name);
	qi_av_name := quote_ident(av_name);
	ql_av_name := quote_literal(av_name);
	qi_gv_name := quote_ident(gv_name);
	ql_gv_name := quote_literal(gv_name);

	IF (num_features > 0) OR (force_layer_creation IS TRUE) THEN
		
		----------------------------------------------------
		-- VIEW FOR ATTRIBUTES
		----------------------------------------------------
		sql_layer := concat(sql_layer,qgis_pkg.generate_sql_view_header(qi_usr_schema,qi_l_name),'
			SELECT 
			co.id AS co_id,
			ngrtsf.id,
			co.gmlid,
			co.name,
			co.description,
			co.creation_date,
			co.last_modification_date,
			co.termination_date,
			co.updating_person,
			ngrtsf.decimalsymbol,
			ngrtsf.fieldseparator,
			ngrtsf.file_,
			ngrtsf.numberofheaderlines,
			ngrtsf.recordseparator,
			ngrtsf.timeinterval,
			ngrtsf.timeinterval_factor,
			ngrtsf.timeinterval_radix,
			ngrtsf.timeinterval_unit,
			ngrtsf.timeperiodprop_beginposition,
			ngrtsf.timeperiodproper_endposition,
			ngrtsf.valuecolumnnumber,
			ngrtsf.uom,
			ngts.timevaluesprop_acquisitionme,
			ngts.timevaluesprop_interpolation,
			ngts.timevaluesprop_qualitydescri,
			ngts.timevaluesprop_thematicdescr,
			ngts.timevaluespropertiest_source
			FROM ',qi_cdb_schema,'.ng_regulartimeseriesfile AS ngrtsf
			INNER JOIN ',qi_cdb_schema,'.ng_timeseries AS ngts
			ON ngrtsf.id = ngts.id
			INNER JOIN ',qi_cdb_schema,'.cityobject AS co
			ON (ngrtsf.id = co.id ',sql_where,');
			COMMENT ON VIEW ',qi_usr_schema,'.',qi_l_name,' IS ''View of RegularTimeSeriesFile in schema ',qi_cdb_schema,''';
			ALTER TABLE ',qi_usr_schema,'.',qi_l_name,' OWNER TO ',qi_usr_name,';
		');
		-- add triggers to make view updatable
		sql_trig := concat(sql_trig,qgis_pkg.generate_sql_triggers(usr_schema, l_name, trig_f_suffix));
		sql_ins := concat(sql_ins,'
			(',ql_cdb_schema,',',ql_ade_prefix,',',ql_l_type,',',ql_feature_type,',',quote_literal(root_class),',',quote_literal(curr_class),',',quote_literal(lod),',
			 ',ql_l_name,',',ql_av_name,',',ql_gv_name,',',num_features,',clock_timestamp(),',quote_literal(qml_form_name),',',quote_literal(qml_symb_name),',
			 ',quote_literal(qml_3d_name),',',quote_nullable(enum_cols_array),',',quote_nullable(codelist_cols_array),'),');
		
	ELSE
		sql_layer := concat(sql_layer,qgis_pkg.generate_sql_matview_else(qi_usr_schema,ql_cdb_schema,ql_l_type,ql_l_name,qi_gv_name));
	END IF;
	
	IF sql_ins IS NOT NULL THEN
		sql_ins := concat(sql_upd, substr(sql_ins,1, length(sql_ins)-1), ';');
	END IF;
	
	sql_statement := concat(sql_layer,sql_trig,sql_ins);
	RETURN sql_statement;
END;
$$ LANGUAGE plpgsql;	
COMMENT ON FUNCTION qgis_pkg.generate_sql_layers_ng_regulartimeseriesfile(varchar,varchar,integer,integer,numeric,geometry,boolean,varchar) IS 'Generate SQL script to create layers for class RegularTimeSeriesFile';
REVOKE EXECUTE ON FUNCTION qgis_pkg.generate_sql_layers_ng_regulartimeseriesfile(varchar,varchar,integer,integer,numeric,geometry,boolean,varchar) FROM public; 	

-------------------------------------------------------------------
-- CREATE FUNCTION qgis_pkg.generate_sql_ng_timevaluesproperties
-------------------------------------------------------------------
DROP FUNCTION IF EXISTS qgis_pkg.generate_sql_layers_ng_timevaluesproperties(varchar,varchar,integer,integer,numeric,geometry,boolean,varchar) CASCADE;
CREATE OR REPLACE FUNCTION qgis_pkg.generate_sql_layers_ng_timevaluesproperties(usr_name varchar,cdb_schema varchar,perform_snapping integer,digits integer,
								                area_poly_min numeric,mview_bbox geometry,force_layer_creation boolean,ade_prefix varchar)
RETURNS text AS $$
DECLARE

	feature_type CONSTANT varchar := ' ';
	l_type varchar := 'DetailViewNoGeom';
	qgis_user_group_name CONSTANT varchar := (SELECT qgis_pkg.create_qgis_pkg_usrgroup_name());
	usr_schema varchar := (SELECT qgis_pkg.create_qgis_usr_schema_name(usr_name));
	usr_names_array varchar[] := (SELECT array_agg(s.usr_name) FROM qgis_pkg.list_qgis_pkg_usrgroup_members() AS s);
	usr_schemas_array varchar[] := (SELECT array_agg(s.usr_schema) FROM qgis_pkg.list_usr_schemas() AS s);
	cdb_schemas_array varchar[] := (SELECT array_agg(s.cdb_schema) FROM qgis_pkg.list_cdb_schemas() AS s);
	srid integer;
	num_features bigint;
	root_class varchar;
	curr_class varchar;
	lod varchar;
	ql_feature_type varchar := quote_literal(feature_type);
	ql_l_type varchar := quote_literal(l_type);
	qi_cdb_schema varchar; ql_cdb_schema varchar;
	qi_usr_schema varchar; ql_usr_schema varchar;
	qi_usr_name varchar; ql_usr_name varchar; ql_ade_prefix varchar;
	l_name varchar; ql_l_name varchar; qi_l_name varchar;
	av_name varchar; ql_av_name varchar; qi_av_name varchar;
	gv_name varchar; qi_gv_name varchar; ql_gv_name varchar;
	qml_form_name 	varchar := NULL;
	qml_symb_name 	varchar := NULL;
	qml_3d_name 	varchar := NULL;
	trig_f_suffix   varchar := NULL;
	r RECORD; s RECORD; t RECORD; u RECORD;
	sql_feat_count	text := NULL;
	sql_where		text := NULL;
	sql_upd			text := NULL;
	sql_ins			text := NULL;
	sql_trig		text := NULL;
	sql_layer	 	text := NULL;
	sql_statement	text := NULL;
	enum_cols_array varchar[][] := ARRAY[['ng_timevaluesproperties','acquisitionmethod'],['ng_timevaluesproperties','interpolationtype']];
	codelist_cols_array varchar[][] := NULL;

BEGIN
	-- check if user name exists
	IF NOT usr_name = ANY(usr_names_array) THEN
	RAISE EXCEPTION 'usr_name is invalid. It must be an existing database user and member of role (group) "%"',qgis_user_group_name;
	END IF;
	
	-- check if usr_schema exists
	IF NOT usr_schema = ANY(usr_schemas_array) THEN
	RAISE EXCEPTION 'usr_schema % does not exist. Please create it beforehand',usr_schema;
	END IF;
	
	-- check if cdb_schema exists
	IF NOT cdb_schema = ANY(cdb_schemas_array)  THEN
	RAISE EXCEPTION 'cdb_schema % is invalid. It must correspond to an existing city db schema',cdb_schema;
	END IF;

	-- add quote identifier (qi_) and quote literal (ql_) for later user in dynamic queries.
	qi_cdb_schema := quote_ident(cdb_schema);
	ql_cdb_schema := quote_literal(cdb_schema);
	qi_usr_name   := quote_ident(usr_name);
	ql_usr_name   := quote_literal(usr_name);
	qi_usr_schema := quote_ident(usr_schema);
	ql_usr_schema := quote_literal(usr_schema);
	ql_ade_prefix := quote_literal(ade_prefix);
	
	-- Prepare fixed part of SQL statements
	-- Remove previous entries from the layer_metadata Table, and insert it again.
	sql_upd := concat('
	DELETE FROM ',qi_usr_schema,'.layer_metadata AS l WHERE l.cdb_schema = ',ql_cdb_schema,' AND l.class = ',quote_literal('TimeValuesProperties'),';
	INSERT INTO ',qi_usr_schema,'.layer_metadata 
	(cdb_schema, ade_prefix, layer_type, feature_type, root_class, class, lod, layer_name, av_name, gv_name, n_features, creation_date, qml_form, qml_symb, qml_3d, enum_cols, codelist_cols)
	VALUES');

	RAISE NOTICE 'For module "%" and user "%": creating layers in usr_schema "%" for cdb_schema "%"', feature_type, qi_usr_name, qi_usr_schema, qi_cdb_schema;
	
	--Initialise variables 
	sql_layer := NULL; sql_ins := NULL; sql_trig := NULL;
	root_class := feature_type;

	-----------------------------------------------------------
	-- CREATE LAYER TIMEVALUESPROPERTIES
	-----------------------------------------------------------
	sql_feat_count := concat('
		SELECT COUNT(ngtvp.id) 
		FROM ',qi_cdb_schema,'.ng_timevaluesproperties AS ngtvp
	');
	EXECUTE sql_feat_count INTO num_features;
	RAISE NOTICE 'Found % features for TimeValuesProperties',num_features;
	
	curr_class := 'TimeValuesProperties';
	lod := 'lodx';
	l_name := concat(cdb_schema,'_ng_timevaluesproperties_lodx');
	av_name := concat('_a_',cdb_schema,'_ng_timevaluesproperties');
	gv_name := ' ';
	qml_form_name := 'ng_timevaluesproperties_form.qml';
	qml_symb_name := ' ';
	qml_3d_name := ' ';
	trig_f_suffix := 'ng_timevaluesproperties';
	qi_l_name := quote_ident(l_name);
	ql_l_name := quote_literal(l_name);
	qi_av_name := quote_ident(av_name);
	ql_av_name := quote_literal(av_name);
	qi_gv_name := quote_ident(gv_name);
	ql_gv_name := quote_literal(gv_name);

	IF (num_features > 0) OR (force_layer_creation IS TRUE) THEN
		
		----------------------------------------------------
		-- VIEW FOR ATTRIBUTES
		----------------------------------------------------
		sql_layer := concat(sql_layer,qgis_pkg.generate_sql_view_header(qi_usr_schema,qi_l_name),'
			SELECT
			ngtvp.id,
			ngtvp.acquisitionmethod,
			ngtvp.interpolationtype,
			ngtvp.qualitydescription,
			ngtvp.source,
			ngtvp.thematicdescription
			FROM ',qi_cdb_schema,'.ng_timevaluesproperties AS ngtvp;
			COMMENT ON VIEW ',qi_usr_schema,'.',qi_l_name,' IS ''View of TimeValuesProperties in schema ',qi_cdb_schema,''';
			ALTER TABLE ',qi_usr_schema,'.',qi_l_name,' OWNER TO ',qi_usr_name,';
		');
		-- add triggers to make view updatable
		sql_trig := concat(sql_trig,qgis_pkg.generate_sql_triggers(usr_schema, l_name, trig_f_suffix));
		sql_ins := concat(sql_ins,'
			(',ql_cdb_schema,',',ql_ade_prefix,',',ql_l_type,',',ql_feature_type,',',quote_literal(root_class),',',quote_literal(curr_class),',',quote_literal(lod),',
			 ',ql_l_name,',',ql_av_name,',',ql_gv_name,',',num_features,',clock_timestamp(),',quote_literal(qml_form_name),',',quote_literal(qml_symb_name),',
			 ',quote_literal(qml_3d_name),',',quote_nullable(enum_cols_array),',',quote_nullable(codelist_cols_array),'),');
		
	ELSE
		sql_layer := concat(sql_layer,qgis_pkg.generate_sql_matview_else(qi_usr_schema,ql_cdb_schema,ql_l_type,ql_l_name,qi_gv_name));
	END IF;
	
	IF sql_ins IS NOT NULL THEN
		sql_ins := concat(sql_upd, substr(sql_ins,1, length(sql_ins)-1), ';');
	END IF;
	
	sql_statement := concat(sql_layer,sql_trig,sql_ins);
	RETURN sql_statement;
END;
$$ LANGUAGE plpgsql;	
COMMENT ON FUNCTION qgis_pkg.generate_sql_layers_ng_timevaluesproperties(varchar,varchar,integer,integer,numeric,geometry,boolean,varchar) IS 'Generate SQL script to create layers for class TimeValuesProperties';
REVOKE EXECUTE ON FUNCTION qgis_pkg.generate_sql_layers_ng_timevaluesproperties(varchar,varchar,integer,integer,numeric,geometry,boolean,varchar) FROM public; 	

-------------------------------------------------------------------
-- CREATE FUNCTION qgis_pkg.generate_sql_ng_construction
-------------------------------------------------------------------

DROP FUNCTION IF EXISTS qgis_pkg.generate_sql_layers_ng_construction(varchar,varchar,integer,integer,numeric,geometry,boolean,varchar);
CREATE OR REPLACE FUNCTION qgis_pkg.generate_sql_layers_ng_construction(usr_name varchar,cdb_schema varchar,perform_snapping integer,digits integer,
	                                                                area_poly_min numeric,mview_bbox geometry,force_layer_creation boolean,ade_prefix varchar)
RETURNS text AS $$
DECLARE

	feature_type CONSTANT varchar := ' ';
	l_type varchar := 'DetailViewNoGeom';
	qgis_user_group_name CONSTANT varchar := (SELECT qgis_pkg.create_qgis_pkg_usrgroup_name());
	usr_schema varchar := (SELECT qgis_pkg.create_qgis_usr_schema_name(usr_name));
	usr_names_array varchar[] := (SELECT array_agg(s.usr_name) FROM qgis_pkg.list_qgis_pkg_usrgroup_members() AS s);
	usr_schemas_array varchar[] := (SELECT array_agg(s.usr_schema) FROM qgis_pkg.list_usr_schemas() AS s);
	cdb_schemas_array varchar[] := (SELECT array_agg(s.cdb_schema) FROM qgis_pkg.list_cdb_schemas() AS s);
	srid integer;
	num_features bigint;
	root_class varchar;
	curr_class varchar;
	lod varchar;
	ql_feature_type varchar := quote_literal(feature_type);
	ql_l_type varchar := quote_literal(l_type);
	qi_cdb_schema varchar; ql_cdb_schema varchar;
	qi_usr_schema varchar; ql_usr_schema varchar;
	qi_usr_name varchar; ql_usr_name varchar; ql_ade_prefix varchar;
	l_name varchar; ql_l_name varchar; qi_l_name varchar;
	av_name varchar; ql_av_name varchar; qi_av_name varchar;
	gv_name varchar; qi_gv_name varchar; ql_gv_name varchar;
	qml_form_name 	varchar := NULL;
	qml_symb_name 	varchar := NULL;
	qml_3d_name 	varchar := NULL;
	trig_f_suffix   varchar := NULL;
	r RECORD; s RECORD; t RECORD; u RECORD;
	sql_feat_count	text := NULL;
	sql_where		text := NULL;
	sql_upd			text := NULL;
	sql_ins			text := NULL;
	sql_trig		text := NULL;
	sql_layer	 	text := NULL;
	sql_statement	text := NULL;
	enum_cols_array varchar[][] := NULL;
	codelist_cols_array varchar[][] := NULL;
	sql_co_atts varchar := 'co.id::bigint,co.gmlid,co.gmlid_codespace,co.name,
				co.name_codespace,co.description,co.creation_date,
				co.termination_date,co.last_modification_date,
				co.updating_person,co.reason_for_update,co.lineage,';

BEGIN
	-- check if user name exists
	IF NOT usr_name = ANY(usr_names_array) THEN
	RAISE EXCEPTION 'usr_name is invalid. It must be an existing database user and member of role (group) "%"',qgis_user_group_name;
	END IF;
	
	-- check if usr_schema exists
	IF NOT usr_schema = ANY(usr_schemas_array) THEN
	RAISE EXCEPTION 'usr_schema % does not exist. Please create it beforehand',usr_schema;
	END IF;
	
	-- check if cdb_schema exists
	IF NOT cdb_schema = ANY(cdb_schemas_array)  THEN
	RAISE EXCEPTION 'cdb_schema % is invalid. It must correspond to an existing city db schema',cdb_schema;
	END IF;

	-- add quote identifier (qi_) and quote literal (ql_) for later user in dynamic queries.
	qi_cdb_schema := quote_ident(cdb_schema);
	ql_cdb_schema := quote_literal(cdb_schema);
	qi_usr_name   := quote_ident(usr_name);
	ql_usr_name   := quote_literal(usr_name);
	qi_usr_schema := quote_ident(usr_schema);
	ql_usr_schema := quote_literal(usr_schema);
	ql_ade_prefix := quote_literal(ade_prefix);
	
	-- Prepare fixed part of SQL statements
	-- Remove previous entries from the layer_metadata Table, and insert it again.
	sql_upd := concat('
	DELETE FROM ',qi_usr_schema,'.layer_metadata AS l WHERE l.cdb_schema = ',ql_cdb_schema,' AND l.class = ',quote_literal('Construction'),';
	INSERT INTO ',qi_usr_schema,'.layer_metadata 
	(cdb_schema, ade_prefix, layer_type, feature_type, root_class, class, lod, layer_name, av_name, gv_name, n_features, creation_date, qml_form, qml_symb, qml_3d, enum_cols, codelist_cols)
	VALUES');
	
	RAISE NOTICE 'For module "%" and user "%": creating layers in usr_schema "%" for cdb_schema "%"', feature_type, qi_usr_name, qi_usr_schema, qi_cdb_schema;
	
	--Initialise variables 
	sql_layer := NULL; sql_ins := NULL; sql_trig := NULL;
	root_class := feature_type;
	
	-----------------------------------------------------------
	-- CREATE LAYER CONSTRUCTION
	-----------------------------------------------------------
	sql_feat_count := concat('
		SELECT COUNT(ngcon.id) FROM ',qi_cdb_schema,'.ng_construction AS ngcon
		INNER JOIN ',qi_cdb_schema,'.cityobject AS co ON ngcon.id = co.id
	');
	EXECUTE sql_feat_count INTO num_features;
	RAISE NOTICE 'Found % features for Construction',num_features;

	curr_class := 'Construction';
	lod := 'lodx';
	l_name := concat(cdb_schema,'_ng_construction_lodx');
	av_name := concat('_a_',cdb_schema,'_ng_construction');
	gv_name := concat(' ');
	qml_form_name := 'ng_construction_form.qml';
	qml_symb_name := ' ';
	qml_3d_name := ' ';
	trig_f_suffix := 'ng_construction';
	qi_l_name := quote_ident(l_name);
	ql_l_name := quote_literal(l_name);
	qi_av_name := quote_ident(av_name);
	ql_av_name := quote_literal(av_name);
	qi_gv_name := quote_ident(gv_name);
	ql_gv_name := quote_literal(gv_name);

	IF (num_features > 0) OR (force_layer_creation IS TRUE) THEN
		
		----------------------------------------------------
		-- VIEW FOR ATTRIBUTES
		----------------------------------------------------
		sql_layer := concat(sql_layer,qgis_pkg.generate_sql_view_header(qi_usr_schema,qi_l_name),'
			SELECT ',
			sql_co_atts,'
			ngcon.opticalproperties_id,
			ngcon.uvalue,
			ngcon.uvalue_uom
			FROM ',qi_cdb_schema,'.ng_construction AS ngcon
			INNER JOIN ',qi_cdb_schema,'.cityobject AS co
			ON (ngcon.id = co.id ',sql_where,');
			COMMENT ON VIEW ',qi_usr_schema,'.',qi_l_name,' IS ''View of Construction in schema ',qi_cdb_schema,''';
			ALTER TABLE ',qi_usr_schema,'.',qi_l_name,' OWNER TO ',qi_usr_name,';
		');
		-- add triggers to make view updatable
		sql_trig := concat(sql_trig,qgis_pkg.generate_sql_triggers(usr_schema, l_name, trig_f_suffix));
		
		-- Add entry to update table layer_metadata
		sql_ins := concat(sql_ins,'
			(',ql_cdb_schema,',',ql_ade_prefix,',',ql_l_type,',',ql_feature_type,',',quote_literal(root_class),',',quote_literal(curr_class),',',quote_literal(lod),',
			 ',ql_l_name,',',ql_av_name,',',ql_gv_name,',',num_features,',clock_timestamp(),',quote_literal(qml_form_name),',',quote_literal(qml_symb_name),',
			 ',quote_literal(qml_3d_name),',',quote_nullable(enum_cols_array),',',quote_nullable(codelist_cols_array),'),');
		
	ELSE
		sql_layer := concat(sql_layer,qgis_pkg.generate_sql_matview_else(qi_usr_schema,ql_cdb_schema,ql_l_type,ql_l_name,qi_gv_name));
	END IF;
	
	IF sql_ins IS NOT NULL THEN
		sql_ins := concat(sql_upd, substr(sql_ins,1, length(sql_ins)-1), ';');
	END IF;
	
	sql_statement := concat(sql_layer,sql_trig,sql_ins);
	RETURN sql_statement;
END;
$$ LANGUAGE plpgsql;	
COMMENT ON FUNCTION qgis_pkg.generate_sql_layers_ng_construction(varchar,varchar,integer,integer,numeric,geometry,boolean,varchar) IS 'Generate SQL script to create layers for class Construction';
REVOKE EXECUTE ON FUNCTION qgis_pkg.generate_sql_layers_ng_construction(varchar,varchar,integer,integer,numeric,geometry,boolean,varchar) FROM public; 	

-------------------------------------------------------------------
-- CREATE FUNCTION qgis_pkg.generate_sql_ng_layer
-------------------------------------------------------------------

DROP FUNCTION IF EXISTS qgis_pkg.generate_sql_layers_ng_layer(varchar,varchar,integer,integer,numeric,geometry,boolean,varchar);
CREATE OR REPLACE FUNCTION qgis_pkg.generate_sql_layers_ng_layer(usr_name varchar,cdb_schema varchar,perform_snapping integer,digits integer,
								 area_poly_min numeric,mview_bbox geometry,force_layer_creation boolean,ade_prefix varchar)
RETURNS text AS $$
DECLARE

	feature_type CONSTANT varchar := ' ';
	l_type varchar := 'DetailViewNoGeom';
	qgis_user_group_name CONSTANT varchar := (SELECT qgis_pkg.create_qgis_pkg_usrgroup_name());
	usr_schema varchar := (SELECT qgis_pkg.create_qgis_usr_schema_name(usr_name));
	usr_names_array varchar[] := (SELECT array_agg(s.usr_name) FROM qgis_pkg.list_qgis_pkg_usrgroup_members() AS s);
	usr_schemas_array varchar[] := (SELECT array_agg(s.usr_schema) FROM qgis_pkg.list_usr_schemas() AS s);
	cdb_schemas_array varchar[] := (SELECT array_agg(s.cdb_schema) FROM qgis_pkg.list_cdb_schemas() AS s);
	srid integer;
	num_features bigint;
	root_class varchar;
	curr_class varchar;
	lod varchar;
	ql_feature_type varchar := quote_literal(feature_type);
	ql_l_type varchar := quote_literal(l_type);
	qi_cdb_schema varchar; ql_cdb_schema varchar;
	qi_usr_schema varchar; ql_usr_schema varchar;
	qi_usr_name varchar; ql_usr_name varchar; ql_ade_prefix varchar;
	l_name varchar; ql_l_name varchar; qi_l_name varchar;
	av_name varchar; ql_av_name varchar; qi_av_name varchar;
	gv_name varchar; qi_gv_name varchar; ql_gv_name varchar;
	qml_form_name 	varchar := NULL;
	qml_symb_name 	varchar := NULL;
	qml_3d_name 	varchar := NULL;
	trig_f_suffix   varchar := NULL;
	r RECORD; s RECORD; t RECORD; u RECORD;
	sql_feat_count	text := NULL;
	sql_where		text := NULL;
	sql_upd			text := NULL;
	sql_ins			text := NULL;
	sql_trig		text := NULL;
	sql_layer	 	text := NULL;
	sql_statement	text := NULL;
	enum_cols_array varchar[][] := NULL;
	codelist_cols_array varchar[][] := NULL;
	sql_co_atts varchar := 'co.id::bigint,co.gmlid,co.gmlid_codespace,co.name,
				co.name_codespace,co.description,co.creation_date,
				co.termination_date,co.last_modification_date,
				co.updating_person,co.reason_for_update,co.lineage,';

BEGIN
	-- check if user name exists
	IF NOT usr_name = ANY(usr_names_array) THEN
	RAISE EXCEPTION 'usr_name is invalid. It must be an existing database user and member of role (group) "%"',qgis_user_group_name;
	END IF;
	
	-- check if usr_schema exists
	IF NOT usr_schema = ANY(usr_schemas_array) THEN
	RAISE EXCEPTION 'usr_schema % does not exist. Please create it beforehand',usr_schema;
	END IF;
	
	-- check if cdb_schema exists
	IF NOT cdb_schema = ANY(cdb_schemas_array)  THEN
	RAISE EXCEPTION 'cdb_schema % is invalid. It must correspond to an existing city db schema',cdb_schema;
	END IF;

	-- add quote identifier (qi_) and quote literal (ql_) for later user in dynamic queries.
	qi_cdb_schema := quote_ident(cdb_schema);
	ql_cdb_schema := quote_literal(cdb_schema);
	qi_usr_name   := quote_ident(usr_name);
	ql_usr_name   := quote_literal(usr_name);
	qi_usr_schema := quote_ident(usr_schema);
	ql_usr_schema := quote_literal(usr_schema);
	ql_ade_prefix := quote_literal(ade_prefix);

	-- Prepare fixed part of SQL statements
	-- Remove previous entries from the layer_metadata Table, and insert it again.
	sql_upd := concat('
	DELETE FROM ',qi_usr_schema,'.layer_metadata AS l WHERE l.cdb_schema = ',ql_cdb_schema,' AND l.class = ',quote_literal('Layer'),';
	INSERT INTO ',qi_usr_schema,'.layer_metadata 
	(cdb_schema, ade_prefix, layer_type, feature_type, root_class, class, lod, layer_name, av_name, gv_name, n_features, creation_date, qml_form, qml_symb, qml_3d, enum_cols, codelist_cols)
	VALUES');

	RAISE NOTICE 'For module "%" and user "%": creating layers in usr_schema "%" for cdb_schema "%"', feature_type, qi_usr_name, qi_usr_schema, qi_cdb_schema;
	
	--Initialise variables 
	sql_layer := NULL; sql_ins := NULL; sql_trig := NULL;
	root_class := ' ';
	
	-----------------------------------------------------------
	-- CREATE LAYER LAYER
	-----------------------------------------------------------
	sql_feat_count := concat('
		SELECT COUNT(ngl.id) FROM ',qi_cdb_schema,'.ng_layer AS ngl
		INNER JOIN ',qi_cdb_schema,'.cityobject AS co ON ngl.id = co.id
	');
	EXECUTE sql_feat_count INTO num_features;
	RAISE NOTICE 'Found % features for Layer',num_features;

	curr_class := 'Layer';
	lod := 'lodx';
	l_name := concat(cdb_schema,'_ng_layer_lodx');
	av_name := concat('_a_',cdb_schema,'_ng_layer');
	gv_name := concat(' ');
	qml_form_name := 'ng_layer_form.qml';
	qml_symb_name := ' ';
	qml_3d_name := ' ';
	trig_f_suffix := 'ng_layer';
	qi_l_name := quote_ident(l_name);
	ql_l_name := quote_literal(l_name);
	qi_av_name := quote_ident(av_name);
	ql_av_name := quote_literal(av_name);
	qi_gv_name := quote_ident(gv_name);
	ql_gv_name := quote_literal(gv_name);

	IF (num_features > 0) OR (force_layer_creation IS TRUE) THEN
		
		----------------------------------------------------
		-- VIEW FOR ATTRIBUTES
		----------------------------------------------------
		sql_layer := concat(sql_layer,qgis_pkg.generate_sql_view_header(qi_usr_schema,qi_l_name),'
			SELECT
		        ngl.id AS co_id,',
			sql_co_atts,'
			ngl.construction_layer_id
			FROM ',qi_cdb_schema,'.ng_layer AS ngl
			INNER JOIN ',qi_cdb_schema,'.cityobject AS co
			ON (ngl.id = co.id ',sql_where,');
			COMMENT ON VIEW ',qi_usr_schema,'.',qi_l_name,' IS ''View of Layer in schema ',qi_cdb_schema,''';
			ALTER TABLE ',qi_usr_schema,'.',qi_l_name,' OWNER TO ',qi_usr_name,';
		');
		
		-- add triggers to make view updatable
		sql_trig := concat(sql_trig,qgis_pkg.generate_sql_triggers(usr_schema, l_name, trig_f_suffix));
		
		-- Add entry to update table layer_metadata
		sql_ins := concat(sql_ins,'
			(',ql_cdb_schema,',',ql_ade_prefix,',',ql_l_type,',',ql_feature_type,',',quote_literal(root_class),',',quote_literal(curr_class),',',quote_literal(lod),',
			 ',ql_l_name,',',ql_av_name,',',ql_gv_name,',',num_features,',clock_timestamp(),',quote_literal(qml_form_name),',',quote_literal(qml_symb_name),',
			 ',quote_literal(qml_3d_name),',',quote_nullable(enum_cols_array),',',quote_nullable(codelist_cols_array),'),');
	ELSE
		sql_layer := concat(sql_layer,qgis_pkg.generate_sql_matview_else(qi_usr_schema,ql_cdb_schema,ql_l_type,ql_l_name,qi_gv_name));
	END IF;
	
	IF sql_ins IS NOT NULL THEN
		sql_ins := concat(sql_upd, substr(sql_ins,1, length(sql_ins)-1), ';');
	END IF;
	
	sql_statement := concat(sql_layer,sql_trig,sql_ins);
	RETURN sql_statement;
END;
$$ LANGUAGE plpgsql;	
COMMENT ON FUNCTION qgis_pkg.generate_sql_layers_ng_layer(varchar,varchar,integer,integer,numeric,geometry,boolean,varchar) IS 'Generate SQL script to create layers for class Layer';
REVOKE EXECUTE ON FUNCTION qgis_pkg.generate_sql_layers_ng_layer(varchar,varchar,integer,integer,numeric,geometry,boolean,varchar) FROM public; 	

-------------------------------------------------------------------
-- CREATE FUNCTION qgis_pkg.generate_sql_ng_layercomponent
-------------------------------------------------------------------

DROP FUNCTION IF EXISTS qgis_pkg.generate_sql_layers_ng_layercomponent(varchar,varchar,integer,integer,numeric,geometry,boolean,varchar);
CREATE OR REPLACE FUNCTION qgis_pkg.generate_sql_layers_ng_layercomponent(usr_name varchar,cdb_schema varchar,perform_snapping integer,digits integer,
									  area_poly_min numeric,mview_bbox geometry,force_layer_creation boolean,ade_prefix varchar)
RETURNS text AS $$
DECLARE

	feature_type CONSTANT varchar := ' ';
	l_type varchar := 'DetailViewNoGeom';
	qgis_user_group_name CONSTANT varchar := (SELECT qgis_pkg.create_qgis_pkg_usrgroup_name());
	usr_schema varchar := (SELECT qgis_pkg.create_qgis_usr_schema_name(usr_name));
	usr_names_array varchar[] := (SELECT array_agg(s.usr_name) FROM qgis_pkg.list_qgis_pkg_usrgroup_members() AS s);
	usr_schemas_array varchar[] := (SELECT array_agg(s.usr_schema) FROM qgis_pkg.list_usr_schemas() AS s);
	cdb_schemas_array varchar[] := (SELECT array_agg(s.cdb_schema) FROM qgis_pkg.list_cdb_schemas() AS s);
	srid integer;
	num_features bigint;
	root_class varchar;
	curr_class varchar;
	lod varchar;
	ql_feature_type varchar := quote_literal(feature_type);
	ql_l_type varchar := quote_literal(l_type);
	qi_cdb_schema varchar; ql_cdb_schema varchar;
	qi_usr_schema varchar; ql_usr_schema varchar;
	qi_usr_name varchar; ql_usr_name varchar; ql_ade_prefix varchar;
	l_name varchar; ql_l_name varchar; qi_l_name varchar;
	av_name varchar; ql_av_name varchar; qi_av_name varchar;
	gv_name varchar; qi_gv_name varchar; ql_gv_name varchar;
	qml_form_name 	varchar := NULL;
	qml_symb_name 	varchar := NULL;
	qml_3d_name 	varchar := NULL;
	trig_f_suffix   varchar := NULL;
	r RECORD; s RECORD; t RECORD; u RECORD;
	sql_feat_count	text := NULL;
	sql_where		text := NULL;
	sql_upd			text := NULL;
	sql_ins			text := NULL;
	sql_trig		text := NULL;
	sql_layer	 	text := NULL;
	sql_statement	text := NULL;
	enum_cols_array varchar[][] := NULL;
	codelist_cols_array varchar[][] := NULL;
	sql_co_atts varchar := 'co.id::bigint,co.gmlid,co.gmlid_codespace,co.name,
				co.name_codespace,co.description,co.creation_date,
				co.termination_date,co.last_modification_date,
				co.updating_person,co.reason_for_update,co.lineage,';

BEGIN
	-- check if user name exists
	IF NOT usr_name = ANY(usr_names_array) THEN
	RAISE EXCEPTION 'usr_name is invalid. It must be an existing database user and member of role (group) "%"',qgis_user_group_name;
	END IF;
	
	-- check if usr_schema exists
	IF NOT usr_schema = ANY(usr_schemas_array) THEN
	RAISE EXCEPTION 'usr_schema % does not exist. Please create it beforehand',usr_schema;
	END IF;
	
	-- check if cdb_schema exists
	IF NOT cdb_schema = ANY(cdb_schemas_array)  THEN
	RAISE EXCEPTION 'cdb_schema % is invalid. It must correspond to an existing city db schema',cdb_schema;
	END IF;

	-- add quote identifier (qi_) and quote literal (ql_) for later user in dynamic queries.
	qi_cdb_schema := quote_ident(cdb_schema);
	ql_cdb_schema := quote_literal(cdb_schema);
	qi_usr_name   := quote_ident(usr_name);
	ql_usr_name   := quote_literal(usr_name);
	qi_usr_schema := quote_ident(usr_schema);
	ql_usr_schema := quote_literal(usr_schema);
	ql_ade_prefix := quote_literal(ade_prefix);
	
	-- Prepare fixed part of SQL statements
	-- Remove previous entries from the layer_metadata Table, and insert it again.
	sql_upd := concat('
	DELETE FROM ',qi_usr_schema,'.layer_metadata AS l WHERE l.cdb_schema = ',ql_cdb_schema,' AND l.class = ',quote_literal('LayerComponent'),';
	INSERT INTO ',qi_usr_schema,'.layer_metadata 
	(cdb_schema, ade_prefix, layer_type, feature_type, root_class, class, lod, layer_name, av_name, gv_name, n_features, creation_date, qml_form, qml_symb, qml_3d, enum_cols, codelist_cols)
	VALUES');

	RAISE NOTICE 'For module "%" and user "%": creating layers in usr_schema "%" for cdb_schema "%"', feature_type, qi_usr_name, qi_usr_schema, qi_cdb_schema;
	
	--Initialise variables 
	sql_layer := NULL; sql_ins := NULL; sql_trig := NULL;
	root_class := ' ';
	
	-----------------------------------------------------------
	-- CREATE LAYER LAYERCOMPONENT
	-----------------------------------------------------------
	sql_feat_count := concat('
		SELECT COUNT(nglc.id) FROM ',qi_cdb_schema,'.ng_layercomponent AS nglc
		INNER JOIN ',qi_cdb_schema,'.cityobject AS co ON nglc.id = co.id
	');
	EXECUTE sql_feat_count INTO num_features;
	RAISE NOTICE 'Found % features for LayerComponent',num_features;

	curr_class := 'LayerComponent';
	lod := 'lodx';
	l_name := concat(cdb_schema,'_ng_layercomponent_lodx');
	av_name := concat('_a_',cdb_schema,'_ng_layercomponent');
	gv_name := ' ';
	qml_form_name := 'ng_layercomponent_form.qml';
	qml_symb_name := ' ';
	qml_3d_name := ' ';
	trig_f_suffix := 'ng_layercomponent';
	qi_l_name := quote_ident(l_name);
	ql_l_name := quote_literal(l_name);
	qi_av_name := quote_ident(av_name);
	ql_av_name := quote_literal(av_name);
	qi_gv_name := quote_ident(gv_name);
	ql_gv_name := quote_literal(gv_name);

	IF (num_features > 0) OR (force_layer_creation IS TRUE) THEN
		
		----------------------------------------------------
		-- VIEW FOR ATTRIBUTES
		----------------------------------------------------
		sql_layer := concat(sql_layer,qgis_pkg.generate_sql_view_header(qi_usr_schema,qi_l_name),'
			SELECT ',
			sql_co_atts,'
			nglc.areafraction,
			nglc.areafraction_uom,
			nglc.layer_layercomponent_id,
			nglc.material_id,
			nglc.thickness,
			nglc.thickness_uom
			FROM ',qi_cdb_schema,'.ng_layercomponent AS nglc
			INNER JOIN ',qi_cdb_schema,'.cityobject AS co
			ON (nglc.id = co.id ',sql_where,');
			COMMENT ON VIEW ',qi_usr_schema,'.',qi_l_name,' IS ''View of LayerComponent in schema ',qi_cdb_schema,''';
			ALTER TABLE ',qi_usr_schema,'.',qi_l_name,' OWNER TO ',qi_usr_name,';
		');
		
		-- add triggers to make view updatable
		sql_trig := concat(sql_trig,qgis_pkg.generate_sql_triggers(usr_schema, l_name, trig_f_suffix));
		
		-- Add entry to update table layer_metadata
		sql_ins := concat(sql_ins,'
			(',ql_cdb_schema,',',ql_ade_prefix,',',ql_l_type,',',ql_feature_type,',',quote_literal(root_class),',',quote_literal(curr_class),',',quote_literal(lod),',
			 ',ql_l_name,',',ql_av_name,',',ql_gv_name,',',num_features,',clock_timestamp(),',quote_literal(qml_form_name),',',quote_literal(qml_symb_name),',
			 ',quote_literal(qml_3d_name),',',quote_nullable(enum_cols_array),',',quote_nullable(codelist_cols_array),'),');
	ELSE
		sql_layer := concat(sql_layer,qgis_pkg.generate_sql_matview_else(qi_usr_schema,ql_cdb_schema,ql_l_type,ql_l_name,qi_gv_name));
	END IF;
	
	IF sql_ins IS NOT NULL THEN
		sql_ins := concat(sql_upd, substr(sql_ins,1, length(sql_ins)-1), ';');
	END IF;
	
	sql_statement := concat(sql_layer,sql_trig,sql_ins);
	RETURN sql_statement;
END;
$$ LANGUAGE plpgsql;	
COMMENT ON FUNCTION qgis_pkg.generate_sql_layers_ng_layercomponent(varchar,varchar,integer,integer,numeric,geometry,boolean,varchar) IS 'Generate SQL script to create layers for class LayerComponent';
REVOKE EXECUTE ON FUNCTION qgis_pkg.generate_sql_layers_ng_layercomponent(varchar,varchar,integer,integer,numeric,geometry,boolean,varchar) FROM public; 	

-------------------------------------------------------------------
-- CREATE FUNCTION qgis_pkg.generate_sql_ng_solidmaterial
-------------------------------------------------------------------

DROP FUNCTION IF EXISTS qgis_pkg.generate_sql_layers_ng_solidmaterial(varchar,varchar,integer,integer,numeric,geometry,boolean,varchar);
CREATE OR REPLACE FUNCTION qgis_pkg.generate_sql_layers_ng_solidmaterial(usr_name varchar,cdb_schema varchar,perform_snapping integer,digits integer,
							  	         area_poly_min numeric,mview_bbox geometry,force_layer_creation boolean,ade_prefix varchar)
RETURNS text AS $$
DECLARE

	feature_type CONSTANT varchar := ' ';
	l_type varchar := 'DetailViewNoGeom';
	qgis_user_group_name CONSTANT varchar := (SELECT qgis_pkg.create_qgis_pkg_usrgroup_name());
	usr_schema varchar := (SELECT qgis_pkg.create_qgis_usr_schema_name(usr_name));
	usr_names_array varchar[] := (SELECT array_agg(s.usr_name) FROM qgis_pkg.list_qgis_pkg_usrgroup_members() AS s);
	usr_schemas_array varchar[] := (SELECT array_agg(s.usr_schema) FROM qgis_pkg.list_usr_schemas() AS s);
	cdb_schemas_array varchar[] := (SELECT array_agg(s.cdb_schema) FROM qgis_pkg.list_cdb_schemas() AS s);
	srid integer;
	num_features bigint;
	root_class varchar;
	curr_class varchar;
	lod varchar;
	ql_feature_type varchar := quote_literal(feature_type);
	ql_l_type varchar := quote_literal(l_type);
	qi_cdb_schema varchar; ql_cdb_schema varchar;
	qi_usr_schema varchar; ql_usr_schema varchar;
	qi_usr_name varchar; ql_usr_name varchar; ql_ade_prefix varchar;
	l_name varchar; ql_l_name varchar; qi_l_name varchar;
	av_name varchar; ql_av_name varchar; qi_av_name varchar;
	gv_name varchar; qi_gv_name varchar; ql_gv_name varchar;
	qml_form_name 	varchar := NULL;
	qml_symb_name 	varchar := NULL;
	qml_3d_name 	varchar := NULL;
	trig_f_suffix   varchar := NULL;
	r RECORD; s RECORD; t RECORD; u RECORD;
	sql_feat_count	text := NULL;
	sql_where		text := NULL;
	sql_upd			text := NULL;
	sql_ins			text := NULL;
	sql_trig		text := NULL;
	sql_layer	 	text := NULL;
	sql_statement	text := NULL;
	enum_cols_array varchar[][] := NULL;
	codelist_cols_array varchar[][] := NULL;
	sql_co_atts varchar := 'co.id::bigint,co.gmlid,co.gmlid_codespace,co.name,
				co.name_codespace,co.description,co.creation_date,
				co.termination_date,co.last_modification_date,
				co.updating_person,co.reason_for_update,co.lineage,';

BEGIN
	-- check if user name exists
	IF NOT usr_name = ANY(usr_names_array) THEN
	RAISE EXCEPTION 'usr_name is invalid. It must be an existing database user and member of role (group) "%"',qgis_user_group_name;
	END IF;
	
	-- check if usr_schema exists
	IF NOT usr_schema = ANY(usr_schemas_array) THEN
	RAISE EXCEPTION 'usr_schema % does not exist. Please create it beforehand',usr_schema;
	END IF;
	
	-- check if cdb_schema exists
	IF NOT cdb_schema = ANY(cdb_schemas_array)  THEN
	RAISE EXCEPTION 'cdb_schema % is invalid. It must correspond to an existing city db schema',cdb_schema;
	END IF;

	-- add quote identifier (qi_) and quote literal (ql_) for later user in dynamic queries.
	qi_cdb_schema := quote_ident(cdb_schema);
	ql_cdb_schema := quote_literal(cdb_schema);
	qi_usr_name   := quote_ident(usr_name);
	ql_usr_name   := quote_literal(usr_name);
	qi_usr_schema := quote_ident(usr_schema);
	ql_usr_schema := quote_literal(usr_schema);
	ql_ade_prefix := quote_literal(ade_prefix);

	-- Prepare fixed part of SQL statements
	-- Remove previous entries from the layer_metadata Table, and insert it again.
	sql_upd := concat('
	DELETE FROM ',qi_usr_schema,'.layer_metadata AS l WHERE l.cdb_schema = ',ql_cdb_schema,' AND l.class = ',quote_literal('SolidMaterial'),';
	INSERT INTO ',qi_usr_schema,'.layer_metadata 
	(cdb_schema, ade_prefix, layer_type, feature_type, root_class, class, lod, layer_name, av_name, gv_name, n_features, creation_date, qml_form, qml_symb, qml_3d, enum_cols, codelist_cols)
	VALUES');

	RAISE NOTICE 'For module "%" and user "%": creating layers in usr_schema "%" for cdb_schema "%"', feature_type, qi_usr_name, qi_usr_schema, qi_cdb_schema;
	
	--Initialise variables 
	sql_layer := NULL; sql_ins := NULL; sql_trig := NULL;
	root_class := ' ';
	
	-----------------------------------------------------------
	-- CREATE LAYER SOLIDMATERIAL
	-----------------------------------------------------------
	sql_feat_count := concat('
		SELECT COUNT(ngsm.id) FROM ',qi_cdb_schema,'.ng_solidmaterial AS ngsm
		INNER JOIN ',qi_cdb_schema,'.cityobject AS co ON ngsm.id = co.id
	');
	EXECUTE sql_feat_count INTO num_features;
	RAISE NOTICE 'Found % features for SolidMaterial',num_features;

	curr_class := 'SolidMaterial';
	lod := 'lodx';
	l_name := concat(cdb_schema,'_ng_solidmaterial_lodx');
	av_name := concat('_a_',cdb_schema,'_ng_solidmaterial');
	gv_name := ' ';
	qml_form_name := 'ng_solidmaterial_form.qml';
	qml_symb_name := ' ';
	qml_3d_name := ' ';
	trig_f_suffix := 'ng_solidmaterial';
	qi_l_name := quote_ident(l_name);
	ql_l_name := quote_literal(l_name);
	qi_av_name := quote_ident(av_name);
	ql_av_name := quote_literal(av_name);
	qi_gv_name := quote_ident(gv_name);
	ql_gv_name := quote_literal(gv_name);

	IF (num_features > 0) OR (force_layer_creation IS TRUE) THEN
		
		----------------------------------------------------
		-- VIEW FOR ATTRIBUTES
		----------------------------------------------------
		sql_layer := concat(sql_layer,qgis_pkg.generate_sql_view_header(qi_usr_schema,qi_l_name),'
			SELECT ',
			sql_co_atts,'
			ngsm.conductivity,
			ngsm.conductivity_uom,
			ngsm.density,
			ngsm.density_uom,
			ngsm.permeance,
			ngsm.permeance_uom,
			ngsm.specificheat,
			ngsm.specificheat_uom
			FROM ',qi_cdb_schema,'.ng_solidmaterial AS ngsm
			INNER JOIN ',qi_cdb_schema,'.cityobject AS co
			ON (ngsm.id = co.id ',sql_where,');
			COMMENT ON VIEW ',qi_usr_schema,'.',qi_l_name,' IS ''View of SolidMaterial in schema ',qi_cdb_schema,''';
			ALTER TABLE ',qi_usr_schema,'.',qi_l_name,' OWNER TO ',qi_usr_name,';
		');
	
		-- add triggers to make view updatable
		sql_trig := concat(sql_trig,qgis_pkg.generate_sql_triggers(usr_schema, l_name, trig_f_suffix));
		
		-- Add entry to update table layer_metadata
		sql_ins := concat(sql_ins,'
			(',ql_cdb_schema,',',ql_ade_prefix,',',ql_l_type,',',ql_feature_type,',',quote_literal(root_class),',',quote_literal(curr_class),',',quote_literal(lod),',
			 ',ql_l_name,',',ql_av_name,',',ql_gv_name,',',num_features,',clock_timestamp(),',quote_literal(qml_form_name),',',quote_literal(qml_symb_name),',
			 ',quote_literal(qml_3d_name),',',quote_nullable(enum_cols_array),',',quote_nullable(codelist_cols_array),'),');

	ELSE
		sql_layer := concat(sql_layer,qgis_pkg.generate_sql_matview_else(qi_usr_schema,ql_cdb_schema,ql_l_type,ql_l_name,qi_gv_name));
	END IF;
	
	IF sql_ins IS NOT NULL THEN
		sql_ins := concat(sql_upd, substr(sql_ins,1, length(sql_ins)-1), ';');
	END IF;
	
	sql_statement := concat(sql_layer,sql_trig,sql_ins);
	RETURN sql_statement;
END;
$$ LANGUAGE plpgsql;	
COMMENT ON FUNCTION qgis_pkg.generate_sql_layers_ng_solidmaterial(varchar,varchar,integer,integer,numeric,geometry,boolean,varchar) IS 'Generate SQL script to create layers for class SolidMaterial';
REVOKE EXECUTE ON FUNCTION qgis_pkg.generate_sql_layers_ng_solidmaterial(varchar,varchar,integer,integer,numeric,geometry,boolean,varchar) FROM public; 	

-------------------------------------------------------------------
-- CREATE FUNCTION qgis_pkg.generate_sql_ng_gas
-------------------------------------------------------------------

DROP FUNCTION IF EXISTS qgis_pkg.generate_sql_layers_ng_gas(varchar,varchar,integer,integer,numeric,geometry,boolean,varchar);
CREATE OR REPLACE FUNCTION qgis_pkg.generate_sql_layers_ng_gas(usr_name varchar,cdb_schema varchar,perform_snapping integer,digits integer,
							       area_poly_min numeric,mview_bbox geometry,force_layer_creation boolean,ade_prefix varchar)
RETURNS text AS $$
DECLARE

	feature_type CONSTANT varchar := ' ';
	l_type varchar := 'DetailViewNoGeom';
	qgis_user_group_name CONSTANT varchar := (SELECT qgis_pkg.create_qgis_pkg_usrgroup_name());
	usr_schema varchar := (SELECT qgis_pkg.create_qgis_usr_schema_name(usr_name));
	usr_names_array varchar[] := (SELECT array_agg(s.usr_name) FROM qgis_pkg.list_qgis_pkg_usrgroup_members() AS s);
	usr_schemas_array varchar[] := (SELECT array_agg(s.usr_schema) FROM qgis_pkg.list_usr_schemas() AS s);
	cdb_schemas_array varchar[] := (SELECT array_agg(s.cdb_schema) FROM qgis_pkg.list_cdb_schemas() AS s);
	srid integer;
	num_features bigint;
	root_class varchar;
	curr_class varchar;
	lod varchar;
	ql_feature_type varchar := quote_literal(feature_type);
	ql_l_type varchar := quote_literal(l_type);
	qi_cdb_schema varchar; ql_cdb_schema varchar;
	qi_usr_schema varchar; ql_usr_schema varchar;
	qi_usr_name varchar; ql_usr_name varchar; ql_ade_prefix varchar;
	l_name varchar; ql_l_name varchar; qi_l_name varchar;
	av_name varchar; ql_av_name varchar; qi_av_name varchar;
	gv_name varchar; qi_gv_name varchar; ql_gv_name varchar;
	qml_form_name 	varchar := NULL;
	qml_symb_name 	varchar := NULL;
	qml_3d_name 	varchar := NULL;
	trig_f_suffix   varchar := NULL;
	r RECORD; s RECORD; t RECORD; u RECORD;
	sql_feat_count	text := NULL;
	sql_where		text := NULL;
	sql_upd			text := NULL;
	sql_ins			text := NULL;
	sql_trig		text := NULL;
	sql_layer	 	text := NULL;
	sql_statement	text := NULL;
	enum_cols_array varchar[][] := NULL;
	codelist_cols_array varchar[][] := NULL;
	sql_co_atts varchar := 'co.id::bigint,co.gmlid,co.gmlid_codespace,co.name,
				co.name_codespace,co.description,co.creation_date,
				co.termination_date,co.last_modification_date,
				co.updating_person,co.reason_for_update,co.lineage,';

BEGIN
	-- check if user name exists
	IF NOT usr_name = ANY(usr_names_array) THEN
	RAISE EXCEPTION 'usr_name is invalid. It must be an existing database user and member of role (group) "%"',qgis_user_group_name;
	END IF;
	
	-- check if usr_schema exists
	IF NOT usr_schema = ANY(usr_schemas_array) THEN
	RAISE EXCEPTION 'usr_schema % does not exist. Please create it beforehand',usr_schema;
	END IF;
	
	-- check if cdb_schema exists
	IF NOT cdb_schema = ANY(cdb_schemas_array)  THEN
	RAISE EXCEPTION 'cdb_schema % is invalid. It must correspond to an existing city db schema',cdb_schema;
	END IF;

	-- add quote identifier (qi_) and quote literal (ql_) for later user in dynamic queries.
	qi_cdb_schema := quote_ident(cdb_schema);
	ql_cdb_schema := quote_literal(cdb_schema);
	qi_usr_name   := quote_ident(usr_name);
	ql_usr_name   := quote_literal(usr_name);
	qi_usr_schema := quote_ident(usr_schema);
	ql_usr_schema := quote_literal(usr_schema);
	ql_ade_prefix := quote_literal(ade_prefix);
	
	-- Prepare fixed part of SQL statements
	-- Remove previous entries from the layer_metadata Table, and insert it again.
	sql_upd := concat('
	DELETE FROM ',qi_usr_schema,'.layer_metadata AS l WHERE l.cdb_schema = ',ql_cdb_schema,' AND l.class = ',quote_literal('Gas'),';
	INSERT INTO ',qi_usr_schema,'.layer_metadata 
	(cdb_schema, ade_prefix, layer_type, feature_type, root_class, class, lod, layer_name, av_name, gv_name, n_features, creation_date, qml_form, qml_symb, qml_3d, enum_cols, codelist_cols)
	VALUES');

	RAISE NOTICE 'For module "%" and user "%": creating layers in usr_schema "%" for cdb_schema "%"', feature_type, qi_usr_name, qi_usr_schema, qi_cdb_schema;
	
	--Initialise variables 
	sql_layer := NULL; sql_ins := NULL; sql_trig := NULL;
	root_class := ' ';
	
	-----------------------------------------------------------
	-- CREATE LAYER GAS
	-----------------------------------------------------------
	sql_feat_count := concat('
		SELECT COUNT(ngg.id) FROM ',qi_cdb_schema,'.ng_gas AS ngg
		INNER JOIN ',qi_cdb_schema,'.cityobject AS co ON ngg.id = co.id
	');
	EXECUTE sql_feat_count INTO num_features;
	RAISE NOTICE 'Found % features for Gas',num_features;

	curr_class := 'Gas';
	lod := 'lodx';
	l_name := concat(cdb_schema,'_ng_gas_lodx');
	av_name := concat('_a_',cdb_schema,'_ng_gas');
	gv_name := ' ';
	qml_form_name := 'ng_gas_form.qml';
	qml_symb_name := ' ';
	qml_3d_name := ' ';
	trig_f_suffix := 'ng_gas';
	qi_l_name := quote_ident(l_name);
	ql_l_name := quote_literal(l_name);
	qi_av_name := quote_ident(av_name);
	ql_av_name := quote_literal(av_name);
	qi_gv_name := quote_ident(gv_name);
	ql_gv_name := quote_literal(gv_name);

	IF (num_features > 0) OR (force_layer_creation IS TRUE) THEN
		
		----------------------------------------------------
		-- VIEW FOR ATTRIBUTES
		----------------------------------------------------
		sql_layer := concat(sql_layer,qgis_pkg.generate_sql_view_header(qi_usr_schema,qi_l_name),'
			SELECT ',
			sql_co_atts,'
			ngg.isventilated,
			ngg.rvalue,
			ngg.rvalue_uom
			FROM ',qi_cdb_schema,'.ng_gas AS ngg
			INNER JOIN ',qi_cdb_schema,'.cityobject AS co
			ON (ngg.id = co.id ',sql_where,');
			COMMENT ON VIEW ',qi_usr_schema,'.',qi_l_name,' IS ''View of Gas in schema ',qi_cdb_schema,''';
			ALTER TABLE ',qi_usr_schema,'.',qi_l_name,' OWNER TO ',qi_usr_name,';
		');
		-- add triggers to make view updatable
		sql_trig := concat(sql_trig,qgis_pkg.generate_sql_triggers(usr_schema, l_name, trig_f_suffix));
		
		-- Add entry to update table layer_metadata
		sql_ins := concat(sql_ins,'
			(',ql_cdb_schema,',',ql_ade_prefix,',',ql_l_type,',',ql_feature_type,',',quote_literal(root_class),',',quote_literal(curr_class),',',quote_literal(lod),',
			 ',ql_l_name,',',ql_av_name,',',ql_gv_name,',',num_features,',clock_timestamp(),',quote_literal(qml_form_name),',',quote_literal(qml_symb_name),',
			 ',quote_literal(qml_3d_name),',',quote_nullable(enum_cols_array),',',quote_nullable(codelist_cols_array),'),');
		
	ELSE
		sql_layer := concat(sql_layer,qgis_pkg.generate_sql_matview_else(qi_usr_schema,ql_cdb_schema,ql_l_type,ql_l_name,qi_gv_name));
	END IF;
	
	IF sql_ins IS NOT NULL THEN
		sql_ins := concat(sql_upd, substr(sql_ins,1, length(sql_ins)-1), ';');
	END IF;
	
	sql_statement := concat(sql_layer,sql_trig,sql_ins);
	RETURN sql_statement;
END;
$$ LANGUAGE plpgsql;	
COMMENT ON FUNCTION qgis_pkg.generate_sql_layers_ng_gas(varchar,varchar,integer,integer,numeric,geometry,boolean,varchar) IS 'Generate SQL script to create layers for class Gas';
REVOKE EXECUTE ON FUNCTION qgis_pkg.generate_sql_layers_ng_gas(varchar,varchar,integer,integer,numeric,geometry,boolean,varchar) FROM public; 	

-------------------------------------------------------------------
-- CREATE FUNCTION qgis_pkg.generate_sql_ng_reflectance
-------------------------------------------------------------------

DROP FUNCTION IF EXISTS qgis_pkg.generate_sql_layers_ng_reflectance(varchar,varchar,integer,integer,numeric,geometry,boolean,varchar);
CREATE OR REPLACE FUNCTION qgis_pkg.generate_sql_layers_ng_reflectance(usr_name varchar,cdb_schema varchar,perform_snapping integer,digits integer,
						                       area_poly_min numeric,mview_bbox geometry,force_layer_creation boolean,ade_prefix varchar)
RETURNS text AS $$
DECLARE

	feature_type CONSTANT varchar := ' ';
	l_type varchar := 'DetailViewNoGeom';
	qgis_user_group_name CONSTANT varchar := (SELECT qgis_pkg.create_qgis_pkg_usrgroup_name());
	usr_schema varchar := (SELECT qgis_pkg.create_qgis_usr_schema_name(usr_name));
	usr_names_array varchar[] := (SELECT array_agg(s.usr_name) FROM qgis_pkg.list_qgis_pkg_usrgroup_members() AS s);
	usr_schemas_array varchar[] := (SELECT array_agg(s.usr_schema) FROM qgis_pkg.list_usr_schemas() AS s);
	cdb_schemas_array varchar[] := (SELECT array_agg(s.cdb_schema) FROM qgis_pkg.list_cdb_schemas() AS s);
	srid integer;
	num_features bigint;
	root_class varchar;
	curr_class varchar;
	lod varchar;
	ql_feature_type varchar := quote_literal(feature_type);
	ql_l_type varchar := quote_literal(l_type);
	qi_cdb_schema varchar; ql_cdb_schema varchar;
	qi_usr_schema varchar; ql_usr_schema varchar;
	qi_usr_name varchar; ql_usr_name varchar; ql_ade_prefix varchar;
	l_name varchar; ql_l_name varchar; qi_l_name varchar;
	av_name varchar; ql_av_name varchar; qi_av_name varchar;
	gv_name varchar; qi_gv_name varchar; ql_gv_name varchar;
	qml_form_name 	varchar := NULL;
	qml_symb_name 	varchar := NULL;
	qml_3d_name 	varchar := NULL;
	trig_f_suffix   varchar := NULL;
	r RECORD; s RECORD; t RECORD; u RECORD;
	sql_feat_count	text := NULL;
	sql_where		text := NULL;
	sql_upd			text := NULL;
	sql_ins			text := NULL;
	sql_trig		text := NULL;
	sql_layer	 	text := NULL;
	sql_statement	text := NULL;
	enum_cols_array varchar[][] := ARRAY[['ng_reflectance','surface'],['ng_reflectance','wavelengthrange']];
	codelist_cols_array varchar[][] := NULL;

BEGIN
	-- check if user name exists
	IF NOT usr_name = ANY(usr_names_array) THEN
	RAISE EXCEPTION 'usr_name is invalid. It must be an existing database user and member of role (group) "%"',qgis_user_group_name;
	END IF;
	
	-- check if usr_schema exists
	IF NOT usr_schema = ANY(usr_schemas_array) THEN
	RAISE EXCEPTION 'usr_schema % does not exist. Please create it beforehand',usr_schema;
	END IF;
	
	-- check if cdb_schema exists
	IF NOT cdb_schema = ANY(cdb_schemas_array)  THEN
	RAISE EXCEPTION 'cdb_schema % is invalid. It must correspond to an existing city db schema',cdb_schema;
	END IF;

	-- add quote identifier (qi_) and quote literal (ql_) for later user in dynamic queries.
	qi_cdb_schema := quote_ident(cdb_schema);
	ql_cdb_schema := quote_literal(cdb_schema);
	qi_usr_name   := quote_ident(usr_name);
	ql_usr_name   := quote_literal(usr_name);
	qi_usr_schema := quote_ident(usr_schema);
	ql_usr_schema := quote_literal(usr_schema);
	ql_ade_prefix := quote_literal(ade_prefix);
	
	-- Prepare fixed part of SQL statements
	-- Remove previous entries from the layer_metadata Table, and insert it again.
	sql_upd := concat('
	DELETE FROM ',qi_usr_schema,'.layer_metadata AS l WHERE l.cdb_schema = ',ql_cdb_schema,' AND l.class = ',quote_literal('Reflectance'),';
	INSERT INTO ',qi_usr_schema,'.layer_metadata 
	(cdb_schema, ade_prefix, layer_type, feature_type, root_class, class, lod, layer_name, av_name, gv_name, n_features, creation_date, qml_form, qml_symb, qml_3d, enum_cols, codelist_cols)
	VALUES');

	RAISE NOTICE 'For module "%" and user "%": creating layers in usr_schema "%" for cdb_schema "%"', feature_type, qi_usr_name, qi_usr_schema, qi_cdb_schema;
	
	--Initialise variables 
	sql_layer := NULL; sql_ins := NULL; sql_trig := NULL;
	root_class := feature_type;
	
	-----------------------------------------------------------
	-- CREATE LAYER REFLECTANCE
	-----------------------------------------------------------
	sql_feat_count := concat('
		SELECT COUNT(ngr.id) FROM ',qi_cdb_schema,'.ng_reflectance AS ngr
	');
	EXECUTE sql_feat_count INTO num_features;
	RAISE NOTICE 'Found % features for Reflectance',num_features;

	curr_class := 'Reflectance';
	lod := 'lodx';
	l_name := concat(cdb_schema,'_ng_reflectance_lodx');
	av_name := concat('_a_',cdb_schema,'_ng_reflectance');
	gv_name := ' ';
	qml_form_name := 'ng_reflectance_form.qml';
	qml_symb_name := ' ';
	qml_3d_name := ' ';
	trig_f_suffix := 'ng_reflectance';
	qi_l_name := quote_ident(l_name);
	ql_l_name := quote_literal(l_name);
	qi_av_name := quote_ident(av_name);
	ql_av_name := quote_literal(av_name);
	qi_gv_name := quote_ident(gv_name);
	ql_gv_name := quote_literal(gv_name);

	IF (num_features > 0) OR (force_layer_creation IS TRUE) THEN
		
		----------------------------------------------------
		-- VIEW FOR ATTRIBUTES
		----------------------------------------------------
		sql_layer := concat(sql_layer,qgis_pkg.generate_sql_view_header(qi_usr_schema,qi_l_name),'
			SELECT
		        ngr.id,	
			ngr.fraction,
			ngr.fraction_uom,
			ngr.opticalproper_reflectance_id,
			ngr.surface,
			ngr.wavelengthrange
			FROM ',qi_cdb_schema,'.ng_reflectance AS ngr;
			COMMENT ON VIEW ',qi_usr_schema,'.',qi_l_name,' IS ''View of Reflectance in schema ',qi_cdb_schema,''';
			ALTER TABLE ',qi_usr_schema,'.',qi_l_name,' OWNER TO ',qi_usr_name,';
		');
		-- add triggers to make view updatable
		sql_trig := concat(sql_trig,qgis_pkg.generate_sql_triggers(usr_schema, l_name, trig_f_suffix));
		sql_ins := concat(sql_ins,'
			(',ql_cdb_schema,',',ql_ade_prefix,',',ql_l_type,',',ql_feature_type,',',quote_literal(root_class),',',quote_literal(curr_class),',',quote_literal(lod),',
			 ',ql_l_name,',',ql_av_name,',',ql_gv_name,',',num_features,',clock_timestamp(),',quote_literal(qml_form_name),',',quote_literal(qml_symb_name),',
			 ',quote_literal(qml_3d_name),',',quote_nullable(enum_cols_array),',',quote_nullable(codelist_cols_array),'),');
		
	ELSE
		sql_layer := concat(sql_layer,qgis_pkg.generate_sql_matview_else(qi_usr_schema,ql_cdb_schema,ql_l_type,ql_l_name,qi_gv_name));
	END IF;
	
	IF sql_ins IS NOT NULL THEN
		sql_ins := concat(sql_upd, substr(sql_ins,1, length(sql_ins)-1), ';');
	END IF;
	
	sql_statement := concat(sql_layer,sql_trig,sql_ins);
	RETURN sql_statement;
END;
$$ LANGUAGE plpgsql;	
COMMENT ON FUNCTION qgis_pkg.generate_sql_layers_ng_reflectance(varchar,varchar,integer,integer,numeric,geometry,boolean,varchar) IS 'Generate SQL script to create layers for class Reflectance';
REVOKE EXECUTE ON FUNCTION qgis_pkg.generate_sql_layers_ng_reflectance(varchar,varchar,integer,integer,numeric,geometry,boolean,varchar) FROM public; 	

-------------------------------------------------------------------
-- CREATE FUNCTION qgis_pkg.generate_sql_ng_opticalproperties
-------------------------------------------------------------------

DROP FUNCTION IF EXISTS qgis_pkg.generate_sql_layers_ng_opticalproperties(varchar,varchar,integer,integer,numeric,geometry,boolean,varchar);
CREATE OR REPLACE FUNCTION qgis_pkg.generate_sql_layers_ng_opticalproperties(usr_name varchar,cdb_schema varchar,perform_snapping integer,digits integer,
							              area_poly_min numeric,mview_bbox geometry,force_layer_creation boolean,ade_prefix varchar)
RETURNS text AS $$
DECLARE

	feature_type CONSTANT varchar := ' ';
	l_type varchar := 'DetailViewNoGeom';
	qgis_user_group_name CONSTANT varchar := (SELECT qgis_pkg.create_qgis_pkg_usrgroup_name());
	usr_schema varchar := (SELECT qgis_pkg.create_qgis_usr_schema_name(usr_name));
	usr_names_array varchar[] := (SELECT array_agg(s.usr_name) FROM qgis_pkg.list_qgis_pkg_usrgroup_members() AS s);
	usr_schemas_array varchar[] := (SELECT array_agg(s.usr_schema) FROM qgis_pkg.list_usr_schemas() AS s);
	cdb_schemas_array varchar[] := (SELECT array_agg(s.cdb_schema) FROM qgis_pkg.list_cdb_schemas() AS s);
	srid integer;
	num_features bigint;
	root_class varchar;
	curr_class varchar;
	lod varchar;
	ql_feature_type varchar := quote_literal(feature_type);
	ql_l_type varchar := quote_literal(l_type);
	qi_cdb_schema varchar; ql_cdb_schema varchar;
	qi_usr_schema varchar; ql_usr_schema varchar;
	qi_usr_name varchar; ql_usr_name varchar; ql_ade_prefix varchar;
	l_name varchar; ql_l_name varchar; qi_l_name varchar;
	av_name varchar; ql_av_name varchar; qi_av_name varchar;
	gv_name varchar; qi_gv_name varchar; ql_gv_name varchar;
	qml_form_name 	varchar := NULL;
	qml_symb_name 	varchar := NULL;
	qml_3d_name 	varchar := NULL;
	trig_f_suffix   varchar := NULL;
	r RECORD; s RECORD; t RECORD; u RECORD;
	sql_feat_count	text := NULL;
	sql_where		text := NULL;
	sql_upd			text := NULL;
	sql_ins			text := NULL;
	sql_trig		text := NULL;
	sql_layer	 	text := NULL;
	sql_statement	text := NULL;
	enum_cols_array varchar[][] := NULL;
	codelist_cols_array varchar[][] := NULL;

BEGIN
	-- check if user name exists
	IF NOT usr_name = ANY(usr_names_array) THEN
	RAISE EXCEPTION 'usr_name is invalid. It must be an existing database user and member of role (group) "%"',qgis_user_group_name;
	END IF;
	
	-- check if usr_schema exists
	IF NOT usr_schema = ANY(usr_schemas_array) THEN
	RAISE EXCEPTION 'usr_schema % does not exist. Please create it beforehand',usr_schema;
	END IF;
	
	-- check if cdb_schema exists
	IF NOT cdb_schema = ANY(cdb_schemas_array)  THEN
	RAISE EXCEPTION 'cdb_schema % is invalid. It must correspond to an existing city db schema',cdb_schema;
	END IF;

	-- add quote identifier (qi_) and quote literal (ql_) for later user in dynamic queries.
	qi_cdb_schema := quote_ident(cdb_schema);
	ql_cdb_schema := quote_literal(cdb_schema);
	qi_usr_name   := quote_ident(usr_name);
	ql_usr_name   := quote_literal(usr_name);
	qi_usr_schema := quote_ident(usr_schema);
	ql_usr_schema := quote_literal(usr_schema);
	ql_ade_prefix := quote_literal(ade_prefix);

	-- Prepare fixed part of SQL statements
	-- Remove previous entries from the layer_metadata Table, and insert it again.
	sql_upd := concat('
	DELETE FROM ',qi_usr_schema,'.layer_metadata AS l WHERE l.cdb_schema = ',ql_cdb_schema,' AND l.class = ',quote_literal('OpticalProperties'),';
	INSERT INTO ',qi_usr_schema,'.layer_metadata 
	(cdb_schema, ade_prefix, layer_type, feature_type, root_class, class, lod, layer_name, av_name, gv_name, n_features, creation_date, qml_form, qml_symb, qml_3d, enum_cols, codelist_cols)
	VALUES');

	RAISE NOTICE 'For module "%" and user "%": creating layers in usr_schema "%" for cdb_schema "%"', feature_type, qi_usr_name, qi_usr_schema, qi_cdb_schema;
	
	--Initialise variables 
	sql_layer := NULL; sql_ins := NULL; sql_trig := NULL;
	root_class := feature_type;
	
	-----------------------------------------------------------
	-- CREATE LAYER OPTICALPROPERTIES
	-----------------------------------------------------------
	sql_feat_count := concat('
		SELECT COUNT(ngop.id) FROM ',qi_cdb_schema,'.ng_opticalproperties AS ngop
	');
	EXECUTE sql_feat_count INTO num_features;
	RAISE NOTICE 'Found % features for OpticalProperties',num_features;

	curr_class := 'OpticalProperties';
	lod := 'lodx';
	l_name := concat(cdb_schema,'_ng_opticalproperties_lodx');
	av_name := concat('_a_',cdb_schema,'_ng_opticalproperties');
	gv_name := concat(' ');
	qml_form_name := 'ng_opticalproperties_form.qml';
	qml_symb_name := ' ';
	qml_3d_name := ' ';
	trig_f_suffix := 'ng_opticalproperties';
	qi_l_name := quote_ident(l_name);
	ql_l_name := quote_literal(l_name);
	qi_av_name := quote_ident(av_name);
	ql_av_name := quote_literal(av_name);
	qi_gv_name := quote_ident(gv_name);
	ql_gv_name := quote_literal(gv_name);

	IF (num_features > 0) OR (force_layer_creation IS TRUE) THEN
		
		----------------------------------------------------
		-- VIEW FOR ATTRIBUTES
		----------------------------------------------------
		sql_layer := concat(sql_layer,qgis_pkg.generate_sql_view_header(qi_usr_schema,qi_l_name),'
			SELECT 
			ngop.id,
			ngop.glazingratio,
			ngop.glazingratio_uom
			FROM ',qi_cdb_schema,'.ng_opticalproperties AS ngop;
			COMMENT ON VIEW ',qi_usr_schema,'.',qi_l_name,' IS ''View of OpticalProperties in schema ',qi_cdb_schema,''';
			ALTER TABLE ',qi_usr_schema,'.',qi_l_name,' OWNER TO ',qi_usr_name,';
		');
		-- add triggers to make view updatable	
		sql_trig := concat(sql_trig,qgis_pkg.generate_sql_triggers(usr_schema, l_name, trig_f_suffix));
		sql_ins := concat(sql_ins,'
			(',ql_cdb_schema,',',ql_ade_prefix,',',ql_l_type,',',ql_feature_type,',',quote_literal(root_class),',',quote_literal(curr_class),',',quote_literal(lod),',
			 ',ql_l_name,',',ql_av_name,',',ql_gv_name,',',num_features,',clock_timestamp(),',quote_literal(qml_form_name),',',quote_literal(qml_symb_name),',
			 ',quote_literal(qml_3d_name),',',quote_nullable(enum_cols_array),',',quote_nullable(codelist_cols_array),'),');
	ELSE
		sql_layer := concat(sql_layer,qgis_pkg.generate_sql_matview_else(qi_usr_schema,ql_cdb_schema,ql_l_type,ql_l_name,qi_gv_name));
	END IF;
	
	IF sql_ins IS NOT NULL THEN
		sql_ins := concat(sql_upd, substr(sql_ins,1, length(sql_ins)-1), ';');
	END IF;
	
	sql_statement := concat(sql_layer,sql_trig,sql_ins);
	RETURN sql_statement;
END;
$$ LANGUAGE plpgsql;	
COMMENT ON FUNCTION qgis_pkg.generate_sql_layers_ng_opticalproperties(varchar,varchar,integer,integer,numeric,geometry,boolean,varchar) IS 'Generate SQL script to create layers for class OpticalProperties';
REVOKE EXECUTE ON FUNCTION qgis_pkg.generate_sql_layers_ng_opticalproperties(varchar,varchar,integer,integer,numeric,geometry,boolean,varchar) FROM public; 	

-------------------------------------------------------------------
-- CREATE FUNCTION qgis_pkg.generate_sql_ng_transmittance
-------------------------------------------------------------------

DROP FUNCTION IF EXISTS qgis_pkg.generate_sql_layers_ng_transmittance(varchar,varchar,integer,integer,numeric,geometry,boolean,varchar);
CREATE OR REPLACE FUNCTION qgis_pkg.generate_sql_layers_ng_transmittance(usr_name varchar,cdb_schema varchar,perform_snapping integer,digits integer,
							          area_poly_min numeric,mview_bbox geometry,force_layer_creation boolean,ade_prefix varchar)
RETURNS text AS $$
DECLARE

	feature_type CONSTANT varchar := ' ';
	l_type varchar := 'DetailViewNoGeom';
	qgis_user_group_name CONSTANT varchar := (SELECT qgis_pkg.create_qgis_pkg_usrgroup_name());
	usr_schema varchar := (SELECT qgis_pkg.create_qgis_usr_schema_name(usr_name));
	usr_names_array varchar[] := (SELECT array_agg(s.usr_name) FROM qgis_pkg.list_qgis_pkg_usrgroup_members() AS s);
	usr_schemas_array varchar[] := (SELECT array_agg(s.usr_schema) FROM qgis_pkg.list_usr_schemas() AS s);
	cdb_schemas_array varchar[] := (SELECT array_agg(s.cdb_schema) FROM qgis_pkg.list_cdb_schemas() AS s);
	srid integer;
	num_features bigint;
	root_class varchar;
	curr_class varchar;
	lod varchar;
	ql_feature_type varchar := quote_literal(feature_type);
	ql_l_type varchar := quote_literal(l_type);
	qi_cdb_schema varchar; ql_cdb_schema varchar;
	qi_usr_schema varchar; ql_usr_schema varchar;
	qi_usr_name varchar; ql_usr_name varchar; ql_ade_prefix varchar;
	l_name varchar; ql_l_name varchar; qi_l_name varchar;
	av_name varchar; ql_av_name varchar; qi_av_name varchar;
	gv_name varchar; qi_gv_name varchar; ql_gv_name varchar;
	qml_form_name 	varchar := NULL;
	qml_symb_name 	varchar := NULL;
	qml_3d_name 	varchar := NULL;
	trig_f_suffix   varchar := NULL;
	r RECORD; s RECORD; t RECORD; u RECORD;
	sql_feat_count	text := NULL;
	sql_where		text := NULL;
	sql_upd			text := NULL;
	sql_ins			text := NULL;
	sql_trig		text := NULL;
	sql_layer	 	text := NULL;
	sql_statement	text := NULL;
	enum_cols_array varchar[][] := ARRAY[['ng_transmittance','wavelengthrange']];
	codelist_cols_array varchar[][] := NULL;

BEGIN
	-- check if user name exists
	IF NOT usr_name = ANY(usr_names_array) THEN
	RAISE EXCEPTION 'usr_name is invalid. It must be an existing database user and member of role (group) "%"',qgis_user_group_name;
	END IF;
	
	-- check if usr_schema exists
	IF NOT usr_schema = ANY(usr_schemas_array) THEN
	RAISE EXCEPTION 'usr_schema % does not exist. Please create it beforehand',usr_schema;
	END IF;
	
	-- check if cdb_schema exists
	IF NOT cdb_schema = ANY(cdb_schemas_array)  THEN
	RAISE EXCEPTION 'cdb_schema % is invalid. It must correspond to an existing city db schema',cdb_schema;
	END IF;

	-- add quote identifier (qi_) and quote literal (ql_) for later user in dynamic queries.
	qi_cdb_schema := quote_ident(cdb_schema);
	ql_cdb_schema := quote_literal(cdb_schema);
	qi_usr_name   := quote_ident(usr_name);
	ql_usr_name   := quote_literal(usr_name);
	qi_usr_schema := quote_ident(usr_schema);
	ql_usr_schema := quote_literal(usr_schema);
	ql_ade_prefix := quote_literal(ade_prefix);

	-- Prepare fixed part of SQL statements
	-- Remove previous entries from the layer_metadata Table, and insert it again.
	sql_upd := concat('
	DELETE FROM ',qi_usr_schema,'.layer_metadata AS l WHERE l.cdb_schema = ',ql_cdb_schema,' AND l.class = ',quote_literal('Transmittance'),';
	INSERT INTO ',qi_usr_schema,'.layer_metadata 
	(cdb_schema, ade_prefix, layer_type, feature_type, root_class, class, lod, layer_name, av_name, gv_name, n_features, creation_date, qml_form, qml_symb, qml_3d, enum_cols, codelist_cols)
	VALUES');

	RAISE NOTICE 'For module "%" and user "%": creating layers in usr_schema "%" for cdb_schema "%"', feature_type, qi_usr_name, qi_usr_schema, qi_cdb_schema;
	
	--Initialise variables 
	sql_layer := NULL; sql_ins := NULL; sql_trig := NULL;
	root_class := feature_type;
	
	-----------------------------------------------------------
	-- CREATE LAYER TRANSMITTANCE
	-----------------------------------------------------------
	sql_feat_count := concat('
		SELECT COUNT(ngt.id) FROM ',qi_cdb_schema,'.ng_transmittance AS ngt
	');
	EXECUTE sql_feat_count INTO num_features;
	RAISE NOTICE 'Found % features for Transmittance',num_features;

	curr_class := 'Transmittance';
	lod := 'lodx';
	l_name := concat(cdb_schema,'_ng_transmittance_lodx');
	av_name := concat('_a_',cdb_schema,'_ng_transmittance');
	gv_name := concat(' ');
	qml_form_name := 'ng_transmittance_form.qml';
	qml_symb_name := ' ';
	qml_3d_name := ' ';
	trig_f_suffix := 'ng_transmittance';
	qi_l_name := quote_ident(l_name);
	ql_l_name := quote_literal(l_name);
	qi_av_name := quote_ident(av_name);
	ql_av_name := quote_literal(av_name);
	qi_gv_name := quote_ident(gv_name);
	ql_gv_name := quote_literal(gv_name);

	IF (num_features > 0) OR (force_layer_creation IS TRUE) THEN
		
		----------------------------------------------------
		-- VIEW FOR ATTRIBUTES
		----------------------------------------------------
		sql_layer := concat(sql_layer,qgis_pkg.generate_sql_view_header(qi_usr_schema,qi_l_name),'
			SELECT
		        ngt.id,	
			ngt.fraction,
			ngt.fraction_uom,
			ngt.opticalprope_transmittanc_id,
			ngt.wavelengthrange
			FROM ',qi_cdb_schema,'.ng_transmittance AS ngt;
			COMMENT ON VIEW ',qi_usr_schema,'.',qi_l_name,' IS ''View of Transmittance in schema ',qi_cdb_schema,''';
			ALTER TABLE ',qi_usr_schema,'.',qi_l_name,' OWNER TO ',qi_usr_name,';
		');
		-- add triggers to make view updatable
		sql_trig := concat(sql_trig,qgis_pkg.generate_sql_triggers(usr_schema, l_name, trig_f_suffix));
		sql_ins := concat(sql_ins,'
			(',ql_cdb_schema,',',ql_ade_prefix,',',ql_l_type,',',ql_feature_type,',',quote_literal(root_class),',',quote_literal(curr_class),',',quote_literal(lod),',
			 ',ql_l_name,',',ql_av_name,',',ql_gv_name,',',num_features,',clock_timestamp(),',quote_literal(qml_form_name),',',quote_literal(qml_symb_name),',
			 ',quote_literal(qml_3d_name),',',quote_nullable(enum_cols_array),',',quote_nullable(codelist_cols_array),'),');
	ELSE
		sql_layer := concat(sql_layer,qgis_pkg.generate_sql_matview_else(qi_usr_schema,ql_cdb_schema,ql_l_type,ql_l_name,qi_gv_name));
	END IF;
	
	IF sql_ins IS NOT NULL THEN
		sql_ins := concat(sql_upd, substr(sql_ins,1, length(sql_ins)-1), ';');
	END IF;
	
	sql_statement := concat(sql_layer,sql_trig,sql_ins);
	RETURN sql_statement;
END;
$$ LANGUAGE plpgsql;	
COMMENT ON FUNCTION qgis_pkg.generate_sql_layers_ng_transmittance(varchar,varchar,integer,integer,numeric,geometry,boolean,varchar) IS 'Generate SQL script to create layers for class Transmittance';
REVOKE EXECUTE ON FUNCTION qgis_pkg.generate_sql_layers_ng_transmittance(varchar,varchar,integer,integer,numeric,geometry,boolean,varchar) FROM public; 	

-------------------------------------------------------------------
-- CREATE FUNCTION qgis_pkg.generate_sql_ng_flooarea
-------------------------------------------------------------------

DROP FUNCTION IF EXISTS qgis_pkg.generate_sql_layers_ng_floorarea(varchar,varchar,integer,integer,numeric,geometry,boolean,varchar);
CREATE OR REPLACE FUNCTION qgis_pkg.generate_sql_layers_ng_floorarea(usr_name varchar,cdb_schema varchar,perform_snapping integer,digits integer,
							             area_poly_min numeric,mview_bbox geometry,force_layer_creation boolean,ade_prefix varchar)
RETURNS text AS $$
DECLARE

	feature_type CONSTANT varchar := ' ';
	l_type varchar := 'DetailViewNoGeom';
	qgis_user_group_name CONSTANT varchar := (SELECT qgis_pkg.create_qgis_pkg_usrgroup_name());
	usr_schema varchar := (SELECT qgis_pkg.create_qgis_usr_schema_name(usr_name));
	usr_names_array varchar[] := (SELECT array_agg(s.usr_name) FROM qgis_pkg.list_qgis_pkg_usrgroup_members() AS s);
	usr_schemas_array varchar[] := (SELECT array_agg(s.usr_schema) FROM qgis_pkg.list_usr_schemas() AS s);
	cdb_schemas_array varchar[] := (SELECT array_agg(s.cdb_schema) FROM qgis_pkg.list_cdb_schemas() AS s);
	srid integer;
	num_features bigint;
	root_class varchar;
	curr_class varchar;
	lod varchar;
	ql_feature_type varchar := quote_literal(feature_type);
	ql_l_type varchar := quote_literal(l_type);
	qi_cdb_schema varchar; ql_cdb_schema varchar;
	qi_usr_schema varchar; ql_usr_schema varchar;
	qi_usr_name varchar; ql_usr_name varchar; ql_ade_prefix varchar;
	l_name varchar; ql_l_name varchar; qi_l_name varchar;
	av_name varchar; ql_av_name varchar; qi_av_name varchar;
	gv_name varchar; qi_gv_name varchar; ql_gv_name varchar;
	qml_form_name 	varchar := NULL;
	qml_symb_name 	varchar := NULL;
	qml_3d_name 	varchar := NULL;
	trig_f_suffix   varchar := NULL;
	r RECORD; s RECORD; t RECORD; u RECORD;
	sql_feat_count	text := NULL;
	sql_where		text := NULL;
	sql_upd			text := NULL;
	sql_ins			text := NULL;
	sql_trig		text := NULL;
	sql_layer	 	text := NULL;
	sql_statement	text := NULL;
	enum_cols_array varchar[][] := ARRAY[['ng_floorarea','type']];
	codelist_cols_array varchar[][] := NULL;

BEGIN
	-- check if user name exists
	IF NOT usr_name = ANY(usr_names_array) THEN
	RAISE EXCEPTION 'usr_name is invalid. It must be an existing database user and member of role (group) "%"',qgis_user_group_name;
	END IF;
	
	-- check if usr_schema exists
	IF NOT usr_schema = ANY(usr_schemas_array) THEN
	RAISE EXCEPTION 'usr_schema % does not exist. Please create it beforehand',usr_schema;
	END IF;
	
	-- check if cdb_schema exists
	IF NOT cdb_schema = ANY(cdb_schemas_array)  THEN
	RAISE EXCEPTION 'cdb_schema % is invalid. It must correspond to an existing city db schema',cdb_schema;
	END IF;

	-- add quote identifier (qi_) and quote literal (ql_) for later user in dynamic queries.
	qi_cdb_schema := quote_ident(cdb_schema);
	ql_cdb_schema := quote_literal(cdb_schema);
	qi_usr_name   := quote_ident(usr_name);
	ql_usr_name   := quote_literal(usr_name);
	qi_usr_schema := quote_ident(usr_schema);
	ql_usr_schema := quote_literal(usr_schema);
	ql_ade_prefix := quote_literal(ade_prefix);
	
	-- Prepare fixed part of SQL statements
	-- Remove previous entries from the layer_metadata Table, and insert it again.
	sql_upd := concat('
	DELETE FROM ',qi_usr_schema,'.layer_metadata AS l WHERE l.cdb_schema = ',ql_cdb_schema,' AND l.class = ',quote_literal('FloorArea'),';
	INSERT INTO ',qi_usr_schema,'.layer_metadata 
	(cdb_schema, ade_prefix, layer_type, feature_type, root_class, class, lod, layer_name, av_name, gv_name, n_features, creation_date, qml_form, qml_symb, qml_3d, enum_cols, codelist_cols)
	VALUES');

	RAISE NOTICE 'For module "%" and user "%": creating layers in usr_schema "%" for cdb_schema "%"', feature_type, qi_usr_name, qi_usr_schema, qi_cdb_schema;
	
	--Initialise variables 
	sql_layer := NULL; sql_ins := NULL; sql_trig := NULL;
	root_class := feature_type;
	
	-----------------------------------------------------------
	-- CREATE LAYER FLOORAREA
	-----------------------------------------------------------
	sql_feat_count := concat('
		SELECT COUNT(ngfa.id) FROM ',qi_cdb_schema,'.ng_floorarea AS ngfa
	');
	EXECUTE sql_feat_count INTO num_features;
	RAISE NOTICE 'Found % features for FloorArea',num_features;

	curr_class := 'FloorArea';
	lod := 'lodx';
	l_name := concat(cdb_schema,'_ng_floorarea_lodx');
	av_name := concat('_a_',cdb_schema,'_ng_floorarea');
	gv_name := concat(' ');
	qml_form_name := 'ng_floorarea_form.qml';
	qml_symb_name := ' ';
	qml_3d_name := ' ';
	trig_f_suffix := 'ng_floorarea';
	qi_l_name := quote_ident(l_name);
	ql_l_name := quote_literal(l_name);
	qi_av_name := quote_ident(av_name);
	ql_av_name := quote_literal(av_name);
	qi_gv_name := quote_ident(gv_name);
	ql_gv_name := quote_literal(gv_name);

	IF (num_features > 0) OR (force_layer_creation IS TRUE) THEN
		
		----------------------------------------------------
		-- VIEW FOR ATTRIBUTES
		----------------------------------------------------
		sql_layer := concat(sql_layer,qgis_pkg.generate_sql_view_header(qi_usr_schema,qi_l_name),'
			SELECT
		        ngfa.id,	
			ngfa.building_floorarea_id,
			ngfa.thermalzone_floorarea_id,
			ngfa.type,
			ngfa.usagezone_floorarea_id,
			ngfa.value,
			ngfa.value_uom
			FROM ',qi_cdb_schema,'.ng_floorarea AS ngfa;
			COMMENT ON VIEW ',qi_usr_schema,'.',qi_l_name,' IS ''View of FloorArea in schema ',qi_cdb_schema,''';
			ALTER TABLE ',qi_usr_schema,'.',qi_l_name,' OWNER TO ',qi_usr_name,';
		');
		-- add triggers to make view updatable
		sql_trig := concat(sql_trig,qgis_pkg.generate_sql_triggers(usr_schema, l_name, trig_f_suffix));
		sql_ins := concat(sql_ins,'
			(',ql_cdb_schema,',',ql_ade_prefix,',',ql_l_type,',',ql_feature_type,',',quote_literal(root_class),',',quote_literal(curr_class),',',quote_literal(lod),',
			 ',ql_l_name,',',ql_av_name,',',ql_gv_name,',',num_features,',clock_timestamp(),',quote_literal(qml_form_name),',',quote_literal(qml_symb_name),',
			 ',quote_literal(qml_3d_name),',',quote_nullable(enum_cols_array),',',quote_nullable(codelist_cols_array),'),');
	ELSE
		sql_layer := concat(sql_layer,qgis_pkg.generate_sql_matview_else(qi_usr_schema,ql_cdb_schema,ql_l_type,ql_l_name,qi_gv_name));
	END IF;
	
	IF sql_ins IS NOT NULL THEN
		sql_ins := concat(sql_upd, substr(sql_ins,1, length(sql_ins)-1), ';');
	END IF;
	
	sql_statement := concat(sql_layer,sql_trig,sql_ins);
	RETURN sql_statement;
END;
$$ LANGUAGE plpgsql;	
COMMENT ON FUNCTION qgis_pkg.generate_sql_layers_ng_floorarea(varchar,varchar,integer,integer,numeric,geometry,boolean,varchar) IS 'Generate SQL script to create layers for class FloorArea';
REVOKE EXECUTE ON FUNCTION qgis_pkg.generate_sql_layers_ng_floorarea(varchar,varchar,integer,integer,numeric,geometry,boolean,varchar) FROM public; 	

-------------------------------------------------------------------
-- CREATE FUNCTION qgis_pkg.generate_sql_ng_volumetype
-------------------------------------------------------------------

DROP FUNCTION IF EXISTS qgis_pkg.generate_sql_layers_ng_volumetype(varchar,varchar,integer,integer,numeric,geometry,boolean,varchar);
CREATE OR REPLACE FUNCTION qgis_pkg.generate_sql_layers_ng_volumetype(usr_name varchar,cdb_schema varchar,perform_snapping integer,digits integer,
							              area_poly_min numeric,mview_bbox geometry,force_layer_creation boolean,ade_prefix varchar)
RETURNS text AS $$
DECLARE

	feature_type CONSTANT varchar := ' ';
	l_type varchar := 'DetailViewNoGeom';
	qgis_user_group_name CONSTANT varchar := (SELECT qgis_pkg.create_qgis_pkg_usrgroup_name());
	usr_schema varchar := (SELECT qgis_pkg.create_qgis_usr_schema_name(usr_name));
	usr_names_array varchar[] := (SELECT array_agg(s.usr_name) FROM qgis_pkg.list_qgis_pkg_usrgroup_members() AS s);
	usr_schemas_array varchar[] := (SELECT array_agg(s.usr_schema) FROM qgis_pkg.list_usr_schemas() AS s);
	cdb_schemas_array varchar[] := (SELECT array_agg(s.cdb_schema) FROM qgis_pkg.list_cdb_schemas() AS s);
	srid integer;
	num_features bigint;
	root_class varchar;
	curr_class varchar;
	lod varchar;
	ql_feature_type varchar := quote_literal(feature_type);
	ql_l_type varchar := quote_literal(l_type);
	qi_cdb_schema varchar; ql_cdb_schema varchar;
	qi_usr_schema varchar; ql_usr_schema varchar;
	qi_usr_name varchar; ql_usr_name varchar; ql_ade_prefix varchar;
	l_name varchar; ql_l_name varchar; qi_l_name varchar;
	av_name varchar; ql_av_name varchar; qi_av_name varchar;
	gv_name varchar; qi_gv_name varchar; ql_gv_name varchar;
	qml_form_name 	varchar := NULL;
	qml_symb_name 	varchar := NULL;
	qml_3d_name 	varchar := NULL;
	trig_f_suffix   varchar := NULL;
	r RECORD; s RECORD; t RECORD; u RECORD;
	sql_feat_count	text := NULL;
	sql_where		text := NULL;
	sql_upd			text := NULL;
	sql_ins			text := NULL;
	sql_trig		text := NULL;
	sql_layer	 	text := NULL;
	sql_statement	text := NULL;
	enum_cols_array varchar[][] := ARRAY[['ng_volumetype','type']];
	codelist_cols_array varchar[][] := NULL;

BEGIN
	-- check if user name exists
	IF NOT usr_name = ANY(usr_names_array) THEN
	RAISE EXCEPTION 'usr_name is invalid. It must be an existing database user and member of role (group) "%"',qgis_user_group_name;
	END IF;
	
	-- check if usr_schema exists
	IF NOT usr_schema = ANY(usr_schemas_array) THEN
	RAISE EXCEPTION 'usr_schema % does not exist. Please create it beforehand',usr_schema;
	END IF;
	
	-- check if cdb_schema exists
	IF NOT cdb_schema = ANY(cdb_schemas_array)  THEN
	RAISE EXCEPTION 'cdb_schema % is invalid. It must correspond to an existing city db schema',cdb_schema;
	END IF;

	-- add quote identifier (qi_) and quote literal (ql_) for later user in dynamic queries.
	qi_cdb_schema := quote_ident(cdb_schema);
	ql_cdb_schema := quote_literal(cdb_schema);
	qi_usr_name   := quote_ident(usr_name);
	ql_usr_name   := quote_literal(usr_name);
	qi_usr_schema := quote_ident(usr_schema);
	ql_usr_schema := quote_literal(usr_schema);
	ql_ade_prefix := quote_literal(ade_prefix);

	-- Prepare fixed part of SQL statements
	-- Remove previous entries from the layer_metadata Table, and insert it again.
	sql_upd := concat('
	DELETE FROM ',qi_usr_schema,'.layer_metadata AS l WHERE l.cdb_schema = ',ql_cdb_schema,' AND l.class = ',quote_literal('VolumeType'),';
	INSERT INTO ',qi_usr_schema,'.layer_metadata 
	(cdb_schema, ade_prefix, layer_type, feature_type, root_class, class, lod, layer_name, av_name, gv_name, n_features, creation_date, qml_form, qml_symb, qml_3d, enum_cols, codelist_cols)
	VALUES');

	RAISE NOTICE 'For module "%" and user "%": creating layers in usr_schema "%" for cdb_schema "%"', feature_type, qi_usr_name, qi_usr_schema, qi_cdb_schema;
	
	--Initialise variables 
	sql_layer := NULL; sql_ins := NULL; sql_trig := NULL;
	root_class := feature_type;
	
	-----------------------------------------------------------
	-- CREATE LAYER VOLUMETYPE
	-----------------------------------------------------------
	sql_feat_count := concat('
		SELECT COUNT(ngvt.id) FROM ',qi_cdb_schema,'.ng_volumetype AS ngvt
	');
	EXECUTE sql_feat_count INTO num_features;
	RAISE NOTICE 'Found % features for VolumeType',num_features;

	curr_class := 'VolumeType';
	lod := 'lodx';
	l_name := concat(cdb_schema,'_ng_volumetype_lodx');
	av_name := concat('_a_',cdb_schema,'_ng_volumetype');
	gv_name := concat(' ');
	qml_form_name := 'ng_volumetype_form.qml';
	qml_symb_name := ' ';
	qml_3d_name := ' ';
	trig_f_suffix := 'ng_volumetype';
	qi_l_name := quote_ident(l_name);
	ql_l_name := quote_literal(l_name);
	qi_av_name := quote_ident(av_name);
	ql_av_name := quote_literal(av_name);
	qi_gv_name := quote_ident(gv_name);
	ql_gv_name := quote_literal(gv_name);

	IF (num_features > 0) OR (force_layer_creation IS TRUE) THEN
		
		----------------------------------------------------
		-- VIEW FOR ATTRIBUTES
		----------------------------------------------------
		sql_layer := concat(sql_layer,qgis_pkg.generate_sql_view_header(qi_usr_schema,qi_l_name),'
			SELECT
		        ngvt.id,	
			ngvt.building_volume_id,
			ngvt.thermalzone_volume_id,
			ngvt.type,
			ngvt.value,
			ngvt.value_uom
			FROM ',qi_cdb_schema,'.ng_volumetype AS ngvt;
			COMMENT ON VIEW ',qi_usr_schema,'.',qi_l_name,' IS ''View of VolumeType in schema ',qi_cdb_schema,''';
			ALTER TABLE ',qi_usr_schema,'.',qi_l_name,' OWNER TO ',qi_usr_name,';
		');
		-- add triggers to make view updatable
		sql_trig := concat(sql_trig,qgis_pkg.generate_sql_triggers(usr_schema, l_name, trig_f_suffix));
		sql_ins := concat(sql_ins,'
			(',ql_cdb_schema,',',ql_ade_prefix,',',ql_l_type,',',ql_feature_type,',',quote_literal(root_class),',',quote_literal(curr_class),',',quote_literal(lod),',
			 ',ql_l_name,',',ql_av_name,',',ql_gv_name,',',num_features,',clock_timestamp(),',quote_literal(qml_form_name),',',quote_literal(qml_symb_name),',
			 ',quote_literal(qml_3d_name),',',quote_nullable(enum_cols_array),',',quote_nullable(codelist_cols_array),'),');
	ELSE
		sql_layer := concat(sql_layer,qgis_pkg.generate_sql_matview_else(qi_usr_schema,ql_cdb_schema,ql_l_type,ql_l_name,qi_gv_name));
	END IF;
	
	IF sql_ins IS NOT NULL THEN
		sql_ins := concat(sql_upd, substr(sql_ins,1, length(sql_ins)-1), ';');
	END IF;
	
	sql_statement := concat(sql_layer,sql_trig,sql_ins);
	RETURN sql_statement;
END;
$$ LANGUAGE plpgsql;	
COMMENT ON FUNCTION qgis_pkg.generate_sql_layers_ng_volumetype(varchar,varchar,integer,integer,numeric,geometry,boolean,varchar) IS 'Generate SQL script to create layers for class VolumeType';
REVOKE EXECUTE ON FUNCTION qgis_pkg.generate_sql_layers_ng_volumetype(varchar,varchar,integer,integer,numeric,geometry,boolean,varchar) FROM public; 	

-------------------------------------------------------------------
-- CREATE FUNCTION qgis_pkg.generate_sql_ng_heightaboveground
-------------------------------------------------------------------

DROP FUNCTION IF EXISTS qgis_pkg.generate_sql_layers_ng_heightaboveground(varchar,varchar,integer,integer,numeric,geometry,boolean,varchar);
CREATE OR REPLACE FUNCTION qgis_pkg.generate_sql_layers_ng_heightaboveground(usr_name varchar,cdb_schema varchar,perform_snapping integer,digits integer,
							             	     area_poly_min numeric,mview_bbox geometry,force_layer_creation boolean,ade_prefix varchar)
RETURNS text AS $$
DECLARE

	feature_type CONSTANT varchar := ' ';
	l_type varchar := 'DetailViewNoGeom';
	qgis_user_group_name CONSTANT varchar := (SELECT qgis_pkg.create_qgis_pkg_usrgroup_name());
	usr_schema varchar := (SELECT qgis_pkg.create_qgis_usr_schema_name(usr_name));
	usr_names_array varchar[] := (SELECT array_agg(s.usr_name) FROM qgis_pkg.list_qgis_pkg_usrgroup_members() AS s);
	usr_schemas_array varchar[] := (SELECT array_agg(s.usr_schema) FROM qgis_pkg.list_usr_schemas() AS s);
	cdb_schemas_array varchar[] := (SELECT array_agg(s.cdb_schema) FROM qgis_pkg.list_cdb_schemas() AS s);
	srid integer;
	num_features bigint;
	root_class varchar;
	curr_class varchar;
	lod varchar;
	ql_feature_type varchar := quote_literal(feature_type);
	ql_l_type varchar := quote_literal(l_type);
	qi_cdb_schema varchar; ql_cdb_schema varchar;
	qi_usr_schema varchar; ql_usr_schema varchar;
	qi_usr_name varchar; ql_usr_name varchar; ql_ade_prefix varchar;
	l_name varchar; ql_l_name varchar; qi_l_name varchar;
	av_name varchar; ql_av_name varchar; qi_av_name varchar;
	gv_name varchar; qi_gv_name varchar; ql_gv_name varchar;
	qml_form_name 	varchar := NULL;
	qml_symb_name 	varchar := NULL;
	qml_3d_name 	varchar := NULL;
	trig_f_suffix   varchar := NULL;
	r RECORD; s RECORD; t RECORD; u RECORD;
	sql_feat_count	text := NULL;
	sql_where		text := NULL;
	sql_upd			text := NULL;
	sql_ins			text := NULL;
	sql_trig		text := NULL;
	sql_layer	 	text := NULL;
	sql_statement	text := NULL;
	enum_cols_array varchar[][] := ARRAY[['ng_heightaboveground','heightreference']];
	codelist_cols_array varchar[][] := NULL;

BEGIN
	-- check if user name exists
	IF NOT usr_name = ANY(usr_names_array) THEN
	RAISE EXCEPTION 'usr_name is invalid. It must be an existing database user and member of role (group) "%"',qgis_user_group_name;
	END IF;
	
	-- check if usr_schema exists
	IF NOT usr_schema = ANY(usr_schemas_array) THEN
	RAISE EXCEPTION 'usr_schema % does not exist. Please create it beforehand',usr_schema;
	END IF;
	
	-- check if cdb_schema exists
	IF NOT cdb_schema = ANY(cdb_schemas_array)  THEN
	RAISE EXCEPTION 'cdb_schema % is invalid. It must correspond to an existing city db schema',cdb_schema;
	END IF;

	-- add quote identifier (qi_) and quote literal (ql_) for later user in dynamic queries.
	qi_cdb_schema := quote_ident(cdb_schema);
	ql_cdb_schema := quote_literal(cdb_schema);
	qi_usr_name   := quote_ident(usr_name);
	ql_usr_name   := quote_literal(usr_name);
	qi_usr_schema := quote_ident(usr_schema);
	ql_usr_schema := quote_literal(usr_schema);
	ql_ade_prefix := quote_literal(ade_prefix);

	-- Prepare fixed part of SQL statements
	-- Remove previous entries from the layer_metadata Table, and insert it again.
	sql_upd := concat('
	DELETE FROM ',qi_usr_schema,'.layer_metadata AS l WHERE l.cdb_schema = ',ql_cdb_schema,' AND l.class = ',quote_literal('HeightAboveGround'),';
	INSERT INTO ',qi_usr_schema,'.layer_metadata 
	(cdb_schema, ade_prefix, layer_type, feature_type, root_class, class, lod, layer_name, av_name, gv_name, n_features, creation_date, qml_form, qml_symb, qml_3d, enum_cols, codelist_cols)
	VALUES');

	RAISE NOTICE 'For module "%" and user "%": creating layers in usr_schema "%" for cdb_schema "%"', feature_type, qi_usr_name, qi_usr_schema, qi_cdb_schema;
	
	--Initialise variables 
	sql_layer := NULL; sql_ins := NULL; sql_trig := NULL;
	root_class := feature_type;
	
	-----------------------------------------------------------
	-- CREATE LAYER HEIGHTABOVEGROUND
	-----------------------------------------------------------
	sql_feat_count := concat('
		SELECT COUNT(nghag.id) FROM ',qi_cdb_schema,'.ng_heightaboveground AS nghag
	');
	EXECUTE sql_feat_count INTO num_features;
	RAISE NOTICE 'Found % features for HeightAboveGround',num_features;

	curr_class := 'HeightAboveGround';
	lod := 'lodx';
	l_name := concat(cdb_schema,'_ng_heightaboveground_lodx');
	av_name := concat('_a_',cdb_schema,'_ng_heightaboveground');
	gv_name := concat(' ');
	qml_form_name := 'ng_heightaboveground_form.qml';
	qml_symb_name := ' ';
	qml_3d_name := ' ';
	trig_f_suffix := 'ng_heightaboveground';
	qi_l_name := quote_ident(l_name);
	ql_l_name := quote_literal(l_name);
	qi_av_name := quote_ident(av_name);
	ql_av_name := quote_literal(av_name);
	qi_gv_name := quote_ident(gv_name);
	ql_gv_name := quote_literal(gv_name);

	IF (num_features > 0) OR (force_layer_creation IS TRUE) THEN
		
		----------------------------------------------------
		-- VIEW FOR ATTRIBUTES
		----------------------------------------------------
		sql_layer := concat(sql_layer,qgis_pkg.generate_sql_view_header(qi_usr_schema,qi_l_name),'
			SELECT
		        nghag.id,	
			nghag.building_heightabovegroun_id,
			nghag.heightreference,
			nghag.value,
			nghag.value_uom
			FROM ',qi_cdb_schema,'.ng_heightaboveground AS nghag;
			COMMENT ON VIEW ',qi_usr_schema,'.',qi_l_name,' IS ''View of HeightAboveGround in schema ',qi_cdb_schema,''';
			ALTER TABLE ',qi_usr_schema,'.',qi_l_name,' OWNER TO ',qi_usr_name,';
		');
		-- add triggers to make view updatable
		sql_trig := concat(sql_trig,qgis_pkg.generate_sql_triggers(usr_schema, l_name, trig_f_suffix));
		sql_ins := concat(sql_ins,'
			(',ql_cdb_schema,',',ql_ade_prefix,',',ql_l_type,',',ql_feature_type,',',quote_literal(root_class),',',quote_literal(curr_class),',',quote_literal(lod),',
			 ',ql_l_name,',',ql_av_name,',',ql_gv_name,',',num_features,',clock_timestamp(),',quote_literal(qml_form_name),',',quote_literal(qml_symb_name),',
			 ',quote_literal(qml_3d_name),',',quote_nullable(enum_cols_array),',',quote_nullable(codelist_cols_array),'),');
	ELSE
		sql_layer := concat(sql_layer,qgis_pkg.generate_sql_matview_else(qi_usr_schema,ql_cdb_schema,ql_l_type,ql_l_name,qi_gv_name));
	END IF;
	
	IF sql_ins IS NOT NULL THEN
		sql_ins := concat(sql_upd, substr(sql_ins,1, length(sql_ins)-1), ';');
	END IF;
	
	sql_statement := concat(sql_layer,sql_trig,sql_ins);
	RETURN sql_statement;
END;
$$ LANGUAGE plpgsql;	
COMMENT ON FUNCTION qgis_pkg.generate_sql_layers_ng_heightaboveground(varchar,varchar,integer,integer,numeric,geometry,boolean,varchar) IS 'Generate SQL script to create layers for class HeightAboveGround';
REVOKE EXECUTE ON FUNCTION qgis_pkg.generate_sql_layers_ng_heightaboveground(varchar,varchar,integer,integer,numeric,geometry,boolean,varchar) FROM public; 	

-------------------------------------------------------------------
-- CREATE FUNCTION qgis_pkg.generate_sql_ng_heatexchangetype
-------------------------------------------------------------------

DROP FUNCTION IF EXISTS qgis_pkg.generate_sql_layers_ng_heatexchangetype(varchar,varchar,integer,integer,numeric,geometry,boolean,varchar);
CREATE OR REPLACE FUNCTION qgis_pkg.generate_sql_layers_ng_heatexchangetype(usr_name varchar,cdb_schema varchar,perform_snapping integer,digits integer,
							            	    area_poly_min numeric,mview_bbox geometry,force_layer_creation boolean,ade_prefix varchar)
RETURNS text AS $$
DECLARE

	feature_type CONSTANT varchar := ' ';
	l_type varchar := 'DetailViewNoGeom';
	qgis_user_group_name CONSTANT varchar := (SELECT qgis_pkg.create_qgis_pkg_usrgroup_name());
	usr_schema varchar := (SELECT qgis_pkg.create_qgis_usr_schema_name(usr_name));
	usr_names_array varchar[] := (SELECT array_agg(s.usr_name) FROM qgis_pkg.list_qgis_pkg_usrgroup_members() AS s);
	usr_schemas_array varchar[] := (SELECT array_agg(s.usr_schema) FROM qgis_pkg.list_usr_schemas() AS s);
	cdb_schemas_array varchar[] := (SELECT array_agg(s.cdb_schema) FROM qgis_pkg.list_cdb_schemas() AS s);
	srid integer;
	num_features bigint;
	root_class varchar;
	curr_class varchar;
	lod varchar;
	ql_feature_type varchar := quote_literal(feature_type);
	ql_l_type varchar := quote_literal(l_type);
	qi_cdb_schema varchar; ql_cdb_schema varchar;
	qi_usr_schema varchar; ql_usr_schema varchar;
	qi_usr_name varchar; ql_usr_name varchar; ql_ade_prefix varchar;
	l_name varchar; ql_l_name varchar; qi_l_name varchar;
	av_name varchar; ql_av_name varchar; qi_av_name varchar;
	gv_name varchar; qi_gv_name varchar; ql_gv_name varchar;
	qml_form_name 	varchar := NULL;
	qml_symb_name 	varchar := NULL;
	qml_3d_name 	varchar := NULL;
	trig_f_suffix   varchar := NULL;
	r RECORD; s RECORD; t RECORD; u RECORD;
	sql_feat_count	text := NULL;
	sql_where		text := NULL;
	sql_upd			text := NULL;
	sql_ins			text := NULL;
	sql_trig		text := NULL;
	sql_layer	 	text := NULL;
	sql_statement	text := NULL;
	enum_cols_array varchar[][] := NULL;
	codelist_cols_array varchar[][] := NULL;

BEGIN
	-- check if user name exists
	IF NOT usr_name = ANY(usr_names_array) THEN
	RAISE EXCEPTION 'usr_name is invalid. It must be an existing database user and member of role (group) "%"',qgis_user_group_name;
	END IF;
	
	-- check if usr_schema exists
	IF NOT usr_schema = ANY(usr_schemas_array) THEN
	RAISE EXCEPTION 'usr_schema % does not exist. Please create it beforehand',usr_schema;
	END IF;
	
	-- check if cdb_schema exists
	IF NOT cdb_schema = ANY(cdb_schemas_array)  THEN
	RAISE EXCEPTION 'cdb_schema % is invalid. It must correspond to an existing city db schema',cdb_schema;
	END IF;

	-- add quote identifier (qi_) and quote literal (ql_) for later user in dynamic queries.
	qi_cdb_schema := quote_ident(cdb_schema);
	ql_cdb_schema := quote_literal(cdb_schema);
	qi_usr_name   := quote_ident(usr_name);
	ql_usr_name   := quote_literal(usr_name);
	qi_usr_schema := quote_ident(usr_schema);
	ql_usr_schema := quote_literal(usr_schema);
	ql_ade_prefix := quote_literal(ade_prefix);

	-- Prepare fixed part of SQL statements
	-- Remove previous entries from the layer_metadata Table, and insert it again.
	sql_upd := concat('
	DELETE FROM ',qi_usr_schema,'.layer_metadata AS l WHERE l.cdb_schema = ',ql_cdb_schema,' AND l.class = ',quote_literal('HeatExchangeType'),';
	INSERT INTO ',qi_usr_schema,'.layer_metadata 
	(cdb_schema, ade_prefix, layer_type, feature_type, root_class, class, lod, layer_name, av_name, gv_name, n_features, creation_date, qml_form, qml_symb, qml_3d, enum_cols, codelist_cols)
	VALUES');


	RAISE NOTICE 'For module "%" and user "%": creating layers in usr_schema "%" for cdb_schema "%"', feature_type, qi_usr_name, qi_usr_schema, qi_cdb_schema;
	
	--Initialise variables 
	sql_layer := NULL; sql_ins := NULL; sql_trig := NULL;
	root_class := feature_type;
	
	-----------------------------------------------------------
	-- CREATE LAYER HEATEXCHANGETYPE
	-----------------------------------------------------------
	sql_feat_count := concat('
		SELECT COUNT(nghet.id) FROM ',qi_cdb_schema,'.ng_heatexchangetype AS nghet
	');
	EXECUTE sql_feat_count INTO num_features;
	RAISE NOTICE 'Found % features for HeatExchangeType',num_features;

	curr_class := 'HeatExchangeType';
	lod := 'lodx';
	l_name := concat(cdb_schema,'_ng_heatexchangetype_lodx');
	av_name := concat('_a_',cdb_schema,'_ng_heatexchangetype');
	gv_name := concat(' ');
	qml_form_name := 'ng_heatexchangetype_form.qml';
	qml_symb_name := ' ';
	qml_3d_name := ' ';
	trig_f_suffix := 'ng_heatexchangetype';
	qi_l_name := quote_ident(l_name);
	ql_l_name := quote_literal(l_name);
	qi_av_name := quote_ident(av_name);
	ql_av_name := quote_literal(av_name);
	qi_gv_name := quote_ident(gv_name);
	ql_gv_name := quote_literal(gv_name);

	IF (num_features > 0) OR (force_layer_creation IS TRUE) THEN
		
		----------------------------------------------------
		-- VIEW FOR ATTRIBUTES
		----------------------------------------------------
		sql_layer := concat(sql_layer,qgis_pkg.generate_sql_view_header(qi_usr_schema,qi_l_name),'
			SELECT
		        nghet.id,	
			nghet.convectivefraction,
			nghet.convectivefraction_uom,
			nghet.latentfraction,
			nghet.latentfraction_uom,
			nghet.radiantfraction,
			nghet.radiantfraction_uom,
			nghet.totalvalue,
			nghet.totalvalue_uom
			FROM ',qi_cdb_schema,'.ng_heatexchangetype AS nghet;
			COMMENT ON VIEW ',qi_usr_schema,'.',qi_l_name,' IS ''View of HeatExchangeType in schema ',qi_cdb_schema,''';
			ALTER TABLE ',qi_usr_schema,'.',qi_l_name,' OWNER TO ',qi_usr_name,';
		');
		-- add triggers to make view updatable
		sql_trig := concat(sql_trig,qgis_pkg.generate_sql_triggers(usr_schema, l_name, trig_f_suffix));
		sql_ins := concat(sql_ins,'
			(',ql_cdb_schema,',',ql_ade_prefix,',',ql_l_type,',',ql_feature_type,',',quote_literal(root_class),',',quote_literal(curr_class),',',quote_literal(lod),',
			 ',ql_l_name,',',ql_av_name,',',ql_gv_name,',',num_features,',clock_timestamp(),',quote_literal(qml_form_name),',',quote_literal(qml_symb_name),',
			 ',quote_literal(qml_3d_name),',',quote_nullable(enum_cols_array),',',quote_nullable(codelist_cols_array),'),');
	ELSE
		sql_layer := concat(sql_layer,qgis_pkg.generate_sql_matview_else(qi_usr_schema,ql_cdb_schema,ql_l_type,ql_l_name,qi_gv_name));
	END IF;
	
	IF sql_ins IS NOT NULL THEN
		sql_ins := concat(sql_upd, substr(sql_ins,1, length(sql_ins)-1), ';');
	END IF;
	
	sql_statement := concat(sql_layer,sql_trig,sql_ins);
	RETURN sql_statement;
END;
$$ LANGUAGE plpgsql;	
COMMENT ON FUNCTION qgis_pkg.generate_sql_layers_ng_heatexchangetype(varchar,varchar,integer,integer,numeric,geometry,boolean,varchar) IS 'Generate SQL script to create layers for class HeightAboveGround';
REVOKE EXECUTE ON FUNCTION qgis_pkg.generate_sql_layers_ng_heatexchangetype(varchar,varchar,integer,integer,numeric,geometry,boolean,varchar) FROM public; 	



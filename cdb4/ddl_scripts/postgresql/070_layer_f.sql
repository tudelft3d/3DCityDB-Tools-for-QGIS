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
-- This script installs some layer management functions in schema qgis_pkg. 
--
-- qgis_pkg.create_layers_xx(...) with xx = feature type (Building, etc.)
-- qgis_pkg.generate_sql_drop_layers_xx(...)
-- qgis_pkg.drop_layers_xx(...)
-- qgis_pkg.refresh_mviews_xx(...)
--
-- qgis_pkg.create_layers(...)
-- qgis_pkg.generate_sql_drop_layers(...)
-- qgis_pkg.drop_layers(...)
-- qgis_pkg.refresh_mviews(...)
--
-- ***********************************************************************

----------------------------------------------------------------
-- Create FUNCTION QGIS_PKG.CREATE_LAYERS_BRIDGE
----------------------------------------------------------------
DROP FUNCTION IF EXISTS    qgis_pkg.create_layers_bridge(varchar, varchar, integer, integer, numeric, numeric[], boolean) CASCADE;
CREATE OR REPLACE FUNCTION qgis_pkg.create_layers_bridge(
usr_name            varchar,
cdb_schema 			varchar,
perform_snapping 	integer   DEFAULT 0,
digits 				integer	  DEFAULT 3,
area_poly_min 		numeric   DEFAULT 0.0001,
bbox_corners_array	numeric[] DEFAULT NULL,
force_layer_creation boolean  DEFAULT FALSE
)
RETURNS void AS $$
DECLARE
sql_statement 	text := NULL;
mview_bbox 		geometry(Polygon) := NULL;

BEGIN
mview_bbox := qgis_pkg.generate_mview_bbox_poly(cdb_schema, bbox_corners_array);

sql_statement := qgis_pkg.generate_sql_layers_bridge(
	usr_name             := usr_name, 
	cdb_schema 			 := cdb_schema, 			
    perform_snapping 	 := perform_snapping, 	
	digits 				 := digits, 				
	area_poly_min 		 := area_poly_min, 		
	mview_bbox			 := mview_bbox,			
	force_layer_creation := force_layer_creation
);

IF sql_statement IS NOT NULL THEN
	EXECUTE sql_statement;
END IF;

EXCEPTION
	WHEN QUERY_CANCELED THEN
		RAISE EXCEPTION 'qgis_pkg.create_layers_bridge(): Error QUERY_CANCELED';
	WHEN OTHERS THEN
		RAISE EXCEPTION 'qgis_pkg.create_layers_bridge(): %', SQLERRM;
END;
$$ LANGUAGE plpgsql;
COMMENT ON FUNCTION qgis_pkg.create_layers_bridge(varchar, varchar, integer, integer, numeric, numeric[], boolean) IS 'Create "Bridge" layers (associated to a cdb_schema) in selected usr_schema';
REVOKE EXECUTE ON FUNCTION qgis_pkg.create_layers_bridge(varchar, varchar, integer, integer, numeric, numeric[], boolean) FROM public;

----------------------------------------------------------------
-- Create FUNCTION QGIS_PKG.GENERATE_SQL_DROP_LAYERS_BRIDGE
----------------------------------------------------------------
-- Generates SQL to drop layers (e.g. mviews, views and associated triggers)
DROP FUNCTION IF EXISTS    qgis_pkg.generate_sql_drop_layers_bridge(varchar, varchar) CASCADE;
CREATE OR REPLACE FUNCTION qgis_pkg.generate_sql_drop_layers_bridge(
usr_schema		varchar,
cdb_schema		varchar
)
RETURNS text
AS $$
DECLARE
feature_type			CONSTANT varchar := 'Bridge';
regexp_string			CONSTANT varchar := '^(bri).*';
mv_prefix				CONSTANT varchar := '_g_';
mv_cdb_schema_pos		CONSTANT integer := length(mv_prefix) + 1;
mv_feat_type_pos		CONSTANT integer := mv_cdb_schema_pos + length(cdb_schema) + 1;
usr_schemas_array		CONSTANT varchar[] := (SELECT array_agg(s.usr_schema) FROM qgis_pkg.list_usr_schemas() AS s);
cdb_schemas_array		CONSTANT varchar[] := (SELECT array_agg(d.cdb_schema) FROM qgis_pkg.list_cdb_schemas() AS d);
feat_type_prefix		varchar;
sql_statement			text := NULL;
r RECORD;

BEGIN
-- Check that the usr_schema exists
IF usr_schema IS NULL OR (NOT usr_schema = ANY(usr_schemas_array)) THEN
	RAISE EXCEPTION 'usr_schema value is invalid. It must correspond to an existing usr_schema';
END IF;

-- Check that the cdb_schema exists
IF cdb_schema IS NULL OR (NOT cdb_schema = ANY(cdb_schemas_array)) THEN
	RAISE EXCEPTION 'cdb_schema value is invalid. It must correspond to an existing cdb_schema';
END IF;

FOR r IN 
	SELECT mv.matviewname AS mv_name FROM pg_matviews AS mv
	WHERE
		mv.schemaname::varchar = usr_schema
		AND substring(mv.matviewname, mv_cdb_schema_pos) LIKE concat(cdb_schema, '%')		
		AND substring(mv.matviewname, mv_feat_type_pos) ~ regexp_string	
	ORDER BY mv.matviewname ASC
LOOP
	sql_statement := concat(sql_statement, format('
DROP MATERIALIZED VIEW %I.%I CASCADE;',
usr_schema, r.mv_name));

END LOOP;

-- Delete entries from table layer_metadata
IF sql_statement IS NOT NULL THEN
	sql_statement := concat(sql_statement, format('
DELETE FROM %I.layer_metadata AS l WHERE l.cdb_schema = %L AND l.feature_type = %L;',
	usr_schema, cdb_schema, feature_type));
END IF;

RETURN sql_statement;

EXCEPTION
	WHEN QUERY_CANCELED THEN
		RAISE EXCEPTION 'qgis_pkg.generate_sql_drop_layers_bridge(): Error QUERY_CANCELED';
  WHEN OTHERS THEN 
		RAISE NOTICE 'qgis_pkg.generate_sql_drop_layers_bridge(): %', SQLERRM;
END;
$$ LANGUAGE plpgsql;
COMMENT ON FUNCTION qgis_pkg.generate_sql_drop_layers_bridge(varchar, varchar) IS 'Genereate SQL to drop "Bridge" layers (associated to a cdb_schema) in selected usr_schema';
REVOKE EXECUTE ON FUNCTION qgis_pkg.generate_sql_drop_layers_bridge(varchar, varchar) FROM public;

----------------------------------------------------------------
-- Create FUNCTION QGIS_PKG.DROP_LAYERS_BRIDGE
----------------------------------------------------------------
-- Generates SQL to drops layers (e.g. mviews, views, and associated triggers)
DROP FUNCTION IF EXISTS    qgis_pkg.drop_layers_bridge(varchar, varchar) CASCADE;
CREATE OR REPLACE FUNCTION qgis_pkg.drop_layers_bridge(
usr_schema		varchar,
cdb_schema		varchar
)
RETURNS void
AS $$
DECLARE
sql_statement text := NULL;

BEGIN
sql_statement := qgis_pkg.generate_sql_drop_layers_bridge(usr_schema, cdb_schema); 

IF sql_statement IS NOT NULL THEN
	EXECUTE sql_statement;
END IF;

EXCEPTION
	WHEN QUERY_CANCELED THEN
		RAISE EXCEPTION 'qgis_pkg.drop_layers_bridge(): Error QUERY_CANCELED';
  WHEN OTHERS THEN 
		RAISE NOTICE 'qgis_pkg.drop_layers_bridge(): %', SQLERRM;
END;
$$ LANGUAGE plpgsql;
COMMENT ON FUNCTION qgis_pkg.drop_layers_bridge(varchar, varchar) IS 'Drop "Bridge" layers (associated to a cdb_schema) in selected usr_schema';
REVOKE EXECUTE ON FUNCTION qgis_pkg.drop_layers_bridge(varchar, varchar) FROM public;

----------------------------------------------------------------
-- Create FUNCTION QGIS_PKG.REFRESH_MVIEWS_BRIDGE
----------------------------------------------------------------
DROP FUNCTION IF EXISTS    qgis_pkg.refresh_mviews_bridge(varchar, varchar) CASCADE;
CREATE OR REPLACE FUNCTION qgis_pkg.refresh_mviews_bridge(
usr_schema	varchar,
cdb_schema	varchar
)
RETURNS void AS $$
DECLARE
regexp_string			CONSTANT varchar := '^(bri).*';
mv_prefix				CONSTANT varchar := '_g_';
mv_cdb_schema_pos		CONSTANT integer := length(mv_prefix) + 1;
mv_feat_type_pos		CONSTANT integer := mv_cdb_schema_pos + length(cdb_schema) + 1;
usr_schemas_array 		CONSTANT varchar[] := (SELECT array_agg(s.usr_schema) FROM qgis_pkg.list_usr_schemas() AS s);
cdb_schemas_array 		CONSTANT varchar[] := (SELECT array_agg(d.cdb_schema) FROM qgis_pkg.list_cdb_schemas() AS d);
feat_type_prefix        varchar;
start_timestamp 		timestamptz(3);
stop_timestamp 			timestamptz(3);
f_start_timestamp 		timestamptz(3);
f_stop_timestamp 		timestamptz(3);
mv_n_features 			integer DEFAULT 0;
r 						RECORD;

BEGIN

-- Check that the usr_schema exists
IF usr_schema IS NULL OR (NOT usr_schema = ANY(usr_schemas_array)) THEN
	RAISE EXCEPTION 'usr_schema value is invalid. It must correspond to an existing usr_schema';
END IF;

-- Check that the cdb_schema exists
IF cdb_schema IS NULL OR (NOT cdb_schema = ANY(cdb_schemas_array)) THEN
	RAISE EXCEPTION 'cdb_schema value is invalid. It must correspond to an existing cdb_schema';
END IF;

f_start_timestamp := clock_timestamp();

RAISE NOTICE 'Refreshing "Bridge" materialized views in usr_schema "%" associated to cdb_schema "%"', usr_schema, cdb_schema;		

FOR r IN 
	SELECT mv.matviewname AS mv_name FROM pg_matviews AS mv
	WHERE
		mv.schemaname::varchar = usr_schema
		AND substring(mv.matviewname, mv_cdb_schema_pos) LIKE concat(cdb_schema, '%')		
		AND substring(mv.matviewname, mv_feat_type_pos) ~ regexp_string			
	ORDER BY mv.matviewname ASC
LOOP
	start_timestamp := clock_timestamp();
	EXECUTE format('REFRESH MATERIALIZED VIEW %I.%I', usr_schema, r.mv_name);
	stop_timestamp := clock_timestamp();
	EXECUTE format('SELECT count(co_id) FROM %I.%I', usr_schema, r.mv_name) INTO mv_n_features;
	EXECUTE format('UPDATE %I.layer_metadata AS lm SET n_features = %L, refresh_date  = %L WHERE lm.mv_name = %L;',
		usr_schema, mv_n_features, stop_timestamp, r.mv_name);				
	RAISE NOTICE 'Refreshed materialized view "%"."%" in %', usr_schema, r.mv_name, stop_timestamp-start_timestamp; 
END LOOP;

f_stop_timestamp := clock_timestamp();		
RAISE NOTICE 'All "Bridge" materialized views in usr_schema "%" associated to cdb_schema "%" refreshed in %', usr_schema, cdb_schema, f_stop_timestamp-f_start_timestamp; 	

EXCEPTION
	WHEN QUERY_CANCELED THEN
		RAISE EXCEPTION 'qgis_pkg.refresh_mviews_bridge(): Error QUERY_CANCELED';
  WHEN OTHERS THEN 
		RAISE NOTICE 'qgis_pkg.refresh_mviews_bridge(): %', SQLERRM;
END;
$$ LANGUAGE plpgsql;
COMMENT ON FUNCTION qgis_pkg.refresh_mviews_bridge(varchar, varchar) IS 'Refresh "Bridge" materialized views (associated to a cdb_schema) in selected usr_schema';
REVOKE EXECUTE ON FUNCTION qgis_pkg.refresh_mviews_bridge(varchar, varchar) FROM public;

----------------------------------------------------------------
-- Create FUNCTION QGIS_PKG.CREATE_LAYERS_BUILDING
----------------------------------------------------------------
DROP FUNCTION IF EXISTS    qgis_pkg.create_layers_building(varchar, varchar, integer, integer, numeric, numeric[], boolean) CASCADE;
CREATE OR REPLACE FUNCTION qgis_pkg.create_layers_building(
usr_name            varchar,
cdb_schema 			varchar,
perform_snapping 	integer   DEFAULT 0,
digits 				integer	  DEFAULT 3,
area_poly_min 		numeric   DEFAULT 0.0001,
bbox_corners_array	numeric[] DEFAULT NULL,
force_layer_creation boolean  DEFAULT FALSE
)
RETURNS void AS $$
DECLARE
sql_statement 	text := NULL;
mview_bbox 		geometry(Polygon) := NULL;

BEGIN
mview_bbox := qgis_pkg.generate_mview_bbox_poly(cdb_schema, bbox_corners_array);

sql_statement := qgis_pkg.generate_sql_layers_building(
	usr_name             := usr_name, 
	cdb_schema 			 := cdb_schema, 			
    perform_snapping 	 := perform_snapping, 	
	digits 				 := digits, 				
	area_poly_min 		 := area_poly_min, 		
	mview_bbox			 := mview_bbox,			
	force_layer_creation := force_layer_creation
);

IF sql_statement IS NOT NULL THEN
	EXECUTE sql_statement;
END IF;

EXCEPTION
	WHEN QUERY_CANCELED THEN
		RAISE EXCEPTION 'qgis_pkg.create_layers_building(): Error QUERY_CANCELED';
	WHEN OTHERS THEN
		RAISE EXCEPTION 'qgis_pkg.create_layers_building(): %', SQLERRM;
END;
$$ LANGUAGE plpgsql;
COMMENT ON FUNCTION qgis_pkg.create_layers_building(varchar, varchar, integer, integer, numeric, numeric[], boolean) IS 'Create "Building" layers (associated to a cdb_schema) in selected usr_schema';
REVOKE EXECUTE ON FUNCTION qgis_pkg.create_layers_building(varchar, varchar, integer, integer, numeric, numeric[], boolean) FROM public;

----------------------------------------------------------------
-- Create FUNCTION QGIS_PKG.GENERATE_SQL_DROP_LAYERS_BUILDING
----------------------------------------------------------------
-- Generates SQL to drop layers (e.g. mviews, views and associated triggers)
DROP FUNCTION IF EXISTS    qgis_pkg.generate_sql_drop_layers_building(varchar, varchar) CASCADE;
CREATE OR REPLACE FUNCTION qgis_pkg.generate_sql_drop_layers_building(
usr_schema		varchar,
cdb_schema		varchar
)
RETURNS text
AS $$
DECLARE
feature_type			CONSTANT varchar := 'Building';
regexp_string			CONSTANT varchar := '^(bdg).*';
mv_prefix				CONSTANT varchar := '_g_';
mv_cdb_schema_pos		CONSTANT integer := length(mv_prefix) + 1;
mv_feat_type_pos		CONSTANT integer := mv_cdb_schema_pos + length(cdb_schema) + 1;
usr_schemas_array		CONSTANT varchar[] := (SELECT array_agg(s.usr_schema) FROM qgis_pkg.list_usr_schemas() AS s);
cdb_schemas_array		CONSTANT varchar[] := (SELECT array_agg(d.cdb_schema) FROM qgis_pkg.list_cdb_schemas() AS d);
feat_type_prefix		varchar;
sql_statement			text := NULL;
r RECORD;

BEGIN
-- Check that the usr_schema exists
IF usr_schema IS NULL OR (NOT usr_schema = ANY(usr_schemas_array)) THEN
	RAISE EXCEPTION 'usr_schema value is invalid. It must correspond to an existing usr_schema';
END IF;

-- Check that the cdb_schema exists
IF cdb_schema IS NULL OR (NOT cdb_schema = ANY(cdb_schemas_array)) THEN
	RAISE EXCEPTION 'cdb_schema value is invalid. It must correspond to an existing cdb_schema';
END IF;

FOR r IN 
	SELECT mv.matviewname AS mv_name FROM pg_matviews AS mv
	WHERE
		mv.schemaname::varchar = usr_schema
		AND substring(mv.matviewname, mv_cdb_schema_pos) LIKE concat(cdb_schema, '%')		
		AND substring(mv.matviewname, mv_feat_type_pos) ~ regexp_string	
	ORDER BY mv.matviewname ASC
LOOP
	sql_statement := concat(sql_statement, format('
DROP MATERIALIZED VIEW %I.%I CASCADE;',
usr_schema, r.mv_name));

END LOOP;

-- Delete entries from table layer_metadata
IF sql_statement IS NOT NULL THEN
	sql_statement := concat(sql_statement, format('
DELETE FROM %I.layer_metadata AS l WHERE l.cdb_schema = %L AND l.feature_type = %L;',
	usr_schema, cdb_schema, feature_type));
END IF;

RETURN sql_statement;

EXCEPTION
	WHEN QUERY_CANCELED THEN
		RAISE EXCEPTION 'qgis_pkg.generate_sql_drop_layers_building(): Error QUERY_CANCELED';
  WHEN OTHERS THEN 
		RAISE NOTICE 'qgis_pkg.generate_sql_drop_layers_building(): %', SQLERRM;
END;
$$ LANGUAGE plpgsql;
COMMENT ON FUNCTION qgis_pkg.generate_sql_drop_layers_building(varchar, varchar) IS 'Genereate SQL to drop "Building" layers (associated to a cdb_schema) in selected usr_schema';
REVOKE EXECUTE ON FUNCTION qgis_pkg.generate_sql_drop_layers_building(varchar, varchar) FROM public;

----------------------------------------------------------------
-- Create FUNCTION QGIS_PKG.DROP_LAYERS_BUILDING
----------------------------------------------------------------
-- Generates SQL to drops layers (e.g. mviews, views, and associated triggers)
DROP FUNCTION IF EXISTS    qgis_pkg.drop_layers_building(varchar, varchar) CASCADE;
CREATE OR REPLACE FUNCTION qgis_pkg.drop_layers_building(
usr_schema		varchar,
cdb_schema		varchar
)
RETURNS void
AS $$
DECLARE
sql_statement text := NULL;

BEGIN
sql_statement := qgis_pkg.generate_sql_drop_layers_building(usr_schema, cdb_schema); 

IF sql_statement IS NOT NULL THEN
	EXECUTE sql_statement;
END IF;

EXCEPTION
	WHEN QUERY_CANCELED THEN
		RAISE EXCEPTION 'qgis_pkg.drop_layers_building(): Error QUERY_CANCELED';
  WHEN OTHERS THEN 
		RAISE NOTICE 'qgis_pkg.drop_layers_building(): %', SQLERRM;
END;
$$ LANGUAGE plpgsql;
COMMENT ON FUNCTION qgis_pkg.drop_layers_building(varchar, varchar) IS 'Drop "Building" layers (associated to a cdb_schema) in selected usr_schema';
REVOKE EXECUTE ON FUNCTION qgis_pkg.drop_layers_building(varchar, varchar) FROM public;

----------------------------------------------------------------
-- Create FUNCTION QGIS_PKG.REFRESH_MVIEWS_BUILDING
----------------------------------------------------------------
DROP FUNCTION IF EXISTS    qgis_pkg.refresh_mviews_building(varchar, varchar) CASCADE;
CREATE OR REPLACE FUNCTION qgis_pkg.refresh_mviews_building(
usr_schema	varchar,
cdb_schema	varchar
)
RETURNS void AS $$
DECLARE
regexp_string			CONSTANT varchar := '^(bdg).*';
mv_prefix				CONSTANT varchar := '_g_';
mv_cdb_schema_pos		CONSTANT integer := length(mv_prefix) + 1;
mv_feat_type_pos		CONSTANT integer := mv_cdb_schema_pos + length(cdb_schema) + 1;
usr_schemas_array 		CONSTANT varchar[] := (SELECT array_agg(s.usr_schema) FROM qgis_pkg.list_usr_schemas() AS s);
cdb_schemas_array 		CONSTANT varchar[] := (SELECT array_agg(d.cdb_schema) FROM qgis_pkg.list_cdb_schemas() AS d);
feat_type_prefix        varchar;
start_timestamp 		timestamptz(3);
stop_timestamp 			timestamptz(3);
f_start_timestamp 		timestamptz(3);
f_stop_timestamp 		timestamptz(3);
mv_n_features 			integer DEFAULT 0;
r 						RECORD;

BEGIN

-- Check that the usr_schema exists
IF usr_schema IS NULL OR (NOT usr_schema = ANY(usr_schemas_array)) THEN
	RAISE EXCEPTION 'usr_schema value is invalid. It must correspond to an existing usr_schema';
END IF;

-- Check that the cdb_schema exists
IF cdb_schema IS NULL OR (NOT cdb_schema = ANY(cdb_schemas_array)) THEN
	RAISE EXCEPTION 'cdb_schema value is invalid. It must correspond to an existing cdb_schema';
END IF;

f_start_timestamp := clock_timestamp();

RAISE NOTICE 'Refreshing "Building" materialized views in usr_schema "%" associated to cdb_schema "%"', usr_schema, cdb_schema;		

FOR r IN 
	SELECT mv.matviewname AS mv_name FROM pg_matviews AS mv
	WHERE
		mv.schemaname::varchar = usr_schema
		AND substring(mv.matviewname, mv_cdb_schema_pos) LIKE concat(cdb_schema, '%')		
		AND substring(mv.matviewname, mv_feat_type_pos) ~ regexp_string			
	ORDER BY mv.matviewname ASC
LOOP
	start_timestamp := clock_timestamp();
	EXECUTE format('REFRESH MATERIALIZED VIEW %I.%I', usr_schema, r.mv_name);
	stop_timestamp := clock_timestamp();
	EXECUTE format('SELECT count(co_id) FROM %I.%I', usr_schema, r.mv_name) INTO mv_n_features;
	EXECUTE format('UPDATE %I.layer_metadata AS lm SET n_features = %L, refresh_date  = %L WHERE lm.mv_name = %L;',
		usr_schema, mv_n_features, stop_timestamp, r.mv_name);				
	RAISE NOTICE 'Refreshed materialized view "%"."%" in %', usr_schema, r.mv_name, stop_timestamp-start_timestamp; 
END LOOP;

f_stop_timestamp := clock_timestamp();		
RAISE NOTICE 'All "Building" materialized views in usr_schema "%" associated to cdb_schema "%" refreshed in %', usr_schema, cdb_schema, f_stop_timestamp-f_start_timestamp; 	

EXCEPTION
	WHEN QUERY_CANCELED THEN
		RAISE EXCEPTION 'qgis_pkg.refresh_mviews_building(): Error QUERY_CANCELED';
  WHEN OTHERS THEN 
		RAISE NOTICE 'qgis_pkg.refresh_mviews_building(): %', SQLERRM;
END;
$$ LANGUAGE plpgsql;
COMMENT ON FUNCTION qgis_pkg.refresh_mviews_building(varchar, varchar) IS 'Refresh "Building" materialized views (associated to a cdb_schema) in selected usr_schema';
REVOKE EXECUTE ON FUNCTION qgis_pkg.refresh_mviews_building(varchar, varchar) FROM public;

----------------------------------------------------------------
-- Create FUNCTION QGIS_PKG.CREATE_LAYERS_CITYFURNITURE
----------------------------------------------------------------
DROP FUNCTION IF EXISTS    qgis_pkg.create_layers_cityfurniture(varchar, varchar, integer, integer, numeric, numeric[], boolean) CASCADE;
CREATE OR REPLACE FUNCTION qgis_pkg.create_layers_cityfurniture(
usr_name            varchar,
cdb_schema 			varchar,
perform_snapping 	integer   DEFAULT 0,
digits 				integer	  DEFAULT 3,
area_poly_min 		numeric   DEFAULT 0.0001,
bbox_corners_array	numeric[] DEFAULT NULL,
force_layer_creation boolean  DEFAULT FALSE
)
RETURNS void AS $$
DECLARE
sql_statement 	text := NULL;
mview_bbox 		geometry(Polygon) := NULL;

BEGIN
mview_bbox := qgis_pkg.generate_mview_bbox_poly(cdb_schema, bbox_corners_array);

sql_statement := qgis_pkg.generate_sql_layers_cityfurniture(
	usr_name             := usr_name, 
	cdb_schema 			 := cdb_schema, 			
    perform_snapping 	 := perform_snapping, 	
	digits 				 := digits, 				
	area_poly_min 		 := area_poly_min, 		
	mview_bbox			 := mview_bbox,			
	force_layer_creation := force_layer_creation
);

IF sql_statement IS NOT NULL THEN
	EXECUTE sql_statement;
END IF;

EXCEPTION
	WHEN QUERY_CANCELED THEN
		RAISE EXCEPTION 'qgis_pkg.create_layers_cityfurniture(): Error QUERY_CANCELED';
	WHEN OTHERS THEN
		RAISE EXCEPTION 'qgis_pkg.create_layers_cityfurniture(): %', SQLERRM;
END;
$$ LANGUAGE plpgsql;
COMMENT ON FUNCTION qgis_pkg.create_layers_cityfurniture(varchar, varchar, integer, integer, numeric, numeric[], boolean) IS 'Create "CityFurniture" layers (associated to a cdb_schema) in selected usr_schema';
REVOKE EXECUTE ON FUNCTION qgis_pkg.create_layers_cityfurniture(varchar, varchar, integer, integer, numeric, numeric[], boolean) FROM public;

----------------------------------------------------------------
-- Create FUNCTION QGIS_PKG.GENERATE_SQL_DROP_LAYERS_CITYFURNITURE
----------------------------------------------------------------
-- Generates SQL to drop layers (e.g. mviews, views and associated triggers)
DROP FUNCTION IF EXISTS    qgis_pkg.generate_sql_drop_layers_cityfurniture(varchar, varchar) CASCADE;
CREATE OR REPLACE FUNCTION qgis_pkg.generate_sql_drop_layers_cityfurniture(
usr_schema		varchar,
cdb_schema		varchar
)
RETURNS text
AS $$
DECLARE
feature_type			CONSTANT varchar := 'CityFurniture';
regexp_string			CONSTANT varchar := '^(city_furn).*';
mv_prefix				CONSTANT varchar := '_g_';
mv_cdb_schema_pos		CONSTANT integer := length(mv_prefix) + 1;
mv_feat_type_pos		CONSTANT integer := mv_cdb_schema_pos + length(cdb_schema) + 1;
usr_schemas_array		CONSTANT varchar[] := (SELECT array_agg(s.usr_schema) FROM qgis_pkg.list_usr_schemas() AS s);
cdb_schemas_array		CONSTANT varchar[] := (SELECT array_agg(d.cdb_schema) FROM qgis_pkg.list_cdb_schemas() AS d);
feat_type_prefix		varchar;
sql_statement			text := NULL;
r RECORD;

BEGIN
-- Check that the usr_schema exists
IF usr_schema IS NULL OR (NOT usr_schema = ANY(usr_schemas_array)) THEN
	RAISE EXCEPTION 'usr_schema value is invalid. It must correspond to an existing usr_schema';
END IF;

-- Check that the cdb_schema exists
IF cdb_schema IS NULL OR (NOT cdb_schema = ANY(cdb_schemas_array)) THEN
	RAISE EXCEPTION 'cdb_schema value is invalid. It must correspond to an existing cdb_schema';
END IF;

FOR r IN 
	SELECT mv.matviewname AS mv_name FROM pg_matviews AS mv
	WHERE
		mv.schemaname::varchar = usr_schema
		AND substring(mv.matviewname, mv_cdb_schema_pos) LIKE concat(cdb_schema, '%')		
		AND substring(mv.matviewname, mv_feat_type_pos) ~ regexp_string	
	ORDER BY mv.matviewname ASC
LOOP
	sql_statement := concat(sql_statement, format('
DROP MATERIALIZED VIEW %I.%I CASCADE;',
usr_schema, r.mv_name));

END LOOP;

-- Delete entries from table layer_metadata
IF sql_statement IS NOT NULL THEN
	sql_statement := concat(sql_statement, format('
DELETE FROM %I.layer_metadata AS l WHERE l.cdb_schema = %L AND l.feature_type = %L;',
	usr_schema, cdb_schema, feature_type));
END IF;

RETURN sql_statement;

EXCEPTION
	WHEN QUERY_CANCELED THEN
		RAISE EXCEPTION 'qgis_pkg.generate_sql_drop_layers_cityfurniture(): Error QUERY_CANCELED';
  WHEN OTHERS THEN 
		RAISE NOTICE 'qgis_pkg.generate_sql_drop_layers_cityfurniture(): %', SQLERRM;
END;
$$ LANGUAGE plpgsql;
COMMENT ON FUNCTION qgis_pkg.generate_sql_drop_layers_cityfurniture(varchar, varchar) IS 'Genereate SQL to drop "CityFurniture" layers (associated to a cdb_schema) in selected usr_schema';
REVOKE EXECUTE ON FUNCTION qgis_pkg.generate_sql_drop_layers_cityfurniture(varchar, varchar) FROM public;

----------------------------------------------------------------
-- Create FUNCTION QGIS_PKG.DROP_LAYERS_CITYFURNITURE
----------------------------------------------------------------
-- Generates SQL to drops layers (e.g. mviews, views, and associated triggers)
DROP FUNCTION IF EXISTS    qgis_pkg.drop_layers_cityfurniture(varchar, varchar) CASCADE;
CREATE OR REPLACE FUNCTION qgis_pkg.drop_layers_cityfurniture(
usr_schema		varchar,
cdb_schema		varchar
)
RETURNS void
AS $$
DECLARE
sql_statement text := NULL;

BEGIN
sql_statement := qgis_pkg.generate_sql_drop_layers_cityfurniture(usr_schema, cdb_schema); 

IF sql_statement IS NOT NULL THEN
	EXECUTE sql_statement;
END IF;

EXCEPTION
	WHEN QUERY_CANCELED THEN
		RAISE EXCEPTION 'qgis_pkg.drop_layers_cityfurniture(): Error QUERY_CANCELED';
  WHEN OTHERS THEN 
		RAISE NOTICE 'qgis_pkg.drop_layers_cityfurniture(): %', SQLERRM;
END;
$$ LANGUAGE plpgsql;
COMMENT ON FUNCTION qgis_pkg.drop_layers_cityfurniture(varchar, varchar) IS 'Drop "CityFurniture" layers (associated to a cdb_schema) in selected usr_schema';
REVOKE EXECUTE ON FUNCTION qgis_pkg.drop_layers_cityfurniture(varchar, varchar) FROM public;

----------------------------------------------------------------
-- Create FUNCTION QGIS_PKG.REFRESH_MVIEWS_CITYFURNITURE
----------------------------------------------------------------
DROP FUNCTION IF EXISTS    qgis_pkg.refresh_mviews_cityfurniture(varchar, varchar) CASCADE;
CREATE OR REPLACE FUNCTION qgis_pkg.refresh_mviews_cityfurniture(
usr_schema	varchar,
cdb_schema	varchar
)
RETURNS void AS $$
DECLARE
regexp_string			CONSTANT varchar := '^(city_furn).*';
mv_prefix				CONSTANT varchar := '_g_';
mv_cdb_schema_pos		CONSTANT integer := length(mv_prefix) + 1;
mv_feat_type_pos		CONSTANT integer := mv_cdb_schema_pos + length(cdb_schema) + 1;
usr_schemas_array 		CONSTANT varchar[] := (SELECT array_agg(s.usr_schema) FROM qgis_pkg.list_usr_schemas() AS s);
cdb_schemas_array 		CONSTANT varchar[] := (SELECT array_agg(d.cdb_schema) FROM qgis_pkg.list_cdb_schemas() AS d);
feat_type_prefix        varchar;
start_timestamp 		timestamptz(3);
stop_timestamp 			timestamptz(3);
f_start_timestamp 		timestamptz(3);
f_stop_timestamp 		timestamptz(3);
mv_n_features 			integer DEFAULT 0;
r 						RECORD;

BEGIN

-- Check that the usr_schema exists
IF usr_schema IS NULL OR (NOT usr_schema = ANY(usr_schemas_array)) THEN
	RAISE EXCEPTION 'usr_schema value is invalid. It must correspond to an existing usr_schema';
END IF;

-- Check that the cdb_schema exists
IF cdb_schema IS NULL OR (NOT cdb_schema = ANY(cdb_schemas_array)) THEN
	RAISE EXCEPTION 'cdb_schema value is invalid. It must correspond to an existing cdb_schema';
END IF;

f_start_timestamp := clock_timestamp();

RAISE NOTICE 'Refreshing "CityFurniture" materialized views in usr_schema "%" associated to cdb_schema "%"', usr_schema, cdb_schema;		

FOR r IN 
	SELECT mv.matviewname AS mv_name FROM pg_matviews AS mv
	WHERE
		mv.schemaname::varchar = usr_schema
		AND substring(mv.matviewname, mv_cdb_schema_pos) LIKE concat(cdb_schema, '%')		
		AND substring(mv.matviewname, mv_feat_type_pos) ~ regexp_string			
	ORDER BY mv.matviewname ASC
LOOP
	start_timestamp := clock_timestamp();
	EXECUTE format('REFRESH MATERIALIZED VIEW %I.%I', usr_schema, r.mv_name);
	stop_timestamp := clock_timestamp();
	EXECUTE format('SELECT count(co_id) FROM %I.%I', usr_schema, r.mv_name) INTO mv_n_features;
	EXECUTE format('UPDATE %I.layer_metadata AS lm SET n_features = %L, refresh_date  = %L WHERE lm.mv_name = %L;',
		usr_schema, mv_n_features, stop_timestamp, r.mv_name);				
	RAISE NOTICE 'Refreshed materialized view "%"."%" in %', usr_schema, r.mv_name, stop_timestamp-start_timestamp; 
END LOOP;

f_stop_timestamp := clock_timestamp();		
RAISE NOTICE 'All "CityFurniture" materialized views in usr_schema "%" associated to cdb_schema "%" refreshed in %', usr_schema, cdb_schema, f_stop_timestamp-f_start_timestamp; 	

EXCEPTION
	WHEN QUERY_CANCELED THEN
		RAISE EXCEPTION 'qgis_pkg.refresh_mviews_cityfurniture(): Error QUERY_CANCELED';
  WHEN OTHERS THEN 
		RAISE NOTICE 'qgis_pkg.refresh_mviews_cityfurniture(): %', SQLERRM;
END;
$$ LANGUAGE plpgsql;
COMMENT ON FUNCTION qgis_pkg.refresh_mviews_cityfurniture(varchar, varchar) IS 'Refresh "CityFurniture" materialized views (associated to a cdb_schema) in selected usr_schema';
REVOKE EXECUTE ON FUNCTION qgis_pkg.refresh_mviews_cityfurniture(varchar, varchar) FROM public;

----------------------------------------------------------------
-- Create FUNCTION QGIS_PKG.CREATE_LAYERS_GENERICS
----------------------------------------------------------------
DROP FUNCTION IF EXISTS    qgis_pkg.create_layers_generics(varchar, varchar, integer, integer, numeric, numeric[], boolean) CASCADE;
CREATE OR REPLACE FUNCTION qgis_pkg.create_layers_generics(
usr_name            varchar,
cdb_schema 			varchar,
perform_snapping 	integer   DEFAULT 0,
digits 				integer	  DEFAULT 3,
area_poly_min 		numeric   DEFAULT 0.0001,
bbox_corners_array	numeric[] DEFAULT NULL,
force_layer_creation boolean  DEFAULT FALSE
)
RETURNS void AS $$
DECLARE
sql_statement 	text := NULL;
mview_bbox 		geometry(Polygon) := NULL;

BEGIN
mview_bbox := qgis_pkg.generate_mview_bbox_poly(cdb_schema, bbox_corners_array);

sql_statement := qgis_pkg.generate_sql_layers_generics(
	usr_name             := usr_name, 
	cdb_schema 			 := cdb_schema, 			
    perform_snapping 	 := perform_snapping, 	
	digits 				 := digits, 				
	area_poly_min 		 := area_poly_min, 		
	mview_bbox			 := mview_bbox,			
	force_layer_creation := force_layer_creation
);

IF sql_statement IS NOT NULL THEN
	EXECUTE sql_statement;
END IF;

EXCEPTION
	WHEN QUERY_CANCELED THEN
		RAISE EXCEPTION 'qgis_pkg.create_layers_generics(): Error QUERY_CANCELED';
	WHEN OTHERS THEN
		RAISE EXCEPTION 'qgis_pkg.create_layers_generics(): %', SQLERRM;
END;
$$ LANGUAGE plpgsql;
COMMENT ON FUNCTION qgis_pkg.create_layers_generics(varchar, varchar, integer, integer, numeric, numeric[], boolean) IS 'Create "Generics" layers (associated to a cdb_schema) in selected usr_schema';
REVOKE EXECUTE ON FUNCTION qgis_pkg.create_layers_generics(varchar, varchar, integer, integer, numeric, numeric[], boolean) FROM public;

----------------------------------------------------------------
-- Create FUNCTION QGIS_PKG.GENERATE_SQL_DROP_LAYERS_GENERICS
----------------------------------------------------------------
-- Generates SQL to drop layers (e.g. mviews, views and associated triggers)
DROP FUNCTION IF EXISTS    qgis_pkg.generate_sql_drop_layers_generics(varchar, varchar) CASCADE;
CREATE OR REPLACE FUNCTION qgis_pkg.generate_sql_drop_layers_generics(
usr_schema		varchar,
cdb_schema		varchar
)
RETURNS text
AS $$
DECLARE
feature_type			CONSTANT varchar := 'Generics';
regexp_string			CONSTANT varchar := '^(gen_cityobj).*';
mv_prefix				CONSTANT varchar := '_g_';
mv_cdb_schema_pos		CONSTANT integer := length(mv_prefix) + 1;
mv_feat_type_pos		CONSTANT integer := mv_cdb_schema_pos + length(cdb_schema) + 1;
usr_schemas_array		CONSTANT varchar[] := (SELECT array_agg(s.usr_schema) FROM qgis_pkg.list_usr_schemas() AS s);
cdb_schemas_array		CONSTANT varchar[] := (SELECT array_agg(d.cdb_schema) FROM qgis_pkg.list_cdb_schemas() AS d);
feat_type_prefix		varchar;
sql_statement			text := NULL;
r RECORD;

BEGIN
-- Check that the usr_schema exists
IF usr_schema IS NULL OR (NOT usr_schema = ANY(usr_schemas_array)) THEN
	RAISE EXCEPTION 'usr_schema value is invalid. It must correspond to an existing usr_schema';
END IF;

-- Check that the cdb_schema exists
IF cdb_schema IS NULL OR (NOT cdb_schema = ANY(cdb_schemas_array)) THEN
	RAISE EXCEPTION 'cdb_schema value is invalid. It must correspond to an existing cdb_schema';
END IF;

FOR r IN 
	SELECT mv.matviewname AS mv_name FROM pg_matviews AS mv
	WHERE
		mv.schemaname::varchar = usr_schema
		AND substring(mv.matviewname, mv_cdb_schema_pos) LIKE concat(cdb_schema, '%')		
		AND substring(mv.matviewname, mv_feat_type_pos) ~ regexp_string	
	ORDER BY mv.matviewname ASC
LOOP
	sql_statement := concat(sql_statement, format('
DROP MATERIALIZED VIEW %I.%I CASCADE;',
usr_schema, r.mv_name));

END LOOP;

-- Delete entries from table layer_metadata
IF sql_statement IS NOT NULL THEN
	sql_statement := concat(sql_statement, format('
DELETE FROM %I.layer_metadata AS l WHERE l.cdb_schema = %L AND l.feature_type = %L;',
	usr_schema, cdb_schema, feature_type));
END IF;

RETURN sql_statement;

EXCEPTION
	WHEN QUERY_CANCELED THEN
		RAISE EXCEPTION 'qgis_pkg.generate_sql_drop_layers_generics(): Error QUERY_CANCELED';
  WHEN OTHERS THEN 
		RAISE NOTICE 'qgis_pkg.generate_sql_drop_layers_generics(): %', SQLERRM;
END;
$$ LANGUAGE plpgsql;
COMMENT ON FUNCTION qgis_pkg.generate_sql_drop_layers_generics(varchar, varchar) IS 'Genereate SQL to drop "Generics" layers (associated to a cdb_schema) in selected usr_schema';
REVOKE EXECUTE ON FUNCTION qgis_pkg.generate_sql_drop_layers_generics(varchar, varchar) FROM public;

----------------------------------------------------------------
-- Create FUNCTION QGIS_PKG.DROP_LAYERS_GENERICS
----------------------------------------------------------------
-- Generates SQL to drops layers (e.g. mviews, views, and associated triggers)
DROP FUNCTION IF EXISTS    qgis_pkg.drop_layers_generics(varchar, varchar) CASCADE;
CREATE OR REPLACE FUNCTION qgis_pkg.drop_layers_generics(
usr_schema		varchar,
cdb_schema		varchar
)
RETURNS void
AS $$
DECLARE
sql_statement text := NULL;

BEGIN
sql_statement := qgis_pkg.generate_sql_drop_layers_generics(usr_schema, cdb_schema); 

IF sql_statement IS NOT NULL THEN
	EXECUTE sql_statement;
END IF;

EXCEPTION
	WHEN QUERY_CANCELED THEN
		RAISE EXCEPTION 'qgis_pkg.drop_layers_generics(): Error QUERY_CANCELED';
  WHEN OTHERS THEN 
		RAISE NOTICE 'qgis_pkg.drop_layers_generics(): %', SQLERRM;
END;
$$ LANGUAGE plpgsql;
COMMENT ON FUNCTION qgis_pkg.drop_layers_generics(varchar, varchar) IS 'Drop "Generics" layers (associated to a cdb_schema) in selected usr_schema';
REVOKE EXECUTE ON FUNCTION qgis_pkg.drop_layers_generics(varchar, varchar) FROM public;

----------------------------------------------------------------
-- Create FUNCTION QGIS_PKG.REFRESH_MVIEWS_GENERICS
----------------------------------------------------------------
DROP FUNCTION IF EXISTS    qgis_pkg.refresh_mviews_generics(varchar, varchar) CASCADE;
CREATE OR REPLACE FUNCTION qgis_pkg.refresh_mviews_generics(
usr_schema	varchar,
cdb_schema	varchar
)
RETURNS void AS $$
DECLARE
regexp_string			CONSTANT varchar := '^(gen_cityobj).*';
mv_prefix				CONSTANT varchar := '_g_';
mv_cdb_schema_pos		CONSTANT integer := length(mv_prefix) + 1;
mv_feat_type_pos		CONSTANT integer := mv_cdb_schema_pos + length(cdb_schema) + 1;
usr_schemas_array 		CONSTANT varchar[] := (SELECT array_agg(s.usr_schema) FROM qgis_pkg.list_usr_schemas() AS s);
cdb_schemas_array 		CONSTANT varchar[] := (SELECT array_agg(d.cdb_schema) FROM qgis_pkg.list_cdb_schemas() AS d);
feat_type_prefix        varchar;
start_timestamp 		timestamptz(3);
stop_timestamp 			timestamptz(3);
f_start_timestamp 		timestamptz(3);
f_stop_timestamp 		timestamptz(3);
mv_n_features 			integer DEFAULT 0;
r 						RECORD;

BEGIN

-- Check that the usr_schema exists
IF usr_schema IS NULL OR (NOT usr_schema = ANY(usr_schemas_array)) THEN
	RAISE EXCEPTION 'usr_schema value is invalid. It must correspond to an existing usr_schema';
END IF;

-- Check that the cdb_schema exists
IF cdb_schema IS NULL OR (NOT cdb_schema = ANY(cdb_schemas_array)) THEN
	RAISE EXCEPTION 'cdb_schema value is invalid. It must correspond to an existing cdb_schema';
END IF;

f_start_timestamp := clock_timestamp();

RAISE NOTICE 'Refreshing "Generics" materialized views in usr_schema "%" associated to cdb_schema "%"', usr_schema, cdb_schema;		

FOR r IN 
	SELECT mv.matviewname AS mv_name FROM pg_matviews AS mv
	WHERE
		mv.schemaname::varchar = usr_schema
		AND substring(mv.matviewname, mv_cdb_schema_pos) LIKE concat(cdb_schema, '%')		
		AND substring(mv.matviewname, mv_feat_type_pos) ~ regexp_string			
	ORDER BY mv.matviewname ASC
LOOP
	start_timestamp := clock_timestamp();
	EXECUTE format('REFRESH MATERIALIZED VIEW %I.%I', usr_schema, r.mv_name);
	stop_timestamp := clock_timestamp();
	EXECUTE format('SELECT count(co_id) FROM %I.%I', usr_schema, r.mv_name) INTO mv_n_features;
	EXECUTE format('UPDATE %I.layer_metadata AS lm SET n_features = %L, refresh_date  = %L WHERE lm.mv_name = %L;',
		usr_schema, mv_n_features, stop_timestamp, r.mv_name);				
	RAISE NOTICE 'Refreshed materialized view "%"."%" in %', usr_schema, r.mv_name, stop_timestamp-start_timestamp; 
END LOOP;

f_stop_timestamp := clock_timestamp();		
RAISE NOTICE 'All "Generics" materialized views in usr_schema "%" associated to cdb_schema "%" refreshed in %', usr_schema, cdb_schema, f_stop_timestamp-f_start_timestamp; 	

EXCEPTION
	WHEN QUERY_CANCELED THEN
		RAISE EXCEPTION 'qgis_pkg.refresh_mviews_generics(): Error QUERY_CANCELED';
  WHEN OTHERS THEN 
		RAISE NOTICE 'qgis_pkg.refresh_mviews_generics(): %', SQLERRM;
END;
$$ LANGUAGE plpgsql;
COMMENT ON FUNCTION qgis_pkg.refresh_mviews_generics(varchar, varchar) IS 'Refresh "Generics" materialized views (associated to a cdb_schema) in selected usr_schema';
REVOKE EXECUTE ON FUNCTION qgis_pkg.refresh_mviews_generics(varchar, varchar) FROM public;

----------------------------------------------------------------
-- Create FUNCTION QGIS_PKG.CREATE_LAYERS_LANDUSE
----------------------------------------------------------------
DROP FUNCTION IF EXISTS    qgis_pkg.create_layers_landuse(varchar, varchar, integer, integer, numeric, numeric[], boolean) CASCADE;
CREATE OR REPLACE FUNCTION qgis_pkg.create_layers_landuse(
usr_name            varchar,
cdb_schema 			varchar,
perform_snapping 	integer   DEFAULT 0,
digits 				integer	  DEFAULT 3,
area_poly_min 		numeric   DEFAULT 0.0001,
bbox_corners_array	numeric[] DEFAULT NULL,
force_layer_creation boolean  DEFAULT FALSE
)
RETURNS void AS $$
DECLARE
sql_statement 	text := NULL;
mview_bbox 		geometry(Polygon) := NULL;

BEGIN
mview_bbox := qgis_pkg.generate_mview_bbox_poly(cdb_schema, bbox_corners_array);

sql_statement := qgis_pkg.generate_sql_layers_landuse(
	usr_name             := usr_name, 
	cdb_schema 			 := cdb_schema, 			
    perform_snapping 	 := perform_snapping, 	
	digits 				 := digits, 				
	area_poly_min 		 := area_poly_min, 		
	mview_bbox			 := mview_bbox,			
	force_layer_creation := force_layer_creation
);

IF sql_statement IS NOT NULL THEN
	EXECUTE sql_statement;
END IF;

EXCEPTION
	WHEN QUERY_CANCELED THEN
		RAISE EXCEPTION 'qgis_pkg.create_layers_landuse(): Error QUERY_CANCELED';
	WHEN OTHERS THEN
		RAISE EXCEPTION 'qgis_pkg.create_layers_landuse(): %', SQLERRM;
END;
$$ LANGUAGE plpgsql;
COMMENT ON FUNCTION qgis_pkg.create_layers_landuse(varchar, varchar, integer, integer, numeric, numeric[], boolean) IS 'Create "LandUse" layers (associated to a cdb_schema) in selected usr_schema';
REVOKE EXECUTE ON FUNCTION qgis_pkg.create_layers_landuse(varchar, varchar, integer, integer, numeric, numeric[], boolean) FROM public;

----------------------------------------------------------------
-- Create FUNCTION QGIS_PKG.GENERATE_SQL_DROP_LAYERS_LANDUSE
----------------------------------------------------------------
-- Generates SQL to drop layers (e.g. mviews, views and associated triggers)
DROP FUNCTION IF EXISTS    qgis_pkg.generate_sql_drop_layers_landuse(varchar, varchar) CASCADE;
CREATE OR REPLACE FUNCTION qgis_pkg.generate_sql_drop_layers_landuse(
usr_schema		varchar,
cdb_schema		varchar
)
RETURNS text
AS $$
DECLARE
feature_type			CONSTANT varchar := 'LandUse';
regexp_string			CONSTANT varchar := '^(land_use).*';
mv_prefix				CONSTANT varchar := '_g_';
mv_cdb_schema_pos		CONSTANT integer := length(mv_prefix) + 1;
mv_feat_type_pos		CONSTANT integer := mv_cdb_schema_pos + length(cdb_schema) + 1;
usr_schemas_array		CONSTANT varchar[] := (SELECT array_agg(s.usr_schema) FROM qgis_pkg.list_usr_schemas() AS s);
cdb_schemas_array		CONSTANT varchar[] := (SELECT array_agg(d.cdb_schema) FROM qgis_pkg.list_cdb_schemas() AS d);
feat_type_prefix		varchar;
sql_statement			text := NULL;
r RECORD;

BEGIN
-- Check that the usr_schema exists
IF usr_schema IS NULL OR (NOT usr_schema = ANY(usr_schemas_array)) THEN
	RAISE EXCEPTION 'usr_schema value is invalid. It must correspond to an existing usr_schema';
END IF;

-- Check that the cdb_schema exists
IF cdb_schema IS NULL OR (NOT cdb_schema = ANY(cdb_schemas_array)) THEN
	RAISE EXCEPTION 'cdb_schema value is invalid. It must correspond to an existing cdb_schema';
END IF;

FOR r IN 
	SELECT mv.matviewname AS mv_name FROM pg_matviews AS mv
	WHERE
		mv.schemaname::varchar = usr_schema
		AND substring(mv.matviewname, mv_cdb_schema_pos) LIKE concat(cdb_schema, '%')		
		AND substring(mv.matviewname, mv_feat_type_pos) ~ regexp_string	
	ORDER BY mv.matviewname ASC
LOOP
	sql_statement := concat(sql_statement, format('
DROP MATERIALIZED VIEW %I.%I CASCADE;',
usr_schema, r.mv_name));

END LOOP;

-- Delete entries from table layer_metadata
IF sql_statement IS NOT NULL THEN
	sql_statement := concat(sql_statement, format('
DELETE FROM %I.layer_metadata AS l WHERE l.cdb_schema = %L AND l.feature_type = %L;',
	usr_schema, cdb_schema, feature_type));
END IF;

RETURN sql_statement;

EXCEPTION
	WHEN QUERY_CANCELED THEN
		RAISE EXCEPTION 'qgis_pkg.generate_sql_drop_layers_landuse(): Error QUERY_CANCELED';
  WHEN OTHERS THEN 
		RAISE NOTICE 'qgis_pkg.generate_sql_drop_layers_landuse(): %', SQLERRM;
END;
$$ LANGUAGE plpgsql;
COMMENT ON FUNCTION qgis_pkg.generate_sql_drop_layers_landuse(varchar, varchar) IS 'Genereate SQL to drop "LandUse" layers (associated to a cdb_schema) in selected usr_schema';
REVOKE EXECUTE ON FUNCTION qgis_pkg.generate_sql_drop_layers_landuse(varchar, varchar) FROM public;

----------------------------------------------------------------
-- Create FUNCTION QGIS_PKG.DROP_LAYERS_LANDUSE
----------------------------------------------------------------
-- Generates SQL to drops layers (e.g. mviews, views, and associated triggers)
DROP FUNCTION IF EXISTS    qgis_pkg.drop_layers_landuse(varchar, varchar) CASCADE;
CREATE OR REPLACE FUNCTION qgis_pkg.drop_layers_landuse(
usr_schema		varchar,
cdb_schema		varchar
)
RETURNS void
AS $$
DECLARE
sql_statement text := NULL;

BEGIN
sql_statement := qgis_pkg.generate_sql_drop_layers_landuse(usr_schema, cdb_schema); 

IF sql_statement IS NOT NULL THEN
	EXECUTE sql_statement;
END IF;

EXCEPTION
	WHEN QUERY_CANCELED THEN
		RAISE EXCEPTION 'qgis_pkg.drop_layers_landuse(): Error QUERY_CANCELED';
  WHEN OTHERS THEN 
		RAISE NOTICE 'qgis_pkg.drop_layers_landuse(): %', SQLERRM;
END;
$$ LANGUAGE plpgsql;
COMMENT ON FUNCTION qgis_pkg.drop_layers_landuse(varchar, varchar) IS 'Drop "LandUse" layers (associated to a cdb_schema) in selected usr_schema';
REVOKE EXECUTE ON FUNCTION qgis_pkg.drop_layers_landuse(varchar, varchar) FROM public;

----------------------------------------------------------------
-- Create FUNCTION QGIS_PKG.REFRESH_MVIEWS_LANDUSE
----------------------------------------------------------------
DROP FUNCTION IF EXISTS    qgis_pkg.refresh_mviews_landuse(varchar, varchar) CASCADE;
CREATE OR REPLACE FUNCTION qgis_pkg.refresh_mviews_landuse(
usr_schema	varchar,
cdb_schema	varchar
)
RETURNS void AS $$
DECLARE
regexp_string			CONSTANT varchar := '^(land_use).*';
mv_prefix				CONSTANT varchar := '_g_';
mv_cdb_schema_pos		CONSTANT integer := length(mv_prefix) + 1;
mv_feat_type_pos		CONSTANT integer := mv_cdb_schema_pos + length(cdb_schema) + 1;
usr_schemas_array 		CONSTANT varchar[] := (SELECT array_agg(s.usr_schema) FROM qgis_pkg.list_usr_schemas() AS s);
cdb_schemas_array 		CONSTANT varchar[] := (SELECT array_agg(d.cdb_schema) FROM qgis_pkg.list_cdb_schemas() AS d);
feat_type_prefix        varchar;
start_timestamp 		timestamptz(3);
stop_timestamp 			timestamptz(3);
f_start_timestamp 		timestamptz(3);
f_stop_timestamp 		timestamptz(3);
mv_n_features 			integer DEFAULT 0;
r 						RECORD;

BEGIN

-- Check that the usr_schema exists
IF usr_schema IS NULL OR (NOT usr_schema = ANY(usr_schemas_array)) THEN
	RAISE EXCEPTION 'usr_schema value is invalid. It must correspond to an existing usr_schema';
END IF;

-- Check that the cdb_schema exists
IF cdb_schema IS NULL OR (NOT cdb_schema = ANY(cdb_schemas_array)) THEN
	RAISE EXCEPTION 'cdb_schema value is invalid. It must correspond to an existing cdb_schema';
END IF;

f_start_timestamp := clock_timestamp();

RAISE NOTICE 'Refreshing "LandUse" materialized views in usr_schema "%" associated to cdb_schema "%"', usr_schema, cdb_schema;		

FOR r IN 
	SELECT mv.matviewname AS mv_name FROM pg_matviews AS mv
	WHERE
		mv.schemaname::varchar = usr_schema
		AND substring(mv.matviewname, mv_cdb_schema_pos) LIKE concat(cdb_schema, '%')		
		AND substring(mv.matviewname, mv_feat_type_pos) ~ regexp_string			
	ORDER BY mv.matviewname ASC
LOOP
	start_timestamp := clock_timestamp();
	EXECUTE format('REFRESH MATERIALIZED VIEW %I.%I', usr_schema, r.mv_name);
	stop_timestamp := clock_timestamp();
	EXECUTE format('SELECT count(co_id) FROM %I.%I', usr_schema, r.mv_name) INTO mv_n_features;
	EXECUTE format('UPDATE %I.layer_metadata AS lm SET n_features = %L, refresh_date  = %L WHERE lm.mv_name = %L;',
		usr_schema, mv_n_features, stop_timestamp, r.mv_name);				
	RAISE NOTICE 'Refreshed materialized view "%"."%" in %', usr_schema, r.mv_name, stop_timestamp-start_timestamp; 
END LOOP;

f_stop_timestamp := clock_timestamp();		
RAISE NOTICE 'All "LandUse" materialized views in usr_schema "%" associated to cdb_schema "%" refreshed in %', usr_schema, cdb_schema, f_stop_timestamp-f_start_timestamp; 	

EXCEPTION
	WHEN QUERY_CANCELED THEN
		RAISE EXCEPTION 'qgis_pkg.refresh_mviews_landuse(): Error QUERY_CANCELED';
  WHEN OTHERS THEN 
		RAISE NOTICE 'qgis_pkg.refresh_mviews_landuse(): %', SQLERRM;
END;
$$ LANGUAGE plpgsql;
COMMENT ON FUNCTION qgis_pkg.refresh_mviews_landuse(varchar, varchar) IS 'Refresh "LandUse" materialized views (associated to a cdb_schema) in selected usr_schema';
REVOKE EXECUTE ON FUNCTION qgis_pkg.refresh_mviews_landuse(varchar, varchar) FROM public;

----------------------------------------------------------------
-- Create FUNCTION QGIS_PKG.CREATE_LAYERS_RELIEF
----------------------------------------------------------------
DROP FUNCTION IF EXISTS    qgis_pkg.create_layers_relief(varchar, varchar, integer, integer, numeric, numeric[], boolean) CASCADE;
CREATE OR REPLACE FUNCTION qgis_pkg.create_layers_relief(
usr_name            varchar,
cdb_schema 			varchar,
perform_snapping 	integer   DEFAULT 0,
digits 				integer	  DEFAULT 3,
area_poly_min 		numeric   DEFAULT 0.0001,
bbox_corners_array	numeric[] DEFAULT NULL,
force_layer_creation boolean  DEFAULT FALSE
)
RETURNS void AS $$
DECLARE
sql_statement 	text := NULL;
mview_bbox 		geometry(Polygon) := NULL;

BEGIN
mview_bbox := qgis_pkg.generate_mview_bbox_poly(cdb_schema, bbox_corners_array);

sql_statement := qgis_pkg.generate_sql_layers_relief(
	usr_name             := usr_name, 
	cdb_schema 			 := cdb_schema, 			
    perform_snapping 	 := perform_snapping, 	
	digits 				 := digits, 				
	area_poly_min 		 := area_poly_min, 		
	mview_bbox			 := mview_bbox,			
	force_layer_creation := force_layer_creation
);

IF sql_statement IS NOT NULL THEN
	EXECUTE sql_statement;
END IF;

EXCEPTION
	WHEN QUERY_CANCELED THEN
		RAISE EXCEPTION 'qgis_pkg.create_layers_relief(): Error QUERY_CANCELED';
	WHEN OTHERS THEN
		RAISE EXCEPTION 'qgis_pkg.create_layers_relief(): %', SQLERRM;
END;
$$ LANGUAGE plpgsql;
COMMENT ON FUNCTION qgis_pkg.create_layers_relief(varchar, varchar, integer, integer, numeric, numeric[], boolean) IS 'Create "Relief" layers (associated to a cdb_schema) in selected usr_schema';
REVOKE EXECUTE ON FUNCTION qgis_pkg.create_layers_relief(varchar, varchar, integer, integer, numeric, numeric[], boolean) FROM public;

----------------------------------------------------------------
-- Create FUNCTION QGIS_PKG.GENERATE_SQL_DROP_LAYERS_RELIEF
----------------------------------------------------------------
-- Generates SQL to drop layers (e.g. mviews, views and associated triggers)
DROP FUNCTION IF EXISTS    qgis_pkg.generate_sql_drop_layers_relief(varchar, varchar) CASCADE;
CREATE OR REPLACE FUNCTION qgis_pkg.generate_sql_drop_layers_relief(
usr_schema		varchar,
cdb_schema		varchar
)
RETURNS text
AS $$
DECLARE
feature_type			CONSTANT varchar := 'Relief';
regexp_string			CONSTANT varchar := '^(rel).*';
--regexp_string			CONSTANT varchar := '^(relief_feat|tin_relief|masspnt_relief|rast_relief|brkln_relief).*';
mv_prefix				CONSTANT varchar := '_g_';
mv_cdb_schema_pos		CONSTANT integer := length(mv_prefix) + 1;
mv_feat_type_pos		CONSTANT integer := mv_cdb_schema_pos + length(cdb_schema) + 1;
usr_schemas_array		CONSTANT varchar[] := (SELECT array_agg(s.usr_schema) FROM qgis_pkg.list_usr_schemas() AS s);
cdb_schemas_array		CONSTANT varchar[] := (SELECT array_agg(d.cdb_schema) FROM qgis_pkg.list_cdb_schemas() AS d);
feat_type_prefix		varchar;
sql_statement			text := NULL;
r RECORD;

BEGIN
-- Check that the usr_schema exists
IF usr_schema IS NULL OR (NOT usr_schema = ANY(usr_schemas_array)) THEN
	RAISE EXCEPTION 'usr_schema value is invalid. It must correspond to an existing usr_schema';
END IF;

-- Check that the cdb_schema exists
IF cdb_schema IS NULL OR (NOT cdb_schema = ANY(cdb_schemas_array)) THEN
	RAISE EXCEPTION 'cdb_schema value is invalid. It must correspond to an existing cdb_schema';
END IF;

FOR r IN 
	SELECT mv.matviewname AS mv_name FROM pg_matviews AS mv
	WHERE
		mv.schemaname::varchar = usr_schema
		AND substring(mv.matviewname, mv_cdb_schema_pos) LIKE concat(cdb_schema, '%')		
		AND substring(mv.matviewname, mv_feat_type_pos) ~ regexp_string	
	ORDER BY mv.matviewname ASC
LOOP
	sql_statement := concat(sql_statement, format('
DROP MATERIALIZED VIEW %I.%I CASCADE;',
usr_schema, r.mv_name));

END LOOP;

-- Delete entries from table layer_metadata
IF sql_statement IS NOT NULL THEN
	sql_statement := concat(sql_statement, format('
DELETE FROM %I.layer_metadata AS l WHERE l.cdb_schema = %L AND l.feature_type = %L;',
	usr_schema, cdb_schema, feature_type));
END IF;

RETURN sql_statement;

EXCEPTION
	WHEN QUERY_CANCELED THEN
		RAISE EXCEPTION 'qgis_pkg.generate_sql_drop_layers_relief(): Error QUERY_CANCELED';
  WHEN OTHERS THEN 
		RAISE NOTICE 'qgis_pkg.generate_sql_drop_layers_relief(): %', SQLERRM;
END;
$$ LANGUAGE plpgsql;
COMMENT ON FUNCTION qgis_pkg.generate_sql_drop_layers_relief(varchar, varchar) IS 'Genereate SQL to drop "Relief" layers (associated to a cdb_schema) in selected usr_schema';
REVOKE EXECUTE ON FUNCTION qgis_pkg.generate_sql_drop_layers_relief(varchar, varchar) FROM public;

----------------------------------------------------------------
-- Create FUNCTION QGIS_PKG.DROP_LAYERS_RELIEF
----------------------------------------------------------------
-- Generates SQL to drops layers (e.g. mviews, views, and associated triggers)
DROP FUNCTION IF EXISTS    qgis_pkg.drop_layers_relief(varchar, varchar) CASCADE;
CREATE OR REPLACE FUNCTION qgis_pkg.drop_layers_relief(
usr_schema		varchar,
cdb_schema		varchar
)
RETURNS void
AS $$
DECLARE
sql_statement text := NULL;

BEGIN
sql_statement := qgis_pkg.generate_sql_drop_layers_relief(usr_schema, cdb_schema); 

IF sql_statement IS NOT NULL THEN
	EXECUTE sql_statement;
END IF;

EXCEPTION
	WHEN QUERY_CANCELED THEN
		RAISE EXCEPTION 'qgis_pkg.drop_layers_relief(): Error QUERY_CANCELED';
  WHEN OTHERS THEN 
		RAISE NOTICE 'qgis_pkg.drop_layers_relief(): %', SQLERRM;
END;
$$ LANGUAGE plpgsql;
COMMENT ON FUNCTION qgis_pkg.drop_layers_relief(varchar, varchar) IS 'Drop "Relief" layers (associated to a cdb_schema) in selected usr_schema';
REVOKE EXECUTE ON FUNCTION qgis_pkg.drop_layers_relief(varchar, varchar) FROM public;

----------------------------------------------------------------
-- Create FUNCTION QGIS_PKG.REFRESH_MVIEWS_RELIEF
----------------------------------------------------------------
DROP FUNCTION IF EXISTS    qgis_pkg.refresh_mviews_relief(varchar, varchar) CASCADE;
CREATE OR REPLACE FUNCTION qgis_pkg.refresh_mviews_relief(
usr_schema	varchar,
cdb_schema	varchar
)
RETURNS void AS $$
DECLARE
regexp_string			CONSTANT varchar := '^(rel).*';
mv_prefix				CONSTANT varchar := '_g_';
mv_cdb_schema_pos		CONSTANT integer := length(mv_prefix) + 1;
mv_feat_type_pos		CONSTANT integer := mv_cdb_schema_pos + length(cdb_schema) + 1;
usr_schemas_array 		CONSTANT varchar[] := (SELECT array_agg(s.usr_schema) FROM qgis_pkg.list_usr_schemas() AS s);
cdb_schemas_array 		CONSTANT varchar[] := (SELECT array_agg(d.cdb_schema) FROM qgis_pkg.list_cdb_schemas() AS d);
feat_type_prefix        varchar;
start_timestamp 		timestamptz(3);
stop_timestamp 			timestamptz(3);
f_start_timestamp 		timestamptz(3);
f_stop_timestamp 		timestamptz(3);
mv_n_features 			integer DEFAULT 0;
r 						RECORD;

BEGIN

-- Check that the usr_schema exists
IF usr_schema IS NULL OR (NOT usr_schema = ANY(usr_schemas_array)) THEN
	RAISE EXCEPTION 'usr_schema value is invalid. It must correspond to an existing usr_schema';
END IF;

-- Check that the cdb_schema exists
IF cdb_schema IS NULL OR (NOT cdb_schema = ANY(cdb_schemas_array)) THEN
	RAISE EXCEPTION 'cdb_schema value is invalid. It must correspond to an existing cdb_schema';
END IF;

f_start_timestamp := clock_timestamp();

RAISE NOTICE 'Refreshing "Relief" materialized views in usr_schema "%" associated to cdb_schema "%"', usr_schema, cdb_schema;		

FOR r IN 
	SELECT mv.matviewname AS mv_name FROM pg_matviews AS mv
	WHERE
		mv.schemaname::varchar = usr_schema
		AND substring(mv.matviewname, mv_cdb_schema_pos) LIKE concat(cdb_schema, '%')		
		AND substring(mv.matviewname, mv_feat_type_pos) ~ regexp_string			
	ORDER BY mv.matviewname ASC
LOOP
	start_timestamp := clock_timestamp();
	EXECUTE format('REFRESH MATERIALIZED VIEW %I.%I', usr_schema, r.mv_name);
	stop_timestamp := clock_timestamp();
	EXECUTE format('SELECT count(co_id) FROM %I.%I', usr_schema, r.mv_name) INTO mv_n_features;
	EXECUTE format('UPDATE %I.layer_metadata AS lm SET n_features = %L, refresh_date  = %L WHERE lm.mv_name = %L;',
		usr_schema, mv_n_features, stop_timestamp, r.mv_name);				
	RAISE NOTICE 'Refreshed materialized view "%"."%" in %', usr_schema, r.mv_name, stop_timestamp-start_timestamp; 
END LOOP;

f_stop_timestamp := clock_timestamp();		
RAISE NOTICE 'All "Relief" materialized views in usr_schema "%" associated to cdb_schema "%" refreshed in %', usr_schema, cdb_schema, f_stop_timestamp-f_start_timestamp; 	

EXCEPTION
	WHEN QUERY_CANCELED THEN
		RAISE EXCEPTION 'qgis_pkg.refresh_mviews_relief(): Error QUERY_CANCELED';
  WHEN OTHERS THEN 
		RAISE NOTICE 'qgis_pkg.refresh_mviews_relief(): %', SQLERRM;
END;
$$ LANGUAGE plpgsql;
COMMENT ON FUNCTION qgis_pkg.refresh_mviews_relief(varchar, varchar) IS 'Refresh "Relief" materialized views (associated to a cdb_schema) in selected usr_schema';
REVOKE EXECUTE ON FUNCTION qgis_pkg.refresh_mviews_relief(varchar, varchar) FROM public;

----------------------------------------------------------------
-- Create FUNCTION QGIS_PKG.CREATE_LAYERS_TRANSPORTATION
----------------------------------------------------------------
DROP FUNCTION IF EXISTS    qgis_pkg.create_layers_transportation(varchar, varchar, integer, integer, numeric, numeric[], boolean) CASCADE;
CREATE OR REPLACE FUNCTION qgis_pkg.create_layers_transportation(
usr_name            varchar,
cdb_schema 			varchar,
perform_snapping 	integer   DEFAULT 0,
digits 				integer	  DEFAULT 3,
area_poly_min 		numeric   DEFAULT 0.0001,
bbox_corners_array	numeric[] DEFAULT NULL,
force_layer_creation boolean  DEFAULT FALSE
)
RETURNS void AS $$
DECLARE
sql_statement 	text := NULL;
mview_bbox 		geometry(Polygon) := NULL;

BEGIN
mview_bbox := qgis_pkg.generate_mview_bbox_poly(cdb_schema, bbox_corners_array);

sql_statement := qgis_pkg.generate_sql_layers_transportation(
	usr_name             := usr_name, 
	cdb_schema 			 := cdb_schema, 			
    perform_snapping 	 := perform_snapping, 	
	digits 				 := digits, 				
	area_poly_min 		 := area_poly_min, 		
	mview_bbox			 := mview_bbox,			
	force_layer_creation := force_layer_creation
);

IF sql_statement IS NOT NULL THEN
	EXECUTE sql_statement;
END IF;

EXCEPTION
	WHEN QUERY_CANCELED THEN
		RAISE EXCEPTION 'qgis_pkg.create_layers_transportation(): Error QUERY_CANCELED';
	WHEN OTHERS THEN
		RAISE EXCEPTION 'qgis_pkg.create_layers_transportation(): %', SQLERRM;
END;
$$ LANGUAGE plpgsql;
COMMENT ON FUNCTION qgis_pkg.create_layers_transportation(varchar, varchar, integer, integer, numeric, numeric[], boolean) IS 'Create "Transportation" layers (associated to a cdb_schema) in selected usr_schema';
REVOKE EXECUTE ON FUNCTION qgis_pkg.create_layers_transportation(varchar, varchar, integer, integer, numeric, numeric[], boolean) FROM public;

----------------------------------------------------------------
-- Create FUNCTION QGIS_PKG.GENERATE_SQL_DROP_LAYERS_TRANSPORTATION
----------------------------------------------------------------
-- Generates SQL to drop layers (e.g. mviews, views and associated triggers)
DROP FUNCTION IF EXISTS    qgis_pkg.generate_sql_drop_layers_transportation(varchar, varchar) CASCADE;
CREATE OR REPLACE FUNCTION qgis_pkg.generate_sql_drop_layers_transportation(
usr_schema		varchar,
cdb_schema		varchar
)
RETURNS text
AS $$
DECLARE
feature_type			CONSTANT varchar := 'Transportation';
regexp_string			CONSTANT varchar := '^(trn).*';
--regexp_string			CONSTANT varchar := '^(railway|road|square|track|tran_complex).*';
mv_prefix				CONSTANT varchar := '_g_';
mv_cdb_schema_pos		CONSTANT integer := length(mv_prefix) + 1;
mv_feat_type_pos		CONSTANT integer := mv_cdb_schema_pos + length(cdb_schema) + 1;
usr_schemas_array		CONSTANT varchar[] := (SELECT array_agg(s.usr_schema) FROM qgis_pkg.list_usr_schemas() AS s);
cdb_schemas_array		CONSTANT varchar[] := (SELECT array_agg(d.cdb_schema) FROM qgis_pkg.list_cdb_schemas() AS d);
feat_type_prefix		varchar;
sql_statement			text := NULL;
r RECORD;

BEGIN
-- Check that the usr_schema exists
IF usr_schema IS NULL OR (NOT usr_schema = ANY(usr_schemas_array)) THEN
	RAISE EXCEPTION 'usr_schema value is invalid. It must correspond to an existing usr_schema';
END IF;

-- Check that the cdb_schema exists
IF cdb_schema IS NULL OR (NOT cdb_schema = ANY(cdb_schemas_array)) THEN
	RAISE EXCEPTION 'cdb_schema value is invalid. It must correspond to an existing cdb_schema';
END IF;

FOR r IN 
	SELECT mv.matviewname AS mv_name FROM pg_matviews AS mv
	WHERE
		mv.schemaname::varchar = usr_schema
		AND substring(mv.matviewname, mv_cdb_schema_pos) LIKE concat(cdb_schema, '%')		
		AND substring(mv.matviewname, mv_feat_type_pos) ~ regexp_string	
	ORDER BY mv.matviewname ASC
LOOP
	sql_statement := concat(sql_statement, format('
DROP MATERIALIZED VIEW %I.%I CASCADE;',
usr_schema, r.mv_name));

END LOOP;

-- Delete entries from table layer_metadata
IF sql_statement IS NOT NULL THEN
	sql_statement := concat(sql_statement, format('
DELETE FROM %I.layer_metadata AS l WHERE l.cdb_schema = %L AND l.feature_type = %L;',
	usr_schema, cdb_schema, feature_type));
END IF;

RETURN sql_statement;

EXCEPTION
	WHEN QUERY_CANCELED THEN
		RAISE EXCEPTION 'qgis_pkg.generate_sql_drop_layers_transportation(): Error QUERY_CANCELED';
  WHEN OTHERS THEN 
		RAISE NOTICE 'qgis_pkg.generate_sql_drop_layers_transportation(): %', SQLERRM;
END;
$$ LANGUAGE plpgsql;
COMMENT ON FUNCTION qgis_pkg.generate_sql_drop_layers_transportation(varchar, varchar) IS 'Genereate SQL to drop "Transportation" layers (associated to a cdb_schema) in selected usr_schema';
REVOKE EXECUTE ON FUNCTION qgis_pkg.generate_sql_drop_layers_transportation(varchar, varchar) FROM public;

----------------------------------------------------------------
-- Create FUNCTION QGIS_PKG.DROP_LAYERS_TRANSPORTATION
----------------------------------------------------------------
-- Generates SQL to drops layers (e.g. mviews, views, and associated triggers)
DROP FUNCTION IF EXISTS    qgis_pkg.drop_layers_transportation(varchar, varchar) CASCADE;
CREATE OR REPLACE FUNCTION qgis_pkg.drop_layers_transportation(
usr_schema		varchar,
cdb_schema		varchar
)
RETURNS void
AS $$
DECLARE
sql_statement text := NULL;

BEGIN
sql_statement := qgis_pkg.generate_sql_drop_layers_transportation(usr_schema, cdb_schema); 

IF sql_statement IS NOT NULL THEN
	EXECUTE sql_statement;
END IF;

EXCEPTION
	WHEN QUERY_CANCELED THEN
		RAISE EXCEPTION 'qgis_pkg.drop_layers_transportation(): Error QUERY_CANCELED';
  WHEN OTHERS THEN 
		RAISE NOTICE 'qgis_pkg.drop_layers_transportation(): %', SQLERRM;
END;
$$ LANGUAGE plpgsql;
COMMENT ON FUNCTION qgis_pkg.drop_layers_transportation(varchar, varchar) IS 'Drop "Transportation" layers (associated to a cdb_schema) in selected usr_schema';
REVOKE EXECUTE ON FUNCTION qgis_pkg.drop_layers_transportation(varchar, varchar) FROM public;

----------------------------------------------------------------
-- Create FUNCTION QGIS_PKG.REFRESH_MVIEWS_TRANSPORTATION
----------------------------------------------------------------
DROP FUNCTION IF EXISTS    qgis_pkg.refresh_mviews_transportation(varchar, varchar) CASCADE;
CREATE OR REPLACE FUNCTION qgis_pkg.refresh_mviews_transportation(
usr_schema	varchar,
cdb_schema	varchar
)
RETURNS void AS $$
DECLARE
regexp_string			CONSTANT varchar := '^(trn).*';
mv_prefix				CONSTANT varchar := '_g_';
mv_cdb_schema_pos		CONSTANT integer := length(mv_prefix) + 1;
mv_feat_type_pos		CONSTANT integer := mv_cdb_schema_pos + length(cdb_schema) + 1;
usr_schemas_array 		CONSTANT varchar[] := (SELECT array_agg(s.usr_schema) FROM qgis_pkg.list_usr_schemas() AS s);
cdb_schemas_array 		CONSTANT varchar[] := (SELECT array_agg(d.cdb_schema) FROM qgis_pkg.list_cdb_schemas() AS d);
feat_type_prefix        varchar;
start_timestamp 		timestamptz(3);
stop_timestamp 			timestamptz(3);
f_start_timestamp 		timestamptz(3);
f_stop_timestamp 		timestamptz(3);
mv_n_features 			integer DEFAULT 0;
r 						RECORD;

BEGIN

-- Check that the usr_schema exists
IF usr_schema IS NULL OR (NOT usr_schema = ANY(usr_schemas_array)) THEN
	RAISE EXCEPTION 'usr_schema value is invalid. It must correspond to an existing usr_schema';
END IF;

-- Check that the cdb_schema exists
IF cdb_schema IS NULL OR (NOT cdb_schema = ANY(cdb_schemas_array)) THEN
	RAISE EXCEPTION 'cdb_schema value is invalid. It must correspond to an existing cdb_schema';
END IF;

f_start_timestamp := clock_timestamp();

RAISE NOTICE 'Refreshing "Transportation" materialized views in usr_schema "%" associated to cdb_schema "%"', usr_schema, cdb_schema;		

FOR r IN 
	SELECT mv.matviewname AS mv_name FROM pg_matviews AS mv
	WHERE
		mv.schemaname::varchar = usr_schema
		AND substring(mv.matviewname, mv_cdb_schema_pos) LIKE concat(cdb_schema, '%')		
		AND substring(mv.matviewname, mv_feat_type_pos) ~ regexp_string			
	ORDER BY mv.matviewname ASC
LOOP
	start_timestamp := clock_timestamp();
	EXECUTE format('REFRESH MATERIALIZED VIEW %I.%I', usr_schema, r.mv_name);
	stop_timestamp := clock_timestamp();
	EXECUTE format('SELECT count(co_id) FROM %I.%I', usr_schema, r.mv_name) INTO mv_n_features;
	EXECUTE format('UPDATE %I.layer_metadata AS lm SET n_features = %L, refresh_date  = %L WHERE lm.mv_name = %L;',
		usr_schema, mv_n_features, stop_timestamp, r.mv_name);				
	RAISE NOTICE 'Refreshed materialized view "%"."%" in %', usr_schema, r.mv_name, stop_timestamp-start_timestamp; 
END LOOP;

f_stop_timestamp := clock_timestamp();		
RAISE NOTICE 'All "Transportation" materialized views in usr_schema "%" associated to cdb_schema "%" refreshed in %', usr_schema, cdb_schema, f_stop_timestamp-f_start_timestamp; 	

EXCEPTION
	WHEN QUERY_CANCELED THEN
		RAISE EXCEPTION 'qgis_pkg.refresh_mviews_transportation(): Error QUERY_CANCELED';
  WHEN OTHERS THEN 
		RAISE NOTICE 'qgis_pkg.refresh_mviews_transportation(): %', SQLERRM;
END;
$$ LANGUAGE plpgsql;
COMMENT ON FUNCTION qgis_pkg.refresh_mviews_transportation(varchar, varchar) IS 'Refresh "Transportation" materialized views (associated to a cdb_schema) in selected usr_schema';
REVOKE EXECUTE ON FUNCTION qgis_pkg.refresh_mviews_transportation(varchar, varchar) FROM public;

----------------------------------------------------------------
-- Create FUNCTION QGIS_PKG.CREATE_LAYERS_TUNNEL
----------------------------------------------------------------
DROP FUNCTION IF EXISTS    qgis_pkg.create_layers_tunnel(varchar, varchar, integer, integer, numeric, numeric[], boolean) CASCADE;
CREATE OR REPLACE FUNCTION qgis_pkg.create_layers_tunnel(
usr_name            varchar,
cdb_schema 			varchar,
perform_snapping 	integer   DEFAULT 0,
digits 				integer	  DEFAULT 3,
area_poly_min 		numeric   DEFAULT 0.0001,
bbox_corners_array	numeric[] DEFAULT NULL,
force_layer_creation boolean  DEFAULT FALSE
)
RETURNS void AS $$
DECLARE
sql_statement 	text := NULL;
mview_bbox 		geometry(Polygon) := NULL;

BEGIN
mview_bbox := qgis_pkg.generate_mview_bbox_poly(cdb_schema, bbox_corners_array);

sql_statement := qgis_pkg.generate_sql_layers_tunnel(
	usr_name             := usr_name, 
	cdb_schema 			 := cdb_schema, 			
    perform_snapping 	 := perform_snapping, 	
	digits 				 := digits, 				
	area_poly_min 		 := area_poly_min, 		
	mview_bbox			 := mview_bbox,			
	force_layer_creation := force_layer_creation
);

IF sql_statement IS NOT NULL THEN
	EXECUTE sql_statement;
END IF;

EXCEPTION
	WHEN QUERY_CANCELED THEN
		RAISE EXCEPTION 'qgis_pkg.create_layers_tunnel(): Error QUERY_CANCELED';
	WHEN OTHERS THEN
		RAISE EXCEPTION 'qgis_pkg.create_layers_tunnel(): %', SQLERRM;
END;
$$ LANGUAGE plpgsql;
COMMENT ON FUNCTION qgis_pkg.create_layers_tunnel(varchar, varchar, integer, integer, numeric, numeric[], boolean) IS 'Create "Tunnel" layers (associated to a cdb_schema) in selected usr_schema';
REVOKE EXECUTE ON FUNCTION qgis_pkg.create_layers_tunnel(varchar, varchar, integer, integer, numeric, numeric[], boolean) FROM public;

----------------------------------------------------------------
-- Create FUNCTION QGIS_PKG.GENERATE_SQL_DROP_LAYERS_TUNNEL
----------------------------------------------------------------
-- Generates SQL to drop layers (e.g. mviews, views and associated triggers)
DROP FUNCTION IF EXISTS    qgis_pkg.generate_sql_drop_layers_tunnel(varchar, varchar) CASCADE;
CREATE OR REPLACE FUNCTION qgis_pkg.generate_sql_drop_layers_tunnel(
usr_schema		varchar,
cdb_schema		varchar
)
RETURNS text
AS $$
DECLARE
feature_type			CONSTANT varchar := 'Tunnel';
regexp_string			CONSTANT varchar := '^(tun).*';
mv_prefix				CONSTANT varchar := '_g_';
mv_cdb_schema_pos		CONSTANT integer := length(mv_prefix) + 1;
mv_feat_type_pos		CONSTANT integer := mv_cdb_schema_pos + length(cdb_schema) + 1;
usr_schemas_array		CONSTANT varchar[] := (SELECT array_agg(s.usr_schema) FROM qgis_pkg.list_usr_schemas() AS s);
cdb_schemas_array		CONSTANT varchar[] := (SELECT array_agg(d.cdb_schema) FROM qgis_pkg.list_cdb_schemas() AS d);
feat_type_prefix		varchar;
sql_statement			text := NULL;
r RECORD;

BEGIN
-- Check that the usr_schema exists
IF usr_schema IS NULL OR (NOT usr_schema = ANY(usr_schemas_array)) THEN
	RAISE EXCEPTION 'usr_schema value is invalid. It must correspond to an existing usr_schema';
END IF;

-- Check that the cdb_schema exists
IF cdb_schema IS NULL OR (NOT cdb_schema = ANY(cdb_schemas_array)) THEN
	RAISE EXCEPTION 'cdb_schema value is invalid. It must correspond to an existing cdb_schema';
END IF;

FOR r IN 
	SELECT mv.matviewname AS mv_name FROM pg_matviews AS mv
	WHERE
		mv.schemaname::varchar = usr_schema
		AND substring(mv.matviewname, mv_cdb_schema_pos) LIKE concat(cdb_schema, '%')		
		AND substring(mv.matviewname, mv_feat_type_pos) ~ regexp_string	
	ORDER BY mv.matviewname ASC
LOOP
	sql_statement := concat(sql_statement, format('
DROP MATERIALIZED VIEW %I.%I CASCADE;',
usr_schema, r.mv_name));

END LOOP;

-- Delete entries from table layer_metadata
IF sql_statement IS NOT NULL THEN
	sql_statement := concat(sql_statement, format('
DELETE FROM %I.layer_metadata AS l WHERE l.cdb_schema = %L AND l.feature_type = %L;',
	usr_schema, cdb_schema, feature_type));
END IF;

RETURN sql_statement;

EXCEPTION
	WHEN QUERY_CANCELED THEN
		RAISE EXCEPTION 'qgis_pkg.generate_sql_drop_layers_tunnel(): Error QUERY_CANCELED';
  WHEN OTHERS THEN 
		RAISE NOTICE 'qgis_pkg.generate_sql_drop_layers_tunnel(): %', SQLERRM;
END;
$$ LANGUAGE plpgsql;
COMMENT ON FUNCTION qgis_pkg.generate_sql_drop_layers_tunnel(varchar, varchar) IS 'Genereate SQL to drop "Tunnel" layers (associated to a cdb_schema) in selected usr_schema';
REVOKE EXECUTE ON FUNCTION qgis_pkg.generate_sql_drop_layers_tunnel(varchar, varchar) FROM public;

----------------------------------------------------------------
-- Create FUNCTION QGIS_PKG.DROP_LAYERS_TUNNEL
----------------------------------------------------------------
-- Generates SQL to drops layers (e.g. mviews, views, and associated triggers)
DROP FUNCTION IF EXISTS    qgis_pkg.drop_layers_tunnel(varchar, varchar) CASCADE;
CREATE OR REPLACE FUNCTION qgis_pkg.drop_layers_tunnel(
usr_schema		varchar,
cdb_schema		varchar
)
RETURNS void
AS $$
DECLARE
sql_statement text := NULL;

BEGIN
sql_statement := qgis_pkg.generate_sql_drop_layers_tunnel(usr_schema, cdb_schema); 

IF sql_statement IS NOT NULL THEN
	EXECUTE sql_statement;
END IF;

EXCEPTION
	WHEN QUERY_CANCELED THEN
		RAISE EXCEPTION 'qgis_pkg.drop_layers_tunnel(): Error QUERY_CANCELED';
  WHEN OTHERS THEN 
		RAISE NOTICE 'qgis_pkg.drop_layers_tunnel(): %', SQLERRM;
END;
$$ LANGUAGE plpgsql;
COMMENT ON FUNCTION qgis_pkg.drop_layers_tunnel(varchar, varchar) IS 'Drop "Tunnel" layers (associated to a cdb_schema) in selected usr_schema';
REVOKE EXECUTE ON FUNCTION qgis_pkg.drop_layers_tunnel(varchar, varchar) FROM public;

----------------------------------------------------------------
-- Create FUNCTION QGIS_PKG.REFRESH_MVIEWS_TUNNEL
----------------------------------------------------------------
DROP FUNCTION IF EXISTS    qgis_pkg.refresh_mviews_tunnel(varchar, varchar) CASCADE;
CREATE OR REPLACE FUNCTION qgis_pkg.refresh_mviews_tunnel(
usr_schema	varchar,
cdb_schema	varchar
)
RETURNS void AS $$
DECLARE
regexp_string			CONSTANT varchar := '^(tun).*';
mv_prefix				CONSTANT varchar := '_g_';
mv_cdb_schema_pos		CONSTANT integer := length(mv_prefix) + 1;
mv_feat_type_pos		CONSTANT integer := mv_cdb_schema_pos + length(cdb_schema) + 1;
usr_schemas_array 		CONSTANT varchar[] := (SELECT array_agg(s.usr_schema) FROM qgis_pkg.list_usr_schemas() AS s);
cdb_schemas_array 		CONSTANT varchar[] := (SELECT array_agg(d.cdb_schema) FROM qgis_pkg.list_cdb_schemas() AS d);
feat_type_prefix        varchar;
start_timestamp 		timestamptz(3);
stop_timestamp 			timestamptz(3);
f_start_timestamp 		timestamptz(3);
f_stop_timestamp 		timestamptz(3);
mv_n_features 			integer DEFAULT 0;
r 						RECORD;

BEGIN

-- Check that the usr_schema exists
IF usr_schema IS NULL OR (NOT usr_schema = ANY(usr_schemas_array)) THEN
	RAISE EXCEPTION 'usr_schema value is invalid. It must correspond to an existing usr_schema';
END IF;

-- Check that the cdb_schema exists
IF cdb_schema IS NULL OR (NOT cdb_schema = ANY(cdb_schemas_array)) THEN
	RAISE EXCEPTION 'cdb_schema value is invalid. It must correspond to an existing cdb_schema';
END IF;

f_start_timestamp := clock_timestamp();

RAISE NOTICE 'Refreshing "Tunnel" materialized views in usr_schema "%" associated to cdb_schema "%"', usr_schema, cdb_schema;		

FOR r IN 
	SELECT mv.matviewname AS mv_name FROM pg_matviews AS mv
	WHERE
		mv.schemaname::varchar = usr_schema
		AND substring(mv.matviewname, mv_cdb_schema_pos) LIKE concat(cdb_schema, '%')		
		AND substring(mv.matviewname, mv_feat_type_pos) ~ regexp_string			
	ORDER BY mv.matviewname ASC
LOOP
	start_timestamp := clock_timestamp();
	EXECUTE format('REFRESH MATERIALIZED VIEW %I.%I', usr_schema, r.mv_name);
	stop_timestamp := clock_timestamp();
	EXECUTE format('SELECT count(co_id) FROM %I.%I', usr_schema, r.mv_name) INTO mv_n_features;
	EXECUTE format('UPDATE %I.layer_metadata AS lm SET n_features = %L, refresh_date  = %L WHERE lm.mv_name = %L;',
		usr_schema, mv_n_features, stop_timestamp, r.mv_name);				
	RAISE NOTICE 'Refreshed materialized view "%"."%" in %', usr_schema, r.mv_name, stop_timestamp-start_timestamp; 
END LOOP;

f_stop_timestamp := clock_timestamp();		
RAISE NOTICE 'All "Tunnel" materialized views in usr_schema "%" associated to cdb_schema "%" refreshed in %', usr_schema, cdb_schema, f_stop_timestamp-f_start_timestamp; 	

EXCEPTION
	WHEN QUERY_CANCELED THEN
		RAISE EXCEPTION 'qgis_pkg.refresh_mviews_tunnel(): Error QUERY_CANCELED';
  WHEN OTHERS THEN 
		RAISE NOTICE 'qgis_pkg.refresh_mviews_tunnel(): %', SQLERRM;
END;
$$ LANGUAGE plpgsql;
COMMENT ON FUNCTION qgis_pkg.refresh_mviews_tunnel(varchar, varchar) IS 'Refresh "Tunnel" materialized views (associated to a cdb_schema) in selected usr_schema';
REVOKE EXECUTE ON FUNCTION qgis_pkg.refresh_mviews_tunnel(varchar, varchar) FROM public;

----------------------------------------------------------------
-- Create FUNCTION QGIS_PKG.CREATE_LAYERS_VEGETATION
----------------------------------------------------------------
DROP FUNCTION IF EXISTS    qgis_pkg.create_layers_vegetation(varchar, varchar, integer, integer, numeric, numeric[], boolean) CASCADE;
CREATE OR REPLACE FUNCTION qgis_pkg.create_layers_vegetation(
usr_name            varchar,
cdb_schema 			varchar,
perform_snapping 	integer   DEFAULT 0,
digits 				integer	  DEFAULT 3,
area_poly_min 		numeric   DEFAULT 0.0001,
bbox_corners_array	numeric[] DEFAULT NULL,
force_layer_creation boolean  DEFAULT FALSE
)
RETURNS void AS $$
DECLARE
sql_statement 	text := NULL;
mview_bbox 		geometry(Polygon) := NULL;

BEGIN
mview_bbox := qgis_pkg.generate_mview_bbox_poly(cdb_schema, bbox_corners_array);

sql_statement := qgis_pkg.generate_sql_layers_vegetation(
	usr_name             := usr_name, 
	cdb_schema 			 := cdb_schema, 			
    perform_snapping 	 := perform_snapping, 	
	digits 				 := digits, 				
	area_poly_min 		 := area_poly_min, 		
	mview_bbox			 := mview_bbox,			
	force_layer_creation := force_layer_creation
);

IF sql_statement IS NOT NULL THEN
	EXECUTE sql_statement;
END IF;

EXCEPTION
	WHEN QUERY_CANCELED THEN
		RAISE EXCEPTION 'qgis_pkg.create_layers_vegetation(): Error QUERY_CANCELED';
	WHEN OTHERS THEN
		RAISE EXCEPTION 'qgis_pkg.create_layers_vegetation(): %', SQLERRM;
END;
$$ LANGUAGE plpgsql;
COMMENT ON FUNCTION qgis_pkg.create_layers_vegetation(varchar, varchar, integer, integer, numeric, numeric[], boolean) IS 'Create "Vegetation" layers (associated to a cdb_schema) in selected usr_schema';
REVOKE EXECUTE ON FUNCTION qgis_pkg.create_layers_vegetation(varchar, varchar, integer, integer, numeric, numeric[], boolean) FROM public;

----------------------------------------------------------------
-- Create FUNCTION QGIS_PKG.GENERATE_SQL_DROP_LAYERS_VEGETATION
----------------------------------------------------------------
-- Generates SQL to drop layers (e.g. mviews, views and associated triggers)
DROP FUNCTION IF EXISTS    qgis_pkg.generate_sql_drop_layers_vegetation(varchar, varchar) CASCADE;
CREATE OR REPLACE FUNCTION qgis_pkg.generate_sql_drop_layers_vegetation(
usr_schema		varchar,
cdb_schema		varchar
)
RETURNS text
AS $$
DECLARE
feature_type			CONSTANT varchar := 'Vegetation';
regexp_string			CONSTANT varchar := '^(sol_veg_obj|plant_cover).*';
mv_prefix				CONSTANT varchar := '_g_';
mv_cdb_schema_pos		CONSTANT integer := length(mv_prefix) + 1;
mv_feat_type_pos		CONSTANT integer := mv_cdb_schema_pos + length(cdb_schema) + 1;
usr_schemas_array		CONSTANT varchar[] := (SELECT array_agg(s.usr_schema) FROM qgis_pkg.list_usr_schemas() AS s);
cdb_schemas_array		CONSTANT varchar[] := (SELECT array_agg(d.cdb_schema) FROM qgis_pkg.list_cdb_schemas() AS d);
feat_type_prefix		varchar;
sql_statement			text := NULL;
r RECORD;

BEGIN
-- Check that the usr_schema exists
IF usr_schema IS NULL OR (NOT usr_schema = ANY(usr_schemas_array)) THEN
	RAISE EXCEPTION 'usr_schema value is invalid. It must correspond to an existing usr_schema';
END IF;

-- Check that the cdb_schema exists
IF cdb_schema IS NULL OR (NOT cdb_schema = ANY(cdb_schemas_array)) THEN
	RAISE EXCEPTION 'cdb_schema value is invalid. It must correspond to an existing cdb_schema';
END IF;

FOR r IN 
	SELECT mv.matviewname AS mv_name FROM pg_matviews AS mv
	WHERE
		mv.schemaname::varchar = usr_schema
		AND substring(mv.matviewname, mv_cdb_schema_pos) LIKE concat(cdb_schema, '%')		
		AND substring(mv.matviewname, mv_feat_type_pos) ~ regexp_string	
	ORDER BY mv.matviewname ASC
LOOP
	sql_statement := concat(sql_statement, format('
DROP MATERIALIZED VIEW %I.%I CASCADE;',
usr_schema, r.mv_name));

END LOOP;

-- Delete entries from table layer_metadata
IF sql_statement IS NOT NULL THEN
	sql_statement := concat(sql_statement, format('
DELETE FROM %I.layer_metadata AS l WHERE l.cdb_schema = %L AND l.feature_type = %L;',
	usr_schema, cdb_schema, feature_type));
END IF;

RETURN sql_statement;

EXCEPTION
	WHEN QUERY_CANCELED THEN
		RAISE EXCEPTION 'qgis_pkg.generate_sql_drop_layers_vegetation(): Error QUERY_CANCELED';
  WHEN OTHERS THEN 
		RAISE NOTICE 'qgis_pkg.generate_sql_drop_layers_vegetation(): %', SQLERRM;
END;
$$ LANGUAGE plpgsql;
COMMENT ON FUNCTION qgis_pkg.generate_sql_drop_layers_vegetation(varchar, varchar) IS 'Genereate SQL to drop "Vegetation" layers (associated to a cdb_schema) in selected usr_schema';
REVOKE EXECUTE ON FUNCTION qgis_pkg.generate_sql_drop_layers_vegetation(varchar, varchar) FROM public;

----------------------------------------------------------------
-- Create FUNCTION QGIS_PKG.DROP_LAYERS_VEGETATION
----------------------------------------------------------------
-- Generates SQL to drops layers (e.g. mviews, views, and associated triggers)
DROP FUNCTION IF EXISTS    qgis_pkg.drop_layers_vegetation(varchar, varchar) CASCADE;
CREATE OR REPLACE FUNCTION qgis_pkg.drop_layers_vegetation(
usr_schema		varchar,
cdb_schema		varchar
)
RETURNS void
AS $$
DECLARE
sql_statement text := NULL;

BEGIN
sql_statement := qgis_pkg.generate_sql_drop_layers_vegetation(usr_schema, cdb_schema); 

IF sql_statement IS NOT NULL THEN
	EXECUTE sql_statement;
END IF;

EXCEPTION
	WHEN QUERY_CANCELED THEN
		RAISE EXCEPTION 'qgis_pkg.drop_layers_vegetation(): Error QUERY_CANCELED';
  WHEN OTHERS THEN 
		RAISE NOTICE 'qgis_pkg.drop_layers_vegetation(): %', SQLERRM;
END;
$$ LANGUAGE plpgsql;
COMMENT ON FUNCTION qgis_pkg.drop_layers_vegetation(varchar, varchar) IS 'Drop "Vegetation" layers (associated to a cdb_schema) in selected usr_schema';
REVOKE EXECUTE ON FUNCTION qgis_pkg.drop_layers_vegetation(varchar, varchar) FROM public;

----------------------------------------------------------------
-- Create FUNCTION QGIS_PKG.REFRESH_MVIEWS_VEGETATION
----------------------------------------------------------------
DROP FUNCTION IF EXISTS    qgis_pkg.refresh_mviews_vegetation(varchar, varchar) CASCADE;
CREATE OR REPLACE FUNCTION qgis_pkg.refresh_mviews_vegetation(
usr_schema	varchar,
cdb_schema	varchar
)
RETURNS void AS $$
DECLARE
regexp_string			CONSTANT varchar := '^(sol_veg_obj|plant_cover).*';
mv_prefix				CONSTANT varchar := '_g_';
mv_cdb_schema_pos		CONSTANT integer := length(mv_prefix) + 1;
mv_feat_type_pos		CONSTANT integer := mv_cdb_schema_pos + length(cdb_schema) + 1;
usr_schemas_array 		CONSTANT varchar[] := (SELECT array_agg(s.usr_schema) FROM qgis_pkg.list_usr_schemas() AS s);
cdb_schemas_array 		CONSTANT varchar[] := (SELECT array_agg(d.cdb_schema) FROM qgis_pkg.list_cdb_schemas() AS d);
feat_type_prefix        varchar;
start_timestamp 		timestamptz(3);
stop_timestamp 			timestamptz(3);
f_start_timestamp 		timestamptz(3);
f_stop_timestamp 		timestamptz(3);
mv_n_features 			integer DEFAULT 0;
r 						RECORD;

BEGIN

-- Check that the usr_schema exists
IF usr_schema IS NULL OR (NOT usr_schema = ANY(usr_schemas_array)) THEN
	RAISE EXCEPTION 'usr_schema value is invalid. It must correspond to an existing usr_schema';
END IF;

-- Check that the cdb_schema exists
IF cdb_schema IS NULL OR (NOT cdb_schema = ANY(cdb_schemas_array)) THEN
	RAISE EXCEPTION 'cdb_schema value is invalid. It must correspond to an existing cdb_schema';
END IF;

f_start_timestamp := clock_timestamp();

RAISE NOTICE 'Refreshing "Vegetation" materialized views in usr_schema "%" associated to cdb_schema "%"', usr_schema, cdb_schema;		

FOR r IN 
	SELECT mv.matviewname AS mv_name FROM pg_matviews AS mv
	WHERE
		mv.schemaname::varchar = usr_schema
		AND substring(mv.matviewname, mv_cdb_schema_pos) LIKE concat(cdb_schema, '%')		
		AND substring(mv.matviewname, mv_feat_type_pos) ~ regexp_string			
	ORDER BY mv.matviewname ASC
LOOP
	start_timestamp := clock_timestamp();
	EXECUTE format('REFRESH MATERIALIZED VIEW %I.%I', usr_schema, r.mv_name);
	stop_timestamp := clock_timestamp();
	EXECUTE format('SELECT count(co_id) FROM %I.%I', usr_schema, r.mv_name) INTO mv_n_features;
	EXECUTE format('UPDATE %I.layer_metadata AS lm SET n_features = %L, refresh_date  = %L WHERE lm.mv_name = %L;',
		usr_schema, mv_n_features, stop_timestamp, r.mv_name);				
	RAISE NOTICE 'Refreshed materialized view "%"."%" in %', usr_schema, r.mv_name, stop_timestamp-start_timestamp; 
END LOOP;

f_stop_timestamp := clock_timestamp();		
RAISE NOTICE 'All "Vegetation" materialized views in usr_schema "%" associated to cdb_schema "%" refreshed in %', usr_schema, cdb_schema, f_stop_timestamp-f_start_timestamp; 	

EXCEPTION
	WHEN QUERY_CANCELED THEN
		RAISE EXCEPTION 'qgis_pkg.refresh_mviews_vegetation(): Error QUERY_CANCELED';
  WHEN OTHERS THEN 
		RAISE NOTICE 'qgis_pkg.refresh_mviews_vegetation(): %', SQLERRM;
END;
$$ LANGUAGE plpgsql;
COMMENT ON FUNCTION qgis_pkg.refresh_mviews_vegetation(varchar, varchar) IS 'Refresh "Vegetation" materialized views (associated to a cdb_schema) in selected usr_schema';
REVOKE EXECUTE ON FUNCTION qgis_pkg.refresh_mviews_vegetation(varchar, varchar) FROM public;

----------------------------------------------------------------
-- Create FUNCTION QGIS_PKG.CREATE_LAYERS_WATERBODY
----------------------------------------------------------------
DROP FUNCTION IF EXISTS    qgis_pkg.create_layers_waterbody(varchar, varchar, integer, integer, numeric, numeric[], boolean) CASCADE;
CREATE OR REPLACE FUNCTION qgis_pkg.create_layers_waterbody(
usr_name            varchar,
cdb_schema 			varchar,
perform_snapping 	integer   DEFAULT 0,
digits 				integer	  DEFAULT 3,
area_poly_min 		numeric   DEFAULT 0.0001,
bbox_corners_array	numeric[] DEFAULT NULL,
force_layer_creation boolean  DEFAULT FALSE
)
RETURNS void AS $$
DECLARE
sql_statement 	text := NULL;
mview_bbox 		geometry(Polygon) := NULL;

BEGIN
mview_bbox := qgis_pkg.generate_mview_bbox_poly(cdb_schema, bbox_corners_array);

sql_statement := qgis_pkg.generate_sql_layers_waterbody(
	usr_name             := usr_name, 
	cdb_schema 			 := cdb_schema, 			
    perform_snapping 	 := perform_snapping, 	
	digits 				 := digits, 				
	area_poly_min 		 := area_poly_min, 		
	mview_bbox			 := mview_bbox,			
	force_layer_creation := force_layer_creation
);

IF sql_statement IS NOT NULL THEN
	EXECUTE sql_statement;
END IF;

EXCEPTION
	WHEN QUERY_CANCELED THEN
		RAISE EXCEPTION 'qgis_pkg.create_layers_waterbody(): Error QUERY_CANCELED';
	WHEN OTHERS THEN
		RAISE EXCEPTION 'qgis_pkg.create_layers_waterbody(): %', SQLERRM;
END;
$$ LANGUAGE plpgsql;
COMMENT ON FUNCTION qgis_pkg.create_layers_waterbody(varchar, varchar, integer, integer, numeric, numeric[], boolean) IS 'Create "WaterBody" layers (associated to a cdb_schema) in selected usr_schema';
REVOKE EXECUTE ON FUNCTION qgis_pkg.create_layers_waterbody(varchar, varchar, integer, integer, numeric, numeric[], boolean) FROM public;

----------------------------------------------------------------
-- Create FUNCTION QGIS_PKG.GENERATE_SQL_DROP_LAYERS_WATERBODY
----------------------------------------------------------------
-- Generates SQL to drop layers (e.g. mviews, views and associated triggers)
DROP FUNCTION IF EXISTS    qgis_pkg.generate_sql_drop_layers_waterbody(varchar, varchar) CASCADE;
CREATE OR REPLACE FUNCTION qgis_pkg.generate_sql_drop_layers_waterbody(
usr_schema		varchar,
cdb_schema		varchar
)
RETURNS text
AS $$
DECLARE
feature_type			CONSTANT varchar := 'WaterBody';
regexp_string			CONSTANT varchar := '^(waterbody).*';
mv_prefix				CONSTANT varchar := '_g_';
mv_cdb_schema_pos		CONSTANT integer := length(mv_prefix) + 1;
mv_feat_type_pos		CONSTANT integer := mv_cdb_schema_pos + length(cdb_schema) + 1;
usr_schemas_array		CONSTANT varchar[] := (SELECT array_agg(s.usr_schema) FROM qgis_pkg.list_usr_schemas() AS s);
cdb_schemas_array		CONSTANT varchar[] := (SELECT array_agg(d.cdb_schema) FROM qgis_pkg.list_cdb_schemas() AS d);
feat_type_prefix		varchar;
sql_statement			text := NULL;
r RECORD;

BEGIN
-- Check that the usr_schema exists
IF usr_schema IS NULL OR (NOT usr_schema = ANY(usr_schemas_array)) THEN
	RAISE EXCEPTION 'usr_schema value is invalid. It must correspond to an existing usr_schema';
END IF;

-- Check that the cdb_schema exists
IF cdb_schema IS NULL OR (NOT cdb_schema = ANY(cdb_schemas_array)) THEN
	RAISE EXCEPTION 'cdb_schema value is invalid. It must correspond to an existing cdb_schema';
END IF;

FOR r IN 
	SELECT mv.matviewname AS mv_name FROM pg_matviews AS mv
	WHERE
		mv.schemaname::varchar = usr_schema
		AND substring(mv.matviewname, mv_cdb_schema_pos) LIKE concat(cdb_schema, '%')		
		AND substring(mv.matviewname, mv_feat_type_pos) ~ regexp_string	
	ORDER BY mv.matviewname ASC
LOOP
	sql_statement := concat(sql_statement, format('
DROP MATERIALIZED VIEW %I.%I CASCADE;',
usr_schema, r.mv_name));

END LOOP;

-- Delete entries from table layer_metadata
IF sql_statement IS NOT NULL THEN
	sql_statement := concat(sql_statement, format('
DELETE FROM %I.layer_metadata AS l WHERE l.cdb_schema = %L AND l.feature_type = %L;',
	usr_schema, cdb_schema, feature_type));
END IF;

RETURN sql_statement;

EXCEPTION
	WHEN QUERY_CANCELED THEN
		RAISE EXCEPTION 'qgis_pkg.generate_sql_drop_layers_waterbody(): Error QUERY_CANCELED';
  WHEN OTHERS THEN 
		RAISE NOTICE 'qgis_pkg.generate_sql_drop_layers_waterbody(): %', SQLERRM;
END;
$$ LANGUAGE plpgsql;
COMMENT ON FUNCTION qgis_pkg.generate_sql_drop_layers_waterbody(varchar, varchar) IS 'Genereate SQL to drop "WaterBody" layers (associated to a cdb_schema) in selected usr_schema';
REVOKE EXECUTE ON FUNCTION qgis_pkg.generate_sql_drop_layers_waterbody(varchar, varchar) FROM public;

----------------------------------------------------------------
-- Create FUNCTION QGIS_PKG.DROP_LAYERS_WATERBODY
----------------------------------------------------------------
-- Generates SQL to drops layers (e.g. mviews, views, and associated triggers)
DROP FUNCTION IF EXISTS    qgis_pkg.drop_layers_waterbody(varchar, varchar) CASCADE;
CREATE OR REPLACE FUNCTION qgis_pkg.drop_layers_waterbody(
usr_schema		varchar,
cdb_schema		varchar
)
RETURNS void
AS $$
DECLARE
sql_statement text := NULL;

BEGIN
sql_statement := qgis_pkg.generate_sql_drop_layers_waterbody(usr_schema, cdb_schema); 

IF sql_statement IS NOT NULL THEN
	EXECUTE sql_statement;
END IF;

EXCEPTION
	WHEN QUERY_CANCELED THEN
		RAISE EXCEPTION 'qgis_pkg.drop_layers_waterbody(): Error QUERY_CANCELED';
  WHEN OTHERS THEN 
		RAISE NOTICE 'qgis_pkg.drop_layers_waterbody(): %', SQLERRM;
END;
$$ LANGUAGE plpgsql;
COMMENT ON FUNCTION qgis_pkg.drop_layers_waterbody(varchar, varchar) IS 'Drop "WaterBody" layers (associated to a cdb_schema) in selected usr_schema';
REVOKE EXECUTE ON FUNCTION qgis_pkg.drop_layers_waterbody(varchar, varchar) FROM public;

----------------------------------------------------------------
-- Create FUNCTION QGIS_PKG.REFRESH_MVIEWS_WATERBODY
----------------------------------------------------------------
DROP FUNCTION IF EXISTS    qgis_pkg.refresh_mviews_waterbody(varchar, varchar) CASCADE;
CREATE OR REPLACE FUNCTION qgis_pkg.refresh_mviews_waterbody(
usr_schema	varchar,
cdb_schema	varchar
)
RETURNS void AS $$
DECLARE
regexp_string			CONSTANT varchar := '^(waterbody).*';
mv_prefix				CONSTANT varchar := '_g_';
mv_cdb_schema_pos		CONSTANT integer := length(mv_prefix) + 1;
mv_feat_type_pos		CONSTANT integer := mv_cdb_schema_pos + length(cdb_schema) + 1;
usr_schemas_array 		CONSTANT varchar[] := (SELECT array_agg(s.usr_schema) FROM qgis_pkg.list_usr_schemas() AS s);
cdb_schemas_array 		CONSTANT varchar[] := (SELECT array_agg(d.cdb_schema) FROM qgis_pkg.list_cdb_schemas() AS d);
feat_type_prefix        varchar;
start_timestamp 		timestamptz(3);
stop_timestamp 			timestamptz(3);
f_start_timestamp 		timestamptz(3);
f_stop_timestamp 		timestamptz(3);
mv_n_features 			integer DEFAULT 0;
r 						RECORD;

BEGIN

-- Check that the usr_schema exists
IF usr_schema IS NULL OR (NOT usr_schema = ANY(usr_schemas_array)) THEN
	RAISE EXCEPTION 'usr_schema value is invalid. It must correspond to an existing usr_schema';
END IF;

-- Check that the cdb_schema exists
IF cdb_schema IS NULL OR (NOT cdb_schema = ANY(cdb_schemas_array)) THEN
	RAISE EXCEPTION 'cdb_schema value is invalid. It must correspond to an existing cdb_schema';
END IF;

f_start_timestamp := clock_timestamp();

RAISE NOTICE 'Refreshing "WaterBody" materialized views in usr_schema "%" associated to cdb_schema "%"', usr_schema, cdb_schema;		

FOR r IN 
	SELECT mv.matviewname AS mv_name FROM pg_matviews AS mv
	WHERE
		mv.schemaname::varchar = usr_schema
		AND substring(mv.matviewname, mv_cdb_schema_pos) LIKE concat(cdb_schema, '%')		
		AND substring(mv.matviewname, mv_feat_type_pos) ~ regexp_string			
	ORDER BY mv.matviewname ASC
LOOP
	start_timestamp := clock_timestamp();
	EXECUTE format('REFRESH MATERIALIZED VIEW %I.%I', usr_schema, r.mv_name);
	stop_timestamp := clock_timestamp();
	EXECUTE format('SELECT count(co_id) FROM %I.%I', usr_schema, r.mv_name) INTO mv_n_features;
	EXECUTE format('UPDATE %I.layer_metadata AS lm SET n_features = %L, refresh_date  = %L WHERE lm.mv_name = %L;',
		usr_schema, mv_n_features, stop_timestamp, r.mv_name);				
	RAISE NOTICE 'Refreshed materialized view "%"."%" in %', usr_schema, r.mv_name, stop_timestamp-start_timestamp; 
END LOOP;

f_stop_timestamp := clock_timestamp();		
RAISE NOTICE 'All "WaterBody" materialized views in usr_schema "%" associated to cdb_schema "%" refreshed in %', usr_schema, cdb_schema, f_stop_timestamp-f_start_timestamp; 	

EXCEPTION
	WHEN QUERY_CANCELED THEN
		RAISE EXCEPTION 'qgis_pkg.refresh_mviews_waterbody(): Error QUERY_CANCELED';
  WHEN OTHERS THEN 
		RAISE NOTICE 'qgis_pkg.refresh_mviews_waterbody(): %', SQLERRM;
END;
$$ LANGUAGE plpgsql;
COMMENT ON FUNCTION qgis_pkg.refresh_mviews_waterbody(varchar, varchar) IS 'Refresh "WaterBody" materialized views (associated to a cdb_schema) in selected usr_schema';
REVOKE EXECUTE ON FUNCTION qgis_pkg.refresh_mviews_waterbody(varchar, varchar) FROM public;

----------------------------------------------------------------
-- Create FUNCTION QGIS_PKG.GENERATE_SQL_CREATE_LAYERS
----------------------------------------------------------------
-- Generates SQL to create layers (e.g. mviews, views, and associated triggers)
DROP FUNCTION IF EXISTS    qgis_pkg.generate_sql_create_layers(varchar, varchar, integer, integer, numeric, geometry, boolean) CASCADE;
CREATE OR REPLACE FUNCTION qgis_pkg.generate_sql_create_layers(
usr_name		     varchar,
cdb_schema		     varchar,
perform_snapping 	 integer,   
digits 				 integer,   
area_poly_min 		 numeric,   
mview_bbox			 geometry,  
force_layer_creation boolean   
)
RETURNS text
AS $$
DECLARE
sql_statement	text := NULL;

BEGIN

sql_statement := concat(sql_statement, qgis_pkg.generate_sql_layers_bridge(
	usr_name             := usr_name, 
	cdb_schema 			 := cdb_schema, 			
    perform_snapping 	 := perform_snapping, 	
	digits 				 := digits, 				
	area_poly_min 		 := area_poly_min, 		
	mview_bbox			 := mview_bbox,			
	force_layer_creation := force_layer_creation)
);

sql_statement := concat(sql_statement, qgis_pkg.generate_sql_layers_building(
	usr_name             := usr_name, 
	cdb_schema 			 := cdb_schema, 			
    perform_snapping 	 := perform_snapping, 	
	digits 				 := digits, 				
	area_poly_min 		 := area_poly_min, 		
	mview_bbox			 := mview_bbox,			
	force_layer_creation := force_layer_creation)
);

sql_statement := concat(sql_statement, qgis_pkg.generate_sql_layers_cityfurniture(
	usr_name             := usr_name, 
	cdb_schema 			 := cdb_schema, 			
    perform_snapping 	 := perform_snapping, 	
	digits 				 := digits, 				
	area_poly_min 		 := area_poly_min, 		
	mview_bbox			 := mview_bbox,			
	force_layer_creation := force_layer_creation)
);

sql_statement := concat(sql_statement, qgis_pkg.generate_sql_layers_cityfurniture(
	usr_name             := usr_name, 
	cdb_schema 			 := cdb_schema, 			
    perform_snapping 	 := perform_snapping, 	
	digits 				 := digits, 				
	area_poly_min 		 := area_poly_min, 		
	mview_bbox			 := mview_bbox,			
	force_layer_creation := force_layer_creation)
);

sql_statement := concat(sql_statement, qgis_pkg.generate_sql_layers_generics(
	usr_name             := usr_name, 
	cdb_schema 			 := cdb_schema, 			
    perform_snapping 	 := perform_snapping, 	
	digits 				 := digits, 				
	area_poly_min 		 := area_poly_min, 		
	mview_bbox			 := mview_bbox,			
	force_layer_creation := force_layer_creation)
);

sql_statement := concat(sql_statement, qgis_pkg.generate_sql_layers_landuse(
	usr_name             := usr_name, 
	cdb_schema 			 := cdb_schema, 			
    perform_snapping 	 := perform_snapping, 	
	digits 				 := digits, 				
	area_poly_min 		 := area_poly_min, 		
	mview_bbox			 := mview_bbox,			
	force_layer_creation := force_layer_creation)
);

sql_statement := concat(sql_statement, qgis_pkg.generate_sql_layers_relief(
	usr_name             := usr_name, 
	cdb_schema 			 := cdb_schema, 			
    perform_snapping 	 := perform_snapping, 	
	digits 				 := digits, 				
	area_poly_min 		 := area_poly_min, 		
	mview_bbox			 := mview_bbox,			
	force_layer_creation := force_layer_creation)
);

sql_statement := concat(sql_statement, qgis_pkg.generate_sql_layers_transportation(
	usr_name             := usr_name, 
	cdb_schema 			 := cdb_schema, 			
    perform_snapping 	 := perform_snapping, 	
	digits 				 := digits, 				
	area_poly_min 		 := area_poly_min, 		
	mview_bbox			 := mview_bbox,			
	force_layer_creation := force_layer_creation)
);

sql_statement := concat(sql_statement, qgis_pkg.generate_sql_layers_tunnel(
	usr_name             := usr_name, 
	cdb_schema 			 := cdb_schema, 			
    perform_snapping 	 := perform_snapping, 	
	digits 				 := digits, 				
	area_poly_min 		 := area_poly_min, 		
	mview_bbox			 := mview_bbox,			
	force_layer_creation := force_layer_creation)
);

sql_statement := concat(sql_statement, qgis_pkg.generate_sql_layers_vegetation(
	usr_name             := usr_name, 
	cdb_schema 			 := cdb_schema, 			
    perform_snapping 	 := perform_snapping, 	
	digits 				 := digits, 				
	area_poly_min 		 := area_poly_min, 		
	mview_bbox			 := mview_bbox,			
	force_layer_creation := force_layer_creation)
);

sql_statement := concat(sql_statement, qgis_pkg.generate_sql_layers_waterbody(
	usr_name             := usr_name, 
	cdb_schema 			 := cdb_schema, 			
    perform_snapping 	 := perform_snapping, 	
	digits 				 := digits, 				
	area_poly_min 		 := area_poly_min, 		
	mview_bbox			 := mview_bbox,			
	force_layer_creation := force_layer_creation)
);

RETURN sql_statement;

EXCEPTION
	WHEN QUERY_CANCELED THEN
		RAISE EXCEPTION 'qgis_pkg.generate_sql_create_layers(): Error QUERY_CANCELED';
  WHEN OTHERS THEN 
		RAISE NOTICE 'qgis_pkg.generate_sql_create_layers(): %', SQLERRM;
END;
$$ LANGUAGE plpgsql;
COMMENT ON FUNCTION qgis_pkg.generate_sql_create_layers(varchar, varchar, integer, integer, numeric, geometry, boolean) IS 'Genereate SQL to create layers in selected usr_schema associated to given cdb_schema';
REVOKE EXECUTE ON FUNCTION qgis_pkg.generate_sql_create_layers(varchar, varchar, integer, integer, numeric, geometry, boolean) FROM public;

----------------------------------------------------------------
-- Create FUNCTION QGIS_PKG.CREATE_LAYERS
----------------------------------------------------------------
-- Creates layers (e.g. mviews, views, and associated triggers)
DROP FUNCTION IF EXISTS    qgis_pkg.create_layers(varchar, varchar, integer, integer, numeric, numeric[], boolean) CASCADE;
CREATE OR REPLACE FUNCTION qgis_pkg.create_layers(
usr_name		varchar,
cdb_schema		varchar,
perform_snapping 	 integer   DEFAULT 0,
digits 				 integer   DEFAULT 3,
area_poly_min 		 numeric   DEFAULT 0.0001,
bbox_corners_array	 numeric[] DEFAULT NULL,
force_layer_creation boolean   DEFAULT FALSE
)
RETURNS void
AS $$
DECLARE
sql_statement text := NULL;
mview_bbox    geometry(Polygon) := NULL;

BEGIN

mview_bbox := qgis_pkg.generate_mview_bbox_poly(cdb_schema, bbox_corners_array);

sql_statement := qgis_pkg.generate_sql_create_layers(
	usr_name             := usr_name, 
	cdb_schema 			 := cdb_schema, 			
    perform_snapping 	 := perform_snapping, 	
	digits 				 := digits, 				
	area_poly_min 		 := area_poly_min, 		
	mview_bbox			 := mview_bbox,			
	force_layer_creation := force_layer_creation
);

IF sql_statement IS NOT NULL THEN
	EXECUTE sql_statement;
END IF;

EXCEPTION
	WHEN QUERY_CANCELED THEN
		RAISE EXCEPTION 'qgis_pkg.create_layers(): Error QUERY_CANCELED';
  WHEN OTHERS THEN 
		RAISE NOTICE 'qgis_pkg.create_layers(): %', SQLERRM;
END;
$$ LANGUAGE plpgsql;
COMMENT ON FUNCTION qgis_pkg.create_layers(varchar, varchar, integer, integer, numeric, numeric[], boolean) IS 'Create all layers in selected usr_schema associated to given cdb_schema';
REVOKE EXECUTE ON FUNCTION qgis_pkg.create_layers(varchar, varchar, integer, integer, numeric, numeric[], boolean) FROM public;

----------------------------------------------------------------
-- Create FUNCTION QGIS_PKG.REFRESH_MVIEWS
----------------------------------------------------------------
DROP FUNCTION IF EXISTS    qgis_pkg.refresh_mviews(varchar, varchar) CASCADE;
CREATE OR REPLACE FUNCTION qgis_pkg.refresh_mviews(
usr_schema	varchar,
cdb_schema	varchar
)
RETURNS void AS $$
DECLARE
mv_prefix				CONSTANT varchar := '_g_';
mv_cdb_schema_pos		CONSTANT integer := length(mv_prefix) + 1;
usr_schemas_array		CONSTANT varchar[] := (SELECT array_agg(s.usr_schema) FROM qgis_pkg.list_usr_schemas() AS s);
cdb_schemas_array		CONSTANT varchar[] := (SELECT array_agg(d.cdb_schema) FROM qgis_pkg.list_cdb_schemas() AS d);
start_timestamp 		timestamptz(3);
stop_timestamp 			timestamptz(3);
f_start_timestamp 		timestamptz(3);
f_stop_timestamp 		timestamptz(3);
mv_n_features 			integer DEFAULT 0;
r RECORD;

BEGIN

-- Check that the usr_schema is valid
IF usr_schema IS NULL OR (NOT usr_schema = ANY(usr_schemas_array)) THEN
	RAISE EXCEPTION 'usr_schema value is invalid. It must be correspond to an existing usr_schema';
END IF;

-- Check that the cdb_schema is valid
IF cdb_schema IS NULL OR (NOT cdb_schema = ANY(cdb_schemas_array)) THEN
	RAISE EXCEPTION 'cdb_schema value is invalid. It must be either NULL or correspond to an existing cdb_schema';
END IF;

f_start_timestamp := clock_timestamp();

RAISE NOTICE 'Refreshing all materialized views in usr_schema "%" associated to cdb_schema "%"', usr_schema, cdb_schema;		
FOR r IN 
	SELECT mv.matviewname AS mv_name FROM pg_matviews AS mv
	WHERE 
		mv.schemaname::varchar = usr_schema
		AND substring(mv.matviewname, mv_cdb_schema_pos) LIKE concat(cdb_schema, '%')	
	ORDER BY mv.matviewname ASC
LOOP
	start_timestamp := clock_timestamp();
	EXECUTE format('REFRESH MATERIALIZED VIEW %I.%I;', usr_schema, r.mv_name);
	stop_timestamp := clock_timestamp();
	EXECUTE format('SELECT count(co_id) FROM %I.%I;', usr_schema, r.mv_name) INTO mv_n_features;
	EXECUTE format('UPDATE %I.layer_metadata AS lm SET n_features = %L, refresh_date = %L WHERE lm.mv_name = %L;'
		,usr_schema, mv_n_features, stop_timestamp, r.mv_name);				
	RAISE NOTICE 'Materialized view "%"."%" refreshed in %', usr_schema, r.mv_name, stop_timestamp-start_timestamp; 
END LOOP;

f_stop_timestamp := clock_timestamp();		
RAISE NOTICE 'All materialized views in usr_schema "%" associated to cdb_schema "%" refreshed in %', usr_schema, cdb_schema, f_stop_timestamp-f_start_timestamp; 	

EXCEPTION
	WHEN QUERY_CANCELED THEN
		RAISE EXCEPTION 'qgis_pkg.refresh_mviews(): Error QUERY_CANCELED';
  WHEN OTHERS THEN 
		RAISE NOTICE 'qgis_pkg.refresh_mviews(): %', SQLERRM;
END;
$$ LANGUAGE plpgsql;
COMMENT ON FUNCTION qgis_pkg.refresh_mviews(varchar, varchar) IS 'Refresh materialized views in usr_schema';
REVOKE EXECUTE ON FUNCTION qgis_pkg.refresh_mviews(varchar, varchar) FROM public;

----------------------------------------------------------------
-- Create FUNCTION QGIS_PKG.GENERATE_SQL_DROP_LAYERS
----------------------------------------------------------------
-- Generates SQL to drops layers (e.g. mviews, views, and associated triggers)
DROP FUNCTION IF EXISTS    qgis_pkg.generate_sql_drop_layers(varchar, varchar) CASCADE;
CREATE OR REPLACE FUNCTION qgis_pkg.generate_sql_drop_layers(
usr_schema		varchar,
cdb_schema		varchar
)
RETURNS text
AS $$
DECLARE
mv_prefix			CONSTANT varchar := '_g_';
mv_cdb_schema_pos	CONSTANT integer := length(mv_prefix) + 1;
usr_schemas_array 	CONSTANT varchar[] := (SELECT array_agg(s.usr_schema) FROM qgis_pkg.list_usr_schemas() AS s);
cdb_schemas_array 	CONSTANT varchar[] := (SELECT array_agg(d.cdb_schema) FROM qgis_pkg.list_cdb_schemas() AS d);
sql_statement		text := NULL;
r RECORD;

BEGIN

-- Check that the usr_schema is valid
IF usr_schema IS NULL OR (NOT usr_schema = ANY(usr_schemas_array)) THEN
	RAISE EXCEPTION 'usr_schema value is invalid. It must be correspond to an existing usr_schema';
END IF;

-- Check that the cdb_schema is valid
IF cdb_schema IS NULL OR (NOT cdb_schema = ANY(cdb_schemas_array)) THEN
	RAISE EXCEPTION 'cdb_schema value is invalid. It must be either NULL or correspond to an existing cdb_schema';
END IF;

--RAISE NOTICE 'Dropping all layers in usr_schema "%" associated to cdb_schema "%"', usr_schema, cdb_schema;
FOR r IN 
	SELECT mv.matviewname AS mv_name FROM pg_matviews AS mv
	WHERE mv.schemaname::varchar = usr_schema
		AND substring(mv.matviewname, mv_cdb_schema_pos) LIKE concat(cdb_schema, '%')	
	ORDER BY mv.matviewname ASC
LOOP
	sql_statement := concat(sql_statement, format('
DROP MATERIALIZED VIEW %I.%I CASCADE;',
usr_schema, r.mv_name));
END LOOP;

-- Delete entries from table layer_metadata
IF sql_statement IS NOT NULL THEN
	sql_statement := concat(sql_statement, format('
DELETE FROM %I.layer_metadata AS l WHERE l.cdb_schema = %L;',
	usr_schema, cdb_schema));
END IF;

RETURN sql_statement;

EXCEPTION
	WHEN QUERY_CANCELED THEN
		RAISE EXCEPTION 'qgis_pkg.generate_sql_drop_layers(): Error QUERY_CANCELED';
  WHEN OTHERS THEN 
		RAISE NOTICE 'qgis_pkg.generate_sql_drop_layers(): %', SQLERRM;
END;
$$ LANGUAGE plpgsql;
COMMENT ON FUNCTION qgis_pkg.generate_sql_drop_layers(varchar, varchar) IS 'Genereates SQL to drops layers in selected usr_schema';
REVOKE EXECUTE ON FUNCTION qgis_pkg.generate_sql_drop_layers(varchar, varchar) FROM public;

----------------------------------------------------------------
-- Create FUNCTION QGIS_PKG.DROP_LAYERS
----------------------------------------------------------------
-- Drops layers (e.g. mviews, views, and associated triggers)
DROP FUNCTION IF EXISTS    qgis_pkg.drop_layers(varchar, varchar, varchar) CASCADE;
CREATE OR REPLACE FUNCTION qgis_pkg.drop_layers(
usr_schema		varchar,
cdb_schema		varchar
)
RETURNS void
AS $$
DECLARE
sql_statement text := NULL;

BEGIN
sql_statement := qgis_pkg.generate_sql_drop_layers(usr_schema, cdb_schema);

IF sql_statement IS NOT NULL THEN
	EXECUTE sql_statement;
END IF;

EXCEPTION
	WHEN QUERY_CANCELED THEN
		RAISE EXCEPTION 'qgis_pkg.drop_layers(): Error QUERY_CANCELED';
  WHEN OTHERS THEN 
		RAISE NOTICE 'qgis_pkg.drop_layers(): %', SQLERRM;
END;
$$ LANGUAGE plpgsql;
COMMENT ON FUNCTION qgis_pkg.drop_layers(varchar, varchar) IS 'Drops layers in selected usr_schema';
REVOKE EXECUTE ON FUNCTION qgis_pkg.drop_layers(varchar, varchar) FROM public;

--**************************
DO $MAINBODY$
BEGIN
RAISE NOTICE E'\n\nDone\n\n';
END $MAINBODY$;
--**************************

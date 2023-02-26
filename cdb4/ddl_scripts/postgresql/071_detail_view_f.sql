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
-- This script installs some functions in schema qgis_pkg to manage
-- detail views. 
--
-- qgis_pkg.create_detail_view(...)
-- qgis_pkg.generate_sql_drop_detail_view(...)
-- qgis_pkg.drop_detail_view(...)
--
--
-- ***********************************************************************

----------------------------------------------------------------
-- Create FUNCTION QGIS_PKG.CREATE_LAYERS_BRIDGE
----------------------------------------------------------------
-- Calls the corresponding qgis_pkg.generate_sql_detail_view function and runs the resulting SQL
DROP FUNCTION IF EXISTS    qgis_pkg.create_detail_view(varchar, varchar, numeric[]) CASCADE;
CREATE OR REPLACE FUNCTION qgis_pkg.create_detail_view(
usr_name             varchar,
cdb_schema           varchar,
bbox_corners_array   numeric[] DEFAULT NULL
)
RETURNS void AS $$
DECLARE
l_type		  CONSTANT varchar := 'DetailView';
sql_statement text := NULL;
mview_bbox    geometry(Polygon) := NULL;

BEGIN
mview_bbox := qgis_pkg.generate_mview_bbox_poly(cdb_schema, bbox_corners_array);

sql_statement := qgis_pkg.generate_sql_detail_view(
    usr_name             := usr_name,
    cdb_schema           := cdb_schema,
    mview_bbox           := mview_bbox
);

IF sql_statement IS NOT NULL THEN
    EXECUTE sql_statement;
END IF;

EXCEPTION
    WHEN QUERY_CANCELED THEN
        RAISE EXCEPTION 'qgis_pkg.create_detail_view(): Error QUERY_CANCELED';
    WHEN OTHERS THEN
        RAISE EXCEPTION 'qgis_pkg.create_detail_view(): %', SQLERRM;
END;
$$ LANGUAGE plpgsql;
COMMENT ON FUNCTION qgis_pkg.create_detail_view(varchar, varchar, numeric[]) IS 'Create nested tables (associated to a cdb_schema) in selected usr_schema';
REVOKE EXECUTE ON FUNCTION qgis_pkg.create_detail_view(varchar, varchar, numeric[]) FROM public;

----------------------------------------------------------------
-- Create FUNCTION QGIS_PKG.GENERATE_SQL_DROP_detail_view
----------------------------------------------------------------
-- Generates SQL to drop layers (e.g. mviews, views and associated triggers) for feature type bridge
DROP FUNCTION IF EXISTS    qgis_pkg.generate_sql_drop_detail_view(varchar, varchar) CASCADE;
CREATE OR REPLACE FUNCTION qgis_pkg.generate_sql_drop_detail_view(
usr_schema varchar,
cdb_schema varchar
)
RETURNS text
AS $$
DECLARE
layer_type   CONSTANT varchar := 'DetailView';
dv_prefix    CONSTANT varchar := 'dv';
regexp_string CONSTANT varchar := '^(gen_attrib|ext_ref|address_bri|address_bdg).*';

layer_prefix varchar := concat(dv_prefix,'_',cdb_schema,'_');
layer_prefix_pos CONSTANT integer := length(layer_prefix) + 1;

usr_schemas_array CONSTANT varchar[] := (SELECT array_agg(s.usr_schema) FROM qgis_pkg.list_usr_schemas() AS s);
cdb_schemas_array CONSTANT varchar[] := (SELECT array_agg(d.cdb_schema) FROM qgis_pkg.list_cdb_schemas() AS d);
sql_statement text := NULL;
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
    SELECT v.table_name AS nt_name
    FROM information_schema.views AS v
    WHERE v.table_schema::varchar = usr_schema
        AND v.table_name::varchar LIKE concat(layer_prefix, '%')
        AND substring(v.table_name FROM layer_prefix_pos) ~ regexp_string
    ORDER BY v.table_name ASC
LOOP
    sql_statement := concat(sql_statement, format('
DROP VIEW IF EXISTS %I.%I CASCADE;',
    usr_schema, r.nt_name));

END LOOP;

-- Delete entries from table layer_metadata and reset sequence (if possible)
IF sql_statement IS NOT NULL THEN
    sql_statement := concat(sql_statement, format('
DELETE FROM %I.layer_metadata AS l WHERE l.cdb_schema = %L AND l.layer_type = %L;
WITH m AS (SELECT max(id) AS max_id FROM %I.layer_metadata)
SELECT setval(''%I.layer_metadata_id_seq''::regclass, m.max_id, TRUE) FROM m;',
    usr_schema, cdb_schema, layer_type,
    usr_schema,
    usr_schema));

END IF;

RETURN sql_statement;

EXCEPTION
    WHEN QUERY_CANCELED THEN
        RAISE EXCEPTION 'qgis_pkg.generate_sql_drop_detail_view(): Error QUERY_CANCELED';
  WHEN OTHERS THEN 
        RAISE NOTICE 'qgis_pkg.generate_sql_drop_detail_view(): %', SQLERRM;
END;
$$ LANGUAGE plpgsql;
COMMENT ON FUNCTION qgis_pkg.generate_sql_drop_detail_view(varchar, varchar) IS 'Genereate SQL to drop nested tables (associated to a cdb_schema) in selected usr_schema';
REVOKE EXECUTE ON FUNCTION qgis_pkg.generate_sql_drop_detail_view(varchar, varchar) FROM public;


----------------------------------------------------------------
-- Create FUNCTION QGIS_PKG.DROP_DEATIL_VIEW
----------------------------------------------------------------
-- Generates SQL to drops layers (e.g. mviews, views, and associated triggers) for feature type bridge
DROP FUNCTION IF EXISTS    qgis_pkg.drop_detail_view(varchar, varchar) CASCADE;
CREATE OR REPLACE FUNCTION qgis_pkg.drop_detail_view(
usr_schema varchar,
cdb_schema varchar
)
RETURNS void
AS $$
DECLARE
sql_statement text := NULL;

BEGIN
sql_statement := qgis_pkg.generate_sql_drop_detail_view(usr_schema, cdb_schema); 

IF sql_statement IS NOT NULL THEN
    EXECUTE sql_statement;
END IF;

EXCEPTION
    WHEN QUERY_CANCELED THEN
        RAISE EXCEPTION 'qgis_pkg.drop_detail_view(): Error QUERY_CANCELED';
    WHEN OTHERS THEN 
        RAISE NOTICE 'qgis_pkg.drop_detail_view(): %', SQLERRM;
END;
$$ LANGUAGE plpgsql;
COMMENT ON FUNCTION qgis_pkg.drop_detail_view(varchar, varchar) IS 'Drop nested tables (associated to a cdb_schema) in selected usr_schema';
REVOKE EXECUTE ON FUNCTION qgis_pkg.drop_detail_view(varchar, varchar) FROM public;


----------------------------------------------------------------
-- Create FUNCTION QGIS_PKG.REFRESH_detail_view
----------------------------------------------------------------
-- Refreshes nested tables (that are actually materialized views
-- DROP FUNCTION IF EXISTS    qgis_pkg.refresh_detail_view(varchar, varchar) CASCADE;
-- CREATE OR REPLACE FUNCTION qgis_pkg.refresh_detail_view(



-- EXCEPTION
--     WHEN QUERY_CANCELED THEN
--         RAISE EXCEPTION 'qgis_pkg.refresh_detail_view(): Error QUERY_CANCELED';
--   WHEN OTHERS THEN 
--         RAISE NOTICE 'qgis_pkg.refresh_detail_view(): %', SQLERRM;
-- END;
-- $$ LANGUAGE plpgsql;
-- COMMENT ON FUNCTION qgis_pkg.refresh_detail_view(varchar, varchar) IS 'Refresh nested tables (associated to a cdb_schema) in selected usr_schema';
-- REVOKE EXECUTE ON FUNCTION qgis_pkg.refresh_detail_view(varchar, varchar) FROM public;


--**************************
DO $MAINBODY$
BEGIN
RAISE NOTICE E'\n\nDone\n\n';
END $MAINBODY$;
--**************************

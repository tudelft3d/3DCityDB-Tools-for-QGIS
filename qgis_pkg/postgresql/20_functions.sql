-- ****************************************************************************
-- ****************************************************************************
--
--
-- CREATE FUNCTIONS in schema qgis_pkg
--
--
-- ****************************************************************************
-- ****************************************************************************

DO $MAINBODY$
DECLARE
BEGIN

/* --- TEMPLATE FOR FUNCTIONS
----------------------------------------------------------------
-- Create FUNCTION QGIS_PKG.XX_FUNCNAME_XX
----------------------------------------------------------------
-- A short description of what it does
-- ...
-- ...
DROP FUNCTION IF EXISTS    qgis_pkg.xx_funcname_xx(signature) CASCADE;
CREATE OR REPLACE FUNCTION qgis_pkg.xx_funcname_xx(
param1 type,
param2 type
...
)
RETURNS xxxx
AS $$
DECLARE
	param3 type;
	param4 type;
...

BEGIN

-- body of the function


EXCEPTION
	WHEN QUERY_CANCELED THEN
		RAISE EXCEPTION 'qgis_pkg.xx_funcname_xx(): Error QUERY_CANCELED';
  WHEN OTHERS THEN 
		RAISE NOTICE 'qgis_pkg.xx_funcname_xx(): %', SQLERRM;
END;
$$ LANGUAGE plpgsql;
COMMENT ON FUNCTION qgis_pkg.xx_funcname_xx(varchar) IS 'xxxx short comment xxxx';
*/

----------------------------------------------------------------
-- Create FUNCTION QGIS_PKG.SUPPORT_FOR_SCHEMA
----------------------------------------------------------------
-- Returns True if qgis_pkg schema supports the input schema.
-- In pratice it searches the schema for view names starting with
-- the input schema name.

DROP FUNCTION IF EXISTS    qgis_pkg.support_for_schema(varchar) CASCADE;
CREATE OR REPLACE FUNCTION qgis_pkg.support_for_schema(
	schema varchar
)
RETURNS boolean
AS $$

BEGIN
PERFORM table_name
	FROM information_schema.tables 
    WHERE table_schema = 'qgis_pkg'
	AND table_type = 'VIEW'
	AND table_name LIKE schema || '%'; 
	-- Don't use FORMAT, something happens with
	-- the variable FOUND assignment (many false positives)


RETURN FOUND;

EXCEPTION
	WHEN QUERY_CANCELED THEN
		RAISE EXCEPTION 'qgis_pkg.support_for_schema(): Error QUERY_CANCELED';
  WHEN OTHERS THEN 
		RAISE NOTICE 'qgis_pkg.support_for_schema(): %', SQLERRM;
END;
$$ LANGUAGE plpgsql;
COMMENT ON FUNCTION qgis_pkg.support_for_schema(varchar) IS 'Searches for schema name into the views name to determine if qgis_pkg support the input schema.';


----------------------------------------------------------------
-- Create FUNCTION QGIS_PKG.GET_ALL_SCHEMAS
----------------------------------------------------------------
-- Retrieves all available schemas in the current database
-- SUGGESTION: rename schema variable from schema to dbschema
--
DROP FUNCTION IF EXISTS    qgis_pkg.get_all_schemas() CASCADE;
CREATE OR REPLACE FUNCTION qgis_pkg.get_all_schemas()
RETURNS TABLE(
schema information_schema.sql_identifier  -- to be checked if too PostgreSQL specific
)
AS $$
DECLARE
BEGIN

RETURN QUERY
	SELECT 
		schema_name
	FROM 
		information_schema.schemata 
	WHERE 
		(schema_name != 'information_schema') 
		AND (schema_name NOT LIKE 'pg_%') 
	ORDER BY schema_name ASC;

EXCEPTION
	WHEN QUERY_CANCELED THEN
		RAISE EXCEPTION 'qgis_pkg.get_all_schemas(): Error QUERY_CANCELED';
  WHEN OTHERS THEN 
		RAISE NOTICE 'qgis_pkg.get_all_schemas(): %', SQLERRM;
END;
$$ LANGUAGE plpgsql;
COMMENT ON FUNCTION qgis_pkg.get_all_schemas() IS 'Retrieves all available schemas in the current database';

----------------------------------------------------------------
-- Create FUNCTION QGIS_PKG.GET_FEATURE_SCHEMAS
----------------------------------------------------------------
-- Retrieves all 3dcitydb schemas in the current database
--
-- TO DO: possibly to be renamed to "get_citydb_schemas"
-- SUGGESTION: rename schema variable from schema to citydb_schema
--
DROP FUNCTION IF EXISTS    qgis_pkg.get_feature_schemas() CASCADE;
CREATE OR REPLACE FUNCTION qgis_pkg.get_feature_schemas()
RETURNS TABLE(
schema information_schema.sql_identifier  -- to be checked if too PostgreSQL specific
)
AS $$
DECLARE
feature_tables CONSTANT varchar := '(cityobject|building|tunnel|tin_relief|bridge|
waterbody|solitary_vegetat_object|land_use|)'; --Ideally should check for all 60+x tables (for v.4.x)

BEGIN

RETURN QUERY
	SELECT 
		DISTINCT(table_schema) 
	FROM information_schema.tables  
	WHERE table_name SIMILAR TO feature_tables
	ORDER BY table_schema ASC;

EXCEPTION
	WHEN QUERY_CANCELED THEN
		RAISE EXCEPTION 'qgis_pkg.get_feature_schemas(): Error QUERY_CANCELED';
  WHEN OTHERS THEN 
		RAISE NOTICE 'qgis_pkg.get_feature_schemas(): %', SQLERRM;
END;
$$ LANGUAGE plpgsql;
COMMENT ON FUNCTION qgis_pkg.get_feature_schemas() IS 'Retrieves all 3dcitydb schemas in the current database';



-- *************************************************************************
-- ***************** What is the difference to the next function?
-- *************************************************************************

----------------------------------------------------------------
-- Create FUNCTION QGIS_PKG.GET_MAIN_SCHEMAS
----------------------------------------------------------------
-- A short description of what it does
-- SUGGESTION: rename schema variable from schema to citydb_schema
-- ...
DROP FUNCTION IF EXISTS    qgis_pkg.get_main_schemas() CASCADE;
CREATE OR REPLACE FUNCTION qgis_pkg.get_main_schemas()
RETURNS TABLE(
schema information_schema.sql_identifier
)
AS $$
DECLARE
feature_tables CONSTANT varchar := '(cityobject|building|tunnel|tin_relief|bridge|
waterbody|solitary_vegetat_object|land_use|)'; --Ideally should check for all 60+x tables (for v.4.x)

BEGIN

RETURN QUERY 
	SELECT 
		DISTINCT(table_schema) 
	FROM information_schema.tables  
	WHERE table_name SIMILAR TO feature_tables
	ORDER BY table_schema ASC;

EXCEPTION
	WHEN QUERY_CANCELED THEN
		RAISE EXCEPTION 'qgis_pkg.get_main_schemas(): Error QUERY_CANCELED';
  WHEN OTHERS THEN 
		RAISE NOTICE 'qgis_pkg.get_main_schemas(): %', SQLERRM;
END;
$$ LANGUAGE plpgsql;
COMMENT ON FUNCTION qgis_pkg.get_main_schemas() IS 'xxxx short comment xxxx';




-- *************************************************************************
-- ***************** Is this used or can it be commented out?
-- *************************************************************************

----------------------------------------------------------------
-- Create FUNCTION QGIS_PKG.GET_TABLE_PRIVILEGES
----------------------------------------------------------------
-- Retrieves the privileges for all tables in the selected schema
--
DROP FUNCTION IF EXISTS    qgis_pkg.get_table_privileges(varchar) CASCADE;
CREATE OR REPLACE FUNCTION qgis_pkg.get_table_privileges(
schema varchar
)
RETURNS TABLE(
table_name varchar,
delete_priv boolean, 
select_priv boolean, 
referenc_priv boolean, 
trigger_priv boolean, 
truncuat_priv boolean, 
update_priv boolean, 
insert_priv boolean
)
AS $$
DECLARE
BEGIN
RETURN QUERY
	WITH t AS (
		SELECT concat(schema,'.',i.table_name)::varchar AS qualified_table_name
		FROM information_schema.tables AS i
		WHERE table_schema = schema 
			AND table_type = 'BASE TABLE'
	) 
	SELECT
		t.qualified_table_name,
		pg_catalog.has_table_privilege(current_user, t.qualified_table_name, 'DELETE')     AS delete_priv,
		pg_catalog.has_table_privilege(current_user, t.qualified_table_name, 'SELECT')     AS select_priv,
		pg_catalog.has_table_privilege(current_user, t.qualified_table_name, 'REFERENCES') AS references_priv,
		pg_catalog.has_table_privilege(current_user, t.qualified_table_name, 'TRIGGER')    AS trigger_priv,
		pg_catalog.has_table_privilege(current_user, t.qualified_table_name, 'TRUNCATE')   AS truncate_priv,
		pg_catalog.has_table_privilege(current_user, t.qualified_table_name, 'UPDATE')     AS update_priv,
		pg_catalog.has_table_privilege(current_user, t.qualified_table_name, 'INSERT')     AS insert_priv
	FROM t;

EXCEPTION
	WHEN QUERY_CANCELED THEN
		RAISE EXCEPTION 'qgis_pkg.get_table_privileges(): Error QUERY_CANCELED';
  WHEN OTHERS THEN 
		RAISE NOTICE 'qgis_pkg.get_table_privileges(): %', SQLERRM;
END;
$$ LANGUAGE plpgsql;
COMMENT ON FUNCTION qgis_pkg.get_table_privileges(varchar) IS 'Retrieves the privileges for all tables in the selected schema';

-- Set returning function, to be used with:
--SELECT * FROM qgis_pkg.get_table_privileges('citydb');


-- *************************************************************************
-- Why do you pass the name of the view and not directly the name of the mview? 
-- The select query is too generic and must be narrowed down
-- ISSUE: the SRID_ID is (was) hardcoded, it must be dynamic
-- The boubnding box geometry MUST be converted to the same SRID of the database.
-- This can happen either in QGIS, or in PostgreSQL, but the bbox string must
-- be provided with the input SRID.
-- *************************************************************************


----------------------------------------------------------------
-- Create FUNCTION QGIS_PKG.VIEW_COUNTER
----------------------------------------------------------------
-- Counts records in the selected materialized view
-- This function can be run providing only the name of the view,
-- OR, alternatively, also the extents.
DROP FUNCTION IF EXISTS    qgis_pkg.view_counter(varchar, varchar) CASCADE;
CREATE OR REPLACE FUNCTION qgis_pkg.view_counter(
view_name	varchar,
extents		varchar DEFAULT NULL	-- PostGIS polygon as WKT. QGIS SRID is missing!
									-- e.g. ST_AsEWKT(ST_MakeEnvelope(229234, 476749, 230334, 479932))
--qgis_srid integer??
)
RETURNS integer
AS $$
DECLARE
counter integer := 0;
db_srid		integer;
--bbox_srid	integer; -- this should be included in the extents_string
query_geom geometry(Polygon);
query_bbox box2d;

BEGIN
IF EXISTS(
		SELECT
			table_name 
		FROM
			information_schema.tables AS i
		WHERE
			i.table_name = view_name
			AND i.table_schema = 'qgis_pkg'   -- Add this one to narrow the query
		) 
THEN
	IF extents IS NULL THEN
		EXECUTE format('SELECT count(co_id) FROM qgis_pkg._g_%I', view_name)
			INTO counter;
	ELSE
		-- retrieve the srid of the database
		db_srid := (SELECT srid FROM citydb.database_srs LIMIT 1);
		-- Create the geometry, but some more checks are needed if the srid is different
		query_geom := ST_GeomFromText(extents,db_srid);
		-- create here the bbox geometry
		query_bbox := ST_Extent(query_geom);
		--RAISE NOTICE 'Query bbox %', query_bbox;
		-- Actually, if for any reason the user is defining a bbox in another srid, we must transform
		-- it to the db_srid_it
		-- ST_Transform or something similar.
		-- Ideally, this check is carried out in QGIS and then bbox passed to the function is already in the same srid.

		EXECUTE FORMAT('SELECT count(t.co_id) FROM qgis_pkg._g_%I t WHERE $1 && t.geom',
			view_name, query_bbox) USING query_bbox INTO counter;
	END IF;
ELSE
	RAISE EXCEPTION 'View % does not exist in schema qgis_pkg',view_name;	
END IF;
RETURN counter;
EXCEPTION
	WHEN QUERY_CANCELED THEN
		RAISE EXCEPTION 'qgis_pkg.view_counter(): Error QUERY_CANCELED';
  WHEN OTHERS THEN 
		RAISE NOTICE 'qgis_pkg.view_counter(): %', SQLERRM;
END;
$$ LANGUAGE plpgsql;
COMMENT ON FUNCTION qgis_pkg.view_counter(varchar, varchar) IS 'Counts records in the selected materialized view';

--SELECT qgis_pkg.view_counter('citydb_bdg_lod0_footprint', NULL);
--SELECT qgis_pkg.view_counter('citydb_bdg_lod0_footprint', ST_AsEWKT(ST_MakeEnvelope(229234, 476749, 230334, 479932)));


----------------------------------------------------------------
-- Create FUNCTION QGIS_PKG.COMPUTE_GA_INDICES
----------------------------------------------------------------
-- This function adds indices to the table containing the generic attributes
-- It must be run ONLY ONCE in a specific dbschema, upon installation.
DROP FUNCTION IF EXISTS    qgis_pkg.add_ga_indices(varchar) CASCADE;
CREATE OR REPLACE FUNCTION qgis_pkg.add_ga_indices(
citydb_schema varchar --DEFAULT 'citydb'
)
RETURNS integer AS $$
DECLARE
sql_statement varchar;
BEGIN
-- Add some indices, if they do not already exists, to table cityobject_genericattrib;

RAISE NOTICE 'Adding indices to table cityobject_genericattrib';
sql_statement := concat('
--ALTER TABLE ',citydb_schema,'.cityobject_genericattrib ALTER COLUMN datatype SET NOT NULL;
--DROP INDEX IF EXISTS ',citydb_schema,'.genericattrib_attrname_inx;
CREATE INDEX IF NOT EXISTS genericattrib_attrname_inx ON ',citydb_schema,'.cityobject_genericattrib (attrname);
--DROP INDEX IF EXISTS ',citydb_schema,'.genericattrib_datatype_inx;
CREATE INDEX IF NOT EXISTS genericattrib_datatype_inx ON ',citydb_schema,'.cityobject_genericattrib (datatype);
');
EXECUTE sql_statement;
RETURN 1;

EXCEPTION
	WHEN QUERY_CANCELED THEN
		RAISE EXCEPTION 'qgis_pkg.add_ga_indices(): Error QUERY_CANCELED';
  WHEN OTHERS THEN 
		RAISE NOTICE 'qgis_pkg.add_ga_indices(): %', SQLERRM;
END;
$$ LANGUAGE plpgsql;
COMMENT ON FUNCTION qgis_pkg.add_ga_indices(varchar) IS 'Adds some indices to table cityobject_genericattrib';

--PERFORM qgis_pkg.add_indices(citydb_schema := 'citydb');

----------------------------------------------------------------
-- Create FUNCTION QGIS_PKG.COMPUTE_SCHEMA_EXTENTS
----------------------------------------------------------------
DROP FUNCTION IF EXISTS    qgis_pkg.compute_schema_extents(varchar) CASCADE;
CREATE OR REPLACE FUNCTION qgis_pkg.compute_schema_extents(
IN citydb_schema varchar, --DEFAULT 'citydb'
--
OUT x_min numeric,
OUT y_min numeric,
OUT x_max numeric,
OUT y_max numeric,
OUT srid_id integer,
OUT upserted_id integer
)
--RETURNS integer 
AS $$
DECLARE
citydb_envelope		geometry(Polygon) := NULL;

BEGIN
--EXECUTE format('SELECT db.srid FROM %I.database_srs AS db LIMIT 1', citydb_schema) INTO srid_id;
--RAISE NOTICE 'database srid: %',srid_id;
EXECUTE format('SELECT ST_Envelope(ST_Collect(co.envelope)) FROM %I.cityobject AS co', citydb_schema) INTO citydb_envelope;
--RAISE NOTICE 'citydb_envelope %', ST_AsEWKT(citydb_envelope);

IF citydb_envelope IS NOT NULL THEN
	srid_id := ST_SRID(citydb_envelope);
	--RAISE NOTICE 'database srid: %',srid_id;	
	x_min :=   floor(ST_Xmin(citydb_envelope));
	x_max := ceiling(ST_Xmax(citydb_envelope));
	y_min :=   floor(ST_Ymin(citydb_envelope));
	y_max := ceiling(ST_Ymax(citydb_envelope));
	--RAISE NOTICE '(% % % %, %)', x_min, y_min, x_max, y_max, srid_id;
	citydb_envelope := ST_MakeEnvelope(x_min, y_min, x_max, y_max, srid_id);

	-- upsert statement for table qgis_pkg.envelope
	EXECUTE format('
		INSERT INTO qgis_pkg.extents AS e (schema_name, bbox_type, envelope, creation_date)
		VALUES (%L, ''db_schema'', %L, clock_timestamp())
		ON CONFLICT ON CONSTRAINT extents_schema_bbox_unique DO
			UPDATE SET
				envelope = %L,
				creation_date = clock_timestamp()
			WHERE
				e.schema_name = %L AND
				e.bbox_type = ''db_schema''
			RETURNING id',
		citydb_schema, citydb_envelope,
		citydb_envelope, citydb_schema)
	INTO STRICT upserted_id;
END IF;

EXCEPTION
	WHEN QUERY_CANCELED THEN
		RAISE EXCEPTION 'qgis_pkg.compute_schema_extents(): Error QUERY_CANCELED';
  WHEN OTHERS THEN 
		RAISE NOTICE 'qgis_pkg.compute_schema_extents(): %', SQLERRM;
END;
$$ LANGUAGE plpgsql;
COMMENT ON FUNCTION qgis_pkg.compute_schema_extents(varchar) IS 'Computes extents of the selected citydb schema';

--PERFORM * FROM qgis_pkg.compute_schema_extents(citydb_schema := 'citydb');
--PERFORM SELECT qgis_pkg.compute_schema_extents(citydb_schema := 'citydb');

----------------------------------------------------------------
-- Create FUNCTION QGIS_PKG.UPSERT_EXTENTS
----------------------------------------------------------------
DROP FUNCTION IF EXISTS    qgis_pkg.upsert_extents(varchar, varchar, geometry) CASCADE;
CREATE OR REPLACE FUNCTION qgis_pkg.upsert_extents(
citydb_schema		varchar, 			--DEFAULT 'citydb',
citydb_bbox_type	varchar, 			--DEFAULT 'db_schema'
citydb_envelope		geometry(Polygon) 	DEFAULT NULL
)
RETURNS integer AS $$
DECLARE
ext_label	varchar;
upserted_id	integer := NULL;

BEGIN

CASE
	WHEN citydb_bbox_type = 'db_schema' THEN
		upserted_id := (SELECT f.upserted_id FROM qgis_pkg.compute_schema_extents(citydb_schema) AS f);
	WHEN citydb_bbox_type IN ('m_view', 'qgis') THEN
		IF citydb_envelope IS NOT NULL THEN
			IF citydb_bbox_type = 'm_view' THEN
				ext_label := concat(citydb_schema,'-mview_bbox_extents');
			ELSE
				ext_label := concat(citydb_schema,'-qgis_bbox_extents');
			END IF;
		
			EXECUTE format('
				INSERT INTO qgis_pkg.extents AS e (schema_name, bbox_type, label, envelope, creation_date)
				VALUES (%L, %L, %L, %L, clock_timestamp())
				ON CONFLICT ON CONSTRAINT extents_schema_bbox_unique DO
					UPDATE SET
						envelope = %L,
						label = %L,
						creation_date = clock_timestamp()
					WHERE
						e.schema_name = %L AND
						e.bbox_type = %L
				RETURNING id',
				citydb_schema, citydb_bbox_type, ext_label, citydb_envelope,
				citydb_envelope, ext_label, citydb_schema, citydb_bbox_type)
			INTO STRICT upserted_id;
		END IF;
ELSE

END CASE;

RETURN upserted_id;
EXCEPTION
	WHEN QUERY_CANCELED THEN
		RAISE EXCEPTION 'qgis_pkg.upsert_extents(): Error QUERY_CANCELED';
  WHEN OTHERS THEN 
		RAISE NOTICE 'qgis_pkg.upsert_extents(): %', SQLERRM;
END;
$$ LANGUAGE plpgsql;
COMMENT ON FUNCTION qgis_pkg.upsert_extents(varchar, varchar, geometry) IS 'Updates the qgis_pkg.extents table';

--PERFORM qgis_pkg.upsert_extents('citydb','db_schema', NULL);

----------------------------------------------------------------
-- Create FUNCTION QGIS_PKG.REFRESH_MVIEW
----------------------------------------------------------------
DROP FUNCTION IF EXISTS    qgis_pkg.refresh_mview(varchar, varchar) CASCADE;
CREATE OR REPLACE FUNCTION qgis_pkg.refresh_mview(
citydb_schema varchar DEFAULT NULL,
mview_name   varchar DEFAULT NULL
)
RETURNS integer AS $$
DECLARE
qgis_pkg_schema_name 	varchar := 'qgis_pkg';
start_timestamp 		timestamptz(3);
stop_timestamp 			timestamptz(3);
f_start_timestamp 		timestamptz(3);
f_stop_timestamp 		timestamptz(3);
r 						RECORD;
mv_n_features 			integer DEFAULT 0;

BEGIN
f_start_timestamp := clock_timestamp();
CASE 
	WHEN citydb_schema IS NULL AND mview_name IS NULL THEN -- refresh all existing materialized views
	RAISE NOTICE 'Refreshing all materialized views in schema %', qgis_pkg_schema_name;
		FOR r IN 
			SELECT pg_namespace.nspname AS table_schema, pg_class.relname AS mview_name
			FROM pg_catalog.pg_class
				INNER JOIN pg_catalog.pg_namespace ON pg_class.relnamespace = pg_namespace.oid
			WHERE pg_class.relkind = 'm' AND pg_namespace.nspname = qgis_pkg_schema_name
			ORDER BY mview_name
		LOOP
			start_timestamp := clock_timestamp();
			EXECUTE format('REFRESH MATERIALIZED VIEW %I.%I', qgis_pkg_schema_name, r.mview_name);
			stop_timestamp := clock_timestamp();
			EXECUTE format('SELECT count(co_id) FROM %I.%I', qgis_pkg_schema_name, r.mview_name) INTO mv_n_features;

			UPDATE qgis_pkg.layer_metadata AS lm SET
				n_features    = mv_n_features,
				refresh_date  = stop_timestamp
			WHERE lm.mv_name = r.mview_name;
			RAISE NOTICE 'Refreshed materialized view "%.%" in %', qgis_pkg_schema_name, r.mview_name, stop_timestamp-start_timestamp; 
		END LOOP;
		f_stop_timestamp := clock_timestamp();		
		RAISE NOTICE 'All materialized views in schema "%" refreshed in %!', qgis_pkg_schema_name, f_stop_timestamp-f_start_timestamp; 	
		RETURN 1;

	WHEN citydb_schema IS NOT NULL THEN -- refresh all existing materialized views for that schema
		IF EXISTS (SELECT 1 FROM pg_catalog.pg_namespace WHERE pg_namespace.nspname=citydb_schema) THEN
		RAISE NOTICE 'Refreshing all materialized views associated to schema "%"', citydb_schema;		
			FOR r IN 
				SELECT pg_namespace.nspname AS table_schema, pg_class.relname AS mview_name
				FROM pg_catalog.pg_class
					INNER JOIN pg_catalog.pg_namespace ON pg_class.relnamespace = pg_namespace.oid
				WHERE pg_class.relkind = 'm' AND pg_namespace.nspname = qgis_pkg_schema_name
					AND pg_class.relname LIKE '_g_'||citydb_schema||'_%'
				ORDER BY table_schema, mview_name
			LOOP
				start_timestamp := clock_timestamp();
				EXECUTE format('REFRESH MATERIALIZED VIEW %I.%I', qgis_pkg_schema_name, r.mview_name);
				stop_timestamp := clock_timestamp();
				
				EXECUTE format('SELECT count(co_id) FROM %I.%I', qgis_pkg_schema_name, r.mview_name) INTO mv_n_features;

				UPDATE qgis_pkg.layer_metadata AS lm SET
					n_features    = mv_n_features,
					refresh_date  = stop_timestamp
				WHERE lm.mv_name = r.mview_name;				

				RAISE NOTICE 'Refreshed materialized view "%.%" in %', qgis_pkg_schema_name, r.mview_name, stop_timestamp-start_timestamp; 
			END LOOP;
			f_stop_timestamp := clock_timestamp();		
			RAISE NOTICE 'All materialized views for citydb schema "%" refreshed in %!!', citydb_schema, f_stop_timestamp-f_start_timestamp; 	
			RETURN 1;
		ELSE
			RAISE NOTICE 'No schema found with name "%"', citydb_schema;
			RETURN 0;			
		END IF;

	WHEN mview_name IS NOT NULL THEN -- refresh only a specific materialized views
		IF EXISTS (SELECT 1 
					FROM pg_catalog.pg_class
						INNER JOIN pg_catalog.pg_namespace ON pg_class.relnamespace = pg_namespace.oid
					WHERE pg_class.relkind = 'm' AND pg_namespace.nspname=qgis_pkg_schema_name
						AND pg_class.relname = mview_name) THEN
			RAISE NOTICE 'Refreshing materialized view "%.%""', qgis_pkg_schema_name, mview_name;
			start_timestamp := clock_timestamp();
			EXECUTE format('REFRESH MATERIALIZED VIEW %I.%I', qgis_pkg_schema_name, mview_name);
			stop_timestamp := clock_timestamp();

			EXECUTE format('SELECT count(co_id) FROM %I.%I', qgis_pkg_schema_name, r.mview_name) INTO mv_n_features;

			UPDATE qgis_pkg.layer_metadata AS lm SET
				n_features    = mv_n_features,
				refresh_date  = stop_timestamp
			WHERE lm.mv_name = r.mview_name;

			RAISE NOTICE 'Refreshed materialized view "%.%" in %', qgis_pkg_schema_name, mview_name, stop_timestamp-start_timestamp; 
			RETURN 1;
		ELSE
			RAISE NOTICE 'No materialized view found with name "%"', mview_name;
			RETURN 0;			
		END IF;

	ELSE
		RAISE NOTICE 'Nothing done';
		RETURN 0;	
END CASE;

EXCEPTION
	WHEN QUERY_CANCELED THEN
		RAISE EXCEPTION 'qgis_pkg.refresh_mview(): Error QUERY_CANCELED';
  WHEN OTHERS THEN 
		RAISE NOTICE 'qgis_pkg.refresh_mview(): %', SQLERRM;
END;
$$ LANGUAGE plpgsql;
COMMENT ON FUNCTION qgis_pkg.refresh_mview(varchar, varchar) IS 'Refresh materialized view(s) in schema qgis_pkg';

--PERFORM qgis_pkg.refresh_mview();
--PERFORM qgis_pkg.refresh_mview(citydb_schema := 'citydb');

----------------------------------------------------------------
-- Create FUNCTION QGIS_PKG.ST_3DAREA_POLY
----------------------------------------------------------------
DROP FUNCTION IF EXISTS    qgis_pkg.st_3darea_poly(geometry);
CREATE OR REPLACE FUNCTION qgis_pkg.st_3darea_poly(
polygon3d geometry			-- must be a 3D polygon
)
RETURNS numeric AS $$
DECLARE
ring geometry;
n_points integer;
i integer; j integer;
p1 geometry; p2 geometry;
x1 numeric; y1 numeric; z1 numeric;
x2 numeric; y2 numeric; z2 numeric;
n_interior_rings integer;
nx_t numeric := 0;
ny_t numeric := 0;
nz_t numeric := 0;
nl_t numeric := 0;
area numeric := 0;
BEGIN
--polygon3d := ST_Force3D(polygon3d);
ring := ST_RemoveRepeatedPoints(ST_ExteriorRing(polygon3d));
ring := ST_ExteriorRing(polygon3d);
n_points := ST_NPoints(ring);
p1 := ST_PointN(ring,1);
x1 := ST_X(p1);
y1 := ST_Y(p1);
z1 := ST_Z(p1);
FOR i IN 2..n_points LOOP
	p2 := ST_PointN(ring,i);
	x2 := ST_X(p2);
	y2 := ST_Y(p2);
	z2 := ST_Z(p2);
	nx_t := nx_t + (y1-y2)*(z1+z2); 
	ny_t := ny_t + (z1-z2)*(x1+x2);
	nz_t := nz_t + (x1-x2)*(y1+y2);
	x1 := x2;
	y1 := y2;
	z1 := z2;
END LOOP;
n_interior_rings := ST_NumInteriorRings(polygon3d);
IF n_interior_rings > 0 THEN
	FOR j IN 1..n_interior_rings LOOP
		ring := ST_RemoveRepeatedPoints(ST_Reverse(ST_InteriorRingN(polygon3d,j)));	
		n_points := ST_NPoints(ring);
		p1 := ST_PointN(ring,1);
		x1 := ST_X(p1);
		y1 := ST_Y(p1);
		z1 := ST_Z(p1);
		FOR i IN 2..n_points LOOP
			p2 := ST_PointN(ring,i);
			x2 := ST_X(p2);
			y2 := ST_Y(p2);
			z2 := ST_Z(p2);
			nx_t := nx_t - (y1-y2)*(z1+z2); 
			ny_t := ny_t - (z1-z2)*(x1+x2);
			nz_t := nz_t - (x1-x2)*(y1+y2);
			x1 := x2;
			y1 := y2;
			z1 := z2;
		END LOOP; --loop ring points		
	END LOOP; -- loop ring
END IF;

area := sqrt(nx_t^2+ny_t^2+nz_t^2)/2;

RETURN area;
EXCEPTION
	WHEN QUERY_CANCELED THEN
		RAISE EXCEPTION 'util_pkg.st_3darea_poly(): Error QUERY_CANCELED';
	WHEN OTHERS THEN
		RAISE EXCEPTION 'util_pkg.st_3darea_poly(): %', SQLERRM;
END;
$$ LANGUAGE plpgsql IMMUTABLE;
COMMENT ON FUNCTION qgis_pkg.st_3darea_poly(geometry) IS 'Returns the 3D area of a 3D polygon';

----------------------------------------------------------------
-- Create FUNCTION QGIS_PKG.SNAP_POLY_TO_GRID
----------------------------------------------------------------
DROP FUNCTION IF EXISTS    qgis_pkg.snap_poly_to_grid(geometry, integer, integer, numeric) CASCADE;
CREATE OR REPLACE FUNCTION qgis_pkg.snap_poly_to_grid(
polygon 			geometry DEFAULT NULL, 		-- do not forget to remove the default null after debugging
perform_snapping 	integer DEFAULT 0, 			-- i.e. default is "do nothing", otherwise 1.
digits 				integer DEFAULT 3,			-- number of digits after comma for precision
area_min			numeric DEFAULT 0.0001 		-- minimum acceptable area of a polygon 
)
RETURNS geometry AS $$
DECLARE
dec_prec 		numeric;
srid_id 		integer;
snapped_poly 	geometry(PolygonZ);
num_geoms		integer;
is_empty_geom 	boolean;
ring 			geometry(LinestringZ);
o_ring 			geometry(LinestringZ);
i_ring			geometry(LinestringZ);
i_rings 		geometry(LinestringZ)[];
n_int_rings		integer;
i 				integer;
r 				RECORD;
area_poly 		numeric;
new_polygon 	geometry(PolygonZ);

BEGIN
/*
polygon := ST_SetSRID(ST_GeomFromText('PolygonZ((
10.123456789 10.123456789 10.123456789,
20.223456789 10.123456789 10.123456789,			   
20.223456789 20.223456789 10.123456789,			   
10.123456789 20.223456789 10.123456789,
10.123456789 10.123456789 10.123456789
),(  
14.123456789 14.123456789 10.123456789,
14.223456789 16.123456789 10.123456789,			   
16.223456789 16.223456789 10.123456789,			   
16.123456789 14.223456789 10.123456789,
14.123456789 14.123456789 10.123456789
))'
),28992);
--*/
/*
polygon := ST_SetSRID(ST_GeomFromText('PolygonZ((
10.0001 10.0001 10.123456789,
20.0001 10.0001 10.123456789,			   
20.0001 10.0002 10.123456789,			   
10.0001 10.0002 10.123456789,
10.0001 10.0001 10.123456789
))'
),28992);
*/
CASE 
	WHEN perform_snapping = 0 THEN
		--RAISE NOTICE 'polygon: %', ST_AsEWKT(polygon);
		RETURN polygon;
	WHEN perform_snapping = 1 THEN
		dec_prec := 10^(-digits);
		srid_id := ST_SRID(polygon);
		snapped_poly := ST_SnapToGrid(polygon, ST_GeomFromText('Point(0 0 0)'), dec_prec, dec_prec, dec_prec, 0);
		--RAISE NOTICE 'snapped poly %',ST_AsEWKT(snapped_poly);
		is_empty_geom := ST_IsEmpty(snapped_poly);
		--RAISE NOTICE 'is empty geom? %',is_empty_geom;

		IF is_empty_geom IS TRUE THEN
			RETURN NULL;
		ELSE -- there is a geometry from the resulting snap to grid process
			num_geoms := ST_NumGeometries(snapped_poly);
			IF num_geoms > 1 THEN
				RAISE NOTICE 'Number of geometries resulting from the snapped polygon is %', num_geoms;
			END IF;

			ring := ST_ExteriorRing(snapped_poly);
			o_ring := ring;
			FOR r IN SELECT
				foo.path[1]-1 AS zero_based_index,
				round(ST_x(foo.geom)::numeric,digits)::double precision AS px,
				round(ST_y(foo.geom)::numeric,digits)::double precision AS py,
				round(ST_z(foo.geom)::numeric,digits)::double precision AS pz
			FROM ST_DumpPoints(ring) AS foo
			LOOP
				o_ring := ST_SetPoint(o_ring, r.zero_based_index, ST_MakePoint(r.px, r.py, r.pz));
			END LOOP;
			o_ring := ST_SetSRID(o_ring, srid_id);

			n_int_rings	:= ST_NumInteriorRings(snapped_poly);
			IF n_int_rings > 0 THEN
				FOR i IN 1..n_int_rings LOOP
					ring := ST_InteriorRingN(snapped_poly, i);
					i_ring := ring;
					FOR r IN SELECT
						foo.path[1]-1 AS zero_based_index,
						round(ST_x(foo.geom)::numeric,digits)::double precision AS px,
						round(ST_y(foo.geom)::numeric,digits)::double precision AS py,
						round(ST_z(foo.geom)::numeric,digits)::double precision AS pz
					FROM ST_DumpPoints(ring) AS foo
					LOOP
						i_ring := ST_SetPoint(i_ring, r.zero_based_index, ST_MakePoint(r.px, r.py, r.pz));
					END LOOP;			
					i_rings := array_append(i_rings, i_ring);
				END LOOP;
			END IF;
		END IF;
ELSE
	RAISE EXCEPTION 'Value of "perform_snapping" input parameter is invalid. It must be either 0 or 1'; 
END CASE;

IF n_int_rings = 0 THEN
	--RAISE NOTICE 'o_ring: %', o_ring;
	new_polygon := ST_MakePolygon(o_ring);
ELSE
	--RAISE NOTICE 'o_ring: %', o_ring;
	--RAISE NOTICE 'i_rings: %', i_rings;
	new_polygon := ST_MakePolygon(o_ring, i_rings);
END IF;

--new_polygon := ST_RemoveRepeatedPoints(new_polygon, dec_prec);
area_poly := qgis_pkg.ST_3DArea_poly(new_polygon);
--RAISE NOTICE 'New polygon area: %',round(area_poly,8);

IF (area_poly IS NULL) OR (area_poly <= area_min) THEN
	--RAISE NOTICE 'Area: %, too small polygon. Returned null', round(area_poly,8);	
	RETURN NULL;
ELSE
	--RAISE NOTICE 'Area %',round(area_poly,8);
	--RAISE NOTICE 'New polygon: %',ST_AsEWKT(new_polygon);
	RETURN new_polygon;
END IF;

EXCEPTION
	WHEN QUERY_CANCELED THEN
		RAISE EXCEPTION 'qgis_pkg.snap_poly_to_grid(): Error QUERY_CANCELED';
	WHEN OTHERS THEN
		RAISE EXCEPTION 'qgis_pkg.snap_poly_to_grid(): %', SQLERRM;
END;
$$ LANGUAGE plpgsql;
COMMENT ON FUNCTION qgis_pkg.snap_poly_to_grid(geometry, integer, integer, numeric) IS 'Snaps 3D polygon to grid and drops it if it is smaller than the minimum area threshold';

--SELECT qgis_pkg.snap_poly_to_grid(geometry, 1, 2, 0.01) FROM citydb.surface_geometry WHERE geometry IS NOT NULL LIMIT 10000;

--**************************
RAISE NOTICE E'\n\nDone\n\n';
END $MAINBODY$;
--**************************


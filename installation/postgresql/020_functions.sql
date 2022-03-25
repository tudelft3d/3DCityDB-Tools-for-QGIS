-- ****************************************************************************
-- ****************************************************************************
--
--
-- CREATE FUNCTIONS in schema qgis_pkg
--
--
-- ****************************************************************************
-- ****************************************************************************


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
-- Create FUNCTION QGIS_PKG.GENERATE_MVIEW_BBOX_POLY
----------------------------------------------------------------
DROP FUNCTION IF EXISTS    qgis_pkg.generate_mview_bbox_poly(numeric[]) CASCADE;
CREATE OR REPLACE FUNCTION qgis_pkg.generate_mview_bbox_poly(
bbox_corners_array numeric[]    -- To be passed as 'ARRAY[1.1,2.2,3.3,4.4]' 
)
RETURNS geometry AS $$
DECLARE
srid_id integer;
x_min numeric;
y_min numeric;
x_max numeric;
y_max numeric;
mview_bbox_poly geometry(Polygon);

BEGIN
IF bbox_corners_array IS NULL THEN
	mview_bbox_poly := NULL;
ELSIF array_position(bbox_corners_array, NULL) IS NOT NULL THEN
	RAISE EXCEPTION 'Array with corner coordinates is invalid and contains a null value';
ELSE
	EXECUTE 'SELECT srid FROM citydb.database_srs LIMIT 1' INTO srid_id;
	x_min :=   floor(bbox_corners_array[1]);
	y_min :=   floor(bbox_corners_array[2]);
	x_max := ceiling(bbox_corners_array[3]);
	y_max := ceiling(bbox_corners_array[4]);
	mview_bbox_poly := ST_MakeEnvelope(x_min, y_min, x_max, y_max, srid_id);
	--RAISE NOTICE 'Polygon is: %', ST_AsEWKT(mview_bbox_poly);
END IF;

RETURN mview_bbox_poly;

EXCEPTION
	WHEN QUERY_CANCELED THEN
		RAISE EXCEPTION 'qgis_pkg.generate_mview_bbox_poly(): Error QUERY_CANCELED';
	WHEN OTHERS THEN
		RAISE EXCEPTION 'qgis_pkg.generate_mview_bbox_poly(): %', SQLERRM;
END;
$$ LANGUAGE plpgsql;
COMMENT ON FUNCTION qgis_pkg.generate_mview_bbox_poly(numeric[]) IS 'Create polygon of mview bbox';

--SELECT qgis_pkg.generate_mview_bbox_poly(
--	bbox_corners_array := ARRAY[220177, 481471, 220755, 482133]
--	bbox_corners_array := '{220177, 481471, 220755, 482133}'
--);


----------------------------------------------------------------
-- Create FUNCTION QGIS_PKG.SUPPORT_FOR_SCHEMA
----------------------------------------------------------------
-- Returns True if qgis_pkg schema supports the input schema.
-- In pratice it searches the schema for view names starting with
-- the input schema name.

DROP FUNCTION IF EXISTS    qgis_pkg.support_for_schema(varchar,varchar) CASCADE;
CREATE OR REPLACE FUNCTION qgis_pkg.support_for_schema(
	cdb_schema varchar,
	usr_schema varchar
)
RETURNS boolean
AS $$

BEGIN
PERFORM table_name
	FROM information_schema.tables 
    WHERE table_schema = usr_schema
	AND table_type = 'VIEW'
	AND table_name LIKE cdb_schema || '%'; 
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
COMMENT ON FUNCTION qgis_pkg.support_for_schema(varchar,varchar) IS 'Searches for citydb schema name into the view names of the user schema to determine if it supports the input citydb schema.';


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
DROP FUNCTION IF EXISTS    qgis_pkg.view_counter(varchar, varchar, varchar) CASCADE;
CREATE OR REPLACE FUNCTION qgis_pkg.view_counter(
usr_schema	varchar,
mview_name	varchar, 				-- Matirialised view name
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
			matviewname 
		FROM
			pg_matviews
		WHERE
			schemaname = usr_schema
			AND ispopulated
		) 
THEN
	IF extents IS NULL THEN
		EXECUTE format('SELECT count(co_id) FROM %I.%I', usr_schema, mview_name)
			INTO counter;
	ELSE
		db_srid := (SELECT srid FROM citydb.database_srs LIMIT 1);
		-- Create the geometry, but some more checks are needed if the srid is different
		query_geom := ST_GeomFromText(extents,db_srid);
		query_bbox := ST_Extent(query_geom);
		-- Actually, if for any reason the user is defining a bbox in another srid, we must transform
		-- it to the db_srid_it
		-- ST_Transform or something similar.
		-- Ideally, this check is carried out in QGIS and then bbox passed to the function is already in the same srid.

		EXECUTE FORMAT('SELECT count(t.co_id) FROM %I.%I t WHERE $1 && t.geom',
			usr_schema, mview_name, query_bbox) USING query_bbox INTO counter;
	END IF;
ELSE
	RAISE EXCEPTION 'View %.% does not exist',usr_schema, mview_name;	
END IF;
RETURN counter;
EXCEPTION
	WHEN QUERY_CANCELED THEN
		RAISE EXCEPTION 'qgis_pkg.view_counter(): Error QUERY_CANCELED';
  WHEN OTHERS THEN 
		RAISE NOTICE 'qgis_pkg.view_counter(): %', SQLERRM;
END;
$$ LANGUAGE plpgsql;
COMMENT ON FUNCTION qgis_pkg.view_counter(varchar, varchar, varchar) IS 'Counts records in the selected materialized view';

--SELECT qgis_pkg.view_counter('citydb_bdg_lod0_footprint', NULL);
--SELECT qgis_pkg.view_counter('citydb_bdg_lod0_footprint', ST_AsEWKT(ST_MakeEnvelope(229234, 476749, 230334, 479932)));


----------------------------------------------------------------
-- Create FUNCTION QGIS_PKG.COMPUTE_GA_INDICES
----------------------------------------------------------------
-- This function adds indices to the table containing the generic attributes
-- It must be run ONLY ONCE in a specific dbschema, upon installation.
DROP FUNCTION IF EXISTS    qgis_pkg.add_ga_indices(varchar) CASCADE;
CREATE OR REPLACE FUNCTION qgis_pkg.add_ga_indices(
cdb_schema varchar
)
RETURNS integer AS $$
DECLARE
sql_statement varchar;
BEGIN
-- Add some indices, if they do not already exists, to table cityobject_genericattrib;

RAISE NOTICE 'Adding indices to table cityobject_genericattrib';
sql_statement := format('
CREATE INDEX IF NOT EXISTS ga_attrname_inx ON %I.cityobject_genericattrib (attrname);
CREATE INDEX IF NOT EXISTS ga_datatype_inx ON %I.cityobject_genericattrib (datatype);
',
cdb_schema, cdb_schema
);
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

--PERFORM qgis_pkg.add_indices(cdb_schema := 'citydb');

----------------------------------------------------------------
-- Create FUNCTION QGIS_PKG.COMPUTE_SCHEMA_EXTENTS
----------------------------------------------------------------
DROP FUNCTION IF EXISTS    qgis_pkg.compute_schema_extents(varchar, varchar) CASCADE;
CREATE OR REPLACE FUNCTION qgis_pkg.compute_schema_extents(
IN cdb_schema	varchar,
IN usr_schema	varchar,
--
OUT x_min		numeric,
OUT y_min		numeric,
OUT x_max		numeric,
OUT y_max		numeric,
OUT srid_id		integer,
OUT upserted_id	integer
)
AS $$
DECLARE
cdb_envelope	geometry(Polygon) := NULL;

BEGIN
EXECUTE format('SELECT ST_Envelope(ST_Collect(co.envelope)) FROM %I.cityobject AS co', cdb_schema) INTO cdb_envelope;

IF cdb_envelope IS NOT NULL THEN
	srid_id := ST_SRID(cdb_envelope);
	x_min :=   floor(ST_Xmin(cdb_envelope));
	x_max := ceiling(ST_Xmax(cdb_envelope));
	y_min :=   floor(ST_Ymin(cdb_envelope));
	y_max := ceiling(ST_Ymax(cdb_envelope));
	cdb_envelope := ST_MakeEnvelope(x_min, y_min, x_max, y_max, srid_id);

	-- upsert statement for table qgis_pkg.envelope
	EXECUTE format('
		INSERT INTO %I.extents AS e (cdb_schema, bbox_type, envelope, creation_date)
		VALUES (%L, ''db_schema'', %L, clock_timestamp())
		ON CONFLICT ON CONSTRAINT extents_cdb_schema_bbox_type_key DO
			UPDATE SET
				envelope = %L,
				creation_date = clock_timestamp()
			WHERE
				e.cdb_schema = %L AND
				e.bbox_type = ''db_schema''
			RETURNING id',
		usr_schema,
		cdb_schema, cdb_envelope,
		cdb_envelope, cdb_schema)
	INTO STRICT upserted_id;
END IF;

EXCEPTION
	WHEN QUERY_CANCELED THEN
		RAISE EXCEPTION 'qgis_pkg.compute_schema_extents(): Error QUERY_CANCELED';
  WHEN OTHERS THEN 
		RAISE NOTICE 'qgis_pkg.compute_schema_extents(): %', SQLERRM;
END;
$$ LANGUAGE plpgsql;
COMMENT ON FUNCTION qgis_pkg.compute_schema_extents(varchar, varchar) IS 'Computes extents of the selected citydb schema';

--SELECT * FROM qgis_pkg.compute_schema_extents(cdb_schema := 'citydb');

----------------------------------------------------------------
-- Create FUNCTION QGIS_PKG.UPSERT_EXTENTS
----------------------------------------------------------------
DROP FUNCTION IF EXISTS    qgis_pkg.upsert_extents(varchar, varchar, varchar, geometry) CASCADE;
CREATE OR REPLACE FUNCTION qgis_pkg.upsert_extents(
usr_schema		varchar,
cdb_schema		varchar,
cdb_bbox_type	varchar,
cdb_envelope	geometry(Polygon) DEFAULT NULL
)
RETURNS integer AS $$
DECLARE
ext_label	varchar;
upserted_id	integer := NULL;

BEGIN

CASE
	WHEN cdb_bbox_type = 'db_schema' THEN
		upserted_id := (SELECT f.upserted_id FROM qgis_pkg.compute_schema_extents(cdb_schema) AS f);
	WHEN cdb_bbox_type IN ('m_view', 'qgis') THEN
		IF cdb_envelope IS NOT NULL THEN
			IF cdb_bbox_type = 'm_view' THEN
				ext_label := concat(cdb_schema,'-mview_bbox_extents');
			ELSE
				ext_label := concat(cdb_schema,'-qgis_bbox_extents');
			END IF;
		
			EXECUTE format('
				INSERT INTO %I.extents AS e (cdb_schema, bbox_type, label, envelope, creation_date)
				VALUES (%L, %L, %L, %L, clock_timestamp())
				ON CONFLICT ON CONSTRAINT extents_cdb_schema_bbox_type_key DO
					UPDATE SET
						envelope = %L,
						label = %L,
						creation_date = clock_timestamp()
					WHERE
						e.cdb_schema = %L AND
						e.bbox_type = %L
				RETURNING id',
				usr_schema,
				cdb_schema, cdb_bbox_type, ext_label, cdb_envelope,
				cdb_envelope, ext_label, cdb_schema, cdb_bbox_type)
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
COMMENT ON FUNCTION qgis_pkg.upsert_extents(varchar, varchar, varchar, geometry) IS 'Updates the extents table in user schema';

--SELECT qgis_pkg.upsert_extents(usr_schema := 'qgis_user', cdb_schema := 'citydb', cdb_bbox_type := 'db_schema', cdb_envelope := NULL);

----------------------------------------------------------------
-- Create FUNCTION QGIS_PKG.REFRESH_MVIEW
----------------------------------------------------------------
DROP FUNCTION IF EXISTS    qgis_pkg.refresh_mview(varchar, varchar, varchar) CASCADE;
CREATE OR REPLACE FUNCTION qgis_pkg.refresh_mview(
usr_schema	varchar,
cdb_schema	varchar DEFAULT NULL,
mview_name	varchar DEFAULT NULL
)
RETURNS integer AS $$
DECLARE
qgis_schema			 	varchar := 'qgis_pkg';
start_timestamp 		timestamptz(3);
stop_timestamp 			timestamptz(3);
f_start_timestamp 		timestamptz(3);
f_stop_timestamp 		timestamptz(3);
r 						RECORD;
mv_n_features 			integer DEFAULT 0;

BEGIN
IF usr_schema IS NULL THEN
	RAISE EXCEPTION 'usr_schema must not be NULL';
END IF;



f_start_timestamp := clock_timestamp();
CASE 
	WHEN cdb_schema IS NULL AND mview_name IS NULL THEN -- refresh all existing materialized views in user_schema
	RAISE NOTICE 'Refreshing all materialized views in schema %', qgis_schema;
		FOR r IN 
			SELECT 
				pg_namespace.nspname AS table_schema,
				pg_class.relname AS mview_name
			FROM 
				pg_catalog.pg_class
				INNER JOIN pg_catalog.pg_namespace ON pg_class.relnamespace = pg_namespace.oid
			WHERE 
				pg_class.relkind = 'm' 
				AND pg_namespace.nspname = usr_schema
			ORDER BY mview_name
		LOOP
			start_timestamp := clock_timestamp();
			EXECUTE format('REFRESH MATERIALIZED VIEW %I.%I', usr_schema, r.mview_name);
			stop_timestamp := clock_timestamp();
			EXECUTE format('SELECT count(co_id) FROM %I.%I', usr_schema, r.mview_name) INTO mv_n_features;
			EXECUTE format('
				UPDATE %I.layer_metadata AS lm SET
					n_features    = %L,
					refresh_date  = %L 
				WHERE lm.mv_name = %L;
			',usr_schema, mv_n_features, stop_timestamp, r.mview_name);

			RAISE NOTICE 'Refreshed materialized view "%.%" in %', usr_schema, r.mview_name, stop_timestamp-start_timestamp; 
		END LOOP;
		f_stop_timestamp := clock_timestamp();		
		RAISE NOTICE 'All materialized views in "%" refreshed in %!', usr_schema, f_stop_timestamp-f_start_timestamp; 	
		RETURN 1;

	WHEN cdb_schema IS NOT NULL THEN -- refresh all existing materialized views for that cdb_schema
		IF EXISTS (
			SELECT 1
			FROM 
				pg_catalog.pg_class
				INNER JOIN pg_catalog.pg_namespace ON pg_class.relnamespace = pg_namespace.oid
			WHERE 
				pg_class.relkind = 'm' 
				AND pg_namespace.nspname = usr_schema
				AND split_part(pg_class.relname::text, '_', 3) = cdb_schema
			LIMIT 1
		) THEN
			RAISE NOTICE 'Refreshing all materialized views in "%" associated to "%"', usr_schema, cdb_schema;		
			FOR r IN 
				SELECT 
					pg_namespace.nspname AS table_schema,
					pg_class.relname AS mview_name
				FROM 
					pg_catalog.pg_class
					INNER JOIN pg_catalog.pg_namespace ON pg_class.relnamespace = pg_namespace.oid
				WHERE 
					pg_class.relkind = 'm' 
					AND pg_namespace.nspname = usr_schema
					AND split_part(pg_class.relname::text, '_', 3) = cdb_schema
				ORDER BY table_schema, mview_name
			LOOP
				start_timestamp := clock_timestamp();
				EXECUTE format('REFRESH MATERIALIZED VIEW %I.%I', usr_schema, r.mview_name);
				stop_timestamp := clock_timestamp();
				EXECUTE format('SELECT count(co_id) FROM %I.%I', usr_schema, r.mview_name) INTO mv_n_features;
				EXECUTE format('
					UPDATE %I.layer_metadata AS lm SET
						n_features    = %L,
						refresh_date  = %L 
					WHERE lm.mv_name = %L;
				',usr_schema, mv_n_features, stop_timestamp, r.mview_name);				

				RAISE NOTICE 'Refreshed materialized view "%.%" in %', usr_schema, r.mview_name, stop_timestamp-start_timestamp; 
			END LOOP;
			f_stop_timestamp := clock_timestamp();		
			RAISE NOTICE 'All materialized views in "%" for "%" refreshed in %!!', usr_schema, cdb_schema, f_stop_timestamp-f_start_timestamp; 	
			RETURN 1;
		ELSE
			RAISE NOTICE 'No schema found with name "%"', cdb_schema;
			RETURN 0;			
		END IF;

	WHEN mview_name IS NOT NULL THEN -- refresh only a specific materialized views
		IF EXISTS (SELECT 1 
					FROM 
						pg_catalog.pg_class
						INNER JOIN pg_catalog.pg_namespace ON pg_class.relnamespace = pg_namespace.oid
					WHERE 
						pg_class.relkind = 'm' 
						AND pg_namespace.nspname = usr_schema
						AND pg_class.relname = mview_name
		) THEN
			RAISE NOTICE 'Refreshing materialized view "%.%""', usr_schema, mview_name;
			start_timestamp := clock_timestamp();
			EXECUTE format('REFRESH MATERIALIZED VIEW %I.%I', usr_schema, mview_name);
			stop_timestamp := clock_timestamp();
			EXECUTE format('SELECT count(co_id) FROM %I.%I', usr_schema, mview_name) INTO mv_n_features;
			EXECUTE format('
				UPDATE %I.layer_metadata AS lm SET
					n_features    = %L,
					refresh_date  = %L 
				WHERE lm.mv_name = %L;
			',usr_schema, mv_n_features, stop_timestamp, mview_name);	
			RAISE NOTICE 'Refreshed materialized view "%.%" in %', usr_schema, mview_name, stop_timestamp-start_timestamp; 
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
COMMENT ON FUNCTION qgis_pkg.refresh_mview(varchar, varchar, varchar) IS 'Refresh materialized view(s) in user schema';

--SELECT qgis_pkg.refresh_mview_new(usr_schema := 'qgis_user');
--SELECT qgis_pkg.refresh_mview(usr_schema := 'qgis_user', cdb_schema := 'citydb3');

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
-- Create FUNCTION QGIS_PKG.ST_SNAP_POLY_TO_GRID
----------------------------------------------------------------
DROP FUNCTION IF EXISTS    qgis_pkg.st_snap_poly_to_grid(geometry, integer, integer, numeric) CASCADE;
CREATE OR REPLACE FUNCTION qgis_pkg.st_snap_poly_to_grid(
polygon 			geometry,
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
	new_polygon := ST_MakePolygon(o_ring);
ELSE
	new_polygon := ST_MakePolygon(o_ring, i_rings);
END IF;

area_poly := qgis_pkg.ST_3DArea_poly(new_polygon);

IF (area_poly IS NULL) OR (area_poly <= area_min) THEN
	RETURN NULL;
ELSE
	RETURN new_polygon;
END IF;

EXCEPTION
	WHEN QUERY_CANCELED THEN
		RAISE EXCEPTION 'qgis_pkg.st_snap_poly_to_grid(): Error QUERY_CANCELED';
	WHEN OTHERS THEN
		RAISE EXCEPTION 'qgis_pkg.st_snap_poly_to_grid(): %', SQLERRM;
END;
$$ LANGUAGE plpgsql;
COMMENT ON FUNCTION qgis_pkg.st_snap_poly_to_grid(geometry, integer, integer, numeric) IS 'Snaps 3D polygon to grid and drops it if it is smaller than the minimum area threshold';

--SELECT qgis_pkg.st_snap_poly_to_grid(geometry, 1, 2, 0.01) FROM citydb.surface_geometry WHERE geometry IS NOT NULL LIMIT 10000;

----------------------------------------------------------------
-- Create FUNCTION QGIS_PKG.DROP_LAYERS
----------------------------------------------------------------
-- Drops layers (e.g. mviews, views, and associated triggers)
DROP FUNCTION IF EXISTS    qgis_pkg.drop_layers(varchar, varchar, varchar) CASCADE;
CREATE OR REPLACE FUNCTION qgis_pkg.drop_layers(
usr_schema		varchar,
cdb_schema		varchar DEFAULT NULL,
feat_type		varchar DEFAULT NULL
)
RETURNS integer
AS $$
DECLARE
r RECORD;
BEGIN

CASE 
	WHEN cdb_schema IS NULL THEN 
		RAISE NOTICE 'Dropping all views in user schema %', usr_schema;
		FOR r IN 
			SELECT pg_namespace.nspname AS table_schema, pg_class.relname AS mview_name
			FROM pg_catalog.pg_class
				INNER JOIN pg_catalog.pg_namespace ON pg_class.relnamespace = pg_namespace.oid
			WHERE 
				pg_class.relkind = 'm' 
				AND pg_namespace.nspname = usr_schema
			ORDER BY mview_name
		LOOP
			EXECUTE format('DROP MATERIALIZED VIEW %I.%I CASCADE', usr_schema, r.mview_name);
		END LOOP;
		
	WHEN cdb_schema IS NOT NULL AND feat_type IS NULL THEN
		RAISE NOTICE 'Dropping all views in user schema % related to cdb_schema %', usr_schema, cdb_schema;
		FOR r IN 
			SELECT pg_namespace.nspname AS table_schema, pg_class.relname AS mview_name
			FROM pg_catalog.pg_class
				INNER JOIN pg_catalog.pg_namespace ON pg_class.relnamespace = pg_namespace.oid
			WHERE 
				pg_class.relkind = 'm' 
				AND pg_namespace.nspname = usr_schema
				AND split_part(pg_class.relname::text, '_', 3) = cdb_schema
			ORDER BY mview_name
		LOOP
			EXECUTE format('DROP MATERIALIZED VIEW %I.%I CASCADE', usr_schema, r.mview_name);
		END LOOP;

	WHEN cdb_schema IS NOT NULL AND feat_type IS NOT NULL THEN
		RAISE NOTICE 'Dropping all views in user schema % related to cdb_schema % for feature type %', usr_schema, cdb_schema, feat_type;
		CASE feat_type
			WHEN 'Bridge' THEN
				FOR r IN 
					SELECT pg_namespace.nspname AS table_schema, pg_class.relname AS mview_name
					FROM pg_catalog.pg_class
						INNER JOIN pg_catalog.pg_namespace ON pg_class.relnamespace = pg_namespace.oid
					WHERE 
						pg_class.relkind = 'm' 
						AND pg_namespace.nspname = usr_schema
						AND split_part(pg_class.relname::text, '_', 3) = cdb_schema
						AND split_part(pg_class.relname::text, '_', 4) = 'bri'						
					ORDER BY mview_name
				LOOP
					EXECUTE format('DROP MATERIALIZED VIEW %I.%I CASCADE', usr_schema, r.mview_name);
				END LOOP;

			WHEN 'Building' THEN
				FOR r IN 
					SELECT pg_namespace.nspname AS table_schema, pg_class.relname AS mview_name
					FROM pg_catalog.pg_class
						INNER JOIN pg_catalog.pg_namespace ON pg_class.relnamespace = pg_namespace.oid
					WHERE 
						pg_class.relkind = 'm' 
						AND pg_namespace.nspname = usr_schema
						AND split_part(pg_class.relname::text, '_', 3) = cdb_schema
						AND split_part(pg_class.relname::text, '_', 4) = 'bdg'						
					ORDER BY mview_name
				LOOP
					EXECUTE format('DROP MATERIALIZED VIEW %I.%I CASCADE', usr_schema, r.mview_name);
				END LOOP;

			WHEN 'CityFurniture' THEN	
				FOR r IN 
					SELECT pg_namespace.nspname AS table_schema, pg_class.relname AS mview_name
					FROM pg_catalog.pg_class
						INNER JOIN pg_catalog.pg_namespace ON pg_class.relnamespace = pg_namespace.oid
					WHERE 
						pg_class.relkind = 'm' 
						AND pg_namespace.nspname = usr_schema
						AND split_part(pg_class.relname::text, '_', 3) = cdb_schema
						AND split_part(pg_class.relname::text, '_', 4) = 'city'						
					ORDER BY mview_name
				LOOP
					EXECUTE format('DROP MATERIALIZED VIEW %I.%I CASCADE', usr_schema, r.mview_name);
				END LOOP;

			WHEN 'CityObjectGroup' THEN				
			
			WHEN 'Generics' THEN
				FOR r IN 
					SELECT pg_namespace.nspname AS table_schema, pg_class.relname AS mview_name
					FROM pg_catalog.pg_class
						INNER JOIN pg_catalog.pg_namespace ON pg_class.relnamespace = pg_namespace.oid
					WHERE 
						pg_class.relkind = 'm' 
						AND pg_namespace.nspname = usr_schema
						AND split_part(pg_class.relname::text, '_', 3) = cdb_schema
						AND split_part(pg_class.relname::text, '_', 4) = 'gen'						
					ORDER BY mview_name
				LOOP
					EXECUTE format('DROP MATERIALIZED VIEW %I.%I CASCADE', usr_schema, r.mview_name);
				END LOOP;

			WHEN 'LandUse' THEN
				FOR r IN 
					SELECT pg_namespace.nspname AS table_schema, pg_class.relname AS mview_name
					FROM pg_catalog.pg_class
						INNER JOIN pg_catalog.pg_namespace ON pg_class.relnamespace = pg_namespace.oid
					WHERE 
						pg_class.relkind = 'm' 
						AND pg_namespace.nspname = usr_schema
						AND split_part(pg_class.relname::text, '_', 3) = cdb_schema
						AND split_part(pg_class.relname::text, '_', 4) = 'land'						
					ORDER BY mview_name
				LOOP
					EXECUTE format('DROP MATERIALIZED VIEW %I.%I CASCADE', usr_schema, r.mview_name);
				END LOOP;

			WHEN 'Relief' THEN
				FOR r IN 
					SELECT pg_namespace.nspname AS table_schema, pg_class.relname AS mview_name
					FROM pg_catalog.pg_class
						INNER JOIN pg_catalog.pg_namespace ON pg_class.relnamespace = pg_namespace.oid
					WHERE 
						pg_class.relkind = 'm' 
						AND pg_namespace.nspname = usr_schema
						AND split_part(pg_class.relname::text, '_', 3) = cdb_schema
						AND split_part(pg_class.relname::text, '_', 4) IN ('relief', 'tin')						
					ORDER BY mview_name
				LOOP
					EXECUTE format('DROP MATERIALIZED VIEW %I.%I CASCADE', usr_schema, r.mview_name);
				END LOOP;

			WHEN 'Transportation' THEN
				FOR r IN 
					SELECT pg_namespace.nspname AS table_schema, pg_class.relname AS mview_name
					FROM pg_catalog.pg_class
						INNER JOIN pg_catalog.pg_namespace ON pg_class.relnamespace = pg_namespace.oid
					WHERE 
						pg_class.relkind = 'm' 
						AND pg_namespace.nspname = usr_schema
						AND split_part(pg_class.relname::text, '_', 3) = cdb_schema
						AND split_part(pg_class.relname::text, '_', 4) IN ('railway', 'road', 'square', 'track', 'tran')						
					ORDER BY mview_name
				LOOP
					EXECUTE format('DROP MATERIALIZED VIEW %I.%I CASCADE', usr_schema, r.mview_name);
				END LOOP;

			WHEN 'Tunnel' THEN
				FOR r IN 
					SELECT pg_namespace.nspname AS table_schema, pg_class.relname AS mview_name
					FROM pg_catalog.pg_class
						INNER JOIN pg_catalog.pg_namespace ON pg_class.relnamespace = pg_namespace.oid
					WHERE 
						pg_class.relkind = 'm' 
						AND pg_namespace.nspname = usr_schema
						AND split_part(pg_class.relname::text, '_', 3) = cdb_schema
						AND split_part(pg_class.relname::text, '_', 4) = 'tun'						
					ORDER BY mview_name
				LOOP
					EXECUTE format('DROP MATERIALIZED VIEW %I.%I CASCADE', usr_schema, r.mview_name);
				END LOOP;

			WHEN 'Vegetation' THEN
				FOR r IN 
					SELECT pg_namespace.nspname AS table_schema, pg_class.relname AS mview_name
					FROM pg_catalog.pg_class
						INNER JOIN pg_catalog.pg_namespace ON pg_class.relnamespace = pg_namespace.oid
					WHERE 
						pg_class.relkind = 'm' 
						AND pg_namespace.nspname = usr_schema
						AND split_part(pg_class.relname::text, '_', 3) = cdb_schema
						AND split_part(pg_class.relname::text, '_', 4) IN ('sol', 'plant')						
					ORDER BY mview_name
				LOOP
					EXECUTE format('DROP MATERIALIZED VIEW %I.%I CASCADE', usr_schema, r.mview_name);
				END LOOP;

			WHEN 'WaterBody' THEN
				FOR r IN 
					SELECT pg_namespace.nspname AS table_schema, pg_class.relname AS mview_name
					FROM pg_catalog.pg_class
						INNER JOIN pg_catalog.pg_namespace ON pg_class.relnamespace = pg_namespace.oid
					WHERE 
						pg_class.relkind = 'm' 
						AND pg_namespace.nspname = usr_schema
						AND split_part(pg_class.relname::text, '_', 3) = cdb_schema
						AND split_part(pg_class.relname::text, '_', 4) = 'waterbody'						
					ORDER BY mview_name
				LOOP
					EXECUTE format('DROP MATERIALIZED VIEW %I.%I CASCADE', usr_schema, r.mview_name);
				END LOOP;
		ELSE
		END CASE;
ELSE
END CASE;	

RETURN 1;

EXCEPTION
	WHEN QUERY_CANCELED THEN
		RAISE EXCEPTION 'qgis_pkg.drop_layers(): Error QUERY_CANCELED';
  WHEN OTHERS THEN 
		RAISE NOTICE 'qgis_pkg.drop_layers(): %', SQLERRM;
END;
$$ LANGUAGE plpgsql;
COMMENT ON FUNCTION qgis_pkg.drop_layers(varchar, varchar, varchar) IS 'Drops layers in user schema';

--SELECT qgis_pkg.drop_layers(usr_schema:= 'qgis_pkg', cdb_schema:= 'citydb');
--SELECT qgis_pkg.drop_layers(usr_schema:= 'qgis_pkg', cdb_schema:= 'citydb', feat_type := 'Building');
--SELECT qgis_pkg.drop_layers(usr_schema:= 'qgis_pkg', cdb_schema:= 'citydb', feat_type := 'Vegetation');
--SELECT qgis_pkg.drop_layers(usr_schema:= 'qgis_pkg', cdb_schema:= 'citydb', feat_type := 'Relief');
--SELECT qgis_pkg.drop_layers(usr_schema:= 'qgis_pkg', cdb_schema:= 'citydb', feat_type := 'WaterBody');
--SELECT qgis_pkg.drop_layers(usr_schema:= 'qgis_pkg', cdb_schema:= 'citydb', feat_type := 'Generics');
--SELECT qgis_pkg.drop_layers(usr_schema:= 'qgis_pkg', cdb_schema:= 'citydb', feat_type := 'LandUse');
--SELECT qgis_pkg.drop_layers(usr_schema:= 'qgis_pkg', cdb_schema:= 'citydb', feat_type := 'Transportation');
--SELECT qgis_pkg.drop_layers(usr_schema:= 'qgis_pkg', cdb_schema:= 'citydb', feat_type := 'LandUse');
--SELECT qgis_pkg.drop_layers(usr_schema:= 'qgis_pkg', cdb_schema:= 'citydb', feat_type := 'CityFurniture');
--SELECT qgis_pkg.drop_layers(usr_schema:= 'qgis_pkg', cdb_schema:= 'citydb', feat_type := 'Tunnel');


----------------------------------------------------------------
-- Create FUNCTION QGIS_PKG.QGIS_PKG_VERSION
----------------------------------------------------------------
-- Returns the version of the QGIS Package
DROP FUNCTION IF EXISTS    qgis_pkg.qgis_pkg_version() CASCADE;
CREATE OR REPLACE FUNCTION qgis_pkg.qgis_pkg_version(
OUT version text,
OUT major_version integer,
OUT minor_version integer,
OUT minor_revision integer
)
RETURNS record
AS $$
DECLARE
BEGIN
major_version  := 0;
minor_version  := 3;
minor_revision := 0;
version := concat(major_version,',',minor_version,',',minor_revision);

EXCEPTION
	WHEN QUERY_CANCELED THEN
		RAISE EXCEPTION 'qgis_pkg.qgis_pkg_version(): Error QUERY_CANCELED';
  WHEN OTHERS THEN 
		RAISE NOTICE 'qgis_pkg.qgis_pkg_version(): %', SQLERRM;
END;
$$ LANGUAGE plpgsql;
COMMENT ON FUNCTION qgis_pkg.qgis_pkg_version() IS 'Returns the version of the QGIS Package';

-- SELECT version, major_version, minor_version, minor_revision FROM qgis_pkg.qgis_pkg_version();


----------------------------------------------------------------
-- Create FUNCTION QGIS_PKG.CREATE_QGIS_USER_SCHEMA
----------------------------------------------------------------
-- Creates the qgis schema for a user
DROP FUNCTION IF EXISTS    qgis_pkg.create_qgis_user_schema(varchar) CASCADE;
CREATE OR REPLACE FUNCTION qgis_pkg.create_qgis_user_schema(
usr_name	varchar
)
RETURNS integer
AS $$
DECLARE
usr_schema 			varchar;
usr_schema_prefix	varchar := 'qgis_'; 

BEGIN
IF usr_name IS NULL THEN
	usr_name := 'user';
END IF;

usr_schema := concat(usr_schema_prefix, usr_name);

-- ************************************************************
-- THIS IS ONLY TEMPORARILY: HARD CODE THE USER TO 'postgres', even if it is different
usr_name := 'postgres';
usr_schema := concat(usr_schema_prefix, 'user');
-- ************************************************************

RAISE NOTICE 'Creating schema "%" for user "%"', usr_schema, usr_name;

-- This must be substituted by a more complex function;
EXECUTE format('DROP SCHEMA IF EXISTS %I CASCADE', usr_schema);

EXECUTE format('CREATE SCHEMA IF NOT EXISTS %I', usr_schema);

EXECUTE format('
DROP TABLE IF EXISTS %I.layer_metadata CASCADE;
CREATE TABLE %I.layer_metadata (LIKE qgis_pkg.layer_metadata INCLUDING ALL);
ALTER TABLE %I.layer_metadata OWNER TO %I;

DROP TABLE IF EXISTS %I.extents CASCADE;
CREATE TABLE %I.extents (LIKE qgis_pkg.extents INCLUDING ALL);
ALTER TABLE %I.extents OWNER TO %I;

DROP TABLE IF EXISTS %I.enumeration CASCADE;
CREATE TABLE %I.enumeration (LIKE qgis_pkg.enumeration INCLUDING ALL);
ALTER TABLE %I.enumeration OWNER TO %I;

DROP TABLE IF EXISTS %I.enumeration_value CASCADE;
CREATE TABLE %I.enumeration_value (LIKE qgis_pkg.enumeration_value INCLUDING ALL);
ALTER TABLE %I.enumeration_value OWNER TO %I;

DROP TABLE IF EXISTS %I.codelist CASCADE;
CREATE TABLE %I.codelist (LIKE qgis_pkg.codelist INCLUDING ALL);
ALTER TABLE %I.codelist OWNER TO %I;

DROP TABLE IF EXISTS %I.codelist_value CASCADE;
CREATE TABLE %I.codelist_value (LIKE qgis_pkg.codelist_value INCLUDING ALL);
ALTER TABLE %I.codelist_value OWNER TO %I;
',
usr_schema,usr_schema,usr_schema,usr_name,
usr_schema,usr_schema,usr_schema,usr_name,
usr_schema,usr_schema,usr_schema,usr_name,
usr_schema,usr_schema,usr_schema,usr_name,
usr_schema,usr_schema,usr_schema,usr_name,
usr_schema,usr_schema,usr_schema,usr_name
);

EXECUTE format('
INSERT INTO %I.extents SELECT * FROM qgis_pkg.extents ORDER BY id;
INSERT INTO %I.enumeration SELECT * FROM qgis_pkg.enumeration ORDER BY id;
INSERT INTO %I.enumeration_value SELECT * FROM qgis_pkg.enumeration_value ORDER BY id;
INSERT INTO %I.codelist SELECT * FROM qgis_pkg.codelist ORDER BY id;
INSERT INTO %I.codelist_value SELECT * FROM qgis_pkg.codelist_value ORDER BY id;
',
usr_schema,usr_schema,usr_schema,usr_schema,usr_schema
);

EXECUTE format('
--DROP VIEW IF EXISTS %I.v_enumeration_value CASCADE;
CREATE VIEW         %I.v_enumeration_value AS
SELECT
	ev.id,
	e.data_model,
	e.name,
	ev.value,
	ev.description,
	e.name_space
FROM
	%I.enumeration_value AS ev
	INNER JOIN %I.enumeration AS e ON (ev.enum_id = e.id);
ALTER TABLE %I.v_enumeration_value OWNER TO %I;

--DROP VIEW IF EXISTS %I.v_codelist_value CASCADE;
CREATE VIEW         %I.v_codelist_value AS
SELECT
	cv.id,
	c.data_model,
	c.name,
	cv.value,
	cv.description,
	c.name_space
FROM
	%I.codelist_value AS cv
	INNER JOIN %I.codelist AS c ON (cv.code_id = c.id);
ALTER TABLE %I.v_codelist_value OWNER TO %I;
',
usr_schema,usr_schema,usr_schema,usr_schema,usr_schema,usr_name,
usr_schema,usr_schema,usr_schema,usr_schema,usr_schema,usr_name
);

EXECUTE format('DELETE FROM qgis_pkg.usr_schema AS u WHERE u.usr_name = %L',usr_name);

INSERT INTO qgis_pkg.usr_schema (usr_name, usr_schema, creation_date) VALUES
(usr_name, usr_schema, clock_timestamp());

RETURN 1;

EXCEPTION
	WHEN QUERY_CANCELED THEN
		RAISE EXCEPTION 'qgis_pkg.create_qgis_user_schema(): Error QUERY_CANCELED';
		RETURN 0;
	WHEN OTHERS THEN 
		RAISE NOTICE 'qgis_pkg.create_qgis_user_schema(): %', SQLERRM;
		RETURN 0;
END;
$$ LANGUAGE plpgsql;
COMMENT ON FUNCTION qgis_pkg.create_qgis_user_schema(varchar) IS 'Creates the qgis schema for a user';

--SELECT qgis_pkg.create_qgis_user_schema('user');

----------------------------------------------------------------
-- Create FUNCTION QGIS_PKG.GENERATE_SQL_TRIGGERS
----------------------------------------------------------------
-- Function to generate SQL for triggers
DROP FUNCTION IF EXISTS    qgis_pkg.generate_sql_triggers(varchar, varchar, varchar, varchar) CASCADE;
CREATE OR REPLACE FUNCTION qgis_pkg.generate_sql_triggers(
view_name			varchar,
tr_function_suffix	varchar,
usr_name			varchar DEFAULT 'postgres',  -- this default will have to be dropped
usr_schema			varchar DEFAULT 'qgis_user'  -- this default will have to be dropped
)
RETURNS text
AS $$
DECLARE
tr					RECORD;
trigger_f			varchar;
slq_stat_trig_part	text := NULL;
sql_statement		text := NULL;

BEGIN

FOR tr IN 
	SELECT * FROM (VALUES
	('ins'::varchar,	'insert'::varchar,	'INSERT'::varchar),
	('upd',				'update',			'UPDATE'),
	('del',				'delete',			'DELETE')	
	) AS t(tr_short, tr_small, tr_cap)
LOOP

--trigger_f := concat('tr_',tr.tr_short,'_land_use()');
--trigger_f := concat('tr_',tr.tr_short,'_',tr_function_suffix,'()');
trigger_f := format('tr_%I_%I()',tr.tr_short,tr_function_suffix);

slq_stat_trig_part := NULL;
/*
slq_stat_trig_part := concat('
DROP TRIGGER IF EXISTS tr_',tr.tr_short,'_',view_name,' ON ',usr_schema,'.',view_name,';
CREATE TRIGGER         tr_',tr.tr_short,'_',view_name,'
	INSTEAD OF ',tr.tr_cap,' ON ',usr_schema,'.',view_name,'
	FOR EACH ROW
	EXECUTE PROCEDURE qgis_pkg.',trigger_f,';
COMMENT ON TRIGGER tr_',tr.tr_short,'_',view_name,' ON ',usr_schema,'.',view_name,' 
	IS ''Fired upon ',tr.tr_small,' into view ',usr_schema,'.',view_name,''';
');
*/

slq_stat_trig_part := format('
DROP TRIGGER IF EXISTS tr_%I_%I ON %I.%I;
CREATE TRIGGER         tr_%I_%I
	INSTEAD OF %s ON %I.%I
	FOR EACH ROW
	EXECUTE PROCEDURE qgis_pkg.%s;
COMMENT ON TRIGGER tr_%I_%I ON %I.%I 
	IS ''Fired upon %I into view %I.%I'';
',
tr.tr_short, view_name, usr_schema, view_name,
tr.tr_short, view_name,
tr.tr_cap, usr_schema, view_name,
trigger_f,
tr.tr_short, view_name, usr_schema, view_name,
tr.tr_small, usr_schema, view_name
);

sql_statement := concat(sql_statement, slq_stat_trig_part);

END LOOP;

RETURN sql_statement;

EXCEPTION
	WHEN QUERY_CANCELED THEN
		RAISE EXCEPTION 'qgis_pkg.generate_sql_triggers(): Error QUERY_CANCELED';
  WHEN OTHERS THEN 
		RAISE NOTICE 'qgis_pkg.generate_sql_triggers(): %', SQLERRM;
END;
$$ LANGUAGE plpgsql;
COMMENT ON FUNCTION qgis_pkg.generate_sql_triggers(varchar, varchar, varchar, varchar) IS 'Generate SQL to create triggers for updatable views';



--**************************
DO $$
BEGIN
RAISE NOTICE E'\n\nDone\n\n';
END $$;
--**************************
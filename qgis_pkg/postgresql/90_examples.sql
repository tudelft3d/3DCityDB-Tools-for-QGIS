-- ****************************************************************************
-- ****************************************************************************
--
--
-- Examples of how to use the functions and in which order
--
--
-- ****************************************************************************
-- ****************************************************************************

DO $MAINBODY$
DECLARE
-- These paramters can be changed
test_citydb_schema		varchar := 'citydb';
test_use_mview_bbox     boolean := TRUE; -- DEFAULT is FALSE, if 1 it will use the mview_bbox
test_perform_snapping	integer := 0; -- if set to 1, then also the next 2 parameters will have effect
test_digits 			integer := 2;
test_area_poly_min 	 	numeric := 0.01;
test_mview_bbox		 	geometry:= NULL;

query_result integer := NULL;
r RECORD;

BEGIN
/*

-- This needs to be run only once to add a couple of indices to the generic attribute table.
query_result := (SELECT qgis_pkg.add_ga_indices(
	citydb_schema 		:= test_citydb_schema
	));
IF query_result IS NOT NULL THEN
	RAISE NOTICE E'\n\n---- Added indices for generic attributes table in db_schema %\n\n',test_citydb_schema; 
END IF;


query_result := (SELECT qgis_pkg.upsert_extents(
	citydb_schema 		:= test_citydb_schema,
	citydb_bbox_type 	:= 'db_schema',
	citydb_envelope 	:= NULL
	));
IF query_result IS NOT NULL THEN
	RAISE NOTICE E'\n\n---- Upserted extents for db_schema %\n\n',test_citydb_schema; 
END IF;


query_result := (SELECT qgis_pkg.create_mviews(
	citydb_schema 		:= test_citydb_schema,
	perform_snapping 	:= test_perform_snapping,
	digits 				:= test_digits,
	area_poly_min 		:= test_area_poly_min,
	mview_bbox 			:= test_mview_bbox
	));
IF query_result IS NOT NULL THEN
	RAISE NOTICE E'\n\n---- Created mviews for db_schema %\n\n', test_citydb_schema;
END IF;


query_result := (SELECT qgis_pkg.create_updatable_views(
	citydb_schema	:= test_citydb_schema,
	mview_bbox 		:= NULL
	));
IF query_result IS NOT NULL THEN
	RAISE NOTICE E'\n\n---- Created updatable views for db_schema %\n\n', test_citydb_schema;
END IF;


query_result := (SELECT qgis_pkg.refresh_mview(
	citydb_schema := test_citydb_schema
	));
IF query_result IS NOT NULL THEN	
	RAISE NOTICE 'Refreshed mviews for citydb schema %', test_citydb_schema;
END IF;

*/

FOR r IN
	SELECT * FROM (VALUES
	('citydb'	, ST_MakeEnvelope(220177,481471,220755,482133, 28992)),
	('citydb2'	, ST_MakeEnvelope(225841,477299,226537,478088, 28992)),	
	('citydb3'	, ST_MakeEnvelope(232068,480433,232525,480818, 28992))	
	) AS t(citydb_schema, mview_bbox)

LOOP

IF test_use_mview_bbox IS FALSE THEN
	test_mview_bbox := NULL;
ELSE
	test_mview_bbox := r.mview_bbox;
END IF;

-- This needs to be run only once to add a couple of indices to the generic attribute table.
query_result := (SELECT qgis_pkg.add_ga_indices(
	citydb_schema 		:= r.citydb_schema
	));
IF query_result IS NOT NULL THEN
	RAISE NOTICE E'\n\n---- Added indices for generic attributes table in db_schema %\n\n', r.citydb_schema; 
END IF;


query_result := (SELECT qgis_pkg.upsert_extents(
	citydb_schema 		:= r.citydb_schema,
	citydb_bbox_type 	:= 'db_schema' --,
--	citydb_envelope 	:= NULL
	));
IF query_result IS NOT NULL THEN
	RAISE NOTICE E'\n\n---- Upserted extents for db_schema %\n\n', r.citydb_schema; 
END IF;


query_result := (SELECT qgis_pkg.create_mviews(
	citydb_schema 		:= r.citydb_schema,
	perform_snapping 	:= test_perform_snapping,
	digits 				:= test_digits,
	area_poly_min 		:= test_area_poly_min,
	mview_bbox 			:= test_mview_bbox
	));
IF query_result IS NOT NULL THEN
	RAISE NOTICE E'\n\n---- Created mviews for db_schema %\n\n', r.citydb_schema;
END IF;


query_result := (SELECT qgis_pkg.create_updatable_views(
	citydb_schema	:= r.citydb_schema,
	mview_bbox 		:= test_mview_bbox
	));
IF query_result IS NOT NULL THEN
	RAISE NOTICE E'\n\n---- Created updatable views for db_schema %\n\n', r.citydb_schema;
END IF;


query_result := (SELECT qgis_pkg.refresh_mview(
	citydb_schema := r.citydb_schema
	));
IF query_result IS NOT NULL THEN	
	RAISE NOTICE 'Refreshed mviews for citydb schema %', r.citydb_schema;
END IF;

END LOOP;



--**************************
RAISE NOTICE E'\n\nDone\n\n';
END $MAINBODY$;
--**************************

-- ************************** TESTS **************************
-- SELECT id, name, relative_to_terrain, description FROM qgis_pkg.citydb_building_lod0_footprint WHERE id=51
-- UPDATE qgis_pkg.citydb_bdg_lod0_footprint SET
-- description='9aaaaa',
-- storeys_above_ground=10
-- WHERE id=51;
-- SELECT *
--id, name, relative_to_terrain, description, storeys_above_ground 
--FROM qgis_pkg.citydb_bdg_lod0_footprint
-- FROM qgis_pkg.citydb_bdg_lod2 
-- WHERE id=51;

-- UPDATE qgis_pkg.citydb_tin_relief_lod2 SET
-- description='19aaaaa',
-- lod=1,
-- max_length=18,
-- max_length_unit='km'
-- WHERE name='Tile_0_0';
-- SELECT *
-- FROM qgis_pkg.citydb_tin_relief_lod2_tin
-- WHERE name='Tile_0_0';

--SELECT qgis_pkg.refresh_materialized_view(mview_name:='_geom_citydb_tin_relief_lod1_tin');

-- UPDATE qgis_pkg.citydb_solitary_vegetat_object_lod2_implicitsurf SET
-- description='sjhjhjhdsdsdsdsdsd',
-- height=10,
-- height_unit='m',
-- crown_diameter=22,
-- crown_diameter_unit='m'
-- WHERE id=905365;

-- SELECT *
-- FROM qgis_pkg.citydb_solitary_vegetat_object_lod2_implicitsurf
-- WHERE id=905365;
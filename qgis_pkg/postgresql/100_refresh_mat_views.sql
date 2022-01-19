-- This one refreshes all views of all schemas
SELECT qgis_pkg.refresh_materialized_view();

-- This one refreshes all views of declared schema
--SELECT qgis_pkg.refresh_materialized_view('citydb');
-- alternative (better) syntax
--SELECT qgis_pkg.refresh_materialized_view(mview_schema:='citydb');

-- This one refreshes a specific view
--SELECT qgis_pkg.refresh_materialized_view(NULL, '_geom_citydb_bdg_lod0_footprint');
-- alternative (better) syntax
--SELECT qgis_pkg.refresh_materialized_view(mview_name:='_geom_citydb_bdg_lod0_footprint');

--**************************
DO $$
BEGIN
RAISE NOTICE 'Done';
END $$;
--**************************


-- ************************** TESTS **************************

/*
--SELECT id, name, relative_to_terrain, description FROM qgis_pkg.citydb_building_lod0_footprint WHERE id=51
UPDATE qgis_pkg.citydb_building_lod0_footprint SET
description='9aaaaa',
storeys_above_ground=10
WHERE id=51;
SELECT *
--id, name, relative_to_terrain, description, storeys_above_ground 
--FROM qgis_pkg.citydb_building_lod0_footprint
FROM qgis_pkg.citydb_building_lod2_solid 
WHERE id=51;


UPDATE qgis_pkg.citydb_tin_relief_lod2_tin SET
description='19aaaaa',
lod=1,
max_length=18,
max_length_unit='km'
WHERE name='Tile_0_0';
SELECT *
FROM qgis_pkg.citydb_tin_relief_lod2_tin
WHERE name='Tile_0_0';


--SELECT qgis_pkg.refresh_materialized_view(mview_name:='_geom_citydb_tin_relief_lod1_tin');

UPDATE qgis_pkg.citydb_solitary_vegetat_object_lod2_implicitsurf SET
description='sjhjhjhdsdsdsdsdsd',
height=10,
height_unit='m',
crown_diameter=22,
crown_diameter_unit='m'
WHERE id=905365;

SELECT *
FROM qgis_pkg.citydb_solitary_vegetat_object_lod2_implicitsurf
WHERE id=905365;

*/
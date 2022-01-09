-- ****************************************************************************
-- ****************************************************************************
--
--
-- CREATE VIEWS for attributes, linked to materialised views of geometries
--
--
-- ****************************************************************************
-- ****************************************************************************

---------------------------------------------------------------
-- Create VIEW QGIS_PKG.CITYDB_BUILDING_LOD0_FOOTPRINT
---------------------------------------------------------------
DROP VIEW IF EXISTS    qgis_pkg.citydb_building_lod0_footprint CASCADE;
CREATE OR REPLACE VIEW qgis_pkg.citydb_building_lod0_footprint AS
SELECT
  t1.id::bigint,
--  t1.objectclass_id,
  t1.gmlid,
  t1.gmlid_codespace,
  t1.name,
  t1.name_codespace,
  t1.description,
--  t1.envelope,
  t1.creation_date,
  t1.termination_date,
  t1.relative_to_terrain,
  t1.relative_to_water,
  t1.last_modification_date,
  t1.updating_person,
  t1.reason_for_update,
  t1.lineage,
  t2.class,
  t2.class_codespace,
  string_to_array(t2.function, '--/\--')::varchar[] AS function,
  string_to_array(t2.function_codespace, '--/\--')::varchar[] AS function_codespace,  
  string_to_array(t2.usage, '--/\--')::varchar[] AS usage,
  string_to_array(t2.usage_codespace, '--/\--')::varchar[] AS usage_codespace, 
  t2.year_of_construction,
  t2.year_of_demolition,
  t2.roof_type,
  t2.roof_type_codespace,
  t2.measured_height,
  t2.measured_height_unit,
  t2.storeys_above_ground,
  t2.storeys_below_ground,
  t2.storey_heights_above_ground,
  t2.storey_heights_ag_unit,
  t2.storey_heights_below_ground,
  t2.storey_heights_bg_unit,
  g.geom::geometry(MultiPolygonZ)
FROM
	qgis_pkg._geom_citydb_bdg_lod0_footprint AS g 
	INNER JOIN citydb.cityobject AS t1 ON g.co_id=t1.id
  	INNER JOIN citydb.building AS t2 ON t2.id=t1.id;
COMMENT ON VIEW qgis_pkg.citydb_building_lod0_footprint IS 'View of Building, as LoD0 footprint (multipolygon in QGIS)';

---------------------------------------------------------------
-- Create VIEW QGIS_PKG.CITYDB_BUILDING_PART_LOD0_FOOTPRINT
---------------------------------------------------------------
DROP VIEW IF EXISTS    qgis_pkg.citydb_building_part_lod0_footprint CASCADE;
CREATE OR REPLACE VIEW qgis_pkg.citydb_building_part_lod0_footprint AS
SELECT
  t1.id::bigint,
  t2.building_parent_id,
  t2.building_root_id,
--  t1.objectclass_id,
  t1.gmlid,
  t1.gmlid_codespace,
  t1.name,
  t1.name_codespace,
  t1.description,
--  t1.envelope,
  t1.creation_date,
  t1.termination_date,
  t1.relative_to_terrain,
  t1.relative_to_water,
  t1.last_modification_date,
  t1.updating_person,
  t1.reason_for_update,
  t1.lineage,
  t2.class,
  t2.class_codespace,
  string_to_array(t2.function, '--/\--')::varchar[] AS function,
  string_to_array(t2.function_codespace, '--/\--')::varchar[] AS function_codespace,  
  string_to_array(t2.usage, '--/\--')::varchar[] AS usage,
  string_to_array(t2.usage_codespace, '--/\--')::varchar[] AS usage_codespace, 
  t2.year_of_construction,
  t2.year_of_demolition,
  t2.roof_type,
  t2.roof_type_codespace,
  t2.measured_height,
  t2.measured_height_unit,
  t2.storeys_above_ground,
  t2.storeys_below_ground,
  t2.storey_heights_above_ground,
  t2.storey_heights_ag_unit,
  t2.storey_heights_below_ground,
  t2.storey_heights_bg_unit,
  g.geom::geometry(MultiPolygonZ)
FROM
	qgis_pkg._geom_citydb_bdg_part_lod0_footprint AS g
	INNER JOIN citydb.cityobject AS t1 ON g.co_id=t1.id
  	INNER JOIN citydb.building AS t2 ON t2.id=t1.id;
COMMENT ON VIEW qgis_pkg.citydb_building_part_lod0_footprint IS 'View of BuildingPart, as LoD0 footprint (multipolygon in QGIS)';

---------------------------------------------------------------
-- Create VIEW QGIS_PKG.CITYDB_BUILDING_LOD0_ROOFEDGE
---------------------------------------------------------------
DROP VIEW IF EXISTS    qgis_pkg.citydb_building_lod0_roofedge CASCADE;
CREATE OR REPLACE VIEW qgis_pkg.citydb_building_lod0_roofedge AS
SELECT
  t1.id::bigint,
--  t1.objectclass_id,
  t1.gmlid,
  t1.gmlid_codespace,
  t1.name,
  t1.name_codespace,
  t1.description,
--  t1.envelope,
  t1.creation_date,
  t1.termination_date,
  t1.relative_to_terrain,
  t1.relative_to_water,
  t1.last_modification_date,
  t1.updating_person,
  t1.reason_for_update,
  t1.lineage,
  t2.class,
  t2.class_codespace,
  string_to_array(t2.function, '--/\--')::varchar[] AS function,
  string_to_array(t2.function_codespace, '--/\--')::varchar[] AS function_codespace,  
  string_to_array(t2.usage, '--/\--')::varchar[] AS usage,
  string_to_array(t2.usage_codespace, '--/\--')::varchar[] AS usage_codespace, 
  t2.year_of_construction,
  t2.year_of_demolition,
  t2.roof_type,
  t2.roof_type_codespace,
  t2.measured_height,
  t2.measured_height_unit,
  t2.storeys_above_ground,
  t2.storeys_below_ground,
  t2.storey_heights_above_ground,
  t2.storey_heights_ag_unit,
  t2.storey_heights_below_ground,
  t2.storey_heights_bg_unit,
  g.geom::geometry(MultiPolygonZ)
FROM
	qgis_pkg._geom_citydb_bdg_lod0_roofedge AS g
	INNER JOIN citydb.cityobject AS t1 ON g.co_id=t1.id
  	INNER JOIN citydb.building AS t2 ON t2.id=t1.id;
COMMENT ON VIEW qgis_pkg.citydb_building_lod0_roofedge IS 'View of Building, as LoD0 roofedge (multipolygon in QGIS)';

---------------------------------------------------------------
-- Create VIEW QGIS_PKG.CITYDB_BUILDING_PART_LOD0_ROOFEDGE
---------------------------------------------------------------
DROP VIEW IF EXISTS    qgis_pkg.citydb_building_part_lod0_roofedge CASCADE;
CREATE OR REPLACE VIEW qgis_pkg.citydb_building_part_lod0_roofedge AS
SELECT
  t1.id::bigint,
  t2.building_parent_id,
  t2.building_root_id,
--  t1.objectclass_id,
  t1.gmlid,
  t1.gmlid_codespace,
  t1.name,
  t1.name_codespace,
  t1.description,
--  t1.envelope,
  t1.creation_date,
  t1.termination_date,
  t1.relative_to_terrain,
  t1.relative_to_water,
  t1.last_modification_date,
  t1.updating_person,
  t1.reason_for_update,
  t1.lineage,
  t2.class,
  t2.class_codespace,
  string_to_array(t2.function, '--/\--')::varchar[] AS function,
  string_to_array(t2.function_codespace, '--/\--')::varchar[] AS function_codespace,  
  string_to_array(t2.usage, '--/\--')::varchar[] AS usage,
  string_to_array(t2.usage_codespace, '--/\--')::varchar[] AS usage_codespace, 
  t2.year_of_construction,
  t2.year_of_demolition,
  t2.roof_type,
  t2.roof_type_codespace,
  t2.measured_height,
  t2.measured_height_unit,
  t2.storeys_above_ground,
  t2.storeys_below_ground,
  t2.storey_heights_above_ground,
  t2.storey_heights_ag_unit,
  t2.storey_heights_below_ground,
  t2.storey_heights_bg_unit,
  g.geom::geometry(MultiPolygonZ)
FROM
	qgis_pkg._geom_citydb_bdg_part_lod0_roofedge AS g
	INNER JOIN citydb.cityobject AS t1 ON g.co_id=t1.id
  	INNER JOIN citydb.building AS t2 ON t2.id=t1.id;
COMMENT ON VIEW qgis_pkg.citydb_building_part_lod0_roofedge IS 'View of BuildingPart, as LoD0 roofedge (multipolygon in QGIS)';

---------------------------------------------------------------
-- Create VIEW QGIS_PKG.CITYDB_BUILDING_LOD1_MULTISURF
---------------------------------------------------------------
DROP VIEW IF EXISTS    qgis_pkg.citydb_building_lod1_multisurf CASCADE;
CREATE OR REPLACE VIEW qgis_pkg.citydb_building_lod1_multisurf AS
SELECT
  t1.id::bigint,
--  t1.objectclass_id,
  t1.gmlid,
  t1.gmlid_codespace,
  t1.name,
  t1.name_codespace,
  t1.description,
--  t1.envelope,
  t1.creation_date,
  t1.termination_date,
  t1.relative_to_terrain,
  t1.relative_to_water,
  t1.last_modification_date,
  t1.updating_person,
  t1.reason_for_update,
  t1.lineage,
  t2.class,
  t2.class_codespace,
  string_to_array(t2.function, '--/\--')::varchar[] AS function,
  string_to_array(t2.function_codespace, '--/\--')::varchar[] AS function_codespace,  
  string_to_array(t2.usage, '--/\--')::varchar[] AS usage,
  string_to_array(t2.usage_codespace, '--/\--')::varchar[] AS usage_codespace, 
  t2.year_of_construction,
  t2.year_of_demolition,
  t2.roof_type,
  t2.roof_type_codespace,
  t2.measured_height,
  t2.measured_height_unit,
  t2.storeys_above_ground,
  t2.storeys_below_ground,
  t2.storey_heights_above_ground,
  t2.storey_heights_ag_unit,
  t2.storey_heights_below_ground,
  t2.storey_heights_bg_unit,
  g.geom::geometry(MultiPolygonZ)
FROM
	qgis_pkg._geom_citydb_bdg_lod1_multisurf AS g
	INNER JOIN citydb.cityobject AS t1 ON g.co_id=t1.id
  	INNER JOIN citydb.building AS t2 ON t2.id=t1.id;
COMMENT ON VIEW qgis_pkg.citydb_building_lod1_multisurf IS 'View of Building, as LoD1 multisurface (multipolygon in QGIS)';

---------------------------------------------------------------
-- Create VIEW QGIS_PKG.CITYDB_BUILDING_PART_LOD1_MULTISURF
---------------------------------------------------------------
DROP VIEW IF EXISTS    qgis_pkg.citydb_building_part_lod1_multisurf CASCADE;
CREATE OR REPLACE VIEW qgis_pkg.citydb_building_part_lod1_multisurf AS
SELECT
  t1.id::bigint,
  t2.building_parent_id,
  t2.building_root_id,
--  t1.objectclass_id,
  t1.gmlid,
  t1.gmlid_codespace,
  t1.name,
  t1.name_codespace,
  t1.description,
--  t1.envelope,
  t1.creation_date,
  t1.termination_date,
  t1.relative_to_terrain,
  t1.relative_to_water,
  t1.last_modification_date,
  t1.updating_person,
  t1.reason_for_update,
  t1.lineage,
  t2.class,
  t2.class_codespace,
  string_to_array(t2.function, '--/\--')::varchar[] AS function,
  string_to_array(t2.function_codespace, '--/\--')::varchar[] AS function_codespace,  
  string_to_array(t2.usage, '--/\--')::varchar[] AS usage,
  string_to_array(t2.usage_codespace, '--/\--')::varchar[] AS usage_codespace, 
  t2.year_of_construction,
  t2.year_of_demolition,
  t2.roof_type,
  t2.roof_type_codespace,
  t2.measured_height,
  t2.measured_height_unit,
  t2.storeys_above_ground,
  t2.storeys_below_ground,
  t2.storey_heights_above_ground,
  t2.storey_heights_ag_unit,
  t2.storey_heights_below_ground,
  t2.storey_heights_bg_unit,
  g.geom::geometry(MultiPolygonZ)
FROM
	qgis_pkg._geom_citydb_bdg_part_lod1_multisurf AS g
	INNER JOIN citydb.cityobject AS t1 ON g.co_id=t1.id
  	INNER JOIN citydb.building AS t2 ON t2.id=t1.id;
COMMENT ON VIEW qgis_pkg.citydb_building_part_lod1_multisurf IS 'View of BuildingPart, as LoD1 multisurface (multipolygon in QGIS)';

---------------------------------------------------------------
-- Create VIEW QGIS_PKG.CITYDB_BUILDING_LOD2_MULTISURF
---------------------------------------------------------------
DROP VIEW IF EXISTS    qgis_pkg.citydb_building_lod2_multisurf CASCADE;
CREATE OR REPLACE VIEW qgis_pkg.citydb_building_lod2_multisurf AS
SELECT
  t1.id::bigint,
--  t1.objectclass_id,
  t1.gmlid,
  t1.gmlid_codespace,
  t1.name,
  t1.name_codespace,
  t1.description,
--  t1.envelope,
  t1.creation_date,
  t1.termination_date,
  t1.relative_to_terrain,
  t1.relative_to_water,
  t1.last_modification_date,
  t1.updating_person,
  t1.reason_for_update,
  t1.lineage,
  t2.class,
  t2.class_codespace,
  string_to_array(t2.function, '--/\--')::varchar[] AS function,
  string_to_array(t2.function_codespace, '--/\--')::varchar[] AS function_codespace,  
  string_to_array(t2.usage, '--/\--')::varchar[] AS usage,
  string_to_array(t2.usage_codespace, '--/\--')::varchar[] AS usage_codespace, 
  t2.year_of_construction,
  t2.year_of_demolition,
  t2.roof_type,
  t2.roof_type_codespace,
  t2.measured_height,
  t2.measured_height_unit,
  t2.storeys_above_ground,
  t2.storeys_below_ground,
  t2.storey_heights_above_ground,
  t2.storey_heights_ag_unit,
  t2.storey_heights_below_ground,
  t2.storey_heights_bg_unit,
  g.geom::geometry(MultiPolygonZ)
FROM
	qgis_pkg._geom_citydb_bdg_lod2_multisurf AS g
	INNER JOIN citydb.cityobject AS t1 ON g.co_id=t1.id
  	INNER JOIN citydb.building AS t2 ON t2.id=t1.id;
COMMENT ON VIEW qgis_pkg.citydb_building_lod2_multisurf IS 'View of Building, as LoD2 multisurface (multipolygon in QGIS)';

---------------------------------------------------------------
-- Create VIEW QGIS_PKG.CITYDB_BUILDING_PART_LOD2_MULTISURF
---------------------------------------------------------------
DROP VIEW IF EXISTS    qgis_pkg.citydb_building_part_lod2_multisurf CASCADE;
CREATE OR REPLACE VIEW qgis_pkg.citydb_building_part_lod2_multisurf AS
SELECT
  t1.id::bigint,
  t2.building_parent_id,
  t2.building_root_id,
--  t1.objectclass_id,
  t1.gmlid,
  t1.gmlid_codespace,
  t1.name,
  t1.name_codespace,
  t1.description,
--  t1.envelope,
  t1.creation_date,
  t1.termination_date,
  t1.relative_to_terrain,
  t1.relative_to_water,
  t1.last_modification_date,
  t1.updating_person,
  t1.reason_for_update,
  t1.lineage,
  t2.class,
  t2.class_codespace,
  string_to_array(t2.function, '--/\--')::varchar[] AS function,
  string_to_array(t2.function_codespace, '--/\--')::varchar[] AS function_codespace,  
  string_to_array(t2.usage, '--/\--')::varchar[] AS usage,
  string_to_array(t2.usage_codespace, '--/\--')::varchar[] AS usage_codespace, 
  t2.year_of_construction,
  t2.year_of_demolition,
  t2.roof_type,
  t2.roof_type_codespace,
  t2.measured_height,
  t2.measured_height_unit,
  t2.storeys_above_ground,
  t2.storeys_below_ground,
  t2.storey_heights_above_ground,
  t2.storey_heights_ag_unit,
  t2.storey_heights_below_ground,
  t2.storey_heights_bg_unit,
  g.geom::geometry(MultiPolygonZ)
FROM
	qgis_pkg._geom_citydb_bdg_part_lod2_multisurf AS g
	INNER JOIN citydb.cityobject AS t1 ON g.co_id=t1.id
  	INNER JOIN citydb.building AS t2 ON t2.id=t1.id;
COMMENT ON VIEW qgis_pkg.citydb_building_part_lod2_multisurf IS 'View of BuildingPart, as LoD2 multisurface (multipolygon in QGIS)';

---------------------------------------------------------------
-- Create VIEW QGIS_PKG.CITYDB_BUILDING_LOD1_SOLID
---------------------------------------------------------------
DROP VIEW IF EXISTS    qgis_pkg.citydb_building_lod1_solid CASCADE;
CREATE OR REPLACE VIEW qgis_pkg.citydb_building_lod1_solid AS
SELECT
  t1.id::bigint,
--  t1.objectclass_id,
  t1.gmlid,
  t1.gmlid_codespace,
  t1.name,
  t1.name_codespace,
  t1.description,
--  t1.envelope,
  t1.creation_date,
  t1.termination_date,
  t1.relative_to_terrain,
  t1.relative_to_water,
  t1.last_modification_date,
  t1.updating_person,
  t1.reason_for_update,
  t1.lineage,
  t2.class,
  t2.class_codespace,
  string_to_array(t2.function, '--/\--')::varchar[] AS function,
  string_to_array(t2.function_codespace, '--/\--')::varchar[] AS function_codespace,  
  string_to_array(t2.usage, '--/\--')::varchar[] AS usage,
  string_to_array(t2.usage_codespace, '--/\--')::varchar[] AS usage_codespace, 
  t2.year_of_construction,
  t2.year_of_demolition,
  t2.roof_type,
  t2.roof_type_codespace,
  t2.measured_height,
  t2.measured_height_unit,
  t2.storeys_above_ground,
  t2.storeys_below_ground,
  t2.storey_heights_above_ground,
  t2.storey_heights_ag_unit,
  t2.storey_heights_below_ground,
  t2.storey_heights_bg_unit,
  g.geom::geometry(MultipolygonZ)
FROM
	qgis_pkg._geom_citydb_bdg_lod1_solid AS g
	INNER JOIN citydb.cityobject AS t1 ON g.co_id=t1.id
  	INNER JOIN citydb.building AS t2 ON t2.id=t1.id;
COMMENT ON VIEW qgis_pkg.citydb_building_lod1_solid IS 'View of Building, as LoD1 solid (multipolygon in QGIS)';

---------------------------------------------------------------
-- Create VIEW QGIS_PKG.CITYDB_BUILDING_PART_LOD1_SOLID
---------------------------------------------------------------
DROP VIEW IF EXISTS    qgis_pkg.citydb_building_part_lod1_solid CASCADE;
CREATE OR REPLACE VIEW qgis_pkg.citydb_building_part_lod1_solid AS
SELECT
  t1.id::bigint,
  t2.building_parent_id,
  t2.building_root_id,
--  t1.objectclass_id,
  t1.gmlid,
  t1.gmlid_codespace,
  t1.name,
  t1.name_codespace,
  t1.description,
--  t1.envelope,
  t1.creation_date,
  t1.termination_date,
  t1.relative_to_terrain,
  t1.relative_to_water,
  t1.last_modification_date,
  t1.updating_person,
  t1.reason_for_update,
  t1.lineage,
  t2.class,
  t2.class_codespace,
  string_to_array(t2.function, '--/\--')::varchar[] AS function,
  string_to_array(t2.function_codespace, '--/\--')::varchar[] AS function_codespace,  
  string_to_array(t2.usage, '--/\--')::varchar[] AS usage,
  string_to_array(t2.usage_codespace, '--/\--')::varchar[] AS usage_codespace, 
  t2.year_of_construction,
  t2.year_of_demolition,
  t2.roof_type,
  t2.roof_type_codespace,
  t2.measured_height,
  t2.measured_height_unit,
  t2.storeys_above_ground,
  t2.storeys_below_ground,
  t2.storey_heights_above_ground,
  t2.storey_heights_ag_unit,
  t2.storey_heights_below_ground,
  t2.storey_heights_bg_unit,
  g.geom::geometry(MultiPolygonZ)
FROM
	qgis_pkg._geom_citydb_bdg_part_lod1_solid AS g
	INNER JOIN citydb.cityobject AS t1 ON g.co_id=t1.id
  	INNER JOIN citydb.building AS t2 ON t2.id=t1.id;
COMMENT ON VIEW qgis_pkg.citydb_building_part_lod1_solid IS 'View of BuildingPart, as LoD1 solid (multipolygon in QGIS)';

---------------------------------------------------------------
-- Create VIEW QGIS_PKG.CITYDB_BUILDING_LOD2_SOLID
---------------------------------------------------------------
DROP VIEW IF EXISTS    qgis_pkg.citydb_building_lod2_solid CASCADE;
CREATE OR REPLACE VIEW qgis_pkg.citydb_building_lod2_solid AS
SELECT
  t1.id::bigint,
--  t1.objectclass_id,
  t1.gmlid,
  t1.gmlid_codespace,
  t1.name,
  t1.name_codespace,
  t1.description,
--  t1.envelope,
  t1.creation_date,
  t1.termination_date,
  t1.relative_to_terrain,
  t1.relative_to_water,
  t1.last_modification_date,
  t1.updating_person,
  t1.reason_for_update,
  t1.lineage,
  t2.class,
  t2.class_codespace,
  string_to_array(t2.function, '--/\--')::varchar[] AS function,
  string_to_array(t2.function_codespace, '--/\--')::varchar[] AS function_codespace,  
  string_to_array(t2.usage, '--/\--')::varchar[] AS usage,
  string_to_array(t2.usage_codespace, '--/\--')::varchar[] AS usage_codespace, 
  t2.year_of_construction,
  t2.year_of_demolition,
  t2.roof_type,
  t2.roof_type_codespace,
  t2.measured_height,
  t2.measured_height_unit,
  t2.storeys_above_ground,
  t2.storeys_below_ground,
  t2.storey_heights_above_ground,
  t2.storey_heights_ag_unit,
  t2.storey_heights_below_ground,
  t2.storey_heights_bg_unit,
  g.geom::geometry(MultipolygonZ)
FROM
	qgis_pkg._geom_citydb_bdg_lod2_solid AS g 
	INNER JOIN citydb.cityobject AS t1 ON g.co_id=t1.id
  	INNER JOIN citydb.building AS t2 ON t2.id=t1.id;
COMMENT ON VIEW qgis_pkg.citydb_building_lod2_solid IS 'View of Building, as LoD2 solid (multipolygon in QGIS)';

---------------------------------------------------------------
-- Create VIEW QGIS_PKG.CITYDB_BUILDING_PART_LOD2_SOLID
---------------------------------------------------------------
DROP VIEW IF EXISTS    qgis_pkg.citydb_building_part_lod2_solid CASCADE;
CREATE OR REPLACE VIEW qgis_pkg.citydb_building_part_lod2_solid AS
SELECT
  t1.id::bigint,
  t2.building_parent_id,
  t2.building_root_id,
--  t1.objectclass_id,
  t1.gmlid,
  t1.gmlid_codespace,
  t1.name,
  t1.name_codespace,
  t1.description,
--  t1.envelope,
  t1.creation_date,
  t1.termination_date,
  t1.relative_to_terrain,
  t1.relative_to_water,
  t1.last_modification_date,
  t1.updating_person,
  t1.reason_for_update,
  t1.lineage,
  t2.class,
  t2.class_codespace,
  string_to_array(t2.function, '--/\--')::varchar[] AS function,
  string_to_array(t2.function_codespace, '--/\--')::varchar[] AS function_codespace,  
  string_to_array(t2.usage, '--/\--')::varchar[] AS usage,
  string_to_array(t2.usage_codespace, '--/\--')::varchar[] AS usage_codespace, 
  t2.year_of_construction,
  t2.year_of_demolition,
  t2.roof_type,
  t2.roof_type_codespace,
  t2.measured_height,
  t2.measured_height_unit,
  t2.storeys_above_ground,
  t2.storeys_below_ground,
  t2.storey_heights_above_ground,
  t2.storey_heights_ag_unit,
  t2.storey_heights_below_ground,
  t2.storey_heights_bg_unit,
  g.geom::geometry(MultiPolygonZ)
FROM
	qgis_pkg._geom_citydb_bdg_part_lod2_solid AS g 
	INNER JOIN citydb.cityobject AS t1 ON g.co_id=t1.id
  	INNER JOIN citydb.building AS t2 ON t2.id=t1.id;
COMMENT ON VIEW qgis_pkg.citydb_building_part_lod2_solid IS 'View of BuildingPart, as LoD2 solid (multipolygon in QGIS)';


--*************************************************************
--*************************************************************
---------------------------------------------------------------
-- Create VIEW QGIS_PKG.CITYDB_BDG_GROUNDSURFACE_LOD2_MULTISURF
---------------------------------------------------------------
DROP VIEW IF EXISTS    qgis_pkg.citydb_bdg_groundsurface_lod2_multisurf CASCADE;
CREATE OR REPLACE VIEW qgis_pkg.citydb_bdg_groundsurface_lod2_multisurf AS
SELECT
  t1.id::bigint,
--  t1.objectclass_id,
  t1.gmlid,
  t1.gmlid_codespace,
  t1.name,
  t1.name_codespace,
  t1.description,
--  t1.envelope,
  t1.creation_date,
  t1.termination_date,
  t1.relative_to_terrain,
  t1.relative_to_water,
  t1.last_modification_date,
  t1.updating_person,
  t1.reason_for_update,
  t1.lineage,
  t2.building_id,
  t2.building_installation_id,  
  g.geom::geometry(MultiPolygonZ)
FROM
	qgis_pkg._geom_citydb_bdg_groundsurface_lod2_multisurf AS g
	INNER JOIN citydb.cityobject AS t1 ON g.co_id=t1.id
  	INNER JOIN citydb.thematic_surface AS t2 ON t2.id=t1.id;
COMMENT ON VIEW qgis_pkg.citydb_bdg_groundsurface_lod2_multisurf IS 'View of (Building) GroundSurface, as LoD2 multisurface (multipolygon in QGIS)';

---------------------------------------------------------------
-- Create VIEW QGIS_PKG.CITYDB_BDG_WALLSURFACE_LOD2_MULTISURF
---------------------------------------------------------------
DROP VIEW IF EXISTS    qgis_pkg.citydb_bdg_wallsurface_lod2_multisurf CASCADE;
CREATE OR REPLACE VIEW qgis_pkg.citydb_bdg_wallsurface_lod2_multisurf AS
SELECT
  t1.id::bigint,
--  t1.objectclass_id,
  t1.gmlid,
  t1.gmlid_codespace,
  t1.name,
  t1.name_codespace,
  t1.description,
--  t1.envelope,
  t1.creation_date,
  t1.termination_date,
  t1.relative_to_terrain,
  t1.relative_to_water,
  t1.last_modification_date,
  t1.updating_person,
  t1.reason_for_update,
  t1.lineage,
  t2.building_id,
  t2.building_installation_id,  
  g.geom::geometry(MultiPolygonZ)
FROM
	qgis_pkg._geom_citydb_bdg_wallsurface_lod2_multisurf AS g
	INNER JOIN citydb.cityobject AS t1 ON g.co_id=t1.id
  	INNER JOIN citydb.thematic_surface AS t2 ON t2.id=t1.id;
COMMENT ON VIEW qgis_pkg.citydb_bdg_wallsurface_lod2_multisurf IS 'View of (Building) WallSurface, as LoD2 multisurface (multipolygon in QGIS)';

---------------------------------------------------------------
-- Create VIEW QGIS_PKG.CITYDB_BDG_ROOFSURFACE_LOD2_MULTISURF
---------------------------------------------------------------
DROP VIEW IF EXISTS    qgis_pkg.citydb_bdg_roofsurface_lod2_multisurf CASCADE;
CREATE OR REPLACE VIEW qgis_pkg.citydb_bdg_roofsurface_lod2_multisurf AS
SELECT
  t1.id::bigint,
--  t1.objectclass_id,
  t1.gmlid,
  t1.gmlid_codespace,
  t1.name,
  t1.name_codespace,
  t1.description,
--  t1.envelope,
  t1.creation_date,
  t1.termination_date,
  t1.relative_to_terrain,
  t1.relative_to_water,
  t1.last_modification_date,
  t1.updating_person,
  t1.reason_for_update,
  t1.lineage,
  t2.building_id,
  t2.building_installation_id,  
  g.geom::geometry(MultiPolygonZ)
FROM
	qgis_pkg._geom_citydb_bdg_roofsurface_lod2_multisurf AS g
	INNER JOIN citydb.cityobject AS t1 ON g.co_id=t1.id
  	INNER JOIN citydb.thematic_surface AS t2 ON t2.id=t1.id;
COMMENT ON VIEW qgis_pkg.citydb_bdg_roofsurface_lod2_multisurf IS 'View of (Building) RoofSurface, as LoD2 multisurface (multipolygon in QGIS)';

---------------------------------------------------------------
-- Create VIEW QGIS_PKG.CITYDB_BDG_CLOSURESURFACE_LOD2_MULTISURF
---------------------------------------------------------------
DROP VIEW IF EXISTS    qgis_pkg.citydb_bdg_closuresurface_lod2_multisurf CASCADE;
CREATE OR REPLACE VIEW qgis_pkg.citydb_bdg_closuresurface_lod2_multisurf AS
SELECT
  t1.id::bigint,
--  t1.objectclass_id,
  t1.gmlid,
  t1.gmlid_codespace,
  t1.name,
  t1.name_codespace,
  t1.description,
--  t1.envelope,
  t1.creation_date,
  t1.termination_date,
  t1.relative_to_terrain,
  t1.relative_to_water,
  t1.last_modification_date,
  t1.updating_person,
  t1.reason_for_update,
  t1.lineage,
  t2.building_id,
  t2.building_installation_id,  
  g.geom::geometry(MultiPolygonZ)
FROM
	qgis_pkg._geom_citydb_bdg_closuresurface_lod2_multisurf AS g
	INNER JOIN citydb.cityobject AS t1 ON g.co_id=t1.id
  	INNER JOIN citydb.thematic_surface AS t2 ON t2.id=t1.id;
COMMENT ON VIEW qgis_pkg.citydb_bdg_closuresurface_lod2_multisurf IS 'View of (Building) ClosureSurface, as LoD2 multisurface (multipolygon in QGIS)';

---------------------------------------------------------------
-- Create VIEW QGIS_PKG.CITYDB_BDG_OUTERCEILINGSURFACE_LOD2_MULTISURF
---------------------------------------------------------------
DROP VIEW IF EXISTS    qgis_pkg.citydb_bdg_outerceilingsurface_lod2_multisurf CASCADE;
CREATE OR REPLACE VIEW qgis_pkg.citydb_bdg_outerceilingsurface_lod2_multisurf AS
SELECT
  t1.id::bigint,
--  t1.objectclass_id,
  t1.gmlid,
  t1.gmlid_codespace,
  t1.name,
  t1.name_codespace,
  t1.description,
--  t1.envelope,
  t1.creation_date,
  t1.termination_date,
  t1.relative_to_terrain,
  t1.relative_to_water,
  t1.last_modification_date,
  t1.updating_person,
  t1.reason_for_update,
  t1.lineage,
  t2.building_id,
  t2.building_installation_id,  
  g.geom::geometry(MultiPolygonZ)
FROM
	qgis_pkg._geom_citydb_bdg_outerceilingsurface_lod2_multisurf AS g
	INNER JOIN citydb.cityobject AS t1 ON g.co_id=t1.id
  	INNER JOIN citydb.thematic_surface AS t2 ON t2.id=t1.id;
COMMENT ON VIEW qgis_pkg.citydb_bdg_outerceilingsurface_lod2_multisurf IS 'View of (Building) OuterCeilingSurface, as LoD2 multisurface (multipolygon in QGIS)';

---------------------------------------------------------------
-- Create VIEW QGIS_PKG.CITYDB_BDG_OUTERFLOORSURFACE_LOD2_MULTISURF
---------------------------------------------------------------
DROP VIEW IF EXISTS    qgis_pkg.citydb_bdg_outerfloorsurface_lod2_multisurf CASCADE;
CREATE OR REPLACE VIEW qgis_pkg.citydb_bdg_outerfloorsurface_lod2_multisurf AS
SELECT
  t1.id::bigint,
--  t1.objectclass_id,
  t1.gmlid,
  t1.gmlid_codespace,
  t1.name,
  t1.name_codespace,
  t1.description,
--  t1.envelope,
  t1.creation_date,
  t1.termination_date,
  t1.relative_to_terrain,
  t1.relative_to_water,
  t1.last_modification_date,
  t1.updating_person,
  t1.reason_for_update,
  t1.lineage,
  t2.building_id,
  t2.building_installation_id,  
  g.geom::geometry(MultiPolygonZ)
FROM
	qgis_pkg._geom_citydb_bdg_outerfloorsurface_lod2_multisurf AS g
	INNER JOIN citydb.cityobject AS t1 ON g.co_id=t1.id
  	INNER JOIN citydb.thematic_surface AS t2 ON t2.id=t1.id;
COMMENT ON VIEW qgis_pkg.citydb_bdg_outerfloorsurface_lod2_multisurf IS 'View of (Building) OuterFloorSurface, as LoD2 multisurface (multipolygon in QGIS)';

--*************************************************************
--*************************************************************
---------------------------------------------------------------
-- Create VIEW QGIS_PKG.CITYDB_BDG_OUTERINSTALLATION_LOD2_MULTISURF
---------------------------------------------------------------
DROP VIEW IF EXISTS    qgis_pkg.citydb_bdg_outerinstallation_lod2_multisurf CASCADE;
CREATE OR REPLACE VIEW qgis_pkg.citydb_bdg_outerinstallation_lod2_multisurf AS
SELECT
  t1.id::bigint,
--  t1.objectclass_id,
  t1.gmlid,
  t1.gmlid_codespace,
  t1.name,
  t1.name_codespace,
  t1.description,
--  t1.envelope,
  t1.creation_date,
  t1.termination_date,
  t1.relative_to_terrain,
  t1.relative_to_water,
  t1.last_modification_date,
  t1.updating_person,
  t1.reason_for_update,
  t1.lineage,
  t2.class,
  t2.class_codespace,
  string_to_array(t2.function, '--/\--')::varchar[] AS function,
  string_to_array(t2.function_codespace, '--/\--')::varchar[] AS function_codespace,  
  string_to_array(t2.usage, '--/\--')::varchar[] AS usage,
  string_to_array(t2.usage_codespace, '--/\--')::varchar[] AS usage_codespace, 
  t2.building_id,
  g.geom::geometry(MultiPolygonZ)
FROM
	qgis_pkg._geom_citydb_bdg_outerinstallation_lod2_multisurf AS g 
	INNER JOIN citydb.cityobject AS t1 ON g.co_id=t1.id
  	INNER JOIN citydb.building_installation AS t2 ON t2.id=t1.id;
COMMENT ON VIEW qgis_pkg.citydb_bdg_outerinstallation_lod2_multisurf IS 'View of (Building) OuterInstallation, as LoD2 geometry (multipolygon in QGIS)';

--**************************
DO $$
BEGIN
RAISE NOTICE 'Done';
END $$;
--**************************

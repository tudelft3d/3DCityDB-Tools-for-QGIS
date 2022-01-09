-- ****************************************************************************
-- ****************************************************************************
--
--
-- CREATE MATERIALIZED VIEWS for geometries
--
--
-- ****************************************************************************
-- ****************************************************************************

---------------------------------------------------------------
-- Create MATERIALIZED VIEW QGIS_PKG._GEOM_CITYDB_BDG_LOD0_FOOTPRINT
---------------------------------------------------------------
DROP MATERIALIZED VIEW IF EXISTS qgis_pkg._geom_citydb_bdg_lod0_footprint CASCADE;
CREATE MATERIALIZED VIEW         qgis_pkg._geom_citydb_bdg_lod0_footprint AS
	SELECT
		sg.cityobject_id::bigint AS co_id,
		ST_Collect(sg.geometry)::geometry(MultiPolygonZ) AS geom		
	FROM 
		citydb.building AS b
		INNER JOIN citydb.surface_geometry AS sg ON (sg.root_id = b.lod0_footprint_id AND b.objectclass_id = 26)
	WHERE 
		sg.geometry IS NOT NULL
	GROUP BY sg.cityobject_id
WITH NO DATA;
COMMENT ON MATERIALIZED VIEW qgis_pkg._geom_citydb_bdg_lod0_footprint IS 'Materialised view of Building LoD0 footprint geometries (multipolygon in QGIS)';
CREATE INDEX _g_citydb_bdg_lod0_footprint_id_idx   ON qgis_pkg._geom_citydb_bdg_lod0_footprint (co_id);
CREATE INDEX _g_citydb_bdg_lod0_footprint_geom_spx ON qgis_pkg._geom_citydb_bdg_lod0_footprint USING gist (geom);



---------------------------------------------------------------
-- Create MATERIALIZED VIEW QGIS_PKG._GEOM_CITYDB_BDG_PART_LOD0_FOOTPRINT
---------------------------------------------------------------
DROP MATERIALIZED VIEW IF EXISTS qgis_pkg._geom_citydb_bdg_part_lod0_footprint CASCADE;
CREATE MATERIALIZED VIEW         qgis_pkg._geom_citydb_bdg_part_lod0_footprint AS
	SELECT
		sg.cityobject_id::bigint AS co_id,
		ST_Collect(sg.geometry)::geometry(MultiPolygonZ) AS geom 		
	FROM 
		citydb.building AS b
		INNER JOIN citydb.surface_geometry AS sg ON (sg.root_id = b.lod0_footprint_id AND b.objectclass_id = 25)
	WHERE 
		sg.geometry IS NOT NULL
	GROUP BY sg.cityobject_id
WITH NO DATA;
COMMENT ON MATERIALIZED VIEW qgis_pkg._geom_citydb_bdg_part_lod0_footprint IS 'Materialised view of BuildingPart LoD0 footprint geometries (multipolygon in QGIS)';
CREATE INDEX _g_citydb_bdg_part_lod0_footprint_id_idx   ON qgis_pkg._geom_citydb_bdg_lod0_footprint (co_id);
CREATE INDEX _g_citydb_bdg_part_lod0_footprint_geom_spx ON qgis_pkg._geom_citydb_bdg_lod0_footprint USING gist (geom);

---------------------------------------------------------------
-- Create MATERIALIZED VIEW QGIS_PKG._GEOM_CITYDB_BDG_LOD0_ROOFEDGE
---------------------------------------------------------------
DROP MATERIALIZED VIEW IF EXISTS qgis_pkg._geom_citydb_bdg_lod0_roofedge CASCADE;
CREATE MATERIALIZED VIEW         qgis_pkg._geom_citydb_bdg_lod0_roofedge AS
	SELECT
		sg.cityobject_id::bigint AS co_id,
		ST_Collect(sg.geometry)::geometry(MultiPolygonZ) AS geom		
	FROM 
		citydb.building AS b
		INNER JOIN citydb.surface_geometry AS sg ON (sg.root_id = b.lod0_roofprint_id AND b.objectclass_id = 26)
	WHERE 
		sg.geometry IS NOT NULL
	GROUP BY sg.cityobject_id
WITH NO DATA;
COMMENT ON MATERIALIZED VIEW qgis_pkg._geom_citydb_bdg_lod0_roofedge IS 'Materialised view of Building LoD0 roofedge geometries (multipolygon in QGIS)';
CREATE INDEX _g_citydb_bdg_lod0_roofedge_id_idx   ON qgis_pkg._geom_citydb_bdg_lod0_roofedge (co_id);
CREATE INDEX _g_citydb_bdg_lod0_roofedge_geom_spx ON qgis_pkg._geom_citydb_bdg_lod0_roofedge USING gist (geom);

---------------------------------------------------------------
-- Create MATERIALIZED VIEW QGIS_PKG._GEOM_CITYDB_BDG_PART_LOD0_ROOFEDGE
---------------------------------------------------------------
DROP MATERIALIZED VIEW IF EXISTS qgis_pkg._geom_citydb_bdg_part_lod0_roofedge CASCADE;
CREATE MATERIALIZED VIEW         qgis_pkg._geom_citydb_bdg_part_lod0_roofedge AS
	SELECT
		sg.cityobject_id::bigint AS co_id,
		ST_Collect(sg.geometry)::geometry(MultiPolygonZ) AS geom 		
	FROM 
		citydb.building AS b
		INNER JOIN citydb.surface_geometry AS sg ON (sg.root_id = b.lod0_roofprint_id AND b.objectclass_id = 25)
	WHERE 
		sg.geometry IS NOT NULL
	GROUP BY sg.cityobject_id
WITH NO DATA;
COMMENT ON MATERIALIZED VIEW qgis_pkg._geom_citydb_bdg_part_lod0_roofedge IS 'Materialised view of BuildingPart LoD0 roofedge geometries (multipolygon in QGIS)';
CREATE INDEX _g_citydb_bdg_part_lod0_roofedge_id_idx   ON qgis_pkg._geom_citydb_bdg_lod0_roofedge (co_id);
CREATE INDEX _g_citydb_bdg_part_lod0_roofedge_geom_spx ON qgis_pkg._geom_citydb_bdg_lod0_roofedge USING gist (geom);


--*************************************************************
--*************************************************************
---------------------------------------------------------------
-- Create MATERIALIZED VIEW QGIS_PKG._GEOM_CITYDB_BDG_LOD1_MULTISURF
---------------------------------------------------------------
DROP MATERIALIZED VIEW IF EXISTS qgis_pkg._geom_citydb_bdg_lod1_multisurf CASCADE;
CREATE MATERIALIZED VIEW         qgis_pkg._geom_citydb_bdg_lod1_multisurf AS
	SELECT
		sg.cityobject_id::bigint AS co_id,
		ST_Collect(sg.geometry)::geometry(MultiPolygonZ) AS geom 		
	FROM 
		citydb.building AS b
		INNER JOIN citydb.surface_geometry AS sg ON (sg.root_id = b.lod1_multi_surface_id AND b.objectclass_id = 26)
	WHERE 
		sg.geometry IS NOT NULL
	GROUP BY sg.cityobject_id
WITH NO DATA;
COMMENT ON MATERIALIZED VIEW qgis_pkg._geom_citydb_bdg_lod1_multisurf IS 'Materialised view of Building, as LoD1 multisurface (multipolygon in QGIS)';
CREATE INDEX _g_citydb_bdg_lod1_multisurf_id_idx   ON qgis_pkg._geom_citydb_bdg_lod1_multisurf (co_id);
CREATE INDEX _g_citydb_bdg_lod1_multisurf_geom_spx ON qgis_pkg._geom_citydb_bdg_lod1_multisurf USING gist (geom);

---------------------------------------------------------------
-- Create MATERIALIZED VIEW QGIS_PKG._GEOM_CITYDB_BDG_PART_LOD1_MULTISURF
---------------------------------------------------------------
DROP MATERIALIZED VIEW IF EXISTS qgis_pkg._geom_citydb_bdg_part_lod1_multisurf CASCADE;
CREATE MATERIALIZED VIEW         qgis_pkg._geom_citydb_bdg_part_lod1_multisurf AS
	SELECT
		sg.cityobject_id::bigint AS co_id,
		ST_Collect(sg.geometry)::geometry(MultiPolygonZ) AS geom		
	FROM 
		citydb.building AS b
		INNER JOIN citydb.surface_geometry AS sg ON (sg.root_id = b.lod1_multi_surface_id AND b.objectclass_id = 25)
	WHERE 
		sg.geometry IS NOT NULL
	GROUP BY sg.cityobject_id
WITH NO DATA;
COMMENT ON MATERIALIZED VIEW qgis_pkg._geom_citydb_bdg_part_lod1_multisurf IS 'Materialised view of BuildingPart, as LoD1 multisurface (multipolygon in QGIS)';
CREATE INDEX _g_citydb_bdg_part_lod1_multisurf_id_idx   ON qgis_pkg._geom_citydb_bdg_part_lod1_multisurf (co_id);
CREATE INDEX _g_citydb_bdg_part_lod1_multisurf_geom_spx ON qgis_pkg._geom_citydb_bdg_part_lod1_multisurf USING gist (geom);

---------------------------------------------------------------
-- Create MATERIALIZED VIEW QGIS_PKG._GEOM_CITYDB_BDG_LOD2_MULTISURF
---------------------------------------------------------------
DROP MATERIALIZED VIEW IF EXISTS qgis_pkg._geom_citydb_bdg_lod2_multisurf CASCADE;
CREATE MATERIALIZED VIEW         qgis_pkg._geom_citydb_bdg_lod2_multisurf AS
	SELECT
		sg.cityobject_id::bigint AS co_id,
		ST_Collect(sg.geometry)::geometry(MultiPolygonZ) AS geom 		
	FROM 
		citydb.building AS b
		INNER JOIN citydb.surface_geometry AS sg ON (sg.root_id = b.lod2_multi_surface_id AND b.objectclass_id = 26)
	WHERE 
		sg.geometry IS NOT NULL
	GROUP BY sg.cityobject_id
WITH NO DATA;
COMMENT ON MATERIALIZED VIEW qgis_pkg._geom_citydb_bdg_lod2_multisurf IS 'Materialised view of Building, as LoD2 multisurface (multipolygon in QGIS)';
CREATE INDEX _g_citydb_bdg_lod2_multisurf_id_idx   ON qgis_pkg._geom_citydb_bdg_lod2_multisurf (co_id);
CREATE INDEX _g_citydb_bdg_lod2_multisurf_geom_spx ON qgis_pkg._geom_citydb_bdg_lod2_multisurf USING gist (geom);

---------------------------------------------------------------
-- Create MATERIALIZED VIEW QGIS_PKG._GEOM_CITYDB_BDG_PART_LOD2_MULTISURF
---------------------------------------------------------------
DROP MATERIALIZED VIEW IF EXISTS qgis_pkg._geom_citydb_bdg_part_lod2_multisurf CASCADE;
CREATE MATERIALIZED VIEW         qgis_pkg._geom_citydb_bdg_part_lod2_multisurf AS
	SELECT
		sg.cityobject_id::bigint AS co_id,
		ST_Collect(sg.geometry)::geometry(MultiPolygonZ) AS geom		
	FROM 
		citydb.building AS b
		INNER JOIN citydb.surface_geometry AS sg ON (sg.root_id = b.lod2_multi_surface_id AND b.objectclass_id = 25)
	WHERE 
		sg.geometry IS NOT NULL
	GROUP BY sg.cityobject_id
WITH NO DATA;
COMMENT ON MATERIALIZED VIEW qgis_pkg._geom_citydb_bdg_part_lod2_multisurf IS 'Materialised view of BuildingPart, as LoD2 multisurface (multipolygon in QGIS)';
CREATE INDEX _g_citydb_bdg_part_lod2_multisurf_id_idx   ON qgis_pkg._geom_citydb_bdg_part_lod2_multisurf (co_id);
CREATE INDEX _g_citydb_bdg_part_lod2_multisurf_geom_spx ON qgis_pkg._geom_citydb_bdg_part_lod2_multisurf USING gist (geom);


--*************************************************************
--*************************************************************
---------------------------------------------------------------
-- Create MATERIALIZED VIEW QGIS_PKG.CITYDB_BUILDING_LOD1_SOLID
---------------------------------------------------------------
DROP MATERIALIZED VIEW IF EXISTS qgis_pkg._geom_citydb_bdg_lod1_solid CASCADE;
CREATE MATERIALIZED VIEW         qgis_pkg._geom_citydb_bdg_lod1_solid AS
	SELECT
		sg.cityobject_id::bigint AS co_id,
		ST_Collect(sg.geometry)::geometry(MultiPolygonZ) AS geom
	FROM 
		citydb.building AS b
		INNER JOIN citydb.surface_geometry AS sg ON (sg.root_id = b.lod1_solid_id AND b.objectclass_id = 26)
	WHERE 
		sg.geometry IS NOT NULL
	GROUP BY sg.cityobject_id
WITH NO DATA;
COMMENT ON MATERIALIZED VIEW qgis_pkg._geom_citydb_bdg_lod1_solid IS 'Materialised view of Building, as LoD1 solid (multipolygon in QGIS)';
CREATE INDEX _g_citydb_bdg_lod1_solid_id_idx   ON qgis_pkg._geom_citydb_bdg_lod1_solid (co_id);
CREATE INDEX _g_citydb_bdg_lod1_solid_geom_spx ON qgis_pkg._geom_citydb_bdg_lod1_solid USING gist (geom);

---------------------------------------------------------------
-- Create MATERIALIZED VIEW QGIS_PKG._GEOM_CITYDB_BDG_PART_LOD1_SOLID
---------------------------------------------------------------
DROP MATERIALIZED VIEW IF EXISTS qgis_pkg._geom_citydb_bdg_part_lod1_solid CASCADE;
CREATE MATERIALIZED VIEW         qgis_pkg._geom_citydb_bdg_part_lod1_solid AS
	SELECT
		sg.cityobject_id::bigint AS co_id,
		ST_Collect(sg.geometry)::geometry(MultiPolygonZ) AS geom
	FROM 
		citydb.building AS b
		INNER JOIN citydb.surface_geometry AS sg ON (sg.root_id = b.lod1_solid_id AND b.objectclass_id = 25)
	WHERE 
		sg.geometry IS NOT NULL
	GROUP BY sg.cityobject_id
WITH NO DATA;
COMMENT ON MATERIALIZED VIEW qgis_pkg._geom_citydb_bdg_part_lod1_solid IS 'Materialised view of BuildingPart, as LoD1 solid (multipolygon in QGIS)';
CREATE INDEX _g_citydb_bdg_part_lod1_solid_id_idx   ON qgis_pkg._geom_citydb_bdg_part_lod1_solid (co_id);
CREATE INDEX _g_citydb_bdg_part_lod1_solid_geom_spx ON qgis_pkg._geom_citydb_bdg_part_lod1_solid USING gist (geom);

---------------------------------------------------------------
-- Create MATERIALIZED VIEW QGIS_PKG.CITYDB_BUILDING_LOD2_SOLID
---------------------------------------------------------------
DROP MATERIALIZED VIEW IF EXISTS qgis_pkg._geom_citydb_bdg_lod2_solid CASCADE;
CREATE MATERIALIZED VIEW         qgis_pkg._geom_citydb_bdg_lod2_solid AS
	SELECT
		sg.cityobject_id::bigint AS co_id,
		ST_Collect(sg.geometry)::geometry(MultiPolygonZ) AS geom
	FROM 
		citydb.building AS b
		INNER JOIN citydb.surface_geometry AS sg ON (sg.root_id = b.lod2_solid_id AND b.objectclass_id = 26)
	WHERE 
		sg.geometry IS NOT NULL
	GROUP BY sg.cityobject_id
WITH NO DATA;
COMMENT ON MATERIALIZED VIEW qgis_pkg._geom_citydb_bdg_lod2_solid IS 'Materialised view of Building, as LoD2 solid (multipolygon in QGIS)';
CREATE INDEX _g_citydb_bdg_lod2_solid_id_idx   ON qgis_pkg._geom_citydb_bdg_lod2_solid (co_id);
CREATE INDEX _g_citydb_bdg_lod2_solid_geom_spx ON qgis_pkg._geom_citydb_bdg_lod2_solid USING gist (geom);

---------------------------------------------------------------
-- Create MATERIALIZED VIEW QGIS_PKG._GEOM_CITYDB_BDG_PART_LOD2_SOLID
---------------------------------------------------------------
DROP MATERIALIZED VIEW IF EXISTS qgis_pkg._geom_citydb_bdg_part_lod2_solid CASCADE;
CREATE MATERIALIZED VIEW         qgis_pkg._geom_citydb_bdg_part_lod2_solid AS
	SELECT
		sg.cityobject_id::bigint AS co_id,
		ST_Collect(sg.geometry)::geometry(MultiPolygonZ) AS geom
	FROM 
		citydb.building AS b
		INNER JOIN citydb.surface_geometry AS sg ON (sg.root_id = b.lod2_solid_id AND b.objectclass_id = 25)
	WHERE 
		sg.geometry IS NOT NULL
	GROUP BY sg.cityobject_id
WITH NO DATA;
COMMENT ON MATERIALIZED VIEW qgis_pkg._geom_citydb_bdg_part_lod2_solid IS 'Materialised view of BuildingPart, as LoD2 solid (multipolygon in QGIS)';
CREATE INDEX _g_citydb_bdg_part_lod2_solid_id_idx   ON qgis_pkg._geom_citydb_bdg_part_lod2_solid (co_id);
CREATE INDEX _g_citydb_bdg_part_lod2_solid_geom_spx ON qgis_pkg._geom_citydb_bdg_part_lod2_solid USING gist (geom);

/*
--*************************************************************
--*************************************************************
---------------------------------------------------------------
-- Create MATERIALIZED VIEW QGIS_PKG.CITYDB_BUILDING_LOD1_POLYHEDRALSURF
---------------------------------------------------------------
DROP MATERIALIZED VIEW IF EXISTS qgis_pkg._geom_citydb_bdg_lod1_polyhedralsurf CASCADE;
CREATE MATERIALIZED VIEW         qgis_pkg._geom_citydb_bdg_lod1_polyhedralsurf AS
	SELECT
		sg.cityobject_id::bigint AS co_id,
		sg.solid_geometry AS geom  		
	FROM 
		citydb.building AS b
		INNER JOIN citydb.surface_geometry AS sg ON (sg.root_id = b.lod1_solid_id AND b.objectclass_id = 26)
	WHERE 
		sg.solid_geometry IS NOT NULL;
COMMENT ON MATERIALIZED VIEW qgis_pkg._geom_citydb_bdg_lod1_polyhedralsurf IS 'View of Building, as LoD1 solid (polyhedralsurface in QGIS)';

---------------------------------------------------------------
-- Create MATERIALIZED VIEW QGIS_PKG._GEOM_CITYDB_BDG_PART_LOD1_POLYHEDRALSURF
---------------------------------------------------------------
DROP MATERIALIZED VIEW IF EXISTS qgis_pkg._geom_citydb_bdg_part_lod1_polyhedralsurf CASCADE;
CREATE MATERIALIZED VIEW         qgis_pkg._geom_citydb_bdg_part_lod1_polyhedralsurf AS
	SELECT
		sg.cityobject_id::bigint AS co_id,
		sg.solid_geometry AS geom  		
	FROM 
		citydb.building AS b
		INNER JOIN citydb.surface_geometry AS sg ON (sg.root_id = b.lod1_solid_id AND b.objectclass_id = 25)
	WHERE 
		sg.solid_geometry IS NOT NULL;
COMMENT ON MATERIALIZED VIEW qgis_pkg._geom_citydb_bdg_part_lod1_polyhedralsurf IS 'View of BuildingPart, as LoD1 solid (polyhedralsurface in QGIS)';

---------------------------------------------------------------
-- Create MATERIALIZED VIEW QGIS_PKG.CITYDB_BUILDING_LOD2_POLYHEDRALSURF
---------------------------------------------------------------

---------------------------------------------------------------
-- Create MATERIALIZED VIEW QGIS_PKG._GEOM_CITYDB_BDG_PART_LOD1_POLYHEDRALSURF
---------------------------------------------------------------

*/


--*************************************************************
--*************************************************************
---------------------------------------------------------------
-- Create MATERIALIZED VIEW QGIS_PKG.CITYDB_BDG_GROUNDSURFACE_LOD2_MULTISURF
---------------------------------------------------------------
DROP MATERIALIZED VIEW IF EXISTS qgis_pkg._geom_citydb_bdg_groundsurface_lod2_multisurf CASCADE;
CREATE MATERIALIZED VIEW         qgis_pkg._geom_citydb_bdg_groundsurface_lod2_multisurf AS
	SELECT
		sg.cityobject_id::bigint AS co_id,
		ST_Collect(sg.geometry)::geometry(MultiPolygonZ) AS geom 		
	FROM 
		citydb.thematic_surface AS o
		INNER JOIN citydb.surface_geometry AS sg ON (sg.root_id = o.lod2_multi_surface_id AND o.objectclass_id = 35)
	WHERE 
		sg.geometry IS NOT NULL
	GROUP BY sg.cityobject_id
WITH NO DATA;
COMMENT ON MATERIALIZED VIEW qgis_pkg._geom_citydb_bdg_groundsurface_lod2_multisurf IS 'Materialized view of (Building) GroundSurface, as LoD2 multisurface (multipolygon in QGIS)';
CREATE INDEX _g_citydb_bdg_groundsurf_lod2_multisurf_id_idx   ON qgis_pkg._geom_citydb_bdg_groundsurface_lod2_multisurf (co_id);
CREATE INDEX _g_citydb_bdg_groundsurf_lod2_multisurf_geom_spx ON qgis_pkg._geom_citydb_bdg_groundsurface_lod2_multisurf USING gist (geom);

---------------------------------------------------------------
-- Create MATERIALIZED VIEW QGIS_PKG.CITYDB_BDG_WALLSURFACE_LOD2_MULTISURF
---------------------------------------------------------------
DROP MATERIALIZED VIEW IF EXISTS qgis_pkg._geom_citydb_bdg_wallsurface_lod2_multisurf CASCADE;
CREATE MATERIALIZED VIEW         qgis_pkg._geom_citydb_bdg_wallsurface_lod2_multisurf AS
	SELECT
		sg.cityobject_id::bigint AS co_id,
		ST_Collect(sg.geometry)::geometry(MultiPolygonZ) AS geom 		
	FROM 
		citydb.thematic_surface AS o
		INNER JOIN citydb.surface_geometry AS sg ON (sg.root_id = o.lod2_multi_surface_id AND o.objectclass_id = 34)
	WHERE 
		sg.geometry IS NOT NULL
	GROUP BY sg.cityobject_id
WITH NO DATA;
COMMENT ON MATERIALIZED VIEW qgis_pkg._geom_citydb_bdg_wallsurface_lod2_multisurf IS 'Materialized view of (Building) WallSurface, as LoD2 multisurface (multipolygon in QGIS)';
CREATE INDEX _g_citydb_bdg_wallsurf_lod2_multisurf_id_idx   ON qgis_pkg._geom_citydb_bdg_wallsurface_lod2_multisurf (co_id);
CREATE INDEX _g_citydb_bdg_wallsurf_lod2_multisurf_geom_spx ON qgis_pkg._geom_citydb_bdg_wallsurface_lod2_multisurf USING gist (geom);

---------------------------------------------------------------
-- Create MATERIALIZED VIEW QGIS_PKG.CITYDB_BDG_ROOFSURFACE_LOD2_MULTISURF
---------------------------------------------------------------
DROP MATERIALIZED VIEW IF EXISTS qgis_pkg._geom_citydb_bdg_roofsurface_lod2_multisurf CASCADE;
CREATE MATERIALIZED VIEW         qgis_pkg._geom_citydb_bdg_roofsurface_lod2_multisurf AS
	SELECT
		sg.cityobject_id::bigint AS co_id,
		ST_Collect(sg.geometry)::geometry(MultiPolygonZ) AS geom 		
	FROM 
		citydb.thematic_surface AS o
		INNER JOIN citydb.surface_geometry AS sg ON (sg.root_id = o.lod2_multi_surface_id AND o.objectclass_id = 33)
	WHERE 
		sg.geometry IS NOT NULL
	GROUP BY sg.cityobject_id
WITH NO DATA;
COMMENT ON MATERIALIZED VIEW qgis_pkg._geom_citydb_bdg_roofsurface_lod2_multisurf IS 'Materialized view of (Building) RoofSurface, as LoD2 multisurface (multipolygon in QGIS)';
CREATE INDEX _g_citydb_bdg_roofsurf_lod2_multisurf_id_idx   ON qgis_pkg._geom_citydb_bdg_roofsurface_lod2_multisurf (co_id);
CREATE INDEX _g_citydb_bdg_roofsurf_lod2_multisurf_geom_spx ON qgis_pkg._geom_citydb_bdg_roofsurface_lod2_multisurf USING gist (geom);

---------------------------------------------------------------
-- Create MATERIALIZED VIEW QGIS_PKG.CITYDB_BDG_CLOSURESURFACE_LOD2_MULTISURF
---------------------------------------------------------------
DROP MATERIALIZED VIEW IF EXISTS qgis_pkg._geom_citydb_bdg_closuresurface_lod2_multisurf CASCADE;
CREATE MATERIALIZED VIEW         qgis_pkg._geom_citydb_bdg_closuresurface_lod2_multisurf AS
	SELECT
		sg.cityobject_id::bigint AS co_id,
		ST_Collect(sg.geometry)::geometry(MultiPolygonZ) AS geom 		
	FROM 
		citydb.thematic_surface AS o
		INNER JOIN citydb.surface_geometry AS sg ON (sg.root_id = o.lod2_multi_surface_id AND o.objectclass_id = 36)
	WHERE 
		sg.geometry IS NOT NULL
	GROUP BY sg.cityobject_id
WITH NO DATA;
COMMENT ON MATERIALIZED VIEW qgis_pkg._geom_citydb_bdg_closuresurface_lod2_multisurf IS 'Materialized view of (Building) ClosureSurface, as LoD2 multisurface (multipolygon in QGIS)';
CREATE INDEX _g_citydb_bdg_closuresurf_lod2_multisurf_id_idx   ON qgis_pkg._geom_citydb_bdg_closuresurface_lod2_multisurf (co_id);
CREATE INDEX _g_citydb_bdg_closuresurf_lod2_multisurf_geom_spx ON qgis_pkg._geom_citydb_bdg_closuresurface_lod2_multisurf USING gist (geom);

---------------------------------------------------------------
-- Create MATERIALIZED VIEW QGIS_PKG.CITYDB_BDG_OUTERCEILINGSURFACE_LOD2_MULTISURF
---------------------------------------------------------------
DROP MATERIALIZED VIEW IF EXISTS qgis_pkg._geom_citydb_bdg_outerceilingsurface_lod2_multisurf CASCADE;
CREATE MATERIALIZED VIEW         qgis_pkg._geom_citydb_bdg_outerceilingsurface_lod2_multisurf AS
	SELECT
		sg.cityobject_id::bigint AS co_id,
		ST_Collect(sg.geometry)::geometry(MultiPolygonZ) AS geom 		
	FROM 
		citydb.thematic_surface AS o
		INNER JOIN citydb.surface_geometry AS sg ON (sg.root_id = o.lod2_multi_surface_id AND o.objectclass_id = 60)
	WHERE 
		sg.geometry IS NOT NULL
	GROUP BY sg.cityobject_id
WITH NO DATA;
COMMENT ON MATERIALIZED VIEW qgis_pkg._geom_citydb_bdg_outerceilingsurface_lod2_multisurf IS 'Materialized view of (Building) OuterCeilingSurface, as LoD2 multisurface (multipolygon in QGIS)';
CREATE INDEX _g_citydb_bdg_outerceilingsurf_lod2_multisurf_id_idx   ON qgis_pkg._geom_citydb_bdg_outerceilingsurface_lod2_multisurf (co_id);
CREATE INDEX _g_citydb_bdg_outerceilingsurf_lod2_multisurf_geom_spx ON qgis_pkg._geom_citydb_bdg_outerceilingsurface_lod2_multisurf USING gist (geom);

---------------------------------------------------------------
-- Create MATERIALIZED VIEW QGIS_PKG.CITYDB_BDG_OUTERFLOORSURFACE_LOD2_MULTISURF
---------------------------------------------------------------
DROP MATERIALIZED VIEW IF EXISTS qgis_pkg._geom_citydb_bdg_outerfloorsurface_lod2_multisurf CASCADE;
CREATE MATERIALIZED VIEW         qgis_pkg._geom_citydb_bdg_outerfloorsurface_lod2_multisurf AS
	SELECT
		sg.cityobject_id::bigint AS co_id,
		ST_Collect(sg.geometry)::geometry(MultiPolygonZ) AS geom 		
	FROM 
		citydb.thematic_surface AS o
		INNER JOIN citydb.surface_geometry AS sg ON (sg.root_id = o.lod2_multi_surface_id AND o.objectclass_id = 61)
	WHERE 
		sg.geometry IS NOT NULL
	GROUP BY sg.cityobject_id
WITH NO DATA;
COMMENT ON MATERIALIZED VIEW qgis_pkg._geom_citydb_bdg_outerfloorsurface_lod2_multisurf IS 'Materialized view of (Building) OuterFloorSurface, as LoD2 multisurface (multipolygon in QGIS)';
CREATE INDEX _g_citydb_bdg_outerfloorsurf_lod2_multisurf_id_idx   ON qgis_pkg._geom_citydb_bdg_outerfloorsurface_lod2_multisurf (co_id);
CREATE INDEX _g_citydb_bdg_outerfloorsurf_lod2_multisurf_geom_spx ON qgis_pkg._geom_citydb_bdg_outerfloorsurface_lod2_multisurf USING gist (geom);

--*************************************************************
--*************************************************************
---------------------------------------------------------------
-- Create MATERIALIZED VIEW QGIS_PKG.CITYDB_BDG_OUTERINSTALLATION_LOD2_MULTISURF
---------------------------------------------------------------
DROP MATERIALIZED VIEW IF EXISTS qgis_pkg._geom_citydb_bdg_outerinstallation_lod2_multisurf CASCADE;
CREATE MATERIALIZED VIEW         qgis_pkg._geom_citydb_bdg_outerinstallation_lod2_multisurf AS
	SELECT
		sg.cityobject_id::bigint AS co_id,
		ST_Collect(sg.geometry)::geometry(MultiPolygonZ) AS geom 		
	FROM 
		citydb.building_installation AS o
		INNER JOIN citydb.surface_geometry AS sg ON (sg.root_id = o.lod2_brep_id AND o.objectclass_id = 27)
	WHERE 
		sg.geometry IS NOT NULL
	GROUP BY sg.cityobject_id
WITH NO DATA;
COMMENT ON MATERIALIZED VIEW qgis_pkg._geom_citydb_bdg_outerinstallation_lod2_multisurf IS 'Materialized view of (Building) OuterInstallation, as LoD2 geometry (multipolygon in QGIS)';
CREATE INDEX _g_citydb_bdg_outerinstallation_lod2_multisurf_id_idx   ON qgis_pkg._geom_citydb_bdg_outerinstallation_lod2_multisurf (co_id);
CREATE INDEX _g_citydb_bdg_outerinstallation_lod2_multisurf_geom_spx ON qgis_pkg._geom_citydb_bdg_outerinstallation_lod2_multisurf USING gist (geom);

--**************************
DO $$
BEGIN
RAISE NOTICE 'Done';
END $$;
--**************************


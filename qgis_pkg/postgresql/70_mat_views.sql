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
CREATE INDEX _g_citydb_bdg_lod0_fp_id_idx   ON qgis_pkg._geom_citydb_bdg_lod0_footprint (co_id);
CREATE INDEX _g_citydb_bdg_lod0_fp_geom_spx ON qgis_pkg._geom_citydb_bdg_lod0_footprint USING gist (geom);

INSERT INTO qgis_pkg.materialized_view (is_up_to_date, name) VALUES
(FALSE, '_geom_citydb_bdg_lod0_footprint');

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
CREATE INDEX _g_citydb_bdg_part_lod0_fp_id_idx   ON qgis_pkg._geom_citydb_bdg_lod0_footprint (co_id);
CREATE INDEX _g_citydb_bdg_part_lod0_fp_geom_spx ON qgis_pkg._geom_citydb_bdg_lod0_footprint USING gist (geom);

INSERT INTO qgis_pkg.materialized_view (is_up_to_date, name) VALUES
(FALSE, '_geom_citydb_bdg_part_lod0_footprint');

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
CREATE INDEX _g_citydb_bdg_lod0_re_id_idx   ON qgis_pkg._geom_citydb_bdg_lod0_roofedge (co_id);
CREATE INDEX _g_citydb_bdg_lod0_re_geom_spx ON qgis_pkg._geom_citydb_bdg_lod0_roofedge USING gist (geom);

INSERT INTO qgis_pkg.materialized_view (is_up_to_date, name) VALUES
(FALSE, '_geom_citydb_bdg_lod0_roofedge');

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
CREATE INDEX _g_citydb_bdg_part_lod0_re_id_idx   ON qgis_pkg._geom_citydb_bdg_lod0_roofedge (co_id);
CREATE INDEX _g_citydb_bdg_part_lod0_re_geom_spx ON qgis_pkg._geom_citydb_bdg_lod0_roofedge USING gist (geom);

INSERT INTO qgis_pkg.materialized_view (is_up_to_date, name) VALUES
(FALSE, '_geom_citydb_bdg_part_lod0_roofedge');


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
CREATE INDEX _g_citydb_bdg_lod1_ms_id_idx   ON qgis_pkg._geom_citydb_bdg_lod1_multisurf (co_id);
CREATE INDEX _g_citydb_bdg_lod1_ms_geom_spx ON qgis_pkg._geom_citydb_bdg_lod1_multisurf USING gist (geom);

INSERT INTO qgis_pkg.materialized_view (is_up_to_date, name) VALUES
(FALSE, '_geom_citydb_bdg_lod1_multisurf');


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
CREATE INDEX _g_citydb_bdg_part_lod1_ms_id_idx   ON qgis_pkg._geom_citydb_bdg_part_lod1_multisurf (co_id);
CREATE INDEX _g_citydb_bdg_part_lod1_ms_geom_spx ON qgis_pkg._geom_citydb_bdg_part_lod1_multisurf USING gist (geom);

INSERT INTO qgis_pkg.materialized_view (is_up_to_date, name) VALUES
(FALSE, '_geom_citydb_bdg_part_lod1_multisurf');

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
CREATE INDEX _g_citydb_bdg_lod2_ms_id_idx   ON qgis_pkg._geom_citydb_bdg_lod2_multisurf (co_id);
CREATE INDEX _g_citydb_bdg_lod2_ms_geom_spx ON qgis_pkg._geom_citydb_bdg_lod2_multisurf USING gist (geom);

INSERT INTO qgis_pkg.materialized_view (is_up_to_date, name) VALUES
(FALSE, '_geom_citydb_bdg_lod2_multisurf');

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
CREATE INDEX _g_citydb_bdg_part_lod2_ms_id_idx   ON qgis_pkg._geom_citydb_bdg_part_lod2_multisurf (co_id);
CREATE INDEX _g_citydb_bdg_part_lod2_ms_geom_spx ON qgis_pkg._geom_citydb_bdg_part_lod2_multisurf USING gist (geom);

INSERT INTO qgis_pkg.materialized_view (is_up_to_date, name) VALUES
(FALSE, '_geom_citydb_bdg_part_lod2_multisurf');



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
CREATE INDEX _g_citydb_bdg_lod1_s_id_idx   ON qgis_pkg._geom_citydb_bdg_lod1_solid (co_id);
CREATE INDEX _g_citydb_bdg_lod1_s_geom_spx ON qgis_pkg._geom_citydb_bdg_lod1_solid USING gist (geom);

INSERT INTO qgis_pkg.materialized_view (is_up_to_date, name) VALUES
(FALSE, '_geom_citydb_bdg_lod1_solid');


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
CREATE INDEX _g_citydb_bdg_part_lod1_s_id_idx   ON qgis_pkg._geom_citydb_bdg_part_lod1_solid (co_id);
CREATE INDEX _g_citydb_bdg_part_lod1_s_geom_spx ON qgis_pkg._geom_citydb_bdg_part_lod1_solid USING gist (geom);

INSERT INTO qgis_pkg.materialized_view (is_up_to_date, name) VALUES
(FALSE, '_geom_citydb_bdg_part_lod1_solid');


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
CREATE INDEX _g_citydb_bdg_lod2_s_id_idx   ON qgis_pkg._geom_citydb_bdg_lod2_solid (co_id);
CREATE INDEX _g_citydb_bdg_lod2_s_geom_spx ON qgis_pkg._geom_citydb_bdg_lod2_solid USING gist (geom);

INSERT INTO qgis_pkg.materialized_view (is_up_to_date, name) VALUES
(FALSE, '_geom_citydb_bdg_lod2_solid');


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
CREATE INDEX _g_citydb_bdg_part_lod2_s_id_idx   ON qgis_pkg._geom_citydb_bdg_part_lod2_solid (co_id);
CREATE INDEX _g_citydb_bdg_part_lod2_s_geom_spx ON qgis_pkg._geom_citydb_bdg_part_lod2_solid USING gist (geom);

INSERT INTO qgis_pkg.materialized_view (is_up_to_date, name) VALUES
(FALSE, '_geom_citydb_bdg_part_lod2_solid');

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
CREATE INDEX _g_citydb_bdg_groundsurf_lod2_ms_id_idx   ON qgis_pkg._geom_citydb_bdg_groundsurface_lod2_multisurf (co_id);
CREATE INDEX _g_citydb_bdg_groundsurf_lod2_ms_geom_spx ON qgis_pkg._geom_citydb_bdg_groundsurface_lod2_multisurf USING gist (geom);

INSERT INTO qgis_pkg.materialized_view (is_up_to_date, name) VALUES
(FALSE, '_geom_citydb_bdg_groundsurface_lod2_multisurf');


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
CREATE INDEX _g_citydb_bdg_wallsurf_lod2_ms_id_idx   ON qgis_pkg._geom_citydb_bdg_wallsurface_lod2_multisurf (co_id);
CREATE INDEX _g_citydb_bdg_wallsurf_lod2_ms_geom_spx ON qgis_pkg._geom_citydb_bdg_wallsurface_lod2_multisurf USING gist (geom);

INSERT INTO qgis_pkg.materialized_view (is_up_to_date, name) VALUES
(FALSE, '_geom_citydb_bdg_wallsurface_lod2_multisurf');


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
CREATE INDEX _g_citydb_bdg_roofsurf_lod2_ms_id_idx   ON qgis_pkg._geom_citydb_bdg_roofsurface_lod2_multisurf (co_id);
CREATE INDEX _g_citydb_bdg_roofsurf_lod2_ms_geom_spx ON qgis_pkg._geom_citydb_bdg_roofsurface_lod2_multisurf USING gist (geom);

INSERT INTO qgis_pkg.materialized_view (is_up_to_date, name) VALUES
(FALSE, '_geom_citydb_bdg_roofsurface_lod2_multisurf');


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
CREATE INDEX _g_citydb_bdg_closuresurf_lod2_ms_id_idx   ON qgis_pkg._geom_citydb_bdg_closuresurface_lod2_multisurf (co_id);
CREATE INDEX _g_citydb_bdg_closuresurf_lod2_ms_geom_spx ON qgis_pkg._geom_citydb_bdg_closuresurface_lod2_multisurf USING gist (geom);

INSERT INTO qgis_pkg.materialized_view (is_up_to_date, name) VALUES
(FALSE, '_geom_citydb_bdg_closuresurface_lod2_multisurf');


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
CREATE INDEX _g_citydb_bdg_outerceilingsurf_lod2_ms_id_idx   ON qgis_pkg._geom_citydb_bdg_outerceilingsurface_lod2_multisurf (co_id);
CREATE INDEX _g_citydb_bdg_outerceilingsurf_lod2_ms_geom_spx ON qgis_pkg._geom_citydb_bdg_outerceilingsurface_lod2_multisurf USING gist (geom);

INSERT INTO qgis_pkg.materialized_view (is_up_to_date, name) VALUES
(FALSE, '_geom_citydb_bdg_outerceilingsurface_lod2_multisurf');

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
CREATE INDEX _g_citydb_bdg_outerfloorsurf_lod2_ms_id_idx   ON qgis_pkg._geom_citydb_bdg_outerfloorsurface_lod2_multisurf (co_id);
CREATE INDEX _g_citydb_bdg_outerfloorsurf_lod2_ms_geom_spx ON qgis_pkg._geom_citydb_bdg_outerfloorsurface_lod2_multisurf USING gist (geom);

INSERT INTO qgis_pkg.materialized_view (is_up_to_date, name) VALUES
(FALSE, '_geom_citydb_bdg_outerfloorsurface_lod2_multisurf');


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
CREATE INDEX _g_citydb_bdg_outerinstallation_lod2_ms_id_idx   ON qgis_pkg._geom_citydb_bdg_outerinstallation_lod2_multisurf (co_id);
CREATE INDEX _g_citydb_bdg_outerinstallation_lod2_ms_geom_spx ON qgis_pkg._geom_citydb_bdg_outerinstallation_lod2_multisurf USING gist (geom);

INSERT INTO qgis_pkg.materialized_view (is_up_to_date, name) VALUES
(FALSE, '_geom_citydb_bdg_outerinstallation_lod2_multisurf');


--*************************************************************
--*************************************************************
---------------------------------------------------------------
-- Create MATERIALIZED VIEW QGIS_PKG.CITYDB_RELIEF_FEATURE_LOD1_POLYGON
---------------------------------------------------------------
DROP MATERIALIZED VIEW IF EXISTS qgis_pkg._geom_citydb_relief_feature_lod1_polygon CASCADE;
CREATE MATERIALIZED VIEW         qgis_pkg._geom_citydb_relief_feature_lod1_polygon AS
	SELECT
		o.id::bigint AS co_id,
		co.envelope::geometry(PolygonZ) AS geom 
	FROM 
		citydb.relief_feature AS o
		INNER JOIN citydb.cityobject AS co ON (co.id = o.id AND o.objectclass_id = 14)
	WHERE 
		lod = 1
WITH NO DATA;
COMMENT ON MATERIALIZED VIEW qgis_pkg._geom_citydb_relief_feature_lod1_polygon IS 'Materialized view of Relief Feature (extents), as LoD1 geometry (polygon in QGIS)';
CREATE INDEX _g_citydb_relief_feature_lod1_p_id_idx   ON qgis_pkg._geom_citydb_relief_feature_lod1_polygon (co_id);
CREATE INDEX _g_citydb_relief_feature_lod1_p_geom_spx ON qgis_pkg._geom_citydb_relief_feature_lod1_polygon USING gist (geom);

INSERT INTO qgis_pkg.materialized_view (is_up_to_date, name) VALUES
(FALSE, '_geom_citydb_relief_feature_lod1_polygon');


--*************************************************************
--*************************************************************
---------------------------------------------------------------
-- Create MATERIALIZED VIEW QGIS_PKG.CITYDB_RELIEF_FEATURE_LOD2_POLYGON
---------------------------------------------------------------
DROP MATERIALIZED VIEW IF EXISTS qgis_pkg._geom_citydb_relief_feature_lod2_polygon CASCADE;
CREATE MATERIALIZED VIEW         qgis_pkg._geom_citydb_relief_feature_lod2_polygon AS
	SELECT
		o.id::bigint AS co_id,
		co.envelope::geometry(PolygonZ) AS geom 
	FROM 
		citydb.relief_feature AS o
		INNER JOIN citydb.cityobject AS co ON (co.id = o.id AND o.objectclass_id = 14)
	WHERE 
		lod = 2
WITH NO DATA;
COMMENT ON MATERIALIZED VIEW qgis_pkg._geom_citydb_relief_feature_lod2_polygon IS 'Materialized view of Relief Feature (extents), as LoD2 geometry (polygon in QGIS)';
CREATE INDEX _g_citydb_relief_feature_lod2_p_id_idx   ON qgis_pkg._geom_citydb_relief_feature_lod2_polygon (co_id);
CREATE INDEX _g_citydb_relief_feature_lod2_p_geom_spx ON qgis_pkg._geom_citydb_relief_feature_lod2_polygon USING gist (geom);

INSERT INTO qgis_pkg.materialized_view (is_up_to_date, name) VALUES
(FALSE, '_geom_citydb_relief_feature_lod2_polygon');


--*************************************************************
--*************************************************************
---------------------------------------------------------------
-- Create MATERIALIZED VIEW QGIS_PKG.CITYDB_TIN_RELIEF_LOD1_TIN
---------------------------------------------------------------
DROP MATERIALIZED VIEW IF EXISTS qgis_pkg._geom_citydb_tin_relief_lod1_tin CASCADE;
CREATE MATERIALIZED VIEW         qgis_pkg._geom_citydb_tin_relief_lod1_tin AS
	SELECT
		sg.cityobject_id::bigint AS co_id,
		ST_Collect(sg.geometry)::geometry(MultiPolygonZ) AS geom 		
	FROM 
		citydb.tin_relief AS o
		INNER JOIN citydb.relief_component AS o2 ON (o2.id = o.id AND o.objectclass_id = 16 AND o2.lod=1)
		INNER JOIN citydb.surface_geometry AS sg ON (sg.root_id = o.surface_geometry_id AND o.objectclass_id = 16)
	WHERE 
		sg.geometry IS NOT NULL
	GROUP BY sg.cityobject_id
WITH NO DATA;
COMMENT ON MATERIALIZED VIEW qgis_pkg._geom_citydb_tin_relief_lod1_tin IS 'Materialized view of TINRelief, as LoD1 TIN (multipolygon in QGIS)';
CREATE INDEX _g_citydb_tin_relief_lod1_tin_id_idx   ON qgis_pkg._geom_citydb_tin_relief_lod1_tin (co_id);
CREATE INDEX _g_citydb_tin_relief_lod1_tin_geom_spx ON qgis_pkg._geom_citydb_tin_relief_lod1_tin USING gist (geom);

INSERT INTO qgis_pkg.materialized_view (is_up_to_date, name) VALUES
(FALSE, '_geom_citydb_tin_relief_lod1_tin');


--*************************************************************
--*************************************************************
---------------------------------------------------------------
-- Create MATERIALIZED VIEW QGIS_PKG.CITYDB_TIN_RELIEF_LOD2_TIN
---------------------------------------------------------------
DROP MATERIALIZED VIEW IF EXISTS qgis_pkg._geom_citydb_tin_relief_lod2_tin CASCADE;
CREATE MATERIALIZED VIEW         qgis_pkg._geom_citydb_tin_relief_lod2_tin AS
	SELECT
		sg.cityobject_id::bigint AS co_id,
		ST_Collect(sg.geometry)::geometry(MultiPolygonZ) AS geom 		
	FROM 
		citydb.tin_relief AS o
		INNER JOIN citydb.relief_component AS o2 ON (o2.id = o.id AND o.objectclass_id = 16 AND o2.lod=2)
		INNER JOIN citydb.surface_geometry AS sg ON (sg.root_id = o.surface_geometry_id AND o.objectclass_id = 16)
	WHERE 
		sg.geometry IS NOT NULL
	GROUP BY sg.cityobject_id
WITH NO DATA;
COMMENT ON MATERIALIZED VIEW qgis_pkg._geom_citydb_tin_relief_lod2_tin IS 'Materialized view of TINRelief, as LoD2 TIN (multipolygon in QGIS)';
CREATE INDEX _g_citydb_tin_relief_lod2_tin_id_idx   ON qgis_pkg._geom_citydb_tin_relief_lod2_tin (co_id);
CREATE INDEX _g_citydb_tin_relief_lod2_tin_geom_spx ON qgis_pkg._geom_citydb_tin_relief_lod2_tin USING gist (geom);

INSERT INTO qgis_pkg.materialized_view (is_up_to_date, name) VALUES
(FALSE, '_geom_citydb_tin_relief_lod2_tin');



--*************************************************************
--*************************************************************
---------------------------------------------------------------
-- Create MATERIALIZED VIEW QGIS_PKG.CITYDB_SOLITARY_VEGETAT_OBJECT_LOD2_multisurf
---------------------------------------------------------------
DROP MATERIALIZED VIEW IF EXISTS qgis_pkg._geom_citydb_solitary_vegetat_object_lod2_multisurf CASCADE;
CREATE MATERIALIZED VIEW         qgis_pkg._geom_citydb_solitary_vegetat_object_lod2_multisurf AS
	SELECT
		sg.cityobject_id::bigint AS co_id,
		ST_Collect(sg.geometry)::geometry(MultiPolygonZ) AS geom 		
	FROM 
		citydb.solitary_vegetat_object AS o
		INNER JOIN citydb.surface_geometry AS sg ON (sg.root_id = o.lod2_brep_id AND o.objectclass_id = 7)
	WHERE 
		sg.geometry IS NOT NULL
	GROUP BY sg.cityobject_id
WITH NO DATA;
COMMENT ON MATERIALIZED VIEW qgis_pkg._geom_citydb_solitary_vegetat_object_lod2_multisurf IS 'Materialized view of Solitary Vegetation Object, as LoD2 geometry (multipolygon in QGIS)';
CREATE INDEX _g_citydb_sol_veg_obj_lod2_ms_id_idx   ON qgis_pkg._geom_citydb_solitary_vegetat_object_lod2_multisurf  (co_id);
CREATE INDEX _g_citydb_sol_veg_obj_lod2_ms_geom_spx ON qgis_pkg._geom_citydb_solitary_vegetat_object_lod2_multisurf  USING gist (geom);

INSERT INTO qgis_pkg.materialized_view (is_up_to_date, name) VALUES
(FALSE, '_geom_citydb_solitary_vegetat_object_lod2_multisurf');


--*************************************************************
--*************************************************************
---------------------------------------------------------------
-- Create MATERIALIZED VIEW QGIS_PKG.CITYDB_SOLITARY_VEGETAT_OBJECT_LOD1_IMPLICITREP
---------------------------------------------------------------
DROP MATERIALIZED VIEW IF EXISTS qgis_pkg._geom_citydb_solitary_vegetat_object_lod1_implicitrep CASCADE;
CREATE MATERIALIZED VIEW         qgis_pkg._geom_citydb_solitary_vegetat_object_lod1_implicitrep AS
	SELECT
		o.id::bigint AS co_id,
		ST_SetSRID(
			ST_Affine(ST_Collect(sg.implicit_geometry),
				   split_part(lod1_implicit_transformation, ' ', 1)::numeric,
				   0,
				   0,
				   0,
				   split_part(lod1_implicit_transformation, ' ', 6)::numeric,
				   0,
				   0,
				   0,
				   split_part(lod1_implicit_transformation, ' ', 11)::numeric,
				   ST_X(o.lod1_implicit_ref_point),
				   ST_Y(o.lod1_implicit_ref_point),
				   ST_Z(o.lod1_implicit_ref_point)
				   ),
			srs.srid)::geometry(MultiPolygonZ) AS geom		
	FROM 
		citydb.solitary_vegetat_object AS o
		INNER JOIN citydb.implicit_geometry AS ig ON (ig.id = o.lod1_implicit_rep_id AND o.objectclass_id = 7)
		INNER JOIN citydb.surface_geometry AS sg ON (sg.root_id = ig.relative_brep_id),
		citydb.database_srs AS srs
	WHERE 
		sg.implicit_geometry IS NOT NULL
	GROUP BY o.id,srs.srid
WITH NO DATA;
COMMENT ON MATERIALIZED VIEW qgis_pkg._geom_citydb_solitary_vegetat_object_lod1_implicitrep IS 'Materialized view of Solitary Vegetation Object, as LoD2 implicit (brep) geometry (multipolygon in QGIS)';
CREATE INDEX _g_citydb_sol_veg_obj_lod1_ig_id_idx   ON qgis_pkg._geom_citydb_solitary_vegetat_object_lod1_implicitrep (co_id);
CREATE INDEX _g_citydb_sol_veg_obj_lod1_ig_geom_spx ON qgis_pkg._geom_citydb_solitary_vegetat_object_lod1_implicitrep USING gist (geom);

INSERT INTO qgis_pkg.materialized_view (is_up_to_date, name) VALUES
(FALSE, '_geom_citydb_solitary_vegetat_object_lod1_implicitrep');


--*************************************************************
--*************************************************************
---------------------------------------------------------------
-- Create MATERIALIZED VIEW QGIS_PKG.CITYDB_SOLITARY_VEGETAT_OBJECT_LOD2_IMPLICITREP
---------------------------------------------------------------
DROP MATERIALIZED VIEW IF EXISTS qgis_pkg._geom_citydb_solitary_vegetat_object_lod2_implicitrep CASCADE;
CREATE MATERIALIZED VIEW         qgis_pkg._geom_citydb_solitary_vegetat_object_lod2_implicitrep AS
	SELECT
		o.id::bigint AS co_id,
		ST_SetSRID(
			ST_Affine(ST_Collect(sg.implicit_geometry),
				   split_part(lod2_implicit_transformation, ' ', 1)::numeric,
				   0,
				   0,
				   0,
				   split_part(lod2_implicit_transformation, ' ', 6)::numeric,
				   0,
				   0,
				   0,
				   split_part(lod2_implicit_transformation, ' ', 11)::numeric,
				   ST_X(o.lod2_implicit_ref_point),
				   ST_Y(o.lod2_implicit_ref_point),
				   ST_Z(o.lod2_implicit_ref_point)
				   ),
			srs.srid)::geometry(MultiPolygonZ) AS geom		
	FROM 
		citydb.solitary_vegetat_object AS o
		INNER JOIN citydb.implicit_geometry AS ig ON (ig.id = o.lod2_implicit_rep_id AND o.objectclass_id = 7)
		INNER JOIN citydb.surface_geometry AS sg ON (sg.root_id = ig.relative_brep_id),
		citydb.database_srs AS srs
	WHERE 
		sg.implicit_geometry IS NOT NULL
	GROUP BY o.id,srs.srid
WITH NO DATA;
COMMENT ON MATERIALIZED VIEW qgis_pkg._geom_citydb_solitary_vegetat_object_lod2_implicitrep IS 'Materialized view of Solitary Vegetation Object, as LoD2 implicit (brep) geometry (multipolygon in QGIS)';
CREATE INDEX _g_citydb_sol_veg_obj_lod2_ig_id_idx   ON qgis_pkg._geom_citydb_solitary_vegetat_object_lod2_implicitrep (co_id);
CREATE INDEX _g_citydb_sol_veg_obj_lod2_ig_geom_spx ON qgis_pkg._geom_citydb_solitary_vegetat_object_lod2_implicitrep USING gist (geom);

INSERT INTO qgis_pkg.materialized_view (is_up_to_date, name) VALUES
(FALSE, '_geom_citydb_solitary_vegetat_object_lod2_implicitrep');

--*************************************************************
--*************************************************************
---------------------------------------------------------------
-- Create MATERIALIZED VIEW QGIS_PKG.CITYDB_SOLITARY_VEGETAT_OBJECT_LOD3_IMPLICITREP
---------------------------------------------------------------
DROP MATERIALIZED VIEW IF EXISTS qgis_pkg._geom_citydb_solitary_vegetat_object_lod3_implicitrep CASCADE;
CREATE MATERIALIZED VIEW         qgis_pkg._geom_citydb_solitary_vegetat_object_lod3_implicitrep AS
	SELECT
		o.id::bigint AS co_id,
		ST_SetSRID(
			ST_Affine(ST_Collect(sg.implicit_geometry),
				   split_part(lod3_implicit_transformation, ' ', 1)::numeric,
				   0,
				   0,
				   0,
				   split_part(lod3_implicit_transformation, ' ', 6)::numeric,
				   0,
				   0,
				   0,
				   split_part(lod3_implicit_transformation, ' ', 11)::numeric,
				   ST_X(o.lod3_implicit_ref_point),
				   ST_Y(o.lod3_implicit_ref_point),
				   ST_Z(o.lod3_implicit_ref_point)
				   ),
			srs.srid)::geometry(MultiPolygonZ) AS geom		
	FROM 
		citydb.solitary_vegetat_object AS o
		INNER JOIN citydb.implicit_geometry AS ig ON (ig.id = o.lod3_implicit_rep_id AND o.objectclass_id = 7)
		INNER JOIN citydb.surface_geometry AS sg ON (sg.root_id = ig.relative_brep_id),
		citydb.database_srs AS srs
	WHERE 
		sg.implicit_geometry IS NOT NULL
	GROUP BY o.id,srs.srid
WITH NO DATA;
COMMENT ON MATERIALIZED VIEW qgis_pkg._geom_citydb_solitary_vegetat_object_lod3_implicitrep IS 'Materialized view of Solitary Vegetation Object, as LoD3 implicit (brep) geometry (multipolygon in QGIS)';
CREATE INDEX _g_citydb_sol_veg_obj_lod3_ig_id_idx   ON qgis_pkg._geom_citydb_solitary_vegetat_object_lod3_implicitrep (co_id);
CREATE INDEX _g_citydb_sol_veg_obj_lod3_ig_geom_spx ON qgis_pkg._geom_citydb_solitary_vegetat_object_lod3_implicitrep USING gist (geom);

INSERT INTO qgis_pkg.materialized_view (is_up_to_date, name) VALUES
(FALSE, '_geom_citydb_solitary_vegetat_object_lod3_implicitrep');



--**************************
DO $$
BEGIN
RAISE NOTICE 'Done';
END $$;
--**************************


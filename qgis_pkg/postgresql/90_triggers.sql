-- ****************************************************************************
-- ****************************************************************************
--
--
-- TRIGGERS for views with geometries
--
--
-- ****************************************************************************
-- ****************************************************************************

----------------------------------------------------------------
-- Create TRIGGERS for view QGIS_PKG.CITYDB_BUILDING_LOD0_FOOTPRINT
----------------------------------------------------------------
DROP TRIGGER IF EXISTS tr_del_citydb_building_lod0_footprint ON qgis_pkg.citydb_building_lod0_footprint;
CREATE TRIGGER         tr_del_citydb_building_lod0_footprint
	INSTEAD OF DELETE ON qgis_pkg.citydb_building_lod0_footprint
	FOR EACH ROW
	EXECUTE PROCEDURE qgis_pkg.tr_del_building();
COMMENT ON TRIGGER tr_del_citydb_building_lod0_footprint ON qgis_pkg.citydb_building_lod0_footprint IS 'Fired upon delete on view qgis_pkg.citydb_building_lod0_footprint';

DROP TRIGGER IF EXISTS tr_ins_citydb_building_lod0_footprint ON qgis_pkg.citydb_building_lod0_footprint;
CREATE TRIGGER         tr_ins_citydb_building_lod0_footprint
	INSTEAD OF INSERT ON qgis_pkg.citydb_building_lod0_footprint
	FOR EACH ROW
	EXECUTE PROCEDURE qgis_pkg.tr_ins_building();
COMMENT ON TRIGGER tr_ins_citydb_building_lod0_footprint ON qgis_pkg.citydb_building_lod0_footprint IS 'Fired upon (blocked) insert into view qgis_pkg.citydb_building_lod0_footprint';

DROP TRIGGER IF EXISTS tr_upd_citydb_building_lod0_footprint ON qgis_pkg.citydb_building_lod0_footprint;
CREATE TRIGGER         tr_upd_citydb_building_lod0_footprint
	INSTEAD OF UPDATE ON qgis_pkg.citydb_building_lod0_footprint
	FOR EACH ROW
	EXECUTE PROCEDURE qgis_pkg.tr_upd_building();
COMMENT ON TRIGGER tr_upd_citydb_building_lod0_footprint ON qgis_pkg.citydb_building_lod0_footprint IS 'Fired upon update of view qgis_pkg.citydb_building_lod0_footprint';	

----------------------------------------------------------------
-- Create TRIGGERS for view QGIS_PKG.CITYDB_BUILDING_LOD0_ROOFEDGE
----------------------------------------------------------------
DROP TRIGGER IF EXISTS tr_del_citydb_building_lod0_roofedge ON qgis_pkg.citydb_building_lod0_roofedge;
CREATE TRIGGER         tr_del_citydb_building_lod0_roofedge
	INSTEAD OF DELETE ON qgis_pkg.citydb_building_lod0_roofedge
	FOR EACH ROW
	EXECUTE PROCEDURE qgis_pkg.tr_del_building();
COMMENT ON TRIGGER tr_del_citydb_building_lod0_roofedge ON qgis_pkg.citydb_building_lod0_roofedge IS 'Fired upon delete on view qgis_pkg.citydb_building_lod0_roofedge';

DROP TRIGGER IF EXISTS tr_ins_citydb_building_lod0_roofedge ON qgis_pkg.citydb_building_lod0_roofedge;
CREATE TRIGGER         tr_ins_citydb_building_lod0_roofedge
	INSTEAD OF INSERT ON qgis_pkg.citydb_building_lod0_roofedge
	FOR EACH ROW
	EXECUTE PROCEDURE qgis_pkg.tr_ins_building();
COMMENT ON TRIGGER tr_ins_citydb_building_lod0_roofedge ON qgis_pkg.citydb_building_lod0_roofedge IS 'Fired upon (blocked) insert into view qgis_pkg.citydb_building_lod0_roofedge';

DROP TRIGGER IF EXISTS tr_upd_citydb_building_lod0_roofedge ON qgis_pkg.citydb_building_lod0_roofedge;
CREATE TRIGGER         tr_upd_citydb_building_lod0_roofedge
	INSTEAD OF UPDATE ON qgis_pkg.citydb_building_lod0_roofedge
	FOR EACH ROW
	EXECUTE PROCEDURE qgis_pkg.tr_upd_building();
COMMENT ON TRIGGER tr_upd_citydb_building_lod0_roofedge ON qgis_pkg.citydb_building_lod0_roofedge IS 'Fired upon update of view qgis_pkg.citydb_building_lod0_roofedge';	

--**************************************************************
--**************************************************************
----------------------------------------------------------------
-- Create TRIGGERS for view QGIS_PKG.CITYDB_BUILDING_LOD1_MULTISURF
----------------------------------------------------------------
DROP TRIGGER IF EXISTS tr_del_citydb_building_lod1_multisurf ON qgis_pkg.citydb_building_lod1_multisurf;
CREATE TRIGGER         tr_del_citydb_building_lod1_multisurf
	INSTEAD OF DELETE ON qgis_pkg.citydb_building_lod1_multisurf
	FOR EACH ROW
	EXECUTE PROCEDURE qgis_pkg.tr_del_building();
COMMENT ON TRIGGER tr_del_citydb_building_lod1_multisurf ON qgis_pkg.citydb_building_lod1_multisurf IS 'Fired upon delete on view qgis_pkg.citydb_building_lod1_multisurf';

DROP TRIGGER IF EXISTS tr_ins_citydb_building_lod1_multisurf ON qgis_pkg.citydb_building_lod1_multisurf;
CREATE TRIGGER         tr_ins_citydb_building_lod1_multisurf
	INSTEAD OF INSERT ON qgis_pkg.citydb_building_lod1_multisurf
	FOR EACH ROW
	EXECUTE PROCEDURE qgis_pkg.tr_ins_building();
COMMENT ON TRIGGER tr_ins_citydb_building_lod1_multisurf ON qgis_pkg.citydb_building_lod1_multisurf IS 'Fired upon (blocked) insert into view qgis_pkg.citydb_building_lod1_multisurf';

DROP TRIGGER IF EXISTS tr_upd_citydb_building_lod1_multisurf ON qgis_pkg.citydb_building_lod1_multisurf;
CREATE TRIGGER         tr_upd_citydb_building_lod1_multisurf
	INSTEAD OF UPDATE ON qgis_pkg.citydb_building_lod1_multisurf
	FOR EACH ROW
	EXECUTE PROCEDURE qgis_pkg.tr_upd_building();
COMMENT ON TRIGGER tr_upd_citydb_building_lod1_multisurf ON qgis_pkg.citydb_building_lod1_multisurf IS 'Fired upon update of view qgis_pkg.citydb_building_lod1_multisurf';

----------------------------------------------------------------
-- Create TRIGGERS for view QGIS_PKG.CITYDB_BUILDING_LOD1_SOLID
----------------------------------------------------------------
DROP TRIGGER IF EXISTS tr_del_citydb_building_lod1_solid ON qgis_pkg.citydb_building_lod1_solid;
CREATE TRIGGER         tr_del_citydb_building_lod1_solid
	INSTEAD OF DELETE ON qgis_pkg.citydb_building_lod1_solid
	FOR EACH ROW
	EXECUTE PROCEDURE qgis_pkg.tr_del_building();
COMMENT ON TRIGGER tr_del_citydb_building_lod1_solid ON qgis_pkg.citydb_building_lod1_solid IS 'Fired upon delete on view qgis_pkg.citydb_building_lod1_solid';

DROP TRIGGER IF EXISTS tr_ins_citydb_building_lod1_solid ON qgis_pkg.citydb_building_lod1_solid;
CREATE TRIGGER         tr_ins_citydb_building_lod1_solid
	INSTEAD OF INSERT ON qgis_pkg.citydb_building_lod1_solid
	FOR EACH ROW
	EXECUTE PROCEDURE qgis_pkg.tr_ins_building();
COMMENT ON TRIGGER tr_ins_citydb_building_lod1_solid ON qgis_pkg.citydb_building_lod1_solid IS 'Fired upon (blocked) insert into view qgis_pkg.citydb_building_lod1_solid';

DROP TRIGGER IF EXISTS tr_upd_citydb_building_lod1_solid ON qgis_pkg.citydb_building_lod1_solid;
CREATE TRIGGER         tr_upd_citydb_building_lod1_solid
	INSTEAD OF UPDATE ON qgis_pkg.citydb_building_lod1_solid
	FOR EACH ROW
	EXECUTE PROCEDURE qgis_pkg.tr_upd_building();
COMMENT ON TRIGGER tr_upd_citydb_building_lod1_solid ON qgis_pkg.citydb_building_lod1_solid IS 'Fired upon update of view qgis_pkg.citydb_building_lod1_solid';	


--**************************************************************
--**************************************************************
----------------------------------------------------------------
-- Create TRIGGERS for view QGIS_PKG.CITYDB_BUILDING_LOD2_MULTISURF
----------------------------------------------------------------
DROP TRIGGER IF EXISTS tr_del_citydb_building_lod2_multisurf ON qgis_pkg.citydb_building_lod2_multisurf;
CREATE TRIGGER         tr_del_citydb_building_lod2_multisurf
	INSTEAD OF DELETE ON qgis_pkg.citydb_building_lod2_multisurf
	FOR EACH ROW
	EXECUTE PROCEDURE qgis_pkg.tr_del_building();
COMMENT ON TRIGGER tr_del_citydb_building_lod2_multisurf ON qgis_pkg.citydb_building_lod2_multisurf IS 'Fired upon delete on view qgis_pkg.citydb_building_lod2_multisurf';

DROP TRIGGER IF EXISTS tr_ins_citydb_building_lod2_multisurf ON qgis_pkg.citydb_building_lod2_multisurf;
CREATE TRIGGER         tr_ins_citydb_building_lod2_multisurf
	INSTEAD OF INSERT ON qgis_pkg.citydb_building_lod2_multisurf
	FOR EACH ROW
	EXECUTE PROCEDURE qgis_pkg.tr_ins_building();
COMMENT ON TRIGGER tr_ins_citydb_building_lod2_multisurf ON qgis_pkg.citydb_building_lod2_multisurf IS 'Fired upon (blocked) insert into view qgis_pkg.citydb_building_lod2_multisurf';

DROP TRIGGER IF EXISTS tr_upd_citydb_building_lod2_multisurf ON qgis_pkg.citydb_building_lod2_multisurf;
CREATE TRIGGER         tr_upd_citydb_building_lod2_multisurf
	INSTEAD OF UPDATE ON qgis_pkg.citydb_building_lod2_multisurf
	FOR EACH ROW
	EXECUTE PROCEDURE qgis_pkg.tr_upd_building();
COMMENT ON TRIGGER tr_upd_citydb_building_lod2_multisurf ON qgis_pkg.citydb_building_lod2_multisurf IS 'Fired upon update of view qgis_pkg.citydb_building_lod2_multisurf';	

----------------------------------------------------------------
-- Create TRIGGERS for view QGIS_PKG.CITYDB_BUILDING_LOD2_SOLID
----------------------------------------------------------------
DROP TRIGGER IF EXISTS tr_del_citydb_building_lod2_solid ON qgis_pkg.citydb_building_lod2_solid;
CREATE TRIGGER         tr_del_citydb_building_lod2_solid
	INSTEAD OF DELETE ON qgis_pkg.citydb_building_lod2_solid
	FOR EACH ROW
	EXECUTE PROCEDURE qgis_pkg.tr_del_building();
COMMENT ON TRIGGER tr_del_citydb_building_lod2_solid ON qgis_pkg.citydb_building_lod2_solid IS 'Fired upon delete on view qgis_pkg.citydb_building_lod2_solid';

DROP TRIGGER IF EXISTS tr_ins_citydb_building_lod2_solid ON qgis_pkg.citydb_building_lod2_solid;
CREATE TRIGGER         tr_ins_citydb_building_lod2_solid
	INSTEAD OF INSERT ON qgis_pkg.citydb_building_lod2_solid
	FOR EACH ROW
	EXECUTE PROCEDURE qgis_pkg.tr_ins_building();
COMMENT ON TRIGGER tr_ins_citydb_building_lod2_solid ON qgis_pkg.citydb_building_lod2_solid IS 'Fired upon (blocked) insert into view qgis_pkg.citydb_building_lod2_solid';

DROP TRIGGER IF EXISTS tr_upd_citydb_building_lod2_solid ON qgis_pkg.citydb_building_lod2_solid;
CREATE TRIGGER         tr_upd_citydb_building_lod2_solid
	INSTEAD OF UPDATE ON qgis_pkg.citydb_building_lod2_solid
	FOR EACH ROW
	EXECUTE PROCEDURE qgis_pkg.tr_upd_building();
COMMENT ON TRIGGER tr_upd_citydb_building_lod2_solid ON qgis_pkg.citydb_building_lod2_solid IS 'Fired upon update of view qgis_pkg.citydb_building_lod2_solid';	

--**************************************************************
--**************************************************************
----------------------------------------------------------------
-- Create TRIGGERS for view QGIS_PKG.CITYDB_BUILDING_PART_LOD0_FOOTPRINT
----------------------------------------------------------------
DROP TRIGGER IF EXISTS tr_del_citydb_building_lod0_footprint ON qgis_pkg.citydb_building_part_lod0_footprint;
CREATE TRIGGER         tr_del_citydb_building_part_lod0_footprint
	INSTEAD OF DELETE ON qgis_pkg.citydb_building_part_lod0_footprint
	FOR EACH ROW
	EXECUTE PROCEDURE qgis_pkg.tr_del_building();
COMMENT ON TRIGGER tr_del_citydb_building_part_lod0_footprint ON qgis_pkg.citydb_building_part_lod0_footprint IS 'Fired upon delete on view qgis_pkg.citydb_building_part_lod0_footprint';

DROP TRIGGER IF EXISTS tr_ins_citydb_building_part_lod0_footprint ON qgis_pkg.citydb_building_part_lod0_footprint;
CREATE TRIGGER         tr_ins_citydb_building_part_lod0_footprint
	INSTEAD OF INSERT ON qgis_pkg.citydb_building_part_lod0_footprint
	FOR EACH ROW
	EXECUTE PROCEDURE qgis_pkg.tr_ins_building();
COMMENT ON TRIGGER tr_ins_citydb_building_part_lod0_footprint ON qgis_pkg.citydb_building_part_lod0_footprint IS 'Fired upon (blocked) insert into view qgis_pkg.citydb_building_part_lod0_footprint';

DROP TRIGGER IF EXISTS tr_upd_citydb_building_part_lod0_footprint ON qgis_pkg.citydb_building_part_lod0_footprint;
CREATE TRIGGER         tr_upd_citydb_building_part_lod0_footprint
	INSTEAD OF UPDATE ON qgis_pkg.citydb_building_part_lod0_footprint
	FOR EACH ROW
	EXECUTE PROCEDURE qgis_pkg.tr_upd_building();
COMMENT ON TRIGGER tr_upd_citydb_building_part_lod0_footprint ON qgis_pkg.citydb_building_part_lod0_footprint IS 'Fired upon update of view qgis_pkg.citydb_building_part_lod0_footprint';	

----------------------------------------------------------------
-- Create TRIGGERS for view QGIS_PKG.CITYDB_BUILDING_PART_LOD0_ROOFEDGE
----------------------------------------------------------------
DROP TRIGGER IF EXISTS tr_del_citydb_building_part_lod0_roofedge ON qgis_pkg.citydb_building_part_lod0_roofedge;
CREATE TRIGGER         tr_del_citydb_building_part_lod0_roofedge
	INSTEAD OF DELETE ON qgis_pkg.citydb_building_part_lod0_roofedge
	FOR EACH ROW
	EXECUTE PROCEDURE qgis_pkg.tr_del_building();
COMMENT ON TRIGGER tr_del_citydb_building_part_lod0_roofedge ON qgis_pkg.citydb_building_part_lod0_roofedge IS 'Fired upon delete on view qgis_pkg.citydb_building_part_lod0_roofedge';

DROP TRIGGER IF EXISTS tr_ins_citydb_building_part_lod0_roofedge ON qgis_pkg.citydb_building_part_lod0_roofedge;
CREATE TRIGGER         tr_ins_citydb_building_part_lod0_roofedge
	INSTEAD OF INSERT ON qgis_pkg.citydb_building_part_lod0_roofedge
	FOR EACH ROW
	EXECUTE PROCEDURE qgis_pkg.tr_ins_building();
COMMENT ON TRIGGER tr_ins_citydb_building_part_lod0_roofedge ON qgis_pkg.citydb_building_part_lod0_roofedge IS 'Fired upon (blocked) insert into view qgis_pkg.citydb_building_part_lod0_roofedge';

DROP TRIGGER IF EXISTS tr_upd_citydb_building_part_lod0_roofedge ON qgis_pkg.citydb_building_part_lod0_roofedge;
CREATE TRIGGER         tr_upd_citydb_building_part_lod0_roofedge
	INSTEAD OF UPDATE ON qgis_pkg.citydb_building_part_lod0_roofedge
	FOR EACH ROW
	EXECUTE PROCEDURE qgis_pkg.tr_upd_building();
COMMENT ON TRIGGER tr_upd_citydb_building_part_lod0_roofedge ON qgis_pkg.citydb_building_part_lod0_roofedge IS 'Fired upon update of view qgis_pkg.citydb_building_part_lod0_roofedge';	

--**************************************************************
--**************************************************************
----------------------------------------------------------------
-- Create TRIGGERS for view QGIS_PKG.CITYDB_BUILDING_PART_LOD1_MULTISURF
----------------------------------------------------------------
DROP TRIGGER IF EXISTS tr_del_citydb_building_part_lod1_multisurf ON qgis_pkg.citydb_building_part_lod1_multisurf;
CREATE TRIGGER         tr_del_citydb_building_part_lod1_multisurf
	INSTEAD OF DELETE ON qgis_pkg.citydb_building_part_lod1_multisurf
	FOR EACH ROW
	EXECUTE PROCEDURE qgis_pkg.tr_del_building();
COMMENT ON TRIGGER tr_del_citydb_building_part_lod1_multisurf ON qgis_pkg.citydb_building_part_lod1_multisurf IS 'Fired upon delete on view qgis_pkg.citydb_building_part_lod1_multisurf';

DROP TRIGGER IF EXISTS tr_ins_citydb_building_part_lod1_multisurf ON qgis_pkg.citydb_building_part_lod1_multisurf;
CREATE TRIGGER         tr_ins_citydb_building_part_lod1_multisurf
	INSTEAD OF INSERT ON qgis_pkg.citydb_building_part_lod1_multisurf
	FOR EACH ROW
	EXECUTE PROCEDURE qgis_pkg.tr_ins_building();
COMMENT ON TRIGGER tr_ins_citydb_building_part_lod1_multisurf ON qgis_pkg.citydb_building_part_lod1_multisurf IS 'Fired upon (blocked) insert into view qgis_pkg.citydb_building_part_lod1_multisurf';

DROP TRIGGER IF EXISTS tr_upd_citydb_building_part_lod1_multisurf ON qgis_pkg.citydb_building_part_lod1_multisurf;
CREATE TRIGGER         tr_upd_citydb_building_part_lod1_multisurf
	INSTEAD OF UPDATE ON qgis_pkg.citydb_building_part_lod1_multisurf
	FOR EACH ROW
	EXECUTE PROCEDURE qgis_pkg.tr_upd_building();
COMMENT ON TRIGGER tr_upd_citydb_building_part_lod1_multisurf ON qgis_pkg.citydb_building_part_lod1_multisurf IS 'Fired upon update of view qgis_pkg.citydb_building_part_lod1_multisurf';

----------------------------------------------------------------
-- Create TRIGGERS for view QGIS_PKG.CITYDB_BUILDING_PART_LOD1_SOLID
----------------------------------------------------------------
DROP TRIGGER IF EXISTS tr_del_citydb_building_part_lod1_solid ON qgis_pkg.citydb_building_part_lod1_solid;
CREATE TRIGGER         tr_del_citydb_building_part_lod1_solid
	INSTEAD OF DELETE ON qgis_pkg.citydb_building_part_lod1_solid
	FOR EACH ROW
	EXECUTE PROCEDURE qgis_pkg.tr_del_building();
COMMENT ON TRIGGER tr_del_citydb_building_part_lod1_solid ON qgis_pkg.citydb_building_part_lod1_solid IS 'Fired upon delete on view qgis_pkg.citydb_building_part_lod1_solid';

DROP TRIGGER IF EXISTS tr_ins_citydb_building_part_lod1_solid ON qgis_pkg.citydb_building_part_lod1_solid;
CREATE TRIGGER         tr_ins_citydb_building_part_lod1_solid
	INSTEAD OF INSERT ON qgis_pkg.citydb_building_part_lod1_solid
	FOR EACH ROW
	EXECUTE PROCEDURE qgis_pkg.tr_ins_building();
COMMENT ON TRIGGER tr_ins_citydb_building_part_lod1_solid ON qgis_pkg.citydb_building_part_lod1_solid IS 'Fired upon (blocked) insert into view qgis_pkg.citydb_building_part_lod1_solid';

DROP TRIGGER IF EXISTS tr_upd_citydb_building_part_lod1_solid ON qgis_pkg.citydb_building_part_lod1_solid;
CREATE TRIGGER         tr_upd_citydb_building_part_lod1_solid
	INSTEAD OF UPDATE ON qgis_pkg.citydb_building_part_lod1_solid
	FOR EACH ROW
	EXECUTE PROCEDURE qgis_pkg.tr_upd_building();
COMMENT ON TRIGGER tr_upd_citydb_building_part_lod1_solid ON qgis_pkg.citydb_building_part_lod1_solid IS 'Fired upon update of view qgis_pkg.citydb_building_part_lod1_solid';	


--**************************************************************
--**************************************************************
----------------------------------------------------------------
-- Create TRIGGERS for view QGIS_PKG.CITYDB_BUILDING_PART_LOD2_MULTISURF
----------------------------------------------------------------
DROP TRIGGER IF EXISTS tr_del_citydb_building_part_lod2_multisurf ON qgis_pkg.citydb_building_part_lod2_multisurf;
CREATE TRIGGER         tr_del_citydb_building_part_lod2_multisurf
	INSTEAD OF DELETE ON qgis_pkg.citydb_building_part_lod2_multisurf
	FOR EACH ROW
	EXECUTE PROCEDURE qgis_pkg.tr_del_building();
COMMENT ON TRIGGER tr_del_citydb_building_part_lod2_multisurf ON qgis_pkg.citydb_building_part_lod2_multisurf IS 'Fired upon delete on view qgis_pkg.citydb_building_part_lod2_multisurf';

DROP TRIGGER IF EXISTS tr_ins_citydb_building_part_lod2_multisurf ON qgis_pkg.citydb_building_part_lod2_multisurf;
CREATE TRIGGER         tr_ins_citydb_building_part_lod2_multisurf
	INSTEAD OF INSERT ON qgis_pkg.citydb_building_part_lod2_multisurf
	FOR EACH ROW
	EXECUTE PROCEDURE qgis_pkg.tr_ins_building();
COMMENT ON TRIGGER tr_ins_citydb_building_part_lod2_multisurf ON qgis_pkg.citydb_building_part_lod2_multisurf IS 'Fired upon (blocked) insert into view qgis_pkg.citydb_building_part_lod2_multisurf';

DROP TRIGGER IF EXISTS tr_upd_citydb_building_part_lod2_multisurf ON qgis_pkg.citydb_building_part_lod2_multisurf;
CREATE TRIGGER         tr_upd_citydb_building_part_lod2_multisurf
	INSTEAD OF UPDATE ON qgis_pkg.citydb_building_part_lod2_multisurf
	FOR EACH ROW
	EXECUTE PROCEDURE qgis_pkg.tr_upd_building();
COMMENT ON TRIGGER tr_upd_citydb_building_part_lod2_multisurf ON qgis_pkg.citydb_building_part_lod2_multisurf IS 'Fired upon update of view qgis_pkg.citydb_building_part_lod2_multisurf';	

----------------------------------------------------------------
-- Create TRIGGERS for view QGIS_PKG.CITYDB_BUILDING_PART_LOD2_SOLID
----------------------------------------------------------------
DROP TRIGGER IF EXISTS tr_del_citydb_building_part_lod2_solid ON qgis_pkg.citydb_building_part_lod2_solid;
CREATE TRIGGER         tr_del_citydb_building_part_lod2_solid
	INSTEAD OF DELETE ON qgis_pkg.citydb_building_part_lod2_solid
	FOR EACH ROW
	EXECUTE PROCEDURE qgis_pkg.tr_del_building();
COMMENT ON TRIGGER tr_del_citydb_building_part_lod2_solid ON qgis_pkg.citydb_building_part_lod2_solid IS 'Fired upon delete on view qgis_pkg.citydb_building_part_lod2_solid';

DROP TRIGGER IF EXISTS tr_ins_citydb_building_part_lod2_solid ON qgis_pkg.citydb_building_part_lod2_solid;
CREATE TRIGGER         tr_ins_citydb_building_part_lod2_solid
	INSTEAD OF INSERT ON qgis_pkg.citydb_building_part_lod2_solid
	FOR EACH ROW
	EXECUTE PROCEDURE qgis_pkg.tr_ins_building();
COMMENT ON TRIGGER tr_ins_citydb_building_part_lod2_solid ON qgis_pkg.citydb_building_part_lod2_solid IS 'Fired upon (blocked) insert into view qgis_pkg.citydb_building_part_lod2_solid';

DROP TRIGGER IF EXISTS tr_upd_citydb_building_part_lod2_solid ON qgis_pkg.citydb_building_part_lod2_solid;
CREATE TRIGGER         tr_upd_citydb_building_part_lod2_solid
	INSTEAD OF UPDATE ON qgis_pkg.citydb_building_part_lod2_solid
	FOR EACH ROW
	EXECUTE PROCEDURE qgis_pkg.tr_upd_building();
COMMENT ON TRIGGER tr_upd_citydb_building_part_lod2_solid ON qgis_pkg.citydb_building_part_lod2_solid IS 'Fired upon update of view qgis_pkg.citydb_building_part_lod2_solid';	


--**************************************************************
--**************************************************************
----------------------------------------------------------------
-- Create TRIGGERS for view QGIS_PKG.CITYDB_BDG_OUTERINSTALLATION_LOD2_MULTISURF
----------------------------------------------------------------
DROP TRIGGER IF EXISTS tr_del_citydb_bdg_outerinstallation_lod2_multisurf ON qgis_pkg.citydb_bdg_outerinstallation_lod2_multisurf;
CREATE TRIGGER         tr_del_citydb_bdg_outerinstallation_lod2_multisurf
	INSTEAD OF DELETE ON qgis_pkg.citydb_bdg_outerinstallation_lod2_multisurf
	FOR EACH ROW
	EXECUTE PROCEDURE qgis_pkg.tr_del_building_installation();
COMMENT ON TRIGGER tr_del_citydb_bdg_outerinstallation_lod2_multisurf ON qgis_pkg.citydb_bdg_outerinstallation_lod2_multisurf IS 'Fired upon delete on view qgis_pkg.citydb_bdg_outerinstallation_lod2_multisurf';

DROP TRIGGER IF EXISTS tr_ins_citydb_bdg_outerinstallation_lod2_multisurf ON qgis_pkg.citydb_bdg_outerinstallation_lod2_multisurf;
CREATE TRIGGER         tr_ins_citydb_bdg_outerinstallation_lod2_multisurf
	INSTEAD OF INSERT ON qgis_pkg.citydb_bdg_outerinstallation_lod2_multisurf
	FOR EACH ROW
	EXECUTE PROCEDURE qgis_pkg.tr_ins_building_installation();
COMMENT ON TRIGGER tr_ins_citydb_bdg_outerinstallation_lod2_multisurf ON qgis_pkg.citydb_bdg_outerinstallation_lod2_multisurf IS 'Fired upon (blocked) insert into view qgis_pkg.citydb_bdg_outerinstallation_lod2_multisurf';

DROP TRIGGER IF EXISTS tr_upd_citydb_bdg_outerinstallation_lod2_multisurf ON qgis_pkg.citydb_bdg_outerinstallation_lod2_multisurf;
CREATE TRIGGER         tr_upd_citydb_bdg_outerinstallation_lod2_multisurf
	INSTEAD OF UPDATE ON qgis_pkg.citydb_bdg_outerinstallation_lod2_multisurf
	FOR EACH ROW
	EXECUTE PROCEDURE qgis_pkg.tr_upd_building_installation();
COMMENT ON TRIGGER tr_upd_citydb_bdg_outerinstallation_lod2_multisurf ON qgis_pkg.citydb_bdg_outerinstallation_lod2_multisurf IS 'Fired upon update of view qgis_pkg.citydb_bdg_outerinstallation_lod2_multisurf';	

--**************************************************************
--**************************************************************
----------------------------------------------------------------
-- Create TRIGGERS for view QGIS_PKG.CITYDB_BDG_GROUNDSURFACE_LOD2_MULTISURF
----------------------------------------------------------------
DROP TRIGGER IF EXISTS tr_del_citydb_bdg_groundsurface_lod2_multisurf ON qgis_pkg.citydb_bdg_groundsurface_lod2_multisurf;
CREATE TRIGGER         tr_del_citydb_bdg_groundsurface_lod2_multisurf
	INSTEAD OF DELETE ON qgis_pkg.citydb_bdg_groundsurface_lod2_multisurf
	FOR EACH ROW
	EXECUTE PROCEDURE qgis_pkg.tr_del_bdg_thematic_surface();
COMMENT ON TRIGGER tr_del_citydb_bdg_groundsurface_lod2_multisurf ON qgis_pkg.citydb_bdg_groundsurface_lod2_multisurf IS 'Fired upon delete on view qgis_pkg.citydb_bdg_groundsurface_lod2_multisurf';

DROP TRIGGER IF EXISTS tr_ins_citydb_building_part_lod2_polyhedralsurf ON qgis_pkg.citydb_bdg_groundsurface_lod2_multisurf;
CREATE TRIGGER         tr_ins_citydb_building_part_lod2_polyhedralsurf
	INSTEAD OF INSERT ON qgis_pkg.citydb_bdg_groundsurface_lod2_multisurf
	FOR EACH ROW
	EXECUTE PROCEDURE qgis_pkg.tr_ins_bdg_thematic_surface();
COMMENT ON TRIGGER tr_ins_citydb_building_part_lod2_polyhedralsurf ON qgis_pkg.citydb_bdg_groundsurface_lod2_multisurf IS 'Fired upon (blocked) insert into view qgis_pkg.citydb_bdg_groundsurface_lod2_multisurf';

DROP TRIGGER IF EXISTS tr_upd_citydb_bdg_groundsurface_lod2_multisurf ON qgis_pkg.citydb_bdg_groundsurface_lod2_multisurf;
CREATE TRIGGER         tr_upd_citydb_bdg_groundsurface_lod2_multisurf
	INSTEAD OF UPDATE ON qgis_pkg.citydb_bdg_groundsurface_lod2_multisurf
	FOR EACH ROW
	EXECUTE PROCEDURE qgis_pkg.tr_upd_bdg_thematic_surface();
COMMENT ON TRIGGER tr_upd_citydb_bdg_groundsurface_lod2_multisurf ON qgis_pkg.citydb_bdg_groundsurface_lod2_multisurf IS 'Fired upon update of view qgis_pkg.citydb_bdg_groundsurface_lod2_multisurf';	

----------------------------------------------------------------
-- Create TRIGGERS for view QGIS_PKG.CITYDB_BDG_WALLSURFACE_LOD2_MULTISURF
----------------------------------------------------------------
DROP TRIGGER IF EXISTS tr_del_citydb_bdg_wallsurface_lod2_multisurf ON qgis_pkg.citydb_bdg_wallsurface_lod2_multisurf;
CREATE TRIGGER         tr_del_citydb_bdg_wallsurface_lod2_multisurf
	INSTEAD OF DELETE ON qgis_pkg.citydb_bdg_wallsurface_lod2_multisurf
	FOR EACH ROW
	EXECUTE PROCEDURE qgis_pkg.tr_del_bdg_thematic_surface();
COMMENT ON TRIGGER tr_del_citydb_bdg_wallsurface_lod2_multisurf ON qgis_pkg.citydb_bdg_wallsurface_lod2_multisurf IS 'Fired upon delete on view qgis_pkg.citydb_bdg_wallsurface_lod2_multisurf';

DROP TRIGGER IF EXISTS tr_ins_citydb_building_part_lod2_polyhedralsurf ON qgis_pkg.citydb_bdg_wallsurface_lod2_multisurf;
CREATE TRIGGER         tr_ins_citydb_building_part_lod2_polyhedralsurf
	INSTEAD OF INSERT ON qgis_pkg.citydb_bdg_wallsurface_lod2_multisurf
	FOR EACH ROW
	EXECUTE PROCEDURE qgis_pkg.tr_ins_bdg_thematic_surface();
COMMENT ON TRIGGER tr_ins_citydb_building_part_lod2_polyhedralsurf ON qgis_pkg.citydb_bdg_wallsurface_lod2_multisurf IS 'Fired upon (blocked) insert into view qgis_pkg.citydb_bdg_wallsurface_lod2_multisurf';

DROP TRIGGER IF EXISTS tr_upd_citydb_bdg_wallsurface_lod2_multisurf ON qgis_pkg.citydb_bdg_wallsurface_lod2_multisurf;
CREATE TRIGGER         tr_upd_citydb_bdg_wallsurface_lod2_multisurf
	INSTEAD OF UPDATE ON qgis_pkg.citydb_bdg_wallsurface_lod2_multisurf
	FOR EACH ROW
	EXECUTE PROCEDURE qgis_pkg.tr_upd_bdg_thematic_surface();
COMMENT ON TRIGGER tr_upd_citydb_bdg_wallsurface_lod2_multisurf ON qgis_pkg.citydb_bdg_wallsurface_lod2_multisurf IS 'Fired upon update of view qgis_pkg.citydb_bdg_wallsurface_lod2_multisurf';	

----------------------------------------------------------------
-- Create TRIGGERS for view QGIS_PKG.CITYDB_BDG_ROOFSURFACE_LOD2_MULTISURF
----------------------------------------------------------------
DROP TRIGGER IF EXISTS tr_del_citydb_bdg_roofsurface_lod2_multisurf ON qgis_pkg.citydb_bdg_roofsurface_lod2_multisurf;
CREATE TRIGGER         tr_del_citydb_bdg_roofsurface_lod2_multisurf
	INSTEAD OF DELETE ON qgis_pkg.citydb_bdg_roofsurface_lod2_multisurf
	FOR EACH ROW
	EXECUTE PROCEDURE qgis_pkg.tr_del_bdg_thematic_surface();
COMMENT ON TRIGGER tr_del_citydb_bdg_roofsurface_lod2_multisurf ON qgis_pkg.citydb_bdg_roofsurface_lod2_multisurf IS 'Fired upon delete on view qgis_pkg.citydb_bdg_roofsurface_lod2_multisurf';

DROP TRIGGER IF EXISTS tr_ins_citydb_building_part_lod2_polyhedralsurf ON qgis_pkg.citydb_bdg_roofsurface_lod2_multisurf;
CREATE TRIGGER         tr_ins_citydb_building_part_lod2_polyhedralsurf
	INSTEAD OF INSERT ON qgis_pkg.citydb_bdg_roofsurface_lod2_multisurf
	FOR EACH ROW
	EXECUTE PROCEDURE qgis_pkg.tr_ins_bdg_thematic_surface();
COMMENT ON TRIGGER tr_ins_citydb_building_part_lod2_polyhedralsurf ON qgis_pkg.citydb_bdg_roofsurface_lod2_multisurf IS 'Fired upon (blocked) insert into view qgis_pkg.citydb_bdg_roofsurface_lod2_multisurf';

DROP TRIGGER IF EXISTS tr_upd_citydb_bdg_roofsurface_lod2_multisurf ON qgis_pkg.citydb_bdg_roofsurface_lod2_multisurf;
CREATE TRIGGER         tr_upd_citydb_bdg_roofsurface_lod2_multisurf
	INSTEAD OF UPDATE ON qgis_pkg.citydb_bdg_roofsurface_lod2_multisurf
	FOR EACH ROW
	EXECUTE PROCEDURE qgis_pkg.tr_upd_bdg_thematic_surface();
COMMENT ON TRIGGER tr_upd_citydb_bdg_roofsurface_lod2_multisurf ON qgis_pkg.citydb_bdg_roofsurface_lod2_multisurf IS 'Fired upon update of view qgis_pkg.citydb_bdg_roofsurface_lod2_multisurf';	

----------------------------------------------------------------
-- Create TRIGGERS for view QGIS_PKG.CITYDB_BDG_CLOSURESURFACE_LOD2_MULTISURF
----------------------------------------------------------------
DROP TRIGGER IF EXISTS tr_del_citydb_bdg_closuresurface_lod2_multisurf ON qgis_pkg.citydb_bdg_closuresurface_lod2_multisurf;
CREATE TRIGGER         tr_del_citydb_bdg_closuresurface_lod2_multisurf
	INSTEAD OF DELETE ON qgis_pkg.citydb_bdg_closuresurface_lod2_multisurf
	FOR EACH ROW
	EXECUTE PROCEDURE qgis_pkg.tr_del_bdg_thematic_surface();
COMMENT ON TRIGGER tr_del_citydb_bdg_closuresurface_lod2_multisurf ON qgis_pkg.citydb_bdg_closuresurface_lod2_multisurf IS 'Fired upon delete on view qgis_pkg.citydb_bdg_closuresurface_lod2_multisurf';

DROP TRIGGER IF EXISTS tr_ins_citydb_building_part_lod2_polyhedralsurf ON qgis_pkg.citydb_bdg_closuresurface_lod2_multisurf;
CREATE TRIGGER         tr_ins_citydb_building_part_lod2_polyhedralsurf
	INSTEAD OF INSERT ON qgis_pkg.citydb_bdg_closuresurface_lod2_multisurf
	FOR EACH ROW
	EXECUTE PROCEDURE qgis_pkg.tr_ins_bdg_thematic_surface();
COMMENT ON TRIGGER tr_ins_citydb_building_part_lod2_polyhedralsurf ON qgis_pkg.citydb_bdg_closuresurface_lod2_multisurf IS 'Fired upon (blocked) insert into view qgis_pkg.citydb_bdg_closuresurface_lod2_multisurf';

DROP TRIGGER IF EXISTS tr_upd_citydb_bdg_closuresurface_lod2_multisurf ON qgis_pkg.citydb_bdg_closuresurface_lod2_multisurf;
CREATE TRIGGER         tr_upd_citydb_bdg_closuresurface_lod2_multisurf
	INSTEAD OF UPDATE ON qgis_pkg.citydb_bdg_closuresurface_lod2_multisurf
	FOR EACH ROW
	EXECUTE PROCEDURE qgis_pkg.tr_upd_bdg_thematic_surface();
COMMENT ON TRIGGER tr_upd_citydb_bdg_closuresurface_lod2_multisurf ON qgis_pkg.citydb_bdg_closuresurface_lod2_multisurf IS 'Fired upon update of view qgis_pkg.citydb_bdg_closuresurface_lod2_multisurf';	

----------------------------------------------------------------
-- Create TRIGGERS for view QGIS_PKG.CITYDB_BDG_OUTERCEILINGSURFACE_LOD2_MULTISURF
----------------------------------------------------------------
DROP TRIGGER IF EXISTS tr_del_citydb_bdg_outerceilingsurface_lod2_multisurf ON qgis_pkg.citydb_bdg_outerceilingsurface_lod2_multisurf;
CREATE TRIGGER         tr_del_citydb_bdg_outerceilingsurface_lod2_multisurf
	INSTEAD OF DELETE ON qgis_pkg.citydb_bdg_outerceilingsurface_lod2_multisurf
	FOR EACH ROW
	EXECUTE PROCEDURE qgis_pkg.tr_del_bdg_thematic_surface();
COMMENT ON TRIGGER tr_del_citydb_bdg_outerceilingsurface_lod2_multisurf ON qgis_pkg.citydb_bdg_outerceilingsurface_lod2_multisurf IS 'Fired upon delete on view qgis_pkg.citydb_bdg_outerceilingsurface_lod2_multisurf';

DROP TRIGGER IF EXISTS tr_ins_citydb_building_part_lod2_polyhedralsurf ON qgis_pkg.citydb_bdg_outerceilingsurface_lod2_multisurf;
CREATE TRIGGER         tr_ins_citydb_building_part_lod2_polyhedralsurf
	INSTEAD OF INSERT ON qgis_pkg.citydb_bdg_outerceilingsurface_lod2_multisurf
	FOR EACH ROW
	EXECUTE PROCEDURE qgis_pkg.tr_ins_bdg_thematic_surface();
COMMENT ON TRIGGER tr_ins_citydb_building_part_lod2_polyhedralsurf ON qgis_pkg.citydb_bdg_outerceilingsurface_lod2_multisurf IS 'Fired upon (blocked) insert into view qgis_pkg.citydb_bdg_outerceilingsurface_lod2_multisurf';

DROP TRIGGER IF EXISTS tr_upd_citydb_bdg_outerceilingsurface_lod2_multisurf ON qgis_pkg.citydb_bdg_outerceilingsurface_lod2_multisurf;
CREATE TRIGGER         tr_upd_citydb_bdg_outerceilingsurface_lod2_multisurf
	INSTEAD OF UPDATE ON qgis_pkg.citydb_bdg_outerceilingsurface_lod2_multisurf
	FOR EACH ROW
	EXECUTE PROCEDURE qgis_pkg.tr_upd_bdg_thematic_surface();
COMMENT ON TRIGGER tr_upd_citydb_bdg_outerceilingsurface_lod2_multisurf ON qgis_pkg.citydb_bdg_outerceilingsurface_lod2_multisurf IS 'Fired upon update of view qgis_pkg.citydb_bdg_outerceilingsurface_lod2_multisurf';	

----------------------------------------------------------------
-- Create TRIGGERS for view QGIS_PKG.CITYDB_BDG_OUTERFLOORSURFACE_LOD2_MULTISURF
----------------------------------------------------------------
DROP TRIGGER IF EXISTS tr_del_citydb_bdg_outerfloorsurface_lod2_multisurf ON qgis_pkg.citydb_bdg_outerfloorsurface_lod2_multisurf;
CREATE TRIGGER         tr_del_citydb_bdg_outerfloorsurface_lod2_multisurf
	INSTEAD OF DELETE ON qgis_pkg.citydb_bdg_outerfloorsurface_lod2_multisurf
	FOR EACH ROW
	EXECUTE PROCEDURE qgis_pkg.tr_del_bdg_thematic_surface();
COMMENT ON TRIGGER tr_del_citydb_bdg_outerfloorsurface_lod2_multisurf ON qgis_pkg.citydb_bdg_outerfloorsurface_lod2_multisurf IS 'Fired upon delete on view qgis_pkg.citydb_bdg_outerfloorsurface_lod2_multisurf';

DROP TRIGGER IF EXISTS tr_ins_citydb_building_part_lod2_polyhedralsurf ON qgis_pkg.citydb_bdg_outerfloorsurface_lod2_multisurf;
CREATE TRIGGER         tr_ins_citydb_building_part_lod2_polyhedralsurf
	INSTEAD OF INSERT ON qgis_pkg.citydb_bdg_outerfloorsurface_lod2_multisurf
	FOR EACH ROW
	EXECUTE PROCEDURE qgis_pkg.tr_ins_bdg_thematic_surface();
COMMENT ON TRIGGER tr_ins_citydb_building_part_lod2_polyhedralsurf ON qgis_pkg.citydb_bdg_outerfloorsurface_lod2_multisurf IS 'Fired upon (blocked) insert into view qgis_pkg.citydb_bdg_outerfloorsurface_lod2_multisurf';

DROP TRIGGER IF EXISTS tr_upd_citydb_bdg_outerfloorsurface_lod2_multisurf ON qgis_pkg.citydb_bdg_outerfloorsurface_lod2_multisurf;
CREATE TRIGGER         tr_upd_citydb_bdg_outerfloorsurface_lod2_multisurf
	INSTEAD OF UPDATE ON qgis_pkg.citydb_bdg_outerfloorsurface_lod2_multisurf
	FOR EACH ROW
	EXECUTE PROCEDURE qgis_pkg.tr_upd_bdg_thematic_surface();
COMMENT ON TRIGGER tr_upd_citydb_bdg_outerfloorsurface_lod2_multisurf ON qgis_pkg.citydb_bdg_outerfloorsurface_lod2_multisurf IS 'Fired upon update of view qgis_pkg.citydb_bdg_outerfloorsurface_lod2_multisurf';	


--**************************************************************
--**************************************************************
----------------------------------------------------------------
-- Create TRIGGERS for view QGIS_PKG.CITYDB_SOLITARY_VEGETAT_OBJECT_LOD1_IMPLICITREP
----------------------------------------------------------------
DROP TRIGGER IF EXISTS tr_del_citydb_solitary_vegetat_object_lod1_implicitrep ON qgis_pkg.citydb_solitary_vegetat_object_lod1_implicitrep;
CREATE TRIGGER         tr_del_citydb_solitary_vegetat_object_lod1_implicitrep
	INSTEAD OF DELETE ON qgis_pkg.citydb_solitary_vegetat_object_lod1_implicitrep
	FOR EACH ROW
	EXECUTE PROCEDURE qgis_pkg.tr_del_solitary_vegetat_object();
COMMENT ON TRIGGER tr_del_citydb_solitary_vegetat_object_lod1_implicitrep ON qgis_pkg.citydb_solitary_vegetat_object_lod1_implicitrep IS 'Fired upon delete on view qgis_pkg.citydb_solitary_vegetat_object_lod1_implicitrep';

DROP TRIGGER IF EXISTS tr_ins_citydb_building_part_lod2_polyhedralsurf ON qgis_pkg.citydb_solitary_vegetat_object_lod1_implicitrep;
CREATE TRIGGER         tr_ins_citydb_building_part_lod2_polyhedralsurf
	INSTEAD OF INSERT ON qgis_pkg.citydb_solitary_vegetat_object_lod1_implicitrep
	FOR EACH ROW
	EXECUTE PROCEDURE qgis_pkg.tr_ins_solitary_vegetat_object();
COMMENT ON TRIGGER tr_ins_citydb_building_part_lod2_polyhedralsurf ON qgis_pkg.citydb_solitary_vegetat_object_lod1_implicitrep IS 'Fired upon (blocked) insert into view qgis_pkg.citydb_solitary_vegetat_object_lod1_implicitrep';

DROP TRIGGER IF EXISTS tr_upd_citydb_solitary_vegetat_object_lod1_implicitrep ON qgis_pkg.citydb_solitary_vegetat_object_lod1_implicitrep;
CREATE TRIGGER         tr_upd_citydb_solitary_vegetat_object_lod1_implicitrep
	INSTEAD OF UPDATE ON qgis_pkg.citydb_solitary_vegetat_object_lod1_implicitrep
	FOR EACH ROW
	EXECUTE PROCEDURE qgis_pkg.tr_upd_solitary_vegetat_object();
COMMENT ON TRIGGER tr_upd_citydb_solitary_vegetat_object_lod1_implicitrep ON qgis_pkg.citydb_solitary_vegetat_object_lod1_implicitrep IS 'Fired upon update of view qgis_pkg.citydb_solitary_vegetat_object_lod1_implicitrep';	

----------------------------------------------------------------
-- Create TRIGGERS for view QGIS_PKG.CITYDB_SOLITARY_VEGETAT_OBJECT_LOD2_IMPLICITREP
----------------------------------------------------------------
DROP TRIGGER IF EXISTS tr_del_citydb_solitary_vegetat_object_lod2_implicitrep ON qgis_pkg.citydb_solitary_vegetat_object_lod2_implicitrep;
CREATE TRIGGER         tr_del_citydb_solitary_vegetat_object_lod2_implicitrep
	INSTEAD OF DELETE ON qgis_pkg.citydb_solitary_vegetat_object_lod2_implicitrep
	FOR EACH ROW
	EXECUTE PROCEDURE qgis_pkg.tr_del_solitary_vegetat_object();
COMMENT ON TRIGGER tr_del_citydb_solitary_vegetat_object_lod2_implicitrep ON qgis_pkg.citydb_solitary_vegetat_object_lod2_implicitrep IS 'Fired upon delete on view qgis_pkg.citydb_solitary_vegetat_object_lod2_implicitrep';

DROP TRIGGER IF EXISTS tr_ins_citydb_building_part_lod2_polyhedralsurf ON qgis_pkg.citydb_solitary_vegetat_object_lod2_implicitrep;
CREATE TRIGGER         tr_ins_citydb_building_part_lod2_polyhedralsurf
	INSTEAD OF INSERT ON qgis_pkg.citydb_solitary_vegetat_object_lod2_implicitrep
	FOR EACH ROW
	EXECUTE PROCEDURE qgis_pkg.tr_ins_solitary_vegetat_object();
COMMENT ON TRIGGER tr_ins_citydb_building_part_lod2_polyhedralsurf ON qgis_pkg.citydb_solitary_vegetat_object_lod2_implicitrep IS 'Fired upon (blocked) insert into view qgis_pkg.citydb_solitary_vegetat_object_lod2_implicitrep';

DROP TRIGGER IF EXISTS tr_upd_citydb_solitary_vegetat_object_lod2_implicitrep ON qgis_pkg.citydb_solitary_vegetat_object_lod2_implicitrep;
CREATE TRIGGER         tr_upd_citydb_solitary_vegetat_object_lod2_implicitrep
	INSTEAD OF UPDATE ON qgis_pkg.citydb_solitary_vegetat_object_lod2_implicitrep
	FOR EACH ROW
	EXECUTE PROCEDURE qgis_pkg.tr_upd_solitary_vegetat_object();
COMMENT ON TRIGGER tr_upd_citydb_solitary_vegetat_object_lod2_implicitrep ON qgis_pkg.citydb_solitary_vegetat_object_lod2_implicitrep IS 'Fired upon update of view qgis_pkg.citydb_solitary_vegetat_object_lod2_implicitrep';	

----------------------------------------------------------------
-- Create TRIGGERS for view QGIS_PKG.CITYDB_SOLITARY_VEGETAT_OBJECT_LOD3_IMPLICITREP
----------------------------------------------------------------
DROP TRIGGER IF EXISTS tr_del_citydb_solitary_vegetat_object_lod3_implicitrep ON qgis_pkg.citydb_solitary_vegetat_object_lod3_implicitrep;
CREATE TRIGGER         tr_del_citydb_solitary_vegetat_object_lod3_implicitrep
	INSTEAD OF DELETE ON qgis_pkg.citydb_solitary_vegetat_object_lod3_implicitrep
	FOR EACH ROW
	EXECUTE PROCEDURE qgis_pkg.tr_del_solitary_vegetat_object();
COMMENT ON TRIGGER tr_del_citydb_solitary_vegetat_object_lod3_implicitrep ON qgis_pkg.citydb_solitary_vegetat_object_lod3_implicitrep IS 'Fired upon delete on view qgis_pkg.citydb_solitary_vegetat_object_lod3_implicitrep';

DROP TRIGGER IF EXISTS tr_ins_citydb_building_part_lod3_polyhedralsurf ON qgis_pkg.citydb_solitary_vegetat_object_lod3_implicitrep;
CREATE TRIGGER         tr_ins_citydb_building_part_lod3_polyhedralsurf
	INSTEAD OF INSERT ON qgis_pkg.citydb_solitary_vegetat_object_lod3_implicitrep
	FOR EACH ROW
	EXECUTE PROCEDURE qgis_pkg.tr_ins_solitary_vegetat_object();
COMMENT ON TRIGGER tr_ins_citydb_building_part_lod3_polyhedralsurf ON qgis_pkg.citydb_solitary_vegetat_object_lod3_implicitrep IS 'Fired upon (blocked) insert into view qgis_pkg.citydb_solitary_vegetat_object_lod3_implicitrep';

DROP TRIGGER IF EXISTS tr_upd_citydb_solitary_vegetat_object_lod3_implicitrep ON qgis_pkg.citydb_solitary_vegetat_object_lod3_implicitrep;
CREATE TRIGGER         tr_upd_citydb_solitary_vegetat_object_lod3_implicitrep
	INSTEAD OF UPDATE ON qgis_pkg.citydb_solitary_vegetat_object_lod3_implicitrep
	FOR EACH ROW
	EXECUTE PROCEDURE qgis_pkg.tr_upd_solitary_vegetat_object();
COMMENT ON TRIGGER tr_upd_citydb_solitary_vegetat_object_lod3_implicitrep ON qgis_pkg.citydb_solitary_vegetat_object_lod3_implicitrep IS 'Fired upon update of view qgis_pkg.citydb_solitary_vegetat_object_lod3_implicitrep';	

----------------------------------------------------------------
-- Create TRIGGERS for view QGIS_PKG.CITYDB_SOLITARY_VEGETAT_OBJECT_LOD2_MULTISURF
----------------------------------------------------------------
DROP TRIGGER IF EXISTS tr_del_citydb_solitary_vegetat_object_lod2_multisurf ON qgis_pkg.citydb_solitary_vegetat_object_lod2_multisurf;
CREATE TRIGGER         tr_del_citydb_solitary_vegetat_object_lod2_multisurf
	INSTEAD OF DELETE ON qgis_pkg.citydb_solitary_vegetat_object_lod2_multisurf
	FOR EACH ROW
	EXECUTE PROCEDURE qgis_pkg.tr_del_solitary_vegetat_object();
COMMENT ON TRIGGER tr_del_citydb_solitary_vegetat_object_lod2_multisurf ON qgis_pkg.citydb_solitary_vegetat_object_lod2_multisurf IS 'Fired upon delete on view qgis_pkg.citydb_solitary_vegetat_object_lod2_multisurf';

DROP TRIGGER IF EXISTS tr_ins_citydb_building_part_lod2_polyhedralsurf ON qgis_pkg.citydb_solitary_vegetat_object_lod2_multisurf;
CREATE TRIGGER         tr_ins_citydb_building_part_lod2_polyhedralsurf
	INSTEAD OF INSERT ON qgis_pkg.citydb_solitary_vegetat_object_lod2_multisurf
	FOR EACH ROW
	EXECUTE PROCEDURE qgis_pkg.tr_ins_solitary_vegetat_object();
COMMENT ON TRIGGER tr_ins_citydb_building_part_lod2_polyhedralsurf ON qgis_pkg.citydb_solitary_vegetat_object_lod2_multisurf IS 'Fired upon (blocked) insert into view qgis_pkg.citydb_solitary_vegetat_object_lod2_multisurf';

DROP TRIGGER IF EXISTS tr_upd_citydb_solitary_vegetat_object_lod2_multisurf ON qgis_pkg.citydb_solitary_vegetat_object_lod2_multisurf;
CREATE TRIGGER         tr_upd_citydb_solitary_vegetat_object_lod2_multisurf
	INSTEAD OF UPDATE ON qgis_pkg.citydb_solitary_vegetat_object_lod2_multisurf
	FOR EACH ROW
	EXECUTE PROCEDURE qgis_pkg.tr_upd_solitary_vegetat_object();
COMMENT ON TRIGGER tr_upd_citydb_solitary_vegetat_object_lod2_multisurf ON qgis_pkg.citydb_solitary_vegetat_object_lod2_multisurf IS 'Fired upon update of view qgis_pkg.citydb_solitary_vegetat_object_lod2_multisurf';	


--**************************************************************
--**************************************************************
----------------------------------------------------------------
-- Create TRIGGERS for view QGIS_PKG.CITYDB_RELIEF_FEATURE_LOD1_POLYGON
----------------------------------------------------------------
DROP TRIGGER IF EXISTS tr_del_citydb_relief_feature_lod1_polygon ON qgis_pkg.citydb_relief_feature_lod1_polygon;
CREATE TRIGGER         tr_del_citydb_relief_feature_lod1_polygon
	INSTEAD OF DELETE ON qgis_pkg.citydb_relief_feature_lod1_polygon
	FOR EACH ROW
	EXECUTE PROCEDURE qgis_pkg.tr_del_relief_feature();
COMMENT ON TRIGGER tr_del_citydb_relief_feature_lod1_polygon ON qgis_pkg.citydb_relief_feature_lod1_polygon IS 'Fired upon delete on view qgis_pkg.citydb_relief_feature_lod1_polygon';

DROP TRIGGER IF EXISTS tr_ins_citydb_building_part_lod2_polyhedralsurf ON qgis_pkg.citydb_relief_feature_lod1_polygon;
CREATE TRIGGER         tr_ins_citydb_building_part_lod2_polyhedralsurf
	INSTEAD OF INSERT ON qgis_pkg.citydb_relief_feature_lod1_polygon
	FOR EACH ROW
	EXECUTE PROCEDURE qgis_pkg.tr_ins_relief_feature();
COMMENT ON TRIGGER tr_ins_citydb_building_part_lod2_polyhedralsurf ON qgis_pkg.citydb_relief_feature_lod1_polygon IS 'Fired upon (blocked) insert into view qgis_pkg.citydb_relief_feature_lod1_polygon';

DROP TRIGGER IF EXISTS tr_upd_citydb_relief_feature_lod1_polygon ON qgis_pkg.citydb_relief_feature_lod1_polygon;
CREATE TRIGGER         tr_upd_citydb_relief_feature_lod1_polygon
	INSTEAD OF UPDATE ON qgis_pkg.citydb_relief_feature_lod1_polygon
	FOR EACH ROW
	EXECUTE PROCEDURE qgis_pkg.tr_upd_relief_feature();
COMMENT ON TRIGGER tr_upd_citydb_relief_feature_lod1_polygon ON qgis_pkg.citydb_relief_feature_lod1_polygon IS 'Fired upon update of view qgis_pkg.citydb_relief_feature_lod1_polygon';	

----------------------------------------------------------------
-- Create TRIGGERS for view QGIS_PKG.CITYDB_RELIEF_FEATURE_LOD2_POLYGON
----------------------------------------------------------------
DROP TRIGGER IF EXISTS tr_del_citydb_relief_feature_lod2_polygon ON qgis_pkg.citydb_relief_feature_lod2_polygon;
CREATE TRIGGER         tr_del_citydb_relief_feature_lod2_polygon
	INSTEAD OF DELETE ON qgis_pkg.citydb_relief_feature_lod2_polygon
	FOR EACH ROW
	EXECUTE PROCEDURE qgis_pkg.tr_del_relief_feature();
COMMENT ON TRIGGER tr_del_citydb_relief_feature_lod2_polygon ON qgis_pkg.citydb_relief_feature_lod2_polygon IS 'Fired upon delete on view qgis_pkg.citydb_relief_feature_lod2_polygon';

DROP TRIGGER IF EXISTS tr_ins_citydb_building_part_lod2_polyhedralsurf ON qgis_pkg.citydb_relief_feature_lod2_polygon;
CREATE TRIGGER         tr_ins_citydb_building_part_lod2_polyhedralsurf
	INSTEAD OF INSERT ON qgis_pkg.citydb_relief_feature_lod2_polygon
	FOR EACH ROW
	EXECUTE PROCEDURE qgis_pkg.tr_ins_relief_feature();
COMMENT ON TRIGGER tr_ins_citydb_building_part_lod2_polyhedralsurf ON qgis_pkg.citydb_relief_feature_lod2_polygon IS 'Fired upon (blocked) insert into view qgis_pkg.citydb_relief_feature_lod2_polygon';

DROP TRIGGER IF EXISTS tr_upd_citydb_relief_feature_lod2_polygon ON qgis_pkg.citydb_relief_feature_lod2_polygon;
CREATE TRIGGER         tr_upd_citydb_relief_feature_lod2_polygon
	INSTEAD OF UPDATE ON qgis_pkg.citydb_relief_feature_lod2_polygon
	FOR EACH ROW
	EXECUTE PROCEDURE qgis_pkg.tr_upd_relief_feature();
COMMENT ON TRIGGER tr_upd_citydb_relief_feature_lod2_polygon ON qgis_pkg.citydb_relief_feature_lod2_polygon IS 'Fired upon update of view qgis_pkg.citydb_relief_feature_lod2_polygon';	



--**************************************************************
--**************************************************************
----------------------------------------------------------------
-- Create TRIGGERS for view QGIS_PKG.CITYDB_TIN_RELIEF_LOD1_TIN
----------------------------------------------------------------
DROP TRIGGER IF EXISTS tr_del_citydb_tin_relief_lod1_tin ON qgis_pkg.citydb_tin_relief_lod1_tin;
CREATE TRIGGER         tr_del_citydb_tin_relief_lod1_tin
	INSTEAD OF DELETE ON qgis_pkg.citydb_tin_relief_lod1_tin
	FOR EACH ROW
	EXECUTE PROCEDURE qgis_pkg.tr_del_tin_relief();
COMMENT ON TRIGGER tr_del_citydb_tin_relief_lod1_tin ON qgis_pkg.citydb_tin_relief_lod1_tin IS 'Fired upon delete on view qgis_pkg.citydb_tin_relief_lod1_tin';

DROP TRIGGER IF EXISTS tr_ins_citydb_building_part_lod2_polyhedralsurf ON qgis_pkg.citydb_tin_relief_lod1_tin;
CREATE TRIGGER         tr_ins_citydb_building_part_lod2_polyhedralsurf
	INSTEAD OF INSERT ON qgis_pkg.citydb_tin_relief_lod1_tin
	FOR EACH ROW
	EXECUTE PROCEDURE qgis_pkg.tr_ins_tin_relief();
COMMENT ON TRIGGER tr_ins_citydb_building_part_lod2_polyhedralsurf ON qgis_pkg.citydb_tin_relief_lod1_tin IS 'Fired upon (blocked) insert into view qgis_pkg.citydb_tin_relief_lod1_tin';

DROP TRIGGER IF EXISTS tr_upd_citydb_tin_relief_lod1_tin ON qgis_pkg.citydb_tin_relief_lod1_tin;
CREATE TRIGGER         tr_upd_citydb_tin_relief_lod1_tin
	INSTEAD OF UPDATE ON qgis_pkg.citydb_tin_relief_lod1_tin
	FOR EACH ROW
	EXECUTE PROCEDURE qgis_pkg.tr_upd_tin_relief();
COMMENT ON TRIGGER tr_upd_citydb_tin_relief_lod1_tin ON qgis_pkg.citydb_tin_relief_lod1_tin IS 'Fired upon update of view qgis_pkg.citydb_tin_relief_lod1_tin';	

----------------------------------------------------------------
-- Create TRIGGERS for view QGIS_PKG.CITYDB_TIN_RELIEF_LOD2_TIN
----------------------------------------------------------------
DROP TRIGGER IF EXISTS tr_del_citydb_tin_relief_lod2_tin ON qgis_pkg.citydb_tin_relief_lod2_tin;
CREATE TRIGGER         tr_del_citydb_tin_relief_lod2_tin
	INSTEAD OF DELETE ON qgis_pkg.citydb_tin_relief_lod2_tin
	FOR EACH ROW
	EXECUTE PROCEDURE qgis_pkg.tr_del_tin_relief();
COMMENT ON TRIGGER tr_del_citydb_tin_relief_lod2_tin ON qgis_pkg.citydb_tin_relief_lod2_tin IS 'Fired upon delete on view qgis_pkg.citydb_tin_relief_lod2_tin';

DROP TRIGGER IF EXISTS tr_ins_citydb_building_part_lod2_polyhedralsurf ON qgis_pkg.citydb_tin_relief_lod2_tin;
CREATE TRIGGER         tr_ins_citydb_building_part_lod2_polyhedralsurf
	INSTEAD OF INSERT ON qgis_pkg.citydb_tin_relief_lod2_tin
	FOR EACH ROW
	EXECUTE PROCEDURE qgis_pkg.tr_ins_tin_relief();
COMMENT ON TRIGGER tr_ins_citydb_building_part_lod2_polyhedralsurf ON qgis_pkg.citydb_tin_relief_lod2_tin IS 'Fired upon (blocked) insert into view qgis_pkg.citydb_tin_relief_lod2_tin';

DROP TRIGGER IF EXISTS tr_upd_citydb_tin_relief_lod2_tin ON qgis_pkg.citydb_tin_relief_lod2_tin;
CREATE TRIGGER         tr_upd_citydb_tin_relief_lod2_tin
	INSTEAD OF UPDATE ON qgis_pkg.citydb_tin_relief_lod2_tin
	FOR EACH ROW
	EXECUTE PROCEDURE qgis_pkg.tr_upd_tin_relief();
COMMENT ON TRIGGER tr_upd_citydb_tin_relief_lod2_tin ON qgis_pkg.citydb_tin_relief_lod2_tin IS 'Fired upon update of view qgis_pkg.citydb_tin_relief_lod2_tin';	


--**************************
DO $$
BEGIN
RAISE NOTICE 'Done';
END $$;
--**************************


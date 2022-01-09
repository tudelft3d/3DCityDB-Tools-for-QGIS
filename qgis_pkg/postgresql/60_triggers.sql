-- ****************************************************************************
-- ****************************************************************************
--
--
-- TABLE UPDATE FUNCTIONs
--
--
-- ****************************************************************************
-- ****************************************************************************

----------------------------------------------------------------
-- Create FUNCTION QGIS_PKG.UPD_BUILDING_ATTS
----------------------------------------------------------------
DROP FUNCTION IF EXISTS    qgis_pkg.upd_building_atts(qgis_pkg.obj_cityobject, qgis_pkg.obj_building, varchar) CASCADE;
CREATE OR REPLACE FUNCTION qgis_pkg.upd_building_atts(
obj_co      qgis_pkg.obj_cityobject,
obj_b       qgis_pkg.obj_building,
schema_name varchar DEFAULT 'citydb'::varchar 
)
RETURNS bigint AS $$
DECLARE
  updated_id bigint;
BEGIN
UPDATE citydb.cityobject AS t1 SET
  gmlid                       = obj_co.gmlid,
  gmlid_codespace             = obj_co.gmlid_codespace,
  name                        = obj_co.name,
  name_codespace              = obj_co.name_codespace,
  description                 = obj_co.description,
  -- envelope                    = obj_co.envelope,
  creation_date               = obj_co.creation_date,
  termination_date            = obj_co.termination_date,
  relative_to_terrain         = obj_co.relative_to_terrain,
  relative_to_water           = obj_co.relative_to_water,
  last_modification_date      = obj_co.last_modification_date,
  updating_person             = obj_co.updating_person,
  reason_for_update           = obj_co.reason_for_update,
  lineage                     = obj_co.lineage
  WHERE t1.id = obj_co.id RETURNING id INTO updated_id;

UPDATE citydb.building AS t2 SET
  class                       = obj_b.class,
  class_codespace             = obj_b.class_codespace,
  function                    = obj_b.function,
  function_codespace          = obj_b.function_codespace,
  usage                       = obj_b.usage,
  usage_codespace             = obj_b.usage_codespace,
  year_of_construction        = obj_b.year_of_construction,
  year_of_demolition          = obj_b.year_of_demolition,
  roof_type                   = obj_b.roof_type,
  roof_type_codespace         = obj_b.roof_type_codespace,
  measured_height             = obj_b.measured_height,
  measured_height_unit        = obj_b.measured_height_unit,
  storeys_above_ground        = obj_b.storeys_above_ground,
  storeys_below_ground        = obj_b.storeys_below_ground,
  storey_heights_above_ground = obj_b.storey_heights_above_ground,
  storey_heights_ag_unit      = obj_b.storey_heights_ag_unit,
  storey_heights_below_ground = obj_b.storey_heights_below_ground,
  storey_heights_bg_unit      = obj_b.storey_heights_bg_unit
  WHERE t2.id = updated_id;

RETURN updated_id;
EXCEPTION
  WHEN OTHERS THEN RAISE NOTICE 'qgis_pkg.upd_building_atts(id: %): %', obj_co.gmlid, SQLERRM;
END;
$$ LANGUAGE plpgsql;
COMMENT ON FUNCTION qgis_pkg.upd_building_atts(qgis_pkg.obj_cityobject, qgis_pkg.obj_building, varchar) IS 'Update attributes of Building/BuildingPart';

----------------------------------------------------------------
-- Create FUNCTION QGIS_PKG.UPD_BUILDING_INSTALLATION_ATTS
----------------------------------------------------------------
DROP FUNCTION IF EXISTS    qgis_pkg.upd_building_installation_atts(qgis_pkg.obj_cityobject, qgis_pkg.obj_building_installation, varchar) CASCADE;
CREATE OR REPLACE FUNCTION qgis_pkg.upd_building_installation_atts(
obj_co      qgis_pkg.obj_cityobject,
obj_bi      qgis_pkg.obj_building_installation,
schema_name varchar DEFAULT 'citydb'::varchar
)
RETURNS bigint AS $$
DECLARE
  updated_id bigint;
BEGIN

UPDATE citydb.cityobject AS t1 SET
  gmlid                       = obj_co.gmlid,
  gmlid_codespace             = obj_co.gmlid_codespace,
  name                        = obj_co.name,
  name_codespace              = obj_co.name_codespace,
  description                 = obj_co.description,
  -- envelope                    = obj_co.envelope,
  creation_date               = obj_co.creation_date,
  termination_date            = obj_co.termination_date,
  relative_to_terrain         = obj_co.relative_to_terrain,
  relative_to_water           = obj_co.relative_to_water,
  last_modification_date      = obj_co.last_modification_date,
  updating_person             = obj_co.updating_person,
  reason_for_update           = obj_co.reason_for_update,
  lineage                     = obj_co.lineage
  WHERE t1.id = obj_co.id RETURNING id INTO updated_id;

UPDATE citydb.building_installation AS t2 SET
  class                       = obj_bi.class,
  class_codespace             = obj_bi.class_codespace,
  function                    = obj_bi.function,
  function_codespace          = obj_bi.function_codespace,
  usage                       = obj_bi.usage,
  usage_codespace             = obj_bi.usage_codespace
  WHERE t2.id = updated_id;

RETURN updated_id;
EXCEPTION
  WHEN OTHERS THEN RAISE NOTICE 'qgis_pkg.upd_building_installation_atts(id: %): %', obj_co.gmlid, SQLERRM;
END;
$$ LANGUAGE plpgsql;
COMMENT ON FUNCTION qgis_pkg.upd_building_installation_atts(qgis_pkg.obj_cityobject, qgis_pkg.obj_building_installation, varchar) IS 'Update attributes of (Inner/Outer) BuildingInstallation';

----------------------------------------------------------------
-- Create FUNCTION QGIS_PKG.UPD_THEMATIC_SURFACE_ATTS
----------------------------------------------------------------
DROP FUNCTION IF EXISTS    qgis_pkg.upd_thematic_surface_atts(qgis_pkg.obj_cityobject, varchar) CASCADE;
CREATE OR REPLACE FUNCTION qgis_pkg.upd_thematic_surface_atts(
obj_co      qgis_pkg.obj_cityobject,
schema_name varchar DEFAULT 'citydb'::varchar
)
RETURNS bigint AS $$
DECLARE
  updated_id bigint;
BEGIN

UPDATE citydb.cityobject AS t1 SET
  gmlid                       = obj_co.gmlid,
  gmlid_codespace             = obj_co.gmlid_codespace,
  name                        = obj_co.name,
  name_codespace              = obj_co.name_codespace,
  description                 = obj_co.description,
  -- envelope                    = obj_co.envelope,
  creation_date               = obj_co.creation_date,
  termination_date            = obj_co.termination_date,
  relative_to_terrain         = obj_co.relative_to_terrain,
  relative_to_water           = obj_co.relative_to_water,
  last_modification_date      = obj_co.last_modification_date,
  updating_person             = obj_co.updating_person,
  reason_for_update           = obj_co.reason_for_update,
  lineage                     = obj_co.lineage
  WHERE t1.id = obj_co.id RETURNING id INTO updated_id;

RETURN updated_id;
EXCEPTION
  WHEN OTHERS THEN RAISE NOTICE 'qgis_pkg.upd_thematic_surface_atts(id: %): %', obj_co.gmlid, SQLERRM;
END;
$$ LANGUAGE plpgsql;
COMMENT ON FUNCTION qgis_pkg.upd_thematic_surface_atts(qgis_pkg.obj_cityobject, varchar) IS 'Update attributes of a (Building) ThematicSurface';




-- ****************************************************************************
-- ****************************************************************************
--
--
-- TRIGGER FUNCTIONs
--
--
-- ****************************************************************************
-- ****************************************************************************

----------------------------------------------------------------
-- Create trigger FUNCTION QGIS_PKG.TR_UPD_CITYDB_BUILDING_ATTS
----------------------------------------------------------------
DROP FUNCTION IF EXISTS    qgis_pkg.tr_upd_citydb_building_atts CASCADE;
CREATE OR REPLACE FUNCTION qgis_pkg.tr_upd_citydb_building_atts()
RETURNS trigger AS $$
DECLARE
  obj_co      qgis_pkg.obj_cityobject;
  obj_b       qgis_pkg.obj_building;
  schema_name varchar := 'citydb';  

BEGIN
obj_co.id                          = OLD.id;
obj_co.gmlid                       = NEW.gmlid;
obj_co.gmlid_codespace             = NEW.gmlid_codespace;
obj_co.name                        = NEW.name;
obj_co.name_codespace              = NEW.name_codespace;
obj_co.description                 = NEW.description;
--obj_co.envelope                    = NEW.envelope;
obj_co.creation_date               = NEW.creation_date;
obj_co.termination_date            = NEW.termination_date;
obj_co.relative_to_terrain         = NEW.relative_to_terrain;
obj_co.relative_to_water           = NEW.relative_to_water;
obj_co.last_modification_date      = NEW.last_modification_date;
obj_co.updating_person             = NEW.updating_person;
obj_co.reason_for_update           = NEW.reason_for_update;
obj_co.lineage                     = NEW.lineage;

obj_b.class                       = NEW.class;
obj_b.class_codespace             = NEW.class_codespace;
obj_b.function                    = array_to_string((SELECT array_agg(DISTINCT x) FROM unnest(NEW.function) AS t(x)), '--/\--');
obj_b.function_codespace          = array_to_string((SELECT array_agg(DISTINCT x) FROM unnest(NEW.function_codespace) AS t(x)), '--/\--');
obj_b.usage                       = array_to_string((SELECT array_agg(DISTINCT x) FROM unnest(NEW.usage) AS t(x)), '--/\--');
obj_b.usage_codespace             = array_to_string((SELECT array_agg(DISTINCT x) FROM unnest(NEW.usage_codespace) AS t(x)), '--/\--');
obj_b.year_of_construction        = NEW.year_of_construction;
obj_b.year_of_demolition          = NEW.year_of_demolition;
obj_b.roof_type                   = NEW.roof_type;
obj_b.roof_type_codespace         = NEW.roof_type_codespace;
obj_b.measured_height             = NEW.measured_height;
obj_b.measured_height_unit        = NEW.measured_height_unit;
obj_b.storeys_above_ground        = NEW.storeys_above_ground;
obj_b.storeys_below_ground        = NEW.storeys_below_ground;
obj_b.storey_heights_above_ground = NEW.storey_heights_above_ground;
obj_b.storey_heights_ag_unit      = NEW.storey_heights_ag_unit;
obj_b.storey_heights_below_ground = NEW.storey_heights_below_ground;
obj_b.storey_heights_bg_unit      = NEW.storey_heights_bg_unit;

PERFORM qgis_pkg.upd_building_atts(obj_co, obj_b, schema_name);

RETURN NEW;
EXCEPTION
  WHEN OTHERS THEN RAISE NOTICE 'qgis_pkg.tr_upd_building_atts(id: %): %', OLD.id, SQLERRM;
END;
$$ LANGUAGE plpgsql;
COMMENT ON FUNCTION qgis_pkg.tr_upd_citydb_building_atts IS 'Update record in view building_*';

----------------------------------------------------------------
-- Create trigger FUNCTION QGIS_PKG.TR_INS_CITYDB_BUILDING
----------------------------------------------------------------
DROP FUNCTION IF EXISTS    qgis_pkg.tr_ins_citydb_building CASCADE;
CREATE OR REPLACE FUNCTION qgis_pkg.tr_ins_citydb_building()
RETURNS trigger AS $$
DECLARE
BEGIN
RAISE EXCEPTION 'You are not allowed to insert new records using the QGIS plugin';
EXCEPTION
  WHEN OTHERS THEN RAISE NOTICE 'qgis_pkg.tr_ins_citydb_building(): %', SQLERRM;
END;
$$ LANGUAGE plpgsql;
COMMENT ON FUNCTION qgis_pkg.tr_ins_citydb_building IS '(Block) insert record in view citydb_building_*';

----------------------------------------------------------------
-- Create trigger FUNCTION QGIS_PKG.TR_DEL_BUILDING
----------------------------------------------------------------
DROP FUNCTION IF EXISTS    qgis_pkg.tr_del_citydb_building CASCADE;
CREATE OR REPLACE FUNCTION qgis_pkg.tr_del_citydb_building()
RETURNS trigger AS $$
DECLARE
BEGIN
PERFORM citydb.del_building(OLD.id);
RETURN OLD;
EXCEPTION
  WHEN OTHERS THEN RAISE NOTICE 'qgis_pkg.tr_del_citydb_building(id: %): %', OLD.id, SQLERRM;
END;
$$ LANGUAGE plpgsql;
COMMENT ON FUNCTION qgis_pkg.tr_del_citydb_building IS 'Delete record in view citydb_building_*';


--**************************************************************
--**************************************************************
----------------------------------------------------------------
-- Create trigger FUNCTION QGIS_PKG.TR_UPD_CITYDB_BUILDING_INSTALLATION_ATTS
----------------------------------------------------------------
DROP FUNCTION IF EXISTS    qgis_pkg.tr_upd_citydb_building_installation_atts CASCADE;
CREATE OR REPLACE FUNCTION qgis_pkg.tr_upd_citydb_building_installation_atts()
RETURNS trigger AS $$
DECLARE
  obj_co      qgis_pkg.obj_cityobject;
  obj_bi      qgis_pkg.obj_building_installation;
  schema_name varchar := 'citydb';  

BEGIN
obj_co.id                          = OLD.id;
obj_co.gmlid                       = NEW.gmlid;
obj_co.gmlid_codespace             = NEW.gmlid_codespace;
obj_co.name                        = NEW.name;
obj_co.name_codespace              = NEW.name_codespace;
obj_co.description                 = NEW.description;
--obj_co.envelope                    = NEW.envelope;
obj_co.creation_date               = NEW.creation_date;
obj_co.termination_date            = NEW.termination_date;
obj_co.relative_to_terrain         = NEW.relative_to_terrain;
obj_co.relative_to_water           = NEW.relative_to_water;
obj_co.last_modification_date      = NEW.last_modification_date;
obj_co.updating_person             = NEW.updating_person;
obj_co.reason_for_update           = NEW.reason_for_update;
obj_co.lineage                     = NEW.lineage;

obj_bi.class                       = NEW.class;
obj_bi.class_codespace             = NEW.class_codespace;
obj_bi.function                    = array_to_string((SELECT array_agg(DISTINCT x) FROM unnest(NEW.function) AS t(x)), '--/\--');
obj_bi.function_codespace          = array_to_string((SELECT array_agg(DISTINCT x) FROM unnest(NEW.function_codespace) AS t(x)), '--/\--');
obj_bi.usage                       = array_to_string((SELECT array_agg(DISTINCT x) FROM unnest(NEW.usage) AS t(x)), '--/\--');
obj_bi.usage_codespace             = array_to_string((SELECT array_agg(DISTINCT x) FROM unnest(NEW.usage_codespace) AS t(x)), '--/\--');

PERFORM qgis_pkg.upd_building_installation_atts(obj_co, obj_bi, schema_name);

RETURN NEW;
EXCEPTION
  WHEN OTHERS THEN RAISE NOTICE 'qgis_pkg.tr_upd_building_installation_atts(id: %): %', OLD.id, SQLERRM;
END;
$$ LANGUAGE plpgsql;
COMMENT ON FUNCTION qgis_pkg.tr_upd_citydb_building_installation_atts IS 'Update record in view building_installation_*';

----------------------------------------------------------------
-- Create trigger FUNCTION QGIS_PKG.TR_INS_CITYDB_BUILDING_INSTALLATION
----------------------------------------------------------------
DROP FUNCTION IF EXISTS    qgis_pkg.tr_ins_citydb_building_installation CASCADE;
CREATE OR REPLACE FUNCTION qgis_pkg.tr_ins_citydb_building_installation()
RETURNS trigger AS $$
DECLARE
BEGIN
RAISE EXCEPTION 'You are not allowed to insert new records using the QGIS plugin';
RETURN NULL;
EXCEPTION
  WHEN OTHERS THEN RAISE NOTICE 'qgis_pkg.tr_ins_citydb_building_installation(): %', SQLERRM;
END;
$$ LANGUAGE plpgsql;
COMMENT ON FUNCTION qgis_pkg.tr_ins_citydb_building_installation IS '(Block) insert record in view citydb_building_installation_*';

----------------------------------------------------------------
-- Create trigger FUNCTION QGIS_PKG.TR_DEL_BUILDING_INSTALLATION
----------------------------------------------------------------
DROP FUNCTION IF EXISTS    qgis_pkg.tr_del_citydb_building_installation CASCADE;
CREATE OR REPLACE FUNCTION qgis_pkg.tr_del_citydb_building_installation()
RETURNS trigger AS $$
DECLARE
BEGIN
PERFORM citydb.del_building_installation(OLD.id);
RETURN OLD;
EXCEPTION
  WHEN OTHERS THEN RAISE NOTICE 'qgis_pkg.tr_del_citydb_building_installation(id: %): %', OLD.id, SQLERRM;
END;
$$ LANGUAGE plpgsql;
COMMENT ON FUNCTION qgis_pkg.tr_del_citydb_building_installation IS 'Delete record in view citydb_building_installation_*';


--**************************************************************
--**************************************************************
----------------------------------------------------------------
-- Create trigger FUNCTION QGIS_PKG.TR_UPD_CITYDB_BDG_THEMATIC_SURFACE_ATTS
----------------------------------------------------------------
DROP FUNCTION IF EXISTS    qgis_pkg.tr_upd_citydb_bdg_thematic_surface_atts CASCADE;
CREATE OR REPLACE FUNCTION qgis_pkg.tr_upd_citydb_bdg_thematic_surface_atts()
RETURNS trigger AS $$
DECLARE
  obj_co      qgis_pkg.obj_cityobject;
  schema_name varchar := 'citydb';  
BEGIN
obj_co.id                          = OLD.id;
obj_co.gmlid                       = NEW.gmlid;
obj_co.gmlid_codespace             = NEW.gmlid_codespace;
obj_co.name                        = NEW.name;
obj_co.name_codespace              = NEW.name_codespace;
obj_co.description                 = NEW.description;
--obj_co.envelope                    = NEW.envelope;
obj_co.creation_date               = NEW.creation_date;
obj_co.termination_date            = NEW.termination_date;
obj_co.relative_to_terrain         = NEW.relative_to_terrain;
obj_co.relative_to_water           = NEW.relative_to_water;
obj_co.last_modification_date      = NEW.last_modification_date;
obj_co.updating_person             = NEW.updating_person;
obj_co.reason_for_update           = NEW.reason_for_update;
obj_co.lineage                     = NEW.lineage;

PERFORM qgis_pkg.upd_thematic_surface_atts(obj_co, schema_name);

RETURN NEW;
EXCEPTION
  WHEN OTHERS THEN RAISE NOTICE 'qgis_pkg.tr_upd_bdg_thematic_surface_atts(id: %): %', OLD.id, SQLERRM;
END;
$$ LANGUAGE plpgsql;
COMMENT ON FUNCTION qgis_pkg.tr_upd_citydb_bdg_thematic_surface_atts IS 'Update record in view *_thematic_surface_*';

----------------------------------------------------------------
-- Create trigger FUNCTION QGIS_PKG.TR_INS_CITYDB_BDG_THEMATIC_SURFACE
----------------------------------------------------------------
DROP FUNCTION IF EXISTS    qgis_pkg.tr_ins_citydb_bdg_thematic_surface CASCADE;
CREATE OR REPLACE FUNCTION qgis_pkg.tr_ins_citydb_bdg_thematic_surface()
RETURNS trigger AS $$
DECLARE
BEGIN
RAISE EXCEPTION 'You are not allowed to insert new records using the QGIS plugin';
RETURN NULL;
EXCEPTION
  WHEN OTHERS THEN RAISE NOTICE 'qgis_pkg.tr_ins_citydb_bdg_thematic_surface(): %', SQLERRM;
END;
$$ LANGUAGE plpgsql;
COMMENT ON FUNCTION qgis_pkg.tr_ins_citydb_bdg_thematic_surface IS '(Block) insert record in view *_thematic_surface_*';

----------------------------------------------------------------
-- Create trigger FUNCTION QGIS_PKG.TR_DEL_BDG_THEMATIC_SURFACE
----------------------------------------------------------------
DROP FUNCTION IF EXISTS    qgis_pkg.tr_del_citydb_bdg_thematic_surface CASCADE;
CREATE OR REPLACE FUNCTION qgis_pkg.tr_del_citydb_bdg_thematic_surface()
RETURNS trigger AS $$
DECLARE
BEGIN
PERFORM citydb.del_thematic_surface(OLD.id);
RETURN OLD;
EXCEPTION
  WHEN OTHERS THEN RAISE NOTICE 'qgis_pkg.tr_del_citydb_bdg_thematic_surface(id: %): %', OLD.id, SQLERRM;
END;
$$ LANGUAGE plpgsql;
COMMENT ON FUNCTION qgis_pkg.tr_del_citydb_bdg_thematic_surface IS 'Delete record in view *_thematic_surface_*';

-- ****************************************************************************
-- ****************************************************************************
--
--
-- TRIGGERS
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
	EXECUTE PROCEDURE qgis_pkg.tr_del_citydb_building();
COMMENT ON TRIGGER tr_del_citydb_building_lod0_footprint ON qgis_pkg.citydb_building_lod0_footprint IS 'Fired upon delete on view qgis_pkg.citydb_building_lod0_footprint';

DROP TRIGGER IF EXISTS tr_ins_citydb_building_lod0_footprint ON qgis_pkg.citydb_building_lod0_footprint;
CREATE TRIGGER         tr_ins_citydb_building_lod0_footprint
	INSTEAD OF INSERT ON qgis_pkg.citydb_building_lod0_footprint
	FOR EACH ROW
	EXECUTE PROCEDURE qgis_pkg.tr_ins_citydb_building();
COMMENT ON TRIGGER tr_ins_citydb_building_lod0_footprint ON qgis_pkg.citydb_building_lod0_footprint IS 'Fired upon (blocked) insert into view qgis_pkg.citydb_building_lod0_footprint';

DROP TRIGGER IF EXISTS tr_upd_citydb_building_lod0_footprint ON qgis_pkg.citydb_building_lod0_footprint;
CREATE TRIGGER         tr_upd_citydb_building_lod0_footprint
	INSTEAD OF UPDATE ON qgis_pkg.citydb_building_lod0_footprint
	FOR EACH ROW
	EXECUTE PROCEDURE qgis_pkg.tr_upd_citydb_building_atts();
COMMENT ON TRIGGER tr_upd_citydb_building_lod0_footprint ON qgis_pkg.citydb_building_lod0_footprint IS 'Fired upon update of view qgis_pkg.citydb_building_lod0_footprint';	

----------------------------------------------------------------
-- Create TRIGGERS for view QGIS_PKG.CITYDB_BUILDING_LOD0_ROOFEDGE
----------------------------------------------------------------
DROP TRIGGER IF EXISTS tr_del_citydb_building_lod0_roofedge ON qgis_pkg.citydb_building_lod0_roofedge;
CREATE TRIGGER         tr_del_citydb_building_lod0_roofedge
	INSTEAD OF DELETE ON qgis_pkg.citydb_building_lod0_roofedge
	FOR EACH ROW
	EXECUTE PROCEDURE qgis_pkg.tr_del_citydb_building();
COMMENT ON TRIGGER tr_del_citydb_building_lod0_roofedge ON qgis_pkg.citydb_building_lod0_roofedge IS 'Fired upon delete on view qgis_pkg.citydb_building_lod0_roofedge';

DROP TRIGGER IF EXISTS tr_ins_citydb_building_lod0_roofedge ON qgis_pkg.citydb_building_lod0_roofedge;
CREATE TRIGGER         tr_ins_citydb_building_lod0_roofedge
	INSTEAD OF INSERT ON qgis_pkg.citydb_building_lod0_roofedge
	FOR EACH ROW
	EXECUTE PROCEDURE qgis_pkg.tr_ins_citydb_building();
COMMENT ON TRIGGER tr_ins_citydb_building_lod0_roofedge ON qgis_pkg.citydb_building_lod0_roofedge IS 'Fired upon (blocked) insert into view qgis_pkg.citydb_building_lod0_roofedge';

DROP TRIGGER IF EXISTS tr_upd_citydb_building_lod0_roofedge ON qgis_pkg.citydb_building_lod0_roofedge;
CREATE TRIGGER         tr_upd_citydb_building_lod0_roofedge
	INSTEAD OF UPDATE ON qgis_pkg.citydb_building_lod0_roofedge
	FOR EACH ROW
	EXECUTE PROCEDURE qgis_pkg.tr_upd_citydb_building_atts();
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
	EXECUTE PROCEDURE qgis_pkg.tr_del_citydb_building();
COMMENT ON TRIGGER tr_del_citydb_building_lod1_multisurf ON qgis_pkg.citydb_building_lod1_multisurf IS 'Fired upon delete on view qgis_pkg.citydb_building_lod1_multisurf';

DROP TRIGGER IF EXISTS tr_ins_citydb_building_lod1_multisurf ON qgis_pkg.citydb_building_lod1_multisurf;
CREATE TRIGGER         tr_ins_citydb_building_lod1_multisurf
	INSTEAD OF INSERT ON qgis_pkg.citydb_building_lod1_multisurf
	FOR EACH ROW
	EXECUTE PROCEDURE qgis_pkg.tr_ins_citydb_building();
COMMENT ON TRIGGER tr_ins_citydb_building_lod1_multisurf ON qgis_pkg.citydb_building_lod1_multisurf IS 'Fired upon (blocked) insert into view qgis_pkg.citydb_building_lod1_multisurf';

DROP TRIGGER IF EXISTS tr_upd_citydb_building_lod1_multisurf ON qgis_pkg.citydb_building_lod1_multisurf;
CREATE TRIGGER         tr_upd_citydb_building_lod1_multisurf
	INSTEAD OF UPDATE ON qgis_pkg.citydb_building_lod1_multisurf
	FOR EACH ROW
	EXECUTE PROCEDURE qgis_pkg.tr_upd_citydb_building_atts();
COMMENT ON TRIGGER tr_upd_citydb_building_lod1_multisurf ON qgis_pkg.citydb_building_lod1_multisurf IS 'Fired upon update of view qgis_pkg.citydb_building_lod1_multisurf';

----------------------------------------------------------------
-- Create TRIGGERS for view QGIS_PKG.CITYDB_BUILDING_LOD1_SOLID
----------------------------------------------------------------
DROP TRIGGER IF EXISTS tr_del_citydb_building_lod1_solid ON qgis_pkg.citydb_building_lod1_solid;
CREATE TRIGGER         tr_del_citydb_building_lod1_solid
	INSTEAD OF DELETE ON qgis_pkg.citydb_building_lod1_solid
	FOR EACH ROW
	EXECUTE PROCEDURE qgis_pkg.tr_del_citydb_building();
COMMENT ON TRIGGER tr_del_citydb_building_lod1_solid ON qgis_pkg.citydb_building_lod1_solid IS 'Fired upon delete on view qgis_pkg.citydb_building_lod1_solid';

DROP TRIGGER IF EXISTS tr_ins_citydb_building_lod1_solid ON qgis_pkg.citydb_building_lod1_solid;
CREATE TRIGGER         tr_ins_citydb_building_lod1_solid
	INSTEAD OF INSERT ON qgis_pkg.citydb_building_lod1_solid
	FOR EACH ROW
	EXECUTE PROCEDURE qgis_pkg.tr_ins_citydb_building();
COMMENT ON TRIGGER tr_ins_citydb_building_lod1_solid ON qgis_pkg.citydb_building_lod1_solid IS 'Fired upon (blocked) insert into view qgis_pkg.citydb_building_lod1_solid';

DROP TRIGGER IF EXISTS tr_upd_citydb_building_lod1_solid ON qgis_pkg.citydb_building_lod1_solid;
CREATE TRIGGER         tr_upd_citydb_building_lod1_solid
	INSTEAD OF UPDATE ON qgis_pkg.citydb_building_lod1_solid
	FOR EACH ROW
	EXECUTE PROCEDURE qgis_pkg.tr_upd_citydb_building_atts();
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
	EXECUTE PROCEDURE qgis_pkg.tr_del_citydb_building();
COMMENT ON TRIGGER tr_del_citydb_building_lod2_multisurf ON qgis_pkg.citydb_building_lod2_multisurf IS 'Fired upon delete on view qgis_pkg.citydb_building_lod2_multisurf';

DROP TRIGGER IF EXISTS tr_ins_citydb_building_lod2_multisurf ON qgis_pkg.citydb_building_lod2_multisurf;
CREATE TRIGGER         tr_ins_citydb_building_lod2_multisurf
	INSTEAD OF INSERT ON qgis_pkg.citydb_building_lod2_multisurf
	FOR EACH ROW
	EXECUTE PROCEDURE qgis_pkg.tr_ins_citydb_building();
COMMENT ON TRIGGER tr_ins_citydb_building_lod2_multisurf ON qgis_pkg.citydb_building_lod2_multisurf IS 'Fired upon (blocked) insert into view qgis_pkg.citydb_building_lod2_multisurf';

DROP TRIGGER IF EXISTS tr_upd_citydb_building_lod2_multisurf ON qgis_pkg.citydb_building_lod2_multisurf;
CREATE TRIGGER         tr_upd_citydb_building_lod2_multisurf
	INSTEAD OF UPDATE ON qgis_pkg.citydb_building_lod2_multisurf
	FOR EACH ROW
	EXECUTE PROCEDURE qgis_pkg.tr_upd_citydb_building_atts();
COMMENT ON TRIGGER tr_upd_citydb_building_lod2_multisurf ON qgis_pkg.citydb_building_lod2_multisurf IS 'Fired upon update of view qgis_pkg.citydb_building_lod2_multisurf';	

----------------------------------------------------------------
-- Create TRIGGERS for view QGIS_PKG.CITYDB_BUILDING_LOD2_SOLID
----------------------------------------------------------------
DROP TRIGGER IF EXISTS tr_del_citydb_building_lod2_solid ON qgis_pkg.citydb_building_lod2_solid;
CREATE TRIGGER         tr_del_citydb_building_lod2_solid
	INSTEAD OF DELETE ON qgis_pkg.citydb_building_lod2_solid
	FOR EACH ROW
	EXECUTE PROCEDURE qgis_pkg.tr_del_citydb_building();
COMMENT ON TRIGGER tr_del_citydb_building_lod2_solid ON qgis_pkg.citydb_building_lod2_solid IS 'Fired upon delete on view qgis_pkg.citydb_building_lod2_solid';

DROP TRIGGER IF EXISTS tr_ins_citydb_building_lod2_solid ON qgis_pkg.citydb_building_lod2_solid;
CREATE TRIGGER         tr_ins_citydb_building_lod2_solid
	INSTEAD OF INSERT ON qgis_pkg.citydb_building_lod2_solid
	FOR EACH ROW
	EXECUTE PROCEDURE qgis_pkg.tr_ins_citydb_building();
COMMENT ON TRIGGER tr_ins_citydb_building_lod2_solid ON qgis_pkg.citydb_building_lod2_solid IS 'Fired upon (blocked) insert into view qgis_pkg.citydb_building_lod2_solid';

DROP TRIGGER IF EXISTS tr_upd_citydb_building_lod2_solid ON qgis_pkg.citydb_building_lod2_solid;
CREATE TRIGGER         tr_upd_citydb_building_lod2_solid
	INSTEAD OF UPDATE ON qgis_pkg.citydb_building_lod2_solid
	FOR EACH ROW
	EXECUTE PROCEDURE qgis_pkg.tr_upd_citydb_building_atts();
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
	EXECUTE PROCEDURE qgis_pkg.tr_del_citydb_building();
COMMENT ON TRIGGER tr_del_citydb_building_part_lod0_footprint ON qgis_pkg.citydb_building_part_lod0_footprint IS 'Fired upon delete on view qgis_pkg.citydb_building_part_lod0_footprint';

DROP TRIGGER IF EXISTS tr_ins_citydb_building_part_lod0_footprint ON qgis_pkg.citydb_building_part_lod0_footprint;
CREATE TRIGGER         tr_ins_citydb_building_part_lod0_footprint
	INSTEAD OF INSERT ON qgis_pkg.citydb_building_part_lod0_footprint
	FOR EACH ROW
	EXECUTE PROCEDURE qgis_pkg.tr_ins_citydb_building();
COMMENT ON TRIGGER tr_ins_citydb_building_part_lod0_footprint ON qgis_pkg.citydb_building_part_lod0_footprint IS 'Fired upon (blocked) insert into view qgis_pkg.citydb_building_part_lod0_footprint';

DROP TRIGGER IF EXISTS tr_upd_citydb_building_part_lod0_footprint ON qgis_pkg.citydb_building_part_lod0_footprint;
CREATE TRIGGER         tr_upd_citydb_building_part_lod0_footprint
	INSTEAD OF UPDATE ON qgis_pkg.citydb_building_part_lod0_footprint
	FOR EACH ROW
	EXECUTE PROCEDURE qgis_pkg.tr_upd_citydb_building_atts();
COMMENT ON TRIGGER tr_upd_citydb_building_part_lod0_footprint ON qgis_pkg.citydb_building_part_lod0_footprint IS 'Fired upon update of view qgis_pkg.citydb_building_part_lod0_footprint';	

----------------------------------------------------------------
-- Create TRIGGERS for view QGIS_PKG.CITYDB_BUILDING_PART_LOD0_ROOFEDGE
----------------------------------------------------------------
DROP TRIGGER IF EXISTS tr_del_citydb_building_part_lod0_roofedge ON qgis_pkg.citydb_building_part_lod0_roofedge;
CREATE TRIGGER         tr_del_citydb_building_part_lod0_roofedge
	INSTEAD OF DELETE ON qgis_pkg.citydb_building_part_lod0_roofedge
	FOR EACH ROW
	EXECUTE PROCEDURE qgis_pkg.tr_del_citydb_building();
COMMENT ON TRIGGER tr_del_citydb_building_part_lod0_roofedge ON qgis_pkg.citydb_building_part_lod0_roofedge IS 'Fired upon delete on view qgis_pkg.citydb_building_part_lod0_roofedge';

DROP TRIGGER IF EXISTS tr_ins_citydb_building_part_lod0_roofedge ON qgis_pkg.citydb_building_part_lod0_roofedge;
CREATE TRIGGER         tr_ins_citydb_building_part_lod0_roofedge
	INSTEAD OF INSERT ON qgis_pkg.citydb_building_part_lod0_roofedge
	FOR EACH ROW
	EXECUTE PROCEDURE qgis_pkg.tr_ins_citydb_building();
COMMENT ON TRIGGER tr_ins_citydb_building_part_lod0_roofedge ON qgis_pkg.citydb_building_part_lod0_roofedge IS 'Fired upon (blocked) insert into view qgis_pkg.citydb_building_part_lod0_roofedge';

DROP TRIGGER IF EXISTS tr_upd_citydb_building_part_lod0_roofedge ON qgis_pkg.citydb_building_part_lod0_roofedge;
CREATE TRIGGER         tr_upd_citydb_building_part_lod0_roofedge
	INSTEAD OF UPDATE ON qgis_pkg.citydb_building_part_lod0_roofedge
	FOR EACH ROW
	EXECUTE PROCEDURE qgis_pkg.tr_upd_citydb_building_atts();
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
	EXECUTE PROCEDURE qgis_pkg.tr_del_citydb_building();
COMMENT ON TRIGGER tr_del_citydb_building_part_lod1_multisurf ON qgis_pkg.citydb_building_part_lod1_multisurf IS 'Fired upon delete on view qgis_pkg.citydb_building_part_lod1_multisurf';

DROP TRIGGER IF EXISTS tr_ins_citydb_building_part_lod1_multisurf ON qgis_pkg.citydb_building_part_lod1_multisurf;
CREATE TRIGGER         tr_ins_citydb_building_part_lod1_multisurf
	INSTEAD OF INSERT ON qgis_pkg.citydb_building_part_lod1_multisurf
	FOR EACH ROW
	EXECUTE PROCEDURE qgis_pkg.tr_ins_citydb_building();
COMMENT ON TRIGGER tr_ins_citydb_building_part_lod1_multisurf ON qgis_pkg.citydb_building_part_lod1_multisurf IS 'Fired upon (blocked) insert into view qgis_pkg.citydb_building_part_lod1_multisurf';

DROP TRIGGER IF EXISTS tr_upd_citydb_building_part_lod1_multisurf ON qgis_pkg.citydb_building_part_lod1_multisurf;
CREATE TRIGGER         tr_upd_citydb_building_part_lod1_multisurf
	INSTEAD OF UPDATE ON qgis_pkg.citydb_building_part_lod1_multisurf
	FOR EACH ROW
	EXECUTE PROCEDURE qgis_pkg.tr_upd_citydb_building_atts();
COMMENT ON TRIGGER tr_upd_citydb_building_part_lod1_multisurf ON qgis_pkg.citydb_building_part_lod1_multisurf IS 'Fired upon update of view qgis_pkg.citydb_building_part_lod1_multisurf';

----------------------------------------------------------------
-- Create TRIGGERS for view QGIS_PKG.CITYDB_BUILDING_PART_LOD1_SOLID
----------------------------------------------------------------
DROP TRIGGER IF EXISTS tr_del_citydb_building_part_lod1_solid ON qgis_pkg.citydb_building_part_lod1_solid;
CREATE TRIGGER         tr_del_citydb_building_part_lod1_solid
	INSTEAD OF DELETE ON qgis_pkg.citydb_building_part_lod1_solid
	FOR EACH ROW
	EXECUTE PROCEDURE qgis_pkg.tr_del_citydb_building();
COMMENT ON TRIGGER tr_del_citydb_building_part_lod1_solid ON qgis_pkg.citydb_building_part_lod1_solid IS 'Fired upon delete on view qgis_pkg.citydb_building_part_lod1_solid';

DROP TRIGGER IF EXISTS tr_ins_citydb_building_part_lod1_solid ON qgis_pkg.citydb_building_part_lod1_solid;
CREATE TRIGGER         tr_ins_citydb_building_part_lod1_solid
	INSTEAD OF INSERT ON qgis_pkg.citydb_building_part_lod1_solid
	FOR EACH ROW
	EXECUTE PROCEDURE qgis_pkg.tr_ins_citydb_building();
COMMENT ON TRIGGER tr_ins_citydb_building_part_lod1_solid ON qgis_pkg.citydb_building_part_lod1_solid IS 'Fired upon (blocked) insert into view qgis_pkg.citydb_building_part_lod1_solid';

DROP TRIGGER IF EXISTS tr_upd_citydb_building_part_lod1_solid ON qgis_pkg.citydb_building_part_lod1_solid;
CREATE TRIGGER         tr_upd_citydb_building_part_lod1_solid
	INSTEAD OF UPDATE ON qgis_pkg.citydb_building_part_lod1_solid
	FOR EACH ROW
	EXECUTE PROCEDURE qgis_pkg.tr_upd_citydb_building_atts();
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
	EXECUTE PROCEDURE qgis_pkg.tr_del_citydb_building();
COMMENT ON TRIGGER tr_del_citydb_building_part_lod2_multisurf ON qgis_pkg.citydb_building_part_lod2_multisurf IS 'Fired upon delete on view qgis_pkg.citydb_building_part_lod2_multisurf';

DROP TRIGGER IF EXISTS tr_ins_citydb_building_part_lod2_multisurf ON qgis_pkg.citydb_building_part_lod2_multisurf;
CREATE TRIGGER         tr_ins_citydb_building_part_lod2_multisurf
	INSTEAD OF INSERT ON qgis_pkg.citydb_building_part_lod2_multisurf
	FOR EACH ROW
	EXECUTE PROCEDURE qgis_pkg.tr_ins_citydb_building();
COMMENT ON TRIGGER tr_ins_citydb_building_part_lod2_multisurf ON qgis_pkg.citydb_building_part_lod2_multisurf IS 'Fired upon (blocked) insert into view qgis_pkg.citydb_building_part_lod2_multisurf';

DROP TRIGGER IF EXISTS tr_upd_citydb_building_part_lod2_multisurf ON qgis_pkg.citydb_building_part_lod2_multisurf;
CREATE TRIGGER         tr_upd_citydb_building_part_lod2_multisurf
	INSTEAD OF UPDATE ON qgis_pkg.citydb_building_part_lod2_multisurf
	FOR EACH ROW
	EXECUTE PROCEDURE qgis_pkg.tr_upd_citydb_building_atts();
COMMENT ON TRIGGER tr_upd_citydb_building_part_lod2_multisurf ON qgis_pkg.citydb_building_part_lod2_multisurf IS 'Fired upon update of view qgis_pkg.citydb_building_part_lod2_multisurf';	

----------------------------------------------------------------
-- Create TRIGGERS for view QGIS_PKG.CITYDB_BUILDING_PART_LOD2_SOLID
----------------------------------------------------------------
DROP TRIGGER IF EXISTS tr_del_citydb_building_part_lod2_solid ON qgis_pkg.citydb_building_part_lod2_solid;
CREATE TRIGGER         tr_del_citydb_building_part_lod2_solid
	INSTEAD OF DELETE ON qgis_pkg.citydb_building_part_lod2_solid
	FOR EACH ROW
	EXECUTE PROCEDURE qgis_pkg.tr_del_citydb_building();
COMMENT ON TRIGGER tr_del_citydb_building_part_lod2_solid ON qgis_pkg.citydb_building_part_lod2_solid IS 'Fired upon delete on view qgis_pkg.citydb_building_part_lod2_solid';

DROP TRIGGER IF EXISTS tr_ins_citydb_building_part_lod2_solid ON qgis_pkg.citydb_building_part_lod2_solid;
CREATE TRIGGER         tr_ins_citydb_building_part_lod2_solid
	INSTEAD OF INSERT ON qgis_pkg.citydb_building_part_lod2_solid
	FOR EACH ROW
	EXECUTE PROCEDURE qgis_pkg.tr_ins_citydb_building();
COMMENT ON TRIGGER tr_ins_citydb_building_part_lod2_solid ON qgis_pkg.citydb_building_part_lod2_solid IS 'Fired upon (blocked) insert into view qgis_pkg.citydb_building_part_lod2_solid';

DROP TRIGGER IF EXISTS tr_upd_citydb_building_part_lod2_solid ON qgis_pkg.citydb_building_part_lod2_solid;
CREATE TRIGGER         tr_upd_citydb_building_part_lod2_solid
	INSTEAD OF UPDATE ON qgis_pkg.citydb_building_part_lod2_solid
	FOR EACH ROW
	EXECUTE PROCEDURE qgis_pkg.tr_upd_citydb_building_atts();
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
	EXECUTE PROCEDURE qgis_pkg.tr_del_citydb_building_installation();
COMMENT ON TRIGGER tr_del_citydb_bdg_outerinstallation_lod2_multisurf ON qgis_pkg.citydb_bdg_outerinstallation_lod2_multisurf IS 'Fired upon delete on view qgis_pkg.citydb_bdg_outerinstallation_lod2_multisurf';

DROP TRIGGER IF EXISTS tr_ins_citydb_bdg_outerinstallation_lod2_multisurf ON qgis_pkg.citydb_bdg_outerinstallation_lod2_multisurf;
CREATE TRIGGER         tr_ins_citydb_bdg_outerinstallation_lod2_multisurf
	INSTEAD OF INSERT ON qgis_pkg.citydb_bdg_outerinstallation_lod2_multisurf
	FOR EACH ROW
	EXECUTE PROCEDURE qgis_pkg.tr_ins_citydb_building_installation();
COMMENT ON TRIGGER tr_ins_citydb_bdg_outerinstallation_lod2_multisurf ON qgis_pkg.citydb_bdg_outerinstallation_lod2_multisurf IS 'Fired upon (blocked) insert into view qgis_pkg.citydb_bdg_outerinstallation_lod2_multisurf';

DROP TRIGGER IF EXISTS tr_upd_citydb_bdg_outerinstallation_lod2_multisurf ON qgis_pkg.citydb_bdg_outerinstallation_lod2_multisurf;
CREATE TRIGGER         tr_upd_citydb_bdg_outerinstallation_lod2_multisurf
	INSTEAD OF UPDATE ON qgis_pkg.citydb_bdg_outerinstallation_lod2_multisurf
	FOR EACH ROW
	EXECUTE PROCEDURE qgis_pkg.tr_upd_citydb_building_installation_atts();
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
	EXECUTE PROCEDURE qgis_pkg.tr_del_citydb_bdg_thematic_surface();
COMMENT ON TRIGGER tr_del_citydb_bdg_groundsurface_lod2_multisurf ON qgis_pkg.citydb_bdg_groundsurface_lod2_multisurf IS 'Fired upon delete on view qgis_pkg.citydb_bdg_groundsurface_lod2_multisurf';

DROP TRIGGER IF EXISTS tr_ins_citydb_bdg_groundsurface_lod2_multisurf ON qgis_pkg.citydb_bdg_groundsurface_lod2_multisurf;
CREATE TRIGGER         tr_ins_citydb_bdg_groundsurface_lod2_multisurf
	INSTEAD OF INSERT ON qgis_pkg.citydb_bdg_groundsurface_lod2_multisurf
	FOR EACH ROW
	EXECUTE PROCEDURE qgis_pkg.tr_ins_citydb_bdg_thematic_surface();
COMMENT ON TRIGGER tr_ins_citydb_bdg_groundsurface_lod2_multisurf ON qgis_pkg.citydb_bdg_groundsurface_lod2_multisurf IS 'Fired upon (blocked) insert into view qgis_pkg.citydb_bdg_groundsurface_lod2_multisurf';

DROP TRIGGER IF EXISTS tr_upd_citydb_bdg_groundsurface_lod2_multisurf ON qgis_pkg.citydb_bdg_groundsurface_lod2_multisurf;
CREATE TRIGGER         tr_upd_citydb_bdg_groundsurface_lod2_multisurf
	INSTEAD OF UPDATE ON qgis_pkg.citydb_bdg_groundsurface_lod2_multisurf
	FOR EACH ROW
	EXECUTE PROCEDURE qgis_pkg.tr_upd_citydb_bdg_thematic_surface_atts();
COMMENT ON TRIGGER tr_upd_citydb_bdg_groundsurface_lod2_multisurf ON qgis_pkg.citydb_bdg_groundsurface_lod2_multisurf IS 'Fired upon update of view qgis_pkg.citydb_bdg_groundsurface_lod2_multisurf';	

----------------------------------------------------------------
-- Create TRIGGERS for view QGIS_PKG.CITYDB_BDG_WALLSURFACE_LOD2_MULTISURF
----------------------------------------------------------------
DROP TRIGGER IF EXISTS tr_del_citydb_bdg_wallsurface_lod2_multisurf ON qgis_pkg.citydb_bdg_wallsurface_lod2_multisurf;
CREATE TRIGGER         tr_del_citydb_bdg_wallsurface_lod2_multisurf
	INSTEAD OF DELETE ON qgis_pkg.citydb_bdg_wallsurface_lod2_multisurf
	FOR EACH ROW
	EXECUTE PROCEDURE qgis_pkg.tr_del_citydb_bdg_thematic_surface();
COMMENT ON TRIGGER tr_del_citydb_bdg_wallsurface_lod2_multisurf ON qgis_pkg.citydb_bdg_wallsurface_lod2_multisurf IS 'Fired upon delete on view qgis_pkg.citydb_bdg_wallsurface_lod2_multisurf';

DROP TRIGGER IF EXISTS tr_ins_citydb_bdg_wallsurface_lod2_multisurf ON qgis_pkg.citydb_bdg_wallsurface_lod2_multisurf;
CREATE TRIGGER         tr_ins_citydb_bdg_wallsurface_lod2_multisurf
	INSTEAD OF INSERT ON qgis_pkg.citydb_bdg_wallsurface_lod2_multisurf
	FOR EACH ROW
	EXECUTE PROCEDURE qgis_pkg.tr_ins_citydb_bdg_thematic_surface();
COMMENT ON TRIGGER tr_ins_citydb_bdg_wallsurface_lod2_multisurf ON qgis_pkg.citydb_bdg_wallsurface_lod2_multisurf IS 'Fired upon (blocked) insert into view qgis_pkg.citydb_bdg_wallsurface_lod2_multisurf';

DROP TRIGGER IF EXISTS tr_upd_citydb_bdg_wallsurface_lod2_multisurf ON qgis_pkg.citydb_bdg_wallsurface_lod2_multisurf;
CREATE TRIGGER         tr_upd_citydb_bdg_wallsurface_lod2_multisurf
	INSTEAD OF UPDATE ON qgis_pkg.citydb_bdg_wallsurface_lod2_multisurf
	FOR EACH ROW
	EXECUTE PROCEDURE qgis_pkg.tr_upd_citydb_bdg_thematic_surface_atts();
COMMENT ON TRIGGER tr_upd_citydb_bdg_wallsurface_lod2_multisurf ON qgis_pkg.citydb_bdg_wallsurface_lod2_multisurf IS 'Fired upon update of view qgis_pkg.citydb_bdg_wallsurface_lod2_multisurf';	

----------------------------------------------------------------
-- Create TRIGGERS for view QGIS_PKG.CITYDB_BDG_ROOFSURFACE_LOD2_MULTISURF
----------------------------------------------------------------
DROP TRIGGER IF EXISTS tr_del_citydb_bdg_roofsurface_lod2_multisurf ON qgis_pkg.citydb_bdg_roofsurface_lod2_multisurf;
CREATE TRIGGER         tr_del_citydb_bdg_roofsurface_lod2_multisurf
	INSTEAD OF DELETE ON qgis_pkg.citydb_bdg_roofsurface_lod2_multisurf
	FOR EACH ROW
	EXECUTE PROCEDURE qgis_pkg.tr_del_citydb_bdg_thematic_surface();
COMMENT ON TRIGGER tr_del_citydb_bdg_roofsurface_lod2_multisurf ON qgis_pkg.citydb_bdg_roofsurface_lod2_multisurf IS 'Fired upon delete on view qgis_pkg.citydb_bdg_roofsurface_lod2_multisurf';

DROP TRIGGER IF EXISTS tr_ins_citydb_bdg_roofsurface_lod2_multisurf ON qgis_pkg.citydb_bdg_roofsurface_lod2_multisurf;
CREATE TRIGGER         tr_ins_citydb_bdg_roofsurface_lod2_multisurf
	INSTEAD OF INSERT ON qgis_pkg.citydb_bdg_roofsurface_lod2_multisurf
	FOR EACH ROW
	EXECUTE PROCEDURE qgis_pkg.tr_ins_citydb_bdg_thematic_surface();
COMMENT ON TRIGGER tr_ins_citydb_bdg_roofsurface_lod2_multisurf ON qgis_pkg.citydb_bdg_roofsurface_lod2_multisurf IS 'Fired upon (blocked) insert into view qgis_pkg.citydb_bdg_roofsurface_lod2_multisurf';

DROP TRIGGER IF EXISTS tr_upd_citydb_bdg_roofsurface_lod2_multisurf ON qgis_pkg.citydb_bdg_roofsurface_lod2_multisurf;
CREATE TRIGGER         tr_upd_citydb_bdg_roofsurface_lod2_multisurf
	INSTEAD OF UPDATE ON qgis_pkg.citydb_bdg_roofsurface_lod2_multisurf
	FOR EACH ROW
	EXECUTE PROCEDURE qgis_pkg.tr_upd_citydb_bdg_thematic_surface_atts();
COMMENT ON TRIGGER tr_upd_citydb_bdg_roofsurface_lod2_multisurf ON qgis_pkg.citydb_bdg_roofsurface_lod2_multisurf IS 'Fired upon update of view qgis_pkg.citydb_bdg_roofsurface_lod2_multisurf';	

----------------------------------------------------------------
-- Create TRIGGERS for view QGIS_PKG.CITYDB_BDG_CLOSURESURFACE_LOD2_MULTISURF
----------------------------------------------------------------
DROP TRIGGER IF EXISTS tr_del_citydb_bdg_closuresurface_lod2_multisurf ON qgis_pkg.citydb_bdg_closuresurface_lod2_multisurf;
CREATE TRIGGER         tr_del_citydb_bdg_closuresurface_lod2_multisurf
	INSTEAD OF DELETE ON qgis_pkg.citydb_bdg_closuresurface_lod2_multisurf
	FOR EACH ROW
	EXECUTE PROCEDURE qgis_pkg.tr_del_citydb_bdg_thematic_surface();
COMMENT ON TRIGGER tr_del_citydb_bdg_closuresurface_lod2_multisurf ON qgis_pkg.citydb_bdg_closuresurface_lod2_multisurf IS 'Fired upon delete on view qgis_pkg.citydb_bdg_closuresurface_lod2_multisurf';

DROP TRIGGER IF EXISTS tr_ins_citydb_bdg_closuresurface_lod2_multisurf ON qgis_pkg.citydb_bdg_closuresurface_lod2_multisurf;
CREATE TRIGGER         tr_ins_citydb_bdg_closuresurface_lod2_multisurf
	INSTEAD OF INSERT ON qgis_pkg.citydb_bdg_closuresurface_lod2_multisurf
	FOR EACH ROW
	EXECUTE PROCEDURE qgis_pkg.tr_ins_citydb_bdg_thematic_surface();
COMMENT ON TRIGGER tr_ins_citydb_bdg_closuresurface_lod2_multisurf ON qgis_pkg.citydb_bdg_closuresurface_lod2_multisurf IS 'Fired upon (blocked) insert into view qgis_pkg.citydb_bdg_closuresurface_lod2_multisurf';

DROP TRIGGER IF EXISTS tr_upd_citydb_bdg_closuresurface_lod2_multisurf ON qgis_pkg.citydb_bdg_closuresurface_lod2_multisurf;
CREATE TRIGGER         tr_upd_citydb_bdg_closuresurface_lod2_multisurf
	INSTEAD OF UPDATE ON qgis_pkg.citydb_bdg_closuresurface_lod2_multisurf
	FOR EACH ROW
	EXECUTE PROCEDURE qgis_pkg.tr_upd_citydb_bdg_thematic_surface_atts();
COMMENT ON TRIGGER tr_upd_citydb_bdg_closuresurface_lod2_multisurf ON qgis_pkg.citydb_bdg_closuresurface_lod2_multisurf IS 'Fired upon update of view qgis_pkg.citydb_bdg_closuresurface_lod2_multisurf';	

----------------------------------------------------------------
-- Create TRIGGERS for view QGIS_PKG.CITYDB_BDG_OUTERCEILINGSURFACE_LOD2_MULTISURF
----------------------------------------------------------------
DROP TRIGGER IF EXISTS tr_del_citydb_bdg_outerceilingsurface_lod2_multisurf ON qgis_pkg.citydb_bdg_outerceilingsurface_lod2_multisurf;
CREATE TRIGGER         tr_del_citydb_bdg_outerceilingsurface_lod2_multisurf
	INSTEAD OF DELETE ON qgis_pkg.citydb_bdg_outerceilingsurface_lod2_multisurf
	FOR EACH ROW
	EXECUTE PROCEDURE qgis_pkg.tr_del_citydb_bdg_thematic_surface();
COMMENT ON TRIGGER tr_del_citydb_bdg_outerceilingsurface_lod2_multisurf ON qgis_pkg.citydb_bdg_outerceilingsurface_lod2_multisurf IS 'Fired upon delete on view qgis_pkg.citydb_bdg_outerceilingsurface_lod2_multisurf';

DROP TRIGGER IF EXISTS tr_ins_citydb_bdg_outerceilingsurface_lod2_multisurf ON qgis_pkg.citydb_bdg_outerceilingsurface_lod2_multisurf;
CREATE TRIGGER         tr_ins_citydb_bdg_outerceilingsurface_lod2_multisurf
	INSTEAD OF INSERT ON qgis_pkg.citydb_bdg_outerceilingsurface_lod2_multisurf
	FOR EACH ROW
	EXECUTE PROCEDURE qgis_pkg.tr_ins_citydb_bdg_thematic_surface();
COMMENT ON TRIGGER tr_ins_citydb_bdg_outerceilingsurface_lod2_multisurf ON qgis_pkg.citydb_bdg_outerceilingsurface_lod2_multisurf IS 'Fired upon (blocked) insert into view qgis_pkg.citydb_bdg_outerceilingsurface_lod2_multisurf';

DROP TRIGGER IF EXISTS tr_upd_citydb_bdg_outerceilingsurface_lod2_multisurf ON qgis_pkg.citydb_bdg_outerceilingsurface_lod2_multisurf;
CREATE TRIGGER         tr_upd_citydb_bdg_outerceilingsurface_lod2_multisurf
	INSTEAD OF UPDATE ON qgis_pkg.citydb_bdg_outerceilingsurface_lod2_multisurf
	FOR EACH ROW
	EXECUTE PROCEDURE qgis_pkg.tr_upd_citydb_bdg_thematic_surface_atts();
COMMENT ON TRIGGER tr_upd_citydb_bdg_outerceilingsurface_lod2_multisurf ON qgis_pkg.citydb_bdg_outerceilingsurface_lod2_multisurf IS 'Fired upon update of view qgis_pkg.citydb_bdg_outerceilingsurface_lod2_multisurf';	

----------------------------------------------------------------
-- Create TRIGGERS for view QGIS_PKG.CITYDB_BDG_OUTERFLOORSURFACE_LOD2_MULTISURF
----------------------------------------------------------------
DROP TRIGGER IF EXISTS tr_del_citydb_bdg_outerfloorsurface_lod2_multisurf ON qgis_pkg.citydb_bdg_outerfloorsurface_lod2_multisurf;
CREATE TRIGGER         tr_del_citydb_bdg_outerfloorsurface_lod2_multisurf
	INSTEAD OF DELETE ON qgis_pkg.citydb_bdg_outerfloorsurface_lod2_multisurf
	FOR EACH ROW
	EXECUTE PROCEDURE qgis_pkg.tr_del_citydb_bdg_thematic_surface();
COMMENT ON TRIGGER tr_del_citydb_bdg_outerfloorsurface_lod2_multisurf ON qgis_pkg.citydb_bdg_outerfloorsurface_lod2_multisurf IS 'Fired upon delete on view qgis_pkg.citydb_bdg_outerfloorsurface_lod2_multisurf';

DROP TRIGGER IF EXISTS tr_ins_citydb_bdg_outerfloorsurface_lod2_multisurf ON qgis_pkg.citydb_bdg_outerfloorsurface_lod2_multisurf;
CREATE TRIGGER         tr_ins_citydb_bdg_outerfloorsurface_lod2_multisurf
	INSTEAD OF INSERT ON qgis_pkg.citydb_bdg_outerfloorsurface_lod2_multisurf
	FOR EACH ROW
	EXECUTE PROCEDURE qgis_pkg.tr_ins_citydb_bdg_thematic_surface();
COMMENT ON TRIGGER tr_ins_citydb_bdg_outerfloorsurface_lod2_multisurf ON qgis_pkg.citydb_bdg_outerfloorsurface_lod2_multisurf IS 'Fired upon (blocked) insert into view qgis_pkg.citydb_bdg_outerfloorsurface_lod2_multisurf';

DROP TRIGGER IF EXISTS tr_upd_citydb_bdg_outerfloorsurface_lod2_multisurf ON qgis_pkg.citydb_bdg_outerfloorsurface_lod2_multisurf;
CREATE TRIGGER         tr_upd_citydb_bdg_outerfloorsurface_lod2_multisurf
	INSTEAD OF UPDATE ON qgis_pkg.citydb_bdg_outerfloorsurface_lod2_multisurf
	FOR EACH ROW
	EXECUTE PROCEDURE qgis_pkg.tr_upd_citydb_bdg_thematic_surface_atts();
COMMENT ON TRIGGER tr_upd_citydb_bdg_outerfloorsurface_lod2_multisurf ON qgis_pkg.citydb_bdg_outerfloorsurface_lod2_multisurf IS 'Fired upon update of view qgis_pkg.citydb_bdg_outerfloorsurface_lod2_multisurf';	


--************************************************
SELECT qgis_pkg.refresh_materialized_view();
--**************************
DO $$
BEGIN
RAISE NOTICE 'Done';
END $$;
--**************************
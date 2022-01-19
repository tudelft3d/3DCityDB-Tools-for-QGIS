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
-- Create trigger FUNCTION QGIS_PKG.TR_INS_BUILDING
----------------------------------------------------------------
DROP FUNCTION IF EXISTS    qgis_pkg.tr_ins_building CASCADE;
CREATE OR REPLACE FUNCTION qgis_pkg.tr_ins_building()
RETURNS trigger AS $$
DECLARE
BEGIN
RAISE EXCEPTION 'You are not allowed to insert new records using the QGIS plugin';
EXCEPTION
  WHEN OTHERS THEN RAISE NOTICE 'qgis_pkg.tr_ins_building(): %', SQLERRM;
END;
$$ LANGUAGE plpgsql;
COMMENT ON FUNCTION qgis_pkg.tr_ins_building IS '(Block) insert record in view *_building_*';

----------------------------------------------------------------
-- Create trigger FUNCTION QGIS_PKG.TR_DEL_BUILDING
----------------------------------------------------------------
DROP FUNCTION IF EXISTS    qgis_pkg.tr_del_building CASCADE;
CREATE OR REPLACE FUNCTION qgis_pkg.tr_del_building()
RETURNS trigger AS $$
DECLARE
  schema_name varchar := split_part(TG_TABLE_NAME, '_', 1); 
BEGIN
EXECUTE format('PERFORM %I.del_building(%L)', schema_name, OLD.id);
RETURN OLD;
EXCEPTION
  WHEN OTHERS THEN RAISE NOTICE 'qgis_pkg.tr_del_building(id: %): %', OLD.id, SQLERRM;
END;
$$ LANGUAGE plpgsql;
COMMENT ON FUNCTION qgis_pkg.tr_del_building IS 'Delete record in view *_building_*';

----------------------------------------------------------------
-- Create trigger FUNCTION QGIS_PKG.TR_UPD_BUILDING
----------------------------------------------------------------
DROP FUNCTION IF EXISTS    qgis_pkg.tr_upd_building CASCADE;
CREATE OR REPLACE FUNCTION qgis_pkg.tr_upd_building()
RETURNS trigger AS $$
DECLARE
  obj_co      qgis_pkg.obj_cityobject;
  obj_b       qgis_pkg.obj_building;
  schema_name varchar := split_part(TG_TABLE_NAME, '_', 1); 
BEGIN
obj_co.id                     := OLD.id;
obj_co.gmlid                  := NEW.gmlid;
obj_co.gmlid_codespace        := NEW.gmlid_codespace;
obj_co.name                   := NEW.name;
obj_co.name_codespace         := NEW.name_codespace;
obj_co.description            := NEW.description;
--obj_co.envelope               := NEW.envelope;
obj_co.creation_date          := NEW.creation_date;
obj_co.termination_date       := NEW.termination_date;
obj_co.relative_to_terrain    := NEW.relative_to_terrain;
obj_co.relative_to_water      := NEW.relative_to_water;
obj_co.last_modification_date := NEW.last_modification_date;
obj_co.updating_person        := NEW.updating_person;
obj_co.reason_for_update      := NEW.reason_for_update;
obj_co.lineage                := NEW.lineage;

obj_b.id                          := OLD.id;
obj_b.class                       := NEW.class;
obj_b.class_codespace             := NEW.class_codespace;
obj_b.function                    := array_to_string((SELECT array_agg(DISTINCT x) FROM unnest(NEW.function) AS t(x)), '--/\--');
obj_b.function_codespace          := array_to_string((SELECT array_agg(DISTINCT x) FROM unnest(NEW.function_codespace) AS t(x)), '--/\--');
obj_b.usage                       := array_to_string((SELECT array_agg(DISTINCT x) FROM unnest(NEW.usage) AS t(x)), '--/\--');
obj_b.usage_codespace             := array_to_string((SELECT array_agg(DISTINCT x) FROM unnest(NEW.usage_codespace) AS t(x)), '--/\--');
obj_b.year_of_construction        := NEW.year_of_construction;
obj_b.year_of_demolition          := NEW.year_of_demolition;
obj_b.roof_type                   := NEW.roof_type;
obj_b.roof_type_codespace         := NEW.roof_type_codespace;
obj_b.measured_height             := NEW.measured_height;
obj_b.measured_height_unit        := NEW.measured_height_unit;
obj_b.storeys_above_ground        := NEW.storeys_above_ground;
obj_b.storeys_below_ground        := NEW.storeys_below_ground;
obj_b.storey_heights_above_ground := NEW.storey_heights_above_ground;
obj_b.storey_heights_ag_unit      := NEW.storey_heights_ag_unit;
obj_b.storey_heights_below_ground := NEW.storey_heights_below_ground;
obj_b.storey_heights_bg_unit      := NEW.storey_heights_bg_unit;

PERFORM qgis_pkg.upd_building_atts(obj_co, obj_b, schema_name);

RETURN NEW;
EXCEPTION
  WHEN OTHERS THEN RAISE NOTICE 'qgis_pkg.tr_upd_building(id: %): %', OLD.id, SQLERRM;
END;
$$ LANGUAGE plpgsql;
COMMENT ON FUNCTION qgis_pkg.tr_upd_building IS 'Update record in view *_building_*';


--**************************************************************
--**************************************************************
----------------------------------------------------------------
-- Create trigger FUNCTION QGIS_PKG.TR_UPD_BUILDING_INSTALLATION
----------------------------------------------------------------
DROP FUNCTION IF EXISTS    qgis_pkg.tr_upd_building_installation CASCADE;
CREATE OR REPLACE FUNCTION qgis_pkg.tr_upd_building_installation()
RETURNS trigger AS $$
DECLARE
  obj_co      qgis_pkg.obj_cityobject;
  obj_bi      qgis_pkg.obj_building_installation;
  schema_name varchar := split_part(TG_TABLE_NAME, '_', 1);  
BEGIN
obj_co.id                     := OLD.id;
obj_co.gmlid                  := NEW.gmlid;
obj_co.gmlid_codespace        := NEW.gmlid_codespace;
obj_co.name                   := NEW.name;
obj_co.name_codespace         := NEW.name_codespace;
obj_co.description            := NEW.description;
--obj_co.envelope               := NEW.envelope;
obj_co.creation_date          := NEW.creation_date;
obj_co.termination_date       := NEW.termination_date;
obj_co.relative_to_terrain    := NEW.relative_to_terrain;
obj_co.relative_to_water      := NEW.relative_to_water;
obj_co.last_modification_date := NEW.last_modification_date;
obj_co.updating_person        := NEW.updating_person;
obj_co.reason_for_update      := NEW.reason_for_update;
obj_co.lineage                := NEW.lineage;

obj_bi.id                 := OLD.id;
obj_bi.class              := NEW.class;
obj_bi.class_codespace    := NEW.class_codespace;
obj_bi.function           := array_to_string((SELECT array_agg(DISTINCT x) FROM unnest(NEW.function) AS t(x)), '--/\--');
obj_bi.function_codespace := array_to_string((SELECT array_agg(DISTINCT x) FROM unnest(NEW.function_codespace) AS t(x)), '--/\--');
obj_bi.usage              := array_to_string((SELECT array_agg(DISTINCT x) FROM unnest(NEW.usage) AS t(x)), '--/\--');
obj_bi.usage_codespace    := array_to_string((SELECT array_agg(DISTINCT x) FROM unnest(NEW.usage_codespace) AS t(x)), '--/\--');

PERFORM qgis_pkg.upd_building_installation_atts(obj_co, obj_bi, schema_name);

RETURN NEW;
EXCEPTION
  WHEN OTHERS THEN RAISE NOTICE 'qgis_pkg.tr_upd_building_installation(id: %): %', OLD.id, SQLERRM;
END;
$$ LANGUAGE plpgsql;
COMMENT ON FUNCTION qgis_pkg.tr_upd_building_installation IS 'Update record in view *_building_installation_*';

----------------------------------------------------------------
-- Create trigger FUNCTION QGIS_PKG.TR_INS_BUILDING_INSTALLATION
----------------------------------------------------------------
DROP FUNCTION IF EXISTS    qgis_pkg.tr_ins_building_installation CASCADE;
CREATE OR REPLACE FUNCTION qgis_pkg.tr_ins_building_installation()
RETURNS trigger AS $$
DECLARE
BEGIN
RAISE EXCEPTION 'You are not allowed to insert new records using the QGIS plugin';
RETURN NULL;
EXCEPTION
  WHEN OTHERS THEN RAISE NOTICE 'qgis_pkg.tr_ins_building_installation(): %', SQLERRM;
END;
$$ LANGUAGE plpgsql;
COMMENT ON FUNCTION qgis_pkg.tr_ins_building_installation IS '(Block) insert record in view *_building_installation_*';

----------------------------------------------------------------
-- Create trigger FUNCTION QGIS_PKG.TR_DEL_BUILDING_INSTALLATION
----------------------------------------------------------------
DROP FUNCTION IF EXISTS    qgis_pkg.tr_del_building_installation CASCADE;
CREATE OR REPLACE FUNCTION qgis_pkg.tr_del_building_installation()
RETURNS trigger AS $$
DECLARE
  schema_name varchar := split_part(TG_TABLE_NAME, '_', 1); 
BEGIN
EXECUTE format('PERFORM %I.del_building_installation(%L)', schema_name, OLD.id);
RETURN OLD;
EXCEPTION
  WHEN OTHERS THEN RAISE NOTICE 'qgis_pkg.tr_del_building_installation(id: %): %', OLD.id, SQLERRM;
END;
$$ LANGUAGE plpgsql;
COMMENT ON FUNCTION qgis_pkg.tr_del_building_installation IS 'Delete record in view *_building_installation_*';


--**************************************************************
--**************************************************************
----------------------------------------------------------------
-- Create trigger FUNCTION QGIS_PKG.TR_UPD_BDG_THEMATIC_SURFACE
----------------------------------------------------------------
DROP FUNCTION IF EXISTS    qgis_pkg.tr_upd_bdg_thematic_surface CASCADE;
CREATE OR REPLACE FUNCTION qgis_pkg.tr_upd_bdg_thematic_surface()
RETURNS trigger AS $$
DECLARE
  obj_co      qgis_pkg.obj_cityobject;
  schema_name varchar := split_part(TG_TABLE_NAME, '_', 1); 
BEGIN
obj_co.id                     := OLD.id;
obj_co.gmlid                  := NEW.gmlid;
obj_co.gmlid_codespace        := NEW.gmlid_codespace;
obj_co.name                   := NEW.name;
obj_co.name_codespace         := NEW.name_codespace;
obj_co.description            := NEW.description;
--obj_co.envelope               := NEW.envelope;
obj_co.creation_date          := NEW.creation_date;
obj_co.termination_date       := NEW.termination_date;
obj_co.relative_to_terrain    := NEW.relative_to_terrain;
obj_co.relative_to_water      := NEW.relative_to_water;
obj_co.last_modification_date := NEW.last_modification_date;
obj_co.updating_person        := NEW.updating_person;
obj_co.reason_for_update      := NEW.reason_for_update;
obj_co.lineage                := NEW.lineage;

PERFORM qgis_pkg.upd_thematic_surface_atts(obj_co, schema_name);

RETURN NEW;
EXCEPTION
  WHEN OTHERS THEN RAISE NOTICE 'qgis_pkg.tr_upd_bdg_thematic_surface(id: %): %', OLD.id, SQLERRM;
END;
$$ LANGUAGE plpgsql;
COMMENT ON FUNCTION qgis_pkg.tr_upd_bdg_thematic_surface IS 'Update record in view *_thematic_surface_*';

----------------------------------------------------------------
-- Create trigger FUNCTION QGIS_PKG.TR_INS_BDG_THEMATIC_SURFACE
----------------------------------------------------------------
DROP FUNCTION IF EXISTS    qgis_pkg.tr_ins_bdg_thematic_surface CASCADE;
CREATE OR REPLACE FUNCTION qgis_pkg.tr_ins_bdg_thematic_surface()
RETURNS trigger AS $$
DECLARE
BEGIN
RAISE EXCEPTION 'You are not allowed to insert new records using the QGIS plugin';
RETURN NULL;
EXCEPTION
  WHEN OTHERS THEN RAISE NOTICE 'qgis_pkg.tr_ins_bdg_thematic_surface(): %', SQLERRM;
END;
$$ LANGUAGE plpgsql;
COMMENT ON FUNCTION qgis_pkg.tr_ins_bdg_thematic_surface IS '(Block) insert record in view *_thematic_surface_*';

----------------------------------------------------------------
-- Create trigger FUNCTION QGIS_PKG.TR_DEL_BDG_THEMATIC_SURFACE
----------------------------------------------------------------
DROP FUNCTION IF EXISTS    qgis_pkg.tr_del_bdg_thematic_surface CASCADE;
CREATE OR REPLACE FUNCTION qgis_pkg.tr_del_bdg_thematic_surface()
RETURNS trigger AS $$
DECLARE
  schema_name varchar := split_part(TG_TABLE_NAME, '_', 1);
BEGIN
EXECUTE format('PERFORM %I.del_thematic_surface(%L)', schema_name, OLD.id);
RETURN OLD;
EXCEPTION
  WHEN OTHERS THEN RAISE NOTICE 'qgis_pkg.tr_del_bdg_thematic_surface(id: %): %', OLD.id, SQLERRM;
END;
$$ LANGUAGE plpgsql;
COMMENT ON FUNCTION qgis_pkg.tr_del_bdg_thematic_surface IS 'Delete record in view *_thematic_surface_*';


--**************************************************************
--**************************************************************
----------------------------------------------------------------
-- Create trigger FUNCTION QGIS_PKG.TR_UPD_SOLITARY_VEGETAT_OBJECT
----------------------------------------------------------------
DROP FUNCTION IF EXISTS    qgis_pkg.tr_upd_solitary_vegetat_object CASCADE;
CREATE OR REPLACE FUNCTION qgis_pkg.tr_upd_solitary_vegetat_object()
RETURNS trigger AS $$
DECLARE
  obj_co      qgis_pkg.obj_cityobject;
  obj_svo     qgis_pkg.obj_solitary_vegetat_object; 
  schema_name varchar := split_part(TG_TABLE_NAME, '_', 1); 
BEGIN
obj_co.id                     := OLD.id;
obj_co.gmlid                  := NEW.gmlid;
obj_co.gmlid_codespace        := NEW.gmlid_codespace;
obj_co.name                   := NEW.name;
obj_co.name_codespace         := NEW.name_codespace;
obj_co.description            := NEW.description;
--obj_co.envelope               := NEW.envelope;
obj_co.creation_date          := NEW.creation_date;
obj_co.termination_date       := NEW.termination_date;
obj_co.relative_to_terrain    := NEW.relative_to_terrain;
obj_co.relative_to_water      := NEW.relative_to_water;
obj_co.last_modification_date := NEW.last_modification_date;
obj_co.updating_person        := NEW.updating_person;
obj_co.reason_for_update      := NEW.reason_for_update;
obj_co.lineage                := NEW.lineage;

obj_svo.id                  := OLD.id;
obj_svo.class               := NEW.class; 
obj_svo.class_codespace     := NEW.class_codespace; 
obj_svo.function            := array_to_string((SELECT array_agg(DISTINCT x) FROM unnest(NEW.function) AS t(x)), '--/\--');
obj_svo.function_codespace  := array_to_string((SELECT array_agg(DISTINCT x) FROM unnest(NEW.function_codespace) AS t(x)), '--/\--');
obj_svo.usage               := array_to_string((SELECT array_agg(DISTINCT x) FROM unnest(NEW.usage) AS t(x)), '--/\--');
obj_svo.usage_codespace     := array_to_string((SELECT array_agg(DISTINCT x) FROM unnest(NEW.usage_codespace) AS t(x)), '--/\--');
obj_svo.species             := NEW.species; 
obj_svo.species_codespace   := NEW.species_codespace; 
obj_svo.height              := NEW.height; 
obj_svo.height_unit         := NEW.height_unit; 
obj_svo.trunk_diameter      := NEW.trunk_diameter; 
obj_svo.trunk_diameter_unit := NEW.trunk_diameter_unit; 
obj_svo.crown_diameter      := NEW.crown_diameter; 
obj_svo.crown_diameter_unit := NEW.crown_diameter_unit;

PERFORM qgis_pkg.upd_solitary_vegetat_object_atts(obj_co, obj_svo, schema_name);

RETURN NEW;
EXCEPTION
  WHEN OTHERS THEN RAISE NOTICE 'qgis_pkg.tr_upd_solitary_vegetat_object(id: %): %', OLD.id, SQLERRM;
END;
$$ LANGUAGE plpgsql;
COMMENT ON FUNCTION qgis_pkg.tr_upd_solitary_vegetat_object IS 'Update record in view *_solitary_vegetat_object_*';

----------------------------------------------------------------
-- Create trigger FUNCTION QGIS_PKG.TR_INS_SOLITARY_VEGETAT_OBJECT
----------------------------------------------------------------
DROP FUNCTION IF EXISTS    qgis_pkg.tr_ins_solitary_vegetat_object CASCADE;
CREATE OR REPLACE FUNCTION qgis_pkg.tr_ins_solitary_vegetat_object()
RETURNS trigger AS $$
DECLARE
BEGIN
RAISE EXCEPTION 'You are not allowed to insert new records using the QGIS plugin';
RETURN NULL;
EXCEPTION
  WHEN OTHERS THEN RAISE NOTICE 'qgis_pkg.tr_ins_solitary_vegetat_object(): %', SQLERRM;
END;
$$ LANGUAGE plpgsql;
COMMENT ON FUNCTION qgis_pkg.tr_ins_solitary_vegetat_object IS '(Block) insert record in view *_solitary_vegetat_object_*';

----------------------------------------------------------------
-- Create trigger FUNCTION QGIS_PKG.TR_DEL_SOLITARY_VEGETAT_OBJECT
----------------------------------------------------------------
DROP FUNCTION IF EXISTS    qgis_pkg.tr_del_solitary_vegetat_object CASCADE;
CREATE OR REPLACE FUNCTION qgis_pkg.tr_del_solitary_vegetat_object()
RETURNS trigger AS $$
DECLARE
  schema_name varchar := split_part(TG_TABLE_NAME, '_', 1);
BEGIN
EXECUTE format('PERFORM %I.del_solitary_vegetat_object(%L)', schema_name, OLD.id);
RETURN OLD;
EXCEPTION
  WHEN OTHERS THEN RAISE NOTICE 'qgis_pkg.tr_del_solitary_vegetat_object(id: %): %', OLD.id, SQLERRM;
END;
$$ LANGUAGE plpgsql;
COMMENT ON FUNCTION qgis_pkg.tr_del_solitary_vegetat_object IS 'Delete record in view *_solitary_vegetat_object_*';


--**************************************************************
--**************************************************************
----------------------------------------------------------------
-- Create trigger FUNCTION QGIS_PKG.TR_UPD_RELIEF_FEATURE
----------------------------------------------------------------
DROP FUNCTION IF EXISTS    qgis_pkg.tr_upd_relief_feature CASCADE;
CREATE OR REPLACE FUNCTION qgis_pkg.tr_upd_relief_feature()
RETURNS trigger AS $$
DECLARE
  obj_co      qgis_pkg.obj_cityobject;
  obj_rf      qgis_pkg.obj_relief_feature; 
  schema_name varchar := split_part(TG_TABLE_NAME, '_', 1); 
BEGIN
obj_co.id                     := OLD.id;
obj_co.gmlid                  := NEW.gmlid;
obj_co.gmlid_codespace        := NEW.gmlid_codespace;
obj_co.name                   := NEW.name;
obj_co.name_codespace         := NEW.name_codespace;
obj_co.description            := NEW.description;
--obj_co.envelope               := NEW.envelope;
obj_co.creation_date          := NEW.creation_date;
obj_co.termination_date       := NEW.termination_date;
obj_co.relative_to_terrain    := NEW.relative_to_terrain;
obj_co.relative_to_water      := NEW.relative_to_water;
obj_co.last_modification_date := NEW.last_modification_date;
obj_co.updating_person        := NEW.updating_person;
obj_co.reason_for_update      := NEW.reason_for_update;
obj_co.lineage                := NEW.lineage;

obj_rf.id  := OLD.id;
obj_rf.lod := NEW.lod; 

PERFORM qgis_pkg.upd_relief_feature_atts(obj_co, obj_rf, schema_name);

RETURN NEW;
EXCEPTION
  WHEN OTHERS THEN RAISE NOTICE 'qgis_pkg.tr_upd_relief_feature(id: %): %', OLD.id, SQLERRM;
END;
$$ LANGUAGE plpgsql;
COMMENT ON FUNCTION qgis_pkg.tr_upd_relief_feature IS 'Update record in view *_relief_feature_*';

----------------------------------------------------------------
-- Create trigger FUNCTION QGIS_PKG.TR_INS_RELIEF_FEATURE
----------------------------------------------------------------
DROP FUNCTION IF EXISTS    qgis_pkg.tr_ins_relief_feature CASCADE;
CREATE OR REPLACE FUNCTION qgis_pkg.tr_ins_relief_feature()
RETURNS trigger AS $$
DECLARE
BEGIN
RAISE EXCEPTION 'You are not allowed to insert new records using the QGIS plugin';
RETURN NULL;
EXCEPTION
  WHEN OTHERS THEN RAISE NOTICE 'qgis_pkg.tr_ins_relief_feature(): %', SQLERRM;
END;
$$ LANGUAGE plpgsql;
COMMENT ON FUNCTION qgis_pkg.tr_ins_relief_feature IS '(Block) insert record in view *_relief_feature_*';

----------------------------------------------------------------
-- Create trigger FUNCTION QGIS_PKG.TR_DEL_RELIEF_FEATURE
----------------------------------------------------------------
DROP FUNCTION IF EXISTS    qgis_pkg.tr_del_relief_feature CASCADE;
CREATE OR REPLACE FUNCTION qgis_pkg.tr_del_relief_feature()
RETURNS trigger AS $$
DECLARE
  schema_name varchar := split_part(TG_TABLE_NAME, '_', 1);
BEGIN
EXECUTE format('PERFORM %I.del_relief_feature(%L)', schema_name, OLD.id);
RETURN OLD;
EXCEPTION
  WHEN OTHERS THEN RAISE NOTICE 'qgis_pkg.tr_del_relief_feature(id: %): %', OLD.id, SQLERRM;
END;
$$ LANGUAGE plpgsql;
COMMENT ON FUNCTION qgis_pkg.tr_del_relief_feature IS 'Delete record in view *_relief_feature_*';

--**************************************************************
--**************************************************************
----------------------------------------------------------------
-- Create trigger FUNCTION QGIS_PKG.TR_UPD_TIN_RELIEF
----------------------------------------------------------------
DROP FUNCTION IF EXISTS    qgis_pkg.tr_upd_tin_relief CASCADE;
CREATE OR REPLACE FUNCTION qgis_pkg.tr_upd_tin_relief()
RETURNS trigger AS $$
DECLARE
  obj_co      qgis_pkg.obj_cityobject;
  obj_rc      qgis_pkg.obj_relief_component; 
  obj_tr      qgis_pkg.obj_tin_relief; 
  schema_name varchar := split_part(TG_TABLE_NAME, '_', 1); 
BEGIN
obj_co.id                     := OLD.id;
obj_co.gmlid                  := NEW.gmlid;
obj_co.gmlid_codespace        := NEW.gmlid_codespace;
obj_co.name                   := NEW.name;
obj_co.name_codespace         := NEW.name_codespace;
obj_co.description            := NEW.description;
--obj_co.envelope               := NEW.envelope;
obj_co.creation_date          := NEW.creation_date;
obj_co.termination_date       := NEW.termination_date;
obj_co.relative_to_terrain    := NEW.relative_to_terrain;
obj_co.relative_to_water      := NEW.relative_to_water;
obj_co.last_modification_date := NEW.last_modification_date;
obj_co.updating_person        := NEW.updating_person;
obj_co.reason_for_update      := NEW.reason_for_update;
obj_co.lineage                := NEW.lineage;

obj_rc.id  := OLD.id;
obj_rc.lod := NEW.lod;

obj_tr.id              := OLD.id;
obj_tr.max_length      := NEW.max_length;
obj_tr.max_length_unit := NEW.max_length_unit; 

PERFORM qgis_pkg.upd_tin_relief_atts(obj_co, obj_rc, obj_tr, schema_name);

RETURN NEW;
EXCEPTION
  WHEN OTHERS THEN RAISE NOTICE 'qgis_pkg.tr_upd_tin_relief(id: %): %', OLD.id, SQLERRM;
END;
$$ LANGUAGE plpgsql;
COMMENT ON FUNCTION qgis_pkg.tr_upd_tin_relief IS 'Update record in view *_tin_relief_*';

----------------------------------------------------------------
-- Create trigger FUNCTION QGIS_PKG.TR_INS_TIN_RELIEF
----------------------------------------------------------------
DROP FUNCTION IF EXISTS    qgis_pkg.tr_ins_tin_relief CASCADE;
CREATE OR REPLACE FUNCTION qgis_pkg.tr_ins_tin_relief()
RETURNS trigger AS $$
DECLARE
BEGIN
RAISE EXCEPTION 'You are not allowed to insert new records using the QGIS plugin';
RETURN NULL;
EXCEPTION
  WHEN OTHERS THEN RAISE NOTICE 'qgis_pkg.tr_ins_tin_relief(): %', SQLERRM;
END;
$$ LANGUAGE plpgsql;
COMMENT ON FUNCTION qgis_pkg.tr_ins_tin_relief IS '(Block) insert record in view *_tin_relief_*';

----------------------------------------------------------------
-- Create trigger FUNCTION QGIS_PKG.TR_DEL_TIN_RELIEF
----------------------------------------------------------------
DROP FUNCTION IF EXISTS    qgis_pkg.tr_del_tin_relief CASCADE;
CREATE OR REPLACE FUNCTION qgis_pkg.tr_del_tin_relief()
RETURNS trigger AS $$
DECLARE
  schema_name varchar := split_part(TG_TABLE_NAME, '_', 1);
BEGIN
EXECUTE format('PERFORM %I.del_tin_relief(%L)', schema_name, OLD.id);
RETURN OLD;
EXCEPTION
  WHEN OTHERS THEN RAISE NOTICE 'qgis_pkg.tr_del_tin_relief(id: %): %', OLD.id, SQLERRM;
END;
$$ LANGUAGE plpgsql;
COMMENT ON FUNCTION qgis_pkg.tr_del_tin_relief IS 'Delete record in view *_tin_relief_*';



--**************************
DO $$
BEGIN
RAISE NOTICE 'Done';
END $$;
--**************************
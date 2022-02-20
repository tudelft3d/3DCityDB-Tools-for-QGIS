-- ****************************************************************************
-- ****************************************************************************
--
--
-- TABLE UPDATE FUNCTIONS, using objects (types)
--
--
-- ****************************************************************************
-- ****************************************************************************

DO $MAINBODY$
DECLARE
BEGIN

----------------------------------------------------------------
-- Create FUNCTION QGIS_PKG_DEV.UPD_T_CITYOBJECT
----------------------------------------------------------------
DROP FUNCTION IF EXISTS    qgis_pkg.upd_t_cityobject(qgis_pkg.obj_cityobject, varchar) CASCADE;
CREATE OR REPLACE FUNCTION qgis_pkg.upd_t_cityobject(
obj         qgis_pkg.obj_cityobject,
schema_name varchar
)
RETURNS bigint AS $$
DECLARE
  rel_2_ter_enum varchar[] := ARRAY['entirelyAboveTerrain', 'entirelyBelowTerrain', 'substantiallyAboveAndBelowTerrain', 'substantiallyAboveTerrain','substantiallyBelowTerrain'];
  rel_2_wat_enum varchar[] := ARRAY['entirelyAboveWaterSurface', 'entirelyBelowWaterSurface', 'substantiallyAboveAndBelowWaterSurface', 'substantiallyAboveWaterSurface', 'substantiallyBelowWaterSurface', 'temporarilyAboveAndBelowWaterSurface']::varchar;
  updated_id bigint;
BEGIN
-- checks
IF (obj.relative_to_terrain IS NOT NULL) AND NOT(obj.relative_to_terrain = ANY(rel_2_ter_enum)) THEN
  RAISE EXCEPTION 'relative_to_terrain value "%" must be either NULL or one of %', obj.relative_to_terrain, rel_2_ter_enum;
END IF;
IF (obj.relative_to_water IS NOT NULL) AND NOT(obj.relative_to_water = ANY(rel_2_wat_enum)) THEN
  RAISE EXCEPTION 'relative_to_water value "%" must be either NULL or one of %', obj.relative_to_water, rel_2_wat_enum;	
END IF;
IF obj.last_modification_date IS NULL THEN 
  obj.last_modification_date := clock_timestamp();
END IF;
IF obj.updating_person IS NULL THEN 
  obj.updating_person := current_user;
END IF;

EXECUTE format('
UPDATE %I.cityobject AS t SET
  gmlid                       = $1.gmlid,
  gmlid_codespace             = $1.gmlid_codespace,
  name                        = $1.name,
  name_codespace              = $1.name_codespace,
  description                 = $1.description,
  creation_date               = $1.creation_date,
  termination_date            = $1.termination_date,
  relative_to_terrain         = $1.relative_to_terrain,
  relative_to_water           = $1.relative_to_water,
  last_modification_date      = $1.last_modification_date,
  updating_person             = $1.updating_person,
  reason_for_update           = $1.reason_for_update,
  lineage                     = $1.lineage
WHERE t.id = $1.id RETURNING id', schema_name) INTO updated_id USING obj;

RETURN updated_id;
EXCEPTION
  WHEN OTHERS THEN RAISE NOTICE 'qgis_pkg.upd_t_cityobject(id: %): %', obj.id, SQLERRM;
END;
$$ LANGUAGE plpgsql;
COMMENT ON FUNCTION qgis_pkg.upd_t_cityobject(qgis_pkg.obj_cityobject, varchar) IS 'Update attributes of table CITYOBJECT';

----------------------------------------------------------------
-- Create FUNCTION QGIS_PKG_DEV.UPD_T_BUILDING
----------------------------------------------------------------
DROP FUNCTION IF EXISTS    qgis_pkg.upd_t_building(qgis_pkg.obj_building, varchar) CASCADE;
CREATE OR REPLACE FUNCTION qgis_pkg.upd_t_building(
obj         qgis_pkg.obj_building,
schema_name varchar
)
RETURNS bigint AS $$
DECLARE
  updated_id bigint;
BEGIN
-- checks
IF (obj.storeys_above_ground < 0) OR (obj.storeys_below_ground < 0) THEN
  RAISE EXCEPTION 'Number of storeys above (or below) ground must be a value >= 0';	
END IF;

EXECUTE format('
UPDATE %I.building AS t SET
  class                       = $1.class,
  class_codespace             = $1.class_codespace,
  function                    = $1.function,
  function_codespace          = $1.function_codespace,
  usage                       = $1.usage,
  usage_codespace             = $1.usage_codespace,
  year_of_construction        = $1.year_of_construction,
  year_of_demolition          = $1.year_of_demolition,
  roof_type                   = $1.roof_type,
  roof_type_codespace         = $1.roof_type_codespace,
  measured_height             = $1.measured_height,
  measured_height_unit        = $1.measured_height_unit,
  storeys_above_ground        = $1.storeys_above_ground,
  storeys_below_ground        = $1.storeys_below_ground,
  storey_heights_above_ground = $1.storey_heights_above_ground,
  storey_heights_ag_unit      = $1.storey_heights_ag_unit,
  storey_heights_below_ground = $1.storey_heights_below_ground,
  storey_heights_bg_unit      = $1.storey_heights_bg_unit
WHERE t.id = $1.id RETURNING id', schema_name) INTO updated_id USING obj;

RETURN updated_id;
EXCEPTION
  WHEN OTHERS THEN RAISE NOTICE 'qgis_pkg.upd_t_building(id: %): %', obj.id, SQLERRM;
END;
$$ LANGUAGE plpgsql;
COMMENT ON FUNCTION qgis_pkg.upd_t_building(qgis_pkg.obj_building, varchar) IS 'Update attributes of table BUILDING';

----------------------------------------------------------------
-- Create FUNCTION QGIS_PKG_DEV.UPD_T_BUILDING_INSTALLATION
----------------------------------------------------------------
DROP FUNCTION IF EXISTS    qgis_pkg.upd_t_building_installation(qgis_pkg.obj_building_installation, varchar) CASCADE;
CREATE OR REPLACE FUNCTION qgis_pkg.upd_t_building_installation(
obj         qgis_pkg.obj_building_installation,
schema_name varchar
)
RETURNS bigint AS $$
DECLARE
  updated_id bigint;
BEGIN
-- checks

EXECUTE format('
UPDATE %I.building_installation AS t SET
  class                       = $1.class,
  class_codespace             = $1.class_codespace,
  function                    = $1.function,
  function_codespace          = $1.function_codespace,
  usage                       = $1.usage,
  usage_codespace             = $1.usage_codespace
WHERE t.id = $1.id RETURNING id', schema_name) INTO updated_id USING obj;

RETURN updated_id;
EXCEPTION
  WHEN OTHERS THEN RAISE NOTICE 'qgis_pkg.upd_t_building_installation(id: %): %', obj.id, SQLERRM;
END;
$$ LANGUAGE plpgsql;
COMMENT ON FUNCTION qgis_pkg.upd_t_building_installation(qgis_pkg.obj_building_installation, varchar) IS 'Update attributes of table BUILDING_INSTALLATION';

----------------------------------------------------------------
-- Create FUNCTION QGIS_PKG_DEV.UPD_T_SOLITARY_VEGETAT_OBJECT
----------------------------------------------------------------
DROP FUNCTION IF EXISTS    qgis_pkg.upd_t_solitary_vegetat_object(qgis_pkg.obj_solitary_vegetat_object, varchar) CASCADE;
CREATE OR REPLACE FUNCTION qgis_pkg.upd_t_solitary_vegetat_object(
obj         qgis_pkg.obj_solitary_vegetat_object,
schema_name varchar
)
RETURNS bigint AS $$
DECLARE
  updated_id bigint;
BEGIN
-- checks

EXECUTE format('
UPDATE %I.solitary_vegetat_object AS t SET
  class               = $1.class, 
  class_codespace     = $1.class_codespace, 
  function            = $1.function, 
  function_codespace  = $1.function_codespace, 
  usage               = $1.usage, 
  usage_codespace     = $1.usage_codespace, 
  species             = $1.species, 
  species_codespace   = $1.species_codespace, 
  height              = $1.height, 
  height_unit         = $1.height_unit, 
  trunk_diameter      = $1.trunk_diameter, 
  trunk_diameter_unit = $1.trunk_diameter_unit, 
  crown_diameter      = $1.crown_diameter, 
  crown_diameter_unit = $1.crown_diameter_unit
WHERE t.id = $1.id RETURNING id', schema_name) INTO updated_id USING obj;

RETURN updated_id;
EXCEPTION
  WHEN OTHERS THEN RAISE NOTICE 'qgis_pkg.upd_t_solitary_vegetat_object(id: %): %', obj.id, SQLERRM;
END;
$$ LANGUAGE plpgsql;
COMMENT ON FUNCTION qgis_pkg.upd_t_solitary_vegetat_object(qgis_pkg.obj_solitary_vegetat_object, varchar) IS 'Update attributes of table SOLITARY_VEGETAT_OBJECT';

----------------------------------------------------------------
-- Create FUNCTION QGIS_PKG_DEV.UPD_T_RELIEF_FEATURE
----------------------------------------------------------------
DROP FUNCTION IF EXISTS    qgis_pkg.upd_t_relief_feature(qgis_pkg.obj_relief_feature, varchar) CASCADE;
CREATE OR REPLACE FUNCTION qgis_pkg.upd_t_relief_feature(
obj         qgis_pkg.obj_relief_feature,
schema_name varchar
)
RETURNS bigint AS $$
DECLARE
  lod_enum numeric[] := ARRAY[0,1,2,3,4];
  updated_id bigint;
BEGIN
-- enumeration checks
IF (obj.lod IS NULL) OR NOT(obj.lod = ANY(lod_enum)) THEN
  RAISE EXCEPTION 'Lod value % must be in interval [0..4]', obj.lod;
END IF;
 
EXECUTE format('
UPDATE %I.relief_feature AS t SET
  lod = $1.lod
WHERE t.id = $1.id RETURNING id', schema_name) INTO updated_id USING obj;

RETURN updated_id;
EXCEPTION
  WHEN OTHERS THEN RAISE NOTICE 'qgis_pkg.upd_t_relief_feature(id: %): %', obj.id, SQLERRM;
END;
$$ LANGUAGE plpgsql;
COMMENT ON FUNCTION qgis_pkg.upd_t_relief_feature(qgis_pkg.obj_relief_feature, varchar) IS 'Update attributes of table RELIEF_FEATURE';

----------------------------------------------------------------
-- Create FUNCTION QGIS_PKG_DEV.UPD_T_RELIEF_COMPONENT
----------------------------------------------------------------
DROP FUNCTION IF EXISTS    qgis_pkg.upd_t_relief_component(qgis_pkg.obj_relief_component, varchar) CASCADE;
CREATE OR REPLACE FUNCTION qgis_pkg.upd_t_relief_component(
obj         qgis_pkg.obj_relief_component,
schema_name varchar
)
RETURNS bigint AS $$
DECLARE
  lod_enum numeric[] := ARRAY[0,1,2,3,4];
  updated_id bigint;
BEGIN
-- checks
IF (obj.lod IS NULL) OR NOT(obj.lod = ANY(lod_enum)) THEN
  RAISE EXCEPTION 'Lod value % must be in interval [0..4]', obj.lod;
END IF;
 
EXECUTE format('
UPDATE %I.relief_component AS t SET
  lod = $1.lod
WHERE t.id = $1.id RETURNING id', schema_name) INTO updated_id USING obj;

RETURN updated_id;
EXCEPTION
  WHEN OTHERS THEN RAISE NOTICE 'qgis_pkg.upd_t_relief_component(id: %): %', obj.id, SQLERRM;
END;
$$ LANGUAGE plpgsql;
COMMENT ON FUNCTION qgis_pkg.upd_t_relief_component(qgis_pkg.obj_relief_component, varchar) IS 'Update attributes of table RELIEF_COMPONENT';

----------------------------------------------------------------
-- Create FUNCTION QGIS_PKG_DEV.UPD_T_TIN_RELIEF
----------------------------------------------------------------
DROP FUNCTION IF EXISTS    qgis_pkg.upd_t_tin_relief(qgis_pkg.obj_tin_relief, varchar) CASCADE;
CREATE OR REPLACE FUNCTION qgis_pkg.upd_t_tin_relief(
obj         qgis_pkg.obj_tin_relief,
schema_name varchar
)
RETURNS bigint AS $$
DECLARE
  updated_id bigint;
BEGIN
-- checks
 
EXECUTE format('
UPDATE %I.tin_relief AS t SET
  max_length      = $1.max_length,
  max_length_unit = $1.max_length_unit  
WHERE t.id = $1.id RETURNING id', schema_name) INTO updated_id USING obj;

RETURN updated_id;
EXCEPTION
  WHEN OTHERS THEN RAISE NOTICE 'qgis_pkg.upd_t_tin_relief(id: %): %', obj.id, SQLERRM;
END;
$$ LANGUAGE plpgsql;
COMMENT ON FUNCTION qgis_pkg.upd_t_tin_relief(qgis_pkg.obj_tin_relief, varchar) IS 'Update attributes of table TIN_RELIEF';

-- ***********************************************************************
-- ***********************************************************************




--**************************
RAISE NOTICE E'\n\nDone\n\n';
END $MAINBODY$;
--**************************
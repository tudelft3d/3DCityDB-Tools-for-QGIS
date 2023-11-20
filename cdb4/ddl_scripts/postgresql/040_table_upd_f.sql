-- ***********************************************************************
--
--      QGIS Package for the CityGML 3D City Database (for PostgreSQL)
--
--
--                        Copyright 2023
--
-- Delft University of Technology, The Netherlands
-- 3D Geoinformation Group
-- https://3d.bk.tudelft.nl/
-- 
-- Licensed under the Apache License, Version 2.0 (the "License");
-- you may not use this file except in compliance with the License.
-- You may obtain a copy of the License at
-- 
--     http://www.apache.org/licenses/LICENSE-2.0
--     
-- Unless required by applicable law or agreed to in writing, software
-- distributed under the License is distributed on an "AS IS" BASIS,
-- WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
-- See the License for the specific language governing permissions and
-- limitations under the License.
--
-- Author: Giorgio Agugiaro
-- Delft University of Technology, The Netherlands
-- 3D Geoinformation Group
-- https://3d.bk.tudelft.nl/gagugiaro/
--
-- ***********************************************************************
-- ***********************************************************************
--
--
-- This script installs update functions for the tables in a citydb schema.
-- BEWARE: Only "normal" attributes are updated: no geometries, no primary
-- keys, no foreign keys, etc.
-- These functions can be used with any cdb_schema inside the database.
-- In certain cases, some checks are carried out before the update
-- operation, e.g. on enumeration values.
--
--
-- ***********************************************************************

----------------------------------------------------------------
-- Create FUNCTION QGIS_PKG_DEV.UPD_T_ADDRESS
----------------------------------------------------------------
DROP FUNCTION IF EXISTS    qgis_pkg.upd_t_address(qgis_pkg.obj_address, varchar) CASCADE;
CREATE OR REPLACE FUNCTION qgis_pkg.upd_t_address(
obj         qgis_pkg.obj_address,
cdb_schema varchar
)
RETURNS bigint AS $$
DECLARE
  srid integer;
  updated_id bigint;
BEGIN
-- checks
IF obj.gmlid IS NULL THEN
	obj.gmlid := concat('Address_UUID_', uuid_generate_v4());
END IF;
IF obj.multi_point IS NOT NULL THEN
	EXECUTE format('SELECT t.srid FROM %I.database_srs AS t LIMIT 1', cdb_schema) INTO srid;
	IF (ST_SRID(obj.multi_point) IS NULL) OR (ST_SRID(obj.multi_point) <> srid) THEN
		RAISE EXCEPTION 'srid of (multi)point geometry % is not defined or wrong)', ST_AsEWKT(obj.multi_point);
	END IF;
	-- Ensure that geometry is cast in any case to a multi geometry. If it is already, nothing happens.
	obj.multi_point := ST_Multi(obj.multi_point);
	-- Check that it is indeed a point geometry
	IF ST_GeometryType(obj.multi_point) <> 'ST_MultiPoint' THEN
		RAISE EXCEPTION 'geometry type must be "ST_Multipoint", but is "%"', ST_GeometryType(obj.multi_point);
	END IF;
	-- Enforce 3D
	obj.multi_point := ST_Force3D(obj.multi_point);
END IF;

EXECUTE format('
UPDATE %I.address AS t SET
  gmlid           = $1.gmlid,
  gmlid_codespace = $1.gmlid_codespace,
  street          = $1.street,
  house_number    = $1.house_number,
  po_box          = $1.po_box,
  zip_code        = $1.zip_code,
  city            = $1.city,
  state           = $1.state,
  country         = $1.country,
  multi_point     = $1.multi_point,
  xal_source      = $1.xal_source 
WHERE t.id = $1.id RETURNING id', cdb_schema) INTO updated_id USING obj;

-- Take care of the xal_source??

RETURN updated_id;
EXCEPTION
  WHEN OTHERS THEN RAISE NOTICE 'qgis_pkg.upd_t_address(id: %): %', obj.id, SQLERRM;
END;
$$ LANGUAGE plpgsql;
COMMENT ON FUNCTION qgis_pkg.upd_t_address(qgis_pkg.obj_address, varchar) IS 'Update attributes of table ADDRESS';
REVOKE EXECUTE ON FUNCTION qgis_pkg.upd_t_address(qgis_pkg.obj_address, varchar) FROM public;

----------------------------------------------------------------
-- Create FUNCTION QGIS_PKG_DEV.UPD_T_APPEARANCE
----------------------------------------------------------------
DROP FUNCTION IF EXISTS    qgis_pkg.upd_t_appearance(qgis_pkg.obj_appearance, varchar) CASCADE;
CREATE OR REPLACE FUNCTION qgis_pkg.upd_t_appearance(
obj         qgis_pkg.obj_appearance,
cdb_schema varchar
)
RETURNS bigint AS $$
DECLARE
  updated_id bigint;
BEGIN
--checks

EXECUTE format('
UPDATE %I.appearance AS t SET
  gmlid           := $1.gmlid,
  gmlid_codespace := $1.gmlid_codespace,
  name            := $1.name,
  name_codespace  := $1.name_codespace,
  description     := $1.description,
  theme           := $1.theme
WHERE t.id = $1.id RETURNING id', cdb_schema) INTO updated_id USING obj;

RETURN updated_id;
EXCEPTION
  WHEN OTHERS THEN RAISE NOTICE 'qgis_pkg.upd_t_appearance(id: %): %', obj.id, SQLERRM;
END;
$$ LANGUAGE plpgsql;
COMMENT ON FUNCTION qgis_pkg.upd_t_appearance(qgis_pkg.obj_appearance, varchar) IS 'Update attributes of table APPEARANCE';
REVOKE EXECUTE ON FUNCTION qgis_pkg.upd_t_appearance(qgis_pkg.obj_appearance, varchar) FROM public;

----------------------------------------------------------------
-- Create FUNCTION QGIS_PKG_DEV.UPD_T_BREAKLINE_RELIEF
----------------------------------------------------------------
--no attributes to be updated


----------------------------------------------------------------
-- Create FUNCTION QGIS_PKG_DEV.UPD_T_BRIDGE
----------------------------------------------------------------
DROP FUNCTION IF EXISTS    qgis_pkg.upd_t_bridge(qgis_pkg.obj_bridge, varchar) CASCADE;
CREATE OR REPLACE FUNCTION qgis_pkg.upd_t_bridge(
obj         qgis_pkg.obj_bridge,
cdb_schema varchar
)
RETURNS bigint AS $$
DECLARE
  updated_id bigint;
BEGIN
-- checks
IF (obj.is_movable IS NOT NULL) AND (obj.is_movable NOT IN (0,1)) THEN
   RAISE EXCEPTION 'is_movable value "%" must be either NULL, 0, or 1', obj.is_movable; 
END IF; 

EXECUTE format('
UPDATE %I.bridge AS t SET
  class                       = $1.class,
  class_codespace             = $1.class_codespace,
  function                    = $1.function,
  function_codespace          = $1.function_codespace,
  usage                       = $1.usage,
  usage_codespace             = $1.usage_codespace,
  year_of_construction        = $1.year_of_construction,
  year_of_demolition          = $1.year_of_demolition,
  is_movable                  = $1.is_movable
WHERE t.id = $1.id RETURNING id', cdb_schema) INTO updated_id USING obj;

RETURN updated_id;
EXCEPTION
  WHEN OTHERS THEN RAISE NOTICE 'qgis_pkg.upd_t_bridge(id: %): %', obj.id, SQLERRM;
END;
$$ LANGUAGE plpgsql;
COMMENT ON FUNCTION qgis_pkg.upd_t_bridge(qgis_pkg.obj_bridge, varchar) IS 'Update attributes of table BRIDGE';
REVOKE EXECUTE ON FUNCTION qgis_pkg.upd_t_bridge(qgis_pkg.obj_bridge, varchar) FROM public;

----------------------------------------------------------------
-- Create FUNCTION QGIS_PKG_DEV.UPD_T_BRIDGE_CONSTR_ELEMENT
----------------------------------------------------------------
DROP FUNCTION IF EXISTS    qgis_pkg.upd_t_bridge_constr_element(qgis_pkg.obj_bridge_constr_element, varchar) CASCADE;
CREATE OR REPLACE FUNCTION qgis_pkg.upd_t_bridge_constr_element(
obj         qgis_pkg.obj_bridge_constr_element,
cdb_schema varchar
)
RETURNS bigint AS $$
DECLARE
  updated_id bigint;
BEGIN
-- checks

EXECUTE format('
UPDATE %I.bridge_constr_element AS t SET
  class                       = $1.class,
  class_codespace             = $1.class_codespace,
  function                    = $1.function,
  function_codespace          = $1.function_codespace,
  usage                       = $1.usage,
  usage_codespace             = $1.usage_codespace
WHERE t.id = $1.id RETURNING id', cdb_schema) INTO updated_id USING obj;

RETURN updated_id;
EXCEPTION
  WHEN OTHERS THEN RAISE NOTICE 'qgis_pkg.upd_t_bridge_constr_element(id: %): %', obj.id, SQLERRM;
END;
$$ LANGUAGE plpgsql;
COMMENT ON FUNCTION qgis_pkg.upd_t_bridge_constr_element(qgis_pkg.obj_bridge_constr_element, varchar) IS 'Update attributes of table BRIDGE_CONSTR_ELEMENT';
REVOKE EXECUTE ON FUNCTION qgis_pkg.upd_t_bridge_constr_element(qgis_pkg.obj_bridge_constr_element, varchar) FROM public;

----------------------------------------------------------------
-- Create FUNCTION QGIS_PKG_DEV.UPD_T_BRIDGE_FURNITURE
----------------------------------------------------------------
DROP FUNCTION IF EXISTS    qgis_pkg.upd_t_bridge_furniture(qgis_pkg.obj_bridge_furniture, varchar) CASCADE;
CREATE OR REPLACE FUNCTION qgis_pkg.upd_t_bridge_furniture(
obj         qgis_pkg.obj_bridge_furniture,
cdb_schema varchar
)
RETURNS bigint AS $$
DECLARE
  updated_id bigint;
BEGIN
-- checks

EXECUTE format('
UPDATE %I.bridge_furniture AS t SET
  class                       = $1.class,
  class_codespace             = $1.class_codespace,
  function                    = $1.function,
  function_codespace          = $1.function_codespace,
  usage                       = $1.usage,
  usage_codespace             = $1.usage_codespace
WHERE t.id = $1.id RETURNING id', cdb_schema) INTO updated_id USING obj;

RETURN updated_id;
EXCEPTION
  WHEN OTHERS THEN RAISE NOTICE 'qgis_pkg.upd_t_bridge_furniture(id: %): %', obj.id, SQLERRM;
END;
$$ LANGUAGE plpgsql;
COMMENT ON FUNCTION qgis_pkg.upd_t_bridge_furniture(qgis_pkg.obj_bridge_furniture, varchar) IS 'Update attributes of table BRIDGE_FURNITURE';
REVOKE EXECUTE ON FUNCTION qgis_pkg.upd_t_bridge_furniture(qgis_pkg.obj_bridge_furniture, varchar) FROM public;

----------------------------------------------------------------
-- Create FUNCTION QGIS_PKG_DEV.UPD_T_BRIDGE_INSTALLATION
----------------------------------------------------------------
DROP FUNCTION IF EXISTS    qgis_pkg.upd_t_bridge_installation(qgis_pkg.obj_bridge_installation, varchar) CASCADE;
CREATE OR REPLACE FUNCTION qgis_pkg.upd_t_bridge_installation(
obj         qgis_pkg.obj_bridge_installation,
cdb_schema varchar
)
RETURNS bigint AS $$
DECLARE
  updated_id bigint;
BEGIN
-- checks

EXECUTE format('
UPDATE %I.bridge_installation AS t SET
  class                       = $1.class,
  class_codespace             = $1.class_codespace,
  function                    = $1.function,
  function_codespace          = $1.function_codespace,
  usage                       = $1.usage,
  usage_codespace             = $1.usage_codespace
WHERE t.id = $1.id RETURNING id', cdb_schema) INTO updated_id USING obj;

RETURN updated_id;
EXCEPTION
  WHEN OTHERS THEN RAISE NOTICE 'qgis_pkg.upd_t_bridge_installation(id: %): %', obj.id, SQLERRM;
END;
$$ LANGUAGE plpgsql;
COMMENT ON FUNCTION qgis_pkg.upd_t_bridge_installation(qgis_pkg.obj_bridge_installation, varchar) IS 'Update attributes of table BRIDGE_INSTALLATION';
REVOKE EXECUTE ON FUNCTION qgis_pkg.upd_t_bridge_installation(qgis_pkg.obj_bridge_installation, varchar) FROM public;

----------------------------------------------------------------
-- Create FUNCTION QGIS_PKG_DEV.UPD_T_BRIDGE_OPENING
----------------------------------------------------------------
--no attributes to be updated

----------------------------------------------------------------
-- Create FUNCTION QGIS_PKG_DEV.UPD_T_BRIDGE_ROOM
----------------------------------------------------------------
DROP FUNCTION IF EXISTS    qgis_pkg.upd_t_bridge_room(qgis_pkg.obj_bridge_room, varchar) CASCADE;
CREATE OR REPLACE FUNCTION qgis_pkg.upd_t_bridge_room(
obj         qgis_pkg.obj_bridge_room,
cdb_schema varchar
)
RETURNS bigint AS $$
DECLARE
  updated_id bigint;
BEGIN
-- checks

EXECUTE format('
UPDATE %I.bridge_room AS t SET
  class                       = $1.class,
  class_codespace             = $1.class_codespace,
  function                    = $1.function,
  function_codespace          = $1.function_codespace,
  usage                       = $1.usage,
  usage_codespace             = $1.usage_codespace
WHERE t.id = $1.id RETURNING id', cdb_schema) INTO updated_id USING obj;

RETURN updated_id;
EXCEPTION
  WHEN OTHERS THEN RAISE NOTICE 'qgis_pkg.upd_t_bridge_room(id: %): %', obj.id, SQLERRM;
END;
$$ LANGUAGE plpgsql;
COMMENT ON FUNCTION qgis_pkg.upd_t_bridge_room(qgis_pkg.obj_bridge_room, varchar) IS 'Update attributes of table BRIDGE_ROOM';
REVOKE EXECUTE ON FUNCTION qgis_pkg.upd_t_bridge_room(qgis_pkg.obj_bridge_room, varchar) FROM public;

----------------------------------------------------------------
-- Create FUNCTION QGIS_PKG_DEV.UPD_T_BRIDGE_THEMATIC_SURFACE
----------------------------------------------------------------
--no attributes to be updated

----------------------------------------------------------------
-- Create FUNCTION QGIS_PKG_DEV.UPD_T_BUILDING
----------------------------------------------------------------
DROP FUNCTION IF EXISTS    qgis_pkg.upd_t_building(qgis_pkg.obj_building, varchar) CASCADE;
CREATE OR REPLACE FUNCTION qgis_pkg.upd_t_building(
obj         qgis_pkg.obj_building,
cdb_schema varchar
)
RETURNS bigint AS $$
DECLARE
  updated_id bigint;
BEGIN
-- checks
IF (obj.storeys_above_ground < 0) OR (obj.storeys_below_ground < 0) THEN
  RAISE EXCEPTION 'Number of storeys above (or below) ground must be an integer value >= 0';	
END IF;
IF ((obj.measured_height IS NOT NULL) AND (obj.measured_height_unit IS NULL)) OR
   ((obj.measured_height IS NULL) AND (obj.measured_height_unit IS NOT NULL)) THEN
   RAISE EXCEPTION 'Measure values (measured_height) must contain both number AND unit of measure';  
END IF;
IF ((obj.storey_heights_above_ground IS NOT NULL) AND (obj.storey_heights_ag_unit IS NULL)) OR
   ((obj.storey_heights_above_ground IS NULL) AND (obj.storey_heights_ag_unit IS NOT NULL)) THEN
   RAISE EXCEPTION 'Measure values (storey_heights_above_ground) must contain both number AND unit of measure';  
END IF;
IF ((obj.storey_heights_below_ground IS NOT NULL) AND (obj.storey_heights_bg_unit IS NULL)) OR
   ((obj.storey_heights_below_ground IS NULL) AND (obj.storey_heights_bg_unit IS NOT NULL)) THEN
   RAISE EXCEPTION 'Measure values (storey_heights_below_ground) must contain both number AND unit of measure';  
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
WHERE t.id = $1.id RETURNING id', cdb_schema) INTO updated_id USING obj;

RETURN updated_id;
EXCEPTION
  WHEN OTHERS THEN RAISE NOTICE 'qgis_pkg.upd_t_building(id: %): %', obj.id, SQLERRM;
END;
$$ LANGUAGE plpgsql;
COMMENT ON FUNCTION qgis_pkg.upd_t_building(qgis_pkg.obj_building, varchar) IS 'Update attributes of table BUILDING';
REVOKE EXECUTE ON FUNCTION qgis_pkg.upd_t_building(qgis_pkg.obj_building, varchar) FROM public;

----------------------------------------------------------------
-- Create FUNCTION QGIS_PKG_DEV.UPD_T_BUILDING_FURNITURE
----------------------------------------------------------------
DROP FUNCTION IF EXISTS    qgis_pkg.upd_t_building_furniture(qgis_pkg.obj_building_furniture, varchar) CASCADE;
CREATE OR REPLACE FUNCTION qgis_pkg.upd_t_building_furniture(
obj         qgis_pkg.obj_building_furniture,
cdb_schema varchar
)
RETURNS bigint AS $$
DECLARE
  updated_id bigint;
BEGIN
-- checks

EXECUTE format('
UPDATE %I.building_furniture AS t SET
  class                       = $1.class,
  class_codespace             = $1.class_codespace,
  function                    = $1.function,
  function_codespace          = $1.function_codespace,
  usage                       = $1.usage,
  usage_codespace             = $1.usage_codespace
WHERE t.id = $1.id RETURNING id', cdb_schema) INTO updated_id USING obj;

RETURN updated_id;
EXCEPTION
  WHEN OTHERS THEN RAISE NOTICE 'qgis_pkg.upd_t_building_furniture(id: %): %', obj.id, SQLERRM;
END;
$$ LANGUAGE plpgsql;
COMMENT ON FUNCTION qgis_pkg.upd_t_building_furniture(qgis_pkg.obj_building_furniture, varchar) IS 'Update attributes of table BUILDING_FURNITURE';
REVOKE EXECUTE ON FUNCTION qgis_pkg.upd_t_building_furniture(qgis_pkg.obj_building_furniture, varchar) FROM public;

----------------------------------------------------------------
-- Create FUNCTION QGIS_PKG_DEV.UPD_T_BUILDING_INSTALLATION
----------------------------------------------------------------
DROP FUNCTION IF EXISTS    qgis_pkg.upd_t_building_installation(qgis_pkg.obj_building_installation, varchar) CASCADE;
CREATE OR REPLACE FUNCTION qgis_pkg.upd_t_building_installation(
obj         qgis_pkg.obj_building_installation,
cdb_schema varchar
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
WHERE t.id = $1.id RETURNING id', cdb_schema) INTO updated_id USING obj;

RETURN updated_id;
EXCEPTION
  WHEN OTHERS THEN RAISE NOTICE 'qgis_pkg.upd_t_building_installation(id: %): %', obj.id, SQLERRM;
END;
$$ LANGUAGE plpgsql;
COMMENT ON FUNCTION qgis_pkg.upd_t_building_installation(qgis_pkg.obj_building_installation, varchar) IS 'Update attributes of table BUILDING_INSTALLATION';
REVOKE EXECUTE ON FUNCTION qgis_pkg.upd_t_building_installation(qgis_pkg.obj_building_installation, varchar) FROM public;

----------------------------------------------------------------
-- Create FUNCTION QGIS_PKG_DEV.UPD_T_CITY_FURNITURE
----------------------------------------------------------------
DROP FUNCTION IF EXISTS    qgis_pkg.upd_t_city_furniture(qgis_pkg.obj_city_furniture, varchar) CASCADE;
CREATE OR REPLACE FUNCTION qgis_pkg.upd_t_city_furniture(
obj         qgis_pkg.obj_city_furniture,
cdb_schema varchar
)
RETURNS bigint AS $$
DECLARE
  updated_id bigint;
BEGIN
-- checks

EXECUTE format('
UPDATE %I.city_furniture AS t SET
  class                       = $1.class,
  class_codespace             = $1.class_codespace,
  function                    = $1.function,
  function_codespace          = $1.function_codespace,
  usage                       = $1.usage,
  usage_codespace             = $1.usage_codespace
WHERE t.id = $1.id RETURNING id', cdb_schema) INTO updated_id USING obj;

RETURN updated_id;
EXCEPTION
  WHEN OTHERS THEN RAISE NOTICE 'qgis_pkg.upd_t_city_furniture(id: %): %', obj.id, SQLERRM;
END;
$$ LANGUAGE plpgsql;
COMMENT ON FUNCTION qgis_pkg.upd_t_city_furniture(qgis_pkg.obj_city_furniture, varchar) IS 'Update attributes of table CITY_FURNITURE';
REVOKE EXECUTE ON FUNCTION qgis_pkg.upd_t_city_furniture(qgis_pkg.obj_city_furniture, varchar) FROM public;

----------------------------------------------------------------
-- Create FUNCTION QGIS_PKG_DEV.UPD_T_CITYMODEL
----------------------------------------------------------------
DROP FUNCTION IF EXISTS    qgis_pkg.upd_t_citymodel(qgis_pkg.obj_citymodel, varchar) CASCADE;
CREATE OR REPLACE FUNCTION qgis_pkg.upd_t_citymodel(
obj         qgis_pkg.obj_citymodel,
cdb_schema  varchar
)
RETURNS bigint AS $$
DECLARE
  updated_id bigint;
BEGIN
-- checks
IF obj.last_modification_date IS NULL THEN 
  obj.last_modification_date := clock_timestamp();
END IF;
IF obj.updating_person IS NULL THEN 
  obj.updating_person := current_user;
END IF;

EXECUTE format('
UPDATE %I.citymodel AS t SET
  gmlid                       = $1.gmlid,
  gmlid_codespace             = $1.gmlid_codespace,
  name                        = $1.name,
  name_codespace              = $1.name_codespace,
  description                 = $1.description,
  creation_date               = $1.creation_date,
  termination_date            = $1.termination_date,
  last_modification_date      = $1.last_modification_date,
  updating_person             = $1.updating_person,
  reason_for_update           = $1.reason_for_update,
  lineage                     = $1.lineage
WHERE t.id = $1.id RETURNING id', cdb_schema) INTO updated_id USING obj;

RETURN updated_id;
EXCEPTION
  WHEN OTHERS THEN RAISE NOTICE 'qgis_pkg.upd_t_citymodel(id: %): %', obj.id, SQLERRM;
END;
$$ LANGUAGE plpgsql;
COMMENT ON FUNCTION qgis_pkg.upd_t_citymodel(qgis_pkg.obj_citymodel, varchar) IS 'Update attributes of table CITYMODEL';
REVOKE EXECUTE ON FUNCTION qgis_pkg.upd_t_citymodel(qgis_pkg.obj_citymodel, varchar) FROM public;

----------------------------------------------------------------
-- Create FUNCTION QGIS_PKG_DEV.UPD_T_CITYOBJECT
----------------------------------------------------------------
DROP FUNCTION IF EXISTS    qgis_pkg.upd_t_cityobject(qgis_pkg.obj_cityobject, varchar) CASCADE;
CREATE OR REPLACE FUNCTION qgis_pkg.upd_t_cityobject(
obj         qgis_pkg.obj_cityobject,
cdb_schema varchar
)
RETURNS bigint AS $$
DECLARE
  rel_2_ter_enum varchar[] := ARRAY['entirelyAboveTerrain', 'entirelyBelowTerrain', 'substantiallyAboveAndBelowTerrain', 'substantiallyAboveTerrain','substantiallyBelowTerrain'];
  rel_2_wat_enum varchar[] := ARRAY['entirelyAboveWaterSurface', 'entirelyBelowWaterSurface', 'substantiallyAboveAndBelowWaterSurface', 'substantiallyAboveWaterSurface', 'substantiallyBelowWaterSurface', 'temporarilyAboveAndBelowWaterSurface'];
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
WHERE t.id = $1.id RETURNING id', cdb_schema) INTO updated_id USING obj;

RETURN updated_id;
EXCEPTION
  WHEN OTHERS THEN RAISE NOTICE 'qgis_pkg.upd_t_cityobject(id: %): %', obj.id, SQLERRM;
END;
$$ LANGUAGE plpgsql;
COMMENT ON FUNCTION qgis_pkg.upd_t_cityobject(qgis_pkg.obj_cityobject, varchar) IS 'Update attributes of table CITYOBJECT';
REVOKE EXECUTE ON FUNCTION qgis_pkg.upd_t_cityobject(qgis_pkg.obj_cityobject, varchar) FROM public;

----------------------------------------------------------------
-- Create FUNCTION QGIS_PKG_DEV.UPD_T_CITYOBJECT_GENERICATTRIB
----------------------------------------------------------------
DROP FUNCTION IF EXISTS    qgis_pkg.upd_t_cityobject_genericattrib(qgis_pkg.obj_cityobject_genericattrib, varchar) CASCADE;
CREATE OR REPLACE FUNCTION qgis_pkg.upd_t_cityobject_genericattrib(
obj         qgis_pkg.obj_cityobject_genericattrib,
cdb_schema varchar
)
RETURNS bigint AS $$
DECLARE
  datatype_enum integer[] := ARRAY[1,2,3,4,5,6,7,8,9,10];
  updated_id bigint;
BEGIN
-- checks
IF obj.attrname IS NULL THEN
  RAISE EXCEPTION 'attrname value must be NOT NULL';
END IF;
IF (obj.datatype IS NULL) OR NOT(obj.datatype = ANY(datatype_enum)) THEN
  RAISE EXCEPTION 'datatype value must be NOT NULL or one of %', datatype_enum;
END IF;

-- update query omitting all PK, FK and geometry columns)
EXECUTE format('
UPDATE %I.cityobject_genericattrib AS t SET
  attrname               = $1.attrname,
  datatype               = $1.datatype,
  strval                 = $1.strval,
  intval                 = $1.intval,
  realval                = $1.realval,
  urival                 = $1.urival,
  dateval                = $1.dateval,
  unit                   = $1.unit,
  genattribset_codespace = $1.genattribset_codespace,
  blobval                = $1.blobval
WHERE t.id = $1.id RETURNING id', cdb_schema) INTO updated_id USING obj;

RETURN updated_id;
EXCEPTION
  WHEN OTHERS THEN RAISE NOTICE 'qgis_pkg.upd_t_cityobject_genericattrib(id: %): %', obj.id, SQLERRM;
END;
$$ LANGUAGE plpgsql;
COMMENT ON FUNCTION qgis_pkg.upd_t_cityobject_genericattrib(qgis_pkg.obj_cityobject_genericattrib, varchar) IS 'Update attributes of table CITYOBJECT_GENERICATTRIB';
REVOKE EXECUTE ON FUNCTION qgis_pkg.upd_t_cityobject_genericattrib(qgis_pkg.obj_cityobject_genericattrib, varchar) FROM public;

----------------------------------------------------------------
-- Create FUNCTION QGIS_PKG_DEV.UPD_T_CITYOBJECTGROUP
----------------------------------------------------------------
DROP FUNCTION IF EXISTS    qgis_pkg.upd_t_cityobjectgroup(qgis_pkg.obj_cityobjectgroup, varchar) CASCADE;
CREATE OR REPLACE FUNCTION qgis_pkg.upd_t_cityobjectgroup(
obj         qgis_pkg.obj_cityobjectgroup,
cdb_schema varchar
)
RETURNS bigint AS $$
DECLARE
  updated_id bigint;
BEGIN
-- checks

EXECUTE format('
UPDATE %I.cityobjectgroup AS t SET
  class                       = $1.class,
  class_codespace             = $1.class_codespace,
  function                    = $1.function,
  function_codespace          = $1.function_codespace,
  usage                       = $1.usage,
  usage_codespace             = $1.usage_codespace
WHERE t.id = $1.id RETURNING id', cdb_schema) INTO updated_id USING obj;

RETURN updated_id;
EXCEPTION
  WHEN OTHERS THEN RAISE NOTICE 'qgis_pkg.upd_t_cityobjectgroup(id: %): %', obj.id, SQLERRM;
END;
$$ LANGUAGE plpgsql;
COMMENT ON FUNCTION qgis_pkg.upd_t_cityobjectgroup(qgis_pkg.obj_cityobjectgroup, varchar) IS 'Update attributes of table CITYOBJECTGROUP';
REVOKE EXECUTE ON FUNCTION qgis_pkg.upd_t_cityobjectgroup(qgis_pkg.obj_cityobjectgroup, varchar) FROM public;

----------------------------------------------------------------
-- Create FUNCTION QGIS_PKG_DEV.UPD_T_EXTERNAL_REFERENCE
----------------------------------------------------------------
DROP FUNCTION IF EXISTS    qgis_pkg.upd_t_external_reference(qgis_pkg.obj_external_reference, varchar) CASCADE;
CREATE OR REPLACE FUNCTION qgis_pkg.upd_t_external_reference(
obj         qgis_pkg.obj_external_reference,
cdb_schema varchar
)
RETURNS bigint AS $$
DECLARE
  updated_id bigint;
BEGIN
-- checks
IF ((obj.name IS NOT NULL) AND (obj.uri IS NOT NULL)) THEN
   RAISE EXCEPTION 'Either value of name "%" or uri "%" are allowed at the same time', obj.name, obj.uri;
END IF;
IF ((obj.name IS NULL) AND (obj.uri IS NULL)) THEN
   RAISE EXCEPTION 'At least one of name or uri values must be provided';
END IF;

EXECUTE format('
UPDATE %I.external_reference AS t SET
  infosys       = $1.infosys,
  name          = $1.name,
  uri           = $1.uri
WHERE t.id = $1.id RETURNING id', cdb_schema) INTO updated_id USING obj;

RETURN updated_id;
EXCEPTION
  WHEN OTHERS THEN RAISE NOTICE 'qgis_pkg.upd_t_external_reference(id: %): %', obj.id, SQLERRM;
END;
$$ LANGUAGE plpgsql;
COMMENT ON FUNCTION qgis_pkg.upd_t_external_reference(qgis_pkg.obj_external_reference, varchar) IS 'Update attributes of table EXTERNAL_REFERENCE';
REVOKE EXECUTE ON FUNCTION qgis_pkg.upd_t_external_reference(qgis_pkg.obj_external_reference, varchar) FROM public;

----------------------------------------------------------------
-- Create FUNCTION QGIS_PKG_DEV.UPD_T_GENERIC_CITYOBJECT
----------------------------------------------------------------
DROP FUNCTION IF EXISTS    qgis_pkg.upd_t_generic_cityobject(qgis_pkg.obj_generic_cityobject, varchar) CASCADE;
CREATE OR REPLACE FUNCTION qgis_pkg.upd_t_generic_cityobject(
obj         qgis_pkg.obj_generic_cityobject,
cdb_schema varchar
)
RETURNS bigint AS $$
DECLARE
  updated_id bigint;
BEGIN
-- checks

EXECUTE format('
UPDATE %I.generic_cityobject AS t SET
  class                       = $1.class,
  class_codespace             = $1.class_codespace,
  function                    = $1.function,
  function_codespace          = $1.function_codespace,
  usage                       = $1.usage,
  usage_codespace             = $1.usage_codespace
WHERE t.id = $1.id RETURNING id', cdb_schema) INTO updated_id USING obj;

RETURN updated_id;
EXCEPTION
  WHEN OTHERS THEN RAISE NOTICE 'qgis_pkg.upd_t_generic_cityobject(id: %): %', obj.id, SQLERRM;
END;
$$ LANGUAGE plpgsql;
COMMENT ON FUNCTION qgis_pkg.upd_t_generic_cityobject(qgis_pkg.obj_generic_cityobject, varchar) IS 'Update attributes of table GENERIC_CITYOBJECT';
REVOKE EXECUTE ON FUNCTION  qgis_pkg.upd_t_generic_cityobject(qgis_pkg.obj_generic_cityobject, varchar) FROM public;

----------------------------------------------------------------
-- Create FUNCTION QGIS_PKG_DEV.UPD_T_GRID_COVERAGE
----------------------------------------------------------------
--no attributes to be updated

/*
----------------------------------------------------------------
-- Create FUNCTION QGIS_PKG_DEV.UPD_T_IMPLICIT_GEOMETRY
----------------------------------------------------------------
DROP FUNCTION IF EXISTS    qgis_pkg.upd_t_implicit_geometry(qgis_pkg.obj_implicit_geometry, varchar) CASCADE;
CREATE OR REPLACE FUNCTION qgis_pkg.upd_t_implicit_geometry(
obj         qgis_pkg.obj_implicit_geometry,
cdb_schema varchar
)
RETURNS bigint AS $$
DECLARE
-- enumerations: mime type
  updated_id bigint;
BEGIN
-- checks

-- update query omitting all PK, FK and geometry columns)
EXECUTE format('
UPDATE %I.implicit_geometry AS t SET
  mime_type            := $1.mime_type,
  reference_to_library := $1.reference_to_library,
  library_object       := $1.library_object
WHERE t.id = $1.id RETURNING id', cdb_schema) INTO updated_id USING obj;

RETURN updated_id;
EXCEPTION
  WHEN OTHERS THEN RAISE NOTICE 'qgis_pkg.upd_t_implicit_geometry(id: %): %', obj.id, SQLERRM;
END;
$$ LANGUAGE plpgsql;
COMMENT ON FUNCTION qgis_pkg.upd_t_implicit_geometry(qgis_pkg.obj_implicit_geometry, varchar) IS 'Update attributes of table IMPLICIT_GEOMETRY';
REVOKE EXECUTE ON FUNCTION  qgis_pkg.upd_t_implicit_geometry(qgis_pkg.obj_implicit_geometry, varchar) FROM public;
*/

----------------------------------------------------------------
-- Create FUNCTION QGIS_PKG_DEV.UPD_T_LAND_USE
----------------------------------------------------------------
DROP FUNCTION IF EXISTS    qgis_pkg.upd_t_land_use(qgis_pkg.obj_land_use, varchar) CASCADE;
CREATE OR REPLACE FUNCTION qgis_pkg.upd_t_land_use(
obj         qgis_pkg.obj_land_use,
cdb_schema varchar
)
RETURNS bigint AS $$
DECLARE
  updated_id bigint;
BEGIN
-- checks

EXECUTE format('
UPDATE %I.land_use AS t SET
  class                       = $1.class,
  class_codespace             = $1.class_codespace,
  function                    = $1.function,
  function_codespace          = $1.function_codespace,
  usage                       = $1.usage,
  usage_codespace             = $1.usage_codespace
WHERE t.id = $1.id RETURNING id', cdb_schema) INTO updated_id USING obj;

RETURN updated_id;
EXCEPTION
  WHEN OTHERS THEN RAISE NOTICE 'qgis_pkg.upd_t_land_use(id: %): %', obj.id, SQLERRM;
END;
$$ LANGUAGE plpgsql;
COMMENT ON FUNCTION qgis_pkg.upd_t_land_use(qgis_pkg.obj_land_use, varchar) IS 'Update attributes of table LAND_USE';
REVOKE EXECUTE ON FUNCTION  qgis_pkg.upd_t_land_use(qgis_pkg.obj_land_use, varchar) FROM public;

----------------------------------------------------------------
-- Create FUNCTION QGIS_PKG_DEV.UPD_T_MASSPOINT_RELIEF
----------------------------------------------------------------
--no attributes to be updated

----------------------------------------------------------------
-- Create FUNCTION QGIS_PKG_DEV.UPD_T_OPENING
----------------------------------------------------------------
--no attributes to be updated

----------------------------------------------------------------
-- Create FUNCTION QGIS_PKG_DEV.UPD_T_SOLITARY_VEGETAT_OBJECT
----------------------------------------------------------------
DROP FUNCTION IF EXISTS    qgis_pkg.upd_t_plant_cover(qgis_pkg.obj_plant_cover, varchar) CASCADE;
CREATE OR REPLACE FUNCTION qgis_pkg.upd_t_plant_cover(
obj         qgis_pkg.obj_plant_cover,
cdb_schema varchar
)
RETURNS bigint AS $$
DECLARE
  updated_id bigint;
BEGIN
-- checks
IF ((obj.average_height IS NOT NULL) AND (obj.average_height_unit IS NULL)) OR
   ((obj.average_height IS NULL) AND (obj.average_height_unit IS NOT NULL)) THEN
   RAISE EXCEPTION 'Measure values (average_height) must contain both number AND unit of measure';  
END IF;


EXECUTE format('
UPDATE %I.plant_cover AS t SET
  class               = $1.class, 
  class_codespace     = $1.class_codespace, 
  function            = $1.function, 
  function_codespace  = $1.function_codespace, 
  usage               = $1.usage, 
  usage_codespace     = $1.usage_codespace, 
  height              = $1.average_height, 
  height_unit         = $1.average_height_unit
WHERE t.id = $1.id RETURNING id', cdb_schema) INTO updated_id USING obj;

RETURN updated_id;
EXCEPTION
  WHEN OTHERS THEN RAISE NOTICE 'qgis_pkg.upd_t_plant_cover(id: %): %', obj.id, SQLERRM;
END;
$$ LANGUAGE plpgsql;
COMMENT ON FUNCTION qgis_pkg.upd_t_plant_cover(qgis_pkg.obj_plant_cover, varchar) IS 'Update attributes of table SOLITARY_VEGETAT_OBJECT';
REVOKE EXECUTE ON FUNCTION  qgis_pkg.upd_t_plant_cover(qgis_pkg.obj_plant_cover, varchar) FROM public;

----------------------------------------------------------------
-- Create FUNCTION QGIS_PKG_DEV.UPD_T_RASTER_RELIEF
----------------------------------------------------------------
DROP FUNCTION IF EXISTS    qgis_pkg.upd_t_raster_relief(qgis_pkg.obj_raster_relief, varchar) CASCADE;
CREATE OR REPLACE FUNCTION qgis_pkg.upd_t_raster_relief(
obj         qgis_pkg.obj_raster_relief,
cdb_schema varchar
)
RETURNS bigint AS $$
DECLARE
  updated_id bigint;
BEGIN
-- checks

-- update query omitting all PK, FK and geometry columns)
EXECUTE format('
UPDATE %I.raster_relief AS t SET
  raster_uri  = $1.raster_uri
WHERE t.id = $1.id RETURNING id', cdb_schema) INTO updated_id USING obj;

RETURN updated_id;
EXCEPTION
  WHEN OTHERS THEN RAISE NOTICE 'qgis_pkg.upd_t_raster_relief(id: %): %', obj.id, SQLERRM;
END;
$$ LANGUAGE plpgsql;
COMMENT ON FUNCTION qgis_pkg.upd_t_raster_relief(qgis_pkg.obj_raster_relief, varchar) IS 'Update attributes of table RASTER_RELIEF';
REVOKE EXECUTE ON FUNCTION  qgis_pkg.upd_t_raster_relief(qgis_pkg.obj_raster_relief, varchar) FROM public;

----------------------------------------------------------------
-- Create FUNCTION QGIS_PKG_DEV.UPD_T_RELIEF_COMPONENT
----------------------------------------------------------------
DROP FUNCTION IF EXISTS    qgis_pkg.upd_t_relief_component(qgis_pkg.obj_relief_component, varchar) CASCADE;
CREATE OR REPLACE FUNCTION qgis_pkg.upd_t_relief_component(
obj         qgis_pkg.obj_relief_component,
cdb_schema varchar
)
RETURNS bigint AS $$
DECLARE
  lod_enum numeric[] := ARRAY[0,1,2,3,4];  -- This is numeric as the column in the table is numeric (oddly)
  updated_id bigint;
BEGIN
-- checks
IF (obj.lod IS NULL) OR NOT(obj.lod = ANY(lod_enum)) THEN
  RAISE EXCEPTION 'Lod value % must be in interval [0..4]', obj.lod;
END IF;
 
EXECUTE format('
UPDATE %I.relief_component AS t SET
  lod = $1.lod
WHERE t.id = $1.id RETURNING id', cdb_schema) INTO updated_id USING obj;

RETURN updated_id;
EXCEPTION
  WHEN OTHERS THEN RAISE NOTICE 'qgis_pkg.upd_t_relief_component(id: %): %', obj.id, SQLERRM;
END;
$$ LANGUAGE plpgsql;
COMMENT ON FUNCTION qgis_pkg.upd_t_relief_component(qgis_pkg.obj_relief_component, varchar) IS 'Update attributes of table RELIEF_COMPONENT';
REVOKE EXECUTE ON FUNCTION  qgis_pkg.upd_t_relief_component(qgis_pkg.obj_relief_component, varchar) FROM public;

----------------------------------------------------------------
-- Create FUNCTION QGIS_PKG_DEV.UPD_T_RELIEF_FEATURE
----------------------------------------------------------------
DROP FUNCTION IF EXISTS    qgis_pkg.upd_t_relief_feature(qgis_pkg.obj_relief_feature, varchar) CASCADE;
CREATE OR REPLACE FUNCTION qgis_pkg.upd_t_relief_feature(
obj         qgis_pkg.obj_relief_feature,
cdb_schema varchar
)
RETURNS bigint AS $$
DECLARE
  lod_enum numeric[] := ARRAY[0,1,2,3,4]; -- This is numeric as the column in the table is numeric (oddly)
  updated_id bigint;
BEGIN
-- checks
IF (obj.lod IS NULL) OR NOT(obj.lod = ANY(lod_enum)) THEN
  RAISE EXCEPTION 'Lod value % must be in interval [0..4]', obj.lod;
END IF;
 
EXECUTE format('
UPDATE %I.relief_feature AS t SET
  lod = $1.lod
WHERE t.id = $1.id RETURNING id', cdb_schema) INTO updated_id USING obj;

RETURN updated_id;
EXCEPTION
  WHEN OTHERS THEN RAISE NOTICE 'qgis_pkg.upd_t_relief_feature(id: %): %', obj.id, SQLERRM;
END;
$$ LANGUAGE plpgsql;
COMMENT ON FUNCTION qgis_pkg.upd_t_relief_feature(qgis_pkg.obj_relief_feature, varchar) IS 'Update attributes of table RELIEF_FEATURE';
REVOKE EXECUTE ON FUNCTION  qgis_pkg.upd_t_relief_feature(qgis_pkg.obj_relief_feature, varchar) FROM public;

----------------------------------------------------------------
-- Create FUNCTION QGIS_PKG_DEV.UPD_T_ROOM
----------------------------------------------------------------
DROP FUNCTION IF EXISTS    qgis_pkg.upd_t_room(qgis_pkg.obj_room, varchar) CASCADE;
CREATE OR REPLACE FUNCTION qgis_pkg.upd_t_room(
obj         qgis_pkg.obj_room,
cdb_schema varchar
)
RETURNS bigint AS $$
DECLARE
  updated_id bigint;
BEGIN

EXECUTE format('
UPDATE %I.room AS t SET
  class                       = $1.class,
  class_codespace             = $1.class_codespace,
  function                    = $1.function,
  function_codespace          = $1.function_codespace,
  usage                       = $1.usage,
  usage_codespace             = $1.usage_codespace
WHERE t.id = $1.id RETURNING id', cdb_schema) INTO updated_id USING obj;

RETURN updated_id;
EXCEPTION
  WHEN OTHERS THEN RAISE NOTICE 'qgis_pkg.upd_t_room(id: %): %', obj.id, SQLERRM;
END;
$$ LANGUAGE plpgsql;
COMMENT ON FUNCTION qgis_pkg.upd_t_room(qgis_pkg.obj_room, varchar) IS 'Update attributes of table ROOM';
REVOKE EXECUTE ON FUNCTION  qgis_pkg.upd_t_room(qgis_pkg.obj_room, varchar) FROM public;

----------------------------------------------------------------
-- Create FUNCTION QGIS_PKG_DEV.UPD_T_SOLITARY_VEGETAT_OBJECT
----------------------------------------------------------------
DROP FUNCTION IF EXISTS    qgis_pkg.upd_t_solitary_vegetat_object(qgis_pkg.obj_solitary_vegetat_object, varchar) CASCADE;
CREATE OR REPLACE FUNCTION qgis_pkg.upd_t_solitary_vegetat_object(
obj         qgis_pkg.obj_solitary_vegetat_object,
cdb_schema varchar
)
RETURNS bigint AS $$
DECLARE
  updated_id bigint;
BEGIN
-- checks
IF ((obj.height IS NOT NULL) AND (obj.height_unit IS NULL)) OR
   ((obj.height IS NULL) AND (obj.height_unit IS NOT NULL)) THEN
   RAISE EXCEPTION 'Measure values (height) must contain both number AND unit of measure';  
END IF;
IF ((obj.trunk_diameter IS NOT NULL) AND (obj.trunk_diameter_unit IS NULL)) OR
   ((obj.trunk_diameter IS NULL) AND (obj.trunk_diameter_unit IS NOT NULL)) THEN
   RAISE EXCEPTION 'Measure values (trunk_diameter) must contain both number AND unit of measure';  
END IF;
IF ((obj.crown_diameter IS NOT NULL) AND (obj.crown_diameter_unit IS NULL)) OR
   ((obj.crown_diameter IS NULL) AND (obj.crown_diameter_unit IS NOT NULL)) THEN
   RAISE EXCEPTION 'Measure values (crown_diameter) must contain both number AND unit of measure';  
END IF;

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
WHERE t.id = $1.id RETURNING id', cdb_schema) INTO updated_id USING obj;

RETURN updated_id;
EXCEPTION
  WHEN OTHERS THEN RAISE NOTICE 'qgis_pkg.upd_t_solitary_vegetat_object(id: %): %', obj.id, SQLERRM;
END;
$$ LANGUAGE plpgsql;
COMMENT ON FUNCTION qgis_pkg.upd_t_solitary_vegetat_object(qgis_pkg.obj_solitary_vegetat_object, varchar) IS 'Update attributes of table SOLITARY_VEGETAT_OBJECT';
REVOKE EXECUTE ON FUNCTION  qgis_pkg.upd_t_solitary_vegetat_object(qgis_pkg.obj_solitary_vegetat_object, varchar) FROM public;

----------------------------------------------------------------
-- Create FUNCTION QGIS_PKG_DEV.UPD_T_SURFACE_DATA
----------------------------------------------------------------
DROP FUNCTION IF EXISTS    qgis_pkg.upd_t_surface_data(qgis_pkg.obj_surface_data, varchar) CASCADE;
CREATE OR REPLACE FUNCTION qgis_pkg.upd_t_surface_data(
obj         qgis_pkg.obj_surface_data,
cdb_schema varchar
)
RETURNS bigint AS $$
DECLARE
-- enumerations: texture type? wrap mode?
  updated_id bigint;
BEGIN
-- checks
-- check for boolean values to be 0 or 1?

EXECUTE format('
UPDATE %I.surface_data AS t SET
  gmlid                 := $1.gmlid,
  gmlid_codespace       := $1.gmlid_codespace,
  name                  := $1.name,
  name_codespace        := $1.name_codespace,
  description           := $1.description,
  is_front              := $1.is_front,
  x3d_shininess         := $1.x3d_shininess,
  x3d_transparency      := $1.x3d_transparency,
  x3d_ambient_intensity := $1.x3d_ambient_intensity,
  x3d_specular_color    := $1.x3d_specular_color,
  x3d_diffuse_color     := $1.x3d_diffuse_color,
  x3d_emissive_color    := $1.x3d_emissive_color,
  x3d_is_smooth         := $1.x3d_is_smooth,
  tex_texture_type      := $1.tex_texture_type,
  tex_wrap_mode         := $1.tex_wrap_mode,
  tex_border_color      := $1.tex_border_color,
  gt_prefer_worldfile   := $1.gt_prefer_worldfile,
  gt_orientation        := $1.gt_orientation
WHERE t.id = $1.id RETURNING id', cdb_schema) INTO updated_id USING obj;

RETURN updated_id;
EXCEPTION
  WHEN OTHERS THEN RAISE NOTICE 'qgis_pkg.upd_t_surface_data(id: %): %', obj.id, SQLERRM;
END;
$$ LANGUAGE plpgsql;
COMMENT ON FUNCTION qgis_pkg.upd_t_surface_data(qgis_pkg.obj_surface_data, varchar) IS 'Update attributes of table SURFACE_DATA';
REVOKE EXECUTE ON FUNCTION  qgis_pkg.upd_t_surface_data(qgis_pkg.obj_surface_data, varchar) FROM public;

----------------------------------------------------------------
-- Create FUNCTION QGIS_PKG_DEV.UPD_T_SURFACE_GEOMETRY
----------------------------------------------------------------
-- left out, to be added if needed

DROP FUNCTION IF EXISTS    qgis_pkg.upd_t_textureparam(qgis_pkg.obj_textureparam, varchar) CASCADE;
CREATE OR REPLACE FUNCTION qgis_pkg.upd_t_textureparam(
obj         qgis_pkg.obj_textureparam,
cdb_schema varchar
)
RETURNS bigint[] AS $$
DECLARE
  updated_id bigint[];
BEGIN
-- checks
IF ((obj.surface_geometry_id IS NULL) OR (obj.surface_data_id IS NULL)) THEN
   RAISE EXCEPTION 'Foreign keys (surface_geometry_id, surface_data_id) must be NOT NULL';  
END IF;

EXECUTE format('
UPDATE %I.textureparam AS t SET
  is_texture_parametrization = $1.is_texture_parametrization,
  world_to_texure            = $1.world_to_texure,
  texture_coordinates        = $1.texture_coordinates
WHERE 
	t.surface_geometry_id = $1.surface_geometry_id 
	AND t.surface_data_id = $1.surface_data_id
RETURNING ARRAY[surface_geometry_id, surface_data_id]', cdb_schema) 
INTO updated_id USING obj;

RETURN updated_id;
EXCEPTION
  WHEN OTHERS THEN RAISE NOTICE 'qgis_pkg.upd_t_textureparam(surface_geometry_id: %, surface_data_id: %): %', obj.surface_geometry_id, obj.surface_data_id, SQLERRM;
END;
$$ LANGUAGE plpgsql;
COMMENT ON FUNCTION qgis_pkg.upd_t_textureparam(qgis_pkg.obj_textureparam, varchar) IS 'Update attributes of table TEXTUREPARAM';
REVOKE EXECUTE ON FUNCTION  qgis_pkg.upd_t_textureparam(qgis_pkg.obj_textureparam, varchar) FROM public;

----------------------------------------------------------------
-- Create FUNCTION QGIS_PKG_DEV.UPD_T_THEMATIC_SURFACE
----------------------------------------------------------------
-- no attributes to be updated

----------------------------------------------------------------
-- Create FUNCTION QGIS_PKG_DEV.UPD_T_TIN_RELIEF
----------------------------------------------------------------
DROP FUNCTION IF EXISTS    qgis_pkg.upd_t_tin_relief(qgis_pkg.obj_tin_relief, varchar) CASCADE;
CREATE OR REPLACE FUNCTION qgis_pkg.upd_t_tin_relief(
obj         qgis_pkg.obj_tin_relief,
cdb_schema varchar
)
RETURNS bigint AS $$
DECLARE
  updated_id bigint;
BEGIN
-- checks
IF ((obj.length IS NOT NULL) AND (obj.length_unit IS NULL)) OR
   ((obj.length IS NULL) AND (obj.length_unit IS NOT NULL)) THEN
   RAISE EXCEPTION 'Measure values (length) must contain both number AND unit of measure';  
END IF;

EXECUTE format('
UPDATE %I.tin_relief AS t SET
  max_length      = $1.max_length,
  max_length_unit = $1.max_length_unit  
WHERE t.id = $1.id RETURNING id', cdb_schema) INTO updated_id USING obj;

RETURN updated_id;
EXCEPTION
  WHEN OTHERS THEN RAISE NOTICE 'qgis_pkg.upd_t_tin_relief(id: %): %', obj.id, SQLERRM;
END;
$$ LANGUAGE plpgsql;
COMMENT ON FUNCTION qgis_pkg.upd_t_tin_relief(qgis_pkg.obj_tin_relief, varchar) IS 'Update attributes of table TIN_RELIEF';
REVOKE EXECUTE ON FUNCTION  qgis_pkg.upd_t_tin_relief(qgis_pkg.obj_tin_relief, varchar) FROM public;

----------------------------------------------------------------
-- Create FUNCTION QGIS_PKG_DEV.UPD_T_TRAFFIC_AREA
----------------------------------------------------------------
DROP FUNCTION IF EXISTS    qgis_pkg.upd_t_traffic_area(qgis_pkg.obj_traffic_area, varchar) CASCADE;
CREATE OR REPLACE FUNCTION qgis_pkg.upd_t_traffic_area(
obj         qgis_pkg.obj_traffic_area,
cdb_schema varchar
)
RETURNS bigint AS $$
DECLARE
  updated_id bigint;
BEGIN
-- checks

EXECUTE format('
UPDATE %I.traffic_area AS t SET
  class                       = $1.class,
  class_codespace             = $1.class_codespace,
  function                    = $1.function,
  function_codespace          = $1.function_codespace,
  usage                       = $1.usage,
  usage_codespace             = $1.usage_codespace,
  surface_material            = $1.surface_material,
  surface_material_codespace  = $1.surface_material_codespace
WHERE t.id = $1.id RETURNING id', cdb_schema) INTO updated_id USING obj;

RETURN updated_id;
EXCEPTION
  WHEN OTHERS THEN RAISE NOTICE 'qgis_pkg.upd_t_traffic_area(id: %): %', obj.id, SQLERRM;
END;
$$ LANGUAGE plpgsql;
COMMENT ON FUNCTION qgis_pkg.upd_t_traffic_area(qgis_pkg.obj_traffic_area, varchar) IS 'Update attributes of table TRAFFIC_AREA';
REVOKE EXECUTE ON FUNCTION qgis_pkg.upd_t_traffic_area(qgis_pkg.obj_traffic_area, varchar) FROM public;

----------------------------------------------------------------
-- Create FUNCTION QGIS_PKG_DEV.UPD_T_TRANSPORTATION_COMPLEX
----------------------------------------------------------------
DROP FUNCTION IF EXISTS    qgis_pkg.upd_t_transportation_complex(qgis_pkg.obj_transportation_complex, varchar) CASCADE;
CREATE OR REPLACE FUNCTION qgis_pkg.upd_t_transportation_complex(
obj         qgis_pkg.obj_transportation_complex,
cdb_schema varchar
)
RETURNS bigint AS $$
DECLARE
  updated_id bigint;
BEGIN
-- checks

EXECUTE format('
UPDATE %I.transportation_complex AS t SET
  class                       = $1.class,
  class_codespace             = $1.class_codespace,
  function                    = $1.function,
  function_codespace          = $1.function_codespace,
  usage                       = $1.usage,
  usage_codespace             = $1.usage_codespace
WHERE t.id = $1.id RETURNING id', cdb_schema) INTO updated_id USING obj;

RETURN updated_id;
EXCEPTION
  WHEN OTHERS THEN RAISE NOTICE 'qgis_pkg.upd_t_transportation_complex(id: %): %', obj.id, SQLERRM;
END;
$$ LANGUAGE plpgsql;
COMMENT ON FUNCTION qgis_pkg.upd_t_transportation_complex(qgis_pkg.obj_transportation_complex, varchar) IS 'Update attributes of table TRANSPORTATION_COMPLEX';
REVOKE EXECUTE ON FUNCTION qgis_pkg.upd_t_transportation_complex(qgis_pkg.obj_transportation_complex, varchar) FROM public;

----------------------------------------------------------------
-- Create FUNCTION QGIS_PKG_DEV.UPD_T_TUNNEL
----------------------------------------------------------------
DROP FUNCTION IF EXISTS    qgis_pkg.upd_t_tunnel(qgis_pkg.obj_tunnel, varchar) CASCADE;
CREATE OR REPLACE FUNCTION qgis_pkg.upd_t_tunnel(
obj         qgis_pkg.obj_tunnel,
cdb_schema varchar
)
RETURNS bigint AS $$
DECLARE
  updated_id bigint;
BEGIN
-- checks

EXECUTE format('
UPDATE %I.tunnel AS t SET
  class                       = $1.class,
  class_codespace             = $1.class_codespace,
  function                    = $1.function,
  function_codespace          = $1.function_codespace,
  usage                       = $1.usage,
  usage_codespace             = $1.usage_codespace,
  year_of_construction        = $1.year_of_construction,
  year_of_demolition          = $1.year_of_demolition,
WHERE t.id = $1.id RETURNING id', cdb_schema) INTO updated_id USING obj;

RETURN updated_id;
EXCEPTION
  WHEN OTHERS THEN RAISE NOTICE 'qgis_pkg.upd_t_tunnel(id: %): %', obj.id, SQLERRM;
END;
$$ LANGUAGE plpgsql;
COMMENT ON FUNCTION qgis_pkg.upd_t_tunnel(qgis_pkg.obj_tunnel, varchar) IS 'Update attributes of table TUNNEL';
REVOKE EXECUTE ON FUNCTION qgis_pkg.upd_t_tunnel(qgis_pkg.obj_tunnel, varchar) FROM public;

----------------------------------------------------------------
-- Create FUNCTION QGIS_PKG_DEV.UPD_T_TUNNEL_FURNITURE
----------------------------------------------------------------
DROP FUNCTION IF EXISTS    qgis_pkg.upd_t_tunnel_furniture(qgis_pkg.obj_tunnel_furniture, varchar) CASCADE;
CREATE OR REPLACE FUNCTION qgis_pkg.upd_t_tunnel_furniture(
obj         qgis_pkg.obj_tunnel_furniture,
cdb_schema varchar
)
RETURNS bigint AS $$
DECLARE
  updated_id bigint;
BEGIN
-- checks

EXECUTE format('
UPDATE %I.tunnel_furniture AS t SET
  class                       = $1.class,
  class_codespace             = $1.class_codespace,
  function                    = $1.function,
  function_codespace          = $1.function_codespace,
  usage                       = $1.usage,
  usage_codespace             = $1.usage_codespace
WHERE t.id = $1.id RETURNING id', cdb_schema) INTO updated_id USING obj;

RETURN updated_id;
EXCEPTION
  WHEN OTHERS THEN RAISE NOTICE 'qgis_pkg.upd_t_tunnel_furniture(id: %): %', obj.id, SQLERRM;
END;
$$ LANGUAGE plpgsql;
COMMENT ON FUNCTION qgis_pkg.upd_t_tunnel_furniture(qgis_pkg.obj_tunnel_furniture, varchar) IS 'Update attributes of table TUNNEL_FURNITURE';
REVOKE EXECUTE ON FUNCTION qgis_pkg.upd_t_tunnel_furniture(qgis_pkg.obj_tunnel_furniture, varchar) FROM public;

----------------------------------------------------------------
-- Create FUNCTION QGIS_PKG_DEV.UPD_T_TUNNEL_HOLLOW_SPACE
----------------------------------------------------------------
DROP FUNCTION IF EXISTS    qgis_pkg.upd_t_tunnel_hollow_space(qgis_pkg.obj_tunnel_hollow_space, varchar) CASCADE;
CREATE OR REPLACE FUNCTION qgis_pkg.upd_t_tunnel_hollow_space(
obj         qgis_pkg.obj_tunnel_hollow_space,
cdb_schema varchar
)
RETURNS bigint AS $$
DECLARE
  updated_id bigint;
BEGIN
-- checks

EXECUTE format('
UPDATE %I.tunnel_hollow_space AS t SET
  class                       = $1.class,
  class_codespace             = $1.class_codespace,
  function                    = $1.function,
  function_codespace          = $1.function_codespace,
  usage                       = $1.usage,
  usage_codespace             = $1.usage_codespace
WHERE t.id = $1.id RETURNING id', cdb_schema) INTO updated_id USING obj;

RETURN updated_id;
EXCEPTION
  WHEN OTHERS THEN RAISE NOTICE 'qgis_pkg.upd_t_tunnel_hollow_space(id: %): %', obj.id, SQLERRM;
END;
$$ LANGUAGE plpgsql;
COMMENT ON FUNCTION qgis_pkg.upd_t_tunnel_hollow_space(qgis_pkg.obj_tunnel_hollow_space, varchar) IS 'Update attributes of table TUNNEL_HOLLOW_SPACE';
REVOKE EXECUTE ON FUNCTION qgis_pkg.upd_t_tunnel_hollow_space(qgis_pkg.obj_tunnel_hollow_space, varchar) FROM public;

----------------------------------------------------------------
-- Create FUNCTION QGIS_PKG_DEV.UPD_T_TUNNEL_INSTALLATION
----------------------------------------------------------------
DROP FUNCTION IF EXISTS    qgis_pkg.upd_t_tunnel_installation(qgis_pkg.obj_tunnel_installation, varchar) CASCADE;
CREATE OR REPLACE FUNCTION qgis_pkg.upd_t_tunnel_installation(
obj         qgis_pkg.obj_tunnel_installation,
cdb_schema varchar
)
RETURNS bigint AS $$
DECLARE
  updated_id bigint;
BEGIN
-- checks

EXECUTE format('
UPDATE %I.tunnel_installation AS t SET
  class                       = $1.class,
  class_codespace             = $1.class_codespace,
  function                    = $1.function,
  function_codespace          = $1.function_codespace,
  usage                       = $1.usage,
  usage_codespace             = $1.usage_codespace
WHERE t.id = $1.id RETURNING id', cdb_schema) INTO updated_id USING obj;

RETURN updated_id;
EXCEPTION
  WHEN OTHERS THEN RAISE NOTICE 'qgis_pkg.upd_t_tunnel_installation(id: %): %', obj.id, SQLERRM;
END;
$$ LANGUAGE plpgsql;
COMMENT ON FUNCTION qgis_pkg.upd_t_tunnel_installation(qgis_pkg.obj_tunnel_installation, varchar) IS 'Update attributes of table TUNNEL_INSTALLATION';
REVOKE EXECUTE ON FUNCTION qgis_pkg.upd_t_tunnel_installation(qgis_pkg.obj_tunnel_installation, varchar) FROM public;

----------------------------------------------------------------
-- Create FUNCTION QGIS_PKG_DEV.UPD_T_TUNNEL_OPENING
----------------------------------------------------------------
-- no attributes to be updated

----------------------------------------------------------------
-- Create FUNCTION QGIS_PKG_DEV.UPD_T_TUNNEL_THEMATIC_SURFACE
----------------------------------------------------------------
-- no attributes to be updated

----------------------------------------------------------------
-- Create FUNCTION QGIS_PKG_DEV.UPD_T_WATERBODY
----------------------------------------------------------------
DROP FUNCTION IF EXISTS    qgis_pkg.upd_t_waterbody(qgis_pkg.obj_waterbody, varchar) CASCADE;
CREATE OR REPLACE FUNCTION qgis_pkg.upd_t_waterbody(
obj         qgis_pkg.obj_waterbody,
cdb_schema varchar
)
RETURNS bigint AS $$
DECLARE
  updated_id bigint;
BEGIN
-- checks

EXECUTE format('
UPDATE %I.waterbody AS t SET
  class                       = $1.class,
  class_codespace             = $1.class_codespace,
  function                    = $1.function,
  function_codespace          = $1.function_codespace,
  usage                       = $1.usage,
  usage_codespace             = $1.usage_codespace
WHERE t.id = $1.id RETURNING id', cdb_schema) INTO updated_id USING obj;

RETURN updated_id;
EXCEPTION
  WHEN OTHERS THEN RAISE NOTICE 'qgis_pkg.upd_t_waterbody(id: %): %', obj.id, SQLERRM;
END;
$$ LANGUAGE plpgsql;
COMMENT ON FUNCTION qgis_pkg.upd_t_waterbody(qgis_pkg.obj_waterbody, varchar) IS 'Update attributes of table WATERBODY';
REVOKE EXECUTE ON FUNCTION qgis_pkg.upd_t_waterbody(qgis_pkg.obj_waterbody, varchar) FROM public;

----------------------------------------------------------------
-- Create FUNCTION QGIS_PKG_DEV.UPD_T_WATERBOUNDARY_SURFACE
----------------------------------------------------------------
DROP FUNCTION IF EXISTS    qgis_pkg.upd_t_waterboundary_surface(qgis_pkg.obj_waterboundary_surface, varchar) CASCADE;
CREATE OR REPLACE FUNCTION qgis_pkg.upd_t_waterboundary_surface(
obj         qgis_pkg.obj_waterboundary_surface,
cdb_schema varchar
)
RETURNS bigint AS $$
DECLARE
  updated_id bigint;
BEGIN
-- checks

EXECUTE format('
UPDATE %I.waterboundary_surface AS t SET
  water_level           = $1.water_level,
  water_level_codespace = $1.water_level_codespace
WHERE t.id = $1.id RETURNING id', cdb_schema) INTO updated_id USING obj;

RETURN updated_id;
EXCEPTION
  WHEN OTHERS THEN RAISE NOTICE 'qgis_pkg.upd_t_waterboundary_surface(id: %): %', obj.id, SQLERRM;
END;
$$ LANGUAGE plpgsql;
COMMENT ON FUNCTION qgis_pkg.upd_t_waterboundary_surface(qgis_pkg.obj_waterboundary_surface, varchar) IS 'Update attributes of table WATERBOUNDARY_SURFACE';
REVOKE EXECUTE ON FUNCTION qgis_pkg.upd_t_waterboundary_surface(qgis_pkg.obj_waterboundary_surface, varchar) FROM public;

/* template
----------------------------------------------------------------
-- Create FUNCTION QGIS_PKG_DEV.UPD_T_ZXC
----------------------------------------------------------------
DROP FUNCTION IF EXISTS    qgis_pkg.upd_t_zxc(qgis_pkg.obj_zxc, varchar) CASCADE;
CREATE OR REPLACE FUNCTION qgis_pkg.upd_t_zxc(
obj         qgis_pkg.obj_zxc,
cdb_schema varchar
)
RETURNS bigint AS $$
DECLARE
-- enumerations

  updated_id bigint;
BEGIN
-- checks

-- update query omitting all PK, FK and geometry columns)
EXECUTE format('
UPDATE %I.zxc AS t SET
  class                       = $1.class,
  class_codespace             = $1.class_codespace,
  function                    = $1.function,
  function_codespace          = $1.function_codespace,
  usage                       = $1.usage,
  usage_codespace             = $1.usage_codespace
WHERE t.id = $1.id RETURNING id', cdb_schema) INTO updated_id USING obj;

RETURN updated_id;
EXCEPTION
  WHEN OTHERS THEN RAISE NOTICE 'qgis_pkg.upd_t_zxc(id: %): %', obj.id, SQLERRM;
END;
$$ LANGUAGE plpgsql;
COMMENT ON FUNCTION qgis_pkg.upd_t_zxc(qgis_pkg.obj_zxc, varchar) IS 'Update attributes of table ZXC';
REVOKE EXECUTE ON FUNCTION qgis_pkg.upd_t_zxc(qgis_pkg.obj_zxc, varchar) FROM public;
*/


--**************************
DO $MAINBODY$
DECLARE
BEGIN
RAISE NOTICE E'\n\nDone\n\n';
END $MAINBODY$;
--**************************
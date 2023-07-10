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
--
-- This script installs in schema qgis_pkg trigger functions related to
-- table address.
--
-- ***********************************************************************


----------------------------------------------------------------
-- Create trigger FUNCTION QGIS_PKG.TR_DEL_ADDRESS
----------------------------------------------------------------
-- This trigger function is meant for the layer, NOT for the detail view!
DROP FUNCTION IF EXISTS    qgis_pkg.tr_del_address CASCADE;
CREATE OR REPLACE FUNCTION qgis_pkg.tr_del_address()
RETURNS trigger AS $$
DECLARE
  dv_prefix  CONSTANT varchar := 'dv_';
  cdb_schema varchar;
BEGIN
CASE
  WHEN TG_TABLE_NAME::text LIKE 'dv_%' THEN
    cdb_schema := split_part(split_part(TG_TABLE_NAME, '_address_', 1), dv_prefix, 2); 

  WHEN TG_TABLE_NAME::text LIKE '%_bdg_address' THEN
    cdb_schema := split_part(TG_TABLE_NAME, '_bdg_address', 1);
  WHEN TG_TABLE_NAME::text LIKE '%_bdg_part_address' THEN
     cdb_schema := split_part(TG_TABLE_NAME, '_bdg_part_address', 1);
  WHEN TG_TABLE_NAME::text LIKE '%_bri_address'  THEN
    cdb_schema := split_part(TG_TABLE_NAME, '_bri_address', 1);
  WHEN TG_TABLE_NAME::text LIKE '%_bri_part_address' THEN 
    cdb_schema := split_part(TG_TABLE_NAME, '_bri_part_address', 1);

  WHEN TG_TABLE_NAME::text LIKE '%_bdg_door_address' THEN
    cdb_schema := split_part(TG_TABLE_NAME, '_bdg__dooraddress', 1);
  WHEN TG_TABLE_NAME::text LIKE '%_bdg_part_door_address' THEN
     cdb_schema := split_part(TG_TABLE_NAME, '_bdg_part_door_address', 1);
  WHEN TG_TABLE_NAME::text LIKE '%_bri_door_address'  THEN
    cdb_schema := split_part(TG_TABLE_NAME, '_bri_door_address', 1);
  WHEN TG_TABLE_NAME::text LIKE '%_bri_part_door_address' THEN 
    cdb_schema := split_part(TG_TABLE_NAME, '_bri_part_door_address', 1);

  ELSE
    RAISE EXCEPTION 'Error extracting the cdb_schema name from %',TG_TABLE_NAME;
END CASE;

EXECUTE format('SELECT %I.del_address(ARRAY[$1]);', cdb_schema) USING OLD.id;

RETURN OLD;
EXCEPTION
  WHEN OTHERS THEN RAISE NOTICE 'qgis_pkg.tr_del_address(id: %): %', OLD.id, SQLERRM;
END;
$$ LANGUAGE plpgsql;
COMMENT ON FUNCTION qgis_pkg.tr_del_address IS 'Trigger to delete a record from a view of table ADDRESS';
REVOKE EXECUTE ON FUNCTION qgis_pkg.tr_del_address FROM public;

----------------------------------------------------------------
-- Create trigger FUNCTION QGIS_PKG.TR_UPD_ADDRESS
----------------------------------------------------------------
-- This trigger function is meant for the layer, NOT for the detail view!
DROP FUNCTION IF EXISTS    qgis_pkg.tr_upd_address CASCADE;
CREATE OR REPLACE FUNCTION qgis_pkg.tr_upd_address()
RETURNS trigger AS $$
DECLARE
  dv_prefix  CONSTANT varchar := 'dv_';
  cdb_schema varchar;
  obj    qgis_pkg.obj_address;
BEGIN
CASE
  WHEN TG_TABLE_NAME::text LIKE 'dv_%' THEN
    cdb_schema := split_part(split_part(TG_TABLE_NAME, '_address_', 1), dv_prefix, 2); 

  WHEN TG_TABLE_NAME::text LIKE '%_bdg_address' THEN
    cdb_schema := split_part(TG_TABLE_NAME, '_bdg_address', 1);
  WHEN TG_TABLE_NAME::text LIKE '%_bdg_part_address' THEN
     cdb_schema := split_part(TG_TABLE_NAME, '_bdg_part_address', 1);
  WHEN TG_TABLE_NAME::text LIKE '%_bri_address'  THEN
    cdb_schema := split_part(TG_TABLE_NAME, '_bri_address', 1);
  WHEN TG_TABLE_NAME::text LIKE '%_bri_part_address' THEN 
    cdb_schema := split_part(TG_TABLE_NAME, '_bri_part_address', 1);

  WHEN TG_TABLE_NAME::text LIKE '%_bdg_door_address' THEN
    cdb_schema := split_part(TG_TABLE_NAME, '_bdg__dooraddress', 1);
  WHEN TG_TABLE_NAME::text LIKE '%_bdg_part_door_address' THEN
     cdb_schema := split_part(TG_TABLE_NAME, '_bdg_part_door_address', 1);
  WHEN TG_TABLE_NAME::text LIKE '%_bri_door_address'  THEN
    cdb_schema := split_part(TG_TABLE_NAME, '_bri_door_address', 1);
  WHEN TG_TABLE_NAME::text LIKE '%_bri_part_door_address' THEN 
    cdb_schema := split_part(TG_TABLE_NAME, '_bri_part_door_address', 1);

  ELSE
    RAISE EXCEPTION 'Error extracting the cdb_schema name from %',TG_TABLE_NAME;
END CASE;

obj.id              := OLD.id;
obj.gmlid           := NEW.gmlid;
obj.gmlid_codespace := NEW.gmlid_codespace;
obj.street          := NEW.street;
obj.house_number    := NEW.house_number;
obj.po_box          := NEW.po_box;
obj.zip_code        := NEW.zip_code;
obj.city            := NEW.city;
obj.state           := NEW.state;
obj.country         := NEW.country;
obj.multi_point     := NEW.geom;
--obj.xal_source      := NEW.xal_source;

-- No need to take care of the NEW.cityobject_id as we do not allow for updating PK and FK

PERFORM qgis_pkg.upd_t_address(obj, cdb_schema);

RETURN NEW;
EXCEPTION
  WHEN OTHERS THEN RAISE NOTICE 'qgis_pkg.tr_upd_address(id: %): %', OLD.id, SQLERRM;
END;
$$ LANGUAGE plpgsql;
COMMENT ON FUNCTION qgis_pkg.tr_upd_address IS 'Trigger to update a record from a view of table ADDRESS';
REVOKE EXECUTE ON FUNCTION qgis_pkg.tr_upd_address FROM public;


----------------------------------------------------------------
-- Create trigger FUNCTION QGIS_PKG.TR_INS_ADDRESS
----------------------------------------------------------------
-- This trigger function is meant for the layer, NOT for the detail view!
DROP FUNCTION IF EXISTS    qgis_pkg.tr_ins_address CASCADE;
CREATE OR REPLACE FUNCTION qgis_pkg.tr_ins_address()
RETURNS trigger AS $$
DECLARE
  dv_prefix       CONSTANT varchar := 'dv_';
  cdb_schema      varchar;
  obj             qgis_pkg.obj_address;
  inserted_id     bigint;
  test_r          RECORD;
  case_value      varchar;
  insert_allowed  boolean := TRUE;
BEGIN
IF TG_TABLE_NAME::text LIKE concat(dv_prefix,'%') THEN -- we are dealing with a detail view calling this trigger

  cdb_schema := split_part(split_part(TG_TABLE_NAME, '_address_', 1), dv_prefix, 2); 
  CASE split_part(TG_TABLE_NAME, '_address_', 2)
    WHEN 'bdg' THEN
      case_value := 'address_to_building';
      -- nothing to do
    WHEN 'bdg_door' THEN
      case_value := 'opening';
      EXECUTE format('SELECT id, address_id FROM %I.opening WHERE id = $1',cdb_schema) INTO test_r USING NEW.cityobject_id;
      IF NOT (test_r.id IS NOT NULL AND test_r.address_id IS NULL) THEN
        insert_allowed := FALSE;
      END IF;
    WHEN 'bri' THEN
      case_value := 'bridge';
      -- nothing to do
    WHEN 'bri_door' THEN
      case_value := 'bridge_opening';
      EXECUTE format('SELECT id, address_id FROM %I.opening WHERE id = $1',cdb_schema) INTO test_r USING NEW.cityobject_id;
      IF NOT (test_r.id IS NOT NULL AND test_r.address_id IS NULL) THEN
        insert_allowed := FALSE;
      END IF;
  END CASE;  

ELSE  -- we are dealing with a layer calling this trigger

  CASE
    WHEN TG_TABLE_NAME::text LIKE '%_bdg_address' THEN
      cdb_schema := split_part(TG_TABLE_NAME, '_bdg_address', 1);
      case_value := 'address_to_building';
    WHEN TG_TABLE_NAME::text LIKE '%_bdg_part_address' THEN
      cdb_schema := split_part(TG_TABLE_NAME, '_bdg_part_address', 1);
      case_value := 'address_to_building';
    WHEN TG_TABLE_NAME::text LIKE '%_bri_address'  THEN
      cdb_schema := split_part(TG_TABLE_NAME, '_bri_address', 1);
      case_value := 'address_to_bridge';
    WHEN TG_TABLE_NAME::text LIKE '%_bri_part_address' THEN 
      cdb_schema := split_part(TG_TABLE_NAME, '_bri_part_address', 1);
      case_value := 'address_to_bridge';
    WHEN TG_TABLE_NAME::text LIKE '%_bdg_door_address' THEN
      cdb_schema := split_part(TG_TABLE_NAME, '_bdg_door_address', 1);
      EXECUTE format('SELECT id, address_id FROM %I.opening WHERE id = $1',cdb_schema) INTO test_r USING NEW.cityobject_id;
      IF NOT (test_r.id IS NOT NULL AND test_r.address_id IS NULL) THEN
        insert_allowed := FALSE;
      END IF;
      case_value := 'opening';
    WHEN TG_TABLE_NAME::text LIKE '%_bdg_part_door_address' THEN
      cdb_schema := split_part(TG_TABLE_NAME, '_bdg_part_door_address', 1);
      EXECUTE format('SELECT id, address_id FROM %I.opening WHERE id = $1',cdb_schema) INTO test_r USING NEW.cityobject_id;
      IF NOT (test_r.id IS NOT NULL AND test_r.address_id IS NULL) THEN
        insert_allowed := FALSE;
      END IF;
      case_value := 'opening';
    WHEN TG_TABLE_NAME::text LIKE '%_bri_door_address'  THEN
      cdb_schema := split_part(TG_TABLE_NAME, '_bri_door_address', 1);
      EXECUTE format('SELECT id, address_id FROM %I.bridge_opening WHERE id = $1',cdb_schema) INTO test_r USING NEW.cityobject_id;
      IF NOT (test_r.id IS NOT NULL AND test_r.address_id IS NULL) THEN
        insert_allowed := FALSE;
      END IF;
      case_value := 'bridge_opening';
    WHEN TG_TABLE_NAME::text LIKE '%_bri_part_door_address' THEN 
      cdb_schema := split_part(TG_TABLE_NAME, '_bri_part_door_address', 1);
      EXECUTE format('SELECT id, address_id FROM %I.bridge_opening WHERE id = $1',cdb_schema) INTO test_r USING NEW.cityobject_id;
      IF NOT (test_r.id IS NOT NULL AND test_r.address_id IS NULL) THEN
        insert_allowed := FALSE;
      END IF;
      case_value := 'bridge_opening';
    ELSE
      RAISE EXCEPTION 'Error extracting the cdb_schema name from %',TG_TABLE_NAME;
  END CASE;
END IF;

IF insert_allowed IS FALSE THEN
  RAISE NOTICE 'Cannot insert address to door, there is already one';
ELSE
  -- Otherwise it stays TRUE, as per initialization
  obj.id              := NEW.id;
  obj.gmlid           := NEW.gmlid;
  obj.gmlid_codespace := NEW.gmlid_codespace;
  obj.street          := NEW.street;
  obj.house_number    := NEW.house_number;
  obj.po_box          := NEW.po_box;
  obj.zip_code        := NEW.zip_code;
  obj.city            := NEW.city;
  obj.state           := NEW.state;
  obj.country         := NEW.country;
  obj.multi_point     := NEW.geom;
  --obj.xal_source      := NEW.xal_source;

  SELECT qgis_pkg.ins_t_address(obj, cdb_schema) INTO inserted_id;

  -- Take care of the relations to the parent cityobjects, i.e. building(parts), bridge(parts), (bridge_)openings
  CASE case_value
    WHEN 'address_to_building' THEN
      EXECUTE format('INSERT INTO %I.address_to_building (address_id, building_id) VALUES ($1, $2)', cdb_schema) USING inserted_id, NEW.cityobject_id;
    WHEN 'address_to_bridge' THEN
      EXECUTE format('INSERT INTO %I.address_to_bridge (address_id, bridge_id) VALUES ($1, $2)', cdb_schema) USING inserted_id, NEW.cityobject_id;
    WHEN 'opening' THEN
      EXECUTE format('UPDATE %I.opening SET address_id = $1 WHERE id = $2', cdb_schema) USING inserted_id, NEW.cityobject_id;
    WHEN 'bridge_opening' THEN
      EXECUTE format('UPDATE %I.bridge_opening SET address_id = $1 WHERE id = $2', cdb_schema) USING inserted_id, NEW.cityobject_id;
    ELSE
      -- do nothing else
  END CASE;

END IF;

RETURN NEW;
EXCEPTION
  WHEN OTHERS THEN RAISE NOTICE 'qgis_pkg.tr_ins_address(id: %): %', inserted_id, SQLERRM;
END;
$$ LANGUAGE plpgsql;
COMMENT ON FUNCTION qgis_pkg.tr_ins_address IS 'Trigger to insert a new record into a view of table ADDRESS';
REVOKE EXECUTE ON FUNCTION qgis_pkg.tr_ins_address FROM public;


--**************************
DO $MAINBODY$
BEGIN
RAISE NOTICE E'\n\nDone\n\n';
END $MAINBODY$;
--**************************

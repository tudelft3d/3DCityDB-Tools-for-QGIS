-- ***********************************************************************
--
--      QGIS Package for the CityGML 3D City Database (for PostgreSQL)
--
--
--                        Copyright 2022
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
-- This script installs in schema qgis_pkg trigger functions for the views.
--
-- ***********************************************************************

----------------------------------------------------------------
-- Create trigger FUNCTION QGIS_PKG.TR_INS_ADDRESS
----------------------------------------------------------------
DROP FUNCTION IF EXISTS    qgis_pkg.tr_ins_address CASCADE;
CREATE OR REPLACE FUNCTION qgis_pkg.tr_ins_address()
RETURNS trigger AS $$
DECLARE
BEGIN
RAISE EXCEPTION 'You are not allowed to insert new records using the QGIS plugin';
RETURN OLD;
EXCEPTION
  WHEN OTHERS THEN RAISE NOTICE 'qgis_pkg.tr_ins_address(): %', SQLERRM;
END;

$$ LANGUAGE plpgsql;
COMMENT ON FUNCTION qgis_pkg.tr_ins_address IS '(Blocks) inserting record in table ADDRESS';
REVOKE EXECUTE ON FUNCTION qgis_pkg.tr_ins_address FROM public;

----------------------------------------------------------------
-- Create trigger FUNCTION QGIS_PKG.TR_DEL_ADDRESS
----------------------------------------------------------------
DROP FUNCTION IF EXISTS    qgis_pkg.tr_del_address CASCADE;
CREATE OR REPLACE FUNCTION qgis_pkg.tr_del_address()
RETURNS trigger AS $$
DECLARE
  cdb_schema CONSTANT varchar := split_part(TG_TABLE_NAME, '_', 1); 
BEGIN
EXECUTE format('PERFORM %I.del_address(ARRAY[%L]);', cdb_schema, OLD.id);
RETURN OLD;
EXCEPTION
  WHEN OTHERS THEN RAISE NOTICE 'qgis_pkg.tr_del_address(): %', SQLERRM;
END;
$$ LANGUAGE plpgsql;
COMMENT ON FUNCTION qgis_pkg.tr_ins_address IS 'Deletes record in table ADDRESS';
REVOKE EXECUTE ON FUNCTION qgis_pkg.tr_del_address FROM public;

----------------------------------------------------------------
-- Create trigger FUNCTION QGIS_PKG.TR_INS_APPEARANCE
----------------------------------------------------------------
DROP FUNCTION IF EXISTS    qgis_pkg.tr_ins_appearance CASCADE;
CREATE OR REPLACE FUNCTION qgis_pkg.tr_ins_appearance()
RETURNS trigger AS $$
DECLARE
BEGIN
RAISE EXCEPTION 'You are not allowed to insert new records using the QGIS plugin';
RETURN OLD;
EXCEPTION
  WHEN OTHERS THEN RAISE NOTICE 'qgis_pkg.tr_ins_appearance(): %', SQLERRM;
END;

$$ LANGUAGE plpgsql;
COMMENT ON FUNCTION qgis_pkg.tr_ins_appearance IS '(Blocks) inserting record in table APPEARANCE';
REVOKE EXECUTE ON FUNCTION qgis_pkg.tr_ins_appearance FROM public;

----------------------------------------------------------------
-- Create trigger FUNCTION QGIS_PKG.TR_DEL_APPEARANCE
----------------------------------------------------------------
DROP FUNCTION IF EXISTS    qgis_pkg.tr_del_appearance CASCADE;
CREATE OR REPLACE FUNCTION qgis_pkg.tr_del_appearance()
RETURNS trigger AS $$
DECLARE
  cdb_schema CONSTANT varchar := split_part(TG_TABLE_NAME, '_', 1); 
BEGIN
EXECUTE format('PERFORM %I.del_appearance(ARRAY[%L]);', cdb_schema, OLD.id);
RETURN OLD;
EXCEPTION
  WHEN OTHERS THEN RAISE NOTICE 'qgis_pkg.tr_del_appearance(): %', SQLERRM;
END;
$$ LANGUAGE plpgsql;
COMMENT ON FUNCTION qgis_pkg.tr_ins_appearance IS 'Deletes record in table APPEARANCE';
REVOKE EXECUTE ON FUNCTION qgis_pkg.tr_del_appearance FROM public;

----------------------------------------------------------------
-- Create trigger FUNCTION QGIS_PKG.TR_INS_BREAKLINE_RELIEF
----------------------------------------------------------------
DROP FUNCTION IF EXISTS    qgis_pkg.tr_ins_breakline_relief CASCADE;
CREATE OR REPLACE FUNCTION qgis_pkg.tr_ins_breakline_relief()
RETURNS trigger AS $$
DECLARE
BEGIN
RAISE EXCEPTION 'You are not allowed to insert new records using the QGIS plugin';
RETURN OLD;
EXCEPTION
  WHEN OTHERS THEN RAISE NOTICE 'qgis_pkg.tr_ins_breakline_relief(): %', SQLERRM;
END;

$$ LANGUAGE plpgsql;
COMMENT ON FUNCTION qgis_pkg.tr_ins_breakline_relief IS '(Blocks) inserting record in table BREAKLINE_RELIEF';
REVOKE EXECUTE ON FUNCTION qgis_pkg.tr_ins_breakline_relief FROM public;

----------------------------------------------------------------
-- Create trigger FUNCTION QGIS_PKG.TR_DEL_BREAKLINE_RELIEF
----------------------------------------------------------------
DROP FUNCTION IF EXISTS    qgis_pkg.tr_del_breakline_relief CASCADE;
CREATE OR REPLACE FUNCTION qgis_pkg.tr_del_breakline_relief()
RETURNS trigger AS $$
DECLARE
  cdb_schema CONSTANT varchar := split_part(TG_TABLE_NAME, '_', 1); 
BEGIN
EXECUTE format('PERFORM %I.del_breakline_relief(ARRAY[%L]);', cdb_schema, OLD.id);
RETURN OLD;
EXCEPTION
  WHEN OTHERS THEN RAISE NOTICE 'qgis_pkg.tr_del_breakline_relief(): %', SQLERRM;
END;
$$ LANGUAGE plpgsql;
COMMENT ON FUNCTION qgis_pkg.tr_ins_breakline_relief IS 'Deletes record in table BREAKLINE_RELIEF';
REVOKE EXECUTE ON FUNCTION qgis_pkg.tr_del_breakline_relief FROM public;

----------------------------------------------------------------
-- Create trigger FUNCTION QGIS_PKG.TR_INS_BRIDGE
----------------------------------------------------------------
DROP FUNCTION IF EXISTS    qgis_pkg.tr_ins_bridge CASCADE;
CREATE OR REPLACE FUNCTION qgis_pkg.tr_ins_bridge()
RETURNS trigger AS $$
DECLARE
BEGIN
RAISE EXCEPTION 'You are not allowed to insert new records using the QGIS plugin';
RETURN OLD;
EXCEPTION
  WHEN OTHERS THEN RAISE NOTICE 'qgis_pkg.tr_ins_bridge(): %', SQLERRM;
END;

$$ LANGUAGE plpgsql;
COMMENT ON FUNCTION qgis_pkg.tr_ins_bridge IS '(Blocks) inserting record in table BRIDGE';
REVOKE EXECUTE ON FUNCTION qgis_pkg.tr_ins_bridge FROM public;

----------------------------------------------------------------
-- Create trigger FUNCTION QGIS_PKG.TR_DEL_BRIDGE
----------------------------------------------------------------
DROP FUNCTION IF EXISTS    qgis_pkg.tr_del_bridge CASCADE;
CREATE OR REPLACE FUNCTION qgis_pkg.tr_del_bridge()
RETURNS trigger AS $$
DECLARE
  cdb_schema CONSTANT varchar := split_part(TG_TABLE_NAME, '_', 1); 
BEGIN
EXECUTE format('PERFORM %I.del_bridge(ARRAY[%L]);', cdb_schema, OLD.id);
RETURN OLD;
EXCEPTION
  WHEN OTHERS THEN RAISE NOTICE 'qgis_pkg.tr_del_bridge(): %', SQLERRM;
END;
$$ LANGUAGE plpgsql;
COMMENT ON FUNCTION qgis_pkg.tr_ins_bridge IS 'Deletes record in table BRIDGE';
REVOKE EXECUTE ON FUNCTION qgis_pkg.tr_del_bridge FROM public;

----------------------------------------------------------------
-- Create trigger FUNCTION QGIS_PKG.TR_INS_BRIDGE_CONSTR_ELEMENT
----------------------------------------------------------------
DROP FUNCTION IF EXISTS    qgis_pkg.tr_ins_bridge_constr_element CASCADE;
CREATE OR REPLACE FUNCTION qgis_pkg.tr_ins_bridge_constr_element()
RETURNS trigger AS $$
DECLARE
BEGIN
RAISE EXCEPTION 'You are not allowed to insert new records using the QGIS plugin';
RETURN OLD;
EXCEPTION
  WHEN OTHERS THEN RAISE NOTICE 'qgis_pkg.tr_ins_bridge_constr_element(): %', SQLERRM;
END;

$$ LANGUAGE plpgsql;
COMMENT ON FUNCTION qgis_pkg.tr_ins_bridge_constr_element IS '(Blocks) inserting record in table BRIDGE_CONSTR_ELEMENT';
REVOKE EXECUTE ON FUNCTION qgis_pkg.tr_ins_bridge_constr_element FROM public;

----------------------------------------------------------------
-- Create trigger FUNCTION QGIS_PKG.TR_DEL_BRIDGE_CONSTR_ELEMENT
----------------------------------------------------------------
DROP FUNCTION IF EXISTS    qgis_pkg.tr_del_bridge_constr_element CASCADE;
CREATE OR REPLACE FUNCTION qgis_pkg.tr_del_bridge_constr_element()
RETURNS trigger AS $$
DECLARE
  cdb_schema CONSTANT varchar := split_part(TG_TABLE_NAME, '_', 1); 
BEGIN
EXECUTE format('PERFORM %I.del_bridge_constr_element(ARRAY[%L]);', cdb_schema, OLD.id);
RETURN OLD;
EXCEPTION
  WHEN OTHERS THEN RAISE NOTICE 'qgis_pkg.tr_del_bridge_constr_element(): %', SQLERRM;
END;
$$ LANGUAGE plpgsql;
COMMENT ON FUNCTION qgis_pkg.tr_ins_bridge_constr_element IS 'Deletes record in table BRIDGE_CONSTR_ELEMENT';
REVOKE EXECUTE ON FUNCTION qgis_pkg.tr_del_bridge_constr_element FROM public;

----------------------------------------------------------------
-- Create trigger FUNCTION QGIS_PKG.TR_INS_BRIDGE_FURNITURE
----------------------------------------------------------------
DROP FUNCTION IF EXISTS    qgis_pkg.tr_ins_bridge_furniture CASCADE;
CREATE OR REPLACE FUNCTION qgis_pkg.tr_ins_bridge_furniture()
RETURNS trigger AS $$
DECLARE
BEGIN
RAISE EXCEPTION 'You are not allowed to insert new records using the QGIS plugin';
RETURN OLD;
EXCEPTION
  WHEN OTHERS THEN RAISE NOTICE 'qgis_pkg.tr_ins_bridge_furniture(): %', SQLERRM;
END;

$$ LANGUAGE plpgsql;
COMMENT ON FUNCTION qgis_pkg.tr_ins_bridge_furniture IS '(Blocks) inserting record in table BRIDGE_FURNITURE';
REVOKE EXECUTE ON FUNCTION qgis_pkg.tr_ins_bridge_furniture FROM public;

----------------------------------------------------------------
-- Create trigger FUNCTION QGIS_PKG.TR_DEL_BRIDGE_FURNITURE
----------------------------------------------------------------
DROP FUNCTION IF EXISTS    qgis_pkg.tr_del_bridge_furniture CASCADE;
CREATE OR REPLACE FUNCTION qgis_pkg.tr_del_bridge_furniture()
RETURNS trigger AS $$
DECLARE
  cdb_schema CONSTANT varchar := split_part(TG_TABLE_NAME, '_', 1); 
BEGIN
EXECUTE format('PERFORM %I.del_bridge_furniture(ARRAY[%L]);', cdb_schema, OLD.id);
RETURN OLD;
EXCEPTION
  WHEN OTHERS THEN RAISE NOTICE 'qgis_pkg.tr_del_bridge_furniture(): %', SQLERRM;
END;
$$ LANGUAGE plpgsql;
COMMENT ON FUNCTION qgis_pkg.tr_ins_bridge_furniture IS 'Deletes record in table BRIDGE_FURNITURE';
REVOKE EXECUTE ON FUNCTION qgis_pkg.tr_del_bridge_furniture FROM public;

----------------------------------------------------------------
-- Create trigger FUNCTION QGIS_PKG.TR_INS_BRIDGE_INSTALLATION
----------------------------------------------------------------
DROP FUNCTION IF EXISTS    qgis_pkg.tr_ins_bridge_installation CASCADE;
CREATE OR REPLACE FUNCTION qgis_pkg.tr_ins_bridge_installation()
RETURNS trigger AS $$
DECLARE
BEGIN
RAISE EXCEPTION 'You are not allowed to insert new records using the QGIS plugin';
RETURN OLD;
EXCEPTION
  WHEN OTHERS THEN RAISE NOTICE 'qgis_pkg.tr_ins_bridge_installation(): %', SQLERRM;
END;

$$ LANGUAGE plpgsql;
COMMENT ON FUNCTION qgis_pkg.tr_ins_bridge_installation IS '(Blocks) inserting record in table BRIDGE_INSTALLATION';
REVOKE EXECUTE ON FUNCTION qgis_pkg.tr_ins_bridge_installation FROM public;

----------------------------------------------------------------
-- Create trigger FUNCTION QGIS_PKG.TR_DEL_BRIDGE_INSTALLATION
----------------------------------------------------------------
DROP FUNCTION IF EXISTS    qgis_pkg.tr_del_bridge_installation CASCADE;
CREATE OR REPLACE FUNCTION qgis_pkg.tr_del_bridge_installation()
RETURNS trigger AS $$
DECLARE
  cdb_schema CONSTANT varchar := split_part(TG_TABLE_NAME, '_', 1); 
BEGIN
EXECUTE format('PERFORM %I.del_bridge_installation(ARRAY[%L]);', cdb_schema, OLD.id);
RETURN OLD;
EXCEPTION
  WHEN OTHERS THEN RAISE NOTICE 'qgis_pkg.tr_del_bridge_installation(): %', SQLERRM;
END;
$$ LANGUAGE plpgsql;
COMMENT ON FUNCTION qgis_pkg.tr_ins_bridge_installation IS 'Deletes record in table BRIDGE_INSTALLATION';
REVOKE EXECUTE ON FUNCTION qgis_pkg.tr_del_bridge_installation FROM public;

----------------------------------------------------------------
-- Create trigger FUNCTION QGIS_PKG.TR_INS_BRIDGE_OPENING
----------------------------------------------------------------
DROP FUNCTION IF EXISTS    qgis_pkg.tr_ins_bridge_opening CASCADE;
CREATE OR REPLACE FUNCTION qgis_pkg.tr_ins_bridge_opening()
RETURNS trigger AS $$
DECLARE
BEGIN
RAISE EXCEPTION 'You are not allowed to insert new records using the QGIS plugin';
RETURN OLD;
EXCEPTION
  WHEN OTHERS THEN RAISE NOTICE 'qgis_pkg.tr_ins_bridge_opening(): %', SQLERRM;
END;

$$ LANGUAGE plpgsql;
COMMENT ON FUNCTION qgis_pkg.tr_ins_bridge_opening IS '(Blocks) inserting record in table BRIDGE_OPENING';
REVOKE EXECUTE ON FUNCTION qgis_pkg.tr_ins_bridge_opening FROM public;

----------------------------------------------------------------
-- Create trigger FUNCTION QGIS_PKG.TR_DEL_BRIDGE_OPENING
----------------------------------------------------------------
DROP FUNCTION IF EXISTS    qgis_pkg.tr_del_bridge_opening CASCADE;
CREATE OR REPLACE FUNCTION qgis_pkg.tr_del_bridge_opening()
RETURNS trigger AS $$
DECLARE
  cdb_schema CONSTANT varchar := split_part(TG_TABLE_NAME, '_', 1); 
BEGIN
EXECUTE format('PERFORM %I.del_bridge_opening(ARRAY[%L]);', cdb_schema, OLD.id);
RETURN OLD;
EXCEPTION
  WHEN OTHERS THEN RAISE NOTICE 'qgis_pkg.tr_del_bridge_opening(): %', SQLERRM;
END;
$$ LANGUAGE plpgsql;
COMMENT ON FUNCTION qgis_pkg.tr_ins_bridge_opening IS 'Deletes record in table BRIDGE_OPENING';
REVOKE EXECUTE ON FUNCTION qgis_pkg.tr_del_bridge_opening FROM public;

----------------------------------------------------------------
-- Create trigger FUNCTION QGIS_PKG.TR_INS_BRIDGE_ROOM
----------------------------------------------------------------
DROP FUNCTION IF EXISTS    qgis_pkg.tr_ins_bridge_room CASCADE;
CREATE OR REPLACE FUNCTION qgis_pkg.tr_ins_bridge_room()
RETURNS trigger AS $$
DECLARE
BEGIN
RAISE EXCEPTION 'You are not allowed to insert new records using the QGIS plugin';
RETURN OLD;
EXCEPTION
  WHEN OTHERS THEN RAISE NOTICE 'qgis_pkg.tr_ins_bridge_room(): %', SQLERRM;
END;

$$ LANGUAGE plpgsql;
COMMENT ON FUNCTION qgis_pkg.tr_ins_bridge_room IS '(Blocks) inserting record in table BRIDGE_ROOM';
REVOKE EXECUTE ON FUNCTION qgis_pkg.tr_ins_bridge_room FROM public;

----------------------------------------------------------------
-- Create trigger FUNCTION QGIS_PKG.TR_DEL_BRIDGE_ROOM
----------------------------------------------------------------
DROP FUNCTION IF EXISTS    qgis_pkg.tr_del_bridge_room CASCADE;
CREATE OR REPLACE FUNCTION qgis_pkg.tr_del_bridge_room()
RETURNS trigger AS $$
DECLARE
  cdb_schema CONSTANT varchar := split_part(TG_TABLE_NAME, '_', 1); 
BEGIN
EXECUTE format('PERFORM %I.del_bridge_room(ARRAY[%L]);', cdb_schema, OLD.id);
RETURN OLD;
EXCEPTION
  WHEN OTHERS THEN RAISE NOTICE 'qgis_pkg.tr_del_bridge_room(): %', SQLERRM;
END;
$$ LANGUAGE plpgsql;
COMMENT ON FUNCTION qgis_pkg.tr_ins_bridge_room IS 'Deletes record in table BRIDGE_ROOM';
REVOKE EXECUTE ON FUNCTION qgis_pkg.tr_del_bridge_room FROM public;

----------------------------------------------------------------
-- Create trigger FUNCTION QGIS_PKG.TR_INS_BRIDGE_THEMATIC_SURFACE
----------------------------------------------------------------
DROP FUNCTION IF EXISTS    qgis_pkg.tr_ins_bridge_thematic_surface CASCADE;
CREATE OR REPLACE FUNCTION qgis_pkg.tr_ins_bridge_thematic_surface()
RETURNS trigger AS $$
DECLARE
BEGIN
RAISE EXCEPTION 'You are not allowed to insert new records using the QGIS plugin';
RETURN OLD;
EXCEPTION
  WHEN OTHERS THEN RAISE NOTICE 'qgis_pkg.tr_ins_bridge_thematic_surface(): %', SQLERRM;
END;

$$ LANGUAGE plpgsql;
COMMENT ON FUNCTION qgis_pkg.tr_ins_bridge_thematic_surface IS '(Blocks) inserting record in table BRIDGE_THEMATIC_SURFACE';
REVOKE EXECUTE ON FUNCTION qgis_pkg.tr_ins_bridge_thematic_surface FROM public;

----------------------------------------------------------------
-- Create trigger FUNCTION QGIS_PKG.TR_DEL_BRIDGE_THEMATIC_SURFACE
----------------------------------------------------------------
DROP FUNCTION IF EXISTS    qgis_pkg.tr_del_bridge_thematic_surface CASCADE;
CREATE OR REPLACE FUNCTION qgis_pkg.tr_del_bridge_thematic_surface()
RETURNS trigger AS $$
DECLARE
  cdb_schema CONSTANT varchar := split_part(TG_TABLE_NAME, '_', 1); 
BEGIN
EXECUTE format('PERFORM %I.del_bridge_thematic_surface(ARRAY[%L]);', cdb_schema, OLD.id);
RETURN OLD;
EXCEPTION
  WHEN OTHERS THEN RAISE NOTICE 'qgis_pkg.tr_del_bridge_thematic_surface(): %', SQLERRM;
END;
$$ LANGUAGE plpgsql;
COMMENT ON FUNCTION qgis_pkg.tr_ins_bridge_thematic_surface IS 'Deletes record in table BRIDGE_THEMATIC_SURFACE';
REVOKE EXECUTE ON FUNCTION qgis_pkg.tr_del_bridge_thematic_surface FROM public;

----------------------------------------------------------------
-- Create trigger FUNCTION QGIS_PKG.TR_INS_BUILDING
----------------------------------------------------------------
DROP FUNCTION IF EXISTS    qgis_pkg.tr_ins_building CASCADE;
CREATE OR REPLACE FUNCTION qgis_pkg.tr_ins_building()
RETURNS trigger AS $$
DECLARE
BEGIN
RAISE EXCEPTION 'You are not allowed to insert new records using the QGIS plugin';
RETURN OLD;
EXCEPTION
  WHEN OTHERS THEN RAISE NOTICE 'qgis_pkg.tr_ins_building(): %', SQLERRM;
END;

$$ LANGUAGE plpgsql;
COMMENT ON FUNCTION qgis_pkg.tr_ins_building IS '(Blocks) inserting record in table BUILDING';
REVOKE EXECUTE ON FUNCTION qgis_pkg.tr_ins_building FROM public;

----------------------------------------------------------------
-- Create trigger FUNCTION QGIS_PKG.TR_DEL_BUILDING
----------------------------------------------------------------
DROP FUNCTION IF EXISTS    qgis_pkg.tr_del_building CASCADE;
CREATE OR REPLACE FUNCTION qgis_pkg.tr_del_building()
RETURNS trigger AS $$
DECLARE
  cdb_schema CONSTANT varchar := split_part(TG_TABLE_NAME, '_', 1); 
BEGIN
EXECUTE format('PERFORM %I.del_building(ARRAY[%L]);', cdb_schema, OLD.id);
RETURN OLD;
EXCEPTION
  WHEN OTHERS THEN RAISE NOTICE 'qgis_pkg.tr_del_building(): %', SQLERRM;
END;
$$ LANGUAGE plpgsql;
COMMENT ON FUNCTION qgis_pkg.tr_ins_building IS 'Deletes record in table BUILDING';
REVOKE EXECUTE ON FUNCTION qgis_pkg.tr_del_building FROM public;

----------------------------------------------------------------
-- Create trigger FUNCTION QGIS_PKG.TR_INS_BUILDING_FURNITURE
----------------------------------------------------------------
DROP FUNCTION IF EXISTS    qgis_pkg.tr_ins_building_furniture CASCADE;
CREATE OR REPLACE FUNCTION qgis_pkg.tr_ins_building_furniture()
RETURNS trigger AS $$
DECLARE
BEGIN
RAISE EXCEPTION 'You are not allowed to insert new records using the QGIS plugin';
RETURN OLD;
EXCEPTION
  WHEN OTHERS THEN RAISE NOTICE 'qgis_pkg.tr_ins_building_furniture(): %', SQLERRM;
END;

$$ LANGUAGE plpgsql;
COMMENT ON FUNCTION qgis_pkg.tr_ins_building_furniture IS '(Blocks) inserting record in table BUILDING_FURNITURE';
REVOKE EXECUTE ON FUNCTION qgis_pkg.tr_ins_building_furniture FROM public;

----------------------------------------------------------------
-- Create trigger FUNCTION QGIS_PKG.TR_DEL_BUILDING_FURNITURE
----------------------------------------------------------------
DROP FUNCTION IF EXISTS    qgis_pkg.tr_del_building_furniture CASCADE;
CREATE OR REPLACE FUNCTION qgis_pkg.tr_del_building_furniture()
RETURNS trigger AS $$
DECLARE
  cdb_schema CONSTANT varchar := split_part(TG_TABLE_NAME, '_', 1); 
BEGIN
EXECUTE format('PERFORM %I.del_building_furniture(ARRAY[%L]);', cdb_schema, OLD.id);
RETURN OLD;
EXCEPTION
  WHEN OTHERS THEN RAISE NOTICE 'qgis_pkg.tr_del_building_furniture(): %', SQLERRM;
END;
$$ LANGUAGE plpgsql;
COMMENT ON FUNCTION qgis_pkg.tr_ins_building_furniture IS 'Deletes record in table BUILDING_FURNITURE';
REVOKE EXECUTE ON FUNCTION qgis_pkg.tr_del_building_furniture FROM public;

----------------------------------------------------------------
-- Create trigger FUNCTION QGIS_PKG.TR_INS_BUILDING_INSTALLATION
----------------------------------------------------------------
DROP FUNCTION IF EXISTS    qgis_pkg.tr_ins_building_installation CASCADE;
CREATE OR REPLACE FUNCTION qgis_pkg.tr_ins_building_installation()
RETURNS trigger AS $$
DECLARE
BEGIN
RAISE EXCEPTION 'You are not allowed to insert new records using the QGIS plugin';
RETURN OLD;
EXCEPTION
  WHEN OTHERS THEN RAISE NOTICE 'qgis_pkg.tr_ins_building_installation(): %', SQLERRM;
END;

$$ LANGUAGE plpgsql;
COMMENT ON FUNCTION qgis_pkg.tr_ins_building_installation IS '(Blocks) inserting record in table BUILDING_INSTALLATION';
REVOKE EXECUTE ON FUNCTION qgis_pkg.tr_ins_building_installation FROM public;

----------------------------------------------------------------
-- Create trigger FUNCTION QGIS_PKG.TR_DEL_BUILDING_INSTALLATION
----------------------------------------------------------------
DROP FUNCTION IF EXISTS    qgis_pkg.tr_del_building_installation CASCADE;
CREATE OR REPLACE FUNCTION qgis_pkg.tr_del_building_installation()
RETURNS trigger AS $$
DECLARE
  cdb_schema CONSTANT varchar := split_part(TG_TABLE_NAME, '_', 1); 
BEGIN
EXECUTE format('PERFORM %I.del_building_installation(ARRAY[%L]);', cdb_schema, OLD.id);
RETURN OLD;
EXCEPTION
  WHEN OTHERS THEN RAISE NOTICE 'qgis_pkg.tr_del_building_installation(): %', SQLERRM;
END;
$$ LANGUAGE plpgsql;
COMMENT ON FUNCTION qgis_pkg.tr_ins_building_installation IS 'Deletes record in table BUILDING_INSTALLATION';
REVOKE EXECUTE ON FUNCTION qgis_pkg.tr_del_building_installation FROM public;

----------------------------------------------------------------
-- Create trigger FUNCTION QGIS_PKG.TR_INS_CITY_FURNITURE
----------------------------------------------------------------
DROP FUNCTION IF EXISTS    qgis_pkg.tr_ins_city_furniture CASCADE;
CREATE OR REPLACE FUNCTION qgis_pkg.tr_ins_city_furniture()
RETURNS trigger AS $$
DECLARE
BEGIN
RAISE EXCEPTION 'You are not allowed to insert new records using the QGIS plugin';
RETURN OLD;
EXCEPTION
  WHEN OTHERS THEN RAISE NOTICE 'qgis_pkg.tr_ins_city_furniture(): %', SQLERRM;
END;

$$ LANGUAGE plpgsql;
COMMENT ON FUNCTION qgis_pkg.tr_ins_city_furniture IS '(Blocks) inserting record in table CITY_FURNITURE';
REVOKE EXECUTE ON FUNCTION qgis_pkg.tr_ins_city_furniture FROM public;

----------------------------------------------------------------
-- Create trigger FUNCTION QGIS_PKG.TR_DEL_CITY_FURNITURE
----------------------------------------------------------------
DROP FUNCTION IF EXISTS    qgis_pkg.tr_del_city_furniture CASCADE;
CREATE OR REPLACE FUNCTION qgis_pkg.tr_del_city_furniture()
RETURNS trigger AS $$
DECLARE
  cdb_schema CONSTANT varchar := split_part(TG_TABLE_NAME, '_', 1); 
BEGIN
EXECUTE format('PERFORM %I.del_city_furniture(ARRAY[%L]);', cdb_schema, OLD.id);
RETURN OLD;
EXCEPTION
  WHEN OTHERS THEN RAISE NOTICE 'qgis_pkg.tr_del_city_furniture(): %', SQLERRM;
END;
$$ LANGUAGE plpgsql;
COMMENT ON FUNCTION qgis_pkg.tr_ins_city_furniture IS 'Deletes record in table CITY_FURNITURE';
REVOKE EXECUTE ON FUNCTION qgis_pkg.tr_del_city_furniture FROM public;

----------------------------------------------------------------
-- Create trigger FUNCTION QGIS_PKG.TR_INS_CITYOBJECT_GENERICATTRIB
----------------------------------------------------------------
DROP FUNCTION IF EXISTS    qgis_pkg.tr_ins_cityobject_genericattrib CASCADE;
CREATE OR REPLACE FUNCTION qgis_pkg.tr_ins_cityobject_genericattrib()
RETURNS trigger AS $$
DECLARE
BEGIN
RAISE EXCEPTION 'You are not allowed to insert new records using the QGIS plugin';
RETURN OLD;
EXCEPTION
  WHEN OTHERS THEN RAISE NOTICE 'qgis_pkg.tr_ins_cityobject_genericattrib(): %', SQLERRM;
END;

$$ LANGUAGE plpgsql;
COMMENT ON FUNCTION qgis_pkg.tr_ins_cityobject_genericattrib IS '(Blocks) inserting record in table CITYOBJECT_GENERICATTRIB';
REVOKE EXECUTE ON FUNCTION qgis_pkg.tr_ins_cityobject_genericattrib FROM public;

----------------------------------------------------------------
-- Create trigger FUNCTION QGIS_PKG.TR_DEL_CITYOBJECT_GENERICATTRIB
----------------------------------------------------------------
DROP FUNCTION IF EXISTS    qgis_pkg.tr_del_cityobject_genericattrib CASCADE;
CREATE OR REPLACE FUNCTION qgis_pkg.tr_del_cityobject_genericattrib()
RETURNS trigger AS $$
DECLARE
  cdb_schema CONSTANT varchar := split_part(TG_TABLE_NAME, '_', 1); 
BEGIN
EXECUTE format('PERFORM %I.del_cityobject_genericattrib(ARRAY[%L]);', cdb_schema, OLD.id);
RETURN OLD;
EXCEPTION
  WHEN OTHERS THEN RAISE NOTICE 'qgis_pkg.tr_del_cityobject_genericattrib(): %', SQLERRM;
END;
$$ LANGUAGE plpgsql;
COMMENT ON FUNCTION qgis_pkg.tr_ins_cityobject_genericattrib IS 'Deletes record in table CITYOBJECT_GENERICATTRIB';
REVOKE EXECUTE ON FUNCTION qgis_pkg.tr_del_cityobject_genericattrib FROM public;

----------------------------------------------------------------
-- Create trigger FUNCTION QGIS_PKG.TR_INS_CITYOBJECTGROUP
----------------------------------------------------------------
DROP FUNCTION IF EXISTS    qgis_pkg.tr_ins_cityobjectgroup CASCADE;
CREATE OR REPLACE FUNCTION qgis_pkg.tr_ins_cityobjectgroup()
RETURNS trigger AS $$
DECLARE
BEGIN
RAISE EXCEPTION 'You are not allowed to insert new records using the QGIS plugin';
RETURN OLD;
EXCEPTION
  WHEN OTHERS THEN RAISE NOTICE 'qgis_pkg.tr_ins_cityobjectgroup(): %', SQLERRM;
END;

$$ LANGUAGE plpgsql;
COMMENT ON FUNCTION qgis_pkg.tr_ins_cityobjectgroup IS '(Blocks) inserting record in table CITYOBJECTGROUP';
REVOKE EXECUTE ON FUNCTION qgis_pkg.tr_ins_cityobjectgroup FROM public;

----------------------------------------------------------------
-- Create trigger FUNCTION QGIS_PKG.TR_DEL_CITYOBJECTGROUP
----------------------------------------------------------------
DROP FUNCTION IF EXISTS    qgis_pkg.tr_del_cityobjectgroup CASCADE;
CREATE OR REPLACE FUNCTION qgis_pkg.tr_del_cityobjectgroup()
RETURNS trigger AS $$
DECLARE
  cdb_schema CONSTANT varchar := split_part(TG_TABLE_NAME, '_', 1); 
BEGIN
EXECUTE format('PERFORM %I.del_cityobjectgroup(ARRAY[%L]);', cdb_schema, OLD.id);
RETURN OLD;
EXCEPTION
  WHEN OTHERS THEN RAISE NOTICE 'qgis_pkg.tr_del_cityobjectgroup(): %', SQLERRM;
END;
$$ LANGUAGE plpgsql;
COMMENT ON FUNCTION qgis_pkg.tr_ins_cityobjectgroup IS 'Deletes record in table CITYOBJECTGROUP';
REVOKE EXECUTE ON FUNCTION qgis_pkg.tr_del_cityobjectgroup FROM public;

----------------------------------------------------------------
-- Create trigger FUNCTION QGIS_PKG.TR_INS_EXTERNAL_REFERENCE
----------------------------------------------------------------
DROP FUNCTION IF EXISTS    qgis_pkg.tr_ins_external_reference CASCADE;
CREATE OR REPLACE FUNCTION qgis_pkg.tr_ins_external_reference()
RETURNS trigger AS $$
DECLARE
BEGIN
RAISE EXCEPTION 'You are not allowed to insert new records using the QGIS plugin';
RETURN OLD;
EXCEPTION
  WHEN OTHERS THEN RAISE NOTICE 'qgis_pkg.tr_ins_external_reference(): %', SQLERRM;
END;

$$ LANGUAGE plpgsql;
COMMENT ON FUNCTION qgis_pkg.tr_ins_external_reference IS '(Blocks) inserting record in table EXTERNAL_REFERENCE';
REVOKE EXECUTE ON FUNCTION qgis_pkg.tr_ins_external_reference FROM public;

----------------------------------------------------------------
-- Create trigger FUNCTION QGIS_PKG.TR_DEL_EXTERNAL_REFERENCE
----------------------------------------------------------------
DROP FUNCTION IF EXISTS    qgis_pkg.tr_del_external_reference CASCADE;
CREATE OR REPLACE FUNCTION qgis_pkg.tr_del_external_reference()
RETURNS trigger AS $$
DECLARE
  cdb_schema CONSTANT varchar := split_part(TG_TABLE_NAME, '_', 1); 
BEGIN
EXECUTE format('PERFORM %I.del_external_reference(ARRAY[%L]);', cdb_schema, OLD.id);
RETURN OLD;
EXCEPTION
  WHEN OTHERS THEN RAISE NOTICE 'qgis_pkg.tr_del_external_reference(): %', SQLERRM;
END;
$$ LANGUAGE plpgsql;
COMMENT ON FUNCTION qgis_pkg.tr_ins_external_reference IS 'Deletes record in table EXTERNAL_REFERENCE';
REVOKE EXECUTE ON FUNCTION qgis_pkg.tr_del_external_reference FROM public;

----------------------------------------------------------------
-- Create trigger FUNCTION QGIS_PKG.TR_INS_GENERIC_CITYOBJECT
----------------------------------------------------------------
DROP FUNCTION IF EXISTS    qgis_pkg.tr_ins_generic_cityobject CASCADE;
CREATE OR REPLACE FUNCTION qgis_pkg.tr_ins_generic_cityobject()
RETURNS trigger AS $$
DECLARE
BEGIN
RAISE EXCEPTION 'You are not allowed to insert new records using the QGIS plugin';
RETURN OLD;
EXCEPTION
  WHEN OTHERS THEN RAISE NOTICE 'qgis_pkg.tr_ins_generic_cityobject(): %', SQLERRM;
END;

$$ LANGUAGE plpgsql;
COMMENT ON FUNCTION qgis_pkg.tr_ins_generic_cityobject IS '(Blocks) inserting record in table GENERIC_CITYOBJECT';
REVOKE EXECUTE ON FUNCTION qgis_pkg.tr_ins_generic_cityobject FROM public;

----------------------------------------------------------------
-- Create trigger FUNCTION QGIS_PKG.TR_DEL_GENERIC_CITYOBJECT
----------------------------------------------------------------
DROP FUNCTION IF EXISTS    qgis_pkg.tr_del_generic_cityobject CASCADE;
CREATE OR REPLACE FUNCTION qgis_pkg.tr_del_generic_cityobject()
RETURNS trigger AS $$
DECLARE
  cdb_schema CONSTANT varchar := split_part(TG_TABLE_NAME, '_', 1); 
BEGIN
EXECUTE format('PERFORM %I.del_generic_cityobject(ARRAY[%L]);', cdb_schema, OLD.id);
RETURN OLD;
EXCEPTION
  WHEN OTHERS THEN RAISE NOTICE 'qgis_pkg.tr_del_generic_cityobject(): %', SQLERRM;
END;
$$ LANGUAGE plpgsql;
COMMENT ON FUNCTION qgis_pkg.tr_ins_generic_cityobject IS 'Deletes record in table GENERIC_CITYOBJECT';
REVOKE EXECUTE ON FUNCTION qgis_pkg.tr_del_generic_cityobject FROM public;

----------------------------------------------------------------
-- Create trigger FUNCTION QGIS_PKG.TR_INS_LAND_USE
----------------------------------------------------------------
DROP FUNCTION IF EXISTS    qgis_pkg.tr_ins_land_use CASCADE;
CREATE OR REPLACE FUNCTION qgis_pkg.tr_ins_land_use()
RETURNS trigger AS $$
DECLARE
BEGIN
RAISE EXCEPTION 'You are not allowed to insert new records using the QGIS plugin';
RETURN OLD;
EXCEPTION
  WHEN OTHERS THEN RAISE NOTICE 'qgis_pkg.tr_ins_land_use(): %', SQLERRM;
END;

$$ LANGUAGE plpgsql;
COMMENT ON FUNCTION qgis_pkg.tr_ins_land_use IS '(Blocks) inserting record in table LAND_USE';
REVOKE EXECUTE ON FUNCTION qgis_pkg.tr_ins_land_use FROM public;

----------------------------------------------------------------
-- Create trigger FUNCTION QGIS_PKG.TR_DEL_LAND_USE
----------------------------------------------------------------
DROP FUNCTION IF EXISTS    qgis_pkg.tr_del_land_use CASCADE;
CREATE OR REPLACE FUNCTION qgis_pkg.tr_del_land_use()
RETURNS trigger AS $$
DECLARE
  cdb_schema CONSTANT varchar := split_part(TG_TABLE_NAME, '_', 1); 
BEGIN
EXECUTE format('PERFORM %I.del_land_use(ARRAY[%L]);', cdb_schema, OLD.id);
RETURN OLD;
EXCEPTION
  WHEN OTHERS THEN RAISE NOTICE 'qgis_pkg.tr_del_land_use(): %', SQLERRM;
END;
$$ LANGUAGE plpgsql;
COMMENT ON FUNCTION qgis_pkg.tr_ins_land_use IS 'Deletes record in table LAND_USE';
REVOKE EXECUTE ON FUNCTION qgis_pkg.tr_del_land_use FROM public;

----------------------------------------------------------------
-- Create trigger FUNCTION QGIS_PKG.TR_INS_MASSPOINT_RELIEF
----------------------------------------------------------------
DROP FUNCTION IF EXISTS    qgis_pkg.tr_ins_masspoint_relief CASCADE;
CREATE OR REPLACE FUNCTION qgis_pkg.tr_ins_masspoint_relief()
RETURNS trigger AS $$
DECLARE
BEGIN
RAISE EXCEPTION 'You are not allowed to insert new records using the QGIS plugin';
RETURN OLD;
EXCEPTION
  WHEN OTHERS THEN RAISE NOTICE 'qgis_pkg.tr_ins_masspoint_relief(): %', SQLERRM;
END;

$$ LANGUAGE plpgsql;
COMMENT ON FUNCTION qgis_pkg.tr_ins_masspoint_relief IS '(Blocks) inserting record in table MASSPOINT_RELIEF';
REVOKE EXECUTE ON FUNCTION qgis_pkg.tr_ins_masspoint_relief FROM public;

----------------------------------------------------------------
-- Create trigger FUNCTION QGIS_PKG.TR_DEL_MASSPOINT_RELIEF
----------------------------------------------------------------
DROP FUNCTION IF EXISTS    qgis_pkg.tr_del_masspoint_relief CASCADE;
CREATE OR REPLACE FUNCTION qgis_pkg.tr_del_masspoint_relief()
RETURNS trigger AS $$
DECLARE
  cdb_schema CONSTANT varchar := split_part(TG_TABLE_NAME, '_', 1); 
BEGIN
EXECUTE format('PERFORM %I.del_masspoint_relief(ARRAY[%L]);', cdb_schema, OLD.id);
RETURN OLD;
EXCEPTION
  WHEN OTHERS THEN RAISE NOTICE 'qgis_pkg.tr_del_masspoint_relief(): %', SQLERRM;
END;
$$ LANGUAGE plpgsql;
COMMENT ON FUNCTION qgis_pkg.tr_ins_masspoint_relief IS 'Deletes record in table MASSPOINT_RELIEF';
REVOKE EXECUTE ON FUNCTION qgis_pkg.tr_del_masspoint_relief FROM public;

----------------------------------------------------------------
-- Create trigger FUNCTION QGIS_PKG.TR_INS_OPENING
----------------------------------------------------------------
DROP FUNCTION IF EXISTS    qgis_pkg.tr_ins_opening CASCADE;
CREATE OR REPLACE FUNCTION qgis_pkg.tr_ins_opening()
RETURNS trigger AS $$
DECLARE
BEGIN
RAISE EXCEPTION 'You are not allowed to insert new records using the QGIS plugin';
RETURN OLD;
EXCEPTION
  WHEN OTHERS THEN RAISE NOTICE 'qgis_pkg.tr_ins_opening(): %', SQLERRM;
END;

$$ LANGUAGE plpgsql;
COMMENT ON FUNCTION qgis_pkg.tr_ins_opening IS '(Blocks) inserting record in table OPENING';
REVOKE EXECUTE ON FUNCTION qgis_pkg.tr_ins_opening FROM public;

----------------------------------------------------------------
-- Create trigger FUNCTION QGIS_PKG.TR_DEL_OPENING
----------------------------------------------------------------
DROP FUNCTION IF EXISTS    qgis_pkg.tr_del_opening CASCADE;
CREATE OR REPLACE FUNCTION qgis_pkg.tr_del_opening()
RETURNS trigger AS $$
DECLARE
  cdb_schema CONSTANT varchar := split_part(TG_TABLE_NAME, '_', 1); 
BEGIN
EXECUTE format('PERFORM %I.del_opening(ARRAY[%L]);', cdb_schema, OLD.id);
RETURN OLD;
EXCEPTION
  WHEN OTHERS THEN RAISE NOTICE 'qgis_pkg.tr_del_opening(): %', SQLERRM;
END;
$$ LANGUAGE plpgsql;
COMMENT ON FUNCTION qgis_pkg.tr_ins_opening IS 'Deletes record in table OPENING';
REVOKE EXECUTE ON FUNCTION qgis_pkg.tr_del_opening FROM public;

----------------------------------------------------------------
-- Create trigger FUNCTION QGIS_PKG.TR_INS_PLANT_COVER
----------------------------------------------------------------
DROP FUNCTION IF EXISTS    qgis_pkg.tr_ins_plant_cover CASCADE;
CREATE OR REPLACE FUNCTION qgis_pkg.tr_ins_plant_cover()
RETURNS trigger AS $$
DECLARE
BEGIN
RAISE EXCEPTION 'You are not allowed to insert new records using the QGIS plugin';
RETURN OLD;
EXCEPTION
  WHEN OTHERS THEN RAISE NOTICE 'qgis_pkg.tr_ins_plant_cover(): %', SQLERRM;
END;

$$ LANGUAGE plpgsql;
COMMENT ON FUNCTION qgis_pkg.tr_ins_plant_cover IS '(Blocks) inserting record in table PLANT_COVER';
REVOKE EXECUTE ON FUNCTION qgis_pkg.tr_ins_plant_cover FROM public;

----------------------------------------------------------------
-- Create trigger FUNCTION QGIS_PKG.TR_DEL_PLANT_COVER
----------------------------------------------------------------
DROP FUNCTION IF EXISTS    qgis_pkg.tr_del_plant_cover CASCADE;
CREATE OR REPLACE FUNCTION qgis_pkg.tr_del_plant_cover()
RETURNS trigger AS $$
DECLARE
  cdb_schema CONSTANT varchar := split_part(TG_TABLE_NAME, '_', 1); 
BEGIN
EXECUTE format('PERFORM %I.del_plant_cover(ARRAY[%L]);', cdb_schema, OLD.id);
RETURN OLD;
EXCEPTION
  WHEN OTHERS THEN RAISE NOTICE 'qgis_pkg.tr_del_plant_cover(): %', SQLERRM;
END;
$$ LANGUAGE plpgsql;
COMMENT ON FUNCTION qgis_pkg.tr_ins_plant_cover IS 'Deletes record in table PLANT_COVER';
REVOKE EXECUTE ON FUNCTION qgis_pkg.tr_del_plant_cover FROM public;

----------------------------------------------------------------
-- Create trigger FUNCTION QGIS_PKG.TR_INS_RASTER_RELIEF
----------------------------------------------------------------
DROP FUNCTION IF EXISTS    qgis_pkg.tr_ins_raster_relief CASCADE;
CREATE OR REPLACE FUNCTION qgis_pkg.tr_ins_raster_relief()
RETURNS trigger AS $$
DECLARE
BEGIN
RAISE EXCEPTION 'You are not allowed to insert new records using the QGIS plugin';
RETURN OLD;
EXCEPTION
  WHEN OTHERS THEN RAISE NOTICE 'qgis_pkg.tr_ins_raster_relief(): %', SQLERRM;
END;

$$ LANGUAGE plpgsql;
COMMENT ON FUNCTION qgis_pkg.tr_ins_raster_relief IS '(Blocks) inserting record in table RASTER_RELIEF';
REVOKE EXECUTE ON FUNCTION qgis_pkg.tr_ins_raster_relief FROM public;

----------------------------------------------------------------
-- Create trigger FUNCTION QGIS_PKG.TR_DEL_RASTER_RELIEF
----------------------------------------------------------------
DROP FUNCTION IF EXISTS    qgis_pkg.tr_del_raster_relief CASCADE;
CREATE OR REPLACE FUNCTION qgis_pkg.tr_del_raster_relief()
RETURNS trigger AS $$
DECLARE
  cdb_schema CONSTANT varchar := split_part(TG_TABLE_NAME, '_', 1); 
BEGIN
EXECUTE format('PERFORM %I.del_raster_relief(ARRAY[%L]);', cdb_schema, OLD.id);
RETURN OLD;
EXCEPTION
  WHEN OTHERS THEN RAISE NOTICE 'qgis_pkg.tr_del_raster_relief(): %', SQLERRM;
END;
$$ LANGUAGE plpgsql;
COMMENT ON FUNCTION qgis_pkg.tr_ins_raster_relief IS 'Deletes record in table RASTER_RELIEF';
REVOKE EXECUTE ON FUNCTION qgis_pkg.tr_del_raster_relief FROM public;

----------------------------------------------------------------
-- Create trigger FUNCTION QGIS_PKG.TR_INS_RELIEF_FEATURE
----------------------------------------------------------------
DROP FUNCTION IF EXISTS    qgis_pkg.tr_ins_relief_feature CASCADE;
CREATE OR REPLACE FUNCTION qgis_pkg.tr_ins_relief_feature()
RETURNS trigger AS $$
DECLARE
BEGIN
RAISE EXCEPTION 'You are not allowed to insert new records using the QGIS plugin';
RETURN OLD;
EXCEPTION
  WHEN OTHERS THEN RAISE NOTICE 'qgis_pkg.tr_ins_relief_feature(): %', SQLERRM;
END;

$$ LANGUAGE plpgsql;
COMMENT ON FUNCTION qgis_pkg.tr_ins_relief_feature IS '(Blocks) inserting record in table RELIEF_FEATURE';
REVOKE EXECUTE ON FUNCTION qgis_pkg.tr_ins_relief_feature FROM public;

----------------------------------------------------------------
-- Create trigger FUNCTION QGIS_PKG.TR_DEL_RELIEF_FEATURE
----------------------------------------------------------------
DROP FUNCTION IF EXISTS    qgis_pkg.tr_del_relief_feature CASCADE;
CREATE OR REPLACE FUNCTION qgis_pkg.tr_del_relief_feature()
RETURNS trigger AS $$
DECLARE
  cdb_schema CONSTANT varchar := split_part(TG_TABLE_NAME, '_', 1); 
BEGIN
EXECUTE format('PERFORM %I.del_relief_feature(ARRAY[%L]);', cdb_schema, OLD.id);
RETURN OLD;
EXCEPTION
  WHEN OTHERS THEN RAISE NOTICE 'qgis_pkg.tr_del_relief_feature(): %', SQLERRM;
END;
$$ LANGUAGE plpgsql;
COMMENT ON FUNCTION qgis_pkg.tr_ins_relief_feature IS 'Deletes record in table RELIEF_FEATURE';
REVOKE EXECUTE ON FUNCTION qgis_pkg.tr_del_relief_feature FROM public;

----------------------------------------------------------------
-- Create trigger FUNCTION QGIS_PKG.TR_INS_ROOM
----------------------------------------------------------------
DROP FUNCTION IF EXISTS    qgis_pkg.tr_ins_room CASCADE;
CREATE OR REPLACE FUNCTION qgis_pkg.tr_ins_room()
RETURNS trigger AS $$
DECLARE
BEGIN
RAISE EXCEPTION 'You are not allowed to insert new records using the QGIS plugin';
RETURN OLD;
EXCEPTION
  WHEN OTHERS THEN RAISE NOTICE 'qgis_pkg.tr_ins_room(): %', SQLERRM;
END;

$$ LANGUAGE plpgsql;
COMMENT ON FUNCTION qgis_pkg.tr_ins_room IS '(Blocks) inserting record in table ROOM';
REVOKE EXECUTE ON FUNCTION qgis_pkg.tr_ins_room FROM public;

----------------------------------------------------------------
-- Create trigger FUNCTION QGIS_PKG.TR_DEL_ROOM
----------------------------------------------------------------
DROP FUNCTION IF EXISTS    qgis_pkg.tr_del_room CASCADE;
CREATE OR REPLACE FUNCTION qgis_pkg.tr_del_room()
RETURNS trigger AS $$
DECLARE
  cdb_schema CONSTANT varchar := split_part(TG_TABLE_NAME, '_', 1); 
BEGIN
EXECUTE format('PERFORM %I.del_room(ARRAY[%L]);', cdb_schema, OLD.id);
RETURN OLD;
EXCEPTION
  WHEN OTHERS THEN RAISE NOTICE 'qgis_pkg.tr_del_room(): %', SQLERRM;
END;
$$ LANGUAGE plpgsql;
COMMENT ON FUNCTION qgis_pkg.tr_ins_room IS 'Deletes record in table ROOM';
REVOKE EXECUTE ON FUNCTION qgis_pkg.tr_del_room FROM public;

----------------------------------------------------------------
-- Create trigger FUNCTION QGIS_PKG.TR_INS_SOLITARY_VEGETAT_OBJECT
----------------------------------------------------------------
DROP FUNCTION IF EXISTS    qgis_pkg.tr_ins_solitary_vegetat_object CASCADE;
CREATE OR REPLACE FUNCTION qgis_pkg.tr_ins_solitary_vegetat_object()
RETURNS trigger AS $$
DECLARE
BEGIN
RAISE EXCEPTION 'You are not allowed to insert new records using the QGIS plugin';
RETURN OLD;
EXCEPTION
  WHEN OTHERS THEN RAISE NOTICE 'qgis_pkg.tr_ins_solitary_vegetat_object(): %', SQLERRM;
END;

$$ LANGUAGE plpgsql;
COMMENT ON FUNCTION qgis_pkg.tr_ins_solitary_vegetat_object IS '(Blocks) inserting record in table SOLITARY_VEGETAT_OBJECT';
REVOKE EXECUTE ON FUNCTION qgis_pkg.tr_ins_solitary_vegetat_object FROM public;

----------------------------------------------------------------
-- Create trigger FUNCTION QGIS_PKG.TR_DEL_SOLITARY_VEGETAT_OBJECT
----------------------------------------------------------------
DROP FUNCTION IF EXISTS    qgis_pkg.tr_del_solitary_vegetat_object CASCADE;
CREATE OR REPLACE FUNCTION qgis_pkg.tr_del_solitary_vegetat_object()
RETURNS trigger AS $$
DECLARE
  cdb_schema CONSTANT varchar := split_part(TG_TABLE_NAME, '_', 1); 
BEGIN
EXECUTE format('PERFORM %I.del_solitary_vegetat_object(ARRAY[%L]);', cdb_schema, OLD.id);
RETURN OLD;
EXCEPTION
  WHEN OTHERS THEN RAISE NOTICE 'qgis_pkg.tr_del_solitary_vegetat_object(): %', SQLERRM;
END;
$$ LANGUAGE plpgsql;
COMMENT ON FUNCTION qgis_pkg.tr_ins_solitary_vegetat_object IS 'Deletes record in table SOLITARY_VEGETAT_OBJECT';
REVOKE EXECUTE ON FUNCTION qgis_pkg.tr_del_solitary_vegetat_object FROM public;

----------------------------------------------------------------
-- Create trigger FUNCTION QGIS_PKG.TR_INS_SURFACE_DATA
----------------------------------------------------------------
DROP FUNCTION IF EXISTS    qgis_pkg.tr_ins_surface_data CASCADE;
CREATE OR REPLACE FUNCTION qgis_pkg.tr_ins_surface_data()
RETURNS trigger AS $$
DECLARE
BEGIN
RAISE EXCEPTION 'You are not allowed to insert new records using the QGIS plugin';
RETURN OLD;
EXCEPTION
  WHEN OTHERS THEN RAISE NOTICE 'qgis_pkg.tr_ins_surface_data(): %', SQLERRM;
END;

$$ LANGUAGE plpgsql;
COMMENT ON FUNCTION qgis_pkg.tr_ins_surface_data IS '(Blocks) inserting record in table SURFACE_DATA';
REVOKE EXECUTE ON FUNCTION qgis_pkg.tr_ins_surface_data FROM public;

----------------------------------------------------------------
-- Create trigger FUNCTION QGIS_PKG.TR_DEL_SURFACE_DATA
----------------------------------------------------------------
DROP FUNCTION IF EXISTS    qgis_pkg.tr_del_surface_data CASCADE;
CREATE OR REPLACE FUNCTION qgis_pkg.tr_del_surface_data()
RETURNS trigger AS $$
DECLARE
  cdb_schema CONSTANT varchar := split_part(TG_TABLE_NAME, '_', 1); 
BEGIN
EXECUTE format('PERFORM %I.del_surface_data(ARRAY[%L]);', cdb_schema, OLD.id);
RETURN OLD;
EXCEPTION
  WHEN OTHERS THEN RAISE NOTICE 'qgis_pkg.tr_del_surface_data(): %', SQLERRM;
END;
$$ LANGUAGE plpgsql;
COMMENT ON FUNCTION qgis_pkg.tr_ins_surface_data IS 'Deletes record in table SURFACE_DATA';
REVOKE EXECUTE ON FUNCTION qgis_pkg.tr_del_surface_data FROM public;

----------------------------------------------------------------
-- Create trigger FUNCTION QGIS_PKG.TR_INS_THEMATIC_SURFACE
----------------------------------------------------------------
DROP FUNCTION IF EXISTS    qgis_pkg.tr_ins_thematic_surface CASCADE;
CREATE OR REPLACE FUNCTION qgis_pkg.tr_ins_thematic_surface()
RETURNS trigger AS $$
DECLARE
BEGIN
RAISE EXCEPTION 'You are not allowed to insert new records using the QGIS plugin';
RETURN OLD;
EXCEPTION
  WHEN OTHERS THEN RAISE NOTICE 'qgis_pkg.tr_ins_thematic_surface(): %', SQLERRM;
END;

$$ LANGUAGE plpgsql;
COMMENT ON FUNCTION qgis_pkg.tr_ins_thematic_surface IS '(Blocks) inserting record in table THEMATIC_SURFACE';
REVOKE EXECUTE ON FUNCTION qgis_pkg.tr_ins_thematic_surface FROM public;

----------------------------------------------------------------
-- Create trigger FUNCTION QGIS_PKG.TR_DEL_THEMATIC_SURFACE
----------------------------------------------------------------
DROP FUNCTION IF EXISTS    qgis_pkg.tr_del_thematic_surface CASCADE;
CREATE OR REPLACE FUNCTION qgis_pkg.tr_del_thematic_surface()
RETURNS trigger AS $$
DECLARE
  cdb_schema CONSTANT varchar := split_part(TG_TABLE_NAME, '_', 1); 
BEGIN
EXECUTE format('PERFORM %I.del_thematic_surface(ARRAY[%L]);', cdb_schema, OLD.id);
RETURN OLD;
EXCEPTION
  WHEN OTHERS THEN RAISE NOTICE 'qgis_pkg.tr_del_thematic_surface(): %', SQLERRM;
END;
$$ LANGUAGE plpgsql;
COMMENT ON FUNCTION qgis_pkg.tr_ins_thematic_surface IS 'Deletes record in table THEMATIC_SURFACE';
REVOKE EXECUTE ON FUNCTION qgis_pkg.tr_del_thematic_surface FROM public;

----------------------------------------------------------------
-- Create trigger FUNCTION QGIS_PKG.TR_INS_TIN_RELIEF
----------------------------------------------------------------
DROP FUNCTION IF EXISTS    qgis_pkg.tr_ins_tin_relief CASCADE;
CREATE OR REPLACE FUNCTION qgis_pkg.tr_ins_tin_relief()
RETURNS trigger AS $$
DECLARE
BEGIN
RAISE EXCEPTION 'You are not allowed to insert new records using the QGIS plugin';
RETURN OLD;
EXCEPTION
  WHEN OTHERS THEN RAISE NOTICE 'qgis_pkg.tr_ins_tin_relief(): %', SQLERRM;
END;

$$ LANGUAGE plpgsql;
COMMENT ON FUNCTION qgis_pkg.tr_ins_tin_relief IS '(Blocks) inserting record in table TIN_RELIEF';
REVOKE EXECUTE ON FUNCTION qgis_pkg.tr_ins_tin_relief FROM public;

----------------------------------------------------------------
-- Create trigger FUNCTION QGIS_PKG.TR_DEL_TIN_RELIEF
----------------------------------------------------------------
DROP FUNCTION IF EXISTS    qgis_pkg.tr_del_tin_relief CASCADE;
CREATE OR REPLACE FUNCTION qgis_pkg.tr_del_tin_relief()
RETURNS trigger AS $$
DECLARE
  cdb_schema CONSTANT varchar := split_part(TG_TABLE_NAME, '_', 1); 
BEGIN
EXECUTE format('PERFORM %I.del_tin_relief(ARRAY[%L]);', cdb_schema, OLD.id);
RETURN OLD;
EXCEPTION
  WHEN OTHERS THEN RAISE NOTICE 'qgis_pkg.tr_del_tin_relief(): %', SQLERRM;
END;
$$ LANGUAGE plpgsql;
COMMENT ON FUNCTION qgis_pkg.tr_ins_tin_relief IS 'Deletes record in table TIN_RELIEF';
REVOKE EXECUTE ON FUNCTION qgis_pkg.tr_del_tin_relief FROM public;

----------------------------------------------------------------
-- Create trigger FUNCTION QGIS_PKG.TR_INS_TRAFFIC_AREA
----------------------------------------------------------------
DROP FUNCTION IF EXISTS    qgis_pkg.tr_ins_traffic_area CASCADE;
CREATE OR REPLACE FUNCTION qgis_pkg.tr_ins_traffic_area()
RETURNS trigger AS $$
DECLARE
BEGIN
RAISE EXCEPTION 'You are not allowed to insert new records using the QGIS plugin';
RETURN OLD;
EXCEPTION
  WHEN OTHERS THEN RAISE NOTICE 'qgis_pkg.tr_ins_traffic_area(): %', SQLERRM;
END;

$$ LANGUAGE plpgsql;
COMMENT ON FUNCTION qgis_pkg.tr_ins_traffic_area IS '(Blocks) inserting record in table TRAFFIC_AREA';
REVOKE EXECUTE ON FUNCTION qgis_pkg.tr_ins_traffic_area FROM public;

----------------------------------------------------------------
-- Create trigger FUNCTION QGIS_PKG.TR_DEL_TRAFFIC_AREA
----------------------------------------------------------------
DROP FUNCTION IF EXISTS    qgis_pkg.tr_del_traffic_area CASCADE;
CREATE OR REPLACE FUNCTION qgis_pkg.tr_del_traffic_area()
RETURNS trigger AS $$
DECLARE
  cdb_schema CONSTANT varchar := split_part(TG_TABLE_NAME, '_', 1); 
BEGIN
EXECUTE format('PERFORM %I.del_traffic_area(ARRAY[%L]);', cdb_schema, OLD.id);
RETURN OLD;
EXCEPTION
  WHEN OTHERS THEN RAISE NOTICE 'qgis_pkg.tr_del_traffic_area(): %', SQLERRM;
END;
$$ LANGUAGE plpgsql;
COMMENT ON FUNCTION qgis_pkg.tr_ins_traffic_area IS 'Deletes record in table TRAFFIC_AREA';
REVOKE EXECUTE ON FUNCTION qgis_pkg.tr_del_traffic_area FROM public;

----------------------------------------------------------------
-- Create trigger FUNCTION QGIS_PKG.TR_INS_TRANSPORTATION_COMPLEX
----------------------------------------------------------------
DROP FUNCTION IF EXISTS    qgis_pkg.tr_ins_transportation_complex CASCADE;
CREATE OR REPLACE FUNCTION qgis_pkg.tr_ins_transportation_complex()
RETURNS trigger AS $$
DECLARE
BEGIN
RAISE EXCEPTION 'You are not allowed to insert new records using the QGIS plugin';
RETURN OLD;
EXCEPTION
  WHEN OTHERS THEN RAISE NOTICE 'qgis_pkg.tr_ins_transportation_complex(): %', SQLERRM;
END;

$$ LANGUAGE plpgsql;
COMMENT ON FUNCTION qgis_pkg.tr_ins_transportation_complex IS '(Blocks) inserting record in table TRANSPORTATION_COMPLEX';
REVOKE EXECUTE ON FUNCTION qgis_pkg.tr_ins_transportation_complex FROM public;

----------------------------------------------------------------
-- Create trigger FUNCTION QGIS_PKG.TR_DEL_TRANSPORTATION_COMPLEX
----------------------------------------------------------------
DROP FUNCTION IF EXISTS    qgis_pkg.tr_del_transportation_complex CASCADE;
CREATE OR REPLACE FUNCTION qgis_pkg.tr_del_transportation_complex()
RETURNS trigger AS $$
DECLARE
  cdb_schema CONSTANT varchar := split_part(TG_TABLE_NAME, '_', 1); 
BEGIN
EXECUTE format('PERFORM %I.del_transportation_complex(ARRAY[%L]);', cdb_schema, OLD.id);
RETURN OLD;
EXCEPTION
  WHEN OTHERS THEN RAISE NOTICE 'qgis_pkg.tr_del_transportation_complex(): %', SQLERRM;
END;
$$ LANGUAGE plpgsql;
COMMENT ON FUNCTION qgis_pkg.tr_ins_transportation_complex IS 'Deletes record in table TRANSPORTATION_COMPLEX';
REVOKE EXECUTE ON FUNCTION qgis_pkg.tr_del_transportation_complex FROM public;

----------------------------------------------------------------
-- Create trigger FUNCTION QGIS_PKG.TR_INS_TUNNEL
----------------------------------------------------------------
DROP FUNCTION IF EXISTS    qgis_pkg.tr_ins_tunnel CASCADE;
CREATE OR REPLACE FUNCTION qgis_pkg.tr_ins_tunnel()
RETURNS trigger AS $$
DECLARE
BEGIN
RAISE EXCEPTION 'You are not allowed to insert new records using the QGIS plugin';
RETURN OLD;
EXCEPTION
  WHEN OTHERS THEN RAISE NOTICE 'qgis_pkg.tr_ins_tunnel(): %', SQLERRM;
END;

$$ LANGUAGE plpgsql;
COMMENT ON FUNCTION qgis_pkg.tr_ins_tunnel IS '(Blocks) inserting record in table TUNNEL';
REVOKE EXECUTE ON FUNCTION qgis_pkg.tr_ins_tunnel FROM public;

----------------------------------------------------------------
-- Create trigger FUNCTION QGIS_PKG.TR_DEL_TUNNEL
----------------------------------------------------------------
DROP FUNCTION IF EXISTS    qgis_pkg.tr_del_tunnel CASCADE;
CREATE OR REPLACE FUNCTION qgis_pkg.tr_del_tunnel()
RETURNS trigger AS $$
DECLARE
  cdb_schema CONSTANT varchar := split_part(TG_TABLE_NAME, '_', 1); 
BEGIN
EXECUTE format('PERFORM %I.del_tunnel(ARRAY[%L]);', cdb_schema, OLD.id);
RETURN OLD;
EXCEPTION
  WHEN OTHERS THEN RAISE NOTICE 'qgis_pkg.tr_del_tunnel(): %', SQLERRM;
END;
$$ LANGUAGE plpgsql;
COMMENT ON FUNCTION qgis_pkg.tr_ins_tunnel IS 'Deletes record in table TUNNEL';
REVOKE EXECUTE ON FUNCTION qgis_pkg.tr_del_tunnel FROM public;

----------------------------------------------------------------
-- Create trigger FUNCTION QGIS_PKG.TR_INS_TUNNEL_FURNITURE
----------------------------------------------------------------
DROP FUNCTION IF EXISTS    qgis_pkg.tr_ins_tunnel_furniture CASCADE;
CREATE OR REPLACE FUNCTION qgis_pkg.tr_ins_tunnel_furniture()
RETURNS trigger AS $$
DECLARE
BEGIN
RAISE EXCEPTION 'You are not allowed to insert new records using the QGIS plugin';
RETURN OLD;
EXCEPTION
  WHEN OTHERS THEN RAISE NOTICE 'qgis_pkg.tr_ins_tunnel_furniture(): %', SQLERRM;
END;

$$ LANGUAGE plpgsql;
COMMENT ON FUNCTION qgis_pkg.tr_ins_tunnel_furniture IS '(Blocks) inserting record in table TUNNEL_FURNITURE';
REVOKE EXECUTE ON FUNCTION qgis_pkg.tr_ins_tunnel_furniture FROM public;

----------------------------------------------------------------
-- Create trigger FUNCTION QGIS_PKG.TR_DEL_TUNNEL_FURNITURE
----------------------------------------------------------------
DROP FUNCTION IF EXISTS    qgis_pkg.tr_del_tunnel_furniture CASCADE;
CREATE OR REPLACE FUNCTION qgis_pkg.tr_del_tunnel_furniture()
RETURNS trigger AS $$
DECLARE
  cdb_schema CONSTANT varchar := split_part(TG_TABLE_NAME, '_', 1); 
BEGIN
EXECUTE format('PERFORM %I.del_tunnel_furniture(ARRAY[%L]);', cdb_schema, OLD.id);
RETURN OLD;
EXCEPTION
  WHEN OTHERS THEN RAISE NOTICE 'qgis_pkg.tr_del_tunnel_furniture(): %', SQLERRM;
END;
$$ LANGUAGE plpgsql;
COMMENT ON FUNCTION qgis_pkg.tr_ins_tunnel_furniture IS 'Deletes record in table TUNNEL_FURNITURE';
REVOKE EXECUTE ON FUNCTION qgis_pkg.tr_del_tunnel_furniture FROM public;

----------------------------------------------------------------
-- Create trigger FUNCTION QGIS_PKG.TR_INS_TUNNEL_HOLLOW_SPACE
----------------------------------------------------------------
DROP FUNCTION IF EXISTS    qgis_pkg.tr_ins_tunnel_hollow_space CASCADE;
CREATE OR REPLACE FUNCTION qgis_pkg.tr_ins_tunnel_hollow_space()
RETURNS trigger AS $$
DECLARE
BEGIN
RAISE EXCEPTION 'You are not allowed to insert new records using the QGIS plugin';
RETURN OLD;
EXCEPTION
  WHEN OTHERS THEN RAISE NOTICE 'qgis_pkg.tr_ins_tunnel_hollow_space(): %', SQLERRM;
END;

$$ LANGUAGE plpgsql;
COMMENT ON FUNCTION qgis_pkg.tr_ins_tunnel_hollow_space IS '(Blocks) inserting record in table TUNNEL_HOLLOW_SPACE';
REVOKE EXECUTE ON FUNCTION qgis_pkg.tr_ins_tunnel_hollow_space FROM public;

----------------------------------------------------------------
-- Create trigger FUNCTION QGIS_PKG.TR_DEL_TUNNEL_HOLLOW_SPACE
----------------------------------------------------------------
DROP FUNCTION IF EXISTS    qgis_pkg.tr_del_tunnel_hollow_space CASCADE;
CREATE OR REPLACE FUNCTION qgis_pkg.tr_del_tunnel_hollow_space()
RETURNS trigger AS $$
DECLARE
  cdb_schema CONSTANT varchar := split_part(TG_TABLE_NAME, '_', 1); 
BEGIN
EXECUTE format('PERFORM %I.del_tunnel_hollow_space(ARRAY[%L]);', cdb_schema, OLD.id);
RETURN OLD;
EXCEPTION
  WHEN OTHERS THEN RAISE NOTICE 'qgis_pkg.tr_del_tunnel_hollow_space(): %', SQLERRM;
END;
$$ LANGUAGE plpgsql;
COMMENT ON FUNCTION qgis_pkg.tr_ins_tunnel_hollow_space IS 'Deletes record in table TUNNEL_HOLLOW_SPACE';
REVOKE EXECUTE ON FUNCTION qgis_pkg.tr_del_tunnel_hollow_space FROM public;

----------------------------------------------------------------
-- Create trigger FUNCTION QGIS_PKG.TR_INS_TUNNEL_INSTALLATION
----------------------------------------------------------------
DROP FUNCTION IF EXISTS    qgis_pkg.tr_ins_tunnel_installation CASCADE;
CREATE OR REPLACE FUNCTION qgis_pkg.tr_ins_tunnel_installation()
RETURNS trigger AS $$
DECLARE
BEGIN
RAISE EXCEPTION 'You are not allowed to insert new records using the QGIS plugin';
RETURN OLD;
EXCEPTION
  WHEN OTHERS THEN RAISE NOTICE 'qgis_pkg.tr_ins_tunnel_installation(): %', SQLERRM;
END;

$$ LANGUAGE plpgsql;
COMMENT ON FUNCTION qgis_pkg.tr_ins_tunnel_installation IS '(Blocks) inserting record in table TUNNEL_INSTALLATION';
REVOKE EXECUTE ON FUNCTION qgis_pkg.tr_ins_tunnel_installation FROM public;

----------------------------------------------------------------
-- Create trigger FUNCTION QGIS_PKG.TR_DEL_TUNNEL_INSTALLATION
----------------------------------------------------------------
DROP FUNCTION IF EXISTS    qgis_pkg.tr_del_tunnel_installation CASCADE;
CREATE OR REPLACE FUNCTION qgis_pkg.tr_del_tunnel_installation()
RETURNS trigger AS $$
DECLARE
  cdb_schema CONSTANT varchar := split_part(TG_TABLE_NAME, '_', 1); 
BEGIN
EXECUTE format('PERFORM %I.del_tunnel_installation(ARRAY[%L]);', cdb_schema, OLD.id);
RETURN OLD;
EXCEPTION
  WHEN OTHERS THEN RAISE NOTICE 'qgis_pkg.tr_del_tunnel_installation(): %', SQLERRM;
END;
$$ LANGUAGE plpgsql;
COMMENT ON FUNCTION qgis_pkg.tr_ins_tunnel_installation IS 'Deletes record in table TUNNEL_INSTALLATION';
REVOKE EXECUTE ON FUNCTION qgis_pkg.tr_del_tunnel_installation FROM public;

----------------------------------------------------------------
-- Create trigger FUNCTION QGIS_PKG.TR_INS_TUNNEL_OPENING
----------------------------------------------------------------
DROP FUNCTION IF EXISTS    qgis_pkg.tr_ins_tunnel_opening CASCADE;
CREATE OR REPLACE FUNCTION qgis_pkg.tr_ins_tunnel_opening()
RETURNS trigger AS $$
DECLARE
BEGIN
RAISE EXCEPTION 'You are not allowed to insert new records using the QGIS plugin';
RETURN OLD;
EXCEPTION
  WHEN OTHERS THEN RAISE NOTICE 'qgis_pkg.tr_ins_tunnel_opening(): %', SQLERRM;
END;

$$ LANGUAGE plpgsql;
COMMENT ON FUNCTION qgis_pkg.tr_ins_tunnel_opening IS '(Blocks) inserting record in table TUNNEL_OPENING';
REVOKE EXECUTE ON FUNCTION qgis_pkg.tr_ins_tunnel_opening FROM public;

----------------------------------------------------------------
-- Create trigger FUNCTION QGIS_PKG.TR_DEL_TUNNEL_OPENING
----------------------------------------------------------------
DROP FUNCTION IF EXISTS    qgis_pkg.tr_del_tunnel_opening CASCADE;
CREATE OR REPLACE FUNCTION qgis_pkg.tr_del_tunnel_opening()
RETURNS trigger AS $$
DECLARE
  cdb_schema CONSTANT varchar := split_part(TG_TABLE_NAME, '_', 1); 
BEGIN
EXECUTE format('PERFORM %I.del_tunnel_opening(ARRAY[%L]);', cdb_schema, OLD.id);
RETURN OLD;
EXCEPTION
  WHEN OTHERS THEN RAISE NOTICE 'qgis_pkg.tr_del_tunnel_opening(): %', SQLERRM;
END;
$$ LANGUAGE plpgsql;
COMMENT ON FUNCTION qgis_pkg.tr_ins_tunnel_opening IS 'Deletes record in table TUNNEL_OPENING';
REVOKE EXECUTE ON FUNCTION qgis_pkg.tr_del_tunnel_opening FROM public;

----------------------------------------------------------------
-- Create trigger FUNCTION QGIS_PKG.TR_INS_TUNNEL_THEMATIC_SURFACE
----------------------------------------------------------------
DROP FUNCTION IF EXISTS    qgis_pkg.tr_ins_tunnel_thematic_surface CASCADE;
CREATE OR REPLACE FUNCTION qgis_pkg.tr_ins_tunnel_thematic_surface()
RETURNS trigger AS $$
DECLARE
BEGIN
RAISE EXCEPTION 'You are not allowed to insert new records using the QGIS plugin';
RETURN OLD;
EXCEPTION
  WHEN OTHERS THEN RAISE NOTICE 'qgis_pkg.tr_ins_tunnel_thematic_surface(): %', SQLERRM;
END;

$$ LANGUAGE plpgsql;
COMMENT ON FUNCTION qgis_pkg.tr_ins_tunnel_thematic_surface IS '(Blocks) inserting record in table TUNNEL_THEMATIC_SURFACE';
REVOKE EXECUTE ON FUNCTION qgis_pkg.tr_ins_tunnel_thematic_surface FROM public;

----------------------------------------------------------------
-- Create trigger FUNCTION QGIS_PKG.TR_DEL_TUNNEL_THEMATIC_SURFACE
----------------------------------------------------------------
DROP FUNCTION IF EXISTS    qgis_pkg.tr_del_tunnel_thematic_surface CASCADE;
CREATE OR REPLACE FUNCTION qgis_pkg.tr_del_tunnel_thematic_surface()
RETURNS trigger AS $$
DECLARE
  cdb_schema CONSTANT varchar := split_part(TG_TABLE_NAME, '_', 1); 
BEGIN
EXECUTE format('PERFORM %I.del_tunnel_thematic_surface(ARRAY[%L]);', cdb_schema, OLD.id);
RETURN OLD;
EXCEPTION
  WHEN OTHERS THEN RAISE NOTICE 'qgis_pkg.tr_del_tunnel_thematic_surface(): %', SQLERRM;
END;
$$ LANGUAGE plpgsql;
COMMENT ON FUNCTION qgis_pkg.tr_ins_tunnel_thematic_surface IS 'Deletes record in table TUNNEL_THEMATIC_SURFACE';
REVOKE EXECUTE ON FUNCTION qgis_pkg.tr_del_tunnel_thematic_surface FROM public;

----------------------------------------------------------------
-- Create trigger FUNCTION QGIS_PKG.TR_INS_WATERBODY
----------------------------------------------------------------
DROP FUNCTION IF EXISTS    qgis_pkg.tr_ins_waterbody CASCADE;
CREATE OR REPLACE FUNCTION qgis_pkg.tr_ins_waterbody()
RETURNS trigger AS $$
DECLARE
BEGIN
RAISE EXCEPTION 'You are not allowed to insert new records using the QGIS plugin';
RETURN OLD;
EXCEPTION
  WHEN OTHERS THEN RAISE NOTICE 'qgis_pkg.tr_ins_waterbody(): %', SQLERRM;
END;

$$ LANGUAGE plpgsql;
COMMENT ON FUNCTION qgis_pkg.tr_ins_waterbody IS '(Blocks) inserting record in table WATERBODY';
REVOKE EXECUTE ON FUNCTION qgis_pkg.tr_ins_waterbody FROM public;

----------------------------------------------------------------
-- Create trigger FUNCTION QGIS_PKG.TR_DEL_WATERBODY
----------------------------------------------------------------
DROP FUNCTION IF EXISTS    qgis_pkg.tr_del_waterbody CASCADE;
CREATE OR REPLACE FUNCTION qgis_pkg.tr_del_waterbody()
RETURNS trigger AS $$
DECLARE
  cdb_schema CONSTANT varchar := split_part(TG_TABLE_NAME, '_', 1); 
BEGIN
EXECUTE format('PERFORM %I.del_waterbody(ARRAY[%L]);', cdb_schema, OLD.id);
RETURN OLD;
EXCEPTION
  WHEN OTHERS THEN RAISE NOTICE 'qgis_pkg.tr_del_waterbody(): %', SQLERRM;
END;
$$ LANGUAGE plpgsql;
COMMENT ON FUNCTION qgis_pkg.tr_ins_waterbody IS 'Deletes record in table WATERBODY';
REVOKE EXECUTE ON FUNCTION qgis_pkg.tr_del_waterbody FROM public;

----------------------------------------------------------------
-- Create trigger FUNCTION QGIS_PKG.TR_INS_WATERBOUNDARY_SURFACE
----------------------------------------------------------------
DROP FUNCTION IF EXISTS    qgis_pkg.tr_ins_waterboundary_surface CASCADE;
CREATE OR REPLACE FUNCTION qgis_pkg.tr_ins_waterboundary_surface()
RETURNS trigger AS $$
DECLARE
BEGIN
RAISE EXCEPTION 'You are not allowed to insert new records using the QGIS plugin';
RETURN OLD;
EXCEPTION
  WHEN OTHERS THEN RAISE NOTICE 'qgis_pkg.tr_ins_waterboundary_surface(): %', SQLERRM;
END;

$$ LANGUAGE plpgsql;
COMMENT ON FUNCTION qgis_pkg.tr_ins_waterboundary_surface IS '(Blocks) inserting record in table WATERBOUNDARY_SURFACE';
REVOKE EXECUTE ON FUNCTION qgis_pkg.tr_ins_waterboundary_surface FROM public;

----------------------------------------------------------------
-- Create trigger FUNCTION QGIS_PKG.TR_DEL_WATERBOUNDARY_SURFACE
----------------------------------------------------------------
DROP FUNCTION IF EXISTS    qgis_pkg.tr_del_waterboundary_surface CASCADE;
CREATE OR REPLACE FUNCTION qgis_pkg.tr_del_waterboundary_surface()
RETURNS trigger AS $$
DECLARE
  cdb_schema CONSTANT varchar := split_part(TG_TABLE_NAME, '_', 1); 
BEGIN
EXECUTE format('PERFORM %I.del_waterboundary_surface(ARRAY[%L]);', cdb_schema, OLD.id);
RETURN OLD;
EXCEPTION
  WHEN OTHERS THEN RAISE NOTICE 'qgis_pkg.tr_del_waterboundary_surface(): %', SQLERRM;
END;
$$ LANGUAGE plpgsql;
COMMENT ON FUNCTION qgis_pkg.tr_ins_waterboundary_surface IS 'Deletes record in table WATERBOUNDARY_SURFACE';
REVOKE EXECUTE ON FUNCTION qgis_pkg.tr_del_waterboundary_surface FROM public;

----------------------------------------------------------------
-- Create trigger FUNCTION QGIS_PKG.TR_INS_WATERBOUNDARY_SURFACE_WATERSURFACE
----------------------------------------------------------------
DROP FUNCTION IF EXISTS    qgis_pkg.tr_ins_waterboundary_surface_watersurface CASCADE;
CREATE OR REPLACE FUNCTION qgis_pkg.tr_ins_waterboundary_surface_watersurface()
RETURNS trigger AS $$
DECLARE
BEGIN
RAISE EXCEPTION 'You are not allowed to insert new records using the QGIS plugin';
RETURN OLD;
EXCEPTION
  WHEN OTHERS THEN RAISE NOTICE 'qgis_pkg.tr_ins_waterboundary_surface_watersurface(): %', SQLERRM;
END;

$$ LANGUAGE plpgsql;
COMMENT ON FUNCTION qgis_pkg.tr_ins_waterboundary_surface_watersurface IS '(Blocks) inserting record in table WATERBOUNDARY_SURFACE';
REVOKE EXECUTE ON FUNCTION qgis_pkg.tr_ins_waterboundary_surface_watersurface FROM public;

----------------------------------------------------------------
-- Create trigger FUNCTION QGIS_PKG.TR_DEL_WATERBOUNDARY_SURFACE_WATERSURFACE
----------------------------------------------------------------
DROP FUNCTION IF EXISTS    qgis_pkg.tr_del_waterboundary_surface_watersurface CASCADE;
CREATE OR REPLACE FUNCTION qgis_pkg.tr_del_waterboundary_surface_watersurface()
RETURNS trigger AS $$
DECLARE
  cdb_schema CONSTANT varchar := split_part(TG_TABLE_NAME, '_', 1); 
BEGIN
EXECUTE format('PERFORM %I.del_waterboundary_surface(ARRAY[[%L]);', cdb_schema, OLD.id);
RETURN OLD;
EXCEPTION
  WHEN OTHERS THEN RAISE NOTICE 'qgis_pkg.tr_del_waterboundary_surface_watersurface(): %', SQLERRM;
END;
$$ LANGUAGE plpgsql;
COMMENT ON FUNCTION qgis_pkg.tr_ins_waterboundary_surface_watersurface IS 'Deletes record in table WATERBOUNDARY_SURFACE';
REVOKE EXECUTE ON FUNCTION qgis_pkg.tr_del_waterboundary_surface_watersurface FROM public;

----------------------------------------------------------------
-- Create trigger FUNCTION QGIS_PKG.TR_UPD_ADDRESS
----------------------------------------------------------------
DROP FUNCTION IF EXISTS    qgis_pkg.tr_upd_address CASCADE;
CREATE OR REPLACE FUNCTION qgis_pkg.tr_upd_address()
RETURNS trigger AS $$
DECLARE
  cdb_schema CONSTANT varchar := split_part(TG_TABLE_NAME, '_', 1);
  obj    qgis_pkg.obj_address;
BEGIN
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

PERFORM qgis_pkg.upd_address_atts(obj, cdb_schema);

RETURN NEW;
EXCEPTION
  WHEN OTHERS THEN RAISE NOTICE 'qgis_pkg.tr_upd_address(id: %): %', OLD.id, SQLERRM;
END;
$$ LANGUAGE plpgsql;
COMMENT ON FUNCTION qgis_pkg.tr_upd_address IS 'Updates record in table ADDRESS';
REVOKE EXECUTE ON FUNCTION qgis_pkg.tr_upd_address FROM public;

----------------------------------------------------------------
-- Create trigger FUNCTION QGIS_PKG.TR_UPD_APPEARANCE
----------------------------------------------------------------
DROP FUNCTION IF EXISTS    qgis_pkg.tr_upd_appearance CASCADE;
CREATE OR REPLACE FUNCTION qgis_pkg.tr_upd_appearance()
RETURNS trigger AS $$
DECLARE
  cdb_schema CONSTANT varchar := split_part(TG_TABLE_NAME, '_', 1);
  obj    qgis_pkg.obj_appearance;
BEGIN
obj.gmlid           := NEW.gmlid;
obj.gmlid_codespace := NEW.gmlid_codespace;
obj.name            := NEW.name;
obj.name_codespace  := NEW.name_codespace;
obj.description     := NEW.description;
obj.theme           := NEW.theme;

PERFORM qgis_pkg.upd_appearance_atts(obj, cdb_schema);

RETURN NEW;
EXCEPTION
  WHEN OTHERS THEN RAISE NOTICE 'qgis_pkg.tr_upd_appearance(id: %): %', OLD.id, SQLERRM;
END;
$$ LANGUAGE plpgsql;
COMMENT ON FUNCTION qgis_pkg.tr_upd_appearance IS 'Updates record in table APPEARANCE';
REVOKE EXECUTE ON FUNCTION qgis_pkg.tr_upd_appearance FROM public;

----------------------------------------------------------------
-- Create trigger FUNCTION QGIS_PKG.TR_UPD_BREAKLINE_RELIEF
----------------------------------------------------------------
DROP FUNCTION IF EXISTS    qgis_pkg.tr_upd_breakline_relief CASCADE;
CREATE OR REPLACE FUNCTION qgis_pkg.tr_upd_breakline_relief()
RETURNS trigger AS $$
DECLARE
  cdb_schema CONSTANT varchar := split_part(TG_TABLE_NAME, '_', 1);
  obj    qgis_pkg.obj_cityobject;
  obj_1  qgis_pkg.obj_relief_component;  
BEGIN
obj.id                     := OLD.id;
obj.gmlid                  := NEW.gmlid;
obj.gmlid_codespace        := NEW.gmlid_codespace;
obj.name                   := NEW.name;
obj.name_codespace         := NEW.name_codespace;
obj.description            := NEW.description;
obj.creation_date          := NEW.creation_date;
obj.termination_date       := NEW.termination_date;
obj.relative_to_terrain    := NEW.relative_to_terrain;
obj.relative_to_water      := NEW.relative_to_water;
obj.last_modification_date := NEW.last_modification_date;
obj.updating_person        := NEW.updating_person;
obj.reason_for_update      := NEW.reason_for_update;
obj.lineage                := NEW.lineage;

obj_1.id := OLD.id;
obj_1.lod  := NEW.lod;

PERFORM qgis_pkg.upd_breakline_relief_atts(obj, obj_1, cdb_schema);

RETURN NEW;
EXCEPTION
  WHEN OTHERS THEN RAISE NOTICE 'qgis_pkg.tr_upd_breakline_relief(id: %): %', OLD.id, SQLERRM;
END;
$$ LANGUAGE plpgsql;
COMMENT ON FUNCTION qgis_pkg.tr_upd_breakline_relief IS 'Updates record in table BREAKLINE_RELIEF';
REVOKE EXECUTE ON FUNCTION qgis_pkg.tr_upd_breakline_relief FROM public;

----------------------------------------------------------------
-- Create trigger FUNCTION QGIS_PKG.TR_UPD_BRIDGE
----------------------------------------------------------------
DROP FUNCTION IF EXISTS    qgis_pkg.tr_upd_bridge CASCADE;
CREATE OR REPLACE FUNCTION qgis_pkg.tr_upd_bridge()
RETURNS trigger AS $$
DECLARE
  cdb_schema CONSTANT varchar := split_part(TG_TABLE_NAME, '_', 1);
  obj    qgis_pkg.obj_cityobject;
  obj_1  qgis_pkg.obj_bridge;
BEGIN
obj.id                     := OLD.id;
obj.gmlid                  := NEW.gmlid;
obj.gmlid_codespace        := NEW.gmlid_codespace;
obj.name                   := NEW.name;
obj.name_codespace         := NEW.name_codespace;
obj.description            := NEW.description;
obj.creation_date          := NEW.creation_date;
obj.termination_date       := NEW.termination_date;
obj.relative_to_terrain    := NEW.relative_to_terrain;
obj.relative_to_water      := NEW.relative_to_water;
obj.last_modification_date := NEW.last_modification_date;
obj.updating_person        := NEW.updating_person;
obj.reason_for_update      := NEW.reason_for_update;
obj.lineage                := NEW.lineage;

obj_1.id                          := OLD.id;
obj_1.class                       := NEW.class;
obj_1.class_codespace             := NEW.class_codespace;
obj_1.function                    := array_to_string((SELECT array_agg(DISTINCT x) FROM unnest(NEW.function) AS t(x)), '--/\--');
obj_1.function_codespace          := array_to_string((SELECT array_agg(DISTINCT x) FROM unnest(NEW.function_codespace) AS t(x)), '--/\--');
obj_1.usage                       := array_to_string((SELECT array_agg(DISTINCT x) FROM unnest(NEW.usage) AS t(x)), '--/\--');
obj_1.usage_codespace             := array_to_string((SELECT array_agg(DISTINCT x) FROM unnest(NEW.usage_codespace) AS t(x)), '--/\--');
obj_1.year_of_construction        = NEW.year_of_construction;
obj_1.year_of_demolition          = NEW.year_of_demolition;
obj_1.is_movable                  = NEW.is_movable;

PERFORM qgis_pkg.upd_bridge_atts(obj, obj_1, cdb_schema);

RETURN NEW;
EXCEPTION
  WHEN OTHERS THEN RAISE NOTICE 'qgis_pkg.tr_upd_bridge(id: %): %', OLD.id, SQLERRM;
END;
$$ LANGUAGE plpgsql;
COMMENT ON FUNCTION qgis_pkg.tr_upd_bridge IS 'Updates record in table BRIDGE';
REVOKE EXECUTE ON FUNCTION qgis_pkg.tr_upd_bridge FROM public;

----------------------------------------------------------------
-- Create trigger FUNCTION QGIS_PKG.TR_UPD_BRIDGE_CONSTR_ELEMENT
----------------------------------------------------------------
DROP FUNCTION IF EXISTS    qgis_pkg.tr_upd_bridge_constr_element CASCADE;
CREATE OR REPLACE FUNCTION qgis_pkg.tr_upd_bridge_constr_element()
RETURNS trigger AS $$
DECLARE
  cdb_schema CONSTANT varchar := split_part(TG_TABLE_NAME, '_', 1);
  obj    qgis_pkg.obj_cityobject;
  obj_1  qgis_pkg.obj_bridge_constr_element;
BEGIN
obj.id                     := OLD.id;
obj.gmlid                  := NEW.gmlid;
obj.gmlid_codespace        := NEW.gmlid_codespace;
obj.name                   := NEW.name;
obj.name_codespace         := NEW.name_codespace;
obj.description            := NEW.description;
obj.creation_date          := NEW.creation_date;
obj.termination_date       := NEW.termination_date;
obj.relative_to_terrain    := NEW.relative_to_terrain;
obj.relative_to_water      := NEW.relative_to_water;
obj.last_modification_date := NEW.last_modification_date;
obj.updating_person        := NEW.updating_person;
obj.reason_for_update      := NEW.reason_for_update;
obj.lineage                := NEW.lineage;

obj_1.id                          := OLD.id;
obj_1.class                       := NEW.class;
obj_1.class_codespace             := NEW.class_codespace;
obj_1.function                    := array_to_string((SELECT array_agg(DISTINCT x) FROM unnest(NEW.function) AS t(x)), '--/\--');
obj_1.function_codespace          := array_to_string((SELECT array_agg(DISTINCT x) FROM unnest(NEW.function_codespace) AS t(x)), '--/\--');
obj_1.usage                       := array_to_string((SELECT array_agg(DISTINCT x) FROM unnest(NEW.usage) AS t(x)), '--/\--');
obj_1.usage_codespace             := array_to_string((SELECT array_agg(DISTINCT x) FROM unnest(NEW.usage_codespace) AS t(x)), '--/\--');
PERFORM qgis_pkg.upd_bridge_constr_element_atts(obj, obj_1, cdb_schema);

RETURN NEW;
EXCEPTION
  WHEN OTHERS THEN RAISE NOTICE 'qgis_pkg.tr_upd_bridge_constr_element(id: %): %', OLD.id, SQLERRM;
END;
$$ LANGUAGE plpgsql;
COMMENT ON FUNCTION qgis_pkg.tr_upd_bridge_constr_element IS 'Updates record in table BRIDGE_CONSTR_ELEMENT';
REVOKE EXECUTE ON FUNCTION qgis_pkg.tr_upd_bridge_constr_element FROM public;

----------------------------------------------------------------
-- Create trigger FUNCTION QGIS_PKG.TR_UPD_BRIDGE_FURNITURE
----------------------------------------------------------------
DROP FUNCTION IF EXISTS    qgis_pkg.tr_upd_bridge_furniture CASCADE;
CREATE OR REPLACE FUNCTION qgis_pkg.tr_upd_bridge_furniture()
RETURNS trigger AS $$
DECLARE
  cdb_schema CONSTANT varchar := split_part(TG_TABLE_NAME, '_', 1);
  obj    qgis_pkg.obj_cityobject;
  obj_1  qgis_pkg.obj_bridge_furniture;
BEGIN
obj.id                     := OLD.id;
obj.gmlid                  := NEW.gmlid;
obj.gmlid_codespace        := NEW.gmlid_codespace;
obj.name                   := NEW.name;
obj.name_codespace         := NEW.name_codespace;
obj.description            := NEW.description;
obj.creation_date          := NEW.creation_date;
obj.termination_date       := NEW.termination_date;
obj.relative_to_terrain    := NEW.relative_to_terrain;
obj.relative_to_water      := NEW.relative_to_water;
obj.last_modification_date := NEW.last_modification_date;
obj.updating_person        := NEW.updating_person;
obj.reason_for_update      := NEW.reason_for_update;
obj.lineage                := NEW.lineage;

obj_1.id                          := OLD.id;
obj_1.class                       := NEW.class;
obj_1.class_codespace             := NEW.class_codespace;
obj_1.function                    := array_to_string((SELECT array_agg(DISTINCT x) FROM unnest(NEW.function) AS t(x)), '--/\--');
obj_1.function_codespace          := array_to_string((SELECT array_agg(DISTINCT x) FROM unnest(NEW.function_codespace) AS t(x)), '--/\--');
obj_1.usage                       := array_to_string((SELECT array_agg(DISTINCT x) FROM unnest(NEW.usage) AS t(x)), '--/\--');
obj_1.usage_codespace             := array_to_string((SELECT array_agg(DISTINCT x) FROM unnest(NEW.usage_codespace) AS t(x)), '--/\--');
PERFORM qgis_pkg.upd_bridge_furniture_atts(obj, obj_1, cdb_schema);

RETURN NEW;
EXCEPTION
  WHEN OTHERS THEN RAISE NOTICE 'qgis_pkg.tr_upd_bridge_furniture(id: %): %', OLD.id, SQLERRM;
END;
$$ LANGUAGE plpgsql;
COMMENT ON FUNCTION qgis_pkg.tr_upd_bridge_furniture IS 'Updates record in table BRIDGE_FURNITURE';
REVOKE EXECUTE ON FUNCTION qgis_pkg.tr_upd_bridge_furniture FROM public;

----------------------------------------------------------------
-- Create trigger FUNCTION QGIS_PKG.TR_UPD_BRIDGE_INSTALLATION
----------------------------------------------------------------
DROP FUNCTION IF EXISTS    qgis_pkg.tr_upd_bridge_installation CASCADE;
CREATE OR REPLACE FUNCTION qgis_pkg.tr_upd_bridge_installation()
RETURNS trigger AS $$
DECLARE
  cdb_schema CONSTANT varchar := split_part(TG_TABLE_NAME, '_', 1);
  obj    qgis_pkg.obj_cityobject;
  obj_1  qgis_pkg.obj_bridge_installation;
BEGIN
obj.id                     := OLD.id;
obj.gmlid                  := NEW.gmlid;
obj.gmlid_codespace        := NEW.gmlid_codespace;
obj.name                   := NEW.name;
obj.name_codespace         := NEW.name_codespace;
obj.description            := NEW.description;
obj.creation_date          := NEW.creation_date;
obj.termination_date       := NEW.termination_date;
obj.relative_to_terrain    := NEW.relative_to_terrain;
obj.relative_to_water      := NEW.relative_to_water;
obj.last_modification_date := NEW.last_modification_date;
obj.updating_person        := NEW.updating_person;
obj.reason_for_update      := NEW.reason_for_update;
obj.lineage                := NEW.lineage;

obj_1.id                          := OLD.id;
obj_1.class                       := NEW.class;
obj_1.class_codespace             := NEW.class_codespace;
obj_1.function                    := array_to_string((SELECT array_agg(DISTINCT x) FROM unnest(NEW.function) AS t(x)), '--/\--');
obj_1.function_codespace          := array_to_string((SELECT array_agg(DISTINCT x) FROM unnest(NEW.function_codespace) AS t(x)), '--/\--');
obj_1.usage                       := array_to_string((SELECT array_agg(DISTINCT x) FROM unnest(NEW.usage) AS t(x)), '--/\--');
obj_1.usage_codespace             := array_to_string((SELECT array_agg(DISTINCT x) FROM unnest(NEW.usage_codespace) AS t(x)), '--/\--');
PERFORM qgis_pkg.upd_bridge_installation_atts(obj, obj_1, cdb_schema);

RETURN NEW;
EXCEPTION
  WHEN OTHERS THEN RAISE NOTICE 'qgis_pkg.tr_upd_bridge_installation(id: %): %', OLD.id, SQLERRM;
END;
$$ LANGUAGE plpgsql;
COMMENT ON FUNCTION qgis_pkg.tr_upd_bridge_installation IS 'Updates record in table BRIDGE_INSTALLATION';
REVOKE EXECUTE ON FUNCTION qgis_pkg.tr_upd_bridge_installation FROM public;

----------------------------------------------------------------
-- Create trigger FUNCTION QGIS_PKG.TR_UPD_BRIDGE_OPENING
----------------------------------------------------------------
DROP FUNCTION IF EXISTS    qgis_pkg.tr_upd_bridge_opening CASCADE;
CREATE OR REPLACE FUNCTION qgis_pkg.tr_upd_bridge_opening()
RETURNS trigger AS $$
DECLARE
  cdb_schema CONSTANT varchar := split_part(TG_TABLE_NAME, '_', 1);
  obj    qgis_pkg.obj_cityobject;
BEGIN
obj.id                     := OLD.id;
obj.gmlid                  := NEW.gmlid;
obj.gmlid_codespace        := NEW.gmlid_codespace;
obj.name                   := NEW.name;
obj.name_codespace         := NEW.name_codespace;
obj.description            := NEW.description;
obj.creation_date          := NEW.creation_date;
obj.termination_date       := NEW.termination_date;
obj.relative_to_terrain    := NEW.relative_to_terrain;
obj.relative_to_water      := NEW.relative_to_water;
obj.last_modification_date := NEW.last_modification_date;
obj.updating_person        := NEW.updating_person;
obj.reason_for_update      := NEW.reason_for_update;
obj.lineage                := NEW.lineage;

PERFORM qgis_pkg.upd_bridge_opening_atts(obj, cdb_schema);	

RETURN NEW;
EXCEPTION
  WHEN OTHERS THEN RAISE NOTICE 'qgis_pkg.tr_upd_bridge_opening(id: %): %', OLD.id, SQLERRM;
END;
$$ LANGUAGE plpgsql;
COMMENT ON FUNCTION qgis_pkg.tr_upd_bridge_opening IS 'Updates record in table BRIDGE_OPENING';
REVOKE EXECUTE ON FUNCTION qgis_pkg.tr_upd_bridge_opening FROM public;

----------------------------------------------------------------
-- Create trigger FUNCTION QGIS_PKG.TR_UPD_BRIDGE_ROOM
----------------------------------------------------------------
DROP FUNCTION IF EXISTS    qgis_pkg.tr_upd_bridge_room CASCADE;
CREATE OR REPLACE FUNCTION qgis_pkg.tr_upd_bridge_room()
RETURNS trigger AS $$
DECLARE
  cdb_schema CONSTANT varchar := split_part(TG_TABLE_NAME, '_', 1);
  obj    qgis_pkg.obj_cityobject;
  obj_1  qgis_pkg.obj_bridge_room;
BEGIN
obj.id                     := OLD.id;
obj.gmlid                  := NEW.gmlid;
obj.gmlid_codespace        := NEW.gmlid_codespace;
obj.name                   := NEW.name;
obj.name_codespace         := NEW.name_codespace;
obj.description            := NEW.description;
obj.creation_date          := NEW.creation_date;
obj.termination_date       := NEW.termination_date;
obj.relative_to_terrain    := NEW.relative_to_terrain;
obj.relative_to_water      := NEW.relative_to_water;
obj.last_modification_date := NEW.last_modification_date;
obj.updating_person        := NEW.updating_person;
obj.reason_for_update      := NEW.reason_for_update;
obj.lineage                := NEW.lineage;

obj_1.id                          := OLD.id;
obj_1.class                       := NEW.class;
obj_1.class_codespace             := NEW.class_codespace;
obj_1.function                    := array_to_string((SELECT array_agg(DISTINCT x) FROM unnest(NEW.function) AS t(x)), '--/\--');
obj_1.function_codespace          := array_to_string((SELECT array_agg(DISTINCT x) FROM unnest(NEW.function_codespace) AS t(x)), '--/\--');
obj_1.usage                       := array_to_string((SELECT array_agg(DISTINCT x) FROM unnest(NEW.usage) AS t(x)), '--/\--');
obj_1.usage_codespace             := array_to_string((SELECT array_agg(DISTINCT x) FROM unnest(NEW.usage_codespace) AS t(x)), '--/\--');
PERFORM qgis_pkg.upd_bridge_room_atts(obj, obj_1, cdb_schema);

RETURN NEW;
EXCEPTION
  WHEN OTHERS THEN RAISE NOTICE 'qgis_pkg.tr_upd_bridge_room(id: %): %', OLD.id, SQLERRM;
END;
$$ LANGUAGE plpgsql;
COMMENT ON FUNCTION qgis_pkg.tr_upd_bridge_room IS 'Updates record in table BRIDGE_ROOM';
REVOKE EXECUTE ON FUNCTION qgis_pkg.tr_upd_bridge_room FROM public;

----------------------------------------------------------------
-- Create trigger FUNCTION QGIS_PKG.TR_UPD_BRIDGE_THEMATIC_SURFACE
----------------------------------------------------------------
DROP FUNCTION IF EXISTS    qgis_pkg.tr_upd_bridge_thematic_surface CASCADE;
CREATE OR REPLACE FUNCTION qgis_pkg.tr_upd_bridge_thematic_surface()
RETURNS trigger AS $$
DECLARE
  cdb_schema CONSTANT varchar := split_part(TG_TABLE_NAME, '_', 1);
  obj    qgis_pkg.obj_cityobject;
BEGIN
obj.id                     := OLD.id;
obj.gmlid                  := NEW.gmlid;
obj.gmlid_codespace        := NEW.gmlid_codespace;
obj.name                   := NEW.name;
obj.name_codespace         := NEW.name_codespace;
obj.description            := NEW.description;
obj.creation_date          := NEW.creation_date;
obj.termination_date       := NEW.termination_date;
obj.relative_to_terrain    := NEW.relative_to_terrain;
obj.relative_to_water      := NEW.relative_to_water;
obj.last_modification_date := NEW.last_modification_date;
obj.updating_person        := NEW.updating_person;
obj.reason_for_update      := NEW.reason_for_update;
obj.lineage                := NEW.lineage;

PERFORM qgis_pkg.upd_bridge_thematic_surface_atts(obj, cdb_schema);	

RETURN NEW;
EXCEPTION
  WHEN OTHERS THEN RAISE NOTICE 'qgis_pkg.tr_upd_bridge_thematic_surface(id: %): %', OLD.id, SQLERRM;
END;
$$ LANGUAGE plpgsql;
COMMENT ON FUNCTION qgis_pkg.tr_upd_bridge_thematic_surface IS 'Updates record in table BRIDGE_THEMATIC_SURFACE';
REVOKE EXECUTE ON FUNCTION qgis_pkg.tr_upd_bridge_thematic_surface FROM public;

----------------------------------------------------------------
-- Create trigger FUNCTION QGIS_PKG.TR_UPD_BUILDING
----------------------------------------------------------------
DROP FUNCTION IF EXISTS    qgis_pkg.tr_upd_building CASCADE;
CREATE OR REPLACE FUNCTION qgis_pkg.tr_upd_building()
RETURNS trigger AS $$
DECLARE
  cdb_schema CONSTANT varchar := split_part(TG_TABLE_NAME, '_', 1);
  obj    qgis_pkg.obj_cityobject;
  obj_1  qgis_pkg.obj_building;
BEGIN
obj.id                     := OLD.id;
obj.gmlid                  := NEW.gmlid;
obj.gmlid_codespace        := NEW.gmlid_codespace;
obj.name                   := NEW.name;
obj.name_codespace         := NEW.name_codespace;
obj.description            := NEW.description;
obj.creation_date          := NEW.creation_date;
obj.termination_date       := NEW.termination_date;
obj.relative_to_terrain    := NEW.relative_to_terrain;
obj.relative_to_water      := NEW.relative_to_water;
obj.last_modification_date := NEW.last_modification_date;
obj.updating_person        := NEW.updating_person;
obj.reason_for_update      := NEW.reason_for_update;
obj.lineage                := NEW.lineage;

obj_1.id                          := OLD.id;
obj_1.class                       := NEW.class;
obj_1.class_codespace             := NEW.class_codespace;
obj_1.function                    := array_to_string((SELECT array_agg(DISTINCT x) FROM unnest(NEW.function) AS t(x)), '--/\--');
obj_1.function_codespace          := array_to_string((SELECT array_agg(DISTINCT x) FROM unnest(NEW.function_codespace) AS t(x)), '--/\--');
obj_1.usage                       := array_to_string((SELECT array_agg(DISTINCT x) FROM unnest(NEW.usage) AS t(x)), '--/\--');
obj_1.usage_codespace             := array_to_string((SELECT array_agg(DISTINCT x) FROM unnest(NEW.usage_codespace) AS t(x)), '--/\--');
obj_1.year_of_construction        := NEW.year_of_construction;
obj_1.year_of_demolition          := NEW.year_of_demolition;
obj_1.roof_type                   := NEW.roof_type;
obj_1.roof_type_codespace         := NEW.roof_type_codespace;
obj_1.measured_height             := NEW.measured_height;
obj_1.measured_height_unit        := NEW.measured_height_unit;
obj_1.storeys_above_ground        := NEW.storeys_above_ground;
obj_1.storeys_below_ground        := NEW.storeys_below_ground;
obj_1.storey_heights_above_ground := NEW.storey_heights_above_ground;
obj_1.storey_heights_ag_unit      := NEW.storey_heights_ag_unit;
obj_1.storey_heights_below_ground := NEW.storey_heights_below_ground;
obj_1.storey_heights_bg_unit      := NEW.storey_heights_bg_unit;

PERFORM qgis_pkg.upd_building_atts(obj, obj_1, cdb_schema);

RETURN NEW;
EXCEPTION
  WHEN OTHERS THEN RAISE NOTICE 'qgis_pkg.tr_upd_building(id: %): %', OLD.id, SQLERRM;
END;
$$ LANGUAGE plpgsql;
COMMENT ON FUNCTION qgis_pkg.tr_upd_building IS 'Updates record in table BUILDING';
REVOKE EXECUTE ON FUNCTION qgis_pkg.tr_upd_building FROM public;

----------------------------------------------------------------
-- Create trigger FUNCTION QGIS_PKG.TR_UPD_BUILDING_FURNITURE
----------------------------------------------------------------
DROP FUNCTION IF EXISTS    qgis_pkg.tr_upd_building_furniture CASCADE;
CREATE OR REPLACE FUNCTION qgis_pkg.tr_upd_building_furniture()
RETURNS trigger AS $$
DECLARE
  cdb_schema CONSTANT varchar := split_part(TG_TABLE_NAME, '_', 1);
  obj    qgis_pkg.obj_cityobject;
  obj_1  qgis_pkg.obj_building_furniture;
BEGIN
obj.id                     := OLD.id;
obj.gmlid                  := NEW.gmlid;
obj.gmlid_codespace        := NEW.gmlid_codespace;
obj.name                   := NEW.name;
obj.name_codespace         := NEW.name_codespace;
obj.description            := NEW.description;
obj.creation_date          := NEW.creation_date;
obj.termination_date       := NEW.termination_date;
obj.relative_to_terrain    := NEW.relative_to_terrain;
obj.relative_to_water      := NEW.relative_to_water;
obj.last_modification_date := NEW.last_modification_date;
obj.updating_person        := NEW.updating_person;
obj.reason_for_update      := NEW.reason_for_update;
obj.lineage                := NEW.lineage;

obj_1.id                          := OLD.id;
obj_1.class                       := NEW.class;
obj_1.class_codespace             := NEW.class_codespace;
obj_1.function                    := array_to_string((SELECT array_agg(DISTINCT x) FROM unnest(NEW.function) AS t(x)), '--/\--');
obj_1.function_codespace          := array_to_string((SELECT array_agg(DISTINCT x) FROM unnest(NEW.function_codespace) AS t(x)), '--/\--');
obj_1.usage                       := array_to_string((SELECT array_agg(DISTINCT x) FROM unnest(NEW.usage) AS t(x)), '--/\--');
obj_1.usage_codespace             := array_to_string((SELECT array_agg(DISTINCT x) FROM unnest(NEW.usage_codespace) AS t(x)), '--/\--');
PERFORM qgis_pkg.upd_building_furniture_atts(obj, obj_1, cdb_schema);

RETURN NEW;
EXCEPTION
  WHEN OTHERS THEN RAISE NOTICE 'qgis_pkg.tr_upd_building_furniture(id: %): %', OLD.id, SQLERRM;
END;
$$ LANGUAGE plpgsql;
COMMENT ON FUNCTION qgis_pkg.tr_upd_building_furniture IS 'Updates record in table BUILDING_FURNITURE';
REVOKE EXECUTE ON FUNCTION qgis_pkg.tr_upd_building_furniture FROM public;

----------------------------------------------------------------
-- Create trigger FUNCTION QGIS_PKG.TR_UPD_BUILDING_INSTALLATION
----------------------------------------------------------------
DROP FUNCTION IF EXISTS    qgis_pkg.tr_upd_building_installation CASCADE;
CREATE OR REPLACE FUNCTION qgis_pkg.tr_upd_building_installation()
RETURNS trigger AS $$
DECLARE
  cdb_schema CONSTANT varchar := split_part(TG_TABLE_NAME, '_', 1);
  obj    qgis_pkg.obj_cityobject;
  obj_1  qgis_pkg.obj_building_installation;
BEGIN
obj.id                     := OLD.id;
obj.gmlid                  := NEW.gmlid;
obj.gmlid_codespace        := NEW.gmlid_codespace;
obj.name                   := NEW.name;
obj.name_codespace         := NEW.name_codespace;
obj.description            := NEW.description;
obj.creation_date          := NEW.creation_date;
obj.termination_date       := NEW.termination_date;
obj.relative_to_terrain    := NEW.relative_to_terrain;
obj.relative_to_water      := NEW.relative_to_water;
obj.last_modification_date := NEW.last_modification_date;
obj.updating_person        := NEW.updating_person;
obj.reason_for_update      := NEW.reason_for_update;
obj.lineage                := NEW.lineage;

obj_1.id                          := OLD.id;
obj_1.class                       := NEW.class;
obj_1.class_codespace             := NEW.class_codespace;
obj_1.function                    := array_to_string((SELECT array_agg(DISTINCT x) FROM unnest(NEW.function) AS t(x)), '--/\--');
obj_1.function_codespace          := array_to_string((SELECT array_agg(DISTINCT x) FROM unnest(NEW.function_codespace) AS t(x)), '--/\--');
obj_1.usage                       := array_to_string((SELECT array_agg(DISTINCT x) FROM unnest(NEW.usage) AS t(x)), '--/\--');
obj_1.usage_codespace             := array_to_string((SELECT array_agg(DISTINCT x) FROM unnest(NEW.usage_codespace) AS t(x)), '--/\--');
PERFORM qgis_pkg.upd_building_installation_atts(obj, obj_1, cdb_schema);

RETURN NEW;
EXCEPTION
  WHEN OTHERS THEN RAISE NOTICE 'qgis_pkg.tr_upd_building_installation(id: %): %', OLD.id, SQLERRM;
END;
$$ LANGUAGE plpgsql;
COMMENT ON FUNCTION qgis_pkg.tr_upd_building_installation IS 'Updates record in table BUILDING_INSTALLATION';
REVOKE EXECUTE ON FUNCTION qgis_pkg.tr_upd_building_installation FROM public;

----------------------------------------------------------------
-- Create trigger FUNCTION QGIS_PKG.TR_UPD_CITY_FURNITURE
----------------------------------------------------------------
DROP FUNCTION IF EXISTS    qgis_pkg.tr_upd_city_furniture CASCADE;
CREATE OR REPLACE FUNCTION qgis_pkg.tr_upd_city_furniture()
RETURNS trigger AS $$
DECLARE
  cdb_schema CONSTANT varchar := split_part(TG_TABLE_NAME, '_', 1);
  obj    qgis_pkg.obj_cityobject;
  obj_1  qgis_pkg.obj_city_furniture;
BEGIN
obj.id                     := OLD.id;
obj.gmlid                  := NEW.gmlid;
obj.gmlid_codespace        := NEW.gmlid_codespace;
obj.name                   := NEW.name;
obj.name_codespace         := NEW.name_codespace;
obj.description            := NEW.description;
obj.creation_date          := NEW.creation_date;
obj.termination_date       := NEW.termination_date;
obj.relative_to_terrain    := NEW.relative_to_terrain;
obj.relative_to_water      := NEW.relative_to_water;
obj.last_modification_date := NEW.last_modification_date;
obj.updating_person        := NEW.updating_person;
obj.reason_for_update      := NEW.reason_for_update;
obj.lineage                := NEW.lineage;

obj_1.id                          := OLD.id;
obj_1.class                       := NEW.class;
obj_1.class_codespace             := NEW.class_codespace;
obj_1.function                    := array_to_string((SELECT array_agg(DISTINCT x) FROM unnest(NEW.function) AS t(x)), '--/\--');
obj_1.function_codespace          := array_to_string((SELECT array_agg(DISTINCT x) FROM unnest(NEW.function_codespace) AS t(x)), '--/\--');
obj_1.usage                       := array_to_string((SELECT array_agg(DISTINCT x) FROM unnest(NEW.usage) AS t(x)), '--/\--');
obj_1.usage_codespace             := array_to_string((SELECT array_agg(DISTINCT x) FROM unnest(NEW.usage_codespace) AS t(x)), '--/\--');
PERFORM qgis_pkg.upd_city_furniture_atts(obj, obj_1, cdb_schema);

RETURN NEW;
EXCEPTION
  WHEN OTHERS THEN RAISE NOTICE 'qgis_pkg.tr_upd_city_furniture(id: %): %', OLD.id, SQLERRM;
END;
$$ LANGUAGE plpgsql;
COMMENT ON FUNCTION qgis_pkg.tr_upd_city_furniture IS 'Updates record in table CITY_FURNITURE';
REVOKE EXECUTE ON FUNCTION qgis_pkg.tr_upd_city_furniture FROM public;

----------------------------------------------------------------
-- Create trigger FUNCTION QGIS_PKG.TR_UPD_CITYOBJECT_GENERICATTRIB
----------------------------------------------------------------
DROP FUNCTION IF EXISTS    qgis_pkg.tr_upd_cityobject_genericattrib CASCADE;
CREATE OR REPLACE FUNCTION qgis_pkg.tr_upd_cityobject_genericattrib()
RETURNS trigger AS $$
DECLARE
  cdb_schema CONSTANT varchar := split_part(TG_TABLE_NAME, '_', 1);
  obj    qgis_pkg.obj_cityobject_genericattrib;
BEGIN
obj.id                     := OLD.id;
obj.attrname               := NEW.attrname;
obj.strval                 := NEW.strval;
obj.intval                 := NEW.intval;
obj.realval                := NEW.realval;
obj.urival                 := NEW.urival;
obj.dateval                := NEW.dateval;
obj.unit                   := NEW.unit;
obj.genattribset_codespace := NEW.genattribset_codespace;
obj.blobval                := NEW.blobval;

PERFORM qgis_pkg.upd_cityobject_genericattrib_atts(obj, cdb_schema);

RETURN NEW;
EXCEPTION
  WHEN OTHERS THEN RAISE NOTICE 'qgis_pkg.tr_upd_cityobject_genericattrib(id: %): %', OLD.id, SQLERRM;
END;
$$ LANGUAGE plpgsql;
COMMENT ON FUNCTION qgis_pkg.tr_upd_cityobject_genericattrib IS 'Updates record in table CITYOBJECT_GENERICATTRIB';
REVOKE EXECUTE ON FUNCTION qgis_pkg.tr_upd_cityobject_genericattrib FROM public;

----------------------------------------------------------------
-- Create trigger FUNCTION QGIS_PKG.TR_UPD_CITYOBJECTGROUP
----------------------------------------------------------------
DROP FUNCTION IF EXISTS    qgis_pkg.tr_upd_cityobjectgroup CASCADE;
CREATE OR REPLACE FUNCTION qgis_pkg.tr_upd_cityobjectgroup()
RETURNS trigger AS $$
DECLARE
  cdb_schema CONSTANT varchar := split_part(TG_TABLE_NAME, '_', 1);
  obj    qgis_pkg.obj_cityobject;
  obj_1  qgis_pkg.obj_cityobjectgroup;
BEGIN
obj.id                     := OLD.id;
obj.gmlid                  := NEW.gmlid;
obj.gmlid_codespace        := NEW.gmlid_codespace;
obj.name                   := NEW.name;
obj.name_codespace         := NEW.name_codespace;
obj.description            := NEW.description;
obj.creation_date          := NEW.creation_date;
obj.termination_date       := NEW.termination_date;
obj.relative_to_terrain    := NEW.relative_to_terrain;
obj.relative_to_water      := NEW.relative_to_water;
obj.last_modification_date := NEW.last_modification_date;
obj.updating_person        := NEW.updating_person;
obj.reason_for_update      := NEW.reason_for_update;
obj.lineage                := NEW.lineage;

obj_1.id                          := OLD.id;
obj_1.class                       := NEW.class;
obj_1.class_codespace             := NEW.class_codespace;
obj_1.function                    := array_to_string((SELECT array_agg(DISTINCT x) FROM unnest(NEW.function) AS t(x)), '--/\--');
obj_1.function_codespace          := array_to_string((SELECT array_agg(DISTINCT x) FROM unnest(NEW.function_codespace) AS t(x)), '--/\--');
obj_1.usage                       := array_to_string((SELECT array_agg(DISTINCT x) FROM unnest(NEW.usage) AS t(x)), '--/\--');
obj_1.usage_codespace             := array_to_string((SELECT array_agg(DISTINCT x) FROM unnest(NEW.usage_codespace) AS t(x)), '--/\--');
PERFORM qgis_pkg.upd_cityobjectgroup_atts(obj, obj_1, cdb_schema);

RETURN NEW;
EXCEPTION
  WHEN OTHERS THEN RAISE NOTICE 'qgis_pkg.tr_upd_cityobjectgroup(id: %): %', OLD.id, SQLERRM;
END;
$$ LANGUAGE plpgsql;
COMMENT ON FUNCTION qgis_pkg.tr_upd_cityobjectgroup IS 'Updates record in table CITYOBJECTGROUP';
REVOKE EXECUTE ON FUNCTION qgis_pkg.tr_upd_cityobjectgroup FROM public;

----------------------------------------------------------------
-- Create trigger FUNCTION QGIS_PKG.TR_UPD_EXTERNAL_REFERENCE
----------------------------------------------------------------
DROP FUNCTION IF EXISTS    qgis_pkg.tr_upd_external_reference CASCADE;
CREATE OR REPLACE FUNCTION qgis_pkg.tr_upd_external_reference()
RETURNS trigger AS $$
DECLARE
  cdb_schema CONSTANT varchar := split_part(TG_TABLE_NAME, '_', 1);
  obj    qgis_pkg.obj_external_reference;
BEGIN
obj.id            := OLD.id;
obj.infosys       := NEW.infosys;
obj.name          := NEW.name;
obj.uri           := NEW.uri;

PERFORM qgis_pkg.upd_external_reference_atts(obj, cdb_schema);

RETURN NEW;
EXCEPTION
  WHEN OTHERS THEN RAISE NOTICE 'qgis_pkg.tr_upd_external_reference(id: %): %', OLD.id, SQLERRM;
END;
$$ LANGUAGE plpgsql;
COMMENT ON FUNCTION qgis_pkg.tr_upd_external_reference IS 'Updates record in table EXTERNAL_REFERENCE';
REVOKE EXECUTE ON FUNCTION qgis_pkg.tr_upd_external_reference FROM public;

----------------------------------------------------------------
-- Create trigger FUNCTION QGIS_PKG.TR_UPD_GENERIC_CITYOBJECT
----------------------------------------------------------------
DROP FUNCTION IF EXISTS    qgis_pkg.tr_upd_generic_cityobject CASCADE;
CREATE OR REPLACE FUNCTION qgis_pkg.tr_upd_generic_cityobject()
RETURNS trigger AS $$
DECLARE
  cdb_schema CONSTANT varchar := split_part(TG_TABLE_NAME, '_', 1);
  obj    qgis_pkg.obj_cityobject;
  obj_1  qgis_pkg.obj_generic_cityobject;
BEGIN
obj.id                     := OLD.id;
obj.gmlid                  := NEW.gmlid;
obj.gmlid_codespace        := NEW.gmlid_codespace;
obj.name                   := NEW.name;
obj.name_codespace         := NEW.name_codespace;
obj.description            := NEW.description;
obj.creation_date          := NEW.creation_date;
obj.termination_date       := NEW.termination_date;
obj.relative_to_terrain    := NEW.relative_to_terrain;
obj.relative_to_water      := NEW.relative_to_water;
obj.last_modification_date := NEW.last_modification_date;
obj.updating_person        := NEW.updating_person;
obj.reason_for_update      := NEW.reason_for_update;
obj.lineage                := NEW.lineage;

obj_1.id                          := OLD.id;
obj_1.class                       := NEW.class;
obj_1.class_codespace             := NEW.class_codespace;
obj_1.function                    := array_to_string((SELECT array_agg(DISTINCT x) FROM unnest(NEW.function) AS t(x)), '--/\--');
obj_1.function_codespace          := array_to_string((SELECT array_agg(DISTINCT x) FROM unnest(NEW.function_codespace) AS t(x)), '--/\--');
obj_1.usage                       := array_to_string((SELECT array_agg(DISTINCT x) FROM unnest(NEW.usage) AS t(x)), '--/\--');
obj_1.usage_codespace             := array_to_string((SELECT array_agg(DISTINCT x) FROM unnest(NEW.usage_codespace) AS t(x)), '--/\--');
PERFORM qgis_pkg.upd_generic_cityobject_atts(obj, obj_1, cdb_schema);

RETURN NEW;
EXCEPTION
  WHEN OTHERS THEN RAISE NOTICE 'qgis_pkg.tr_upd_generic_cityobject(id: %): %', OLD.id, SQLERRM;
END;
$$ LANGUAGE plpgsql;
COMMENT ON FUNCTION qgis_pkg.tr_upd_generic_cityobject IS 'Updates record in table GENERIC_CITYOBJECT';
REVOKE EXECUTE ON FUNCTION qgis_pkg.tr_upd_generic_cityobject FROM public;

----------------------------------------------------------------
-- Create trigger FUNCTION QGIS_PKG.TR_UPD_LAND_USE
----------------------------------------------------------------
DROP FUNCTION IF EXISTS    qgis_pkg.tr_upd_land_use CASCADE;
CREATE OR REPLACE FUNCTION qgis_pkg.tr_upd_land_use()
RETURNS trigger AS $$
DECLARE
  cdb_schema CONSTANT varchar := split_part(TG_TABLE_NAME, '_', 1);
  obj    qgis_pkg.obj_cityobject;
  obj_1  qgis_pkg.obj_land_use;
BEGIN
obj.id                     := OLD.id;
obj.gmlid                  := NEW.gmlid;
obj.gmlid_codespace        := NEW.gmlid_codespace;
obj.name                   := NEW.name;
obj.name_codespace         := NEW.name_codespace;
obj.description            := NEW.description;
obj.creation_date          := NEW.creation_date;
obj.termination_date       := NEW.termination_date;
obj.relative_to_terrain    := NEW.relative_to_terrain;
obj.relative_to_water      := NEW.relative_to_water;
obj.last_modification_date := NEW.last_modification_date;
obj.updating_person        := NEW.updating_person;
obj.reason_for_update      := NEW.reason_for_update;
obj.lineage                := NEW.lineage;

obj_1.id                          := OLD.id;
obj_1.class                       := NEW.class;
obj_1.class_codespace             := NEW.class_codespace;
obj_1.function                    := array_to_string((SELECT array_agg(DISTINCT x) FROM unnest(NEW.function) AS t(x)), '--/\--');
obj_1.function_codespace          := array_to_string((SELECT array_agg(DISTINCT x) FROM unnest(NEW.function_codespace) AS t(x)), '--/\--');
obj_1.usage                       := array_to_string((SELECT array_agg(DISTINCT x) FROM unnest(NEW.usage) AS t(x)), '--/\--');
obj_1.usage_codespace             := array_to_string((SELECT array_agg(DISTINCT x) FROM unnest(NEW.usage_codespace) AS t(x)), '--/\--');
PERFORM qgis_pkg.upd_land_use_atts(obj, obj_1, cdb_schema);

RETURN NEW;
EXCEPTION
  WHEN OTHERS THEN RAISE NOTICE 'qgis_pkg.tr_upd_land_use(id: %): %', OLD.id, SQLERRM;
END;
$$ LANGUAGE plpgsql;
COMMENT ON FUNCTION qgis_pkg.tr_upd_land_use IS 'Updates record in table LAND_USE';
REVOKE EXECUTE ON FUNCTION qgis_pkg.tr_upd_land_use FROM public;

----------------------------------------------------------------
-- Create trigger FUNCTION QGIS_PKG.TR_UPD_MASSPOINT_RELIEF
----------------------------------------------------------------
DROP FUNCTION IF EXISTS    qgis_pkg.tr_upd_masspoint_relief CASCADE;
CREATE OR REPLACE FUNCTION qgis_pkg.tr_upd_masspoint_relief()
RETURNS trigger AS $$
DECLARE
  cdb_schema CONSTANT varchar := split_part(TG_TABLE_NAME, '_', 1);
  obj    qgis_pkg.obj_cityobject;
  obj_1  qgis_pkg.obj_relief_component;  
BEGIN
obj.id                     := OLD.id;
obj.gmlid                  := NEW.gmlid;
obj.gmlid_codespace        := NEW.gmlid_codespace;
obj.name                   := NEW.name;
obj.name_codespace         := NEW.name_codespace;
obj.description            := NEW.description;
obj.creation_date          := NEW.creation_date;
obj.termination_date       := NEW.termination_date;
obj.relative_to_terrain    := NEW.relative_to_terrain;
obj.relative_to_water      := NEW.relative_to_water;
obj.last_modification_date := NEW.last_modification_date;
obj.updating_person        := NEW.updating_person;
obj.reason_for_update      := NEW.reason_for_update;
obj.lineage                := NEW.lineage;

obj_1.id := OLD.id;
obj_1.lod  := NEW.lod;

PERFORM qgis_pkg.upd_masspoint_relief_atts(obj, obj_1, cdb_schema);

RETURN NEW;
EXCEPTION
  WHEN OTHERS THEN RAISE NOTICE 'qgis_pkg.tr_upd_masspoint_relief(id: %): %', OLD.id, SQLERRM;
END;
$$ LANGUAGE plpgsql;
COMMENT ON FUNCTION qgis_pkg.tr_upd_masspoint_relief IS 'Updates record in table MASSPOINT_RELIEF';
REVOKE EXECUTE ON FUNCTION qgis_pkg.tr_upd_masspoint_relief FROM public;

----------------------------------------------------------------
-- Create trigger FUNCTION QGIS_PKG.TR_UPD_OPENING
----------------------------------------------------------------
DROP FUNCTION IF EXISTS    qgis_pkg.tr_upd_opening CASCADE;
CREATE OR REPLACE FUNCTION qgis_pkg.tr_upd_opening()
RETURNS trigger AS $$
DECLARE
  cdb_schema CONSTANT varchar := split_part(TG_TABLE_NAME, '_', 1);
  obj    qgis_pkg.obj_cityobject;
BEGIN
obj.id                     := OLD.id;
obj.gmlid                  := NEW.gmlid;
obj.gmlid_codespace        := NEW.gmlid_codespace;
obj.name                   := NEW.name;
obj.name_codespace         := NEW.name_codespace;
obj.description            := NEW.description;
obj.creation_date          := NEW.creation_date;
obj.termination_date       := NEW.termination_date;
obj.relative_to_terrain    := NEW.relative_to_terrain;
obj.relative_to_water      := NEW.relative_to_water;
obj.last_modification_date := NEW.last_modification_date;
obj.updating_person        := NEW.updating_person;
obj.reason_for_update      := NEW.reason_for_update;
obj.lineage                := NEW.lineage;

PERFORM qgis_pkg.upd_opening_atts(obj, cdb_schema);	

RETURN NEW;
EXCEPTION
  WHEN OTHERS THEN RAISE NOTICE 'qgis_pkg.tr_upd_opening(id: %): %', OLD.id, SQLERRM;
END;
$$ LANGUAGE plpgsql;
COMMENT ON FUNCTION qgis_pkg.tr_upd_opening IS 'Updates record in table OPENING';
REVOKE EXECUTE ON FUNCTION qgis_pkg.tr_upd_opening FROM public;

----------------------------------------------------------------
-- Create trigger FUNCTION QGIS_PKG.TR_UPD_PLANT_COVER
----------------------------------------------------------------
DROP FUNCTION IF EXISTS    qgis_pkg.tr_upd_plant_cover CASCADE;
CREATE OR REPLACE FUNCTION qgis_pkg.tr_upd_plant_cover()
RETURNS trigger AS $$
DECLARE
  cdb_schema CONSTANT varchar := split_part(TG_TABLE_NAME, '_', 1);
  obj    qgis_pkg.obj_cityobject;
  obj_1  qgis_pkg.obj_plant_cover;
BEGIN
obj.id                     := OLD.id;
obj.gmlid                  := NEW.gmlid;
obj.gmlid_codespace        := NEW.gmlid_codespace;
obj.name                   := NEW.name;
obj.name_codespace         := NEW.name_codespace;
obj.description            := NEW.description;
obj.creation_date          := NEW.creation_date;
obj.termination_date       := NEW.termination_date;
obj.relative_to_terrain    := NEW.relative_to_terrain;
obj.relative_to_water      := NEW.relative_to_water;
obj.last_modification_date := NEW.last_modification_date;
obj.updating_person        := NEW.updating_person;
obj.reason_for_update      := NEW.reason_for_update;
obj.lineage                := NEW.lineage;

obj_1.id := OLD.id;
obj_1.class                       := NEW.class;
obj_1.class_codespace             := NEW.class_codespace;
obj_1.function                    := array_to_string((SELECT array_agg(DISTINCT x) FROM unnest(NEW.function) AS t(x)), '--/\--');
obj_1.function_codespace          := array_to_string((SELECT array_agg(DISTINCT x) FROM unnest(NEW.function_codespace) AS t(x)), '--/\--');
obj_1.usage                       := array_to_string((SELECT array_agg(DISTINCT x) FROM unnest(NEW.usage) AS t(x)), '--/\--');
obj_1.usage_codespace             := array_to_string((SELECT array_agg(DISTINCT x) FROM unnest(NEW.usage_codespace) AS t(x)), '--/\--');
obj_1.average_height      = NEW.average_height; 
obj_1.average_height_unit = NEW.average_height_unit;

PERFORM qgis_pkg.upd_plant_cover_atts(obj, obj_1, cdb_schema);

RETURN NEW;
EXCEPTION
  WHEN OTHERS THEN RAISE NOTICE 'qgis_pkg.tr_upd_plant_cover(id: %): %', OLD.id, SQLERRM;
END;
$$ LANGUAGE plpgsql;
COMMENT ON FUNCTION qgis_pkg.tr_upd_plant_cover IS 'Updates record in table PLANT_COVER';
REVOKE EXECUTE ON FUNCTION qgis_pkg.tr_upd_plant_cover FROM public;

----------------------------------------------------------------
-- Create trigger FUNCTION QGIS_PKG.TR_UPD_RASTER_RELIEF
----------------------------------------------------------------
DROP FUNCTION IF EXISTS    qgis_pkg.tr_upd_raster_relief CASCADE;
CREATE OR REPLACE FUNCTION qgis_pkg.tr_upd_raster_relief()
RETURNS trigger AS $$
DECLARE
  cdb_schema CONSTANT varchar := split_part(TG_TABLE_NAME, '_', 1);
  obj    qgis_pkg.obj_cityobject;
  obj_1  qgis_pkg.obj_relief_component;  
  obj_2  qgis_pkg.obj_raster_relief;
BEGIN
obj.id                     := OLD.id;
obj.gmlid                  := NEW.gmlid;
obj.gmlid_codespace        := NEW.gmlid_codespace;
obj.name                   := NEW.name;
obj.name_codespace         := NEW.name_codespace;
obj.description            := NEW.description;
obj.creation_date          := NEW.creation_date;
obj.termination_date       := NEW.termination_date;
obj.relative_to_terrain    := NEW.relative_to_terrain;
obj.relative_to_water      := NEW.relative_to_water;
obj.last_modification_date := NEW.last_modification_date;
obj.updating_person        := NEW.updating_person;
obj.reason_for_update      := NEW.reason_for_update;
obj.lineage                := NEW.lineage;

obj_1.id := OLD.id;
obj_1.lod := NEW_lod;
obj_2.raster_uri  = NEW.raster_uri;

PERFORM qgis_pkg.upd_raster_relief_atts(obj, obj_1, cdb_schema);

RETURN NEW;
EXCEPTION
  WHEN OTHERS THEN RAISE NOTICE 'qgis_pkg.tr_upd_raster_relief(id: %): %', OLD.id, SQLERRM;
END;
$$ LANGUAGE plpgsql;
COMMENT ON FUNCTION qgis_pkg.tr_upd_raster_relief IS 'Updates record in table RASTER_RELIEF';
REVOKE EXECUTE ON FUNCTION qgis_pkg.tr_upd_raster_relief FROM public;

----------------------------------------------------------------
-- Create trigger FUNCTION QGIS_PKG.TR_UPD_RELIEF_FEATURE
----------------------------------------------------------------
DROP FUNCTION IF EXISTS    qgis_pkg.tr_upd_relief_feature CASCADE;
CREATE OR REPLACE FUNCTION qgis_pkg.tr_upd_relief_feature()
RETURNS trigger AS $$
DECLARE
  cdb_schema CONSTANT varchar := split_part(TG_TABLE_NAME, '_', 1);
  obj    qgis_pkg.obj_cityobject;
  obj_1  qgis_pkg.obj_relief_feature;  
BEGIN
obj.id                     := OLD.id;
obj.gmlid                  := NEW.gmlid;
obj.gmlid_codespace        := NEW.gmlid_codespace;
obj.name                   := NEW.name;
obj.name_codespace         := NEW.name_codespace;
obj.description            := NEW.description;
obj.creation_date          := NEW.creation_date;
obj.termination_date       := NEW.termination_date;
obj.relative_to_terrain    := NEW.relative_to_terrain;
obj.relative_to_water      := NEW.relative_to_water;
obj.last_modification_date := NEW.last_modification_date;
obj.updating_person        := NEW.updating_person;
obj.reason_for_update      := NEW.reason_for_update;
obj.lineage                := NEW.lineage;

obj_1.id := OLD.id;
obj_1.lod  := NEW.lod;

PERFORM qgis_pkg.upd_relief_feature_atts(obj, obj_1, cdb_schema);

RETURN NEW;
EXCEPTION
  WHEN OTHERS THEN RAISE NOTICE 'qgis_pkg.tr_upd_relief_feature(id: %): %', OLD.id, SQLERRM;
END;
$$ LANGUAGE plpgsql;
COMMENT ON FUNCTION qgis_pkg.tr_upd_relief_feature IS 'Updates record in table RELIEF_FEATURE';
REVOKE EXECUTE ON FUNCTION qgis_pkg.tr_upd_relief_feature FROM public;

----------------------------------------------------------------
-- Create trigger FUNCTION QGIS_PKG.TR_UPD_ROOM
----------------------------------------------------------------
DROP FUNCTION IF EXISTS    qgis_pkg.tr_upd_room CASCADE;
CREATE OR REPLACE FUNCTION qgis_pkg.tr_upd_room()
RETURNS trigger AS $$
DECLARE
  cdb_schema CONSTANT varchar := split_part(TG_TABLE_NAME, '_', 1);
  obj    qgis_pkg.obj_cityobject;
  obj_1  qgis_pkg.obj_room;
BEGIN
obj.id                     := OLD.id;
obj.gmlid                  := NEW.gmlid;
obj.gmlid_codespace        := NEW.gmlid_codespace;
obj.name                   := NEW.name;
obj.name_codespace         := NEW.name_codespace;
obj.description            := NEW.description;
obj.creation_date          := NEW.creation_date;
obj.termination_date       := NEW.termination_date;
obj.relative_to_terrain    := NEW.relative_to_terrain;
obj.relative_to_water      := NEW.relative_to_water;
obj.last_modification_date := NEW.last_modification_date;
obj.updating_person        := NEW.updating_person;
obj.reason_for_update      := NEW.reason_for_update;
obj.lineage                := NEW.lineage;

obj_1.id                          := OLD.id;
obj_1.class                       := NEW.class;
obj_1.class_codespace             := NEW.class_codespace;
obj_1.function                    := array_to_string((SELECT array_agg(DISTINCT x) FROM unnest(NEW.function) AS t(x)), '--/\--');
obj_1.function_codespace          := array_to_string((SELECT array_agg(DISTINCT x) FROM unnest(NEW.function_codespace) AS t(x)), '--/\--');
obj_1.usage                       := array_to_string((SELECT array_agg(DISTINCT x) FROM unnest(NEW.usage) AS t(x)), '--/\--');
obj_1.usage_codespace             := array_to_string((SELECT array_agg(DISTINCT x) FROM unnest(NEW.usage_codespace) AS t(x)), '--/\--');
PERFORM qgis_pkg.upd_room_atts(obj, obj_1, cdb_schema);

RETURN NEW;
EXCEPTION
  WHEN OTHERS THEN RAISE NOTICE 'qgis_pkg.tr_upd_room(id: %): %', OLD.id, SQLERRM;
END;
$$ LANGUAGE plpgsql;
COMMENT ON FUNCTION qgis_pkg.tr_upd_room IS 'Updates record in table ROOM';
REVOKE EXECUTE ON FUNCTION qgis_pkg.tr_upd_room FROM public;

----------------------------------------------------------------
-- Create trigger FUNCTION QGIS_PKG.TR_UPD_SOLITARY_VEGETAT_OBJECT
----------------------------------------------------------------
DROP FUNCTION IF EXISTS    qgis_pkg.tr_upd_solitary_vegetat_object CASCADE;
CREATE OR REPLACE FUNCTION qgis_pkg.tr_upd_solitary_vegetat_object()
RETURNS trigger AS $$
DECLARE
  cdb_schema CONSTANT varchar := split_part(TG_TABLE_NAME, '_', 1);
  obj    qgis_pkg.obj_cityobject;
  obj_1  qgis_pkg.obj_solitary_vegetat_object;
BEGIN
obj.id                     := OLD.id;
obj.gmlid                  := NEW.gmlid;
obj.gmlid_codespace        := NEW.gmlid_codespace;
obj.name                   := NEW.name;
obj.name_codespace         := NEW.name_codespace;
obj.description            := NEW.description;
obj.creation_date          := NEW.creation_date;
obj.termination_date       := NEW.termination_date;
obj.relative_to_terrain    := NEW.relative_to_terrain;
obj.relative_to_water      := NEW.relative_to_water;
obj.last_modification_date := NEW.last_modification_date;
obj.updating_person        := NEW.updating_person;
obj.reason_for_update      := NEW.reason_for_update;
obj.lineage                := NEW.lineage;

obj_1.id := OLD.id;
obj_1.class                       := NEW.class;
obj_1.class_codespace             := NEW.class_codespace;
obj_1.function                    := array_to_string((SELECT array_agg(DISTINCT x) FROM unnest(NEW.function) AS t(x)), '--/\--');
obj_1.function_codespace          := array_to_string((SELECT array_agg(DISTINCT x) FROM unnest(NEW.function_codespace) AS t(x)), '--/\--');
obj_1.usage                       := array_to_string((SELECT array_agg(DISTINCT x) FROM unnest(NEW.usage) AS t(x)), '--/\--');
obj_1.usage_codespace             := array_to_string((SELECT array_agg(DISTINCT x) FROM unnest(NEW.usage_codespace) AS t(x)), '--/\--');
obj_1.species             = NEW.species; 
obj_1.species_codespace   = NEW.species_codespace; 
obj_1.height              = NEW.height; 
obj_1.height_unit         = NEW.height_unit; 
obj_1.trunk_diameter      = NEW.trunk_diameter; 
obj_1.trunk_diameter_unit = NEW.trunk_diameter_unit; 
obj_1.crown_diameter      = NEW.crown_diameter; 
obj_1.crown_diameter_unit = NEW.crown_diameter_unit;

PERFORM qgis_pkg.upd_solitary_vegetat_object_atts(obj, obj_1, cdb_schema);

RETURN NEW;
EXCEPTION
  WHEN OTHERS THEN RAISE NOTICE 'qgis_pkg.tr_upd_solitary_vegetat_object(id: %): %', OLD.id, SQLERRM;
END;
$$ LANGUAGE plpgsql;
COMMENT ON FUNCTION qgis_pkg.tr_upd_solitary_vegetat_object IS 'Updates record in table SOLITARY_VEGETAT_OBJECT';
REVOKE EXECUTE ON FUNCTION qgis_pkg.tr_upd_solitary_vegetat_object FROM public;

----------------------------------------------------------------
-- Create trigger FUNCTION QGIS_PKG.TR_UPD_SURFACE_DATA
----------------------------------------------------------------
DROP FUNCTION IF EXISTS    qgis_pkg.tr_upd_surface_data CASCADE;
CREATE OR REPLACE FUNCTION qgis_pkg.tr_upd_surface_data()
RETURNS trigger AS $$
DECLARE
  cdb_schema CONSTANT varchar := split_part(TG_TABLE_NAME, '_', 1);
  obj    qgis_pkg.obj_surface_data;
BEGIN
obj.id                    := OLD.id;
obj.gmlid                 := NEW.gmlid;
obj.gmlid_codespace       := NEW.gmlid_codespace;
obj.name                  := NEW.name;
obj.name_codespace        := NEW.name_codespace;
obj.description           := NEW.description;
obj.is_front              := NEW.is_front;
obj.x3d_shininess         := NEW.x3d_shininess;
obj.x3d_transparency      := NEW.x3d_transparency;
obj.x3d_ambient_intensity := NEW.x3d_ambient_intensity;
obj.x3d_specular_color    := NEW.x3d_specular_color;
obj.x3d_diffuse_color     := NEW.x3d_diffuse_color;
obj.x3d_emissive_color    := NEW.x3d_emissive_color;
obj.x3d_is_smooth         := NEW.x3d_is_smooth;
obj.tex_texture_type      := NEW.tex_texture_type;
obj.tex_wrap_mode         := NEW.tex_wrap_mode;
obj.tex_border_color      := NEW.tex_border_color;
obj.gt_prefer_worldfile   := NEW.gt_prefer_worldfile;
obj.gt_orientation        := NEW.gt_orientation;

PERFORM qgis_pkg.upd_surface_data_atts(obj, cdb_schema);

RETURN NEW;
EXCEPTION
  WHEN OTHERS THEN RAISE NOTICE 'qgis_pkg.tr_upd_surface_data(id: %): %', OLD.id, SQLERRM;
END;
$$ LANGUAGE plpgsql;
COMMENT ON FUNCTION qgis_pkg.tr_upd_surface_data IS 'Updates record in table SURFACE_DATA';
REVOKE EXECUTE ON FUNCTION qgis_pkg.tr_upd_surface_data FROM public;

----------------------------------------------------------------
-- Create trigger FUNCTION QGIS_PKG.TR_UPD_THEMATIC_SURFACE
----------------------------------------------------------------
DROP FUNCTION IF EXISTS    qgis_pkg.tr_upd_thematic_surface CASCADE;
CREATE OR REPLACE FUNCTION qgis_pkg.tr_upd_thematic_surface()
RETURNS trigger AS $$
DECLARE
  cdb_schema CONSTANT varchar := split_part(TG_TABLE_NAME, '_', 1);
  obj    qgis_pkg.obj_cityobject;
BEGIN
obj.id                     := OLD.id;
obj.gmlid                  := NEW.gmlid;
obj.gmlid_codespace        := NEW.gmlid_codespace;
obj.name                   := NEW.name;
obj.name_codespace         := NEW.name_codespace;
obj.description            := NEW.description;
obj.creation_date          := NEW.creation_date;
obj.termination_date       := NEW.termination_date;
obj.relative_to_terrain    := NEW.relative_to_terrain;
obj.relative_to_water      := NEW.relative_to_water;
obj.last_modification_date := NEW.last_modification_date;
obj.updating_person        := NEW.updating_person;
obj.reason_for_update      := NEW.reason_for_update;
obj.lineage                := NEW.lineage;

PERFORM qgis_pkg.upd_thematic_surface_atts(obj, cdb_schema);	

RETURN NEW;
EXCEPTION
  WHEN OTHERS THEN RAISE NOTICE 'qgis_pkg.tr_upd_thematic_surface(id: %): %', OLD.id, SQLERRM;
END;
$$ LANGUAGE plpgsql;
COMMENT ON FUNCTION qgis_pkg.tr_upd_thematic_surface IS 'Updates record in table THEMATIC_SURFACE';
REVOKE EXECUTE ON FUNCTION qgis_pkg.tr_upd_thematic_surface FROM public;

----------------------------------------------------------------
-- Create trigger FUNCTION QGIS_PKG.TR_UPD_TIN_RELIEF
----------------------------------------------------------------
DROP FUNCTION IF EXISTS    qgis_pkg.tr_upd_tin_relief CASCADE;
CREATE OR REPLACE FUNCTION qgis_pkg.tr_upd_tin_relief()
RETURNS trigger AS $$
DECLARE
  cdb_schema CONSTANT varchar := split_part(TG_TABLE_NAME, '_', 1);
  obj    qgis_pkg.obj_cityobject;
  obj_1  qgis_pkg.obj_relief_component;
  obj_2  qgis_pkg.obj_tin_relief;  
BEGIN
obj.id                     := OLD.id;
obj.gmlid                  := NEW.gmlid;
obj.gmlid_codespace        := NEW.gmlid_codespace;
obj.name                   := NEW.name;
obj.name_codespace         := NEW.name_codespace;
obj.description            := NEW.description;
obj.creation_date          := NEW.creation_date;
obj.termination_date       := NEW.termination_date;
obj.relative_to_terrain    := NEW.relative_to_terrain;
obj.relative_to_water      := NEW.relative_to_water;
obj.last_modification_date := NEW.last_modification_date;
obj.updating_person        := NEW.updating_person;
obj.reason_for_update      := NEW.reason_for_update;
obj.lineage                := NEW.lineage;

obj_1.id  := OLD.id;
obj_1.lod := NEW.lod;
obj_2.id              := OLD.id;
obj_2.max_length      := NEW.max_length;
obj_2.max_length_unit := NEW.max_length_unit; 

PERFORM qgis_pkg.upd_tin_relief_atts(obj, obj_1, obj_2, cdb_schema);

RETURN NEW;
EXCEPTION
  WHEN OTHERS THEN RAISE NOTICE 'qgis_pkg.tr_upd_tin_relief(id: %): %', OLD.id, SQLERRM;
END;
$$ LANGUAGE plpgsql;
COMMENT ON FUNCTION qgis_pkg.tr_upd_tin_relief IS 'Updates record in table TIN_RELIEF';
REVOKE EXECUTE ON FUNCTION qgis_pkg.tr_upd_tin_relief FROM public;

----------------------------------------------------------------
-- Create trigger FUNCTION QGIS_PKG.TR_UPD_TRAFFIC_AREA
----------------------------------------------------------------
DROP FUNCTION IF EXISTS    qgis_pkg.tr_upd_traffic_area CASCADE;
CREATE OR REPLACE FUNCTION qgis_pkg.tr_upd_traffic_area()
RETURNS trigger AS $$
DECLARE
  cdb_schema CONSTANT varchar := split_part(TG_TABLE_NAME, '_', 1);
  obj    qgis_pkg.obj_cityobject;
  obj_1  qgis_pkg.obj_traffic_area;
BEGIN
obj.id                     := OLD.id;
obj.gmlid                  := NEW.gmlid;
obj.gmlid_codespace        := NEW.gmlid_codespace;
obj.name                   := NEW.name;
obj.name_codespace         := NEW.name_codespace;
obj.description            := NEW.description;
obj.creation_date          := NEW.creation_date;
obj.termination_date       := NEW.termination_date;
obj.relative_to_terrain    := NEW.relative_to_terrain;
obj.relative_to_water      := NEW.relative_to_water;
obj.last_modification_date := NEW.last_modification_date;
obj.updating_person        := NEW.updating_person;
obj.reason_for_update      := NEW.reason_for_update;
obj.lineage                := NEW.lineage;

obj_1.id := OLD.id;
obj_1.class                       := NEW.class;
obj_1.class_codespace             := NEW.class_codespace;
obj_1.function                    := array_to_string((SELECT array_agg(DISTINCT x) FROM unnest(NEW.function) AS t(x)), '--/\--');
obj_1.function_codespace          := array_to_string((SELECT array_agg(DISTINCT x) FROM unnest(NEW.function_codespace) AS t(x)), '--/\--');
obj_1.usage                       := array_to_string((SELECT array_agg(DISTINCT x) FROM unnest(NEW.usage) AS t(x)), '--/\--');
obj_1.usage_codespace             := array_to_string((SELECT array_agg(DISTINCT x) FROM unnest(NEW.usage_codespace) AS t(x)), '--/\--');
obj_1.surface_material            := NEW.surface_material;
obj_1.surface_material_codespace  := NEW.surface_material_codespace;

PERFORM qgis_pkg.upd_traffic_area_atts(obj, obj_1, cdb_schema);

RETURN NEW;
EXCEPTION
  WHEN OTHERS THEN RAISE NOTICE 'qgis_pkg.tr_upd_traffic_area(id: %): %', OLD.id, SQLERRM;
END;
$$ LANGUAGE plpgsql;
COMMENT ON FUNCTION qgis_pkg.tr_upd_traffic_area IS 'Updates record in table TRAFFIC_AREA';
REVOKE EXECUTE ON FUNCTION qgis_pkg.tr_upd_traffic_area FROM public;

----------------------------------------------------------------
-- Create trigger FUNCTION QGIS_PKG.TR_UPD_TRANSPORTATION_COMPLEX
----------------------------------------------------------------
DROP FUNCTION IF EXISTS    qgis_pkg.tr_upd_transportation_complex CASCADE;
CREATE OR REPLACE FUNCTION qgis_pkg.tr_upd_transportation_complex()
RETURNS trigger AS $$
DECLARE
  cdb_schema CONSTANT varchar := split_part(TG_TABLE_NAME, '_', 1);
  obj    qgis_pkg.obj_cityobject;
  obj_1  qgis_pkg.obj_transportation_complex;
BEGIN
obj.id                     := OLD.id;
obj.gmlid                  := NEW.gmlid;
obj.gmlid_codespace        := NEW.gmlid_codespace;
obj.name                   := NEW.name;
obj.name_codespace         := NEW.name_codespace;
obj.description            := NEW.description;
obj.creation_date          := NEW.creation_date;
obj.termination_date       := NEW.termination_date;
obj.relative_to_terrain    := NEW.relative_to_terrain;
obj.relative_to_water      := NEW.relative_to_water;
obj.last_modification_date := NEW.last_modification_date;
obj.updating_person        := NEW.updating_person;
obj.reason_for_update      := NEW.reason_for_update;
obj.lineage                := NEW.lineage;

obj_1.id                          := OLD.id;
obj_1.class                       := NEW.class;
obj_1.class_codespace             := NEW.class_codespace;
obj_1.function                    := array_to_string((SELECT array_agg(DISTINCT x) FROM unnest(NEW.function) AS t(x)), '--/\--');
obj_1.function_codespace          := array_to_string((SELECT array_agg(DISTINCT x) FROM unnest(NEW.function_codespace) AS t(x)), '--/\--');
obj_1.usage                       := array_to_string((SELECT array_agg(DISTINCT x) FROM unnest(NEW.usage) AS t(x)), '--/\--');
obj_1.usage_codespace             := array_to_string((SELECT array_agg(DISTINCT x) FROM unnest(NEW.usage_codespace) AS t(x)), '--/\--');
PERFORM qgis_pkg.upd_transportation_complex_atts(obj, obj_1, cdb_schema);

RETURN NEW;
EXCEPTION
  WHEN OTHERS THEN RAISE NOTICE 'qgis_pkg.tr_upd_transportation_complex(id: %): %', OLD.id, SQLERRM;
END;
$$ LANGUAGE plpgsql;
COMMENT ON FUNCTION qgis_pkg.tr_upd_transportation_complex IS 'Updates record in table TRANSPORTATION_COMPLEX';
REVOKE EXECUTE ON FUNCTION qgis_pkg.tr_upd_transportation_complex FROM public;

----------------------------------------------------------------
-- Create trigger FUNCTION QGIS_PKG.TR_UPD_TUNNEL
----------------------------------------------------------------
DROP FUNCTION IF EXISTS    qgis_pkg.tr_upd_tunnel CASCADE;
CREATE OR REPLACE FUNCTION qgis_pkg.tr_upd_tunnel()
RETURNS trigger AS $$
DECLARE
  cdb_schema CONSTANT varchar := split_part(TG_TABLE_NAME, '_', 1);
  obj    qgis_pkg.obj_cityobject;
  obj_1  qgis_pkg.obj_tunnel;
BEGIN
obj.id                     := OLD.id;
obj.gmlid                  := NEW.gmlid;
obj.gmlid_codespace        := NEW.gmlid_codespace;
obj.name                   := NEW.name;
obj.name_codespace         := NEW.name_codespace;
obj.description            := NEW.description;
obj.creation_date          := NEW.creation_date;
obj.termination_date       := NEW.termination_date;
obj.relative_to_terrain    := NEW.relative_to_terrain;
obj.relative_to_water      := NEW.relative_to_water;
obj.last_modification_date := NEW.last_modification_date;
obj.updating_person        := NEW.updating_person;
obj.reason_for_update      := NEW.reason_for_update;
obj.lineage                := NEW.lineage;

obj_1.id := OLD.id;
obj_1.class                       := NEW.class;
obj_1.class_codespace             := NEW.class_codespace;
obj_1.function                    := array_to_string((SELECT array_agg(DISTINCT x) FROM unnest(NEW.function) AS t(x)), '--/\--');
obj_1.function_codespace          := array_to_string((SELECT array_agg(DISTINCT x) FROM unnest(NEW.function_codespace) AS t(x)), '--/\--');
obj_1.usage                       := array_to_string((SELECT array_agg(DISTINCT x) FROM unnest(NEW.usage) AS t(x)), '--/\--');
obj_1.usage_codespace             := array_to_string((SELECT array_agg(DISTINCT x) FROM unnest(NEW.usage_codespace) AS t(x)), '--/\--');
obj_1.year_of_construction        = NEW.year_of_construction;
obj_1.year_of_demolition          = NEW.year_of_demolition;

PERFORM qgis_pkg.upd_tunnel_atts(obj, obj_1, cdb_schema);

RETURN NEW;
EXCEPTION
  WHEN OTHERS THEN RAISE NOTICE 'qgis_pkg.tr_upd_tunnel(id: %): %', OLD.id, SQLERRM;
END;
$$ LANGUAGE plpgsql;
COMMENT ON FUNCTION qgis_pkg.tr_upd_tunnel IS 'Updates record in table TUNNEL';
REVOKE EXECUTE ON FUNCTION qgis_pkg.tr_upd_tunnel FROM public;

----------------------------------------------------------------
-- Create trigger FUNCTION QGIS_PKG.TR_UPD_TUNNEL_FURNITURE
----------------------------------------------------------------
DROP FUNCTION IF EXISTS    qgis_pkg.tr_upd_tunnel_furniture CASCADE;
CREATE OR REPLACE FUNCTION qgis_pkg.tr_upd_tunnel_furniture()
RETURNS trigger AS $$
DECLARE
  cdb_schema CONSTANT varchar := split_part(TG_TABLE_NAME, '_', 1);
  obj    qgis_pkg.obj_cityobject;
  obj_1  qgis_pkg.obj_tunnel_furniture;
BEGIN
obj.id                     := OLD.id;
obj.gmlid                  := NEW.gmlid;
obj.gmlid_codespace        := NEW.gmlid_codespace;
obj.name                   := NEW.name;
obj.name_codespace         := NEW.name_codespace;
obj.description            := NEW.description;
obj.creation_date          := NEW.creation_date;
obj.termination_date       := NEW.termination_date;
obj.relative_to_terrain    := NEW.relative_to_terrain;
obj.relative_to_water      := NEW.relative_to_water;
obj.last_modification_date := NEW.last_modification_date;
obj.updating_person        := NEW.updating_person;
obj.reason_for_update      := NEW.reason_for_update;
obj.lineage                := NEW.lineage;

obj_1.id                          := OLD.id;
obj_1.class                       := NEW.class;
obj_1.class_codespace             := NEW.class_codespace;
obj_1.function                    := array_to_string((SELECT array_agg(DISTINCT x) FROM unnest(NEW.function) AS t(x)), '--/\--');
obj_1.function_codespace          := array_to_string((SELECT array_agg(DISTINCT x) FROM unnest(NEW.function_codespace) AS t(x)), '--/\--');
obj_1.usage                       := array_to_string((SELECT array_agg(DISTINCT x) FROM unnest(NEW.usage) AS t(x)), '--/\--');
obj_1.usage_codespace             := array_to_string((SELECT array_agg(DISTINCT x) FROM unnest(NEW.usage_codespace) AS t(x)), '--/\--');
PERFORM qgis_pkg.upd_tunnel_furniture_atts(obj, obj_1, cdb_schema);

RETURN NEW;
EXCEPTION
  WHEN OTHERS THEN RAISE NOTICE 'qgis_pkg.tr_upd_tunnel_furniture(id: %): %', OLD.id, SQLERRM;
END;
$$ LANGUAGE plpgsql;
COMMENT ON FUNCTION qgis_pkg.tr_upd_tunnel_furniture IS 'Updates record in table TUNNEL_FURNITURE';
REVOKE EXECUTE ON FUNCTION qgis_pkg.tr_upd_tunnel_furniture FROM public;

----------------------------------------------------------------
-- Create trigger FUNCTION QGIS_PKG.TR_UPD_TUNNEL_HOLLOW_SPACE
----------------------------------------------------------------
DROP FUNCTION IF EXISTS    qgis_pkg.tr_upd_tunnel_hollow_space CASCADE;
CREATE OR REPLACE FUNCTION qgis_pkg.tr_upd_tunnel_hollow_space()
RETURNS trigger AS $$
DECLARE
  cdb_schema CONSTANT varchar := split_part(TG_TABLE_NAME, '_', 1);
  obj    qgis_pkg.obj_cityobject;
  obj_1  qgis_pkg.obj_tunnel_hollow_space;
BEGIN
obj.id                     := OLD.id;
obj.gmlid                  := NEW.gmlid;
obj.gmlid_codespace        := NEW.gmlid_codespace;
obj.name                   := NEW.name;
obj.name_codespace         := NEW.name_codespace;
obj.description            := NEW.description;
obj.creation_date          := NEW.creation_date;
obj.termination_date       := NEW.termination_date;
obj.relative_to_terrain    := NEW.relative_to_terrain;
obj.relative_to_water      := NEW.relative_to_water;
obj.last_modification_date := NEW.last_modification_date;
obj.updating_person        := NEW.updating_person;
obj.reason_for_update      := NEW.reason_for_update;
obj.lineage                := NEW.lineage;

obj_1.id                          := OLD.id;
obj_1.class                       := NEW.class;
obj_1.class_codespace             := NEW.class_codespace;
obj_1.function                    := array_to_string((SELECT array_agg(DISTINCT x) FROM unnest(NEW.function) AS t(x)), '--/\--');
obj_1.function_codespace          := array_to_string((SELECT array_agg(DISTINCT x) FROM unnest(NEW.function_codespace) AS t(x)), '--/\--');
obj_1.usage                       := array_to_string((SELECT array_agg(DISTINCT x) FROM unnest(NEW.usage) AS t(x)), '--/\--');
obj_1.usage_codespace             := array_to_string((SELECT array_agg(DISTINCT x) FROM unnest(NEW.usage_codespace) AS t(x)), '--/\--');
PERFORM qgis_pkg.upd_tunnel_hollow_space_atts(obj, obj_1, cdb_schema);

RETURN NEW;
EXCEPTION
  WHEN OTHERS THEN RAISE NOTICE 'qgis_pkg.tr_upd_tunnel_hollow_space(id: %): %', OLD.id, SQLERRM;
END;
$$ LANGUAGE plpgsql;
COMMENT ON FUNCTION qgis_pkg.tr_upd_tunnel_hollow_space IS 'Updates record in table TUNNEL_HOLLOW_SPACE';
REVOKE EXECUTE ON FUNCTION qgis_pkg.tr_upd_tunnel_hollow_space FROM public;

----------------------------------------------------------------
-- Create trigger FUNCTION QGIS_PKG.TR_UPD_TUNNEL_INSTALLATION
----------------------------------------------------------------
DROP FUNCTION IF EXISTS    qgis_pkg.tr_upd_tunnel_installation CASCADE;
CREATE OR REPLACE FUNCTION qgis_pkg.tr_upd_tunnel_installation()
RETURNS trigger AS $$
DECLARE
  cdb_schema CONSTANT varchar := split_part(TG_TABLE_NAME, '_', 1);
  obj    qgis_pkg.obj_cityobject;
  obj_1  qgis_pkg.obj_tunnel_installation;
BEGIN
obj.id                     := OLD.id;
obj.gmlid                  := NEW.gmlid;
obj.gmlid_codespace        := NEW.gmlid_codespace;
obj.name                   := NEW.name;
obj.name_codespace         := NEW.name_codespace;
obj.description            := NEW.description;
obj.creation_date          := NEW.creation_date;
obj.termination_date       := NEW.termination_date;
obj.relative_to_terrain    := NEW.relative_to_terrain;
obj.relative_to_water      := NEW.relative_to_water;
obj.last_modification_date := NEW.last_modification_date;
obj.updating_person        := NEW.updating_person;
obj.reason_for_update      := NEW.reason_for_update;
obj.lineage                := NEW.lineage;

obj_1.id                          := OLD.id;
obj_1.class                       := NEW.class;
obj_1.class_codespace             := NEW.class_codespace;
obj_1.function                    := array_to_string((SELECT array_agg(DISTINCT x) FROM unnest(NEW.function) AS t(x)), '--/\--');
obj_1.function_codespace          := array_to_string((SELECT array_agg(DISTINCT x) FROM unnest(NEW.function_codespace) AS t(x)), '--/\--');
obj_1.usage                       := array_to_string((SELECT array_agg(DISTINCT x) FROM unnest(NEW.usage) AS t(x)), '--/\--');
obj_1.usage_codespace             := array_to_string((SELECT array_agg(DISTINCT x) FROM unnest(NEW.usage_codespace) AS t(x)), '--/\--');
PERFORM qgis_pkg.upd_tunnel_installation_atts(obj, obj_1, cdb_schema);

RETURN NEW;
EXCEPTION
  WHEN OTHERS THEN RAISE NOTICE 'qgis_pkg.tr_upd_tunnel_installation(id: %): %', OLD.id, SQLERRM;
END;
$$ LANGUAGE plpgsql;
COMMENT ON FUNCTION qgis_pkg.tr_upd_tunnel_installation IS 'Updates record in table TUNNEL_INSTALLATION';
REVOKE EXECUTE ON FUNCTION qgis_pkg.tr_upd_tunnel_installation FROM public;

----------------------------------------------------------------
-- Create trigger FUNCTION QGIS_PKG.TR_UPD_TUNNEL_OPENING
----------------------------------------------------------------
DROP FUNCTION IF EXISTS    qgis_pkg.tr_upd_tunnel_opening CASCADE;
CREATE OR REPLACE FUNCTION qgis_pkg.tr_upd_tunnel_opening()
RETURNS trigger AS $$
DECLARE
  cdb_schema CONSTANT varchar := split_part(TG_TABLE_NAME, '_', 1);
  obj    qgis_pkg.obj_cityobject;
BEGIN
obj.id                     := OLD.id;
obj.gmlid                  := NEW.gmlid;
obj.gmlid_codespace        := NEW.gmlid_codespace;
obj.name                   := NEW.name;
obj.name_codespace         := NEW.name_codespace;
obj.description            := NEW.description;
obj.creation_date          := NEW.creation_date;
obj.termination_date       := NEW.termination_date;
obj.relative_to_terrain    := NEW.relative_to_terrain;
obj.relative_to_water      := NEW.relative_to_water;
obj.last_modification_date := NEW.last_modification_date;
obj.updating_person        := NEW.updating_person;
obj.reason_for_update      := NEW.reason_for_update;
obj.lineage                := NEW.lineage;

PERFORM qgis_pkg.upd_tunnel_opening_atts(obj, cdb_schema);	

RETURN NEW;
EXCEPTION
  WHEN OTHERS THEN RAISE NOTICE 'qgis_pkg.tr_upd_tunnel_opening(id: %): %', OLD.id, SQLERRM;
END;
$$ LANGUAGE plpgsql;
COMMENT ON FUNCTION qgis_pkg.tr_upd_tunnel_opening IS 'Updates record in table TUNNEL_OPENING';
REVOKE EXECUTE ON FUNCTION qgis_pkg.tr_upd_tunnel_opening FROM public;

----------------------------------------------------------------
-- Create trigger FUNCTION QGIS_PKG.TR_UPD_TUNNEL_THEMATIC_SURFACE
----------------------------------------------------------------
DROP FUNCTION IF EXISTS    qgis_pkg.tr_upd_tunnel_thematic_surface CASCADE;
CREATE OR REPLACE FUNCTION qgis_pkg.tr_upd_tunnel_thematic_surface()
RETURNS trigger AS $$
DECLARE
  cdb_schema CONSTANT varchar := split_part(TG_TABLE_NAME, '_', 1);
  obj    qgis_pkg.obj_cityobject;
BEGIN
obj.id                     := OLD.id;
obj.gmlid                  := NEW.gmlid;
obj.gmlid_codespace        := NEW.gmlid_codespace;
obj.name                   := NEW.name;
obj.name_codespace         := NEW.name_codespace;
obj.description            := NEW.description;
obj.creation_date          := NEW.creation_date;
obj.termination_date       := NEW.termination_date;
obj.relative_to_terrain    := NEW.relative_to_terrain;
obj.relative_to_water      := NEW.relative_to_water;
obj.last_modification_date := NEW.last_modification_date;
obj.updating_person        := NEW.updating_person;
obj.reason_for_update      := NEW.reason_for_update;
obj.lineage                := NEW.lineage;

PERFORM qgis_pkg.upd_tunnel_thematic_surface_atts(obj, cdb_schema);	

RETURN NEW;
EXCEPTION
  WHEN OTHERS THEN RAISE NOTICE 'qgis_pkg.tr_upd_tunnel_thematic_surface(id: %): %', OLD.id, SQLERRM;
END;
$$ LANGUAGE plpgsql;
COMMENT ON FUNCTION qgis_pkg.tr_upd_tunnel_thematic_surface IS 'Updates record in table TUNNEL_THEMATIC_SURFACE';
REVOKE EXECUTE ON FUNCTION qgis_pkg.tr_upd_tunnel_thematic_surface FROM public;

----------------------------------------------------------------
-- Create trigger FUNCTION QGIS_PKG.TR_UPD_WATERBODY
----------------------------------------------------------------
DROP FUNCTION IF EXISTS    qgis_pkg.tr_upd_waterbody CASCADE;
CREATE OR REPLACE FUNCTION qgis_pkg.tr_upd_waterbody()
RETURNS trigger AS $$
DECLARE
  cdb_schema CONSTANT varchar := split_part(TG_TABLE_NAME, '_', 1);
  obj    qgis_pkg.obj_cityobject;
  obj_1  qgis_pkg.obj_waterbody;
BEGIN
obj.id                     := OLD.id;
obj.gmlid                  := NEW.gmlid;
obj.gmlid_codespace        := NEW.gmlid_codespace;
obj.name                   := NEW.name;
obj.name_codespace         := NEW.name_codespace;
obj.description            := NEW.description;
obj.creation_date          := NEW.creation_date;
obj.termination_date       := NEW.termination_date;
obj.relative_to_terrain    := NEW.relative_to_terrain;
obj.relative_to_water      := NEW.relative_to_water;
obj.last_modification_date := NEW.last_modification_date;
obj.updating_person        := NEW.updating_person;
obj.reason_for_update      := NEW.reason_for_update;
obj.lineage                := NEW.lineage;

obj_1.id                          := OLD.id;
obj_1.class                       := NEW.class;
obj_1.class_codespace             := NEW.class_codespace;
obj_1.function                    := array_to_string((SELECT array_agg(DISTINCT x) FROM unnest(NEW.function) AS t(x)), '--/\--');
obj_1.function_codespace          := array_to_string((SELECT array_agg(DISTINCT x) FROM unnest(NEW.function_codespace) AS t(x)), '--/\--');
obj_1.usage                       := array_to_string((SELECT array_agg(DISTINCT x) FROM unnest(NEW.usage) AS t(x)), '--/\--');
obj_1.usage_codespace             := array_to_string((SELECT array_agg(DISTINCT x) FROM unnest(NEW.usage_codespace) AS t(x)), '--/\--');
PERFORM qgis_pkg.upd_waterbody_atts(obj, obj_1, cdb_schema);

RETURN NEW;
EXCEPTION
  WHEN OTHERS THEN RAISE NOTICE 'qgis_pkg.tr_upd_waterbody(id: %): %', OLD.id, SQLERRM;
END;
$$ LANGUAGE plpgsql;
COMMENT ON FUNCTION qgis_pkg.tr_upd_waterbody IS 'Updates record in table WATERBODY';
REVOKE EXECUTE ON FUNCTION qgis_pkg.tr_upd_waterbody FROM public;

----------------------------------------------------------------
-- Create trigger FUNCTION QGIS_PKG.TR_UPD_WATERBOUNDARY_SURFACE
----------------------------------------------------------------
DROP FUNCTION IF EXISTS    qgis_pkg.tr_upd_waterboundary_surface CASCADE;
CREATE OR REPLACE FUNCTION qgis_pkg.tr_upd_waterboundary_surface()
RETURNS trigger AS $$
DECLARE
  cdb_schema CONSTANT varchar := split_part(TG_TABLE_NAME, '_', 1);
  obj    qgis_pkg.obj_cityobject;
BEGIN
obj.id                     := OLD.id;
obj.gmlid                  := NEW.gmlid;
obj.gmlid_codespace        := NEW.gmlid_codespace;
obj.name                   := NEW.name;
obj.name_codespace         := NEW.name_codespace;
obj.description            := NEW.description;
obj.creation_date          := NEW.creation_date;
obj.termination_date       := NEW.termination_date;
obj.relative_to_terrain    := NEW.relative_to_terrain;
obj.relative_to_water      := NEW.relative_to_water;
obj.last_modification_date := NEW.last_modification_date;
obj.updating_person        := NEW.updating_person;
obj.reason_for_update      := NEW.reason_for_update;
obj.lineage                := NEW.lineage;

PERFORM qgis_pkg.upd_waterboundary_surface_atts(obj, cdb_schema);	

RETURN NEW;
EXCEPTION
  WHEN OTHERS THEN RAISE NOTICE 'qgis_pkg.tr_upd_waterboundary_surface(id: %): %', OLD.id, SQLERRM;
END;
$$ LANGUAGE plpgsql;
COMMENT ON FUNCTION qgis_pkg.tr_upd_waterboundary_surface IS 'Updates record in table WATERBOUNDARY_SURFACE';
REVOKE EXECUTE ON FUNCTION qgis_pkg.tr_upd_waterboundary_surface FROM public;

----------------------------------------------------------------
-- Create trigger FUNCTION QGIS_PKG.TR_UPD_WATERBOUNDARY_SURFACE_WATERSURFACE
----------------------------------------------------------------
DROP FUNCTION IF EXISTS    qgis_pkg.tr_upd_waterboundary_surface_watersurface CASCADE;
CREATE OR REPLACE FUNCTION qgis_pkg.tr_upd_waterboundary_surface_watersurface()
RETURNS trigger AS $$
DECLARE
  cdb_schema CONSTANT varchar := split_part(TG_TABLE_NAME, '_', 1);
  obj    qgis_pkg.obj_cityobject;
  obj_1  qgis_pkg.obj_waterboundary_surface;
BEGIN
obj.id                     := OLD.id;
obj.gmlid                  := NEW.gmlid;
obj.gmlid_codespace        := NEW.gmlid_codespace;
obj.name                   := NEW.name;
obj.name_codespace         := NEW.name_codespace;
obj.description            := NEW.description;
obj.creation_date          := NEW.creation_date;
obj.termination_date       := NEW.termination_date;
obj.relative_to_terrain    := NEW.relative_to_terrain;
obj.relative_to_water      := NEW.relative_to_water;
obj.last_modification_date := NEW.last_modification_date;
obj.updating_person        := NEW.updating_person;
obj.reason_for_update      := NEW.reason_for_update;
obj.lineage                := NEW.lineage;

obj_1.id := OLD.id;
obj_1.water_level           := NEW.water_level;
obj_1.water_level_codespace := NEW.water_level_codespace;

PERFORM qgis_pkg.upd_waterboundary_surface_watersurface_atts(obj, obj_1, cdb_schema);

RETURN NEW;
EXCEPTION
  WHEN OTHERS THEN RAISE NOTICE 'qgis_pkg.tr_upd_waterboundary_surface_watersurface(id: %): %', OLD.id, SQLERRM;
END;
$$ LANGUAGE plpgsql;
COMMENT ON FUNCTION qgis_pkg.tr_upd_waterboundary_surface_watersurface IS 'Updates record in table WATERBOUNDARY_SURFACE_WATERSURFACE';
REVOKE EXECUTE ON FUNCTION qgis_pkg.tr_upd_waterboundary_surface_watersurface FROM public;

--**************************
DO $MAINBODY$
BEGIN
RAISE NOTICE E'\n\nDone\n\n';
END $MAINBODY$;
--**************************

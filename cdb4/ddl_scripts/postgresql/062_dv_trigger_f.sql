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
-- This script installs in schema qgis_pkg trigger functions for the detail
-- views.
--
-- ***********************************************************************


----------------------------------------------------------------
-- Create trigger FUNCTION QGIS_PKG.TR_DEL_DV_ADDRESS
----------------------------------------------------------------
-- This trigger function is meant for the detail view, not for the layer!
DROP FUNCTION IF EXISTS    qgis_pkg.tr_del_dv_address CASCADE;
CREATE OR REPLACE FUNCTION qgis_pkg.tr_del_dv_address()
RETURNS trigger AS $$
DECLARE
  dv_prefix  CONSTANT varchar := 'dv_';
  cdb_schema CONSTANT varchar := split_part(split_part(TG_TABLE_NAME, '_address_', 1), dv_prefix, 2); 
BEGIN
EXECUTE format('SELECT %I.del_address(ARRAY[$1]);', cdb_schema) USING OLD.id;
RETURN OLD;
EXCEPTION
  WHEN OTHERS THEN RAISE NOTICE 'qgis_pkg.tr_del_dv_address(id: %): %', OLD.id, SQLERRM;
END;
$$ LANGUAGE plpgsql;
COMMENT ON FUNCTION qgis_pkg.tr_del_dv_address IS 'Trigger to delete a record of table ADDRESS from a detail view';
REVOKE EXECUTE ON FUNCTION qgis_pkg.tr_del_dv_address FROM public;

----------------------------------------------------------------
-- Create trigger FUNCTION QGIS_PKG.TR_UPD_DV_ADDRESS
----------------------------------------------------------------
-- This trigger function is meant for the detail view, not for the layer!
DROP FUNCTION IF EXISTS    qgis_pkg.tr_upd_dv_address CASCADE;
CREATE OR REPLACE FUNCTION qgis_pkg.tr_upd_dv_address()
RETURNS trigger AS $$
DECLARE
  dv_prefix  CONSTANT varchar := 'dv_';
  cdb_schema CONSTANT varchar := split_part(split_part(TG_TABLE_NAME, '_address_', 1), dv_prefix, 2); 
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
--obj.multi_point     := NEW.geom;
--obj.xal_source      := NEW.xal_source;

PERFORM qgis_pkg.upd_t_address(obj, cdb_schema);

RETURN NEW;
EXCEPTION
  WHEN OTHERS THEN RAISE NOTICE 'qgis_pkg.tr_upd_dv_address(id: %): %', OLD.id, SQLERRM;
END;
$$ LANGUAGE plpgsql;
COMMENT ON FUNCTION qgis_pkg.tr_upd_dv_address IS 'Trigger to update a record of table ADDRESS from a detail view';
REVOKE EXECUTE ON FUNCTION qgis_pkg.tr_upd_dv_address FROM public;


----------------------------------------------------------------
-- Create trigger FUNCTION QGIS_PKG.TR_INS_DV_ADDRESS
----------------------------------------------------------------
-- This trigger function is meant for the detail view, not for the layer!
DROP FUNCTION IF EXISTS    qgis_pkg.tr_ins_dv_address CASCADE;
CREATE OR REPLACE FUNCTION qgis_pkg.tr_ins_dv_address()
RETURNS trigger AS $$
DECLARE
  dv_prefix  CONSTANT varchar := 'dv_';
  cdb_schema CONSTANT varchar := split_part(split_part(TG_TABLE_NAME, '_address_', 1), dv_prefix, 2);
  obj qgis_pkg.obj_address;
  inserted_id bigint;
BEGIN
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
--obj.multi_point     := NEW.geom;
--obj.xal_source      := NEW.xal_source;

SELECT qgis_pkg.ins_t_address(obj, cdb_schema) INTO inserted_id;

RETURN NEW;
EXCEPTION
  WHEN OTHERS THEN RAISE NOTICE 'qgis_pkg.tr_ins_dv_address(id: %): %', inserted_id, SQLERRM;
END;
$$ LANGUAGE plpgsql;
COMMENT ON FUNCTION qgis_pkg.tr_ins_dv_address IS 'Trigger to insert a new record of table ADDRESS from a detail view';
REVOKE EXECUTE ON FUNCTION qgis_pkg.tr_ins_dv_address FROM public;


----------------------------------------------------------------
-- Create trigger FUNCTION QGIS_PKG.TR_DEL_DV_CITYOBJECT_GENERICATTRIB
----------------------------------------------------------------
-- This trigger function is for the detail view (prefix = 'dv_')!
DROP FUNCTION IF EXISTS    qgis_pkg.tr_del_dv_cityobject_genericattrib CASCADE;
CREATE OR REPLACE FUNCTION qgis_pkg.tr_del_dv_cityobject_genericattrib()
RETURNS trigger AS $$
DECLARE
  dv_prefix  CONSTANT varchar := 'dv_';
  cdb_schema CONSTANT varchar := split_part(split_part(TG_TABLE_NAME, '_gen_attrib_', 1), dv_prefix, 2);

BEGIN
EXECUTE format('SELECT %I.del_cityobject_genericattrib(ARRAY[$1]);', cdb_schema) USING OLD.id;

RETURN OLD;
EXCEPTION
  WHEN OTHERS THEN RAISE NOTICE 'qgis_pkg.tr_del_dv_cityobject_genericattrib(id: %): %', OLD.id, SQLERRM;
END;
$$ LANGUAGE plpgsql;
COMMENT ON FUNCTION qgis_pkg.tr_del_dv_cityobject_genericattrib IS 'Trigger to delete a record of table CITYOBJECT_GENERICATTRIB from a detail view';
REVOKE EXECUTE ON FUNCTION qgis_pkg.tr_del_dv_cityobject_genericattrib FROM public;

----------------------------------------------------------------
-- Create trigger FUNCTION QGIS_PKG.TR_UPD_DV_CITYOBJECT_GENERICATTRIB
----------------------------------------------------------------
-- This trigger function is for the detail view (prefix = 'dv_')!
DROP FUNCTION IF EXISTS    qgis_pkg.tr_upd_dv_cityobject_genericattrib CASCADE;
CREATE OR REPLACE FUNCTION qgis_pkg.tr_upd_dv_cityobject_genericattrib()
RETURNS trigger AS $$
DECLARE
  dv_prefix  CONSTANT varchar := 'dv_';
  cdb_schema CONSTANT varchar := split_part(split_part(TG_TABLE_NAME, '_gen_attrib_', 1), dv_prefix, 2);
  data_type  CONSTANT varchar := split_part(TG_TABLE_NAME, '_gen_attrib_', 2);
  obj    qgis_pkg.obj_cityobject_genericattrib;
BEGIN
obj.id                     := OLD.id;
--obj.root_genattrib_id      := OLD.root_genattrib_id;
obj.attrname               := NEW.attrname;
CASE data_type
	WHEN 'string' THEN
		obj.datatype := 1;
		obj.strval   := NEW.value;
	WHEN 'integer' THEN
		obj.datatype := 2;
		obj.intval   := NEW.value;
	WHEN 'real' THEN
		obj.datatype := 3;
		obj.realval  := NEW.value;
	WHEN 'uri' THEN
		obj.datatype := 4;
		obj.urival   := NEW.value;
	WHEN 'date' THEN
		obj.datatype := 5;
		obj.dateval  := NEW.value;
	WHEN 'measure' THEN
		obj.datatype := 6;
		obj.realval  := NEW.value;
		obj.unit     := NEW.uom;
--	WHEN 'set' THEN
--		obj.datatype := 7;
--		obj.genattribset_codespace := NEW.value;
	WHEN 'blob' THEN
		obj.datatype := 8;
		obj.blobval  := NEW.value;
--	WHEN 'geom' THEN
--		obj.datatype := 9;
--		obj.geomval  := NEW.value;
--	WHEN 'surf_geom' THEN
--		obj.datatype := 10;
--		obj.surface_geometry_id := NEW.value;
	ELSE
		RAISE EXCEPTION 'datatype not supported';
END CASE;
--obj.cityobject_id := NEW.cityobject_id;

PERFORM qgis_pkg.upd_t_cityobject_genericattrib(obj, cdb_schema);

RETURN NEW;
EXCEPTION
  WHEN OTHERS THEN RAISE NOTICE 'qgis_pkg.tr_upd_dv_cityobject_genericattrib(id: %): %', OLD.id, SQLERRM;
END;
$$ LANGUAGE plpgsql;
COMMENT ON FUNCTION qgis_pkg.tr_upd_dv_cityobject_genericattrib IS 'Trigger to update a record of table CITYOBJECT_GENERICATTRIB from a detail view';
REVOKE EXECUTE ON FUNCTION qgis_pkg.tr_upd_dv_cityobject_genericattrib FROM public;

----------------------------------------------------------------
-- Create trigger FUNCTION QGIS_PKG.TR_INS_DV_CITYOBJECT_GENERICATTRIB
----------------------------------------------------------------
-- This trigger function is for the detail view (prefix = 'dv_')!
DROP FUNCTION IF EXISTS    qgis_pkg.tr_ins_dv_cityobject_genericattrib CASCADE;
CREATE OR REPLACE FUNCTION qgis_pkg.tr_ins_dv_cityobject_genericattrib()
RETURNS trigger AS $$
DECLARE
  dv_prefix  CONSTANT varchar := 'dv_';
  cdb_schema CONSTANT varchar := split_part(split_part(TG_TABLE_NAME, '_gen_attrib_', 1), dv_prefix, 2);
  data_type  CONSTANT varchar := split_part(TG_TABLE_NAME, '_gen_attrib_', 2);
  obj qgis_pkg.obj_cityobject_genericattrib;
  inserted_id bigint;
BEGIN
obj.id                     := NEW.id;
--obj.root_genattrib_id      := NEW.root_genattrib_id; -- This will be set by the int_t_functon
obj.attrname               := NEW.attrname;
CASE data_type
	WHEN 'string' THEN
		obj.datatype := 1;
		obj.strval   := NEW.value;
	WHEN 'integer' THEN
		obj.datatype := 2;
		obj.intval   := NEW.value;
	WHEN 'real' THEN
		obj.datatype := 3;
		obj.realval  := NEW.value;
	WHEN 'uri' THEN
		obj.datatype := 4;
		obj.urival   := NEW.value;
	WHEN 'date' THEN
		obj.datatype := 5;
		obj.dateval  := NEW.value;
	WHEN 'measure' THEN
		obj.datatype := 6;
		obj.realval  := NEW.value;
		obj.unit     := NEW.uom;
--	WHEN 'set' THEN
--		obj.datatype := 7;
--		obj.genattribset_codespace := NEW.value;
	WHEN 'blob' THEN
		obj.datatype := 8;
		obj.blobval  := NEW.value;
--	WHEN 'geom' THEN
--		obj.datatype := 9;
--		obj.geomval  := NEW.value;
--	WHEN 'surf_geom' THEN
--		obj.datatype := 10;
--		obj.surface_geometry_id := NEW.value;
	ELSE
		RAISE EXCEPTION 'datatype not supported';
END CASE;	
obj.cityobject_id := NEW.cityobject_id;

SELECT qgis_pkg.ins_t_cityobject_genericattrib(obj, cdb_schema) INTO inserted_id;

RETURN NEW;
EXCEPTION
  WHEN OTHERS THEN RAISE NOTICE 'qgis_pkg.tr_ins_dv_cityobject_genericattrib(id: %): %', inserted_id, SQLERRM;
END;
$$ LANGUAGE plpgsql;
COMMENT ON FUNCTION qgis_pkg.tr_ins_dv_cityobject_genericattrib IS 'Trigger to insert a new record of table CITYOBJECT_GENERICATTRIB from a detail view';
REVOKE EXECUTE ON FUNCTION qgis_pkg.tr_ins_dv_cityobject_genericattrib FROM public;

----------------------------------------------------------------
-- Create trigger FUNCTION QGIS_PKG.TR_DEL_DV_EXTERNAL_REFERENCE
----------------------------------------------------------------
-- This trigger function is for the detail view (prefix = 'dv_')!
DROP FUNCTION IF EXISTS    qgis_pkg.tr_del_dv_external_reference CASCADE;
CREATE OR REPLACE FUNCTION qgis_pkg.tr_del_dv_external_reference()
RETURNS trigger AS $$
DECLARE
  dv_prefix  CONSTANT varchar := 'dv_';
  cdb_schema CONSTANT varchar := split_part(split_part(TG_TABLE_NAME, '_ext_ref_', 1), dv_prefix, 2);
BEGIN
EXECUTE format('SELECT %I.del_external_reference(ARRAY[$1]);', cdb_schema) USING OLD.id;
RETURN OLD;
EXCEPTION
  WHEN OTHERS THEN RAISE NOTICE 'qgis_pkg.tr_del_dv_external_reference(id: %): %', OLD.id, SQLERRM;
END;
$$ LANGUAGE plpgsql;
COMMENT ON FUNCTION qgis_pkg.tr_del_dv_external_reference IS 'Trigger to delete record of table EXTERNAL_REFERENCE from a detail view';
REVOKE EXECUTE ON FUNCTION qgis_pkg.tr_del_dv_external_reference FROM public;

----------------------------------------------------------------
-- Create trigger FUNCTION QGIS_PKG.TR_UPD_DV_EXTERNAL_REFERENCE
----------------------------------------------------------------
-- This trigger function is for the detail view (prefix = 'dv_')!
DROP FUNCTION IF EXISTS    qgis_pkg.tr_upd_dv_external_reference CASCADE;
CREATE OR REPLACE FUNCTION qgis_pkg.tr_upd_dv_external_reference()
RETURNS trigger AS $$
DECLARE
  dv_prefix  CONSTANT varchar := 'dv_';
  cdb_schema CONSTANT varchar := split_part(split_part(TG_TABLE_NAME, '_ext_ref_', 1), dv_prefix, 2);
  data_type  CONSTANT varchar := split_part(TG_TABLE_NAME, '_ext_ref_', 2);
  obj    qgis_pkg.obj_external_reference;
BEGIN
obj.id            := OLD.id;
obj.infosys       := NEW.infosys;
CASE data_type
	WHEN 'name' THEN
		obj.name          := NEW.value;
		obj.uri           := NULL;	
	WHEN 'uri' THEN
		obj.name          := NULL;
		obj.uri           := NEW.value;
	ELSE
		RAISE EXCEPTION 'datatype not supported';
END CASE;
--obj.cityobject_id := NEW.cityobject_id;

PERFORM qgis_pkg.upd_t_external_reference(obj, cdb_schema);

RETURN NEW;
EXCEPTION
  WHEN OTHERS THEN RAISE NOTICE 'qgis_pkg.tr_upd_dv_external_reference(id: %): %', OLD.id, SQLERRM;
END;
$$ LANGUAGE plpgsql;
COMMENT ON FUNCTION qgis_pkg.tr_upd_dv_external_reference IS 'Trigger to update a record of tabel EXTERNAL_REFERENCE from a detail view';
REVOKE EXECUTE ON FUNCTION qgis_pkg.tr_upd_dv_external_reference FROM public;

----------------------------------------------------------------
-- Create trigger FUNCTION QGIS_PKG.TR_INS_DV_EXTERNAL_REFERENCE
----------------------------------------------------------------
-- This trigger function is for the detail view (prefix = 'dv_')!
DROP FUNCTION IF EXISTS    qgis_pkg.tr_ins_dv_external_reference CASCADE;
CREATE OR REPLACE FUNCTION qgis_pkg.tr_ins_dv_external_reference()
RETURNS trigger AS $$
DECLARE
  dv_prefix  CONSTANT varchar := 'dv_';
  cdb_schema CONSTANT varchar := split_part(split_part(TG_TABLE_NAME, '_ext_ref_', 1), dv_prefix, 2);
  data_type  CONSTANT varchar := split_part(TG_TABLE_NAME, '_ext_ref_', 2);
  obj qgis_pkg.obj_external_reference;
  inserted_id bigint;
BEGIN
obj.id            := NEW.id;
obj.infosys       := NEW.infosys;
CASE data_type
	WHEN 'name' THEN
		obj.name          := NEW.value;
		obj.uri           := NULL;	
	WHEN 'uri' THEN
		obj.name          := NULL;
		obj.uri           := NEW.value;
	ELSE
		RAISE EXCEPTION 'datatype not supported';		
END CASE;	
obj.cityobject_id := NEW.cityobject_id;

SELECT qgis_pkg.ins_t_external_reference(obj, cdb_schema) INTO inserted_id;

RETURN NEW;
EXCEPTION
  WHEN OTHERS THEN RAISE NOTICE 'qgis_pkg.tr_ins_dv_external_reference(id: %): %', inserted_id, SQLERRM;
END;

$$ LANGUAGE plpgsql;
COMMENT ON FUNCTION qgis_pkg.tr_ins_dv_external_reference IS 'Trigger to insert a new record of table EXTERNAL_REFERENCE from a detail view';
REVOKE EXECUTE ON FUNCTION qgis_pkg.tr_ins_dv_external_reference FROM public;


--**************************
DO $MAINBODY$
BEGIN
RAISE NOTICE E'\n\nDone\n\n';
END $MAINBODY$;
--**************************

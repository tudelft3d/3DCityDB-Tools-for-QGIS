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
-- This script installs in schema qgis_pkg insert functions for the views
-- that will be generated in the usr_schemas.
--
-- ***********************************************************************

----------------------------------------------------------------
-- Create FUNCTION QGIS_PKG.INS_ADDRESS_ATTS
----------------------------------------------------------------
DROP FUNCTION IF EXISTS    qgis_pkg.ins_address_atts(qgis_pkg.obj_address, varchar) CASCADE;
CREATE OR REPLACE FUNCTION qgis_pkg.ins_address_atts(
obj         qgis_pkg.obj_address,
cdb_schema varchar
)
RETURNS bigint AS $$
DECLARE
  inserted_id bigint;
BEGIN
SELECT qgis_pkg.ins_t_address(obj, cdb_schema) INTO inserted_id;
RETURN inserted_id;
EXCEPTION
  WHEN OTHERS THEN RAISE NOTICE 'qgis_pkg.ins_address_atts(id: %): %', inserted_id, SQLERRM;
END;
$$ LANGUAGE plpgsql;
COMMENT ON FUNCTION qgis_pkg.ins_address_atts(qgis_pkg.obj_address, varchar) IS 'Insert new record into table ADDRESS of selected cdb_schema';
REVOKE EXECUTE ON FUNCTION qgis_pkg.ins_address_atts(qgis_pkg.obj_address, varchar) FROM public;


----------------------------------------------------------------
-- Create FUNCTION QGIS_PKG.INS_CITYOBJECT_GENERICATTRIB_ATTS
----------------------------------------------------------------
DROP FUNCTION IF EXISTS    qgis_pkg.ins_cityobject_genericattrib_atts(qgis_pkg.obj_cityobject_genericattrib, varchar) CASCADE;
CREATE OR REPLACE FUNCTION qgis_pkg.ins_cityobject_genericattrib_atts(
obj         qgis_pkg.obj_cityobject_genericattrib,
cdb_schema varchar
)
RETURNS bigint AS $$
DECLARE
  inserted_id bigint;
BEGIN
SELECT qgis_pkg.ins_t_cityobject_genericattrib(obj, cdb_schema) INTO inserted_id;
RETURN inserted_id;
EXCEPTION
  WHEN OTHERS THEN RAISE NOTICE 'qgis_pkg.ins_cityobject_genericattrib_atts(id: %): %', inserted, SQLERRM;
END;
$$ LANGUAGE plpgsql;
COMMENT ON FUNCTION qgis_pkg.ins_cityobject_genericattrib_atts(qgis_pkg.obj_cityobject_genericattrib, varchar) IS 'Insert new record into table CITYOBJECT_GENERICATTRIB of selected cdb_schema';
REVOKE EXECUTE ON FUNCTION qgis_pkg.ins_cityobject_genericattrib_atts(qgis_pkg.obj_cityobject_genericattrib, varchar) FROM public;


----------------------------------------------------------------
-- Create FUNCTION QGIS_PKG.INS_EXTERNAL_REFERENCE_ATTS
----------------------------------------------------------------
DROP FUNCTION IF EXISTS    qgis_pkg.ins_external_reference_atts(qgis_pkg.obj_external_reference, varchar) CASCADE;
CREATE OR REPLACE FUNCTION qgis_pkg.ins_external_reference_atts(
obj         qgis_pkg.obj_external_reference,
cdb_schema varchar
)
RETURNS bigint AS $$
DECLARE
  inserted_id bigint;
BEGIN
SELECT qgis_pkg.ins_t_external_reference(obj, cdb_schema) INTO inserted_id;
RETURN inserted_id;
EXCEPTION
  WHEN OTHERS THEN RAISE NOTICE 'qgis_pkg.ins_external_reference_atts(id: %): %', inserted_id, SQLERRM;
END;
$$ LANGUAGE plpgsql;
COMMENT ON FUNCTION qgis_pkg.ins_external_reference_atts(qgis_pkg.obj_external_reference, varchar) IS 'Insert new record into table EXTERNAL_REFERENCE of selected cdb_schema';
REVOKE EXECUTE ON FUNCTION qgis_pkg.ins_external_reference_atts(qgis_pkg.obj_external_reference, varchar) FROM public;



--**************************
DO $MAINBODY$
BEGIN
RAISE NOTICE E'\n\nDone\n\n';
END $MAINBODY$;
--**************************

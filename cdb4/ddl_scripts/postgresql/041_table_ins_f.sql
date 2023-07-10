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
-- This script installs insert functions for tables address,
-- external_reference, cityobject_genericattrib.
--
--
-- ***********************************************************************


----------------------------------------------------------------
-- Create FUNCTION QGIS_PKG_DEV.INS_T_ADDRESS
----------------------------------------------------------------
DROP FUNCTION IF EXISTS    qgis_pkg.ins_t_address(qgis_pkg.obj_address, varchar) CASCADE;
CREATE OR REPLACE FUNCTION qgis_pkg.ins_t_address(
obj         qgis_pkg.obj_address,
cdb_schema varchar
)
RETURNS bigint AS $$
DECLARE
  seq_name varchar := concat(cdb_schema,'.address_seq');
  srid integer;
  inserted_id bigint;
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
	-- Ensure that geometry is always cast to a multi geometry. If it is already, nothing happens.
	obj.multi_point := ST_Multi(obj.multi_point);
	-- Check that it is indeed a point geometry
	IF ST_GeometryType(obj.multi_point) <> 'ST_MultiPoint' THEN
		RAISE EXCEPTION 'geometry type must be "ST_Multipoint", but is "%"', ST_GeometryType(obj.multi_point);
	END IF;
	-- Enforce 3D, even though it will have a 0 height coordinate
	obj.multi_point := ST_Force3D(obj.multi_point);
END IF;
-- For the time being, set the xal_source to NULL.
obj.xal_source = NULL;
/*
IF obj.xal_source IS NULL THEN
	obj.xal_source := concat('<?xml version="1.0" encoding="windows-1252" standalone="yes"?><xAL:AddressDetails xmlns:xAL="urn:oasis:names:tc:ciq:xsdschema:xAL:2.0"><xAL:Country><xAL:CountryNameCode>ALD</xAL:CountryNameCode><xAL:CountryName>Bespin Territories</xAL:CountryName><xAL:Locality Type="Town"><xAL:LocalityName>Alderaan</xAL:LocalityName><xAL:Thoroughfare Type="Street"><xAL:ThoroughfareNumber>10</xAL:ThoroughfareNumber><xAL:ThoroughfareName>Bespin Square</xAL:ThoroughfareName></xAL:Thoroughfare><xAL:PostalCode><xAL:PostalCodeNumber>1977SW</xAL:PostalCodeNumber></xAL:PostalCode></xAL:Locality></xAL:Country></xAL:AddressDetails>');
END IF;
<?xml version="1.0" encoding="windows-1252" standalone="yes"?>
<xAL:AddressDetails xmlns:xAL="urn:oasis:names:tc:ciq:xsdschema:xAL:2.0">
	<xAL:Country>
		<xAL:CountryNameCode>ALD</xAL:CountryNameCode>
		<xAL:CountryName>Bespin Territories</xAL:CountryName>
		<xAL:Locality Type="Town">
			<xAL:LocalityName>Alderaan</xAL:LocalityName>
			<xAL:Thoroughfare Type="Street">
				<xAL:ThoroughfareNumber>10</xAL:ThoroughfareNumber>
				<xAL:ThoroughfareName>Bespin Square</xAL:ThoroughfareName>
			</xAL:Thoroughfare>
			<xAL:PostalCode>
				<xAL:PostalCodeNumber>1977SW</xAL:PostalCodeNumber>
			</xAL:PostalCode>
		</xAL:Locality>
	</xAL:Country>
</xAL:AddressDetails>
*/
-- Assign new ID to PK
IF obj.id IS NULL THEN
	obj.id := nextval(seq_name::regclass);
END IF;

EXECUTE format('
INSERT INTO %I.address AS t
(id, gmlid, gmlid_codespace, street, house_number, po_box, zip_code, city, state, country, multi_point, xal_source)
SELECT ($1).* RETURNING id', cdb_schema) INTO inserted_id USING obj;      

RETURN inserted_id;
EXCEPTION
  WHEN OTHERS THEN RAISE NOTICE 'qgis_pkg.ins_t_address(id: %): %', obj.id, SQLERRM;
END;
$$ LANGUAGE plpgsql;
COMMENT ON FUNCTION qgis_pkg.ins_t_address(qgis_pkg.obj_address, varchar) IS 'Insert a new record into table ADDRESS';
REVOKE EXECUTE ON FUNCTION qgis_pkg.ins_t_address(qgis_pkg.obj_address, varchar) FROM public;


----------------------------------------------------------------
-- Create FUNCTION QGIS_PKG_DEV.INS_T_CITYOBJECT_GENERICATTRIB
----------------------------------------------------------------
-- ********************************
-- Possible values for datatype
-- 1 STRING          (varchar)
-- 2 INTEGER         (integer)
-- 3 REAL            (double)
-- 4 URI             (varchar)
-- 5 DATE            (timestamptz)
-- 6 MEASURE         (double + varchar)
-- 7 Group of generic attributes
-- 8 BLOB            (bytea)
-- 9 Geometry type   (geometry)
-- 10 Geometry via surfaces in the table SURFACE_GEOMETRY (integer)
-- ********************************
DROP FUNCTION IF EXISTS    qgis_pkg.ins_t_cityobject_genericattrib(qgis_pkg.obj_cityobject_genericattrib, varchar) CASCADE;
CREATE OR REPLACE FUNCTION qgis_pkg.ins_t_cityobject_genericattrib(
obj        qgis_pkg.obj_cityobject_genericattrib,
cdb_schema varchar
)
RETURNS bigint AS $$
DECLARE
  seq_name varchar := concat(cdb_schema,'.cityobject_genericatt_seq');
  datatype_enum integer[] := ARRAY[1,2,3,4,5,6,7,8,9,10];
  inserted_id bigint;
BEGIN
-- checks
IF obj.attrname IS NULL THEN
  RAISE EXCEPTION 'attrname value must be NOT NULL';
END IF;
IF (obj.datatype IS NULL) OR NOT(obj.datatype = ANY(datatype_enum)) THEN
  RAISE EXCEPTION 'datatype value must be NOT NULL and one of %', datatype_enum;
END IF;
IF obj.cityobject_id IS NULL THEN
  RAISE EXCEPTION 'cityobject_id value must be NOT NULL and reference an existing (city)object';
END IF;

-- Assign new ID to PK
IF obj.id IS NULL THEN
	obj.id := nextval(seq_name::regclass);
	obj.root_genattrib_id := obj.id;
END IF;

EXECUTE format('
INSERT INTO %I.cityobject_genericattrib AS t 
(id, parent_genattrib_id, root_genattrib_id, attrname, datatype, strval, intval, realval, 
urival, dateval, unit, genattribset_codespace, blobval, geomval, surface_geometry_id, cityobject_id)
SELECT ($1).* RETURNING id', cdb_schema) INTO inserted_id USING obj;

RETURN inserted_id;
EXCEPTION
  WHEN OTHERS THEN RAISE NOTICE 'qgis_pkg.ins_t_cityobject_genericattrib(id: %): %', inserted_id, SQLERRM;
END;
$$ LANGUAGE plpgsql;
COMMENT ON FUNCTION qgis_pkg.ins_t_cityobject_genericattrib(qgis_pkg.obj_cityobject_genericattrib, varchar) IS 'Insert a new record into table CITYOBJECT_GENERICATTRIB';
REVOKE EXECUTE ON FUNCTION qgis_pkg.ins_t_cityobject_genericattrib(qgis_pkg.obj_cityobject_genericattrib, varchar) FROM public;

--SELECT 
--qgis_pkg.ins_t_cityobject_genericattrib(
--ROW(NULL,NULL,NULL,'pippo_string',1,'ciao ciao ciao', NULL, NULL, NULL, NULL, NULL, NULL, NULL::bytea, NULL, NULL,
--1)::qgis_pkg.obj_cityobject_genericattrib
--,'alderaan');

----------------------------------------------------------------
-- Create FUNCTION QGIS_PKG_DEV.INS_T_EXTERNAL_REFERENCE
----------------------------------------------------------------
DROP FUNCTION IF EXISTS    qgis_pkg.ins_t_external_reference(qgis_pkg.obj_external_reference, varchar) CASCADE;
CREATE OR REPLACE FUNCTION qgis_pkg.ins_t_external_reference(
obj         qgis_pkg.obj_external_reference,
cdb_schema  varchar
)
RETURNS bigint AS $$
DECLARE
  seq_name varchar := concat(cdb_schema,'.external_ref_seq');
  inserted_id bigint;
BEGIN
-- checks
IF ((obj.name IS NOT NULL) AND (obj.uri IS NOT NULL)) THEN
   RAISE EXCEPTION 'Only one value of name ("%") or uri ("%") are allowed at the same time', obj.name, obj.uri;
END IF;
IF ((obj.name IS NULL) AND (obj.uri IS NULL)) THEN
   RAISE EXCEPTION 'At least one of name or uri values must be provided';
END IF;
IF obj.cityobject_id IS NULL THEN
  RAISE EXCEPTION 'cityobject_id value must be NOT NULL and reference an existing (city)object';
END IF;

-- Assign new ID to PK
IF obj.id IS NULL THEN
	obj.id := nextval(seq_name::regclass);
END IF;

EXECUTE format('
INSERT INTO %I.external_reference AS t 
(id, infosys, name, uri, cityobject_id)
SELECT ($1).* RETURNING id', cdb_schema) INTO inserted_id USING obj;

RETURN inserted_id;
EXCEPTION
  WHEN OTHERS THEN RAISE NOTICE 'qgis_pkg.ins_t_external_reference(id: %): %', obj.id, SQLERRM;
END;
$$ LANGUAGE plpgsql;
COMMENT ON FUNCTION qgis_pkg.ins_t_external_reference(qgis_pkg.obj_external_reference, varchar) IS 'Insert a new record into table EXTERNAL_REFERENCE';
REVOKE EXECUTE ON FUNCTION qgis_pkg.ins_t_external_reference(qgis_pkg.obj_external_reference, varchar) FROM public;

--SELECT qgis_pkg.ins_t_external_reference(
--ROW(NULL,'gio_infosys',NULL, NULL,1)	--::qgis_pkg.obj_external_reference (cast is optional)
--ROW(NULL,'gio_infosys',NULL, 'gio_uri',1)
--ROW(NULL,'gio_infosys','gio_name', NULL,1)
--ROW(NULL,'gio_infosys','gio_name', 'gio_uri',1)	
--, 'alderaan');


--**************************
DO $MAINBODY$
DECLARE
BEGIN
RAISE NOTICE E'\n\nDone\n\n';
END $MAINBODY$;
--**************************
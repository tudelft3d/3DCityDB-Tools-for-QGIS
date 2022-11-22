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
-- This script installs in schema qgis_pkg update functions for the views
-- that will be generated in the usr_schemas.
--
-- ***********************************************************************

----------------------------------------------------------------
-- Create FUNCTION QGIS_PKG.UPD_BRIDGE_OPENING_ATTS
----------------------------------------------------------------
DROP FUNCTION IF EXISTS    qgis_pkg.upd_bridge_opening_atts(qgis_pkg.obj_cityobject, varchar) CASCADE;
CREATE OR REPLACE FUNCTION qgis_pkg.upd_bridge_opening_atts(
obj         qgis_pkg.obj_cityobject,
cdb_schema varchar
)
RETURNS bigint AS $$
DECLARE
  updated_id bigint;
BEGIN
SELECT qgis_pkg.upd_t_cityobject(obj, cdb_schema) INTO updated_id;
RETURN updated_id;
EXCEPTION
  WHEN OTHERS THEN RAISE NOTICE 'qgis_pkg.upd_bridge_opening_atts(id: %): %', obj.id, SQLERRM;
END;
$$ LANGUAGE plpgsql;
COMMENT ON FUNCTION qgis_pkg.upd_bridge_opening_atts(qgis_pkg.obj_cityobject, varchar) IS 'Update attributes of table BRIDGE_OPENING (and parent ones)';
REVOKE EXECUTE ON FUNCTION qgis_pkg.upd_bridge_opening_atts(qgis_pkg.obj_cityobject, varchar) FROM public;

----------------------------------------------------------------
-- Create FUNCTION QGIS_PKG.UPD_BRIDGE_THEMATIC_SURFACE_ATTS
----------------------------------------------------------------
DROP FUNCTION IF EXISTS    qgis_pkg.upd_bridge_thematic_surface_atts(qgis_pkg.obj_cityobject, varchar) CASCADE;
CREATE OR REPLACE FUNCTION qgis_pkg.upd_bridge_thematic_surface_atts(
obj         qgis_pkg.obj_cityobject,
cdb_schema varchar
)
RETURNS bigint AS $$
DECLARE
  updated_id bigint;
BEGIN
SELECT qgis_pkg.upd_t_cityobject(obj, cdb_schema) INTO updated_id;
RETURN updated_id;
EXCEPTION
  WHEN OTHERS THEN RAISE NOTICE 'qgis_pkg.upd_bridge_thematic_surface_atts(id: %): %', obj.id, SQLERRM;
END;
$$ LANGUAGE plpgsql;
COMMENT ON FUNCTION qgis_pkg.upd_bridge_thematic_surface_atts(qgis_pkg.obj_cityobject, varchar) IS 'Update attributes of table BRIDGE_THEMATIC_SURFACE (and parent ones)';
REVOKE EXECUTE ON FUNCTION qgis_pkg.upd_bridge_thematic_surface_atts(qgis_pkg.obj_cityobject, varchar) FROM public;

----------------------------------------------------------------
-- Create FUNCTION QGIS_PKG.UPD_OPENING_ATTS
----------------------------------------------------------------
DROP FUNCTION IF EXISTS    qgis_pkg.upd_opening_atts(qgis_pkg.obj_cityobject, varchar) CASCADE;
CREATE OR REPLACE FUNCTION qgis_pkg.upd_opening_atts(
obj         qgis_pkg.obj_cityobject,
cdb_schema varchar
)
RETURNS bigint AS $$
DECLARE
  updated_id bigint;
BEGIN
SELECT qgis_pkg.upd_t_cityobject(obj, cdb_schema) INTO updated_id;
RETURN updated_id;
EXCEPTION
  WHEN OTHERS THEN RAISE NOTICE 'qgis_pkg.upd_opening_atts(id: %): %', obj.id, SQLERRM;
END;
$$ LANGUAGE plpgsql;
COMMENT ON FUNCTION qgis_pkg.upd_opening_atts(qgis_pkg.obj_cityobject, varchar) IS 'Update attributes of table OPENING (and parent ones)';
REVOKE EXECUTE ON FUNCTION qgis_pkg.upd_opening_atts(qgis_pkg.obj_cityobject, varchar) FROM public;

----------------------------------------------------------------
-- Create FUNCTION QGIS_PKG.UPD_THEMATIC_SURFACE_ATTS
----------------------------------------------------------------
DROP FUNCTION IF EXISTS    qgis_pkg.upd_thematic_surface_atts(qgis_pkg.obj_cityobject, varchar) CASCADE;
CREATE OR REPLACE FUNCTION qgis_pkg.upd_thematic_surface_atts(
obj         qgis_pkg.obj_cityobject,
cdb_schema varchar
)
RETURNS bigint AS $$
DECLARE
  updated_id bigint;
BEGIN
SELECT qgis_pkg.upd_t_cityobject(obj, cdb_schema) INTO updated_id;
RETURN updated_id;
EXCEPTION
  WHEN OTHERS THEN RAISE NOTICE 'qgis_pkg.upd_thematic_surface_atts(id: %): %', obj.id, SQLERRM;
END;
$$ LANGUAGE plpgsql;
COMMENT ON FUNCTION qgis_pkg.upd_thematic_surface_atts(qgis_pkg.obj_cityobject, varchar) IS 'Update attributes of table THEMATIC_SURFACE (and parent ones)';
REVOKE EXECUTE ON FUNCTION qgis_pkg.upd_thematic_surface_atts(qgis_pkg.obj_cityobject, varchar) FROM public;

----------------------------------------------------------------
-- Create FUNCTION QGIS_PKG.UPD_TUNNEL_OPENING_ATTS
----------------------------------------------------------------
DROP FUNCTION IF EXISTS    qgis_pkg.upd_tunnel_opening_atts(qgis_pkg.obj_cityobject, varchar) CASCADE;
CREATE OR REPLACE FUNCTION qgis_pkg.upd_tunnel_opening_atts(
obj         qgis_pkg.obj_cityobject,
cdb_schema varchar
)
RETURNS bigint AS $$
DECLARE
  updated_id bigint;
BEGIN
SELECT qgis_pkg.upd_t_cityobject(obj, cdb_schema) INTO updated_id;
RETURN updated_id;
EXCEPTION
  WHEN OTHERS THEN RAISE NOTICE 'qgis_pkg.upd_tunnel_opening_atts(id: %): %', obj.id, SQLERRM;
END;
$$ LANGUAGE plpgsql;
COMMENT ON FUNCTION qgis_pkg.upd_tunnel_opening_atts(qgis_pkg.obj_cityobject, varchar) IS 'Update attributes of table TUNNEL_OPENING (and parent ones)';
REVOKE EXECUTE ON FUNCTION qgis_pkg.upd_tunnel_opening_atts(qgis_pkg.obj_cityobject, varchar) FROM public;

----------------------------------------------------------------
-- Create FUNCTION QGIS_PKG.UPD_TUNNEL_THEMATIC_SURFACE_ATTS
----------------------------------------------------------------
DROP FUNCTION IF EXISTS    qgis_pkg.upd_tunnel_thematic_surface_atts(qgis_pkg.obj_cityobject, varchar) CASCADE;
CREATE OR REPLACE FUNCTION qgis_pkg.upd_tunnel_thematic_surface_atts(
obj         qgis_pkg.obj_cityobject,
cdb_schema varchar
)
RETURNS bigint AS $$
DECLARE
  updated_id bigint;
BEGIN
SELECT qgis_pkg.upd_t_cityobject(obj, cdb_schema) INTO updated_id;
RETURN updated_id;
EXCEPTION
  WHEN OTHERS THEN RAISE NOTICE 'qgis_pkg.upd_tunnel_thematic_surface_atts(id: %): %', obj.id, SQLERRM;
END;
$$ LANGUAGE plpgsql;
COMMENT ON FUNCTION qgis_pkg.upd_tunnel_thematic_surface_atts(qgis_pkg.obj_cityobject, varchar) IS 'Update attributes of table TUNNEL_THEMATIC_SURFACE (and parent ones)';
REVOKE EXECUTE ON FUNCTION qgis_pkg.upd_tunnel_thematic_surface_atts(qgis_pkg.obj_cityobject, varchar) FROM public;

----------------------------------------------------------------
-- Create FUNCTION QGIS_PKG.UPD_WATERBOUNDARY_SURFACE_ATTS
----------------------------------------------------------------
DROP FUNCTION IF EXISTS    qgis_pkg.upd_waterboundary_surface_atts(qgis_pkg.obj_cityobject, varchar) CASCADE;
CREATE OR REPLACE FUNCTION qgis_pkg.upd_waterboundary_surface_atts(
obj         qgis_pkg.obj_cityobject,
cdb_schema varchar
)
RETURNS bigint AS $$
DECLARE
  updated_id bigint;
BEGIN
SELECT qgis_pkg.upd_t_cityobject(obj, cdb_schema) INTO updated_id;
RETURN updated_id;
EXCEPTION
  WHEN OTHERS THEN RAISE NOTICE 'qgis_pkg.upd_waterboundary_surface_atts(id: %): %', obj.id, SQLERRM;
END;
$$ LANGUAGE plpgsql;
COMMENT ON FUNCTION qgis_pkg.upd_waterboundary_surface_atts(qgis_pkg.obj_cityobject, varchar) IS 'Update attributes of table WATERBOUNDARY_SURFACE (and parent ones)';
REVOKE EXECUTE ON FUNCTION qgis_pkg.upd_waterboundary_surface_atts(qgis_pkg.obj_cityobject, varchar) FROM public;

----------------------------------------------------------------
-- Create FUNCTION QGIS_PKG.UPD_BRIDGE_ATTS
----------------------------------------------------------------
DROP FUNCTION IF EXISTS    qgis_pkg.upd_bridge_atts(qgis_pkg.obj_cityobject, qgis_pkg.obj_bridge, varchar) CASCADE;
CREATE OR REPLACE FUNCTION qgis_pkg.upd_bridge_atts(
obj         qgis_pkg.obj_cityobject,
obj_1       qgis_pkg.obj_bridge,
cdb_schema varchar 
)
RETURNS bigint AS $$
DECLARE
  updated_id bigint;
BEGIN

SELECT  qgis_pkg.upd_t_cityobject(obj, cdb_schema) INTO updated_id;
PERFORM qgis_pkg.upd_t_bridge(obj_1, cdb_schema);

RETURN updated_id;
EXCEPTION
  WHEN OTHERS THEN RAISE NOTICE 'qgis_pkg.upd_bridge_atts(id: %): %', obj.id, SQLERRM;
END;
$$ LANGUAGE plpgsql;
COMMENT ON FUNCTION qgis_pkg.upd_bridge_atts(qgis_pkg.obj_cityobject, qgis_pkg.obj_bridge, varchar) IS 'Update attributes of table BRIDGE (and parent ones)';
REVOKE EXECUTE ON FUNCTION qgis_pkg.upd_bridge_atts(qgis_pkg.obj_cityobject, qgis_pkg.obj_bridge, varchar) FROM public;

----------------------------------------------------------------
-- Create FUNCTION QGIS_PKG.UPD_BRIDGE_CONSTR_ELEMENT_ATTS
----------------------------------------------------------------
DROP FUNCTION IF EXISTS    qgis_pkg.upd_bridge_constr_element_atts(qgis_pkg.obj_cityobject, qgis_pkg.obj_bridge_constr_element, varchar) CASCADE;
CREATE OR REPLACE FUNCTION qgis_pkg.upd_bridge_constr_element_atts(
obj         qgis_pkg.obj_cityobject,
obj_1       qgis_pkg.obj_bridge_constr_element,
cdb_schema varchar 
)
RETURNS bigint AS $$
DECLARE
  updated_id bigint;
BEGIN

SELECT  qgis_pkg.upd_t_cityobject(obj, cdb_schema) INTO updated_id;
PERFORM qgis_pkg.upd_t_bridge_constr_element(obj_1, cdb_schema);

RETURN updated_id;
EXCEPTION
  WHEN OTHERS THEN RAISE NOTICE 'qgis_pkg.upd_bridge_constr_element_atts(id: %): %', obj.id, SQLERRM;
END;
$$ LANGUAGE plpgsql;
COMMENT ON FUNCTION qgis_pkg.upd_bridge_constr_element_atts(qgis_pkg.obj_cityobject, qgis_pkg.obj_bridge_constr_element, varchar) IS 'Update attributes of table BRIDGE_CONSTR_ELEMENT (and parent ones)';
REVOKE EXECUTE ON FUNCTION qgis_pkg.upd_bridge_constr_element_atts(qgis_pkg.obj_cityobject, qgis_pkg.obj_bridge_constr_element, varchar) FROM public;

----------------------------------------------------------------
-- Create FUNCTION QGIS_PKG.UPD_BRIDGE_FURNITURE_ATTS
----------------------------------------------------------------
DROP FUNCTION IF EXISTS    qgis_pkg.upd_bridge_furniture_atts(qgis_pkg.obj_cityobject, qgis_pkg.obj_bridge_furniture, varchar) CASCADE;
CREATE OR REPLACE FUNCTION qgis_pkg.upd_bridge_furniture_atts(
obj         qgis_pkg.obj_cityobject,
obj_1       qgis_pkg.obj_bridge_furniture,
cdb_schema varchar 
)
RETURNS bigint AS $$
DECLARE
  updated_id bigint;
BEGIN

SELECT  qgis_pkg.upd_t_cityobject(obj, cdb_schema) INTO updated_id;
PERFORM qgis_pkg.upd_t_bridge_furniture(obj_1, cdb_schema);

RETURN updated_id;
EXCEPTION
  WHEN OTHERS THEN RAISE NOTICE 'qgis_pkg.upd_bridge_furniture_atts(id: %): %', obj.id, SQLERRM;
END;
$$ LANGUAGE plpgsql;
COMMENT ON FUNCTION qgis_pkg.upd_bridge_furniture_atts(qgis_pkg.obj_cityobject, qgis_pkg.obj_bridge_furniture, varchar) IS 'Update attributes of table BRIDGE_FURNITURE (and parent ones)';
REVOKE EXECUTE ON FUNCTION qgis_pkg.upd_bridge_furniture_atts(qgis_pkg.obj_cityobject, qgis_pkg.obj_bridge_furniture, varchar) FROM public;

----------------------------------------------------------------
-- Create FUNCTION QGIS_PKG.UPD_BRIDGE_INSTALLATION_ATTS
----------------------------------------------------------------
DROP FUNCTION IF EXISTS    qgis_pkg.upd_bridge_installation_atts(qgis_pkg.obj_cityobject, qgis_pkg.obj_bridge_installation, varchar) CASCADE;
CREATE OR REPLACE FUNCTION qgis_pkg.upd_bridge_installation_atts(
obj         qgis_pkg.obj_cityobject,
obj_1       qgis_pkg.obj_bridge_installation,
cdb_schema varchar 
)
RETURNS bigint AS $$
DECLARE
  updated_id bigint;
BEGIN

SELECT  qgis_pkg.upd_t_cityobject(obj, cdb_schema) INTO updated_id;
PERFORM qgis_pkg.upd_t_bridge_installation(obj_1, cdb_schema);

RETURN updated_id;
EXCEPTION
  WHEN OTHERS THEN RAISE NOTICE 'qgis_pkg.upd_bridge_installation_atts(id: %): %', obj.id, SQLERRM;
END;
$$ LANGUAGE plpgsql;
COMMENT ON FUNCTION qgis_pkg.upd_bridge_installation_atts(qgis_pkg.obj_cityobject, qgis_pkg.obj_bridge_installation, varchar) IS 'Update attributes of table BRIDGE_INSTALLATION (and parent ones)';
REVOKE EXECUTE ON FUNCTION qgis_pkg.upd_bridge_installation_atts(qgis_pkg.obj_cityobject, qgis_pkg.obj_bridge_installation, varchar) FROM public;

----------------------------------------------------------------
-- Create FUNCTION QGIS_PKG.UPD_BRIDGE_ROOM_ATTS
----------------------------------------------------------------
DROP FUNCTION IF EXISTS    qgis_pkg.upd_bridge_room_atts(qgis_pkg.obj_cityobject, qgis_pkg.obj_bridge_room, varchar) CASCADE;
CREATE OR REPLACE FUNCTION qgis_pkg.upd_bridge_room_atts(
obj         qgis_pkg.obj_cityobject,
obj_1       qgis_pkg.obj_bridge_room,
cdb_schema varchar 
)
RETURNS bigint AS $$
DECLARE
  updated_id bigint;
BEGIN

SELECT  qgis_pkg.upd_t_cityobject(obj, cdb_schema) INTO updated_id;
PERFORM qgis_pkg.upd_t_bridge_room(obj_1, cdb_schema);

RETURN updated_id;
EXCEPTION
  WHEN OTHERS THEN RAISE NOTICE 'qgis_pkg.upd_bridge_room_atts(id: %): %', obj.id, SQLERRM;
END;
$$ LANGUAGE plpgsql;
COMMENT ON FUNCTION qgis_pkg.upd_bridge_room_atts(qgis_pkg.obj_cityobject, qgis_pkg.obj_bridge_room, varchar) IS 'Update attributes of table BRIDGE_ROOM (and parent ones)';
REVOKE EXECUTE ON FUNCTION qgis_pkg.upd_bridge_room_atts(qgis_pkg.obj_cityobject, qgis_pkg.obj_bridge_room, varchar) FROM public;

----------------------------------------------------------------
-- Create FUNCTION QGIS_PKG.UPD_BUILDING_ATTS
----------------------------------------------------------------
DROP FUNCTION IF EXISTS    qgis_pkg.upd_building_atts(qgis_pkg.obj_cityobject, qgis_pkg.obj_building, varchar) CASCADE;
CREATE OR REPLACE FUNCTION qgis_pkg.upd_building_atts(
obj         qgis_pkg.obj_cityobject,
obj_1       qgis_pkg.obj_building,
cdb_schema varchar 
)
RETURNS bigint AS $$
DECLARE
  updated_id bigint;
BEGIN

SELECT  qgis_pkg.upd_t_cityobject(obj, cdb_schema) INTO updated_id;
PERFORM qgis_pkg.upd_t_building(obj_1, cdb_schema);

RETURN updated_id;
EXCEPTION
  WHEN OTHERS THEN RAISE NOTICE 'qgis_pkg.upd_building_atts(id: %): %', obj.id, SQLERRM;
END;
$$ LANGUAGE plpgsql;
COMMENT ON FUNCTION qgis_pkg.upd_building_atts(qgis_pkg.obj_cityobject, qgis_pkg.obj_building, varchar) IS 'Update attributes of table BUILDING (and parent ones)';
REVOKE EXECUTE ON FUNCTION qgis_pkg.upd_building_atts(qgis_pkg.obj_cityobject, qgis_pkg.obj_building, varchar) FROM public;

----------------------------------------------------------------
-- Create FUNCTION QGIS_PKG.UPD_BUILDING_FURNITURE_ATTS
----------------------------------------------------------------
DROP FUNCTION IF EXISTS    qgis_pkg.upd_building_furniture_atts(qgis_pkg.obj_cityobject, qgis_pkg.obj_building_furniture, varchar) CASCADE;
CREATE OR REPLACE FUNCTION qgis_pkg.upd_building_furniture_atts(
obj         qgis_pkg.obj_cityobject,
obj_1       qgis_pkg.obj_building_furniture,
cdb_schema varchar 
)
RETURNS bigint AS $$
DECLARE
  updated_id bigint;
BEGIN

SELECT  qgis_pkg.upd_t_cityobject(obj, cdb_schema) INTO updated_id;
PERFORM qgis_pkg.upd_t_building_furniture(obj_1, cdb_schema);

RETURN updated_id;
EXCEPTION
  WHEN OTHERS THEN RAISE NOTICE 'qgis_pkg.upd_building_furniture_atts(id: %): %', obj.id, SQLERRM;
END;
$$ LANGUAGE plpgsql;
COMMENT ON FUNCTION qgis_pkg.upd_building_furniture_atts(qgis_pkg.obj_cityobject, qgis_pkg.obj_building_furniture, varchar) IS 'Update attributes of table BUILDING_FURNITURE (and parent ones)';
REVOKE EXECUTE ON FUNCTION qgis_pkg.upd_building_furniture_atts(qgis_pkg.obj_cityobject, qgis_pkg.obj_building_furniture, varchar) FROM public;

----------------------------------------------------------------
-- Create FUNCTION QGIS_PKG.UPD_BUILDING_INSTALLATION_ATTS
----------------------------------------------------------------
DROP FUNCTION IF EXISTS    qgis_pkg.upd_building_installation_atts(qgis_pkg.obj_cityobject, qgis_pkg.obj_building_installation, varchar) CASCADE;
CREATE OR REPLACE FUNCTION qgis_pkg.upd_building_installation_atts(
obj         qgis_pkg.obj_cityobject,
obj_1       qgis_pkg.obj_building_installation,
cdb_schema varchar 
)
RETURNS bigint AS $$
DECLARE
  updated_id bigint;
BEGIN

SELECT  qgis_pkg.upd_t_cityobject(obj, cdb_schema) INTO updated_id;
PERFORM qgis_pkg.upd_t_building_installation(obj_1, cdb_schema);

RETURN updated_id;
EXCEPTION
  WHEN OTHERS THEN RAISE NOTICE 'qgis_pkg.upd_building_installation_atts(id: %): %', obj.id, SQLERRM;
END;
$$ LANGUAGE plpgsql;
COMMENT ON FUNCTION qgis_pkg.upd_building_installation_atts(qgis_pkg.obj_cityobject, qgis_pkg.obj_building_installation, varchar) IS 'Update attributes of table BUILDING_INSTALLATION (and parent ones)';
REVOKE EXECUTE ON FUNCTION qgis_pkg.upd_building_installation_atts(qgis_pkg.obj_cityobject, qgis_pkg.obj_building_installation, varchar) FROM public;

----------------------------------------------------------------
-- Create FUNCTION QGIS_PKG.UPD_CITY_FURNITURE_ATTS
----------------------------------------------------------------
DROP FUNCTION IF EXISTS    qgis_pkg.upd_city_furniture_atts(qgis_pkg.obj_cityobject, qgis_pkg.obj_city_furniture, varchar) CASCADE;
CREATE OR REPLACE FUNCTION qgis_pkg.upd_city_furniture_atts(
obj         qgis_pkg.obj_cityobject,
obj_1       qgis_pkg.obj_city_furniture,
cdb_schema varchar 
)
RETURNS bigint AS $$
DECLARE
  updated_id bigint;
BEGIN

SELECT  qgis_pkg.upd_t_cityobject(obj, cdb_schema) INTO updated_id;
PERFORM qgis_pkg.upd_t_city_furniture(obj_1, cdb_schema);

RETURN updated_id;
EXCEPTION
  WHEN OTHERS THEN RAISE NOTICE 'qgis_pkg.upd_city_furniture_atts(id: %): %', obj.id, SQLERRM;
END;
$$ LANGUAGE plpgsql;
COMMENT ON FUNCTION qgis_pkg.upd_city_furniture_atts(qgis_pkg.obj_cityobject, qgis_pkg.obj_city_furniture, varchar) IS 'Update attributes of table CITY_FURNITURE (and parent ones)';
REVOKE EXECUTE ON FUNCTION qgis_pkg.upd_city_furniture_atts(qgis_pkg.obj_cityobject, qgis_pkg.obj_city_furniture, varchar) FROM public;

----------------------------------------------------------------
-- Create FUNCTION QGIS_PKG.UPD_CITYOBJECTGROUP_ATTS
----------------------------------------------------------------
DROP FUNCTION IF EXISTS    qgis_pkg.upd_cityobjectgroup_atts(qgis_pkg.obj_cityobject, qgis_pkg.obj_cityobjectgroup, varchar) CASCADE;
CREATE OR REPLACE FUNCTION qgis_pkg.upd_cityobjectgroup_atts(
obj         qgis_pkg.obj_cityobject,
obj_1       qgis_pkg.obj_cityobjectgroup,
cdb_schema varchar 
)
RETURNS bigint AS $$
DECLARE
  updated_id bigint;
BEGIN

SELECT  qgis_pkg.upd_t_cityobject(obj, cdb_schema) INTO updated_id;
PERFORM qgis_pkg.upd_t_cityobjectgroup(obj_1, cdb_schema);

RETURN updated_id;
EXCEPTION
  WHEN OTHERS THEN RAISE NOTICE 'qgis_pkg.upd_cityobjectgroup_atts(id: %): %', obj.id, SQLERRM;
END;
$$ LANGUAGE plpgsql;
COMMENT ON FUNCTION qgis_pkg.upd_cityobjectgroup_atts(qgis_pkg.obj_cityobject, qgis_pkg.obj_cityobjectgroup, varchar) IS 'Update attributes of table CITYOBJECTGROUP (and parent ones)';
REVOKE EXECUTE ON FUNCTION qgis_pkg.upd_cityobjectgroup_atts(qgis_pkg.obj_cityobject, qgis_pkg.obj_cityobjectgroup, varchar) FROM public;

----------------------------------------------------------------
-- Create FUNCTION QGIS_PKG.UPD_GENERIC_CITYOBJECT_ATTS
----------------------------------------------------------------
DROP FUNCTION IF EXISTS    qgis_pkg.upd_generic_cityobject_atts(qgis_pkg.obj_cityobject, qgis_pkg.obj_generic_cityobject, varchar) CASCADE;
CREATE OR REPLACE FUNCTION qgis_pkg.upd_generic_cityobject_atts(
obj         qgis_pkg.obj_cityobject,
obj_1       qgis_pkg.obj_generic_cityobject,
cdb_schema varchar 
)
RETURNS bigint AS $$
DECLARE
  updated_id bigint;
BEGIN

SELECT  qgis_pkg.upd_t_cityobject(obj, cdb_schema) INTO updated_id;
PERFORM qgis_pkg.upd_t_generic_cityobject(obj_1, cdb_schema);

RETURN updated_id;
EXCEPTION
  WHEN OTHERS THEN RAISE NOTICE 'qgis_pkg.upd_generic_cityobject_atts(id: %): %', obj.id, SQLERRM;
END;
$$ LANGUAGE plpgsql;
COMMENT ON FUNCTION qgis_pkg.upd_generic_cityobject_atts(qgis_pkg.obj_cityobject, qgis_pkg.obj_generic_cityobject, varchar) IS 'Update attributes of table GENERIC_CITYOBJECT (and parent ones)';
REVOKE EXECUTE ON FUNCTION qgis_pkg.upd_generic_cityobject_atts(qgis_pkg.obj_cityobject, qgis_pkg.obj_generic_cityobject, varchar) FROM public;

----------------------------------------------------------------
-- Create FUNCTION QGIS_PKG.UPD_LAND_USE_ATTS
----------------------------------------------------------------
DROP FUNCTION IF EXISTS    qgis_pkg.upd_land_use_atts(qgis_pkg.obj_cityobject, qgis_pkg.obj_land_use, varchar) CASCADE;
CREATE OR REPLACE FUNCTION qgis_pkg.upd_land_use_atts(
obj         qgis_pkg.obj_cityobject,
obj_1       qgis_pkg.obj_land_use,
cdb_schema varchar 
)
RETURNS bigint AS $$
DECLARE
  updated_id bigint;
BEGIN

SELECT  qgis_pkg.upd_t_cityobject(obj, cdb_schema) INTO updated_id;
PERFORM qgis_pkg.upd_t_land_use(obj_1, cdb_schema);

RETURN updated_id;
EXCEPTION
  WHEN OTHERS THEN RAISE NOTICE 'qgis_pkg.upd_land_use_atts(id: %): %', obj.id, SQLERRM;
END;
$$ LANGUAGE plpgsql;
COMMENT ON FUNCTION qgis_pkg.upd_land_use_atts(qgis_pkg.obj_cityobject, qgis_pkg.obj_land_use, varchar) IS 'Update attributes of table LAND_USE (and parent ones)';
REVOKE EXECUTE ON FUNCTION qgis_pkg.upd_land_use_atts(qgis_pkg.obj_cityobject, qgis_pkg.obj_land_use, varchar) FROM public;

----------------------------------------------------------------
-- Create FUNCTION QGIS_PKG.UPD_PLANT_COVER_ATTS
----------------------------------------------------------------
DROP FUNCTION IF EXISTS    qgis_pkg.upd_plant_cover_atts(qgis_pkg.obj_cityobject, qgis_pkg.obj_plant_cover, varchar) CASCADE;
CREATE OR REPLACE FUNCTION qgis_pkg.upd_plant_cover_atts(
obj         qgis_pkg.obj_cityobject,
obj_1       qgis_pkg.obj_plant_cover,
cdb_schema varchar 
)
RETURNS bigint AS $$
DECLARE
  updated_id bigint;
BEGIN

SELECT  qgis_pkg.upd_t_cityobject(obj, cdb_schema) INTO updated_id;
PERFORM qgis_pkg.upd_t_plant_cover(obj_1, cdb_schema);

RETURN updated_id;
EXCEPTION
  WHEN OTHERS THEN RAISE NOTICE 'qgis_pkg.upd_plant_cover_atts(id: %): %', obj.id, SQLERRM;
END;
$$ LANGUAGE plpgsql;
COMMENT ON FUNCTION qgis_pkg.upd_plant_cover_atts(qgis_pkg.obj_cityobject, qgis_pkg.obj_plant_cover, varchar) IS 'Update attributes of table PLANT_COVER (and parent ones)';
REVOKE EXECUTE ON FUNCTION qgis_pkg.upd_plant_cover_atts(qgis_pkg.obj_cityobject, qgis_pkg.obj_plant_cover, varchar) FROM public;

----------------------------------------------------------------
-- Create FUNCTION QGIS_PKG.UPD_RELIEF_FEATURE_ATTS
----------------------------------------------------------------
DROP FUNCTION IF EXISTS    qgis_pkg.upd_relief_feature_atts(qgis_pkg.obj_cityobject, qgis_pkg.obj_relief_feature, varchar) CASCADE;
CREATE OR REPLACE FUNCTION qgis_pkg.upd_relief_feature_atts(
obj         qgis_pkg.obj_cityobject,
obj_1       qgis_pkg.obj_relief_feature,
cdb_schema varchar 
)
RETURNS bigint AS $$
DECLARE
  updated_id bigint;
BEGIN

SELECT  qgis_pkg.upd_t_cityobject(obj, cdb_schema) INTO updated_id;
PERFORM qgis_pkg.upd_t_relief_feature(obj_1, cdb_schema);

RETURN updated_id;
EXCEPTION
  WHEN OTHERS THEN RAISE NOTICE 'qgis_pkg.upd_relief_feature_atts(id: %): %', obj.id, SQLERRM;
END;
$$ LANGUAGE plpgsql;
COMMENT ON FUNCTION qgis_pkg.upd_relief_feature_atts(qgis_pkg.obj_cityobject, qgis_pkg.obj_relief_feature, varchar) IS 'Update attributes of table RELIEF_FEATURE (and parent ones)';
REVOKE EXECUTE ON FUNCTION qgis_pkg.upd_relief_feature_atts(qgis_pkg.obj_cityobject, qgis_pkg.obj_relief_feature, varchar) FROM public;

----------------------------------------------------------------
-- Create FUNCTION QGIS_PKG.UPD_ROOM_ATTS
----------------------------------------------------------------
DROP FUNCTION IF EXISTS    qgis_pkg.upd_room_atts(qgis_pkg.obj_cityobject, qgis_pkg.obj_room, varchar) CASCADE;
CREATE OR REPLACE FUNCTION qgis_pkg.upd_room_atts(
obj         qgis_pkg.obj_cityobject,
obj_1       qgis_pkg.obj_room,
cdb_schema varchar 
)
RETURNS bigint AS $$
DECLARE
  updated_id bigint;
BEGIN

SELECT  qgis_pkg.upd_t_cityobject(obj, cdb_schema) INTO updated_id;
PERFORM qgis_pkg.upd_t_room(obj_1, cdb_schema);

RETURN updated_id;
EXCEPTION
  WHEN OTHERS THEN RAISE NOTICE 'qgis_pkg.upd_room_atts(id: %): %', obj.id, SQLERRM;
END;
$$ LANGUAGE plpgsql;
COMMENT ON FUNCTION qgis_pkg.upd_room_atts(qgis_pkg.obj_cityobject, qgis_pkg.obj_room, varchar) IS 'Update attributes of table ROOM (and parent ones)';
REVOKE EXECUTE ON FUNCTION qgis_pkg.upd_room_atts(qgis_pkg.obj_cityobject, qgis_pkg.obj_room, varchar) FROM public;

----------------------------------------------------------------
-- Create FUNCTION QGIS_PKG.UPD_SOLITARY_VEGETAT_OBJECT_ATTS
----------------------------------------------------------------
DROP FUNCTION IF EXISTS    qgis_pkg.upd_solitary_vegetat_object_atts(qgis_pkg.obj_cityobject, qgis_pkg.obj_solitary_vegetat_object, varchar) CASCADE;
CREATE OR REPLACE FUNCTION qgis_pkg.upd_solitary_vegetat_object_atts(
obj         qgis_pkg.obj_cityobject,
obj_1       qgis_pkg.obj_solitary_vegetat_object,
cdb_schema varchar 
)
RETURNS bigint AS $$
DECLARE
  updated_id bigint;
BEGIN

SELECT  qgis_pkg.upd_t_cityobject(obj, cdb_schema) INTO updated_id;
PERFORM qgis_pkg.upd_t_solitary_vegetat_object(obj_1, cdb_schema);

RETURN updated_id;
EXCEPTION
  WHEN OTHERS THEN RAISE NOTICE 'qgis_pkg.upd_solitary_vegetat_object_atts(id: %): %', obj.id, SQLERRM;
END;
$$ LANGUAGE plpgsql;
COMMENT ON FUNCTION qgis_pkg.upd_solitary_vegetat_object_atts(qgis_pkg.obj_cityobject, qgis_pkg.obj_solitary_vegetat_object, varchar) IS 'Update attributes of table SOLITARY_VEGETAT_OBJECT (and parent ones)';
REVOKE EXECUTE ON FUNCTION qgis_pkg.upd_solitary_vegetat_object_atts(qgis_pkg.obj_cityobject, qgis_pkg.obj_solitary_vegetat_object, varchar) FROM public;

----------------------------------------------------------------
-- Create FUNCTION QGIS_PKG.UPD_TRAFFIC_AREA_ATTS
----------------------------------------------------------------
DROP FUNCTION IF EXISTS    qgis_pkg.upd_traffic_area_atts(qgis_pkg.obj_cityobject, qgis_pkg.obj_traffic_area, varchar) CASCADE;
CREATE OR REPLACE FUNCTION qgis_pkg.upd_traffic_area_atts(
obj         qgis_pkg.obj_cityobject,
obj_1       qgis_pkg.obj_traffic_area,
cdb_schema varchar 
)
RETURNS bigint AS $$
DECLARE
  updated_id bigint;
BEGIN

SELECT  qgis_pkg.upd_t_cityobject(obj, cdb_schema) INTO updated_id;
PERFORM qgis_pkg.upd_t_traffic_area(obj_1, cdb_schema);

RETURN updated_id;
EXCEPTION
  WHEN OTHERS THEN RAISE NOTICE 'qgis_pkg.upd_traffic_area_atts(id: %): %', obj.id, SQLERRM;
END;
$$ LANGUAGE plpgsql;
COMMENT ON FUNCTION qgis_pkg.upd_traffic_area_atts(qgis_pkg.obj_cityobject, qgis_pkg.obj_traffic_area, varchar) IS 'Update attributes of table TRAFFIC_AREA (and parent ones)';
REVOKE EXECUTE ON FUNCTION qgis_pkg.upd_traffic_area_atts(qgis_pkg.obj_cityobject, qgis_pkg.obj_traffic_area, varchar) FROM public;

----------------------------------------------------------------
-- Create FUNCTION QGIS_PKG.UPD_TRANSPORTATION_COMPLEX_ATTS
----------------------------------------------------------------
DROP FUNCTION IF EXISTS    qgis_pkg.upd_transportation_complex_atts(qgis_pkg.obj_cityobject, qgis_pkg.obj_transportation_complex, varchar) CASCADE;
CREATE OR REPLACE FUNCTION qgis_pkg.upd_transportation_complex_atts(
obj         qgis_pkg.obj_cityobject,
obj_1       qgis_pkg.obj_transportation_complex,
cdb_schema varchar 
)
RETURNS bigint AS $$
DECLARE
  updated_id bigint;
BEGIN

SELECT  qgis_pkg.upd_t_cityobject(obj, cdb_schema) INTO updated_id;
PERFORM qgis_pkg.upd_t_transportation_complex(obj_1, cdb_schema);

RETURN updated_id;
EXCEPTION
  WHEN OTHERS THEN RAISE NOTICE 'qgis_pkg.upd_transportation_complex_atts(id: %): %', obj.id, SQLERRM;
END;
$$ LANGUAGE plpgsql;
COMMENT ON FUNCTION qgis_pkg.upd_transportation_complex_atts(qgis_pkg.obj_cityobject, qgis_pkg.obj_transportation_complex, varchar) IS 'Update attributes of table TRANSPORTATION_COMPLEX (and parent ones)';
REVOKE EXECUTE ON FUNCTION qgis_pkg.upd_transportation_complex_atts(qgis_pkg.obj_cityobject, qgis_pkg.obj_transportation_complex, varchar) FROM public;

----------------------------------------------------------------
-- Create FUNCTION QGIS_PKG.UPD_TUNNEL_ATTS
----------------------------------------------------------------
DROP FUNCTION IF EXISTS    qgis_pkg.upd_tunnel_atts(qgis_pkg.obj_cityobject, qgis_pkg.obj_tunnel, varchar) CASCADE;
CREATE OR REPLACE FUNCTION qgis_pkg.upd_tunnel_atts(
obj         qgis_pkg.obj_cityobject,
obj_1       qgis_pkg.obj_tunnel,
cdb_schema varchar 
)
RETURNS bigint AS $$
DECLARE
  updated_id bigint;
BEGIN

SELECT  qgis_pkg.upd_t_cityobject(obj, cdb_schema) INTO updated_id;
PERFORM qgis_pkg.upd_t_tunnel(obj_1, cdb_schema);

RETURN updated_id;
EXCEPTION
  WHEN OTHERS THEN RAISE NOTICE 'qgis_pkg.upd_tunnel_atts(id: %): %', obj.id, SQLERRM;
END;
$$ LANGUAGE plpgsql;
COMMENT ON FUNCTION qgis_pkg.upd_tunnel_atts(qgis_pkg.obj_cityobject, qgis_pkg.obj_tunnel, varchar) IS 'Update attributes of table TUNNEL (and parent ones)';
REVOKE EXECUTE ON FUNCTION qgis_pkg.upd_tunnel_atts(qgis_pkg.obj_cityobject, qgis_pkg.obj_tunnel, varchar) FROM public;

----------------------------------------------------------------
-- Create FUNCTION QGIS_PKG.UPD_TUNNEL_FURNITURE_ATTS
----------------------------------------------------------------
DROP FUNCTION IF EXISTS    qgis_pkg.upd_tunnel_furniture_atts(qgis_pkg.obj_cityobject, qgis_pkg.obj_tunnel_furniture, varchar) CASCADE;
CREATE OR REPLACE FUNCTION qgis_pkg.upd_tunnel_furniture_atts(
obj         qgis_pkg.obj_cityobject,
obj_1       qgis_pkg.obj_tunnel_furniture,
cdb_schema varchar 
)
RETURNS bigint AS $$
DECLARE
  updated_id bigint;
BEGIN

SELECT  qgis_pkg.upd_t_cityobject(obj, cdb_schema) INTO updated_id;
PERFORM qgis_pkg.upd_t_tunnel_furniture(obj_1, cdb_schema);

RETURN updated_id;
EXCEPTION
  WHEN OTHERS THEN RAISE NOTICE 'qgis_pkg.upd_tunnel_furniture_atts(id: %): %', obj.id, SQLERRM;
END;
$$ LANGUAGE plpgsql;
COMMENT ON FUNCTION qgis_pkg.upd_tunnel_furniture_atts(qgis_pkg.obj_cityobject, qgis_pkg.obj_tunnel_furniture, varchar) IS 'Update attributes of table TUNNEL_FURNITURE (and parent ones)';
REVOKE EXECUTE ON FUNCTION qgis_pkg.upd_tunnel_furniture_atts(qgis_pkg.obj_cityobject, qgis_pkg.obj_tunnel_furniture, varchar) FROM public;

----------------------------------------------------------------
-- Create FUNCTION QGIS_PKG.UPD_TUNNEL_HOLLOW_SPACE_ATTS
----------------------------------------------------------------
DROP FUNCTION IF EXISTS    qgis_pkg.upd_tunnel_hollow_space_atts(qgis_pkg.obj_cityobject, qgis_pkg.obj_tunnel_hollow_space, varchar) CASCADE;
CREATE OR REPLACE FUNCTION qgis_pkg.upd_tunnel_hollow_space_atts(
obj         qgis_pkg.obj_cityobject,
obj_1       qgis_pkg.obj_tunnel_hollow_space,
cdb_schema varchar 
)
RETURNS bigint AS $$
DECLARE
  updated_id bigint;
BEGIN

SELECT  qgis_pkg.upd_t_cityobject(obj, cdb_schema) INTO updated_id;
PERFORM qgis_pkg.upd_t_tunnel_hollow_space(obj_1, cdb_schema);

RETURN updated_id;
EXCEPTION
  WHEN OTHERS THEN RAISE NOTICE 'qgis_pkg.upd_tunnel_hollow_space_atts(id: %): %', obj.id, SQLERRM;
END;
$$ LANGUAGE plpgsql;
COMMENT ON FUNCTION qgis_pkg.upd_tunnel_hollow_space_atts(qgis_pkg.obj_cityobject, qgis_pkg.obj_tunnel_hollow_space, varchar) IS 'Update attributes of table TUNNEL_HOLLOW_SPACE (and parent ones)';
REVOKE EXECUTE ON FUNCTION qgis_pkg.upd_tunnel_hollow_space_atts(qgis_pkg.obj_cityobject, qgis_pkg.obj_tunnel_hollow_space, varchar) FROM public;

----------------------------------------------------------------
-- Create FUNCTION QGIS_PKG.UPD_TUNNEL_INSTALLATION_ATTS
----------------------------------------------------------------
DROP FUNCTION IF EXISTS    qgis_pkg.upd_tunnel_installation_atts(qgis_pkg.obj_cityobject, qgis_pkg.obj_tunnel_installation, varchar) CASCADE;
CREATE OR REPLACE FUNCTION qgis_pkg.upd_tunnel_installation_atts(
obj         qgis_pkg.obj_cityobject,
obj_1       qgis_pkg.obj_tunnel_installation,
cdb_schema varchar 
)
RETURNS bigint AS $$
DECLARE
  updated_id bigint;
BEGIN

SELECT  qgis_pkg.upd_t_cityobject(obj, cdb_schema) INTO updated_id;
PERFORM qgis_pkg.upd_t_tunnel_installation(obj_1, cdb_schema);

RETURN updated_id;
EXCEPTION
  WHEN OTHERS THEN RAISE NOTICE 'qgis_pkg.upd_tunnel_installation_atts(id: %): %', obj.id, SQLERRM;
END;
$$ LANGUAGE plpgsql;
COMMENT ON FUNCTION qgis_pkg.upd_tunnel_installation_atts(qgis_pkg.obj_cityobject, qgis_pkg.obj_tunnel_installation, varchar) IS 'Update attributes of table TUNNEL_INSTALLATION (and parent ones)';
REVOKE EXECUTE ON FUNCTION qgis_pkg.upd_tunnel_installation_atts(qgis_pkg.obj_cityobject, qgis_pkg.obj_tunnel_installation, varchar) FROM public;

----------------------------------------------------------------
-- Create FUNCTION QGIS_PKG.UPD_WATERBODY_ATTS
----------------------------------------------------------------
DROP FUNCTION IF EXISTS    qgis_pkg.upd_waterbody_atts(qgis_pkg.obj_cityobject, qgis_pkg.obj_waterbody, varchar) CASCADE;
CREATE OR REPLACE FUNCTION qgis_pkg.upd_waterbody_atts(
obj         qgis_pkg.obj_cityobject,
obj_1       qgis_pkg.obj_waterbody,
cdb_schema varchar 
)
RETURNS bigint AS $$
DECLARE
  updated_id bigint;
BEGIN

SELECT  qgis_pkg.upd_t_cityobject(obj, cdb_schema) INTO updated_id;
PERFORM qgis_pkg.upd_t_waterbody(obj_1, cdb_schema);

RETURN updated_id;
EXCEPTION
  WHEN OTHERS THEN RAISE NOTICE 'qgis_pkg.upd_waterbody_atts(id: %): %', obj.id, SQLERRM;
END;
$$ LANGUAGE plpgsql;
COMMENT ON FUNCTION qgis_pkg.upd_waterbody_atts(qgis_pkg.obj_cityobject, qgis_pkg.obj_waterbody, varchar) IS 'Update attributes of table WATERBODY (and parent ones)';
REVOKE EXECUTE ON FUNCTION qgis_pkg.upd_waterbody_atts(qgis_pkg.obj_cityobject, qgis_pkg.obj_waterbody, varchar) FROM public;

----------------------------------------------------------------
-- Create FUNCTION QGIS_PKG.UPD_TIN_RELIEF_ATTS
----------------------------------------------------------------
DROP FUNCTION IF EXISTS    qgis_pkg.upd_tin_relief_atts(qgis_pkg.obj_cityobject, qgis_pkg.obj_relief_component, qgis_pkg.obj_tin_relief, varchar) CASCADE;
CREATE OR REPLACE FUNCTION qgis_pkg.upd_tin_relief_atts(
obj      qgis_pkg.obj_cityobject,
obj_1    qgis_pkg.obj_relief_component,
obj_2    qgis_pkg.obj_tin_relief,
cdb_schema varchar
)
RETURNS bigint AS $$
DECLARE
  updated_id bigint;
BEGIN

SELECT  qgis_pkg.upd_t_cityobject(obj, cdb_schema) INTO updated_id;
PERFORM qgis_pkg.upd_t_relief_component(obj_1, cdb_schema);
PERFORM qgis_pkg.upd_t_tin_relief(obj_2, cdb_schema);

RETURN updated_id;
EXCEPTION
  WHEN OTHERS THEN RAISE NOTICE 'qgis_pkg.upd_tin_relief_atts(id: %): %', obj.id, SQLERRM;
END;
$$ LANGUAGE plpgsql;
COMMENT ON FUNCTION qgis_pkg.upd_tin_relief_atts(qgis_pkg.obj_cityobject, qgis_pkg.obj_relief_component, qgis_pkg.obj_tin_relief, varchar) IS 'Update attributes of table TIN_RELIEF (and parent ones)';
REVOKE EXECUTE ON FUNCTION qgis_pkg.upd_tin_relief_atts(qgis_pkg.obj_cityobject, qgis_pkg.obj_relief_component, qgis_pkg.obj_tin_relief, varchar) FROM public;

----------------------------------------------------------------
-- Create FUNCTION QGIS_PKG.UPD_BREAKLINE_RELIEF_ATTS
----------------------------------------------------------------
DROP FUNCTION IF EXISTS    qgis_pkg.upd_breakline_relief_atts(qgis_pkg.obj_cityobject, qgis_pkg.obj_relief_component, varchar) CASCADE;
CREATE OR REPLACE FUNCTION qgis_pkg.upd_breakline_relief_atts(
obj      qgis_pkg.obj_cityobject,
obj_1    qgis_pkg.obj_relief_component,
cdb_schema varchar
)
RETURNS bigint AS $$
DECLARE
  updated_id bigint;
BEGIN

SELECT  qgis_pkg.upd_t_cityobject(obj, cdb_schema) INTO updated_id;
PERFORM qgis_pkg.upd_t_relief_component(obj_1, cdb_schema);

RETURN updated_id;
EXCEPTION
  WHEN OTHERS THEN RAISE NOTICE 'qgis_pkg.upd_breakline_relief_atts(id: %): %', obj.id, SQLERRM;
END;
$$ LANGUAGE plpgsql;
COMMENT ON FUNCTION qgis_pkg.upd_breakline_relief_atts(qgis_pkg.obj_cityobject, qgis_pkg.obj_relief_component, varchar) IS 'Update attributes of table BREAKLINE_RELIEF (and parent ones)';
REVOKE EXECUTE ON FUNCTION qgis_pkg.upd_breakline_relief_atts(qgis_pkg.obj_cityobject, qgis_pkg.obj_relief_component, varchar) FROM public;

----------------------------------------------------------------
-- Create FUNCTION QGIS_PKG.UPD_MASSPOINT_RELIEF_ATTS
----------------------------------------------------------------
DROP FUNCTION IF EXISTS    qgis_pkg.upd_masspoint_relief_atts(qgis_pkg.obj_cityobject, qgis_pkg.obj_relief_component, varchar) CASCADE;
CREATE OR REPLACE FUNCTION qgis_pkg.upd_masspoint_relief_atts(
obj      qgis_pkg.obj_cityobject,
obj_1    qgis_pkg.obj_relief_component,
cdb_schema varchar
)
RETURNS bigint AS $$
DECLARE
  updated_id bigint;
BEGIN

SELECT  qgis_pkg.upd_t_cityobject(obj, cdb_schema) INTO updated_id;
PERFORM qgis_pkg.upd_t_relief_component(obj_1, cdb_schema);

RETURN updated_id;
EXCEPTION
  WHEN OTHERS THEN RAISE NOTICE 'qgis_pkg.upd_masspoint_relief_atts(id: %): %', obj.id, SQLERRM;
END;
$$ LANGUAGE plpgsql;
COMMENT ON FUNCTION qgis_pkg.upd_masspoint_relief_atts(qgis_pkg.obj_cityobject, qgis_pkg.obj_relief_component, varchar) IS 'Update attributes of table MASSPOINT_RELIEF (and parent ones)';
REVOKE EXECUTE ON FUNCTION qgis_pkg.upd_masspoint_relief_atts(qgis_pkg.obj_cityobject, qgis_pkg.obj_relief_component, varchar) FROM public;

----------------------------------------------------------------
-- Create FUNCTION QGIS_PKG.UPD_WATERBOUNDARY_SURFACE_WATERBODY_ATTS
----------------------------------------------------------------
DROP FUNCTION IF EXISTS    qgis_pkg.upd_waterboundary_surface_waterbody_atts(qgis_pkg.obj_cityobject, qgis_pkg.obj_waterboundary_surface, varchar) CASCADE;
CREATE OR REPLACE FUNCTION qgis_pkg.upd_waterboundary_surface_waterbody_atts(
obj      qgis_pkg.obj_cityobject,
obj_1    qgis_pkg.obj_waterboundary_surface,
cdb_schema varchar
)
RETURNS bigint AS $$
DECLARE
  updated_id bigint;
BEGIN

SELECT  qgis_pkg.upd_t_cityobject(obj, cdb_schema) INTO updated_id;
PERFORM qgis_pkg.upd_t_waterboundary_surface(obj_1, cdb_schema);

RETURN updated_id;
EXCEPTION
  WHEN OTHERS THEN RAISE NOTICE 'qgis_pkg.upd_waterboundary_surface_waterbody_atts(id: %): %', obj.id, SQLERRM;
END;
$$ LANGUAGE plpgsql;
COMMENT ON FUNCTION qgis_pkg.upd_waterboundary_surface_waterbody_atts(qgis_pkg.obj_cityobject, qgis_pkg.obj_waterboundary_surface, varchar) IS 'Update attributes of table WATERBOUNDARY_SURFACE (for class WaterBody) (and parent ones)';
REVOKE EXECUTE ON FUNCTION qgis_pkg.upd_waterboundary_surface_waterbody_atts(qgis_pkg.obj_cityobject, qgis_pkg.obj_waterboundary_surface, varchar) FROM public;

--**************************
DO $MAINBODY$
BEGIN
RAISE NOTICE E'\n\nDone\n\n';
END $MAINBODY$;
--**************************

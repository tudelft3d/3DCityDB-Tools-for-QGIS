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
-- This script carries out the last operation before completing the 
-- installation of the CityGML QGIS package for PostgreSQL. 
--
-- ***********************************************************************

-- Make functions in schema qgis_pkg non available to everybody
--REVOKE EXECUTE ON ALL FUNCTIONS IN SCHEMA qgis_pkg FROM public;

-- Add user group and template table(s)
DO $MAINBODY$
DECLARE
BEGIN

IF NOT EXISTS(SELECT 1 FROM information_schema.enabled_roles AS i WHERE i.role_name::varchar = 'qgis_user_ro') THEN
	-- Add/create a default 3DCityDB read-only user
	CREATE ROLE qgis_user_ro WITH
		LOGIN
		NOSUPERUSER
		NOCREATEDB
		NOCREATEROLE
		INHERIT
		NOREPLICATION
		CONNECTION LIMIT -1
		PASSWORD 'qgis_user_ro';
	GRANT qgis_pkg_usrgroup TO qgis_user_ro;
	COMMENT ON ROLE qgis_user_ro IS 'QGIS-Package user with read-only privileges for the 3DCityDB';
END IF;

IF NOT EXISTS(SELECT 1 FROM information_schema.enabled_roles AS i WHERE i.role_name::varchar = 'qgis_user_rw') THEN
	-- Add/create a default 3DCityDB read & write user
	CREATE ROLE qgis_user_rw WITH
		LOGIN
		NOSUPERUSER
		NOCREATEDB
		NOCREATEROLE
		INHERIT
		NOREPLICATION
		CONNECTION LIMIT -1
		PASSWORD 'qgis_user_rw';
	GRANT qgis_pkg_usrgroup TO qgis_user_rw;
	COMMENT ON ROLE qgis_user_rw IS 'QGIS-Package user with read/write privileges for the 3DCityDB';
END IF;

END $MAINBODY$;

-- Assign respective ro/rw priviles to the user regarding all existing citydb schemas
SELECT qgis_pkg.grant_qgis_usr_privileges('qgis_user_ro', 'ro');
SELECT qgis_pkg.grant_qgis_usr_privileges('qgis_user_rw', 'rw');

-- Create default schemas for user qgis_user_ro and qgis_user_rw
SELECT qgis_pkg.create_qgis_usr_schema('qgis_user_ro');
SELECT qgis_pkg.create_qgis_usr_schema('qgis_user_rw');

--**************************
DO $MAINBODY$
DECLARE
BEGIN
RAISE NOTICE E'\n\nDone\n\n';
END $MAINBODY$;
--**************************
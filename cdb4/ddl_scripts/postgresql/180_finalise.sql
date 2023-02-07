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
-- This script carries out the last operation before completing the 
-- installation of the CityGML QGIS package for PostgreSQL. 
--
-- ***********************************************************************

-- Assign respective ro/rw priviles to the user regarding ALL existing citydb schemas (NULL parameter)
-- Upon the first cdb_schema, it is also assigned to the "qgis_pkg_usrgroup_*" associated to the current database.
-- SELECT qgis_pkg.grant_qgis_usr_privileges('qgis_user_ro', 'ro', NULL);
-- SELECT qgis_pkg.grant_qgis_usr_privileges('qgis_user_rw', 'rw', NULL);

-- Create default schemas for user qgis_user_ro and qgis_user_rw
-- SELECT qgis_pkg.create_qgis_usr_schema('qgis_user_ro');
-- SELECT qgis_pkg.create_qgis_usr_schema('qgis_user_rw');

--**************************
DO $MAINBODY$
DECLARE
BEGIN
RAISE NOTICE E'\n\nDone\n\n';
END $MAINBODY$;
--**************************
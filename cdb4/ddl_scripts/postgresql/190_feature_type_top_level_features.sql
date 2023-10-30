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
-- This script adds values to the feature_type_to_toplevel_feature table.
--
-- ***********************************************************************

--TRUNCATE    qgis_pkg.feature_type_to_toplevel_feature RESTART IDENTITY CASCADE;
INSERT INTO qgis_pkg.feature_type_to_toplevel_feature (ade_prefix, is_supported, feature_type, toplevel_feature) VALUES
---- Standard CityGML modules (Feature Types) and top-level features (CityObjects)
(NULL, TRUE ,'Bridge'         , 'Bridge'),
(NULL, TRUE ,'Building'       , 'Building'),
(NULL, TRUE ,'CityFurniture'  , 'CityFurniture'),
(NULL, TRUE ,'CityObjectGroup', 'CityObjectGroup'),
(NULL, TRUE ,'Generics'       , 'GenericCityObject'),
(NULL, TRUE ,'LandUse'        , 'LandUse'),
(NULL, TRUE ,'Relief'         , 'ReliefFeature'),
(NULL, TRUE ,'Relief'         , 'TINRelief'),
(NULL, TRUE ,'Relief'         , 'BreaklineRelief'),
(NULL, TRUE ,'Relief'         , 'MassPointRelief'),
(NULL, FALSE,'Relief'         , 'RasterRelief'),
(NULL, TRUE ,'Transportation' , 'TransportationComplex'),
(NULL, TRUE ,'Transportation' , 'Track'),
(NULL, TRUE ,'Transportation' , 'Railway'),
(NULL, TRUE ,'Transportation' , 'Road'),
(NULL, TRUE ,'Transportation' , 'Square'),
(NULL, TRUE ,'Tunnel'         , 'Tunnel'),
(NULL, TRUE ,'Vegetation'     , 'SolitaryVegetationObject'),
(NULL, TRUE ,'Vegetation'     , 'PlantCover'),
(NULL, TRUE ,'WaterBody'      , 'WaterBody')
;


--**************************
DO $$
BEGIN
RAISE NOTICE E'\n\nDone\n\n';
END $$;
--**************************
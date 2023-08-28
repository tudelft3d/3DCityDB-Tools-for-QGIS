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
-- This script adds configuration values to set up look-up tables for
-- enumerations in the QGIS attribute forms.
--
-- ***********************************************************************

--TRUNCATE TABLE qgis_pkg.enum_lookup_config RESTART IDENTITY CASCADE;
INSERT INTO qgis_pkg.enum_lookup_config
(ade_prefix, source_class, source_table, source_column, filter_expression)
VALUES
(NULL, 'CityObject', 'cityobject', 'relative_to_terrain', 'data_model = ''CityGML 2.0'' AND name = ''RelativeToTerrainType'''),
(NULL, 'CityObject', 'cityobject', 'relative_to_water'  , 'data_model = ''CityGML 2.0'' AND name = ''RelativeToWaterType''');

----------------------------------------------------------------------------------------------------------------
-- Additional entries must be added in this order:
--
--(ade_prefix, source_class, source_table, source_column, filter_expression)
--
-- And stand for:
-- ADE_PREFIX: If an enumeration is contained in an ADE, then this field contains the ade_prefix associated in the citydb to this ADE.
-- SOURCE_CLASS: The CityGML/ADE class the CodeList will be associated to
-- SOURCE_TABLE: The corresponding citydb table which contains the column to be associated to a codelist
-- SOURCE_COLUMN: The column to be associated to a codelist
--
-- The following values are needed to set up the "ValueReleatin" widget used in teh QGIS attribute forms.
-- FILTER_EXPRESSION: Expression to filter the values of the desired codelist. Basically, it refers to two columns of view v_codelist.
----------------------------------------------------------------------------------------------------------------







--**************************
DO $$
BEGIN
RAISE NOTICE E'\n\nDone\n\n';
END $$;
--**************************
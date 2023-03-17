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
-- codelists in QGIS attribute forms.
--
-- ***********************************************************************

TRUNCATE TABLE qgis_pkg.codelist_lookup_config_template CASCADE;
INSERT INTO qgis_pkg.codelist_lookup_config_template
(name, ade_prefix, source_class, source_table, source_column, target_table, key_column, value_column, allow_multi, num_columns, filter_expression)
VALUES
---------------------------
-- CityGML 2.0 codelists as per specifications
---------------------------
-- Bridge
('CityGML 2.0', NULL, 'Bridge'      , 'bridge', 'class'     , 'v_codelist', 'value', 'description', FALSE, 1, 'data_model = ''CityGML 2.0'' AND name = ''_AbstractBridgeClass'''),
('CityGML 2.0', NULL, 'Bridge'      , 'bridge', 'function'  , 'v_codelist', 'value', 'description', TRUE , 3, 'data_model = ''CityGML 2.0'' AND name = ''_AbstractBridgeFunctionUsage'''),
('CityGML 2.0', NULL, 'Bridge'      , 'bridge', 'usage'     , 'v_codelist', 'value', 'description', TRUE , 3, 'data_model = ''CityGML 2.0'' AND name = ''_AbstractBridgeFunctionUsage'''),
-- BridgePart
('CityGML 2.0', NULL, 'BridgePart'  , 'bridge', 'class'     , 'v_codelist', 'value', 'description', FALSE, 1, 'data_model = ''CityGML 2.0'' AND name = ''_AbstractBridgeClass'''),
('CityGML 2.0', NULL, 'BridgePart'  , 'bridge', 'function'  , 'v_codelist', 'value', 'description', TRUE , 3, 'data_model = ''CityGML 2.0'' AND name = ''_AbstractBridgeFunctionUsage'''),
('CityGML 2.0', NULL, 'BridgePart'  , 'bridge', 'usage'     , 'v_codelist', 'value', 'description', TRUE , 3, 'data_model = ''CityGML 2.0'' AND name = ''_AbstractBridgeFunctionUsage'''),
-- Building
('CityGML 2.0', NULL, 'Building'    , 'building', 'class'     , 'v_codelist', 'value', 'description', FALSE, 1, 'data_model = ''CityGML 2.0'' AND name = ''_AbstractBuildingClass'''),
('CityGML 2.0', NULL, 'Building'    , 'building', 'function'  , 'v_codelist', 'value', 'description', TRUE , 3, 'data_model = ''CityGML 2.0'' AND name = ''_AbstractBuildingFunctionUsage'''),
('CityGML 2.0', NULL, 'Building'    , 'building', 'usage'     , 'v_codelist', 'value', 'description', TRUE , 3, 'data_model = ''CityGML 2.0'' AND name = ''_AbstractBuildingFunctionUsage'''),
('CityGML 2.0', NULL, 'Building'    , 'building', 'roof_type' , 'v_codelist', 'value', 'description', FALSE, 1, 'data_model = ''CityGML 2.0'' AND name = ''_AbstractBuildingRoofType'''),
-- BuildingPart
('CityGML 2.0', NULL, 'BuildingPart', 'building', 'class'     , 'v_codelist', 'value', 'description', FALSE, 1, 'data_model = ''CityGML 2.0'' AND name = ''_AbstractBuildingClass'''),
('CityGML 2.0', NULL, 'BuildingPart', 'building', 'function'  , 'v_codelist', 'value', 'description', TRUE , 3, 'data_model = ''CityGML 2.0'' AND name = ''_AbstractBuildingFunctionUsage'''),
('CityGML 2.0', NULL, 'BuildingPart', 'building', 'usage'     , 'v_codelist', 'value', 'description', TRUE , 3, 'data_model = ''CityGML 2.0'' AND name = ''_AbstractBuildingFunctionUsage'''),
('CityGML 2.0', NULL, 'BuildingPart', 'building', 'roof_type' , 'v_codelist', 'value', 'description', FALSE, 1, 'data_model = ''CityGML 2.0'' AND name = ''_AbstractBuildingRoofType'''),
-- BuildingRoom
('CityGML 2.0', NULL, 'BuildingRoom', 'room', 'class'     , 'v_codelist', 'value', 'description', FALSE, 1, 'data_model = ''CityGML 2.0'' AND name = ''RoomClass'''),
('CityGML 2.0', NULL, 'BuildingRoom', 'room', 'function'  , 'v_codelist', 'value', 'description', TRUE , 3, 'data_model = ''CityGML 2.0'' AND name = ''RoomFunctionUsage'''),
('CityGML 2.0', NULL, 'BuildingRoom', 'room', 'usage'     , 'v_codelist', 'value', 'description', TRUE , 3, 'data_model = ''CityGML 2.0'' AND name = ''RoomFunctionUsage'''),
-- BuildingFurniture
('CityGML 2.0', NULL, 'BuildingFurniture', 'building_furniture', 'class'     , 'v_codelist', 'value', 'description', FALSE, 1, 'data_model = ''CityGML 2.0'' AND name = ''BuildingFurnitureClass'''),
('CityGML 2.0', NULL, 'BuildingFurniture', 'building_furniture', 'function'  , 'v_codelist', 'value', 'description', TRUE , 3, 'data_model = ''CityGML 2.0'' AND name = ''BuildingFurnitureFunctionUsage'''),
('CityGML 2.0', NULL, 'BuildingFurniture', 'building_furniture', 'usage'     , 'v_codelist', 'value', 'description', TRUE , 3, 'data_model = ''CityGML 2.0'' AND name = ''BuildingFurnitureFunctionUsage'''),
-- BuildingInstallation (outer)
('CityGML 2.0', NULL, 'BuildingInstallation', 'building_installation', 'class'     , 'v_codelist', 'value', 'description', FALSE, 1, 'data_model = ''CityGML 2.0'' AND name = ''BuildingInstallationClass'''),
('CityGML 2.0', NULL, 'BuildingInstallation', 'building_installation', 'function'  , 'v_codelist', 'value', 'description', TRUE , 3, 'data_model = ''CityGML 2.0'' AND name = ''BuildingInstallationFunctionUsage'''),
('CityGML 2.0', NULL, 'BuildingInstallation', 'building_installation', 'usage'     , 'v_codelist', 'value', 'description', TRUE , 3, 'data_model = ''CityGML 2.0'' AND name = ''BuildingInstallationFunctionUsage'''),
-- BuildingInstallation (interior)
('CityGML 2.0', NULL, 'IntBuildingInstallation', 'building_installation', 'class'     , 'v_codelist', 'value', 'description', FALSE, 1, 'data_model = ''CityGML 2.0'' AND name = ''IntBuildingInstallationClass'''),
('CityGML 2.0', NULL, 'IntBuildingInstallation', 'building_installation', 'function'  , 'v_codelist', 'value', 'description', TRUE , 3, 'data_model = ''CityGML 2.0'' AND name = ''IntBuildingInstallationFunctionUsage'''),
('CityGML 2.0', NULL, 'IntBuildingInstallation', 'building_installation', 'usage'     , 'v_codelist', 'value', 'description', TRUE , 3, 'data_model = ''CityGML 2.0'' AND name = ''IntBuildingInstallationFunctionUsage'''),
-- CityFurniture
('CityGML 2.0', NULL, 'CityFurniture', 'city_furniture', 'class'     , 'v_codelist', 'value', 'description', FALSE, 1, 'data_model = ''CityGML 2.0'' AND name = ''CityFurnitureClass'''),
('CityGML 2.0', NULL, 'CityFurniture', 'city_furniture', 'function'  , 'v_codelist', 'value', 'description', TRUE , 3, 'data_model = ''CityGML 2.0'' AND name = ''CityFurnitureFunctionUsage'''),
('CityGML 2.0', NULL, 'CityFurniture', 'city_furniture', 'usage'     , 'v_codelist', 'value', 'description', TRUE , 3, 'data_model = ''CityGML 2.0'' AND name = ''CityFurnitureFunctionUsage'''),
-- CityObjectGroup
('CityGML 2.0', NULL, 'CityObjectGroup', 'cityobjectgroup', 'class'     , 'v_codelist', 'value', 'description', FALSE, 1, 'data_model = ''CityGML 2.0'' AND name = ''CityObjectGroupClass'''),
('CityGML 2.0', NULL, 'CityObjectGroup', 'cityobjectgroup', 'function'  , 'v_codelist', 'value', 'description', TRUE , 3, 'data_model = ''CityGML 2.0'' AND name = ''CityObjectGroupFunctionUsage'''),
('CityGML 2.0', NULL, 'CityObjectGroup', 'cityobjectgroup', 'usage'     , 'v_codelist', 'value', 'description', TRUE , 3, 'data_model = ''CityGML 2.0'' AND name = ''CityObjectGroupFunctionUsage'''),
-- LandUse
('CityGML 2.0', NULL, 'LandUse', 'land_use', 'class'     , 'v_codelist', 'value', 'description', FALSE, 1, 'data_model = ''CityGML 2.0'' AND name = ''LandUseClass'''),
('CityGML 2.0', NULL, 'LandUse', 'land_use', 'function'  , 'v_codelist', 'value', 'description', TRUE , 3, 'data_model = ''CityGML 2.0'' AND name = ''LandUseFunctionUsage'''),
('CityGML 2.0', NULL, 'LandUse', 'land_use', 'usage'     , 'v_codelist', 'value', 'description', TRUE , 3, 'data_model = ''CityGML 2.0'' AND name = ''LandUseFunctionUsage'''),
-- TransportationComplex
('CityGML 2.0', NULL, 'TransportationComplex', 'transportation_complex', 'class'     , 'v_codelist', 'value', 'description', FALSE, 1, 'data_model = ''CityGML 2.0'' AND name = ''TransportationComplexClass'''),
('CityGML 2.0', NULL, 'TransportationComplex', 'transportation_complex', 'function'  , 'v_codelist', 'value', 'description', TRUE , 3, 'data_model = ''CityGML 2.0'' AND name = ''TransportationComplexFunctionUsage'''),
('CityGML 2.0', NULL, 'TransportationComplex', 'transportation_complex', 'usage'     , 'v_codelist', 'value', 'description', TRUE , 3, 'data_model = ''CityGML 2.0'' AND name = ''TransportationComplexFunctionUsage'''),
-- AuxiliaryTrafficArea
--('CityGML 2.0', NULL, 'AuxiliaryTrafficArea', 'traffic_area', 'class'            , 'v_codelist', 'value', 'description', FALSE, 1, 'data_model = ''CityGML 2.0'' AND name = ''AuxiliaryTrafficAreaClass'''),
('CityGML 2.0', NULL, 'AuxiliaryTrafficArea', 'traffic_area', 'function'         , 'v_codelist', 'value', 'description', TRUE , 3, 'data_model = ''CityGML 2.0'' AND name = ''AuxiliaryTrafficAreaFunction'''),
--('CityGML 2.0', NULL, 'AuxiliaryTrafficArea', 'traffic_area', 'usage'            , 'v_codelist', 'value', 'description', TRUE , 3, 'data_model = ''CityGML 2.0'' AND name = ''AuxiliaryTrafficAreaFunctionUsage'''),
('CityGML 2.0', NULL, 'AuxiliaryTrafficArea', 'traffic_area', 'surface_material' , 'v_codelist', 'value', 'description', FALSE, 1, 'data_model = ''CityGML 2.0'' AND name = ''TrafficAreaSurfaceMaterial'''),
-- TrafficArea
--('CityGML 2.0', NULL, 'TrafficArea', 'traffic_area', 'class'     , 'v_codelist', 'value', 'description', FALSE, 1, 'data_model = ''CityGML 2.0'' AND name = ''TrafficAreaClass'''),
('CityGML 2.0', NULL, 'TrafficArea', 'traffic_area', 'function'         , 'v_codelist', 'value', 'description', TRUE , 3, 'data_model = ''CityGML 2.0'' AND name = ''TrafficAreaFunction'''),
('CityGML 2.0', NULL, 'TrafficArea', 'traffic_area', 'usage'            , 'v_codelist', 'value', 'description', TRUE , 3, 'data_model = ''CityGML 2.0'' AND name = ''TrafficAreaUsage'''),
('CityGML 2.0', NULL, 'TrafficArea', 'traffic_area', 'surface_material' , 'v_codelist', 'value', 'description', FALSE, 1, 'data_model = ''CityGML 2.0'' AND name = ''TrafficAreaSurfaceMaterial'''),
-- Tunnel
('CityGML 2.0', NULL, 'Tunnel'      , 'tunnel', 'class'     , 'v_codelist', 'value', 'description', FALSE, 1, 'data_model = ''CityGML 2.0'' AND name = ''_AbstractTunnelClass'''),
('CityGML 2.0', NULL, 'Tunnel'      , 'tunnel', 'function'  , 'v_codelist', 'value', 'description', TRUE , 3, 'data_model = ''CityGML 2.0'' AND name = ''_AbstractTunnelFunctionUsage'''),
('CityGML 2.0', NULL, 'Tunnel'      , 'tunnel', 'usage'     , 'v_codelist', 'value', 'description', TRUE , 3, 'data_model = ''CityGML 2.0'' AND name = ''_AbstractTunnelFunctionUsage'''),
-- TunnelPart
('CityGML 2.0', NULL, 'TunnelPart'  , 'tunnel','class'     , 'v_codelist', 'value', 'description', FALSE, 1, 'data_model = ''CityGML 2.0'' AND name = ''_AbstractTunnelClass'''),
('CityGML 2.0', NULL, 'TunnelPart'  , 'tunnel','function'  , 'v_codelist', 'value', 'description', TRUE , 3, 'data_model = ''CityGML 2.0'' AND name = ''_AbstractTunnelFunctionUsage'''),
('CityGML 2.0', NULL, 'TunnelPart'  , 'tunnel','usage'     , 'v_codelist', 'value', 'description', TRUE , 3, 'data_model = ''CityGML 2.0'' AND name = ''_AbstractTunnelFunctionUsage'''),
-- PlantCover
('CityGML 2.0', NULL, 'PlantCover', 'plant_cover', 'class'     , 'v_codelist', 'value', 'description', FALSE, 1, 'data_model = ''CityGML 2.0'' AND name = ''PlantCoverClassFunctionUsage'''),
('CityGML 2.0', NULL, 'PlantCover', 'plant_cover', 'function'  , 'v_codelist', 'value', 'description', TRUE , 3, 'data_model = ''CityGML 2.0'' AND name = ''PlantCoverClassFunctionUsage'''),
('CityGML 2.0', NULL, 'PlantCover', 'plant_cover', 'usage'     , 'v_codelist', 'value', 'description', TRUE , 3, 'data_model = ''CityGML 2.0'' AND name = ''PlantCoverClassFunctionUsage'''),
-- SolitaryVegetationObject
('CityGML 2.0', NULL, 'SolitaryVegetationObject', 'solitary_vegetat_object', 'class'   , 'v_codelist', 'value', 'description', FALSE, 1, 'data_model = ''CityGML 2.0'' AND name = ''SolitaryVegetationObjectClassFunctionUsage'''),
('CityGML 2.0', NULL, 'SolitaryVegetationObject', 'solitary_vegetat_object', 'function', 'v_codelist', 'value', 'description', TRUE , 3, 'data_model = ''CityGML 2.0'' AND name = ''SolitaryVegetationObjectClassFunctionUsage'''),
('CityGML 2.0', NULL, 'SolitaryVegetationObject', 'solitary_vegetat_object', 'usage'   , 'v_codelist', 'value', 'description', TRUE , 3, 'data_model = ''CityGML 2.0'' AND name = ''SolitaryVegetationObjectClassFunctionUsage'''),
('CityGML 2.0', NULL, 'SolitaryVegetationObject', 'solitary_vegetat_object', 'species' , 'v_codelist', 'value', 'description', FALSE, 1, 'data_model = ''CityGML 2.0'' AND name = ''SolitaryVegetationObjectSpecies'''),
-- WaterBody
('CityGML 2.0', NULL, 'WaterBody', 'waterbody', 'class'     , 'v_codelist', 'value', 'description', FALSE, 1, 'data_model = ''CityGML 2.0'' AND name = ''WaterbodyClass'''),
('CityGML 2.0', NULL, 'WaterBody', 'waterbody', 'function'  , 'v_codelist', 'value', 'description', TRUE , 3, 'data_model = ''CityGML 2.0'' AND name = ''WaterbodyFunction'''),
('CityGML 2.0', NULL, 'WaterBody', 'waterbody', 'usage'     , 'v_codelist', 'value', 'description', TRUE , 3, 'data_model = ''CityGML 2.0'' AND name = ''WaterbodyUsage'''),
-- WaterSurface
('CityGML 2.0', NULL, 'WaterSurface', 'waterboundary_surface', 'water_level', 'v_codelist', 'value', 'description', FALSE, 1, 'data_model = ''CityGML 2.0'' AND name = ''WaterSurfaceWaterLevel'''),

---------------------------
-- TUD 3DGeoInfo Building
---------------------------
-- Building
('TUD-3DGeoinfo', NULL, 'Building'    , 'building', 'class'     , 'v_codelist', 'value', 'description', FALSE, 1, 'data_model = ''TUD-3DGeoinfo'' AND name = ''BAG_gebruiksdoel'''),
--('TUD-3DGeoinfo', NULL, 'Building'    , 'building', 'function'  , 'v_codelist', 'value', 'description', TRUE , 3, 'data_model = ''TUD-3DGeoinfo'' AND name = ''_AbstractBuildingFunctionUsage'''),
--('TUD-3DGeoinfo', NULL, 'Building'    , 'building', 'usage'     , 'v_codelist', 'value', 'description', TRUE , 3, 'data_model = ''TUD-3DGeoinfo'' AND name = ''_AbstractBuildingFunctionUsage'''),
--('TUD-3DGeoinfo', NULL, 'Building'    , 'building', 'roof_type' , 'v_codelist', 'value', 'description', FALSE, 1, 'data_model = ''TUD-3DGeoinfo'' AND name = ''_AbstractBuildingRoofType'''),
-- BuildingPart
('TUD-3DGeoinfo', NULL, 'BuildingPart', 'building', 'class'     , 'v_codelist', 'value', 'description', FALSE, 1, 'data_model = ''TUD-3DGeoinfo'' AND name = ''BAG_gebruiksdoel''')
--('TUD-3DGeoinfo', NULL, 'BuildingPart', 'building', 'function'  , 'v_codelist', 'value', 'description', TRUE , 3, 'data_model = ''TUD-3DGeoinfo'' AND name = ''_AbstractBuildingFunctionUsage'''),
--('TUD-3DGeoinfo', NULL, 'BuildingPart', 'building', 'usage'     , 'v_codelist', 'value', 'description', TRUE , 3, 'data_model = ''TUD-3DGeoinfo'' AND name = ''_AbstractBuildingFunctionUsage'''),
--('TUD-3DGeoinfo', NULL, 'BuildingPart', 'building', 'roof_type' , 'v_codelist', 'value', 'description', FALSE, 1, 'data_model = ''TUD-3DGeoinfo'' AND name = ''_AbstractBuildingRoofType'''),

----------------------------------------------------------------------------------------------------------------

-- Additional entries must be added in this order:
--
--(name, source_class, source_table, source_column, target_table, key_column, value_column, allow_multi, num_columns, filter_expression)
--
-- And stand for:
-- NAME: The name indicating the set of mapping rules. It must be the same for all rules belonging to the same group. This label will be the selectable one in the QGIS GUI.
-- SOURCE_CLASS: The CityGML/ADE class the CodeList will be associated to
-- SOURCE_TABLE: The corresponding citydb table which contains the column to be associated to a codelist
-- SOURCE_COLUMN: The column to be associated to a codelist
--
-- The following values are needed to set up the "ValueReleatin" widget used in teh QGIS attribute forms.
--
-- TARGET_TABLE: The view containing all codelists values. Fixed value ('v_codelist').
-- KEY_COLUMN: fixed value ('value'), from view v_codelist
-- VALUE_COLUMN: fixed value ('description'), from view v_codelist
-- ALLOW_MULTI: FALSE if the cardinality is 0..1, TRUE if it is 0..*
-- NUM_COLUMNS: Number of column presented in the widget anc containing look-up values. Default: 1 when ALLOW_MULTI is FALSE, 3 WHEN ALLOW_MULTI is TRUE.
-- FILTER_EXPRESSION: Expression to filter the values of the desired codelist. Basically, it refers to two columns of view v_codelist.

---------------------------
-- Add here your codelist to table/column mapping to enable automatic set up of combo boxes in the QGIS attribute forms
---------------------------


;
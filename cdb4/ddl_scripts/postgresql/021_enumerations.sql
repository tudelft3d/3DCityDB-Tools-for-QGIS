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
-- This script contains the enumeration values of the CityGML 2.0 standard
--
-- ***********************************************************************

--TRUNCATE    qgis_pkg.enumeration RESTART IDENTITY CASCADE;
INSERT INTO qgis_pkg.enumeration_template (data_model, name, name_space)
VALUES
('CityGML 2.0','RelativeToTerrainType','http://schemas.opengis.net/citygml/2.0/cityGMLBase.xsd'),
('CityGML 2.0','RelativeToWaterType'  ,'http://schemas.opengis.net/citygml/2.0/cityGMLBase.xsd'),
('CityGML 2.0','TextureTypeType'      ,'http://schemas.opengis.net/citygml/appearance/2.0/appearance.xsd'),
('CityGML 2.0','WrapModeTypeType'     ,'http://schemas.opengis.net/citygml/appearance/2.0/appearance.xsd')
;

-- ****************************************************************************
-- ****************************************************************************

--TRUNCATE    qgis_pkg.enumeration_value RESTART IDENTITY CASCADE;
WITH em AS (SELECT id FROM qgis_pkg.enumeration_template	WHERE
	data_model = 'CityGML 2.0'
	AND
	name = 'RelativeToTerrainType'
) INSERT INTO qgis_pkg.enumeration_value_template (enum_id, value, description) 
SELECT em.id, v.value, v.description FROM em, (VALUES  
('entirelyAboveTerrain'             ,'(City)Object entirely above terrain'               ),
('substantiallyAboveTerrain'        ,'(City)Object substantially above terrain'          ),
('substantiallyAboveAndBelowTerrain','(City)Object substantially above and below terrain'),
('substantiallyBelowTerrain'        ,'(City)Object substantially below terrain'          ),
('entirelyBelowTerrain'             ,'(City)Object entirely below terrain'               )
) AS v(value, description);

WITH em AS (SELECT id FROM qgis_pkg.enumeration_template	WHERE
	data_model = 'CityGML 2.0'
	AND
	name = 'RelativeToWaterType'
) INSERT INTO qgis_pkg.enumeration_value_template (enum_id, value, description) 
SELECT em.id, v.value, v.description FROM em, (VALUES  
('entirelyAboveWaterSurface'             ,'(City)Object entirely above water surface'               ),
('substantiallyAboveWaterSurface'        ,'(City)Object substantially above water surface'          ),
('substantiallyAboveAndBelowWaterSurface','(City)Object substantially above and below water surface'),
('substantiallyBelowWaterSurface'        ,'(City)Object substantially below water surface'          ),
('entirelyBelowWaterSurface'             ,'(City)Object entirely below water surface'               ),
('temporarilyAboveAndBelowWaterSurface'  ,'(City)Object temporarily above and below water surface'  )
) AS v(value, description);

WITH em AS (SELECT id FROM qgis_pkg.enumeration_template	WHERE
	data_model = 'CityGML 2.0'
	AND
	name = 'TextureTypeType'
) INSERT INTO qgis_pkg.enumeration_value_template (enum_id, value, description) 
SELECT em.id, v.value, v.description FROM em, (VALUES  
('specific'  ,'Specific'),
('typical'   ,'Typical' ),
('unknown'   ,'Unknown' )
) AS v(value, description);

WITH em AS (SELECT id FROM qgis_pkg.enumeration_template	WHERE
	data_model = 'CityGML 2.0'
	AND
	name = 'WrapModeTypeType'
) INSERT INTO qgis_pkg.enumeration_value_template (enum_id, value, description) 
SELECT em.id, v.value, v.description FROM em, (VALUES  
('none'  ,'None'  ),
('wrap'  ,'Wrap'  ),
('mirror','Mirror'),
('clamp' ,'Clamp' ),
('border','Border')
) AS v(value, description);

--**************************
DO $$
BEGIN
RAISE NOTICE E'\n\nDone\n\n';
END $$;
--**************************
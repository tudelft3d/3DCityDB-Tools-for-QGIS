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
-- This script contains customized (non-normative) codelist values for 
-- CityGML 2.0 classes.
--
-- ***********************************************************************

----------------------------------------------------------
-- Add 3DGeoinfo building class
----------------------------------------------------------
WITH cl AS (
    INSERT INTO qgis_pkg.codelist_template (data_model, name, name_space, description)
    VALUES
    ('TUD-3DGeoinfo',  '_AbstractBuildingClass',  'https://3dcities.bk.tudelft.nl/codelists/citygml/_AbstractBuildingClass.xml',  'Values of building class used by the 3DGeoinfo group)')
    RETURNING id)
INSERT INTO qgis_pkg.codelist_value_template (code_id, value, description)
SELECT cl.id, v.value, v.description FROM cl, (VALUES  
('residential'                      ,'Residential'),
('mixed-use'                        ,'Mixed-use'),
('non-residential (single-function)','Non-residential (single-function)'),
('non-residential (multi-function)' ,'Non-residential (multi-function)'),
('unknown'                          ,'Unknown')
) AS v(value, description);

----------------------------------------------------------
-- Add NL BAG Gebruiksdoel for building function/usage
----------------------------------------------------------
WITH cl AS (
    INSERT INTO qgis_pkg.codelist_template (data_model, name, name_space, description)
    VALUES
    ('TUD-3DGeoinfo',  'BAG_gebruiksdoel',  'https://3dcities.bk.tudelft.nl/codelists/citygml/BAG_gebruiksdoel.xml',  'Values of building functions according to the Dutch "Basisregistratie Adressen en Gebouwen" (BAG))')
    RETURNING id)
INSERT INTO qgis_pkg.codelist_value_template (code_id, value, description)
SELECT cl.id, v.value, v.description FROM cl, (VALUES  
('woonfunctie'            ,'Gebruiksfunctie voor het wonen'),
('bijeenkomstfunctie'     ,'Gebruiksfunctie voor het samenkomen van personen voor kunst, cultuur, godsdienst, communicatie, kinderopvang, het verstrekken van consumpties voor het gebruik ter plaatse of het aanschouwen van sport'),
('celfunctie'             ,'Gebruiksfunctie voor het dwangverblijf van personen'),
('gezondheidszorgfunctie' ,'Gebruiksfunctie voor medisch onderzoek, verpleging, verzorging of behandeling'),
('industriefunctie'       ,'Gebruiksfunctie voor het bedrijfsmatig bewerken of opslaan van materialen en goederen, of voor agrarische doeleinden'),
('kantoorfunctie'         ,'Gebruiksfunctie voor administratie'),
('logiesfunctie'          ,'Gebruiksfunctie voor het bieden van recreatief verblijf of tijdelijk onderdak aan personen'),
('onderwijsfunctie'       ,'Gebruiksfunctie voor het geven van onderwijs'),
('sportfunctie'           ,'Gebruiksfunctie voor het beoefenen van sport'),
('winkelfunctie'          ,'Gebruiksfunctie voor het verhandelen van materialen, goederen of diensten'),
('overige gebruiksfunctie','Niet in dit lid benoemde gebruiksfunctie voor activiteiten waarbij het verblijven van personen een ondergeschikte rol speelt')
) AS v(value, description);


--**************************
DO $$
BEGIN
RAISE NOTICE E'\n\nDone\n\n';
END $$;
--**************************



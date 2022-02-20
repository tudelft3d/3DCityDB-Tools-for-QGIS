-- ****************************************************************************
-- ****************************************************************************
--
--
-- CREATE TABLES
--
--
-- ****************************************************************************
-- ****************************************************************************

DROP TABLE IF EXISTS qgis_pkg.materialized_view CASCADE;
CREATE TABLE         qgis_pkg.materialized_view (
id            serial PRIMARY KEY,
--parent_id     integer,
hierarchy     integer,
schema_name   varchar,
view_name     varchar,
last_refresh  timestamptz(3),
is_up_to_date boolean
);
COMMENT ON TABLE qgis_pkg.materialized_view IS 'List of materialized views in the qgis_pkg schema';

--CREATE INDEX mat_view_status_parent_id_idx ON qgis_pkg.materialized_view (parent_id);
CREATE INDEX mat_view_status_hierarchy_id_idx ON qgis_pkg.materialized_view (hierarchy);
CREATE INDEX mat_view_status_schema_name_idx  ON qgis_pkg.materialized_view (schema_name);
CREATE INDEX mat_view_status_view_name_idx    ON qgis_pkg.materialized_view (view_name);
CREATE INDEX mat_view_status_uptodate_idx     ON qgis_pkg.materialized_view (is_up_to_date);


----------------------------------------------------------------
-- Create FUNCTION QGIS_PKG.REFRESH_MATERIALIZED_VIEW
----------------------------------------------------------------
DROP FUNCTION IF EXISTS    qgis_pkg.refresh_materialized_view(varchar, varchar) CASCADE;
CREATE OR REPLACE FUNCTION qgis_pkg.refresh_materialized_view(
mview_schema varchar DEFAULT NULL,
mview_name   varchar DEFAULT NULL
)
RETURNS integer AS $$
DECLARE
qgis_pkg_schema_name varchar := 'qgis_pkg';
start_timestamp timestamptz(3);
stop_timestamp timestamptz(3);
r RECORD;
BEGIN

CASE 
	WHEN mview_schema IS NULL AND mview_name IS NULL THEN -- refresh all existing materialized views
		FOR r IN 
			SELECT pg_namespace.nspname AS table_schema, pg_class.relname AS mview_name
			FROM pg_catalog.pg_class
				INNER JOIN pg_catalog.pg_namespace ON pg_class.relnamespace = pg_namespace.oid
			WHERE pg_class.relkind = 'm' AND pg_namespace.nspname=qgis_pkg_schema_name
			ORDER BY mview_name
		LOOP
			start_timestamp := clock_timestamp();
			EXECUTE format('REFRESH MATERIALIZED VIEW %I.%I', qgis_pkg_schema_name, r.mview_name);
			stop_timestamp := clock_timestamp();
			UPDATE qgis_pkg.materialized_view AS mv SET
				is_up_to_date = TRUE,
				last_refresh  = stop_timestamp
			WHERE mv.view_name=r.mview_name;
				RAISE NOTICE 'Refreshed materialized view "%.%" in %', qgis_pkg_schema_name, r.mview_name, stop_timestamp-start_timestamp; 
			--PERFORM pg_notify('ref',FORMAT('Refreshed materialized view "%s.%s" in %s', qgis_pkg_schema_name, r.mview_name, stop_timestamp-start_timestamp));
					
		END LOOP;
		RAISE NOTICE 'All materialized views in schema "%" refreshed!', qgis_pkg_schema_name; 	
		RETURN 1;

	WHEN mview_schema IS NOT NULL THEN -- refresh all existing materialized views for that schema
		IF EXISTS (SELECT 1 FROM pg_catalog.pg_namespace WHERE pg_namespace.nspname=mview_schema) THEN
			FOR r IN 
				SELECT pg_namespace.nspname AS table_schema, pg_class.relname AS mview_name
				FROM pg_catalog.pg_class
					INNER JOIN pg_catalog.pg_namespace ON pg_class.relnamespace = pg_namespace.oid
				WHERE pg_class.relkind = 'm' AND pg_namespace.nspname=qgis_pkg_schema_name
					AND pg_class.relname LIKE '_geom_'||mview_schema||'_%'
				ORDER BY table_schema, mview_name
			LOOP
				start_timestamp := clock_timestamp();
				EXECUTE format('REFRESH MATERIALIZED VIEW %I.%I', qgis_pkg_schema_name, r.mview_name);
				stop_timestamp := clock_timestamp();
				UPDATE qgis_pkg.materialized_view AS mv SET
					is_up_to_date = TRUE,
					last_refresh  = stop_timestamp
				WHERE mv.view_name=r.mview_name;
				RAISE NOTICE 'Refreshed materialized view "%.%" in %', qgis_pkg_schema_name, r.mview_name, stop_timestamp-start_timestamp; 
			END LOOP;
			RAISE NOTICE 'All materialized views of schema "%" refreshed!', mview_schema; 	
			RETURN 1;
		ELSE
			RAISE NOTICE 'No schema found with name "%"', mview_schema;
			RETURN 0;			
		END IF;

	WHEN mview_name IS NOT NULL THEN -- refresh only a specific materialized views
		IF EXISTS (SELECT 1 
					FROM pg_catalog.pg_class
						INNER JOIN pg_catalog.pg_namespace ON pg_class.relnamespace = pg_namespace.oid
					WHERE pg_class.relkind = 'm' AND pg_namespace.nspname=qgis_pkg_schema_name
						AND pg_class.relname = mview_name) THEN
			start_timestamp := clock_timestamp();
			EXECUTE format('REFRESH MATERIALIZED VIEW %I.%I', qgis_pkg_schema_name, r.mview_name);
			stop_timestamp := clock_timestamp();
			UPDATE qgis_pkg.materialized_view AS mv SET
				is_up_to_date = TRUE,
				last_refresh  = stop_timestamp
			WHERE mv.view_name=r.mview_name;
			RAISE NOTICE 'Refreshed materialized view "%.%" in %', qgis_pkg_schema_name, r.mview_name, stop_timestamp-start_timestamp; 
			RETURN 1;
		ELSE
			RAISE NOTICE 'No materialized view found with name "%"', mview_name;
			RETURN 0;			
		END IF;

	ELSE
		RAISE NOTICE 'Nothing done';
		RETURN 0;	
END CASE;

EXCEPTION
  WHEN OTHERS THEN RAISE NOTICE '%.refresh_materialized_view(): %', qgis_pkg_schema_name, SQLERRM;
END;
$$ LANGUAGE plpgsql;
COMMENT ON FUNCTION qgis_pkg.refresh_materialized_view(varchar, varchar) IS 'Refresh materialized view(s) in schema qgis_pkg';

-- ****************************************************************************
-- ****************************************************************************
--
--
-- CREATE LOOK-UP TABLES, all prefixed with lu_
--
--
-- ****************************************************************************
-- ****************************************************************************

-- TODO: codelist_name, e magari unisci TUTTE le codelist in un unica tabella (add field: codelist_class)

----------------------------------------------------------------
-- Table LU_RELATIVE_TO_TERRAIN
----------------------------------------------------------------
DROP TABLE IF EXISTS qgis_pkg.lu_relative_to_terrain CASCADE;
CREATE TABLE         qgis_pkg.lu_relative_to_terrain (
code_value  varchar PRIMARY KEY,
code_name   varchar,
description text,
codespace   varchar
);
COMMENT ON TABLE qgis_pkg.lu_relative_to_terrain IS 'Contains the enumeration values of CityGML class core::RelativeToTerrainType';

TRUNCATE    qgis_pkg.lu_relative_to_terrain CASCADE;
INSERT INTO qgis_pkg.lu_relative_to_terrain
(code_value, code_name)
VALUES
('entirelyAboveTerrain'             ,'Entirely above terrain'               ),
('substantiallyAboveTerrain'        ,'Substantially above terrain'          ),
('substantiallyAboveAndBelowTerrain','Substantially above and below terrain'),
('substantiallyBelowTerrain'        ,'Substantially below terrain'          ),
('entirelyBelowTerrain'             ,'Entirely below terrain'               )
;
UPDATE qgis_pkg.lu_relative_to_terrain SET codespace='https://schemas.opengis.net/citygml/2.0/cityGMLBase.xsd';

----------------------------------------------------------------
-- Table LU_RELATIVE_TO_WATER
----------------------------------------------------------------
DROP TABLE IF EXISTS qgis_pkg.lu_relative_to_water CASCADE;
CREATE TABLE         qgis_pkg.lu_relative_to_water (
code_value  varchar PRIMARY KEY,
code_name   varchar,
description text,
codespace   varchar
);
-- CREATE INDEX lu_relwat_name_inx ON qgis_pkg.lu_relative_to_water USING btree (code_name, value_codespace);
COMMENT ON TABLE qgis_pkg.lu_relative_to_water IS 'Contains the enumeration values of CityGML class core::RelativeToWaterType';

TRUNCATE    qgis_pkg.lu_relative_to_water CASCADE;
INSERT INTO qgis_pkg.lu_relative_to_water
(code_value, code_name)
VALUES
('entirelyAboveWaterSurface'             ,'Entirely above water surface'               ),
('substantiallyAboveWaterSurface'        ,'Substantially above water surface'          ),
('substantiallyAboveAndBelowWaterSurface','Substantially above and below water surface'),
('substantiallyBelowWaterSurface'        ,'Substantially below water surface'          ),
('entirelyBelowWaterSurface'             ,'Entirely below water surface'               ),
('temporarilyAboveAndBelowWaterSurface'  ,'Temporarily above and below water surface'  )
;
UPDATE qgis_pkg.lu_relative_to_water SET codespace='https://schemas.opengis.net/citygml/2.0/cityGMLBase.xsd';

----------------------------------------------------------------
-- Table LU_GENERICATTRIB_DATA_TYPE
----------------------------------------------------------------
DROP TABLE IF EXISTS qgis_pkg.lu_genericattrib_data_type CASCADE;
CREATE TABLE         qgis_pkg.lu_genericattrib_data_type (
code_value integer PRIMARY KEY,
code_name  varchar
);
COMMENT ON TABLE qgis_pkg.lu_genericattrib_data_type IS 'Contains the values corresponding to data types of generic attributes';

TRUNCATE    qgis_pkg.lu_genericattrib_data_type CASCADE;
INSERT INTO qgis_pkg.lu_genericattrib_data_type
(code_value, code_name)
VALUES
( 1, 'String'          ),
( 2, 'Integer'         ),
( 3, 'Real'            ),
( 4, 'Uri'             ),
( 5, 'Date'            ),
( 6, 'Measure'         ),
( 7, 'Group'           ),
( 8, 'Blob'            ),
( 9, 'Geometry'        ),
(10, 'Surface geometry')
;

----------------------------------------------------------------
-- Table LU_MIME_TYPE
----------------------------------------------------------------
DROP TABLE IF EXISTS qgis_pkg.lu_mime_type CASCADE;
CREATE TABLE         qgis_pkg.lu_mime_type (
code_value varchar PRIMARY KEY,
code_name  varchar,
codespace  varchar
);
COMMENT ON TABLE qgis_pkg.lu_mime_type IS 'Contains some NON-normative codelist values for mime types (refer to https://www.iana.org/assignments/media-types/media-types.xhtml)';

TRUNCATE    qgis_pkg.lu_mime_type CASCADE;
INSERT INTO qgis_pkg.lu_mime_type
(code_value, code_name)
VALUES
('model/vrml'                   , 'VRML97'              ),
('application/x-3ds'            , '3ds max'             ),
('application/dxf'              , 'AutoCad DXF'         ),
('application/x-autocad'        , 'AutoCad DXF'         ),
('application/x-dxf'            , 'AutoCad DXF'         ),
('application/acad'             , 'AutoCad DWG'         ),
('application/x-shockwave-flash', 'Shockwave 3D'        ),
('model/x3d+xml'                , 'X3D'                 ),
('model/x3d+binary'             , 'X3D'                 ),
('image/gif'                    , '*.gif images'        ),
('image/jpeg'                   , '*.jpeg, *.jpg images'),
('image/png'                    , '*.png images'        ),
('image/tiff'                   , '*.tiff, *.tif images'),
('image/bmp'                    , '*.bmp images'        )
;
UPDATE qgis_pkg.lu_mime_type SET codespace='http://www.sig3d.org/codelists/standard/core/2.0/ImplicitGeometry_mimeType.xml';

----------------------------------------------------------------
-- Table LU_BUILDING_CLASS
----------------------------------------------------------------
DROP TABLE IF EXISTS qgis_pkg.lu_building_class CASCADE;
CREATE TABLE         qgis_pkg.lu_building_class (
code_value      varchar PRIMARY KEY,
code_name       varchar,
description     text,
codelist_name   varchar,
codespace       varchar
);
COMMENT ON TABLE qgis_pkg.lu_building_class IS 'Contains the NON-normative codelist values of attribute "class" in class bldg::_AbstractBuilding';
CREATE INDEX lu_bdg_class_cl_name_idx ON qgis_pkg.lu_building_class (codelist_name);

TRUNCATE    qgis_pkg.lu_building_class CASCADE;
INSERT INTO qgis_pkg.lu_building_class
(code_value, code_name, codelist_name) 
VALUES 
(1000, 'Habitation'                       ,'CityGML 2.0 non-normative'),
(1010, 'Sanitation'                       ,'CityGML 2.0 non-normative'),
(1020, 'Administration'                   ,'CityGML 2.0 non-normative'),
(1030, 'Business, trade'                  ,'CityGML 2.0 non-normative'),
(1040, 'Catering'                         ,'CityGML 2.0 non-normative'),
(1050, 'Recreation'                       ,'CityGML 2.0 non-normative'),
(1060, 'Sport'                            ,'CityGML 2.0 non-normative'),
(1070, 'Culture'                          ,'CityGML 2.0 non-normative'),
(1080, 'Church institution'               ,'CityGML 2.0 non-normative'),
(1090, 'Agriculture, forestry'            ,'CityGML 2.0 non-normative'),
(1100, 'Schools, education, research'     ,'CityGML 2.0 non-normative'),
(1110, 'Maintainence and waste management','CityGML 2.0 non-normative'),
(1120, 'Healthcare'                       ,'CityGML 2.0 non-normative'),
(1130, 'Communicating'                    ,'CityGML 2.0 non-normative'),
(1140, 'Security'                         ,'CityGML 2.0 non-normative'),
(1150, 'Storage'                          ,'CityGML 2.0 non-normative'),
(1160, 'Industry'                         ,'CityGML 2.0 non-normative'),
(1170, 'Traffic'                          ,'CityGML 2.0 non-normative'),
(1180, 'Other function'                   ,'CityGML 2.0 non-normative'),
(9999, 'Unknown'                          ,'CityGML 2.0 non-normative')
;
UPDATE qgis_pkg.lu_building_class SET codespace='https://www.sig3d.org/codelists/standard/building/2.0/_AbstractBuilding_class.xml' WHERE codelist_name='CityGML 2.0 non-normative';

INSERT INTO qgis_pkg.lu_building_class
(code_value, code_name, codelist_name)
VALUES 
('Unknown'                          ,'Unknown'                          ,'TUD 3DGeoInfo 3DBAG'),
('Residential'                      ,'Residential'                      ,'TUD 3DGeoInfo 3DBAG'),
('Mixed-use'                        ,'Mixed-use'                        ,'TUD 3DGeoInfo 3DBAG'),
('Non-residential (multi function)' ,'Non-residential (multi function)' ,'TUD 3DGeoInfo 3DBAG'),
('Non-residential (single function)','Non-residential (single function)','TUD 3DGeoInfo 3DBAG')
;
UPDATE qgis_pkg.lu_building_class SET codespace='https://www.sig3d.org/codelists/standard/building/2.0/_AbstractBuilding_class.xml'
WHERE codelist_name='TUD 3DGeoInfo 3DBAG';


----------------------------------------------------------------
-- Table LU_BUILDING_FUNCTION_USAGE
----------------------------------------------------------------
DROP TABLE IF EXISTS qgis_pkg.lu_building_function_usage CASCADE;
CREATE TABLE         qgis_pkg.lu_building_function_usage (
code_value      varchar PRIMARY KEY,
code_name       varchar,
description     text,
codelist_name   varchar,
codespace       varchar
);
COMMENT ON TABLE qgis_pkg.lu_building_function_usage IS 'Contains the NON-normative codelist values of attributes "function" and "usage" in class bldg::_AbstractBuilding';
CREATE INDEX lu_bdg_fun_usa_cl_name_idx ON qgis_pkg.lu_building_function_usage (codelist_name);

TRUNCATE    qgis_pkg.lu_building_function_usage CASCADE;
INSERT INTO qgis_pkg.lu_building_function_usage 
(code_value, code_name, codelist_name) 
VALUES 
(1000, 'Residential building'                        ,'CityGML 2.0 non-normative'),
(1010, 'Tenement'                                    ,'CityGML 2.0 non-normative'),
(1020, 'Hostel'                                      ,'CityGML 2.0 non-normative'),
(1090, 'Forester''s lodge'                           ,'CityGML 2.0 non-normative'),
(1100, 'Holiday house'                               ,'CityGML 2.0 non-normative'),
(1110, 'Summer house'                                ,'CityGML 2.0 non-normative'),
(1120, 'Office building'                             ,'CityGML 2.0 non-normative'),
(1130, 'Credit institution'                          ,'CityGML 2.0 non-normative'),
(1140, 'Insurance'                                   ,'CityGML 2.0 non-normative'),
(1150, 'Business building'                           ,'CityGML 2.0 non-normative'),
(1160, 'Department store'                            ,'CityGML 2.0 non-normative'),
(1170, 'Shopping centre'                             ,'CityGML 2.0 non-normative'),
(1180, 'Kiosk'                                       ,'CityGML 2.0 non-normative'),
(1190, 'Pharmacy'                                    ,'CityGML 2.0 non-normative'),
(1200, 'Pavilion'                                    ,'CityGML 2.0 non-normative'),
(1210, 'Hotel'                                       ,'CityGML 2.0 non-normative'),
(1220, 'Youth hostel'                                ,'CityGML 2.0 non-normative'),
(1230, 'Campsite building'                           ,'CityGML 2.0 non-normative'),
(1240, 'Restaurant'                                  ,'CityGML 2.0 non-normative'),
(1250, 'Cantine'                                     ,'CityGML 2.0 non-normative'),
(1260, 'Recreational site'                           ,'CityGML 2.0 non-normative'),
(1270, 'Function room'                               ,'CityGML 2.0 non-normative'),
(1280, 'Cinema'                                      ,'CityGML 2.0 non-normative'),
(1290, 'Bowling alley'                               ,'CityGML 2.0 non-normative'),
(1300, 'Casino'                                      ,'CityGML 2.0 non-normative'),
(1310, 'Industrial building'                         ,'CityGML 2.0 non-normative'),
(1320, 'Factory'                                     ,'CityGML 2.0 non-normative'),
(1330, 'Workshop'                                    ,'CityGML 2.0 non-normative'),
(1350, 'Washing plant'                               ,'CityGML 2.0 non-normative'),
(1360, 'Cold store'                                  ,'CityGML 2.0 non-normative'),
(1370, 'Depot'                                       ,'CityGML 2.0 non-normative'),
(1380, 'Building for research purposes'              ,'CityGML 2.0 non-normative'),
(1390, 'Quarry'                                      ,'CityGML 2.0 non-normative'),
(1400, 'Salt works'                                  ,'CityGML 2.0 non-normative'),
(1410, 'Miscellaneous industrial building'           ,'CityGML 2.0 non-normative'),
(1420, 'Mill'                                        ,'CityGML 2.0 non-normative'),
(1430, 'Windmill'                                    ,'CityGML 2.0 non-normative'),
(1440, 'Water mill'                                  ,'CityGML 2.0 non-normative'),
(1450, 'Bucket elevator'                             ,'CityGML 2.0 non-normative'),
(1460, 'Weather station'                             ,'CityGML 2.0 non-normative'),
(1470, 'Traffic assets office'                       ,'CityGML 2.0 non-normative'),
(1480, 'Street maintenance'                          ,'CityGML 2.0 non-normative'),
(1490, 'Waiting hall'                                ,'CityGML 2.0 non-normative'),
(1500, 'Signal control box'                          ,'CityGML 2.0 non-normative'),
(1510, 'Engine shed'                                 ,'CityGML 2.0 non-normative'),
(1520, 'Signal box or stop signal'                   ,'CityGML 2.0 non-normative'),
(1530, 'Plant building for air traffic'              ,'CityGML 2.0 non-normative'),
(1540, 'Hangar'                                      ,'CityGML 2.0 non-normative'),
(1550, 'Plant building for shipping'                 ,'CityGML 2.0 non-normative'),
(1560, 'Shipyard'                                    ,'CityGML 2.0 non-normative'),
(1570, 'Dock'                                        ,'CityGML 2.0 non-normative'),
(1580, 'Plant building for canal lock'               ,'CityGML 2.0 non-normative'),
(1590, 'Boathouse'                                   ,'CityGML 2.0 non-normative'),
(1600, 'Plant building for cablecar'                 ,'CityGML 2.0 non-normative'),
(1610, 'Multi-storey car park'                       ,'CityGML 2.0 non-normative'),
(1620, 'Parking level'                               ,'CityGML 2.0 non-normative'),
(1630, 'Garage'                                      ,'CityGML 2.0 non-normative'),
(1640, 'Vehicle hall'                                ,'CityGML 2.0 non-normative'),
(1650, 'Underground garage'                          ,'CityGML 2.0 non-normative'),
(1660, 'Building for supply'                         ,'CityGML 2.0 non-normative'),
(1670, 'Waterworks'                                  ,'CityGML 2.0 non-normative'),
(1680, 'Pump station'                                ,'CityGML 2.0 non-normative'),
(1690, 'Water basin'                                 ,'CityGML 2.0 non-normative'),
(1700, 'Electric power station'                      ,'CityGML 2.0 non-normative'),
(1710, 'Transformer station'                         ,'CityGML 2.0 non-normative'),
(1720, 'Converter'                                   ,'CityGML 2.0 non-normative'),
(1730, 'Reactor'                                     ,'CityGML 2.0 non-normative'),
(1740, 'Turbine house'                               ,'CityGML 2.0 non-normative'),
(1750, 'Boiler house'                                ,'CityGML 2.0 non-normative'),
(1760, 'Building for telecommunications'             ,'CityGML 2.0 non-normative'),
(1770, 'Gas works'                                   ,'CityGML 2.0 non-normative'),
(1780, 'Heat plant'                                  ,'CityGML 2.0 non-normative'),
(1790, 'Pumping station'                             ,'CityGML 2.0 non-normative'),
(1800, 'Building for disposal'                       ,'CityGML 2.0 non-normative'),
(1810, 'Building for effluent disposal'              ,'CityGML 2.0 non-normative'),
(1820, 'Building for filter plant'                   ,'CityGML 2.0 non-normative'),
(1830, 'Toilet'                                      ,'CityGML 2.0 non-normative'),
(1840, 'Rubbish bunker'                              ,'CityGML 2.0 non-normative'),
(1850, 'Building for rubbish incineration'           ,'CityGML 2.0 non-normative'),
(1860, 'Building for rubbish disposal'               ,'CityGML 2.0 non-normative'),
(1870, 'Building for agrarian and forestry'          ,'CityGML 2.0 non-normative'),
(1880, 'Barn'                                        ,'CityGML 2.0 non-normative'),
(1890, 'Stall'                                       ,'CityGML 2.0 non-normative'),
(1900, 'Equestrian hall'                             ,'CityGML 2.0 non-normative'),
(1910, 'Alpine cabin'                                ,'CityGML 2.0 non-normative'),
(1920, 'Hunting lodge'                               ,'CityGML 2.0 non-normative'),
(1930, 'Arboretum'                                   ,'CityGML 2.0 non-normative'),
(1940, 'Glass house'                                 ,'CityGML 2.0 non-normative'),
(1950, 'Moveable glass house'                        ,'CityGML 2.0 non-normative'),
(1960, 'Public building'                             ,'CityGML 2.0 non-normative'),
(1970, 'Administration building'                     ,'CityGML 2.0 non-normative'),
(1980, 'Parliament'                                  ,'CityGML 2.0 non-normative'),
(1990, 'Guildhall'                                   ,'CityGML 2.0 non-normative'),
(2000, 'Post office'                                 ,'CityGML 2.0 non-normative'),
(2010, 'Customs office'                              ,'CityGML 2.0 non-normative'),
(2020, 'Court'                                       ,'CityGML 2.0 non-normative'),
(2030, 'Embassy or consulate'                        ,'CityGML 2.0 non-normative'),
(2040, 'District administration'                     ,'CityGML 2.0 non-normative'),
(2050, 'District government'                         ,'CityGML 2.0 non-normative'),
(2060, 'Tax office'                                  ,'CityGML 2.0 non-normative'),
(2080, 'Comprehensive school'                        ,'CityGML 2.0 non-normative'),
(2090, 'Vocational school'                           ,'CityGML 2.0 non-normative'),
(2100, 'College or university'                       ,'CityGML 2.0 non-normative'),
(2110, 'Research establishment'                      ,'CityGML 2.0 non-normative'),
(2120, 'Building for cultural purposes'              ,'CityGML 2.0 non-normative'),
(2130, 'Castle'                                      ,'CityGML 2.0 non-normative'),
(2140, 'Theatre or opera'                            ,'CityGML 2.0 non-normative'),
(2150, 'Concert building'                            ,'CityGML 2.0 non-normative'),
(2160, 'Museum'                                      ,'CityGML 2.0 non-normative'),
(2170, 'Broadcasting building'                       ,'CityGML 2.0 non-normative'),
(2180, 'Activity building'                           ,'CityGML 2.0 non-normative'),
(2190, 'Library'                                     ,'CityGML 2.0 non-normative'),
(2200, 'Fort'                                        ,'CityGML 2.0 non-normative'),
(2210, 'Religious Building'                          ,'CityGML 2.0 non-normative'),
(2220, 'Church'                                      ,'CityGML 2.0 non-normative'),
(2230, 'Synagogue'                                   ,'CityGML 2.0 non-normative'),
(2240, 'Chapel'                                      ,'CityGML 2.0 non-normative'),
(2250, 'Community centre'                            ,'CityGML 2.0 non-normative'),
(2260, 'Place of worship'                            ,'CityGML 2.0 non-normative'),
(2270, 'Mosque'                                      ,'CityGML 2.0 non-normative'),
(2280, 'Temple'                                      ,'CityGML 2.0 non-normative'),
(2290, 'Convent'                                     ,'CityGML 2.0 non-normative'),
(2300, 'Building for health care'                    ,'CityGML 2.0 non-normative'),
(2310, 'Hospital'                                    ,'CityGML 2.0 non-normative'),
(2320, 'Healing centre or care home'                 ,'CityGML 2.0 non-normative'),
(2330, 'Health centre or outpatients clinic'         ,'CityGML 2.0 non-normative'),
(2340, 'Building for social purposes'                ,'CityGML 2.0 non-normative'),
(2350, 'Youth centre'                                ,'CityGML 2.0 non-normative'),
(2360, 'Seniors centre'                              ,'CityGML 2.0 non-normative'),
(2370, 'Homeless shelter'                            ,'CityGML 2.0 non-normative'),
(2380, 'Kindergarten or nursery'                     ,'CityGML 2.0 non-normative'),
(2390, 'Asylum seekers home'                         ,'CityGML 2.0 non-normative'),
(2400, 'Police station'                              ,'CityGML 2.0 non-normative'),
(2410, 'Fire station'                                ,'CityGML 2.0 non-normative'),
(2420, 'Barracks'                                    ,'CityGML 2.0 non-normative'),
(2430, 'Bunker'                                      ,'CityGML 2.0 non-normative'),
(2440, 'Penitentiary or prison'                      ,'CityGML 2.0 non-normative'),
(2450, 'Cemetery building'                           ,'CityGML 2.0 non-normative'),
(2460, 'Funeral parlor'                              ,'CityGML 2.0 non-normative'),
(2470, 'Crematorium'                                 ,'CityGML 2.0 non-normative'),
(2480, 'Train Station'                               ,'CityGML 2.0 non-normative'),
(2490, 'Airport building'                            ,'CityGML 2.0 non-normative'),
(2500, 'Building for underground station'            ,'CityGML 2.0 non-normative'),
(2510, 'Building for tramway'                        ,'CityGML 2.0 non-normative'),
(2520, 'Building for bus station'                    ,'CityGML 2.0 non-normative'),
(2530, 'Shipping terminal'                           ,'CityGML 2.0 non-normative'),
(2540, 'Building for recuperation purposes'          ,'CityGML 2.0 non-normative'),
(1040, 'Residential and office building'             ,'CityGML 2.0 non-normative'),
(1050, 'Residential and business building'           ,'CityGML 2.0 non-normative'),
(1060, 'Residential and plant building'              ,'CityGML 2.0 non-normative'),
(1070, 'Agrarian and forestry building'              ,'CityGML 2.0 non-normative'),
(1080, 'Residential and commercial building'         ,'CityGML 2.0 non-normative'),
(1340, 'Petrol/Gas station'                          ,'CityGML 2.0 non-normative'),
(2550, 'Building for sport purposes'                 ,'CityGML 2.0 non-normative'),
(2560, 'Sports hall'                                 ,'CityGML 2.0 non-normative'),
(2570, 'Building for sports field'                   ,'CityGML 2.0 non-normative'),
(2580, 'Swimming baths'                              ,'CityGML 2.0 non-normative'),
(2590, 'Indoor swimming pool'                        ,'CityGML 2.0 non-normative'),
(2600, 'Sanatorium'                                  ,'CityGML 2.0 non-normative'),
(2610, 'Zoo building'                                ,'CityGML 2.0 non-normative'),
(2620, 'Green house'                                 ,'CityGML 2.0 non-normative'),
(2630, 'Botanical show house'                        ,'CityGML 2.0 non-normative'),
(2640, 'Bothy'                                       ,'CityGML 2.0 non-normative'),
(2650, 'Tourist information centre'                  ,'CityGML 2.0 non-normative'),
(2700, 'Others'                                      ,'CityGML 2.0 non-normative'),
(1030, 'Residential and administration building'     ,'CityGML 2.0 non-normative'),
(2070, 'School (Building for education and research)','CityGML 2.0 non-normative')
;
UPDATE qgis_pkg.lu_building_function_usage SET codespace='https://www.sig3d.org/codelists/standard/building/2.0/_AbstractBuilding_function.xml' WHERE codelist_name='CityGML 2.0 non-normative';

INSERT INTO qgis_pkg.lu_building_function_usage 
(code_value, code_name, codelist_name, description)
VALUES
('bijeenkomstfunctie'     ,'Bijeenkomstfunctie'     ,'NL BAG Gebruiksdoel', 'Gebruiksfunctie voor het samenkomen van personen voor kunst, cultuur, godsdienst, communicatie, kinderopvang, het verstrekken van consumpties voor het gebruik ter plaatse of het aanschouwen van sport'),
('celfunctie'             ,'Celfunctie'             ,'NL BAG Gebruiksdoel', 'Gebruiksfunctie voor het dwangverblijf van personen'),
('gezondheidszorgfunctie' ,'Gezondheidszorgfunctie' ,'NL BAG Gebruiksdoel', 'Gebruiksfunctie voor medisch onderzoek, verpleging, verzorging of behandeling'),
('industriefunctie'       ,'Industriefunctie'       ,'NL BAG Gebruiksdoel', 'Gebruiksfunctie voor het bedrijfsmatig bewerken of opslaan van materialen en goederen, of voor agrarische doeleinden'),
('kantoorfunctie'         ,'Kantoorfunctie'         ,'NL BAG Gebruiksdoel', 'Gebruiksfunctie voor administratie'),
('logiesfunctie'          ,'Logiesfunctie'          ,'NL BAG Gebruiksdoel', 'Gebruiksfunctie voor het bieden van recreatief verblijf of tijdelijk onderdak aan personen'),
('onderwijsfunctie'       ,'Onderwijsfunctie'       ,'NL BAG Gebruiksdoel', 'Gebruiksfunctie voor het geven van onderwijs'),
('overige gebruiksfunctie','Overige gebruiksfunctie','NL BAG Gebruiksdoel', 'Niet in dit lid benoemde gebruiksfunctie voor activiteiten waarbij het verblijven van personen een ondergeschikte rol speelt'),
('sportfunctie'           ,'Sportfunctie'           ,'NL BAG Gebruiksdoel', 'Gebruiksfunctie voor het beoefenen van sport'),
('winkelfunctie'          ,'Winkelfunctie'          ,'NL BAG Gebruiksdoel', 'Gebruiksfunctie voor het verhandelen van materialen, goederen of diensten'),
('woonfunctie'            ,'Woonfunctie'            ,'NL BAG Gebruiksdoel', 'Gebruiksfunctie voor het wonen')
;
--UPDATE qgis_pkg.lu_building_function_usage SET codespace='https://www.sig3d.org/codelists/standard/building/2.0/_AbstractBuilding_function.xml'
--WHERE codelist_name='NL BAG Gebruiksdoel';


----------------------------------------------------------------
-- Table LU_BUILDING_ROOF_TYPE
----------------------------------------------------------------
DROP TABLE IF EXISTS qgis_pkg.lu_building_roof_type CASCADE;
CREATE TABLE         qgis_pkg.lu_building_roof_type (
code_value      varchar PRIMARY KEY,
code_name       varchar,
description     text,
codelist_name   varchar,
codespace       varchar
);
COMMENT ON TABLE qgis_pkg.lu_building_roof_type IS 'Contains the NON-normative codelist values of attribute "roofType" in class bldg::_AbstractBuilding';
CREATE INDEX lu_bdg_roof_cl_name_idx ON qgis_pkg.lu_building_roof_type (codelist_name);

TRUNCATE    qgis_pkg.lu_building_roof_type CASCADE;
INSERT INTO qgis_pkg.lu_building_roof_type 
(code_value, code_name, codelist_name) 
VALUES 
(1000, 'Flat roof'                ,'CityGML 2.0 non-normative'),
(1010, 'Monopitch roof'           ,'CityGML 2.0 non-normative'),
(1020, 'Dual-pent roof'           ,'CityGML 2.0 non-normative'),
(1030, 'Gabled roof'              ,'CityGML 2.0 non-normative'),
(1040, 'Hipped roof'              ,'CityGML 2.0 non-normative'),
(1050, 'Half-hipped roof'         ,'CityGML 2.0 non-normative'),
(1060, 'Mansard roof'             ,'CityGML 2.0 non-normative'),
(1070, 'Pavilion roof'            ,'CityGML 2.0 non-normative'),
(1080, 'Cone roof'                ,'CityGML 2.0 non-normative'),
(1090, 'Cupola roof'              ,'CityGML 2.0 non-normative'),
(1100, 'Sawtooth roof '           ,'CityGML 2.0 non-normative'),
(1110, 'Arch roof'                ,'CityGML 2.0 non-normative'),
(1120, 'Pyramidal broach roof'    ,'CityGML 2.0 non-normative'),
(1130, 'Combination of roof forms','CityGML 2.0 non-normative')
;
UPDATE qgis_pkg.lu_building_roof_type SET codespace='https://www.sig3d.org/codelists/standard/building/2.0/_AbstractBuilding_roofType.xml' WHERE codelist_name='CityGML 2.0 non-normative';






----------------------------------------------------------------
-- Table LU_BUILDING_INSTALLATION_CLASS
----------------------------------------------------------------
DROP TABLE IF EXISTS qgis_pkg.lu_building_installation_class CASCADE;
CREATE TABLE         qgis_pkg.lu_building_installation_class (
code_value      varchar PRIMARY KEY,
code_name       varchar,
description     text,
codelist_name   varchar,
codespace       varchar
);
COMMENT ON TABLE qgis_pkg.lu_building_installation_class IS 'Contains the NON-normative codelist values of attribute "class" in class bldg::BuildingInstallation';
CREATE INDEX lu_bdg_inst_class_cl_name_idx ON qgis_pkg.lu_building_installation_class (codelist_name);


TRUNCATE    qgis_pkg.lu_building_installation_class CASCADE;
INSERT INTO qgis_pkg.lu_building_installation_class
(code_value, code_name, codelist_name)
VALUES
(1000, 'Outer characteristics','CityGML 2.0 non-normative'),
(1010, 'Inner characteristics','CityGML 2.0 non-normative'),
(1020, 'Waste management'     ,'CityGML 2.0 non-normative'),
(1030, 'Maintenance'          ,'CityGML 2.0 non-normative'),
(1040, 'Communicating'        ,'CityGML 2.0 non-normative'),
(1050, 'Security'             ,'CityGML 2.0 non-normative'),
(1060, 'Others'               ,'CityGML 2.0 non-normative')
;
UPDATE qgis_pkg.lu_building_installation_class SET codespace='https://www.sig3d.org/codelists/standard/building/2.0/BuildingInstallation_class.xml' WHERE codelist_name='CityGML 2.0 non-normative';

----------------------------------------------------------------
-- Table LU_BUILDING_INSTALLATION_FUNCTION_USAGE
----------------------------------------------------------------
DROP TABLE IF EXISTS qgis_pkg.lu_building_installation_function_usage CASCADE;
CREATE TABLE         qgis_pkg.lu_building_installation_function_usage (
code_value      varchar PRIMARY KEY,
code_name       varchar,
description     text,
codelist_name   varchar,
codespace       varchar
);
COMMENT ON TABLE qgis_pkg.lu_building_installation_function_usage IS 'Contains the NON-normative codelist values of attributes "function" and "usage" in class bldg::BuildingInstallation';
CREATE INDEX lu_bdg_inst_fun_usa_cl_name_idx ON qgis_pkg.lu_building_installation_function_usage (codelist_name);

TRUNCATE    qgis_pkg.lu_building_installation_function_usage CASCADE;
INSERT INTO qgis_pkg.lu_building_installation_function_usage
(code_value, code_name, codelist_name)
VALUES
(1000, 'Balcony'                     ,'CityGML 2.0 non-normative'),
(1010, 'Winter garden'               ,'CityGML 2.0 non-normative'),
(1020, 'Arcade'                      ,'CityGML 2.0 non-normative'),
(1030, 'Chimney (Part of a building)','CityGML 2.0 non-normative'),
(1040, 'Tower (Part of a Building)'  ,'CityGML 2.0 non-normative'),
(1050, 'Column'                      ,'CityGML 2.0 non-normative'),
(1060, 'Stairs'                      ,'CityGML 2.0 non-normative'),
(1070, 'Others'                      ,'CityGML 2.0 non-normative')
;
UPDATE qgis_pkg.lu_building_installation_function_usage SET codespace='https://www.sig3d.org/codelists/standard/building/2.0/BuildingInstallation_function.xml' WHERE codelist_name='CityGML 2.0 non-normative';

--**************************
DO $$
BEGIN
RAISE NOTICE 'Done';
END $$;
--**************************


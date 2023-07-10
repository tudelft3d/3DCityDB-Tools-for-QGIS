DROP TABLE IF EXISTS qgis_pkg.ade_feature_types;
CREATE TABLE qgis_pkg.ade_feature_types (
	id		SERIAL PRIMARY KEY,	
	feature_type	varchar(250),
	ade_name	varchar(250),
	ade_prefix	varchar(250)
);

INSERT INTO qgis_pkg.ade_feature_types(feature_type,ade_name,ade_prefix)
VALUES('WeatherStation'::varchar,'KitEnergyADE'::varchar,'ng'::varchar);
-- in future move ddl to 020_tables
-- leave dml only here


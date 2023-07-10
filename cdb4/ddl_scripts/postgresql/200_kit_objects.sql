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
-- Author: Tendai Mbwanda
--         MSc Geomatics
--	   Delft University of Technology, The Netherlands
-- 	
-- ***********************************************************************
-- ***********************************************************************
--
--
-- This script installs the database types (objects) into schema qgis_pkg.
-- Each type corresponds to an energy ade table.
--
--
-- ***********************************************************************

----------------------------------------------------------------
-- CREATE OBJECT (TYPE) corresponding to table ng_building
----------------------------------------------------------------

DROP TYPE IF EXISTS qgis_pkg.obj_ng_building CASCADE;
CREATE TYPE qgis_pkg.obj_ng_building AS (
	id				bigint,
	buildingtype			varchar,
	buildingtype_codespace		varchar,
	constructionweight		varchar,
	referencepoint			geometry
);
COMMENT ON TYPE qgis_pkg.obj_ng_building IS 'This object (type) corresponds to table ng_building';

---------------------------------------------------------------
-- CREATE OBJECT (TYPE) corresponding to table ng_cityobject
---------------------------------------------------------------

DROP TYPE IF EXISTS qgis_pkg.obj_ng_cityobject CASCADE;
CREATE TYPE qgis_pkg.obj_ng_cityobject AS (
	id				bigint
);
COMMENT ON TYPE qgis_pkg.obj_ng_cityobject IS 'This object (type) corresponds to table ng_cityobject';

-------------------------------------------------------------------------------------
-- CREATE OBJECT (TYPE) corresponding to table ng_construction
-------------------------------------------------------------------------------------

DROP TYPE IF EXISTS qgis_pkg.obj_ng_construction CASCADE;
CREATE TYPE qgis_pkg.obj_ng_construction AS (
	id				bigint,
	opticalproperties_id		bigint,
	uvalue				numeric,
	uvalue_uom			varchar
);
COMMENT ON TYPE qgis_pkg.obj_ng_construction IS 'This object (type) corresponds to table ng_construction';

-------------------------------------------------------------------------------------
-- CREATE OBJECT (TYPE) corresponding to table ng_dailyschedule
-------------------------------------------------------------------------------------

DROP TYPE IF EXISTS qgis_pkg.obj_ng_dailyschedule CASCADE;
CREATE TYPE qgis_pkg.obj_ng_dailyschedule AS (
	id				bigint,
	daytype				varchar,
	periodofyear_dailyschedul_id	bigint,
	schedule_id			bigint
);
COMMENT ON TYPE qgis_pkg.obj_ng_dailyschedule IS 'This object (type) corresponds to table ng_dailyschedule';

------------------------------------------------------------------------------------
-- CREATE OBJECT (TYPE) corresponding to table ng_energydem_to_cityobjec
------------------------------------------------------------------------------------

DROP TYPE IF EXISTS qgis_pkg.obj_ng_energydem_to_cityobjec CASCADE;
CREATE TYPE qgis_pkg.obj_ng_energydem_to_cityobjec AS (
	cityobject_id			bigint,
	energydemand_id			bigint
);
COMMENT ON TYPE qgis_pkg.obj_ng_energydem_to_cityobjec IS 'This object (type) corresponds to table ng_energydem_to_cityobjec';

------------------------------------------------------------------------------------
-- CREATE OBJECT (TYPE) corresponding to ng_energydemand
------------------------------------------------------------------------------------

DROP TYPE IF EXISTS qgis_pkg.obj_ng_energydemand CASCADE;
CREATE TYPE qgis_pkg.obj_ng_energydemand AS (
	id				bigint,
	cityobject_demands_id		bigint,
	enduse				varchar,
	energyamount_id			bigint,
	energycarriertype		varchar,
	energycarriertype_codespace	varchar,
	maximumload			numeric,
	maximumload_uom			varchar
);
COMMENT ON TYPE qgis_pkg.obj_ng_energydemand IS 'This object (type) corresponds to table ng_energydemand';

-------------------------------------------------------------------------------------
-- CREATE OBJECT (TYPE) corresponding to table ng_facilities
-------------------------------------------------------------------------------------

DROP TYPE IF EXISTS qgis_pkg.obj_ng_facilities CASCADE;
CREATE TYPE qgis_pkg.obj_ng_facilities AS (
	id				bigint,
	heatdissipation_id		bigint,
	objectclass_id			integer,
	operationschedule_id		bigint,
	usagezone_equippedwith_id	bigint
);
COMMENT ON TYPE qgis_pkg.obj_ng_facilities IS 'This object (type) corresponds to table ng_facilities';

-------------------------------------------------------------------------------------
-- CREATE OBJECT (TYPE) corresponding to table ng_floorarea
-------------------------------------------------------------------------------------

DROP TYPE IF EXISTS qgis_pkg.obj_ng_floorarea CASCADE;
CREATE TYPE qgis_pkg.obj_ng_floorarea AS (
	id				bigint,
	building_floorarea_id		bigint,
	thermalzone_floorarea_id	bigint,
	type				varchar,
	usagezone_floorarea_id		bigint,
	value				numeric,
	value_uom			varchar
);
COMMENT ON TYPE qgis_pkg.obj_ng_floorarea IS 'This object (type) corresponds to table ng_floorarea';

-------------------------------------------------------------------------------------
-- CREATE OBJECT(TYPE) corresponding to table ng_gas
-------------------------------------------------------------------------------------

DROP TYPE IF EXISTS qgis_pkg.obj_ng_gas CASCADE;
CREATE TYPE qgis_pkg.obj_ng_gas AS (
	id				bigint,
	isventilated			numeric,
	rvalue				numeric,
	rvalue_uom			varchar
);
COMMENT ON TYPE qgis_pkg.obj_ng_gas IS 'This object (type) corresponds to table ng_gas';

-------------------------------------------------------------------------------------
-- CREATE OBJECT (TYPE) corresponding to table ng_heatexchangetype
-------------------------------------------------------------------------------------

DROP TYPE IF EXISTS qgis_pkg.obj_ng_heatexchangetype CASCADE;
CREATE TYPE qgis_pkg.obj_ng_heatexchangetype AS (
	id 				bigint,
	convectivefraction		numeric,
	convectivefraction_uom		varchar,
	latentfraction			numeric,
	latentfraction_uom		varchar,
	radiantfraction			numeric,
	radiantfraction_uom		varchar,
	totalvalue			numeric,
	totalvalue_uom			varchar
);
COMMENT ON TYPE qgis_pkg.obj_ng_heatexchangetype IS 'This object (type) correposnds to table ng_heatexchangetype';

-------------------------------------------------------------------------------------
-- CREATE OBJECT (TYPE) corresponding to table ng_heightaboveground
-------------------------------------------------------------------------------------

DROP TYPE IF EXISTS qgis_pkg.obj_ng_heightaboveground CASCADE;
CREATE TYPE qgis_pkg.obj_ng_heightaboveground AS (
	id				bigint,
	building_heightabovegroun_id	bigint,
	heightreference			varchar,
	value				numeric,
	value_uom			varchar
);
COMMENT ON TYPE qgis_pkg.obj_ng_heightaboveground IS 'This object (type) corresponds to table ng_heightaboveground';

-------------------------------------------------------------------------------------
-- CREATE OBJECT (TYPE) correponding to table ng_layer
-------------------------------------------------------------------------------------

DROP TYPE IF EXISTS qgis_pkg.obj_ng_layer CASCADE;
CREATE TYPE qgis_pkg.obj_ng_layer AS (
	id				bigint,
	construction_layer_id		bigint
);
COMMENT ON TYPE qgis_pkg.obj_ng_layer IS 'This object (type) corresponds to table ng_layer';

-------------------------------------------------------------------------------------
-- CREATE OBJECT (TYPE) corresponding to table ng_layercomponent
-------------------------------------------------------------------------------------

DROP TYPE IF EXISTS qgis_pkg.obj_ng_layercomponent CASCADE;
CREATE TYPE qgis_pkg.obj_ng_layercomponent AS (
	id 				bigint,
	areafraction			numeric,
	areafraction_uom		varchar,
	layer_layercomponent_id		bigint,
	material_id			bigint,
	thickness			numeric,
	thickness_uom			varchar
);
COMMENT ON TYPE qgis_pkg.obj_ng_layercomponent IS 'This object (type) corresponds to table ng_layercomponent';

-------------------------------------------------------------------------------------
-- CREATE OBJECT (TYPE) corresponding to table ng_material
-------------------------------------------------------------------------------------

DROP TYPE IF EXISTS qgis_pkg.obj_ng_material CASCADE;
CREATE TYPE qgis_pkg.obj_ng_material AS (
	id				bigint,
	objectclass_id			bigint
);
COMMENT ON TYPE qgis_pkg.obj_ng_material IS 'This object (type) corresponds to table ng_material';

-------------------------------------------------------------------------------------
-- CREATE OBJECT (TYPE) corresponding to table ng_occupants
-------------------------------------------------------------------------------------

DROP TYPE IF EXISTS qgis_pkg.obj_ng_occupants CASCADE;
CREATE TYPE qgis_pkg.obj_ng_occupants AS (
	id				bigint,
	heatdissipation_id		bigint,
	numberofoccupants		integer,
	occupancyrate_id		bigint,
	usagezone_occupiedby_id		bigint
);
COMMENT ON TYPE qgis_pkg.obj_ng_occupants IS 'This object (type) corresponds to table ng_occupants';

-------------------------------------------------------------------------------------
-- CREATE OBJECT (TYPE) corresponding to table ng_opticalproperties
-------------------------------------------------------------------------------------

DROP TYPE IF EXISTS qgis_pkg.obj_ng_opticalproperties CASCADE;
CREATE TYPE qgis_pkg.obj_ng_opticalproperties AS (
	id				bigint,
	glazingratio			numeric,
	glazingratio_uom		varchar
);
COMMENT ON TYPE qgis_pkg.obj_ng_opticalproperties IS 'This object (type) corresponds to table ng_opticalproperties';

-------------------------------------------------------------------------------------
-- CREATE OBJECT (TYPE) corresponding to table ng_periodofyear
-------------------------------------------------------------------------------------

DROP TYPE IF EXISTS qgis_pkg.obj_ng_periodofyear CASCADE;
CREATE TYPE qgis_pkg.obj_ng_periodofyear AS (
	id				bigint,
	objectclass_id			bigint,
	schedule_periodofyear		bigint,
	timeperiodprop_beginposition	timestamp with time zone,
	timeperiodproper_endposition	timestamp with time zone
);
COMMENT ON TYPE qgis_pkg.obj_ng_periodofyear IS 'This object (type) corresponds to table ng_periodofyear';

-------------------------------------------------------------------------------------
-- CREATE OBJECT (TYPE) corresponding to table ng_reflectance
-------------------------------------------------------------------------------------

DROP TYPE IF EXISTS qgis_pkg.obj_ng_reflectance CASCADE;
CREATE TYPE qgis_pkg.obj_ng_reflectance AS (
	id				bigint,
	fraction			numeric,
	fraction_uom			varchar,
	opticalproper_reflectance_id	bigint,
	surface				varchar,
	wavelengthrange			varchar
);
COMMENT ON TYPE qgis_pkg.obj_ng_reflectance IS 'This object (type) corresponds to table ng_reflectance';

-------------------------------------------------------------------------------------
-- CREATE OBJECT (TYPE) corresponding to table ng_regulartimeseries
-------------------------------------------------------------------------------------

DROP TYPE IF EXISTS qgis_pkg.obj_ng_regulartimeseries CASCADE;
CREATE TYPE qgis_pkg.obj_ng_regulartimeseries AS (
	id				bigint,
	timeinterval			numeric,
	timeinterval_factor		integer,
	timeinterval_radix		integer,
	timeinterval_unit		varchar,
	timeperiodprop_beginposition	timestamp with time zone,
	timeperiodproper_endposition	timestamp with time zone,
	values_				text,
	values_uom			varchar
);
COMMENT ON TYPE qgis_pkg.obj_ng_regulartimeseries IS 'This object (type) corresponds to table ng_regulartimeseries';

--------------------------------------------------------------------------------------
-- CREATE OBJECT (TYPE) corresponding to table ng_regulartimeseriesfile
--------------------------------------------------------------------------------------

DROP TYPE IF EXISTS qgis_pkg.obj_ng_regulartimeseriesfile CASCADE;
CREATE TYPE qgis_pkg.obj_ng_regulartimeseriesfile AS (
	id				bigint,
	decimalsymbol			varchar,
	fieldseparator			varchar,
	file_				varchar,
	numberofheaderlines		integer,
	recordseparator			varchar,
	timeinterval			numeric,
	timeinterval_factor		integer,
	timeinterval_radix		integer,
	timeinterval_unit		varchar,
	timeperiodprop_beginposition	timestamp with time zone,
	timeperiodprop_endposition	timestamp with time zone,
	uom				varchar,
	valuecolumnnumber		integer
);
COMMENT ON TYPE qgis_pkg.obj_ng_regulartimeseriesfile IS 'This object (type) corresponds to table ng_regulartimeseriesfile';

--------------------------------------------------------------------------------------
-- CREATE OBJECT (TYPE) corresponding to table ng_schedule
--------------------------------------------------------------------------------------

DROP TYPE IF EXISTS qgis_pkg.obj_ng_schedule CASCADE;
CREATE TYPE qgis_pkg.obj_ng_schedule AS (
	id				bigint
);
COMMENT ON TYPE qgis_pkg.obj_ng_schedule is 'This object (type) corresponds to table ng_schedule';

--------------------------------------------------------------------------------------
-- CREATE OBJECT (TYPE) corresponding to table ng_solidmaterial
--------------------------------------------------------------------------------------

DROP TYPE IF EXISTS qgis_pkg.obj_ng_solidmaterial CASCADE;
CREATE TYPE qgis_pkg.obj_ng_solidmaterial AS (
	id				bigint,
	conductivity			numeric,
	conductivity_uom		varchar,
	density				numeric,
	density_uom			varchar,
	permeance			numeric,
	permeance_uom			varchar,
	specificheat			numeric,
	specificheat_uom		varchar
);
COMMENT ON TYPE qgis_pkg.obj_ng_solidmaterial IS 'This object (type) corresponds to table ng_solidmaterial';

---------------------------------------------------------------------------------------
-- CREATE OBJECT (TYPE) corresponding to table ng_ther_boun_to_ther_deli
---------------------------------------------------------------------------------------

DROP TYPE IF EXISTS qgis_pkg.obj_ng_ther_boun_to_ther_deli CASCADE;
CREATE TYPE qgis_pkg.obj_ng_ther_boun_to_ther_deli AS (
	thermalboundary_delimits_id	bigint,
	thermalzoneboundedby_id		bigint
);
COMMENT ON TYPE qgis_pkg.obj_ng_ther_boun_to_ther_deli IS 'This object (type) corresponds to table ng_ther_boun_to_ther_deli';

---------------------------------------------------------------------------------------
-- CREATE OBJECT (TYPE) corresponding to table ng_thermalboundary
---------------------------------------------------------------------------------------

DROP TYPE IF EXISTS qgis_pkg.obj_ng_thermalboundary CASCADE;
CREATE TYPE qgis_pkg.obj_ng_thermalboundary AS (
	id				bigint,
	area				numeric,
	area_uom			varchar,
	azimuth				numeric,
	azimuth_uom			varchar,
	construction_id			bigint,
	inclination			numeric,
	inclination_uom			varchar,
	surfacegeometry_id		bigint,
	thermalboundarytype		varchar,
	thermalzone_boundedby_id	bigint
);
COMMENT ON TYPE qgis_pkg.obj_ng_thermalboundary IS 'This object (type) corresponds to table ng_thermalboundary';

---------------------------------------------------------------------------------------
-- CREATE OBJECT (TYPE) corresponding to table ng_thermalopening
---------------------------------------------------------------------------------------

DROP TYPE IF EXISTS qgis_pkg.obj_ng_thermalopening CASCADE;
CREATE TYPE qgis_pkg.obj_ng_thermalopening AS (
	id				bigint,
	area				numeric,
	area_uom			varchar,
	construction_id			bigint,
	surfacegeometry_id		bigint,
	thermalboundary_contains_id	bigint
);
COMMENT ON TYPE qgis_pkg.obj_ng_thermalopening IS 'This object (type) corresponds to table ng_thermalopening';

---------------------------------------------------------------------------------------
-- CREATE OBJECT (TYPE) corresponging to table ng_thermalzone
---------------------------------------------------------------------------------------

DROP TYPE IF EXISTS qgis_pkg.obj_ng_thermalzone CASCADE;
CREATE TYPE qgis_pkg.obj_ng_thermalzone AS (
	id				bigint,
	building_thermalzone_id		bigint,
	infiltrationrate		numeric,
	infiltrationrate_uom		varchar,
	iscooled			numeric,
	isheated			numeric,
	volumegeometry_id		bigint
);
COMMENT ON TYPE qgis_pkg.obj_ng_thermalzone IS 'This object (type) corresponds to table ng_thermalzone';

---------------------------------------------------------------------------------------
-- CREATE OBJECT (TYPE) corresponding to table ng_timeseries
---------------------------------------------------------------------------------------

DROP TYPE IF EXISTS qgis_pkg.obj_ng_timeseries CASCADE;
CREATE TYPE qgis_pkg.obj_ng_timeseries AS (
	id				bigint,
	objectclass_id			bigint,
	timevaluesprop_acquisitionme	varchar,
	timevaluesprop_interpolation	varchar,
	timevaluesprop_thematicsescr	varchar,
	timevaluespropertiest_source	varchar
);
COMMENT ON TYPE qgis_pkg.obj_ng_timeseries IS 'This object (type) corresponds to table ng_timeseries';

---------------------------------------------------------------------------------------
-- CREATE OBJECT (TYPE) corresponding to table ng_timevaluesproperties
---------------------------------------------------------------------------------------

DROP TYPE IF EXISTS qgis_pkg.obj_ng_timevaluesproperties CASCADE;
CREATE TYPE qgis_pkg.obj_ng_timevaluesproperties AS (
	id				bigint,
	acquisitionmethod		varchar,
	interpolationtype		varchar,
	qualitydescription		varchar,
	source				varchar,
	thematicdescription		varchar
);
COMMENT ON TYPE qgis_pkg.obj_ng_timevaluesproperties IS 'This object (type) corresponds to table ng_timevaluesproperties';

---------------------------------------------------------------------------------------
-- CREATE OBJECT (TYPE) corresponding to table ng_transmittance
---------------------------------------------------------------------------------------

DROP TYPE IF EXISTS qgis_pkg.obj_ng_transmittance CASCADE;
CREATE TYPE qgis_pkg.obj_ng_transmittance AS (
	id				bigint,
	fraction			numeric,
	fraction_uom			varchar,
	opticalprope_transmittanc_id	bigint,
	wavelengthrange			varchar
);
COMMENT ON TYPE qgis_pkg.obj_ng_transmittance IS 'This object (type) corresponds to table ng_transmittance';

---------------------------------------------------------------------------------------
-- CREATE OBJECT (TYPE) corresponding to table ng_usagezone
---------------------------------------------------------------------------------------

DROP TYPE IF EXISTS qgis_pkg.obj_ng_usagezone CASCADE;
CREATE TYPE qgis_pkg.obj_ng_usagezone AS (
	id				bigint,
	building_usagezone_id		bigint,
	coolingschedule_id		bigint,
	heatingschedule_id		bigint,
	thermalzone_contains_id		bigint,
	usagezonetype			varchar,
	usagezonetype_codespace		varchar,
	ventilationschedule_id		bigint
);
COMMENT ON TYPE qgis_pkg.obj_ng_usagezone IS 'This object (type) corresponds to table ng_usagezone';

---------------------------------------------------------------------------------------
-- CREATE OBJECT (TYPE) corresponding to table ng_volumetype
---------------------------------------------------------------------------------------

DROP TYPE IF EXISTS qgis_pkg.obj_ng_volumetype CASCADE;	
CREATE TYPE qgis_pkg.obj_ng_volumetype AS (
	id				bigint,
	building_volume_id		bigint,
	thermalzone_volume_id		bigint,
	type				varchar,
	value				numeric,
	value_uom			varchar
);
COMMENT ON TYPE qgis_pkg.obj_ng_volumetype IS 'This object (type) corresponds to table ng_volumetype';

---------------------------------------------------------------------------------------
-- CREATE OBJECT (TYPE) corresponding to table ng_weatherdata
---------------------------------------------------------------------------------------

DROP TYPE IF EXISTS qgis_pkg.obj_ng_weatherdata CASCADE;
CREATE TYPE qgis_pkg.obj_ng_weatherdata AS (
	id				bigint,
	cityobject_weatherdata_id	bigint,
	position			geometry,
	values_id			bigint,
	weatherdatatype			varchar,
	weatherstation_parameter_id	bigint
);
COMMENT ON TYPE qgis_pkg.obj_ng_weatherdata IS 'This object (type) corresponds to table ng_weatherdata';

---------------------------------------------------------------------------------------
-- CREATE OBJECT (TYPE) corresponding to table ng_weatherstation
---------------------------------------------------------------------------------------

DROP TYPE IF EXISTS qgis_pkg.obj_ng_weatherstation CASCADE;
CREATE TYPE qgis_pkg.obj_ng_weatherstation AS (
	id 				bigint,
	genericapplicationpropertyof	text,
	position			geometry,
	stationname			varchar
);
COMMENT ON TYPE qgis_pkg.obj_ng_weatherstation IS 'This object (type) corresponds to table ng_weatherstation';

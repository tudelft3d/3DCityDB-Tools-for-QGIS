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
--	   MSc Geomatics
--	   Delft University of Technology, The Netherlands
--	   
-- 
-- ***********************************************************************
-- ***********************************************************************
--
--
-- This script installs update functions for Energy ADE tables.
-- BEWARE: Only "normal" attributes are updated: no geometries, no primary
-- keys, no foreign keys, etc.
-- These functions can be used with any cdb_schema inside the database.
-- In certain cases, some checks are carried out before the update
-- operation, e.g. on enumeration values.
--
--
-- ***********************************************************************

----------------------------------------------------------------------------
-- CREATE FUNCTION qgis_pkg.upd_t_ng_building
----------------------------------------------------------------------------

DROP FUNCTION IF EXISTS qgis_pkg.upd_t_ng_building(qgis_pkg.obj_ng_building,varchar) CASCADE;
CREATE OR REPLACE FUNCTION qgis_pkg.upd_t_ng_building(obj qgis_pkg.obj_ng_building, cdb_schema varchar)
RETURNS bigint AS $$
DECLARE
	updated_id bigint;
	conWeight_enum varchar[] := ARRAY['veryLight', 'light', 'medium','heavy']::varchar;

BEGIN	
	IF (obj.constructionweight IS NOT NULL) AND NOT(obj.constructionweight = ANY(conWeight_enum))
	THEN RAISE EXCEPTION 'constructionweight value %  must either be NULL or one of %', obj.constructionweight, conWeight_enum;
	END IF;
	
	EXECUTE format('
		UPDATE %I.ng_building AS t SET 
		buildingtype 			= $1.buildingtype,
		buildingtype_codespace  	= $1.buildingtype_codespace,
		constructionweight		= $1.constructionweight
		WHERE t.id = $1.id RETURNING id',
		cdb_schema) INTO updated_id USING obj;

	RETURN updated_id;
	EXCEPTION
		WHEN OTHERS THEN RAISE NOTICE 'qgis_pkg.upd_t_ng_building(id: %): %',obj.id,SQLERRM;
END;
$$ LANGUAGE plpgsql;
COMMENT ON FUNCTION qgis_pkg.upd_t_ng_building(qgis_pkg.obj_ng_building,varchar) IS 'Update attributes of table ng_building';
REVOKE EXECUTE ON FUNCTION qgis_pkg.upd_t_ng_building(qgis_pkg.obj_ng_building,varchar) FROM public;

-----------------------------------------------------------------------------
-- CREATE FUNCTION qgis_pkg.upd_t_ng_cityobject
-----------------------------------------------------------------------------

DROP FUNCTION IF EXISTS    qgis_pkg.upd_t_ng_cityobject(qgis_pkg.obj_ng_cityobject,varchar) CASCADE;
CREATE OR REPLACE FUNCTION qgis_pkg.upd_t_ng_cityobject(obj qgis_pkg.obj_ng_cityobject,cdbschema varchar)
RETURNS bigint AS $$
DECLARE 
	updated_id bigint;

BEGIN
	updated_id := obj.id;
	
	RETURN updated_id;
	EXCEPTION
		WHEN OTHERS THEN RAISE NOTICE 'qgis_pkg.upd_t_ng_cityobject(id: %) : %',obj.id,SQLERRM;
END;
$$ LANGUAGE plpgsql;
COMMENT ON FUNCTION qgis_pkg.upd_t_ng_cityobject(qgis_pkg.obj_ng_cityobject,varchar) IS 'Update attribute of table ng_cityobject';
REVOKE EXECUTE ON FUNCTION qgis_pkg.upd_t_ng_cityobject(qgis_pkg.obj_ng_cityobject,varchar) FROM public;

------------------------------------------------------------------------------
-- CREATE FUNCTION qgis_pkg.upd_t_ng_construction
------------------------------------------------------------------------------

DROP FUNCTION IF EXISTS qgis_pkg.upd_t_ng_construction(qgis_pkg.obj_ng_construction,varchar) CASCADE;
CREATE OR REPLACE FUNCTION qgis_pkg.upd_t_ng_construction(obj qgis_pkg.obj_ng_construction,cdbschema varchar)
RETURNS bigint AS $$
DECLARE
	updated_id bigint;

BEGIN
	IF (obj.uvalue IS NOT NULL) AND (obj.uvalue_uom IS NULL) 
	THEN RAISE EXCEPTION 'uvalue_uom must not be NULL';
	END IF;

	IF (obj.uvalue_uom IS NOT NULL) AND (obj.uvalue IS NULL)
	THEN RAISE EXCEPTION 'uvalue must not be NULL';
	END IF;
	
	EXECUTE format('
		UPDATE %I.ng_construction AS t SET 
		uvalue				= $1.uvalue,
		uvalue_uom			= $1.uvalue_uom
		WHERE t.id = $1.id RETURNING id',
		cdbschema) INTO updated_id USING obj;

	RETURN updated_id;
	EXCEPTION
		WHEN OTHERS THEN RAISE NOTICE 'qgis_pkg.upd_t_ng_construction(id: %): %',obj.id,SQLERRM;
END;
$$ LANGUAGE plpgsql;
COMMENT ON FUNCTION qgis_pkg.upd_t_ng_construction(qgis_pkg.obj_ng_construction,varchar) IS 'Update attributes of table ng_construction';
REVOKE EXECUTE ON FUNCTION qgis_pkg.upd_t_ng_construction(qgis_pkg.obj_ng_construction,varchar) FROM public;

-------------------------------------------------------------------------------
-- CREATE FUNCTION qgis_pkg.upd_t_ng_dailyschedule
-------------------------------------------------------------------------------

DROP FUNCTION IF EXISTS qgis_pkg.upd_t_ng_dailyschedule(qgis_pkg.obj_ng_dailyschedule,varchar) CASCADE;
CREATE OR REPLACE FUNCTION qgis_pkg.upd_t_ng_dailyschedule(obj qgis_pkg.obj_ng_dailyschedule, cdbschema varchar)
RETURNS bigint AS $$
DECLARE
	updated_id bigint;
	dayTypeValue_enum varchar[] := ARRAY['monday','tuesday','wednesday','thursday','friday','saturday','sunday','designDay','weekDay','weekEnd','typicalDay'];

BEGIN
	IF (obj.daytype IS NOT NULL) AND NOT(obj.daytype = ANY(dayTypeValue_enum))
	THEN RAISE EXCEPTION 'daytype value % must be NULL or one of %', obj.daytype,dayTypeValue_enum;
        END IF;
        
	EXECUTE format('
		UPDATE %I.ng_dailyschedule as t SET
		daytype				= $1.daytype
		WHERE t.id = $1.id RETURNING id',
		cdbschema) INTO updated_id USING obj;
                 
	RETURN updated_id;
	EXCEPTION
		WHEN OTHERS THEN RAISE NOTICE 'qgis_pkg.upd_t_ng_dailyschedule(id: %): %',obj.id,SQLERRM;
END;
$$LANGUAGE plpgsql;
COMMENT ON FUNCTION qgis_pkg.upd_t_ng_dailyschedule(qgis_pkg.obj_ng_dailyschedule,varchar) IS 'Update attributes of table ng_dailyschedule';
REVOKE EXECUTE ON FUNCTION qgis_pkg.upd_t_ng_dailyschedule(qgis_pkg.obj_ng_dailyschedule,varchar) FROM public;

--------------------------------------------------------------------------------
-- CREATE FUNCTION qgis_pkg.upd_t_ng_energydem_to_cityobjec
--------------------------------------------------------------------------------

DROP FUNCTION IF EXISTS qgis_pkg.upd_t_ng_energydem_to_cityobjec(qgis_pkg.obj_ng_energydem_to_cityobjec,varchar) CASCADE;
CREATE OR REPLACE FUNCTION qgis_pkg.upd_t_ng_energydem_to_cityobjec(obj qgis_pkg.obj_ng_energydem_to_cityobjec, cdbschema varchar)
RETURNS bigint AS $$
DECLARE
	updated_id bigint;

BEGIN
	updated_id := obj.energydemand_id;
	RETURN updated_id;
	EXCEPTION
		WHEN OTHERS THEN RAISE NOTICE 'qgis_pkg.upd_t_ng_energydem_to_cityobjec(id: %): %',obj.id,SQLERRM;
END;
$$LANGUAGE plpgsql;
COMMENT ON FUNCTION qgis_pkg.upd_t_ng_energydem_to_cityobjec(qgis_pkg.obj_ng_energydem_to_cityobjec,varchar) IS 'Update attributes of ng_energydem_to_cityobjec';
REVOKE EXECUTE ON FUNCTION qgis_pkg.upd_t_ng_energydem_to_cityobjec(qgis_pkg.obj_ng_energydem_to_cityobjec,varchar) FROM public;

-------------------------------------------------------------------------------
-- CREATE FUNCTION qgis_pkg.upd_t_ng_energydemand
-------------------------------------------------------------------------------

DROP FUNCTION IF EXISTS qgis_pkg.upd_t_ng_energydemand(qgis_pkg.obj_ng_energydemand,varchar) CASCADE;
CREATE OR REPLACE FUNCTION qgis_pkg.upd_t_ng_energydemand(obj qgis_pkg.obj_ng_energydemand,cdbschema varchar) 
RETURNS bigint AS $$
DECLARE 
	updated_id bigint;
	enduseType_enum varchar[] := ARRAY['cooking','domesticHotWater','electricalAppliances','lighting','otherOrCombination','spaceCooling','spaceHeating','ventilation','process'];

BEGIN
	IF (obj.maximumload IS NOT NULL) AND (obj.maximumload_uom IS NULL)
	THEN RAISE EXCEPTION 'maximumload must have a unit of measure';
	END IF;
	
	IF (obj.maximumload IS NULL) AND (obj.maximumload_uom IS NOT NULL)
	THEN RAISE EXCEPTION 'maximumload_uom must have a number';
	END IF;

	IF (obj.enduse IS NOT NULL) AND NOT(obj.enduse = ANY(enduseType_enum))
	THEN RAISE EXCEPTION 'enduse value % must either be NULL or one of %',obj.enduse,enduseType_enum;
	END IF;

	EXECUTE format('
		UPDATE %I.ng_energydemand AS t SET
		enduse				= $1.enduse,
		energycarriertype		= $1.energycarriertype,
		energycarriertype_codespace	= $1.energycarriertype_codespace,
		maximumload			= $1.maximumload,
		maximumload_uom			= $1.maximumload_uom
		WHERE t.id = $1.id RETURNING id',
		cdbschema) INTO updated_id USING obj;
	
	RETURN updated_id;
	EXCEPTION
		WHEN OTHERS THEN RAISE NOTICE 'qgis_pkg.upd_t_ng_energydemand(id: %): %',obj.id,SQLERRM;
END;
$$LANGUAGE plpgsql;
COMMENT ON FUNCTION qgis_pkg.upd_t_ng_energydemand(qgis_pkg.obj_ng_energydemand,varchar) IS 'Update attributes of table ng_energydemand';
REVOKE EXECUTE ON FUNCTION qgis_pkg.upd_t_ng_energydemand(qgis_pkg.obj_ng_energydemand,varchar) FROM public;

--------------------------------------------------------------------------
-- CREATE FUNCTION qgis_pkg.upd_t_ng_facilities
--------------------------------------------------------------------------

DROP FUNCTION IF EXISTS qgis_pkg.upd_t_ng_facilities(qgis_pkg.obj_ng_facilities,varchar) CASCADE;
CREATE OR REPLACE FUNCTION qgis_pkg.upd_t_ng_facilities(obj qgis_pkg.obj_ng_facilities,cdbschema varchar)
RETURNS bigint AS $$
DECLARE
	updated_id bigint;

BEGIN
	updated_id := obj.id;
	RETURN updated_id;
	EXCEPTION
		WHEN OTHERS THEN RAISE NOTICE 'qgis_pkg.upd_t_ng_facilities(id: %): %',obj.id,SQLERRM;
END;
$$LANGUAGE plpgsql;
COMMENT ON FUNCTION qgis_pkg.upd_t_ng_facilities(qgis_pkg.obj_ng_facilities,varchar) IS 'Returns id of ng_facilities record';
REVOKE EXECUTE ON FUNCTION qgis_pkg.upd_t_ng_facilities(qgis_pkg.obj_ng_facilities,varchar) FROM public;

--------------------------------------------------------------------------
--CREATE FUNCTION qgis_pkg.upd_t_ng_floorarea
--------------------------------------------------------------------------

DROP FUNCTION IF EXISTS qgis_pkg.upd_t_ng_floorarea(qgis_pkg.obj_ng_floorarea,varchar) CASCADE;
CREATE OR REPLACE FUNCTION qgis_pkg.upd_t_ng_floorarea(obj qgis_pkg.obj_ng_floorarea,cdbschema varchar)
RETURNS bigint AS $$
DECLARE
	updated_id bigint;
	floorArea_enum varchar[] := ARRAY['netFloorArea','grossFloorArea','energyReferenceArea'];

BEGIN
	IF (obj.value IS NOT NULL) AND (obj.value_uom IS NULL)
	THEN RAISE EXCEPTION 'value must have a measure unit';
	END IF;

	IF (obj.value IS NULL) AND (obj.value_uom IS NOT NULL)
	THEN RAISE EXCEPTION 'measure unit must have a value';
	END IF;

	IF (obj.type IS NOT NULL) AND NOT(obj.type = ANY(floorArea_enum))
	THEN RAISE EXCEPTION 'type value % must either be NULL or one of %',obj.type,floorArea_enum;	
	END IF;

	EXECUTE format('
		UPDATE %I.ng_floorarea AS t SET
		type				= $1.type,
		value				= $1.value,
		value_uom			= $1.value_uom
		WHERE t.id = $1.id RETURNING id',
		cdbschema) INTO updated_id USING obj;
	
	RETURN updated_id;
	EXCEPTION
		WHEN OTHERS THEN RAISE NOTICE 'qgis_pkg.upd_t_ng_floorarea(id: %): %',obj.id,SQLERRM;	
END;
$$LANGUAGE plpgsql;
COMMENT ON FUNCTION qgis_pkg.upd_t_ng_floorarea(qgis_pkg.obj_ng_floorarea,varchar) IS 'Update attributes of table ng_floorarea';
REVOKE EXECUTE ON FUNCTION qgis_pkg.upd_t_ng_floorarea(qgis_pkg.obj_ng_floorarea,varchar) FROM public;

-------------------------------------------------------------------
-- CREATE FUNCTION qgis_pkg.upd_t_ng_gas
-------------------------------------------------------------------

DROP FUNCTION IF EXISTS qgis_pkg.upd_t_ng_gas(qgis_pkg.obj_ng_gas,varchar) CASCADE;
CREATE OR REPLACE FUNCTION qgis_pkg.upd_t_ng_gas(obj qgis_pkg.obj_ng_gas,cdbschema varchar)
RETURNS bigint AS $$
DECLARE
	updated_id bigint;

BEGIN
	IF ((obj.rvalue IS NOT NULL) AND (obj.rvalue_uom IS NULL))
	OR ((obj.rvalue IS NULL) AND (obj.rvalue_uom IS NOT NULL))
	THEN RAISE EXCEPTION 'rvalue must have a number and measure unit';
	END IF;

	IF (obj.isventilated IS NOT NULL) AND (obj.isventilated > 1)
	THEN RAISE EXCEPTION 'isventilated must either be 0 or 1';
	END IF;

	EXECUTE format('
		UPDATE %I.ng_gas AS t SET 
		isventilated			= $1.isventilated,
		rvalue 				= $1.rvalue,
		rvalue_uom			= $1.rvalue_uom
		WHERE t.id = $1.id RETURNING id',
		cdbschema) INTO updated_id USING obj;
	
	RETURN updated_id;
	EXCEPTION
		WHEN OTHERS THEN RAISE NOTICE 'qgis_pkg.upd_t_ng_gas(id: %): %',obj.id,SQLERRM;
END;
$$LANGUAGE plpgsql;
COMMENT ON FUNCTION qgis_pkg.upd_t_ng_gas(qgis_pkg.obj_ng_gas,varchar) IS 'Update attributes of table ng_gas';
REVOKE EXECUTE ON FUNCTION qgis_pkg.upd_t_ng_gas(qgis_pkg.obj_ng_gas,varchar) FROM public;

---------------------------------------------------------------------
-- CREATE FUNCTION qgis_pkg.upd_t_ng_heatexchangetype
---------------------------------------------------------------------

DROP FUNCTION IF EXISTS qgis_pkg.upd_t_ng_heatexchangetype(qgis_pkg.obj_ng_heatexchangetype,varchar) CASCADE;
CREATE OR REPLACE FUNCTION qgis_pkg.upd_t_ng_heatexchangetype(obj qgis_pkg.obj_ng_heatexchangetype,cdbschema varchar)
RETURNS bigint AS $$
DECLARE 
	updated_id bigint;

BEGIN
	IF ((obj.convectivefraction IS NOT NULL) AND (obj.convectivefraction_uom IS NULL))
	OR ((obj.convectivefraction IS NULL) AND (obj.convectivefraction_uom IS NOT NULL))
	THEN RAISE EXCEPTION 'convectivefraction must have a number and measure unit';
	END IF;
	
	IF ((obj.latentfraction IS NOT NULL) AND (obj.latentfraction_uom IS NULL))
        OR ((obj.latentfraction IS NULL) AND (obj.latentfraction_uom IS NOT NULL))
        THEN RAISE EXCEPTION 'latentfraction must have a number and measure unit';
        END IF;

	IF ((obj.radiantfraction IS NOT NULL) AND (obj.radiantfraction_uom IS NULL))
        OR ((obj.radiantfraction IS NULL) AND (obj.radiantfraction_uom IS NOT NULL))
        THEN RAISE EXCEPTION 'radiantfraction must have a number and measure unit';
        END IF;

	IF ((obj.totalvalue IS NOT NULL) AND (obj.totalvalue_uom IS NULL))
        OR ((obj.totalvalue IS NULL) AND (obj.totalvalue_uom IS NOT NULL))
        THEN RAISE EXCEPTION 'totalvalue must have a number and measure unit';
        END IF;

        EXECUTE format('
		UPDATE %I.ng_heatexchangetype AS t SET 
		convectivefraction		= $1.convectivefraction,
		convectivefraction_uom		= $1.convectivefraction_uom,
		latentfraction			= $1.latentfraction,
		latentfraction_uom		= $1.latentfraction_uom,
		radiantfraction			= $1.radiantfraction,
		radiantfraction_uom		= $1.radiantfraction_uom,
		totalvalue			= $1.totalvalue,
		totalvalue_uom			= $1.totalvalue_uom
		WHERE t.id = $1.id RETURNING id',
		cdbschema) INTO updated_id USING obj;

	RETURN updated_id;
	EXCEPTION 
		WHEN OTHERS THEN RAISE NOTICE 'qgis_pkg.upd_t_ng_heatexchangetype(id: %): %',obj.id,SQLERRM;
END;
$$LANGUAGE plpgsql;
COMMENT ON FUNCTION qgis_pkg.upd_t_ng_heatexchangetype(qgis_pkg.obj_ng_heatexchangetype,varchar) IS 'Updates attributes of table ng_heatexchangetype';
REVOKE EXECUTE ON FUNCTION qgis_pkg.upd_t_ng_heatexchangetype(qgis_pkg.obj_ng_heatexchangetype,varchar) FROM public;

----------------------------------------------------------------------
-- CREATE FUNCTION qgis_pkg.upd_t_ng_heightaboveground
----------------------------------------------------------------------

DROP FUNCTION IF EXISTS qgis_pkg.upd_t_ng_heightaboveground(qgis_pkg.obj_ng_heightaboveground,varchar) CASCADE;
CREATE OR REPLACE FUNCTION qgis_pkg.upd_t_ng_heightaboveground(obj qgis_pkg.obj_ng_heightaboveground, cdbschema varchar)
RETURNS bigint AS $$
DECLARE
	updated_id bigint;
	elevRef_enum varchar[] := ARRAY['bottomOfConstruction','entrancePoint','generalEave','generalRoof','generalRoofEdge',
					'highestEave','highestPoint','lowestEave','lowestFloorAboveGround','lowestRoofEdge',
					'topOfConstruction','topThermalBoundary','bottomThermalBoundary'];
BEGIN
	IF ((obj.value IS NOT NULL) AND (obj.value_uom IS NULL))
        OR ((obj.value IS NULL) AND (obj.value_uom IS NOT NULL))
        THEN RAISE EXCEPTION 'heightaboveground must have a number and measure unit';
        END IF;
	
	IF (obj.heightreference IS NOT NULL) AND NOT(obj.heightreference = ANY(elevRef_enum))
	THEN RAISE EXCEPTION 'heightreference % must either be NULL or one of %',obj.heightreference,elevRef_enum;
	END IF;

	EXECUTE format('
		UPDATE %I.ng_heightaboveground AS t SET
		heightreference			= $1.heightreference,
		value				= $1.value,
		value_uom			= $1.value_uom
		WHERE t.id = $1.id RETURNING id',
		cdbschema) INTO updated_id USING obj;
	RETURN updated_id;
	EXCEPTION
		WHEN OTHERS THEN RAISE NOTICE 'qgis_pkg.upd_t_ng_heightaboveground(id: %): %',obj.id,SQLERRM;
END;
$$LANGUAGE plpgsql;
COMMENT ON FUNCTION qgis_pkg.upd_t_ng_heightaboveground(qgis_pkg.obj_ng_heightaboveground,varchar) IS 'Updates attributes of ng_heightaboveground';
REVOKE EXECUTE ON FUNCTION qgis_pkg.upd_t_ng_heightaboveground(qgis_pkg.obj_ng_heightaboveground,varchar) FROM public;

--------------------------------------------------------------------
-- CREATE FUNCTION qgis_pkg.upd_t_ng_layer
--------------------------------------------------------------------

DROP FUNCTION IF EXISTS qgis_pkg.upd_t_ng_layer(qgis_pkg.obj_ng_layer,varchar) CASCADE;
CREATE OR REPLACE FUNCTION qgis_pkg.upd_t_ng_layer(obj qgis_pkg.obj_ng_layer,cdbschema varchar)
RETURNS bigint AS $$
DECLARE 
	updated_id bigint;

BEGIN 
	updated_id := obj.id;
	RETURN updated_id;
	EXCEPTION
		WHEN OTHERS THEN RAISE NOTICE 'qgis_pkg.upd_t_ng_layer(id: %): %',obj.id,SQLERRM;
END;
$$LANGUAGE plpgsql;
COMMENT ON FUNCTION qgis_pkg.upd_t_ng_layer(qgis_pkg.obj_ng_layer,varchar) IS 'Returns id of ng_layer record';
REVOKE EXECUTE ON FUNCTION qgis_pkg.upd_t_ng_layer(qgis_pkg.obj_ng_layer,varchar) FROM public;

-------------------------------------------------------------------
-- CREATE FUNCTION qgis_pkg.upd_t_ng_layercomponent
-------------------------------------------------------------------

DROP FUNCTION IF EXISTS qgis_pkg.upd_t_ng_layercomponent(qgis_pkg.obj_ng_layercomponent,varchar) CASCADE;
CREATE OR REPLACE FUNCTION qgis_pkg.upd_t_ng_layercomponent(obj qgis_pkg.obj_ng_layercomponent,cdbschema varchar)
RETURNS bigint AS $$
DECLARE
	updated_id bigint;

BEGIN
	IF ((obj.areafraction IS NOT NULL) AND (obj.areafraction_uom IS NULL))
        OR ((obj.areafraction IS NULL) AND (obj.areafraction_uom IS NOT NULL))
        THEN RAISE EXCEPTION 'areafraction must have a number and measure unit';
        END IF;

	IF ((obj.thickness IS NOT NULL) AND (obj.thickness_uom IS NULL))
        OR ((obj.thickness IS NULL) AND (obj.thickness_uom IS NOT NULL))
        THEN RAISE EXCEPTION 'thickness must have a number and measure unit';
        END IF;

	EXECUTE format('
		UPDATE %I.ng_layercomponent AS t SET
		areafraction			= $1.areafraction,
		areafraction_uom		= $1.areafraction_uom,
		thickness			= $1.thickness,
		thickness_uom			= $1.thickness_uom
		WHERE t.id = $1.id RETURNING id',
		cdbschema) INTO updated_id USING obj;

	RETURN updated_id;
	EXCEPTION
		WHEN OTHERS THEN RAISE NOTICE 'qgis_pkg.upd_t_ng_layercomponent(id: %): %',obj.id,SQLERRM;
END;
$$LANGUAGE plpgsql;
COMMENT ON FUNCTION qgis_pkg.upd_t_ng_layercomponent(qgis_pkg.obj_ng_layercomponent,varchar) IS 'Updates attributes of table ng_layercomponent';
REVOKE EXECUTE ON FUNCTION qgis_pkg.upd_t_ng_layercomponent(qgis_pkg.obj_ng_layercomponent,varchar) FROM public;


-------------------------------------------------------------------------
-- CREATE FUNCTION qgis_pkg.upd_t_ng_occupants
-------------------------------------------------------------------------

DROP FUNCTION IF EXISTS qgis_pkg.upd_t_ng_occupants(qgis_pkg.obj_ng_occupants,varchar) CASCADE;
CREATE OR REPLACE FUNCTION qgis_pkg.upd_t_ng_occupants(obj qgis_pkg.obj_ng_occupants,cdbschema varchar)
RETURNS bigint AS $$
DECLARE 
	updated_id bigint;

BEGIN
	EXECUTE format('
		UPDATE %I.ng_occupants AS t SET
		numberofoccupants = $1.numberofoccupants
		WHERE t.id = $1.id RETURNING id',
		cdbschema) INTO updated_id USING obj;
	RETURN updated_id;
	EXCEPTION
		WHEN OTHERS THEN RAISE NOTICE 'qgis_pkg.upd_t_ng_occupants(id: %): %',obj.id,SQLERRM;
END;
$$LANGUAGE plpgsql;
COMMENT ON FUNCTION qgis_pkg.upd_t_ng_occupants(qgis_pkg.obj_ng_occupants,varchar) IS 'Returns id of ng_occupants record';
REVOKE EXECUTE ON FUNCTION qgis_pkg.upd_t_ng_occupants(qgis_pkg.obj_ng_occupants,varchar) FROM public;

--------------------------------------------------------------------------
-- CREATE FUNCTION qgis_pkg.upd_t_ng_opticalproperties
--------------------------------------------------------------------------

DROP FUNCTION IF EXISTS qgis_pkg.upd_t_ng_opticalproperties(qgis_pkg.obj_ng_opticalproperties,varchar) CASCADE;
CREATE OR REPLACE FUNCTION qgis_pkg.upd_t_ng_opticalproperties(obj qgis_pkg.obj_ng_opticalproperties,cdbschema varchar)
RETURNS bigint AS $$
DECLARE
        updated_id bigint;

BEGIN
	EXECUTE format('
		UPDATE %I.ng_opticalproperties AS t SET
		glazingratio			= $1.glazingratio,
		glazingratio_uom		= $1.glazingratio_uom
		WHERE t.id = $1.id RETURNING id',
		cdbschema) INTO updated_id USING obj;
        RETURN updated_id;
        EXCEPTION
                WHEN OTHERS THEN RAISE NOTICE 'qgis_pkg.upd_t_ng_opticalproperties(id: %): %',obj.id,SQLERRM;
END;
$$LANGUAGE plpgsql;
COMMENT ON FUNCTION  qgis_pkg.upd_t_ng_opticalproperties(qgis_pkg.obj_ng_opticalproperties,varchar) IS 'Returns id of ng_opticalproperties record';
REVOKE EXECUTE ON FUNCTION qgis_pkg.upd_t_ng_opticalproperties(qgis_pkg.obj_ng_opticalproperties,varchar) FROM public;

--------------------------------------------------------------------------
-- CREATE FUNCTION qgis_pkg.upd_t_ng_periodofyear
--------------------------------------------------------------------------

DROP FUNCTION IF EXISTS qgis_pkg.upd_t_ng_periodofyear(qgis_pkg.obj_ng_periodofyear,varchar) CASCADE;
CREATE OR REPLACE FUNCTION qgis_pkg.upd_t_ng_periodofyear(obj qgis_pkg.obj_ng_periodofyear,cdbschema varchar)
RETURNS bigint AS $$
DECLARE
	updated_id bigint;

BEGIN
	EXECUTE format('
		UPDATE %I.ng_periodofyear AS t SET
		timeperiodprop_beginposition	= $1.timeperiodprop_beginposition,
		timeperiodproper_endposition	= $1.timeperiodproper_endposition
		WHERE t.id = $1.id RETURNING id',
		cdbschema) INTO updated_id USING obj;
	RETURN updated_id;
	EXCEPTION
		WHEN OTHERS THEN RAISE NOTICE 'qgis_pkg.upd_t_ng_periodofyear(id: %_: %',obj.id,SQLERRM;
END;
$$LANGUAGE plpgsql;
COMMENT ON FUNCTION qgis_pkg.upd_t_ng_periodofyear(qgis_pkg.obj_ng_periodofyear,varchar) IS 'Updates attributes of table ng_periodofyear';
REVOKE EXECUTE ON FUNCTION qgis_pkg.upd_t_ng_periodofyear(qgis_pkg.obj_ng_periodofyear,varchar) FROM public;

---------------------------------------------------------------------------
-- CREATE FUNCTION qgis_pkg.upd_t_ng_reflectance
---------------------------------------------------------------------------

DROP FUNCTION IF EXISTS qgis_pkg.upd_t_ng_reflectance(qgis_pkg.obj_ng_reflectance,varchar) CASCADE;
CREATE OR REPLACE FUNCTION qgis_pkg.upd_t_ng_reflectance(obj qgis_pkg.obj_ng_reflectance,cdbschema varchar)
RETURNS bigint AS $$
DECLARE
	updated_id bigint;
	waveLen_enum varchar[] := ARRAY['solar','infrared','visible','total'];
	surface_enum varchar[] := ARRAY['inside','outside'];

BEGIN
	IF (obj.surface IS NOT NULL) AND NOT(obj.surface = ANY(surface_enum))
	THEN RAISE EXCEPTION 'surface % must either be NULL or one of %',obj.surface,surface_enum;
	END IF;

	IF (obj.wavelengthrange IS NOT NULL) AND NOT(obj.wavelengthrange = ANY(waveLen_enum))
        THEN RAISE EXCEPTION 'wavelengthrange % must either be NULL or one of %',obj.wavelengthrange,waveLen_enum;
        END IF;

	IF ((obj.fraction IS NOT NULL) AND (obj.fraction_uom IS NULL))
        OR ((obj.fraction IS NULL) AND (obj.fraction_uom IS NOT NULL))
        THEN RAISE EXCEPTION 'fraction must have a number and measure unit';
        END IF;

	EXECUTE format('
		UPDATE %I.ng_reflectance AS t SET
		fraction 			= $1.fraction,
		fraction_uom			= $1.fraction_uom,
		surface				= $1.surface,
		wavelengthrange			= $1.wavelengthrange
		WHERE t.id = $1.id RETURNING id',
		cdbschema) INTO updated_id USING obj;
	RETURN updated_id;
	EXCEPTION
		WHEN OTHERS THEN RAISE NOTICE 'qgis_pkg.upd_t_ng_reflectance(id: %): %',obj.id,SQLERRM;
END;
$$LANGUAGE plpgsql;
COMMENT ON FUNCTION qgis_pkg.upd_t_ng_reflectance(qgis_pkg.obj_ng_reflectance,varchar) IS 'Updates attributes of table ng_reflectance';
REVOKE EXECUTE ON FUNCTION qgis_pkg.upd_t_ng_reflectance(qgis_pkg.obj_ng_reflectance,varchar) FROM public;

--------------------------------------------------------------------------
-- CREATE FUNCTION qgis_pkg.upd_t_ng_regulartimeseries
--------------------------------------------------------------------------

DROP FUNCTION IF EXISTS qgis_pkg.upd_t_ng_regulartimeseries(qgis_pkg.obj_ng_regulartimeseries,varchar) CASCADE;
CREATE OR REPLACE FUNCTION qgis_pkg.upd_t_ng_regulartimeseries(obj qgis_pkg.obj_ng_regulartimeseries,cdbschema varchar)
RETURNS bigint AS $$
DECLARE
	updated_id bigint;

BEGIN
	IF ((obj.values_ IS NOT NULL) AND (obj.values_uom IS NULL))
        OR ((obj.values_ IS NULL) AND (obj.values_uom IS NOT NULL))
        THEN RAISE EXCEPTION 'values_ must have a number and measure unit';
        END IF;

	EXECUTE format('
		UPDATE %I.ng_regulartimeseries AS t SET 
		timeinterval			= $1.timeinterval,
		timeinterval_factor		= $1.timeinterval_factor,
		timeinterval_radix		= $1.timeinterval_radix,
		timeinterval_unit		= $1.timeinterval_unit,
		values_				= $1.values_,
		values_uom			= $1.values_uom
		WHERE t.id = $1.id RETURNING id',
		cdbschema) INTO updated_id USING obj;
	RETURN updated_id;
	EXCEPTION
		WHEN OTHERS THEN RAISE NOTICE 'qgis_pkg.upd_t_ng_regulartimeseries(id: %): %',obj.id,SQLERRM;
END;
$$LANGUAGE plpgsql;
COMMENT ON FUNCTION qgis_pkg.upd_t_ng_regulartimeseries(qgis_pkg.obj_ng_regulartimeseries,varchar) IS 'Updates attributes of table ng_regulartimeseries';
REVOKE EXECUTE ON FUNCTION qgis_pkg.upd_t_ng_regulartimeseries(qgis_pkg.obj_ng_regulartimeseries,varchar) FROM public;

---------------------------------------------------------------------
-- CREATE FUNCTION qgis_pkg.upd_t_ng_regulartimeseriesfile
---------------------------------------------------------------------

DROP FUNCTION IF EXISTS qgis_pkg.upd_t_ng_regulartimeseriesfile(qgis_pkg.obj_ng_regulartimeseriesfile,varchar) CASCADE;
CREATE OR REPLACE FUNCTION qgis_pkg.upd_t_ng_regulartimeseriesfile(obj qgis_pkg.obj_ng_regulartimeseriesfile,cdbschema varchar) 
RETURNS bigint AS $$
DECLARE
	updated_id bigint;

BEGIN
	IF (obj.numberofheaderlines IS NULL)
	THEN obj.numberofheaderlines := 0;
	END IF;

	IF (obj.recordseparator IS NULL)
	THEN obj.recordseparator := "\n";
	END IF;

	IF (obj.decimalsymbol IS NULL)
	THEN obj.decimalsymbol := ".";
	END IF;
	
	IF (obj.valuecolumnnumber IS NULL)
	THEN obj.valuecolumnnumber := 1;
	END IF;

	IF (obj.uom IS NULL) THEN RAISE EXCEPTION 'regulartimeseriefile must have a measure unit';
	END IF;

	EXECUTE format('
		UPDATE %I.ng_regulartimeseriesfile AS t SET
		decimalsymbol 			= $1.decimalsymbol,
		fieldseparator			= $1.fieldseparator,
		file_				= $1.file_,
		numberofheaderlines		= $1.numberofheaderlines,
		recordseparator			= $1.recordseparator,
		timeinterval			= $1.timeinterval,
		timeinterval_factor		= $1.timeinterval_factor,
		timeinterval_radix 		= $1.timeinterval_radix,
		timeinterval_unit		= $1.timeinterval_unit,
		timeperiodprop_beginposition	= $1.timeperiodprop_beginposition,
		timeperiodproper_endposition	= $1.timeperiodproper_endposition,
		uom				= $1.uom,
		valuecolumnnumber		= $1.valuecolumnnumber
		WHERE t.id = $1.id RETURNING id',
		cdbschema) INTO updated_id USING obj;
	RETURN updated_id;
	EXCEPTION
		WHEN OTHERS THEN RAISE NOTICE 'qgis_pkg.upd_t_ng_regulartimeseriesfile(id: %): %',obj.id,SQLERRM;
END;
$$LANGUAGE plpgsql;
COMMENT ON FUNCTION qgis_pkg.upd_t_ng_regulartimeseriesfile(qgis_pkg.obj_ng_regulartimeseriesfile,varchar) IS 'Updates attributes of table ng_regulartimeseriesfile';
REVOKE EXECUTE ON FUNCTION qgis_pkg.upd_t_ng_regulartimeseriesfile(qgis_pkg.obj_ng_regulartimeseriesfile,varchar) FROM public;

---------------------------------------------------------------------------
-- CREATE FUNCTION qgis_pkg.upd_t_ng_schedule
---------------------------------------------------------------------------

DROP FUNCTION IF EXISTS qgis_pkg.upd_t_ng_schedule(qgis_pkg.obj_ng_schedule,varchar) CASCADE;
CREATE OR REPLACE FUNCTION qgis_pkg.upd_t_ng_schedule(obj qgis_pkg.obj_ng_schedule,cdbschema varchar)
RETURNS bigint AS $$
DECLARE
	updated_id bigint;

BEGIN
	updated_id := obj.id;
	RETURN updated_id;
	EXCEPTION
		WHEN OTHERS THEN RAISE NOTICE 'qgis_pkg.upd_t_ng_schedule(id: %): %',obj.id,SQLERRM;
END;
$$LANGUAGE plpgsql;
COMMENT ON FUNCTION qgis_pkg.upd_t_ng_schedule(qgis_pkg.obj_ng_schedule,varchar) IS 'Returns id of ng_schedule record';
REVOKE EXECUTE ON FUNCTION qgis_pkg.upd_t_ng_schedule(qgis_pkg.obj_ng_schedule,varchar) FROM public;

--------------------------------------------------------------------------
-- CREATE FUNCTION qgis_pkg.upd_t_ng_solidmaterial
--------------------------------------------------------------------------

DROP FUNCTION IF EXISTS qgis_pkg.upd_t_ng_solidmaterial(qgis_pkg.obj_ng_solidmaterial,varchar) CASCADE;
CREATE OR REPLACE FUNCTION qgis_pkg.upd_t_ng_solidmaterial(obj qgis_pkg.obj_ng_solidmaterial,cdbschema varchar)
RETURNS bigint AS $$
DECLARE
	updated_id bigint;
BEGIN
	IF ((obj.conductivity IS NOT NULL) AND (obj.conductivity_uom IS NULL))
        OR ((obj.conductivity IS NULL) AND (obj.conductivity_uom IS NOT NULL))
        THEN RAISE EXCEPTION 'conductivity must have a number and measure unit';
        END IF;

	IF ((obj.density IS NOT NULL) AND (obj.density_uom IS NULL))
        OR ((obj.density IS NULL) AND (obj.density_uom IS NOT NULL))
        THEN RAISE EXCEPTION 'density must have a number and measure unit';
        END IF;

	IF ((obj.permeance IS NOT NULL) AND (obj.permeance_uom IS NULL))
        OR ((obj.permeance IS NULL) AND (obj.permeance_uom IS NOT NULL))
        THEN RAISE EXCEPTION 'permeance must have a number and measure unit';
        END IF;

	IF ((obj.specificheat IS NOT NULL) AND (obj.specificheat_uom IS NULL))
        OR ((obj.specificheat IS NULL) AND (obj.specificheat_uom IS NOT NULL))
        THEN RAISE EXCEPTION 'specificheat must have a number and measure unit';
        END IF;
	
	EXECUTE format('
		UPDATE %I.ng_solidmaterial AS t SET
		conductivity			= $1.conductivity,
		conductivity_uom		= $1.conductivity_uom,
		density				= $1.density,
		density_uom			= $1.density_uom,
		permeance			= $1.permeance,
		permeance_uom 			= $1.permeance_uom,
		specificheat			= $1.specificheat,
		specificheat_uom		= $1.specificheat_uom
		WHERE t.id = $1.id RETURNING id',
		cdbschema) INTO updated_id USING obj;
	RETURN updated_id;
	EXCEPTION
		WHEN OTHERS THEN RAISE NOTICE 'qgis_pkg.upd_t_ng_solidmaterial(id: %): %',obj.id,SQLERRM;

END;
$$LANGUAGE plpgsql;
COMMENT ON FUNCTION qgis_pkg.upd_t_ng_solidmaterial(qgis_pkg.obj_ng_solidmaterial,varchar) IS' Updates attributes of table ng_solidmaterial';
REVOKE EXECUTE ON FUNCTION qgis_pkg.upd_t_ng_solidmaterial(qgis_pkg.obj_ng_solidmaterial,varchar) FROM public;

---------------------------------------------------------------------
-- CREATE FUNCTION qgis_pkg.upd_t_ng_ther_boun_to_ther_deli
---------------------------------------------------------------------

DROP FUNCTION IF EXISTS qgis_pkg.upd_t_ng_ther_boun_to_ther_deli(qgis_pkg.obj_ng_ther_boun_to_ther_deli,varchar) CASCADE;
CREATE OR REPLACE FUNCTION qgis_pkg.upd_t_ng_ther_boun_to_ther_deli(obj qgis_pkg.obj_ng_ther_boun_to_ther_deli,cdbschema varchar)
RETURNS bigint AS $$
DECLARE 
	updated_id bigint;

BEGIN
	updated_id := obj.id;
	RETURN updated_id;
	EXCEPTION
		WHEN OTHERS THEN RAISE NOTICE 'qgis_pkg.upd_t_ng_ther_boun_to_ther_deli(id: %): %',obj.id,SQLERRM;
END;
$$LANGUAGE plpgsql;
COMMENT ON FUNCTION qgis_pkg.upd_t_ng_ther_boun_to_ther_deli(qgis_pkg.obj_ng_ther_boun_to_ther_deli,varchar) IS 'Returns id of ng_ther_boun_to_ther_deli record';
REVOKE EXECUTE ON FUNCTION qgis_pkg.upd_t_ng_ther_boun_to_ther_deli(qgis_pkg.obj_ng_ther_boun_to_ther_deli,varchar) FROM public; 

----------------------------------------------------------------------
-- CREATE FUNCTION qgis_pkg.upd_t_ng_thermalboundary
----------------------------------------------------------------------

DROP FUNCTION IF EXISTS qgis_pkg.upd_t_ng_thermalboundary(qgis_pkg.obj_ng_thermalboundary,varchar) CASCADE;
CREATE OR REPLACE FUNCTION qgis_pkg.upd_t_ng_thermalboundary(obj qgis_pkg.obj_ng_thermalboundary,cdbschema varchar)  
RETURNS bigint AS $$
DECLARE
	updated_id bigint;
	thermBoundary_enum varchar[] := ARRAY['interiorWall','intermediaryFloor','sharedWall','outerWall','groundSlab','basementCeiling','atticFloor','roof'];
BEGIN
	IF ((obj.area IS NOT NULL) AND (obj.area_uom IS NULL))
        OR ((obj.area IS NULL) AND (obj.area_uom IS NOT NULL))
        THEN RAISE EXCEPTION 'area must have a number and measure unit';
        END IF;

	IF ((obj.azimuth IS NOT NULL) AND (obj.azimuth_uom IS NULL))
        OR ((obj.azimuth IS NULL) AND (obj.azimuth_uom IS NOT NULL))
        THEN RAISE EXCEPTION 'azimuth must have a number and measure unit';
        END IF;

	IF ((obj.inclination IS NOT NULL) AND (obj.inclination_uom IS NULL))
        OR ((obj.inclination IS NULL) AND (obj.inclination_uom IS NOT NULL))
        THEN RAISE EXCEPTION 'inclination must have a number and measure unit';
        END IF;

	IF (obj.thermalboundarytype IS NOT NULL) AND NOT(obj.thermalboundarytype = ANY(thermBoundary_enum))
	THEN RAISE EXCEPTION 'thermalboundarytype must either be NULL or one of %',thermBoundary_enum;
	END IF;

	EXECUTE format('
		UPDATE %I.ng_thermalboundary AS t SET 
		area 				= $1.area,
		area_uom			= $1.area_uom,
		azimuth				= $1.azimuth,
		azimuth_uom			= $1.azimuth_uom,
		inclination			= $1.inclination,
		inclination_uom			= $1.inclination_uom,
		thermalboundarytype		= $1.thermalboundarytype
		WHERE t.id = $1.id RETURNING id',
		cdbschema) INTO updated_id USING obj;
	RETURN updated_id;
	EXCEPTION
		WHEN OTHERS THEN RAISE NOTICE 'qgis_pkg.upd_t_ng_thermalboundary(id: %): %',obj.id,SQLERRM;
END;
$$LANGUAGE plpgsql;
COMMENT ON FUNCTION qgis_pkg.upd_t_ng_thermalboundary(qgis_pkg.obj_ng_thermalboundary,varchar) IS 'Updates attributes of table ng_thermalboundary';
REVOKE EXECUTE ON FUNCTION qgis_pkg.upd_t_ng_thermalboundary(qgis_pkg.obj_ng_thermalboundary,varchar) FROM public;

----------------------------------------------------------------------
-- CREATE FUNCTION qgis_pkg.upd_t_ng_thermalopening
----------------------------------------------------------------------

DROP FUNCTION IF EXISTS qgis_pkg.upd_t_ng_thermalopening(qgis_pkg.obj_ng_thermalopening,varchar) CASCADE;
CREATE OR REPLACE FUNCTION qgis_pkg.upd_t_ng_thermalopening(obj qgis_pkg.obj_ng_thermalopening,cdbschema varchar)
RETURNS bigint AS $$
DECLARE 
	updated_id bigint;
BEGIN
	IF ((obj.area IS NOT NULL) AND (obj.area_uom IS NULL))
        OR ((obj.area IS NULL) AND (obj.area_uom IS NOT NULL))
        THEN RAISE EXCEPTION 'area must have a number and measure unit';
        END IF;

	EXECUTE format('
		UPDATE %I.ng_thermalopening AS t SET 
		area 				= $1.area,
		area_uom			= $1.area_uom
		WHERE t.id = $1.id RETURNING id',
		cdbschema) INTO updated_id USING obj;
	RETURN updated_id;
	EXCEPTION
		WHEN OTHERS THEN RAISE NOTICE 'qgis_pkg.upd_t_ng_thermalopening(id: %): %',obj.id,SQLERRM;
END;
$$LANGUAGE plpgsql;
COMMENT ON FUNCTION qgis_pkg.upd_t_ng_thermalopening(qgis_pkg.obj_ng_thermalopening,varchar) IS 'Updates attributes of tablr ng_thermalopening';
REVOKE EXECUTE ON FUNCTION qgis_pkg.upd_t_ng_thermalopening(qgis_pkg.obj_ng_thermalopening,varchar) FROM public;

---------------------------------------------------------------------
-- CREATE FUNCTION qgis_pkg.upd_t_ng_thermalzone
---------------------------------------------------------------------

DROP FUNCTION IF EXISTS qgis_pkg.upd_t_ng_thermalzone(qgis_pkg.obj_ng_thermalzone,varchar) CASCADE;
CREATE OR REPLACE FUNCTION qgis_pkg.upd_t_ng_thermalzone(obj qgis_pkg.obj_ng_thermalzone,cdbschema varchar)
RETURNS bigint AS $$
DECLARE
	updated_id bigint;
BEGIN
	IF ((obj.infiltrationrate IS NOT NULL) AND (obj.infiltrationrate_uom IS NULL))
        OR ((obj.infiltrationrate IS NULL) AND (obj.infiltrationrate_uom IS NOT NULL))
        THEN RAISE EXCEPTION 'infiltrationrate must have a number and measure unit';
        END IF;

	IF (obj.iscooled IS NULL) THEN obj.iscooled := 1;
	END IF;
	
	IF (obj.isheated IS NULL) THEN obj.isheated := 1;
	END IF;
	
	EXECUTE format('
		UPDATE %I.ng_thermalzone AS t SET 
		infiltrationrate		= $1.infiltrationrate,
		infiltrationrate_uom		= $1.infiltrationrate_uom,
		iscooled			= $1.iscooled,
		isheated			= $1.isheated
		WHERE t.id = $1.id RETURNING id',
		cdbschema) INTO updated_id USING obj;
	RETURN updated_id;
	EXCEPTION
		WHEN OTHERS THEN RAISE NOTICE 'qgis_pkg.upd_t_ng_thermalzone(id: %): %',obj.id,SQLERRM;
END;
$$LANGUAGE plpgsql;
COMMENT ON FUNCTION qgis_pkg.upd_t_ng_thermalzone(qgis_pkg.obj_ng_thermalzone,varchar) IS 'Updates attributes of table ng_thermalzone';
REVOKE EXECUTE ON FUNCTION qgis_pkg.upd_t_ng_thermalzone(qgis_pkg.obj_ng_thermalzone,varchar) FROM public;

---------------------------------------------------------------------
-- CREATE FUNCTION qgis_pkg.upd_t_ng_timeseries
---------------------------------------------------------------------
 
DROP FUNCTION IF EXISTS qgis_pkg.upd_t_ng_timeseries(qgis_pkg.obj_ng_timeseries,varchar) CASCADE;  
CREATE OR REPLACE FUNCTION qgis_pkg.upd_t_ng_timeseries(obj qgis_pkg.obj_ng_timeseries,cdbschema varchar)
RETURNS bigint AS $$
DECLARE
	updated_id bigint;
	acquisition_enum varchar[] := ARRAY['measurement','estimation','simulation','calibratedSimulation','unknown'];
	interpolation_enum varchar[] := ARRAY['averageInPrecedingInterval','averageInSucceedingInterval','constantInPrecedingInterval',
					      'constantInSucceedingInterval','continuous','discontinuous','instantaneousTotal',
					      'maximumInPrecedingInterval','maximumInSucceedingInterval','minimumInPrecedingInterval',
					      'minimumInSucceedingInterval','precedingTotal','succeedingTotal'];
BEGIN
	IF ((obj.timevaluesprop_acquisitionme IS NOT NULL) AND NOT(obj.timevaluesprop_acquisitionme = ANY(acquisition_enum)))
        THEN RAISE EXCEPTION 'timevaluesprop_acquisitionme must either be NULL or one of %',acquisition_enum;
        END IF;

	IF ((obj.timevaluesprop_interpolation IS NOT NULL) AND NOT(obj.timevaluesprop_interpolation = ANY(interpolation_enum)))
        THEN RAISE EXCEPTION 'timevaluesprop_interpolation must either be null or one of %',interpolation_enum;
        END IF;

	EXECUTE format('
		UPDATE %I.ng_timeseries AS t SET 
		timevaluesprop_acquisitionme	= $1.timevaluesprop_acquisitionme,
		timevaluesprop_interpolation	= $1.timevaluesprop_interpolation,
		timevaluesprop_qualitydescri	= $1.timevaluesprop_qualitydescri,
		timevaluesprop_thematicdescr	= $1.timevaluesprop_thematicdescr,
		timevaluespropertiest_source	= $1.timevaluespropertiest_source
		WHERE t.id = $1.id RETURNING id',
		cdbschema) INTO updated_id USING obj;
	RETURN updated_id;
	EXCEPTION
		WHEN OTHERS THEN RAISE NOTICE 'qgis_pkg.upd_t_ng_timeseries(id: %): %',obj.id,SQLERRM; 
END;
$$LANGUAGE plpgsql;
COMMENT ON FUNCTION qgis_pkg.upd_t_ng_timeseries(qgis_pkg.obj_ng_timeseries,varchar) IS 'Updates attributes of table ng_timeseries';
REVOKE EXECUTE ON FUNCTION qgis_pkg.upd_t_ng_timeseries(qgis_pkg.obj_ng_timeseries,varchar) FROM public;

---------------------------------------------------------------------
-- CREATE FUNCTION qgis_pkg.upd_t_ng_timevaluesproperties
---------------------------------------------------------------------

DROP FUNCTION IF EXISTS qgis_pkg.upd_t_ng_timevaluesproperties(qgis_pkg.obj_ng_timevaluesproperties,varchar) CASCADE; 
CREATE OR REPLACE FUNCTION qgis_pkg.upd_t_ng_timevaluesproperties(obj qgis_pkg.obj_ng_timevaluesproperties,cdbschema varchar)
RETURNS bigint AS $$
DECLARE
	updated_id bigint;
	acquisition_enum varchar[] := ARRAY['measurement','estimation','simulation','calibratedSimulation','unknown'];
	interpolation_enum varchar[] := ARRAY['averageInPrecedingInterval','averageInSucceedingInterval','constantInPrecedingInterval',
					      'constantInSucceedingInterval','continuous','discontinuous','instantaneousTotal',
					      'maximumInPrecedingInterval','maximumInSucceedingInterval','minimumInPrecedingInterval',
					      'minimumInSucceedingInterval','precedingTotal','succeedingTotal'];
BEGIN
	IF ((obj.acquisitionmethod IS NOT NULL) AND NOT(obj.acquisitionmethod = ANY(acquisition_enum)))
        THEN RAISE EXCEPTION 'acquisition must either be NULL or one of %',acquisition_enum;
        END IF;
	
	IF ((obj.interpolationtype IS NOT NULL) AND NOT(obj.interpolationtype = ANY(acquisition_enum)))
        THEN RAISE EXCEPTION 'interpolation must either be NULL or one of %',interpolation_enum;
        END IF;
	
	EXECUTE format('
		UPDATE %I.ng_timevaluesproperties AS t SET
	 	acquisitionmethod		= $1.acquisitionmethod,
		interpolationtype 		= $1.interpolationtype,
		qualitydescription		= $1.qualitydescription,
		source				= $1.source,
		thematicdescription		= $1.thematicdescription
		WHERE t.id = $1.id RETURNING id',
		cdbschema) INTO updated_id USING obj;
	RETURN updated_id;
	EXCEPTION
		WHEN OTHERS THEN RAISE NOTICE 'qgis_pkg.upd_t_ng_timevaluesproperties(id: %): %',obj.id,SQLERRM;
END;
$$LANGUAGE plpgsql;
COMMENT ON FUNCTION qgis_pkg.upd_t_ng_timevaluesproperties(qgis_pkg.obj_ng_timevaluesproperties,varchar) IS 'Updates attributes of table ng_timevaluesproperties';
REVOKE EXECUTE ON FUNCTION qgis_pkg.upd_t_ng_timevaluesproperties(qgis_pkg.obj_ng_timevaluesproperties,varchar) FROM public;

------------------------------------------------------------------
-- CREATE FUNCTION qgis_pkg.upd_t_ng_transmittance
------------------------------------------------------------------

DROP FUNCTION IF EXISTS qgis_pkg.upd_t_ng_transmittance(qgis_pkg.obj_ng_transmittance,varchar) CASCADE;
CREATE OR REPLACE FUNCTION qgis_pkg.upd_t_ng_transmittance(obj qgis_pkg.obj_ng_transmittance,cdbschema varchar)  
RETURNS bigint AS $$
DECLARE
	updated_id bigint;
	waveLen_enum varchar[] := ARRAY['solar','infrared','visible','total'];
BEGIN
	IF ((obj.fraction IS NOT NULL) AND (obj.fraction_uom IS NULL))
        OR ((obj.fraction IS NULL) AND (obj.fraction_uom IS NOT NULL))
        THEN RAISE EXCEPTION 'fraction must have a number and measure unit';
        END IF;

	IF (obj.wavelengthrange IS NOT NULL) AND NOT(obj.wavelengthrange = ANY(waveLen_enum))
	THEN RAISE EXCEPTION 'wavelenghtrange must either be NULL or one of %',waveLen_enum;
	END IF;

	EXECUTE format('
		UPDATE %I.ng_transmittance AS t SET
		fraction 			= $1.fraction,
		fraction_uom			= $1.fraction_uom,
		wavelengthrange			= $1.wavelengthrange
		WHERE t.id = $1.id RETURNING id',
		cdbschema) INTO updated_id USING obj;
	RETURN updated_id;
	EXCEPTION
		WHEN OTHERS THEN RAISE NOTICE 'qgis_pkg.upd_t_ng_transmittance(id: %): %',obj.id,SQLERRM;
END;
$$LANGUAGE plpgsql;
COMMENT ON FUNCTION  qgis_pkg.upd_t_ng_transmittance(qgis_pkg.obj_ng_transmittance,varchar) IS 'Updates attributes of table ng_transmittance';
REVOKE EXECUTE ON FUNCTION qgis_pkg.upd_t_ng_transmittance(qgis_pkg.obj_ng_transmittance,varchar) FROM public; 

-----------------------------------------------------------------
-- CREATE FUNCTION qgis_pkg.upd_t_ng_usagezone
-----------------------------------------------------------------

DROP FUNCTION IF EXISTS qgis_pkg.upd_t_ng_usagezone(qgis_pkg.obj_ng_usagezone,varchar) CASCADE;
CREATE OR REPLACE FUNCTION  qgis_pkg.upd_t_ng_usagezone(obj qgis_pkg.obj_ng_usagezone,cdbschema varchar)  
RETURNS bigint AS $$
DECLARE
	updated_id bigint;

BEGIN
	EXECUTE format('
		UPDATE %I.ng_usagezone AS t SET
		usagezonetype			= $1.usagezonetype,
		usagezonetype_codespace		= $1.usagezonetype_codespace
		WHERE t.id = $1.id RETURNING id',
		cdbschema) INTO updated_id USING obj;
	RETURN updated_id;
	EXCEPTION
		WHEN OTHERS THEN RAISE NOTICE 'qgis_pkg.upd_t_ng_usagezone(id: %): %',obj.id,SQLERRM;
END;
$$LANGUAGE plpgsql;
COMMENT ON FUNCTION qgis_pkg.upd_t_ng_usagezone(qgis_pkg.obj_ng_usagezone,varchar) IS 'Updates attributes of table ng_usagezone';
REVOKE EXECUTE ON FUNCTION qgis_pkg.upd_t_ng_usagezone(qgis_pkg.obj_ng_usagezone,varchar) FROM public;

-------------------------------------------------------------------
-- CREATE FUNCTION qgis_pkg.upd_t_ng_volumetype
-------------------------------------------------------------------

DROP FUNCTION IF EXISTS qgis_pkg.upd_t_ng_volumetype(qgis_pkg.obj_ng_volumetype,varchar) CASCADE;
CREATE OR REPLACE FUNCTION  qgis_pkg.upd_t_ng_volumetype(obj qgis_pkg.obj_ng_volumetype,cdbschema varchar) 
RETURNS bigint AS $$
DECLARE
	updated_id bigint;
	type_enum varchar[] := ARRAY['netVolume','grossVolume','energyReferenceVolume'];
BEGIN
	IF (obj.type IS NOT NULL) AND NOT(obj.type = ANY(type_enum))
	THEN RAISE EXCEPTION 'type must either be NULL or one of %',type_enum;
	END IF;

	IF ((obj.value IS NOT NULL) AND (obj.value_uom IS NULL))
	OR ((obj.value IS NULL) AND NOT(obj.value_uom IS NULL))
	THEN RAISE EXCEPTION 'volume must have a value and measure unit';
	END IF;

	EXECUTE format('
		UPDATE %I.ng_volumetype AS t SET 
		type				= $1.type,
		value				= $1.value,
		value_uom			= $1.value_uom
		WHERE t.id = $1.id RETURNING id',
		cdbschema) INTO updated_id USING obj;
	RETURN updated_id;
	EXCEPTION
		WHEN OTHERS THEN RAISE NOTICE 'qgis_pkg.upd_t_ng_volumetype(id: %): %',obj.id,SQLERRM;
END;
$$LANGUAGE plpgsql;
COMMENT ON FUNCTION qgis_pkg.upd_t_ng_volumetype(qgis_pkg.obj_ng_volumetype,varchar) IS 'Updates attributes of table ng_volumetype';
REVOKE EXECUTE ON FUNCTION qgis_pkg.upd_t_ng_volumetype(qgis_pkg.obj_ng_volumetype,varchar) FROM public;

------------------------------------------------------------------
-- CREATE FUNCTION qgis_pkg.upd_t_ng_weatherdata
------------------------------------------------------------------

DROP FUNCTION IF EXISTS qgis_pkg.upd_t_ng_weatherdata(qgis_pkg.obj_ng_weatherdata,varchar) CASCADE;
CREATE OR REPLACE FUNCTION qgis_pkg.upd_t_ng_weatherdata(obj qgis_pkg.obj_ng_weatherdata,cdbschema varchar)
RETURNS bigint AS $$
DECLARE 
	updated_id bigint;
	weather_enum varchar[] := ARRAY['airTemperature','humidity','windSpeed','cloudiness','globalSolarIrradiance','directSolarIrradiance',
					'diffuseSolarIrradiance','terrestrialEmission','downwardTerrestrialRadiation','daylightIlluminance'];
BEGIN
	IF (obj.weatherdatatype IS NOT NULL) AND NOT(obj.weatherdatatype = ANY(weather_enum))
	THEN RAISE EXCEPTION 'weatherdatatype must either be NULL or one of %',weather_enum;
	END IF;

	EXECUTE format('
		UPDATE %I.ng_weatherdata AS t SET
		weatherdatatype			= $1.weatherdatatype
		WHERE t.id = $1.id RETURNING id',
		cdbschema) INTO updated_id USING obj;
	RETURN updated_id;
	EXCEPTION
		WHEN OTHERS THEN RAISE NOTICE 'qgis_pkg.upd_t_ng_weatherdata(id: %): %',obj.id,SQLERRM;
END;
$$LANGUAGE plpgsql;
COMMENT ON FUNCTION qgis_pkg.upd_t_ng_weatherdata(qgis_pkg.obj_ng_weatherdata,varchar) IS 'Updates attributes of table ng_weatherdata';
REVOKE EXECUTE ON FUNCTION qgis_pkg.upd_t_ng_weatherdata(qgis_pkg.obj_ng_weatherdata,varchar) FROM public;

-----------------------------------------------------------------
-- CREATE FUNCTION qgis_pkg.upd_t_ng_weatherstation
-----------------------------------------------------------------

DROP FUNCTION IF EXISTS qgis_pkg.upd_t_ng_weatherstation(qgis_pkg.obj_ng_weatherstation,varchar) CASCADE;
CREATE OR REPLACE FUNCTION qgis_pkg.upd_t_ng_weatherstation(obj qgis_pkg.obj_ng_weatherstation,cdbschema varchar) 
RETURNS bigint AS $$
DECLARE 
	updated_id bigint;
BEGIN
	EXECUTE format('
		UPDATE %I.ng_weatherstation AS t SET 
		genericapplicationpropertyof	= $1.genericapplicationpropertyof,
		stationname			= $1.stationname
		WHERE t.id = $1.id RETURNING id',
		cdbschema) INTO updated_id USING obj;
	RETURN updated_id;
	EXCEPTION
		WHEN OTHERS THEN RAISE NOTICE 'qgis_pkg.upd_t_ng_weatherstation(id: %): %',obj.id,SQLERRM;
END;
$$LANGUAGE plpgsql;
COMMENT ON FUNCTION qgis_pkg.upd_t_ng_weatherstation(qgis_pkg.obj_ng_weatherstation,varchar) IS 'Updates attributes of table ng_weatherstation';
REVOKE EXECUTE ON FUNCTION qgis_pkg.upd_t_ng_weatherstation(qgis_pkg.obj_ng_weatherstation,varchar) FROM public; 











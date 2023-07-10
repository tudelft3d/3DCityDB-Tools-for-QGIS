------------------------------------------------------------
-- CREATE FUNCTION qgis_pkg.upd_ng_building_atts
------------------------------------------------------------
DROP FUNCTION IF EXISTS qgis_pkg.upd_ng_building_atts(qgis_pkg.obj_cityobject,qgis_pkg.obj_building,qgis_pkg.obj_ng_building,varchar) CASCADE;
CREATE OR REPLACE FUNCTION qgis_pkg.upd_ng_building_atts(obj qgis_pkg.obj_cityobject,obj_1 qgis_pkg.obj_building,obj_2 qgis_pkg.obj_ng_building,cdb_schema varchar)
RETURNS bigint AS 
$$
DECLARE 
	updated_id bigint;
BEGIN
	SELECT qgis_pkg.upd_t_cityobject(obj,cdb_schema) INTO updated_id;
	PERFORM qgis_pkg.upd_t_building(obj_1,cdb_schema);
	PERFORM qgis_pkg.upd_t_ng_building(obj_2,cdb_schema);
	RETURN updated_id;
	EXCEPTION
		WHEN OTHERS THEN RAISE NOTICE 'qgis_pkg.upd_ng_building_atts(id: %): %',obj.id,SQLERRM;
END;
$$
LANGUAGE plpgsql;
COMMENT ON FUNCTION qgis_pkg.upd_ng_building_atts(qgis_pkg.obj_cityobject,qgis_pkg.obj_building,qgis_pkg.obj_ng_building,varchar) IS 'Update attributes of table ng_building (and its parents)';
REVOKE EXECUTE ON FUNCTION qgis_pkg.upd_ng_building_atts(qgis_pkg.obj_cityobject,qgis_pkg.obj_building,qgis_pkg.obj_ng_building,varchar) FROM public;

------------------------------------------------------------
-- CREATE FUNCTION qgis_pkg.upd_ng_thermalzone_atts
------------------------------------------------------------

DROP FUNCTION IF EXISTS qgis_pkg.upd_ng_thermalzone_atts(qgis_pkg.obj_cityobject,qgis_pkg.obj_ng_thermalzone,varchar) CASCADE;
CREATE OR REPLACE FUNCTION qgis_pkg.upd_ng_thermalzone_atts(obj qgis_pkg.obj_cityobject,obj_1 qgis_pkg.obj_ng_thermalzone,cdb_schema varchar)
RETURNS bigint AS $$
DECLARE
	updated_id bigint;
BEGIN
	SELECT qgis_pkg.upd_t_cityobject(obj,cdb_schema) INTO updated_id;
	PERFORM qgis_pkg.upd_t_ng_thermalzone(obj_1,cdb_schema);
	RETURN updated_id;
	EXCEPTION
		WHEN OTHERS THEN RAISE NOTICE 'qgis_pkg.upd_ng_thermalzone_atts(id: %): %',obj.id,SQLERRM;
END;
$$
LANGUAGE plpgsql;
COMMENT ON FUNCTION qgis_pkg.upd_ng_thermalzone_atts(qgis_pkg.obj_cityobject,qgis_pkg.obj_ng_thermalzone,varchar) IS 'Update attributes of table ng_thermalzone (and its parents)';
REVOKE EXECUTE ON FUNCTION qgis_pkg.upd_ng_thermalzone_atts(qgis_pkg.obj_cityobject,qgis_pkg.obj_ng_thermalzone,varchar) FROM public;

------------------------------------------------------------
-- CREATE FUNCTION qgis_pkg.upd_ng_thermalboundary_atts
------------------------------------------------------------

DROP FUNCTION IF EXISTS qgis_pkg.upd_ng_thermalboundary_atts(qgis_pkg.obj_cityobject,qgis_pkg.obj_ng_thermalboundary,varchar) CASCADE;
CREATE OR REPLACE FUNCTION qgis_pkg.upd_ng_thermalboundary_atts(obj qgis_pkg.obj_cityobject, obj_1 qgis_pkg.obj_ng_thermalboundary, cdb_schema varchar)
RETURNS bigint AS $$
DECLARE 
	updated_id bigint;
BEGIN
	SELECT qgis_pkg.upd_t_cityobject(obj,cdb_schema) INTO updated_id;
	PERFORM qgis_pkg.upd_t_ng_thermalboundary(obj_1,cdb_schema);
	RETURN updated_id;
	EXCEPTION
		WHEN OTHERS THEN RAISE NOTICE 'qgis_pkg.upd_ng_thermalboundary_atts(id: %): %',obj.id,SQLERRM;
END;
$$
LANGUAGE plpgsql;
COMMENT ON FUNCTION qgis_pkg.upd_ng_thermalboundary_atts(qgis_pkg.obj_cityobject,qgis_pkg.obj_ng_thermalboundary,varchar) IS 'Updates attributes of table ng_thermalboundary (and its parents)';
REVOKE EXECUTE ON FUNCTION qgis_pkg.upd_ng_thermalboundary_atts(qgis_pkg.obj_cityobject,qgis_pkg.obj_ng_thermalboundary,varchar) FROM public;

-----------------------------------------------------------
-- CREATE FUNCTION qgis_pkg.upd_ng_thermalopening_atts
-----------------------------------------------------------

DROP FUNCTION IF EXISTS qgis_pkg.upd_ng_thermalopening_atts(qgis_pkg.obj_cityobject,qgis_pkg.obj_ng_thermalopening,varchar) CASCADE;
CREATE OR REPLACE FUNCTION qgis_pkg.upd_ng_thermalopening_atts(obj qgis_pkg.obj_cityobject,obj_1 qgis_pkg.obj_ng_thermalopening,cdb_schema varchar)
RETURNS bigint AS $$
DECLARE
	updated_id bigint;
BEGIN
	SELECT qgis_pkg.upd_t_cityobject(obj,cdb_schema) INTO updated_id;
	PERFORM qgis_pkg.upd_t_ng_thermalopening(obj_1,cdb_schema);
	RETURN updated_id;
	EXCEPTION
		WHEN OTHERS THEN RAISE NOTICE 'qgis_pkg.upd_ng_thermalopening_atts(id: %): %',obj.id,SQLERRM;
END;
$$
LANGUAGE plpgsql;
COMMENT ON FUNCTION qgis_pkg.upd_ng_thermalopening_atts(qgis_pkg.obj_cityobject,qgis_pkg.obj_ng_thermalopening,varchar) IS 'Updates attributes of table ng_themalopening (and its parents)';
REVOKE EXECUTE ON FUNCTION qgis_pkg.upd_ng_thermalopening_atts(qgis_pkg.obj_cityobject,qgis_pkg.obj_ng_thermalopening,varchar) FROM public;

-----------------------------------------------------------
-- CREATE FUNCTION qgis_pkg.upd_ng_weatherstation_atts
-----------------------------------------------------------

DROP FUNCTION IF EXISTS qgis_pkg.upd_ng_weatherstation_atts(qgis_pkg.obj_cityobject,qgis_pkg.obj_ng_weatherstation,varchar) CASCADE;
CREATE OR REPLACE FUNCTION qgis_pkg.upd_ng_weatherstation_atts(obj qgis_pkg.obj_cityobject,obj_1 qgis_pkg.obj_ng_weatherstation,cdb_schema varchar)
RETURNS bigint AS $$
DECLARE
	updated_id bigint;
BEGIN
	SELECT qgis_pkg.upd_t_cityobject(obj,cdb_schema) INTO updated_id;
	PERFORM qgis_pkg.upd_t_ng_weatherstation(obj_1,cdb_schema);
	RETURN updated_id;
	EXCEPTION
		WHEN OTHERS THEN RAISE NOTICE 'qgis_pkg.upd_ng_weatherstation_atts(id: %): %',obj.id,SQLERRM;
END;
$$
LANGUAGE plpgsql;
COMMENT ON FUNCTION qgis_pkg.upd_ng_weatherstation_atts(qgis_pkg.obj_cityobject,qgis_pkg.obj_ng_weatherstation,varchar) IS 'Updates attributes of table ng_weatherstation (and its parents)';
REVOKE EXECUTE ON FUNCTION qgis_pkg.upd_ng_weatherstation_atts(qgis_pkg.obj_cityobject,qgis_pkg.obj_ng_weatherstation,varchar) FROM public;

-----------------------------------------------------------
-- CREATE FUNCTION qgis_pkg.upd_ng_weatherdata_atts
-----------------------------------------------------------

DROP FUNCTION IF EXISTS qgis_pkg.upd_ng_weatherdata_atts(qgis_pkg.obj_cityobject,qgis_pkg.obj_ng_weatherdata,varchar) CASCADE;
CREATE OR REPLACE FUNCTION qgis_pkg.upd_ng_weatherdata_atts(obj qgis_pkg.obj_cityobject,obj_1 qgis_pkg.obj_ng_weatherdata,cdb_schema varchar)
RETURNS bigint AS $$
DECLARE
	updated_id bigint;
BEGIN
	SELECT qgis_pkg.upd_t_cityobject(obj,cdb_schema) INTO updated_id;
	PERFORM qgis_pkg.upd_t_ng_weatherdata(obj_1,cdb_schema);
	RETURN updated_id;
	EXCEPTION
		WHEN OTHERS THEN RAISE NOTICE 'qgis_pkg.upd_ng_weatherdata_atts(id: %): %',obj.id,SQLERRM;
END;
$$
LANGUAGE plpgsql;
COMMENT ON FUNCTION qgis_pkg.upd_ng_weatherdata_atts(qgis_pkg.obj_cityobject,qgis_pkg.obj_ng_weatherdata,varchar) IS 'Updates attributes of table ng_weatherdata (and its parents)';
REVOKE EXECUTE ON FUNCTION qgis_pkg.upd_ng_weatherdata_atts(qgis_pkg.obj_cityobject,qgis_pkg.obj_ng_weatherdata,varchar) FROM public;

-----------------------------------------------------------
-- CREATE FUNCTION qgis_pkg.upd_ng_dailyschedule_atts
-----------------------------------------------------------

DROP FUNCTION IF EXISTS qgis_pkg.upd_ng_dailyschedule_atts(qgis_pkg.obj_ng_dailyschedule,varchar) CASCADE;
CREATE OR REPLACE FUNCTION qgis_pkg.upd_ng_dailyschedule_atts(obj qgis_pkg.obj_ng_dailyschedule,cdb_schema varchar)
RETURNS bigint AS $$
DECLARE 
	updated_id bigint;
BEGIN
	SELECT qgis_pkg.upd_t_ng_dailyschedule(obj,cdb_schema) INTO updated_id;
	RETURN updated_id;
	EXCEPTION
		WHEN OTHERS THEN RAISE NOTICE 'qgis_pkg.upd_ng_dailyschedule_atts(id: %): %',obj.id,SQLERRM;
END;
$$
LANGUAGE plpgsql;
COMMENT ON FUNCTION qgis_pkg.upd_ng_dailyschedule_atts(qgis_pkg.obj_ng_dailyschedule,varchar) IS 'Updates attributes of table ng_dailyschedule';
REVOKE EXECUTE ON FUNCTION qgis_pkg.upd_ng_dailyschedule_atts(qgis_pkg.obj_ng_dailyschedule,varchar) FROM public;

-----------------------------------------------------------
-- CREATE FUNCTION qgis_pkg.upd_ng_periodofyear_atts
-----------------------------------------------------------

DROP FUNCTION IF EXISTS qgis_pkg.upd_ng_periodofyear_atts(qgis_pkg.obj_ng_periodofyear,varchar) CASCADE;
CREATE OR REPLACE FUNCTION qgis_pkg.upd_ng_periodofyear_atts(obj qgis_pkg.obj_ng_periodofyear,cdb_schema varchar)
RETURNS bigint AS $$
DECLARE 
	updated_id bigint;
BEGIN 
	SELECT qgis_pkg.upd_t_ng_periodofyear(obj,cdb_schema) INTO updated_id;
	RETURN updated_id;
	EXCEPTION
		WHEN OTHERS THEN RAISE NOTICE 'qgis_pkg.upd_ng_periodofyear_atts(id: %): %',obj.id,SQLERRM;
END;
$$
LANGUAGE plpgsql;
COMMENT ON FUNCTION qgis_pkg.upd_ng_periodofyear_atts(qgis_pkg.obj_ng_periodofyear,varchar) IS 'Updates attributes of table ng_periodofyear';
REVOKE EXECUTE ON FUNCTION qgis_pkg.upd_ng_periodofyear_atts(qgis_pkg.obj_ng_periodofyear,varchar) FROM public;

-----------------------------------------------------------
-- CREATE FUNCTION qgis_pkg.upd_ng_regulartimeseries_atts
-----------------------------------------------------------

DROP FUNCTION IF EXISTS qgis_pkg.upd_ng_regulartimeseries_atts(qgis_pkg.obj_cityobject,qgis_pkg.obj_ng_regulartimeseries,qgis_pkg.obj_ng_timeseries,varchar) CASCADE;
CREATE OR REPLACE FUNCTION qgis_pkg.upd_ng_regulartimeseries_atts(obj qgis_pkg.obj_cityobject,obj_1 qgis_pkg.obj_ng_regulartimeseries,obj_2 qgis_pkg.obj_ng_timeseries,cdb_schema varchar)
RETURNS bigint AS $$
DECLARE
	updated_id bigint;
BEGIN
	SELECT qgis_pkg.upd_t_cityobject(obj,cdb_schema) INTO updated_id;
	PERFORM qgis_pkg.upd_t_ng_regulartimeseries(obj_1,cdb_schema);
	PERFORM qgis_pkg.upd_t_ng_timeseries(obj_2,cdb_schema);
	RETURN updated_id;
	EXCEPTION
		WHEN OTHERS THEN RAISE NOTICE 'qgis_pkg.upd_ng_regulartimeseries(id: %): %',obj.id,SQLERRM;
END;
$$ 
LANGUAGE plpgsql;
COMMENT ON FUNCTION qgis_pkg.upd_ng_regulartimeseries_atts(qgis_pkg.obj_cityobject,qgis_pkg.obj_ng_regulartimeseries,qgis_pkg.obj_ng_timeseries,varchar) IS 'Updates attributes of table ng_regulartimeseries';
REVOKE EXECUTE ON FUNCTION qgis_pkg.upd_ng_regulartimeseries_atts(qgis_pkg.obj_cityobject,qgis_pkg.obj_ng_regulartimeseries,qgis_pkg.obj_ng_timeseries,varchar) FROM public;

-----------------------------------------------------------
-- CREATE FUNCTION qgis_pkg.upd_ng_regulartimeseriesfile_atts
-----------------------------------------------------------

DROP FUNCTION IF EXISTS qgis_pkg.upd_ng_regulartimeseriesfile_atts(qgis_pkg.obj_cityobject,qgis_pkg.obj_ng_regulartimeseriesfile,qgis_pkg.obj_ng_timeseries,varchar) CASCADE;
CREATE OR REPLACE FUNCTION qgis_pkg.upd_ng_regulartimeseriesfile_atts(obj qgis_pkg.obj_cityobject,obj_1 qgis_pkg.obj_ng_regulartimeseriesfile,obj_2 qgis_pkg.obj_ng_timeseries,cdb_schema varchar)
RETURNS bigint AS $$
DECLARE
	updated_id bigint;
BEGIN
	SELECT qgis_pkg.upd_t_cityobject(obj,cdb_schema) INTO updated_id;
	PERFORM qgis_pkg.upd_t_ng_regulartimeseriesfile(obj_1,cdb_schema);
	PERFORM qgis_pkg.upd_t_ng_timeseries(obj_2,cdb_schema);
	RETURN updated_id;
	EXCEPTION
		WHEN OTHERS THEN RAISE NOTICE 'qgis_pkg.upd_ng_regulartimeseriesfile(id: %): %',obj.id,SQLERRM;
END;
$$ 
LANGUAGE plpgsql;
COMMENT ON FUNCTION qgis_pkg.upd_ng_regulartimeseriesfile_atts(qgis_pkg.obj_cityobject,qgis_pkg.obj_ng_regulartimeseriesfile,qgis_pkg.obj_ng_timeseries,varchar) IS 'Updates attributes of table ng_regulartimeseriesfile';
REVOKE EXECUTE ON FUNCTION qgis_pkg.upd_ng_regulartimeseriesfile_atts(qgis_pkg.obj_cityobject,qgis_pkg.obj_ng_regulartimeseriesfile,qgis_pkg.obj_ng_timeseries,varchar) FROM public;

-----------------------------------------------------------
-- CREATE FUNCTION qgis_pkg.upd_ng_usagezone_atts
-----------------------------------------------------------

DROP FUNCTION IF EXISTS qgis_pkg.upd_ng_usagezone_atts(qgis_pkg.obj_cityobject,qgis_pkg.obj_ng_usagezone,varchar) CASCADE;
CREATE OR REPLACE FUNCTION qgis_pkg.upd_ng_usagezone_atts(obj qgis_pkg.obj_cityobject,obj_1 qgis_pkg.obj_ng_usagezone,cdb_schema varchar)
RETURNS bigint AS $$
DECLARE
	updated_id bigint;
BEGIN
	SELECT qgis_pkg.upd_t_cityobject(obj,cdb_schema) INTO updated_id;
	PERFORM qgis_pkg.upd_t_ng_usagezone(obj_1,cdb_schema);
	RETURN updated_id;
	EXCEPTION
		WHEN OTHERS THEN RAISE NOTICE 'qgis_pkg.upd_ng_usagezone_atts(id: %): %',obj.id,SQLERRM;
END;
$$ 
LANGUAGE plpgsql;
COMMENT ON FUNCTION qgis_pkg.upd_ng_usagezone_atts(qgis_pkg.obj_cityobject,qgis_pkg.obj_ng_usagezone,varchar) IS 'Updates attributes of table ng_usagezone';
REVOKE EXECUTE ON FUNCTION qgis_pkg.upd_ng_usagezone_atts(qgis_pkg.obj_cityobject,qgis_pkg.obj_ng_usagezone,varchar) FROM public;

-----------------------------------------------------------
-- CREATE FUNCTION qgis_pkg.upd_ng_facilities_atts
-----------------------------------------------------------

DROP FUNCTION IF EXISTS qgis_pkg.upd_ng_facilities_atts(qgis_pkg.obj_cityobject,qgis_pkg.obj_ng_facilities,varchar) CASCADE;
CREATE OR REPLACE FUNCTION qgis_pkg.upd_ng_facilities_atts(obj qgis_pkg.obj_cityobject,obj_1 qgis_pkg.obj_ng_facilities,cdb_schema varchar)
RETURNS bigint AS $$
DECLARE
	updated_id bigint;
BEGIN
	SELECT qgis_pkg.upd_t_cityobject(obj,cdb_schema) INTO updated_id;
	PERFORM qgis_pkg.upd_t_ng_facilities(obj_1,cdb_schema);
	RETURN updated_id;
	EXCEPTION
		WHEN OTHERS THEN RAISE NOTICE 'qgis_pkg.upd_ng_facilities_atts(id: %): %',obj.id,SQLERRM;
END;
$$ 
LANGUAGE plpgsql;
COMMENT ON FUNCTION qgis_pkg.upd_ng_facilities_atts(qgis_pkg.obj_cityobject,qgis_pkg.obj_ng_facilities,varchar) IS 'Updates attributes of table ng_facilities';
REVOKE EXECUTE ON FUNCTION qgis_pkg.upd_ng_facilities_atts(qgis_pkg.obj_cityobject,qgis_pkg.obj_ng_facilities,varchar) FROM public;

-----------------------------------------------------------
-- CREATE FUNCTION qgis_pkg.upd_ng_occupants_atts
-----------------------------------------------------------

DROP FUNCTION IF EXISTS qgis_pkg.upd_ng_occupants_atts(qgis_pkg.obj_cityobject,qgis_pkg.obj_ng_occupants,varchar) CASCADE;
CREATE OR REPLACE FUNCTION qgis_pkg.upd_ng_occupants_atts(obj qgis_pkg.obj_cityobject,obj_1 qgis_pkg.obj_ng_occupants,cdb_schema varchar)
RETURNS bigint AS $$
DECLARE
	updated_id bigint;
BEGIN
	SELECT qgis_pkg.upd_t_cityobject(obj,cdb_schema) INTO updated_id;
	PERFORM qgis_pkg.upd_t_ng_occupants(obj_1,cdb_schema);
	RETURN updated_id;
	EXCEPTION
		WHEN OTHERS THEN RAISE NOTICE 'qgis_pkg.upd_ng_occupants_atts(id: %): %',obj.id,SQLERRM;
END;
$$ 
LANGUAGE plpgsql;
COMMENT ON FUNCTION qgis_pkg.upd_ng_occupants_atts(qgis_pkg.obj_cityobject,qgis_pkg.obj_ng_occupants,varchar) IS 'Updates attributes of table ng_occupants';
REVOKE EXECUTE ON FUNCTION qgis_pkg.upd_ng_occupants_atts(qgis_pkg.obj_cityobject,qgis_pkg.obj_ng_occupants,varchar) FROM public;

-----------------------------------------------------------
-- CREATE FUNCTION qgis_pkg.upd_ng_construction_atts
-----------------------------------------------------------

DROP FUNCTION IF EXISTS qgis_pkg.upd_ng_construction_atts(qgis_pkg.obj_cityobject,qgis_pkg.obj_ng_construction,varchar) CASCADE;
CREATE OR REPLACE FUNCTION qgis_pkg.upd_ng_construction_atts(obj qgis_pkg.obj_cityobject,obj_1 qgis_pkg.obj_ng_construction,cdb_schema varchar)
RETURNS bigint AS $$
DECLARE
	updated_id bigint;
BEGIN
	SELECT qgis_pkg.upd_t_cityobject(obj,cdb_schema) INTO updated_id;
	PERFORM qgis_pkg.upd_t_ng_construction(obj_1,cdb_schema);
	RETURN updated_id;
	EXCEPTION
		WHEN OTHERS THEN RAISE NOTICE 'qgis_pkg.upd_ng_construction_atts(id: %): %',obj.id,SQLERRM;
END;
$$ 
LANGUAGE plpgsql;
COMMENT ON FUNCTION qgis_pkg.upd_ng_construction_atts(qgis_pkg.obj_cityobject,qgis_pkg.obj_ng_construction,varchar) IS 'Updates attributes of table ng_construction';
REVOKE EXECUTE ON FUNCTION qgis_pkg.upd_ng_construction_atts(qgis_pkg.obj_cityobject,qgis_pkg.obj_ng_construction,varchar) FROM public;

-----------------------------------------------------------
-- CREATE FUNCTION qgis_pkg.upd_ng_layer_atts
-----------------------------------------------------------

DROP FUNCTION IF EXISTS qgis_pkg.upd_ng_layer_atts(qgis_pkg.obj_cityobject,qgis_pkg.obj_ng_layer,varchar) CASCADE;
CREATE OR REPLACE FUNCTION qgis_pkg.upd_ng_layer_atts(obj qgis_pkg.obj_cityobject,obj_1 qgis_pkg.obj_ng_layer,cdb_schema varchar)
RETURNS bigint AS $$
DECLARE
	updated_id bigint;
BEGIN
	SELECT qgis_pkg.upd_t_cityobject(obj,cdb_schema) INTO updated_id;
	PERFORM qgis_pkg.upd_t_ng_layer(obj_1,cdb_schema);
	RETURN updated_id;
	EXCEPTION
		WHEN OTHERS THEN RAISE NOTICE 'qgis_pkg.upd_ng_layer_atts(id: %): %',obj.id,SQLERRM;
END;
$$ 
LANGUAGE plpgsql;
COMMENT ON FUNCTION qgis_pkg.upd_ng_layer_atts(qgis_pkg.obj_cityobject,qgis_pkg.obj_ng_layer,varchar) IS 'Updates attributes of table ng_layer';
REVOKE EXECUTE ON FUNCTION qgis_pkg.upd_ng_layer_atts(qgis_pkg.obj_cityobject,qgis_pkg.obj_ng_layer,varchar) FROM public;

-----------------------------------------------------------
-- CREATE FUNCTION qgis_pkg.upd_ng_layercomponent_atts
-----------------------------------------------------------

DROP FUNCTION IF EXISTS qgis_pkg.upd_ng_layercomponent_atts(qgis_pkg.obj_cityobject,qgis_pkg.obj_ng_layercomponent,varchar) CASCADE;
CREATE OR REPLACE FUNCTION qgis_pkg.upd_ng_layercomponent_atts(obj qgis_pkg.obj_cityobject,obj_1 qgis_pkg.obj_ng_layercomponent,cdb_schema varchar)
RETURNS bigint AS $$
DECLARE
	updated_id bigint;
BEGIN
	SELECT qgis_pkg.upd_t_cityobject(obj,cdb_schema) INTO updated_id;
	PERFORM qgis_pkg.upd_t_ng_layercomponent(obj_1,cdb_schema);
	RETURN updated_id;
	EXCEPTION
		WHEN OTHERS THEN RAISE NOTICE 'qgis_pkg.upd_ng_layercomponent_atts(id: %): %',obj.id,SQLERRM;
END;
$$ 
LANGUAGE plpgsql;
COMMENT ON FUNCTION qgis_pkg.upd_ng_layercomponent_atts(qgis_pkg.obj_cityobject,qgis_pkg.obj_ng_layercomponent,varchar) IS 'Updates attributes of table ng_component';
REVOKE EXECUTE ON FUNCTION qgis_pkg.upd_ng_layercomponent_atts(qgis_pkg.obj_cityobject,qgis_pkg.obj_ng_layercomponent,varchar) FROM public;

-----------------------------------------------------------
-- CREATE FUNCTION qgis_pkg.upd_ng_gas_atts
-----------------------------------------------------------

DROP FUNCTION IF EXISTS qgis_pkg.upd_ng_gas_atts(qgis_pkg.obj_cityobject,qgis_pkg.obj_ng_gas,varchar) CASCADE;
CREATE OR REPLACE FUNCTION qgis_pkg.upd_ng_gas_atts(obj qgis_pkg.obj_cityobject,obj_1 qgis_pkg.obj_ng_gas,cdb_schema varchar)
RETURNS bigint AS $$
DECLARE
	updated_id bigint;
BEGIN
	SELECT qgis_pkg.upd_t_cityobject(obj,cdb_schema) INTO updated_id;
	PERFORM qgis_pkg.upd_t_ng_gas(obj_1,cdb_schema);
	RETURN updated_id;
	EXCEPTION
		WHEN OTHERS THEN RAISE NOTICE 'qgis_pkg.upd_ng_gas_atts(id: %): %',obj.id,SQLERRM;
END;
$$ 
LANGUAGE plpgsql;
COMMENT ON FUNCTION qgis_pkg.upd_ng_gas_atts(qgis_pkg.obj_cityobject,qgis_pkg.obj_ng_gas,varchar) IS 'Updates attributes of table ng_gas';
REVOKE EXECUTE ON FUNCTION qgis_pkg.upd_ng_gas_atts(qgis_pkg.obj_cityobject,qgis_pkg.obj_ng_gas,varchar) FROM public;

-----------------------------------------------------------
-- CREATE FUNCTION qgis_pkg.upd_ng_solidmaterial_atts
-----------------------------------------------------------

DROP FUNCTION IF EXISTS qgis_pkg.upd_ng_solidmaterial_atts(qgis_pkg.obj_cityobject,qgis_pkg.obj_ng_solidmaterial,varchar) CASCADE;
CREATE OR REPLACE FUNCTION qgis_pkg.upd_ng_solidmaterial_atts(obj qgis_pkg.obj_cityobject,obj_1 qgis_pkg.obj_ng_solidmaterial,cdb_schema varchar)
RETURNS bigint AS $$
DECLARE
	updated_id bigint;
BEGIN
	SELECT qgis_pkg.upd_t_cityobject(obj,cdb_schema) INTO updated_id;
	PERFORM qgis_pkg.upd_t_ng_solidmaterial(obj_1,cdb_schema);
	RETURN updated_id;
	EXCEPTION
		WHEN OTHERS THEN RAISE NOTICE 'qgis_pkg.upd_ng_solidmaterial_atts(id: %): %',obj.id,SQLERRM;
END;
$$ 
LANGUAGE plpgsql;
COMMENT ON FUNCTION qgis_pkg.upd_ng_solidmaterial_atts(qgis_pkg.obj_cityobject,qgis_pkg.obj_ng_solidmaterial,varchar) IS 'Updates attributes of table ng_solidmaterial';
REVOKE EXECUTE ON FUNCTION qgis_pkg.upd_ng_solidmaterial_atts(qgis_pkg.obj_cityobject,qgis_pkg.obj_ng_solidmaterial,varchar) FROM public;

-----------------------------------------------------------
-- CREATE FUNCTION qgis_pkg.upd_ng_energydemand_atts
-----------------------------------------------------------

DROP FUNCTION IF EXISTS qgis_pkg.upd_ng_energydemand_atts(qgis_pkg.obj_ng_energydemand,varchar) CASCADE;
CREATE OR REPLACE FUNCTION qgis_pkg.upd_ng_energydemand_atts(obj_1 qgis_pkg.obj_ng_energydemand,cdb_schema varchar)
RETURNS bigint AS $$
DECLARE
	updated_id bigint;
BEGIN
	SELECT qgis_pkg.upd_t_ng_energydemand(obj_1,cdb_schema) INTO updated_id;
	RETURN updated_id;
	EXCEPTION
		WHEN OTHERS THEN RAISE NOTICE 'qgis_pkg.upd_ng_energydemand_atts(id: %): %',obj_1.id,SQLERRM;
END;
$$ 
LANGUAGE plpgsql;
COMMENT ON FUNCTION qgis_pkg.upd_ng_energydemand_atts(qgis_pkg.obj_ng_energydemand,varchar) IS 'Updates attributes of table ng_energydemand';
REVOKE EXECUTE ON FUNCTION qgis_pkg.upd_ng_energydemand_atts(qgis_pkg.obj_ng_energydemand,varchar) FROM public;

-----------------------------------------------------------
-- CREATE FUNCTION qgis_pkg.upd_ng_timevaluesproperties_atts
-----------------------------------------------------------

DROP FUNCTION IF EXISTS qgis_pkg.upd_ng_timevaluesproperties_atts(qgis_pkg.obj_ng_timevaluesproperties,varchar) CASCADE;
CREATE OR REPLACE FUNCTION qgis_pkg.upd_ng_timevaluesproperties_atts(obj_1 qgis_pkg.obj_ng_timevaluesproperties,cdb_schema varchar)
RETURNS bigint AS $$
DECLARE
	updated_id bigint;
BEGIN
	SELECT qgis_pkg.upd_t_ng_timevaluesproperties(obj_1,cdb_schema) INTO updated_id;
	RETURN updated_id;
	EXCEPTION
		WHEN OTHERS THEN RAISE NOTICE 'qgis_pkg.upd_ng_timevaluesproperties_atts(id: %): %',obj_1.id,SQLERRM;
END;
$$ 
LANGUAGE plpgsql;
COMMENT ON FUNCTION qgis_pkg.upd_ng_timevaluesproperties_atts(qgis_pkg.obj_ng_timevaluesproperties,varchar) IS 'Updates attributes of table ng_timevaluesproperties';
REVOKE EXECUTE ON FUNCTION qgis_pkg.upd_ng_timevaluesproperties_atts(qgis_pkg.obj_ng_timevaluesproperties,varchar) FROM public;

-----------------------------------------------------------
-- CREATE FUNCTION qgis_pkg.upd_ng_reflectance_atts
-----------------------------------------------------------

DROP FUNCTION IF EXISTS qgis_pkg.upd_ng_reflectance_atts(qgis_pkg.obj_ng_reflectance,varchar) CASCADE;
CREATE OR REPLACE FUNCTION qgis_pkg.upd_ng_reflectance_atts(obj_1 qgis_pkg.obj_ng_reflectance,cdb_schema varchar)
RETURNS bigint AS $$
DECLARE
	updated_id bigint;
BEGIN
	SELECT qgis_pkg.upd_t_ng_reflectance(obj_1,cdb_schema) INTO updated_id;
	RETURN updated_id;
	EXCEPTION
		WHEN OTHERS THEN RAISE NOTICE 'qgis_pkg.upd_ng_reflectance_atts(id: %): %',obj_1.id,SQLERRM;
END;
$$ 
LANGUAGE plpgsql;
COMMENT ON FUNCTION qgis_pkg.upd_ng_reflectance_atts(qgis_pkg.obj_ng_reflectance,varchar) IS 'Updates attributes of table ng_reflectance';
REVOKE EXECUTE ON FUNCTION qgis_pkg.upd_ng_reflectance_atts(qgis_pkg.obj_ng_reflectance,varchar) FROM public;

-----------------------------------------------------------
-- CREATE FUNCTION qgis_pkg.upd_ng_opticalproperties_atts
-----------------------------------------------------------

DROP FUNCTION IF EXISTS qgis_pkg.upd_ng_opticalproperties_atts(qgis_pkg.obj_ng_opticalproperties,varchar) CASCADE;
CREATE OR REPLACE FUNCTION qgis_pkg.upd_ng_opticalproperties_atts(obj_1 qgis_pkg.obj_ng_opticalproperties,cdb_schema varchar)
RETURNS bigint AS $$
DECLARE
	updated_id bigint;
BEGIN
	SELECT qgis_pkg.upd_t_ng_opticalproperties(obj_1,cdb_schema) INTO updated_id;
	RETURN updated_id;
	EXCEPTION
		WHEN OTHERS THEN RAISE NOTICE 'qgis_pkg.upd_ng_opticalproperties_atts(id: %): %',obj_1.id,SQLERRM;
END;
$$ 
LANGUAGE plpgsql;
COMMENT ON FUNCTION qgis_pkg.upd_ng_opticalproperties_atts(qgis_pkg.obj_ng_opticalproperties,varchar) IS 'Updates attributes of table ng_opticalproperties';
REVOKE EXECUTE ON FUNCTION qgis_pkg.upd_ng_opticalproperties_atts(qgis_pkg.obj_ng_opticalproperties,varchar) FROM public;

-----------------------------------------------------------
-- CREATE FUNCTION qgis_pkg.upd_ng_volumetype_atts
-----------------------------------------------------------

DROP FUNCTION IF EXISTS qgis_pkg.upd_ng_volumetype_atts(qgis_pkg.obj_ng_volumetype,varchar) CASCADE;
CREATE OR REPLACE FUNCTION qgis_pkg.upd_ng_volumetype_atts(obj_1 qgis_pkg.obj_ng_volumetype,cdb_schema varchar)
RETURNS bigint AS $$
DECLARE
	updated_id bigint;
BEGIN
	SELECT qgis_pkg.upd_t_ng_volumetype(obj_1,cdb_schema) INTO updated_id;
	RETURN updated_id;
	EXCEPTION
		WHEN OTHERS THEN RAISE NOTICE 'qgis_pkg.upd_ng_volumetype_atts(id: %): %',obj_1.id,SQLERRM;
END;
$$ 
LANGUAGE plpgsql;
COMMENT ON FUNCTION qgis_pkg.upd_ng_volumetype_atts(qgis_pkg.obj_ng_volumetype,varchar) IS 'Updates attributes of table ng_volumetype';
REVOKE EXECUTE ON FUNCTION qgis_pkg.upd_ng_volumetype_atts(qgis_pkg.obj_ng_volumetype,varchar) FROM public;

-----------------------------------------------------------
-- CREATE FUNCTION qgis_pkg.upd_ng_floorarea_atts
-----------------------------------------------------------

DROP FUNCTION IF EXISTS qgis_pkg.upd_ng_floorarea_atts(qgis_pkg.obj_ng_floorarea,varchar) CASCADE;
CREATE OR REPLACE FUNCTION qgis_pkg.upd_ng_floorarea_atts(obj_1 qgis_pkg.obj_ng_floorarea,cdb_schema varchar)
RETURNS bigint AS $$
DECLARE
	updated_id bigint;
BEGIN
	SELECT qgis_pkg.upd_t_ng_floorarea(obj_1,cdb_schema) INTO updated_id;
	RETURN updated_id;
	EXCEPTION
		WHEN OTHERS THEN RAISE NOTICE 'qgis_pkg.upd_ng_floorarea_atts(id: %): %',obj_1.id,SQLERRM;
END;
$$ 
LANGUAGE plpgsql;
COMMENT ON FUNCTION qgis_pkg.upd_ng_floorarea_atts(qgis_pkg.obj_ng_floorarea,varchar) IS 'Updates attributes of table ng_floorarea';
REVOKE EXECUTE ON FUNCTION qgis_pkg.upd_ng_floorarea_atts(qgis_pkg.obj_ng_floorarea,varchar) FROM public;

-----------------------------------------------------------
-- CREATE FUNCTION qgis_pkg.upd_ng_heatexchangetype_atts
-----------------------------------------------------------

DROP FUNCTION IF EXISTS qgis_pkg.upd_ng_heatexchangetype_atts(qgis_pkg.obj_ng_heatexchangetype,varchar) CASCADE;
CREATE OR REPLACE FUNCTION qgis_pkg.upd_ng_heatexchangetype_atts(obj_1 qgis_pkg.obj_ng_heatexchangetype,cdb_schema varchar)
RETURNS bigint AS $$
DECLARE
	updated_id bigint;
BEGIN
	SELECT qgis_pkg.upd_t_ng_heatexchangetype(obj_1,cdb_schema) INTO updated_id;
	RETURN updated_id;
	EXCEPTION
		WHEN OTHERS THEN RAISE NOTICE 'qgis_pkg.upd_ng_heatexchangetype_atts(id: %): %',obj_1.id,SQLERRM;
END;
$$ 
LANGUAGE plpgsql;
COMMENT ON FUNCTION qgis_pkg.upd_ng_heatexchangetype_atts(qgis_pkg.obj_ng_heatexchangetype,varchar) IS 'Updates attributes of table ng_heatexchangetype';
REVOKE EXECUTE ON FUNCTION qgis_pkg.upd_ng_heatexchangetype_atts(qgis_pkg.obj_ng_heatexchangetype,varchar) FROM public;

-----------------------------------------------------------
-- CREATE FUNCTION qgis_pkg.upd_ng_heightaboveground_atts
-----------------------------------------------------------

DROP FUNCTION IF EXISTS qgis_pkg.upd_ng_heightaboveground_atts(qgis_pkg.obj_ng_heightaboveground,varchar) CASCADE;
CREATE OR REPLACE FUNCTION qgis_pkg.upd_ng_heightaboveground_atts(obj_1 qgis_pkg.obj_ng_heightaboveground,cdb_schema varchar)
RETURNS bigint AS $$
DECLARE
	updated_id bigint;
BEGIN
	SELECT qgis_pkg.upd_t_ng_heightaboveground(obj_1,cdb_schema) INTO updated_id;
	RETURN updated_id;
	EXCEPTION
		WHEN OTHERS THEN RAISE NOTICE 'qgis_pkg.upd_ng_heightaboveground_atts(id: %): %',obj_1.id,SQLERRM;
END;
$$ 
LANGUAGE plpgsql;
COMMENT ON FUNCTION qgis_pkg.upd_ng_heightaboveground_atts(qgis_pkg.obj_ng_heightaboveground,varchar) IS 'Updates attributes of table ng_heightaboveground';
REVOKE EXECUTE ON FUNCTION qgis_pkg.upd_ng_heightaboveground_atts(qgis_pkg.obj_ng_heightaboveground,varchar) FROM public;

-----------------------------------------------------------
-- CREATE FUNCTION qgis_pkg.upd_ng_transmittance_atts
-----------------------------------------------------------

DROP FUNCTION IF EXISTS qgis_pkg.upd_ng_transmittance_atts(qgis_pkg.obj_ng_transmittance,varchar) CASCADE;
CREATE OR REPLACE FUNCTION qgis_pkg.upd_ng_transmittance_atts(obj_1 qgis_pkg.obj_ng_transmittance,cdb_schema varchar)
RETURNS bigint AS $$
DECLARE
	updated_id bigint;
BEGIN
	SELECT qgis_pkg.upd_t_ng_transmittance(obj_1,cdb_schema) INTO updated_id;
	RETURN updated_id;
	EXCEPTION
		WHEN OTHERS THEN RAISE NOTICE 'qgis_pkg.upd_ng_transmittance_atts(id: %): %',obj_1.id,SQLERRM;
END;
$$ 
LANGUAGE plpgsql;
COMMENT ON FUNCTION qgis_pkg.upd_ng_transmittance_atts(qgis_pkg.obj_ng_transmittance,varchar) IS 'Updates attributes of table ng_transmittance';
REVOKE EXECUTE ON FUNCTION qgis_pkg.upd_ng_transmittance_atts(qgis_pkg.obj_ng_transmittance,varchar) FROM public;





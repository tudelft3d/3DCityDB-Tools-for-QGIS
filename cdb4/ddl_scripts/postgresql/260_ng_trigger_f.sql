------------------------------------------------------------
-- CREATE TRIGGER FUNCTION qgis_pkg.tr_ins_ng_building
------------------------------------------------------------
DROP FUNCTION IF EXISTS qgis_pkg.tr_ins_ng_building CASCADE;
CREATE OR REPLACE FUNCTION qgis_pkg.tr_ins_ng_building()
RETURNS trigger AS
$$
DECLARE 
BEGIN
	RAISE EXCEPTION 'You are not allowed to insert new records using the QGIS plugin';
	RETURN OLD;
	EXCEPTION
		WHEN OTHERS THEN RAISE NOTICE 'qgis_pkg.tr_ins_ng_building(): %',SQLERRM;
END;
$$
LANGUAGE plpgsql;
COMMENT ON FUNCTION qgis_pkg.tr_ins_ng_building IS 'Trigger to block inserting a record into view of cdb_schema.ng_building';
REVOKE EXECUTE ON FUNCTION qgis_pkg.tr_ins_ng_building FROM public;

------------------------------------------------------------
-- CREATE TRIGGER FUNCTION qgis_pkg.tr_del_ng_building
------------------------------------------------------------
DROP FUNCTION IF EXISTS qgis_pkg.tr_del_ng_building CASCADE;
CREATE OR REPLACE FUNCTION qgis_pkg.tr_del_ng_building()
RETURNS trigger AS
$$
DECLARE
	cdb_schema CONSTANT varchar := split_part(TG_TABLE_NAME,'_ng_',1);	
BEGIN
	RAISE NOTICE '%',cdb_schema;
	EXECUTE format('
		SELECT %I.del_ng_building(ARRAY[$1]);',cdb_schema) USING OLD.id;
	RETURN OLD;
	EXCEPTION
		WHEN OTHERS THEN RAISE NOTICE 'qgis_pkg.tr_del_ng_building(id: %): %',OLD.id,SQLERRM;
END;
$$
LANGUAGE plpgsql;
COMMENT ON FUNCTION qgis_pkg.tr_del_ng_building IS 'Trigger to delete a record from view of cdb_schema.ng_building';
REVOKE EXECUTE ON FUNCTION qgis_pkg.tr_del_ng_building FROM public;

------------------------------------------------------------
-- CREATE TRIGGER FUNCTION qgis_pkg.tr_upd_ng_building
------------------------------------------------------------

DROP FUNCTION IF EXISTS qgis_pkg.tr_upd_ng_building() CASCADE;
CREATE OR REPLACE FUNCTION qgis_pkg.tr_upd_ng_building() 
RETURNS trigger AS $$
DECLARE
	cdb_schema CONSTANT varchar := split_part(TG_TABLE_NAME,'_ng_',1);
	obj qgis_pkg.obj_cityobject;
	obj_1 qgis_pkg.obj_building;
	obj_2 qgis_pkg.obj_ng_building;
BEGIN
	obj.id					:= OLD.id;
	obj.gmlid				:= NEW.gmlid;
	obj.gmlid_codespace        		:= NEW.gmlid_codespace;
	obj.name                   		:= NEW.name;
	obj.name_codespace         		:= NEW.name_codespace;
	obj.description            		:= NEW.description;
	obj.creation_date          		:= NEW.creation_date;
	obj.termination_date       		:= NEW.termination_date;
	obj.relative_to_terrain    		:= NEW.relative_to_terrain;
	obj.relative_to_water      		:= NEW.relative_to_water;
	obj.last_modification_date 		:= NEW.last_modification_date;
	obj.updating_person        		:= NEW.updating_person;
	obj.reason_for_update      		:= NEW.reason_for_update;
	obj.lineage                		:= NEW.lineage;

	obj_1.id                        	:= OLD.id;
	obj_1.class                             := NEW.class;
	obj_1.class_codespace                   := NEW.class_codespace;
	obj_1.function                          := array_to_string((SELECT array_agg(DISTINCT x) FROM unnest(NEW.function) AS t(x)), '--/\--');
	obj_1.function_codespace                := array_to_string((SELECT array_agg(DISTINCT x) FROM unnest(NEW.function_codespace) AS t(x)), '--/\--');
	obj_1.usage                             := array_to_string((SELECT array_agg(DISTINCT x) FROM unnest(NEW.usage) AS t(x)), '--/\--');
	obj_1.usage_codespace                   := array_to_string((SELECT array_agg(DISTINCT x) FROM unnest(NEW.usage_codespace) AS t(x)), '--/\--');
	obj_1.year_of_construction              := NEW.year_of_construction;
	obj_1.year_of_demolition                := NEW.year_of_demolition;
	obj_1.roof_type                         := NEW.roof_type;
	obj_1.roof_type_codespace               := NEW.roof_type_codespace;
	obj_1.measured_height                   := NEW.measured_height;
	obj_1.measured_height_unit              := NEW.measured_height_unit;
	obj_1.storeys_above_ground              := NEW.storeys_above_ground;
	obj_1.storeys_below_ground              := NEW.storeys_below_ground;
	obj_1.storey_heights_above_ground       := NEW.storey_heights_above_ground;
	obj_1.storey_heights_ag_unit            := NEW.storey_heights_ag_unit;
	obj_1.storey_heights_below_ground       := NEW.storey_heights_below_ground;
	obj_1.storey_heights_bg_unit            := NEW.storey_heights_bg_unit;		
	
	obj_2.id				:= OLD.id;
	obj_2.buildingtype			:= NEW.buildingtype;
	obj_2.buildingtype_codespace		:= NEW.buildingtype_codespace;
	obj_2.constructionweight		:= NEW.constructionweight;
	                                        
	PERFORM qgis_pkg.upd_ng_building_atts(obj,obj_1,obj_2,cdb_schema);

	RETURN NEW;
	EXCEPTION
		WHEN OTHERS THEN RAISE NOTICE 'qgis_pkg.tr_upd_ng_building(id: %): %',OLD.id,SQLERRM;

END;
$$ LANGUAGE plpgsql;
COMMENT ON FUNCTION qgis_pkg.tr_upd_ng_building IS 'Trigger to update a record in a view of cdb_schema.ng_building';
REVOKE EXECUTE ON FUNCTION qgis_pkg.tr_upd_ng_building FROM public;

------------------------------------------------------------
-- CREATE TRIGGER FUNCTION qgis_pkg.tr_ins_ng_thematic_surface
------------------------------------------------------------
DROP FUNCTION IF EXISTS qgis_pkg.tr_ins_ng_thematic_surface CASCADE;
CREATE OR REPLACE FUNCTION qgis_pkg.tr_ins_ng_thematic_surface()
RETURNS trigger AS
$$
DECLARE 
BEGIN
	RAISE EXCEPTION 'You are not allowed to insert new records using the QGIS plugin';
	RETURN OLD;
	EXCEPTION
		WHEN OTHERS THEN RAISE NOTICE 'qgis_pkg.tr_ins_ng_thematic_surface(): %',SQLERRM;
END;
$$
LANGUAGE plpgsql;
COMMENT ON FUNCTION qgis_pkg.tr_ins_ng_thematic_surface IS 'Trigger to block inserting a record into view of cdb_schema.thematic_surface';
REVOKE EXECUTE ON FUNCTION qgis_pkg.tr_ins_ng_thematic_surface FROM public;

------------------------------------------------------------
-- CREATE TRIGGER FUNCTION qgis_pkg.tr_del_ng_thematic_surface
------------------------------------------------------------
DROP FUNCTION IF EXISTS qgis_pkg.tr_del_ng_thematic_surface CASCADE;
CREATE OR REPLACE FUNCTION qgis_pkg.tr_del_ng_thematic_surface()
RETURNS trigger AS
$$
DECLARE
	cdb_schema CONSTANT varchar := split_part(TG_TABLE_NAME,'_ng_',1);	
BEGIN
	RAISE NOTICE '%',cdb_schema;
	EXECUTE format('
		SELECT %I.del_thematic_surface(ARRAY[$1]);',cdb_schema) USING OLD.id;
	RETURN OLD;
	EXCEPTION
		WHEN OTHERS THEN RAISE NOTICE 'qgis_pkg.tr_del_thematic_surface(id: %): %',OLD.id,SQLERRM;
END;
$$
LANGUAGE plpgsql;
COMMENT ON FUNCTION qgis_pkg.tr_del_thematic_surface IS 'Trigger to delete a record from view of cdb_schema.ng_building';
REVOKE EXECUTE ON FUNCTION qgis_pkg.tr_del_thematic_surface FROM public;

---------------------------------------------------------------------
-- CREATE TRIGGER FUNCTION qgis_pkg.tr_upd_ng_thematic_surface
---------------------------------------------------------------------

DROP FUNCTION IF EXISTS qgis_pkg.tr_upd_ng_thematic_surface CASCADE;
CREATE OR REPLACE FUNCTION qgis_pkg.tr_upd_ng_thematic_surface()
RETURNS trigger AS $$
DECLARE
	cdb_schema CONSTANT varchar := split_part(TG_TABLE_NAME,'_ng_',1);
	obj qgis_pkg.obj_cityobject;
BEGIN
	obj.id                     		:= OLD.id;
	obj.gmlid                  		:= NEW.gmlid;
	obj.gmlid_codespace        		:= NEW.gmlid_codespace;
	obj.name                   		:= NEW.name;
	obj.name_codespace         		:= NEW.name_codespace;
	obj.description            		:= NEW.description;
	obj.creation_date          		:= NEW.creation_date;
	obj.termination_date       		:= NEW.termination_date;
	obj.relative_to_terrain    		:= NEW.relative_to_terrain;
	obj.relative_to_water      		:= NEW.relative_to_water;
	obj.last_modification_date 		:= NEW.last_modification_date;
	obj.updating_person        		:= NEW.updating_person;
	obj.reason_for_update      		:= NEW.reason_for_update;
	obj.lineage                		:= NEW.lineage;

	PERFORM qgis_pkg.upd_thematic_surface_atts(obj,cdb_schema);

	RETURN NEW;
	EXCEPTION
		WHEN OTHERS THEN RAISE NOTICE 'qgis_pkg.tr_upd_thematic_surface(id: %): %',OLD.id,SQLERRM;
END;
$$ LANGUAGE plpgsql;
COMMENT ON FUNCTION qgis_pkg.tr_upd_ng_thematic_surface IS 'Trigger to update a record in a view of cdb_schema.thematic_surface';
REVOKE EXECUTE ON FUNCTION qgis_pkg.tr_upd_ng_thematic_surface FROM public;

---------------------------------------------------------------------
-- CREATE TRIGGER FUNCTION qgis_pkg.tr_ins_ng_thermalzone
---------------------------------------------------------------------

DROP FUNCTION IF EXISTS qgis_pkg.tr_ins_ng_thermalzone CASCADE;
CREATE OR REPLACE FUNCTION qgis_pkg.tr_ins_ng_thermalzone()
RETURNS trigger AS $$
DECLARE
BEGIN
	RAISE EXCEPTION 'You are not allowed to insert new records using the QGIS plugin';
	RETURN OLD;
	EXCEPTION
		WHEN OTHERS THEN RAISE NOTICE 'qgis_pkg.tr_ins_ng_thermalzone(): %',SQLERRM;
END;
$$
LANGUAGE plpgsql;
COMMENT ON FUNCTION qgis_pkg.tr_ins_ng_thematic_surface IS 'Trigger to block inserting a record into view of cdb_schema.thermalzone';
REVOKE EXECUTE ON FUNCTION qgis_pkg.tr_ins_ng_thermalzone FROM public;

---------------------------------------------------------------------
-- CREATE TRIGGER FUNCTION qgis_pkg.tr_del_ng_thermalzone
---------------------------------------------------------------------

DROP FUNCTION IF EXISTS qgis_pkg.tr_del_ng_thermalzone CASCADE;
CREATE OR REPLACE FUNCTION qgis_pkg.tr_del_ng_thermalzone()
RETURNS trigger AS $$
DECLARE
	cdb_schema CONSTANT varchar := split_part(TG_TABLE_NAME,'_ng_',1);	
BEGIN
	EXECUTE format('
		SELECT %I.del_ng_thermalzone(ARRAY[$1]);',cdb_schema) USING OLD.id;
	RETURN OLD;
	EXCEPTION
		WHEN OTHERS THEN RAISE NOTICE 'qgis_pkg.tr_del_ng_thermalzone(id: %): %',OLD.id,SQLERRM;
END;
$$
LANGUAGE plpgsql;
COMMENT ON FUNCTION qgis_pkg.tr_del_ng_thermalzone IS 'Trigger to delete a record from view of cdb_schema.ng_thermalzone';
REVOKE EXECUTE ON FUNCTION qgis_pkg.tr_del_ng_thermalzone FROM public;

---------------------------------------------------------------------
-- CREATE TRIGGER FUNCTION qgis_pkg.tr_upd_ng_thermalzone
---------------------------------------------------------------------

DROP FUNCTION IF EXISTS qgis_pkg.tr_upd_ng_thermalzone CASCADE;
CREATE OR REPLACE FUNCTION qgis_pkg.tr_upd_ng_thermalzone()
RETURNS trigger AS $$
DECLARE
	cdb_schema CONSTANT varchar := split_part(TG_TABLE_NAME,'_ng_',1);
	obj qgis_pkg.obj_cityobject;
	obj_1 qgis_pkg.obj_ng_thermalzone;
BEGIN
	obj.id					:= OLD.id;
	obj.gmlid                  		:= NEW.gmlid;
	obj.gmlid_codespace        		:= NEW.gmlid_codespace;
	obj.name                   		:= NEW.name;
	obj.name_codespace         		:= NEW.name_codespace;
	obj.description            		:= NEW.description;
	obj.creation_date          		:= NEW.creation_date;
	obj.termination_date       		:= NEW.termination_date;
	obj.relative_to_terrain    		:= NEW.relative_to_terrain;
	obj.relative_to_water      		:= NEW.relative_to_water;
	obj.last_modification_date 		:= NEW.last_modification_date;
	obj.updating_person        		:= NEW.updating_person;
	obj.reason_for_update      		:= NEW.reason_for_update;
	obj.lineage                		:= NEW.lineage;

	obj_1.id				:= OLD.id;
	obj_1.infiltrationrate			:= NEW.infiltrationrate;
	obj_1.infiltrationrate_uom		:= NEW.infiltrationrate_uom;
	obj_1.iscooled				:= NEW.iscooled;
	obj_1.isheated				:= NEW.isheated;

	PERFORM qgis_pkg.upd_ng_thermalzone_atts(obj,obj_1,cdb_schema);
	
	RETURN NEW;
	EXCEPTION
		WHEN OTHERS THEN RAISE NOTICE 'qgis_pkg.tr_upd_ng_thermalzone(id: %): %',OLD.id,SQLERRM;
END;
$$
LANGUAGE plpgsql;
COMMENT ON FUNCTION qgis_pkg.tr_upd_ng_thermalzone IS 'Trigger to update a record in a view of cdb_schema.ng_thermalzone';
REVOKE EXECUTE ON FUNCTION qgis_pkg.tr_upd_ng_thermalzone FROM public;

---------------------------------------------------------------------
-- CREATE TRIGGER FUNCTION qgis_pkg.tr_ins_ng_thermalboundary
---------------------------------------------------------------------

DROP FUNCTION IF EXISTS qgis_pkg.tr_ins_ng_thermalboundary CASCADE;
CREATE OR REPLACE FUNCTION qgis_pkg.tr_ins_ng_thermalboundary()
RETURNS trigger AS $$
DECLARE
BEGIN
	RAISE EXCEPTION 'You are not allowed to insert records using the QGIS plugin';
	RETURN OLD;
	EXCEPTION
		WHEN OTHERS THEN RAISE NOTICE 'qgis_pkg.tr_ins_ng_thermalboundary(): %',SQLERRM;
END;
$$
LANGUAGE plpgsql;
COMMENT ON FUNCTION qgis_pkg.tr_ins_ng_thermalboundary IS 'Trigger to block inserting a record into a view of cdb_schema.ng_thermalboundary';
REVOKE EXECUTE ON FUNCTION qgis_pkg.tr_ins_ng_thermalboundary FROM public;

---------------------------------------------------------------------
-- CREATE TRIGGER FUNCTION qgis_pkg.tr_del_ng_thermalboundary
---------------------------------------------------------------------

DROP FUNCTION IF EXISTS qgis_pkg.tr_del_ng_thermalboundary CASCADE;
CREATE OR REPLACE FUNCTION qgis_pkg.tr_del_ng_thermalboundary()
RETURNS trigger AS $$
DECLARE
	cdb_schema CONSTANT varchar := split_part(TG_TABLE_NAME,'_ng_',1);
BEGIN
	EXECUTE format('
		SELECT %I.del_ng_thermalboundary(ARRAY[$1]);',cdb_schema) USING OLD.id;
	RETURN OLD;
	EXCEPTION
		WHEN OTHERS THEN RAISE NOTICE 'qgis_pkg.tr_del_ng_thermalboundary(id: %): %',OLD.id,SQLERRM;
END;
$$
LANGUAGE plpgsql;
COMMENT ON FUNCTION qgis_pkg.tr_del_ng_thermalboundary IS 'Trigger to delete a record from a view of cdb_schema.ng_themalboundary';
REVOKE EXECUTE ON FUNCTION qgis_pkg.tr_del_ng_thermalboundary FROM public;

---------------------------------------------------------------------
-- CREATE TRIGGER FUNCTION qgis_pkg.tr_upd_ng_thermalboundary
---------------------------------------------------------------------

DROP FUNCTION IF EXISTS qgis_pkg.tr_upd_ng_thermalboundary CASCADE;
CREATE OR REPLACE FUNCTION qgis_pkg.tr_upd_ng_thermalboundary()
RETURNS trigger AS $$
DECLARE
	cdb_schema CONSTANT varchar := split_part(TG_TABLE_NAME,'_ng_',1);
	obj qgis_pkg.obj_cityobject;
	obj_1 qgis_pkg.obj_ng_thermalboundary;
BEGIN
	obj.id                     		:= OLD.id;
	obj.gmlid                  		:= NEW.gmlid;
	obj.gmlid_codespace        		:= NEW.gmlid_codespace;
	obj.name                   		:= NEW.name;
	obj.name_codespace         		:= NEW.name_codespace;
	obj.description            		:= NEW.description;
	obj.creation_date          		:= NEW.creation_date;
	obj.termination_date      		:= NEW.termination_date;
	obj.relative_to_terrain    		:= NEW.relative_to_terrain;
	obj.relative_to_water      		:= NEW.relative_to_water;
	obj.last_modification_date 		:= NEW.last_modification_date;
	obj.updating_person        		:= NEW.updating_person;
	obj.reason_for_update      		:= NEW.reason_for_update;
	obj.lineage                		:= NEW.lineage;

	obj_1.id				:= OLD.id;
	obj_1.area				:= NEW.area;
	obj_1.area_uom				:= NEW.area_uom;
	obj_1.azimuth				:= NEW.azimuth;
	obj_1.azimuth_uom			:= NEW.azimuth_uom;
	obj_1.inclination			:= NEW.inclination;
	obj_1.inclination_uom			:= NEW.inclination_uom;
	obj_1.thermalboundarytype		:= NEW.thermalboundarytype;

	PERFORM qgis_pkg.upd_ng_thermalboundary_atts(obj,obj_1,cdb_schema);
	
	RETURN NEW;
	EXCEPTION
		WHEN OTHERS THEN RAISE NOTICE 'qgis_pkg.tr_upd_ng_thermalboundary(id: %): %',OLD.id,SQLERRM;
END;
$$
LANGUAGE plpgsql;
COMMENT ON FUNCTION qgis_pkg.tr_upd_ng_thermalboundary IS 'Trigger to update a record in a view of cdb_schema.ng_thermalboundary';
REVOKE EXECUTE ON FUNCTION qgis_pkg.tr_upd_ng_thermalboundary FROM public;

---------------------------------------------------------------------
-- CREATE TRIGGER FUNCTION qgis_pkg.tr_ins_ng_thermalopening
---------------------------------------------------------------------

DROP FUNCTION IF EXISTS qgis_pkg.tr_ins_ng_thermalopening CASCADE;
CREATE OR REPLACE FUNCTION qgis_pkg.tr_ins_ng_thermalopening()
RETURNS trigger AS $$
DECLARE
BEGIN
	RAISE NOTICE 'You are not allowed to insert records using the QGIS plugin';
	RETURN OLD;
	EXCEPTION
		WHEN OTHERS THEN RAISE NOTICE 'qgis_pkg.tr_ins_ng_thermalopening(): %',SQLERRM;
END;
$$
LANGUAGE plpgsql;
COMMENT ON FUNCTION qgis_pkg.tr_ins_ng_thermalopening IS 'Trigger to block inserting a record into a view of cdb_schema.ng_thermalopening';
REVOKE EXECUTE ON FUNCTION qgis_pkg.tr_ins_ng_thermalopening FROM public;

---------------------------------------------------------------------
-- CREATE TRIGGER FUNCTION qgis_pkg.tr_del_ng_thermalopening
---------------------------------------------------------------------

DROP FUNCTION IF EXISTS qgis_pkg.tr_del_ng_thermalopening CASCADE;
CREATE OR REPLACE FUNCTION qgis_pkg.tr_del_ng_thermalopening()
RETURNS trigger AS $$
DECLARE 
	cdb_schema CONSTANT varchar := split_part(TG_TABLE_NAME,'_ng_',1);
BEGIN
	EXECUTE format('
		SELECT %I.del_ng_thermalopening(ARRAY[$1])',cdb_schema) USING OLD.id;
	RETURN OLD;
	EXCEPTION
		WHEN OTHERS THEN RAISE NOTICE 'qgis_pkg.tr_del_ng_thermalopening(id: %): %',OLD.id,SQLERRM;
END;
$$
LANGUAGE plpgsql;
COMMENT ON FUNCTION qgis_pkg.tr_del_ng_thermalopening IS 'Trigger to delete a record from a view of cdb_schema.ng_thermalboundary';
REVOKE EXECUTE ON FUNCTION qgis_pkg.tr_del_ng_thermalopening FROM public;

---------------------------------------------------------------------
-- CREATE TRIGGER FUNCTION qgis_pkg.tr_upd_ng_thermalopening
---------------------------------------------------------------------

DROP FUNCTION IF EXISTS qgis_pkg.tr_upd_ng_thermalopening CASCADE;
CREATE OR REPLACE FUNCTION qgis_pkg.tr_upd_ng_thermalopening()
RETURNS trigger AS $$
DECLARE
	cdb_schema CONSTANT varchar := split_part(TG_TABLE_NAME,'_ng_',1);
	obj qgis_pkg.obj_cityobject;
	obj_1 qgis_pkg.obj_ng_thermalopening;
BEGIN
	obj.id                     		:= OLD.id;
	obj.gmlid                  		:= NEW.gmlid;
	obj.gmlid_codespace        		:= NEW.gmlid_codespace;
	obj.name                   		:= NEW.name;
	obj.name_codespace         		:= NEW.name_codespace;
	obj.description            		:= NEW.description;
	obj.creation_date          		:= NEW.creation_date;
	obj.termination_date      		:= NEW.termination_date;
	obj.relative_to_terrain    		:= NEW.relative_to_terrain;
	obj.relative_to_water      		:= NEW.relative_to_water;
	obj.last_modification_date 		:= NEW.last_modification_date;
	obj.updating_person        		:= NEW.updating_person;
	obj.reason_for_update      		:= NEW.reason_for_update;
	obj.lineage                		:= NEW.lineage;

	obj_1.id				:= OLD.id;
	obj_1.area				:= NEW.area;
	obj_1.area_uom				:= NEW.area_uom;
	
	PERFORM qgis_pkg.upd_ng_thermalopening_atts(obj,obj_1,cdb_schema);

	RETURN NEW;
	EXCEPTION
		WHEN OTHERS THEN RAISE NOTICE 'qgis_pkg.tr_upd_ng_thermalopening(id: %): %',OLD.id,SQLERRM;
END;
$$
LANGUAGE plpgsql;
COMMENT ON FUNCTION qgis_pkg.tr_upd_ng_thermalopening IS 'Trigger to update a record in a view of cdb_schema.ng_thermalopening';
REVOKE EXECUTE ON FUNCTION qgis_pkg.tr_upd_ng_thermalopening FROM public;

---------------------------------------------------------------------
-- CREATE TRIGGER FUNCTION qgis_pkg.tr_ins_ng_weatherstation
---------------------------------------------------------------------

DROP FUNCTION IF EXISTS qgis_pkg.tr_ins_ng_weatherstation CASCADE;
CREATE OR REPLACE FUNCTION qgis_pkg.tr_ins_ng_weatherstation()
RETURNS trigger AS $$
DECLARE
BEGIN
	RAISE NOTICE 'You are not allowed to insert records using the QGIS plugin';
       	RETURN OLD;
	EXCEPTION
		WHEN OTHERS THEN RAISE NOTICE 'qgis_pkg.tr_ins_ng_weatherstation(): %',SQLERRM;
END;
$$
LANGUAGE plpgsql;
COMMENT ON FUNCTION qgis_pkg.tr_ins_ng_weatherstation IS 'Trigger to block inserting a record into a view of cdb_schema.ng_weatherstation';
REVOKE EXECUTE ON FUNCTION qgis_pkg.tr_ins_ng_weatherstation FROM public;

---------------------------------------------------------------------
-- CREATE TRIGGER FUNCTION qgis_pkg.tr_del_ng_weatherstation
---------------------------------------------------------------------

DROP FUNCTION IF EXISTS qgis_pkg.tr_del_ng_weatherstation CASCADE;
CREATE OR REPLACE FUNCTION qgis_pkg.tr_del_ng_weatherstation()
RETURNS trigger AS $$
DECLARE
	cdb_schema CONSTANT varchar := split_part(TG_TABLE_NAME,'_ng_',1);

BEGIN
	EXECUTE format('
		SELECT %I.del_ng_weatherstation(ARRAY[$1])',cdb_schema) USING OLD.id;
        RETURN updated_id;
	EXCEPTION
		WHEN OTHERS THEN RAISE NOTICE 'qgis_pkg.tr_del_ng_weatherstation(id: %): %',OLD.id,SQLERRM;
END;
$$
LANGUAGE plpgsql;
COMMENT ON FUNCTION qgis_pkg.tr_del_ng_weatherstation IS 'Trigger to delete a record from a view of cdb_schema.ng_weatherstation';
REVOKE EXECUTE ON FUNCTION qgis_pkg.tr_del_ng_weatherstation FROM public;

---------------------------------------------------------------------
-- CREATE TRIGGER FUNCTION qgis_pkg.tr_upd_ng_weatherstation
---------------------------------------------------------------------

DROP FUNCTION IF EXISTS qgis_pkg.tr_upd_ng_weatherstation CASCADE;
CREATE OR REPLACE FUNCTION qgis_pkg.tr_upd_ng_weatherstation()
RETURNS trigger AS $$
DECLARE
	cdb_schema CONSTANT varchar := split_part(TG_TABLE_NAME,'_ng_',1);
	obj qgis_pkg.obj_cityobject;
	obj_1 qgis_pkg.obj_ng_weatherstation;
BEGIN
	obj.id                                  := OLD.id;
        obj.gmlid                               := NEW.gmlid;
        obj.gmlid_codespace                     := NEW.gmlid_codespace;
        obj.name                                := NEW.name;
        obj.name_codespace                      := NEW.name_codespace;
        obj.description                         := NEW.description;
        obj.creation_date                       := NEW.creation_date;
        obj.termination_date                    := NEW.termination_date;
        obj.relative_to_terrain                 := NEW.relative_to_terrain;
        obj.relative_to_water                   := NEW.relative_to_water;
        obj.last_modification_date              := NEW.last_modification_date;
        obj.updating_person                     := NEW.updating_person;
        obj.reason_for_update                   := NEW.reason_for_update;
        obj.lineage                             := NEW.lineage;

	obj_1.id				:= OLD.id;
	obj_1.genericapplicationpropertyof	:= NEW.genericapplicationpropertyof;
	obj_1.stationname			:= NEW.stationname;
	obj_1.position				:= OLD.position;

	PERFORM qgis_pkg.upd_ng_weatherstation_atts(obj,obj_1,cdb_schema);
	
	RETURN NEW;
	EXCEPTION
		WHEN OTHERS THEN RAISE NOTICE 'qgis_pkg.tr_upd_ng_weatherstation(id: %): %',OLD.id,SQLERRM;
END;
$$
LANGUAGE plpgsql;
COMMENT ON FUNCTION qgis_pkg.tr_upd_ng_weatherstation IS 'Trigger to update a record of a view of cdb_schema.ng_weatherstation';
REVOKE EXECUTE ON FUNCTION qgis_pkg.tr_upd_ng_weatherstation FROM public;

---------------------------------------------------------------------
-- CREATE TRIGGER FUNCTION qgis_pkg.tr_ins_ng_weatherdata
---------------------------------------------------------------------

DROP FUNCTION IF EXISTS qgis_pkg.tr_ins_ng_weatherdata CASCADE;
CREATE OR REPLACE FUNCTION qgis_pkg.tr_ins_ng_weatherdata()
RETURNS trigger AS $$
DECLARE
BEGIN
	RAISE NOTICE 'You are not allowed to insert records using the QGIS plugin';
       	RETURN OLD;
	EXCEPTION
		WHEN OTHERS THEN RAISE NOTICE 'qgis_pkg.tr_ins_ng_weatherdata(): %',SQLERRM;
END;
$$
LANGUAGE plpgsql;
COMMENT ON FUNCTION qgis_pkg.tr_ins_ng_weatherdata IS 'Trigger to block inserting a record into a view of cdb_schema.ng_weatherstation';
REVOKE EXECUTE ON FUNCTION qgis_pkg.tr_ins_ng_weatherdata FROM public;

---------------------------------------------------------------------
-- CREATE TRIGGER FUNCTION qgis_pkg.tr_del_ng_weatherdata
---------------------------------------------------------------------

DROP FUNCTION IF EXISTS qgis_pkg.tr_del_ng_weatherdata CASCADE;
CREATE OR REPLACE FUNCTION qgis_pkg.tr_del_ng_weatherdata()
RETURNS trigger AS $$
DECLARE
	cdb_schema CONSTANT varchar := split_part(TG_TABLE_NAME,'_ng_',1);

BEGIN
	EXECUTE format('
		SELECT %I.del_ng_weatherdata(ARRAY[$1])',cdb_schema) USING OLD.id;
        RETURN updated_id;
	EXCEPTION
		WHEN OTHERS THEN RAISE NOTICE 'qgis_pkg.tr_del_ng_weatherdata(id: %): %',OLD.id,SQLERRM;
END;
$$
LANGUAGE plpgsql;
COMMENT ON FUNCTION qgis_pkg.tr_del_ng_weatherdata IS 'Trigger to delete a record from a view of cdb_schema.ng_weatherstation';
REVOKE EXECUTE ON FUNCTION qgis_pkg.tr_del_ng_weatherdata FROM public;

---------------------------------------------------------------------
-- CREATE TRIGGER FUNCTION qgis_pkg.tr_upd_ng_weatherdata
---------------------------------------------------------------------

DROP FUNCTION IF EXISTS qgis_pkg.tr_upd_ng_weatherdata CASCADE;
CREATE OR REPLACE FUNCTION qgis_pkg.tr_upd_ng_weatherdata()
RETURNS trigger AS $$
DECLARE
	cdb_schema CONSTANT varchar := split_part(TG_TABLE_NAME,'_ng_',1);
	obj qgis_pkg.obj_cityobject;
	obj_1 qgis_pkg.obj_ng_weatherdata;
BEGIN
	obj.id                                  := OLD.id;
        obj.gmlid                               := NEW.gmlid;
        obj.gmlid_codespace                     := NEW.gmlid_codespace;
        obj.name                                := NEW.name;
        obj.name_codespace                      := NEW.name_codespace;
        obj.description                         := NEW.description;
        obj.creation_date                       := NEW.creation_date;
        obj.termination_date                    := NEW.termination_date;
        obj.relative_to_terrain                 := NEW.relative_to_terrain;
        obj.relative_to_water                   := NEW.relative_to_water;
        obj.last_modification_date              := NEW.last_modification_date;
        obj.updating_person                     := NEW.updating_person;
        obj.reason_for_update                   := NEW.reason_for_update;
        obj.lineage                             := NEW.lineage;

	obj_1.id				:= OLD.id;
	obj_1.weatherdatatype			:= NEW.weatherdatatype;
	obj_1.cityobject_weatherdata_id		:= OLD.cityobject_weatherdata_id;
	obj_1.position				:= OLD.position;
	obj_1.values_id				:= OLD.values_id;
	obj_1.weatherstation_parameter_id	:= OLD.weatherstation_parameter_id;

	PERFORM qgis_pkg.upd_ng_weatherdata_atts(obj,obj_1,cdb_schema);
	
	RETURN NEW;
	EXCEPTION
		WHEN OTHERS THEN RAISE NOTICE 'qgis_pkg.tr_upd_ng_weatherdata(id: %): %',OLD.id,SQLERRM;
END;
$$
LANGUAGE plpgsql;
COMMENT ON FUNCTION qgis_pkg.tr_upd_ng_weatherdata IS 'Trigger to update a record of a view of cdb_schema.ng_weatherstation';
REVOKE EXECUTE ON FUNCTION qgis_pkg.tr_upd_ng_weatherdata FROM public;

---------------------------------------------------------------------
-- CREATE TRIGGER FUNCTION qgis_pkg.tr_ins_ng_dailyschedule
---------------------------------------------------------------------

DROP FUNCTION IF EXISTS qgis_pkg.tr_ins_ng_dailyschedule CASCADE;
CREATE OR REPLACE FUNCTION qgis_pkg.tr_ins_ng_dailyschedule()
RETURNS trigger AS $$
DECLARE
BEGIN
	RAISE NOTICE 'You are not allowed to insert records using the QGIS plugin';
       	RETURN OLD;
	EXCEPTION
		WHEN OTHERS THEN RAISE NOTICE 'qgis_pkg.tr_ins_ng_dailyschedule(): %',SQLERRM;
END;
$$
LANGUAGE plpgsql;
COMMENT ON FUNCTION qgis_pkg.tr_ins_ng_dailyschedule IS 'Trigger to block inserting a record into a view of cdb_schema.ng_dailyschedule';
REVOKE EXECUTE ON FUNCTION qgis_pkg.tr_ins_ng_dailyschedule FROM public;

---------------------------------------------------------------------
-- CREATE TRIGGER FUNCTION qgis_pkg.tr_del_ng_dailyschedule
---------------------------------------------------------------------

DROP FUNCTION IF EXISTS qgis_pkg.tr_del_ng_dailyschedule CASCADE;
CREATE OR REPLACE FUNCTION qgis_pkg.tr_del_ng_dailyschedule()
RETURNS trigger AS $$
DECLARE
	cdb_schema CONSTANT varchar := split_part(TG_TABLE_NAME,'_ng_',1);

BEGIN
	EXECUTE format('
		SELECT %I.del_ng_dailyschedule(ARRAY[$1])',cdb_schema) USING OLD.id;
        RETURN updated_id;
	EXCEPTION
		WHEN OTHERS THEN RAISE NOTICE 'qgis_pkg.tr_del_ng_dailyschedule(id: %): %',OLD.id,SQLERRM;
END;
$$
LANGUAGE plpgsql;
COMMENT ON FUNCTION qgis_pkg.tr_del_ng_dailyschedule IS 'Trigger to delete a record from a view of cdb_schema.ng_dailyschedule';
REVOKE EXECUTE ON FUNCTION qgis_pkg.tr_del_ng_dailyschedule FROM public;

---------------------------------------------------------------------
-- CREATE TRIGGER FUNCTION qgis_pkg.tr_upd_ng_dailyschedule
---------------------------------------------------------------------

DROP FUNCTION IF EXISTS qgis_pkg.tr_upd_ng_dailyschedule CASCADE;
CREATE OR REPLACE FUNCTION qgis_pkg.tr_upd_ng_dailyschedule()
RETURNS trigger AS $$
DECLARE
	cdb_schema CONSTANT varchar := split_part(TG_TABLE_NAME,'_ng_',1);
	obj qgis_pkg.obj_ng_dailyschedule;
BEGIN
	obj.id					:= OLD.id;
	obj.daytype				:= NEW.daytype;
	obj.periodofyear_dailyschedul_id	:= OLD.periodofyear_dailyschedul_id;
	obj.schedule_id				:= OLD.schedule_id;

	PERFORM qgis_pkg.upd_ng_dailyschedule_atts(obj,cdb_schema);
	RETURN NEW;
	EXCEPTION
		WHEN OTHERS THEN RAISE NOTICE 'qgis_pkg.tr_upd_ng_dailyschedule(id :%): %',OLD.id,SQLERRM;
END;
$$
LANGUAGE plpgsql;
COMMENT ON FUNCTION qgis_pkg.tr_upd_ng_dailyschedule IS 'Trigger to update a record in a view of cdb_schema.ng_dailyschedule';
REVOKE EXECUTE ON FUNCTION qgis_pkg.tr_upd_ng_dailyschedule FROM public;

---------------------------------------------------------------------
-- CREATE TRIGGER FUNCTION qgis_pkg.tr_ins_ng_periodofyear
---------------------------------------------------------------------

DROP FUNCTION IF EXISTS qgis_pkg.tr_ins_ng_periodofyear CASCADE;
CREATE OR REPLACE FUNCTION qgis_pkg.tr_ins_ng_periodofyear()
RETURNS trigger AS $$
DECLARE
BEGIN
	RAISE NOTICE 'You are not allowed to insert records using the QGIS plugin';
       	RETURN OLD;
	EXCEPTION
		WHEN OTHERS THEN RAISE NOTICE 'qgis_pkg.tr_ins_ng_periodofyear(): %',SQLERRM;
END;
$$
LANGUAGE plpgsql;
COMMENT ON FUNCTION qgis_pkg.tr_ins_ng_periodofyear IS 'Trigger to block inserting a record into a view of cdb_schema.ng_periodofyear';
REVOKE EXECUTE ON FUNCTION qgis_pkg.tr_ins_ng_periodofyear FROM public;

---------------------------------------------------------------------
-- CREATE TRIGGER FUNCTION qgis_pkg.tr_del_ng_periodofyear
---------------------------------------------------------------------

DROP FUNCTION IF EXISTS qgis_pkg.tr_del_ng_periodofyear CASCADE;
CREATE OR REPLACE FUNCTION qgis_pkg.tr_del_ng_periodofyear()
RETURNS trigger AS $$
DECLARE
	cdb_schema CONSTANT varchar := split_part(TG_TABLE_NAME,'_ng_',1);

BEGIN
	EXECUTE format('
		SELECT %I.del_ng_periodofyear(ARRAY[$1])',cdb_schema) USING OLD.id;
        RETURN updated_id;
	EXCEPTION
		WHEN OTHERS THEN RAISE NOTICE 'qgis_pkg.tr_del_ng_periodofyear(id: %): %',OLD.id,SQLERRM;
END;
$$
LANGUAGE plpgsql;
COMMENT ON FUNCTION qgis_pkg.tr_del_ng_periodofyear IS 'Trigger to delete a record from a view of cdb_schema.ng_periodofyear';
REVOKE EXECUTE ON FUNCTION qgis_pkg.tr_del_ng_periodofyear FROM public;

--------------------------------------------------------------------
-- CREATE TRIGGER FUNCTION qgis_pkg.tr_upd_ng_periodofyear
--------------------------------------------------------------------

DROP FUNCTION IF EXISTS qgis_pkg.tr_upd_ng_periodofyear CASCADE;
CREATE OR REPLACE FUNCTION qgis_pkg.tr_upd_ng_periodofyear()
RETURNS trigger AS $$
DECLARE
	cdb_schema CONSTANT varchar := split_part(TG_TABLE_NAME,'_ng_',1);
	obj qgis_pkg.obj_ng_periodofyear;
BEGIN
	obj.id					:= OLD.id;
	obj.timeperiodprop_beginposition	:= NEW.timeperiodprop_beginposition;
	obj.timeperiodproper_endposition	:= NEW.timeperiodproper_endposition;

	PERFORM qgis_pkg.upd_ng_periodofyear_atts(obj,cdb_schema);
	RETURN NEW;
	EXCEPTION
		WHEN OTHERS THEN RAISE NOTICE 'qgis_pkg.tr_upd_ng_periodofyear(id: %): %',OLD.id,SQLERRM;
END;
$$
LANGUAGE plpgsql;
COMMENT ON FUNCTION qgis_pkg.tr_upd_ng_periodofyear IS 'Trigger to update a record in a view of cdb_schema.ng_periodofyear';
REVOKE EXECUTE ON FUNCTION qgis_pkg.tr_upd_ng_periodofyear FROM public;

---------------------------------------------------------------------
-- CREATE TRIGGER FUNCTION qgis_pkg.tr_ins_ng_regulartimeseries
---------------------------------------------------------------------

DROP FUNCTION IF EXISTS qgis_pkg.tr_ins_ng_regulartimeseries CASCADE;
CREATE OR REPLACE FUNCTION qgis_pkg.tr_ins_ng_regulartimeseries()
RETURNS trigger AS $$
DECLARE
BEGIN
	RAISE NOTICE 'You are not allowed to insert records using the QGIS plugin';
       	RETURN OLD;
	EXCEPTION
		WHEN OTHERS THEN RAISE NOTICE 'qgis_pkg.tr_ins_ng_regulartimeseries(): %',SQLERRM;
END;
$$
LANGUAGE plpgsql;
COMMENT ON FUNCTION qgis_pkg.tr_ins_ng_regulartimeseries IS 'Trigger to block inserting a record into a view of cdb_schema.ng_regulartimeseries';
REVOKE EXECUTE ON FUNCTION qgis_pkg.tr_ins_ng_regulartimeseries FROM public;

---------------------------------------------------------------------
-- CREATE TRIGGER FUNCTION qgis_pkg.tr_del_ng_regulartimeseries
---------------------------------------------------------------------

DROP FUNCTION IF EXISTS qgis_pkg.tr_del_ng_regulartimeseries CASCADE;
CREATE OR REPLACE FUNCTION qgis_pkg.tr_del_ng_regulartimeseries()
RETURNS trigger AS $$
DECLARE
	cdb_schema CONSTANT varchar := split_part(TG_TABLE_NAME,'_ng_',1);

BEGIN
	EXECUTE format('
		SELECT %I.del_ng_regulartimeseries(ARRAY[$1])',cdb_schema) USING OLD.id;
        RETURN updated_id;
	EXCEPTION
		WHEN OTHERS THEN RAISE NOTICE 'qgis_pkg.tr_del_ng_regulartimeseries(id: %): %',OLD.id,SQLERRM;
END;
$$
LANGUAGE plpgsql;
COMMENT ON FUNCTION qgis_pkg.tr_del_ng_regulartimeseries IS 'Trigger to delete a record from a view of cdb_schema.ng_regulartimeseries';
REVOKE EXECUTE ON FUNCTION qgis_pkg.tr_del_ng_regulartimeseries FROM public;

---------------------------------------------------------------------
-- CREATE OR REPLACE FUNCTION qgis_pkg.tr_upd_ng_regulartimeseries
---------------------------------------------------------------------

DROP FUNCTION IF EXISTS qgis_pkg.tr_upd_ng_regulartimeseries CASCADE;
CREATE OR REPLACE FUNCTION qgis_pkg.tr_upd_ng_regulartimeseries()
RETURNS trigger AS $$
DECLARE 
	cdb_schema CONSTANT varchar := split_part(TG_TABLE_NAME,'_ng_',1);
	obj qgis_pkg.obj_cityobject;
	obj_1 qgis_pkg.obj_ng_regulartimeseries;
	obj_2 qgis_pkg.obj_ng_timeseries;
BEGIN
	obj.id                     		:= OLD.co_id;
	obj.gmlid                  		:= NEW.gmlid;
	obj.name                   		:= NEW.name;
	obj.description            		:= NEW.description;
	obj.creation_date          		:= NEW.creation_date;
	obj.last_modification_date 		:= NEW.last_modification_date;
	obj.updating_person        		:= NEW.updating_person;

	obj_1.id				:= OLD.co_id;
	obj_1.timeinterval			:= NEW.timeinterval;
	obj_1.timeinterval_factor		:= NEW.timeinterval_factor;
	obj_1.timeinterval_radix		:= NEW.timeinterval_radix;
	obj_1.timeinterval_unit			:= NEW.timeinterval_unit;
	obj_1.timeperiodprop_beginposition	:= NEW.timeperiodprop_beginposition;
	obj_1.timeperiodproper_endposition	:= NEW.timeperiodproper_endposition;
	obj_1.values_				:= NEW.values_;
        obj_1.values_uom			:= NEW.values_uom;
	
	obj_2.id				:= OLD.co_id;
	obj_2.timevaluesprop_acquisitionme	:= NEW.timevaluesprop_acquisitionme;
	obj_2.timevaluesprop_interpolation	:= NEW.timevaluesprop_interpolation;
	obj_2.timevaluesprop_qualitydescri	:= NEW.timevaluesprop_qualitydescri;
	obj_2.timevaluesprop_thematicdescr	:= NEW.timevaluesprop_thematicdescr;
	obj_2.timevaluespropertiest_source	:= NEW.timevaluespropertiest_source;

	PERFORM qgis_pkg.upd_ng_regulartimeseries_atts(obj,obj_1,obj_2,cdb_schema);
	RETURN NEW;
	EXCEPTION
		WHEN OTHERS THEN RAISE NOTICE 'qgis_pkg.tr_upd_ng_regulartimeseries(id: %): %',OLD.co_id,SQLERRM;
END;
$$
LANGUAGE plpgsql;
COMMENT ON FUNCTION qgis_pkg.tr_upd_ng_regulartimeseries IS 'Trigger to update a record in a view of cdb_schema.ng_regulartimeseries';
REVOKE EXECUTE ON FUNCTION qgis_pkg.tr_upd_ng_regulartimeseries FROM public;

---------------------------------------------------------------------
-- CREATE TRIGGER FUNCTION qgis_pkg.tr_ins_ng_regulartimeseriesfile
---------------------------------------------------------------------

DROP FUNCTION IF EXISTS qgis_pkg.tr_ins_ng_regulartimeseriesfile CASCADE;
CREATE OR REPLACE FUNCTION qgis_pkg.tr_ins_ng_regulartimeseriesfile()
RETURNS trigger AS $$
DECLARE
BEGIN
	RAISE NOTICE 'You are not allowed to insert records using the QGIS plugin';
       	RETURN OLD;
	EXCEPTION
		WHEN OTHERS THEN RAISE NOTICE 'qgis_pkg.tr_ins_ng_regulartimeseriesfile(): %',SQLERRM;
END;
$$
LANGUAGE plpgsql;
COMMENT ON FUNCTION qgis_pkg.tr_ins_ng_regulartimeseriesfile IS 'Trigger to block inserting a record into a view of cdb_schema.ng_regulartimeseriesfile';
REVOKE EXECUTE ON FUNCTION qgis_pkg.tr_ins_ng_regulartimeseriesfile FROM public;

---------------------------------------------------------------------
-- CREATE TRIGGER FUNCTION qgis_pkg.tr_del_ng_regulartimeseriesfile
---------------------------------------------------------------------

DROP FUNCTION IF EXISTS qgis_pkg.tr_del_ng_regulartimeseriesfile CASCADE;
CREATE OR REPLACE FUNCTION qgis_pkg.tr_del_ng_regulartimeseriesfile()
RETURNS trigger AS $$
DECLARE
	cdb_schema CONSTANT varchar := split_part(TG_TABLE_NAME,'_ng_',1);

BEGIN
	EXECUTE format('
		SELECT %I.del_ng_regulartimeseriesfile(ARRAY[$1])',cdb_schema) USING OLD.id;
        RETURN updated_id;
	EXCEPTION
		WHEN OTHERS THEN RAISE NOTICE 'qgis_pkg.tr_del_ng_regulartimeseriesfile(id: %): %',OLD.id,SQLERRM;
END;
$$
LANGUAGE plpgsql;
COMMENT ON FUNCTION qgis_pkg.tr_del_ng_regulartimeseriesfile IS 'Trigger to delete a record from a view of cdb_schema.ng_regulartimeseriesfile';
REVOKE EXECUTE ON FUNCTION qgis_pkg.tr_del_ng_regulartimeseriesfile FROM public;

---------------------------------------------------------------------
-- CREATE TRIGGER FUNCTION qgis_pkg.tr_upd_ng_regulartimeseriesfile
---------------------------------------------------------------------

DROP FUNCTION IF EXISTS qgis_pkg.tr_upd_ng_regulartimeseriesfile CASCADE;
CREATE OR REPLACE FUNCTION qgis_pkg.tr_upd_ng_regulartimeseriesfile()
RETURNS trigger AS $$
DECLARE 
	cdb_schema CONSTANT varchar := split_part(TG_TABLE_NAME,'_ng_',1);
	obj qgis_pkg.obj_cityobject;
	obj_1 qgis_pkg.obj_ng_regulartimeseriesfile;
	obj_2 qgis_pkg.obj_ng_timeseries;
BEGIN
	obj.id                     		:= OLD.co_id;
	obj.gmlid                  		:= NEW.gmlid;
	obj.name                   		:= NEW.name;
	obj.description            		:= NEW.description;
	obj.creation_date          		:= NEW.creation_date;
	obj.last_modification_date 		:= NEW.last_modification_date;
	obj.updating_person        		:= NEW.updating_person;

	obj_1.id				:= OLD.co_id;
	obj_1.timeinterval			:= NEW.timeinterval;
	obj_1.timeinterval_factor		:= NEW.timeinterval_factor;
	obj_1.timeinterval_radix		:= NEW.timeinterval_radix;
	obj_1.timeinterval_unit			:= NEW.timeinterval_unit;
	obj_1.timeperiodprop_beginposition	:= NEW.timeperiodprop_beginposition;
	obj_1.timeperiodproper_endposition	:= NEW.timeperiodproper_endposition;
	obj_1.values_				:= NEW.values_;
        obj_1.values_uom			:= NEW.values_uom;
	
	obj_2.id				:= OLD.id;
	obj_2.decimalsymbol			:= NEW.decimalsymbol;
	obj_2.field_separator			:= NEW.fieldseparator;
	obj_2.file_				:= NEW.file_;
	obj_2.numberofheaderlines		:= NEW.numberofheaderlines;
	obj_2.recordseparator			:= NEW.recordseparator;
	obj_2.timeinterval			:= NEW.timeinterval;
	obj_2.timeinterval_factor		:= NEW.timeinterval_factor;
	obj_2.timeinterval_radix		:= NEW.timeinterval_radix;
	obj_2.timeinterval_unit			:= NEW.timeinterval_unit;
	obj_2.timeperiodprop_beginposition	:= NEW.timeperiodprop_beginposition;
	obj_2.timeperiodproper_endposition	:= NEW.timeperiodproper_endposition;
	obj_2.uom				:= NEW.uom;
	obj_2.valuecolumnnumber			:= NEW.valuecolumnnumber;

	PERFORM qgis_pkg.upd_ng_regulartimeseriesfile_atts(obj,obj_1,obj_2,cdb_schema);
	RETURN NEW;
	EXCEPTION
		WHEN OTHERS THEN RAISE NOTICE 'qgis_pkg.tr_upd_ng_regulartimeseriesfile(id: %): %',OLD.co_id,SQLERRM;
END;
$$
LANGUAGE plpgsql;
COMMENT ON FUNCTION qgis_pkg.tr_upd_ng_regulartimeseriesfile IS 'Trigger to update a record in a view of cdb_schema.ng_regulartimeseriesfile';
REVOKE EXECUTE ON FUNCTION qgis_pkg.tr_upd_ng_regulartimeseriesfile FROM public;

---------------------------------------------------------------------
-- CREATE TRIGGER FUNCTION qgis_pkg.tr_ins_ng_usagezone
---------------------------------------------------------------------

DROP FUNCTION IF EXISTS qgis_pkg.tr_ins_ng_usagezone CASCADE;
CREATE OR REPLACE FUNCTION qgis_pkg.tr_ins_ng_usagezone()
RETURNS trigger AS $$
DECLARE
BEGIN
	RAISE NOTICE 'You are not allowed to insert records using the QGIS plugin';
       	RETURN OLD;
	EXCEPTION
		WHEN OTHERS THEN RAISE NOTICE 'qgis_pkg.tr_ins_ng_usagezone(): %',SQLERRM;
END;
$$
LANGUAGE plpgsql;
COMMENT ON FUNCTION qgis_pkg.tr_ins_ng_usagezone IS 'Trigger to block inserting a record into a view of cdb_schema.ng_usagezone';
REVOKE EXECUTE ON FUNCTION qgis_pkg.tr_ins_ng_usagezone FROM public;

---------------------------------------------------------------------
-- CREATE TRIGGER FUNCTION qgis_pkg.tr_del_ng_usagezone
---------------------------------------------------------------------

DROP FUNCTION IF EXISTS qgis_pkg.tr_del_ng_usagezone CASCADE;
CREATE OR REPLACE FUNCTION qgis_pkg.tr_del_ng_usagezone()
RETURNS trigger AS $$
DECLARE
	cdb_schema CONSTANT varchar := split_part(TG_TABLE_NAME,'_ng_',1);
	
BEGIN
	EXECUTE format('
		SELECT %I.del_ng_usagezone(ARRAY[$1])',cdb_schema) USING OLD.id;
        RETURN OLD; 
	EXCEPTION
		WHEN OTHERS THEN RAISE NOTICE 'qgis_pkg.tr_del_ng_usagezone(id: %): %',OLD.id,SQLERRM;
END;
$$
LANGUAGE plpgsql;
COMMENT ON FUNCTION qgis_pkg.tr_del_ng_usagezone IS 'Trigger to delete a record from a view of cdb_schema.ng_usagezone';
REVOKE EXECUTE ON FUNCTION qgis_pkg.tr_del_ng_usagezone FROM public;

---------------------------------------------------------------------
-- CREATE TRIGGER FUNCTION qgis_pkg.tr_upd_ng_usagezone
---------------------------------------------------------------------

DROP FUNCTION IF EXISTS qgis_pkg.tr_upd_ng_usagezone CASCADE;
CREATE OR REPLACE FUNCTION qgis_pkg.tr_upd_ng_usagezone()
RETURNS trigger AS $$
DECLARE 
	cdb_schema CONSTANT varchar := split_part(TG_TABLE_NAME,'_ng_',1);
	obj qgis_pkg.obj_cityobject;
	obj_1 qgis_pkg.obj_ng_usagezone;
BEGIN
	obj.id                                  := OLD.id;
        obj.gmlid                               := NEW.gmlid;
        obj.gmlid_codespace                     := NEW.gmlid_codespace;
        obj.name                                := NEW.name;
        obj.name_codespace                      := NEW.name_codespace;
        obj.description                         := NEW.description;
        obj.creation_date                       := NEW.creation_date;
        obj.termination_date                    := NEW.termination_date;
        obj.relative_to_terrain                 := NEW.relative_to_terrain;
        obj.relative_to_water                   := NEW.relative_to_water;
        obj.last_modification_date              := NEW.last_modification_date;
        obj.updating_person                     := NEW.updating_person;
        obj.reason_for_update                   := NEW.reason_for_update;
        obj.lineage                             := NEW.lineage;
	
	obj_1.id				:= OLD.id;
	obj_1.usagezonetype			:= NEW.usagezonetype;
	obj_1.usagezonetype_codespace		:= NEW.usagezonetype_codespace;
	
	PERFORM qgis_pkg.upd_ng_usagezone_atts(obj,obj_1,cdb_schema);
	RETURN NEW;
	EXCEPTION
		WHEN OTHERS THEN RAISE NOTICE 'qgis_pkg.tr_upd_ng_usagezone(id: %): %',OLD.id,SQLERRM;
END;
$$
LANGUAGE plpgsql;
COMMENT ON FUNCTION qgis_pkg.tr_upd_ng_usagezone IS 'Trigger to update a record in a view of cdb_schema.ng_usagezone';
REVOKE EXECUTE ON FUNCTION qgis_pkg.tr_upd_ng_usagezone FROM public;

---------------------------------------------------------------------
-- CREATE TRIGGER FUNCTION qgis_pkg.tr_ins_ng_facilities
---------------------------------------------------------------------

DROP FUNCTION IF EXISTS qgis_pkg.tr_ins_ng_facilities CASCADE;
CREATE OR REPLACE FUNCTION qgis_pkg.tr_ins_ng_facilities()
RETURNS trigger AS $$
DECLARE
BEGIN
	RAISE NOTICE 'You are not allowed to insert records using the QGIS plugin';
       	RETURN OLD;
	EXCEPTION
		WHEN OTHERS THEN RAISE NOTICE 'qgis_pkg.tr_ins_ng_facilities(): %',SQLERRM;
END;
$$
LANGUAGE plpgsql;
COMMENT ON FUNCTION qgis_pkg.tr_ins_ng_facilities IS 'Trigger to block inserting a record into a view of cdb_schema.ng_facilities';
REVOKE EXECUTE ON FUNCTION qgis_pkg.tr_ins_ng_facilities FROM public;

---------------------------------------------------------------------
-- CREATE TRIGGER FUNCTION qgis_pkg.tr_del_ng_facilities
---------------------------------------------------------------------

DROP FUNCTION IF EXISTS qgis_pkg.tr_del_ng_facilities CASCADE;
CREATE OR REPLACE FUNCTION qgis_pkg.tr_del_ng_facilities()
RETURNS trigger AS $$
DECLARE
	cdb_schema CONSTANT varchar := split_part(TG_TABLE_NAME,'_ng_',1);

BEGIN
	EXECUTE format('
		SELECT %I.del_ng_facilities(ARRAY[$1])',cdb_schema) USING OLD.id;
        RETURN updated_id;
	EXCEPTION
		WHEN OTHERS THEN RAISE NOTICE 'qgis_pkg.tr_del_ng_facilities(id: %): %',OLD.id,SQLERRM;
END;
$$
LANGUAGE plpgsql;
COMMENT ON FUNCTION qgis_pkg.tr_del_ng_facilities IS 'Trigger to delete a record from a view of cdb_schema.ng_facilities';
REVOKE EXECUTE ON FUNCTION qgis_pkg.tr_del_ng_facilities FROM public;

---------------------------------------------------------------------
-- CREATE TRIGGER FUNCTION qgis_pkg.tr_upd_ng_facilities
---------------------------------------------------------------------

DROP FUNCTION IF EXISTS qgis_pkg.tr_upd_ng_facilities CASCADE;
CREATE OR REPLACE FUNCTION qgis_pkg.tr_upd_ng_facilities()
RETURNS trigger AS $$
DECLARE 
	cdb_schema CONSTANT varchar := split_part(TG_TABLE_NAME,'_ng_',1);
	obj qgis_pkg.obj_cityobject;
	obj_1 qgis_pkg.obj_ng_facilities;
BEGIN
	obj.id                     		:= OLD.co_id;
	obj.id                     		:= OLD.co_id;
	obj.id                                  := OLD.id;
        obj.gmlid                               := NEW.gmlid;
        obj.gmlid_codespace                     := NEW.gmlid_codespace;
        obj.name                                := NEW.name;
        obj.name_codespace                      := NEW.name_codespace;
        obj.description                         := NEW.description;
        obj.creation_date                       := NEW.creation_date;
        obj.termination_date                    := NEW.termination_date;
        obj.relative_to_terrain                 := NEW.relative_to_terrain;
        obj.relative_to_water                   := NEW.relative_to_water;
        obj.last_modification_date              := NEW.last_modification_date;
        obj.updating_person                     := NEW.updating_person;
        obj.reason_for_update                   := NEW.reason_for_update;
        obj.lineage                             := NEW.lineage;

	obj_1.id				:= OLD.co_id;
	
	PERFORM qgis_pkg.upd_ng_facilities_atts(obj,obj_1,cdb_schema);
	RETURN NEW;
	EXCEPTION
		WHEN OTHERS THEN RAISE NOTICE 'qgis_pkg.tr_upd_ng_facilities(id: %): %',OLD.co_id,SQLERRM;
END;
$$
LANGUAGE plpgsql;
COMMENT ON FUNCTION qgis_pkg.tr_upd_ng_facilities IS 'Trigger to update a record in a view of cdb_schema.ng_facilities';
REVOKE EXECUTE ON FUNCTION qgis_pkg.tr_upd_ng_facilities FROM public;

---------------------------------------------------------------------
-- CREATE TRIGGER FUNCTION qgis_pkg.tr_ins_ng_occupants
---------------------------------------------------------------------

DROP FUNCTION IF EXISTS qgis_pkg.tr_ins_ng_occupants CASCADE;
CREATE OR REPLACE FUNCTION qgis_pkg.tr_ins_ng_occupants()
RETURNS trigger AS $$
DECLARE
BEGIN
	RAISE NOTICE 'You are not allowed to insert records using the QGIS plugin';
       	RETURN OLD;
	EXCEPTION
		WHEN OTHERS THEN RAISE NOTICE 'qgis_pkg.tr_ins_ng_occupants(): %',SQLERRM;
END;
$$
LANGUAGE plpgsql;
COMMENT ON FUNCTION qgis_pkg.tr_ins_ng_occupants IS 'Trigger to block inserting a record into a view of cdb_schema.ng_occupants';
REVOKE EXECUTE ON FUNCTION qgis_pkg.tr_ins_ng_occupants FROM public;

---------------------------------------------------------------------
-- CREATE TRIGGER FUNCTION qgis_pkg.tr_del_ng_occupants
---------------------------------------------------------------------

DROP FUNCTION IF EXISTS qgis_pkg.tr_del_ng_occupants CASCADE;
CREATE OR REPLACE FUNCTION qgis_pkg.tr_del_ng_occupants()
RETURNS trigger AS $$
DECLARE
	cdb_schema CONSTANT varchar := split_part(TG_TABLE_NAME,'_ng_',1);

BEGIN
	EXECUTE format('
		SELECT %I.del_ng_occupants(ARRAY[$1])',cdb_schema) USING OLD.id;
        RETURN updated_id;
	EXCEPTION
		WHEN OTHERS THEN RAISE NOTICE 'qgis_pkg.tr_del_ng_occupants(id: %): %',OLD.id,SQLERRM;
END;
$$
LANGUAGE plpgsql;
COMMENT ON FUNCTION qgis_pkg.tr_del_ng_occupants IS 'Trigger to delete a record from a view of cdb_schema.ng_occupants';
REVOKE EXECUTE ON FUNCTION qgis_pkg.tr_del_ng_occupants FROM public;

---------------------------------------------------------------------
-- CREATE TRIGGER FUNCTION qgis_pkg.tr_upd_ng_occupants
---------------------------------------------------------------------

DROP FUNCTION IF EXISTS qgis_pkg.tr_upd_ng_occupants CASCADE;
CREATE OR REPLACE FUNCTION qgis_pkg.tr_upd_ng_occupants()
RETURNS trigger AS $$
DECLARE 
	cdb_schema CONSTANT varchar := split_part(TG_TABLE_NAME,'_ng_',1);
	obj qgis_pkg.obj_cityobject;
	obj_1 qgis_pkg.obj_ng_occupants;
BEGIN
	obj.id                     		:= OLD.co_id;
	obj.id                     		:= OLD.co_id;
	obj.id                                  := OLD.id;
        obj.gmlid                               := NEW.gmlid;
        obj.gmlid_codespace                     := NEW.gmlid_codespace;
        obj.name                                := NEW.name;
        obj.name_codespace                      := NEW.name_codespace;
        obj.description                         := NEW.description;
        obj.creation_date                       := NEW.creation_date;
        obj.termination_date                    := NEW.termination_date;
        obj.relative_to_terrain                 := NEW.relative_to_terrain;
        obj.relative_to_water                   := NEW.relative_to_water;
        obj.last_modification_date              := NEW.last_modification_date;
        obj.updating_person                     := NEW.updating_person;
        obj.reason_for_update                   := NEW.reason_for_update;
        obj.lineage                             := NEW.lineage;

	obj_1.id				:= OLD.co_id;
	obj_1.numberofoccupants			:= NEW.numberofoccupants;

	PERFORM qgis_pkg.upd_ng_occupants_atts(obj,obj_1,cdb_schema);
	RETURN NEW;
	EXCEPTION
		WHEN OTHERS THEN RAISE NOTICE 'qgis_pkg.tr_upd_ng_occupants(id: %): %',OLD.co_id,SQLERRM;
END;
$$
LANGUAGE plpgsql;
COMMENT ON FUNCTION qgis_pkg.tr_upd_ng_occupants IS 'Trigger to update a record in a view of cdb_schema.ng_occupants';
REVOKE EXECUTE ON FUNCTION qgis_pkg.tr_upd_ng_occupants FROM public;

---------------------------------------------------------------------
-- CREATE TRIGGER FUNCTION qgis_pkg.tr_ins_ng_construction
---------------------------------------------------------------------

DROP FUNCTION IF EXISTS qgis_pkg.tr_ins_ng_construction CASCADE;
CREATE OR REPLACE FUNCTION qgis_pkg.tr_ins_ng_construction()
RETURNS trigger AS $$
DECLARE
BEGIN
	RAISE NOTICE 'You are not allowed to insert records using the QGIS plugin';
       	RETURN OLD;
	EXCEPTION
		WHEN OTHERS THEN RAISE NOTICE 'qgis_pkg.tr_ins_ng_construction(): %',SQLERRM;
END;
$$
LANGUAGE plpgsql;
COMMENT ON FUNCTION qgis_pkg.tr_ins_ng_construction IS 'Trigger to block inserting a record into a view of cdb_schema.ng_construction';
REVOKE EXECUTE ON FUNCTION qgis_pkg.tr_ins_ng_construction FROM public;

---------------------------------------------------------------------
-- CREATE TRIGGER FUNCTION qgis_pkg.tr_del_ng_construction
---------------------------------------------------------------------

DROP FUNCTION IF EXISTS qgis_pkg.tr_del_ng_construction CASCADE;
CREATE OR REPLACE FUNCTION qgis_pkg.tr_del_ng_construction()
RETURNS trigger AS $$
DECLARE
	cdb_schema CONSTANT varchar := split_part(TG_TABLE_NAME,'_ng_',1);

BEGIN
	EXECUTE format('
		SELECT %I.del_ng_construction(ARRAY[$1])',cdb_schema) USING OLD.id;
        RETURN updated_id;
	EXCEPTION
		WHEN OTHERS THEN RAISE NOTICE 'qgis_pkg.tr_del_ng_construction(id: %): %',OLD.id,SQLERRM;
END;
$$
LANGUAGE plpgsql;
COMMENT ON FUNCTION qgis_pkg.tr_del_ng_construction IS 'Trigger to delete a record from a view of cdb_schema.ng_construction';
REVOKE EXECUTE ON FUNCTION qgis_pkg.tr_del_ng_construction FROM public;

---------------------------------------------------------------------
-- CREATE TRIGGER FUNCTION qgis_pkg.tr_upd_ng_construction
---------------------------------------------------------------------

DROP FUNCTION IF EXISTS qgis_pkg.tr_upd_ng_construction CASCADE;
CREATE OR REPLACE FUNCTION qgis_pkg.tr_upd_ng_construction()
RETURNS trigger AS $$
DECLARE 
	cdb_schema CONSTANT varchar := split_part(TG_TABLE_NAME,'_ng_',1);
	obj qgis_pkg.obj_cityobject;
	obj_1 qgis_pkg.obj_ng_construction;
BEGIN


	obj.id                                  := OLD.id;
        obj.gmlid                               := NEW.gmlid;
        obj.gmlid_codespace                     := NEW.gmlid_codespace;
        obj.name                                := NEW.name;
        obj.name_codespace                      := NEW.name_codespace;
        obj.description                         := NEW.description;
        obj.creation_date                       := NEW.creation_date;
        obj.termination_date                    := NEW.termination_date;
        obj.relative_to_terrain                 := NEW.relative_to_terrain;
        obj.relative_to_water                   := NEW.relative_to_water;
        obj.last_modification_date              := NEW.last_modification_date;
        obj.updating_person                     := NEW.updating_person;
        obj.reason_for_update                   := NEW.reason_for_update;
        obj.lineage                             := NEW.lineage;

	obj_1.id				:= OLD.id;
	obj_1.uvalue				:= NEW.uvalue;
	obj_1.uvalue_uom			:= NEW.uvalue_uom;
	
	PERFORM qgis_pkg.upd_ng_construction_atts(obj,obj_1,cdb_schema);
	RETURN NEW;
	EXCEPTION
		WHEN OTHERS THEN RAISE NOTICE 'qgis_pkg.tr_upd_ng_construction(id: %): %',OLD.id,SQLERRM;
END;
$$
LANGUAGE plpgsql;
COMMENT ON FUNCTION qgis_pkg.tr_upd_ng_construction IS 'Trigger to update a record in a view of cdb_schema.ng_construction';
REVOKE EXECUTE ON FUNCTION qgis_pkg.tr_upd_ng_construction FROM public;

---------------------------------------------------------------------
-- CREATE TRIGGER FUNCTION qgis_pkg.tr_ins_ng_layer
---------------------------------------------------------------------

DROP FUNCTION IF EXISTS qgis_pkg.tr_ins_ng_layer CASCADE;
CREATE OR REPLACE FUNCTION qgis_pkg.tr_ins_ng_layer()
RETURNS trigger AS $$
DECLARE
BEGIN
	RAISE NOTICE 'You are not allowed to insert records using the QGIS plugin';
       	RETURN OLD;
	EXCEPTION
		WHEN OTHERS THEN RAISE NOTICE 'qgis_pkg.tr_ins_ng_layer(): %',SQLERRM;
END;
$$
LANGUAGE plpgsql;
COMMENT ON FUNCTION qgis_pkg.tr_ins_ng_layer IS 'Trigger to block inserting a record into a view of cdb_schema.ng_layer';
REVOKE EXECUTE ON FUNCTION qgis_pkg.tr_ins_ng_layer FROM public;

---------------------------------------------------------------------
-- CREATE TRIGGER FUNCTION qgis_pkg.tr_del_ng_layer
---------------------------------------------------------------------

DROP FUNCTION IF EXISTS qgis_pkg.tr_del_ng_layer CASCADE;
CREATE OR REPLACE FUNCTION qgis_pkg.tr_del_ng_layer()
RETURNS trigger AS $$
DECLARE
	cdb_schema CONSTANT varchar := split_part(TG_TABLE_NAME,'_ng_',1);

BEGIN
	EXECUTE format('
		SELECT %I.del_ng_layer(ARRAY[$1])',cdb_schema) USING OLD.id;
        RETURN updated_id;
	EXCEPTION
		WHEN OTHERS THEN RAISE NOTICE 'qgis_pkg.tr_del_ng_layer(id: %): %',OLD.id,SQLERRM;
END;
$$
LANGUAGE plpgsql;
COMMENT ON FUNCTION qgis_pkg.tr_del_ng_layer IS 'Trigger to delete a record from a view of cdb_schema.ng_layer';
REVOKE EXECUTE ON FUNCTION qgis_pkg.tr_del_ng_layer FROM public;

---------------------------------------------------------------------
-- CREATE TRIGGER FUNCTION qgis_pkg.tr_upd_ng_layer
---------------------------------------------------------------------

DROP FUNCTION IF EXISTS qgis_pkg.tr_upd_ng_layer CASCADE;
CREATE OR REPLACE FUNCTION qgis_pkg.tr_upd_ng_layer()
RETURNS trigger AS $$
DECLARE 
	cdb_schema CONSTANT varchar := split_part(TG_TABLE_NAME,'_ng_',1);
	obj qgis_pkg.obj_cityobject;
	obj_1 qgis_pkg.obj_ng_layer;
BEGIN
	obj.id                     		:= OLD.co_id;
	obj.id                     		:= OLD.co_id;
	obj.id                                  := OLD.id;
        obj.gmlid                               := NEW.gmlid;
        obj.gmlid_codespace                     := NEW.gmlid_codespace;
        obj.name                                := NEW.name;
        obj.name_codespace                      := NEW.name_codespace;
        obj.description                         := NEW.description;
        obj.creation_date                       := NEW.creation_date;
        obj.termination_date                    := NEW.termination_date;
        obj.relative_to_terrain                 := NEW.relative_to_terrain;
        obj.relative_to_water                   := NEW.relative_to_water;
        obj.last_modification_date              := NEW.last_modification_date;
        obj.updating_person                     := NEW.updating_person;
        obj.reason_for_update                   := NEW.reason_for_update;
        obj.lineage                             := NEW.lineage;

	obj_1.id				:= OLD.co_id;

	PERFORM qgis_pkg.upd_ng_layer_atts(obj,obj_1,cdb_schema);
	RETURN NEW;
	EXCEPTION
		WHEN OTHERS THEN RAISE NOTICE 'qgis_pkg.tr_upd_ng_layer(id: %): %',OLD.co_id,SQLERRM;
END;
$$
LANGUAGE plpgsql;
COMMENT ON FUNCTION qgis_pkg.tr_upd_ng_layer IS 'Trigger to update a record in a view of cdb_schema.ng_layer';
REVOKE EXECUTE ON FUNCTION qgis_pkg.tr_upd_ng_layer FROM public;

---------------------------------------------------------------------
-- CREATE TRIGGER FUNCTION qgis_pkg.tr_ins_ng_layercomponent
---------------------------------------------------------------------

DROP FUNCTION IF EXISTS qgis_pkg.tr_ins_ng_layercomponent CASCADE;
CREATE OR REPLACE FUNCTION qgis_pkg.tr_ins_ng_layercomponent()
RETURNS trigger AS $$
DECLARE
BEGIN
	RAISE NOTICE 'You are not allowed to insert records using the QGIS plugin';
       	RETURN OLD;
	EXCEPTION
		WHEN OTHERS THEN RAISE NOTICE 'qgis_pkg.tr_ins_ng_layercomponent(): %',SQLERRM;
END;
$$
LANGUAGE plpgsql;
COMMENT ON FUNCTION qgis_pkg.tr_ins_ng_layercomponent IS 'Trigger to block inserting a record into a view of cdb_schema.ng_layercomponent';
REVOKE EXECUTE ON FUNCTION qgis_pkg.tr_ins_ng_layercomponent FROM public;

---------------------------------------------------------------------
-- CREATE TRIGGER FUNCTION qgis_pkg.tr_del_ng_layercomponent
---------------------------------------------------------------------

DROP FUNCTION IF EXISTS qgis_pkg.tr_del_ng_layercomponent CASCADE;
CREATE OR REPLACE FUNCTION qgis_pkg.tr_del_ng_layercomponent()
RETURNS trigger AS $$
DECLARE
	cdb_schema CONSTANT varchar := split_part(TG_TABLE_NAME,'_ng_',1);

BEGIN
	EXECUTE format('
		SELECT %I.del_ng_layercomponent(ARRAY[$1])',cdb_schema) USING OLD.id;
        RETURN updated_id;
	EXCEPTION
		WHEN OTHERS THEN RAISE NOTICE 'qgis_pkg.tr_del_ng_layercomponent(id: %): %',OLD.id,SQLERRM;
END;
$$
LANGUAGE plpgsql;
COMMENT ON FUNCTION qgis_pkg.tr_del_ng_layercomponent IS 'Trigger to delete a record from a view of cdb_schema.ng_layercomponent';
REVOKE EXECUTE ON FUNCTION qgis_pkg.tr_del_ng_layercomponent FROM public;

---------------------------------------------------------------------
-- CREATE TRIGGER FUNCTION qgis_pkg.tr_upd_ng_layercomponent
---------------------------------------------------------------------

DROP FUNCTION IF EXISTS qgis_pkg.tr_upd_ng_layercomponent CASCADE;
CREATE OR REPLACE FUNCTION qgis_pkg.tr_upd_ng_layercomponent()
RETURNS trigger AS $$
DECLARE 
	cdb_schema CONSTANT varchar := split_part(TG_TABLE_NAME,'_ng_',1);
	obj qgis_pkg.obj_cityobject;
	obj_1 qgis_pkg.obj_ng_layercomponent;
BEGIN
	obj.id                     		:= OLD.id;
	obj.id                     		:= OLD.id;
	obj.id                                  := OLD.id;
        obj.gmlid                               := NEW.gmlid;
        obj.gmlid_codespace                     := NEW.gmlid_codespace;
        obj.name                                := NEW.name;
        obj.name_codespace                      := NEW.name_codespace;
        obj.description                         := NEW.description;
        obj.creation_date                       := NEW.creation_date;
        obj.termination_date                    := NEW.termination_date;
        obj.relative_to_terrain                 := NEW.relative_to_terrain;
        obj.relative_to_water                   := NEW.relative_to_water;
        obj.last_modification_date              := NEW.last_modification_date;
        obj.updating_person                     := NEW.updating_person;
        obj.reason_for_update                   := NEW.reason_for_update;
        obj.lineage                             := NEW.lineage;

	obj_1.id				:= OLD.id;
	obj_1.areafraction			:= NEW.areafraction;
	obj_1.areafraction_uom			:= NEW.areafraction_uom;
	obj_1.thickness				:= NEW.thickness;
	obj_1.thickness_uom			:= NEW.thickness_uom;

	PERFORM qgis_pkg.upd_ng_layercomponent_atts(obj,obj_1,cdb_schema);
	RETURN NEW;
	EXCEPTION
		WHEN OTHERS THEN RAISE NOTICE 'qgis_pkg.tr_upd_ng_layercomponent(id: %): %',OLD.id,SQLERRM;
END;
$$
LANGUAGE plpgsql;
COMMENT ON FUNCTION qgis_pkg.tr_upd_ng_layercomponent IS 'Trigger to update a record in a view of cdb_schema.ng_layercomponent';
REVOKE EXECUTE ON FUNCTION qgis_pkg.tr_upd_ng_layercomponent FROM public;

---------------------------------------------------------------------
-- CREATE TRIGGER FUNCTION qgis_pkg.tr_ins_ng_gas
---------------------------------------------------------------------

DROP FUNCTION IF EXISTS qgis_pkg.tr_ins_ng_gas CASCADE;
CREATE OR REPLACE FUNCTION qgis_pkg.tr_ins_ng_gas()
RETURNS trigger AS $$
DECLARE
BEGIN
	RAISE NOTICE 'You are not allowed to insert records using the QGIS plugin';
       	RETURN OLD;
	EXCEPTION
		WHEN OTHERS THEN RAISE NOTICE 'qgis_pkg.tr_ins_ng_gas(): %',SQLERRM;
END;
$$
LANGUAGE plpgsql;
COMMENT ON FUNCTION qgis_pkg.tr_ins_ng_gas IS 'Trigger to block inserting a record into a view of cdb_schema.ng_gas';
REVOKE EXECUTE ON FUNCTION qgis_pkg.tr_ins_ng_gas FROM public;

---------------------------------------------------------------------
-- CREATE TRIGGER FUNCTION qgis_pkg.tr_del_ng_gas
---------------------------------------------------------------------

DROP FUNCTION IF EXISTS qgis_pkg.tr_del_ng_gas CASCADE;
CREATE OR REPLACE FUNCTION qgis_pkg.tr_del_ng_gas()
RETURNS trigger AS $$
DECLARE
	cdb_schema CONSTANT varchar := split_part(TG_TABLE_NAME,'_ng_',1);

BEGIN
	EXECUTE format('
		SELECT %I.del_ng_gas(ARRAY[$1])',cdb_schema) USING OLD.id;
        RETURN updated_id;
	EXCEPTION
		WHEN OTHERS THEN RAISE NOTICE 'qgis_pkg.tr_del_ng_gas(id: %): %',OLD.id,SQLERRM;
END;
$$
LANGUAGE plpgsql;
COMMENT ON FUNCTION qgis_pkg.tr_del_ng_gas IS 'Trigger to delete a record from a view of cdb_schema.ng_gas';
REVOKE EXECUTE ON FUNCTION qgis_pkg.tr_del_ng_gas FROM public;

---------------------------------------------------------------------
-- CREATE TRIGGER FUNCTION qgis_pkg.tr_upd_ng_gas
---------------------------------------------------------------------

DROP FUNCTION IF EXISTS qgis_pkg.tr_upd_ng_gas CASCADE;
CREATE OR REPLACE FUNCTION qgis_pkg.tr_upd_ng_gas()
RETURNS trigger AS $$
DECLARE 
	cdb_schema CONSTANT varchar := split_part(TG_TABLE_NAME,'_ng_',1);
	obj qgis_pkg.obj_cityobject;
	obj_1 qgis_pkg.obj_ng_gas;
BEGIN
	obj.id                     		:= OLD.co_id;
	obj.id                     		:= OLD.co_id;
	obj.id                                  := OLD.id;
        obj.gmlid                               := NEW.gmlid;
        obj.gmlid_codespace                     := NEW.gmlid_codespace;
        obj.name                                := NEW.name;
        obj.name_codespace                      := NEW.name_codespace;
        obj.description                         := NEW.description;
        obj.creation_date                       := NEW.creation_date;
        obj.termination_date                    := NEW.termination_date;
        obj.relative_to_terrain                 := NEW.relative_to_terrain;
        obj.relative_to_water                   := NEW.relative_to_water;
        obj.last_modification_date              := NEW.last_modification_date;
        obj.updating_person                     := NEW.updating_person;
        obj.reason_for_update                   := NEW.reason_for_update;
        obj.lineage                             := NEW.lineage;

	obj_1.id				:= OLD.co_id;
	obj_1.isventilated			:= NEW.isventilated;
	obj_1.rvalue				:= NEW.rvalue;
	obj_1.rvalue_uom			:= NEW.rvalue_uom;

	PERFORM qgis_pkg.upd_ng_gas_atts(obj,obj_1,cdb_schema);
	RETURN NEW;
	EXCEPTION
		WHEN OTHERS THEN RAISE NOTICE 'qgis_pkg.tr_upd_ng_gas(id: %): %',OLD.co_id,SQLERRM;
END;
$$
LANGUAGE plpgsql;
COMMENT ON FUNCTION qgis_pkg.tr_upd_ng_gas IS 'Trigger to update a record in a view of cdb_schema.ng_gas';
REVOKE EXECUTE ON FUNCTION qgis_pkg.tr_upd_ng_gas FROM public;

---------------------------------------------------------------------
-- CREATE TRIGGER FUNCTION qgis_pkg.tr_ins_ng_solidmaterial
---------------------------------------------------------------------

DROP FUNCTION IF EXISTS qgis_pkg.tr_ins_ng_solidmaterial CASCADE;
CREATE OR REPLACE FUNCTION qgis_pkg.tr_ins_ng_solidmaterial()
RETURNS trigger AS $$
DECLARE
BEGIN
	RAISE NOTICE 'You are not allowed to insert records using the QGIS plugin';
       	RETURN OLD;
	EXCEPTION
		WHEN OTHERS THEN RAISE NOTICE 'qgis_pkg.tr_ins_ng_solidmaterial(): %',SQLERRM;
END;
$$
LANGUAGE plpgsql;
COMMENT ON FUNCTION qgis_pkg.tr_ins_ng_solidmaterial IS 'Trigger to block inserting a record into a view of cdb_schema.ng_solidmaterial';
REVOKE EXECUTE ON FUNCTION qgis_pkg.tr_ins_ng_solidmaterial FROM public;

---------------------------------------------------------------------
-- CREATE TRIGGER FUNCTION qgis_pkg.tr_del_ng_solidmaterial
---------------------------------------------------------------------

DROP FUNCTION IF EXISTS qgis_pkg.tr_del_ng_solidmaterial CASCADE;
CREATE OR REPLACE FUNCTION qgis_pkg.tr_del_ng_solidmaterial()
RETURNS trigger AS $$
DECLARE
	cdb_schema CONSTANT varchar := split_part(TG_TABLE_NAME,'_ng_',1);

BEGIN
	EXECUTE format('
		SELECT %I.del_ng_solidmaterial(ARRAY[$1])',cdb_schema) USING OLD.id;
        RETURN updated_id;
	EXCEPTION
		WHEN OTHERS THEN RAISE NOTICE 'qgis_pkg.tr_del_ng_solidmaterial(id: %): %',OLD.id,SQLERRM;
END;
$$
LANGUAGE plpgsql;
COMMENT ON FUNCTION qgis_pkg.tr_del_ng_solidmaterial IS 'Trigger to delete a record from a view of cdb_schema.ng_solidmaterial';
REVOKE EXECUTE ON FUNCTION qgis_pkg.tr_del_ng_solidmaterial FROM public;

---------------------------------------------------------------------
-- CREATE TRIGGER FUNCTION qgis_pkg.tr_upd_ng_solidmaterial
---------------------------------------------------------------------

DROP FUNCTION IF EXISTS qgis_pkg.tr_upd_ng_solidmaterial CASCADE;
CREATE OR REPLACE FUNCTION qgis_pkg.tr_upd_ng_solidmaterial()
RETURNS trigger AS $$
DECLARE 
	cdb_schema CONSTANT varchar := split_part(TG_TABLE_NAME,'_ng_',1);
	obj qgis_pkg.obj_cityobject;
	obj_1 qgis_pkg.obj_ng_solidmaterial;
BEGIN
	obj.id                                  := OLD.id;
        obj.gmlid                               := NEW.gmlid;
        obj.gmlid_codespace                     := NEW.gmlid_codespace;
        obj.name                                := NEW.name;
        obj.name_codespace                      := NEW.name_codespace;
        obj.description                         := NEW.description;
        obj.creation_date                       := NEW.creation_date;
        obj.termination_date                    := NEW.termination_date;
        obj.relative_to_terrain                 := NEW.relative_to_terrain;
        obj.relative_to_water                   := NEW.relative_to_water;
        obj.last_modification_date              := NEW.last_modification_date;
        obj.updating_person                     := NEW.updating_person;
        obj.reason_for_update                   := NEW.reason_for_update;
        obj.lineage                             := NEW.lineage;

	obj_1.id				:= OLD.id;
	obj_1.conductivity			:= NEW.conductivity;
	obj_1.conductivity_uom			:= NEW.conductivity_uom;
	obj_1.density				:= NEW.density;
	obj_1.density_uom			:= NEW.density_uom;
	obj_1.permeance				:= NEW.permeance;
	obj_1.permeance_uom			:= NEW.permeance_uom;
	obj_1.specificheat			:= NEW.specificheat;
	obj_1.specificheat_uom			:= NEW.specificheat_uom;

	PERFORM qgis_pkg.upd_ng_solidmaterial_atts(obj,obj_1,cdb_schema);
	RETURN NEW;
	EXCEPTION
		WHEN OTHERS THEN RAISE NOTICE 'qgis_pkg.tr_upd_ng_solidmaterial(id: %): %',OLD.id,SQLERRM;
END;
$$
LANGUAGE plpgsql;
COMMENT ON FUNCTION qgis_pkg.tr_upd_ng_solidmaterial IS 'Trigger to update a record in a view of cdb_schema.ng_solidmaterial';
REVOKE EXECUTE ON FUNCTION qgis_pkg.tr_upd_ng_solidmaterial FROM public;

---------------------------------------------------------------------
-- CREATE TRIGGER FUNCTION qgis_pkg.tr_ins_ng_energydemand
---------------------------------------------------------------------

DROP FUNCTION IF EXISTS qgis_pkg.tr_ins_ng_energydemand CASCADE;
CREATE OR REPLACE FUNCTION qgis_pkg.tr_ins_ng_energydemand()
RETURNS trigger AS $$
DECLARE
BEGIN
	RAISE NOTICE 'You are not allowed to insert records using the QGIS plugin';
       	RETURN OLD;
	EXCEPTION
		WHEN OTHERS THEN RAISE NOTICE 'qgis_pkg.tr_ins_ng_energydemand(): %',SQLERRM;
END;
$$
LANGUAGE plpgsql;
COMMENT ON FUNCTION qgis_pkg.tr_ins_ng_energydemand IS 'Trigger to block inserting a record into a view of cdb_schema.ng_energydemand';
REVOKE EXECUTE ON FUNCTION qgis_pkg.tr_ins_ng_energydemand FROM public;

---------------------------------------------------------------------
-- CREATE TRIGGER FUNCTION qgis_pkg.tr_del_ng_energydemand
---------------------------------------------------------------------

DROP FUNCTION IF EXISTS qgis_pkg.tr_del_ng_energydemand CASCADE;
CREATE OR REPLACE FUNCTION qgis_pkg.tr_del_ng_energydemand()
RETURNS trigger AS $$
DECLARE
	cdb_schema CONSTANT varchar := split_part(TG_TABLE_NAME,'_ng_',1);

BEGIN
	EXECUTE format('
		SELECT %I.del_ng_energydemand(ARRAY[$1])',cdb_schema) USING OLD.id;
        RETURN updated_id;
	EXCEPTION
		WHEN OTHERS THEN RAISE NOTICE 'qgis_pkg.tr_del_ng_energydemand(id: %): %',OLD.id,SQLERRM;
END;
$$
LANGUAGE plpgsql;
COMMENT ON FUNCTION qgis_pkg.tr_del_ng_energydemand IS 'Trigger to delete a record from a view of cdb_schema.ng_energydemand';
REVOKE EXECUTE ON FUNCTION qgis_pkg.tr_del_ng_energydemand FROM public;

---------------------------------------------------------------------
-- CREATE TRIGGER FUNCTION qgis_pkg.tr_upd_ng_energydemand
---------------------------------------------------------------------

DROP FUNCTION IF EXISTS qgis_pkg.tr_upd_ng_energydemand CASCADE;
CREATE OR REPLACE FUNCTION qgis_pkg.tr_upd_ng_energydemand()
RETURNS trigger AS $$
DECLARE 
	cdb_schema CONSTANT varchar := split_part(TG_TABLE_NAME,'_ng_',1);
	obj_1 qgis_pkg.obj_ng_energydemand;
BEGIN
	obj_1.id				:= OLD.id;
	obj_1.cityobject_demands_id		:= NEW.cityobject_demands_id;
	obj_1.enduse				:= NEW.enduse;
	obj_1.energyamount_id			:= OLD.energyamount_id;
	obj_1.energycarriertype			:= NEW.energycarriertype;
	obj_1.energycarriertype_codespace	:= NEW.energycarriertype_codespace;
	obj_1.maximumload			:= NEW.maximumload;
	obj_1.maximumload_uom			:= NEW.maximumload_uom;

	PERFORM qgis_pkg.upd_ng_energydemand_atts(obj_1,cdb_schema);
	RETURN NEW;
	EXCEPTION
		WHEN OTHERS THEN RAISE NOTICE 'qgis_pkg.tr_upd_ng_energydemand(id: %): %',OLD.id,SQLERRM;
END;
$$
LANGUAGE plpgsql;
COMMENT ON FUNCTION qgis_pkg.tr_upd_ng_energydemand IS 'Trigger to update a record in a view of cdb_schema.ng_energydemand';
REVOKE EXECUTE ON FUNCTION qgis_pkg.tr_upd_ng_energydemand FROM public;

---------------------------------------------------------------------
-- CREATE TRIGGER FUNCTION qgis_pkg.tr_ins_ng_timevaluesproperties
---------------------------------------------------------------------

DROP FUNCTION IF EXISTS qgis_pkg.tr_ins_ng_timevaluesproperties CASCADE;
CREATE OR REPLACE FUNCTION qgis_pkg.tr_ins_ng_timevaluesproperties()
RETURNS trigger AS $$
DECLARE
BEGIN
	RAISE NOTICE 'You are not allowed to insert records using the QGIS plugin';
       	RETURN OLD;
	EXCEPTION
		WHEN OTHERS THEN RAISE NOTICE 'qgis_pkg.tr_ins_ng_timevaluesproperties(): %',SQLERRM;
END;
$$
LANGUAGE plpgsql;
COMMENT ON FUNCTION qgis_pkg.tr_ins_ng_timevaluesproperties IS 'Trigger to block inserting a record into a view of cdb_schema.ng_timevaluesproperties';
REVOKE EXECUTE ON FUNCTION qgis_pkg.tr_ins_ng_timevaluesproperties FROM public;

---------------------------------------------------------------------
-- CREATE TRIGGER FUNCTION qgis_pkg.tr_del_ng_timevaluesproperties
---------------------------------------------------------------------

DROP FUNCTION IF EXISTS qgis_pkg.tr_del_ng_timevaluesproperties CASCADE;
CREATE OR REPLACE FUNCTION qgis_pkg.tr_del_ng_timevaluesproperties()
RETURNS trigger AS $$
DECLARE
	cdb_schema CONSTANT varchar := split_part(TG_TABLE_NAME,'_ng_',1);

BEGIN
	EXECUTE format('
		SELECT %I.del_ng_timevaluesproperties(ARRAY[$1])',cdb_schema) USING OLD.id;
        RETURN updated_id;
	EXCEPTION
		WHEN OTHERS THEN RAISE NOTICE 'qgis_pkg.tr_del_ng_timevaluesproperties(id: %): %',OLD.id,SQLERRM;
END;
$$
LANGUAGE plpgsql;
COMMENT ON FUNCTION qgis_pkg.tr_del_ng_timevaluesproperties IS 'Trigger to delete a record from a view of cdb_schema.ng_timevaluesproperties';
REVOKE EXECUTE ON FUNCTION qgis_pkg.tr_del_ng_timevaluesproperties FROM public;

---------------------------------------------------------------------
-- CREATE TRIGGER FUNCTION qgis_pkg.tr_upd_ng_timevaluesproperties
---------------------------------------------------------------------

DROP FUNCTION IF EXISTS qgis_pkg.tr_upd_ng_timevaluesproperties CASCADE;
CREATE OR REPLACE FUNCTION qgis_pkg.tr_upd_ng_timevaluesproperties()
RETURNS trigger AS $$
DECLARE 
	cdb_schema CONSTANT varchar := split_part(TG_TABLE_NAME,'_ng_',1);
	obj_1 qgis_pkg.obj_ng_timevaluesproperties;
BEGIN
	obj_1.id				:= OLD.id;
	obj_1.acquisitionmethod			:= NEW.acquisitionmethod;
	obj_1.interpolationtype			:= NEW.interpolationtype;
	obj_1.qualitydescription		:= NEW.qualitydescription;
	obj_1.source				:= NEW.source;
	obj_1.thematicdescription		:= NEW.thematicdescription;

	PERFORM qgis_pkg.upd_ng_timevaluesproperties_atts(obj_1,cdb_schema);
	RETURN NEW;
	EXCEPTION
		WHEN OTHERS THEN RAISE NOTICE 'qgis_pkg.tr_upd_ng_timevaluesproperties(id: %): %',OLD.id,SQLERRM;
END;
$$
LANGUAGE plpgsql;
COMMENT ON FUNCTION qgis_pkg.tr_upd_ng_timevaluesproperties IS 'Trigger to update a record in a view of cdb_schema.ng_timevaluesproperties';
REVOKE EXECUTE ON FUNCTION qgis_pkg.tr_upd_ng_timevaluesproperties FROM public;

---------------------------------------------------------------------
-- CREATE TRIGGER FUNCTION qgis_pkg.tr_ins_ng_reflectance
---------------------------------------------------------------------

DROP FUNCTION IF EXISTS qgis_pkg.tr_ins_ng_reflectance CASCADE;
CREATE OR REPLACE FUNCTION qgis_pkg.tr_ins_ng_reflectance()
RETURNS trigger AS $$
DECLARE
BEGIN
	RAISE NOTICE 'You are not allowed to insert records using the QGIS plugin';
       	RETURN OLD;
	EXCEPTION
		WHEN OTHERS THEN RAISE NOTICE 'qgis_pkg.tr_ins_ng_reflectance(): %',SQLERRM;
END;
$$
LANGUAGE plpgsql;
COMMENT ON FUNCTION qgis_pkg.tr_ins_ng_reflectance IS 'Trigger to block inserting a record into a view of cdb_schema.ng_reflectance';
REVOKE EXECUTE ON FUNCTION qgis_pkg.tr_ins_ng_reflectance FROM public;

---------------------------------------------------------------------
-- CREATE TRIGGER FUNCTION qgis_pkg.tr_del_ng_reflectance
---------------------------------------------------------------------

DROP FUNCTION IF EXISTS qgis_pkg.tr_del_ng_reflectance CASCADE;
CREATE OR REPLACE FUNCTION qgis_pkg.tr_del_ng_reflectance()
RETURNS trigger AS $$
DECLARE
	cdb_schema CONSTANT varchar := split_part(TG_TABLE_NAME,'_ng_',1);

BEGIN
	EXECUTE format('
		SELECT %I.del_ng_reflectance(ARRAY[$1])',cdb_schema) USING OLD.id;
        RETURN updated_id;
	EXCEPTION
		WHEN OTHERS THEN RAISE NOTICE 'qgis_pkg.tr_del_ng_reflectance(id: %): %',OLD.id,SQLERRM;
END;
$$
LANGUAGE plpgsql;
COMMENT ON FUNCTION qgis_pkg.tr_del_ng_reflectance IS 'Trigger to delete a record from a view of cdb_schema.ng_reflectance';
REVOKE EXECUTE ON FUNCTION qgis_pkg.tr_del_ng_reflectance FROM public;

---------------------------------------------------------------------
-- CREATE TRIGGER FUNCTION qgis_pkg.tr_upd_ng_reflectance
---------------------------------------------------------------------

DROP FUNCTION IF EXISTS qgis_pkg.tr_upd_ng_reflectance CASCADE;
CREATE OR REPLACE FUNCTION qgis_pkg.tr_upd_ng_reflectance()
RETURNS trigger AS $$
DECLARE 
	cdb_schema CONSTANT varchar := split_part(TG_TABLE_NAME,'_ng_',1);
	obj_1 qgis_pkg.obj_ng_reflectance;
BEGIN
	obj_1.id				:= OLD.id;
	obj_1.fraction				:= NEW.fraction;
	obj_1.fraction_uom			:= NEW.fraction_uom;
	obj_1.surface				:= NEW.surface;
	obj_1.wavelengthrange			:= NEW.wavelengthrange;

	PERFORM qgis_pkg.upd_ng_reflectance_atts(obj_1,cdb_schema);
	RETURN NEW;
	EXCEPTION
		WHEN OTHERS THEN RAISE NOTICE 'qgis_pkg.tr_upd_ng_reflectance(id: %): %',OLD.id,SQLERRM;
END;
$$
LANGUAGE plpgsql;
COMMENT ON FUNCTION qgis_pkg.tr_upd_ng_reflectance IS 'Trigger to update a record in a view of cdb_schema.ng_reflectance';
REVOKE EXECUTE ON FUNCTION qgis_pkg.tr_upd_ng_reflectance FROM public;

---------------------------------------------------------------------
-- CREATE TRIGGER FUNCTION qgis_pkg.tr_ins_ng_opticalproperties
---------------------------------------------------------------------

DROP FUNCTION IF EXISTS qgis_pkg.tr_ins_ng_opticalproperties CASCADE;
CREATE OR REPLACE FUNCTION qgis_pkg.tr_ins_ng_opticalproperties()
RETURNS trigger AS $$
DECLARE
BEGIN
	RAISE NOTICE 'You are not allowed to insert records using the QGIS plugin';
       	RETURN OLD;
	EXCEPTION
		WHEN OTHERS THEN RAISE NOTICE 'qgis_pkg.tr_ins_ng_opticalpropeties(): %',SQLERRM;
END;
$$
LANGUAGE plpgsql;
COMMENT ON FUNCTION qgis_pkg.tr_ins_ng_opticalproperties IS 'Trigger to block inserting a record into a view of cdb_schema.ng_opticalproperties';
REVOKE EXECUTE ON FUNCTION qgis_pkg.tr_ins_ng_opticalproperties FROM public;

---------------------------------------------------------------------
-- CREATE TRIGGER FUNCTION qgis_pkg.tr_del_ng_opticalproperties
---------------------------------------------------------------------

DROP FUNCTION IF EXISTS qgis_pkg.tr_del_ng_opticalproperties CASCADE;
CREATE OR REPLACE FUNCTION qgis_pkg.tr_del_ng_opticalproperties()
RETURNS trigger AS $$
DECLARE
	cdb_schema CONSTANT varchar := split_part(TG_TABLE_NAME,'_ng_',1);

BEGIN
	EXECUTE format('
		SELECT %I.del_ng_opticalproperties(ARRAY[$1])',cdb_schema) USING OLD.id;
        RETURN updated_id;
	EXCEPTION
		WHEN OTHERS THEN RAISE NOTICE 'qgis_pkg.tr_del_ng_opticalproperties(id: %): %',OLD.id,SQLERRM;
END;
$$
LANGUAGE plpgsql;
COMMENT ON FUNCTION qgis_pkg.tr_del_ng_opticalproperties IS 'Trigger to delete a record from a view of cdb_schema.ng_opticalproperties';
REVOKE EXECUTE ON FUNCTION qgis_pkg.tr_del_ng_opticalproperties FROM public;

---------------------------------------------------------------------
-- CREATE TRIGGER FUNCTION qgis_pkg.tr_upd_ng_opticalproperties
---------------------------------------------------------------------

DROP FUNCTION IF EXISTS qgis_pkg.tr_upd_ng_opticalproperties CASCADE;
CREATE OR REPLACE FUNCTION qgis_pkg.tr_upd_ng_opticalproperties()
RETURNS trigger AS $$
DECLARE 
	cdb_schema CONSTANT varchar := split_part(TG_TABLE_NAME,'_ng_',1);
	obj_1 qgis_pkg.obj_ng_opticalproperties;
BEGIN
	obj_1.id				:= OLD.id;
	obj_1.glazingratio			:= NEW.glazingratio;
	obj_1.glazingratio_uom			:= NEW.glazingratio_uom;

	PERFORM qgis_pkg.upd_ng_opticalproperties_atts(obj_1,cdb_schema);
	RETURN NEW;
	EXCEPTION
		WHEN OTHERS THEN RAISE NOTICE 'qgis_pkg.tr_upd_ng_opticalproperties(id: %): %',OLD.id,SQLERRM;
END;
$$
LANGUAGE plpgsql;
COMMENT ON FUNCTION qgis_pkg.tr_upd_ng_opticalproperties IS 'Trigger to update a record in a view of cdb_schema.ng_opticalproperties';
REVOKE EXECUTE ON FUNCTION qgis_pkg.tr_upd_ng_opticalproperties FROM public;

---------------------------------------------------------------------
-- CREATE TRIGGER FUNCTION qgis_pkg.tr_ins_ng_volumetype
---------------------------------------------------------------------

DROP FUNCTION IF EXISTS qgis_pkg.tr_ins_ng_volumetype CASCADE;
CREATE OR REPLACE FUNCTION qgis_pkg.tr_ins_ng_volumetype()
RETURNS trigger AS $$
DECLARE
BEGIN
	RAISE NOTICE 'You are not allowed to insert records using the QGIS plugin';
       	RETURN OLD;
	EXCEPTION
		WHEN OTHERS THEN RAISE NOTICE 'qgis_pkg.tr_ins_ng_volumetype(): %',SQLERRM;
END;
$$
LANGUAGE plpgsql;
COMMENT ON FUNCTION qgis_pkg.tr_ins_ng_volumetype IS 'Trigger to block inserting a record into a view of cdb_schema.ng_volumetype';
REVOKE EXECUTE ON FUNCTION qgis_pkg.tr_ins_ng_volumetype FROM public;

---------------------------------------------------------------------
-- CREATE TRIGGER FUNCTION qgis_pkg.tr_del_ng_volumetype
---------------------------------------------------------------------

DROP FUNCTION IF EXISTS qgis_pkg.tr_del_ng_volumetype CASCADE;
CREATE OR REPLACE FUNCTION qgis_pkg.tr_del_ng_volumetype()
RETURNS trigger AS $$
DECLARE
	cdb_schema CONSTANT varchar := split_part(TG_TABLE_NAME,'_ng_',1);

BEGIN
	EXECUTE format('
		SELECT %I.del_ng_volumetype(ARRAY[$1])',cdb_schema) USING OLD.id;
        RETURN updated_id;
	EXCEPTION
		WHEN OTHERS THEN RAISE NOTICE 'qgis_pkg.tr_del_ng_volumetype(id: %): %',OLD.id,SQLERRM;
END;
$$
LANGUAGE plpgsql;
COMMENT ON FUNCTION qgis_pkg.tr_del_ng_volumetype IS 'Trigger to delete a record from a view of cdb_schema.ng_volumetype';
REVOKE EXECUTE ON FUNCTION qgis_pkg.tr_del_ng_volumetype FROM public;

---------------------------------------------------------------------
-- CREATE TRIGGER FUNCTION qgis_pkg.tr_upd_ng_volumetype
---------------------------------------------------------------------

DROP FUNCTION IF EXISTS qgis_pkg.tr_upd_ng_volumetype CASCADE;
CREATE OR REPLACE FUNCTION qgis_pkg.tr_upd_ng_volumetype()
RETURNS trigger AS $$
DECLARE 
	cdb_schema CONSTANT varchar := split_part(TG_TABLE_NAME,'_ng_',1);
	obj_1 qgis_pkg.obj_ng_volumetype;
BEGIN
	obj_1.id				:= OLD.id;
	obj_1.type				:= NEW.type;
	obj_1.value				:= NEW.value;
	obj_1.value_uom				:= NEW.value_uom;
	
	PERFORM qgis_pkg.upd_ng_volumetype_atts(obj_1,cdb_schema);
	RETURN NEW;
	EXCEPTION
		WHEN OTHERS THEN RAISE NOTICE 'qgis_pkg.tr_upd_ng_volumetype(id: %): %',OLD.id,SQLERRM;
END;
$$
LANGUAGE plpgsql;
COMMENT ON FUNCTION qgis_pkg.tr_upd_ng_volumetype IS 'Trigger to update a record in a view of cdb_schema.ng_volumetype';
REVOKE EXECUTE ON FUNCTION qgis_pkg.tr_upd_ng_volumetype FROM public;

---------------------------------------------------------------------
-- CREATE TRIGGER FUNCTION qgis_pkg.tr_ins_ng_floorarea
---------------------------------------------------------------------

DROP FUNCTION IF EXISTS qgis_pkg.tr_ins_ng_floorarea CASCADE;
CREATE OR REPLACE FUNCTION qgis_pkg.tr_ins_ng_floorarea()
RETURNS trigger AS $$
DECLARE
BEGIN
	RAISE NOTICE 'You are not allowed to insert records using the QGIS plugin';
       	RETURN OLD;
	EXCEPTION
		WHEN OTHERS THEN RAISE NOTICE 'qgis_pkg.tr_ins_ng_floorarea(): %',SQLERRM;
END;
$$
LANGUAGE plpgsql;
COMMENT ON FUNCTION qgis_pkg.tr_ins_ng_floorarea IS 'Trigger to block inserting a record into a view of cdb_schema.ng_floorarea';
REVOKE EXECUTE ON FUNCTION qgis_pkg.tr_ins_ng_floorarea FROM public;

---------------------------------------------------------------------
-- CREATE TRIGGER FUNCTION qgis_pkg.tr_del_ng_floorarea
---------------------------------------------------------------------

DROP FUNCTION IF EXISTS qgis_pkg.tr_del_ng_floorarea CASCADE;
CREATE OR REPLACE FUNCTION qgis_pkg.tr_del_ng_floorarea()
RETURNS trigger AS $$
DECLARE
	cdb_schema CONSTANT varchar := split_part(TG_TABLE_NAME,'_ng_',1);

BEGIN
	EXECUTE format('
		SELECT %I.del_ng_floorarea(ARRAY[$1])',cdb_schema) USING OLD.id;
        RETURN updated_id;
	EXCEPTION
		WHEN OTHERS THEN RAISE NOTICE 'qgis_pkg.tr_del_ng_floorarea(id: %): %',OLD.id,SQLERRM;
END;
$$
LANGUAGE plpgsql;
COMMENT ON FUNCTION qgis_pkg.tr_del_ng_floorarea IS 'Trigger to delete a record from a view of cdb_schema.ng_floorarea';
REVOKE EXECUTE ON FUNCTION qgis_pkg.tr_del_ng_floorarea FROM public;

---------------------------------------------------------------------
-- CREATE TRIGGER FUNCTION qgis_pkg.tr_upd_ng_floorarea
---------------------------------------------------------------------

DROP FUNCTION IF EXISTS qgis_pkg.tr_upd_ng_floorarea CASCADE;
CREATE OR REPLACE FUNCTION qgis_pkg.tr_upd_ng_floorarea()
RETURNS trigger AS $$
DECLARE 
	cdb_schema CONSTANT varchar := split_part(TG_TABLE_NAME,'_ng_',1);
	obj_1 qgis_pkg.obj_ng_floorarea;
BEGIN
	obj_1.id				:= OLD.id;
	obj_1.type				:= NEW.type;
	obj_1.value				:= NEW.value;
	obj_1.value_uom				:= NEW.value_uom;
	PERFORM qgis_pkg.upd_ng_floorarea_atts(obj_1,cdb_schema);
	
	RETURN NEW;
	EXCEPTION
		WHEN OTHERS THEN RAISE NOTICE 'qgis_pkg.tr_upd_ng_flooarea(id: %): %',OLD.id,SQLERRM;
END;
$$
LANGUAGE plpgsql;
COMMENT ON FUNCTION qgis_pkg.tr_upd_ng_floorarea IS 'Trigger to update a record in a view of cdb_schema.ng_floorarea';
REVOKE EXECUTE ON FUNCTION qgis_pkg.tr_upd_ng_floorarea FROM public;

---------------------------------------------------------------------
-- CREATE TRIGGER FUNCTION qgis_pkg.tr_ins_ng_heatexchangetype
---------------------------------------------------------------------

DROP FUNCTION IF EXISTS qgis_pkg.tr_ins_ng_heatexchangetype CASCADE;
CREATE OR REPLACE FUNCTION qgis_pkg.tr_ins_ng_heatexchangetype()
RETURNS trigger AS $$
DECLARE
BEGIN
	RAISE NOTICE 'You are not allowed to insert records using the QGIS plugin';
       	RETURN OLD;
	EXCEPTION
		WHEN OTHERS THEN RAISE NOTICE 'qgis_pkg.tr_ins_ng_heatexchangetype(): %',SQLERRM;
END;
$$
LANGUAGE plpgsql;
COMMENT ON FUNCTION qgis_pkg.tr_ins_ng_heatexchangetype IS 'Trigger to block inserting a record into a view of cdb_schema.ng_heatexchangetype';
REVOKE EXECUTE ON FUNCTION qgis_pkg.tr_ins_ng_heatexchangetype FROM public;

---------------------------------------------------------------------
-- CREATE TRIGGER FUNCTION qgis_pkg.tr_del_ng_heatexchangetype
---------------------------------------------------------------------

DROP FUNCTION IF EXISTS qgis_pkg.tr_del_ng_heatexchangetype CASCADE;
CREATE OR REPLACE FUNCTION qgis_pkg.tr_del_ng_heatexchangetype()
RETURNS trigger AS $$
DECLARE
	cdb_schema CONSTANT varchar := split_part(TG_TABLE_NAME,'_ng_',1);

BEGIN
	EXECUTE format('
		SELECT %I.del_ng_heatexchangetype(ARRAY[$1])',cdb_schema) USING OLD.id;
        RETURN updated_id;
	EXCEPTION
		WHEN OTHERS THEN RAISE NOTICE 'qgis_pkg.tr_del_ng_heatexchangetype(id: %): %',OLD.id,SQLERRM;
END;
$$
LANGUAGE plpgsql;
COMMENT ON FUNCTION qgis_pkg.tr_del_ng_heatexchangetype IS 'Trigger to delete a record from a view of cdb_schema.ng_heatexchangetype';
REVOKE EXECUTE ON FUNCTION qgis_pkg.tr_del_ng_heatexchangetype FROM public;

---------------------------------------------------------------------
-- CREATE TRIGGER FUNCTION qgis_pkg.tr_upd_ng_heatexchangetype
---------------------------------------------------------------------

DROP FUNCTION IF EXISTS qgis_pkg.tr_upd_ng_heatexchangetype CASCADE;
CREATE OR REPLACE FUNCTION qgis_pkg.tr_upd_ng_heatexchangetype()
RETURNS trigger AS $$
DECLARE 
	cdb_schema CONSTANT varchar := split_part(TG_TABLE_NAME,'_ng_',1);
	obj_1 qgis_pkg.obj_ng_heatexchangetype;
BEGIN
	obj_1.id				:= OLD.id;
	obj_1.convectivefraction		:= NEW.convectivefraction;
	obj_1.convectivefraction_uom		:= NEW.convectivefraction_uom;
	obj_1.latentfraction			:= NEW.latentfraction;
	obj_1.latentfraction_uom		:= NEW.latentfraction_uom;
	obj_1.radiantfraction			:= NEW.radiantfraction;
	obj_1.radiantfraction_uom		:= NEW.radiantfraction_uom;
	obj_1.totalvalue			:= NEW.totalvalue;
	obj_1.totalvalue_uom			:= NEW.totalvalue_uom;
	
	PERFORM qgis_pkg.upd_ng_heatexchangetype_atts(obj_1,cdb_schema);
	
	RETURN NEW;
	EXCEPTION
		WHEN OTHERS THEN RAISE NOTICE 'qgis_pkg.tr_upd_ng_heatexchangetype(id: %): %',OLD.id,SQLERRM;
END;
$$
LANGUAGE plpgsql;
COMMENT ON FUNCTION qgis_pkg.tr_upd_ng_heatexchangetype IS 'Trigger to update a record in a view of cdb_schema.ng_heatexchangetype';
REVOKE EXECUTE ON FUNCTION qgis_pkg.tr_upd_ng_heatexchangetype FROM public;

---------------------------------------------------------------------
-- CREATE TRIGGER FUNCTION qgis_pkg.tr_ins_ng_heightaboveground
---------------------------------------------------------------------

DROP FUNCTION IF EXISTS qgis_pkg.tr_ins_ng_heightaboveground CASCADE;
CREATE OR REPLACE FUNCTION qgis_pkg.tr_ins_ng_heightaboveground()
RETURNS trigger AS $$
DECLARE
BEGIN
	RAISE NOTICE 'You are not allowed to insert records using the QGIS plugin';
       	RETURN OLD;
	EXCEPTION
		WHEN OTHERS THEN RAISE NOTICE 'qgis_pkg.tr_ins_ng_heightaboveground(): %',SQLERRM;
END;
$$
LANGUAGE plpgsql;
COMMENT ON FUNCTION qgis_pkg.tr_ins_ng_heightaboveground IS 'Trigger to block inserting a record into a view of cdb_schema.ng_heightaboveground';
REVOKE EXECUTE ON FUNCTION qgis_pkg.tr_ins_ng_heightaboveground FROM public;

---------------------------------------------------------------------
-- CREATE TRIGGER FUNCTION qgis_pkg.tr_del_ng_heightaboveground
---------------------------------------------------------------------

DROP FUNCTION IF EXISTS qgis_pkg.tr_del_ng_heightaboveground CASCADE;
CREATE OR REPLACE FUNCTION qgis_pkg.tr_del_ng_heightaboveground()
RETURNS trigger AS $$
DECLARE
	cdb_schema CONSTANT varchar := split_part(TG_TABLE_NAME,'_ng_',1);

BEGIN
	EXECUTE format('
		SELECT %I.del_ng_heightaboveground(ARRAY[$1])',cdb_schema) USING OLD.id;
        RETURN updated_id;
	EXCEPTION
		WHEN OTHERS THEN RAISE NOTICE 'qgis_pkg.tr_del_ng_heightaboveground(id: %): %',OLD.id,SQLERRM;
END;
$$
LANGUAGE plpgsql;
COMMENT ON FUNCTION qgis_pkg.tr_del_ng_heightaboveground IS 'Trigger to delete a record from a view of cdb_schema.ng_heightaboveground';
REVOKE EXECUTE ON FUNCTION qgis_pkg.tr_del_ng_heightaboveground FROM public;

---------------------------------------------------------------------
-- CREATE TRIGGER FUNCTION qgis_pkg.tr_upd_ng_heightaboveground
---------------------------------------------------------------------

DROP FUNCTION IF EXISTS qgis_pkg.tr_upd_ng_heightaboveground CASCADE;
CREATE OR REPLACE FUNCTION qgis_pkg.tr_upd_ng_heightaboveground()
RETURNS trigger AS $$
DECLARE 
	cdb_schema CONSTANT varchar := split_part(TG_TABLE_NAME,'_ng_',1);
	obj_1 qgis_pkg.obj_ng_heightaboveground;
BEGIN
	obj_1.id				:= OLD.id;
	obj_1.heightreference			:= NEW.heightreference;
	obj_1.value				:= NEW.value;
	obj_1.value_uom				:= NEW.value_uom;
	
	PERFORM qgis_pkg.upd_ng_heightaboveground_atts(obj_1,cdb_schema);
	
	RETURN NEW;
	EXCEPTION
		WHEN OTHERS THEN RAISE NOTICE 'qgis_pkg.tr_upd_ng_heightaboveground(id: %): %',OLD.id,SQLERRM;
END;
$$
LANGUAGE plpgsql;
COMMENT ON FUNCTION qgis_pkg.tr_upd_ng_heightaboveground IS 'Trigger to update a record in a view of cdb_schema.ng_heightaboveground';
REVOKE EXECUTE ON FUNCTION qgis_pkg.tr_upd_ng_heightaboveground FROM public;

---------------------------------------------------------------------
-- CREATE TRIGGER FUNCTION qgis_pkg.tr_ins_ng_transmittance
---------------------------------------------------------------------

DROP FUNCTION IF EXISTS qgis_pkg.tr_ins_ng_transmittance CASCADE;
CREATE OR REPLACE FUNCTION qgis_pkg.tr_ins_ng_transmittance()
RETURNS trigger AS $$
DECLARE
BEGIN
	RAISE NOTICE 'You are not allowed to insert records using the QGIS plugin';
       	RETURN OLD;
	EXCEPTION
		WHEN OTHERS THEN RAISE NOTICE 'qgis_pkg.tr_ins_ng_transmittance(): %',SQLERRM;
END;
$$
LANGUAGE plpgsql;
COMMENT ON FUNCTION qgis_pkg.tr_ins_ng_transmittance IS 'Trigger to block inserting a record into a view of cdb_schema.ng_transmittance';
REVOKE EXECUTE ON FUNCTION qgis_pkg.tr_ins_ng_transmittance FROM public;

---------------------------------------------------------------------
-- CREATE TRIGGER FUNCTION qgis_pkg.tr_del_ng_transmittance
---------------------------------------------------------------------

DROP FUNCTION IF EXISTS qgis_pkg.tr_del_ng_transmittance CASCADE;
CREATE OR REPLACE FUNCTION qgis_pkg.tr_del_ng_transmittance()
RETURNS trigger AS $$
DECLARE
	cdb_schema CONSTANT varchar := split_part(TG_TABLE_NAME,'_ng_',1);

BEGIN
	EXECUTE format('
		SELECT %I.del_ng_transmittance(ARRAY[$1])',cdb_schema) USING OLD.id;
        RETURN updated_id;
	EXCEPTION
		WHEN OTHERS THEN RAISE NOTICE 'qgis_pkg.tr_del_ng_transmittance(id: %): %',OLD.id,SQLERRM;
END;
$$
LANGUAGE plpgsql;
COMMENT ON FUNCTION qgis_pkg.tr_del_ng_transmittance IS 'Trigger to delete a record from a view of cdb_schema.ng_transmittance';
REVOKE EXECUTE ON FUNCTION qgis_pkg.tr_del_ng_transmittance FROM public;

---------------------------------------------------------------------
-- CREATE TRIGGER FUNCTION qgis_pkg.tr_upd_ng_transmittance
---------------------------------------------------------------------

DROP FUNCTION IF EXISTS qgis_pkg.tr_upd_ng_transmittance CASCADE;
CREATE OR REPLACE FUNCTION qgis_pkg.tr_upd_ng_transmittance()
RETURNS trigger AS $$
DECLARE 
	cdb_schema CONSTANT varchar := split_part(TG_TABLE_NAME,'_ng_',1);
	obj_1 qgis_pkg.obj_ng_transmittance;
BEGIN
	obj_1.id				:= OLD.id;
	obj_1.wavelengthrange			:= NEW.wavelengthrange;
	obj_1.fraction				:= NEW.fraction;
	obj_1.fraction_uom			:= NEW.fraction_uom;
	
	PERFORM qgis_pkg.upd_ng_transmittance_atts(obj_1,cdb_schema);
	
	RETURN NEW;
	EXCEPTION
		WHEN OTHERS THEN RAISE NOTICE 'qgis_pkg.tr_upd_ng_transmittance(id: %): %',OLD.id,SQLERRM;
END;
$$
LANGUAGE plpgsql;
COMMENT ON FUNCTION qgis_pkg.tr_upd_ng_transmittance IS 'Trigger to update a record in a view of cdb_schema.ng_transmittance';
REVOKE EXECUTE ON FUNCTION qgis_pkg.tr_upd_ng_transmittance FROM public;






-- ****************************************************************************
-- ****************************************************************************
--
--
-- VIEW UPDATE FUNCTIONs
--
--
-- ****************************************************************************
-- ****************************************************************************

DO $MAINBODY$
DECLARE
r RECORD;
sql_statement varchar;

BEGIN

-- Create update attribute functions with 1 object
FOR r IN
	SELECT * FROM (VALUES
	('address'::text),
	('appearance'),
	('cityobject_genericattrib'),
	('external_reference'),
	('surface_data')
	) AS t(table_name)
LOOP

sql_statement := concat('
----------------------------------------------------------------
-- Create FUNCTION QGIS_PKG.UPD_',upper(r.table_name),'_ATTS
----------------------------------------------------------------
DROP FUNCTION IF EXISTS    qgis_pkg.upd_',r.table_name,'_atts(qgis_pkg.obj_',r.table_name,', varchar) CASCADE;
CREATE OR REPLACE FUNCTION qgis_pkg.upd_',r.table_name,'_atts(
obj         qgis_pkg.obj_',r.table_name,',
cdb_schema varchar
)
RETURNS bigint AS $$
DECLARE
  updated_id bigint;
BEGIN
SELECT qgis_pkg.upd_t_',r.table_name,'(obj, cdb_schema) INTO updated_id;
RETURN updated_id;
EXCEPTION
  WHEN OTHERS THEN RAISE NOTICE ''qgis_pkg.upd_',r.table_name,'_atts(id: %): %'', obj.id, SQLERRM;
END;
$$ LANGUAGE plpgsql;
COMMENT ON FUNCTION qgis_pkg.upd_',r.table_name,'_atts(qgis_pkg.obj_',r.table_name,', varchar) IS ''Update attributes of table ',upper(r.table_name),''';
');
EXECUTE sql_statement;

END LOOP;  -- loop 1 object


-- Create update attribute functions for objects based only on cityobject table
FOR r IN
	SELECT * FROM (VALUES
	('bridge_opening'),
	('bridge_thematic_surface'),
--	('grid_coverage'),
	('opening'),
	('thematic_surface'),
	('tunnel_opening'),
	('tunnel_thematic_surface'),
	('waterboundary_surface')  -- the ones without attributes
	) AS t(table_name)
LOOP

sql_statement := concat('
----------------------------------------------------------------
-- Create FUNCTION QGIS_PKG.UPD_',upper(r.table_name),'_ATTS
----------------------------------------------------------------
DROP FUNCTION IF EXISTS    qgis_pkg.upd_',r.table_name,'_atts(qgis_pkg.obj_cityobject, varchar) CASCADE;
CREATE OR REPLACE FUNCTION qgis_pkg.upd_',r.table_name,'_atts(
obj         qgis_pkg.obj_cityobject,
cdb_schema varchar
)
RETURNS bigint AS $$
DECLARE
  updated_id bigint;
BEGIN
SELECT qgis_pkg.upd_t_cityobject(obj, cdb_schema) INTO updated_id;
RETURN updated_id;
EXCEPTION
  WHEN OTHERS THEN RAISE NOTICE ''qgis_pkg.upd_',r.table_name,'_atts(id: %): %'', obj.id, SQLERRM;
END;
$$ LANGUAGE plpgsql;
COMMENT ON FUNCTION qgis_pkg.upd_',r.table_name,'_atts(qgis_pkg.obj_cityobject, varchar) IS ''Update attributes of table ',upper(r.table_name),' (and parent ones)'';
');
EXECUTE sql_statement;

END LOOP;  -- loop 1 object

-- Create update attribute functions with 2 objects
FOR r IN
	SELECT * FROM (VALUES
	('bridge'::text),
	('bridge_constr_element'),	
	('bridge_furniture'),
	('bridge_installation'),
	('bridge_room'),
	('building'),
	('building_furniture'),
	('building_installation'),
	('city_furniture'),
	('cityobjectgroup'),
	('generic_cityobject'),
	('land_use'),
	('plant_cover'),	
	('relief_feature'),
	('room'),
	('solitary_vegetat_object'),
	('traffic_area'),
	('transportation_complex'),
	('tunnel'),
	('tunnel_furniture'),
	('tunnel_hollow_space'),
	('tunnel_installation'),
	('waterbody')
	) AS t(table_name)
LOOP

sql_statement := concat('
----------------------------------------------------------------
-- Create FUNCTION QGIS_PKG.UPD_',upper(r.table_name),'_ATTS
----------------------------------------------------------------
DROP FUNCTION IF EXISTS    qgis_pkg.upd_',r.table_name,'_atts(qgis_pkg.obj_cityobject, qgis_pkg.obj_',r.table_name,', varchar) CASCADE;
CREATE OR REPLACE FUNCTION qgis_pkg.upd_',r.table_name,'_atts(
obj         qgis_pkg.obj_cityobject,
obj_1       qgis_pkg.obj_',r.table_name,',
cdb_schema varchar 
)
RETURNS bigint AS $$
DECLARE
  updated_id bigint;
BEGIN

SELECT  qgis_pkg.upd_t_cityobject(obj, cdb_schema) INTO updated_id;
PERFORM qgis_pkg.upd_t_',r.table_name,'(obj_1, cdb_schema);

RETURN updated_id;
EXCEPTION
  WHEN OTHERS THEN RAISE NOTICE ''qgis_pkg.upd_',r.table_name,'_atts(id: %): %'', obj.id, SQLERRM;
END;
$$ LANGUAGE plpgsql;
COMMENT ON FUNCTION qgis_pkg.upd_',r.table_name,'_atts(qgis_pkg.obj_cityobject, qgis_pkg.obj_',r.table_name,', varchar) IS ''Update attributes of table ',upper(r.table_name),' (and parent ones)'';
');
EXECUTE sql_statement;

END LOOP; -- loop 1 object (cityobject + 1)


-- Create update attribute functions with 3 objects
FOR r IN
	SELECT * FROM (VALUES
	('tin_relief'::text, 	'relief_component'::text),
	('raster_relief',		'relief_component'::text)	
--	('masspoint_relief', 	'relief_component'), questo non ha attributi
--	('breakline_relief',	'relief_component')	 questo non ha attributi	

	) AS t(table_name, parent_table_name)
LOOP

sql_statement := concat('
----------------------------------------------------------------
-- Create FUNCTION QGIS_PKG.UPD_',upper(r.table_name),'_ATTS
----------------------------------------------------------------
DROP FUNCTION IF EXISTS    qgis_pkg.upd_',r.table_name,'_atts(qgis_pkg.obj_cityobject, qgis_pkg.obj_relief_component, qgis_pkg.obj_',r.table_name,', varchar) CASCADE;
CREATE OR REPLACE FUNCTION qgis_pkg.upd_',r.table_name,'_atts(
obj      qgis_pkg.obj_cityobject,
obj_1    qgis_pkg.obj_',r.parent_table_name,',
obj_2    qgis_pkg.obj_',r.table_name,',
cdb_schema varchar
)
RETURNS bigint AS $$
DECLARE
  updated_id bigint;
BEGIN

SELECT  qgis_pkg.upd_t_cityobject(obj, cdb_schema) INTO updated_id;
PERFORM qgis_pkg.upd_t_',r.parent_table_name,'(obj_1, cdb_schema);
PERFORM qgis_pkg.upd_t_',r.table_name,'(obj_2, cdb_schema);

RETURN updated_id;
EXCEPTION
  WHEN OTHERS THEN RAISE NOTICE ''qgis_pkg.upd_',r.table_name,'_atts(id: %): %'', obj.id, SQLERRM;
END;
$$ LANGUAGE plpgsql;
COMMENT ON FUNCTION qgis_pkg.upd_',r.table_name,'_atts(qgis_pkg.obj_cityobject, qgis_pkg.obj_',r.parent_table_name,', qgis_pkg.obj_',r.table_name,', varchar) IS ''Update attributes of table ',upper(r.table_name),' (and parent ones)'';
');
EXECUTE sql_statement;

END LOOP; -- loop 3 object (cityobject + 2)

----------------------------------------------------------------
-- Create FUNCTION QGIS_PKG.UPD_WATERBOUNDARY_SURFACE_WATERBODY_ATTS
----------------------------------------------------------------
DROP FUNCTION IF EXISTS    qgis_pkg.upd_waterboundary_surface_waterbody_atts(qgis_pkg.obj_cityobject, qgis_pkg.obj_waterboundary_surface, varchar) CASCADE;
CREATE OR REPLACE FUNCTION qgis_pkg.upd_waterboundary_surface_waterbody_atts(
obj      qgis_pkg.obj_cityobject,
obj_1    qgis_pkg.obj_waterboundary_surface,
cdb_schema varchar
)
RETURNS bigint AS $$
DECLARE
  updated_id bigint;
BEGIN

SELECT  qgis_pkg.upd_t_cityobject(obj, cdb_schema) INTO updated_id;
PERFORM qgis_pkg.upd_t_waterboundary_surface(obj_1, cdb_schema);

RETURN updated_id;
EXCEPTION
  WHEN OTHERS THEN RAISE NOTICE 'qgis_pkg.upd_waterboundary_surface_waterbody_atts(id: %): %', obj.id, SQLERRM;
END;
$$ LANGUAGE plpgsql;
COMMENT ON FUNCTION qgis_pkg.upd_waterboundary_surface_waterbody_atts(qgis_pkg.obj_cityobject, qgis_pkg.obj_waterboundary_surface, varchar) IS 'Update attributes of table WATERBOUNDARY_SURFACE (for class WaterBody) (and parent ones)';


--**************************
RAISE NOTICE E'\n\nDone\n\n';
END $MAINBODY$;
--**************************
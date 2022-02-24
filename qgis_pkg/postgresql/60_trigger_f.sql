-- ****************************************************************************
-- ****************************************************************************
--
--
-- TRIGGER FUNCTIONs
--
--
-- ****************************************************************************
-- ****************************************************************************

DO $MAINBODY$
DECLARE
r RECORD;
sql_statement varchar;
sql_statement_head varchar;
sql_statement_body varchar;
sql_statement_tail varchar;
sql_statement_co_fields varchar;
sql_statement_cfu_fields varchar;

BEGIN

-- Generate all trigger functions for insert (to block insert operations) and delete functions
FOR r IN
	SELECT * FROM (VALUES
	('address'::text					,'del_address'					),
	('appearance'						,'del_appearance'				),
	('breakline_relief'					,'del_breakline_relief'			),	
	('bridge'							,'del_bridge'					),
	('bridge_constr_element'			,'del_bridge_constr_element'	),	
	('bridge_furniture'					,'del_bridge_furniture'			),
	('bridge_installation'				,'del_bridge_installation'		),
	('bridge_opening'					,'del_bridge_opening'			),
	('bridge_room'						,'del_bridge_room'				),
	('bridge_thematic_surface'			,'del_bridge_thematic_surface'	),
	('building'							,'del_building'					),
	('building_furniture'				,'del_building_furniture'		),
	('building_installation'			,'del_building_installation'	),
	('city_furniture'					,'del_city_furniture'			),
	('cityobject_genericattrib'			,'del_cityobject_genericattrib'	),
	('cityobjectgroup'					,'del_cityobjectgroup'			),
	('external_reference'				,'del_external_reference'		),
	('generic_cityobject'				,'del_generic_cityobject'		),
--	('grid_coverage'					,'del_grid_coverage'			),
--	('implicit_geometry'				,'del_implicit_geometry'		),		
	('land_use'							,'del_land_use'					),
	('masspoint_relief'					,'del_masspoint_relief'			),		
	('opening'							,'del_opening'					),
	('plant_cover'						,'del_plant_cover'				),
	('raster_relief'					,'del_raster_relief'			),
--	('relief_component'					,'del_relief_component'			),	
	('relief_feature'					,'del_relief_feature'			),
	('room'								,'del_room'						),
	('solitary_vegetat_object'			,'del_solitary_vegetat_object'	),
	('surface_data'						,'del_surface_data'				),
--	('surface_geometry'					,'del_surface_geometry'			),
	('thematic_surface'					,'del_thematic_surface'			),
	('tin_relief'						,'del_tin_relief'				),	
	('traffic_area'						,'del_traffic_area'				),
	('transportation_complex'			,'del_transportation_complex'	),
	('tunnel'							,'del_tunnel'					),
	('tunnel_furniture'					,'del_tunnel_furniture'			),
	('tunnel_hollow_space'				,'del_tunnel_hollow_space'		),
	('tunnel_installation'				,'del_tunnel_installation'		),
	('tunnel_opening'					,'del_tunnel_opening'			),
	('tunnel_thematic_surface'			,'del_tunnel_thematic_surface'	),
	('waterbody'						,'del_waterbody'				),
	('waterboundary_surface'			,'del_waterboundary_surface'	)
	) AS t(table_name, del_function)
LOOP



----------------------------------------------------------------
-- Create trigger FUNCTION QGIS_PKG.TR_INS_*
----------------------------------------------------------------
sql_statement := concat('
DROP FUNCTION IF EXISTS    qgis_pkg.tr_ins_',r.table_name,' CASCADE;
CREATE OR REPLACE FUNCTION qgis_pkg.tr_ins_',r.table_name,'()
RETURNS trigger AS $$
DECLARE
BEGIN
RAISE EXCEPTION ''You are not allowed to insert new records using the QGIS plugin'';
RETURN OLD;
EXCEPTION
  WHEN OTHERS THEN RAISE NOTICE ''qgis_pkg.tr_ins_',r.table_name,'(): %'', SQLERRM;
END;

$$ LANGUAGE plpgsql;
COMMENT ON FUNCTION qgis_pkg.tr_ins_',r.table_name,' IS ''(Blocks) inserting record in table ',upper(r.table_name),''';
');
EXECUTE sql_statement;

----------------------------------------------------------------
-- Create trigger FUNCTION QGIS_PKG.TR_DEL_*
----------------------------------------------------------------
sql_statement := concat('
DROP FUNCTION IF EXISTS    qgis_pkg.tr_del_',r.table_name,' CASCADE;
CREATE OR REPLACE FUNCTION qgis_pkg.tr_del_',r.table_name,'()
RETURNS trigger AS $$
DECLARE
  schema_name varchar := split_part(TG_TABLE_NAME, ''_'', 1); 
BEGIN
EXECUTE format(''PERFORM %I.del_',r.table_name,'(ARRAY[%L])'', schema_name, OLD.id);
RETURN OLD;
EXCEPTION
  WHEN OTHERS THEN RAISE NOTICE ''qgis_pkg.tr_del_',r.table_name,'(): %'', SQLERRM;
END;
$$ LANGUAGE plpgsql;
COMMENT ON FUNCTION qgis_pkg.tr_ins_',r.table_name,' IS ''Deletes record in table ',upper(r.table_name),''';
');
EXECUTE sql_statement;

END LOOP; -- loop insert tr_ins e tr_del_functions


----------------------------------------------------------------
-- Create trigger FUNCTION QGIS_PKG.TR_INS/DEL_WATERBOUNDARY_SURFACE_WATERSURFACE
----------------------------------------------------------------
sql_statement := concat('
DROP FUNCTION IF EXISTS    qgis_pkg.tr_ins_waterboundary_surface_watersurface CASCADE;
CREATE OR REPLACE FUNCTION qgis_pkg.tr_ins_waterboundary_surface_watersurface()
RETURNS trigger AS $$
DECLARE
BEGIN
RAISE EXCEPTION ''You are not allowed to insert new records using the QGIS plugin'';
RETURN OLD;
EXCEPTION
  WHEN OTHERS THEN RAISE NOTICE ''qgis_pkg.tr_ins_waterboundary_surface_watersurface(): %'', SQLERRM;
END;

$$ LANGUAGE plpgsql;
COMMENT ON FUNCTION qgis_pkg.tr_ins_waterboundary_surface_watersurface IS ''(Blocks) inserting record in table WATERBOUNDARY_SURFACE'';
');
EXECUTE sql_statement;

sql_statement := concat('
DROP FUNCTION IF EXISTS    qgis_pkg.tr_del_waterboundary_surface_watersurface CASCADE;
CREATE OR REPLACE FUNCTION qgis_pkg.tr_del_waterboundary_surface_watersurface()
RETURNS trigger AS $$
DECLARE
  schema_name varchar := split_part(TG_TABLE_NAME, ''_'', 1); 
BEGIN
EXECUTE format(''PERFORM %I.del_waterboundary_surface(ARRAY[[%L])'', schema_name, OLD.id);
RETURN OLD;
EXCEPTION
  WHEN OTHERS THEN RAISE NOTICE ''qgis_pkg.tr_del_waterboundary_surface_watersurface(): %'', SQLERRM;
END;
$$ LANGUAGE plpgsql;
COMMENT ON FUNCTION qgis_pkg.tr_ins_waterboundary_surface_watersurface IS ''Deletes record in table WATERBOUNDARY_SURFACE'';
');
EXECUTE sql_statement;



FOR r IN
	SELECT * FROM (VALUES
	('address'::text			),
	('appearance'				),
	('breakline_relief'			),	
	('bridge'					),
	('bridge_constr_element'	),	
	('bridge_furniture'			),
	('bridge_installation'		),
	('bridge_opening'			),
	('bridge_room'				),
	('bridge_thematic_surface'	),
	('building'					),
	('building_furniture'		),
	('building_installation'	),
	('city_furniture'			),
	('cityobject_genericattrib'	),
	('cityobjectgroup'			),
	('external_reference'		),
	('generic_cityobject'		),
--	('grid_coverage'			),
--	('implicit_geometry'		),		
	('land_use'					),
	('masspoint_relief'			),		
	('opening'					),
	('plant_cover'				),
	('raster_relief'			),
--	('relief_component'			),	
	('relief_feature'			),
	('room'						),
	('solitary_vegetat_object'	),
	('surface_data'				),
--	('surface_geometry'			),
	('thematic_surface'			),
	('tin_relief'				),	
	('traffic_area'				),
	('transportation_complex'	),
	('tunnel'					),
	('tunnel_furniture'			),
	('tunnel_hollow_space'		),
	('tunnel_installation'		),
	('tunnel_opening'			),
	('tunnel_thematic_surface'	),
	('waterbody'				),
	('waterboundary_surface'	),
	('waterboundary_surface_watersurface')	
	) AS t(table_name)
LOOP

sql_statement_co_fields := concat('
obj.id                     := OLD.id;
obj.gmlid                  := NEW.gmlid;
obj.gmlid_codespace        := NEW.gmlid_codespace;
obj.name                   := NEW.name;
obj.name_codespace         := NEW.name_codespace;
obj.description            := NEW.description;
obj.creation_date          := NEW.creation_date;
obj.termination_date       := NEW.termination_date;
obj.relative_to_terrain    := NEW.relative_to_terrain;
obj.relative_to_water      := NEW.relative_to_water;
obj.last_modification_date := NEW.last_modification_date;
obj.updating_person        := NEW.updating_person;
obj.reason_for_update      := NEW.reason_for_update;
obj.lineage                := NEW.lineage;
');
--RAISE NOTICE 'co_fields %:',sql_statement_co_fields;

sql_statement_cfu_fields := concat('
obj_1.class                       := NEW.class;
obj_1.class_codespace             := NEW.class_codespace;
obj_1.function                    := array_to_string((SELECT array_agg(DISTINCT x) FROM unnest(NEW.function) AS t(x)), ''--/\--'');
obj_1.function_codespace          := array_to_string((SELECT array_agg(DISTINCT x) FROM unnest(NEW.function_codespace) AS t(x)), ''--/\--'');
obj_1.usage                       := array_to_string((SELECT array_agg(DISTINCT x) FROM unnest(NEW.usage) AS t(x)), ''--/\--'');
obj_1.usage_codespace             := array_to_string((SELECT array_agg(DISTINCT x) FROM unnest(NEW.usage_codespace) AS t(x)), ''--/\--'');');
--RAISE NOTICE 'co_fields %:',sql_statement_cfu_fields;

sql_statement_head := concat('
DROP FUNCTION IF EXISTS    qgis_pkg.tr_upd_',r.table_name,' CASCADE;
CREATE OR REPLACE FUNCTION qgis_pkg.tr_upd_',r.table_name,'()
RETURNS trigger AS $$
DECLARE
  schema_name varchar := split_part(TG_TABLE_NAME, ''_'', 1);');
--RAISE NOTICE 'head %:',sql_statement_head;


CASE
	WHEN r.table_name IN
	   ('bridge_opening',
		'bridge_thematic_surface',
		'opening',
		'thematic_surface',
		'tunnel_opening',
		'tunnel_thematic_surface',
		'waterboundary_surface')					THEN sql_statement_body := concat('
  obj    qgis_pkg.obj_cityobject;
BEGIN',
sql_statement_co_fields,'
PERFORM qgis_pkg.upd_',r.table_name,'_atts(obj, schema_name);	
');
	WHEN r.table_name IN
	   ('bridge_constr_element',
		'bridge_furniture'     ,
		'bridge_installation'  ,
		'bridge_room'          ,
		'building_furniture'   ,
		'building_installation',
		'city_furniture'       ,
		'cityobjectgroup'      ,
		'generic_cityobject'   ,
		'room'                 ,
		'tunnel_furniture'     ,
		'tunnel_hollow_space'  ,
		'tunnel_installation'  ,
		'waterbody')					THEN sql_statement_body := concat('
  obj    qgis_pkg.obj_cityobject;
  obj_1  qgis_pkg.obj_',r.table_name,';
BEGIN',
sql_statement_co_fields,'
obj_1.id                          := OLD.id;',
sql_statement_cfu_fields,'
PERFORM qgis_pkg.upd_',r.table_name,'_atts(obj, obj_1, schema_name);
');
	WHEN r.table_name IN
	   ('traffic_area',
		'transportation_complex')					THEN sql_statement_body := concat('
  obj    qgis_pkg.obj_cityobject;
  obj_1  qgis_pkg.obj_',r.table_name,';
BEGIN',
sql_statement_co_fields,'
obj_1.id := OLD.id;',
sql_statement_cfu_fields,'
obj_1.surface_material            = NEW.surface_material;
obj_1.surface_material_codespace  = NEW.surface_material_codespace;

PERFORM qgis_pkg.upd_',r.table_name,'_atts(obj, obj_1, schema_name);
');
	WHEN r.table_name = 'address'                  THEN sql_statement_body := concat('
  obj    qgis_pkg.obj_',r.table_name,';
BEGIN
obj.id              := OLD.id;
obj.gmlid           := NEW.gmlid;
obj.gmlid_codespace := NEW.gmlid_codespace;
obj.street          := NEW.street;
obj.house_number    := NEW.house_number;
obj.po_box          := NEW.po_box;
obj.zip_code        := NEW.zip_code;
obj.city            := NEW.city;
obj.state           := NEW.state;
obj.country         := NEW.country;

PERFORM qgis_pkg.upd_',r.table_name,'_atts(obj, schema_name);
');
	WHEN r.table_name = 'appearance'				THEN sql_statement_body := concat('
  obj    qgis_pkg.obj_',r.table_name,';
BEGIN
obj.gmlid           := NEW.gmlid;
obj.gmlid_codespace := NEW.gmlid_codespace;
obj.name            := NEW.name;
obj.name_codespace  := NEW.name_codespace;
obj.description     := NEW.description;
obj.theme           := NEW.theme;

PERFORM qgis_pkg.upd_',r.table_name,'_atts(obj, schema_name);
');

	WHEN r.table_name IN
	   ('breakline_relief',
		'masspoint_relief')					THEN sql_statement_body := concat('
  obj    qgis_pkg.obj_cityobject;
  obj_1  qgis_pkg.obj_relief_component;  
BEGIN',
sql_statement_co_fields,'
obj_1.id := OLD.id;
obj_1.lod  := NEW.lod;

PERFORM qgis_pkg.upd_',r.table_name,'_atts(obj, obj_1, schema_name);
');

	WHEN r.table_name = 'bridge'					THEN sql_statement_body := concat('
  obj    qgis_pkg.obj_cityobject;
  obj_1  qgis_pkg.obj_',r.table_name,';
BEGIN',
sql_statement_co_fields,'
obj_1.id                          := OLD.id;',
sql_statement_cfu_fields,'
obj_1.year_of_construction        = NEW.year_of_construction;
obj_1.year_of_demolition          = NEW.year_of_demolition;
obj_1.is_movable                  = NEW.is_movable;

PERFORM qgis_pkg.upd_',r.table_name,'_atts(obj, obj_1, schema_name);
');

	WHEN r.table_name = 'building'					THEN sql_statement_body := concat('
  obj    qgis_pkg.obj_cityobject;
  obj_1  qgis_pkg.obj_',r.table_name,';
BEGIN',
sql_statement_co_fields,'
obj_1.id                          := OLD.id;',
sql_statement_cfu_fields,'
obj_1.year_of_construction        := NEW.year_of_construction;
obj_1.year_of_demolition          := NEW.year_of_demolition;
obj_1.roof_type                   := NEW.roof_type;
obj_1.roof_type_codespace         := NEW.roof_type_codespace;
obj_1.measured_height             := NEW.measured_height;
obj_1.measured_height_unit        := NEW.measured_height_unit;
obj_1.storeys_above_ground        := NEW.storeys_above_ground;
obj_1.storeys_below_ground        := NEW.storeys_below_ground;
obj_1.storey_heights_above_ground := NEW.storey_heights_above_ground;
obj_1.storey_heights_ag_unit      := NEW.storey_heights_ag_unit;
obj_1.storey_heights_below_ground := NEW.storey_heights_below_ground;
obj_1.storey_heights_bg_unit      := NEW.storey_heights_bg_unit;

PERFORM qgis_pkg.upd_',r.table_name,'_atts(obj, obj_1, schema_name);
');

	WHEN r.table_name = 'cityobject_genericattrib'	THEN sql_statement_body := concat('
  obj    qgis_pkg.obj_',r.table_name,';
BEGIN
obj.id                     := OLD.id;
obj.attrname               := NEW.attrname;
obj.strval                 := NEW.strval;
obj.intval                 := NEW.intval;
obj.realval                := NEW.realval;
obj.urival                 := NEW.urival;
obj.dateval                := NEW.dateval;
obj.unit                   := NEW.unit;
obj.genattribset_codespace := NEW.genattribset_codespace;
obj.blobval                := NEW.blobval;

PERFORM qgis_pkg.upd_',r.table_name,'_atts(obj, schema_name);
');

	WHEN r.table_name = 'external_reference'		THEN sql_statement_body := concat('
  obj    qgis_pkg.obj_',r.table_name,';
BEGIN
obj.id            := OLD.id;
obj.infosys       := NEW.infosys;
obj.name          := NEW.name;
obj.uri           := NEW.uri;

PERFORM qgis_pkg.upd_',r.table_name,'_atts(obj, schema_name);
');


	WHEN r.table_name = 'land_use'					THEN sql_statement_body := concat('
  obj    qgis_pkg.obj_cityobject;
  obj_1  qgis_pkg.obj_',r.table_name,';
BEGIN',
sql_statement_co_fields,'
obj_1.id                          := OLD.id;',
sql_statement_cfu_fields,'
PERFORM qgis_pkg.upd_',r.table_name,'_atts(obj, obj_1, schema_name);
');

	WHEN r.table_name = 'plant_cover'				THEN sql_statement_body := concat('
  obj    qgis_pkg.obj_cityobject;
  obj_1  qgis_pkg.obj_',r.table_name,';
BEGIN',
sql_statement_co_fields,'
obj_1.id := OLD.id;',
sql_statement_cfu_fields,'
obj_1.height              = NEW.average_height; 
obj_1.height_unit         = NEW.average_height_unit;

PERFORM qgis_pkg.upd_',r.table_name,'_atts(obj, obj_1, schema_name);
');

	WHEN r.table_name = 'raster_relief'			THEN sql_statement_body := concat('
  obj    qgis_pkg.obj_cityobject;
  obj_1  qgis_pkg.obj_relief_component;  
  obj_2  qgis_pkg.obj_',r.table_name,';
BEGIN',
sql_statement_co_fields,'
obj_1.id := OLD.id;
obj_1.lod := NEW_lod;
obj_2.raster_uri  = NEW.raster_uri;

PERFORM qgis_pkg.upd_',r.table_name,'_atts(obj, obj_1, schema_name);
');

	WHEN r.table_name = 'relief_feature'			THEN sql_statement_body := concat('
  obj    qgis_pkg.obj_cityobject;
  obj_1  qgis_pkg.obj_relief_feature;  
BEGIN',
sql_statement_co_fields,'
obj_1.id := OLD.id;
obj_1.lod  := NEW.lod;

PERFORM qgis_pkg.upd_',r.table_name,'_atts(obj, obj_1, schema_name);
');

	WHEN r.table_name = 'solitary_vegetat_object'	THEN sql_statement_body := concat('
  obj    qgis_pkg.obj_cityobject;
  obj_1  qgis_pkg.obj_',r.table_name,';
BEGIN',
sql_statement_co_fields,'
obj_1.id := OLD.id;',
sql_statement_cfu_fields,'
obj_1.species             = NEW.species; 
obj_1.species_codespace   = NEW.species_codespace; 
obj_1.height              = NEW.height; 
obj_1.height_unit         = NEW.height_unit; 
obj_1.trunk_diameter      = NEW.trunk_diameter; 
obj_1.trunk_diameter_unit = NEW.trunk_diameter_unit; 
obj_1.crown_diameter      = NEW.crown_diameter; 
obj_1.crown_diameter_unit = NEW.crown_diameter_unit;

PERFORM qgis_pkg.upd_',r.table_name,'_atts(obj, obj_1, schema_name);
');

	WHEN r.table_name = 'surface_data'				THEN sql_statement_body := concat('
  obj    qgis_pkg.obj_',r.table_name,';
BEGIN
obj.id                    := OLD.id;
obj.gmlid                 := NEW.gmlid;
obj.gmlid_codespace       := NEW.gmlid_codespace;
obj.name                  := NEW.name;
obj.name_codespace        := NEW.name_codespace;
obj.description           := NEW.description;
obj.is_front              := NEW.is_front;
obj.x3d_shininess         := NEW.x3d_shininess;
obj.x3d_transparency      := NEW.x3d_transparency;
obj.x3d_ambient_intensity := NEW.x3d_ambient_intensity;
obj.x3d_specular_color    := NEW.x3d_specular_color;
obj.x3d_diffuse_color     := NEW.x3d_diffuse_color;
obj.x3d_emissive_color    := NEW.x3d_emissive_color;
obj.x3d_is_smooth         := NEW.x3d_is_smooth;
obj.tex_texture_type      := NEW.tex_texture_type;
obj.tex_wrap_mode         := NEW.tex_wrap_mode;
obj.tex_border_color      := NEW.tex_border_color;
obj.gt_prefer_worldfile   := NEW.gt_prefer_worldfile;
obj.gt_orientation        := NEW.gt_orientation;

PERFORM qgis_pkg.upd_',r.table_name,'_atts(obj, schema_name);
');

	WHEN r.table_name = 'tin_relief'				THEN sql_statement_body := concat('
  obj    qgis_pkg.obj_cityobject;
  obj_1  qgis_pkg.obj_relief_component;
  obj_2  qgis_pkg.obj_',r.table_name,';  
BEGIN',
sql_statement_co_fields,'
obj_1.id  := OLD.id;
obj_1.lod := NEW.lod;
obj_2.id              := OLD.id;
obj_2.max_length      := NEW.max_length;
obj_2.max_length_unit := NEW.max_length_unit; 

PERFORM qgis_pkg.upd_',r.table_name,'_atts(obj, obj_1, schema_name);
');

	WHEN r.table_name = 'tunnel'					THEN sql_statement_body := concat('
  obj    qgis_pkg.obj_cityobject;
  obj_1  qgis_pkg.obj_',r.table_name,';
BEGIN',
sql_statement_co_fields,'
obj_1.id := OLD.id;',
sql_statement_cfu_fields,'
obj_1.year_of_construction        = NEW.year_of_construction;
obj_1.year_of_demolition          = NEW.year_of_demolition;

PERFORM qgis_pkg.upd_',r.table_name,'_atts(obj, obj_1, schema_name);
');

	WHEN r.table_name = 'waterboundary_surface_watersurface'	THEN sql_statement_body := concat('
  obj    qgis_pkg.obj_cityobject;
  obj_1  qgis_pkg.obj_waterboundary_surface;
BEGIN',
sql_statement_co_fields,'
obj_1.id := OLD.id;
obj_1.water_level           := NEW.water_level;
obj_1.water_level_codespace := NEW.water_level_codespace;

PERFORM qgis_pkg.upd_',r.table_name,'_atts(obj, obj_1, schema_name);
');
	ELSE

RAISE NOTICE 'Manca %', r.table_name;

END CASE;

sql_statement_tail := concat('
RETURN NEW;
EXCEPTION
  WHEN OTHERS THEN RAISE NOTICE ''qgis_pkg.tr_upd_',r.table_name,'(id: %): %'', OLD.id, SQLERRM;
END;
$$ LANGUAGE plpgsql;
COMMENT ON FUNCTION qgis_pkg.tr_upd_',r.table_name,' IS ''Updates record in table ',upper(r.table_name),''';
');

IF sql_statement_body IS NOT NULL THEN
	EXECUTE concat(sql_statement_head, sql_statement_body, sql_statement_tail);
END IF;

sql_statement_body := NULL;

END LOOP; -- loop tr_upd functions


--**************************
RAISE NOTICE E'\n\nDone\n\n';
END $MAINBODY$;
--**************************
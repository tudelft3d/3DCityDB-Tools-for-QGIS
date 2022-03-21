-- ****************************************************************************
-- ****************************************************************************
--
--
-- CREATE LAYERS FOR MODULE RELIEF
--
--
-- ****************************************************************************
-- ****************************************************************************

--SELECT qgis_pkg.drop_layers(usr_schema:= 'qgis_user', cdb_schema:= 'citydb', feat_type := 'Relief'); 
--DELETE FROM qgis_user.layer_metadata WHERE cdb_schema = 'citydb' AND feature_type = 'Relief';

----------------------------------------------------------------
-- Create FUNCTION QGIS_PKG.GENERATE_SQL_LAYERS_RELIEF
----------------------------------------------------------------
DROP FUNCTION IF EXISTS    qgis_pkg.generate_sql_layers_relief(varchar, varchar, integer, integer, numeric, geometry, boolean) CASCADE;
CREATE OR REPLACE FUNCTION qgis_pkg.generate_sql_layers_relief(
cdb_schema 			varchar,
usr_name            varchar,
perform_snapping 	integer  DEFAULT 0,
digits 				integer	 DEFAULT 3,
area_poly_min 		numeric  DEFAULT 0.0001,
mview_bbox			geometry DEFAULT NULL,
force_layer_creation boolean DEFAULT TRUE  -- to be set to FALSE in normal usage
) 
RETURNS text AS $$

DECLARE
usr_schema      varchar := 'qgis_user';  -- will be concat('qgis',usr_name);
feature_type 	varchar := 'Relief';
srid_id         integer; 
num_features    bigint;
trig_f_suffix   varchar;
mview_bbox_srid integer := ST_SRID(mview_bbox);
mview_bbox_xmin numeric;
mview_bbox_ymin numeric;
mview_bbox_xmax numeric;
mview_bbox_ymax numeric;
r 				RECORD;
s 				RECORD;
t 				RECORD;
u 				RECORD;
tr				RECORD;
l_name 			varchar;
view_name 		varchar;
mview_name 		varchar;
mview_idx_name 	varchar;
mview_spx_name 	varchar;

sql_query		text := NULL;
sql_mview_count text := NULL;
sql_where 		text := NULL;
sql_upd			text := NULL;
sql_ins_part	text := NULL;
sql_ins			text := NULL;
sql_trig_part	text := NULL;
sql_trig		text := NULL;
sql_layer_part	text := NULL;
sql_layer	 	text := NULL;
sql_statement	text := NULL;
qml_file_name 	varchar;
citydb_envelope geometry(Polygon);

sql_co_atts varchar := '
  co.id::bigint,
  co.gmlid,
  co.gmlid_codespace,
  co.name,
  co.name_codespace,
  co.description,
  co.creation_date,
  co.termination_date,
  co.relative_to_terrain,
  co.relative_to_water,
  co.last_modification_date,
  co.updating_person,
  co.reason_for_update,
  co.lineage,';

BEGIN
-- Prepare fixed part of SQL statements
sql_upd := format('
DELETE FROM %I.layer_metadata AS l WHERE l.cdb_schema = %L AND l.feature_type = %L;',usr_schema, cdb_schema, feature_type);
sql_upd := concat(sql_upd,'
INSERT INTO ',usr_schema,'.layer_metadata 
(n_features, cdb_schema, feature_type, qml_file, lod, root_class, layer_name, creation_date, mv_name, v_name)
VALUES');


EXECUTE 'SELECT srid FROM citydb.database_srs LIMIT 1' INTO srid_id;

IF mview_bbox_srid IS NULL OR mview_bbox_srid <> srid_id THEN
	mview_bbox := NULL;
	sql_where := NULL;
ELSE
	mview_bbox_xmin := floor(ST_XMin(mview_bbox));
	mview_bbox_ymin := floor(ST_YMin(mview_bbox));
	mview_bbox_xmax := ceil(ST_XMax(mview_bbox));
	mview_bbox_ymax := ceil(ST_YMax(mview_bbox));
	mview_bbox := ST_MakeEnvelope(mview_bbox_xmin, mview_bbox_ymin, mview_bbox_xmax, mview_bbox_ymax, srid_id);
	sql_where := concat('AND ST_MakeEnvelope(',mview_bbox_xmin,', ',mview_bbox_ymin,', ',mview_bbox_xmax,', ',mview_bbox_ymax,', ',srid_id,') && co.envelope');
END IF;

RAISE NOTICE 'Creating in schema "%" layers of module "%" for user "%" and cdb_schema "%"', usr_schema, feature_type, usr_name, cdb_schema;

sql_layer_part	:= NULL;
sql_layer	 	:= NULL;
sql_ins_part	:= NULL;
sql_trig_part	:= NULL;
sql_trig		:= NULL;

---------------------------------------------------------------
-- Create LAYER RELIEF_FEATURE_LOD0-4
---------------------------------------------------------------
FOR r IN 
	SELECT * FROM (VALUES
	('ReliefFeature'::varchar, 14::integer, 'relief_feature'::varchar)
	) AS t(class_name, class_id, class_label)
LOOP
	FOR t IN 
		SELECT * FROM (VALUES
		('LoD0'::varchar, 'lod0'::varchar),
		('LoD1'			, 'lod1'),
		('LoD2'			, 'lod2'),
		('LoD3'			, 'lod3'),
		('LoD4'			, 'lod4')			
		) AS t(lodx_name, lodx_label)
	LOOP

-- First check if there are any features at all in the database schema
sql_mview_count := concat('
SELECT count(o.id) AS n_features
FROM 
	',cdb_schema,'.relief_feature AS o
	INNER JOIN ',cdb_schema,'.cityobject AS co ON (o.id = co.id AND o.objectclass_id = ',r.class_id,' ',sql_where,')
WHERE
	o.lod = ',right(t.lodx_label,1),'
');
EXECUTE sql_mview_count INTO num_features;

RAISE NOTICE 'Found % features for % %', num_features, r.class_name, t.lodx_name;

l_name         := concat(r.class_label,'_',t.lodx_label);
view_name      := concat(cdb_schema,'_',l_name);
mview_name     := concat('_g_',view_name);
mview_idx_name := concat(mview_name,'_id_idx');
mview_spx_name := concat(mview_name,'_geom_spx');
qml_file_name  := concat(r.class_label,'_form.qml');

IF (num_features > 0) OR (force_layer_creation IS TRUE) THEN

--------------------
-- MATERIALIZED VIEW
--------------------
sql_layer_part := concat('
DROP MATERIALIZED VIEW IF EXISTS ',usr_schema,'.',mview_name,' CASCADE;
CREATE MATERIALIZED VIEW         ',usr_schema,'.',mview_name,' AS
	SELECT
		o.id::bigint AS co_id,
		co.envelope::geometry(PolygonZ, ',srid_id,') AS geom	
	FROM
		',cdb_schema,'.relief_feature AS o
		INNER JOIN ',cdb_schema,'.cityobject AS co ON (o.id = co.id AND o.objectclass_id = ',r.class_id,' ',sql_where,')
	WHERE
		o.lod = ',right(t.lodx_label,1),'
WITH NO DATA;
COMMENT ON MATERIALIZED VIEW ',usr_schema,'.',mview_name,' IS ''Mat. view of ',r.class_name,' ',t.lodx_name,' in schema ',cdb_schema,''';
CREATE INDEX ',mview_idx_name,' ON ',usr_schema,'.',mview_name,' (co_id);
CREATE INDEX ',mview_spx_name,' ON ',usr_schema,'.',mview_name,' USING gist (geom);
ALTER TABLE ',usr_schema,'.',mview_name,' OWNER TO ',usr_name,';
--DELETE FROM ',usr_schema,'.layer_metadata WHERE v_name = ''',view_name,''';
--REFRESH MATERIALIZED VIEW ',usr_schema,'.',mview_name,';
');
sql_layer := concat(sql_layer,sql_layer_part);

-------
-- VIEW
-------
sql_layer_part := concat('
DROP VIEW IF EXISTS    ',usr_schema,'.',view_name,' CASCADE;
CREATE OR REPLACE VIEW ',usr_schema,'.',view_name,' AS
SELECT',sql_co_atts,'
  o.lod,
  g.geom::geometry(PolygonZ,',srid_id,')
FROM
	',usr_schema,'.',mview_name,' AS g 
	INNER JOIN ',cdb_schema,'.cityobject AS co ON (g.co_id = co.id AND co.objectclass_id = ',r.class_id,')
  	INNER JOIN ',cdb_schema,'.relief_feature AS o ON (o.id = co.id AND o.objectclass_id = ',r.class_id,')
WHERE
	o.lod = ',right(t.lodx_label,1),';
COMMENT ON VIEW ',usr_schema,'.',view_name,' IS ''View of ',r.class_name,' ',t.lodx_name,' in schema ',cdb_schema,''';
ALTER TABLE ',usr_schema,'.',view_name,' OWNER TO ',usr_name,';
');
sql_layer := concat(sql_layer,sql_layer_part);

trig_f_suffix := 'relief_feature';

SELECT qgis_pkg.generate_sql_triggers(
	view_name 			:= view_name,
	tr_function_suffix	:= trig_f_suffix,
	usr_name			:= usr_name, 
	usr_schema			:= usr_schema
) INTO sql_trig_part;
sql_trig := concat(sql_trig,sql_trig_part);

-- ADD ENTRY TO UPDATE TABLE LAYER_METADATA
sql_ins_part := concat('
(',num_features,',''',cdb_schema,''',''',feature_type,''',''',qml_file_name,''',''',t.lodx_label,''',''',r.class_name,''',''',l_name,''',clock_timestamp(),''',mview_name,''',''',view_name,'''),');
sql_ins := concat(sql_ins,sql_ins_part);

ELSE

sql_layer_part := concat('
DROP MATERIALIZED VIEW IF EXISTS ',usr_schema,'.',mview_name,' CASCADE;
DELETE FROM ',usr_schema,'.layer_metadata WHERE v_name = ''',view_name,''';
');
sql_layer := concat(sql_layer,sql_layer_part);

END IF;

	END LOOP; -- relief feature lod
END LOOP;  -- relief feature
--------------------------------------------------------
--------------------------------------------------------

---------------------------------------------------------------
-- Create LAYER TIN_RELIEF_LOD0-4
---------------------------------------------------------------
FOR r IN 
	SELECT * FROM (VALUES
	('TINRelief'::varchar, 16::integer, 'tin_relief'::varchar)
	) AS t(class_name, class_id, class_label)
LOOP
	FOR t IN 
		SELECT * FROM (VALUES
		('LoD0'::varchar, 'lod0'::varchar),
		('LoD1'			, 'lod1'),
		('LoD2'			, 'lod2'),
		('LoD3'			, 'lod3'),
		('LoD4'			, 'lod4')			
		) AS t(lodx_name, lodx_label)
	LOOP

-- First check if there are any features at all in the database schema
sql_mview_count := concat('
SELECT count(o.id) AS n_features
FROM 
	',cdb_schema,'.tin_relief AS o
	INNER JOIN ',cdb_schema,'.cityobject AS co ON (o.id = co.id AND o.objectclass_id = ',r.class_id,' ',sql_where,')
	INNER JOIN ',cdb_schema,'.relief_component AS o2 ON (o2.id = o.id AND o2.lod = ',right(t.lodx_label,1),');
');
EXECUTE sql_mview_count INTO num_features;

RAISE NOTICE 'Found % features for % %', num_features, r.class_name, t.lodx_name;

l_name         := concat(r.class_label,'_',t.lodx_label);
view_name      := concat(cdb_schema,'_',l_name);
mview_name     := concat('_g_',view_name);
mview_idx_name := concat(mview_name,'_id_idx');
mview_spx_name := concat(mview_name,'_geom_spx');
qml_file_name  := concat(r.class_label,'_form.qml');

IF (num_features > 0) OR (force_layer_creation IS TRUE) THEN

--------------------
-- MATERIALIZED VIEW
--------------------
sql_layer_part := concat('
DROP MATERIALIZED VIEW IF EXISTS ',usr_schema,'.',mview_name,' CASCADE;
CREATE MATERIALIZED VIEW         ',usr_schema,'.',mview_name,' AS
	SELECT
		sg.cityobject_id::bigint AS co_id,
		ST_Collect(qgis_pkg.ST_snap_poly_to_grid(sg.geometry,',perform_snapping,',',digits,',',area_poly_min,'))::geometry(MultiPolygonZ, ',srid_id,') AS geom	
	FROM
		',cdb_schema,'.tin_relief AS o
		INNER JOIN ',cdb_schema,'.cityobject AS co ON (o.id = co.id AND o.objectclass_id = ',r.class_id,' ',sql_where,')
		INNER JOIN ',cdb_schema,'.relief_component AS o2 ON (o2.id = o.id AND o2.lod = ',right(t.lodx_label,1),')
		INNER JOIN ',cdb_schema,'.surface_geometry AS sg ON (sg.root_id = o.surface_geometry_id AND sg.geometry IS NOT NULL) 
	GROUP BY sg.cityobject_id
WITH NO DATA;
COMMENT ON MATERIALIZED VIEW ',usr_schema,'.',mview_name,' IS ''Mat. view of ',r.class_name,' ',t.lodx_name,' in schema ',cdb_schema,''';
CREATE INDEX ',mview_idx_name,' ON ',usr_schema,'.',mview_name,' (co_id);
CREATE INDEX ',mview_spx_name,' ON ',usr_schema,'.',mview_name,' USING gist (geom);
ALTER TABLE ',usr_schema,'.',mview_name,' OWNER TO ',usr_name,';
--DELETE FROM qgis_pkg.layer_metadata AS l WHERE l.v_name = ''',view_name,''';
-- REFRESH MATERIALIZED VIEW ',usr_schema,'.',mview_name,';
');
sql_layer := concat(sql_layer,sql_layer_part);

-------
-- VIEW
-------
sql_layer_part := concat('
DROP VIEW IF EXISTS    ',usr_schema,'.',view_name,' CASCADE;
CREATE OR REPLACE VIEW ',usr_schema,'.',view_name,' AS
SELECT',sql_co_atts,'
  o.lod,
  o2.max_length,
  o2.max_length_unit,  
  g.geom::geometry(MultiPolygonZ,',srid_id,')
FROM
	',usr_schema,'.',mview_name,' AS g 
	INNER JOIN ',cdb_schema,'.cityobject AS co ON (g.co_id = co.id AND co.objectclass_id = ',r.class_id,')
	INNER JOIN ',cdb_schema,'.relief_component AS o ON (o.id = co.id AND o.objectclass_id = ',r.class_id,' AND o.lod = ',right(t.lodx_label,1),')	
  	INNER JOIN ',cdb_schema,'.tin_relief AS o2 ON (o2.id = co.id AND o2.objectclass_id = ',r.class_id,');
COMMENT ON VIEW ',usr_schema,'.',view_name,' IS ''View of ',r.class_name,' ',t.lodx_name,' in schema ',cdb_schema,''';
ALTER TABLE ',usr_schema,'.',view_name,' OWNER TO ',usr_name,';
');
sql_layer := concat(sql_layer,sql_layer_part);

trig_f_suffix := 'tin_relief';

SELECT qgis_pkg.generate_sql_triggers(
	view_name 			:= view_name,
	tr_function_suffix	:= trig_f_suffix,
	usr_name			:= usr_name, 
	usr_schema			:= usr_schema
) INTO sql_trig_part;
sql_trig := concat(sql_trig,sql_trig_part);

-- ADD ENTRY TO UPDATE TABLE LAYER_METADATA
sql_ins_part := concat('
(',num_features,',''',cdb_schema,''',''',feature_type,''',''',qml_file_name,''',''',t.lodx_label,''',''',r.class_name,''',''',l_name,''',clock_timestamp(),''',mview_name,''',''',view_name,'''),');
sql_ins := concat(sql_ins,sql_ins_part);

ELSE

sql_layer_part := concat('
DROP MATERIALIZED VIEW IF EXISTS ',usr_schema,'.',mview_name,' CASCADE;
DELETE FROM ',usr_schema,'.layer_metadata WHERE v_name = ''',view_name,''';
');
sql_layer := concat(sql_layer,sql_layer_part);

END IF;

	END LOOP; -- tin relief lod
END LOOP;  -- tin feature
--------------------------------------------------------
--------------------------------------------------------

---------------------------------------------------------------
-- Create LAYER RASTER_RELIEF_LOD0-4
---------------------------------------------------------------
--------------------------------------------------------
--------------------------------------------------------

---------------------------------------------------------------
-- Create LAYER MASSPOINT_RELIEF_LOD0-4
---------------------------------------------------------------
--------------------------------------------------------
--------------------------------------------------------

---------------------------------------------------------------
-- Create LAYER BREAKLINE_RELIEF_LOD0-4
---------------------------------------------------------------
--------------------------------------------------------
--------------------------------------------------------

-- substitute last comma with semi-colon
IF sql_ins IS NOT NULL THEN
	sql_ins := concat(sql_upd, substr(sql_ins,1, length(sql_ins)-1), ';');
END IF;
-- create the final sql statement
sql_statement := concat(sql_layer, sql_trig, sql_ins);

RETURN sql_statement;
EXCEPTION
	WHEN QUERY_CANCELED THEN
		RAISE EXCEPTION 'qgis_pkg.generate_sql_layers_relief(): Error QUERY_CANCELED';
	WHEN OTHERS THEN
		RAISE EXCEPTION 'qgis_pkg.generate_sql_layers_relief(): %', SQLERRM;
END;
$$ LANGUAGE plpgsql;
COMMENT ON FUNCTION qgis_pkg.generate_sql_layers_relief(varchar, varchar, integer, integer, numeric, geometry, boolean) IS 'Create layers for module LandUse';

----------------------------------------------------------------
-- Create FUNCTION QGIS_PKG.CREATE_LAYERS_RELIEF
----------------------------------------------------------------
DROP FUNCTION IF EXISTS    qgis_pkg.create_layers_relief(varchar, varchar, integer, integer, numeric, geometry, boolean) CASCADE;
CREATE OR REPLACE FUNCTION qgis_pkg.create_layers_relief(
cdb_schema 			varchar  DEFAULT 'citydb',
usr_name            varchar  DEFAULT 'postgres',
perform_snapping 	integer  DEFAULT 0,
digits 				integer	 DEFAULT 3,
area_poly_min 		numeric  DEFAULT 0.0001,
mview_bbox			geometry DEFAULT NULL,
force_layer_creation boolean DEFAULT FALSE
)
RETURNS integer AS $$
DECLARE
sql_statement text := NULL;

BEGIN
SELECT qgis_pkg.generate_sql_layers_relief(
	cdb_schema 			 := cdb_schema, 			
	usr_name             := usr_name,            
	perform_snapping 	 := perform_snapping, 	
	digits 				 := digits, 				
	area_poly_min 		 := area_poly_min, 		
	mview_bbox			 := mview_bbox,			
	force_layer_creation := force_layer_creation
) INTO sql_statement;

IF sql_statement IS NOT NULL THEN
--	RAISE NOTICE '
--%
--',sql_statement;
	EXECUTE sql_statement;
END IF;

RETURN 1;

EXCEPTION
	WHEN QUERY_CANCELED THEN
		RAISE EXCEPTION 'qgis_pkg.create_layers_relief(): Error QUERY_CANCELED';
	WHEN OTHERS THEN
		RAISE EXCEPTION 'qgis_pkg.create_layers_relief(): %', SQLERRM;
END;
$$ LANGUAGE plpgsql;
COMMENT ON FUNCTION qgis_pkg.create_layers_relief(varchar, varchar, integer, integer, numeric, geometry, boolean) IS 'Create layers for module Reief';

--SELECT qgis_pkg.create_layers_relief(cdb_schema := 'citydb3',force_layer_creation := FALSE);

--**************************
DO $MAINBODY$
DECLARE
BEGIN
RAISE NOTICE E'\n\nDone\n\n';
END $MAINBODY$;
--**************************
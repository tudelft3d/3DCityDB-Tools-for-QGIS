-- ****************************************************************************
-- ****************************************************************************
--
--
-- CREATE LAYERS FOR MODULE TRANSPORTATION
--
--
-- ****************************************************************************
-- ****************************************************************************

--SELECT qgis_pkg.drop_layers(usr_schema:= 'qgis_user', cdb_schema:= 'citydb', feat_type := 'Transportation'); 
--DELETE FROM qgis_user.layer_metadata WHERE cdb_schema = 'citydb' AND feature_type = 'Transportation';

----------------------------------------------------------------
-- Create FUNCTION QGIS_PKG.GENERATE_SQL_LAYERS_TRANSPORTATION
----------------------------------------------------------------
DROP FUNCTION IF EXISTS    qgis_pkg.generate_sql_layers_transportation(varchar, varchar, integer, integer, numeric, geometry, boolean) CASCADE;
CREATE OR REPLACE FUNCTION qgis_pkg.generate_sql_layers_transportation(
cdb_schema 			varchar,
usr_name            varchar,
perform_snapping 	integer  DEFAULT 0,
digits 				integer	 DEFAULT 3,
area_poly_min 		numeric  DEFAULT 0.0001,
mview_bbox			geometry DEFAULT NULL,
force_layer_creation boolean DEFAULT FALSE
) 
RETURNS text AS $$

DECLARE
usr_schema      varchar := 'qgis_user';  -- will be concat('qgis',usr_name);
feature_type 	varchar := 'Transportation';
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
-- Create LAYER TRANSPORTATION_LOD1
---------------------------------------------------------------
FOR r IN 
	SELECT * FROM (VALUES
	('TransportationComplex'::varchar,	42::integer, 	'tran_complex'::varchar),
	('Track',							43,				'track'),
	('Railway',							44,				'railway'),
	('Road',							45,				'road'),
	('Square',							46,				'square')	
	) AS t(class_name, class_id, class_label)
LOOP
	FOR t IN 
		SELECT * FROM (VALUES
		('LoD1'::varchar, 'lod1'::varchar)
		) AS t(lodx_name, lodx_label)
	LOOP

-- First check if there are any features at all in the database schema
sql_mview_count := concat('
SELECT count(o.id) AS n_features
FROM 
	',cdb_schema,'.transportation_complex AS o
	INNER JOIN ',cdb_schema,'.cityobject AS co ON (o.id = co.id AND o.objectclass_id = ',r.class_id,' ',sql_where,')
WHERE
	o.',t.lodx_label,'_multi_surface_id IS NOT NULL;
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
		',cdb_schema,'.transportation_complex AS o
		INNER JOIN ',cdb_schema,'.cityobject AS co ON (o.id = co.id AND o.objectclass_id = ',r.class_id,' ',sql_where,')		
		INNER JOIN ',cdb_schema,'.surface_geometry AS sg ON (sg.root_id = o.',t.lodx_label,'_multi_surface_id AND sg.geometry IS NOT NULL)
	GROUP BY sg.cityobject_id
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
  o.class,
  o.class_codespace,
  string_to_array(o.function, ''--/\--'')::varchar[] AS function,
  string_to_array(o.function_codespace, ''--/\--'')::varchar[] AS function_codespace,  
  string_to_array(o.usage, ''--/\--'')::varchar[] AS usage,
  string_to_array(o.usage_codespace, ''--/\--'')::varchar[] AS usage_codespace,
  g.geom::geometry(MultiPolygonZ,',srid_id,')
FROM
	',usr_schema,'.',mview_name,' AS g 
	INNER JOIN ',cdb_schema,'.cityobject AS co ON (g.co_id = co.id AND co.objectclass_id = ',r.class_id,')
  	INNER JOIN ',cdb_schema,'.transportation_complex AS o ON (o.id = co.id AND o.objectclass_id = ',r.class_id,');
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

	END LOOP; -- transportation lod1

---------------------------------------------------------------
-- Create LAYER TRANSPORTATION_LOD2-4
---------------------------------------------------------------
	FOR t IN 
		SELECT * FROM (VALUES
		('LoD2'::varchar, 'lod2'::varchar),
		('LoD3'			, 'lod3'),
		('LoD4'			, 'lod4')
		) AS t(lodx_name, lodx_label)
	LOOP

-- First check if there are any features at all in the database schema
sql_mview_count := concat('
SELECT count(foo.co_id) AS n_features
FROM (
	SELECT
		o.id AS co_id
	FROM
		',cdb_schema,'.transportation_complex AS o
	INNER JOIN ',cdb_schema,'.cityobject AS co ON (o.id = co.id AND o.objectclass_id = ',r.class_id,' ',sql_where,')		
	WHERE
		o.',t.lodx_name,'_multi_surface_id IS NOT NULL
	UNION 
	SELECT 
		o.transportation_complex_id co_id
	FROM 
		',cdb_schema,'.traffic_area AS o
	INNER JOIN ',cdb_schema,'.cityobject AS co ON (o.id = co.id AND o.objectclass_id = ',r.class_id,' ',sql_where,')
	INNER JOIN ',cdb_schema,'.transportation_complex AS tc ON (tc.id = o.transportation_complex_id AND o.objectclass_id = ',r.class_id,')	
	WHERE
		o.',t.lodx_name,'_multi_surface_id IS NOT NULL AND o.transportation_complex_id IS NOT NULL
) as foo;
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
		foo2.co_id::bigint AS co_id,
		ST_Collect(qgis_pkg.ST_snap_poly_to_grid(sg.geometry,',perform_snapping,',',digits,',',area_poly_min,'))::geometry(MultiPolygonZ, ',srid_id,') AS geom
	FROM (
		SELECT
			foo.co_id,
			unnest(foo.sg_id_array) AS sg_id
		FROM (
			SELECT
				coalesce(o.id, ta_t.co_id) as co_id,
				--o.id AS co_id,
				CASE 
					WHEN ta_t.sg_id_array IS NOT NULL THEN ta_t.sg_id_array
					ELSE ARRAY[o.',t.lodx_label,'_multi_surface_id]
				END AS sg_id_array 
			FROM 
				',cdb_schema,'.transportation_complex AS o
				INNER JOIN ',cdb_schema,'.cityobject AS co ON (o.id = co.id AND o.objectclass_id = ',r.class_id,' ',sql_where,')
				FULL OUTER JOIN (
				--INNER JOIN (
					SELECT 
						ta.transportation_complex_id AS co_id, 
						array_agg(ta.',t.lodx_label,'_multi_surface_id) AS sg_id_array
					FROM 
						',cdb_schema,'.traffic_area AS ta
						INNER JOIN ',cdb_schema,'.cityobject AS co ON (co.id = ta.id ',sql_where,')
						INNER JOIN ',cdb_schema,'.transportation_complex AS tc ON (tc.id = ta.transportation_complex_id AND tc.objectclass_id = ',r.class_id,')	
					GROUP BY ta.transportation_complex_id
				) AS ta_t ON (ta_t.co_id = o.id)
			) AS foo
		) AS foo2
		INNER JOIN ',cdb_schema,'.surface_geometry AS sg ON (sg.root_id = foo2.sg_id AND sg.geometry IS NOT NULL)
	GROUP BY foo2.co_id
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
  o.class,
  o.class_codespace,
  string_to_array(o.function, ''--/\--'')::varchar[] AS function,
  string_to_array(o.function_codespace, ''--/\--'')::varchar[] AS function_codespace,  
  string_to_array(o.usage, ''--/\--'')::varchar[] AS usage,
  string_to_array(o.usage_codespace, ''--/\--'')::varchar[] AS usage_codespace,
  g.geom::geometry(MultiPolygonZ,',srid_id,')
FROM
	',usr_schema,'.',mview_name,' AS g 
	INNER JOIN ',cdb_schema,'.cityobject AS co ON (g.co_id = co.id AND co.objectclass_id = ',r.class_id,')
  	INNER JOIN ',cdb_schema,'.transportation_complex AS o ON (o.id = co.id AND o.objectclass_id = ',r.class_id,');
COMMENT ON VIEW ',usr_schema,'.',view_name,' IS ''View of ',r.class_name,' ',t.lodx_name,' in schema ',cdb_schema,''';
ALTER TABLE ',usr_schema,'.',view_name,' OWNER TO ',usr_name,';
');
sql_layer := concat(sql_layer,sql_layer_part);

trig_f_suffix := 'transportation_complex';

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

---------------------------------------------------------------
-- Create LAYER TRANSPORTATION_LOD2-4_(AUXILIARY)_TRAFFIC_AREA
---------------------------------------------------------------

		FOR u IN 
			SELECT * FROM (VALUES
			('TrafficArea'::varchar,	47::integer, 	'traffic_area'::varchar),
			('AuxiliaryTrafficArea',	48,				'aux_traffic_area')
			) AS t(class_name, class_id, class_label)
		LOOP

-- First check if there are any features at all in the database schema
sql_mview_count := concat('
SELECT count(o.id) AS n_features
FROM 
	',cdb_schema,'.traffic_area AS o
INNER JOIN ',cdb_schema,'.cityobject AS co ON (o.id = co.id AND o.objectclass_id = ',u.class_id,' ',sql_where,')
INNER JOIN ',cdb_schema,'.transportation_complex AS tc ON (tc.id = o.transportation_complex_id AND tc.objectclass_id = ',r.class_id,')	
WHERE
	o.',t.lodx_name,'_multi_surface_id IS NOT NULL
;
');
EXECUTE sql_mview_count INTO num_features;

RAISE NOTICE 'Found % features for % % %', num_features, r.class_name, t.lodx_name, u.class_name;

l_name         := concat(r.class_label,'_',t.lodx_label,'_',u.class_label);
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
		',cdb_schema,'.traffic_area AS o
		INNER JOIN ',cdb_schema,'.cityobject AS co ON (o.id = co.id AND o.objectclass_id = ',u.class_id,' ',sql_where,')
		INNER JOIN ',cdb_schema,'.transportation_complex AS tc ON (tc.id = o.transportation_complex_id AND tc.objectclass_id = ',r.class_id,')		
		INNER JOIN ',cdb_schema,'.surface_geometry AS sg ON (sg.root_id = o.',t.lodx_label,'_multi_surface_id AND sg.geometry IS NOT NULL)
	GROUP BY sg.cityobject_id
WITH NO DATA;
COMMENT ON MATERIALIZED VIEW ',usr_schema,'.',mview_name,' IS ''Mat. view of (',r.class_name,') ',t.lodx_name,' ',u.class_name,' in schema ',cdb_schema,''';
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
  o.class,
  o.class_codespace,
  string_to_array(o.function, ''--/\--'')::varchar[] AS function,
  string_to_array(o.function_codespace, ''--/\--'')::varchar[] AS function_codespace,  
  string_to_array(o.usage, ''--/\--'')::varchar[] AS usage,
  string_to_array(o.usage_codespace, ''--/\--'')::varchar[] AS usage_codespace,
  o.surface_material,
  o.transportation_complex_id,
  g.geom::geometry(MultiPolygonZ,',srid_id,')
FROM
	',usr_schema,'.',mview_name,' AS g 
	INNER JOIN ',cdb_schema,'.cityobject AS co ON (g.co_id = co.id AND co.objectclass_id = ',r.class_id,')
  	INNER JOIN ',cdb_schema,'.traffic_area AS o ON (o.id = co.id AND o.objectclass_id = ',u.class_id,')
  	INNER JOIN ',cdb_schema,'.transportation_complex AS tc ON (tc.id = o.transportation_complex_id AND tc.objectclass_id = ',r.class_id,');
COMMENT ON VIEW ',usr_schema,'.',view_name,' IS ''View of (',r.class_name,') ',t.lodx_name,' ',u.class_name,' in schema ',cdb_schema,''';
ALTER TABLE ',usr_schema,'.',view_name,' OWNER TO ',usr_name,';
');
sql_layer := concat(sql_layer,sql_layer_part);

trig_f_suffix := 'traffic_area';

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

		END LOOP; -- end loop (auxiliary) traffic areas lod 2-4

	END LOOP; -- transportation lod2-4

END LOOP;  -- transportation
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
		RAISE EXCEPTION 'qgis_pkg.generate_sql_layers_transportation(): Error QUERY_CANCELED';
	WHEN OTHERS THEN
		RAISE EXCEPTION 'qgis_pkg.generate_sql_layers_transportation(): %', SQLERRM;
END;
$$ LANGUAGE plpgsql;
COMMENT ON FUNCTION qgis_pkg.generate_sql_layers_transportation
(varchar, varchar, integer, integer, numeric, geometry, boolean) 
IS 'Create layers for module Transportation';

----------------------------------------------------------------
-- Create FUNCTION QGIS_PKG.CREATE_LAYERS_TRANSPORTATION
----------------------------------------------------------------
DROP FUNCTION IF EXISTS    qgis_pkg.create_layers_transportation(varchar, varchar, integer, integer, numeric, geometry, boolean) CASCADE;
CREATE OR REPLACE FUNCTION qgis_pkg.create_layers_transportation(
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
SELECT qgis_pkg.generate_sql_layers_transportation(
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
		RAISE EXCEPTION 'qgis_pkg.create_layers_transportation(): Error QUERY_CANCELED';
	WHEN OTHERS THEN
		RAISE EXCEPTION 'qgis_pkg.create_layers_transportation(): %', SQLERRM;
END;
$$ LANGUAGE plpgsql;
COMMENT ON FUNCTION qgis_pkg.create_layers_transportation(varchar, varchar, integer, integer, numeric, geometry, boolean) IS 'Create layers for module CityFurniture';

--SELECT qgis_pkg.create_layers_transportation(cdb_schema := 'citydb',force_layer_creation := FALSE);

--**************************
DO $MAINBODY$
DECLARE
BEGIN
RAISE NOTICE E'\n\nDone\n\n';
END $MAINBODY$;
--**************************
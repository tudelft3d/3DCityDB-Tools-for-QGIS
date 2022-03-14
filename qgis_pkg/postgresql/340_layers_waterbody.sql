-- ****************************************************************************
-- ****************************************************************************
--
--
-- CREATE LAYERS FOR MODULE WATERBODY
--
--
-- ****************************************************************************
-- ****************************************************************************

--SELECT qgis_pkg.drop_layers(usr_schema:= 'qgis_user', cdb_schema:= 'citydb', feat_type := 'WaterBody'); 
--DELETE FROM qgis_user.layer_metadata WHERE cdb_schema = 'citydb' AND feature_type = 'WaterBody';

----------------------------------------------------------------
-- Create FUNCTION QGIS_PKG.GENERATE_SQL_LAYERS_WATERBODY
----------------------------------------------------------------
DROP FUNCTION IF EXISTS    qgis_pkg.generate_sql_layers_waterbody(varchar, varchar, integer, integer, numeric, geometry, boolean) CASCADE;
CREATE OR REPLACE FUNCTION qgis_pkg.generate_sql_layers_waterbody(
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
feature_type 	varchar := 'WaterBody';
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
(schema_name, n_features, cdb_schema, feature_type, qml_file, lod, root_class, layer_name, creation_date, mv_name, v_name)
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
-- Create LAYER WATERBODY_LOD0
---------------------------------------------------------------
FOR r IN 
	SELECT * FROM (VALUES
	('WaterBody'::varchar, 9::integer, 'waterbody'::varchar)	
	) AS t(class_name, class_id, class_label)
LOOP
	FOR t IN 
		SELECT * FROM (VALUES
		('LoD0'::varchar, 'lod0'::varchar)
		) AS t(lodx_name, lodx_label)
	LOOP

-- First check if there are any features at all in the database schema
sql_mview_count := concat('
SELECT count(o.id) AS n_features
FROM 
	',cdb_schema,'.waterbody AS o
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
		',cdb_schema,'.waterbody AS o
		INNER JOIN ',cdb_schema,'.cityobject AS co ON (o.id = co.id AND o.objectclass_id = ',r.class_id,' ',sql_where,')
		INNER JOIN ',cdb_schema,'.surface_geometry AS sg ON (sg.root_id = o.',t.lodx_label,'_multi_surface_id AND sg.geometry IS NOT NULL)
	GROUP BY sg.cityobject_id
WITH NO DATA;
COMMENT ON MATERIALIZED VIEW ',usr_schema,'.',mview_name,' IS ''Mat. view of ',r.class_name,' ',t.lodx_name,' in schema ',cdb_schema,''';
CREATE INDEX ',mview_idx_name,' ON ',usr_schema,'.',mview_name,' (co_id);
CREATE INDEX ',mview_spx_name,' ON ',usr_schema,'.',mview_name,' USING gist (geom);
ALTER TABLE ',usr_schema,'.',mview_name,' OWNER TO ',usr_name,';
--DELETE FROM qgis_pkg.layer_metadata WHERE v_name = ''',view_name,''';
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
(''',cdb_schema,''',''',num_features,''',''',cdb_schema,''',''',feature_type,''',''',qml_file_name,''',''',t.lodx_label,''',''',r.class_name,''',''',l_name,''',clock_timestamp(),''',mview_name,''',''',view_name,'''),');
sql_ins := concat(sql_ins,sql_ins_part);

ELSE

sql_layer_part := concat('
DROP MATERIALIZED VIEW IF EXISTS ',usr_schema,'.',mview_name,' CASCADE;
DELETE FROM ',usr_schema,'.layer_metadata WHERE v_name = ''',view_name,''';
');
sql_layer := concat(sql_layer,sql_layer_part);

END IF;

	END LOOP; -- waterbody lod1

---------------------------------------------------------------
-- Create LAYER WATERBODY_LOD1
---------------------------------------------------------------
	FOR t IN 
		SELECT * FROM (VALUES
		('LoD1'::varchar, 'lod1'::varchar)
		) AS t(lodx_name, lodx_label)
	LOOP

-- First check if there are any features at all in the database schema
sql_mview_count := concat('
SELECT count(o.id) AS n_features
FROM 
	',cdb_schema,'.waterbody AS o
	INNER JOIN ',cdb_schema,'.cityobject AS co ON (o.id = co.id AND o.objectclass_id = ',r.class_id,' ',sql_where,')
WHERE
	o.',t.lodx_label,'_multi_surface_id IS NOT NULL OR o.',t.lodx_label,'_solid_id IS NOT NULL;
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
	FROM (
		SELECT
			o1.',t.lodx_label,'_multi_surface_id AS sg_id
		FROM
			',cdb_schema,'.waterbody AS o1
			INNER JOIN ',cdb_schema,'.cityobject AS co ON (co.id = o1.id AND o1.objectclass_id = ',r.class_id,' ',sql_where,')
		UNION
		SELECT
			o2.',t.lodx_label,'_solid_id AS sg_id
		FROM
			',cdb_schema,'.waterbody AS o2
			INNER JOIN ',cdb_schema,'.cityobject AS co ON (co.id = o2.id AND o2.objectclass_id = ',r.class_id,' ',sql_where,')
		) AS o
		INNER JOIN ',cdb_schema,'.surface_geometry AS sg ON (sg.root_id = o.sg_id AND sg.geometry IS NOT NULL)
	GROUP BY sg.cityobject_id
WITH NO DATA;
COMMENT ON MATERIALIZED VIEW ',usr_schema,'.',mview_name,' IS ''Mat. view of ',r.class_name,' ',t.lodx_name,' in schema ',cdb_schema,''';
CREATE INDEX ',mview_idx_name,' ON ',usr_schema,'.',mview_name,' (co_id);
CREATE INDEX ',mview_spx_name,' ON ',usr_schema,'.',mview_name,' USING gist (geom);
ALTER TABLE ',usr_schema,'.',mview_name,' OWNER TO ',usr_name,';
--DELETE FROM qgis_pkg.layer_metadata WHERE v_name = ''',view_name,''';
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
  	INNER JOIN ',cdb_schema,'.waterbody AS o ON (o.id = co.id AND o.objectclass_id = ',r.class_id,');
COMMENT ON VIEW ',usr_schema,'.',view_name,' IS ''View of ',r.class_name,' ',t.lodx_name,' in schema ',cdb_schema,''';
ALTER TABLE ',usr_schema,'.',view_name,' OWNER TO ',usr_name,';
');
sql_layer := concat(sql_layer,sql_layer_part);

trig_f_suffix := 'waterbody';

SELECT qgis_pkg.generate_sql_triggers(
	view_name 			:= view_name,
	tr_function_suffix	:= trig_f_suffix,
	usr_name			:= usr_name, 
	usr_schema			:= usr_schema
) INTO sql_trig_part;
sql_trig := concat(sql_trig,sql_trig_part);

-- ADD ENTRY TO UPDATE TABLE LAYER_METADATA
sql_ins_part := concat('
(''',cdb_schema,''',''',num_features,''',''',cdb_schema,''',''',feature_type,''',''',qml_file_name,''',''',t.lodx_label,''',''',r.class_name,''',''',l_name,''',clock_timestamp(),''',mview_name,''',''',view_name,'''),');
sql_ins := concat(sql_ins,sql_ins_part);

ELSE

sql_layer_part := concat('
DROP MATERIALIZED VIEW IF EXISTS ',usr_schema,'.',mview_name,' CASCADE;
DELETE FROM ',usr_schema,'.layer_metadata WHERE v_name = ''',view_name,''';
');
sql_layer := concat(sql_layer,sql_layer_part);

END IF;

	END LOOP; -- waterbody lod1

---------------------------------------------------------------
-- Create LAYER WATERBODY_LOD2-4
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
		',cdb_schema,'.waterbody AS o
	INNER JOIN ',cdb_schema,'.cityobject AS co ON (o.id = co.id AND o.objectclass_id = ',r.class_id,' ',sql_where,')		
	WHERE
		o.',t.lodx_name,'_solid_id IS NOT NULL
	UNION 
	SELECT
		ww.waterbody_id AS co_id
	FROM 
		',cdb_schema,'.waterboundary_surface AS o
	INNER JOIN ',cdb_schema,'.cityobject AS co ON (o.id = co.id ',sql_where,')
	INNER JOIN ',cdb_schema,'.waterbod_to_waterbnd_srf AS ww ON (ww.waterboundary_surface_id = o.id)
	WHERE
		o.',t.lodx_label,'_surface_id IS NOT NULL		
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
				coalesce(o.id, ts_t.co_id) as co_id,
				--o.id AS co_id,
				CASE 
					WHEN ts_t.sg_id_array IS NOT NULL THEN ts_t.sg_id_array
					ELSE ARRAY[o.',t.lodx_label,'_solid_id]
				END AS sg_id_array 
			FROM 
				',cdb_schema,'.waterbody AS o
				INNER JOIN ',cdb_schema,'.cityobject AS co ON (o.id = co.id AND o.objectclass_id= ',r.class_id,' ',sql_where,')
				FULL OUTER JOIN (
					SELECT ww.waterbody_id AS co_id, array_agg(ts.',t.lodx_label,'_surface_id) AS sg_id_array 
					FROM 
						',cdb_schema,'.waterboundary_surface AS ts
						INNER JOIN ',cdb_schema,'.cityobject AS co ON (co.id = ts.id ',sql_where,')
						INNER JOIN ',cdb_schema,'.waterbod_to_waterbnd_srf AS ww ON (ww.waterboundary_surface_id = ts.id)
					WHERE
						ts.',t.lodx_label,'_surface_id IS NOT NULL
					GROUP BY ww.waterbody_id
					) AS ts_t ON (ts_t.co_id = o.id)
			WHERE 
				sg_id_array IS NOT NULL
			) AS foo
		) AS foo2
		INNER JOIN ',cdb_schema,'.surface_geometry AS sg ON (sg.root_id = foo2.sg_id AND sg.geometry IS NOT NULL)
	GROUP BY foo2.co_id
WITH NO DATA;
COMMENT ON MATERIALIZED VIEW ',usr_schema,'.',mview_name,' IS ''Mat. view of ',r.class_name,' ',t.lodx_name,' in schema ',cdb_schema,''';
CREATE INDEX ',mview_idx_name,' ON ',usr_schema,'.',mview_name,' (co_id);
CREATE INDEX ',mview_spx_name,' ON ',usr_schema,'.',mview_name,' USING gist (geom);
ALTER TABLE ',usr_schema,'.',mview_name,' OWNER TO ',usr_name,';
--DELETE FROM qgis_pkg.layer_metadata WHERE v_name = ''',view_name,''';
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
  	INNER JOIN ',cdb_schema,'.waterbody AS o ON (o.id = co.id AND o.objectclass_id = ',r.class_id,');
COMMENT ON VIEW ',usr_schema,'.',view_name,' IS ''View of ',r.class_name,' ',t.lodx_name,' in schema ',cdb_schema,''';
ALTER TABLE ',usr_schema,'.',view_name,' OWNER TO ',usr_name,';
');
sql_layer := concat(sql_layer,sql_layer_part);

trig_f_suffix := 'waterbody';

SELECT qgis_pkg.generate_sql_triggers(
	view_name 			:= view_name,
	tr_function_suffix	:= trig_f_suffix,
	usr_name			:= usr_name, 
	usr_schema			:= usr_schema
) INTO sql_trig_part;
sql_trig := concat(sql_trig,sql_trig_part);

-- ADD ENTRY TO UPDATE TABLE LAYER_METADATA
sql_ins_part := concat('
(''',cdb_schema,''',''',num_features,''',''',cdb_schema,''',''',feature_type,''',''',qml_file_name,''',''',t.lodx_label,''',''',r.class_name,''',''',l_name,''',clock_timestamp(),''',mview_name,''',''',view_name,'''),');
sql_ins := concat(sql_ins,sql_ins_part);

ELSE

sql_layer_part := concat('
DROP MATERIALIZED VIEW IF EXISTS ',usr_schema,'.',mview_name,' CASCADE;
DELETE FROM ',usr_schema,'.layer_metadata WHERE v_name = ''',view_name,''';
');
sql_layer := concat(sql_layer,sql_layer_part);

END IF;


---------------------------------------------------------------
-- Create LAYER WATERBODY_LOD2-4_WATERBOUNDARY_SURFACE
---------------------------------------------------------------

		FOR u IN 
			SELECT * FROM (VALUES
			('WaterSurface'::varchar,	11::integer,'watersurf'::varchar),
			('WaterGroundSurface',		12,			'watergroundsurf'),
			('WaterClosureSurface',		13,			'waterclosuresurf')
			) AS t(class_name, class_id, class_label)
		LOOP

-- First check if there are any features at all in the database schema
sql_mview_count := concat('
SELECT count(o.id) AS n_features
FROM 
	',cdb_schema,'.waterboundary_surface AS o
	INNER JOIN ',cdb_schema,'.cityobject AS co ON (o.id = co.id AND o.objectclass_id = ',u.class_id,' ',sql_where,')
WHERE
	o.',t.lodx_label,'_surface_id IS NOT NULL;
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
		',cdb_schema,'.waterboundary_surface AS o
		INNER JOIN ',cdb_schema,'.cityobject AS co ON (o.id = co.id AND o.objectclass_id = ',u.class_id,' ',sql_where,')		
		INNER JOIN ',cdb_schema,'.surface_geometry AS sg ON (sg.root_id = o.',t.lodx_name,'_surface_id AND sg.geometry IS NOT NULL)
	GROUP BY sg.cityobject_id
WITH NO DATA;
COMMENT ON MATERIALIZED VIEW ',usr_schema,'.',mview_name,' IS ''Mat. view of (',r.class_name,') ',t.lodx_name,' ',u.class_name,' in schema ',cdb_schema,''';
CREATE INDEX ',mview_idx_name,' ON ',usr_schema,'.',mview_name,' (co_id);
CREATE INDEX ',mview_spx_name,' ON ',usr_schema,'.',mview_name,' USING gist (geom);
ALTER TABLE ',usr_schema,'.',mview_name,' OWNER TO ',usr_name,';
--DELETE FROM qgis_pkg.layer_metadata WHERE v_name = ''',view_name,''';
--REFRESH MATERIALIZED VIEW ',usr_schema,'.',mview_name,';
');
sql_layer := concat(sql_layer,sql_layer_part);

-------
-- VIEW
-------
sql_layer_part := concat('
DROP VIEW IF EXISTS    ',usr_schema,'.',view_name,' CASCADE;
CREATE OR REPLACE VIEW ',usr_schema,'.',view_name,' AS
SELECT',sql_co_atts,
CASE 
	WHEN u.class_name = 'WaterSurface' THEN '
	  water_level,
	  water_level_codespace,'
	ELSE 
		NULL
END,'
  ww.waterbody_id,
  g.geom::geometry(MultiPolygonZ,',srid_id,')
FROM
	',usr_schema,'.',mview_name,' AS g 
	INNER JOIN ',cdb_schema,'.cityobject AS co ON (g.co_id = co.id AND co.objectclass_id = ',u.class_id,')
  	INNER JOIN ',cdb_schema,'.waterboundary_surface AS o ON (o.id = co.id AND o.objectclass_id = ',u.class_id,')
  	INNER JOIN ',cdb_schema,'.waterbod_to_waterbnd_srf AS ww ON (ww.waterboundary_surface_id = o.id);
COMMENT ON VIEW ',usr_schema,'.',view_name,' IS ''View of (',r.class_name,') ',t.lodx_name,' ',u.class_name,' in schema ',cdb_schema,''';
ALTER TABLE ',usr_schema,'.',view_name,' OWNER TO ',usr_name,';
');
sql_layer := concat(sql_layer,sql_layer_part);

IF u.class_name = 'WaterSurface' THEN
	trig_f_suffix := 'waterboundary_surface_watersurface';
ELSE
	trig_f_suffix := 'waterboundary_surface';
END IF;

SELECT qgis_pkg.generate_sql_triggers(
	view_name 			:= view_name,
	tr_function_suffix	:= trig_f_suffix,
	usr_name			:= usr_name, 
	usr_schema			:= usr_schema
) INTO sql_trig_part;
sql_trig := concat(sql_trig,sql_trig_part);

-- ADD ENTRY TO UPDATE TABLE LAYER_METADATA
sql_ins_part := concat('
(''',cdb_schema,''',''',num_features,''',''',cdb_schema,''',''',feature_type,''',''',qml_file_name,''',''',t.lodx_label,''',''',r.class_name,''',''',l_name,''',clock_timestamp(),''',mview_name,''',''',view_name,'''),');
sql_ins := concat(sql_ins,sql_ins_part);

ELSE

sql_layer_part := concat('
DROP MATERIALIZED VIEW IF EXISTS ',usr_schema,'.',mview_name,' CASCADE;
DELETE FROM ',usr_schema,'.layer_metadata WHERE v_name = ''',view_name,''';
');
sql_layer := concat(sql_layer,sql_layer_part);

END IF;

		END LOOP; -- end loop (auxiliary) traffic areas lod 2-4

	END LOOP; -- waterbody lod2-4

END LOOP;  -- waterbody
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
		RAISE EXCEPTION 'qgis_pkg.generate_sql_layers_waterbody(): Error QUERY_CANCELED';
	WHEN OTHERS THEN
		RAISE EXCEPTION 'qgis_pkg.generate_sql_layers_waterbody(): %', SQLERRM;
END;
$$ LANGUAGE plpgsql;
COMMENT ON FUNCTION qgis_pkg.generate_sql_layers_waterbody
(varchar, varchar, integer, integer, numeric, geometry, boolean) 
IS 'Create layers for module WaterBody';

----------------------------------------------------------------
-- Create FUNCTION QGIS_PKG.CREATE_LAYERS_WATERBODY
----------------------------------------------------------------
DROP FUNCTION IF EXISTS    qgis_pkg.create_layers_waterbody(varchar, varchar, integer, integer, numeric, geometry, boolean) CASCADE;
CREATE OR REPLACE FUNCTION qgis_pkg.create_layers_waterbody(
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
SELECT qgis_pkg.generate_sql_layers_waterbody(
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
		RAISE EXCEPTION 'qgis_pkg.create_layers_waterbody(): Error QUERY_CANCELED';
	WHEN OTHERS THEN
		RAISE EXCEPTION 'qgis_pkg.create_layers_waterbody(): %', SQLERRM;
END;
$$ LANGUAGE plpgsql;
COMMENT ON FUNCTION qgis_pkg.create_layers_waterbody(varchar, varchar, integer, integer, numeric, geometry, boolean) IS 'Create layers for module CityFurniture';

--SELECT qgis_pkg.create_layers_waterbody(cdb_schema := 'citydb3',force_layer_creation := FALSE);

--**************************
DO $MAINBODY$
DECLARE
BEGIN
RAISE NOTICE E'\n\nDone\n\n';
END $MAINBODY$;
--**************************
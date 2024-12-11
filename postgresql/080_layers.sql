-- ***********************************************************************
--
-- This script installs a set of functions into qgis_pkg schema
-- List of functions:
--
-- qgis_pkg.get_all_attribute_id_in_schema()
-- qgis_pkg.get_view_name()
-- qgis_pkg.generate_sql_layer_matview_footer_join()
-- qgis_pkg.generate_sql_layer_matview_footer_attri_table()
-- qgis_pkg.create_layer_multiple_joins()
-- qgis_pkg.get_attribute_columns()
-- qgis_pkg.check_attribute_column_is_json()
-- qgis_pkg.create_attris_table_view()
-- qgis_pkg.create_layer_attri_table()
-- qgis_pkg.create_layer()
-- qgis_pkg.create_class_layers()
-- qgis_pkg.create_all_layer()
--
-- ***********************************************************************


----------------------------------------------------------------
-- Create FUNCTION QGIS_PKG.GET_ALL_ATTRIBUTE_ID_IN_SCHEMA
----------------------------------------------------------------
DROP FUNCTION IF EXISTS    qgis_pkg.get_all_attribute_id_in_schema(varchar, varchar, integer, boolean) CASCADE;
CREATE OR REPLACE FUNCTION qgis_pkg.get_all_attribute_id_in_schema(
	usr_schema  varchar,
	cdb_schema 	varchar,
	objectclass_id integer,
	is_nested	boolean DEFAULT FALSE -- TRUE to gather all nested attributes
)
RETURNS integer[] 
AS $$
DECLARE
	qi_usr_schema varchar := quote_ident(usr_schema);
	qi_cdb_schema varchar := quote_ident(cdb_schema);
	qi_is_nested boolean  := is_nested;
	oc_id integer 		  := objectclass_id;
	classname varchar 	  := qgis_pkg.objectclass_id_to_classname(qi_cdb_schema, oc_id);
	attri_ids integer[];
	attri_id integer;
	attri_type varchar;
	sql_attri_id text;
	r RECORD;
BEGIN
-- Check if cdb_schema exists
IF qi_cdb_schema IS NULL or NOT EXISTS(SELECT 1 FROM information_schema.schemata AS i WHERE i.schema_name::varchar = qi_cdb_schema) THEN
	RAISE EXCEPTION 'cdb_schema (%) is invalid. It must be an existing schema', qi_cdb_schema;
END IF;

-- Check if feature attribute metadata table exists
IF NOT EXISTS(SELECT 1 FROM information_schema.tables WHERE table_schema = qi_usr_schema AND table_name = 'feature_attribute_metadata') THEN
	RAISE EXCEPTION '%.feature_attribute_metadata table not yet created. Please create it first', qi_usr_schema;
END IF;

IF NOT is_nested THEN
	attri_type := 'inline';
	EXECUTE format('
	SELECT ARRAY(
		SELECT fam.id 
		FROM %I.feature_attribute_metadata AS fam 
		WHERE fam.cdb_schema = %L 
			AND fam.objectclass_id = %L 
			AND fam.is_nested = %L)
	', qi_usr_schema, qi_cdb_schema, oc_id, qi_is_nested) INTO attri_ids;
	IF ARRAY_LENGTH(attri_ids, 1) = 0 THEN
		attri_ids := NULL;
	END IF;
ELSE
	attri_type := 'nested';
	FOR r IN
		EXECUTE format('
			SELECT DISTINCT fam.cdb_schema, fam.objectclass_id, fam.parent_attribute_name 
			FROM %I.feature_attribute_metadata AS fam 
			WHERE fam.cdb_schema = %L 
				AND fam.objectclass_id = %L 
				AND fam.is_nested = %L
		', qi_usr_schema, qi_cdb_schema, oc_id, qi_is_nested)
	LOOP
		attri_id  := (SELECT * FROM qgis_pkg.get_attribute_key_id(qi_usr_schema, r.cdb_schema, r.objectclass_id , r.parent_attribute_name));
		attri_ids := ARRAY_APPEND(attri_ids, attri_id);
	END LOOP;
END IF;

IF attri_ids IS NULL THEN
	RAISE NOTICE 'No % attributes of % (oc_id = %) found in schema %.', attri_type, classname, oc_id, cdb_schema;
	RETURN attri_ids;
ELSE
	RETURN attri_ids;
END IF;

EXCEPTION
	WHEN QUERY_CANCELED THEN
		RAISE EXCEPTION 'qgis_pkg.get_all_attribute_id_in_schema(): Error QUERY_CANCELED';
  	WHEN OTHERS THEN 
		RAISE EXCEPTION 'qgis_pkg.get_all_attribute_id_in_schema(): %', SQLERRM;
END;
$$ LANGUAGE plpgsql;
COMMENT ON FUNCTION qgis_pkg.get_all_attribute_id_in_schema(varchar, varchar, integer, boolean) IS 'Get all existing attribute key_id(s) in the given schema';
REVOKE EXECUTE ON FUNCTION qgis_pkg.get_all_attribute_id_in_schema(varchar, varchar, integer, boolean) FROM public;
-- Example
-- SELECT * FROM qgis_pkg.get_all_attribute_id_in_schema('qgis_bstsai','citydb', 901);	-- inline
-- SELECT * FROM qgis_pkg.get_all_attribute_id_in_schema('qgis_bstsai','citydb', 901, TRUE); -- nested


----------------------------------------------------------------
-- Create FUNCTION QGIS_PKG.GET_VIEW_NAME
----------------------------------------------------------------
DROP FUNCTION IF EXISTS    qgis_pkg.get_view_name(varchar, integer, boolean, boolean) CASCADE;
CREATE OR REPLACE FUNCTION qgis_pkg.get_view_name(
	usr_schema 	varchar,
	key_id 		integer,
	is_attri 	boolean DEFAULT FALSE, -- TRUE to extract attribute view or mv's name. Otherwise, get that of geometry
	is_matview	boolean DEFAULT FALSE -- TRUE to extract mv name. Otherwise, get view name
)
RETURNS text 
AS $$
DECLARE
	qi_usr_schema varchar := quote_ident(usr_schema);
	view_name text;
	usr_view_name text;
	sql_get_view text;
BEGIN
-- Check if current user has created specific schema named "qgis_(usr_name)"
IF qi_usr_schema IS NULL OR NOT EXISTS(SELECT * FROM information_schema.schemata AS i WHERE schema_name = qi_usr_schema) THEN
	RAISE EXCEPTION 'user_schema: % does not exist. Please create it first', qi_usr_schema;
END IF;

-- Check if feature geometry metadata table exists
IF NOT EXISTS(SELECT 1 FROM information_schema.tables WHERE table_schema = qi_usr_schema AND table_name = 'feature_geometry_metadata') THEN
	RAISE EXCEPTION '%.feature_geometry_metadata table not yet created. Please create it first', qi_usr_schema;
END IF;

-- Check if feature attribute metadata table exists
IF NOT EXISTS(SELECT 1 FROM information_schema.tables WHERE table_schema = qi_usr_schema AND table_name = 'feature_attribute_metadata') THEN
	RAISE EXCEPTION '%.feature_attribute_metadata table not yet created. Please create it first', qi_usr_schema;
END IF;

IF NOT is_matview THEN
-- View name
	IF NOT is_attri THEN
	-- get geometry view name
		sql_get_view := concat('SELECT fgm.view_name FROM ',qi_usr_schema,'.feature_geometry_metadata AS fgm WHERE fgm.id = ',key_id,';');
		EXECUTE sql_get_view INTO view_name;
	ELSE
	-- get attribute view name
		sql_get_view := concat('SELECT fgm.view_name FROM ',qi_usr_schema,'.feature_attribute_metadata AS fgm WHERE fgm.id = ',key_id,';');
		EXECUTE sql_get_view INTO view_name;
	END IF;
ELSE
-- Materialized view name
	IF NOT is_attri THEN
	-- get geometry view name
		sql_get_view := concat('SELECT fgm.mview_name FROM ',qi_usr_schema,'.feature_geometry_metadata AS fgm WHERE fgm.id = ',key_id,';');
		EXECUTE sql_get_view INTO view_name;
	ELSE
	-- get attribute view name
		sql_get_view := concat('SELECT fgm.mview_name FROM ',qi_usr_schema,'.feature_attribute_metadata AS fgm WHERE fgm.id = ',key_id,';');
		EXECUTE sql_get_view INTO view_name;
	END IF;
END IF;

RETURN view_name;

IF view_name IS NULL THEN
	-- usr_view_name := concat(qi_usr_schema, '.', view_name);
	RAISE NOTICE 'The (materialized) view name not found. Please check if it is already created!';
END IF;

EXCEPTION
	WHEN QUERY_CANCELED THEN
		RAISE EXCEPTION 'qgis_pkg.get_view_name(): Error QUERY_CANCELED';
  	WHEN OTHERS THEN 
		RAISE EXCEPTION 'qgis_pkg.get_view_name(): %', SQLERRM;
END;
$$ LANGUAGE plpgsql;
COMMENT ON FUNCTION qgis_pkg.get_view_name(varchar, integer, boolean, boolean) IS 'Lookup the geometry or attribute (materialized) view name by the given key_id';
REVOKE EXECUTE ON FUNCTION qgis_pkg.get_view_name(varchar, integer, boolean, boolean) FROM public;
-- Example
-- SELECT * FROM qgis_pkg.get_view_name('qgis_bstsai', 1); -- geom, view
-- SELECT * FROM qgis_pkg.get_view_name('qgis_bstsai', 1, FALSE, TRUE); -- geom, mview
-- SELECT * FROM qgis_pkg.get_view_name('qgis_bstsai', 1, TRUE); -- attri, view
-- SELECT * FROM qgis_pkg.get_view_name('qgis_bstsai', 1, TRUE, TRUE); -- attri, mview


----------------------------------------------------------------
-- Create FUNCTION QGIS_PKG.GENERATE_SQL_LAYER_MATVIEW_FOOTER_JOIN
----------------------------------------------------------------
DROP FUNCTION IF EXISTS    qgis_pkg.generate_sql_layer_matview_footer_join(varchar,varchar,varchar,varchar,integer[]) CASCADE;
CREATE OR REPLACE FUNCTION qgis_pkg.generate_sql_layer_matview_footer_join(
	usr_name 		varchar,
	usr_schema 		varchar,
	cdb_schema		varchar,
	lv_name	 		varchar,
	attribute_ids 	integer[] DEFAULT NULL
)
RETURNS text 
AS $$
DECLARE
	qi_usr_name varchar   := quote_ident(usr_name);
	qi_usr_schema varchar := quote_ident(usr_schema);
	qi_cdb_schema varchar := quote_ident(cdb_schema);
	qi_lv_name CONSTANT varchar := trim(both '"' from lv_name);
    qi_lv_name_idx CONSTANT varchar := (SELECT REGEXP_REPLACE((trim(both '"' from lv_name)), '^=lmv_', ''));
	view_col_names text[]; view_col_name text;
	val_col_count integer := 1;
	attri_view_name text;
	attri_count integer := 1;
	attri_id integer;
    attri_idx_name varchar;
	val_col_type varchar;
    sql_statement text;
BEGIN

sql_statement := concat('
CREATE INDEX "', qi_lv_name_idx, '_g_1_f_id_idx" ON ', qi_usr_schema, '."', qi_lv_name, '" (f_id);
CREATE INDEX "', qi_lv_name_idx, '_g_2_o_id_idx" ON ', qi_usr_schema, '."', qi_lv_name, '" (f_object_id);
CREATE INDEX "', qi_lv_name_idx, '_g_3_geom_spx" ON ', qi_usr_schema, '."', qi_lv_name, '" USING gist (geom);');

IF attribute_ids IS NOT NULL THEN
	FOREACH attri_id IN ARRAY attribute_ids
	LOOP
		attri_view_name := qgis_pkg.get_view_name(qi_usr_schema, attri_id, TRUE, TRUE);
		view_col_names := qgis_pkg.get_view_column_name(qi_usr_schema, attri_view_name);
		IF ARRAY_LENGTH(view_col_names,1) > 0 THEN
			FOREACH view_col_name IN ARRAY view_col_names
			LOOP
				IF view_col_name <> 'f_id' THEN
					val_col_type := qgis_pkg.get_view_column_type(qi_usr_schema, attri_view_name, view_col_name);
					IF val_col_type <> 'json' THEN
					attri_idx_name := concat('"', qi_lv_name_idx, '_a', attri_count, '_', val_col_count, '"');
sql_statement := concat(sql_statement,'
CREATE INDEX ',attri_idx_name,' ON ',qi_usr_schema,'."',qi_lv_name,'" ("',view_col_name,'");');
					END IF;
				END IF;
				val_col_count := val_col_count + 1;
			END LOOP;
		val_col_count := 1;
		END IF;
		attri_count := attri_count + 1;
	END LOOP;
END IF;
	
sql_statement := concat(sql_statement,'
ALTER TABLE ',qi_usr_schema,'."',qi_lv_name,'" OWNER TO ',qi_usr_name,';
REFRESH MATERIALIZED VIEW ',qi_usr_schema,'."',qi_lv_name,'"');
RETURN sql_statement;

EXCEPTION
	WHEN QUERY_CANCELED THEN
		RAISE EXCEPTION 'qgis_pkg.generate_sql_layer_matview_footer_join(): Error QUERY_CANCELED';
  	WHEN OTHERS THEN 
		RAISE EXCEPTION 'qgis_pkg.generate_sql_layer_matview_footer_join(): %', SQLERRM;
END;
$$ LANGUAGE plpgsql;
COMMENT ON FUNCTION qgis_pkg.generate_sql_layer_matview_footer_join(varchar, varchar, varchar, varchar, integer[]) IS 'Generate the footer for creating indices on every layer materialized view value columns and refresh it';
REVOKE EXECUTE ON FUNCTION qgis_pkg.generate_sql_layer_matview_footer_join(varchar, varchar, varchar, varchar, integer[]) FROM public;


----------------------------------------------------------------
-- Create FUNCTION QGIS_PKG.GENERATE_SQL_LAYER_MATVIEW_FOOTER_ATTRI_TABLE
----------------------------------------------------------------
DROP FUNCTION IF EXISTS    qgis_pkg.generate_sql_layer_matview_footer_attri_table(varchar,varchar,varchar,varchar,varchar) CASCADE;
CREATE OR REPLACE FUNCTION qgis_pkg.generate_sql_layer_matview_footer_attri_table(
	usr_name 		varchar,
	usr_schema 		varchar,
	cdb_schema		varchar,
	lv_name	 		varchar,
	attri_view_name varchar DEFAULT NULL
)
RETURNS text 
AS $$
DECLARE
	qi_usr_name varchar   := quote_ident(usr_name);
	qi_usr_schema varchar := quote_ident(usr_schema);
	qi_cdb_schema varchar := quote_ident(cdb_schema);
    qi_lv_name CONSTANT varchar := trim(both '"' from lv_name);
	qi_lv_name_idx CONSTANT varchar := (SELECT REGEXP_REPLACE((trim(both '"' from lv_name)), '^=lmv_', ''));
	view_col_names text[]; view_col_name text;
	attri_count integer := 1;
    attri_idx_name varchar;
	val_col_type varchar;
    sql_statement text;
BEGIN

sql_statement := concat('
CREATE INDEX "', qi_lv_name_idx, '_g_1_f_id_idx" ON ', qi_usr_schema, '."', qi_lv_name, '" (f_id);
CREATE INDEX "', qi_lv_name_idx, '_g_2_o_id_idx" ON ', qi_usr_schema, '."', qi_lv_name, '" (f_object_id);
CREATE INDEX "', qi_lv_name_idx, '_g_3_geom_spx" ON ', qi_usr_schema, '."', qi_lv_name, '" USING gist (geom);');

IF attri_view_name IS NOT NULL THEN
	view_col_names := (qgis_pkg.get_view_column_name(qi_usr_schema, attri_view_name))[2:];
	IF ARRAY_LENGTH(view_col_names,1) > 0 THEN
		FOREACH view_col_name IN ARRAY view_col_names
		LOOP
			IF view_col_name <> 'f_id' THEN
				val_col_type := qgis_pkg.get_view_column_type(qi_usr_schema, attri_view_name, view_col_name);
				IF val_col_type <> 'json' THEN
					attri_idx_name := concat('"', qi_lv_name_idx, '_a_', attri_count, '"');
					sql_statement := concat(sql_statement,'
					CREATE INDEX ',attri_idx_name,' ON ',qi_usr_schema,'."',qi_lv_name,'" ("',view_col_name,'");');
				END IF;
			END IF;
			attri_count := attri_count + 1;
		END LOOP;
	END IF;
END IF;

	
sql_statement := concat(sql_statement,'
ALTER TABLE ',qi_usr_schema,'."',qi_lv_name,'" OWNER TO ',qi_usr_name,';
REFRESH MATERIALIZED VIEW ',qi_usr_schema,'."',qi_lv_name,'";');
RETURN sql_statement;

EXCEPTION
	WHEN QUERY_CANCELED THEN
		RAISE EXCEPTION 'qgis_pkg.generate_sql_layer_matview_footer_attri_table(): Error QUERY_CANCELED';
  	WHEN OTHERS THEN 
		RAISE EXCEPTION 'qgis_pkg.generate_sql_layer_matview_footer_attri_table(): %', SQLERRM;
END;
$$ LANGUAGE plpgsql;
COMMENT ON FUNCTION qgis_pkg.generate_sql_layer_matview_footer_attri_table(varchar,varchar,varchar,varchar,varchar) IS 'Generate the footer for creating indices on every layer materialized view value columns and refresh it';
REVOKE EXECUTE ON FUNCTION qgis_pkg.generate_sql_layer_matview_footer_attri_table(varchar,varchar,varchar,varchar,varchar) FROM public;
--Example
-- SELECT * FROM qgis_pkg.generate_sql_layer_matview_footer_attri_table('bstsai', 'qgis_bstsai', 'citydb', 'test_layer', '"_amv_citydb_Building_attributes"')


----------------------------------------------------------------
-- Create FUNCTION QGIS_PKG.CREATE_LAYER_MULTIPLE_JOINS()
----------------------------------------------------------------
DROP FUNCTION IF EXISTS    qgis_pkg.create_layer_multiple_joins(varchar, varchar, integer, integer[], boolean, boolean) CASCADE;
CREATE OR REPLACE FUNCTION qgis_pkg.create_layer_multiple_joins(
	usr_schema varchar,
	cdb_schema varchar,
	geometry_id integer,
	attribute_ids integer[] DEFAULT NULL,
	is_matview boolean DEFAULT FALSE,
	is_all_attris boolean DEFAULT FALSE
)
RETURNS varchar
AS $$
DECLARE
	qi_usr_name varchar	  		  	:= (SELECT substring(usr_schema from 'qgis_(.*)') AS usr_name);
	qi_usr_schema varchar 			:= quote_ident(usr_schema);
	qi_cdb_schema varchar 			:= quote_ident(cdb_schema);
	ql_cdb_schema varchar 			:= quote_literal(cdb_schema);
	attri_val_cols_array varchar[][]; -- store a list of attribute val_cols
	attri_val_cols varchar[]; -- store all val_col name of attribute view(s)
	attri_val_col varchar; 
	attri_address varchar; -- store the inline or nested attribute number and prefix. e.g,. _ia_{4}_na_{1} means 4 inline and 1 nested attributes are selected
	g_id integer := geometry_id;
	inline_attri_ids integer[];
	nested_attri_ids integer[];
	geom_view_name varchar; attri_view_name varchar;
	attri_count integer := 1;
	qi_lv_header text;
	qi_lmv_header text;
	qi_lmv_footer text;
	sql_l_select text;
	sql_l_from text;
	sql_layer text;
	sql_statement text;
	r RECORD;
	p_oc_id integer;
	oc_id integer;
	parent_classname varchar;
	classname varchar;
	parent_class_alias varchar;
	class_alias varchar;

	-- for layer metadata
	sql_feat_count text;
	sql_ins_cols text;
	sql_ins_vals text;
	sql_ins text;
	f_type varchar;
	g_type varchar;
	lod varchar;
	attri_id integer;
	attri_ids integer[];
	is_nested boolean;
	selected_attri varchar;
	attri_view_names varchar[];
	inline_attris varchar[];
	nested_attris varchar[];
	num_features integer;
	l_name varchar;

BEGIN
-- Check if usr_schema exists
IF qi_usr_schema IS NULL or NOT EXISTS(SELECT 1 FROM information_schema.schemata AS i WHERE i.schema_name::varchar = qi_usr_schema) THEN
	RAISE EXCEPTION 'usr_schema (%) not found. Please create usr_schema first', qi_usr_schema;
END IF;
	
-- Check if cdb_schema exists
IF qi_cdb_schema IS NULL or NOT EXISTS(SELECT 1 FROM information_schema.schemata AS i WHERE i.schema_name::varchar = qi_cdb_schema) THEN
	RAISE EXCEPTION 'cdb_schema (%) not found. It must be an existing schema', qi_cdb_schema;
END IF;

sql_l_select := concat('
SELECT
	g.f_id AS f_id,
	g.f_object_id AS f_object_id,
	g.geom AS geom,');


sql_l_from := concat('
FROM ');

-- Prepare layer metadata insertion
sql_ins_cols := concat('	
cdb_schema, feature_type, objectclass_id, classname, lod, geometry_type, 
gv_name, is_matview, is_all_attris, is_joins, n_features, creation_date,');

-- retrieve the geometry view (matview by default)
geom_view_name := qgis_pkg.get_view_name(qi_usr_schema, geometry_id, FALSE, TRUE);

-- check if the geometry views have been created, if not first created both geometry view and matview
IF geom_view_name IS NULL THEN
	-- view
	-- PERFORM qgis_pkg.create_geometry_view(qi_usr_schema, qi_cdb_schema, r.parent_objectclass_id, r.objectclass_id, r.datatype_id, r.geometry_name, r.lod, r.geometry_type, r.postgis_geom_type, FALSE, r.bbox_type);
	-- matview
	PERFORM qgis_pkg.create_geometry_view(qi_usr_schema, qi_cdb_schema, r.parent_objectclass_id, r.objectclass_id, r.datatype_id, r.geometry_name, r.lod, r.geometry_type, r.postgis_geom_type, TRUE, r.bbox_type);
	geom_view_name := qgis_pkg.get_view_name(qi_usr_schema, geometry_id, FALSE, TRUE);
	PERFORM qgis_pkg.refresh_geometry_materialized_view(qi_usr_schema, qi_cdb_schema, r.parent_objectclass_id, r.objectclass_id, r.geometry_name);
END IF;

sql_feat_count := concat('
	SELECT count(f_id) AS n_features
	FROM ',qi_usr_schema,'.',geom_view_name,';
');

EXECUTE sql_feat_count INTO num_features;

EXECUTE format ('
SELECT 
	fgm.bbox_type ,fgm.parent_objectclass_id, fgm.objectclass_id, fgm.datatype_id, 
	fgm.geometry_name, fgm.lod, fgm.geometry_type, fgm.postgis_geom_type
FROM %I.feature_geometry_metadata AS fgm
WHERE fgm.id = %L;'
, qi_usr_schema, g_id) INTO r;

p_oc_id     := r.parent_objectclass_id;
oc_id 		:= r.objectclass_id;
IF p_oc_id <> 0 THEN
	parent_classname	:= qgis_pkg.objectclass_id_to_classname(qi_cdb_schema, p_oc_id);
	parent_class_alias	:= qgis_pkg.objectclass_id_to_alias(p_oc_id);
END IF;
classname 	:= qgis_pkg.objectclass_id_to_classname(qi_cdb_schema, oc_id);
class_alias := qgis_pkg.objectclass_id_to_alias(oc_id);
g_type 		:= (CASE WHEN r.geometry_name LIKE 'lod%' AND LENGTH(r.geometry_name) > 3 THEN SUBSTRING(r.geometry_name FROM POSITION('lod%' IN r.geometry_name) + 5) ELSE r.geometry_type END);
lod			:= concat('lod', r.lod);
EXECUTE format('SELECT feature_type FROM qgis_pkg.classname_lookup WHERE oc_id = %L', oc_id) INTO f_type;

sql_ins_vals := concat('VALUES (
', ql_cdb_schema,',', quote_literal(f_type),',', oc_id,',', quote_literal(classname),',', quote_literal(lod),',', quote_literal(g_type),',
', quote_literal(geom_view_name),',', quote_literal(is_matview), ',', quote_literal(is_all_attris),', TRUE,', num_features,', clock_timestamp(),
');

IF is_all_attris AND attribute_ids IS NULL THEN
	inline_attri_ids := qgis_pkg.get_all_attribute_id_in_schema(qi_usr_schema, qi_cdb_schema, oc_id);
	nested_attri_ids := qgis_pkg.get_all_attribute_id_in_schema(qi_usr_schema, qi_cdb_schema, oc_id, TRUE);
	attribute_ids := ARRAY(SELECT unnest(inline_attri_ids || nested_attri_ids) AS id ORDER BY id ASC);
END IF;

-- generate layer name
SELECT qgis_pkg.generate_layer_name_attri_joins(qi_usr_schema, qi_cdb_schema, g_id, attribute_ids, is_matview, is_all_attris) INTO l_name;

-- retrieve the attribute view(s)
IF attribute_ids IS NULL THEN
-- only geometry
	attri_address := '_no_attri_joins"';
	IF NOT is_matview THEN
		IF parent_class_alias IS NOT NULL THEN
			sql_ins_cols 	:= concat(sql_ins_cols, 'parent_objectclass_id, parent_classname,');
			sql_ins_vals 	:= concat(sql_ins_vals, p_oc_id,',', quote_literal(parent_classname),',');
		END IF;
		qi_lv_header := qgis_pkg.generate_sql_view_header(qi_usr_schema, l_name);
		sql_layer := concat(qi_lv_header, 
			LEFT(sql_l_select, LENGTH(sql_l_select)-1),
			sql_l_from, qi_usr_schema,'.',geom_view_name,' AS g;
		');
	ELSE 
		IF parent_class_alias IS NOT NULL THEN
			sql_ins_cols 	:= concat(sql_ins_cols, 'parent_objectclass_id, parent_classname,');
			sql_ins_vals 	:= concat(sql_ins_vals, p_oc_id,',', quote_literal(parent_classname),',');
		END IF;
		qi_lmv_header := qgis_pkg.generate_sql_matview_header(qi_usr_schema, l_name);
		qi_lmv_footer := qgis_pkg.generate_sql_layer_matview_footer_join(qi_usr_name, qi_usr_schema, qi_cdb_schema, l_name, attribute_ids);
		sql_layer := concat(qi_lmv_header,
			LEFT(sql_l_select, LENGTH(sql_l_select)-1),
			sql_l_from, qi_usr_schema,'.',geom_view_name,' AS g;', 
			qi_lmv_footer, ';
		');
	END IF;
ELSE
	sql_l_from := concat(sql_l_from, qi_usr_schema,'.',geom_view_name,' AS g ');
	FOREACH attri_id IN ARRAY attribute_ids
	LOOP
		selected_attri 	:= qgis_pkg.attribute_key_id_to_name(qi_usr_schema, qi_cdb_schema, oc_id, attri_id);
		-- Check the given attri_id is nested
		EXECUTE format('SELECT is_nested FROM %I.feature_attribute_metadata WHERE id = %L', qi_usr_schema, attri_id) INTO is_nested;
		IF is_nested THEN
			nested_attris := ARRAY_APPEND(nested_attris, selected_attri);
		ELSE
			inline_attris := ARRAY_APPEND(inline_attris, selected_attri);
		END IF;
		attri_view_name := qgis_pkg.get_view_name(qi_usr_schema, attri_id, TRUE, is_matview);
		-- check if the attribute views have been created, if not first created both attribute view and matview
		-- view or matview determined by the layer view type specification
		IF attri_view_name IS NULL THEN
			EXECUTE format('
			SELECT fam.objectclass_id, fam.parent_attribute_name, fam.attribute_name, fam.is_nested, fam.bbox_type
			FROM %I.feature_attribute_metadata AS fam
			WHERE fam.id = %L;
			',qi_usr_schema, attri_id) INTO r;
			IF NOT r.is_nested THEN
				SELECT qgis_pkg.create_attribute_view(qi_usr_schema, qi_cdb_schema, r.objectclass_id, r.attribute_name, r.is_nested, r.bbox_type, is_matview) INTO attri_view_name;
			ELSE
				SELECT qgis_pkg.create_attribute_view(qi_usr_schema, qi_cdb_schema, r.objectclass_id, r.parent_attribute_name, r.is_nested, r.bbox_type, is_matview) INTO attri_view_name;
			END IF;
		END IF;
		attri_view_names := ARRAY_APPEND(attri_view_names, attri_view_name);
		-- Get all value columns name of a attri_view
		attri_val_cols 	:= qgis_pkg.get_view_column_name(qi_usr_schema, attri_view_name);
		-- Get rid of the f_id from the attri_view value columns
		attri_val_cols := (SELECT ARRAY (SELECT unnest(attri_val_cols) OFFSET 1));
		IF attri_val_cols IS NOT NULL THEN
			FOREACH attri_val_col IN ARRAY attri_val_cols
			LOOP
			sql_l_select := concat(sql_l_select, '
				a',attri_count,'."',attri_val_col,'",');
			END LOOP;
		END IF;
		sql_l_from := concat(sql_l_from, '  
			LEFT OUTER JOIN ',qi_usr_schema,'.',attri_view_name,' AS a',attri_count,' ON g.f_id = a',attri_count,'.f_id');
		attri_count := attri_count + 1;
	END LOOP;
	sql_l_select := LEFT(sql_l_select, LENGTH(sql_l_select)-1); -- remove the last comma
	sql_ins_cols := concat(sql_ins_cols, 'av_join_names,');
	sql_ins_vals := concat(sql_ins_vals, quote_literal(attri_view_names), ',');

	IF ARRAY_LENGTH(inline_attris, 1) > 0 THEN
		sql_ins_cols	:= concat(sql_ins_cols, 'inline_attris, ');
		sql_ins_vals	:= concat(sql_ins_vals, quote_literal(inline_attris),',');
	END IF;
	IF ARRAY_LENGTH(nested_attris, 1) > 0 THEN
		sql_ins_cols	:= concat(sql_ins_cols, 'nested_attris, ');
		sql_ins_vals	:= concat(sql_ins_vals, quote_literal(nested_attris),',');
	END IF;
	
	IF NOT is_matview THEN
		IF parent_class_alias IS NOT NULL THEN
			sql_ins_cols 	:= concat(sql_ins_cols, 'parent_objectclass_id, parent_classname,');
			sql_ins_vals 	:= concat(sql_ins_vals, p_oc_id,',', quote_literal(parent_classname),',');
		END IF;
		qi_lv_header := qgis_pkg.generate_sql_view_header(qi_usr_schema, l_name);
		sql_layer := concat(qi_lv_header, 
			sql_l_select,
			sql_l_from, ';'
		);
	ELSE
		IF parent_class_alias IS NOT NULL THEN
			sql_ins_cols 	:= concat(sql_ins_cols, 'parent_objectclass_id, parent_classname,');
			sql_ins_vals 	:= concat(sql_ins_vals, p_oc_id,',', quote_literal(parent_classname),',');
		END IF;
		qi_lmv_header := qgis_pkg.generate_sql_matview_header(qi_usr_schema, l_name);
		qi_lmv_footer := qgis_pkg.generate_sql_layer_matview_footer_join(qi_usr_name, qi_usr_schema, qi_cdb_schema, l_name, attribute_ids);
		sql_layer := concat(qi_lmv_header,
			sql_l_select,
			sql_l_from,';',
			qi_lmv_footer,';
		');
	END IF;
END IF;

sql_ins_cols := concat(sql_ins_cols, 'layer_name,');
sql_ins_vals := concat(sql_ins_vals, quote_literal(l_name),',');
sql_ins := concat(' 
DELETE FROM ',qi_usr_schema,'.layer_metadata AS l WHERE l.cdb_schema = ',ql_cdb_schema,' AND l.layer_name = ',quote_literal(l_name),';
INSERT INTO ',qi_usr_schema,'.layer_metadata (', LEFT(sql_ins_cols, LENGTH(sql_ins_cols)-1), ')', LEFT(sql_ins_vals, LENGTH(sql_ins_vals)-1), ')');

sql_statement := concat(sql_layer, sql_ins);

EXECUTE sql_statement;

RETURN concat(qi_usr_schema, '.', l_name);
	
EXCEPTION
	WHEN QUERY_CANCELED THEN
		RAISE EXCEPTION 'qgis_pkg.create_layer_multiple_joins(): Error QUERY_CANCELED';
  	WHEN OTHERS THEN 
		RAISE EXCEPTION 'qgis_pkg.create_layer_multiple_joins(): %', SQLERRM;
END;
$$ LANGUAGE plpgsql;
COMMENT ON FUNCTION qgis_pkg.create_layer_multiple_joins(varchar, varchar, integer, integer[], boolean, boolean) IS 'Create layer as views or materialized views by joining specified geometry and attribute view(s)';
REVOKE EXECUTE ON FUNCTION qgis_pkg.create_layer_multiple_joins(varchar, varchar, integer, integer[], boolean, boolean) FROM public;
-- Example
-- SELECT * FROM qgis_pkg.create_layer_multiple_joins('qgis_bstsai', 'citydb', 5); 						-- only geometry - view	
-- SELECT * FROM qgis_pkg.create_layer_multiple_joins('qgis_bstsai', 'citydb', 5, NULL, TRUE); 			-- only geometry - matview
-- SELECT * FROM qgis_pkg.create_layer_multiple_joins('qgis_bstsai', 'citydb', 14, ARRAY[4,7,8,9,13]);	-- g + 3 ia + 2 na -- view
-- SELECT * FROM qgis_pkg.create_layer_multiple_joins('qgis_bstsai', 'citydb', 5, ARRAY[4,7,8,9,13], TRUE);	-- g + 3 ia + 2 na -- matview


----------------------------------------------------------------
-- Create FUNCTION QGIS_PKG.GET_ATTRIBUTE_COLUMNS
----------------------------------------------------------------
DROP FUNCTION IF EXISTS    qgis_pkg.get_attribute_columns(text) CASCADE;
CREATE OR REPLACE FUNCTION qgis_pkg.get_attribute_columns(
	sql_attri text
)
RETURNS text[]
AS $$
DECLARE
	match_pattern text;
	select_clause text;
	attri_cols_ text[];
	attri_cols text[];
	col text;
BEGIN
-- check if CROSSTAB exists to determine the match pattern
SELECT
    CASE 
        WHEN position('CROSSTAB' IN upper(sql_attri)) > 0 THEN 'SELECT\s+(.*?)\s+FROM\s+CROSSTAB\('
        ELSE 'SELECT\s+(.*?)\s+FROM'
    END AS crosstab_status
INTO match_pattern;

-- Extract the value columns in the SELECT clause
SELECT (REGEXP_MATCHES(sql_attri, match_pattern, 'si'))[1] INTO select_clause;

-- Split the result extracted text in the SELECT clause into array
attri_cols := STRING_TO_ARRAY(select_clause, ',');

FOR i IN 1..ARRAY_LENGTH(attri_cols,1)
LOOP
	col := (SELECT (REGEXP_MATCHES(attri_cols[i], '.*\sAS\s(.*?)$', 'i'))[1]);
	attri_cols[i] := col;
END LOOP;

RETURN attri_cols;
	
EXCEPTION
	WHEN QUERY_CANCELED THEN
		RAISE EXCEPTION 'qgis_pkg.get_attribute_columns(): Error QUERY_CANCELED';
  	WHEN OTHERS THEN 
		RAISE EXCEPTION 'qgis_pkg.get_attribute_columns(): %', SQLERRM;
END;
$$ LANGUAGE plpgsql;
COMMENT ON FUNCTION qgis_pkg.get_attribute_columns(text) IS 'Extract the value columns from a collect attribute query';
REVOKE EXECUTE ON FUNCTION qgis_pkg.get_attribute_columns(text) FROM public;
-- Example
-- SELECT * FROM qgis_pkg.get_attribute_columns((SELECT qgis_pkg.collect_inline_attribute('qgis_bstsai', 'citydb', 901, 'function')))
-- SELECT * FROM qgis_pkg.get_attribute_columns((SELECT qgis_pkg.collect_inline_attribute('qgis_bstsai', 'citydb', 901, 'storeyHeightsAboveGround')))
-- SELECT * FROM qgis_pkg.get_attribute_columns((SELECT qgis_pkg.collect_inline_attribute('qgis_bstsai', 'citydb', 901, 'description')))
-- SELECT * FROM qgis_pkg.get_attribute_columns((SELECT qgis_pkg.collect_inline_attribute('qgis_bstsai', 'rh_v5', 709, 'direction')))
-- SELECT * FROM qgis_pkg.get_attribute_columns((SELECT qgis_pkg.collect_nested_attribute('qgis_bstsai', 'citydb', 901, 'height')))


----------------------------------------------------------------
-- Create FUNCTION QGIS_PKG.CHECK_ATTRIBUTE_COLUMN_IS_JSON
----------------------------------------------------------------
DROP FUNCTION IF EXISTS    qgis_pkg.check_attribute_column_is_json(text) CASCADE;
CREATE OR REPLACE FUNCTION qgis_pkg.check_attribute_column_is_json(
	sql_attri text
)
RETURNS text[]
AS $$
DECLARE
	match_pattern text;
	select_clause text;
	attri_cols text[];
	is_json text;
	
BEGIN
-- check if CROSSTAB exists to determine the match pattern
SELECT
    CASE 
        WHEN position('CROSSTAB' IN upper(sql_attri)) > 0 THEN 'SELECT\s+(.*?)\s+FROM\s+CROSSTAB\('
        ELSE 'SELECT\s+(.*?)\s+FROM'
    END AS crosstab_status
INTO match_pattern;

-- Extract the value columns in the SELECT clause
SELECT (REGEXP_MATCHES(sql_attri, match_pattern, 'si'))[1] INTO select_clause;

-- Split the result extracted text in the SELECT clause into array
attri_cols := STRING_TO_ARRAY(select_clause, ',');

FOR i IN 1..ARRAY_LENGTH(attri_cols,1)
LOOP
	is_json := (CASE WHEN attri_cols[i] ~* '^.*p\.val_array\s+AS\s+".*"$' THEN 'true' ELSE 'false' END);
	attri_cols[i] := is_json;
END LOOP;

RETURN attri_cols;
	
EXCEPTION
	WHEN QUERY_CANCELED THEN
		RAISE EXCEPTION 'qgis_pkg.check_attribute_column_is_json(): Error QUERY_CANCELED';
  	WHEN OTHERS THEN 
		RAISE EXCEPTION 'qgis_pkg.check_attribute_column_is_json(): %', SQLERRM;
END;
$$ LANGUAGE plpgsql;
COMMENT ON FUNCTION qgis_pkg.check_attribute_column_is_json(text) IS 'Check whether the value columns from a collected attribute query is json type';
REVOKE EXECUTE ON FUNCTION qgis_pkg.check_attribute_column_is_json(text) FROM public;
-- Example
-- SELECT * FROM qgis_pkg.check_attribute_column_is_json((SELECT qgis_pkg.collect_inline_attribute('qgis_bstsai', 'citydb', 901, 'storeyHeightsAboveGround')))


----------------------------------------------------------------
-- Create FUNCTION QGIS_PKG.CREATE_ATTRIS_TABLE_VIEW
----------------------------------------------------------------
-- The function creates the view or materialized view of selected feature attributes into a integrated table regarding an objectclass
DROP FUNCTION IF EXISTS    qgis_pkg.create_attris_table_view(varchar, varchar, integer, integer, integer[], boolean, boolean) CASCADE;
CREATE OR REPLACE FUNCTION qgis_pkg.create_attris_table_view(
	usr_schema varchar,
	cdb_schema varchar,
	objectclass_id integer,
	geometry_id integer,
	attribute_ids integer[] DEFAULT NULL,
	is_matview boolean DEFAULT FALSE,
	is_all_attris boolean DEFAULT FALSE
)
RETURNS integer[]
AS $$
DECLARE
	qi_usr_name varchar	  := (SELECT substring(usr_schema from 'qgis_(.*)') AS usr_name);
	qi_usr_schema varchar := quote_ident(usr_schema);
	qi_cdb_schema varchar := quote_ident(cdb_schema);
	classname varchar := (SELECT qgis_pkg.objectclass_id_to_classname(cdb_schema, objectclass_id));
	num_attri integer;
	attri_count integer := 2;
	attri_index integer := 2;
	attri_val_cols text[]; -- store all val_col name of attribute view(s)
	attri_val_col_types text[]; -- store all val_col name of attribute view(s)
	attri_val_col varchar;
	attri_id integer;
	ct_type_name varchar;
	check_ct_type_name varchar;
	ct_type_header text;
	sql_attri text;
	sql_view_header text;
	sql_matview_footer text;
	sql_atv_ct_header text;
	sql_atv_select_f_id text;
	sql_atv_select_val text;
	sql_atv_select text;
	sql_atv_from text;
	sql_atv_full_join_key text;
	sql_atv text;
	r RECORD;

	view_name varchar;
	view_prefix CONSTANT varchar := '_av_';
	matview_prefix CONSTANT varchar := '_amv_';

	-- for all_attri
	oc_id integer := objectclass_id;
	inline_attri_ids integer[];
	nested_attri_ids integer[];
	attri_ids integer[] := attribute_ids;
	v_attri_ids integer[]; -- valid attributes
BEGIN
-- Check if usr_schema exists
IF qi_usr_schema IS NULL or NOT EXISTS(SELECT 1 FROM information_schema.schemata AS i WHERE i.schema_name::varchar = qi_usr_schema) THEN
	RAISE EXCEPTION 'usr_schema (%) not found. Please create usr_schema first', qi_usr_schema;
END IF;
	
-- Check if cdb_schema exists
IF qi_cdb_schema IS NULL or NOT EXISTS(SELECT 1 FROM information_schema.schemata AS i WHERE i.schema_name::varchar = qi_cdb_schema) THEN
	RAISE EXCEPTION 'cdb_schema (%) not found. It must be an existing schema', qi_cdb_schema;
END IF;

IF is_all_attris THEN
	inline_attri_ids := qgis_pkg.get_all_attribute_id_in_schema(qi_usr_schema, qi_cdb_schema, oc_id);
	nested_attri_ids := qgis_pkg.get_all_attribute_id_in_schema(qi_usr_schema, qi_cdb_schema, oc_id, TRUE);
	attri_ids := ARRAY(SELECT unnest(inline_attri_ids || nested_attri_ids) AS id ORDER BY id ASC);
	attribute_ids := attri_ids;
END IF;

-- View name and header creation
IF NOT is_matview THEN
	view_name 			:= concat('"',view_prefix, qi_cdb_schema, '_', classname, '_g_', geometry_id,'_attributes"');
	sql_view_header 	:= qgis_pkg.generate_sql_view_header(qi_usr_schema, view_name);
ELSE
	view_name 			:= concat('"', matview_prefix, qi_cdb_schema, '_', classname, '_g_', geometry_id,'_attributes"');
	sql_view_header 	:= qgis_pkg.generate_sql_matview_header(qi_usr_schema, view_name);
	sql_matview_footer 	:= concat('
CREATE INDEX ', qi_cdb_schema,'_', objectclass_id, '_g_', geometry_id, '_attri_f_id_idx ON ', qi_usr_schema, '.', view_name, ' (f_id);');
END IF;

num_attri := (ARRAY_LENGTH(attri_ids, 1));

sql_atv_select := concat('
SELECT');

IF attri_ids IS NOT NULL THEN
	-- only 1 attribute
	attri_id := attribute_ids[1];
	EXECUTE format('
	SELECT fam.bbox_type, fam.objectclass_id, fam.parent_attribute_name, fam.attribute_name, fam.is_nested 
	FROM %I.feature_attribute_metadata AS fam
	WHERE fam.id = %L;
	', qi_usr_schema, attri_id) INTO r;
	IF NOT r.is_nested THEN
		SELECT qgis_pkg.collect_inline_attribute(qi_usr_schema, qi_cdb_schema, r.objectclass_id, r.attribute_name, r.bbox_type) INTO sql_attri;
	ELSE
		SELECT qgis_pkg.collect_nested_attribute(qi_usr_schema, qi_cdb_schema, r.objectclass_id, r.parent_attribute_name, r.bbox_type) INTO sql_attri;
	END IF;

	-- In case the scanned attribute has no valid entries (the sql_attri will be null in this case)
	IF sql_attri IS NOT NULL THEN
	v_attri_ids := ARRAY_APPEND(v_attri_ids, attri_id);
	-- Check if composite type exist in attribute query
	-- If true, separate the ct_type_header and the rest of the query for later adding the view creation header
	ct_type_header := (SELECT (REGEXP_MATCH(sql_attri, '(DROP TYPE IF EXISTS .*?;[\n\s]*CREATE TYPE .*?;)'))[1]);
	IF ct_type_header IS NOT NULL THEN
		ct_type_name := (SELECT (REGEXP_MATCH(sql_attri, 'DROP TYPE IF EXISTS (.*?);[\s\n]*CREATE TYPE (.*?) AS \(.*?\);'))[1]);
		check_ct_type_name := trim(both '"' from ct_type_name);
		sql_attri := (SELECT (REGEXP_SUBSTR(sql_attri, 'SELECT.*?AS ct\(.*?\)')));
		--Check if ct_type already existed
		IF NOT EXISTS (SELECT 1 FROM pg_type WHERE typname = check_ct_type_name) THEN
			sql_atv_ct_header := concat(sql_atv_ct_header,
			ct_type_header);
		END IF;
	END IF;

	attri_val_cols 		:= (SELECT qgis_pkg.get_attribute_columns(sql_attri));
	attri_val_col_types	:= (SELECT qgis_pkg.check_attribute_column_is_json(sql_attri));
		
	FOR i IN 1..ARRAY_LENGTH(attri_val_cols, 1)
	LOOP
		IF attri_val_cols[i] = 'f_id' THEN
			sql_atv_select_f_id := concat('
				COALESCE(a1.', attri_val_cols[i],',');
		ELSE
			sql_atv_select_val := concat(sql_atv_select_val,'
				a1.',attri_val_cols[i],',');

		-- adding matview footer, excluding the json type column
			IF attri_val_col_types[i] <> 'true' THEN
				sql_matview_footer := concat(sql_matview_footer,'
				CREATE INDEX "', qi_cdb_schema,'_', objectclass_id, '_g_', geometry_id, '_attri_', (trim (both '"' FROM attri_val_cols[i])),'_idx" ON ', qi_usr_schema, '.', view_name, ' (',attri_val_cols[i],');');
			END IF;
		END IF;
	END LOOP;
	sql_atv_from := concat('
	FROM ('
	, sql_attri, ') AS a1');
	END IF;

	-- multiple attributes
	IF num_attri > 1 THEN
		sql_atv_full_join_key := concat('COALESCE(a1.f_id,');
		-- FOR i IN 2..num_attri
		WHILE attri_index <= num_attri THEN
		LOOP
			attri_id := attribute_ids[attri_index]; -- start with 2
			EXECUTE format('
			SELECT fam.bbox_type, fam.objectclass_id, fam.parent_attribute_name, fam.attribute_name, fam.is_nested
			FROM %I.feature_attribute_metadata AS fam
			WHERE fam.id = %L;
			', qi_usr_schema, attri_id) INTO r;
			IF NOT r.is_nested THEN
				SELECT qgis_pkg.collect_inline_attribute(qi_usr_schema, qi_cdb_schema, r.objectclass_id, r.attribute_name, r.bbox_type) INTO sql_attri;
			ELSE
				SELECT qgis_pkg.collect_nested_attribute(qi_usr_schema, qi_cdb_schema, r.objectclass_id, r.parent_attribute_name, r.bbox_type) INTO sql_attri;
			END IF;
			
			-- In case the scanned attribute has no valid entries (the sql_attri will be null in this case)
			WHILE sql_attri IS NULL THEN
			LOOP
				attri_index := attri_index + 1;
				attri_id := attribute_ids[attri_index];
				EXECUTE format('
				SELECT fam.bbox_type, fam.objectclass_id, fam.parent_attribute_name, fam.attribute_name, fam.is_nested
				FROM %I.feature_attribute_metadata AS fam
				WHERE fam.id = %L;
				', qi_usr_schema, attri_id) INTO r;
				IF NOT r.is_nested THEN
					SELECT qgis_pkg.collect_inline_attribute(qi_usr_schema, qi_cdb_schema, r.objectclass_id, r.attribute_name, r.bbox_type) INTO sql_attri;
				ELSE
					SELECT qgis_pkg.collect_nested_attribute(qi_usr_schema, qi_cdb_schema, r.objectclass_id, r.parent_attribute_name, r.bbox_type) INTO sql_attri;
				END IF;
			END LOOP;
			v_attri_ids := ARRAY_APPEND(v_attri_ids, attri_id);
			-- Check if composite type exist in attribute query
			-- If true, separate the ct_type_header and the rest of the query for later adding the view creation header
			ct_type_header := (SELECT (REGEXP_MATCH(sql_attri, '(DROP TYPE IF EXISTS .*?;[\n\s]*CREATE TYPE .*?;)'))[1]);
			IF ct_type_header IS NOT NULL THEN
				ct_type_name := (SELECT (REGEXP_MATCH(sql_attri, 'DROP TYPE IF EXISTS (.*?);[\s\n]*CREATE TYPE (.*?) AS \(.*?\);'))[1]);
				check_ct_type_name := trim(both '"' from ct_type_name);
				sql_attri := (SELECT (REGEXP_SUBSTR(sql_attri, 'SELECT.*?AS ct\(.*?\)')));
				--Check if ct_type already existed
				IF NOT EXISTS (SELECT 1 FROM pg_type WHERE typname = check_ct_type_name) THEN
					sql_atv_ct_header := concat(sql_atv_ct_header,
					ct_type_header);
				END IF;
			END IF;

			attri_val_cols 		:= (SELECT qgis_pkg.get_attribute_columns(sql_attri));
			attri_val_col_types	:= (SELECT qgis_pkg.check_attribute_column_is_json(sql_attri));

			FOR j IN 1..ARRAY_LENGTH(attri_val_cols, 1)
			LOOP
				IF attri_val_cols[j] = 'f_id' THEN
					sql_atv_select_f_id := concat(sql_atv_select_f_id, 'a',attri_count,'.',attri_val_cols[j],',');
				ELSE
				sql_atv_select_val := concat(sql_atv_select_val,'
					a',attri_count,'.',attri_val_cols[j],',');

					-- adding matview footer, excluding the json type column
					IF attri_val_col_types[j] <> 'true' THEN
						sql_matview_footer := concat(sql_matview_footer,'
						CREATE INDEX "', qi_cdb_schema,'_', objectclass_id, '_g_', geometry_id, '_attri_', (trim (both '"' FROM attri_val_cols[j])),'_idx" ON ', qi_usr_schema, '.', view_name, ' (',attri_val_cols[j],');');
					END IF;
				END IF;
			END LOOP;

			IF attri_count - 1 > 1 THEN
				sql_atv_full_join_key := concat(sql_atv_full_join_key, ' a', attri_count-1, '.f_id,');
			END IF;

			sql_atv_from := concat(sql_atv_from,'
			FULL JOIN (', sql_attri, ') AS a', attri_count, ' 
				ON ', LEFT(sql_atv_full_join_key, LENGTH(sql_atv_full_join_key)-1),') = a', attri_count, '.f_id');
						attri_index := attri_index + 1;
						attri_count := attri_count + 1;
		END LOOP;
	END IF;
	sql_atv_select := concat(sql_atv_select,
		LEFT(sql_atv_select_f_id, LENGTH(sql_atv_select_f_id)-1), ') AS f_id,',
		LEFT(sql_atv_select_val, LENGTH(sql_atv_select_val)-1)
	);

	-- Generate the final sql_statment
	IF NOT is_matview THEN
		sql_atv := concat(sql_atv_ct_header,
			sql_view_header,
			sql_atv_select, 
			sql_atv_from, ';');
	ELSE
		sql_atv := concat(sql_atv_ct_header,
			sql_view_header,
			sql_atv_select, 
			sql_atv_from, ';',
			sql_matview_footer,'
			ALTER TABLE ',qi_usr_schema,'.',view_name,' OWNER TO ',qi_usr_name,';
			REFRESH MATERIALIZED VIEW ', qi_usr_schema, '.', view_name);
	END IF;
ELSE
	RAISE EXCEPTION 'No attribute found to create attribute table.';
END IF;

EXECUTE sql_atv;

RETURN v_attri_ids;

EXCEPTION
	WHEN QUERY_CANCELED THEN
		RAISE EXCEPTION 'qgis_pkg.create_attris_table_view(): Error QUERY_CANCELED';
  	WHEN OTHERS THEN 
		RAISE EXCEPTION 'qgis_pkg.create_attris_table_view(): %', SQLERRM;
END;
$$ LANGUAGE plpgsql;
COMMENT ON FUNCTION qgis_pkg.create_attris_table_view(varchar, varchar, integer, integer, integer[], boolean, boolean) IS 'Create view of matview of a table of specified feature attributes';
REVOKE EXECUTE ON FUNCTION qgis_pkg.create_attris_table_view(varchar, varchar, integer, integer, integer[], boolean, boolean) FROM public;
--Example
-- SELECT * FROM qgis_pkg.create_attris_table_view('qgis_bstsai', 'citydb', 901, 13, ARRAY[2]); -- name
-- SELECT * FROM qgis_pkg.create_attris_table_view('qgis_bstsai', 'citydb', 901, ARRAY[7], TRUE); -- height
-- SELECT * FROM qgis_pkg.create_attris_table_view('qgis_bstsai', 'citydb', 901, ARRAY[2,3,5,7], TRUE); -- height
-- SELECT * FROM qgis_pkg.create_attris_table_view('qgis_bstsai', 'citydb', 901, ARRAY[1,2,3,4,5,6,7,11], TRUE); -- all manual
-- SELECT * FROM qgis_pkg.create_attris_table_view('qgis_bstsai', 'citydb', 901, ARRAY[108,114,110,125], TRUE); -- all manual
-- SELECT * FROM qgis_pkg.create_attris_table_view('qgis_bstsai', 'citydb', 901, NULL, TRUE, TRUE); -- all automatic
-- SELECT * FROM qgis_pkg.create_attris_table_view('qgis_bstsai', 'rh_v5', 709, 24, NULL, TRUE, TRUE); -- all automatic
-- SELECT * FROM qgis_pkg.create_attris_table_view('qgis_bstsai', 'rh', 709, 4, NULL, TRUE, TRUE); -- rh, 709 wall: direction invalid values check


----------------------------------------------------------------
-- Create FUNCTION QGIS_PKG.CREATE_LAYER_ATTRI_TABLE
----------------------------------------------------------------
DROP FUNCTION IF EXISTS    qgis_pkg.create_layer_attri_table(varchar, varchar, integer, integer[], boolean, boolean) CASCADE;
CREATE OR REPLACE FUNCTION qgis_pkg.create_layer_attri_table(
	usr_schema varchar,
	cdb_schema varchar,
	geometry_id integer,
	attribute_ids integer[] DEFAULT NULL,
	is_matview boolean DEFAULT FALSE,
	is_all_attris boolean DEFAULT FALSE
)
RETURNS varchar
AS $$
DECLARE
	qi_usr_name varchar	  := (SELECT substring(usr_schema from 'qgis_(.*)') AS usr_name);
	qi_usr_schema varchar := quote_ident(usr_schema);
	ql_usr_schema varchar := quote_literal(usr_schema);
	qi_cdb_schema varchar := quote_ident(cdb_schema);
	ql_cdb_schema varchar := quote_literal(cdb_schema);
	geom_view_name varchar; attri_view_name varchar;
	view_col_names text[]; view_col_name text;
	p_oc_id integer; 
	oc_id integer; 
	parent_classname varchar;
	classname varchar;
	parent_class_alias varchar; 
	class_alias varchar;
	g_id integer := geometry_id;
	sql_l_select text;
	sql_l_from text;
	sql_layer text;
	sql_statement text;
	r RECORD;
	l_name varchar;
	qi_lv_header text;
	qi_lmv_header text;
	qi_lmv_footer text;

	-- for integrated attribute view name creation
	view_prefix CONSTANT varchar := '_av_';
	matview_prefix CONSTANT varchar := '_amv_';

	-- for layer metadata
	sql_feat_count text;
	sql_ins_cols text;
	sql_ins_vals text;
	sql_ins text;
	f_type varchar;
	g_type varchar;
	lod varchar;
	attri_id integer;
	attri_ids integer[];
	is_nested boolean;
	selected_attri varchar;
	inline_attris varchar[];
	nested_attris varchar[];
	num_features integer;
	
BEGIN
-- Check if usr_schema exists
IF qi_usr_schema IS NULL or NOT EXISTS(SELECT 1 FROM information_schema.schemata AS i WHERE i.schema_name::varchar = qi_usr_schema) THEN
	RAISE EXCEPTION 'usr_schema (%) not found. Please create usr_schema first', qi_usr_schema;
END IF;
	
-- Check if cdb_schema exists
IF qi_cdb_schema IS NULL or NOT EXISTS(SELECT 1 FROM information_schema.schemata AS i WHERE i.schema_name::varchar = qi_cdb_schema) THEN
	RAISE EXCEPTION 'cdb_schema (%) not found. It must be an existing schema', qi_cdb_schema;
END IF;


sql_l_select := concat('
SELECT
	g.f_id AS f_id,
	g.f_object_id AS f_object_id,
	g.geom AS geom,');

sql_l_from := concat('
FROM ');

-- Prepare layer metadata insertion
sql_ins_cols := concat('	
cdb_schema, feature_type, objectclass_id, classname, lod, geometry_type, 
gv_name, is_matview, is_all_attris, n_features, creation_date,');

-- retrieve the geometry view (matview by default)
geom_view_name := qgis_pkg.get_view_name(qi_usr_schema, geometry_id, FALSE, TRUE);
EXECUTE format('
    SELECT 
        fgm.bbox_type, fgm.parent_objectclass_id, fgm.objectclass_id, fgm.datatype_id, 
        fgm.geometry_name, fgm.lod, fgm.geometry_type, fgm.postgis_geom_type
    FROM %I.feature_geometry_metadata AS fgm
    WHERE fgm.id = %L
', qi_usr_schema, g_id) INTO r;

p_oc_id 	:= r.parent_objectclass_id;
oc_id 		:= r.objectclass_id;
IF p_oc_id <> 0 THEN
	parent_classname	:= qgis_pkg.objectclass_id_to_classname(qi_cdb_schema, p_oc_id);
	parent_class_alias	:= qgis_pkg.objectclass_id_to_alias(p_oc_id);
END IF;
classname 	:= qgis_pkg.objectclass_id_to_classname(qi_cdb_schema, oc_id);
class_alias := qgis_pkg.objectclass_id_to_alias(oc_id);
g_type  	:= (CASE WHEN r.geometry_name LIKE 'lod%' AND LENGTH(r.geometry_name) > 3 THEN SUBSTRING(r.geometry_name FROM POSITION('lod%' IN r.geometry_name) + 5) ELSE r.geometry_type END);
lod			:= concat('lod', r.lod);
EXECUTE format('SELECT feature_type FROM qgis_pkg.classname_lookup WHERE oc_id = %L', oc_id) INTO f_type;

-- check if the geometry views have been created, if not first created both geometry view and matview
IF geom_view_name IS NULL THEN
	-- view
	-- PERFORM qgis_pkg.create_geometry_view(qi_usr_schema, qi_cdb_schema, r.parent_objectclass_id, r.objectclass_id, r.datatype_id, r.geometry_name, r.lod, r.geometry_type, r.postgis_geom_type, FALSE, r.bbox_type);
	-- matview
	PERFORM qgis_pkg.create_geometry_view(qi_usr_schema, qi_cdb_schema, r.parent_objectclass_id, r.objectclass_id, r.datatype_id, r.geometry_name, r.lod, r.geometry_type, r.postgis_geom_type, TRUE, r.bbox_type);
	geom_view_name := qgis_pkg.get_view_name(qi_usr_schema, geometry_id, FALSE, TRUE);
	PERFORM qgis_pkg.refresh_geometry_materialized_view(qi_usr_schema, qi_cdb_schema, r.parent_objectclass_id, r.objectclass_id, r.geometry_name);
END IF;

sql_feat_count := concat('
	SELECT count(f_id) AS n_features
	FROM ',qi_usr_schema,'.',geom_view_name,';
');

EXECUTE sql_feat_count INTO num_features;

sql_ins_vals := concat('VALUES (
', ql_cdb_schema,',', quote_literal(f_type),',', oc_id,',', quote_literal(classname),',', quote_literal(lod),',', quote_literal(g_type),',
', quote_literal(geom_view_name),',', quote_literal(is_matview),',', quote_literal(is_all_attris),',', num_features,', clock_timestamp(),
');

-- generate layer name
SELECT qgis_pkg.generate_layer_name_attri_table(qi_usr_schema, qi_cdb_schema, g_id, attribute_ids, is_matview, is_all_attris) INTO l_name;

IF attribute_ids IS NULL AND NOT is_all_attris THEN
	-- only geometry
	attri_view_name := NULL;
	IF NOT is_matview THEN
		IF parent_class_alias IS NOT NULL THEN
			sql_ins_cols 	:= concat(sql_ins_cols, 'parent_objectclass_id, parent_classname,');
			sql_ins_vals 	:= concat(sql_ins_vals, p_oc_id,',', quote_literal(parent_classname),',');
		END IF;
		qi_lv_header 		:= qgis_pkg.generate_sql_view_header(qi_usr_schema, l_name);
		sql_layer := concat(qi_lv_header,
		LEFT(sql_l_select, LENGTH(sql_l_select)-1),
		sql_l_from, qi_usr_schema, '.', geom_view_name, ' AS g;'
		);
	ELSE
		IF parent_class_alias IS NOT NULL THEN
			sql_ins_cols 	:= concat(sql_ins_cols, 'parent_objectclass_id, parent_classname,');
			sql_ins_vals 	:= concat(sql_ins_vals, p_oc_id,',', quote_literal(parent_classname),',');
		END IF;
		qi_lmv_header 		:= qgis_pkg.generate_sql_matview_header(qi_usr_schema, l_name);
		qi_lmv_footer 		:= qgis_pkg.generate_sql_layer_matview_footer_attri_table(qi_usr_name, qi_usr_schema, qi_cdb_schema, l_name, attri_view_name);
		sql_layer := concat(qi_lmv_header,
		LEFT(sql_l_select, LENGTH(sql_l_select)-1),
		sql_l_from, qi_usr_schema, '.', geom_view_name, ' AS g;',
		qi_lmv_footer
		);
	END IF;
ELSE
	-- Create the attribute table view first
	SELECT qgis_pkg.create_attris_table_view(qi_usr_schema, qi_cdb_schema, oc_id, geometry_id, attribute_ids, is_matview, is_all_attris) INTO attri_ids;

	FOREACH attri_id IN ARRAY attri_ids
	LOOP
		selected_attri := qgis_pkg.attribute_key_id_to_name(qi_usr_schema, qi_cdb_schema, oc_id, attri_id);
		-- Check the given attri_id is nested
		EXECUTE format('SELECT is_nested FROM %I.feature_attribute_metadata WHERE id = %L', qi_usr_schema, attri_id) INTO is_nested;
		IF is_nested THEN
			nested_attris := ARRAY_APPEND(nested_attris, selected_attri);
		ELSE
			inline_attris := ARRAY_APPEND(inline_attris, selected_attri);
		END IF;
	END LOOP;
	-- Generate attri_name for later finding the attri_view for joining
	IF NOT is_matview THEN
		IF parent_class_alias IS NOT NULL THEN
			sql_ins_cols 	:= concat(sql_ins_cols, 'parent_objectclass_id, parent_classname,');
			sql_ins_vals 	:= concat(sql_ins_vals, p_oc_id,',', quote_literal(parent_classname),',');
		END IF;
		qi_lv_header 	:= qgis_pkg.generate_sql_view_header(qi_usr_schema, l_name);
		attri_view_name := concat('"', view_prefix, qi_cdb_schema, '_', classname, '_g_', geometry_id, '_attributes"');
		sql_ins_cols := concat(sql_ins_cols, 'av_table_name,');
		sql_ins_vals := concat(sql_ins_vals, quote_literal(attri_view_name),',');

		-- Get rid of the first f_id column from the attribute table view
		view_col_names 	:= (SELECT qgis_pkg.get_view_column_name(qi_usr_schema, attri_view_name))[2:];
		FOREACH view_col_name IN ARRAY view_col_names 
		LOOP
			sql_l_select := concat(sql_l_select,'
				a."',view_col_name,'",');
		END LOOP;
		sql_l_from := concat(sql_l_from, qi_usr_schema,'.',geom_view_name,' AS g
		LEFT JOIN ', qi_usr_schema,'.',attri_view_name,' AS a ON g.f_id = a.f_id;
		');		
		sql_layer := concat(qi_lv_header,
		LEFT(sql_l_select, LENGTH(sql_l_select)-1),
		sql_l_from
		);
	ELSE
		IF parent_class_alias IS NOT NULL THEN
			sql_ins_cols 	:= concat(sql_ins_cols, 'parent_objectclass_id, parent_classname,');
			sql_ins_vals 	:= concat(sql_ins_vals, p_oc_id,',', quote_literal(parent_classname),',');
		END IF;
		qi_lmv_header 	:= qgis_pkg.generate_sql_matview_header(qi_usr_schema, l_name);
		attri_view_name	:= concat('"', matview_prefix, qi_cdb_schema, '_', classname, '_g_', geometry_id, '_attributes"');
		sql_ins_cols 	:= concat(sql_ins_cols, 'av_table_name,');
		sql_ins_vals 	:= concat(sql_ins_vals, quote_literal(attri_view_name),',');
		qi_lmv_footer 	:= qgis_pkg.generate_sql_layer_matview_footer_attri_table(qi_usr_name, qi_usr_schema, qi_cdb_schema, l_name, attri_view_name);
		-- Get rid of the first f_id column from the attribute table view
		view_col_names 	:= (SELECT qgis_pkg.get_view_column_name(qi_usr_schema, attri_view_name))[2:];
		FOREACH view_col_name IN ARRAY view_col_names 
		LOOP
			sql_l_select := concat(sql_l_select,'
				a."',view_col_name,'",');
		END LOOP;
		sql_l_from := concat(sql_l_from, qi_usr_schema,'.',geom_view_name,' AS g
		LEFT JOIN ', qi_usr_schema,'.',attri_view_name,' AS a ON g.f_id = a.f_id;
		');	
		sql_layer := concat(qi_lmv_header,
		LEFT(sql_l_select, LENGTH(sql_l_select)-1),
		sql_l_from,
		qi_lmv_footer
		);
	END IF;
END IF;

sql_ins_cols := concat(sql_ins_cols, 'layer_name,');
sql_ins_vals := concat(sql_ins_vals, quote_literal(l_name),',');

IF ARRAY_LENGTH(inline_attris, 1) > 0 THEN
	sql_ins_cols 	:= concat(sql_ins_cols, 'inline_attris,');
	sql_ins_vals 	:= concat(sql_ins_vals, quote_literal(inline_attris),',');
END IF;

IF ARRAY_LENGTH(nested_attris, 1) > 0 THEN
	sql_ins_cols 	:= concat(sql_ins_cols, 'nested_attris,');
	sql_ins_vals 	:= concat(sql_ins_vals, quote_literal(nested_attris),',');
END IF;

sql_ins := concat(' 
DELETE FROM ',qi_usr_schema,'.layer_metadata AS l WHERE l.cdb_schema = ',ql_cdb_schema,' AND l.layer_name = ',quote_literal(l_name),';
INSERT INTO ',qi_usr_schema,'.layer_metadata (', LEFT(sql_ins_cols, LENGTH(sql_ins_cols)-1), ')', LEFT(sql_ins_vals, LENGTH(sql_ins_vals)-1), ')');

sql_statement := concat(sql_layer, sql_ins);

EXECUTE sql_statement;

RETURN concat(qi_usr_schema, '.', l_name);
	
EXCEPTION
	WHEN QUERY_CANCELED THEN
		RAISE EXCEPTION 'qgis_pkg.create_layer_attri_table(): Error QUERY_CANCELED';
  	WHEN OTHERS THEN 
		RAISE EXCEPTION 'qgis_pkg.create_layer_attri_table(): %', SQLERRM;
END;
$$ LANGUAGE plpgsql;
COMMENT ON FUNCTION qgis_pkg.create_layer_attri_table(varchar, varchar, integer, integer[], boolean, boolean) IS 'Create layer as views or materialized views by joining geometry and feature class attribute table view(s)';
REVOKE EXECUTE ON FUNCTION qgis_pkg.create_layer_attri_table(varchar, varchar, integer, integer[], boolean, boolean) FROM public;
-- Example
-- SELECT * FROM qgis_pkg.create_layer_attri_table('qgis_bstsai', 'citydb', 14, NULL, FALSE, TRUE); -- view: citydb all bdg lod1solid with all attris
-- SELECT * FROM qgis_pkg.create_layer_attri_table('qgis_bstsai', 'citydb', 5, NULL, TRUE, TRUE); -- matview: citydb all bdg lod1solid with all attris
-- SELECT * FROM qgis_pkg.create_layer_attri_table('qgis_bstsai', 'citydb', 14, ARRAY[40,42,46], TRUE); -- citydb all bdg lod1solid with 'description','name', 'function'
-- SELECT * FROM qgis_pkg.create_layer_attri_table('qgis_bstsai', 'rh_v5', 11, NULL, FALSE, TRUE); -- view: citydb all bdg lod1solid with all attris
-- SELECT * FROM qgis_pkg.create_layer_attri_table('qgis_bstsai', 'rh_v5', 11, NULL, TRUE, TRUE); -- 	matview:citydb all bdg lod1solid with all attris
-- SELECT * FROM qgis_pkg.create_layer_attri_table('qgis_bstsai', 'rh_v5', 15, NULL, TRUE, TRUE); -- citydb all veg lod3implicit with all attris


----------------------------------------------------------------
-- Create FUNCTION QGIS_PKG.CREATE_LAYER
----------------------------------------------------------------
DROP FUNCTION IF EXISTS    qgis_pkg.create_layer(varchar, varchar, integer, integer, text, integer, text[], boolean, boolean, boolean) CASCADE;
CREATE OR REPLACE FUNCTION qgis_pkg.create_layer(
	usr_schema varchar,
	cdb_schema varchar,
	parent_objectclass_id integer,
	objectclass_id integer,
	geometry_name text,
	lod integer,
	attris text[] DEFAULT NULL,
	is_matview boolean DEFAULT FALSE,
	is_all_attris boolean DEFAULT FALSE,
	is_joins boolean DEFAULT FALSE
)
RETURNS varchar
AS $$
DECLARE
	qi_usr_schema	varchar := quote_ident(usr_schema);
	qi_cdb_schema 	varchar	:= quote_ident(cdb_schema);
	p_oc_id 		integer := parent_objectclass_id; 
	oc_id 			integer := objectclass_id;
	geom			text	:= geometry_name;
	geom_id  		integer := qgis_pkg.get_geometry_key_id(qi_usr_schema, qi_cdb_schema, p_oc_id, oc_id, geom, lod);
	attri 			text;
	attri_id 		integer;
	attri_ids 		integer[];
	sql_layer 		text;
	l_name 			varchar;
	
BEGIN
-- Prepare the Array of specified attributes
IF attris IS NOT NULL AND NOT is_all_attris THEN
	FOREACH attri IN ARRAY attris
	LOOP
		attri_id := qgis_pkg.get_attribute_key_id(qi_usr_schema, qi_cdb_schema, oc_id, attri);
		attri_ids := ARRAY_APPEND(attri_ids, attri_id);
	END LOOP;
END IF;

-- Determine which method for layer creation
IF NOT is_joins THEN
	SELECT qgis_pkg.create_layer_attri_table(qi_usr_schema, qi_cdb_schema, geom_id, attri_ids, is_matview, is_all_attris) INTO l_name;
ELSE
	SELECT qgis_pkg.create_layer_multiple_joins(qi_usr_schema, qi_cdb_schema, geom_id, attri_ids, is_matview, is_all_attris) INTO l_name;
END IF;

RETURN l_name;
	
EXCEPTION
	WHEN QUERY_CANCELED THEN
		RAISE EXCEPTION 'qgis_pkg.create_layer(): Error QUERY_CANCELED';
  	WHEN OTHERS THEN 
		RAISE EXCEPTION 'qgis_pkg.create_layer(): %', SQLERRM;
END;
$$ LANGUAGE plpgsql;
COMMENT ON FUNCTION qgis_pkg.create_layer(varchar, varchar, integer, integer, text, integer, text[], boolean, boolean, boolean) IS 'Create feature class layer by joining geometry matview with either multiple join or table of attribute views';
REVOKE EXECUTE ON FUNCTION qgis_pkg.create_layer(varchar, varchar, integer, integer, text, integer, text[], boolean, boolean, boolean) FROM public;
-- Example
--(usr_schema, cdb_schema, p_oc_id, oc_id, geom_name, lod, attribute_name[], is_matview, is_all_attris, is_joins)
-- SELECT * FROM qgis_pkg.create_layer('qgis_bstsai', 'citydb', 0, 901, 'lod1Solid', 1); -- VIEW geom only 
-- SELECT * FROM qgis_pkg.create_layer('qgis_bstsai', 'citydb', 0, 901, 'lod1Solid', 1, NULL, TRUE); -- MATVIEW geom only
-- SELECT * FROM qgis_pkg.create_layer('qgis_bstsai', 'citydb', 0, 901, 'lod1Solid', 1, ARRAY['name','description'], FALSE, FALSE); -- VIEW g+a (TABLE) 
-- SELECT * FROM qgis_pkg.create_layer('qgis_bstsai', 'citydb', 0, 901, 'lod1Solid', 1, ARRAY['name','description'], TRUE, FALSE); -- MATVIEW g+a (TABLE)
-- SELECT * FROM qgis_pkg.create_layer('qgis_bstsai', 'citydb', 0, 901, 'lod1Solid', 1, ARRAY['name','description'], FALSE, FALSE, TRUE); -- VIEW g+a (JOIN)
-- SELECT * FROM qgis_pkg.create_layer('qgis_bstsai', 'citydb', 0, 901, 'lod1Solid', 1, ARRAY['name','description'], FALSE, TRUE, TRUE); -- MATVIEW g+a (JOIN)
-- SELECT * FROM qgis_pkg.create_layer('qgis_bstsai', 'citydb', 0, 901, 'lod1Solid', 1, NULL, FALSE, TRUE); -- VIEW g+ ALL a (TABLE)
-- SELECT * FROM qgis_pkg.create_layer('qgis_bstsai', 'citydb', 0, 901, 'lod1Solid', 1, NULL, TRUE, TRUE); -- MATVIEW g+ ALL a (TABLE)
-- SELECT * FROM qgis_pkg.create_layer('qgis_bstsai', 'citydb', 0, 901, 'lod1Solid', 1, NULL, FALSE, TRUE, TRUE); -- VIEW g+ ALL a (JOIN)
-- SELECT * FROM qgis_pkg.create_layer('qgis_bstsai', 'citydb', 0, 901, 'lod1Solid', 1, NULL, TRUE, TRUE, TRUE); -- MATVIEW g+ ALL a (JOIN)
-- SELECT qgis_pkg.create_layer('qgis_bstsai', 'vienna_v5', 0, 502, 'tin', 2, NULL, TRUE, FALSE); -- MATVIEW g+ ALL a (TABLE)


----------------------------------------------------------------
-- Create FUNCTION QGIS_PKG.CREATE_CLASS_LAYERS
----------------------------------------------------------------
DROP FUNCTION IF EXISTS qgis_pkg.create_class_layers(varchar, varchar, integer, integer, boolean, boolean) CASCADE;
CREATE OR REPLACE FUNCTION qgis_pkg.create_class_layers(
	usr_schema varchar,
	cdb_schema varchar,
	parent_objectclass_id integer,
	objectclass_id integer,
	is_matview boolean DEFAULT TRUE,
	is_joins boolean DEFAULT FALSE
)
RETURNS varchar
AS $$
DECLARE
	qi_usr_schema varchar 		:= quote_ident(usr_schema);
	qi_cdb_schema varchar 		:= quote_ident(cdb_schema);
	p_oc_id integer 			:= (CASE WHEN parent_objectclass_id IS NULL THEN 0 ELSE parent_objectclass_id END);
	oc_id integer 				:= objectclass_id;
	parent_classname varchar 	:= (CASE WHEN parent_objectclass_id IS NOT NULL THEN qgis_pkg.objectclass_id_to_classname(qi_cdb_schema, p_oc_id) ELSE NULL END);
	classname varchar 			:= (SELECT qgis_pkg.objectclass_id_to_classname(qi_cdb_schema, oc_id));
	view_type varchar			:= (CASE WHEN is_matview THEN 'MATERIALIZED VIEW' ELSE 'VIEW' END);
	layer_approach varchar		:= (CASE WHEN is_joins THEN 'attribute joins' ELSE 'attribute table' END);
	attri_count integer;
	result_text text;
	r RECORD;
	
BEGIN
	-- Check if feature geometry metadata table exists
	IF NOT EXISTS(SELECT 1 FROM information_schema.tables WHERE table_schema = qi_usr_schema AND table_name = 'feature_geometry_metadata') THEN
		RAISE EXCEPTION '%.feature_geometry_metadata table not yet created. Please create it first', qi_usr_schema;
	END IF;

	-- Check if feature attribute metadata table exists
	IF NOT EXISTS(SELECT 1 FROM information_schema.tables WHERE table_schema = qi_usr_schema AND table_name = 'feature_attribute_metadata') THEN
		RAISE EXCEPTION '%.feature_attribute_metadata table not yet created. Please create it first', qi_usr_schema;
	END IF;

	IF parent_classname IS NOT NULL THEN
		result_text := concat(qi_cdb_schema,',', p_oc_id,'(', parent_classname,')', ',', oc_id, '(', classname,'),', LOWER(view_type), ',', layer_approach);
	ELSE
		result_text := concat(qi_cdb_schema,',', oc_id, '(', classname,'),', LOWER(view_type), ',', layer_approach);
	END IF;

	-- Loop through all existing feature geometries regarding the classess
	FOR r IN
		EXECUTE format('
		SELECT parent_objectclass_id AS p_oc_id, objectclass_id AS oc_id, geometry_name AS geom, lod AS lod
		FROM %I.feature_geometry_metadata AS fgm 
		WHERE fgm.cdb_schema = %L
			AND parent_objectclass_id = %L
			AND objectclass_id = %L
			AND fgm.geometry_name <> ''address'' 
			AND fgm.postgis_geom_type IS NOT NULL
		', qi_usr_schema, qi_cdb_schema, p_oc_id, oc_id)
	LOOP
		-- Count attributes for the current object class
		EXECUTE format('
		SELECT COUNT(*)
		FROM %I.feature_attribute_metadata AS fam 
		WHERE fam.cdb_schema = %L 
			AND fam.objectclass_id = %L;
		', qi_usr_schema, qi_cdb_schema, r.oc_id) INTO attri_count;

		-- If there are attributes, use approach 3 with all attributes
		IF attri_count > 0 THEN
			PERFORM qgis_pkg.create_layer(qi_usr_schema, qi_cdb_schema, r.p_oc_id, r.oc_id, r.geom, r.lod::integer, NULL, is_matview, TRUE, is_joins); -- approach 3 specification with attributes
		-- If no attributes exist, create layer with only the geometry
		ELSE
			PERFORM qgis_pkg.create_layer(qi_usr_schema, qi_cdb_schema, r.p_oc_id, r.oc_id, r.geom, r.lod::integer, NULL, is_matview, FALSE, is_joins); -- approach 3 specification without attributes
		END IF;
	END LOOP;

RETURN result_text;

EXCEPTION
	WHEN QUERY_CANCELED THEN
		RAISE EXCEPTION 'qgis_pkg.create_class_layers(): Error QUERY_CANCELED';
	WHEN OTHERS THEN 
		RAISE EXCEPTION 'qgis_pkg.create_class_layers(): %', SQLERRM;
END;
$$ LANGUAGE plpgsql;

COMMENT ON FUNCTION qgis_pkg.create_class_layers(varchar, varchar, integer, integer, boolean, boolean) IS 'Create all existing layers of the selected class in the cdb_schema with all existing attributes';
REVOKE EXECUTE ON FUNCTION qgis_pkg.create_class_layers(varchar, varchar, integer, integer, boolean, boolean) FROM public;
-- Example
-- SELECT * FROM qgis_pkg.create_class_layers('qgis_bstsai', 'alderaan', NULL, 901, FALSE); -- view (TABLE)
-- SELECT * FROM qgis_pkg.create_class_layers('qgis_bstsai', 'alderaan', 901, 709, FALSE); -- view (TABLE)
-- SELECT * FROM qgis_pkg.create_class_layers('qgis_bstsai', 'alderaan', NULL, 901); -- matview (TABLE)
-- SELECT * FROM qgis_pkg.create_class_layers('qgis_bstsai', 'alderaan', 901, 709); -- matview (TABLE)
-- SELECT * FROM qgis_pkg.create_class_layers('qgis_bstsai', 'alderaan',  NULL, 901, FALSE, TRUE); -- view (JOINS)
-- SELECT * FROM qgis_pkg.create_class_layers('qgis_bstsai', 'alderaan', 901, 709, FALSE, TRUE); -- view (JOINS)
-- SELECT * FROM qgis_pkg.create_class_layers('qgis_bstsai', 'alderaan',  NULL, 901, TRUE, TRUE); -- matview (JOINS)
-- SELECT * FROM qgis_pkg.create_class_layers('qgis_bstsai', 'alderaan', 901, 709, TRUE, TRUE); -- matview (JOINS)


----------------------------------------------------------------
-- Create FUNCTION QGIS_PKG.CREATE_ALL_LAYER
----------------------------------------------------------------
DROP FUNCTION IF EXISTS qgis_pkg.create_all_layer(varchar, varchar, boolean, boolean) CASCADE;
CREATE OR REPLACE FUNCTION qgis_pkg.create_all_layer(
	usr_schema varchar,
	cdb_schema varchar,
	is_matview boolean DEFAULT TRUE,
	is_joins boolean DEFAULT FALSE
)
RETURNS varchar
AS $$
DECLARE
	qi_usr_schema varchar	:= quote_ident(usr_schema);
	qi_cdb_schema varchar	:= quote_ident(cdb_schema);
	view_type varchar		:= (CASE WHEN is_matview THEN 'MATERIALIZED VIEW' ELSE 'VIEW' END);
	layer_approach varchar	:= (CASE WHEN is_joins THEN 'attribute joins' ELSE 'attribute table' END);
	attri_count integer;
	result_text text;
	r RECORD;
	
BEGIN
	-- Check if feature geometry metadata table exists
	IF NOT EXISTS(SELECT 1 FROM information_schema.tables WHERE table_schema = qi_usr_schema AND table_name = 'feature_geometry_metadata') THEN
		RAISE EXCEPTION '%.feature_geometry_metadata table not yet created. Please create it first', qi_usr_schema;
	END IF;

	-- Check if feature attribute metadata table exists
	IF NOT EXISTS(SELECT 1 FROM information_schema.tables WHERE table_schema = qi_usr_schema AND table_name = 'feature_attribute_metadata') THEN
		RAISE EXCEPTION '%.feature_attribute_metadata table not yet created. Please create it first', qi_usr_schema;
	END IF;

	result_text := concat(qi_cdb_schema,',', LOWER(view_type), ',', layer_approach);

	-- Loop through all existing feature geometries
	FOR r IN
		EXECUTE format('
		SELECT parent_objectclass_id AS p_oc_id, objectclass_id AS oc_id, geometry_name AS geom, lod AS lod
		FROM %I.feature_geometry_metadata AS fgm 
		WHERE fgm.cdb_schema = %L 
			AND fgm.geometry_name <> ''address'' 
			AND fgm.postgis_geom_type IS NOT NULL
		', qi_usr_schema, qi_cdb_schema)
	LOOP
		-- Count attributes for the current object class
		EXECUTE format('
		SELECT COUNT(*)
		FROM %I.feature_attribute_metadata AS fam 
		WHERE fam.cdb_schema = %L 
			AND fam.objectclass_id = %L;
		', qi_usr_schema, qi_cdb_schema, r.oc_id) INTO attri_count;

		-- If there are attributes, use approach 3 with all attributes
		IF attri_count > 0 THEN
			PERFORM qgis_pkg.create_layer(qi_usr_schema, qi_cdb_schema, r.p_oc_id, r.oc_id, r.geom, r.lod::integer, NULL, is_matview, TRUE, is_joins); -- approach 3 specification with attributes
		-- If no attributes exist, create layer with only the geometry
		ELSE
			PERFORM qgis_pkg.create_layer(qi_usr_schema, qi_cdb_schema, r.p_oc_id, r.oc_id, r.geom, r.lod::integer, NULL, is_matview, FALSE, is_joins); -- approach 3 specification without attributes
		END IF;
	END LOOP;

RETURN result_text;

EXCEPTION
	WHEN QUERY_CANCELED THEN
		RAISE EXCEPTION 'qgis_pkg.create_all_layer(): Error QUERY_CANCELED';
	WHEN OTHERS THEN 
		RAISE EXCEPTION 'qgis_pkg.create_all_layer(): %', SQLERRM;
END;
$$ LANGUAGE plpgsql;

COMMENT ON FUNCTION qgis_pkg.create_all_layer(varchar, varchar, boolean, boolean) IS 'Create all existing layers in the cdb_schema with all existing attributes';
REVOKE EXECUTE ON FUNCTION qgis_pkg.create_all_layer(varchar, varchar, boolean, boolean) FROM public;
-- Example
-- SELECT * FROM qgis_pkg.create_all_layer('qgis_bstsai', 'citydb'); -- matview (TABLE)
-- SELECT * FROM qgis_pkg.create_all_layer('qgis_bstsai', 'citydb', FALSE); -- view (TABLE)
-- SELECT * FROM qgis_pkg.create_all_layer('qgis_bstsai', 'citydb', TRUE, TRUE); -- matview (JOINS)
-- SELECT * FROM qgis_pkg.create_all_layer('qgis_bstsai', 'citydb', FALSE, TRUE); -- view (JOINS)
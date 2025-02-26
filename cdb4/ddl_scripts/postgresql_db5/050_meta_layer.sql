-- ***********************************************************************
--
-- This script installs a set of functions into qgis_pkg schema
-- List of functions:
--
-- qgis_pkg.generate_layer_name_attri_joins()
-- qgis_pkg.generate_layer_name_attri_table()
-- qgis_pkg.drop_single_layer_attri_joins()
-- qgis_pkg.drop_class_layers_attri_joins()
-- qgis_pkg.drop_single_layer_attri_table()
-- qgis_pkg.drop_class_layers_attri_table()
-- qgis_pkg.drop_all_layer()
--
-- ***********************************************************************


----------------------------------------------------------------
-- Create FUNCTION QGIS_PKG.GENERATE_LAYER_NAME_ATTRI_JOINS
----------------------------------------------------------------
DROP FUNCTION IF EXISTS qgis_pkg.generate_layer_name_attri_joins(varchar, varchar, integer, integer[], boolean, boolean) CASCADE;
CREATE OR REPLACE FUNCTION qgis_pkg.generate_layer_name_attri_joins(
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
	qi_usr_schema        varchar := quote_ident(usr_schema);
	qi_cdb_schema        varchar := quote_ident(cdb_schema);
	prefix               varchar := CASE WHEN is_matview THEN '=lmv' ELSE '=lv' END;
	inline_prefix        varchar := '_ia_{';
	nested_prefix        varchar := '_na_{';
	g_id                 integer := geometry_id;
	attri_address        varchar := '_no_attri_joins';
	p_oc_id       		 integer;
	oc_id       		 integer;
	parent_class_alias   varchar;
	class_alias          varchar;
	g_type               varchar;
	lod                  varchar;
	attri_id             integer;
	inline_attri_ids     integer[];
	nested_attri_ids     integer[];
	l_name               varchar;
	is_nested            boolean;
	r                    RECORD;

BEGIN
-- Check if schemas exist
IF NOT EXISTS (SELECT 1 FROM information_schema.schemata WHERE schema_name = qi_usr_schema) THEN
	RAISE EXCEPTION 'usr_schema (%) not found. Please create usr_schema first', qi_usr_schema;
END IF;
IF NOT EXISTS (SELECT 1 FROM information_schema.schemata WHERE schema_name = qi_cdb_schema) THEN
	RAISE EXCEPTION 'cdb_schema (%) not found. It must be an existing schema', qi_cdb_schema;
END IF;

-- Get geometry metadata
EXECUTE format('
    SELECT 
        fgm.parent_objectclass_id, fgm.objectclass_id, fgm.geometry_type, fgm.lod
    FROM %I.feature_geometry_metadata AS fgm
    WHERE fgm.id = %L', qi_usr_schema, g_id) INTO r;

IF r IS NULL THEN
	RAISE EXCEPTION 'Specified geometry ID % of % cannot be found in %.feature_geometry_metadata!', g_id, cdb_schema, usr_schema;
END IF;

p_oc_id := r.parent_objectclass_id;
oc_id := r.objectclass_id;
parent_class_alias := (CASE WHEN p_oc_id <> 0 THEN (SELECT qgis_pkg.objectclass_id_to_alias(p_oc_id)) ELSE NULL END);
class_alias := qgis_pkg.objectclass_id_to_alias(oc_id);
g_type := r.geometry_type;
lod := concat('lod', r.lod);

-- If all attributes are requested and not provided, retrieve them
IF is_all_attris AND attribute_ids IS NULL THEN
	inline_attri_ids := qgis_pkg.get_all_attribute_id_in_schema(qi_usr_schema, qi_cdb_schema, oc_id);
	nested_attri_ids := qgis_pkg.get_all_attribute_id_in_schema(qi_usr_schema, qi_cdb_schema, oc_id, TRUE);
	attribute_ids := ARRAY(SELECT unnest(inline_attri_ids || nested_attri_ids) ORDER BY 1);
END IF;

-- If attributes are provided, classify them
IF attribute_ids IS NOT NULL THEN
	FOR attri_id IN SELECT unnest(attribute_ids)
	LOOP
		EXECUTE format('SELECT is_nested FROM %I.feature_attribute_metadata WHERE id = %L', qi_usr_schema, attri_id) INTO is_nested;
		IF is_nested THEN
			nested_attri_ids := array_append(nested_attri_ids, attri_id);
		ELSE
			inline_attri_ids := array_append(inline_attri_ids, attri_id);
		END IF;
	END LOOP;
	
	-- Update attribute address based on classified attributes
	attri_address := CASE
		WHEN is_all_attris THEN '_all_attri_joins'
		ELSE
			concat(
				CASE WHEN array_length(inline_attri_ids, 1) > 0 THEN concat(inline_prefix, ARRAY_LENGTH(inline_attri_ids, 1), '}') ELSE '' END,
				CASE WHEN array_length(nested_attri_ids, 1) > 0 THEN concat(nested_prefix, ARRAY_LENGTH(nested_attri_ids, 1), '}') ELSE '' END
			)
	END;
END IF;

-- Construct the layer name
l_name := format('"%s_%s_%s_%s_%s%s"', 
	prefix, 
	qi_cdb_schema, 
	CASE WHEN parent_class_alias IS NOT NULL THEN concat(parent_class_alias, '_', class_alias) ELSE class_alias END,  
	lod, 
	g_type, 
	attri_address);

RETURN l_name;

EXCEPTION
	WHEN QUERY_CANCELED THEN
		RAISE EXCEPTION 'qgis_pkg.generate_layer_name_attri_joins(): Error QUERY_CANCELED';
	WHEN OTHERS THEN
		RAISE EXCEPTION 'qgis_pkg.generate_layer_name_attri_joins(): %', SQLERRM;
END;
$$ LANGUAGE plpgsql;
COMMENT ON FUNCTION qgis_pkg.generate_layer_name_attri_joins(varchar, varchar, integer, integer[], boolean, boolean) IS 'Generate layer name based on the selected geometry and attributes using approach 1 or 2';
REVOKE EXECUTE ON FUNCTION qgis_pkg.generate_layer_name_attri_joins(varchar, varchar, integer, integer[], boolean, boolean) FROM PUBLIC;
-- Example
-- SELECT * FROM qgis_pkg.generate_layer_name_attri_joins('qgis_bstsai', 'alderaan', 5, NULL, FALSE); -- view, 902-15, no_attris
-- SELECT * FROM qgis_pkg.generate_layer_name_attri_joins('qgis_bstsai', 'alderaan', 14, ARRAY[40,57], FALSE); -- view, 901, ['description','height']
-- SELECT * FROM qgis_pkg.generate_layer_name_attri_joins('qgis_bstsai', 'alderaan', 14, ARRAY[40,46,57], TRUE);  -- matview, 901, ['name','description','height']
-- SELECT * FROM qgis_pkg.generate_layer_name_attri_joins('qgis_bstsai', 'alderaan', 14, NULL, FALSE, TRUE); -- view, 901, all_attris
-- SELECT * FROM qgis_pkg.generate_layer_name_attri_joins('qgis_bstsai', 'alderaan', 14, NULL, TRUE, TRUE);  -- matview, 901, all_attris


----------------------------------------------------------------
-- Create FUNCTION QGIS_PKG.GENERATE_LAYER_NAME_ATTRI_TABLE
----------------------------------------------------------------
DROP FUNCTION IF EXISTS qgis_pkg.generate_layer_name_attri_table(varchar, varchar, integer, integer[], boolean, boolean) CASCADE;
CREATE OR REPLACE FUNCTION qgis_pkg.generate_layer_name_attri_table(
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
	qi_usr_schema		varchar := quote_ident(usr_schema);
	qi_cdb_schema 		varchar	:= quote_ident(cdb_schema);
	prefix 				varchar := (CASE WHEN is_matview THEN '=lmv' ELSE '=lv' END);
	attr_suffix 		varchar := (CASE WHEN attribute_ids IS NULL AND NOT is_all_attris THEN '_no_attri_table' ELSE '_attri_table' END);
	g_id 				integer := geometry_id;
	p_oc_id 			integer; 
	oc_id 				integer; 
	parent_classname 	varchar;
	classname 			varchar;
	parent_class_alias 	varchar; 
	class_alias 		varchar;
	g_type 				varchar;
	lod 				varchar;
	l_name 				varchar;
	r 					RECORD;

BEGIN
-- Check if usr_schema and cdb_schema exist
IF qi_usr_schema IS NULL OR NOT EXISTS (SELECT 1 FROM information_schema.schemata WHERE schema_name = qi_usr_schema) THEN
	RAISE EXCEPTION 'usr_schema (%) not found. Please create usr_schema first', qi_usr_schema;
END IF;
IF qi_cdb_schema IS NULL OR NOT EXISTS (SELECT 1 FROM information_schema.schemata WHERE schema_name = qi_cdb_schema) THEN
	RAISE EXCEPTION 'cdb_schema (%) not found. It must be an existing schema', qi_cdb_schema;
END IF;

-- Get geometry metadata
EXECUTE format('
    SELECT 
        fgm.bbox_type, fgm.parent_objectclass_id, fgm.objectclass_id, fgm.datatype_id, 
        fgm.geometry_name, fgm.lod, fgm.geometry_type, fgm.postgis_geom_type
    FROM %I.feature_geometry_metadata AS fgm
    WHERE fgm.id = %L', qi_usr_schema, g_id) INTO r;

IF r IS NULL THEN
	RAISE EXCEPTION 'Specified geometry ID % of % cannot be found in %.feature_geometry_metadata!', g_id, cdb_schema, usr_schema;
END IF;

-- Retrieve class and parent class information
p_oc_id := r.parent_objectclass_id;
oc_id := r.objectclass_id;
IF p_oc_id <> 0 THEN
	parent_classname := qgis_pkg.objectclass_id_to_classname(qi_cdb_schema, p_oc_id);
	parent_class_alias := qgis_pkg.objectclass_id_to_alias(p_oc_id);
END IF;
classname := qgis_pkg.objectclass_id_to_classname(qi_cdb_schema, oc_id);
class_alias := qgis_pkg.objectclass_id_to_alias(oc_id);
g_type := r.geometry_type;
lod := concat('lod', r.lod);

-- Generate the layer name
l_name := format('"%s_%s_%s_%s_%s%s"', 
	prefix, 
	qi_cdb_schema, 
	CASE WHEN parent_class_alias IS NOT NULL THEN concat(parent_class_alias, '_', class_alias) ELSE class_alias END,
	lod, 
	g_type, 
	attr_suffix);

RETURN l_name;

EXCEPTION
	WHEN QUERY_CANCELED THEN
		RAISE EXCEPTION 'qgis_pkg.generate_layer_name_attri_table(): Error QUERY_CANCELED';
 	WHEN OTHERS THEN
		RAISE EXCEPTION 'qgis_pkg.generate_layer_name_attri_table(): %', SQLERRM;
END;
$$ LANGUAGE plpgsql;
COMMENT ON FUNCTION qgis_pkg.generate_layer_name_attri_table(varchar, varchar, integer, integer[], boolean, boolean) IS 'Generate layer name based on the selected geometry and attributes using approach 3';
REVOKE EXECUTE ON FUNCTION qgis_pkg.generate_layer_name_attri_table(varchar, varchar, integer, integer[], boolean, boolean) FROM PUBLIC;
-- Example
-- SELECT * FROM qgis_pkg.generate_layer_name_attri_table('qgis_bstsai', 'alderaan', 14, NULL, FALSE, TRUE); -- view, all attris
-- SELECT * FROM qgis_pkg.generate_layer_name_attri_table('qgis_bstsai', 'alderaan', 14, NULL, TRUE, TRUE);  -- matview, all attris


----------------------------------------------------------------
-- Create FUNCTION QGIS_PKG.DROP_SINGLE_LAYER_ATTRI_JOINS
----------------------------------------------------------------
DROP FUNCTION IF EXISTS qgis_pkg.drop_single_layer_attri_joins(varchar, varchar, integer, integer, text, integer, text[], boolean, boolean, boolean) CASCADE;
CREATE OR REPLACE FUNCTION qgis_pkg.drop_single_layer_attri_joins(
	usr_schema varchar,
	cdb_schema varchar,
	parent_objectclass_id integer,
	objectclass_id integer,
	geometry_name text,
	lod integer,
	attris text[] DEFAULT NULL,
	is_matview boolean DEFAULT FALSE,
	is_all_attris boolean DEFAULT FALSE,
	is_drop_attris boolean DEFAULT FALSE
) 
RETURNS varchar 
AS $$
DECLARE
	qi_usr_schema	varchar := quote_ident(usr_schema);
	qi_cdb_schema 	varchar	:= quote_ident(cdb_schema);
	ql_cdb_schema 	varchar	:= quote_literal(cdb_schema);
	p_oc_id 		integer := (CASE WHEN parent_objectclass_id IS NULL THEN 0 ELSE parent_objectclass_id END); 
	oc_id 			integer := objectclass_id;
	geom			text	:= geometry_name;
	geom_id  		integer := qgis_pkg.get_geometry_key_id(qi_usr_schema, qi_cdb_schema, p_oc_id, oc_id, geom, lod);
	view_type		varchar	:= (CASE WHEN is_matview THEN 'MATERIALIZED VIEW' ELSE 'VIEW' END);
	attri 			text;
	attri_id 		integer;
	attri_ids 		integer[];
	l_name			varchar;
	sql_drop 		text;
	r				RECORD;
	found_record	boolean := FALSE; -- Flag to track if any records were found

BEGIN
-- Check if cdb_schema exists
IF qi_cdb_schema IS NULL or NOT EXISTS(SELECT 1 FROM information_schema.schemata AS i WHERE i.schema_name::varchar = qi_cdb_schema) THEN
	RAISE EXCEPTION 'cdb_schema (%) not found. It must be an existing schema', qi_cdb_schema;
END IF;

-- Prepare the Array of specified attributes
IF attris IS NOT NULL AND NOT is_all_attris THEN
	FOREACH attri IN ARRAY attris
	LOOP
		attri_id := qgis_pkg.get_attribute_key_id(qi_usr_schema, qi_cdb_schema, oc_id, attri);
		attri_ids := ARRAY_APPEND(attri_ids, attri_id);
	END LOOP;
END IF;

-- Generate the target layer name
SELECT qgis_pkg.generate_layer_name_attri_joins(qi_usr_schema, qi_cdb_schema, geom_id, attri_ids, is_matview, is_all_attris) INTO l_name;

FOR r IN
	EXECUTE format('
	SELECT layer_name, inline_attris, nested_attris
	FROM %I.layer_metadata AS l 
	WHERE l.cdb_schema = %L 
		AND l.parent_objectclass_id %s AND l.objectclass_id = %L AND l.layer_name = %L
		AND l.is_matview = %L AND l.is_joins IS TRUE;
	',qi_usr_schema, qi_cdb_schema, CASE WHEN p_oc_id <> 0 THEN concat('=',p_oc_id) ELSE 'IS NULL' END, oc_id, l_name, is_matview)
LOOP
	found_record := TRUE;
	sql_drop := concat('
	DROP ', view_type,' IF EXISTS ',qi_usr_schema,'.', r.layer_name,' CASCADE;
	DELETE FROM ',qi_usr_schema,'.layer_metadata AS l WHERE l.cdb_schema = ',ql_cdb_schema,' AND l.layer_name = ',quote_literal(r.layer_name),';
	WITH m AS (SELECT max(id) AS max_id FROM ',qi_usr_schema,'.layer_metadata)
	SELECT setval(''',qi_usr_schema,'.layer_metadata_id_seq''::regclass, m.max_id, TRUE) FROM m;
	');
	EXECUTE sql_drop;
	IF is_drop_attris THEN
		IF ARRAY_LENGTH(r.inline_attris, 1) > 0 THEN
			FOREACH attri IN ARRAY(r.inline_attris)
			LOOP
				PERFORM qgis_pkg.drop_attribute_view(qi_usr_schema, qi_cdb_schema, oc_id, attri, FALSE, is_matview);
			END LOOP;
		END IF;
		IF ARRAY_LENGTH(r.nested_attris, 1) > 0 THEN
			FOREACH attri IN ARRAY(r.nested_attris)
			LOOP
				PERFORM qgis_pkg.drop_attribute_view(qi_usr_schema, qi_cdb_schema, oc_id, attri, TRUE, is_matview);
			END LOOP;
		END IF;
	END IF;
END LOOP;

-- If no records were found, raise an exception
IF NOT found_record THEN
	RAISE EXCEPTION 'layers % not found in the %.layer_metadata', l_name, qi_usr_schema;
END IF;

RETURN concat(qi_usr_schema, '.', l_name);

EXCEPTION
	WHEN QUERY_CANCELED THEN
		RAISE EXCEPTION 'qgis_pkg.drop_single_layer_attri_joins(): Error QUERY_CANCELED';
 	WHEN OTHERS THEN
		RAISE EXCEPTION 'qgis_pkg.drop_single_layer_attri_joins(): %', SQLERRM;
END;
$$ LANGUAGE plpgsql;
COMMENT ON FUNCTION qgis_pkg.drop_single_layer_attri_joins(varchar, varchar, integer, integer, text, integer, text[], boolean, boolean, boolean) IS 'Drop individual layer generated using apporach 1 & 2 with the specified geometry and attributes from the cdb_schema. Selectable to cascade dropping the associated attribute (materialized) view(s)';
REVOKE EXECUTE ON FUNCTION qgis_pkg.drop_single_layer_attri_joins(varchar, varchar, integer, integer, text, integer, text[], boolean, boolean, boolean) FROM PUBLIC;
-- Example
-- SELECT * FROM qgis_pkg.create_layer('qgis_bstsai', 'alderaan', 0, 901, 'lod1Solid', 1, ARRAY['name','description','height'], TRUE, FALSE, TRUE); -- MATVIEW g+ selected a (JOIN)
-- SELECT * FROM qgis_pkg.drop_single_layer_attri_joins('qgis_bstsai', 'alderaan', NULL, 901, 'lod1Solid', 1, ARRAY['name','description','height'], TRUE, FALSE); -- only drop matview layer
-- SELECT * FROM qgis_pkg.drop_single_layer_attri_joins('qgis_bstsai', 'alderaan', NULL, 901, 'lod1Solid', 1, ARRAY['name','description','height'], TRUE, FALSE, TRUE); -- drop matview layer & attribute views
-- SELECT * FROM qgis_pkg.create_layer('qgis_bstsai', 'alderaan', 0, 901, 'lod1Solid', 1, NULL, TRUE, TRUE, TRUE); -- MATVIEW g+ ALL a (JOIN)
-- SELECT * FROM qgis_pkg.drop_single_layer_attri_joins('qgis_bstsai', 'alderaan', NULL, 901, 'lod1Solid', 1, NULL, TRUE, TRUE, TRUE); -- drop matview layer & attribute views


----------------------------------------------------------------
-- Create FUNCTION QGIS_PKG.DROP_CLASS_LAYERS_ATTRI_JOINS
----------------------------------------------------------------
-- Batch dropping layers generated using approach 1 & 2 based on objectclass_id from specified schema. Selectable to cascade dropping the associated attribute (materialized) view(s)
DROP FUNCTION IF EXISTS qgis_pkg.drop_class_layers_attri_joins(varchar, varchar, integer, integer, boolean, boolean) CASCADE;
CREATE OR REPLACE FUNCTION qgis_pkg.drop_class_layers_attri_joins(
	usr_schema varchar,
	cdb_schema varchar,
	parent_objectclass_id integer,
	objectclass_id integer,
	is_matview boolean DEFAULT TRUE,
	is_drop_attris boolean DEFAULT TRUE
) 
RETURNS varchar 
AS $$
DECLARE
	qi_usr_schema		varchar := quote_ident(usr_schema);
	qi_cdb_schema 		varchar	:= quote_ident(cdb_schema);
	ql_cdb_schema 		varchar	:= quote_literal(cdb_schema);
	p_oc_id 			integer := parent_objectclass_id;
	parent_classname	varchar := (CASE WHEN p_oc_id IS NOT NULL THEN (SELECT qgis_pkg.objectclass_id_to_classname(qi_cdb_schema, p_oc_id)) ELSE NULL END);
	oc_id 				integer := objectclass_id;
	class_name			varchar := (SELECT qgis_pkg.objectclass_id_to_classname(qi_cdb_schema, oc_id));
	view_type			varchar	:= (CASE WHEN is_matview THEN 'MATERIALIZED VIEW' ELSE 'VIEW' END);
	attri_suffix		varchar := (CASE WHEN is_drop_attris THEN ',drop cascade to attributes' ELSE NULL END);
	l_names				varchar[];
	l_name				varchar;
	inline_attris		varchar[];
	nested_attris		varchar[];
	selected_attri 		varchar;
	aview_name			varchar;
	sql_drop 			text;
	sql_del				text;
	sql_statement		text;
	result_text 		text;
	r 					RECORD;
	found_record		boolean := FALSE; -- Flag to track if any records were found

BEGIN
-- Check if cdb_schema exists
IF qi_cdb_schema IS NULL or NOT EXISTS(SELECT 1 FROM information_schema.schemata AS i WHERE i.schema_name::varchar = qi_cdb_schema) THEN
	RAISE EXCEPTION 'cdb_schema (%) not found. It must be an existing schema', qi_cdb_schema;
END IF;

IF parent_classname IS NOT NULL THEN
	result_text := concat(qi_cdb_schema,',', p_oc_id,'(', parent_classname,')', ',', oc_id, '(', class_name,'),', LOWER(view_type), attri_suffix);
ELSE
	result_text := concat(qi_cdb_schema,',', oc_id, '(', class_name,'),', LOWER(view_type), attri_suffix);
END IF;

-- Get all existing layer names based on the target classes from the target cdb_schema
FOR r IN 
	EXECUTE format('
	SELECT layer_name, inline_attris, nested_attris
	FROM %I.layer_metadata AS l 
	WHERE l.cdb_schema = %L 
		AND l.parent_objectclass_id %s AND l.objectclass_id = %L
		AND l.is_matview = %L AND l.is_joins IS TRUE;
	', qi_usr_schema, qi_cdb_schema, CASE WHEN p_oc_id IS NOT NULL THEN concat('=',p_oc_id) ELSE 'IS NULL' END, oc_id, is_matview)
LOOP
	found_record := TRUE; -- Set the flag to TRUE if the loop runs, indicating a record was found
	
	sql_drop	:= concat('DROP ', view_type,' IF EXISTS ', qi_usr_schema,'.', r.layer_name, ' CASCADE;');
	sql_del 	:= concat('
	DELETE FROM ',qi_usr_schema,'.layer_metadata AS l WHERE l.cdb_schema = ',ql_cdb_schema,' AND l.layer_name = ',quote_literal(r.layer_name),';
	WITH m AS (SELECT max(id) AS max_id FROM ',qi_usr_schema,'.layer_metadata)
	SELECT setval(''',qi_usr_schema,'.layer_metadata_id_seq''::regclass, m.max_id, TRUE) FROM m;
	');
	sql_statement := concat(sql_drop, sql_del);
	EXECUTE sql_statement;
	-- drop also the associated attribute views
	IF is_drop_attris THEN
		IF ARRAY_LENGTH(r.inline_attris, 1) > 0 THEN
			FOREACH selected_attri IN ARRAY(r.inline_attris)
			LOOP
				PERFORM qgis_pkg.drop_attribute_view(qi_usr_schema, qi_cdb_schema, oc_id, selected_attri, FALSE, is_matview);
			END LOOP;
		END IF;
		IF ARRAY_LENGTH(r.nested_attris, 1) > 0 THEN
			FOREACH selected_attri IN ARRAY(r.nested_attris)
			LOOP
				PERFORM qgis_pkg.drop_attribute_view(qi_usr_schema, qi_cdb_schema, oc_id, selected_attri, TRUE, is_matview);
			END LOOP;
		END IF;
	END IF;
END LOOP;

-- If no records were found, raise an exception
IF NOT found_record THEN
	RAISE EXCEPTION 'No layers found for the given conditions: %', result_text;
END IF;

RETURN result_text;

EXCEPTION
	WHEN QUERY_CANCELED THEN
		RAISE EXCEPTION 'qgis_pkg.drop_class_layers_attri_joins(): Error QUERY_CANCELED';
 	WHEN OTHERS THEN
		RAISE EXCEPTION 'qgis_pkg.drop_class_layers_attri_joins(): %', SQLERRM;
END;
$$ LANGUAGE plpgsql;
COMMENT ON FUNCTION qgis_pkg.drop_class_layers_attri_joins(varchar, varchar, integer, integer, boolean, boolean) IS 'Batch dropping layers generated using approach 1 & 2 based on objectclass_id from a specified schema. Selectable to cascade dropping the associated attribute (materialized) view(s)';
REVOKE EXECUTE ON FUNCTION qgis_pkg.drop_class_layers_attri_joins(varchar, varchar, integer, integer, boolean, boolean) FROM PUBLIC;
--Example
-- VIEW
-- SELECT * FROM qgis_pkg.create_class_layers('qgis_bstsai', 'alderaan', NULL, 901, FALSE, TRUE); -- view (JOIN)
-- SELECT * FROM qgis_pkg.drop_class_layers_attri_joins('qgis_bstsai', 'alderaan', NULL, 901, FALSE, TRUE); -- drop layer view and associated attribute views
-- SELECT * FROM qgis_pkg.drop_class_layers_attri_joins('qgis_bstsai', 'alderaan', NULL, 901, FALSE, FALSE); -- only drop layer view

-- MATVIEW
-- SELECT * FROM qgis_pkg.create_class_layers('qgis_bstsai', 'alderaan', 901, 709, TRUE, TRUE); -- matview (JOIN)
-- SELECT * FROM qgis_pkg.drop_class_layers_attri_joins('qgis_bstsai', 'alderaan', 901, 709); -- drop layer matview and associated attribute matviews
-- SELECT * FROM qgis_pkg.drop_class_layers_attri_joins('qgis_bstsai', 'alderaan', NULL, 901, TRUE, FALSE); -- only drop layer matview


----------------------------------------------------------------
-- Create FUNCTION QGIS_PKG.DROP_SINGLE_LAYER_ATTRI_TABLE
----------------------------------------------------------------
DROP FUNCTION IF EXISTS qgis_pkg.drop_single_layer_attri_table(varchar, varchar, integer, integer, text, integer, text[], boolean, boolean, boolean) CASCADE;
CREATE OR REPLACE FUNCTION qgis_pkg.drop_single_layer_attri_table(
	usr_schema varchar,
	cdb_schema varchar,
	parent_objectclass_id integer,
	objectclass_id integer,
	geometry_name text,
	lod integer,
	attris text[] DEFAULT NULL,
	is_matview boolean DEFAULT FALSE,
	is_all_attris boolean DEFAULT FALSE,
	is_drop_attris boolean DEFAULT FALSE
) 
RETURNS varchar 
AS $$
DECLARE
	qi_usr_schema	varchar := quote_ident(usr_schema);
	qi_cdb_schema 	varchar	:= quote_ident(cdb_schema);
	ql_cdb_schema 	varchar	:= quote_literal(cdb_schema);
	p_oc_id 		integer := (CASE WHEN parent_objectclass_id IS NULL THEN 0 ELSE parent_objectclass_id END); 
	oc_id 			integer := objectclass_id;
	geom			text	:= geometry_name;
	geom_id  		integer := qgis_pkg.get_geometry_key_id(qi_usr_schema, qi_cdb_schema, p_oc_id, oc_id, geom, lod);
	view_type		varchar	:= (CASE WHEN is_matview THEN 'MATERIALIZED VIEW' ELSE 'VIEW' END);
	attri 			text;
	attri_id 		integer;
	attri_ids 		integer[];
	l_name			varchar;
	sql_drop 		text;
	r				RECORD;
	found_record	boolean := FALSE; -- Flag to track if any records were found

BEGIN
-- Check if cdb_schema exists
IF qi_cdb_schema IS NULL or NOT EXISTS(SELECT 1 FROM information_schema.schemata AS i WHERE i.schema_name::varchar = qi_cdb_schema) THEN
	RAISE EXCEPTION 'cdb_schema (%) not found. It must be an existing schema', qi_cdb_schema;
END IF;

-- Prepare the Array of specified attributes
IF attris IS NOT NULL AND NOT is_all_attris THEN
	FOREACH attri IN ARRAY attris
	LOOP
		attri_id := qgis_pkg.get_attribute_key_id(qi_usr_schema, qi_cdb_schema, oc_id, attri);
		attri_ids := ARRAY_APPEND(attri_ids, attri_id);
	END LOOP;
END IF;

-- Generate the target layer name
SELECT qgis_pkg.generate_layer_name_attri_table(qi_usr_schema, qi_cdb_schema, geom_id, attri_ids, is_matview, is_all_attris) INTO l_name;

FOR r IN
	EXECUTE format('
	SELECT layer_name, av_table_name
	FROM %I.layer_metadata AS l 
	WHERE l.cdb_schema = %L 
		AND l.parent_objectclass_id %s AND l.objectclass_id = %L AND l.layer_name = %L
		AND l.is_matview = %L AND l.is_joins IS FALSE;
	',qi_usr_schema, qi_cdb_schema, CASE WHEN p_oc_id <> 0 THEN concat('=',p_oc_id) ELSE 'IS NULL' END, oc_id, l_name, is_matview)
LOOP
	found_record := TRUE;
	sql_drop := concat('
	DROP ', view_type,' IF EXISTS ',qi_usr_schema,'.', r.layer_name,' CASCADE;
	DELETE FROM ',qi_usr_schema,'.layer_metadata AS l WHERE l.cdb_schema = ',ql_cdb_schema,' AND l.layer_name = ',quote_literal(r.layer_name),';
	WITH m AS (SELECT max(id) AS max_id FROM ',qi_usr_schema,'.layer_metadata)
	SELECT setval(''',qi_usr_schema,'.layer_metadata_id_seq''::regclass, m.max_id, TRUE) FROM m;
	');
	EXECUTE sql_drop;
	IF is_drop_attris THEN
		sql_drop := concat('DROP ', view_type,' IF EXISTS ', qi_usr_schema,'.', r.av_table_name, ' CASCADE;');
		EXECUTE sql_drop;
	END IF;
END LOOP;

-- If no records were found, raise an exception
IF NOT found_record THEN
	RAISE EXCEPTION 'layers % not found in the %.layer_metadata', l_name, qi_usr_schema;
END IF;

RETURN concat(qi_usr_schema, '.', l_name);

EXCEPTION
	WHEN QUERY_CANCELED THEN
		RAISE EXCEPTION 'qgis_pkg.drop_single_layer_attri_table(): Error QUERY_CANCELED';
 	WHEN OTHERS THEN
		RAISE EXCEPTION 'qgis_pkg.drop_single_layer_attri_table(): %', SQLERRM;
END;
$$ LANGUAGE plpgsql;
COMMENT ON FUNCTION qgis_pkg.drop_single_layer_attri_table(varchar, varchar, integer, integer, text, integer, text[], boolean, boolean, boolean) IS 'Drop individual layer generated using apporach 3 with the specified geometry and attributes from the cdb_schema. Selectable to cascade dropping the associated integrated attribute table (materialized) view';
REVOKE EXECUTE ON FUNCTION qgis_pkg.drop_single_layer_attri_table(varchar, varchar, integer, integer, text, integer, text[], boolean, boolean, boolean) FROM PUBLIC;
-- Example
-- VIEW
-- SELECT * FROM qgis_pkg.create_layer('qgis_bstsai', 'alderaan', 0, 901, 'lod1Solid', 1, NULL, FALSE, TRUE); -- VIEW g+ ALL a (TABLE)
-- SELECT * FROM qgis_pkg.drop_single_layer_attri_table('qgis_bstsai', 'alderaan', NULL, 901, 'lod1Solid', 1, NULL, FALSE, TRUE, TRUE); -- drop view layer & integrated attribute view
-- MATVIEW
-- SELECT * FROM qgis_pkg.create_layer('qgis_bstsai', 'alderaan', 0, 901, 'lod1Solid', 1, ARRAY['name','description','height'], TRUE, FALSE); -- MATVIEW g+ selected a (TABLE)
-- SELECT * FROM qgis_pkg.drop_single_layer_attri_table('qgis_bstsai', 'alderaan', NULL, 901, 'lod1Solid', 1, ARRAY['name','description','height'], TRUE, FALSE, TRUE); -- drop view layer & integrated attribute matview


----------------------------------------------------------------
-- Create FUNCTION QGIS_PKG.DROP_CLASS_LAYERS_ATTRI_TABLE
----------------------------------------------------------------
-- Batch dropping layers generated using approach 3 based on objectclass_id from specified schema. Selectable to cascade dropping the associated integrated attribute table (materialized) view(s)
DROP FUNCTION IF EXISTS qgis_pkg.drop_class_layers_attri_table(varchar, varchar, integer, integer, boolean, boolean) CASCADE;
CREATE OR REPLACE FUNCTION qgis_pkg.drop_class_layers_attri_table(
	usr_schema varchar,
	cdb_schema varchar,
	parent_objectclass_id integer,
	objectclass_id integer,
	is_matview boolean DEFAULT TRUE,
	is_drop_attris boolean DEFAULT TRUE
) 
RETURNS varchar 
AS $$
DECLARE
	qi_usr_schema		varchar := quote_ident(usr_schema);
	qi_cdb_schema 		varchar	:= quote_ident(cdb_schema);
	ql_cdb_schema 		varchar	:= quote_literal(cdb_schema);
	p_oc_id 			integer := parent_objectclass_id;
	parent_classname	varchar := (CASE WHEN p_oc_id IS NOT NULL THEN (SELECT qgis_pkg.objectclass_id_to_classname(qi_cdb_schema, p_oc_id)) ELSE NULL END);
	oc_id 				integer := objectclass_id;
	classname			varchar := (SELECT qgis_pkg.objectclass_id_to_classname(qi_cdb_schema, oc_id));
	view_type			varchar	:= (CASE WHEN is_matview THEN 'MATERIALIZED VIEW' ELSE 'VIEW' END);
	attri_suffix		varchar := (CASE WHEN is_drop_attris THEN ',drop cascade to attributes' ELSE NULL END);
	l_names				varchar[];
	l_name				varchar;
	inline_attris		varchar[];
	nested_attris		varchar[];
	selected_attri 		varchar;
	aview_name			varchar;
	sql_drop 			text;
	sql_del				text;
	sql_statement		text;
	result_text 		text;
	r 					RECORD;
	found_record		boolean := FALSE; -- Flag to track if any records were found

BEGIN
-- Check if cdb_schema exists
IF qi_cdb_schema IS NULL or NOT EXISTS(SELECT 1 FROM information_schema.schemata AS i WHERE i.schema_name::varchar = qi_cdb_schema) THEN
	RAISE EXCEPTION 'cdb_schema (%) not found. It must be an existing schema', qi_cdb_schema;
END IF;

IF parent_classname IS NOT NULL THEN
	result_text := concat(qi_cdb_schema,',', p_oc_id,'(', parent_classname,')', ',', oc_id, '(', classname,'),', LOWER(view_type), attri_suffix);
ELSE
	result_text := concat(qi_cdb_schema,',', oc_id, '(', classname,'),', LOWER(view_type), attri_suffix);
END IF;

-- Get all existing layer names based on the target classes from the target cdb_schema
FOR r IN 
	EXECUTE format('
	SELECT layer_name, av_table_name
	FROM %I.layer_metadata AS l 
	WHERE l.cdb_schema = %L 
		AND l.parent_objectclass_id %s AND l.objectclass_id = %L
		AND l.is_matview = %L AND l.is_joins IS FALSE;
	', qi_usr_schema, qi_cdb_schema, CASE WHEN p_oc_id IS NOT NULL THEN concat('=',p_oc_id) ELSE 'IS NULL' END, oc_id, is_matview)
LOOP
	found_record := TRUE; -- Set the flag to TRUE if the loop runs, indicating a record was found
	
	-- Drop the layer and associated attribute views
	sql_drop	:= concat('DROP ', view_type,' IF EXISTS ', qi_usr_schema,'.', r.layer_name, ' CASCADE;');
	sql_del 	:= concat('
	DELETE FROM ',qi_usr_schema,'.layer_metadata AS l WHERE l.cdb_schema = ',ql_cdb_schema,' AND l.layer_name = ',quote_literal(r.layer_name),';
	WITH m AS (SELECT max(id) AS max_id FROM ',qi_usr_schema,'.layer_metadata)
	SELECT setval(''',qi_usr_schema,'.layer_metadata_id_seq''::regclass, m.max_id, TRUE) FROM m;
	');
	sql_statement := concat(sql_drop, sql_del);
	EXECUTE sql_statement;
	
	-- Drop associated attribute views if required
	IF is_drop_attris THEN
		sql_drop := concat('DROP ', view_type,' IF EXISTS ', qi_usr_schema,'.', r.av_table_name, ' CASCADE;');
		EXECUTE sql_drop;
	END IF;
END LOOP;

-- If no records were found, raise an exception
IF NOT found_record THEN
	RAISE EXCEPTION 'No layers found for the given conditions: %', result_text;
END IF;

RETURN result_text;

EXCEPTION
	WHEN QUERY_CANCELED THEN
		RAISE EXCEPTION 'qgis_pkg.drop_class_layers_attri_table(): Error QUERY_CANCELED';
 	WHEN OTHERS THEN
		RAISE EXCEPTION 'qgis_pkg.drop_class_layers_attri_table(): %', SQLERRM;
END;
$$ LANGUAGE plpgsql;
COMMENT ON FUNCTION qgis_pkg.drop_class_layers_attri_table(varchar, varchar, integer, integer, boolean, boolean) IS 'Batch dropping layers generated using approach 3 based on objectclass_id from specified schema. Selectable to cascade dropping the associated integrated attribute table (materialized) view(s)';
REVOKE EXECUTE ON FUNCTION qgis_pkg.drop_class_layers_attri_table(varchar, varchar, integer, integer, boolean, boolean) FROM PUBLIC;
--Example
-- VIEW
-- SELECT * FROM qgis_pkg.create_class_layers('qgis_bstsai', 'alderaan', NULL, 901); -- matview (TABLE)
-- SELECT * FROM qgis_pkg.drop_class_layers_attri_table('qgis_bstsai', 'alderaan', NULL, 901) -- drop layer matview & integrated attri table matview 
-- SELECT * FROM qgis_pkg.drop_class_layers_attri_table('qgis_bstsai', 'alderaan', NULL, 901, FALSE) -- only drop layer matview
-- MATVIEW
-- SELECT * FROM qgis_pkg.create_class_layers('qgis_bstsai', 'alderaan', NULL, 901, FALSE); -- view (TABLE)
-- SELECT * FROM qgis_pkg.drop_class_layers_attri_table('qgis_bstsai', 'alderaan', NULL, 901, FALSE) -- drop layer view & integrated attri table view
-- SELECT * FROM qgis_pkg.drop_class_layers_attri_table('qgis_bstsai', 'alderaan', NULL, 901, FALSE, FALSE) -- only drop layer view


----------------------------------------------------------------
-- Create FUNCTION QGIS_PKG.DROP_ALL_LAYER
----------------------------------------------------------------
DROP FUNCTION IF EXISTS qgis_pkg.drop_all_layer(varchar, varchar, boolean, boolean, boolean) CASCADE;
CREATE OR REPLACE FUNCTION qgis_pkg.drop_all_layer(
	usr_schema varchar,
	cdb_schema varchar,
	is_matview boolean DEFAULT TRUE,
	is_drop_attris boolean DEFAULT TRUE,
	is_joins boolean DEFAULT FALSE
)
RETURNS varchar
AS $$
DECLARE
	qi_usr_schema varchar	:= quote_ident(usr_schema);
	qi_cdb_schema varchar	:= quote_ident(cdb_schema);
	view_type varchar		:= (CASE WHEN is_matview THEN 'MATERIALIZED VIEW' ELSE 'VIEW' END);
	layer_approach varchar	:= (CASE WHEN is_joins THEN 'attribute joins' ELSE 'attribute table' END);
	result_text text;
	r RECORD;
	
BEGIN
	-- Check if layer metadata table exists
	IF NOT EXISTS(SELECT 1 FROM information_schema.tables WHERE table_schema = qi_usr_schema AND table_name = 'layer_metadata') THEN
		RAISE EXCEPTION '%.layer_metadata table not yet created. Please create it first', qi_usr_schema;
	END IF;

	result_text := concat(qi_cdb_schema,',', LOWER(view_type), ',', layer_approach);
	
	-- Loop through all available feature geometries
	FOR r IN
		EXECUTE format('
		SELECT DISTINCT parent_objectclass_id AS p_oc_id, objectclass_id AS oc_id
		FROM %I.layer_metadata AS l
		WHERE l.cdb_schema = %L AND l.is_matview = %L
		', qi_usr_schema, qi_cdb_schema, is_matview)
	LOOP
		-- For layers generated using apporach 1 & 2 -> Multiple joins of attribute (materialized) views
		IF is_joins THEN
			PERFORM qgis_pkg.drop_class_layers_attri_joins(qi_usr_schema, qi_cdb_schema, r.p_oc_id, r.oc_id, is_matview, is_drop_attris);
		-- For layers generated using apporach 3 -> Single join of integrated attribute (materialized) view
		ELSE
			PERFORM qgis_pkg.drop_class_layers_attri_table(qi_usr_schema, qi_cdb_schema, r.p_oc_id, r.oc_id, is_matview, is_drop_attris);
		END IF;
	END LOOP;

RETURN result_text;

EXCEPTION
	WHEN QUERY_CANCELED THEN
		RAISE EXCEPTION 'qgis_pkg.drop_all_layer(): Error QUERY_CANCELED';
	WHEN OTHERS THEN 
		RAISE EXCEPTION 'qgis_pkg.drop_all_layer(): %', SQLERRM;
END;
$$ LANGUAGE plpgsql;

COMMENT ON FUNCTION qgis_pkg.drop_all_layer(varchar, varchar, boolean, boolean, boolean) IS 'Drop all existing layers from the cdb_schema with all existing attributes';
REVOKE EXECUTE ON FUNCTION qgis_pkg.drop_all_layer(varchar, varchar, boolean, boolean, boolean) FROM public;
-- Example
-- SELECT * FROM qgis_pkg.create_all_layer('qgis_bstsai', 'alderaan');
-- SELECT * FROM qgis_pkg.drop_all_layer('qgis_bstsai', 'alderaan', FALSE); -- drop layers & associated integrated attribute view (TABLE)
-- SELECT * FROM qgis_pkg.drop_all_layer('qgis_bstsai', 'alderaan'); -- drop layers & associated integrated attribute matview (TABLE)
-- SELECT * FROM qgis_pkg.drop_all_layer('qgis_bstsai', 'alderaan', FALSE, FALSE); -- only drop layers view (TABLE)
-- SELECT * FROM qgis_pkg.drop_all_layer('qgis_bstsai', 'alderaan', TRUE, FALSE); -- only drop layers matview (TABLE)
-- SELECT * FROM qgis_pkg.drop_all_layer('qgis_bstsai', 'alderaan', FALSE, TRUE, TRUE); -- drop layers & associated integrated attribute view (JOINS)
-- SELECT * FROM qgis_pkg.drop_all_layer('qgis_bstsai', 'alderaan', TRUE, TRUE, TRUE); -- drop layers & associated integrated attribute matview (JOINS)
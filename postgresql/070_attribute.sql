-- ***********************************************************************
--
-- This script installs a set of functions into qgis_pkg schema
-- List of functions:
--
-- qgis_pkg.attribute_name_to_datatype_id()
-- qgis_pkg.attribute_value_column_check()
-- qgis_pkg.attribute_value_column_type()
-- qgis_pkg.attribute_multiplicity_count()
-- qgis_pkg.create_compostie_type_name()
-- qgis_pkg.create_compostie_type_header()
-- qgis_pkg.collect_inline_single_attribute()
-- qgis_pkg.collect_inline_multiple_attribute()
-- qgis_pkg.collect_inline_attribute()
-- qgis_pkg.collect_nested_single_attribute()
-- qgis_pkg.collect_nested_multiple_attribute()
-- qgis_pkg.collect_nested_attribute()
-- qgis_pkg.get_view_column_name()
-- qgis_pkg.get_view_column_type()
-- qgis_pkg.get_attribute_key_id()
-- qgis_pkg.attribute_key_id_to_name()
-- qgis_pkg.generate_sql_attribute_matview_footer()
-- qgis_pkg.create_attribute_view()
-- qgis_pkg.create_all_attribute_view_in_schema()
-- qgis_pkg.drop_attribute_view()
-- qgis_pkg.drop_all_attribute_views()
--
-- ***********************************************************************

----------------------------------------------------------------
-- Create FUNCTION QGIS_PKG.ATTRIBUTE_NAME_TO_DATATYPE_ID()
----------------------------------------------------------------
/* Query the datatype_id of the given attribute name from the property table */
DROP FUNCTION IF EXISTS qgis_pkg.attribute_name_to_datatype_id(varchar, integer, text, boolean);
CREATE OR REPLACE FUNCTION qgis_pkg.attribute_name_to_datatype_id(
	cdb_schema varchar,
	objectclass_id integer,
	attribute_name text,
	is_nested boolean DEFAULT FALSE
) RETURNS integer AS $$
DECLARE
	nested_attri_ids text;
	qi_cdb_schema varchar := quote_ident(cdb_schema);
	sql_attri_datatype_id text;
	attri_datatype_id integer;
BEGIN
-- Get the nested attribute datatype_ids
EXECUTE format('SELECT STRING_AGG(adl.id::TEXT, %L) FROM qgis_pkg.attribute_datatype_lookup AS adl WHERE adl.alias NOT IN (%L,%L,%L) AND adl.is_nested = 1',',','dyn','grp','vers') INTO nested_attri_ids;
IF is_nested THEN
	sql_attri_datatype_id := concat('
		SELECT p.datatype_id 
		FROM ',qi_cdb_schema,'.property AS p 
			INNER JOIN ',qi_cdb_schema,'.feature AS f ON (f.id = p.feature_id 
						AND f.objectclass_id = ',objectclass_id,' 
						AND p.datatype_id IN (',nested_attri_ids,'))
		WHERE p.name = ',quote_literal(attribute_name),' 
		LIMIT 1;
	');
ELSE
	sql_attri_datatype_id := concat('
	SELECT p.datatype_id 
	FROM ',qi_cdb_schema,'.property AS p 
		INNER JOIN ',qi_cdb_schema,'.feature AS f ON (f.id = p.feature_id 
					AND f.objectclass_id = ',objectclass_id,' 
					AND p.datatype_id NOT IN (',nested_attri_ids,'))
	WHERE p.name = ',quote_literal(attribute_name),' 
	LIMIT 1;
	');
END IF;
EXECUTE sql_attri_datatype_id INTO attri_datatype_id;
RETURN attri_datatype_id;

EXCEPTION
	WHEN QUERY_CANCELED THEN
		RAISE EXCEPTION 'qgis_pkg.attribute_name_to_datatype_id(): Error QUERY_CANCELED';
	WHEN OTHERS THEN 
		RAISE EXCEPTION 'qgis_pkg.attribute_name_to_datatype_id(): %', SQLERRM;
END;
$$ LANGUAGE plpgsql;
COMMENT ON FUNCTION qgis_pkg.attribute_name_to_datatype_id(varchar, integer, text, boolean) IS 'Lookup the datatype_id of the given attribute name in property table';
REVOKE EXECUTE ON FUNCTION qgis_pkg.attribute_name_to_datatype_id(varchar, integer, text, boolean) FROM public;
-- Example
-- SELECT * FROM qgis_pkg.attribute_name_to_datatype_id('citydb', 901,'class');
-- SELECT * FROM qgis_pkg.attribute_name_to_datatype_id('citydb', 901,'height', TRUE);
-- SELECT * FROM qgis_pkg.attribute_name_to_datatype_id('citydb', 15,'relatedTo'); -- inline attribute name: relatedTo
-- SELECT * FROM qgis_pkg.attribute_name_to_datatype_id('citydb', 15,'relatedTo','TRUE'); -- nested attribute name: relatedTo
-- SELECT * FROM qgis_pkg.attribute_name_to_datatype_id('citydb', 1301,'height');



----------------------------------------------------------------
-- Create FUNCTION QGIS_PKG.ATTRIBUTE_VALUE_COLUMN_CHECK()
----------------------------------------------------------------
-- For the given attribute name, first check its datatype and then perform a value existence check 
-- in all the value columns based on datatype to gather target value column(s) as an array
DROP FUNCTION IF EXISTS qgis_pkg.attribute_value_column_check(varchar, integer, text, boolean);
CREATE OR REPLACE FUNCTION qgis_pkg.attribute_value_column_check(
	cdb_schema varchar,
	objectclass_id integer,
	attribute_name text,
	is_nested boolean DEFAULT FALSE
) RETURNS text[] AS $$
DECLARE
	nested_attri_ids integer[] := (SELECT ARRAY_AGG(adl.id) FROM qgis_pkg.attribute_datatype_lookup AS adl WHERE adl.alias NOT IN ('dyn','grp','vers') AND adl.is_nested = 1);
	qi_cdb_schema varchar := quote_ident(cdb_schema);
	attri_datatype_id integer;
	attri_val_col_array text[]; -- possible val_cols of the attribute datatype
	attri_val_col text;
	attri_val_cols text[]; -- stored the value columns that have values
	sql_col_val_check text;
	val_exist boolean;
BEGIN
-- Get the datatype of the attribute name
-- is_nested variable can be false since nested attribute does not have any values, thus no need to check
EXECUTE format('SELECT * FROM qgis_pkg.attribute_name_to_datatype_id(%L,%s,%L,%L)', qi_cdb_schema, objectclass_id, attribute_name, is_nested) INTO attri_datatype_id;

IF attri_datatype_id = ANY(nested_attri_ids) THEN
	RAISE NOTICE 'Attribute (%) of objectclass id (%) is nested, the values are stored in its child attributes value columns', attribute_name, objectclass_id;
ELSE
-- Get the value columns of the datatype as an array
EXECUTE format('SELECT val_col FROM qgis_pkg.attribute_datatype_lookup AS adl WHERE adl.id = %s', attri_datatype_id) INTO attri_val_col_array;
	-- Check value existence of each val_col for all non nested attributes
	IF attri_val_col_array IS NOT NULL THEN
		FOREACH attri_val_col IN ARRAY attri_val_col_array LOOP
			sql_col_val_check := concat('
				SELECT EXISTS 
					(SELECT 1
					FROM ',qi_cdb_schema,'.feature AS f
						INNER JOIN ',qi_cdb_schema,'.property AS p ON f.id = p.feature_id AND f.objectclass_id = ',objectclass_id,'
					WHERE p.name = ',quote_literal(attribute_name),' AND p.',attri_val_col,' IS NOT NULL
					LIMIT 1);
			');
			EXECUTE sql_col_val_check INTO val_exist;
			IF (val_exist) THEN
				attri_val_cols := ARRAY_APPEND(attri_val_cols, attri_val_col);
			END IF;
			val_exist := NULL;
		END LOOP;
	END IF;
END IF;
	
RETURN attri_val_cols;

EXCEPTION
	WHEN QUERY_CANCELED THEN
		RAISE EXCEPTION 'qgis_pkg.attribute_value_column_check(): Error QUERY_CANCELED';
	WHEN OTHERS THEN 
		RAISE EXCEPTION 'qgis_pkg.attribute_value_column_check(): %', SQLERRM;
END;
$$ LANGUAGE plpgsql;
COMMENT ON FUNCTION qgis_pkg.attribute_value_column_check(varchar, integer, text, boolean) IS 'Check value column(s) of the given objectclass_id and attribute name';
REVOKE EXECUTE ON FUNCTION qgis_pkg.attribute_value_column_check(varchar, integer, text, boolean) FROM public;
-- Example
-- SELECT * FROM qgis_pkg.attribute_value_column_check('citydb', 901, 'function');
-- SELECT * FROM qgis_pkg.attribute_value_column_check('citydb', 901, '土砂災害警戒区域');
-- SELECT * FROM qgis_pkg.attribute_value_column_check('citydb', 901, '区域区分'); -- nested-child attribute "土砂災害警戒区域"
-- SELECT * FROM qgis_pkg.attribute_value_column_check('citydb', 901, 'height', TRUE);
-- SELECT * FROM qgis_pkg.attribute_value_column_check('rh_v5', 712, 'direction'); -- Roof Surface- direction mapped to string value
-- SELECT * FROM qgis_pkg.attribute_value_column_check('rh_v5', 709, 'direction'); -- Wall Surface- direction mapped to double value, which is wrong and it won't be shown in DB
-- SELECT * FROM qgis_pkg.attribute_value_column_check('citydb', 15, 'relatedTo', TRUE); -- nested attribute "relatedTo"
-- SELECT * FROM qgis_pkg.attribute_value_column_check('citydb', 15, 'relatedTo'); -- nested-child attribute "relatedTo"
-- SELECT * FROM qgis_pkg.attribute_value_column_check('citydb', 1301, 'height');
-- SELECT * FROM qgis_pkg.attribute_value_column_check('vienna_v5', 901, 'Blattnummer');
-- SELECT * FROM qgis_pkg.attribute_value_column_check('rh_v5', 901, 'storeysAboveGround')


----------------------------------------------------------------
-- Create FUNCTION QGIS_PKG.ATTRIBUTE_VALUE_TYPE()
----------------------------------------------------------------
DROP FUNCTION IF EXISTS qgis_pkg.attribute_value_column_type(varchar, text);
CREATE OR REPLACE FUNCTION qgis_pkg.attribute_value_column_type(
	cdb_schema varchar,
	col_name text
) RETURNS text AS $$
DECLARE
	qi_cdb_schema varchar := quote_ident(cdb_schema);
	sql_val_col_type text;
	val_col_type text;
BEGIN

EXECUTE format('SELECT pg_typeof(%s) FROM %I.property LIMIT 1', col_name, qi_cdb_schema) INTO val_col_type;
RETURN val_col_type;

EXCEPTION
	WHEN QUERY_CANCELED THEN
		RAISE EXCEPTION 'qgis_pkg.attribute_value_column_type(): Error QUERY_CANCELED';
	WHEN OTHERS THEN 
		RAISE EXCEPTION 'qgis_pkg.attribute_value_column_type(): %', SQLERRM;
END;
$$ LANGUAGE plpgsql;
COMMENT ON FUNCTION qgis_pkg.attribute_value_column_type(varchar, text) IS 'Lookup the attribute value column type';
REVOKE EXECUTE ON FUNCTION qgis_pkg.attribute_value_column_type(varchar, text) FROM public;
-- Example
-- SELECT * FROM qgis_pkg.attribute_value_column_type('citydb', 'val_array');


----------------------------------------------------------------
-- Create FUNCTION QGIS_PKG.ATTRIBUTE_MULTIPLICITY_COUNT()
----------------------------------------------------------------
DROP FUNCTION IF EXISTS qgis_pkg.attribute_multiplicity_count(varchar, varchar, integer, text, varchar);
CREATE OR REPLACE FUNCTION qgis_pkg.attribute_multiplicity_count(
	usr_schema varchar,
	cdb_schema varchar,
	objectclass_id integer,
	attribute_name text,
	cdb_bbox_type varchar DEFAULT 'db_schema'
) RETURNS bigint AS $$
DECLARE
	qi_usr_schema varchar := quote_ident(usr_schema);
	qi_cdb_schema varchar := quote_ident(cdb_schema);
	cdb_bbox_type_array CONSTANT varchar[] 	:= ARRAY['db_schema', 'm_view', 'qgis'];
	cdb_envelope geometry;
	srid integer;
	sql_where text;
	sql_max_attri_count text;
	max_attribute_multiplicity bigint;
BEGIN
-- Get the srid
EXECUTE format('SELECT srid FROM %I.database_srs LIMIT 1', qi_cdb_schema) INTO srid;
	
-- Check that the cdb_box_type is a valid value and get the envelope
IF cdb_bbox_type IS NULL OR NOT (cdb_bbox_type = ANY (cdb_bbox_type_array)) THEN
	RAISE EXCEPTION 'cdb_bbox_type value is invalid. It must be one of (%)', cdb_bbox_type_array;
ELSE
	EXECUTE format('SELECT envelope FROM %I.extents WHERE cdb_schema = %L AND bbox_type = %L', qi_usr_schema, qi_cdb_schema, cdb_bbox_type) INTO cdb_envelope;
END IF;

-- Check that the srid is the same to cdb_envelope
IF ST_SRID(cdb_envelope) IS NULL OR ST_SRID(cdb_envelope) <> srid OR cdb_bbox_type = 'db_schema' THEN
	sql_where := NULL;
ELSE
	sql_where := concat(' AND ST_MakeEnvelope(',ST_XMin(cdb_envelope),',',ST_YMin(cdb_envelope),',',ST_XMax(cdb_envelope),',',ST_YMax(cdb_envelope),',',srid,') && f.envelope ');
END IF;

sql_max_attri_count := concat('
SELECT MAX(count_p_name) AS max_count
FROM (
    SELECT f.id, f.objectclass_id, COUNT(p.name) AS count_p_name
    FROM ',qi_cdb_schema,'.property AS p
		INNER JOIN ',qi_cdb_schema,'.feature AS f ON (f.id = p.feature_id AND f.objectclass_id = ',objectclass_id,' AND p.parent_id IS NULL ',sql_where,'
	)
WHERE p.name = ',quote_literal(attribute_name),'
GROUP BY f.id) AS count_attri;
');

EXECUTE sql_max_attri_count INTO max_attribute_multiplicity;
RETURN max_attribute_multiplicity;

EXCEPTION
	WHEN QUERY_CANCELED THEN
		RAISE EXCEPTION 'qgis_pkg.list_cdb_schemas(): Error QUERY_CANCELED';
	WHEN OTHERS THEN 
		RAISE EXCEPTION 'qgis_pkg.list_cdb_schemas(): %', SQLERRM;
END;
$$ LANGUAGE plpgsql;
COMMENT ON FUNCTION qgis_pkg.attribute_multiplicity_count(varchar, varchar, integer, text, varchar) IS 'Reture the maximum multiplicity count of the given feature attribute in the extent';
REVOKE EXECUTE ON FUNCTION qgis_pkg.attribute_multiplicity_count(varchar, varchar,integer, text, varchar) FROM public;
-- Example
-- SELECT * FROM qgis_pkg.attribute_multiplicity_count('qgis_bstsai', 'citydb', 901, 'name'); -- alderaan data: multiple names for f_id = 10 (bldg)
-- SELECT * FROM qgis_pkg.attribute_multiplicity_count('qgis_bstsai', 'alderaan_v5', 901, 'name'); -- alderaan data: multiple names for f_id = 10 (bldg)
-- SELECT * FROM qgis_pkg.attribute_multiplicity_count('qgis_bstsai', 'citydb', 15, 'relatedTo'); 
-- SELECT * FROM qgis_pkg.attribute_multiplicity_count('qgis_bstsai', 'citydb', 901, 'height'); 


----------------------------------------------------------------
-- Create FUNCTION QGIS_PKG.CREATE_COMPOSITE_TYPE_NAME()
----------------------------------------------------------------
-- Create the composite type header for the crosstab function, and the ct_type name as an array
DROP FUNCTION IF EXISTS qgis_pkg.create_compostie_type_name(varchar, integer, text);
CREATE OR REPLACE FUNCTION qgis_pkg.create_compostie_type_name(
	cdb_schema varchar,
	objectclass_id integer,
	attribute_name text
) RETURNS varchar AS $$
DECLARE
	qi_cdb_schema varchar := quote_ident(cdb_schema);
	ct_name varchar;
BEGIN
-- Create name of the new composite type
ct_name := concat('"',qi_cdb_schema, '_', objectclass_id, '_', attribute_name,'_ct"');

RETURN ct_name;

EXCEPTION
	WHEN QUERY_CANCELED THEN
		RAISE EXCEPTION 'qgis_pkg.create_compostie_type_name(): Error QUERY_CANCELED';
	WHEN OTHERS THEN 
		RAISE EXCEPTION 'qgis_pkg.create_compostie_type_name(): %', SQLERRM;
END;
$$ LANGUAGE plpgsql;
COMMENT ON FUNCTION qgis_pkg.create_compostie_type_name(varchar, integer, text) IS 'Create the composite type name for the crosstab function';
REVOKE EXECUTE ON FUNCTION qgis_pkg.create_compostie_type_name(varchar, integer, text) FROM public;
-- Example
-- SELECT * FROM qgis_pkg.create_compostie_type_name('citydb', 901, 'BuildingPart'); -- ct type name


----------------------------------------------------------------
-- Create FUNCTION QGIS_PKG.CREATE_COMPOSITE_TYPE_HEADER()
----------------------------------------------------------------
-- Create the composite type header for the crosstab function
DROP FUNCTION IF EXISTS qgis_pkg.create_compostie_type_header(varchar, varchar, text[]);
CREATE OR REPLACE FUNCTION qgis_pkg.create_compostie_type_header(
	cdb_schema varchar,
	ct_type_name varchar,
	attri_val_cols text[]
) 
RETURNS text AS $$
DECLARE
	qi_cdb_schema varchar := quote_ident(cdb_schema);
	ct_name varchar;
	attri_val_col text;
	attri_val_col_type text;
	sql_ct_type text;
BEGIN	
sql_ct_type := concat('
DROP TYPE IF EXISTS ',ct_type_name,'; 
CREATE TYPE ',ct_type_name,' AS (');
	
FOREACH attri_val_col IN ARRAY attri_val_cols
LOOP
	EXECUTE format('SELECT * FROM qgis_pkg.attribute_value_column_type(%L, %L);', qi_cdb_schema, attri_val_col) INTO attri_val_col_type;
	sql_ct_type := concat(sql_ct_type, attri_val_col, ' ', attri_val_col_type, ',');
END LOOP;
	
sql_ct_type := concat(LEFT(sql_ct_type, LENGTH(sql_ct_type) - 1), ');'); -- remove the last comma and close the type definition
-- RAISE NOTICE '%', sql_ct_type;

RETURN sql_ct_type;

EXCEPTION
	WHEN QUERY_CANCELED THEN
		RAISE EXCEPTION 'qgis_pkg.create_compostie_type_header(): Error QUERY_CANCELED';
	WHEN OTHERS THEN 
		RAISE EXCEPTION 'qgis_pkg.create_compostie_type_header(): %', SQLERRM;
END;
$$ LANGUAGE plpgsql;
COMMENT ON FUNCTION qgis_pkg.create_compostie_type_header(varchar, varchar, text[]) IS 'Create the composite type header for the crosstab function';
REVOKE EXECUTE ON FUNCTION qgis_pkg.create_compostie_type_header(varchar, varchar, text[]) FROM public;
-- Example
-- SELECT * FROM qgis_pkg.create_compostie_type_header('citydb', '"citydb_901_BuildingPart_ct"', ARRAY['val_string', 'val_codespace']);


----------------------------------------------------------------
-- Create FUNCTION QGIS_PKG.COLLECT_INLINE_SINGLE_ATTRIBUTE()
----------------------------------------------------------------
DROP FUNCTION IF EXISTS qgis_pkg.collect_inline_single_attribute(varchar, varchar, integer, text, varchar) CASCADE;
CREATE OR REPLACE FUNCTION qgis_pkg.collect_inline_single_attribute(
	usr_schema varchar,
	cdb_schema varchar,
	objectclass_id integer,
	attribute_name text,
	cdb_bbox_type varchar DEFAULT 'db_schema'
)
RETURNS text AS $$
DECLARE
	qi_usr_schema varchar:= quote_ident(usr_schema);
	qi_cdb_schema varchar:= quote_ident(cdb_schema);
	qi_oc_id integer := objectclass_id;
	qi_attri_name text:= attribute_name;
	cdb_bbox_type_array CONSTANT varchar[]:= ARRAY['db_schema', 'm_view', 'qgis'];
	cdb_envelope geometry;
	attri_val_cols text[]; attri_val_col text;
	additional_col_name text;
	val_col_count integer:= 1; -- 1-based index of array in postgresql
	qi_is_multiple_val_cols boolean DEFAULT FALSE;
	qi_n_val_cols integer;
	srid integer;
	sql_where text;
	sql_header text;
	sql_attri text;
	rec record;
BEGIN
-- Get the srid
EXECUTE format('SELECT srid FROM %I.database_srs LIMIT 1', qi_cdb_schema) INTO srid;
	
-- Check that the cdb_box_type is a valid value and get the envelope
IF cdb_bbox_type IS NULL OR NOT (cdb_bbox_type = ANY (cdb_bbox_type_array)) THEN
	RAISE EXCEPTION 'cdb_bbox_type value is invalid. It must be one of (%)', cdb_bbox_type_array;
ELSE
	EXECUTE format('SELECT envelope FROM %I.extents WHERE cdb_schema = %L AND bbox_type = %L', qi_usr_schema, qi_cdb_schema, cdb_bbox_type) INTO cdb_envelope;
END IF;

-- Check that the srid is the same to cdb_envelope
IF ST_SRID(cdb_envelope) IS NULL OR ST_SRID(cdb_envelope) <> srid OR cdb_bbox_type = 'db_schema' THEN
	sql_where := NULL;
ELSE
	sql_where := concat(' AND ST_MakeEnvelope(',ST_XMin(cdb_envelope),',',ST_YMin(cdb_envelope),',',ST_XMax(cdb_envelope),',',ST_YMax(cdb_envelope),',',srid,') && f.envelope ');
END IF;

-- Get the existing attribute value columns
EXECUTE format('SELECT * FROM qgis_pkg.attribute_value_column_check(%L,%L,%L)', qi_cdb_schema, objectclass_id, attribute_name) INTO attri_val_cols;
qi_n_val_cols := ARRAY_LENGTH(attri_val_cols, 1);

-- Multiple value columns
IF qi_n_val_cols > 1 THEN
	qi_is_multiple_val_cols := TRUE;
END IF;

-- Dynamically add the attribute value column(s)
sql_attri := 'SELECT 
	f.id AS f_id,';
IF attri_val_cols IS NOT NULL THEN
	FOREACH attri_val_col IN ARRAY attri_val_cols
	LOOP
		IF val_col_count = 1 THEN
			sql_attri := concat(sql_attri,'
				p.',attri_val_col,' AS "',attribute_name,'",');
		ELSE
			IF attri_val_col = 'val_uom' THEN
			sql_attri := concat(sql_attri,'
				p.',attri_val_col,' AS "',attribute_name,'_', 'UoM', '",');
			ELSE 
			sql_attri := concat(sql_attri,'
				p.',attri_val_col,' AS "',attribute_name,'_',SUBSTRING(attri_val_col FROM 'val_(.*)'),'",'); -- INITCAP
			END IF;
		END IF;
		val_col_count := val_col_count + 1;
	END LOOP;
	sql_attri := concat(LEFT(sql_attri, LENGTH(sql_attri) - 1),'
	FROM ',qi_cdb_schema,'.feature AS f
		INNER JOIN ',qi_cdb_schema,'.property AS p ON (f.id = p.feature_id AND f.objectclass_id = ',objectclass_id,' AND p.name = ',quote_literal(attribute_name),'',sql_where,')');
	-- Update the is_multiple_value_columns, n_value_columns, value_columns
	EXECUTE format('
	UPDATE %I.feature_attribute_metadata AS fam
	SET 
		is_multiple_value_columns = %L, 
		n_value_columns = %L,
		value_column = %L, 
		last_modification_date = clock_timestamp()
	WHERE fam.cdb_schema = %L
		AND fam.objectclass_id = %L
		AND fam.attribute_name = %L;
	', 
	qi_usr_schema, qi_is_multiple_val_cols, qi_n_val_cols, attri_val_cols,
	qi_cdb_schema, qi_oc_id, qi_attri_name);
ELSE
	sql_attri := NULL;
END IF;
	
RETURN sql_attri;

EXCEPTION
	WHEN QUERY_CANCELED THEN
		RAISE EXCEPTION 'qgis_pkg.collect_inline_single_attribute(): Error QUERY_CANCELED';
	WHEN OTHERS THEN 
		RAISE EXCEPTION 'qgis_pkg.collect_inline_single_attribute(): %', SQLERRM;
END;	
$$ LANGUAGE plpgsql;
COMMENT ON FUNCTION qgis_pkg.collect_inline_single_attribute(varchar, varchar, integer, text, varchar) IS 'Collect values of the "inline-single" attribute type';
REVOKE EXECUTE ON FUNCTION qgis_pkg.collect_inline_single_attribute(varchar, varchar, integer, text, varchar) FROM public;
--Example
-- SELECT * FROM qgis_pkg.collect_inline_single_attribute('qgis_bstsai','citydb',901,'description'); -- 1 value column
-- SELECT * FROM qgis_pkg.collect_inline_single_attribute('qgis_bstsai','citydb',901,'description'); -- 1 value column
-- SELECT * FROM qgis_pkg.collect_inline_single_attribute('qgis_bstsai','citydb',901,'function'); -- 1 value column
-- SELECT * FROM qgis_pkg.collect_inline_single_attribute('qgis_bstsai','citydb',901,'roofType'); -- 2 value column
-- SELECT * FROM qgis_pkg.collect_inline_single_attribute('qgis_bstsai','citydb',901,'lod2_volume'); -- 2 value columns
-- SELECT * FROM qgis_pkg.collect_inline_single_attribute('qgis_bstsai','rh_v5', 901, 'storeysAboveGround');
-- SELECT * FROM qgis_pkg.collect_inline_single_attribute('qgis_bstsai','rh_v5', 709, 'direction', 'm_view'); -- no value for wall_surf direction because of wrong tags
-- SELECT * FROM qgis_pkg.collect_inline_single_attribute('qgis_bstsai','rh_v5', 709, 'direction');


----------------------------------------------------------------
-- Create FUNCTION QGIS_PKG.COLLECT_INLINE_MULTIPLE_ATTRIBUTE()
----------------------------------------------------------------
DROP FUNCTION IF EXISTS qgis_pkg.collect_inline_multiple_attribute(varchar, varchar, integer, text, integer, varchar) CASCADE;
CREATE OR REPLACE FUNCTION qgis_pkg.collect_inline_multiple_attribute(
	usr_schema varchar,
	cdb_schema varchar,
	objectclass_id integer,
	attribute_name text,
	max_multiplicity integer,
	cdb_bbox_type varchar DEFAULT 'db_schema'
)
RETURNS text AS $$
DECLARE
	qi_usr_schema varchar:= quote_ident(usr_schema);
	qi_cdb_schema varchar:= quote_ident(cdb_schema);
	qi_oc_id integer := objectclass_id;
	qi_attri_name text:= attribute_name;
	attri_val_cols text[]; attri_val_col text;
	attri_val_cols_type_array text[][]; attri_val_col_type text;
	cdb_bbox_type_array CONSTANT varchar[] := ARRAY['db_schema', 'm_view', 'qgis'];
	cdb_envelope geometry;
	iter_count bigint := 1;
	val_col_count int := 1;
	qi_is_multiple_val_cols boolean DEFAULT FALSE;
	qi_n_val_cols integer;
	qi_ct_type_name varchar;
	srid integer;
	sql_where text;
	sql_ct_type_def text;
	sql_ctb_header text; sql_ctb_val_col text;
	sql_attri text;
	rec record;
BEGIN
-- Get the srid
EXECUTE format('SELECT srid FROM %I.database_srs LIMIT 1', qi_cdb_schema) INTO srid;
	
-- Check that the cdb_box_type is a valid value and get the envelope
IF cdb_bbox_type IS NULL OR NOT (cdb_bbox_type = ANY (cdb_bbox_type_array)) THEN
	RAISE EXCEPTION 'cdb_bbox_type value is invalid. It must be one of (%)', cdb_bbox_type_array;
ELSE
	EXECUTE format('SELECT envelope FROM %I.extents WHERE cdb_schema = %L AND bbox_type = %L', qi_usr_schema, qi_cdb_schema, cdb_bbox_type) INTO cdb_envelope;
END IF;

-- Check that the srid is the same to cdb_envelope
IF ST_SRID(cdb_envelope) IS NULL OR ST_SRID(cdb_envelope) <> srid OR cdb_bbox_type = 'db_schema' THEN
	sql_where := NULL;
ELSE
	sql_where := concat(' AND ST_MakeEnvelope(',ST_XMin(cdb_envelope),',',ST_YMin(cdb_envelope),',',ST_XMax(cdb_envelope),',',ST_YMax(cdb_envelope),',',srid,') && f.envelope ');
END IF;

-- Get the existing attribute value columns
EXECUTE format('SELECT * FROM qgis_pkg.attribute_value_column_check(%L,%L,%L)', qi_cdb_schema, objectclass_id, attribute_name) INTO attri_val_cols;
qi_n_val_cols := ARRAY_LENGTH(attri_val_cols, 1);

sql_attri := concat('
SELECT 
	f_id AS f_id,');
-- Generate the crosstab sql and its column header based on the the number of value column and its attribute multiplicity
-- Multiple value columns
IF qi_n_val_cols > 1 THEN
	qi_is_multiple_val_cols := TRUE;
	-- create the composite type for the crosstab function
	EXECUTE format ('SELECT * FROM qgis_pkg.create_compostie_type_name(%L,%s,%L)', qi_cdb_schema, objectclass_id, attribute_name) INTO qi_ct_type_name;
	EXECUTE format ('SELECT * FROM qgis_pkg.create_compostie_type_header(%L,%L,%L)', qi_cdb_schema, qi_ct_type_name, attri_val_cols) INTO sql_ct_type_def;
	-- select clause generation
	WHILE iter_count <= max_multiplicity
	LOOP
		FOREACH attri_val_col IN ARRAY attri_val_cols
		LOOP
			-- only the first val_col will be named as the attribute name
			IF val_col_count = 1 THEN 
				sql_attri := concat(sql_attri,'
					(',attribute_name,'_', iter_count::text,').',attri_val_col,' AS "',attribute_name,'_',iter_count::text,'",');
			-- the rest val_cols will be named without the 'val_' prefix, like column 'val_codespace' will be renamed as 'codespace'
			ELSE
				IF attri_val_col = 'val_uom' THEN
				sql_attri := concat(sql_attri,'
					(',attribute_name,'_', iter_count::text,').',attri_val_col,' AS "',attribute_name,'_UoM', '_', iter_count::text, '",');
				ELSE 
				sql_attri := concat(sql_attri,'
					(',attribute_name,'_', iter_count::text,').',attri_val_col,' AS "',attribute_name, '_', SUBSTRING(attri_val_col FROM 'val_(.*)'),'_', iter_count::text, '",'); -- INITCAP
				END IF;
			END IF;
			val_col_count := val_col_count + 1; 
		END LOOP;
		iter_count = iter_count + 1;
		val_col_count := 1;
	END LOOP;

	-- select clause in crosstab body to get target attribute value columns
	FOREACH attri_val_col IN ARRAY attri_val_cols
	LOOP
		sql_ctb_val_col := concat(sql_ctb_val_col,'p.',attri_val_col,',');
	END LOOP;
	sql_ctb_val_col := concat('(',LEFT(sql_ctb_val_col, LENGTH(sql_ctb_val_col) - 1),')::',qi_ct_type_name);

	-- Generate crosstab columns header with attribute name and composite type(qi_ct_type_name)
	iter_count := 1;
	sql_ctb_header := '(f_id bigint, ';
	WHILE iter_count <= max_multiplicity
	LOOP
		sql_ctb_header := concat(sql_ctb_header,'',attribute_name,'_', iter_count::text, ' ', qi_ct_type_name,',');
		iter_count = iter_count + 1;
	END LOOP;
	sql_ctb_header := LEFT(sql_ctb_header, LENGTH(sql_ctb_header) - 1);
	
	sql_attri = concat(sql_ct_type_def, LEFT(sql_attri, LENGTH(sql_attri) - 1), '
	FROM CROSSTAB(
		$BODY$
		SELECT 
			f.id AS f_id, 
			p.name,
			',sql_ctb_val_col,'
		FROM ',qi_cdb_schema,'.feature AS f
			INNER JOIN ',qi_cdb_schema,'.property AS p ON (f.id = p.feature_id AND f.objectclass_id = ',objectclass_id,'',sql_where,')
		WHERE p.name = ',quote_literal(attribute_name),'
		ORDER BY f_id, p.id ASC 
		$BODY$)
		AS ct',sql_ctb_header,')');

-- One value columns	
ELSE
	EXECUTE format('SELECT * FROM qgis_pkg.attribute_value_column_type(%L,%L)', qi_cdb_schema, attri_val_cols[1]) INTO attri_val_col_type;
	-- Loop to add additional columns based on max_multiplicity
	sql_ctb_header := '(f_id bigint, ';
	WHILE iter_count <= max_multiplicity 
	LOOP
		-- Concatenate additional column names with increasing numbers
	sql_attri := concat(sql_attri, '
		ct.',attribute_name,'_', iter_count::text,' AS ', attribute_name,'_',iter_count::text,',');
			sql_ctb_header := concat(sql_ctb_header,'"',attribute_name,'_', iter_count::text,'" ', attri_val_col_type,',');
			iter_count = iter_count + 1;
		END LOOP;
		sql_ctb_header = LEFT(sql_ctb_header, LENGTH(sql_ctb_header) - 1);	-- Remove the end comma
	
	sql_attri := concat(LEFT(sql_attri, LENGTH(sql_attri) - 1),'
	FROM CROSSTAB(
		$BODY$
		SELECT 
			f.id AS f_id, 
			p.name,
			',attri_val_cols[1],'
		FROM ',qi_cdb_schema,'.feature AS f
			INNER JOIN ',qi_cdb_schema,'.property AS p ON (f.id = p.feature_id AND f.objectclass_id = ',objectclass_id,'',sql_where,')
		WHERE p.name = ',quote_literal(attribute_name),'
		ORDER BY f_id, p.id ASC 
		$BODY$)
		AS ct' ,sql_ctb_header,')');
END IF;

-- Update the is_multiple_value_columns, n_value_columns, value_columns and ct_type_name if there are multiple val_cols
EXECUTE format('
UPDATE %I.feature_attribute_metadata AS fam
SET 
	is_multiple_value_columns = %L, 
	ct_type_name = %L,
	n_value_columns = %L,
	value_column = %L, 
	last_modification_date = clock_timestamp()
WHERE fam.cdb_schema = %L 
	AND fam.objectclass_id = %L 
	AND fam.attribute_name = %L;
', 
qi_usr_schema, qi_is_multiple_val_cols, qi_ct_type_name, qi_n_val_cols, 
attri_val_cols, qi_cdb_schema, qi_oc_id, qi_attri_name);

RETURN sql_attri;
	
EXCEPTION
	WHEN QUERY_CANCELED THEN
		RAISE EXCEPTION 'qgis_pkg.collect_inline_multiple_attribute(): Error QUERY_CANCELED';
	WHEN OTHERS THEN 
		RAISE EXCEPTION 'qgis_pkg.collect_inline_multiple_attribute(): %', SQLERRM;
END;	
$$ LANGUAGE plpgsql;
COMMENT ON FUNCTION qgis_pkg.collect_inline_multiple_attribute(varchar, varchar, integer, text, integer, varchar) IS 'Collect values of the "inline-multiple" attribute type';
REVOKE EXECUTE ON FUNCTION qgis_pkg.collect_inline_multiple_attribute(varchar, varchar, integer, text, integer, varchar) FROM public;
-- Example
-- SELECT * FROM qgis_pkg.collect_inline_multiple_attribute('qgis_bstsai', 'citydb', 901, 'name', 3);
-- SELECT * FROM qgis_pkg.collect_inline_multiple_attribute('qgis_bstsai', 'citydb', 901, 'function', 3);
-- SELECT * FROM qgis_pkg.collect_inline_multiple_attribute('qgis_bstsai','rh_v5',901,'function', 5, 'm_view');
-- SELECT * FROM qgis_pkg.collect_inline_multiple_attribute('qgis_bstsai','rh_v5',901,'function', 6);


----------------------------------------------------------------
-- Create FUNCTION QGIS_PKG.COLLECT_INLINE_ATTRIBUTE()
----------------------------------------------------------------
-- The function first check the maximum multiplicity of the "inline" attribute and
-- 1. if maximum multiplicity > 1 then call function qgis_pkg.collect_inline_multiple_attribute
-- 2. else call function qgis_pkg.collect_inline_single_attribute
DROP FUNCTION IF EXISTS qgis_pkg.collect_inline_attribute(varchar, varchar, integer, text, varchar);
CREATE OR REPLACE FUNCTION qgis_pkg.collect_inline_attribute(
    usr_schema varchar,
	cdb_schema varchar,
    objectclass_id integer,
	attribute_name text,
    cdb_bbox_type varchar DEFAULT 'db_schema'
) RETURNS text AS $$
DECLARE
    qi_usr_schema varchar := quote_ident(usr_schema);
	qi_cdb_schema varchar := quote_ident(cdb_schema);
    cdb_bbox_type_array CONSTANT varchar[] := ARRAY['db_schema', 'm_view', 'qgis'];
	qi_oc_id integer := objectclass_id;
	qi_attri_name text:= attribute_name;
	qi_is_multiple boolean DEFAULT FALSE;
    qi_max_multiplicity integer;
    srid integer;
	sql_attri text;
	sql_insert_header text;
    sql_insert_value text;
    sql_nested_attri text;
BEGIN
-- Get the srid
EXECUTE format('SELECT srid FROM %I.database_srs LIMIT 1', qi_cdb_schema) INTO srid;
	
-- Check that the cdb_box_type is a valid value
IF cdb_bbox_type IS NULL OR NOT (cdb_bbox_type = ANY (cdb_bbox_type_array)) THEN
	RAISE EXCEPTION 'cdb_bbox_type value is invalid. It must be one of (%)', cdb_bbox_type_array;
END IF;

-- Get the maximum multiplicity number of the given feature attribute
EXECUTE format('SELECT * FROM qgis_pkg.attribute_multiplicity_count(%L, %L, %L, %L, %L);', qi_usr_schema, qi_cdb_schema, objectclass_id, attribute_name, cdb_bbox_type) INTO qi_max_multiplicity;
IF qi_max_multiplicity > 1 THEN 
    qi_is_multiple := TRUE;
	EXECUTE format('SELECT qgis_pkg.collect_inline_multiple_attribute(%L, %L, %s, %L, %s, %L);', qi_usr_schema, qi_cdb_schema, objectclass_id, attribute_name, qi_max_multiplicity, cdb_bbox_type) INTO sql_attri;
ELSE
	EXECUTE format('SELECT qgis_pkg.collect_inline_single_attribute(%L, %L, %s, %L, %L);', qi_usr_schema, qi_cdb_schema, objectclass_id, attribute_name, cdb_bbox_type) INTO sql_attri;
END IF;

-- Update the is_multiple and maximum multiplicity column
EXECUTE format('
UPDATE %I.feature_attribute_metadata AS fam
SET 
	is_multiple = %L, 
	max_multiplicity = %L, 
	last_modification_date = clock_timestamp()
WHERE fam.cdb_schema = %L 
	AND fam.objectclass_id = %L 
	AND fam.attribute_name = %L;
', 
qi_usr_schema, qi_is_multiple, qi_max_multiplicity, 
qi_cdb_schema, qi_oc_id, qi_attri_name);

RETURN sql_attri;

EXCEPTION
	WHEN QUERY_CANCELED THEN
		RAISE EXCEPTION 'qgis_pkg.collect_inline_attribute(): Error QUERY_CANCELED';
	WHEN OTHERS THEN 
		RAISE EXCEPTION 'qgis_pkg.collect_inline_attribute(): %', SQLERRM;
END;
$$ LANGUAGE plpgsql;
COMMENT ON FUNCTION qgis_pkg.collect_inline_attribute(varchar, varchar, integer, text, varchar) IS 'Collect the "inline" attribute value in specific cdb_schema';
REVOKE EXECUTE ON FUNCTION qgis_pkg.collect_inline_attribute(varchar, varchar, integer, text, varchar) FROM public;
--Example
-- SELECT * FROM qgis_pkg.collect_inline_attribute('qgis_bstsai', 'citydb', 901, 'description');
-- SELECT * FROM qgis_pkg.collect_inline_attribute('qgis_bstsai', 'citydb', 901, 'name');
-- SELECT * FROM qgis_pkg.collect_inline_attribute('qgis_bstsai', 'citydb', 901, 'class');
-- SELECT * FROM qgis_pkg.collect_inline_attribute('qgis_bstsai', 'citydb', 901, 'function');
-- SELECT * FROM qgis_pkg.collect_inline_attribute('qgis_bstsai','citydb', 901, 'storeyHeightsAboveGround');
-- SELECT * FROM qgis_pkg.collect_inline_attribute('qgis_bstsai','rh_v5', 901, 'function');
-- SELECT * FROM qgis_pkg.collect_inline_attribute('qgis_bstsai','rh_v5', 709, 'direction', 'm_view');
-- SELECT * FROM qgis_pkg.collect_inline_attribute('qgis_bstsai','rh_v5', 901, 'function', 'm_view');


----------------------------------------------------------------
-- Create FUNCTION QGIS_PKG.COLLECT_NESTED_SINGLE_ATTRIBUTE()
----------------------------------------------------------------
DROP FUNCTION IF EXISTS qgis_pkg.collect_nested_single_attribute(varchar, varchar, integer, text, varchar) CASCADE;
CREATE OR REPLACE FUNCTION qgis_pkg.collect_nested_single_attribute(
	usr_schema varchar,
	cdb_schema varchar,
	objectclass_id integer,
	parent_attribute_name text,
	cdb_bbox_type varchar DEFAULT 'db_schema'
)
RETURNS text AS $$
DECLARE
	qi_usr_schema varchar:= quote_ident(usr_schema);
	qi_cdb_schema varchar:= quote_ident(cdb_schema);
	cdb_bbox_type_array CONSTANT varchar[]:= ARRAY['db_schema', 'm_view', 'qgis'];
	cdb_envelope geometry;
	oc_id integer := objectclass_id;
	p_attri_name text := parent_attribute_name;
	attri_names text[]; attri_name text;
	attri_val_cols text[]; attri_val_col text;
	val_col_count integer:= 1; -- 1-based index of array in postgresql
    qi_is_multiple_val_cols boolean DEFAULT FALSE;
	qi_n_val_cols integer;
	srid integer;
	sql_where text;
	sql_attri text;
BEGIN
-- Get the srid
EXECUTE format('SELECT srid FROM %I.database_srs LIMIT 1', qi_cdb_schema) INTO srid;
	
-- Check that the cdb_box_type is a valid value and get the envelope
IF cdb_bbox_type IS NULL OR NOT (cdb_bbox_type = ANY (cdb_bbox_type_array)) THEN
	RAISE EXCEPTION 'cdb_bbox_type value is invalid. It must be one of (%)', cdb_bbox_type_array;
ELSE
	EXECUTE format('SELECT envelope FROM %I.extents WHERE cdb_schema = %L AND bbox_type = %L', qi_usr_schema, qi_cdb_schema, cdb_bbox_type) INTO cdb_envelope;
END IF;

-- Check that the srid is the same to cdb_envelope
IF ST_SRID(cdb_envelope) IS NULL OR ST_SRID(cdb_envelope) <> srid OR cdb_bbox_type = 'db_schema' THEN
	sql_where := NULL;
ELSE
	sql_where := concat(' AND ST_MakeEnvelope(',ST_XMin(cdb_envelope),',',ST_YMin(cdb_envelope),',',ST_XMax(cdb_envelope),',',ST_YMax(cdb_envelope),',',srid,') && f.envelope ');
END IF;

-- Check if feature attribute metadata table exists
IF NOT EXISTS(SELECT 1 FROM information_schema.tables WHERE table_schema = qi_usr_schema AND table_name = 'feature_attribute_metadata') THEN
	RAISE EXCEPTION '%.feature_attribute_metadata table not yet created. Please create it first', qi_usr_schema;
END IF;

-- Get the child attributes from feature attribute metadata table
EXECUTE format('SELECT ARRAY_AGG(attribute_name) FROM %I.feature_attribute_metadata WHERE cdb_schema = %L AND objectclass_id = %s AND parent_attribute_name = %L;', qi_usr_schema, qi_cdb_schema, objectclass_id, parent_attribute_name) INTO attri_names;

sql_attri := concat('
SELECT 
	f.id AS f_id,');

-- Dynamically add SELECT clause
FOREACH attri_name IN ARRAY attri_names
LOOP
EXECUTE format('SELECT * FROM qgis_pkg.attribute_value_column_check(%L,%L,%L)', qi_cdb_schema, objectclass_id, attri_name) INTO attri_val_cols;
qi_n_val_cols := ARRAY_LENGTH(attri_val_cols, 1);
	-- multiple value columns
	IF qi_n_val_cols > 1 THEN
        qi_is_multiple_val_cols := TRUE;
		FOREACH attri_val_col IN ARRAY attri_val_cols
		LOOP
			-- only the first val_col will be named as the attribute name
			IF val_col_count = 1 THEN
				sql_attri := concat(sql_attri,'
					MAX(CASE WHEN p1.name = ', quote_literal(attri_name),' THEN p1.', attri_val_col,' END) AS "', parent_attribute_name, '_', attri_name, '",');
			-- the rest val_cols will be named without the 'val_' prefix, like column 'val_codespace' will be renamed as 'Codespace'
			ELSE
				IF attri_val_col = 'val_uom' THEN
					sql_attri := concat(sql_attri,'
						MAX(CASE WHEN p1.name = ', quote_literal(attri_name),' THEN p1.', attri_val_col,' END) AS "', parent_attribute_name, '_', attri_name, '_UoM",');
				ELSE
					sql_attri := concat(sql_attri,'
						MAX(CASE WHEN p1.name = ', quote_literal(attri_name),' THEN p1.', attri_val_col,' END) AS "', parent_attribute_name, '_', attri_name, '_', SUBSTRING(attri_val_col FROM 'val_(.*)'),'",'); -- INITCAP
				END IF;
			END IF;
			val_col_count := val_col_count + 1; 
		END LOOP;
		val_col_count := 1;
	ELSE
	sql_attri := concat(sql_attri,'
		MAX(CASE WHEN p1.name = ', quote_literal(attri_name),' THEN p1.', attri_val_cols[1],' END) AS "', parent_attribute_name, '_', attri_name, '",');
	END IF;
    
    -- Update the is_multiple_value_columns, n_value_columns, value_columns
	EXECUTE format('
	UPDATE %I.feature_attribute_metadata AS fam
    SET 
        is_multiple_value_columns = %L, 
        n_value_columns = %L,
        value_column = %L, 
        last_modification_date = clock_timestamp()
    WHERE fam.cdb_schema = %L 
		AND fam.objectclass_id = %L
		AND fam.parent_attribute_name = %L 
		AND fam.attribute_name = %L;
	', 
	qi_usr_schema, qi_is_multiple_val_cols, qi_n_val_cols, attri_val_cols, 
	qi_cdb_schema, oc_id, p_attri_name, attri_name);
END LOOP;

-- Add the FROM clause
sql_attri := concat(LEFT(sql_attri, LENGTH(sql_attri) - 1),'
FROM ',qi_cdb_schema,'.feature AS f
	INNER JOIN ',qi_cdb_schema,'.property AS p ON (f.id = p.feature_id AND f.objectclass_id = ',objectclass_id,' AND p.name = ',quote_literal(parent_attribute_name),'',sql_where,')
	INNER JOIN ',qi_cdb_schema,'.property AS p1 ON p.id = p1.parent_id
GROUP BY f.id
');

RETURN sql_attri;
	
EXCEPTION
	WHEN QUERY_CANCELED THEN
		RAISE EXCEPTION 'qgis_pkg.collect_nested_single_attribute(): Error QUERY_CANCELED';
	WHEN OTHERS THEN 
		RAISE EXCEPTION 'qgis_pkg.collect_nested_single_attribute(): %', SQLERRM;
END;	
$$ LANGUAGE plpgsql;
COMMENT ON FUNCTION qgis_pkg.collect_nested_single_attribute(varchar, varchar, integer, text, varchar) IS 'Collect values of the "nested-single" attribute type';
REVOKE EXECUTE ON FUNCTION qgis_pkg.collect_nested_single_attribute(varchar, varchar, integer, text, varchar) FROM public;
-- Example
-- SELECT * FROM qgis_pkg.collect_nested_single_attribute('qgis_bstsai', 'citydb', 901, 'height');
-- SELECT * FROM qgis_pkg.collect_nested_single_attribute('qgis_bstsai', 'rh_v5', 901, 'height');
-- SELECT * FROM qgis_pkg.collect_nested_single_attribute('qgis_bstsai', 'vienna_v5', 901, 'height');


----------------------------------------------------------------
-- Create FUNCTION QGIS_PKG.COLLECT_NESTED_MULTIPLE_ATTRIBUTE()
----------------------------------------------------------------
DROP FUNCTION IF EXISTS qgis_pkg.collect_nested_multiple_attribute(varchar, varchar, integer, text, integer, varchar) CASCADE;
CREATE OR REPLACE FUNCTION qgis_pkg.collect_nested_multiple_attribute(
	usr_schema varchar,
	cdb_schema varchar,
	objectclass_id integer,
	parent_attribute_name text,
    max_multiplicity integer,
	cdb_bbox_type varchar DEFAULT 'db_schema'
)
RETURNS text AS $$
DECLARE
	qi_usr_schema varchar:= quote_ident(usr_schema);
	qi_cdb_schema varchar:= quote_ident(cdb_schema);
	cdb_bbox_type_array CONSTANT varchar[]:= ARRAY['db_schema', 'm_view', 'qgis'];
	cdb_envelope geometry;
	oc_id integer := objectclass_id;
	qi_p_attri_name text := parent_attribute_name;
	attri_names text[]; attri_name text;
	attri_val_cols text[]; attri_val_col text; attri_val_cols_nested text[];
	additional_col_name text;
	iter_count integer := 1;
	val_col_count integer:= 1; -- 1-based index of array in postgresql
	val_col_type text; -- only used when there is only one value column
    qi_is_multiple_val_cols boolean DEFAULT FALSE;
	qi_n_val_cols integer;
	qi_ct_type_name varchar;
	srid integer;
	sql_where text;
	sql_ct_type_def text;
	sql_ctb_header text; sql_ctb_val_col text;
	sql_attri text;
BEGIN
-- Get the srid
EXECUTE format('SELECT srid FROM %I.database_srs LIMIT 1', qi_cdb_schema) INTO srid;
	
-- Check that the cdb_box_type is a valid value and get the envelope
IF cdb_bbox_type IS NULL OR NOT (cdb_bbox_type = ANY (cdb_bbox_type_array)) THEN
	RAISE EXCEPTION 'cdb_bbox_type value is invalid. It must be one of (%)', cdb_bbox_type_array;
ELSE
	EXECUTE format('SELECT envelope FROM %I.extents WHERE cdb_schema = %L AND bbox_type = %L', qi_usr_schema, qi_cdb_schema, cdb_bbox_type) INTO cdb_envelope;
END IF;

-- Check that the srid is the same to cdb_envelope
IF ST_SRID(cdb_envelope) IS NULL OR ST_SRID(cdb_envelope) <> srid OR cdb_bbox_type = 'db_schema' THEN
	sql_where := NULL;
ELSE
	sql_where := concat(' AND ST_MakeEnvelope(',ST_XMin(cdb_envelope),',',ST_YMin(cdb_envelope),',',ST_XMax(cdb_envelope),',',ST_YMax(cdb_envelope),',',srid,') && f.envelope ');
END IF;

-- Check if feature attribute metadata table exists
IF NOT EXISTS(SELECT 1 FROM information_schema.tables WHERE table_schema = qi_usr_schema AND table_name = 'feature_attribute_metadata') THEN
	RAISE EXCEPTION '%.feature_attribute_metadata table not yet created. Please create it first', qi_usr_schema;
END IF;

-- Get the child attributes from feature attribute metadata table
EXECUTE format('SELECT ARRAY_AGG(attribute_name) FROM %I.feature_attribute_metadata WHERE cdb_schema = %L AND objectclass_id = %s AND parent_attribute_name = %L;', qi_usr_schema, qi_cdb_schema, objectclass_id, parent_attribute_name) INTO attri_names;

sql_attri := concat('
SELECT 
	f_id AS f_id,');
sql_ctb_header := 'f_id bigint, ';

FOREACH attri_name IN ARRAY attri_names
LOOP
	EXECUTE format('SELECT * FROM qgis_pkg.attribute_value_column_check(%L,%L,%L)', qi_cdb_schema, objectclass_id, attri_name) INTO attri_val_cols;
    qi_n_val_cols := ARRAY_LENGTH(attri_val_cols, 1);
    IF qi_n_val_cols > 1 THEN
        qi_is_multiple_val_cols := TRUE;
    END IF;
    -- Update the is_multiple_value_columns, n_value_columns, value_columns
	EXECUTE format('
	UPDATE %I.feature_attribute_metadata AS fam
    SET 
        is_multiple_value_columns = %L, 
        n_value_columns = %L,
        value_column = %L, 
        last_modification_date = clock_timestamp()
    WHERE fam.cdb_schema = %L 
		AND fam.objectclass_id = %L 
		AND fam.parent_attribute_name = %L  
		AND fam.attribute_name = %L;
	', 
	qi_usr_schema, qi_is_multiple_val_cols, qi_n_val_cols, attri_val_cols,
	qi_cdb_schema, oc_id, qi_p_attri_name, attri_name
	);

	FOREACH attri_val_col IN ARRAY attri_val_cols
	LOOP
		IF NOT attri_val_col = ANY(attri_val_cols_nested) OR attri_val_cols_nested IS NULL THEN
			-- Check the overall value columns
			attri_val_cols_nested := ARRAY_APPEND(attri_val_cols_nested, attri_val_col);
			-- Generate SELECT clause in crosstab body to get target attribute value columns
			sql_ctb_val_col := concat(sql_ctb_val_col,'p1.',attri_val_col,',');
		END IF;
	END LOOP;
END LOOP;


-- Generate the crosstab sql column header based on the child attributes and the parent attribute's multiplicity
IF (attri_val_cols_nested IS NOT NULL AND ARRAY_LENGTH(attri_val_cols_nested,1) > 1) THEN
    -- If the nested attributes have all their values in one column, then no need for creating composite type
    -- and the SELECT clause in crosstab body will only be p1.(val_col)
    EXECUTE format ('SELECT * FROM qgis_pkg.create_compostie_type_name(%L,%L,%L)', qi_cdb_schema, objectclass_id, parent_attribute_name) INTO qi_ct_type_name;
	EXECUTE format ('SELECT * FROM qgis_pkg.create_compostie_type_header(%L,%L,%L)', qi_cdb_schema, qi_ct_type_name, attri_val_cols_nested) INTO sql_ct_type_def;
	sql_ctb_val_col := concat('(',LEFT(sql_ctb_val_col, LENGTH(sql_ctb_val_col) - 1),')::', qi_ct_type_name);

	WHILE iter_count <= max_multiplicity
	LOOP
		FOREACH attri_name IN ARRAY attri_names
		LOOP
            -- Update ct_type_name if there are multiple val_cols
			EXECUTE format ('
			UPDATE %I.feature_attribute_metadata AS fam
            SET 
                ct_type_name = %L,
                last_modification_date = clock_timestamp()
            WHERE fam.cdb_schema = %L 
				AND fam.objectclass_id = %L 
				AND fam.parent_attribute_name = %L;
			', 
			qi_usr_schema, qi_ct_type_name, qi_cdb_schema, oc_id, qi_p_attri_name);
            
			sql_ctb_header := concat(sql_ctb_header, attri_name, '_', iter_count::text, ' ', qi_ct_type_name, ',');
			EXECUTE format('SELECT * FROM qgis_pkg.attribute_value_column_check(%L,%L,%L)', qi_cdb_schema, objectclass_id, attri_name) INTO attri_val_cols;
			FOREACH attri_val_col IN ARRAY attri_val_cols
			LOOP
				-- only the first val_col will be named as the attribute name
				IF val_col_count = 1 THEN
						sql_attri := concat(sql_attri, '
							(', attri_name, '_', iter_count::text, ').', attri_val_col, ' AS "', parent_attribute_name, '_', attri_name, '_', iter_count::text, '",');
				ELSE 
					IF attri_val_col = 'val_uom' THEN
						sql_attri := concat(sql_attri, '
							(', attri_name, '_', iter_count::text, ').', attri_val_col, ' AS "', parent_attribute_name, '_', attri_name, '_UoM_', iter_count, '",');
					ELSE
						sql_attri := concat(sql_attri, '
							(', attri_name, '_', iter_count::text, ').', attri_val_col, ' AS "', parent_attribute_name, '_', attri_name, '_', SUBSTRING(attri_val_col FROM 'val_(.*)'),'_',iter_count, '",'); -- INITCAP
					END IF;
				END IF;
				val_col_count := val_col_count +1;
			END LOOP;
			val_col_count := 1;
		END LOOP;
		iter_count := iter_count + 1;
	END LOOP; 
	iter_count := 1;

ELSIF (attri_val_cols_nested IS NOT NULL AND ARRAY_LENGTH(attri_val_cols_nested,1) = 1) THEN
	sql_ct_type_def := NULL;
	sql_ctb_val_col := concat('p1.', attri_val_cols_nested[1]);
	-- Get the datatype of the only value column
	EXECUTE format('SELECT qgis_pkg.attribute_value_column_type(%L, %L)', qi_cdb_schema, attri_val_cols_nested[1]) INTO val_col_type;
	WHILE iter_count <= max_multiplicity
	LOOP
		FOREACH attri_name IN ARRAY attri_names
		LOOP
			sql_ctb_header := concat(sql_ctb_header, attri_name, '_', iter_count::text, ' ', val_col_type, ',');
			EXECUTE format('SELECT * FROM qgis_pkg.attribute_value_column_check(%L,%L,%L)', qi_cdb_schema, objectclass_id, attri_name) INTO attri_val_cols;
			FOREACH attri_val_col IN ARRAY attri_val_cols
			LOOP
				-- only the first val_col will be named as the attribute name
				IF val_col_count = 1 THEN
						sql_attri := concat(sql_attri, '
							', attri_name, '_', iter_count::text, ' AS "', parent_attribute_name, '_', attri_name, '_', iter_count::text, '",');
				ELSE 
					IF attri_val_col = 'val_uom' THEN
						sql_attri := concat(sql_attri, '
							', attri_name, '_', iter_count::text, ' AS "', parent_attribute_name, '_', attri_name, '_UoM_', iter_count, '",');
					ELSE
						sql_attri := concat(sql_attri, '
							', attri_name, '_', iter_count::text, ' AS "', parent_attribute_name, '_', attri_name, '_', SUBSTRING(attri_val_col FROM 'val_(.*)'),'_',iter_count, '",'); -- INITCAP
					END IF;
				END IF;
				val_col_count := val_col_count +1;
			END LOOP;
			val_col_count := 1;
		END LOOP;
		iter_count := iter_count + 1;
	END LOOP; 
	iter_count := 1;
END IF;

-- Generate the final sql_attri
sql_attri := concat(sql_ct_type_def, LEFT(sql_attri, LENGTH(sql_attri) - 1),'
FROM CROSSTAB(
	$BODY$
	SELECT
		f.id AS f_id,
		p1.name,
		',sql_ctb_val_col,'
	FROM ',qi_cdb_schema,'.feature AS f 
		INNER JOIN ',qi_cdb_schema,'.property AS p ON (f.id = p.feature_id AND f.objectclass_id = ',objectclass_id,' AND p.name = ',quote_literal(parent_attribute_name),'',sql_where,')
		INNER JOIN ',qi_cdb_schema,'.property AS p1 ON p.id = p1.parent_id
	ORDER BY f.id, p.id, p1.name ASC
    $BODY$
) AS ct(',LEFT(sql_ctb_header, LENGTH(sql_ctb_header) - 1),')
');

RETURN sql_attri;
	
EXCEPTION
	WHEN QUERY_CANCELED THEN
		RAISE EXCEPTION 'qgis_pkg.collect_nested_multiple_attribute(): Error QUERY_CANCELED';
	WHEN OTHERS THEN 
		RAISE EXCEPTION 'qgis_pkg.collect_nested_multiple_attribute(): %', SQLERRM;
END;	
$$ LANGUAGE plpgsql;
COMMENT ON FUNCTION qgis_pkg.collect_nested_multiple_attribute(varchar, varchar, integer, text, integer, varchar) IS 'Collect values of the "nested-multiple" attribute type';
REVOKE EXECUTE ON FUNCTION qgis_pkg.collect_nested_multiple_attribute(varchar, varchar, integer, text, integer, varchar) FROM public;
--Example
-- SELECT * FROM qgis_pkg.collect_nested_multiple_attribute('qgis_bstsai', 'citydb', 901, 'height', 2);


----------------------------------------------------------------
-- Create FUNCTION QGIS_PKG.COLLECT_NESTED_ATTRIBUTE()
----------------------------------------------------------------
-- The function first check the maximum multiplicity of the "nested" attribute and
-- 1. if maximum multiplicity > 1 then call function qgis_pkg.collect_nested_multiple_attribute
-- 2. else call function qgis_pkg.collect_nested_single_attribute
DROP FUNCTION IF EXISTS qgis_pkg.collect_nested_attribute(varchar, varchar, integer, text, varchar);
CREATE OR REPLACE FUNCTION qgis_pkg.collect_nested_attribute(
    usr_schema varchar,
	cdb_schema varchar,
    objectclass_id integer,
	parent_attribute_name text,
    cdb_bbox_type varchar DEFAULT 'db_schema'
) RETURNS text AS $$
DECLARE
    qi_usr_schema varchar := quote_ident(usr_schema);
	qi_cdb_schema varchar := quote_ident(cdb_schema);
    cdb_bbox_type_array CONSTANT varchar[] := ARRAY['db_schema', 'm_view', 'qgis'];
	oc_id integer := objectclass_id;
	p_attri_name text:= parent_attribute_name;
	qi_is_multiple boolean DEFAULT FALSE;
    qi_max_multiplicity integer;
    srid integer;
	sql_attri text;
BEGIN
-- Get the srid
EXECUTE format('SELECT srid FROM %I.database_srs LIMIT 1', qi_cdb_schema) INTO srid;
	
-- Check that the cdb_box_type is a valid value
IF cdb_bbox_type IS NULL OR NOT (cdb_bbox_type = ANY (cdb_bbox_type_array)) THEN
	RAISE EXCEPTION 'cdb_bbox_type value is invalid. It must be one of (%)', cdb_bbox_type_array;
END IF;

-- Get the maximum multiplicity number of the given feature attribute
EXECUTE format('SELECT * FROM qgis_pkg.attribute_multiplicity_count(%L, %L, %L, %L, %L);', qi_usr_schema, qi_cdb_schema, objectclass_id, parent_attribute_name, cdb_bbox_type) INTO qi_max_multiplicity;

IF qi_max_multiplicity > 1 THEN
	qi_is_multiple := TRUE;
    EXECUTE format('SELECT qgis_pkg.collect_nested_multiple_attribute(%L, %L, %s, %L, %s, %L);', qi_usr_schema, qi_cdb_schema, objectclass_id, parent_attribute_name, qi_max_multiplicity, cdb_bbox_type) INTO sql_attri;
ELSE
    EXECUTE format('SELECT qgis_pkg.collect_nested_single_attribute(%L, %L, %s, %L, %L);', qi_usr_schema, qi_cdb_schema, objectclass_id, parent_attribute_name, cdb_bbox_type) INTO sql_attri;
END IF;

-- Update the is_multiple and maximum multiplicity column
EXECUTE format ('
UPDATE %I.feature_attribute_metadata AS fam
SET 
	is_multiple = %L, 
	max_multiplicity = %L, 
	last_modification_date = clock_timestamp()
WHERE fam.cdb_schema = %L
	AND fam.objectclass_id = %L 
	AND fam.parent_attribute_name = %L;
',
qi_usr_schema, qi_is_multiple, qi_max_multiplicity, qi_cdb_schema,
oc_id, p_attri_name);
	
RETURN sql_attri;

EXCEPTION
	WHEN QUERY_CANCELED THEN
		RAISE EXCEPTION 'qgis_pkg.collect_nested_attribute(): Error QUERY_CANCELED';
	WHEN OTHERS THEN 
		RAISE EXCEPTION 'qgis_pkg.collect_nested_attribute(): %', SQLERRM;
END;
$$ LANGUAGE plpgsql;
COMMENT ON FUNCTION qgis_pkg.collect_nested_attribute(varchar, varchar, integer, text, varchar) IS 'Collect the "nested" attribute value in specific cdb_schema';
REVOKE EXECUTE ON FUNCTION qgis_pkg.collect_nested_attribute(varchar, varchar, integer, text, varchar) FROM public;
-- Example
-- SELECT * FROM qgis_pkg.collect_nested_attribute('qgis_bstsai', 'citydb', 15, 'relatedTo'); -- single entry
-- SELECT * FROM qgis_pkg.collect_nested_attribute('qgis_bstsai', 'citydb', 901, 'height'); -- citydb_v5: multiple height entries; japan_v5: single entry
-- SELECT * FROM qgis_pkg.collect_nested_attribute('qgis_bstsai', 'citydb', 901, '土砂災害警戒区域');
-- SELECT * FROM qgis_pkg.collect_nested_attribute('qgis_bstsai', 'rh_v5', 901, 'height');
-- SELECT * FROM qgis_pkg.collect_nested_attribute('qgis_bstsai', 'vienna_v5', 901, 'height');
-- SELECT qgis_pkg.cleanup_schema('citydb');


----------------------------------------------------------------
-- Create FUNCTION QGIS_PKG.GET_VIEW_COLUMN_NAME()
----------------------------------------------------------------
DROP FUNCTION IF EXISTS qgis_pkg.get_view_column_name(varchar, varchar);
CREATE OR REPLACE FUNCTION qgis_pkg.get_view_column_name(
    usr_schema varchar,
	qi_av_name varchar
) RETURNS text[] AS $$
DECLARE
	qi_usr_schema varchar := quote_ident(usr_schema);
	ql_usr_schema varchar := quote_literal(usr_schema);
	av_name CONSTANT varchar := trim(both '"' from qi_av_name);
    ql_view_name varchar := quote_literal(av_name);
    sql_col_name text;
    col_names text[];
BEGIN
sql_col_name := concat('
SELECT ARRAY (
    SELECT 
        a.attname
        -- pg_catalog.format_type(a.atttypid, a.atttypmod)
        -- a.attnotnull
    FROM pg_attribute AS a
        INNER JOIN pg_class AS t on a.attrelid = t.oid
        INNER JOIN pg_namespace s on t.relnamespace = s.oid
    WHERE a.attnum > 0 
        AND NOT a.attisdropped
        AND t.relname = ',ql_view_name,' --<< replace with the name of the MV 
        AND s.nspname = ',ql_usr_schema,' --<< change to the schema your MV is in 
    ORDER BY a.attnum); 
');

EXECUTE sql_col_name INTO col_names;

IF ARRAY_LENGTH(col_names,1) > 0 THEN
	RETURN col_names;
ELSE
	RAISE NOTICE 'Materialized view %.% does not exists, please create it first', qi_usr_schema, qi_av_name;
END IF;
	
EXCEPTION
	WHEN QUERY_CANCELED THEN
		RAISE EXCEPTION 'qgis_pkg.get_view_column_name(): Error QUERY_CANCELED';
	WHEN OTHERS THEN 
		RAISE EXCEPTION 'qgis_pkg.get_view_column_name(): %', SQLERRM;
END;
$$ LANGUAGE plpgsql;
COMMENT ON FUNCTION qgis_pkg.get_view_column_name(varchar, varchar) IS 'Get the available column name(s) of the specified view or materialized view within given schema';
REVOKE EXECUTE ON FUNCTION qgis_pkg.get_view_column_name(varchar, varchar) FROM public;
-- Example
-- SELECT * FROM qgis_pkg.get_view_column_name('qgis_bstsai', '"citydb_attri_v_inline_storeysAboveGround"');
-- SELECT * FROM qgis_pkg.get_view_column_name('qgis_bstsai', '"citydb_amv_n_901_height"');
-- SELECT ARRAY (SELECT unnest(ARRAY(SELECT * FROM qgis_pkg.get_view_column_name('qgis_bstsai', '"citydb_amv_n_901_height"'))) OFFSET 1);


----------------------------------------------------------------
-- Create FUNCTION QGIS_PKG.GET_VIEW_COLUMN_TYPE()
----------------------------------------------------------------
DROP FUNCTION IF EXISTS qgis_pkg.get_view_column_type(varchar, varchar, varchar);
CREATE OR REPLACE FUNCTION qgis_pkg.get_view_column_type(
    usr_schema varchar,
	qi_av_name varchar,
	val_col_name varchar
) RETURNS varchar AS $$
DECLARE
	qi_usr_schema varchar := quote_ident(usr_schema);
	av_name varchar := trim(both '"' from qi_av_name);
	qi_av_name varchar := quote_ident(av_name);
    qi_view_name varchar;
	ql_val_col_name varchar := quote_literal(val_col_name);
    sql_col_type text;
    col_type varchar;
BEGIN
qi_view_name := concat(qi_usr_schema,'.',qi_av_name);
sql_col_type := concat('
SELECT  
	FORMAT_TYPE(atttypid, atttypmod)::varchar AS data_type
FROM pg_attribute
WHERE attrelid = ',quote_literal(qi_view_name),' ::regclass
AND attname = ',ql_val_col_name,';
');

EXECUTE sql_col_type INTO col_type;

IF col_type IS NOT NULL THEN
	RETURN col_type;
ELSE
	RAISE NOTICE 'Error finding the type of % column in view %.%. Please check whether the view has been created or the column name is entered correctly!', ql_val_col_name, qi_usr_schema, qi_av_name;
END IF;
	
EXCEPTION
	WHEN QUERY_CANCELED THEN
		RAISE EXCEPTION 'qgis_pkg.get_view_column_type(): Error QUERY_CANCELED';
	WHEN OTHERS THEN 
		RAISE EXCEPTION 'qgis_pkg.get_view_column_type(): %', SQLERRM;
END;
$$ LANGUAGE plpgsql;
COMMENT ON FUNCTION qgis_pkg.get_view_column_type(varchar, varchar, varchar) IS 'Get the available column type of the specified view or materialized view within given schema';
REVOKE EXECUTE ON FUNCTION qgis_pkg.get_view_column_type(varchar, varchar, varchar) FROM public;
-- Example
-- SELECT * FROM qgis_pkg.get_view_column_type('qgis_bstsai', 'citydb_av_i_902_storeyHeightsAboveGround', 'storeyHeightsAboveGround');


----------------------------------------------------------------
-- Create FUNCTION QGIS_PKG.GET_ATTRIBUTE_KEY_ID()
----------------------------------------------------------------
-- The function lookup the primary key id of the given attribute
-- If the attribute is nested, it will return the key id of its first child attribute's id
DROP FUNCTION IF EXISTS qgis_pkg.get_attribute_key_id(varchar, varchar, integer, varchar);
CREATE OR REPLACE FUNCTION qgis_pkg.get_attribute_key_id(
	usr_schema varchar,
	cdb_schema varchar,
	objectclass_id integer,
	attribute_name varchar
) RETURNS integer AS $$
DECLARE
	qi_usr_schema varchar := quote_ident(usr_schema);
	ql_cdb_schema varchar := quote_literal(cdb_schema);
	ql_attri_name varchar := quote_literal(attribute_name);
	oc_id integer := objectclass_id;
    sql_attri_id text;
    attri_id integer;
BEGIN

-- Check if feature attribute metadata table exists
IF NOT EXISTS(SELECT 1 FROM information_schema.tables WHERE table_schema = qi_usr_schema AND table_name = 'feature_attribute_metadata') THEN
	RAISE EXCEPTION '%.feature_attribute_metadata table not yet created. Please create it first', qi_usr_schema;
END IF;

-- First check Inline attribute
sql_attri_id := concat('
SELECT fam.id
FROM ',qi_usr_schema,'.feature_attribute_metadata AS fam
WHERE fam.cdb_schema = ',ql_cdb_schema,' 
	AND fam.objectclass_id = ',oc_id,' AND fam.attribute_name = ',ql_attri_name,'
	AND fam.is_nested IS FALSE;
');

EXECUTE sql_attri_id INTO attri_id;

IF attri_id IS NULL THEN
	-- Nested attribute, only return the first child attribute's id as reference
	sql_attri_id := concat('
	SELECT fam.id
	FROM ',qi_usr_schema,'.feature_attribute_metadata AS fam
	WHERE fam.cdb_schema = ',ql_cdb_schema,' 
		AND fam.objectclass_id = ',oc_id,' AND fam.parent_attribute_name = ',ql_attri_name,'
		AND fam.is_nested IS TRUE
	ORDER BY fam.id
	LIMIT 1;
	');
	EXECUTE sql_attri_id INTO attri_id;
	IF attri_id IS NULL THEN
		RAISE EXCEPTION 'The attribute % of objectclass_id % cannot be found! Please check if the existence of the attribute in schema %', ql_attri_name, oc_id, ql_cdb_schema;
	ELSE
		RETURN attri_id;
	END IF;
ELSE
	RETURN attri_id;
END IF;

EXCEPTION
	WHEN QUERY_CANCELED THEN
		RAISE EXCEPTION 'qgis_pkg.get_attribute_key_id(): Error QUERY_CANCELED';
	WHEN OTHERS THEN 
		RAISE EXCEPTION 'qgis_pkg.get_attribute_key_id(): %', SQLERRM;
END;
$$ LANGUAGE plpgsql;
COMMENT ON FUNCTION qgis_pkg.get_attribute_key_id(varchar, varchar, integer, varchar) IS 'Lookup the primary key id of the given attribute. If the attribute is nested, it will return the key id of the first id of its child attribute';
REVOKE EXECUTE ON FUNCTION qgis_pkg.get_attribute_key_id(varchar, varchar, integer, varchar) FROM public;
-- Example
-- SELECT * FROM qgis_pkg.get_attribute_key_id('qgis_bstsai','citydb', 901, 'name');
-- SELECT * FROM qgis_pkg.get_attribute_key_id('qgis_bstsai','citydb', 901, 'height');
-- SELECT * FROM qgis_pkg.get_attribute_key_id('qgis_bstsai','citydb', 901, '土砂災害警戒区域');


----------------------------------------------------------------
-- Create FUNCTION QGIS_PKG.ATTRIBUTE_KEY_ID_TO_NAME()
----------------------------------------------------------------
-- The function lookup the attribute name of the given attribute_id
-- If the attribute is nested, it will return the parent attribute name suffixed with child attribute name (e.g. hight_value, hight_status, etc)
DROP FUNCTION IF EXISTS qgis_pkg.attribute_key_id_to_name(varchar, varchar, integer, integer);
CREATE OR REPLACE FUNCTION qgis_pkg.attribute_key_id_to_name(
	usr_schema varchar,
	cdb_schema varchar,
	objectclass_id integer,
	attribute_id integer
) RETURNS varchar AS $$
DECLARE
	qi_usr_schema varchar := quote_ident(usr_schema);
	ql_cdb_schema varchar := quote_literal(cdb_schema);
	oc_id integer := objectclass_id;
    sql_attri_name text;
	attri_name varchar;

BEGIN

-- Check if feature attribute metadata table exists
IF NOT EXISTS(SELECT 1 FROM information_schema.tables WHERE table_schema = qi_usr_schema AND table_name = 'feature_attribute_metadata') THEN
	RAISE EXCEPTION '%.feature_attribute_metadata table not yet created. Please create it first', qi_usr_schema;
END IF;

-- First check Inline attribute
sql_attri_name := concat('
SELECT attribute_name
FROM ',qi_usr_schema,'.feature_attribute_metadata AS fam
WHERE fam.cdb_schema = ',ql_cdb_schema,' 
	AND fam.objectclass_id = ', oc_id,' AND fam.id = ', attribute_id,'
	AND fam.is_nested IS FALSE;
');

EXECUTE sql_attri_name INTO attri_name;

IF attri_name IS NULL THEN
	-- Nested attribute, return the name with parent attribute and child attribute concatenated with '_'
	-- sql_attri_name := concat('
	-- 	WITH nested_attri AS (
	-- 		SELECT parent_attribute_name AS p_attri
	-- 		FROM ',qi_usr_schema,'.feature_attribute_metadata
	-- 		WHERE cdb_schema = ', ql_cdb_schema,' AND id = ', attribute_id,'
	-- 	)
	-- 	SELECT array_to_string(
	-- 		ARRAY(
	-- 		SELECT concat(parent_attribute_name, ''_'', attribute_name)
	-- 		FROM ',qi_usr_schema,'.feature_attribute_metadata, nested_attri
	-- 		WHERE cdb_schema = ', ql_cdb_schema,' 
	-- 			AND objectclass_id = ', oc_id,'
	-- 			AND parent_attribute_name = nested_attri.p_attri
	-- 		), '',''
	-- 	)
	-- ');

	-- Only return the parent attribute names
	sql_attri_name := concat('
		SELECT parent_attribute_name AS p_attri
		FROM ',qi_usr_schema,'.feature_attribute_metadata
		WHERE cdb_schema = ', ql_cdb_schema,' AND id = ', attribute_id,'
	');
	EXECUTE sql_attri_name INTO attri_name;
	IF attri_name IS NULL THEN
		RAISE EXCEPTION 'The given attribute name of objectclass_id % cannot be found! Please check if the existence of the attribute in schema %', oc_id, ql_cdb_schema;
	ELSE
		RETURN attri_name;
	END IF;
ELSE
	RETURN attri_name;
END IF;

EXCEPTION
	WHEN QUERY_CANCELED THEN
		RAISE EXCEPTION 'qgis_pkg.attribute_key_id_to_name(): Error QUERY_CANCELED';
	WHEN OTHERS THEN 
		RAISE EXCEPTION 'qgis_pkg.attribute_key_id_to_name(): %', SQLERRM;
END;
$$ LANGUAGE plpgsql;
COMMENT ON FUNCTION qgis_pkg.attribute_key_id_to_name(varchar, varchar, integer, integer) IS 'Lookup the attribute name with the given attribute_id. If the attribute is nested, it will return the parent attribute name suffixed with child attribute name (e.g. hight_value, hight_status, etc)';
REVOKE EXECUTE ON FUNCTION qgis_pkg.attribute_key_id_to_name(varchar, varchar, integer, integer) FROM public;
--Example
-- SELECT * FROM qgis_pkg.attribute_key_id_to_name('qgis_bstsai', 'citydb', 502, 1);
-- SELECT * FROM qgis_pkg.attribute_key_id_to_name('qgis_bstsai', 'citydb', 901, 57);


----------------------------------------------------------------
-- Create FUNCTION QGIS_PKG.GENERATE_SQL_ATTRIBUTE_MATVIEW_FOOTER
----------------------------------------------------------------
DROP FUNCTION IF EXISTS    qgis_pkg.generate_sql_attribute_matview_footer(varchar,varchar,varchar,varchar,integer,varchar) CASCADE;
CREATE OR REPLACE FUNCTION qgis_pkg.generate_sql_attribute_matview_footer(
	qi_usr_name 	varchar,
	qi_usr_schema 	varchar,
	qi_av_name	 	varchar,
	cdb_schema		varchar,
	objectclass_id	integer,
	attribute_name	varchar
)
RETURNS text AS $$
DECLARE
    view_col_names text[]; view_col_name text;
    av_name CONSTANT varchar := trim(both '"' from qi_av_name);
	attri_id bigint := (SELECT qgis_pkg.get_attribute_key_id(qi_usr_schema, cdb_schema, objectclass_id, attribute_name));
    idx_name varchar;
	val_col_type varchar;
    sql_statement text;
BEGIN
-- Get the existing value column names of the view
EXECUTE format('SELECT qgis_pkg.get_view_column_name(%L,%L)', qi_usr_schema, av_name) INTO view_col_names;

IF ARRAY_LENGTH(view_col_names,1) > 0 THEN
    FOREACH view_col_name IN ARRAY view_col_names
    LOOP
		-- Get the type of view value column, if it is json type, skip it for creating index
		EXECUTE format('SELECT qgis_pkg.get_view_column_type(%L,%L,%L)', qi_usr_schema, av_name, view_col_name) INTO val_col_type;
		IF val_col_type <> 'json' THEN
	        idx_name := concat(cdb_schema,'_', objectclass_id, '_', attri_id, '_', view_col_name, '_idx');
	        sql_statement := concat(sql_statement,
	        'CREATE INDEX ',idx_name,' ON ',qi_usr_schema,'.',qi_av_name,' ("',view_col_name,'");');
		END IF;
    END LOOP;
    sql_statement := concat(sql_statement,'
    ALTER TABLE ',qi_usr_schema,'.',qi_av_name,' OWNER TO ',qi_usr_name,';
	REFRESH MATERIALIZED VIEW ',qi_usr_schema,'.',qi_av_name,'');
	RETURN sql_statement;
ELSE
	RAISE NOTICE 'Materialized view %.% does not exists, please create it first', qi_usr_schema, qi_av_name;
END IF;

EXCEPTION
	WHEN QUERY_CANCELED THEN
		RAISE EXCEPTION 'qgis_pkg.generate_sql_attribute_matview_footer(): Error QUERY_CANCELED';
  WHEN OTHERS THEN 
		RAISE EXCEPTION 'qgis_pkg.generate_sql_attribute_matview_footer(): %', SQLERRM;
END;
$$ LANGUAGE plpgsql;
COMMENT ON FUNCTION qgis_pkg.generate_sql_attribute_matview_footer(varchar,varchar,varchar,varchar,integer,varchar) IS 'Generate the footer for creating indices on every attribute materialized view value columns and refresh it';
REVOKE EXECUTE ON FUNCTION qgis_pkg.generate_sql_attribute_matview_footer(varchar,varchar,varchar,varchar,integer,varchar) FROM public;
--Example
-- SELECT * FROM qgis_pkg.generate_sql_attribute_matview_footer('bstsai', 'qgis_bstsai', '"citydb_attri_v_nested_height"', 'citydb', 901, 'height');
-- SELECT * FROM qgis_pkg.generate_sql_attribute_matview_footer('bstsai', 'qgis_bstsai', '"citydb_attri_v_inline_function"', 'citydb', 901, 'function');
	

----------------------------------------------------------------
-- Create FUNCTION QGIS_PKG.CREATE_ATTRIBUTE_VIEW
----------------------------------------------------------------
DROP FUNCTION IF EXISTS qgis_pkg.create_attribute_view(varchar, varchar, integer, text, boolean, varchar, boolean);
CREATE OR REPLACE FUNCTION qgis_pkg.create_attribute_view(
	usr_schema varchar,
	cdb_schema varchar,
	objectclass_id integer,
	attribute_name text,
	is_nested boolean DEFAULT FALSE,
	cdb_bbox_type varchar DEFAULT 'db_schema',
	is_matview boolean DEFAULT FALSE
) RETURNS varchar AS $$
DECLARE
	qi_usr_schema varchar := quote_ident(usr_schema);
	qi_cdb_schema varchar := quote_ident(cdb_schema);
	qi_attri_name varchar := attribute_name;
	qi_usr_name varchar := (SELECT substring(usr_schema from 'qgis_(.*)') AS usr_name);
	qi_oc_id integer := objectclass_id;
	qi_view_name varchar;
	cdb_bbox_type_array CONSTANT varchar[]:= ARRAY['db_schema', 'm_view', 'qgis'];
	ct_type_name varchar;
	check_ct_type_name varchar;
	ct_type_header text;
	sql_where text;
	sql_attri text;
	sql_view_header text;
	sql_mv_footer text;
	sql_view text;
	inline_exist boolean;
	nested_exist boolean;

BEGIN
-- Check if cdb_name exists
IF qi_cdb_schema IS NULL or NOT EXISTS(SELECT 1 FROM information_schema.schemata AS i WHERE i.schema_name::varchar = qi_cdb_schema) THEN
	RAISE EXCEPTION 'cdb_schema (%) is invalid. It must be an existing schema', qi_cdb_schema;
END IF;

-- Check if current user has created specific schema named "qgis_(usr_name)"
IF qi_usr_schema IS NULL OR NOT EXISTS(SELECT * FROM information_schema.schemata AS i WHERE schema_name = qi_usr_schema) THEN
	RAISE EXCEPTION 'user_schema: % does not exist. Please create it first', qi_usr_schema;
END IF;
	
-- Check that the cdb_box_type is a valid value and get the envelope
IF cdb_bbox_type IS NULL OR NOT (cdb_bbox_type = ANY (cdb_bbox_type_array)) THEN
	RAISE EXCEPTION 'cdb_bbox_type value is invalid. It must be one of (%)', cdb_bbox_type_array;
END IF;

-- Check if feature attribute metadata table exists
IF NOT EXISTS(SELECT 1 FROM information_schema.tables WHERE table_schema = qi_usr_schema AND table_name = 'feature_attribute_metadata') THEN
	RAISE EXCEPTION '%.feature_attribute_metadata table not yet created. Please create it first', qi_usr_schema;
END IF;


-- Check if the attribute is in the feature attribute metadata table and generate view name(s)
IF NOT is_nested THEN
	EXECUTE format('
	SELECT 1 FROM %I.feature_attribute_metadata AS fam 
	WHERE fam.cdb_schema = %L
		AND fam.objectclass_id = %L 
		AND fam.attribute_name = %L', qi_usr_schema, qi_cdb_schema, qi_oc_id, qi_attri_name) INTO inline_exist;
	IF NOT inline_exist THEN
		RAISE EXCEPTION 'Inline attribute "%" does not exist in schema % (extent type: %). Please scan and check it first in the %.feature_attribute_metadata table!', attribute_name, cdb_schema, cdb_bbox_type, usr_schema;
	ELSE
		qi_view_name := concat('i_', objectclass_id, '_', attribute_name);
		EXECUTE format('SELECT qgis_pkg.collect_inline_attribute(%L, %L, %s, %L, %L);', qi_usr_schema, qi_cdb_schema, objectclass_id, attribute_name, cdb_bbox_type) INTO sql_attri;
	END IF;
ELSE
	EXECUTE format('
	SELECT 1 FROM %I.feature_attribute_metadata AS fam 
	WHERE fam.cdb_schema = %L 
		AND fam.objectclass_id = %L 
		AND fam.parent_attribute_name = %L
	', qi_usr_schema, qi_cdb_schema, qi_oc_id, qi_attri_name) INTO nested_exist;
	IF NOT nested_exist THEN
		RAISE EXCEPTION 'Nested attribute "%" does not exist in schema % (extent type: %). Please scan and check it first in the %.feature_attribute_metadata table!', attribute_name, cdb_schema, cdb_bbox_type, usr_schema;
	ELSE
		qi_view_name := concat('n_', objectclass_id, '_', attribute_name);
		EXECUTE format('SELECT qgis_pkg.collect_nested_attribute(%L, %L, %s, %L, %L);', qi_usr_schema, qi_cdb_schema, objectclass_id, attribute_name, cdb_bbox_type) INTO sql_attri;
	END IF;
END IF;

-- Check if composite type exist in attribute query
-- If true, separate the ct_type_header and the rest of the query for later adding the view creation header
ct_type_name := (SELECT (REGEXP_MATCH(sql_attri, 'DROP TYPE IF EXISTS (.*?);[\s\n]*CREATE TYPE (.*?) AS \(.*?\);'))[1]);
ct_type_header := (SELECT (REGEXP_MATCH(sql_attri, '(DROP TYPE IF EXISTS .*?;[\n\s]*CREATE TYPE .*?;)'))[1]);
IF ct_type_header IS NOT NULL THEN
	sql_attri := (SELECT (REGEXP_SUBSTR(sql_attri, 'SELECT.*?AS ct\(.*?\)')));
END IF;
check_ct_type_name := trim(both '"' from ct_type_name);
	
-- Determine view or materialized view
-- Add view prefix: av-> feature attribute view; amv -> feature attribute materialized view
IF NOT is_matview THEN
	qi_view_name := concat('"', qi_cdb_schema, '_av_', qi_view_name, '"');
	-- Generate view header
	EXECUTE format('SELECT qgis_pkg.generate_sql_view_header(%L, %L)', qi_usr_schema, qi_view_name) INTO sql_view_header;
	--Check if ct_type already existed
	IF NOT EXISTS (SELECT 1 FROM pg_type WHERE typname = check_ct_type_name) THEN
		sql_view := concat(ct_type_header, sql_view_header, sql_attri, ';');
	ELSE
		sql_view := concat(sql_view_header, sql_attri, ';');
	END IF;
ELSE
	qi_view_name := concat('"', qi_cdb_schema, '_amv_', qi_view_name, '"');
	-- Generate materialized view header
	EXECUTE format('SELECT qgis_pkg.generate_sql_matview_header(%L, %L)', qi_usr_schema, qi_view_name) INTO sql_view_header;
	-- Generate materialized view footer (should create index based on the columns)
	-- Check if ct_type already existed
	IF NOT EXISTS (SELECT 1 FROM pg_type WHERE typname = check_ct_type_name) THEN
		-- Generate attribute view query and add refresh mv
		sql_view := concat(ct_type_header, sql_view_header, sql_attri, ';');
	ELSE
		sql_view := concat(sql_view_header, sql_attri, ';');
	END IF;
END IF;

IF sql_attri IS NOT NULL THEN
	EXECUTE sql_view;
	-- Update the view info in feature attribute metadata table
	-- If MV is created, add the footer and execute to create indices on its all value column and refresh it
	IF NOT is_matview THEN
		IF NOT is_nested THEN
			-- Update the view_name, creation_date
			EXECUTE format('
			UPDATE %I.feature_attribute_metadata AS fam
			SET 
				view_name = %L, 
				view_creation_date = clock_timestamp()
			WHERE fam.cdb_schema = %L 
				AND fam.objectclass_id = %L 
				AND fam.attribute_name = %L;
			', qi_usr_schema, qi_view_name, qi_cdb_schema, qi_oc_id, qi_attri_name);
		ELSE
			-- Update the view_name, creation_date
			EXECUTE format('
			UPDATE %I.feature_attribute_metadata AS fam
			SET 
				view_name = %L, 
				view_creation_date = clock_timestamp()
			WHERE fam.cdb_schema = %L 
				AND fam.objectclass_id = %L 
				AND fam.parent_attribute_name = %L;
			', qi_usr_schema, qi_view_name, qi_cdb_schema, qi_oc_id, qi_attri_name);
		END IF;
	ELSE
		IF NOT is_nested THEN
			-- Generate attribute mv footer
			EXECUTE format('SELECT qgis_pkg.generate_sql_attribute_matview_footer(%L, %L, %L, %L, %L, %L)',qi_usr_name, usr_schema, qi_view_name, qi_cdb_schema, objectclass_id, attribute_name) INTO sql_mv_footer;
			EXECUTE sql_mv_footer;
			-- Update the mview_name, creation_date
			EXECUTE format('
			UPDATE %I.feature_attribute_metadata AS fam
			SET 
				mview_name = %L, 
				mview_refresh_date = clock_timestamp()
			WHERE fam.cdb_schema = %L 
				AND fam.objectclass_id = %L 
				AND fam.attribute_name = %L;
			', qi_usr_schema, qi_view_name, qi_cdb_schema, qi_oc_id, qi_attri_name);
		ELSE
			-- Update the mview_name, mv_refresh_date
			-- Generate attribute mv footer
			EXECUTE format('SELECT qgis_pkg.generate_sql_attribute_matview_footer(%L, %L, %L, %L, %L, %L)',qi_usr_name, usr_schema, qi_view_name, qi_cdb_schema, objectclass_id, attribute_name) INTO sql_mv_footer;
			EXECUTE sql_mv_footer;
			-- Update the mview_name, creation_date
			EXECUTE format('
			UPDATE %I.feature_attribute_metadata AS fam
			SET 
				mview_name = %L, 
				mview_refresh_date = clock_timestamp()
			WHERE fam.cdb_schema = %L 
				AND fam.objectclass_id = %L 
				AND fam.parent_attribute_name = %L;
			', qi_usr_schema, qi_view_name, qi_cdb_schema, qi_oc_id, qi_attri_name);
		END IF;
	END IF;
ELSE
	RAISE EXCEPTION 'The sql_attri is null. Please check the existence of attribute values in schema %', cdb_schema;
END IF;

RETURN qi_view_name;

EXCEPTION
	WHEN QUERY_CANCELED THEN
		RAISE EXCEPTION 'qgis_pkg.create_attribute_view(): Error QUERY_CANCELED';
	WHEN OTHERS THEN 
		RAISE EXCEPTION 'qgis_pkg.create_attribute_view(): %', SQLERRM;
END;
$$ LANGUAGE plpgsql;
COMMENT ON FUNCTION qgis_pkg.create_attribute_view(varchar, varchar, integer, text, boolean, varchar, boolean) IS 'Create view or materialized view for the specified attribute';
REVOKE EXECUTE ON FUNCTION qgis_pkg.create_attribute_view(varchar, varchar, integer, text, boolean, varchar, boolean) FROM public;
-- Example
-- SELECT * FROM qgis_pkg.create_attribute_view('qgis_bstsai', 'citydb', 901, 'storeysAboveGround');
-- SELECT * FROM qgis_pkg.create_attribute_view('qgis_bstsai', 'citydb', 901, 'description');
-- SELECT * FROM qgis_pkg.create_attribute_view('qgis_bstsai', 'citydb', 901, 'function');
-- SELECT * FROM qgis_pkg.create_attribute_view('qgis_bstsai', 'citydb', 901, '13_区市町村コード_大字・町コード_町・丁目コード', FALSE, 'db_schema', TRUE);
-- SELECT * FROM qgis_pkg.create_attribute_view('qgis_bstsai', 'citydb', 901, 'function', FALSE, 'db_schema', TRUE);
-- SELECT * FROM qgis_pkg.create_attribute_view('qgis_bstsai', 'citydb', 901, 'name');
-- SELECT * FROM qgis_pkg.create_attribute_view('qgis_bstsai', 'citydb', 901, 'height', 'TRUE');
-- SELECT * FROM qgis_pkg.create_attribute_view('qgis_bstsai', 'citydb', 901, 'height', 'TRUE', 'db_schema', TRUE);
-- SELECT * FROM qgis_pkg.create_attribute_view('qgis_bstsai', 'rh_v5', 709, 'direction', FALSE, 'm_view'); -- void, rh_v5 709-direction does not have any value


----------------------------------------------------------------
-- Create FUNCTION QGIS_PKG.CREATE_ALL_ATTRIBUTE_VIEW_IN_SCHEMA()
----------------------------------------------------------------
DROP FUNCTION IF EXISTS qgis_pkg.create_all_attribute_view_in_schema(varchar, varchar, integer, boolean, varchar);
CREATE OR REPLACE FUNCTION qgis_pkg.create_all_attribute_view_in_schema(
    usr_schema varchar,
	cdb_schema varchar,
    objectclass_id integer DEFAULT NULL,
	is_matview boolean DEFAULT FALSE,
    cdb_bbox_type varchar DEFAULT 'db_schema'
) RETURNS void AS $$
DECLARE
	qi_usr_schema varchar 					:= quote_ident(usr_schema);
    qi_cdb_schema varchar 					:= quote_ident(cdb_schema);
	cdb_bbox_type_array CONSTANT varchar[] 	:= ARRAY['db_schema', 'm_view', 'qgis'];
	oc_id integer := objectclass_id;
	classname text;
	attri_name text;
    start_time TIMESTAMP;
    end_time TIMESTAMP;
    view_type text;
	view_type_pl text;
    r RECORD;

BEGIN

IF is_matview THEN
    view_type := 'Materialized view';
	view_type_pl := 'materialized view(s)';
ELSE
    view_type := 'View';
	view_type_pl := 'view(s)';
END IF;

-- Check that the cdb_box_type is a valid value and get the envelope
IF cdb_bbox_type IS NULL OR NOT (cdb_bbox_type = ANY (cdb_bbox_type_array)) THEN
    RAISE EXCEPTION 'cdb_bbox_type value is invalid. It must be one of (%)', cdb_bbox_type_array;
END IF;

-- Check if feature attribute metadata table exists
IF NOT EXISTS(SELECT 1 FROM information_schema.tables WHERE table_schema = usr_schema AND table_name = 'feature_attribute_metadata') THEN
	RAISE EXCEPTION '%.feature_attribute_metadata table not yet created. Please create it first', qi_usr_schema;
END IF;

IF objectclass_id IS NOT NULL THEN
	classname := (SELECT qgis_pkg.objectclass_id_to_classname(qi_cdb_schema,oc_id));
	-- Create all attribute view or materialized view of the given objectclass_id within the schema
	RAISE NOTICE 'Create all attribute % of % (oc_id = %) in cdb_schema %', view_type_pl, classname, oc_id, cdb_schema;
    FOR r IN
		EXECUTE format('
        SELECT fam.cdb_schema, fam.objectclass_id, fam.classname, fam.parent_attribute_name, fam.attribute_name, fam.is_nested
        FROM %I.feature_attribute_metadata AS fam
        WHERE fam.cdb_schema = %L AND fam.objectclass_id = %L AND fam.is_nested IS FALSE
		UNION ALL
		SELECT DISTINCT fam.cdb_schema, fam.objectclass_id, fam.classname, fam.parent_attribute_name, ''-'' AS attribute_name, fam.is_nested
        FROM %I.feature_attribute_metadata AS fam
        WHERE fam.cdb_schema = %L AND fam.objectclass_id = %L AND fam.is_nested IS TRUE
		', 
		qi_usr_schema, qi_cdb_schema, oc_id,
		qi_usr_schema, qi_cdb_schema, oc_id)
    LOOP
        IF r.is_nested = 'FALSE' THEN
			attri_name := r.attribute_name;
        ELSE
			attri_name := r.parent_attribute_name;
        END IF;
		start_time := clock_timestamp();
		PERFORM qgis_pkg.create_attribute_view(
			qi_usr_schema,
			r.cdb_schema,
			r.objectclass_id,
			attri_name,
			r.is_nested,
			cdb_bbox_type,
			is_matview
		);
		end_time := clock_timestamp();
		RAISE NOTICE '% (cdb_schema: %, classname = %, attribute_name = %) creation time: %', view_type, r.cdb_schema, r.classname, attri_name, end_time - start_time;
    END LOOP;
ELSE
	-- Create all existing attribute view or materialized view within the schema
	RAISE NOTICE 'Create all attribute % in cdb_schema %', view_type_pl, cdb_schema;
    FOR r IN
		EXECUTE format('
        SELECT fam.cdb_schema, fam.objectclass_id, fam.classname, fam.parent_attribute_name, fam.attribute_name, fam.is_nested
        FROM %I.feature_attribute_metadata AS fam
        WHERE fam.cdb_schema = %L AND fam.is_nested IS FALSE
		UNION ALL
		SELECT DISTINCT fam.cdb_schema, fam.objectclass_id, fam.classname, fam.parent_attribute_name, ''-'' AS attribute_name, fam.is_nested
        FROM %I.feature_attribute_metadata AS fam
        WHERE fam.cdb_schema = %L AND fam.is_nested IS TRUE
		',
		qi_usr_schema, qi_cdb_schema,
		qi_usr_schema, qi_cdb_schema)
    LOOP
        IF r.is_nested = 'FALSE' THEN
			attri_name := r.attribute_name;
        ELSE
			attri_name := r.parent_attribute_name;
        END IF;
			start_time := clock_timestamp();
            PERFORM qgis_pkg.create_attribute_view(
                qi_usr_schema,
                r.cdb_schema,
                r.objectclass_id,
                attri_name,
                r.is_nested,
                cdb_bbox_type,
                is_matview
            );
			end_time := clock_timestamp();
            RAISE NOTICE '% (cdb_schema: %, classname = %, attribute_name = %) creation time: %', view_type, r.cdb_schema, r.classname, attri_name, end_time - start_time;
    END LOOP;
END IF;

EXCEPTION
	WHEN QUERY_CANCELED THEN
		RAISE EXCEPTION 'qgis_pkg.create_all_attribute_view_in_schema(): Error QUERY_CANCELED';
	WHEN OTHERS THEN 
		RAISE EXCEPTION 'qgis_pkg.create_all_attribute_view_in_schema(): %', SQLERRM;
END;
$$ LANGUAGE plpgsql;
COMMENT ON FUNCTION qgis_pkg.create_all_attribute_view_in_schema(varchar, varchar, integer, boolean, varchar) IS 'Create all attribute view(s) or materialized view(s) of the objectclass within given schema';
REVOKE EXECUTE ON FUNCTION qgis_pkg.create_all_attribute_view_in_schema(varchar, varchar, integer, boolean, varchar) FROM public;
--Example
-- SELECT * FROM qgis_pkg.create_all_attribute_view_in_schema('qgis_bstsai', 'citydb', 901);
-- SELECT * FROM qgis_pkg.create_all_attribute_view_in_schema('qgis_bstsai', 'citydb', 901, TRUE);
-- SELECT * FROM qgis_pkg.create_all_attribute_view_in_schema('qgis_bstsai', 'citydb');
-- SELECT * FROM qgis_pkg.create_all_attribute_view_in_schema('qgis_bstsai', 'citydb', NULL, TRUE);


----------------------------------------------------------------
-- Create FUNCTION QGIS_PKG.DROP_ATTRIBUTE_VIEW()
----------------------------------------------------------------
-- The function drops the specified attibute view and materialized view of the given objectclass in the given schema
DROP FUNCTION IF EXISTS qgis_pkg.drop_attribute_view(varchar, varchar, integer, text, boolean, boolean);
CREATE OR REPLACE FUNCTION qgis_pkg.drop_attribute_view(
	usr_schema varchar,
	cdb_schema varchar,
	objectclass_id integer,
	attribute_name text,
	is_nested boolean DEFAULT FALSE,
	is_matview boolean DEFAULT FALSE
) 
RETURNS varchar AS $$
DECLARE
	qi_cdb_schema varchar := quote_ident(cdb_schema);
	ql_cdb_schema varchar := quote_literal(cdb_schema);
	qi_usr_schema varchar := quote_ident(usr_schema);
	qi_attri_name varchar := quote_ident(attribute_name);
	ql_attri_name varchar := quote_literal(attribute_name);
	classname text := (SELECT qgis_pkg.objectclass_id_to_classname(qi_cdb_schema, objectclass_id));
	oc_id integer := objectclass_id;
	view_type varchar := (CASE WHEN is_matview THEN 'MATERIALIZED VIEW' ELSE 'VIEW' END);
	av_name varchar;
	sql_del  text := (CASE WHEN is_matview THEN 'mview_name = NULL,mview_refresh_date = NULL, last_modification_date = clock_timestamp()' ELSE '	view_name = NULL,view_creation_date = NULL, last_modification_date = clock_timestamp()' END);
	sql_drop text;
	r RECORD;
	
BEGIN
-- Check if feature attribute metadata table exists
IF NOT EXISTS(SELECT 1 FROM information_schema.tables WHERE table_schema = qi_usr_schema AND table_name = 'feature_attribute_metadata') THEN
	RAISE EXCEPTION '%.feature_attribute_metadata table not yet created. Please create it first', qi_usr_schema;
END IF;

IF NOT is_nested THEN
	-- Inline attribute
	FOR r IN
		EXECUTE format('
		SELECT fam.view_name, fam.mview_name
		FROM %I.feature_attribute_metadata AS fam
		WHERE fam.cdb_schema = %L AND fam.objectclass_id = %L AND fam.attribute_name = %L
		', qi_usr_schema, qi_cdb_schema, oc_id, attribute_name)
	LOOP
		av_name  := (CASE WHEN is_matview THEN r.mview_name ELSE r.view_name END);
		sql_drop := concat('
			DROP ', view_type, ' IF EXISTS ', qi_usr_schema, '.', av_name, 'CASCADE;
			UPDATE ',qi_usr_schema,'.feature_attribute_metadata AS fam SET ', sql_del,'
			WHERE fam.cdb_schema = ',ql_cdb_schema,' AND fam.objectclass_id = ',oc_id,' AND fam.attribute_name = ',ql_attri_name,';
		');
		EXECUTE sql_drop;
		RAISE NOTICE 'Drop % of % in cdb_schema %', LOWER(view_type), av_name, cdb_schema;
	END LOOP;
ELSE
	-- Nested attribute
	FOR r IN
		EXECUTE format(' 
		SELECT fam.view_name, fam.mview_name, fam.ct_type_name
		FROM %I.feature_attribute_metadata AS fam
		WHERE fam.cdb_schema = %L AND fam.objectclass_id = %L AND fam.parent_attribute_name = %L
		LIMIT 1
		', qi_usr_schema, qi_cdb_schema, oc_id, attribute_name)
	LOOP
		av_name  := (CASE WHEN is_matview THEN r.mview_name ELSE r.view_name END);
		sql_drop := concat('
			DROP ', view_type, ' IF EXISTS ', qi_usr_schema, '.', av_name, 'CASCADE;
			UPDATE ',qi_usr_schema,'.feature_attribute_metadata AS fam SET ', sql_del,'
			WHERE fam.cdb_schema = ',ql_cdb_schema,' AND fam.objectclass_id = ',oc_id,' AND fam.parent_attribute_name = ',ql_attri_name,';
		');
		EXECUTE sql_drop;
		RAISE NOTICE 'Drop % of % in cdb_schema %', LOWER(view_type), av_name, cdb_schema;
	END LOOP;
END IF;

RETURN av_name;

EXCEPTION
	WHEN QUERY_CANCELED THEN
		RAISE EXCEPTION 'qgis_drop_attribute_view(): Error QUERY_CANCELED';
  	WHEN OTHERS THEN
		RAISE EXCEPTION 'qgis_drop_attribute_view(): %', SQLERRM;
END;
$$ LANGUAGE plpgsql;
COMMENT ON FUNCTION qgis_pkg.drop_attribute_view(varchar, varchar, integer, text, boolean, boolean) IS 'Drop specified attribute (materialized) views of the given objectclass feature in the schema';
REVOKE EXECUTE ON FUNCTION qgis_pkg.drop_attribute_view(varchar, varchar, integer, text, boolean, boolean) FROM PUBLIC;
-- Example
-- SELECT * FROM qgis_pkg.drop_attribute_view('qgis_bstsai', 'alderaan', 901, 'dateOfConstruction'); -- drop inline attribute view
-- SELECT * FROM qgis_pkg.drop_attribute_view('qgis_bstsai', 'citydb', 901, 'description', FALSE, TRUE); -- drop inline attribute matview
-- SELECT * FROM qgis_pkg.drop_attribute_view('qgis_bstsai', 'citydb', 901, 'height', TRUE); -- drop nested attribute view
-- SELECT * FROM qgis_pkg.drop_attribute_view('qgis_bstsai', 'citydb', 901, 'height', TRUE, TRUE); -- drop nested attribute matview


----------------------------------------------------------------
-- Create FUNCTION QGIS_PKG.DROP_ALL_ATTRIBUTE_VIEWS()
----------------------------------------------------------------
-- The function drops all existing attibute view and materialized view in the given schema
-- If objectclass_id provided, drop all available attribute view and mv of that objectclass_id
-- Otherwise, drop all attibute view in the schema
DROP FUNCTION IF EXISTS qgis_pkg.drop_all_attribute_views(varchar, varchar, integer, boolean);
CREATE OR REPLACE FUNCTION qgis_pkg.drop_all_attribute_views(
	usr_schema varchar,
	cdb_schema varchar,
	objectclass_id integer DEFAULT NULL,
	is_matview boolean DEFAULT FALSE
) 
RETURNS void AS $$
DECLARE
	qi_usr_schema varchar := quote_ident(usr_schema);
	qi_cdb_schema varchar := quote_ident(cdb_schema);
	ql_cdb_schema varchar := quote_literal(cdb_schema);
	view_type varchar := (CASE WHEN is_matview THEN 'MATERIALIZED VIEW' ELSE 'VIEW' END);
	oc_id integer := objectclass_id;
	classname varchar;
	r RECORD;
BEGIN

IF objectclass_id IS NOT NULL THEN
	classname := (SELECT qgis_pkg.objectclass_id_to_classname(qi_cdb_schema, objectclass_id));
	RAISE NOTICE 'Drop all attribute %(s) of % (oc_id = %) in schema %', LOWER(view_type), classname, oc_id, cdb_schema;
	FOR r IN 
		EXECUTE format('
		SELECT fam.attribute_name, fam.is_nested
		FROM %I.feature_attribute_metadata AS fam
		WHERE fam.cdb_schema = %L AND fam.objectclass_id = %L AND fam.is_nested IS FALSE
		UNION ALL		
		SELECT DISTINCT fam.parent_attribute_name AS attribute_name, fam.is_nested
		FROM %I.feature_attribute_metadata AS fam
		WHERE fam.cdb_schema = %L AND fam.objectclass_id = %L AND fam.is_nested IS TRUE
		',
		qi_usr_schema, qi_cdb_schema, oc_id,
		qi_usr_schema, qi_cdb_schema, oc_id)
	LOOP
		PERFORM qgis_pkg.drop_attribute_view(qi_usr_schema, qi_cdb_schema, oc_id, r.attribute_name, r.is_nested, is_matview);
	END LOOP;
ELSE
	RAISE NOTICE 'Drop all attribute %(s) in schema %', LOWER(view_type), cdb_schema;
	FOR r IN
		EXECUTE format('
		SELECT fam.objectclass_id, fam.attribute_name, fam.view_name, fam.mview_name, fam.is_nested
		FROM %I.feature_attribute_metadata AS fam
		WHERE fam.cdb_schema = %L AND fam.is_nested IS FALSE
		UNION ALL		
		SELECT DISTINCT fam.objectclass_id, fam.parent_attribute_name AS attribute_name, fam.view_name, fam.mview_name, fam.is_nested
		FROM %I.feature_attribute_metadata AS fam
		WHERE fam.cdb_schema = %L AND fam.is_nested IS TRUE
		',
		qi_usr_schema, qi_cdb_schema,
		qi_usr_schema, qi_cdb_schema)
	LOOP
		PERFORM qgis_pkg.drop_attribute_view(qi_usr_schema, qi_cdb_schema, r.objectclass_id, r.attribute_name, r.is_nested, is_matview);
	END LOOP;
END IF;

EXCEPTION
	WHEN QUERY_CANCELED THEN
		RAISE EXCEPTION 'qgis_pkg.drop_all_attribute_views: Error QUERY_CANCELED';
  	WHEN OTHERS THEN
		RAISE EXCEPTION 'qgis_pkg.drop_all_attribute_views: %', SQLERRM;
END;
$$ LANGUAGE plpgsql;
COMMENT ON FUNCTION qgis_pkg.drop_all_attribute_views(varchar, varchar, integer, boolean) IS 'If objectclass_id provided, drop all available attribute view and mv of that objectclass_id. Otherwise, drop all attibute view in the schema';
REVOKE EXECUTE ON FUNCTION qgis_pkg.drop_all_attribute_views(varchar, varchar, integer, boolean) FROM PUBLIC;
--Example
-- SELECT * FROM qgis_pkg.drop_all_attribute_views('qgis_bstsai', 'citydb', 901); -- drop all 901 attribute views in citydb schema
-- SELECT * FROM qgis_pkg.drop_all_attribute_views('qgis_bstsai', 'citydb', 901, TRUE); -- drop all attribute matviews in citydb schema
-- SELECT * FROM qgis_pkg.drop_all_attribute_views('qgis_bstsai', 'alderaan'); -- drop all attribute views in citydb schema
-- SELECT * FROM qgis_pkg.drop_all_attribute_views('qgis_bstsai', 'alderaan', NULL, TRUE); -- drop all attribute matviews in citydb schema
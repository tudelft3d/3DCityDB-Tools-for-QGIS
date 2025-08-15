-- ***********************************************************************
--
-- This script installs a set of functions into qgis_pkg schema
-- List of functions:
--
-- qgis_pkg.check_feature_inline_attribute()
-- qgis_pkg.check_feature_nested_attribute()
-- qgis_pkg.update_feature_attribute_metadata()
--
-- ***********************************************************************

----------------------------------------------------------------
-- Create FUNCTION QGIS_PKG.CHECK_FEATURE_INLINE_ATTRIBUTE
----------------------------------------------------------------
--  The function scans the given cdb_schema and update the metadata table
--  "qgis_pkg.feature_attribute_metadata" with all available "inline" attributes
DROP FUNCTION IF EXISTS qgis_pkg.check_feature_inline_attribute(varchar, varchar, integer, text, varchar) CASCADE;
CREATE OR REPLACE FUNCTION qgis_pkg.check_feature_inline_attribute(
    usr_schema varchar,
	cdb_schema varchar,
    objectclass_id integer,
    attribute_name text,
    cdb_bbox_type varchar DEFAULT 'db_schema'
) 
RETURNS void AS $$
DECLARE
    qi_usr_schema varchar := quote_ident(usr_schema);
	qi_cdb_schema varchar := quote_ident(cdb_schema);
    objectclass_name varchar;
    attri_typename varchar;
    attri_datatype_id integer;
    attri_label varchar DEFAULT 'Inline';
    is_nested varchar DEFAULT 'FALSE';
    sql_insert_header text;
    sql_insert_value text;
    sql_inline_attri text;
BEGIN
-- Check if feature attribute metadata table exists
IF NOT EXISTS(SELECT 1 FROM information_schema.tables WHERE table_schema = qi_usr_schema AND table_name = 'feature_attribute_metadata') THEN
	RAISE EXCEPTION '%.feature_attribute_metadata table not yet created. Please create it first', qi_usr_schema;
END IF;

-- Get objectclass name
EXECUTE format ('SELECT * FROM qgis_pkg.objectclass_id_to_classname(%L,%s)', qi_cdb_schema, objectclass_id) INTO objectclass_name;
-- Get attribute datatype_id
EXECUTE format ('SELECT qgis_pkg.attribute_name_to_datatype_id(%L,%s,%L,%L)', qi_cdb_schema, objectclass_id, attribute_name, is_nested) INTO attri_datatype_id;
-- Get attribute typename
EXECUTE format ('SELECT adl.typename FROM qgis_pkg.attribute_datatype_lookup AS adl WHERE adl.id = %s', attri_datatype_id) INTO attri_typename;

sql_insert_header := '
    cdb_schema,
    bbox_type, 
    objectclass_id,
    classname,
    parent_attribute_name, 
    parent_attribute_typename,
    attribute_name, 
    attribute_typename, 
    is_nested,
	last_modification_date
';
sql_insert_value := concat('
    ',quote_literal(cdb_schema),',
    ',quote_literal(cdb_bbox_type),',
    ',objectclass_id,',
    ',quote_literal(objectclass_name),',
    ''-'',
    ''-'',
    ',quote_literal(attribute_name),',
    ',quote_literal(attri_typename),',
    ',quote_literal(is_nested),',
	clock_timestamp()
');

sql_inline_attri := concat('
    INSERT INTO ',qi_usr_schema,'.feature_attribute_metadata (',sql_insert_header,') 
    VALUES (',sql_insert_value,') 
    ON CONFLICT (cdb_schema, objectclass_id, classname, parent_attribute_name, attribute_name) 
    DO UPDATE SET last_modification_date = clock_timestamp();
');
EXECUTE sql_inline_attri;
RAISE NOTICE '% attribute "%" of "%" class (oc_id = % in schema "%") is checked', attri_label, attribute_name, objectclass_name, objectclass_id, cdb_schema;

EXCEPTION
	WHEN QUERY_CANCELED THEN
		RAISE EXCEPTION 'qgis_pkg.check_feature_inline_attribute(): Error QUERY_CANCELED';
	WHEN OTHERS THEN
		RAISE EXCEPTION 'qgis_pkg.check_feature_inline_attribute(): %', SQLERRM;
END;
$$ LANGUAGE plpgsql;
COMMENT ON FUNCTION qgis_pkg.check_feature_inline_attribute(varchar, varchar, integer, text, varchar) IS 'Check the existence of "inline" attributes of the given feature objectclass_id';
REVOKE EXECUTE ON FUNCTION qgis_pkg.check_feature_inline_attribute(varchar, varchar, integer, text, varchar) FROM PUBLIC;


----------------------------------------------------------------
-- Create FUNCTION QGIS_PKG.CHECK_FEATURE_NESTED_ATTRIBUTE
----------------------------------------------------------------
--  The function scans the given cdb_schema and update the metadata table
--  "qgis_pkg.feature_attribute_metadata" with all available "nested" attributes
DROP FUNCTION IF EXISTS qgis_pkg.check_feature_nested_attribute(varchar, varchar, integer, text, text, varchar) CASCADE;
CREATE OR REPLACE FUNCTION qgis_pkg.check_feature_nested_attribute(
    usr_schema varchar,
	cdb_schema varchar,
    objectclass_id integer,
    parent_attribute_name text,
    attribute_name text,
    cdb_bbox_type varchar DEFAULT 'db_schema'
) 
RETURNS VOID AS $$
DECLARE
    qi_usr_schema varchar := quote_ident(usr_schema);
	qi_cdb_schema varchar := quote_ident(cdb_schema);
    objectclass_name varchar;
    p_attri_typename varchar;
    attri_typename varchar;
    p_attri_datatype_id integer;
    attri_datatype_id integer;
    attri_label varchar DEFAULT 'Nested-Single';
    is_nested varchar DEFAULT 'TRUE';
    is_multiple varchar DEFAULT 'FALSE';
    max_multiplicity integer DEFAULT NULL;
    is_multiple_value_columns varchar DEFAULT NULL;
    n_value_columns integer DEFAULT NULL;
    value_column text[] DEFAULT NULL;
    sql_insert_header text;
    sql_insert_value text;
    sql_nested_attri text;
BEGIN
-- Check if feature attribute metadata table exists
IF NOT EXISTS(SELECT 1 FROM information_schema.tables WHERE table_schema = qi_usr_schema AND table_name = 'feature_attribute_metadata') THEN
	RAISE EXCEPTION '%.feature_attribute_metadata table not yet created. Please create it first', qi_usr_schema;
END IF;

-- Get objectclass name
EXECUTE format ('SELECT * FROM qgis_pkg.objectclass_id_to_classname(%L,%s)', qi_cdb_schema, objectclass_id) INTO objectclass_name;
-- Get parent attribute datatype_id
EXECUTE format ('SELECT qgis_pkg.attribute_name_to_datatype_id(%L,%s,%L,%L)', qi_cdb_schema, objectclass_id, parent_attribute_name, is_nested) INTO p_attri_datatype_id;
-- Get parent attribute typename
EXECUTE format ('SELECT adl.typename FROM qgis_pkg.attribute_datatype_lookup AS adl WHERE adl.id = %s', p_attri_datatype_id) INTO p_attri_typename;

-- Get attribute datatype_id
EXECUTE format ('SELECT qgis_pkg.attribute_name_to_datatype_id(%L,%s,%L,%L)', qi_cdb_schema, objectclass_id, attribute_name, 'FALSE') INTO attri_datatype_id;
-- Get attribute typename
EXECUTE format ('SELECT adl.typename FROM qgis_pkg.attribute_datatype_lookup AS adl WHERE adl.id = %s', attri_datatype_id) INTO attri_typename;


sql_insert_header := '
    cdb_schema,
    bbox_type, 
    objectclass_id,
    classname,
    parent_attribute_name, 
    parent_attribute_typename,
    attribute_name, 
    attribute_typename, 
    is_nested,
    last_modification_date
';
sql_insert_value := concat('
    ',quote_literal(cdb_schema),',
    ',quote_literal(cdb_bbox_type),',
    ',objectclass_id,',
    ',quote_literal(objectclass_name),',
    ',quote_literal(parent_attribute_name),',
    ',quote_literal(p_attri_typename),',
    ',quote_literal(attribute_name),',
    ',quote_literal(attri_typename),',
    ',quote_literal(is_nested),',
    clock_timestamp()
');

sql_nested_attri := concat('
    INSERT INTO ',qi_usr_schema,'.feature_attribute_metadata (',sql_insert_header,') 
    VALUES (',sql_insert_value,') 
    ON CONFLICT (cdb_schema, objectclass_id, classname, parent_attribute_name, attribute_name) 
    DO UPDATE SET last_modification_date = clock_timestamp();
');
EXECUTE sql_nested_attri;

RAISE NOTICE '% attribute "%-%" of "%" class (oc_id = % in schema "%") is checked', attri_label, parent_attribute_name, attribute_name, objectclass_name, objectclass_id, cdb_schema;

EXCEPTION
	WHEN QUERY_CANCELED THEN
		RAISE EXCEPTION 'qgis_pkg.check_feature_nested_attribute(): Error QUERY_CANCELED';
	WHEN OTHERS THEN
		RAISE EXCEPTION 'qgis_pkg.check_feature_nested_attribute(): %', SQLERRM;
END;
$$ LANGUAGE plpgsql;
COMMENT ON FUNCTION qgis_pkg.check_feature_nested_attribute(varchar, varchar, integer, text, text, varchar) IS 'Check the existence of "nested" attributes of the given feature objectclass_id';
REVOKE EXECUTE ON FUNCTION qgis_pkg.check_feature_nested_attribute(varchar, varchar, integer, text, text, varchar) FROM PUBLIC;


----------------------------------------------------------------
-- Create FUNCTION QGIS_PKG.UPDATE_FEATURE_ATTRIBUTE_METADATA
----------------------------------------------------------------
--  The function check all the existing attributes based on "is_nested" indicator
--  The attributes will be classified as "inline" or "nested" types, it then provides the general menu
--  for the qgis_pkg.create_attribute_view function to call corresponding collect attribute functions for attribute extraction
DROP FUNCTION IF EXISTS qgis_pkg.update_feature_attribute_metadata(varchar, varchar, varchar) CASCADE;
CREATE OR REPLACE FUNCTION qgis_pkg.update_feature_attribute_metadata(
	usr_schema varchar,
	cdb_schema varchar,
    cdb_bbox_type varchar DEFAULT 'db_schema'
) 
RETURNS varchar AS $$
DECLARE
    cdb_bbox_type_array CONSTANT varchar[]	:= ARRAY['db_schema', 'm_view', 'qgis']; cdb_envelope geometry; srid integer;
	qi_usr_schema varchar 			        := quote_ident(usr_schema);
	qi_cdb_schema varchar 			        := quote_ident(cdb_schema);
    oc_ids integer[]; oc_id integer;
    oc_id_inline_attris text[]; oc_id_inline_attri  text;
    oc_id_nested_attris text[][]; oc_id_nested_attri  text[];
    inline_attri_count integer; nested_attri_count integer;
    geom_datatype_id integer; 
    implicit_geom_datatype_id integer;
	feature_datatype_id integer;
	address_datatype_id integer;
	appearance_datatype_id integer;
    nested_attri_ids text;
	iter_count integer := 1;
    sql_oc_ids text;
    sql_oc_id_attris text;
    sql_where text;

BEGIN
-- Check if cdb_name exists
IF qi_cdb_schema IS NULL or NOT EXISTS(SELECT 1 FROM information_schema.schemata AS i WHERE i.schema_name::varchar = qi_cdb_schema) THEN
	RAISE EXCEPTION 'cdb_schema (%) not found. It must be an existing schema', qi_cdb_schema;
END IF;

-- Check that the cdb_box_type is a valid value
IF cdb_bbox_type IS NULL OR NOT (cdb_bbox_type = ANY (cdb_bbox_type_array)) THEN
	RAISE EXCEPTION 'cdb_bbox_type value is invalid. It must be one of (%)', cdb_bbox_type_array;
END IF;

-- Get the srid from the cdb_schema
EXECUTE format('SELECT srid FROM %I.database_srs LIMIT 1', cdb_schema) INTO srid;
-- Get the cdb_envelope from the extents table in the usr_schema
EXECUTE format ('SELECT envelope FROM %I.extents WHERE cdb_schema = %L AND bbox_type = %L', qi_usr_schema, qi_cdb_schema, cdb_bbox_type) INTO cdb_envelope;

-- Check whether the retrived extent exists 
IF cdb_envelope IS NULL THEN
	RAISE EXCEPTION 'cdb_envelope is invalid. Please first upsert the extent of cdb_bbox_type: %', cdb_bbox_type;
END IF;
-- Check that the srid is the same if the cdb_envelope
IF ST_SRID(cdb_envelope) IS NULL OR ST_SRID(cdb_envelope) <> srid OR cdb_bbox_type = 'db_schema' THEN
	sql_where := NULL;
ELSE
	sql_where := concat(' AND ST_MakeEnvelope(',ST_XMin(cdb_envelope),',',ST_YMin(cdb_envelope),',',ST_XMax(cdb_envelope),',',ST_YMax(cdb_envelope),',',srid,') && f.envelope ');
END IF;

-- Get the datatype_id of GeometryProperty , ImplicitGeometryProperty
EXECUTE format('SELECT * FROM qgis_pkg.datatype_name_to_type_id(%L, %L)', qi_cdb_schema, 'GeometryProperty') INTO geom_datatype_id;
EXECUTE format('SELECT * FROM qgis_pkg.datatype_name_to_type_id(%L, %L)', qi_cdb_schema, 'ImplicitGeometryProperty') INTO implicit_geom_datatype_id;
EXECUTE format('SELECT * FROM qgis_pkg.datatype_name_to_type_id(%L, %L)', qi_cdb_schema, 'FeatureProperty') INTO feature_datatype_id ;
EXECUTE format('SELECT * FROM qgis_pkg.datatype_name_to_type_id(%L, %L)', qi_cdb_schema, 'AddressProperty') INTO address_datatype_id ;
EXECUTE format('SELECT * FROM qgis_pkg.datatype_name_to_type_id(%L, %L)', qi_cdb_schema, 'AppearanceProperty') INTO appearance_datatype_id ;

-- Get the nested attribute datatype_ids
EXECUTE format('SELECT STRING_AGG(adl.id::TEXT, %L) FROM qgis_pkg.attribute_datatype_lookup AS adl WHERE adl.alias NOT IN (%L,%L,%L) AND adl.is_nested = 1',',','dyn','grp','vers') INTO nested_attri_ids;

------------------------------------------
-- SCAN AND INSERT OBJECTCLASS ATTRIBUTES
------------------------------------------
-- Delete all existing records of the specified cdb_schema
EXECUTE format ('DELETE FROM %I.feature_attribute_metadata WHERE cdb_schema = %L', qi_usr_schema, qi_cdb_schema);

-- Schema-wise scan of exisiting objectclass_ids in the given extent and return as an array
-- Exclude 'Versioning', 'Dynamizer', 'CityObjectGroup', 'Appearance' modules
sql_oc_ids := concat('
SELECT ARRAY(
	SELECT 
		DISTINCT objectclass_id
		FROM ',qi_cdb_schema,'.feature AS f
			INNER JOIN ',qi_cdb_schema,'.objectclass AS o ON (f.objectclass_id = o.id ',sql_where,')
			INNER JOIN ',qi_cdb_schema,'.namespace AS n ON o.namespace_id = n.id
		WHERE n.alias NOT IN (''dyn'', ''app'', ''grp'', ''vers'')) AS oc_ids;
');
EXECUTE sql_oc_ids INTO oc_ids;
-- oc_ids := ARRAY[901];

-- Check the existing attributes of each objectclass, excluding the (implicit) geometry, feature, address and appearance attributes (datatype_id 8, 9, 10, 11 & 16)
FOREACH oc_id IN ARRAY oc_ids 
LOOP
    -- First search for inline attributes
    sql_oc_id_attris := concat('
        SELECT 
            ARRAY_AGG( DISTINCT p.name)
        FROM ',qi_cdb_schema,'.feature AS f 
            INNER JOIN ',qi_cdb_schema,'.property AS p ON (f.id = p.feature_id AND f.objectclass_id = ',oc_id,' ',sql_where,')
        WHERE p.parent_id IS NULL
            AND p.datatype_id NOT IN (',geom_datatype_id,',',implicit_geom_datatype_id,',',appearance_datatype_id,',',feature_datatype_id,',', address_datatype_id,',',nested_attri_ids,')
    ');
    EXECUTE sql_oc_id_attris INTO oc_id_inline_attris;
    inline_attri_count := (SELECT ARRAY_LENGTH(oc_id_inline_attris,1));

    -- Second search for nested attributes
    sql_oc_id_attris := concat('
        SELECT 
            ARRAY_AGG(ARRAY[p_attri, attri]) AS nested_attribute_set
        FROM(
            SELECT DISTINCT p.name AS p_attri, p1.name AS attri
            FROM ',qi_cdb_schema,'.feature AS f 
                INNER JOIN ',qi_cdb_schema,'.property AS p ON f.id = p.feature_id AND f.objectclass_id = ',oc_id,' 
					AND p.datatype_id NOT IN (',geom_datatype_id,',',implicit_geom_datatype_id,',',appearance_datatype_id,',',feature_datatype_id,',', address_datatype_id,')',sql_where,'
                INNER JOIN ',qi_cdb_schema,'.property AS p1 ON p.id = p1.parent_id
			ORDER BY p.name, p1.name
        ) AS nested_attribute
    ');
    EXECUTE sql_oc_id_attris INTO oc_id_nested_attris;
    nested_attri_count := (SELECT ARRAY_LENGTH(oc_id_nested_attris,1));

    -- CHECK INLINE ATTRIBUTES
	IF inline_attri_count IS NOT NULL THEN
	    FOREACH oc_id_inline_attri IN ARRAY oc_id_inline_attris
	    LOOP
	        PERFORM qgis_pkg.check_feature_inline_attribute(usr_schema, cdb_schema, oc_id, oc_id_inline_attri, cdb_bbox_type);
	    END LOOP;
	END IF;
    RAISE NOTICE 'oc_id % scanned (cdb_schema: % , extent: %, inline_attribute_num: %) and updated to table %.feature_attribute_metadata', oc_id, qi_cdb_schema, cdb_bbox_type, inline_attri_count, qi_usr_schema;

    -- CHECK NESTED ATTRIBUTES
	IF nested_attri_count IS NOT NULL THEN
        WHILE iter_count <= nested_attri_count
        LOOP
            PERFORM qgis_pkg.check_feature_nested_attribute(usr_schema, cdb_schema, oc_id, oc_id_nested_attris[iter_count][1], oc_id_nested_attris[iter_count][2], cdb_bbox_type);
            iter_count := iter_count + 1;
        END LOOP;
        RAISE NOTICE 'oc_id % scanned (cdb_schema: % , extent: %, nested_attribute_num: %) and updated to table %.feature_attribute_metadata', oc_id, qi_cdb_schema, cdb_bbox_type, nested_attri_count, qi_usr_schema;
        iter_count := 1;
	END IF;
END LOOP;

RETURN cdb_schema;

EXCEPTION
	WHEN QUERY_CANCELED THEN
		RAISE EXCEPTION 'qgis_pkg.update_feature_attribute_metadata(): Error QUERY_CANCELED';
	WHEN OTHERS THEN
		RAISE EXCEPTION 'qgis_pkg.update_feature_attribute_metadata(): %', SQLERRM;
END;
$$ LANGUAGE plpgsql;
COMMENT ON FUNCTION qgis_pkg.update_feature_attribute_metadata(varchar, varchar, varchar) IS 'Check the existence and classify all the available feature attributes in the given cdb_schema';
REVOKE EXECUTE ON FUNCTION qgis_pkg.update_feature_attribute_metadata(varchar, varchar, varchar) FROM PUBLIC;
-- Example
-- SELECT * FROM qgis_pkg.update_feature_attribute_metadata('qgis_bstsai', 'citydb');
-- SELECT * FROM qgis_pkg.update_feature_attribute_metadata('qgis_bstsai', 'alderaan_v5');
-- SELECT * FROM qgis_pkg.update_feature_attribute_metadata('qgis_bstsai', 'rh_v5', 'm_view'); -- 8 secs 959 msecs
-- SELECT * FROM qgis_pkg.update_feature_attribute_metadata('qgis_bstsai', 'vienna_v5');
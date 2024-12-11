-- ***********************************************************************
--
-- This script installs a set of functions into qgis_pkg schema
-- List of functions:
--
-- qgis_pkg.get_geometry_key_id()
-- qgis_pkg.create_geometry_space_feature()
-- qgis_pkg.create_geometry_boundary_feature()
-- qgis_pkg.create_geometry_relief_feature()
-- qgis_pkg.create_geometry_relief_component()
-- qgis_pkg.create_geometry_address()
-- qgis_pkg.create_geometry_view()
-- qgis_pkg.create_all_geometry_view_in_schema()
-- qgis_pkg.refresh_geometry_materialized_view()
-- qgis_pkg.refresh_all_geometry_materialized_view()
-- qgis_pkg.drop_geometry_view()
-- qgis_pkg.drop_all_geometry_views()

-- ***********************************************************************

----------------------------------------------------------------
-- Create FUNCTION QGIS_PKG.GET_GEOMETRY_KEY_ID()
----------------------------------------------------------------
-- The function lookup the primary key id of the given parent_objectclass_id, objectclass_id and geometry_name
DROP FUNCTION IF EXISTS qgis_pkg.get_geometry_key_id(varchar, varchar, integer, integer, varchar, integer);
CREATE OR REPLACE FUNCTION qgis_pkg.get_geometry_key_id(
	usr_schema varchar,
	cdb_schema varchar,
	parent_objectclass_id integer,
	objectclass_id integer,
	geometry_name varchar,
	lod integer
) RETURNS integer AS $$
DECLARE
	qi_usr_schema varchar := quote_ident(usr_schema);
	qi_cdb_schema varchar := quote_ident(cdb_schema);
	ql_cdb_schema varchar := quote_literal(cdb_schema);
	ql_geom_name  varchar := quote_literal(geometry_name);
	p_oc_id integer := parent_objectclass_id;
	oc_id integer := objectclass_id;
	parent_classname text;
	classname text;
	target_class text;
    sql_geom_id text;
    geom_id integer;
BEGIN

-- Check if feature geometry metadata table exists
IF NOT EXISTS(SELECT 1 FROM information_schema.tables WHERE table_schema = qi_usr_schema AND table_name = 'feature_geometry_metadata') THEN
	RAISE EXCEPTION '%.feature_geometry_metadata table not yet created. Please create it first', qi_usr_schema;
END IF;

-- Check if cdb_schema exists
IF qi_cdb_schema IS NULL or NOT EXISTS(SELECT 1 FROM information_schema.schemata AS i WHERE i.schema_name::varchar = qi_cdb_schema) THEN
	RAISE EXCEPTION 'cdb_schema (%) not found. It must be an existing schema', qi_cdb_schema;
END IF;

IF p_oc_id <> 0 THEN
	parent_classname := (SELECT qgis_pkg.objectclass_id_to_classname(qi_cdb_schema, p_oc_id));
	classname := (SELECT qgis_pkg.objectclass_id_to_classname(qi_cdb_schema, oc_id));
	target_class := concat(parent_classname, '_', classname);
ELSE
	classname := (SELECT qgis_pkg.objectclass_id_to_classname(qi_cdb_schema, oc_id));
	target_class := classname;
END IF;
	
sql_geom_id := concat('
SELECT fgm.id AS geom_id
FROM ',qi_usr_schema,'.feature_geometry_metadata AS fgm
WHERE fgm.cdb_schema = ',ql_cdb_schema,' 
	AND fgm.parent_objectclass_id = ',p_oc_id,' AND fgm.objectclass_id = ',oc_id,' AND fgm.geometry_name = ',ql_geom_name,' AND fgm.lod = ',lod,'::text;
');
EXECUTE sql_geom_id INTO geom_id;
	
IF geom_id IS NULL THEN
	RAISE EXCEPTION 'The geometry id of % (p_oc_id = %, oc_id = %) in % can not be found! Please check if the existence of the geometry name in schema %', target_class, p_oc_id, oc_id, geometry_name, cdb_schema;
ELSE
	RETURN geom_id;
END IF;

EXCEPTION
	WHEN QUERY_CANCELED THEN
		RAISE EXCEPTION 'qgis_pkg.get_geometry_key_id(): Error QUERY_CANCELED';
	WHEN OTHERS THEN 
		RAISE EXCEPTION 'qgis_pkg.get_geometry_key_id(): %', SQLERRM;
END;
$$ LANGUAGE plpgsql;
COMMENT ON FUNCTION qgis_pkg.get_geometry_key_id(varchar, varchar, integer, integer, varchar, integer) IS 'Lookup the primary key id of the given geometry name.';
REVOKE EXECUTE ON FUNCTION qgis_pkg.get_geometry_key_id(varchar, varchar, integer, integer, varchar, integer) FROM public;
-- Example
-- SELECT * FROM qgis_pkg.get_geometry_key_id('qgis_bstsai','citydb', 0, 901, 'lod1Solid');
-- SELECT * FROM qgis_pkg.get_geometry_key_id('qgis_bstsai','citydb', 901, 709, 'lod2MultiSurface');
-- SELECT * FROM qgis_pkg.get_geometry_key_id('qgis_bstsai','citydb', 0, 901, 'lod2Solid');
-- SELECT * FROM qgis_pkg.get_geometry_key_id('qgis_bstsai','vienna_v5', 0, 502, 'tin', 2);
-- SELECT * FROM qgis_pkg.get_geometry_key_id('qgis_bstsai','citydb', 901, 709, 'lod1MultiSurface'); -- error test


----------------------------------------------------------------
-- Create FUNCTION QGIS_PKG.CREATE_GEOMETRY_SPACE_FEATURE()
----------------------------------------------------------------
--  The function returns the sql for creating geometry view of space feature
DROP FUNCTION IF EXISTS qgis_pkg.create_geometry_space_feature(varchar, integer, text, text, integer, integer, text, boolean);
CREATE OR REPLACE FUNCTION qgis_pkg.create_geometry_space_feature(
	cdb_schema varchar,
    objectclass_id integer,
    geometry_name text,
    postgis_geom_type text,
    geometry_datatype_id integer,
    srid integer,
    sql_where text,
    is_count boolean DEFAULT FALSE -- TRUE to return count sql
) 
RETURNS text AS $$
DECLARE
	qi_cdb_schema varchar  	:= quote_ident(cdb_schema);
    ql_geom_name text      	:= quote_literal(geometry_name);
    ql_p_geom_type text  	:= quote_literal(postgis_geom_type);
    oc_id integer := objectclass_id;
    geom_datatype_id integer;
    implicit_geom_datatype_id integer;
	sql_space_feat_geom text;
	sql_space_feat_implicit_geom text;
    sql_space_feat_count text;
	sql_geom_type_cast text;
BEGIN
-- Get the necessary datatype_ids
EXECUTE format('SELECT * FROM qgis_pkg.datatype_name_to_type_id(%L, %L)', qi_cdb_schema, 'GeometryProperty') INTO geom_datatype_id;
EXECUTE format('SELECT * FROM qgis_pkg.datatype_name_to_type_id(%L, %L)', qi_cdb_schema, 'ImplicitGeometryProperty') INTO implicit_geom_datatype_id;

-- This is created tailor for the "PolyhedralSurfaceZ" in PostGIS to be converted to MultiSurfaceZ for the inspection in QGIS
IF postgis_geom_type = 'PolyhedralSurfaceZ' THEN
	sql_geom_type_cast := concat('ST_CollectionExtract(g.geometry::geometry(',ql_p_geom_type,',',srid,')::geometry, 3)');
ELSE
	sql_geom_type_cast := concat('g.geometry::geometry(',ql_p_geom_type,',',srid,')');
END IF;
	
sql_space_feat_geom := concat('
SELECT
	f.id::bigint 			AS f_id,
	f.objectid::text 	 	AS f_object_id,
	',sql_geom_type_cast,' AS geom
    --	g.geometry::geometry 	AS geom
FROM ',qi_cdb_schema,'.property AS p
	INNER JOIN ',qi_cdb_schema,'.feature AS f ON (p.feature_id = f.id AND f.objectclass_id = ',oc_id,' AND 
			p.val_geometry_id IS NOT NULL AND p.name = ',ql_geom_name,'',sql_where,')
	INNER JOIN ',qi_cdb_schema,'.geometry_data AS g ON (p.val_geometry_id = g.id AND g.geometry IS NOT NULL);
-- ORDER BY f.id ASC;
');

sql_space_feat_implicit_geom := concat('
SELECT 
    f.id::bigint			AS f_id,
    f.objectid::text 	 	AS f_object_id,
    st_setsrid(
            st_translate(
                    st_affine(
                            g.implicit_geometry,
                            (val_array->>0)::double precision,
                            (val_array->>1)::double precision,
                            (val_array->>2)::double precision,
                            (val_array->>4)::double precision,
                            (val_array->>5)::double precision,
                            (val_array->>6)::double precision,
                            (val_array->>8)::double precision,
                            (val_array->>9)::double precision,
                            (val_array->>10)::double precision,
                            (val_array->>3)::double precision,
                            (val_array->>7)::double precision,
                            (val_array->>11)::double precision
                            ),
                    st_x(p.val_implicitgeom_refpoint),
                    st_y(p.val_implicitgeom_refpoint),
                    st_z(p.val_implicitgeom_refpoint)
                    ),
                    ',srid,'
            )::geometry(',ql_p_geom_type,',',srid,') AS geom
FROM ',qi_cdb_schema,'.property p
		INNER JOIN ',qi_cdb_schema,'.feature AS f ON (p.feature_id = f.id AND f.objectclass_id = ', oc_id,' AND 
            p.name = ',ql_geom_name,' AND p.val_implicitgeom_id IS NOT NULL',sql_where,')
		INNER JOIN ',qi_cdb_schema,'.implicit_geometry AS ig ON (p.val_implicitgeom_id = ig.id AND p.val_implicitgeom_id IS NOT NULL)
		INNER JOIN ',qi_cdb_schema,'.geometry_data AS g ON ig.relative_geometry_id = g.id
		AND g.implicit_geometry IS NOT NULL;
-- ORDER BY f.id ASC;
');

sql_space_feat_count := concat('
SELECT
	COUNT(f.id) AS n_feature
FROM ',qi_cdb_schema,'.property AS p
	INNER JOIN ',qi_cdb_schema,'.feature AS f ON (
		p.feature_id = f.id AND 
		f.objectclass_id = ',oc_id,'',sql_where,' AND 
		p.name = ',ql_geom_name,' 
		AND (p.val_geometry_id IS NOT NULL OR p.val_implicitgeom_id IS NOT NULL));
');

IF NOT is_count THEN
    IF geometry_datatype_id = geom_datatype_id THEN
        RETURN sql_space_feat_geom;
    ELSIF geometry_datatype_id = implicit_geom_datatype_id THEN
        RETURN sql_space_feat_implicit_geom;
    ELSE
        RAISE NOTICE 'Error, invalid geometry datatype_id';
    END IF;
ELSE
    RETURN sql_space_feat_count;
END IF;

EXCEPTION
	WHEN QUERY_CANCELED THEN
		RAISE EXCEPTION ' qgis_pkg.create_geometry_space_feature(): Error QUERY_CANCELED';
  	WHEN OTHERS THEN
		RAISE EXCEPTION ' qgis_pkg.create_geometry_space_feature(): %', SQLERRM;
END;
$$ LANGUAGE plpgsql;
COMMENT ON FUNCTION qgis_pkg.create_geometry_space_feature(varchar, integer, text, text, integer, integer, text, boolean) IS 'Create sql for creating geometry view of space feature';
REVOKE EXECUTE ON FUNCTION qgis_pkg.create_geometry_space_feature(varchar, integer, text, text, integer, integer, text, boolean) FROM PUBLIC;
-- Example
-- SELECT * FROM qgis_pkg.create_geometry_space_feature('citydb', 901, 'lod1Solid', 'POLYHEDRALSURFACEZ', 11, 28992, NULL);
-- SELECT * FROM qgis_pkg.create_geometry_space_feature('citydb', 901, 'lod1Solid', 'POLYHEDRALSURFACEZ', 11, 28992, NULL, TRUE);


----------------------------------------------------------------
-- Create FUNCTION QGIS_PKG.CREATE_GEOMETRY_BOUNDARY_FEATURE()
----------------------------------------------------------------
--  The function returns the sql for creating geometry view of boundary feature
DROP FUNCTION IF EXISTS qgis_pkg.create_geometry_boundary_feature(varchar, integer, integer, text, text, integer, integer, text, boolean);
CREATE OR REPLACE FUNCTION qgis_pkg.create_geometry_boundary_feature(
	cdb_schema varchar,
    parent_objectclass_id integer,
    objectclass_id integer,
    geometry_name text,
    postgis_geom_type text,
    geometry_datatype_id integer,
    srid integer,
    sql_where text,
    is_count boolean DEFAULT FALSE -- TRUE to return count sql
) 
RETURNS text AS $$
DECLARE
	qi_cdb_schema varchar  	:= quote_ident(cdb_schema);
    ql_geom_name text      	:= quote_literal(geometry_name);
	ql_p_geom_type text 	:= quote_literal(postgis_geom_type);
    p_oc_id integer := parent_objectclass_id;
    oc_id integer := objectclass_id;
    geom_datatype_id integer;
	sql_boundary_feat_geom text;
    sql_boundary_count text;
BEGIN
-- Get the necessary datatype_ids
EXECUTE format('SELECT * FROM qgis_pkg.datatype_name_to_type_id(%L, %L)', qi_cdb_schema, 'GeometryProperty') INTO geom_datatype_id;

sql_boundary_feat_geom := concat('
SELECT
	f1.id::bigint 			AS f_id,
  	f1.objectid::text  		AS f_object_id,
	g.geometry::geometry(',ql_p_geom_type,',',srid,') AS geom
    --	g.geometry::geometry 	AS geom
FROM ', qi_cdb_schema,'.feature AS f
	INNER JOIN ',qi_cdb_schema,'.property AS p ON (f.id = p.feature_id AND p.name = ''boundary'' AND f.objectclass_id = ', p_oc_id,')
	INNER JOIN ',qi_cdb_schema,'.feature AS f1 ON f1.id = p.val_feature_id
	INNER JOIN ',qi_cdb_schema,'.property AS p1 ON (f1.id = p1.feature_id AND f1.objectclass_id = ', oc_id,' ',sql_where,' AND p1.datatype_id = ',geom_datatype_id,' AND p1.name = ',ql_geom_name,')
	INNER JOIN ',qi_cdb_schema,'.geometry_data AS g ON (p1.val_geometry_id = g.id AND g.geometry IS NOT NULL);
-- ORDER BY f1.id ASC;
');
sql_boundary_count := concat('
SELECT
	COUNT(f1.id) AS n_feature
FROM ', qi_cdb_schema,'.feature AS f
	INNER JOIN ',qi_cdb_schema,'.property AS p ON (f.id = p.feature_id AND p.name = ''boundary'' AND f.objectclass_id = ', p_oc_id,'',sql_where,')
	INNER JOIN ',qi_cdb_schema,'.feature AS f1 ON f1.id = p.val_feature_id
	INNER JOIN ',qi_cdb_schema,'.property AS p1 ON (f1.id = p1.feature_id AND f1.objectclass_id = ',oc_id,' AND p1.datatype_id = ',geom_datatype_id,' AND p1.name = ',ql_geom_name,');
');

IF NOT is_count THEN
    IF geometry_datatype_id = geom_datatype_id THEN
        RETURN sql_boundary_feat_geom;
    ELSE
        RAISE NOTICE 'Error, invalid geometry datatype_id';
    END IF;
ELSE
    RETURN sql_boundary_count;
END IF;
    
EXCEPTION
	WHEN QUERY_CANCELED THEN
		RAISE EXCEPTION ' qgis_pkg.create_geometry_boundary_feature(): Error QUERY_CANCELED';
  	WHEN OTHERS THEN
		RAISE EXCEPTION ' qgis_pkg.create_geometry_boundary_feature(): %', SQLERRM;
END;
$$ LANGUAGE plpgsql;
COMMENT ON FUNCTION qgis_pkg.create_geometry_boundary_feature(varchar, integer ,integer, text, text, integer, integer, text, boolean) IS 'Create sql for creating geometry view of boundary feature';
REVOKE EXECUTE ON FUNCTION qgis_pkg.create_geometry_boundary_feature(varchar, integer, integer, text, text, integer, integer, text, boolean) FROM PUBLIC;
-- Example
-- SELECT * FROM qgis_pkg.create_geometry_boundary_feature('citydb', 901, 709, 'lod2MultiSurface', 'MULTIPOLYGONZ', 11, 28992, NULL);
-- SELECT * FROM qgis_pkg.create_geometry_boundary_feature('citydb', 901, 709, 'lod2MultiSurface', 'MULTIPOLYGONZ', 11, 28992, NULL, TRUE);


----------------------------------------------------------------
-- Create FUNCTION QGIS_PKG.CREATE_GEOMETRY_RELIEF_FEATURE()
----------------------------------------------------------------
--  The function returns the sql for creating geometry view of relief feature
DROP FUNCTION IF EXISTS qgis_pkg.create_geometry_relief_feature(varchar, integer, text, text, text, integer, text, boolean);
CREATE OR REPLACE FUNCTION qgis_pkg.create_geometry_relief_feature(
	cdb_schema varchar,
    objectclass_id integer,
    geometry_name text,
    postgis_geom_type text,
    lod text,
    srid integer,
    sql_where text,
    is_count boolean DEFAULT FALSE -- TRUE to return count sql
) 
RETURNS text AS $$
DECLARE
	qi_cdb_schema varchar   := quote_ident(cdb_schema);
    ql_geom_name text       := quote_literal(geometry_name);
    ql_p_geom_type text     := quote_literal(postgis_geom_type);
    ql_lod text             := quote_literal(lod);
    oc_id integer           := objectclass_id;
	sql_relief_feat_geom text;
    sql_relief_feat_count text;
BEGIN

sql_relief_feat_geom := concat('
SELECT
	f.id::bigint 									    AS f_id,
	f.objectid::text 	 							    AS f_object_id,			 
	f.envelope::geometry(',ql_p_geom_type,',',srid,') 	AS geom
FROM ',qi_cdb_schema,'.property p
	INNER JOIN ',qi_cdb_schema,'.feature f ON (p.feature_id = f.id AND f.objectclass_id = ', oc_id,' AND 
		p.val_int = ',ql_lod,' AND p.name = ''lod''',sql_where,');
-- ORDER BY f.id ASC;
');

sql_relief_feat_count := concat('
SELECT
	COUNT(f.id) AS n_feature		 
FROM ',qi_cdb_schema,'.property p
	INNER JOIN ',qi_cdb_schema,'.feature f ON (p.feature_id = f.id AND f.objectclass_id = ', oc_id,' AND 
		p.val_int = ',ql_lod,' AND p.name = ''lod''',sql_where,');
');

IF NOT is_count THEN
    RETURN sql_relief_feat_geom;
ELSE
    RETURN sql_relief_feat_count;
END IF;
    
EXCEPTION
	WHEN QUERY_CANCELED THEN
		RAISE EXCEPTION ' qgis_pkg.create_geometry_relief_feature(): Error QUERY_CANCELED';
  	WHEN OTHERS THEN
		RAISE EXCEPTION ' qgis_pkg.create_geometry_relief_feature(): %', SQLERRM;
END;
$$ LANGUAGE plpgsql;
COMMENT ON FUNCTION qgis_pkg.create_geometry_relief_feature(varchar, integer, text, text, text, integer, text, boolean) IS 'Create sql for creating geometry view of relief feature';
REVOKE EXECUTE ON FUNCTION qgis_pkg.create_geometry_relief_feature(varchar, integer, text, text, text, integer, text, boolean) FROM PUBLIC;
-- Example
-- SELECT * FROM qgis_pkg.create_geometry_relief_feature('citydb', 500, 'lod', 'POLYGONZ', '1', 28992, NULL);
-- SELECT * FROM qgis_pkg.create_geometry_relief_feature('citydb', 500, 'lod', 'POLYGONZ', '1', 28992, NULL, TRUE);


----------------------------------------------------------------
-- Create FUNCTION QGIS_PKG.CREATE_GEOMETRY_RELIEF_COMPONENT()
----------------------------------------------------------------
--  The function returns the sql for creating geometry view of relief feature
DROP FUNCTION IF EXISTS qgis_pkg.create_geometry_relief_component(varchar, integer, text, text, text, integer, text, boolean);
CREATE OR REPLACE FUNCTION qgis_pkg.create_geometry_relief_component(
	cdb_schema varchar,
    objectclass_id integer,
    geometry_name text,
    postgis_geom_type text,
    lod text,
    srid integer,
    sql_where text,
    is_count boolean DEFAULT FALSE -- TRUE to return count sql
) 
RETURNS text AS $$
DECLARE
	qi_cdb_schema varchar   := quote_ident(cdb_schema);
    ql_geom_name text       := quote_literal(geometry_name);
    ql_p_geom_type text     := quote_literal(postgis_geom_type);
    ql_lod text             := quote_literal(lod);
    oc_id integer           := objectclass_id;
	sql_relief_compon_geom text;
    sql_relief_compon_count text;
BEGIN

sql_relief_compon_geom := concat('
SELECT
	f.id::bigint 			AS f_id,
	f.objectid::text 	 	AS f_object_id,
	g.geometry::geometry(',ql_p_geom_type,',',srid,') AS geom
--	g.geometry 	 			AS geom
FROM ',qi_cdb_schema,'.property AS p
	INNER JOIN ',qi_cdb_schema,'.feature AS f ON (p.feature_id = f.id AND f.objectclass_id = ', oc_id,' AND 
		p.name = ',ql_geom_name,' AND p.val_lod = ',ql_lod,'::text ',sql_where,')
	INNER JOIN ',qi_cdb_schema,'.geometry_data AS g ON (p.val_geometry_id = g.id AND g.geometry IS NOT NULL);
-- ORDER BY f.id ASC;
');

sql_relief_compon_count := concat('
SELECT
	COUNT(f.id) AS n_feature
FROM ',qi_cdb_schema,'.property AS p
	INNER JOIN ',qi_cdb_schema,'.feature AS f ON (p.feature_id = f.id AND f.objectclass_id = ', oc_id,' AND 
		p.name = ',ql_geom_name,' AND p.val_lod = ',ql_lod,'::text',sql_where,');
');

IF NOT is_count THEN
    RETURN sql_relief_compon_geom;
ELSE
    RETURN sql_relief_compon_count;
END IF;
    
EXCEPTION
	WHEN QUERY_CANCELED THEN
		RAISE EXCEPTION ' qgis_pkg.create_geometry_relief_component(): Error QUERY_CANCELED';
  	WHEN OTHERS THEN
		RAISE EXCEPTION ' qgis_pkg.create_geometry_relief_component(): %', SQLERRM;
END;
$$ LANGUAGE plpgsql;
COMMENT ON FUNCTION qgis_pkg.create_geometry_relief_component(varchar, integer, text, text, text, integer, text, boolean) IS 'Create sql for creating geometry view of relief component';
REVOKE EXECUTE ON FUNCTION qgis_pkg.create_geometry_relief_component(varchar, integer, text, text, text, integer, text, boolean) FROM PUBLIC;
-- Example
-- SELECT * FROM qgis_pkg.create_geometry_relief_component('citydb', 502, 'tin', 'MULTIPOLYGONZ', '1', 28992, NULL);
-- SELECT * FROM qgis_pkg.create_geometry_relief_component('citydb', 502, 'tin', 'MULTIPOLYGONZ', '1', 28992, NULL, TRUE);


----------------------------------------------------------------
-- Create FUNCTION QGIS_PKG.CREATE_GEOMETRY_ADDRESS()
----------------------------------------------------------------
--  The function returns the sql for creating geometry view of address
DROP FUNCTION IF EXISTS qgis_pkg.create_geometry_address(varchar, integer, text, boolean);
CREATE OR REPLACE FUNCTION qgis_pkg.create_geometry_address(
	cdb_schema varchar,
    objectclass_id integer,
    sql_where text,
    is_count boolean DEFAULT FALSE -- TRUE to return count sql
) 
RETURNS text AS $$
DECLARE
	qi_cdb_schema varchar   := quote_ident(cdb_schema);
    oc_id integer           := objectclass_id;
	sql_address text;
    sql_address_count text;
BEGIN

sql_address := concat('
SELECT
	a.id						AS a_id,
	f.id::bigint 				AS f_id,
	f.objectid::text			AS f_object_id,
	a.multi_point				AS geom,
	a.objectid,
	a.identifier,				
	a.identifier_codespace,	
	a.street,
	a.house_number,
	a.zip_code,
	a.city,
	a.state,
	a.country,
	a.free_text,
	a.content,
	a.content_mime_type
FROM ',qi_cdb_schema,'.feature AS f
	INNER JOIN ',qi_cdb_schema,'.property AS p ON (f.id = p.feature_id AND f.objectclass_id = ',oc_id,'',sql_where,')
	INNER JOIN ',qi_cdb_schema,'.address  AS a ON (p.val_address_id = a.id);
-- ORDER BY f.id ASC;
');

sql_address_count := concat('
	SELECT
		COUNT(f.id) AS n_feature
	FROM ',qi_cdb_schema,'.feature AS f
		INNER JOIN ',qi_cdb_schema,'.property AS p ON (f.id = p.feature_id AND f.objectclass_id = ',oc_id,'',sql_where,')
		INNER JOIN ',qi_cdb_schema,'.address  AS a ON (p.val_address_id = a.id);
');

IF NOT is_count THEN
    RETURN sql_address;
ELSE
    RETURN sql_address_count;
END IF;
    
EXCEPTION
	WHEN QUERY_CANCELED THEN
		RAISE EXCEPTION ' qgis_pkg.create_geometry_address(): Error QUERY_CANCELED';
  	WHEN OTHERS THEN
		RAISE EXCEPTION ' qgis_pkg.create_geometry_address(): %', SQLERRM;
END;
$$ LANGUAGE plpgsql;
COMMENT ON FUNCTION qgis_pkg.create_geometry_address(varchar, integer, text, boolean) IS 'Create sql for creating geometry view of address';
REVOKE EXECUTE ON FUNCTION qgis_pkg.create_geometry_address(varchar, integer, text, boolean) FROM PUBLIC;
-- Example
-- SELECT * FROM qgis_pkg.create_geometry_address('citydb', 901, NULL);
-- SELECT * FROM qgis_pkg.create_geometry_address('citydb', 901, NULL, TRUE);


----------------------------------------------------------------
-- Create FUNCTION QGIS_PKG.CREATE_GEOMETRY_VIEW()
----------------------------------------------------------------
/*  Create geometry view */
DROP FUNCTION IF EXISTS qgis_pkg.create_geometry_view(varchar, varchar, integer, integer, integer, text, text, text, text, boolean, varchar) CASCADE;
CREATE OR REPLACE FUNCTION qgis_pkg.create_geometry_view(
	usr_schema varchar,
	cdb_schema varchar, 
	parent_objectclass_id integer, 
	objectclass_id integer, 
	datatype_id integer, 
	geometry_name text, 
	lod text, 
	geometry_type text, 
	postgis_geom_type text, 
	is_matview boolean DEFAULT FALSE,
	cdb_bbox_type varchar DEFAULT 'db_schema'	
) 
RETURNS varchar AS $$
DECLARE
	-- view detail
	qi_usr_name varchar			:= (SELECT substring(usr_schema from 'qgis_(.*)') AS usr_name);
	feature_type varchar		:= (SELECT feature_type FROM qgis_pkg.classname_lookup WHERE oc_id = objectclass_id);
	srid integer 				:= NULL;
	num_features bigint			:= NULL;
	qi_usr_schema varchar 		:= quote_ident(usr_schema);
	ql_usr_schema varchar		:= quote_literal(usr_schema);
	qi_cdb_schema varchar 		:= quote_ident(cdb_schema);
	ql_cdb_schema varchar		:= quote_literal(cdb_schema);
	ql_feature_type varchar		:= quote_literal(feature_type);
	qi_geom_name text 			:= quote_ident(geometry_name);
	ql_geom_name text			:= geometry_name;
    qi_geom_type text 			:= quote_ident(geometry_type);
	ql_p_geom_type text 		:= postgis_geom_type;
    ql_lod text                 := lod;
	p_oc_id integer 			:= parent_objectclass_id;
	oc_id integer 				:= objectclass_id;
	p_oc_alias text; oc_alias text;
	relief_feat_id integer; relief_compon_ids integer[];
	qi_gv_name varchar;
	qi_gv_header text;
	qi_gv_footer text;
	-- geometry creation
	cdb_bbox_type_array CONSTANT varchar[] 	:= ARRAY['db_schema', 'm_view', 'qgis'];
    cdb_envelope geometry;
	address_datatype_id integer; geom_datatype_id integer; implicit_geom_datatype_id integer;
    sql_geometry text;
    sql_geometry_count text;
	sql_view text;
	sql_where text;
    -- view info
	v_start_time TIMESTAMP; v_end_time TIMESTAMP; v_creation_time TIME(3);
	-- mv info
	view_type text; mv_start_time TIMESTAMP; mv_end_time TIMESTAMP; mv_create_time TIME(3);

BEGIN
-- Check if usr_schema exists
IF qi_usr_schema IS NULL or NOT EXISTS(SELECT 1 FROM information_schema.schemata AS i WHERE i.schema_name::varchar = qi_usr_schema) THEN
	RAISE EXCEPTION 'usr_schema (%) not found. Please create usr_schema first', qi_usr_schema;
END IF;
	
-- Check if cdb_schema exists
IF qi_cdb_schema IS NULL or NOT EXISTS(SELECT 1 FROM information_schema.schemata AS i WHERE i.schema_name::varchar = qi_cdb_schema) THEN
	RAISE EXCEPTION 'cdb_schema (%) not found. It must be an existing schema', qi_cdb_schema;
END IF;

-- Check if current user has created specific schema named "qgis_(user_name)"
IF qi_usr_schema IS NULL OR NOT EXISTS(SELECT * FROM information_schema.schemata AS i WHERE schema_name = qi_usr_schema) THEN
	RAISE EXCEPTION 'usr_schema: % does not exist. Please create it first', qi_usr_schema;
END IF;

-- Check if feature geometry metadata table exists
IF NOT EXISTS(SELECT 1 FROM information_schema.tables WHERE table_schema = qi_usr_schema AND table_name = 'feature_geometry_metadata') THEN
	RAISE EXCEPTION '%.feature_geometry_metadata table not yet created. Please create it first', qi_usr_schema;
END IF;

-- Check if feature geometry is deprecated geometry type
IF ql_p_geom_type IS NULL THEN
	RAISE EXCEPTION 'The geometry_name "%" is a deprecated geometry type in CityGML v.3.0! Skip create_geometry_view()', geometry_name;
END IF;

-- Get the srid, necessary datatype_ids and objectclass_ids of relief_components from the cdb_schema
EXECUTE format('SELECT srid FROM %s.database_srs LIMIT 1', qi_cdb_schema) INTO srid;
EXECUTE format('SELECT * FROM qgis_pkg.datatype_name_to_type_id(%L, %L)', qi_cdb_schema, 'AddressProperty') INTO address_datatype_id;
EXECUTE format('SELECT * FROM qgis_pkg.datatype_name_to_type_id(%L, %L)', qi_cdb_schema, 'GeometryProperty') INTO geom_datatype_id;
EXECUTE format('SELECT * FROM qgis_pkg.datatype_name_to_type_id(%L, %L)', qi_cdb_schema, 'ImplicitGeometryProperty') INTO implicit_geom_datatype_id;
EXECUTE format('SELECT * FROM qgis_pkg.classname_to_objectclass_id(%L, %L)', qi_cdb_schema, 'ReliefFeature') INTO relief_feat_id;
EXECUTE format('SELECT ARRAY (SELECT id FROM %I.objectclass WHERE superclass_id = qgis_pkg.classname_to_objectclass_id(%L, %L))', qi_cdb_schema, qi_cdb_schema, 'AbstractReliefComponent') INTO relief_compon_ids;

-- Check that the cdb_box_type is a valid value and get the envelope
IF CDB_BBOX_TYPE IS NULL OR NOT (CDB_BBOX_TYPE = ANY (cdb_bbox_type_array)) THEN
	RAISE EXCEPTION 'cdb_bbox_type value is invalid. It must be one of (%)', cdb_bbox_type_array;
ELSE
	EXECUTE format('SELECT envelope FROM %I.extents WHERE cdb_schema = %L AND bbox_type = %L', qi_usr_schema, qi_cdb_schema, CDB_BBOX_TYPE) INTO cdb_envelope;
END IF;

-- Check that the srid is the same to cdb_envelope
IF ST_SRID(cdb_envelope) IS NULL OR ST_SRID(cdb_envelope) <> srid OR cdb_bbox_type = 'db_schema' THEN
	sql_where := NULL;
ELSE
	sql_where := concat(' AND ST_MakeEnvelope(',ST_XMin(cdb_envelope),',',ST_YMin(cdb_envelope),',',ST_XMax(cdb_envelope),',',ST_YMax(cdb_envelope),',',srid,') && f.envelope ');
END IF;

-- Generate view name
IF p_oc_id = 0 THEN
	-- space feature
	oc_alias := (SELECT * FROM qgis_pkg.objectclass_id_to_alias(oc_id));
	IF datatype_id = address_datatype_id THEN
		qi_gv_name := concat(qi_cdb_schema,'_', oc_alias, '_lod', lod, '_', geometry_name);
	ELSE
		qi_gv_name := concat(qi_cdb_schema,'_', oc_alias, '_lod', lod, '_', geometry_type);
	END IF;
ELSE
	-- boundary feature
	p_oc_alias  := (SELECT * FROM qgis_pkg.objectclass_id_to_alias(p_oc_id));
	oc_alias    := (SELECT * FROM qgis_pkg.objectclass_id_to_alias(oc_id));
	qi_gv_name := concat(qi_cdb_schema,'_', p_oc_alias, '_', oc_alias, '_lod', lod, '_', geometry_type);
END IF;

-- Determine View or Materialized View
IF IS_MATVIEW THEN
	view_type := 'materialized view';
	qi_gv_name := concat('"_g_', qi_gv_name, '"');
	qi_gv_header := qgis_pkg.generate_sql_matview_header(qi_usr_schema, qi_gv_name);
	qi_gv_footer := qgis_pkg.generate_sql_matview_footer(qi_usr_name, qi_usr_schema, qi_gv_name);
ELSE
	view_type := 'view';
    qi_gv_name := concat('"', qi_gv_name, '"');
	qi_gv_header := qgis_pkg.generate_sql_view_header(qi_usr_schema, qi_gv_name);
END IF;

-- Determine which sql
IF oc_id = relief_feat_id THEN
    -- Relief Feature
    sql_geometry := (SELECT qgis_pkg.create_geometry_relief_feature(qi_cdb_schema, oc_id, geometry_name, ql_p_geom_type, ql_lod, srid, sql_where));
    sql_geometry_count := (SELECT qgis_pkg.create_geometry_relief_feature(qi_cdb_schema, oc_id, qi_geom_name, ql_p_geom_type, ql_lod, srid, sql_where, TRUE));
ELSIF oc_id = ANY(relief_compon_ids) THEN
    -- Relief Components
    sql_geometry := (SELECT qgis_pkg.create_geometry_relief_component(qi_cdb_schema, oc_id, geometry_name, ql_p_geom_type, ql_lod, srid, sql_where));
    sql_geometry_count := (SELECT qgis_pkg.create_geometry_relief_component(qi_cdb_schema, oc_id, qi_geom_name, ql_p_geom_type, ql_lod, srid, sql_where, TRUE));
ELSE
	-- Space Feature
	IF p_oc_id = 0 THEN
		-- geometry / implicit geometry
		IF datatype_id IN (geom_datatype_id, implicit_geom_datatype_id) THEN
            sql_geometry := (SELECT qgis_pkg.create_geometry_space_feature(qi_cdb_schema, oc_id, geometry_name, ql_p_geom_type, datatype_id, srid, sql_where));
            sql_geometry_count := (SELECT qgis_pkg.create_geometry_space_feature(qi_cdb_schema, oc_id, qi_geom_name, ql_p_geom_type, datatype_id, srid, sql_where, TRUE));
		ELSIF datatype_id = address_datatype_id THEN
			-- Address feature
            sql_geometry := (SELECT qgis_pkg.create_geometry_address(qi_cdb_schema, oc_id, sql_where));
            sql_geometry_count := (SELECT qgis_pkg.create_geometry_address(qi_cdb_schema, oc_id, sql_where, TRUE));
		ELSE
			RAISE NOTICE 'Datatype_id is wrong, it should be geometry, implicit geometry or address property. Please check in the %.feature_geometry_metadata table !', qi_usr_schema;
		END IF;
	ELSE
        -- Boundary Feature
		IF datatype_id = geom_datatype_id THEN
        	sql_geometry := (SELECT qgis_pkg.create_geometry_boundary_feature(qi_cdb_schema, p_oc_id, oc_id, geometry_name, ql_p_geom_type, datatype_id, srid, sql_where));
        	sql_geometry_count := (SELECT qgis_pkg.create_geometry_boundary_feature(qi_cdb_schema, p_oc_id, oc_id, qi_geom_name, ql_p_geom_type, datatype_id, srid, sql_where, TRUE));
		END IF;
	END IF;
END IF;

sql_view := concat(qi_gv_header, sql_geometry);
-- EXECUTE sql_geometry_count INTO num_features;
	
-- Create view or materialized view
IF IS_MATVIEW THEN
	sql_view := concat(sql_view, qi_gv_footer);
	mv_start_time := clock_timestamp();
	EXECUTE sql_view;
	mv_end_time := clock_timestamp();
	mv_create_time :=  mv_end_time - mv_start_time;
	RAISE NOTICE '% % creation time %', view_type, qi_gv_name, mv_create_time;
	EXECUTE format('
		UPDATE %I.feature_geometry_metadata AS fgm
		SET 
			is_matview = TRUE,
			mview_name = %L,
			mv_creation_time = %L
		WHERE
			fgm.cdb_schema = %L AND fgm.parent_objectclass_id = %L AND
			fgm.objectclass_id = %L AND fgm.geometry_name = %L AND fgm.lod = %L;
	', qi_usr_schema, qi_gv_name, mv_create_time, qi_cdb_schema, p_oc_id, oc_id, ql_geom_name, ql_lod);
ELSE
	v_start_time := clock_timestamp();
	EXECUTE sql_view;
	v_end_time := clock_timestamp();
	v_creation_time := v_end_time - v_start_time;
	RAISE NOTICE '%: % creation time %', view_type, qi_gv_name, v_creation_time;
	EXECUTE format('
	UPDATE %I.feature_geometry_metadata AS fgm
    SET view_name = %L
    WHERE
        fgm.cdb_schema = %L AND fgm.parent_objectclass_id = %L AND 
		fgm.objectclass_id = %L AND fgm.geometry_name = %L AND fgm.lod = %L;
	', qi_usr_schema, qi_gv_name, qi_cdb_schema, p_oc_id, oc_id, ql_geom_name, ql_lod);
END IF;


/* Drop geometry materialized view (before creation) cascades to related layer
   Delete entries from table layer_metadata and reset sequence (if possible) */
EXECUTE format('
DELETE FROM %I.layer_metadata AS l WHERE l.cdb_schema = %L AND l.gv_name = %L;
WITH m AS (SELECT max(id) AS max_id FROM %I.layer_metadata)
SELECT setval(''%I.layer_metadata_id_seq''::regclass, m.max_id, TRUE) FROM m;',
qi_usr_schema, qi_cdb_schema, qi_gv_name,
qi_usr_schema, qi_usr_schema);

RETURN concat(qi_usr_schema, '.', qi_gv_name);

EXCEPTION
	WHEN QUERY_CANCELED THEN
		RAISE EXCEPTION 'qgis_pkg.create_geometry_view: Error QUERY_CANCELED';
  	WHEN OTHERS THEN
		RAISE EXCEPTION 'qgis_pkg.create_geometry_view: %', SQLERRM;
END;
$$ LANGUAGE plpgsql;
COMMENT ON FUNCTION qgis_pkg.create_geometry_view(varchar, varchar, integer, integer, integer, text, text, text, text, boolean, varchar) IS 'Feature geometry (materialized) view creation. Specify is_matview as TRUE for MV';
REVOKE EXECUTE ON FUNCTION qgis_pkg.create_geometry_view(varchar, varchar, integer, integer, integer, text, text, text, text, boolean, varchar) FROM PUBLIC;
-- Example
-- SELECT * FROM qgis_pkg.create_geometry_view('qgis_bstsai','citydb', 0, 901, 11, 'lod0MultiSurface', '0', 'MultiSurface', 'MultiPolygonZ', FALSE);
-- SELECT * FROM qgis_pkg.create_geometry_view('qgis_bstsai','citydb', 0, 1301, 16, 'lod3ImplicitRepresentation', '3', 'ImplicitRepresentation', 'MultiPolygonZ', TRUE); --mv
-- SELECT * FROM qgis_pkg.create_geometry_view('qgis_bstsai','citydb', 901, 712, 11, 'lod2MultiSurface', '2', 'MultiSurface', 'MultiPolygonZ', TRUE);
-- SELECT * FROM qgis_pkg.create_geometry_view('qgis_bstsai','citydb', 0, 502, 11, 'tin', '1', 'tin', 'MultiPolygonZ', TRUE);


----------------------------------------------------------------
-- Create FUNCTION QGIS_PKG.CREATE_ALL_GEOMETRY_VIEW_IN_SCHEMA()
----------------------------------------------------------------
/*  The function creates all (materialized) views based on all the available feature geometries of a given schema */
DROP FUNCTION IF EXISTS qgis_pkg.create_all_geometry_view_in_schema(varchar, varchar, integer, integer, boolean, varchar);
CREATE OR REPLACE FUNCTION qgis_pkg.create_all_geometry_view_in_schema(
    usr_schema varchar,
	cdb_schema varchar,
    parent_objectclass_id integer DEFAULT NULL,
    objectclass_id integer DEFAULT NULL,
	is_matview boolean DEFAULT FALSE,
	cdb_bbox_type varchar DEFAULT 'db_schema'
) 
RETURNS void AS $$
DECLARE
	qi_usr_schema varchar 					:= quote_ident(usr_schema);
    qi_cdb_schema varchar 					:= quote_ident(cdb_schema);
	cdb_bbox_type_array CONSTANT varchar[] 	:= ARRAY['db_schema', 'm_view', 'qgis'];
    p_oc_id integer := parent_objectclass_id ; oc_id integer := objectclass_id;
    parent_classname text;
    classname text;
    geom_name text;
    start_time TIMESTAMP;
    end_time TIMESTAMP;
    view_type text;
    view_type_pl text;
    r RECORD;
BEGIN
-- Check if usr_schema exists
IF qi_usr_schema IS NULL or NOT EXISTS(SELECT 1 FROM information_schema.schemata AS i WHERE i.schema_name::varchar = qi_usr_schema) THEN
	RAISE EXCEPTION 'usr_schema (%) not found. Please create usr_schema first', qi_usr_schema;
END IF;
	
-- Check if cdb_schema exists
IF qi_cdb_schema IS NULL or NOT EXISTS(SELECT 1 FROM information_schema.schemata AS i WHERE i.schema_name::varchar = qi_cdb_schema) THEN
	RAISE EXCEPTION 'cdb_schema (%) not found. It must be an existing schema', qi_cdb_schema;
END IF;
	
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

-- Check if feature geometry metadata table exists
IF NOT EXISTS(SELECT 1 FROM information_schema.tables WHERE table_schema = qi_usr_schema AND table_name = 'feature_geometry_metadata') THEN
	RAISE EXCEPTION '%.feature_geometry_metadata table not yet created. Please create it first', qi_usr_schema;
END IF;


IF objectclass_id IS NOT NULL AND parent_objectclass_id <> 0 THEN
    -- Boundary feature
    parent_classname := (SELECT qgis_pkg.objectclass_id_to_classname(qi_cdb_schema, p_oc_id));
    classname := (SELECT qgis_pkg.objectclass_id_to_classname(qi_cdb_schema, oc_id));
    -- Create all attribute view or materialized view of the given parent and child objectclass_id within the schema
	RAISE NOTICE 'Create all geometry % of %-% (p_od_id = %, oc_id = %) in cdb_schema %', view_type_pl, parent_classname, classname, p_oc_id, oc_id, cdb_schema;
    FOR r IN
		EXECUTE format('
			SELECT fgm.cdb_schema, fgm.parent_objectclass_id, fgm.objectclass_id, fgm.datatype_id, fgm.geometry_name, fgm.lod, fgm.geometry_type, fgm.postgis_geom_type
			FROM %I.feature_geometry_metadata AS fgm
			WHERE fgm.cdb_schema = %L AND fgm.parent_objectclass_id = %L AND fgm.objectclass_id = %L
			ORDER BY fgm.id ASC
		', qi_usr_schema, qi_cdb_schema, p_oc_id, oc_id)
    LOOP
        PERFORM qgis_pkg.create_geometry_view(
            qi_usr_schema,
            qi_cdb_schema, 
            r.parent_objectclass_id, 
            r.objectclass_id, 
            r.datatype_id, 
            r.geometry_name, 
            r.lod, 
            r.geometry_type, 
            r.postgis_geom_type,
            is_matview,
            cdb_bbox_type
        );
    END LOOP;
    RAISE NOTICE 'All available %(s) of boundary feature of %-% in schema "%" are created successfully in user schema "%"', LOWER(view_type), parent_classname, classname, qi_cdb_schema, qi_usr_schema;
ELSIF objectclass_id IS NOT NULL AND parent_objectclass_id = 0 THEN
    -- Space feature
    classname := (SELECT qgis_pkg.objectclass_id_to_classname(qi_cdb_schema, oc_id));
    -- Create all attribute view or materialized view of the given parent objectclass_id within the schema
	RAISE NOTICE 'Create all geometry % of % (oc_id = %) in cdb_schema %', view_type_pl, classname, oc_id, cdb_schema;
    FOR r IN
		EXECUTE format('
			SELECT fgm.cdb_schema, fgm.parent_objectclass_id, fgm.objectclass_id, fgm.datatype_id, fgm.geometry_name, fgm.lod, fgm.geometry_type, fgm.postgis_geom_type
        	FROM %I.feature_geometry_metadata AS fgm
        	WHERE fgm.cdb_schema = %L AND fgm.parent_objectclass_id = %L AND fgm.objectclass_id = %L
			ORDER BY fgm.id ASC
		', qi_usr_schema, qi_cdb_schema, p_oc_id, oc_id)
    LOOP
        PERFORM qgis_pkg.create_geometry_view(
            qi_usr_schema,
            r.cdb_schema, 
            r.parent_objectclass_id, 
            r.objectclass_id, 
            r.datatype_id, 
            r.geometry_name, 
            r.lod, 
            r.geometry_type, 
            r.postgis_geom_type,
            is_matview,
            cdb_bbox_type
        );
    END LOOP;
    RAISE NOTICE 'All available %(s) of space feature of % in schema "%" are created successfully in user schema "%"', LOWER(view_type), classname, qi_cdb_schema, qi_usr_schema;
ELSIF objectclass_id IS NULL AND parent_objectclass_id IS NULL THEN
    -- All feature
    -- Create all attribute view or materialized view within the schema
	RAISE NOTICE 'Create all geometry % in cdb_schema %', view_type_pl, cdb_schema;
    FOR r IN
		EXECUTE format('
			SELECT fgm.cdb_schema, fgm.parent_objectclass_id, fgm.objectclass_id, fgm.datatype_id, fgm.geometry_name, fgm.lod, fgm.geometry_type, fgm.postgis_geom_type
			FROM %I.feature_geometry_metadata AS fgm
			WHERE fgm.cdb_schema = %L
			ORDER BY fgm.id ASC
		', qi_usr_schema, qi_cdb_schema)
    LOOP
        PERFORM qgis_pkg.create_geometry_view(
            qi_usr_schema,
            r.cdb_schema, 
            r.parent_objectclass_id, 
            r.objectclass_id, 
            r.datatype_id, 
            r.geometry_name, 
            r.lod, 
            r.geometry_type, 
            r.postgis_geom_type,
            is_matview,
            cdb_bbox_type
        );
    END LOOP;
    RAISE NOTICE 'All available %(s) of all feature in schema "%" are created successfully in user schema "%"', LOWER(view_type), qi_cdb_schema, qi_usr_schema;
ELSIF NOT FOUND THEN
    RAISE EXCEPTION 'Specified parent and child objectclass_ids not found. Please check and update the %.feature_geometry_metadata table first!', qi_usr_schema;
END IF;
 
EXCEPTION
    WHEN QUERY_CANCELED THEN
        RAISE EXCEPTION 'qgis_pkg.create_all_geometry_view_in_schema(): Error QUERY_CANCELED';
    WHEN OTHERS THEN
        RAISE EXCEPTION 'qgis_pkg.create_all_geometry_view_in_schema(): %', SQLERRM;
END;
$$ LANGUAGE plpgsql;
COMMENT ON FUNCTION qgis_pkg.create_all_geometry_view_in_schema(varchar, varchar, integer, integer, boolean, varchar) IS 'Create all available (materialized) views in a given schema';
REVOKE EXECUTE ON FUNCTION qgis_pkg.create_all_geometry_view_in_schema(varchar, varchar, integer, integer, boolean, varchar) FROM PUBLIC;
--Example
-- SELECT * FROM qgis_pkg.create_all_geometry_view_in_schema('qgis_bstsai', 'citydb', NULL, 901); -- p_oc_id & oc_id not found test
-- SELECT * FROM qgis_pkg.create_all_geometry_view_in_schema('qgis_bstsai', 'cityd', 0, 901); -- cdb_schema not found test
-- SELECT * FROM qgis_pkg.create_all_geometry_view_in_schema('qgis_bstsai', 'citydb', NULL, NULL, TRUE); -- (db_schema, mv)
-- SELECT * FROM qgis_pkg.create_all_geometry_view_in_schema('qgis_bstsai', 'citydb', 0, 901);
-- SELECT * FROM qgis_pkg.create_all_geometry_view_in_schema('qgis_bstsai', 'citydb', 0, 901, TRUE);


----------------------------------------------------------------
-- Create FUNCTION QGIS_PKG.REFRESH_GEOMETRY_MATERIALIZED_VIEW()
----------------------------------------------------------------
/*  The function refresh geometry materialized views of the specified parent-child objectclass_ids and geometry representation in given schema */
DROP FUNCTION IF EXISTS qgis_pkg.refresh_geometry_materialized_view(varchar, varchar, integer, integer, text);
CREATE OR REPLACE FUNCTION qgis_pkg.refresh_geometry_materialized_view(
    usr_schema varchar,
	cdb_schema varchar,
	parent_objectclass_id integer,
	objectclass_id integer,
    geometry_name text
) 
RETURNS varchar AS $$
DECLARE
	qi_usr_schema varchar 	:= quote_ident(usr_schema);
    qi_cdb_schema varchar 	:= quote_ident(cdb_schema);
	p_oc_id integer 		:= parent_objectclass_id;
	oc_id integer 			:= objectclass_id;
	geom_name text 			:= geometry_name;
	parent_classname text; classname text;
	target_class text;
	start_time TIMESTAMP; end_time TIMESTAMP;
	mv_refresh_t TIME(3);
	mview_exists boolean := FALSE;
	sql_mv_refresh text;
    r RECORD;
BEGIN
-- Check if usr_schema exists
IF qi_usr_schema IS NULL or NOT EXISTS(SELECT 1 FROM information_schema.schemata AS i WHERE i.schema_name::varchar = qi_usr_schema) THEN
	RAISE EXCEPTION 'usr_schema (%) not found. Please create usr_schema first', qi_usr_schema;
END IF;
	
-- Check if cdb_schema exists
IF qi_cdb_schema IS NULL or NOT EXISTS(SELECT 1 FROM information_schema.schemata AS i WHERE i.schema_name::varchar = qi_cdb_schema) THEN
	RAISE EXCEPTION 'cdb_schema (%) not found. It must be an existing schema', qi_cdb_schema;
END IF;
	
-- Check if feature geometry metadata table exists
IF NOT EXISTS(SELECT 1 FROM information_schema.tables WHERE table_schema = qi_usr_schema AND table_name = 'feature_geometry_metadata') THEN
    RAISE EXCEPTION '%.feature_geometry_metadata table not yet created. Please create it first', qi_usr_schema;
END IF;

IF parent_objectclass_id IS NOT NULL AND objectclass_id IS NOT NULL AND geometry_name IS NOT NULL THEN
	IF parent_objectclass_id <> 0 THEN
		parent_classname := (SELECT qgis_pkg.objectclass_id_to_classname(qi_cdb_schema, parent_objectclass_id));
		classname := (SELECT qgis_pkg.objectclass_id_to_classname(qi_cdb_schema, objectclass_id));
		target_class := concat(parent_classname, '_', classname);
		RAISE NOTICE 'Refresh %-% (p_oc_id = %, oc_id = %) materialized view of % in schema %', parent_classname, classname, p_oc_id, oc_id, geometry_name, cdb_schema;
	ELSE
		classname := (SELECT qgis_pkg.objectclass_id_to_classname(qi_cdb_schema, objectclass_id));
		target_class := classname;
		RAISE NOTICE 'Refresh % (oc_id = %) materialized view of % in schema %', classname, oc_id, geometry_name, cdb_schema;
	END IF;
END IF;
	
FOR r IN
	EXECUTE format('
		SELECT fgm.cdb_schema, fgm.parent_objectclass_id, fgm.objectclass_id, fgm.mview_name
		FROM %I.feature_geometry_metadata AS fgm
		WHERE fgm.cdb_schema = %L AND fgm.parent_objectclass_id = %L AND fgm.objectclass_id = %L
			AND fgm.geometry_name = %L AND fgm.mview_name IS NOT NULL
	', qi_usr_schema, qi_cdb_schema, p_oc_id, oc_id, geom_name)
LOOP
	IF r.mview_name IS NOT NULL THEN
		mview_exists := TRUE;
	    sql_mv_refresh := concat('REFRESH MATERIALIZED VIEW ', qi_usr_schema,'.', r.mview_name,';');
	    start_time := clock_timestamp();
	    EXECUTE sql_mv_refresh;
	    end_time := clock_timestamp();
	    mv_refresh_t := end_time - start_time;
		EXECUTE format('
			UPDATE %I.feature_geometry_metadata
			SET mv_refresh_time = %L, mv_last_update_time = %L
			WHERE cdb_schema = %L AND mview_name = %L
		', qi_usr_schema, mv_refresh_t, end_time, qi_cdb_schema, r.mview_name);
	END IF;
END LOOP;

IF NOT mview_exists THEN
	RAISE EXCEPTION 'No geometry % materialized view of % found in schema %', target_class, geometry_name, cdb_schema;
END IF;

RETURN concat(qi_usr_schema, '.', r.mview_name);
 
EXCEPTION
    WHEN QUERY_CANCELED THEN
        RAISE EXCEPTION 'qgis_pkg.refresh_geometry_materialized_view(): Error QUERY_CANCELED';
    WHEN OTHERS THEN
        RAISE EXCEPTION 'qgis_pkg.refresh_geometry_materialized_view(): %', SQLERRM;
END;
$$ LANGUAGE plpgsql;
COMMENT ON FUNCTION qgis_pkg.refresh_geometry_materialized_view(varchar, varchar, integer, integer, text) IS 'Refresh specified materialized views in a given schema';
REVOKE EXECUTE ON FUNCTION qgis_pkg.refresh_geometry_materialized_view(varchar, varchar, integer, integer, text) FROM PUBLIC;
--Example
-- SELECT * FROM qgis_pkg.refresh_geometry_materialized_view('qgis_bstsai', 'citydb', 0, 901, 'lod1Solid'); -- refresh mv of 901-lod1Solid
-- SELECT * FROM qgis_pkg.refresh_geometry_materialized_view('qgis_bstsai', 'citydb', 901, 709, 'lod2MultiSurface'); -- refresh mv of 901--709-lod1Solid
-- SELECT * FROM qgis_pkg.refresh_geometry_materialized_view('qgis_bstsai', 'citydb', 0, 901, 'lod0Solid'); -- refresh mv error test


----------------------------------------------------------------
-- Create FUNCTION QGIS_PKG.REFRESH_ALL_GEOMETRY_MATERIALIZED_VIEW()
----------------------------------------------------------------
DROP FUNCTION IF EXISTS qgis_pkg.refresh_all_geometry_materialized_view(varchar, varchar, integer, integer);
CREATE OR REPLACE FUNCTION qgis_pkg.refresh_all_geometry_materialized_view(
    usr_schema varchar,
	cdb_schema varchar,
	parent_objectclass_id integer DEFAULT NULL,
	objectclass_id integer DEFAULT NULL
) 
RETURNS void AS $$
DECLARE
	qi_usr_schema varchar 	:= quote_ident(usr_schema);
    qi_cdb_schema varchar 	:= quote_ident(cdb_schema);
	p_oc_id integer 		:= parent_objectclass_id;
	oc_id integer 			:= objectclass_id;
	parent_classname text; classname text;
	target_class text;
	start_time TIMESTAMP; end_time TIMESTAMP;
	mv_refresh_t TIME(3);
	mview_exists boolean := FALSE;
	sql_mv_refresh text;
    r RECORD;
BEGIN
-- Check if usr_schema exists
IF qi_usr_schema IS NULL or NOT EXISTS(SELECT 1 FROM information_schema.schemata AS i WHERE i.schema_name::varchar = qi_usr_schema) THEN
	RAISE EXCEPTION 'usr_schema (%) not found. Please create usr_schema first', qi_usr_schema;
END IF;
	
-- Check if cdb_schema exists
IF qi_cdb_schema IS NULL or NOT EXISTS(SELECT 1 FROM information_schema.schemata AS i WHERE i.schema_name::varchar = qi_cdb_schema) THEN
	RAISE EXCEPTION 'cdb_schema (%) not found. It must be an existing schema', qi_cdb_schema;
END IF;
	
-- Check if feature geometry metadata table exists
IF NOT EXISTS(SELECT 1 FROM information_schema.tables WHERE table_schema = qi_usr_schema AND table_name = 'feature_geometry_metadata') THEN
    RAISE EXCEPTION '%.feature_geometry_metadata table not yet created. Please create it first', qi_usr_schema;
END IF;

IF NOT (parent_objectclass_id IS NULL AND objectclass_id IS NULL) THEN
	IF parent_objectclass_id <> 0 THEN
		parent_classname := (SELECT qgis_pkg.objectclass_id_to_classname(qi_cdb_schema, parent_objectclass_id));
		classname := (SELECT qgis_pkg.objectclass_id_to_classname(qi_cdb_schema, objectclass_id));
		target_class := concat(parent_classname, '_', classname);
		RAISE NOTICE 'Refresh %-% (p_oc_id = %, oc_id = %) materialized view(s) in schema %', parent_classname, classname, p_oc_id, oc_id, cdb_schema;
	ELSE
		classname := (SELECT qgis_pkg.objectclass_id_to_classname(qi_cdb_schema, objectclass_id));
		target_class := classname;
		RAISE NOTICE 'Refresh % (oc_id = %) materialized view(s) in schema %', classname, oc_id, cdb_schema;
	END IF;
	
	FOR r IN
		EXECUTE format('
			SELECT fgm.cdb_schema, fgm.parent_objectclass_id, fgm.objectclass_id, fgm.geometry_name, fgm.mview_name
	    	FROM %I.feature_geometry_metadata AS fgm
	    	WHERE fgm.cdb_schema = %L AND fgm.parent_objectclass_id = %L AND fgm.objectclass_id = %L
			AND fgm.mview_name IS NOT NULL
		',qi_usr_schema, qi_cdb_schema, p_oc_id, oc_id)
	LOOP
		mview_exists := TRUE;
		PERFORM qgis_pkg.refresh_geometry_materialized_view(
			qi_usr_schema,
			r.cdb_schema,
			r.parent_objectclass_id,
			r.objectclass_id,
			r.geometry_name
		);
	END LOOP;
ELSE
	FOR r IN
		EXECUTE format('
			SELECT fgm.cdb_schema, fgm.parent_objectclass_id, fgm.objectclass_id, fgm.geometry_name, fgm.mview_name
	    	FROM %I.feature_geometry_metadata AS fgm
	    	WHERE fgm.cdb_schema = %L AND fgm.mview_name IS NOT NULL
		', qi_usr_schema, qi_cdb_schema)
	LOOP
		mview_exists := TRUE;
		PERFORM qgis_pkg.refresh_geometry_materialized_view(
			qi_usr_schema,
			r.cdb_schema,
			r.parent_objectclass_id,
			r.objectclass_id,
			r.geometry_name
		);
	END LOOP;
END IF;

IF NOT mview_exists THEN
	IF NOT (parent_objectclass_id IS NULL AND objectclass_id IS NULL) THEN
		RAISE EXCEPTION 'No geometry materialized views of % found in schema %', target_class, cdb_schema;
	ELSE
		RAISE EXCEPTION 'No geometry materialized views found in schema %', cdb_schema;
	END IF;
END IF;
 
EXCEPTION
    WHEN QUERY_CANCELED THEN
        RAISE EXCEPTION 'qgis_pkg.refresh_all_geometry_materialized_view(): Error QUERY_CANCELED';
    WHEN OTHERS THEN
        RAISE EXCEPTION 'qgis_pkg.refresh_all_geometry_materialized_view(): %', SQLERRM;
END;
$$ LANGUAGE plpgsql;
COMMENT ON FUNCTION qgis_pkg.refresh_all_geometry_materialized_view(varchar, varchar, integer, integer) IS 'Refresh all materialized views in a given schema (of parent-child objectclass_id)';
REVOKE EXECUTE ON FUNCTION qgis_pkg.refresh_all_geometry_materialized_view(varchar, varchar, integer, integer) FROM PUBLIC;
-- Example
-- SELECT * FROM qgis_pkg.refresh_all_geometry_materialized_view('qgis_bstsai', 'citydb');
-- SELECT * FROM qgis_pkg.refresh_all_geometry_materialized_view('qgis_bstsai', 'citydb', 0, 901);
-- SELECT * FROM qgis_pkg.refresh_all_geometry_materialized_view('qgis_bstsai', 'citydb', 901, 709);
-- SELECT * FROM qgis_pkg.refresh_all_geometry_materialized_view('qgis_bstsai', 'citydb', 0, 903); -- refresh all mv error test


----------------------------------------------------------------
-- Create FUNCTION QGIS_PKG.DROP_GEOMETRY_VIEW()
----------------------------------------------------------------
-- The function drops the specified geometry view and materialized view of the given objectclass in the given schema
DROP FUNCTION IF EXISTS qgis_pkg.drop_geometry_view(varchar, varchar, integer, integer, text, varchar);
CREATE OR REPLACE FUNCTION qgis_pkg.drop_geometry_view(
	usr_schema varchar,
	cdb_schema varchar,
    parent_objectclass_id integer,
	objectclass_id integer,
    geometry_name text,
	lod	varchar
) 
RETURNS void AS $$
DECLARE
	qi_cdb_schema varchar := quote_ident(cdb_schema);
	ql_cdb_schema varchar := quote_literal(cdb_schema);
	qi_usr_schema varchar := quote_ident(usr_schema);
	ql_lod varchar := lod;
	parent_classname text; classname text; target_class text;
    p_oc_id integer := parent_objectclass_id;
	oc_id integer := objectclass_id;
    geom_name varchar = geometry_name; 
	view_exists boolean := FALSE;
	sql_drop_v text;
    sql_drop_mv text;
	r RECORD;
	
BEGIN
-- Check if usr_schema exists
IF qi_usr_schema IS NULL or NOT EXISTS(SELECT 1 FROM information_schema.schemata AS i WHERE i.schema_name::varchar = qi_usr_schema) THEN
	RAISE EXCEPTION 'usr_schema (%) not found. Please create usr_schema first', qi_usr_schema;
END IF;
	
-- Check if cdb_schema exists
IF qi_cdb_schema IS NULL or NOT EXISTS(SELECT 1 FROM information_schema.schemata AS i WHERE i.schema_name::varchar = qi_cdb_schema) THEN
	RAISE EXCEPTION 'cdb_schema (%) not found. It must be an existing schema', qi_cdb_schema;
END IF;
	
-- Check if feature geometry metadata table exists
IF NOT EXISTS(SELECT 1 FROM information_schema.tables WHERE table_schema = qi_usr_schema AND table_name = 'feature_geometry_metadata') THEN
	RAISE EXCEPTION '%.feature_geometry_metadata table not yet created. Please create it first', qi_usr_schema;
END IF;

IF parent_objectclass_id IS NOT NULL AND objectclass_id IS NOT NULL AND geometry_name IS NOT NULL THEN
	IF parent_objectclass_id <> 0 THEN
		parent_classname := (SELECT qgis_pkg.objectclass_id_to_classname(qi_cdb_schema, parent_objectclass_id));
		classname := (SELECT qgis_pkg.objectclass_id_to_classname(qi_cdb_schema, objectclass_id));
		target_class := concat(parent_classname, '_', classname);
		RAISE NOTICE 'Drop %-% (p_oc_id = %, oc_id = %) (materialized) view in % (LoD_%) in schema %', parent_classname, classname, p_oc_id, oc_id, geometry_name, lod, cdb_schema;
	ELSE
		classname := (SELECT qgis_pkg.objectclass_id_to_classname(qi_cdb_schema, objectclass_id));
		target_class := classname;
		RAISE NOTICE 'Drop % (oc_id = %) (materialized) view in %(LoD_%) in schema %', classname, oc_id, geometry_name, lod, cdb_schema;
	END IF;
END IF;

FOR r IN
	EXECUTE format('
		SELECT fgm.cdb_schema, fgm.view_name, fgm.mview_name
    	FROM %I.feature_geometry_metadata AS fgm
    	WHERE fgm.cdb_schema = %L AND fgm.parent_objectclass_id = %L AND fgm.objectclass_id = %L AND fgm.geometry_name = %L AND fgm.lod = %L
	', qi_usr_schema, qi_cdb_schema, p_oc_id, oc_id, geom_name, ql_lod)
LOOP
	IF r.view_name IS NOT NULL THEN
		view_exists := TRUE;
	    sql_drop_v := concat('DROP VIEW IF EXISTS ', qi_usr_schema, '.', r.view_name, ' CASCADE;');
	    EXECUTE sql_drop_v;
		RAISE NOTICE 'Drop view of % in cdb_schema %', r.view_name, cdb_schema;
		EXECUTE format('
			UPDATE %I.feature_geometry_metadata AS fgm
			SET view_name = NULL
			WHERE fgm.cdb_schema = %L AND fgm.view_name = %L;
		', qi_usr_schema, qi_cdb_schema, r.view_name);
	END IF;
	IF r.mview_name IS NOT NULL THEN
		view_exists := TRUE;
	    sql_drop_mv := concat('DROP MATERIALIZED VIEW IF EXISTS ', qi_usr_schema, '.', r.mview_name, ' CASCADE;');
	    EXECUTE sql_drop_mv;
		RAISE NOTICE 'Drop materialized view of % in cdb_schema %', r.mview_name, cdb_schema;
		EXECUTE format('
		UPDATE %I.feature_geometry_metadata AS fgm
   		SET 
	        is_matview = FALSE,
	        mview_name = NULL,
	        mv_creation_time = NULL,
	        mv_refresh_time	= NULL,
	        mv_last_update_time	= NULL
	    WHERE fgm.cdb_schema = %L AND fgm.mview_name = %L;
		', qi_usr_schema, qi_cdb_schema, r.mview_name);

		/* Drop geometry materialized view cascades to related layer
		   Delete entries from table layer_metadata and reset sequence (if possible) */
		EXECUTE format('
		DELETE FROM %I.layer_metadata AS l WHERE l.cdb_schema = %L AND l.gv_name = %L;
		WITH m AS (SELECT max(id) AS max_id FROM %I.layer_metadata)
		SELECT setval(''%I.layer_metadata_id_seq''::regclass, m.max_id, TRUE) FROM m;',
		qi_usr_schema, qi_cdb_schema, r.mview_name,
		qi_usr_schema, qi_usr_schema);
	END IF;
END LOOP;

IF NOT view_exists THEN
	RAISE EXCEPTION 'The geometry (materialized) view of the % (p_oc_id = %, oc_id = %) in %(LoD_%) does not exist in %.feature_geometry_data table.', target_class, p_oc_id, oc_id, geometry_name, lod, qi_usr_schema;
END IF;
	
EXCEPTION
	WHEN QUERY_CANCELED THEN
		RAISE EXCEPTION 'qgis_pkg.drop_geometry_view(): Error QUERY_CANCELED';
  	WHEN OTHERS THEN
		RAISE EXCEPTION 'qgis_pkg.drop_geometry_view(): %', SQLERRM;
END;
$$ LANGUAGE plpgsql;
COMMENT ON FUNCTION qgis_pkg.drop_geometry_view(varchar, varchar, integer, integer, text, varchar) IS 'Drop specified geometry (materialized) views of the given objectclass feature in the schema';
REVOKE EXECUTE ON FUNCTION qgis_pkg.drop_geometry_view(varchar, varchar, integer, integer, text, varchar) FROM PUBLIC;
--Example
-- SELECT * FROM qgis_pkg.drop_geometry_view('qgis_bstsai', 'citydb', 901, 709, 'lod2MultiSurface', '2')
-- SELECT * FROM qgis_pkg.drop_geometry_view('qgis_bstsai', 'citydb', 0, 901, 'address', '0')
-- SELECT * FROM qgis_pkg.drop_geometry_view('qgis_bstsai', 'citydb', 0, 901, 'lod1Solid', '1')
-- SELECT * FROM qgis_pkg.drop_geometry_view('qgis_bstsai', 'citydb', 0, 901, 'lod0Solid', '0') -- drop view error test
-- SELECT * FROM qgis_pkg.drop_geometry_view('qgis_bstsai', 'citydb', 0, 903, 'lod1Solid', '1') -- drop view error test


----------------------------------------------------------------
-- Create FUNCTION QGIS_PKG.DROP_ALL_GEOMETRY_VIEWS()
----------------------------------------------------------------
/*  The function drops all available view and materialized view in the specified schema */
DROP FUNCTION IF EXISTS qgis_pkg.drop_all_geometry_views(varchar, varchar, integer, integer);
CREATE OR REPLACE FUNCTION qgis_pkg.drop_all_geometry_views(
	usr_schema varchar,
	cdb_schema varchar,
    parent_objectclass_id integer DEFAULT NULL,
    objectclass_id integer DEFAULT NULL
) 
RETURNS void AS $$
DECLARE
	qi_usr_schema varchar := quote_ident(usr_schema);
	qi_cdb_schema varchar := quote_ident(cdb_schema);
	ql_cdb_schema varchar := quote_literal(cdb_schema);
    p_oc_id integer := parent_objectclass_id;
	oc_id integer := objectclass_id;
	parent_classname varchar; classname varchar; target_class text;
	view_exists boolean := FALSE;
	r RECORD;
BEGIN
-- Check if usr_schema exists
IF qi_usr_schema IS NULL or NOT EXISTS(SELECT 1 FROM information_schema.schemata AS i WHERE i.schema_name::varchar = qi_usr_schema) THEN
	RAISE EXCEPTION 'usr_schema (%) not found. Please create usr_schema first', qi_usr_schema;
END IF;
	
-- Check if cdb_schema exists
IF qi_cdb_schema IS NULL or NOT EXISTS(SELECT 1 FROM information_schema.schemata AS i WHERE i.schema_name::varchar = qi_cdb_schema) THEN
	RAISE EXCEPTION 'cdb_schema (%) not found. It must be an existing schema', qi_cdb_schema;
END IF;

-- Check if feature geometry metadata table exists
IF NOT EXISTS(SELECT 1 FROM information_schema.tables WHERE table_schema = qi_usr_schema AND table_name = 'feature_geometry_metadata') THEN
	RAISE EXCEPTION '%.feature_geometry_metadata table not yet created. Please create it first', qi_usr_schema;
END IF;

IF parent_objectclass_id IS NOT NULL AND objectclass_id IS NOT NULL THEN
	IF parent_objectclass_id <> 0 THEN
		parent_classname := (SELECT qgis_pkg.objectclass_id_to_classname(qi_cdb_schema, parent_objectclass_id));
		classname := (SELECT qgis_pkg.objectclass_id_to_classname(qi_cdb_schema, objectclass_id));
		target_class := concat(parent_classname, '_', classname);
		RAISE NOTICE 'Drop all geometry (materialized) view(s) of %-% (p_oc_id = %, oc_id = %) in schema %', parent_classname, classname, p_oc_id, oc_id, cdb_schema;
	ELSE
		classname := (SELECT qgis_pkg.objectclass_id_to_classname(qi_cdb_schema, objectclass_id));
		target_class := classname;
		RAISE NOTICE 'Drop all geometry (materialized) view(s) of % (oc_id = %) in schema %', classname,  oc_id, cdb_schema;
	END IF;
	FOR r IN
		EXECUTE format('
			SELECT fgm.cdb_schema, fgm.parent_objectclass_id, fgm.objectclass_id, fgm.geometry_name, fgm.lod
			FROM %I.feature_geometry_metadata AS fgm
			WHERE fgm.cdb_schema = %L AND fgm.parent_objectclass_id = %L AND fgm.objectclass_id = %L
				AND (fgm.view_name IS NOT NULL OR fgm.mview_name IS NOT NULL)
		', qi_usr_schema, qi_cdb_schema, p_oc_id, oc_id)
	LOOP
		view_exists := TRUE;
	    PERFORM qgis_pkg.drop_geometry_view(
	        qi_usr_schema,
	        qi_cdb_schema, 
	        r.parent_objectclass_id, 
	        r.objectclass_id,
	        r.geometry_name,
			r.lod
	    );
	END LOOP;
ELSE
	RAISE NOTICE 'Drop all geometry (materialized) view(s) in schema %', cdb_schema;
	FOR r IN 
		EXECUTE format('
			SELECT fgm.cdb_schema, fgm.parent_objectclass_id, fgm.objectclass_id, fgm.geometry_name, fgm.lod
	    	FROM %I.feature_geometry_metadata AS fgm
	    	WHERE fgm.cdb_schema = %L AND NOT (fgm.view_name IS NULL AND fgm.mview_name IS NULL)
		', qi_usr_schema, qi_cdb_schema)
	LOOP
		view_exists := TRUE;
	    PERFORM qgis_pkg.drop_geometry_view(
	        qi_usr_schema,
	        qi_cdb_schema, 
	        r.parent_objectclass_id, 
	        r.objectclass_id,
	        r.geometry_name,
			r.lod
	    );
	END LOOP;
END IF;

IF NOT view_exists THEN
	IF NOT (parent_objectclass_id IS NULL AND objectclass_id IS NULL) THEN
		RAISE EXCEPTION 'The geometry (materialized) view(s) of % (p_oc_id = % AND oc_id = %) does not exist in %_feature_geometry_data table.', target_class, p_oc_id, oc_id, qi_usr_schema;
		RETURN;
	ELSE
		RAISE EXCEPTION 'No geometry (materialized) view(s) exist in %_feature_geometry_data table.', qi_usr_schema;
	END IF;
END IF;

END;
$$ LANGUAGE plpgsql;
COMMENT ON FUNCTION qgis_pkg.drop_all_geometry_views(varchar, varchar, integer, integer) IS 'Drop all available geometry (materialized) views in the specified schema';
REVOKE EXECUTE ON FUNCTION qgis_pkg.drop_all_geometry_views(varchar, varchar, integer, integer) FROM PUBLIC;
-- Example
-- SELECT * FROM qgis_pkg.drop_all_geometry_views('qgis_bstsai', 'citydb'); -- drop all v & mv
-- SELECT * FROM qgis_pkg.drop_all_geometry_views('qgis_bstsai', 'citydb', 0, 901); -- drop all v & mv of oc_id = 901
-- SELECT * FROM qgis_pkg.drop_all_geometry_views('qgis_bstsai', 'citydb', 0, 1301); -- drop all v & mv of oc_id = 1301
-- SELECT * FROM qgis_pkg.drop_all_geometry_views('qgis_bstsai', 'citydb', 901, 709); -- drop all v & mv of p_oc_id = 901, oc_id = 709
-- SELECT * FROM qgis_pkg.drop_all_geometry_views('qgis_bstsai', 'citydb', 901, 716); -- drop all v & mv error test
-- ***********************************************************************
--
--      QGIS Package for the CityGML 3D City Database (for PostgreSQL)
--
--
--                        Copyright 2023
--
-- Delft University of Technology, The Netherlands
-- 3D Geoinformation Group
-- https://3d.bk.tudelft.nl/
-- 
-- Licensed under the Apache License, Version 2.0 (the "License");
-- you may not use this file except in compliance with the License.
-- You may obtain a copy of the License at
-- 
--     http://www.apache.org/licenses/LICENSE-2.0
--     
-- Unless required by applicable law or agreed to in writing, software
-- distributed under the License is distributed on an "AS IS" BASIS,
-- WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
-- See the License for the specific language governing permissions and
-- limitations under the License.
--
-- Author: Giorgio Agugiaro
-- Delft University of Technology, The Netherlands
-- 3D Geoinformation Group
-- https://3d.bk.tudelft.nl/gagugiaro/
--
-- ***********************************************************************
--
-- This script created the qgis_pkg schema, and then installs a set of functions into it
-- List of functions:
--
-- qgis_pkg.qgis_pkg_version()
-- qgis_pkg.is_superuser(...)
-- qgis_pkg.cleanup_schema(...)
-- qgis_pkg.create_qgis_pkg_usrgroup_name()
-- qgis_pkg.create_qgis_pkg_usrgroup()
-- qgis_pkg.add_user_to_qgis_pkg_group(...);
-- qgis_pkg.remove_user_from_qgis_pkg_group(...);
-- qgis_pkg.list_qgis_pkg_usrgroup_members()
-- qgis_pkg.list_qgis_pkg_non_usrgroup_members()
-- qgis_pkg.create_default_qgis_pkg_user()
-- qgis_pkg.create_qgis_usr_schema_name(...)
-- qgis_pkg.list_cdb_schemas()
-- qgis_pkg.list_cdb_schemas_n_feats()
-- qgis_pkg.list_cdb_schemas_privs(...)
-- qgis_pkg.list_cdb_schemas_privs_n_features(...)
-- qgis_pkg.list_ades(...)
-- qgis_pkg.add_ga_indices(...)
-- qgis_pkg.drop_ga_indices(...)
-- qgis_pkg.create_qgis_usr_schema(...)
-- qgis_pkg.list_usr_schemas()
-- qgis_pkg.grant_qgis_usr_privileges(...)
-- qgis_pkg.revoke_qgis_usr_privileges(...)
-- qgis_pkg.compute_cdb_schema_extents(...)
-- qgis_pkg.upsert_extents(...)
-- qgis_pkg.generate_mview_bbox_poly(...)
-- qgis_pkg.list_feature_types(...)
-- qgis_pkg.feature_type_checker(...)
-- qgis_pkg.feature_type_counter(...)
-- qgis_pkg.root_class_checker(...)
-- qgis_pkg.root_class_counter(...)
-- qgis_pkg.has_layers_for_cdb_schema(...)
-- qgis_pkg.class_name_to_class_id(...)
-- qgis_pkg.gview_counter(...)
-- qgis_pkg.upsert_settings(...)
-- qgis_pkg.compute_schema_size()
-- qgis_pkg.st_3darea_poly(...)
-- qgis_pkg.st_snap_poly_to_grid(...)
-- qgis_pkg.generate_sql_matview_header(...)
-- qgis_pkg.generate_sql_matview_footer(...)
-- qgis_pkg.generate_sql_view_header(...)
-- qgis_pkg.generate_sql_matview_else(...)
-- qgis_pkg.generate_sql_triggers(...)
--
-- ***********************************************************************

-- Drop schema if it already exists from before.
DROP SCHEMA IF EXISTS qgis_pkg CASCADE;
-- Create new qgis_pkg schema;
CREATE SCHEMA         qgis_pkg;
-- Add "uuid-ossp" extension (if not already installed);
CREATE EXTENSION IF NOT EXISTS "uuid-ossp" SCHEMA public;


----------------------------------------------------------------
-- Create FUNCTION QGIS_PKG.QGIS_PKG_VERSION
----------------------------------------------------------------
-- Returns the version of the QGIS Package
DROP FUNCTION IF EXISTS    qgis_pkg.qgis_pkg_version() CASCADE;
CREATE OR REPLACE FUNCTION qgis_pkg.qgis_pkg_version()
RETURNS TABLE (
version 		text,
full_version    text,
major_version	integer,
minor_version	integer,
minor_revision	integer,
code_name		varchar,
release_date	date
)
AS $$
DECLARE

BEGIN
major_version  := 0;
minor_version  := 10;
minor_revision := 2;
code_name      := 'Nero and Poppaea';
release_date   := '2023-08-28'::date;
version        := concat(major_version,'.',minor_version,'.',minor_revision);
full_version   := concat(major_version,'.',minor_version,'.',minor_revision,' "',code_name,'", released on ',release_date);

RETURN NEXT;

EXCEPTION
	WHEN QUERY_CANCELED THEN
		RAISE  'qgis_pkg.qgis_pkg_version(): Error QUERY_CANCELED';
  WHEN OTHERS THEN 
		RAISE EXCEPTION 'qgis_pkg.qgis_pkg_version(): %', SQLERRM;
END;
$$ LANGUAGE plpgsql;
COMMENT ON FUNCTION qgis_pkg.qgis_pkg_version() IS 'Returns the version of the QGIS Package for the 3DCityDB';
REVOKE EXECUTE ON FUNCTION qgis_pkg.qgis_pkg_version() FROM public;

-- Example:
-- SELECT version, major_version, minor_version, minor_revision FROM qgis_pkg.qgis_pkg_version();

----------------------------------------------------------------
-- Create FUNCTION QGIS_PKG.IS_SUPERUSER
----------------------------------------------------------------
-- Checks if the provided user (or the current user) is a superuser or not
DROP FUNCTION IF EXISTS    qgis_pkg.is_superuser(varchar) CASCADE;
CREATE OR REPLACE FUNCTION qgis_pkg.is_superuser(
usr_name	varchar DEFAULT NULL
)
RETURNS boolean
AS $$
DECLARE
BEGIN
IF usr_name IS NULL THEN 
	usr_name := current_user;
END IF;

IF EXISTS (SELECT 1 FROM pg_user WHERE usesuper IS TRUE AND quote_ident(usename) = quote_ident(usr_name)) THEN
	--RAISE NOTICE 'User "%" is a superuser', usr_name;
	RETURN TRUE;
ELSE
	--RAISE NOTICE 'User "%" is NOT a superuser', usr_name;
	RETURN FALSE;
END IF;

EXCEPTION
	WHEN QUERY_CANCELED THEN
		RAISE EXCEPTION 'qgis_pkg.is_superuser(): Error QUERY_CANCELED';
	WHEN OTHERS THEN 
		RAISE EXCEPTION 'qgis_pkg.is_superuser(): %', SQLERRM;
END;
$$ LANGUAGE plpgsql;
COMMENT ON FUNCTION qgis_pkg.is_superuser(varchar) IS 'Check if the current user is a database superuser';
REVOKE EXECUTE ON FUNCTION qgis_pkg.is_superuser(varchar) FROM public;

--Example:
-- SELECT qgis_pkg.is_superuser(NULL);
-- SELECT qgis_pkg.is_superuser('postgres');
-- SELECT qgis_pkg.is_superuser('qgis_user_ro');


----------------------------------------------------------------
-- Create FUNCTION QGIS_PKG.CLEANUP_SCHEMA
----------------------------------------------------------------
-- Cleans up the whole schema, i.e. it truncates all tables.
-- The reason for this apparently duplicated function for the 3DCityDB
-- is that it allows to users with RW and TRUNCATE privileges to clean up the schema.
-- This function makes it available because it uses the 
-- TRUNCATE .... RESTART IDENTITY CASCADE command, 
-- while the original one still uses the "old way"
-- TRUNCATE ... CASCADE and ALTER SEQUENCE ... RESTART.
-- This is however a problem, as only owners of the sequence (e.g. postgres) can restart it.
DROP FUNCTION IF EXISTS    qgis_pkg.cleanup_schema(varchar);
CREATE OR REPLACE FUNCTION qgis_pkg.cleanup_schema(
cdb_schema	varchar
)
RETURNS void 
AS $$
DECLARE
cdb_schemas_array 	CONSTANT varchar[] := (SELECT array_agg(s.cdb_schema) FROM qgis_pkg.list_cdb_schemas(FALSE) AS s);
rec RECORD;

BEGIN
-- Check that the cdb_schema exists and is valid
IF (cdb_schema IS NULL) OR NOT cdb_schema = ANY(cdb_schemas_array) THEN
	RAISE EXCEPTION 'cdb_schema is invalid. It must be one of %', cdb_schemas_array;
END IF;

-- Truncate tables
FOR rec IN
    SELECT table_name FROM information_schema.tables where table_schema = cdb_schema
    AND table_name <> 'database_srs'
    AND table_name <> 'objectclass'
    AND table_name <> 'index_table'
    AND table_name <> 'ade'
    AND table_name <> 'schema'
    AND table_name <> 'schema_to_objectclass'
    AND table_name <> 'schema_referencing'
    AND table_name <> 'aggregation_info'
    AND table_name NOT LIKE 'tmp_%'
  LOOP
   	EXECUTE format('TRUNCATE TABLE %I.%I CASCADE', cdb_schema, rec.table_name);
	-- This would suffice, if the tables were created using the IDENTITY clause.
	--EXECUTE format('TRUNCATE TABLE %I.%I RESTART IDENTITY CASCADE', cdb_schema, rec.table_name);
  END LOOP;

FOR rec IN 
    SELECT sequence_name FROM information_schema.sequences where sequence_schema = cdb_schema
    AND sequence_name <> 'ade_seq'
    AND sequence_name <> 'schema_seq'
  LOOP
	-- The user must be owner of the sequence to RESTART it.
	-- EXECUTE format('ALTER SEQUENCE %I.%I RESTART', cdb_schema, rec.sequence_name);
	-- In this way, the user can reset it to 1 even without ownership.
    EXECUTE format('SELECT setval(''%I.%I'', 1, false)', cdb_schema, rec.sequence_name);
  END LOOP;

EXCEPTION
	WHEN QUERY_CANCELED THEN
		RAISE EXCEPTION 'qgis_pkg.cleanup_schema(): Error QUERY_CANCELED';
  WHEN OTHERS THEN 
		RAISE EXCEPTION 'qgis_pkg.cleanup_schema(): %', SQLERRM;
END;
$$ LANGUAGE 'plpgsql';
COMMENT ON FUNCTION qgis_pkg.cleanup_schema(varchar) IS 'Cleans up the selected schema (BEWARE: it truncates all tables!)';
REVOKE EXECUTE ON FUNCTION qgis_pkg.cleanup_schema(varchar) FROM public;

-- Example
-- SELECT qgis_pkg.cleanup_schema('citydb');


----------------------------------------------------------------
-- Create FUNCTION QGIS_PKG.CREATE_QGIS_PKG_USRGROUP_NAME
----------------------------------------------------------------
-- Creates the name of the schema for the current database instance
DROP FUNCTION IF EXISTS    qgis_pkg.create_qgis_pkg_usrgroup_name() CASCADE;
CREATE OR REPLACE FUNCTION qgis_pkg.create_qgis_pkg_usrgroup_name()
RETURNS varchar
AS $$
DECLARE
qgis_pkg_usrgroup_prefix CONSTANT varchar := 'qgis_pkg_usrgroup_';
qgis_pkg_usrgroup_name varchar; 

BEGIN
qgis_pkg_usrgroup_name := concat(qgis_pkg_usrgroup_prefix, current_database());

RETURN qgis_pkg_usrgroup_name;

EXCEPTION
	WHEN QUERY_CANCELED THEN
		RAISE EXCEPTION 'qgis_pkg.create_qgis_pkg_usrgroup_name(): Error QUERY_CANCELED';
  WHEN OTHERS THEN 
		RAISE EXCEPTION 'qgis_pkg.create_qgis_pkg_usrgroup_name(): %', SQLERRM;
END;
$$ LANGUAGE plpgsql;
COMMENT ON FUNCTION qgis_pkg.create_qgis_pkg_usrgroup_name() IS 'Creates the name of the qgis_pkg database group for the current database';
REVOKE EXECUTE ON FUNCTION qgis_pkg.create_qgis_pkg_usrgroup_name() FROM public;

-- SELECT qgis_pkg.create_qgis_pkg_usrgroup_name();

----------------------------------------------------------------
-- Create FUNCTION QGIS_PKG.CREATE_QGIS_PKG_USRGROUP
----------------------------------------------------------------
-- Create the group "qgis_pgk_usr_name_*" for the current database
DROP FUNCTION IF EXISTS    qgis_pkg.create_qgis_pkg_usrgroup() CASCADE;
CREATE OR REPLACE FUNCTION qgis_pkg.create_qgis_pkg_usrgroup()
RETURNS varchar
AS $$
DECLARE
grp_name CONSTANT varchar := (SELECT qgis_pkg.create_qgis_pkg_usrgroup_name());
sql_statement	varchar;

BEGIN
--RAISE NOTICE 'Creating group "%"', grp_name;
sql_statement := concat('
-- Add/create role (user group)
CREATE ROLE ',quote_ident(grp_name),' WITH
	NOLOGIN
	NOSUPERUSER
	INHERIT
	NOCREATEDB
	NOCREATEROLE
	NOREPLICATION;
COMMENT ON ROLE ',quote_ident(grp_name),' IS ''Contains all users allowed to use the QGIS Package in database ',current_database(),''';
');
--RAISE NOTICE 'sql: %', sql_statement;

IF NOT EXISTS(SELECT 1 FROM information_schema.enabled_roles AS i WHERE role_name::varchar = grp_name) THEN
	--RAISE NOTICE 'Adding group "%"', grp_name;
	EXECUTE sql_statement;
ELSE
	RAISE NOTICE 'Group "%" already exists for current database', grp_name;
END IF;

RETURN grp_name;

EXCEPTION
	WHEN QUERY_CANCELED THEN
		RAISE EXCEPTION 'qgis_pkg.create_qgis_pkg_usrgroup(): Error QUERY_CANCELED';
  WHEN OTHERS THEN 
		RAISE EXCEPTION 'qgis_pkg.create_qgis_pkg_usrgroup(): %', SQLERRM;
END;
$$ LANGUAGE plpgsql;
COMMENT ON FUNCTION qgis_pkg.create_qgis_pkg_usrgroup() IS 'Create the group "qgis_pgk_usr_name_*" for the current database';
REVOKE EXECUTE ON FUNCTION qgis_pkg.create_qgis_pkg_usrgroup() FROM public;

-- Example
-- SELECT qgis_pkg.create_qgis_pkg_usrgroup();


----------------------------------------------------------------
-- Create FUNCTION QGIS_PKG.ADD_USER_TO_QGIS_PKG_USRGROUP
----------------------------------------------------------------
-- Creates the qgis schema for a user
DROP FUNCTION IF EXISTS    qgis_pkg.add_user_to_qgis_pkg_usrgroup(varchar) CASCADE;
CREATE OR REPLACE FUNCTION qgis_pkg.add_user_to_qgis_pkg_usrgroup(
INOUT usr_name	varchar
)
RETURNS varchar
AS $$
DECLARE
qgis_pkg_grp_name	CONSTANT varchar := (SELECT qgis_pkg.create_qgis_pkg_usrgroup_name());
sql_statement varchar;
BEGIN

EXECUTE format('GRANT %I TO %I;', qgis_pkg_grp_name, usr_name);
RAISE NOTICE 'User "%" added to group "%"', usr_name, qgis_pkg_grp_name; 

EXCEPTION
	WHEN QUERY_CANCELED THEN
		RAISE EXCEPTION 'qgis_pkg.add_user_to_qgis_pkg_usrgroup(): Error QUERY_CANCELED';
  WHEN OTHERS THEN 
		RAISE EXCEPTION 'qgis_pkg.add_user_to_qgis_pkg_usrgroup(): %', SQLERRM;
END;
$$ LANGUAGE plpgsql;
COMMENT ON FUNCTION qgis_pkg.add_user_to_qgis_pkg_usrgroup(varchar) IS 'Adds user to the qgis_pkg_usrgroup_* associated to the current database';
REVOKE EXECUTE ON FUNCTION qgis_pkg.add_user_to_qgis_pkg_usrgroup(varchar) FROM public;

-- Examples
-- SELECT qgis_pkg.add_user_to_qgis_pkg_usrgroup('giorgio');


----------------------------------------------------------------
-- Create FUNCTION QGIS_PKG.REMOVE_USER_FROM_QGIS_PKG_USRGROUP
----------------------------------------------------------------
-- Creates the qgis schema for a user
DROP FUNCTION IF EXISTS    qgis_pkg.remove_user_from_qgis_pkg_usrgroup(varchar) CASCADE;
CREATE OR REPLACE FUNCTION qgis_pkg.remove_user_from_qgis_pkg_usrgroup(
INOUT usr_name	varchar
)
RETURNS varchar
AS $$
DECLARE
qgis_pkg_grp_name	CONSTANT varchar := (SELECT qgis_pkg.create_qgis_pkg_usrgroup_name());
sql_statement varchar;
BEGIN

EXECUTE format('REVOKE %I FROM %I;', qgis_pkg_grp_name, usr_name);
RAISE NOTICE 'User "%" removed from group "%"', usr_name, qgis_pkg_grp_name; 

EXCEPTION
	WHEN QUERY_CANCELED THEN
		RAISE EXCEPTION 'qgis_pkg.remove_user_from_qgis_pkg_usrgroup(): Error QUERY_CANCELED';
  WHEN OTHERS THEN 
		RAISE EXCEPTION 'qgis_pkg.remove_user_from_qgis_pkg_usrgroup(): %', SQLERRM;
END;
$$ LANGUAGE plpgsql;
COMMENT ON FUNCTION qgis_pkg.remove_user_from_qgis_pkg_usrgroup(varchar) IS 'Adds user to the qgis_pkg_usrgroup_* associated to the current database';
REVOKE EXECUTE ON FUNCTION qgis_pkg.remove_user_from_qgis_pkg_usrgroup(varchar) FROM public;

-- Examples
-- SELECT qgis_pkg.remove_user_from_qgis_pkg_usrgroup('giorgio');


----------------------------------------------------------------
-- Create FUNCTION QGIS_PKG.LIST_QGIS_PKG_URSGROUP_MEMBERS
----------------------------------------------------------------
-- List all database users that belong to the group ('qgis_pkg_usrgroup_*') assigned to the current database
DROP FUNCTION IF EXISTS    qgis_pkg.list_qgis_pkg_usrgroup_members() CASCADE;
CREATE OR REPLACE FUNCTION qgis_pkg.list_qgis_pkg_usrgroup_members()
RETURNS 
TABLE (
usr_name varchar
)
AS $$
DECLARE
qgis_pkg_usrgroup_name CONSTANT varchar := (SELECT qgis_pkg.create_qgis_pkg_usrgroup_name());

BEGIN

RETURN QUERY
	SELECT i.grantee::varchar AS usr_name
	FROM information_schema.applicable_roles AS i
	WHERE quote_ident(i.role_name) = quote_ident(qgis_pkg_usrgroup_name)
	ORDER BY i.grantee ASC;

EXCEPTION
	WHEN QUERY_CANCELED THEN
		RAISE EXCEPTION 'qgis_pkg.list_qgis_pkg_usrgroup_members(): Error QUERY_CANCELED';
  WHEN OTHERS THEN 
		RAISE EXCEPTION 'qgis_pkg.list_qgis_pkg_usrgroup_members(): %', SQLERRM;
END;
$$ LANGUAGE plpgsql;
COMMENT ON FUNCTION qgis_pkg.list_qgis_pkg_usrgroup_members() IS 'List all database users that belong to the group (''qgis_pkg_usrgroup_*'') assigned to the current database';
REVOKE EXECUTE ON FUNCTION qgis_pkg.list_qgis_pkg_usrgroup_members() FROM public;

-- Example:
-- SELECT usr_name FROM qgis_pkg.list_qgis_pkg_usrgroup_members();
-- SELECT array_agg(s.usr_name) FROM qgis_pkg.list_qgis_pkg_usrgroup_members() AS s;


----------------------------------------------------------------
-- Create FUNCTION QGIS_PKG.LIST_QGIS_PKG_NON_URSGROUP_MEMBERS
----------------------------------------------------------------
-- Lists all users that are not part of the qgis_pkg_usrgroup_* group associated to the current database
DROP FUNCTION IF EXISTS    qgis_pkg.list_qgis_pkg_non_usrgroup_members() CASCADE;
CREATE OR REPLACE FUNCTION qgis_pkg.list_qgis_pkg_non_usrgroup_members()
RETURNS 
TABLE (
usr_name varchar
)
AS $$
DECLARE
qgis_pkg_usrgroup_name CONSTANT varchar := (SELECT qgis_pkg.create_qgis_pkg_usrgroup_name());

BEGIN

RETURN QUERY
	SELECT foo.usr_name FROM (
		SELECT c.usename::varchar as usr_name 
		FROM pg_catalog.pg_user AS c
		
		EXCEPT
		
		SELECT i.grantee::varchar AS usr_name
		FROM information_schema.applicable_roles AS i
		WHERE quote_ident(i.role_name) = quote_ident(qgis_pkg_usrgroup_name)) AS foo
	ORDER BY foo.usr_name ASC;

EXCEPTION
	WHEN QUERY_CANCELED THEN
		RAISE EXCEPTION 'qgis_pkg.list_qgis_pkg_non_usrgroup_members(): Error QUERY_CANCELED';
  WHEN OTHERS THEN 
		RAISE EXCEPTION 'qgis_pkg.list_qgis_pkg_non_usrgroup_members(): %', SQLERRM;
END;
$$ LANGUAGE plpgsql;
COMMENT ON FUNCTION qgis_pkg.list_qgis_pkg_non_usrgroup_members() IS 'List all database users that do not belong to group "qgis_pkg_usrgroup_* associated to the current database"';
REVOKE EXECUTE ON FUNCTION qgis_pkg.list_qgis_pkg_non_usrgroup_members() FROM public;

-- Example:
-- SELECT usr_name FROM qgis_pkg.list_qgis_pkg_non_usrgroup_members();
-- SELECT array_agg(s.usr_name) FROM qgis_pkg.list_qgis_pkg_non_usrgroup_members() AS s;


----------------------------------------------------------------
-- Create FUNCTION QGIS_PKG.CREATE_QGIS_USR_SCHEMA_NAME
----------------------------------------------------------------
-- Creates the name of the schema for a certain user (prefixed: "qgis_")
DROP FUNCTION IF EXISTS    qgis_pkg.create_qgis_usr_schema_name(varchar) CASCADE;
CREATE OR REPLACE FUNCTION qgis_pkg.create_qgis_usr_schema_name(
usr_name varchar
)
RETURNS varchar
AS $$
DECLARE
qgis_usr_schema_prefix	CONSTANT varchar := 'qgis_';
qgis_usr_name_array		CONSTANT varchar[] := ARRAY['qgis_user_ro','qgis_user_rw'];
qgis_usr_schema varchar; 

BEGIN
-- Check that the user exists
IF usr_name IS NULL OR NOT EXISTS(SELECT 1 FROM information_schema.enabled_roles AS i WHERE i.role_name::varchar = usr_name) THEN
	RAISE EXCEPTION 'usr_name is invalid. It must be an existing database user';
END IF;

-- Special case for the default users 'qgis_user_ro' and 'qgis_user_rw'
IF usr_name = ANY(qgis_usr_name_array) THEN
	qgis_usr_schema := usr_name;
ELSE
	qgis_usr_schema := concat(qgis_usr_schema_prefix, usr_name);
END IF;

RETURN qgis_usr_schema;

EXCEPTION
	WHEN QUERY_CANCELED THEN
		RAISE EXCEPTION 'qgis_pkg.create_qgis_usr_schema_name(): Error QUERY_CANCELED';
  WHEN OTHERS THEN 
		RAISE EXCEPTION 'qgis_pkg.create_qgis_usr_schema_name(): %', SQLERRM;
END;
$$ LANGUAGE plpgsql;
COMMENT ON FUNCTION qgis_pkg.create_qgis_usr_schema_name(varchar) IS 'Creates the qgis schema name for the provided user';
REVOKE EXECUTE ON FUNCTION qgis_pkg.create_qgis_usr_schema_name(varchar) FROM public;

--Example (works also with "crazy" user names using special (but legal) characters:
--SELECT qgis_pkg.create_qgis_usr_schema_name('giorgio');
--SELECT qgis_pkg.create_qgis_usr_schema_name('g.a@nl');


----------------------------------------------------------------
-- Create FUNCTION QGIS_PKG.LIST_CDB_SCHEMAS
----------------------------------------------------------------
-- List all schemas containing citydb tables in the current database and (optionally) picks only the non-empty ones
DROP FUNCTION IF EXISTS    qgis_pkg.list_cdb_schemas(boolean) CASCADE;
CREATE OR REPLACE FUNCTION qgis_pkg.list_cdb_schemas(
	only_non_empty	boolean DEFAULT FALSE)
RETURNS TABLE (
	cdb_schema 		varchar,  -- name of the citydb schema
	is_empty		boolean
)
AS $$
DECLARE
cdb_name CONSTANT varchar := current_database()::varchar;
r RECORD;

BEGIN

FOR r IN 
	SELECT i.schema_name 
	FROM information_schema.schemata AS i
	WHERE 
		i.catalog_name::varchar = cdb_name
		AND i.schema_name::varchar NOT LIKE 'pg_%'
		AND i.schema_name::varchar NOT IN ('information_schema', 'public', 'citydb_pkg')
		AND i.schema_name::varchar NOT LIKE 'qgis_%'
	ORDER BY i.schema_name ASC
LOOP
	IF -- check that it is indeed a citydb schema
		EXISTS(SELECT version FROM citydb_pkg.citydb_version())
			AND
		EXISTS(SELECT 1 FROM information_schema.tables AS t WHERE t.table_schema = r.schema_name AND t.table_name = 'cityobject')
			AND
		EXISTS(SELECT 1 FROM information_schema.tables AS t WHERE t.table_schema = r.schema_name AND t.table_name = 'objectclass')		
		  AND
		EXISTS(SELECT 1 FROM information_schema.tables AS t WHERE t.table_schema = r.schema_name AND t.table_name = 'surface_geometry')	
			AND
		EXISTS(SELECT 1 FROM information_schema.tables AS t WHERE t.table_schema = r.schema_name AND t.table_name = 'appearance')
	THEN 
		cdb_schema := r.schema_name::varchar;
		is_empty := NULL;
		
		EXECUTE format('SELECT NOT EXISTS(SELECT 1 FROM %I.cityobject LIMIT 1)',cdb_schema) INTO is_empty;

		IF only_non_empty IS NULL OR only_non_empty IS FALSE THEN
			RETURN NEXT;
		ELSE		
			IF is_empty IS FALSE THEN
				RETURN NEXT;
			ELSE
				-- do not return it, it's empty
			END IF;
		END IF;
	END IF;
END LOOP;

EXCEPTION
	WHEN QUERY_CANCELED THEN
		RAISE EXCEPTION 'qgis_pkg.list_cdb_schemas(): Error QUERY_CANCELED';
	WHEN OTHERS THEN 
		RAISE EXCEPTION 'qgis_pkg.list_cdb_schemas(): %', SQLERRM;
END;
$$ LANGUAGE plpgsql;
COMMENT ON FUNCTION qgis_pkg.list_cdb_schemas(boolean) IS 'List all schemas containing citydb tables in the current database, and optionally only the non-empty ones';
REVOKE EXECUTE ON FUNCTION qgis_pkg.list_cdb_schemas(boolean) FROM public;

--SELECT a.* FROM qgis_pkg.list_cdb_schemas(only_non_empty:=FALSE) AS a;
--SELECT a.* FROM qgis_pkg.list_cdb_schemas(only_non_empty:=TRUE) AS a;


----------------------------------------------------------------
-- Create FUNCTION QGIS_PKG.LIST_CDB_SCHEMAS_N_FEATS
----------------------------------------------------------------
-- List all schemas containing citydb tables in the current database and (optionally) picks only the non-empty ones
DROP FUNCTION IF EXISTS    qgis_pkg.list_cdb_schemas_n_feats(boolean) CASCADE;
CREATE OR REPLACE FUNCTION qgis_pkg.list_cdb_schemas_n_feats(
	only_non_empty	boolean DEFAULT FALSE)
RETURNS TABLE (
	cdb_schema 		varchar,  -- name of the citydb schema
	co_number		bigint    -- number of cityobjects stored in that schema
)
AS $$
DECLARE
cdb_name CONSTANT varchar := current_database()::varchar;
r RECORD;

BEGIN

FOR r IN 
	SELECT i.schema_name 
	FROM information_schema.schemata AS i
	WHERE 
		i.catalog_name::varchar = cdb_name
		AND i.schema_name::varchar NOT LIKE 'pg_%'
		AND i.schema_name::varchar NOT IN ('information_schema', 'public', 'citydb_pkg')
		AND i.schema_name::varchar NOT LIKE 'qgis_%'
	ORDER BY i.schema_name ASC
LOOP
	IF -- check that it is indeed a citydb schema
		EXISTS(SELECT version FROM citydb_pkg.citydb_version())
			AND
		EXISTS(SELECT 1 FROM information_schema.tables AS t WHERE t.table_schema = r.schema_name AND t.table_name = 'cityobject')
			AND
		EXISTS(SELECT 1 FROM information_schema.tables AS t WHERE t.table_schema = r.schema_name AND t.table_name = 'objectclass')		
			AND
		EXISTS(SELECT 1 FROM information_schema.tables AS t WHERE t.table_schema = r.schema_name AND t.table_name = 'surface_geometry')	
			AND
		EXISTS(SELECT 1 FROM information_schema.tables AS t WHERE t.table_schema = r.schema_name AND t.table_name = 'appearance')
	THEN 
		cdb_schema := r.schema_name::varchar;
		co_number := NULL;

		-- Counting rows with count(id) is known to be a very slow function in PostgreSQL with large tables
		-- We will have to rewrite to something faster and rething the approach.
		-- Actually, we may not need always need a precise number of cityobjects
		--
		EXECUTE format('SELECT count(id) FROM %I.cityobject', r.schema_name) INTO co_number;

		IF only_non_empty IS NULL OR only_non_empty IS FALSE THEN
			RETURN NEXT;
		ELSE		
			IF co_number > 0 THEN
				RETURN NEXT;
			ELSE
				-- do not return it, it's empty
			END IF;
		END IF;
	END IF;
END LOOP;

EXCEPTION
	WHEN QUERY_CANCELED THEN
		RAISE EXCEPTION 'qgis_pkg.list_cdb_schemas_n_feats(): Error QUERY_CANCELED';
	WHEN OTHERS THEN 
		RAISE EXCEPTION 'qgis_pkg.list_cdb_schemas_n_feats(): %', SQLERRM;
END;
$$ LANGUAGE plpgsql;
COMMENT ON FUNCTION qgis_pkg.list_cdb_schemas_n_feats(boolean) IS 'List all schemas containing citydb tables in the current database, and optionally only the non-empty ones';
REVOKE EXECUTE ON FUNCTION qgis_pkg.list_cdb_schemas_n_feats(boolean) FROM public;

--SELECT a.* FROM qgis_pkg.list_cdb_schemas_n_feats(only_non_empty:=FALSE) AS a;
--SELECT a.* FROM qgis_pkg.list_cdb_schemas_n_feats(only_non_empty:=TRUE) AS a;


----------------------------------------------------------------
-- Create FUNCTION QGIS_PKG.LIST_CDB_SCHEMAS_PRIVS
----------------------------------------------------------------
-- List all cdb_schemas with privileges information regarding the usr_name
DROP FUNCTION IF EXISTS    qgis_pkg.list_cdb_schemas_privs(varchar);
CREATE OR REPLACE FUNCTION qgis_pkg.list_cdb_schemas_privs(
usr_name	varchar
)
RETURNS TABLE (
cdb_schema 		varchar,	-- name of the citydb schema
is_empty		boolean,	-- is the schema empty?
priv_type		varchar		-- type of privileges ('none', 'ro', 'rw')	
)
AS $$
DECLARE
usr_names_array		CONSTANT varchar[] := (SELECT array_agg(s.usr_name) FROM qgis_pkg.list_qgis_pkg_usrgroup_members() AS s);
curr_db				CONSTANT varchar := current_database();

BEGIN
IF (usr_name IS NULL) OR (NOT usr_name = ANY (usr_names_array)) THEN
	RAISE EXCEPTION 'usr_name is invalid. It must belong to the qgis_pkg_usr_group associated to the current database';
END IF;

RETURN QUERY
	SELECT s.cdb_schema:: varchar, s.is_empty, --p.usr_name, --p.priv_array,
	CASE 
		WHEN p.priv_array IS NULL THEN 'none'::varchar
		WHEN 'INSERT' = ANY (p.priv_array) THEN 'rw'::varchar
		ELSE 'ro'::varchar
	END AS priv_type
	FROM qgis_pkg.list_cdb_schemas(only_non_empty := FALSE) AS s
	LEFT JOIN (
		SELECT 
			table_catalog AS curr_db, 
			table_schema AS cdb_schema, 
			grantee AS usr_name,
			-- array_agg(privilege_type) AS priv_array
			array_agg(privilege_type::varchar) AS priv_array  -- type cast added for compatibility in PostgreSQL 10
		FROM (
			SELECT rt.table_catalog, rt.table_schema, rt.grantee, rt.privilege_type
			FROM information_schema.role_table_grants AS rt
			WHERE rt.table_name='cityobject' AND quote_ident(rt.table_catalog) = quote_ident(curr_db) AND quote_ident(rt.grantee) = quote_ident(usr_name)
			ORDER BY rt.table_catalog, rt.table_schema, rt.grantee, rt.privilege_type
		) AS foo
		GROUP BY foo.table_catalog, foo.table_schema, foo.grantee
		) AS p ON (s.cdb_schema = p.cdb_schema)
	ORDER BY s.cdb_schema, p.usr_name;

EXCEPTION
	WHEN QUERY_CANCELED THEN
		RAISE EXCEPTION 'qgis_pkg.list_cdb_schemas_privs(): Error QUERY_CANCELED';
  WHEN OTHERS THEN 
		RAISE EXCEPTION 'qgis_pkg.list_cdb_schemas_privs(): %', SQLERRM;
END;
$$ LANGUAGE plpgsql;
COMMENT ON FUNCTION qgis_pkg.list_cdb_schemas_privs(varchar) IS 'List all cdb_schemas with privileges information regarding the usr_name';
REVOKE EXECUTE ON FUNCTION qgis_pkg.list_cdb_schemas_privs(varchar) FROM public;

-- Example
-- SELECT * FROM qgis_pkg.list_cdb_schemas_privs('qgis_user_ro');


----------------------------------------------------------------
-- Create FUNCTION qgis_pkg.list_cdb_schemas_privs_n_features
----------------------------------------------------------------
-- List all cdb_schemas with privileges information regarding the usr_name
DROP FUNCTION IF EXISTS    qgis_pkg.list_cdb_schemas_privs_n_features(varchar);
CREATE OR REPLACE FUNCTION qgis_pkg.list_cdb_schemas_privs_n_features(
usr_name	varchar
)
RETURNS TABLE (
cdb_schema 		varchar,	-- name of the citydb schema
co_number		bigint,		-- number of cityobjects stored in that schema
priv_type		varchar		-- type of privileges ('none', 'ro', 'rw')	
)
AS $$
DECLARE
usr_names_array		CONSTANT varchar[] := (SELECT array_agg(s.usr_name) FROM qgis_pkg.list_qgis_pkg_usrgroup_members() AS s);
curr_db				CONSTANT varchar := current_database();

BEGIN
IF (usr_name IS NULL) OR (NOT usr_name = ANY (usr_names_array)) THEN
	RAISE EXCEPTION 'usr_name is invalid. It must belong to the qgis_pkg_usr_group associated to the current database';
END IF;

RETURN QUERY
	SELECT s.cdb_schema:: varchar, s.co_number,--p.usr_name, --p.priv_array,
	CASE 
		WHEN p.priv_array IS NULL THEN 'none'::varchar
		WHEN 'INSERT' = ANY (p.priv_array) THEN 'rw'::varchar
		ELSE 'ro'::varchar
	END AS priv_type
	FROM qgis_pkg.list_cdb_schemas_n_feats(FALSE) AS s
	LEFT JOIN (
		SELECT 
			table_catalog AS curr_db, 
			table_schema AS cdb_schema, 
			grantee AS usr_name,
			-- array_agg(privilege_type) AS priv_array
			array_agg(privilege_type::varchar) AS priv_array  -- type cast added for compatibility in PostgreSQL 10
		FROM (
			SELECT rt.table_catalog, rt.table_schema, rt.grantee, rt.privilege_type
			FROM information_schema.role_table_grants AS rt
			WHERE rt.table_name='cityobject' AND quote_ident(rt.table_catalog) = quote_ident(curr_db) AND quote_ident(rt.grantee) = quote_ident(usr_name)
			ORDER BY rt.table_catalog, rt.table_schema, rt.grantee, rt.privilege_type
		) AS foo
		GROUP BY foo.table_catalog, foo.table_schema, foo.grantee
		) AS p ON (s.cdb_schema = p.cdb_schema)
	ORDER BY s.cdb_schema, p.usr_name;

EXCEPTION
	WHEN QUERY_CANCELED THEN
		RAISE EXCEPTION 'qgis_pkg.list_cdb_schemas_privs_n_features(): Error QUERY_CANCELED';
  WHEN OTHERS THEN 
		RAISE EXCEPTION 'qgis_pkg.list_cdb_schemas_privs_n_features(): %', SQLERRM;
END;
$$ LANGUAGE plpgsql;
COMMENT ON FUNCTION qgis_pkg.list_cdb_schemas_privs_n_features(varchar) IS 'List all cdb_schemas with privileges information regarding the usr_name';
REVOKE EXECUTE ON FUNCTION qgis_pkg.list_cdb_schemas_privs_n_features(varchar) FROM public;

-- Example
-- SELECT * FROM qgis_pkg.list_cdb_schemas_privs_n_features('qgis_user_ro');


----------------------------------------------------------------
-- Create FUNCTION QGIS_PKG.LIST_ADES
----------------------------------------------------------------
-- List all installed ADEs in the selected cdb_schema
DROP FUNCTION IF EXISTS    qgis_pkg.list_ades(varchar) CASCADE;
CREATE OR REPLACE FUNCTION qgis_pkg.list_ades(
INOUT cdb_schema 	varchar,
OUT ade_prefix		varchar,  -- ade_prefix (called db_prefix in the citydb)
OUT ade_name		varchar,  -- ade name
OUT ade_version		varchar   -- ade version
)
RETURNS SETOF record
AS $$
DECLARE
r RECORD;

BEGIN

FOR r IN 
	EXECUTE format('
		SELECT a.db_prefix AS ade_prefix, a.name AS ade_name, a.version AS ade_version 
		FROM %I.ade AS a 
		ORDER BY a.name',
		cdb_schema)
LOOP
	
	ade_prefix  := r.ade_prefix;
	ade_name	:= r.ade_name;
	ade_version := r.ade_version;	

	RETURN NEXT;

END LOOP;

RETURN;

EXCEPTION
	WHEN QUERY_CANCELED THEN
		RAISE EXCEPTION 'qgis_pkg.list_ades(): Error QUERY_CANCELED';
  WHEN OTHERS THEN 
		RAISE EXCEPTION 'qgis_pkg.list_ades(): %', SQLERRM;
END;
$$ LANGUAGE plpgsql;
COMMENT ON FUNCTION qgis_pkg.list_ades(varchar) IS 'List all ADEs installed in the selected cdb_schema';
REVOKE EXECUTE ON FUNCTION qgis_pkg.list_ades(varchar) FROM public;

--SELECT a.* FROM qgis_pkg.list_ades('citydb') AS a;


----------------------------------------------------------------
-- Create FUNCTION QGIS_PKG.LIST_CDB_SCHEMAS_USABILITY
----------------------------------------------------------------
-- List all cdb_schemas that can be accessed by usr_names belonging to the "qgis_pqk_usrgroup_*"
-- associated to the current database
DROP FUNCTION IF EXISTS    qgis_pkg.list_cdb_schemas_usability(varchar, varchar);
CREATE OR REPLACE FUNCTION qgis_pkg.list_cdb_schemas_usability(
INOUT usr_name		varchar DEFAULT NULL, -- NULL = all existing group members, otherwise to the given usr_name
INOUT cdb_schema	varchar DEFAULT NULL, -- NULL = all existing cdb_schemas, otherwise to the given schema (e.g. 'citydb').
OUT usable			boolean
)
RETURNS SETOF record
AS $$
DECLARE
usr_names_array		CONSTANT varchar[] := (SELECT array_agg(s.usr_name) FROM qgis_pkg.list_qgis_pkg_usrgroup_members() AS s);
cdb_schemas_array 	CONSTANT varchar[] := (SELECT array_agg(s.cdb_schema) FROM qgis_pkg.list_cdb_schemas(FALSE) AS s);

u varchar; u_array varchar[];
s varchar; s_array varchar[];
usable boolean;

BEGIN
--RAISE NOTICE '%', usr_names_array;
--RAISE NOTICE '%', cdb_schemas_array;

-- Check user name
IF usr_name IS NULL THEN
	u_array := usr_names_array;
ELSE  -- it is not null
	IF NOT usr_name = ANY(usr_names_array) THEN
		RAISE EXCEPTION 'usr_name is invalid: It must be one of "%"', usr_names_array;
	ELSE
		u_array := ARRAY[usr_name];
	END IF;
END IF;

-- Check user name
IF cdb_schema IS NULL THEN
	s_array := cdb_schemas_array;
ELSE  -- it is not null
	IF NOT cdb_schema = ANY(cdb_schemas_array) THEN
		RAISE EXCEPTION 'cdb_schema is invalid: It must be one of %', cdb_schemas_array;
	ELSE
		s_array := ARRAY[cdb_schema];
	END IF;
END IF;

FOREACH u IN ARRAY u_array LOOP
	FOREACH s IN ARRAY s_array LOOP
		usable := has_schema_privilege(u, s, 'USAGE');
		--RAISE NOTICE 'u %, s %, usable %', u, s, usable;
		RETURN QUERY
			SELECT u, s, usable;
	END LOOP;
END LOOP;

EXCEPTION
	WHEN QUERY_CANCELED THEN
		RAISE EXCEPTION 'qgis_pkg.list_cdb_schemas_usability(): Error QUERY_CANCELED';
  WHEN OTHERS THEN 
		RAISE EXCEPTION 'qgis_pkg.list_cdb_schemas_usability(): %', SQLERRM;
END;
$$ LANGUAGE plpgsql;
COMMENT ON FUNCTION qgis_pkg.list_cdb_schemas_usability(varchar, varchar) IS 'Checks whether usr_name(s) have USAGE privilege on cdb_schema(s)';
REVOKE EXECUTE ON FUNCTION qgis_pkg.list_cdb_schemas_usability(varchar, varchar) FROM public;

-- Examples
--SELECT * FROM qgis_pkg.list_cdb_schemas_usability(NULL, NULL) -- All users, all citydb schemas
--SELECT * FROM qgis_pkg.list_cdb_schemas_usability('giorgio', NULL) -- All schemas accessible by giorgio
--SELECT * FROM qgis_pkg.list_cdb_schemas_usability('giorgio', 'citydb') -- giorgio access citydb?
--SELECT * FROM qgis_pkg.list_cdb_schemas_usability(NULL, 'citydb') -- All users, citydb?


----------------------------------------------------------------
-- Create FUNCTION QGIS_PKG.ADD_GA_INDICES
----------------------------------------------------------------
-- This function adds indices to the table containing the generic attributes
-- It must be run ONLY ONCE in a specific dbschema, upon installation.
DROP FUNCTION IF EXISTS    qgis_pkg.add_ga_indices(varchar) CASCADE;
CREATE OR REPLACE FUNCTION qgis_pkg.add_ga_indices(
cdb_schema varchar
)
RETURNS void AS $$
DECLARE
index_object	citydb_pkg.index_obj;
index_exists	boolean;
seq_name 		varchar;
BEGIN

EXECUTE format('
		SELECT EXISTS(SELECT 1 FROM %I.index_table 
		WHERE (obj).index_name = ''ga_datatype_inx'' 
			AND (obj).table_name = ''cityobject_genericattrib'' 
			AND (obj).attribute_name = ''datatype'')', cdb_schema)
			INTO index_exists;
--RAISE NOTICE 'Exists %', index_exists;

IF index_exists IS TRUE THEN
	-- Do nothing, the index already exists
	--RAISE NOTICE 'Found';
ELSE
	--RAISE NOTICE 'Not found';
	-- Create the index object
	index_object.index_name     := 'ga_datatype_inx';
	index_object.table_name     := 'cityobject_genericattrib';
	index_object.attribute_name := 'datatype';
	index_object.type           := 0;
	index_object.srid           := 0;
	index_object.is_3d          := 0;

	-- Create the index and register it into the index_table
	RAISE NOTICE 'Adding index (only this time) ''%'' to table %.cityobject_genericattrib', (index_object).index_name, cdb_schema;
	seq_name := concat(quote_ident(cdb_schema),'.index_table_id_seq');
	EXECUTE format('
	WITH s AS (SELECT max(t.id) AS max_id FROM %I.index_table AS t)
	SELECT CASE WHEN s.max_id IS NULL     THEN setval(%L::regclass, 1, false)
				WHEN s.max_id IS NOT NULL THEN setval(%L::regclass, s.max_id, true) END
	FROM s;
	CREATE INDEX IF NOT EXISTS ga_datatype_inx ON %I.cityobject_genericattrib (datatype);
	INSERT INTO %I.index_table (obj) VALUES ($1);',
	cdb_schema,
	seq_name,
	seq_name,
	cdb_schema,
	cdb_schema) USING index_object;

END IF;

-- Other index... (if needed)
-- 
-- 

EXCEPTION
	WHEN QUERY_CANCELED THEN
		RAISE EXCEPTION 'qgis_pkg.add_ga_indices(): Error QUERY_CANCELED';
	WHEN OTHERS THEN 
		RAISE EXCEPTION 'qgis_pkg.add_ga_indices(): %', SQLERRM;
END;
$$ LANGUAGE plpgsql;
COMMENT ON FUNCTION qgis_pkg.add_ga_indices(varchar) IS 'Adds some indices to table cityobject_genericattrib';
REVOKE EXECUTE ON FUNCTION qgis_pkg.add_ga_indices(varchar) FROM public;

-- SELECT qgis_pkg.add_ga_indices(cdb_schema := 'citydb');


----------------------------------------------------------------
-- Create FUNCTION QGIS_PKG.DROP_GA_INDICES
----------------------------------------------------------------
-- This function adds indices to the table containing the generic attributes
-- It must be run ONLY ONCE in a specific dbschema, upon installation.
DROP FUNCTION IF EXISTS    qgis_pkg.drop_ga_indices(varchar) CASCADE;
CREATE OR REPLACE FUNCTION qgis_pkg.drop_ga_indices(
cdb_schema varchar
)
RETURNS void AS $$
DECLARE
index_object	citydb_pkg.index_obj;
index_id		integer := NULL;
seq_name 		varchar;
BEGIN

EXECUTE format('
		SELECT id FROM %I.index_table 
		WHERE (obj).index_name = ''ga_datatype_inx'' 
			AND (obj).table_name = ''cityobject_genericattrib'' 
			AND (obj).attribute_name = ''datatype''
		', cdb_schema) INTO index_id;
--RAISE NOTICE 'Exists %', index_exists;

IF index_id IS NOT NULL THEN
	--RAISE NOTICE 'Found';
	seq_name := concat(quote_ident(cdb_schema),'.index_table_id_seq');
	
	-- Drop the index and remove it from the index_table
	RAISE NOTICE 'Dropping index (only this time) ''ga_datatype_inx'' from table %.cityobject_genericattrib', cdb_schema;
	EXECUTE format('
	DROP INDEX IF EXISTS %I.ga_datatype_inx;

	DELETE FROM %I.index_table 
	WHERE (obj).index_name = ''ga_datatype_inx'' 
		AND (obj).table_name = ''cityobject_genericattrib'' 
		AND (obj).attribute_name = ''datatype'';
	
	WITH s AS (SELECT max(t.id) AS max_id FROM %I.index_table AS t)
	SELECT CASE WHEN s.max_id IS NULL     THEN setval(%L::regclass, 1, false)
				WHEN s.max_id IS NOT NULL THEN setval(%L::regclass, s.max_id, true) END
	FROM s;
	',
	cdb_schema,
	cdb_schema,
	cdb_schema,
	seq_name,
	seq_name);

ELSE
	RAISE NOTICE 'Not found';
	-- Do nothing, the index does not exist
END IF;

-- Other index... (if needed)
-- 
-- 

EXCEPTION
	WHEN QUERY_CANCELED THEN
		RAISE EXCEPTION 'qgis_pkg.drop_ga_indices(): Error QUERY_CANCELED';
  WHEN OTHERS THEN 
		RAISE EXCEPTION 'qgis_pkg.drop_ga_indices(): %', SQLERRM;
END;
$$ LANGUAGE plpgsql;
COMMENT ON FUNCTION qgis_pkg.drop_ga_indices(varchar) IS 'Adds some indices to table cityobject_genericattrib';
--REVOKE EXECUTE ON FUNCTION qgis_pkg.drop_ga_indices(varchar) FROM public;

SELECT qgis_pkg.drop_ga_indices(cdb_schema := 'citydb');


----------------------------------------------------------------
-- Create FUNCTION QGIS_PKG.CREATE_DEFAULT_QGIS_PKG_USER
----------------------------------------------------------------
-- Create a default QGIS-Package user with read-only or read & write privileges
DROP FUNCTION IF EXISTS    qgis_pkg.create_default_qgis_pkg_user(varchar) CASCADE;
CREATE OR REPLACE FUNCTION qgis_pkg.create_default_qgis_pkg_user(
priv_type		varchar   	-- must be either 'ro' or 'rw')
)
RETURNS varchar
AS $$
DECLARE
priv_types_array	CONSTANT varchar[] :=  ARRAY['ro', 'rw'];
usr_name			varchar;
usr_name_label		varchar;
sql_statement		varchar;

BEGIN
-- Check that the privileges type is correct.
-- Set the usr_name
IF priv_type IS NULL OR (NOT priv_type = ANY(priv_types_array)) THEN
	RAISE EXCEPTION 'Privileges type not valid: It must be one of %', priv_types_array;
ELSE
	IF priv_type = 'ro' THEN
		usr_name := 'qgis_user_ro';
		usr_name_label := 'read-only';
	ELSE 
		usr_name := 'qgis_user_rw';
		usr_name_label := 'read & write';
	END IF;
END IF;

IF NOT EXISTS(SELECT 1 FROM information_schema.enabled_roles AS i WHERE i.role_name::varchar = usr_name) THEN
	sql_statement := concat('
-- Add/create a default QGIS-Package ',usr_name_label,' user
CREATE ROLE ',quote_ident(usr_name),' WITH
	LOGIN
	NOSUPERUSER
	NOCREATEDB
	NOCREATEROLE
	INHERIT
	NOREPLICATION
	CONNECTION LIMIT -1
	PASSWORD ',quote_literal(usr_name),';
COMMENT ON ROLE ',quote_ident(usr_name),' IS ''QGIS-Package default user with ',usr_name_label,' privileges for the 3DCityDB'';
');
	EXECUTE sql_statement;
	RAISE NOTICE 'User % created', usr_name;
	RETURN usr_name;
ELSE
	RAISE NOTICE 'User % already exists', usr_name;
	RETURN NULL;
END IF;

EXCEPTION
	WHEN QUERY_CANCELED THEN
		RAISE EXCEPTION 'qgis_pkg.create_default_qgis_pkg_user(): Error QUERY_CANCELED';
  WHEN OTHERS THEN 
		RAISE EXCEPTION 'qgis_pkg.create_default_qgis_pkg_user(): %', SQLERRM;
END;
$$ LANGUAGE plpgsql;
COMMENT ON FUNCTION qgis_pkg.create_default_qgis_pkg_user(varchar) IS 'Create a default QGIS-Package user with read-only or read & write privileges';
REVOKE EXECUTE ON FUNCTION qgis_pkg.create_default_qgis_pkg_user(varchar) FROM public;

-- Example
--SELECT qgis_pkg.create_default_qgis_pkg_user('ro');
--SELECT qgis_pkg.create_default_qgis_pkg_user('rw');


----------------------------------------------------------------
-- Create FUNCTION QGIS_PKG.CREATE_QGIS_USR_SCHEMA
----------------------------------------------------------------
-- Creates the qgis schema for a user
DROP FUNCTION IF EXISTS    qgis_pkg.create_qgis_usr_schema(varchar) CASCADE;
CREATE OR REPLACE FUNCTION qgis_pkg.create_qgis_usr_schema(
usr_name	varchar
)
RETURNS varchar
AS $$
DECLARE
tb_names_array	varchar[] := ARRAY['codelist', 'codelist_value', 'enumeration', 'enumeration_value', 'codelist_lookup_config', 'extents', 'settings'];
tb_name 	varchar;
usr_schema	varchar;
seq_name	varchar;

BEGIN
IF usr_name IS NULL OR NOT EXISTS(SELECT 1 FROM information_schema.enabled_roles AS i WHERE i.role_name::varchar = usr_name) THEN
	RAISE EXCEPTION 'usr_name is invalid. It must be an existing database user';
END IF;

usr_schema := qgis_pkg.create_qgis_usr_schema_name(usr_name);

RAISE NOTICE 'Creating usr_schema "%" for user "%"', usr_schema, usr_name;

-- Just to clean up from potentially different previous installations.
IF (usr_name = 'postgres') OR (qgis_pkg.is_superuser(usr_name) IS TRUE) THEN
	-- Do nothing
	NULL;
ELSE
	-- Revoke privileges from qgis_pkg schema if any. Only for normal users
	EXECUTE format('REVOKE EXECUTE ON ALL FUNCTIONS IN SCHEMA qgis_pkg FROM %I;',usr_name);
	EXECUTE format('REVOKE SELECT ON TABLE qgis_pkg.feature_type_to_toplevel_feature FROM %I;', usr_name);
	EXECUTE format('REVOKE SELECT ON TABLE qgis_pkg.enum_lookup_config FROM %I;', usr_name);
	EXECUTE format('REVOKE USAGE ON SCHEMA qgis_pkg FROM %I;', usr_name);
END IF;

-- This will work till there are not too many layers (over 500).
-- Otherwise first: delete all layers for all cdb_schemas, THEN drop schema
EXECUTE format('DROP SCHEMA IF EXISTS %I CASCADE', usr_schema);
-- Delete the entry from the user_schema table.
EXECUTE format('DELETE FROM qgis_pkg.usr_schema WHERE usr_schema = %L', usr_schema);

-- Now start with a clean installation.
EXECUTE format('CREATE SCHEMA IF NOT EXISTS %I', usr_schema);

-- Create new schema and tables
EXECUTE format('
DROP TABLE IF EXISTS %I.layer_metadata CASCADE;
CREATE TABLE %I.layer_metadata (LIKE qgis_pkg.layer_metadata_template INCLUDING ALL);
ALTER TABLE %I.layer_metadata OWNER TO %I;

DROP TABLE IF EXISTS %I.extents CASCADE;
CREATE TABLE %I.extents (LIKE qgis_pkg.extents_template INCLUDING ALL);
ALTER TABLE %I.extents OWNER TO %I;

DROP TABLE IF EXISTS %I.enumeration CASCADE;
CREATE TABLE %I.enumeration (LIKE qgis_pkg.enumeration_template INCLUDING ALL);
ALTER TABLE %I.enumeration OWNER TO %I;

DROP TABLE IF EXISTS %I.enumeration_value CASCADE;
CREATE TABLE %I.enumeration_value (LIKE qgis_pkg.enumeration_value_template INCLUDING ALL);
ALTER TABLE %I.enumeration_value OWNER TO %I;

DROP TABLE IF EXISTS %I.codelist CASCADE;
CREATE TABLE %I.codelist (LIKE qgis_pkg.codelist_template INCLUDING ALL);
ALTER TABLE %I.codelist OWNER TO %I;

DROP TABLE IF EXISTS %I.codelist_value CASCADE;
CREATE TABLE %I.codelist_value (LIKE qgis_pkg.codelist_value_template INCLUDING ALL);
ALTER TABLE %I.codelist_value OWNER TO %I;

DROP TABLE IF EXISTS %I.codelist_lookup_config CASCADE;
CREATE TABLE %I.codelist_lookup_config (LIKE qgis_pkg.codelist_lookup_config_template INCLUDING ALL);
ALTER TABLE %I.codelist_lookup_config OWNER TO %I;

DROP TABLE IF EXISTS %I.settings CASCADE;
CREATE TABLE %I.settings (LIKE qgis_pkg.settings INCLUDING ALL);
ALTER TABLE %I.settings OWNER TO %I;
',
usr_schema, usr_schema, usr_schema, usr_name,
usr_schema, usr_schema, usr_schema, usr_name,
usr_schema, usr_schema, usr_schema, usr_name,
usr_schema, usr_schema, usr_schema, usr_name,
usr_schema, usr_schema, usr_schema, usr_name,
usr_schema, usr_schema, usr_schema, usr_name,
usr_schema, usr_schema, usr_schema, usr_name,
usr_schema, usr_schema, usr_schema, usr_name
);

-- Populate new tables
EXECUTE format('
INSERT INTO %I.extents SELECT * FROM qgis_pkg.extents_template ORDER BY id;
INSERT INTO %I.enumeration SELECT * FROM qgis_pkg.enumeration_template ORDER BY id;
INSERT INTO %I.enumeration_value SELECT * FROM qgis_pkg.enumeration_value_template ORDER BY id;
INSERT INTO %I.codelist SELECT * FROM qgis_pkg.codelist_template ORDER BY id;
INSERT INTO %I.codelist_value SELECT * FROM qgis_pkg.codelist_value_template ORDER BY id;
INSERT INTO %I.codelist_lookup_config SELECT * FROM qgis_pkg.codelist_lookup_config_template ORDER BY id;
',
usr_schema, usr_schema, usr_schema, usr_schema, usr_schema, usr_schema
);

-- Add foreign keys for enumeration and codelist tables
EXECUTE format('
ALTER TABLE %I.codelist_value ADD CONSTRAINT cl_to_cl_value_fk FOREIGN KEY (code_id) REFERENCES %I.codelist (id) ON UPDATE CASCADE ON DELETE CASCADE;
ALTER TABLE %I.enumeration_value ADD CONSTRAINT en_to_en_value_fk FOREIGN KEY (enum_id) REFERENCES %I.enumeration  (id) ON UPDATE CASCADE ON DELETE CASCADE;
',
usr_schema, usr_schema,
usr_schema, usr_schema
);

-- Refresh/Update the associated sequence values
FOREACH tb_name IN ARRAY tb_names_array LOOP
	seq_name := concat(quote_ident(usr_schema),'.',tb_name,'_id_seq');
	EXECUTE format('
		WITH s AS (SELECT max(t.id) AS max_id FROM %I.%I AS t)
		SELECT CASE WHEN s.max_id IS NULL     THEN setval(%L::regclass, 1, false)
		            WHEN s.max_id IS NOT NULL THEN setval(%L::regclass, s.max_id, true) END
		FROM s',
	usr_schema, tb_name,
	seq_name,
	seq_name);
END LOOP;

--Create views for codelists and enumerations
EXECUTE format('
--DROP VIEW IF EXISTS %I.v_enumeration_value CASCADE;
CREATE VIEW         %I.v_enumeration_value AS
SELECT
	ev.id,
	e.data_model,
	e.name,
	ev.value,
	ev.description,
	e.name_space
FROM
	%I.enumeration_value AS ev
	INNER JOIN %I.enumeration AS e ON (ev.enum_id = e.id);
ALTER TABLE %I.v_enumeration_value OWNER TO %I;

--DROP VIEW IF EXISTS %I.v_codelist_value CASCADE;
CREATE VIEW         %I.v_codelist_value AS
SELECT
	cv.id,
	c.data_model,
	c.name,
	cv.value,
	cv.description,
	c.name_space
FROM
	%I.codelist_value AS cv
	INNER JOIN %I.codelist AS c ON (cv.code_id = c.id);
ALTER TABLE %I.v_codelist_value OWNER TO %I;
',
usr_schema,usr_schema,usr_schema,usr_schema,usr_schema,usr_name,
usr_schema,usr_schema,usr_schema,usr_schema,usr_schema,usr_name
);

-- Delete if exists the previously installed entry in table qgis_pkg.usr_schema;
EXECUTE format('DELETE FROM qgis_pkg.usr_schema AS u WHERE u.usr_name = %L',usr_name);

-- Insert the newly installed usr_schema in table qgis_pkg.usr_schema;
INSERT INTO qgis_pkg.usr_schema (usr_name, usr_schema, creation_date) VALUES
(usr_name, usr_schema, clock_timestamp());

-- Grant privileges to use your own usr_schema
EXECUTE format('GRANT USAGE, CREATE ON SCHEMA %I TO %I;', usr_schema, usr_name);

-- Grant privileges to access the qgis_pkg schema use functions in qgis_pkg
EXECUTE format('GRANT USAGE ON SCHEMA qgis_pkg TO %I;', usr_name);
-- Grant privileges to use functions in qgis_pkg
EXECUTE format('GRANT EXECUTE ON ALL FUNCTIONS IN SCHEMA qgis_pkg TO %I;', usr_name);
-- Grant privileges to read from the following tables in qgis_pkg
EXECUTE format('GRANT SELECT ON TABLE qgis_pkg.feature_type_to_toplevel_feature TO %I;', usr_name);
EXECUTE format('GRANT SELECT ON TABLE qgis_pkg.enum_lookup_config TO %I;', usr_name);

IF (usr_name = 'postgres') OR (qgis_pkg.is_superuser(usr_name) IS TRUE) THEN
	NULL;
	-- Do nothing, this is to avoid revoking privileges from yourself.
	-- It's anyway either postgres or a superuser being able to run this script.
ELSE
	-- DO NOT REVOKE privileges from (they are called also by user-level functions):
	-- qgis_pkg.is_superuser(varchar)
	-- qgis_pkg.list_qgis_pkg_usrgroup_members()

	-- Revoke privileges to use functions in qgis_pkg. These are needed only by superusers
	EXECUTE format('REVOKE EXECUTE ON FUNCTION qgis_pkg.create_qgis_pkg_usrgroup() FROM %I;', usr_name);
	EXECUTE format('REVOKE EXECUTE ON FUNCTION qgis_pkg.add_user_to_qgis_pkg_usrgroup(varchar) FROM %I;', usr_name);
	EXECUTE format('REVOKE EXECUTE ON FUNCTION qgis_pkg.remove_user_from_qgis_pkg_usrgroup(varchar) FROM %I;', usr_name);
	EXECUTE format('REVOKE EXECUTE ON FUNCTION qgis_pkg.list_qgis_pkg_non_usrgroup_members() FROM %I;', usr_name);
	--EXECUTE format('REVOKE EXECUTE ON FUNCTION qgis_pkg.list_cdb_schemas_privs(varchar) FROM %I;', usr_name);
	EXECUTE format('REVOKE EXECUTE ON FUNCTION qgis_pkg.create_default_qgis_pkg_user(varchar) FROM %I;', usr_name);
	EXECUTE format('REVOKE EXECUTE ON FUNCTION qgis_pkg.create_qgis_usr_schema(varchar) FROM %I;', usr_name);
	EXECUTE format('REVOKE EXECUTE ON FUNCTION qgis_pkg.grant_qgis_usr_privileges(varchar, varchar, varchar) FROM %I;', usr_name);
	EXECUTE format('REVOKE EXECUTE ON FUNCTION qgis_pkg.grant_qgis_usr_privileges(varchar, varchar, varchar[]) FROM %I;', usr_name);
	EXECUTE format('REVOKE EXECUTE ON FUNCTION qgis_pkg.revoke_qgis_usr_privileges(varchar, varchar) FROM %I;', usr_name);
	EXECUTE format('REVOKE EXECUTE ON FUNCTION qgis_pkg.revoke_qgis_usr_privileges(varchar, varchar[]) FROM %I;', usr_name);
END IF;

RETURN usr_schema;

EXCEPTION
	WHEN QUERY_CANCELED THEN
		RAISE EXCEPTION 'qgis_pkg.create_qgis_usr_schema(): Error QUERY_CANCELED';
	WHEN OTHERS THEN 
		RAISE EXCEPTION 'qgis_pkg.create_qgis_usr_schema(): %', SQLERRM;
END;
$$ LANGUAGE plpgsql;
COMMENT ON FUNCTION qgis_pkg.create_qgis_usr_schema(varchar) IS 'Creates the qgis schema for a user';
REVOKE EXECUTE ON FUNCTION qgis_pkg.create_qgis_usr_schema(varchar) FROM public;

-- Example: 
--SELECT qgis_pkg.create_qgis_usr_schema('qgis_user_rw');


----------------------------------------------------------------
-- Create FUNCTION QGIS_PKG.LIST_USR_SCHEMAS
----------------------------------------------------------------
-- List all usr schemas of qgis pkg users in the current database
DROP FUNCTION IF EXISTS    qgis_pkg.list_usr_schemas() CASCADE;
CREATE OR REPLACE FUNCTION qgis_pkg.list_usr_schemas()
RETURNS TABLE (
usr_schema	varchar
)
AS $$
DECLARE
cdb_name CONSTANT varchar := current_database()::varchar;
r RECORD;

BEGIN

FOR r IN 
	SELECT i.schema_name 
	FROM information_schema.schemata AS i
	WHERE 
		i.catalog_name::varchar = cdb_name
		AND i.schema_name::varchar LIKE 'qgis_%'
	ORDER BY i.schema_name ASC
LOOP
	IF
		EXISTS(SELECT 1 FROM information_schema.tables AS t WHERE t.table_schema = r.schema_name AND t.table_name::varchar = 'extents')
			AND
		EXISTS(SELECT 1 FROM information_schema.tables AS t WHERE t.table_schema = r.schema_name AND t.table_name::varchar = 'layer_metadata')		
			AND
		EXISTS(SELECT 1 FROM information_schema.tables AS t WHERE t.table_schema = r.schema_name AND t.table_name::varchar = 'enumeration')	
			AND
		EXISTS(SELECT 1 FROM information_schema.tables AS t WHERE t.table_schema = r.schema_name AND t.table_name::varchar = 'codelist')
	THEN
		usr_schema := r.schema_name::varchar;
		RETURN NEXT;
	END IF;
END LOOP;

EXCEPTION
	WHEN QUERY_CANCELED THEN
		RAISE EXCEPTION 'qgis_pkg.list_usr_schemas(): Error QUERY_CANCELED';
  WHEN OTHERS THEN 
		RAISE EXCEPTION 'qgis_pkg.list_usr_schemas(): %', SQLERRM;
END;
$$ LANGUAGE plpgsql;
COMMENT ON FUNCTION qgis_pkg.list_usr_schemas() IS 'List all existing usr_schemas generated by the QGIS package in the current database';
REVOKE EXECUTE ON FUNCTION qgis_pkg.list_usr_schemas() FROM public;

-- Example:
--SELECT usr_schema FROM qgis_pkg.list_usr_schemas();
--SELECT array_agg(usr_schema) FROM qgis_pkg.list_usr_schemas();


----------------------------------------------------------------
-- Create FUNCTION QGIS_PKG.GRANT_QGIS_USR_PRIVILEGES
----------------------------------------------------------------
-- Grants read-only or read-write privileges to a user for a certain cdb_schema
DROP FUNCTION IF EXISTS    qgis_pkg.grant_qgis_usr_privileges(varchar, varchar, varchar) CASCADE;
CREATE OR REPLACE FUNCTION qgis_pkg.grant_qgis_usr_privileges(
usr_name		varchar,
priv_type		varchar,   				-- must be either 'ro' or 'rw'
cdb_schema		varchar DEFAULT NULL	-- NULL = all existing cdb_schemas, otherwise to the given schema (e.g. 'citydb').
)
RETURNS void
AS $$
DECLARE
cdb_name 			CONSTANT varchar := current_database()::varchar;
priv_types_array 	CONSTANT varchar[] :=  ARRAY['ro', 'rw'];
cdb_schemas_array 	CONSTANT varchar[] := (SELECT array_agg(s.cdb_schema) FROM qgis_pkg.list_cdb_schemas(FALSE) AS s);
qgis_pkg_grp_name	CONSTANT varchar := (SELECT qgis_pkg.create_qgis_pkg_usrgroup_name());
qgis_pkg_name		CONSTANT varchar := 'qgis_pkg';
sch_name 			varchar;
sql_priv_type 		varchar;

BEGIN
-- Check that the user exists
IF usr_name IS NULL OR NOT EXISTS(SELECT 1 FROM information_schema.enabled_roles AS i WHERE i.role_name::varchar = usr_name) THEN
	RAISE EXCEPTION 'usr_name is invalid: It must be an existing database user';
END IF;

-- Check that the privileges type is correct.
IF (priv_type IS NULL) OR (NOT priv_type = ANY(priv_types_array)) THEN
	RAISE EXCEPTION 'Privileges type not valid: It must be one of %', priv_types_array;
ELSE
	IF priv_type = 'rw' THEN
		sql_priv_type := 'ALL';
	ELSE
		sql_priv_type := 'SELECT';
	END IF;
END IF;

-- Check that the cdb_schema exists.
IF (cdb_schema IS NOT NULL) AND (NOT cdb_schema = ANY(cdb_schemas_array)) THEN
	RAISE EXCEPTION 'cdb_schema is invalid: It must be an existing cdb_schema';
END IF;

-- Assign the user to be part of the "qgis_pkg_usrgroup_*" assigned to the current database.
-- If already member, a simple NOTICE will be raised automatically, no error.
EXECUTE format('GRANT %I TO %I;', qgis_pkg_grp_name, usr_name);
RAISE NOTICE 'Added user "%" to group "%"', usr_name, qgis_pkg_grp_name;

IF (usr_name = 'postgres') OR (qgis_pkg.is_superuser(usr_name) IS TRUE) THEN
	--RAISE NOTICE 'Working with user "%" as superuser', usr_name;
	-- Revoke the privileges from a previous run, if any.
	-- In the case of superusers, no need to worry about being revoked access
	-- to the database: They will always have, such privileges are not revoked.

	EXECUTE format('SELECT qgis_pkg.revoke_qgis_usr_privileges(%L, %L);',  usr_name, cdb_schema);

	IF cdb_schema IS NULL THEN

		-- Grant usage to citydb_pkg
		EXECUTE format('GRANT USAGE ON SCHEMA citydb_pkg TO %I;', usr_name);
		-- No tables in schema citydb_pkg (also also no sequences)
		--EXECUTE format('GRANT ALL PRIVILEGES ON ALL TABLES IN SCHEMA citydb_pkg TO %I;', sql_priv_type, usr_name);


		-- Recursively iterate for each cdb_schema in database
		FOREACH sch_name IN ARRAY cdb_schemas_array LOOP
			EXECUTE format('GRANT USAGE, CREATE ON SCHEMA %I TO %I;', sch_name, usr_name);
			EXECUTE format('GRANT %s ON ALL TABLES IN SCHEMA %I TO %I;', sql_priv_type, sch_name, usr_name);
			EXECUTE format('GRANT ALL PRIVILEGES ON ALL SEQUENCES IN SCHEMA %I TO %I', sch_name, usr_name);

			IF priv_type = 'rw' THEN
				-- Added to ensure that also a rw user can clean up schema (via qgis_pkg.cleanup_schema(...))
				EXECUTE format('GRANT TRUNCATE ON ALL TABLES IN SCHEMA %I TO %I', sch_name, usr_name);
				RAISE NOTICE 'Granted TRUNCATE privileges to user "%" for tables in schema "%"', usr_name, sch_name; 
			END IF;

			RAISE NOTICE 'Granted "%" privileges to user "%" for schema "%"', priv_type, usr_name, sch_name; 		

			-- And finally add an index on column datatype of table cityobject_genericattrib.
			-- We need access to schema citydb_pkg, that has been granted before the loop
			-- The index is created only the very first time, then it won't be created again,
			-- no matter if another uses it granted privileges.
			EXECUTE format('SELECT qgis_pkg.add_ga_indices(%L);', sch_name);

		END LOOP;

		-- Access/usage to qgis_pkg was granted at the moment of installing the usr_schema

		-- Grant usage to public
		EXECUTE format('GRANT USAGE ON SCHEMA public TO %I;', usr_name);
		EXECUTE format('GRANT %s ON ALL TABLES IN SCHEMA public TO %I;', sql_priv_type, usr_name);


	ELSIF cdb_schema = ANY(cdb_schemas_array) THEN 
		-- Grant usage to citydb_pkg
		EXECUTE format('GRANT USAGE ON SCHEMA citydb_pkg TO %I;', usr_name);
		-- No tables in schema citydb_pkg (also also no sequences)
		--EXECUTE format('GRANT ALL PRIVILEGES ON ALL TABLES IN SCHEMA citydb_pkg TO %I;', sql_priv_type, usr_name);

		-- Grant privileges only for the selected cdb_schema.
		EXECUTE format('GRANT USAGE, CREATE ON SCHEMA %I TO %I;', cdb_schema, usr_name);
		EXECUTE format('GRANT %s ON ALL TABLES IN SCHEMA %I TO %I;', sql_priv_type, cdb_schema, usr_name);
		EXECUTE format('GRANT ALL PRIVILEGES ON ALL SEQUENCES IN SCHEMA %I TO %I', cdb_schema, usr_name);

		IF priv_type = 'rw' THEN
			-- Added to ensure that also a rw user can clean up schema (via qgis_pkg.cleanup_schema(...))
			EXECUTE format('GRANT TRUNCATE ON ALL TABLES IN SCHEMA %I TO %I', cdb_schema, usr_name);
			RAISE NOTICE 'Granted TRUNCATE privileges to user "%" for tables in schema "%"', usr_name, cdb_schema; 
		END IF;
		
		-- And finally add an index on column datatype of table cityobject_genericattrib.
		-- We need access to schema citydb_pkg, that has been granted before the loop
		-- The index is created only the very first time, then it won't be created again,
		-- no matter if another uses it granted privileges.
		EXECUTE format('SELECT qgis_pkg.add_ga_indices(%L);', sch_name);

		-- Access/usage to qgis_pkg was granted at the moment of installing the usr_schema
		
		-- Grant usage to public
		EXECUTE format('GRANT USAGE ON SCHEMA public TO %I;', usr_name);
		EXECUTE format('GRANT %s ON ALL TABLES IN SCHEMA public TO %I;', sql_priv_type, usr_name);

		RAISE NOTICE 'Granted "%" privileges to user "%" for schema "%" in database "%"', priv_type, usr_name, cdb_schema, cdb_name; 

	END IF;

ELSE -- any other non super-user
	--RAISE NOTICE 'Working with user "%" as normal user', usr_name;
	-- Revoke the privileges from a previous run, if any.
	EXECUTE format('SELECT qgis_pkg.revoke_qgis_usr_privileges(%L, %L);',  usr_name, cdb_schema);

	-- Grant access to the database (no need to iterate)
	EXECUTE format('GRANT CONNECT, TEMP ON DATABASE %I TO %I;', cdb_name, usr_name);
	RAISE NOTICE 'Granted access to database "%" to user "%"', cdb_name, usr_name;

	IF cdb_schema IS NULL THEN

		-- Grant access to the citydb_pkg schema
		EXECUTE format('GRANT USAGE ON SCHEMA citydb_pkg TO %I;', usr_name);
		-- No tables in schema citydb_pkg
		--EXECUTE format('GRANT %s ON ALL TABLES IN SCHEMA citydb_pkg TO %I;', sql_priv_type, usr_name);

		-- Recursively iterate for each cdb_schema in database
		FOREACH sch_name IN ARRAY cdb_schemas_array LOOP
			-- USAGE to connect, CREATE to create mviews and views
			EXECUTE format('GRANT USAGE, CREATE ON SCHEMA %I TO %I;', sch_name, usr_name);
			-- SELECT or ALL
			EXECUTE format('GRANT %s ON ALL TABLES IN SCHEMA %I TO %I;', sql_priv_type, sch_name, usr_name);

			IF priv_type = 'rw' THEN
				EXECUTE format('GRANT ALL PRIVILEGES ON ALL SEQUENCES IN SCHEMA %I TO %I', sch_name, usr_name);
				-- Added to ensure that also a rw user can clean up schema (via qgis_pkg.cleanup_schema(...))
				EXECUTE format('GRANT TRUNCATE ON ALL TABLES IN SCHEMA %I TO %I', sch_name, usr_name);
				RAISE NOTICE 'Granted TRUNCATE privileges to user "%" for tables in schema "%"', usr_name, sch_name; 
			END IF;

			RAISE NOTICE 'Granted "%" privileges to user "%" for schema "%"', priv_type, usr_name, sch_name; 		

			-- And finally add an index on column datatype of table cityobject_genericattrib.
			-- We need access to schema citydb_pkg, that has been granted before the loop
			-- The index is created only the very first time, then it won't be created again,
			-- no matter if another uses it granted privileges.
			EXECUTE format('SELECT qgis_pkg.add_ga_indices(%L);', sch_name);

		END LOOP;

		-- No need to iterate here

		-- Access/usage to qgis_pkg was granted at the moment of installing the usr_schema

		-- Grant access to the public schema
		EXECUTE format('GRANT USAGE ON SCHEMA public TO %I;', usr_name);
		EXECUTE format('GRANT %s ON ALL TABLES IN SCHEMA public TO %I;', sql_priv_type, usr_name);

	ELSIF cdb_schema = ANY(cdb_schemas_array) THEN
			-- Grant access to the citydb_pkg schema
		EXECUTE format('GRANT USAGE ON SCHEMA citydb_pkg TO %I;', usr_name);

		-- Grant privileges only for the selected cdb_schema.
		EXECUTE format('GRANT USAGE ON SCHEMA %I TO %I;', cdb_schema, usr_name);
		EXECUTE format('GRANT %s ON ALL TABLES IN SCHEMA %I TO %I;', sql_priv_type, cdb_schema, usr_name);
		
		IF priv_type = 'rw' THEN
			EXECUTE format('GRANT ALL PRIVILEGES ON ALL SEQUENCES IN SCHEMA %I TO %I', cdb_schema, usr_name);
			-- Added to ensure that also a rw user can clean up schema (via qgis_pkg.cleanup_schema(...))
			EXECUTE format('GRANT TRUNCATE ON ALL TABLES IN SCHEMA %I TO %I', cdb_schema, usr_name);
		END IF;

		-- (No need to iterate here)
		-- And finally add an index on column datatype of table cityobject_genericattrib.
		-- We need access to schema citydb_pkg, that has been granted before the loop
		-- The index is created only the very first time, then it won't be created again,
		-- no matter if another uses it granted privileges.
		EXECUTE format('SELECT qgis_pkg.add_ga_indices(%L);', sch_name);
		-- No tables in citydb_pkg
		--EXECUTE format('GRANT %s ON ALL TABLES IN SCHEMA citydb_pkg TO %I;', sql_priv_type, usr_name);

		-- Access/usage to qgis_pkg was granted at the moment of installing the usr_schema

		-- Grant access to the public schema
		EXECUTE format('GRANT USAGE ON SCHEMA public TO %I;', usr_name);
		EXECUTE format('GRANT %s ON ALL TABLES IN SCHEMA public TO %I;', sql_priv_type, usr_name);

		RAISE NOTICE 'Granted "%" privileges to user "%" for schema "%" in database "%"', priv_type, usr_name, cdb_schema, cdb_name; 

	END IF;

END IF;

EXCEPTION
	WHEN QUERY_CANCELED THEN
		RAISE EXCEPTION 'qgis_pkg.grant_qgis_usr_privileges(): Error QUERY_CANCELED';
	WHEN OTHERS THEN 
		RAISE EXCEPTION 'qgis_pkg.grant_qgis_usr_privileges(): %', SQLERRM;
END;
$$ LANGUAGE plpgsql;
COMMENT ON FUNCTION qgis_pkg.grant_qgis_usr_privileges(varchar, varchar, varchar) IS 'Grants access to the current database and read-only / read-write privileges to a user for a citydb schema';
REVOKE EXECUTE ON FUNCTION qgis_pkg.grant_qgis_usr_privileges(varchar, varchar, varchar) FROM public;


----------------------------------------------------------------
-- Create FUNCTION QGIS_PKG.REVOKE_QGIS_USR_PRIVILEGES
----------------------------------------------------------------
-- Revokes all privileges for all cdb_schemas for the user from the current database
DROP FUNCTION IF EXISTS    qgis_pkg.revoke_qgis_usr_privileges(varchar, varchar) CASCADE;
CREATE OR REPLACE FUNCTION qgis_pkg.revoke_qgis_usr_privileges(
usr_name		varchar,
cdb_schema		varchar DEFAULT NULL	-- NULL = all cdb_schemas, otherwise to the given schema (e.g. 'citydb').
)
RETURNS void
AS $$
DECLARE
cdb_name 			CONSTANT varchar := current_database()::varchar;
cdb_schemas_array	CONSTANT varchar[] := (SELECT array_agg(s.cdb_schema) FROM qgis_pkg.list_cdb_schemas(FALSE) AS s);
qgis_pkg_grp_name	CONSTANT varchar := (SELECT qgis_pkg.create_qgis_pkg_usrgroup_name());
qgis_pkg_name 		CONSTANT varchar := 'qgis_pkg';
sch_name varchar;
r RECORD;

BEGIN
-- Check that the user exists
IF (usr_name IS NULL) OR (NOT EXISTS(SELECT 1 FROM information_schema.enabled_roles AS i WHERE i.role_name = usr_name)) THEN
	RAISE EXCEPTION 'User name is invalid. It must correspond to an existing database user';
END IF;
-- Avoid superusers locking themselves out their own house...
IF (usr_name = 'postgres') OR (qgis_pkg.is_superuser(usr_name) IS TRUE) THEN
	-- RAISE NOTICE 'Dealing with a supersuer';
	
	IF cdb_schema IS NULL THEN
		-- Iterate for each cdb_schema in database
		FOREACH sch_name IN ARRAY cdb_schemas_array LOOP
		
			-- Revoke privileges only for the selected cdb_schema.
			EXECUTE format('REVOKE ALL PRIVILEGES ON ALL SEQUENCES IN SCHEMA %I FROM %I;', sch_name, usr_name);
			EXECUTE format('REVOKE ALL PRIVILEGES ON ALL TABLES IN SCHEMA %I FROM %I;', sch_name, usr_name);
			EXECUTE format('REVOKE ALL PRIVILEGES ON SCHEMA %I FROM %I;', sch_name, usr_name);
			EXECUTE format('REVOKE TRUNCATE ON ALL TABLES IN SCHEMA %I FROM %I', sch_name, usr_name);

			--RAISE NOTICE 'Revoked all privileges on citydb schema "%" from user "%" in database "%"', sch_name, usr_name, cdb_name;

		END LOOP;
	
	ELSIF cdb_schema = ANY(cdb_schemas_array) THEN 

		-- Revoke privileges only for the selected cdb_schema.
		EXECUTE format('REVOKE ALL PRIVILEGES ON ALL SEQUENCES IN SCHEMA %I FROM %I;', cdb_schema, usr_name);
		EXECUTE format('REVOKE ALL PRIVILEGES ON ALL TABLES IN SCHEMA %I FROM %I;', cdb_schema, usr_name);
		EXECUTE format('REVOKE ALL PRIVILEGES ON SCHEMA %I FROM %I;', cdb_schema, usr_name);
		EXECUTE format('REVOKE TRUNCATE ON ALL TABLES IN SCHEMA %I FROM %I', cdb_schema, usr_name);
		--RAISE NOTICE 'Revoked all privileges on citydb schema "%" from user "%" in database "%"', cdb_schema, usr_name, cdb_name; 

	ELSE
		RAISE EXCEPTION 'cdb_schema is invalid, it must correspond to an existing citydb schema';
	END IF;

ELSE -- any other non super-user
	--RAISE NOTICE 'Dealing with a normal user';

	IF cdb_schema IS NULL THEN
		-- Iterate for each cdb_schema in database
		FOREACH sch_name IN ARRAY cdb_schemas_array LOOP
		
			-- Revoke privileges only for the selected cdb_schema.
			EXECUTE format('REVOKE ALL PRIVILEGES ON ALL SEQUENCES IN SCHEMA %I FROM %I;', sch_name, usr_name);
			EXECUTE format('REVOKE ALL PRIVILEGES ON ALL TABLES IN SCHEMA %I FROM %I;', sch_name, usr_name);
			EXECUTE format('REVOKE ALL PRIVILEGES ON SCHEMA %I FROM %I;', sch_name, usr_name);
			--RAISE NOTICE 'Revoked all privileges on citydb schema "%" from user "%" in database "%"', sch_name, usr_name, cdb_name;

		END LOOP;
		
		-- From here on: Only once

		-- Revoke privileges and usage for schema citydb_pkg
		EXECUTE format('REVOKE ALL PRIVILEGES ON ALL TABLES IN SCHEMA citydb_pkg FROM %I;', usr_name);
		EXECUTE format('REVOKE USAGE ON SCHEMA citydb_pkg FROM %I;', usr_name);
		--RAISE NOTICE 'Revoked access to qgis_pkg schema from user "%"', usr_name;

		-- Revoke privileges and usage for schema public
		EXECUTE format('REVOKE ALL PRIVILEGES ON ALL TABLES IN SCHEMA public FROM %I;', usr_name);
		EXECUTE format('REVOKE USAGE ON SCHEMA public FROM %I;', usr_name);
		--RAISE NOTICE 'Revoked access to public schema from user "%"', usr_name;

		-- Revoke access to the database
		EXECUTE format('REVOKE CONNECT, TEMP ON DATABASE %I FROM %I;', cdb_name, usr_name);
		--RAISE NOTICE 'Revoked access to database "%" from user "%"', cdb_name, usr_name;
		
	ELSIF cdb_schema = ANY(cdb_schemas_array) THEN 

		-- Revoke privileges only for the selected cdb_schema.
		EXECUTE format('REVOKE ALL PRIVILEGES ON ALL SEQUENCES IN SCHEMA %I FROM %I;', cdb_schema, usr_name);
		EXECUTE format('REVOKE ALL PRIVILEGES ON ALL TABLES IN SCHEMA %I FROM %I;', cdb_schema, usr_name);
		EXECUTE format('REVOKE ALL PRIVILEGES ON SCHEMA %I FROM %I;', cdb_schema, usr_name);
		--RAISE NOTICE 'Revoked all privileges on citydb schema "%" from user "%" in database "%"', cdb_schema, usr_name, cdb_name; 

		-- If this is the last cdb_schema I am allowed to work with, then perform also the rest 
		IF NOT EXISTS(SELECT foo.cdb_schema 
					FROM qgis_pkg.list_cdb_schemas_usability(usr_name, NULL) AS foo 
					WHERE foo.usable IS TRUE LIMIT 1) THEN
					
			-- Revoke privileges and usage for schema citydp_pkg
			EXECUTE format('REVOKE ALL PRIVILEGES ON ALL TABLES IN SCHEMA citydb_pkg FROM %I;', usr_name);
			EXECUTE format('REVOKE USAGE ON SCHEMA citydb_pkg FROM %I;', usr_name);
			--RAISE NOTICE 'Revoked access to qgis_pkg schema from user "%"', usr_name;

			-- Revoke privileges and usage for schema public
			EXECUTE format('REVOKE ALL PRIVILEGES ON ALL TABLES IN SCHEMA public FROM %I;', usr_name);
			EXECUTE format('REVOKE USAGE ON SCHEMA public FROM %I;', usr_name);
			--RAISE NOTICE 'Revoked access to public schema from user "%"', usr_name;

			--Revoke access to the database
			EXECUTE format('REVOKE CONNECT, TEMP ON DATABASE %I FROM %I;', cdb_name, usr_name);
			--RAISE NOTICE 'Revoked access to database "%" from user "%"', cdb_name, usr_name;
			
		END IF;
	ELSE
		RAISE EXCEPTION 'cdb_schema is invalid, it must correspond to an existing citydb schema';
	END IF;

END IF;

EXCEPTION
	WHEN QUERY_CANCELED THEN
		RAISE EXCEPTION 'qgis_pkg.revoke_qgis_usr_privileges(): Error QUERY_CANCELED';
  WHEN OTHERS THEN 
		RAISE EXCEPTION 'qgis_pkg.revoke_qgis_usr_privileges(): %', SQLERRM;
END;
$$ LANGUAGE plpgsql;
COMMENT ON FUNCTION qgis_pkg.revoke_qgis_usr_privileges(varchar, varchar) IS 'Revoke privileges from a user for a/all citydb schema(s) in the current database';
REVOKE EXECUTE ON FUNCTION qgis_pkg.revoke_qgis_usr_privileges(varchar, varchar) FROM public;


----------------------------------------------------------------
-- Create FUNCTION QGIS_PKG.GRANT_QGIS_USR_PRIVILEGES (ARRAY)
----------------------------------------------------------------
-- Grant privileges for an array of cdb_schemas for the user from the current database (ARRAY)
DROP FUNCTION IF EXISTS    qgis_pkg.grant_qgis_usr_privileges(varchar, varchar, varchar[]) CASCADE;
CREATE OR REPLACE FUNCTION qgis_pkg.grant_qgis_usr_privileges(
usr_name		varchar,
priv_type		varchar,
cdb_schemas		varchar[] DEFAULT NULL	-- NULL = ARRAY of cdb_schemas, or NULL.
)
RETURNS void
AS $$
DECLARE
cdb_schema			varchar;

BEGIN
IF cdb_schemas IS NULL THEN
	EXECUTE format('SELECT qgis_pkg.grant_qgis_usr_privileges(usr_name := %L, priv_type := %L, cdb_schema := NULL)', usr_name, priv_type);
ELSIF array_length(cdb_schemas, 1) IS NOT NULL THEN
	FOREACH cdb_schema IN ARRAY cdb_schemas LOOP
		EXECUTE format('SELECT qgis_pkg.grant_qgis_usr_privileges(usr_name := %L, priv_type := %L, cdb_schema := %L)', usr_name, priv_type, cdb_schema);
	END LOOP;
ELSE
	RAISE EXCEPTION 'Array length of "%" is NULL', cdb_schemas;
END IF;

EXCEPTION
	WHEN QUERY_CANCELED THEN
		RAISE EXCEPTION 'qgis_pkg.grant_qgis_usr_privileges(): Error QUERY_CANCELED';
  WHEN OTHERS THEN 
		RAISE EXCEPTION 'qgis_pkg.grant_qgis_usr_privileges(): %', SQLERRM;
END;
$$ LANGUAGE plpgsql;
COMMENT ON FUNCTION qgis_pkg.grant_qgis_usr_privileges(varchar, varchar, varchar[]) IS 'Grant privileges to a user for an ARRAY of citydb schema(s) in the current database';
REVOKE EXECUTE ON FUNCTION qgis_pkg.grant_qgis_usr_privileges(varchar, varchar, varchar[]) FROM public;


----------------------------------------------------------------
-- Create FUNCTION QGIS_PKG.REVOKE_QGIS_USR_PRIVILEGES (ARRAY)
----------------------------------------------------------------
-- Revoke privileges for an array of cdb_schemas for the user from the current database (ARRAY)
DROP FUNCTION IF EXISTS    qgis_pkg.revoke_qgis_usr_privileges(varchar, varchar[]) CASCADE;
CREATE OR REPLACE FUNCTION qgis_pkg.revoke_qgis_usr_privileges(
usr_name		varchar,
cdb_schemas		varchar[] DEFAULT NULL	-- NULL = ARRAY of cdb_schemas, or NULL.
)
RETURNS void
AS $$
DECLARE
cdb_schema			varchar;

BEGIN
IF cdb_schemas IS NULL THEN
	EXECUTE format('SELECT qgis_pkg.revoke_qgis_usr_privileges(usr_name := %L, cdb_schema := NULL)', usr_name);
ELSIF array_length(cdb_schemas, 1) IS NOT NULL THEN
	FOREACH cdb_schema IN ARRAY cdb_schemas LOOP
		EXECUTE format('SELECT qgis_pkg.revoke_qgis_usr_privileges(usr_name := %L, cdb_schema := %L)', usr_name, cdb_schema);
	END LOOP;
ELSE
	RAISE EXCEPTION 'Array length of "%" is NULL', cdb_schemas;
END IF;

EXCEPTION
	WHEN QUERY_CANCELED THEN
		RAISE EXCEPTION 'qgis_pkg.revoke_qgis_usr_privileges(): Error QUERY_CANCELED';
  WHEN OTHERS THEN 
		RAISE EXCEPTION 'qgis_pkg.revoke_qgis_usr_privileges(): %', SQLERRM;
END;
$$ LANGUAGE plpgsql;
COMMENT ON FUNCTION qgis_pkg.revoke_qgis_usr_privileges(varchar, varchar[]) IS 'Revoke privileges from a user for an ARRAY of citydb schema(s) in the current database';
REVOKE EXECUTE ON FUNCTION qgis_pkg.revoke_qgis_usr_privileges(varchar, varchar[]) FROM public;


----------------------------------------------------------------
-- Create FUNCTION QGIS_PKG.COMPUTE_CDB_SCHEMA_EXTENTS
----------------------------------------------------------------
DROP FUNCTION IF EXISTS    qgis_pkg.compute_cdb_schema_extents(varchar, boolean);
CREATE OR REPLACE FUNCTION qgis_pkg.compute_cdb_schema_extents(
cdb_schema 		varchar,
is_geographic	boolean DEFAULT FALSE  -- TRUE is EPSG uses long-lat, FALSE if is projected (Default)
-- The polygon will have its coordinated approximated to:
-- EITHER floor and ceiling if coordinate system is projected
-- OR the 6th decimal position is coordinates are geographic (e.g. x = long, y = lat)

-- TO DO: instead of passing it from the GUI, have the function determine autonomously if it's projected or not.
-- Requires string pattern with the metadata in the refernce system table in public.
)
RETURNS TABLE(
	is_geom_null boolean,
	x_min numeric,
	y_min numeric,
	x_max numeric,
	y_max numeric,
	srid integer
) 
AS $$
DECLARE
cdb_extents box2d := NULL;
geog_coords_prec integer := 6;

BEGIN
IF is_geographic IS NULL THEN
	RAISE EXCEPTION 'Parameter is_geographic is NULL but must be either TRUE or FALSE';
END IF;

is_geom_null := NULL;
x_min := NULL;
y_min := NULL;
x_max := NULL;
y_max := NULL;
srid := NULL;

EXECUTE format('SELECT ST_Extent(envelope) FROM %I.cityobject AS co', cdb_schema) INTO cdb_extents;

IF cdb_extents IS NULL THEN
	is_geom_null := TRUE;
ELSE
	is_geom_null := FALSE;

	IF is_geographic IS TRUE THEN
		x_min        := round(ST_Xmin(cdb_extents)::numeric, geog_coords_prec);
		x_max        := round(ST_Xmax(cdb_extents)::numeric, geog_coords_prec);
		y_min        := round(ST_Ymin(cdb_extents)::numeric, geog_coords_prec);
		y_max        := round(ST_Ymax(cdb_extents)::numeric, geog_coords_prec);
	ELSE
		x_min        :=   floor(ST_Xmin(cdb_extents))::numeric;
		x_max        := ceiling(ST_Xmax(cdb_extents))::numeric;
		y_min        :=   floor(ST_Ymin(cdb_extents))::numeric;
		y_max        := ceiling(ST_Ymax(cdb_extents))::numeric;
	END IF;

	-- Get the srid from the cdb_schema
	EXECUTE format('SELECT srid FROM %I.database_srs LIMIT 1', cdb_schema) INTO srid;
END IF;

RETURN NEXT;

EXCEPTION
	WHEN QUERY_CANCELED THEN
		RAISE EXCEPTION 'qgis_pkg.compute_cdb_schema_extents(): Error QUERY_CANCELED';
  WHEN OTHERS THEN 
		RAISE EXCEPTION 'qgis_pkg.compute_cdb_schema_extents(): %', SQLERRM;
END;
$$ LANGUAGE plpgsql;
COMMENT ON FUNCTION    qgis_pkg.compute_cdb_schema_extents(varchar, boolean) IS 'Computes extents of the selected cdb_schema';
REVOKE ALL ON FUNCTION qgis_pkg.compute_cdb_schema_extents(varchar, boolean) FROM PUBLIC;

-- Example:
-- will default to projected coordinate systems and round to next integer.
--SELECT qgis_pkg.compute_cdb_schema_extents('citydb');


----------------------------------------------------------------
-- Create FUNCTION QGIS_PKG.UPSERT_EXTENTS
----------------------------------------------------------------
DROP FUNCTION IF EXISTS    qgis_pkg.upsert_extents(varchar, varchar, varchar, geometry, boolean);
CREATE OR REPLACE FUNCTION qgis_pkg.upsert_extents(
	usr_schema varchar,
	cdb_schema varchar,
	cdb_bbox_type varchar,
	cdb_envelope geometry DEFAULT NULL,
	is_geographic boolean DEFAULT FALSE)
RETURNS integer
AS $$
DECLARE
	cdb_bbox_type_array CONSTANT varchar[] := ARRAY['db_schema', 'm_view', 'qgis'];
	ext_label	varchar;
	srid integer;
	creation_timestamp timestamptz(3);
	upserted_id	integer := NULL;
	bbox_obj RECORD;
	
BEGIN
-- Check that the cdb_box_type is a valid value
IF cdb_bbox_type IS NULL OR NOT (cdb_bbox_type = ANY (cdb_bbox_type_array)) THEN
	RAISE EXCEPTION 'cdb_bbox_type value is invalid. It must be one of (%)', cdb_bbox_type_array;
END IF;
IF is_geographic IS NULL THEN
	RAISE EXCEPTION 'Parameter is_geographic is NULL but must be either TRUE or FALSE';
END IF;

CASE
	WHEN cdb_bbox_type = 'db_schema' THEN

		ext_label := concat(cdb_schema, '-bbox_extents');
		bbox_obj  := (SELECT qgis_pkg.compute_cdb_schema_extents(cdb_schema, is_geographic));
	
		IF bbox_obj.is_geom_null IS FALSE THEN
			creation_timestamp := clock_timestamp();
			cdb_envelope := ST_MakeEnvelope(bbox_obj.x_min, bbox_obj.y_min, bbox_obj.x_max, bbox_obj.y_max, bbox_obj.srid);
		ELSE
			creation_timestamp := NULL;
			cdb_envelope := NULL;
		END IF;

	WHEN cdb_bbox_type IN ('mview', 'qgis') THEN

		IF cdb_bbox_type = 'mview' THEN
			ext_label := concat(cdb_schema,'-mview_bbox_extents');
		ELSE
			ext_label := concat(cdb_schema,'-qgis_bbox_extents');
		END IF;

		-- Get the srid from the current cdb_schema
		IF cdb_envelope IS NOT NULL THEN
			creation_timestamp := clock_timestamp();
			EXECUTE format('SELECT srid FROM %I.database_srs LIMIT 1', cdb_schema) INTO srid;
			cdb_envelope := ST_SetSrid(cdb_envelope, srid);
		ELSE
			creation_timestamp := NULL;
			cdb_envelope := NULL;
		END IF;
	ELSE
		-- do nothing
END CASE;

EXECUTE format('
	INSERT INTO %I.extents AS e 
		(cdb_schema, bbox_type, label, envelope, creation_date)
	VALUES (%L, %L, %L, %L, %L)
	ON CONFLICT ON CONSTRAINT extents_cdb_schema_bbox_type_key DO
		UPDATE SET
			envelope = %L, label = %L, creation_date = %L
		WHERE 
			e.cdb_schema = %L AND e.bbox_type = %L
	RETURNING id',
	usr_schema,
	cdb_schema, cdb_bbox_type, ext_label, cdb_envelope, creation_timestamp,
	cdb_envelope, ext_label, creation_timestamp,
	cdb_schema, cdb_bbox_type)
INTO STRICT upserted_id;

RETURN upserted_id;

EXCEPTION
	WHEN QUERY_CANCELED THEN
		RAISE EXCEPTION 'qgis_pkg.upsert_extents(): Error QUERY_CANCELED';
  WHEN OTHERS THEN 
		RAISE EXCEPTION 'qgis_pkg.upsert_extents(): %', SQLERRM;
END;
$$ LANGUAGE plpgsql;
COMMENT ON FUNCTION qgis_pkg.upsert_extents(varchar, varchar, varchar, geometry, boolean) IS 'Insert/Update the EXTENTS table in the user schema';
REVOKE ALL ON FUNCTION qgis_pkg.upsert_extents(varchar, varchar, varchar, geometry, boolean) FROM PUBLIC;


----------------------------------------------------------------
-- Create FUNCTION QGIS_PKG.GENERATE_MVIEW_BBOX_POLY
----------------------------------------------------------------
-- Created a 2D polygon (and adds the SRID) from an array containing the bbox of the extents
-- The polygon will have its coordinated approximated to:
-- EITHER floor and ceiling if coordinate system is projected
-- OR the 6th decimal position is coordinates are geographic (e.g. x = long, y = lat)
DROP FUNCTION IF EXISTS    qgis_pkg.generate_mview_bbox_poly(varchar, numeric[], boolean) CASCADE;
CREATE OR REPLACE FUNCTION qgis_pkg.generate_mview_bbox_poly(
cdb_schema			varchar,
bbox_corners_array	numeric[],             -- To be passed as 'ARRAY[1.1,2.2,3.3,4.4]' 
is_geographic		boolean DEFAULT FALSE  -- TRUE is EPSG uses long-lat, FALSE if is projected (Default)	
)
RETURNS geometry AS $$
DECLARE
srid_id integer;
x_min numeric;
y_min numeric;
x_max numeric;
y_max numeric;
geog_coords_prec integer := 6;
mview_bbox_poly geometry(Polygon);  -- A rectangular PostGIS Polygon with SRID

BEGIN

IF bbox_corners_array IS NULL THEN
	mview_bbox_poly := NULL;
ELSIF array_position(bbox_corners_array, NULL) IS NOT NULL THEN
	RAISE EXCEPTION 'Array with corner coordinates is invalid and contains at least a null value';
ELSIF is_geographic IS NULL THEN
	RAISE EXCEPTION 'Parameter is_geographic is NULL but must be either TRUE or FALSE';
ELSE

	EXECUTE format('SELECT srid FROM %I.database_srs LIMIT 1', cdb_schema) INTO srid_id;
	
	IF is_geographic IS TRUE THEN
		x_min := round(bbox_corners_array[1]::numeric, geog_coords_prec);
		y_min := round(bbox_corners_array[2]::numeric, geog_coords_prec);
		x_max := round(bbox_corners_array[3]::numeric, geog_coords_prec);
		y_max := round(bbox_corners_array[4]::numeric, geog_coords_prec);
	ELSE
		x_min :=   floor(bbox_corners_array[1]);
		y_min :=   floor(bbox_corners_array[2]);
		x_max := ceiling(bbox_corners_array[3]);
		y_max := ceiling(bbox_corners_array[4]);
	END IF;

	mview_bbox_poly := ST_MakeEnvelope(x_min, y_min, x_max, y_max, srid_id);
END IF;

RETURN mview_bbox_poly;

EXCEPTION
	WHEN QUERY_CANCELED THEN
		RAISE EXCEPTION 'qgis_pkg.generate_mview_bbox_poly(): Error QUERY_CANCELED';
	WHEN OTHERS THEN
		RAISE EXCEPTION 'qgis_pkg.generate_mview_bbox_poly(): %', SQLERRM;
END;
$$ LANGUAGE plpgsql;
COMMENT ON FUNCTION qgis_pkg.generate_mview_bbox_poly(varchar, numeric[], boolean) IS 'Create polygon of mview bbox';
REVOKE EXECUTE ON FUNCTION qgis_pkg.generate_mview_bbox_poly(varchar, numeric[], boolean) FROM public;

-- Example:
--SELECT qgis_pkg.generate_mview_bbox_poly('citydb', ARRAY[220177, 481471, 220755, 482133], TRUE);
--SELECT qgis_pkg.generate_mview_bbox_poly('citydb', '{220177, 481471, 220755, 482133}', FALSE);


----------------------------------------------------------------
-- Create FUNCTION QGIS_PKG.LIST_FEATURE_TYPES
----------------------------------------------------------------
-- Gets all Feature Types in all/selected user schema(s) from tables layer_metadata
DROP FUNCTION IF EXISTS    qgis_pkg.list_feature_types(varchar);
CREATE OR REPLACE FUNCTION qgis_pkg.list_feature_types(
	INOUT usr_schema		varchar DEFAULT NULL,
	OUT	  cdb_schema		varchar,
	OUT   feature_type		varchar
)
RETURNS SETOF record
AS $$
DECLARE
	usr_schemas_array 	varchar[] := (SELECT array_agg(s.usr_schema) FROM qgis_pkg.list_usr_schemas() AS s);
	usr_schemas			varchar[] := NULL;
	s				 	varchar;
	query_sql			varchar;
BEGIN
-- Check if the usr_schema exists (must have been created before)
IF (usr_schema IS NOT NULL) AND (NOT usr_schema = ANY(usr_schemas_array)) THEN
	RAISE EXCEPTION 'usr_schema "%" does not exist in current database', usr_schema;
END IF;

IF usr_schema IS NULL THEN
	usr_schemas := usr_schemas_array;
ELSE
	usr_schemas := ARRAY[usr_schema];
END IF;

FOREACH s IN ARRAY usr_schemas LOOP
	--RAISE NOTICE 'Searching for Feature Types in %.layer_metadata', s;
	query_sql := format('SELECT DISTINCT %L::varchar AS usr_schema, cdb_schema, feature_type 
						FROM %I.layer_metadata
						WHERE 
							layer_type IN (''VectorLayer'', ''VectorLayerNoGeom'')
							AND feature_type IS NOT NULL
						ORDER BY cdb_schema, feature_type ASC;', s, s);
	--RAISE NOTICE 'SQL: %', query_sql;
	RETURN QUERY EXECUTE query_sql;
END LOOP;

RETURN;

EXCEPTION
	WHEN QUERY_CANCELED THEN
		RAISE EXCEPTION 'qgis_pkg.list_feature_types(): Error QUERY_CANCELED';
  WHEN OTHERS THEN 
		RAISE EXCEPTION 'qgis_pkg.list_feature_types(): %', SQLERRM;
END;
$$ LANGUAGE plpgsql;
COMMENT ON FUNCTION qgis_pkg.list_feature_types(varchar) IS 'Gets all Feature Types in all/selected user schema(s)';
REVOKE ALL ON FUNCTION qgis_pkg.list_feature_types(varchar) FROM PUBLIC;

--SELECT * FROM qgis_pkg.list_feature_types('qgis_user_rw');
--SELECT * FROM qgis_pkg.list_feature_types();


----------------------------------------------------------------
-- Create FUNCTION QGIS_PKG.FEATURE_TYPE_CHECKER
----------------------------------------------------------------
-- Checks whether features types (CityGML modules) exist in the selected cdb_schema
DROP FUNCTION IF EXISTS    qgis_pkg.feature_type_checker(varchar, varchar, varchar) CASCADE;
CREATE OR REPLACE FUNCTION qgis_pkg.feature_type_checker(
cdb_schema	varchar,
ade_prefix	varchar DEFAULT NULL,	-- NULL = CityGML, <> NULL = CityGML AND selected ADE
extents		varchar DEFAULT NULL	-- WKT polygon without SRID, passed as: ST_AsEWKT(ST_MakeEnvelope(229234, 476749, 230334, 479932))
)
RETURNS TABLE (
	feature_type 	varchar,
    exists_in_db 	boolean
)
AS $$
DECLARE

BEGIN
-- do not perform any checks, they will be carried out by the invoked function anyway
RETURN QUERY
	SELECT t.feature_type AS feature_type, bool_or(t.exists_in_db) AS exists_in_db
	FROM qgis_pkg.root_class_checker(cdb_schema, ade_prefix, extents) AS t 
	GROUP BY t.feature_type 
	ORDER BY t.feature_type;

RETURN;

EXCEPTION
	WHEN QUERY_CANCELED THEN
		RAISE EXCEPTION 'qgis_pkg.feature_type_checker(): Error QUERY_CANCELED';
  WHEN OTHERS THEN 
		RAISE EXCEPTION 'qgis_pkg.feature_type_checker(): %', SQLERRM;
END;
$$ LANGUAGE plpgsql;
COMMENT ON FUNCTION qgis_pkg.feature_type_checker(varchar, varchar, varchar) IS 'Checks whether features types (CityGML modules) exist in the selected cdb_schema';
REVOKE EXECUTE ON FUNCTION qgis_pkg.feature_type_checker(varchar, varchar, varchar) FROM public;


----------------------------------------------------------------
-- Create FUNCTION QGIS_PKG.FEATURE_TYPE_COUNTER
----------------------------------------------------------------
-- Counts features types (CityGML modules) in the selected cdb_schema
DROP FUNCTION IF EXISTS    qgis_pkg.feature_type_counter(varchar, varchar, varchar) CASCADE;
CREATE OR REPLACE FUNCTION qgis_pkg.feature_type_counter(
cdb_schema	varchar,
ade_prefix	varchar DEFAULT NULL,	-- NULL = CityGML, <> NULL = CityGML AND selected ADE
extents		varchar DEFAULT NULL	-- WKT polygon without SRID, passed as: ST_AsEWKT(ST_MakeEnvelope(229234, 476749, 230334, 479932))
)
RETURNS TABLE (
	feature_type 	varchar,
    n_feature_type 	bigint
)
AS $$
DECLARE

BEGIN
--do not perform any checks, they will be carried out by the invoked function anyway
RETURN QUERY
	SELECT t.feature_type AS feature_type, sum(t.n_feature)::bigint AS n_feature_type
	FROM qgis_pkg.root_class_counter(cdb_schema, ade_prefix, extents) AS t 
	GROUP BY t.feature_type 
	ORDER BY t.feature_type;

RETURN;

EXCEPTION
	WHEN QUERY_CANCELED THEN
		RAISE EXCEPTION 'qgis_pkg.feature_type_counter(): Error QUERY_CANCELED';
  WHEN OTHERS THEN 
		RAISE EXCEPTION 'qgis_pkg.feature_type_counter(): %', SQLERRM;
END;
$$ LANGUAGE plpgsql;
COMMENT ON FUNCTION qgis_pkg.feature_type_counter(varchar, varchar, varchar) IS 'Counts features types (CityGML modules) in the selected cdb_schema';
REVOKE EXECUTE ON FUNCTION qgis_pkg.feature_type_counter(varchar, varchar, varchar) FROM public;

-- Example: 
--SELECT * FROM qgis_pkg.feature_type_counter('alderaan', NULL);
--SELECT * FROM qgis_pkg.feature_type_counter('rh', ST_AsEWKT(ST_MakeEnvelope(229234, 476749, 230334, 479932)));


----------------------------------------------------------------
-- Create FUNCTION QGIS_PKG.ROOT_CLASS_CHECKER
----------------------------------------------------------------
-- Checks whether root-class objects in the selected cdb_schema exist
DROP FUNCTION IF EXISTS    qgis_pkg.root_class_checker(varchar, varchar, varchar) CASCADE;
CREATE OR REPLACE FUNCTION qgis_pkg.root_class_checker(
cdb_schema	varchar,
ade_prefix	varchar DEFAULT NULL,	-- NULL = CityGML, <> NULL = CityGML AND selected ADE
extents		varchar DEFAULT NULL	-- WKT polygon without SRID, passed as: ST_AsEWKT(ST_MakeEnvelope(229234, 476749, 230334, 479932))
)
RETURNS TABLE (
	feature_type 	varchar,
	root_class	 	varchar,
	objectclass_id	integer,
    exists_in_db 	boolean
)
AS $$
DECLARE
cdb_schemas_array 	varchar[] := (SELECT array_agg(s.cdb_schema) FROM qgis_pkg.list_cdb_schemas() AS s);
a_pref				varchar := ade_prefix;
srid				integer;
oc_id				integer;
query_geom			geometry(Polygon);
sql_where 			varchar;
sql_statement 		varchar;
row_test 			boolean;
r 					RECORD;

BEGIN
-- Check if the cdb_schema exists
IF (cdb_schema IS NULL) OR (NOT cdb_schema = ANY(cdb_schemas_array)) THEN
	RAISE EXCEPTION 'cdb_schema ''%'' is invalid. It must correspond to an existing cdb_schema in %',cdb_schema, cdb_schemas_array;
END IF;

-- Check if the ADE exists
IF ade_prefix IS NOT NULL THEN
	IF EXISTS(SELECT 1 FROM qgis_pkg.list_ades(cdb_schema) AS a WHERE a.ade_prefix = a_pref) IS TRUE THEN
		-- the ADE exists, do nothing, all fine
	ELSE
		RAISE EXCEPTION 'ade_prefix ''%'' is invalid as it does not exist in cdb_schema ''%''', ade_prefix, cdb_schema;
	END IF;
END IF;

IF extents IS NULL THEN
	sql_where := NULL;
ELSE
	-- Get the srid from the cdb_schema and add it to the WKT polygon passed in the input
	EXECUTE format('SELECT srid FROM %I.database_srs LIMIT 1', cdb_schema) INTO srid;
	query_geom := ST_GeomFromText(extents, srid);
	sql_where  := concat(' AND ST_MakeEnvelope(',ST_XMin(query_geom),',',ST_YMin(query_geom),',',ST_XMax(query_geom),',',ST_YMax(query_geom),',',srid,') && co.envelope');
END IF;

FOR r IN 
	SELECT t.feature_type, t.toplevel_feature 
	FROM qgis_pkg.feature_type_to_toplevel_feature AS t
	WHERE 
		t.ade_prefix IS NULL OR t.ade_prefix IS NOT DISTINCT FROM a_pref
		AND t.is_supported IS TRUE
LOOP

	feature_type := r.feature_type;
	root_class := r.toplevel_feature;

	-- Get the objectclass_id related to that feature from table OBJECTCLASS
	EXECUTE format('SELECT id FROM %I.objectclass WHERE classname = %L LIMIT 1', cdb_schema, r.toplevel_feature) INTO oc_id;
	objectclass_id := oc_id;

	-- Get the objectclass_id related to that feature from table OBJECTCLASS
	sql_statement := concat('SELECT exists(SELECT id FROM ',quote_ident(cdb_schema),'.cityobject AS co WHERE co.objectclass_id = ', oc_id, sql_where,' LIMIT 1);');
	EXECUTE sql_statement INTO row_test;
	
	-- RAISE NOTICE '%, % (oc_id=%): %', feature_type, root_class, oc_id, row_test;

	exists_in_db := row_test;
	
	RETURN NEXT;
END LOOP;

RETURN;

EXCEPTION
	WHEN QUERY_CANCELED THEN
		RAISE EXCEPTION 'qgis_pkg.root_class_checker(): Error QUERY_CANCELED';
	WHEN OTHERS THEN 
		RAISE EXCEPTION 'qgis_pkg.root_class_checker(): %', SQLERRM;
END;
$$ LANGUAGE plpgsql;
COMMENT ON FUNCTION qgis_pkg.root_class_checker(varchar, varchar, varchar) IS 'Checks whether root-class objects in the selected cdb_schema exist';
REVOKE EXECUTE ON FUNCTION qgis_pkg.root_class_checker(varchar, varchar, varchar) FROM public;

-- Example: 
--SELECT * FROM qgis_pkg.root_class_counter('qgis_user_rw','alderaan', NULL);
--SELECT * FROM qgis_pkg.root_class_counter('qgis_user_rw','rh', ST_AsEWKT(ST_MakeEnvelope(229234, 476749, 230334, 479932)));


----------------------------------------------------------------
-- Create FUNCTION QGIS_PKG.ROOT_CLASS_COUNTER
----------------------------------------------------------------
DROP FUNCTION IF EXISTS    qgis_pkg.root_class_counter(varchar, varchar, varchar) CASCADE;
CREATE OR REPLACE FUNCTION qgis_pkg.root_class_counter(
cdb_schema	varchar,
ade_prefix	varchar DEFAULT NULL,   -- NULL = CityGML, <> NULL = CityGML AND selected ADE
extents		varchar DEFAULT NULL	-- PostGIS polygon without SRID, e.g. passed as: ST_AsEWKT(ST_MakeEnvelope(229234, 476749, 230334, 479932))
)
RETURNS TABLE (
	feature_type 	varchar,
	root_class	 	varchar,
	objectclass_id	integer,
    n_feature		bigint
)
AS $$
DECLARE
cdb_schemas_array 	varchar[] := (SELECT array_agg(s.cdb_schema) FROM qgis_pkg.list_cdb_schemas() AS s); 
a_pref				varchar := ade_prefix;
srid				integer;
n_co				bigint;
oc_id				integer;
query_geom			geometry(Polygon);
sql_where 			varchar;
sql_statement 		varchar;
r 					RECORD;

BEGIN
-- Check if the cdb_schema exists
IF (cdb_schema IS NULL) OR (NOT cdb_schema = ANY(cdb_schemas_array)) THEN
	RAISE EXCEPTION 'cdb_schema is invalid. It must correspond to an existing citydb schema';
END IF;

-- Check if the ADE exists
IF ade_prefix IS NOT NULL THEN
	IF EXISTS(SELECT 1 FROM qgis_pkg.list_ades(cdb_schema) AS a WHERE a.ade_prefix = a_pref) IS TRUE THEN
		-- the ADE exists, do nothing, all fine
	ELSE
		RAISE EXCEPTION 'ade_prefix ''%'' is invalid as it does not exist in cdb_schema ''%''', ade_prefix, cdb_schema;
	END IF;
END IF;

IF extents IS NULL THEN
	sql_where := NULL;
ELSE
	-- Get the srid from the cdb_schema
	EXECUTE format('SELECT srid FROM %I.database_srs LIMIT 1', cdb_schema) INTO srid;
	query_geom := ST_GeomFromText(extents, srid);
	sql_where  := concat(' AND ST_MakeEnvelope(',ST_XMin(query_geom),',',ST_YMin(query_geom),',',ST_XMax(query_geom),',',ST_YMax(query_geom),',',srid,') && co.envelope');
END IF;

FOR r IN 
	SELECT t.feature_type, t.toplevel_feature 
	FROM qgis_pkg.feature_type_to_toplevel_feature AS t
	WHERE 
		t.ade_prefix IS NULL OR t.ade_prefix IS NOT DISTINCT FROM a_pref
		AND t.is_supported IS TRUE
LOOP
	feature_type := r.feature_type;
	root_class := r.toplevel_feature;
	EXECUTE format('SELECT id FROM %I.objectclass WHERE classname = %L LIMIT 1', cdb_schema, r.toplevel_feature) INTO oc_id;
	objectclass_id := oc_id;

	sql_statement := concat('SELECT count(id) AS n_co FROM ', quote_ident(cdb_schema),'.cityobject AS co WHERE co.objectclass_id = ', oc_id, sql_where, ';');
	EXECUTE sql_statement INTO n_co;
	--RAISE NOTICE '%, % (oc_id=%): %', feature_type, root_class, oc_id, n_co;

	n_feature := n_co;
	
	RETURN NEXT;
END LOOP;

RETURN;

EXCEPTION
	WHEN QUERY_CANCELED THEN
		RAISE EXCEPTION 'qgis_pkg.root_class_counter(): Error QUERY_CANCELED';
  WHEN OTHERS THEN 
		RAISE EXCEPTION 'qgis_pkg.root_class_counter(): %', SQLERRM;
END;
$$ LANGUAGE plpgsql;
COMMENT ON FUNCTION qgis_pkg.root_class_counter(varchar, varchar, varchar) IS 'Counts root-class objects in the selected cdb_schema';
REVOKE EXECUTE ON FUNCTION qgis_pkg.root_class_counter(varchar, varchar, varchar) FROM public;

-- Example: 
--SELECT * FROM qgis_pkg.root_class_counter('alderaan', NULL);
--SELECT * FROM qgis_pkg.root_class_counter('rh', ST_AsEWKT(ST_MakeEnvelope(229234, 476749, 230334, 479932)));


----------------------------------------------------------------
-- Create FUNCTION QGIS_PKG.HAS_LAYERS_FOR_CDB_SCHEMA
----------------------------------------------------------------
-- Returns True if usr_schema contains layers that were generated before
-- It searches the schema for view names starting with the input usr_schema.
DROP FUNCTION IF EXISTS    qgis_pkg.has_layers_for_cdb_schema(varchar, varchar, varchar) CASCADE;
CREATE OR REPLACE FUNCTION qgis_pkg.has_layers_for_cdb_schema(
usr_schema varchar,
cdb_schema varchar,
ade_prefix varchar DEFAULT NULL
)
RETURNS boolean
AS $$
DECLARE
cdb_schemas_array 	varchar[] := (SELECT array_agg(s.cdb_schema) FROM qgis_pkg.list_cdb_schemas() AS s);
a_pref 				varchar := ade_prefix;
layer_prefix 		varchar;

BEGIN
-- Check if the cdb_schema exists
IF (cdb_schema IS NULL) OR (NOT cdb_schema = ANY(cdb_schemas_array)) THEN
	RAISE EXCEPTION 'cdb_schema is invalid. It must correspond to an existing citydb schema';
END IF;

-- Check if the ADE exists
IF ade_prefix IS NOT NULL THEN
	IF EXISTS(SELECT 1 FROM qgis_pkg.list_ades(cdb_schema) AS a WHERE a.ade_prefix = a_pref) IS TRUE THEN
		-- the ADE exists, do nothing, all fine
		layer_prefix := concat(cdb_schema,'_',ade_prefix,'_%');
	ELSE
		RAISE EXCEPTION 'ade_prefix ''%'' is invalid as it does not exist in cdb_schema ''%''', ade_prefix, cdb_schema;
	END IF;
ELSE -- ade_prefix is null
	layer_prefix := concat(cdb_schema,'_%');
END IF;

PERFORM t.table_name
	FROM
		 information_schema.tables AS t
    WHERE 
		quote_ident(t.table_schema) = quote_ident(usr_schema)
		AND t.table_type = 'VIEW'
		AND t.table_name::varchar LIKE layer_prefix;

RETURN FOUND;

EXCEPTION
	WHEN QUERY_CANCELED THEN
		RAISE EXCEPTION 'qgis_pkg.has_layers_for_cdb_schema(): Error QUERY_CANCELED';
  WHEN OTHERS THEN 
		RAISE EXCEPTION 'qgis_pkg.has_layers_for_cdb_schema(): %', SQLERRM;
END;
$$ LANGUAGE plpgsql;
COMMENT ON FUNCTION qgis_pkg.has_layers_for_cdb_schema(varchar,varchar,varchar) IS 'Searches for cdb_schema name into the view names of the usr_schema to determine if it supports the input cdb_schema and the selected ADE.';
REVOKE EXECUTE ON FUNCTION qgis_pkg.has_layers_for_cdb_schema(varchar,varchar,varchar) FROM public;


----------------------------------------------------------------
-- Create FUNCTION CLASS_NAME_TO_CLASS_ID
----------------------------------------------------------------
-- Returns the class_id from table OBJECTCLASS of the given class
DROP FUNCTION IF EXISTS    qgis_pkg.class_name_to_class_id(varchar, varchar, varchar);
CREATE OR REPLACE FUNCTION qgis_pkg.class_name_to_class_id(
	cdb_schema	varchar,
	class_name	varchar,
	ade_prefix	varchar DEFAULT NULL
)
RETURNS integer AS $$
DECLARE
	ade_id		integer := NULL;
	class_id	varchar := NULL;
BEGIN
IF ade_prefix IS NOT NULL THEN
	EXECUTE format('SELECT a.id FROM %I.ade AS a WHERE a.db_prefix=%L', cdb_schema, ade_prefix) INTO ade_id;
	IF ade_id IS NULL THEN
		RAISE EXCEPTION 'There is no ADE with prefix "%"!', ade_prefix;
	END IF;
END IF;

IF ade_prefix IS NULL THEN
	-- we are looking for a standard CityGML objectclass
	EXECUTE format('SELECT o.id FROM %I.objectclass AS o WHERE o.classname=%L AND ade_id IS NULL', cdb_schema, class_name) INTO class_id;
ELSE
	-- we are looking for an ADE objectclass
	EXECUTE format('SELECT o.id FROM %I.objectclass AS o WHERE o.classname=%L AND ade_id=%L', cdb_schema, ade_id) INTO class_id;
END IF;

IF class_id IS NULL THEN
	RAISE EXCEPTION 'There is no class found with name "%" in schema "%"!', class_name,  cdb_schema;
ELSE
	RETURN class_id;
END IF;

EXCEPTION
	WHEN QUERY_CANCELED THEN
		RAISE EXCEPTION 'qgis_pkg.class_name_to_class_id(): Error QUERY_CANCELED';
	WHEN OTHERS THEN 
		RAISE EXCEPTION 'qgis_pkg.class_name_to_class_id(%, %, %): %', cdb_schema, class_name, ade_prefix, SQLERRM;
END;
$$ LANGUAGE plpgsql;
COMMENT ON FUNCTION qgis_pkg.class_name_to_class_id(varchar, varchar, varchar) IS 'Returns the class_id from table OBJECTCLASS of the given class';
REVOKE EXECUTE ON FUNCTION qgis_pkg.class_name_to_class_id(varchar, varchar, varchar) FROM public;

-- Example:
--SELECT qgis_pkg.class_name_to_class_id('citydb', 'SolitaryVegetationObject', NULL);
--SELECT qgis_pkg.class_name_to_class_id('citydb', 'ThermalZone', 'ng');


----------------------------------------------------------------
-- Create FUNCTION QGIS_PKG.GVIEW_COUNTER
----------------------------------------------------------------
-- Counts records in the selected materialized view with geometries (gview)
-- This function can be run providing only the name of the gview, OR, alternatively, also the extents.
DROP FUNCTION IF EXISTS    qgis_pkg.gview_counter(varchar, varchar, varchar, varchar) CASCADE;
CREATE OR REPLACE FUNCTION qgis_pkg.gview_counter(
usr_schema	varchar,
cdb_schema	varchar,
gview_name	varchar, 				-- Materialised view name containing geometries (i.e. prefixed with _g_)
extents		varchar DEFAULT NULL	-- PostGIS polygon without SRID, e.g. passed as: ST_AsEWKT(ST_MakeEnvelope(229234, 476749, 230334, 479932))
)
RETURNS integer
AS $$
DECLARE
counter		integer := 0;
srid		integer;
query_geom	geometry(Polygon);
query_bbox	box2d;

BEGIN
IF EXISTS(SELECT mv.matviewname FROM pg_matviews AS mv WHERE mv.schemaname::varchar = usr_schema AND mv.ispopulated IS TRUE) THEN
	IF extents IS NULL THEN
		EXECUTE format('SELECT count(co_id) FROM %I.%I', usr_schema, gview_name) INTO counter;
	ELSE
		EXECUTE format('SELECT srid FROM %I.database_srs LIMIT 1', cdb_schema) INTO srid;
		query_geom := ST_GeomFromText(extents,srid);
		query_bbox := ST_Extent(query_geom);
		EXECUTE FORMAT('SELECT count(t.co_id) FROM %I.%I t WHERE $1 && t.geom', usr_schema, gview_name, query_bbox) USING query_bbox INTO counter;
	END IF;
ELSE
	RAISE EXCEPTION 'View "%"."%" does not exist', usr_schema, gview_name;	
END IF;
RETURN counter;
EXCEPTION
	WHEN QUERY_CANCELED THEN
		RAISE EXCEPTION 'qgis_pkg.gview_counter(): Error QUERY_CANCELED';
  WHEN OTHERS THEN 
		RAISE EXCEPTION 'qgis_pkg.gview_counter(): %', SQLERRM;
END;
$$ LANGUAGE plpgsql;
COMMENT ON FUNCTION qgis_pkg.gview_counter(varchar, varchar, varchar, varchar) IS 'Counts records in the selected materialized view for geometries';
REVOKE EXECUTE ON FUNCTION qgis_pkg.gview_counter(varchar, varchar, varchar, varchar) FROM public;

-- Example: 
--SELECT qgis_pkg.gview_counter('qgis_giorgio','citydb2','citydb_bdg_lod0_footprint', NULL);
--SELECT qgis_pkg.gview_counter('qgis_giorgio','citydb2','citydb_bdg_lod0_footprint', ST_AsEWKT(ST_MakeEnvelope(229234, 476749, 230334, 479932)));


----------------------------------------------------------------
-- Create FUNCTION QGIS_PKG.UPSERT_SETTINGS
----------------------------------------------------------------
DROP FUNCTION IF EXISTS    qgis_pkg.upsert_settings(varchar, varchar, varchar, integer, varchar, varchar);
CREATE OR REPLACE FUNCTION qgis_pkg.upsert_settings(
	usr_schema		varchar,
	dialog_name 	varchar,
	name			varchar,
	data_type		integer,
	data_value		varchar,
	description		varchar)
RETURNS integer
AS $$
DECLARE
	upserted_id integer;
	data_type_array CONSTANT integer[] := ARRAY[1,2,3,4,5];
	qgis_pkg_name CONSTANT varchar := 'qgis_pkg';
	usr_schemas_array 	varchar[] := (SELECT array_agg(s.usr_schema) FROM qgis_pkg.list_usr_schemas() AS s);

/* Data types
1 string
2 integer
3 real
4 boolean
5 date
*/

BEGIN
-- Add the qgis_pkg to the list of schemas
usr_schemas_array := array_append(usr_schemas_array, qgis_pkg_name);

-- Check if the usr_schema exists (must habe been created before)
IF usr_schema IS NULL OR NOT usr_schema = ANY(usr_schemas_array) THEN
	RAISE EXCEPTION 'usr_schema "%" does not exist. Please create it beforehand', usr_schema;
END IF;

--Check that the dialog_name is valid
IF dialog_name IS NULL OR dialog_name = '' THEN
	RAISE EXCEPTION 'dialog_name value is invalid';
END IF;

--Check that the name is valid
IF name IS NULL OR name = '' THEN
	RAISE EXCEPTION 'name value is invalid';
END IF;

--Check that the data_type is valid
IF data_type IS NULL OR NOT data_type = ANY(data_type_array) data_type THEN
	RAISE EXCEPTION 'data_type must be one of %', data_type_array;
END IF;

EXECUTE format('
	INSERT INTO %I.settings AS s 
		(dialog_name, name, data_type, data_value, description, latest_update)
	VALUES (%L, %L, %L, %L, %L, clock_timestamp())
	ON CONFLICT ON CONSTRAINT settings_dialog_name_name_key DO
		UPDATE SET
			data_value = %L
		WHERE 
			s.dialog_name = %L AND s.name = %L
	RETURNING id',
	usr_schema,
	dialog_name, name, data_type, data_value, description,
	data_value,
	dialog_name, name)
INTO STRICT upserted_id;

RETURN upserted_id;

EXCEPTION
	WHEN QUERY_CANCELED THEN
		RAISE EXCEPTION 'qgis_pkg.upsert_settings(): Error QUERY_CANCELED';
  WHEN OTHERS THEN 
		RAISE EXCEPTION 'qgis_pkg.upsert_settings(): %', SQLERRM;
END;
$$ LANGUAGE plpgsql;
COMMENT ON FUNCTION qgis_pkg.upsert_settings(varchar, varchar, varchar, integer, varchar, varchar) IS 'Insert/Update the SETTINGS table in the user schema';
REVOKE ALL ON FUNCTION qgis_pkg.upsert_settings(varchar, varchar, varchar, integer, varchar, varchar) FROM PUBLIC;

----------------------------------------------------------------
-- Create FUNCTION QGIS_PKG.COMPUTE_SCHEMA_DISK_SIZE()
----------------------------------------------------------------
-- Computes the size occupied on disk by schemas of the current database
DROP FUNCTION IF EXISTS    qgis_pkg.compute_schemas_disk_size();
CREATE OR REPLACE FUNCTION qgis_pkg.compute_schemas_disk_size()
RETURNS TABLE (
  sche_name	varchar,
  size 		varchar
)
AS $$
DECLARE

BEGIN

RETURN QUERY 
	SELECT 
		schemaname::varchar as sch_name, 
		pg_size_pretty(sum(pg_relation_size(quote_ident(schemaname) || '.' || quote_ident(tablename)))::bigint)::varchar as size 
	FROM pg_tables
	WHERE schemaname::varchar NOT IN ('pg_catalog', 'information_schema')
	GROUP BY schemaname
	ORDER BY schemaname;

EXCEPTION
	WHEN QUERY_CANCELED THEN
		RAISE EXCEPTION 'util_pkg.compute_schemas_disk_size(): Error QUERY_CANCELED';
	WHEN OTHERS THEN
		RAISE EXCEPTION 'util_pkg.compute_schemas_disk_size(): %', SQLERRM;
END;
$$ LANGUAGE plpgsql IMMUTABLE;
COMMENT ON FUNCTION qgis_pkg.compute_schemas_disk_size() IS 'Returns the size occupied on disk by schemas of the current database';
REVOKE EXECUTE ON FUNCTION qgis_pkg.compute_schemas_disk_size() FROM public;

-- Example:
-- SELECT * FROM qgis_pkg.compute_schemas_disk_size()

----------------------------------------------------------------
-- Create FUNCTION QGIS_PKG.ST_3DAREA_POLY
----------------------------------------------------------------
DROP FUNCTION IF EXISTS    qgis_pkg.st_3darea_poly(geometry);
CREATE OR REPLACE FUNCTION qgis_pkg.st_3darea_poly(
polygon3d geometry			-- must be a 3D polygon
)
RETURNS numeric AS $$
DECLARE
ring geometry;
n_points integer;
i integer; j integer;
p1 geometry; p2 geometry;
x1 numeric; y1 numeric; z1 numeric;
x2 numeric; y2 numeric; z2 numeric;
n_interior_rings integer;
nx_t numeric := 0;
ny_t numeric := 0;
nz_t numeric := 0;
nl_t numeric := 0;
area numeric := 0;

BEGIN

--polygon3d := ST_Force3D(polygon3d);
ring := ST_RemoveRepeatedPoints(ST_ExteriorRing(polygon3d));
ring := ST_ExteriorRing(polygon3d);
n_points := ST_NPoints(ring);
p1 := ST_PointN(ring,1);
x1 := ST_X(p1);
y1 := ST_Y(p1);
z1 := ST_Z(p1);

FOR i IN 2..n_points LOOP
	p2 := ST_PointN(ring,i);
	x2 := ST_X(p2);
	y2 := ST_Y(p2);
	z2 := ST_Z(p2);
	nx_t := nx_t + (y1-y2)*(z1+z2); 
	ny_t := ny_t + (z1-z2)*(x1+x2);
	nz_t := nz_t + (x1-x2)*(y1+y2);
	x1 := x2;
	y1 := y2;
	z1 := z2;
END LOOP;

n_interior_rings := ST_NumInteriorRings(polygon3d);
IF n_interior_rings > 0 THEN
	FOR j IN 1..n_interior_rings LOOP
		ring := ST_RemoveRepeatedPoints(ST_Reverse(ST_InteriorRingN(polygon3d,j)));	
		n_points := ST_NPoints(ring);
		p1 := ST_PointN(ring,1);
		x1 := ST_X(p1);
		y1 := ST_Y(p1);
		z1 := ST_Z(p1);
		FOR i IN 2..n_points LOOP
			p2 := ST_PointN(ring,i);
			x2 := ST_X(p2);
			y2 := ST_Y(p2);
			z2 := ST_Z(p2);
			nx_t := nx_t - (y1-y2)*(z1+z2); 
			ny_t := ny_t - (z1-z2)*(x1+x2);
			nz_t := nz_t - (x1-x2)*(y1+y2);
			x1 := x2;
			y1 := y2;
			z1 := z2;
		END LOOP; --loop ring points		
	END LOOP; -- loop ring
END IF;

area := sqrt(nx_t^2+ny_t^2+nz_t^2)/2;

RETURN area;

EXCEPTION
	WHEN QUERY_CANCELED THEN
		RAISE EXCEPTION 'util_pkg.st_3darea_poly(): Error QUERY_CANCELED';
	WHEN OTHERS THEN
		RAISE EXCEPTION 'util_pkg.st_3darea_poly(): %', SQLERRM;
END;
$$ LANGUAGE plpgsql IMMUTABLE;
COMMENT ON FUNCTION qgis_pkg.st_3darea_poly(geometry) IS 'Returns the 3D area of a 3D polygon';
REVOKE EXECUTE ON FUNCTION qgis_pkg.st_3darea_poly(geometry) FROM public;

----------------------------------------------------------------
-- Create FUNCTION QGIS_PKG.ST_SNAP_POLY_TO_GRID
----------------------------------------------------------------
DROP FUNCTION IF EXISTS    qgis_pkg.st_snap_poly_to_grid(geometry, integer, integer, numeric) CASCADE;
CREATE OR REPLACE FUNCTION qgis_pkg.st_snap_poly_to_grid(
polygon 			geometry,
perform_snapping 	integer DEFAULT 0, 			-- i.e. default is 0 ("do nothing"), otherwise 1.
digits 				integer DEFAULT 3,			-- number of digits after comma for precision
area_min			numeric DEFAULT 0.0001 		-- minimum acceptable area of a polygon 
)
RETURNS geometry AS $$
DECLARE
dec_prec 		numeric;
srid_id 		integer;
snapped_poly 	geometry(PolygonZ);
num_geoms		integer;
is_empty_geom 	boolean;
ring 			geometry(LinestringZ);
o_ring 			geometry(LinestringZ);
i_ring			geometry(LinestringZ);
i_rings 		geometry(LinestringZ)[];
n_int_rings		integer;
i integer; r RECORD;
area_poly 		numeric;
new_polygon 	geometry(PolygonZ);

BEGIN

CASE 
	WHEN perform_snapping = 0 THEN
		RETURN polygon;
	WHEN perform_snapping = 1 THEN
		dec_prec := 10^(-digits);
		srid_id := ST_SRID(polygon);
		snapped_poly := ST_SnapToGrid(polygon, ST_GeomFromText('Point(0 0 0)'), dec_prec, dec_prec, dec_prec, 0);
		is_empty_geom := ST_IsEmpty(snapped_poly);

		IF is_empty_geom IS TRUE THEN
			RETURN NULL;
		ELSE -- there is a geometry from the resulting snap to grid process
			num_geoms := ST_NumGeometries(snapped_poly);
			IF num_geoms > 1 THEN
				RAISE NOTICE 'Number of geometries resulting from the snapped polygon is %', num_geoms;
			END IF;

			ring := ST_ExteriorRing(snapped_poly);
			o_ring := ring;
			FOR r IN SELECT
				foo.path[1]-1 AS zero_based_index,
				round(ST_x(foo.geom)::numeric,digits)::double precision AS px,
				round(ST_y(foo.geom)::numeric,digits)::double precision AS py,
				round(ST_z(foo.geom)::numeric,digits)::double precision AS pz
			FROM ST_DumpPoints(ring) AS foo
			LOOP
				o_ring := ST_SetPoint(o_ring, r.zero_based_index, ST_MakePoint(r.px, r.py, r.pz));
			END LOOP;
			o_ring := ST_SetSRID(o_ring, srid_id);

			n_int_rings	:= ST_NumInteriorRings(snapped_poly);
			IF n_int_rings > 0 THEN
				FOR i IN 1..n_int_rings LOOP
					ring := ST_InteriorRingN(snapped_poly, i);
					i_ring := ring;
					FOR r IN SELECT
						foo.path[1]-1 AS zero_based_index,
						round(ST_x(foo.geom)::numeric,digits)::double precision AS px,
						round(ST_y(foo.geom)::numeric,digits)::double precision AS py,
						round(ST_z(foo.geom)::numeric,digits)::double precision AS pz
					FROM ST_DumpPoints(ring) AS foo
					LOOP
						i_ring := ST_SetPoint(i_ring, r.zero_based_index, ST_MakePoint(r.px, r.py, r.pz));
					END LOOP;			
					i_rings := array_append(i_rings, i_ring);
				END LOOP;
			END IF;
		END IF;
ELSE
	RAISE EXCEPTION 'Value of "perform_snapping" input parameter is invalid. It must be either 0 or 1'; 
END CASE;

IF n_int_rings = 0 THEN
	new_polygon := ST_MakePolygon(o_ring);
ELSE
	new_polygon := ST_MakePolygon(o_ring, i_rings);
END IF;

area_poly := qgis_pkg.ST_3DArea_poly(new_polygon);

IF (area_poly IS NULL) OR (area_poly <= area_min) THEN
	RETURN NULL;
ELSE
	RETURN new_polygon;
END IF;

EXCEPTION
	WHEN QUERY_CANCELED THEN
		RAISE EXCEPTION 'qgis_pkg.st_snap_poly_to_grid(): Error QUERY_CANCELED';
	WHEN OTHERS THEN
		RAISE EXCEPTION 'qgis_pkg.st_snap_poly_to_grid(): %', SQLERRM;
END;
$$ LANGUAGE plpgsql IMMUTABLE;
COMMENT ON FUNCTION qgis_pkg.st_snap_poly_to_grid(geometry, integer, integer, numeric) IS 'Snaps 3D polygon to grid and drops it if it is smaller than the minimum area threshold';
REVOKE EXECUTE ON FUNCTION qgis_pkg.st_snap_poly_to_grid(geometry, integer, integer, numeric) FROM public;

--SELECT qgis_pkg.st_snap_poly_to_grid(geometry, 1, 2, 0.01) FROM citydb.surface_geometry WHERE geometry IS NOT NULL LIMIT 10000;








----------------------------------------------------------------
-- Create FUNCTION QGIS_PKG.GENERATE_SQL_MATVIEW_HEADER
----------------------------------------------------------------
DROP FUNCTION IF EXISTS    qgis_pkg.generate_sql_matview_header(varchar,varchar) CASCADE;
CREATE OR REPLACE FUNCTION qgis_pkg.generate_sql_matview_header(
qi_usr_schema	varchar,
qi_gv_name	varchar 
)
RETURNS text
AS $$
DECLARE
sql_statement text;

BEGIN

sql_statement := concat('
-----------------------------------------------------------------
-- MATERIALIZED VIEW ',upper(qi_usr_schema),'.',upper(qi_gv_name),'
-----------------------------------------------------------------
DROP MATERIALIZED VIEW IF EXISTS ',qi_usr_schema,'.',qi_gv_name,' CASCADE;
CREATE MATERIALIZED VIEW         ',qi_usr_schema,'.',qi_gv_name,' AS');

RETURN sql_statement;

EXCEPTION
	WHEN QUERY_CANCELED THEN
		RAISE EXCEPTION 'qgis_pkg.generate_sql_matview_header(): Error QUERY_CANCELED';
  WHEN OTHERS THEN 
		RAISE EXCEPTION 'qgis_pkg.generate_sql_matview_header(): %', SQLERRM;
END;
$$ LANGUAGE plpgsql;
REVOKE EXECUTE ON FUNCTION qgis_pkg.generate_sql_matview_header(varchar,varchar) FROM public;

----------------------------------------------------------------
-- Create FUNCTION QGIS_PKG.GENERATE_SQL_MATVIEW_FOOTER
----------------------------------------------------------------
DROP FUNCTION IF EXISTS    qgis_pkg.generate_sql_matview_footer(varchar,varchar,varchar,varchar) CASCADE;
CREATE OR REPLACE FUNCTION qgis_pkg.generate_sql_matview_footer(
qi_usr_name   varchar,
qi_usr_schema varchar,
ql_l_name	  varchar,
qi_gv_name	  varchar
)
RETURNS text
AS $$
DECLARE
gv_name CONSTANT varchar := trim(both '"' from qi_gv_name);
gv_idx_name CONSTANT varchar := quote_ident(concat(gv_name,'_id_idx'));
gv_spx_name CONSTANT varchar := quote_ident(concat(gv_name,'_geom_spx'));
sql_statement text;

BEGIN
sql_statement := concat('
CREATE INDEX ',gv_idx_name,' ON ',qi_usr_schema,'.',qi_gv_name,' (co_id);
CREATE INDEX ',gv_spx_name,' ON ',qi_usr_schema,'.',qi_gv_name,' USING gist (geom);
ALTER TABLE ',qi_usr_schema,'.',qi_gv_name,' OWNER TO ',qi_usr_name,';
--DELETE FROM ',qi_usr_schema,'.layer_metadata AS lm WHERE lm.layer_name = ',ql_l_name,';
--REFRESH MATERIALIZED VIEW ',qi_usr_schema,'.',qi_gv_name,';
');

RETURN sql_statement;

EXCEPTION
	WHEN QUERY_CANCELED THEN
		RAISE EXCEPTION 'qgis_pkg.generate_sql_matview_footer(): Error QUERY_CANCELED';
  WHEN OTHERS THEN 
		RAISE EXCEPTION 'qgis_pkg.generate_sql_matview_footer(): %', SQLERRM;
END;
$$ LANGUAGE plpgsql;
REVOKE EXECUTE ON FUNCTION qgis_pkg.generate_sql_matview_footer(varchar,varchar,varchar,varchar) FROM public;

----------------------------------------------------------------
-- Create FUNCTION QGIS_PKG.GENERATE_SQL_VIEW_HEADER
----------------------------------------------------------------
DROP FUNCTION IF EXISTS    qgis_pkg.generate_sql_view_header(varchar,varchar) CASCADE;
CREATE OR REPLACE FUNCTION qgis_pkg.generate_sql_view_header(
qi_usr_schema	varchar,
qi_layer_name	varchar 
)
RETURNS text
AS $$
DECLARE
sql_statement text;

BEGIN
sql_statement := concat('
-----------------------------------------------------------------
-- VIEW ',upper(qi_usr_schema),'.',upper(qi_layer_name),' -- joins attributes and mat views of geometries
-----------------------------------------------------------------
DROP VIEW IF EXISTS    ',qi_usr_schema,'.',qi_layer_name,' CASCADE;
CREATE OR REPLACE VIEW ',qi_usr_schema,'.',qi_layer_name,' AS');

RETURN sql_statement;

EXCEPTION
	WHEN QUERY_CANCELED THEN
		RAISE EXCEPTION 'qgis_pkg.generate_sql_view_header(): Error QUERY_CANCELED';
  WHEN OTHERS THEN 
		RAISE EXCEPTION 'qgis_pkg.generate_sql_view_header(): %', SQLERRM;
END;
$$ LANGUAGE plpgsql;
REVOKE EXECUTE ON FUNCTION qgis_pkg.generate_sql_view_header(varchar,varchar) FROM public;

----------------------------------------------------------------
-- Create FUNCTION QGIS_PKG.GENERATE_SQL_MATVIEW_ELSE
----------------------------------------------------------------
DROP FUNCTION IF EXISTS    qgis_pkg.generate_sql_matview_else(varchar,varchar,varchar,varchar,varchar) CASCADE;
CREATE OR REPLACE FUNCTION qgis_pkg.generate_sql_matview_else(
qi_usr_schema varchar,
ql_cdb_schema varchar,
ql_l_type     varchar,
ql_l_name     varchar,
qi_gv_name    varchar
)
RETURNS text
AS $$
DECLARE
sql_statement text;

BEGIN
sql_statement := concat('
-- This drops the materialized view AND the associated view
DROP MATERIALIZED VIEW IF EXISTS ',qi_usr_schema,'.',qi_gv_name,' CASCADE;
DELETE FROM ',qi_usr_schema,'.layer_metadata AS lm WHERE lm.cdb_schema = ',ql_cdb_schema,' AND lm.layer_type = ',ql_l_type,' AND lm.layer_name = ', ql_l_name,';
');

RETURN sql_statement;

EXCEPTION
	WHEN QUERY_CANCELED THEN
		RAISE EXCEPTION 'qgis_pkg.generate_sql_matview_else(): Error QUERY_CANCELED';
  WHEN OTHERS THEN 
		RAISE EXCEPTION 'qgis_pkg.generate_sql_matview_else(): %', SQLERRM;
END;
$$ LANGUAGE plpgsql;
REVOKE EXECUTE ON FUNCTION qgis_pkg.generate_sql_matview_else(varchar,varchar,varchar,varchar,varchar) FROM public;

----------------------------------------------------------------
-- Create FUNCTION QGIS_PKG.GENERATE_SQL_TRIGGERS
----------------------------------------------------------------
-- Function to generate SQL for triggers
DROP FUNCTION IF EXISTS    qgis_pkg.generate_sql_triggers(varchar, varchar, varchar) CASCADE;
CREATE OR REPLACE FUNCTION qgis_pkg.generate_sql_triggers(
usr_schema			varchar,
layer_name			varchar,
tr_function_suffix	varchar
)
RETURNS text
AS $$
DECLARE
tr					RECORD;
trigger_f			varchar;
trigger_n			varchar;
slq_stat_trig_part	text := NULL;
sql_statement		text := NULL;

BEGIN
FOR tr IN 
	SELECT * FROM (VALUES
	('ins'::varchar,	'insert'::varchar,	'INSERT'::varchar),
	('upd',				'update',			'UPDATE'),
	('del',				'delete',			'DELETE')	
	) AS t(tr_short, tr_small, tr_cap)
LOOP
	trigger_f := format('tr_%s_%s()', tr.tr_short, tr_function_suffix);
	trigger_n := concat('tr_', tr.tr_short, '_', layer_name);
	slq_stat_trig_part := NULL;
	slq_stat_trig_part := format('
DROP TRIGGER IF EXISTS %I ON %I.%I;
CREATE TRIGGER         %I
	INSTEAD OF %s ON %I.%I
	FOR EACH ROW EXECUTE PROCEDURE qgis_pkg.%s;
COMMENT ON TRIGGER %I ON %I.%I IS ''Fired upon %s into view %I.%I'';
',
	trigger_n, usr_schema, layer_name,
	trigger_n,
	tr.tr_cap, usr_schema, layer_name,
	trigger_f,
	trigger_n, usr_schema, layer_name,
	tr.tr_small, usr_schema, layer_name
	);
	sql_statement := concat(sql_statement, slq_stat_trig_part);
END LOOP;

RETURN sql_statement;

EXCEPTION
	WHEN QUERY_CANCELED THEN
		RAISE EXCEPTION 'qgis_pkg.generate_sql_triggers(): Error QUERY_CANCELED';
  WHEN OTHERS THEN 
		RAISE EXCEPTION 'qgis_pkg.generate_sql_triggers(): %', SQLERRM;
END;
$$ LANGUAGE plpgsql;
REVOKE EXECUTE ON FUNCTION qgis_pkg.generate_sql_triggers(varchar, varchar, varchar) FROM public;

/* --- TEMPLATE FOR ADDITIONAL FUNCTIONS
----------------------------------------------------------------
-- Create FUNCTION QGIS_PKG.XX_FUNCNAME_XX
----------------------------------------------------------------
-- A short description of what it does
-- ...
-- ...
DROP FUNCTION IF EXISTS    qgis_pkg.xx_funcname_xx(signature) CASCADE;
CREATE OR REPLACE FUNCTION qgis_pkg.xx_funcname_xx(
param1 type,
param2 type
...
)
RETURNS xxxx
AS $$
DECLARE
	param3 type;
	param4 type;
...

BEGIN

-- body of the function


EXCEPTION
	WHEN QUERY_CANCELED THEN
		RAISE EXCEPTION 'qgis_pkg.xx_funcname_xx(): Error QUERY_CANCELED';
  WHEN OTHERS THEN 
		RAISE EXCEPTION 'qgis_pkg.xx_funcname_xx(): %', SQLERRM;
END;
$$ LANGUAGE plpgsql;
COMMENT ON FUNCTION qgis_pkg.xx_funcname_xx(varchar) IS 'xxxx short comment xxxx';
REVOKE EXECUTE ON FUNCTION qgis_pkg.xx_funcname_xx(...) FROM public;
*/

--**************************
DO $$
BEGIN
RAISE NOTICE E'\n\nDone\n\n';
END $$;
--**************************
-- ***********************************************************************
-- Version: P5(Final) Oct.17.2024
-- This script created the qgis_pkg schema, and then installs a set of functions into it
-- List of functions:
--
-- qgis_pkg.qgis_pkg_version()
-- qgis_pkg.is_superuser()
-- qgis_pkg.cleanup_schema()
-- qgis_pkg.create_qgis_pkg_usrgroup_name()
-- qgis_pkg.create_qgis_pkg_usrgroup()
-- qgis_pkg.add_user_to_qgis_pkg_usrgroup()
-- qgis_pkg.remove_user_from_qgis_pkg_usrgroup()
-- qgis_pkg.list_qgis_pkg_usrgroup_members()
-- qgis_pkg.list_qgis_pkg_non_usrgroup_members()
-- qgis_pkg.create_default_qgis_pkg_user()
-- qgis_pkg.create_qgis_usr_schema_name()
-- qgis_pkg.list_cdb_schemas()
-- qgis_pkg.create_qgis_usr_schema()
-- qgis_pkg.grant_qgis_usr_privileges()
-- qgis_pkg.revoke_qgis_usr_privileges()
-- qgis_pkg.grant_qgis_usr_privileges(ARRAY)
-- qgis_pkg.revoke_qgis_usr_privileges(ARRAY)
-- qgis_pkg.objectclass_id_to_alias()
-- qgis_pkg.classname_to_objectclass_id()
-- qgis_pkg.objectclass_id_to_classname()
-- qgis_pkg.datatype_name_to_type_id()
-- qgis_pkg.generate_sql_view_header()
-- qgis_pkg.generate_sql_matview_header()
-- qgis_pkg.generate_sql_matview_footer()
-- qgis_pkg.compute_cdb_schema_extents()
-- qgis_pkg.upsert_extents()
-- qgis_pkg.generate_mview_bbox_poly()

--
-- ***********************************************************************

-- Drop schema if it already exists from before.
DROP SCHEMA IF EXISTS qgis_pkg CASCADE;
-- Create new qgis_pkg schema;
CREATE SCHEMA         qgis_pkg;
-- Add "uuid-ossp" extension (if not already installed);
CREATE EXTENSION IF NOT EXISTS "uuid-ossp" SCHEMA public;
-- ADD "tablefunc" extension (if not already installed);
CREATE EXTENSION IF NOT EXISTS "tablefunc" SCHEMA public;

DO $$
DECLARE
    curr_usr_name NAME := (SELECT current_user);
BEGIN
    EXECUTE format('SELECT current_user') INTO curr_usr_name;
	-- SET ROLE curr_usr_name;
    RAISE NOTICE 'Current user: %', curr_usr_name;
	EXECUTE format('ALTER SCHEMA qgis_pkg OWNER TO %I;', curr_usr_name);
	EXECUTE format('GRANT EXECUTE ON ALL FUNCTIONS IN SCHEMA qgis_pkg TO %I;', curr_usr_name);
END $$;


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
minor_version  := 0;
minor_revision := 0;
code_name      := 'May breeze';
release_date   := '2024-10-29'::date;
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
RETURNS boolean AS $$
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
-- SELECT qgis_pkg.is_superuser('bstsai');
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
        AND table_name <> 'ade'
        AND table_name <> 'datatype'
        AND table_name <> 'database_srs'
        AND table_name <> 'codelist'
        AND table_name <> 'codelist_entry'
        AND table_name <> 'namespace'
        AND table_name <> 'objectclass'
  LOOP
   	EXECUTE format('TRUNCATE TABLE %I.%I CASCADE', cdb_schema, rec.table_name);
	-- This would suffice, if the tables were created using the IDENTITY clause.
	--EXECUTE format('TRUNCATE TABLE %I.%I RESTART IDENTITY CASCADE', cdb_schema, rec.table_name);
  END LOOP;

FOR rec IN 
    SELECT sequence_name FROM information_schema.sequences where sequence_schema = cdb_schema
		AND sequence_name <> 'ade_seq'
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

-- Example:
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
-- RAISE NOTICE 'sql: %', sql_statement;

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
-- SELECT qgis_pkg.add_user_to_qgis_pkg_usrgroup('postgres');
-- SELECT qgis_pkg.add_user_to_qgis_pkg_usrgroup('bstsai');


----------------------------------------------------------------
-- Create FUNCTION QGIS_PKG.REMOVE_USER_FROM_QGIS_PKG_USRGROUP
----------------------------------------------------------------
-- Creates the qgis schema for a user
DROP FUNCTION IF EXISTS    qgis_pkg.remove_user_from_qgis_pkg_usrgroup(varchar) CASCADE;
CREATE OR REPLACE FUNCTION qgis_pkg.remove_user_from_qgis_pkg_usrgroup(
INOUT user_name	varchar
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

-- Example:
-- SELECT qgis_pkg.remove_user_from_qgis_pkg_usrgroup('bstsai');
-- Check exisiting role names
-- SELECT rolname
-- FROM pg_roles
-- WHERE rolsuper = FALSE  -- Filters out superusers
-- AND rolinherit = TRUE   -- Filters out roles that do not inherit privileges
-- AND rolname = 'qgis_pkg_usergroup_citydb_v5';
-- Delete current user group
-- DROP ROLE qgis_pkg_usergroup_bstsai;


----------------------------------------------------------------
-- Create FUNCTION QGIS_PKG.LIST_QGIS_PKG_USRGROUP_MEMBERS
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
-- Create FUNCTION QGIS_PKG.LIST_QGIS_PKG_NON_USRGROUP_MEMBERS
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
		WHERE quote_ident(i.role_name) = quote_ident(qgis_pkg_usergroup_name)) AS foo
	ORDER BY foo.user_name ASC;

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
-- CREATE USER benson WITH PASSWORD 'b12345';
-- ALTER USER benson WITH SUPERUSER;


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
-- example
-- SELECT * FROM qgis_pkg.create_default_qgis_pkg_user('rw');


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
-- SELECT qgis_pkg.create_qgis_usr_schema_name('bstsai');
-- SELECT qgis_pkg.create_qgis_usr_schema_name('g.a@nl');


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
		EXISTS(SELECT * FROM information_schema.tables AS t WHERE t.table_schema = r.schema_name AND t.table_name = 'feature')
			AND
		EXISTS(SELECT * FROM information_schema.tables AS t WHERE t.table_schema = r.schema_name AND t.table_name = 'property')
			AND
		EXISTS(SELECT 1 FROM information_schema.tables AS t WHERE t.table_schema = r.schema_name AND t.table_name = 'objectclass')		
		  AND
		EXISTS(SELECT 1 FROM information_schema.tables AS t WHERE t.table_schema = r.schema_name AND t.table_name = 'datatype')	
			AND
		EXISTS(SELECT 1 FROM information_schema.tables AS t WHERE t.table_schema = r.schema_name AND t.table_name = 'namespace')	
			AND
		EXISTS(SELECT 1 FROM information_schema.tables AS t WHERE t.table_schema = r.schema_name AND t.table_name = 'geometry_data')	
			AND
		EXISTS(SELECT 1 FROM information_schema.tables AS t WHERE t.table_schema = r.schema_name AND t.table_name = 'appearance')
	THEN 
		cdb_schema := r.schema_name::varchar;
		is_empty := NULL;
		
		EXECUTE format('SELECT NOT EXISTS(SELECT 1 FROM %I.feature LIMIT 1)',cdb_schema) INTO is_empty;

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

-- Example:
-- SELECT a.* FROM qgis_pkg.list_cdb_schemas(only_non_empty:=FALSE) AS a;
-- SELECT a.* FROM qgis_pkg.list_cdb_schemas(only_non_empty:=TRUE) AS a;


----------------------------------------------------------------
-- Create FUNCTION QGIS_PKG.CREATE_QGIS_USR_SCHEMA
----------------------------------------------------------------
/* Creates the name of the schema for a certain user (prefixed: "qgis_(usr_name)_(cdb_schema)") */

DROP FUNCTION IF EXISTS qgis_pkg.create_qgis_usr_schema(varchar, varchar) CASCADE;
CREATE OR REPLACE FUNCTION qgis_pkg.create_qgis_usr_schema(
	usr_name varchar
)
RETURNS varchar
AS $$
DECLARE
	tb_names_array	varchar[] := ARRAY['extents'];
	tb_name 	varchar;
	usr_schema varchar;
	seq_name 	varchar;

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
	EXECUTE format('REVOKE SELECT ON TABLE qgis_pkg.classname_lookup FROM %I;', usr_name);
	EXECUTE format('REVOKE SELECT ON TABLE qgis_pkg.attribute_datatype_lookup FROM %I;', usr_name);
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
DROP TABLE IF EXISTS %I.feature_geometry_metadata CASCADE;
CREATE TABLE %I.feature_geometry_metadata (LIKE qgis_pkg.feature_geometry_metadata_template INCLUDING ALL);
ALTER TABLE %I.feature_geometry_metadata OWNER TO %I;

DROP TABLE IF EXISTS %I.feature_attribute_metadata CASCADE;
CREATE TABLE %I.feature_attribute_metadata (LIKE qgis_pkg.feature_attribute_metadata_template INCLUDING ALL);
ALTER TABLE %I.feature_attribute_metadata OWNER TO %I;

DROP TABLE IF EXISTS %I.layer_metadata CASCADE;
CREATE TABLE %I.layer_metadata (LIKE qgis_pkg.layer_metadata_template INCLUDING ALL);
ALTER TABLE %I.layer_metadata OWNER TO %I;

DROP TABLE IF EXISTS %I.extents CASCADE;
CREATE TABLE %I.extents (LIKE qgis_pkg.extents_template INCLUDING ALL);
ALTER TABLE %I.extents OWNER TO %I;
',
usr_schema, usr_schema, usr_schema, usr_name,
usr_schema, usr_schema, usr_schema, usr_name,
usr_schema, usr_schema, usr_schema, usr_name,
usr_schema, usr_schema, usr_schema, usr_name
);

-- Populate new tables
EXECUTE format('
INSERT INTO %I.extents SELECT * FROM qgis_pkg.extents_template ORDER BY id;
',
usr_schema
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

-- Delete if exists the previously installed entry in table qgis_pkg.usr_schema;
EXECUTE format('DELETE FROM qgis_pkg.usr_schema AS u WHERE u.usr_name = %L',usr_name);
-- Insert the newly installed user_schema in table qgis_pkg.usr_schema;
INSERT INTO qgis_pkg.usr_schema (usr_name, usr_schema, creation_date) VALUES
(usr_name, usr_schema, clock_timestamp());

-- Grant privileges to use your own usr_schema
EXECUTE format('GRANT USAGE, CREATE ON SCHEMA %I TO %I;', usr_schema, usr_name);
-- Grant privileges to access the qgis_pkg schema use functions in qgis_pkg
EXECUTE format('GRANT USAGE ON SCHEMA qgis_pkg TO %I;', usr_name);
-- Grant privileges to read from the following tables in qgis_pkg
EXECUTE format('GRANT SELECT ON TABLE qgis_pkg.classname_lookup TO %I;', usr_name);
EXECUTE format('GRANT SELECT ON TABLE qgis_pkg.attribute_datatype_lookup TO %I;', usr_name);

IF (usr_name = 'postgres') OR (qgis_pkg.is_superuser(usr_name) IS TRUE) THEN
	NULL;
	-- Do nothing, this is to avoid revoking privileges from yourself.
	-- It's anyway either postgres or a superuser being able to run this script.
ELSE
	-- DO NOT REVOKE privileges from (they are called also by user-level functions):
	-- qgis_pkg.is_superuser(varchar)
	-- qgis_pkg.list_qgis_pkg_usergroup_members()

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
COMMENT ON FUNCTION qgis_pkg.create_qgis_usr_schema(varchar) IS 'Creates the qgis schema for the provided user';
REVOKE EXECUTE ON FUNCTION qgis_pkg.create_qgis_usr_schema(varchar) FROM PUBLIC;
-- Example: 
--SELECT qgis_pkg.create_qgis_usr_schema('qgis_user_rw');


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
		-- EXECUTE format('GRANT ALL PRIVILEGES ON ALL TABLES IN SCHEMA citydb_pkg TO %I;', sql_priv_type, usr_name);


		-- Recursively iterate for each cdb_schema in database
		FOREACH sch_name IN ARRAY cdb_schemas_array LOOP
			EXECUTE format('GRANT USAGE, CREATE ON SCHEMA %I TO %I;', sch_name, usr_name);
			EXECUTE format('GRANT %s ON ALL TABLES IN SCHEMA %I TO %I;', sql_priv_type, sch_name, usr_name);
			EXECUTE format('GRANT ALL PRIVILEGES ON ALL SEQUENCES IN SCHEMA %I TO %I', sch_name, usr_name);

			IF priv_type = 'rw' THEN
				-- Added to ensure that also a rw user can clean up schema (via qgis_pkg.cleanup_schema(...))
				EXECUTE format('GRANT TRUNCATE ON ALL TABLES IN SCHEMA %I TO %I', sch_name, usr_name);
				RAISE NOTICE 'Granted TRUNCATE privileges to user "%" for tables in cdb_schema "%"', usr_name, sch_name; 
			END IF;

			RAISE NOTICE 'Granted "%" privileges to user "%" for cdb_schema "%"', priv_type, usr_name, sch_name; 		

			-- And finally add an index on column datatype of table cityobject_genericattrib.
			-- We need access to schema citydb_pkg, that has been granted before the loop
			-- The index is created only the very first time, then it won't be created again,
			-- no matter if another user is granted privileges.
			EXECUTE format('SELECT qgis_pkg.add_ga_indices(%L);', sch_name);

		END LOOP;

		-- Access/usage to qgis_pkg was granted at the moment of installing the usr_schema

		-- Grant usage to public
		EXECUTE format('GRANT USAGE ON SCHEMA public TO %I;', usr_name);
		EXECUTE format('GRANT %s ON ALL TABLES IN SCHEMA public TO %I;', sql_priv_type, usr_name);
		
		RAISE NOTICE 'Granted "%" privileges to user "%" for cdb_schema "%" in database "%"', priv_type, usr_name, sch_name, cdb_name; 


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
		EXECUTE format('SELECT qgis_pkg.add_ga_indices(%L);', cdb_schema);

		-- Access/usage to qgis_pkg was granted at the moment of installing the usr_schema
		
		-- Grant usage to public
		EXECUTE format('GRANT USAGE ON SCHEMA public TO %I;', usr_name);
		EXECUTE format('GRANT %s ON ALL TABLES IN SCHEMA public TO %I;', sql_priv_type, usr_name);

		RAISE NOTICE 'Granted "%" privileges to user "%" for cdb_schema "%" in database "%"', priv_type, usr_name, cdb_schema, cdb_name; 

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
		EXECUTE format('SELECT qgis_pkg.add_ga_indices(%L);', cdb_schema);
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

-- Example:
-- SELECT qgis_pkg.grant_qgis_usr_privileges('giorgio', 'ro', 'citydb')
-- SELECT qgis_pkg.grant_qgis_usr_privileges('giorgio', 'ro', NULL)

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

-- Example:
-- SELECT qgis_pkg.revoke_qgis_usr_privileges('giorgio', 'citydb')
-- SELECT qgis_pkg.revoke_qgis_usr_privileges('giorgio', NULL)


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
-- Create FUNCTION QGIS_PKG.OBJECTCLASS_ID_TO_ALIAS()
----------------------------------------------------------------
/*  The function returns the alias of the given objectclass_id */
DROP FUNCTION IF EXISTS qgis_pkg.objectclass_id_to_alias(integer);
CREATE OR REPLACE FUNCTION qgis_pkg.objectclass_id_to_alias(
	objectclass_id integer
) 
RETURNS varchar 
AS $$
DECLARE
	oc_alias varchar := NULL;
BEGIN
EXECUTE format ('SELECT oc_alias FROM qgis_pkg.classname_lookup WHERE oc_id = %s', objectclass_id) INTO oc_alias;	
IF oc_alias IS NULL THEN
	RAISE EXCEPTION 'Alias of objectclass_id % not found. Please make sure the feature of the objectclass_id can be instantiated!', objectclass_id;
END IF;
RETURN oc_alias;

EXCEPTION
	WHEN QUERY_CANCELED THEN
		RAISE EXCEPTION 'qgis_pkg.objectclass_id_to_alias: Error QUERY_CANCELED';
  WHEN OTHERS THEN
		RAISE EXCEPTION 'qgis_pkg.objectclass_id_to_alias: %', SQLERRM;
END;
$$ LANGUAGE plpgsql;
COMMENT ON FUNCTION qgis_pkg.objectclass_id_to_alias(integer) IS 'Return the alias name of the given objectclass_id';
REVOKE EXECUTE ON FUNCTION qgis_pkg.objectclass_id_to_alias(integer) FROM PUBLIC;


----------------------------------------------------------------
-- Create FUNCTION QGIS_PKG.CLASSNAME_TO_OBJECTCLASS_ID()
----------------------------------------------------------------
/*  The function looks up the id of the given classname in table objectclass */
DROP FUNCTION IF EXISTS qgis_pkg.classname_to_objectclass_id(varchar, text);
CREATE OR REPLACE FUNCTION qgis_pkg.classname_to_objectclass_id(
	cdb_schema varchar,
	classname text
) 
RETURNS integer 
AS $$
DECLARE
	qi_cdb_schema varchar := quote_ident(cdb_schema);
	sql_class_id text := NULL;
	class_id integer := NULL;
BEGIN
sql_class_id := format('
	SELECT id 
	FROM %I.objectclass
	WHERE classname = $1
', qi_cdb_schema);

EXECUTE sql_class_id INTO class_id USING classname;

IF class_id IS NULL THEN
	RAISE EXCEPTION 'Objectclass_id of the classname "%" not found. Please make sure to enter correct classname!', classname;
END IF;

RETURN class_id;

EXCEPTION
	WHEN QUERY_CANCELED THEN
		RAISE EXCEPTION 'qgis_pkg.classname_to_objectclass_id: Error QUERY_CANCELED';
  	WHEN OTHERS THEN
		RAISE EXCEPTION 'qgis_pkg.classname_to_objectclass_id: %', SQLERRM;
END;
$$ LANGUAGE plpgsql;
COMMENT ON FUNCTION qgis_pkg.classname_to_objectclass_id(varchar, text) IS 'Return the id of the given classname';
REVOKE EXECUTE ON FUNCTION qgis_pkg.classname_to_objectclass_id(varchar, text) FROM PUBLIC;
-- Example
-- SELECT * FROM qgis_pkg.classname_to_objectclass_id('citydb', 'Building');


----------------------------------------------------------------
-- Create FUNCTION QGIS_PKG.OBJECTCLASS_ID_TO_CLASSNAME
----------------------------------------------------------------
DROP FUNCTION IF EXISTS    qgis_pkg.objectclass_id_to_classname(varchar, integer) CASCADE;
CREATE OR REPLACE FUNCTION qgis_pkg.objectclass_id_to_classname(
	cdb_schema varchar,
	objectclass_id integer
)
RETURNS text
AS $$
DECLARE
	qi_cdb_schema varchar := quote_ident(cdb_schema);
	sql_classname text := NULL;
	classname text := NULL;
BEGIN
sql_classname := format('
	SELECT classname 
	FROM %I.objectclass
	WHERE id = %s
', qi_cdb_schema, objectclass_id);

EXECUTE sql_classname INTO classname;

IF classname IS NULL THEN
	RAISE EXCEPTION 'Name of the objectclass_id "%" not found. Please make sure to enter correct id number!', objectclass_id;
END IF;

RETURN classname;

EXCEPTION
	WHEN QUERY_CANCELED THEN
		RAISE EXCEPTION 'qgis_pkg.objectclass_id_to_classname(): Error QUERY_CANCELED';
  	WHEN OTHERS THEN 
		RAISE EXCEPTION 'qgis_pkg.objectclass_id_to_classname(): %', SQLERRM;
END;
$$ LANGUAGE plpgsql;
COMMENT ON FUNCTION qgis_pkg.objectclass_id_to_classname(varchar, integer) IS 'Return the classname of the given id';
REVOKE EXECUTE ON FUNCTION qgis_pkg.objectclass_id_to_classname(varchar, integer) FROM public;

-- Example
-- SELECT * FROM qgis_pkg.objectclass_id_to_classname('alderaan_v5', 901)


----------------------------------------------------------------
-- Create FUNCTION QGIS_PKG.DATATYPE_NAME_TO_TYPE_ID()
----------------------------------------------------------------
/*  The function looks up the id of the given classname in the default table objectclass in schema citydb */
DROP FUNCTION IF EXISTS qgis_pkg.datatype_name_to_type_id();
CREATE OR REPLACE FUNCTION qgis_pkg.datatype_name_to_type_id(
	cdb_schema varchar,
	datatype_name text
) 
RETURNS integer 
AS $$
DECLARE
	qi_cdb_schema varchar := quote_ident(cdb_schema);
	sql_datatype_id text := NULL;
	datatype_id integer := NULL;
BEGIN
sql_datatype_id := format('
SELECT id 
FROM %I.datatype
WHERE typename = $1
', qi_cdb_schema);

EXECUTE sql_datatype_id INTO datatype_id USING datatype_name;

IF datatype_id IS NULL THEN
	RAISE EXCEPTION 'Id of the datatype name "%" not found. Please make sure to enter correct datatype name!', datatype_name;
END IF;

RETURN datatype_id;

EXCEPTION
	WHEN QUERY_CANCELED THEN
		RAISE EXCEPTION 'qgis_pkg.datatype_name_to_type_id: Error QUERY_CANCELED';
  	WHEN OTHERS THEN
		RAISE EXCEPTION 'qgis_pkg.datatype_name_to_type_id: %', SQLERRM;
END;
$$ LANGUAGE plpgsql;
COMMENT ON FUNCTION qgis_pkg.datatype_name_to_type_id(varchar, text) IS 'Return the id of the given datatype name';
REVOKE EXECUTE ON FUNCTION qgis_pkg.datatype_name_to_type_id(varchar, text) FROM PUBLIC;


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
CREATE OR REPLACE VIEW ',qi_usr_schema,'.',qi_layer_name,' AS 
');

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
CREATE MATERIALIZED VIEW         ',qi_usr_schema,'.',qi_gv_name,' AS
');

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
DROP FUNCTION IF EXISTS    qgis_pkg.generate_sql_matview_footer(varchar,varchar,varchar) CASCADE;
CREATE OR REPLACE FUNCTION qgis_pkg.generate_sql_matview_footer(
	qi_usr_name 	varchar,
	qi_usr_schema 	varchar,
	qi_gv_name	 	varchar
)
RETURNS text
AS $$
DECLARE
gv_name CONSTANT varchar := trim(both '"' from qi_gv_name);
gv_f_idx_name CONSTANT varchar := LOWER(quote_ident(concat(gv_name,'_f_id_idx')));
gv_fo_idx_name CONSTANT varchar := LOWER(quote_ident(concat(gv_name,'_o_id_idx')));
gv_spx_name CONSTANT varchar := LOWER(quote_ident(concat(gv_name,'_geom_spx')));
sql_statement text;

BEGIN
sql_statement := concat('
CREATE INDEX ',gv_f_idx_name,' ON ',qi_usr_schema,'.',qi_gv_name,' (f_id);
CREATE INDEX ',gv_fo_idx_name,' ON ',qi_usr_schema,'.',qi_gv_name,' (f_object_id);
CREATE INDEX ',gv_spx_name,' ON ',qi_usr_schema,'.',qi_gv_name,' USING gist (geom);
ALTER TABLE ',qi_usr_schema,'.',qi_gv_name,' OWNER TO ',qi_usr_name,';
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
REVOKE EXECUTE ON FUNCTION qgis_pkg.generate_sql_matview_footer(varchar,varchar,varchar) FROM public;


----------------------------------------------------------------
-- Create FUNCTION QGIS_PKG.COMPUTE_CDB_SCHEMA_EXTENTS
----------------------------------------------------------------
DROP FUNCTION IF EXISTS    qgis_pkg.compute_cdb_schema_extents(varchar, boolean);
CREATE OR REPLACE FUNCTION qgis_pkg.compute_cdb_schema_extents(
cdb_schema 		varchar,
is_geographic	boolean DEFAULT FALSE  -- TRUE is EPSG uses long-lat, FALSE if is projected (Default)
-- The polygon will have its coordinated approximated to the 6th decimal position
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

EXECUTE format('SELECT ST_Extent(envelope) FROM %I.feature AS f', cdb_schema) INTO cdb_extents;


IF cdb_extents IS NULL THEN
	is_geom_null := TRUE;
ELSE
	is_geom_null := FALSE;

	-- IF is_geographic IS TRUE THEN
	-- 	x_min        := round(ST_Xmin(cdb_extents)::numeric, geog_coords_prec);
	-- 	x_max        := round(ST_Xmax(cdb_extents)::numeric, geog_coords_prec);
	-- 	y_min        := round(ST_Ymin(cdb_extents)::numeric, geog_coords_prec);
	-- 	y_max        := round(ST_Ymax(cdb_extents)::numeric, geog_coords_prec);
	-- ELSE
	-- 	x_min        :=   floor(ST_Xmin(cdb_extents))::numeric;
	-- 	x_max        := ceiling(ST_Xmax(cdb_extents))::numeric;
	-- 	y_min        :=   floor(ST_Ymin(cdb_extents))::numeric;
	-- 	y_max        := ceiling(ST_Ymax(cdb_extents))::numeric;
	-- END IF;

	-- Since with compount EPSG codes is it not alwayes possible to get a correct answer (e.g. in QGIS),
	-- we simply ignore the is_geographic.

	x_min        := round(ST_Xmin(cdb_extents)::numeric, geog_coords_prec);
	x_max        := round(ST_Xmax(cdb_extents)::numeric, geog_coords_prec);
	y_min        := round(ST_Ymin(cdb_extents)::numeric, geog_coords_prec);
	y_max        := round(ST_Ymax(cdb_extents)::numeric, geog_coords_prec);

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

-- Example
-- SELECT * FROM qgis_pkg.compute_cdb_schema_extents('rh_v5');

----------------------------------------------------------------
-- Create FUNCTION QGIS_PKG.UPSERT_EXTENTS
----------------------------------------------------------------
DROP FUNCTION IF EXISTS    qgis_pkg.upsert_extents(varchar, varchar, varchar, geometry, boolean);
CREATE OR REPLACE FUNCTION qgis_pkg.upsert_extents(
	usr_schema varchar,
	cdb_schema varchar,
	cdb_bbox_type varchar DEFAULT 'db_schema',
	cdb_envelope geometry DEFAULT NULL,
	is_geographic boolean DEFAULT FALSE)
RETURNS integer
AS $$
DECLARE
	cdb_bbox_type_array CONSTANT varchar[] := ARRAY['db_schema', 'm_view', 'qgis']; -- default, usr_sql_entered, qgis_gui_entered
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

	WHEN cdb_bbox_type IN ('m_view', 'qgis') THEN

		IF cdb_bbox_type = 'm_view' THEN
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
			RAISE EXCEPTION 'Error, please provide a valid cdb_envelope';
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

-- create view to visualize the extent in QGIS
EXECUTE format('CREATE OR REPLACE VIEW %I.EXT_%I_%I AS SELECT 1 AS id, %L::geometry AS geom', usr_schema, cdb_schema, cdb_bbox_type, cdb_envelope);

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
-- SELECT qgis_pkg.generate_mview_bbox_poly('vienna_v5', ARRAY[2739, 340810, 3890, 341800], TRUE);
-- SELECT qgis_pkg.generate_mview_bbox_poly('vienna_v5', ARRAY[2739, 340810, 3890, 341800], FALSE);


/* --- TEMPLATE FOR ADDITIONAL FUNCTIONS
----------------------------------------------------------------
-- Create FUNCTION QGIS_PKG.XX_FUNCNAME_XX
----------------------------------------------------------------
A short description of what it does
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
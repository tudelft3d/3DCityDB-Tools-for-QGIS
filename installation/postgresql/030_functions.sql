-- ***********************************************************************
--
--      QGIS Package for the CityGML 3D City Database (for PostgreSQL)
--
--
--                        Copyright 2022
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
-- This script installs a set of functions into the qgis_pkg schema, such as:
--
-- qgis_pkg.qgis_pkg_version()
-- qgis_pkg.list_qgis_pkg_usrgroup_members()
-- qgis_pkg.list_cdb_schemas()
-- qgis_pkg.list_usr_schemas()
-- qgis_pkg.grant_qgis_usr_privileges(...)
-- qgis_pkg.revoke_qgis_usr_privileges(...)
-- qgis_pkg.create_qgis_usr_schema_name(...)
-- qgis_pkg.create_qgis_usr_schema(...)
-- qgis_pkg.generate_mview_bbox_poly(...)
-- qgis_pkg.support_for_schema(...)
-- qgis_pkg.view_counter(...)
-- qgis_pkg.add_ga_indices(...)
-- qgis_pkg.compute_schema_extents(...)
-- qgis_pkg.upsert_extents(...)
-- qgis_pkg.st_3darea_poly(...)
-- qgis_pkg.st_snap_poly_to_grid(...)
-- qgis_pkg.generate_sql_matview_header(...)
-- qgis_pkg.generate_sql_matview_footer(...)
-- qgis_pkg.generate_sql_view_header(...)
-- qgis_pkg.generate_sql_matview_else(...)
-- qgis_pkg.generate_sql_triggers(...)
--
-- ***********************************************************************

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
minor_version  := 6;
minor_revision := 2;
code_name      := 'May tulip';
release_date   := '2022-05-10'::date;
version        := concat(major_version,'.',minor_version,'.',minor_revision);
full_version   := concat(major_version,'.',minor_version,'.',minor_revision,' "',code_name,'", released on ',release_date);

RETURN NEXT;

EXCEPTION
	WHEN QUERY_CANCELED THEN
		RAISE EXCEPTION 'qgis_pkg.qgis_pkg_version(): Error QUERY_CANCELED';
  WHEN OTHERS THEN 
		RAISE NOTICE 'qgis_pkg.qgis_pkg_version(): %', SQLERRM;
END;
$$ LANGUAGE plpgsql;
COMMENT ON FUNCTION qgis_pkg.qgis_pkg_version() IS 'Returns the version of the QGIS Package for the 3DCityDB';

-- Example:
-- SELECT version, major_version, minor_version, minor_revision FROM qgis_pkg.qgis_pkg_version();

----------------------------------------------------------------
-- Create FUNCTION QGIS_PKG.LIST_QGIS_PKG_URSGROUP_MEMBERS
----------------------------------------------------------------
-- Lists all users that are part of the qgis_pkg_usrgroup role (group)
DROP FUNCTION IF EXISTS    qgis_pkg.list_qgis_pkg_usrgroup_members() CASCADE;
CREATE OR REPLACE FUNCTION qgis_pkg.list_qgis_pkg_usrgroup_members()
RETURNS 
TABLE (
usr_name varchar
)
AS $$
DECLARE
qgis_pkg_group_name CONSTANT varchar := 'qgis_pkg_usrgroup'; 
cdb_name 			CONSTANT varchar := current_database()::varchar;
r RECORD;

BEGIN

RETURN QUERY
	SELECT i.grantee::varchar AS usrname
	FROM information_schema.applicable_roles AS i
	WHERE i.role_name = qgis_pkg_group_name
	ORDER BY i.grantee ASC;

EXCEPTION
	WHEN QUERY_CANCELED THEN
		RAISE EXCEPTION 'qgis_pkg.list_qgis_pkg_usrgroup_members(): Error QUERY_CANCELED';
  WHEN OTHERS THEN 
		RAISE NOTICE 'qgis_pkg.list_qgis_pkg_usrgroup_members(): %', SQLERRM;
END;
$$ LANGUAGE plpgsql;
COMMENT ON FUNCTION qgis_pkg.list_qgis_pkg_usrgroup_members() IS 'List all database users that are part of the role (group) "qgis_pkg_usrgroup"';

-- Example:
-- SELECT usr_name FROM qgis_pkg.list_qgis_pkg_usrgroup_members();
-- SELECT array_agg(s.usr_name) FROM qgis_pkg.list_qgis_pkg_usrgroup_members() AS s;

----------------------------------------------------------------
-- Create FUNCTION QGIS_PKG.LIST_CDB_SCHEMAS
----------------------------------------------------------------
-- List all schemas containing citydb tables in the current database and picks only the non-empty ones
DROP FUNCTION IF EXISTS    qgis_pkg.list_cdb_schemas(boolean) CASCADE;
CREATE OR REPLACE FUNCTION qgis_pkg.list_cdb_schemas(
only_non_empty boolean DEFAULT FALSE)
RETURNS TABLE (
cdb_schema 		varchar
)
AS $$
DECLARE
cdb_name CONSTANT varchar := current_database()::varchar;
co_number integer;
r RECORD;
BEGIN

FOR r IN 
	SELECT i.schema_name 
	FROM information_schema.schemata AS i
	WHERE 
		i.catalog_name = cdb_name
		AND i.catalog_name NOT LIKE 'pg_%'
		AND i.catalog_name <> 'citydb_pkg'
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
		IF only_non_empty IS NULL OR only_non_empty IS FALSE THEN
			cdb_schema := r.schema_name::varchar;
			RETURN NEXT;		
		ELSE -- now check that it is not empty
			co_number := NULL;
			EXECUTE format('SELECT count(id) FROM %I.cityobject', r.schema_name) INTO co_number;
			IF co_number > 0 THEN
				cdb_schema := r.schema_name::varchar;
				RETURN NEXT;
			END IF;
		END IF;
	END IF;
END LOOP;

EXCEPTION
	WHEN QUERY_CANCELED THEN
		RAISE EXCEPTION 'qgis_pkg.list_cdb_schemas(): Error QUERY_CANCELED';
  WHEN OTHERS THEN 
		RAISE NOTICE 'qgis_pkg.list_cdb_schemas(): %', SQLERRM;
END;
$$ LANGUAGE plpgsql;
COMMENT ON FUNCTION qgis_pkg.list_cdb_schemas(boolean) IS 'List all schemas containing citydb tables in the current database, and optionally only the non-empty ones';

-- Example:
--SELECT cdb_schema FROM qgis_pkg.list_cdb_schemas();
--SELECT array_agg(cdb_schema) FROM qgis_pkg.list_cdb_schemas();
--SELECT array_agg(cdb_schema) FROM qgis_pkg.list_cdb_schemas(TRUE);

----------------------------------------------------------------
-- Create FUNCTION QGIS_PKG.TABLE_IS_EMPTY
----------------------------------------------------------------
-- Check if a given table of a given schema is eempty.
DROP FUNCTION IF EXISTS    qgis_pkg.table_is_empty(varchar,varchar) CASCADE;
CREATE OR REPLACE FUNCTION qgis_pkg.table_is_empty(
	schema_n varchar,
	table_n	varchar)
RETURNS bool
AS $$
DECLARE
empty_t 	bool := false;

BEGIN

EXECUTE FORMAT('SELECT NOT EXISTS(SELECT 1 FROM %I.%I)',schema_n,table_n) INTO empty_t;
RETURN empty_t;

EXCEPTION
	WHEN QUERY_CANCELED THEN
		RAISE EXCEPTION 'qgis_pkg.table_is_empty(): Error QUERY_CANCELED';
  WHEN OTHERS THEN 
		RAISE NOTICE 'qgis_pkg.table_is_empty(): %', SQLERRM;
END;
$$ LANGUAGE plpgsql;
COMMENT ON FUNCTION qgis_pkg.table_is_empty(varchar,varchar) IS 'Checks if a table of a schema is empty.';


----------------------------------------------------------------
-- Create FUNCTION QGIS_PKG.LIST_USR_SCHEMAS
----------------------------------------------------------------
-- List all usr schemas of qgis pkg users in the current database
DROP FUNCTION IF EXISTS    qgis_pkg.list_usr_schemas() CASCADE;
CREATE OR REPLACE FUNCTION qgis_pkg.list_usr_schemas()
RETURNS TABLE (
usr_schema varchar
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
		--EXISTS(SELECT version FROM citydb_pkg.qgis_pkg_version())  -- checks that the qgis_pkg is installed in this database
			--AND
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
		RAISE NOTICE 'qgis_pkg.list_usr_schemas(): %', SQLERRM;
END;
$$ LANGUAGE plpgsql;
COMMENT ON FUNCTION qgis_pkg.list_usr_schemas() IS 'List all existing usr_schemas generated by the QGIS package in the current database';

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
priv_type		varchar,   	-- must be either 'ro' or 'rw'
cdb_schema		varchar DEFAULT NULL	-- NULL = all existing cdb_schemas, otherwise to the given schema (e.g. 'citydb').
)
RETURNS void
AS $$
DECLARE
cdb_name 			CONSTANT varchar := current_database()::varchar;
priv_types_array 	CONSTANT varchar[] :=  ARRAY['ro', 'rw'];
cdb_schemas_array 	CONSTANT varchar[] := (SELECT array_agg(s.cdb_schema) FROM qgis_pkg.list_cdb_schemas() AS s); 
sch_name 			varchar;
sql_priv_type 		varchar;

BEGIN

-- Check that the user exists
IF usr_name IS NULL OR NOT EXISTS(SELECT 1 FROM information_schema.enabled_roles AS i WHERE i.role_name::varchar = usr_name) THEN
	RAISE EXCEPTION 'usr_name is invalid. It must be an existing database user';
END IF;

-- Check that the privileges type is correct.
IF (priv_type IS NULL) OR (NOT priv_type = ANY(priv_types_array)) THEN
	RAISE EXCEPTION 'Privileges type not valid. It must be either ''ro'' or ''rw''';
ELSE
	IF priv_type = 'rw' THEN sql_priv_type := 'ALL';
	ELSE sql_priv_type := 'SELECT';
	END IF;
END IF;

IF cdb_schema IS NULL THEN

	EXECUTE format('GRANT CONNECT, TEMP ON DATABASE %I TO %I;', cdb_name, usr_name);
	RAISE NOTICE 'Granted access to database "%" to user "%"', cdb_name, usr_name;
	
	-- Recurvively iterate for each cdb_schema in database
	FOREACH sch_name IN ARRAY cdb_schemas_array LOOP
		EXECUTE format('GRANT USAGE ON SCHEMA %I TO %I;', sch_name, usr_name);
		--EXECUTE format('GRANT USAGE, CREATE ON SCHEMA %I TO %I;', sch_name, usr_name);
		EXECUTE format('GRANT %s ON ALL TABLES IN SCHEMA %I TO %I;', sql_priv_type, sch_name, usr_name);
		IF priv_type = 'rw' THEN
			EXECUTE format('GRANT ALL PRIVILEGES ON ALL SEQUENCES IN SCHEMA %I TO %I', sch_name, usr_name);
		END IF;		
		RAISE NOTICE 'Granted "%" privileges to user "%" for schema "%"', priv_type, usr_name, sch_name; 		
	END LOOP;

	EXECUTE format('GRANT USAGE ON SCHEMA citydb_pkg TO %I;', usr_name);
	EXECUTE format('GRANT %s ON ALL TABLES IN SCHEMA citydb_pkg TO %I;', sql_priv_type, usr_name);
	EXECUTE format('GRANT USAGE ON SCHEMA public TO %I;', usr_name);
	EXECUTE format('GRANT %s ON ALL TABLES IN SCHEMA public TO %I;', sql_priv_type, usr_name);
	EXECUTE format('GRANT qgis_pkg_usrgroup TO %I;', usr_name);
	RAISE NOTICE 'Added user "%" to group "qgis_pkg_usrgroup"', usr_name;		

ELSIF cdb_schema = ANY(cdb_schemas_array) THEN 

	-- Grant privileges only for the selected cdb_schema.
	EXECUTE format('GRANT CONNECT, TEMP ON DATABASE %I TO %I;', cdb_name, usr_name);
	EXECUTE format('GRANT USAGE ON SCHEMA %I TO %I;', cdb_schema, usr_name);
	--EXECUTE format('GRANT USAGE, CREATE ON SCHEMA %I TO %I;', cdb_schema, usr_name);
	EXECUTE format('GRANT %s ON ALL TABLES IN SCHEMA %I TO %I;', sql_priv_type, cdb_schema, usr_name);
	EXECUTE format('GRANT USAGE ON SCHEMA citydb_pkg TO %I;', usr_name);
	EXECUTE format('GRANT %s ON ALL TABLES IN SCHEMA citydb_pkg TO %I;', sql_priv_type, usr_name);
	EXECUTE format('GRANT USAGE ON SCHEMA public TO %I;', usr_name);
	EXECUTE format('GRANT %s ON ALL TABLES IN SCHEMA public TO %I;', sql_priv_type, usr_name);
	IF priv_type = 'rw' THEN
		EXECUTE format('GRANT ALL PRIVILEGES ON ALL SEQUENCES IN SCHEMA %I TO %I', cdb_schema, usr_name);
	END IF;	
	RAISE NOTICE 'Granted "%" privileges to user "%" for schema "%" in database "%"', priv_type, usr_name, cdb_schema, cdb_name; 
	EXECUTE format('GRANT qgis_pkg_usrgroup TO %I;', usr_name);
	RAISE NOTICE 'Added user "%" to group "qgis_pkg_usrgroup"', usr_name;
	
ELSE
	RAISE EXCEPTION 'cdb_schema is invalid, it must correspond to an existing citydb schema';
END IF;

EXCEPTION
	WHEN QUERY_CANCELED THEN
		RAISE EXCEPTION 'qgis_pkg.grant_qgis_usr_privileges(): Error QUERY_CANCELED';
  WHEN OTHERS THEN 
		RAISE NOTICE 'qgis_pkg.grant_qgis_usr_privileges(): %', SQLERRM;
END;
$$ LANGUAGE plpgsql;
COMMENT ON FUNCTION qgis_pkg.grant_qgis_usr_privileges(varchar, varchar, varchar) IS 'Grants access to the current database and read-only / read-write privileges to a user for a citydb schema';


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
cdb_schemas_array	CONSTANT varchar[] := (SELECT array_agg(s.cdb_schema) FROM qgis_pkg.list_cdb_schemas() AS s); 
sch_name varchar;
r RECORD;

BEGIN

-- Check that the user exists
IF (usr_name IS NULL) OR (NOT EXISTS(SELECT 1 FROM information_schema.enabled_roles AS i WHERE i.role_name = usr_name)) THEN
	RAISE EXCEPTION 'User name is invalid, must correspond to an existing database user';
END IF;

IF cdb_schema IS NULL THEN
	-- Recursively iterate for each cdb_schema in database
	FOREACH sch_name IN ARRAY cdb_schemas_array LOOP

		PERFORM qgis_pkg.revoke_qgis_usr_privileges(
			usr_name	:= usr_name,
			cdb_schema  := sch_name
			);
	END LOOP;
	
	-- And finally revoke connection to the database and membership in the group
	EXECUTE format('REVOKE ALL PRIVILEGES ON ALL TABLES IN SCHEMA citydb_pkg FROM %I;', usr_name);
	EXECUTE format('REVOKE USAGE ON SCHEMA citydb_pkg FROM %I;', usr_name);
	EXECUTE format('REVOKE ALL PRIVILEGES ON ALL TABLES IN SCHEMA public FROM %I;', usr_name);
	EXECUTE format('REVOKE USAGE ON SCHEMA public FROM %I;', usr_name);	
	EXECUTE format('REVOKE CONNECT, TEMP ON DATABASE %I FROM %I;', cdb_name, usr_name);
	EXECUTE format('REVOKE qgis_pkg_usrgroup FROM %I;', usr_name);
	RAISE NOTICE 'Revoked access to database "%" and membership in group "qgis_pkg_usrgroup" from user "%"', cdb_name, usr_name;

ELSIF cdb_schema = ANY(cdb_schemas_array) THEN 

	-- Grant privileges only for the selected cdb_schema.
	EXECUTE format('REVOKE ALL PRIVILEGES ON ALL SEQUENCES IN SCHEMA %I FROM %I;', cdb_schema, usr_name);
	EXECUTE format('REVOKE ALL PRIVILEGES ON ALL TABLES IN SCHEMA %I FROM %I;', cdb_schema, usr_name);
	EXECUTE format('REVOKE ALL PRIVILEGES ON SCHEMA %I FROM %I;', cdb_schema, usr_name);
	RAISE NOTICE 'Revoked all privileges on citydb schema "%" from user "%" in database "%"', cdb_schema, usr_name, cdb_name; 

ELSE
	RAISE EXCEPTION 'cdb_schema is invalid, it must correspond to an existing citydb schema';
END IF;

EXCEPTION
	WHEN QUERY_CANCELED THEN
		RAISE EXCEPTION 'qgis_pkg.revoke_qgis_usr_privileges(): Error QUERY_CANCELED';
  WHEN OTHERS THEN 
		RAISE NOTICE 'qgis_pkg.revoke_qgis_usr_privileges(): %', SQLERRM;
END;
$$ LANGUAGE plpgsql;
COMMENT ON FUNCTION qgis_pkg.revoke_qgis_usr_privileges(varchar, varchar) IS 'Revoke privileges from a user for a/all citydb schema(s) in the current database';

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
		RAISE NOTICE 'qgis_pkg.create_qgis_usr_schema_name(): %', SQLERRM;
END;
$$ LANGUAGE plpgsql;
COMMENT ON FUNCTION qgis_pkg.create_qgis_usr_schema_name(varchar) IS 'Creates the qgis schema for the provided user';

--Example (works also with "crazy" user names using special (but legal) characters:
--SELECT qgis_pkg.create_qgis_usr_schema_name('giorgio');
--SELECT qgis_pkg.create_qgis_usr_schema_name('giorgio@tudelft.nl');

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
tb_names_array	varchar[] := ARRAY['codelist', 'codelist_value', 'enumeration', 'enumeration_value', 'extents'];
tb_name 	varchar;
usr_schema	varchar;
seq_name	varchar;

BEGIN
IF usr_name IS NULL OR NOT EXISTS(SELECT 1 FROM information_schema.enabled_roles AS i WHERE i.role_name::varchar = usr_name) THEN
	RAISE EXCEPTION 'usr_name is invalid. It must be an existing database user AND belong to the role (group) "qgis_pkg_usrgroup"';
END IF;

usr_schema := qgis_pkg.create_qgis_usr_schema_name(usr_name);

RAISE NOTICE 'Creating usr_schema "%" for user "%"', usr_schema, usr_name;

-- Revoke privileges from qgis_pkg schema if any.
EXECUTE format('REVOKE EXECUTE ON ALL FUNCTIONS IN SCHEMA qgis_pkg FROM %I;',usr_name);
EXECUTE format('REVOKE USAGE ON SCHEMA qgis_pkg FROM %I;', usr_name);

-- This will work till there are not too many layers (over 500).
-- Otherwise first: delete all layers for all cdb_schemas, THEN drop schema
EXECUTE format('DROP SCHEMA IF EXISTS %I CASCADE', usr_schema);
-------------------------------

EXECUTE format('DELETE FROM qgis_pkg.usr_schema WHERE usr_schema = %L', usr_schema);

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
',
usr_schema,usr_schema,usr_schema,usr_name,
usr_schema,usr_schema,usr_schema,usr_name,
usr_schema,usr_schema,usr_schema,usr_name,
usr_schema,usr_schema,usr_schema,usr_name,
usr_schema,usr_schema,usr_schema,usr_name,
usr_schema,usr_schema,usr_schema,usr_name
);

-- Populate new tables
EXECUTE format('
INSERT INTO %I.extents SELECT * FROM qgis_pkg.extents_template ORDER BY id;
INSERT INTO %I.enumeration SELECT * FROM qgis_pkg.enumeration_template ORDER BY id;
INSERT INTO %I.enumeration_value SELECT * FROM qgis_pkg.enumeration_value_template ORDER BY id;
INSERT INTO %I.codelist SELECT * FROM qgis_pkg.codelist_template ORDER BY id;
INSERT INTO %I.codelist_value SELECT * FROM qgis_pkg.codelist_value_template ORDER BY id;
',
usr_schema,usr_schema,usr_schema,usr_schema,usr_schema
);

-- Refresh/Update the associated sequence values
FOREACH tb_name IN ARRAY tb_names_array LOOP
	seq_name := concat(quote_ident(usr_schema),'.',tb_name,'_id_seq');
	RAISE NOTICE 'seq_name %', seq_name;
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

-- Grant privileges to use functions in qgis_pkg
EXECUTE format('GRANT USAGE, CREATE ON SCHEMA %I TO %I;', usr_schema, usr_name);
EXECUTE format('GRANT USAGE ON SCHEMA qgis_pkg TO %I;', usr_name);
EXECUTE format('GRANT EXECUTE ON ALL FUNCTIONS IN SCHEMA qgis_pkg TO %I;',usr_name);
EXECUTE format('REVOKE EXECUTE ON FUNCTION qgis_pkg.create_qgis_usr_schema(varchar) FROM %I;',usr_name);
EXECUTE format('REVOKE EXECUTE ON FUNCTION qgis_pkg.grant_qgis_usr_privileges(varchar, varchar, varchar) FROM %I;',usr_name);
EXECUTE format('REVOKE EXECUTE ON FUNCTION qgis_pkg.revoke_qgis_usr_privileges(varchar, varchar) FROM %I;',usr_name);

RETURN usr_schema;

EXCEPTION
	WHEN QUERY_CANCELED THEN
		RAISE EXCEPTION 'qgis_pkg.create_qgis_usr_schema(): Error QUERY_CANCELED';
	WHEN OTHERS THEN 
		RAISE NOTICE 'qgis_pkg.create_qgis_usr_schema(): %', SQLERRM;
END;
$$ LANGUAGE plpgsql;
COMMENT ON FUNCTION qgis_pkg.create_qgis_usr_schema(varchar) IS 'Creates the qgis schema for a user';

-- Example: 
--SELECT qgis_pkg.create_qgis_usr_schema('qgis_user_rw');

----------------------------------------------------------------
-- Create FUNCTION QGIS_PKG.GENERATE_MVIEW_BBOX_POLY
----------------------------------------------------------------
-- Created a 2D polygon (and adds the SRID) from an array containing the bbox of the extents
DROP FUNCTION IF EXISTS    qgis_pkg.generate_mview_bbox_poly(numeric[]) CASCADE;
CREATE OR REPLACE FUNCTION qgis_pkg.generate_mview_bbox_poly(
bbox_corners_array numeric[]    -- To be passed as 'ARRAY[1.1,2.2,3.3,4.4]' 
)
RETURNS geometry AS $$
DECLARE
srid_id integer;
x_min numeric;
y_min numeric;
x_max numeric;
y_max numeric;
mview_bbox_poly geometry(Polygon);

BEGIN

IF bbox_corners_array IS NULL THEN
	mview_bbox_poly := NULL;
ELSIF array_position(bbox_corners_array, NULL) IS NOT NULL THEN
	RAISE EXCEPTION 'Array with corner coordinates is invalid and contains at least a null value';
ELSE
	EXECUTE 'SELECT srid FROM citydb.database_srs LIMIT 1' INTO srid_id;
	x_min :=   floor(bbox_corners_array[1]);
	y_min :=   floor(bbox_corners_array[2]);
	x_max := ceiling(bbox_corners_array[3]);
	y_max := ceiling(bbox_corners_array[4]);
	mview_bbox_poly := ST_MakeEnvelope(x_min, y_min, x_max, y_max, srid_id);
	--RAISE NOTICE 'Polygon is: %', ST_AsEWKT(mview_bbox_poly);
END IF;

RETURN mview_bbox_poly;

EXCEPTION
	WHEN QUERY_CANCELED THEN
		RAISE EXCEPTION 'qgis_pkg.generate_mview_bbox_poly(): Error QUERY_CANCELED';
	WHEN OTHERS THEN
		RAISE EXCEPTION 'qgis_pkg.generate_mview_bbox_poly(): %', SQLERRM;
END;
$$ LANGUAGE plpgsql;
COMMENT ON FUNCTION qgis_pkg.generate_mview_bbox_poly(numeric[]) IS 'Create polygon of mview bbox';

-- Example:
--SELECT qgis_pkg.generate_mview_bbox_poly(bbox_corners_array := ARRAY[220177, 481471, 220755, 482133]);
--SELECT qgis_pkg.generate_mview_bbox_poly(bbox_corners_array := '{220177, 481471, 220755, 482133}');

----------------------------------------------------------------
-- Create FUNCTION QGIS_PKG.SUPPORT_FOR_SCHEMA
----------------------------------------------------------------
-- Returns True if qgis_pkg schema supports the input schema.
-- In pratice it searches the schema for view names starting with
-- the input schema name.
DROP FUNCTION IF EXISTS    qgis_pkg.support_for_schema(varchar,varchar) CASCADE;
CREATE OR REPLACE FUNCTION qgis_pkg.support_for_schema(
usr_schema varchar,
cdb_schema varchar
)
RETURNS boolean
AS $$
DECLARE

BEGIN

PERFORM t.table_name
	FROM information_schema.tables AS t
    WHERE t.table_schema = usr_schema
	AND t.table_type = 'VIEW'
	AND t.table_name LIKE cdb_schema || '%'; 
	-- Don't use FORMAT, something happens with
	-- the variable FOUND assignment (many false positives)

RETURN FOUND;

EXCEPTION
	WHEN QUERY_CANCELED THEN
		RAISE EXCEPTION 'qgis_pkg.support_for_schema(): Error QUERY_CANCELED';
  WHEN OTHERS THEN 
		RAISE NOTICE 'qgis_pkg.support_for_schema(): %', SQLERRM;
END;
$$ LANGUAGE plpgsql;
COMMENT ON FUNCTION qgis_pkg.support_for_schema(varchar,varchar) IS 'Searches for cdb_schema name into the view names of the usr_schema to determine if it supports the input cdb_schema.';

----------------------------------------------------------------
-- Create FUNCTION QGIS_PKG.VIEW_COUNTER
----------------------------------------------------------------
-- Counts records in the selected materialized view
-- This function can be run providing only the name of the view,
-- OR, alternatively, also the extents.
DROP FUNCTION IF EXISTS    qgis_pkg.view_counter(varchar, varchar, varchar) CASCADE;
CREATE OR REPLACE FUNCTION qgis_pkg.view_counter(
usr_schema	varchar,
mview_name	varchar, 				-- Materialised view name
extents		varchar DEFAULT NULL	-- PostGIS polygon as ST_MakeEnvelope(229234, 476749, 230334, 479932)
)
RETURNS integer
AS $$
DECLARE
counter		integer := 0;
db_srid		integer;
query_geom	geometry(Polygon);
query_bbox	box2d;

BEGIN
IF EXISTS(SELECT mv.matviewname FROM pg_matviews AS mv WHERE mv.schemaname = usr_schema AND mv.ispopulated IS TRUE) THEN
	IF extents IS NULL THEN
		EXECUTE format('SELECT count(co_id) FROM %I.%I', usr_schema, mview_name)
			INTO counter;
	ELSE
		db_srid := (SELECT srid FROM citydb.database_srs LIMIT 1);
		-- Create the geometry, but some more checks are needed if the srid is different
		query_geom := ST_GeomFromText(extents,db_srid);
		query_bbox := ST_Extent(query_geom);
		-- Actually, if for any reason the user is defining a bbox in another srid, we must transform
		-- it to the db_srid_it
		-- ST_Transform or something similar.
		-- Ideally, this check is carried out in QGIS and then bbox passed to the function is already in the same srid.

		EXECUTE FORMAT('SELECT count(t.co_id) FROM %I.%I t WHERE $1 && t.geom',
			usr_schema, mview_name, query_bbox) USING query_bbox INTO counter;
	END IF;
ELSE
	RAISE EXCEPTION 'View "%"."%" does not exist', usr_schema, mview_name;	
END IF;
RETURN counter;
EXCEPTION
	WHEN QUERY_CANCELED THEN
		RAISE EXCEPTION 'qgis_pkg.view_counter(): Error QUERY_CANCELED';
  WHEN OTHERS THEN 
		RAISE NOTICE 'qgis_pkg.view_counter(): %', SQLERRM;
END;
$$ LANGUAGE plpgsql;
COMMENT ON FUNCTION qgis_pkg.view_counter(varchar, varchar, varchar) IS 'Counts records in the selected materialized view';

-- Example: 
--SELECT qgis_pkg.view_counter('citydb_bdg_lod0_footprint', NULL);
--SELECT qgis_pkg.view_counter('citydb_bdg_lod0_footprint', ST_AsEWKT(ST_MakeEnvelope(229234, 476749, 230334, 479932)));

----------------------------------------------------------------
-- Create FUNCTION QGIS_PKG.COMPUTE_GA_INDICES
----------------------------------------------------------------
-- This function adds indices to the table containing the generic attributes
-- It must be run ONLY ONCE in a specific dbschema, upon installation.
DROP FUNCTION IF EXISTS    qgis_pkg.add_ga_indices(varchar) CASCADE;
CREATE OR REPLACE FUNCTION qgis_pkg.add_ga_indices(
cdb_schema varchar
)
RETURNS void AS $$
DECLARE
sql_statement varchar;

BEGIN
-- Add some indices, if they do not already exists, to table cityobject_genericattrib;

RAISE NOTICE 'Adding indices to table cityobject_genericattrib';
sql_statement := format('
CREATE INDEX IF NOT EXISTS ga_attrname_inx ON %I.cityobject_genericattrib (attrname);
CREATE INDEX IF NOT EXISTS ga_datatype_inx ON %I.cityobject_genericattrib (datatype);
',
cdb_schema, cdb_schema
);
EXECUTE sql_statement;

EXCEPTION
	WHEN QUERY_CANCELED THEN
		RAISE EXCEPTION 'qgis_pkg.add_ga_indices(): Error QUERY_CANCELED';
  WHEN OTHERS THEN 
		RAISE NOTICE 'qgis_pkg.add_ga_indices(): %', SQLERRM;
END;
$$ LANGUAGE plpgsql;
COMMENT ON FUNCTION qgis_pkg.add_ga_indices(varchar) IS 'Adds some indices to table cityobject_genericattrib';

--PERFORM qgis_pkg.add_indices(cdb_schema := 'citydb');

----------------------------------------------------------------
-- Create FUNCTION QGIS_PKG.COMPUTE_SCHEMA_EXTENTS
----------------------------------------------------------------
DROP FUNCTION IF EXISTS    qgis_pkg.compute_schema_extents(varchar, varchar) CASCADE;
CREATE OR REPLACE FUNCTION qgis_pkg.compute_schema_extents(
usr_schema	varchar,
cdb_schema	varchar
)
RETURNS TABLE (
x_min		numeric,
y_min		numeric,
x_max		numeric,
y_max		numeric,
srid_id		integer,
upserted_id	integer
)
AS $$
DECLARE
cdb_envelope	geometry(Polygon) := NULL;

BEGIN

EXECUTE format('SELECT ST_Envelope(ST_Collect(co.envelope)) FROM %I.cityobject AS co', cdb_schema) INTO cdb_envelope;

IF cdb_envelope IS NOT NULL THEN
	srid_id := ST_SRID(cdb_envelope);
	x_min :=   floor(ST_Xmin(cdb_envelope));
	x_max := ceiling(ST_Xmax(cdb_envelope));
	y_min :=   floor(ST_Ymin(cdb_envelope));
	y_max := ceiling(ST_Ymax(cdb_envelope));
	cdb_envelope := ST_MakeEnvelope(x_min, y_min, x_max, y_max, srid_id);

	-- upsert statement for table envelope in in usr_schema
	EXECUTE format('
		INSERT INTO %I.extents AS e (cdb_schema, bbox_type, envelope, creation_date)
		VALUES (%L, ''db_schema'', %L, clock_timestamp())
		ON CONFLICT ON CONSTRAINT extents_cdb_schema_bbox_type_key DO
			UPDATE SET envelope = %L, creation_date = clock_timestamp()
			WHERE e.cdb_schema = %L AND e.bbox_type = ''db_schema''
			RETURNING id',
		usr_schema,	cdb_schema, cdb_envelope, cdb_envelope, cdb_schema)
	INTO STRICT upserted_id;
	RETURN NEXT;
END IF;

EXCEPTION
	WHEN QUERY_CANCELED THEN
		RAISE EXCEPTION 'qgis_pkg.compute_schema_extents(): Error QUERY_CANCELED';
  WHEN OTHERS THEN 
		RAISE NOTICE 'qgis_pkg.compute_schema_extents(): %', SQLERRM;
END;
$$ LANGUAGE plpgsql;
COMMENT ON FUNCTION qgis_pkg.compute_schema_extents(varchar, varchar) IS 'Computes extents of the selected cdb_schema';

-- Example: 
--SELECT * FROM qgis_pkg.compute_schema_extents(cdb_schema := 'citydb');

----------------------------------------------------------------
-- Create FUNCTION QGIS_PKG.UPSERT_EXTENTS
----------------------------------------------------------------
-- Upserts the extents to table extents in usr_schema
DROP FUNCTION IF EXISTS    qgis_pkg.upsert_extents(varchar, varchar, varchar, geometry) CASCADE;
CREATE OR REPLACE FUNCTION qgis_pkg.upsert_extents(
usr_schema		varchar,
cdb_schema		varchar,
cdb_bbox_type	varchar,  -- A value in (''db_schema'', ''m_view'', ''qgis''))
cdb_envelope	geometry(Polygon) DEFAULT NULL
)
RETURNS integer AS $$
DECLARE
cdb_bbox_type_array CONSTANT varchar[] := ARRAY['db_schema', 'm_view', 'qgis'];
ext_label	varchar;
upserted_id	integer := NULL;

BEGIN 

-- Check that the cdb_box_type is a valid value
IF cdb_bbox_type IS NULL OR NOT (cdb_bbox_type = ANY (cdb_bbox_type_array)) THEN
	RAISE EXCEPTION 'cdb_bbox_type value is invalid. It must be one of (''db_schema'', ''m_view'', ''qgis'')';
END IF;

CASE
	WHEN cdb_bbox_type = 'db_schema' THEN
		upserted_id := (SELECT f.upserted_id FROM qgis_pkg.compute_schema_extents(cdb_schema) AS f);
	WHEN cdb_bbox_type IN ('m_view', 'qgis') THEN
		IF cdb_envelope IS NOT NULL THEN
			IF cdb_bbox_type = 'm_view' THEN
				ext_label := concat(cdb_schema,'-mview_bbox_extents');
			ELSE
				ext_label := concat(cdb_schema,'-qgis_bbox_extents');
			END IF;
		
			EXECUTE format('
				INSERT INTO %I.extents AS e (cdb_schema, bbox_type, label, envelope, creation_date)
				VALUES (%L, %L, %L, %L, clock_timestamp())
				ON CONFLICT ON CONSTRAINT extents_cdb_schema_bbox_type_key DO
					UPDATE SET envelope = %L, label = %L, creation_date = clock_timestamp()
					WHERE e.cdb_schema = %L AND e.bbox_type = %L
				RETURNING id',
				usr_schema,
				cdb_schema, cdb_bbox_type, ext_label, cdb_envelope,
				cdb_envelope, ext_label, cdb_schema, cdb_bbox_type)
			INTO STRICT upserted_id;
		END IF;
END CASE;

RETURN upserted_id;

EXCEPTION
	WHEN QUERY_CANCELED THEN
		RAISE EXCEPTION 'qgis_pkg.upsert_extents(): Error QUERY_CANCELED';
  WHEN OTHERS THEN 
		RAISE NOTICE 'qgis_pkg.upsert_extents(): %', SQLERRM;
END;
$$ LANGUAGE plpgsql;
COMMENT ON FUNCTION qgis_pkg.upsert_extents(varchar, varchar, varchar, geometry) IS 'Updates the extents table in user schema';

-- Example:
--SELECT qgis_pkg.upsert_extents(usr_schema := 'qgis_user', cdb_schema := 'citydb', cdb_bbox_type := 'db_schema', cdb_envelope := NULL);

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

----------------------------------------------------------------
-- Create FUNCTION QGIS_PKG.ST_SNAP_POLY_TO_GRID
----------------------------------------------------------------
DROP FUNCTION IF EXISTS    qgis_pkg.st_snap_poly_to_grid(geometry, integer, integer, numeric) CASCADE;
CREATE OR REPLACE FUNCTION qgis_pkg.st_snap_poly_to_grid(
polygon 			geometry,
perform_snapping 	integer DEFAULT 0, 			-- i.e. default is "do nothing", otherwise 1.
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
		--RAISE NOTICE 'polygon: %', ST_AsEWKT(polygon);
		RETURN polygon;
	WHEN perform_snapping = 1 THEN
		dec_prec := 10^(-digits);
		srid_id := ST_SRID(polygon);
		snapped_poly := ST_SnapToGrid(polygon, ST_GeomFromText('Point(0 0 0)'), dec_prec, dec_prec, dec_prec, 0);
		--RAISE NOTICE 'snapped poly %',ST_AsEWKT(snapped_poly);
		is_empty_geom := ST_IsEmpty(snapped_poly);
		--RAISE NOTICE 'is empty geom? %',is_empty_geom;

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
$$ LANGUAGE plpgsql;
COMMENT ON FUNCTION qgis_pkg.st_snap_poly_to_grid(geometry, integer, integer, numeric) IS 'Snaps 3D polygon to grid and drops it if it is smaller than the minimum area threshold';

--SELECT qgis_pkg.st_snap_poly_to_grid(geometry, 1, 2, 0.01) FROM citydb.surface_geometry WHERE geometry IS NOT NULL LIMIT 10000;

----------------------------------------------------------------
-- Create FUNCTION QGIS_PKG.GENERATE_SQL_MATVIEW_HEADER
----------------------------------------------------------------
DROP FUNCTION IF EXISTS    qgis_pkg.generate_sql_matview_header(varchar,varchar) CASCADE;
CREATE OR REPLACE FUNCTION qgis_pkg.generate_sql_matview_header(
qi_usr_schema	varchar,
qi_mview_name	varchar 
)
RETURNS text
AS $$
DECLARE
sql_statement text;

BEGIN

sql_statement := concat('
-----------------------------------------------------------------
-- MATERIALIZED VIEW ',upper(qi_usr_schema),'.',upper(qi_mview_name),'
-----------------------------------------------------------------
DROP MATERIALIZED VIEW IF EXISTS ',qi_usr_schema,'.',qi_mview_name,' CASCADE;
CREATE MATERIALIZED VIEW         ',qi_usr_schema,'.',qi_mview_name,' AS');

RETURN sql_statement;

EXCEPTION
	WHEN QUERY_CANCELED THEN
		RAISE EXCEPTION 'qgis_pkg.generate_sql_matview_header(): Error QUERY_CANCELED';
  WHEN OTHERS THEN 
		RAISE NOTICE 'qgis_pkg.generate_sql_matview_header(): %', SQLERRM;
END;
$$ LANGUAGE plpgsql;

----------------------------------------------------------------
-- Create FUNCTION QGIS_PKG.GENERATE_SQL_MATVIEW_FOOTER
----------------------------------------------------------------
DROP FUNCTION IF EXISTS    qgis_pkg.generate_sql_matview_footer(varchar,varchar,varchar,varchar) CASCADE;
CREATE OR REPLACE FUNCTION qgis_pkg.generate_sql_matview_footer(
qi_usr_name		varchar,
qi_usr_schema	varchar,
qi_mview_name	varchar,
ql_view_name	varchar
)
RETURNS text
AS $$
DECLARE
mview_name CONSTANT varchar := trim(both '"' from qi_mview_name);
mview_idx_name CONSTANT varchar := quote_ident(concat(mview_name,'_id_idx'));
mview_spx_name CONSTANT varchar := quote_ident(concat(mview_name,'_geom_spx'));
sql_statement text;

BEGIN
sql_statement := concat('
CREATE INDEX ',mview_idx_name,' ON ',qi_usr_schema,'.',qi_mview_name,' (co_id);
CREATE INDEX ',mview_spx_name,' ON ',qi_usr_schema,'.',qi_mview_name,' USING gist (geom);
ALTER TABLE ',qi_usr_schema,'.',qi_mview_name,' OWNER TO ',qi_usr_name,';

--DELETE FROM ',qi_usr_schema,'.layer_metadata WHERE v_name = ',ql_view_name,';
--REFRESH MATERIALIZED VIEW ',qi_usr_schema,'.',qi_mview_name,';
');

RETURN sql_statement;

EXCEPTION
	WHEN QUERY_CANCELED THEN
		RAISE EXCEPTION 'qgis_pkg.generate_sql_matview_footer(): Error QUERY_CANCELED';
  WHEN OTHERS THEN 
		RAISE NOTICE 'qgis_pkg.generate_sql_matview_footer(): %', SQLERRM;
END;
$$ LANGUAGE plpgsql;

----------------------------------------------------------------
-- Create FUNCTION QGIS_PKG.GENERATE_SQL_VIEW_HEADER
----------------------------------------------------------------
DROP FUNCTION IF EXISTS    qgis_pkg.generate_sql_view_header(varchar,varchar) CASCADE;
CREATE OR REPLACE FUNCTION qgis_pkg.generate_sql_view_header(
qi_usr_schema	varchar,
qi_view_name	varchar 
)
RETURNS text
AS $$
DECLARE
sql_statement text;

BEGIN
sql_statement := concat('
-----------------------------------------------------------------
-- VIEW ',upper(qi_usr_schema),'.',upper(qi_view_name),'
-----------------------------------------------------------------
DROP VIEW IF EXISTS    ',qi_usr_schema,'.',qi_view_name,' CASCADE;
CREATE OR REPLACE VIEW ',qi_usr_schema,'.',qi_view_name,' AS');

RETURN sql_statement;

EXCEPTION
	WHEN QUERY_CANCELED THEN
		RAISE EXCEPTION 'qgis_pkg.generate_sql_view_header(): Error QUERY_CANCELED';
  WHEN OTHERS THEN 
		RAISE NOTICE 'qgis_pkg.generate_sql_view_header(): %', SQLERRM;
END;
$$ LANGUAGE plpgsql;

----------------------------------------------------------------
-- Create FUNCTION QGIS_PKG.GENERATE_SQL_MATVIEW_ELSE
----------------------------------------------------------------
DROP FUNCTION IF EXISTS    qgis_pkg.generate_sql_matview_else(varchar,varchar,varchar) CASCADE;
CREATE OR REPLACE FUNCTION qgis_pkg.generate_sql_matview_else(
qi_usr_schema	varchar,
qi_mview_name	varchar,
ql_view_name	varchar  
)
RETURNS text
AS $$
DECLARE
sql_statement text;

BEGIN
sql_statement := concat('
-- This drops the materialized view AND the associated view
DROP MATERIALIZED VIEW IF EXISTS ',qi_usr_schema,'.',qi_mview_name,' CASCADE;
DELETE FROM ',qi_usr_schema,'.layer_metadata WHERE v_name = ',ql_view_name,';
');

RETURN sql_statement;

EXCEPTION
	WHEN QUERY_CANCELED THEN
		RAISE EXCEPTION 'qgis_pkg.generate_sql_matview_else(): Error QUERY_CANCELED';
  WHEN OTHERS THEN 
		RAISE NOTICE 'qgis_pkg.generate_sql_matview_else(): %', SQLERRM;
END;
$$ LANGUAGE plpgsql;

----------------------------------------------------------------
-- Create FUNCTION QGIS_PKG.GENERATE_SQL_TRIGGERS
----------------------------------------------------------------
-- Function to generate SQL for triggers
DROP FUNCTION IF EXISTS    qgis_pkg.generate_sql_triggers(varchar, varchar, varchar, varchar) CASCADE;
CREATE OR REPLACE FUNCTION qgis_pkg.generate_sql_triggers(
view_name			varchar,
tr_function_suffix	varchar,
usr_name			varchar,
usr_schema			varchar 
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
	trigger_n := concat('tr_', tr.tr_short, '_', view_name);
	slq_stat_trig_part := NULL;
	slq_stat_trig_part := format('
DROP TRIGGER IF EXISTS %I ON %I.%I;
CREATE TRIGGER         %I
	INSTEAD OF %s ON %I.%I
	FOR EACH ROW EXECUTE PROCEDURE qgis_pkg.%s;
COMMENT ON TRIGGER %I ON %I.%I IS ''Fired upon %s into view %I.%I'';
',
	trigger_n, usr_schema, view_name,
	trigger_n,
	tr.tr_cap, usr_schema, view_name,
	trigger_f,
	trigger_n, usr_schema, view_name,
	tr.tr_small, usr_schema, view_name
);

sql_statement := concat(sql_statement, slq_stat_trig_part);

END LOOP;

RETURN sql_statement;

EXCEPTION
	WHEN QUERY_CANCELED THEN
		RAISE EXCEPTION 'qgis_pkg.generate_sql_triggers(): Error QUERY_CANCELED';
  WHEN OTHERS THEN 
		RAISE NOTICE 'qgis_pkg.generate_sql_triggers(): %', SQLERRM;
END;
$$ LANGUAGE plpgsql;

/* --- TEMPLATE FOR FUNCTIONS
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
		RAISE NOTICE 'qgis_pkg.xx_funcname_xx(): %', SQLERRM;
END;
$$ LANGUAGE plpgsql;
COMMENT ON FUNCTION qgis_pkg.xx_funcname_xx(varchar) IS 'xxxx short comment xxxx';
*/

--**************************
DO $$
BEGIN
RAISE NOTICE E'\n\nDone\n\n';
END $$;
--**************************
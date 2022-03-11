-- ****************************************************************************
-- ****************************************************************************
--
--
-- CREATE LAYERS FOR MODULE LANDUSE
--
--
-- ****************************************************************************
-- ****************************************************************************

----------------------------------------------------------------
-- Create FUNCTION QGIS_PKG.REFRESH_MVIEW_new
----------------------------------------------------------------
DROP FUNCTION IF EXISTS    qgis_pkg.refresh_mview_new(varchar, varchar) CASCADE;
CREATE OR REPLACE FUNCTION qgis_pkg.refresh_mview_new(
usr_schema	varchar,
cdb_schema	varchar DEFAULT NULL,
mview_name	varchar DEFAULT NULL
)
RETURNS integer AS $$
DECLARE
qgis_schema			 	varchar := 'qgis_pkg';
start_timestamp 		timestamptz(3);
stop_timestamp 			timestamptz(3);
f_start_timestamp 		timestamptz(3);
f_stop_timestamp 		timestamptz(3);
r 						RECORD;
mv_n_features 			integer DEFAULT 0;

BEGIN
IF usr_schema IS NULL THEN
	RAISE EXCEPTION 'usr_schema must not be NULL';
END IF;



f_start_timestamp := clock_timestamp();
CASE 
	WHEN cdb_schema IS NULL AND mview_name IS NULL THEN -- refresh all existing materialized views in user_schema
	RAISE NOTICE 'Refreshing all materialized views in schema %', qgis_schema;
		FOR r IN 
			SELECT 
				pg_namespace.nspname AS table_schema,
				pg_class.relname AS mview_name
			FROM 
				pg_catalog.pg_class
				INNER JOIN pg_catalog.pg_namespace ON pg_class.relnamespace = pg_namespace.oid
			WHERE 
				pg_class.relkind = 'm' 
				AND pg_namespace.nspname = usr_schema
			ORDER BY mview_name
		LOOP
			start_timestamp := clock_timestamp();
			EXECUTE format('REFRESH MATERIALIZED VIEW %I.%I', usr_schema, r.mview_name);
			stop_timestamp := clock_timestamp();
			EXECUTE format('SELECT count(co_id) FROM %I.%I', usr_schema, r.mview_name) INTO mv_n_features;
			EXECUTE format('
				UPDATE %I.layer_metadata AS lm SET
					n_features    = %L,
					refresh_date  = %L 
				WHERE lm.mv_name = %L;
			',usr_schema, mv_n_features, stop_timestamp, r.mview_name);

			RAISE NOTICE 'Refreshed materialized view "%.%" in %', usr_schema, r.mview_name, stop_timestamp-start_timestamp; 
		END LOOP;
		f_stop_timestamp := clock_timestamp();		
		RAISE NOTICE 'All materialized views in "%" refreshed in %!', usr_schema, f_stop_timestamp-f_start_timestamp; 	
		RETURN 1;

	WHEN cdb_schema IS NOT NULL THEN -- refresh all existing materialized views for that cdb_schema
		IF EXISTS (
			SELECT 1
			FROM 
				pg_catalog.pg_class
				INNER JOIN pg_catalog.pg_namespace ON pg_class.relnamespace = pg_namespace.oid
			WHERE 
				pg_class.relkind = 'm' 
				AND pg_namespace.nspname = usr_schema
				AND split_part(pg_class.relname::text, '_', 3) = cdb_schema
			LIMIT 1
		) THEN
			RAISE NOTICE 'Refreshing all materialized views in "%" associated to "%"', usr_schema, cdb_schema;		
			FOR r IN 
				SELECT 
					pg_namespace.nspname AS table_schema,
					pg_class.relname AS mview_name
				FROM 
					pg_catalog.pg_class
					INNER JOIN pg_catalog.pg_namespace ON pg_class.relnamespace = pg_namespace.oid
				WHERE 
					pg_class.relkind = 'm' 
					AND pg_namespace.nspname = usr_schema
					AND split_part(pg_class.relname::text, '_', 3) = cdb_schema
				ORDER BY table_schema, mview_name
			LOOP
				start_timestamp := clock_timestamp();
				EXECUTE format('REFRESH MATERIALIZED VIEW %I.%I', usr_schema, r.mview_name);
				stop_timestamp := clock_timestamp();
				EXECUTE format('SELECT count(co_id) FROM %I.%I', usr_schema, r.mview_name) INTO mv_n_features;
				EXECUTE format('
					UPDATE %I.layer_metadata AS lm SET
						n_features    = %L,
						refresh_date  = %L 
					WHERE lm.mv_name = %L;
				',usr_schema, mv_n_features, stop_timestamp, r.mview_name);				

				RAISE NOTICE 'Refreshed materialized view "%.%" in %', usr_schema, r.mview_name, stop_timestamp-start_timestamp; 
			END LOOP;
			f_stop_timestamp := clock_timestamp();		
			RAISE NOTICE 'All materialized views in "%" for "%" refreshed in %!!', usr_schema, cdb_schema, f_stop_timestamp-f_start_timestamp; 	
			RETURN 1;
		ELSE
			RAISE NOTICE 'No schema found with name "%"', cdb_schema;
			RETURN 0;			
		END IF;

	WHEN mview_name IS NOT NULL THEN -- refresh only a specific materialized views
		IF EXISTS (SELECT 1 
					FROM 
						pg_catalog.pg_class
						INNER JOIN pg_catalog.pg_namespace ON pg_class.relnamespace = pg_namespace.oid
					WHERE 
						pg_class.relkind = 'm' 
						AND pg_namespace.nspname = usr_schema
						AND pg_class.relname = mview_name
		) THEN
			RAISE NOTICE 'Refreshing materialized view "%.%""', usr_schema, mview_name;
			start_timestamp := clock_timestamp();
			EXECUTE format('REFRESH MATERIALIZED VIEW %I.%I', usr_schema, mview_name);
			stop_timestamp := clock_timestamp();
			EXECUTE format('SELECT count(co_id) FROM %I.%I', usr_schema, mview_name) INTO mv_n_features;
			EXECUTE format('
				UPDATE %I.layer_metadata AS lm SET
					n_features    = %L,
					refresh_date  = %L 
				WHERE lm.mv_name = %L;
			',usr_schema, mv_n_features, stop_timestamp, mview_name);	
			RAISE NOTICE 'Refreshed materialized view "%.%" in %', usr_schema, mview_name, stop_timestamp-start_timestamp; 
			RETURN 1;
		ELSE
			RAISE NOTICE 'No materialized view found with name "%"', mview_name;
			RETURN 0;			
		END IF;

	ELSE
		RAISE NOTICE 'Nothing done';
		RETURN 0;	
END CASE;

EXCEPTION
	WHEN QUERY_CANCELED THEN
		RAISE EXCEPTION 'qgis_pkg.refresh_mview(): Error QUERY_CANCELED';
  WHEN OTHERS THEN 
		RAISE NOTICE 'qgis_pkg.refresh_mview(): %', SQLERRM;
END;
$$ LANGUAGE plpgsql;
COMMENT ON FUNCTION qgis_pkg.refresh_mview(varchar, varchar) IS 'Refresh materialized view(s) in user schema';

--SELECT qgis_pkg.refresh_mview_new(usr_schema := 'qgis_user');
SELECT qgis_pkg.refresh_mview_new(usr_schema := 'qgis_user', cdb_schema := 'citydb3');

----------------------------------------------------------------
-- Create FUNCTION QGIS_PKG.CREATE_QGIS_USER_SCHEMA
----------------------------------------------------------------
-- Creates the qgis schema for a user
DROP FUNCTION IF EXISTS    qgis_pkg.create_qgis_user_schema(varchar) CASCADE;
CREATE OR REPLACE FUNCTION qgis_pkg.create_qgis_user_schema(
usr_name	varchar
)
RETURNS integer
AS $$
DECLARE
usr_schema_prefix varchar := 'qgis_'; 
usr_schema varchar;

BEGIN
IF usr_name IS NULL THEN
	usr_name := 'user';
END IF;

usr_schema := concat(usr_schema_prefix, usr_name);

-- ************************************************************
-- THIS IS ONLY TEMPORARILY: HARD CODE THE USER TO 'postgres', even if it is different
usr_name := 'postgres';
usr_schema := concat(usr_schema_prefix, 'user');
-- ************************************************************
RAISE NOTICE 'Creating schema "%" for user "%"', usr_schema, usr_name;

-- This must be substituted by a more complex function;
EXECUTE format('DROP SCHEMA IF EXISTS %I CASCADE', usr_schema);

EXECUTE format('CREATE SCHEMA IF NOT EXISTS %I', usr_schema);

EXECUTE format('
DROP TABLE IF EXISTS %I.layer_metadata CASCADE;
CREATE TABLE %I.layer_metadata (LIKE qgis_pkg.layer_metadata INCLUDING ALL);
ALTER TABLE %I.layer_metadata OWNER TO %I;

DROP TABLE IF EXISTS %I.extents CASCADE;
CREATE TABLE %I.extents (LIKE qgis_pkg.extents INCLUDING ALL);
ALTER TABLE %I.extents OWNER TO %I;

DROP TABLE IF EXISTS %I.enumeration CASCADE;
CREATE TABLE %I.enumeration (LIKE qgis_pkg.enumeration INCLUDING ALL);
ALTER TABLE %I.enumeration OWNER TO %I;

DROP TABLE IF EXISTS %I.enumeration_value CASCADE;
CREATE TABLE %I.enumeration_value (LIKE qgis_pkg.enumeration_value INCLUDING ALL);
ALTER TABLE %I.enumeration_value OWNER TO %I;

DROP TABLE IF EXISTS %I.codelist CASCADE;
CREATE TABLE %I.codelist (LIKE qgis_pkg.codelist INCLUDING ALL);
ALTER TABLE %I.codelist OWNER TO %I;

DROP TABLE IF EXISTS %I.codelist_value CASCADE;
CREATE TABLE %I.codelist_value (LIKE qgis_pkg.codelist_value INCLUDING ALL);
ALTER TABLE %I.codelist_value OWNER TO %I;
',
usr_schema,usr_schema,usr_schema,usr_name,
usr_schema,usr_schema,usr_schema,usr_name,
usr_schema,usr_schema,usr_schema,usr_name,
usr_schema,usr_schema,usr_schema,usr_name,
usr_schema,usr_schema,usr_schema,usr_name,
usr_schema,usr_schema,usr_schema,usr_name
);

EXECUTE format('
INSERT INTO %I.extents SELECT * FROM qgis_pkg.extents ORDER BY id;
INSERT INTO %I.enumeration SELECT * FROM qgis_pkg.enumeration ORDER BY id;
INSERT INTO %I.enumeration_value SELECT * FROM qgis_pkg.enumeration_value ORDER BY id;
INSERT INTO %I.codelist SELECT * FROM qgis_pkg.codelist ORDER BY id;
INSERT INTO %I.codelist_value SELECT * FROM qgis_pkg.codelist_value ORDER BY id;
',
usr_schema,usr_schema,usr_schema,usr_schema,usr_schema
);

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

EXECUTE format('DELETE FROM qgis_pkg.usr_schema AS u WHERE u.usr_name = %L',usr_name);

INSERT INTO qgis_pkg.usr_schema (usr_name, usr_schema, creation_date) VALUES
(usr_name, usr_schema, clock_timestamp());

RETURN 1;

EXCEPTION
	WHEN QUERY_CANCELED THEN
		RAISE EXCEPTION 'qgis_pkg.create_qgis_user_schema(): Error QUERY_CANCELED';
		RETURN 0;
	WHEN OTHERS THEN 
		RAISE NOTICE 'qgis_pkg.create_qgis_user_schema(): %', SQLERRM;
		RETURN 0;
END;
$$ LANGUAGE plpgsql;
COMMENT ON FUNCTION qgis_pkg.create_qgis_user_schema(varchar) IS 'Creates the qgis schema for a user';

--SELECT qgis_pkg.create_qgis_user_schema('user');

----------------------------------------------------------------
-- Create FUNCTION QGIS_PKG.GENERATE_SQL_TRIGGERS
----------------------------------------------------------------
-- Function to generate SQL for triggers
DROP FUNCTION IF EXISTS    qgis_pkg.generate_sql_triggers(varchar, varchar, varchar, varchar) CASCADE;
CREATE OR REPLACE FUNCTION qgis_pkg.generate_sql_triggers(
view_name			varchar,
tr_function_suffix	varchar,
usr_name			varchar DEFAULT 'postgres',  -- this default will have to be dropped
usr_schema			varchar DEFAULT 'qgis_user'  -- this default will have to be dropped
)
RETURNS text
AS $$
DECLARE
tr				RECORD;
trigger_f		varchar;
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

--trigger_f := concat('tr_',tr.tr_short,'_land_use()');
trigger_f := concat('tr_',tr.tr_short,'_',tr_function_suffix,'()');

slq_stat_trig_part := NULL;
slq_stat_trig_part := concat('
DROP TRIGGER IF EXISTS tr_',tr.tr_short,'_',view_name,' ON ',usr_schema,'.',view_name,';
CREATE TRIGGER         tr_',tr.tr_short,'_',view_name,'
	INSTEAD OF ',tr.tr_cap,' ON ',usr_schema,'.',view_name,'
	FOR EACH ROW
	EXECUTE PROCEDURE qgis_pkg.',trigger_f,';
COMMENT ON TRIGGER tr_',tr.tr_short,'_',view_name,' ON ',usr_schema,'.',view_name,' IS ''Fired upon ',tr.tr_small,' into view ',usr_schema,'.',view_name,''';
');

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
COMMENT ON FUNCTION qgis_pkg.generate_sql_triggers(varchar, varchar, varchar, varchar) IS 'Generate SQL to create triggers for updatable views';



--**************************
DO $MAINBODY$
DECLARE
BEGIN
RAISE NOTICE E'\n\nDone\n\n';
END $MAINBODY$;
--**************************
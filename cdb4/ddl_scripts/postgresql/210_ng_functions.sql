-------------------------------------------------------------------
-- CREATE FUNCTION qgis_pkg.generate_sql_triggers
-------------------------------------------------------------------

DROP FUNCTION IF EXISTS qgis_pkg.generate_sql_triggers(varchar,varchar,varchar) CASCADE;
CREATE OR REPLACE FUNCTION qgis_pkg.generate_sql_triggers(usr_schema varchar, layer_name varchar, tr_function_suffix varchar)
RETURNS text AS $$

DECLARE
	tr RECORD;
	trigger_f varchar;
	trigger_n varchar;
	sql_stat_trig_part text := NULL;
	sql_statement text := NULL;
BEGIN
	FOR tr IN
		SELECT * FROM (VALUES
		('ins','insert','INSERT'),
		('del','delete','DELETE'),
		('upd','update','UPDATE')
		) AS t(tr_short,tr_small,tr_cap)
	LOOP
		trigger_f := format('tr_%s_%s()',tr.tr_short,tr_function_suffix);
		trigger_n := concat('tr_',tr.tr_short,'_',layer_name);
		sql_stat_trig_part := format('
			DROP TRIGGER IF EXISTS %I ON %I.%I;
			CREATE TRIGGER %I
				INSTEAD OF %s ON %I.%I
				FOR EACH ROW EXECUTE PROCEDURE qgis_pkg.%s;
			COMMENT ON TRIGGER %I ON %I.%I IS ''Fired upon %s into view %I.%I'';',
			trigger_n,usr_schema,layer_name,
			trigger_n,
			tr.tr_cap,usr_schema,layer_name,
			trigger_f,
			trigger_n,usr_schema,layer_name,tr.tr_small,usr_schema,layer_name);
		sql_statement := concat(sql_statement,sql_stat_trig_part);
	END LOOP;
	RETURN sql_statement;
	EXCEPTION
		WHEN QUERY_CANCELED THEN
			RAISE EXCEPTION 'qgis_pkg.generate_sql_triggers(): Error QUERY_CANCELED';
		WHEN OTHERS THEN
			RAISE NOTICE 'qgis_pkg.generate_sql_triggers(): %',SQLERRM;
	
END
$$ LANGUAGE plpgsql;
REVOKE EXECUTE ON FUNCTION qgis_pkg.generate_sql_triggers(varchar,varchar,varchar) FROM public;

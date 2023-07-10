---------------------------------------------------------------------
-- CREATE FUNCTION qgis_pkg.create_layers_ng_building
---------------------------------------------------------------------

DROP FUNCTION IF EXISTS qgis_pkg.create_layers_ng_building(varchar,varchar,integer,integer,numeric,numeric[],boolean) CASCADE;
CREATE OR REPLACE FUNCTION qgis_pkg.create_layers_ng_building(
	usr_name varchar, 
	cdb_schema varchar, 
	perform_snapping integer DEFAULT 0, 
	digits integer DEFAULT 3, 
	area_poly_min numeric DEFAULT 0.0001,
	bbox_corners_array numeric[] DEFAULT NULL,
	force_layer_creation boolean DEFAULT TRUE
)
RETURNS void AS $$
DECLARE
	sql_statement text := NULL;
	mview_bbox geometry(Polygon) := NULL;
	schema varchar			:= 'qgis_pkg';
	sql_function text;
	f RECORD;
	qi_schema varchar; qi_feature varchar; qi_usr_name varchar; qi_cdb_schema varchar;
	ade_prefix_ varchar := 'ng';
BEGIN
	mview_bbox := qgis_pkg.generate_mview_bbox_poly(cdb_schema,bbox_corners_array);
	sql_statement := qgis_pkg.generate_sql_layers_ng_building(
		usr_name 		:= usr_name,
		cdb_schema		:= cdb_schema,
		perform_snapping	:= perform_snapping,
		digits			:= digits,
		area_poly_min		:= area_poly_min,
		mview_bbox		:= mview_bbox,
		force_layer_creation	:= force_layer_creation,
		ade_prefix		:= ade_prefix_
	);

	IF sql_statement IS NOT NULL THEN
		EXECUTE sql_statement;
	END IF;
	
	qi_schema := quote_ident(schema);
	qi_cdb_schema := quote_ident(cdb_schema);
	qi_usr_name := quote_ident(usr_name);
	mview_bbox := qgis_pkg.generate_mview_bbox_poly(cdb_schema,bbox_corners_array);	
	FOR f IN
		SELECT * FROM (VALUES
			('thermalzone'::varchar),
			('thermalboundary'::varchar),
			('thermalopening'::varchar),
			('usagezone'::varchar),
			('facilities'::varchar),
			('occupants'::varchar)
		) AS bphys(class_name)
	LOOP
		sql_statement := NULL;
		EXECUTE format('SELECT qgis_pkg.generate_sql_layers_ng_%s(usr_name:=$1,cdb_schema:=$2,perform_snapping:=$3,
				digits:=$4,area_poly_min:=$5,mview_bbox:=$6,force_layer_creation:=$7,ade_prefix:=$8)',f.class_name)
	       			INTO sql_statement 
				USING usr_name,cdb_schema,perform_snapping,digits,
			        area_poly_min,mview_bbox,force_layer_creation,ade_prefix_;	
		RAISE NOTICE '%',sql_statement;

		IF sql_statement IS NOT NULL THEN
			EXECUTE sql_statement;
		END IF;
				
	END LOOP;
		
		
	EXCEPTION
		WHEN QUERY_CANCELED THEN
			RAISE EXCEPTION 'qgis_pkg.create_layers_ng_building(): Error QUERY_CANCELED';
		WHEN OTHERS THEN
			RAISE EXCEPTION 'qgis_pkg.create_layers_ng_building(): %',SQLERRM;
END;
$$ LANGUAGE plpgsql;
COMMENT ON FUNCTION qgis_pkg.create_layers_ng_building(varchar,varchar,integer,integer,numeric,numeric[],boolean) IS 'Create Building layers';
REVOKE EXECUTE ON FUNCTION qgis_pkg.create_layers_ng_building(varchar,varchar,integer,integer,numeric,numeric[],boolean) FROM public;

---------------------------------------------------------------------
-- CREATE FUNCTION qgis_pkg.create_layers_weatherstation
---------------------------------------------------------------------

DROP FUNCTION IF EXISTS qgis_pkg.create_layers_ng_weatherstation(varchar,varchar,integer,integer,numeric,numeric[],boolean) CASCADE;
CREATE OR REPLACE FUNCTION qgis_pkg.create_layers_ng_weatherstation(
	usr_name varchar,
       	cdb_schema varchar,
       	perform_snapping integer DEFAULT 0,
       	digits integer DEFAULT 3,
	area_poly_min numeric DEFAULT 0.0001,
       	bbox_corners_array numeric[] DEFAULT NULL,
       	force_layer_creation boolean DEFAULT FALSE
)
RETURNS void AS $$
DECLARE
	sql_statement text 		:= NULL;
	mview_bbox geometry(Polygon) 	:= NULL;
	schema varchar			:= 'qgis_pkg';
	sql_function text;
	qi_schema varchar; qi_feature varchar; qi_usr_name varchar; qi_cdb_schema varchar;
	f RECORD;
BEGIN
	mview_bbox := qgis_pkg.generate_mview_bbox_poly(cdb_schema,bbox_corners_array);	
	qi_usr_name := quote_literal(usr_name);
	qi_cdb_schema := quote_ident(cdb_schema);

	FOR f IN
		SELECT * FROM (VALUES
			('weatherstation'::varchar)
		) AS wdata(class_name)
	LOOP

		EXECUTE format('SELECT qgis_pkg.generate_sql_layers_ng_%s(usr_name:=$1,cdb_schema:=$2,perform_snapping:=$3,
				digits:=$4,area_poly_min:=$5,mview_bbox:=$6,force_layer_creation:=$7)',f.class_name) INTO sql_statement 
				USING usr_name,cdb_schema,perform_snapping,digits,
			        area_poly_min,mview_bbox,force_layer_creation;	
		RAISE NOTICE '%',sql_statement;

		IF sql_statement IS NOT NULL THEN
			EXECUTE sql_statement;
		END IF;

	END LOOP;

	EXCEPTION
	    WHEN QUERY_CANCELED THEN
		RAISE EXCEPTION 'qgis_pkg.create_layers_ng_weatherstation(): Error QUERY_CANCELED';
	    WHEN OTHERS THEN
		RAISE EXCEPTION 'qgis_pkg.create_layers__ng_weatherstation(): %', SQLERRM;
END;
$$ LANGUAGE plpgsql;
COMMENT ON FUNCTION qgis_pkg.create_layers_ng_weatherstation(varchar,varchar,integer,integer,numeric,numeric[],boolean) IS 'Create WeatherStation layers';
REVOKE EXECUTE ON FUNCTION qgis_pkg.create_layers_ng_weatherstation(varchar,varchar,integer,integer,numeric,numeric[],boolean) FROM public;


---------------------------------------------------------------------
-- CREATE FUNCTION qgis_pkg.create_detail_views
---------------------------------------------------------------------

DROP FUNCTION IF EXISTS qgis_pkg.create_detail_views(varchar,varchar,integer,integer,numeric,numeric[],boolean) CASCADE;
CREATE OR REPLACE FUNCTION qgis_pkg.create_detail_views(
	usr_name varchar,
       	cdb_schema varchar,
       	perform_snapping integer DEFAULT 0,
       	digits integer DEFAULT 3,
	area_poly_min numeric DEFAULT 0.0001,
       	bbox_corners_array numeric[] DEFAULT NULL,
       	force_layer_creation boolean DEFAULT TRUE
)
RETURNS void AS $$
DECLARE
	sql_statement text              := NULL;
        mview_bbox geometry(Polygon)    := NULL;
        schema varchar                  := 'qgis_pkg';
        sql_function text;
        qi_schema varchar; qi_feature varchar; qi_usr_name varchar; qi_cdb_schema varchar;
        f RECORD;
BEGIN
	mview_bbox := qgis_pkg.generate_mview_bbox_poly(cdb_schema,bbox_corners_array);	
	qi_usr_name := quote_literal(usr_name);
	qi_cdb_schema := quote_ident(cdb_schema);
	
	FOR f IN
		SELECT * FROM (VALUES
			('dailyschedule'::varchar),
			('periodofyear'::varchar),
			('energydemand'::varchar),
			('opticalproperties'::varchar),
			('reflectance'::varchar),
			('floorarea'::varchar),
			('heightaboveground'::varchar),
			('heatexchangetype'::varchar),
			('volumetype'::varchar),
			('transmittance'::varchar),
			('construction'::varchar),
			('layer'::varchar),
			('layercomponent'::varchar),
			('gas'::varchar),
			('solidmaterial'::varchar),
			('timevaluesproperties'::varchar),
			('regulartimeseries'::varchar),
			('regulartimeseriesfile'::varchar),
			('weatherdata'::varchar)
		) AS ts(class_name)
	LOOP
		EXECUTE format('SELECT qgis_pkg.generate_sql_layers_ng_%s(usr_name:=$1,cdb_schema:=$2,perform_snapping:=$3,
				digits:=$4,area_poly_min:=$5,mview_bbox:=$6,force_layer_creation:=$7,ade_prefix:=$8)',f.class_name) INTO sql_statement 
				USING usr_name,cdb_schema,perform_snapping,digits,
			        area_poly_min,mview_bbox,force_layer_creation,'ng';	
		RAISE NOTICE '%',sql_statement;

		IF sql_statement IS NOT NULL THEN
			EXECUTE sql_statement;
		END IF;

	END LOOP;

	EXCEPTION
	    WHEN QUERY_CANCELED THEN
		RAISE EXCEPTION 'qgis_pkg.create_detail_views(): Error QUERY_CANCELED';
	    WHEN OTHERS THEN
		RAISE EXCEPTION 'qgis_pkg.create_detail_views(): %', SQLERRM;
END;
$$ LANGUAGE plpgsql;
COMMENT ON FUNCTION qgis_pkg.create_detail_views(varchar,varchar,integer,integer,numeric,numeric[],boolean) IS 'Create Detail Views';
REVOKE EXECUTE ON FUNCTION qgis_pkg.create_detail_views(varchar,varchar,integer,integer,numeric,numeric[],boolean) FROM public;

---------------------------------------------------------------------
-- CREATE FUNCTION qgis_pkg.refresh_layers_ng_building
---------------------------------------------------------------------

DROP FUNCTION IF EXISTS qgis_pkg.refresh_layers_ng_building(varchar,varchar) CASCADE;
CREATE OR REPLACE FUNCTION qgis_pkg.refresh_layers_ng_building(usr_schema varchar,cdb_schema varchar) 
RETURNS void AS $$
DECLARE 
	usr_schemas_array CONSTANT varchar[] := (SELECT array_agg(s.usr_schema) FROM qgis_pkg.list_usr_schemas() AS s);
	cdb_schemas_array CONSTANT varchar[] := (SELECT array_agg(d.cdb_schema) FROM qgis_pkg.list_cdb_schemas() AS d);
	feat_type_prefix  varchar;
	start_timestamp   timestamptz(3);
	stop_timestamp    timestamptz(3);
	f_start_timestamp timestamptz(3);
	f_stop_timestamp  timestamptz(3);
	mv_n_features     integer DEFAULT 0;
	r                 RECORD;
BEGIN
	IF usr_schema IS NULL OR NOT(usr_schema = ANY(usr_schemas_array)) THEN
		RAISE EXCEPTION 'usr_schema must correspond to an existing usr_schema';
	END IF;

	IF cdb_schema IS NULL OR NOT(cdb_schema = ANY(cdb_schemas_array)) THEN
		RAISE EXCEPTION 'cdb_schema must correspond to an existing cdb_schema';
	END IF;

	FOR r IN
		SELECT mv.matviewname AS mv_name 
		FROM pg_matviews AS mv
		WHERE
			mv.schemaname = usr_schema AND
			mv.matviewname LIKE concat('%',cdb_schema,'%ng_bdg%')
		UNION
		SELECT mv.matviewname AS mv_name
		FROM pg_matviews AS mv
		WHERE
			mv.schemaname = usr_schema AND
			mv.matviewname LIKE concat('%',cdb_schema,'%thermal%')
	LOOP
		RAISE NOTICE '%',r;
		start_timestamp := clock_timestamp();
		EXECUTE format('REFRESH MATERIALIZED VIEW %I.%I',usr_schema,r.mv_name);
		stop_timestamp := clock_timestamp();
		EXECUTE format('SELECT COUNT(co_id) FROM %I.%I',usr_schema,r.mv_name) INTO mv_n_features;
		EXECUTE format('UPDATE %I.layer_metadata AS lm SET n_features = %L, refresh_date = %L WHERE lm.cdb_schema = %L AND lm.gv_name = %L;',
        			usr_schema, mv_n_features, stop_timestamp, cdb_schema, r.mv_name);
		RAISE NOTICE 'Refreshed materialized view "%"."%" in %',usr_schema,r.mv_name,stop_timestamp-start_timestamp;
	END LOOP;

	f_stop_timestamp := clock_timestamp();
	RAISE NOTICE 'All layers in usr_schema "%" associated to cdb_schema "%" refreshed', usr_schema, cdb_schema;
	EXCEPTION
		WHEN QUERY_CANCELED THEN
			RAISE EXCEPTION 'qgis_pkg.refresh_layers_ng_building(): Error QUERY_CANCELED';
		WHEN OTHERS THEN 
			RAISE NOTICE 'qgis_pkg.refresh_layers_ng_building(): %',SQLERRM;
END;
$$ LANGUAGE plpgsql;
COMMENT ON FUNCTION qgis_pkg.refresh_layers_ng_building(varchar,varchar) IS 'Refresh ng_building layers';
REVOKE EXECUTE ON FUNCTION qgis_pkg.refresh_layers_ng_building(varchar,varchar) FROM public;

---------------------------------------------------------------------
-- CREATE FUNCTION qgis_pkg.refresh_layers_ng_weatherstation
---------------------------------------------------------------------

DROP FUNCTION IF EXISTS qgis_pkg.refresh_layers_ng_weatherstation(varchar,varchar) CASCADE;
CREATE OR REPLACE FUNCTION qgis_pkg.refresh_layers_ng_weatherstation(usr_schema varchar,cdb_schema varchar) 
RETURNS void AS $$
DECLARE 
	usr_schemas_array CONSTANT varchar[] := (SELECT array_agg(s.usr_schema) FROM qgis_pkg.list_usr_schemas() AS s);
	cdb_schemas_array CONSTANT varchar[] := (SELECT array_agg(d.cdb_schema) FROM qgis_pkg.list_cdb_schemas() AS d);
	feat_type_prefix  varchar;
	start_timestamp   timestamptz(3);
	stop_timestamp    timestamptz(3);
	f_start_timestamp timestamptz(3);
	f_stop_timestamp  timestamptz(3);
	mv_n_features     integer DEFAULT 0;
	r                 RECORD;
BEGIN
	IF usr_schema IS NULL OR NOT(usr_schema = ANY(usr_schemas_array)) THEN
		RAISE EXCEPTION 'usr_schema must correspond to an existing usr_schema';
	END IF;

	IF cdb_schema IS NULL OR NOT(cdb_schema = ANY(cdb_schemas_array)) THEN
		RAISE EXCEPTION 'cdb_schema must correspond to an existing cdb_schema';
	END IF;

	FOR r IN
		SELECT mv.matviewname AS mv_name 
		FROM pg_matviews AS mv
		WHERE
			mv.schemaname = usr_schema AND
			mv.matviewname LIKE concat('%',cdb_schema,'%ng_weather%')
	LOOP
		start_timestamp := clock_timestamp();
		EXECUTE format('REFRESH MATERIALIZED VIEW %I.%I',usr_schema,r.mv_name);
		stop_timestamp := clock_timestamp();
		EXECUTE format('SELECT COUNT(co_id) FROM %I.%I',usr_schema,r.mv_name) INTO mv_n_features;
		EXECUTE format('UPDATE %I.layer_metadata AS lm SET n_features = %L, refresh_date = %L WHERE lm.cdb_schema = %L AND lm.gv_name = %L;',
        			usr_schema, mv_n_features, stop_timestamp, cdb_schema, r.mv_name);
		RAISE NOTICE 'Refreshed materialized view "%"."%" in %',usr_schema,r.mv_name,stop_timestamp-start_timestamp;
	END LOOP;

	f_stop_timestamp := clock_timestamp();
	RAISE NOTICE 'All layers in usr_schema "%" associated to cdb_schema "%" refreshed', usr_schema, cdb_schema;
	EXCEPTION
		WHEN QUERY_CANCELED THEN
			RAISE EXCEPTION 'qgis_pkg.refresh_layers_ng_weatherstation(): Error QUERY_CANCELED';
		WHEN OTHERS THEN 
			RAISE NOTICE 'qgis_pkg.refresh_layers_ng_weatherstation(): %',SQLERRM;
END;
$$ LANGUAGE plpgsql;
COMMENT ON FUNCTION qgis_pkg.refresh_layers_ng_weatherstation(varchar,varchar) IS 'Refresh WeatherStation layers';
REVOKE EXECUTE ON FUNCTION qgis_pkg.refresh_layers_ng_weatherstation(varchar,varchar) FROM public;

---------------------------------------------------------------------
-- CREATE FUNCTION qgis_pkg.generate_sql_drop_vector_layers
---------------------------------------------------------------------

DROP FUNCTION IF EXISTS qgis_pkg.generate_sql_drop_vector_layers(varchar,varchar,varchar) CASCADE;
CREATE OR REPLACE FUNCTION qgis_pkg.generate_sql_drop_vector_layers(usr_schema varchar,cdb_schema varchar,feature_type varchar)
RETURNS text AS $$
DECLARE
	layer_type CONSTANT varchar := 'VectorLayer';
	usr_schemas_array CONSTANT varchar[] := (SELECT array_agg(s.usr_schema) FROM qgis_pkg.list_usr_schemas() AS s);
	cdb_schemas_array CONSTANT varchar[] := (SELECT array_agg(d.cdb_schema) FROM qgis_pkg.list_cdb_schemas() AS d);
	sql_statement text := NULL;
	r RECORD;
BEGIN
	IF usr_schema IS NULL OR NOT(usr_schema = ANY(usr_schemas_array)) THEN
		RAISE EXCEPTION 'usr_schema value must correspond to an existing usr_schema';
	END IF;

	IF cdb_schema IS NULL OR NOT(cdb_schema = ANY(cdb_schemas_array)) THEN
		RAISE EXCEPTION 'cdb_schema must correspond to an existing cdb_schema';
	END IF;

	FOR r IN
		EXECUTE format('
		       SELECT gv_name FROM %I.layer_metadata as lm	
		       WHERE lm.feature_type = $1
		       AND lm.cdb_schema = $2'
		       ,usr_schema) USING feature_type,cdb_schema	
	LOOP
		sql_statement := concat(sql_statement,format('
				DROP MATERIALIZED VIEW IF EXISTS %I.%I CASCADE;',
				usr_schema,r.gv_name)
		);
	END LOOP;

	IF sql_statement IS NOT NULL THEN
		sql_statement := concat(sql_statement,format('
				DELETE FROM %I.layer_metadata AS l
				WHERE
					l.cdb_schema = %L AND
					l.feature_type = %L;
				WITH m AS (
					SELECT MAX(id) AS max_id 
					FROM %I.layer_metadata)
				SELECT setval(''%I.layer_metadata_id_seq''::regclass,m.max_id,TRUE) FROM m;',
				usr_schema,cdb_schema,feature_type,usr_schema,usr_schema));
	END IF;


	RETURN sql_statement;
	EXCEPTION
		WHEN QUERY_CANCELED THEN
			RAISE EXCEPTION 'qgis_pkg.generate_sql_drop_vector_layers(): Error QUERY_CANCELED';
		WHEN OTHERS THEN
			RAISE NOTICE 'qgis_pkg.generate_sql_drop_vector_layers(): %',SQLERRM;
END;
$$ LANGUAGE plpgsql;
COMMENT ON FUNCTION qgis_pkg.generate_sql_drop_vector_layers(varchar,varchar,varchar) IS 'Generate sql to drop all vector layers';
REVOKE EXECUTE ON FUNCTION qgis_pkg.generate_sql_drop_vector_layers(varchar,varchar,varchar) FROM public;

---------------------------------------------------------------------
-- CREATE FUNCTION qgis_pkg.generate_sql_drop_detail_views_nogeom
---------------------------------------------------------------------

DROP FUNCTION IF EXISTS qgis_pkg.generate_sql_drop_detail_views_nogeom(varchar,varchar,varchar) CASCADE;
CREATE OR REPLACE FUNCTION qgis_pkg.generate_sql_drop_detail_views_nogeom(usr_schema varchar,cdb_schema varchar,classname varchar)
RETURNS text AS $$
DECLARE
	usr_schemas_array CONSTANT varchar[] := (SELECT array_agg(s.usr_schema) FROM qgis_pkg.list_usr_schemas() AS s);
	cdb_schemas_array CONSTANT varchar[] := (SELECT array_agg(d.cdb_schema) FROM qgis_pkg.list_cdb_schemas() AS d);
	sql_statement text := NULL;
	r RECORD;
	
BEGIN
	IF usr_schema IS NULL OR NOT(usr_schema = ANY(usr_schemas_array)) THEN
		RAISE EXCEPTION 'usr_schema value must correspond to an existing usr_schema';
	END IF;

	IF cdb_schema IS NULL OR NOT(cdb_schema = ANY(cdb_schemas_array)) THEN
		RAISE EXCEPTION 'cdb_schema must correspond to an existing cdb_schema';
	END IF;
	
	FOR r IN
		EXECUTE format('
		       SELECT layer_name FROM %I.layer_metadata as lm	
		       WHERE lm.class = $1
		       AND lm.cdb_schema = $2'
		       ,usr_schema) USING classname,cdb_schema	
	LOOP
		sql_statement := concat(sql_statement,format('
				DROP VIEW %I.%I CASCADE;',
				usr_schema,r.layer_name)
		);
		
	END LOOP;
	RAISE NOTICE '%',sql_statement;
	IF sql_statement IS NOT NULL THEN
		sql_statement := concat(sql_statement,format('
				DELETE FROM %I.layer_metadata AS l
				WHERE
					l.cdb_schema = %L AND
					l.class = %L; 
				WITH m AS (
					SELECT MAX(id) AS max_id 
					FROM %I.layer_metadata)
				SELECT setval(''%I.layer_metadata_id_seq''::regclass,m.max_id,TRUE) FROM m;',
				usr_schema,cdb_schema,classname,usr_schema,usr_schema));
	END IF;
	
	RETURN sql_statement;
	EXCEPTION
		WHEN QUERY_CANCELED THEN
			RAISE EXCEPTION 'qgis_pkg.generate_sql_drop_detail_views_nogeom(): Error QUERY_CANCELED';
		WHEN OTHERS THEN
			RAISE NOTICE 'qgis_pkg.generate_sql_drop_detail_views_nogeom(): %',SQLERRM;
END;
$$ LANGUAGE plpgsql;
COMMENT ON FUNCTION qgis_pkg.generate_sql_drop_detail_views_nogeom(varchar,varchar,varchar) IS 'Generate sql to drop detail views';
REVOKE EXECUTE ON FUNCTION qgis_pkg.generate_sql_drop_detail_views_nogeom(varchar,varchar,varchar) FROM public;


---------------------------------------------------------------------
-- CREATE FUNCTION qgis_pkg.generate_sql_drop_detail_views_geom
---------------------------------------------------------------------

DROP FUNCTION IF EXISTS qgis_pkg.generate_sql_drop_detail_views_geom(varchar,varchar,varchar) CASCADE;
CREATE OR REPLACE FUNCTION qgis_pkg.generate_sql_drop_detail_views_geom(usr_schema varchar,cdb_schema varchar,classname varchar)
RETURNS text AS $$
DECLARE
	layer_type CONSTANT varchar := 'DetailViewGeom';
	usr_schemas_array CONSTANT varchar[] := (SELECT array_agg(s.usr_schema) FROM qgis_pkg.list_usr_schemas() AS s);
	cdb_schemas_array CONSTANT varchar[] := (SELECT array_agg(d.cdb_schema) FROM qgis_pkg.list_cdb_schemas() AS d);
	sql_statement text := NULL;
	r RECORD;
BEGIN
	IF usr_schema IS NULL OR NOT(usr_schema = ANY(usr_schemas_array)) THEN
		RAISE EXCEPTION 'usr_schema value must correspond to an existing usr_schema';
	END IF;

	IF cdb_schema IS NULL OR NOT(cdb_schema = ANY(cdb_schemas_array)) THEN
		RAISE EXCEPTION 'cdb_schema must correspond to an existing cdb_schema';
	END IF;

	FOR r IN
		EXECUTE format('
		       SELECT gv_name FROM %I.layer_metadata as lm	
		       WHERE lm.class = $1
		       AND lm.cdb_schema = $2'
		       ,usr_schema) USING classname,cdb_schema	
	LOOP
		sql_statement := concat(sql_statement,format('
				DROP MATERIALIZED VIEW %I.%I CASCADE;',
				usr_schema,r.gv_name)
		);
	END LOOP;

	IF sql_statement IS NOT NULL THEN
		sql_statement := concat(sql_statement,format('
				DELETE FROM %I.layer_metadata AS l
				WHERE
					l.cdb_schema = %L AND
					l.class = %L;
				WITH m AS (
					SELECT MAX(id) AS max_id 
					FROM %I.layer_metadata)
				SELECT setval(''%I.layer_metadata_id_seq''::regclass,m.max_id,TRUE) FROM m;',
				usr_schema,cdb_schema,classname,usr_schema,usr_schema));
	END IF;


	RETURN sql_statement;
	EXCEPTION
		WHEN QUERY_CANCELED THEN
			RAISE EXCEPTION 'qgis_pkg.generate_sql_drop_detail_views_geom(): Error QUERY_CANCELED';
		WHEN OTHERS THEN
			RAISE NOTICE 'qgis_pkg.generate_sql_drop_detail_views_geom(): %',SQLERRM;
END;
$$ LANGUAGE plpgsql;
COMMENT ON FUNCTION qgis_pkg.generate_sql_drop_detail_views_geom(varchar,varchar,varchar) IS 'Generate sql to drop all vector layers';
REVOKE EXECUTE ON FUNCTION qgis_pkg.generate_sql_drop_detail_views_geom(varchar,varchar,varchar) FROM public;


---------------------------------------------------------------------
-- CREATE FUNCTION qgis_pkg.generate_sql_drop_vector_layer_nogeom
---------------------------------------------------------------------

DROP FUNCTION IF EXISTS qgis_pkg.generate_sql_drop_vector_layer_nogeom(varchar,varchar,varchar) CASCADE;
CREATE OR REPLACE FUNCTION qgis_pkg.generate_sql_drop_vector_layer_nogeom(usr_schema varchar,cdb_schema varchar,classname varchar)
RETURNS text AS $$
DECLARE
	usr_schemas_array CONSTANT varchar[] := (SELECT array_agg(s.usr_schema) FROM qgis_pkg.list_usr_schemas() AS s);
	cdb_schemas_array CONSTANT varchar[] := (SELECT array_agg(d.cdb_schema) FROM qgis_pkg.list_cdb_schemas() AS d);
	sql_statement text := NULL;
	r RECORD;
	
BEGIN
	IF usr_schema IS NULL OR NOT(usr_schema = ANY(usr_schemas_array)) THEN
		RAISE EXCEPTION 'usr_schema value must correspond to an existing usr_schema';
	END IF;

	IF cdb_schema IS NULL OR NOT(cdb_schema = ANY(cdb_schemas_array)) THEN
		RAISE EXCEPTION 'cdb_schema must correspond to an existing cdb_schema';
	END IF;
	
	FOR r IN
		EXECUTE format('
		       SELECT layer_name FROM %I.layer_metadata as lm	
		       WHERE lm.class = $1
		       AND lm.cdb_schema = $2'
		       ,usr_schema) USING classname,cdb_schema	
	LOOP
		sql_statement := concat(sql_statement,format('
				DROP VIEW IF EXISTS %I.%I CASCADE;',
				usr_schema,r.layer_name)
		);
		
	END LOOP;
	RAISE NOTICE '%',sql_statement;
	IF sql_statement IS NOT NULL THEN
		sql_statement := concat(sql_statement,format('
				DELETE FROM %I.layer_metadata AS l
				WHERE
					l.cdb_schema = %L AND
					l.class = %L; 
				WITH m AS (
					SELECT MAX(id) AS max_id 
					FROM %I.layer_metadata)
				SELECT setval(''%I.layer_metadata_id_seq''::regclass,m.max_id,TRUE) FROM m;',
				usr_schema,cdb_schema,classname,usr_schema,usr_schema));
	END IF;
	
	RETURN sql_statement;
	EXCEPTION
		WHEN QUERY_CANCELED THEN
			RAISE EXCEPTION 'qgis_pkg.generate_sql_drop_vector_layer_nogeom(): Error QUERY_CANCELED';
		WHEN OTHERS THEN
			RAISE NOTICE 'qgis_pkg.generate_sql_drop_vector_layer_nogeom(): %',SQLERRM;
END;
$$ LANGUAGE plpgsql;
COMMENT ON FUNCTION qgis_pkg.generate_sql_drop_vector_layer_nogeom(varchar,varchar,varchar) IS 'Generate sql to drop detail views';
REVOKE EXECUTE ON FUNCTION qgis_pkg.generate_sql_drop_vector_layer_nogeom(varchar,varchar,varchar) FROM public;

---------------------------------------------------------------------
-- CREATE FUNCTION qgis_pkg.drop_ng_layers
---------------------------------------------------------------------

DROP FUNCTION IF EXISTS qgis_pkg.drop_ng_layers(varchar,varchar) CASCADE;
CREATE OR REPLACE FUNCTION qgis_pkg.drop_ng_layers(usr_schema varchar,cdb_schema varchar)
RETURNS void AS $$
DECLARE
	sql_statement text := NULL;
	f RECORD;
	g RECORD;
	h RECORD;
	i RECORD;
BEGIN
	FOR h IN
		SELECT * FROM (VALUES
			('Facilities'::varchar),
			('UsageZone'::varchar),
			('Occupants'::varchar)
		) AS t(class_name)
	LOOP
		sql_statement := qgis_pkg.generate_sql_drop_vector_layer_nogeom(usr_schema,cdb_schema,h.class_name);
		RAISE NOTICE '%',sql_statement;
		IF sql_statement IS NOT NULL THEN
			EXECUTE sql_statement;
		END IF;
	END LOOP;
	
	FOR g IN
		SELECT * FROM (VALUES
			('RegularTimeSeries'::varchar),
			('RegularTimeSeriesFile'::varchar),
			('DailySchedule'::varchar),
			('PeriodOfYear'::varchar),
			('EnergyDemand'::varchar),
			('Occupants'::varchar),
			('Construction'::varchar),
			('Reflectance'::varchar),
			('OpticalProperties'::varchar),
			('VolumeType'::varchar),
			('Transmittance'::varchar),
			('HeightAboveGround'::varchar),
			('HeatExchangeType'::varchar),
			('Layer'::varchar),
			('LayerComponent'::varchar),
			('Gas'::varchar),
			('SolidMaterial'::varchar),
			('FloorArea'::varchar),
			('TimeValuesProperties'::varchar)
		) AS t(class_name)
	LOOP
		sql_statement := qgis_pkg.generate_sql_drop_detail_views_nogeom(usr_schema,cdb_schema,g.class_name);
		RAISE NOTICE '%',sql_statement;

		IF sql_statement IS NOT NULL THEN
			EXECUTE sql_statement;
		END IF;

	END LOOP;

	FOR i IN
		SELECT * FROM (VALUES
			('WeatherData'::varchar)
		) AS t(class_name)
	LOOP
		sql_statement := qgis_pkg.generate_sql_drop_detail_views_geom(usr_schema,cdb_schema,i.class_name);
		RAISE NOTICE '%',sql_statement;
		IF sql_statement IS NOT NULL THEN
			EXECUTE sql_statement;
		END IF;
	END LOOP;

	FOR f IN
                SELECT * FROM (VALUES
                        ('Building'::varchar),
                        ('WeatherStation'::varchar)
                ) AS t(ftype)
        LOOP
                sql_statement := qgis_pkg.generate_sql_drop_vector_layers(usr_schema,cdb_schema,f.ftype);
                RAISE NOTICE '%',sql_statement;
                IF sql_statement IS NOT NULL THEN
                        EXECUTE sql_statement;
                END IF;
        END LOOP;

	
	EXCEPTION
		WHEN QUERY_CANCELED THEN
			RAISE EXCEPTION 'qgis_pkg.drop_ng_layers(): Error QUERY_CANCELED';
		WHEN OTHERS THEN
			RAISE NOTICE 'qgis_pkg.drop_ng_layers(): %',SQLERRM;
END;
$$ LANGUAGE plpgsql;
COMMENT ON FUNCTION qgis_pkg.drop_ng_layers(varchar,varchar) IS 'Drop all layers';
REVOKE EXECUTE ON FUNCTION qgis_pkg.drop_ng_layers(varchar,varchar) FROM public;

---------------------------------------------------------------------
-- CREATE FUNCTION qgis_pkg.drop_vector_layers
---------------------------------------------------------------------
DROP FUNCTION IF EXISTS qgis_pkg.drop_vector_layers(varchar,varchar) CASCADE;
CREATE OR REPLACE FUNCTION qgis_pkg.drop_vector_layers(usr_schema varchar,cdb_schema varchar)
RETURNS void AS $$
DECLARE
	h RECORD;
	sql_statement text := NULL;
	ql_lname varchar;
BEGIN
	FOR h in
		EXECUTE format('SELECT gv_name FROM %I.layer_metadata
				WHERE layer_type = $1
				AND cdb_schema = $2',usr_schema)
				USING 'VectorLayer',cdb_schema

	LOOP
		
		sql_statement := concat(sql_statement,format('
				DROP MATERIALIZED VIEW IF EXISTS %I.%I CASCADE;
				DELETE FROM %I.layer_metadata
				WHERE gv_name = %L',
				usr_schema,h.gv_name,usr_schema,h.gv_name));
		RAISE NOTICE '%',sql_statement;
		IF sql_statement IS NOT NULL
			THEN EXECUTE sql_statement;
		END IF;
		sql_statement := NULL;
		
	END LOOP;
	EXCEPTION
		WHEN QUERY_CANCELED THEN
			RAISE EXCEPTION 'qgis_pkg.drop_vector_layers(): Error QUERY_CANCELED';
		WHEN OTHERS THEN
			RAISE NOTICE 'qgis_pkg.drop_vector_layers(): %',SQLERRM;
END;
$$ LANGUAGE plpgsql;
COMMENT ON FUNCTION qgis_pkg.drop_vector_layers(varchar,varchar) IS 'Drop all layer of type VectorLayerNoGeom';
REVOKE EXECUTE ON FUNCTION qgis_pkg.drop_vector_layers(varchar,varchar) FROM public;

---------------------------------------------------------------------
-- CREATE FUNCTION qgis_pkg.drop_vector_layers_no_geom
---------------------------------------------------------------------
DROP FUNCTION IF EXISTS qgis_pkg.drop_vector_layers_no_geom(varchar,varchar) CASCADE;
CREATE OR REPLACE FUNCTION qgis_pkg.drop_vector_layers_no_geom(usr_schema varchar,cdb_schema varchar)
RETURNS void AS $$
DECLARE
	h RECORD;
	sql_statement text := NULL;
	ql_lname varchar;
BEGIN
	FOR h in
		EXECUTE format('SELECT layer_name FROM %I.layer_metadata
				WHERE layer_type = $1
				AND cdb_schema = $2',usr_schema)
				USING 'VectorLayerNoGeom',cdb_schema

	LOOP
	
		sql_statement := concat(sql_statement,format('
				DROP VIEW IF EXISTS %I.%I CASCADE;
				DELETE FROM %I.layer_metadata
				WHERE layer_name = %L',
				usr_schema,h.layer_name,usr_schema,h.layer_name));
		RAISE NOTICE '%',sql_statement;
		IF sql_statement IS NOT NULL
			THEN EXECUTE sql_statement;
		END IF;
		sql_statement := NULL;
		
	END LOOP;
	EXCEPTION
		WHEN QUERY_CANCELED THEN
			RAISE EXCEPTION 'qgis_pkg.drop_vector_layers_no_geom(): Error QUERY_CANCELED';
		WHEN OTHERS THEN
			RAISE NOTICE 'qgis_pkg.drop_vector_layers_no_geom(): %',SQLERRM;
END;
$$ LANGUAGE plpgsql;
COMMENT ON FUNCTION qgis_pkg.drop_vector_layers_no_geom(varchar,varchar) IS 'Drop all layer of type VectorLayerNoGeom';
REVOKE EXECUTE ON FUNCTION qgis_pkg.drop_vector_layers_no_geom(varchar,varchar) FROM public;

---------------------------------------------------------------------
-- CREATE FUNCTION qgis_pkg.drop_detail_views_geom
---------------------------------------------------------------------
DROP FUNCTION IF EXISTS qgis_pkg.drop_detail_views_geom(varchar,varchar) CASCADE;
CREATE OR REPLACE FUNCTION qgis_pkg.drop_detail_views_geom(usr_schema varchar,cdb_schema varchar)
RETURNS void AS $$
DECLARE
	h RECORD;
	sql_statement text := NULL;
	ql_lname varchar;
BEGIN
	FOR h in
		EXECUTE format('SELECT gv_name FROM %I.layer_metadata
				WHERE layer_type = $1
				AND cdb_schema = $2',usr_schema)
				USING 'DetailViewGeom',cdb_schema

	LOOP
	
		sql_statement := concat(sql_statement,format('
				DROP MATERIALIZED VIEW IF EXISTS %I.%I CASCADE;
				DELETE FROM %I.layer_metadata
				WHERE gv_name = %L',
				usr_schema,h.gv_name,usr_schema,h.gv_name));
		RAISE NOTICE '%',sql_statement;
		IF sql_statement IS NOT NULL
			THEN EXECUTE sql_statement;
		END IF;
		sql_statement := NULL;
		
	END LOOP;
	EXCEPTION
		WHEN QUERY_CANCELED THEN
			RAISE EXCEPTION 'qgis_pkg.drop_detail_views_geom(): Error QUERY_CANCELED';
		WHEN OTHERS THEN
			RAISE NOTICE 'qgis_pkg.drop_detail_views_geom(): %',SQLERRM;
END;
$$ LANGUAGE plpgsql;
COMMENT ON FUNCTION qgis_pkg.drop_detail_views_geom(varchar,varchar) IS 'Drop all layer of type DetailViewGeom';
REVOKE EXECUTE ON FUNCTION qgis_pkg.drop_detail_views_geom(varchar,varchar) FROM public;

---------------------------------------------------------------------
-- CREATE FUNCTION qgis_pkg.drop_detail_views_no_geom
---------------------------------------------------------------------
DROP FUNCTION IF EXISTS qgis_pkg.drop_detail_views_no_geom(varchar,varchar) CASCADE;
CREATE OR REPLACE FUNCTION qgis_pkg.drop_detail_views_no_geom(usr_schema varchar,cdb_schema varchar)
RETURNS void AS $$
DECLARE
	h RECORD;
	sql_statement text := NULL;
	ql_lname varchar;
BEGIN
	FOR h in
		EXECUTE format('SELECT layer_name FROM %I.layer_metadata
				WHERE layer_type = $1
				AND cdb_schema = $2',usr_schema)
				USING 'DetailViewNoGeom',cdb_schema

	LOOP
	
		sql_statement := concat(sql_statement,format('
				DROP VIEW IF EXISTS %I.%I CASCADE;
				DELETE FROM %I.layer_metadata
				WHERE layer_name = %L',
				usr_schema,h.layer_name,usr_schema,h.layer_name));
		RAISE NOTICE '%',sql_statement;
		IF sql_statement IS NOT NULL
			THEN EXECUTE sql_statement;
		END IF;
		sql_statement := NULL;
		
	END LOOP;
	EXCEPTION
		WHEN QUERY_CANCELED THEN
			RAISE EXCEPTION 'qgis_pkg.drop_detail_views_no_geom(): Error QUERY_CANCELED';
		WHEN OTHERS THEN
			RAISE NOTICE 'qgis_pkg.drop_detail_views_no_geom(): %',SQLERRM;
END;
$$ LANGUAGE plpgsql;
COMMENT ON FUNCTION qgis_pkg.drop_detail_views_no_geom(varchar,varchar) IS 'Drop all layer of type DetailViewGeom';
REVOKE EXECUTE ON FUNCTION qgis_pkg.drop_detail_views_no_geom(varchar,varchar) FROM public;


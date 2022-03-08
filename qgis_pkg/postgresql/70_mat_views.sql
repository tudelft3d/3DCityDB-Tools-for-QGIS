-- ****************************************************************************
-- ****************************************************************************
--
--
-- CREATE MATERIALIZED VIEWS for geometries
--
--
-- ****************************************************************************
-- ****************************************************************************

DO $MAINBODY$
DECLARE
BEGIN

----------------------------------------------------------------
-- Create FUNCTION QGIS_PKG.CREATE_MVIEWS
----------------------------------------------------------------
DROP FUNCTION IF EXISTS    qgis_pkg.create_mviews(varchar, integer, integer, numeric, geometry) CASCADE;
CREATE OR REPLACE FUNCTION qgis_pkg.create_mviews(
citydb_schema 		varchar DEFAULT 'citydb',
perform_snapping 	integer DEFAULT 0,
digits 				integer	DEFAULT 3,
area_poly_min 		numeric DEFAULT 0.0001,
mview_bbox			geometry DEFAULT NULL
) 
RETURNS integer AS $$

DECLARE
srid_id integer; 
mview_bbox_srid integer := ST_SRID(mview_bbox);
mview_bbox_xmin numeric;
mview_bbox_ymin numeric;
mview_bbox_xmax numeric;
mview_bbox_ymax numeric;
r 				RECORD;
s 				RECORD;
t 				RECORD;
u 				RECORD;
l_name 			varchar;
view_name 		varchar;
mview_name 		varchar;
mview_idx_name 	varchar;
mview_spx_name 	varchar;
sql_statement 	varchar;
sql_where 		varchar;
feature_type 	varchar;
qml_file_name 	varchar;
citydb_envelope geometry(Polygon);

BEGIN
RAISE NOTICE 'Creating materialized views';
EXECUTE format('SELECT srid FROM citydb.database_srs LIMIT 1') INTO srid_id;
--RAISE NOTICE 'Srid is: %', srid_id;

-- Delete all existing materialized views for the selected citydb schema
--sql_statement := concat('DELETE FROM qgis_pkg.layer_metadata;');
sql_statement := concat('DELETE FROM qgis_pkg.layer_metadata WHERE schema_name = ''',citydb_schema,''';');
EXECUTE sql_statement;
--EXECUTE format('DELETE FROM qgis_pkg.layer_metadata WHERE schema_name = %L',citydb_schema);

IF mview_bbox_srid IS NULL OR mview_bbox_srid <> srid_id THEN
	mview_bbox := NULL;
ELSE
	mview_bbox_xmin := floor(ST_XMin(mview_bbox));
	mview_bbox_ymin := floor(ST_YMin(mview_bbox));
	mview_bbox_xmax := ceil(ST_XMax(mview_bbox));
	mview_bbox_ymax := ceil(ST_YMax(mview_bbox));
	mview_bbox := ST_MakeEnvelope(mview_bbox_xmin, mview_bbox_ymin, mview_bbox_xmax, mview_bbox_ymax, srid_id);
END IF;

-- ***********************
-- BUILDING MODULE
-- ***********************
feature_type     := 'Building';

FOR r IN 
	SELECT * FROM (VALUES
	('Building'::varchar, 26::integer, 'bdg'::varchar),
	('BuildingPart'     , 25         , 'bdg_part')		   
	) AS t(class_name, class_id, class_label)
LOOP

---------------------------------------------------------------
-- Create MATERIALIZED VIEW QGIS_PKG._G_*_BUILDING(PART)_LOD0
---------------------------------------------------------------
l_name         := format(      '%I_lod0',           			   r.class_label);
view_name      := format(   '%I_%I_lod0',           citydb_schema, r.class_label);		
mview_name     := format('_g_%I_%I_lod0', 			citydb_schema, r.class_label);
mview_idx_name := format('_g_%I_%I_lod0_id_idx',    citydb_schema, r.class_label);
mview_spx_name := format('_g_%I_%I_lod0_geom_spx',  citydb_schema, r.class_label);
qml_file_name  := concat(r.class_label,'_form.qml');

IF mview_bbox IS NOT NULL THEN
	sql_where := concat('AND ST_MakeEnvelope(',mview_bbox_xmin,', ',mview_bbox_ymin,', ',mview_bbox_xmax,', ',mview_bbox_ymax,', ',srid_id,') && co.envelope');
ELSE
	sql_where := NULL;
END IF;

sql_statement := concat('
DROP MATERIALIZED VIEW IF EXISTS qgis_pkg.',mview_name,' CASCADE;
CREATE MATERIALIZED VIEW         qgis_pkg.',mview_name,' AS
	SELECT
		sg.cityobject_id::bigint AS co_id,
		ST_Collect(qgis_pkg.ST_snap_poly_to_grid(sg.geometry,',perform_snapping,',',digits,',',area_poly_min,'))::geometry(MultiPolygonZ, ',srid_id,') AS geom	
	FROM (
		SELECT
			b1.lod0_footprint_id AS sg_id
		FROM
			',citydb_schema,'.building AS b1
			INNER JOIN ',citydb_schema,'.cityobject AS co ON (co.id = b1.id AND b1.objectclass_id = ',r.class_id,' ',sql_where,')
		UNION
		SELECT
			b2.lod0_roofprint_id AS sg_id
		FROM
			',citydb_schema,'.building AS b2
			INNER JOIN ',citydb_schema,'.cityobject AS co ON (co.id = b2.id AND b2.objectclass_id = ',r.class_id,' ',sql_where,')
		) AS b
		INNER JOIN ',citydb_schema,'.surface_geometry AS sg ON (sg.root_id = b.sg_id AND sg.geometry IS NOT NULL)
	GROUP BY sg.cityobject_id
WITH NO DATA;
COMMENT ON MATERIALIZED VIEW qgis_pkg.',mview_name,' IS ''Mat. view of ',r.class_name,' LoD0 in schema ',citydb_schema,''';
CREATE INDEX ',mview_idx_name,' ON qgis_pkg.',mview_name,' (co_id);
CREATE INDEX ',mview_spx_name,' ON qgis_pkg.',mview_name,' USING gist (geom);
DELETE FROM qgis_pkg.layer_metadata WHERE v_name = ''',view_name,''';
INSERT INTO qgis_pkg.layer_metadata (schema_name, feature_type, qml_file, lod, root_class, layer_name, creation_date, mv_name, v_name) VALUES
(''',citydb_schema,''',''',feature_type,''',''',qml_file_name,''',''lod0'',''',r.class_name,''',''',l_name,''',clock_timestamp(),''',mview_name,''',''',view_name,''');
');
EXECUTE sql_statement;

---------------------------------------------------------------
-- Create MATERIALIZED VIEW QGIS_PKG._G_*_BUILDING(PART)_LOD0_FOOTPRINT/ROOFEDGE
---------------------------------------------------------------
	FOR s IN 
		SELECT * FROM (VALUES
		('footprint'::varchar, 'footprint'::varchar),
		('roofedge'          , 'roofprint')		   
		) AS t(themsurf_name, themsurf_label)
	LOOP

l_name         := format(      '%I_lod0_%I',							r.class_label, s.themsurf_name);
view_name      := format(   '%I_%I_lod0_%I',			citydb_schema, r.class_label, s.themsurf_name);
mview_name     := format('_g_%I_%I_lod0_%I',			citydb_schema, r.class_label, s.themsurf_name);
mview_idx_name := format('_g_%I_%I_lod0_%I_id_idx',		citydb_schema, r.class_label, s.themsurf_name);
mview_spx_name := format('_g_%I_%I_lod0_%I_geom_spx',	citydb_schema, r.class_label, s.themsurf_name);
qml_file_name  := concat(r.class_label,'_form.qml');

IF mview_bbox IS NOT NULL THEN
	sql_where := concat('AND ST_MakeEnvelope(',mview_bbox_xmin,', ',mview_bbox_ymin,', ',mview_bbox_xmax,', ',mview_bbox_ymax,', ',srid_id,') && co.envelope');
ELSE
	sql_where := NULL;
END IF;

sql_statement := concat('
DROP MATERIALIZED VIEW IF EXISTS qgis_pkg.',mview_name,' CASCADE;
CREATE MATERIALIZED VIEW         qgis_pkg.',mview_name,' AS
	SELECT
		sg.cityobject_id::bigint AS co_id,
		ST_Collect(qgis_pkg.ST_snap_poly_to_grid(sg.geometry,',perform_snapping,',',digits,',',area_poly_min,'))::geometry(MultiPolygonZ, ',srid_id,') AS geom	
	FROM
		',citydb_schema,'.building AS o
		INNER JOIN ',citydb_schema,'.cityobject AS co ON (o.id = co.id AND o.objectclass_id = ',r.class_id,' ',sql_where,') 
		INNER JOIN ',citydb_schema,'.surface_geometry AS sg ON (sg.root_id = o.lod0_',s.themsurf_label,'_id AND sg.geometry IS NOT NULL)
	GROUP BY sg.cityobject_id
WITH NO DATA;
COMMENT ON MATERIALIZED VIEW qgis_pkg.',mview_name,' IS ''Mat. view of ',r.class_name,' LoD0 ',s.themsurf_name,' in schema ',citydb_schema,''';
CREATE INDEX ',mview_idx_name,' ON qgis_pkg.',mview_name,' (co_id);
CREATE INDEX ',mview_spx_name,' ON qgis_pkg.',mview_name,' USING gist (geom);
DELETE FROM qgis_pkg.layer_metadata WHERE v_name = ''',view_name,''';
INSERT INTO qgis_pkg.layer_metadata (schema_name, feature_type, qml_file, lod, root_class, layer_name, creation_date, mv_name, v_name) VALUES
(''',citydb_schema,''',''',feature_type,''',''',qml_file_name,''',''lod0'',''',r.class_name,''',''',l_name,''',clock_timestamp(),''',mview_name,''',''',view_name,''');
');
EXECUTE sql_statement;

	END LOOP; -- bdg lod0 foot/roofprint

---------------------------------------------------------------
-- Create MATERIALIZED VIEW QGIS_PKG._G_*_BUILDING(PART)_LOD1
---------------------------------------------------------------
l_name         := format(      '%I_lod1',							r.class_label);
view_name      := format(   '%I_%I_lod1',			citydb_schema, r.class_label);
mview_name     := format('_g_%I_%I_lod1',			citydb_schema, r.class_label);
mview_idx_name := format('_g_%I_%I_lod1_id_idx',	citydb_schema, r.class_label);
mview_spx_name := format('_g_%I_%I_lod1_geom_spx',	citydb_schema, r.class_label);
qml_file_name  := concat(r.class_label,'_form.qml');

IF mview_bbox IS NOT NULL THEN
	sql_where := concat('AND ST_MakeEnvelope(',mview_bbox_xmin,', ',mview_bbox_ymin,', ',mview_bbox_xmax,', ',mview_bbox_ymax,', ',srid_id,') && co.envelope');
ELSE
	sql_where := NULL;
END IF;

sql_statement := concat('
DROP MATERIALIZED VIEW IF EXISTS qgis_pkg.',mview_name,' CASCADE;
CREATE MATERIALIZED VIEW         qgis_pkg.',mview_name,' AS
	SELECT
		sg.cityobject_id::bigint AS co_id,
		ST_Collect(qgis_pkg.ST_snap_poly_to_grid(sg.geometry,',perform_snapping,',',digits,',',area_poly_min,'))::geometry(MultiPolygonZ, ',srid_id,') AS geom	
	FROM (
		SELECT
			o.id AS co_id, 	
			CASE
				WHEN o.lod1_solid_id IS NOT NULL THEN o.lod1_solid_id
				ELSE o.lod1_multi_surface_id
			END	AS sg_id 
		FROM 
			',citydb_schema,'.building AS o
			INNER JOIN ',citydb_schema,'.cityobject AS co ON (o.id=co.id AND o.objectclass_id = ',r.class_id,' ',sql_where,') 
		WHERE			
			NOT(o.lod1_solid_id IS NULL AND o.lod1_multi_surface_id IS NULL)
		) AS foo
		INNER JOIN ',citydb_schema,'.surface_geometry AS sg ON (sg.root_id = foo.sg_id AND sg.geometry IS NOT NULL)
	GROUP BY sg.cityobject_id
WITH NO DATA;
COMMENT ON MATERIALIZED VIEW qgis_pkg.',mview_name,' IS ''Mat. view of ',r.class_name,' LoD1 in schema ',citydb_schema,''';
CREATE INDEX ',mview_idx_name,' ON qgis_pkg.',mview_name,' (co_id);
CREATE INDEX ',mview_spx_name,' ON qgis_pkg.',mview_name,' USING gist (geom);
DELETE FROM qgis_pkg.layer_metadata WHERE v_name = ''',view_name,''';
INSERT INTO qgis_pkg.layer_metadata (schema_name, feature_type, qml_file, lod, root_class, layer_name, creation_date, mv_name, v_name) VALUES
(''',citydb_schema,''',''',feature_type,''',''',qml_file_name,''',''lod1'',''',r.class_name,''',''',l_name,''',clock_timestamp(),''',mview_name,''',''',view_name,''');
');
EXECUTE sql_statement;

---------------------------------------------------------------
-- Create MATERIALIZED VIEW QGIS_PKG._G_*_BUILDING(PART)_LOD2-4
---------------------------------------------------------------
	FOR t IN 
		SELECT * FROM (VALUES
		('LoD2'::varchar, 'lod2'::varchar),
		('LoD3'			, 'lod3'),
		('LoD4'			, 'lod4')		
		) AS t(lodx_name, lodx_label)
	LOOP

l_name         := format(      '%I_%I',								r.class_label, t.lodx_label);
view_name      := format(   '%I_%I_%I',				citydb_schema, r.class_label, t.lodx_label);
mview_name     := format('_g_%I_%I_%I', 			citydb_schema, r.class_label, t.lodx_label);
mview_idx_name := format('_g_%I_%I_%I_id_idx',  	citydb_schema, r.class_label, t.lodx_label);
mview_spx_name := format('_g_%I_%I_%I_geom_spx',	citydb_schema, r.class_label, t.lodx_label);
qml_file_name  := concat(r.class_label,'_form.qml');

IF mview_bbox IS NOT NULL THEN
	sql_where := concat('AND ST_MakeEnvelope(',mview_bbox_xmin,', ',mview_bbox_ymin,', ',mview_bbox_xmax,', ',mview_bbox_ymax,', ',srid_id,') && co.envelope');
ELSE
	sql_where := NULL;
END IF;

sql_statement := concat('
DROP MATERIALIZED VIEW IF EXISTS qgis_pkg.',mview_name,' CASCADE;
CREATE MATERIALIZED VIEW         qgis_pkg.',mview_name,' AS
	SELECT
		foo2.co_id::bigint AS co_id,
		ST_Collect(qgis_pkg.ST_snap_poly_to_grid(sg.geometry,',perform_snapping,',',digits,',',area_poly_min,'))::geometry(MultiPolygonZ, ',srid_id,') AS geom	
	FROM (
		SELECT
			foo.co_id,
			unnest(foo.sg_id_array) AS sg_id
		FROM (
			SELECT
				-- coalesce(o.id, ts_t.co_id) as co_id,
				o.id AS co_id,
				CASE 
					WHEN ts_t.sg_id_array IS NOT NULL THEN ts_t.sg_id_array
					WHEN o.',t.lodx_label,'_solid_id IS NOT NULL THEN ARRAY[o.',t.lodx_label,'_solid_id]
					ELSE ARRAY[o.',t.lodx_label,'_multi_surface_id]
				END AS sg_id_array 
			FROM 
				',citydb_schema,'.building AS o
				INNER JOIN ',citydb_schema,'.cityobject AS co ON (o.id = co.id AND o.objectclass_id= ',r.class_id,' ',sql_where,')
				-- FULL OUTER JOIN
				INNER JOIN (
					SELECT ts.building_id AS co_id, array_agg(ts.',t.lodx_label,'_multi_surface_id) AS sg_id_array 
					FROM 
						',citydb_schema,'.thematic_surface AS ts
						INNER JOIN ',citydb_schema,'.cityobject AS co ON (co.id = ts.id ',sql_where,')
						INNER JOIN ',citydb_schema,'.building AS b1 ON (ts.building_id = b1.id AND b1.objectclass_id = ',r.class_id,')	
					GROUP BY ts.building_id
					) AS ts_t ON (ts_t.co_id = o.id)
			WHERE 
				sg_id_array IS NOT NULL
			) AS foo
		) AS foo2
		INNER JOIN ',citydb_schema,'.surface_geometry AS sg ON (sg.root_id = foo2.sg_id AND sg.geometry IS NOT NULL)
	GROUP BY foo2.co_id
WITH NO DATA;
COMMENT ON MATERIALIZED VIEW qgis_pkg.',mview_name,' IS ''Mat. view of ',r.class_name,' ',t.lodx_name,' in schema ',citydb_schema,''';
CREATE INDEX ',mview_idx_name,' ON qgis_pkg.',mview_name,' (co_id);
CREATE INDEX ',mview_spx_name,' ON qgis_pkg.',mview_name,' USING gist (geom);
DELETE FROM qgis_pkg.layer_metadata WHERE v_name = ''',view_name,''';
INSERT INTO qgis_pkg.layer_metadata (schema_name, feature_type, qml_file, lod, root_class, layer_name, creation_date, mv_name, v_name) VALUES
(''',citydb_schema,''',''',feature_type,''',''',qml_file_name,''',''',t.lodx_label,''',''',r.class_name,''',''',l_name,''',clock_timestamp(),''',mview_name,''',''',view_name,''');
');
EXECUTE sql_statement;

---------------------------------------------------------------
-- Create MATERIALIZED VIEW QGIS_PKG._G_*_BUILDING(PART)_LOD2-4_THEMATIC_SURFACES
---------------------------------------------------------------
		FOR u IN 
			SELECT * FROM (VALUES
			('BuildingRoofSurface'::varchar , 33::integer, 'roofsurf'::varchar),
			('BuildingWallSurface'			, 34		 , 'wallsurf'),
			('BuildingGroundSurface'		, 35		 , 'groundsurf'),
			('BuildingClosureSurface'		, 36		 , 'closuresurf'),
			('OuterBuildingCeilingSurface'	, 60		 , 'outerceilingsurf'),
			('OuterBuildingFloorSurface'	, 61		 , 'outerfloorsurf')
			) AS t(themsurf_name, class_id, themsurf_label)
		LOOP

l_name         := format(      '%I_%I_%I',							r.class_label, t.lodx_label, u.themsurf_label);
view_name      := format(   '%I_%I_%I_%I',			citydb_schema, r.class_label, t.lodx_label, u.themsurf_label);
mview_name     := format('_g_%I_%I_%I_%I', 			citydb_schema, r.class_label, t.lodx_label, u.themsurf_label);
mview_idx_name := format('_g_%I_%I_%I_%I_id_idx',   citydb_schema, r.class_label, t.lodx_label, u.themsurf_label);
mview_spx_name := format('_g_%I_%I_%I_%I_geom_spx',	citydb_schema, r.class_label, t.lodx_label, u.themsurf_label);
qml_file_name  := concat(r.class_label,'_them_surf_form.qml');

IF mview_bbox IS NOT NULL THEN
	sql_where := concat('AND ST_MakeEnvelope(',mview_bbox_xmin,', ',mview_bbox_ymin,', ',mview_bbox_xmax,', ',mview_bbox_ymax,', ',srid_id,') && co.envelope');
ELSE
	sql_where := NULL;
END IF;

sql_statement := concat('
DROP MATERIALIZED VIEW IF EXISTS qgis_pkg.',mview_name,' CASCADE;
CREATE MATERIALIZED VIEW         qgis_pkg.',mview_name,' AS
	SELECT
		sg.cityobject_id::bigint AS co_id,
		ST_Collect(qgis_pkg.ST_snap_poly_to_grid(sg.geometry,',perform_snapping,',',digits,',',area_poly_min,'))::geometry(MultiPolygonZ, ',srid_id,') AS geom
	FROM
		',citydb_schema,'.thematic_surface AS o
		INNER JOIN ',citydb_schema,'.cityobject AS co ON (o.id = co.id AND o.objectclass_id = ',u.class_id,' ',sql_where,')		
		INNER JOIN ',citydb_schema,'.building AS b ON (o.building_id = b.id AND b.objectclass_id = ',r.class_id,')
		INNER JOIN ',citydb_schema,'.surface_geometry AS sg ON (sg.root_id = o.',t.lodx_name,'_multi_surface_id AND sg.geometry IS NOT NULL)
	GROUP BY sg.cityobject_id
WITH NO DATA;
COMMENT ON MATERIALIZED VIEW qgis_pkg.',mview_name,' IS ''Mat. view of (',r.class_name,') ',t.lodx_name,' ',u.themsurf_name,' in schema ',citydb_schema,''';
CREATE INDEX ',mview_idx_name,' ON qgis_pkg.',mview_name,' (co_id);
CREATE INDEX ',mview_spx_name,' ON qgis_pkg.',mview_name,' USING gist (geom);
DELETE FROM qgis_pkg.layer_metadata WHERE v_name = ''',view_name,''';
INSERT INTO qgis_pkg.layer_metadata (schema_name, feature_type, qml_file, lod, root_class, layer_name, creation_date, mv_name, v_name) VALUES
(''',citydb_schema,''',''',feature_type,''',''',qml_file_name,''',''',t.lodx_label,''',''',r.class_name,''',''',l_name,''',clock_timestamp(),''',mview_name,''',''',view_name,''');
');
EXECUTE sql_statement;

		END LOOP; -- bdg thematic surface
	END LOOP; -- bdg lod2-4

---------------------------------------------------------------
-- Create MATERIALIZED VIEW QGIS_PKG._G_**_BUILDING_INSTALLATION_**_LOD2-4
---------------------------------------------------------------
	FOR s IN 
		SELECT * FROM (VALUES
		('BuildingInstallation'::varchar, 27::integer, 'out_inst'::varchar)
		) AS t(class_name, class_id, class_label)
	LOOP
		FOR t IN 
			SELECT * FROM (VALUES
			('LoD2'::varchar, 'lod2'::varchar),
			('LoD3'			, 'lod3'),
			('LoD4'			, 'lod4')		
			) AS t(lodx_name, lodx_label)
		LOOP
l_name         := format(      '%I_%I_%I',							r.class_label, s.class_label, t.lodx_label);
view_name      := format(   '%I_%I_%I_%I',			citydb_schema, r.class_label, s.class_label, t.lodx_label);
mview_name     := format('_g_%I_%I_%I_%I',			citydb_schema, r.class_label, s.class_label, t.lodx_label);
mview_idx_name := format('_g_%I_%I_%I_%I_id_idx',	citydb_schema, r.class_label, s.class_label, t.lodx_label);
mview_spx_name := format('_g_%I_%I_%I_%I_geom_spx',	citydb_schema, r.class_label, s.class_label, t.lodx_label);
qml_file_name  := concat(r.class_label,'_',s.class_label,'_form.qml');

IF mview_bbox IS NOT NULL THEN
	sql_where := concat('AND ST_MakeEnvelope(',mview_bbox_xmin,', ',mview_bbox_ymin,', ',mview_bbox_xmax,', ',mview_bbox_ymax,', ',srid_id,') && co.envelope');
ELSE
	sql_where := NULL;
END IF;

sql_statement := concat('
DROP MATERIALIZED VIEW IF EXISTS qgis_pkg.',mview_name,' CASCADE;
CREATE MATERIALIZED VIEW         qgis_pkg.',mview_name,' AS
	SELECT 
		foo2.co_id AS co_id,
		st_collect(qgis_pkg.ST_snap_poly_to_grid(sg.geometry,',perform_snapping,',',digits,',',area_poly_min,'))::geometry(MultiPolygonZ, ',srid_id,') AS geom
	FROM ( 
			SELECT 
				foo.co_id,
				unnest(foo.sg_id_array) AS sg_id
			FROM ( 
					SELECT
						o.id AS co_id,
						CASE
							WHEN ts_t.sg_id_array IS NOT NULL THEN ts_t.sg_id_array
							ELSE ARRAY[o.',t.lodx_label,'_brep_id]
						END AS sg_id_array
					FROM 
						',citydb_schema,'.building_installation AS o
						INNER JOIN ',citydb_schema,'.cityobject AS co ON (o.id = co.id AND o.objectclass_id = ',s.class_id,' ',sql_where,')
						INNER JOIN (
							SELECT
								o.building_installation_id AS co_id,
								array_agg(o.',t.lodx_label,'_multi_surface_id) AS sg_id_array
							FROM 
								',citydb_schema,'.thematic_surface AS o
								INNER JOIN ',citydb_schema,'.cityobject AS co ON (co.id = o.id ',sql_where,')
								INNER JOIN ',citydb_schema,'.building AS b ON (o.building_id = b.id AND b.objectclass_id = ',r.class_id,')
							WHERE 
								o.building_installation_id IS NOT NULL
							GROUP BY o.building_installation_id
						) AS ts_t ON (ts_t.co_id = o.id)
					WHERE
						o.',t.lodx_label,'_implicit_rep_id IS NULL
				) AS foo
	   ) AS foo2
	INNER JOIN ',citydb_schema,'.surface_geometry AS sg ON (sg.root_id = foo2.sg_id AND sg.geometry IS NOT NULL)
	GROUP BY foo2.co_id
	UNION');
-- the need to split is due to max 100 arguments allowed in the concat function.
sql_statement := concat(sql_statement,'	
	SELECT
		o.id::bigint AS co_id,
		ST_SetSRID(
			ST_Affine(ST_Collect(sg.implicit_geometry),
				   split_part(o.',t.lodx_label,'_implicit_transformation, '' '', 1)::double precision,
				   0,0,0,
				   split_part(o.',t.lodx_label,'_implicit_transformation, '' '', 6)::double precision,
				   0,0,0,
				   split_part(o.',t.lodx_label,'_implicit_transformation, '' '', 11)::double precision,
				   ST_X(o.',t.lodx_label,'_implicit_ref_point),
				   ST_Y(o.',t.lodx_label,'_implicit_ref_point),
				   ST_Z(o.',t.lodx_label,'_implicit_ref_point)
				   ),
			',srid_id,')::geometry(MultiPolygonZ, ',srid_id,') AS geom
	FROM 
		',citydb_schema,'.building_installation AS o
		INNER JOIN ',citydb_schema,'.cityobject AS co ON (o.id = co.id AND o.objectclass_id = ',s.class_id,' ',sql_where,')
		INNER JOIN ',citydb_schema,'.building AS b ON (b.id = o.building_id AND b.objectclass_id = ',r.class_id,')
		INNER JOIN ',citydb_schema,'.implicit_geometry AS ig ON (ig.id = o.',t.lodx_label,'_implicit_rep_id)
		INNER JOIN ',citydb_schema,'.surface_geometry AS sg ON (sg.root_id = ig.relative_brep_id AND sg.implicit_geometry IS NOT NULL)
	WHERE
		o.',t.lodx_label,'_implicit_rep_id IS NOT NULL
	GROUP BY o.id
WITH NO DATA;
COMMENT ON MATERIALIZED VIEW qgis_pkg.',mview_name,' IS ''Mat. view of ',s.class_name,' ',t.lodx_name,' in schema ',citydb_schema,''';
CREATE INDEX ',mview_idx_name,' ON qgis_pkg.',mview_name,' (co_id);
CREATE INDEX ',mview_spx_name,' ON qgis_pkg.',mview_name,' USING gist (geom);
DELETE FROM qgis_pkg.layer_metadata WHERE v_name = ''',view_name,''';
INSERT INTO qgis_pkg.layer_metadata (schema_name, feature_type, qml_file, lod, root_class, layer_name, creation_date, mv_name, v_name) VALUES
(''',citydb_schema,''',''',feature_type,''',''',qml_file_name,''',''',t.lodx_label,''',''',s.class_name,''',''',l_name,''',clock_timestamp(),''',mview_name,''',''',view_name,''');
');
EXECUTE sql_statement;

---------------------------------------------------------------
-- Create MATERIALIZED VIEW QGIS_PKG._G_*_BUILDING_INSTALLATION_LOD2-4_THEMATIC_SURFACES
---------------------------------------------------------------
			FOR u IN 
				SELECT * FROM (VALUES
				('BuildingRoofSurface'::varchar , 33::integer, 'roofsurf'::varchar),
				('BuildingWallSurface'			, 34		 , 'wallsurf'),
				('BuildingGroundSurface'		, 35		 , 'groundsurf'),
				('BuildingClosureSurface'		, 36		 , 'closuresurf'),
				('OuterBuildingCeilingSurface'	, 60		 , 'outerceilingsurf'),
				('OuterBuildingFloorSurface'	, 61		 , 'outerfloorsurf')
				) AS t(themsurf_name, class_id, themsurf_label)
			LOOP

l_name         := format(      '%I_%I_%I_%I',							r.class_label, s.class_label, t.lodx_label, u.themsurf_label);
view_name      := format(   '%I_%I_%I_%I_%I',			citydb_schema, r.class_label, s.class_label, t.lodx_label, u.themsurf_label);
mview_name     := format('_g_%I_%I_%I_%I_%I',			citydb_schema, r.class_label, s.class_label, t.lodx_label, u.themsurf_label);
mview_idx_name := format('_g_%I_%I_%I_%I_%I_id_idx',	citydb_schema, r.class_label, s.class_label, t.lodx_label, u.themsurf_label);
mview_spx_name := format('_g_%I_%I_%I_%I_%I_geom_spx',	citydb_schema, r.class_label, s.class_label, t.lodx_label, u.themsurf_label);
qml_file_name  := concat(r.class_label,'_',s.class_label,'_them_surf_form.qml');

IF mview_bbox IS NOT NULL THEN
	sql_where := concat('AND ST_MakeEnvelope(',mview_bbox_xmin,', ',mview_bbox_ymin,', ',mview_bbox_xmax,', ',mview_bbox_ymax,', ',srid_id,') && co.envelope');
ELSE
	sql_where := NULL;
END IF;

sql_statement := concat('
DROP MATERIALIZED VIEW IF EXISTS qgis_pkg.',mview_name,' CASCADE;
CREATE MATERIALIZED VIEW         qgis_pkg.',mview_name,' AS
	SELECT
		sg.cityobject_id::bigint AS co_id,
		ST_Collect(qgis_pkg.ST_snap_poly_to_grid(sg.geometry,',perform_snapping,',',digits,',',area_poly_min,'))::geometry(MultiPolygonZ,',srid_id,') AS geom
	FROM
		',citydb_schema,'.thematic_surface AS o
		INNER JOIN ',citydb_schema,'.cityobject AS co ON (o.id = co.id AND o.objectclass_id = ',u.class_id,' ',sql_where,') 
		INNER JOIN ',citydb_schema,'.building_installation AS bi ON (o.building_installation_id = bi.id AND bi.objectclass_id = ',s.class_id,')
		INNER JOIN ',citydb_schema,'.building AS b ON (o.building_id = b.id AND b.objectclass_id = ',r.class_id,')		
		INNER JOIN ',citydb_schema,'.surface_geometry AS sg ON (sg.root_id = o.',t.lodx_name,'_multi_surface_id  AND sg.geometry IS NOT NULL)
	GROUP BY sg.cityobject_id
WITH NO DATA;
COMMENT ON MATERIALIZED VIEW qgis_pkg.',mview_name,' IS ''Mat. view of ',s.class_name,' ',t.lodx_name,' ',u.themsurf_name,' in schema ',citydb_schema,''';
CREATE INDEX ',mview_idx_name,' ON qgis_pkg.',mview_name,' (co_id);
CREATE INDEX ',mview_spx_name,' ON qgis_pkg.',mview_name,' USING gist (geom);
DELETE FROM qgis_pkg.layer_metadata WHERE v_name = ''',view_name,''';
INSERT INTO qgis_pkg.layer_metadata (schema_name, feature_type, qml_file, lod, root_class, layer_name, creation_date, mv_name, v_name) VALUES
(''',citydb_schema,''',''',feature_type,''',''',qml_file_name,''',''',t.lodx_label,''',''',s.class_name,''',''',l_name,''',clock_timestamp(),''',mview_name,''',''',view_name,''');
');
EXECUTE sql_statement;

			END LOOP; -- outer bgd out install thematic surfaces loop
		END LOOP; -- outer bgd out install lod loop
	END LOOP; -- outer bgd install loop

---------------------------------------------------------------
-- Create MATERIALIZED VIEW QGIS_PKG._G_**_INT_BUILDING_INSTALLATION_**_LOD4
---------------------------------------------------------------
	FOR s IN 
		SELECT * FROM (VALUES
		('IntBuildingInstallation'::varchar, 28::integer, 'int_inst'::varchar)
		) AS t(class_name, class_id, class_label)
	LOOP
		FOR t IN 
			SELECT * FROM (VALUES
			('LoD4'::varchar, 'lod4'::varchar)
			) AS t(lodx_name, lodx_label)
		LOOP
l_name         := format(      '%I_%I_%I',							r.class_label, s.class_label, t.lodx_label);
view_name      := format(   '%I_%I_%I_%I',			citydb_schema, r.class_label, s.class_label, t.lodx_label);
mview_name     := format('_g_%I_%I_%I_%I',			citydb_schema, r.class_label, s.class_label, t.lodx_label);
mview_idx_name := format('_g_%I_%I_%I_%I_id_idx',	citydb_schema, r.class_label, s.class_label, t.lodx_label);
mview_spx_name := format('_g_%I_%I_%I_%I_geom_spx',	citydb_schema, r.class_label, s.class_label, t.lodx_label);
qml_file_name  := concat(r.class_label,'_',s.class_label,'_form.qml');

IF mview_bbox IS NOT NULL THEN
	sql_where := concat('AND ST_MakeEnvelope(',mview_bbox_xmin,', ',mview_bbox_ymin,', ',mview_bbox_xmax,', ',mview_bbox_ymax,', ',srid_id,') && co.envelope');
ELSE
	sql_where := NULL;
END IF;

sql_statement := concat('
DROP MATERIALIZED VIEW IF EXISTS qgis_pkg.',mview_name,' CASCADE;
CREATE MATERIALIZED VIEW         qgis_pkg.',mview_name,' AS
	SELECT 
		foo2.co_id AS co_id,
		st_collect(qgis_pkg.ST_snap_poly_to_grid(sg.geometry,',perform_snapping,',',digits,',',area_poly_min,'))::geometry(MultiPolygonZ, ',srid_id,') AS geom
	FROM ( 
			SELECT 
				foo.co_id,
				unnest(foo.sg_id_array) AS sg_id
			FROM ( 
					SELECT
						o.id AS co_id,
						CASE
							WHEN ts_t.sg_id_array IS NOT NULL THEN ts_t.sg_id_array
							ELSE ARRAY[o.',t.lodx_label,'_brep_id]
						END AS sg_id_array
					FROM 
						',citydb_schema,'.building_installation AS o
						INNER JOIN ',citydb_schema,'.cityobject AS co ON (o.id = co.id AND o.objectclass_id = ',s.class_id,' ',sql_where,')
						INNER JOIN (
							SELECT
								o.building_installation_id AS co_id,
								array_agg(o.',t.lodx_label,'_multi_surface_id) AS sg_id_array
							FROM 
								',citydb_schema,'.thematic_surface AS o
								INNER JOIN ',citydb_schema,'.cityobject AS co ON (co.id = o.id ',sql_where,')
								INNER JOIN ',citydb_schema,'.building AS b ON (o.building_id = b.id AND b.objectclass_id = ',r.class_id,')
							WHERE 
								o.building_installation_id IS NOT NULL
							GROUP BY o.building_installation_id
						) AS ts_t ON (ts_t.co_id = o.id)
					WHERE
						o.',t.lodx_label,'_implicit_rep_id IS NULL
				) AS foo
	   ) AS foo2
	INNER JOIN ',citydb_schema,'.surface_geometry AS sg ON (sg.root_id = foo2.sg_id AND sg.geometry IS NOT NULL)
	GROUP BY foo2.co_id
	UNION');
-- the need to split is due to max 100 arguments allowed in the concat function.
sql_statement := concat(sql_statement,'	
	SELECT
		o.id::bigint AS co_id,
		ST_SetSRID(
			ST_Affine(ST_Collect(sg.implicit_geometry),
				   split_part(o.',t.lodx_label,'_implicit_transformation, '' '', 1)::double precision,
				   0,0,0,
				   split_part(o.',t.lodx_label,'_implicit_transformation, '' '', 6)::double precision,
				   0,0,0,
				   split_part(o.',t.lodx_label,'_implicit_transformation, '' '', 11)::double precision,
				   ST_X(o.',t.lodx_label,'_implicit_ref_point),
				   ST_Y(o.',t.lodx_label,'_implicit_ref_point),
				   ST_Z(o.',t.lodx_label,'_implicit_ref_point)
				   ),
			',srid_id,')::geometry(MultiPolygonZ, ',srid_id,') AS geom
	FROM 
		',citydb_schema,'.building_installation AS o
		INNER JOIN ',citydb_schema,'.cityobject AS co ON (o.id = co.id AND o.objectclass_id = ',s.class_id,' ',sql_where,')
		INNER JOIN ',citydb_schema,'.building AS b ON (b.id = o.building_id AND b.objectclass_id = ',r.class_id,')
		INNER JOIN ',citydb_schema,'.implicit_geometry AS ig ON (ig.id = o.',t.lodx_label,'_implicit_rep_id)
		INNER JOIN ',citydb_schema,'.surface_geometry AS sg ON (sg.root_id = ig.relative_brep_id AND sg.implicit_geometry IS NOT NULL)
	WHERE
		o.',t.lodx_label,'_implicit_rep_id IS NOT NULL
	GROUP BY o.id
WITH NO DATA;
COMMENT ON MATERIALIZED VIEW qgis_pkg.',mview_name,' IS ''Mat. view of ',s.class_name,' ',t.lodx_name,' in schema ',citydb_schema,''';
CREATE INDEX ',mview_idx_name,' ON qgis_pkg.',mview_name,' (co_id);
CREATE INDEX ',mview_spx_name,' ON qgis_pkg.',mview_name,' USING gist (geom);
DELETE FROM qgis_pkg.layer_metadata WHERE v_name = ''',view_name,''';
INSERT INTO qgis_pkg.layer_metadata (schema_name, feature_type, qml_file, lod, root_class, layer_name, creation_date, mv_name, v_name) VALUES
(''',citydb_schema,''',''',feature_type,''',''',qml_file_name,''',''',t.lodx_label,''',''',s.class_name,''',''',l_name,''',clock_timestamp(),''',mview_name,''',''',view_name,''');
');
EXECUTE sql_statement;

---------------------------------------------------------------
-- Create MATERIALIZED VIEW QGIS_PKG._G_**_INT_BUILDING_INSTALLATION_**_LOD4_THEMATIC_SURF
---------------------------------------------------------------
			FOR u IN 
				SELECT * FROM (VALUES
				('BuildingRoofSurface'::varchar , 33::integer, 'roofsurf'::varchar),
				('BuildingWallSurface'			, 34		 , 'wallsurf'),
				('BuildingGroundSurface'		, 35		 , 'groundsurf'),
				('BuildingClosureSurface'		, 36		 , 'closuresurf'),
				('OuterBuildingCeilingSurface'	, 60		 , 'outerceilingsurf'),
				('OuterBuildingFloorSurface'	, 61		 , 'outerfloorsurf')
				) AS t(themsurf_name, class_id, themsurf_label)
			LOOP

l_name         := format(      '%I_%I_%I_%I',							r.class_label, s.class_label, t.lodx_label, u.themsurf_label);
view_name      := format(   '%I_%I_%I_%I_%I',			citydb_schema, r.class_label, s.class_label, t.lodx_label, u.themsurf_label);
mview_name     := format('_g_%I_%I_%I_%I_%I',			citydb_schema, r.class_label, s.class_label, t.lodx_label, u.themsurf_label);
mview_idx_name := format('_g_%I_%I_%I_%I_%I_id_idx',	citydb_schema, r.class_label, s.class_label, t.lodx_label, u.themsurf_label);
mview_spx_name := format('_g_%I_%I_%I_%I_%I_geom_spx',	citydb_schema, r.class_label, s.class_label, t.lodx_label, u.themsurf_label);
qml_file_name  := concat(r.class_label,'_',s.class_label,'_them_surf_form.qml');

IF mview_bbox IS NOT NULL THEN
	sql_where := concat('AND ST_MakeEnvelope(',mview_bbox_xmin,', ',mview_bbox_ymin,', ',mview_bbox_xmax,', ',mview_bbox_ymax,', ',srid_id,') && co.envelope');
ELSE
	sql_where := NULL;
END IF;

sql_statement := concat('
DROP MATERIALIZED VIEW IF EXISTS qgis_pkg.',mview_name,' CASCADE;
CREATE MATERIALIZED VIEW         qgis_pkg.',mview_name,' AS
	SELECT
		sg.cityobject_id::bigint AS co_id,
		ST_Collect(qgis_pkg.ST_snap_poly_to_grid(sg.geometry,',perform_snapping,',',digits,',',area_poly_min,'))::geometry(MultiPolygonZ,',srid_id,') AS geom
	FROM
		',citydb_schema,'.thematic_surface AS o
		INNER JOIN ',citydb_schema,'.cityobject AS co ON (o.id = co.id AND o.objectclass_id = ',u.class_id,' ',sql_where,') 
		INNER JOIN ',citydb_schema,'.building_installation AS bi ON (o.building_installation_id = bi.id AND bi.objectclass_id = ',s.class_id,')
		INNER JOIN ',citydb_schema,'.building AS b ON (o.building_id = b.id AND b.objectclass_id = ',r.class_id,')		
		INNER JOIN ',citydb_schema,'.surface_geometry AS sg ON (sg.root_id = o.',t.lodx_name,'_multi_surface_id  AND sg.geometry IS NOT NULL)
	GROUP BY sg.cityobject_id
WITH NO DATA;
COMMENT ON MATERIALIZED VIEW qgis_pkg.',mview_name,' IS ''Mat. view of ',s.class_name,' ',t.lodx_name,' ',u.themsurf_name,' in schema ',citydb_schema,''';
CREATE INDEX ',mview_idx_name,' ON qgis_pkg.',mview_name,' (co_id);
CREATE INDEX ',mview_spx_name,' ON qgis_pkg.',mview_name,' USING gist (geom);
DELETE FROM qgis_pkg.layer_metadata WHERE v_name = ''',view_name,''';
INSERT INTO qgis_pkg.layer_metadata (schema_name, feature_type, qml_file, lod, root_class, layer_name, creation_date, mv_name, v_name) VALUES
(''',citydb_schema,''',''',feature_type,''',''',qml_file_name,''',''',t.lodx_label,''',''',s.class_name,''',''',l_name,''',clock_timestamp(),''',mview_name,''',''',view_name,''');
');
EXECUTE sql_statement;

			END LOOP; -- interior bgd install thematic surfaces lod loop

		END LOOP; -- interior bgd install lod loop
	END LOOP; -- interior bgd install loop

---------------------------------------------------------------
-- Create MATERIALIZED VIEW QGIS_PKG._G_**_ROOM_LOD4
---------------------------------------------------------------
	FOR s IN 
		SELECT * FROM (VALUES
		('Room'::varchar, 41::integer, 'room'::varchar)
		) AS t(class_name, class_id, class_label)
	LOOP

l_name         := format(      '%I_%I_lod4',							r.class_label, s.class_label);
view_name      := format(   '%I_%I_%I_lod4',			citydb_schema, r.class_label, s.class_label);
mview_name     := format('_g_%I_%I_%I_lod4', 			citydb_schema, r.class_label, s.class_label);
mview_idx_name := format('_g_%I_%I_%I_lod4_id_idx', 	citydb_schema, r.class_label, s.class_label);
mview_spx_name := format('_g_%I_%I_%I_lod4_geom_spx',	citydb_schema, r.class_label, s.class_label);
qml_file_name  := concat(r.class_label,'_',s.class_label,'_form.qml');

IF mview_bbox IS NOT NULL THEN
	sql_where := concat('AND ST_MakeEnvelope(',mview_bbox_xmin,', ',mview_bbox_ymin,', ',mview_bbox_xmax,', ',mview_bbox_ymax,', ',srid_id,') && co.envelope');
ELSE
	sql_where := NULL;
END IF;

sql_statement := concat('
DROP MATERIALIZED VIEW IF EXISTS qgis_pkg.',mview_name,' CASCADE;
CREATE MATERIALIZED VIEW         qgis_pkg.',mview_name,' AS

	SELECT
		foo2.co_id::bigint AS co_id,
		ST_Collect(qgis_pkg.ST_snap_poly_to_grid(sg.geometry,',perform_snapping,',',digits,',',area_poly_min,'))::geometry(MultiPolygonZ, ',srid_id,') AS geom	
	FROM (
		SELECT
			foo.co_id,
			unnest(foo.sg_id_array) AS sg_id
		FROM (
			SELECT
				-- coalesce(o.id, ts_t.co_id) as co_id,
				o.id AS co_id,
				CASE 
					WHEN ts_t.sg_id_array IS NOT NULL THEN ts_t.sg_id_array
					WHEN o.',t.lodx_label,'_solid_id IS NOT NULL THEN ARRAY[o.',t.lodx_label,'_solid_id]
					ELSE ARRAY[o.',t.lodx_label,'_multi_surface_id]
				END AS sg_id_array 
			FROM 
				',citydb_schema,'.room AS o
				INNER JOIN ',citydb_schema,'.cityobject AS co ON (o.id = co.id AND o.objectclass_id = ',s.class_id,' ',sql_where,')
				INNER JOIN ',citydb_schema,'.building AS b ON (b.id = o.building_id AND b.objectclass_id = ',r.class_id,')
				-- FULL OUTER JOIN
				INNER JOIN (
					SELECT ts.building_id AS co_id, array_agg(ts.',t.lodx_label,'_multi_surface_id) AS sg_id_array 
					FROM 
						',citydb_schema,'.thematic_surface AS ts
						INNER JOIN ',citydb_schema,'.cityobject AS co ON (co.id = ts.id ',sql_where,')
						INNER JOIN ',citydb_schema,'.room AS r ON (ts.building_id = r.id AND r.objectclass_id = ',s.class_id,' ',sql_where,')
						INNER JOIN ',citydb_schema,'.building AS b1 ON (b1.id = r.building_id AND b1.objectclass_id = ',r.class_id,')						
					GROUP BY ts.building_id
					) AS ts_t ON (ts_t.co_id = o.id)
			WHERE 
				sg_id_array IS NOT NULL
			) AS foo
		) AS foo2
		INNER JOIN ',citydb_schema,'.surface_geometry AS sg ON (sg.root_id = foo2.sg_id AND sg.geometry IS NOT NULL)
	GROUP BY foo2.co_id
WITH NO DATA;
COMMENT ON MATERIALIZED VIEW qgis_pkg.',mview_name,' IS ''Mat. view of (',r.class_name,') ',s.class_name,' ',t.lodx_name,' in schema ',citydb_schema,''';
CREATE INDEX ',mview_idx_name,' ON qgis_pkg.',mview_name,' (co_id);
CREATE INDEX ',mview_spx_name,' ON qgis_pkg.',mview_name,' USING gist (geom);
DELETE FROM qgis_pkg.layer_metadata WHERE v_name = ''',view_name,''';
INSERT INTO qgis_pkg.layer_metadata (schema_name, feature_type, qml_file, lod, root_class, layer_name, creation_date, mv_name, v_name) VALUES
(''',citydb_schema,''',''',feature_type,''',''',qml_file_name,''',''',t.lodx_label,''',''',s.class_name,''',''',l_name,''',clock_timestamp(),''',mview_name,''',''',view_name,''');
');
EXECUTE sql_statement;

---------------------------------------------------------------
-- Create MATERIALIZED VIEW QGIS_PKG._G_**_ROOM_LOD4_THEMATIC_SURFACES
---------------------------------------------------------------
			FOR u IN 
				SELECT * FROM (VALUES
				('BuildingCeilingSurface'::varchar	, 30::integer	, 'ceilingsurf'::varchar),
				('InteriorBuildingWallSurface'		, 31		 	, 'intwallsurf'),
				('BuildingFloorSurface'				, 32		    , 'floorsurf')
				) AS t(themsurf_name, class_id, themsurf_label)
			LOOP

l_name         := format(      '%I_%I_lod4_%I',								r.class_label, s.class_label, u.themsurf_label);
view_name      := format(   '%I_%I_%I_lod4_%I',				citydb_schema, r.class_label, s.class_label, u.themsurf_label);
mview_name     := format('_g_%I_%I_%I_lod4_%I',				citydb_schema, r.class_label, s.class_label, u.themsurf_label);
mview_idx_name := format('_g_%I_%I_%I_lod4_%I_id_idx',		citydb_schema, r.class_label, s.class_label, u.themsurf_label);
mview_spx_name := format('_g_%I_%I_%I_lod4_%I_geom_spx',	citydb_schema, r.class_label, s.class_label, u.themsurf_label);
qml_file_name  := concat(r.class_label,'_',s.class_label,'_them_surf_form.qml');

IF mview_bbox IS NOT NULL THEN
	sql_where := concat('AND ST_MakeEnvelope(',mview_bbox_xmin,', ',mview_bbox_ymin,', ',mview_bbox_xmax,', ',mview_bbox_ymax,', ',srid_id,') && co.envelope');
ELSE
	sql_where := NULL;
END IF;

sql_statement := concat('
DROP MATERIALIZED VIEW IF EXISTS qgis_pkg.',mview_name,' CASCADE;
CREATE MATERIALIZED VIEW         qgis_pkg.',mview_name,' AS
	SELECT
		sg.cityobject_id::bigint AS co_id,
		ST_Collect(qgis_pkg.ST_snap_poly_to_grid(sg.geometry,',perform_snapping,',',digits,',',area_poly_min,'))::geometry(MultiPolygonZ,',srid_id,') AS geom
	FROM
		',citydb_schema,'.thematic_surface AS o
		INNER JOIN ',citydb_schema,'.cityobject AS co ON (o.id = co.id AND o.objectclass_id = ',u.class_id,' ',sql_where,') 
		INNER JOIN ',citydb_schema,'.room AS r ON (o.room_id = r.id AND r.objectclass_id = ',s.class_id,')
		INNER JOIN ',citydb_schema,'.building AS b ON (r.building_id = b.id AND b.objectclass_id = ',r.class_id,')		
		INNER JOIN ',citydb_schema,'.surface_geometry AS sg ON (sg.root_id = o.',t.lodx_name,'_multi_surface_id  AND sg.geometry IS NOT NULL)
	GROUP BY sg.cityobject_id
WITH NO DATA;
COMMENT ON MATERIALIZED VIEW qgis_pkg.',mview_name,' IS ''Mat. view of (',r.class_name,') ',s.class_name,' ',t.lodx_name,' ',u.themsurf_name,' in schema ',citydb_schema,''';
CREATE INDEX ',mview_idx_name,' ON qgis_pkg.',mview_name,' (co_id);
CREATE INDEX ',mview_spx_name,' ON qgis_pkg.',mview_name,' USING gist (geom);
DELETE FROM qgis_pkg.layer_metadata WHERE v_name = ''',view_name,''';
INSERT INTO qgis_pkg.layer_metadata (schema_name, feature_type, qml_file, lod, root_class, layer_name, creation_date, mv_name, v_name) VALUES
(''',citydb_schema,''',''',feature_type,''',''',qml_file_name,''',''',t.lodx_label,''',''',s.class_name,''',''',l_name,''',clock_timestamp(),''',mview_name,''',''',view_name,''');
');
EXECUTE sql_statement;
		END LOOP; -- room thematic surfaces loop
	END LOOP; -- room loop

---------------------------------------------------------------
-- Create MATERIALIZED VIEW QGIS_PKG._G_**_WINDOW/DOOR_LOD3-4
---------------------------------------------------------------
	FOR s IN 
		SELECT * FROM (VALUES
		('BuildingWindow'::varchar, 38::integer, 'window'::varchar),
		('BuildingDoor'           , 39         , 'door')		
		) AS t(class_name, class_id, class_label)
	LOOP
		FOR t IN 
			SELECT * FROM (VALUES
			('LoD3'::varchar, 'lod3'::varchar),
			('LoD4'			, 'lod4')		
			) AS t(lodx_name, lodx_label)
		LOOP

-- The concat is here necessary because "window" is a reserved word and using format would add a " to the name.
l_name         := concat(						  r.class_label,'_',s.class_label,'_',t.lodx_label);
view_name      := concat(	   citydb_schema,'_',r.class_label,'_',s.class_label,'_',t.lodx_label);
mview_name     := concat('_g_',citydb_schema,'_',r.class_label,'_',s.class_label,'_',t.lodx_label);
mview_idx_name := concat('_g_',citydb_schema,'_',r.class_label,'_',s.class_label,'_',t.lodx_label,'_id_idx');
mview_spx_name := concat('_g_',citydb_schema,'_',r.class_label,'_',s.class_label,'_',t.lodx_label,'_geom_spx');
qml_file_name  := concat(r.class_label,'_opening_form.qml');

IF mview_bbox IS NOT NULL THEN
	sql_where := concat('AND ST_MakeEnvelope(',mview_bbox_xmin,', ',mview_bbox_ymin,', ',mview_bbox_xmax,', ',mview_bbox_ymax,', ',srid_id,') && co.envelope');
ELSE
	sql_where := NULL;
END IF;

sql_statement := concat('
DROP MATERIALIZED VIEW IF EXISTS qgis_pkg.',mview_name,' CASCADE;
CREATE MATERIALIZED VIEW         qgis_pkg.',mview_name,' AS
	SELECT
		sg.cityobject_id::bigint AS co_id,
		ST_Collect(qgis_pkg.ST_snap_poly_to_grid(sg.geometry,',perform_snapping,',',digits,',',area_poly_min,'))::geometry(MultiPolygonZ,',srid_id,') AS geom
	FROM
		',citydb_schema,'.opening AS o
		INNER JOIN ',citydb_schema,'.cityobject AS co ON (o.id = co.id AND o.objectclass_id = ',s.class_id,' ',sql_where,')
		INNER JOIN ',citydb_schema,'.opening_to_them_surface AS ots ON (ots.opening_id = o.id)
		INNER JOIN ',citydb_schema,'.thematic_surface AS ts ON (ts.id = ots.thematic_surface_id)
		INNER JOIN ',citydb_schema,'.building AS b ON (b.id = ts.building_id AND b.objectclass_id = ',r.class_id,')
		INNER JOIN ',citydb_schema,'.surface_geometry sg ON sg.root_id = o.',t.lodx_name,'_multi_surface_id  AND sg.geometry IS NOT NULL
	WHERE
		o.',t.lodx_name,'_implicit_rep_id IS NULL
	GROUP BY sg.cityobject_id
	UNION');

sql_statement := concat(sql_statement,'
	SELECT
		o.id::bigint AS co_id,
		ST_SetSRID(
			ST_Affine(ST_Collect(sg.implicit_geometry),
				   split_part(o.',t.lodx_label,'_implicit_transformation, '' '', 1)::double precision,
				   0,0,0,
				   split_part(o.',t.lodx_label,'_implicit_transformation, '' '', 6)::double precision,
				   0,0,0,
				   split_part(o.',t.lodx_label,'_implicit_transformation, '' '', 11)::double precision,
				   ST_X(o.',t.lodx_label,'_implicit_ref_point),
				   ST_Y(o.',t.lodx_label,'_implicit_ref_point),
				   ST_Z(o.',t.lodx_label,'_implicit_ref_point)
				   ),
			',srid_id,')::geometry(MultiPolygonZ, ',srid_id,') AS geom
	FROM 
		',citydb_schema,'.opening AS o
		INNER JOIN ',citydb_schema,'.cityobject AS co ON (o.id = co.id AND o.objectclass_id = ',s.class_id,' ',sql_where,')		
		INNER JOIN ',citydb_schema,'.opening_to_them_surface AS ots ON (ots.opening_id = o.id)
		INNER JOIN ',citydb_schema,'.thematic_surface AS ts ON (ts.id = ots.thematic_surface_id)
		INNER JOIN ',citydb_schema,'.building AS b ON (b.id = ts.building_id AND b.objectclass_id = ',r.class_id,')	
		INNER JOIN ',citydb_schema,'.implicit_geometry AS ig ON (ig.id = o.',t.lodx_name,'_implicit_rep_id) 
		INNER JOIN ',citydb_schema,'.surface_geometry AS sg ON (sg.root_id = ig.relative_brep_id AND sg.implicit_geometry IS NOT NULL)
	WHERE
		o.',t.lodx_name,'_implicit_rep_id IS NOT NULL
	GROUP BY o.id
WITH NO DATA;
COMMENT ON MATERIALIZED VIEW qgis_pkg.',mview_name,' IS ''Mat. view of (',r.class_name,') ',s.class_name,' ',t.lodx_name,' in schema ',citydb_schema,''';
CREATE INDEX ',mview_idx_name,' ON qgis_pkg.',mview_name,' (co_id);
CREATE INDEX ',mview_spx_name,' ON qgis_pkg.',mview_name,' USING gist (geom);
DELETE FROM qgis_pkg.layer_metadata WHERE v_name = ''',view_name,''';
INSERT INTO qgis_pkg.layer_metadata (schema_name, feature_type, qml_file, lod, root_class, layer_name, creation_date, mv_name, v_name) VALUES
(''',citydb_schema,''',''',feature_type,''',''',qml_file_name,''',''',t.lodx_label,''',''',s.class_name,''',''',l_name,''',clock_timestamp(),''',mview_name,''',''',view_name,''');
');
EXECUTE sql_statement;

		END LOOP; -- bgd window/door lod
	END LOOP; -- bgd window/door


---------------------------------------------------------------
-- Create MATERIALIZED VIEW QGIS_PKG._G_**_BUILDINGFURNITURE_LOD4
---------------------------------------------------------------
	FOR s IN 
		SELECT * FROM (VALUES
		('BuildingFurniture'::varchar, 40::integer, 'furniture'::varchar)		
		) AS t(class_name, class_id, class_label)
	LOOP

l_name         := format(      '%I_%I_lod4',							r.class_label, s.class_label);
view_name      := format(   '%I_%I_%I_lod4',			citydb_schema, r.class_label, s.class_label);
mview_name     := format('_g_%I_%I_%I_lod4',			citydb_schema, r.class_label, s.class_label);
mview_idx_name := format('_g_%I_%I_%I_lod4_id_idx',		citydb_schema, r.class_label, s.class_label);
mview_spx_name := format('_g_%I_%I_%I_lod4_geom_spx',	citydb_schema, r.class_label, s.class_label);
qml_file_name  := concat(r.class_label,'_',s.class_label,'_form.qml');

IF mview_bbox IS NOT NULL THEN
	sql_where := concat('AND ST_MakeEnvelope(',mview_bbox_xmin,', ',mview_bbox_ymin,', ',mview_bbox_xmax,', ',mview_bbox_ymax,', ',srid_id,') && co.envelope');
ELSE
	sql_where := NULL;
END IF;

sql_statement := concat('
DROP MATERIALIZED VIEW IF EXISTS qgis_pkg.',mview_name,' CASCADE;
CREATE MATERIALIZED VIEW         qgis_pkg.',mview_name,' AS
	SELECT
		sg.cityobject_id::bigint AS co_id,
		ST_Collect(qgis_pkg.ST_snap_poly_to_grid(sg.geometry,',perform_snapping,',',digits,',',area_poly_min,'))::geometry(MultiPolygonZ,',srid_id,') AS geom
	FROM
		',citydb_schema,'.building_furniture AS o
		INNER JOIN ',citydb_schema,'.cityobject AS co ON (o.id = co.id AND o.objectclass_id = ',s.class_id,' ',sql_where,')
		INNER JOIN ',citydb_schema,'.room AS r ON (r.id = o.room_id)
		INNER JOIN ',citydb_schema,'.building AS b ON (b.id = r.building_id AND b.objectclass_id = ',r.class_id,')
		INNER JOIN ',citydb_schema,'.surface_geometry AS sg ON (sg.root_id = o.lod4_brep_id AND sg.geometry IS NOT NULL)
	WHERE
		o.lod4_implicit_rep_id IS NULL
	GROUP BY sg.cityobject_id
	UNION');

sql_statement := concat(sql_statement,'
	SELECT
		o.id::bigint AS co_id,
		ST_SetSRID(
			ST_Affine(ST_Collect(sg.implicit_geometry),
				   split_part(o.lod4_implicit_transformation, '' '', 1)::double precision,
				   0,0,0,
				   split_part(o.lod4_implicit_transformation, '' '', 6)::double precision,
				   0,0,0,
				   split_part(o.lod4_implicit_transformation, '' '', 11)::double precision,
				   ST_X(o.lod4_implicit_ref_point),
				   ST_Y(o.lod4_implicit_ref_point),
				   ST_Z(o.lod4_implicit_ref_point)
				   ),
			',srid_id,')::geometry(MultiPolygonZ, ',srid_id,') AS geom
	FROM 
		',citydb_schema,'.building_furniture AS o
		INNER JOIN ',citydb_schema,'.cityobject AS co ON (o.id = co.id AND o.objectclass_id = ',s.class_id,' ',sql_where,')		
		INNER JOIN ',citydb_schema,'.room AS r ON (r.id = o.room_id)
		INNER JOIN ',citydb_schema,'.building AS b ON (b.id = r.building_id AND b.objectclass_id = ',r.class_id,')	
		INNER JOIN ',citydb_schema,'.implicit_geometry AS ig ON (ig.id = o.lod4_implicit_rep_id) 
		INNER JOIN ',citydb_schema,'.surface_geometry AS sg ON (sg.root_id = ig.relative_brep_id AND sg.implicit_geometry IS NOT NULL)
	WHERE
		o.lod4_implicit_rep_id IS NOT NULL
	GROUP BY o.id
WITH NO DATA;
COMMENT ON MATERIALIZED VIEW qgis_pkg.',mview_name,' IS ''Mat. view of (',r.class_name,') ',s.class_name,' ',t.lodx_name,' in schema ',citydb_schema,''';
CREATE INDEX ',mview_idx_name,' ON qgis_pkg.',mview_name,' (co_id);
CREATE INDEX ',mview_spx_name,' ON qgis_pkg.',mview_name,' USING gist (geom);
DELETE FROM qgis_pkg.layer_metadata WHERE v_name = ''',view_name,''';
INSERT INTO qgis_pkg.layer_metadata (schema_name, feature_type, qml_file, lod, root_class, layer_name, creation_date, mv_name, v_name) VALUES
(''',citydb_schema,''',''',feature_type,''',''',qml_file_name,''',''',t.lodx_label,''',''',s.class_name,''',''',l_name,''',clock_timestamp(),''',mview_name,''',''',view_name,''');
');
EXECUTE sql_statement;

	END LOOP; -- building furniture

END LOOP; -- building(part) loop

-- ***********************
-- VEGETATION MODULE
-- ***********************
feature_type     := 'Vegetation';

---------------------------------------------------------------
-- Create MATERIALIZED VIEW QGIS_PKG._G_*_SOLITARY_VEGETAT_OBJECT_LOD1-4
---------------------------------------------------------------
FOR r IN 
	SELECT * FROM (VALUES
	('SolitaryVegetationObject'::varchar, 7::integer, 'sol_veg_obj'::varchar)
	) AS t(class_name, class_id, class_label)
LOOP
	FOR t IN 
		SELECT * FROM (VALUES
		('LoD1'::varchar, 'lod1'::varchar),
		('LoD2'			, 'lod2'),
		('LoD3'			, 'lod3'),
		('LoD4'			, 'lod4')		
		) AS t(lodx_name, lodx_label)
	LOOP

l_name         := format(      '%I_%I',								r.class_label, t.lodx_label);
view_name      := format(   '%I_%I_%I',				citydb_schema, r.class_label, t.lodx_label);
mview_name     := format('_g_%I_%I_%I',				citydb_schema, r.class_label, t.lodx_label);
mview_idx_name := format('_g_%I_%I_%I_id_idx',		citydb_schema, r.class_label, t.lodx_label);
mview_spx_name := format('_g_%I_%I_%I_geom_spx',	citydb_schema, r.class_label, t.lodx_label);
qml_file_name  := concat(r.class_label,'_form.qml');

IF mview_bbox IS NOT NULL THEN
	sql_where := concat('AND ST_MakeEnvelope(',mview_bbox_xmin,', ',mview_bbox_ymin,', ',mview_bbox_xmax,', ',mview_bbox_ymax,', ',srid_id,') && co.envelope');
ELSE
	sql_where := NULL;
END IF;

sql_statement := concat('
DROP MATERIALIZED VIEW IF EXISTS qgis_pkg.',mview_name,' CASCADE;
CREATE MATERIALIZED VIEW         qgis_pkg.',mview_name,' AS
	SELECT
		sg.cityobject_id::bigint AS co_id,
		ST_Collect(qgis_pkg.ST_snap_poly_to_grid(sg.geometry,',perform_snapping,',',digits,',',area_poly_min,'))::geometry(MultiPolygonZ, ',srid_id,') AS geom	
	FROM
		',citydb_schema,'.solitary_vegetat_object AS o
		INNER JOIN ',citydb_schema,'.cityobject AS co ON (o.id = co.id AND o.objectclass_id = ',r.class_id,' ',sql_where,')
		INNER JOIN ',citydb_schema,'.surface_geometry AS sg ON (sg.root_id = o.',t.lodx_label,'_brep_id AND sg.geometry IS NOT NULL)
	WHERE
		o.',t.lodx_label,'_implicit_rep_id IS NULL AND o.',t.lodx_label,'_brep_id IS NOT NULL 
	GROUP BY sg.cityobject_id

	UNION

	SELECT
		o.id::bigint AS co_id,
		ST_SetSRID(
			ST_Affine(ST_Collect(sg.implicit_geometry),
				   split_part(o.',t.lodx_label,'_implicit_transformation, '' '', 1)::double precision,
				   0,0,0,
				   split_part(o.',t.lodx_label,'_implicit_transformation, '' '', 6)::double precision,
				   0,0,0,
				   split_part(o.',t.lodx_label,'_implicit_transformation, '' '', 11)::double precision,
				   ST_X(o.',t.lodx_label,'_implicit_ref_point),
				   ST_Y(o.',t.lodx_label,'_implicit_ref_point),
				   ST_Z(o.',t.lodx_label,'_implicit_ref_point)
				   ),
			',srid_id,')::geometry(MultiPolygonZ, ',srid_id,') AS geom
	FROM 
		',citydb_schema,'.solitary_vegetat_object AS o
		INNER JOIN ',citydb_schema,'.cityobject AS co ON (o.id=co.id AND o.objectclass_id = ',r.class_id,' ',sql_where,')	
		INNER JOIN ',citydb_schema,'.implicit_geometry AS ig ON (ig.id = o.',t.lodx_label,'_implicit_rep_id)
		INNER JOIN ',citydb_schema,'.surface_geometry AS sg ON (sg.root_id = ig.relative_brep_id AND sg.implicit_geometry IS NOT NULL)
	WHERE
		o.',t.lodx_label,'_implicit_rep_id IS NOT NULL
	GROUP BY o.id
WITH NO DATA;
COMMENT ON MATERIALIZED VIEW qgis_pkg.',mview_name,' IS ''Mat. view of ',r.class_name,' ',t.lodx_name,' in schema ',citydb_schema,''';
CREATE INDEX ',mview_idx_name,' ON qgis_pkg.',mview_name,' (co_id);
CREATE INDEX ',mview_spx_name,' ON qgis_pkg.',mview_name,' USING gist (geom);
DELETE FROM qgis_pkg.layer_metadata WHERE v_name = ''',view_name,''';
INSERT INTO qgis_pkg.layer_metadata (schema_name, feature_type, qml_file, lod, root_class, layer_name, creation_date, mv_name, v_name) VALUES
(''',citydb_schema,''',''',feature_type,''',''',qml_file_name,''',''',t.lodx_label,''',''',r.class_name,''',''',l_name,''',clock_timestamp(),''',mview_name,''',''',view_name,''');
');
EXECUTE sql_statement;

	END LOOP; -- solitary_vegetat_object lod
END LOOP; -- solitary_vegetat_object

---------------------------------------------------------------
-- Create MATERIALIZED VIEW QGIS_PKG._G_**_PLANT_COVER_LOD1-4
---------------------------------------------------------------
FOR r IN 
	SELECT * FROM (VALUES
	('PlantCover'::varchar, 8::integer, 'plant_cover'::varchar)
	) AS t(class_name, class_id, class_label)
LOOP
	FOR t IN 
		SELECT * FROM (VALUES
		('LoD1'::varchar, 'lod1'::varchar),
		('LoD2'			, 'lod2'),
		('LoD3'			, 'lod3'),
		('LoD4'			, 'lod4')		
		) AS t(lodx_name, lodx_label)
	LOOP

l_name         := format(      '%I_%I',								r.class_label, t.lodx_label);
view_name      := format(   '%I_%I_%I',				citydb_schema, r.class_label, t.lodx_label);
mview_name     := format('_g_%I_%I_%I',				citydb_schema, r.class_label, t.lodx_label);
mview_idx_name := format('_g_%I_%I_%I_id_idx',		citydb_schema, r.class_label, t.lodx_label);
mview_spx_name := format('_g_%I_%I_%I_geom_spx',	citydb_schema, r.class_label, t.lodx_label);
qml_file_name  := concat(r.class_label,'_form.qml');

IF mview_bbox IS NOT NULL THEN
	sql_where := concat('AND ST_MakeEnvelope(',mview_bbox_xmin,', ',mview_bbox_ymin,', ',mview_bbox_xmax,', ',mview_bbox_ymax,', ',srid_id,') && co.envelope');
ELSE
	sql_where := NULL;
END IF;

sql_statement := concat('
DROP MATERIALIZED VIEW IF EXISTS qgis_pkg.',mview_name,' CASCADE;
CREATE MATERIALIZED VIEW         qgis_pkg.',mview_name,' AS
	SELECT
		sg.cityobject_id::bigint AS co_id,
		ST_Collect(qgis_pkg.ST_snap_poly_to_grid(sg.geometry,',perform_snapping,',',digits,',',area_poly_min,'))::geometry(MultiPolygonZ, ',srid_id,') AS geom
	FROM (
		SELECT
			o.id AS co_id, 	
			CASE
				WHEN o.',t.lodx_label,'_multi_solid_id IS NOT NULL THEN o.',t.lodx_label,'_multi_solid_id
				ELSE o.',t.lodx_label,'_multi_surface_id
			END	AS sg_id 
		FROM 
			',citydb_schema,'.plant_cover AS o
			INNER JOIN ',citydb_schema,'.cityobject AS co ON (o.id = co.id AND o.objectclass_id = ',r.class_id,' ',sql_where,') 
		WHERE 
			o.objectclass_id = ',r.class_id,'
			AND NOT(o.',t.lodx_label,'_multi_solid_id IS NULL AND o.',t.lodx_label,'_multi_surface_id IS NULL)
		) AS foo
		INNER JOIN ',citydb_schema,'.surface_geometry AS sg ON (sg.root_id = foo.sg_id AND sg.geometry IS NOT NULL)
	GROUP BY sg.cityobject_id
WITH NO DATA;
COMMENT ON MATERIALIZED VIEW qgis_pkg.',mview_name,' IS ''Mat. view of ',r.class_name,' ',t.lodx_name,' in schema ',citydb_schema,''';
CREATE INDEX ',mview_idx_name,' ON qgis_pkg.',mview_name,' (co_id);
CREATE INDEX ',mview_spx_name,' ON qgis_pkg.',mview_name,' USING gist (geom);
DELETE FROM qgis_pkg.layer_metadata WHERE v_name = ''',view_name,''';
INSERT INTO qgis_pkg.layer_metadata (schema_name, feature_type, qml_file, lod, root_class, layer_name, creation_date, mv_name, v_name) VALUES
(''',citydb_schema,''',''',feature_type,''',''',qml_file_name,''',''',t.lodx_label,''',''',r.class_name,''',''',l_name,''',clock_timestamp(),''',mview_name,''',''',view_name,''');
');
EXECUTE sql_statement;

	END LOOP; -- plat cover lod
END LOOP; -- plant cover


-- ***********************
-- LANDUSE MODULE
-- ***********************
feature_type     := 'LandUse';

---------------------------------------------------------------
-- Create MATERIALIZED VIEW QGIS_PKG._G_**_LAND_USE_LOD0-4
---------------------------------------------------------------
FOR r IN 
	SELECT * FROM (VALUES
	('LandUse'::varchar, 4::integer, 'land_use'::varchar)
	) AS t(class_name, class_id, class_label)
LOOP
	FOR t IN 
		SELECT * FROM (VALUES
		('LoD0'::varchar, 'lod0'::varchar),
		('LoD1'			, 'lod1'),
		('LoD2'			, 'lod2'),
		('LoD3'			, 'lod3'),
		('LoD4'			, 'lod4')		
		) AS t(lodx_name, lodx_label)
	LOOP

l_name         := format(      '%I_%I',								r.class_label, t.lodx_label);
view_name      := format(   '%I_%I_%I',				citydb_schema, r.class_label, t.lodx_label);
mview_name     := format('_g_%I_%I_%I',				citydb_schema, r.class_label, t.lodx_label);
mview_idx_name := format('_g_%I_%I_%I_id_idx',		citydb_schema, r.class_label, t.lodx_label);
mview_spx_name := format('_g_%I_%I_%I_geom_spx',	citydb_schema, r.class_label, t.lodx_label);
qml_file_name  := concat(r.class_label,'_form.qml');

IF mview_bbox IS NOT NULL THEN
	sql_where := concat('AND ST_MakeEnvelope(',mview_bbox_xmin,', ',mview_bbox_ymin,', ',mview_bbox_xmax,', ',mview_bbox_ymax,', ',srid_id,') && co.envelope');
ELSE
	sql_where := NULL;
END IF;

sql_statement := concat('
DROP MATERIALIZED VIEW IF EXISTS qgis_pkg.',mview_name,' CASCADE;
CREATE MATERIALIZED VIEW         qgis_pkg.',mview_name,' AS
	SELECT
		sg.cityobject_id::bigint AS co_id,
		ST_Collect(qgis_pkg.ST_snap_poly_to_grid(sg.geometry,',perform_snapping,',',digits,',',area_poly_min,'))::geometry(MultiPolygonZ, ',srid_id,') AS geom
	FROM 
		',citydb_schema,'.land_use AS o
		INNER JOIN ',citydb_schema,'.cityobject AS co ON (o.id = co.id AND o.objectclass_id = ',r.class_id,' ',sql_where,')
		INNER JOIN ',citydb_schema,'.surface_geometry AS sg ON (sg.root_id = o.',t.lodx_label,'_multi_surface_id AND sg.geometry IS NOT NULL)
	GROUP BY sg.cityobject_id
WITH NO DATA;
COMMENT ON MATERIALIZED VIEW qgis_pkg.',mview_name,' IS ''Mat. view of ',r.class_name,' ',t.lodx_name,' in schema ',citydb_schema,''';
CREATE INDEX ',mview_idx_name,' ON qgis_pkg.',mview_name,' (co_id);
CREATE INDEX ',mview_spx_name,' ON qgis_pkg.',mview_name,' USING gist (geom);
DELETE FROM qgis_pkg.layer_metadata WHERE v_name = ''',view_name,''';
INSERT INTO qgis_pkg.layer_metadata (schema_name, feature_type, qml_file, lod, root_class, layer_name, creation_date, mv_name, v_name) VALUES
(''',citydb_schema,''',''',feature_type,''',''',qml_file_name,''',''',t.lodx_label,''',''',r.class_name,''',''',l_name,''',clock_timestamp(),''',mview_name,''',''',view_name,''');
');
EXECUTE sql_statement;

	END LOOP; -- land use lod
END LOOP;  -- land use


-- ***********************
-- GENERIC CITYOBJECT MODULE
-- ***********************
feature_type     := 'Generics';

---------------------------------------------------------------
-- Create MATERIALIZED VIEW QGIS_PKG._G_**_GENERIC_CITYOBJECT_LOD0-4
---------------------------------------------------------------
FOR r IN 
	SELECT * FROM (VALUES
	('GenericCityObject'::varchar, 5::integer, 'gen_cityobject'::varchar)
	) AS t(class_name, class_id, class_label)
LOOP
	FOR t IN 
		SELECT * FROM (VALUES
		('LoD0'::varchar, 'lod0'::varchar),
		('LoD1'			, 'lod1'),
		('LoD2'			, 'lod2'),
		('LoD3'			, 'lod3'),
		('LoD4'			, 'lod4')		
		) AS t(lodx_name, lodx_label)
	LOOP

l_name         := format(      '%I_%I',								r.class_label, t.lodx_label);
view_name      := format(   '%I_%I_%I',				citydb_schema, r.class_label, t.lodx_label);
mview_name     := format('_g_%I_%I_%I',				citydb_schema, r.class_label, t.lodx_label);
mview_idx_name := format('_g_%I_%I_%I_id_idx',		citydb_schema, r.class_label, t.lodx_label);
mview_spx_name := format('_g_%I_%I_%I_geom_spx',	citydb_schema, r.class_label, t.lodx_label);
qml_file_name  := concat(r.class_label,'_form.qml');

IF mview_bbox IS NOT NULL THEN
	sql_where := concat('AND ST_MakeEnvelope(',mview_bbox_xmin,', ',mview_bbox_ymin,', ',mview_bbox_xmax,', ',mview_bbox_ymax,', ',srid_id,') && co.envelope');
ELSE
	sql_where := NULL;
END IF;

sql_statement := concat('
DROP MATERIALIZED VIEW IF EXISTS qgis_pkg.',mview_name,' CASCADE;
CREATE MATERIALIZED VIEW         qgis_pkg.',mview_name,' AS
	SELECT
		sg.cityobject_id::bigint AS co_id,
		ST_Collect(qgis_pkg.ST_snap_poly_to_grid(sg.geometry,',perform_snapping,',',digits,',',area_poly_min,'))::geometry(MultiPolygonZ, ',srid_id,') AS geom	
	FROM
		',citydb_schema,'.generic_cityobject AS o
		INNER JOIN ',citydb_schema,'.cityobject AS co ON (o.id = co.id AND o.objectclass_id = ',r.class_id,' ',sql_where,')
		INNER JOIN ',citydb_schema,'.surface_geometry AS sg ON (sg.root_id = o.',t.lodx_label,'_brep_id AND sg.geometry IS NOT NULL)
	WHERE
		o.',t.lodx_label,'_brep_id IS NOT NULL AND o.',t.lodx_label,'_implicit_rep_id IS NULL
	GROUP BY sg.cityobject_id
	UNION
	SELECT
		o.id::bigint AS co_id,
		ST_SetSRID(
			ST_Affine(ST_Collect(sg.implicit_geometry),
				   split_part(',t.lodx_label,'_implicit_transformation, '' '', 1)::double precision,
				   0,0,0,
				   split_part(',t.lodx_label,'_implicit_transformation, '' '', 6)::double precision,
				   0,0,0,
				   split_part(',t.lodx_label,'_implicit_transformation, '' '', 11)::double precision,
				   ST_X(o.',t.lodx_label,'_implicit_ref_point),
				   ST_Y(o.',t.lodx_label,'_implicit_ref_point),
				   ST_Z(o.',t.lodx_label,'_implicit_ref_point)
				   ),
			',srid_id,')::geometry(MultiPolygonZ, ',srid_id,') AS geom
	FROM 
		',citydb_schema,'.generic_cityobject AS o
		INNER JOIN ',citydb_schema,'.cityobject AS co ON (o.id=co.id AND o.objectclass_id = ',r.class_id,' ',sql_where,')	
		INNER JOIN ',citydb_schema,'.implicit_geometry AS ig ON (ig.id = o.',t.lodx_label,'_implicit_rep_id)
		INNER JOIN ',citydb_schema,'.surface_geometry AS sg ON (sg.root_id = ig.relative_brep_id AND sg.implicit_geometry IS NOT NULL)
	WHERE
		o.',t.lodx_label,'_implicit_rep_id IS NOT NULL
	GROUP BY o.id
WITH NO DATA;
COMMENT ON MATERIALIZED VIEW qgis_pkg.',mview_name,' IS ''Mat. view of ',r.class_name,' ',t.lodx_name,' in schema ',citydb_schema,''';
CREATE INDEX ',mview_idx_name,' ON qgis_pkg.',mview_name,' (co_id);
CREATE INDEX ',mview_spx_name,' ON qgis_pkg.',mview_name,' USING gist (geom);
DELETE FROM qgis_pkg.layer_metadata WHERE v_name = ''',view_name,''';
INSERT INTO qgis_pkg.layer_metadata (schema_name, feature_type, qml_file, lod, root_class, layer_name, creation_date, mv_name, v_name) VALUES
(''',citydb_schema,''',''',feature_type,''',''',qml_file_name,''',''',t.lodx_label,''',''',r.class_name,''',''',l_name,''',clock_timestamp(),''',mview_name,''',''',view_name,''');
');
EXECUTE sql_statement;

	END LOOP; -- generic city object lod
END LOOP; -- generic city object


-- ***********************
-- GENERIC CITYFURNITURE MODULE
-- ***********************
feature_type     := 'CityFurniture';

---------------------------------------------------------------
-- Create MATERIALIZED VIEW QGIS_PKG._G_**_CITY_FURNITURE_LOD1-4
---------------------------------------------------------------
FOR r IN 
	SELECT * FROM (VALUES
	('CityFurniture'::varchar, 21::integer, 'city_furniture'::varchar)
	) AS t(class_name, class_id, class_label)
LOOP
	FOR t IN 
		SELECT * FROM (VALUES
		('LoD1'::varchar, 'lod1'::varchar),
		('LoD2'			, 'lod2'),
		('LoD3'			, 'lod3'),
		('LoD4'			, 'lod4')		
		) AS t(lodx_name, lodx_label)
	LOOP

l_name         := format(      '%I_%I',								r.class_label, t.lodx_label);
view_name      := format(   '%I_%I_%I',				citydb_schema, r.class_label, t.lodx_label);
mview_name     := format('_g_%I_%I_%I',				citydb_schema, r.class_label, t.lodx_label);
mview_idx_name := format('_g_%I_%I_%I_id_idx',		citydb_schema, r.class_label, t.lodx_label);
mview_spx_name := format('_g_%I_%I_%I_geom_spx',	citydb_schema, r.class_label, t.lodx_label);
qml_file_name  := concat(r.class_label,'_form.qml');

IF mview_bbox IS NOT NULL THEN
	sql_where := concat('AND ST_MakeEnvelope(',mview_bbox_xmin,', ',mview_bbox_ymin,', ',mview_bbox_xmax,', ',mview_bbox_ymax,', ',srid_id,') && co.envelope');
ELSE
	sql_where := NULL;
END IF;

sql_statement := concat('
DROP MATERIALIZED VIEW IF EXISTS qgis_pkg.',mview_name,' CASCADE;
CREATE MATERIALIZED VIEW         qgis_pkg.',mview_name,' AS
	SELECT
		sg.cityobject_id::bigint AS co_id,
		ST_Collect(qgis_pkg.ST_snap_poly_to_grid(sg.geometry,',perform_snapping,',',digits,',',area_poly_min,'))::geometry(MultiPolygonZ, ',srid_id,') AS geom	
	FROM
		',citydb_schema,'.city_furniture AS o
		INNER JOIN ',citydb_schema,'.cityobject AS co ON (o.id = co.id AND o.objectclass_id = ',r.class_id,' ',sql_where,')
		INNER JOIN ',citydb_schema,'.surface_geometry AS sg ON (sg.root_id = o.',t.lodx_label,'_brep_id AND sg.geometry IS NOT NULL)
	WHERE
		o.',t.lodx_label,'_brep_id IS NOT NULL AND o.',t.lodx_label,'_implicit_rep_id IS NULL 
	GROUP BY sg.cityobject_id
	UNION
	SELECT
		o.id::bigint AS co_id,
		ST_SetSRID(
			ST_Affine(ST_Collect(sg.implicit_geometry),
				   split_part(',t.lodx_label,'_implicit_transformation, '' '', 1)::double precision,
				   0,0,0,
				   split_part(',t.lodx_label,'_implicit_transformation, '' '', 6)::double precision,
				   0,0,0,
				   split_part(',t.lodx_label,'_implicit_transformation, '' '', 11)::double precision,
				   ST_X(o.',t.lodx_label,'_implicit_ref_point),
				   ST_Y(o.',t.lodx_label,'_implicit_ref_point),
				   ST_Z(o.',t.lodx_label,'_implicit_ref_point)
				   ),
			',srid_id,')::geometry(MultiPolygonZ, ',srid_id,') AS geom
	FROM 
		',citydb_schema,'.city_furniture AS o
		INNER JOIN ',citydb_schema,'.cityobject AS co ON (o.id=co.id AND o.objectclass_id = ',r.class_id,' ',sql_where,')	
		INNER JOIN ',citydb_schema,'.implicit_geometry AS ig ON (ig.id = o.',t.lodx_label,'_implicit_rep_id)
		INNER JOIN ',citydb_schema,'.surface_geometry AS sg ON (sg.root_id = ig.relative_brep_id AND sg.implicit_geometry IS NOT NULL)
	WHERE
		o.',t.lodx_label,'_implicit_rep_id IS NOT NULL
	GROUP BY o.id
WITH NO DATA;
COMMENT ON MATERIALIZED VIEW qgis_pkg.',mview_name,' IS ''Mat. view of ',r.class_name,' ',t.lodx_name,' in schema ',citydb_schema,''';
CREATE INDEX ',mview_idx_name,' ON qgis_pkg.',mview_name,' (co_id);
CREATE INDEX ',mview_spx_name,' ON qgis_pkg.',mview_name,' USING gist (geom);
DELETE FROM qgis_pkg.layer_metadata WHERE v_name = ''',view_name,''';
INSERT INTO qgis_pkg.layer_metadata (schema_name, feature_type, qml_file, lod, root_class, layer_name, creation_date, mv_name, v_name) VALUES
(''',citydb_schema,''',''',feature_type,''',''',qml_file_name,''',''',t.lodx_label,''',''',r.class_name,''',''',l_name,''',clock_timestamp(),''',mview_name,''',''',view_name,''');
');
EXECUTE sql_statement;

	END LOOP; -- city furniture lod
END LOOP; -- city furniture 

-- ***********************
-- RELIEF MODULE
-- ***********************
feature_type     := 'Relief';

---------------------------------------------------------------
-- Create MATERIALIZED VIEW QGIS_PKG._G_**_RELIEF_FEATURE_LOD0-4
---------------------------------------------------------------
FOR r IN 
	SELECT * FROM (VALUES
	('ReliefFeature'::varchar, 14::integer, 'relief_feature'::varchar)
	) AS t(class_name, class_id, class_label)
LOOP
	FOR t IN 
		SELECT * FROM (VALUES
		('LoD0'::varchar, 'lod0'::varchar, 0::integer),
		('LoD1'			, 'lod1'		 , 1),
		('LoD2'			, 'lod2'		 , 2),
		('LoD3'			, 'lod3'		 , 3),
		('LoD4'			, 'lod4'		 , 4)			
		) AS t(lodx_name, lodx_label, lodx_integer)
	LOOP

l_name         := format(      '%I_%I',								r.class_label, t.lodx_label);
view_name      := format(   '%I_%I_%I',				citydb_schema, r.class_label, t.lodx_label);
mview_name     := format('_g_%I_%I_%I',				citydb_schema, r.class_label, t.lodx_label);
mview_idx_name := format('_g_%I_%I_%I_id_idx',		citydb_schema, r.class_label, t.lodx_label);
mview_spx_name := format('_g_%I_%I_%I_geom_spx',	citydb_schema, r.class_label, t.lodx_label);
qml_file_name  := concat(r.class_label,'_form.qml');

IF mview_bbox IS NOT NULL THEN
	sql_where := concat('AND ST_MakeEnvelope(',mview_bbox_xmin,', ',mview_bbox_ymin,', ',mview_bbox_xmax,', ',mview_bbox_ymax,', ',srid_id,') && co.envelope');
ELSE
	sql_where := NULL;
END IF;

sql_statement := concat('
DROP MATERIALIZED VIEW IF EXISTS qgis_pkg.',mview_name,' CASCADE;
CREATE MATERIALIZED VIEW         qgis_pkg.',mview_name,' AS
	SELECT
		o.id::bigint AS co_id,
		co.envelope::geometry(PolygonZ, ',srid_id,') AS geom	
	FROM
		',citydb_schema,'.relief_feature AS o
		INNER JOIN ',citydb_schema,'.cityobject AS co ON (o.id = co.id AND o.objectclass_id = ',r.class_id,' ',sql_where,')
	WHERE
		lod = ',t.lodx_integer,' 
WITH NO DATA;
COMMENT ON MATERIALIZED VIEW qgis_pkg.',mview_name,' IS ''Mat. view of ',r.class_name,' ',t.lodx_name,' in schema ',citydb_schema,''';
CREATE INDEX ',mview_idx_name,' ON qgis_pkg.',mview_name,' (co_id);
CREATE INDEX ',mview_spx_name,' ON qgis_pkg.',mview_name,' USING gist (geom);
DELETE FROM qgis_pkg.layer_metadata WHERE v_name = ''',view_name,''';
INSERT INTO qgis_pkg.layer_metadata (schema_name, feature_type, qml_file, lod, root_class, layer_name, creation_date, mv_name, v_name) VALUES
(''',citydb_schema,''',''',feature_type,''',''',qml_file_name,''',''',t.lodx_label,''',''',r.class_name,''',''',l_name,''',clock_timestamp(),''',mview_name,''',''',view_name,''');
');
EXECUTE sql_statement;

	END LOOP; -- relief feature lod
END LOOP; -- relief feature

---------------------------------------------------------------
-- Create MATERIALIZED VIEW QGIS_PKG._G_**_TIN_RELIEF_LOD0-4
---------------------------------------------------------------
FOR r IN 
	SELECT * FROM (VALUES
	('TINRelief'::varchar, 16::integer, 'tin_relief'::varchar)
	) AS t(class_name, class_id, class_label)
LOOP
	FOR t IN 
		SELECT * FROM (VALUES
		('LoD0'::varchar, 'lod0'::varchar, 0::integer),
		('LoD1'			, 'lod1'		 , 1),
		('LoD2'			, 'lod2'		 , 2),
		('LoD3'			, 'lod3'		 , 3),
		('LoD4'			, 'lod4'		 , 4)			
		) AS t(lodx_name, lodx_label, lodx_integer)
	LOOP

l_name         := format(      '%I_%I',								r.class_label, t.lodx_label);
view_name      := format(   '%I_%I_%I',				citydb_schema, r.class_label, t.lodx_label);
mview_name     := format('_g_%I_%I_%I',				citydb_schema, r.class_label, t.lodx_label);
mview_idx_name := format('_g_%I_%I_%I_id_idx',		citydb_schema, r.class_label, t.lodx_label);
mview_spx_name := format('_g_%I_%I_%I_geom_spx',	citydb_schema, r.class_label, t.lodx_label);
qml_file_name  := concat(r.class_label,'_form.qml');

IF mview_bbox IS NOT NULL THEN
	sql_where := concat('AND ST_MakeEnvelope(',mview_bbox_xmin,', ',mview_bbox_ymin,', ',mview_bbox_xmax,', ',mview_bbox_ymax,', ',srid_id,') && co.envelope');
ELSE
	sql_where := NULL;
END IF;

sql_statement := concat('
DROP MATERIALIZED VIEW IF EXISTS qgis_pkg.',mview_name,' CASCADE;
CREATE MATERIALIZED VIEW         qgis_pkg.',mview_name,' AS
	SELECT
		sg.cityobject_id::bigint AS co_id,
		ST_Collect(qgis_pkg.ST_snap_poly_to_grid(sg.geometry,',perform_snapping,',',digits,',',area_poly_min,'))::geometry(MultiPolygonZ, ',srid_id,') AS geom	
	FROM
		',citydb_schema,'.tin_relief AS o
		INNER JOIN ',citydb_schema,'.cityobject AS co ON (o.id = co.id AND o.objectclass_id = ',r.class_id,' ',sql_where,')
		INNER JOIN ',citydb_schema,'.relief_component AS o2 ON (o2.id = o.id AND o2.lod = ',t.lodx_integer,')
		INNER JOIN ',citydb_schema,'.surface_geometry AS sg ON (sg.root_id = o.surface_geometry_id AND sg.geometry IS NOT NULL) 
	GROUP BY sg.cityobject_id
WITH NO DATA;
COMMENT ON MATERIALIZED VIEW qgis_pkg.',mview_name,' IS ''Mat. view of ',r.class_name,' ',t.lodx_name,' in schema ',citydb_schema,''';
CREATE INDEX ',mview_idx_name,' ON qgis_pkg.',mview_name,' (co_id);
CREATE INDEX ',mview_spx_name,' ON qgis_pkg.',mview_name,' USING gist (geom);
DELETE FROM qgis_pkg.layer_metadata WHERE v_name = ''',view_name,''';
INSERT INTO qgis_pkg.layer_metadata (schema_name, feature_type, qml_file, lod, root_class, layer_name, creation_date, mv_name, v_name) VALUES
(''',citydb_schema,''',''',feature_type,''',''',qml_file_name,''',''',t.lodx_label,''',''',r.class_name,''',''',l_name,''',clock_timestamp(),''',mview_name,''',''',view_name,''');
');
EXECUTE sql_statement;

	END LOOP; -- tin relief lod
END LOOP;  -- tin relief


-- ***********************
-- BRIDGE MODULE
-- ***********************
feature_type     := 'Bridge';

FOR r IN 
	SELECT * FROM (VALUES
	('Bridge'::varchar, 64::integer, 'bri'::varchar),
	('BridgePart'     , 63         , 'bri_part')		   
	) AS t(class_name, class_id, class_label)
LOOP

---------------------------------------------------------------
-- Create MATERIALIZED VIEW QGIS_PKG._G_*_BRIDGE(PART)_LOD1
---------------------------------------------------------------
l_name         := format(      '%I_lod1',							r.class_label);
view_name      := format(   '%I_%I_lod1',			citydb_schema, r.class_label);
mview_name     := format('_g_%I_%I_lod1',			citydb_schema, r.class_label);
mview_idx_name := format('_g_%I_%I_lod1_id_idx',	citydb_schema, r.class_label);
mview_spx_name := format('_g_%I_%I_lod1_geom_spx',	citydb_schema, r.class_label);
qml_file_name  := concat(r.class_label,'_form.qml');

IF mview_bbox IS NOT NULL THEN
	sql_where := concat('AND ST_MakeEnvelope(',mview_bbox_xmin,', ',mview_bbox_ymin,', ',mview_bbox_xmax,', ',mview_bbox_ymax,', ',srid_id,') && co.envelope');
ELSE
	sql_where := NULL;
END IF;

sql_statement := concat('
DROP MATERIALIZED VIEW IF EXISTS qgis_pkg.',mview_name,' CASCADE;
CREATE MATERIALIZED VIEW         qgis_pkg.',mview_name,' AS
	SELECT
		sg.cityobject_id::bigint AS co_id,
		ST_Collect(qgis_pkg.ST_snap_poly_to_grid(sg.geometry,',perform_snapping,',',digits,',',area_poly_min,'))::geometry(MultiPolygonZ, ',srid_id,') AS geom	
	FROM (
		SELECT
			o.id AS co_id, 	
			CASE
				WHEN o.lod1_solid_id IS NOT NULL THEN o.lod1_solid_id
				ELSE o.lod1_multi_surface_id
			END	AS sg_id 
		FROM 
			',citydb_schema,'.bridge AS o
			INNER JOIN ',citydb_schema,'.cityobject AS co ON (o.id=co.id AND o.objectclass_id = ',r.class_id,' ',sql_where,') 
		WHERE			
			NOT(o.lod1_solid_id IS NULL AND o.lod1_multi_surface_id IS NULL)
		) AS foo
		INNER JOIN ',citydb_schema,'.surface_geometry AS sg ON (sg.root_id = foo.sg_id AND sg.geometry IS NOT NULL)
	GROUP BY sg.cityobject_id
WITH NO DATA;
COMMENT ON MATERIALIZED VIEW qgis_pkg.',mview_name,' IS ''Mat. view of ',r.class_name,' LoD1 in schema ',citydb_schema,''';
CREATE INDEX ',mview_idx_name,' ON qgis_pkg.',mview_name,' (co_id);
CREATE INDEX ',mview_spx_name,' ON qgis_pkg.',mview_name,' USING gist (geom);
DELETE FROM qgis_pkg.layer_metadata WHERE v_name = ''',view_name,''';
INSERT INTO qgis_pkg.layer_metadata (schema_name, feature_type, qml_file, lod, root_class, layer_name, creation_date, mv_name, v_name) VALUES
(''',citydb_schema,''',''',feature_type,''',''',qml_file_name,''',''lod1'',''',r.class_name,''',''',l_name,''',clock_timestamp(),''',mview_name,''',''',view_name,''');
');
EXECUTE sql_statement;

---------------------------------------------------------------
-- Create MATERIALIZED VIEW QGIS_PKG._G_*_BRIDGE(PART)_LOD2-4
---------------------------------------------------------------
	FOR t IN 
		SELECT * FROM (VALUES
		('LoD2'::varchar, 'lod2'::varchar),
		('LoD3'			, 'lod3'),
		('LoD4'			, 'lod4')		
		) AS t(lodx_name, lodx_label)
	LOOP

l_name         := format(      '%I_%I',								r.class_label, t.lodx_label);
view_name      := format(   '%I_%I_%I',				citydb_schema, r.class_label, t.lodx_label);
mview_name     := format('_g_%I_%I_%I', 			citydb_schema, r.class_label, t.lodx_label);
mview_idx_name := format('_g_%I_%I_%I_id_idx',  	citydb_schema, r.class_label, t.lodx_label);
mview_spx_name := format('_g_%I_%I_%I_geom_spx',	citydb_schema, r.class_label, t.lodx_label);
qml_file_name  := concat(r.class_label,'_form.qml');

IF mview_bbox IS NOT NULL THEN
	sql_where := concat('AND ST_MakeEnvelope(',mview_bbox_xmin,', ',mview_bbox_ymin,', ',mview_bbox_xmax,', ',mview_bbox_ymax,', ',srid_id,') && co.envelope');
ELSE
	sql_where := NULL;
END IF;

sql_statement := concat('
DROP MATERIALIZED VIEW IF EXISTS qgis_pkg.',mview_name,' CASCADE;
CREATE MATERIALIZED VIEW         qgis_pkg.',mview_name,' AS
	SELECT
		foo2.co_id::bigint AS co_id,
		ST_Collect(qgis_pkg.ST_snap_poly_to_grid(sg.geometry,',perform_snapping,',',digits,',',area_poly_min,'))::geometry(MultiPolygonZ, ',srid_id,') AS geom	
	FROM (
		SELECT
			foo.co_id,
			unnest(foo.sg_id_array) AS sg_id
		FROM (
			SELECT
				-- coalesce(o.id, ts_t.co_id) as co_id,
				o.id AS co_id,
				CASE 
					WHEN ts_t.sg_id_array IS NOT NULL THEN ts_t.sg_id_array
					WHEN o.',t.lodx_label,'_solid_id IS NOT NULL THEN ARRAY[o.',t.lodx_label,'_solid_id]
					ELSE ARRAY[o.',t.lodx_label,'_multi_surface_id]
				END AS sg_id_array 
			FROM 
				',citydb_schema,'.bridge AS o
				INNER JOIN ',citydb_schema,'.cityobject AS co ON (o.id = co.id AND o.objectclass_id= ',r.class_id,' ',sql_where,')
				-- FULL OUTER JOIN
				INNER JOIN (
					SELECT ts.bridge_id AS co_id, array_agg(ts.',t.lodx_label,'_multi_surface_id) AS sg_id_array 
					FROM 
						',citydb_schema,'.bridge_thematic_surface AS ts
						INNER JOIN ',citydb_schema,'.cityobject AS co ON (co.id = ts.id ',sql_where,')
						INNER JOIN ',citydb_schema,'.bridge AS b1 ON (ts.bridge_id = b1.id AND b1.objectclass_id = ',r.class_id,')	
					GROUP BY ts.bridge_id
					) AS ts_t ON (ts_t.co_id = o.id)
			WHERE 
				sg_id_array IS NOT NULL
			) AS foo
		) AS foo2
		INNER JOIN ',citydb_schema,'.surface_geometry AS sg ON (sg.root_id = foo2.sg_id AND sg.geometry IS NOT NULL)
	GROUP BY foo2.co_id
WITH NO DATA;
COMMENT ON MATERIALIZED VIEW qgis_pkg.',mview_name,' IS ''Mat. view of ',r.class_name,' ',t.lodx_name,' in schema ',citydb_schema,''';
CREATE INDEX ',mview_idx_name,' ON qgis_pkg.',mview_name,' (co_id);
CREATE INDEX ',mview_spx_name,' ON qgis_pkg.',mview_name,' USING gist (geom);
DELETE FROM qgis_pkg.layer_metadata WHERE v_name = ''',view_name,''';
INSERT INTO qgis_pkg.layer_metadata (schema_name, feature_type, qml_file, lod, root_class, layer_name, creation_date, mv_name, v_name) VALUES
(''',citydb_schema,''',''',feature_type,''',''',qml_file_name,''',''',t.lodx_label,''',''',r.class_name,''',''',l_name,''',clock_timestamp(),''',mview_name,''',''',view_name,''');
');
EXECUTE sql_statement;

---------------------------------------------------------------
-- Create MATERIALIZED VIEW QGIS_PKG._G_*_BRIDGE(PART)_LOD2-4_THEMATIC_SURFACES
---------------------------------------------------------------
		FOR u IN 
			SELECT * FROM (VALUES
			('BridgeRoofSurface'::varchar , 71::integer, 'roofsurf'::varchar),
			('BridgeWallSurface'		  , 72		   , 'wallsurf'),
			('BridgeGroundSurface'		  , 73		   , 'groundsurf'),
			('BridgeClosureSurface'		  , 74		   , 'closuresurf'),
			('OuterBridgeCeilingSurface'  , 75		   , 'outerceilingsurf'),
			('OuterBridgeFloorSurface'	  , 66		   , 'outerfloorsurf')
			) AS t(themsurf_name, class_id, themsurf_label)
		LOOP

l_name         := format(      '%I_%I_%I',							r.class_label, t.lodx_label, u.themsurf_label);
view_name      := format(   '%I_%I_%I_%I',			citydb_schema, r.class_label, t.lodx_label, u.themsurf_label);
mview_name     := format('_g_%I_%I_%I_%I', 			citydb_schema, r.class_label, t.lodx_label, u.themsurf_label);
mview_idx_name := format('_g_%I_%I_%I_%I_id_idx',   citydb_schema, r.class_label, t.lodx_label, u.themsurf_label);
mview_spx_name := format('_g_%I_%I_%I_%I_geom_spx',	citydb_schema, r.class_label, t.lodx_label, u.themsurf_label);
qml_file_name  := concat(r.class_label,'_them_surf_form.qml');

IF mview_bbox IS NOT NULL THEN
	sql_where := concat('AND ST_MakeEnvelope(',mview_bbox_xmin,', ',mview_bbox_ymin,', ',mview_bbox_xmax,', ',mview_bbox_ymax,', ',srid_id,') && co.envelope');
ELSE
	sql_where := NULL;
END IF;

sql_statement := concat('
DROP MATERIALIZED VIEW IF EXISTS qgis_pkg.',mview_name,' CASCADE;
CREATE MATERIALIZED VIEW         qgis_pkg.',mview_name,' AS
	SELECT
		sg.cityobject_id::bigint AS co_id,
		ST_Collect(qgis_pkg.ST_snap_poly_to_grid(sg.geometry,',perform_snapping,',',digits,',',area_poly_min,'))::geometry(MultiPolygonZ, ',srid_id,') AS geom
	FROM
		',citydb_schema,'.bridge_thematic_surface AS o
		INNER JOIN ',citydb_schema,'.cityobject AS co ON (o.id = co.id AND o.objectclass_id = ',u.class_id,' ',sql_where,')		
		INNER JOIN ',citydb_schema,'.bridge AS b ON (o.bridge_id = b.id AND b.objectclass_id = ',r.class_id,')
		INNER JOIN ',citydb_schema,'.surface_geometry AS sg ON (sg.root_id = o.',t.lodx_name,'_multi_surface_id AND sg.geometry IS NOT NULL)
	GROUP BY sg.cityobject_id
WITH NO DATA;
COMMENT ON MATERIALIZED VIEW qgis_pkg.',mview_name,' IS ''Mat. view of (',r.class_name,') ',t.lodx_name,' ',u.themsurf_name,' in schema ',citydb_schema,''';
CREATE INDEX ',mview_idx_name,' ON qgis_pkg.',mview_name,' (co_id);
CREATE INDEX ',mview_spx_name,' ON qgis_pkg.',mview_name,' USING gist (geom);
DELETE FROM qgis_pkg.layer_metadata WHERE v_name = ''',view_name,''';
INSERT INTO qgis_pkg.layer_metadata (schema_name, feature_type, qml_file, lod, root_class, layer_name, creation_date, mv_name, v_name) VALUES
(''',citydb_schema,''',''',feature_type,''',''',qml_file_name,''',''',t.lodx_label,''',''',r.class_name,''',''',l_name,''',clock_timestamp(),''',mview_name,''',''',view_name,''');
');
EXECUTE sql_statement;

		END LOOP; -- bridge thematic surface
	END LOOP; -- bridge lod2-4

---------------------------------------------------------------
-- Create MATERIALIZED VIEW QGIS_PKG._G_**_BRIDGE_INSTALLATION_**_LOD2-4
---------------------------------------------------------------
	FOR s IN 
		SELECT * FROM (VALUES
		('BridgeInstallation'::varchar, 65::integer, 'out_inst'::varchar)
		) AS t(class_name, class_id, class_label)
	LOOP
		FOR t IN 
			SELECT * FROM (VALUES
			('LoD2'::varchar, 'lod2'::varchar),
			('LoD3'			, 'lod3'),
			('LoD4'			, 'lod4')		
			) AS t(lodx_name, lodx_label)
		LOOP

l_name         := format(      '%I_%I_%I',							r.class_label, s.class_label, t.lodx_label);
view_name      := format(   '%I_%I_%I_%I',			citydb_schema, r.class_label, s.class_label, t.lodx_label);
mview_name     := format('_g_%I_%I_%I_%I',			citydb_schema, r.class_label, s.class_label, t.lodx_label);
mview_idx_name := format('_g_%I_%I_%I_%I_id_idx',	citydb_schema, r.class_label, s.class_label, t.lodx_label);
mview_spx_name := format('_g_%I_%I_%I_%I_geom_spx',	citydb_schema, r.class_label, s.class_label, t.lodx_label);
qml_file_name  := concat(r.class_label,'_',s.class_label,'_form.qml');

IF mview_bbox IS NOT NULL THEN
	sql_where := concat('AND ST_MakeEnvelope(',mview_bbox_xmin,', ',mview_bbox_ymin,', ',mview_bbox_xmax,', ',mview_bbox_ymax,', ',srid_id,') && co.envelope');
ELSE
	sql_where := NULL;
END IF;

sql_statement := concat('
DROP MATERIALIZED VIEW IF EXISTS qgis_pkg.',mview_name,' CASCADE;
CREATE MATERIALIZED VIEW         qgis_pkg.',mview_name,' AS
	SELECT 
		foo2.co_id AS co_id,
		st_collect(qgis_pkg.ST_snap_poly_to_grid(sg.geometry,',perform_snapping,',',digits,',',area_poly_min,'))::geometry(MultiPolygonZ, ',srid_id,') AS geom
	FROM ( 
			SELECT 
				foo.co_id,
				unnest(foo.sg_id_array) AS sg_id
			FROM ( 
					SELECT
						o.id AS co_id,
						CASE
							WHEN ts_t.sg_id_array IS NOT NULL THEN ts_t.sg_id_array
							ELSE ARRAY[o.',t.lodx_label,'_brep_id]
						END AS sg_id_array
					FROM 
						',citydb_schema,'.bridge_installation AS o
						INNER JOIN ',citydb_schema,'.cityobject AS co ON (o.id = co.id AND o.objectclass_id = ',s.class_id,' ',sql_where,')
						INNER JOIN (
							SELECT
								o.bridge_installation_id AS co_id,
								array_agg(o.',t.lodx_label,'_multi_surface_id) AS sg_id_array
							FROM 
								',citydb_schema,'.bridge_thematic_surface AS o
								INNER JOIN ',citydb_schema,'.cityobject AS co ON (co.id = o.id ',sql_where,')
								INNER JOIN ',citydb_schema,'.bridge AS b ON (o.bridge_id = b.id AND b.objectclass_id = ',r.class_id,')
							WHERE 
								o.bridge_installation_id IS NOT NULL
							GROUP BY o.bridge_installation_id
						) AS ts_t ON (ts_t.co_id = o.id)
					WHERE
						o.',t.lodx_label,'_implicit_rep_id IS NULL
				) AS foo
	   ) AS foo2
	INNER JOIN ',citydb_schema,'.surface_geometry AS sg ON (sg.root_id = foo2.sg_id AND sg.geometry IS NOT NULL)
	GROUP BY foo2.co_id
	UNION');
-- the need to split is due to max 100 arguments allowed in the concat function.
sql_statement := concat(sql_statement,'	
	SELECT
		o.id::bigint AS co_id,
		ST_SetSRID(
			ST_Affine(ST_Collect(sg.implicit_geometry),
				   split_part(o.',t.lodx_label,'_implicit_transformation, '' '', 1)::double precision,
				   0,0,0,
				   split_part(o.',t.lodx_label,'_implicit_transformation, '' '', 6)::double precision,
				   0,0,0,
				   split_part(o.',t.lodx_label,'_implicit_transformation, '' '', 11)::double precision,
				   ST_X(o.',t.lodx_label,'_implicit_ref_point),
				   ST_Y(o.',t.lodx_label,'_implicit_ref_point),
				   ST_Z(o.',t.lodx_label,'_implicit_ref_point)
				   ),
			',srid_id,')::geometry(MultiPolygonZ, ',srid_id,') AS geom
	FROM 
		',citydb_schema,'.bridge_installation AS o
		INNER JOIN ',citydb_schema,'.cityobject AS co ON (o.id = co.id AND o.objectclass_id = ',s.class_id,' ',sql_where,')
		INNER JOIN ',citydb_schema,'.bridge AS b ON (b.id = o.bridge_id AND b.objectclass_id = ',r.class_id,')
		INNER JOIN ',citydb_schema,'.implicit_geometry AS ig ON (ig.id = o.',t.lodx_label,'_implicit_rep_id)
		INNER JOIN ',citydb_schema,'.surface_geometry AS sg ON (sg.root_id = ig.relative_brep_id AND sg.implicit_geometry IS NOT NULL)
	WHERE
		o.',t.lodx_label,'_implicit_rep_id IS NOT NULL
	GROUP BY o.id
WITH NO DATA;
COMMENT ON MATERIALIZED VIEW qgis_pkg.',mview_name,' IS ''Mat. view of ',s.class_name,' ',t.lodx_name,' in schema ',citydb_schema,''';
CREATE INDEX ',mview_idx_name,' ON qgis_pkg.',mview_name,' (co_id);
CREATE INDEX ',mview_spx_name,' ON qgis_pkg.',mview_name,' USING gist (geom);
DELETE FROM qgis_pkg.layer_metadata WHERE v_name = ''',view_name,''';
INSERT INTO qgis_pkg.layer_metadata (schema_name, feature_type, qml_file, lod, root_class, layer_name, creation_date, mv_name, v_name) VALUES
(''',citydb_schema,''',''',feature_type,''',''',qml_file_name,''',''',t.lodx_label,''',''',s.class_name,''',''',l_name,''',clock_timestamp(),''',mview_name,''',''',view_name,''');
');
EXECUTE sql_statement;

---------------------------------------------------------------
-- Create MATERIALIZED VIEW QGIS_PKG._G_*_BRIDGE_INSTALLATION_LOD2-4_THEMATIC_SURFACES
---------------------------------------------------------------
			FOR u IN 
				SELECT * FROM (VALUES
				('BridgeRoofSurface'::varchar , 71::integer, 'roofsurf'::varchar),
				('BridgeWallSurface'		  , 72		   , 'wallsurf'),
				('BridgeGroundSurface'		  , 73		   , 'groundsurf'),
				('BridgeClosureSurface'		  , 74		   , 'closuresurf'),
				('OuterBridgeCeilingSurface'  , 75		   , 'outerceilingsurf'),
				('OuterBridgeFloorSurface'	  , 66		   , 'outerfloorsurf')
				) AS t(themsurf_name, class_id, themsurf_label)
			LOOP

l_name         := format(      '%I_%I_%I_%I',							r.class_label, s.class_label, t.lodx_label, u.themsurf_label);
view_name      := format(   '%I_%I_%I_%I_%I',			citydb_schema, r.class_label, s.class_label, t.lodx_label, u.themsurf_label);
mview_name     := format('_g_%I_%I_%I_%I_%I',			citydb_schema, r.class_label, s.class_label, t.lodx_label, u.themsurf_label);
mview_idx_name := format('_g_%I_%I_%I_%I_%I_id_idx',	citydb_schema, r.class_label, s.class_label, t.lodx_label, u.themsurf_label);
mview_spx_name := format('_g_%I_%I_%I_%I_%I_geom_spx',	citydb_schema, r.class_label, s.class_label, t.lodx_label, u.themsurf_label);
qml_file_name  := concat(r.class_label,'_',s.class_label,'_them_surf_form.qml');

IF mview_bbox IS NOT NULL THEN
	sql_where := concat('AND ST_MakeEnvelope(',mview_bbox_xmin,', ',mview_bbox_ymin,', ',mview_bbox_xmax,', ',mview_bbox_ymax,', ',srid_id,') && co.envelope');
ELSE
	sql_where := NULL;
END IF;

sql_statement := concat('
DROP MATERIALIZED VIEW IF EXISTS qgis_pkg.',mview_name,' CASCADE;
CREATE MATERIALIZED VIEW         qgis_pkg.',mview_name,' AS
	SELECT
		sg.cityobject_id::bigint AS co_id,
		ST_Collect(qgis_pkg.ST_snap_poly_to_grid(sg.geometry,',perform_snapping,',',digits,',',area_poly_min,'))::geometry(MultiPolygonZ,',srid_id,') AS geom
	FROM
		',citydb_schema,'.bridge_thematic_surface AS o
		INNER JOIN ',citydb_schema,'.cityobject AS co ON (o.id = co.id AND o.objectclass_id = ',u.class_id,' ',sql_where,') 
		INNER JOIN ',citydb_schema,'.bridge_installation AS bi ON (o.bridge_installation_id = bi.id AND bi.objectclass_id = ',s.class_id,')
		INNER JOIN ',citydb_schema,'.bridge AS b ON (o.bridge_id = b.id AND b.objectclass_id = ',r.class_id,')		
		INNER JOIN ',citydb_schema,'.surface_geometry AS sg ON (sg.root_id = o.',t.lodx_name,'_multi_surface_id  AND sg.geometry IS NOT NULL)
	GROUP BY sg.cityobject_id
WITH NO DATA;
COMMENT ON MATERIALIZED VIEW qgis_pkg.',mview_name,' IS ''Mat. view of ',s.class_name,' ',t.lodx_name,' ',u.themsurf_name,' in schema ',citydb_schema,''';
CREATE INDEX ',mview_idx_name,' ON qgis_pkg.',mview_name,' (co_id);
CREATE INDEX ',mview_spx_name,' ON qgis_pkg.',mview_name,' USING gist (geom);
DELETE FROM qgis_pkg.layer_metadata WHERE v_name = ''',view_name,''';
INSERT INTO qgis_pkg.layer_metadata (schema_name, feature_type, qml_file, lod, root_class, layer_name, creation_date, mv_name, v_name) VALUES
(''',citydb_schema,''',''',feature_type,''',''',qml_file_name,''',''',t.lodx_label,''',''',s.class_name,''',''',l_name,''',clock_timestamp(),''',mview_name,''',''',view_name,''');
');
EXECUTE sql_statement;

			END LOOP; -- outer bridge out install thematic surfaces loop
		END LOOP; -- outer bridge out install lod loop
	END LOOP; -- outer bridge installation loop


---------------------------------------------------------------
-- Create MATERIALIZED VIEW QGIS_PKG._G_**_BRIDGE_CONSTRUCTION_ELEMENT
---------------------------------------------------------------
	FOR s IN 
		SELECT * FROM (VALUES
		('BridgeConstructionElement'::varchar, 82::integer, 'constr_elem'::varchar)
		) AS t(class_name, class_id, class_label)
	LOOP

---------------------------------------------------------------
-- Create MATERIALIZED VIEW QGIS_PKG._G_**_BRIDGE_CONSTRUCTION_ELEMENT_LOD1
---------------------------------------------------------------
l_name         := format(      '%I_%I_lod1',						   r.class_label, s.class_label);
view_name      := format(   '%I_%I_%I_lod1',			citydb_schema, r.class_label, s.class_label);
mview_name     := format('_g_%I_%I_%I_lod1',			citydb_schema, r.class_label, s.class_label);
mview_idx_name := format('_g_%I_%I_%I_lod1_id_idx',		citydb_schema, r.class_label, s.class_label);
mview_spx_name := format('_g_%I_%I_%I_lod1_geom_spx',	citydb_schema, r.class_label, s.class_label);
qml_file_name  := concat(r.class_label,'_',s.class_label,'_form.qml');

IF mview_bbox IS NOT NULL THEN
	sql_where := concat('AND ST_MakeEnvelope(',mview_bbox_xmin,', ',mview_bbox_ymin,', ',mview_bbox_xmax,', ',mview_bbox_ymax,', ',srid_id,') && co.envelope');
ELSE
	sql_where := NULL;
END IF;

sql_statement := concat('
DROP MATERIALIZED VIEW IF EXISTS qgis_pkg.',mview_name,' CASCADE;
CREATE MATERIALIZED VIEW         qgis_pkg.',mview_name,' AS
	SELECT
		sg.cityobject_id::bigint AS co_id,
		ST_Collect(qgis_pkg.ST_snap_poly_to_grid(sg.geometry,',perform_snapping,',',digits,',',area_poly_min,'))::geometry(MultiPolygonZ, ',srid_id,') AS geom	
	FROM
		',citydb_schema,'.bridge_constr_element AS o
		INNER JOIN ',citydb_schema,'.cityobject AS co ON (o.id = co.id AND o.objectclass_id = ',r.class_id,' ',sql_where,')
		INNER JOIN ',citydb_schema,'.surface_geometry AS sg ON (sg.root_id = o.',t.lodx_label,'_brep_id AND sg.geometry IS NOT NULL)
	WHERE
		o.',t.lodx_label,'_implicit_rep_id IS NULL AND o.',t.lodx_label,'_brep_id IS NOT NULL 
	GROUP BY sg.cityobject_id

	UNION

	SELECT
		o.id::bigint AS co_id,
		ST_SetSRID(
			ST_Affine(ST_Collect(sg.implicit_geometry),
				   split_part(o.',t.lodx_label,'_implicit_transformation, '' '', 1)::double precision,
				   0,0,0,
				   split_part(o.',t.lodx_label,'_implicit_transformation, '' '', 6)::double precision,
				   0,0,0,
				   split_part(o.',t.lodx_label,'_implicit_transformation, '' '', 11)::double precision,
				   ST_X(o.',t.lodx_label,'_implicit_ref_point),
				   ST_Y(o.',t.lodx_label,'_implicit_ref_point),
				   ST_Z(o.',t.lodx_label,'_implicit_ref_point)
				   ),
			',srid_id,')::geometry(MultiPolygonZ, ',srid_id,') AS geom
	FROM 
		',citydb_schema,'.bridge_constr_element AS o
		INNER JOIN ',citydb_schema,'.cityobject AS co ON (o.id=co.id AND o.objectclass_id = ',r.class_id,' ',sql_where,')	
		INNER JOIN ',citydb_schema,'.implicit_geometry AS ig ON (ig.id = o.',t.lodx_label,'_implicit_rep_id)
		INNER JOIN ',citydb_schema,'.surface_geometry AS sg ON (sg.root_id = ig.relative_brep_id AND sg.implicit_geometry IS NOT NULL)
	WHERE
		o.',t.lodx_label,'_implicit_rep_id IS NOT NULL
	GROUP BY o.id
WITH NO DATA;
COMMENT ON MATERIALIZED VIEW qgis_pkg.',mview_name,' IS ''Mat. view of ',r.class_name,' ',t.lodx_name,' in schema ',citydb_schema,''';
CREATE INDEX ',mview_idx_name,' ON qgis_pkg.',mview_name,' (co_id);
CREATE INDEX ',mview_spx_name,' ON qgis_pkg.',mview_name,' USING gist (geom);
DELETE FROM qgis_pkg.layer_metadata WHERE v_name = ''',view_name,''';
INSERT INTO qgis_pkg.layer_metadata (schema_name, feature_type, qml_file, lod, root_class, layer_name, creation_date, mv_name, v_name) VALUES
(''',citydb_schema,''',''',feature_type,''',''',qml_file_name,''',''',t.lodx_label,''',''',r.class_name,''',''',l_name,''',clock_timestamp(),''',mview_name,''',''',view_name,''');
');
EXECUTE sql_statement;

---------------------------------------------------------------
-- Create MATERIALIZED VIEW QGIS_PKG._G_*_BRIDGE_CONSTRUCTION_ELEMENT_LOD2-4
---------------------------------------------------------------	
		FOR t IN 
			SELECT * FROM (VALUES
			('LoD2'::varchar, 'lod2'::varchar),
			('LoD3'			, 'lod3'),
			('LoD4'			, 'lod4')		
			) AS t(lodx_name, lodx_label)
		LOOP

l_name         := format(      '%I_%I_%I',							r.class_label, s.class_label, t.lodx_label);
view_name      := format(   '%I_%I_%I_%I',			citydb_schema, r.class_label, s.class_label, t.lodx_label);
mview_name     := format('_g_%I_%I_%I_%I',			citydb_schema, r.class_label, s.class_label, t.lodx_label);
mview_idx_name := format('_g_%I_%I_%I_%I_id_idx',	citydb_schema, r.class_label, s.class_label, t.lodx_label);
mview_spx_name := format('_g_%I_%I_%I_%I_geom_spx',	citydb_schema, r.class_label, s.class_label, t.lodx_label);
qml_file_name  := concat(r.class_label,'_',s.class_label,'_form.qml');

IF mview_bbox IS NOT NULL THEN
	sql_where := concat('AND ST_MakeEnvelope(',mview_bbox_xmin,', ',mview_bbox_ymin,', ',mview_bbox_xmax,', ',mview_bbox_ymax,', ',srid_id,') && co.envelope');
ELSE
	sql_where := NULL;
END IF;

sql_statement := concat('
DROP MATERIALIZED VIEW IF EXISTS qgis_pkg.',mview_name,' CASCADE;
CREATE MATERIALIZED VIEW         qgis_pkg.',mview_name,' AS
	SELECT 
		foo2.co_id AS co_id,
		st_collect(qgis_pkg.ST_snap_poly_to_grid(sg.geometry,',perform_snapping,',',digits,',',area_poly_min,'))::geometry(MultiPolygonZ, ',srid_id,') AS geom
	FROM ( 
			SELECT 
				foo.co_id,
				unnest(foo.sg_id_array) AS sg_id
			FROM ( 
					SELECT
						o.id AS co_id,
						CASE
							WHEN ts_t.sg_id_array IS NOT NULL THEN ts_t.sg_id_array
							ELSE ARRAY[o.',t.lodx_label,'_brep_id]
						END AS sg_id_array
					FROM 
						',citydb_schema,'.bridge_constr_element AS o
						INNER JOIN ',citydb_schema,'.cityobject AS co ON (o.id = co.id AND o.objectclass_id = ',s.class_id,' ',sql_where,')
						INNER JOIN (
							SELECT
								o.bridge_constr_element_id AS co_id,
								array_agg(o.',t.lodx_label,'_multi_surface_id) AS sg_id_array
							FROM 
								',citydb_schema,'.bridge_thematic_surface AS o
								INNER JOIN ',citydb_schema,'.cityobject AS co ON (co.id = o.id ',sql_where,')
								INNER JOIN ',citydb_schema,'.bridge AS b ON (o.bridge_id = b.id AND b.objectclass_id = ',r.class_id,')
							WHERE 
								o.bridge_constr_element_id IS NOT NULL
							GROUP BY o.bridge_constr_element_id
						) AS ts_t ON (ts_t.co_id = o.id)
					WHERE
						o.',t.lodx_label,'_implicit_rep_id IS NULL
				) AS foo
	   ) AS foo2
	INNER JOIN ',citydb_schema,'.surface_geometry AS sg ON (sg.root_id = foo2.sg_id AND sg.geometry IS NOT NULL)
	GROUP BY foo2.co_id
	UNION');
-- the need to split is due to max 100 arguments allowed in the concat function.
sql_statement := concat(sql_statement,'	
	SELECT
		o.id::bigint AS co_id,
		ST_SetSRID(
			ST_Affine(ST_Collect(sg.implicit_geometry),
				   split_part(o.',t.lodx_label,'_implicit_transformation, '' '', 1)::double precision,
				   0,0,0,
				   split_part(o.',t.lodx_label,'_implicit_transformation, '' '', 6)::double precision,
				   0,0,0,
				   split_part(o.',t.lodx_label,'_implicit_transformation, '' '', 11)::double precision,
				   ST_X(o.',t.lodx_label,'_implicit_ref_point),
				   ST_Y(o.',t.lodx_label,'_implicit_ref_point),
				   ST_Z(o.',t.lodx_label,'_implicit_ref_point)
				   ),
			',srid_id,')::geometry(MultiPolygonZ, ',srid_id,') AS geom
	FROM 
		',citydb_schema,'.bridge_constr_element AS o
		INNER JOIN ',citydb_schema,'.cityobject AS co ON (o.id = co.id AND o.objectclass_id = ',s.class_id,' ',sql_where,')
		INNER JOIN ',citydb_schema,'.bridge AS b ON (b.id = o.bridge_id AND b.objectclass_id = ',r.class_id,')
		INNER JOIN ',citydb_schema,'.implicit_geometry AS ig ON (ig.id = o.',t.lodx_label,'_implicit_rep_id)
		INNER JOIN ',citydb_schema,'.surface_geometry AS sg ON (sg.root_id = ig.relative_brep_id AND sg.implicit_geometry IS NOT NULL)
	WHERE
		o.',t.lodx_label,'_implicit_rep_id IS NOT NULL
	GROUP BY o.id
WITH NO DATA;
COMMENT ON MATERIALIZED VIEW qgis_pkg.',mview_name,' IS ''Mat. view of ',s.class_name,' ',t.lodx_name,' in schema ',citydb_schema,''';
CREATE INDEX ',mview_idx_name,' ON qgis_pkg.',mview_name,' (co_id);
CREATE INDEX ',mview_spx_name,' ON qgis_pkg.',mview_name,' USING gist (geom);
DELETE FROM qgis_pkg.layer_metadata WHERE v_name = ''',view_name,''';
INSERT INTO qgis_pkg.layer_metadata (schema_name, feature_type, qml_file, lod, root_class, layer_name, creation_date, mv_name, v_name) VALUES
(''',citydb_schema,''',''',feature_type,''',''',qml_file_name,''',''',t.lodx_label,''',''',s.class_name,''',''',l_name,''',clock_timestamp(),''',mview_name,''',''',view_name,''');
');
EXECUTE sql_statement;

---------------------------------------------------------------
-- Create MATERIALIZED VIEW QGIS_PKG._G_*_BRIDGE_CONSTRUCTION_ELEMENT_LOD2-4_THEMATIC_SURFACES
---------------------------------------------------------------
			FOR u IN 
				SELECT * FROM (VALUES
				('BridgeRoofSurface'::varchar , 71::integer, 'roofsurf'::varchar),
				('BridgeWallSurface'		  , 72		   , 'wallsurf'),
				('BridgeGroundSurface'		  , 73		   , 'groundsurf'),
				('BridgeClosureSurface'		  , 74		   , 'closuresurf'),
				('OuterBridgeCeilingSurface'  , 75		   , 'outerceilingsurf'),
				('OuterBridgeFloorSurface'	  , 66		   , 'outerfloorsurf')
				) AS t(themsurf_name, class_id, themsurf_label)
			LOOP

l_name         := format(      '%I_%I_%I_%I',						   r.class_label, s.class_label, t.lodx_label, u.themsurf_label);
view_name      := format(   '%I_%I_%I_%I_%I',			citydb_schema, r.class_label, s.class_label, t.lodx_label, u.themsurf_label);
mview_name     := format('_g_%I_%I_%I_%I_%I',			citydb_schema, r.class_label, s.class_label, t.lodx_label, u.themsurf_label);
mview_idx_name := format('_g_%I_%I_%I_%I_%I_id_idx',	citydb_schema, r.class_label, s.class_label, t.lodx_label, u.themsurf_label);
mview_spx_name := format('_g_%I_%I_%I_%I_%I_geom_spx',	citydb_schema, r.class_label, s.class_label, t.lodx_label, u.themsurf_label);
qml_file_name  := concat(r.class_label,'_',s.class_label,'_them_surf_form.qml');

IF mview_bbox IS NOT NULL THEN
	sql_where := concat('AND ST_MakeEnvelope(',mview_bbox_xmin,', ',mview_bbox_ymin,', ',mview_bbox_xmax,', ',mview_bbox_ymax,', ',srid_id,') && co.envelope');
ELSE
	sql_where := NULL;
END IF;

sql_statement := concat('
DROP MATERIALIZED VIEW IF EXISTS qgis_pkg.',mview_name,' CASCADE;
CREATE MATERIALIZED VIEW         qgis_pkg.',mview_name,' AS
	SELECT
		sg.cityobject_id::bigint AS co_id,
		ST_Collect(qgis_pkg.ST_snap_poly_to_grid(sg.geometry,',perform_snapping,',',digits,',',area_poly_min,'))::geometry(MultiPolygonZ,',srid_id,') AS geom
	FROM
		',citydb_schema,'.bridge_thematic_surface AS o
		INNER JOIN ',citydb_schema,'.cityobject AS co ON (o.id = co.id AND o.objectclass_id = ',u.class_id,' ',sql_where,') 
		INNER JOIN ',citydb_schema,'.bridge_constr_element AS bi ON (o.bridge_constr_element_id = bi.id AND bi.objectclass_id = ',s.class_id,')
		INNER JOIN ',citydb_schema,'.bridge AS b ON (o.bridge_id = b.id AND b.objectclass_id = ',r.class_id,')		
		INNER JOIN ',citydb_schema,'.surface_geometry AS sg ON (sg.root_id = o.',t.lodx_name,'_multi_surface_id  AND sg.geometry IS NOT NULL)
	GROUP BY sg.cityobject_id
WITH NO DATA;
COMMENT ON MATERIALIZED VIEW qgis_pkg.',mview_name,' IS ''Mat. view of ',s.class_name,' ',t.lodx_name,' ',u.themsurf_name,' in schema ',citydb_schema,''';
CREATE INDEX ',mview_idx_name,' ON qgis_pkg.',mview_name,' (co_id);
CREATE INDEX ',mview_spx_name,' ON qgis_pkg.',mview_name,' USING gist (geom);
DELETE FROM qgis_pkg.layer_metadata WHERE v_name = ''',view_name,''';
INSERT INTO qgis_pkg.layer_metadata (schema_name, feature_type, qml_file, lod, root_class, layer_name, creation_date, mv_name, v_name) VALUES
(''',citydb_schema,''',''',feature_type,''',''',qml_file_name,''',''',t.lodx_label,''',''',s.class_name,''',''',l_name,''',clock_timestamp(),''',mview_name,''',''',view_name,''');
');
EXECUTE sql_statement;

			END LOOP; -- bridge construction element thematic surfaces loop
		END LOOP; -- bridge construction element lod2-4 loop
	END LOOP; -- bridge construction element loop

---------------------------------------------------------------
-- Create MATERIALIZED VIEW QGIS_PKG._G_**_INT_BRIDGE_INSTALLATION_LOD4
---------------------------------------------------------------
	FOR s IN 
		SELECT * FROM (VALUES
		('IntBridgeInstallation'::varchar, 66::integer, 'int_inst'::varchar)
		) AS t(class_name, class_id, class_label)
	LOOP

		FOR t IN 
			SELECT * FROM (VALUES
			('LoD4'::varchar, 'lod4'::varchar)
			) AS t(lodx_name, lodx_label)
		LOOP
l_name         := format(      '%I_%I_%I',							r.class_label, s.class_label, t.lodx_label);
view_name      := format(   '%I_%I_%I_%I',			citydb_schema, r.class_label, s.class_label, t.lodx_label);
mview_name     := format('_g_%I_%I_%I_%I',			citydb_schema, r.class_label, s.class_label, t.lodx_label);
mview_idx_name := format('_g_%I_%I_%I_%I_id_idx',	citydb_schema, r.class_label, s.class_label, t.lodx_label);
mview_spx_name := format('_g_%I_%I_%I_%I_geom_spx',	citydb_schema, r.class_label, s.class_label, t.lodx_label);
qml_file_name  := concat(r.class_label,'_',s.class_label,'_form.qml');

IF mview_bbox IS NOT NULL THEN
	sql_where := concat('AND ST_MakeEnvelope(',mview_bbox_xmin,', ',mview_bbox_ymin,', ',mview_bbox_xmax,', ',mview_bbox_ymax,', ',srid_id,') && co.envelope');
ELSE
	sql_where := NULL;
END IF;

sql_statement := concat('
DROP MATERIALIZED VIEW IF EXISTS qgis_pkg.',mview_name,' CASCADE;
CREATE MATERIALIZED VIEW         qgis_pkg.',mview_name,' AS
	SELECT 
		foo2.co_id AS co_id,
		st_collect(qgis_pkg.ST_snap_poly_to_grid(sg.geometry,',perform_snapping,',',digits,',',area_poly_min,'))::geometry(MultiPolygonZ, ',srid_id,') AS geom
	FROM ( 
			SELECT 
				foo.co_id,
				unnest(foo.sg_id_array) AS sg_id
			FROM ( 
					SELECT
						o.id AS co_id,
						CASE
							WHEN ts_t.sg_id_array IS NOT NULL THEN ts_t.sg_id_array
							ELSE ARRAY[o.',t.lodx_label,'_brep_id]
						END AS sg_id_array
					FROM 
						',citydb_schema,'.bridge_installation AS o
						INNER JOIN ',citydb_schema,'.cityobject AS co ON (o.id = co.id AND o.objectclass_id = ',s.class_id,' ',sql_where,')
						INNER JOIN (
							SELECT
								o.bridge_installation_id AS co_id,
								array_agg(o.',t.lodx_label,'_multi_surface_id) AS sg_id_array
							FROM 
								',citydb_schema,'.bridge_thematic_surface AS o
								INNER JOIN ',citydb_schema,'.cityobject AS co ON (co.id = o.id ',sql_where,')
								INNER JOIN ',citydb_schema,'.bridge AS b ON (o.bridge_id = b.id AND b.objectclass_id = ',r.class_id,')
							WHERE 
								o.bridge_installation_id IS NOT NULL
							GROUP BY o.bridge_installation_id
						) AS ts_t ON (ts_t.co_id = o.id)
					WHERE
						o.',t.lodx_label,'_implicit_rep_id IS NULL
				) AS foo
	   ) AS foo2
	INNER JOIN ',citydb_schema,'.surface_geometry AS sg ON (sg.root_id = foo2.sg_id AND sg.geometry IS NOT NULL)
	GROUP BY foo2.co_id
	UNION');
-- the need to split is due to max 100 arguments allowed in the concat function.
sql_statement := concat(sql_statement,'	
	SELECT
		o.id::bigint AS co_id,
		ST_SetSRID(
			ST_Affine(ST_Collect(sg.implicit_geometry),
				   split_part(o.',t.lodx_label,'_implicit_transformation, '' '', 1)::double precision,
				   0,0,0,
				   split_part(o.',t.lodx_label,'_implicit_transformation, '' '', 6)::double precision,
				   0,0,0,
				   split_part(o.',t.lodx_label,'_implicit_transformation, '' '', 11)::double precision,
				   ST_X(o.',t.lodx_label,'_implicit_ref_point),
				   ST_Y(o.',t.lodx_label,'_implicit_ref_point),
				   ST_Z(o.',t.lodx_label,'_implicit_ref_point)
				   ),
			',srid_id,')::geometry(MultiPolygonZ, ',srid_id,') AS geom
	FROM 
		',citydb_schema,'.bridge_installation AS o
		INNER JOIN ',citydb_schema,'.cityobject AS co ON (o.id = co.id AND o.objectclass_id = ',s.class_id,' ',sql_where,')
		INNER JOIN ',citydb_schema,'.bridge AS b ON (b.id = o.bridge_id AND b.objectclass_id = ',r.class_id,')
		INNER JOIN ',citydb_schema,'.implicit_geometry AS ig ON (ig.id = o.',t.lodx_label,'_implicit_rep_id)
		INNER JOIN ',citydb_schema,'.surface_geometry AS sg ON (sg.root_id = ig.relative_brep_id AND sg.implicit_geometry IS NOT NULL)
	WHERE
		o.',t.lodx_label,'_implicit_rep_id IS NOT NULL
	GROUP BY o.id
WITH NO DATA;
COMMENT ON MATERIALIZED VIEW qgis_pkg.',mview_name,' IS ''Mat. view of ',s.class_name,' ',t.lodx_name,' in schema ',citydb_schema,''';
CREATE INDEX ',mview_idx_name,' ON qgis_pkg.',mview_name,' (co_id);
CREATE INDEX ',mview_spx_name,' ON qgis_pkg.',mview_name,' USING gist (geom);
DELETE FROM qgis_pkg.layer_metadata WHERE v_name = ''',view_name,''';
INSERT INTO qgis_pkg.layer_metadata (schema_name, feature_type, qml_file, lod, root_class, layer_name, creation_date, mv_name, v_name) VALUES
(''',citydb_schema,''',''',feature_type,''',''',qml_file_name,''',''',t.lodx_label,''',''',s.class_name,''',''',l_name,''',clock_timestamp(),''',mview_name,''',''',view_name,''');
');
EXECUTE sql_statement;

---------------------------------------------------------------
-- Create MATERIALIZED VIEW QGIS_PKG._G_**_INT_BRIDGE_INT_INSTALLATION_LOD4_THEMATIC_SURF
---------------------------------------------------------------
			FOR u IN 
				SELECT * FROM (VALUES
				('BridgeRoofSurface'::varchar , 71::integer, 'roofsurf'::varchar),
				('BridgeWallSurface'		  , 72		   , 'wallsurf'),
				('BridgeGroundSurface'		  , 73		   , 'groundsurf'),
				('BridgeClosureSurface'		  , 74		   , 'closuresurf'),
				('OuterBridgeCeilingSurface'  , 75		   , 'outerceilingsurf'),
				('OuterBridgeFloorSurface'	  , 66		   , 'outerfloorsurf')
				) AS t(themsurf_name, class_id, themsurf_label)
			LOOP

l_name         := format(      '%I_%I_%I_%I',						   r.class_label, s.class_label, t.lodx_label, u.themsurf_label);
view_name      := format(   '%I_%I_%I_%I_%I',			citydb_schema, r.class_label, s.class_label, t.lodx_label, u.themsurf_label);
mview_name     := format('_g_%I_%I_%I_%I_%I',			citydb_schema, r.class_label, s.class_label, t.lodx_label, u.themsurf_label);
mview_idx_name := format('_g_%I_%I_%I_%I_%I_id_idx',	citydb_schema, r.class_label, s.class_label, t.lodx_label, u.themsurf_label);
mview_spx_name := format('_g_%I_%I_%I_%I_%I_geom_spx',	citydb_schema, r.class_label, s.class_label, t.lodx_label, u.themsurf_label);
qml_file_name  := concat(r.class_label,'_',s.class_label,'_them_surf_form.qml');

IF mview_bbox IS NOT NULL THEN
	sql_where := concat('AND ST_MakeEnvelope(',mview_bbox_xmin,', ',mview_bbox_ymin,', ',mview_bbox_xmax,', ',mview_bbox_ymax,', ',srid_id,') && co.envelope');
ELSE
	sql_where := NULL;
END IF;

sql_statement := concat('
DROP MATERIALIZED VIEW IF EXISTS qgis_pkg.',mview_name,' CASCADE;
CREATE MATERIALIZED VIEW         qgis_pkg.',mview_name,' AS
	SELECT
		sg.cityobject_id::bigint AS co_id,
		ST_Collect(qgis_pkg.ST_snap_poly_to_grid(sg.geometry,',perform_snapping,',',digits,',',area_poly_min,'))::geometry(MultiPolygonZ,',srid_id,') AS geom
	FROM
		',citydb_schema,'.bridge_thematic_surface AS o
		INNER JOIN ',citydb_schema,'.cityobject AS co ON (o.id = co.id AND o.objectclass_id = ',u.class_id,' ',sql_where,') 
		INNER JOIN ',citydb_schema,'.bridge_installation AS bi ON (o.bridge_installation_id = bi.id AND bi.objectclass_id = ',s.class_id,')
		INNER JOIN ',citydb_schema,'.bridge AS b ON (o.bridge_id = b.id AND b.objectclass_id = ',r.class_id,')		
		INNER JOIN ',citydb_schema,'.surface_geometry AS sg ON (sg.root_id = o.',t.lodx_name,'_multi_surface_id  AND sg.geometry IS NOT NULL)
	GROUP BY sg.cityobject_id
WITH NO DATA;
COMMENT ON MATERIALIZED VIEW qgis_pkg.',mview_name,' IS ''Mat. view of ',s.class_name,' ',t.lodx_name,' ',u.themsurf_name,' in schema ',citydb_schema,''';
CREATE INDEX ',mview_idx_name,' ON qgis_pkg.',mview_name,' (co_id);
CREATE INDEX ',mview_spx_name,' ON qgis_pkg.',mview_name,' USING gist (geom);
DELETE FROM qgis_pkg.layer_metadata WHERE v_name = ''',view_name,''';
INSERT INTO qgis_pkg.layer_metadata (schema_name, feature_type, qml_file, lod, root_class, layer_name, creation_date, mv_name, v_name) VALUES
(''',citydb_schema,''',''',feature_type,''',''',qml_file_name,''',''',t.lodx_label,''',''',s.class_name,''',''',l_name,''',clock_timestamp(),''',mview_name,''',''',view_name,''');
');
EXECUTE sql_statement;

			END LOOP; -- interior bridge installation thematic surfaces lod loop
		END LOOP; -- interior bridge installation lod loop
	END LOOP; -- interior bridge installation loop

---------------------------------------------------------------
-- Create MATERIALIZED VIEW QGIS_PKG._G_**_BRIDGE_ROOM_LOD4
---------------------------------------------------------------
	FOR s IN 
		SELECT * FROM (VALUES
		('BridgeRoom'::varchar, 81::integer, 'room'::varchar)
		) AS t(class_name, class_id, class_label)
	LOOP
l_name         := format(      '%I_%I_lod4',							r.class_label, s.class_label);
view_name      := format(   '%I_%I_%I_lod4',			citydb_schema, r.class_label, s.class_label);
mview_name     := format('_g_%I_%I_%I_lod4', 			citydb_schema, r.class_label, s.class_label);
mview_idx_name := format('_g_%I_%I_%I_lod4_id_idx', 	citydb_schema, r.class_label, s.class_label);
mview_spx_name := format('_g_%I_%I_%I_lod4_geom_spx',	citydb_schema, r.class_label, s.class_label);
qml_file_name  := concat(r.class_label,'_',s.class_label,'_form.qml');

IF mview_bbox IS NOT NULL THEN
	sql_where := concat('AND ST_MakeEnvelope(',mview_bbox_xmin,', ',mview_bbox_ymin,', ',mview_bbox_xmax,', ',mview_bbox_ymax,', ',srid_id,') && co.envelope');
ELSE
	sql_where := NULL;
END IF;

sql_statement := concat('
DROP MATERIALIZED VIEW IF EXISTS qgis_pkg.',mview_name,' CASCADE;
CREATE MATERIALIZED VIEW         qgis_pkg.',mview_name,' AS

	SELECT
		foo2.co_id::bigint AS co_id,
		ST_Collect(qgis_pkg.ST_snap_poly_to_grid(sg.geometry,',perform_snapping,',',digits,',',area_poly_min,'))::geometry(MultiPolygonZ, ',srid_id,') AS geom	
	FROM (
		SELECT
			foo.co_id,
			unnest(foo.sg_id_array) AS sg_id
		FROM (
			SELECT
				-- coalesce(o.id, ts_t.co_id) as co_id,
				o.id AS co_id,
				CASE 
					WHEN ts_t.sg_id_array IS NOT NULL THEN ts_t.sg_id_array
					WHEN o.',t.lodx_label,'_solid_id IS NOT NULL THEN ARRAY[o.',t.lodx_label,'_solid_id]
					ELSE ARRAY[o.',t.lodx_label,'_multi_surface_id]
				END AS sg_id_array 
			FROM 
				',citydb_schema,'.bridge_room AS o
				INNER JOIN ',citydb_schema,'.cityobject AS co ON (o.id = co.id AND o.objectclass_id = ',s.class_id,' ',sql_where,')
				INNER JOIN ',citydb_schema,'.bridge AS b ON (b.id = o.bridge_id AND b.objectclass_id = ',r.class_id,')
				-- FULL OUTER JOIN
				INNER JOIN (
					SELECT ts.bridge_id AS co_id, array_agg(ts.',t.lodx_label,'_multi_surface_id) AS sg_id_array 
					FROM 
						',citydb_schema,'.bridge_thematic_surface AS ts
						INNER JOIN ',citydb_schema,'.cityobject AS co ON (co.id = ts.id ',sql_where,')
						INNER JOIN ',citydb_schema,'.bridge_room AS r ON (ts.bridge_id = r.id AND r.objectclass_id = ',s.class_id,' ',sql_where,')
						INNER JOIN ',citydb_schema,'.bridge AS b1 ON (b1.id = r.bridge_id AND b1.objectclass_id = ',r.class_id,')						
					GROUP BY ts.bridge_id
					) AS ts_t ON (ts_t.co_id = o.id)
			WHERE 
				sg_id_array IS NOT NULL
			) AS foo
		) AS foo2
		INNER JOIN ',citydb_schema,'.surface_geometry AS sg ON (sg.root_id = foo2.sg_id AND sg.geometry IS NOT NULL)
	GROUP BY foo2.co_id
WITH NO DATA;
COMMENT ON MATERIALIZED VIEW qgis_pkg.',mview_name,' IS ''Mat. view of (',r.class_name,') ',s.class_name,' ',t.lodx_name,' in schema ',citydb_schema,''';
CREATE INDEX ',mview_idx_name,' ON qgis_pkg.',mview_name,' (co_id);
CREATE INDEX ',mview_spx_name,' ON qgis_pkg.',mview_name,' USING gist (geom);
DELETE FROM qgis_pkg.layer_metadata WHERE v_name = ''',view_name,''';
INSERT INTO qgis_pkg.layer_metadata (schema_name, feature_type, qml_file, lod, root_class, layer_name, creation_date, mv_name, v_name) VALUES
(''',citydb_schema,''',''',feature_type,''',''',qml_file_name,''',''',t.lodx_label,''',''',s.class_name,''',''',l_name,''',clock_timestamp(),''',mview_name,''',''',view_name,''');
');
EXECUTE sql_statement;

---------------------------------------------------------------
-- Create MATERIALIZED VIEW QGIS_PKG._G_**_ROOM_LOD4_THEMATIC_SURFACES
---------------------------------------------------------------
			FOR u IN 
				SELECT * FROM (VALUES
				('BridgeCeilingSurface'::varchar	, 68::integer	, 'ceilingsurf'::varchar),
				('InteriorBridgeWallSurface'		, 69		 	, 'intwallsurf'),
				('BridgeFloorSurface'				, 70		    , 'floorsurf')
				) AS t(themsurf_name, class_id, themsurf_label)
			LOOP

l_name         := format(      '%I_%I_lod4_%I',								r.class_label, s.class_label, u.themsurf_label);
view_name      := format(   '%I_%I_%I_lod4_%I',				citydb_schema, r.class_label, s.class_label, u.themsurf_label);
mview_name     := format('_g_%I_%I_%I_lod4_%I',				citydb_schema, r.class_label, s.class_label, u.themsurf_label);
mview_idx_name := format('_g_%I_%I_%I_lod4_%I_id_idx',		citydb_schema, r.class_label, s.class_label, u.themsurf_label);
mview_spx_name := format('_g_%I_%I_%I_lod4_%I_geom_spx',	citydb_schema, r.class_label, s.class_label, u.themsurf_label);
qml_file_name  := concat(r.class_label,'_',s.class_label,'_them_surf_form.qml');

IF mview_bbox IS NOT NULL THEN
	sql_where := concat('AND ST_MakeEnvelope(',mview_bbox_xmin,', ',mview_bbox_ymin,', ',mview_bbox_xmax,', ',mview_bbox_ymax,', ',srid_id,') && co.envelope');
ELSE
	sql_where := NULL;
END IF;

sql_statement := concat('
DROP MATERIALIZED VIEW IF EXISTS qgis_pkg.',mview_name,' CASCADE;
CREATE MATERIALIZED VIEW         qgis_pkg.',mview_name,' AS
	SELECT
		sg.cityobject_id::bigint AS co_id,
		ST_Collect(qgis_pkg.ST_snap_poly_to_grid(sg.geometry,',perform_snapping,',',digits,',',area_poly_min,'))::geometry(MultiPolygonZ,',srid_id,') AS geom
	FROM
		',citydb_schema,'.bridge_thematic_surface AS o
		INNER JOIN ',citydb_schema,'.cityobject AS co ON (o.id = co.id AND o.objectclass_id = ',u.class_id,' ',sql_where,') 
		INNER JOIN ',citydb_schema,'.bridge_room AS r ON (o.bridge_room_id = r.id AND r.objectclass_id = ',s.class_id,')
		INNER JOIN ',citydb_schema,'.bridge AS b ON (r.bridge_id = b.id AND b.objectclass_id = ',r.class_id,')		
		INNER JOIN ',citydb_schema,'.surface_geometry AS sg ON (sg.root_id = o.',t.lodx_name,'_multi_surface_id  AND sg.geometry IS NOT NULL)
	GROUP BY sg.cityobject_id
WITH NO DATA;
COMMENT ON MATERIALIZED VIEW qgis_pkg.',mview_name,' IS ''Mat. view of (',r.class_name,') ',s.class_name,' ',t.lodx_name,' ',u.themsurf_name,' in schema ',citydb_schema,''';
CREATE INDEX ',mview_idx_name,' ON qgis_pkg.',mview_name,' (co_id);
CREATE INDEX ',mview_spx_name,' ON qgis_pkg.',mview_name,' USING gist (geom);
DELETE FROM qgis_pkg.layer_metadata WHERE v_name = ''',view_name,''';
INSERT INTO qgis_pkg.layer_metadata (schema_name, feature_type, qml_file, lod, root_class, layer_name, creation_date, mv_name, v_name) VALUES
(''',citydb_schema,''',''',feature_type,''',''',qml_file_name,''',''',t.lodx_label,''',''',s.class_name,''',''',l_name,''',clock_timestamp(),''',mview_name,''',''',view_name,''');
');
EXECUTE sql_statement;

		END LOOP; -- bridge room thematic surfaces loop
	END LOOP; -- bridge room loop

---------------------------------------------------------------
-- Create MATERIALIZED VIEW QGIS_PKG._G_**_BRIDGE_WINDOW/DOOR_LOD3-4
---------------------------------------------------------------
	FOR s IN 
		SELECT * FROM (VALUES
		('BridgeWindow'::varchar, 78::integer, 'window'::varchar),
		('BridgeDoor'           , 79         , 'door')		
		) AS t(class_name, class_id, class_label)
	LOOP
		FOR t IN 
			SELECT * FROM (VALUES
			('LoD3'::varchar, 'lod3'::varchar),
			('LoD4'			, 'lod4')		
			) AS t(lodx_name, lodx_label)
		LOOP

-- The concat is here necessary because "window" is a reserved word and using format would add a " to the name.
l_name         := concat(						 r.class_label,'_',s.class_label,'_',t.lodx_label);
view_name      := concat(	   citydb_schema,'_',r.class_label,'_',s.class_label,'_',t.lodx_label);
mview_name     := concat('_g_',citydb_schema,'_',r.class_label,'_',s.class_label,'_',t.lodx_label);
mview_idx_name := concat('_g_',citydb_schema,'_',r.class_label,'_',s.class_label,'_',t.lodx_label,'_id_idx');
mview_spx_name := concat('_g_',citydb_schema,'_',r.class_label,'_',s.class_label,'_',t.lodx_label,'_geom_spx');
qml_file_name  := concat(r.class_label,'_opening_form.qml');

IF mview_bbox IS NOT NULL THEN
	sql_where := concat('AND ST_MakeEnvelope(',mview_bbox_xmin,', ',mview_bbox_ymin,', ',mview_bbox_xmax,', ',mview_bbox_ymax,', ',srid_id,') && co.envelope');
ELSE
	sql_where := NULL;
END IF;

sql_statement := concat('
DROP MATERIALIZED VIEW IF EXISTS qgis_pkg.',mview_name,' CASCADE;
CREATE MATERIALIZED VIEW         qgis_pkg.',mview_name,' AS
	SELECT
		sg.cityobject_id::bigint AS co_id,
		ST_Collect(qgis_pkg.ST_snap_poly_to_grid(sg.geometry,',perform_snapping,',',digits,',',area_poly_min,'))::geometry(MultiPolygonZ,',srid_id,') AS geom
	FROM
		',citydb_schema,'.bridge_opening AS o
		INNER JOIN ',citydb_schema,'.cityobject AS co ON (o.id = co.id AND o.objectclass_id = ',s.class_id,' ',sql_where,')
		INNER JOIN ',citydb_schema,'.bridge_open_to_them_srf AS ots ON (ots.bridge_opening_id = o.id)
		INNER JOIN ',citydb_schema,'.bridge_thematic_surface AS ts ON (ts.id = ots.bridge_thematic_surface_id)
		INNER JOIN ',citydb_schema,'.bridge AS b ON (b.id = ts.bridge_id AND b.objectclass_id = ',r.class_id,')
		INNER JOIN ',citydb_schema,'.surface_geometry sg ON sg.root_id = o.',t.lodx_name,'_multi_surface_id  AND sg.geometry IS NOT NULL
	WHERE
		o.',t.lodx_name,'_implicit_rep_id IS NULL
	GROUP BY sg.cityobject_id
	UNION');

sql_statement := concat(sql_statement,'
	SELECT
		o.id::bigint AS co_id,
		ST_SetSRID(
			ST_Affine(ST_Collect(sg.implicit_geometry),
				   split_part(o.',t.lodx_label,'_implicit_transformation, '' '', 1)::double precision,
				   0,0,0,
				   split_part(o.',t.lodx_label,'_implicit_transformation, '' '', 6)::double precision,
				   0,0,0,
				   split_part(o.',t.lodx_label,'_implicit_transformation, '' '', 11)::double precision,
				   ST_X(o.',t.lodx_label,'_implicit_ref_point),
				   ST_Y(o.',t.lodx_label,'_implicit_ref_point),
				   ST_Z(o.',t.lodx_label,'_implicit_ref_point)
				   ),
			',srid_id,')::geometry(MultiPolygonZ, ',srid_id,') AS geom
	FROM 
		',citydb_schema,'.bridge_opening AS o
		INNER JOIN ',citydb_schema,'.cityobject AS co ON (o.id = co.id AND o.objectclass_id = ',s.class_id,' ',sql_where,')		
		INNER JOIN ',citydb_schema,'.bridge_open_to_them_srf AS ots ON (ots.bridge_opening_id = o.id)
		INNER JOIN ',citydb_schema,'.bridge_thematic_surface AS ts ON (ts.id = ots.bridge_thematic_surface_id)
		INNER JOIN ',citydb_schema,'.bridge AS b ON (b.id = ts.bridge_id AND b.objectclass_id = ',r.class_id,')	
		INNER JOIN ',citydb_schema,'.implicit_geometry AS ig ON (ig.id = o.',t.lodx_name,'_implicit_rep_id) 
		INNER JOIN ',citydb_schema,'.surface_geometry AS sg ON (sg.root_id = ig.relative_brep_id AND sg.implicit_geometry IS NOT NULL)
	WHERE
		o.',t.lodx_name,'_implicit_rep_id IS NOT NULL
	GROUP BY o.id
WITH NO DATA;
COMMENT ON MATERIALIZED VIEW qgis_pkg.',mview_name,' IS ''Mat. view of (',r.class_name,') ',s.class_name,' ',t.lodx_name,' in schema ',citydb_schema,''';
CREATE INDEX ',mview_idx_name,' ON qgis_pkg.',mview_name,' (co_id);
CREATE INDEX ',mview_spx_name,' ON qgis_pkg.',mview_name,' USING gist (geom);
DELETE FROM qgis_pkg.layer_metadata WHERE v_name = ''',view_name,''';
INSERT INTO qgis_pkg.layer_metadata (schema_name, feature_type, qml_file, lod, root_class, layer_name, creation_date, mv_name, v_name) VALUES
(''',citydb_schema,''',''',feature_type,''',''',qml_file_name,''',''',t.lodx_label,''',''',s.class_name,''',''',l_name,''',clock_timestamp(),''',mview_name,''',''',view_name,''');
');
EXECUTE sql_statement;

		END LOOP; -- bridge window/door lod
	END LOOP; -- bridge window/door

---------------------------------------------------------------
-- Create MATERIALIZED VIEW QGIS_PKG._G_**_BRIDGE_FURNITURE_LOD4
---------------------------------------------------------------
	FOR s IN 
		SELECT * FROM (VALUES
		('BridgeFurniture'::varchar, 80::integer, 'furniture'::varchar)		
		) AS t(class_name, class_id, class_label)
	LOOP

l_name         := format(      '%I_%I_lod4',							r.class_label, s.class_label);
view_name      := format(   '%I_%I_%I_lod4',			citydb_schema, r.class_label, s.class_label);
mview_name     := format('_g_%I_%I_%I_lod4',			citydb_schema, r.class_label, s.class_label);
mview_idx_name := format('_g_%I_%I_%I_lod4_id_idx',		citydb_schema, r.class_label, s.class_label);
mview_spx_name := format('_g_%I_%I_%I_lod4_geom_spx',	citydb_schema, r.class_label, s.class_label);
qml_file_name  := concat(r.class_label,'_',s.class_label,'_form.qml');

IF mview_bbox IS NOT NULL THEN
	sql_where := concat('AND ST_MakeEnvelope(',mview_bbox_xmin,', ',mview_bbox_ymin,', ',mview_bbox_xmax,', ',mview_bbox_ymax,', ',srid_id,') && co.envelope');
ELSE
	sql_where := NULL;
END IF;

sql_statement := concat('
DROP MATERIALIZED VIEW IF EXISTS qgis_pkg.',mview_name,' CASCADE;
CREATE MATERIALIZED VIEW         qgis_pkg.',mview_name,' AS
	SELECT
		sg.cityobject_id::bigint AS co_id,
		ST_Collect(qgis_pkg.ST_snap_poly_to_grid(sg.geometry,',perform_snapping,',',digits,',',area_poly_min,'))::geometry(MultiPolygonZ,',srid_id,') AS geom
	FROM
		',citydb_schema,'.bridge_furniture AS o
		INNER JOIN ',citydb_schema,'.cityobject AS co ON (o.id = co.id AND o.objectclass_id = ',s.class_id,' ',sql_where,')
		INNER JOIN ',citydb_schema,'.bridge_room AS r ON (r.id = o.bridge_room_id)
		INNER JOIN ',citydb_schema,'.bridge AS b ON (b.id = r.bridge_id AND b.objectclass_id = ',r.class_id,')
		INNER JOIN ',citydb_schema,'.surface_geometry AS sg ON (sg.root_id = o.lod4_brep_id AND sg.geometry IS NOT NULL)
	WHERE
		o.lod4_implicit_rep_id IS NULL
	GROUP BY sg.cityobject_id
	UNION');

sql_statement := concat(sql_statement,'
	SELECT
		o.id::bigint AS co_id,
		ST_SetSRID(
			ST_Affine(ST_Collect(sg.implicit_geometry),
				   split_part(o.lod4_implicit_transformation, '' '', 1)::double precision,
				   0,0,0,
				   split_part(o.lod4_implicit_transformation, '' '', 6)::double precision,
				   0,0,0,
				   split_part(o.lod4_implicit_transformation, '' '', 11)::double precision,
				   ST_X(o.lod4_implicit_ref_point),
				   ST_Y(o.lod4_implicit_ref_point),
				   ST_Z(o.lod4_implicit_ref_point)
				   ),
			',srid_id,')::geometry(MultiPolygonZ, ',srid_id,') AS geom
	FROM 
		',citydb_schema,'.bridge_furniture AS o
		INNER JOIN ',citydb_schema,'.cityobject AS co ON (o.id = co.id AND o.objectclass_id = ',s.class_id,' ',sql_where,')		
		INNER JOIN ',citydb_schema,'.bridge_room AS r ON (r.id = o.bridge_room_id)
		INNER JOIN ',citydb_schema,'.bridge AS b ON (b.id = r.bridge_id AND b.objectclass_id = ',r.class_id,')	
		INNER JOIN ',citydb_schema,'.implicit_geometry AS ig ON (ig.id = o.lod4_implicit_rep_id) 
		INNER JOIN ',citydb_schema,'.surface_geometry AS sg ON (sg.root_id = ig.relative_brep_id AND sg.implicit_geometry IS NOT NULL)
	WHERE
		o.lod4_implicit_rep_id IS NOT NULL
	GROUP BY o.id
WITH NO DATA;
COMMENT ON MATERIALIZED VIEW qgis_pkg.',mview_name,' IS ''Mat. view of (',r.class_name,') ',s.class_name,' ',t.lodx_name,' in schema ',citydb_schema,''';
CREATE INDEX ',mview_idx_name,' ON qgis_pkg.',mview_name,' (co_id);
CREATE INDEX ',mview_spx_name,' ON qgis_pkg.',mview_name,' USING gist (geom);
DELETE FROM qgis_pkg.layer_metadata WHERE v_name = ''',view_name,''';
INSERT INTO qgis_pkg.layer_metadata (schema_name, feature_type, qml_file, lod, root_class, layer_name, creation_date, mv_name, v_name) VALUES
(''',citydb_schema,''',''',feature_type,''',''',qml_file_name,''',''',t.lodx_label,''',''',s.class_name,''',''',l_name,''',clock_timestamp(),''',mview_name,''',''',view_name,''');
');
EXECUTE sql_statement;

	END LOOP; -- bridge furniture

END LOOP;  -- bridge

-- ***********************
-- TRANSPORTATION MODULE
-- ***********************
feature_type     := 'Transportation';

---------------------------------------------------------------
-- Create MATERIALIZED VIEW QGIS_PKG._G_*_TRANSPORTATION_COMPLEX_LOD1
---------------------------------------------------------------
FOR r IN 
	SELECT * FROM (VALUES
	('TransportationComplex'::varchar,	42::integer, 	'tran_complex'::varchar),
	('Track',							43,				'track'),
	('Railway',							44,				'railway'),
	('Road',							45,				'road'),
	('Square',							46,				'square')		   
	) AS t(class_name, class_id, class_label)
LOOP

l_name         := format(      '%I_lod1',						   r.class_label);
view_name      := format(   '%I_%I_lod1',			citydb_schema, r.class_label);
mview_name     := format('_g_%I_%I_lod1',			citydb_schema, r.class_label);
mview_idx_name := format('_g_%I_%I_lod1_id_idx',	citydb_schema, r.class_label);
mview_spx_name := format('_g_%I_%I_lod1_geom_spx',	citydb_schema, r.class_label);
qml_file_name  := concat('transportation_form.qml');

IF mview_bbox IS NOT NULL THEN
	sql_where := concat('AND ST_MakeEnvelope(',mview_bbox_xmin,', ',mview_bbox_ymin,', ',mview_bbox_xmax,', ',mview_bbox_ymax,', ',srid_id,') && co.envelope');
ELSE
	sql_where := NULL;
END IF;

sql_statement := concat('
DROP MATERIALIZED VIEW IF EXISTS qgis_pkg.',mview_name,' CASCADE;
CREATE MATERIALIZED VIEW         qgis_pkg.',mview_name,' AS
	SELECT
		sg.cityobject_id::bigint AS co_id,
		ST_Collect(qgis_pkg.ST_snap_poly_to_grid(sg.geometry,',perform_snapping,',',digits,',',area_poly_min,'))::geometry(MultiPolygonZ, ',srid_id,') AS geom
	FROM
		',citydb_schema,'.transportation_complex AS o
		INNER JOIN ',citydb_schema,'.cityobject AS co ON (o.id = co.id AND o.objectclass_id = ',r.class_id,' ',sql_where,')		
		INNER JOIN ',citydb_schema,'.surface_geometry AS sg ON (sg.root_id = o.lod1_multi_surface_id AND sg.geometry IS NOT NULL)
	GROUP BY sg.cityobject_id
WITH NO DATA;
COMMENT ON MATERIALIZED VIEW qgis_pkg.',mview_name,' IS ''Mat. view of ',r.class_name,' LoD1 in schema ',citydb_schema,''';
CREATE INDEX ',mview_idx_name,' ON qgis_pkg.',mview_name,' (co_id);
CREATE INDEX ',mview_spx_name,' ON qgis_pkg.',mview_name,' USING gist (geom);
DELETE FROM qgis_pkg.layer_metadata WHERE v_name = ''',view_name,''';
INSERT INTO qgis_pkg.layer_metadata (schema_name, feature_type, qml_file, lod, root_class, layer_name, creation_date, mv_name, v_name) VALUES
(''',citydb_schema,''',''',feature_type,''',''',qml_file_name,''',''lod1'',''',r.class_name,''',''',l_name,''',clock_timestamp(),''',mview_name,''',''',view_name,''');
');
EXECUTE sql_statement;

---------------------------------------------------------------
-- Create MATERIALIZED VIEW QGIS_PKG._G_*_TRANSPORTATION_COMPLEX_LOD2-4
---------------------------------------------------------------
	FOR t IN 
		SELECT * FROM (VALUES
		('LoD2'::varchar, 'lod2'::varchar),
		('LoD3'			, 'lod3'),
		('LoD4'			, 'lod4')			
		) AS t(lodx_name, lodx_label)
	LOOP

l_name         := format(      '%I_%I',							   r.class_label, t.lodx_label);
view_name      := format(   '%I_%I_%I',				citydb_schema, r.class_label, t.lodx_label);
mview_name     := format('_g_%I_%I_%I',				citydb_schema, r.class_label, t.lodx_label);
mview_idx_name := format('_g_%I_%I_%I_id_idx',		citydb_schema, r.class_label, t.lodx_label);
mview_spx_name := format('_g_%I_%I_%I_geom_spx',	citydb_schema, r.class_label, t.lodx_label);
qml_file_name  := concat('transportation_form.qml');

IF mview_bbox IS NOT NULL THEN
	sql_where := concat('AND ST_MakeEnvelope(',mview_bbox_xmin,', ',mview_bbox_ymin,', ',mview_bbox_xmax,', ',mview_bbox_ymax,', ',srid_id,') && co.envelope');
ELSE
	sql_where := NULL;
END IF;

sql_statement := concat('
DROP MATERIALIZED VIEW IF EXISTS qgis_pkg.',mview_name,' CASCADE;
CREATE MATERIALIZED VIEW         qgis_pkg.',mview_name,' AS
	SELECT
		foo2.co_id::bigint AS co_id,
		ST_Collect(qgis_pkg.ST_snap_poly_to_grid(sg.geometry,',perform_snapping,',',digits,',',area_poly_min,'))::geometry(MultiPolygonZ, ',srid_id,') AS geom
	FROM (
		SELECT
			foo.co_id,
			unnest(foo.sg_id_array) AS sg_id
		FROM (
			SELECT
				coalesce(o.id, ta_t.co_id) as co_id,
				--o.id AS co_id,
				CASE 
					WHEN ta_t.sg_id_array IS NOT NULL THEN ta_t.sg_id_array
					ELSE ARRAY[o.',t.lodx_label,'_multi_surface_id]
				END AS sg_id_array 
			FROM 
				',citydb_schema,'.transportation_complex AS o
				INNER JOIN ',citydb_schema,'.cityobject AS co ON (o.id = co.id AND o.objectclass_id = ',r.class_id,' ',sql_where,')
				FULL OUTER JOIN (
				--INNER JOIN (
					SELECT 
						ta.transportation_complex_id AS co_id, 
						array_agg(ta.',t.lodx_label,'_multi_surface_id) AS sg_id_array
					FROM 
						',citydb_schema,'.traffic_area AS ta
						INNER JOIN ',citydb_schema,'.cityobject AS co ON (co.id = ta.id ',sql_where,')
						INNER JOIN ',citydb_schema,'.transportation_complex AS tc ON (tc.id = ta.transportation_complex_id AND tc.objectclass_id = ',r.class_id,')	
					GROUP BY ta.transportation_complex_id
				) AS ta_t ON (ta_t.co_id = o.id)
			) AS foo
		) AS foo2
		INNER JOIN ',citydb_schema,'.surface_geometry AS sg ON (sg.root_id = foo2.sg_id AND sg.geometry IS NOT NULL)
	GROUP BY foo2.co_id
WITH NO DATA;
COMMENT ON MATERIALIZED VIEW qgis_pkg.',mview_name,' IS ''Mat. view of ',r.class_name,' ',t.lodx_name,' in schema ',citydb_schema,''';
CREATE INDEX ',mview_idx_name,' ON qgis_pkg.',mview_name,' (co_id);
CREATE INDEX ',mview_spx_name,' ON qgis_pkg.',mview_name,' USING gist (geom);
DELETE FROM qgis_pkg.layer_metadata WHERE v_name = ''',view_name,''';
INSERT INTO qgis_pkg.layer_metadata (schema_name, feature_type, qml_file, lod, root_class, layer_name, creation_date, mv_name, v_name) VALUES
(''',citydb_schema,''',''',feature_type,''',''',qml_file_name,''',''',t.lodx_label,''',''',r.class_name,''',''',l_name,''',clock_timestamp(),''',mview_name,''',''',view_name,''');
');
EXECUTE sql_statement;

		FOR u IN 
			SELECT * FROM (VALUES
			('TrafficArea'::varchar,	47::integer, 	'traffic_area'::varchar),
			('AuxiliaryTrafficArea',	48,				'aux_traffic_area')
			) AS t(class_name, class_id, class_label)
		LOOP

l_name         := format(      '%I_%I_%I',							   r.class_label, t.lodx_label, u.class_label);
view_name      := format(   '%I_%I_%I_%I',				citydb_schema, r.class_label, t.lodx_label, u.class_label);
mview_name     := format('_g_%I_%I_%I_%I',				citydb_schema, r.class_label, t.lodx_label, u.class_label);
mview_idx_name := format('_g_%I_%I_%I_%I_id_idx',		citydb_schema, r.class_label, t.lodx_label, u.class_label);
mview_spx_name := format('_g_%I_%I_%I_%I_geom_spx',	citydb_schema, r.class_label, t.lodx_label, u.class_label);
qml_file_name  := concat('traffic_area_form.qml');

IF mview_bbox IS NOT NULL THEN
	sql_where := concat('AND ST_MakeEnvelope(',mview_bbox_xmin,', ',mview_bbox_ymin,', ',mview_bbox_xmax,', ',mview_bbox_ymax,', ',srid_id,') && co.envelope');
ELSE
	sql_where := NULL;
END IF;

sql_statement := concat('
DROP MATERIALIZED VIEW IF EXISTS qgis_pkg.',mview_name,' CASCADE;
CREATE MATERIALIZED VIEW         qgis_pkg.',mview_name,' AS

	SELECT
		sg.cityobject_id::bigint AS co_id,
		ST_Collect(qgis_pkg.ST_snap_poly_to_grid(sg.geometry,',perform_snapping,',',digits,',',area_poly_min,'))::geometry(MultiPolygonZ, ',srid_id,') AS geom
	FROM
		',citydb_schema,'.traffic_area AS o
		INNER JOIN ',citydb_schema,'.cityobject AS co ON (o.id = co.id AND o.objectclass_id = ',u.class_id,' ',sql_where,')
		INNER JOIN ',citydb_schema,'.transportation_complex AS tc ON (tc.id = o.transportation_complex_id AND tc.objectclass_id = ',r.class_id,')		
		INNER JOIN ',citydb_schema,'.surface_geometry AS sg ON (sg.root_id = o.',t.lodx_label,'_multi_surface_id AND sg.geometry IS NOT NULL)
	GROUP BY sg.cityobject_id
WITH NO DATA;
COMMENT ON MATERIALIZED VIEW qgis_pkg.',mview_name,' IS ''Mat. view of (',r.class_name,') ',t.lodx_name,' ',u.class_label,' in schema ',citydb_schema,''';
CREATE INDEX ',mview_idx_name,' ON qgis_pkg.',mview_name,' (co_id);
CREATE INDEX ',mview_spx_name,' ON qgis_pkg.',mview_name,' USING gist (geom);
DELETE FROM qgis_pkg.layer_metadata WHERE v_name = ''',view_name,''';
INSERT INTO qgis_pkg.layer_metadata (schema_name, feature_type, qml_file, lod, root_class, layer_name, creation_date, mv_name, v_name) VALUES
(''',citydb_schema,''',''',feature_type,''',''',qml_file_name,''',''',t.lodx_label,''',''',r.class_name,''',''',l_name,''',clock_timestamp(),''',mview_name,''',''',view_name,''');
');
EXECUTE sql_statement;

		END LOOP; -- end loop (auxiliarry) traffic areas lod 2-4

	END LOOP; -- end loop transportaton lod 2-4

END LOOP;  -- end loop transportaton


-- ***********************
-- TUNNEL MODULE
-- ***********************
feature_type     := 'Tunnel';

FOR r IN 
	SELECT * FROM (VALUES
	('Tunnel'::varchar, 84::integer, 'tun'::varchar),
	('TunnelPart'     , 85         , 'tun_part')		   
	) AS t(class_name, class_id, class_label)
LOOP

---------------------------------------------------------------
-- Create MATERIALIZED VIEW QGIS_PKG._G_*_TUNNEL(PART)_LOD1
---------------------------------------------------------------
l_name         := format(      '%I_lod1',							r.class_label);
view_name      := format(   '%I_%I_lod1',			citydb_schema, r.class_label);
mview_name     := format('_g_%I_%I_lod1',			citydb_schema, r.class_label);
mview_idx_name := format('_g_%I_%I_lod1_id_idx',	citydb_schema, r.class_label);
mview_spx_name := format('_g_%I_%I_lod1_geom_spx',	citydb_schema, r.class_label);
qml_file_name  := concat(r.class_label,'_form.qml');

IF mview_bbox IS NOT NULL THEN
	sql_where := concat('AND ST_MakeEnvelope(',mview_bbox_xmin,', ',mview_bbox_ymin,', ',mview_bbox_xmax,', ',mview_bbox_ymax,', ',srid_id,') && co.envelope');
ELSE
	sql_where := NULL;
END IF;

sql_statement := concat('
DROP MATERIALIZED VIEW IF EXISTS qgis_pkg.',mview_name,' CASCADE;
CREATE MATERIALIZED VIEW         qgis_pkg.',mview_name,' AS
	SELECT
		sg.cityobject_id::bigint AS co_id,
		ST_Collect(qgis_pkg.ST_snap_poly_to_grid(sg.geometry,',perform_snapping,',',digits,',',area_poly_min,'))::geometry(MultiPolygonZ, ',srid_id,') AS geom	
	FROM (
		SELECT
			o.id AS co_id, 	
			CASE
				WHEN o.lod1_solid_id IS NOT NULL THEN o.lod1_solid_id
				ELSE o.lod1_multi_surface_id
			END	AS sg_id 
		FROM 
			',citydb_schema,'.tunnel AS o
			INNER JOIN ',citydb_schema,'.cityobject AS co ON (o.id=co.id AND o.objectclass_id = ',r.class_id,' ',sql_where,') 
		WHERE			
			NOT(o.lod1_solid_id IS NULL AND o.lod1_multi_surface_id IS NULL)
		) AS foo
		INNER JOIN ',citydb_schema,'.surface_geometry AS sg ON (sg.root_id = foo.sg_id AND sg.geometry IS NOT NULL)
	GROUP BY sg.cityobject_id
WITH NO DATA;
COMMENT ON MATERIALIZED VIEW qgis_pkg.',mview_name,' IS ''Mat. view of ',r.class_name,' LoD1 in schema ',citydb_schema,''';
CREATE INDEX ',mview_idx_name,' ON qgis_pkg.',mview_name,' (co_id);
CREATE INDEX ',mview_spx_name,' ON qgis_pkg.',mview_name,' USING gist (geom);
DELETE FROM qgis_pkg.layer_metadata WHERE v_name = ''',view_name,''';
INSERT INTO qgis_pkg.layer_metadata (schema_name, feature_type, qml_file, lod, root_class, layer_name, creation_date, mv_name, v_name) VALUES
(''',citydb_schema,''',''',feature_type,''',''',qml_file_name,''',''lod1'',''',r.class_name,''',''',l_name,''',clock_timestamp(),''',mview_name,''',''',view_name,''');
');
EXECUTE sql_statement;

---------------------------------------------------------------
-- Create MATERIALIZED VIEW QGIS_PKG._G_*_TUNNEL(PART)_LOD2-4
---------------------------------------------------------------
	FOR t IN 
		SELECT * FROM (VALUES
		('LoD2'::varchar, 'lod2'::varchar),
		('LoD3'			, 'lod3'),
		('LoD4'			, 'lod4')		
		) AS t(lodx_name, lodx_label)
	LOOP

l_name         := format(      '%I_%I',								r.class_label, t.lodx_label);
view_name      := format(   '%I_%I_%I',				citydb_schema, r.class_label, t.lodx_label);
mview_name     := format('_g_%I_%I_%I', 			citydb_schema, r.class_label, t.lodx_label);
mview_idx_name := format('_g_%I_%I_%I_id_idx',  	citydb_schema, r.class_label, t.lodx_label);
mview_spx_name := format('_g_%I_%I_%I_geom_spx',	citydb_schema, r.class_label, t.lodx_label);
qml_file_name  := concat(r.class_label,'_form.qml');

IF mview_bbox IS NOT NULL THEN
	sql_where := concat('AND ST_MakeEnvelope(',mview_bbox_xmin,', ',mview_bbox_ymin,', ',mview_bbox_xmax,', ',mview_bbox_ymax,', ',srid_id,') && co.envelope');
ELSE
	sql_where := NULL;
END IF;

sql_statement := concat('
DROP MATERIALIZED VIEW IF EXISTS qgis_pkg.',mview_name,' CASCADE;
CREATE MATERIALIZED VIEW         qgis_pkg.',mview_name,' AS
	SELECT
		foo2.co_id::bigint AS co_id,
		ST_Collect(qgis_pkg.ST_snap_poly_to_grid(sg.geometry,',perform_snapping,',',digits,',',area_poly_min,'))::geometry(MultiPolygonZ, ',srid_id,') AS geom	
	FROM (
		SELECT
			foo.co_id,
			unnest(foo.sg_id_array) AS sg_id
		FROM (
			SELECT
				-- coalesce(o.id, ts_t.co_id) as co_id,
				o.id AS co_id,
				CASE 
					WHEN ts_t.sg_id_array IS NOT NULL THEN ts_t.sg_id_array
					WHEN o.',t.lodx_label,'_solid_id IS NOT NULL THEN ARRAY[o.',t.lodx_label,'_solid_id]
					ELSE ARRAY[o.',t.lodx_label,'_multi_surface_id]
				END AS sg_id_array 
			FROM 
				',citydb_schema,'.tunnel AS o
				INNER JOIN ',citydb_schema,'.cityobject AS co ON (o.id = co.id AND o.objectclass_id= ',r.class_id,' ',sql_where,')
				-- FULL OUTER JOIN
				INNER JOIN (
					SELECT ts.tunnel_id AS co_id, array_agg(ts.',t.lodx_label,'_multi_surface_id) AS sg_id_array 
					FROM 
						',citydb_schema,'.tunnel_thematic_surface AS ts
						INNER JOIN ',citydb_schema,'.cityobject AS co ON (co.id = ts.id ',sql_where,')
						INNER JOIN ',citydb_schema,'.tunnel AS b1 ON (ts.tunnel_id = b1.id AND b1.objectclass_id = ',r.class_id,')	
					GROUP BY ts.tunnel_id
					) AS ts_t ON (ts_t.co_id = o.id)
			WHERE 
				sg_id_array IS NOT NULL
			) AS foo
		) AS foo2
		INNER JOIN ',citydb_schema,'.surface_geometry AS sg ON (sg.root_id = foo2.sg_id AND sg.geometry IS NOT NULL)
	GROUP BY foo2.co_id
WITH NO DATA;
COMMENT ON MATERIALIZED VIEW qgis_pkg.',mview_name,' IS ''Mat. view of ',r.class_name,' ',t.lodx_name,' in schema ',citydb_schema,''';
CREATE INDEX ',mview_idx_name,' ON qgis_pkg.',mview_name,' (co_id);
CREATE INDEX ',mview_spx_name,' ON qgis_pkg.',mview_name,' USING gist (geom);
DELETE FROM qgis_pkg.layer_metadata WHERE v_name = ''',view_name,''';
INSERT INTO qgis_pkg.layer_metadata (schema_name, feature_type, qml_file, lod, root_class, layer_name, creation_date, mv_name, v_name) VALUES
(''',citydb_schema,''',''',feature_type,''',''',qml_file_name,''',''',t.lodx_label,''',''',r.class_name,''',''',l_name,''',clock_timestamp(),''',mview_name,''',''',view_name,''');
');
EXECUTE sql_statement;

---------------------------------------------------------------
-- Create MATERIALIZED VIEW QGIS_PKG._G_*_TUNNEL(PART)_LOD2-4_THEMATIC_SURFACES
---------------------------------------------------------------
		FOR u IN 
			SELECT * FROM (VALUES
			('TunnelRoofSurface'::varchar , 92::integer, 'roofsurf'::varchar),
			('TunnelWallSurface'		  , 93		   , 'wallsurf'),
			('TunnelGroundSurface'		  , 94		   , 'groundsurf'),
			('TunnelClosureSurface'		  , 95		   , 'closuresurf'),
			('OuterTunnelCeilingSurface'  , 96		   , 'outerceilingsurf'),
			('OuterTunnelFloorSurface'	  , 97		   , 'outerfloorsurf')
			) AS t(themsurf_name, class_id, themsurf_label)
		LOOP

l_name         := format(      '%I_%I_%I',						   r.class_label, t.lodx_label, u.themsurf_label);
view_name      := format(   '%I_%I_%I_%I',			citydb_schema, r.class_label, t.lodx_label, u.themsurf_label);
mview_name     := format('_g_%I_%I_%I_%I', 			citydb_schema, r.class_label, t.lodx_label, u.themsurf_label);
mview_idx_name := format('_g_%I_%I_%I_%I_id_idx',   citydb_schema, r.class_label, t.lodx_label, u.themsurf_label);
mview_spx_name := format('_g_%I_%I_%I_%I_geom_spx',	citydb_schema, r.class_label, t.lodx_label, u.themsurf_label);
qml_file_name  := concat(r.class_label,'_them_surf_form.qml');

IF mview_bbox IS NOT NULL THEN
	sql_where := concat('AND ST_MakeEnvelope(',mview_bbox_xmin,', ',mview_bbox_ymin,', ',mview_bbox_xmax,', ',mview_bbox_ymax,', ',srid_id,') && co.envelope');
ELSE
	sql_where := NULL;
END IF;

sql_statement := concat('
DROP MATERIALIZED VIEW IF EXISTS qgis_pkg.',mview_name,' CASCADE;
CREATE MATERIALIZED VIEW         qgis_pkg.',mview_name,' AS
	SELECT
		sg.cityobject_id::bigint AS co_id,
		ST_Collect(qgis_pkg.ST_snap_poly_to_grid(sg.geometry,',perform_snapping,',',digits,',',area_poly_min,'))::geometry(MultiPolygonZ, ',srid_id,') AS geom
	FROM
		',citydb_schema,'.tunnel_thematic_surface AS o
		INNER JOIN ',citydb_schema,'.cityobject AS co ON (o.id = co.id AND o.objectclass_id = ',u.class_id,' ',sql_where,')		
		INNER JOIN ',citydb_schema,'.tunnel AS b ON (o.tunnel_id = b.id AND b.objectclass_id = ',r.class_id,')
		INNER JOIN ',citydb_schema,'.surface_geometry AS sg ON (sg.root_id = o.',t.lodx_name,'_multi_surface_id AND sg.geometry IS NOT NULL)
	GROUP BY sg.cityobject_id
WITH NO DATA;
COMMENT ON MATERIALIZED VIEW qgis_pkg.',mview_name,' IS ''Mat. view of (',r.class_name,') ',t.lodx_name,' ',u.themsurf_name,' in schema ',citydb_schema,''';
CREATE INDEX ',mview_idx_name,' ON qgis_pkg.',mview_name,' (co_id);
CREATE INDEX ',mview_spx_name,' ON qgis_pkg.',mview_name,' USING gist (geom);
DELETE FROM qgis_pkg.layer_metadata WHERE v_name = ''',view_name,''';
INSERT INTO qgis_pkg.layer_metadata (schema_name, feature_type, qml_file, lod, root_class, layer_name, creation_date, mv_name, v_name) VALUES
(''',citydb_schema,''',''',feature_type,''',''',qml_file_name,''',''',t.lodx_label,''',''',r.class_name,''',''',l_name,''',clock_timestamp(),''',mview_name,''',''',view_name,''');
');
EXECUTE sql_statement;


		END LOOP; -- tunnel thematic surface
	END LOOP; -- tunnel lod2-4

---------------------------------------------------------------
-- Create MATERIALIZED VIEW QGIS_PKG._G_**_TUNNEL_INSTALLATION_**_LOD2-4
---------------------------------------------------------------
	FOR s IN 
		SELECT * FROM (VALUES
		('TunnelInstallation'::varchar, 86::integer, 'out_inst'::varchar)
		) AS t(class_name, class_id, class_label)
	LOOP
		FOR t IN 
			SELECT * FROM (VALUES
			('LoD2'::varchar, 'lod2'::varchar),
			('LoD3'			, 'lod3'),
			('LoD4'			, 'lod4')		
			) AS t(lodx_name, lodx_label)
		LOOP

l_name         := format(      '%I_%I_%I',							r.class_label, s.class_label, t.lodx_label);
view_name      := format(   '%I_%I_%I_%I',			citydb_schema, r.class_label, s.class_label, t.lodx_label);
mview_name     := format('_g_%I_%I_%I_%I',			citydb_schema, r.class_label, s.class_label, t.lodx_label);
mview_idx_name := format('_g_%I_%I_%I_%I_id_idx',	citydb_schema, r.class_label, s.class_label, t.lodx_label);
mview_spx_name := format('_g_%I_%I_%I_%I_geom_spx',	citydb_schema, r.class_label, s.class_label, t.lodx_label);
qml_file_name  := concat(r.class_label,'_',s.class_label,'_form.qml');

IF mview_bbox IS NOT NULL THEN
	sql_where := concat('AND ST_MakeEnvelope(',mview_bbox_xmin,', ',mview_bbox_ymin,', ',mview_bbox_xmax,', ',mview_bbox_ymax,', ',srid_id,') && co.envelope');
ELSE
	sql_where := NULL;
END IF;

sql_statement := concat('
DROP MATERIALIZED VIEW IF EXISTS qgis_pkg.',mview_name,' CASCADE;
CREATE MATERIALIZED VIEW         qgis_pkg.',mview_name,' AS
	SELECT 
		foo2.co_id AS co_id,
		st_collect(qgis_pkg.ST_snap_poly_to_grid(sg.geometry,',perform_snapping,',',digits,',',area_poly_min,'))::geometry(MultiPolygonZ, ',srid_id,') AS geom
	FROM ( 
			SELECT 
				foo.co_id,
				unnest(foo.sg_id_array) AS sg_id
			FROM ( 
					SELECT
						o.id AS co_id,
						CASE
							WHEN ts_t.sg_id_array IS NOT NULL THEN ts_t.sg_id_array
							ELSE ARRAY[o.',t.lodx_label,'_brep_id]
						END AS sg_id_array
					FROM 
						',citydb_schema,'.tunnel_installation AS o
						INNER JOIN ',citydb_schema,'.cityobject AS co ON (o.id = co.id AND o.objectclass_id = ',s.class_id,' ',sql_where,')
						INNER JOIN (
							SELECT
								o.tunnel_installation_id AS co_id,
								array_agg(o.',t.lodx_label,'_multi_surface_id) AS sg_id_array
							FROM 
								',citydb_schema,'.tunnel_thematic_surface AS o
								INNER JOIN ',citydb_schema,'.cityobject AS co ON (co.id = o.id ',sql_where,')
								INNER JOIN ',citydb_schema,'.tunnel AS b ON (o.tunnel_id = b.id AND b.objectclass_id = ',r.class_id,')
							WHERE 
								o.tunnel_installation_id IS NOT NULL
							GROUP BY o.tunnel_installation_id
						) AS ts_t ON (ts_t.co_id = o.id)
					WHERE
						o.',t.lodx_label,'_implicit_rep_id IS NULL
				) AS foo
	   ) AS foo2
	INNER JOIN ',citydb_schema,'.surface_geometry AS sg ON (sg.root_id = foo2.sg_id AND sg.geometry IS NOT NULL)
	GROUP BY foo2.co_id
	UNION');
-- the need to split is due to max 100 arguments allowed in the concat function.
sql_statement := concat(sql_statement,'	
	SELECT
		o.id::bigint AS co_id,
		ST_SetSRID(
			ST_Affine(ST_Collect(sg.implicit_geometry),
				   split_part(o.',t.lodx_label,'_implicit_transformation, '' '', 1)::double precision,
				   0,0,0,
				   split_part(o.',t.lodx_label,'_implicit_transformation, '' '', 6)::double precision,
				   0,0,0,
				   split_part(o.',t.lodx_label,'_implicit_transformation, '' '', 11)::double precision,
				   ST_X(o.',t.lodx_label,'_implicit_ref_point),
				   ST_Y(o.',t.lodx_label,'_implicit_ref_point),
				   ST_Z(o.',t.lodx_label,'_implicit_ref_point)
				   ),
			',srid_id,')::geometry(MultiPolygonZ, ',srid_id,') AS geom
	FROM 
		',citydb_schema,'.tunnel_installation AS o
		INNER JOIN ',citydb_schema,'.cityobject AS co ON (o.id = co.id AND o.objectclass_id = ',s.class_id,' ',sql_where,')
		INNER JOIN ',citydb_schema,'.tunnel AS b ON (b.id = o.tunnel_id AND b.objectclass_id = ',r.class_id,')
		INNER JOIN ',citydb_schema,'.implicit_geometry AS ig ON (ig.id = o.',t.lodx_label,'_implicit_rep_id)
		INNER JOIN ',citydb_schema,'.surface_geometry AS sg ON (sg.root_id = ig.relative_brep_id AND sg.implicit_geometry IS NOT NULL)
	WHERE
		o.',t.lodx_label,'_implicit_rep_id IS NOT NULL
	GROUP BY o.id
WITH NO DATA;
COMMENT ON MATERIALIZED VIEW qgis_pkg.',mview_name,' IS ''Mat. view of ',s.class_name,' ',t.lodx_name,' in schema ',citydb_schema,''';
CREATE INDEX ',mview_idx_name,' ON qgis_pkg.',mview_name,' (co_id);
CREATE INDEX ',mview_spx_name,' ON qgis_pkg.',mview_name,' USING gist (geom);
DELETE FROM qgis_pkg.layer_metadata WHERE v_name = ''',view_name,''';
INSERT INTO qgis_pkg.layer_metadata (schema_name, feature_type, qml_file, lod, root_class, layer_name, creation_date, mv_name, v_name) VALUES
(''',citydb_schema,''',''',feature_type,''',''',qml_file_name,''',''',t.lodx_label,''',''',s.class_name,''',''',l_name,''',clock_timestamp(),''',mview_name,''',''',view_name,''');
');
EXECUTE sql_statement;

---------------------------------------------------------------
-- Create MATERIALIZED VIEW QGIS_PKG._G_*_TUNNEL_INSTALLATION_LOD2-4_THEMATIC_SURFACES
---------------------------------------------------------------
			FOR u IN 
				SELECT * FROM (VALUES
				('TunnelRoofSurface'::varchar , 92::integer, 'roofsurf'::varchar),
				('TunnelWallSurface'		  , 93		   , 'wallsurf'),
				('TunnelGroundSurface'		  , 94		   , 'groundsurf'),
				('TunnelClosureSurface'		  , 95		   , 'closuresurf'),
				('OuterTunnelCeilingSurface'  , 96		   , 'outerceilingsurf'),
				('OuterTunnelFloorSurface'	  , 97		   , 'outerfloorsurf')
				) AS t(themsurf_name, class_id, themsurf_label)
			LOOP

l_name         := format(      '%I_%I_%I_%I',							r.class_label, s.class_label, t.lodx_label, u.themsurf_label);
view_name      := format(   '%I_%I_%I_%I_%I',			citydb_schema, r.class_label, s.class_label, t.lodx_label, u.themsurf_label);
mview_name     := format('_g_%I_%I_%I_%I_%I',			citydb_schema, r.class_label, s.class_label, t.lodx_label, u.themsurf_label);
mview_idx_name := format('_g_%I_%I_%I_%I_%I_id_idx',	citydb_schema, r.class_label, s.class_label, t.lodx_label, u.themsurf_label);
mview_spx_name := format('_g_%I_%I_%I_%I_%I_geom_spx',	citydb_schema, r.class_label, s.class_label, t.lodx_label, u.themsurf_label);
qml_file_name  := concat(r.class_label,'_',s.class_label,'_them_surf_form.qml');

IF mview_bbox IS NOT NULL THEN
	sql_where := concat('AND ST_MakeEnvelope(',mview_bbox_xmin,', ',mview_bbox_ymin,', ',mview_bbox_xmax,', ',mview_bbox_ymax,', ',srid_id,') && co.envelope');
ELSE
	sql_where := NULL;
END IF;

sql_statement := concat('
DROP MATERIALIZED VIEW IF EXISTS qgis_pkg.',mview_name,' CASCADE;
CREATE MATERIALIZED VIEW         qgis_pkg.',mview_name,' AS
	SELECT
		sg.cityobject_id::bigint AS co_id,
		ST_Collect(qgis_pkg.ST_snap_poly_to_grid(sg.geometry,',perform_snapping,',',digits,',',area_poly_min,'))::geometry(MultiPolygonZ,',srid_id,') AS geom
	FROM
		',citydb_schema,'.tunnel_thematic_surface AS o
		INNER JOIN ',citydb_schema,'.cityobject AS co ON (o.id = co.id AND o.objectclass_id = ',u.class_id,' ',sql_where,') 
		INNER JOIN ',citydb_schema,'.tunnel_installation AS bi ON (o.tunnel_installation_id = bi.id AND bi.objectclass_id = ',s.class_id,')
		INNER JOIN ',citydb_schema,'.tunnel AS b ON (o.tunnel_id = b.id AND b.objectclass_id = ',r.class_id,')		
		INNER JOIN ',citydb_schema,'.surface_geometry AS sg ON (sg.root_id = o.',t.lodx_name,'_multi_surface_id  AND sg.geometry IS NOT NULL)
	GROUP BY sg.cityobject_id
WITH NO DATA;
COMMENT ON MATERIALIZED VIEW qgis_pkg.',mview_name,' IS ''Mat. view of ',s.class_name,' ',t.lodx_name,' ',u.themsurf_name,' in schema ',citydb_schema,''';
CREATE INDEX ',mview_idx_name,' ON qgis_pkg.',mview_name,' (co_id);
CREATE INDEX ',mview_spx_name,' ON qgis_pkg.',mview_name,' USING gist (geom);
DELETE FROM qgis_pkg.layer_metadata WHERE v_name = ''',view_name,''';
INSERT INTO qgis_pkg.layer_metadata (schema_name, feature_type, qml_file, lod, root_class, layer_name, creation_date, mv_name, v_name) VALUES
(''',citydb_schema,''',''',feature_type,''',''',qml_file_name,''',''',t.lodx_label,''',''',s.class_name,''',''',l_name,''',clock_timestamp(),''',mview_name,''',''',view_name,''');
');
EXECUTE sql_statement;

			END LOOP; -- outer tunnel out install thematic surfaces loop
		END LOOP; -- outer tunnel out install lod loop
	END LOOP; -- outer tunnel installation loop

---------------------------------------------------------------
-- Create MATERIALIZED VIEW QGIS_PKG._G_**_INT_TUNNEL_INSTALLATION_LOD4
---------------------------------------------------------------
	FOR s IN 
		SELECT * FROM (VALUES
		('IntTunnelInstallation'::varchar, 87::integer, 'int_inst'::varchar)
		) AS t(class_name, class_id, class_label)
	LOOP

		FOR t IN 
			SELECT * FROM (VALUES
			('LoD4'::varchar, 'lod4'::varchar)
			) AS t(lodx_name, lodx_label)
		LOOP
l_name         := format(      '%I_%I_%I',							r.class_label, s.class_label, t.lodx_label);
view_name      := format(   '%I_%I_%I_%I',			citydb_schema, r.class_label, s.class_label, t.lodx_label);
mview_name     := format('_g_%I_%I_%I_%I',			citydb_schema, r.class_label, s.class_label, t.lodx_label);
mview_idx_name := format('_g_%I_%I_%I_%I_id_idx',	citydb_schema, r.class_label, s.class_label, t.lodx_label);
mview_spx_name := format('_g_%I_%I_%I_%I_geom_spx',	citydb_schema, r.class_label, s.class_label, t.lodx_label);
qml_file_name  := concat(r.class_label,'_',s.class_label,'_form.qml');

IF mview_bbox IS NOT NULL THEN
	sql_where := concat('AND ST_MakeEnvelope(',mview_bbox_xmin,', ',mview_bbox_ymin,', ',mview_bbox_xmax,', ',mview_bbox_ymax,', ',srid_id,') && co.envelope');
ELSE
	sql_where := NULL;
END IF;

sql_statement := concat('
DROP MATERIALIZED VIEW IF EXISTS qgis_pkg.',mview_name,' CASCADE;
CREATE MATERIALIZED VIEW         qgis_pkg.',mview_name,' AS
	SELECT 
		foo2.co_id AS co_id,
		st_collect(qgis_pkg.ST_snap_poly_to_grid(sg.geometry,',perform_snapping,',',digits,',',area_poly_min,'))::geometry(MultiPolygonZ, ',srid_id,') AS geom
	FROM ( 
			SELECT 
				foo.co_id,
				unnest(foo.sg_id_array) AS sg_id
			FROM ( 
					SELECT
						o.id AS co_id,
						CASE
							WHEN ts_t.sg_id_array IS NOT NULL THEN ts_t.sg_id_array
							ELSE ARRAY[o.',t.lodx_label,'_brep_id]
						END AS sg_id_array
					FROM 
						',citydb_schema,'.tunnel_installation AS o
						INNER JOIN ',citydb_schema,'.cityobject AS co ON (o.id = co.id AND o.objectclass_id = ',s.class_id,' ',sql_where,')
						INNER JOIN (
							SELECT
								o.tunnel_installation_id AS co_id,
								array_agg(o.',t.lodx_label,'_multi_surface_id) AS sg_id_array
							FROM 
								',citydb_schema,'.tunnel_thematic_surface AS o
								INNER JOIN ',citydb_schema,'.cityobject AS co ON (co.id = o.id ',sql_where,')
								INNER JOIN ',citydb_schema,'.tunnel AS b ON (o.tunnel_id = b.id AND b.objectclass_id = ',r.class_id,')
							WHERE 
								o.tunnel_installation_id IS NOT NULL
							GROUP BY o.tunnel_installation_id
						) AS ts_t ON (ts_t.co_id = o.id)
					WHERE
						o.',t.lodx_label,'_implicit_rep_id IS NULL
				) AS foo
	   ) AS foo2
	INNER JOIN ',citydb_schema,'.surface_geometry AS sg ON (sg.root_id = foo2.sg_id AND sg.geometry IS NOT NULL)
	GROUP BY foo2.co_id
	UNION');
-- the need to split is due to max 100 arguments allowed in the concat function.
sql_statement := concat(sql_statement,'	
	SELECT
		o.id::bigint AS co_id,
		ST_SetSRID(
			ST_Affine(ST_Collect(sg.implicit_geometry),
				   split_part(o.',t.lodx_label,'_implicit_transformation, '' '', 1)::double precision,
				   0,0,0,
				   split_part(o.',t.lodx_label,'_implicit_transformation, '' '', 6)::double precision,
				   0,0,0,
				   split_part(o.',t.lodx_label,'_implicit_transformation, '' '', 11)::double precision,
				   ST_X(o.',t.lodx_label,'_implicit_ref_point),
				   ST_Y(o.',t.lodx_label,'_implicit_ref_point),
				   ST_Z(o.',t.lodx_label,'_implicit_ref_point)
				   ),
			',srid_id,')::geometry(MultiPolygonZ, ',srid_id,') AS geom
	FROM 
		',citydb_schema,'.tunnel_installation AS o
		INNER JOIN ',citydb_schema,'.cityobject AS co ON (o.id = co.id AND o.objectclass_id = ',s.class_id,' ',sql_where,')
		INNER JOIN ',citydb_schema,'.tunnel AS b ON (b.id = o.tunnel_id AND b.objectclass_id = ',r.class_id,')
		INNER JOIN ',citydb_schema,'.implicit_geometry AS ig ON (ig.id = o.',t.lodx_label,'_implicit_rep_id)
		INNER JOIN ',citydb_schema,'.surface_geometry AS sg ON (sg.root_id = ig.relative_brep_id AND sg.implicit_geometry IS NOT NULL)
	WHERE
		o.',t.lodx_label,'_implicit_rep_id IS NOT NULL
	GROUP BY o.id
WITH NO DATA;
COMMENT ON MATERIALIZED VIEW qgis_pkg.',mview_name,' IS ''Mat. view of ',s.class_name,' ',t.lodx_name,' in schema ',citydb_schema,''';
CREATE INDEX ',mview_idx_name,' ON qgis_pkg.',mview_name,' (co_id);
CREATE INDEX ',mview_spx_name,' ON qgis_pkg.',mview_name,' USING gist (geom);
DELETE FROM qgis_pkg.layer_metadata WHERE v_name = ''',view_name,''';
INSERT INTO qgis_pkg.layer_metadata (schema_name, feature_type, qml_file, lod, root_class, layer_name, creation_date, mv_name, v_name) VALUES
(''',citydb_schema,''',''',feature_type,''',''',qml_file_name,''',''',t.lodx_label,''',''',s.class_name,''',''',l_name,''',clock_timestamp(),''',mview_name,''',''',view_name,''');
');
EXECUTE sql_statement;

---------------------------------------------------------------
-- Create MATERIALIZED VIEW QGIS_PKG._G_**_TUNNEL_INT_INSTALLATION_LOD4_THEMATIC_SURF
---------------------------------------------------------------
			FOR u IN 
				SELECT * FROM (VALUES
				('TunnelRoofSurface'::varchar , 92::integer, 'roofsurf'::varchar),
				('TunnelWallSurface'		  , 93		   , 'wallsurf'),
				('TunnelGroundSurface'		  , 94		   , 'groundsurf'),
				('TunnelClosureSurface'		  , 95		   , 'closuresurf'),
				('OuterTunnelCeilingSurface'  , 96		   , 'outerceilingsurf'),
				('OuterTunnelFloorSurface'	  , 97		   , 'outerfloorsurf')
				) AS t(themsurf_name, class_id, themsurf_label)
			LOOP

l_name         := format(      '%I_%I_%I_%I',						   r.class_label, s.class_label, t.lodx_label, u.themsurf_label);
view_name      := format(   '%I_%I_%I_%I_%I',			citydb_schema, r.class_label, s.class_label, t.lodx_label, u.themsurf_label);
mview_name     := format('_g_%I_%I_%I_%I_%I',			citydb_schema, r.class_label, s.class_label, t.lodx_label, u.themsurf_label);
mview_idx_name := format('_g_%I_%I_%I_%I_%I_id_idx',	citydb_schema, r.class_label, s.class_label, t.lodx_label, u.themsurf_label);
mview_spx_name := format('_g_%I_%I_%I_%I_%I_geom_spx',	citydb_schema, r.class_label, s.class_label, t.lodx_label, u.themsurf_label);
qml_file_name  := concat(r.class_label,'_',s.class_label,'_them_surf_form.qml');

IF mview_bbox IS NOT NULL THEN
	sql_where := concat('AND ST_MakeEnvelope(',mview_bbox_xmin,', ',mview_bbox_ymin,', ',mview_bbox_xmax,', ',mview_bbox_ymax,', ',srid_id,') && co.envelope');
ELSE
	sql_where := NULL;
END IF;

sql_statement := concat('
DROP MATERIALIZED VIEW IF EXISTS qgis_pkg.',mview_name,' CASCADE;
CREATE MATERIALIZED VIEW         qgis_pkg.',mview_name,' AS
	SELECT
		sg.cityobject_id::bigint AS co_id,
		ST_Collect(qgis_pkg.ST_snap_poly_to_grid(sg.geometry,',perform_snapping,',',digits,',',area_poly_min,'))::geometry(MultiPolygonZ,',srid_id,') AS geom
	FROM
		',citydb_schema,'.tunnel_thematic_surface AS o
		INNER JOIN ',citydb_schema,'.cityobject AS co ON (o.id = co.id AND o.objectclass_id = ',u.class_id,' ',sql_where,') 
		INNER JOIN ',citydb_schema,'.tunnel_installation AS bi ON (o.tunnel_installation_id = bi.id AND bi.objectclass_id = ',s.class_id,')
		INNER JOIN ',citydb_schema,'.tunnel AS b ON (o.tunnel_id = b.id AND b.objectclass_id = ',r.class_id,')		
		INNER JOIN ',citydb_schema,'.surface_geometry AS sg ON (sg.root_id = o.',t.lodx_name,'_multi_surface_id  AND sg.geometry IS NOT NULL)
	GROUP BY sg.cityobject_id
WITH NO DATA;
COMMENT ON MATERIALIZED VIEW qgis_pkg.',mview_name,' IS ''Mat. view of ',s.class_name,' ',t.lodx_name,' ',u.themsurf_name,' in schema ',citydb_schema,''';
CREATE INDEX ',mview_idx_name,' ON qgis_pkg.',mview_name,' (co_id);
CREATE INDEX ',mview_spx_name,' ON qgis_pkg.',mview_name,' USING gist (geom);
DELETE FROM qgis_pkg.layer_metadata WHERE v_name = ''',view_name,''';
INSERT INTO qgis_pkg.layer_metadata (schema_name, feature_type, qml_file, lod, root_class, layer_name, creation_date, mv_name, v_name) VALUES
(''',citydb_schema,''',''',feature_type,''',''',qml_file_name,''',''',t.lodx_label,''',''',s.class_name,''',''',l_name,''',clock_timestamp(),''',mview_name,''',''',view_name,''');
');
EXECUTE sql_statement;

			END LOOP; -- interior tunnel installation thematic surfaces lod loop
		END LOOP; -- interior tunnel installation lod loop
	END LOOP; -- interior tunnel installation loop

---------------------------------------------------------------
-- Create MATERIALIZED VIEW QGIS_PKG._G_**_TUNNEL_HOLLOW_SPACE_LOD4
---------------------------------------------------------------
	FOR s IN 
		SELECT * FROM (VALUES
		('TunnelHollowSpace'::varchar, 102::integer, 'hollow_space'::varchar)
		) AS t(class_name, class_id, class_label)
	LOOP
l_name         := format(      '%I_%I_lod4',							r.class_label, s.class_label);
view_name      := format(   '%I_%I_%I_lod4',			citydb_schema, r.class_label, s.class_label);
mview_name     := format('_g_%I_%I_%I_lod4', 			citydb_schema, r.class_label, s.class_label);
mview_idx_name := format('_g_%I_%I_%I_lod4_id_idx', 	citydb_schema, r.class_label, s.class_label);
mview_spx_name := format('_g_%I_%I_%I_lod4_geom_spx',	citydb_schema, r.class_label, s.class_label);
qml_file_name  := concat(r.class_label,'_',s.class_label,'_form.qml');

IF mview_bbox IS NOT NULL THEN
	sql_where := concat('AND ST_MakeEnvelope(',mview_bbox_xmin,', ',mview_bbox_ymin,', ',mview_bbox_xmax,', ',mview_bbox_ymax,', ',srid_id,') && co.envelope');
ELSE
	sql_where := NULL;
END IF;

sql_statement := concat('
DROP MATERIALIZED VIEW IF EXISTS qgis_pkg.',mview_name,' CASCADE;
CREATE MATERIALIZED VIEW         qgis_pkg.',mview_name,' AS

	SELECT
		foo2.co_id::bigint AS co_id,
		ST_Collect(qgis_pkg.ST_snap_poly_to_grid(sg.geometry,',perform_snapping,',',digits,',',area_poly_min,'))::geometry(MultiPolygonZ, ',srid_id,') AS geom	
	FROM (
		SELECT
			foo.co_id,
			unnest(foo.sg_id_array) AS sg_id
		FROM (
			SELECT
				-- coalesce(o.id, ts_t.co_id) as co_id,
				o.id AS co_id,
				CASE 
					WHEN ts_t.sg_id_array IS NOT NULL THEN ts_t.sg_id_array
					WHEN o.',t.lodx_label,'_solid_id IS NOT NULL THEN ARRAY[o.',t.lodx_label,'_solid_id]
					ELSE ARRAY[o.',t.lodx_label,'_multi_surface_id]
				END AS sg_id_array 
			FROM 
				',citydb_schema,'.tunnel_hollow_space AS o
				INNER JOIN ',citydb_schema,'.cityobject AS co ON (o.id = co.id AND o.objectclass_id = ',s.class_id,' ',sql_where,')
				INNER JOIN ',citydb_schema,'.tunnel AS b ON (b.id = o.tunnel_id AND b.objectclass_id = ',r.class_id,')
				-- FULL OUTER JOIN
				INNER JOIN (
					SELECT ts.tunnel_id AS co_id, array_agg(ts.',t.lodx_label,'_multi_surface_id) AS sg_id_array 
					FROM 
						',citydb_schema,'.tunnel_thematic_surface AS ts
						INNER JOIN ',citydb_schema,'.cityobject AS co ON (co.id = ts.id ',sql_where,')
						INNER JOIN ',citydb_schema,'.tunnel_hollow_space AS r ON (ts.tunnel_id = r.id AND r.objectclass_id = ',s.class_id,' ',sql_where,')
						INNER JOIN ',citydb_schema,'.tunnel AS b1 ON (b1.id = r.tunnel_id AND b1.objectclass_id = ',r.class_id,')						
					GROUP BY ts.tunnel_id
					) AS ts_t ON (ts_t.co_id = o.id)
			WHERE 
				sg_id_array IS NOT NULL
			) AS foo
		) AS foo2
		INNER JOIN ',citydb_schema,'.surface_geometry AS sg ON (sg.root_id = foo2.sg_id AND sg.geometry IS NOT NULL)
	GROUP BY foo2.co_id
WITH NO DATA;
COMMENT ON MATERIALIZED VIEW qgis_pkg.',mview_name,' IS ''Mat. view of (',r.class_name,') ',s.class_name,' ',t.lodx_name,' in schema ',citydb_schema,''';
CREATE INDEX ',mview_idx_name,' ON qgis_pkg.',mview_name,' (co_id);
CREATE INDEX ',mview_spx_name,' ON qgis_pkg.',mview_name,' USING gist (geom);
DELETE FROM qgis_pkg.layer_metadata WHERE v_name = ''',view_name,''';
INSERT INTO qgis_pkg.layer_metadata (schema_name, feature_type, qml_file, lod, root_class, layer_name, creation_date, mv_name, v_name) VALUES
(''',citydb_schema,''',''',feature_type,''',''',qml_file_name,''',''',t.lodx_label,''',''',s.class_name,''',''',l_name,''',clock_timestamp(),''',mview_name,''',''',view_name,''');
');
EXECUTE sql_statement;

---------------------------------------------------------------
-- Create MATERIALIZED VIEW QGIS_PKG._G_**_TUNNEL_HOLLOW_SPACE_LOD4_THEMATIC_SURFACES
---------------------------------------------------------------
			FOR u IN 
				SELECT * FROM (VALUES
				('TunnelCeilingSurface'::varchar	, 89::integer	, 'ceilingsurf'::varchar),
				('InteriorTunnelWallSurface'		, 90		 	, 'intwallsurf'),
				('TunnelFloorSurface'				, 91		    , 'floorsurf')
				) AS t(themsurf_name, class_id, themsurf_label)
			LOOP

l_name         := format(      '%I_%I_lod4_%I',								r.class_label, s.class_label, u.themsurf_label);
view_name      := format(   '%I_%I_%I_lod4_%I',				citydb_schema, r.class_label, s.class_label, u.themsurf_label);
mview_name     := format('_g_%I_%I_%I_lod4_%I',				citydb_schema, r.class_label, s.class_label, u.themsurf_label);
mview_idx_name := format('_g_%I_%I_%I_lod4_%I_id_idx',		citydb_schema, r.class_label, s.class_label, u.themsurf_label);
mview_spx_name := format('_g_%I_%I_%I_lod4_%I_geom_spx',	citydb_schema, r.class_label, s.class_label, u.themsurf_label);
qml_file_name  := concat(r.class_label,'_',s.class_label,'_them_surf_form.qml');

IF mview_bbox IS NOT NULL THEN
	sql_where := concat('AND ST_MakeEnvelope(',mview_bbox_xmin,', ',mview_bbox_ymin,', ',mview_bbox_xmax,', ',mview_bbox_ymax,', ',srid_id,') && co.envelope');
ELSE
	sql_where := NULL;
END IF;

sql_statement := concat('
DROP MATERIALIZED VIEW IF EXISTS qgis_pkg.',mview_name,' CASCADE;
CREATE MATERIALIZED VIEW         qgis_pkg.',mview_name,' AS
	SELECT
		sg.cityobject_id::bigint AS co_id,
		ST_Collect(qgis_pkg.ST_snap_poly_to_grid(sg.geometry,',perform_snapping,',',digits,',',area_poly_min,'))::geometry(MultiPolygonZ,',srid_id,') AS geom
	FROM
		',citydb_schema,'.tunnel_thematic_surface AS o
		INNER JOIN ',citydb_schema,'.cityobject AS co ON (o.id = co.id AND o.objectclass_id = ',u.class_id,' ',sql_where,') 
		INNER JOIN ',citydb_schema,'.tunnel_hollow_space AS r ON (o.tunnel_hollow_space_id = r.id AND r.objectclass_id = ',s.class_id,')
		INNER JOIN ',citydb_schema,'.tunnel AS b ON (r.tunnel_id = b.id AND b.objectclass_id = ',r.class_id,')		
		INNER JOIN ',citydb_schema,'.surface_geometry AS sg ON (sg.root_id = o.',t.lodx_name,'_multi_surface_id  AND sg.geometry IS NOT NULL)
	GROUP BY sg.cityobject_id
WITH NO DATA;
COMMENT ON MATERIALIZED VIEW qgis_pkg.',mview_name,' IS ''Mat. view of (',r.class_name,') ',s.class_name,' ',t.lodx_name,' ',u.themsurf_name,' in schema ',citydb_schema,''';
CREATE INDEX ',mview_idx_name,' ON qgis_pkg.',mview_name,' (co_id);
CREATE INDEX ',mview_spx_name,' ON qgis_pkg.',mview_name,' USING gist (geom);
DELETE FROM qgis_pkg.layer_metadata WHERE v_name = ''',view_name,''';
INSERT INTO qgis_pkg.layer_metadata (schema_name, feature_type, qml_file, lod, root_class, layer_name, creation_date, mv_name, v_name) VALUES
(''',citydb_schema,''',''',feature_type,''',''',qml_file_name,''',''',t.lodx_label,''',''',s.class_name,''',''',l_name,''',clock_timestamp(),''',mview_name,''',''',view_name,''');
');
EXECUTE sql_statement;

		END LOOP; -- tunnel hollowspace thematic surfaces loop
	END LOOP; -- tunnel hollowspace loop

---------------------------------------------------------------
-- Create MATERIALIZED VIEW QGIS_PKG._G_**_TUNNEL_WINDOW/DOOR_LOD3-4
---------------------------------------------------------------
	FOR s IN 
		SELECT * FROM (VALUES
		('TunnelWindow'::varchar, 99::integer, 'window'::varchar),
		('TunnelDoor'           , 100         , 'door')		
		) AS t(class_name, class_id, class_label)
	LOOP
		FOR t IN 
			SELECT * FROM (VALUES
			('LoD3'::varchar, 'lod3'::varchar),
			('LoD4'			, 'lod4')		
			) AS t(lodx_name, lodx_label)
		LOOP

-- The concat is here necessary because "window" is a reserved word and using format would add a " to the name.
l_name         := concat(						 r.class_label,'_',s.class_label,'_',t.lodx_label);
view_name      := concat(	   citydb_schema,'_',r.class_label,'_',s.class_label,'_',t.lodx_label);
mview_name     := concat('_g_',citydb_schema,'_',r.class_label,'_',s.class_label,'_',t.lodx_label);
mview_idx_name := concat('_g_',citydb_schema,'_',r.class_label,'_',s.class_label,'_',t.lodx_label,'_id_idx');
mview_spx_name := concat('_g_',citydb_schema,'_',r.class_label,'_',s.class_label,'_',t.lodx_label,'_geom_spx');
qml_file_name  := concat(r.class_label,'_opening_form.qml');

IF mview_bbox IS NOT NULL THEN
	sql_where := concat('AND ST_MakeEnvelope(',mview_bbox_xmin,', ',mview_bbox_ymin,', ',mview_bbox_xmax,', ',mview_bbox_ymax,', ',srid_id,') && co.envelope');
ELSE
	sql_where := NULL;
END IF;

sql_statement := concat('
DROP MATERIALIZED VIEW IF EXISTS qgis_pkg.',mview_name,' CASCADE;
CREATE MATERIALIZED VIEW         qgis_pkg.',mview_name,' AS
	SELECT
		sg.cityobject_id::bigint AS co_id,
		ST_Collect(qgis_pkg.ST_snap_poly_to_grid(sg.geometry,',perform_snapping,',',digits,',',area_poly_min,'))::geometry(MultiPolygonZ,',srid_id,') AS geom
	FROM
		',citydb_schema,'.tunnel_opening AS o
		INNER JOIN ',citydb_schema,'.cityobject AS co ON (o.id = co.id AND o.objectclass_id = ',s.class_id,' ',sql_where,')
		INNER JOIN ',citydb_schema,'.tunnel_open_to_them_srf AS ots ON (ots.tunnel_opening_id = o.id)
		INNER JOIN ',citydb_schema,'.tunnel_thematic_surface AS ts ON (ts.id = ots.tunnel_thematic_surface_id)
		INNER JOIN ',citydb_schema,'.tunnel AS b ON (b.id = ts.tunnel_id AND b.objectclass_id = ',r.class_id,')
		INNER JOIN ',citydb_schema,'.surface_geometry sg ON sg.root_id = o.',t.lodx_name,'_multi_surface_id  AND sg.geometry IS NOT NULL
	WHERE
		o.',t.lodx_name,'_implicit_rep_id IS NULL
	GROUP BY sg.cityobject_id
	UNION');

sql_statement := concat(sql_statement,'
	SELECT
		o.id::bigint AS co_id,
		ST_SetSRID(
			ST_Affine(ST_Collect(sg.implicit_geometry),
				   split_part(o.',t.lodx_label,'_implicit_transformation, '' '', 1)::double precision,
				   0,0,0,
				   split_part(o.',t.lodx_label,'_implicit_transformation, '' '', 6)::double precision,
				   0,0,0,
				   split_part(o.',t.lodx_label,'_implicit_transformation, '' '', 11)::double precision,
				   ST_X(o.',t.lodx_label,'_implicit_ref_point),
				   ST_Y(o.',t.lodx_label,'_implicit_ref_point),
				   ST_Z(o.',t.lodx_label,'_implicit_ref_point)
				   ),
			',srid_id,')::geometry(MultiPolygonZ, ',srid_id,') AS geom
	FROM 
		',citydb_schema,'.tunnel_opening AS o
		INNER JOIN ',citydb_schema,'.cityobject AS co ON (o.id = co.id AND o.objectclass_id = ',s.class_id,' ',sql_where,')		
		INNER JOIN ',citydb_schema,'.tunnel_open_to_them_srf AS ots ON (ots.tunnel_opening_id = o.id)
		INNER JOIN ',citydb_schema,'.tunnel_thematic_surface AS ts ON (ts.id = ots.tunnel_thematic_surface_id)
		INNER JOIN ',citydb_schema,'.tunnel AS b ON (b.id = ts.tunnel_id AND b.objectclass_id = ',r.class_id,')	
		INNER JOIN ',citydb_schema,'.implicit_geometry AS ig ON (ig.id = o.',t.lodx_name,'_implicit_rep_id) 
		INNER JOIN ',citydb_schema,'.surface_geometry AS sg ON (sg.root_id = ig.relative_brep_id AND sg.implicit_geometry IS NOT NULL)
	WHERE
		o.',t.lodx_name,'_implicit_rep_id IS NOT NULL
	GROUP BY o.id
WITH NO DATA;
COMMENT ON MATERIALIZED VIEW qgis_pkg.',mview_name,' IS ''Mat. view of (',r.class_name,') ',s.class_name,' ',t.lodx_name,' in schema ',citydb_schema,''';
CREATE INDEX ',mview_idx_name,' ON qgis_pkg.',mview_name,' (co_id);
CREATE INDEX ',mview_spx_name,' ON qgis_pkg.',mview_name,' USING gist (geom);
DELETE FROM qgis_pkg.layer_metadata WHERE v_name = ''',view_name,''';
INSERT INTO qgis_pkg.layer_metadata (schema_name, feature_type, qml_file, lod, root_class, layer_name, creation_date, mv_name, v_name) VALUES
(''',citydb_schema,''',''',feature_type,''',''',qml_file_name,''',''',t.lodx_label,''',''',s.class_name,''',''',l_name,''',clock_timestamp(),''',mview_name,''',''',view_name,''');
');
EXECUTE sql_statement;

		END LOOP; -- tunnel window/door lod
	END LOOP; -- tunnel window/door

---------------------------------------------------------------
-- Create MATERIALIZED VIEW QGIS_PKG._G_**_TUNNEL_FURNITURE_LOD4
---------------------------------------------------------------
	FOR s IN 
		SELECT * FROM (VALUES
		('TunnelFurniture'::varchar, 101::integer, 'furniture'::varchar)		
		) AS t(class_name, class_id, class_label)
	LOOP

l_name         := format(      '%I_%I_lod4',							r.class_label, s.class_label);
view_name      := format(   '%I_%I_%I_lod4',			citydb_schema, r.class_label, s.class_label);
mview_name     := format('_g_%I_%I_%I_lod4',			citydb_schema, r.class_label, s.class_label);
mview_idx_name := format('_g_%I_%I_%I_lod4_id_idx',		citydb_schema, r.class_label, s.class_label);
mview_spx_name := format('_g_%I_%I_%I_lod4_geom_spx',	citydb_schema, r.class_label, s.class_label);
qml_file_name  := concat(r.class_label,'_',s.class_label,'_form.qml');

IF mview_bbox IS NOT NULL THEN
	sql_where := concat('AND ST_MakeEnvelope(',mview_bbox_xmin,', ',mview_bbox_ymin,', ',mview_bbox_xmax,', ',mview_bbox_ymax,', ',srid_id,') && co.envelope');
ELSE
	sql_where := NULL;
END IF;

sql_statement := concat('
DROP MATERIALIZED VIEW IF EXISTS qgis_pkg.',mview_name,' CASCADE;
CREATE MATERIALIZED VIEW         qgis_pkg.',mview_name,' AS
	SELECT
		sg.cityobject_id::bigint AS co_id,
		ST_Collect(qgis_pkg.ST_snap_poly_to_grid(sg.geometry,',perform_snapping,',',digits,',',area_poly_min,'))::geometry(MultiPolygonZ,',srid_id,') AS geom
	FROM
		',citydb_schema,'.tunnel_furniture AS o
		INNER JOIN ',citydb_schema,'.cityobject AS co ON (o.id = co.id AND o.objectclass_id = ',s.class_id,' ',sql_where,')
		INNER JOIN ',citydb_schema,'.tunnel_hollow_space AS r ON (r.id = o.tunnel_hollow_space_id)
		INNER JOIN ',citydb_schema,'.tunnel AS b ON (b.id = r.tunnel_id AND b.objectclass_id = ',r.class_id,')
		INNER JOIN ',citydb_schema,'.surface_geometry AS sg ON (sg.root_id = o.lod4_brep_id AND sg.geometry IS NOT NULL)
	WHERE
		o.lod4_implicit_rep_id IS NULL
	GROUP BY sg.cityobject_id
	UNION');

sql_statement := concat(sql_statement,'
	SELECT
		o.id::bigint AS co_id,
		ST_SetSRID(
			ST_Affine(ST_Collect(sg.implicit_geometry),
				   split_part(o.lod4_implicit_transformation, '' '', 1)::double precision,
				   0,0,0,
				   split_part(o.lod4_implicit_transformation, '' '', 6)::double precision,
				   0,0,0,
				   split_part(o.lod4_implicit_transformation, '' '', 11)::double precision,
				   ST_X(o.lod4_implicit_ref_point),
				   ST_Y(o.lod4_implicit_ref_point),
				   ST_Z(o.lod4_implicit_ref_point)
				   ),
			',srid_id,')::geometry(MultiPolygonZ, ',srid_id,') AS geom
	FROM 
		',citydb_schema,'.tunnel_furniture AS o
		INNER JOIN ',citydb_schema,'.cityobject AS co ON (o.id = co.id AND o.objectclass_id = ',s.class_id,' ',sql_where,')		
		INNER JOIN ',citydb_schema,'.tunnel_hollow_space AS r ON (r.id = o.tunnel_hollow_space_id)
		INNER JOIN ',citydb_schema,'.tunnel AS b ON (b.id = r.tunnel_id AND b.objectclass_id = ',r.class_id,')	
		INNER JOIN ',citydb_schema,'.implicit_geometry AS ig ON (ig.id = o.lod4_implicit_rep_id) 
		INNER JOIN ',citydb_schema,'.surface_geometry AS sg ON (sg.root_id = ig.relative_brep_id AND sg.implicit_geometry IS NOT NULL)
	WHERE
		o.lod4_implicit_rep_id IS NOT NULL
	GROUP BY o.id
WITH NO DATA;
COMMENT ON MATERIALIZED VIEW qgis_pkg.',mview_name,' IS ''Mat. view of (',r.class_name,') ',s.class_name,' ',t.lodx_name,' in schema ',citydb_schema,''';
CREATE INDEX ',mview_idx_name,' ON qgis_pkg.',mview_name,' (co_id);
CREATE INDEX ',mview_spx_name,' ON qgis_pkg.',mview_name,' USING gist (geom);
DELETE FROM qgis_pkg.layer_metadata WHERE v_name = ''',view_name,''';
INSERT INTO qgis_pkg.layer_metadata (schema_name, feature_type, qml_file, lod, root_class, layer_name, creation_date, mv_name, v_name) VALUES
(''',citydb_schema,''',''',feature_type,''',''',qml_file_name,''',''',t.lodx_label,''',''',s.class_name,''',''',l_name,''',clock_timestamp(),''',mview_name,''',''',view_name,''');
');
EXECUTE sql_statement;

	END LOOP; -- tunnel furniture

END LOOP; -- tunnel(part)

-- ***********************
-- WATERBODY MODULE
-- ***********************
feature_type     := 'WaterBody';

---------------------------------------------------------------
-- Create MATERIALIZED VIEW QGIS_PKG._G_*_WATERBODY_LOD0-4
---------------------------------------------------------------
FOR r IN 
	SELECT * FROM (VALUES
	('WaterBody'::varchar, 9::integer, 'waterbody'::varchar)
	) AS t(class_name, class_id, class_label)
LOOP

	FOR t IN 
		SELECT * FROM (VALUES
		('LoD0'::varchar, 'lod0'::varchar)
		) AS t(lodx_name, lodx_label)
	LOOP

l_name         := format(      '%I_%I',							   r.class_label, t.lodx_label);
view_name      := format(   '%I_%I_%I',				citydb_schema, r.class_label, t.lodx_label);
mview_name     := format('_g_%I_%I_%I',				citydb_schema, r.class_label, t.lodx_label);
mview_idx_name := format('_g_%I_%I_%I_id_idx',		citydb_schema, r.class_label, t.lodx_label);
mview_spx_name := format('_g_%I_%I_%I_geom_spx',	citydb_schema, r.class_label, t.lodx_label);
qml_file_name  := concat(r.class_label,'_form.qml');

sql_statement := concat('
DROP MATERIALIZED VIEW IF EXISTS qgis_pkg.',mview_name,' CASCADE;
CREATE MATERIALIZED VIEW         qgis_pkg.',mview_name,' AS
	SELECT
		sg.cityobject_id::bigint AS co_id,
		ST_Collect(qgis_pkg.ST_snap_poly_to_grid(sg.geometry,',perform_snapping,',',digits,',',area_poly_min,'))::geometry(MultiPolygonZ, ',srid_id,') AS geom
	FROM 
		',citydb_schema,'.waterbody AS o
		INNER JOIN ',citydb_schema,'.cityobject AS co ON (o.id = co.id AND o.objectclass_id = ',r.class_id,' ',sql_where,')
		INNER JOIN ',citydb_schema,'.surface_geometry AS sg ON (sg.root_id = o.',t.lodx_label,'_multi_surface_id AND sg.geometry IS NOT NULL)
	GROUP BY sg.cityobject_id
WITH NO DATA;
COMMENT ON MATERIALIZED VIEW qgis_pkg.',mview_name,' IS ''Mat. view of ',r.class_name,' ',t.lodx_name,' in schema ',citydb_schema,''';
CREATE INDEX ',mview_idx_name,' ON qgis_pkg.',mview_name,' (co_id);
CREATE INDEX ',mview_spx_name,' ON qgis_pkg.',mview_name,' USING gist (geom);
DELETE FROM qgis_pkg.layer_metadata WHERE v_name = ''',view_name,''';
INSERT INTO qgis_pkg.layer_metadata (schema_name, feature_type, qml_file, lod, root_class, layer_name, creation_date, mv_name, v_name) VALUES
(''',citydb_schema,''',''',feature_type,''',''',qml_file_name,''',''',t.lodx_label,''',''',r.class_name,''',''',l_name,''',clock_timestamp(),''',mview_name,''',''',view_name,''');
');
EXECUTE sql_statement;

	END LOOP; -- waterbody lod2-4

	FOR t IN 
		SELECT * FROM (VALUES
		('LoD1'::varchar, 'lod1'::varchar)
		) AS t(lodx_name, lodx_label)
	LOOP

l_name         := format(      '%I_%I',							   r.class_label, t.lodx_label);
view_name      := format(   '%I_%I_%I',				citydb_schema, r.class_label, t.lodx_label);
mview_name     := format('_g_%I_%I_%I',				citydb_schema, r.class_label, t.lodx_label);
mview_idx_name := format('_g_%I_%I_%I_id_idx',		citydb_schema, r.class_label, t.lodx_label);
mview_spx_name := format('_g_%I_%I_%I_geom_spx',	citydb_schema, r.class_label, t.lodx_label);
qml_file_name  := concat(r.class_label,'_form.qml');

IF mview_bbox IS NOT NULL THEN
	sql_where := concat('AND ST_MakeEnvelope(',mview_bbox_xmin,', ',mview_bbox_ymin,', ',mview_bbox_xmax,', ',mview_bbox_ymax,', ',srid_id,') && co.envelope');
ELSE
	sql_where := NULL;
END IF;

sql_statement := concat('
DROP MATERIALIZED VIEW IF EXISTS qgis_pkg.',mview_name,' CASCADE;
CREATE MATERIALIZED VIEW         qgis_pkg.',mview_name,' AS
	SELECT
		sg.cityobject_id::bigint AS co_id,
		ST_Collect(qgis_pkg.ST_snap_poly_to_grid(sg.geometry,',perform_snapping,',',digits,',',area_poly_min,'))::geometry(MultiPolygonZ, ',srid_id,') AS geom	
	FROM (
		SELECT
			o.id AS co_id, 	
			CASE
				WHEN o.',t.lodx_label,'_solid_id IS NOT NULL THEN o.',t.lodx_label,'_solid_id
				ELSE o.',t.lodx_label,'_multi_surface_id
			END	AS sg_id 
		FROM 
			',citydb_schema,'.waterbody AS o
			INNER JOIN ',citydb_schema,'.cityobject AS co ON (o.id=co.id AND o.objectclass_id = ',r.class_id,' ',sql_where,') 
		WHERE			
			NOT(o.',t.lodx_label,'_solid_id IS NULL AND o.',t.lodx_label,'_multi_surface_id IS NULL)
		) AS foo
		INNER JOIN ',citydb_schema,'.surface_geometry AS sg ON (sg.root_id = foo.sg_id AND sg.geometry IS NOT NULL)
	GROUP BY sg.cityobject_id
WITH NO DATA;
COMMENT ON MATERIALIZED VIEW qgis_pkg.',mview_name,' IS ''Mat. view of ',r.class_name,' ',t.lodx_name,' in schema ',citydb_schema,''';
CREATE INDEX ',mview_idx_name,' ON qgis_pkg.',mview_name,' (co_id);
CREATE INDEX ',mview_spx_name,' ON qgis_pkg.',mview_name,' USING gist (geom);
DELETE FROM qgis_pkg.layer_metadata WHERE v_name = ''',view_name,''';
INSERT INTO qgis_pkg.layer_metadata (schema_name, feature_type, qml_file, lod, root_class, layer_name, creation_date, mv_name, v_name) VALUES
(''',citydb_schema,''',''',feature_type,''',''',qml_file_name,''',''',t.lodx_label,''',''',r.class_name,''',''',l_name,''',clock_timestamp(),''',mview_name,''',''',view_name,''');
');
EXECUTE sql_statement;

	END LOOP; -- waterbody lod1

	FOR t IN 
		SELECT * FROM (VALUES
		('LoD2'::varchar, 'lod2'::varchar),
		('LoD3'			, 'lod3'),	
		('LoD4'			, 'lod4')		
		) AS t(lodx_name, lodx_label)
	LOOP
	
l_name         := format(      '%I_%I',								r.class_label, t.lodx_label);
view_name      := format(   '%I_%I_%I',				citydb_schema, r.class_label, t.lodx_label);
mview_name     := format('_g_%I_%I_%I',				citydb_schema, r.class_label, t.lodx_label);
mview_idx_name := format('_g_%I_%I_%I_id_idx',		citydb_schema, r.class_label, t.lodx_label);
mview_spx_name := format('_g_%I_%I_%I_geom_spx',	citydb_schema, r.class_label, t.lodx_label);
qml_file_name  := concat(r.class_label,'_form.qml');

sql_statement := concat('
DROP MATERIALIZED VIEW IF EXISTS qgis_pkg.',mview_name,' CASCADE;
CREATE MATERIALIZED VIEW         qgis_pkg.',mview_name,' AS
	SELECT
		foo2.co_id::bigint AS co_id,
		ST_Collect(qgis_pkg.ST_snap_poly_to_grid(sg.geometry,',perform_snapping,',',digits,',',area_poly_min,'))::geometry(MultiPolygonZ, ',srid_id,') AS geom	
	FROM (
		SELECT
			foo.co_id,
			unnest(foo.sg_id_array) AS sg_id
		FROM (
			SELECT
				-- coalesce
				o.id AS co_id,
				CASE 
					WHEN ts_t.sg_id_array IS NOT NULL THEN ts_t.sg_id_array
					ELSE ARRAY[o.',t.lodx_label,'_solid_id]
				END AS sg_id_array 
			FROM 
				',citydb_schema,'.waterbody AS o
				INNER JOIN ',citydb_schema,'.cityobject AS co ON (o.id = co.id AND o.objectclass_id= ',r.class_id,' ',sql_where,')
				--FULL OUTER JOIN
				INNER JOIN (
					SELECT wtw.waterbody_id AS co_id, array_agg(ts.',t.lodx_label,'_surface_id) AS sg_id_array 
					FROM 
						',citydb_schema,'.waterboundary_surface AS ts
						INNER JOIN ',citydb_schema,'.cityobject AS co ON (co.id = ts.id ',sql_where,')
						INNER JOIN ',citydb_schema,'.waterbod_to_waterbnd_srf AS wtw ON (wtw.waterboundary_surface_id = ts.id)	
					GROUP BY wtw.waterbody_id
					) AS ts_t ON (ts_t.co_id = o.id)
			WHERE 
				sg_id_array IS NOT NULL
			) AS foo
		) AS foo2
		INNER JOIN ',citydb_schema,'.surface_geometry AS sg ON (sg.root_id = foo2.sg_id AND sg.geometry IS NOT NULL)
	GROUP BY foo2.co_id
WITH NO DATA;
COMMENT ON MATERIALIZED VIEW qgis_pkg.',mview_name,' IS ''Mat. view of ',r.class_name,' ',t.lodx_name,' in schema ',citydb_schema,''';
CREATE INDEX ',mview_idx_name,' ON qgis_pkg.',mview_name,' (co_id);
CREATE INDEX ',mview_spx_name,' ON qgis_pkg.',mview_name,' USING gist (geom);
DELETE FROM qgis_pkg.layer_metadata WHERE v_name = ''',view_name,''';
INSERT INTO qgis_pkg.layer_metadata (schema_name, feature_type, qml_file, lod, root_class, layer_name, creation_date, mv_name, v_name) VALUES
(''',citydb_schema,''',''',feature_type,''',''',qml_file_name,''',''',t.lodx_label,''',''',r.class_name,''',''',l_name,''',clock_timestamp(),''',mview_name,''',''',view_name,''');
');
EXECUTE sql_statement;

---------------------------------------------------------------
-- Create MATERIALIZED VIEW QGIS_PKG._G_*_WATERBODY_LOD0-4_THEMATIC_SURFACES
---------------------------------------------------------------
		FOR u IN 
			SELECT * FROM (VALUES
			('WaterSurface'::varchar,	11::integer,'watersurf'::varchar),
			('WaterGroundSurface',		12,			'watergroundsurf'),
			('WaterClosureSurface',		13,			'waterclosuresurf')
			) AS t(themsurf_name, class_id, themsurf_label)
		LOOP

l_name         := format(      '%I_%I_%I',						   r.class_label, t.lodx_label, u.themsurf_label);
view_name      := format(   '%I_%I_%I_%I',			citydb_schema, r.class_label, t.lodx_label, u.themsurf_label);
mview_name     := format('_g_%I_%I_%I_%I', 			citydb_schema, r.class_label, t.lodx_label, u.themsurf_label);
mview_idx_name := format('_g_%I_%I_%I_%I_id_idx',   citydb_schema, r.class_label, t.lodx_label, u.themsurf_label);
mview_spx_name := format('_g_%I_%I_%I_%I_geom_spx',	citydb_schema, r.class_label, t.lodx_label, u.themsurf_label);
IF u.themsurf_name = 'WaterSurface' THEN
	qml_file_name  := concat(r.class_label,'_water_surf_form.qml');
ELSE
	qml_file_name  := concat(r.class_label,'_water_bound_surf_form.qml');
END IF;

sql_statement := concat('
DROP MATERIALIZED VIEW IF EXISTS qgis_pkg.',mview_name,' CASCADE;
CREATE MATERIALIZED VIEW         qgis_pkg.',mview_name,' AS
	SELECT
		sg.cityobject_id::bigint AS co_id,
		ST_Collect(qgis_pkg.ST_snap_poly_to_grid(sg.geometry,',perform_snapping,',',digits,',',area_poly_min,'))::geometry(MultiPolygonZ, ',srid_id,') AS geom
	FROM
		',citydb_schema,'.waterboundary_surface AS o
		INNER JOIN ',citydb_schema,'.cityobject AS co ON (o.id = co.id AND o.objectclass_id = ',u.class_id,' ',sql_where,')		
		INNER JOIN ',citydb_schema,'.surface_geometry AS sg ON (sg.root_id = o.',t.lodx_name,'_surface_id AND sg.geometry IS NOT NULL)
	GROUP BY sg.cityobject_id
WITH NO DATA;
COMMENT ON MATERIALIZED VIEW qgis_pkg.',mview_name,' IS ''Mat. view of (',r.class_name,') ',t.lodx_name,' ',u.themsurf_name,' in schema ',citydb_schema,''';
CREATE INDEX ',mview_idx_name,' ON qgis_pkg.',mview_name,' (co_id);
CREATE INDEX ',mview_spx_name,' ON qgis_pkg.',mview_name,' USING gist (geom);
DELETE FROM qgis_pkg.layer_metadata WHERE v_name = ''',view_name,''';
INSERT INTO qgis_pkg.layer_metadata (schema_name, feature_type, qml_file, lod, root_class, layer_name, creation_date, mv_name, v_name) VALUES
(''',citydb_schema,''',''',feature_type,''',''',qml_file_name,''',''',t.lodx_label,''',''',r.class_name,''',''',l_name,''',clock_timestamp(),''',mview_name,''',''',view_name,''');
');
EXECUTE sql_statement;
		
		END LOOP; -- waterbody lod2-4 thematic surfaces
	END LOOP; -- waterbody lod2-4
END LOOP;  -- waterbody


-- Upsert table qgis_pkg.extents with m_view bbox
IF mview_bbox IS NULL THEN
	EXECUTE format('SELECT e.envelope FROM qgis_pkg.extents AS e WHERE schema_name = %L AND bbox_type = ''db_schema''', citydb_schema) INTO citydb_envelope;
	IF citydb_envelope IS NULL THEN
		citydb_envelope := (SELECT ST_MakeEnvelope(f.x_min, f.y_min, f.x_max, f.y_min, f.srid_id) FROM qgis_pkg.compute_schema_extents(citydb_schema) AS f);
	END IF;
	mview_bbox := citydb_envelope;
END IF;

RAISE NOTICE 'Upserting the mview bbox in table qgis_pkg.extents'; 
PERFORM qgis_pkg.upsert_extents(
	citydb_schema 		:= citydb_schema,
	citydb_bbox_type 	:= 'm_view',
	citydb_envelope 	:= mview_bbox
	);


-- **************************
RETURN 1;
EXCEPTION
	WHEN QUERY_CANCELED THEN
		RAISE EXCEPTION 'qgis_pkg.create_mviews(): Error QUERY_CANCELED';
	WHEN OTHERS THEN
		RAISE EXCEPTION 'qgis_pkg.create_mviews(): %', SQLERRM;
END;
$$ LANGUAGE plpgsql;
COMMENT ON FUNCTION qgis_pkg.create_mviews(varchar, integer, integer, numeric, geometry) IS 'Installs the materialized views for the selected citydb schema';

-- Installs the materlialised views for the citydb default schema.
--PERFORM qgis_pkg.create_mviews();
--PERFORM qgis_pkg.refresh_mview(citydb_schema := 'citydb');

-- **************************
RAISE NOTICE E'\n\nDone\n\n';
END $MAINBODY$
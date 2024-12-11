-- ***********************************************************************
--
-- This script installs a set of functions into qgis_pkg schema
-- List of functions:
--
-- qgis_pkg.check_address_feature()
-- qgis_pkg.check_relief_feature()
-- qgis_pkg.check_space_feature()
-- qgis_pkg.check_boundary_feature()
-- qgis_pkg.update_feature_geometry_metadata()
--
-- ***********************************************************************

----------------------------------------------------------------
-- Create FUNCTION QGIS_PKG.CHECK_ADDRESS_FEATURE
----------------------------------------------------------------
DROP FUNCTION IF EXISTS qgis_pkg.check_address_feature(varchar, varchar, integer, varchar) CASCADE;
CREATE OR REPLACE FUNCTION qgis_pkg.check_address_feature(
	usr_schema varchar,
	cdb_schema varchar,
	srid integer,
	cdb_bbox_type varchar DEFAULT 'db_schema'
) 
RETURNS void AS $$
DECLARE
	qi_usr_schema varchar 			:= quote_ident(usr_schema);
	qi_cdb_schema varchar 			:= quote_ident(cdb_schema);
	ql_cdb_schema varchar 			:= quote_literal(cdb_schema);
	cdb_bbox_type_array CONSTANT varchar[]	:= ARRAY['db_schema', 'm_view', 'qgis']; cdb_envelope geometry; srid integer;
	-- 'DoorSurface', 'WindowSurface' should be added in bdr_oc_names, the 3DCityDB v.0.7.1-beta mapping is lacking of their parent objectclasses which are Door and Window
	bdr_oc_names text [] 			:= ARRAY['ClosureSurface', 'AuxiliaryTrafficArea', 'TrafficArea','WallSurface', 'GroundSurface', 'InteriorWallSurface', 
								 			 'RoofSurface', 'FloorSurface', 'OuterFloorSurface', 'CeilingSurface', 'OuterCeilingSurface', 'WaterSurface', 'WaterGroundSurface', 'DoorSurface', 'WindowSurface'];
	bdr_oc_ids integer[]			:= NULL;
  	bdr_oc_name text 				:= NULL; 
	oc_ids integer[]				:= NULL; 
	oc_id integer					:= NULL;
	sql_address_scan text 			:= NULL;
	sql_address_feat text 			:= NULL;
	sql_parent_classname text		:= NULL;
	sql_where text					:= NULL;

BEGIN
-- Check if cdb_schema exists
IF qi_cdb_schema IS NULL or NOT EXISTS(SELECT 1 FROM information_schema.schemata AS i WHERE i.schema_name::varchar = qi_cdb_schema) THEN
	RAISE EXCEPTION 'cdb_schema (%) not found. It must be an existing schema', qi_cdb_schema;
END IF;

-- Check if feature geometry metadata table exists
IF NOT EXISTS(SELECT 1 FROM information_schema.tables WHERE table_schema = qi_usr_schema AND table_name = 'feature_geometry_metadata') THEN
	RAISE EXCEPTION '%.feature_geometry_metadata table not yet created. Please create it first', qi_usr_schema;
END IF;

-- Check that the cdb_box_type is a valid value
IF cdb_bbox_type IS NULL OR NOT (cdb_bbox_type = ANY (cdb_bbox_type_array)) THEN
	RAISE EXCEPTION 'cdb_bbox_type value is invalid. It must be one of (%)', cdb_bbox_type_array;
END IF;

-- Get the srid from the cdb_schema
EXECUTE format('SELECT srid FROM %I.database_srs LIMIT 1', cdb_schema) INTO srid;
-- Get the cdb_envelope from the extents table in the usr_schema
EXECUTE format ('SELECT envelope FROM %I.extents WHERE cdb_schema = %L AND bbox_type = %L', usr_schema, cdb_schema, cdb_bbox_type) INTO cdb_envelope;

-- Check whether the retrived extent exists 
IF cdb_envelope IS NULL THEN
	RAISE EXCEPTION 'cdb_envelope is invalid. Please first upsert the extent of cdb_bbox_type: %', cdb_bbox_type;
END IF;

-- Check that the srid is the same to the cdb_envelope
IF ST_SRID(cdb_envelope) IS NULL OR ST_SRID(cdb_envelope) <> srid OR cdb_bbox_type = 'db_schema' THEN
	sql_where := NULL;
ELSE
	sql_where := concat(' AND ST_MakeEnvelope(',ST_XMin(cdb_envelope),',',ST_YMin(cdb_envelope),',',ST_XMax(cdb_envelope),',',ST_YMax(cdb_envelope),',',srid,') && f.envelope ');
END IF;

-- Scan classes that have address
sql_address_scan := concat('
SELECT ARRAY(
	SELECT DISTINCT f.objectclass_id
	FROM ',qi_cdb_schema,'.feature AS f
		INNER JOIN ',qi_cdb_schema,'.property AS p ON f.id = p.feature_id
		INNER JOIN ',qi_cdb_schema,'.address AS a ON p.val_address_id = a.id)
');

-- Scan the oc_id that is stored as a boundary attribute to its parent oc_id
FOREACH bdr_oc_name IN ARRAY bdr_oc_names
LOOP
	bdr_oc_ids := ARRAY_APPEND(bdr_oc_ids, qgis_pkg.classname_to_objectclass_id(qi_cdb_schema, bdr_oc_name));
END LOOP;

EXECUTE sql_address_scan INTO oc_ids;
IF oc_ids IS NOT NULL THEN
	FOREACH oc_id IN ARRAY oc_ids
	LOOP
		-- Boundary feature
		IF oc_id = ANY(bdr_oc_ids) THEN
			sql_where := concat(' AND ST_MakeEnvelope(',ST_XMin(cdb_envelope),',',ST_YMin(cdb_envelope),',',ST_XMax(cdb_envelope),',',ST_YMax(cdb_envelope),',',srid,') && f1.envelope ');
			sql_address_feat := concat('
			INSERT INTO ',qi_usr_schema,'.feature_geometry_metadata (cdb_schema, bbox_type, parent_objectclass_id, parent_classname, objectclass_id, classname, datatype_id, geometry_name, lod, geometry_type, postgis_geom_type, last_modification_date)
			SELECT DISTINCT ON (cdb_schema, parent_objectclass_id, parent_classname, objectclass_id, classname, datatype_id, geometry_name, lod, geometry_type, postgis_geom_type)
				',ql_cdb_schema,'																			::varchar			AS cdb_schema,
				',quote_literal(cdb_bbox_type),'															::varchar			AS bbox_type,
				f.objectclass_id																			::integer   		AS parent_objectclass_id,
				',quote_literal(qgis_pkg.objectclass_id_to_classname(qi_cdb_schema, f.objectclass_id)),'	::varchar			AS parent_classname,
				f1.objectclass_id																			::integer 			AS objectclass_id,
				',quote_literal(qgis_pkg.objectclass_id_to_classname(qi_cdb_schema, oc_id)),'				::varchar			AS classname,
				p1.datatype_id																				::integer 			AS datatype_id,
				p1.name																						::text				AS geometry_name,
				0																							::text				AS lod,
				-- MultiPoint
				''MPt''																						::text 		       	AS geometry_type,
				''MultiPointZ''																				::text     			AS postgis_geom_type,
				clock_timestamp()																			::timestamptz(3)  	AS last_modification_date
			FROM ',qi_cdb_schema,'.feature AS f
				INNER JOIN ',qi_cdb_schema,'.property AS p ON (f.id = p.feature_id AND p.name = ''boundary''
				INNER JOIN ',qi_cdb_schema,'.feature AS f1 ON (f1.id = p.val_feature_id AND f1.objectclass_id = ',oc_id,'',sql_where,')
				INNER JOIN ',qi_cdb_schema,'.property AS p1 ON f1.id = p1.feature_id
				INNER JOIN ',qi_cdb_schema,'.address AS a ON p1.val_address_id = a.id
			WHERE p.name=''address''
			ON CONFLICT (cdb_schema, parent_objectclass_id, objectclass_id, datatype_id, geometry_name, lod, geometry_type, postgis_geom_type)
			DO UPDATE
			SET last_modification_date = clock_timestamp();
			');
		ELSE
			-- Space feature
			sql_address_feat := concat('
			INSERT INTO ',qi_usr_schema,'.feature_geometry_metadata (cdb_schema, bbox_type, parent_objectclass_id, parent_classname, objectclass_id, classname, datatype_id, geometry_name, lod, geometry_type, postgis_geom_type, last_modification_date)
			SELECT DISTINCT ON (cdb_schema, parent_objectclass_id, parent_classname, objectclass_id, classname, datatype_id, geometry_name, lod, geometry_type, postgis_geom_type)
				',ql_cdb_schema,'																	::varchar	    	AS cdb_schema,
				',quote_literal(cdb_bbox_type),'															::varchar			AS bbox_type,
				0 																					::integer 			AS parent_objectclass_id,
				''-''																				::varchar			AS parent_classname,
				f.objectclass_id																	::integer 	        AS objectclass_id,
				',quote_literal(qgis_pkg.objectclass_id_to_classname(qi_cdb_schema, oc_id)),'		::varchar			AS classname,
				p.datatype_id																		::integer		    AS datatype_id,
				p.name																				::text				AS geometry_name,
				0 																					::text		        AS lod,
				-- MultiPoint
				''MPt''																				::text 		       	AS geometry_type, 
				''MultiPointZ''																		::text              AS postgis_geom_type,
				clock_timestamp()																	::timestamptz(3)  	AS last_modification_date
			FROM ',qi_cdb_schema,'.feature AS f 
				INNER JOIN ',qi_cdb_schema,'.property AS p ON (f.id = p.feature_id AND f.objectclass_id = ',oc_id,'',sql_where,')
				INNER JOIN ',qi_cdb_schema,'.address  AS a ON p.val_address_id = a.id
			WHERE p.name=''address''
			ON CONFLICT (cdb_schema, parent_objectclass_id, objectclass_id, datatype_id, geometry_name, lod, geometry_type, postgis_geom_type)
			DO UPDATE
			SET last_modification_date = clock_timestamp();
			');
		END IF;
		EXECUTE sql_address_feat;
		RAISE NOTICE 'Address feature (belongs to oc_id = %) checked and updated in schema "%"', oc_id, qi_cdb_schema;
	END LOOP;
END IF;

-- Get the parent_classname
sql_parent_classname := concat('
UPDATE ',qi_usr_schema,'.feature_geometry_metadata AS fgm
SET parent_classname = qgis_pkg.objectclass_id_to_classname(',ql_cdb_schema,', subquery.parent_objectclass_id)
FROM (
    SELECT parent_objectclass_id
    FROM ',qi_usr_schema,'.feature_geometry_metadata AS fgm
    WHERE fgm.cdb_schema = ',ql_cdb_schema,' 
		AND fgm.geometry_name = ''address'' 
		AND fgm.parent_objectclass_id <> 0
) AS subquery
WHERE fgm.cdb_schema = ',ql_cdb_schema,'
	AND fgm.geomtry_name = ''address''
    AND fgm.parent_objectclass_id <> 0;
');

EXCEPTION
	WHEN QUERY_CANCELED THEN
		RAISE EXCEPTION 'qgis_pkg.check_address_feature(): Error QUERY_CANCELED';
	WHEN OTHERS THEN
		RAISE EXCEPTION 'qgis_pkg.check_address_feature(): %', SQLERRM;
END;
$$ LANGUAGE plpgsql;
COMMENT ON FUNCTION qgis_pkg.check_address_feature(varchar, varchar, integer, varchar) IS 'Check the existence of address feature within the given cdb_schema';
REVOKE EXECUTE ON FUNCTION qgis_pkg.check_address_feature(varchar, varchar, integer, varchar) FROM PUBLIC;
-- Example
-- SELECT * FROM qgis_pkg.check_address_feature('qgis_bstsai','citydb', 28992)


----------------------------------------------------------------
-- Create FUNCTION QGIS_PKG.CHECK_RELIEF_FEATURE
----------------------------------------------------------------
DROP FUNCTION IF EXISTS qgis_pkg.check_relief_feature(varchar, varchar, integer, integer, varchar) CASCADE;
CREATE OR REPLACE FUNCTION qgis_pkg.check_relief_feature(
	usr_schema varchar,
	cdb_schema varchar,
	objectclass_id integer,
	srid integer,
	cdb_bbox_type varchar DEFAULT 'db_schema'
) 
RETURNS void AS $$
DECLARE
	qi_usr_schema varchar 			:= quote_ident(usr_schema);
	qi_cdb_schema varchar 			:= quote_ident(cdb_schema);
	ql_cdb_schema varchar 		:= quote_literal(cdb_schema);
	cdb_bbox_type_array CONSTANT varchar[]	:= ARRAY['db_schema', 'm_view', 'qgis']; cdb_envelope geometry; srid integer;
	classname varchar				:= (SELECT qgis_pkg.objectclass_id_to_classname(qi_cdb_schema, objectclass_id));
	sql_relief_feat text 			:= NULL;
	sql_where text					:= NULL;

BEGIN
-- Check if cdb_schema exists
IF qi_cdb_schema IS NULL or NOT EXISTS(SELECT 1 FROM information_schema.schemata AS i WHERE i.schema_name::varchar = qi_cdb_schema) THEN
	RAISE EXCEPTION 'cdb_schema (%) not found. It must be an existing schema', qi_cdb_schema;
END IF;

-- Check if feature geometry metadata table exists
IF NOT EXISTS(SELECT 1 FROM information_schema.tables WHERE table_schema = qi_usr_schema AND table_name = 'feature_geometry_metadata') THEN
	RAISE EXCEPTION '%.feature_geometry_metadata table not yet created. Please create it first', qi_usr_schema;
END IF;

-- Check that the cdb_box_type is a valid value
IF cdb_bbox_type IS NULL OR NOT (cdb_bbox_type = ANY (cdb_bbox_type_array)) THEN
	RAISE EXCEPTION 'cdb_bbox_type value is invalid. It must be one of (%)', cdb_bbox_type_array;
END IF;

-- Get the srid from the cdb_schema
EXECUTE format('SELECT srid FROM %I.database_srs LIMIT 1', cdb_schema) INTO srid;
-- Get the cdb_envelope from the extents table in the usr_schema
EXECUTE format ('SELECT envelope FROM %I.extents WHERE cdb_schema = %L AND bbox_type = %L', usr_schema, cdb_schema, cdb_bbox_type) INTO cdb_envelope;

-- Check whether the retrived extent exists 
IF cdb_envelope IS NULL THEN
	RAISE EXCEPTION 'cdb_envelope is invalid. Please first upsert the extent of cdb_bbox_type: %', cdb_bbox_type;
END IF;

-- Check that the srid is the same to the cdb_envelope
IF ST_SRID(cdb_envelope) IS NULL OR ST_SRID(cdb_envelope) <> srid OR cdb_bbox_type = 'db_schema' THEN
	sql_where := NULL;
ELSE
	sql_where := concat(' AND ST_MakeEnvelope(',ST_XMin(cdb_envelope),',',ST_YMin(cdb_envelope),',',ST_XMax(cdb_envelope),',',ST_YMax(cdb_envelope),',',srid,') && f.envelope ');
END IF;

sql_relief_feat := concat('
INSERT INTO ',qi_usr_schema,'.feature_geometry_metadata (cdb_schema, bbox_type, parent_objectclass_id, parent_classname, objectclass_id, classname, datatype_id, geometry_name, lod, geometry_type, postgis_geom_type, last_modification_date)
SELECT DISTINCT ON (cdb_schema, parent_objectclass_id, parent_classname, objectclass_id, classname, datatype_id, geometry_name, lod, geometry_type, postgis_geom_type)
	',ql_cdb_schema,'					::varchar	    	AS cdb_schema,
	',quote_literal(cdb_bbox_type),'	::varchar 			AS bbox_type,
	0 									::integer 			AS parent_objectclass_id,
	''-''								::varchar			AS parent_classname,
	f.objectclass_id					::integer 	        AS objectclass_id,
	',quote_literal(classname),'		::varchar			AS classname,
	p.datatype_id						::integer		    AS datatype_id,
	p.name								::text				AS geometry_name,
	p.val_int							::text		        AS lod,
	''Envelope''						::text 		        AS geometry_type,
	''PolygonZ''						::text              AS postgis_geom_type,
	clock_timestamp()					::timestamptz(3)   	AS last_modification_date
FROM ',qi_cdb_schema,'.feature AS f
	INNER JOIN ',qi_cdb_schema,'.property AS p ON (f.id = p.feature_id AND f.objectclass_id = ',objectclass_id,')
WHERE p.name=''lod''
',sql_where,'
ON CONFLICT (cdb_schema, parent_objectclass_id, objectclass_id, datatype_id, geometry_name, lod, geometry_type, postgis_geom_type)
DO UPDATE
SET last_modification_date = clock_timestamp();
');

EXECUTE sql_relief_feat;
RAISE NOTICE 'Relief feature (oc_id = %) checked and updated in schema "%"', qgis_pkg.classname_to_objectclass_id(qi_cdb_schema, 'ReliefFeature'), qi_cdb_schema;

EXCEPTION
	WHEN QUERY_CANCELED THEN
		RAISE EXCEPTION 'qgis_pkg.check_relief_feature(): Error QUERY_CANCELED';
	WHEN OTHERS THEN
		RAISE EXCEPTION 'qgis_pkg.check_relief_feature(): %', SQLERRM;
END;
$$ LANGUAGE plpgsql;
COMMENT ON FUNCTION qgis_pkg.check_relief_feature(varchar, varchar, integer, integer, varchar) IS 'Check the existence of relief feature within the given cdb_schema';
REVOKE EXECUTE ON FUNCTION qgis_pkg.check_relief_feature(varchar, varchar, integer, integer, varchar) FROM PUBLIC;
-- Example
-- SELECT * FROM qgis_pkg.check_relief_feature('qgis_bstsai', 'citydb', 500, 28992);


----------------------------------------------------------------
-- Create FUNCTION QGIS_PKG.CHECK_SPACE_FEATURE
----------------------------------------------------------------
DROP FUNCTION IF EXISTS qgis_pkg.check_space_feature(varchar, varchar, integer, integer, varchar) CASCADE;
CREATE OR REPLACE FUNCTION qgis_pkg.check_space_feature(
	usr_schema varchar,
	cdb_schema varchar,
	objectclass_id integer,
	srid integer,
	cdb_bbox_type varchar DEFAULT 'db_schema'
) 
RETURNS void AS $$
DECLARE
	qi_usr_schema varchar 				:= quote_ident(usr_schema);
	qi_cdb_schema varchar 				:= quote_ident(cdb_schema);
	ql_cdb_schema varchar 			:= quote_literal(cdb_schema);
	cdb_bbox_type_array CONSTANT varchar[]	:= ARRAY['db_schema', 'm_view', 'qgis']; cdb_envelope geometry; srid integer;
	classname varchar					:= (SELECT qgis_pkg.objectclass_id_to_classname(qi_cdb_schema, objectclass_id));
	geom_datatype_id integer 			:= NULL;
	implicit_geom_datatype_id integer 	:= NULL;
	sql_space_feature text 				:= NULL;
	sql_where text 						:= NULL;

BEGIN
-- Check if cdb_schema exists
IF qi_cdb_schema IS NULL or NOT EXISTS(SELECT 1 FROM information_schema.schemata AS i WHERE i.schema_name::varchar = qi_cdb_schema) THEN
	RAISE EXCEPTION 'cdb_schema (%) not found. It must be an existing schema', qi_cdb_schema;
END IF;

-- Check if feature geometry metadata table exists
IF NOT EXISTS(SELECT 1 FROM information_schema.tables WHERE table_schema = qi_usr_schema AND table_name = 'feature_geometry_metadata') THEN
	RAISE EXCEPTION '%.feature_geometry_metadata table not yet created. Please create it first', qi_usr_schema;
END IF;

-- Check that the cdb_box_type is a valid value
IF cdb_bbox_type IS NULL OR NOT (cdb_bbox_type = ANY (cdb_bbox_type_array)) THEN
	RAISE EXCEPTION 'cdb_bbox_type value is invalid. It must be one of (%)', cdb_bbox_type_array;
END IF;

-- Get the srid from the cdb_schema
EXECUTE format('SELECT srid FROM %I.database_srs LIMIT 1', cdb_schema) INTO srid;
-- Get the cdb_envelope from the extents table in the usr_schema
EXECUTE format ('SELECT envelope FROM %I.extents WHERE cdb_schema = %L AND bbox_type = %L', usr_schema, cdb_schema, cdb_bbox_type) INTO cdb_envelope;

-- Check whether the retrived extent exists 
IF cdb_envelope IS NULL THEN
	RAISE EXCEPTION 'cdb_envelope is invalid. Please first upsert the extent of cdb_bbox_type: %', cdb_bbox_type;
END IF;

-- Check that the srid is the same to the cdb_envelope
IF ST_SRID(cdb_envelope) IS NULL OR ST_SRID(cdb_envelope) <> srid OR cdb_bbox_type = 'db_schema' THEN
	sql_where := NULL;
ELSE
	sql_where := concat(' AND ST_MakeEnvelope(',ST_XMin(cdb_envelope),',',ST_YMin(cdb_envelope),',',ST_XMax(cdb_envelope),',',ST_YMax(cdb_envelope),',',srid,') && f.envelope ');
END IF;
	
-- Get the datatype_id of GeometryProperty and ImplicitGeometryProperty
EXECUTE format('SELECT * FROM qgis_pkg.datatype_name_to_type_id(%L, %L)', qi_cdb_schema, 'GeometryProperty') INTO geom_datatype_id;
EXECUTE format('SELECT * FROM qgis_pkg.datatype_name_to_type_id(%L, %L)', qi_cdb_schema, 'ImplicitGeometryProperty') INTO implicit_geom_datatype_id;


sql_space_feature := concat('
INSERT INTO ',qi_usr_schema,'.feature_geometry_metadata (cdb_schema, bbox_type, parent_objectclass_id, parent_classname, objectclass_id, classname, datatype_id, geometry_name, lod, geometry_type, postgis_geom_type, last_modification_date)
SELECT DISTINCT ON (cdb_schema, parent_objectclass_id, parent_classname, objectclass_id, classname, datatype_id, geometry_name, lod, geometry_type, postgis_geom_type)
	',ql_cdb_schema,'				::varchar 			AS cdb_schema,
	',quote_literal(cdb_bbox_type),'	::varchar		AS bbox_type,
	0								::integer			AS parent_objectclass_id,
	''-''							::varchar			AS parent_classname, 
	f.objectclass_id				::integer 			AS objectclass_id,
	',quote_literal(classname),'	::varchar			AS classname,
	p.datatype_id					::integer 			AS datatype_id,
	p.name							::text				AS geometry_name,
	p.val_lod						::text 				AS lod,
	CASE
		-- relief component geometry
		WHEN p.name = ''tin'' 																				THEN ''tin''
		WHEN p.name = ''reliefPoints'' 																		THEN ''reliefPt''
		WHEN p.name = ''ridgeOrValleyLines''																THEN ''ridgeOrValleyL'' 
		WHEN p.name = ''breaklines'' 																		THEN ''breakL''
 		--WHEN p.name = ''gird'' 				THEN ''grid'' -- to be checked
 		--WHEN p.name = ''pointCloud'' 			THEN ''pointCloud'' -- to be checked, not yet supported by current 3DCityDB
		-- core geometry & lod concepts
		WHEN (SUBSTRING(p.name FROM POSITION(''lod%'' IN p.name) + 5)) = ''Solid'' 							THEN ''Solid''
		WHEN (SUBSTRING(p.name FROM POSITION(''lod%'' IN p.name) + 5)) = ''MultiSurface'' 					THEN ''MSurf''
		WHEN (SUBSTRING(p.name FROM POSITION(''lod%'' IN p.name) + 5)) = ''MultiCurve'' 					THEN ''MCurve''
		WHEN (SUBSTRING(p.name FROM POSITION(''lod%'' IN p.name) + 5)) = ''TerrainIntersectionCurve'' 		THEN ''TerrainInterCurve''
		WHEN (SUBSTRING(p.name FROM POSITION(''lod%'' IN p.name) + 5)) = ''Point'' 							THEN ''Pt''
		WHEN (SUBSTRING(p.name FROM POSITION(''lod%'' IN p.name) + 5)) = ''ImplicitRepresentation'' 		THEN ''Implicit''
    END								::text 				AS geometry_type,
							 
	CASE
		-- relief component geometry
		WHEN p.name = ''tin'' 																				THEN ''MultiPolygonZ''
		WHEN p.name = ''reliefPoints'' 																		THEN ''MultiPointZ''
		WHEN p.name = ''ridgeOrValleyLines''																THEN ''MultiLineStringZ'' 
		WHEN p.name = ''breaklines'' 																		THEN ''MultiLineStringZ''
 		--WHEN p.name = ''gird'' 				THEN '''' -- to be checked
 		--WHEN p.name = ''pointCloud'' 			THEN ''MultiPointZ'' -- to be checked, not yet supported by current 3DCityDB
		-- core geometry & lod concepts
		WHEN (SUBSTRING(p.name FROM POSITION(''lod%'' IN p.name) + 5)) = ''Solid'' 							THEN ''PolyhedralSurfaceZ''
		WHEN (SUBSTRING(p.name FROM POSITION(''lod%'' IN p.name) + 5)) = ''MultiSurface'' 					THEN ''MultiPolygonZ''
		WHEN (SUBSTRING(p.name FROM POSITION(''lod%'' IN p.name) + 5)) = ''MultiCurve'' 					THEN ''MultiLineStringZ''
		WHEN (SUBSTRING(p.name FROM POSITION(''lod%'' IN p.name) + 5)) = ''TerrainIntersectionCurve'' 		THEN ''MultiLineStringZ''
		WHEN (SUBSTRING(p.name FROM POSITION(''lod%'' IN p.name) + 5)) = ''Point'' 							THEN ''PointZ''
		WHEN (SUBSTRING(p.name FROM POSITION(''lod%'' IN p.name) + 5)) = ''ImplicitRepresentation'' 		THEN ''MultiPolygonZ''					 
	END								::text 				AS postgis_geom_type,
	clock_timestamp()				::timestamptz(3) 	AS last_modification_date
FROM 
	',qi_cdb_schema,'.feature AS f
	INNER JOIN ',qi_cdb_schema,'.property AS p ON f.id = p.feature_id AND f.objectclass_id = ',objectclass_id,'',sql_where,'
WHERE p.datatype_id IN (',geom_datatype_id,',',implicit_geom_datatype_id,') AND val_lod IS NOT NULL
ON CONFLICT (cdb_schema, parent_objectclass_id, objectclass_id, datatype_id, geometry_name, lod, geometry_type, postgis_geom_type)
DO UPDATE
SET last_modification_date = clock_timestamp();
');

EXECUTE sql_space_feature;
RAISE NOTICE 'Space feature % (oc_id = %) checked and updated in schema "%"', classname, objectclass_id, qi_cdb_schema;

EXCEPTION
	WHEN QUERY_CANCELED THEN
		RAISE EXCEPTION 'qgis_pkg.check_space_feature(): Error QUERY_CANCELED';
 	WHEN OTHERS THEN
		RAISE EXCEPTION 'qgis_pkg.check_space_feature(): %', SQLERRM;
END;
$$ LANGUAGE plpgsql;
COMMENT ON FUNCTION qgis_pkg.check_space_feature(varchar, varchar, integer, integer, varchar) IS 'Check the existence of space feature within the given cdb_schema';
REVOKE EXECUTE ON FUNCTION qgis_pkg.check_space_feature(varchar, varchar, integer, integer, varchar) FROM PUBLIC;
-- Example
-- SELECT * FROM qgis_pkg.check_space_feature('qgis_bstsai','citydb', 901, 28992);


----------------------------------------------------------------
-- Create FUNCTION QGIS_PKG.CHECK_BOUNDARY_FEATURE
----------------------------------------------------------------
DROP FUNCTION IF EXISTS qgis_pkg.check_boundary_feature(varchar, varchar, integer, integer, varchar) CASCADE;
CREATE OR REPLACE FUNCTION qgis_pkg.check_boundary_feature(
	usr_schema varchar,
	cdb_schema varchar,
	objectclass_id integer,
	srid integer,
	cdb_bbox_type varchar DEFAULT 'db_schema'
) 
RETURNS void AS $$
DECLARE
	qi_usr_schema varchar		 			:= quote_ident(usr_schema);
	qi_cdb_schema varchar 		 			:= quote_ident(cdb_schema);
	ql_cdb_schema varchar 	 				:= quote_literal(cdb_schema);
	classname	varchar			 			:= (SELECT qgis_pkg.objectclass_id_to_classname(qi_cdb_schema, objectclass_id));
	child_oc_id integer			 			:= objectclass_id;
	geom_datatype_id integer 	 			:= NULL;
	sql_boundary_feature text 	 			:= NULL;
	sql_parent_classname text				:= NULL;
	sql_where text 				 			:= NULL;
	cdb_bbox_type_array CONSTANT varchar[]	:= ARRAY['db_schema', 'm_view', 'qgis']; 
	cdb_envelope geometry					:= NULL; 
	srid integer							:= NULL;

BEGIN
-- Check if cdb_schema exists
IF qi_cdb_schema IS NULL or NOT EXISTS(SELECT 1 FROM information_schema.schemata AS i WHERE i.schema_name::varchar = qi_cdb_schema) THEN
	RAISE EXCEPTION 'cdb_schema (%) not found. It must be an existing schema', qi_cdb_schema;
END IF;

-- Check if feature geometry metadata table exists
IF NOT EXISTS(SELECT 1 FROM information_schema.tables WHERE table_schema = qi_usr_schema AND table_name = 'feature_geometry_metadata') THEN
	RAISE EXCEPTION '%.feature_geometry_metadata table not yet created. Please create it first', qi_usr_schema;
END IF;

-- Check that the cdb_box_type is a valid value
IF cdb_bbox_type IS NULL OR NOT (cdb_bbox_type = ANY (cdb_bbox_type_array)) THEN
	RAISE EXCEPTION 'cdb_bbox_type value is invalid. It must be one of (%)', cdb_bbox_type_array;
END IF;

-- Get the srid from the cdb_schema
EXECUTE format('SELECT srid FROM %I.database_srs LIMIT 1', cdb_schema) INTO srid;
-- Get the cdb_envelope from the extents table in the usr_schema
EXECUTE format ('SELECT envelope FROM %I.extents WHERE cdb_schema = %L AND bbox_type = %L', usr_schema, cdb_schema, cdb_bbox_type) INTO cdb_envelope;

-- Check whether the retrived extent exists 
IF cdb_envelope IS NULL THEN
	RAISE EXCEPTION 'cdb_envelope is invalid. Please first upsert the extent of cdb_bbox_type: %', cdb_bbox_type;
END IF;

-- Check that the srid is the same to the cdb_envelope
IF ST_SRID(cdb_envelope) IS NULL OR ST_SRID(cdb_envelope) <> srid OR cdb_bbox_type = 'db_schema' THEN
	sql_where := NULL;
ELSE
	sql_where := concat(' AND ST_MakeEnvelope(',ST_XMin(cdb_envelope),',',ST_YMin(cdb_envelope),',',ST_XMax(cdb_envelope),',',ST_YMax(cdb_envelope),',',srid,') && f1.envelope ');
END IF;

-- Get the datatype_id of GeometryProperty
EXECUTE format('SELECT * FROM qgis_pkg.datatype_name_to_type_id(%L, %L)', qi_cdb_schema, 'GeometryProperty') INTO geom_datatype_id;

sql_boundary_feature := concat('
INSERT INTO ',qi_usr_schema,'.feature_geometry_metadata (cdb_schema, bbox_type, parent_objectclass_id, parent_classname, objectclass_id, classname, datatype_id, geometry_name, lod, geometry_type, postgis_geom_type, last_modification_date)
SELECT DISTINCT ON (cdb_schema, parent_objectclass_id, objectclass_id, datatype_id, geometry_name, lod, geometry_type, postgis_geom_type)
	',ql_cdb_schema,'						::varchar			AS cdb_schema,
	',quote_literal(cdb_bbox_type),'		::varchar			AS bbox_type,
	f.objectclass_id						::integer    		AS parent_objectclass_id,
	''-''									::varchar			AS parent_classname,
	f1.objectclass_id						::integer 			AS objectclass_id,
	',quote_literal(classname),'			::varchar			AS classname,
	p1.datatype_id							::integer 			AS datatype_id,
	p1.name									::text 				AS geometry_name,
	p1.val_lod								::text				AS lod,
	CASE 
 		-- WHEN p1.name = ''pointCloud'' 		THEN ''pointCloud'' -- to be checked, not yet supported by current 3DCityDB
		WHEN (SUBSTRING(p1.name FROM POSITION(''lod%'' IN p.name) + 5)) = ''MultiSurface''			THEN ''MSurf''
		WHEN (SUBSTRING(p1.name FROM POSITION(''lod%'' IN p.name) + 5)) = ''MultiCurve'' 			THEN ''MCurve'' 
    END																							::text 				AS geometry_type,
	CASE
		-- core geometry & lod concepts
 		-- WHEN p1.name = ''pointCloud'' 		THEN ''MULTIPOINTZ'' -- to be checked, not yet supported by current 3DCityDB
		WHEN (SUBSTRING(p1.name FROM POSITION(''lod%'' IN p.name) + 5)) = ''MultiSurface''			THEN ''MultiPolygonZ''
		WHEN (SUBSTRING(p1.name FROM POSITION(''lod%'' IN p.name) + 5)) = ''MultiCurve'' 			THEN ''MultiLineStringZ'' 
	END 																						::text				AS postgis_geom_type,
 	clock_timestamp()																			::timestamptz(3) 	AS last_modification_date
FROM 
	',qi_cdb_schema,'.feature AS f
	INNER JOIN ',qi_cdb_schema,'.property AS p ON f.id = p.feature_id AND p.name = ''boundary''
	INNER JOIN ',qi_cdb_schema,'.feature AS f1 ON f1.id = p.val_feature_id AND f1.objectclass_id = ',objectclass_id,'',sql_where,'
	INNER JOIN ',qi_cdb_schema,'.property AS p1 ON f1.id = p1.feature_id AND p1.datatype_id = ',geom_datatype_id,' 
ON CONFLICT (cdb_schema, parent_objectclass_id, objectclass_id, datatype_id, geometry_name, lod, geometry_type, postgis_geom_type)
DO UPDATE
SET last_modification_date = clock_timestamp();
');

EXECUTE sql_boundary_feature;

-- Get the parent_classname
sql_parent_classname := concat('
UPDATE ',qi_usr_schema,'.feature_geometry_metadata AS fgm
SET parent_classname = qgis_pkg.objectclass_id_to_classname(',ql_cdb_schema,', fgm.parent_objectclass_id)
FROM (
    SELECT parent_objectclass_id
    FROM ',qi_usr_schema,'.feature_geometry_metadata
    WHERE cdb_schema = ',ql_cdb_schema,' AND objectclass_id = ',child_oc_id,'
) AS subquery
WHERE fgm.cdb_schema = ',ql_cdb_schema,'
    AND fgm.parent_objectclass_id = subquery.parent_objectclass_id
    AND fgm.objectclass_id = ',child_oc_id,';
');

EXECUTE sql_parent_classname;

RAISE NOTICE 'Boundary feature % (oc_od = %) checked and updated in schema "%"', classname, objectclass_id, qi_cdb_schema;

EXCEPTION
	WHEN QUERY_CANCELED THEN
		RAISE EXCEPTION 'qgis_pkg.check_boundary_feature(): Error QUERY_CANCELED';
  	WHEN OTHERS THEN
		RAISE EXCEPTION 'qgis_pkg.check_boundary_feature(): %', SQLERRM;
END;
$$ LANGUAGE plpgsql;
COMMENT ON FUNCTION qgis_pkg.check_boundary_feature(varchar, varchar, integer, integer, varchar) IS 'Check the existence of boundary features within the given cdb_schema';
REVOKE EXECUTE ON FUNCTION qgis_pkg.check_boundary_feature(varchar, varchar, integer, integer, varchar) FROM PUBLIC;
-- Example
-- SELECT * FROM qgis_pkg.check_boundary_feature('qgis_bstsai','citydb', 709, 28992);


----------------------------------------------------------------
-- Create FUNCTION QGIS_PKG.UPDATE_FEATURE_GEOMETRY_METADATA()
----------------------------------------------------------------
/*  The function check all the existing feature(objectclass_id) within the given
	schema and then update the feature_geometry_metadata table under the usr_schema */
DROP FUNCTION IF EXISTS qgis_pkg.update_feature_geometry_metadata(varchar, varchar, varchar);
CREATE OR REPLACE FUNCTION qgis_pkg.update_feature_geometry_metadata(
	usr_schema varchar,
	cdb_schema varchar,
	cdb_bbox_type varchar DEFAULT 'db_schema'
) 
RETURNS varchar AS $$
DECLARE
	qi_usr_schema varchar					:= quote_ident(usr_schema);
	qi_cdb_schema varchar 					:= quote_ident(cdb_schema);
	cdb_bbox_type_array CONSTANT varchar[]	:= ARRAY['db_schema', 'm_view', 'qgis']; cdb_envelope geometry; srid integer;
	sql_oc_ids text 						:= NULL;
	sql_where text 							:= NULL;
	sql_feat_count text						:= NULL;
	-- 'DoorSurface', 'WindowSurface' should be added in bdr_oc_names, the 3DCityDB v.0.7.1-beta mapping is lacking of their parent objectclasses which are Door and Window
	bdr_oc_names text [] 					:= ARRAY['ClosureSurface', 'AuxiliaryTrafficArea', 'TrafficArea','WallSurface', 'GroundSurface', 'InteriorWallSurface', 
								 					 'RoofSurface', 'FloorSurface', 'OuterFloorSurface', 'CeilingSurface', 'OuterCeilingSurface', 'WaterSurface', 'WaterGroundSurface'];
  	address_exists boolean					:= NULL;
	bdr_oc_name text 						:= NULL; 
	bdr_oc_ids integer[] 					:= NULL;
	oc_ids integer[]						:= NULL; 
	oc_id integer 							:= NULL;
	
BEGIN
-- Check if cdb_schema exists
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
EXECUTE format ('SELECT envelope FROM %I.extents WHERE cdb_schema = %L AND bbox_type = %L', usr_schema, cdb_schema, cdb_bbox_type) INTO cdb_envelope;


-- Check whether the retrived extent exists 
IF cdb_envelope IS NULL THEN
	RAISE EXCEPTION 'cdb_envelope is invalid. Please first upsert the extent of cdb_bbox_type: %', cdb_bbox_type;
END IF;

-- Check that the srid is the same to the cdb_envelope
IF ST_SRID(cdb_envelope) IS NULL OR ST_SRID(cdb_envelope) <> srid OR cdb_bbox_type = 'db_schema' THEN
	sql_where := NULL;
ELSE
	sql_where := concat(' AND ST_MakeEnvelope(',ST_XMin(cdb_envelope),',',ST_YMin(cdb_envelope),',',ST_XMax(cdb_envelope),',',ST_YMax(cdb_envelope),',',srid,') && f.envelope ');
END IF;

-- Delete all existing records of the specified cdb_schema
EXECUTE format ('DELETE FROM %I.feature_geometry_metadata WHERE cdb_schema = %L', qi_usr_schema, cdb_schema);
	
-- Schema-wise scan of exisiting objectclass_ids in the given extent and return as an array
-- Exclude 'Versioning', 'Dynamizer', 'CityObjectGroup', 'Appearance' modules
sql_oc_ids := concat('
SELECT ARRAY(
	SELECT 
		DISTINCT objectclass_id
		FROM ',qi_cdb_schema,'.feature AS f
			INNER JOIN ',qi_cdb_schema,'.objectclass AS o ON f.objectclass_id = o.id
			INNER JOIN ',qi_cdb_schema,'.namespace AS n ON o.namespace_id = n.id
		WHERE n.alias NOT IN (''dyn'', ''app'', ''grp'', ''vers'')', sql_where,') AS oc_ids;
');
EXECUTE sql_oc_ids INTO oc_ids;

-- Scan the oc_id that is stored as a boundary attribute to its parent oc_id
FOREACH bdr_oc_name IN ARRAY bdr_oc_names
LOOP
	bdr_oc_ids := ARRAY_APPEND(bdr_oc_ids, qgis_pkg.classname_to_objectclass_id(qi_cdb_schema, bdr_oc_name));
END LOOP;

-- Iterate through each objectclass_id in the array
FOREACH oc_id IN ARRAY oc_ids
LOOP
	-- First check relief feature
	IF oc_id = qgis_pkg.classname_to_objectclass_id(qi_cdb_schema, 'ReliefFeature') THEN
		PERFORM qgis_pkg.check_relief_feature(usr_schema, cdb_schema, oc_id, srid, cdb_bbox_type);
	-- Second check all feature oc_ids that can be the boundary attributes to their parent features
	ELSIF oc_id = ANY(bdr_oc_ids) THEN
		PERFORM qgis_pkg.check_boundary_feature(usr_schema, cdb_schema, oc_id, srid, cdb_bbox_type);
	ELSE
		PERFORM qgis_pkg.check_space_feature(usr_schema, cdb_schema, oc_id, srid, cdb_bbox_type);
	END IF;
END LOOP;

-- Check address feature
EXECUTE format('SELECT EXISTS (SELECT 1 FROM %I.address)', qi_cdb_schema) INTO address_exists;

IF address_exists THEN
	PERFORM qgis_pkg.check_address_feature(usr_schema, cdb_schema, srid, cdb_bbox_type);
END IF;

RAISE NOTICE 'cdb_schema "%" scanned (extent: %) and updated to table "%.feature_geometry_metadata"', qi_cdb_schema, cdb_bbox_type, qi_usr_schema;

RETURN cdb_schema;

EXCEPTION
	WHEN QUERY_CANCELED THEN
		RAISE EXCEPTION 'qgis_pkg.update_feature_geometry_metadata: Error QUERY_CANCELED';
  	WHEN OTHERS THEN
		RAISE EXCEPTION 'qgis_pkg.update_feature_geometry_metadata: %', SQLERRM;
END;
$$ LANGUAGE plpgsql;
COMMENT ON FUNCTION qgis_pkg.update_feature_geometry_metadata(varchar, varchar, varchar) IS 'Scan exisitng features in the given schema and update the feature_geometry_metadata table under the usr_schema';
REVOKE EXECUTE ON FUNCTION qgis_pkg.update_feature_geometry_metadata(varchar, varchar, varchar) FROM PUBLIC;
-- Example
-- SELECT * FROM qgis_pkg.update_feature_geometry_metadata('qgis_bstsai', 'citydb');
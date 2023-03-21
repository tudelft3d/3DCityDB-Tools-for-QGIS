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
-- This script installs a function that generates the SQL script to
-- create some detail views, e.g. external references, or generic
-- attributes. 
--
-- ***********************************************************************

----------------------------------------------------------------
-- Create FUNCTION QGIS_PKG.GENERATE_SQL_DETAIL_VIEW
----------------------------------------------------------------
DROP FUNCTION IF EXISTS    qgis_pkg.generate_sql_detail_view(varchar, varchar, geometry) CASCADE;
CREATE OR REPLACE FUNCTION qgis_pkg.generate_sql_detail_view(
usr_name            varchar,
cdb_schema 			varchar,
mview_bbox			geometry -- A rectangular PostGIS polygon with SRID, e.g. ST_GeomFromText('Polygon((.... .....))', srid)
) 
RETURNS text AS $$
DECLARE
l_prefix			CONSTANT varchar := 'dv';
l_type varchar; ql_l_type varchar;
qgis_user_group_name CONSTANT varchar := (SELECT qgis_pkg.create_qgis_pkg_usrgroup_name());
usr_schema      	CONSTANT varchar := (SELECT qgis_pkg.create_qgis_usr_schema_name(usr_name));
usr_names_array     CONSTANT varchar[] := (SELECT array_agg(s.usr_name) FROM qgis_pkg.list_qgis_pkg_usrgroup_members() AS s);
usr_schemas_array 	CONSTANT varchar[] := (SELECT array_agg(s.usr_schema) FROM qgis_pkg.list_usr_schemas() AS s);
cdb_schemas_array 	CONSTANT varchar[] := (SELECT array_agg(s.cdb_schema) FROM qgis_pkg.list_cdb_schemas() AS s);  
srid                integer;
curr_class			varchar;
qi_cdb_schema varchar; ql_cdb_schema varchar;
qi_usr_schema varchar; ql_usr_schema varchar;
qi_usr_name varchar; ql_usr_name varchar;
l_name varchar; ql_l_name varchar; qi_l_name varchar;
av_name varchar; ql_av_name varchar; qi_av_name varchar;
qml_form_name 	varchar := NULL;
qml_symb_name 	varchar := NULL;
qml_3d_name 	varchar := NULL;
trig_f_suffix   varchar := NULL;
r RECORD; s RECORD; t RECORD; u RECORD;
sql_where 		text := NULL;
sql_ins			text := NULL;
sql_trig		text := NULL;
sql_view	 	text := NULL;
sql_join		text := NULL;
sql_statement	text := NULL;

BEGIN
-- Check if the usr_name exists AND is group of the "qgis_pkg_usrgroup";
-- The check to avoid if it is null has been already carried out by 
-- function qgis_pkg.create_qgis_usr_schema_name(usr_name) during DECLARE
IF NOT usr_name = ANY(usr_names_array) THEN
	RAISE EXCEPTION 'usr_name is invalid. It must be an existing database user AND member of role (group) "%"', qgis_user_group_name;
END IF;

-- Check if the usr_schema exists (must habe been created before)
-- No need to check if it is NULL.
IF NOT usr_schema = ANY(usr_schemas_array) THEN
	RAISE EXCEPTION 'usr_schema "%" does not exist. Please create it beforehand', usr_schema;
END IF;

-- Check if the cdb_schema exists
IF (cdb_schema IS NULL) OR (NOT cdb_schema = ANY(cdb_schemas_array)) THEN
	RAISE EXCEPTION 'cdb_schema "%" is invalid. It must correspond to an existing citydb schema', cdb_schema;
END IF;

-- Add quote identifier and literal for later user.
qi_cdb_schema := quote_ident(cdb_schema);
ql_cdb_schema := quote_literal(cdb_schema);
qi_usr_name   := quote_ident(usr_name);
ql_usr_name   := quote_literal(usr_name);
qi_usr_schema := quote_ident(usr_schema);
ql_usr_schema := quote_literal(usr_schema);

-- Prepare fixed part of SQL statements
sql_ins := concat('
DELETE FROM ',qi_usr_schema,'.layer_metadata AS l WHERE l.cdb_schema = ',ql_cdb_schema,' AND l.layer_type IN (''DetailView'', ''DetailViewNoGeom'');
INSERT INTO ',qi_usr_schema,'.layer_metadata 
(cdb_schema, layer_type, class, layer_name, av_name, creation_date, qml_form)
VALUES');

-- Get the srid from the cdb_schema
EXECUTE format('SELECT srid FROM %I.database_srs LIMIT 1', cdb_schema) INTO srid;

-- Check that the srid is the same if the mview_box
IF ST_SRID(mview_bbox) IS NULL OR ST_SRID(mview_bbox) <> srid THEN
	sql_where := NULL;
ELSE
	sql_where := concat('AND ST_MakeEnvelope(',ST_XMin(mview_bbox),',',ST_YMin(mview_bbox),',',ST_XMax(mview_bbox),',',ST_YMax(mview_bbox),',',srid,') && co.envelope');
END IF;

RAISE NOTICE 'For user "%": creating nested tables in usr_schema "%" for cdb_schema "%"', qi_usr_name, qi_usr_schema, qi_cdb_schema;


l_type := 'DetailViewNoGeom';
ql_l_type := quote_literal(l_type);
sql_view := NULL; sql_join := NULL; sql_trig := NULL;
---------------------------------------------------------------
-- Create GENERIC ATTRIBUTES (DETAIL) VIEWS AND TRIGGERS
---------------------------------------------------------------
IF sql_where IS NOT NULL THEN
	sql_join := concat('
	INNER JOIN ',qi_cdb_schema,'.cityobject AS co ON (co.id = t.cityobject_id ',sql_where,')');
END IF;

FOR r IN 
	SELECT * FROM (VALUES
	( 1::integer, 'string'::varchar, 'stringAttribute'::varchar, 'gen_attrib_string_form.qml'::varchar),
	( 2         , 'integer'        , 'intAttribute'            , 'gen_attrib_int_form.qml' ),
	( 3         , 'real'           , 'doubleAttribute'         , 'gen_attrib_real_form.qml' ),
	( 4         , 'uri'            , 'uriAttribute'            , 'gen_attrib_string_form.qml' ),
	( 5         , 'date'           , 'dateAttribute'           , 'gen_attrib_date_form.qml'   ),
	( 6         , 'measure'        , 'measureAttribute'        , 'gen_attrib_measure_form.qml')
--	( 7         , 'set'            , 'genericAttributeSet'     , 'gen_attrib_string_form.qml' ),
--	( 8         , 'blob'           , 'blobAttribute'           , 'gen_attrib_blob_form.qml'   )
--	( 9         , 'geom'           , 'geomAttribute'           , 'gen_attrib_string_form.qml' ),
--	(10         , 'surf_geom'      , 'surfGeomAttribute'       , 'gen_attrib_string_form.qml' )
	) AS t(data_type, data_type_name, class_name, qml_form_name)
LOOP

curr_class := r.class_name;

av_name := concat('gen_attrib_',r.data_type_name);
l_name := concat(l_prefix,'_',qi_cdb_schema,'_',av_name);
qi_av_name := quote_ident(av_name);
ql_av_name := quote_literal(av_name);
qi_l_name := quote_ident(l_name);
ql_l_name := quote_literal(l_name);

qml_form_name := r.qml_form_name;

sql_view := concat(sql_view,'
-----------------------------------------------------------------
-- VIEW ',upper(qi_usr_schema),'.',upper(qi_l_name),'
-----------------------------------------------------------------
DROP VIEW IF EXISTS ',qi_usr_schema,'.',qi_l_name,' CASCADE;
CREATE VIEW         ',qi_usr_schema,'.',qi_l_name,' AS
SELECT
  t.id::bigint,
--  t.parent_genattrib_id,
--  t.root_genattrib_id,
  t.attrname::varchar,',
CASE r.data_type
 WHEN 1::integer THEN '
  t.strval::varchar AS value,'
 WHEN 2::integer THEN '
  t.intval::integer AS value,'
 WHEN 3::integer THEN '
  t.realval::double precision AS value,'
 WHEN 4::integer THEN '
  t.urival::varchar AS value,'
 WHEN 5::integer THEN '
  t.dateval::timestamptz AS value,'
 WHEN 6::integer THEN '
  t.realval::double precision AS value,
  t.unit::varchar AS uom,'
 WHEN 7::integer THEN '
  t.genattribset_codespace::varchar AS value,'
 WHEN 8::integer THEN '
  t.blobval::bytea AS value,'
 WHEN 9::integer THEN '
  t.geomval::geometry AS value,'
 WHEN 10::integer THEN '
  t.surface_geometry_id::bigint,'
END,'
  t.cityobject_id
FROM
	 ',qi_cdb_schema,'.cityobject_genericattrib AS t',
CASE WHEN sql_where IS NOT NULL THEN
	sql_join
END,'
WHERE t.datatype=',r.data_type,';
COMMENT ON VIEW ',qi_usr_schema,'.',qi_l_name,' IS ''View of generic attributes (type ',r.data_type_name,') in schema ',qi_cdb_schema,''';
ALTER TABLE ',qi_usr_schema,'.',qi_l_name,' OWNER TO ',qi_usr_name,';
');

-- Add triggers to make view updatable
trig_f_suffix := 'dv_cityobject_genericattrib';
sql_trig := concat(sql_trig,qgis_pkg.generate_sql_triggers(usr_schema, l_name, trig_f_suffix));
-- Add entry to update table layer_metadata
--(cdb_schema, layer_type, class, layer_name, av_name, creation_date, qml_form)
sql_ins := concat(sql_ins,'
(',ql_cdb_schema,',',ql_l_type,',',quote_literal(curr_class),',',ql_l_name,',',ql_av_name,',clock_timestamp(),',quote_literal(qml_form_name),'),');

END LOOP; -- end loop GenericAttributes

sql_statement := concat(sql_statement, sql_view, sql_trig);

l_type := 'DetailViewNoGeom';
ql_l_type := quote_literal(l_type);
curr_class := 'ExternalReference';
sql_view := NULL; sql_join := NULL; sql_trig := NULL;
---------------------------------------------------------------
-- Create EXTERNAL REFERENCE (DETAIL) VIEWS AND TRIGGERS
---------------------------------------------------------------
IF sql_where IS NOT NULL THEN
	sql_join := concat('
	INNER JOIN ',qi_cdb_schema,'.cityobject AS co ON (co.id = t.cityobject_id ',sql_where,')');
END IF;

FOR r IN 
	SELECT * FROM (VALUES
	(1::integer, 'name'::varchar),	
	(2         , 'uri'          )
	) AS t(data_type, data_type_name)
LOOP

av_name := concat('ext_ref_', r.data_type_name);
l_name := concat(l_prefix,'_',qi_cdb_schema,'_',av_name);
qi_av_name := quote_ident(av_name);
ql_av_name := quote_literal(av_name);
qi_l_name := quote_ident(l_name);
ql_l_name := quote_literal(l_name);

qml_form_name := concat('ext_ref_form.qml');

sql_view := concat(sql_view,'
-----------------------------------------------------------------
-- VIEW ',upper(qi_usr_schema),'.',upper(qi_l_name),'
-----------------------------------------------------------------
DROP VIEW IF EXISTS ',qi_usr_schema,'.',qi_l_name,' CASCADE;
CREATE VIEW         ',qi_usr_schema,'.',qi_l_name,' AS
SELECT
  t.id::bigint,
  t.infosys,',
CASE r.data_type
 WHEN 1 THEN '
  t.name AS value,'
 WHEN 2 THEN '
  t.uri AS value,'
END,'
  t.cityobject_id
FROM 
	',qi_cdb_schema,'.external_reference AS t',
CASE WHEN sql_where IS NOT NULL THEN
	sql_join
END,'
WHERE',
CASE r.data_type
 WHEN 1 THEN '
  t.name IS NOT NULL;'
 WHEN 2 THEN '
  t.uri IS NOT NULL;'
END,'
COMMENT ON VIEW ',qi_usr_schema,'.',qi_l_name,' IS ''View of external reference (type ',r.data_type_name,') in schema ',qi_cdb_schema,''';
ALTER TABLE ',qi_usr_schema,'.',qi_l_name,' OWNER TO ',qi_usr_name,';
');

-- Add triggers to make view updatable
trig_f_suffix := 'dv_external_reference';
sql_trig := concat(sql_trig,qgis_pkg.generate_sql_triggers(usr_schema, l_name, trig_f_suffix));
-- Add entry to update table layer_metadata
--(cdb_schema, layer_type, class, layer_name, av_name, creation_date, qml_form)
sql_ins := concat(sql_ins,'
(',ql_cdb_schema,',',ql_l_type,',',quote_literal(curr_class),',',ql_l_name,',',ql_av_name,',clock_timestamp(),',quote_literal(qml_form_name),'),');

END LOOP;

sql_statement := concat(sql_statement, sql_view, sql_trig);

l_type := 'DetailView';
ql_l_type := quote_literal(l_type);
curr_class := 'Address';
sql_view := NULL; sql_join := NULL; sql_trig := NULL;
---------------------------------------------------------------
-- Create ADDRESS_BDG/BRI(PART) (DETAIL) VIEWS AND TRIGGERS
---------------------------------------------------------------
FOR r IN 
	SELECT * FROM (VALUES
	('Building(Part)'::varchar, 'building'::varchar, 'bdg'::varchar),
	('Bridge(Part)'::varchar  , 'bridge'           , 'bri'::varchar)
	) AS t(class_name, table_name, class_label)
LOOP

IF sql_where IS NOT NULL THEN
	sql_join := concat('
	INNER JOIN ',qi_cdb_schema,'.cityobject AS co ON (co.id = a2.',r.table_name,'_id ',sql_where,')');
END IF;

av_name := concat('address_',r.class_label);
l_name := concat(l_prefix,'_',qi_cdb_schema,'_',av_name);
qi_av_name := quote_ident(av_name);
ql_av_name := quote_literal(av_name);
qi_l_name := quote_ident(l_name);
ql_l_name := quote_literal(l_name);

qml_form_name := concat('address_form.qml');

sql_view := concat(sql_view,'
-----------------------------------------------------------------
-- VIEW ',upper(qi_usr_schema),'.',upper(qi_l_name),'
-----------------------------------------------------------------
DROP VIEW IF EXISTS ',qi_usr_schema,'.',qi_l_name,' CASCADE;
CREATE VIEW         ',qi_usr_schema,'.',qi_l_name,' AS
SELECT
  a.id::bigint,
  a.gmlid,
  a.gmlid_codespace,
  a.street,
  a.house_number,
  a.po_box,
  a.zip_code,
  a.city,
  a.state,
  a.country,
  a2.',r.table_name,'_id AS cityobject_id,
  a.multi_point AS geom
FROM 
	',qi_cdb_schema,'.address AS a
	INNER JOIN ',qi_cdb_schema,'.address_to_',r.table_name,' AS a2 ON (a2.address_id = a.id)',
CASE WHEN sql_where IS NOT NULL THEN
	sql_join
END,';
COMMENT ON VIEW ',qi_usr_schema,'.',qi_l_name,' IS ''View of address (for ',r.class_name,') in schema ',qi_cdb_schema,''';
ALTER TABLE ',qi_usr_schema,'.',qi_l_name,' OWNER TO ',qi_usr_name,';
');

-- Add triggers to make view updatable
trig_f_suffix := 'address';
sql_trig := concat(sql_trig,qgis_pkg.generate_sql_triggers(usr_schema, l_name, trig_f_suffix));
-- Add entry to update table layer_metadata
--(cdb_schema, layer_type, class, layer_name, av_name, creation_date, qml_form)
sql_ins := concat(sql_ins,'
(',ql_cdb_schema,',',ql_l_type,',',quote_literal(curr_class),',',ql_l_name,',',ql_av_name,',clock_timestamp(),',quote_literal(qml_form_name),'),');

END LOOP;

sql_statement := concat(sql_statement, sql_view, sql_trig);

l_type := 'DetailView';
ql_l_type := quote_literal(l_type);
curr_class := 'Address';
sql_view := NULL; sql_join := NULL; sql_trig := NULL;
---------------------------------------------------------------
-- Create ADDRESS_BDG/BRI(PART)_DOOR (DETAIL) VIEWS AND TRIGGERS
---------------------------------------------------------------
IF sql_where IS NOT NULL THEN
	sql_join := concat('
	INNER JOIN ',qi_cdb_schema,'.cityobject AS co ON (co.id = a2.id ',sql_where,')');
END IF;

FOR r IN 
	SELECT * FROM (VALUES
	('Building(Part) Door'::varchar, 'opening'::varchar, 'bdg_door'::varchar),
	('Bridge(Part) Door'::varchar  , 'bridge_opening'  , 'bri_door'::varchar)
	) AS t(class_name, table_name, class_label)
LOOP

av_name := concat('address_',r.class_label);
l_name := concat(l_prefix,'_',qi_cdb_schema,'_',av_name);
qi_av_name := quote_ident(av_name);
ql_av_name := quote_literal(av_name);
qi_l_name := quote_ident(l_name);
ql_l_name := quote_literal(l_name);

qml_form_name := concat('address_form.qml');

sql_view := concat(sql_view,'
-----------------------------------------------------------------
-- VIEW ',upper(qi_usr_schema),'.',upper(qi_l_name),'
-----------------------------------------------------------------
DROP VIEW IF EXISTS ',qi_usr_schema,'.',qi_l_name,' CASCADE;
CREATE VIEW         ',qi_usr_schema,'.',qi_l_name,' AS
SELECT
  a.id::bigint,
  a.gmlid,
  a.gmlid_codespace,
  a.street,
  a.house_number,
  a.po_box,
  a.zip_code,
  a.city,
  a.state,
  a.country,
  a2.id AS cityobject_id,
  a.multi_point AS geom
FROM 
	',qi_cdb_schema,'.address AS a
	INNER JOIN ',qi_cdb_schema,'.',r.table_name,' AS a2 ON (a2.address_id = a.id)',
CASE WHEN sql_where IS NOT NULL THEN
	sql_join
END,';
COMMENT ON VIEW ',qi_usr_schema,'.',qi_l_name,' IS ''View of address (for ',r.class_name,') in schema ',qi_cdb_schema,''';
ALTER TABLE ',qi_usr_schema,'.',qi_l_name,' OWNER TO ',qi_usr_name,';
');

-- Add triggers to make view updatable
trig_f_suffix := 'address';
sql_trig := concat(sql_trig,qgis_pkg.generate_sql_triggers(usr_schema, l_name, trig_f_suffix));
-- Add entry to update table layer_metadata
--(cdb_schema, layer_type, class, layer_name, av_name, creation_date, qml_form)
sql_ins := concat(sql_ins,'
(',ql_cdb_schema,',',ql_l_type,',',quote_literal(curr_class),',',ql_l_name,',',ql_av_name,',clock_timestamp(),',quote_literal(qml_form_name),'),');

END LOOP;

sql_statement := concat(sql_statement, sql_view, sql_trig);


-- substitute last comma with semi-colon
IF sql_ins IS NOT NULL THEN
	sql_ins := concat(substr(sql_ins,1, length(sql_ins)-1), ';');
END IF;
-- create the final sql statement
sql_statement := concat(sql_statement, sql_ins);

RETURN sql_statement;
EXCEPTION
	WHEN QUERY_CANCELED THEN
		RAISE EXCEPTION 'qgis_pkg.generate_sql_detail_view(): Error QUERY_CANCELED';
	WHEN OTHERS THEN
		RAISE EXCEPTION 'qgis_pkg.generate_sql_detail_view(): %', SQLERRM;
END;
$$ LANGUAGE plpgsql;
COMMENT ON FUNCTION qgis_pkg.generate_sql_detail_view(varchar, varchar, geometry) IS 'Generate SQL script to create detail views';
REVOKE EXECUTE ON FUNCTION qgis_pkg.generate_sql_detail_view(varchar, varchar, geometry) FROM public;

--**************************
DO $MAINBODY$
DECLARE
BEGIN
RAISE NOTICE E'\n\nDone\n\n';
END $MAINBODY$;
--**************************

--SELECT qgis_pkg.generate_sql_detail_view('giorgio', 'alderaan', NULL)
--SELECT qgis_pkg.generate_sql_detail_view('giorgio', 'alderaan', qgis_pkg.generate_mview_bbox_poly('alderaan', ARRAY[0, 0, 10, 10]))
-- ****************************************************************************
-- ****************************************************************************
--
--
-- CREATE SCHEMA and TABLES
--
--
-- ****************************************************************************
-- ****************************************************************************


-- WARNING: DUE to the big amount of objects to drop, if there are above (circa 500ish) mviews, the simple DROP command will fail.
-- For this reason, we must first reduce the number of layers, if present.
-- SELECT qgis_pkg.drop_layers(usr_schema:= 'qgis_pkg', cdb_schema:= 'citydb2');
-- COMMIT;
-- SELECT qgis_pkg.drop_layers(usr_schema:= 'qgis_pkg', cdb_schema:= 'citydb');
-- COMMIT;


-- Create schema;
DROP SCHEMA IF EXISTS qgis_pkg CASCADE;
CREATE SCHEMA         qgis_pkg;

-- Add extension (if not already installed);
CREATE EXTENSION IF NOT EXISTS "uuid-ossp" SCHEMA public;

-- Add table(s)
DO $MAINBODY$
DECLARE
srid_id integer := (SELECT srid FROM citydb.database_srs LIMIT 1);
sql_statement	varchar;
BEGIN


------------------------------------------------------------------
-- TABLE qgis_pkg.extents
------------------------------------------------------------------
sql_statement := concat('
DROP TABLE IF EXISTS qgis_pkg.extents  CASCADE;
CREATE TABLE         qgis_pkg.extents (
id				serial PRIMARY KEY,
usr_name		varchar,
usr_schema		varchar,
cdb_schema		varchar,
schema_name		varchar,
bbox_type		varchar CHECK (bbox_type IN (''db_schema'', ''m_view'', ''qgis'')),
label			varchar,
creation_date	timestamptz(3),
--qml_file		varchar,
envelope		geometry(Polygon,',srid_id,')
);
COMMENT ON TABLE qgis_pkg.extents IS ''Extents (as bounding box) of data and queries'';
ALTER TABLE qgis_pkg.extents ADD CONSTRAINT extents_schema_bbox_unique UNIQUE (schema_name, bbox_type);

CREATE INDEX ext_usr_name_idx	ON qgis_pkg.extents (usr_name);

INSERT INTO qgis_pkg.extents (schema_name, bbox_type, label) VALUES
(''citydb'',''db_schema'', ''citydb-full_extents''),
(''citydb'',''m_view'',    ''citydb-mview_bbox_extents''),
(''citydb'',''qgis'',      ''citydb-qgis_bbox_extents'');
');
EXECUTE sql_statement;

END $MAINBODY$;

------------------------------------------------------------------
-- TABLE qgis_pkg.layer_metadata
------------------------------------------------------------------
DROP TABLE IF EXISTS qgis_pkg.layer_metadata CASCADE;
CREATE TABLE         qgis_pkg.layer_metadata (
id				serial PRIMARY KEY,
usr_name		varchar,
usr_schema		varchar,
cdb_schema		varchar,
schema_name		varchar,  -- to be commented out
feature_type	varchar,
lod				varchar(4),
root_class		varchar,
layer_name		varchar,
n_features		integer,
mv_name			varchar UNIQUE,
v_name			varchar UNIQUE,
qml_file		varchar,
creation_date	timestamptz(3),
refresh_date	timestamptz(3)
);
COMMENT ON TABLE qgis_pkg.layer_metadata IS 'List of layers in schema qgis_pkg';

CREATE INDEX lmeta_usr_name_idx    ON qgis_pkg.layer_metadata (usr_name);
CREATE INDEX lmeta_usr_schema_idx  ON qgis_pkg.layer_metadata (usr_schema);
CREATE INDEX lmeta_cdb_schema_idx  ON qgis_pkg.layer_metadata (cdb_schema);
CREATE INDEX lmeta_schema_name_idx ON qgis_pkg.layer_metadata (schema_name); -- to be commented out
CREATE INDEX lmeta_lod_idx         ON qgis_pkg.layer_metadata (lod);
CREATE INDEX lmeta_l_name_idx      ON qgis_pkg.layer_metadata (layer_name);
CREATE INDEX lmeta_nf_idx          ON qgis_pkg.layer_metadata (n_features);
CREATE INDEX lmeta_rd_idx          ON qgis_pkg.layer_metadata (refresh_date);

--**************************
DO $$
BEGIN
RAISE NOTICE E'\n\nDone\n\n';
END $$;
--**************************


-- ****************************************************************************
-- ****************************************************************************
--
--
-- CREATE SCHEMA and other minor stuff
--
--
-- ****************************************************************************
-- ****************************************************************************

DROP SCHEMA IF EXISTS qgis_pkg CASCADE;
CREATE SCHEMA         qgis_pkg;

-- Add extension (if not already installed);
CREATE EXTENSION IF NOT EXISTS "uuid-ossp" SCHEMA public;

-- Add some constraints and indices to table cityobject_genericattrib;
ALTER TABLE citydb.cityobject_genericattrib ALTER COLUMN datatype SET NOT NULL;

DROP INDEX IF EXISTS citydb.genericattrib_attrname_inx;
CREATE INDEX         genericattrib_attrname_inx ON citydb.cityobject_genericattrib (attrname);
DROP INDEX IF EXISTS citydb.genericattrib_datatype_inx;
CREATE INDEX         genericattrib_datatype_inx ON citydb.cityobject_genericattrib (datatype);

--**************************
DO $$
BEGIN
RAISE NOTICE 'Done';
END $$;
--**************************


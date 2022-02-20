-- ****************************************************************************
-- ****************************************************************************
--
--
-- VIEW UPDATE FUNCTIONs
--
--
-- ****************************************************************************
-- ****************************************************************************

DO $MAINBODY$
DECLARE
BEGIN

----------------------------------------------------------------
-- Create FUNCTION QGIS_PKG.UPD_BUILDING_ATTS
----------------------------------------------------------------
DROP FUNCTION IF EXISTS    qgis_pkg.upd_building_atts(qgis_pkg.obj_cityobject, qgis_pkg.obj_building, varchar) CASCADE;
CREATE OR REPLACE FUNCTION qgis_pkg.upd_building_atts(
obj_co      qgis_pkg.obj_cityobject,
obj_b       qgis_pkg.obj_building,
schema_name varchar --DEFAULT 'citydb'::varchar 
)
RETURNS bigint AS $$
DECLARE
  updated_id bigint;
BEGIN

SELECT  qgis_pkg.upd_t_cityobject(obj_co, schema_name) INTO updated_id;
PERFORM qgis_pkg.upd_t_building(obj_b, schema_name);

RETURN updated_id;
EXCEPTION
  WHEN OTHERS THEN RAISE NOTICE 'qgis_pkg.upd_building_atts(id: %): %', obj_co.id, SQLERRM;
END;
$$ LANGUAGE plpgsql;
COMMENT ON FUNCTION qgis_pkg.upd_building_atts(qgis_pkg.obj_cityobject, qgis_pkg.obj_building, varchar) IS 'Update attributes of Building/BuildingPart';

----------------------------------------------------------------
-- Create FUNCTION QGIS_PKG.UPD_BUILDING_INSTALLATION_ATTS
----------------------------------------------------------------
DROP FUNCTION IF EXISTS    qgis_pkg.upd_building_installation_atts(qgis_pkg.obj_cityobject, qgis_pkg.obj_building_installation, varchar) CASCADE;
CREATE OR REPLACE FUNCTION qgis_pkg.upd_building_installation_atts(
obj_co      qgis_pkg.obj_cityobject,
obj_bi      qgis_pkg.obj_building_installation,
schema_name varchar
)
RETURNS bigint AS $$
DECLARE
  updated_id bigint;
BEGIN

SELECT  qgis_pkg.upd_t_cityobject(obj_co, schema_name) INTO updated_id;
PERFORM qgis_pkg.upd_t_building_installation(obj_bi, schema_name);

RETURN updated_id;
EXCEPTION
  WHEN OTHERS THEN RAISE NOTICE 'qgis_pkg.upd_building_installation_atts(id: %): %', obj_co.id, SQLERRM;
END;
$$ LANGUAGE plpgsql;
COMMENT ON FUNCTION qgis_pkg.upd_building_installation_atts(qgis_pkg.obj_cityobject, qgis_pkg.obj_building_installation, varchar) IS 'Update attributes of (Inner/Outer) BuildingInstallation';

----------------------------------------------------------------
-- Create FUNCTION QGIS_PKG.UPD_BDG_THEMATIC_SURFACE_ATTS
----------------------------------------------------------------
DROP FUNCTION IF EXISTS    qgis_pkg.upd_bdg_thematic_surface_atts(qgis_pkg.obj_cityobject, varchar) CASCADE;
CREATE OR REPLACE FUNCTION qgis_pkg.upd_bdg_thematic_surface_atts(
obj_co      qgis_pkg.obj_cityobject,
schema_name varchar
)
RETURNS bigint AS $$
DECLARE
  updated_id bigint;
BEGIN

SELECT qgis_pkg.upd_t_cityobject(obj_co, schema_name) INTO updated_id;

RETURN updated_id;
EXCEPTION
  WHEN OTHERS THEN RAISE NOTICE 'qgis_pkg.upd_bdg_thematic_surface_atts(id: %): %', obj_co.id, SQLERRM;
END;
$$ LANGUAGE plpgsql;
COMMENT ON FUNCTION qgis_pkg.upd_bdg_thematic_surface_atts(qgis_pkg.obj_cityobject, varchar) IS 'Update attributes of a (Building) ThematicSurface';

----------------------------------------------------------------
-- Create FUNCTION QGIS_PKG.UPD_SOLITARY_VEGETAT_OBJECT_ATTS
----------------------------------------------------------------
DROP FUNCTION IF EXISTS    qgis_pkg.upd_solitary_vegetat_object_atts(qgis_pkg.obj_cityobject, qgis_pkg.obj_solitary_vegetat_object, varchar) CASCADE;
CREATE OR REPLACE FUNCTION qgis_pkg.upd_solitary_vegetat_object_atts(
obj_co      qgis_pkg.obj_cityobject,
obj_svo     qgis_pkg.obj_solitary_vegetat_object,
schema_name varchar
)
RETURNS bigint AS $$
DECLARE
  updated_id bigint;
BEGIN

SELECT  qgis_pkg.upd_t_cityobject(obj_co, schema_name) INTO updated_id;
PERFORM qgis_pkg.upd_t_solitary_vegetat_object(obj_svo, schema_name);

RETURN updated_id;
EXCEPTION
  WHEN OTHERS THEN RAISE NOTICE 'qgis_pkg.upd_solitary_vegetat_object_atts(id: %): %', obj_co.id, SQLERRM;
END;
$$ LANGUAGE plpgsql;
COMMENT ON FUNCTION qgis_pkg.upd_solitary_vegetat_object_atts(qgis_pkg.obj_cityobject, qgis_pkg.obj_solitary_vegetat_object, varchar) IS 'Update attributes of a SolitaryVegetationObject';

----------------------------------------------------------------
-- Create FUNCTION QGIS_PKG.UPD_RELIEF_FEATURE_ATTS
----------------------------------------------------------------
DROP FUNCTION IF EXISTS    qgis_pkg.upd_relief_feature_atts(qgis_pkg.obj_cityobject, qgis_pkg.obj_relief_feature, varchar) CASCADE;
CREATE OR REPLACE FUNCTION qgis_pkg.upd_relief_feature_atts(
obj_co      qgis_pkg.obj_cityobject,
obj_rf      qgis_pkg.obj_relief_feature,
schema_name varchar
)
RETURNS bigint AS $$
DECLARE
  updated_id bigint;
BEGIN

SELECT  qgis_pkg.upd_t_cityobject(obj_co, schema_name) INTO updated_id;
PERFORM qgis_pkg.upd_t_relief_feature(obj_rf, schema_name);

RETURN updated_id;
EXCEPTION
  WHEN OTHERS THEN RAISE NOTICE 'qgis_pkg.upd_relief_feature_atts(id: %): %', obj_co.id, SQLERRM;
END;
$$ LANGUAGE plpgsql;
COMMENT ON FUNCTION qgis_pkg.upd_relief_feature_atts(qgis_pkg.obj_cityobject, qgis_pkg.obj_relief_feature, varchar) IS 'Update attributes of a ReliefFeature';

----------------------------------------------------------------
-- Create FUNCTION QGIS_PKG.UPD_TIN_RELIEF_ATTS
----------------------------------------------------------------
DROP FUNCTION IF EXISTS    qgis_pkg.upd_tin_relief_atts(qgis_pkg.obj_cityobject, qgis_pkg.obj_relief_component, qgis_pkg.obj_tin_relief, varchar) CASCADE;
CREATE OR REPLACE FUNCTION qgis_pkg.upd_tin_relief_atts(
obj_co      qgis_pkg.obj_cityobject,
obj_rc      qgis_pkg.obj_relief_component,
obj_tr      qgis_pkg.obj_tin_relief,
schema_name varchar
)
RETURNS bigint AS $$
DECLARE
  updated_id bigint;
BEGIN

SELECT  qgis_pkg.upd_t_cityobject(obj_co, schema_name) INTO updated_id;
PERFORM qgis_pkg.upd_t_relief_component(obj_rc, schema_name);
PERFORM qgis_pkg.upd_t_tin_relief(obj_tr, schema_name);

RETURN updated_id;
EXCEPTION
  WHEN OTHERS THEN RAISE NOTICE 'qgis_pkg.upd_tin_relief_atts(id: %): %', obj_co.id, SQLERRM;
END;
$$ LANGUAGE plpgsql;
COMMENT ON FUNCTION qgis_pkg.upd_tin_relief_atts(qgis_pkg.obj_cityobject, qgis_pkg.obj_relief_component, qgis_pkg.obj_tin_relief, varchar) IS 'Update attributes of a TINRelief';



--**************************
RAISE NOTICE E'\n\nDone\n\n';
END $MAINBODY$;
--**************************
-- ****************************************************************************
-- ****************************************************************************
--
--
-- CREATE OBJECTS (TYPES) corresponding each to a table of citydb
--
--
-- ****************************************************************************
-- ****************************************************************************

----------------------------------------------------------------
-- CREATE OBJECT (TYPE) corresponding to table citymodel
----------------------------------------------------------------
DROP TYPE IF EXISTS qgis_pkg.obj_citymodel CASCADE; 
CREATE TYPE         qgis_pkg.obj_citymodel AS (
 id                     bigint,
 gmlid                  varchar,
 gmlid_codespace        varchar,
 name                   varchar,
 name_codespace         varchar,
 description            varchar,
 envelope               geometry,
 creation_date          timestamptz,
 termination_date       timestamptz,
 last_modification_date timestamptz,
 updating_person        varchar,
 reason_for_update      varchar,
 lineage                varchar
);
COMMENT ON TYPE qgis_pkg.obj_citymodel IS 'This object (type) corresponds to table citymodel';

----------------------------------------------------------------
-- CREATE OBJECT (TYPE) corresponding to table address
----------------------------------------------------------------
DROP TYPE IF EXISTS qgis_pkg.obj_address CASCADE; 
CREATE TYPE         qgis_pkg.obj_address AS (
 id              bigint,
 gmlid           varchar,
 gmlid_codespace varchar,
 street          varchar,
 house_number    varchar,
 po_box          varchar,
 zip_code        varchar,
 city            varchar,
 state           varchar,
 country         varchar,
 multi_point     geometry,
 xal_source      text
);
COMMENT ON TYPE qgis_pkg.obj_address IS 'This object (type) corresponds to table address';

----------------------------------------------------------------
-- CREATE OBJECT (TYPE) corresponding to table appearance
----------------------------------------------------------------
DROP TYPE IF EXISTS qgis_pkg.obj_appearance CASCADE; 
CREATE TYPE         qgis_pkg.obj_appearance AS (
 id              bigint,
 gmlid           varchar,
 gmlid_codespace varchar,
 name            varchar,
 name_codespace  varchar,
 description     varchar,
 theme           varchar,
 citymodel_id    bigint,
 cityobject_id   bigint
);
COMMENT ON TYPE qgis_pkg.obj_appearance IS 'This object (type) corresponds to table appearance';

----------------------------------------------------------------
-- CREATE OBJECT (TYPE) corresponding to table surface_data
----------------------------------------------------------------
DROP TYPE IF EXISTS qgis_pkg.obj_surface_data CASCADE; 
CREATE TYPE         qgis_pkg.obj_surface_data AS (
 id                    bigint,
 gmlid                 varchar,
 gmlid_codespace       varchar,
 name                  varchar,
 name_codespace        varchar,
 description           varchar,
 is_front              numeric,
 objectclass_id        int4,
 x3d_shininess         float8,
 x3d_transparency      float8,
 x3d_ambient_intensity float8,
 x3d_specular_color    varchar,
 x3d_diffuse_color     varchar,
 x3d_emissive_color    varchar,
 x3d_is_smooth         numeric,
 tex_image_id          bigint,
 tex_texture_type      varchar,
 tex_wrap_mode         varchar,
 tex_border_color      varchar,
 gt_prefer_worldfile   numeric,
 gt_orientation        varchar,
 gt_reference_point    geometry
);
COMMENT ON TYPE qgis_pkg.obj_surface_data IS 'This object (type) corresponds to table surface_data';

----------------------------------------------------------------
-- CREATE OBJECT (TYPE) corresponding to table textureparam
----------------------------------------------------------------
DROP TYPE IF EXISTS qgis_pkg.obj_textureparam CASCADE; 
CREATE TYPE         qgis_pkg.obj_textureparam AS (
 surface_geometry_id        bigint,
 is_texture_parametrization numeric,
 world_to_texture           varchar,
 texture_coordinates        geometry,
 surface_data_id            bigint
);
COMMENT ON TYPE qgis_pkg.obj_textureparam IS 'This object (type) corresponds to table textureparam';

----------------------------------------------------------------
-- CREATE OBJECT (TYPE) corresponding to table external_reference
----------------------------------------------------------------
DROP TYPE IF EXISTS qgis_pkg.obj_external_reference CASCADE; 
CREATE TYPE         qgis_pkg.obj_external_reference AS (
 id            bigint,
 infosys       varchar,
 name          varchar,
 uri           varchar,
 cityobject_id bigint
);
COMMENT ON TYPE qgis_pkg.obj_external_reference IS 'This object (type) corresponds to table external_reference';


----------------------------------------------------------------
-- CREATE OBJECT (TYPE) corresponding to table cityobject_genericattrib
----------------------------------------------------------------
DROP TYPE IF EXISTS qgis_pkg.obj_cityobject_genericattrib CASCADE; 
CREATE TYPE         qgis_pkg.obj_cityobject_genericattrib AS (
 id                     bigint,
 parent_genattrib_id    bigint,
 root_genattrib_id      bigint,
 attrname               varchar,
 datatype               int4,
 strval                 varchar,
 intval                 int4,
 realval                float8,
 urival                 varchar,
 dateval                timestamptz,
 unit                   varchar,
 genattribset_codespace varchar,
 blobval                bytea,
 geomval                geometry,
 surface_geometry_id    bigint,
 cityobject_id          bigint
);
COMMENT ON TYPE qgis_pkg.obj_cityobject_genericattrib IS 'This object (type) corresponds to table cityobject_genericattrib';

----------------------------------------------------------------
-- CREATE OBJECT (TYPE) corresponding to table cityobject
----------------------------------------------------------------
DROP TYPE IF EXISTS qgis_pkg.obj_cityobject CASCADE; 
CREATE TYPE         qgis_pkg.obj_cityobject AS (
 id                     bigint,
 objectclass_id         int4,
 gmlid                  varchar,
 gmlid_codespace        varchar,
 name                   varchar,
 name_codespace         varchar,
 description            varchar,
 envelope               geometry,
 creation_date          timestamptz,
 termination_date       timestamptz,
 relative_to_terrain    varchar,
 relative_to_water      varchar,
 last_modification_date timestamptz,
 updating_person        varchar,
 reason_for_update      varchar,
 lineage                varchar,
 xml_source             text
);
COMMENT ON TYPE qgis_pkg.obj_cityobject IS 'This object (type) corresponds to table cityobject';

----------------------------------------------------------------
-- CREATE OBJECT (TYPE) corresponding to table cityobjectgroup
----------------------------------------------------------------
DROP TYPE IF EXISTS qgis_pkg.obj_cityobjectgroup CASCADE; 
CREATE TYPE         qgis_pkg.obj_cityobjectgroup AS (
 id                   bigint,
 objectclass_id       int4,  
 class                varchar,
 class_codespace      varchar,
 function             varchar,
 function_codespace   varchar,
 usage                varchar,
 usage_codespace      varchar,
 brep_id              bigint,
 other_geom           geometry,
 parent_cityobject_id bigint
);
COMMENT ON TYPE qgis_pkg.obj_cityobjectgroup IS 'This object (type) corresponds to table cityobjectgroup';

----------------------------------------------------------------
-- CREATE OBJECT (TYPE) corresponding to table building
----------------------------------------------------------------
DROP TYPE IF EXISTS qgis_pkg.obj_building CASCADE; 
CREATE TYPE         qgis_pkg.obj_building AS (
 id                          bigint,
 objectclass_id              int4, 
 building_parent_id          bigint,
 building_root_id            bigint,
 class                       varchar,
 class_codespace             varchar,
 function                    varchar,
 function_codespace          varchar,
 usage                       varchar,
 usage_codespace             varchar,
 year_of_construction        date,
 year_of_demolition          date,
 roof_type                   varchar,
 roof_type_codespace         varchar,
 measured_height             float8,
 measured_height_unit        varchar,
 storeys_above_ground        numeric,
 storeys_below_ground        numeric,
 storey_heights_above_ground varchar,
 storey_heights_ag_unit      varchar,
 storey_heights_below_ground varchar,
 storey_heights_bg_unit      varchar,
 lod1_terrain_intersection   geometry,
 lod2_terrain_intersection   geometry,
 lod3_terrain_intersection   geometry,
 lod4_terrain_intersection   geometry,
 lod2_multi_curve            geometry,
 lod3_multi_curve            geometry,
 lod4_multi_curve            geometry,
 lod0_footprint_id           bigint,
 lod0_roofprint_id           bigint,
 lod1_multi_surface_id       bigint,
 lod2_multi_surface_id       bigint,
 lod3_multi_surface_id       bigint,
 lod4_multi_surface_id       bigint,
 lod1_solid_id               bigint,
 lod2_solid_id               bigint,
 lod3_solid_id               bigint,
 lod4_solid_id               bigint
);
COMMENT ON TYPE qgis_pkg.obj_building IS 'This object (type) corresponds to table building';

----------------------------------------------------------------
-- CREATE OBJECT (TYPE) corresponding to table building_installation
----------------------------------------------------------------
DROP TYPE IF EXISTS qgis_pkg.obj_building_installation CASCADE; 
CREATE TYPE         qgis_pkg.obj_building_installation AS (
 id                           bigint,
 objectclass_id               int4,
 class                        varchar,
 class_codespace              varchar,
 function                     varchar,
 function_codespace           varchar,
 usage                        varchar,
 usage_codespace              varchar,
 building_id                  bigint,
 room_id                      bigint,
 lod2_brep_id                 bigint,
 lod3_brep_id                 bigint,
 lod4_brep_id                 bigint,
 lod2_other_geom              geometry,
 lod3_other_geom              geometry,
 lod4_other_geom              geometry,
 lod2_implicit_rep_id         bigint,
 lod3_implicit_rep_id         bigint,
 lod4_implicit_rep_id         bigint,
 lod2_implicit_ref_point      geometry,
 lod3_implicit_ref_point      geometry,
 lod4_implicit_ref_point      geometry,
 lod2_implicit_transformation varchar,
 lod3_implicit_transformation varchar,
 lod4_implicit_transformation varchar
);
COMMENT ON TYPE qgis_pkg.obj_building_installation IS 'This object (type) corresponds to table building_installation';

----------------------------------------------------------------
-- CREATE OBJECT (TYPE) corresponding to table thematic_surface
----------------------------------------------------------------
DROP TYPE IF EXISTS qgis_pkg.obj_thematic_surface CASCADE; 
CREATE TYPE         qgis_pkg.obj_thematic_surface AS (
 id                       bigint,
 objectclass_id           int4,
 building_id              bigint,
 room_id                  bigint,
 building_installation_id bigint,
 lod2_multi_surface_id    bigint,
 lod3_multi_surface_id    bigint,
 lod4_multi_surface_id    bigint
);
COMMENT ON TYPE qgis_pkg.obj_thematic_surface IS 'This object (type) corresponds to table thematic_surface';

----------------------------------------------------------------
-- CREATE OBJECT (TYPE) corresponding to table address_to_building
----------------------------------------------------------------
DROP TYPE IF EXISTS qgis_pkg.obj_address_to_building CASCADE; 
CREATE TYPE         qgis_pkg.obj_address_to_building AS (
 building_id bigint,
 address_id  bigint
);
COMMENT ON TYPE qgis_pkg.obj_address_to_building IS 'This object (type) corresponds to table address_to_building';

----------------------------------------------------------------
-- CREATE OBJECT (TYPE) corresponding to table appear_to_surface_data
----------------------------------------------------------------
DROP TYPE IF EXISTS qgis_pkg.obj_appear_to_surface_data CASCADE; 
CREATE TYPE         qgis_pkg.obj_appear_to_surface_data AS (
 surface_data_id bigint,
 appearance_id   bigint
);
COMMENT ON TYPE qgis_pkg.obj_appear_to_surface_data IS 'This object (type) corresponds to table appear_to_surface_data';

----------------------------------------------------------------
-- CREATE OBJECT (TYPE) corresponding to table cityobject_member
----------------------------------------------------------------
DROP TYPE IF EXISTS qgis_pkg.obj_cityobject_member CASCADE; 
CREATE TYPE         qgis_pkg.obj_cityobject_member AS (
 citymodel_id  bigint,
 cityobject_id bigint
);
COMMENT ON TYPE qgis_pkg.obj_cityobject_member IS 'This object (type) corresponds to table cityobject_member';

----------------------------------------------------------------
-- CREATE OBJECT (TYPE) corresponding to table group_to_cityobject
----------------------------------------------------------------
DROP TYPE IF EXISTS qgis_pkg.obj_group_to_cityobject CASCADE; 
CREATE TYPE         qgis_pkg.obj_group_to_cityobject AS (
 cityobject_id      bigint,
 cityobjectgroup_id bigint,
 role               varchar
);
COMMENT ON TYPE qgis_pkg.obj_group_to_cityobject IS 'This object (type) corresponds to table group_to_cityobject';


-- ***********************************************************************
-- ***********************************************************************


--**************************
DO $$
BEGIN
RAISE NOTICE 'Done';
END $$;
--**************************
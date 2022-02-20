-- ****************************************************************************
-- ****************************************************************************
--
--
-- CREATE OBJECTS (TYPES) corresponding each to a table of citydb
--
--
-- ****************************************************************************
-- ****************************************************************************

--**************************
DO $MAINBODY$
DECLARE

BEGIN

/*
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
COMMENT ON TYPE qgis_pkg.obj_citymodel IS 'This object (type) corresponds to table CITYMODEL';

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
COMMENT ON TYPE qgis_pkg.obj_address IS 'This object (type) corresponds to table ADDRESS';

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
COMMENT ON TYPE qgis_pkg.obj_appearance IS 'This object (type) corresponds to table APPEARANCE';

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
 objectclass_id        integer,
 x3d_shininess         double precision,
 x3d_transparency      double precision,
 x3d_ambient_intensity double precision,
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
COMMENT ON TYPE qgis_pkg.obj_surface_data IS 'This object (type) corresponds to table SURFACE_DATA';


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
COMMENT ON TYPE qgis_pkg.obj_textureparam IS 'This object (type) corresponds to table TEXTUREPARAM';

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
COMMENT ON TYPE qgis_pkg.obj_external_reference IS 'This object (type) corresponds to table EXTERNAL_REFERENCE';


----------------------------------------------------------------
-- CREATE OBJECT (TYPE) corresponding to table cityobject_genericattrib
----------------------------------------------------------------
DROP TYPE IF EXISTS qgis_pkg.obj_cityobject_genericattrib CASCADE; 
CREATE TYPE         qgis_pkg.obj_cityobject_genericattrib AS (
 id                     bigint,
 parent_genattrib_id    bigint,
 root_genattrib_id      bigint,
 attrname               varchar,
 datatype               integer,
 strval                 varchar,
 intval                 integer,
 realval                double precision,
 urival                 varchar,
 dateval                timestamptz,
 unit                   varchar,
 genattribset_codespace varchar,
 blobval                bytea,
 geomval                geometry,
 surface_geometry_id    bigint,
 cityobject_id          bigint
);
COMMENT ON TYPE qgis_pkg.obj_cityobject_genericattrib IS 'This object (type) corresponds to table CITYOBJECT_GENERICATTRIB';

*/

----------------------------------------------------------------
-- CREATE OBJECT (TYPE) corresponding to table cityobject
----------------------------------------------------------------
DROP TYPE IF EXISTS qgis_pkg.obj_cityobject CASCADE; 
CREATE TYPE         qgis_pkg.obj_cityobject AS (
 id                     bigint,
 objectclass_id         integer,
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
COMMENT ON TYPE qgis_pkg.obj_cityobject IS 'This object (type) corresponds to table CITYOBJECT';

/*
----------------------------------------------------------------
-- CREATE OBJECT (TYPE) corresponding to table cityobjectgroup
----------------------------------------------------------------
DROP TYPE IF EXISTS qgis_pkg.obj_cityobjectgroup CASCADE; 
CREATE TYPE         qgis_pkg.obj_cityobjectgroup AS (
 id                   bigint,
 objectclass_id       integer,  
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
COMMENT ON TYPE qgis_pkg.obj_cityobjectgroup IS 'This object (type) corresponds to table CITYOBJECTGROUP';
*/

----------------------------------------------------------------
-- CREATE OBJECT (TYPE) corresponding to table building
----------------------------------------------------------------
DROP TYPE IF EXISTS qgis_pkg.obj_building CASCADE; 
CREATE TYPE         qgis_pkg.obj_building AS (
 id                          bigint,
 objectclass_id              integer, 
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
 measured_height             double precision,
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
COMMENT ON TYPE qgis_pkg.obj_building IS 'This object (type) corresponds to table BUILDING';

----------------------------------------------------------------
-- CREATE OBJECT (TYPE) corresponding to table building_installation
----------------------------------------------------------------
DROP TYPE IF EXISTS qgis_pkg.obj_building_installation CASCADE; 
CREATE TYPE         qgis_pkg.obj_building_installation AS (
 id                           bigint,
 objectclass_id               integer,
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
COMMENT ON TYPE qgis_pkg.obj_building_installation IS 'This object (type) corresponds to table BUILDING_INSTALLATION';

----------------------------------------------------------------
-- CREATE OBJECT (TYPE) corresponding to table thematic_surface
----------------------------------------------------------------
DROP TYPE IF EXISTS qgis_pkg.obj_thematic_surface CASCADE; 
CREATE TYPE         qgis_pkg.obj_thematic_surface AS (
 id                       bigint,
 objectclass_id           integer,
 building_id              bigint,
 room_id                  bigint,
 building_installation_id bigint,
 lod2_multi_surface_id    bigint,
 lod3_multi_surface_id    bigint,
 lod4_multi_surface_id    bigint
);
COMMENT ON TYPE qgis_pkg.obj_thematic_surface IS 'This object (type) corresponds to table THEMATIC_SURFACE';











----------------------------------------------------------------
-- CREATE OBJECT (TYPE) corresponding to table solitary_vegetat_object
----------------------------------------------------------------
DROP TYPE IF EXISTS qgis_pkg.obj_solitary_vegetat_object CASCADE; 
CREATE TYPE         qgis_pkg.obj_solitary_vegetat_object AS (
 id                           bigint,
 class                        varchar,
 class_codespace              varchar,
 function                     varchar,
 function_codespace           varchar,
 usage                        varchar,
 usage_codespace              varchar,
 species                      varchar,
 species_codespace            varchar,
 height                       double precision,
 height_unit                  varchar,
 trunk_diameter               double precision,
 trunk_diameter_unit          varchar,
 crown_diameter               double precision,
 crown_diameter_unit          varchar,
 lod1_brep_id                 bigint,
 lod2_brep_id                 bigint,
 lod3_brep_id                 bigint,
 lod4_brep_id                 bigint,
 lod1_other_geom              geometry,
 lod2_other_geom              geometry,
 lod3_other_geom              geometry,
 lod4_other_geom              geometry,
 lod1_implicit_rep_id         bigint,
 lod2_implicit_rep_id         bigint,
 lod3_implicit_rep_id         bigint,
 lod4_implicit_rep_id         bigint,
 lod1_implicit_ref_point      geometry,
 lod2_implicit_ref_point      geometry,
 lod3_implicit_ref_point      geometry,
 lod4_implicit_ref_point      geometry,
 lod1_implicit_transformation varchar,
 lod2_implicit_transformation varchar,
 lod3_implicit_transformation varchar,
 lod4_implicit_transformation varchar
);
COMMENT ON TYPE qgis_pkg.obj_solitary_vegetat_object IS 'This object (type) corresponds to table SOLITARY_VEGETAT_OBJECT';


----------------------------------------------------------------
-- CREATE OBJECT (TYPE) corresponding to table plant_cover
----------------------------------------------------------------








----------------------------------------------------------------
-- CREATE OBJECT (TYPE) corresponding to table relief_feature
----------------------------------------------------------------
DROP TYPE IF EXISTS qgis_pkg.obj_relief_feature CASCADE; 
CREATE TYPE         qgis_pkg.obj_relief_feature AS (
 id  bigint,
 lod numeric
);
COMMENT ON TYPE qgis_pkg.obj_relief_feature IS 'This object (type) corresponds to table RELIEF_FEATURE';

----------------------------------------------------------------
-- CREATE OBJECT (TYPE) corresponding to table relief_component
----------------------------------------------------------------
DROP TYPE IF EXISTS qgis_pkg.obj_relief_component CASCADE; 
CREATE TYPE         qgis_pkg.obj_relief_component AS (
 id             bigint,
 objectclass_id integer,
 lod            numeric,
 extent         geometry
);
COMMENT ON TYPE qgis_pkg.obj_relief_component IS 'This object (type) corresponds to table RELIEF_COMPONENT';

----------------------------------------------------------------
-- CREATE OBJECT (TYPE) corresponding to table tin_relief
----------------------------------------------------------------
DROP TYPE IF EXISTS qgis_pkg.obj_tin_relief CASCADE; 
CREATE TYPE         qgis_pkg.obj_tin_relief AS (
 id                  bigint,
 max_length          double precision,
 max_length_unit     varchar,
 stop_lines          geometry,
 break_lines         geometry,
 control_points      geometry,
 surface_geometry_id bigint
);
COMMENT ON TYPE qgis_pkg.obj_tin_relief IS 'This object (type) corresponds to table TIN_RELIEF';


-- ***********************************************************************
-- ***********************************************************************


--**************************
RAISE NOTICE E'\n\nDone\n\n';
END $MAINBODY$;
--**************************
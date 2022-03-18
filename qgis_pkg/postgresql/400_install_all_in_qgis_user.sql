/*

INSTRUCTIONS:

As ADMINISTRATOR, you install as usual scripts 010 till 3xx.

The stuff in schema "qgis_pkg" is installed.

------

Then, as USER (at the moment still postgres, but it's
treated now as a simple user"), you only have to

1) run once the 

SELECT qgis_pkg.create_qgis_user_schema(usr_name := 'postgres');

This creates the "qgis_user" package.

2) Run the scripts to create the layers. Those that are not
ready are commented out in the next lines

3) Refresh the materialized views. Please note, the user-schema-aware
function is different (suffix: _new)

SELECT qgis_pkg.refresh_mview_new(
	usr_schema := 'qgis_user',
	cdb_schema := 'citydb'		-- cdb_schema for which to refresh the views.
);

I will drop the _new suffix when the 020 script is cleaned:
	- drop duplicate/redundant functions
	- adapt all functions to the new naming convention (usr_schema and cdb_schema)
*/

SELECT qgis_pkg.create_qgis_user_schema(usr_name := 'postgres');

/*
SELECT  qgis_pkg.create_layers_bridge(
cdb_schema 			varchar  DEFAULT 'citydb',
usr_name            varchar  DEFAULT 'postgres',
perform_snapping 	integer  DEFAULT 0,
digits 				integer	 DEFAULT 3,
area_poly_min 		numeric  DEFAULT 0.0001,
mview_bbox			geometry DEFAULT NULL,
force_layer_creation boolean DEFAULT FALSE  -- to be set to FALSE in normal usage
);
*/

/*
SELECT  qgis_pkg.create_layers_building(
cdb_schema 			varchar  DEFAULT 'citydb',
usr_name            varchar  DEFAULT 'postgres',
perform_snapping 	integer  DEFAULT 0,
digits 				integer	 DEFAULT 3,
area_poly_min 		numeric  DEFAULT 0.0001,
mview_bbox			geometry DEFAULT NULL,
force_layer_creation boolean DEFAULT FALSE  -- to be set to FALSE in normal usage
);
*/


SELECT qgis_pkg.create_layers_city_furniture(
cdb_schema 			 := 'citydb',
usr_name             := 'postgres',
perform_snapping 	 := 0,
digits 				 := 3,
area_poly_min 		 := 0.0001,
mview_bbox			 := NULL,
force_layer_creation := FALSE  -- TRUE to create all layers, even when empty
);

SELECT  qgis_pkg.create_layers_generics(
cdb_schema 			 := 'citydb',
usr_name             := 'postgres',
perform_snapping 	 := 0,
digits 				 := 3,
area_poly_min 		 := 0.0001,
mview_bbox			 := NULL,
force_layer_creation := FALSE  -- TRUE to create all layers, even when empty
);

SELECT  qgis_pkg.create_layers_land_use(
cdb_schema 			 := 'citydb',
usr_name             := 'postgres',
perform_snapping 	 := 0,
digits 				 := 3,
area_poly_min 		 := 0.0001,
mview_bbox			 := NULL,
force_layer_creation := FALSE  -- TRUE to create all layers, even when empty
);

SELECT  qgis_pkg.create_layers_relief(
cdb_schema 			 := 'citydb',
usr_name             := 'postgres',
perform_snapping 	 := 0,
digits 				 := 3,
area_poly_min 		 := 0.0001,
mview_bbox			 := NULL,
force_layer_creation := FALSE  -- TRUE to create all layers, even when empty
);

/*
SELECT  qgis_pkg.create_layers_transportation(
cdb_schema 			 := 'citydb',
usr_name             := 'postgres',
perform_snapping 	 := 0,
digits 				 := 3,
area_poly_min 		 := 0.0001,
mview_bbox			 := NULL,
force_layer_creation := FALSE  -- TRUE to create all layers, even when empty
);
*/

/*
SELECT  qgis_pkg.create_layers_tunnel(
cdb_schema 			 := 'citydb',
usr_name             := 'postgres',
perform_snapping 	 := 0,
digits 				 := 3,
area_poly_min 		 := 0.0001,
mview_bbox			 := NULL,
force_layer_creation := FALSE  -- TRUE to create all layers, even when empty
);
*/

SELECT  qgis_pkg.create_layers_vegetation(
cdb_schema 			 := 'citydb',
usr_name             := 'postgres',
perform_snapping 	 := 0,
digits 				 := 3,
area_poly_min 		 := 0.0001,
mview_bbox			 := NULL,
force_layer_creation := FALSE  -- TRUE to create all layers, even when empty
);

/*
SELECT  qgis_pkg.create_layers_waterbody(
cdb_schema 			 := 'citydb',
usr_name             := 'postgres',
perform_snapping 	 := 0,
digits 				 := 3,
area_poly_min 		 := 0.0001,
mview_bbox			 := NULL,
force_layer_creation := FALSE  -- TRUE to create all layers, even when empty
);
*/

SELECT qgis_pkg.refresh_mview(usr_schema := 'qgis_user', cdb_schema := 'citydb');

--**************************
DO $MAINBODY$
DECLARE
BEGIN
RAISE NOTICE E'\n\nDone\n\n';
END $MAINBODY$;
--**************************
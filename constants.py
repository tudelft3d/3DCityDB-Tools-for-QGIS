#Qgis Layer Fields

#Lookup-table names

#3DCityDB View names
#NOTE:TODO: read them from DB
view_names = ['citydb_building_lod0_roofedge','citydb_building_part_lod0_roofedge','citydb_building_lod1_multisurf','citydb_building_part_lod1_multisurf',
                'citydb_building_lod1_solid','citydb_building_part_lod1_solid','citydb_building_lod2_solid','citydb_building_lod2_multisurf',
                'citydb_building_part_lod2_multisurf','citydb_building_part_lod0_footprint','citydb_bdg_outerceilingsurface_lod2_multisurf','citydb_bdg_outerfloorsurface_lod2_multisurf',
                'citydb_solitary_vegetat_object_lod1_implicitrep','citydb_tin_relief_lod1_tin','citydb_tin_relief_lod2_tin','citydb_solitary_vegetat_object_lod2_implicitrep',
                'citydb_building_lod0_footprint','citydb_building_part_lod2_solid','citydb_bdg_outerinstallation_lod2_multisurf','citydb_bdg_groundsurface_lod2_multisurf',
                'citydb_bdg_wallsurface_lod2_multisurf','citydb_bdg_roofsurface_lod2_multisurf','citydb_bdg_closuresurface_lod2_multisurf','citydb_solitary_vegetat_object_lod3_implicitrep',
                'citydb_solitary_vegetat_object_lod2_multisurf','citydb_relief_feature_lod1_polygon','citydb_relief_feature_lod2_polygon']

features_view ={
"building":('citydb_building_lod0_roofedge','citydb_building_lod0_footprint',
            'citydb_building_lod1_multisurf','citydb_building_lod1_solid',
            'citydb_building_lod2_solid','citydb_building_lod2_multisurf'),
"solitary_vegetat_object":('citydb_solitary_vegetat_object_lod1_implicitrep','citydb_solitary_vegetat_object_lod2_implicitrep','citydb_solitary_vegetat_object_lod3_implicitrep','citydb_solitary_vegetat_object_lod2_multisurf'),
"tin_relief":('citydb_tin_relief_lod1_multisurf','citydb_tin_relief_lod2_multisurf','citydb_relief_feature_lod1_polygon','citydb_relief_feature_lod2_polygon')
}

subfeatures_view={
    "building":{"building_installation":('citydb_bdg_outerinstallation_lod2_multisurf'),
                "building_furniture":(),
                "building":('citydb_building_part_lod0_footprint','citydb_building_part_lod0_roofedge','citydb_building_part_lod1_multisurf',
                'citydb_building_part_lod1_solid','citydb_building_part_lod2_multisurf','citydb_building_part_lod2_solid'),
                "thematic_surface":('citydb_bdg_groundsurface_lod2_multisurf','citydb_bdg_wallsurface_lod2_multisurf','citydb_bdg_roofsurface_lod2_multisurf',
                'citydb_bdg_outerceilingsurface_lod2_multisurf','citydb_bdg_outerfloorsurface_lod2_multisurf','citydb_bdg_closuresurface_lod2_multisurf')}

} #NOTE: ONLY for building ATM

#Table names
#Thematic features: NOTE: some are missing on purpose 
features_tables=["cityobject","building","tin_relief","tunnel","bridge","waterbody","solitary_vegetat_object", "city_furniture", "land_use"]  #Named after their main corresponding table name from the 3DCityDB.
subfeatures_tables={'building':("building_installation","building_furniture","building","thematic_surface")} #NOTE: ONLY buildings ATM
features_tables_array='{"cityobject","building","tin_relief","tunnel","bridge","waterbody","solitary_vegetat_object", "city_furniture", "land_use"}' #TODO:19/01/2022 FIND A BETTER WAY TO GET THIS. I WANT TO USE IT AS AN ARRAY



#Thematic Feature names
features_names=["City Object","Building","DTM","Tunnel","Bridge","Water Bodies","Vegetation Objects", "City Furniture", "Land Use"] #Named after their main corresponding table name from the 3DCityDB.
subfeatures_names={'Buildings':("Building installations","Building furniture","Building Parts", "Thematic Surfaces")} #NOTE: ONLY buildings ATM
feature_tables_to_names = dict(zip(features_tables,features_names))

subfeature_tables_to_names={}
for feature in subfeatures_tables.keys():
    subfeature_tables_to_names[feature]= dict(zip(subfeatures_tables['building'],subfeatures_names['Buildings']))
#LOD names

#Geometry type names?

        
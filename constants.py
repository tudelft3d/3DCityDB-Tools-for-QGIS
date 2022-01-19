def table_to_name(table):
    if table=="building": return "Building"
    elif table=="cityobject":return "City Object"
    elif table=="tin_relief":return "DTM"
    elif table=="tunnel":return "Tunnel"
    elif table=="bridge":return "Bridge"
    elif table=="waterbody":return "Water Bodies"
    elif table=="solitary_vegetat_object":return "City Furniture"
    elif table=="city_furniture":return "City Object"
    elif table=="land_use":return "Land Use"
    elif table=="building_installation":return "Building installation"
    elif table=="building_installation":return "Building furniture"
    elif table=="building":return "Building Parts"
    elif table=="thematic_surface":return "Thematic Surfaces"

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
subfeatures_names={'Building':("Building installation","Building furniture","Building Parts", "Thematic Surfaces")} #NOTE: ONLY buildings ATM
feature_tables_to_names = dict(zip(features_tables,features_names))
feature_names_to_tables = dict(zip(features_names,features_tables))

subfeature_tables_to_names={}
subfeature_names_to_tables={}
for feature in subfeatures_tables.keys():
    subfeature_tables_to_names[feature]= dict(zip(subfeatures_tables['building'],subfeatures_names['Building']))
for feature in subfeatures_names.keys():
    subfeature_names_to_tables[feature]= dict(zip(subfeatures_names['Building'],subfeatures_tables['building']))
#LOD names

#Geometry type names?

        
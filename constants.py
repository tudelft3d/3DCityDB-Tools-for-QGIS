#Thematic features 3DCityDB tables
cityObject_table= "cityobject"
building_table= "building"
dtm_table= "relief_feature"
tunnel_table= "tunnel"
bridge_table= "bridge"
waterbody_table= "waterbody"
vegetation_table= "solitary_vegetat_object"
cityFurniture_table= "city_furniture"
landUse_table= "land_use"

#Subfeatures 3DCityDB tables
buildingOuterInstallation_table= "building_installation"
buildingFurniture_table= "building_furniture"
buildingPart_table= "building"
thematicSurfaces_table= "thematic_surface"
reliefTIN_table= "tin_relief"
reliefMassPoint_table= "masspoint_relief"
reliefRaster_table= "raster_relief"
reliefBreakLine_table= "breakline_relief"

#subfeatures names in views
buildingOuterInstallation_in_view= 'installation'
thematicSurfaces_in_view= 'themsurf'
buildingPart_in_view= 'part'
reliefTIN_in_view= 'tin'

buildingFurniture_in_view= "furni"
reliefMassPoint_in_view= "asdasd"
reliefRaster_in_view= "asdasd"
reliefBreakLine_in_view= "asdasd"


feature_tables=(cityObject_table,building_table,dtm_table,tunnel_table,bridge_table,waterbody_table,vegetation_table,cityFurniture_table,landUse_table)
subfeature_tables=(buildingOuterInstallation_table,buildingFurniture_table,buildingPart_table,thematicSurfaces_table,reliefTIN_table,reliefMassPoint_table,reliefRaster_table,reliefBreakLine_table)
subfeature_inView= (buildingOuterInstallation_in_view,buildingFurniture_in_view,buildingPart_in_view,thematicSurfaces_in_view,reliefTIN_in_view,reliefMassPoint_in_view,reliefRaster_in_view,reliefBreakLine_in_view)
subfeature_tables_to_inView = dict(zip(subfeature_tables,subfeature_inView))
subfeature_inView_to_tables = dict(zip(subfeature_inView,subfeature_tables))
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
def get_postgres_array(data):
    array=''
    for f in data:
        array+=f
        array+='|'

    array=list(array)
    array[-1]=")"
    array.insert(0,"(")
    array=''.join(array)
    return array


def get_schema_views(dbLoader,schema='qgis_pkg'):
    cur=dbLoader.conn.cursor()
    cur.execute(f"""SELECT table_name,'' 
                    FROM information_schema.views
                    WHERE table_schema ='{schema}';
                    """)
    views=cur.fetchall()
    cur.close()
    views,empty=zip(*views)
    return views



def get_feature_views(dbLoader,Feature,subFeatures,schema='qgis_pkg'):

    array=get_postgres_array(subFeatures)

    cur=dbLoader.conn.cursor()
    cur.execute(f"""SELECT table_name,'' 
                    FROM information_schema.views
                    WHERE table_schema ='{schema}'
                    AND table_name LIKE '%{Feature}%'
                    AND table_name NOT SIMILAR TO '%{array}%';
                    """)
    views=cur.fetchall()
    if views:
        views,empty=zip(*views)
    return views


def get_subfeature_views_single(dbLoader,subFeature,schema='qgis_pkg'):


    cur=dbLoader.conn.cursor()
    cur.execute(f"""SELECT table_name,'' 
                    FROM information_schema.views
                    WHERE table_schema ='{schema}'
                    AND table_name LIKE '%{subFeature}%';
                    """)
    views=cur.fetchall()
    if views:
        views,empty=zip(*views)
    return views

def get_features_subFeatures_views(dbLoader):
    
    subFeatures_views={}
    featureSubFeature_views={}
    for subFeature in subfeature_tables_to_inView:
        subFeatures_views[subFeature]= get_subfeature_views_single(dbLoader,subFeature=subfeature_tables_to_inView[subFeature])
    
    feature_views={}
    for feature in feature_tables:
        feature_views[feature]= get_feature_views(dbLoader,Feature= feature,subFeatures=subfeature_inView)


    for feature in feature_tables:
        featureSubFeature_views[feature]= feature_views[feature],
        for subFeature in subfeature_tables:
            
            featureName_isFoundIn_subFeatureName= any(item in feature.split('_') for item in subFeature.split('_'))
            thematic_and_feature_isFound= all(thematicSurfaces_in_view in view and feature in view for view in subFeatures_views[subFeature])
            views_exist= subFeatures_views[subFeature]

            if featureName_isFoundIn_subFeatureName or thematic_and_feature_isFound and views_exist:
                featureSubFeature_views[feature]= (*featureSubFeature_views[feature],{subFeature:subFeatures_views[subFeature]})
    
    return featureSubFeature_views

def create_constants(dbLoader):
    views_all = get_schema_views(dbLoader)
    views_features_subFeatures = get_features_subFeatures_views(dbLoader)


def print_view_hierarchy(views_features_subFeatures): #NOTE:TODO maybe show this thought the settings
    for feature in views_features_subFeatures.keys():
        print("Feature:\t",feature)
        for j in views_features_subFeatures[feature]:
            if type(j)==type(()):
                for view in j:
                    print("\t\tview:",view)
            elif type(j)==type({}):
                for sub in j.keys():
                    print("\t\tSubfeature:\t",sub)
                    for vieww in j[sub]:
                        print("\t\t\t\tview:",vieww)
        print("\n")



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

        
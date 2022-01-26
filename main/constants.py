class View():
    def __init__(self,schema,feature,subfeature,lod,g_type):
        self.schema = schema
        self.feature = feature
        self.subfeature = subfeature
        self.lod = lod
        self.type = g_type
        self.name = self.construct_name()

    
    def construct_name(self):
        if self.subfeature: return f'{self.schema}_{self.feature}_{self.subfeature}_{self.lod}_{self.type}'
        else: return f'{self.schema}_{self.feature}_{self.lod}_{self.type}'


class CityObject():
    def __init__(self):
        obj_container=[]

class Building(): #NOTE: ALL calsses have hardcoded values from the installed views. So every update them with changes to installation script (e.g. addeing new views or changing names)
    def __init__(self):
        self.table_name='building' #'building'
        self.view_name='building'
        self.alias='Building'
        self.class_id=26
        self.subFeatures_objects=[]
        self.subFeatures_table_name=['building_installation','building','building_furniture','thematic_surface']
        self.views=[View('citydb','building',None,'lod0','footprint'),View('citydb','building',None,'lod0','roofedge'),
                    View('citydb','building',None,'lod1','multisurf'),View('citydb','building',None,'lod1','solid'),
                    View('citydb','building',None,'lod2','multisurf'),View('citydb','building',None,'lod2','solid')]
        self.lods={ 'lod0':('footprint','roofedge'),
                    'lod1':('multisurf','solid'),
                    'lod2':('multisurf','solid')}
        self.count=0
        self.is_feature=True

    
    def get_view(self,schema,feature,subfeature,lod,g_type):
        views=[]
        for view in self.views:
            if view.schema==schema and view.feature==feature and view.subfeature == subfeature and view.lod==lod and view.type==g_type: #NOTE: x in y to handle thematic
                views.append(view)
        return views


    

class BuildingInstallation(Building):
    def __init__(self):
        self.table_name='building_installation'
        self.view_name='installation'
        self.alias='Building installation'
        self.views=[View('citydb','building','installation','lod2','multisurf')]
        self.lods={'lod2':('multisurf')}
        self.count=0
        self.is_feature=False
    def get_view(self,schema,feature,subfeature,lod,g_type):
        views=[]
        for view in self.views:
            if view.schema==schema and view.feature==feature and subfeature in view.subfeature and view.lod==lod and view.type==g_type: #NOTE: x in y to handle thematic
                views.append(view)
        return views
class BuildingPart(Building):
    def __init__(self):
        self.table_name='building'
        self.view_name='part'
        self.alias='Building Part'
        self.class_id=25
        self.views=[View('citydb','building','part','lod0','footprint'),View('citydb','building','part','lod0','roofedge'),
                    View('citydb','building','part','lod1','multisurf'),View('citydb','building','part','lod1','solid'),
                    View('citydb','building','part','lod2','multisurf'),View('citydb','building','part','lod2','solid')]
        self.lods={ 'lod0':('footprint','roofedge'),
                    'lod1':('multisurf','solid'),
                    'lod2':('multisurf','solid')}
        self.count=0
        self.is_feature=False
    
    def __str__(self):
        return 'Building Part'
    def get_view(self,schema,feature,subfeature,lod,g_type):
        views=[]
        for view in self.views:
            if view.schema==schema and view.feature==feature and subfeature in view.subfeature and view.lod==lod and view.type==g_type: #NOTE: x in y to handle thematic
                views.append(view)
        return views
class BuildingFurniture(Building):
    def __init__(self):
        self.table_name='building_furniture'
        self.view_name='furniture'
        self.alias='Building furniture'
        self.views=[]
        self.lods={}
        self.count=0
        self.is_feature=False
    def get_view(self,schema,feature,subfeature,lod,g_type):
        views=[]
        for view in self.views:
            if view.schema==schema and view.feature==feature and subfeature in view.subfeature and view.lod==lod and view.type==g_type: #NOTE: x in y to handle thematic
                views.append(view)
        return views
class BuildingThematic(Building):
    def __init__(self):
        self.table_name='thematic_surface'
        self.view_name='themsurf'
        self.alias='Thematic surfaces'
        self.views=[View('citydb','building','themsurf_groundsurface','lod2','multisurf'),View('citydb','building','themsurf_wallsurface','lod2','multisurf'),
                    View('citydb','building','themsurf_roofsurface','lod2','multisurf'),View('citydb','building','themsurf_outerceilingsurface','lod2','multisurf'),
                    View('citydb','building','themsurf_outerfloorsurface','lod2','multisurf'),View('citydb','building','themsurf_closuresurface','lod2','multisurf')]
        self.lods={'lod2':('multisurf')}
        self.count=0
        self.is_feature=False
    def get_view(self,schema,feature,subfeature,lod,g_type):
        views=[]
        for view in self.views:
            if view.schema==schema and view.feature==feature and subfeature in view.subfeature and view.lod==lod and view.type==g_type: #NOTE: x in y to handle thematic
                views.append(view)
        return views



class Relief(): 
    def __init__(self):
        self.table_name='relief_feature' #'building'
        self.view_name='relief_feature'
        self.alias='DTM'
        self.subFeatures_objects=[]
        self.subFeatures_table_name=['tin_relief']
        self.views=[View('citydb',self.view_name,None,'lod1','polygon'),
                    View('citydb',self.view_name,None,'lod2','polygon')]
        self.lods={ 'lod1':('polygon'),
                    'lod2':('polygon')}
        self.count=0
        self.is_feature=True
    def get_view(self,schema,feature,subfeature,lod,g_type):
        views=[]
        for view in self.views:
            if view.schema==schema and view.feature==feature and view.subfeature == subfeature and view.lod==lod and view.type==g_type: #NOTE: x in y to handle thematic
                views.append(view)
        return views
class TINRelief(Relief):
    def __init__(self):
        self.table_name='tin_relief'
        self.view_name='tin_relief'
        self.alias='TIN relief'
        self.views=[View('citydb','relief_feature',self.view_name,'lod1','tin'),
                    View('citydb','relief_feature',self.view_name,'lod2','tin')]
        self.lods={ 'lod1':('tin'),
                    'lod2':('tin')}
        self.count=0
        self.is_feature=False
    def get_view(self,schema,feature,subfeature,lod,g_type):
        views=[]
        for view in self.views:
            if view.schema==schema and view.feature==feature and subfeature in view.subfeature and view.lod==lod and view.type==g_type: #NOTE: x in y to handle thematic
                views.append(view)
        return views
class Vegetation():
    def __init__(self):
        self.table_name='solitary_vegetat_object'
        self.view_name='solitary_vegetat_object'
        self.alias='Vegetation'
        self.subFeatures_objects=[]
        self.views=[View('citydb',self.view_name,None,'lod1','implicitrep'),
                    View('citydb',self.view_name,None,'lod2','implicitrep'),View('citydb',self.view_name,None,'lod2','multisurf'),
                    View('citydb',self.view_name,None,'lod3','implicitrep')]
        self.lods={ 'lod1':('implicitrep'),
                    'lod2':('mutlisurf','implicitrep'),
                    'lod3':('implicitrep')}
        self.count=0
        self.is_feature=True
    def get_view(self,schema,feature,subfeature,lod,g_type):
        views=[]
        for view in self.views:
            if view.schema==schema and view.feature==feature and view.subfeature == subfeature and view.lod==lod and view.type==g_type: #NOTE: x in y to handle thematic
                views.append(view)
        return views


class subFeatures:

    def __init(self,table_name):
        
        self.table_name='' #'thematic_surface' NOTE: building's part table is 'building'
        self.view_name=subfeature_tables_to_names[self.table_name]
        self.min_lod=0 
        self.max_lod=4
    def get_view(self,schema,feature,subfeature,lod,g_type):
        for view in self.views:
            if view.schema==schema and view.feature==feature and view.subfeature==subfeature and view.lod==lod and view.type==g_type:
                return view


class ImportLayer:

    def __init__(self,schema,feature,subfeature,lod,type):
        
        #as 3DCityDB names
        self.schema=None #citydb
        self.feature=None #feature_relief
        self.subFeatures=[] #[tin_relief,raster_relief]
        self.lod=None #[lod2,lod3]
        self.type=None #mutlisurf

        self.min_lod=0
        self.extents
        self.to_import=False
        self.is_subFeature=False
        self.is_Feature=False
        
    def create_name(self):
        if self.is_subFeature:
            self.name= f"{self.schema}_{self.feature}_{self.subFeature}_{self.lod}_{self.type}"
        elif self.is_Feature and not self.is_subFeature:
            self.name= f"{self.schema}_{self.feature}_{self.lod}_{self.type}"
    
    def count_view_objects(self,connection):
        cur=connection.cursor()
        cur.execute(f"""SELECT count(*),'' FROM qgis_pkg.{self.name}""")
        count=cur.fetchone()
        cur.close()
        self.objects_amount= count[0]
        return count[0]

    def count_feature_objects(self,connection):
        cur=connection.cursor()
        if self.is_Feature:
            cur.execute(f"""SELECT count(*),'' 
                            FROM {self.schema}.cityobject co
                            JOIN {self.schema}.{self.feature} bg 
                            ON co.id = bg.id
                            WHERE ST_Contains(ST_GeomFromText('{self.extents}',28992),envelope)""")

        elif self.is_subFeature and not self.is_Feature:
            cur.execute(f"""SELECT count(*),'' 
                            FROM {self.schema}.cityobject co
                            JOIN {self.schema}.{self.feature} bg 
                            ON co.id = bg.id
                            WHERE ST_Contains(ST_GeomFromText('{self.extents}',28992),envelope)""")
        count=cur.fetchone()
        cur.close()
        count,empty=count
        return count


    def view_name_from_table(self,table_name):
        if self.is_Feature:
            return feature_tables_to_names[table_name]
        elif self.is_subFeature and not self.is_Feature:
            return subfeature_tables_to_names[table_name]
    
    def table_name_from_view(self,view_name):
        if self.is_Feature:
            return feature_names_to_tables[view_name]
        elif self.is_subFeature and not self.is_Feature:
            return subfeature_names_to_tables[view_names]

    def get_minimum_lod(self):
        pass

class Constants:
    
    views_features_subFeatures=''

    def __init__(self):
        self      

def get_features(dbLoader):
    
    b=Building()
    b.subFeatures.append(BuildingInstallation(b))
    b.subFeatures.append(BuildingPart(b))

    return [b,...,...]



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

geometry_rep={  "lod0":['footprint','roofedge'],
                "lod1":['multisurf','solid','polygon','tin','implicitrep'],
                "lod2":['multisurf','solid','polygon','tin','implicitrep'],
                "lod3":['implicitrep'],
                "lod4":[]} 





def table_to_alias(table_name,table_type):
    if table_type=='feature':
        if table_name=="building": return "Building"
        elif table_name=="cityobject":return "City Object"
        elif table_name=="relief_feature":return "DTM"
        elif table_name=="tunnel":return "Tunnel"
        elif table_name=="bridge":return "Bridge"
        elif table_name=="waterbody":return "Water Bodies"
        elif table_name=="solitary_vegetat_object":return "Vegetation"
        elif table_name=="land_use":return "Land Use"
    
    elif table_type=='sub_feature':
        
        #Cityobject
        if table_name=="city_furniture":return "City furniture"

        #Building
        elif table_name=="building_installation":return "Building installation"
        elif table_name=="building_furniture":return "Building furniture"
        elif table_name=="building":return "Building Part"

        #Relief Feature
        elif table_name=="tin_relief":return "TIN relief"
        
        #Thematic Surface
        elif table_name=='thematic_surface':return 'Thematic surfaces'

        #there is no lod table but still the format for the name might need to be changed
    elif table_type=='lod': 
        if table_name=="lod0":return "LoD0"
        if table_name=="lod1":return "LoD1"
        if table_name=="lod2":return "LoD2"
        if table_name=="lod3":return "LoD3"

    elif table_type=='type':
        if table_name=="multisurf":return "Multi-surface"
        elif table_name=="footprint":return "Footprint"
        elif table_name=="roofedge":return "Roofedge"
        elif table_name=="solid":return "Solid"
        elif table_name=='implicitrep':return "Implicit"
        elif table_name=='tin':return "TIN"
        elif table_name=='polygon':return 'Polygon'

def alias_to_viewSyntax(alias_name,table_type):
    if table_type=='feature':
        if alias_name=="Building": return "building"
        elif alias_name=="City Object":return "cityobject"
        elif alias_name=="DTM":return "relief_feature"
        elif alias_name=="Tunnel":return "tunnel"
        elif alias_name=="Bridge":return "bridge"
        elif alias_name=="Water Bodies":return "waterbody"
        elif alias_name=="Vegetation":return "solitary_vegetat_object"
        elif alias_name=="Land Use":return "land_use"
    
    elif table_type=='sub_feature':
        
        #Cityobject
        if alias_name=="City furniture":return "city_furniture"

        #Building
        elif alias_name=="Building installation":return "building_installation"
        elif alias_name=="Building furniture":return "building_furniture"
        elif alias_name=="Building Part":return "building"

        #Relief Feature
        elif alias_name=="TIN relief":return "tin_relief"
        
        #Thematic Surface
        elif alias_name=='Thematic surfaces':return 'thematic_surface'

        #there is no lod table but still the format for the name might need to be changed
    elif table_type=='lod': 
        if alias_name=="LoD0":return "lod0"
        if alias_name=="LoD1":return "lod1"
        if alias_name=="LoD2":return "lod2"
        if alias_name=="LoD3":return "lod3"

    elif table_type=='type':
        if alias_name=="Multi-surface":return "multisurf"
        elif alias_name=="Footprint":return "footprint"
        elif alias_name=="Roofedge":return "roofedge"
        elif alias_name=="Solid":return "solid"
        elif alias_name=='Implicit':return "implicitrep"
        elif alias_name=='TIN':return "tin"
        elif alias_name=='Polygon':return 'polygon'

def view_syntax(table_name,table_type):
    if table_type=='feature':
        if table_name=="building": return "building"
        elif table_name=="cityobject":return "cityobject"
        elif table_name=="relief_feature":return "relief_feature"
        elif table_name=="tunnel":return "tunnel"
        elif table_name=="bridge":return "bridge"
        elif table_name=="waterbody":return "waterbody"
        elif table_name=="solitary_vegetat_object":return "solitary_vegetat_object"
        elif table_name=="land_use":return "land_use"
    
    elif table_type=='sub_feature':
        #Cityobject
        if table_name=="city_furniture":return "furniture"

        #Building 
        elif table_name=="building_installation":return "installation"
        elif table_name=="building_furniture":return "furniture"
        elif table_name=="building":return "parts"

        #Relief Feature
        elif table_name=="tin_relief":return "tin_relief"

        #Thematic Surface
        elif table_name=='thematic_surface':return 'themsurf'

    #The following are redundunt but have them for comrehension's sake
    elif table_type=='lod': 
        if table_name=="lod0":return "lod0"
        if table_name=="lod1":return "lod1"
        if table_name=="lod2":return "lod2"
        if table_name=="lod3":return "lod3"

    elif table_type=='type':
        if table_name=="multisurf":return "multisurf"
        elif table_name=="solid":return "solid"
        elif table_name=='implicitrep':return "implicitrep"
        elif table_name=='tin':return "tin"
        elif table_name=='polygon':return 'polygon'




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
    Constants.views_features_subFeatures = get_features_subFeatures_views(dbLoader)


# def print_view_hierarchy(data): #NOTE:TODO maybe show this thought the settings
#     for feature in data.keys():
#         print("Feature:\t",feature)
#         for j in data[feature]:
#             if type(j)==type(()):
#                 for view in j:
#                     print("\t\tview:",view)
#             elif type(j)==type({}):
#                 for sub in j.keys():
#                     print("\t\tSubfeature:\t",sub)
#                     for vieww in j[sub]:
#                         print("\t\t\t\tview:",vieww)
#         print("\n")



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

        
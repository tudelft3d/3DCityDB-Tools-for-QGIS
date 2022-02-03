from distutils.log import info
from qgis.PyQt.QtWidgets import QLabel
from .constants import *
from .functions import *

def fill_schema_box(dbLoader):
    dbLoader.dlg.cbxSchema.clear()

    for schema in dbLoader.schemas: 
        res = schema_has_features(dbLoader,schema,features_tables)
        if res:
            dbLoader.dlg.cbxSchema.addItem(schema,res)
 

def schema_has_features(dbLoader,schema,features):
    cur=dbLoader.conn.cursor()

    cur.execute(f"""SELECT table_name, table_schema FROM information_schema.tables 
                    WHERE table_schema = '{schema}' 
                    AND table_name SIMILAR TO '{get_postgres_array(features)}'
                    ORDER BY table_name ASC""")
    feature_response= cur.fetchall() #All tables relevant to the thematic surfaces
    cur.close()
    return feature_response

def count_objects(dbLoader,view_name):
    cur=dbLoader.conn.cursor()
    cur.execute(f"""SELECT count(*),'' from qgis_pkg.{view_name}""")
    count=cur.fetchone()
    cur.close()
    count,empty=count
    return count

def count_objects_in_bbox(dbLoader,checked_features,extents):
    selected_module = dbLoader.dlg.qcbxFeature.currentData()

    for feature in checked_features:
        for view in feature.views:
            cur=dbLoader.conn.cursor()
            cur.execute(f"""SELECT count(*),'' from qgis_pkg.{view.name} t
                        WHERE ST_Intersects(ST_GeomFromText('{extents}',28992), t.geom)""")
            count=cur.fetchone()
            cur.close()
            count,empty=count
            view.count = count  



def fill_module_box(dbLoader):

    for module_name in modules:
        module_obj = instantiate_objects(dbLoader,module_name)
        if module_obj: 
            for feature in module_obj.features:
                for view in feature.views:
                    print(view)
                    if count_objects(dbLoader, view.name):
                        dbLoader.dlg.qcbxFeature.addItem(module_obj.alias,module_obj) 
                        break
                else: 
                    continue
                break

        

def instantiate_objects(dbLoader,module_name):

    if module_name == "Building": #TODO: don't hardcode, at least not here

        mod = Module(module_name)
        mod.features=[
                Building(*building.values()),
                BuildingInstallation(*building_installation.values()),
                BuildingPart(*building_part.values())
            ]


    elif module_name == 'Vegetation':
        mod = Module(module_name)
        mod.features = [
            Vegetation(*vegetation.values())
            ] 
    #TODO: fill the rest of the features
    else: return None
    
    dbLoader.module_container.append(mod)
    return mod


def fill_lod_box(dbLoader):
    checked_features = get_checked_features(dbLoader,dbLoader.dlg.gridLayout_2)
    extents=dbLoader.dlg.qgrbExtent.outputExtent().asWktPolygon()
    
    for feature in checked_features:
        current_lod= None
        add_types=[]
        add_geometries={}
        for view in feature.views:
            if view.count:
                if  current_lod != view.lod:
                    if current_lod and add_types: #check if they are NOT empty
                        add_types=[]

                    current_lod= view.lod
                    add_types.append(view.representation)
                    add_geometries[current_lod]=add_types

                else:
                    add_types.append(view.representation)
                    add_geometries[current_lod]=add_types

            feature.lods=add_geometries
            
            
        
    lod_intersection=[]
    for feature in checked_features:
        lod_intersection.append(set(feature.lods.keys()))
    res=sorted(set.intersection(*lod_intersection))

    types=[]
    for feature in checked_features:
        for lod in res:
            if type(feature.lods[lod])==type([]):
                for i in feature.lods[lod]:
                    types.append(i)
            else:
                types.append(feature.lods[lod])
    

    counter=Counter(types)

    types=[]
    for key in counter.keys():
        if counter[key] >= len(checked_features): #NOTE: this >= seems suspicius
            types.append(key)

    for key,values in geometry_rep.items():
        if key in res:
            add_types=[]
            for v in values:
                if v in types:
                    add_types.append(table_to_alias(v,'type'))
            dbLoader.dlg.cbxGeometryLvl.addItem(table_to_alias(key,'lod'),add_types)  


def create_geometry_checkboxes(dbLoader,types):

    row=-1
    col=0
    try:
        for c,representation in enumerate(types):
            #assert feature.subFeatures_objects #NOTE:22-01-2022 I want to catch features that don't have subfeatures and notify the user. BUT i don't think it works as intended
            check_box= QCheckBox(representation)
            check_box.stateChanged.connect(dbLoader.evt_checkBoxTypes_stateChanged)
            if c%3==0:
                row+=1
                col=0
            dbLoader.dlg.gridLayout_4.addWidget(check_box,row,col)
            if c==0:dbLoader.dlg.gbxSubFeatures.setDisabled(False)
            col+=1
    except AssertionError as msg:
        dbLoader.show_Qmsg(f'<b>{msg}</b> doesn\'t have any sub-features',msg_type=Qgis.Info)
        return 0


def set_counter_label(dbLoader):
    checked_types = get_checked_types(dbLoader,dbLoader.dlg.gridLayout_4)
    checked_features = get_checked_features(dbLoader,dbLoader.dlg.gridLayout_2)
    selected_lod=dbLoader.dlg.cbxGeometryLvl.currentText()

    msg=''
    total_count=0
    for feature in checked_features:
        for view in feature.views:
            print(view.lod,view.representation,checked_types)
            if view.lod==alias_to_viewSyntax(selected_lod,'lod'):
                if view.representation in checked_types:
                    total_count+=view.count
                    msg+=f"    \u2116 of '{feature.alias}' objects represented as {view.representation}: {view.count}\n"
                else:
                    total_count+=view.count
                    msg+=f"\u2116 of '{feature.alias}' objects: {view.count}\n"
    label= QLabel()
    warning_icon=":/plugins/citydb_loader/icons/warning_icon.svg"
    info_icon=":/plugins/citydb_loader/icons/info_icon.svg"
    
    html="""
    <html>
    <head/>
        <body>
            <p>
            <img src="{icon_path}" width="20" height="20"/>
            <br/>{message}
            </p>
        </body>
    </html>"""

    if total_count>20000:
        label.setText(html.format(icon_path = warning_icon,message= msg))
    else:
        label.setText(html.format(icon_path = info_icon,message= msg))
    dbLoader.dlg.formLayout.addWidget(label)
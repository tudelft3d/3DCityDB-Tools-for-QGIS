
from tkinter.ttk import Separator
from pandas import isnull
from qgis.PyQt.QtWidgets import QLabel
from qgis.PyQt import QtCore
from .constants import *
from .functions import *


 



def count_objects(dbLoader,view_name):

    try:
        cur=dbLoader.conn.cursor()
        cur.execute(f"""SELECT count(*),'' from qgis_pkg.{view_name}""")
        count=cur.fetchone()
        cur.close()
        count,empty=count
        return count
    except (Exception, psycopg2.DatabaseError) as error:
        print('In import_tab.count_objects:',error)
        cur.close()

def count_objects_in_bbox(dbLoader,checked_features,extents):
    selected_module = dbLoader.dlg.cbxModule.currentData()

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

    modules=instantiate_objects(dbLoader)

    for module_obj in modules.values():    

        for feature in module_obj.features.values():
            for view in feature.views:
                if view.count>0:
                    dbLoader.dlg.cbxModule.addItem(module_obj.alias,module_obj)
                    break
            else: 
                continue
            break

        

def instantiate_objects(dbLoader):
    cur=dbLoader.conn.cursor()
    cur.execute(f"""SELECT * FROM qgis_pkg.metadata""")
    metadata=cur.fetchall()
    colnames = [desc[0] for desc in cur.description]
    cur.close()
    metadata_dict_list= [dict(zip(colnames,f)) for f in metadata]
    
    dbLoader.module_container=   { "Building": Module(alias='Building',features={  "Building": Building(),
                                                                                "BuildingPart": BuildingPart(),
                                                                                "BuildingInstallation": BuildingInstallation(),
                                                                                "BuildingFurniture": BuildingFurniture()}),
                                "Vegetation": Module(alias='Vegetation', features= {"Vegetation": Vegetation(),
                                                                                    "PlantCover": PlantCover()})}

    dbLoader.module_container
    for metadata_dict in metadata_dict_list:
        
        #keys: id,module,root_feature,schema,lod,alias,layer_name,object_count
        if metadata_dict['object_count']==0:continue
        curr_module_obj=dbLoader.module_container[metadata_dict['module']]
        curr_feature = curr_module_obj.features[metadata_dict['root_feature']]
        curr_feature.views.append(View(*metadata_dict.values()))

    return dbLoader.module_container


def fill_lod_box(dbLoader):
    selected_module = dbLoader.dlg.cbxModule.currentData()
    if not selected_module: return None
    geom_set=set()
    geom_set_=set()
    for feature in selected_module.features.values():
        for view in feature.views:
            geom_set.add(view.lod)
            geom_set_.add(alias_to_viewSyntax(view.lod,'lod'))
            
    avalibale_lods = dict(zip(sorted(list(geom_set)),sorted(list(geom_set_))))

    for alias,lod in avalibale_lods.items():
        dbLoader.dlg.cbxLod.addItem(alias,lod)



def fill_features_box(dbLoader):
    selected_lod = dbLoader.dlg.cbxLod.currentText()
    selected_module = dbLoader.dlg.cbxModule.currentData()
    
    if not selected_module: return None

    try:
        c=0
        for c,feature in enumerate(selected_module.features.values()):
            for view in feature.views:
                if view.lod == selected_lod:  
                    count=get_view_obj_amount(dbLoader,view.view_name)
                    if count > 0: 
                        dbLoader.dlg.ccbxFeatures.setCurrentIndex(c)
                        dbLoader.dlg.ccbxFeatures.addItemWithCheckState(f'{view.alias} ({count})',0, userData=view)#{view.view_name:(view.module,view.schema,view.lod,view.root_feature)})

#TODO: 05-02-2021 Add separator between different features NOTE:REMEMBER: don't use method 'setSeparator', it adds a custom separtor to join string of selected items

    except AssertionError as msg:
        dbLoader.show_Qmsg(f'<b>{msg}</b> doesn\'t have any sub-features',msg_type=Qgis.Info)
        return 0

def get_view_obj_amount(dbLoader,view):
    extents = dbLoader.dlg.qgbxExtent.outputExtent().asWktPolygon()
    cur=dbLoader.conn.cursor()
    cur.callproc('qgis_pkg.view_counter',(view,extents))
    count=cur.fetchone()[0]
    cur.close()
    return count


def set_counter_label(dbLoader):
    checked_types = get_checked_types(dbLoader,dbLoader.dlg.gridLayout_4)
    checked_features = get_checked_features(dbLoader,dbLoader.dlg.gridLayout_2)
    selected_lod=dbLoader.dlg.cbxLod.currentText()

    msg=''
    total_count=0
    for feature in checked_features:
        for view in feature.views:
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
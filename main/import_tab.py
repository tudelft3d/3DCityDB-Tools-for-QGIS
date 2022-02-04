
from qgis.PyQt.QtWidgets import QLabel
from .constants import *
from .functions import *


 



def count_objects(dbLoader,view_name):
    cur=dbLoader.conn.cursor()
    cur.execute(f"""SELECT count(*),'' from qgis_pkg.{view_name}""")
    count=cur.fetchone()
    cur.close()
    count,empty=count
    return count

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

    for module_obj in modules:    

        for feature in module_obj.features:
            for view in feature.views:
                if count_objects(dbLoader, view.name):
                    dbLoader.dlg.cbxModule.addItem(module_obj.alias,module_obj)
                    break
            else: 
                continue
            break

        

def instantiate_objects(dbLoader):
    dbLoader.module_container=[]
    for module_name in modules:
        
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
        else: continue
        
        dbLoader.module_container.append(mod)
    return dbLoader.module_container


def fill_lod_box(dbLoader):
    selected_module = dbLoader.dlg.cbxModule.currentData()
    
    geom_set=set()
    geom_set_=set()
    for feature in selected_module.features:
        for view in feature.views:
            geom_set.add(view.lod)
            geom_set_.add(table_to_alias(view.lod,'lod'))
            

    avalibale_lods = dict(zip(sorted(list(geom_set_)),sorted(list(geom_set))))

    for alias,lod in avalibale_lods.items():
        dbLoader.dlg.cbxLod.addItem(alias,lod)



def fill_features_box(dbLoader):
    selected_lod = dbLoader.dlg.cbxLod.currentData()
    selected_module = dbLoader.dlg.cbxModule.currentData()
    
    try:
        for c,feature in enumerate(selected_module.features):
            for view in feature.views:
                if view.lod == selected_lod:
                    dbLoader.dlg.ccbxFeatures.addItemWithCheckState(view.name,0,view.name)
    except AssertionError as msg:
        dbLoader.show_Qmsg(f'<b>{msg}</b> doesn\'t have any sub-features',msg_type=Qgis.Info)
        return 0


def set_counter_label(dbLoader):
    checked_types = get_checked_types(dbLoader,dbLoader.dlg.gridLayout_4)
    checked_features = get_checked_features(dbLoader,dbLoader.dlg.gridLayout_2)
    selected_lod=dbLoader.dlg.cbxLod.currentText()

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
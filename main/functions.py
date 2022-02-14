# -*- coding: utf-8 -*-
from distutils.command.config import config
import os, configparser
from gpg import Data
import psycopg2
from pyrsistent import b
from qgis.core import *
from qgis.gui import QgsLayerTreeView
from qgis.PyQt.QtWidgets import QMessageBox,QCheckBox,QHBoxLayout
from qgis.PyQt.QtGui import QStandardItemModel
from .connection import *
from qgis.PyQt.QtCore import *
from collections import OrderedDict
from .constants import *
import itertools
from collections import Counter









def create_features_checkboxes(dbLoader):
    module = dbLoader.dlg.cbxModule.currentData()

    row=-1
    col=0
    try:
        for c,feature in enumerate(module.features):
            #assert feature.subFeatures_objects #NOTE:22-01-2022 I want to catch features that don't have subfeatures and notify the user. BUT i don't think it works as intended
            check_box= QCheckBox(feature.alias)
            check_box.stateChanged.connect(dbLoader.evt_checkBox_stateChanged)
            if c%3==0:
                row+=1
                col=0
            dbLoader.dlg.gridLayout_2.addWidget(check_box,row,col)
            if c==0:dbLoader.dlg.gbxSubFeatures.setDisabled(False)
            col+=1
    except AssertionError as msg:
        dbLoader.show_Qmsg(f'<b>{msg}</b> doesn\'t have any sub-features',msg_type=Qgis.Info)
        return 0

    

def delete_all_features_widgets(dbLoader,layout):
    for w in reversed(range(layout.count())):
        layout.itemAt(w).widget().setParent(None)


def get_checked_features(dbLoader,layout):
    selected_module = dbLoader.dlg.cbxModule.currentData()
    check_boxes = [layout.itemAt(w).widget() for w in reversed(range(layout.count()))]
    checked_features=[]
    for feature in check_boxes: 
        if feature.isChecked():
            obj_inx=[feat.alias for feat in selected_module.features].index(feature.text())
            checked_features.append(selected_module.features[obj_inx])
    return checked_features

def get_checked_types(dbLoader,layout):
    check_boxes = [layout.itemAt(w).widget() for w in reversed(range(layout.count()))]
    checked_types=[]
    for representation in check_boxes: 
        if representation.isChecked():
            checked_types.append(representation)
    return checked_types






def check_geometry(dbLoader):
    conn = None
    database = dbLoader.dlg.cbxExistingConnection.currentData()
    schema = dbLoader.dlg.cbxScema.currentText()
    feature = dbLoader.dlg.cbxModule.currentData()
    extents=dbLoader.dlg.qgbxExtent.outputExtent().asWktPolygon() 

    checked_subfeature_tables = get_checked_features(dbLoader)
    feature_all_lvls = [feature]+checked_subfeature_tables


    try:

        total_count=0
        
        msg=''
        for element in feature_all_lvls:
            cur=dbLoader.conn.cursor()
            #Get amount of thematic features and subfeatures inside the extents 
            if element.view_name == 'part':
                            cur.execute(f"""SELECT count(*),'' 
                            FROM {schema}.cityobject co
                            JOIN {schema}.{element.table_name} bg 
                            ON co.id = bg.id
                            WHERE ST_Intersects(ST_GeomFromText('{extents}',28992),envelope)
                            AND bg.objectclass_id = {element.class_id}""")
            else:
                cur.execute(f"""SELECT count(*),'' 
                            FROM {schema}.cityobject co
                            JOIN {schema}.{element.table_name} bg 
                            ON co.id = bg.id
                            WHERE ST_Intersects(ST_GeomFromText('{extents}',28992),envelope)""")
            count=cur.fetchone()
            cur.close()
            count,empty=count
            element.count=count
            total_count+=count

            if element.is_feature: 
                msg+=f"\u2116 of '{element.alias}' objects: {element.count}\n"
            else: 
                msg+=f"   \u2116 of '{element.alias}' objects: {element.count}\n"


            current_lod= None
            add_lod=None
            add_types=[]
            add_geometries={}
            for view in element.views:
                
                cur=dbLoader.conn.cursor()
                #Get geometry columns
                cur.execute(f"""SELECT count(*),'' FROM qgis_pkg.{view.name}
                                WHERE ST_GeomFromText('{extents}',28992) && ST_Envelope(geom))""") #TODO: DONT HARDCODE SRID
                count=cur.fetchone()
                cur.close()
 
                if count[0]: #NOT 0
                    if  current_lod != view.lod:
                        if current_lod and add_types: #check if they are NOT empty
                            add_types=[]

                        current_lod= view.lod
                        add_types.append(view.type)
                        add_geometries[current_lod]=add_types

                    else:
                        add_types.append(view.type)
                        add_geometries[current_lod]=add_types

            element.lods=add_geometries
            
            
        
        lod_intersection=[]
        for element in feature_all_lvls:
            lod_intersection.append(set(element.lods.keys()))
        res=sorted(set.intersection(*lod_intersection))



        types=[]
        for element in feature_all_lvls:
            for lod in res:
                if type(element.lods[lod])==type([]):
                    for i in element.lods[lod]:
                        types.append(i)
                else:
                    types.append(element.lods[lod])
        

        counter=Counter(types)

        types=[]
        for key in counter.keys():
            if counter[key] >= len(feature_all_lvls): #NOTE: this >= seems suspicius
                types.append(key)

        for key,values in geometry_rep.items():
            if key in res:
                add_types=[]
                for v in values:
                    if v in types:
                        add_types.append(table_to_alias(v,'type'))
                dbLoader.dlg.cbxLod.addItem(table_to_alias(key,'lod'),add_types)       
                    

        #Guard against importing many feutures
        if total_count>20000:
            QMessageBox.warning(dbLoader.dlg,"Warning", f"Too many features set to be imported ({total_count})!\n"
                                                        f"This could hinder perfomance and even cause frequent crashes.\n{msg}") #TODO: justify it better with storage size to 
        else:
            QMessageBox.information(dbLoader.dlg,"Info", msg)
            if count == 0:
                cur.close()
                return 2

    except (Exception, psycopg2.DatabaseError) as error:
        print(error)
    finally:
        if dbLoader.conn is not None:
            # close the communication with the PostgreSQL
            #cur.close()
            pass
    

    return 3


def fieldVisibility (layer,fname):
    setup = QgsEditorWidgetSetup('Hidden', {})
    for i, column in enumerate(layer.fields()):
        if column.name()==fname:
            layer.setEditorWidgetSetup(i, setup)
            break
        else:
            continue

def value_rel_widget(AllowMulti= False, AllowNull= True, FilterExpression='',
                    Layer= '', Key= '', Value= '',
                    NofColumns= 1, OrderByValue= False, UseCompleter= False):

    config =   {'AllowMulti': AllowMulti,
                'AllowNull': AllowNull,
                'FilterExpression':FilterExpression,
                'Layer': Layer,
                'Key': Key,
                'Value': Value,
                'NofColumns': NofColumns,
                'OrderByValue': OrderByValue,
                'UseCompleter': UseCompleter}
    return QgsEditorWidgetSetup(type= 'ValueRelation',config= config)



    #     for element,views in feature_views.items():
    #         for view in views:
    #             import_lookups(dbLoader)
    #             vlayer = create_layers(dbLoader,view.name)
    #             import_generics(dbLoader)

    #             if not vlayer or not vlayer.isValid():
    #                 dbLoader.show_Qmsg('Layer failed to load properly',msg_type=Qgis.Critical)
    #             else:
    #                 # if vlayer.featureCount()==0:
    #                 #     continue
    #                 #dbLoader.iface.mainWindow().blockSignals(True)
    #                 QgsProject.instance().addMapLayer(vlayer,False)
                    
    #                 if element.is_feature: node_flod.addLayer(vlayer)
    #                 else: 
    #                     #if thematicSurfaces_in_view in view.subfeature:

                       
    #                     node_subFeature= node_feature.findGroup(element.alias)
    #                     node_lod = node_subFeature.findGroup(table_to_alias(view.lod,'lod'))
    #                     node_lod.addLayer(vlayer)

    #                 dbLoader.iface.mainWindow().blockSignals(False) #NOTE: Temp solution to avoid undefined CRS pop up. IT IS DEFINED
    #                 dbLoader.show_Qmsg('Success!!')

    #                 vlayer.loadNamedStyle('/home/konstantinos/.local/share/QGIS/QGIS3/profiles/default/python/plugins/citydb_loader/forms/forms_style.qml') #TODO: this needs to be platform independent
    #                 create_relations(vlayer)
    #     #Its important to first order the ToC and then send it to the top. 
    #     order_ToC(node_database)     
    #     send_to_top_ToC(root,node_database)

    # except (Exception, psycopg2.DatabaseError) as error:
    #     print(error)
    #     dbLoader.show_Qmsg('Import failed! Check Log Messages',msg_type=Qgis.Critical)
    # finally:
    #     if dbLoader.conn is not None:
    #         # close the communication with the PostgreSQL
    #         #cur.close()
    #         pass
            
    

#TODO: Check if Commit is needed after every query execution https://www.psycopg.org/docs/faq.html

#TODO: drop view when layer is removed from project
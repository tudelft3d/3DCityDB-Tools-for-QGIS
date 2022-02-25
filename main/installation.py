"""This module contains functions that relate to the package Installation
operations.

These functions are usually called from widget_setup functions 
relating to child widgets of the 'Settings Tab' or 'Connection Tab'
as from either of these tabs installation,uninstallation processes
can commence.
"""

from qgis.PyQt.QtWidgets import QProgressBar,QMessageBox
from qgis.PyQt.QtCore import Qt
from .constants import *
from qgis.core import Qgis, QgsMessageLog
import os
import subprocess
from .constants import get_postgres_array
from .threads import install_pkg_thread
import psycopg2

def has_qgis_pkg(dbLoader):
    """
    Check if current database has all the necessary view installed.
    This function helps to avoid new installation on top of existing ones (case when the plugin runs from start)
    """
    if 'qgis_pkg' in dbLoader.schemas:
        return True
    return False


def has_schema_views(dbLoader,schema): #TODO: TRY except, or plpgsql it in package
    try:
        cur = dbLoader.conn.cursor()
        cur.execute(""" SELECT table_name,'' FROM information_schema.tables 
                        WHERE table_schema = 'qgis_pkg' AND table_type = 'VIEW'""")
        views= cur.fetchall()
        cur.close()
        views,empty = zip(*views)
        dbLoader.cur_schema_views=views     
        if any(schema in view for view in views):
            return True
        return False
    except (Exception, psycopg2.DatabaseError) as error:
        print("In 'installation.has_schema_views",error) 
        

def upd_conn_file(dbLoader):

    #Get selected connection details 
    database = dbLoader.dlg.cbxExistingConnection.currentData() 
    
    #Get plugin directory (parent dir of 'main')
    cur_dir = os.path.dirname(os.path.realpath(__file__))
    par_dir = os.path.join(cur_dir,os.pardir)

    if os.name == 'posix': #Linux or MAC

        #Create path to the 'connections' file
        path_connection_params = os.path.join(par_dir,dbLoader.plugin_package, 'CONNECTION_params.sh')

        #Get psql executable path
        cmd = ['which', 'psql']
        proc = subprocess.Popen(cmd, stdout=subprocess.PIPE, stderr=subprocess.PIPE)
        o, e = proc.communicate()
        psql_path = o.decode('ascii') 
        

        #Rewrite the 'connections' file with current database parameters.
        with open (path_connection_params, 'w') as f:
            f.write(f"""\
#!/bin/bash

export PGHOST={database.host}
export PGPORT={database.port}
export CITYDB={database.database_name}
export PGUSER={database.username}
export PGBIN={psql_path}
""")    
        #Give executable rights    
        os.chmod(path_connection_params, 0o755)

    else: #Windows TODO: Find how to translate the above into windows batch
        pass
    return 0

def installation_query(dbLoader,message,origin):
    selected_db=dbLoader.dlg.cbxExistingConnection.currentData()

    res= QMessageBox.question(dbLoader.dlg,"Installation", message)
    if res == 16384: #YES                
        upd_conn_file(dbLoader) #Prepares installation scripts with the connection parameters 
        success = install(dbLoader,origin)
        if success: return True                   
    else: 
        dbLoader.connection_status['Install']=False
    return False

def install(dbLoader,origin):
    """Origin relates to the mode of installation automatically/manually.
       But in practice it is the label object on which the loading anumation is going to play """
    #Get plugin directory
    selected_db=dbLoader.dlg.cbxExistingConnection.currentData()

    cur_dir = os.path.dirname(os.path.realpath(__file__))
    par_dir = os.path.join(cur_dir,os.pardir)
    os.chdir(par_dir)

    if os.name == 'posix': #Linux or MAC
        path_installation_sh = os.path.join(par_dir,dbLoader.plugin_package, 'CREATE_DB_qgis_pkg.sh')
        path_installation_sql = os.path.join(cur_dir,dbLoader.plugin_package, 'INSTALL_qgis_pkg.sql')
        
        #Give executable rights
        os.chmod(path_installation_sh, 0o755)

        #Run installation script
        install_pkg_thread(dbLoader,path_installation_sh,selected_db.password,origin) #TODO: Need to catch error in the worker thread for logging and user msgs
        return True
    else: #Windows TODO: Find how to translate the above into windows batch
        pass
    return False

def uninstall_pkg(dbLoader):
    progress = QProgressBar(dbLoader.dlg.gbxInstall.bar)
    progress.setMaximum(len(dbLoader.schemas))
    progress.setAlignment(Qt.AlignLeft|Qt.AlignVCenter)
    dbLoader.dlg.gbxInstall.bar.pushWidget(progress, Qgis.Info)

    if 'qgis_pkg' in dbLoader.schemas:
        cur = dbLoader.conn.cursor()
        cur.execute(f"""DROP SCHEMA qgis_pkg CASCADE;""")

        dbLoader.conn.commit()
        cur.close()
        dbLoader.conn.close()  

        msg = dbLoader.dlg.gbxInstall.bar.createMessage( u'Database has been cleared' )
        dbLoader.dlg.gbxInstall.bar.clearWidgets()
        dbLoader.dlg.gbxInstall.bar.pushWidget(msg, Qgis.Success, duration=4)
        
        dbLoader.dlg.cbxExistingConnection.currentData().has_installation = False
                     
    else:
        QgsMessageLog.logMessage('This message should never be able to be printed. Check installation.py ',level= Qgis.Critical,notifyUser=True)

def uninstall_views(dbLoader,schema):
    progress = QProgressBar(dbLoader.dlg.gbxInstall.bar)
    progress.setMaximum(len(dbLoader.schemas))
    progress.setAlignment(Qt.AlignLeft|Qt.AlignVCenter)
    dbLoader.dlg.gbxInstall.bar.pushWidget(progress, Qgis.Info)

    view_array=get_postgres_array(dbLoader.cur_schema_views)

    if 'qgis_pkg' in dbLoader.schemas:
        cur = dbLoader.conn.cursor()
        cur.execute(f"""    SELECT 'DROP VIEW ' || table_name || ' CASCADE;' 
                            FROM information_schema.tables 
                            WHERE table_name SIMILAR TO '%{schema}%' and table_schema='qgis_pkg';""")

        dbLoader.conn.commit()
        cur.close()

        msg = dbLoader.dlg.gbxInstall.bar.createMessage( u'Database has been cleared' )
        dbLoader.dlg.gbxInstall.bar.clearWidgets()
        dbLoader.dlg.gbxInstall.bar.pushWidget(msg, Qgis.Success, duration=4)
        
        dbLoader.dlg.cbxExistingConnection.currentData().has_installation = False
                     
    else:
        QgsMessageLog.logMessage('This message should never be able to be printed. Check installation.py ',level= Qgis.Critical,notifyUser=True)


# def refresh_schema_views(dbLoader):
#     import time

#     if 'qgis_pkg' in dbLoader.schemas:        
#         cur = dbLoader.conn.cursor()
        
#         cur.callproc("qgis_pkg.refresh_materialized_view")
        
#         for notice in dbLoader.conn.notices: #NOTE: It may take notices from other procs
#              QgsMessageLog.logMessage(notice,tag="3DCityDB-Loader",level= Qgis.Info)

#         #dbLoader.conn.commit()

#         msg = dbLoader.dlg.gbxInstall.bar.createMessage( u'Views have been succesfully updated' )
#         dbLoader.dlg.gbxInstall.bar.clearWidgets()
#         dbLoader.dlg.gbxInstall.bar.pushWidget(msg, Qgis.Success, duration=4)
        
                     
#     else:
#         QgsMessageLog.logMessage('This message should never be able to be printed. Check installation.py ',level= Qgis.Critical,notifyUser=True)


import psycopg2
import time
from qgis.PyQt.QtWidgets import QProgressBar
from qgis.PyQt.QtCore import *
from qgis.core import Qgis, QgsMessageLog

global building_attr
building_attr=  """
                b.id, o.gmlid,
                o.envelope,
                b.class,
                b.function, b.usage,
                b.year_of_construction, b.year_of_demolition,
                b.roof_type,
                b.measured_height,measured_height_unit,
                b.storeys_above_ground, b.storeys_below_ground,
                b.storey_heights_above_ground, b.storey_heights_ag_unit,
                b.storey_heights_below_ground, b.storey_heights_bg_unit
                """
global plugin_view_syntax
plugin_view_syntax =    {'building':'building',
                         'LoD0':'lod0',
                         'LoD1':'lod1',
                         'LoD2':'lod2',
                         'Footprint':'footprint',
                         'Roofprint':'roofedge',
                         'Multi-surface':'multisurf',
                         'Solid':'solid'}

global feature_subclasses
feature_subclasses = {'building': ('Building Part', 'Building installation')}

def check_install(dbLoader):
    """
    Check if current database has all the necessary view installed.
    This function helps to avoid new installation on top of existing ones (case when the plugin runs from start)
    """
    cur = dbLoader.conn.cursor()
    if 'qgis_pkg' in dbLoader.schemas:
        return True

import os
import subprocess
def upd_conn_file(dbLoader):

    #Get selected connection details 
    database = dbLoader.dlg.cbxConnToExist.currentData() 
    
    #Get plugin directory
    cur_dir = os.path.dirname(os.path.realpath(__file__))

    if os.name == 'posix': #Linux or MAC

        #Create path to the 'connections' file
        path_connection_params = os.path.join(cur_dir,'qgis_pkg', 'CONNECTION_params.sh')

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
""")    
        #Give executable rights    
        os.chmod(path_connection_params, 0o755)

    else: #Windows TODO: Find how to translate the above into windows batch
        pass
    return 0


def install(db):
    #Get plugin directory

    cur_dir = os.path.dirname(os.path.realpath(__file__))
    os.chdir(cur_dir)

    if os.name == 'posix': #Linux or MAC
        path_installation_sh = os.path.join('./','qgis_pkg', 'CREATE_DB_qgis_pkg.sh')
        path_installation_sql = os.path.join(cur_dir,'qgis_pkg', 'INSTALL_qgis_pkg.sql')
        
        #Give executable rights
        os.chmod(os.path.join(os.getcwd(),'qgis_pkg', 'CREATE_DB_qgis_pkg.sh'), 0o755)

        #Run installation script
        p = subprocess.Popen(path_installation_sh,  stdin = subprocess.PIPE,
                                                    stdout=subprocess.PIPE ,
                                                    stderr=subprocess.PIPE ,
                                                    universal_newlines=True)

        output,e = p.communicate(f'{db.password}\n')
        if 'ERROR' in e:
            QgsMessageLog.logMessage('Installation failed!',level= Qgis.Critical,notifyUser=True)
            QgsMessageLog.logMessage(e[29:],level= Qgis.Info,notifyUser=True) #e[29:] skips manually 'Password for user postgres:', the stdin of the subprocess
            return 0
        else: QgsMessageLog.logMessage(output,level= Qgis.Success,notifyUser=True)


    else: #Windows TODO: Find how to translate the above into windows batch
        pass
    return 1

def uninstall(dbLoader):
    progress = QProgressBar(dbLoader.dlg.gbxInstall.bar)
    progress.setMaximum(len(dbLoader.schemas))
    progress.setAlignment(Qt.AlignLeft|Qt.AlignVCenter)
    dbLoader.dlg.gbxInstall.bar.pushWidget(progress, Qgis.Info)

    if 'qgis_pkg' in dbLoader.schemas:
        cur = dbLoader.conn.cursor()
        cur.execute(f"""DROP SCHEMA qgis_pkg CASCADE""")

        dbLoader.conn.commit()

        msg = dbLoader.dlg.gbxInstall.bar.createMessage( u'Database has been cleared' )
        dbLoader.dlg.gbxInstall.bar.clearWidgets()
        dbLoader.dlg.gbxInstall.bar.pushWidget(msg, Qgis.Success, duration=4)
        
        dbLoader.dlg.cbxConnToExist.currentData().has_installation = False
                     
    else:
        QgsMessageLog.logMessage('This message should never be able to be printed. Check installation.py ',level= Qgis.Critical,notifyUser=True)

from .installation import *
from .connection_tab import *
from .functions import *
from .threads import *
from qgis.PyQt.QtCore import QThread



def cbxExistingConnection_setup(dbLoader):
    selected_db=dbLoader.dlg.cbxExistingConnection.currentData()

    ### Database groupbox
    dbLoader.dlg.gbxDatabase.setDisabled(False)
    dbLoader.dlg.btnConnectToDB.setText(f"Connect to '{selected_db.database_name}'")
    dbLoader.dlg.lblConnectToDB.setDisabled(False)
    dbLoader.dlg.btnConnectToDB.setDisabled(False)

    dbLoader.dlg.lblSchema.setDisabled(True)
    dbLoader.dlg.cbxSchema.clear()
    dbLoader.dlg.cbxSchema.setDisabled(True)

    ### Connection Status groupbox
    dbLoader.dlg.gbxConnectionStatus.setDisabled(True)
    dbLoader.dlg.lblConnectedToDB_out.clear()
    dbLoader.dlg.lblServerVersion_out.clear()
    dbLoader.dlg.lblUserPrivileges_out.clear()
    dbLoader.dlg.lbl3DCityDBVersion_out.clear()
    dbLoader.dlg.lblInstall.setText("Installation for <schema>:")
    dbLoader.dlg.lblInstall_out.clear()

    ### User Type groupbox
    deselect_radiobtn_group(dbLoader)
    dbLoader.dlg.gbxUserType.setDisabled(True)

    if dbLoader.conn: dbLoader.conn.close()

    reset_importTab(dbLoader)
    reset_settingsTab(dbLoader)

    dbLoader.connection_status={'ConnectedToDB':False,'ServerVersion':False,'UserPrivileges':False,'3DCityDBVersion':False,'Install':False}

def btnConnectToDB_setup(dbLoader):
    selected_db=dbLoader.dlg.cbxExistingConnection.currentData()

    ### Connection Status groupbox
    dbLoader.dlg.gbxConnectionStatus.setDisabled(False)

    successful_connection = is_connected(dbLoader)
    if successful_connection:
        
        ##Show successful database name connection and server version
        dbLoader.dlg.lblConnectedToDB_out.setText(success_html.format(selected_db.database_name))
        dbLoader.connection_status['ConnectedToDB']=True
        dbLoader.dlg.lblServerVersion_out.setText(success_html.format(selected_db.s_version))
        dbLoader.connection_status['ServerVersion']=True 

        if is_3dcitydb(dbLoader):
            dbLoader.connection_status['3DCityDBVersion']=True
            dbLoader.dlg.lbl3DCityDBVersion_out.setText(success_html.format(selected_db.c_version))
        else: 
            dbLoader.connection_status['3DCityDBVersion']=False
            dbLoader.dlg.lbl3DCityDBVersion_out.setText(failure_html.format(selected_db.database_name+' DOES NOT have 3DCityDB installed.'))


        ##Enalbe and fill schema comboBox
        dbLoader.dlg.cbxSchema.setDisabled(False)
        dbLoader.dlg.lblSchema.setDisabled(False)
        get_schemas(dbLoader)           #Stored in dbLoader.schemas
        fill_schema_box(dbLoader)       #Stored in dbLoader.dlg.cbxSchema
        #At this point,filling the schema box, activates the 'evt_cbxSchema_changed' event. 
        #So if you're following the code line by line, go to citydb_loader.py>evt_cbxSchema_changed or at 'cbxSchema_setup' function below

    else: 
        dbLoader.dlg.lblConnectedToDB_out.setText(failure_html.format('Unsucessful connection'))
        dbLoader.connection_status['ConnectedToDB']=False
        dbLoader.dlg.lblServerVersion_out.setText(failure_html.format('')) 
        dbLoader.connection_status['ServerVersion']=False     
        dbLoader.dlg.cbxSchema.setDisabled(True)
        dbLoader.dlg.lblSchema.setDisabled(True)


def cbxSchema_setup(dbLoader):
    selected_db=dbLoader.dlg.cbxExistingConnection.currentData()
    selected_schema=dbLoader.dlg.cbxSchema.currentText()

    if not selected_schema: return None

    ### Connection Status groupbox
    dbLoader.dlg.lblInstall.setText(f"Installation for {selected_schema}:")
    dbLoader.dlg.lblUserPrivileges_out.clear()
    
    #Catch and show errors
    privileges_dict=table_privileges(dbLoader)
    if not privileges_dict: 
        dbLoader.dlg.lblInstall_out.clear()
        dbLoader.connection_status['UserPrivileges']=False
        return dbLoader.dlg.lblUserPrivileges_out.setText(failure_html.format('An error occured assesing privileges. See log'))

    #Show user privilages
    dbLoader.availiable_privileges = true_privileges(privileges_dict)
    if len(privileges_dict)==len(privileges_dict):
        dbLoader.dlg.lblUserPrivileges_out.setText(success_html.format(dbLoader.availiable_privileges))
        dbLoader.connection_status['UserPrivileges']=True
    elif len(privileges_dict)==0:
        dbLoader.dlg.lblUserPrivileges_out.setText(failure_html.format(dbLoader.availiable_privileges))
        dbLoader.connection_status['UserPrivileges']=False
    else: dbLoader.dlg.lblUserPrivileges_out.setText(crit_warning_html.format(dbLoader.availiable_privileges))
    

    #Check for schema installation
    dbLoader.dlg.lblInstall_out.clear()
    has_qgispkg= has_qgis_pkg(dbLoader)
    if not has_qgispkg:
        dbLoader.dlg.lblInstall_out.setText(crit_warning_html.format('qgis_pkg is not installed!\n\tRequires installation!'))
        dbLoader.connection_status['Install']=False
        return installation_query(dbLoader,f"Database '{selected_db.database_name}' requires 'qgis_pkg' to be installed with contents mapping '{selected_schema}' schema.\nDo you want to proceed?")
    else:
        selected_db.has_installation = True
        qgispkg_has_views= has_schema_views(dbLoader,selected_schema)
    #NOTE: TODO need to check also for materialised views, functions and triggers are OK

        if qgispkg_has_views:
            dbLoader.dlg.lblInstall_out.setText(success_html.format('qgis_pkg is already installed!'))
            dbLoader.connection_status['Install']=True
        elif has_qgispkg and not qgispkg_has_views: 
            dbLoader.dlg.lblInstall_out.setText(crit_warning_html.format(f'qgis_pkg is already installed but NOT for {selected_schema}!\n\tRequires installation!'))
            dbLoader.connection_status['Install']=False
            return installation_query(dbLoader,f"'qgis_pkg' needs to be enhanced with contents mapping '{selected_schema}' schema.\nDo you want to proceed?")

    return True

def gbxUserType_setup(dbLoader,user_type):
    print(f'I am {user_type}')
    selected_db=dbLoader.dlg.cbxExistingConnection.currentData()
    selected_schema=dbLoader.dlg.cbxSchema.currentText()
    reset_importTab(dbLoader)
    
    dbLoader.dlg.tabImport.setDisabled(False)
    dbLoader.dlg.lblDbSchema.setText(dbLoader.dlg.lblDbSchema.init_text.format(Database=selected_db.database_name,Schema=selected_schema))
    dbLoader.dlg.lblDbSchema.setDisabled(False)

    settingsTab_setup(dbLoader,user_type)
    


    dbLoader.dlg.wdgMain.setCurrentIndex(1)

def settingsTab_setup(dbLoader,user_type):
    selected_db=dbLoader.dlg.cbxExistingConnection.currentData()
    selected_schema=dbLoader.dlg.cbxSchema.currentText()



    if user_type=='Viewer':        
        reset_settingsTab(dbLoader)

    elif user_type=='Editor':
        dbLoader.dlg.btnInstallDB.setText(dbLoader.dlg.btnInstallDB.init_text.format(DB=selected_db.database_name,SC=selected_schema))
        dbLoader.dlg.btnInstallDB.setDisabled(False)

        dbLoader.dlg.btnUnInstallDB.setText(dbLoader.dlg.btnUnInstallDB.init_text.format(DB=selected_db.database_name,SC=selected_schema))
        dbLoader.dlg.btnUnInstallDB.setDisabled(False)

        dbLoader.dlg.btnClearDB.setText(dbLoader.dlg.btnClearDB.init_text.format(DB=selected_db.database_name))
        dbLoader.dlg.btnClearDB.setDisabled(False)
   
        dbLoader.dlg.btnRefreshViews.setText(dbLoader.dlg.btnRefreshViews.init_text.format(DB=selected_db.database_name,SC=selected_schema))
        dbLoader.dlg.btnRefreshViews.setDisabled(False)

def reset_importTab(dbLoader):
    selected_db=dbLoader.dlg.cbxExistingConnection.currentData()
    selected_schema=dbLoader.dlg.cbxSchema.currentText()

    dbLoader.dlg.tabImport.setDisabled(True)
    dbLoader.dlg.lblDbSchema.setText(dbLoader.dlg.lblDbSchema.init_text)

def reset_settingsTab(dbLoader):

    dbLoader.dlg.btnInstallDB.setDisabled(True)
    dbLoader.dlg.btnInstallDB.setText(dbLoader.dlg.btnInstallDB.init_text)
    dbLoader.dlg.btnUnInstallDB.setDisabled(True)
    dbLoader.dlg.btnUnInstallDB.setText(dbLoader.dlg.btnUnInstallDB.init_text)
    dbLoader.dlg.btnClearDB.setDisabled(True)
    dbLoader.dlg.btnClearDB.setText(dbLoader.dlg.btnClearDB.init_text)
    dbLoader.dlg.btnRefreshViews.setDisabled(True)
    dbLoader.dlg.btnRefreshViews.setText(dbLoader.dlg.btnRefreshViews.init_text)
    #dbLoader.dlg.grbExtent.setDisabled(True)
    #dbLoader.dlg.qgrbExtent.c
    

def refreshViews_setup(dbLoader):
    cur = dbLoader.conn.cursor()
    message= "This is going to take a while! Do you want to proceed?"
    res= QMessageBox.question(dbLoader.dlg,"Refreshing Views", message)
    
    if res == 16384: #YES   
        refresh_views_thread(dbLoader,cursor=cur)

        
def InstallDB_setup(dbLoader):
    selected_db=dbLoader.dlg.cbxExistingConnection.currentData()
    cur = dbLoader.conn.cursor()
    upd_conn_file(dbLoader) #Prepares installation scripts with the connection parameters 
    
    success = install(dbLoader, origin=dbLoader.dlg.lblLoadingInstall)
    if success: 
        selected_db.has_installation = True
        dbLoader.connection_status['Install']=True
        if not dbLoader.plugin_package in dbLoader.schemas: dbLoader.schemas.append(dbLoader.plugin_package)
    else:    
        dbLoader.connection_status['Install']=False
        dbLoader.dlg.btnClearDB.setDisabled(False)
        dbLoader.dlg.btnClearDB.setDefault(True)
        dbLoader.dlg.btnClearDB.setText(f'Clear corrupted installation!')  
        dbLoader.dlg.wdgMain.setCurrentIndex(2)            
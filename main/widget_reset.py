"""reset  docsting"""

#### Connection tab ##############################################
def reset_tabConnection(dbLoader):
    reset_gbxUserType(dbLoader)
    reset_gbxConnectionStatus(dbLoader)
    reset_gbxDatabase(dbLoader)

def reset_gbxDatabase(dbLoader):
    dbLoader.dlg.cbxSchema.clear()
    dbLoader.dlg.cbxSchema.setDisabled(True)
    dbLoader.dlg.lblSchema.setDisabled(True)

def reset_gbxConnectionStatus(dbLoader):
    dbLoader.dlg.gbxConnectionStatus.setDisabled(True)
    dbLoader.dlg.lblConnectedToDB_out.clear()
    dbLoader.dlg.lblServerVersion_out.clear()
    dbLoader.dlg.lblUserPrivileges_out.clear()
    dbLoader.dlg.lbl3DCityDBVersion_out.clear()
    dbLoader.dlg.lblInstall.setText(dbLoader.dlg.lblInstall.init_text)
    dbLoader.dlg.lblInstall_out.clear()

def reset_gbxUserType(dbLoader):
    dbLoader.dlg.gbxUserType.setDisabled(True)
    if dbLoader.dlg.buttonGroup.checkedButton():
        dbLoader.dlg.buttonGroup.setExclusive(False)
        dbLoader.dlg.buttonGroup.checkedButton().setChecked(False)
        dbLoader.dlg.buttonGroup.setExclusive(True)


#### Import tab #############################################
def reset_tabImport(dbLoader):
    dbLoader.dlg.tabImport.setDisabled(True)
    reset_gbxFeatures(dbLoader)
    reset_gbxParameters(dbLoader)
    reset_gbxExtent(dbLoader)
    reset_lblDbSchema(dbLoader)

def reset_lblDbSchema(dbLoader):
    dbLoader.dlg.lblDbSchema.setText(dbLoader.dlg.lblDbSchema.init_text)
    dbLoader.dlg.lblDbSchema.setDisabled(True)

def reset_gbxExtent(dbLoader):
    dbLoader.dlg.gbxExtent.setDisabled(True)
   

def reset_gbxParameters(dbLoader):
    dbLoader.dlg.gbxParameters.setDisabled(True)
    dbLoader.dlg.cbxFeatureType.clear()
    dbLoader.dlg.cbxLod.clear()

def reset_gbxFeatures(dbLoader):
    dbLoader.dlg.gbxFeatures.setDisabled(True)
    dbLoader.dlg.ccbxFeatures.clear()
    dbLoader.dlg.btnImport.setText(dbLoader.dlg.btnImport.init_text)


#### Settings tab ################################################################# 
def reset_tabSettings(dbLoader):
    dbLoader.dlg.tabSettings.setDisabled(True)
    reset_gbxDatabaseSettings(dbLoader)
    reset_gbxInstall(dbLoader)

def reset_gbxInstall(dbLoader):
    dbLoader.dlg.btnInstallDB.setDisabled(True)
    dbLoader.dlg.btnInstallDB.setText(dbLoader.dlg.btnInstallDB.init_text)

    dbLoader.dlg.btnUnInstallDB.setDisabled(True)
    dbLoader.dlg.btnUnInstallDB.setText(dbLoader.dlg.btnUnInstallDB.init_text)

    dbLoader.dlg.btnClearDB.setDisabled(True)
    dbLoader.dlg.btnClearDB.setText(dbLoader.dlg.btnClearDB.init_text)

def reset_gbxDatabaseSettings(dbLoader):
    dbLoader.dlg.btnRefreshViews.setDisabled(True)
    dbLoader.dlg.btnRefreshViews.setText(dbLoader.dlg.btnRefreshViews.init_text)
"""This module contains reset functions for each QT widgets.

The logic behind all of the functions is to reset widgets as individual
objects or as block of objects, depending on the needs.

The reset functions consist of clearing text or changed text to original state,
clearing widget items or selections and deactivating widgets.
"""
from ....cdb_tools_main import CDBToolsMain # Used only to add the type of the function parameters

#############################################
# Reset widget functions
#############################################

def tabSettings_reset(cdbMain: CDBToolsMain) -> None:
    """Function to reset the 'Settings' tab
    """
    dlg = cdbMain.admin_dlg
    
    dlg.tabSettings.setDisabled(True)
    gbxDefaultUsers_reset(cdbMain)
    dlg.btnResetToDefault.setDisabled(True)
    #dlg.btnSaveSettings.setDisabled(True)
    #dlg.btnLoadSettings.setDisabled(True)

def gbxDefaultUsers_reset(cdbMain: CDBToolsMain) -> None:
    """Function to reset the 'Default Users' groupBox
    """
    dlg = cdbMain.admin_dlg

    dlg.gbxDefaultUsers.setDisabled(True)
    dlg.ckbUserRO.setChecked(dlg.settings.enable_ro_user_default)
    dlg.ckbUserROAccess.setChecked(dlg.settings.enable_ro_user_access_default)
    dlg.ckbUserRW.setChecked(dlg.settings.enable_rw_user_default)
    dlg.ckbUserRWAccess.setChecked(dlg.settings.enable_rw_user_access_default)

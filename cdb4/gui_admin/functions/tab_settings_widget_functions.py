"""This module contains reset functions for each QT widgets.

The logic behind all of the functions is to reset widgets as individual
objects or as block of objects, depending on the needs.

The reset functions consist of clearing text or changed text to original state,
clearing widget items or selections and deactivating widgets.
"""
from __future__ import annotations
from typing import TYPE_CHECKING  #, Union
if TYPE_CHECKING:       
    from ...gui_admin.admin_dialog import CDB4AdminDialog

#############################################
# Reset widget functions
#############################################

def tabSettings_reset(dlg: CDB4AdminDialog) -> None:
    """Function to reset the 'Settings' tab
    """
    dlg.tabSettings.setDisabled(True)
    gbxDefaultUsers_reset(dlg)
    dlg.btnResetToDefault.setDisabled(True)
    #dlg.btnSaveSettings.setDisabled(True)
    #dlg.btnLoadSettings.setDisabled(True)

def gbxDefaultUsers_reset(dlg: CDB4AdminDialog) -> None:
    """Function to reset the 'Default Users' groupBox
    """
    dlg.gbxDefaultUsers.setDisabled(True)
    dlg.ckbUserRO.setChecked(dlg.settings.enable_ro_user_default)
    dlg.ckbUserROAccess.setChecked(dlg.settings.enable_ro_user_access_default)
    dlg.ckbUserRW.setChecked(dlg.settings.enable_rw_user_default)
    dlg.ckbUserRWAccess.setChecked(dlg.settings.enable_rw_user_access_default)

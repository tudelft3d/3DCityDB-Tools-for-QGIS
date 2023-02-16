"""This module contains reset functions for each QT widgets.

The logic behind all of the functions is to reset widgets as individual
objects or as block of objects, depending on the needs.

The reset functions consist of clearing text or changed text to original state,
clearing widget items or selections and deactivating widgets.
"""
from __future__ import annotations
from typing import TYPE_CHECKING
if TYPE_CHECKING:       
    from ...gui_admin.admin_dialog import CDB4AdminDialog

from qgis.PyQt.QtGui import QIcon

from . import sql
from . import tab_install_widget_functions as ti_wf
from . import tab_settings_widget_functions as ts_wf

#############################################
# Set up widget functions
#############################################

def fill_database_users_box(dlg: CDB4AdminDialog, usr_names: tuple = None) -> None:
    """Function to reset the combobox containing the list of users.
    """
    usr_icon = QIcon(":/plugins/citydb_loader/icons/user.svg")

    # Clean combo box from previous leftovers.
    dlg.cbxSelUser4Grp.clear()

    if not usr_names:
        # Add this placeholder to show that there are none
        dlg.cbxSelUser4Grp.addItem(usr_icon, 'None available')
        # Disable the combobox
        dlg.cbxSelUser4Grp.setDisabled(True)
        # Disable the associated button
        dlg.btnAddUserToGrp.setDisabled(True)
    else:
        for usr_name in usr_names:
            dlg.cbxSelUser4Grp.addItem(usr_icon, usr_name)
        if not dlg.cbxSelUser4Grp.isEnabled():
            # Enable the combobox 
            dlg.cbxSelUser4Grp.setDisabled(False)
            # Enable the associated button
            dlg.btnAddUserToGrp.setDisabled(False)


def fill_plugin_users_box(dlg: CDB4AdminDialog, usr_names: tuple = None) -> None:
    """Function to reset the combobox (drop down menu) containing the list of plugin users
    and the associated remove user from group.
    """
    usr_icon = QIcon(":/plugins/citydb_loader/icons/user.svg")

    # Clean combo box from previous leftovers.
    dlg.cbxUser.clear()
    # Disable the "Remove from group" button from previous runs 
    dlg.btnRemoveUserFromGrp.setDisabled(True)

    if not usr_names:
        # Add this placeholder to show that there are none
        dlg.cbxUser.addItem(usr_icon, 'None available')
        # Disable the combobox
        dlg.cbxUser.setDisabled(True)
        # Disable the remove user button
        dlg.btnRemoveUserFromGrp.setDisabled(True)       
    else:
        for usr_name in usr_names:
            dlg.cbxUser.addItem(usr_icon, usr_name)

        if not dlg.cbxUser.isEnabled():
            # Enable the combobox 
            dlg.cbxUser.setDisabled(False)
    
    return None


def fill_cdb_schemas_box(dlg: CDB4AdminDialog, cdb_schemas_with_priv: list = None) -> None:
    """Function that fills the 'Citydb schema(s)' checkable combo box.
    """
    # Clean combo box from previous leftovers.
    dlg.ccbSelCDBSch.clear()
    dlg.ccbSelCDBSch.setDefaultText('Select schema(s)')

    if not cdb_schemas_with_priv:
        dlg.ccbSelCDBSch.setDefaultText('None available')
        # Disable the combobox
        dlg.ccbSelCDBSch.setDisabled(True) 
    else:
        for cdb_schema in cdb_schemas_with_priv:
            dlg.ccbSelCDBSch.addItemWithCheckState(
                text=f"{cdb_schema.cdb_schema} ({cdb_schema.priv_type})", # Must be a string! ;-)
                state=0,
                userData=f"{cdb_schema.cdb_schema}") # Must put it here, as the gen_sh.function retrieves this field
        if dlg.ckbSelAllCDBSch.isChecked():
            # Disable the check all
            dlg.ckbSelAllCDBSch.setChecked(False)
        if not dlg.ccbSelCDBSch.isEnabled():
            # Enable the combobox
            dlg.ccbSelCDBSch.setDisabled(False)
    
    # REMEMBER: don't use method 'setSeparator', it adds a custom separator to join string of selected items
    return None


def setup_post_qgis_pkg_installation(dlg: CDB4AdminDialog) -> None:
    """ Function to set up the widgets after:
        - The existence of the qgis_pkg has been checked upon (re)load of the GUI 
            AND
          the current version of the QGIS package is supported
        - After the qgis_pkg has been successfully installed
    """
    # Disable the install button
    dlg.btnMainInst.setDisabled(True)
    # Enable the uninstall button
    dlg.btnMainUninst.setDisabled(False)

    # Reset and Disable the Settings Tab
    ts_wf.tabSettings_reset(dlg) # This also disables it

    # Reset the user installation GroupBox
    ti_wf.gbxUserInst_reset(dlg)

    # Enable the User Installation Group box
    dlg.gbxUserInstCont.setDisabled(False)

    # 1) Users and group membership 

    # Enable the User selection Group Box (Group Membership)
    dlg.gbxGroupMemb.setDisabled(False)

    # Get the database users not belonging to the qgis_pkg_usrgroup
    db_usr_names: tuple = sql.exec_list_qgis_pkg_non_usrgroup_members(dlg)
    # print('Database members:', db_usr_names)

    # Fill and enable the combobox in Group Membership group
    # Depending on whether the tuple is populated or not,
    # the function fills the names and activates the relative button
    # Otherwise it keeps itself and the button disabled 
    ti_wf.fill_database_users_box(dlg, db_usr_names)

    # 2) User schema creation 
    # Fill the combobox with the list of plugin users (i.e. members of the group)

    # Enable the User Schema Installation Group Box (User Installation)
    dlg.gbxUserInst.setDisabled(False)

    # Get users belonging to the group 'qgis_pkg_usrgroup_*' from current database.
    # The superuser will always be member of it, as it cannot kick itself out
    # when it removes people from the group 
    usr_names_plugin: tuple = sql.exec_list_qgis_pkg_usrgroup_members(dlg)
    # print('Group members:', usr_names_plugin)

    # Clear the combobox with the user
    # Set up/fill the combobox of the plugin users
    # Upon filling it, an event is fired (evt_cbxPluginUser_changed) that
    # checks whether the user schema has already been created or not

    ti_wf.fill_plugin_users_box(dlg, usr_names_plugin)

    # 3) User privileges settings
    # This is taken care of from the evt_cbxPluginUser_changed() event, as it applied only to
    # users for whom the usr_schema has already been created

    return None


def setup_post_qgis_pkg_uninstallation(dlg: CDB4AdminDialog) -> None:
    """ Function to set up the widgets after:
        - The NON existence of the qgis_pkg has been checked upon (re)load of the GUI
        - A failed QGIS Package installation
        - A successful QGIS Package uninstallation
    """
    # Enable the QGIS Package Install button
    dlg.btnMainInst.setDisabled(False)
    # Disable the QGIS Package Uninstall button
    dlg.btnMainUninst.setDisabled(True)

    # Reset and disable the User Installation groupbox (in Installation Tab)
    ti_wf.gbxUserInst_reset(dlg) # this also disables it
    # Reset the Settings tab
    ts_wf.tabSettings_reset(dlg) # this also disables it

    # Enable the Settings tab
    dlg.tabSettings.setDisabled(False)
    dlg.gbxDefaultUsers.setDisabled(False)
    dlg.btnResetToDefault.setDisabled(False)
   
    return None

#############################################
# Reset widget functions
#############################################

def tabInstall_reset(dlg: CDB4AdminDialog) -> None:
    """Function to reset the 'Settings' tab. Resets: gbxInstall and lblInfoText.
    """
    gbxMainInst_reset(dlg)
    gbxUserInst_reset(dlg)
    gbxConnStatus_reset(dlg)


def gbxMainInst_reset(dlg: CDB4AdminDialog) -> None:
    """Function to reset the 'Main Installation' groupBox
    """
    dlg.gbxMainInst.setDisabled(True)
    dlg.btnMainInst.setText(dlg.btnMainInst.init_text)
    dlg.btnMainUninst.setText(dlg.btnMainUninst.init_text)


def gbxUserInst_reset(dlg: CDB4AdminDialog) -> None:
    """Function to reset the 'User Installation Group membership' groupBox
    """
    dlg.gbxUserInst.setDisabled(True)
    gbxGroupMemb_reset(dlg)
    gbxUserSchemaInst_reset(dlg)
    gbxPriv_reset(dlg)


def gbxGroupMemb_reset(dlg: CDB4AdminDialog) -> None:
    """Function to reset the 'Group membership' groupBox
    """
    dlg.gbxGroupMemb.setDisabled(True)
    dlg.cbxSelUser4Grp.clear()
    dlg.cbxSelUser4Grp.setDisabled(False)
    dlg.btnAddUserToGrp.setDisabled(False)


def gbxUserSchemaInst_reset(dlg: CDB4AdminDialog) -> None:
    """Function to reset the 'User Installation' groupBox
    """
    dlg.gbxUserInst.setDisabled(True)
    dlg.btnRemoveUserFromGrp.setDisabled(False)
    #dlg.btnUsrInst.setText(dlg.btnUsrInst.init_text)
    #dlg.btnUsrUninst.setText(dlg.btnUsrUninst.init_text)
    dlg.cbxUser.clear()


def gbxPriv_reset(dlg: CDB4AdminDialog) -> None:
    """Function to reset the 'Database privileges' groupBox
    """
    dlg.gbxPriv.setDisabled(True)
    dlg.ccbSelCDBSch.clear() # This clears also the default text
    dlg.ccbSelCDBSch.setDefaultText('Select schema(s)')
    dlg.ckbSelAllCDBSch.setChecked(False)


def gbxConnStatus_reset(dlg: CDB4AdminDialog) -> None:
    """Function to reset the 'Connection status' groupbox
    """
    dlg.gbxConnStatus.setDisabled(True)
    dlg.lblConnToDb_out.clear()
    dlg.lblPostInst_out.clear()
    dlg.lblUserPrivileges_out.clear()
    dlg.lbl3DCityDBInst_out.clear()
    dlg.lblMainInst_out.clear()
    dlg.lblUserInst_out.clear()

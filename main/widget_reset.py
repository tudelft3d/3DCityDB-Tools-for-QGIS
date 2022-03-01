"""This module contains reset functions for each QT widget in the GUI of the
plugin.

The logic behind all of the functions is to reset widgets as individual
objects or as block of objects, depending on the needs.

These function help declutter the widget_setup.py from repetitive code.

The reset functions consist of clearing text or changed text to original state,
clearing widget items or selections and deacivating widgets."""


# Connection tab
def reset_tabConnection(dbLoader) -> None:
    """Function to reset the 'Connection' tab.
    Resets: gbxUserType, gbxConnectionStatus and gbxDatabase.
    """
    reset_gbxUserType(dbLoader)
    reset_gbxConnectionStatus(dbLoader)
    reset_gbxDatabase(dbLoader)

def reset_gbxDatabase(dbLoader) -> None:
    """Function to reset the 'Database' groupbox (in Connection tab)."""

    dbLoader.dlg.cbxSchema.clear()
    dbLoader.dlg.cbxSchema.setDisabled(True)
    dbLoader.dlg.lblSchema.setDisabled(True)

def reset_gbxConnectionStatus(dbLoader) -> None:
    """Function to reset the 'Connection status' groupbox
    (in Connection tab).
    """

    dbLoader.dlg.gbxConnectionStatus.setDisabled(True)
    dbLoader.dlg.lblConnectedToDB_out.clear()
    dbLoader.dlg.lblServerVersion_out.clear()
    dbLoader.dlg.lblUserPrivileges_out.clear()
    dbLoader.dlg.lbl3DCityDBVersion_out.clear()
    dbLoader.dlg.lblInstall.setText(dbLoader.dlg.lblInstall.init_text)
    dbLoader.dlg.lblInstall_out.clear()

def reset_gbxUserType(dbLoader) -> None:
    """Function to reset the 'UserType' groupbox (in Connection tab)."""

    dbLoader.dlg.gbxUserType.setDisabled(True)
    if dbLoader.dlg.buttonGroup.checkedButton():
        dbLoader.dlg.buttonGroup.setExclusive(False)
        dbLoader.dlg.buttonGroup.checkedButton().setChecked(False)
        dbLoader.dlg.buttonGroup.setExclusive(True)

# Import tab # TODO: create reset function for the basemap
def reset_tabImport(dbLoader) -> None:
    """Function to reset the 'Import' tab.
    Resets: gbxFeatures, gbxParameters, gbxExtent and lblDbSchema.
    """

    dbLoader.dlg.tabImport.setDisabled(True)
    reset_gbxFeatures(dbLoader)
    reset_gbxParameters(dbLoader)
    reset_gbxExtent(dbLoader)
    reset_lblDbSchema(dbLoader)

def reset_lblDbSchema(dbLoader) -> None:
    """Function to reset the 'DB and Schema' label (in Import tab)."""

    dbLoader.dlg.lblDbSchema.setText(dbLoader.dlg.lblDbSchema.init_text)
    dbLoader.dlg.lblDbSchema.setDisabled(True)

def reset_gbxExtent(dbLoader) -> None:
    """Function to reset the 'Extents' groupbox (in Import tab)."""

    dbLoader.dlg.gbxExtent.setDisabled(True)

def reset_gbxParameters(dbLoader) -> None:
    """Function to reset the 'Parameters' group box (in Import tab)."""

    dbLoader.dlg.gbxParameters.setDisabled(True)
    dbLoader.dlg.cbxFeatureType.clear()
    dbLoader.dlg.cbxLod.clear()

def reset_gbxFeatures(dbLoader) -> None:
    """Function to reset the 'Features to Import' group box (in Import tab)."""

    dbLoader.dlg.gbxFeatures.setDisabled(True)
    dbLoader.dlg.ccbxFeatures.clear()
    dbLoader.dlg.btnImport.setText(dbLoader.dlg.btnImport.init_text)


# Settings tab
def reset_tabSettings(dbLoader) -> None:
    """Function to reset the 'Settings' tab.
    Resets: gbxInstall and lblDbSchema.
    """

    dbLoader.dlg.tabSettings.setDisabled(True)
    reset_gbxDatabaseSettings(dbLoader)
    reset_gbxInstall(dbLoader)

def reset_gbxInstall(dbLoader) -> None:
    """Function to reset the 'Install' group box (in Settings tab)."""

    dbLoader.dlg.btnInstallDB.setDisabled(True)
    dbLoader.dlg.btnInstallDB.setText(dbLoader.dlg.btnInstallDB.init_text)

    dbLoader.dlg.btnUnInstallDB.setDisabled(True)
    dbLoader.dlg.btnUnInstallDB.setText(dbLoader.dlg.btnUnInstallDB.init_text)

    dbLoader.dlg.btnClearDB.setDisabled(True)
    dbLoader.dlg.btnClearDB.setText(dbLoader.dlg.btnClearDB.init_text)

def reset_gbxDatabaseSettings(dbLoader) -> None:
    """Function to reset the 'Database' group box (in Settings tab)."""

    dbLoader.dlg.btnRefreshViews.setDisabled(True)
    dbLoader.dlg.btnRefreshViews.setText(dbLoader.dlg.btnRefreshViews.init_text)

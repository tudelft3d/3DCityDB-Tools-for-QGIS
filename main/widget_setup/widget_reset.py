"""This module contains reset functions for each QT widget in the GUI of the
plugin.

The logic behind all of the functions is to reset widgets as individual
objects or as block of objects, depending on the needs.

These function help declutter the widget_setup.py from repetitive code.

The reset functions consist of clearing text or changed text to original state,
clearing widget items or selections and deacivating widgets."""

from qgis.core import QgsProject

from .. import constants as c

# 'User Connection' tab
def reset_tabConnection(dbLoader) -> None:
    """Function to reset the 'Connection' tab.
    Resets: gbxConnStatusC and gbxDatabase.
    """
    # Close the current open connection.
    if dbLoader.conn is not None:
        dbLoader.conn.close()
    reset_gbxDatabase(dbLoader)
    reset_gbxConnStatusC(dbLoader)
    reset_gbxBasemapC(dbLoader)
    reset_cgbxOptions(dbLoader)
    reset_btnCreateLayers(dbLoader)
    reset_btnRefreshLayers(dbLoader)
    reset_btnDropLayers(dbLoader)
    dbLoader.dlg.btnCloseConnC.setDisabled(True)

def reset_gbxDatabase(dbLoader) -> None:
    """Function to reset the 'Database' groupbox (in Connection tab)."""

    dbLoader.dlg.cbxSchema.clear()
    dbLoader.dlg.cbxSchema.setDisabled(True)
    dbLoader.dlg.lblSchema.setDisabled(True)

def reset_gbxConnStatusC(dbLoader) -> None:
    """Function to reset the 'Connection status' groupbox
    (in Connection tab).
    """

    dbLoader.dlg.gbxConnStatusC.setDisabled(True)
    dbLoader.dlg.lblConnToDbC_out.clear()
    dbLoader.dlg.lblPostInstC_out.clear()
    dbLoader.dlg.lbl3DCityDBInstC_out.clear()
    dbLoader.dlg.lblMainInstC_out.clear()
    dbLoader.dlg.lblUserInstC_out.clear()
    dbLoader.dlg.lblSupport_out.clear()
    dbLoader.dlg.lblLayerRefr_out.clear()

def reset_gbxBasemapC(dbLoader) -> None:
    """Function to reset the 'Basemap (OSM)' groupbox
    (in 'User Connection' tab).
    """

    dbLoader.dlg.gbxBasemapC.setDisabled(True)
    dbLoader.dlg.btnCityExtentsC.setText(dbLoader.dlg.btnCityExtentsC.init_text)

    # Remove extent rubber bands.
    dbLoader.RUBBER_SCHEMA_C.reset()
    dbLoader.RUBBER_LAYERS_C.reset()
    dbLoader.RUBBER_USER.reset()

    # Clear map registry from OSM layers.
    registryLayers = [i.id() for i in QgsProject.instance().mapLayers().values() if c.OSM_NAME == i.name()]
    QgsProject.instance().removeMapLayers(registryLayers)
    # Refresh to show to rerender the canvas (as empty).
    dbLoader.CANVAS_C.refresh()

def reset_cgbxOptions(dbLoader) -> None:
    """Function to reset the 'Advanced option' groupbox
    (in 'User Connection' tab).
    """
    dbLoader.dlg.cgbxOptions.setCollapsed(True)
    dbLoader.dlg.cgbxOptions.setDisabled(True)
    reset_gbxSimplifyGeom(dbLoader)


def reset_gbxSimplifyGeom(dbLoader) -> None:
    """Function to reset the 'Simplify geometries' groupbox
    (in 'User Connection' tab).
    """
    dbLoader.dlg.gbxSimplifyGeom.setChecked(False)
    dbLoader.dlg.qspbDecimalPrec.setValue(c.DEC_PREC)
    dbLoader.dlg.qspbMinArea.setValue(c.MIN_AREA)

def reset_btnCreateLayers(dbLoader) -> None:
    """Function to reset the 'Create layers' pushButton (in 'User Connection' tab)."""

    dbLoader.dlg.btnCreateLayers.setDisabled(True)
    dbLoader.dlg.btnCreateLayers.setText(dbLoader.dlg.btnCreateLayers.init_text)

def reset_btnRefreshLayers(dbLoader) -> None:
    """Function to reset the 'Refresh layers' pushButton (in 'User Connection' tab)."""

    dbLoader.dlg.btnRefreshLayers.setDisabled(True)
    dbLoader.dlg.btnRefreshLayers.setText(dbLoader.dlg.btnRefreshLayers.init_text)

def reset_btnDropLayers(dbLoader) -> None:
    """Function to reset the 'Drop layers' pushButton (in 'User Connection' tab)."""

    dbLoader.dlg.btnDropLayers.setDisabled(True)
    dbLoader.dlg.btnDropLayers.setText(dbLoader.dlg.btnDropLayers.init_text)


# Import tab # TODO: create reset function for the basemap
def reset_tabLayers(dbLoader) -> None:
    """Function to reset the 'Import' tab.
    Resets: gbxAvailableL, gbxLayerSelection, gbxExtent and lblInfoText.
    """

    dbLoader.dlg.tabLayers.setDisabled(True)
    reset_gbxAvailableL(dbLoader)
    reset_gbxLayerSelection(dbLoader)
    reset_gbxBasemap(dbLoader)
    reset_lblInfoText(dbLoader)

def reset_lblInfoText(dbLoader) -> None:
    """Function to reset the 'DB and Schema' label (in Import tab)."""

    dbLoader.dlg.lblInfoText.setText(dbLoader.dlg.lblInfoText.init_text)
    dbLoader.dlg.lblInfoText.setDisabled(True)

def reset_gbxBasemap(dbLoader) -> None:
    """Function to reset the 'Extents' groupbox (in Import tab)."""

    dbLoader.dlg.qgbxExtents.setDisabled(True)

    # Remove extent rubber bands.
    dbLoader.RUBBER_SCHEMA.reset()
    dbLoader.RUBBER_LAYERS.reset()
    dbLoader.RUBBER_USER.reset()

def reset_gbxLayerSelection(dbLoader) -> None:
    """Function to reset the 'Parameters' group box (in Import tab)."""

    dbLoader.dlg.gbxLayerSelection.setDisabled(True)
    dbLoader.dlg.cbxFeatureType.clear()
    dbLoader.dlg.cbxLod.clear()

def reset_gbxAvailableL(dbLoader) -> None:
    """Function to reset the 'Features to Import' group box (in Import tab)."""

    dbLoader.dlg.gbxAvailableL.setDisabled(True)
    dbLoader.dlg.ccbxFeatures.clear()


# Settings tab
def reset_tabDbAdmin(dbLoader) -> None:
    """Function to reset the 'Settings' tab.
    Resets: gbxInstall and lblInfoText.
    """

    # Close the current open connection.
    if dbLoader.conn is not None:
        dbLoader.conn.close()
    reset_gbxMainInst(dbLoader)
    reset_gbxUserInst(dbLoader)
    reset_gbxConnStatus(dbLoader)
    dbLoader.dlg_admin.btnCloseConn.setDisabled(True)

def reset_gbxMainInst(dbLoader) -> None:
    """Function to reset the 'Main Installation' groupBox
    (in Database Administration tab)."""

    dbLoader.dlg_admin.gbxMainInst.setDisabled(True)
    dbLoader.dlg_admin.btnMainInst.setText(dbLoader.dlg_admin.btnMainInst.init_text)
    dbLoader.dlg_admin.btnMainUninst.setText(dbLoader.dlg_admin.btnMainUninst.init_text)

def reset_gbxUserInst(dbLoader) -> None:
    """Function to reset the 'User Installation' groupBox
    (in Database Administration tab)."""
    
    dbLoader.dlg_admin.gbxUserInst.setDisabled(True)
    dbLoader.dlg_admin.btnUsrInst.setText(dbLoader.dlg_admin.btnUsrInst.init_text)
    dbLoader.dlg_admin.btnUsrUninst.setText(dbLoader.dlg_admin.btnUsrUninst.init_text)
    dbLoader.dlg_admin.cbxUser.clear()


def reset_gbxConnStatus(dbLoader) -> None:
    """Function to reset the 'Connection status' groupbox
    (in  Database Administration tab).
    """

    dbLoader.dlg_admin.gbxConnStatus.setDisabled(True)
    dbLoader.dlg_admin.lblConnToDb_out.clear()
    dbLoader.dlg_admin.lblPostInst_out.clear()
    dbLoader.dlg_admin.lbl3DCityDBInst_out.clear()
    dbLoader.dlg_admin.lblMainInst_out.clear()
    dbLoader.dlg_admin.lblUserInst_out.clear()

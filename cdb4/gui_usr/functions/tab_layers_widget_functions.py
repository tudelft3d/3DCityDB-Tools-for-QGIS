"""This module contains reset functions for each QT widget in the GUI of the
plugin.

The logic behind all of the functions is to reset widgets as individual
objects or as block of objects, depending on the needs.

These function help declutter the widget_setup.py from repetitive code.

The reset functions consist of clearing text or changed text to original state,
clearing widget items or selections and deactivating widgets.
"""

#from qgis.core import Qgis, QgsMessageLog 
from qgis.PyQt.QtCore import Qt

from ....cdb_loader import CDBLoader # Used only to add the type of the function parameters
from ... import cdb4_constants as c
from . import canvas

FILE_LOCATION = c.get_file_relative_path(file=__file__)

####################################################
## Setup widget functions for 'Layer' tab
####################################################

# In 'Basemap (OMS)' groupBox.
def gbxBasemap_setup(cdbLoader: CDBLoader, canvas_widget) ->  None:
    """Function to setup the 'Basemap' groupbox.
    It uses an additional canvas instance to store an OSM map
    from which extents can be extracted for further spatial queries.

    The basemap is zoomed-in the city model's extents.

    (in 'Layers' tab)

    .. While this function is almost identical to the one handling the
    canvas in the User Connection tab, I think, it is prudent to duplicate
    for better debugging comprehension.
    """

    # Put extents coordinates into the widget.
    #cdbLoader.usr_dlg.qgbxExtentsC.setOutputExtentFromUser(cdbLoader.CDB_SCHEMA_EXTENTS, cdbLoader.CRS)

    # Set basemap.
    canvas.canvas_setup(
        cdbLoader,
        canvas=canvas_widget,
        #extents=cdbLoader.CDB_SCHEMA_EXTENTS,
        extents=cdbLoader.LAYER_EXTENTS,        
        crs=cdbLoader.CRS,
        clear=False)

    # Draw rubberband for extents of selected {cdb_schema}.
    canvas.insert_rubber_band(
        band=cdbLoader.RUBBER_SCHEMA,
        extents=cdbLoader.CDB_SCHEMA_EXTENTS,
        crs=cdbLoader.CRS,
        width=3,
        color=Qt.blue)

    # Draw rubberband for extents of materialized views in selected {cdb_schema}.
    canvas.insert_rubber_band(
        band=cdbLoader.RUBBER_LAYERS,
        extents=cdbLoader.LAYER_EXTENTS,
        crs=cdbLoader.CRS,
        width=2,
        color=Qt.red)

    # Zoom to layer extents.
    canvas_widget.zoomToFeatureExtent(cdbLoader.LAYER_EXTENTS)

    # Draw the extents in the canvas
    # Create polygon rubber band corresponding to the extents
    canvas.insert_rubber_band(
        band=cdbLoader.RUBBER_USER,
        extents=cdbLoader.CURRENT_EXTENTS,
        crs=cdbLoader.CRS,
        width=1,
        color=Qt.green)


####################################################
## Reset widget functions for 'Layer' tab
####################################################

# Import tab # TODO: create reset function for the basemap
def tabLayers_reset(cdbLoader: CDBLoader) -> None:
    """Function to reset the 'Import' tab.
    Resets: gbxAvailableL, gbxLayerSelection, gbxExtent and lblInfoText.
    """
    cdbLoader.usr_dlg.tabLayers.setDisabled(True)
    gbxAvailableL_reset(cdbLoader)
    gbxLayerSelection_reset(cdbLoader)
    gbxBasemap_reset(cdbLoader)
    lblInfoText_reset(cdbLoader)


def lblInfoText_reset(cdbLoader: CDBLoader) -> None:
    """Function to reset the 'DB and Schema' label (in Layers tab)."""

    cdbLoader.usr_dlg.lblInfoText.setText(cdbLoader.usr_dlg.lblInfoText.init_text)
    cdbLoader.usr_dlg.lblInfoText.setDisabled(True)


def gbxBasemap_reset(cdbLoader: CDBLoader) -> None:
    """Function to reset the 'Extents' groupbox (in Layers tab)."""

    cdbLoader.usr_dlg.qgbxExtents.setDisabled(True)

    # Remove extent rubber bands.
    cdbLoader.RUBBER_SCHEMA.reset()
    cdbLoader.RUBBER_LAYERS.reset()
    cdbLoader.RUBBER_USER.reset()


def gbxLayerSelection_reset(cdbLoader: CDBLoader) -> None:
    """Function to reset the 'Parameters' group box (in Layers tab)."""

    cdbLoader.usr_dlg.gbxLayerSelection.setDisabled(True)
    cdbLoader.usr_dlg.cbxFeatureType.clear()
    cdbLoader.usr_dlg.cbxLod.clear()


def gbxAvailableL_reset(cdbLoader: CDBLoader) -> None:
    """Function to reset the 'Features to Import' group box (in Layers tab)."""

    cdbLoader.usr_dlg.gbxAvailableL.setDisabled(True)
    cdbLoader.usr_dlg.ccbxFeatures.clear()


"""This module contains reset functions for each QT widget in the GUI of the plugin.

The logic behind all of the functions is to reset widgets as individual
objects or as block of objects, depending on the needs.

The reset functions consist of clearing text or changed text to original state,
clearing widget items or selections and deactivating widgets.
"""

#from qgis.core import Qgis, QgsMessageLog 
from qgis.PyQt.QtCore import Qt

from ....cdb_loader import CDBLoader # Used only to add the type of the function parameters
from ...shared.functions import general_functions as gen_f
from . import canvas

FILE_LOCATION = gen_f.get_file_relative_path(file=__file__)

####################################################
## Setup widget functions for 'Layer' tab
####################################################

# In 'Basemap (OMS)' groupBox.
def gbxBasemap_setup(cdbLoader: CDBLoader) ->  None:
    """Function to setup the 'Basemap' groupbox. It uses an additional canvas instance to store an OSM map
    from which extents can be extracted for further spatial queries.
    The basemap is zoomed-in to the city model's extents (in 'Layers' tab)
    """
    # Set basemap of the layer tab.
    canvas.canvas_setup(cdbLoader=cdbLoader, canvas=cdbLoader.CANVAS, extents=cdbLoader.LAYER_EXTENTS_RED, crs=cdbLoader.CRS, clear=False)

    # Draw rubberband for extents of selected {cdb_schema}.
    canvas.insert_rubber_band(band=cdbLoader.RUBBER_CDB_SCHEMA_BLUE, extents=cdbLoader.CDB_SCHEMA_EXTENTS_BLUE, crs=cdbLoader.CRS, width=3, color=Qt.blue)

    # Draw rubberband for extents of materialized views in selected {cdb_schema}.
    canvas.insert_rubber_band(band=cdbLoader.RUBBER_LAYERS_RED, extents=cdbLoader.LAYER_EXTENTS_RED, crs=cdbLoader.CRS, width=2, color=Qt.red)

    # Zoom to the layer extents (red box).
    canvas.zoom_to_extents(canvas=cdbLoader.CANVAS, extents=cdbLoader.LAYER_EXTENTS_RED)

    # Create polygon rubber band corresponding to the extents (the green one)
    canvas.insert_rubber_band(band=cdbLoader.RUBBER_QGIS_GREEN, extents=cdbLoader.CURRENT_EXTENTS, crs=cdbLoader.CRS, width=1, color=Qt.green)


####################################################
## Reset widget functions for 'Layer' tab
####################################################

def tabLayers_reset(cdbLoader: CDBLoader) -> None:
    """Function to reset the 'Import' tab.
    Resets: gbxAvailableL, gbxLayerSelection, gbxExtent and lblInfoText.
    """
    dlg = cdbLoader.usr_dlg

    dlg.tabLayers.setDisabled(True)
    gbxAvailableL_reset(cdbLoader)
    gbxLayerSelection_reset(cdbLoader)
    gbxBasemap_reset(cdbLoader)
    lblInfoText_reset(cdbLoader)


def lblInfoText_reset(cdbLoader: CDBLoader) -> None:
    """Function to reset the 'DB and Schema' label (in Layers tab).
    """
    dlg = cdbLoader.usr_dlg

    dlg.lblInfoText.setText(dlg.lblInfoText.init_text)
    dlg.lblInfoText.setDisabled(True)


def gbxBasemap_reset(cdbLoader: CDBLoader) -> None:
    """Function to reset the 'Extents' groupbox (in Layers tab).
    """
    dlg = cdbLoader.usr_dlg
    
    dlg.qgbxExtents.setDisabled(True)
    # Remove extent rubber bands.
    cdbLoader.RUBBER_CDB_SCHEMA_BLUE.reset()
    cdbLoader.RUBBER_LAYERS_RED.reset()
    cdbLoader.RUBBER_QGIS_GREEN.reset()


def gbxLayerSelection_reset(cdbLoader: CDBLoader) -> None:
    """Function to reset the 'Parameters' group box (in Layers tab).
    """
    dlg = cdbLoader.usr_dlg
    
    dlg.gbxLayerSelection.setDisabled(True)
    dlg.cbxFeatureType.clear()
    dlg.cbxLod.clear()


def gbxAvailableL_reset(cdbLoader: CDBLoader) -> None:
    """Function to reset the 'Features to Import' group box (in Layers tab).
    """
    dlg = cdbLoader.usr_dlg

    dlg.gbxAvailableL.setDisabled(True)
    dlg.ccbxFeatures.clear()


"""This module contains reset functions for each QT widgets.

The logic behind all of the functions is to reset widgets as individual
objects or as block of objects, depending on the needs.

The reset functions consist of clearing text or changed text to original state,
clearing widget items or selections and deactivating widgets.
"""
from __future__ import annotations
from typing import TYPE_CHECKING
if TYPE_CHECKING:       
    from ...gui_loader.loader_dialog import CDB4LoaderDialog

from ...shared.functions import general_functions as gen_f
from .. import loader_constants as c
from . import canvas

FILE_LOCATION = gen_f.get_file_relative_path(file=__file__)

####################################################
## Setup widget functions for 'Layer' tab
####################################################

def fill_CityGML_codelist_selection_box(dlg: CDB4LoaderDialog, CityGML_codelist_set_names: list = None) -> None:
    """Function that fills the 'Select CodeLists group' combo box.
    """
    # Clean combo box from previous leftovers.
    dlg.cbxCodeListSelCityGML.clear()

    if not CityGML_codelist_set_names:
        # Disable the combobox
        dlg.cbxCodeListSelCityGML.setDisabled(True)
        dlg.cbxCodeListSelCityGML.setDisabled(True)
    else:
        label: str = f"None"
        dlg.cbxCodeListSelCityGML.addItem(label, userData=label)
        for codelist_set_name in CityGML_codelist_set_names:
            label: str = f"{codelist_set_name}"
            dlg.cbxCodeListSelCityGML.addItem(label, userData=label)
        if not dlg.cbxCodeListSelCityGML.isEnabled():
            # Enable the combobox
            dlg.cbxCodeListSelCityGML.setDisabled(False)
            dlg.lblCodeListSelCityGML.setDisabled(False)
   
    # REMEMBER: don't use method 'setSeparator', it adds a custom separator to join string of selected items
    return None

# def fill_ADE_codelist_selection_box(dlg: CDB4LoaderDialog, ADE_codelist_set_names: list = None) -> None:
#     """Function that fills the 'Select CodeLists group' combo box.
#     """
#     # Clean combo box from previous leftovers.
#     dlg.cbxCodeListSelADE.clear()

#     if not ADE_codelist_set_names:
#         # Disable the combobox
#         dlg.cbxCodeListSelADE.setDisabled(True)
#         dlg.cbxCodeListSelADE.setDisabled(True)
#     else:
#         label: str = f"None"
#         dlg.cbxCodeListSelADE.addItem(label, userData=label)
#         for codelist_set_name in ADE_codelist_set_names:
#             label: str = f"{codelist_set_name}"
#             dlg.cbxCodeListSelADE.addItem(label, userData=label)
#         if not dlg.cbxCodeListSelADE.isEnabled():
#             # Enable the combobox
#             dlg.cbxCodeListSelADE.setDisabled(False)
#             dlg.lblCodeListSelADE.setDisabled(False)
   
    # REMEMBER: don't use method 'setSeparator', it adds a custom separator to join string of selected items
    return None


# In 'Basemap (OMS)' groupBox.
def gbxBasemapL_setup(dlg: CDB4LoaderDialog) ->  None:
    """Function to setup the 'Basemap' groupbox. It uses an additional canvas instance to store an OSM map
    from which extents can be extracted for further spatial queries.
    The basemap is zoomed-in to the city model's extents (in 'Layers' tab)
    """
    # Set basemap of the layer tab.
    canvas.canvas_setup(dlg=dlg, canvas=dlg.CANVAS_L, extents=dlg.LAYER_EXTENTS, crs=dlg.CRS, clear=False)

    # Draw rubberband for extents of selected {cdb_schema}.
    canvas.insert_rubber_band(band=dlg.RUBBER_CDB_SCHEMA_L, extents=dlg.CDB_SCHEMA_EXTENTS, crs=dlg.CRS, width=3, color=c.CDB_EXTENTS_COLOUR)

    # Draw rubberband for extents of materialized views in selected {cdb_schema}.
    canvas.insert_rubber_band(band=dlg.RUBBER_LAYERS_L, extents=dlg.LAYER_EXTENTS, crs=dlg.CRS, width=2, color=c.LAYER_EXTENTS_COLOUR)

    # Zoom to the layer extents
    canvas.zoom_to_extents(canvas=dlg.CANVAS_L, extents=dlg.LAYER_EXTENTS)

    # Create polygon rubber band corresponding to the QGIS extents
    canvas.insert_rubber_band(band=dlg.RUBBER_QGIS_L, extents=dlg.CURRENT_EXTENTS, crs=dlg.CRS, width=1, color=c.QGIS_EXTENTS_COLOUR)

    return None


####################################################
## Reset widget functions for 'Layer' tab
####################################################

def tabLayers_reset(dlg: CDB4LoaderDialog) -> None:
    """Function to reset the 'Import' tab.
    Resets: gbxAvailableL, gbxLayerSelection, gbxExtent and lblInfoText.
    """
    # Disable the tab
    dlg.tabLayers.setDisabled(True)
    # Reset all underlying objects
    lblInfoText_reset(dlg)
    gbxBasemapL_reset(dlg)
    gbxLayerSelection_reset(dlg)
    gbxCodeListSelection_reset(dlg)
    gbxAvailableL_reset(dlg)

    return None


def lblInfoText_reset(dlg: CDB4LoaderDialog) -> None:
    """Function to reset the 'DB and Schema' label (in Layers tab).
    """
    dlg.lblInfoText.setText(dlg.lblInfoText.init_text)
    dlg.lblInfoText.setDisabled(True)

    return None


def gbxBasemapL_reset(dlg: CDB4LoaderDialog) -> None:
    """Function to reset the 'Extents' groupbox (in Layers tab).
    """
    dlg.qgbxExtentsL.setDisabled(True)
    # Remove extent rubber bands.
    dlg.RUBBER_CDB_SCHEMA_L.reset()
    dlg.RUBBER_LAYERS_L.reset()
    dlg.RUBBER_QGIS_L.reset()

    return None


def gbxLayerSelection_reset(dlg: CDB4LoaderDialog) -> None:
    """Function to reset the 'Parameters' group box (in Layers tab).
    """
    dlg.gbxLayerSelection.setDisabled(True)
    dlg.cbxFeatureType.clear()
    dlg.cbxLod.clear()

    return None

def gbxCodeListSelection_reset(dlg: CDB4LoaderDialog) -> None:
    """Function to reset the 'Miscellaneous option' groupbox to the DEFAULT values
    """
    dlg.cbxCodeListSelCityGML.clear()
    # dlg.cbxCodeListSelADE.clear()
    return None



def gbxAvailableL_reset(dlg: CDB4LoaderDialog) -> None:
    """Function to reset the 'Features to Import' group box (in Layers tab).
    """
    dlg.ccbxLayers.clear()
    dlg.gbxAvailableL.setDisabled(True)

    return None
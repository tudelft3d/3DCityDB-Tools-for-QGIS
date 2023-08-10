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

FILE_LOCATION = gen_f.get_file_relative_path(file=__file__)


# def fill_CityGML_codelist_selection_box(dlg: CDB4LoaderDialog, CityGML_codelist_set_names: list = None) -> None:
#     """Function that fills the 'Select CodeLists group' combo box.
#     """
#     # Clean combo box from previous leftovers.
#     dlg.cbxCodeListSelCityGML.clear()

#     if not CityGML_codelist_set_names:
#         # Disable the combobox
#         dlg.cbxCodeListSelCityGML.setDisabled(True)
#         dlg.cbxCodeListSelCityGML.setDisabled(True)
#     else:
#         label: str = f"None"
#         dlg.cbxCodeListSelCityGML.addItem(label, userData=label)
#         for codelist_set_name in CityGML_codelist_set_names:
#             label: str = f"{codelist_set_name}"
#             dlg.cbxCodeListSelCityGML.addItem(label, userData=label)
#         if not dlg.cbxCodeListSelCityGML.isEnabled():
#             # Enable the combobox
#             dlg.cbxCodeListSelCityGML.setDisabled(False)
#             dlg.lblCodeListSelCityGML.setDisabled(False)
   
#     # REMEMBER: don't use method 'setSeparator', it adds a custom separator to join string of selected items
#     return None


####################################################
## Reset widget functions for 'Settings' tab
####################################################

def tabSettings_reset(dlg: CDB4LoaderDialog) -> None:
    """Function to reset the 'Settings' tab
    """
    dlg.tabSettings.setDisabled(True)
    gbxGeomSimp_reset(dlg)
    gbxLayerOptions_reset(dlg)
    # gbxCodeListSelection_reset(dlg)
    gbxMisc_reset(dlg)

    return None


def gbxGeomSimp_reset(dlg: CDB4LoaderDialog) -> None:
    """Function to reset the 'Geometry simplification' groupbox to the DEFAULT values
    """
    dlg.gbxGeomSimp.setChecked(False)
    dlg.qspbDecimalPrec.setValue(dlg.settings.simp_geom_dec_prec_default)
    dlg.qspbMinArea.setValue(dlg.settings.simp_geom_min_area_default)

    return None


def gbxLayerOptions_reset(dlg: CDB4LoaderDialog) -> None:
    """Function to reset the 'Layer Options' groupbox to the DEFAULT values
    """
    dlg.gbxGeomSimp.setChecked(False)
    dlg.qspbMaxFeatImport.setValue(dlg.settings.max_features_to_import_default)
    dlg.cbxForceLayerGen.setChecked(dlg.settings.force_all_layers_creation_default)

    return None


# def gbxCodeListSelection_reset(dlg: CDB4LoaderDialog) -> None:
#     """Function to reset the 'Miscellaneous option' groupbox to the DEFAULT values
#     """
#     dlg.cbxCodeListSelCityGML.clear()

#     return None


def gbxMisc_reset(dlg: CDB4LoaderDialog) -> None:
    """Function to reset the 'Miscellaneous option' groupbox to the DEFAULT values
    """
    dlg.cbxEnable3D.setChecked(dlg.settings.enable_3d_renderer_default)

    return None


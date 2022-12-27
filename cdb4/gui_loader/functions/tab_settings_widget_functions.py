"""This module contains reset functions for each QT widget in the GUI of the
plugin.

The logic behind all of the functions is to reset widgets as individual
objects or as block of objects, depending on the needs.

These function help declutter the widget_setup.py from repetitive code.

The reset functions consist of clearing text or changed text to original state,
clearing widget items or selections and deactivating widgets.
"""
from ....cdb_loader import CDBLoader # Used only to add the type of the function parameters

from ...shared.functions import general_functions as gen_f

FILE_LOCATION = gen_f.get_file_relative_path(file=__file__)

####################################################
## Setup widget functions for 'Settings' tab
####################################################



####################################################
## Reset widget functions for 'Settings' tab
####################################################

def tabSettings_reset(cdbLoader: CDBLoader) -> None:
    """Function to reset the 'Settings' tab.
    """
    gbxGeomSimp_reset(cdbLoader)
    gbxLayerOptions_reset(cdbLoader)
    gbxMisc_reset(cdbLoader)


def gbxGeomSimp_reset(cdbLoader: CDBLoader) -> None:
    """Function to reset the 'Geometry simplification' groupbox.
    """
    dlg = cdbLoader.loader_dlg

    dlg.gbxGeomSimp.setChecked(False)
    dlg.qspbDecimalPrec.setValue(dlg.settings.simp_geom_dec_prec)
    dlg.qspbMinArea.setValue(dlg.settings.simp_geom_min_area)


def gbxLayerOptions_reset(cdbLoader: CDBLoader) -> None:
    """Function to reset the 'Simplify geometries' groupbox.
    """
    dlg = cdbLoader.loader_dlg

    dlg.gbxGeomSimp.setChecked(False)
    dlg.qspbMaxFeatImport.setValue(dlg.settings.max_features_to_import)
    dlg.cbxForceLayerGen.setChecked(dlg.settings.force_all_layers_creation)

def gbxMisc_reset(cdbLoader: CDBLoader) -> None:
    """Function to reset the 'Simplify geometries' groupbox.
    """
    dlg = cdbLoader.loader_dlg

    dlg.cbxEnable3D.setChecked(dlg.settings.enable_3d_renderer)
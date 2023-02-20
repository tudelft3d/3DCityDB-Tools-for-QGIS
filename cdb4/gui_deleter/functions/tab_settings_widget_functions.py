"""This module contains reset functions for each QT widgets.

The logic behind all of the functions is to reset widgets as individual
objects or as block of objects, depending on the needs.

The reset functions consist of clearing text or changed text to original state,
clearing widget items or selections and deactivating widgets.
"""
from __future__ import annotations
from typing import TYPE_CHECKING  #, Union
if TYPE_CHECKING:       
    from ...gui_deleter.deleter_dialog import CDB4DeleterDialog

from ...shared.functions import general_functions as gen_f

FILE_LOCATION = gen_f.get_file_relative_path(file=__file__)

####################################################
## Reset widget functions for 'Settings' tab
####################################################

def tabSettings_reset(dlg: CDB4DeleterDialog) -> None:
    """Function to reset the 'Settings' tab
    """
    gbxMiscSettings_reset(dlg)
    dlg.tabSettings.setDisabled(True)

    return None

def gbxMiscSettings_reset(dlg: CDB4DeleterDialog) -> None:
    """Function to reset the groupbox 'gbxMiscSettings' tab
    """
    dlg.sbxArraySize.setValue(dlg.settings.max_del_array_length_default)

    return None
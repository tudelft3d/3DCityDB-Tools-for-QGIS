"""This module contains general commodity functions
"""
import os.path
from typing import Callable

from qgis.PyQt.QtCore import Qt
from qgis.core import QgsMessageLog, Qgis
from qgis.gui import QgsCheckableComboBox

from .... import cdb_tools_main_constants as main_c

def get_checkedItemsData(ccbx: QgsCheckableComboBox) -> list:
    """Function to extract the QVariant data from a QgsCheckableComboBox widget.
    Replaces built-in method: checkedItemsData()
    """
    # 0 Qt.Unchecked
    # 1 Qt.PartiallyChecked
    # 2 Qt.Checked
    # See: https://doc.qt.io/qt-6/qt.html#CheckState-enum

    checked_items = []
    for idx in range(ccbx.count()):
        
        if ccbx.itemCheckState(idx) == Qt.Checked:
            checked_items.append(ccbx.itemData(idx))
    return checked_items


def get_file_relative_path(file: str = __file__) -> str:
    """Function that retrieves the file path relative to the plugin directory (os independent).
    Running get_file_relative_path() (i.e. without arguments) 
    returns 3dcitydb-tools/cdb4/shared/functions/general_functions.py

    *   :param file: absolute path of a file
        :type file: str
    """
    path = os.path.split(file)[0]
    file_name = os.path.split(file)[1]
    rel_path = os.path.relpath(path, main_c.PLUGIN_ROOT_PATH)
    rel_file_path = os.path.join(rel_path, file_name)
    return rel_file_path


def critical_log(func: Callable, location: str, header: str, error: str) -> None:
    """Function used to form and display  in the QGIS Message Log panel an error caught in a critical message.

    *   :param func: The function producing the error
        :type func: function

    *   :param location: The relative path (to the plugin directory) of the function's file
        :type location: str

    *   :param header: Informative text appended to the location of the error
        :type header: str

    *   :param error: Error to be displayed
        :type error: str
    """
    # Get the location to show in log where an issue happens
    function_name = func.__name__
    location = ">".join([location, function_name])

    # Specify in the header the type of error and where it happened.
    header = f"{header} ERROR at {location}\n ERROR: "

    # Show the error in the log panel. Should open it even if it is closed.
    QgsMessageLog.logMessage(
        message=header + str(error),
        tag=main_c.PLUGIN_NAME_LABEL,
        level=Qgis.Critical,
        notifyUser=True)
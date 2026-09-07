"""This module contains general commodity functions
"""
import os.path
from typing import Callable

from qgis.PyQt.QtCore import Qt
from qgis.core import QgsMessageLog, Qgis
from qgis.gui import QgsCheckableComboBox, QgsMessageBar

from .... import cdb_tools_main_constants as main_c


def get_checkedItemsData(ccbx: QgsCheckableComboBox) -> list:
    """Function to extract the QVariant data from a QgsCheckableComboBox widget.
    Replaces built-in method: checkedItemsData()
    """
    checked_items = []
    for idx in range(ccbx.count()):
        if ccbx.itemCheckState(idx) == Qt.CheckState.Checked:
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
    header = f"{header} ERROR at {location}\nERROR: "

    # Show the error in the log panel. Should open it even if it is closed.
    QgsMessageLog.logMessage(message=header + str(error), tag=main_c.PLUGIN_NAME_LABEL, level=Qgis.MessageLevel.Critical, notifyUser=True)


def push_message_bar_message(
    layout,
    index: int,
    message: str,
    message_type: Qgis.MessageLevel,
    title: str
) -> None:
    """Function used to push a message to a QgsMessageBar in the specified layout position and message level.

    *   :param layout: The layout where the message bar will be inserted
        :type layout: QVBoxLayout, QHBoxLayout etc.

    *   :param index: The position index in the layout where the message bar will be inserted
        :type index: int

    *   :param message: The message text to display
        :type message: str

    *   :param message_type: The message level (Info, Warning, Critical, Success)
        :type message_type: Qgis.MessageLevel

    *   :param title: The title for the message
        :type title: str
    """
    bar = QgsMessageBar()
    layout.insertWidget(index, bar)

    if message_type == Qgis.MessageLevel.Info:
        bar.pushInfo(title, message)
    elif message_type == Qgis.MessageLevel.Warning:
        bar.pushWarning(title, message)
    elif message_type == Qgis.MessageLevel.Critical:
        bar.pushCritical(title, message)
    elif message_type == Qgis.MessageLevel.Success:
        bar.pushSuccess(title, message)
    else:
        bar.pushMessage(title, message)
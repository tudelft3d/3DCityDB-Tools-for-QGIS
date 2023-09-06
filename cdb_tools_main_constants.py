"""This module contains hardcoded variables that are used within the main plugin class (CDBLoader)
"""
import os.path

# Qt Windows Modality enumeration: https://doc.qt.io/qt-5/qt.html#WindowModality-enum
# Qt.NonModal	        0	The window is not modal and does not block input to other windows.
# Qt.WindowModal	    1	The window is modal to a single window hierarchy and blocks input to its parent window, all grandparent windows, and all siblings of its parent and grandparent windows.
# Qt.ApplicationModal	2	The window is modal to the application and blocks input to all windows.

# Plugin current version
PLUGIN_VERSION_MAJOR: int = 0
PLUGIN_VERSION_MINOR: int = 8
PLUGIN_VERSION_REV:   int = 5

# Paths
PLUGIN_ROOT_PATH: str = os.path.split(os.path.dirname(__file__))[0]
PLUGIN_ROOT_DIR: str = os.path.split(os.path.dirname(__file__))[1]

# Database schemas where QGIS Package is installed etc.
QGIS_PKG_SCHEMA: str = "qgis_pkg"

# Root folder for cdb4
CDB4_PLUGIN_DIR: str = "cdb4"

# Plugin and dialog labels
PLUGIN_NAME_LABEL: str      = "3DCityDB Tools"
DLG_NAME_ADMIN_LABEL: str   = "QGIS Package Administrator"
DLG_NAME_LOADER_LABEL: str  = "Layer Loader"
DLG_NAME_DELETER_LABEL: str = "Bulk Deleter"

# Dialog variable names
DLG_VAR_NAME_ADMIN: str   = "admin_dlg"
DLG_VAR_NAME_LOADER: str  = "loader_dlg"
DLG_VAR_NAME_DELETER: str = "deleter_dlg"
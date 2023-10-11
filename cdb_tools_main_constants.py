"""This module contains hardcoded variables that are used within the main plugin class (CDBLoader)
"""
import os.path

# Qt Windows Modality enumeration: https://doc.qt.io/qt-5/qt.html#WindowModality-enum
# Qt.NonModal	        0	The window is not modal and does not block input to other windows.
# Qt.WindowModal	    1	The window is modal to a single window hierarchy and blocks input to its parent window, all grandparent windows, and all siblings of its parent and grandparent windows.
# Qt.ApplicationModal	2	The window is modal to the application and blocks input to all windows.

# Supported QGIS minor versions, i.e. version 3.xx
QGIS_LTR : list = [22, 28]

# Plugin current version
PLUGIN_VERSION_MAJOR: int = 0
PLUGIN_VERSION_MINOR: int = 8
PLUGIN_VERSION_REV:   int = 6

# Paths
PLUGIN_ABS_PATH: str      = os.path.normpath(os.path.dirname(__file__))
# print("PLUGIN_ABS_PATH", PLUGIN_PATH) # e.g. C:\...\QGIS3\profiles\default\python\plugins\citydb-tools  
PLUGIN_ROOT_PATH: str = os.path.split(os.path.dirname(__file__))[0]
# print("PLUGIN_ROOT_PATH", PLUGIN_ROOT_PATH) # e.g. C:\...\QGIS3\profiles\default\python\plugins
PLUGIN_ROOT_DIR: str  = os.path.split(os.path.dirname(__file__))[1]
# print("PLUGIN_ROOT_DIR", PLUGIN_ROOT_DIR) # e.g. citydb-tools 
URL_GITHUB_PLUGIN: str   = "https://github.com/tudelft3d/3DCityDB-Tools-for-QGIS"


# Database schemas where QGIS Package is installed etc.
QGIS_PKG_SCHEMA: str = "qgis_pkg"

# Root folder for cdb4
CDB4_PLUGIN_DIR: str = "cdb4"
# Root folder for cdb5
# CDB4_PLUGIN_DIR: str = "cdb5"

# Plugin and dialog labels
PLUGIN_NAME_LABEL: str      = "3DCityDB Tools"
DLG_NAME_ADMIN_LABEL: str   = "QGIS Package Administrator"
DLG_NAME_LOADER_LABEL: str  = "Layer Loader"
DLG_NAME_DELETER_LABEL: str = "Bulk Deleter"
DLG_NAME_USRGUIDE_LABEL: str= "User guide (PDF)"
DLG_NAME_ABOUT_LABEL: str   = "About"

# Dialog variable names
DLG_VAR_NAME_ADMIN: str   = "admin_dlg"
DLG_VAR_NAME_LOADER: str  = "loader_dlg"
DLG_VAR_NAME_DELETER: str = "deleter_dlg"
DLG_VAR_NAME_ABOUT: str   = "about_dlg"
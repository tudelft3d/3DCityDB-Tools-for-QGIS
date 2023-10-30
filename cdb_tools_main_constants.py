"""This module contains hardcoded variables that are used within the main plugin class (CDBLoader)
"""
import os.path

# Qt Windows Modality enumeration: https://doc.qt.io/qt-5/qt.html#WindowModality-enum
# Qt.NonModal	        0	The window is not modal and does not block input to other windows.
# Qt.WindowModal	    1	The window is modal to a single window hierarchy and blocks input to its parent window, all grandparent windows, and all siblings of its parent and grandparent windows.
# Qt.ApplicationModal	2	The window is modal to the application and blocks input to all windows.

# Supported QGIS minor versions, i.e. version 3.xx
#QGIS_LTR: tuple = (22,) # With one-item tuples, do not forget to add a column after it!! :-)
QGIS_LTR: tuple = (22, 28, 34)

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

# Plugin and menu labels
PLUGIN_NAME_LABEL: str  = "3DCityDB Tools"
MENU_LABEL_LOADER: str  = "Layer Loader"
MENU_LABEL_DELETER: str = "Bulk Deleter"
MENU_LABEL_ADMIN: str   = "QGIS Package Administrator"
MENU_LABEL_USRGUIDE: str= "User guide (PDF)"
MENU_LABEL_ABOUT: str   = "About"

# Dialog names
DLG_NAME_ADMIN: str   = "admin_dlg"
DLG_NAME_LOADER: str  = "loader_dlg"
DLG_NAME_DELETER: str = "deleter_dlg"
DLG_NAME_ABOUT: str   = "about_dlg"
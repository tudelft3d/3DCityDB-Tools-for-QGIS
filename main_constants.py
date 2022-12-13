"""This module contains hardcoded variables that are used within the main plugin class (CDBLoader)
"""
import os.path

# Plugin names
PLUGIN_NAME: str = "3DCityDB Manager"
#PLUGIN_NAME_ADMIN: str = " ".join([PLUGIN_NAME, "(Administration)"])
PLUGIN_NAME_LOADER: str = "3DCityDB Layer Loader"
PLUGIN_NAME_ADMIN: str = "3DCityDB Feature Deleter"
PLUGIN_NAME_DELETER: str = "3DCityDB Administration"

# Paths
PLUGIN_ROOT_PATH: str = os.path.split(os.path.dirname(__file__))[0]
PLUGIN_ROOT_DIR: str = os.path.split(os.path.dirname(__file__))[1]

#print("PLUGIN_ROOT_PATH: " + PLUGIN_ROOT_PATH)
#print("PLUGIN_ROOT_DIR: " + PLUGIN_ROOT_DIR)

CDB4_PLUGIN_DIR: str = "cdb4"

# Plugin current version
PLUGIN_VERSION_MAJOR: int = 0
PLUGIN_VERSION_MINOR: int = 7
PLUGIN_VERSION_REV:   int = 0

# Database schemas where QGIS Package is installed etc.
QGIS_PKG_SCHEMA: str = "qgis_pkg"
USR_SCHEMA: str = "qgis_{user}"

# Dialog names
ADMIN_DLG: str = "admin_dlg"
LOADER_DLG: str = "loader_dlg"
DELETER_DLG: str = "deleter_dlg"
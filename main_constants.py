"""This module contains hardcoded variables that are used within the plugin
"""
import os.path

# Names
PLUGIN_NAME: str = "3DCityDB-Loader"
PLUGIN_NAME_ADMIN: str = " ".join([PLUGIN_NAME, "(Administration)"])

PLUGIN_VERSION_MAJOR: int = 0
PLUGIN_VERSION_MINOR: int = 6
PLUGIN_VERSION_REV:   int = 0

QGIS_PKG_SCHEMA: str = "qgis_pkg"
USR_SCHEMA: str = "qgis_{user}"

# Paths
PLUGIN_ROOT_PATH: str = os.path.split(os.path.dirname(__file__))[0]
PLUGIN_ROOT_DIR: str = os.path.split(os.path.dirname(__file__))[1]

CDB4_PLUGIN_DIR: str = "cdb4"
#CDB5_PLUGIN_DIR: str = "cdb5"
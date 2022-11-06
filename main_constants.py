"""This module contains all hardcoded or constant elements that are
used within the plugin
"""

import os.path

# Names
PLUGIN_NAME: str = "3DCityDB-Loader"
PLUGIN_NAME_ADMIN: str = " ".join([PLUGIN_NAME, "(Administration)"])

QGIS_PKG_SCHEMA: str = "qgis_pkg"
USR_SCHEMA: str = "qgis_{user}"

# Paths
PLUGIN_ROOT_PATH: str = os.path.split(os.path.dirname(__file__))[0]
PLUGIN_ROOT_DIR: str = os.path.split(os.path.dirname(__file__))[1]

CDB4_PLUGIN_DIR: str = "cdb4"
#CDB5_PLUGIN_DIR: str = "cdb5"
"""This module contains all hardcoded or constant elements that are
used within the plugin
"""

import os.path

# Names
PLUGIN_NAME = "3DCityDB-Loader"
PLUGIN_NAME_ADMIN = " ".join([PLUGIN_NAME, "(Administration)"])

QGIS_PKG_SCHEMA = "qgis_pkg"
USR_SCHEMA = "qgis_{user}"

# Paths
PLUGIN_ROOT_PATH = os.path.split(os.path.dirname(__file__))[0]
PLUGIN_ROOT_DIR = os.path.split(os.path.dirname(__file__))[1]

CDB4_PLUGIN_DIR = "cdb4"
CDB5_PLUGIN_DIR = "cdb5"
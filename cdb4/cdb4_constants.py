"""This module contains all hardcoded or constant elements that are
used within the plugin
"""

import os.path
from typing import Callable
from qgis.core import QgsMessageLog, Qgis, QgsRectangle, QgsCoordinateReferenceSystem

from .. import main_constants as main_c



# 3D City Database minimum version
CDB_MIN_VERSION = 4

QML_FORMS_DIR = "forms"
QML_FORMS_PATH = os.path.join(main_c.PLUGIN_ROOT_PATH, main_c.PLUGIN_ROOT_DIR, main_c.CDB4_PLUGIN_DIR, QML_FORMS_DIR)

SQL_SCRIPTS_DIR = "ddl_scripts"
PG_SCRIPTS_DIR = "postgresql"
PG_SCRIPTS_INST_PATH = os.path.join(main_c.PLUGIN_ROOT_PATH, main_c.PLUGIN_ROOT_DIR, main_c.CDB4_PLUGIN_DIR, SQL_SCRIPTS_DIR, PG_SCRIPTS_DIR)
#OR_SCRIPTS_SUBDIR = "oracle"
#OR_SCRIPTS_INST_PATH = os.path.join(main_c.PLUGIN_ROOT_PATH, main_c.CDB4_PLUGIN_SUBDIR, SQL_SCRIPTS_SUBDIR, OR_SCRIPTS_SUBDIR)

#QgsMessageLog.logMessage(f"************** forms path {PG_SCRIPTS_INST_PATH} ", "3DCityDB-Loader", level=Qgis.Info)
#QgsMessageLog.logMessage(f"************** SQL scripts path {PG_SCRIPTS_INST_PATH} ", "3DCityDB-Loader", level=Qgis.Info)

# Extent type names
CDB_SCHEMA_EXT_TYPE = "db_schema"
MAT_VIEW_EXT_TYPE = "m_view"
QGIS_EXT_TYPE = "qgis"

# Basemaps
GOOGLE_URL = "http://mt1.google.com/vt/lyrs%3Dm%26x%3D%7Bx%7D%26y%3D%7By%7D%26z%3D%7Bz%7D&"
GOOGLE_URI = f"type=xyz&url={GOOGLE_URL}zmax=22&zmin=0"
OSM_URL = "https://tile.openstreetmap.org/%7Bz%7D/%7Bx%7D/%7By%7D.png"
OSM_URI = f"type=xyz&url={OSM_URL}&zmax=22&zmin=0"
OSM_INIT_EXTS = QgsRectangle(-14372453, -6084688, 16890255, 13952819)
OSM_INIT_CRS = QgsCoordinateReferenceSystem("EPSG:3857")
OSM_NAME = "OSM Basemap"

# Options default Parameters
# For simplify geometries function
DEC_PREC = 3
MIN_AREA = 0.0001  # to be expressed in m2

# Max number of features per layer to be importer
MAX_FEATURES_PER_LAYER = 20000

# View constants
geom_col = "geom" # Geometry column name of db views.
id_col = "id" # Primary key column name of db views.

# 3DCityDB constants
generics_table = "cityobject_genericattrib"
generics_alias = "Generic Attributes"


features_tables = [
    "cityobject",
    "building",
    "tin_relief",
    "tunnel",
    "bridge",
    "waterbody",
    "solitary_vegetat_object",
    "city_furniture",
    "land_use"
    ]  #Named after their main corresponding table name from the 3DCityDB.

feature_types = [
    "CityObject",
    "Building",
    "Relief",
    "Tunnel",
    "Bridge",
    "Waterbody",
    "Vegetation",
    "CityFurniture",
    "LandUse",
    "Transportation",
    "Generics"
    ]

lods = [
    "LoD0",
    "LoD1",
    "LoD2",
    "LoD3",
    "LoD4"
    ]

create_layers_funcs = [
    "create_layers_building",
    "create_layers_bridge",
    "create_layers_cityfurniture",
    "create_layers_generics",
    "create_layers_tunnel",
    "create_layers_transportation",
    "create_layers_landuse",
    "create_layers_relief",
    "create_layers_vegetation",
    "create_layers_waterbody",
    ]

drop_layers_funcs = [
    "drop_layers_building",
    "drop_layers_bridge",
    "drop_layers_cityfurniture",
    "drop_layers_generics",
    "drop_layers_tunnel",
    "drop_layers_transportation",
    "drop_layers_landuse",
    "drop_layers_relief",
    "drop_layers_vegetation",
    "drop_layers_waterbody",
    ]

# Text - Messages - Log
icon_msg_core = """
                <html><head/><body><p> 
                <img src="{image_rc}" style='vertical-align: bottom'/> 
                <span style=" color:{color_hex};">{addtional_text}</span>
                </p></body></html>
                """
success_html = icon_msg_core.format(
    image_rc=':/plugins/citydb_loader/icons/success_icon.svg',
    color_hex='#00E400',
    addtional_text='{text}')

failure_html = icon_msg_core.format(
    image_rc=':/plugins/citydb_loader/icons/failure_icon.svg',
    color_hex='#FF0000',
    addtional_text='{text}')

warning_html = icon_msg_core.format(
    image_rc=':/plugins/citydb_loader/icons/warning_icon.svg',
    color_hex='#FFA701',
    addtional_text='{text}')

crit_warning_html = icon_msg_core.format(
    image_rc=':/plugins/citydb_loader/icons/critical_warning_icon.svg',
    color_hex='#DA4453',
    addtional_text='{text}')

menu_html = icon_msg_core.format(
    image_rc=':/plugins/citydb_loader/icons/plugin_icon.png',
    color_hex='#000000',
    addtional_text='{text}')

# Log messages
log_errors = "{type} ERROR at {loc}\n ERROR: "

INST_SUCC_MSG = "Database schema '{pkg}' successfully installed!"
INST_ERROR_MSG = "Database schema '{pkg}' installation failed!"
UNINST_SUCC_MSG = "Database schema '{pkg}' successfully uninstalled!"
UNINST_ERROR_MSG = "Database schema '{pkg}' NOT removed!"

LAYER_CR_SUCC_MSG = "Layers successfully created in schema '{sch}'"
LAYER_CR_ERROR_MSG = "Error while creating layers in schema '{sch}'"
LAYER_DR_SUCC_MSG = "Layers successfully removed from schema '{sch}'"
LAYER_DR_ERROR_MSG = "Error while removing layers from schema '{sch}'"

# Connection status messages
CONN_FAIL_MSG = "Connection failed"
PG_SERVER_FAIL_MSG = "PostgreSQL server is not responding"
CDB_FAIL_MSG = "3DCityDB is not installed"
INST_MSG = "{pkg} is already installed"
INST_FAIL_MSG = "{pkg} is not installed"

SCHEMA_SUPP_MSG = "Layers for schema '{sch}' already exist"
SCHEMA_SUPP_FAIL_MSG = "Layers need to be created for schema '{sch}'"
REFR_LAYERS_MSG = "Last refresh: {date}"
REFR_LAYERS_FAIL_MSG = "Layers need to be refreshed"

# Pop-up messages
INST_QUERY = "Any existing installation of '{pkg}' will be replaced! Do you want to proceed?"
UNINST_QUERY = "Uninstalling '{pkg}'! Do you want to proceed?"

REFRESH_QUERY = "Refreshing layers can take long time.\nDo you want to proceed?"

# default "qgis_pkg" users
def_users = [
    "qgis_user_ro",
    "qgis_user_rw", 
    ]

# default user group name
def_usr_group = "qgis_pkg_usrgroup"

# Widget initial embedded text | Note: empty spaces are for positioning.
btnConnectToDb  = "Connect to database '{db}'"
btnMainInst_t   = "  Install to current database '{db}'"
btnMainUninst_t = "  Uninstall from current database '{db}'"
btnUsrInst_t    = "  Create schema for user '{usr}'"
btnUsrUninst_t  = "  Drop schema for user '{usr}'"

btnConnectToDbC_t  = "Connect to database '{db}'"
btnCityExtentsC_t  = "Set to schema '{sch}'"
btnCreateLayers_t  = "Create layers for schema '{sch}'"
btnRefreshLayers_t = " Refresh layers for schema '{sch}'"
btnDropLayers_t    = "Drop layers for schema '{sch}'"

lblInfoText_t    = "Current database: '{db}'\nCurrent user: '{usr}'\nCurrent citydb schema: '{sch}'"
btnCityExtents_t = "Set to schema '{sch}'"
ccbxFeatures_t   = "Select available features to import"



# Classes
class View():
    """This class is used to convert each row of
    the 'layer_metadata' table into object
    instances.

    Its purpose is to facilitate access to attributes.
    """

    def __init__(self,
            v_id: int,
            cdb_schema: str,
            feature_type: str,
            lod: str,
            root_class: str,
            layer_name: str,
            n_features: int,
            mv_name: str,
            v_name: str,
            qml_file: str,
            creation_data: str,
            refresh_date: str):
        self.v_id = v_id
        self.cdb_schema = cdb_schema
        self.feature_type = feature_type
        self.lod = lod
        self.root_class = root_class
        self.layer_name = layer_name
        self.n_features = n_features
        self.n_selected = 0
        self.mv_name = mv_name
        self.v_name = v_name
        self.qml_file = qml_file
        self.qml_path = os.path.join(QML_FORMS_PATH, qml_file)
        self.creation_data = creation_data
        self.refresh_date = refresh_date

class FeatureType():
    """This class acts as a container of the View
    class.

    It is used to organise all views according to
    their corresponding feature type.
    """

    def __init__(self, alias: str):
        self.alias = alias
        self.views = []





# Functions

def get_postgres_array(data) -> str:
    """Function that formats a collection of data into
    a postgres array string.

    *   :param data: Elements to be converted like a PostgreSQL array.

        :param data: tuple,list,dict

    *   :returns: a PostgreSQL like array to be used in sql queries.

        :rtype: str
    """

    array=''
    for f in data:
        array += f
        array += '|'

    array = list(array)
    array[-1] = ")"
    array.insert(0,"(")
    array = ''.join(array)
    return array


def get_file_relative_path(file: str = __file__) -> str:
    """Function that retrieves the file path relative to
    the plugin directory (os independent).

    Running get_file_relative_path() returns 3dcitydb-loader/constants.py

    *   :param file: absolute path of a file

        :type file: str
    """
    path = os.path.split(file)[0]
    file_name = os.path.split(file)[1]
    rel_path = os.path.relpath(path, main_c.PLUGIN_ROOT_PATH)
    rel_file_path = os.path.join(rel_path, file_name)
    return rel_file_path


def critical_log(func: Callable, location: str, header: str, error: str) -> None:
    """Function used to form and display an error caught in a critical message
    into the QGIS Message Log panel.

    *   :param func: The function producing the error.

        :type func: function

    *   :param location: The relative path (to the plugin directory) of the
            function's file.

        :type location: str

    *   :param header: Informative text appended to the location of the error.

        :type header: str

    *   :param error: Error to be displayed.

        :type error: str
    """
    # Get the location to show in log where an issue happens
    function_name = func.__name__
    location = ">".join([location, function_name])

    # Specify in the header the type of error and where it happened.
    header = log_errors.format(type=header, loc=location)

    # Show the error in the log panel. Should open it even if it is closed.
    QgsMessageLog.logMessage(
        message=header + str(error),
        tag=main_c.PLUGIN_NAME,
        level=Qgis.Critical,
        notifyUser=True)


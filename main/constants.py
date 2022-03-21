"""This module contains all the hardcoded or constant elements that are
used in the plugin's functionality."""


import os.path
from typing import Callable

from qgis.core import QgsMessageLog, Qgis, QgsRectangle, QgsCoordinateReferenceSystem

# Directories - Paths - Names
DIR_NAME = os.path.split(os.path.dirname(__file__))[1] # main
QML_FORMS_DIR = "forms"
PLUGIN_PATH = os.path.split(os.path.dirname(__file__))[0]
QML_FORMS_PATH = os.path.join(PLUGIN_PATH,QML_FORMS_DIR)

PLUGIN_NAME = "3DCityDB-Loader"
MAIN_PKG_NAME = "qgis_pkg"
USER_PKG_NAME = "qgis_{user}"
INST_DIR_NAME = "installation"
INST_SCRIPTS_DIR_NAME = "postgresql"
# MAIN_INST_DIR_NAME = "main_inst"
# USER_INST_DIR_NAME = "user_inst"

MAIN_INST_PATH = os.path.join(PLUGIN_PATH,INST_DIR_NAME,INST_SCRIPTS_DIR_NAME)
USER_INST_PATH = os.path.join(PLUGIN_PATH,INST_DIR_NAME,INST_SCRIPTS_DIR_NAME)
CITYDB_DEF_NAME = "citydb"


MAIN_INST_PREFIX = [0]


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
INST_SUCCS_MSG = "{pkg} has been installed successfully!"
INST_ERROR_MSG = "{pkg} installation failed!"
UNINST_SUCC_MSG = "{pkg} has been uninstalled succeffully!"
UNINST_ERROR_MSG = "{pkg} was NOT removed!"
LAYER_CR_SUCCS_MSG = "Layers have been created successfully in {sch}"
LAYER_CR_ERROR_MSG = "Error occured while creating layers in {sch}"

# Connection Status messages
CONN_FAIL_MSG = "Connection failed!"
POST_FAIL_MSG = "PostgreSQL sever wasn't reached!"
CITYDB_FAIL_MSG = "3DCityDB is not installed!"
INST_FAIL_MSG = "{pkg} is not installed!"
SCHEMA_SUPP_FAIL_MSG = "Layers need to be created for {sch}!"
REFR_LAYERS_FAIL_MSG = "Layers need to be refreshed!"
REFR_LAYERS_MSG = "Last refresh: {date}"
SCHEMA_SUPP_MSG = "Layers already exist in {sch}!"
INST_MSG = "{pkg} is already installed!"

INST_QUERY = "Any existing installation of '{pkg}' is going to be replaced! Do you want to proceed?"
UNINST_QUERY = "Uninstalling '{pkg}'! Do you want to proceed?"

# Widget initial embedded text | Note: empty spaces are for positioning.  
btnConnectToDbC_t = "Connect to {db}"
btnCreateLayers_t = "Create layers for schema {sch}"
btnRefreshLayers_t = " Refresh layers in schema {sch}"
btnCityExtentsC_t = "Set to {sch} schema"

lblInfoText_t = "Database: {db}\nCurrent user: {usr}\nCurrent citydb schema: {sch}"
btnCityExtents_t = btnCityExtentsC_t
ccbxFeatures_t = "Select availiable features to import"

btnConnectToDb = btnConnectToDbC_t
btnMainInst_t = "  Install to database {db}"
btnMainUninst_t = "  Uninstall from database {db}"
btnUsrInst_t = "  Create schema for user {usr}"
btnUsrUninst_t = "  Drop schema for user {usr}"

# Parameters
DEC_PREC = 3
MIN_AREA = 0.0001

# View constants
geom_col = "geom" # Geometry column name of db views.
id_col = "id" # Primary key column name of db views.

# 3DCityDB constants
generics_table = "cityobject_genericattrib"
generics_alias = "Generic Attributes"

# Extent type names
SCHEMA_EXT_TYPE = "db_schema"
MAT_VIEW_EXT_TYPE = "m_view"
QGIS_EXT_TYPE = "qgis"

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
priviledge_types = [
    "DELETE",
    "INSERT",
    "REFERENCES",
    "SELECT",
    "TRIGGER",
    "TRUNCATE",
    "UPDATE"
    ]
lods = [
    'LoD0',
    'LoD1',
    'LoD2',
    'LoD3',
    'LoD4'
    ]

create_layers_funcs = [
    "create_layers_city_furniture",
    "create_layers_generics",
    "create_layers_land_use",
    "create_layers_relief",
    "create_layers_vegetation"
    ]
    # NOTE:TODO fill in the rest when they're done

# Basemaps
GOOGLE_URL = "http://mt1.google.com/vt/lyrs%3Dm%26x%3D%7Bx%7D%26y%3D%7By%7D%26z%3D%7Bz%7D&"
GOOGLE_URI = f"type=xyz&url={GOOGLE_URL}zmax=22&zmin=0"
OSM_URL = "https://tile.openstreetmap.org/%7Bz%7D/%7Bx%7D/%7By%7D.png"
OSM_URI = f"type=xyz&url={OSM_URL}&zmax=22&zmin=0"
OSM_INIT_EXTS = QgsRectangle(-14372453,-6084688,16890255,13952819)
OSM_INIT_CRS = QgsCoordinateReferenceSystem("EPSG:3857")
OSM_NAME = "OSM Basemap"

# Classes
class View():
    """This class is used to convert each row of
    the qgis_pkg.layer_meatadata table into object
    instances.

    Its purpose is to facilitate access to attributes."""

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
        self.v_name= v_name
        self.v_name = v_name
        self.qml_file = qml_file
        self.qml_path = os.path.join(QML_FORMS_PATH,qml_file)
        self.creation_data=creation_data
        self.refresh_date=refresh_date

class FeatureType():
    """This class acts as a container of the View
    class.

    It is used to organise all of the views to
    their corresponding feature type."""

    def __init__(self,alias: str):
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
        array+=f
        array+='|'

    array=list(array)
    array[-1]=")"
    array.insert(0,"(")
    array=''.join(array)
    return array

def get_file_location(file: str = __file__) -> str:
    """Function that retrieves the file path relative to
    plugin's directory (os independent).

    Running get_file_location() returns main/constants.py

    *   :param file: absolute path of a file

        :type file: str
    """

    file_name = os.path.split(file)[1]
    relative_file_location = os.path.join(DIR_NAME,file_name)
    return relative_file_location

def critical_log(func: Callable, location: str, header: str, error: str) -> None:
    """Function used to form and display caught error in a critical message
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
    location = ">".join([location,function_name])

    # Specify in the header the type of error and where it happend.
    header = log_errors.format(type=header, loc=location)

    # Show the error in the log panel. Should open it even if its closed.
    QgsMessageLog.logMessage(message=header + str(error),
        tag="3DCityDB-Loader",
        level=Qgis.Critical,
        notifyUser=True)

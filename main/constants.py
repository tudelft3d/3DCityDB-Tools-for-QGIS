"""This module contains all the hardcoded or constant elements that are
used in the plugin's functionality."""


import os.path


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

log_errors = "{type} ERROR at {loc}\n ERROR: "

# Widget initial embedded text
btnInstallDB_text = "Install plugin contents to database {DB}.{SC}"
btnUnInstallDB_text = "Uninstall plugin contents from database {DB}.{SC}"
btnClearDB_text = "Clear entire {DB} database from plugin contents"
btnRefreshViews_text = "Refresh views for {DB}.{SC}"
lblDbSchema_text = "Database: {Database}\nSchema: {Schema}"
btnImport_text = "Import {num} feature layers"
lblInstall_text = "Installation for {schema}:"
ccbxFeatures_text = "Select availiable features to import"

# Directories - Paths - NAMES
DIR_NAME = os.path.split(os.path.dirname(__file__))[1] # main
QML_FROMS_DIR = "forms"
PLUGIN_PATH = os.path.split(os.path.dirname(__file__))[0]
QML_FROMS_PATH = os.path.join(PLUGIN_PATH,QML_FROMS_DIR)
PLUGIN_PKG_NAME = "qgis_pkg"
PLUGIN_NAME = "3DCityDB-Loader"
INST_SCRIPT_DIR_NAME = "postgresql"
INST_SCRIPT_DIR_PATH = os.path.join(PLUGIN_PATH,PLUGIN_PKG_NAME,INST_SCRIPT_DIR_NAME)



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
FeatureTypes = [
    "CityObject",
    "Building",
    "DTM","Tunnel",
    "Bridge",
    "Waterbody",
    "Vegetation",
    "CityFurniture",
    "LandUse",
    "Transportation"
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

# Basemaps
GOOGLE_URL = "http://mt1.google.com/vt/lyrs%3Dm%26x%3D%7Bx%7D%26y%3D%7By%7D%26z%3D%7Bz%7D&"
GOOGLE_URI = f"type=xyz&url={GOOGLE_URL}zmax=22&zmin=0"
OSM_URL = "https://tile.openstreetmap.org/%7Bz%7D/%7Bx%7D/%7By%7D.png"
OSM_URI = f"type=xyz&url={OSM_URL}&zmax=18&zmin=0"


# Classes
class View():
    """This class is used to convert each row of
    the qgis_pkg.layer_meatadata table into object
    instances.

    Its purpose is to facilitate access to attributes."""

    def __init__(self,
            v_id: int,
            schema_name: str,
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
        self.v_id=v_id
        self.schema_name=schema_name
        self.feature_type = feature_type
        self.lod = lod
        self.root_class = root_class
        self.layer_name = layer_name
        self.n_features=n_features
        self.n_selected=0
        self.mv_name=mv_name
        self.v_name= v_name
        self.v_name = v_name
        self.qml_file=qml_file
        self.qml_path=os.path.join(QML_FROMS_PATH,qml_file)
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

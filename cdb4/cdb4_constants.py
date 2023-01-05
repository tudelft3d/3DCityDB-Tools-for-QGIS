"""This module contains constant values that are used within the CityDB-Loader plugin for 3DCityDB v. 4.x
"""

import os.path
from qgis.core import QgsCoordinateReferenceSystem, QgsRectangle

from .. import main_constants as main_c

# PostgreSQL Database minimum version supported
PG_MIN_VERSION: int = 10
# 3D City Database minimum version
CDB_MIN_VERSION: int = 4
# QGIS Package minimum version
QGIS_PKG_MIN_VERSION_MAJOR: int = 0
QGIS_PKG_MIN_VERSION_MINOR: int = 9
QGIS_PKG_MIN_VERSION_MINOR_REV: int = 0
QGIS_PKG_MIN_VERSION_TXT: str = ".".join([str(QGIS_PKG_MIN_VERSION_MAJOR), str(QGIS_PKG_MIN_VERSION_MINOR), str(QGIS_PKG_MIN_VERSION_MINOR_REV)])

# Path to style configuration files
QML_DIR: str = "qml"
QML_PATH: str = os.path.join(main_c.PLUGIN_ROOT_PATH, main_c.PLUGIN_ROOT_DIR, main_c.CDB4_PLUGIN_DIR, QML_DIR)

QML_FORM_DIR: str = "form"
QML_SYMB_DIR: str = "symb"
QML_3D_DIR: str = "3d"

# Path to SQL scripts to install the QGIS Package
SQL_SCRIPTS_DIR: str= "ddl_scripts"
PG_SCRIPTS_DIR: str = "postgresql"
PG_SCRIPTS_INST_PATH: str = os.path.join(main_c.PLUGIN_ROOT_PATH, main_c.PLUGIN_ROOT_DIR, main_c.CDB4_PLUGIN_DIR, SQL_SCRIPTS_DIR, PG_SCRIPTS_DIR)
#OR_SCRIPTS_SUBDIR: str = "oracle"
#OR_SCRIPTS_INST_PATH: str = os.path.join(main_c.PLUGIN_ROOT_PATH, main_c.CDB4_PLUGIN_SUBDIR, SQL_SCRIPTS_SUBDIR, OR_SCRIPTS_SUBDIR)

# Extent types
CDB_SCHEMA_EXT_TYPE: str = "db_schema"
MAT_VIEW_EXT_TYPE: str   = "m_view"
QGIS_EXT_TYPE: str       = "qgis"

# Basemaps
GOOGLE_URL: str = "http://mt1.google.com/vt/lyrs%3Dm%26x%3D%7Bx%7D%26y%3D%7By%7D%26z%3D%7Bz%7D&"
GOOGLE_URI: str = f"type=xyz&url={GOOGLE_URL}zmax=22&zmin=0"

OSM_NAME: str = "OSM Basemap"
OSM_URL: str = "https://tile.openstreetmap.org/%7Bz%7D/%7Bx%7D/%7By%7D.png"
OSM_URI: str = f"type=xyz&url={OSM_URL}&zmax=22&zmin=0"
OSM_INIT_EXTS: QgsRectangle = QgsRectangle(-14372453, -6084688, 16890255, 13952819)
OSM_INIT_CRS: QgsCoordinateReferenceSystem = QgsCoordinateReferenceSystem("EPSG:3857")

## SETTINGS (BEGIN) ####

# Options default parameters to simplify geometries
SIMP_GEOM_DEC_PREC: int = 3         # decimal positions after the comma to round coordinates
SIMP_GEOM_MIN_AREA: float = 0.0001  # to be expressed in m2

# Max number of features per layer to be imported
MAX_FEATURES_TO_IMPORT: int = 50000

# Other settings
FORCE_ALL_LAYERS_CREATION: bool = False
ENABLE_3D_RENDERER: bool = False

## SETTINGS (END) ####

# 3DCityDB constants
generics_table: str     = "cityobject_genericattrib"
generics_alias: str     = "Generic Attributes"
enumerations_table: str = "v_enumeration_value"
codelists_table: str    = "v_codelist_value"

create_layers_funcs: list = [
    "create_layers_bridge",
    "create_layers_building",
    "create_layers_cityfurniture",
    "create_layers_generics",
    "create_layers_landuse",
    "create_layers_relief",
    "create_layers_transportation",
    "create_layers_tunnel",
    "create_layers_vegetation",
    "create_layers_waterbody",
    ]

drop_layers_funcs: list = [
    "drop_layers_bridge",
    "drop_layers_building",
    "drop_layers_cityfurniture",
    "drop_layers_generics",
    "drop_layers_landuse",
    "drop_layers_relief",
    "drop_layers_transportation",
    "drop_layers_tunnel",
    "drop_layers_vegetation",
    "drop_layers_waterbody",
    ]

# Text - Messages - Log
icon_msg_core: str = """
                <html><head/><body><p> 
                <img src="{image_rc}" style='vertical-align: bottom'/> 
                <span style=" color:{color_hex};">{addtional_text}</span>
                </p></body></html>
                """
success_html: str = icon_msg_core.format(
    image_rc=':/plugins/citydb_loader/icons/success_icon.svg',
    color_hex='#00E400',   # green
    addtional_text='{text}')

failure_html: str = icon_msg_core.format(
    image_rc=':/plugins/citydb_loader/icons/failure_icon.svg',
    color_hex='#FF0000',  # red
    addtional_text='{text}')

warning_html: str = icon_msg_core.format(
    image_rc=':/plugins/citydb_loader/icons/warning_icon.svg',
    color_hex='#FFA701',  # Orange
    addtional_text='{text}')

crit_warning_html: str = icon_msg_core.format(
    image_rc=':/plugins/citydb_loader/icons/critical_warning_icon.svg',
    color_hex='#DA4453', # pale red
    addtional_text='{text}')

menu_html: str = icon_msg_core.format(
    image_rc=':/plugins/citydb_loader/icons/plugin_icon.png',
    color_hex='#000000',  # black
    addtional_text='{text}')

# Admin dialog strings
INST_SUCC_MSG: str    = "Database schema '{pkg}' successfully installed!"
INST_ERROR_MSG: str   = "Database schema '{pkg}' installation failed!"
UNINST_SUCC_MSG: str  = "Database schema '{pkg}' successfully uninstalled!"





# Usr dialog strings




LAYER_CR_SUCC_MSG: str  = "Layers successfully created in schema '{sch}'"
LAYER_CR_ERROR_MSG: str = "Error while creating layers in schema '{sch}'"
LAYER_DR_SUCC_MSG: str  = "Layers successfully removed from schema '{sch}'"
LAYER_DR_ERROR_MSG: str = "Error while removing layers from schema '{sch}'"

# Connection status messages
CONN_FAIL_MSG: str = "Connection failed"
PG_SERVER_FAIL_MSG: str = "PostgreSQL server is not responding"
PG_VERSION_UNSUPPORTED_MSG: str = "Unsupported PostgreSQL version"

CDB_FAIL_MSG: str = "3DCityDB is not installed"
INST_MSG: str = "Schema '{pkg}' is installed"
INST_FAIL_MSG: str = "Required schema '{pkg}' is not installed"
INST_FAIL_VERSION_MSG: str = "Unsupported version of QGIS Package"
INST_FAIL_MISSING_MSG: str = "The QGIS Package is not installed"

SCHEMA_LAYER_MSG: str = "Layers for schema '{sch}' already exist"
SCHEMA_LAYER_FAIL_MSG: str = "Layers need to be created for schema '{sch}'"
REFR_LAYERS_MSG: str = "Latest refresh: {date}"
REFR_LAYERS_FAIL_MSG: str = "Layers must be refreshed"

# Pop-up messages
INST_QUERY: str = "Any existing installation of '{pkg}' will be replaced! Do you want to proceed?"
UNINST_QUERY: str = "Uninstalling '{pkg}'! Do you want to proceed?"


# Admin dialog: Widget initial embedded text | Note: empty spaces are for positioning.


# User dialog: Widget initial embedded text | Note: empty spaces are for positioning.


# Widget initial embedded text | Note: empty spaces are for positioning.
btnConnectToDb: str  = "Connect to database '{db}'"
btnMainInst_t: str   = "  Install to current database '{db}'"
btnMainUninst_t: str = "  Uninstall from current database '{db}'"
btnUsrInst_t: str    = "  Create schema for user '{usr}'"
btnUsrUninst_t: str  = "  Drop schema for user '{usr}'"

btnConnectToDbC_t: str  = "Connect to database '{db}'"

btnRefreshCDBExtents_t: str  = "Refresh '{sch}' extents"

btnCityExtentsC_t: str  = "Set to schema '{sch}'"

btnCreateLayers_t: str  = "Create layers for schema '{sch}'"
btnRefreshLayers_t: str = " Refresh layers for schema '{sch}'"
btnDropLayers_t: str    = "Drop layers for schema '{sch}'"

lblInfoText_t: str    = "Current database: '{db}'\nCurrent user: '{usr}'\nCurrent citydb schema: '{sch}'"
btnCityExtents_t: str = "Set to schema '{sch}'"
ccbxFeatures_t: str   = "Select available features to import"
btnCleanUpSchema: str = "Truncate ALL tables in schema '{sch}'"
btnDropLayers: str = "Delete features from '{sch}'"

# dict for getting feature type from root class
module_finder = {'Bridge': 'Bridge',
                 'Building': 'Building',
                 'CityFurniture': 'CityFurniture',
                 'CityObjectGroup': 'CityObjectGroup',
                 'GenericCityObject': 'Generics',
                 'LandUse': 'LandUse',
                 'ReliefFeature': 'Relief',
                 'TransportationComplex': 'Transportation',
                 'Track': 'Transportation',
                 'Railway': 'Transportation',
                 'Road': 'Transportation',
                 'Square': 'Transportation',
                 'Tunnel': 'Tunnel',
                 'SolitaryVegetationObject': 'Vegetation',
                 'PlantCover': 'Vegetation',
                 'WaterBody': 'WaterBody'}

ftype_class_finder = {'Building': ('Building','BuildingPart','BuildingInstallation','IntBuildingInstallation','BuildingCeilingSurface',
                                   'InteriorBuildingWallSurface','BuildingFloorSurface','BuildingRoofSurface','BuildingWallSurface',
                                   'BuildingGroundSurface','BuildingClosureSurface','BuildingWindow','BuildingDoor','BuildingFurniture','BuildingRoom'),
                      }

frc_class_finder = {'Building': ('Building','BuildingPart','BuildingInstallation','IntBuildingInstallation','BuildingCeilingSurface',
                                 'InteriorBuildingWallSurface','BuildingFloorSurface','BuildingRoofSurface','BuildingWallSurface',
                                 'BuildingGroundSurface','BuildingClosureSurface','BuildingWindow','BuildingDoor','BuildingFurniture','BuildingRoom')}
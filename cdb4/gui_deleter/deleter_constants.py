"""This module contains constant values that are used within the CityDB-Loader plugin for 3DCityDB v. 4.x
"""
from qgis.core import QgsCoordinateReferenceSystem, QgsRectangle
from qgis.PyQt.QtGui import QColor
from qgis.PyQt.QtCore import Qt

# QGIS Package minimum version
QGIS_PKG_MIN_VERSION_MAJOR: int = 0
QGIS_PKG_MIN_VERSION_MINOR: int = 10
QGIS_PKG_MIN_VERSION_MINOR_REV: int = 3
QGIS_PKG_MIN_VERSION_TXT: str = ".".join([str(QGIS_PKG_MIN_VERSION_MAJOR), str(QGIS_PKG_MIN_VERSION_MINOR), str(QGIS_PKG_MIN_VERSION_MINOR_REV)])

# Extent types
CDB_SCHEMA_EXT_TYPE: str = "db_schema"
LAYER_EXT_TYPE: str      = "m_view"

# Extent types
# Check more here: https://doc.qt.io/qt-5/qt.html#GlobalColor-enum
CDB_EXTENTS_COLOUR:   QColor = Qt.black
DELETE_EXTENTS_COLOUR: QColor = Qt.red

# Basemaps
GOOGLE_URL: str = "http://mt1.google.com/vt/lyrs%3Dm%26x%3D%7Bx%7D%26y%3D%7By%7D%26z%3D%7Bz%7D&"
GOOGLE_URI: str = f"type=xyz&url={GOOGLE_URL}zmax=22&zmin=0"

OSM_NAME: str = "OSM Basemap"
OSM_URL: str = "https://tile.openstreetmap.org/%7Bz%7D/%7Bx%7D/%7By%7D.png"
OSM_URI: str = f"type=xyz&url={OSM_URL}&zmax=22&zmin=0"
OSM_INIT_EXTS = QgsRectangle(-14372453, -6084688, 16890255, 13952819)
OSM_INIT_CRS = QgsCoordinateReferenceSystem("EPSG:3857")

# Usr dialog strings
CONN_FAIL_MSG: str = "Connection failed"
PG_SERVER_FAIL_MSG: str = "PostgreSQL server is not responding"
INST_FAIL_MISSING_MSG: str = "The QGIS Package is not available"
INST_FAIL_VERSION_MSG: str = "Unsupported version of QGIS Package"
INST_MSG: str = "Schema '{pkg}' is installed"
INST_FAIL_MSG: str = "Schema '{pkg}' is not installed"
SCHEMA_LAYER_MSG: str = "Layers for schema '{sch}' already exist"

TRUNC_SUCC_MSG: str = "Clean-up of schema {sch} successful"
TRUNC_FAIL_MSG: str = "Error while cleaning up schema {sch}"

BULK_DEL_SUCC_MSG: str = "Bulk delete operation in schema {sch} successful"
BULK_DEL_FAIL_MSG: str = "Error while bulk deleting from schema {sch}"

LAYER_DR_SUCC_MSG: str  = "Layers removed from schema '{sch}'"
LAYER_DR_ERROR_MSG: str = "Error while removing layers from schema '{sch}'"

# Widget initial embedded text | Note: empty spaces are for positioning.
btnConnectToDB_t: str  = "Connect to database '{db}'"

btnCleanUpSchema_t:str = "Truncate ALL tables in schema '{sch}'"

btnRefreshCDBExtents_t: str  = "Refresh '{sch}' extents"
btnCityExtents_t: str  = "Set to schema '{sch}'"

ccbxFeatures_t: str   = "Select available features to import"
btnDelSelFeatures_t: str    = "Delete data from schema '{sch}'"

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
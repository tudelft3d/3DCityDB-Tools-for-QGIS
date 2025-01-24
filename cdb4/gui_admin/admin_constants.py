"""This module contains constant values that are used within the CityDB-Tools plugin for 3DCityDB v. 4.x
"""
import os.path
from ... import cdb_tools_main_constants as main_c

# PostgreSQL Database minimum version supported
PG_MIN_VERSION: int = 10

# 3D City Database minimum version
CDB_MIN_VERSION_MAJOR: int = 4
CDB_MIN_VERSION_MINOR: int = 0 # Currently not used

# QGIS Package minimum version
QGIS_PKG_MIN_VERSION_MAJOR: int = 0
QGIS_PKG_MIN_VERSION_MINOR: int = 10
QGIS_PKG_MIN_VERSION_MINOR_REV: int = 6
QGIS_PKG_MIN_VERSION_TXT: str = ".".join([str(QGIS_PKG_MIN_VERSION_MAJOR), str(QGIS_PKG_MIN_VERSION_MINOR), str(QGIS_PKG_MIN_VERSION_MINOR_REV)])

# Path to SQL scripts to install the QGIS Package
SQL_SCRIPTS_DIR: str = "ddl_scripts"
PG_SCRIPTS_DIR: str = "postgresql"
PG_SCRIPTS_INST_PATH: str = os.path.join(main_c.PLUGIN_ROOT_PATH, main_c.PLUGIN_ROOT_DIR, main_c.CDB4_PLUGIN_DIR, SQL_SCRIPTS_DIR, PG_SCRIPTS_DIR)

# Admin strings
CONN_FAIL_MSG: str = "Connection failed"
PG_SERVER_FAIL_MSG: str = "PostgreSQL server is not responding"
PG_VERSION_UNSUPPORTED_MSG: str = "Unsupported PostgreSQL version"
CDB_FAIL_MSG: str = "3DCityDB is not installed"
USER_PRIV_MSG: str = "Current user has {privs} privileges"
INST_FAIL_VERSION_MSG: str = "Unsupported version of QGIS Package"
INST_ONGOING_MSG: str = "Schema '{pkg}' being installed"
INST_SUCC_MSG: str = "Schema '{pkg}' installed"
INST_FAIL_MSG: str = "Schema '{pkg}' not installed"
UNINST_ONGOING_MSG: str = "Schema '{pkg}' being uninstalled"
UNINST_SUCC_MSG: str = "Schema '{pkg}' uninstalled"

# Widget initial embedded text | Note: empty spaces are for positioning.
btnConnectToDb_t: str = "Connect to database '{db}'"
btnMainInst_t: str = "  Install to '{db}'"
btnMainUninst_t: str = "  Uninstall from '{db}'"
btnConnectToDbC_t: str = "Connect to database '{db}'"

# Text - Messages - Log
icon_msg_core: str = """
                <html><head/><body><p> 
                <img src="{image_rc}" style='vertical-align: bottom'/> 
                <span style=" color:{color_hex};">{additional_text}</span>
                </p></body></html>
                """
success_html: str = icon_msg_core.format(
    image_rc=':/plugins/citydb_loader/icons/success_icon.svg',
    color_hex='#00E400',   # green
    additional_text='{text}')

failure_html: str = icon_msg_core.format(
    image_rc=':/plugins/citydb_loader/icons/failure_icon.svg',
    color_hex='#FF0000',  # red
    additional_text='{text}')

ongoing_html: str = icon_msg_core.format(
    image_rc=os.path.join(main_c.PLUGIN_ABS_PATH, "icons", "refresh_icon_orange.svg"),
    color_hex='#FF7E33',  # orange2
    additional_text='{text}')

warning_html: str = icon_msg_core.format(
    image_rc=':/plugins/citydb_loader/icons/warning_icon.svg',
    color_hex='#FFA701',  # orange1
    additional_text='{text}')

crit_warning_html: str = icon_msg_core.format(
    image_rc=':/plugins/citydb_loader/icons/critical_warning_icon.svg',
    color_hex='#DA4453', # pale red
    additional_text='{text}')

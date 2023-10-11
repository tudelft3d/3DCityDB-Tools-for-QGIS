"""This module contains constant values that are used within the CityDB-Loader plugin for 3DCityDB v. 4.x
"""
import os.path
from .. import cdb_tools_main_constants as main_c

FILE_PATH: str = os.path.normpath(os.path.dirname(__file__))

URL_PDF_3DCITYDB_INSTALL: str = "https://github.com/tudelft3d/3DCityDB-Tools-for-QGIS/blob/master/user_guide/3DCityDB_Suite_QuickInstall.pdf"
#URL_PDF_3DCITYDB_INSTALL: str = os.path.join(main_c.PLUGIN_PATH, "user_guide", "3DCityDB_Suite_QuickInstall.pdf")

HTML_ABOUT: str      = "about.html"
HTML_DEVELOPERS: str = "developers.html"
HTML_CHANGELOG: str  = "changelog.html"
HTML_REFERENCES: str  = "references.html"
HTML_LICENSE: str    = "license.html"
HTML_3DCITYDB: str   = "3dcitydb.html"
PATH_HTML: str = os.path.join(FILE_PATH, "html")

# URLs 3DCityDB-Plugin
URL_GITHUB_PLUGIN: str        = "https://github.com/tudelft3d/3DCityDB-Tools-for-QGIS"
URL_GITHUB_PLUGIN_ISSUES: str = "https://github.com/tudelft3d/3DCityDB-Tools-for-QGIS/issues"

# URLs 3DCityDB
URL_GITHUB_3DCITYDB: str        = "https://github.com/3dcitydb/3dcitydb-suite/releases"
URL_GITHUB_3DCITYDB_MANUAL: str = "https://3dcitydb-docs.readthedocs.io/en/latest/"
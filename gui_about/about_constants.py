"""This module contains constant values that are used within the CityDB-Loader plugin for 3DCityDB v. 4.x
"""
import os.path

FILE_PATH: str = os.path.normpath(os.path.dirname(__file__))

HTML_ABOUT: str      = "about.html"
HTML_DEVELOPERS: str = "developers.html"
HTML_CHANGELOG: str  = "changelog.html"
HTML_REFERENCES: str = "references.html"
HTML_LICENSE: str    = "license.html"
HTML_3DCITYDB: str   = "3dcitydb.html"
HTML_SEARCH_PATH: str = os.path.join(FILE_PATH, "html")

# URLs 3DCityDB database
URL_GITHUB_3DCITYDB: str        = "https://github.com/3dcitydb/3dcitydb-suite/releases"
URL_GITHUB_3DCITYDB_MANUAL: str = "https://3dcitydb-docs.readthedocs.io/en/latest/"
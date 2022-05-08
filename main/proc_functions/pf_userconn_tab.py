"""This module contains functions that relate to the 'Connection Tab'
(in the GUI look for the elephant).

These functions are usually called from widget_setup functions
relating to child widgets of the 'Connection Tab'.
"""


from qgis.core import QgsMessageLog, Qgis
import psycopg2

from .. import connection
from .. import constants
from . import sql


def is_3dcitydb(dbLoader) -> bool:
    """Function that checks if the current database has
    3DCityDB installed. The check is done by querying the 3DCityDB
    version from citydb_pkg.version(). The version is stored
    in 'c_version' attribute of the Connection object.

    On 3DCityDB absence a database error is emited which means that
    it is not installed.

    Note for future 3DCityDB versions: this function MUST be updated
    for every change in the abovementioned 3DCitydb function's name
    or schema.
    """

    # Get 3DCityDB version
    version = sql.fetch_3dcitydb_version(dbLoader)

    if version: # Could be None
        # Store verison into the connection object.
        dbLoader.DB.c_version = version
        return True
    return False

def fill_schema_box(dbLoader, schemas: tuple) -> None:
    """Function that fills schema combo box with the provided schemas."""

    # Clear combo box from previous entries
    dbLoader.dlg.cbxSchema.clear()

    for schema in schemas:
        if not sql.exec_table_is_empty(dbLoader,schema,"cityobject"):
            dbLoader.dlg.cbxSchema.addItem(schema, True)
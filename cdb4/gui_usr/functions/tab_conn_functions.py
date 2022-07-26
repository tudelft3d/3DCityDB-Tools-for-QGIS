"""This module contains functions that relate to the 'Connection Tab'
(in the GUI look for the elephant).

These functions are usually called from widget_setup functions
relating to child widgets of the 'Connection Tab'.
"""

#from qgis.core import QgsMessageLog, Qgis

from ....cdb_loader import CDBLoader # Used only to add the type of the function parameters

from . import sql

def is_3dcitydb_installed(cdbLoader: CDBLoader) -> bool:
    """Function that checks whether the current database has the 
    3DCityDB installed. The check is done by querying the 3DCityDB
    version from citydb_pkg.version(). The version is stored
    in 'citydb_version' attribute of the Connection object.

    On 3DCityDB absence a database error is emitted which means that
    it is not installed.

    Note for future 3DCityDB versions: this function MUST be updated
    for every change in the above mentioned 3DCitydb function's name
    or schema.
    """

    # Get 3DCityDB version
    version = sql.fetch_3dcitydb_version(cdbLoader)

    if version: # Could be None
        # Store version into the connection object.
        cdbLoader.DB.citydb_version = version
        return True
    return False

def fill_schema_box(cdbLoader: CDBLoader, schemas: tuple) -> None:
    """Function that fills schema combo box with the provided schemas."""

    # Clear combo box from previous entries
    cdbLoader.usr_dlg.cbxSchema.clear()

    for schema in schemas:
        cdbLoader.usr_dlg.cbxSchema.addItem(schema, True)
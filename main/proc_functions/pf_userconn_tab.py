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


def open_connection(dbLoader) -> bool:
    """Opens a connection using the parameters stored in DBLoader.DB
    and retrieves the server's verison. The server version is stored
    in 's_version' attribute of the Connection object.

    *   :returns: connection attempt results

        :rtype: bool
    """

    try:
        # Open the connection.
        dbLoader.conn = connection.connect(dbLoader.DB)
        dbLoader.conn.commit() # This seems redundant.

        # Get server version.
        version = sql.fetch_server_version(dbLoader)

        # Store verison into the connection object.
        dbLoader.DB.s_version = version

    except (Exception, psycopg2.Error) as error:
        # Get the location to show in log where an issue happenes
        FUNCTION_NAME = open_connection.__name__
        FILE_LOCATION = constants.get_file_location(file=__file__)
        LOCATION = ">".join([FILE_LOCATION,FUNCTION_NAME])

        # Specify in the header the type of error and where it happend.
        header = constants.log_errors.format(type="Attempting connection", loc=LOCATION)

        # Show the error in the log panel. Should open it even if its closed.
        QgsMessageLog.logMessage(message=header + str(error),
            tag="3DCityDB-Loader",
            level=Qgis.Critical,
            notifyUser=True)
        dbLoader.conn.rollback()
        return False

    return True

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
        res = sql.schema_has_features(dbLoader, schema=schema)
        if res:
            dbLoader.dlg.cbxSchema.addItem(schema,res)
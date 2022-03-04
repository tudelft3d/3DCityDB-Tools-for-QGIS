"""This module contains functions that relate to the package Installation
operations.

These functions are usually called from widget_setup functions
relating to child widgets of the 'Settings Tab' or 'Connection Tab'
as from either of these tabs installation,uninstallation processes
can commence.

..(04-03-22) The functions where reduced by a LOT, so this whole
.. file seems a bit redundant. Think of how to consume it.
"""

from qgis.PyQt.QtWidgets import QMessageBox

from . import constants as c
from . import sql
from . import threads as th

def installation_query(dbLoader, message: str) -> None:
    """Function that propts the user to install
    the plugin package (qgis_pkg) in the database.

    *   :param message: Text to show the user

        :param message: str
    """

    res= QMessageBox.question(dbLoader.dlg,"Installation", message)
    if res == 16384: #YES

        # Run scripts
        th.install_pkg_thread(dbLoader,
        path=c.INST_SCRIPT_DIR_PATH)

def uninstall_pkg(dbLoader) -> None:
    """Function that uninstalls the plugin package from the
    user's database.
    """

    sql.drop_package(dbLoader)

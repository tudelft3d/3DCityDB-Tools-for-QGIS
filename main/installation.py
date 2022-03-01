"""This module contains functions that relate to the package Installation
operations.

These functions are usually called from widget_setup functions
relating to child widgets of the 'Settings Tab' or 'Connection Tab'
as from either of these tabs installation,uninstallation processes
can commence.
"""


import os
import subprocess

from qgis.PyQt.QtWidgets import QMessageBox
from qgis.core import Qgis, QgsMessageLog

from . import constants as c
from . import sql
from . import threads as th


def upd_conn_file(dbLoader) -> None:
    """Function that prepares the installation script files according
    the users case (parameter, os).
    Updates "CONNECTION_params.sh" or CONNECTION_DETAILS.bat with the
    current paramters

    This is the file that 'CREATE_DB_qgis_pkg.sh/.bat read to install
    the sql scripts.

    Not yet for windows!
    """
    # TODO: name sh and bat connection files the same!

    if os.name == "posix": #Linux or MAC

        #Create path to the 'connections' file
        path_connection_params = os.path.join(
            c.PLUGIN_PATH,
            c.PLUGIN_PKG,
            "CONNECTION_params.sh")

        #Get psql executable path
        cmd = ['which', 'psql'] # NOTE: Does this command work on MAC?
        proc = subprocess.Popen(cmd,
            stdout=subprocess.PIPE,
            stderr=subprocess.PIPE)
        o, e = proc.communicate()
        psql_path = o.decode('ascii')


        #Rewrite the 'connections' file with current database parameters.
        with open (path_connection_params, 'w') as f:
            f.write(f"""\
#!/bin/bash

export PGHOST={dbLoader.DB.host}
export PGPORT={dbLoader.DB.port}
export CITYDB={dbLoader.DB.database_name}
export PGUSER={dbLoader.DB.username}
export PGBIN={psql_path}
                        """)

        #Give executable rights
        os.chmod(path_connection_params, 0o755)

    else: #Windows TODO: Translate the above into windows batch
        pass

def installation_query(dbLoader, message: str) -> None:
    """Function that propts the user to install
    the plugin package (qgis_pkg) in the database.

    *   :param message: Text to show the user

        :param message: str
    """

    res= QMessageBox.question(dbLoader.dlg,"Installation", message)
    if res == 16384: #YES
        # Prepare installation scripts with the connection parameters.
        upd_conn_file(dbLoader)

        # Run script
        install(dbLoader)

def install(dbLoader) -> None:
    """Function that exectutes the installation script
    CREATE_DB_qgis_pkg.sh/.bat depending on the os.
    """

    os.chdir(c.PLUGIN_PATH)

    if os.name == "posix": #Linux or MAC
        installation_path = os.path.join(
            c.PLUGIN_PATH,
            c.PLUGIN_PKG,
            "CREATE_DB_qgis_pkg.sh")
        #Give executable rights
        os.chmod(installation_path, 0o755)

    else: #Windows TODO:Translate the above into windows batch
        # installation_path = os.path.join(par_dir,dbLoader.plugin_package, 'CREATE_DB_qgis_pkg.bat')
        # #Give executable rights
        # os.chmod(installation_path, 0o755)
        return None

    #Run installation script on separate thread.
    th.install_pkg_thread(dbLoader,
        path=installation_path,
        password=dbLoader.DB.password)

def uninstall_pkg(dbLoader) -> None:
    """Function that uninstalls the plugin package from the
    user's database.
    """

    sql.drop_package(dbLoader)

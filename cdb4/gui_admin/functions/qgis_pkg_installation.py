"""
This module contains functions that relate to the package Installation operations.
"""

from qgis.PyQt.QtWidgets import QMessageBox

from ....cdb_loader import CDBLoader # Used only to add the type of the function parameters

from ...cdb4_constants import PG_SCRIPTS_INST_PATH
from . import sql 
from . import threads as thr

def installation_query(cdbLoader: CDBLoader, message: str, inst_type: str) -> bool:
    """Function that prompts the user to install the plugin packages in the database.

    *   :param message: Text to show the user.
        :param message: str

    *   :param inst_type: Type of installation either 'main' or 'user'
        :param inst_type: str (main|user)
    """
    dlg = cdbLoader.admin_dlg

    if inst_type == "main":
        res = QMessageBox.question(dlg, "Installation", message)
        if res == 16384: #YES
            thr.install_qgis_pkg_thread(cdbLoader, sql_scripts_path=PG_SCRIPTS_INST_PATH, qgis_pkg_schema=cdbLoader.QGIS_PKG_SCHEMA)
            return True
        return False
    elif inst_type == "user":
        res = QMessageBox.question(dlg, "Installation", message)
        if res == 16384: #YES
            sql.exec_create_qgis_usr_schema(cdbLoader)
            cdbLoader.admin_dlg.btnUsrUninst.setDisabled(False)
            return True
        cdbLoader.admin_dlg.btnUsrUninst.setDisabled(True)
        return False
    else:
        QMessageBox.critical(dlg, "Installation error", "Unrecognised install type!")
        return False

def uninstallation_query(cdbLoader: CDBLoader, message: str, uninst_type: str) -> bool:
    """Function that uninstalls a qgis_{usr} or the qgis_pkg schema in current database.

    *   :param message: Text to show the user.
        :param message: str

    *   :param inst_type: Type of installation either 'main' or 'user'
        :param inst_type: str (main|user)
    """
    dlg = cdbLoader.admin_dlg

    if uninst_type == "main":
        res = QMessageBox.question(dlg, "Uninstallation", message)
        if res == 16384: #YES
            thr.uninstall_qgis_pkg_thread(cdbLoader)
            return True
        return False
    elif uninst_type == "user":
        res = QMessageBox.question(dlg, "Uninstallation", message)
        if res == 16384: #YES
            # Run scripts
            thr.drop_usr_schema_thread(cdbLoader)
            return True
        return False
    else:
        QMessageBox.critical(dlg, "Uninstallation error", "Unrecognised uninstall type")
        return False
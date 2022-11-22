#from qgis.core import Qgis, QgsMessageLog
from qgis.PyQt.QtGui import QIcon

from ....cdb_loader import CDBLoader # Used only to add the type of the function parameters

# Clean and fills up again the combo box with the list of users.
def fill_users_box(cdbLoader: CDBLoader, users: tuple) -> None:
    """Function to reset the box containing the list of users.
    """
    dlg = cdbLoader.admin_dlg

    # Clean combo box from leftovers.
    dlg.cbxUser.clear()

    user_icon = QIcon(":/plugins/citydb_loader/icons/user.svg")

    for user in users:
        dlg.cbxUser.addItem(user_icon, user)


#############################################
# Reset widget functions
#############################################

"""Here are reset functions for each QT widget in the Admin GUI of the
plugin.

They reset widgets as individual objects or as block of objects, 
depending on the needs.

The reset functions clear text or change text to its original state,
clearing widget items or selections and deactivating them.
"""

def tabDbAdmin_reset(cdbLoader: CDBLoader) -> None:
    """Function to reset the 'Settings' tab. Resets: gbxInstall and lblInfoText.
    """
    # Close the current open connection.
    if cdbLoader.conn is not None:
        cdbLoader.conn.close()

    gbxMainInst_reset(cdbLoader)
    gbxUserInst_reset(cdbLoader)
    gbxConnStatus_reset(cdbLoader)
    cdbLoader.admin_dlg.btnCloseConn.setDisabled(True)


def gbxMainInst_reset(cdbLoader: CDBLoader) -> None:
    """Function to reset the 'Main Installation' groupBox
    """
    dlg = cdbLoader.admin_dlg

    dlg.gbxMainInst.setDisabled(True)
    dlg.btnMainInst.setText(dlg.btnMainInst.init_text)
    dlg.btnMainUninst.setText(dlg.btnMainUninst.init_text)


def gbxUserInst_reset(cdbLoader: CDBLoader) -> None:
    """Function to reset the 'User Installation' groupBox
    """
    dlg = cdbLoader.admin_dlg

    dlg.gbxUserInst.setDisabled(True)
    dlg.btnUsrInst.setText(dlg.btnUsrInst.init_text)
    dlg.btnUsrUninst.setText(dlg.btnUsrUninst.init_text)
    dlg.cbxUser.clear()


def gbxConnStatus_reset(cdbLoader: CDBLoader) -> None:
    """Function to reset the 'Connection status' groupbox
    """
    dlg = cdbLoader.admin_dlg

    dlg.gbxConnStatus.setDisabled(True)
    dlg.lblConnToDb_out.clear()
    dlg.lblPostInst_out.clear()
    dlg.lbl3DCityDBInst_out.clear()
    dlg.lblMainInst_out.clear()
    dlg.lblUserInst_out.clear()

#from qgis.core import Qgis, QgsMessageLog
from qgis.PyQt.QtGui import QIcon

from ....cdb_loader import CDBLoader # Used only to add the type of the function parameters

# Clean and fills up again the combo box with the list of users.
def fill_users_box(cdbLoader: CDBLoader, users: tuple) -> None:

    # Clean combo box from leftovers.
    cdbLoader.admin_dlg.cbxUser.clear()

    user_icon = QIcon(":/plugins/citydb_loader/icons/user.svg")

    for user in users:
        cdbLoader.admin_dlg.cbxUser.addItem(user_icon, user)


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
    """Function to reset the 'Settings' tab.
    Resets: gbxInstall and lblInfoText.
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
    (in Database Administration tab)."""

    cdbLoader.admin_dlg.gbxMainInst.setDisabled(True)
    cdbLoader.admin_dlg.btnMainInst.setText(cdbLoader.admin_dlg.btnMainInst.init_text)
    cdbLoader.admin_dlg.btnMainUninst.setText(cdbLoader.admin_dlg.btnMainUninst.init_text)


def gbxUserInst_reset(cdbLoader: CDBLoader) -> None:
    """Function to reset the 'User Installation' groupBox"""
    
    cdbLoader.admin_dlg.gbxUserInst.setDisabled(True)
    cdbLoader.admin_dlg.btnUsrInst.setText(cdbLoader.admin_dlg.btnUsrInst.init_text)
    cdbLoader.admin_dlg.btnUsrUninst.setText(cdbLoader.admin_dlg.btnUsrUninst.init_text)
    cdbLoader.admin_dlg.cbxUser.clear()


def gbxConnStatus_reset(cdbLoader: CDBLoader) -> None:
    """Function to reset the 'Connection status' groupbox"""

    cdbLoader.admin_dlg.gbxConnStatus.setDisabled(True)
    cdbLoader.admin_dlg.lblConnToDb_out.clear()
    cdbLoader.admin_dlg.lblPostInst_out.clear()
    cdbLoader.admin_dlg.lbl3DCityDBInst_out.clear()
    cdbLoader.admin_dlg.lblMainInst_out.clear()
    cdbLoader.admin_dlg.lblUserInst_out.clear()

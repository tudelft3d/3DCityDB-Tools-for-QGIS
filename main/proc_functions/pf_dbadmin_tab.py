
from qgis.PyQt.QtGui import QIcon

def fill_users_box(dbLoader, users: dict) -> None:


    super_icon = QIcon(":/plugins/citydb_loader/icons/superuser.svg")
    user_icon = QIcon(":/plugins/citydb_loader/icons/user.svg")
    for user, status in users.items():
        if status: # Superuser
            dbLoader.dlg.cbxUser.addItem(
                super_icon,
                user,
                status)
        else: # User
            dbLoader.dlg.cbxUser.addItem(
                user_icon,
                user,
                status)

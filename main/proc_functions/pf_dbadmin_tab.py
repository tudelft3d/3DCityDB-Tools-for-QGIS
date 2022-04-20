
from qgis.PyQt.QtGui import QIcon

def fill_users_box(dbLoader, users: tuple) -> None:

    #super_icon = QIcon(":/plugins/citydb_loader/icons/superuser.svg")
    user_icon = QIcon(":/plugins/citydb_loader/icons/user.svg")
    for user in users:
        # if status: # Superuser
        #     dbLoader.dlg_admin.cbxUser.addItem(
        #         super_icon,
        #         user,
        #         status)
        # User
        dbLoader.dlg_admin.cbxUser.addItem(user_icon,user)

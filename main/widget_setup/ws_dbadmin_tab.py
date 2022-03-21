
from qgis.core import Qgis, QgsMessageLog
from qgis.gui import QgsMessageBar
from qgis.PyQt.QtWidgets import QMessageBox

from .. import constants as c
from ..proc_functions import pf_userconn_tab as usr_tab
from ..proc_functions import pf_dbadmin_tab as dba_tab
from ..proc_functions import threads, sql
from .. import installation
from . import widget_reset


def cbxExistingConn_setup(dbLoader) -> None:
    """Function to setup the gui after a change signal is emitted from
    the cbxExistingConn comboBox.

    This function runs every time the current selection of 'Existing Connection'
    changes.

    (in 'Database Administration' tab)
    """

    # Variable to store the plugin's main dialog
    dlg = dbLoader.dlg
    # Variable to store database name.
    db_name = dbLoader.DB.database_name

    # Reset the Database Administration tab from previous other content.
    widget_reset.reset_tabDbAdmin(dbLoader) # disables it!

    # Enable tab.
    dlg.tabDbAdmin.setDisabled(False)

    # Enable button to connect.
    dlg.btnConnectToDb.setDisabled(False)
    dlg.btnConnectToDb.setText(dlg.btnConnectToDb.init_text.format(db=db_name))

    # Close the current open connection.
    if dbLoader.conn is not None:
        dbLoader.conn.close()

    widget_reset.reset_tabConnection(dbLoader)
    widget_reset.reset_tabLayers(dbLoader)

def btnConnectToDb_setup(dbLoader) -> None:
    """Function to setup the gui after a click signal is emitted from
    the btnConnectToDb pushButton.

    This function runs every time the 'Connect to {db}' button is pressed.

    (in 'Database Administration' tab)
    """

    # Variable to store the plugin's main dialog.
    dlg = dbLoader.dlg
    # Variable to store database name.
    db_name = dbLoader.DB.database_name

    widget_reset.reset_tabConnection(dbLoader)

    # Enable 'Connection Status' group box.
    dlg.gbxConnStatus.setDisabled(False)

    # Attempt to connect to the database
    successful_connection = usr_tab.open_connection(dbLoader)

    if successful_connection and dbLoader.DB.s_version:
        # Show database name
        dlg.lblConnToDb_out.setText(c.success_html.format(
            text=dbLoader.DB.database_name))
        # Show server version
        dlg.lblPostInst_out.setText(c.success_html.format(
            text=dbLoader.DB.s_version))

        # Check that database has 3DCityDB installed.
        if usr_tab.is_3dcitydb(dbLoader):
            # Show 3DCityDB version
            dlg.lbl3DCityDBInst_out.setText(c.success_html.format(
                text=dbLoader.DB.c_version))

            # Enable 'Main installation' group box.
            dlg.gbxMainInst.setDisabled(False)
            dlg.btnMainInst.setText(dlg.btnMainInst.init_text.format(db=db_name))
            dlg.btnMainUninst.setText(dlg.btnMainUninst.init_text.format(db=db_name))



            # Check if main package (schema) is installed in database.
            has_main_inst = sql.has_main_pkg(dbLoader)
            if has_main_inst:
                dbLoader.dlg.lblMainInst_out.setText(c.success_html.format(text=c.INST_MSG.format(pkg=c.MAIN_PKG_NAME)))
            else:
                dbLoader.dlg.lblMainInst_out.setText(c.crit_warning_html.format(text=c.INST_FAIL_MSG.format(pkg=c.MAIN_PKG_NAME)))

            # Get users from database.
            users = sql.fetch_users(dbLoader)
            dba_tab.fill_users_box(dbLoader,users)

        else:
            dlg.lbl3DCityDBInst_out.setText(c.failure_html.format(
                text=c.CITYDB_FAIL_MSG))

    else: # Connection failed!
        widget_reset.reset_gbxConnStatus(dbLoader)
        dlg.gbxConnStatusC.setDisabled(False)

        dlg.lblConnToDb_out.setText(c.failure_html.format(
            text=c.CONN_FAIL_MSG))

        dlg.lblPostInst_out.setText(c.failure_html.format(
            text=c.POST_FAIL_MSG))

def cbxUser_setup(dbLoader) -> None:
    """Function to setup the gui after a change signal is emitted from
    the cbxUser comboBox.

    This function runs every time the current selection of 'User'
    changes.

    (in 'Database Administration' tab)
    """
    dlg = dbLoader.dlg

    # Update current user variable.
    dbLoader.USER = dlg.cbxUser.currentText()
    if not dbLoader.USER:
        return None
 
    # Enable 'User installation' group box.
    dlg.gbxUserInst.setDisabled(False)
    dlg.btnUsrInst.setText(dlg.btnUsrInst.init_text.format(usr=dbLoader.USER))
    dlg.btnUsrUninst.setText(dlg.btnUsrUninst.init_text.format(usr=dbLoader.USER))

    # Check if user package (schema) is installed in database.
    has_user_inst = sql.has_user_pkg(dbLoader)
    #has_user_inst=False
    if has_user_inst:
        dbLoader.dlg.lblUserInst_out.setText(
            c.success_html.format(text=c.INST_MSG.format(
                pkg=dbLoader.USER_SCHEMA)))
    else:
        dbLoader.dlg.lblUserInst_out.setText(c.crit_warning_html.format(text=c.INST_FAIL_MSG.format(
                pkg=dbLoader.USER_SCHEMA)))


def btnRefreshLayers_setup(dbLoader) -> None:
    """Function to setup the gui after a click signal is emitted from
    the btnRefreshLayers pushButton.

    This function runs every time the 'Refresh Views' button is pressed.

    (in 'Database Administration' tab)
    """

    # Assert that user REALLY want to refresh the views.
    message= "This is going to take a while! Do you want to proceed?"
    res= QMessageBox.question(dbLoader.dlg,"Refreshing Views", message)

    if res == 16384: #YES
        threads.refresh_views_thread(dbLoader)

def btnMainInst_setup(dbLoader) -> None:
    """Function to setup the gui after a click signal is emitted from
    the btnMainInst pushButton.

    This function runs every time the 'Install to database' button is pressed.

    It installs the plugin package by executing sql scripts.

    (in 'Database Administration' tab)
    """

    installation.installation_query(dbLoader, c.INST_QUERY.format(pkg=c.MAIN_PKG_NAME), "main")
    widget_reset.reset_tabConnection(dbLoader)

def btnMainUninst_setup(dbLoader) -> None:
    """Function to setup the gui after a click signal is emitted from
    the btnMainUninst pushButton.

    This function runs every time the  'Uninstall from database {db}'
    button is pressed.

    (in 'Database Administration' tab)
    """

    installation.uninstallation_query(dbLoader, c.UNINST_QUERY.format(pkg=c.MAIN_PKG_NAME), "main")

    # Create QgsMessageBar instance.
    dbLoader.dlg.msg_bar = QgsMessageBar()
    # Add the message bar into the input layer and position.
    dbLoader.dlg.vLayoutMainInst.insertWidget(-1,dbLoader.dlg.msg_bar)

    has_main_pkg = sql.has_main_pkg(dbLoader)
    has_user_pkg = sql.has_user_pkg(dbLoader)

    if not has_main_pkg:
        dbLoader.dlg.msg_bar.pushMessage(c.UNINST_SUCC_MSG.format(pkg=c.MAIN_PKG_NAME), level = Qgis.Success)
        # Update status.
        dbLoader.dlg.lblMainInst_out.setText(c.crit_warning_html.format(text=c.INST_FAIL_MSG.format(pkg=c.MAIN_PKG_NAME)))
    elif has_main_pkg:
        dbLoader.dlg.msg_bar.pushMessage(c.INST_ERROR_MSG.format(pkg=c.MAIN_PKG_NAME), level = Qgis.Success)
        # Update status.
        dbLoader.dlg.lblMainInst_out.setText(c.success_html.format(text=c.INST_MSG.format(pkg=c.MAIN_PKG_NAME)))

    if not has_user_pkg:
        dbLoader.dlg.msg_bar.pushMessage(c.UNINST_SUCC_MSG.format(pkg=dbLoader.USER_SCHEMA), level = Qgis.Success)
        # Update status.
        dbLoader.dlg.lblUserInst_out.setText(c.crit_warning_html.format(text=c.INST_FAIL_MSG.format(pkg=dbLoader.USER_SCHEMA)))
    elif has_user_pkg:
        dbLoader.dlg.msg_bar.pushMessage(c.INST_ERROR_MSG.format(pkg=dbLoader.USER_SCHEMA), level = Qgis.Success)
        # Update status.
        dbLoader.dlg.lblUserInst_out.setText(c.success_html.format(text=c.INST_MSG.format(pkg=dbLoader.USER_SCHEMA)))


    widget_reset.reset_tabConnection(dbLoader)
    widget_reset.reset_tabLayers(dbLoader)
    #widget_reset.reset_tabDbAdmin(dbLoader)


def btnUsrInst_setup(dbLoader) -> None:
    """Function to setup the gui after a click signal is emitted from
    the btnUsrInst pushButton.

    This function runs every time the 'Crea schema for user' button is pressed.

    It installs the plugin package by executing sql scripts.

    (in 'Database Administration' tab)
    """

    res = installation.installation_query(dbLoader, c.INST_QUERY.format(pkg=dbLoader.USER_SCHEMA), "user")
    if not res: # Query was canceled by user, or error occured.
        return None

    # Create QgsMessageBar instance.
    dbLoader.dlg.msg_bar = QgsMessageBar()
    # Add the message bar into the input layer and position.
    dbLoader.dlg.vLayoutUsrInst.insertWidget(2,dbLoader.dlg.msg_bar)

    if sql.has_user_pkg(dbLoader):

        # Replace with Success msg.
        msg = dbLoader.dlg.msg_bar.createMessage(c.INST_SUCCS_MSG.format(pkg=dbLoader.USER_SCHEMA))
        dbLoader.dlg.msg_bar.pushWidget(msg, Qgis.Success, 5)

        # Inform user
        dbLoader.dlg.lblUserInst_out.setText(c.success_html.format(text=c.INST_MSG.format(pkg=dbLoader.USER_SCHEMA)))
        QgsMessageLog.logMessage(message=c.INST_SUCCS_MSG.format(pkg=dbLoader.USER_SCHEMA),
                tag="3DCityDB-Loader",
                level=Qgis.Success,
                notifyUser=True)
    else:
        # Replace with Failure msg.
        msg = dbLoader.dlg.msg_bar.createMessage(c.INST_ERROR_MSG.format(pkg=dbLoader.USER_SCHEMA))
        dbLoader.dlg.msg_bar.pushWidget(msg, Qgis.Critical, 5)

        # Inform user
        dbLoader.dlg.lblUserInst_out.setText(c.crit_warning_html.format(text=c.INST_FAIL_MSG.format(pkg=dbLoader.USER_SCHEMA)))
        QgsMessageLog.logMessage(message=c.INST_ERROR_MSG.format(pkg=dbLoader.USER_SCHEMA),
                tag="3DCityDB-Loader",
                level=Qgis.Critical,
                notifyUser=True)

    widget_reset.reset_tabConnection(dbLoader)

def btnUsrUninst_setup(dbLoader) -> None:
    """Function to setup the gui after a click signal is emitted from
    the btnUsrUninst pushButton.

    This function runs every time the  'Drop schema for user}'
    button is pressed.

    (in 'Database Administration' tab)
    """

    res = installation.uninstallation_query(dbLoader, c.UNINST_QUERY.format(pkg=dbLoader.USER_SCHEMA), "user")
    if not res: # Query was canceled by user, or error occured.
        return None

    # Create QgsMessageBar instance.
    dbLoader.dlg.msg_bar = QgsMessageBar()
    # Add the message bar into the input layer and position.
    dbLoader.dlg.vLayoutUsrInst.insertWidget(-1,dbLoader.dlg.msg_bar)

    if not sql.has_user_pkg(dbLoader): # Successful schema drop.

        dbLoader.dlg.msg_bar.pushMessage(c.UNINST_SUCC_MSG.format(pkg=dbLoader.USER_SCHEMA), level = Qgis.Success)
        # Update status.
        dbLoader.dlg.lblUserInst_out.setText(c.crit_warning_html.format(text=c.INST_FAIL_MSG.format(pkg=dbLoader.USER_SCHEMA)))
    else: # Unsuccessful schema drop.
        # Replace with Failure msg.
        msg = dbLoader.dlg.msg_bar.createMessage(c.UNINST_ERROR_MSG.format(pkg=dbLoader.USER_SCHEMA))
        dbLoader.dlg.msg_bar.pushWidget(msg, Qgis.Critical, 5)

        # Inform user.
        dbLoader.dlg.lblUserInst_out.setText(c.success_html.format(text=c.INST_MSG.format(pkg=dbLoader.USER_SCHEMA)))
        QgsMessageLog.logMessage(message=c.UNINST_ERROR_MSG.format(pkg=dbLoader.USER_SCHEMA),
                tag="3DCityDB-Loader",
                level=Qgis.Critical,
                notifyUser=True)

    widget_reset.reset_tabConnection(dbLoader)
    widget_reset.reset_tabLayers(dbLoader)
    #widget_reset.reset_tabDbAdmin(dbLoader)
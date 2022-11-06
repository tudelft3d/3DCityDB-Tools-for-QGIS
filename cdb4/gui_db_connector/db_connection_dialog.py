"""This module contains classes and functions related to the database connections."""

from xmlrpc.client import boolean
from qgis.core import Qgis, QgsSettings

import os
from qgis.gui import QgsMessageBar
from qgis.PyQt import uic,QtWidgets
from PyQt5 import QtWidgets

import psycopg2

from .. import cdb4_constants as c
from .connection import Connection
from .functions.conn_functions import connect

FILE_LOCATION = c.get_file_relative_path(__file__)

# This loads the .ui file so that PyQt can populate the plugin
# with the elements from Qt Designer
FORM_CLASS, _ = uic.loadUiType(os.path.join(os.path.dirname(__file__), "ui", "db_connector_dialog.ui"))

class DBConnectorDialog(QtWidgets.QDialog, FORM_CLASS):
    """Connector Dialog. This dialog pops up when a user requests to make a new connection.
    """

    def __init__(self, parent=None):
        super(DBConnectorDialog, self).__init__(parent)
        self.setupUi(self)

        self.gbxConnDet.bar = QgsMessageBar()
        self.verticalLayout.addWidget(self.gbxConnDet.bar, 0)

        # Connection object variable
        self.new_connection: Connection = None

        # Connect signals
        self.btnConnect.clicked.connect(self.evt_btnConnect_clicked)

    def store_credetials(self):
        """Function that stores the database connection parameters
        in the user's profile settings for future use.
        """
        #TODO: Warn user that the connection parameters are stored locally in a .ini file

        new_settings = QgsSettings()
        con_path= f'PostgreSQL/connections/{self.new_connection.connection_name}'

        new_settings.setValue(f'{con_path}/database', self.new_connection.database_name)
        new_settings.setValue(f'{con_path}/host', self.new_connection.host)
        new_settings.setValue(f'{con_path}/port', self.new_connection.port)
        new_settings.setValue(f'{con_path}/username', self.new_connection.username)
        new_settings.setValue(f'{con_path}/password', self.new_connection.password)

    def evt_btnConnect_clicked(self) -> None:
        """Event that is called when the current 'Connect' pushButton
        (btnConnect) is pressed.
        """
        # Instantiate a connection object
        connectionInstance = Connection()

        # Update connection attributes parameters from 'Line Edit' user info
        connectionInstance.connection_name = self.ledConnName.text()
        connectionInstance.host = self.ledHost.text()
        connectionInstance.port = self.ledPort.text()
        connectionInstance.database_name = self.ledDb.text()
        connectionInstance.username = self.ledUserName.text()
        connectionInstance.password = self.qledPassw.text()
        if self.checkBox.isChecked():
            connectionInstance.store_creds = True

        try:
            # Attempt to open connection
            connect(connectionInstance)
            self.new_connection = connectionInstance

            self.gbxConnDet.bar.pushMessage(
                    "Success", 
                    "Connection is valid! You can find it in 'Select an existing connection' box.", 
                    level=Qgis.Success,
                    duration=3)
            if self.checkBox.isChecked():
                self.store_credetials()

        except (Exception, psycopg2.DatabaseError) as error:
            c.critical_log(
                func=self.evt_btnConnect_clicked,
                location=FILE_LOCATION,
                header="Attempting connection",
                error=error)
            self.gbxConnDet.bar.pushMessage(
                "Error",
                "Connection failed!",
                level=Qgis.Critical,
                duration=5)


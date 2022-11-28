"""This module contains classes and functions related to the database connections."""
import os
import psycopg2
from qgis.core import Qgis, QgsSettings
from qgis.gui import QgsMessageBar
from qgis.PyQt import QtWidgets, uic

from ..shared.functions import general_functions as gen_f
from .other_classes import Connection
from .functions.conn_functions import connect

FILE_LOCATION = gen_f.get_file_relative_path(__file__)

# This loads the .ui file so that PyQt can populate the plugin with the elements from Qt Designer
FORM_CLASS, _ = uic.loadUiType(os.path.join(os.path.dirname(__file__), "ui", "db_connector_dialog.ui"))

class DBConnectorDialog(QtWidgets.QDialog, FORM_CLASS):
    """Connector Dialog. This dialog pops up when a user requests to make a new connection.
    """
    def __init__(self, parent=None):
        super(DBConnectorDialog, self).__init__(parent)

        self.setupUi(self)

        ############################################################
        ## From here you can add your variables or constants
        ############################################################

        # Connection object variable
        self.conn_params: Connection = None
        
        self.gbxConnDet.bar = QgsMessageBar()
        self.verticalLayout.addWidget(self.gbxConnDet.bar, 0)

        ################################################
        ### SIGNALS (start) ############################
        ################################################

        # Connect signals
        self.btnTestConn.clicked.connect(self.evt_btnTestConn_clicked)
        self.btnOK.clicked.connect(self.evt_btnOK_clicked)
        self.btnCancel.clicked.connect(self.evt_btnCancel_clicked)

        ################################################
        ### SIGNALS (end) ##############################
        ################################################

    def store_conn_parameters(self):
        """Function that stores the database connection parameters in the user's profile settings for future use.
        """
        #TODO: Warn user that the connection parameters are stored locally in a .ini file

        new_conn_params = QgsSettings()
        conn_path= f'PostgreSQL/connections/{self.conn_params.connection_name}'

        new_conn_params.setValue(f'{conn_path}/database', self.conn_params.database_name)
        new_conn_params.setValue(f'{conn_path}/host', self.conn_params.host)
        new_conn_params.setValue(f'{conn_path}/port', self.conn_params.port)
        new_conn_params.setValue(f'{conn_path}/username', self.conn_params.username)
        new_conn_params.setValue(f'{conn_path}/password', self.conn_params.password)

        ################################################
        ### EVENTS (start) ############################
        ################################################

    def evt_btnTestConn_clicked(self) -> None:
        """Event that is called when the 'Test connection' pushButton (btnTestConn) is pressed.
        """
        # Instantiate a connection object
        NewConnParams = Connection()

        # Update connection attributes parameters from 'Line Edit' user info
        NewConnParams.connection_name = self.ledConnName.text()
        NewConnParams.host = self.ledHost.text()
        NewConnParams.port = self.ledPort.text()
        NewConnParams.database_name = self.ledDb.text()
        NewConnParams.username = self.ledUserName.text()
        NewConnParams.password = self.qledPassw.text()
        if self.checkBox.isChecked():
            NewConnParams.store_creds = True
        
        if any((not NewConnParams.connection_name, not NewConnParams.host, 
                not NewConnParams.port, not NewConnParams.database_name, 
                not NewConnParams.username, not NewConnParams.password)):
            self.gbxConnDet.bar.pushMessage("Error", "Missing connection parameters", level=Qgis.Warning, duration=3)
            return None
        else:
            temp_conn: psycopg2.connection = None
            try:
                temp_conn = connect(NewConnParams) # attempt to open connection and keep it open
                # If successful, close it, otherwise an Exception will be raised.
                temp_conn.close() # close connection after the test.
                self.gbxConnDet.bar.pushMessage("Success", "Connection parameters are valid!", level=Qgis.Success, duration=3)

            except (Exception, psycopg2.DatabaseError) as error:
                gen_f.critical_log(
                    func=self.evt_btnTestConn_clicked,
                    location=FILE_LOCATION,
                    header="Attempting connection",
                    error=error)
                self.gbxConnDet.bar.pushMessage("Error", "Connection could not be established", level=Qgis.Critical, duration=3)

            return None


    def evt_btnOK_clicked(self) -> None:
        """Event that is called when the 'OK' pushButton (btnOK) is pressed. It checks the connection,
        and, if successful, 
        """
        # Instantiate a connection object
        NewConnParams = Connection()

        # Update connection attributes parameters from 'Line Edit' user info
        NewConnParams.connection_name = self.ledConnName.text()
        NewConnParams.host = self.ledHost.text()
        NewConnParams.port = self.ledPort.text()
        NewConnParams.database_name = self.ledDb.text()
        NewConnParams.username = self.ledUserName.text()
        NewConnParams.password = self.qledPassw.text()
        if self.checkBox.isChecked():
            NewConnParams.store_creds = True
        
        if any((not NewConnParams.connection_name, not NewConnParams.host, 
                not NewConnParams.port, not NewConnParams.database_name, 
                not NewConnParams.username, not NewConnParams.password)):
            self.gbxConnDet.bar.pushMessage("Error", "Missing connection parameters", level=Qgis.Warning, duration=3)
            return None
        else:
            temp_conn: psycopg2.connection = None
            try:
                temp_conn = connect(NewConnParams) # attempt to open connection and keep it open
                # If successful, close it, otherwise an Exception will be raised.
                temp_conn.close() # close connection after the test.

                # Assign the new connection parameters to the variable, they will be added to the dropbox in the parent dialog.
                self.conn_params = NewConnParams

                # Store the new connection parameters for future use.
                if self.checkBox.isChecked():
                    self.store_conn_parameters()
                                
            except (Exception, psycopg2.DatabaseError) as error:
                gen_f.critical_log(
                    func=self.evt_btnTestConn_clicked,
                    location=FILE_LOCATION,
                    header="Attempting connection",
                    error=error)
                self.gbxConnDet.bar.pushMessage("Error", "Connection could not be established", level=Qgis.Critical, duration=3)

        self.close()


    def evt_btnCancel_clicked(self) -> None:
        """Event that is called when the 'Cancel' pushButton (btnCancel) is pressed.
        It simply closes the dialog.
        """
        self.close()

        ################################################
        ### EVENTS (end) ############################
        ################################################
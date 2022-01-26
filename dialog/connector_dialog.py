# -*- coding: utf-8 -*-

# Form implementation generated from reading ui file 'connector.ui'
#
# Created by: PyQt5 UI code generator 5.14.1
#
# WARNING! All changes made in this file will be lost!


from PyQt5 import QtCore, QtGui, QtWidgets
from qgis.gui import QgsMessageBar
from qgis.PyQt.QtWidgets import *

class Ui_dlgConnector(object):
    def setupUi(self, dlgConnector):
        dlgConnector.setObjectName("dlgConnector")
        dlgConnector.resize(380, 610)
        
        self.gridLayout = QtWidgets.QGridLayout(dlgConnector)
        self.gridLayout.setObjectName("gridLayout")
        self.verticalLayout = QtWidgets.QVBoxLayout()
        self.verticalLayout.setObjectName("verticalLayout")
        self.gbxConnDet = QtWidgets.QGroupBox(dlgConnector)
        self.gbxConnDet.setObjectName("gbxConnDet")

        self.gbxConnDet.bar = QgsMessageBar()
        self.gbxConnDet.bar.setSizePolicy( QSizePolicy.Minimum, QSizePolicy.Fixed )
        self.verticalLayout.addWidget(self.gbxConnDet.bar, 0)

        self.verticalLayout_2 = QtWidgets.QVBoxLayout(self.gbxConnDet)
        self.verticalLayout_2.setObjectName("verticalLayout_2")
        self.lblConnName = QtWidgets.QLabel(self.gbxConnDet)
        self.lblConnName.setObjectName("lblConnName")
        self.verticalLayout_2.addWidget(self.lblConnName)
        self.ledConnName = QtWidgets.QLineEdit(self.gbxConnDet)
        self.ledConnName.setInputMask("")
        self.ledConnName.setText("")
        self.ledConnName.setObjectName("ledConnName")
        self.verticalLayout_2.addWidget(self.ledConnName)
        self.lblHost = QtWidgets.QLabel(self.gbxConnDet)
        self.lblHost.setObjectName("lblHost")
        self.verticalLayout_2.addWidget(self.lblHost)
        self.ledHost = QtWidgets.QLineEdit(self.gbxConnDet)
        self.ledHost.setInputMask("")
        self.ledHost.setText("")
        self.ledHost.setObjectName("ledHost")
        self.verticalLayout_2.addWidget(self.ledHost)
        self.lblPort = QtWidgets.QLabel(self.gbxConnDet)
        self.lblPort.setObjectName("lblPort")
        self.verticalLayout_2.addWidget(self.lblPort)
        self.ledPort = QtWidgets.QLineEdit(self.gbxConnDet)
        self.ledPort.setInputMask("")
        self.ledPort.setText("")
        self.ledPort.setObjectName("ledPort")
        self.verticalLayout_2.addWidget(self.ledPort)
        self.lblDb = QtWidgets.QLabel(self.gbxConnDet)
        self.lblDb.setObjectName("lblDb")
        self.verticalLayout_2.addWidget(self.lblDb)
        self.ledDb = QtWidgets.QLineEdit(self.gbxConnDet)
        self.ledDb.setObjectName("ledDb")
        self.verticalLayout_2.addWidget(self.ledDb)
        spacerItem = QtWidgets.QSpacerItem(20, 40, QtWidgets.QSizePolicy.Minimum, QtWidgets.QSizePolicy.Expanding)
        self.verticalLayout_2.addItem(spacerItem)
        self.lblUserName = QtWidgets.QLabel(self.gbxConnDet)
        self.lblUserName.setObjectName("lblUserName")
        self.verticalLayout_2.addWidget(self.lblUserName)
        self.ledUserName = QtWidgets.QLineEdit(self.gbxConnDet)
        self.ledUserName.setObjectName("ledUserName")
        self.verticalLayout_2.addWidget(self.ledUserName)
        self.lblPassw = QtWidgets.QLabel(self.gbxConnDet)
        self.lblPassw.setObjectName("lblPassw")
        self.verticalLayout_2.addWidget(self.lblPassw)
        self.qledPassw = gui.QgsPasswordLineEdit(self.gbxConnDet)
        self.qledPassw.setObjectName("qledPassw")
        self.verticalLayout_2.addWidget(self.qledPassw)
        self.checkBox = QtWidgets.QCheckBox(self.gbxConnDet)
        self.checkBox.setObjectName("checkBox")
        self.verticalLayout_2.addWidget(self.checkBox)
        spacerItem1 = QtWidgets.QSpacerItem(20, 40, QtWidgets.QSizePolicy.Minimum, QtWidgets.QSizePolicy.Expanding)
        self.verticalLayout_2.addItem(spacerItem1)
        self.btnConnect = QtWidgets.QPushButton(self.gbxConnDet)
        self.btnConnect.setObjectName("btnConnect")
        self.verticalLayout_2.addWidget(self.btnConnect)
        self.verticalLayout.addWidget(self.gbxConnDet)
        self.gridLayout.addLayout(self.verticalLayout, 0, 0, 1, 1)

        self.retranslateUi(dlgConnector)
        QtCore.QMetaObject.connectSlotsByName(dlgConnector)

    def retranslateUi(self, dlgConnector):
        _translate = QtCore.QCoreApplication.translate
        dlgConnector.setWindowTitle(_translate("dlgConnector", "Establish new postgres connection"))
        self.gbxConnDet.setTitle(_translate("dlgConnector", "Postgres connection credentials"))
        self.lblConnName.setText(_translate("dlgConnector", "Connection name:"))
        self.ledConnName.setPlaceholderText(_translate("dlgConnector", "e.g. myconnection"))
        self.lblHost.setText(_translate("dlgConnector", "Host:"))
        self.ledHost.setPlaceholderText(_translate("dlgConnector", "e.g. 127.0.0.1"))
        self.lblPort.setText(_translate("dlgConnector", "Port:"))
        self.ledPort.setPlaceholderText(_translate("dlgConnector", "e.g. 5432"))
        self.lblDb.setText(_translate("dlgConnector", "Database:"))
        self.ledDb.setPlaceholderText(_translate("dlgConnector", "e.g. mydatabase"))
        self.lblUserName.setText(_translate("dlgConnector", "User name:"))
        self.ledUserName.setPlaceholderText(_translate("dlgConnector", "e.g. postgres"))
        self.lblPassw.setText(_translate("dlgConnector", "Password:"))
        self.checkBox.setText(_translate("dlgConnector", "Save credentials"))
        self.btnConnect.setText(_translate("dlgConnector", "Connect"))
from qgis import gui

"""
/***************************************************************************
 Class CDBAboutDialog

        This is a QGIS plugin for the CityGML 3D City Database.
                             -------------------
        begin                : 2023-10-02
        git sha              : $Format:%H$
        author(s)            : Giorgio Agugiaro
        email                : g.agugiaro@tudelft.nl
 ***************************************************************************/

/***************************************************************************
 *                                                                         *
   Copyright 2023 Giorgio Agugiaro

   Licensed under the Apache License, Version 2.0 (the "License");
   you may not use this file except in compliance with the License.
   You may obtain a copy of the License at

       http://www.apache.org/licenses/LICENSE-2.0

   Unless required by applicable law or agreed to in writing, software
   distributed under the License is distributed on an "AS IS" BASIS,
   WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
   See the License for the specific language governing permissions and
   limitations under the License.
 *                                                                         *
 ***************************************************************************/
"""
from __future__ import annotations

import os
import webbrowser

from qgis.PyQt import uic, QtWidgets
#from qgis.PyQt.QtWidgets import QTableWidgetItem, QAction, QWidget, QMessageBox, QListWidget, QListWidgetItem
from qgis.PyQt.QtCore import QUrl
from qgis.PyQt.QtGui import QTextDocument

from . import about_constants as c

# This loads the .ui file so that PyQt can populate the plugin with the elements from Qt Designer
FORM_CLASS, _ = uic.loadUiType(os.path.join(os.path.dirname(__file__), "ui", "about_dialog.ui"))

class CDBAboutDialog(QtWidgets.QDialog, FORM_CLASS):
    """About Dialog class of the plugin. The GUI is imported from an external .ui xml
    """

    def __init__(self, parent=None):
        """Constructor"""
        super(CDBAboutDialog, self).__init__(parent)
        # Set up the user interface from Designer through FORM_CLASS.
        # After self.setupUi() you can access any designer object by doing
        # self.<objectname>, and you can use autoconnect slots
        self.setupUi(self)

        ############################################################
        ## Variables and/or constants
        ############################################################

        ############################################################
        ## Dialog initialization
        ############################################################
        url: QUrl = QUrl()

        url.setUrl(c.HTML_ABOUT)
        self.txtAbout.setSearchPaths([c.PATH_HTML])
        self.txtAbout.doSetSource(url, QTextDocument.HtmlResource)

        url.setUrl(c.HTML_DEVELOPERS)
        self.txtDevelopers.setSearchPaths([c.PATH_HTML])
        self.txtDevelopers.doSetSource(url, QTextDocument.HtmlResource)

        url.setUrl(c.HTML_CHANGELOG)
        self.txtChangelog.setSearchPaths([c.PATH_HTML])
        self.txtChangelog.doSetSource(url, QTextDocument.HtmlResource)

        url.setUrl(c.HTML_REFERENCES)
        self.txtReferences.setSearchPaths([c.PATH_HTML])
        self.txtReferences.doSetSource(url, QTextDocument.HtmlResource)

        url.setUrl(c.HTML_LICENSE)
        self.txtLicense.setSearchPaths([c.PATH_HTML])
        self.txtLicense.doSetSource(url, QTextDocument.HtmlResource)

        url.setUrl(c.HTML_3DCITYDB)
        self.txt3DCityDB.setSearchPaths([c.PATH_HTML])
        self.txt3DCityDB.doSetSource(url, QTextDocument.HtmlResource)

        #- SIGNALS  (start)  ################################################################

        self.listMenu.itemClicked.connect(self.evt_listMenu_ItemClicked)

        # Buttons
        self.btnOpenGitHub.clicked.connect(self.evt_btnOpenGitHub_clicked)
        self.btnIssueBug.clicked.connect(self.evt_btnIssueBug_clicked)

        self.btn3DCityDBDownload.clicked.connect(self.evt_btn3DCityDBDownload_clicked)
        self.btn3DCityDBInstall.clicked.connect(self.evt_btn3DCityDBInstall_clicked)
        self.btn3DCityDBManual.clicked.connect(self.evt_btn3DCityDBManual_clicked)

        self.btnClose.clicked.connect(self.evt_btnClose_clicked)

        #-SIGNALS  (end)  ################################################################

    # EVENT FUNCTIONS (begin)  #####################################################################

    def evt_listMenu_ItemClicked(self) -> None:
        """Event that is called when an item of the ListMenu is clicked
        """
        #print(self.listMenu.currentRow())
        #print(self.listMenu.currentItem().text())
        clickedRow: int = self.listMenu.currentRow()
        self.stackedContents.setCurrentIndex(clickedRow)
        return None


    def evt_btnOpenGitHub_clicked(self) -> None:
        """Event that is called when the Button 'btnOpenGitHub' is pressed.
        """
        webbrowser.open_new_tab(c.URL_GITHUB_PLUGIN)
        return None


    def evt_btnIssueBug_clicked(self) -> None:
        """Event that is called when the Button 'btnOpenGitHub' is pressed.
        """
        webbrowser.open_new_tab(c.URL_GITHUB_PLUGIN_ISSUES)
        return None


    def evt_btn3DCityDBDownload_clicked(self) -> None:
        """Event that is called when the Button 'btn3DCityDBDownload' is pressed.
        """
        webbrowser.open_new_tab(c.URL_GITHUB_3DCITYDB)
        return None


    def evt_btn3DCityDBInstall_clicked(self) -> None:
        """Event that is called when the Button 'btn3DCityDBManual' is pressed.
        """
        webbrowser.open_new_tab(c.URL_PDF_3DCITYDB_INSTALL)
        return None


    def evt_btn3DCityDBManual_clicked(self) -> None:
        """Event that is called when the Button 'btn3DCityDBManual' is pressed.
        """
        webbrowser.open_new_tab(c.URL_GITHUB_3DCITYDB_MANUAL)
        return None


    def evt_btnClose_clicked(self) -> None:
        """Event that is called when the 'Close' pushButton
        (btnClose) is pressed.
        """
        self.close()
        return None

    #-EVENT FUNCTIONS (end) #####################################################################
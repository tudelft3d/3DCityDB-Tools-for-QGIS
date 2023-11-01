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
from typing import TYPE_CHECKING
if TYPE_CHECKING:
    from ..cdb_tools_main import CDBToolsMain

import os.path

from qgis.PyQt import uic, QtWidgets
from qgis.PyQt.QtCore import QUrl 
from qgis.PyQt.QtGui import QTextDocument

from ..shared.functions import shared_functions as sh_f 
from . import about_constants as c

# This loads the .ui file so that PyQt can populate the plugin with the elements from Qt Designer
FORM_CLASS, _ = uic.loadUiType(os.path.join(os.path.dirname(__file__), "ui", "about_dialog.ui"))

class CDBAboutDialog(QtWidgets.QDialog, FORM_CLASS):
    """About Dialog class of the plugin. The GUI is imported from an external .ui xml
    """

    def __init__(self, cdbMain: CDBToolsMain, parent=None):
        """Constructor"""
        super(CDBAboutDialog, self).__init__(parent)
        # Set up the user interface from Designer through FORM_CLASS.
        # After self.setupUi() you can access any designer object by doing
        # self.<objectname>, and you can use autoconnect slots
        self.setupUi(self)

        ############################################################
        ## Variables and/or constants
        ############################################################
        #self.cdbMain = cdbMain
        self.PLUGIN_NAME: str = cdbMain.PLUGIN_NAME

        # Variable to store the name of this dialog (same as the label in the menu)
        # self.DLG_NAME_LABEL: str = cdbMain.MENU_LABEL_ABOUT
        # Variable to store the name of this dialog
        # self.DLG_NAME: str = cdbMain.DLG_NAME_ABOUT

        self.PLUGIN_ABS_PATH:    str = cdbMain.PLUGIN_ABS_PATH
        self.PLATFORM_SYSTEM:    str = cdbMain.PLATFORM_SYSTEM
        self.PLUGIN_VERSION_TXT: str = cdbMain.PLUGIN_VERSION_TXT
        self.URL_GITHUB_PLUGIN:  str = cdbMain.URL_GITHUB_PLUGIN

        ############################################################
        ## Dialog initialization
        ############################################################
        url: QUrl = QUrl()

        url.setUrl(c.HTML_ABOUT)
        self.txtAbout.setSearchPaths([c.HTML_SEARCH_PATH])
        self.txtAbout.doSetSource(url, QTextDocument.HtmlResource)

        url.setUrl(c.HTML_DEVELOPERS)
        self.txtDevelopers.setSearchPaths([c.HTML_SEARCH_PATH])
        self.txtDevelopers.doSetSource(url, QTextDocument.HtmlResource)

        url.setUrl(c.HTML_CHANGELOG)
        self.txtChangelog.setSearchPaths([c.HTML_SEARCH_PATH])
        self.txtChangelog.doSetSource(url, QTextDocument.HtmlResource)

        url.setUrl(c.HTML_REFERENCES)
        self.txtReferences.setSearchPaths([c.HTML_SEARCH_PATH])
        self.txtReferences.doSetSource(url, QTextDocument.HtmlResource)

        url.setUrl(c.HTML_LICENSE)
        self.txtLicense.setSearchPaths([c.HTML_SEARCH_PATH])
        self.txtLicense.doSetSource(url, QTextDocument.HtmlResource)

        url.setUrl(c.HTML_3DCITYDB)
        self.txt3DCityDB.setSearchPaths([c.HTML_SEARCH_PATH])
        self.txt3DCityDB.doSetSource(url, QTextDocument.HtmlResource)

        #- SIGNALS  (start)  ################################################################

        self.listMenu.itemClicked.connect(self.evt_listMenu_ItemClicked)

        # Buttons
        self.btnOpenGitHub.clicked.connect(self.evt_btnOpenGitHub_clicked)
        self.btnIssueBug.clicked.connect(self.evt_btnIssueBug_clicked)

        self.btn3DCityDBDownload.clicked.connect(self.evt_btn3DCityDBDownload_clicked)
        self.btn3DCityDBInstall.clicked.connect(self.evt_btn3DCityDBInstall_clicked)
        self.btn3DCityDBManual.clicked.connect(self.evt_btnOnline3DCityDBManual_clicked)

        self.btnClose.clicked.connect(self.evt_btnClose_clicked)

        #-SIGNALS  (end)  ################################################################

    # "NORMAL" FUNCTIONS (begin)  #####################################################################

    # "NORMAL" FUNCTIONS (end)  #####################################################################

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
        url: str = self.URL_GITHUB_PLUGIN
        sh_f.open_online_url(url)

        return None


    def evt_btnIssueBug_clicked(self) -> None:
        """Event that is called when the Button 'btnOpenGitHub' is pressed.
        """
        url: str = "/".join([self.URL_GITHUB_PLUGIN, "issues"])
        sh_f.open_online_url(url)

        return None


    def evt_btn3DCityDBDownload_clicked(self) -> None:
        """Event that is called when the Button 'btn3DCityDBDownload' is pressed.
        """
        url: str = c.URL_GITHUB_3DCITYDB
        sh_f.open_online_url(url)

        return None


    def evt_btn3DCityDBInstall_clicked(self) -> None:
        """ Event that is called when the Button 'btn3DCityDBInstall' is pressed.
        For Windows OS: Opens the default web browser with the PDF file containing the installation and user guide.
        Otherwise: Opens the url to GitHub where the PDFs are stored.
        """
        # To be activated once we have the PDFs for each main OS
        #
        if self.PLATFORM_SYSTEM == "Windows":
            file_name: str = "3DCityDB_Suite_QuickInstall.pdf"
        # elif self.PLATFORM_SYSTEM == "Darwin":
        #     file_name: str = "3DCityDB_Suite_QuickInstall_MacOS.pdf"
        # elif self.PLATFORM_SYSTEM == "Linux":
        #     file_name: str = "3DCityDB_Suite_QuickInstall_Linux.pdf"
        # else:
        #     file_name: str = "3DCityDB_Suite_QuickInstall_Linux.pdf"

        if self.PLATFORM_SYSTEM == "Windows":
            # This will open a PDF viewer instead of the browser
            pdf_path = os.path.join(self.PLUGIN_ABS_PATH, "manuals", "3dcitydb_install", file_name)
            sh_f.open_local_PDF(pdf_path)
        else:
            # url = "/".join([self.URL_GITHUB_PLUGIN, "blob", "v." + self.PLUGIN_VERSION_TXT, "manuals", "3dcitydb_install", file_name])

            # For OS other than windows, simply point to the GitHub folder because
            # we cannot automatically guess which default PDF reader (if any) they have on their system.
            url = "/".join([self.URL_GITHUB_PLUGIN, "blob", "v." + self.PLUGIN_VERSION_TXT, "manuals", "3dcitydb_install"])
            sh_f.open_online_url(url)

        # **************************************
        # Only for testing purposes
        #
        # url = "/".join([self.URL_GITHUB_PLUGIN, "blob", "v." + self.PLUGIN_VERSION_TXT, "manuals", "3dcitydb_install"])
        # url = "/".join([self.URL_GITHUB_PLUGIN, "tree", "master", "manuals", "3dcitydb_install"])
        # sh_f.open_online_url(url)
        # 
        # **************************************

        return None


    def evt_btnOnline3DCityDBManual_clicked(self) -> None:
        """Event that is called when the Button 'btn3DCityDBManual' is pressed.
        """
        url: str = c.URL_GITHUB_3DCITYDB_MANUAL
        sh_f.open_online_url(url)
    
        return None


    def evt_btnClose_clicked(self) -> None:
        """Event that is called when the 'Close' pushButton (btnClose) is pressed.
        """
        self.close()
        return None

    #-EVENT FUNCTIONS (end) #####################################################################
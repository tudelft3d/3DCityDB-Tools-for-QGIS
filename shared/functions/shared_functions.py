"""This module contains shared functions
"""
import os.path, requests, webbrowser

from qgis.PyQt.QtWidgets import QMessageBox

from qgis.core import QgsMessageLog, Qgis

from ... import cdb_tools_main_constants as main_c

def open_online_url(url: str) -> None:
    """ Opens the default web browser.
    Qt offers PyQt5.QtWebEngineWidgets (QWebEngineView, QWebEngineSettings) but they are not
    available from pyQGIS

    NOTE: webbrowser will be removed from Python v. 3.13 (QGIS using 3.9 at the moment)
    """
    plugin_name: str = main_c.PLUGIN_NAME_LABEL
    try:
        r = requests.head(url)
        if r.ok: # it is a boolean
            try:
                webbrowser.open_new_tab(url)
            except webbrowser.Error as e:
                msg = f"Webbrowser error: {e}"
                QgsMessageLog.logMessage(msg, plugin_name, level=Qgis.MessageLevel.Warning, notifyUser=True)
        elif r.status_code == 404:
            msg = f"HTTP Error 404: Page not found.<br>The following URL may be broken or dead:<br><br>{url}"
            QgsMessageLog.logMessage(msg, plugin_name, level=Qgis.MessageLevel.Warning, notifyUser=True)
            QMessageBox.warning(None, "URL unreachable", msg)
        else:
            msg = f"Error with URL<br><br>{url}."
            QgsMessageLog.logMessage(msg, plugin_name, level=Qgis.MessageLevel.Warning, notifyUser=True)
            QMessageBox.warning(None, "URL unreachable", msg) 

    except requests.ConnectionError as e:
        # print(e)
        msg = f"URL {url} could not be opened.<br><br>Is your internet connection up and working?"
        QgsMessageLog.logMessage(msg, plugin_name, level=Qgis.MessageLevel.Warning, notifyUser=True)
        QMessageBox.warning(None, "URL unreachable", msg)

    return None

def open_local_PDF(pdf_path: str) -> None:
    """ Opens the default web browser.
    Qt offers PyQt5.QtWebEngineWidgets (QWebEngineView, QWebEngineSettings) but they are not
    available from pyQGIS

    NOTE: webbrowser will be removed from Python v. 3.13 (QGIS using 3.9 at the moment...)
    """
    plugin_name: str = main_c.PLUGIN_NAME_LABEL

    if os.path.isfile(pdf_path): # The file exists
        webbrowser.open_new_tab("file:///" + pdf_path)
    else:
        msg = f"The following file could not be found in your system:<br><br>{pdf_path}"
        QgsMessageLog.logMessage(msg, plugin_name, level=Qgis.MessageLevel.Warning, notifyUser=True)
        QMessageBox.warning(None, "File not found", msg)

    return None

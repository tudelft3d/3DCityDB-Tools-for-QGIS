from qgis.PyQt.QtGui import *
from qgis.PyQt.QtWidgets import *
from qgis.core import (
    QgsProject,
    QgsMapLayerType,
    QgsDataSourceUri,
    QgsApplication
)

# initialize Qt resources from file resources.py
from . import resources

class TDCityDB_loader:

  def __init__(self, iface):
    # save reference to the QGIS interface
    self.iface = iface

  def initGui(self):
    # create action that will start plugin configuration
    self.action = QAction(QIcon(':plugins/3DCityDB-Loader/icon.png'), 
                          QApplication.translate("TDCityDB_loader", "3DCityDB plugin"),
                          self.iface.mainWindow())
    self.action.setObjectName("testAction")
    self.action.setWhatsThis("Configuration for test plugin")
    self.action.setStatusTip("This is status tip")
    self.action.triggered.connect(self.run)

    # add toolbar button and menu item
    self.iface.addDatabaseToolBarIcon(self.action)
    self.iface.addPluginToDatabaseMenu(QApplication.translate("TDCityDB_loader", None), self.action)

    # connect to signal renderComplete which is emitted when canvas
    # rendering is done
    self.iface.mapCanvas().renderComplete.connect(self.renderTest)


  def unload(self):
    # remove the plugin menu item and icon
    self.iface.databaseMenu().removeAction(self.action)
    #self.iface.removePluginDatabaseMenu("&3DCityDB Plugin", self.action)
    self.iface.removeDatabaseToolBarIcon(self.action)

    # disconnect form signal of the canvas
    self.iface.mapCanvas().renderComplete.disconnect(self.renderTest)

  def run(self):
    # create and show a configuration dialog or something similar
    print("3DCityDB-Loader: run called!")

  def renderTest(self, painter):
    # use painter for drawing to map canvas
    print("3DCityDB-Loader: renderTest called!")
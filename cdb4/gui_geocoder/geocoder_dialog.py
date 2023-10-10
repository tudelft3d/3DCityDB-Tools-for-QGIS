"""
/***************************************************************************
 Class GeoCoderDialog

        This is a QGIS plugin for the CityGML 3D City Database.
                             -------------------
        begin                : 2023-01-01
        git sha              : $Format:%H$
        author(s)            : Giorgio Agugiaro
                               Tendai Mbwanda
        email                : g.agugiaro@tudelft.nl 
                               t.mbwanda@student.tudelft.nl
                                                             
 ***************************************************************************/

/***************************************************************************
 *                                                                         *
   Copyright 2023 Giorgio Agugiaro, Tendai Mbwanda

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
import os, requests
from qgis.PyQt import uic, QtWidgets
from qgis.PyQt.QtWidgets import QMessageBox
from qgis.core import (
            Qgis, 
            QgsProject, 
            QgsRectangle, 
            QgsCoordinateReferenceSystem, 
            QgsCoordinateTransform, 
            QgsCoordinateReferenceSystem, 
            QgsProject, 
            QgsPointXY)
from qgis.gui import QgsMapCanvas

# This loads the .ui file so that PyQt can populate the plugin with the elements from Qt Designer
FORM_CLASS, _ = uic.loadUiType(os.path.join(
    os.path.dirname(__file__), "ui", "geocoder_dialog.ui"))

# class GeoCoderDialog(QtWidgets.QDialog, FORM_CLASS):
class GeoCoderDialog(QtWidgets.QDialog, FORM_CLASS):
    """GeoCoder Dialog class of the plugin.
    The GUI is imported from an external .ui xml
    """

    # def __init__(self, cdbMain: CDBToolsMain, parent=None):
    def __init__(self, dlg_crs: QgsCoordinateReferenceSystem, dlg_cdb_extents: QgsRectangle, dlg_canvas: QgsMapCanvas, parent=None):
        """Constructor."""
        super(GeoCoderDialog, self).__init__(parent)
        # Set up the user interface from Designer through FORM_CLASS.
        # After self.setupUi() you can access any designer object by doing
        # self.<objectname>, and you can use autoconnect slots
        self.setupUi(self)

        ############################################################
        ## From here you can add your variables or constants
        ############################################################
        self.srid: int = dlg_crs.postgisSrid()
        self.extents: QgsRectangle = dlg_cdb_extents
        self.canvas: QgsMapCanvas = dlg_canvas

        self.inputField.setPlaceholderText("Type here a place name, e.g. 'Padova, Italy'")

        ### SIGNALS (start) ############################
        #### Query Tab
        self.btnSearchPlace.clicked.connect(self.evt_btnSearchPlace_clicked)
        self.btnCancel1.clicked.connect(self.evt_btnCancel1_clicked)
        #### Zoom Tab
        self.btnZoomTo.clicked.connect(self.evt_btnZoomTo_clicked)
        self.btnCancel2.clicked.connect(self.evt_btnCancel2_clicked)
        ### SIGNALS (end) ##############################

    ################################################
    ### EVENTS (start) ############################

    ##### Events for 'Query tab'

    def evt_btnSearchPlace_clicked(self) -> None:
        """Event that is called when the button 'btnSearchPlace' is clicked.
        """
        # Get the place name from the GUI dialog
        place_name: str = self.inputField.text()

        if not place_name:
            msg = "Please type a place name to search, or press 'Cancel' to exit."
            QMessageBox.warning(self, "Geocoding unsuccessful", msg)
            return None

        # Set up a CRS Transformer to go from the 3DCityDB CRS to LatLon (EPSG:4326)
        CRSTransformer = QgsCoordinateTransform(                            
                            QgsCoordinateReferenceSystem(f'EPSG:{self.srid}'),
                            QgsCoordinateReferenceSystem('EPSG:4326'),
                            QgsProject.instance())

        # Create the reprojected version of the cdb_extents
        extents_4326: QgsRectangle
        extents_4326 = CRSTransformer.transformBoundingBox(
                    rectangle = self.extents, 
                    direction = Qgis.TransformDirection.Forward, 
                    handle180Crossover = True)

        # Extract the vertices defining the bbox
        lon_min: float = extents_4326.xMinimum()
        lat_min: float = extents_4326.yMinimum()
        lon_max: float = extents_4326.xMaximum()
        lat_max: float = extents_4326.yMaximum()

        # Prepare the nominatim query.
        # Prefilter only those results that are within the bbox
        viewbox: str = f"&viewbox={lon_min},{lat_min},{lon_max},{lat_max}"
        url: str = f"https://nominatim.openstreetmap.org/search?q={place_name}&limit=50&format=json{viewbox}&bounded=1"
        # print(url)    
        
        # Get the list of places
        nominatim = None
        try:
            nominatim = requests.get(url).json()
        except:
            msg = "Please check your internet connection."
            QMessageBox.warning(self, "Geocoding unsuccessful", msg)
            return None

        # If we get a response with at least one place, then
        # extract the lat lon from the json response
        # create a point and reproject it back to the 3DCityDB CRS
        # add it to the combobox
        # show the next widget page
        if len(nominatim):

            for place in nominatim:
                # print(place)

                # Extract lat lon
                wgs_location = [float(place[key]) for key in place if key in ["lat", "lon"]]

                # Create a new point
                point_4326 = QgsPointXY(wgs_location[1], wgs_location[0])

                # Reprojected the point coordinates back to the 3DCityDB EPSG code
                point: QgsPointXY
                point = CRSTransformer.transform(
                        point=point_4326, 
                        direction=Qgis.TransformDirection.Reverse)

                # Fill the combobox
                nom_label = str(place["display_name"])
                self.cbxGeocodeMatches.addItem(
                    nom_label, 
                    point)

                # Switch to the next page of the stacked Widget
                self.stackedWidget.setCurrentIndex(1)

        else:
            msg = "No matches found within the citydb extents. Please refine your search."
            QMessageBox.warning(self, "Geocoding unsuccessful", msg)
            return None

        return None


    def evt_btnCancel1_clicked(self) -> None:
        """Event that is called when the button 'btnCancel1' is clicked.
        """
        self.close()
        return None
    
        ##### Events for 'Zoom tab'

    def evt_btnZoomTo_clicked(self) -> None:
        """Event that is called when the button 'btnZoomTo' is clicked.
        """
        sel_point = self.cbxGeocodeMatches.currentData()
        self.canvas.zoomByFactor(scaleFactor=0.5, center=sel_point)
        self.close()

        return None


    def evt_btnCancel2_clicked(self) -> None:
        """Event that is called when the button 'btnCancel2' is clicked.
        """
        self.close()        
        
        return None
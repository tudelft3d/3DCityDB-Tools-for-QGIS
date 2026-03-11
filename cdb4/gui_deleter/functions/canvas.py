from __future__ import annotations
from typing import TYPE_CHECKING, cast, Iterable
if TYPE_CHECKING:       
    from ...gui_deleter.deleter_dialog import CDB4DeleterDialog

from qgis.core import QgsRectangle, QgsRasterLayer, QgsGeometry, QgsProject, QgsCoordinateReferenceSystem, QgsMapLayer
from qgis.gui import QgsRubberBand, QgsMapCanvas
from qgis.PyQt.QtCore import Qt
from qgis.PyQt.QtGui import QColor

from .. import deleter_constants as c

def canvas_setup(dlg: CDB4DeleterDialog, canvas: QgsMapCanvas, extents: QgsRectangle = c.OSM_INIT_EXTS, crs: QgsCoordinateReferenceSystem = c.OSM_INIT_CRS, clear: bool = True) -> None:
    """Function to set up the additional map canvas that shows the extents.
    For the basemap it uses a OSM maps WMS layer

    *   :param canvas: Canvas objects to put the map on.
        :type canvas: QgsMapCanvas

    *   :param extents: Extents to focus the canvas on.
        :type extents: QgsRectangle

    *   :param crs: CRS of the map.
        :type extents: QgsCoordinateReferenceSystem

    *   :param clear: Clear map registry from old OSM layers.
        :type clear: bool
    """
    # OSM id of layer.
    # registryOSM_id = [i.id() for i in QgsProject.instance().mapLayers().values() if c.OSM_NAME == i.name()]
    registryOSM_id = [i.id() for i in cast(Iterable[QgsMapLayer], QgsProject.instance().mapLayers().values()) if c.OSM_NAME == i.name()]
    dlg.qgbxExtents.setOutputExtentFromUser(extents, crs) # Signal emitted for qgbxExtents.

    # Set CRS and extents of the canvas
    canvas.setDestinationCrs(crs=crs)
    canvas.setExtent(r=extents)

    if clear:
        # Clear map registry from old OSM layers.

        ###########################################################
        # QgsProject.instance().removeMapLayers(layerIds=registryOSM_id)
        # Since QGIS 3.44, the parameter is layers and not layerIds. To keep compatibility, we simply pass the value.
        ###########################################################
        QgsProject.instance().removeMapLayers(registryOSM_id)

        # Create WMS "pseudo-layer" to set as the basemap of the canvas
        # pseudo means that the layer is not going to be added to the legend.
        rlayer: QgsRasterLayer = QgsRasterLayer(c.OSM_URI, baseName=c.OSM_NAME, providerType="wms")

        # Make sure that the layer can load properly, then add layer to the registry
        if rlayer.isValid():
            QgsProject.instance().addMapLayer(mapLayer=rlayer, addToLegend=False)

    # OSM layers object
    registryOSM_list = [i for i in QgsProject.instance().mapLayers().values() if c.OSM_NAME == i.name()]

    # Set the map canvas layer set.
    canvas.setLayers(layers=registryOSM_list)

    return None


def insert_rubber_band(band: QgsRubberBand, extents: QgsRectangle, crs: QgsCoordinateReferenceSystem, width: int, color: Qt.GlobalColor = c.DELETE_EXTENTS_COLOUR) -> None:
    """Function that insert a rubber band corresponding to an extent.
    The rubber band is inserted into the additional map canvas created to show the extents.
    Use different colors to represent different extent types, e.g.
    +   c.CDB_EXTENTS_COLOUR = citydb schema extents
    +   c.LAYER_EXTENTS_COLOUR = Layers extents

        or from qgis_pkg.extents
    +   c.CDB_EXTENTS_COLOUR = db_schema extents
    +   c.LAYER_EXTENTS_COLOUR = m_view extents

    *   :param canvas: Canvas to draw the rubber band on.
        :type extents: QgsMapCanvas

    *   :param extents: Extents to focus the canvas on.
        :type extents: QgsRectangle

    *   :param color: Color to paint the extents.
        :type color: GlobalColor

        (in 'User Connection' tab)
        (in 'Layers' tab)
    """
    # Create polygon rubber band corresponding to the extents
    extents_geometry: QgsGeometry = QgsGeometry.fromRect(rect=extents)
    band.setToGeometry(geometry=extents_geometry, crs=crs)
    band.setColor(QColor(color))
    band.setWidth(width=width)
    band.setFillColor(color=Qt.GlobalColor.transparent)

    return None


def zoom_to_extents(canvas: QgsMapCanvas, extents: QgsRectangle) -> None:
    """Function that zooms to extents provided in the given canvas.
    This funtion does not cause the passed extents variable to be changed
    to a larger area - which happens with the native metod canvas.zoomToFeatureExtent().

    This function DOES NOT fires an event of type evt_qgbxExtents_ext_changed()

    *   :param canvas: Canvas to draw the rubber band on.
        :type extents: QgsMapCanvas

    *   :param extents: Extents to focus the canvas on.
        :type extents: QgsRectangle
    """
    # In this way we overcome the problem that the variable extents will be
    # changed to new values after the zoom function, as this is not desired.
    extents_wkt: str = extents.asWktPolygon()
    rectangle: QgsRectangle = QgsRectangle().fromWkt(extents_wkt)
    canvas.zoomToFeatureExtent(rectangle)

    return None
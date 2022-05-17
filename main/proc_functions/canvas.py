from qgis.core import QgsRectangle, QgsRasterLayer
from qgis.core import QgsGeometry, QgsProject, QgsCoordinateReferenceSystem
from qgis.gui import QgsRubberBand, QgsMapCanvas
from qgis.PyQt.QtCore import Qt
from qgis.PyQt.QtGui import QColor


from .. import constants as c


def canvas_setup(dbLoader,
        canvas=QgsMapCanvas(),
        extents=c.OSM_INIT_EXTS,
        crs=c.OSM_INIT_CRS,
        clear=True) -> None:
    """Function to set up the additional map canvas that shows the extents.

    For the base map it uses a OSM maps WMS layer

    *   :param canvas: Canvas objects to put the map on.

        :type canvas: QgsMapCanvas

    *   :param extents: Extents to focus the canvas on.

        :type extents: QgsRectangle

    *   :param crs: CRS of the map.

        :type extents: QgsCoordinateReferenceSystem

        (in 'User Connection' tab)
        (in 'Layers' tab)
    """
    # OSM id of layer.
    registryOSM_id = [i.id() for i in QgsProject.instance().mapLayers().values() if c.OSM_NAME == i.name()]
    
    if canvas==dbLoader.CANVAS_C: # in 'User Connection' tab
        # Put extents coordinates into the widget. Singal emitted for qgbxExtentsC.
        dbLoader.dlg.qgbxExtentsC.setOutputExtentFromUser(extents,crs)
    elif canvas==dbLoader.CANVAS: # in 'Layers' tab
        # Put extents coordinates into the widget. Singal emitted for qgbxExtents.
        dbLoader.dlg.qgbxExtents.setOutputExtentFromUser(extents,crs)


    # Set CRS and extents of the canvas
    canvas.setDestinationCrs(crs)
    canvas.setExtent(extents)
    if clear:
        # Clear map registry from old OSM layers.
        QgsProject.instance().removeMapLayers(registryOSM_id)

        # Create WMS "pseudo-layer" to set as the basemap of the canvas
        # pseudo means that the layer is not going to be added to the legentd.
        rlayer = QgsRasterLayer(c.OSM_URI,
            baseName=c.OSM_NAME,
            providerType="wms")

        # Make sure that the layer can load properly
        assert rlayer.isValid()

        # Add layer to the registry
        QgsProject.instance().addMapLayer(rlayer, addToLegend=False)



    # OSM layers object
    registryOSM_l = [i for i in QgsProject.instance().mapLayers().values() if c.OSM_NAME == i.name()]
    # Set the map canvas layer set.
    canvas.setLayers(registryOSM_l)

def insert_rubber_band(band: QgsRubberBand,
        extents: QgsRectangle,
        crs: QgsCoordinateReferenceSystem,
        width: int,
        color: Qt.GlobalColor = Qt.red) -> None:
    """Function that insert a rubber band correspoding to an extent.

    The rubber band is inserted into the additional map canvas created
    to show the extents.

    Use different color to represent differnt extent types
    e.g.
    +   Qt.blue = citydb schema extents
    +   Qt.red = Layers extents
    +   Qt.green = User defined extents, pressing the buttons

        or from qgis_pkg.extents
    +   Qt.blue = db_schema extents
    +   Qt.red = m_view extents
    +   Qt.green = qgis extents

    *   :param canvas: Canvas to draw the rubber band on.

        :type extents: QgsMapCanvas

    *   :param extents: Extents to focus the canvas on.

        :type extents: QgsRectangle

    *   :param color: Color to paint the extents.

        :type color: GlobalColor

        (in 'User Connection' tab)
        (in 'Layers' tab)
    """

    # Create polygon rubber band corespoding to the extents
    #band = QgsRubberBand(canvas, QgsWkbTypes.PolygonGeometry)
    extents_geometry = QgsGeometry.fromRect(extents)
    band.setToGeometry(extents_geometry,crs)
    band.setColor(QColor(color))
    band.setWidth(width)
    band.setFillColor(Qt.transparent)
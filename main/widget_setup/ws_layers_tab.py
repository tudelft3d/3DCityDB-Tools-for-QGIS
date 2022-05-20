
from qgis.core import Qgis,QgsMessageLog, QgsGeometry, QgsRectangle, QgsProject
from qgis.PyQt.QtCore import Qt
from qgis.PyQt.QtWidgets import QMessageBox
import psycopg2

from ..proc_functions import pf_layers_tab as lrs_tab
from ..proc_functions import canvas
from ..proc_functions import sql
from .. import constants as c
from . import widget_reset



FILE_LOCATION = c.get_file_location(file=__file__)

# In 'Basemap (OMS)' groupBox.
def gbxBasemap_setup(dbLoader,canvas_widget) ->  None:
    """Function to setup the 'Basemap' groupbox.
    It uses an additional canvas instance to store an OSM map
    from which extents can be extracted for further spatial queries.

    The basemap is zoomed-in the city model's entents.

    (in 'Layers' tab)

    .. While this function is almost identical to the one handling the
    canvas in the User Connection tab, I think, it is prudent to diplicate
    for better debuggin comprehension.
    """

    # Put extents coordinates into the widget.
    #dbLoader.dlg.qgbxExtentsC.setOutputExtentFromUser(dbLoader.SCHEMA_EXTENTS,dbLoader.CRS)


    # Set basemap.
    canvas.canvas_setup(dbLoader,
        canvas=canvas_widget,
        extents=dbLoader.VIEWS_EXTENTS,
        crs=dbLoader.CRS,
        clear=False)

    # Draw citydb extents rubberband.
    canvas.insert_rubber_band(band=dbLoader.RUBBER_SCHEMA,
        extents=dbLoader.SCHEMA_EXTENTS,
        crs=dbLoader.CRS,
        width=3,
        color=Qt.blue)

    # Draw mat views extents rubberband.
    canvas.insert_rubber_band(band=dbLoader.RUBBER_LAYERS,
        extents=dbLoader.VIEWS_EXTENTS,
        crs=dbLoader.CRS,
        width=2,
        color=Qt.red)

    # Zoom to Schema extents.
    canvas_widget.zoomToFeatureExtent(dbLoader.SCHEMA_EXTENTS)


    # Get the mat views extents stored in server.
    extents = sql.fetch_extents(dbLoader,
            from_schema=dbLoader.USER_SCHEMA,
            for_schema=dbLoader.SCHEMA,
            ext_type=c.MAT_VIEW_EXT_TYPE)

    # Extents might be None (not computed yet).
    if extents:

        # Store extents into plugin variable.
        dbLoader.USER_EXTENTS = QgsRectangle.fromWkt(extents)

        # Draw the extents in the canvas
        # Create polygon rubber band corespoding to the extents
        canvas.insert_rubber_band(band=dbLoader.RUBBER_USER,
            extents=dbLoader.USER_EXTENTS,
            crs=dbLoader.CRS,
            width=1,
            color=Qt.green)

    else:
        raise Exception('compute_schema_extent server function returned None')


def qgbxExtents_setup(dbLoader) -> None:
    """Function to setup the gui after an extentChanged signal is emitted from
    one of the qgbxExtents's embedded pushbuttons.
    (e.g. 'Calculate from Layer', 'Map Canvas Extent','Draw on Canvas'*)
    Fills the 'Feature Type' widget.

    This function runs every time the extents in the widget change.

    (in 'Layers' tab)
    """
    # NOTE: 'Draw on Canvas'* has an undesired effect.
    # There is a hardcoded True value that causes the parent dialog to
    # toggle its visibility to let the user draw. But in our case
    # the parent dialog contains the canvas that we need to draw on.
    # Re-opening the plugin allows us to draw in the canvas but with the
    # caveat that the drawing tool never closes (also cause some qgis crashes).
    # https://github.com/qgis/QGIS/blob/master/src/gui/qgsextentgroupbox.cpp
    # https://github.com/qgis/QGIS/blob/master/src/gui/qgsextentwidget.h
    # line 251 extentDrawn function
    # https://qgis.org/pyqgis/3.16/gui/QgsExtentGroupBox.html
    # https://qgis.org/pyqgis/3.16/gui/QgsExtentWidget.html

    # Update extents variable with the ones that fired the signal.
    dbLoader.EXTENTS = dbLoader.dlg.qgbxExtents.outputExtent()
    if dbLoader.EXTENTS.isNull() or dbLoader.VIEWS_EXTENTS.isNull():
        return None

    # Draw the extents in the addtional canvas (basemap)
    canvas.insert_rubber_band(band=dbLoader.RUBBER_USER,
        extents=dbLoader.EXTENTS,
        crs=dbLoader.CRS,
        width=2,
        color=Qt.green)

    # Compare original extents with user defined ones.
    lrs_exts= QgsGeometry.fromRect(dbLoader.EXTENTS)
    orig_exts= QgsGeometry.fromRect(dbLoader.VIEWS_EXTENTS)

    # Check validity of user extents relative to the City Model's extents.
    if not lrs_exts.intersects(orig_exts):
        QMessageBox.critical(dbLoader.dlg,
            "Warning",
            "No data can be found here!\nPick a region inside 'layers' extents (red area).")
        return None
    else:
        dbLoader.USER_EXTENTS = dbLoader.EXTENTS

    widget_reset.reset_gbxLayerSelection(dbLoader)
    dbLoader.dlg.gbxLayerSelection.setDisabled(False)
    # Operations cascade to a lot of functions from here!
    # Based on the selected extents fill out the Feature Types combo box.
    lrs_tab.fill_FeatureType_box(dbLoader)

    return None

def btnCityExtents_setup(dbLoader) -> None:
    """Function to setup the gui after a click signal is emitted from
    the btnCityExtents pushButton.

    This function runs every time the 'Set to layers extents' button
    is pressed.

    (in 'User Connection' tab)
    """

    # Get the extents stored in server (already computed at this point).
    extents = sql.fetch_extents(dbLoader,
        from_schema=dbLoader.USER_SCHEMA,
        for_schema=dbLoader.SCHEMA,
        ext_type=c.MAT_VIEW_EXT_TYPE)
    assert extents, "Extents don't exist but should have been aleady computed!"

    # Convert extents format to QgsRectangle object.
    extents = QgsRectangle.fromWkt(extents)
    # Update extents in plugin variable.
    dbLoader.EXTENTS = extents

    # Put extents coordinates into the widget.
    dbLoader.dlg.qgbxExtents.setOutputExtentFromUser(dbLoader.EXTENTS,dbLoader.CRS)
    # At this point an extentChanged signal is emitted.

    # Zoom to these extents.
    dbLoader.CANVAS.zoomToFeatureExtent(extents)

def cbxFeatureType_setup(dbLoader) -> None:
    """Function to setup the gui after a 'currentIndexChanged' signal is
    emitted from cbxFeatureType. Fills the 'LoD' widget.

    This function runs every time the selected Feature Type in the widget
    changes.

    (in 'Layers' tab)
    """

    # Clear 'Geometry Level' combo box from previous runs.
    dbLoader.dlg.cbxLod.clear()

    # Enable 'Geometry Level' combo box
    dbLoader.dlg.cbxLod.setDisabled(False)

    # Fill out the LoDs, based on the selected extents and Feature Type.
    lrs_tab.fill_lod_box(dbLoader)

def cbxLod_setup(dbLoader) -> None:
    """Function to setup the gui after a 'currentIndexChanged' signal is
    emitted from cbxLod. Fills the 'features' widget.

    This function runs every time the selected LoD in the widget
    changes.

    (in 'Layers' tab)
    """

    # Enable 'Features to Import' group box.
    dbLoader.dlg.gbxAvailableL.setDisabled(False)

    # Clear 'Features' checkable combo box from previous runs.
    dbLoader.dlg.ccbxFeatures.clear()
    # Revert to initial text.
    dbLoader.dlg.ccbxFeatures.setDefaultText(dbLoader.dlg.ccbxFeatures.init_text)

    # Fill out the features.
    lrs_tab.fill_features_box(dbLoader)

def ccbxFeatures_setup(dbLoader) -> None:
    """Function to setup the gui after a 'checkedItemsChanged' signal is
    emitted from ccbxFeatures. Shows selected layers with their number of
    features..

    This function runs every time a layer is selected in the widget.

    (in 'Layers' tab)
    """

    # Get all the selected layers (views).
    checked_views = dbLoader.dlg.ccbxFeatures.checkedItems()

    if checked_views:
        # Enable 'Import' pushbutton.
        dbLoader.dlg.btnImport.setDisabled(False)
    else:
        # Revert to inital text and disable 'Import' pushbutton
        dbLoader.dlg.btnImport.setDisabled(True)

def btnImport_setup(dbLoader) -> None:
    """Function to setup the gui after a click signal is emitted from
    the btnImport pushButton.

    This function runs every time the 'Import' button is pressed.

    (in 'Layers' tab)
    """

    # Get the data that is checked from 'ccbxFeatures'
    # Remebmer widget hold items in the form of (view_name,View_object)
    checked_views = lrs_tab.get_checkedItemsData(dbLoader.dlg.ccbxFeatures)
    #checked_views = dbLoader.dlg.ccbxFeatures.checkedItemsData() NOTE: this builtin method works only for string types. Check https://qgis.org/api/qgscheckablecombobox_8cpp_source.html line 173

    # Get the total number of features to be imported.
    counter = 0
    for view in checked_views:
        counter += view.n_selected

    # Wrarn user when too many features are to be imported. (Subjective value).
    if counter>20000:
        res= QMessageBox.question(dbLoader.dlg,
            "Warning",
            f"Too many features set to be imported ({counter})!\n"
            "This could hinder perfomance and even cause frequent crashes.\n"
            "Do you want to continue?")
        if res == 16384: # YES
            success = lrs_tab.import_layers(dbLoader,layers=checked_views)
        else: return None #Import Cancelled
    else:
        success = lrs_tab.import_layers(dbLoader,layers=checked_views)

    if not success:
        QgsMessageLog.logMessage(message="Something went wrong on Import!",
            tag="3DCityDB-Loader",
            level=Qgis.Critical,
            notifyUser=True)
        return None


    # Structure 'Table of Contents' tree.
    db_group = lrs_tab.get_node_database(dbLoader)
    lrs_tab.sort_ToC(db_group)
    lrs_tab.send_to_top_ToC(db_group)

    #At last bring the Relief, Feature type at the bottom of the ToC.
    lrs_tab.send_to_bottom_ToC(QgsProject.instance().layerTreeRoot())

    #Set CRS of the project to match the server's.
    QgsProject.instance().setCrs(dbLoader.CRS)
    # A final success message.
    QgsMessageLog.logMessage(message="",tag="3DCityDB-Loader",level=Qgis.Success,notifyUser=True)
    return None

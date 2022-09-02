"""This module contains operations that relate to time consuming
processes like installation or mainly refresh views.

The purpose of this module is to hint the user that a heavy process is
running in the background, so that they don't think that the plugin crashed,
or froze.

The plugin runs on single thread, meaning that in such processes the plugin
'freezes' until completion. But without warning or visual cue the user could
think that it broke.

To avoid this module provides two visuals cues.
1. Progress bar.
2. Disabling the entire plugin (gray-out to ignore signals from panic clicking)

This is done by assigning a working thread for the
heavy process. In the main thread the progress bar is assigned to
update following the heavy process taking place in the worker thread.
"""


from qgis.PyQt.QtCore import QObject,QThread,pyqtSignal, Qt
from qgis.PyQt.QtWidgets import QProgressBar, QVBoxLayout
from qgis.core import Qgis, QgsMessageLog
from qgis.gui import QgsMessageBar
import psycopg2

from ....cdb_loader import CDBLoader # Used only to add the type of the function parameters

from ...gui_db_connector.functions import conn_functions as conn_f
from .... import main_constants as main_c
from ... import cdb4_constants as c

from . import tab_layers_widget_functions as lt_wf
from . import sql

def create_progress_bar(dialog, layout: QVBoxLayout, position: int) -> None:
    """Function that creates a QProgressBar embedded into
    a QgsMessageBar, in a specific position in the GUI.

    *   :param layout: QLayout of the gui where the bar is to be
            assigned.

        :type layout: QBoxLayout

    *   :param position: The place (index) in the layout to place
            the progress bar

        :type position: int

    """

    # Create QgsMessageBar instance.
    dialog.msg_bar = QgsMessageBar()

    # Add the message bar into the input layer and position.
    layout.insertWidget(position, dialog.msg_bar)

    # Create QProgressBar instance into QgsMessageBar.
    dialog.bar = QProgressBar(parent=dialog.msg_bar)

    # Setup progress bar.
    dialog.bar.setAlignment(Qt.AlignLeft|Qt.AlignVCenter)
    dialog.bar.setStyleSheet("text-align: left;")

    # Show progress bar in message bar.
    dialog.msg_bar.pushWidget(dialog.bar, Qgis.Info)


class LayerCreationWorker(QObject):
    """Class to assign Worker that executes the 'layer creation' SQL
    functions in the database."""

    # Create custom signals.
    finished = pyqtSignal()
    progress = pyqtSignal(str, int, str)
    success = pyqtSignal()
    fail = pyqtSignal()

    def __init__(self, cdbLoader: CDBLoader):
        super().__init__()
        self.plg = cdbLoader

    def create_thread(self):
        """Execution method that creates the layers
        using function from the 'qgis_pkg' installation.
        """
        # Flag to help us break from a failing installation.
        fail_flag = False

        # Set progress bar goal
        self.plg.usr_dlg.bar.setMaximum(len(c.create_layers_funcs))

        # Get corners coordinates
        y_min = str(self.plg.LAYER_EXTENTS.yMinimum())
        x_min = str(self.plg.LAYER_EXTENTS.xMinimum())
        y_max = str(self.plg.LAYER_EXTENTS.yMaximum())
        x_max = str(self.plg.LAYER_EXTENTS.xMaximum())

        # Set function input
        params = [
            self.plg.DB.username,
            self.plg.CDB_SCHEMA,
            int(self.plg.usr_dlg.gbxSimplifyGeom.isChecked()),
            self.plg.usr_dlg.qspbDecimalPrec.value(),
            self.plg.usr_dlg.qspbMinArea.value(),
            "{"+",".join([x_min, y_min, x_max, y_max])+"}",
            False
            ]

        # Open new temp session
        with conn_f.connect(db_connection=self.plg.DB, app_name=f"{conn_f.connect.__defaults__[0]} (Layer creation)") as conn:
            for s, module_func in enumerate(c.create_layers_funcs, start=1):

                # Update progress bar with current step and script.
                text = " ".join(["Executing:", module_func])
                self.progress.emit("main", s, text)
                try:
                    # Attempt direct sql injection.
                    with conn.cursor() as cursor:
                        cursor.callproc(f"{main_c.QGIS_PKG_SCHEMA}.{module_func}", [*params])
                    conn.commit()

                except (Exception, psycopg2.DatabaseError) as error:
                    print(error)
                    fail_flag = True
                    conn.rollback()
                    self.fail.emit()
                    break

        # No FAIL = SUCCESS
        if not fail_flag:
            self.success.emit()
        self.finished.emit()


def create_layers_thread(cdbLoader: CDBLoader) -> None:
    """Function that create layers in the user schema in the database
    by branching a new Worker thread to execute the operation on.
    """

    for index in range(cdbLoader.usr_dlg.vLayoutUserConn.count()):
        widget = cdbLoader.usr_dlg.vLayoutUserConn.itemAt(index).widget()
        if widget.objectName() == "btnCreateLayers":
            # Add a new progress bar to follow the installation procedure.
            create_progress_bar(
                dialog=cdbLoader.usr_dlg,
                layout=cdbLoader.usr_dlg.vLayoutUserConn,
                position=index+1)
            break

    # Create new thread object.
    cdbLoader.thread = QThread()
    # Instantiate worker object for the operation.
    cdbLoader.worker = LayerCreationWorker(cdbLoader)
    # Move worker object to the be executed on the new thread.
    cdbLoader.worker.moveToThread(cdbLoader.thread)

    #-SIGNALS (start) #######################################################

    # Execute worker's 'run' method.
    cdbLoader.thread.started.connect(cdbLoader.worker.create_thread)

    # Capture progress to show in bar.
    cdbLoader.worker.progress.connect(cdbLoader.evt_update_bar)

    # Get rid of worker and thread objects.
    cdbLoader.worker.finished.connect(cdbLoader.thread.quit)
    cdbLoader.worker.finished.connect(cdbLoader.worker.deleteLater)
    cdbLoader.thread.finished.connect(cdbLoader.thread.deleteLater)

    # On installation status
    cdbLoader.worker.success.connect(lambda: ev_layers_success(cdbLoader))
    cdbLoader.worker.fail.connect(lambda: ev_layers_fail(cdbLoader))

    #-SIGNALS (end) #######################################################

    # Initiate worker thread
    cdbLoader.thread.start()


class RefreshMatViewsWorker(QObject):
    """Class to assign Worker that executes the 'refresh_mview'
    function from qgis_pkg in the server, into an additional thread."""

    # Create custom signals.
    finished = pyqtSignal()
    progress = pyqtSignal(str, int, str)
    fail = pyqtSignal()

    def __init__(self, cdbLoader: CDBLoader):
        super().__init__()
        self.plg = cdbLoader

    def refresh_all_mat_views(self):
        """Execution method that refreshes the materialized views in the
        server (for a specific schema).
        """

        # Get feature types from layer_metadata table.
        cols_to_featch = ",".join(["feature_type","mv_name"])
        col, ftype_mview = sql.fetch_layer_metadata(
                                            self.plg,
                                            usr_schema = self.plg.USR_SCHEMA,
                                            cdb_schema=self.plg.CDB_SCHEMA,
                                            cols=cols_to_featch)
        col = None # Discard byproduct.

        # Set progress bar goal
        self.plg.usr_dlg.bar.setMaximum(len(ftype_mview))

        # Open new temp session, reserved for mat refresh.
        with conn_f.connect(db_connection=self.plg.DB, app_name=f"{conn_f.connect.__defaults__[0]} (Refresh)") as conn:
            for s, (ftype, mview) in enumerate(ftype_mview):

                # Update progress bar with current step and text.
                text = " ".join(["Refreshing materialized views of:", ftype])
                self.progress.emit("main", s, text)

                try:
                    sql.refresh_mat_view(cdbLoader=self.plg, connection=conn, m_view=mview)
                    conn.commit()
                    # time.sleep(0.05) # Use this for debugging instead of waiting for mats.

                except (Exception, psycopg2.DatabaseError) as error:
                    print(error)
                    conn.rollback()
                    self.fail.emit()

        self.finished.emit()


def refresh_views_thread(cdbLoader: CDBLoader) -> None:
    """Function that refreshes the materialized views in the database
    by branching a new Worker thread to execute the operation on.
    """

    for index in range(cdbLoader.usr_dlg.vLayoutUserConn.count()):
        widget = cdbLoader.usr_dlg.vLayoutUserConn.itemAt(index).widget()
        if widget.objectName() == "btnRefreshLayers":
            # Add a new progress bar to follow the installation procedure.
            create_progress_bar(
                dialog=cdbLoader.usr_dlg,
                layout=cdbLoader.usr_dlg.vLayoutUserConn,
                position=index+1)
            break

    # Create new thread object.
    cdbLoader.thread = QThread()
    # Instantiate worker object for the operation.
    cdbLoader.worker = RefreshMatViewsWorker(cdbLoader)
    # Move worker object to the be executed on the new thread.
    cdbLoader.worker.moveToThread(cdbLoader.thread)

    #----------################################################################
    #-SIGNALS--################################################################
    #-(start)--################################################################

    # Disable widgets to avoid queuing signals.
    cdbLoader.thread.started.connect(lambda: cdbLoader.usr_dlg.btnRefreshLayers.setDisabled(True))
    cdbLoader.thread.started.connect(lambda: cdbLoader.usr_dlg.btnCreateLayers.setDisabled(True))
    cdbLoader.thread.started.connect(lambda: cdbLoader.usr_dlg.btnDropLayers.setDisabled(True))
    cdbLoader.thread.started.connect(lambda: cdbLoader.usr_dlg.tabLayers.setDisabled(True))

    # Execute worker's 'run' method.
    cdbLoader.thread.started.connect(cdbLoader.worker.refresh_all_mat_views)

    # Capture progress to show in bar.
    cdbLoader.worker.progress.connect(cdbLoader.evt_update_bar)

    # Get rid of worker and thread objects.
    cdbLoader.worker.finished.connect(cdbLoader.thread.quit)
    cdbLoader.worker.finished.connect(cdbLoader.worker.deleteLater)
    cdbLoader.thread.finished.connect(cdbLoader.thread.deleteLater)

    # Enable widgets.
    cdbLoader.thread.finished.connect(lambda: cdbLoader.usr_dlg.btnRefreshLayers.setDisabled(False))
    cdbLoader.thread.finished.connect(lambda: cdbLoader.usr_dlg.btnCreateLayers.setDisabled(False))
    cdbLoader.thread.finished.connect(lambda: cdbLoader.usr_dlg.btnDropLayers.setDisabled(False))
    cdbLoader.thread.finished.connect(lambda: cdbLoader.usr_dlg.tabLayers.setDisabled(False))

    cdbLoader.worker.finished.connect(lambda: ev_refresh_success(cdbLoader))

    #----------################################################################
    #-SIGNALS--################################################################
    #-(end)--##################################################################

    # Initiate worker thread
    cdbLoader.thread.start()


class LayerDroppingWorker(QObject):
    """Class to assign Worker that executes the 'layer dropping' SQL
    functions in the database."""

    # Create custom signals.
    finished = pyqtSignal()
    progress = pyqtSignal(str, int, str)
    success = pyqtSignal()
    fail = pyqtSignal()

    def __init__(self, cdbLoader: CDBLoader):
        super().__init__()
        self.plg = cdbLoader

    def create_thread(self):
        """Execution method that creates the layers
        using function from the 'qgis_pkg' installation.
        """
        # Flag to help us break from a failing installation.
        fail_flag = False

        # Set progress bar goal
        self.plg.usr_dlg.bar.setMaximum(len(c.drop_layers_funcs))

        # Open new temp session, reserved for installation.
        with conn_f.connect(db_connection=self.plg.DB, app_name=f"{conn_f.connect.__defaults__[0]} (Dropping Layers)") as conn:
            for s, module_func in enumerate(c.drop_layers_funcs, start=1):
                # Update progress bar with current step and script.
                text = " ".join(["Executing:", module_func])
                self.progress.emit("main", s, text)
                try:
                    # Attempt direct sql injection.
                    with conn.cursor() as cursor:
                        cursor.callproc(f"{main_c.QGIS_PKG_SCHEMA}.{module_func}", [self.plg.USR_SCHEMA, self.plg.CDB_SCHEMA])
                    conn.commit()
                except (Exception, psycopg2.DatabaseError) as error:
                    QgsMessageLog.logMessage(
                        message=error,
                        tag=main_c.PLUGIN_NAME,
                        level=Qgis.Critical,
                        notifyUser=True)
                    fail_flag = True
                    conn.rollback()
                    self.fail.emit()
                    break

        # No FAIL = SUCCESS
        if not fail_flag:
            self.success.emit()
        self.finished.emit()


def drop_layers_thread(cdbLoader: CDBLoader) -> None:
    """Function that drops layers of the user schema in the database
    by branching a new Worker thread to execute the operation on.
    """

    # The sole purpose of the loop here is to find the widget's index in
    # the layout, in order to put the progress bar just below it.
    for index in range(cdbLoader.usr_dlg.vLayoutUserConn.count()):
        widget = cdbLoader.usr_dlg.vLayoutUserConn.itemAt(index).widget()
        if widget is None: continue
        if widget.objectName() == "btnDropLayers":
            # Add a new progress bar to follow the dropping procedure.
            create_progress_bar(
                dialog=cdbLoader.usr_dlg,
                layout=cdbLoader.usr_dlg.vLayoutUserConn,
                position=index+1)
            break

    # Create new thread object.
    cdbLoader.thread = QThread()
    # Instantiate worker object for the operation.
    cdbLoader.worker = LayerDroppingWorker(cdbLoader)
    # Move worker object to the be executed on the new thread.
    cdbLoader.worker.moveToThread(cdbLoader.thread)

    #-SIGNALS--################################################################
    #-(start)--################################################################

    # Execute worker's 'run' method.
    cdbLoader.thread.started.connect(cdbLoader.worker.create_thread)

    # Capture progress to show in bar.
    cdbLoader.worker.progress.connect(cdbLoader.evt_update_bar)

    # Get rid of worker and thread objects.
    cdbLoader.worker.finished.connect(cdbLoader.thread.quit)
    cdbLoader.worker.finished.connect(cdbLoader.worker.deleteLater)
    cdbLoader.thread.finished.connect(cdbLoader.thread.deleteLater)

    # On installation status
    cdbLoader.worker.success.connect(lambda: ev_drop_layers_success(cdbLoader))
    cdbLoader.worker.fail.connect(lambda: ev_drop_layers_fail(cdbLoader))

    #-SIGNALS--################################################################
    #--(end)---################################################################

    # Initiate worker thread
    cdbLoader.thread.start()


###--EVENTS (start)########################################################

def ev_refresh_success(cdbLoader: CDBLoader) -> None:
    """Event that is called when the thread executing the refresh
    finishes successfully.

    Shows success message at cdbLoader.usr_dlg.msg_bar: QgsMessageBar
    Shows success message in Connection Status groupbox
    Shows success message in QgsMessageLog
    """

    # Remove progress bar
    cdbLoader.usr_dlg.msg_bar.clearWidgets()

    # Check if the materialised views are populated. # NOTE: duplicate code?
    refresh_date = sql.fetch_layer_metadata(
            cdbLoader, 
            usr_schema=cdbLoader.USR_SCHEMA, 
            cdb_schema=cdbLoader.CDB_SCHEMA, 
            cols="refresh_date")
    # Extract a date.
    date =list(set(refresh_date[1]))[0][0]

    if date:
        # Replace with Success msg.
        msg = cdbLoader.usr_dlg.msg_bar.createMessage("Materialized views successfully refreshed!")
        cdbLoader.usr_dlg.msg_bar.pushWidget(msg, Qgis.Success, 5)

        # Inform user
        cdbLoader.usr_dlg.lblLayerRefr_out.setText(c.success_html.format(text=c.REFR_LAYERS_MSG.format(date=date)))
        QgsMessageLog.logMessage(
                message="Materialized views successfully refreshed!",
                tag=main_c.PLUGIN_NAME,
                level=Qgis.Success,
                notifyUser=True)

        # Setup GUI
        cdbLoader.usr_dlg.tabLayers.setDisabled(False)
        cdbLoader.usr_dlg.lblInfoText.setDisabled(False)
        cdbLoader.usr_dlg.lblInfoText.setText(cdbLoader.usr_dlg.lblInfoText.init_text.format(
            db=cdbLoader.DB.database_name,
            usr=cdbLoader.DB.username,
            sch=cdbLoader.CDB_SCHEMA))
        cdbLoader.usr_dlg.gbxBasemap.setDisabled(False)
        cdbLoader.usr_dlg.qgbxExtents.setDisabled(False)
        cdbLoader.usr_dlg.btnCityExtents.setDisabled(False)
        cdbLoader.usr_dlg.btnCityExtents.setText(cdbLoader.usr_dlg.btnCityExtents.init_text.format(sch="layers extents"))
        lt_wf.gbxBasemap_setup(cdbLoader, cdbLoader.CANVAS)


def ev_layers_success(cdbLoader: CDBLoader) -> None:
    """Event that is called when the thread executing the layer
    creation finishes successfully.

    Shows success message at cdbLoader.usr_dlg.msg_bar: QgsMessageBar
    Shows success message in Connection Status groupbox
    Shows success message in QgsMessageLog
    """

    # Remove progress bar
    cdbLoader.usr_dlg.msg_bar.clearWidgets()

    if sql.exec_support_for_schema(cdbLoader):
        # Replace with Success msg.
        msg = cdbLoader.usr_dlg.msg_bar.createMessage(c.LAYER_CR_SUCC_MSG.format(sch=cdbLoader.USR_SCHEMA))
        cdbLoader.usr_dlg.msg_bar.pushWidget(msg, Qgis.Success, 5)

        # Inform user
        cdbLoader.usr_dlg.lblSupport_out.setText(c.success_html.format(text=c.SCHEMA_SUPP_MSG.format(sch=cdbLoader.USR_SCHEMA)))
        QgsMessageLog.logMessage(
                message=c.LAYER_CR_SUCC_MSG.format(sch=cdbLoader.USR_SCHEMA),
                tag=main_c.PLUGIN_NAME,
                level=Qgis.Success,
                notifyUser=True)
        
        # Now that layers have been created:
        # Allow the option to refresh them.
        cdbLoader.usr_dlg.btnRefreshLayers.setDisabled(False)
        # Allow the option to delete them.
        cdbLoader.usr_dlg.btnDropLayers.setDisabled(False)
    else:
        ev_layers_fail(cdbLoader)


def ev_layers_fail(cdbLoader: CDBLoader) -> None:
    """Event that is called when the thread executing the layer creations
    emits a fail signal meaning that something went wrong with the process.

    Shows fail message at cdbLoader.usr_dlg.msg_bar: QgsMessageBar
    Shows fail message in Connection Status groupbox
    Shows fail message in QgsMessageLog
    """

    # Remove progress bar
    cdbLoader.usr_dlg.msg_bar.clearWidgets()

    # Replace with Failure msg.
    msg = cdbLoader.usr_dlg.msg_bar.createMessage(c.LAYER_CR_ERROR_MSG.format(sch=cdbLoader.USR_SCHEMA))
    cdbLoader.usr_dlg.msg_bar.pushWidget(msg, Qgis.Critical, 5)

    # Inform user
    cdbLoader.usr_dlg.lblSupport_out.setText(c.failure_html.format(text=c.SCHEMA_SUPP_FAIL_MSG.format(sch=cdbLoader.CDB_SCHEMA)))
    QgsMessageLog.logMessage(
            message=c.LAYER_CR_ERROR_MSG.format(sch=cdbLoader.USR_SCHEMA),
            tag=main_c.PLUGIN_NAME,
            level=Qgis.Critical,
            notifyUser=True)


def ev_drop_layers_success(cdbLoader: CDBLoader) -> None:
    """Event that is called when the thread executing the layer
    dropping finishes successfully.

    Shows success message at cdbLoader.usr_dlg.msg_bar: QgsMessageBar
    Shows success message in Connection Status groupbox
    Shows success message in QgsMessageLog
    """

    # Remove progress bar
    cdbLoader.usr_dlg.msg_bar.clearWidgets()

    if not sql.exec_support_for_schema(cdbLoader):
        # Replace with Success msg.
        msg = cdbLoader.usr_dlg.msg_bar.createMessage(c.LAYER_DR_SUCC_MSG.format(sch=cdbLoader.USR_SCHEMA))
        cdbLoader.usr_dlg.msg_bar.pushWidget(msg, Qgis.Success, 5)

        # Inform user that now there aren't any layers in its schema
        cdbLoader.usr_dlg.lblSupport_out.setText(c.failure_html.format(text=c.SCHEMA_SUPP_FAIL_MSG.format(sch=cdbLoader.CDB_SCHEMA)))
        cdbLoader.usr_dlg.lblLayerRefr_out
        QgsMessageLog.logMessage(
                message=c.LAYER_DR_SUCC_MSG.format(sch=cdbLoader.USR_SCHEMA),
                tag=main_c.PLUGIN_NAME,
                level=Qgis.Success,
                notifyUser=True)

        # Now that layers have been removed. Disable the option to delete them.
        # Disable the option to refresh them.
        cdbLoader.usr_dlg.btnRefreshLayers.setDisabled(True)
        # Disable the option to delete them.
        cdbLoader.usr_dlg.btnDropLayers.setDisabled(True)
        cdbLoader.usr_dlg.lblLayerRefr_out.clear()
    else:
        ev_drop_layers_fail(cdbLoader)


def ev_drop_layers_fail(cdbLoader: CDBLoader) -> None:
    """Event that is called when the thread executing the layer dropping
    emits a fail signal meaning that something went wrong with the process.

    Shows fail message at cdbLoader.usr_dlg.msg_bar: QgsMessageBar
    Shows fail message in Connection Status groupbox
    Shows fail message in QgsMessageLog
    """

    # Remove progress bar
    cdbLoader.usr_dlg.msg_bar.clearWidgets()

    # Replace with Failure msg.
    msg = cdbLoader.usr_dlg.msg_bar.createMessage(c.LAYER_DR_ERROR_MSG.format(sch=cdbLoader.USR_SCHEMA))
    cdbLoader.usr_dlg.msg_bar.pushWidget(msg, Qgis.Critical, 5)

    # Inform user that the layers are now corrupted.
    cdbLoader.usr_dlg.lblSupport_out.setText(c.crit_warning_html.format(text=c.LAYER_DR_ERROR_MSG.format(sch=cdbLoader.USR_SCHEMA)))
    QgsMessageLog.logMessage(
            message=c.LAYER_DR_ERROR_MSG.format(sch=cdbLoader.USR_SCHEMA),
            tag=main_c.PLUGIN_NAME,
            level=Qgis.Critical,
            notifyUser=True)

###--EVENTS (end) ########################################################


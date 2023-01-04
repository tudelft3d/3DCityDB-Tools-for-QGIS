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

from qgis.PyQt.QtCore import QObject, QThread, pyqtSignal
from qgis.core import Qgis, QgsMessageLog
import psycopg2

from ....cdb_loader import CDBLoader # Used only to add the type of the function parameters

from ...gui_db_connector.functions import conn_functions as conn_f
from ... import cdb4_constants as c

from . import sql


class LayerDroppingWorker(QObject):
    """Class to assign Worker that executes the 'layer dropping' SQL functions in the database.
    """
    # Create custom signals.
    finished = pyqtSignal()
    progress = pyqtSignal(str, int, str)
    success = pyqtSignal()
    fail = pyqtSignal()

    def __init__(self, cdbLoader: CDBLoader):
        super().__init__()
        self.plugin = cdbLoader

    def create_thread(self):
        dlg = self.plugin.deleter_dlg
        """Execution method that creates the layers using function from the 'qgis_pkg' installation.
        """
        # Flag to help us break from a failing installation.
        fail_flag: bool = False

        # Set progress bar goal
        dlg.bar.setMaximum(len(c.drop_layers_funcs))

        # Open new temp session, reserved for installation.
        with conn_f.connect(db_connection=self.plugin.DB, app_name=f"{conn_f.connect.__defaults__[0]} (Dropping layers)") as conn:
            for s, module_func in enumerate(c.drop_layers_funcs, start=1):
                # Update progress bar with current step and script.
                text = " ".join(["Executing:", module_func])
                self.progress.emit(self.plugin.DELETER_DLG, s, text)
                try:
                    with conn.cursor() as cursor:
                        cursor.callproc(f"{self.plugin.QGIS_PKG_SCHEMA}.{module_func}", [self.plugin.USR_SCHEMA, self.plugin.CDB_SCHEMA])
                    conn.commit()
                except (Exception, psycopg2.DatabaseError) as error:
                    QgsMessageLog.logMessage(
                        message=error,
                        tag=self.plugin.PLUGIN_NAME,
                        level=Qgis.Critical,
                        notifyUser=True)
                    fail_flag = True
                    conn.rollback()
                    self.fail.emit()
                    break
        
        if not fail_flag: # No FAIL = SUCCESS
            self.success.emit()
        self.finished.emit()


def drop_layers_thread(cdbLoader: CDBLoader) -> None:
    """Function that drops layers of the user schema in the database
    by branching a new Worker thread to execute the operation on.
    """
    dlg = cdbLoader.deleter_dlg

    # The sole purpose of the loop here is to find the widget's index in
    # the layout, in order to put the progress bar just below it.
    for index in range(dlg.vLayoutUserConn.count()):
        widget = dlg.vLayoutUserConn.itemAt(index).widget()
        if widget is None: continue
        if widget.objectName() == "btnDropLayers":
            # Add a new progress bar to follow the dropping procedure.
            cdbLoader.create_progress_bar(dialog=dlg, layout=dlg.vLayoutUserConn, position=index+1)
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

def ev_drop_layers_success(cdbLoader: CDBLoader) -> None:
    """Event that is called when the thread executing the layer dropping finishes successfully.

    Shows success message at cdbLoader.usr_dlg.msg_bar: QgsMessageBar
    Shows success message in Connection Status groupbox
    Shows success message in QgsMessageLog
    """
    dlg = cdbLoader.deleter_dlg

    # Remove progress bar
    dlg.msg_bar.clearWidgets()

    if not sql.exec_has_layers_for_cdb_schema(cdbLoader):
        # Replace with Success msg.
        msg = dlg.msg_bar.createMessage(c.LAYER_DR_SUCC_MSG.format(sch=cdbLoader.USR_SCHEMA))
        dlg.msg_bar.pushWidget(msg, Qgis.Success, 5)

        # Inform user that now there aren't any layers in its schema
        dlg.lblLayerExist_out.setText(c.failure_html.format(text=c.SCHEMA_LAYER_FAIL_MSG.format(sch=cdbLoader.CDB_SCHEMA)))
        dlg.lblLayerRefr_out
        QgsMessageLog.logMessage(
                message=c.LAYER_DR_SUCC_MSG.format(sch=cdbLoader.USR_SCHEMA),
                tag=cdbLoader.PLUGIN_NAME,
                level=Qgis.Success,
                notifyUser=True)

        # Now that layers have been removed. Disable the option to delete them.
        # Disable the option to refresh them.
        dlg.btnRefreshLayers.setDisabled(True)
        # Disable the option to delete them.
        dlg.btnDropLayers.setDisabled(True)
        dlg.lblLayerRefr_out.clear()
    else:
        ev_drop_layers_fail(cdbLoader)


def ev_drop_layers_fail(cdbLoader: CDBLoader) -> None:
    """Event that is called when the thread executing the layer dropping
    emits a fail signal meaning that something went wrong with the process.

    Shows fail message at cdbLoader.usr_dlg.msg_bar: QgsMessageBar
    Shows fail message in Connection Status groupbox
    Shows fail message in QgsMessageLog
    """
    dlg = cdbLoader.deleter_dlg

    # Remove progress bar
    dlg.msg_bar.clearWidgets()

    # Replace with Failure msg.
    msg = dlg.msg_bar.createMessage(c.LAYER_DR_ERROR_MSG.format(sch=cdbLoader.USR_SCHEMA))
    dlg.msg_bar.pushWidget(msg, Qgis.Critical, 5)

    # Inform user that the layers are now corrupted.
    dlg.lblLayerExist_out.setText(c.crit_warning_html.format(text=c.LAYER_DR_ERROR_MSG.format(sch=cdbLoader.USR_SCHEMA)))
    QgsMessageLog.logMessage(
            message=c.LAYER_DR_ERROR_MSG.format(sch=cdbLoader.USR_SCHEMA),
            tag=cdbLoader.PLUGIN_NAME,
            level=Qgis.Critical,
            notifyUser=True)

###--EVENTS (end) ########################################################
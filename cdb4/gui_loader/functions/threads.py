"""This module contains operations that relate to time consuming
processes.

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
import time

from qgis.PyQt.QtCore import QObject, QThread, pyqtSignal
from qgis.core import Qgis, QgsMessageLog
import psycopg2, psycopg2.sql as pysql

from ....cdb_tools_main import CDBToolsMain # Used only to add the type of the function parameters

from ...gui_db_connector.functions import conn_functions as conn_f
from ...shared.functions import general_functions as gen_f

from .. import loader_constants as c
from ..other_classes import FeatureType

from . import tab_conn_functions as tc_f
from . import sql

FILE_LOCATION = gen_f.get_file_relative_path(file=__file__)

#####################################################################################
##### CREATE LAYERS WORKER ##########################################################
#####################################################################################

def run_create_layers_thread(cdbMain: CDBToolsMain) -> None:
    """Function that creates layers in the user schema in the database
    by branching a new Worker thread to execute the operation on.
    """
    dlg = cdbMain.loader_dlg

    for index in range(dlg.vLayoutUserConn.count()):
        widget = dlg.vLayoutUserConn.itemAt(index).widget()
        if not widget:
            continue # Needed to avoid errors with layouts, vertical spacers, etc.
        if widget.objectName() == "gbxLayerButtons":
            # Add a new progress bar to follow the installation procedure.
            cdbMain.create_progress_bar(dialog=dlg, layout=dlg.vLayoutUserConn, position=index+1)
            break
   
    # Create new thread object.
    cdbMain.thread = QThread()
    # Instantiate worker object for the operation.
    cdbMain.worker = CreateLayersWorker(cdbMain)
    # Move worker object to the be executed on the new thread.
    cdbMain.worker.moveToThread(cdbMain.thread)

    #-SIGNALS (start) #######################################################
    # Anti-panic clicking: Disable widgets to avoid queuing signals.
    cdbMain.thread.started.connect(lambda: dlg.btnRefreshLayers.setDisabled(True))
    cdbMain.thread.started.connect(lambda: dlg.gbxFeatSel.setDisabled(True))
    cdbMain.thread.started.connect(lambda: dlg.btnCreateLayers.setDisabled(True))
    cdbMain.thread.started.connect(lambda: dlg.btnDropLayers.setDisabled(True))
    cdbMain.thread.started.connect(lambda: dlg.tabLayers.setDisabled(True))
    cdbMain.thread.started.connect(lambda: dlg.tabSettings.setDisabled(True))

    # Execute worker's 'run' method.
    cdbMain.thread.started.connect(cdbMain.worker.create_layers_thread)

    # Capture progress to show in bar.
    cdbMain.worker.sig_progress.connect(cdbMain.evt_update_bar)

    # Get rid of worker and thread objects.
    cdbMain.worker.sig_finished.connect(cdbMain.thread.quit)
    cdbMain.worker.sig_finished.connect(cdbMain.worker.deleteLater)
    cdbMain.thread.finished.connect(cdbMain.thread.deleteLater)

    # Reenable the GUI
    # cdbMain.thread.finished.connect(lambda: dlg.gbxFeatSel.setDisabled(False))
    # cdbMain.thread.finished.connect(lambda: dlg.btnCreateLayers.setDisabled(False))
    # cdbMain.thread.finished.connect(lambda: dlg.btnRefreshLayers.setDisabled(False))
    # cdbMain.thread.finished.connect(lambda: dlg.btnDropLayers.setDisabled(False))
    # cdbMain.thread.finished.connect(lambda: dlg.tabLayers.setDisabled(False))
    cdbMain.thread.finished.connect(lambda: dlg.tabSettings.setDisabled(False))
    cdbMain.thread.finished.connect(dlg.msg_bar.clearWidgets)

    # On installation status
    cdbMain.worker.sig_success.connect(lambda: evt_create_layers_success(cdbMain))
    cdbMain.worker.sig_fail.connect(lambda: evt_create_layers_fail(cdbMain))

    #-SIGNALS (end) #######################################################

    # Initiate worker thread
    cdbMain.thread.start()


class CreateLayersWorker(QObject):
    """Class to assign Worker that executes the 'layer creation' SQL functions in the database.
    """
    # Create custom signals.
    sig_finished = pyqtSignal()
    sig_progress = pyqtSignal(str, int, str)
    sig_success = pyqtSignal()
    sig_fail = pyqtSignal()

    def __init__(self, cdbMain: CDBToolsMain):
        super().__init__()
        self.plugin = cdbMain

    def create_layers_thread(self):
        """Execution method that creates the layers using function from the 'qgis_pkg' installation.
        """
        dlg = self.plugin.loader_dlg

        # Flag to help us break from a failing loop.
        fail_flag: bool = False

        funcs_list = []
        ft: FeatureType
        if dlg.gbxFeatSel.isChecked():
            # Update the FeatureTypeMetadata with the information about the selected ones
            for ft in dlg.FeatureTypesRegistry.values():
                if ft.is_selected and ft.name != "CityObjectGroup":
                # if ft.is_selected and ft.name != "CityObjectGroup":
                    funcs_list.append(ft.layers_create_function)
        else:
            # Update the FeatureTypeMetadata with the information about the existing ones
            for ft in dlg.FeatureTypesRegistry.values():
                if ft.exists and ft.name != "CityObjectGroup":
                # if ft.exists:
                    funcs_list.append(ft.layers_create_function)
        # print("selected feature types funcs", funcs_list)

        n_iter_steps = len(funcs_list)

        # Set progress bar goal
        dlg.bar.setMaximum(n_iter_steps)

        bbox: str
        if dlg.LAYER_EXTENTS == dlg.CDB_SCHEMA_EXTENTS:
            bbox = None
        else:
            # Get corners coordinates
            y_min = str(dlg.LAYER_EXTENTS.yMinimum())
            x_min = str(dlg.LAYER_EXTENTS.xMinimum())
            y_max = str(dlg.LAYER_EXTENTS.yMaximum())
            x_max = str(dlg.LAYER_EXTENTS.xMaximum())
            bbox = "{"+",".join([x_min, y_min, x_max, y_max])+"}"

        # Set function input
        params = [
            self.plugin.DB.username,
            self.plugin.CDB_SCHEMA,
            int(dlg.gbxGeomSimp.isChecked()), # 0 (False) or 1 (True)
            dlg.qspbDecimalPrec.value(),
            dlg.qspbMinArea.value(),
            bbox,
            dlg.cbxForceLayerGen.isChecked() # True or False
            ]

        try:
            # Open new temp session
            temp_conn = conn_f.create_db_connection(db_connection=self.plugin.DB, app_name=" ".join([self.plugin.PLUGIN_NAME_LOADER, "(Create layers)"]))
            with temp_conn:

                # Start measuring time
                time_start = time.time()

                for s, module_func in enumerate(funcs_list, start=1):

                    query = pysql.SQL("""
                                SELECT {_qgis_pkg_schema}.{_module_func}({_params});
                                """).format(
                                _qgis_pkg_schema = pysql.Identifier(self.plugin.QGIS_PKG_SCHEMA),
                                _module_func = pysql.Identifier(module_func),
                                _params = pysql.SQL(", ").join(pysql.Placeholder() * len(params))
                                )

                    # Update progress bar
                    msg = f"Executing: {module_func}"
                    self.sig_progress.emit(self.plugin.DLG_NAME_LOADER, s, msg)

                    try:
                        with temp_conn.cursor() as cur:
                            cur.execute(query, params)
                        temp_conn.commit()

                    except (Exception, psycopg2.Error) as error:
                        temp_conn.rollback()
                        fail_flag = True
                        gen_f.critical_log(
                            func=self.create_layers_thread,
                            location=FILE_LOCATION,
                            header="Creating layers",
                            error=error)
                        self.sig_fail.emit()
                        break

            # Measure elapsed time
            print(f"Create layers process completed in {round((time.time() - time_start), 4)} seconds")

        except (Exception, psycopg2.Error) as error:
            fail_flag = True
            gen_f.critical_log(
                func=self.create_layers_thread,
                location=FILE_LOCATION,
                header="Establishibng temporary connection",
                error=error)
            self.sig_fail.emit()

        # No FAIL = SUCCESS
        if not fail_flag:
            self.sig_success.emit()
        
        self.sig_finished.emit()
        # Close temp connection
        temp_conn.close()
        return None

###--EVENTS (start)########################################################

def evt_create_layers_success(cdbMain: CDBToolsMain) -> None:
    """Event that is called when the thread executing the layer creation finishes successfully.

    Shows success message at cdbMain.loader_dlg.msg_bar: QgsMessageBar
    Shows success message in Connection Status groupbox
    Shows success message in QgsMessageLog
    """
    dlg = cdbMain.loader_dlg

    # Remove progress bar
    # dlg.msg_bar.clearWidgets()

    # Update the layer extents in the corresponding table in the server.
    sql.exec_upsert_extents(cdbMain=cdbMain, bbox_type=c.LAYER_EXT_TYPE, extents_wkt_2d_poly=dlg.LAYER_EXTENTS.asWktPolygon())

    # Perform the activities related to checking layers status, and get the result
    check_layers_refresh_status: bool = tc_f.check_layers_status(cdbMain)

    if not check_layers_refresh_status:
        evt_create_layers_fail(cdbMain) 

    return None

def evt_create_layers_fail(cdbMain: CDBToolsMain) -> None:
    """Event that is called when the thread executing the layer creations
    emits a fail signal meaning that something went wrong with the process.

    Shows fail message at cdbMain.loader_dlg.msg_bar: QgsMessageBar
    Shows fail message in Connection Status groupbox
    Shows fail message in QgsMessageLog
    """
    dlg = cdbMain.loader_dlg

    # Replace with Failure msg.
    msg = dlg.msg_bar.createMessage(c.LAYER_CR_ERROR_MSG.format(sch=cdbMain.USR_SCHEMA))
    dlg.msg_bar.pushWidget(msg, Qgis.Critical, 5)

    # Inform user
    dlg.lblLayerExist_out.setText(c.failure_html.format(text=c.SCHEMA_LAYER_FAIL_MSG.format(sch=cdbMain.CDB_SCHEMA)))
    QgsMessageLog.logMessage(
            message=c.LAYER_CR_ERROR_MSG.format(sch=cdbMain.USR_SCHEMA),
            tag=cdbMain.PLUGIN_NAME,
            level=Qgis.Critical,
            notifyUser=True)
    
    return None

###--EVENTS (end) ########################################################

#####################################################################################
##### REFRESH LAYERS WORKER #########################################################
#####################################################################################

def run_refresh_layers_thread(cdbMain: CDBToolsMain) -> None:
    """Function that refreshes the materialized views in the database
    by branching a new Worker thread to execute the operation on.
    """
    dlg = cdbMain.loader_dlg

    for index in range(dlg.vLayoutUserConn.count()):
        widget = dlg.vLayoutUserConn.itemAt(index).widget()
        if not widget:
            continue
        if widget.objectName() == "gbxLayerButtons":
            # Add a new progress bar to follow the installation procedure.
            cdbMain.create_progress_bar(dialog=dlg, layout=dlg.vLayoutUserConn, position=index+1)
            break

    # Create new thread object.
    cdbMain.thread = QThread()
    # Instantiate worker object for the operation.
    cdbMain.worker = RefreshLayersWorker(cdbMain)
    # Move worker object to the be executed on the new thread.
    cdbMain.worker.moveToThread(cdbMain.thread)

    #-SIGNALS---(start)--################################################################
    # Disable widgets to avoid queuing signals.
    cdbMain.thread.started.connect(lambda: dlg.btnRefreshLayers.setDisabled(True))
    cdbMain.thread.started.connect(lambda: dlg.gbxFeatSel.setDisabled(True))
    cdbMain.thread.started.connect(lambda: dlg.btnCreateLayers.setDisabled(True))
    cdbMain.thread.started.connect(lambda: dlg.btnDropLayers.setDisabled(True))
    cdbMain.thread.started.connect(lambda: dlg.tabLayers.setDisabled(True))
    cdbMain.thread.started.connect(lambda: dlg.tabSettings.setDisabled(True))

    # Execute worker's 'run' method.
    cdbMain.thread.started.connect(cdbMain.worker.refresh_all_gviews_thread)

    # Capture progress to show in bar.
    cdbMain.worker.sig_progress.connect(cdbMain.evt_update_bar)

    # Get rid of worker and thread objects.
    cdbMain.worker.sig_finished.connect(cdbMain.thread.quit)
    cdbMain.worker.sig_finished.connect(cdbMain.worker.deleteLater)
    cdbMain.thread.finished.connect(cdbMain.thread.deleteLater)

    # (Re)Enable widgets.

    # cdbMain.thread.finished.connect(lambda: dlg.btnCreateLayers.setDisabled(False))
    cdbMain.thread.finished.connect(lambda: dlg.btnRefreshLayers.setDisabled(False))
    cdbMain.thread.finished.connect(lambda: dlg.btnDropLayers.setDisabled(False))
    # cdbMain.thread.finished.connect(lambda: dlg.tabLayers.setDisabled(False))
    cdbMain.thread.finished.connect(lambda: dlg.tabSettings.setDisabled(False))
    cdbMain.thread.finished.connect(dlg.msg_bar.clearWidgets)

    cdbMain.worker.sig_finished.connect(lambda: evt_refresh_layers_success(cdbMain))
    #-SIGNALS---(end)--################################################################

    # Initiate worker thread
    cdbMain.thread.start()

    return None


class RefreshLayersWorker(QObject):
    """Class to assign Worker that executes the 'refresh_mview'
    function from qgis_pkg in the server, into an additional thread.
    """
    # Create custom signals.
    sig_finished = pyqtSignal()
    sig_progress = pyqtSignal(str, int, str)
    sig_fail = pyqtSignal()
    # sig_success = pyqtSignal()

    def __init__(self, cdbMain: CDBToolsMain):
        super().__init__()
        self.plugin = cdbMain

    def refresh_all_gviews_thread(self):
        """Execution method that refreshes the materialized views in the server (for a specific schema).
        """
        dlg = self.plugin.loader_dlg
        usr_schema = self.plugin.USR_SCHEMA

        # Flag to help us break from a failing loop.
        fail_flag: bool = False

        # Get feature types from layer_metadata table.
        cols_to_fetch: list = ["feature_type","gv_name"]
        col, feattype_geom_mview = sql.fetch_layer_metadata(cdbMain=self.plugin, usr_schema=self.plugin.USR_SCHEMA, cdb_schema=self.plugin.CDB_SCHEMA, cols_list=cols_to_fetch)
        col = None # Discard byproduct.

        # Set progress bar goal
        dlg.bar.setMaximum(len(feattype_geom_mview))

        try:
            # Open new temp session, reserved for mat refresh.
            temp_conn = conn_f.create_db_connection(db_connection=self.plugin.DB, app_name=" ".join([self.plugin.PLUGIN_NAME_LOADER, "(Refresh layers)"]))
            with temp_conn:

                # Start measuring time
                time_start = time.time()

                for s, (ftype, mview) in enumerate(feattype_geom_mview):

                    query = pysql.SQL("""
                        REFRESH MATERIALIZED VIEW {_usr_schema}.{_gv_name};
                        """).format(
                        _usr_schema = pysql.Identifier(usr_schema),
                        _gv_name = pysql.Identifier(mview)
                        )
                    query2 = pysql.SQL("""
                        UPDATE {_usr_schema}.layer_metadata
                        SET refresh_date = clock_timestamp()
                        WHERE gv_name = {_gv_name};
                        """).format(
                        _usr_schema = pysql.Identifier(usr_schema),
                        _gv_name = pysql.Literal(mview)
                        )

                    # Update progress bar
                    msg = f"Refreshing {ftype} layers"
                    self.sig_progress.emit(self.plugin.DLG_NAME_LOADER, s, msg)

                    try:
                        with temp_conn.cursor() as cur:
                            cur.execute(query)
                            cur.execute(query2)
                        temp_conn.commit()
                        # time.sleep(0.05) # Use this for debugging instead of waiting for mats.

                    except (Exception, psycopg2.Error) as error:
                        temp_conn.rollback()
                        fail_flag = True
                        gen_f.critical_log(
                            func=self.refresh_all_gviews_thread,
                            location=FILE_LOCATION,
                            header="Refreshing layers",
                            error=error)
                        self.sig_fail.emit()

            # Measure elapsed time
            print(f"Refresh layers process completed in {round((time.time() - time_start), 4)} seconds")

        except (Exception, psycopg2.Error) as error:
            fail_flag = True
            gen_f.critical_log(
                func=self.refresh_all_gviews_thread,
                location=FILE_LOCATION,
                header="Establishibng temporary connection",
                error=error)
            self.sig_fail.emit()

        # No FAIL = SUCCESS
        if not fail_flag:
            # self.sig_success.emit() # At the moment, there is not success signal slot
            pass
        
        self.sig_finished.emit()
        # Close temp connection
        temp_conn.close()
        return None


###--EVENTS (start)########################################################

def evt_refresh_layers_success(cdbMain: CDBToolsMain) -> None:
    """Event that is called when the thread executing the refresh finishes successfully.

    Shows success message at cdbMain.loader_dlg.msg_bar: QgsMessageBar
    Shows success message in Connection Status groupbox
    Shows success message in QgsMessageLog
    """
    tc_f.check_layers_status(cdbMain)    

    return None

###--EVENTS (end) ########################################################

#####################################################################################
##### DROP LAYERS WORKER ############################################################
#####################################################################################

def run_drop_layers_thread(cdbMain: CDBToolsMain) -> None:
    """Function that drops layers of the user schema in the database
    by branching a new Worker thread to execute the operation on.
    """
    dlg = cdbMain.loader_dlg

    # The sole purpose of the loop here is to find the widget's index in
    # the layout, in order to put the progress bar just below it.
    for index in range(dlg.vLayoutUserConn.count()):
        widget = dlg.vLayoutUserConn.itemAt(index).widget()
        if not widget: 
            continue
        if widget.objectName() == "gbxLayerButtons":
            # Add a new progress bar to follow the dropping procedure.
            cdbMain.create_progress_bar(dialog=dlg, layout=dlg.vLayoutUserConn, position=index+1)
            break

    # Create new thread object.
    cdbMain.thread = QThread()
    # Instantiate worker object for the operation.
    cdbMain.worker = DropLayersWorker(cdbMain)
    # Move worker object to the be executed on the new thread.
    cdbMain.worker.moveToThread(cdbMain.thread)

    #-SIGNALS--(start)--################################################################
    # Disable widgets to avoid queuing signals.
    cdbMain.thread.started.connect(lambda: dlg.gbxFeatSel.setDisabled(True))
    cdbMain.thread.started.connect(lambda: dlg.btnCreateLayers.setDisabled(True))
    cdbMain.thread.started.connect(lambda: dlg.btnRefreshLayers.setDisabled(True))
    cdbMain.thread.started.connect(lambda: dlg.btnDropLayers.setDisabled(True))
    cdbMain.thread.started.connect(lambda: dlg.tabLayers.setDisabled(True))
    cdbMain.thread.started.connect(lambda: dlg.tabSettings.setDisabled(True))

    # Execute worker's 'run' method.
    cdbMain.thread.started.connect(cdbMain.worker.drop_layers_thread)

    # Capture progress to show in bar.
    cdbMain.worker.sig_progress.connect(cdbMain.evt_update_bar)

    # Get rid of worker and thread objects.
    cdbMain.worker.sig_finished.connect(cdbMain.thread.quit)
    cdbMain.worker.sig_finished.connect(cdbMain.worker.deleteLater)
    cdbMain.thread.finished.connect(cdbMain.thread.deleteLater)

    # (Re)Enable widgets.

    # cdbMain.thread.finished.connect(lambda: dlg.btnCreateLayers.setDisabled(False))
    cdbMain.thread.finished.connect(lambda: dlg.gbxFeatSel.setDisabled(False))
    cdbMain.thread.finished.connect(lambda: dlg.btnCreateLayers.setDisabled(False))
    cdbMain.thread.finished.connect(lambda: dlg.btnDropLayers.setDisabled(True))
    cdbMain.thread.finished.connect(lambda: dlg.btnRefreshLayers.setDisabled(True))
    cdbMain.thread.finished.connect(lambda: dlg.tabLayers.setDisabled(True))
    cdbMain.thread.finished.connect(lambda: dlg.tabSettings.setDisabled(False))
    cdbMain.thread.finished.connect(dlg.msg_bar.clearWidgets)

    # On installation status
    cdbMain.worker.sig_success.connect(lambda: evt_drop_layers_success(cdbMain))
    cdbMain.worker.sig_fail.connect(lambda: evt_drop_layers_fail(cdbMain))
    #-SIGNALS--(end)---################################################################

    # Initiate worker thread
    cdbMain.thread.start()

    return None

class DropLayersWorker(QObject):
    """Class to assign Worker that executes the 'layer dropping' SQL functions in the database.
    """
    # Create custom signals.
    sig_finished = pyqtSignal()
    sig_progress = pyqtSignal(str, int, str)
    sig_success = pyqtSignal()
    sig_fail = pyqtSignal()

    def __init__(self, cdbMain: CDBToolsMain):
        super().__init__()
        self.plugin = cdbMain

    def drop_layers_thread(self):
        dlg = self.plugin.loader_dlg
        """Execution method that drops the layers using functions from the qgis_pkg.
        """
        # Flag to help us break from a failing installation.
        fail_flag: bool = False

        feat_type = ()
        feat_types = sql.fetch_unique_feature_types_in_layer_metadata(self.plugin)

        if not feat_types:
            self.sig_finished.emit()
            return None

        funcs_list = []
        ft: FeatureType
        for feat_type in feat_types:
            ft = dlg.FeatureTypesRegistry[feat_type]
            funcs_list.append(ft.layers_drop_function)

        n_iter_steps = len(funcs_list)

        # Set progress bar goal
        dlg.bar.setMaximum(n_iter_steps)

        try:
            # Open new temp session, reserved for dropping layers.
            temp_conn = conn_f.create_db_connection(db_connection=self.plugin.DB, app_name=" ".join([self.plugin.PLUGIN_NAME_LOADER, "(Drop layers)"]))
            with temp_conn:

                # Start measuring time
                time_start = time.time()

                for s, module_func in enumerate(funcs_list, start=1):

                    query = pysql.SQL("""
                                SELECT {_qgis_pkg_schema}.{_module_func}({_usr_schema}, {_cdb_schema});
                                """).format(
                                _qgis_pkg_schema = pysql.Identifier(self.plugin.QGIS_PKG_SCHEMA),
                                _module_func = pysql.Identifier(module_func),
                                _usr_schema = pysql.Literal(self.plugin.USR_SCHEMA),
                                _cdb_schema = pysql.Literal(self.plugin.CDB_SCHEMA)
                                )

                    # Update progress bar
                    msg = f"Executing: {module_func}"
                    self.sig_progress.emit(self.plugin.DLG_NAME_LOADER, s, msg)
                    
                    try:
                        with temp_conn.cursor() as cur:
                            cur.execute(query)
                        temp_conn.commit()

                    except (Exception, psycopg2.Error) as error:
                        temp_conn.rollback()
                        fail_flag = True
                        gen_f.critical_log(
                            func=self.drop_layers_thread,
                            location=FILE_LOCATION,
                            header="Dropping layers",
                            error=error)
                        self.sig_fail.emit()
                        break

            # Measure elapsed time
            print(f"Drop layers process completed in {round((time.time() - time_start), 4)} seconds")

        except (Exception, psycopg2.Error) as error:
            fail_flag = True
            gen_f.critical_log(
                func=self.drop_layers_thread,
                location=FILE_LOCATION,
                header="Establishibng temporary connection",
                error=error)
            self.sig_fail.emit()

        if not fail_flag: # No FAIL = SUCCESS
            self.sig_success.emit()
        
        self.sig_finished.emit()
        # Close temp connection
        temp_conn.close()
        return None


###--EVENTS (start)########################################################

def evt_drop_layers_success(cdbMain: CDBToolsMain) -> None:
    """Event that is called when the thread executing the layer dropping finishes successfully.

    Shows success message at cdbMain.loader_dlg.msg_bar: QgsMessageBar
    Shows success message in Connection Status groupbox
    Shows success message in QgsMessageLog
    """
    dlg = cdbMain.loader_dlg

    layers_exist_status: bool = tc_f.check_layers_status(cdbMain)

    if not layers_exist_status: # i.e. we have successfully dropped all layers

        # Replace with Success msg.
        msg = dlg.msg_bar.createMessage(c.LAYER_DR_SUCC_MSG.format(sch=cdbMain.USR_SCHEMA))
        dlg.msg_bar.pushWidget(msg, Qgis.Success, 5)

        # Inform user that now there aren't any layers in its schema
        dlg.lblLayerExist_out.setText(c.failure_html.format(text=c.SCHEMA_LAYER_FAIL_MSG.format(sch=cdbMain.CDB_SCHEMA)))
        dlg.lblLayerRefr_out
        QgsMessageLog.logMessage(
                message=c.LAYER_DR_SUCC_MSG.format(sch=cdbMain.USR_SCHEMA),
                tag=cdbMain.PLUGIN_NAME,
                level=Qgis.Success,
                notifyUser=True)

    else:
        evt_drop_layers_fail(cdbMain)

    return None


def evt_drop_layers_fail(cdbMain: CDBToolsMain) -> None:
    """Event that is called when the thread executing the layer dropping
    emits a fail signal meaning that something went wrong with the process.

    Shows fail message at cdbMain.loader_dlg.msg_bar: QgsMessageBar
    Shows fail message in Connection Status groupbox
    Shows fail message in QgsMessageLog
    """
    dlg = cdbMain.loader_dlg

    # Replace with Failure msg.
    msg = dlg.msg_bar.createMessage(c.LAYER_DR_ERROR_MSG.format(sch=cdbMain.USR_SCHEMA))
    dlg.msg_bar.pushWidget(msg, Qgis.Critical, 5)

    # Inform user that the layers are now corrupted.
    dlg.lblLayerExist_out.setText(c.crit_warning_html.format(text=c.LAYER_DR_ERROR_MSG.format(sch=cdbMain.USR_SCHEMA)))
    QgsMessageLog.logMessage(
            message=c.LAYER_DR_ERROR_MSG.format(sch=cdbMain.USR_SCHEMA),
            tag=cdbMain.PLUGIN_NAME,
            level=Qgis.Critical,
            notifyUser=True)

    return None
###--EVENTS (end) ########################################################
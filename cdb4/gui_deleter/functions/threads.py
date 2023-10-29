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
from __future__ import annotations
from typing import TYPE_CHECKING
if TYPE_CHECKING:       
    from ...gui_deleter.deleter_dialog import CDB4DeleterDialog
    from ..other_classes import FeatureType, TopLevelFeature

import math, time
from qgis.PyQt.QtCore import QObject, QThread, pyqtSignal
from qgis.core import Qgis, QgsMessageLog
import psycopg2, psycopg2.sql as pysql

from ...gui_db_connector.functions import conn_functions as conn_f
from ...shared.functions import general_functions as gen_f
from .. import deleter_constants as c
from . import tab_conn_functions as tc_f

FILE_LOCATION = gen_f.get_file_relative_path(file=__file__)

#####################################################################################
##### CLEAN UP SCHEMA ###############################################################
#####################################################################################

def run_cleanup_schema_thread(dlg: CDB4DeleterDialog) -> None:
    """Function that uninstalls the qgis_pkg schema from the database
    by branching a new Worker thread to execute the operation on.
    """
    # Add a new progress bar to follow the installation procedure.
    for index in range(dlg.vLayoutUserConn.count()):
        widget = dlg.vLayoutUserConn.itemAt(index).widget()
        if not widget:
            continue # Needed to avoid errors with layouts, vertical spacers, etc.
        if widget.objectName() == "gbxCleanUpSchema":
            # Add a new progress bar to follow the deletion procedure.
            dlg.create_progress_bar(layout=dlg.vLayoutUserConn, position=index+1)
            break

    # Create new thread object.
    dlg.thread = QThread()
    # Instantiate worker object for the operation.
    dlg.worker = CleanUpSchemaWorker(dlg)
    # Move worker object to the be executed on the new thread.
    dlg.worker.moveToThread(dlg.thread)

    #-SIGNALS (start) #######################################################
    # Anti-panic clicking: Disable widgets to avoid queuing signals.
    # ...

    # Execute worker's 'run' method.
    dlg.thread.started.connect(dlg.worker.clean_up_schema_thread)

    # Capture progress to show in bar.
    dlg.worker.sig_progress.connect(dlg.evt_update_bar)

    # Get rid of worker and thread objects.
    dlg.worker.sig_finished.connect(dlg.thread.quit)
    dlg.worker.sig_finished.connect(dlg.worker.deleteLater)
    dlg.thread.finished.connect(dlg.thread.deleteLater)

    # Reenable the GUI
    dlg.thread.finished.connect(dlg.msg_bar.clearWidgets)

    # On installation status
    dlg.worker.sig_success.connect(lambda: evt_clean_up_schema_success(dlg))
    dlg.worker.sig_fail.connect(lambda: evt_clean_up_schema_fail(dlg))
    #-SIGNALS (end) #######################################################

    # Initiate worker thread
    dlg.thread.start()


class CleanUpSchemaWorker(QObject):
    """Class to assign Worker that bulk deletes the selected features 
    either as groups of FeatureTypes or as top-level Features from the current database.
    """
    # Create custom signals.
    sig_finished = pyqtSignal()
    sig_progress = pyqtSignal(int, str)
    sig_success = pyqtSignal()
    sig_fail = pyqtSignal()

    def __init__(self, dlg: CDB4DeleterDialog):
        super().__init__()
        self.dlg = dlg

    def clean_up_schema_thread(self):
        """Execution method that truncates all tables in the current citydb schema.
        """
        dlg = self.dlg
        qgis_pkg_schema: str = dlg.QGIS_PKG_SCHEMA
        cdb_schema: str = dlg.CDB_SCHEMA

        # Flag to help us break from a failing installation.
        fail_flag: bool = False

        # Strictly speaking, all these extra TRUNCATE statements to the tables are not necessary,
        # as one single run of the cleanup_schema function would suffice.
        # This strategy however allows for some action in the progress bar, otherwise the user would have no cue of
        # what is going on.

        table_names: tuple = (
            "address_to_bridge",
            "address_to_building",
            "appear_to_surface_data",
            "group_to_cityobject",
            "generalization",
            "opening_to_them_surface",
            "relief_feat_to_rel_comp",
            "textureparam",
            "appearance", 
            "address", 
            "external_reference",
            "surface_data", 
            "surface_geometry", 
            "cityobject_genericattrib",
            "building",
            "bridge",
            "tunnel",
            "solitary_vegetat_object",
            "plant_cover",
            "tin_relief",
            "waterbody",
            "land_use",
            "generic_cityobject",
            "cityobjectgroup",
            "cityobject"
            )

        # Set progress bar goal:
        steps_tot = len(table_names) + 1
        dlg.bar.setMaximum(steps_tot)
        curr_step: int = 0
        
        try:
            # Open new temp session, reserved for installation.
            temp_conn = conn_f.create_db_connection(db_connection=dlg.DB, app_name=" ".join([dlg.DLG_NAME_LABEL, "(Clean up schema (TRUNCATE)"]))
            with temp_conn:
                # Start measuring time
                time_start = time.time()                

                for table_name in table_names:

                    query = pysql.SQL("""
                        TRUNCATE {_cdb_schema}.{_table_name} RESTART IDENTITY CASCADE;
                    """).format(
                    _cdb_schema = pysql.Identifier(cdb_schema),
                    _table_name = pysql.Identifier(table_name)
                    )

                    # Update progress bar
                    msg = f"Truncating {cdb_schema}.{table_name}"
                    curr_step += 1
                    self.sig_progress.emit(curr_step, msg)

                    try:
                        with temp_conn.cursor() as cur:
                            cur.execute(query)
                        temp_conn.commit()   # Actually redundant, it is autocommitted

                    except (Exception, psycopg2.Error) as error:
                        temp_conn.rollback()
                        fail_flag = True
                        gen_f.critical_log(
                            func=self.clean_up_schema_thread,
                            location=FILE_LOCATION,
                            header=f"Truncating {cdb_schema}.{table_name}",
                            error=error)
                        self.sig_fail.emit()
                        # break # Exit from loop

                # Measure elapsed time
                time_middle = time.time()
                print(f"First round of truncating completed in {round((time_middle - time_start), 4)} seconds")

                # 2) Eventually, run the generic clean up function, just to be sure...
                query = pysql.SQL("""
                    SELECT {_qgis_pkg_schema}.cleanup_schema({_cdb_schema});
                """).format(
                _qgis_pkg_schema = pysql.Identifier(qgis_pkg_schema),
                _cdb_schema = pysql.Literal(cdb_schema)
                )

                # Update progress bar
                msg = "Finalizing the clean up"
                curr_step += 1
                self.sig_progress.emit(curr_step, msg)

                try:
                    with temp_conn.cursor() as cur:
                        cur.execute(query)
                    temp_conn.commit()   # Actually redundant, it is autocommitted

                except (Exception, psycopg2.Error) as error:
                    temp_conn.rollback()
                    fail_flag = True
                    gen_f.critical_log(
                        func=self.clean_up_schema_thread,
                        location=FILE_LOCATION,
                        header=f"Running qgis_pkg.cleanup_schema('{cdb_schema}')",
                        error=error)
                    self.sig_fail.emit()


            # Measure elapsed time
            print(f"Running qgis_pkg.cleanup_schema() completed in {round((time.time() - time_middle), 4)} seconds")
            # Measure elapsed time
            print(f"Clean-up process completed in {round((time.time() - time_start), 4)} seconds")

        except (Exception, psycopg2.Error) as error:
            fail_flag = True
            gen_f.critical_log(
                func=self.clean_up_schema_thread,
                location=FILE_LOCATION,
                header="Establishibng temporary connection",
                error=error)
            self.sig_fail.emit()

        # No FAIL = SUCCESS
        if not fail_flag:
            self.sig_success.emit()

        self.sig_finished.emit()
        # Close temporary connection       
        temp_conn.close()
        return None

#--EVENTS  (start)  ##############################################################

def evt_clean_up_schema_success(dlg: CDB4DeleterDialog) -> None:
    """Event that is called when the thread executing the delete operation finishes successfully.
    It emits a success signal meaning that all went fine.

    Shows success message at dlg.msg_bar: QgsMessageBar
    Shows success message in QgsMessageLog
    """
    cdb_schema = dlg.CDB_SCHEMA

    # Replace with Success msg.
    msg = dlg.msg_bar.createMessage(c.TRUNC_SUCC_MSG.format(sch=cdb_schema))
    dlg.msg_bar.pushWidget(msg, Qgis.MessageLevel.Success, 4)

    # Inform user
    QgsMessageLog.logMessage(
            message=c.BULK_DEL_SUCC_MSG.format(sch=cdb_schema),
            tag=dlg.PLUGIN_NAME,
            level=Qgis.MessageLevel.Success,
            notifyUser=True)

    tc_f.refresh_extents(dlg)

    return None


def evt_clean_up_schema_fail(dlg: CDB4DeleterDialog) -> None:
    """Event that is called when the thread executing the delete operation fails
    It emits a fail signal meaning that something went wrong.

    Shows fail message at dlg.msg_bar: QgsMessageBar
    Shows fail message in QgsMessageLog
    """
    error: str = 'Clean-up error'

    # Replace with Failure msg.
    msg = dlg.msg_bar.createMessage(error)
    dlg.msg_bar.pushWidget(msg, Qgis.MessageLevel.Critical, 4)
    
    # Inform user
    QgsMessageLog.logMessage(
            message=error,
            tag=dlg.PLUGIN_NAME,
            level=Qgis.MessageLevel.Critical,
            notifyUser=True)
    
    return None

#####################################################################################
##### BULK FEATURE DELETER ##########################################################
#####################################################################################

def run_bulk_delete_thread(dlg: CDB4DeleterDialog, delete_mode: str) -> None:
    """Function that uninstalls the qgis_pkg schema from the database
    by branching a new Worker thread to execute the operation on.
    """
    # Add a new progress bar to follow the installation procedure.
    for index in range(dlg.vLayoutUserConn.count()):
        widget = dlg.vLayoutUserConn.itemAt(index).widget()
        if not widget:
            continue # Needed to avoid errors with layouts, vertical spacers, etc.
        if widget.objectName() == "gbxFeatSel":
            # Add a new progress bar to follow the deletion procedure.
            dlg.create_progress_bar(layout=dlg.vLayoutUserConn, position=index+1)
            break

    # Create new thread object.
    dlg.thread = QThread()
    # Instantiate worker object for the operation.
    dlg.worker = BulkDeleteWorker(dlg, delete_mode)
    # Move worker object to the be executed on the new thread.
    dlg.worker.moveToThread(dlg.thread)

    #-SIGNALS--(start)--################################################################
    # Anti-panic clicking: Disable widgets to avoid queuing signals.
    # ...

    # Execute worker's 'run' method.
    dlg.thread.started.connect(dlg.worker.bulk_delete_thread)

    # Capture progress to show in bar.
    dlg.worker.sig_progress.connect(dlg.evt_update_bar)

    # Get rid of worker and thread objects.
    dlg.worker.sig_finished.connect(dlg.thread.quit)
    dlg.worker.sig_finished.connect(dlg.worker.deleteLater)
    dlg.thread.finished.connect(dlg.thread.deleteLater)

    # Reenable the GUI
    dlg.thread.finished.connect(dlg.msg_bar.clearWidgets)

    # On installation status
    dlg.worker.sig_success.connect(lambda: evt_bulk_delete_success(dlg))
    dlg.worker.sig_fail.connect(lambda: evt_buld_delete_fail(dlg))
    #-SIGNALS--(end)---################################################################

    # Initiate worker thread
    dlg.thread.start()


class BulkDeleteWorker(QObject):
    """Class to assign Worker that bulk deletes the selected features 
    either as groups of FeatureTypes or as top-level Features from the current database.
    """
    # Create custom signals.
    sig_finished = pyqtSignal()
    sig_progress = pyqtSignal(int, str)
    sig_success = pyqtSignal()
    sig_fail = pyqtSignal()

    def __init__(self, dlg: CDB4DeleterDialog, delete_mode: str):
        super().__init__()
        self.dlg = dlg
        self.delete_mode = delete_mode


    def bulk_delete_thread(self):
        """Execution method that bulk deletes the features.
        """
        dlg = self.dlg

        # Flag to help us break from a failing installation.
        fail_flag: bool = False
        cdb_schema: str = dlg.CDB_SCHEMA
        co_id_array_length: int = dlg.settings.max_del_array_length_default

        sql_where: str
        if dlg.DELETE_EXTENTS == dlg.CDB_SCHEMA_EXTENTS:
            sql_where = "" # Empty string
        else:
            # Get corners coordinates
            x_min = str(dlg.DELETE_EXTENTS.xMinimum())
            y_min = str(dlg.DELETE_EXTENTS.yMinimum())
            x_max = str(dlg.DELETE_EXTENTS.xMaximum())
            y_max = str(dlg.DELETE_EXTENTS.yMaximum())
            srid: int = dlg.CRS.postgisSrid()
            # Write the spatial term of the where clause
            sql_where = f"AND (co.envelope && ST_MakeEnvelope({x_min}, {y_min}, {x_max}, {y_max}, {srid}))"

        if not self.delete_mode:
            self.sig_fail.emit()
            self.sig_finished.emit()
            return None # Exit and activate fail event.
        
        elif self.delete_mode == "del_FeatureTypes":
            # 1a) Select the all Features that belong to the selected Feature Types
            sel_fts: list = []
            sel_fts = [k for k, ft in dlg.FeatureTypesRegistry.items() if ft.is_selected]

            ft_rel: FeatureType
            ft_cog: FeatureType
            ft_rel = dlg.FeatureTypesRegistry['Relief']
            ft_cog = dlg.FeatureTypesRegistry['CityObjectGroup']

            # 2a) Filter the top-level features based on the selected Featuere Types 
            sel_tlfs: list = []               # Used for all the top-level features, except the CityObjectGroup
            sel_tlfs = sorted([rcf for rcf in dlg.TopLevelFeaturesRegistry.values() if (rcf.feature_type in sel_fts) and (rcf.n_features != 0)], key = lambda x: x.name)
            
            # 3a) Put the ReliefFeature and the CityObjectGroup top-level features at the end of the list 
            if (not ft_rel.is_selected) and (not ft_cog.is_selected):
                pass # Nothing to do

            elif (ft_rel.is_selected) and (not ft_cog.is_selected):
                # a) Remove from the list
                sel_tlfs = sorted([tlf for tlf in sel_tlfs if tlf.name != "ReliefFeature"], key = lambda x: x.name)
                # b) add it at the end of the list
                sel_tlfs.append(dlg.TopLevelFeaturesRegistry["ReliefFeature"])

            elif (not ft_rel.is_selected) and (ft_cog.is_selected):
                # Move the ReliefFeature at the end of the rcf list
                # a) Remove from the list
                sel_tlfs = sorted([tlf for tlf in sel_tlfs if tlf.name != "CityObjectGroup"], key = lambda x: x.name)
                # b) add it at the end of the list
                sel_tlfs.append(dlg.TopLevelFeaturesRegistry["CityObjectGroup"])

            elif (ft_rel.is_selected) and (ft_cog.is_selected):
                # Move the ReliefFeature and the CityObjectGroup at the end of the rcf list
                # a) Remove from the list
                sel_tlfs = sorted([tlf for tlf in sel_tlfs if tlf.name not in ["ReliefFeature", "CityObjectGroup"]], key = lambda x: x.name)
                # b) add at the end of the list
                sel_tlfs.append(dlg.TopLevelFeaturesRegistry["ReliefFeature"])
                sel_tlfs.append(dlg.TopLevelFeaturesRegistry["CityObjectGroup"])

            tot_del_iter: int = 0

            tlf: TopLevelFeature
            n_iter: int = 0
            for tlf in sel_tlfs:
                n_iter = math.ceil(tlf.n_features / co_id_array_length) # approximates to the next integer, so always >= 1
                tlf.n_del_iter = n_iter
                tot_del_iter += n_iter

        elif self.delete_mode == "del_TopLevelFeatures":
            # 1b) Pick only those top-level features that have been selected (except ReliefFeature and CityObjectGroup, added later) 
            sel_tlfs: list = []               # Used for all the top-level features, except the CityObjectGroup and ReliefFeature
            sel_tlfs: list = sorted([rcf for rcf in dlg.TopLevelFeaturesRegistry.values() if (rcf.is_selected) and (rcf.name not in ["ReliefFeature", "CityObjectGroup"])], key = lambda x: x.name)

            rcf_rel: TopLevelFeature
            rcf_cog: TopLevelFeature
            rcf_rel = dlg.TopLevelFeaturesRegistry['ReliefFeature']
            rcf_cog = dlg.TopLevelFeaturesRegistry['CityObjectGroup']

            if rcf_rel.is_selected: # for sure it has n_features > 0, bacause it could be selected
                sel_tlfs.append(rcf_rel)

            if rcf_cog.is_selected: # for sure it has n_features > 0, bacause it could be selected
                sel_tlfs.append(rcf_cog)

            # Update the number of delete iterations for each selected top-level feature
            tot_del_iter: int = 0

            tlf: TopLevelFeature = None
            n_iter: int = 0
            for tlf in sel_tlfs:
                n_iter = math.ceil(tlf.n_features / co_id_array_length) # approximates to the next integer, so always >= 1
                tlf.n_del_iter = n_iter
                tot_del_iter += n_iter

        # Set progress bar goal:
        # drop_iterations: tot_del_iter actions
        # clean up global appearances: 1 action

        steps_tot = tot_del_iter + 1
        dlg.bar.setMaximum(steps_tot)
        curr_step: int = 0
        # print("steps_tot", steps_tot)

        # Open new temp session, reserved for installation.
        try:
            temp_conn = conn_f.create_db_connection(db_connection=dlg.DB, app_name=" ".join([dlg.DLG_NAME_LABEL, "(Bulk Deleter)"]))
            with temp_conn:

                # Start measuring time
                time_start = time.time()

                # Start deleting the top-level features that are neither ReliefFeature nor CityObjectGroup
                for tlf in sel_tlfs:
                    for i in range(tlf.n_del_iter):

                        # This query will return only an id of the whole array, if something was deleted.
                        # It will return null if nothing was deleted
                        query = pysql.SQL("""
                            WITH s AS (
                                SELECT array_agg(foo.id) AS co_id_array
                                FROM (
                                    SELECT co.id FROM {_cdb_schema}.cityobject AS co
                                    WHERE co.objectclass_id = {_objectclass_id} {_sql_where}
                                    LIMIT {_co_id_array_length} FOR UPDATE) AS foo
                                )
                            SELECT {_cdb_schema}.{_del_func}(s.co_id_array) FROM s LIMIT 1;
                        """).format(
                        _cdb_schema = pysql.Identifier(cdb_schema),
                        _objectclass_id = pysql.Placeholder('oc_id'),
                        _sql_where = pysql.SQL(" ".join(["", sql_where])),
                        _co_id_array_length = pysql.Placeholder('co_id_arr_len'),
                        _del_func = pysql.Identifier(tlf.del_function)
                        )

                        # Update progress bar
                        msg = f"Deleting '{tlf.name}' objects"
                        curr_step += 1
                        self.sig_progress.emit(curr_step, msg)

                        try:
                            with temp_conn.cursor() as cur:
                                cur.execute(query, {'oc_id': tlf.objectclass_id, 'co_id_arr_len': co_id_array_length})
                            temp_conn.commit()   # Actually redundant, it is autocommitted

                        except (Exception, psycopg2.Error) as error:
                            temp_conn.rollback()
                            fail_flag = True
                            gen_f.critical_log(
                                func=self.bulk_delete_thread,
                                location=FILE_LOCATION,
                                header=f"Deleting objects of top-level '{tlf.name}' in schema {cdb_schema}",
                                error=error)
                            self.sig_fail.emit()
                            break # Exit from the loop

                        # print(f"deleted {rcf.name} step {curr_step}/{steps_tot}")

                # 2) Eventually, clean up the global appearances. Same as before, only one value is returned.
                query = pysql.SQL("""
                    SELECT {_cdb_schema}.cleanup_appearances() LIMIT 1;
                """).format(
                _cdb_schema = pysql.Identifier(cdb_schema),
                )

                # Update progress bar
                msg = f"Cleaning up global appearances"
                curr_step += 1
                self.sig_progress.emit(curr_step, msg)

                try:
                    with temp_conn.cursor() as cur:
                        cur.execute(query)
                    temp_conn.commit()   # Actually redundant, it is autocommitted

                except (Exception, psycopg2.Error) as error:
                    temp_conn.rollback()
                    fail_flag = True
                    gen_f.critical_log(
                        func=self.bulk_delete_thread,
                        location=FILE_LOCATION,
                        header=f"Cleaning up global appearances in schema {cdb_schema}",
                        error=error)
                    self.sig_fail.emit()

                # print(f"cleaned up appearances, step {curr_step}/{steps_tot}")

            # Measure elapsed time
            print(f"Delete process completed in {round((time.time() - time_start), 4)} seconds")

        except (Exception, psycopg2.Error) as error:
            fail_flag = True
            gen_f.critical_log(
                func=self.bulk_delete_thread,
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

#--EVENTS  (start)  ##############################################################

def evt_bulk_delete_success(dlg: CDB4DeleterDialog) -> None:
    """Event that is called when the thread executing the delete operation finishes successfully.
    It emits a success signal meaning that all went fine.

    Shows success message at dlg.msg_bar: QgsMessageBar
    Shows success message in QgsMessageLog
    """
    cdb_schema = dlg.CDB_SCHEMA

    # Replace with Success msg.
    msg = dlg.msg_bar.createMessage(c.BULK_DEL_SUCC_MSG.format(sch=cdb_schema))
    dlg.msg_bar.pushWidget(msg, Qgis.MessageLevel.Success, 4)

    # Inform user
    QgsMessageLog.logMessage(
            message=c.BULK_DEL_SUCC_MSG.format(sch=cdb_schema),
            tag=dlg.PLUGIN_NAME,
            level=Qgis.MessageLevel.Success,
            notifyUser=True)

    tc_f.refresh_extents(dlg)

    return None


def evt_buld_delete_fail(dlg: CDB4DeleterDialog) -> None:
    """Event that is called when the thread executing the delete operation fails
    It emits a fail signal meaning that something went wrong.

    Shows fail message at dlg.msg_bar: QgsMessageBar
    Shows fail message in QgsMessageLog
    """
    error: str = 'Bulk Delete error'

    # Replace with Failure msg.
    msg = dlg.msg_bar.createMessage(error)
    dlg.msg_bar.pushWidget(msg, Qgis.MessageLevel.Critical, 4)

    # Inform user
    QgsMessageLog.logMessage(
            message=error,
            tag=dlg.PLUGIN_NAME,
            level=Qgis.MessageLevel.Critical,
            notifyUser=True)
    
    return None

#--EVENTS  (end) ################################################################


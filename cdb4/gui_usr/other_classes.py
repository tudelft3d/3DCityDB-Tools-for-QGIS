import os.path
from .. import cdb4_constants as c

class UserDialogRequirements:
    def __init__(self):
        self.green_db_conn: bool = False
        self.green_postgis_inst: bool = False
        self.green_citydb_inst: bool = False
        self.green_main_inst: bool = False
        self.green_user_inst: bool = False
        self.green_schema_supp: bool = False
        self.green_refresh_date: bool = False

    def are_requirements_fulfilled(self) -> bool:
        """Method that can be used to check if the connection is ready for plugin use.

        *   :returns: The connection's readiness status to work with
                the plugin.
            :rtype: bool
        """
        if all((self.green_db_conn,
                self.green_postgis_inst,
                self.green_citydb_inst,
                self.green_main_inst,
                self.green_user_inst,
                self.green_schema_supp,
                self.green_refresh_date)):
            return True
        return False

    
class UserDialogSettings:
    "TODO: these settings will be read from a setting.ini file stored in the QGIS plugin directory"

    def __init__(self):
        self.simp_geom_dec_prec: int = c.SIMP_GEOM_DEC_PREC
        self.simp_geom_dec_prec_label: str = "Number of decimal positions after the comma to round coordinates"
        self.simp_geom_min_area: float = c.SIMP_GEOM_MIN_AREA
        self.simp_geom_min_area_label: str = "Min area threshold to keep simplified polygon, in [m2]"
        self.max_features_to_import: int = c.MAX_FEATURES_TO_IMPORT
        self.max_features_to_import_label: str = "Max (cumulative) number of features to import into QGIS at a time"
        self.force_all_layers_creation: bool = c.FORCE_ALL_LAYERS_CREATION
        self.force_all_layers_creation_label: str = "Forces QGIS Package to generate all layers, even if empty"

    def __str__(self):
        return_str: str = \
            f"simp_geom_dec_prec: {self.simp_geom_dec_prec}\n" + \
            f"simp_geom_min_area: {self.simp_geom_min_area}\n" + \
            f"max_features_to_import: {self.max_features_to_import}\n" + \
            f"force_all_layers_creation: {self.force_all_layers_creation}\n"
        
        return return_str


class CDBLayer():
    """This class is used to convert each row of the 'layer_metadata' table into object
    instances. Its purpose is to facilitate access to attributes.
    """
    def __init__(self,
            v_id: int,
            cdb_schema: str,
            feature_type: str,
            lod: str,
            root_class: str,
            layer_name: str,
            n_features: int,
            mv_name: str,
            v_name: str,
            qml_file: str,
            creation_data: str,
            refresh_date: str):

        self.v_id = v_id
        self.cdb_schema = cdb_schema
        self.feature_type = feature_type
        self.lod = lod
        self.root_class = root_class
        self.layer_name = layer_name
        self.n_features = n_features
        self.n_selected = 0
        self.mv_name = mv_name
        self.v_name = v_name
        self.qml_file = qml_file
        self.qml_path = os.path.join(c.QML_FORMS_PATH, qml_file)
        self.creation_data = creation_data
        self.refresh_date = refresh_date


class FeatureType():
    """This class acts as a container of the Layer class. It is used to organise all layers according to their corresponding CityGML feature type.
    """
    def __init__(self, alias: str):
        self.alias = alias
        self.layers = [] # Will contain the Layers objects to be loaded
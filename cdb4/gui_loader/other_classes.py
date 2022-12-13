import os.path
from .. import cdb4_constants as c

class LoaderDialogRequirements:
    def __init__(self):
        self.is_conn_successful: bool = False
        self.is_postgis_installed: bool = False
        self.is_3dcitydb_installed: bool = False
        self.is_qgis_pkg_installed: bool = False
        self.is_usr_pkg_installed: bool = False
        self.layers_exist: bool = False
        self.layers_refreshed: bool = False

    def __str__(self):
        return_str: str = \
            f"Is the connection to the database established? {self.is_conn_successful}\n" + \
            f"Is PostGIS installed? {self.is_postgis_installed}\n" + \
            f"Is the 3DCityDB installed? {self.is_3dcitydb_installed}\n" + \
            f"Is the QGIS Package installed? {self.is_qgis_pkg_installed}\n" + \
            f"Is the user schema installed? {self.is_usr_pkg_installed}\n" + \
            f"Have layers been created? {self.layers_exist}\n" + \
            f"Have layers been refreshed? {self.layers_refreshed}\n"
        return return_str


    def are_requirements_fulfilled(self) -> bool:
        """Method that is used to check whether layers can be loaded in the ""Layers' tab"

        *   :returns: The plugin's readiness to finally load layers.
            :rtype: bool
        """
        if all((self.is_conn_successful,
                self.is_postgis_installed,
                self.is_3dcitydb_installed,
                self.is_qgis_pkg_installed,
                self.is_usr_pkg_installed,
                self.layers_exist,
                self.layers_refreshed)):
            return True
        return False

    
class LoaderDialogSettings:
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
        self.enable_3d_renderer: bool = c.ENABLE_3D_RENDERER

    def __str__(self):
        return_str: str = \
            f"simp_geom_dec_prec: {self.simp_geom_dec_prec}\n" + \
            f"simp_geom_min_area: {self.simp_geom_min_area}\n" + \
            f"max_features_to_import: {self.max_features_to_import}\n" + \
            f"force_all_layers_creation: {self.force_all_layers_creation}\n" + \
            f"enable_3d_renderer: {self.enable_3d_renderer}\n"
        return return_str


class CDBLayer():
    """This class is used to convert each row of the 'layer_metadata' table into object
    instances. Its purpose is to facilitate access to attributes.
    """
    def __init__(self,
            l_id: int,
            cdb_schema: str,
            layer_type: str,
            feature_type: str,
            root_class: str,
            curr_class: str,
            lod: str,
            layer_name: str,
            av_name: str,
            gv_name: str,
            n_features: int,
            creation_date: str,
            refresh_date: str,
            qml_form: str,
            qml_symb: str,
            qml_3d: str
            ):

        self.l_id = l_id
        self.cdb_schema = cdb_schema
        self.layer_type = layer_type
        self.feature_type = feature_type
        self.root_class = root_class
        self.curr_class = curr_class
        self.lod = lod
        self.root_class_name = root_class
        self.curr_class_name = curr_class
        self.layer_name = layer_name
        self.gv_name = gv_name
        self.av_name = av_name
        self.n_features = n_features
        self.creation_date = creation_date
        self.refresh_date = refresh_date
        self.qml_form = qml_form
        self.qml_symb = qml_symb
        self.qml_3d = qml_3d

        if qml_form:
            self.qml_form_with_path = os.path.join(c.QML_PATH, c.QML_FORM_DIR, qml_form)
        else:
            self.qml_form = None
        if qml_symb:
            self.qml_symb_with_path = os.path.join(c.QML_PATH, c.QML_SYMB_DIR, qml_symb)
        else:
            self.qml_symb = None
        if qml_3d:
            self.qml_3d_with_path = os.path.join(c.QML_PATH, c.QML_3D_DIR, qml_3d)
        else:
            self.qml_3d = None
        
        self.n_selected: int = 0


class FeatureTypeLayersGroup():
    """This class acts as a container of the Layer class. It is used to organise all layers according to their corresponding CityGML feature type.
    """
    def __init__(self, feature_type_alias: str):
        self.feature_type_alias = feature_type_alias
        self.layers = [] # Will contain the Layers objects to be loaded
class DialogChecks:
    def __init__(self):
        self.is_conn_successful: bool = False
        self.is_3dcitydb_installed: bool = False
        self.is_qgis_pkg_installed: bool = False
        self.is_usr_pkg_installed: bool = False
        self.is_superuser: bool = False


    def __str__(self):
        return_str: str = \
            f"Is the connection to the database established? {self.is_conn_successful}<br>" + \
            f"Is the 3DCityDB installed? {self.is_3dcitydb_installed}<br>" + \
            f"Is the QGIS Package installed? {self.is_qgis_pkg_installed}<br>" + \
            f"Is the user schema installed? {self.is_usr_pkg_installed}<br>" + \
            f"Is the user a database superuser? {self.is_superuser}<br>"
        return return_str

   
class DefaultSettings:
    """ Contains all DEFAULT settings of the CDBDeleterDialog, and their explanation.
    """
    def __init__(self):

        self.max_del_array_length_default: int = 100  # rule of thumb (on my PC: 10 cityobjects per second)
        self.max_del_array_length_label: str = "Maximum (cumulative) number of features to delete at a time"

        self.force_dropping_layers_default: bool = False
        self.force_dropping_layers_label: str = "Forces QGIS Package to drop all layers in the current usr_schema"

    def __str__(self):
        return_str: str = \
            f"max_features_to_delete_default (DEFAULT): {self.max_features_to_delete_default}<br>" + \
            f"force_dropping_layers (DEFAULT): {self.force_dropping_layers_default}<br>"
        return return_str


class TopLevelFeature():
    def __init__(self,
                name: str,
                feature_type: str,
                objectclass_id: int,
                del_function: str = None,
                exists: bool = False, # i.e. exists in the selected cdb_schema?
                is_ade: bool = False,
                is_selected: bool = False,
                n_features: int = 0,
                n_del_iter: int = 0
                ):
        self.name = name
        self.feature_type = feature_type
        self.objectclass_id = objectclass_id
        self.del_function = del_function
        self.exists = exists 
        self.is_ade = is_ade
        self.is_selected = is_selected
        self.n_features = n_features
        self.n_del_iter = n_del_iter
    
    def __str__(self):
        return_str: str = \
            f"name: {self.name}<br>" + \
            f"feature type: {self.feature_type}<br>" + \
            f"citydb_objectclass_id: {self.objectclass_id}<br>" + \
            f"citydb_del_function: {self.del_function}<br>" + \
            f"exists? {self.exists}<br>" + \
            f"is_ade? {self.is_ade}<br>" + \
            f"is selected? {self.is_selected}<br>" + \
            f"features number: {self.n_features}<br>"

        return return_str


class FeatureType():
    def __init__(self,
                name: str,
                alias: str,
                layers_drop_function: str = None,
                exists: bool = None,                   # i.e. exists in the selected cdb_schema?
                is_ade: bool = False,
                is_selected: bool = False,
                n_features: int = 0,
                top_class_features: list = []
                ):
        
        self.name = name 
        self.alias = alias

        if layers_drop_function:
            self.layers_drop_function = layers_drop_function
        else:
            self.layers_drop_function = "_".join(["drop_layers", alias])

        self.exists = exists 
        self.is_ade = is_ade
        self.is_selected = is_selected
        self.n_features = n_features
        self.top_class_features = top_class_features # Will contain the TopClassFeatures objects to be deleted
    
    def __str__(self):
        return_str: str = \
            f"name: {self.name}<br>" + \
            f"alias: {self.alias}<br>" + \
            f"layers_drop_function: {self.layers_drop_function}<br>" + \
            f"exists? {self.exists}<br>" + \
            f"is_ade? {self.is_ade}<br>" + \
            f"is selected? {self.is_selected}<br>" + \
            f"features number: {self.n_features}<br>" + \
            f"top-level features number: {len(self.top_class_features)}<br>"
        return return_str


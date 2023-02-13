class AdminDialogChecks:
    def __init__(self):
        self.is_conn_successful: bool = False
        self.is_3dcitydb_installed: bool = False
        self.is_3dcitydb_supported: bool = False
        self.is_qgis_pkg_installed: bool = False
        self.is_qgis_pkg_supported: bool = False
        self.is_usr_pkg_installed: bool = False


class FeatureType():
    def __init__(self,
                alias: str,
                layers_drop_function: str = None,
                is_ade: bool = False,
                #n_features: int = 0
                ):
        self.alias = alias

        if layers_drop_function:
            self.layers_drop_function = layers_drop_function
        else:
            self.layers_drop_function = "_".join(["drop_layers", alias])

        self.is_ade = is_ade
        #self.n_features = n_features
    
    def __str__(self):
        return_str: str = \
            f"alias: {self.alias}\n" + \
            f"layers_drop_function: {self.layers_drop_function}\n" + \
            f"is_ade? {self.is_ade}\n"

        return return_str


class AdminDefaultSettings:
    """ Contains all DEFAULT settings of the CDB4-Admin dialog, and their descriptions
    """
    def __init__(self):
        self.enable_ro_user_default: int = False
        self.enable_ro_user_label: str = "Enables the default 'qgis_user_ro' user upon installation of the QGIS Package"

        self.enable_ro_user_access_default: int = False
        self.enable_ro_user_access_label: str = "Grants the 'qgis_user_ro' access to all existing citydb schemas upon installation of the QGIS Package"

        self.enable_rw_user_default: int = False
        self.enable_rw_user_label: str = "Enables the default 'qgis_user_rw' user upon installation of the QGIS Package"

        self.enable_rw_user_access_default: int = False
        self.enable_rw_user_access_label: str = "Grants the 'qgis_user_rw' access to all existing citydb schemas upon installation of the QGIS Package"
    

    
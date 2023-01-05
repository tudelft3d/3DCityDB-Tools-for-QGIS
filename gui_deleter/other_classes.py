import os.path
from .. import cdb4_constants as c

class DeleterDialogRequirements:
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

    
class DeleterDialogSettings:
    "TODO: these settings will be read from a setting.ini file stored in the QGIS plugin directory"

    def __init__(self):
        pass

    def __str__(self):
        return_str: str = None

        return return_str
class AdminDialogRequirements:
    def __init__(self):
        self.green_db_conn: bool  = False
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
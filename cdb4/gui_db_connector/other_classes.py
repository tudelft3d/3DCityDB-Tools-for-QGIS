class Connection:
    """Class to store connection information.
    """
    def __init__(self):
        self.connection_name: str = None
        self.database_name: str = None
        self.host: str = None
        self.port: int = None
        self.username: str = None
        self.password = '*****'
        self.store_creds: bool = False
        self.is_active: bool = None
        self.pg_server_version: str = None # PostgreSQL server version
        self.citydb_version: str = None # 3DCityDB version
        self.id = id(self)
        self.hex_location = hex(self.id)

        # self.green_db_conn: bool  = False
        # self.green_postgis_inst: bool = False
        # self.green_citydb_inst: bool = False
        # self.green_main_inst: bool = False
        # self.green_user_inst: bool = False
        # self.green_schema_supp: bool = False
        # self.green_refresh_date: bool = False

    def __str__(self):
        return_str: str = \
            f"connection name: {self.connection_name}\n" + \
            f"db name: {self.database_name}\n" + \
            f"host: {self.host}\n" + \
            f"port: {self.port}\n" + \
            f"username: {self.username}\n" + \
            f"password: {self.password[0]}{self.password[1]}*****\n" + \
            f"id: {self.id}\n" + \
            f"DB version: {self.pg_server_version}\n" + \
            f"3DCityDB version: {self.citydb_version}\n" + \
            f"hex location: {self.hex_location}\n" + \
            f"to store: {self.store_creds}\n"
        return return_str
  

    # def user_meets_requirements(self) -> bool:
    #     """Method that can be used to check if the connection is ready for plugin use.

    #     *   :returns: The connection's readiness status to work with
    #             the plugin.
    #         :rtype: bool
    #     """
    #     if all((self.green_db_conn,
    #             self.green_postgis_inst,
    #             self.green_citydb_inst,
    #             self.green_main_inst,
    #             self.green_user_inst,
    #             self.green_schema_supp,
    #             self.green_refresh_date)):
    #         return True
    #     return False
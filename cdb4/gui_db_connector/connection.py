class Connection:
    """Class to store connection information."""

    def __init__(self):
        self.connection_name = None
        self.database_name = None
        self.host = None
        self.port = None
        self.username = None
        self.password = '*****'
        self.store_creds = False
        self.is_active = None
        self.pg_server_version: str = None # PostgreSQL server version
        self.citydb_version: str = None # 3DCityDB version
        self.id = id(self)
        self.hex_location = hex(self.id)

        self.green_db_conn: bool  = False
        self.green_post_inst: bool = False
        self.green_citydb_inst: bool = False
        self.green_main_inst: bool = False
        self.green_user_inst: bool = False
        self.green_schema_supp: bool = False
        self.green_refresh_date: bool = False

    def __str__(self):
        print(f"connection name: {self.connection_name}")
        print(f"db name: {self.database_name}")
        print(f"host:{self.host}")
        print(f"port:{self.port}")
        print(f"username:{self.username}")
        print(f"password:{self.password[0]}{self.password[1]}*****")
        print(f"id:{self.id}")
        print(f"DB version:{self.pg_server_version}")
        print(f"3DCityDB version:{self.citydb_version}")
        print(f"hex location:{self.hex_location}")
        print(f"to store:{self.store_creds}")
        print('\n')

    def meets_requirements(self) -> bool:
        """Method that can be used to check if the connection
        is ready for plugin use.

        *   :returns: The connection's readiness status to work with
                the plugin.

            :rtype: bool
        """
        if all((self.green_db_conn,
                self.green_post_inst,
                self.green_citydb_inst,
                self.green_main_inst,
                self.green_user_inst,
                self.green_schema_supp,
                self.green_refresh_date)):
            return True
        return False

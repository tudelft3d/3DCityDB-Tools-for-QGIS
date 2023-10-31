class Connection:
    """Class to store connection information.
    """
    def __init__(self):
        self.connection_name: str = None
        self.database_name: str = None
        self.host: str = None
        self.port: int = None
        self.username: str = None
        self.password: str = None
        self.store_creds: bool = False
        self.is_active: bool = None
        self.pg_server_version: str = None # PostgreSQL server version
        self.citydb_version: str = None # 3DCityDB version
        self.id = id(self)
        self.hex_location = hex(self.id)

    def __str__(self):
        pw: str
        if self.password is None:
            pw = 'None'
        else:
            pw = '********'
        return_str: str = \
            f"connection name: {self.connection_name}\n" + \
            f"host: {self.host}\n" + \
            f"port: {self.port}\n" + \
            f"db name: {self.database_name}\n" + \
            f"username: {self.username}\n" + \
            f"password: {pw}\n" + \
            f"id: {self.id}\n" + \
            f"DB version: {self.pg_server_version}\n" + \
            f"3DCityDB version: {self.citydb_version}\n" + \
            f"hex location: {self.hex_location}\n" + \
            f"Store credentials?: {self.store_creds}\n"
        return return_str

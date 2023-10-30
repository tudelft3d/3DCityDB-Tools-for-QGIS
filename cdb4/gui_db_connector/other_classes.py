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
            f"connection name: {self.connection_name}<br>" + \
            f"host: {self.host}<br>" + \
            f"port: {self.port}<br>" + \
            f"db name: {self.database_name}<br>" + \
            f"username: {self.username}<br>" + \
            f"password: {pw}<br>" + \
            f"id: {self.id}<br>" + \
            f"DB version: {self.pg_server_version}<br>" + \
            f"3DCityDB version: {self.citydb_version}<br>" + \
            f"hex location: {self.hex_location}<br>" + \
            f"Store credentials?: {self.store_creds}<br>"
        return return_str

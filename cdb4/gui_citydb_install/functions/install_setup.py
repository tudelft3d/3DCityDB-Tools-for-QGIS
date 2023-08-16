import os

from .. import citydb_install_dialog_constants as const


def setup_connection_file_unix(db,psql_path):
    """Function that prepares the CONNECTION_DETAILS.sh file with the valus from the plugin"""

    with open(const.CITYDB_Shell_SCRIPTS_CONN_UNIX, "w") as conn_file:
        conn_file.writelines(const.CITYDB_CONN_MOCK_UNIX.format(
            psql = psql_path, 
            host = db.host, 
            port = db.port, 
            db = db.database_name,
            user = db.username
            )
        )

def setup_permissions_unix():
    """
    Function that modifies the current permission of a file in UNIX systems
    0o775 handles is the equivalent of chmod u+x file.sh

    NOTE: We could add more options to this function but it is not needed, yet. 
    """
    os.chmod(const.CITYDB_Shell_SCRIPTS_DB_UNIX,0o775)

def setup_connection_file_win(db,psql_path):
    """Function that prepares the CONNECTION_DETAILS.bat file with the valus from the plugin"""
    with open(const.CITYDB_Shell_SCRIPTS_CONN_WIN, "w") as conn_file:
        conn_file.writelines(const.CITYDB_CONN_MOCK_WIN.format(
            psql = psql_path, 
            host = db.host, 
            port = db.port, 
            db = db.database_name,
            user = db.username
            )
        )
def reset_connection_file_win():
    """
    Function that resets the CONNECTION_DETAILS.bat file back to its original state
    This is usefull to implement for security reasons, as the connection credentials are saved unencrypted
    NOTE: NOT USED YET
    """

    with open(const.CITYDB_Shell_SCRIPTS_CONN_WIN, "w") as conn_file:
        conn_file.writelines(const.CITYDB_CONN_MOCK_WIN.format(
            psql = const.DEF_PGBIN, 
            host = const.DEF_PGHOST, 
            port = const.DEF_PGPORT, 
            db = const.DEF_CITYDB,
            user = const.DEF_PGUSER,
            )
        )

def reset_connection_file_unix():
    """
    Function that resets the CONNECTION_DETAILS.sh file back to its original state
    This is usefull to implement for security reasons, as the connection credentials are saved unencrypted
    NOTE: NOT USED YET
    """

    with open(const.CITYDB_Shell_SCRIPTS_CONN_UNIX, "w") as conn_file:
        conn_file.writelines(const.CITYDB_CONN_MOCK_UNIX.format(
            psql = const.DEF_PGBIN, 
            host = const.DEF_PGHOST, 
            port = const.DEF_PGPORT, 
            db = const.DEF_CITYDB,
            user = const.DEF_PGUSER,
            )
        )
        
from .. import citydb_install_dialog_constants as const
from ...shared.functions import general_functions as gen_f
from ....cdb_tools_main_constants import PLUGIN_ROOT_PATH
import os
def setup_connection_file_unix(db,psql_path):
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
    os.chmod(const.CITYDB_Shell_SCRIPTS_DB_UNIX,0o775)

def setup_connection_file_win(db,psql_path):

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

    with open(const.CITYDB_Shell_SCRIPTS_CONN_WIN, "w") as conn_file:
        conn_file.writelines(const.CITYDB_CONN_MOCK_WIN.format(
            psql = const.DEF_PGBIN, 
            host = const.DEF_PGHOST, 
            port = const.DEF_PGPORT, 
            db = const.DEF_CITYDB,
            user = const.DEF_PGUSER,
            )
        )
    
        
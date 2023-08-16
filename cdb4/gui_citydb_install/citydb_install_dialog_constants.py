import os.path as p
from ...cdb_tools_main_constants import PLUGIN_ROOT_PATH, PLUGIN_ROOT_DIR

CITYDB_VERISON_MAJOR = 4
CITYDB_VERISON_MINOR = 1
CITYDB_VERISON_PATCH = 0

CITYDB_DIR_NAME = "3dcitydb-4.1.0"

# Absolute paths
CITYDB_DIR = p.join(PLUGIN_ROOT_PATH,PLUGIN_ROOT_DIR,CITYDB_DIR_NAME)

CITYDB_DIR_SQL_SCRIPTS = p.join(CITYDB_DIR,"postgresql","SQLScripts")

# WINDOWS
CITYDB_DIR_Shell_SCRIPTS_WIN = p.join(CITYDB_DIR,"postgresql","ShellScripts","Windows")
CITYDB_Shell_SCRIPTS_CONN_WIN = p.join(CITYDB_DIR,"postgresql","ShellScripts","Windows", "CONNECTION_DETAILS.bat")
CITYDB_Shell_SCRIPTS_DB_WIN = p.join(CITYDB_DIR,"postgresql","ShellScripts","Windows", "CREATE_DB.bat")
# ...
# ...
# ...
DEF_PGBIN = "path_to_psql" 
DEF_PGHOST = "your_host_address"
DEF_PGPORT = "5432"
DEF_CITYDB = "your_database"
DEF_PGUSER = "your_username"
CITYDB_CONN_MOCK_WIN = """
:: Provide your database details here -----------------------------------------
set PGBIN={psql}
set PGHOST={host}
set PGPORT={port}
set CITYDB={db}
set PGUSER={user}
::-----------------------------------------------------------------------------
"""
PSQL_PROBABLE_PATH_WIN = "e.g. C:\Program Files\PostgreSQL\\14\\bin\psql.exe"

# UNIX
CITYDB_DIR_Shell_SCRIPTS_UNIX = p.join(CITYDB_DIR,"postgresql","ShellScripts","Unix")
CITYDB_Shell_SCRIPTS_CONN_UNIX = p.join(CITYDB_DIR,"postgresql","ShellScripts","Unix", "CONNECTION_DETAILS.sh")
CITYDB_Shell_SCRIPTS_DB_UNIX = p.join(CITYDB_DIR,"postgresql","ShellScripts","Unix", "CREATE_DB.sh")
# ...
# ...
# ...
# NOTE: We can add all of the scripts

PSQL_PROBABLE_PATH_UNIX = "e.g. /usr/bin/psql"

CITYDB_CONN_MOCK_UNIX = """
#!/bin/bash
# Provide your database details here ------------------------------------------
export PGBIN={psql}
export PGHOST={host}
export PGPORT={port}
export CITYDB={db}
export PGUSER={user}
#------------------------------------------------------------------------------
"""


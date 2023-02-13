"""This module contains functions that relate to the server side operations.

These functions are responsible to communicate and fetch data from
the database with sql queries or sql function calls.
"""

import psycopg2

from ....cdb_tools_main import CDBToolsMain # Used only to add the type of the function parameters
from ...shared.functions import general_functions as gen_f

FILE_LOCATION = gen_f.get_file_relative_path(__file__)

def fetch_posgresql_server_version(cdbMain: CDBToolsMain) -> str:
    """SQL query that reads and retrieves the server version.

    *   :returns: PostgreSQL server version as string (e.g. 10.6)
        :rtype: str
    """
    try:
        with cdbMain.conn.cursor() as cur:
            cur.execute(query="""SHOW server_version;""")
            version: str = cur.fetchone()[0] # Tuple has trailing comma.
        cdbMain.conn.commit()
        return version

    except (Exception, psycopg2.Error) as error:
        cdbMain.conn.rollback()
        gen_f.critical_log(
            func=fetch_posgresql_server_version,
            location=FILE_LOCATION,
            header="Retrieving PostgreSQL server version",
            error=error)


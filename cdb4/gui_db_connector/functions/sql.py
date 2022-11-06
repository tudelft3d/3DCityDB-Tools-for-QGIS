"""This module contains functions that relate to the server side operations.

These functions are responsible to communicate and fetch data from
the database with sql queries or sql function calls.
"""

from ....cdb_loader import CDBLoader # Used only to add the type of the function parameters

import psycopg2
from ... import cdb4_constants as c

FILE_LOCATION = c.get_file_relative_path(__file__)

def fetch_posgresql_server_version(cdbLoader: CDBLoader) -> str:
    """SQL query that reads and retrieves the server version.

    *   :returns: PostgreSQL server version as string (e.g. 10.6)
        :rtype: str
    """
    version: str
    try:
        with cdbLoader.conn.cursor() as cur:
            cur.execute(query="""SHOW server_version;""")
            version = cur.fetchone()[0] # Tuple has trailing comma.
        cdbLoader.conn.commit()
        return version

    except (Exception, psycopg2.Error) as error:
        c.critical_log(
            func=fetch_posgresql_server_version,
            location=FILE_LOCATION,
            header="Retrieving PostgreSQL server version",
            error=error)
        cdbLoader.conn.rollback()

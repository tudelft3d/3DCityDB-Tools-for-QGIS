"""This module contains functions that relate to the server side
operations.

These functions are responsible to communicate and fetch data from
the database with sql queries or sql function calls.
"""

import psycopg2
from ... import cdb4_constants as c

FILE_LOCATION = c.get_file_relative_path(__file__)

def fetch_server_version(cdbLoader) -> str:
    """SQL query that reads and retrieves the server version.
    *   :returns: Server version.

        :rtype: str
    """
    try:
         # Create cursor.
        with cdbLoader.conn.cursor() as cur:
            # Get server to fetch its version
            cur.execute(query="SHOW server_version;")
            version = cur.fetchone()[0] # Tuple has trailing comma.
        cdbLoader.conn.commit()
        return version

    except (Exception, psycopg2.Error) as error:
        # Send error to QGIS Message Log panel.
        c.critical_log(
            func=fetch_server_version,
            location=FILE_LOCATION,
            header="Retrieving PostgreSQL server version",
            error=error)
        cdbLoader.conn.rollback()

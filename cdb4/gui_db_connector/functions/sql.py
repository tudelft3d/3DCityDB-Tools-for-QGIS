"""This module contains functions that relate to the server side operations.

These functions are responsible to communicate and fetch data from
the database with sql queries or sql function calls.
"""
from __future__ import annotations
from typing import TYPE_CHECKING, Union
if TYPE_CHECKING:       
    from ...gui_admin.admin_dialog import CDB4AdminDialog
    from ...gui_loader.loader_dialog import CDB4LoaderDialog
    from ...gui_deleter.deleter_dialog import CDB4DeleterDialog

import psycopg2

from ...shared.functions import general_functions as gen_f

FILE_LOCATION = gen_f.get_file_relative_path(file=__file__)

def get_posgresql_server_version(dlg: Union[CDB4LoaderDialog, CDB4DeleterDialog, CDB4AdminDialog]) -> str:
    """SQL query that reads and retrieves the server version.

    *   :returns: PostgreSQL server version as string (e.g. 10.6)
        :rtype: str
    """
    try:
        with dlg.conn.cursor() as cur:
            cur.execute(query="""SHOW server_version;""")
            version = str(cur.fetchone()[0]) # Tuple has trailing comma.
        dlg.conn.commit()
        return version

    except (Exception, psycopg2.Error) as error:
        dlg.conn.rollback()
        gen_f.critical_log(
            func=get_posgresql_server_version,
            location=FILE_LOCATION,
            header="Retrieving PostgreSQL server version",
            error=error)


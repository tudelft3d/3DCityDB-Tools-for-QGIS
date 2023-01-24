"""This module contains functions that relate to the 'Connection Tab'
(in the GUI look for the elephant).

These functions are usually called from widget_setup functions
relating to child widgets of the 'Connection Tab'.
"""
from ....cdb_loader import CDBLoader # Used only to add the type of the function parameters


def fill_cdb_schemas_box(cdbLoader: CDBLoader, cdb_schemas: tuple) -> None:
    """Function that fills schema combo box with the provided schemas.
    """
    dlg = cdbLoader.deleter_dlg
    # Clear combo box from previous entries
    dlg.cbxSchema.clear()

    for cdb_schema in cdb_schemas:
        dlg.cbxSchema.addItem(cdb_schema, True)


def delete_feature(q,cdbLoader=CDBLoader):
    while True:
        try:
            with cdbLoader.conn.cursor() as cur:
                cur.execute(f'''SELECT {cdbLoader.CDB_SCHEMA}.del_cityobject({q.get()})''')
                print('Next Line')
            cdbLoader.conn.commit()
        except:
            continue
        else:
            q.task_done()


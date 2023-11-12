from typing import NamedTuple
from enum import Enum
from datetime import date

class BBoxType(Enum):
    """Enumeration containing the types of the bbox
    * DB_SCHEMA: str = "db_schema"
    * MAT_VIEW: str = "m_view"
    * QGIS: str = "qgis"
    """

    CDB_SCHEMA: str = "db_schema"   # These are the extents of all data stored in the selected cdb_schema
    MAT_VIEW: str = "m_view"        # These are the extents defined by the used to generate the layers
    QGIS: str = "qgis"              # These are the extents defined by the used to import data into QGIS

class CDBPrivType(Enum):
    """Enumeration containing the types of database rights
    * READ_ONLY: str = "ro"
    * READ_WRITE: str = "rw"
    """

    READ_ONLY: str = "ro"
    READ_WRITE: str = "rw"

class QgisPKGVersion(NamedTuple):
    """NamedTyple consisting of the following fields
    * version: str
    * full_version: str
    * major_version: int
    * minor_version: int
    * minor_revision: int
    * code_name: str
    * release_date: date
    """
    
    version: str
    full_version: str
    major_version: int
    minor_version: int
    minor_revision: int
    code_name: str
    release_date: date

class CDBSchemaPrivs(NamedTuple):
    """NamedTyple consisting of the following fields
    * cdb_schema: str
    * is_empty: bool
    * priv_type: str
    """
    
    cdb_schema: str
    is_empty: bool
    priv_type: str

class TopLevelFeatureCounter(NamedTuple):
    """NamedTyple consisting of the following fields
    * feature_type: str
    * root_class: str
    * objectclass_id: int
    * n_feature: int
    """

    feature_type: str
    root_class: str
    objectclass_id: int
    n_feature: int

class DetailViewMetadata(NamedTuple):
    """NamedTyple consisting of the following fields
    * id: int
    * cdb_schema: str
    * layer_type: str
    * curr_class: str 
    * layer_name: str 
    * gen_name: str 
    * qml_form: str 
    * qml_symb: str 
    * qml_3d: str
    """

    id: int
    cdb_schema: str
    layer_type: str
    curr_class: str 
    layer_name: str 
    gen_name: str 
    qml_form: str 
    qml_symb: str 
    qml_3d: str

class LookupTableConfig(NamedTuple):
    """NamedTyple consisting of the following fields
    * id: int
    * name: str
    * ade_prefix: str
    * source_class: str
    * source_table: str
    * source_column: str
    * target_table: str
    * key_column: str
    * value_column: str
    * filter_expression: str
    * num_columns: int
    * allow_multi: bool
    * allow_null: bool
    * order_by_value: bool
    * use_completer: bool
    * description: str
    """

    id: int
    name: str
    ade_prefix: str
    source_class: str
    source_table: str
    source_column: str
    target_table: str
    key_column: str
    value_column: str
    filter_expression: str
    num_columns: int
    allow_multi: bool
    allow_null: bool
    order_by_value: bool
    use_completer: bool
    description: str

class ListFeatureTypes(NamedTuple):
    """NamedTyple consisting of the following fields
    * usr_schema: str
    * cdb_schema: str
    * feature_type: str
    """

    usr_schema: str
    cdb_schema: str
    feature_type: str
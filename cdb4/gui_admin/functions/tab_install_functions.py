from __future__ import annotations
from typing import TYPE_CHECKING
if TYPE_CHECKING:       
    from ...gui_admin.admin_dialog import CDB4AdminDialog

from ..other_classes import FeatureType
# from . import sql


def initialize_feature_type_registry(dlg: CDB4AdminDialog) -> None:
    """Function to create the dictionary containing Feature Type metadata.
    """
    # Variable to store metadata about the Feature Types (i.e. CityGML modules/packages) 
    # NOTE: This is at the moment hard-coded, with ADE it will have to be possibly chanced

    dlg.FeatureTypesRegistry: dict = {}

    dlg.FeatureTypesRegistry: dict = {
        "Bridge"          : FeatureType(alias='bridge'         , ade_prefix=None),
        "Building"        : FeatureType(alias='building'       , ade_prefix=None),
        "CityFurniture"   : FeatureType(alias='cityfurniture'  , ade_prefix=None),
        "CityObjectGroup" : FeatureType(alias='cityobjectgroup', ade_prefix=None),
        "Generics"        : FeatureType(alias='generics'       , ade_prefix=None),
        "LandUse"         : FeatureType(alias='landuse'        , ade_prefix=None),
        "Relief"          : FeatureType(alias='relief'         , ade_prefix=None),
        "Transportation"  : FeatureType(alias='transportation' , ade_prefix=None),
        "Tunnel"          : FeatureType(alias='tunnel'         , ade_prefix=None),
        "Vegetation"      : FeatureType(alias='vegetation'     , ade_prefix=None),
        "WaterBody"       : FeatureType(alias='waterbody'      , ade_prefix=None)
        }

    # Add a function that adds additional "ADE" FeatureTypes in case there are 
    # ADEs installed in some cdb_schemas of the current database.
    # ade_feature_types: list = []
    # ade_feature_types = get_ADE_feature_types(.....)
    # for aft in ade_feature_types:
        # dlg.FeatureTypesRegistry.update({aft: FeatureType(alias="....", ....})

    return None
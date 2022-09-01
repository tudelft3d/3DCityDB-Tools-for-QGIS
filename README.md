# 3DCityDB-Loader for QGIS

This repository contains code of a QGIS plugin that facilitates management and visualization of data stored in the CityGML 3D City Database.

# Introduction

The plugin allows to connect to local or remote instances of the free and open-source CityGML [3D City Database](https://www.3dcitydb.org)  for PostgreSQL/PostGIS and to load data as "classical" layers into QGIS. Once data layers are available in QGIS, the user can interact with them "as usual", i.e. perform analyses, work with associated attributes, explore and visualise the data in 2D and 3D.

Semantic 3D city models tend to be huge datasets and are generally best managed in spatial databases. The main idea behind the development of this plugin is to facilitate access and usage of [CityGML](https://en.wikipedia.org/wiki/CityGML)/[CityJSON](https://www.cityjson.org/) data for those practitioners that lack a deep knowledge of the international standard [OCG CityGML data model](https://www.ogc.org/standards/citygml), and/or have limited experience with SQL - and spatial databases in general.

These are the main features currently available in the plugin:
- All CityGML modules are supported (Building, Bridge, Tunnel, etc.)
- All LoDs are supported, whenever applicable (LoD0 to LoD4)
- Multiple citydb schemas in the same 3D City Database instance
- Multiple user support, with different privileges (read-only, read-write)
- Form-based editing of feature attributes, changes are stored directly into the database
- In order to tackle possibly very large datasets, different strategies have been implemented to facilitate the user's experience when interacting with the city models via the GUI in QGIS
- As CityGML natively deals with 3D data, all geometries in the QGIS "layers" are 3D: they can be therefore visualised both in 2D and (with currently some limitations) in 3D, too
- The plugin consists of a server-side part (written in PG/pgSQL) and a client-side part (written in Python). Installation of the server-side part is possible via the plugin GUI (for database administrators).

Further details, and a simple user guide, can be found in the \user_guide subfolder of the plugin installation directory (see file "[3DCityDBLoader_UserGuide.pdf](https://github.com/tudelft3d/3DCityDB-QGIS-Loader/blob/master/user_guide/3DCityDBLoader_UserGuide.pdf)").

Some datasets for testing purposes are available, too, and are contained in the \test_datasets subfolder.

# Requirements

The plugin has been developed using QGIS 3.22 LTR and works best with it. Our tests so far show that it works with any QGIS version >= 3.20. Please note that support und further development will focus only on LTR versions, e.g. the next one will be QGIS 3.28 LTR expected in autumn 2022.

Other than QGIS, only a working instance of the 3D City Database is required. The currently supported version of the [3DCityDB]( https://github.com/3dcitydb) is the 4.x. To set up the 3D City Database and import (or export) CityGML/CityJSON data from/to it, we heartily reccommend to use the free and open-source, Java-based [Importer-Exporter](https://github.com/3dcitydb/importer-exporter). Alternatively, the [3D City Database Suite](https://github.com/3dcitydb/3dcitydb-suite/releases) already ships with all necessary software

# Developers

The plugin has been developed by:
- Kostantinos Pantelios (mainly client-side)
- Giorgio Agugiaro (mainly server-side)

With kind suggestions, contributions and feedback by Camilo Leòn-Sànchez (TU Delft), Claus Nagel and Zhihang Yao (VirtualCitySystems GmbH).

# Disclaimer
This work started as a TU Delft MSc Thesis in Geomatics by Konstantinos Pantelios. If you would like to read more about his work, it is available [here](http://resolver.tudelft.nl/uuid:fb532bef-81b9-482b-921a-e7ce907cb544). The 3D Geoinformation group at TU Delft has created this fork of the initial GitHub repository to continue development in the future. You are kindly invited to submit issues (and ideas, and suggestions!) to THIS repository.

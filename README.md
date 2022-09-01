# 3DCityDB-Loader for QGIS

This repository contains code of a **QGIS plugin** that facilitates management and visualization of data stored in the CityGML **3D City Database** (aka 3DCityDB), wich currently supports CityGML v. 1.0 and 2.0.

# Introduction

The plugin allows to connect to local or remote instances of the free and open-source CityGML [3D City Database](https://www.3dcitydb.org) for PostgreSQL/PostGIS and to load data as "classical" layers into QGIS. Once data layers are available in QGIS, the user can interact with them as usual, i.e. perform analyses, work with associated attributes, explore and visualise the data in 2D and 3D, etc.

As semantic 3D city models tend to be huge datasets and are generally best managed in spatial databases, the main idea behind the development of this plugin is to facilitate access and use of [CityGML](https://en.wikipedia.org/wiki/CityGML)/[CityJSON](https://www.cityjson.org/) data for those practitioners that lack a deep knowledge of the international standard [OCG CityGML data model](https://www.ogc.org/standards/citygml), and/or have limited experience with SQL/Spatial-RDBMSs in general.
The plugin consists of a server-side part (written in PL/pgSQL) and a client-side part (written in Python). Installation of the server-side part is carried out also via the plugin GUI (for database administrators).

These are the main features currently available in the plugin:
- All CityGML modules are supported (Building, Bridge, Tunnel, etc.)
- All LoDs are supported, whenever applicable (LoD0 to LoD4)
- Multiple citydb schemas in the same 3D City Database instance
- Multiple user support, with different privileges (i.e. read-only, read-write)
- User-friendly form-based editing of feature attributes; changes are stored directly into the database
- Automatically generated, hierarchical layer order in the QGIS Layers Panel
- Server-side and client-side interactive selection of the Area Of Interest (AOI) extents to load in QGIS, in order to tackle with possibly very large datasets
- Smart layer management: layers are generated only for existing data, only layers with data within the AOI extents can be selected
- Support for CityGML enumerations and codelists
- All layer geometries are 3D: they can be visualised both in 2D and in 3D (Please be aware that 3D visualisation in QGIS 3D map is still a bit unstable...).

Further details, and a simple user guide, can be found in the \user_guide subfolder of the plugin installation directory (see file "[3DCityDBLoader_UserGuide.pdf](https://github.com/tudelft3d/3DCityDB-QGIS-Loader/blob/master/user_guide/3DCityDBLoader_UserGuide.pdf)").

Some datasets for testing purposes are available, too, and are contained in the \test_datasets subfolder.

# Requirements

The plugin has been developed using [QGIS](https://www.qgis.org/nl/site/forusers/download.html) 3.22 LTR and works best with it. Our tests so far show that it works with any QGIS version >= 3.20. Please note that support und further development will focus only on LTR versions, e.g. the next one will be QGIS 3.28 LTR expected in autumn 2022.

Other than QGIS, only a working instance of the 3D City Database is required. The currently supported version of the [3DCityDB](https://github.com/3dcitydb) is the 4.x. To set up the 3D City Database and import (or export) CityGML/CityJSON data from/to it, we heartily reccommend to use the free and open-source, Java-based [Importer-Exporter](https://github.com/3dcitydb/importer-exporter). Alternatively, the [3D City Database Suite](https://github.com/3dcitydb/3dcitydb-suite/releases) already ships with all necessary software tools. Further information can be found [here](https://3dcitydb-docs.readthedocs.io/en/latest/).

# Developers

The plugin has been developed by:
- [Kostantinos Pantelios](konstantinospantelios@yahoo.com) (mainly client-side)
- [Giorgio Agugiaro](mailto:g.agugiaro@tudelft.nl) (mainly server-side, code refactoring)

With additional kind suggestions and feedback by Camilo León-Sánchez (TU Delft), Claus Nagel and Zhihang Yao (Virtual City Systems GmbH).

# Future

Besides further testing and debugging, there are a number of improvements that we are thinking of, such as, for example:
- Overall GUI improvements
- Richer GUI, e.g. with more options for database administrators, and better codelists management/settings 
- Support of ADEs (e.g. the Energy ADE, to start with)
- Support for appearances (at least for X3D Materials, if possible)
- Support for other geometry types other than (Multi)Polygons (e.g. multilines for Terrain Instersection Curves)
- Testing and initial support for the 3DCityDB v. 5.0 (and therefore CityGML 3.0)
- ...the sky is the limit...

# Disclaimer

This work started as a [TU Delft](www.tudelft.nl) MSc Thesis in [Geomatics](https://www.tudelft.nl/en/education/programmes/masters/geomatics/msc-geomatics) by Konstantinos Pantelios. If you would like to read more about his work, it is available [here](http://resolver.tudelft.nl/uuid:fb532bef-81b9-482b-921a-e7ce907cb544). The [3D Geoinformation group](https://3d.bk.tudelft.nl/) at TU Delft has created this fork of the initial GitHub repository to continue development in the future. You are kindly invited to submit issues (and ideas, and suggestions!) to THIS repository.

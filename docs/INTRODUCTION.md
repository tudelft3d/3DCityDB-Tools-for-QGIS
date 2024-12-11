# Introduction
[← Back to README](../README.md)

## GIS Layer-Based Data Interaction with 3DCityDB v.5.0 Using PostgreSQL
  3D city model data often requires relational databases such as [**3D City Database (3DCityDB)**](https://www.3dcitydb.org/3dcitydb/) for efficient access and management due to their large data size.

  [**3DCityDB-Tools for QGIS**](https://plugins.qgis.org/plugins/citydb-tools/) is a plug-in developed by the **3D Geoinformation group at TU Delft**. It provides a user-friendly GUI for creating GIS layers from data encoded within 3DCityDB using PostgreSQL/PostGIS. These GIS layers consist of unique feature geometries associated with attributes and follow the [Simple Feature for SQL (SFS) Model](https://docs.qgis.org/3.34/en/docs/training_manual/spatial_databases/simple_feature_model.html). The layer-based approach offers a more intuitive data interaction, especially for AEC practitioners who often use GIS applications for spatial data analysis.

  The current **3DCityDB-Tools for QGIS** only supports 3DCityDB up to version 4.x, which follows CityGML 1.0 & 2.0 standards. As the [CityGML 3.0](https://www.ogc.org/publications/standard/citygml/) was released in 2021, the 3DCityDB is being updated to version 5.0 to add full support for CityGML 3.0. Consequently, an adaptation of the **3DCityDB-Tools for QGIS** is necessary to address these changes. This repository presents an initial server-side approach to create GIS layers from the 3DCityDB 5.0.

## Features
  - Interaction with 3D city model data from 3DCityDB for PostgreSQL/PostGIS database in QGIS.
  - Flatten (linearise) complex feature schemas to support data consumption.
  - Enhanced support of the **3DCityDB-Tools for QGIS** following CityGML 3.0 standards.
# 3DCityDB 5.0 Installation & Data Import Guide

[← Back to README](../README.md)

## Step 1: Install PostgreSQL
  Install PostgreSQL, which can be done using the [EDB installer](https://www.enterprisedb.com/downloads/postgres-postgresql-downloads). Download and unzip the [3DCityDB 5.0 Command line tool](https://github.com/3dcitydb/citydb-tool) package.

## Step 2: Create User and Database in pgAdmin4
  1. **Create new user role and set privileges**

      Create a new user and set privileges for this newly created role by granting full access in the side panel under `Login/Group Roles`.

      <p align="center">
        <img src="../docs/images/create%20user%20name.png" alt="create new role" width="500"/>
      </p>

  2. **Create new database for data import**

      Create a new database under the PostgreSQL server.
      <p align="center">
        <img src="../docs/images/create new db.png" alt="create db" width="300"/>
      </p>

  3. **Create necessary extensions**
      Open a new query tool tab and run the following scripts to create the extensions for installing 3DCityDB 5.0 schemas:

      ```pgSQL
      CREATE EXTENSION IF NOT EXISTS postgis SCHEMA public; 
      CREATE EXTENSION IF NOT EXISTS postgis_raster SCHEMA public;
      CREATE EXTENSION IF NOT EXISTS "uuid-ossp" SCHEMA public; 
      CREATE EXTENSION IF NOT EXISTS pldbgapi SCHEMA public;
      ```

## Step 3: Configure Connection Details
  The procedures for setting up new 3DCityDB 5.0 instances are referenced from the [database setup instruction](https://github.com/3dcitydb/3dcitydb?tab=readme-ov-file#database-setup). The following steps demonstrated using MacOS `Terminal`.

  Navigate to the `3dcitydb/postgresql/shell-scripts/unix` directory in the 3DCityDB 5.0 command-line-tool folder and edit the `connection details`:

  ```bash
    export PGBIN  = path_to_psql
    export PGHOST = your_host_address
    export PGPORT = your_port_number
    export CITYDB = your_database
    export PGUSER = your_username
  ```

## Step 4: Create 3DCityDB 5.0 Schemas
  Navigate to the `3dcitydb/postgresql/shell-scripts/unix`, execute the `create_db.sh` shell script by the following command:
  ```bash
  sh create_db.sh
  ```

  The script will prompt for:
  
  (1) Spatial Reference System ID (SRID) to be used for all geometry objects. (e.g. 28992 for the Dutch SRID) <br>
  (2) EPSG code of the height system (optional) (e.g. 5109 for the Dutch height system).<br>
  (3) String encoding of the SRS used for the gml:srsName attribute in CityGML exports.

  After successful execution, two default schemas (citydb and citydb_pkg) will be created under the target database. You can create additional 3DCityDB 5.0 schemas by running the `create_schema` shell script.
  <p align="center"> 
    <img src="../docs/images/create db schema.png" alt="create 3dcitydb" width="500"/> 
  </p>

## Step 5: Import Spatial Data
  To import CityGML/CityJSON data, navigate to the 3DCityDB 5.0 command-line-tool folder and use the following command:
  ```bash
  sh citydb import [citygml/cityjson] [<file>] 
    --db-host localhost 
    --db-port [your_port_number] 
    --db-name [target_database] 
    --db-username [your_user_name] 
    --db-password [your_password] 
    --db-schema [target_schema]
  ```

  The 3DCityDB 5.0 schems that store the imported data are referred to `cdb_schema`.

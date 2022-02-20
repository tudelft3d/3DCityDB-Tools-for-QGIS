REM Shell script to install the qgis_pkg schema to the 3DCityDB on PostgreSQL/PostGIS

@ECHO OFF
CLS

REM Provide your database details here
SET PGPORT=write here the port of the postgres server (e.g. 5432)
SET PGHOST=write here the name/address of the host (e.g. localhost)
SET PGUSER=write here the postgres user (e.g. postgres)
SET CITYDB=write here the name of the database (e.g. vienna_db)
SET PGBIN=write here the path to psql.exe (e.g C:\Program Files\PostgreSQL\14\bin)

REM cd to path of the shell script
CD /d %~dp0

@ECHO ON

"%PGBIN%\psql" -h %PGHOST% -p %PGPORT% -d "%CITYDB%" -U %PGUSER% -f "INSTALL_qgis_pkg.sql"

PAUSE
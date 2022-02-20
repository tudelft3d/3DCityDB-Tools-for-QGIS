REM Shell script to install the qgis_pkg schema to the 3DCityDB on PostgreSQL/PostGIS

@ECHO OFF
CLS

REM Provide your database details here
SET PGPORT=5432
SET PGHOST=localhost
SET PGUSER=postgres
SET CITYDB=qgis_test
SET PGBIN=C:\Program Files\PostgreSQL\12\bin

REM cd to path of the shell script
CD /d %~dp0

@ECHO ON

"%PGBIN%\psql" -h %PGHOST% -p %PGPORT% -d "%CITYDB%" -U %PGUSER% -f "INSTALL_qgis_pkg.sql"

PAUSE
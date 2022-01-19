REM Shell script to install the 3DCityDB "Plus" Package on PostgreSQL/PostGIS

REM Provide your database details here
SET PGPORT=5432
SET PGHOST=localhost
SET PGUSER=postgres
SET CITYDB=qgis_test
SET PGBIN=C:\Program Files\PostgreSQL\12\bin

REM cd to path of the shell script
CD /d %~dp0

REM Run INSTALL_citydb_util.sql to add the 3DCityDB utilities to the 3DCityDB instance

REM "%PGBIN%\psql" -h %PGHOST% -p %PGPORT% -d "%CITYDB%" -U %PGUSER% -c "ALTER DATABASE %CITYDB% SET search_path TO citydb, citydb_pkg, public"
"%PGBIN%\psql" -h %PGHOST% -p %PGPORT% -d "%CITYDB%" -U %PGUSER% -f "INSTALL_qgis_pkg.sql"

PAUSE
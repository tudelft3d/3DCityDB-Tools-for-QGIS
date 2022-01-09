-- This script is called from CREATE_DB_qgis_pkg.bat/.sh
\pset footer off
SET client_min_messages TO WARNING;
\set ON_ERROR_STOP ON

\echo
\echo 'Setting up the new qgis_pkg schema'
\i postgresql/10_setup.sql

\echo
\echo 'Installing the tables'
\i postgresql/20_tables.sql

\echo
\echo 'Installing the materialized views'
\i postgresql/30_materialized_views.sql

\echo
\echo 'Installing the views'
\i postgresql/40_views.sql

\echo
\echo 'Installing the objects'
\i postgresql/50_objects.sql

\echo
\echo 'Installing triggers'
\i postgresql/60_triggers.sql

\echo
\echo '**********************************************************'
\echo
\echo 'Installation of the database scripts for the 3DCityDB QGIS Plugin complete!'
\echo
\echo '**********************************************************'
\echo

-- This script is called from CREATE_DB_qgis_pkg.bat/.sh
\pset footer off
SET client_min_messages TO WARNING;
\set ON_ERROR_STOP ON

\echo
\echo 'Setting up the new qgis_pkg schema'
\i postgresql/10_setup.sql

\echo
\echo 'Installing the main functions'
\i postgresql/20_functions.sql

\echo
\echo 'Installing other functions'
\i postgresql/25_functions_k.sql

\echo
\echo 'Installing the objects (types)'
\i postgresql/30_objects.sql

\echo
\echo 'Installing the table update functions'
\i postgresql/40_table_upd_f.sql

\echo
\echo 'Installing the view update functions'
\i postgresql/50_view_upd_f.sql

\echo
\echo 'Installing the trigger functions'
\i postgresql/60_trigger_f.sql

\echo
\echo 'Installing the materialized views'
\i postgresql/70_mat_views.sql

\echo
\echo 'Installing the views'
\i postgresql/80_views_and_triggers.sql

\echo
\echo '**********************************************************'
\echo
\echo 'Installation of the database scripts for the 3DCityDB QGIS Plugin complete!'
\echo
\echo '**********************************************************'
\echo

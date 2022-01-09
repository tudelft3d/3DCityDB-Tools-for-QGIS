#!/bin/sh

. ./qgis_pkg/CONNECTION_params.sh
cd "$( cd "$( dirname "$0" )" && pwd )" > /dev/null
pwd

# Run INSTALL_Metadata_module.sql to add the 3DcityDB utilities to the 3DCityDB instance
$PGBIN -h $PGHOST -p $PGPORT -d "$CITYDB" -U $PGUSER -f "INSTALL_qgis_pkg.sql"


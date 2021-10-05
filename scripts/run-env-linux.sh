#!/bin/bash

QGIS_PREFIX_PATH=/usr/bin/qgis
if [ -n "$1" ]; then
    QGIS_PREFIX_PATH=$1
fi

echo ${QGIS_PREFIX_PATH}


export QGIS_PREFIX_PATH=${QGIS_PREFIX_PATH}
export QGIS_PATH=/usr/bin/qgis #${QGIS_PREFIX_PATH}
export LD_LIBRARY_PATH=/usr/lib/qgis
export PYTHONPATH=~/.local/lib/python3.8:${QGIS_PREFIX_PATH}~/.local/share/QGIS/QGIS3/profiles/default/python/plugins/:${PYTHONPATH}

echo "QGIS PATH: $QGIS_PREFIX_PATH"
export QGIS_DEBUG=0
export QGIS_LOG_FILE=/tmp/inasafe/realtime/logs/qgis.log

export PATH=${QGIS_PREFIX_PATH}/bin:$PATH

echo "This script is intended to be sourced to set up your shell to"
echo "use a QGIS 2.0 built in $QGIS_PREFIX_PATH"
echo
echo "To use it do:"
echo "source $BASH_SOURCE /your/optional/install/path"
echo
echo "Then use the make file supplied here e.g. make guitest"

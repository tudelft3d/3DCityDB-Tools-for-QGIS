"""
/***************************************************************************
                        3DCityDB Tools for QGIS
 
        This is a QGIS plugin for the CityGML 3D City Database.
                             -------------------
        begin                : 2021-09-30
        git sha              : $Format:%H$
        author(s)            : Giorgio Agugiaro
                               Konstantinos Pantelios
        email                : g.agugiaro@tudelft.nl
                               konstantinospantelios@yahoo.com
 ***************************************************************************/

/***************************************************************************
 *                                                                         *
   Copyright 2021 Giorgio Agugiaro, Konstantinos Pantelios

   Licensed under the Apache License, Version 2.0 (the "License");
   you may not use this file except in compliance with the License.
   You may obtain a copy of the License at

       http://www.apache.org/licenses/LICENSE-2.0

   Unless required by applicable law or agreed to in writing, software
   distributed under the License is distributed on an "AS IS" BASIS,
   WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
   See the License for the specific language governing permissions and
   limitations under the License.
 *                                                                         *
 ***************************************************************************/
"""
from qgis.gui import QgisInterface
from .cdb_tools_main import CDBToolsMain

def classFactory(iface: QgisInterface):
    """Load CDBToolsMain class from file cdb_tools_main.py

    *   :param iface: A QGIS interface instance.
        :type iface: QgsInterface
    """
    return CDBToolsMain(iface=iface)
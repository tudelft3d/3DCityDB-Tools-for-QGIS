# -*- coding: utf-8 -*-
import os, configparser
from qgis.core import QgsApplication


def get_postgres_conn(self):
    """ Reads QGIS3.ini to get saved user connection parameters of postgres databases""" 

    #Current active profile directory
    profile_dir = QgsApplication.qgisSettingsDirPath()
    ini_path=os.path.join(profile_dir,"QGIS","QGIS3.ini")
    print(ini_path)

    # Clear the contents of the comboBox from previous runs
    self.btnConnToExist.clear()

    # Populate the comboBox with names of all the loaded layers
    #os.path.exists(my_path)

    parser = configparser.ConfigParser()

    #Makes path 'Case Sensitive'
    parser.optionxform = str 

    parser.read(ini_path)

        #db_name = re.compile('.*\database')
    for key in parser['PostgreSQL']:
    
        if '\database' in str(key):
            connection_name = str(key).split("\\")[1]
            self.btnConnToExist.addItems(['   '.join((parser['PostgreSQL'][key],f"(Connection name: {connection_name})"))])
      
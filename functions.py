# -*- coding: utf-8 -*-
import os, configparser
from qgis.core import QgsApplication

class database_cred:
    def __init__(self,connection_name,database): 
        self.connection_name=connection_name
        self.database=database
        self.host=None
        self.port=None
        self.username=None
        self.password='*****'
        self.store_creds=None
        self.is_active=None
        

    def __str__(self):
        print(f"connection name: {self.connection_name}") 
        print(f"db name: {self.database}")
        print(f"host:{self.host}")
        print(f"port:{self.port}")
        print(f"username:{self.username}")
        print(f"password:{self.password[0]}{self.password[1]}*****")
        return('\n')
    
    def add_to_collection(self,db_collection):
        db_collection.append(self)
        #print(f"{hex(id(self))} was added to db collection {db_collection}")

def get_postgres_conn(self):
    """ Reads QGIS3.ini to get saved user connection parameters of postgres databases""" 

    #Current active profile directory
    profile_dir = QgsApplication.qgisSettingsDirPath()
    ini_path=os.path.join(profile_dir,"QGIS","QGIS3.ini")
    ini_path=os.path.normpath(ini_path)

    # Clear the contents of the comboBox from previous runs
    self.btnConnToExist.clear()

    #os.path.exists(my_path)

    parser = configparser.ConfigParser()

    #Makes path 'Case Sensitive'
    parser.optionxform = str 

    parser.read(ini_path)

    db_collection = []
    for key in parser['PostgreSQL']:
        current_connection_name = str(key).split("\\")[1] #NOTE: seems too hardcoded, might break in the feature if .ini structure changes
        
        #Show database and connection name into combobox
        if 'database' in str(key):
            database_cred
            database = parser['PostgreSQL'][key]

            #Create DB instance based on current connection. This IF (and the rest) is visited only once per connection  
            db_instance =database_cred(current_connection_name,database)
            db_instance.add_to_collection(db_collection)

            self.btnConnToExist.addItem(f'{current_connection_name}',db_instance)#hex(id(db_instance)))
            
        if 'host' in str(key):
            host = parser['PostgreSQL'][key]
            db_instance.host=host

        if 'port' in str(key):
            port = parser['PostgreSQL'][key]
            db_instance.port=port

        if 'username' in str(key):
            username = parser['PostgreSQL'][key]
            db_instance.username=username

        if 'password' in str(key): 
            password = parser['PostgreSQL'][key]
            db_instance.password=password
 
    #NOTE: the above implementation works but feels unstable! Test it 

    return db_collection
    


    
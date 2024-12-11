import os
import re
import sys
from sqlalchemy import create_engine, text
from sqlalchemy.dialects.postgresql import psycopg2
import psycopg2, psycopg2.sql as pysql
from psycopg2.extras import LoggingConnection, LoggingCursor
import logging
import time
from datetime import datetime

logging.basicConfig(level=logging.DEBUG)
logger = logging.getLogger(__name__)

# MyLoggingCursor simply sets self.timestamp at start of each query                                                                 
class MyLoggingCursor(LoggingCursor):
    def execute(self, query, vars=None):
        self.timestamp = time.time()
        return super(MyLoggingCursor, self).execute(query, vars)

    def callproc(self, procname, vars=None):
        self.timestamp = time.time()
        return super(MyLoggingCursor, self).callproc(procname, vars)

# MyLogging Connection:                                                                                                             
#   a) calls MyLoggingCursor rather than the default                                                                                
#   b) adds resulting execution (+ transport) time via filter()                                                                     
class MyLoggingConnection(LoggingConnection):
    def filter(self, msg, curs):
        # return msg.decode(psycopg2.extensions.encodings[self.encoding], 'replace') + "   %d ms" % int((time.time() - curs.timestamp) * 1000)
        # return  "   %f ms" % int((time.time() - curs.timestamp) * 1000)
        return msg.decode(psycopg2.extensions.encodings[self.encoding], 'replace') + str( "\n>>== Execution Time: " + datetime.utcfromtimestamp(time.time() - curs.timestamp).strftime('%H:%M:%S.%f')[:-3] + '\n')

    def cursor(self, *args, **kwargs):
        kwargs.setdefault('cursor_factory', MyLoggingCursor)
        return LoggingConnection.cursor(self, *args, **kwargs)



def get_db_parameters(file_name):
    # Read connection detail from txt file
    # location = os.path.dirname(os.path.abspath(__file__))
    # parameters_file = os.path.join(location, file_name)

    with open(file_name, 'rt') as myfile:
        txt = myfile.read()
        params = txt.split()
    return params


def prompt_user_for_input():    
    while True:
        user_response = input("Do you want to proceed? (Y/N): ").strip().lower()
        if user_response == 'y':
            database = input("Enter the database name: ")
            user = input("Enter the username: ")
            password = input("Enter the password: ")
            host = input("Enter the host: ")
            port = input("Enter the port: ")
            schema = input("Enter the schema: ")
            return user, password, host, port, database, schema
        elif user_response == 'n':
            print("Function terminated.")
            exit()
        else:
            print("Invalid input. Please enter 'Y' or 'N'.")


def connection_details(file_name):
    db_prams ={}
    if os.path.exists(file_name):
        # user, password, host, port, database, schema = get_db_parameters(file_name)
        db_prams['user'], db_prams['password'], db_prams['host'], db_prams['port'], db_prams['database'], db_prams['schema'] = get_db_parameters(file_name)
    else:
        print(f"'{file_name}' not found, please enter the DB connection detail!\n")
        db_prams['user'], db_prams['password'], db_prams['host'], db_prams['port'], db_prams['database'], db_prams['schema'] = prompt_user_for_input()

    # return user, password, host, port, database, schema
    return db_prams


def setup_connection(file_name):
    # database, user, password, host, port
    """
    Set up connection to the given database
    Parameters:
    user --  username
    password -- password of user
    database -- database name
    host -- host address of database
    port -- port number of database
    schema -- schema name under the database
    """
    db_params = connection_details(file_name)
    # user, password, host, port, database, schema = db_params['user'], db_params['password'], db_params['host'], db_params['port'], db_params['database'], db_params['schema']
    try:
        # print(f"\n>> Connecting to PostgreSQL schema: '{db_params['schema']}' in database: '{db_params['database']}'")
        return psycopg2.connect(connection_factory=MyLoggingConnection, database=db_params['database'], user=db_params['user'], password=db_params['password'], host=db_params['host'], port=db_params['port'], options=f"--search_path={db_params['schema']},public")

    except (Exception, psycopg2.Error) as error:
        print("Error while connecting to PostgreSQL;", error)
        sys.exit()


def close_connection(connection, cursor):
    """
    Close connection to the database and cursor used to perform queries.
    Parameters:
    connection -- database connection
    cursor -- cursor for database connection
    """

    if cursor:
        cursor.close()
        # print("\n>> Cursor is closed")

    if connection:
        connection.close()
        # print("\n>> PostgreSQL connection is closed =======================\n")


def read_sql_file(file_path)->str:
    with open(file_path, 'r') as file:
        sql = ""
        in_multi_line_comment = False
        for line in file:
            # Check for multi-line comments
            if '/*' in line:
                in_multi_line_comment = True
            if not in_multi_line_comment:
                # Remove both single-line and multi-line comments
                line = re.sub(r'--.*$', '', line)
                line = re.sub(r'/\*.*?\*/', '', line)
                # Omit blank lines
                if not line.strip():
                    continue
                # Append the line to the SQL code
                sql += line
            # Check for the end of multi-line comments
            if '*/' in line:
                in_multi_line_comment = False
    return sql


"""
sqlalchemy
High-level abstracted interface for working with databases
sqlalchemy package provides a DB engine that can be used as an object
"""

def engineBuilder(file_name):
    user_db, password_db, host_db, port_db, database_db, schema_db = get_db_parameters(file_name)
    db_url = f'postgresql+psycopg2://{user_db}:{password_db}@{host_db}:{port_db}/{database_db}'
    # Create the sqlalchemy engine
    try:
        # Searches left-to-right
        db_engine = create_engine(db_url, connect_args={'options': '-csearch_path={},public'.format(schema_db)})
        print(f'Connection to database {database_db} was successful')

    except:
        print(f'Connection to database {database_db} failed')
    return db_engine


def main():
    folder = os.path.dirname(os.path.abspath(__file__))
    os.chdir(folder)
    DB_3DCityDB_ConDetails = "DB_3DCityDB_ConDetails.txt"
    # print(get_db_parameters(DB_3DCityDB_ConDetails))
    db_3dcitydb = engineBuilder(DB_3DCityDB_ConDetails)

    # print(setup_connection(DB_3DCityDB_ConDetails))
    # test sql import
    # sql_bgd = read_sql_file('../postgresql/layers_buildings_v5.sql')
    # print(sql_bgd)
    # sql_veg = read_sql_file('../postgresql/layers_vegetation_v5.sql')
    # print(sql_veg)

if __name__ == "__main__":
    main()
import time
import psycopg2
import psycopg2.extensions
import os
import constants as c

conn = psycopg2.connect(
    database="3DCityDB_v3.3",
    user="postgres",
    password="maitrisedb",
    host="localhost",
    port="5432",
    application_name="test"
)

#conn.set_session(autocommit=True)

install_script_dir = os.path.join(c.PLUGIN_PATH,c.PLUGIN_PKG,"postgresql")
install_scripts= sorted(os.listdir(install_script_dir))

for script in install_scripts:
    print(f"Installing {script}")
    if script in ("25_functions_k_old.sql","90_examples.sql"): continue
    with conn.cursor() as cursor:
        cursor.execute(open(os.path.join(install_script_dir,script),"r").read())
    conn.commit()



# c=0
# while True:
#     time.sleep(2)
#     print("ITER: ",c)
#     c+=1
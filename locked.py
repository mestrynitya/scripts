from flask import Flask, request, jsonify
import os
import psycopg2
import sys
from datetime import datetime, timedelta

app = Flask(__name__)
DB_DSN = os.getenv('DB_DSN')
app.config['SQLALCHEMY_DATABASE_URI'] = DB_DSN
app.config['SQLALCHEMY_TRACK_MODIFICATIONS'] = False

#DB info
db_connection_string = os.environ.get('DB_DSN', '')

def create_table(db):
    CREATE_RESOURCE_LOCKS = """
    CREATE TABLE IF NOT EXISTS resource_locks (
        id serial PRIMARY KEY,
        name text NOT NULL,
        host_id integer NOT NULL references hosts(id),
        valid_until TIMESTAMP NOT NULL,
        cpus integer NOT NULL,
        memory integer NOT NULL,
        disk integer NOT NULL,
        UNIQUE (name, host_id)
    );
    """
    cursor = db.cursor()
    cursor.execute(CREATE_RESOURCE_LOCKS)
    return db.commit()

def locked_resources(hostname, db):
    print (hostname)
    cursor = db.cursor()

    host_id = """select id from hosts where name = %(name)s"""
    cursor.execute(host_id, {"name": hostname})
    hostid = cursor.fetchone()
    statusmessage = cursor.statusmessage
    if 'SELECT 0' in statusmessage:
        message = "Got " + cursor.statusmessage + " | Host Not Found in the Database"
        return (message)
        sys.exit(1)
        # return "{} {}".format(x, message)
    sql_get_metrics = """
    select metric_id, round(value) from host_metrics where (host_id=%(host_id)s AND ((metric_id=4) OR (metric_id=10) OR (metric_id=13)))
    """
    cursor.execute(sql_get_metrics, {"host_id": hostid})
    get_metrics = cursor.fetchall()
    for i in get_metrics:
        # print("all metrics ", i)
        if i[0] == 4:
            free_cpu = int(i[1])
            print("it's a CPU", free_cpu)
        elif i[0] == 10:
            free_memory = int(i[1])
            print("it's a Memory", free_memory)
        elif i[0] == 13:
            free_disk = int(i[1])
            print("it's a disk", free_disk)
    # free_cpu = get_metrics[0]
    print("free CPU ", free_cpu)
    # free_memory = get_metrics[1]
    # free_disk = get_metrics[2]
    # print("free cpu ",free_cpu, "free_memory", free_memory, "free_disk", free_disk)
    sql = """
    insert into resource_locks(name, host_id, valid_until, cpus, memory, disk)
    values (%(name)s, %(host_id)s, %(valid_until)s, %(cpus)s, %(memory)s, %(disk)s)
    on conflict (name, host_id) do update
    set valid_until = %(valid_until)s,
    cpus = %(cpus)s,
    memory = %(memory)s,
    disk = %(disk)s
    """
    cursor.execute(sql, {"name": hostname,
                         "host_id": hostid,
                         "valid_until": datetime.utcnow() + timedelta(minutes = 30),
                         "cpus": free_cpu,
                         "memory": free_memory,
                         "disk": free_disk})
    db.commit()
    sql_resource_locks = """
    # select name, cpus, memory, disk from resource_locks where name = %(name)s
    # """
    # cursor.execute(sql_resource_locks, {"name": hostname})
    # result = cursor.fetchall()
    # print(result)
    # return jsonify(result.data)
    return "Host {} Resources | CPU : {}, Memory : {}, Disk {}".format(hostname, free_cpu, free_memory, free_disk)

@app.route("/hostname/<hostname>")
def locked_host(hostname):
    try:
        db = psycopg2.connect(db_connection_string)
    except psycopg2.Error as e:
        print("Unable to connect to the database!")
        print(e)
        sys.exit(1)
    create_table(db)
    return(locked_resources(hostname, db))    

def flask_run():
    app.run(debug=True)

if __name__ == '__main__':
    flask_run()
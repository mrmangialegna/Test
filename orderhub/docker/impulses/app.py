import time
import socket
import subprocess
import requests
import psycopg2
from prometheus_client import start_http_server, Gauge, Counter

# Metriche Prometheus
CPU_USAGE = Gauge('node_cpu_usage_percent', 'CPU usage percent')
MEM_USAGE = Gauge('node_mem_usage_percent', 'Memory usage percent')
DISK_USAGE = Gauge('node_disk_usage_percent', 'Disk usage percent')
CHECK_COUNT = Counter('health_check_count', 'Number of health checks')

def get_cpu_usage():
    with open('/proc/stat', 'r') as f:
        fields = f.readline().strip().split()
        total = sum(int(x) for x in fields[1:])
        idle = int(fields[4])
        return (1 - idle/total) * 100

def get_mem_usage():
    with open('/proc/meminfo', 'r') as f:
        lines = f.readlines()
        total = int(lines[0].split()[1])
        available = int(lines[2].split()[1])
        return (1 - available/total) * 100

def get_disk_usage():
    res = subprocess.run(['df', '/'], capture_output=True, text=True)
    pct = res.stdout.splitlines()[1].split()[4].replace('%', '')
    return int(pct)

def write_to_db(cpu, mem, disk):
    conn = psycopg2.connect(
        host='orderhub-db-svc',
        dbname='orderhubdb',
        user='postgres',
        password='abracadabra'
    )
    cur = conn.cursor()
    cur.execute('CREATE TABLE IF NOT EXISTS cpu_metrics (ts TIMESTAMPTZ DEFAULT NOW(), value FLOAT)')
    cur.execute('CREATE TABLE IF NOT EXISTS mem_metrics (ts TIMESTAMPTZ DEFAULT NOW(), value FLOAT)')
    cur.execute('CREATE TABLE IF NOT EXISTS disk_metrics (ts TIMESTAMPTZ DEFAULT NOW(), value FLOAT)')
    cur.execute('INSERT INTO cpu_metrics (value) VALUES (%s)', (cpu,))
    cur.execute('INSERT INTO mem_metrics (value) VALUES (%s)', (mem,))
    cur.execute('INSERT INTO disk_metrics (value) VALUES (%s)', (disk,))
    conn.commit()
    cur.close()
    conn.close()

def run_checks():
    while True:
        try:
            requests.get('http://orderhub-frontend-svc', timeout=5)
            sock = socket.socket(socket.AF_INET, socket.SOCK_STREAM)
            sock.settimeout(5)
            sock.connect(('orderhub-db-svc', 5432))
            sock.close()
        except Exception as e:
            print(f'Error: {e}')

        cpu = get_cpu_usage()
        mem = get_mem_usage()
        disk = get_disk_usage()
        write_to_db(cpu, mem, disk)

        CPU_USAGE.set(cpu)
        MEM_USAGE.set(mem)
        DISK_USAGE.set(disk)
        CHECK_COUNT.inc()

        time.sleep(60)

if __name__ == '__main__':
    start_http_server(8000)
    run_checks()
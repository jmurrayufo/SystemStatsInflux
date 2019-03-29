#!/usr/bin/env python3
import requests
import psutil
import socket
import time

influxDB_host = "http://192.168.3.4:8086"

min_time_between_reports = 10

t_last = time.time()
# Dummy call to init psutil tracking

while 1:

    # Loop until we are ready to report again
    while time.time() > t_last + min_time_between_reports:
        time.sleep(0.1)
    t_last = time.time()

    data = ""

    # Measure CPU %'s
    cpu_percents = psutil.cpu_percent(interval=min_time_between_reports/2, percpu=True)
    for idx,core in enumerate(cpu_percents):
        data +=  f"cpu,hostname={socket.gethostname()},core={idx} use={cpu_percents[idx]}\n"

    cpu_freqs = psutil.cpu_freq(percpu=True)
    for idx,core in enumerate(cpu_freqs):
        data +=  f"cpu,hostname={socket.gethostname()},core={idx} freq={cpu_freqs[idx]}\n"

    # Measure Memory
    mem_data = psutil.virtual_memory()
    data += f"memory,hostname={socket.gethostname()} total={mem_data.total}\n"
    data += f"memory,hostname={socket.gethostname()} available={mem_data.available}\n"
    data += f"memory,hostname={socket.gethostname()} percent={mem_data.percent}\n"
    data += f"memory,hostname={socket.gethostname()} used={mem_data.used}\n"
    data += f"memory,hostname={socket.gethostname()} free={mem_data.free}\n"
    data += f"memory,hostname={socket.gethostname()} active={mem_data.active}\n"
    data += f"memory,hostname={socket.gethostname()} inactive={mem_data.inactive}\n"
    data += f"memory,hostname={socket.gethostname()} buffers={mem_data.buffers}\n"
    data += f"memory,hostname={socket.gethostname()} cached={mem_data.cached}\n"
    data += f"memory,hostname={socket.gethostname()} shared={mem_data.shared}\n"
    data += f"memory,hostname={socket.gethostname()} slab={mem_data.slab}\n"

    # Measure Disks
    disk_use = psutil.disk_usage("/")
    data += f"disk,hostname={socket.gethostname()} total={disk_use.total},used={disk_use.used},free={disk_use.free},percent={disk_use.percent}\n"

    # Measure Processes
    num_pids = len(psutil.pids())
    data += f"pids,hostname={socket.gethostname()} count={num_pids}\n"

    host = influxDB_host + '/write'
    params = {"db":"systems","precision":"s"}
    r = requests.post( host, params=params, data=data)

# curl -XPOST 'http://192.168.3.4:8086/write?db=test' --data-binary 'cpu,hostname=herbihub,core=0 use=0.0'

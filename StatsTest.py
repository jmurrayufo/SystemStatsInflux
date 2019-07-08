#!/usr/bin/env python3.7
import requests
import psutil
import socket
import time
import uuid

influxDB_host = "http://192.168.3.4:8086"

min_time_between_reports = 10

t_last = time.time()
# Dummy call to init psutil tracking

while 1:
    data = ""
    hostname = socket.gethostname()

    # Detect MAC for host type identication
    is_vm = f"{uuid.getnode():012X}".startswith("080027")

    # Measure CPU %'s
    cpu_percents = psutil.cpu_percent(interval=min_time_between_reports-1, percpu=True)
    for idx,core in enumerate(cpu_percents):
        data +=  f"cpu,hostname={hostname},is_vm={is_vm},core={idx} use={cpu_percents[idx]}\n"

    cpu_freqs = psutil.cpu_freq(percpu=True)
    for idx,core in enumerate(cpu_freqs):
        data +=  f"cpu,hostname={hostname},is_vm={is_vm},core={idx} freq={cpu_freqs[idx].current}\n"

    # Measure Memory
    mem_data = psutil.virtual_memory()
    data += f"memory,hostname={hostname},is_vm={is_vm} total={mem_data.total}\n"
    data += f"memory,hostname={hostname},is_vm={is_vm} available={mem_data.available}\n"
    data += f"memory,hostname={hostname},is_vm={is_vm} percent={mem_data.percent}\n"
    data += f"memory,hostname={hostname},is_vm={is_vm} used={mem_data.used}\n"
    data += f"memory,hostname={hostname},is_vm={is_vm} free={mem_data.free}\n"
    data += f"memory,hostname={hostname},is_vm={is_vm} active={mem_data.active}\n"
    data += f"memory,hostname={hostname},is_vm={is_vm} inactive={mem_data.inactive}\n"
    data += f"memory,hostname={hostname},is_vm={is_vm} buffers={mem_data.buffers}\n"
    data += f"memory,hostname={hostname},is_vm={is_vm} cached={mem_data.cached}\n"
    data += f"memory,hostname={hostname},is_vm={is_vm} shared={mem_data.shared}\n"
    data += f"memory,hostname={hostname},is_vm={is_vm} slab={mem_data.slab}\n"

    # Measure Disks
    disk_use = psutil.disk_usage("/")
    data += f"disk,hostname={hostname},is_vm={is_vm} total={disk_use.total},used={disk_use.used},free={disk_use.free},percent={disk_use.percent}\n"

    # Measure Processes
    num_pids = len(psutil.pids())
    data += f"pids,hostname={hostname},is_vm={is_vm} count={num_pids}\n"

    # Measure Temperatures
    temperatures = psutil.sensors_temperatures()
    for name in temperatures:
        for idx,obj in enumerate(temperatures[name]):
            if len(obj.label) == 0:
                label = 'none'
            else:
                label = obj.label
            data += f"temperature,hostname={hostname},is_vm={is_vm},chipset={name},val_index={idx},label={label} current={obj.current}\n"

    # Mesure Network
    network = psutil.net_io_counters(pernic=True, nowrap=True)
    for interface in network:
        data += f"network,hostname={hostname},is_vm={is_vm},interface={interface} bytes_sent={network[interface].bytes_sent}\n"
        data += f"network,hostname={hostname},is_vm={is_vm},interface={interface} bytes_recv={network[interface].bytes_recv}\n"
        data += f"network,hostname={hostname},is_vm={is_vm},interface={interface} packets_sent={network[interface].packets_sent}\n"
        data += f"network,hostname={hostname},is_vm={is_vm},interface={interface} packets_recv={network[interface].packets_recv}\n"
        data += f"network,hostname={hostname},is_vm={is_vm},interface={interface} errin={network[interface].errin}\n"
        data += f"network,hostname={hostname},is_vm={is_vm},interface={interface} errout={network[interface].errout}\n"
        data += f"network,hostname={hostname},is_vm={is_vm},interface={interface} dropin={network[interface].dropin}\n"
        data += f"network,hostname={hostname},is_vm={is_vm},interface={interface} dropout={network[interface].dropout}\n"

    host = influxDB_host + '/write'
    params = {"db":"systems","precision":"s"}
    try:
        r = requests.post( host, params=params, data=data, timeout=1)
    except Exception as e:
        print("Error",e)
        time.sleep(1)
        continue

# curl -XPOST 'http://192.168.3.4:8086/write?db=test' --data-binary 'cpu,hostname=herbihub,core=0 use=0.0'

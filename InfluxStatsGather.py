#!/usr/bin/env python3.7
import psutil
import requests
import socket
import subprocess
import time
import uuid
import argparse

parser = argparse.ArgumentParser(description='Collect and log system statistics.')
parser.add_argument('--logdest', default="http://192.168.4.3:8086", help="HTTP Endpoint to post data to.")
parser.add_argument('--test', action='store_true', help="Do not post data, just collect and print")

args = parser.parse_args()

influxDB_host = args.logdest

min_time_between_reports = 5

t_last = time.time()
# Dummy call to init psutil tracking

last_network = {}

while 1:
    data = ""
    hostname = socket.gethostname()

    # Detect MAC for host type identication
    is_vm = f"{uuid.getnode():012X}".startswith("080027") or f"{uuid.getnode():012X}".startswith("525400")

    # Record uptime
    uptime = time.time() - psutil.boot_time()
    data += f"uptime,hostname={hostname},is_vm={is_vm} seconds={uptime}\n"

    # Measure CPU %'s
    cpu_percents = psutil.cpu_percent(interval=min_time_between_reports*0.8, percpu=True)
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

    # Measure ZFS on systems that support it
    try:
        zfs_data = subprocess.run(["zfs","list","-Hp"], stdout=subprocess.PIPE)

        for row in zfs_data.stdout.decode().split("\n"):
            row = row.split("\t")
            if len(row) < 5:
                continue
            data += f"zfs,hostname={hostname},is_vm={is_vm},dataset={row[0]},mountpoint={row[4]} used={row[1]},available={row[2]},referenced={row[3]}\n"
    except FileNotFoundError:
        pass

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
        # Calculate data in/out for easier graphing
        if interface in last_network:
            # Note, all values forced to be above zero incase no-wrap doesn't work
            data += f"network,hostname={hostname},is_vm={is_vm},interface={interface} d_bytes_sent={max(0, network[interface].bytes_sent - last_network[interface]['bytes_sent'])}\n"
            data += f"network,hostname={hostname},is_vm={is_vm},interface={interface} d_bytes_recv={max(0, network[interface].bytes_recv - last_network[interface]['bytes_recv'])}\n"
            data += f"network,hostname={hostname},is_vm={is_vm},interface={interface} d_packets_sent={max(0, network[interface].packets_sent - last_network[interface]['packets_sent'])}\n"
            data += f"network,hostname={hostname},is_vm={is_vm},interface={interface} d_packets_recv={max(0, network[interface].packets_recv - last_network[interface]['packets_recv'])}\n"
            data += f"network,hostname={hostname},is_vm={is_vm},interface={interface} d_errin={max(0, network[interface].errin - last_network[interface]['errin'])}\n"
            data += f"network,hostname={hostname},is_vm={is_vm},interface={interface} d_errout={max(0, network[interface].errout - last_network[interface]['errout'])}\n"
            data += f"network,hostname={hostname},is_vm={is_vm},interface={interface} d_dropin={max(0, network[interface].dropin - last_network[interface]['dropin'])}\n"
            data += f"network,hostname={hostname},is_vm={is_vm},interface={interface} d_dropout={max(0, network[interface].dropout - last_network[interface]['dropout'])}\n"
        else:
            last_network[interface] = {}

        last_network[interface]['bytes_sent'] = network[interface].bytes_sent
        last_network[interface]['bytes_recv'] = network[interface].bytes_recv
        last_network[interface]['packets_sent'] = network[interface].packets_sent
        last_network[interface]['packets_recv'] = network[interface].packets_recv
        last_network[interface]['errin'] = network[interface].errin
        last_network[interface]['errout'] = network[interface].errout
        last_network[interface]['dropin'] = network[interface].dropin
        last_network[interface]['dropout'] = network[interface].dropout

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
        if args.test:
            print(data)
        else:
            r = requests.post( host, params=params, data=data, timeout=1)
    except Exception as e:
        print("Error",e)
        continue
    
    t_sleep = t_last + min_time_between_reports - time.time()
    if t_sleep > 0:
        time.sleep(t_sleep)

    t_last = time.time()

# curl -XPOST 'http://192.168.3.4:8086/write?db=test' --data-binary 'cpu,hostname=herbihub,core=0 use=0.0'

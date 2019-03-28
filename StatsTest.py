#!/usr/bin/env python3
import requests
import psutil
import socket

influxDB_host = "http://192.168.3.4:8086"

while 1:
    data = ""
    cpu_percents = psutil.cpu_percent(interval=1, percpu=True)

    for idx,core in enumerate(cpu_percents):
        data +=  f"cpu,hostname={socket.gethostname()},core={idx} use={cpu_percents[0]}\n"

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
    
    # data = f"cpu,hostname={socket.gethostname()},core=0 use={cpu_percents[0]}"

    # print(data)
    host = influxDB_host + '/write'
    # print(host)
    params = {"db":"test","precision":"s"}
    r = requests.post( host, params=params, data=data)
    print(r)
    # print(r.text)
    # exit()


# curl -XPOST 'http://192.168.3.4:8086/write?db=test' --data-binary 'cpu,hostname=herbihub,core=0 use=0.0'
#!/bin/bash
cat InfluxStatsGather.py | sha256sum | awk '{print $1}' > InfluxStatsGather.sha256

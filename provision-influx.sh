#!/bin/bash

echo "Provission DB"

# Create sensor DB
influx -execute 'CREATE DATABASE sensors'
# Create system DB
influx -execute 'CREATE DATABASE systems'
# Create path of exile DB
influx -execute 'CREATE DATABASE poe'

influx -execute 'ALTER RETENTION POLICY autogen ON sensors DURATION 3d REPLICATION 1 SHARD DURATION 1d DEFAULT'
influx -execute 'ALTER RETENTION POLICY autogen ON systems DURATION 3d REPLICATION 1 SHARD DURATION 1d DEFAULT'
influx -execute 'ALTER RETENTION POLICY autogen ON poe DURATION 1d REPLICATION 1 SHARD DURATION 1d DEFAULT'

influx -execute 'CREATE RETENTION POLICY a_week ON sensors DURATION 7d REPLICATION 1 SHARD DURATION 1d'
influx -execute 'CREATE RETENTION POLICY a_week ON systems DURATION 7d REPLICATION 1 SHARD DURATION 1d'
#influx -execute 'CREATE RETENTION POLICY a_week ON poe DURATION 7d REPLICATION 1 SHARD DURATION 1d'

influx -execute 'CREATE RETENTION POLICY a_month ON sensors DURATION 31d REPLICATION 1 SHARD DURATION 1d'
influx -execute 'CREATE RETENTION POLICY a_month ON systems DURATION 31d REPLICATION 1 SHARD DURATION 1d'
influx -execute 'CREATE RETENTION POLICY a_month ON poe DURATION 31d REPLICATION 1 SHARD DURATION 1d'

influx -execute 'CREATE RETENTION POLICY a_year ON sensors DURATION 52w REPLICATION 1 SHARD DURATION 1w'
influx -execute 'CREATE RETENTION POLICY a_year ON systems DURATION 52w REPLICATION 1 SHARD DURATION 1w'
influx -execute 'CREATE RETENTION POLICY a_year ON poe DURATION 52w REPLICATION 1 SHARD DURATION 1w'

influx -execute 'CREATE RETENTION POLICY forever ON sensors DURATION inf REPLICATION 1 SHARD DURATION 1w'
influx -execute 'CREATE RETENTION POLICY forever ON systems DURATION inf REPLICATION 1 SHARD DURATION 1w'
influx -execute 'CREATE RETENTION POLICY forever ON poe DURATION inf REPLICATION 1 SHARD DURATION 1w'

# Sensor retention policy
# a_week: 7d/1d  
#   any data first lands here
# a_month: 30d/1d
#   Data is descimated from any time scale to 1/minute
# a_year: 52w/7d
#   Data is further descimated to 6/hour (10 minutes)
# forever: inf/7d
#   Data is finally descimated to hours and saved forever

influx -execute 'CREATE CONTINUOUS QUERY "cq_10s" ON "sensors" BEGIN SELECT mean(*) INTO "sensors"."a_week".:MEASUREMENT FROM /.*/ GROUP BY time(10s),* END'
influx -execute 'CREATE CONTINUOUS QUERY "cq_10s" ON "systems" BEGIN SELECT mean(*) INTO "systems"."a_week".:MEASUREMENT FROM /.*/ GROUP BY time(10s),* END'
#influx -execute 'CREATE CONTINUOUS QUERY "cq_10s" ON "poe" BEGIN SELECT mean(*) INTO "poe"."a_week".:MEASUREMENT FROM /.*/ GROUP BY time(10s),* END'

influx -execute 'CREATE CONTINUOUS QUERY "cq_1min_mean" ON "sensors" BEGIN SELECT mean(*) INTO "sensors"."a_month".:MEASUREMENT FROM /.*/ GROUP BY time(1m),* END'
influx -execute 'CREATE CONTINUOUS QUERY "cq_1min_mean" ON "systems" BEGIN SELECT mean(*) INTO "systems"."a_month".:MEASUREMENT FROM /.*/ GROUP BY time(1m),* END'
influx -execute 'CREATE CONTINUOUS QUERY "cq_1min_mean" ON "poe" BEGIN SELECT mean(*) INTO "poe"."a_month".:MEASUREMENT FROM /.*/ GROUP BY time(1m),* END'

influx -execute 'CREATE CONTINUOUS QUERY "cq_10min" ON "sensors" BEGIN SELECT mean(*) INTO "sensors"."a_year".:MEASUREMENT FROM /.*/ GROUP BY time(10m),* END'
influx -execute 'CREATE CONTINUOUS QUERY "cq_10min" ON "systems" BEGIN SELECT mean(*) INTO "systems"."a_year".:MEASUREMENT FROM /.*/ GROUP BY time(10m),* END'
influx -execute 'CREATE CONTINUOUS QUERY "cq_10min" ON "poe" BEGIN SELECT mean(*) INTO "poe"."a_year".:MEASUREMENT FROM /.*/ GROUP BY time(10m),* END'

influx -execute 'CREATE CONTINUOUS QUERY "cq_1hr_mean" ON "sensors" BEGIN SELECT mean(*) INTO "sensors"."forever".:MEASUREMENT FROM /.*/ GROUP BY time(1h),* END'
influx -execute 'CREATE CONTINUOUS QUERY "cq_1hr_mean" ON "systems" BEGIN SELECT mean(*) INTO "systems"."forever".:MEASUREMENT FROM /.*/ GROUP BY time(1h),* END'
influx -execute 'CREATE CONTINUOUS QUERY "cq_1hr_mean" ON "poe" BEGIN SELECT mean(*) INTO "poe"."forever".:MEASUREMENT FROM /.*/ GROUP BY time(1h),* END'


influx -execute 'CREATE CONTINUOUS QUERY "cq_10s_sum" ON "sensors" BEGIN SELECT sum(*) INTO "sensors"."a_week".:MEASUREMENT FROM /.*/ GROUP BY time(10s),* END'
influx -execute 'CREATE CONTINUOUS QUERY "cq_10s_sum" ON "systems" BEGIN SELECT sum(*) INTO "systems"."a_week".:MEASUREMENT FROM /.*/ GROUP BY time(10s),* END'
#influx -execute 'CREATE CONTINUOUS QUERY "cq_10s_sum" ON "poe" BEGIN SELECT sum(*) INTO "poe"."a_week".:MEASUREMENT FROM /.*/ GROUP BY time(10s),* END'

influx -execute 'CREATE CONTINUOUS QUERY "cq_1min_sum" ON "sensors" BEGIN SELECT sum(*) INTO "sensors"."a_month".:MEASUREMENT FROM /.*/ GROUP BY time(1m),* END'
influx -execute 'CREATE CONTINUOUS QUERY "cq_1min_sum" ON "systems" BEGIN SELECT sum(*) INTO "systems"."a_month".:MEASUREMENT FROM /.*/ GROUP BY time(1m),* END'
influx -execute 'CREATE CONTINUOUS QUERY "cq_1min_sum" ON "poe" BEGIN SELECT sum(*) INTO "poe"."a_month".:MEASUREMENT FROM /.*/ GROUP BY time(1m),* END'

influx -execute 'CREATE CONTINUOUS QUERY "cq_10min_sum" ON "sensors" BEGIN SELECT sum(*) INTO "sensors"."a_year".:MEASUREMENT FROM /.*/ GROUP BY time(10m),* END'
influx -execute 'CREATE CONTINUOUS QUERY "cq_10min_sum" ON "systems" BEGIN SELECT sum(*) INTO "systems"."a_year".:MEASUREMENT FROM /.*/ GROUP BY time(10m),* END'
influx -execute 'CREATE CONTINUOUS QUERY "cq_10min_sum" ON "poe" BEGIN SELECT sum(*) INTO "poe"."a_year".:MEASUREMENT FROM /.*/ GROUP BY time(10m),* END'

influx -execute 'CREATE CONTINUOUS QUERY "cq_1hr_sum" ON "sensors" BEGIN SELECT sum(*) INTO "sensors"."forever".:MEASUREMENT FROM /.*/ GROUP BY time(1h),* END'
influx -execute 'CREATE CONTINUOUS QUERY "cq_1hr_sum" ON "systems" BEGIN SELECT sum(*) INTO "systems"."forever".:MEASUREMENT FROM /.*/ GROUP BY time(1h),* END'
influx -execute 'CREATE CONTINUOUS QUERY "cq_1hr_sum" ON "poe" BEGIN SELECT sum(*) INTO "poe"."forever".:MEASUREMENT FROM /.*/ GROUP BY time(1h),* END'


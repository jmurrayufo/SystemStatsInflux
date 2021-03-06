#!/bin/bash

echo "Provission DB"

# Create sensor DB
influx -execute 'CREATE DATABASE sensors'
# Create system DB
influx -execute 'CREATE DATABASE systems'
# Create path of exile DB
influx -execute 'CREATE DATABASE poe'
influx -execute 'CREATE DATABASE poe_currency'
# Create Weather DB
influx -execute 'CREATE DATABASE weather'
# Create Tesla DB
influx -execute 'CREATE DATABASE tesla'

echo 'Create autogen retention policies'
influx -execute 'ALTER RETENTION POLICY autogen ON sensors DURATION 3d REPLICATION 1 SHARD DURATION 1d DEFAULT'
influx -execute 'ALTER RETENTION POLICY autogen ON systems DURATION 3d REPLICATION 1 SHARD DURATION 1d DEFAULT'
influx -execute 'ALTER RETENTION POLICY autogen ON poe DURATION 1d REPLICATION 1 SHARD DURATION 1d DEFAULT'
influx -execute 'ALTER RETENTION POLICY autogen ON poe_currency DURATION 3d REPLICATION 1 SHARD DURATION 1d DEFAULT'
influx -execute 'ALTER RETENTION POLICY autogen ON weather DURATION 3d REPLICATION 1 SHARD DURATION 1d DEFAULT'
influx -execute 'ALTER RETENTION POLICY autogen ON tesla DURATION 3d REPLICATION 1 SHARD DURATION 1d DEFAULT'

echo 'Create weekly retention policies'
influx -execute 'CREATE RETENTION POLICY a_week ON sensors DURATION 7d REPLICATION 1 SHARD DURATION 1d'
influx -execute 'CREATE RETENTION POLICY a_week ON systems DURATION 7d REPLICATION 1 SHARD DURATION 1d'
#influx -execute 'CREATE RETENTION POLICY a_week ON poe DURATION 7d REPLICATION 1 SHARD DURATION 1d'
influx -execute 'CREATE RETENTION POLICY a_week ON poe_currency DURATION 7d REPLICATION 1 SHARD DURATION 1d'
influx -execute 'CREATE RETENTION POLICY a_week ON weather DURATION 7d REPLICATION 1 SHARD DURATION 1d'
influx -execute 'CREATE RETENTION POLICY a_week ON tesla DURATION 7d REPLICATION 1 SHARD DURATION 1d'

echo 'Create monthly retention policies'
influx -execute 'CREATE RETENTION POLICY a_month ON sensors DURATION 31d REPLICATION 1 SHARD DURATION 1d'
influx -execute 'CREATE RETENTION POLICY a_month ON systems DURATION 31d REPLICATION 1 SHARD DURATION 1d'
influx -execute 'CREATE RETENTION POLICY a_month ON poe DURATION 31d REPLICATION 1 SHARD DURATION 1d'
influx -execute 'CREATE RETENTION POLICY a_month ON poe_currency DURATION 31d REPLICATION 1 SHARD DURATION 1d'
influx -execute 'CREATE RETENTION POLICY a_month ON weather DURATION 31d REPLICATION 1 SHARD DURATION 1d'
influx -execute 'CREATE RETENTION POLICY a_month ON tesla DURATION 31d REPLICATION 1 SHARD DURATION 1d'

echo 'Create yearly retention policies'
influx -execute 'CREATE RETENTION POLICY a_year ON sensors DURATION 52w REPLICATION 1 SHARD DURATION 1w'
influx -execute 'CREATE RETENTION POLICY a_year ON systems DURATION 52w REPLICATION 1 SHARD DURATION 1w'
influx -execute 'CREATE RETENTION POLICY a_year ON poe DURATION 52w REPLICATION 1 SHARD DURATION 1w'
influx -execute 'CREATE RETENTION POLICY a_year ON poe_currency DURATION 52w REPLICATION 1 SHARD DURATION 1w'
influx -execute 'CREATE RETENTION POLICY a_year ON weather DURATION 52w REPLICATION 1 SHARD DURATION 1w'
influx -execute 'CREATE RETENTION POLICY a_year ON tesla DURATION 52w REPLICATION 1 SHARD DURATION 1w'

echo 'Create eternal retention policies'
influx -execute 'CREATE RETENTION POLICY forever ON sensors DURATION inf REPLICATION 1 SHARD DURATION 1w'
influx -execute 'CREATE RETENTION POLICY forever ON systems DURATION inf REPLICATION 1 SHARD DURATION 1w'
influx -execute 'CREATE RETENTION POLICY forever ON poe DURATION inf REPLICATION 1 SHARD DURATION 1w'
influx -execute 'CREATE RETENTION POLICY forever ON poe_currency DURATION inf REPLICATION 1 SHARD DURATION 1w'
influx -execute 'CREATE RETENTION POLICY forever ON weather DURATION inf REPLICATION 1 SHARD DURATION 1w'
influx -execute 'CREATE RETENTION POLICY forever ON tesla DURATION inf REPLICATION 1 SHARD DURATION 1w'

# Sensor retention policy
# a_week: 7d/1d  
#   any data first lands here
# a_month: 30d/1d
#   Data is descimated from any time scale to 1/minute
# a_year: 52w/7d
#   Data is further descimated to 6/hour (10 minutes)
# forever: inf/7d
#   Data is finally descimated to hours and saved forever

echo 'Create sensor CQs'
influx -execute 'CREATE CONTINUOUS QUERY "cq_10s" ON "sensors" BEGIN SELECT mean(*) INTO "sensors"."a_week".:MEASUREMENT FROM /.*/ GROUP BY time(10s),* END'
influx -execute 'CREATE CONTINUOUS QUERY "cq_1min_mean" ON "sensors" BEGIN SELECT mean(*) INTO "sensors"."a_month".:MEASUREMENT FROM /.*/ GROUP BY time(1m),* END'
influx -execute 'CREATE CONTINUOUS QUERY "cq_10min" ON "sensors" BEGIN SELECT mean(*) INTO "sensors"."a_year".:MEASUREMENT FROM /.*/ GROUP BY time(10m),* END'
influx -execute 'CREATE CONTINUOUS QUERY "cq_1hr_mean" ON "sensors" BEGIN SELECT mean(*) INTO "sensors"."forever".:MEASUREMENT FROM /.*/ GROUP BY time(1h),* END'

influx -execute 'CREATE CONTINUOUS QUERY "cq_10s_sum" ON "sensors" BEGIN SELECT sum(*) INTO "sensors"."a_week".:MEASUREMENT FROM /.*/ GROUP BY time(10s),* END'
influx -execute 'CREATE CONTINUOUS QUERY "cq_1min_sum" ON "sensors" BEGIN SELECT sum(*) INTO "sensors"."a_month".:MEASUREMENT FROM /.*/ GROUP BY time(1m),* END'
influx -execute 'CREATE CONTINUOUS QUERY "cq_10min_sum" ON "sensors" BEGIN SELECT sum(*) INTO "sensors"."a_year".:MEASUREMENT FROM /.*/ GROUP BY time(10m),* END'
influx -execute 'CREATE CONTINUOUS QUERY "cq_1hr_sum" ON "sensors" BEGIN SELECT sum(*) INTO "sensors"."forever".:MEASUREMENT FROM /.*/ GROUP BY time(1h),* END'

echo 'Create system CQs'
influx -execute 'CREATE CONTINUOUS QUERY "cq_10s" ON "systems" BEGIN SELECT mean(*) INTO "systems"."a_week".:MEASUREMENT FROM /.*/ GROUP BY time(10s),* END'
influx -execute 'CREATE CONTINUOUS QUERY "cq_1min_mean" ON "systems" BEGIN SELECT mean(*) INTO "systems"."a_month".:MEASUREMENT FROM /.*/ GROUP BY time(1m),* END'
influx -execute 'CREATE CONTINUOUS QUERY "cq_10min" ON "systems" BEGIN SELECT mean(*) INTO "systems"."a_year".:MEASUREMENT FROM /.*/ GROUP BY time(10m),* END'
influx -execute 'CREATE CONTINUOUS QUERY "cq_1hr_mean" ON "systems" BEGIN SELECT mean(*) INTO "systems"."forever".:MEASUREMENT FROM /.*/ GROUP BY time(1h),* END'

influx -execute 'CREATE CONTINUOUS QUERY "cq_10s_sum" ON "systems" BEGIN SELECT sum(*) INTO "systems"."a_week".:MEASUREMENT FROM /.*/ GROUP BY time(10s),* END'
influx -execute 'CREATE CONTINUOUS QUERY "cq_1min_sum" ON "systems" BEGIN SELECT sum(*) INTO "systems"."a_month".:MEASUREMENT FROM /.*/ GROUP BY time(1m),* END'
influx -execute 'CREATE CONTINUOUS QUERY "cq_10min_sum" ON "systems" BEGIN SELECT sum(*) INTO "systems"."a_year".:MEASUREMENT FROM /.*/ GROUP BY time(10m),* END'
influx -execute 'CREATE CONTINUOUS QUERY "cq_1hr_sum" ON "systems" BEGIN SELECT sum(*) INTO "systems"."forever".:MEASUREMENT FROM /.*/ GROUP BY time(1h),* END'

echo 'Create Path of Exile CQs'
#influx -execute 'CREATE CONTINUOUS QUERY "cq_10s" ON "poe" BEGIN SELECT mean(*) INTO "poe"."a_week".:MEASUREMENT FROM /.*/ GROUP BY time(10s),* END'
influx -execute 'CREATE CONTINUOUS QUERY "cq_1min_mean" ON "poe" BEGIN SELECT mean(*) INTO "poe"."a_month".:MEASUREMENT FROM /.*/ GROUP BY time(1m),* END'
influx -execute 'CREATE CONTINUOUS QUERY "cq_10min" ON "poe" BEGIN SELECT mean(*) INTO "poe"."a_year".:MEASUREMENT FROM /.*/ GROUP BY time(10m),* END'
influx -execute 'CREATE CONTINUOUS QUERY "cq_1hr_mean" ON "poe" BEGIN SELECT mean(*) INTO "poe"."forever".:MEASUREMENT FROM /.*/ GROUP BY time(1h),* END'

#influx -execute 'CREATE CONTINUOUS QUERY "cq_10s_sum" ON "poe" BEGIN SELECT sum(*) INTO "poe"."a_week".:MEASUREMENT FROM /.*/ GROUP BY time(10s),* END'
influx -execute 'CREATE CONTINUOUS QUERY "cq_1min_sum" ON "poe" BEGIN SELECT sum(*) INTO "poe"."a_month".:MEASUREMENT FROM /.*/ GROUP BY time(1m),* END'
influx -execute 'CREATE CONTINUOUS QUERY "cq_10min_sum" ON "poe" BEGIN SELECT sum(*) INTO "poe"."a_year".:MEASUREMENT FROM /.*/ GROUP BY time(10m),* END'
influx -execute 'CREATE CONTINUOUS QUERY "cq_1hr_sum" ON "poe" BEGIN SELECT sum(*) INTO "poe"."forever".:MEASUREMENT FROM /.*/ GROUP BY time(1h),* END'

echo 'Create Path of Exile Currency CQs'
influx -execute 'CREATE CONTINUOUS QUERY "cq_10min" ON "poe_currency" BEGIN SELECT mean(*),median(*),count(*),spread(*),stddev(*),min(*),max(*) INTO "poe_currency"."a_month".:MEASUREMENT FROM /.*/ GROUP BY time(10m),* END'
influx -execute 'CREATE CONTINUOUS QUERY "cq_1hour" ON "poe_currency" BEGIN SELECT mean(*),median(*),count(*),spread(*),stddev(*),min(*),max(*) INTO "poe_currency"."a_year".:MEASUREMENT FROM /.*/ GROUP BY time(1h),* END'
# Note, these things are kinda wonky for data we only get every minute or two.... 
#influx -execute 'CREATE CONTINUOUS QUERY "cq_1min_stats" ON "poe_currency" BEGIN SELECT mean(*) INTO "poe_currency"."a_month".:MEASUREMENT FROM /.*/ GROUP BY time(1m),* END'
#influx -execute 'CREATE CONTINUOUS QUERY "cq_10min_stats" ON "poe_currency" BEGIN SELECT mean(*) INTO "poe_currency"."a_year".:MEASUREMENT FROM /.*/ GROUP BY time(10m),* END'
#influx -execute 'CREATE CONTINUOUS QUERY "cq_1hr_stats" ON "poe_currency" BEGIN SELECT mean(*) INTO "poe_currency"."forever".:MEASUREMENT FROM /.*/ GROUP BY time(1h),* END'

echo 'Create weather CQs'
influx -execute 'CREATE CONTINUOUS QUERY "cq_10s" ON "weather" RESAMPLE FOR 1h BEGIN SELECT mean(*),sum(*),min(*),max(*) INTO "weather"."a_week".:MEASUREMENT FROM /.*/ GROUP BY time(10s),* END'
influx -execute 'CREATE CONTINUOUS QUERY "cq_1min" ON "weather" RESAMPLE FOR 1h BEGIN SELECT mean(*),sum(*),min(*),max(*) INTO "weather"."a_month".:MEASUREMENT FROM /.*/ GROUP BY time(1m),* END'
influx -execute 'CREATE CONTINUOUS QUERY "cq_10min" ON "weather" RESAMPLE FOR 1h BEGIN SELECT mean(*),sum(*),min(*),max(*) INTO "weather"."a_year".:MEASUREMENT FROM /.*/ GROUP BY time(10m),* END'
influx -execute 'CREATE CONTINUOUS QUERY "cq_1hr" ON "weather" RESAMPLE FOR 2h BEGIN SELECT mean(*),sum(*),min(*),max(*) INTO "weather"."forever".:MEASUREMENT FROM /.*/ GROUP BY time(1h),* END'

echo 'Create tesla CQs'
influx -execute 'CREATE CONTINUOUS QUERY "cq_10s" ON "tesla" BEGIN SELECT mean(*),sum(*),min(*),max(*) INTO "tesla"."a_week".:MEASUREMENT FROM /.*/ GROUP BY time(10s),* END'
influx -execute 'CREATE CONTINUOUS QUERY "cq_1min" ON "tesla" BEGIN SELECT mean(*),sum(*),min(*),max(*) INTO "tesla"."a_month".:MEASUREMENT FROM /.*/ GROUP BY time(1m),* END'
influx -execute 'CREATE CONTINUOUS QUERY "cq_10min" ON "tesla" BEGIN SELECT mean(*),sum(*),min(*),max(*) INTO "tesla"."a_year".:MEASUREMENT FROM /.*/ GROUP BY time(10m),* END'
influx -execute 'CREATE CONTINUOUS QUERY "cq_1hr" ON "tesla" BEGIN SELECT mean(*),sum(*),min(*),max(*) INTO "tesla"."forever".:MEASUREMENT FROM /.*/ GROUP BY time(1h),* END'


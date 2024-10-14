#!/bin/bash
service ssh start
if [ "$SPARK_ROLE" == "master" ]; then
  start-master.sh
else
  start-slave.sh spark://spark-master:7077
fi
tail -f /dev/null

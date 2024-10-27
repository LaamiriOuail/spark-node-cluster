#!/bin/bash

echo "Example 2: Create and Query Hive Table"

# Copy the purchases1 file to the Hive container
docker cp input/purchases1.txt docker-hive-hive-server-1:/opt/purchases1.txt

# Copy the HQL script to the Hive container
docker cp purchases_queries.hql docker-hive-hive-server-1:/opt/purchases_queries.hql

# Run the Hive script using Beeline
docker exec -i docker-hive-hive-server-1 bash -c "
  /opt/hive/bin/beeline -u jdbc:hive2://localhost:10000 -f /opt/purchases_queries.hql
"

echo "Queries executed and results displayed."

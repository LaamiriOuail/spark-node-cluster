#!/bin/bash

echo "Application"

echo "Example 1:"

# Copy the input file to the Hive container
docker cp input/file.txt docker-hive-hive-server-1:/opt/file.txt

# Run commands in Hive server container
docker exec -i docker-hive-hive-server-1 bash -c "
  /opt/hive/bin/beeline -u jdbc:hive2://localhost:10000 -e \"
    CREATE TABLE IF NOT EXISTS FILES(line STRING);
    LOAD DATA LOCAL INPATH '/opt/file.txt' OVERWRITE INTO TABLE FILES;
    CREATE TABLE IF NOT EXISTS word_counts AS 
      SELECT word, COUNT(1) AS count 
      FROM (SELECT explode(split(line, ' ')) AS word FROM FILES) w 
      GROUP BY word 
      ORDER BY word;
    INSERT OVERWRITE TABLE word_counts 
      SELECT word, COUNT(1) AS count 
      FROM (SELECT explode(split(line, ' ')) AS word FROM FILES) w 
      GROUP BY word 
      ORDER BY word;
    SELECT * FROM word_counts;
  \"
"

echo "Example query executed and results displayed."

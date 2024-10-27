#!/bin/bash


echo "Application"

echo "Example 1: "

docker cp input/purchases.txt dokcer-hive:/opt/purchases.txt

docker exec -it docker-hive-hive-server-1 bash

/otp/hive/bin/beeline -u jdbc:hive2://localhost:10000

CREATE TABLE FILES(line STRING);

LOAD DATA LOCAL INPATH 'purchases.txt' OVERWRITE INTO TABLE FILES;

CREATE TABLE word_counts AS SELECT word,count(1) AS count FROM (SELECT explode(split(line,' ')) AS word FROM FILES) w GROUP BY word ORDER BY word;

SELECT * FROM word_counts;

exit;
















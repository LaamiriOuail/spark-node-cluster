#!/bin/bash

cd docker-hive

docker compose up -d

docker compose up -d presto-coordinator

docker exec -it docker-hive-hive-server-1 bash

/opt/hive/bin/beeline -u jdbc:hive2://localhost:10000

CREATE TABLE pokes(foo INT,bar STRING)

LOAD DATA LOCAL INPATH '/opt/hive/examples/files/kv1.txt' OVERWRITE INTO TABLE pokes;

exit;

curl -o presto-cli-308-executable.jar https://repo1.maven.org/maven2/io/prestosql/presto-cli/308/presto-cli-308-executable.jar

mv presto-cli-308-executable.jar presto.jar

java -jar presto.jar --server localhost:8080 --catalog hive --schema default 

select * from pokes;

exit;

docker pull gethue/hue:latest

docker run -it -p 8888:8888 gethue/hue:latest

./build/env/bin/pip install Werkzeug

./build/env/bin/hue runserver_plus 0.0.0.0:88888












































#!/bin/bash

# Navigate to docker-hive directory
cd docker-hive || exit

# Start Docker services
docker compose up -d
docker compose up -d presto-coordinator

# Wait for services to initialize
sleep 15  # Adjust based on service initialization time

# Run commands within Hive server
docker exec -i docker-hive-hive-server-1 bash -c "
  cd /
  /opt/hive/bin/beeline -u jdbc:hive2://localhost:10000 -e \"
    CREATE TABLE IF NOT EXISTS pokes(foo INT, bar STRING);
    LOAD DATA LOCAL INPATH '/opt/hive/examples/files/kv1.txt' OVERWRITE INTO TABLE pokes;
  \"
"

# Download and setup Presto CLI
curl -o presto.jar https://repo1.maven.org/maven2/io/prestosql/presto-cli/308/presto-cli-308-executable.jar
chmod +x presto.jar

# Run Presto CLI and execute query
java -jar presto.jar --server localhost:8080 --catalog hive --schema default --execute "SELECT * FROM pokes;"

# Start Hue
docker pull gethue/hue:latest
docker run -p 8888:8888 gethue/hue:latest &

# Install additional Python packages for Hue
docker exec -it $(docker ps -qf "ancestor=gethue/hue:latest") bash -c "
  ./build/env/bin/pip install Werkzeug &&
  ./build/env/bin/hue runserver_plus 0.0.0.0:8888
"

# Open Hue in Firefox or Chrome if available
if command -v firefox &> /dev/null
then
    firefox http://0.0.0.0:8888
elif command -v google-chrome &> /dev/null
then
    google-chrome http://0.0.0.0:8888
elif command -v xdg-open &> /dev/null
then
    xdg-open http://0.0.0.0:8888
else
    echo "No supported browser found. Please open http://0.0.0.0:8888 manually."
fi

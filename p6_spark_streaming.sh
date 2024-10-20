#!/bin/bash

# Usage: ./run_spark_streaming_project.sh <container_name>
if [ -z "$1" ]; then
  echo "Error: Container name not provided."
  echo "Usage: ./run_spark_streaming_project.sh <container_name>"
  exit 1
fi

CONTAINER_NAME=$1
JAR_FILE=spark-streaming/target/stream-1.jar

# Copy the JAR file to the container
docker cp "$JAR_FILE" "$CONTAINER_NAME:/root/stream-1.jar"

# Run the Spark Streaming application inside the container
docker exec -it "$CONTAINER_NAME" bash -c "spark-submit \
    --class tn.spark.streaming.Stream \
    --master local[2] /root/stream-1.jar"

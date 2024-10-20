#!/bin/bash

# Usage: ./run_spark_rdd_project.sh <container_name>
if [ -z "$1" ]; then
  echo "Error: Container name not provided."
  echo "Usage: ./run_spark_rdd_project.sh <container_name>"
  exit 1
fi

CONTAINER_NAME=$1
JAR_FILE=spark-wordcount/target/wordcount-1.0-SNAPSHOT.jar
INPUT_FOLDER="/root/input"
OUTPUT_FOLDER="/root/output"  # Output should be a directory
TEXT_FILE="input/file.txt"
HOST_OUTPUT_PATH="./output"  # Adjust the path as necessary

# Create the output directory on the host if it doesn't exist
mkdir -p $HOST_OUTPUT_PATH

# 2. Copy the input file and jar to the master container
echo "Copying necessary files to the Spark Master..."
docker exec -it $CONTAINER_NAME bash -c "mkdir -p $INPUT_FOLDER && mkdir -p $OUTPUT_FOLDER"

docker cp $TEXT_FILE $CONTAINER_NAME:$INPUT_FOLDER/file.txt
docker cp $JAR_FILE $CONTAINER_NAME:/root/wordcount-1.jar

# 3. Remove the existing output directory if it exists
echo "Removing existing output directory if it exists..."
docker exec -it $CONTAINER_NAME bash -c "if [ -d $OUTPUT_FOLDER ]; then rm -rf $OUTPUT_FOLDER; fi"

# 4. Run spark-submit inside the master container
echo "Running Spark WordCount job..."
docker exec -it $CONTAINER_NAME bash -c "spark-submit \
  --class tn.spark.batch.WordCountTask \
  --master local /root/wordcount-1.jar $INPUT_FOLDER/file.txt $OUTPUT_FOLDER \
  && exit"

# 5. Display the output
# Copy the entire output directory from the container to the host
docker cp $CONTAINER_NAME:$OUTPUT_FOLDER $HOST_OUTPUT_PATH/

# Display the results
echo "Job finished. Output files:"
ls $HOST_OUTPUT_PATH/output  # List the output files

# Concatenate and display the contents of all part files
echo "Contents of the output files:"
cat $HOST_OUTPUT_PATH/output/part-*  # This assumes multiple part files may exist

echo "Done."

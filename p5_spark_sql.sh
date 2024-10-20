#!/bin/bash

# Usage: ./run_spark_rdd_project.sh <container_name>
if [ -z "$1" ]; then
  echo "Error: Container name not provided."
  echo "Usage: ./script.sh <container_name>"
  exit 1
fi

CONTAINER_NAME=$1

# Enter the spark-master container

echo "Entering the Spark master container..."

INPUT_FOLDER="/root/input"
OUTPUT_FOLDER="/root/output"  # Output should be a directory
TEXT_FILE="input/purchases.txt"
HOST_OUTPUT_PATH="./output"  # Adjust the path as necessary
docker cp $TEXT_FILE $CONTAINER_NAME:$INPUT_FOLDER/purchases.txt

docker exec -it $CONTAINER_NAME bash -c '
# Navigate to the input directory
cd ~/input

# Check if purchases.txt already exists
if [ ! -f "purchases.txt" ]; then
    echo "File not exist /root/input/purchases.txt..."
    exit 1
fi

# List the contents to confirm the file is present
echo "Listing contents of ~/input:"
ls

# Start spark-shell for RDD operations
echo "Starting Spark shell for RDD operations..."
spark-shell << EOF
// Load the purchases.txt into an RDD
val allData = sc.textFile("/root/input/purchases.txt")

// Transformation 1: Split the fields
val splitted = allData.map(line => line.split("\\t"))

// Transformation 2: Extract key-value pairs
val pairs = splitted.map(splitted => (splitted(2), splitted(4).toFloat))

// Transformation 3: Calculate the total sales per city
val finalResult = pairs.reduceByKey(_ + _)

// Save the result to a text file
finalResult.saveAsTextFile("/root/output/purchase-rdd.count")

// Show the result
println("RDD results:")
finalResult.collect().foreach(println)
EOF

# Start spark-shell for DataFrame operations
echo "Starting Spark shell for DataFrame operations..."
spark-shell << EOF
// Import necessary classes
import org.apache.spark.sql.types.{StructType, StructField, StringType, FloatType}

// Define the schema
val customSchema = StructType(Seq(
  StructField("date", StringType, true),
  StructField("time", StringType, true),
  StructField("town", StringType, true),
  StructField("product", StringType, true),
  StructField("price", FloatType, true),
  StructField("payment", StringType, true)
))

// Read the purchases.txt file as a DataFrame
val resultAsACsvFormat = spark.read.schema(customSchema).option("delimiter", "\\t").csv("/root/input/purchases.txt")

// Group by town and sum the prices
val finalResultDF = resultAsACsvFormat.groupBy("town").sum("price")

// Save the results to a text file
finalResultDF.rdd.saveAsTextFile("/root/output/purchase-df.count")

// Show the result
println("DataFrame results:")
finalResultDF.show()
EOF

# Start spark-shell for Dataset operations
echo "Starting Spark shell for Dataset operations..."
spark-shell << EOF
// Import necessary classes
import org.apache.spark.sql.types.{StructType, StructField, StringType, FloatType}

// Define the schema
val customSchema = StructType(Seq(
  StructField("date", StringType, true),
  StructField("time", StringType, true),
  StructField("town", StringType, true),
  StructField("product", StringType, true),
  StructField("price", FloatType, true),
  StructField("payment", StringType, true)
))

// Define the case class for Dataset
case class Product(date: String, time: String, town: String, product: String, price: Float, payment: String)

// Read the purchases.txt file as a Dataset
val result = spark.read.schema(customSchema).option("delimiter", "\\t").csv("/root/input/purchases.txt").as[Product]

// Group by town and sum the prices
val finalResultDS = result.groupBy("town").sum("price")

// Show the result
println("Dataset results:")
finalResultDS.show()
EOF

echo "Spark operations completed."
'

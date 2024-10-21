#!/bin/bash

# Usage: ./run_spark_rdd_project.sh <container_name>
if [ -z "$1" ]; then
  echo "Error: Container name not provided."
  echo "Usage: ./run_spark_rdd_project.sh <container_name>"
  exit 1
fi

CONTAINER_NAME=$1

# This script sets up and runs a Spark MLlib pipeline in Docker.

# Step 2: Access the master container
echo "Connecting to the Spark master container..."
docker exec -it "$CONTAINER_NAME" bash -c "
  # Step 3: Set up the environment for PySpark
  echo 'Setting up PySpark environment...'
  echo 'export PYSPARK_PYTHON=python3' >> ~/.bashrc
  echo 'export PYSPARK_DRIVER_PYTHON=python3' >> ~/.bashrc
  source ~/.bashrc

  # Step 4: Install pip3 if not already installed
  if ! command -v pip3 &> /dev/null; then
    echo 'Installing pip3...'
    apt update && apt install -y python3-pip
  fi

  # Step 5: Install necessary Python packages
  echo 'Installing required Python packages...'
  pip3 install pyspark==2.4.5
  pip3 install cloudpickle==1.3.0

  cd /root
  # Step 6: Create the pipeline.py file
  echo 'Creating pipeline.py...'
  cat <<EOL > pipeline.py
from pyspark.ml import Pipeline
from pyspark.ml.classification import LogisticRegression
from pyspark.ml.feature import HashingTF, Tokenizer
from pyspark.sql import SQLContext
from pyspark import SparkContext

sc = SparkContext(appName='Linear Regression Pipeline')
spark = SQLContext(sc)

# Prepare training documents from a list of tuples (id, text, label)
training = spark.createDataFrame([
  (0, 'a b c d e spark', 1.0),
  (1, 'b d', 0.0),
  (2, 'spark f g h', 1.0),
  (3, 'hadoop mapreduce', 0.0)
], ['id', 'text', 'label'])

# Configure the pipeline
tokenizer = Tokenizer(inputCol='text', outputCol='words')
hashingTF = HashingTF(inputCol=tokenizer.getOutputCol(), outputCol='features')
lr = LogisticRegression(maxIter=10, regParam=0.001)
pipeline = Pipeline(stages=[tokenizer, hashingTF, lr])

# Fit the pipeline to the training data
model = pipeline.fit(training)

# Prepare test documents (unlabeled)
test = spark.createDataFrame([
  (4, 'spark i j k'),
  (5, 'l m n'),
  (6, 'spark hadoop spark'),
  (7, 'apache hadoop')
], ['id', 'text'])

# Make predictions on the test data
prediction = model.transform(test)
selected = prediction.select('id', 'text', 'probability', 'prediction')
for row in selected.collect():
  rid, text, prob, prediction = row
  print('(%d, %s) --> prob=%s, prediction=%f' % (rid, text, str(prob), prediction))
EOL

  # Step 7: Run the Spark job
  echo 'Running the Spark MLlib pipeline...'
  spark-submit --conf \"spark.pyspark.python=python3\" --conf \"spark.pyspark.driver.python=python3\" pipeline.py
"

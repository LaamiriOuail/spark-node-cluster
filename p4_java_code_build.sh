#!/bin/bash


# Step 1: Create the directory structure for a Maven project
echo "Step 1: Creating Maven project structure..."
mkdir -p spark-wordcount/src/main/java/tn/spark/batch
mkdir -p spark-wordcount/src/main/resources

# Step 2: Create pom.xml file
echo "Step 2: Writing pom.xml..."
cat <<EOL > spark-wordcount/pom.xml
<project xmlns="http://maven.apache.org/POM/4.0.0"
         xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"
         xsi:schemaLocation="http://maven.apache.org/POM/4.0.0 http://maven.apache.org/xsd/maven-4.0.0.xsd">
    <modelVersion>4.0.0</modelVersion>

    <groupId>spark.batch</groupId>
    <artifactId>wordcount</artifactId>
    <version>1.0-SNAPSHOT</version>

    <properties>
        <maven.compiler.source>1.8</maven.compiler.source>
        <maven.compiler.target>1.8</maven.compiler.target>
    </properties>

    <dependencies>
        <!-- Spark Core Dependency -->
        <dependency>
            <groupId>org.apache.spark</groupId>
            <artifactId>spark-core_2.12</artifactId>
            <version>2.4.5</version>
        </dependency>

        <!-- Logging Dependency -->
        <dependency>
            <groupId>org.slf4j</groupId>
            <artifactId>slf4j-api</artifactId>
            <version>1.7.25</version>
        </dependency>
        <dependency>
            <groupId>org.slf4j</groupId>
            <artifactId>slf4j-log4j12</artifactId>
            <version>1.7.25</version>
        </dependency>
    </dependencies>
</project>
EOL

# Step 3: Write the Java WordCountTask code
echo "Step 3: Writing Java WordCountTask..."
cat <<EOL > spark-wordcount/src/main/java/tn/spark/batch/WordCountTask.java
package tn.spark.batch;

import org.apache.spark.SparkConf;
import org.apache.spark.api.java.JavaPairRDD;
import org.apache.spark.api.java.JavaRDD;
import org.apache.spark.api.java.JavaSparkContext;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import scala.Tuple2;

import java.util.Arrays;

import static jersey.repackaged.com.google.common.base.Preconditions.checkArgument;

public class WordCountTask {
    private static final Logger LOGGER = LoggerFactory.getLogger(WordCountTask.class);

    public static void main(String[] args) {
        checkArgument(args.length > 1, "Please provide the path of input file and output dir as parameters.");
        new WordCountTask().run(args[0], args[1]);
    }

    public void run(String inputFilePath, String outputDir) {
        SparkConf conf = new SparkConf()
              .setAppName(WordCountTask.class.getName());

        JavaSparkContext sc = new JavaSparkContext(conf);

        JavaRDD<String> textFile = sc.textFile(inputFilePath);
        JavaPairRDD<String, Integer> counts = textFile
                .flatMap(s -> Arrays.asList(s.split(" ")).iterator())
                .mapToPair(word -> new Tuple2<>(word, 1))
                .reduceByKey((a, b) -> a + b);
        counts.saveAsTextFile(outputDir);
    }
}
EOL

# Step 4: Create a test input file loremipsum.txt in src/main/resources
echo "Step 4: Creating test file src/main/resources/loremipsum.txt..."
echo "Lorem ipsum dolor sit amet, consectetur adipiscing elit." > spark-wordcount/src/main/resources/loremipsum.txt

# Step 5: Set JAVA_HOME if not already set
export JAVA_HOME=$(dirname $(dirname $(readlink -f $(which java))))
echo "JAVA_HOME is set to $JAVA_HOME"

# Step 6: Build the project using Maven
echo "Step 6: Building the project with Maven..."
cd spark-wordcount
mvn clean package || { echo "Maven build failed. Exiting..."; exit 1; }
cd ..
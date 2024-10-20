#!/bin/bash

# Create a new Maven project directory
PROJECT_NAME="spark-streaming"
mkdir "$PROJECT_NAME"
cd "$PROJECT_NAME" || exit

# Create pom.xml file
cat <<EOF > pom.xml
<?xml version="1.0" encoding="UTF-8"?>
<project xmlns="http://maven.apache.org/POM/4.0.0"
         xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"
         xsi:schemaLocation="http://maven.apache.org/POM/4.0.0 http://maven.apache.org/xsd/maven-4.0.0.xsd">
    <modelVersion>4.0.0</modelVersion>
    <groupId>spark.streaming</groupId>
    <artifactId>stream</artifactId>
    <version>1</version>
    <dependencies>
        <dependency>
            <groupId>org.apache.spark</groupId>
            <artifactId>spark-core_2.11</artifactId>
            <version>2.2.1</version>
        </dependency>
        <dependency>
            <groupId>org.apache.spark</groupId>
            <artifactId>spark-streaming_2.11</artifactId>
            <version>2.2.1</version>
        </dependency>
    </dependencies>
    <build>
        <plugins>
            <plugin>
                <groupId>org.apache.maven.plugins</groupId>
                <artifactId>maven-compiler-plugin</artifactId>
                <version>3.1</version>
                <configuration>
                    <source>1.8</source>
                    <target>1.8</target>
                </configuration>
            </plugin>
        </plugins>
    </build>
</project>
EOF

# Create the Java source directory structure
mkdir -p src/main/java/tn/spark/streaming

# Create Stream.java file
cat <<EOF > src/main/java/tn/spark/streaming/Stream.java
package tn.spark.streaming;

import org.apache.spark.SparkConf;
import org.apache.spark.streaming.Durations;
import org.apache.spark.streaming.api.java.JavaDStream;
import org.apache.spark.streaming.api.java.JavaPairDStream;
import org.apache.spark.streaming.api.java.JavaReceiverInputDStream;
import org.apache.spark.streaming.api.java.JavaStreamingContext;
import scala.Tuple2;

import java.util.Arrays;

public class Stream {
    public static void main(String[] args) throws InterruptedException {
        SparkConf conf = new SparkConf()
            .setAppName("NetworkWordCount")
            .setMaster("local[*]");
        JavaStreamingContext jssc =
            new JavaStreamingContext(conf, Durations.seconds(1));

        JavaReceiverInputDStream<String> lines =
            jssc.socketTextStream("localhost", 9999);

        JavaDStream<String> words =
            lines.flatMap(x -> Arrays.asList(x.split(" ")).iterator());
        JavaPairDStream<String, Integer> pairs =
            words.mapToPair(s -> new Tuple2<>(s, 1));
        JavaPairDStream<String, Integer> wordCounts =
            pairs.reduceByKey((i1, i2) -> i1 + i2);

        wordCounts.print();
        jssc.start();
        jssc.awaitTermination();
    }
}
EOF

# Step 5: Set JAVA_HOME if not already set
export JAVA_HOME=$(dirname $(dirname $(readlink -f $(which java))))
echo "JAVA_HOME is set to $JAVA_HOME"

mvn package install

# Print completion message
echo "Maven project for Spark Streaming has been created in the directory: $PROJECT_NAME"
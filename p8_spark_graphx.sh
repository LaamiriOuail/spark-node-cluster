#!/bin/bash

#!/bin/bash

# Usage: ./run_spark_streaming_project.sh <container_name>
if [ -z "$1" ]; then
  echo "Error: Container name not provided."
  echo "Usage: ./run_spark_streaming_project.sh <container_name>"
  exit 1
fi

CONTAINER_NAME=$1

# Step 1: Start the Docker containers for Spark

# Step 2: Enter the master container and launch Spark Shell
echo "Connecting to Spark master container and launching spark-shell..."
docker exec -it $CONTAINER_NAME bash -c '
  # Step 3: Start Spark Shell and run GraphX example
  echo "Launching spark-shell for GraphX example..."
  spark-shell << EOF

// Step 4: Import necessary classes for GraphX
import org.apache.spark._
import org.apache.spark.rdd.RDD
import org.apache.spark.graphx._

// Step 5: Define vertices and edges for the graph
val sommets = Array((1L,("Alia",28)),(2L,("Bechir",27)),(3L,("Chiheb",65)),(4L,("Delia",42)),(5L,("Emir",35)),(6L,("Fawzi",50)))
val aretes = Array(Edge(2,1,"follows"),Edge(4,1,"follows"),Edge(2,4,"follows"),Edge(3,2,"follows"),Edge(5,2,"follows"),Edge(5,3,"follows"),Edge(3,6,"follows"),Edge(6,5,"follows"))

// Step 6: Create the RDDs for vertices and edges
val sommetRDD: RDD[(Long, (String, Int))] = sc.parallelize(sommets)
val areteRDD: RDD[Edge[String]] = sc.parallelize(aretes)

// Step 7: Construct the graph from the vertices and edges
val graph: Graph[(String, Int), String] = Graph(sommetRDD, areteRDD)

// Step 8: Filter and display vertices where age > 30
graph.vertices.filter { case (id, (nom, age)) => age > 30 }.collect.foreach { case (id, (nom, age)) => println(s"\$nom a \$age ans") }

for (triplet <- graph.triplets.collect) {
  println(s"\${triplet.srcAttr._1} suit \${triplet.dstAttr._1}")
}

// Step 10: Create user graph and calculate inDegrees and outDegrees
case class Utilisateur(nom: String, age: Int, inDeg: Int, outDeg: Int)
val initialUserGraph: Graph[Utilisateur, String] = graph.mapVertices { case (id, (nom, age)) => Utilisateur(nom, age, 0, 0) }
val userGraph = initialUserGraph.outerJoinVertices(initialUserGraph.inDegrees) {
  case (id, u, inDegOpt) => Utilisateur(u.nom, u.age, inDegOpt.getOrElse(0), u.outDeg)
}.outerJoinVertices(initialUserGraph.outDegrees) {
  case (id, u, outDegOpt) => Utilisateur(u.nom, u.age, u.inDeg, outDegOpt.getOrElse(0))
}

// Step 11: Display users and their in-degrees (followers)
for ((id, prop) <- userGraph.vertices.collect) {
  println(s"Utilisateur \$id s'appelle \${prop.nom} et est suivi par \${prop.inDeg} personnes.")
}

// Step 12: Find the oldest follower for each user
def msgFun(triplet: EdgeContext[(String, Int), String, Int]) {
  triplet.sendToDst(triplet.srcAttr._2)
}
def reduceFun(a: Int, b: Int): Int = if (a > b) a else b
val result = graph.aggregateMessages[Int](msgFun, reduceFun)
result.collect.foreach { case (id, age) => println(s"L'abonné le plus âgé de l'utilisateur \$id a \$age ans") }

EOF
'
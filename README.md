# Big DATA :

## TP1:

[Atelier-Spark](https://liliasfaxi.github.io/Atelier-Spark/)

- Part 1 :
    - include : 
        1. P1 - Introduction au Big Data 
        2. P2 - Introduction à Apache Spark
        3. P3 - Installation de Spark 
    - solution :
        ```bash
        docker compose up -d
        ```
- Part 2 :
    - include :
        1. P4 - RDD et Batch Processing avec Spark 
    - solution :
        ```bash
        chmod +x p4_java_code_build.sh
        chmod +x p4_rdd_batch_processing.sh
        ./p4_java_code_build.sh
        ./p4_rdd_batch_processing.sh spark-master-1
        ```
    - result :
        1. go `/output` in yout laptop:
            ```bash
            cat output/output/part-00000
            ```
        2. go inside container : 
            ```bash
            docker exec -it spark-master-1 bash
            cd /root/output
            cat part-00000
            ```
Part 3:

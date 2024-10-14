# Step 1: Use Ubuntu as base image
FROM ubuntu:20.04

# Step 4: Install OpenSSH (Add this line before your SSH setup step)
RUN apt-get update && apt-get install -y openssh-server

# Step 5: Configure SSH
RUN ssh-keygen -t rsa -N "" -f /root/.ssh/id_rsa && \
    cp /root/.ssh/id_rsa.pub /root/.ssh/authorized_keys && \
    echo "service ssh start" >> ~/.bashrc


# Step 2: Install essential packages
RUN apt-get update && apt-get install -y \
    openjdk-11-jdk \
    scala \
    openssh-server \
    curl \
    vim \
    && apt-get clean

# Step 3: Install Spark
RUN curl -O https://archive.apache.org/dist/spark/spark-2.4.5/spark-2.4.5-bin-hadoop2.7.tgz && \
    tar xvf spark-2.4.5-bin-hadoop2.7.tgz && \
    mv spark-2.4.5-bin-hadoop2.7 /opt/spark && \
    rm spark-2.4.5-bin-hadoop2.7.tgz

# Step 4: Set environment variables
ENV SPARK_HOME=/opt/spark
ENV PATH=$PATH:$SPARK_HOME/bin:$SPARK_HOME/sbin

# Step 6: Expose necessary ports
EXPOSE 8080 7077 22

# Step 7: Start SSH and set default command
CMD ["/bin/bash"]

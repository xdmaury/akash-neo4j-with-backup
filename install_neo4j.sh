#!/bin/bash

# This Bash script automates the installation of Java OpenJDK 17 and Neo4j Enterprise Edition. 
# It also configures Neo4j to accept network connections and sets the default database. 
# Make sure to modify the Neo4j configuration file path to match the location on your system.

# # Check if the Java installation was successful
java -version
if [ $? -ne 0 ]; then
    echo "Error: Java installation failed. Check if OpenJDK 17 is available in the system repositories."
    exit 1
fi

# Set the password of Neo4j you want to use
NEO4J_PASSWORD="root"

# Set the version of Neo4j you want to download
NEO4J_VERSION="enterprise-5.11.0"

# Set the name of the compressed file
NEO4J_FILE="neo4j-$NEO4J_VERSION-unix.tar.gz"

# Neo4j download URL
NEO4J_URL="https://neo4j.com/artifact.php?name=$NEO4J_FILE"

# Directory where Neo4j will be installed
INSTALL_DIR="/opt"

# Check if the installation directory exists, if not, create it
if [ ! -d "$INSTALL_DIR" ]; then
  mkdir -p $INSTALL_DIR
fi

# Download Neo4j
echo "Downloading Neo4j $NEO4J_VERSION..."
wget -O "$NEO4J_FILE" "$NEO4J_URL"

# Extract Neo4j to the installation directory
echo "Extracting Neo4j to$INSTALL_DIR..."
tar -xf "$NEO4J_FILE" -C "$INSTALL_DIR"

rm "$NEO4J_FILE"

# Rename the Neo4j directory for easier access
echo "Renaming the Neo4j directory..."
mv "$INSTALL_DIR/neo4j-$NEO4J_VERSION" "$INSTALL_DIR/neo4j"

# Set the JAVA_HOME environment variable
# export JAVA_HOME=/usr/lib/jvm/java-11-openjdk-amd64

# Change the default Neo4j password
echo "Changing the default Neo4j password..."
"$INSTALL_DIR/neo4j/bin/neo4j-admin" dbms set-initial-password "$NEO4J_PASSWORD"


# Use one of the following options to accept the commercial license agreement
echo "Setting the environment variable" 
NEO4J_ACCEPT_LICENSE_AGREEMENT=yes

"$INSTALL_DIR/neo4j/bin/neo4j-admin" server license --accept-commercial

# Run Neo4j
# echo "Starting Neo4j..."
# "$INSTALL_DIR/neo4j/bin/neo4j" start

# echo "Neo4j is running on http://localhost:7474"
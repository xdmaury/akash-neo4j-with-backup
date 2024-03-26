# Akash Neo4j with automated Backup 

This Docker image runs Neo4j on Akash for graph databases, alongside an Ubuntu instance with SFTP and automated backup.

## Software packages included in this neo4j-backup image:

* ssh: An OpenSSH server providing secure and encrypted remote access to the server.
* sftp: An SFTP (SSH File Transfer Protocol) server allowing secure file transfer between remote systems.
* neo4j: A graph database management system enabling connections to and manipulation of data in a graph format.
* cron: A task scheduler allowing automated execution of commands or scripts at specific times.

## Usage:

Ideal for setting up a Neo4j database on the Akash cloud platform. Users can easily configure this service to kickstart projects and have a graph database running, along with a backup instance running in parallel.

## Running the service on Akash

* Using the following SDL example, replace the environment variable `YOUR_PASSWORD_DB` with your Neo4j database access password and `YOUR_PASSWORD_UBUNTU` with your SSH/SFTP access password for the Neo4j backup service.
* Deploy the SDL on Akash and onfigure it according to the resources you wish to deploy.

Note: Do not change the name of the neo4j-db service, as the backup routine script uses this service name to connect to and backup the database. Additionally, backups are performed every day at 00:00. Backups are performed only for the 'neo4j' database.

````
---
version: "2.0"
services:
  neo4j-db:
    image: neo4j:5.11.0-enterprise
    expose:
      - port: 7474
        as: 7474
        to:
          - global: true
      - port: 7687
        as: 7687
        to:
          - global: true
      - port: 6362
        as: 6362
    env:
      - NEO4J_server_config_strict__validation_enabled=false
      - NEO4J_server_default__listen__address=0.0.0.0
      - NEO4J_server_bolt_enabled=true
      - NEO4J_server_bolt_tls__level=DISABLED
      - NEO4J_server_bolt_listen__address=0.0.0.0:7687
      - NEO4J_server_http_enabled=true
      - NEO4J_server_http_listen__address=0.0.0.0:7474
      - NEO4J_initial_dbms_default__database=neo4j
      - NEO4J_ACCEPT_LICENSE_AGREEMENT=yes
      - NEO4J_AUTH=neo4j/<YOUR_PASSWORD_DB>
      - NEO4J_server_backup_listen__address=0.0.0.0:6362
      - NEO4J_server_backup_enabled=true
    params:
      storage:
        data:
          mount: /var/lib/neo4j/data
          readOnly: false
  neo4j-backup:
    image: xdmaury/neo4j-backup:v1.1.0
    expose:
      - port: 22
        as: 22
        to:
          - global: true
    env:
      - ROOT_PASSWORD=<YOUR_PASSWORD_UBUNTU>
    params:
      storage:
        backup:
          mount: /opt/neo4j/backups
          readOnly: false
profiles:
  compute:
    neo4j-db:
      resources:
        cpu:
          units: 1
        memory:
          size: 2Gi
        storage:
          - size: 2Gi
          - name: data
            size: 2Gi
            attributes:
              persistent: true
              class: beta3
    neo4j-backup:
      resources:
        cpu:
          units: 1
        memory:
          size: 1Gi
        storage:
          - size: 2Gi
          - name: backup
            size: 2Gi
            attributes:
              persistent: true
              class: beta3
  placement:
    dcloud:
      pricing:
        neo4j-db:
          denom: uakt
          amount: 1000
        neo4j-backup:
          denom: uakt
          amount: 1000
deployment:
  neo4j-db:
    dcloud:
      profile: neo4j-db
      count: 1
  neo4j-backup:
    dcloud:
      profile: neo4j-backup
      count: 1

````
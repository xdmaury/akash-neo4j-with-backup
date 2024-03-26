FROM ubuntu:latest

# Install necessary packages
RUN apt-get update && \
    apt-get install -y openssh-server && \
    apt-get install -y cron && \
    apt-get install -y wget && \
    apt-get install -y openjdk-17-jre && \
    apt-get install -y sshpass && \
    rm -rf /var/lib/apt/lists/*

# Configure SFTP
RUN sed -i 's/#PermitRootLogin prohibit-password/PermitRootLogin yes/' /etc/ssh/sshd_config && \
    echo "PasswordAuthentication yes" >> /etc/ssh/sshd_config

RUN mkdir /run/sshd
EXPOSE 22

# INSTALL NEO4J
COPY install_neo4j.sh /install_neo4j.sh
RUN chmod +x /install_neo4j.sh
RUN /install_neo4j.sh

# Neo4j service backup
RUN mkdir -p /opt/neo4j/backups
RUN touch /opt/neo4j/backups/backups.log 
COPY backup_script.sh /backup_script.sh
RUN chmod +x /backup_script.sh
RUN (crontab -l ; echo "0 0 * * * /backup_script.sh >> /opt/neo4j/backups/backups.log 2>&1 ") | crontab

# Set root password, start cron and SSH service
CMD echo "root:$ROOT_PASSWORD" | chpasswd && cron && /usr/sbin/sshd -D

#!/bin/bash

HOST_TO_BACKUP=neo4j-db:6362

echo "Starting backup for $(echo $HOST_TO_BACKUP)"
BACKUP_DIR="/opt/neo4j/backups"
BACKUP_FILENAME="neo4j_backup_$(date +%Y%m%d_%H%M%S).tar.gz"
BACKUP_FILE="$BACKUP_DIR/$BACKUP_FILENAME"

# Perform database backup
/opt/neo4j/bin/neo4j-admin database backup --type=full --to-path=$BACKUP_DIR --from=$HOST_TO_BACKUP neo4j 

# Find the most recent .backup file
BACKUP=$(find $BACKUP_DIR -type f -name "*.backup" -printf '%T@ %p\n' | sort -k1nr | head -1 | cut -f2- -d' ')

# Compress the backup file
tar -czf $BACKUP_FILE $BACKUP

# Check if compression was successful
if [ $? -eq 0 ]; then
    # Remove the .backup file
    rm $BACKUP
    echo "Backup file compressed and .backup file removed"
else
    echo "Backup file compression failed, .backup file not removed"
fi

echo "Backup completed for $(echo $HOST_TO_BACKUP)"

# Keep only the last 7 days of files
find $BACKUP_DIR -type f -mtime +7 -delete

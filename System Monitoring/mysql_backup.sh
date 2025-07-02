#!/bin/bash

# Source Server Config
SRC_USER=""
SRC_PASSWORD=""
SRC_HOST=""
SRC_DB=""
# Backup & Transfer Settings
BACKUP_FILE="backup_$(date +%Y%m%d_%H%M%S).sql"
LOCAL_BACKUP_DIR="/tmp"
REMOTE_BACKUP_DIR="/tmp"

Step 1: Backup the source database
echo "Backing up $SRC_DB from $SRC_HOST..."
mysqldump -u "$SRC_USER" -p"$SRC_PASSWORD" --no-tablespaces --column-statistics=0 -h "$SRC_HOST" --databases "$SRC_DB" --set-gtid-purged=off | pv > "/tmp/$BACKUP_FILE"
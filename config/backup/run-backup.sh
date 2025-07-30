#!/bin/sh
set -e
BACKUP_DIR="/backup"
SOURCE_DIR="/data"
DATE=$(date +"%Y-%m-%d_%H-%M")
ARCHIVE_NAME="shelter-siem-$DATE.tar.gz"
ENCRYPTED_NAME="$ARCHIVE_NAME.gpg"
KEY_FILE="/config/backup-key.gpg"

if [ ! -f "$KEY_FILE" ]; then
  echo "Generating backup encryption key..."
  gpg --batch --gen-key <<EOF
Key-Type: default
Key-Length: 4096
Name-Real: ShelterBackup
Name-Email: shelter@local
Expire-Date: 0
%no-protection
%commit
EOF
  gpg --export ShelterBackup > "$KEY_FILE"
  echo "Backup key created at $KEY_FILE - COPY THIS TO USB AND STORE SAFELY."
fi

tar -czf "/tmp/$ARCHIVE_NAME" -C "$SOURCE_DIR" .
gpg --batch --yes --recipient ShelterBackup -o "$BACKUP_DIR/$ENCRYPTED_NAME" --encrypt "/tmp/$ARCHIVE_NAME"
rm "/tmp/$ARCHIVE_NAME"
echo "Backup completed: $BACKUP_DIR/$ENCRYPTED_NAME"

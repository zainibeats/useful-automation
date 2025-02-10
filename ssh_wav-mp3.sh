#!/bin/bash

# Configuration
SOURCE_DIR="/path/to/source/folder"  # Update this path to your music files location
DEST_SSH="user@192.661.0.10:/destination/folder"  # Update this path to your destination folder

# Check if source directory exists
if [ ! -d "$SOURCE_DIR" ]; then
    echo "Error: Source directory '$SOURCE_DIR' does not exist"
    exit 1
fi

echo "Copying music files from: $SOURCE_DIR"
echo "To remote destination: $DEST_SSH"
echo "(Skipping files that exist and are unchanged)"

# Run rsync with optimized settings
rsync \
    -r \
    -v \
    -u \
    -i \
    --progress \
    --include='*/' \
    --include='*.mp3' \
    --include='*.wav' \
    --exclude='*' \
    --compress \
    --compress-level=9 \
    --partial \
    --stats \
    "${SOURCE_DIR}/" \
    "${DEST_SSH}"

status=$?
if [ $status -eq 0 ]; then
    echo "Transfer complete!"
else
    echo "Error: Transfer failed with status $status"
    exit 1
fi 

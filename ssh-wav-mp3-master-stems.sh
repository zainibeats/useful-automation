#!/bin/bash

# Configuration
SOURCE_DIR="/path/to/source/folder"  # Update this path to your music files location
DEST_SSH="user@192.xxx.x.xx:/destination/folder"  # Update this path to the ip address + relative path of destination

# Check if source directory exists
if [ ! -d "$SOURCE_DIR" ]; then
    echo "Error: Source directory '$SOURCE_DIR' does not exist"
    exit 1
fi

echo "Copying music files from: $SOURCE_DIR"
echo "To remote destination: $DEST_SSH"
echo "(Skipping files that exist and are unchanged)"
echo "(Skipping stem/stems files unless they contain 'master')"

# Run rsync on mp3 and wav files only, but:
# If file has name stem(s), exclude from rsync except:
# If file has name master, include no matter what (include master track from trackouts / stems folders)

rsync \
    -r \
    -v \
    -u \
    -i \
    --progress \
    --include='*/' \
    --include='*[Mm]aster*[Ss][Tt][Ee][Mm][Ss]*.mp3' \
    --include='*[Mm]aster*[Ss][Tt][Ee][Mm]*.mp3' \
    --include='*[Mm]aster*[Ss][Tt][Ee][Mm][Ss]*.wav' \
    --include='*[Mm]aster*[Ss][Tt][Ee][Mm]*.wav' \
    --exclude='*[Ss][Tt][Ee][Mm][Ss]*.mp3' \
    --exclude='*[Ss][Tt][Ee][Mm]*.mp3' \
    --exclude='*[Ss][Tt][Ee][Mm][Ss]*.wav' \
    --exclude='*[Ss][Tt][Ee][Mm]*.wav' \
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

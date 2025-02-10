#!/bin/bash

# File containing the list of URLs
URL_FILE="/path/to/txt/file"

# Directory to save downloaded audio files
DOWNLOAD_DIR="/home/user/downloads"

# Create the download directory if it doesn't exist
mkdir -p "$DOWNLOAD_DIR"

# Read each URL from the file and download the audio
while IFS= read -r url; do
    yt-dlp -P "$DOWNLOAD_DIR" "$url"
done < "$URL_FILE"

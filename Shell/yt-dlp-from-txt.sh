#!/bin/bash

# yt-dlp-from-txt.sh
# Purpose: Download media files from URLs listed in a text file using yt-dlp

# Configuration variables
# Text file containing one URL per line
URL_FILE="/path/to/txt/file"

# Target directory for downloaded files
# Will be created if it doesn't exist
DOWNLOAD_DIR="/home/user/downloads"

# Ensure download directory exists before proceeding
# -p flag creates parent directories if needed
mkdir -p "$DOWNLOAD_DIR"

# Process each URL from the input file
# IFS= preserves leading/trailing whitespace
# -r prevents backslash escaping
while IFS= read -r url; do
    # Download media using yt-dlp
    # -P specifies output path
    yt-dlp -P "$DOWNLOAD_DIR" "$url"
done < "$URL_FILE"

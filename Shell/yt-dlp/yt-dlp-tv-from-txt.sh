#!/bin/bash

# yt-dlp-tv-from-txt.sh
# Purpose: Download media files from URLs listed in a text file using yt-dlp,
#          numbering episodes sequentially while starting from the next available number.

# Configuration variables
# Text file containing one URL per line
URL_FILE="/path/to/txt/file"

# Extract the base name from the URL file (without the .txt extension)
BASE_NAME=$(basename "$URL_FILE" .txt)

# Define the target directory for downloaded files using the base name
OUTPUT_DIR="/path/to/target/directory/$BASE_NAME"

# Ensure the output directory exists before proceeding
mkdir -p "$OUTPUT_DIR"

# Determine the next episode number
max=0
shopt -s nullglob
# Adjust the pattern if you use different extensions.
for f in "$OUTPUT_DIR/${BASE_NAME}_Episode_"*.*; do
    # Extract the number between "Episode_" and the next dot.
    num=$(echo "$f" | grep -oP 'Episode_(\d+)' | grep -oP '\d+')
    if [[ -n "$num" && "$num" -gt "$max" ]]; then
        max=$num
    fi
done
episode=$((max + 1))

# Process each URL from the input file
while IFS= read -r url; do
    # Format the episode number (e.g. 03, 04, ...)
    ep=$(printf "%02d" "$episode")
    
    # Download media using yt-dlp with the output filename template
    yt-dlp --downloader ffmpeg --hls-use-mpegts -o "$OUTPUT_DIR/${BASE_NAME}_Episode_${ep}.%(ext)s" "$url"
    # Increment the episode counter
    episode=$((episode + 1))
done < "$URL_FILE"

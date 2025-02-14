# Shell Scripts

This directory contains Bash shell scripts for media downloads and file transfers

## Scripts

### append-mp3.sh

Appends .mp3 extension to all files in a specified directory

#### Requirements
- Bash shell environment
- Write permissions in target directory

#### Usage
1. Update the target directory:
   ```bash
   TARGET_DIR="/path/to/your/folder"
   ```

2. Make the script executable:
   ```bash
   chmod +x append-mp3.sh
   ```

3. Run the script:
   ```bash
   ./append-mp3.sh
   ```

#### Features
- Processes all files in target directory
- Adds .mp3 extension to each file
- Skips directories and special files
- Simple error handling for directory validation

### remote_mount.sh

Mounts remote filesystem via SSHFS with Mullvad VPN's mullvad-exclude functionality

#### Requirements
- SSHFS installed
- Mullvad VPN with mullvad-exclude
- SSH access to remote server

#### Usage
1. Configure the connection variables:
   ```bash
   server="user@serverip"     # Your SSH username and server
   port="customport"          # Your SSH port (or 22 for default)
   ```

2. Make the script executable:
   ```bash
   chmod +x remote_mount.sh
   ```

3. Run the script:
   ```bash
   ./remote_mount.sh
   ```

#### Features
- Creates mount directory if not exists
- Handles custom SSH ports
- Maintains connection with keepalive settings
- Bypasses VPN for mount connection
- Verifies successful mounting

### yt-dlp-from-txt.sh

Downloads media from a list of URLs using yt-dlp

#### Requirements
- yt-dlp installed
- Bash shell environment

#### Usage
1. Update the script variables:
   ```bash
   URL_FILE="/path/to/txt/file"      # File containing URLs, one per line
   DOWNLOAD_DIR="/home/user/downloads"  # Directory to save downloads
   ```

2. Make the script executable:
   ```bash
   chmod +x yt-dlp-from-txt.sh
   ```

3. Run the script:
   ```bash
   ./yt-dlp-from-txt.sh
   ```

### ssh_wav-mp3.sh

Transfers WAV and MP3 files to a remote server using rsync over SSH

#### Requirements
- rsync
- SSH access to remote server
- Proper SSH configuration

#### Usage
1. Update the configuration variables:
   ```bash
   SOURCE_DIR="/path/to/source/folder"
   DEST_SSH="user@192.661.0.10:/destination/folder"
   ```

2. Make the script executable:
   ```bash
   chmod +x ssh_wav-mp3.sh
   ```

3. Run the script:
   ```bash
   ./ssh_wav-mp3.sh
   ```

#### Features
- Skips existing unchanged files
- Includes only WAV and MP3 files
- Shows transfer progress
- Provides transfer statistics

### ssh-wav-mp3-master-stems.sh

Advanced version of ssh_wav-mp3.sh that handles master tracks and stems intelligently.

#### Requirements
Same as ssh_wav-mp3.sh

#### Usage
1. Update the configuration variables:
   ```bash
   SOURCE_DIR="/path/to/source/folder"
   DEST_SSH="user@192.xxx.x.xx:/destination/folder"
   ```

2. Make the script executable:
   ```bash
   chmod +x ssh-wav-mp3-master-stems.sh
   ```

3. Run the script:
   ```bash
   ./ssh-wav-mp3-master-stems.sh
   ```

#### Features
- Transfers WAV and MP3 files
- Special handling for stem files:
  - Excludes files with "stem" or "stems" in the name
  - Includes files with "master" in the name, even if they're in stem folders
- Shows transfer progress and statistics
- Skips existing unchanged files

## Common Features
- All scripts include error handling
- Progress indicators where applicable
- Validation of source directories
- Status reporting 
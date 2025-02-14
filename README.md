# Personal Utility Scripts

A collection of utility scripts for various file operations, media downloads, and file transfers. This repository contains PowerShell, Batch, and Shell scripts to automate common tasks.

## Project Structure

- **Batch/** - Windows batch scripts for media processing
  - `resize_media.bat` - Lightweight image resizing script (supports GIF, PNG, JPG, JPEG)

- **PowerShell/** - Windows-specific utility scripts
  - `rename-files-from-list.ps1` - Batch rename files using a reference list

- **Shell/** - Bash shell scripts for various operations
  - `append-mp3.sh` - Append .mp3 extension to files in a directory
  - `remote_mount.sh` - Mount remote filesystem via SSHFS with VPN bypass
  - `yt-dlp-from-txt.sh` - Download media from URLs listed in a text file
  - `ssh_wav-mp3.sh` - Transfer audio files (WAV/MP3) to a remote server via SSH
  - `ssh-wav-mp3-master-stems.sh` - Transfer master audio files while handling stem files

## Requirements

### Batch Scripts
- Windows operating system
- ImageMagick installed and added to system PATH
- Read/Write permissions in target directories

### PowerShell Scripts
- Windows PowerShell or PowerShell Core
- Appropriate file system permissions

### Shell Scripts
- Bash shell environment
- Required tools:
  - `yt-dlp` for media downloads
  - `rsync` for file transfers
  - `sshfs` for remote mounting
  - SSH access and configuration for remote operations
  - Mullvad VPN (optional, for VPN bypass operations)

## Features

### Media Processing
- Basic image resizing with custom scale
- Support for common image formats
- Directory-based batch processing
- Interactive command-line interface

### File Management
- Batch file renaming
- Directory organization
- File transfer and synchronization
- Remote file operations
- Extension management

### Media Downloads
- Batch URL processing
- Audio file management
- Support for various media sources

### Remote Operations
- SSHFS mounting with VPN bypass
- Secure file transfers
- Remote directory synchronization

## Usage

Each script directory contains its own README with specific usage instructions and examples. Please refer to:
- [Batch Scripts Documentation](./Batch/README.md)
- [PowerShell Scripts Documentation](./PowerShell/README.md)
- [Shell Scripts Documentation](./Shell/README.md)

## Contributing

Feel free to submit issues and enhancement requests. Pull requests are welcome

## License

This project is licensed under the MIT License
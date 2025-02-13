# Useful Automation

A collection of utility scripts for various file operations, media downloads, and file transfers. This repository contains PowerShell, Batch, and Shell scripts to automate common tasks.

## Project Structure

- **Batch/** - Windows batch scripts for media processing
  - `resize_media.bat` - Versatile image resizing and processing script (supports GIF, PNG, JPG, WebP, etc.)

- **PowerShell/** - Windows-specific utility scripts
  - `rename-files-from-list.ps1` - Batch rename files using a reference list

- **Shell/** - Bash shell scripts for various operations
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
  - SSH access and configuration for remote transfers

## Features

### Media Processing
- Image resizing and format conversion
- Support for modern image formats (WebP, AVIF)
- Pixel art upscaling
- Photo optimization
- Animated GIF handling

### File Management
- Batch file renaming
- Directory organization
- File transfer and synchronization
- Remote file operations

### Media Downloads
- Batch URL processing
- Audio file management
- Support for various media sources

## Usage

Each script directory contains its own README with specific usage instructions and examples. Please refer to:
- [Batch Scripts Documentation](./Batch/README.md)
- [PowerShell Scripts Documentation](./PowerShell/README.md)
- [Shell Scripts Documentation](./Shell/README.md)

## Contributing

Feel free to submit issues and enhancement requests. Pull requests are welcome.

## License

This project is licensed under the MIT License.
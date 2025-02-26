# Batch Utility Scripts

This directory contains Windows Batch scripts for various file operations

## ez-release

A modular, cross-language release automation toolkit for Windows developers.

### Features
- **Semantic Versioning**: Automatically increment major, minor, or patch versions
- **Cross-Language Support**: Works with JavaScript/Node.js, Python, Rust, C#, Java, and Go
- **Modular Design**: Use only the components you need for your project
- **Build Optimization**: Language-specific optimizations for better build performance
- **GPG Signing**: Securely sign your releases with GPG
- **Release Packaging**: Create comprehensive release packages with documentation

### Main Components
- `release.bat` - Main script that orchestrates the entire release process
- `config.bat` - Central configuration for customizing the toolkit to your project
- `custom-build-steps.bat` - Add project-specific build steps
- `increment-version.bat` - Handle semantic version increments
- `update-version.bat` - Update version references in project files
- `optimize-build.bat` - Optimize your build environment
- `sign-and-package.bat` - Create signed release packages
- `template-processor.bat` - Process templates for release documentation

See the [ez-release README](./ez-release/README.md) for detailed usage instructions.

## Scripts

### resize_media.bat

A lightweight utility script for batch resizing images while preserving quality. Processes files recursively in the specified directory

#### Requirements
- Windows operating system
- ImageMagick installed and added to system PATH
- Read/Write permissions in the target directory

#### Usage

1. Run the script:
   ```batch
   resize_media.bat
   ```

2. Follow the prompts:
   - Enter target directory (or press Enter for current folder)
   - Specify resize percentage (e.g., 130 for 30% larger, 50 for half size)
   - Choose file type (gif/png/jpg) or 'all' for every supported format

#### Features
- Supports multiple image formats (GIF, PNG, JPG, JPEG)
- Recursive directory processing
- User-specified resize percentage
- Single or all file type processing
- Simple and straightforward interface

#### Notes
- Original files are modified in place; make backups before running
- Processes all matching files in target directory and subdirectories
- No default resize value to prevent accidental processing

#### Examples
```batch
# Double the size of all images:
Enter folder path: C:\My Pictures
Enter resize percentage: 200
Enter file type: all

# Halve the size of GIFs only:
Enter folder path: C:\Animations
Enter resize percentage: 50
Enter file type: gif

# Process current directory:
Enter folder path: .
Enter resize percentage: 75
Enter file type: png
``` 
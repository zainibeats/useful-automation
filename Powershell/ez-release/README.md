# Modular Release Script for PowerShell

This directory contains the modular release automation script `New-Release.ps1` designed to standardize the build and packaging process across different projects.

## Overview

The `New-Release.ps1` script automates:

1. Version detection from source files or Git tags
2. Building the application using a project-specific build script
3. Packaging artifacts with documentation into organized releases
4. Optional GPG signing for executables

It's designed to be flexible, allowing each project to define its own build and packaging requirements through a configuration file, while keeping the release process consistent.

## Getting Started

To use this script in your project:

1. Copy `New-Release.ps1` to your project root or a central location
2. Create a `release.config.ps1` file in your project root based on the `release.config.example.ps1` template
3. Depending on your project type, copy and customize the language-specific build scripts (see "Language-Specific Templates")
4. Customize the configuration to match your project's structure and requirements

## Configuration

The `release.config.ps1` file is a PowerShell script that returns a hashtable defining:

- Basic project information (name, structure)
- Version extraction method
- Build script details
- Artifact definitions
- Documentation files
- Signing information

See `release.config.example.ps1` for a fully commented example.

## Language-Specific Templates

This repository includes **generic example** build scripts for different types of projects. You should copy and customize these for your own project.

### Python Projects

For Python projects, see the files in the `Python/` directory:

- `Python/build.example.ps1` - PowerShell wrapper script for Python builds that interfaces with New-Release.ps1
- `Python/build_package.example.py` - Python script that handles PyInstaller packaging and NSIS installer creation

To use these templates:
1. Copy `Python/build.example.ps1` to your project root as `build.ps1`
2. Copy `Python/build_package.example.py` to your project root as `build_package.py`
3. Customize both files for your specific Python project
4. Update your `release.config.ps1` to point to these scripts

### Rust Components

For projects with Rust components, see the file in the `Rust/` directory:

- `Rust/build_rust.example.py` - Python script that builds a Rust library and handles cross-platform concerns

To use this template:
1. Copy `Rust/build_rust.example.py` to your project root as `build_rust.py`
2. Customize it for your specific Rust library
3. Call it from your main build script (e.g., from `build.ps1`)

## TrueFA-Py Concrete Example

In addition to the generic `*.example.*` files, this directory also contains the **specific, working configuration and build files** used for the [TrueFA-Py](https://github.com/zainibeats/truefa-py) project. These serve as a real-world example of how the templates can be adapted.

**Included TrueFA-Py Files:**
- `release.config.ps1`: The actual configuration used for TrueFA-Py.
- `Python/build.ps1`: The PowerShell build script for TrueFA-Py.
- `Python/build_package.py`: The Python packaging script for TrueFA-Py.
- `Rust/build_rust.py`: The Rust component build script for TrueFA-Py.

**Using the TrueFA-Py Example:**

If you want to build the `TrueFA-Py` project using these exact scripts:
1. Clone the `TrueFA-Py` repository.
2. Copy the following files from this (`ez-release`) directory into the root of your cloned `TrueFA-Py` repository:
   - `New-Release.ps1`
   - `release.config.ps1`
   - `Python/build.ps1` (copy to `truefa-py/build.ps1`)
   - `Python/build_package.py` (copy to `truefa-py/build_package.py`)
   - `Rust/build_rust.py` (copy to `truefa-py/build_rust.py`)
3. Open the copied `release.config.ps1` in the `TrueFA-Py` directory and update the `GpgKeyId` to your own GPG key if you plan to sign the release, or leave it empty to disable signing.
4. Ensure you have the necessary [Requirements](#requirements) installed (Python, PyInstaller, NSIS, Rust).
5. Run `.\New-Release.ps1` from the root of the `TrueFA-Py` directory.

This allows developers to easily test or replicate the build process for the `TrueFA-Py` project itself using this modular release system.

## Usage

### Basic Usage

Run from your project root (where `release.config.ps1` is located):

```powershell
.\New-Release.ps1
```

### Advanced Options

```powershell
# Use a custom config path
.\New-Release.ps1 -ConfigPath .\deploy\my-release-config.ps1

# Skip the build step (use existing artifacts)
.\New-Release.ps1 -NoBuild

# Skip GPG signing
.\New-Release.ps1 -NoSign

# Pass additional arguments to the build script
.\New-Release.ps1 -BuildArgs @{ NoConsole = $true; Verbose = $true }

# Pass -Clean switch to the build script
.\New-Release.ps1 -CleanBuild

# Specify a different project root directory
.\New-Release.ps1 -ProjectRoot .\src
```

## Requirements

- Windows PowerShell or PowerShell Core
- Appropriate file system permissions
- GPG installed and configured in PATH (for signing only)
- For Python projects: Python, PyInstaller, and NSIS (for installers)
- For Rust components: Rust toolchain (rustc, cargo)

## Docker-Compose-Like Experience

The script is designed to provide a seamless experience similar to docker-compose:

1. Place `New-Release.ps1` and `release.config.ps1` in your project root
2. Run `.\New-Release.ps1` without any parameters
3. The script will automatically:
   - Find the configuration file
   - Determine the project root
   - Execute the build process
   - Package artifacts
   - Generate a consistent release structure

## Tips

- The configuration file is evaluated as PowerShell code, so you can use variables and expressions
- All paths are relative to the project root directory
- Use `$ProjectName` in patterns to avoid repetition
- The script changes to the project root directory before executing any operations
- For language-specific configuration, check the example template files

## Examples

- **Generic Template:** `release.config.example.ps1`
- **Specific TrueFA-Py Config:** `release.config.ps1`
- See language-specific template directories (`Python/`, `Rust/`) for build script examples and the corresponding TrueFA-Py implementations.
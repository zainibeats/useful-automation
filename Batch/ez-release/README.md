# ez-release: Modular Release Automation Toolkit

A modular, cross-language release automation toolkit for Windows developers.

## Overview

ez-release is a collection of batch scripts that automate the release process for software projects. The toolkit handles version management, building, optimization, signing, and packaging of your application in a streamlined workflow.

## Features

- **Semantic Versioning**: Automatically increment major, minor, or patch versions
- **Cross-Language Support**: Works with JavaScript/Node.js, Python, Rust, C#, Java, and more
- **Modular Design**: Use only the components you need for your project
- **GPG Signing**: Securely sign your releases with GPG
- **Release Packaging**: Create comprehensive release packages with documentation

## Getting Started

1. Copy the `ez-release` directory to your project root
2. Configure the scripts for your project (see Configuration section)
3. Run `release.bat [major|minor|patch|none]` to create a release

## Configuration

### 1. Project Configuration

Edit the `config.bat` file to specify your project details:

```batch
@echo off
REM ===== PROJECT CONFIGURATION =====

REM Project Name (used in filenames and documentation)
set PROJECT_NAME=YourAppName

REM Project Description (used in readme)
set PROJECT_DESCRIPTION=Your app description

REM Developer Information
set DEVELOPER_NAME=Your Name
set DEVELOPER_EMAIL=email@example.com
set DEVELOPER_GITHUB=yourusername/yourrepo

REM GPG Key Information (for signing)
set GPG_KEY_ID=YOUR_GPG_KEY_ID

REM Version Control System (git, svn, none)
set VCS=git

REM ===== LANGUAGE-SPECIFIC CONFIGURATION =====
REM Uncomment the section for your primary language

REM === Node.js/JavaScript ===
set PROJECT_TYPE=nodejs
set BUILD_COMMAND=npm run build:prod
set TEST_COMMAND=npm test
set DEPENDENCY_COMMAND=npm install
set VERSION_FILE=package.json
set VERSION_PATTERN="version": "%OLD_VERSION%"
set VERSION_REPLACEMENT="version": "%NEW_VERSION%"

REM === Python ===
REM set PROJECT_TYPE=python
REM set BUILD_COMMAND=python setup.py build
REM set TEST_COMMAND=pytest
REM set DEPENDENCY_COMMAND=pip install -r requirements.txt
REM set VERSION_FILE=setup.py
REM set VERSION_PATTERN=version='%OLD_VERSION%'
REM set VERSION_REPLACEMENT=version='%NEW_VERSION%'

REM === Rust ===
REM set PROJECT_TYPE=rust
REM set BUILD_COMMAND=cargo build --release
REM set TEST_COMMAND=cargo test
REM set DEPENDENCY_COMMAND=cargo update
REM set VERSION_FILE=Cargo.toml
REM set VERSION_PATTERN=version = "%OLD_VERSION%"
REM set VERSION_REPLACEMENT=version = "%NEW_VERSION%"

REM === C# (.NET) ===
REM set PROJECT_TYPE=dotnet
REM set BUILD_COMMAND=dotnet build -c Release
REM set TEST_COMMAND=dotnet test
REM set DEPENDENCY_COMMAND=dotnet restore
REM set VERSION_FILE=Directory.Build.props
REM set VERSION_PATTERN=<Version>%OLD_VERSION%</Version>
REM set VERSION_REPLACEMENT=<Version>%NEW_VERSION%</Version>

REM === Java (Maven) ===
REM set PROJECT_TYPE=java
REM set BUILD_COMMAND=mvn package
REM set TEST_COMMAND=mvn test
REM set DEPENDENCY_COMMAND=mvn dependency:resolve
REM set VERSION_FILE=pom.xml
REM set VERSION_PATTERN=<version>%OLD_VERSION%</version>
REM set VERSION_REPLACEMENT=<version>%NEW_VERSION%</version>

REM === GO ===
REM set PROJECT_TYPE=go
REM set BUILD_COMMAND=go build -o bin/
REM set TEST_COMMAND=go test ./...
REM set DEPENDENCY_COMMAND=go mod tidy
REM set VERSION_FILE=version.go
REM set VERSION_PATTERN=const Version = "%OLD_VERSION%"
REM set VERSION_REPLACEMENT=const Version = "%NEW_VERSION%"

REM ===== OUTPUT CONFIGURATION =====
REM Uncomment the section for your preferred output format

REM === Installer + Portable ===
set OUTPUT_TYPE=installer_portable
set INSTALLER_NAME=%PROJECT_NAME%-Setup-%NEW_VERSION%.exe
set PORTABLE_NAME=%PROJECT_NAME%-Portable-%NEW_VERSION%.exe
set OUTPUT_DIR=build

REM === Single Executable ===
REM set OUTPUT_TYPE=single_executable
REM set EXECUTABLE_NAME=%PROJECT_NAME%-%NEW_VERSION%.exe
REM set OUTPUT_DIR=bin

REM === Package (ZIP) ===
REM set OUTPUT_TYPE=package
REM set PACKAGE_NAME=%PROJECT_NAME%-%NEW_VERSION%.zip
REM set OUTPUT_DIR=dist

REM === Library (JAR, DLL, etc.) ===
REM set OUTPUT_TYPE=library
REM set LIBRARY_NAME=%PROJECT_NAME%-%NEW_VERSION%.dll
REM set OUTPUT_DIR=lib
```

### 2. Custom Build Steps (Optional)

If your project needs custom build steps, edit the `custom-build-steps.bat` file:

```batch
@echo off
REM This file contains custom build steps for your project
REM It is called by release.bat between the standard build steps

echo Running custom build steps...

REM Add your custom build commands here
REM Examples:
REM call npm run build:docs
REM call python tools/generate_bindings.py
REM etc.

echo Custom build steps completed.
```

## Components

### Core Scripts

- `release.bat` - Main script that orchestrates the entire release process
- `config.bat` - Central configuration file for customizing the toolkit to your project
- `increment-version.bat` - Increments version based on semantic versioning
- `update-version.bat` - Updates version references across project files
- `optimize-build.bat` - Prepares environment for optimal build
- `sign-and-package.bat` - Signs and packages the release artifacts
- `custom-build-steps.bat` - Custom build steps for your project
- `template-processor.bat` - Processes templates for release documentation
- `version-management.bat` - Interactive tool for managing project versions
- `setup-ez-release.bat` - Helper script to copy this toolkit to other projects

## Usage Examples

### Setting Up in a New Project

```batch
setup-ez-release.bat
# Follow the prompts to copy the toolkit to your project
# Then customize config.bat for your specific project needs
```

### Using the Version Management Tool

```batch
version-management.bat
# Interactive menu for managing project versions
# Options to show current version, increment version, and more
```

### Creating a Release with Version Update

```batch
release.bat minor
# This will:
# 1. Increment the minor version number
# 2. Install dependencies
# 3. Run tests (if configured)
# 4. Build the project
# 5. Sign and package the release
```

### Creating a Release without Version Update

```batch
release.bat none
# This will create a release using the current version
```

### Only Incrementing the Version

```batch
increment-version.bat patch
# This will only increment the patch version
```

### Only Updating Version in Files

```batch
update-version.bat 2.0.0
# This will update all version references to 2.0.0
```

### Only Building and Packaging

```batch
# First, ensure your configuration is correct
call config.bat

# Then run specific scripts as needed
call optimize-build.bat
call custom-build-steps.bat
call sign-and-package.bat
```

## Extending for Other Languages

To add support for a language not included in the default configurations:

1. Edit `config.bat` and add a new section for your language
2. Define the appropriate commands and file patterns
3. Uncomment your language section and comment out others

## License

This project is released under the MIT License. See LICENSE file for details.
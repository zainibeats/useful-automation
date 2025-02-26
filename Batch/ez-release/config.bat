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

REM ===== ADDITIONAL OPTIONS =====

REM Set to 'true' to automatically commit version changes
set AUTO_COMMIT=false

REM Set to 'true' to automatically create a tag after release
set AUTO_TAG=false

REM Set to 'true' to enable GPG signing of release artifacts
set ENABLE_SIGNING=true

REM Set to 'true' to run tests before building
set RUN_TESTS=true

REM Default release package name
set RELEASE_PACKAGE=%PROJECT_NAME%-%NEW_VERSION%-Release.zip

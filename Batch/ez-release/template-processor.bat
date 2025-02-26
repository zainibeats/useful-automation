@echo off
setlocal enabledelayedexpansion

REM Template processor for ez-release
REM This script populates template variables in release-readme.txt

REM Load configuration
if not exist config.bat (
    echo ERROR: config.bat not found. Please create it first.
    echo See README.md for configuration instructions.
    exit /b 1
)
call config.bat

echo Processing templates...

REM Check if we have a template to process
if not exist release-readme.txt (
    echo ERROR: release-readme.txt template not found.
    exit /b 1
)

REM Create a temporary file for processing
copy release-readme.txt release-readme.tmp

REM Replace project variables
powershell -Command "(Get-Content release-readme.tmp) -replace '%%PROJECT_NAME%%', '%PROJECT_NAME%' | Set-Content release-readme.tmp2"
powershell -Command "(Get-Content release-readme.tmp2) -replace '%%PROJECT_DESCRIPTION%%', '%PROJECT_DESCRIPTION%' | Set-Content release-readme.tmp"
powershell -Command "(Get-Content release-readme.tmp) -replace '%%NEW_VERSION%%', '%NEW_VERSION%' | Set-Content release-readme.tmp2"
powershell -Command "(Get-Content release-readme.tmp2) -replace '%%DEVELOPER_GITHUB%%', '%DEVELOPER_GITHUB%' | Set-Content release-readme.tmp"
powershell -Command "(Get-Content release-readme.tmp) -replace '%%DEVELOPER_EMAIL%%', '%DEVELOPER_EMAIL%' | Set-Content release-readme.tmp2"

REM Process installer files based on output type
set INSTALLER_FILES_TEXT=

if "%OUTPUT_TYPE%"=="installer_portable" (
    set INSTALLER_FILES_TEXT=- `%INSTALLER_NAME%` - Installer version^

- `%PORTABLE_NAME%` - Portable version^

- `VERIFY.txt` with detailed verification instructions
) else if "%OUTPUT_TYPE%"=="single_executable" (
    set INSTALLER_FILES_TEXT=- `%EXECUTABLE_NAME%` - Application executable^

- `VERIFY.txt` with detailed verification instructions
) else if "%OUTPUT_TYPE%"=="package" (
    set INSTALLER_FILES_TEXT=- `%PACKAGE_NAME%` - Application package^

- `VERIFY.txt` with detailed verification instructions
) else if "%OUTPUT_TYPE%"=="library" (
    set INSTALLER_FILES_TEXT=- `%LIBRARY_NAME%` - Library file^

- `VERIFY.txt` with detailed verification instructions
)

powershell -Command "(Get-Content release-readme.tmp2) -replace '%%INSTALLER_FILES%%', '%INSTALLER_FILES_TEXT%' | Set-Content release-readme.tmp"

REM Process installation instructions based on output type
set INSTALLATION_INSTRUCTIONS_TEXT=

if "%OUTPUT_TYPE%"=="installer_portable" (
    set INSTALLATION_INSTRUCTIONS_TEXT=Run `%INSTALLER_NAME%` and follow the installation wizard. This will:^

- Install %PROJECT_NAME% on your computer^

- Create desktop and start menu shortcuts^

- Allow uninstallation through Windows Control Panel^

^

Alternatively, you can use the portable version `%PORTABLE_NAME%` which requires no installation.
) else if "%OUTPUT_TYPE%"=="single_executable" (
    set INSTALLATION_INSTRUCTIONS_TEXT=No installation required. Simply run `%EXECUTABLE_NAME%` to start the application.
) else if "%OUTPUT_TYPE%"=="package" (
    set INSTALLATION_INSTRUCTIONS_TEXT=Extract `%PACKAGE_NAME%` to a directory of your choice and run the application.
) else if "%OUTPUT_TYPE%"=="library" (
    set INSTALLATION_INSTRUCTIONS_TEXT=Include `%LIBRARY_NAME%` in your project according to your development environment requirements.
)

powershell -Command "(Get-Content release-readme.tmp) -replace '%%INSTALLATION_INSTRUCTIONS%%', '%INSTALLATION_INSTRUCTIONS_TEXT%' | Set-Content release-readme.tmp2"

REM Set default placeholders for other sections if not defined
if not defined GETTING_STARTED (
    set GETTING_STARTED=1. Launch %PROJECT_NAME%^

2. [Add specific getting started instructions here]
)

if not defined SYSTEM_REQUIREMENTS (
    set SYSTEM_REQUIREMENTS=- Windows 10 or later^

- [Add specific system requirements here]
)

if not defined RELEASE_NOTES (
    set RELEASE_NOTES=- Version %NEW_VERSION% release^

- [Add specific release notes here]
)

REM Replace remaining placeholders
powershell -Command "(Get-Content release-readme.tmp2) -replace '%%GETTING_STARTED%%', '%GETTING_STARTED%' | Set-Content release-readme.tmp"
powershell -Command "(Get-Content release-readme.tmp) -replace '%%SYSTEM_REQUIREMENTS%%', '%SYSTEM_REQUIREMENTS%' | Set-Content release-readme.tmp2"
powershell -Command "(Get-Content release-readme.tmp2) -replace '%%RELEASE_NOTES%%', '%RELEASE_NOTES%' | Set-Content release-readme.txt"

REM Clean up temporary files
del release-readme.tmp
del release-readme.tmp2

echo Template processing complete. The release-readme.txt file has been updated.

endlocal

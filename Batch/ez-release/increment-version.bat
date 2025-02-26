@echo off
setlocal enabledelayedexpansion

REM Check if version type parameter is provided
if "%~1"=="" (
    echo Usage: increment-version.bat [major|minor|patch]
    echo Example: increment-version.bat patch
    exit /b 1
)

REM Load configuration
if not exist config.bat (
    echo ERROR: config.bat not found. Please create it first.
    echo See README.md for configuration instructions.
    exit /b 1
)
call config.bat

set VERSION_TYPE=%~1
set VERSION_TYPE=%VERSION_TYPE: =%

if /i not "%VERSION_TYPE%"=="major" (
    if /i not "%VERSION_TYPE%"=="minor" (
        if /i not "%VERSION_TYPE%"=="patch" (
            echo Invalid version type. Use 'major', 'minor', or 'patch'.
            exit /b 1
        )
    )
)

REM Get current version from the configured version file
echo Detecting current version from %VERSION_FILE%...
if not exist "%VERSION_FILE%" (
    echo ERROR: Version file "%VERSION_FILE%" not found.
    echo Please check the VERSION_FILE setting in config.bat
    exit /b 1
)

REM Extract version according to project type
set CURRENT_VERSION=unknown

if "%PROJECT_TYPE%"=="nodejs" (
    for /f "tokens=2 delims=:, " %%a in ('findstr "version" %VERSION_FILE%') do (
        set CURRENT_VERSION=%%a
        set CURRENT_VERSION=!CURRENT_VERSION:"=!
        goto :VersionFound
    )
) else if "%PROJECT_TYPE%"=="python" (
    for /f "tokens=2 delims=''" %%a in ('findstr "version=" %VERSION_FILE%') do (
        set CURRENT_VERSION=%%a
        goto :VersionFound
    )
) else if "%PROJECT_TYPE%"=="rust" (
    for /f "tokens=3 delims= " %%a in ('findstr "version =" %VERSION_FILE%') do (
        set CURRENT_VERSION=%%a
        set CURRENT_VERSION=!CURRENT_VERSION:"=!
        goto :VersionFound
    )
) else if "%PROJECT_TYPE%"=="dotnet" (
    for /f "tokens=2 delims=><" %%a in ('findstr "<Version>" %VERSION_FILE%') do (
        set CURRENT_VERSION=%%a
        goto :VersionFound
    )
) else if "%PROJECT_TYPE%"=="java" (
    for /f "tokens=2 delims=><" %%a in ('findstr "<version>" %VERSION_FILE%') do (
        set CURRENT_VERSION=%%a
        goto :VersionFound
    )
) else if "%PROJECT_TYPE%"=="go" (
    for /f "tokens=4 delims= " %%a in ('findstr "const Version =" %VERSION_FILE%') do (
        set CURRENT_VERSION=%%a
        set CURRENT_VERSION=!CURRENT_VERSION:"=!
        goto :VersionFound
    )
) else (
    echo Using custom project type. Attempting generic version detection...
    for /f "tokens=1 delims=" %%a in ('type %VERSION_FILE% ^| findstr /C:"%OLD_VERSION%"') do (
        set CURRENT_VERSION=%OLD_VERSION%
        goto :VersionFound
    )
)

:VersionFound

if "%CURRENT_VERSION%"=="unknown" (
    echo ERROR: Could not detect current version from %VERSION_FILE%
    exit /b 1
)

REM Parse the version components
for /f "tokens=1,2,3 delims=." %%a in ("%CURRENT_VERSION%") do (
    set MAJOR=%%a
    set MINOR=%%b
    set PATCH=%%c
)

REM Increment the appropriate component
if /i "%VERSION_TYPE%"=="major" (
    set /a MAJOR+=1
    set MINOR=0
    set PATCH=0
) else if /i "%VERSION_TYPE%"=="minor" (
    set /a MINOR+=1
    set PATCH=0
) else if /i "%VERSION_TYPE%"=="patch" (
    set /a PATCH+=1
)

REM Build the new version string
set NEW_VERSION=%MAJOR%.%MINOR%.%PATCH%

echo Incrementing %VERSION_TYPE% version
echo Current version: %CURRENT_VERSION%
echo New version: %NEW_VERSION%
echo.

REM Call the update-version script with the new version
call update-version.bat %NEW_VERSION%

endlocal
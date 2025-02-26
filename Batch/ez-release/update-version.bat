@echo off
setlocal enabledelayedexpansion

REM Check if version parameter is provided
if "%~1"=="" (
    echo Usage: update-version.bat [new_version]
    echo Example: update-version.bat 1.0.1
    exit /b 1
)

REM Load configuration
if not exist config.bat (
    echo ERROR: config.bat not found. Please create it first.
    echo See README.md for configuration instructions.
    exit /b 1
)
call config.bat

set NEW_VERSION=%~1

REM Get current version from the configured version file
echo Detecting current version from %VERSION_FILE%...
if not exist "%VERSION_FILE%" (
    echo ERROR: Version file "%VERSION_FILE%" not found.
    echo Please check the VERSION_FILE setting in config.bat
    exit /b 1
)

REM Extract version according to project type
set OLD_VERSION=unknown

if "%PROJECT_TYPE%"=="nodejs" (
    for /f "tokens=2 delims=:, " %%a in ('findstr "version" %VERSION_FILE%') do (
        set OLD_VERSION=%%a
        set OLD_VERSION=!OLD_VERSION:"=!
        goto :VersionFound
    )
) else if "%PROJECT_TYPE%"=="python" (
    for /f "tokens=2 delims=''" %%a in ('findstr "version=" %VERSION_FILE%') do (
        set OLD_VERSION=%%a
        goto :VersionFound
    )
) else if "%PROJECT_TYPE%"=="rust" (
    for /f "tokens=3 delims= " %%a in ('findstr "version =" %VERSION_FILE%') do (
        set OLD_VERSION=%%a
        set OLD_VERSION=!OLD_VERSION:"=!
        goto :VersionFound
    )
) else if "%PROJECT_TYPE%"=="dotnet" (
    for /f "tokens=2 delims=><" %%a in ('findstr "<Version>" %VERSION_FILE%') do (
        set OLD_VERSION=%%a
        goto :VersionFound
    )
) else if "%PROJECT_TYPE%"=="java" (
    for /f "tokens=2 delims=><" %%a in ('findstr "<version>" %VERSION_FILE%') do (
        set OLD_VERSION=%%a
        goto :VersionFound
    )
) else if "%PROJECT_TYPE%"=="go" (
    for /f "tokens=4 delims= " %%a in ('findstr "const Version =" %VERSION_FILE%') do (
        set OLD_VERSION=%%a
        set OLD_VERSION=!OLD_VERSION:"=!
        goto :VersionFound
    )
)
:VersionFound

if "%OLD_VERSION%"=="unknown" (
    echo ERROR: Could not detect current version from %VERSION_FILE%
    exit /b 1
)

echo ===== %PROJECT_NAME% Version Update Script =====
echo Current version: %OLD_VERSION%
echo New version: %NEW_VERSION%
echo.

REM Update the version file according to project type
echo Updating %VERSION_FILE%...

if defined VERSION_PATTERN (
    if defined VERSION_REPLACEMENT (
        REM Replace using configured patterns
        set SEARCH_PATTERN=%VERSION_PATTERN%
        set REPLACE_TEXT=%VERSION_REPLACEMENT%
        
        REM Replace OLD_VERSION and NEW_VERSION in the patterns
        set SEARCH_PATTERN=!SEARCH_PATTERN:%%OLD_VERSION%%=%OLD_VERSION%!
        set REPLACE_TEXT=!REPLACE_TEXT:%%NEW_VERSION%%=%NEW_VERSION%!
        
        powershell -Command "(Get-Content '%VERSION_FILE%') -replace '!SEARCH_PATTERN!', '!REPLACE_TEXT!' | Set-Content '%VERSION_FILE%'"
    ) else (
        echo ERROR: VERSION_REPLACEMENT not defined in config.bat
        exit /b 1
    )
) else (
    echo ERROR: VERSION_PATTERN not defined in config.bat
    exit /b 1
)

REM Update file names in sign-and-package.bat if it exists
if exist sign-and-package.bat (
    echo Updating sign-and-package.bat...
    
    REM Update based on output type
    if "%OUTPUT_TYPE%"=="installer_portable" (
        REM Update installer references
        powershell -Command "(Get-Content sign-and-package.bat) -replace '%PROJECT_NAME%-Setup-%OLD_VERSION%.exe', '%PROJECT_NAME%-Setup-%NEW_VERSION%.exe' | Set-Content sign-and-package.bat.tmp"
        powershell -Command "(Get-Content sign-and-package.bat.tmp) -replace '%PROJECT_NAME%-Portable-%OLD_VERSION%.exe', '%PROJECT_NAME%-Portable-%NEW_VERSION%.exe' | Set-Content sign-and-package.bat.tmp2"
        move /Y sign-and-package.bat.tmp2 sign-and-package.bat
        del sign-and-package.bat.tmp
    ) else if "%OUTPUT_TYPE%"=="single_executable" (
        REM Update single executable references
        powershell -Command "(Get-Content sign-and-package.bat) -replace '%PROJECT_NAME%-%OLD_VERSION%.exe', '%PROJECT_NAME%-%NEW_VERSION%.exe' | Set-Content sign-and-package.bat.tmp"
        move /Y sign-and-package.bat.tmp sign-and-package.bat
    ) else if "%OUTPUT_TYPE%"=="package" (
        REM Update package references
        powershell -Command "(Get-Content sign-and-package.bat) -replace '%PROJECT_NAME%-%OLD_VERSION%.zip', '%PROJECT_NAME%-%NEW_VERSION%.zip' | Set-Content sign-and-package.bat.tmp"
        move /Y sign-and-package.bat.tmp sign-and-package.bat
    ) else if "%OUTPUT_TYPE%"=="library" (
        REM Update library references
        powershell -Command "(Get-Content sign-and-package.bat) -replace '%PROJECT_NAME%-%OLD_VERSION%.dll', '%PROJECT_NAME%-%NEW_VERSION%.dll' | Set-Content sign-and-package.bat.tmp"
        move /Y sign-and-package.bat.tmp sign-and-package.bat
    )
    
    REM Update release package name
    powershell -Command "(Get-Content sign-and-package.bat) -replace '%PROJECT_NAME%-%OLD_VERSION%-Release.zip', '%PROJECT_NAME%-%NEW_VERSION%-Release.zip' | Set-Content sign-and-package.bat.tmp"
    move /Y sign-and-package.bat.tmp sign-and-package.bat
    
    REM Update verification instructions
    powershell -Command "(Get-Content sign-and-package.bat) -replace '%PROJECT_NAME%-%OLD_VERSION%', '%PROJECT_NAME%-%NEW_VERSION%' | Set-Content sign-and-package.bat.tmp"
    move /Y sign-and-package.bat.tmp sign-and-package.bat
)

REM Update release-readme.txt if it exists
if exist release-readme.txt (
    echo Updating release-readme.txt...
    powershell -Command "(Get-Content release-readme.txt) -replace '%PROJECT_NAME% %OLD_VERSION%', '%PROJECT_NAME% %NEW_VERSION%' | Set-Content release-readme.txt.tmp"
    powershell -Command "(Get-Content release-readme.txt.tmp) -replace '%PROJECT_NAME%-%OLD_VERSION%', '%PROJECT_NAME%-%NEW_VERSION%' | Set-Content release-readme.txt"
    del release-readme.txt.tmp
)

echo.
echo ===== Version updated successfully! =====
echo.
echo Updated files:
echo - %VERSION_FILE%
if exist sign-and-package.bat echo - sign-and-package.bat
if exist release-readme.txt echo - release-readme.txt
echo.

REM Language-specific post-update message
if "%PROJECT_TYPE%"=="nodejs" (
    echo NOTE: Package lock will be updated automatically when you run npm install
    echo.
    echo Don't forget to:
    echo 1. Run npm install to update package-lock.json
) else if "%PROJECT_TYPE%"=="python" (
    echo Don't forget to:
    echo 1. Update any requirements.txt or setup.cfg if needed
) else if "%PROJECT_TYPE%"=="rust" (
    echo NOTE: Cargo.lock will be updated automatically when you run cargo build
    echo.
    echo Don't forget to:
    echo 1. Run cargo build to update Cargo.lock
) else if "%PROJECT_TYPE%"=="dotnet" (
    echo Don't forget to:
    echo 1. Update any .csproj files if needed
) else if "%PROJECT_TYPE%"=="java" (
    echo Don't forget to:
    echo 1. Update any dependencies or sub-modules if needed
) else if "%PROJECT_TYPE%"=="go" (
    echo Don't forget to:
    echo 1. Update go.mod and go.sum if needed
)

echo 2. Commit the changes to your version control system
echo 3. Build the application with the new version

endlocal
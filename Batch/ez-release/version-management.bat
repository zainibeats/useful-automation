@echo off
setlocal enabledelayedexpansion

echo ===== Version Management Tool =====
echo This tool helps manage your project version numbers.

REM Load configuration
if not exist config.bat (
    echo ERROR: config.bat not found. Please create it first.
    echo See README.md for configuration instructions.
    exit /b 1
)
call config.bat

:menu
echo.
echo Current project: %PROJECT_NAME%
echo.
echo VERSION MANAGEMENT MENU
echo =============================================
echo 1. Show current version
echo 2. Increment MAJOR version (x.0.0)
echo 3. Increment MINOR version (0.x.0)
echo 4. Increment PATCH version (0.0.x)
echo 5. Set custom version
echo 6. Update version in all files
echo =============================================
echo 0. Exit
echo.

set /p CHOICE=Enter your choice (0-6): 

if "%CHOICE%"=="0" goto end
if "%CHOICE%"=="1" goto show_version
if "%CHOICE%"=="2" goto increment_major
if "%CHOICE%"=="3" goto increment_minor
if "%CHOICE%"=="4" goto increment_patch
if "%CHOICE%"=="5" goto custom_version
if "%CHOICE%"=="6" goto update_version
echo Invalid choice. Please try again.
goto menu

:show_version
echo.
echo Checking current version...
call increment-version.bat show
goto menu

:increment_major
echo.
echo Incrementing MAJOR version...
call increment-version.bat major
goto menu

:increment_minor
echo.
echo Incrementing MINOR version...
call increment-version.bat minor
goto menu

:increment_patch
echo.
echo Incrementing PATCH version...
call increment-version.bat patch
goto menu

:custom_version
echo.
echo Setting custom version...
set /p CUSTOM_VERSION=Enter the new version (format: x.y.z): 
call update-version.bat %CUSTOM_VERSION%
goto menu

:update_version
echo.
echo Updating version in all project files...
call update-version.bat
goto menu

:end
echo.
echo Exiting Version Management Tool...
endlocal

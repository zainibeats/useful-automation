@echo off
setlocal enabledelayedexpansion

echo ===== ez-release: Complete Release Process =====
echo.

REM Check if version type parameter is provided
if "%~1"=="" (
    echo Usage: release.bat [major|minor|patch|none]
    echo Examples:
    echo   release.bat patch    (Increment patch version and build)
    echo   release.bat minor    (Increment minor version and build)
    echo   release.bat major    (Increment major version and build)
    echo   release.bat none     (Use current version and build)
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
            if /i not "%VERSION_TYPE%"=="none" (
                echo Invalid version type. Use 'major', 'minor', 'patch', or 'none'.
                exit /b 1
            )
        )
    )
)

REM Get current version before any changes
echo Detecting current version...
if not exist "%VERSION_FILE%" (
    echo ERROR: Version file "%VERSION_FILE%" not found.
    echo Please check the VERSION_FILE setting in config.bat
    exit /b 1
)

REM Initialize version variables
set CURRENT_VERSION=unknown
set NEW_VERSION=unknown

REM Extract version according to project type
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

echo Current version detected: %CURRENT_VERSION%

REM Increment version if requested
if /i not "%VERSION_TYPE%"=="none" (
    echo Step 1: Updating version...
    call increment-version.bat %VERSION_TYPE%
    echo.
) else (
    echo Step 1: Skipping version update, using current version %CURRENT_VERSION%
    set NEW_VERSION=%CURRENT_VERSION%
    echo.
)

REM Get updated version after increment
if "%PROJECT_TYPE%"=="nodejs" (
    for /f "tokens=2 delims=:, " %%a in ('findstr "version" %VERSION_FILE%') do (
        set NEW_VERSION=%%a
        set NEW_VERSION=!NEW_VERSION:"=!
        goto :NewVersionFound
    )
) else if "%PROJECT_TYPE%"=="python" (
    for /f "tokens=2 delims=''" %%a in ('findstr "version=" %VERSION_FILE%') do (
        set NEW_VERSION=%%a
        goto :NewVersionFound
    )
) else if "%PROJECT_TYPE%"=="rust" (
    for /f "tokens=3 delims= " %%a in ('findstr "version =" %VERSION_FILE%') do (
        set NEW_VERSION=%%a
        set NEW_VERSION=!NEW_VERSION:"=!
        goto :NewVersionFound
    )
) else if "%PROJECT_TYPE%"=="dotnet" (
    for /f "tokens=2 delims=><" %%a in ('findstr "<Version>" %VERSION_FILE%') do (
        set NEW_VERSION=%%a
        goto :NewVersionFound
    )
) else if "%PROJECT_TYPE%"=="java" (
    for /f "tokens=2 delims=><" %%a in ('findstr "<version>" %VERSION_FILE%') do (
        set NEW_VERSION=%%a
        goto :NewVersionFound
    )
) else if "%PROJECT_TYPE%"=="go" (
    for /f "tokens=4 delims= " %%a in ('findstr "const Version =" %VERSION_FILE%') do (
        set NEW_VERSION=%%a
        set NEW_VERSION=!NEW_VERSION:"=!
        goto :NewVersionFound
    )
) else (
    set NEW_VERSION=%CURRENT_VERSION%
    if /i not "%VERSION_TYPE%"=="none" (
        REM This shouldn't happen if increment-version.bat worked correctly
        echo WARNING: Unable to detect new version automatically.
        echo Please check if the version was updated correctly in %VERSION_FILE%.
    )
    goto :NewVersionFound
)
:NewVersionFound

echo New version: %NEW_VERSION%

REM Step 2: Installing dependencies
echo Step 2: Installing dependencies...
if exist "%DEPENDENCY_COMMAND%" (
    call %DEPENDENCY_COMMAND%
) else (
    echo Skipping dependency installation. No dependency command configured.
)
echo.

REM Step 3: Run tests if enabled
if /i "%RUN_TESTS%"=="true" (
    echo Step 3: Running tests...
    if exist "%TEST_COMMAND%" (
        call %TEST_COMMAND%
        if !ERRORLEVEL! neq 0 (
            echo Tests failed. Aborting release.
            exit /b !ERRORLEVEL!
        )
    ) else (
        echo Skipping tests. No test command configured.
    )
    echo.
) else (
    echo Step 3: Skipping tests (disabled in config)
    echo.
)

REM Step 4: Run optimize build if it exists
if exist optimize-build.bat (
    echo Step 4: Optimizing build environment...
    call optimize-build.bat
    echo.
) else (
    echo Step 4: Skipping build optimization (optimize-build.bat not found)
    echo.
)

REM Step 5: Building application
echo Step 5: Building application...
if exist "%BUILD_COMMAND%" (
    call %BUILD_COMMAND%
    if !ERRORLEVEL! neq 0 (
        echo Build failed. Aborting release.
        exit /b !ERRORLEVEL!
    )
) else (
    echo ERROR: Build command not found or not configured.
    echo Please check the BUILD_COMMAND setting in config.bat
    exit /b 1
)
echo.

REM Step 6: Run custom build steps if the file exists
if exist custom-build-steps.bat (
    echo Step 6: Running custom build steps...
    call custom-build-steps.bat
    echo.
) else (
    echo Step 6: No custom build steps found (custom-build-steps.bat not present)
    echo.
)

REM Step 7: Signing and packaging
echo Step 7: Signing and packaging...
if exist sign-and-package.bat (
    call sign-and-package.bat
    echo.
) else (
    echo WARNING: sign-and-package.bat not found, skipping this step.
    echo.
)

REM Step 8: Version control operations (commit & tag if configured)
if /i "%AUTO_COMMIT%"=="true" (
    echo Step 8: Committing version changes...
    if /i "%VCS%"=="git" (
        git add .
        git commit -m "Release version %NEW_VERSION%"
        
        if /i "%AUTO_TAG%"=="true" (
            git tag -a v%NEW_VERSION% -m "Version %NEW_VERSION%"
            echo Created tag v%NEW_VERSION%
        )
    ) else if /i "%VCS%"=="svn" (
        svn commit -m "Release version %NEW_VERSION%"
    ) else (
        echo Skipping auto-commit (VCS not configured or not supported)
    )
) else (
    echo Step 8: Skipping version control operations (disabled in config)
)
echo.

echo ===== Release %NEW_VERSION% completed successfully! =====
echo.
echo Release package: %RELEASE_PACKAGE%
echo.
echo Don't forget to:
echo 1. Test the release package thoroughly
echo 2. If not auto-committed, commit the changes to your version control system
echo 3. If not auto-tagged, tag this release in your version control system
echo 4. Upload and distribute your release

endlocal
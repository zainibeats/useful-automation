@echo off
setlocal enabledelayedexpansion

echo ===== Build Optimization Script =====
echo Optimizing build environment for maximum performance...

REM Load configuration
if not exist config.bat (
    echo ERROR: config.bat not found. Please create it first.
    echo See README.md for configuration instructions.
    exit /b 1
)
call config.bat

REM Clear temp files
echo Clearing temporary files...
del /q /s %TEMP%\*.* >nul 2>&1

REM Project type specific optimizations
if "%PROJECT_TYPE%"=="nodejs" (
    REM Node.js optimizations
    echo Clearing NPM cache...
    call npm cache clean --force >nul 2>&1
    
    REM Kill any possible running instances that might lock files
    echo Checking for running instances of %PROJECT_NAME%...
    taskkill /f /im %PROJECT_NAME%.exe >nul 2>&1
    
    REM Clear build directories
    echo Cleaning Node.js build artifacts...
    if exist dist rmdir /s /q dist >nul 2>&1
    if exist dist-electron rmdir /s /q dist-electron >nul 2>&1
    if exist build rmdir /s /q build >nul 2>&1
    if exist node_modules\\.cache rmdir /s /q node_modules\\.cache >nul 2>&1
    
    REM Set environment variables for better build performance
    echo Setting Node.js optimization environment variables...
    set NODE_ENV=production
    set NODE_OPTIONS=--max-old-space-size=4096

) else if "%PROJECT_TYPE%"=="python" (
    REM Python optimizations
    echo Clearing Python cache files...
    for /d /r . %%d in (__pycache__) do @if exist "%%d" rmdir /s /q "%%d" >nul 2>&1
    for /r . %%f in (*.pyc) do @if exist "%%f" del "%%f" >nul 2>&1
    
    REM Clean build directories
    if exist build rmdir /s /q build >nul 2>&1
    if exist dist rmdir /s /q dist >nul 2>&1
    if exist *.egg-info rmdir /s /q *.egg-info >nul 2>&1
    
    REM Set environment variables for optimized Python builds
    echo Setting Python optimization environment variables...
    set PYTHONOPTIMIZE=2
    set PYTHONHASHSEED=0

) else if "%PROJECT_TYPE%"=="rust" (
    REM Rust optimizations
    echo Optimizing Rust build process...
    
    REM Clean Cargo cache and target directories
    if exist target rmdir /s /q target >nul 2>&1
    
    REM Set Rust performance flags
    echo Setting Rust optimization flags...
    set RUSTFLAGS=-C opt-level=3 -C target-cpu=native -C codegen-units=1 -C lto=fat

) else if "%PROJECT_TYPE%"=="dotnet" (
    REM .NET optimizations
    echo Optimizing .NET build process...
    
    REM Clean build artifacts
    if exist bin rmdir /s /q bin >nul 2>&1
    if exist obj rmdir /s /q obj >nul 2>&1
    
    REM Set .NET build variables
    set DOTNET_CLI_TELEMETRY_OPTOUT=1
    set DOTNET_SKIP_FIRST_TIME_EXPERIENCE=1

) else if "%PROJECT_TYPE%"=="java" (
    REM Java optimizations
    echo Optimizing Java build process...
    
    REM Clean Maven/Gradle artifacts
    if exist target rmdir /s /q target >nul 2>&1
    if exist build rmdir /s /q build >nul 2>&1
    if exist .gradle rmdir /s /q .gradle >nul 2>&1
    
    REM Set Java optimization flags
    set MAVEN_OPTS=-Xmx4g -XX:+TieredCompilation -XX:TieredStopAtLevel=1
    set GRADLE_OPTS=-Xmx4g -Dorg.gradle.daemon=false -Dorg.gradle.parallel=true

) else if "%PROJECT_TYPE%"=="go" (
    REM Go optimizations
    echo Optimizing Go build process...
    
    REM Clean Go cache
    go clean -cache >nul 2>&1
    
    REM Set Go optimization flags
    set GOGC=off
    set CGO_ENABLED=0

) else (
    echo No specific optimizations available for %PROJECT_TYPE%, applying generic optimizations...
)

REM Generic optimizations for all project types
echo Performing generic build optimizations...

REM Create clean build directory if needed
if not exist "%OUTPUT_DIR%" mkdir "%OUTPUT_DIR%"

echo.
echo Build environment has been optimized.
echo Build will now run with maximum performance settings.
echo.

endlocal
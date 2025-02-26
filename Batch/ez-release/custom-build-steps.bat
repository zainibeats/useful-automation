@echo off
REM This file contains custom build steps for your project
REM It is called by release.bat between the standard build steps

echo Running custom build steps...

REM Add your custom build commands here
REM Examples:
REM call npm run build:docs
REM call python tools/generate_bindings.py
REM call dotnet publish -c Release -r win-x64 --self-contained
REM etc.

REM === NODE.JS EXAMPLE ===
REM if "%PROJECT_TYPE%"=="nodejs" (
REM   echo Running Node.js-specific build steps...
REM   call npm run generate-docs
REM   call npm run bundle-assets
REM )

REM === PYTHON EXAMPLE ===
REM if "%PROJECT_TYPE%"=="python" (
REM   echo Running Python-specific build steps...
REM   call python scripts/generate_api_docs.py
REM   call python scripts/compile_resources.py
REM )

REM === RUST EXAMPLE ===
REM if "%PROJECT_TYPE%"=="rust" (
REM   echo Running Rust-specific build steps...
REM   call cargo doc
REM   call cargo clippy -- -D warnings
REM )

echo Custom build steps completed.

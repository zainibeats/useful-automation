# Example Build Script for a Python Project (using PyInstaller)
# This script is called by New-Release.ps1 based on the 'BuildScriptPath' in release.config.ps1
# It should handle the actual compilation/packaging of your project.
# Rename this to 'build.ps1' in your project root and customize it.

[CmdletBinding()]
param (
    # --- Standard Parameters (from New-Release.ps1) ---
    # The -Clean switch is passed if `New-Release.ps1 -CleanBuild` is used.
    [Parameter(Mandatory=$false)]
    [switch]$Clean,

    # Switches corresponding to the keys in the 'Artifacts' section of release.config.ps1
    # where 'IncludeInBuildArgs = $true'. These tell the build script which artifact(s)
    # are expected by the release script.
    [Parameter(Mandatory=$false)]
    [switch]$WindowsPortable, # Example artifact type key

    [Parameter(Mandatory=$false)]
    [switch]$WindowsInstaller, # Example artifact type key

    # --- Custom Parameters (Optional) ---
    # Add any other parameters your specific build process might need.
    [Parameter(Mandatory=$false)]
    [switch]$BuildRust, # Example: If your Python project includes a Rust component

    [Parameter(Mandatory=$false)]
    [switch]$NoConsole # Example: For building a GUI app without a console window
)

$ErrorActionPreference = "Stop"

Write-Host "=================================================="
Write-Host "  Example Python Project Build Script"
Write-Host "=================================================="

# Get the directory where this build script resides
$ScriptDir = Split-Path -Parent $MyInvocation.MyCommand.Path

# --- Clean Step ---
# Remove previous build artifacts if -Clean was specified
if ($Clean) {
    Write-Host "[BUILD] Cleaning previous build artifacts..."
    $buildDir = Join-Path $ScriptDir "build"
    $distDir = Join-Path $ScriptDir "dist"
    if (Test-Path $buildDir) { Remove-Item -Recurse -Force $buildDir }
    if (Test-Path $distDir) { Remove-Item -Recurse -Force $distDir }
    Write-Host "[BUILD] Clean complete."
}

# --- Pre-Build Steps (Optional) ---
# Example: Build a Rust component if needed
if ($BuildRust) {
    Write-Host "[BUILD] Building Rust component..."
    $rustBuildScript = Join-Path $ScriptDir "build_rust.py" # Assuming it's alongside
    if (-not (Test-Path $rustBuildScript)) {
        Write-Error "Rust build script not found at $rustBuildScript"
        exit 1
    }
    # Ensure you have python in PATH or use a specific path/venv
    python $rustBuildScript
    if ($LASTEXITCODE -ne 0) {
        Write-Error "Rust build failed."
        exit 1
    }
    Write-Host "[BUILD] Rust component built."
}

# --- Main Build Step --- 
# Determine which build types are requested based on parameters
$buildTypes = @()
if ($WindowsPortable) { $buildTypes += "portable" }
if ($WindowsInstaller) { $buildTypes += "installer" }

if ($buildTypes.Count -eq 0) {
    Write-Warning "[BUILD] No specific build types requested (e.g., -WindowsPortable, -WindowsInstaller). Assuming default build."
    # Handle default build case if necessary, or modify build_package.py to have a default.
    # For this example, we will require at least one type.
    Write-Error "[BUILD] Please specify at least one build type via parameters (e.g., -WindowsPortable)."
    exit 1
}

Write-Host "[BUILD] Starting Python packaging process for types: $($buildTypes -join ', ')"
$packageScript = Join-Path $ScriptDir "build_package.py" # Assuming it's alongside
if (-not (Test-Path $packageScript)) {
    Write-Error "Python packaging script not found at $packageScript"
    exit 1
}

# Construct the command to call the Python packaging script
$buildCmdArgs = @()
if ($WindowsPortable) { $buildCmdArgs += "--portable" }
if ($WindowsInstaller) { $buildCmdArgs += "--installer" }
if ($NoConsole) { $buildCmdArgs += "--no-console" }
# Add any other args needed by build_package.py

$buildCmd = "python $packageScript $($buildCmdArgs -join ' ')"

# Execute the Python packaging script
Write-Host "[BUILD] Executing: $buildCmd"
try {
    Invoke-Expression $buildCmd
    if ($LASTEXITCODE -ne 0) {
        Throw "Python packaging script failed with exit code $LASTEXITCODE."
    }
    Write-Host "[BUILD] Python packaging completed successfully." -ForegroundColor Green
} catch {
    Write-Error "[BUILD] Python packaging script execution failed: $($_.Exception.Message)"
    exit 1
}

Write-Host "=================================================="
Write-Host "  Build script finished."
Write-Host "==================================================" 
<#
.SYNOPSIS
    Automates the release process for a software project based on a configuration file.

.DESCRIPTION
    This script handles version detection, building, packaging, and optionally signing
    application artifacts for release. It is designed to be modular and configurable
    through a 'release.config.ps1' file.

.PARAMETER ConfigPath
    Path to the release configuration file. Defaults to './release.config.ps1'.

.PARAMETER VersionType
    Specifies the type of version bump (major, minor, patch). Default is 'none'.
    (Currently, only 'none' is fully supported; version bumping is not implemented).

.PARAMETER NoSign
    If specified, skips the GPG signing step even if a GpgKeyId is configured.

.PARAMETER NoBuild
    If specified, skips the build step and assumes artifacts exist in the configured BuildOutputDir.

.PARAMETER BuildArgs
    A hashtable or string of additional arguments to pass directly to the configured build script.
    Example: -BuildArgs @{ NoConsole = $true; ExtraFlag = 'value' }
    Example: -BuildArgs "--custom-flag --another-arg=foo"

.PARAMETER CleanBuild
    If specified, passes a '-Clean' argument to the build script (if supported by the build script).

.EXAMPLE
    .\New-Release.ps1
    Runs the release process using configuration from './release.config.ps1'.

.EXAMPLE
    .\New-Release.ps1 -ConfigPath .\deploy\release.config.ps1 -NoSign
    Uses a custom config path and skips signing.

.EXAMPLE
    .\New-Release.ps1 -NoBuild
    Packages existing build artifacts without rebuilding.

.EXAMPLE
    .\New-Release.ps1 -CleanBuild -BuildArgs @{ NoConsole = $true }
    Cleans before building, and passes '-NoConsole' to the build script.

.NOTES
    Requires a 'release.config.ps1' file (or specified via -ConfigPath).
    Requires GPG to be configured and in PATH for signing.
    The build script specified in the config must exist and be executable.
#>
[CmdletBinding()]
param (
    [Parameter(Mandatory=$false)]
    [string]$ConfigPath = ".\release.config.ps1",

    [Parameter(Mandatory=$false)]
    [ValidateSet("major", "minor", "patch", "none")]
    [string]$VersionType = "none",

    [Parameter(Mandatory=$false)]
    [switch]$NoSign,

    [Parameter(Mandatory=$false)]
    [switch]$NoBuild,
    
    [Parameter(Mandatory=$false)]
    [switch]$CleanBuild,

    [Parameter(Mandatory=$false)]
    [object]$BuildArgs # Can be string or hashtable
)

# --- Initial Setup ---
$ErrorActionPreference = "Stop"
Write-Host "===== Modular Release Script =====" -ForegroundColor Cyan
Write-Host "Timestamp: $(Get-Date)"
Write-Host ""

# Resolve configuration path
$ResolvedConfigPath = Resolve-Path $ConfigPath -ErrorAction SilentlyContinue
if (-not $ResolvedConfigPath) {
    Write-Error "Configuration file not found at '$ConfigPath'."
    exit 1
}
Write-Host "[INFO] Loading configuration from: $($ResolvedConfigPath.Path)"
$Config = . $ResolvedConfigPath.Path

# --- Validate Configuration ---
Write-Host "[INFO] Validating configuration..."
$requiredKeys = @("ProjectName", "VersionSource", "BuildScriptPath", "BuildOutputDir", "Artifacts", "DocFiles", "GpgKeyId")
$missingKeys = @()
foreach ($key in $requiredKeys) {
    if (-not $Config.ContainsKey($key)) {
        $missingKeys += $key
    }
}
if ($missingKeys.Count -gt 0) {
    Write-Error "Configuration file '$($ResolvedConfigPath.Path)' is missing required keys: $($missingKeys -join ', ')"
    exit 1
}
# Further validation could be added here (e.g., checking types, paths)
Write-Host "[INFO] Configuration validation passed."

# --- Determine Version ---
Write-Host "[INFO] Determining project version..."
$CurrentVersion = $null
$VersionSourceConfig = $Config.VersionSource

if ($VersionSourceConfig.Type -eq "File") {
    $versionFilePath = Resolve-Path $VersionSourceConfig.FilePath -ErrorAction SilentlyContinue
    if ($versionFilePath -and (Test-Path $versionFilePath.Path)) {
        try {
            $versionPattern = $VersionSourceConfig.Pattern
            $versionMatch = Select-String -Path $versionFilePath.Path -Pattern $versionPattern | Select-Object -First 1
            if ($versionMatch -and $versionMatch.Matches.Groups.Count -gt 1) {
                $CurrentVersion = $versionMatch.Matches.Groups[1].Value
                Write-Host "[INFO] Detected Version '$CurrentVersion' from $($versionFilePath.Path)"
            } else {
                 Write-Warning "Could not extract version using pattern '$versionPattern' from $($versionFilePath.Path)."
            }
        } catch {
            Write-Warning "Error reading or parsing version file '$($versionFilePath.Path)': $($_.Exception.Message)"
        }
    } else {
        Write-Warning "Version source file not found: $($VersionSourceConfig.FilePath)"
    }
} elseif ($VersionSourceConfig.Type -eq "GitTag") {
    Write-Warning "'GitTag' version source type is not yet implemented."
    # Placeholder for future Git tag logic
    # try {
    #     $CurrentVersion = git describe --tags --abbrev=0
    #     Write-Host "[INFO] Detected Version '$CurrentVersion' from Git tag."
    # } catch { Write-Warning "Could not get version from Git tag. Is Git installed and are there tags?"}
} else {
    Write-Warning "Unsupported VersionSource Type: $($VersionSourceConfig.Type)"
}

if (-not $CurrentVersion) {
    Write-Error "Could not determine project version. Please check configuration and version source."
    exit 1
}

# --- Version Bumping (Placeholder) ---
if ($VersionType -ne "none") {
    Write-Warning "Automatic version bumping ('$VersionType') is not yet implemented. Using current version '$CurrentVersion'."
    # Future implementation: Increment $CurrentVersion based on $VersionType
    # $NewVersion = ...
    # Update version in the source file/tag
}
$ReleaseVersion = $CurrentVersion # Use current version for this release

# --- Build Step ---
if (-not $NoBuild) {
    Write-Host "[INFO] Starting build process..."
    $buildScriptPath = Resolve-Path $Config.BuildScriptPath -ErrorAction SilentlyContinue
    if (-not $buildScriptPath) {
        Write-Error "Build script not found at '$($Config.BuildScriptPath)'"
        exit 1
    }

    # Prepare arguments for the build script
    $scriptArgs = @{}
    if ($CleanBuild) {
        $scriptArgs.Add("Clean", $true) # Assumes build script uses -Clean switch
    }

    # Add artifact-specific flags (e.g., -Portable, -Installer)
    foreach ($key in $Config.Artifacts.Keys) {
        $artifactConf = $Config.Artifacts[$key]
        if ($artifactConf.IncludeInBuildArgs -eq $true) {
            # Assuming the key name matches the switch name (e.g., 'Portable' -> '-Portable')
            $scriptArgs.Add($key, $true) 
        }
    }
    
    # Merge custom build arguments
    if ($BuildArgs) {
        if ($BuildArgs -is [hashtable]) {
            # Merge hashtables
            $BuildArgs.GetEnumerator() | ForEach-Object { 
                if (-not $scriptArgs.ContainsKey($_.Name)) {
                    $scriptArgs.Add($_.Name, $_.Value) 
                } else {
                     Write-Warning "Build argument '$($_.Name)' conflicts with script-defined arguments. Provided argument ignored."
                }
            }
        } elseif ($BuildArgs -is [string]) {
            # Append string arguments (less precise, relies on build script parsing)
             Write-Warning "Passing build arguments as a single string. Ensure your build script can parse '$BuildArgs'."
             # Note: Splatting doesn't directly support adding raw strings. We execute differently.
        }
    }

    Write-Host "[INFO] Executing build script: $($buildScriptPath.Path)"
    Write-Host "[INFO] Calculated Build Script Arguments:"
    $scriptArgs | Format-Table -AutoSize | Out-String | Write-Host
    if ($BuildArgs -is [string]) { Write-Host "[INFO] Additional Raw Build Args: $BuildArgs" }

    try {
        if ($BuildArgs -is [string]) {
            # Execute with string args - requires careful quoting in the build script call if needed
            $command = "$($buildScriptPath.Path) @scriptArgs $BuildArgs"
            Write-Host "[DEBUG] Running command: $command"
            Invoke-Expression $command 
        } else {
             # Execute using splatting for hashtable arguments
            Write-Host "[DEBUG] Running command: & '$($buildScriptPath.Path)' @scriptArgs"
            & $buildScriptPath.Path @scriptArgs
        }

        if ($LASTEXITCODE -ne 0) {
            Throw "Build script failed with exit code $LASTEXITCODE."
        }
        Write-Host "[SUCCESS] Build completed successfully." -ForegroundColor Green
    } catch {
        Write-Error "Build script execution failed: $($_.Exception.Message)"
        exit 1
    }
} else {
    Write-Host "[INFO] Build skipped as requested via -NoBuild." -ForegroundColor Yellow
}

# --- Prepare Release ---
$releaseBaseDir = "release"
Write-Host "[INFO] Preparing release directory: $releaseBaseDir"
if (Test-Path $releaseBaseDir) {
    Write-Host "[INFO] Removing existing release directory..."
    Remove-Item -Recurse -Force $releaseBaseDir
}
New-Item -Path $releaseBaseDir -ItemType Directory -Force | Out-Null

$buildOutputDirPath = Resolve-Path $Config.BuildOutputDir -ErrorAction SilentlyContinue
if (-not $buildOutputDirPath -or -not (Test-Path $buildOutputDirPath.Path -PathType Container)) {
     Write-Error "Build output directory not found or is not a directory: '$($Config.BuildOutputDir)'"
     exit 1
}

# --- Package Artifacts ---
Write-Host "[INFO] Packaging artifacts..."
$packagedArtifacts = @{} # To store paths of created packages

foreach ($artifactKey in $Config.Artifacts.Keys) {
    $artifactConf = $Config.Artifacts[$artifactKey]
    $artifactTargetDirName = $artifactConf.TargetDir
    $artifactPackageSuffix = $artifactConf.PackageNameSuffix
    $artifactSourcePattern = $artifactConf.SourcePattern
    
    $artifactReleaseDir = Join-Path $releaseBaseDir $artifactTargetDirName
    Write-Host "[INFO] Processing artifact type: '$artifactKey'"
    Write-Host "[INFO] -> Target directory: $artifactReleaseDir"
    New-Item -Path $artifactReleaseDir -ItemType Directory -Force | Out-Null

    # Find and copy build artifact(s)
    $sourceArtifactPath = Join-Path $buildOutputDirPath.Path $artifactSourcePattern
    $foundArtifacts = Get-ChildItem -Path $sourceArtifactPath -ErrorAction SilentlyContinue
    
    if ($foundArtifacts) {
        Write-Host "[INFO] -> Found artifact(s) matching '$artifactSourcePattern' in $($buildOutputDirPath.Path):"
        $foundArtifacts | ForEach-Object { Write-Host "   - $($_.Name)" }
        Copy-Item -Path $foundArtifacts.FullName -Destination $artifactReleaseDir -Force
    } else {
        Write-Warning "No artifact found matching pattern '$artifactSourcePattern' in '$($buildOutputDirPath.Path)' for type '$artifactKey'."
        continue # Skip packaging this type if primary artifact is missing
    }

    # Copy documentation files
    Write-Host "[INFO] -> Copying documentation files..."
    foreach ($docFileRelPath in $Config.DocFiles) {
        $docFileFullPath = Resolve-Path $docFileRelPath -ErrorAction SilentlyContinue
        if ($docFileFullPath -and (Test-Path $docFileFullPath.Path -PathType Leaf)) {
            Copy-Item $docFileFullPath.Path $artifactReleaseDir -Force
            Write-Host "[INFO]    - Copied '$($docFileFullPath.Name)'"
        } else {
            Write-Warning "Documentation file not found or is not a file: '$docFileRelPath'"
        }
    }

    # Sign executables (if applicable and not skipped)
    $shouldSign = (-not $NoSign) -and ($Config.GpgKeyId -ne $null -and $Config.GpgKeyId -ne "")
    if ($shouldSign) {
        Write-Host "[INFO] -> Signing executables in '$artifactReleaseDir'..."
        $executablesToSign = Get-ChildItem -Path $artifactReleaseDir -Filter "*.exe"
        if ($executablesToSign) {
            foreach ($exe in $executablesToSign) {
                Write-Host "[INFO]    - Signing '$($exe.Name)' with key '$($Config.GpgKeyId)'..."
                try {
                    # Use --quiet to reduce output, check $LASTEXITCODE
                    gpg --batch --yes --quiet --default-key $Config.GpgKeyId --detach-sign $exe.FullName
                    if ($LASTEXITCODE -ne 0) {
                        Write-Warning "GPG signing failed for '$($exe.Name)' with exit code $LASTEXITCODE."
                    } else {
                         Write-Host "[INFO]    - Successfully signed '$($exe.Name)'."
                    }
                } catch {
                     Write-Warning "Error executing gpg for '$($exe.Name)': $($_.Exception.Message)"
                }
            }
        } else {
            Write-Host "[INFO] -> No executables found in '$artifactReleaseDir' to sign."
        }
    } elseif (-not $NoSign) {
         Write-Host "[INFO] -> Signing skipped (GpgKeyId not configured)."
    } else {
         Write-Host "[INFO] -> Signing skipped as requested via -NoSign." -ForegroundColor Yellow
    }

    # Create ZIP archive
    $zipFileNameBase = "$($Config.ProjectName)$($artifactPackageSuffix)-$($ReleaseVersion)"
    $zipFilePath = Join-Path $releaseBaseDir "$zipFileNameBase.zip"
    Write-Host "[INFO] -> Creating archive: $zipFilePath"
    try {
        Compress-Archive -Path "$artifactReleaseDir\*" -DestinationPath $zipFilePath -Force
        Write-Host "[SUCCESS] -> Archive '$zipFilePath' created." -ForegroundColor Green
        $packagedArtifacts[$artifactKey] = $zipFilePath
    } catch {
        Write-Error "Failed to create archive '$zipFilePath': $($_.Exception.Message)"
    }
    Write-Host "" # Newline between artifact types
}

# --- Final Summary ---
Write-Host "===== Release Process Summary =====" -ForegroundColor Cyan
Write-Host "Project: $($Config.ProjectName)"
Write-Host "Version: $ReleaseVersion"
Write-Host "Timestamp: $(Get-Date)"
Write-Host ""

if ($packagedArtifacts.Count -gt 0) {
    Write-Host "Created Packages:" -ForegroundColor Green
    $packagedArtifacts.GetEnumerator() | ForEach-Object {
        Write-Host "  - $($_.Name): $(Resolve-Path $_.Value)"
    }
} else {
     Write-Warning "No release packages were created."
}

Write-Host ""
Write-Host "Release files (unpacked) are located in: $(Resolve-Path $releaseBaseDir)"
Write-Host ""
Write-Host "===== Release process completed. =====" -ForegroundColor Cyan 
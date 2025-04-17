# Example Configuration for New-Release.ps1
# Rename this file to 'release.config.ps1' in your project root and customize it.

@{
    # --- Project Information ---
    # The name of your project. Used for naming release artifacts.
    ProjectName = "MyAwesomeProject"

    # --- Version Source ---
    # How the script determines the project's current version.
    VersionSource = @{
        # Type: 'File' or 'GitTag' (GitTag not implemented yet)
        Type     = "File"
        # FilePath: Path relative to project root containing the version string.
        FilePath = "src\__init__.py" # Example for Python
        # Pattern: Regex pattern to extract the version number. MUST have one capture group for the version.
        Pattern  = "__version__ = '([0-9]+\.[0-9]+\.[0-9]+)'" # Example for Python: __version__ = '1.2.3'
        # --- OR --- Example for other files:
        # FilePath = "version.txt"
        # Pattern  = "^([0-9]+\.[0-9]+\.[0-9]+)$" # Example for version.txt containing only '1.2.3'
    }

    # --- Build Process ---
    # BuildScriptPath: Path relative to project root of the script that builds your project.
    # This script will be executed by New-Release.ps1.
    BuildScriptPath = "build.ps1" # Example: A PowerShell build script
    # BuildOutputDir: Path relative to project root where the build script places its output artifacts.
    BuildOutputDir  = "dist"

    # --- Artifact Packaging ---
    # Defines the different types of release packages you want to create.
    # Each key (e.g., 'WindowsPortable', 'LinuxBinary') represents an artifact type.
    Artifacts = @{
        # Example: A portable Windows executable package
        WindowsPortable = @{
            # SourcePattern: File/directory name or pattern (relative to BuildOutputDir) of the main artifact to package.
            # Can include wildcards (*, ?). Use '\\' for path separators if needed (e.g., "subdir\\MyExe.exe").
            SourcePattern      = "MyAwesomeProject.exe"
            # TargetDir: Name of the subfolder within the 'release' directory where this artifact will be staged before zipping.
            TargetDir          = "win-portable"
            # PackageNameSuffix: Suffix added to the project name for the final ZIP file name.
            PackageNameSuffix  = "-Windows-Portable"
            # IncludeInBuildArgs: If $true, the key name ('WindowsPortable') is passed as a switch (-WindowsPortable) to the BuildScriptPath.
            # Useful for telling your build script which artifact type to build.
            IncludeInBuildArgs = $true
        }
        # Example: A Windows installer package
        WindowsInstaller = @{
            SourcePattern      = "MyAwesomeProject_Setup_*.exe" # Example using wildcard for version
            TargetDir          = "win-installer"
            PackageNameSuffix  = "-Windows-Installer"
            IncludeInBuildArgs = $true
        }
        # Example: A generic binary package (e.g., for Linux)
        LinuxBinary = @{
            SourcePattern      = "myawesomeproject"
            TargetDir          = "linux-binary"
            PackageNameSuffix  = "-Linux-x64"
            IncludeInBuildArgs = $false # Maybe the default build script already produces this
        }
    }

    # --- Documentation Files ---
    # List of documentation or other files (relative to project root) to include in EACH artifact package.
    DocFiles = @(
        "README.md",
        "LICENSE",
        "CHANGELOG.md"
    )

    # --- Signing (Optional) ---
    # GpgKeyId: Your GPG Key ID (long format) to sign *.exe files found in the artifact staging directories.
    # Leave empty or remove the key to disable signing.
    # Requires GPG to be installed and in PATH.
    GpgKeyId = ""
} 
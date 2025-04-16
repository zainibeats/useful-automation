# Configuration template for New-Release.ps1
# Rename this file to 'release.config.ps1' in your project root or specify its path via -ConfigPath

# Return a hashtable with the configuration settings
@{    
    # --- Project Information ---
    ProjectName = "YourProjectName" # Used in filenames and messages

    # --- Version Source ---
    # Define how the script finds the current version.
    # Supported Types: "File", "GitTag" (GitTag not yet implemented)
    VersionSource = @{
        Type     = "File" # Or "GitTag"
        FilePath = "src\__init__.py" # Relative path to the version file (for Type = "File")
        Pattern  = "__version__ = '([0-9]+\.[0-9]+\.[0-9]+)'" # Regex to extract version (for Type = "File")
                                                                # Must contain one capturing group for the version string.
        # TagPrefix = "v" # Optional prefix for Git tags (for Type = "GitTag")
    }

    # --- Build Process ---
    BuildScriptPath = ".\ref\build.ps1" # Relative path to the project's build script (e.g., build.ps1, build.bat, makefile)
    BuildOutputDir  = "dist"             # Relative path to the directory where build artifacts are placed by the build script
    
    # --- Artifact Packaging ---
    # Define the artifacts to package. The keys ("Portable", "Installer") can be anything descriptive.
    # Each key maps to a hashtable defining:
    #   - SourcePattern: File pattern (relative to BuildOutputDir) to find the main artifact (e.g., *.exe, *.jar).
    #   - TargetDir: Name of the subdirectory within the 'release' folder for this artifact type.
    #   - PackageNameSuffix: String appended to the project name for the final zip file (e.g., "-Portable", "-Installer").
    #   - IncludeInBuildArgs: $true/$false. If true, the key name (e.g., "Portable") is passed as a switch (e.g., "-Portable") to the build script.
    Artifacts = @{
        Portable = @{
            SourcePattern      = "$($ProjectName).exe" # Example: Find YourProjectName.exe
            TargetDir          = "portable"
            PackageNameSuffix  = "-Portable"
            IncludeInBuildArgs = $true # Pass -Portable to the build script
        }
        Installer = @{
            SourcePattern      = "$($ProjectName)*Setup*.exe" # Example: Find YourProjectName_Setup_1.0.0.exe
            TargetDir          = "installer"
            PackageNameSuffix  = "-Installer"
            IncludeInBuildArgs = $true # Pass -Installer to the build script
        }
        # Add more artifact types if needed (e.g., Library, SourceCode)
        # SourceCode = @{
        #     SourcePattern      = "*.zip" # Example: Assume build script creates a source zip
        #     TargetDir          = "source"
        #     PackageNameSuffix  = "-Source"
        #     IncludeInBuildArgs = $false 
        # }
    }
    
    # --- Documentation Files ---
    # List of relative paths to documentation files to include in each artifact package.
    DocFiles = @(
        "README.md",
        "LICENSE",
        "CHANGELOG.md"
        # Add other files like SECURITY.md, CONTRIBUTING.md etc.
    )

    # --- Signing ---
    # GPG Key ID for signing executables. Leave empty or remove if signing is not needed.
    # The GPG key must be available in the environment where the script runs.
    GpgKeyId = "YOUR_GPG_KEY_ID" # Example: "8910ACB66A475A28"
} 
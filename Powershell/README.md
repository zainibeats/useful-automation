# PowerShell Utility Scripts

This directory contains PowerShell scripts for various file operations

## Scripts

### rename-files-from-list.ps1

A versatile script to batch rename files using a list of names from a text file. The script is particularly useful when you have a set of files that need to be renamed according to a predefined list, such as:
- Product images with SKU names
- Photo collections with event names
- Asset files with proper naming conventions
- Media files with metadata in the list

#### Requirements
- Windows PowerShell or PowerShell Core
- Read/Write permissions in the target directory

#### Usage

1. Prepare a text file with names in the format:
   ```
   NewName1[,optional metadata]
   NewName2[,additional info]
   NewName3[,anything after comma is ignored]
   ```
   The comma feature is useful for:
   - Keeping metadata/notes with each name
   - Using exported CSV data without cleanup
   - Including categories or tags without affecting names
   - Preserving reference information

2. Update the script variables:
   ```powershell
   $namesFilePath = "C:\Path\To\names.txt"    # Path to your names list file
   $gifFolderPath = "C:\Path\To\Files"        # Path to folder containing files to rename
   ```

3. Run the script:
   ```powershell
   .\rename-files-from-list.ps1
   ```

#### Features
- Automatically matches files to names in alphabetical order
- Ignores any text after a comma in the names list
- Performs validation to ensure the number of files matches the number of names
- Preserves original file extensions
- Error handling for mismatched file counts

#### Notes
- Files are sorted alphabetically before renaming
- The script will stop if the number of files doesn't match the number of names
- Make sure to backup your files before running the script
- You can modify the script to target specific file types by changing the `-Filter` parameter
- The comma functionality can be repurposed for different delimiters by modifying the split character

### ez-release/New-Release.ps1

A modular and configurable PowerShell script designed to automate the software release process. It handles version detection, building, packaging, and optional GPG signing based on a project-specific configuration file.

Located in the `ez-release` subdirectory.

#### Features

- **Configurable:** Define project specifics (name, version source, build steps, artifacts) in a simple PowerShell configuration file (`release.config.ps1`).
- **Flexible Versioning:** Extract version numbers from files using regex (support for Git tags planned).
- **Build Integration:** Executes your existing build script (e.g., `.ps1`, `.bat`, `make`) with configurable arguments.
- **Artifact Packaging:** Automatically gathers specified build artifacts (e.g., executables, libraries) and documentation files.
- **GPG Signing:** Optionally signs packaged executables using a configured GPG key.
- **Output:** Creates organized release directories and ZIP archives for different artifact types (e.g., portable, installer).

#### Requirements

- Windows PowerShell or PowerShell Core.
- A `release.config.ps1` file (see `ez-release/release.config.example.ps1`) defining the release process for your project.
- The build script specified in the configuration must be present and executable.
- GPG installed and configured in the system PATH (required only if signing is enabled).

#### Usage

1.  **Configure:** Copy `ez-release/release.config.example.ps1` to `release.config.ps1` (or another location) and customize it for your project.
2.  **Run:** Execute the script from your project root or specify the configuration path:

    ```powershell
    # Use default ./release.config.ps1
    ./PowerShell/ez-release/New-Release.ps1
    
    # Specify a custom config path
    ./PowerShell/ez-release/New-Release.ps1 -ConfigPath ./deploy/my-release-config.ps1
    
    # Skip the build step (use existing artifacts)
    ./PowerShell/ez-release/New-Release.ps1 -NoBuild
    
    # Skip GPG signing
    ./PowerShell/ez-release/New-Release.ps1 -NoSign
    
    # Pass additional arguments to the build script
    ./PowerShell/ez-release/New-Release.ps1 -BuildArgs @{ NoConsole = $true; Verbose = $true }
    
    # Pass -Clean switch to the build script
    ./PowerShell/ez-release/New-Release.ps1 -CleanBuild
    ```

See the script's comment-based help for more details on parameters:

```powershell
Get-Help ./PowerShell/ez-release/New-Release.ps1 -Full
```

#### Configuration (`release.config.ps1`)

This file returns a PowerShell hashtable defining the release parameters. Key settings include:

- `ProjectName`: Your application's name.
- `VersionSource`: How to find the version (File path + Regex, Git tag planned).
- `BuildScriptPath`: Path to your build script.
- `BuildOutputDir`: Where your build script places artifacts.
- `Artifacts`: Defines what to package (e.g., Portable executable, Installer), how to find them (`SourcePattern`), where to put them (`TargetDir`), and the final zip name (`PackageNameSuffix`).
- `DocFiles`: List of documentation files (README, LICENSE, etc.) to include.
- `GpgKeyId`: Your GPG key ID for signing (leave empty to disable).

Refer to `ez-release/release.config.example.ps1` for detailed structure and examples. 
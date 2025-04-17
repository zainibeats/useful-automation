# Configuration for New-Release.ps1 - TrueFA-Py
# This configures the release process for TrueFA-Py

@{    
    # --- Project Information ---
    ProjectName = "TrueFA-Py"

    # --- Version Source ---
    VersionSource = @{
        Type     = "File" 
        FilePath = "src\__init__.py" # Relative to the project root
        Pattern  = "__version__ = '([0-9]+\.[0-9]+\.[0-9]+)'" 
    }

    # --- Build Process ---
    BuildScriptPath = "build.ps1" # Relative to the project root
    BuildOutputDir  = "dist"            
    
    # --- Artifact Packaging ---
    Artifacts = @{
        Portable = @{
            SourcePattern      = "TrueFA-Py-CLI.exe" # Match the specific portable executable
            TargetDir          = "portable"    
            PackageNameSuffix  = "-Portable"  
            IncludeInBuildArgs = $true 
        }
        Installer = @{
            SourcePattern      = "TrueFA-Py*Setup*.exe" # Installer pattern
            TargetDir          = "installer"          
            PackageNameSuffix  = "-Installer"         
            IncludeInBuildArgs = $true
        }
    }
    
    # --- Documentation Files ---
    DocFiles = @(
        "README.md", 
        "LICENSE", 
        "SECURITY.md", 
        "CRYPTO.md"
    )

    # --- Signing ---
    GpgKeyId = "8910ACB66A475A28" # From the reference script
} 
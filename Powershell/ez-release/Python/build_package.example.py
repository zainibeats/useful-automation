#!/usr/bin/env python
"""
Example Python Package/Deployment Script for New-Release.ps1

This script builds a Python application in multiple formats:
1. Portable executable (using PyInstaller)
2. Installer package (using NSIS)

Rename this to 'build_package.py' in your project root and customize it.
"""

import os
import sys
import shutil
import subprocess
import platform
import importlib.util
import argparse
import re  # For regex version extraction

# Function to get version from a Python __init__.py file
def get_version_from_init():
    version_file = os.path.join('src', '__init__.py')
    try:
        with open(version_file, 'r') as f:
            version_match = re.search(r"^__version__ = ['\"]([^'\"]*)['\"]", f.read(), re.M)
        if version_match:
            return version_match.group(1)
        else:
            print(f"Could not find __version__ in {version_file}")
    except Exception as e:
        print(f"Error reading version from {version_file}: {e}")
    
    # Fallback version if we couldn't read it
    return "0.1.0"

# Application Configuration
APP_NAME = "MyAwesomeProject"  # Change this to your project name
APP_VERSION = get_version_from_init()  # Read version dynamically
AUTHOR = "Your Name"
COPYRIGHT = f"Copyright (c) {2025} {AUTHOR}"
DESCRIPTION = "Description of your project"
WEBSITE = "https://github.com/username/project"

# Icon path - this should point to the icon file in your project
ICON_PATH = os.path.join("assets", "app_icon.ico")

def setup_parser():
    """Set up command line argument parser."""
    parser = argparse.ArgumentParser(description=f"Build {APP_NAME} application")
    parser.add_argument("--portable", action="store_true", 
                        help="Build portable executable")
    parser.add_argument("--installer", action="store_true", 
                        help="Build installer package")
    parser.add_argument("--clean", action="store_true", 
                        help="Remove build and dist directories before building")
    parser.add_argument("--no-console", action="store_true", 
                        help="Build GUI version with no console window")
    return parser

def check_requirements(check_nsis=False):
    """Check if all required tools are installed."""
    print("Checking build requirements...")
    
    requirements = []
    
    # 1. Check for PyInstaller
    try:
        import PyInstaller
        print(f"(+) PyInstaller found (version {PyInstaller.__version__})")
    except ImportError:
        requirements.append("PyInstaller (pip install pyinstaller)")
    
    # 2. Check for NSIS only if requested
    if check_nsis:
        nsis_found = False
        nsis_paths = [
            r"C:\Program Files (x86)\NSIS\makensis.exe",
            r"C:\Program Files\NSIS\makensis.exe"
        ]
        for path in nsis_paths:
            if os.path.exists(path):
                nsis_found = True
                print(f"(+) NSIS found at {path}")
                break
        
        if not nsis_found:
            requirements.append("NSIS (https://nsis.sourceforge.io/Download) - Required for installer build")
    
    # Report any missing requirements
    if requirements:
        print("\nMissing requirements:")
        for req in requirements:
            print(f"  - {req}")
        print("\nPlease install the missing requirements and try again.")
        return False
    
    return True

def check_icon():
    """Check if the icon file exists and is valid."""
    if not os.path.exists(ICON_PATH):
        print(f"Warning: Icon file not found at {ICON_PATH}")
        return None
    
    print(f"(+) Using icon: {ICON_PATH}")
    return ICON_PATH

def create_spec_file(entry_script, icon_path, use_console=True):
    """Create a PyInstaller spec file."""
    print(f"Creating PyInstaller spec file for {'Console' if use_console else 'GUI'} application...")
    
    # Determine output name
    output_name = APP_NAME
    
    # Determine hidden imports - customize these for your project
    hidden_imports = []
    
    print(f"Using entry script: {entry_script}")
    print(f"Hidden imports: {hidden_imports}")

    # Determine data files to include
    datas = [
        ('assets/*', 'assets'),  # Include assets directory
        # Add other data files your application needs
    ]
    
    print(f"Data files: {datas}")

    # Create spec file content
    spec_content = f"""# -*- mode: python ; coding: utf-8 -*-

block_cipher = None

a = Analysis(
    ['{entry_script}'],
    pathex=[],
    binaries=[],
    datas={datas},
    hiddenimports={hidden_imports},
    hookspath=[],
    hooksconfig={{}},
    runtime_hooks=[],
    excludes=[],
    win_no_prefer_redirects=False,
    win_private_assemblies=False,
    cipher=block_cipher,
    noarchive=False,
)

pyz = PYZ(a.pure, a.zipped_data, cipher=block_cipher)

exe = EXE(
    pyz,
    a.scripts,
    a.binaries,
    a.zipfiles,
    a.datas,
    [],
    name='{output_name}',
    debug=False,
    bootloader_ignore_signals=False,
    strip=False,
    upx=True,
    upx_exclude=[],
    runtime_tmpdir=None,
    console={'True' if use_console else 'False'},
    {'icon=r"' + icon_path + '"' if icon_path else ''}
)
"""
    
    # Write spec file
    spec_file = f"{output_name}.spec"
    with open(spec_file, 'w') as f:
        f.write(spec_content)
    
    print(f"(+) Created spec file: {spec_file}")
    return spec_file

def create_version_file():
    """Create a version information file for Windows executables."""
    print("Creating version information file...")
    
    # File content for version information
    version_info = f"""# UTF-8
#
# For more details about fixed file info 'ffi' see:
# http://msdn.microsoft.com/en-us/library/ms646997.aspx
VSVersionInfo(
  ffi=FixedFileInfo(
    # filevers and prodvers should be always a tuple with four items: (1, 2, 3, 4)
    # Set not needed items to zero 0.
    filevers=({', '.join(APP_VERSION.split('.') + ['0'] * (4 - len(APP_VERSION.split('.'))))}),
    prodvers=({', '.join(APP_VERSION.split('.') + ['0'] * (4 - len(APP_VERSION.split('.'))))}),
    # Contains a bitmask that specifies the valid bits 'flags'r
    mask=0x3f,
    # Contains a bitmask that specifies the Boolean attributes of the file.
    flags=0x0,
    # The operating system for which this file was designed.
    # 0x4 - NT and there is no need to change it.
    OS=0x40004,
    # The general type of file.
    # 0x1 - the file is an application.
    fileType=0x1,
    # The function of the file.
    # 0x0 - the function is not defined for this fileType
    subtype=0x0,
    # Creation date and time stamp.
    date=(0, 0)
    ),
  kids=[
    StringFileInfo(
      [
      StringTable(
        u'040904B0',
        [StringStruct(u'CompanyName', u'{AUTHOR}'),
        StringStruct(u'FileDescription', u'{DESCRIPTION}'),
        StringStruct(u'FileVersion', u'{APP_VERSION}'),
        StringStruct(u'InternalName', u'{APP_NAME}'),
        StringStruct(u'LegalCopyright', u'{COPYRIGHT}'),
        StringStruct(u'OriginalFilename', u'{APP_NAME}.exe'),
        StringStruct(u'ProductName', u'{APP_NAME}'),
        StringStruct(u'ProductVersion', u'{APP_VERSION}')])
      ]), 
    VarFileInfo([VarStruct(u'Translation', [1033, 1200])])
  ]
)"""

    # Write to file
    version_file = "file_version_info.txt"
    with open(version_file, 'w') as f:
        f.write(version_info)
    
    print(f"(+) Created version information file")
    return version_file

def build_executable(spec_file):
    """Build the executable using PyInstaller."""
    print(f"Building executable from {spec_file}...")
    
    try:
        # Run PyInstaller
        subprocess.run(["pyinstaller", spec_file, "--clean"], check=True)
        print(f"(+) PyInstaller build completed successfully")
        return True
    except subprocess.CalledProcessError as e:
        print(f"Error running PyInstaller: {e}")
        return False
    except Exception as e:
        print(f"Unexpected error during build: {e}")
        return False

def create_nsis_script(icon_path, app_name=APP_NAME, version=APP_VERSION):
    """Create an NSIS installer script."""
    print("Creating NSIS installer script...")
    
    # NSIS script content
    nsis_script = f"""
; Installer script for {app_name}
!include "MUI2.nsh"

; Basic definitions
!define APPNAME "{app_name}"
!define COMPANYNAME "{AUTHOR}"
!define DESCRIPTION "{DESCRIPTION}"
!define VERSIONMAJOR {APP_VERSION.split('.')[0]}
!define VERSIONMINOR {APP_VERSION.split('.')[1] if len(APP_VERSION.split('.')) > 1 else 0}
!define VERSIONBUILD {APP_VERSION.split('.')[2] if len(APP_VERSION.split('.')) > 2 else 0}
!define HELPURL "{WEBSITE}"
!define UPDATEURL "{WEBSITE}"
!define ABOUTURL "{WEBSITE}"

; The name of the installer
Name "${{APPNAME}}"

; The file to write
OutFile "dist/${{APPNAME}}_Setup_${{VERSIONMAJOR}}.${{VERSIONMINOR}}.${{VERSIONBUILD}}.exe"

; Request application privileges
RequestExecutionLevel admin

; Build Unicode installer
Unicode True

; The default installation directory
InstallDir "$PROGRAMFILES\\${{APPNAME}}"

; Registry key to check for directory (so if you install again, it will 
; overwrite the old one automatically)
InstallDirRegKey HKLM "Software\\${{APPNAME}}" "Install_Dir"

; Interface Settings
!define MUI_ABORTWARNING
!define MUI_ICON "{icon_path if icon_path else 'installer.ico'}"

; Pages
!insertmacro MUI_PAGE_LICENSE "LICENSE"
!insertmacro MUI_PAGE_DIRECTORY
!insertmacro MUI_PAGE_INSTFILES
    
!insertmacro MUI_UNPAGE_CONFIRM
!insertmacro MUI_UNPAGE_INSTFILES

; Languages
!insertmacro MUI_LANGUAGE "English"

; The stuff to install
Section "Install"
  ; Set output path to the installation directory
  SetOutPath $INSTDIR
  
  ; Put file there
  File /r "dist\\${{APPNAME}}\\*.*"
  
  ; Write the installation path into the registry
  WriteRegStr HKLM "SOFTWARE\\${{APPNAME}}" "Install_Dir" "$INSTDIR"
  
  ; Write the uninstall keys for Windows
  WriteRegStr HKLM "Software\\Microsoft\\Windows\\CurrentVersion\\Uninstall\\${{APPNAME}}" "DisplayName" "${{APPNAME}}"
  WriteRegStr HKLM "Software\\Microsoft\\Windows\\CurrentVersion\\Uninstall\\${{APPNAME}}" "DisplayVersion" "${{VERSIONMAJOR}}.${{VERSIONMINOR}}.${{VERSIONBUILD}}"
  WriteRegStr HKLM "Software\\Microsoft\\Windows\\CurrentVersion\\Uninstall\\${{APPNAME}}" "Publisher" "${{COMPANYNAME}}"
  WriteRegStr HKLM "Software\\Microsoft\\Windows\\CurrentVersion\\Uninstall\\${{APPNAME}}" "UninstallString" '"$INSTDIR\\uninstall.exe"'
  WriteRegStr HKLM "Software\\Microsoft\\Windows\\CurrentVersion\\Uninstall\\${{APPNAME}}" "QuietUninstallString" '"$INSTDIR\\uninstall.exe" /S'
  WriteRegStr HKLM "Software\\Microsoft\\Windows\\CurrentVersion\\Uninstall\\${{APPNAME}}" "InstallLocation" "$INSTDIR"
  WriteRegStr HKLM "Software\\Microsoft\\Windows\\CurrentVersion\\Uninstall\\${{APPNAME}}" "DisplayIcon" "$INSTDIR\\${{APPNAME}}.exe"
  WriteRegStr HKLM "Software\\Microsoft\\Windows\\CurrentVersion\\Uninstall\\${{APPNAME}}" "URLInfoAbout" "${{ABOUTURL}}"
  WriteRegStr HKLM "Software\\Microsoft\\Windows\\CurrentVersion\\Uninstall\\${{APPNAME}}" "HelpLink" "${{HELPURL}}"
  WriteRegDWORD HKLM "Software\\Microsoft\\Windows\\CurrentVersion\\Uninstall\\${{APPNAME}}" "NoModify" 1
  WriteRegDWORD HKLM "Software\\Microsoft\\Windows\\CurrentVersion\\Uninstall\\${{APPNAME}}" "NoRepair" 1
  
  ; Create uninstaller
  WriteUninstaller "$INSTDIR\\uninstall.exe"
  
  ; Create start menu shortcut
  CreateDirectory "$SMPROGRAMS\\${{APPNAME}}"
  CreateShortcut "$SMPROGRAMS\\${{APPNAME}}\\${{APPNAME}}.lnk" "$INSTDIR\\${{APPNAME}}.exe" "" "$INSTDIR\\${{APPNAME}}.exe" 0
  CreateShortcut "$SMPROGRAMS\\${{APPNAME}}\\Uninstall.lnk" "$INSTDIR\\uninstall.exe" "" "$INSTDIR\\uninstall.exe" 0
SectionEnd

; The uninstaller
Section "Uninstall"
  ; Remove registry keys
  DeleteRegKey HKLM "Software\\Microsoft\\Windows\\CurrentVersion\\Uninstall\\${{APPNAME}}"
  DeleteRegKey HKLM "SOFTWARE\\${{APPNAME}}"

  ; Remove files and uninstaller
  Delete $INSTDIR\\*.*

  ; Remove shortcuts, if any
  Delete "$SMPROGRAMS\\${{APPNAME}}\\*.*"

  ; Remove directories used
  RMDir "$SMPROGRAMS\\${{APPNAME}}"
  RMDir /r "$INSTDIR"
SectionEnd
"""
    
    # Write to file
    nsis_script_file = "installer.nsi"
    with open(nsis_script_file, 'w') as f:
        f.write(nsis_script)
    
    print(f"(+) Created NSIS installer script")
    return nsis_script_file

def build_installer(nsis_script):
    """Build the installer using NSIS."""
    print(f"Building installer with NSIS...")
    
    try:
        # Find NSIS
        nsis_paths = [
            r"C:\Program Files (x86)\NSIS\makensis.exe",
            r"C:\Program Files\NSIS\makensis.exe"
        ]
        
        nsis_exe = None
        for path in nsis_paths:
            if os.path.exists(path):
                nsis_exe = path
                break
        
        if not nsis_exe:
            print("NSIS not found. Please install NSIS and try again.")
            return False
        
        # Run NSIS
        subprocess.run([nsis_exe, nsis_script], check=True)
        print(f"(+) NSIS installer build completed successfully")
        return True
    except subprocess.CalledProcessError as e:
        print(f"Error running NSIS: {e}")
        return False
    except Exception as e:
        print(f"Unexpected error during installer build: {e}")
        return False

def main():
    """Main build process."""
    parser = setup_parser()
    args = parser.parse_args()
    
    # Print build configuration
    print("Build configuration:")
    print(f"  Portable: {args.portable}")
    print(f"  Installer: {args.installer}")
    print(f"  GUI (No Console): {args.no_console}")
    
    # Clean build artifacts if requested
    if args.clean:
        print("Cleaning build artifacts...")
        if os.path.exists("build"):
            shutil.rmtree("build")
        if os.path.exists("dist"):
            shutil.rmtree("dist")
    
    # Create dist directory if it doesn't exist
    os.makedirs("dist", exist_ok=True)
    
    # Check requirements before building
    if not check_requirements(check_nsis=args.installer):
        sys.exit(1)
    
    # Check icon file
    icon_path = check_icon()
    
    # Create version file for Windows executables
    version_file = create_version_file()
    
    # Determine the entry script based on console usage
    entry_script = "main.py"  # Change this to your main entry script
    if not args.no_console:
        print(f"Building Console application from {entry_script}")
    else:
        entry_script = "gui_main.py"  # Change this to your GUI entry script
        print(f"Building GUI application from {entry_script}")
    
    # Build portable executable if requested
    if args.portable:
        print("\n----- Building Portable Executable -----")
        spec_file = create_spec_file(entry_script, icon_path, use_console=not args.no_console)
        if build_executable(spec_file):
            print("Portable executable build successful.")
        else:
            print("Failed to build portable executable.")
            sys.exit(1)
    
    # Build installer if requested
    if args.installer:
        print("\n----- Building Installer -----")
        spec_file = create_spec_file(entry_script, icon_path, use_console=not args.no_console)
        if build_executable(spec_file):
            nsis_script = create_nsis_script(icon_path)
            if build_installer(nsis_script):
                print("Installer build successful.")
            else:
                print("Failed to build installer.")
                sys.exit(1)
        else:
            print("Failed to build executable for installer.")
            sys.exit(1)
    
    print("\nBuild process completed.")

if __name__ == "__main__":
    main() 
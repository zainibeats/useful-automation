#!/usr/bin/env python
"""
TrueFA Comprehensive Build Script

This script builds TrueFA in multiple formats:
1. Portable executable (single file)
2. Setup installer (using NSIS)

It also ensures proper icon integration and DLL validation.
"""

import os
import sys
import shutil
import subprocess
from pathlib import Path
import ctypes
import platform
import importlib.util
import time
import stat
import argparse
import re # Import re for regex

# Function to get version from src/__init__.py
def get_version_from_init():
    version_file = os.path.join('src', '__init__.py')
    try:
        with open(version_file, 'r') as f:
            version_match = re.search(r"^__version__ = ['\"]([^'\"]*)['\"]", f.read(), re.M)
        if version_match:
            return version_match.group(1)
    except Exception as e:
        print(f"Error reading version from {version_file}: {e}")
    # Fallback or error handling if needed, here we'll exit if not found
    print(f"Could not find __version__ in {version_file}")
    sys.exit(1)

# Configuration
APP_NAME = "TrueFA-Py"
APP_VERSION = get_version_from_init() # Read version dynamically
AUTHOR = "Cheyenne Z"
COPYRIGHT = "Copyright (c) 2025 Cheyenne Zaini"
DESCRIPTION = "Secure Two-Factor Authentication Tool"
WEBSITE = "https://github.com/zainibeats/truefa-py"

# Icon path - this should point to the icon file in assets directory
ICON_PATH = os.path.join("assets", "truefa2.ico")

def setup_parser():
    """Set up command line argument parser."""
    parser = argparse.ArgumentParser(description="Build TrueFA application")
    parser.add_argument("--portable", action="store_true", 
                        help="Build portable version only")
    parser.add_argument("--installer", action="store_true", 
                        help="Build installer version only")
    parser.add_argument("--clean", action="store_true", 
                        help="Remove build and dist directories before building")
    parser.add_argument("--is_installer_build", action="store_true", help=argparse.SUPPRESS)
    parser.add_argument("--no-console", action="store_true", 
                        help="Build GUI version (truefa_gui.py) instead of console version (main.py)")
    parser.add_argument("--fallback", action="store_true", 
                        help="Force use of Python fallback implementation")
    parser.add_argument("--config-logging", type=str, default="logging=enabled,debug=disabled",
                        help="Configure logging settings (format: logging=[enabled|disabled],debug=[enabled|disabled])")
    return parser

def check_requirements(check_nsis=False):
    """Check if all required tools are installed."""
    print("Checking build requirements...")
    
    requirements = []
    
    # 1. Check for PyInstaller
    try:
        # Try to import PyInstaller directly
        import PyInstaller
        print(f"(+) PyInstaller found (version {PyInstaller.__version__})")
    except ImportError:
        # Fall back to spec check
        try:
            spec = importlib.util.find_spec("PyInstaller")
            if spec is None:
                requirements.append("PyInstaller (pip install pyinstaller)")
            else:
                print("(+) PyInstaller found")
        except Exception:
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

def check_dll():
    """Check if the Rust DLL exists and has the required functions."""
    print("Checking Rust cryptography DLL...")
    
    possible_dll_locations = [
        # Current directory
        os.path.join(os.getcwd(), "truefa_crypto.dll"),
        # Direct path
        os.path.join("truefa_crypto", "truefa_crypto.dll"), 
        # Source directory
        os.path.join("src", "truefa_crypto", "truefa_crypto.dll"),
        # Build directory
        os.path.join("rust_crypto", "target", "release", "truefa_crypto.dll"),
    ]
    
    for dll_path in possible_dll_locations:
        if os.path.exists(dll_path):
            print(f"(+) Found DLL at {dll_path}")
            try:
                # Load the DLL
                lib = ctypes.CDLL(dll_path)
                
                # Define the list of required functions
                required_functions = [
                    'c_secure_random_bytes',
                    'c_is_vault_unlocked',
                    'c_vault_exists',
                    'c_create_vault',
                    'c_unlock_vault',
                    'c_lock_vault',
                    'c_generate_salt',
                    'c_derive_master_key',
                    'c_encrypt_master_key',
                    'c_decrypt_master_key',
                    'c_verify_signature',
                    'c_create_secure_string'
                ]
                
                # Check all required functions
                missing_functions = []
                for func_name in required_functions:
                    if not hasattr(lib, func_name):
                        missing_functions.append(func_name)
                
                if missing_functions:
                    print(f"Warning: Missing functions in the DLL: {', '.join(missing_functions)}")
                    return False, dll_path
                else:
                    print("(+) All required functions found in the DLL")
                    
                    # Ensure DLL is in both root truefa_crypto and src/truefa_crypto
                    src_dll_path = os.path.join("src", "truefa_crypto", "truefa_crypto.dll")
                    root_dll_path = os.path.join("truefa_crypto", "truefa_crypto.dll")
                    
                    # Create directories if they don't exist
                    os.makedirs(os.path.dirname(src_dll_path), exist_ok=True)
                    os.makedirs(os.path.dirname(root_dll_path), exist_ok=True)
                    
                    if os.path.abspath(dll_path) != os.path.abspath(src_dll_path):
                        print(f"(+) Copying DLL to {src_dll_path}")
                        shutil.copy2(dll_path, src_dll_path)
                    
                    if os.path.abspath(dll_path) != os.path.abspath(root_dll_path):
                        print(f"(+) Copying DLL to {root_dll_path}")
                        shutil.copy2(dll_path, root_dll_path)
                    
                    return True, dll_path
                    
            except Exception as e:
                print(f"Error loading DLL: {e}")
    
    print("No valid DLL found")
    return False, None

def create_spec_file(entry_script, icon_path, use_console=True):
    """Create a PyInstaller spec file for a one-file executable."""
    print(f"Creating PyInstaller spec file for {'Console' if use_console else 'GUI'} application...")
    
    # Determine output name based on console usage
    output_name = f"{APP_NAME}-CLI" if use_console else APP_NAME
    
    # Determine hidden imports based on GUI or CLI
    hidden_imports = []
    if not use_console: # GUI specific imports
        hidden_imports = [
            'PyQt6', 
            'PyQt6.sip', 
            'PyQt6.QtCore', 
            'PyQt6.QtGui', 
            'PyQt6.QtWidgets',
            'PyQt6.QtNetwork', 
            'PyQt6.QtSvg',
            # Add platform plugin explicitly if needed, often collected automatically
            # 'PyQt6.plugins.platforms.qwindows', 
        ]
        
    print(f"Using entry script: {entry_script}")
    print(f"Hidden imports: {hidden_imports}")

    # Determine datas, add Qt platform plugins for GUI builds
    datas = [
        ('assets/*', 'assets'),
    ]
    if not use_console:
        # Attempt to find PyQt6 plugins relative to the package location
        try:
            import PyQt6
            pyqt6_path = os.path.dirname(PyQt6.__file__)
            qt_plugins_path = os.path.join(pyqt6_path, 'Qt6', 'plugins')
            if os.path.exists(os.path.join(qt_plugins_path, 'platforms')):
                datas.append((os.path.join(qt_plugins_path, 'platforms'), 'PyQt6/Qt6/plugins/platforms'))
                print(f"(+) Added Qt platform plugins from: {qt_plugins_path}")
            if os.path.exists(os.path.join(qt_plugins_path, 'styles')):
                 datas.append((os.path.join(qt_plugins_path, 'styles'), 'PyQt6/Qt6/plugins/styles'))
                 print(f"(+) Added Qt style plugins from: {qt_plugins_path}")
        except ImportError:
            print("Warning: PyQt6 not found, cannot automatically add plugins.")
        except Exception as e:
            print(f"Warning: Error finding PyQt6 plugins: {e}")
            
    print(f"Datas: {datas}")

    # Use double backslashes for icon path in the spec file string
    safe_icon_path = icon_path.replace("\\\\", "\\\\\\\\").replace("\\", "\\\\") if icon_path else ''
    icon_arg = f"icon=['{safe_icon_path}']" if safe_icon_path else "icon=None" # Handle case where icon is None

    spec_content = f"""# -*- mode: python ; coding: utf-8 -*-

block_cipher = None

a = Analysis(
    ['{entry_script}'],
    pathex=[],
    binaries=[('truefa_crypto\\\\truefa_crypto.dll', '.')],
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

# Always build a one-file executable
exe = EXE(
    pyz,
    a.scripts,
    a.binaries + a.zipfiles + a.datas, # Include binaries and datas for one-file
    exclude_binaries=False, # Ensure binaries are included
    name='{output_name}',
    debug=False,
    bootloader_ignore_signals=False,
    strip=False,
    upx=True,
    upx_exclude=[],
    runtime_tmpdir=None,
    console={use_console},
    disable_windowed_traceback=False,
    argv_emulation=False,
    target_arch=None,
    codesign_identity=None,
    entitlements_file=None,
    {icon_arg},
    version='file_version_info.txt',
)

# No COLLECT block needed for one-file builds
"""
    
    # Write the spec file
    spec_file = f"{output_name}.spec"
    with open(spec_file, 'w') as f:
        f.write(spec_content)
    
    print(f"(+) Created spec file: {spec_file}")
    return spec_file

def create_version_file():
    """Create a version file for the Windows executable."""
    print("Creating version information file...")
    
    version_content = f"""
VSVersionInfo(
  ffi=FixedFileInfo(
    filevers=({APP_VERSION.replace('.', ', ')}, 0),
    prodvers=({APP_VERSION.replace('.', ', ')}, 0),
    mask=0x3f,
    flags=0x0,
    OS=0x40004,
    fileType=0x1,
    subtype=0x0,
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
)
"""
    
    with open('file_version_info.txt', 'w') as f:
        f.write(version_content)
    
    print("(+) Created version information file")

def configure_logging_settings(config_str):
    """
    Configure logging settings in the source code based on config string.
    
    Args:
        config_str (str): Configuration string in format "logging=enabled|disabled,debug=enabled|disabled"
        
    Returns:
        tuple: (logging_enabled, debug_enabled) boolean values
    """
    print(f"Configuring logging settings: {config_str}")
    
    # Default settings
    logging_enabled = True
    debug_enabled = False
    
    # Parse configuration string
    try:
        parts = config_str.split(',')
        for part in parts:
            key, value = part.strip().split('=')
            if key.lower() == 'logging':
                logging_enabled = value.lower() == 'enabled'
            elif key.lower() == 'debug':
                debug_enabled = value.lower() == 'enabled'
    except Exception as e:
        print(f"Error parsing logging configuration: {e}")
        print("Using default settings: logging=enabled, debug=disabled")
    
    print(f"Logging configuration: logging={'enabled' if logging_enabled else 'disabled'}, "
          f"debug={'enabled' if debug_enabled else 'disabled'}")
    
    # Create a temporary environment file that will be included in the build
    env_file = '_build_env.py'
    with open(env_file, 'w') as f:
        f.write(f"""# Build-time environment settings
# This file is generated during the build process and should not be edited manually
LOGGING_ENABLED = {logging_enabled}
DEBUG_ENABLED = {debug_enabled}
""")
    
    return logging_enabled, debug_enabled

def setup_environment(use_fallback, logging_enabled=True, debug_enabled=False):
    """Set up environment variables for the build."""
    # Set environment variables for the build process
    if use_fallback:
        os.environ["TRUEFA_USE_FALLBACK"] = "1"
        print("Using Python fallback implementation for cryptography")
    else:
        os.environ.pop("TRUEFA_USE_FALLBACK", None)
        print("Using native Rust cryptography implementation")
    
    # Set logging environment variables
    if logging_enabled:
        os.environ["TRUEFA_LOG"] = "1"
        print("File logging enabled")
    else:
        os.environ.pop("TRUEFA_LOG", None)
        print("File logging disabled")
    
    # Set debug environment variables
    if debug_enabled:
        os.environ["TRUEFA_DEBUG"] = "1" 
        print("Debug mode enabled")
    else:
        os.environ.pop("TRUEFA_DEBUG", None)
        print("Debug mode disabled")

def build_executable(spec_file):
    """Build the executable using PyInstaller."""
    print(f"Building executable from {spec_file}...")
    
    try:
        # Run PyInstaller
        result = subprocess.run(
            [sys.executable, "-m", "PyInstaller", spec_file, "--clean"],
            check=True,
            capture_output=True,
            text=True
        )
        
        print("(+) PyInstaller build completed successfully")
        return True
    except subprocess.CalledProcessError as e:
        print(f"Error building executable: {e}")
        print(f"Output: {e.stdout}")
        print(f"Error: {e.stderr}")
        return False

def create_nsis_script(icon_path, has_console=False):
    """Create an NSIS script for the installer."""
    print("Creating NSIS installer script...")
    
    # Determine base name for exe and installer file based on console flag
    exe_name = f"{APP_NAME}-CLI.exe" if has_console else f"{APP_NAME}.exe"
    installer_file_base = f"{APP_NAME}-CLI" if has_console else APP_NAME
    installer_outfile = f"dist\\{installer_file_base}_Setup_{APP_VERSION}.exe"
    
    # Ensure icon path uses backslashes for NSIS
    nsis_icon_path = icon_path.replace('/', '\\') if icon_path else ''

    nsis_script = f"""
; TrueFA Installer Script
Unicode True

!include "MUI2.nsh"
!include "FileFunc.nsh"

; Application information
!define PRODUCT_NAME "{APP_NAME}"
!define PRODUCT_VERSION "{APP_VERSION}"
!define PRODUCT_PUBLISHER "{AUTHOR}"
!define PRODUCT_WEB_SITE "{WEBSITE}"
!define PRODUCT_DIR_REGKEY "Software\\Microsoft\\Windows\\CurrentVersion\\App Paths\\{exe_name}"
!define PRODUCT_UNINST_KEY "Software\\Microsoft\\Windows\\CurrentVersion\\Uninstall\\${{PRODUCT_NAME}}"
!define PRODUCT_UNINST_ROOT_KEY "HKLM"

; MUI Settings
!define MUI_ABORTWARNING
!define MUI_ICON "{nsis_icon_path}"
!define MUI_UNICON "{nsis_icon_path}"

; Pages
!insertmacro MUI_PAGE_WELCOME
!insertmacro MUI_PAGE_LICENSE "LICENSE"
!insertmacro MUI_PAGE_DIRECTORY
!insertmacro MUI_PAGE_INSTFILES
!insertmacro MUI_PAGE_FINISH

!insertmacro MUI_UNPAGE_CONFIRM
!insertmacro MUI_UNPAGE_INSTFILES

; Language
!insertmacro MUI_LANGUAGE "English"

; Installer Information
Name "${{PRODUCT_NAME}}{' CLI' if has_console else ''} ${{PRODUCT_VERSION}}\"
OutFile "{installer_outfile.replace('\\', '\\\\')}\"
InstallDir "$PROGRAMFILES\\${{PRODUCT_NAME}}{' CLI' if has_console else ''}\"
InstallDirRegKey HKLM "${{PRODUCT_DIR_REGKEY}}" ""
ShowInstDetails show
ShowUnInstDetails show

Section "MainSection" SEC01
  SetOutPath "$INSTDIR"
  
  ; Add files (if one-file mode)
  File "dist\\{exe_name}"
  
  ; Create shortcuts
  CreateDirectory "$SMPROGRAMS\\${{PRODUCT_NAME}}"
  CreateShortCut "$SMPROGRAMS\\${{PRODUCT_NAME}}\\${{PRODUCT_NAME}}.lnk" "$INSTDIR\\{exe_name}"
  CreateShortCut "$DESKTOP\\${{PRODUCT_NAME}}.lnk" "$INSTDIR\\{exe_name}"
  
  ; Create uninstaller
  WriteUninstaller "$INSTDIR\\uninstall.exe"
  
  ; Register application
  WriteRegStr HKLM "${{PRODUCT_DIR_REGKEY}}" "" "$INSTDIR\\{exe_name}"
  WriteRegStr ${{PRODUCT_UNINST_ROOT_KEY}} "${{PRODUCT_UNINST_KEY}}" "DisplayName" "$(^Name)"
  WriteRegStr ${{PRODUCT_UNINST_ROOT_KEY}} "${{PRODUCT_UNINST_KEY}}" "UninstallString" "$INSTDIR\\uninstall.exe"
  WriteRegStr ${{PRODUCT_UNINST_ROOT_KEY}} "${{PRODUCT_UNINST_KEY}}" "DisplayIcon" "$INSTDIR\\{exe_name}"
  WriteRegStr ${{PRODUCT_UNINST_ROOT_KEY}} "${{PRODUCT_UNINST_KEY}}" "DisplayVersion" "${{PRODUCT_VERSION}}"
  WriteRegStr ${{PRODUCT_UNINST_ROOT_KEY}} "${{PRODUCT_UNINST_KEY}}" "URLInfoAbout" "${{PRODUCT_WEB_SITE}}"
  WriteRegStr ${{PRODUCT_UNINST_ROOT_KEY}} "${{PRODUCT_UNINST_KEY}}" "Publisher" "${{PRODUCT_PUBLISHER}}"
  
  ; Get installed size
  ${{GetSize}} "$INSTDIR" "/S=0K" $0 $1 $2
  IntFmt $0 "0x%08X" $0
  WriteRegDWORD ${{PRODUCT_UNINST_ROOT_KEY}} "${{PRODUCT_UNINST_KEY}}" "EstimatedSize" "$0"
SectionEnd

Section "Uninstall"
  ; Remove shortcuts
  Delete "$SMPROGRAMS\\${{PRODUCT_NAME}}\\${{PRODUCT_NAME}}.lnk"
  Delete "$DESKTOP\\${{PRODUCT_NAME}}.lnk"
  RMDir "$SMPROGRAMS\\${{PRODUCT_NAME}}"
  
  ; Remove files
  Delete "$INSTDIR\\{exe_name}"
  Delete "$INSTDIR\\uninstall.exe"
  
  ; Remove directories
  RMDir "$INSTDIR"
  
  ; Remove registry entries
  DeleteRegKey ${{PRODUCT_UNINST_ROOT_KEY}} "${{PRODUCT_UNINST_KEY}}"
  DeleteRegKey HKLM "${{PRODUCT_DIR_REGKEY}}"
SectionEnd
"""
    
    with open('installer.nsi', 'w') as f:
        f.write(nsis_script)
    
    print("(+) Created NSIS installer script")
    return 'installer.nsi'

def build_installer(nsis_script):
    """Build the installer using NSIS."""
    print("Building installer with NSIS...")
    
    try:
        # Find NSIS
        if os.name == 'nt':  # Windows
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
                print("NSIS not found. Please install it and try again.")
                return False
                
            # Run NSIS
            subprocess.run([nsis_exe, nsis_script], check=True)
            
            print("(+) NSIS installer build completed successfully")
            return True
        else:
            print("NSIS building is only supported on Windows.")
            return False
    except subprocess.CalledProcessError as e:
        print(f"Error building installer: {e}")
        return False

def main():
    """Main build process."""
    parser = setup_parser()
    args = parser.parse_args()

    # --- Clean directories if requested ---
    if args.clean:
        print("Cleaning build and dist directories...")
        build_dir = Path('build')
        dist_dir = Path('dist')
        if build_dir.exists():
            print(f"Removing {build_dir} ...")
            shutil.rmtree(build_dir)
        if dist_dir.exists():
            print(f"Removing {dist_dir} ...")
            shutil.rmtree(dist_dir)
        print("Cleaning complete.")

    # Determine build types based on flags or default to both if none specified
    build_portable = args.portable or not (args.portable or args.installer)
    should_build_installer = args.installer or not (args.portable or args.installer)
    # Set the internal flag if installer is being built
    args.is_installer_build = should_build_installer 

    print(f"Build configuration:")
    print(f"  Portable: {build_portable}")
    print(f"  Installer: {should_build_installer}")
    print(f"  GUI (No Console): {args.no_console}")
    print(f"  Force Fallback: {args.fallback}")
    print(f"  Logging Config: {args.config_logging}")

    if not check_requirements(check_nsis=args.is_installer_build):
        sys.exit(1)

    icon_path = check_icon()
    if not icon_path:
        # Decide whether to proceed without an icon or exit
        print("Proceeding without an application icon.")
        # sys.exit(1) # Optional: uncomment to make icon mandatory

    dll_ok, dll_path = check_dll()
    if not dll_ok and not args.fallback:
        print("Rust DLL check failed. Use --fallback to build without Rust backend or fix the DLL issue.")
        sys.exit(1)
    elif args.fallback:
        print("Forcing Python fallback implementation as requested.")
        # Ensure DLL is not included in the build if fallback is forced
        dll_path = None 
    elif dll_ok:
        print(f"(+) Using Rust DLL: {dll_path}")

    # Set up environment variables based on args
    logging_enabled, debug_enabled = configure_logging_settings(args.config_logging)
    setup_environment(args.fallback, logging_enabled, debug_enabled)

    # Determine entry script and console usage
    use_console = not args.no_console
    entry_script = 'main.py' if use_console else 'truefa_gui.py'
    
    print(f"Building {'Console' if use_console else 'GUI'} application from {entry_script}")

    # --- Build Portable Executable ---
    if build_portable:
        print("\n----- Building Portable Executable -----")
        spec_file_portable = create_spec_file(entry_script, icon_path, use_console=use_console)
        version_file = create_version_file() # Create version info file
        
        if not build_executable(spec_file_portable):
            print("Error building portable executable.")
            sys.exit(1)
            
        # Clean up intermediate files for portable build
        if spec_file_portable and os.path.exists(spec_file_portable): 
            os.remove(spec_file_portable)
        if version_file and os.path.exists(version_file): 
            os.remove(version_file) # Remove version file after use
        print("Portable executable build successful.")

    # --- Build Installer ---
    if should_build_installer:
        print("\n----- Building Installer -----")
        # Installer now also uses a one-file build
        spec_file_installer = create_spec_file(entry_script, icon_path, use_console=use_console) 
        version_file = create_version_file() # Recreate version info file if needed

        if not build_executable(spec_file_installer):
            print("Error building application for installer.")
            sys.exit(1)

        nsis_script_path = create_nsis_script(icon_path, has_console=use_console) # Pass console flag
        if not nsis_script_path or not build_installer(nsis_script_path):
            print("Error building installer.")
            sys.exit(1)

        # Clean up intermediate files for installer build
        if spec_file_installer and os.path.exists(spec_file_installer): 
            os.remove(spec_file_installer)
        if version_file and os.path.exists(version_file): 
            os.remove(version_file) # Remove version file
        if nsis_script_path and os.path.exists(nsis_script_path): 
            os.remove(nsis_script_path)
        print("Installer build successful.")

    # Optional: Clean up build directory unless needed for debugging
    # if os.path.exists('build'):
    #     shutil.rmtree('build')

    print("\nBuild process completed.")

if __name__ == "__main__":
    main() 
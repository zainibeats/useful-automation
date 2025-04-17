#!/usr/bin/env python3
"""
Build script for the Rust crypto module.

This script handles the compilation of the Rust cryptographic module and sets up
the necessary Python bindings. It performs the following steps:
1. Verifies Rust toolchain is installed
2. Builds the Rust library in release mode
3. Sets up proper Python module structure for the compiled library

Note: This script is for development only and is not needed in production.
"""

import os
import platform
import shutil
import subprocess
import sys
from pathlib import Path

def check_rust_installed():
    """Check if Rust toolchain is installed"""
    rust_path = os.path.expanduser("~/.cargo/bin/rustc")
    windows_rust_path = os.path.expanduser("~\\.cargo\\bin\\rustc.exe")
    
    if os.path.exists(rust_path) or os.path.exists(windows_rust_path):
        print("Rust is installed")
        return True
    else:
        # Try to run rustc directly
        try:
            subprocess.run(
                ["rustc", "--version"], 
                stdout=subprocess.PIPE, 
                stderr=subprocess.PIPE, 
                check=True
            )
            print("Rust is installed")
            return True
        except (subprocess.SubprocessError, FileNotFoundError):
            print("Error: Rust is not installed. Please install Rust from https://rustup.rs/")
            return False

def build_rust_module():
    """
    Build the Rust library module.
    
    Returns:
        bool: True if build successful, False otherwise
    """
    print("Building Rust module...")
    
    # Get the appropriate cargo path
    cargo_path = "cargo"
    windows_cargo_path = os.path.expanduser("~\\.cargo\\bin\\cargo.exe")
    if os.path.exists(windows_cargo_path):
        cargo_path = windows_cargo_path
    
    try:
        # Change to the directory containing the Rust code
        os.chdir("rust_crypto")
        
        # Run cargo build in release mode
        build_cmd = [cargo_path, "build", "--release"]
        result = subprocess.run(
            build_cmd,
            stdout=subprocess.PIPE,
            stderr=subprocess.PIPE,
            text=True
        )
        
        if result.returncode != 0:
            print(f"Cargo build failed:\n{result.stderr}")
            return False
        
        # Verify the DLL was created and contains the expected functions
        dll_path = os.path.join("target", "release", "truefa_crypto.dll")
        if os.path.exists(dll_path):
            print(f"DLL built successfully at: {os.path.abspath(dll_path)}")
            print("Checking exported functions...")
            try:
                # Try to load the DLL using ctypes
                import ctypes
                lib = ctypes.CDLL(dll_path)
                
                # Check for key functions
                required_functions = [
                    'c_secure_random_bytes',
                    'c_create_vault',
                    'c_unlock_vault',
                    'c_is_vault_unlocked',
                    'c_lock_vault',
                    'c_vault_exists',
                    'c_generate_salt',
                    'c_derive_master_key',
                    'c_encrypt_master_key',
                    'c_decrypt_master_key',
                    'c_create_secure_string',
                    'c_verify_signature'
                ]
                
                missing = []
                for func in required_functions:
                    if not hasattr(lib, func):
                        missing.append(func)
                
                if missing:
                    print(f"WARNING: The following functions are missing from the DLL: {', '.join(missing)}")
                    print("This may cause issues when loading the library at runtime.")
                else:
                    print("All required functions are present in the DLL.")
            except Exception as e:
                print(f"Error checking DLL: {e}")
        else:
            print(f"WARNING: DLL not found at expected location: {os.path.abspath(dll_path)}")
            
        print("Rust module built successfully")
        return True
    except Exception as e:
        print(f"Error building Rust module: {e}")
        return False
    finally:
        # Return to the original directory
        os.chdir("..")

if __name__ == "__main__":
    if not check_rust_installed():
        print("Build failed")
        sys.exit(1)
    
    if build_rust_module():
        # Run the build_module.py script to create a proper Python module
        print("Building Python module...")
        try:
            result = subprocess.run(
                [sys.executable, "build_module.py"], 
                stdout=subprocess.PIPE, 
                stderr=subprocess.PIPE,
                text=True
            )
            if result.returncode != 0:
                print(f"Failed to build Python module:\n{result.stderr}")
                print("Build failed")
                sys.exit(1)
            print("Python module built successfully")
            print("Build completed successfully")
        except Exception as e:
            print(f"Error building Python module: {e}")
            print("Build failed")
            sys.exit(1)
    else:
        print("Build failed")
        sys.exit(1)

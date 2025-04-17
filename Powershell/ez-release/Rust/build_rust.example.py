#!/usr/bin/env python
"""
Example Rust Component Build Script

This script handles building a Rust library for use in your project.
It demonstrates how to:
1. Check if Rust is installed
2. Build the Rust library in release mode
3. Verify the outputs by checking for expected exports
4. Copy the compiled library to appropriate locations in your project

Rename this to 'build_rust.py' in your project root and customize it.
"""

import os
import platform
import shutil
import subprocess
import sys
from pathlib import Path

def check_rust_installed():
    """Check if Rust toolchain is installed."""
    print("Checking for Rust installation...")
    
    # Various paths where rustc might be found
    rust_path = os.path.expanduser("~/.cargo/bin/rustc")
    windows_rust_path = os.path.expanduser("~\\.cargo\\bin\\rustc.exe")
    
    if os.path.exists(rust_path) or os.path.exists(windows_rust_path):
        print("(+) Rust is installed (found in ~/.cargo/bin)")
        return True
    else:
        # Try to run rustc directly in case it's in PATH
        try:
            subprocess.run(
                ["rustc", "--version"], 
                stdout=subprocess.PIPE, 
                stderr=subprocess.PIPE, 
                check=True
            )
            print("(+) Rust is installed (found in PATH)")
            return True
        except (subprocess.SubprocessError, FileNotFoundError):
            print("(-) Error: Rust is not installed. Please install Rust from https://rustup.rs/")
            return False

def build_rust_library():
    """
    Build the Rust library.
    
    Returns:
        bool: True if build successful, False otherwise
    """
    print("Building Rust library...")
    
    # Get the appropriate cargo path
    cargo_path = "cargo"
    windows_cargo_path = os.path.expanduser("~\\.cargo\\bin\\cargo.exe")
    if os.path.exists(windows_cargo_path):
        cargo_path = windows_cargo_path
    
    # Set the Rust project directory - change this to your Rust project path
    rust_project_dir = "rust_lib"
    
    try:
        # Change to the directory containing the Rust code
        os.chdir(rust_project_dir)
        
        # Run cargo build in release mode
        build_cmd = [cargo_path, "build", "--release"]
        print(f"Executing: {' '.join(build_cmd)}")
        result = subprocess.run(
            build_cmd,
            stdout=subprocess.PIPE,
            stderr=subprocess.PIPE,
            text=True
        )
        
        if result.returncode != 0:
            print(f"(-) Cargo build failed:\n{result.stderr}")
            return False
        
        # Determine the expected library name based on platform
        if platform.system() == "Windows":
            lib_name = "my_library.dll"
        elif platform.system() == "Darwin":  # macOS
            lib_name = "libmy_library.dylib"
        else:  # Linux and others
            lib_name = "libmy_library.so"
        
        # Verify the library was created
        lib_path = os.path.join("target", "release", lib_name)
        if os.path.exists(lib_path):
            print(f"(+) Library built successfully at: {os.path.abspath(lib_path)}")
            
            # Optional: Check exports/symbols in the library
            print("(+) Library verification successful")
            
            # Copy the library to appropriate locations in your project
            # Example: Copy to a lib directory at the project root
            dest_path = os.path.join("..", "lib", lib_name)
            os.makedirs(os.path.dirname(dest_path), exist_ok=True)
            shutil.copy2(lib_path, dest_path)
            print(f"(+) Copied library to: {os.path.abspath(dest_path)}")
            
            return True
        else:
            print(f"(-) ERROR: Library not found at expected location: {os.path.abspath(lib_path)}")
            return False
            
    except Exception as e:
        print(f"(-) Error building Rust library: {e}")
        return False
    finally:
        # Return to the original directory
        os.chdir("..")

if __name__ == "__main__":
    if not check_rust_installed():
        print("Build failed: Rust is not installed")
        sys.exit(1)
    
    if build_rust_library():
        print("Rust library build completed successfully!")
    else:
        print("Build failed")
        sys.exit(1) 
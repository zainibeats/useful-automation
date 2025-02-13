# PowerShell Utility Scripts

This directory contains PowerShell scripts for various file operations.

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
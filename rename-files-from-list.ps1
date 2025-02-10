# Enter the full path to your names text file.
$namesFilePath = "C:\Path\To\names.txt"

# Enter the full path to the folder containing the GIF files.
$gifFolderPath = "C:\Path\To\Gifs"

# Read names from the text file. Each line is expected to be in the format: Name,rarity.
# This splits each line at the comma and keeps only the first part (the name), trimming any extra spaces.
$names = Get-Content $namesFilePath | ForEach-Object {
    ($_ -split ",")[0].Trim()
}

# Get a list of .gif files in the specified folder.
# The files are sorted by name so that the order aligns with the text file.
$gifFiles = Get-ChildItem -Path $gifFolderPath -Filter *.gif | Sort-Object Name

# Optional: Check if the number of GIF files matches the number of names.
if ($gifFiles.Count -ne $names.Count) {
    Write-Error "Mismatch: There are $($gifFiles.Count) GIF files but $($names.Count) names in the text file."
    exit
}

# Loop over each file and rename it to "Name.gif" using the corresponding name from the list.
for ($i = 0; $i -lt $gifFiles.Count; $i++) {
    # Construct the new file name while preserving the .gif extension.
    $newName = "$($names[$i]).gif"
    
    # Rename the file.
    Rename-Item -Path $gifFiles[$i].FullName -NewName $newName
}

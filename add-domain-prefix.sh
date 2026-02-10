#!/bin/bash

# Add "domain:" prefix to every non-empty line in all txt files in the specified folder
# Usage: ./add-domain-prefix.sh <folder_path>

if [ -z "$1" ]; then
    echo "Error: Please provide a folder path as input parameter"
    echo "Usage: $0 <folder_path>"
    exit 1
fi

FOLDER="$1"

# Check if folder exists
if [ ! -d "$FOLDER" ]; then
    echo "Error: Folder '$FOLDER' does not exist"
    exit 1
fi

# Iterate over all txt files in the folder
for file in "$FOLDER"/*.txt; do
    if [ -f "$file" ]; then
        echo "Processing: $file"
        
        # Add "domain:" prefix to non-empty lines and save to a temp file
        sed '/^[[:space:]]*$/!s/^/domain:/' "$file" > "$file.tmp"
        
        # Replace original file with the modified version
        mv "$file.tmp" "$file"
        
        echo "  ✓ Completed"
    fi
done

echo "All txt files in '$FOLDER' have been processed"

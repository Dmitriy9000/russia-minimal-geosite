#!/bin/bash
set -euo pipefail

# Add "domain:" prefix to every non-empty line in all txt files in the specified folder
# Usage: ./add-domain-prefix.sh <folder_path>

if [ "$#" -ne 1 ]; then
    echo "Usage: $0 <folder_path>" >&2
    exit 1
fi

FOLDER="$1"
tmp=""
trap 'if [ -n "$tmp" ]; then rm -f "$tmp"; fi' EXIT

# Check if folder exists
if [ ! -d "$FOLDER" ]; then
    echo "Error: Folder '$FOLDER' does not exist" >&2
    exit 1
fi

# Iterate over all txt files in the folder
shopt -s nullglob
for file in "$FOLDER"/*.txt; do
    if [ -f "$file" ]; then
        echo "Processing: $file"

        tmp=$(mktemp "$file.tmp.XXXXXX")
        cp -p "$file" "$tmp"
        # Add "domain:" prefix only to non-empty lines that do NOT already
        # start with a prefix (a token followed by a colon), and save to a temp file.
        awk '
        /^[[:space:]]*$/ { print; next }
        /^[[:space:]]*[^[:space:]]+:/ { print; next }
        { print "domain:" $0 }
        ' "$file" > "$tmp"

        # Replace original file with the modified version
        mv "$tmp" "$file"
        tmp=""

        echo "  ✓ Completed"
    fi
done

echo "All txt files in '$FOLDER' have been processed"

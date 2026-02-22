#!/usr/bin/env bash

# Append lines from files in ./enrich to corresponding files in ./categories
# Usage: ./append-enrich-to-categories.sh [enrich_dir] [categories_dir]

set -euo pipefail

ENRICH_DIR="./enrich"
CATEGORIES_DIR="./categories"

if [ $# -ge 1 ]; then
  ENRICH_DIR="$1"
fi
if [ $# -ge 2 ]; then
  CATEGORIES_DIR="$2"
fi

if [ ! -d "$ENRICH_DIR" ]; then
  echo "Error: enrich directory '$ENRICH_DIR' does not exist"
  exit 1
fi

if [ ! -d "$CATEGORIES_DIR" ]; then
  echo "Warning: categories directory '$CATEGORIES_DIR' does not exist — it will be created"
  mkdir -p "$CATEGORIES_DIR"
fi

echo "Scanning '$ENRICH_DIR' and appending to '$CATEGORIES_DIR'"

shopt -s nullglob
for src in "$ENRICH_DIR"/*; do
  [ -f "$src" ] || continue
  base=$(basename "$src")
  dst="$CATEGORIES_DIR/$base"

  echo "Processing: $base -> $dst"

  # Ensure destination exists; if not, copy the whole file
  if [ ! -f "$dst" ]; then
    # Copy only non-empty lines
    grep -v -E '^[[:space:]]*$' "$src" > "$dst" || true
    echo "  • created $dst"
    continue
  fi

  # Append non-empty lines from src that are not already present in dst
  # Use fixed-string, whole-line matching to avoid partial matches
  # Filter out empty lines first
  new_lines_tmp=$(mktemp)
  grep -v -E '^[[:space:]]*$' "$src" > "$new_lines_tmp" || true

  if [ -s "$new_lines_tmp" ]; then
    # Determine lines not present in destination
    grep -F -x -v -f "$dst" "$new_lines_tmp" >> "$dst" || true
    echo "  • appended unique lines to $dst"
  else
    echo "  • no non-empty lines to append"
  fi

  rm -f "$new_lines_tmp"
done

echo "Done."

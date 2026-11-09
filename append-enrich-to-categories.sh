#!/usr/bin/env bash

# Append lines from files in ./enrich to corresponding files in ./categories
# Usage: ./append-enrich-to-categories.sh [enrich_dir] [categories_dir]

set -euo pipefail

ENRICH_DIR="./enrich"
CATEGORIES_DIR="./categories"
tmp=""
trap 'if [ -n "$tmp" ]; then rm -f "$tmp"; fi' EXIT

if [ "$#" -gt 2 ]; then
  echo "Usage: $0 [enrich_dir] [categories_dir]" >&2
  exit 1
fi

if [ "$#" -ge 1 ]; then
  ENRICH_DIR="$1"
fi
if [ "$#" -ge 2 ]; then
  CATEGORIES_DIR="$2"
fi

if [ ! -d "$ENRICH_DIR" ]; then
  echo "Error: enrich directory '$ENRICH_DIR' does not exist" >&2
  exit 1
fi

if [ ! -d "$CATEGORIES_DIR" ]; then
  echo "Warning: categories directory '$CATEGORIES_DIR' does not exist — it will be created" >&2
  mkdir -p "$CATEGORIES_DIR"
fi

echo "Scanning '$ENRICH_DIR' and appending to '$CATEGORIES_DIR'"

shopt -s nullglob
for src in "$ENRICH_DIR"/*; do
  [ -f "$src" ] || continue
  base=$(basename "$src")
  dst="$CATEGORIES_DIR/$base"

  echo "Processing: $base -> $dst"

  tmp=$(mktemp "$CATEGORIES_DIR/.${base}.tmp.XXXXXX")
  if [ -f "$dst" ]; then
    cp -p "$dst" "$tmp"
    awk '
      FILENAME == ARGV[1] {
        if ($0 !~ /^[[:space:]]*$/) seen[$0] = 1
        print
        next
      }
      $0 !~ /^[[:space:]]*$/ && !seen[$0] {
        seen[$0] = 1
        print
      }
    ' "$dst" "$src" > "$tmp"
  else
    chmod 644 "$tmp"
    awk '$0 !~ /^[[:space:]]*$/ && !seen[$0]++' "$src" > "$tmp"
  fi

  mv "$tmp" "$dst"
  tmp=""
  echo "  • updated $dst"
done

echo "Done."

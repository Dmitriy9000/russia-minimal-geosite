#!/bin/bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
cd "$SCRIPT_DIR"

URL="https://github.com/runetfreedom/russia-blocked-geosite/releases/latest/download/geosite.dat"

fail() {
  echo "Error: $*" >&2
  exit 1
}

command -v curl >/dev/null 2>&1 || fail "curl is required to download the source geosite.dat"

V2DAT_BIN=""
for candidate in "$SCRIPT_DIR/v2dat" "$SCRIPT_DIR/../v2dat/v2dat"; do
  if [ -x "$candidate" ]; then
    V2DAT_BIN="$candidate"
    break
  fi
done
if [ -z "$V2DAT_BIN" ]; then
  V2DAT_BIN="$(command -v v2dat || true)"
fi
[ -n "$V2DAT_BIN" ] || fail "v2dat was not found. Put it in the repository root, ../v2dat/v2dat, or PATH"
[ -x "$V2DAT_BIN" ] || fail "v2dat is not executable: $V2DAT_BIN"

DOMAIN_LIST_COMMUNITY_BIN=""
if [ -x "$SCRIPT_DIR/domain-list-community" ]; then
  DOMAIN_LIST_COMMUNITY_BIN="$SCRIPT_DIR/domain-list-community"
else
  DOMAIN_LIST_COMMUNITY_BIN="$(command -v domain-list-community || true)"
fi
if [ -z "$DOMAIN_LIST_COMMUNITY_BIN" ]; then
  cat >&2 <<EOF
Error: domain-list-community was not found.

Install Go, then build it from the upstream repository:
  git clone https://github.com/v2fly/domain-list-community.git
  cd domain-list-community
  go build -o "$SCRIPT_DIR/domain-list-community" ./

This puts the executable in this project's repository root. Then return here
and run ./minimize.sh again. Alternatively, put the executable on your PATH.
EOF
  exit 1
fi
[ -x "$DOMAIN_LIST_COMMUNITY_BIN" ] || fail "domain-list-community is not executable: $DOMAIN_LIST_COMMUNITY_BIN"

for helper in append-enrich-to-categories.sh add-domain-prefix.sh; do
  [ -f "$SCRIPT_DIR/$helper" ] || fail "required helper script is missing: $SCRIPT_DIR/$helper"
done
[ -w "$SCRIPT_DIR" ] || fail "repository directory is not writable: $SCRIPT_DIR"
for name in categories extracted; do
  if [ -e "$SCRIPT_DIR/$name" ] && [ ! -w "$SCRIPT_DIR/$name" ]; then
    fail "$SCRIPT_DIR/$name is not writable by the current user. If it was created by running this script with sudo, fix ownership from the repository root with: sudo chown -R \"$(id -un)\" $name"
  fi
done

WORK_DIR="$(mktemp -d "$SCRIPT_DIR/.minimize.XXXXXX")" || fail "could not create a temporary build directory"
BACKUP_SUFFIX="${WORK_DIR##*/}"
COMMITTED=false

rollback_directories() {
  for name in categories extracted geosite.dat; do
    backup="$SCRIPT_DIR/.$name.backup.$BACKUP_SUFFIX"
    if [ -e "$backup" ]; then
      rm -rf "$SCRIPT_DIR/$name"
      mv "$backup" "$SCRIPT_DIR/$name" || echo "Error: could not restore $name" >&2
    elif [ "$name" != geosite.dat ] && [ ! -e "$WORK_DIR/$name" ]; then
      rm -rf "$SCRIPT_DIR/$name"
    fi
  done
}

cleanup() {
  status=$?
  trap - EXIT
  if [ "$COMMITTED" != true ]; then
    rollback_directories
  else
    for name in categories extracted geosite.dat; do
      rm -rf "$SCRIPT_DIR/.$name.backup.$BACKUP_SUFFIX"
    done
  fi
  rm -rf "$WORK_DIR"
  exit "$status"
}
trap cleanup EXIT

mkdir -p "$WORK_DIR/extracted" "$WORK_DIR/categories"

echo "=== Downloading latest geosite.dat..."
curl --fail --location --show-error --output "$WORK_DIR/geosite.dat" "$URL"
[ -s "$WORK_DIR/geosite.dat" ] || fail "download succeeded but source geosite.dat is missing or empty"

echo "=== Extracting geosite.dat sections..."
"$V2DAT_BIN" unpack geosite -o "$WORK_DIR/extracted" "$WORK_DIR/geosite.dat"

echo "=== Copying only important sections"
REQUIRED_CATEGORIES=(
  ru-blocked
  ru-available-only-inside
  category-ads-all
  apple
  microsoft
  steam
  category-games
  category-ru
  reddit
  'category-ai-!cn'
  'category-ai-chat-!cn'
  category-cryptocurrency
  cursor
  forza
  piratebay
  roblox
  rutracker
)
for category in "${REQUIRED_CATEGORIES[@]}"; do
  extracted_file="$WORK_DIR/extracted/geosite_${category}.txt"
  [ -f "$extracted_file" ] || fail "upstream geosite.dat is missing required category '$category' (expected $extracted_file)"
  cp "$extracted_file" "$WORK_DIR/categories/$category"
done

echo "=== Enriching with extra domains"
bash "$SCRIPT_DIR/append-enrich-to-categories.sh" "$SCRIPT_DIR/enrich" "$WORK_DIR/categories"

echo "=== Adding domain prefix"
bash "$SCRIPT_DIR/add-domain-prefix.sh" "$WORK_DIR/categories"

echo "=== Building .dat file"
"$DOMAIN_LIST_COMMUNITY_BIN" --datapath="$WORK_DIR/categories" --outputdir="$WORK_DIR"
[ -s "$WORK_DIR/dlc.dat" ] || fail "domain-list-community did not create a non-empty dlc.dat"

echo "=== Publishing generated files"
for name in categories extracted; do
  backup="$SCRIPT_DIR/.$name.backup.$BACKUP_SUFFIX"
  if [ -e "$SCRIPT_DIR/$name" ]; then
    mv "$SCRIPT_DIR/$name" "$backup"
  fi
  mv "$WORK_DIR/$name" "$SCRIPT_DIR/$name"
done
if [ -e "$SCRIPT_DIR/geosite.dat" ]; then
  mv "$SCRIPT_DIR/geosite.dat" "$SCRIPT_DIR/.geosite.dat.backup.$BACKUP_SUFFIX"
fi
mv "$WORK_DIR/dlc.dat" "$SCRIPT_DIR/geosite.dat"
COMMITTED=true

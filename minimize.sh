#!/bin/bash

# Download geosite.dat from GitHub releases
URL="https://github.com/runetfreedom/russia-blocked-geosite/releases/latest/download/geosite.dat"
OUTPUT_FILE="geosite.dat"

echo "=== Clean up"
rm -rf ./extracted
rm -rf ./categories
mkdir extracted
mkdir categories
rm ./dlc.dat
rm ./geosite.dat

echo "=== Downloading latest geosite.dat..."
curl -L -o "$OUTPUT_FILE" "$URL"

echo "=== Extracting geosite.dat sections..."
./v2dat unpack geosite -o extracted geosite.dat
rm ./geosite.dat

echo "=== Copying only important to us sections"
cp ./extracted/geosite_ru-blocked.txt ./categories/ru-blocked
cp ./extracted/geosite_ru-available-only-inside.txt ./categories/ru-available-only-inside
cp ./extracted/geosite_category-ads-all.txt ./categories/category-ads-all

echo "=== Enriching with extra domains"
./append-enrich-to-categories.sh

echo "=== Adding domain prefix"
./add-domain-prefix.sh ./categories

echo "=== Building .dat file"
./domain-list-community --datapath=./categories

echo "=== Renaming dlc.dat to geosite.dat"
mv dlc.dat geosite.dat
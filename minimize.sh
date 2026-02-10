#!/bin/bash

# Download geosite.dat from GitHub releases
URL="https://github.com/runetfreedom/russia-blocked-geosite/releases/latest/download/geosite.dat"
OUTPUT_FILE="geosite.dat"

echo "Clean up"
#rm -rf ./extracted
#mkdir extracted

echo "Downloading latest geosite.dat..."
curl -L -o "$OUTPUT_FILE" "$URL"

echo "Extracting geosite.dat sections..."
./v2dat unpack geosite -o extracted geosite.dat

echo "Copying only important to us sections"
cp ./extracted/geosite_ru-blocked.txt ./categories/ru-blocked.txt
cp ./extracted/geosite_ru-available-only-inside.txt ./categories/ru-available-only-inside.txt
cp ./extracted/geosite_category-ads-all.txt ./categories/category-ads-all.txt

#echo "Enriching with extra domains"
# TODO

echo "Adding domain prefix"
./add-domain-prefix.sh ./categories

echo "Building .dat file"

go run ./ --datapath=../russia-minimal-geosite/categories
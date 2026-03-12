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
cp ./extracted/geosite_apple.txt ./categories/apple
cp ./extracted/geosite_microsoft.txt ./categories/microsoft
cp ./extracted/geosite_steam.txt ./categories/steam
cp ./extracted/geosite_category-games.txt ./categories/category-games
cp ./extracted/geosite_category-ru.txt ./categories/category-ru
cp ./extracted/geosite_reddit.txt ./categories/reddit
cp ./extracted/geosite_category-ai-!cn.txt ./categories/category-ai-!cn
cp ./extracted/geosite_category-ai-chat-!cn.txt ./categories/category-ai-chat-!cn
cp ./extracted/geosite_category-cryptocurrency.txt ./categories/category-cryptocurrency
cp ./extracted/geosite_cursor.txt ./categories/cursor
cp ./extracted/geosite_forza.txt ./categories/forza
cp ./extracted/geosite_piratebay.txt ./categories/piratebay
cp ./extracted/geosite_roblox.txt ./categories/roblox
cp ./extracted/geosite_rutracker.txt ./categories/rutracker

echo "=== Enriching with extra domains"
./append-enrich-to-categories.sh

echo "=== Adding domain prefix"
./add-domain-prefix.sh ./categories

echo "=== Building .dat file"
./domain-list-community --datapath=./categories

echo "=== Renaming dlc.dat to geosite.dat"
mv dlc.dat geosite.dat
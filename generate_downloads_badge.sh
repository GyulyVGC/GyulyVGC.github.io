#!/bin/bash

GITHUB_COUNT=$(curl -s https://api.github.com/repos/gyulyvgc/sniffnet/releases | grep -E 'download_count' | cut '-d:' -f 2 | sed 's/,//g' | paste -s -d+ - | bc)
echo "GITHUB_COUNT: $GITHUB_COUNT"

CRATES_COUNT=$(curl -s https://crates.io/api/v1/crates/sniffnet | grep -E -o '"downloads":[0-9]*' | head -1 | cut '-d:' -f 2)
echo "CRATES_COUNT: $CRATES_COUNT"

HOMEBREW_COUNT=$(curl -s https://github.com/Homebrew/homebrew-core/pkgs/container/core%2Fsniffnet | grep -A1 "Total downloads" | grep -o 'title="[0-9]*"' | cut '-d=' -f 2 | sed 's/"//g')
echo "HOMEBREW_COUNT: $HOMEBREW_COUNT"

GHCR_COUNT=$(curl -s https://github.com/gyulyvgc/sniffnet/pkgs/container/sniffnet | grep -A1 "Total downloads" | grep -o 'title="[0-9]*"' | cut '-d=' -f 2 | sed 's/"//g')
echo "GHCR_COUNT: $GHCR_COUNT"

TOTAL_DOWNLOADS=$((GITHUB_COUNT+CRATES_COUNT+HOMEBREW_COUNT+GHCR_COUNT))
echo "TOTAL_DOWNLOADS: $TOTAL_DOWNLOADS"

PREVIOUS_DOWNLOADS=$(cat download_count.txt)
echo "PREVIOUS_DOWNLOADS: $PREVIOUS_DOWNLOADS"

if [ $TOTAL_DOWNLOADS -lt $PREVIOUS_DOWNLOADS ]; then
    echo "Error: Total downloads is less than previous downloads"
    exit 1
fi

echo -n $TOTAL_DOWNLOADS > download_count.txt

DOWNLOADS_STRING=$((TOTAL_DOWNLOADS/1000))k

curl -o assets/img/downloads_badge.svg https://img.shields.io/badge/Downloads-$DOWNLOADS_STRING-blue?style=for-the-badge

exit 0
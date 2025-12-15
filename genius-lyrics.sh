#!/bin/bash

# Get now playing info via AppleScript
output=$(osascript \
    -e 'use framework "AppKit"' \
    -e 'set MediaRemote to current application'\''s NSBundle'\''s bundleWithPath:"/System/Library/PrivateFrameworks/MediaRemote.framework"' \
    -e 'MediaRemote'\''s load()' \
    -e 'set MRNowPlayingRequest to current application'\''s NSClassFromString("MRNowPlayingRequest")' \
    -e 'set appName to MRNowPlayingRequest'\''s localNowPlayingPlayerPath()'\''s client()'\''s displayName()' \
    -e 'set infoDict to MRNowPlayingRequest'\''s localNowPlayingItem()'\''s nowPlayingInfo()' \
    -e 'set theTitle to (infoDict'\''s valueForKey:"kMRMediaRemoteNowPlayingInfoTitle") as text' \
    -e 'set theArtist to (infoDict'\''s valueForKey:"kMRMediaRemoteNowPlayingInfoArtist") as text' \
    -e 'return theTitle & " — " & theArtist')

# Parse
title=$(echo "$output" | sed 's/ — .*//')
artist=$(echo "$output" | sed 's/.* — //')

# If artist ends in VEVO, it's probably YouTube - try to parse artist from title
if [[ "$artist" == *VEVO ]]; then
    # Title is usually "Artist - Song"
    artist=$(echo "$title" | sed 's/ *-.*//')
    title=$(echo "$title" | sed 's/.*- *//')
fi

echo "Artist: $artist"
echo "Title: $title"

# Clean up
clean_title=$(echo "$title" | sed -E 's/ *\(.*\)//g; s/ *\[.*\]//g; s/ *-.*[0-9]{4}.*//g')
clean_artist=$(echo "$artist" | sed -E 's/ *\(.*\)//g; s/ *—.*//g; s/ *-.*//g')

# Convert to URL-friendly format
url_title=$(echo "$clean_title" | tr '[:upper:]' '[:lower:]' | sed -E 's/[^a-z0-9 -]//g; s/ +/-/g; s/-+/-/g')
url_artist=$(echo "$clean_artist" | tr '[:upper:]' '[:lower:]' | sed -E 's/[^a-z0-9 -]//g; s/ +/-/g; s/-+/-/g')

direct_url="https://genius.com/${url_artist}-${url_title}-lyrics"
query=$(python3 -c "import urllib.parse; print(urllib.parse.quote('$clean_artist $clean_title'))")

echo "Checking: $direct_url"

# Fetch first 5KB and check for 404 content
response=$(curl -s -L -m 5 -r 0-5000 -A "Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/537.36" "$direct_url")

if echo "$response" | grep -qi "Burrr\|Page not found"; then
    echo "Direct URL not found, opening search..."
    open "https://genius.com/search?q=$query"
else
    echo "Opening direct URL..."
    open "$direct_url"
fi
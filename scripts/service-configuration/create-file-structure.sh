#!/bin/bash

# This script creates the recommended directory structure for storing media 
# as outlined by the guide at https://trash-guides.info/Hardlinks/How-to-setup-for/Docker/#folder-structure

# Check if a username has been provided
if [ -z "$1" ]; then
    echo "Usage: $0 username"
    exit 1
fi

# Username provided as the first command line argument
USERNAME="$1"

# Base directory
BASE_DIR="/data"

# Subdirectories under /data
SUBDIRS=("torrents" "usenet" "media")

# Subcategories
CATEGORIES=("books" "movies" "music" "tv")

# Create subdirectories and their subcategories
for dir in "${SUBDIRS[@]}"; do
    # Special case for usenet to include incomplete and complete
    if [ "$dir" = "usenet" ]; then
        mkdir -p "$BASE_DIR/$dir/incomplete"
        for category in "${CATEGORIES[@]}"; do
            mkdir -p "$BASE_DIR/$dir/complete/$category"
        done
    else
        for category in "${CATEGORIES[@]}"; do
            mkdir -p "$BASE_DIR/$dir/$category"
        done
    fi
done

# Update the ownership and permissions recursively
sudo chown -R "$USERNAME:$USERNAME" "$BASE_DIR"
sudo chmod -R a=,a+rX,u+w,g+w "$BASE_DIR"

echo "Directory structure created and permissions set for user $USERNAME under $BASE_DIR."


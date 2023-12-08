#!/bin/bash

# This script creates the recommended directory structure for storing media
# as outlined by the guide at https://trash-guides.info/Hardlinks/How-to-setup-for/Docker/#folder-structure

SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )"
BUILDARR_CONFIG_FILE="$SCRIPT_DIR/../../buildarr/buildarr.yml"
RECYCLARR_SECRETS_FILE="$SCRIPT_DIR/../../recyclarr/secrets.yml"
# Load environment variables from .env file
if [ -f "$SCRIPT_DIR/../../.env" ]; then
    source "$SCRIPT_DIR/../../.env"
else
    # Create the .env file by copying the .env.example file from the same directory
    cp "$SCRIPT_DIR/../../.env.example" "$SCRIPT_DIR/../../.env"
fi

# Check if a username has been provided
if [ -z "$1" ]; then
    echo "Usage: $0 username"
    exit 1
fi

# Username provided as the first command line argument
USERNAME="$1"

# Base directory
BASE_DIR="$DATA_ROOT"

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
# Create the buildarr.yml file if it doesnt exist.
# If it doesnt exist, then create it by copying the buildarr.example.yml file from the same directory
if [ ! -f "$BUILDARR_CONFIG_FILE" ]; then
		cp "$SCRIPT_DIR/../../buildarr/buildarr.example.yml" "$BUILDARR_CONFIG_FILE"
		echo "Created $BUILDARR_CONFIG_FILE"
fi

# Create the secrets.yml file if it doesnt exist.
# If it doesnt exist, then create it by copying the secrets.example.yml file from the same directory
if [ ! -f "$RECYCLARR_SECRETS_FILE" ]; then
		cp "$SCRIPT_DIR/../../recyclarr/secrets.example.yml" "$RECYCLARR_SECRETS_FILE"
		echo "Created $RECYCLARR_SECRETS_FILE"
fi


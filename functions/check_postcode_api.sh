#!/bin/bash

# Get the absolute path of the current script directory
SCRIPT_DIR="$(realpath "$(dirname "$0")")"

# Source functions from the current full path
source "$SCRIPT_DIR/functions.sh"

# Fetch current version from config
CURRENT_VERSION=$(get_version "companiesapi")
echo "Current version of companiesapi: $CURRENT_VERSION"

# Get latest version from GitHub
echo "Fetching latest version from GitHub..."
LATEST_VERSION=$(curl -s https://api.github.com/repos/ideal-postcodes/postcodes.io/releases/latest | jq -r .tag_name)
echo "Latest version from GitHub: $LATEST_VERSION"

# Log file
LOG_FILE="$SCRIPT_DIR/update_log.txt"

# Compare versions
if [[ "$CURRENT_VERSION" == "$LATEST_VERSION" ]]; then
    echo "$(date): No new version. Current version: $CURRENT_VERSION" | tee -a "$LOG_FILE"
else
    echo "$(date): New version found! Updating to $LATEST_VERSION" | tee -a "$LOG_FILE"

    # Update version
   #  set_version "companiesapi" "$LATEST_VERSION"

    echo "Updated companiesapi to version: $LATEST_VERSION"
fi

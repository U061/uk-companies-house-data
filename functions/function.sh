#!/bin/bash

# Get the absolute path of the current script directory
SCRIPT_DIR="$(realpath "$(dirname "$0")")"

# Source the function.sh file to import the get_version function
source "$SCRIPT_DIR/config.sh"

# Function to get the version of a given key (e.g., postcodeapi)
get_version() {
    local key=$1
    eval "echo \$${key}"
}

# Function to set the version of a given key
set_version() {
    local key=$1
    local version=$2

    # If key exists, update it; if not, add it.
    if grep -q "^${key}=" "$SCRIPT_DIR/config.sh"; then
        # Replace the existing value
        sed -i "s/^${key}=.*$/${key}=\"${version}\"/" "$SCRIPT_DIR/config.sh"
    else
        # Append if the key doesn't exist
        echo "${key}=\"${version}\"" >> "$SCRIPT_DIR/config.sh"
    fi
}


#!/bin/bash

# Get the absolute path of the current script directory
SCRIPT_DIR="$(realpath "$(dirname "$0")")"

# Source the function.sh file to import the get_version function
source "$SCRIPT_DIR/function.sh"

# Get the current version of postcodeapi
current_capi=$(get_version "companiesapi")
echo "Current version of companiesapi: $companiesapi"
set_version "companiesapi" "2.0.1"


# Get the current version of postcodeapi
current_postcodeapi=$(get_version "postcodeapi")
echo "Current version of postcodeapi: $current_postcodeapi"

# Set a new version for postcodeapi
set_version "postcodeapi" "200.1.0"
echo "Updated version of postcodeapi to: $(get_version 'postcodeapi')"

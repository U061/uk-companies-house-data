#!/bin/bash

# URL base for Companies House downloads
BASE_URL="https://download.companieshouse.gov.uk/"

# Check if a filename parameter is provided
if [ -z "$1" ]; then
    echo "❌ No filename provided. Usage: ./download_files.sh <filename>"
    exit 1
fi

# File to download (parameter passed to the script)
FILE_NAME="$1"

SCRIPT_DIR="$(realpath "$(dirname "$0")")"

# Directory where files will be saved
DOWNLOAD_DIR="$SCRIPT_DIR/downloads"  # Folder name

# Ensure the download directory exists
mkdir -p "$DOWNLOAD_DIR"

# Check if the file already exists in the download directory
FILE_PATH="$DOWNLOAD_DIR/$(basename "$FILE_NAME")"
if [ -f "$FILE_PATH" ]; then
    echo "⚠️ File $FILE_NAME already exists in $DOWNLOAD_DIR. Skipping download."
    exit 0
fi

# Construct the full download URL
DOWNLOAD_URL="${BASE_URL}${FILE_NAME}"

# Print the URL for debugging purposes
echo "DEBUG: Constructed URL: $DOWNLOAD_URL"

# Attempt to download the file using curl, and get the HTTP response code
HTTP_RESPONSE=$(curl -s -o "$FILE_PATH" -w "%{http_code}" "$DOWNLOAD_URL")

# Check the HTTP response code
if [ "$HTTP_RESPONSE" -eq 200 ]; then
    echo "✅ Downloaded $FILE_NAME successfully."
elif [ "$HTTP_RESPONSE" -eq 404 ]; then
    echo "❌ File $FILE_NAME not found (HTTP 404)."
    # Remove the file if it was created (although it shouldn't have been in this case)
    rm -f "$FILE_PATH"
    exit 1
else
    echo "❌ Failed to download $FILE_NAME. HTTP response code: $HTTP_RESPONSE"
    # Remove the file if it was created (although it shouldn't have been in this case)
    rm -f "$FILE_PATH"
    exit 1
fi

# Check if the corresponding CSV file already exists
CSV_FILE="$DOWNLOAD_DIR/$(basename "$FILE_NAME" .zip).csv"
if [ -f "$CSV_FILE" ]; then
    echo "⚠️ CSV file $CSV_FILE already exists in $DOWNLOAD_DIR. Skipping unzip."
else
    # Unzip the downloaded file (only if it's a .zip file)
    if [[ "$FILE_NAME" == *.zip ]]; then
        echo "📦 Unzipping the downloaded file..."

        # Unzip the file into the downloads folder
        unzip -q "$FILE_PATH" -d "$DOWNLOAD_DIR"

        # Check if the unzip was successful
        if [ $? -eq 0 ]; then
            echo "✅ Successfully unzipped $FILE_NAME."

            # Remove the ZIP file after successful extraction
            rm -f "$FILE_PATH"
            echo "🗑️  Removed ZIP file: $FILE_PATH"
        else
            echo "❌ Failed to unzip $FILE_NAME."
            exit 1
        fi

        # Call process csv for processing csv
        python3 "$SCRIPT_DIR/process.py" "$CSV_FILE"

    else
        echo "⚠️ The downloaded file is not a .zip file. Skipping unzip step."
    fi
fi

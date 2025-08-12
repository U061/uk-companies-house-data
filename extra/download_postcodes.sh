#!/bin/bash

# Exit immediately if a command exits with a non-zero status (error handling)
set -e

# Enable debugging (optional, for troubleshooting)
#set -x

# Directory and file variables
DATA_DIR="postcode"
ZIP_FILE="$DATA_DIR/postcodes.zip"
URL="https://www.doogal.co.uk/files/postcodes.zip"
CSV_FILE="$DATA_DIR/postcodes.csv"  # Updated file name
PROCESSED_CSV="$DATA_DIR/postcode_processed.csv"

# Create the data directory if it doesn't exist
if [[ ! -d "$DATA_DIR" ]]; then
    echo "Creating directory $DATA_DIR..."
    mkdir -p "$DATA_DIR"
fi

# Download the ZIP file
echo "Downloading ZIP file from $URL..."
wget -O "$ZIP_FILE" "$URL"

# Extract the ZIP file
echo "Extracting ZIP file to $DATA_DIR..."
unzip -o "$ZIP_FILE" -d "$DATA_DIR"

# Clean up the ZIP file after extraction
echo "Removing ZIP file..."
rm "$ZIP_FILE"

# Check if the CSV file exists
if [[ -f "$CSV_FILE" ]]; then
    echo "Processing CSV file..."

    # Extract rows where "In Use?" is "Yes", select required columns, remove rows where latitude or longitude is 0
    csvgrep -c "In Use?" -m "Yes" "$CSV_FILE" | csvcut -c Postcode,Latitude,Longitude | \
    csvgrep -c Latitude -r "^[^0]" | csvgrep -c Longitude -r "^[^0]" | \
    (read header && echo "$header" | tr '[:upper:]' '[:lower:]' && cat) > "$PROCESSED_CSV"

    echo "Processed CSV file saved as $PROCESSED_CSV"
else
    echo "Error: CSV file $CSV_FILE not found!"
    exit 1
fi

echo "Postcode data update and processing completed successfully."

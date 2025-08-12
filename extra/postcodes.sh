#!/bin/bash

# Define the file path for storing the last downloaded version
VERSION_FILE="postcode/postcode_version.txt"
DOWNLOAD_DIR="postcode"  # Define your download directory

# MySQL database credentials
DB_USER="root"
DB_PASS="root"
DB_NAME="capi"

# Fetch the latest release version details from GitHub
LATEST_VERSION=$(curl -s https://api.github.com/repos/ideal-postcodes/postcodes.io/releases/latest | jq -r .tag_name)
HTML_URL=$(curl -s https://api.github.com/repos/ideal-postcodes/postcodes.io/releases/latest | jq -r .html_url)

# Construct the correct download URL
DOWNLOAD_URL="https://github.com/ideal-postcodes/postcodes.io/archive/refs/tags/${LATEST_VERSION}.tar.gz"

# Get the last downloaded version (if any)
if [ -f "$VERSION_FILE" ]; then
    LAST_DOWNLOADED_VERSION=$(cat $VERSION_FILE)
else
    LAST_DOWNLOADED_VERSION=""
fi

# Compare versions and download if a newer version is available
if [ "$LATEST_VERSION" != "$LAST_DOWNLOADED_VERSION" ]; then
    echo "New version available: $LATEST_VERSION. Downloading..."

    # Download the latest version of the dataset
    wget -O "$DOWNLOAD_DIR/postcodesdb.tar.gz" "$DOWNLOAD_URL"

    # Check if the download was successful
    if [ $? -ne 0 ]; then
        echo "Error downloading the file."
        exit 1
    fi

    # Extract the downloaded tar.gz file
    echo "Extracting the downloaded file..."
    tar -xzvf "$DOWNLOAD_DIR/postcodesdb.tar.gz" -C "$DOWNLOAD_DIR"

    # Check if the SQL file exists after extraction
    SQL_FILE="$DOWNLOAD_DIR/postcodesio-${LATEST_VERSION}/postcodesdb.sql"
    if [ -f "$SQL_FILE" ]; then
        # Import the SQL file into MySQL
        echo "Importing the SQL file into MySQL..."
        mysql -u "$DB_USER" -p"$DB_PASS" "$DB_NAME" < "$SQL_FILE"

        # Optionally delete the SQL file and tar.gz file after import
        rm -rf "$DOWNLOAD_DIR/postcodesio-${LATEST_VERSION}"
        rm "$DOWNLOAD_DIR/postcodesdb.tar.gz"
        echo "Import complete. Files deleted."
    else
        echo "Error: No SQL file found after extraction. Listing contents of the directory:"
        # List the contents of the extracted folder for debugging
        ls -lh "$DOWNLOAD_DIR/postcodesio-${LATEST_VERSION}"
        exit 1
    fi

    # Update the version file with the latest version
    echo "$LATEST_VERSION" > $VERSION_FILE
    echo "Download, extraction, and import complete. Version updated to $LATEST_VERSION."
else
    echo "No new version available. The current version is $LATEST_VERSION."
fi

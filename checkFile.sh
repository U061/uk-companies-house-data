#!/bin/bash
echo "" 
echo "Running Version 1 - Companies House Data"
echo "" 
# URL of the Companies House HTML page
PAGE_URL="https://download.companieshouse.gov.uk/en_output.html"

# Set FILE_TYPE to filter results (e.g., "BasicCompanyData" or "BasicCompanyDataAsOneFile")
FILE_TYPE="BasicCompanyData-2025-03-01-part1_7.zip"  # Change this value as needed for testing

# Get current year and current month
CURRENT_YEAR=$(date +%Y)
CURRENT_MONTH=$(date +%m)  # Current month for testing

# Fetch the HTML page content
HTML_CONTENT=$(curl -s "$PAGE_URL")

# Check if curl succeeded
if [ $? -ne 0 ]; then
    echo "❌ Failed to fetch the HTML page."
    exit 1
fi

# Extract all unique ZIP filenames starting with BasicCompanyData
FILES=$(echo "$HTML_CONTENT" | grep -oP 'BasicCompanyData[^"]*-\d{4}-\d{2}-\d{2}[^"]*\.zip' | sort -u -r)

# Check if any files were found
if [ -z "$FILES" ]; then
    echo "❌ No matching ZIP files found on the page."
    echo ""
    exit 1
fi

# Echo FILES for debugging
echo "All files found:"
echo "$FILES"
echo ""

# Filter files based on FILE_TYPE
if [[ "$FILE_TYPE" == "BasicCompanyData" ]]; then
    FILTERED_FILES=$(echo "$FILES" | grep -P 'BasicCompanyData-\d{4}-\d{2}-\d{2}-part\d+_\d+\.zip')
elif [[ "$FILE_TYPE" == "BasicCompanyDataAsOneFile" ]]; then
    FILTERED_FILES=$(echo "$FILES" | grep -P 'BasicCompanyDataAsOneFile-\d{4}-\d{2}-\d{2}\.zip')
elif [[ "$FILE_TYPE" == "BasicCompanyData-2025-03-01-part1_7.zip" ]]; then
	FILTERED_FILES=$(echo "$FILES" | grep -P 'BasicCompanyData-2025-03-01-part1_7.zip')
else
    echo "❌ Unknown FILE_TYPE: $FILE_TYPE"
    exit 1
fi

# Check if any matching files were found after filtering
if [ -z "$FILTERED_FILES" ]; then
    echo "❌ No files found for type: $FILE_TYPE"
    echo ""
    exit 1
fi

# Echo FILTERED_FILES for debugging
echo "Filtered files based on FILE_TYPE:"
echo "$FILTERED_FILES"
echo ""

# Store all matching files
MATCHED_FILES=()

# Loop through FILTERED_FILES to check date part for each file
while read -r FILE; do
    # Echo each FILE for debugging
    echo "Checking file: $FILE"

    # Extract the date part (YYYY-MM-DD)
    DATE_PART=$(echo "$FILE" | grep -oP '\d{4}-\d{2}-\d{2}')

    # Echo the extracted DATE_PART for debugging
    echo "Extracted date: $DATE_PART"

    # Extract year and month separately
    FILE_YEAR=$(echo "$DATE_PART" | cut -d'-' -f1)
    FILE_MONTH=$(echo "$DATE_PART" | cut -d'-' -f2)

    # Echo the extracted FILE_YEAR and FILE_MONTH for debugging
    echo "Year: $FILE_YEAR, Month: $FILE_MONTH"

    # Check if the file is for the current year and current month
    if [[ "$FILE_YEAR" == "$CURRENT_YEAR" && "$FILE_MONTH" == "$CURRENT_MONTH" ]]; then
        MATCHED_FILES+=("$FILE")  # Add to the list of matched files
    fi
done <<< "$FILTERED_FILES"  # Use FILTERED_FILES here
echo ""

# Initialize counter to track downloads
DOWNLOAD_COUNT=0
FIRST_RUN=true  # Flag to ensure "before loading" optimizations run only once
SCRIPT_DIR="$(realpath "$(dirname "$0")")"
# Display results for all matched files
if [ ${#MATCHED_FILES[@]} -gt 0 ]; then
    echo "✅ Found the following matching files for current month ($CURRENT_YEAR-$CURRENT_MONTH):"
    echo ""

    for FILE in "${MATCHED_FILES[@]}"; do
		
		
        # Directory where files will be saved
        DOWNLOAD_DIR="$SCRIPT_DIR/downloads"  # Folder name

        # Ensure the download directory exists
        mkdir -p "$DOWNLOAD_DIR"

        # Get the corresponding CSV filename (replace .zip with .csv)
        CSV_FILE="$DOWNLOAD_DIR/$(basename "$FILE" .zip).csv"

        # Check if the CSV file already exists
        if [ -f "$CSV_FILE" ]; then
            echo "⚠️  CSV file $CSV_FILE already exists in $DOWNLOAD_DIR. Skipping download."
        else

		# Run "Before Loading" SQL optimizations **only once**
        if [ "$FIRST_RUN" = true ]; then
            echo "🚀 First Run - Applying DB performance enhancements before loading data..."

            
            # Set flag to false so this runs only once
            FIRST_RUN=false
			echo ""
        fi
            echo "Downloading $FILE ..."
            bash "$SCRIPT_DIR/download_files.sh" "$FILE"

	# Increment the counter since a file was downloaded
            DOWNLOAD_COUNT=$((DOWNLOAD_COUNT + 1))
			echo ""
        fi
    done

# Only run SQL optimizations if at least one file was downloaded
if [ "$DOWNLOAD_COUNT" -gt 0 ]; then
    echo "✅ Running DB performance optimizations after loading data..."

    

else
    echo "⚠️ No files found for current month ($CURRENT_YEAR-$CURRENT_MONTH)."
fi

fi
echo ""  # New line for readability

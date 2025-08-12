#!/bin/bash

# Check if a filename parameter is provided
if [ -z "$1" ]; then
    echo "❌ No filename provided. Usage: ./process_csv.sh <filename>"
    exit 1
fi

# Define folder, input, and output files
FOLDER="downloads"
I="$1"
O="${1%.*}_processed.csv"  # Append "_processed" to the filename
INPUT_FILE="$FOLDER/$(basename "$I")"
OUTPUT_FILE="$FOLDER/$(basename "$O")"

# Ensure the folder exists
mkdir -p "$FOLDER"

# Process the file
sed '1s/\./_/g' "$INPUT_FILE" | \
awk '
NR==1 {
    gsub(/^ +| +$/, "", $0);  # Remove leading and trailing spaces from header
    gsub(/ /, "", $0);        # Remove all internal spaces from header
    print tolower($0);        # Convert header to lowercase
}
NR>1 {
    gsub(/^ +| +$/, "", $0);  # Remove leading and trailing spaces from data rows
    print $0;
}' > "$OUTPUT_FILE"

# Check if the output file was successfully created
if [ -f "$OUTPUT_FILE" ]; then
    echo "✅ Processing completed. Output saved to $OUTPUT_FILE"

python3 process.py "$OUTPUT_FILE"

    # Delete the input file
    # rm "$INPUT_FILE"
    # echo "🗑️ Input file $INPUT_FILE deleted."
else
    echo "❌ Error: Output file $OUTPUT_FILE was not created. Input file not deleted."
    exit 1
fi

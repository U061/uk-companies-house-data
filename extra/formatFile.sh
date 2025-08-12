#!/bin/bash

# Set input and output file paths
input_file="downloads/test.csv"
output_file="downloads/test1.csv"

# Make a backup of the original CSV
cp "$input_file" "$input_file.bak"

# Process the CSV: Convert date columns (using column positions as an example)
awk -F',' 'BEGIN{OFS=","}
{
    # Convert date columns (for example, columns 13, 14, 15, etc. are dates)
    # DissolutionDate (column 13)
    if ($13 != "" && $13 != "NULL") {
        split($13, date_arr, "/");
        $13 = date_arr[3] "-" date_arr[2] "-" date_arr[1]; # yyyy-mm-dd
    }
    # IncorporationDate (column 14)
    if ($14 != "" && $14 != "NULL") {
        split($14, date_arr, "/");
        $14 = date_arr[3] "-" date_arr[2] "-" date_arr[1]; # yyyy-mm-dd
    }
    # Repeat for other date columns as needed (e.g., column 15, 16, etc.)
    # Accounts_NextDueDate (column 15)
    if ($15 != "" && $15 != "NULL") {
        split($15, date_arr, "/");
        $15 = date_arr[3] "-" date_arr[2] "-" date_arr[1]; # yyyy-mm-dd
    }
    # Output the transformed line
    print $0
}
' "$input_file" > "$output_file"

echo "Date format conversion completed. Transformed file saved as $output_file"

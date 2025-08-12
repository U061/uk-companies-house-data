#!/bin/bash

file="downloads/BasicCompanyData-2025-03-01-part1_7.csv"
delimiter=","

# Check if the file exists
if [[ ! -f "$file" ]]; then
  echo "Error: File '$file' not found."
  exit 1
fi

# Get the number of columns
num_columns=$(head -n 1 "$file" | tr "$delimiter" '\n' | wc -l)

# Get the header row
header=$(head -n 1 "$file")
column_names=($(echo "$header" | tr "$delimiter" '\n'))

# Loop through each column
for ((col=1; col<=num_columns; col++)); do
    column_name="${column_names[$((col-1))]}"
    echo "Column $col: $column_name"

    # Extract the column data (skip header)
    column_data=$(cut -d "$delimiter" -f "$col" "$file" | tail -n +2)

    # Trim whitespace and calculate max length
    trimmed_data=$(echo "$column_data" | sed 's/^[[:space:]]*//;s/[[:space:]]*$//')

    # Determine data type and max length
    if [[ "$column_name" =~ [Dd]ate$ ]]; then #check if header ends with date/DATE
        if [[ "$trimmed_data" =~ ^[0-9]{2}/[0-9]{2}/[0-9]{4}$ ]]; then
            echo "  Data Type: DATE"
        else
            echo "  Data Type: VARCHAR"
            max_length=$(echo "$trimmed_data" | awk '{print length($0)}' | sort -n | tail -n 1)
            echo "  Max Length: $max_length"
        fi
    elif [[ "$trimmed_data" =~ ^[0-9]+$ ]]; then
        # Integer column
        max_length=$(echo "$trimmed_data" | awk '{print length($0)}' | sort -n | tail -n 1)
        echo "  Data Type: INT"
        echo "  Max Length: $max_length"
    elif [[ "$trimmed_data" =~ ^[0-9]+\.[0-9]+$ ]]; then
        # Float/Decimal column
        max_length=$(echo "$trimmed_data" | awk '{print length($0)}' | sort -n | tail -n 1)
        echo "  Data Type: DECIMAL"
        echo "  Max Length: $max_length"
    else
        # String/VARCHAR column
        max_length=$(echo "$trimmed_data" | awk '{print length($0)}' | sort -n | tail -n 1)
        echo "  Data Type: VARCHAR"
        echo "  Max Length: $max_length"
    fi

    echo "---"
done

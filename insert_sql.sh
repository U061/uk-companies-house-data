#!/bin/bash

# Check if a filename parameter is provided
if [ -z "$1" ]; then
    echo "❌ No filename provided. Usage: ./download_files.sh <filename>"
    exit 1
fi

# File to download (parameter passed to the script)
FILE_NAME="$1"

# PostgreSQL Credentials
DB_USER=$POSTGRES_USER
DB_PASS=$POSTGRES_PASSWORD
DB_NAME=$POSTGRES_DB
TABLE_NAME=$POSTGRES_TABLE
DB_HOST=$POSTGRES_HOST
DB_PORT=$POSTGRES_PORT

SCRIPT_DIR="$(realpath "$(dirname "$0")")"
		
CSV_FILE="$SCRIPT_DIR/downloads/$(basename "$FILE_NAME")"

# Check if the file exists
if [ ! -f "$CSV_FILE" ]; then
    echo "❌ File does not exist: $CSV_FILE"
    exit 1
fi

# Export environment variable for PostgreSQL authentication
export PGPASSWORD=$DB_PASS

# Run the PostgreSQL command to load data from CSV
psql -h "$DB_HOST" -U "$DB_USER" -d "$DB_NAME" <<EOF
SET DATESTYLE TO 'European';
\copy $TABLE_NAME (companyname, companynumber, regaddress_careof, regaddress_pobox, regaddress_addressline1, regaddress_addressline2, regaddress_posttown, regaddress_county, regaddress_country, regaddress_postcode, companycategory, companystatus, countryoforigin, dissolutiondate, incorporationdate, accounts_accountrefday, accounts_accountrefmonth, accounts_nextduedate, accounts_lastmadeupdate, accounts_accountcategory, returns_nextduedate, returns_lastmadeupdate, mortgages_nummortcharges, mortgages_nummortoutstanding, mortgages_nummortpartsatisfied, mortgages_nummortsatisfied, siccode_sictext_1, siccode_sictext_2, siccode_sictext_3, siccode_sictext_4, limitedpartnerships_numgenpartners, limitedpartnerships_numlimpartners, uri, previousname_1_condate, previousname_1_companyname, previousname_2_condate, previousname_2_companyname, previousname_3_condate, previousname_3_companyname, previousname_4_condate, previousname_4_companyname, previousname_5_condate, previousname_5_companyname, previousname_6_condate, previousname_6_companyname, previousname_7_condate, previousname_7_companyname, previousname_8_condate, previousname_8_companyname, previousname_9_condate, previousname_9_companyname, previousname_10_condate, previousname_10_companyname, confstmtnextduedate, confstmtlastmadeupdate) FROM '$CSV_FILE' DELIMITER ',' CSV HEADER NULL AS '';
EOF

echo "✅ Data loaded into $DB_NAME.$TABLE_NAME from $CSV_FILE."

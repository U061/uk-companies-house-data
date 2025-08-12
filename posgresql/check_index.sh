#!/bin/bash

# Define database connection details
DB_HOST="localhost"        # Change this to your host (e.g., container IP)
DB_PORT="5432"             # Default PostgreSQL port
DB_NAME="postcodesiodb"    # Your database name
DB_USER="postcodesio"      # Your PostgreSQL username
DB_PASSWORD="password"     # Your PostgreSQL password
INDEX_NAME="idx_postcodes_geography" # Name of the index to check

# Export the PostgreSQL password so that psql uses it automatically
export PGPASSWORD="$DB_PASSWORD"

# Query to check if the index exists
CHECK_INDEX_QUERY="SELECT to_regclass('$INDEX_NAME') IS NOT NULL;"

# Run the query and store the result
INDEX_EXISTS=$(psql -h "$DB_HOST" -p "$DB_PORT" -d "$DB_NAME" -U "$DB_USER" -t -c "$CHECK_INDEX_QUERY" | tr -d '[:space:]')

# Check the result and create the index if it does not exist
if [ "$INDEX_EXISTS" != "t" ]; then
  echo "Index '$INDEX_NAME' does not exist. Creating it now..."
  CREATE_INDEX_QUERY="CREATE INDEX $INDEX_NAME ON postcodes USING GIST(geography(ST_MakePoint(longitude, latitude)));"
  psql -h "$DB_HOST" -p "$DB_PORT" -d "$DB_NAME" -U "$DB_USER" -c "$CREATE_INDEX_QUERY"
  echo "Index '$INDEX_NAME' created successfully."
else
  echo "Index '$INDEX_NAME' already exists. No action needed."
fi

# Unset the password for security after the script runs
unset PGPASSWORD

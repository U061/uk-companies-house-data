import pandas as pd
import sys
import subprocess
import os

script_dir = os.path.dirname(os.path.realpath(__file__))

# Ensure the script is run with the filename argument
if len(sys.argv) < 2:
    print("❌ Usage: python script.py <input_csv_file>")
    sys.exit(1)

# Get the input file from command-line arguments
csv_file = sys.argv[1]

# Check if the file exists and load the data
print(f"📂 Reading the file: {csv_file}")
try:
    data = pd.read_csv(csv_file, low_memory=False)  # Read CSV with low_memory=False to handle mixed types
    print("✅ File loaded successfully.")
except FileNotFoundError:
    print(f"❌ Error: File '{csv_file}' not found.")
    sys.exit(1)

# Modify column names
print("🔄 Modifying column names...")
data.columns = data.columns.str.replace('.', '_')  # Replace '.' with '_'
data.columns = data.columns.str.strip()  # Remove leading/trailing spaces from column names
data.columns = data.columns.str.replace(' ', '')  # Remove internal spaces in column names
data.columns = data.columns.str.lower()  # Convert column names to lowercase
print("✅ Column names modified.")

# Remove leading/trailing spaces from data rows
print("🔄 Stripping leading/trailing spaces from data rows...")
data = data.apply(lambda x: x.str.strip() if x.dtype == "object" else x)
print("✅ Data rows processed.")

# Convert specific columns to integers
integer_columns = [
    'accounts_accountrefday', 
    'accounts_accountrefmonth', 
    'limitedpartnerships_numgenpartners', 
    'limitedpartnerships_numlimpartners'
]

# Ensure that these columns are converted to integers (allowing NaN for missing values)
for col in integer_columns:
    if col in data.columns:
        print(f"🔄 Processing Integer column: {col}")
        data[col] = data[col].astype('Int64')  # Convert to integer (nullable)

# Check if 'dissolutiondate' exists in the columns and replace empty with NaN
if 'dissolutiondate' in data.columns:
    print("🔄 Processing 'dissolutiondate' column...")
    data['dissolutiondate'] = data['dissolutiondate'].replace('', pd.NA)
    print("✅ 'dissolutiondate' processed.")
else:
    print("⚠️ Warning: 'dissolutiondate' column not found in the CSV file.")

# Convert dates from dd/mm/yyyy format to yyyy-mm-dd (assuming they are in strings)
date_columns = ['dissolutiondate', 'incorporationdate', 'accounts_nextduedate', 'accounts_lastmadeupdate',
                'returns_nextduedate', 'returns_lastmadeupdate', 'previousname_1_condate', 'previousname_2_condate',
                'previousname_3_condate', 'previousname_4_condate', 'previousname_5_condate', 'previousname_6_condate',
                'previousname_7_condate', 'previousname_8_condate', 'previousname_9_condate', 'previousname_10_condate',
                'confstmtnextduedate', 'confstmtlastmadeupdate']

print("🔄 Converting date columns to yyyy-mm-dd format...")
# Convert each date column if they exist in the data
for col in date_columns:
    if col in data.columns:
        data[col] = pd.to_datetime(data[col], format='%d/%m/%Y', errors='coerce')
        print(f"✅ '{col}' column converted.")
    else:
        print(f"⚠️ Warning: '{col}' column not found in the CSV file.")

# Generate the output filename
output_file = csv_file.replace('.csv', '_processed.csv')

# Save the processed data to the output file
print(f"📂 Saving the processed data to '{output_file}'...")
data.to_csv(output_file, index=False)
print(f"✅ Processed data saved to '{output_file}'.")

# Call the bash shell script with the output file as a parameter
try:
    print("🛠️ Running insert_sql.sh with the processed output file...")
    # Build the full path for insert_sql.sh
    insert_sql_path = os.path.join(script_dir, "insert_sql.sh")
    subprocess.run(["bash", insert_sql_path, output_file], check=True)
    print("✅ Data inserted successfully using insert_sql.sh.")
except subprocess.CalledProcessError as e:
    print(f"Error running insert_sql.sh: {e}")

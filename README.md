# uk-companies-house-data

- Checks Companies house data Monthly download is available and inserts the data to a postgres database.
- Runs in linux using bash shell and python + pandas.
- Config.sh and Config.txt is used to determine which month data to look for.

Start 

checkFile.sh 

(Recommended - create cronjob to run this file daily at your preferred time.)
Checks if new month data is available on the Companies house using the config.txt (MONTH)

download_files.sh

Downloads the available file onto the downloads folder

process.py

Using the pandas library the downloaded files are processed to match the database date format and avoid any errors.
Creates new file with same name and processed at the end.

insert_sql.sh

Contains the postgres db credentials and inserts the processed data.





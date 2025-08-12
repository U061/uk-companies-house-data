#!/bin/bash

# Log file
LOG_FILE="version_check.log"

# Get the container name or ID
CONTAINER_NAME_OR_ID="postcodes"

# Get the installed image name and tag
INSTALLED_IMAGE=$(docker inspect --format='{{.Config.Image}}' "$CONTAINER_NAME_OR_ID")
INSTALLED_TAG=$(echo "$INSTALLED_IMAGE" | awk -F':' '{print $2}')
if [ -z "$INSTALLED_TAG" ]; then
    INSTALLED_TAG="latest"
fi

# Get the installed image digest
INSTALLED_DIGEST=$(docker inspect --format='{{index .RepoDigests 0}}' "$CONTAINER_NAME_OR_ID")
if [ -z "$INSTALLED_DIGEST" ]; then
    INSTALLED_DIGEST="N/A"
fi

echo "Installed Image: $INSTALLED_IMAGE" >> $LOG_FILE
echo "Installed Tag: $INSTALLED_TAG" >> $LOG_FILE
echo "Installed Digest: $INSTALLED_DIGEST" >> $LOG_FILE

# Pull the latest image
docker pull idealpostcodes/postcodes.io.db

# Get the latest image name and tag
LATEST_IMAGE=$(docker inspect --format='{{.Config.Image}}' idealpostcodes/postcodes.io.db)
LATEST_TAG=$(echo "$LATEST_IMAGE" | awk -F':' '{print $2}')
if [ -z "$LATEST_TAG" ]; then
    LATEST_TAG="latest"
fi

# Get the latest image digest
LATEST_DIGEST=$(docker inspect --format='{{index .RepoDigests 0}}' idealpostcodes/postcodes.io.db)
if [ -z "$LATEST_DIGEST" ]; then
    LATEST_DIGEST="N/A"
fi

echo "Latest Image: $LATEST_IMAGE" >> $LOG_FILE
echo "Latest Tag: $LATEST_TAG" >> $LOG_FILE
echo "Latest Digest: $LATEST_DIGEST" >> $LOG_FILE

# Compare versions
if [ "$INSTALLED_DIGEST" != "$LATEST_DIGEST" ]; then
    echo "Update available: Installed Digest ($INSTALLED_DIGEST) vs Latest Digest ($LATEST_DIGEST)" >> $LOG_FILE
else
    echo "No update available. Installed version is up to date." >> $LOG_FILE
fi

echo "Version check completed. Results logged in $LOG_FILE."
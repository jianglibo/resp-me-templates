#!/bin/bash

# Store the original working directory
original_dir=$(pwd)
# Get the directory path of the executing script
cd "$(dirname "$0")"

# you can comment out lines bellow after the initial setup.
source ./setup-nginx.sh
source ./setup-rabbitmq.sh

to_dir="/etc/nginx/certs"
mkdir -p "$to_dir"
backup_dir="$(dirname "$to_dir")/certs_$(date +'%Y%m%d%H%M%S')"
# Create the backup directory
mkdir -p "$backup_dir"

# Copy the contents of the source directory to the backup directory
cp -R "$to_dir"/* "$backup_dir/"

cp -Rf ./certs/* "$to_dir"/

# Reload nginx to apply the changes
echo "Reloading nginx..."
sudo nginx -s reload

cd "$original_dir"

# tell the system not to delete the folder after execution.
exit 210

# latest_backup=$(ls -dtr "$(dirname "$source_dir")"/certs_* | tail -n 1)
# cp -R "$latest_backup"/* "$source_dir/"
# rm -rf "$latest_backup"
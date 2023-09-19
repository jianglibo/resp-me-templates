#!/bin/bash

# Function to check if a package is installed
is_package_installed() {
  dpkg -l "$1" &> /dev/null
}

# Check if mariadb-server is installed, and if not, install it
if ! is_package_installed mariadb-server; then
  echo "mariadb-server is not installed. Installing mariadb-server..."
  sudo apt -q update
  sudo apt -q install -y mariadb-server
fi

# Function to check if mariadb service is active
is_mariadb_active() {
  sudo systemctl is-active mariadb &> /dev/null
}

# Wait for mariadb to start, with a maximum of 3 tries
MAX_TRIES=3
tries=0

echo "Waiting for mariadb to start..."
while [ $tries -lt $MAX_TRIES ]; do
  if is_mariadb_active; then
    echo "mariadb is now active and running!"
    break
  fi

  tries=$((tries + 1))
  if [ $tries -lt $MAX_TRIES ]; then
    echo "Attempt $tries: mariadb is not active yet. Retrying in 5 seconds..."
    sleep 5
  fi
done

if [ $tries -eq $MAX_TRIES ]; then
  echo "Giving up after $MAX_TRIES attempts. mariadb did not start."
  exit 210
fi

echo -e "\n\n\n\nY\n\n\nY\nY\nY\nY" | sudo mysql_secure_installation

# SQL file to execute
SQL_FILE="./init.sql"

hashed_password=$(echo -n "$APP_ADMIN_PASSWORD" | sha224sum | awk '{print $1}')

echo "replace the password in the SQL file"
sed -i "s/'sha224_admin_password'/'$hashed_password'/g" $SQL_FILE

# Check if the SQL file exists
if [ -f "$SQL_FILE" ]; then
  # Execute the SQL file using mariadb
  mysql -uroot --force < "$SQL_FILE"
  echo "SQL file executed successfully."
else
  echo "SQL file not found: $SQL_FILE"
fi

sudo systemctl restart mariadb
#!/bin/bash

# Function to check if a package is installed
is_package_installed() {
  dpkg -l "$1" &> /dev/null
}

# Check if mysql-server is installed, and if not, install it
if ! is_package_installed mysql-server; then
  echo "mysql-server is not installed. Installing mysql-server..."
  sudo apt -q update
  sudo apt -q install -y mysql-server
fi

# Function to check if mysql service is active
is_mysql_active() {
  sudo systemctl is-active mysql &> /dev/null
}

# Wait for mysql to start, with a maximum of 3 tries
MAX_TRIES=3
tries=0

echo "Waiting for mysql to start..."
while [ $tries -lt $MAX_TRIES ]; do
  if is_mysql_active; then
    echo "mysql is now active and running!"
    break
  fi

  tries=$((tries + 1))
  if [ $tries -lt $MAX_TRIES ]; then
    echo "Attempt $tries: mysql is not active yet. Retrying in 5 seconds..."
    sleep 5
  fi
done

if [ $tries -eq $MAX_TRIES ]; then
  echo "Giving up after $MAX_TRIES attempts. mysql did not start."
  exit 210
fi

echo -e "\n\n\n\nY\n\n\nY\nY\nY\nY" | {{mysql.sudo}} mysql_secure_installation

SQL_FILE="./init.sql"
# Check if the SQL file exists
if [ -f "$SQL_FILE" ]; then
  # Execute the SQL file using mariadb
  mysql -uroot --force < "$SQL_FILE"
  echo "SQL file executed successfully."
else
  echo "SQL file not found: $SQL_FILE"
fi

sudo systemctl restart mysql

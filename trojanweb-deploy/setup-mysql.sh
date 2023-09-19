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
  echo "copying mysqld.cnf"
  sudo systemctl stop mysql-server
  cp -f ./mysqld.cnf /etc/mysql/mysql.conf.d/mysqld.cnf
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

# new password may not take effect, it's still allowed to login with no password for root user.
echo -e "\n\n\n\nY\n{{mysql.mysql_root_password}}\n{{mysql.mysql_root_password}}\nY\nY\nY\nY" | {{mysql.sudo}} mysql_secure_installation

# echo "CREATE DATABASE $DB_NAME;" | {{mysql.sudo}} mysql -u root -p$MYSQL_ROOT_PASSWORD

# Check if the user already exists
# {{mysql.sudo}} mysql -u root -p$MYSQL_ROOT_PASSWORD -e "SELECT User FROM mysql.user WHERE User='$DB_USER'" | grep -q "$DB_USER"

# if [ $? -eq 0 ]; then
    # User exists, update the password and privileges
#     echo "ALTER USER '$DB_USER'@'localhost' IDENTIFIED BY '$DB_USER_PASSWORD';" | {{mysql.sudo}} mysql -u root -p$MYSQL_ROOT_PASSWORD
#     echo "Password and privileges updated for user $DB_USER"
# else
    # User doesn't exist, create the user with privileges
    # echo "CREATE USER '$DB_USER'@'localhost' IDENTIFIED BY '$DB_USER_PASSWORD'; GRANT ALL PRIVILEGES ON $DB_NAME.* TO '$DB_USER'@'localhost';" | {{mysql.sudo}} mysql -u root -p$MYSQL_ROOT_PASSWORD
    # echo "User $DB_USER created with the specified password and granted privileges"
# fi

# echo "FLUSH PRIVILEGES;" | {{mysql.sudo}} mysql -u root -p$MYSQL_ROOT_PASSWORD

# SQL file to execute
SQL_FILE="./init.sql"

hashed_password=$(echo -n "$APP_ADMIN_PASSWORD" | sha224sum | awk '{print $1}')

sed -i "s/'sha224_admin_password'/'$hashed_password'/g" $SQL_FILE

# Check if the SQL file exists
if [ -f "$SQL_FILE" ]; then
  # Execute the SQL file using MySQL
  mysql -uroot < "$SQL_FILE"
  echo "SQL file executed successfully."
else
  echo "SQL file not found: $SQL_FILE"
fi

sudo systemctl restart mysql
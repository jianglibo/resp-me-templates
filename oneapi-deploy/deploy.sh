#!/bin/bash

MYSQL_ROOT_PASSWORD="{{mysql.mysql_root_password}}"
DB_NAME="{{mysql.db_name}}"
DB_USER="{{mysql.db_user}}"
DB_USER_PASSWORD="{{mysql.db_user_password}}"
APP_ADMIN_PASSWORD="{{mysql.app_admin_password}}"

WORKING_DIR="{{service.workingDir}}"
EXEC_START="{{service.execStart}}"

# create workingDir
sudo mkdir -p "$WORKING_DIR"

# if file one-api exists in the workingDir then skip download.
if [[ ! -f "${EXEC_START}" ]]; then
	curl -s -L https://github.com/songquanpeng/one-api/releases/download/v0.5.2/one-api -o "$EXEC_START"
	chmod a+x "$EXEC_START"
fi

backup_and_copy ./certs /etc/nginx/certs
source ./setup-mysql.sh
source ./setup-service.sh
source ./setup-nginx.sh

sleep 5

adminPassword=$(htpasswd -bnBC 10 "" ${APP_ADMIN_PASSWORD} | tr -d ':\n')
sudo mysql -u root -p$MYSQL_ROOT_PASSWORD -e "UPDATE ${DB_NAME}.users SET password = '${adminPassword}' WHERE username = 'root';"

systemctl restart nginx

echo "end of the start.sh"
# for debug purpose the deployed files will not delete at exit.

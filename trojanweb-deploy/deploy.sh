#!/bin/bash

DB_NAME="{{mysql.db_name}}"
DB_USER="{{mysql.db_user}}"
DB_USER_PASSWORD="{{mysql.db_user_password}}"
APP_ADMIN_PASSWORD="{{mysql.app_admin_password}}"

WORKING_DIR="{{service.workingDir}}"
EXEC_START="{{service.execStart}}"

APP_USER="{{service.username}}"
APP_NAME="{{service.appname}}"

# create workingDir
sudo mkdir -p "$WORKING_DIR"

# we are using customized image so all these bellow have already installed.
# sudo apt-get update
# sudo apt-get install supervisor trojan libmysqlclient-dev cpanminus build-essential libcurl4-gnutls-dev libxml2-dev libssl-dev -y
# sudo cpanm HTTP::Daemon IO::Socket::SSL Crypt::CBC YAML::XS DBI DBD::mysql Data::Page Mojolicious::Plugin::HTMX Number::Bytes::Human CryptX Mojolicious::Plugin::AssetPack Session::Token Mojolicious::Plugin::I18N

echo "start copying trojanweb.zip to {{service.workingDir}}"
backup_and_copy ./certs /etc/trojanweb/certs

# source ./setup-mysql.sh
source ./setup-mariadb.sh

sleep 3
# source ./setup-service.sh
source ./setup-supervisor.sh

echo "end of the deploy.sh"
# for debug purpose the deployed files will not delete at exit.

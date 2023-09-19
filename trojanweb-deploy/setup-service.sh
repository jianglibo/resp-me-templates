#!/bin/bash

cp ./trojanweb.zip "{{service.workingDir}}"

unzip_keep_in_same_directory "{{service.workingDir}}/trojanweb.zip" -o
cp -f ./config.json /etc/trojan/config.json

cp -f ./trojanweb.conf.pl /opt/trojanweb/

sudo systemctl restart trojan

username="{{service.username}}"
WORKING_DIR="{{service.workingDir}}"
appname="{{service.appname}}"

sudo groupadd --system $username
sudo useradd -s /sbin/nologin --system -g $username $username

sudo chown -R $username $WORKING_DIR

sudo mkdir -p "/etc/$username"

sudo cp app.env "/etc/${appname}/env"
sudo cp app.service "/etc/systemd/system/${appname}.service"

sudo systemctl enable "${appname}.service"
sudo systemctl daemon-reload
sudo systemctl start "${appname}.service"

# https://www.freedesktop.org/software/systemd/man/systemd.service.html

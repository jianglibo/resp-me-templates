#!/bin/bash

# Set the directory path
dir_to_wait="/etc/supervisor/conf.d/"

MAX_TRIES=3
tries=0
# Check if the directory exists
while [ ! -d "$dir_to_wait" ]; do
	echo "Waiting for $dir_to_wait to be created..."
	tries=$((tries + 1))
	if [ $tries -lt $MAX_TRIES ]; then
		echo "Attempt $tries: waiting supervisor to start. Retrying in 3 seconds..."
		sleep 3
	else
		break
	fi
done

echo "start copying trojanweb.zip to {{service.workingDir}}"
cp ./trojanweb.zip "{{service.workingDir}}"

echo "start unziping trojanweb.zip to {{service.workingDir}}"
unzip_keep_in_same_directory "{{service.workingDir}}/trojanweb.zip" -o 

echo "start copying trojan config.json to /etc/trojan/config.json"
cp -f ./config.json /etc/trojan/config.json

echo "start copying trojanweb.conf.pl to /opt/trojanweb/"
cp -f ./trojanweb.conf.pl {{service.workingDir}}

echo "start copying supervisoer-trojanweb.conf to /etc/supervisor/conf.d/trojanweb.conf"
cp -f ./supervisor-trojanweb.conf /etc/supervisor/conf.d/trojanweb.conf

sleep 3

sudo systemctl restart trojan
sudo supervisorctl reread
sudo supervisorctl update

sudo supervisorctl restart trojanweb

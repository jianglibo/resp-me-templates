#!/bin/bash

action="$1"

source ./deploy-util.sh

if [[ "$action" == "cert" ]];then
	echo "start copying certs..."
	backup_and_copy ./certs /etc/nginx/certs
	systemctl reload nginx
elif [[ "$action" == "destroy" ]];then
	echo "start destroying..."
elif [[ "$action" == "redeploy" ]];then
	echo "start redeploying..."
else
	echo "start deploying..."
	source ./deploy.sh
fi

echo "---CHENGGONG---"

exit 210
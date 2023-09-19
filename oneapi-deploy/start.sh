#!/bin/bash

action="$1"

source ./deploy-util.sh

if [[ "$action" == "cert" ]];then
	echo "start copying certs..."
	backup_and_copy ./certs /etc/trojanweb/certs
	systemctl reload trojan
elif [[ "$action" == "destroy" ]];then
	echo "start destroying..."
elif [[ "$action" == "redeploy" ]];then
	echo "start redeploying..."
else
	echo "start deploying..."
	source ./deploy.sh
fi


exit 210
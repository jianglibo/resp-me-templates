#!/bin/bash

action="$1"

source ./deploy-util.sh
date -u
if [[ "$action" == "cert" ]];then
	echo "start copying certs..."
	backup_and_copy ./certs /etc/trojanweb/certs
	systemctl reload trojan
elif [[ "$action" == "destroy" ]];then
	echo "start destroying trojanweb ..."
elif [[ "$action" == "redeploy" ]];then
	echo "start redeploying..."
else
	echo "start deploying trojanweb..."
	source ./deploy.sh
fi

date -u

exit 210
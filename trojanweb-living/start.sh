#!/bin/bash

action="$1"

source ./deploy-util.sh

VM_IMAGE={{image}}
VM_SIZE={{size}}

vmName="a${THIS_TEMPLATE_DEPLOY_HISTORY_ID}a"
myResourceGroup="for-living-template"

if [[ "$action" == "deploy" ]];then
	echo "start deploying..."
	source ./up.sh
elif [[ "$action" == "destroy" ]];then
	echo "start destroying..."
	source ./down.sh
elif [[ "$action" == "redeploy" ]];then
	echo "start redeploying..."
	source ./up.sh
	# source ./redeploy.sh
else
	echo "unknown action"
fi
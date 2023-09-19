#!/bin/bash

# Set the 'set -e' option to exit on any error
# set -e

source ./deploy-util.sh
tdhjson=$(cat "template-deploy-history.json")

deploy_result_str=$(echo "$tdhjson" | jq -r .deploy_result)
if [[ -z $deploy_result_str || $deploy_result_str == "null" ]];then
	echo "no deploy_result found in $tdhjson"
	exit 210
fi

vm_id=$(echo $deploy_result_str | jq -r .create_vm.id)
if [[ -z $vm_id || $vm_id == "null" ]];then
	echo "no vm_id found in $deploy_result_str"
	exit 210
fi

echo "vm_id:$vm_id"

az_login

delete_azure_vm "$vm_id"

echo "task finished."
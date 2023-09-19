#!/bin/bash

# what is a redeploy? I got every thing ready except the destroyed vm.
# create the vm and get it's ip_address, update the DNS record, recreate the environment by existing data.

prevDeployResult=$(cat template-deploy-history.json | jq -r .deploy_result)

prevSshKey=$(echo $prevDeployResult | jq -r .sshkey_id)
url=$(echo $prevDeployResult | jq -r .url)
sshpublickey=$(echo $prevDeployResult | jq -r .sshpublickey)
trojanweb_deploy_id=$(echo $prevDeployResult | jq -r .trojanweb_deploy_id)
cert_deploy_id=$(echo $prevDeployResult | jq -r .cert_deploy_id)

if [[ -z "$prevSshKey" || "null" == $prevSshKey ]]; then
	echo "got error. prevSshKey is empty"
	exit 210
fi

az_login
# Execute the 'az vm create' command
# https://learn.microsoft.com/en-us/azure/virtual-machines/sizes-b-series-burstable
echo "start invoking az vm create with image: $VM_IMAGE and size: $VM_SIZE"
vm_create_result=$(az vm create -n "$vmName" -g "$myResourceGroup" \
	--image $VM_IMAGE \
	--admin-username azureuser \
	--size $VM_SIZE \
	--public-ip-address-dns-name "$vmName" \
	--authentication-type ssh \
	--public-ip-sku Standard \
	--ssh-key-values "${sshpublickey}" \
	--verbose)

az vm run-command invoke -g "$myResourceGroup" -n "$vmName" --command-id RunShellScript --scripts "apt-get update && apt-get install -y curl unzip jq apache2-utils"
az vm open-port -g "$myResourceGroup" -n "$vmName" --port 80,443 --priority 100

echo "az vm create result: ${vm_create_result}"

ip_address=$(echo $vm_create_result | jq -r .publicIpAddress)
if [ "$?" -ne 0 ]; then
	echo "got error. dump vm_create_result:"
	echo "$vm_create_result"
	exit 210
fi

cert_settings=$(
	cat <<EOF
{
	"mustache": {
		"scopes":{
			"ip_address": "${ip_address}"
		}
	}
}
EOF
)
# if there exists mustache.scopes.ip_adderss the server will update the dns setting if the ip address changed.
merge_deploy_definition_settings $cert_deploy_id "$cert_settings"

dr=$(
	cat <<EOF
{
	"vm_create_result": $vm_create_result
}
EOF
)

if ! merge_template_deploy_result "$dr";then
	exit 210
fi

if ! check_dns_resolve "$url" "$ip_address";then
	echo "dns resolve failed"
	exit 210
fi

# redeploy the trojanweb-deploy definition
# this is event message output, not json.
echo "start deploy created definition. ${trojanweb_deploy_id}"
deploy_deploy_definition "$trojanweb_deploy_id"

echo "---CHENGGONG---"
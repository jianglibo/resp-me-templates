#!/bin/bash

# Set the 'set -e' option to exit on any error
# set -e
definition_json="definition.json"
template_deploy_history_json="template-deploy-history.json"

if [[ -f "/etc/wsl.conf" ]]; then
	source /home/jianglibo/appc-pki/sb3/src/main/resources/bash/deploy-util-tpl.sh
	X_TOBE_CLIENT_SECRET="neZ74ff12kNOxfog5OBfxE3nlpPck6OL5S4SYe5E9022eBu3G3eXw8MZFc9D9yQ5"
	SERVER_ROOT_URI="http://localhost:4000"
	MY_USER_ID=30
	THIS_DEPLOY_DEFINITION_ID=
	THIS_TEMPLATE_ID=372
	THIS_DEPLOY_DEFINITION_SECRET=
	THIS_TEMPLATE_DEPLOY_HISTORY_ID=65
	definition_json="___definition.json"
	template_deploy_history_json="___template-deploy-history.json"
else
	source ./deploy-util.sh
fi

client_id=$(cat "$definition_json" | jq -r .user_id)

prevDeployResult=$(cat "$template_deploy_history_json" | jq -r .deploy_result)
template_deploy_history_id=$(cat "$template_deploy_history_json" | jq -r .id)
prevSshKey=$(echo $prevDeployResult | jq -r .sshkey.data.id)

if [[ (-n "$prevSshKey") && ("$prevSshKey" != "null") ]]; then
	echo "find sshkey_id in prev"
	sshkey_id=$prevSshKey
	sshpublickey=$(echo $prevDeployResult | jq -r .sshkey.data.public_key)
else
	sshkey=$(generate_sshkey)
	sshpublickey=$(echo $sshkey | jq -r .data.public_key)
	sshkey_id=$(echo $sshkey | jq -r .data.id)
	if ! share_sshkey $client_id $sshkey_id; then
		exit 210
	fi

	update_template_deploy_step_result "sshkey" "$sshkey"
fi

# Construct the VM name using variable expansion
vmName="a${THIS_TEMPLATE_DEPLOY_HISTORY_ID}a"
myResourceGroup="for-living-template"

prevVmCreateResult=$(echo $prevDeployResult | jq -r '.create_vm')

echo "prevVmCreateResult:$prevVmCreateResult"

if [[ -n "$prevVmCreateResult" && $prevVmCreateResult != "null" ]]; then
	echo "vm created before."
	echo "$prevVmCreateResult"
	vm_create_result=$prevVmCreateResult
else
	az_login
	# Execute the 'az vm create' command
	# https://learn.microsoft.com/en-us/azure/virtual-machines/sizes-b-series-burstable
	vm_create_result=$(az vm create -n "$vmName" -g "$myResourceGroup" \
		--image $VM_IMAGE \
		--admin-username azureuser \
		--size $VM_SIZE \
		--public-ip-address-dns-name "$vmName" \
		--authentication-type ssh \
		--public-ip-sku Standard \
		--ssh-key-values "${sshpublickey}" \
		--verbose)

	# we are using customized image so it's already installed.

	# echo "running shell script: apt-get -q update && apt-get install -q -y curl unzip jq apache2-utils"
	# _v=$(az vm run-command invoke -g "$myResourceGroup" -n "$vmName" --command-id RunShellScript --scripts "apt-get -q update && apt-get install -q -y curl unzip jq apache2-utils")
	# if [[ "$?" -ne 0 ]]; then
	# 	echo "got error. run shell script failed."
	# 	echo "$_v"
	# 	exit 210
	# fi

	echo "openning port 80,443"
	_v=$(az vm open-port -g "$myResourceGroup" -n "$vmName" --port 80,443 --priority 100)
	if [[ "$?" -ne 0 ]]; then
		echo "got error. open port failed."
		echo "$_v"
		exit 210
	fi

	if ! update_template_deploy_step_result "create_vm" "$vm_create_result"; then
		exit 210
	fi
fi

# Print the result of the 'az vm create' command
# echo "VM Creation Result:"
# echo "$vm_create_result"

ip_address=$(echo $vm_create_result | jq -r .publicIpAddress)
if [ "$?" -ne 0 ]; then
	echo "got error. dump vm_create_result:"
	echo "$vm_create_result"
	exit 210
fi

echo "publicIpAddress:$ip_address"

ccc=$(echo $prevDeployResult | jq -r '.cert')

cert_result_id=$(echo $prevDeployResult | jq -r '.cert.data.id')
settings_str=$(echo $prevDeployResult | jq -r .cert.data.settings)
domain_name=$(echo $settings_str | jq -r .mustache.scopes.domain_name)
ip_address_in_cert=$(echo $settings_str | jq -r .mustache.scopes.ip_address)

# need to update the dns record to reflect the new ip.
# do an update to the cert deploy definition. when updating update the dns record too.
# is the necessary to update the deploy_result?
if [[ $ip_address != $ip_address_in_cert ]]; then
	echo "ip address changed, update cert deploy definition."
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
fi

if [[ -z $cert_result_id || $cert_result_id == "null" ]]; then
	# will override the default 192.168.0.1 ip address on result cert deploy definition.
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

	# dependence on free-sub-domain will add extra information to the this deploydefinition.
	# will add the ip_address and domain_name to the certification deploy definition's scopes.
	# The free-sub-domain template is a special template that will create a new instance of the certification deploy instead of creating an instance of itself.
	# which concern only the domain_id key in the settings.
	# when instancing free-sub-domain it will add dns record to azure dns.
	# So we need to update the dns record when the ip address changed and the ip_address value in the cert deploy definition(even so we don't use the value.).
	# it's deploy_to is domain. when create a new instance it will add a dns record to new created domain.
	# if we use existing domain name, we need to update the dns record to reflect the new ip address.
	cert_result=$(curl_post "$cert_settings" "/tobe/deploy_templates/free-sub-domain/newInstance")

	if [ "$?" -ne 0 ]; then
		echo "got error. create cert newInstance failed:"
		echo "$cert_settings"
		echo "$cert_result"
		exit 210
	fi
	cert_result_id=$(echo $cert_result | jq .data.id)
	settings_str=$(echo $cert_result | jq -r .data.settings)
	echo "${settings_str}" | jq -r '.'
	domain_name=$(echo $settings_str | jq -r .mustache.scopes.domain_name)

	echo "cert: $cert_result"

	if ! update_template_deploy_step_result "cert" "$cert_result"; then
		exit 210
	fi
fi

connection=$(
	cat <<EOF
{
			"host": "$domain_name",
			"port": 22,
			"user": "azureuser",
			"workingdir": "/home/azureuser",
			"sudo": true,
			"exec": false,
			"sshkey_id": $sshkey_id
		}
EOF
)

username="trojanweb"
mysql_root_password=$(pwgen 64 1)
db_user_password=$(pwgen 64 1)
app_admin_password=$(pwgen 64 1)
msecret=$(pwgen 64 1)
trojanweb_settings=$(
	cat <<EOF
{
	"template_deploy_history_id": $template_deploy_history_id,
		"connection": $connection,
		"entrypoint_params": ["cert"],
		"all_possible_actions": ["cert", "deploy","redeploy"],
		"mustache": {
			"scopes": {
				"workingDir": "/opt/$username",
				"service": {
					"username": "$username",
					"appname": "$username",
					"workingDir": "/opt/$username",
					"execStart": "hypnotoad /opt/$username/script/${username}.pl"
				},
				"mojolicious": {
					"secret": "$msecret"
				},
				"mysql": {
					"mysql_root_password": "${mysql_root_password}",
					"db_name": "trojan",
					"db_user": "trojan",
					"db_user_password": "${db_user_password}",
					"app_admin_password": "${app_admin_password}"
				}
			}
		}
	}
EOF
)
trojanweb_result=$(curl_post "$trojanweb_settings" "/tobe/deploy_templates/trojanweb-deploy/newInstance")

trojanweb_result_id=$(echo $trojanweb_result | jq .data.id)

if [[ (-z $trojanweb_result_id) || $trojanweb_result_id == "null" ]]; then
	echo "got error. create trojanweb-deploy newInstance failed:"
	echo "$trojanweb_settings"
	echo "$trojanweb_result"
	exit 210
fi
echo "trojanweb_result_id:$trojanweb_result_id"

# update dependency
if ! update_deploy_dependency $trojanweb_result_id $cert_result_id; then
	exit 210
fi

deploy_step_result=$(
	cat <<EOF
{
	"id": $trojanweb_result_id
}
EOF
)

if ! update_template_deploy_step_result "deploy" "$deploy_step_result"; then
	exit 210
fi

echo "start save cloud_resource"
resouce_id=$(echo $vm_create_result | jq -r .id)
cloud_resouce=$(
	cat <<EOF
	{
		"provider": "azure",
		"resource_type": "vm",
		"resource_id": "$resouce_id",
		"deploy_definition_id": $trojanweb_result_id
	}
EOF
)

if ! save_cloud_resouce "$cloud_resouce"; then
	exit 210
fi

update_cron=$(
	cat <<EOF
{
	"id": $trojanweb_result_id,
	"cron": "75d,75d"
	}
EOF
)

echo "start update deploy cron"
update_deploy "$update_cron"

# make a deloyment for trojanweb-deploy, the code above create only a definition not a deployment, only the deployment will
# actually do things on the just created vm.
deploy_customize=$(
	cat <<EOF
{
	"entrypoint_params": ["deploy"]
	}
EOF
)

echo "start deploy deploy_definition"
# this is event message output, not json.
deploy_deploy_definition "$trojanweb_result_id" "$deploy_customize"

# IF we came here, we have a vm created, and a cert created, and a trojanweb-deploy created.
# If the result is not as expected, we could go to the web ui to run this deploydefintion, it's no need to create vm again and again.

result_for_final_user=$(
	cat <<EOF
{"settings":
  {
    "url": "https://${domain_name}",
	"username": "admin",
	"password": "${app_admin_password}",
	"connection": $connection
  },
  "status": "ready"
}
EOF
)

echo "start update cosumers deploy definition"
if ! update_consumers_deploy_definition "$result_for_final_user"; then
	exit 210
fi

# if we see this line it will be considered succeeded.
echo "---CHENGGONG---"

echo "up task finished"

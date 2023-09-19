#!/bin/bash

delete_azure_vm() {
	# vm_id=$(echo $vm_create_result | jq -r '.id')
	local vm_id="$1"
	echo "vm id: $vm_id"
	# vm_id=$(az vm list --query "[?name == '$vmName'].id" --output tsv)
	# vmName=$(az vm list --query "[?id == '$vm_id'].name" --output tsv)
	vmName=$(basename $vm_id)
	echo "vm name: $vmName"

	resource_group=for-living-template

	# disk_ids=$(az disk list --query "[?managedBy == '$vm_id'].id" --output tsv)
	disk_ids=$(az disk list --query "[?starts_with(name, '${vmName}_')].id" --output tsv)
	echo "disk ids: $disk_ids"

	az vm delete -n "$vmName" -g "$resource_group" --yes
	az network nic delete -n "${vmName}VMNic" -g "$resource_group"
	az network public-ip delete -n "${vmName}PublicIp" -g "$resource_group"
	az network nsg delete -n "${vmName}NSG" -g "$resource_group"
	az network vnet delete -n "${vmName}VNET" -g "$resource_group"
	if [[ -n $disk_ids ]]; then
		az disk delete --ids $disk_ids --yes
	fi
}

read -r -d '' vm_create_result <<EOF
{
  "fqdns": "",
  "id": "/subscriptions/702e1d2b-b275-4b39-8480-a065e39474bd/resourceGroups/for-living-template/providers/Microsoft.Compute/virtualMachines/a55a",
  "location": "koreacentral",
  "macAddress": "60-45-BD-45-A6-EB",
  "powerState": "VM running",
  "privateIpAddress": "10.0.0.4",
  "publicIpAddress": "20.196.193.78",
  "resourceGroup": "for-living-template",
  "zones": ""
}
EOF

vm_id=$(echo $vm_create_result | jq -r '.id')

delete_azure_vm "$vm_id"

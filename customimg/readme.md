## azure
https://learn.microsoft.com/en-us/azure/virtual-machines/generalize#code-try-1
https://learn.microsoft.com/en-us/azure/virtual-machines/capture-image-resource


inside the vm:
sudo waagent -deprovision+user

az vm deallocate --resource-group for-living-template --name trojanwebperl
az vm generalize  --resource-group for-living-template --name trojanwebperl

az image create --resource-group for-living-template --name trojanwebperlImg --source trojanwebperl

az vm create -n cccc -g for-living-template --image /subscriptions/702e1d2b-b275-4b39-8480-a065e39474bd/resourceGroups/for-living-template/providers/Microsoft.Compute/images/trojanwebperlImg --admin-username azureuser --size  Standard_B1ls --authentication-type ssh --public-ip-sku Standard --verbose

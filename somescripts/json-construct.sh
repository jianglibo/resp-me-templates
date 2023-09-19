#!/bin/bash

function addFileToJsonObject() {
    local json="$1"
    local filename="$2"
    local filecontent="$(cat "$filename")"

    echo "$json" | jq --arg filename "$filename" --arg filecontent "$filecontent" \
    '. + { files: {filename: $filename, filecontent: $filecontent} }'
}

read -r -d '' multiline_var <<EOF
{
  "fqdns": "testing.koreacentral.cloudapp.azure.com",
  "id": "/subscriptions/00000000-0000-0000-0000-000000000000/resourceGroups/for-living-template/providers/Microsoft.Compute/virtualMachines/testing",
  "location": "koreacentral",
  "macAddress": "00-22-48-05-62-0C",
  "powerState": "VM running",
  "privateIpAddress": "10.0.0.4",
  "publicIpAddress": "20.196.196.46",
  "resourceGroup": "rg",
  "zones": ""
}
EOF
echo $multiline_var | jq -r '.fqdns'
# Example usage:
# originalJson='{"a": 1}'
# result=$(addFileToJsonObject "$originalJson" "f.txt")
# echo "$result"

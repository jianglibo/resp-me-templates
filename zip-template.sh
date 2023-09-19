#!/bin/bash

if [ $# -eq 0 ]; then
    echo "Usage: $0 <template-folder-name>"
    exit 1
fi

# Store the original working directory
original_dir=$(pwd)

cfg=$(cat ${original_dir}/___xsecret.json)
user_id=$(echo $cfg | jq -r .user_id)
url=$(echo $cfg | jq -r .url)
otp=$(echo $cfg | jq -r .otp)
echo "$user_id"
echo "$url"
echo "$otp"

# Get the directory path of the executing script
cd "$(dirname "$0")/$1"

if [[ -f "___call_me.sh" ]];then
    chmod +x ___call_me.sh
    ./___call_me.sh
fi

zipfile="${1%/}.zip"
sha256sumfile="${1%/}.sha256"
if [[ -f "$zipfile" ]]; then
    rm $zipfile
fi

zip $zipfile ./*.* -x "$sha256sumfile" "___*" secret_settings_tpl.json xsecret_tpl.json

echo $(cat $sha256sumfile)
sha256sum "$zipfile" | tee "$sha256sumfile"

importTemplate="false"
for element in "$@"; do
    if [ "$element" == "--upload" ]; then
        importTemplate="true"
        break
    fi
done

if [[ $importTemplate == "true" ]]; then
    asset=$(curl -H "X-TOBE-CLIENT-SECRET: $otp" -F file=@"${zipfile}" "${url}/upload-with-secret")
    echo "$asset" | jq -r '.'
    if [ "$?" -ne 0 ]; then
        echo "upload template failed."
        echo "$asset"
        exit 210
    fi
    asset_id=$(echo $asset | jq -r .data[0].id)
    if [[ ( "$?" -ne 0 ) || ( -z "$asset_id" ) ]]; then
        echo "extract asset_id failed."
        echo "$asset"
        exit 210
    fi
    echo "asset_id:$asset_id"
    postBody=$(
        cat <<EOF
{
    "variables": {
        "object": {
            "asset_id": $asset_id,
            "user_id": $user_id
        }
    },
    "sub_action": "import",
    "action": "create",
    "target": "deploy_templates"
}
EOF
    )
    postResult=$(curl -H "X-TOBE-CLIENT-SECRET: $otp" -H "Content-Type: application/json" -X POST -d "$postBody" "${url}/tobe/graphql/3")
    echo "import template result:"
    echo "$postResult" | jq -r '.'
    if [ "$?" -ne 0 ]; then
        echo "import template failed."
        echo "post body:"
        echo "$postBody"
        echo "post result:"
        echo "$postResult"
        exit 210
    fi
    template_id=$(echo $postResult | jq -r .data.id)

    if [[ -f "./___secret_settings.json" ]]; then
        updateBody=$(
            cat <<EOF
{
    "variables": {
        "_set": {
            "id": $template_id,
            "settings": $(cat ./___secret_settings.json)
        }
    },
    "sub_action": "",
    "action": "update",
    "target": "deploy_templates"
}
EOF
        )
        echo "$updateBody"
        updateResult=$(curl -H "X-TOBE-CLIENT-SECRET: $otp" -H "Content-Type: application/json" -X POST -d "$updateBody" "${url}/tobe/graphql/3")
        echo "$updateResult" | jq -r '.'
        if [ "$?" -ne 0 ]; then
            echo "update deploy template failed."
            echo "$updateResult"
            exit 210
        fi
    fi

fi

cd "$original_dir"

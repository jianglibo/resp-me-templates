#!/bin/bash

connection=$(cat << EOF
{
	"host": "hostname",
	"port": 22,
	"user": "azureuser",
	"workingdir": "/home/azureuser",
	"sudo": true,
	"exec": false,
	"sshkey_id": 5109
}
EOF
)

settings=$(cat << EOF
{
		"connection": $connection,
		"mustache": {
			"scopes": {
				"mysql_root_password": "",
				"db_name": "",
				"db_user": "",
				"db_user_password": ""
			},
			"templates": [
				{
					"template": "setup-mysql.sh",
					"scopes": {}
				}
			]
		}
	}
EOF
)
echo "$settings"

cert_result=$(cat << EOF
{"data":{"id":684,"name":"free-sub-domain-cert","settings":"{\"domain_id\":388,\"mustache\":{\"scopes\":{\"domain_name\":\"d29.free-ssl.me\",\"ip_address\":\"20.249.0.128\"},\"templates\":[]}}","pause":false,"cron":null,"next":null,"secret":"XDZZ58e8E87xLoj2ie3aVX9g0j1VI7U1d9U0dPidtxvKBw9mtYOUrSm4eyL74BB4","region":null,"main":false,"description":null,"entityMeta":null,"responseMeta":null,"scriptFile":null,"cloudResources":null,"output":null,"template_id":null,"setting_schema":null,"deploy_to":"certification","user_id":30,"keep_working_env":false,"created_at":"2023-08-20T20:52:22.890128+08:00","updated_at":"2023-08-20T20:52:22.890128+08:00","main_definition_id":null,"description_url":null}}
EOF
)

settings_str=$(echo $cert_result | jq -r .data.settings)
host=$(echo $settings_str|jq .mustache.scopes.domain_name)
# host=$(echo $cert_result | jq -r .data.settings)

connection=$(cat << EOF
{
			"host": $host,
			"port": 22,
			"user": "azureuser",
			"workingdir": "/home/azureuser",
			"sudo": true,
			"exec": false,
			"sshkey_id": $sshkey_id
		}
EOF
)
echo $connection
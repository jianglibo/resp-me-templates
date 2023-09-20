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

echo "deploy definition id: ${THIS_DEPLOY_DEFINITION_ID}"

# body=$(
# 	cat <<EOF
# {
# 	"name": "hello",
# 	"cron_expression": "0 0 ccc0 * * *",
# 	"params": {
# 		"entrypoint_params": ["deploy"],
# 		"definition_id": 5,
# 		"template_id": ${THIS_TEMPLATE_ID},
# 		"template_deploy_history_id": ${THIS_TEMPLATE_DEPLOY_HISTORY_ID}
# 	},
# 	"owner_type": "deploy_definitions",
# 	"owner_id": 760
# }
# EOF
# )

# add_deploy_cron "$body"

echo "${1:-{}}"
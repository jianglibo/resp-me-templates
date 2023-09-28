#!/bin/bash

#!/bin/bash

action="$1"
if ! command -v tree; then
	apt install tree
fi

RJBHOME="/root/.jbang"
alias j!=jbang
export PATH="$RJBHOME/bin:$RJBHOME/currentjdk/bin:$PATH"
export JAVA_HOME="$RJBHOME/currentjdk"

if command -v jbang; then
	echo "jbang already installed"
else
	echo "Installing jbang"
	curl -Ls https://sh.jbang.dev | bash -s - app setup
fi

source ./deploy-util.sh
date -u
tree
echo "the action is: $action"
if [[ "$action" == "cert" ]]; then
	echo "start copying certs..."
	# /etc/nginx/sites-available/resp.me
	if [[ $? -ne 0 ]]; then
		echo "last exit code is non-zero. Exiting...."
	fi
	systemctl reload nginx

	appId={{appId}}
	password={{password}}
	tenant={{tenant}}
	resourceId={{resourceId}}
	resourceGroup={{resourceGroup}}
	appname={{appname}}

	az login --service-principal -u ${appId} -p ${password} --tenant ${tenant}

	az config set extension.use_dynamic_install=yes_without_prompt

	hostname="resp.me"
	pfx_password=$(cat dependencies/396/pfx_password.txt)
	certificate_file="dependencies/396/pfxfile_1.1.1f.pfx"
	az containerapp ssl upload -g ${resourceGroup} --name ${appname} -f ${certificate_file} -e ${resourceId} -p "${pfx_password}" --hostname ${hostname}

	hostname="dev.resp.me"
	certificate_file="dependencies/397/pfxfile_1.1.1f.pfx"
	pfx_password=$(cat dependencies/397/pfx_password.txt)
	az containerapp ssl upload -g ${resourceGroup} --name ${appname} -f ${certificate_file} -e ${resourceId} -p "${pfx_password}" --hostname ${hostname}

elif [[ "$action" == "destroy" ]]; then
	echo "start destroying trojanweb ..."
elif [[ "$action" == "redeploy" ]]; then
	echo "start redeploying..."
else
	echo "start deploying trojanweb..."
	# source ./deploy.sh
fi

date -u

exit 210

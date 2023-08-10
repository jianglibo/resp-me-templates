#!/bin/bash

# Function to check if a package is installed
is_package_installed() {
	dpkg -l "$1" &>/dev/null
}

# Check if rabbitmq-server is installed, and if not, install it
if ! is_package_installed minio; then
	echo "minio is not installed. Installing minio..."
	wget https://dl.min.io/server/minio/release/linux-amd64/minio_20230809233022.0.0_amd64.deb
	dpkg -i minio_20230809233022.0.0_amd64.deb

	# In case you want to delete it.
	# sudo dpkg -r minio
	# sudo dpkg -P minio

	groupadd -r minio-user
	useradd -M -r -g minio-user minio-user
	mkdir -p "{{MINIO_VOLUMES}}"
	chown minio-user:minio-user "{{MINIO_VOLUMES}}"
fi

cp -f ./minio.env /etc/default/minio

DOMAIN_NAME={{#cert_dependency}}{{domain_name}}{{/cert_dependency}}

to_dir="/opt/minio/certs"

mkdir -p "$to_dir"
backup_dir="$(dirname "$to_dir")/certs_$(date +'%Y%m%d%H%M%S')"
# Create the backup directory
mkdir -p "$backup_dir"

# Copy the contents of the source directory to the backup directory
cp "${to_dir}/public.crt" "${backup_dir}/"
cp "${to_dir}/private.key" "${backup_dir}/"

cp -f "./certs/${DOMAIN_NAME}/fullchain.cer" "${to_dir}/public.crt"
cp -f "./certs/${DOMAIN_NAME}/${DOMAIN_NAME}.key" "${to_dir}/private.key"

sudo systemctl start minio.service
sudo systemctl status minio.service
# journalctl -f -u minio.service

# prevent deleting after execution.
exit 210
#!/bin/bash

echo "something changed."
# Check if unzip is already installed
if ! command -v unzip &>/dev/null; then
	# Install unzip
	sudo apt-get update
	sudo apt-get install unzip
	echo "unzip installed successfully."
else
	echo "unzip is already installed."
fi

source ./setup-nginx.sh
source ./setup-rabbitmq.sh

exit 210
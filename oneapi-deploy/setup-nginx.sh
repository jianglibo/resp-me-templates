#!/bin/bash

NGINX_BASE="/etc/nginx"
# Check if nginx is installed, and if not, install nginx-full
if ! command -v nginx &> /dev/null; then
  echo "Nginx is not installed. Installing nginx-full..."
  sudo apt -q update
  sudo apt -q install -y nginx-full
fi

if grep -q "oneapi" "${NGINX_BASE}/nginx.conf"; then
    echo "File already contains the specific string."
else
    cp "nginx.conf" "${NGINX_BASE}/nginx.conf"
    mkdir -p "${NGINX_BASE}/certs"
fi
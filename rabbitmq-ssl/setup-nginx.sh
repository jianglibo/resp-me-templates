#!/bin/bash

NGINX_BASE="/etc/nginx"
# Check if nginx is installed, and if not, install nginx-full
if ! command -v nginx &> /dev/null; then
  echo "Nginx is not installed. Installing nginx-full..."
  sudo apt update
  sudo apt install -y nginx-full
fi

rm -rf /etc/nginx/sites-enabled/default

# Check if the config file /etc/nginx/sites-available/{{sitename}} exists, and if not, copy the file {{sitename}}
if [ ! -f /etc/nginx/sites-available/{{sitename}} ]; then
  echo "Config file ${NGINX_BASE}/sites-available/{{sitename}} not found. Copying {{sitename}} to the appropriate location..."
  sudo cp rabbitmq-proxy-15672.conf ${NGINX_BASE}/sites-available/{{sitename}}
fi

# Create a symbolic link from /etc/nginx/sites-enabled/{{sitename}} to /etc/nginx/sites-available/{{sitename}}
if [ ! -f "${NGINX_BASE}/sites-enabled/{{sitename}}" ]; then
  echo "Creating symbolic link from ${NGINX_BASE}/sites-available/{{sitename}} to ${NGINX_BASE}/sites-enabled/{{sitename}}..."
  sudo ln -s "${NGINX_BASE}/sites-available/{{sitename}}" "${NGINX_BASE}/sites-enabled/{{sitename}}"
fi

if grep -q "rabbitmq_backend" "${NGINX_BASE}/nginx.conf"; then
    echo "File already contains the specific string."
else
    cat "rabbitmq-proxy-5761.conf" >> "${NGINX_BASE}/nginx.conf"
    echo "Content appended to the file."
fi

# Reload nginx to apply the changes
echo "Reloading nginx..."
sudo nginx -s reload

echo "Nginx installation and configuration completed successfully!"

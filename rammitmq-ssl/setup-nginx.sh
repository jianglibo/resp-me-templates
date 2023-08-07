#!/bin/bash


# Check if nginx is installed, and if not, install nginx-full
if ! command -v nginx &> /dev/null; then
  echo "Nginx is not installed. Installing nginx-full..."
  sudo apt update
  sudo apt install -y nginx-full
fi

rm -rf /etc/nginx/sites-enabled/default

# Check if the config file /etc/nginx/sites-available/{{sitename}} exists, and if not, copy the file {{sitename}}
if [ ! -f /etc/nginx/sites-available/{{sitename}} ]; then
  echo "Config file /etc/nginx/sites-available/{{sitename}} not found. Copying {{sitename}} to the appropriate location..."
  sudo cp rabbitmq-proxy-15672.conf /etc/nginx/sites-available/{{sitename}}
fi

# Create a symbolic link from /etc/nginx/sites-enabled/{{sitename}} to /etc/nginx/sites-available/{{sitename}}
if [ ! -f /etc/nginx/sites-enabled/{{sitename}} ]; then
  echo "Creating symbolic link from /etc/nginx/sites-available/{{sitename}} to /etc/nginx/sites-enabled/{{sitename}}..."
  sudo ln -s /etc/nginx/sites-available/{{sitename}} /etc/nginx/sites-enabled/{{sitename}}
fi

# Check if the config file /etc/nginx/sites-available/amqp-{{sitename}} exists, and if not, copy the file amqp-{{sitename}}
if [ ! -f /etc/nginx/sites-available/amqp-{{sitename}} ]; then
  echo "Config file /etc/nginx/sites-available/amqp-{{sitename}} not found. Copying amqp-{{sitename}} to the appropriate location..."
  sudo cp rabbitmq-proxy-5671.conf /etc/nginx/sites-available/amqp-{{sitename}}
fi

# Create a symbolic link from /etc/nginx/sites-enabled/amqp-{{sitename}} to /etc/nginx/sites-available/amqp-{{sitename}}
if [ ! -f /etc/nginx/sites-enabled/amqp-{{sitename}} ]; then
  echo "Creating symbolic link from /etc/nginx/sites-available/amqp-{{sitename}} to /etc/nginx/sites-enabled/amqp-{{sitename}}..."
  sudo ln -s /etc/nginx/sites-available/amqp-{{sitename}} /etc/nginx/sites-enabled/amqp-{{sitename}}
fi

# Reload nginx to apply the changes
echo "Reloading nginx..."
sudo nginx -s reload

echo "Nginx installation and configuration completed successfully!"

#!/bin/bash

# Function to check if a package is installed
is_package_installed() {
  dpkg -l "$1" &> /dev/null
}

# Check if rabbitmq-server is installed, and if not, install it
if ! is_package_installed rabbitmq-server; then
  echo "rabbitmq-server is not installed. Installing rabbitmq-server..."
  sudo apt update
  sudo apt install -y rabbitmq-server
fi

#!/bin/bash

# Function to check if RabbitMQ service is active
is_rabbitmq_active() {
  sudo systemctl is-active rabbitmq-server &> /dev/null
}

# Wait for RabbitMQ to start, with a maximum of 3 tries
MAX_TRIES=3
tries=0

echo "Waiting for RabbitMQ to start..."
while [ $tries -lt $MAX_TRIES ]; do
  if is_rabbitmq_active; then
    echo "RabbitMQ is now active and running!"
    break
  fi

  tries=$((tries + 1))
  if [ $tries -lt $MAX_TRIES ]; then
    echo "Attempt $tries: RabbitMQ is not active yet. Retrying in 5 seconds..."
    sleep 5
  fi
done

if [ $tries -eq $MAX_TRIES ]; then
  echo "Giving up after $MAX_TRIES attempts. RabbitMQ did not start."
  exit 1
fi

# Enable RabbitMQ management plugin
sudo rabbitmq-plugins enable rabbitmq_management

sudo rabbitmqctl add_user {{rabbitmqAdminName}} {{rabbitmqAdminPassword}}

sudo rabbitmqctl change_password {{rabbitmqAdminName}} {{rabbitmqAdminPassword}}

sudo rabbitmqctl set_user_tags {{rabbitmqAdminName}} administrator

sudo rabbitmqctl set_permissions -p / {{rabbitmqAdminName}} ".*" ".*" ".*"

sudo rabbitmqctl delete_user guest

sudo rabbitmqctl clear_password guest

sudo systemctl restart rabbitmq-server

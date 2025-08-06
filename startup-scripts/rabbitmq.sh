#!/bin/bash

# Import GPG keys
curl -fsSL https://github.com/rabbitmq/signing-keys/releases/download/3.0/rabbitmq-release-signing-key.asc | sudo apt-key add -
curl -fsSL https://github.com/rabbitmq/signing-keys/releases/download/3.0/cloudsmith.rabbitmq-erlang.E495BB49CC4BBE5B.key | sudo apt-key add -
curl -fsSL https://github.com/rabbitmq/signing-keys/releases/download/3.0/cloudsmith.rabbitmq-server.9F4587F226208342.key | sudo apt-key add -

# Add repos (replace 'bookworm' with your Debian codename if needed)
echo "deb https://ppa1.novemberain.com/rabbitmq/rabbitmq-erlang/deb/debian bookworm main" | sudo tee /etc/apt/sources.list.d/rabbitmq-erlang.list
echo "deb https://ppa1.novemberain.com/rabbitmq/rabbitmq-server/deb/debian bookworm main" | sudo tee /etc/apt/sources.list.d/rabbitmq-server.list

# Update and install
sudo apt update
sudo apt install -y socat logrotate rabbitmq-server

# Enable & start service
sudo systemctl enable rabbitmq-server
sudo systemctl start rabbitmq-server

# Allow external connections
echo "[{rabbit, [{loopback_users, []}]}]." | sudo tee /etc/rabbitmq/rabbitmq.config
sudo systemctl restart rabbitmq-server

# Create admin user
sudo rabbitmqctl add_user test test
sudo rabbitmqctl set_user_tags test administrator
sudo rabbitmqctl set_permissions -p / test ".*" ".*" ".*"


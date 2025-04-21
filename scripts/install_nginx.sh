#!/bin/bash

set -e

# Install Nginx and configure UFW
echo "Installing Nginx and configuring UFW..."
apt update
apt install -y nginx
ufw allow 'Nginx Full'
ufw allow 'ssh'
echo "y" | ufw enable

echo "Nginx installed and UFW configured successfully."
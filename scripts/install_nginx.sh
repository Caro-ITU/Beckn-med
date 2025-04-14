#!/bin/bash

# Exit on any error
set -e

# Install Nginx and configure UFW
apt update
apt install -y nginx
ufw allow 'Nginx Full'
ufw allow 'ssh'
echo "y" | ufw enable

echo "Nginx installed and UFW configured successfully."
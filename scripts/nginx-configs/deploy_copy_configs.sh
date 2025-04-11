#!/bin/bash

# Path to SSH key (customize if different)
SSH_KEY="$HOME/.ssh/id_rsa"

# Check if SSH key exists
if [ ! -f "$SSH_KEY" ]; then
    echo "Error: SSH key $SSH_KEY not found"
    exit 1
fi

# Start ssh-agent and capture its environment variables
eval "$(ssh-agent -s)" > /dev/null
if [ $? -ne 0 ]; then
    echo "Error: Failed to start ssh-agent"
    exit 1
fi

# Prompt for SSH key passphrase
echo "Enter passphrase for SSH key $SSH_KEY (you will only be prompted once for this script):"
ssh-add "$SSH_KEY"
if [ $? -ne 0 ]; then
    echo "Error: Failed to add SSH key to ssh-agent"
    ssh-agent -k > /dev/null
    exit 1
fi

# Check if .env file exists
if [ ! -f ../.env ]; then
    echo "Error: .env file not found in /scripts/"
    ssh-agent -k > /dev/null
    exit 1
fi

# Read variables from .env
source ../.env

# Check required variables
if [ -z "$DOMAIN_NAME" ] || [ -z "$REGISTRY_IP" ] || [ -z "$GATEWAY_IP" ] || [ -z "$BAP_IP" ] || [ -z "$BPP_IP" ]; then
    echo "Error: Missing required variables (DOMAIN_NAME, REGISTRY_IP, GATEWAY_IP, BAP_IP, BPP_IP) in /scripts/.env"
    ssh-agent -k > /dev/null
    exit 1
fi

# SSH user
SSH_USER="root"

# Nginx path on remote servers
NGINX_AVAILABLE="/etc/nginx/sites-available"

# List of config files and their corresponding IPs
CONFIG_FILES=(
    "onix-registry.${DOMAIN_NAME}:${REGISTRY_IP}"
    "onix-gateway.${DOMAIN_NAME}:${GATEWAY_IP}"
    "onix-bap.${DOMAIN_NAME}:${BAP_IP}"
    "onix-bap-client.${DOMAIN_NAME}:${BAP_IP}"
    "onix-bpp.${DOMAIN_NAME}:${BPP_IP}"
    "onix-bpp-client.${DOMAIN_NAME}:${BPP_IP}"
)

echo "Copying configuration files to servers..."

for entry in "${CONFIG_FILES[@]}"; do
    # Split entry into config_file and server_ip
    config_file="${entry%%:*}"
    server_ip="${entry##*:}"

    if [ ! -f "$config_file" ]; then
        echo "Error: Config file $config_file not found in /scripts/nginx-scripts/"
        continue
    fi

    echo "Copying $config_file to $server_ip..."
    scp "$config_file" "${SSH_USER}@${server_ip}:${NGINX_AVAILABLE}/$config_file"
    if [ $? -ne 0 ]; then
        echo "Error: Failed to copy $config_file to $server_ip:$NGINX_AVAILABLE"
        continue
    fi

    echo "$config_file copied to $server_ip"
done

echo "Config file copying completed."

# Clean up ssh-agent
ssh-agent -k > /dev/null
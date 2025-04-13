#!/bin/bash

# Path to SSH key (customize if different)
SSH_KEY="$HOME/.ssh/id_rsa"

# Check if SSH key exists
if [ ! -f "$SSH_KEY" ]; then
    echo "Error: SSH key $SSH_KEY not found"
    exit 1
fi


# Check if .env file exists
if [ ! -f ../.env ]; then
    echo "Error: .env file not found in /scripts/"
    exit 1
fi

# Read variables from .env
source ../.env

# Check required variables
if [ -z "$DOMAIN_NAME" ] || [ -z "$REGISTRY_IP" ] || [ -z "$GATEWAY_IP" ] || [ -z "$BAP_IP" ] || [ -z "$BPP_IP" ]; then
    echo "Error: Missing required variables (DOMAIN_NAME, REGISTRY_IP, GATEWAY_IP, BAP_IP, BPP_IP) in /scripts/.env"
    exit 1
fi

# SSH user
SSH_USER="root"

# Nginx paths on remote servers
NGINX_AVAILABLE="/etc/nginx/sites-available"
NGINX_ENABLED="/etc/nginx/sites-enabled"

# List of config files and their corresponding IPs
CONFIG_FILES=(
    "onix-registry.${DOMAIN_NAME}:${REGISTRY_IP}"
    "onix-gateway.${DOMAIN_NAME}:${GATEWAY_IP}"
    "onix-bap.${DOMAIN_NAME}:${BAP_IP}"
    "onix-bap-client.${DOMAIN_NAME}:${BAP_IP}"
    "onix-bpp.${DOMAIN_NAME}:${BPP_IP}"
    "onix-bpp-client.${DOMAIN_NAME}:${BPP_IP}"
)

echo "Enabling configuration files on servers..."

for entry in "${CONFIG_FILES[@]}"; do
    # Split entry into config_file and server_ip
    config_file="${entry%%:*}"
    server_ip="${entry##*:}"

    echo "Enabling $config_file on $server_ip..."
    ssh "${SSH_USER}@${server_ip}" "sudo ln -sf $NGINX_AVAILABLE/$config_file $NGINX_ENABLED/$config_file"
    if [ $? -ne 0 ]; then
        echo "Error: Failed to enable $config_file on $server_ip"
        continue
    fi

    echo "$config_file enabled on $server_ip"
done

echo "Config file enabling completed."
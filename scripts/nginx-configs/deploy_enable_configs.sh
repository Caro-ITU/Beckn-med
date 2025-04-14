#!/bin/bash

# Exit on any error
set -e

# Nginx paths on remote server
NGINX_AVAILABLE="/etc/nginx/sites-available"
NGINX_ENABLED="/etc/nginx/sites-enabled"

# Determine config files to enable based on server
case "$CURRENT_SERVER" in
    "$REGISTRY_IP")
        CONFIG_FILES=("onix-registry.$DOMAIN_NAME")
        ;;
    "$GATEWAY_IP")
        CONFIG_FILES=("onix-gateway.$DOMAIN_NAME")
        ;;
    "$BAP_IP")
        CONFIG_FILES=("onix-bap.$DOMAIN_NAME" "onix-bap-client.$DOMAIN_NAME")
        ;;
    "$BPP_IP")
        CONFIG_FILES=("onix-bpp.$DOMAIN_NAME" "onix-bpp-client.$DOMAIN_NAME")
        ;;
    *)
        echo "Error: Unknown server $CURRENT_SERVER, cannot determine config files"
        exit 1
        ;;
esac

# Enable config files by creating symbolic links
for config_file in "${CONFIG_FILES[@]}"; do
    if [ ! -f "$NGINX_AVAILABLE/$config_file" ]; then
        echo "Error: Config file $NGINX_AVAILABLE/$config_file not found"
        exit 1
    fi

    echo "Enabling $config_file..."
    ln -sf "$NGINX_AVAILABLE/$config_file" "$NGINX_ENABLED/$config_file"
done

echo "Config files enabled successfully."
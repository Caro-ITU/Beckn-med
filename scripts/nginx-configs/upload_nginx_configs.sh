#!/bin/bash

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
NGINX_AVAILABLE="/etc/nginx/sites-available"

SERVERS=(
    "$REGISTRY_IP"
    "$GATEWAY_IP"
    "$BAP_IP"
    "$BPP_IP"
)

CONFIG_FILES=(
    "onix-registry2.$DOMAIN_NAME"
    "onix-gateway2.$DOMAIN_NAME"
    "onix-bap2.$DOMAIN_NAME onix-bap2-client.$DOMAIN_NAME"
    "onix-bpp2.$DOMAIN_NAME onix-bpp2-client.$DOMAIN_NAME onix-bpp2-ps.$DOMAIN_NAME"
)

# Iterate through each server and copy the respective config files
for i in "${!SERVERS[@]}"; do
    server="${SERVERS[$i]}"
    config_files="${CONFIG_FILES[$i]}"
    
    echo "Uploading config files to $server..."

    for config_file in $config_files; do
        local_file="$SCRIPT_DIR/$config_file"
    
        if [ ! -f "$local_file" ]; then
            echo "Error: Missing config file $local_file"
            exit 1
        fi
        
        echo "Copying $local_file to $server:$NGINX_AVAILABLE/"
        scp "$local_file" root@"$server":"$NGINX_AVAILABLE/"
        echo "Successfully uploaded $config_file to $server:$NGINX_AVAILABLE/"
    done
done

echo "All config files uploaded successfully!"

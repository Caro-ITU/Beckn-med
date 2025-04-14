#!/bin/bash

# Exit on any error
set -e

# Nginx path on remote server
NGINX_AVAILABLE="/etc/nginx/sites-available"

# Define local directory where generated configs are stored
# Get the directory of this script
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# List of servers and config files mapping (using indexed arrays)
SERVERS=(
    "$REGISTRY_IP"
    "$GATEWAY_IP"
    "$BAP_IP"
    "$BPP_IP"
)

# Corresponding config files for each server
CONFIG_FILES=(
    "onix-registry.$DOMAIN_NAME"
    "onix-gateway.$DOMAIN_NAME"
    "onix-bap.$DOMAIN_NAME onix-bap-client.$DOMAIN_NAME"
    "onix-bpp.$DOMAIN_NAME onix-bpp-client.$DOMAIN_NAME"
)

# Iterate through each server and copy the respective config files
for i in "${!SERVERS[@]}"; do
    server="${SERVERS[$i]}"
    config_files="${CONFIG_FILES[$i]}"
    
    echo "Uploading config files to $server..."
    
    # Loop through config files for the current server
    for config_file in $config_files; do
        # Define the local file path (absolute path on the local machine)
        local_file="$SCRIPT_DIR/$config_file"
        
        if [ ! -f "$local_file" ]; then
            echo "Error: Missing config file $local_file"
            exit 1
        fi
        
        echo "Copying $local_file to $server:$NGINX_AVAILABLE/"
        scp "$local_file" root@"$server":"$NGINX_AVAILABLE/"
        echo "Deployed $config_file to $server:$NGINX_AVAILABLE/"
    done
done

echo "All config files uploaded successfully!"

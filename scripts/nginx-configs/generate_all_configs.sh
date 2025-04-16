#!/bin/bash

# Exit on any error
set -e

# Get the directory of this script
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# List of configuration scripts (relative to nginx-configs/)
SCRIPTS=(
    "generate_bap_config.sh"
    "generate_bap_client_config.sh"
    "generate_bpp_config.sh"
    "generate_bpp_client_config.sh"
    "generate_bpp_webhook_config.sh"
    "generate_gateway_config.sh"
    "generate_registry_config.sh"
)

echo "Generating configurations for DOMAIN_NAME=$DOMAIN_NAME in $CONFIG_DIR..."

# Run each script, executing them from their absolute path
for script in "${SCRIPTS[@]}"; do
    echo "Running $script..."
    bash "$SCRIPT_DIR/$script"
done

echo "All configurations generated successfully in $CONFIG_DIR."

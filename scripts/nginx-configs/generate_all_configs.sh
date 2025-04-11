#!/bin/bash

# Check if .env file exists
if [ ! -f ../.env ]; then
    echo "Error: .env file not found in /scripts/"
    exit 1
fi

# Read DOMAIN_NAME from .env
DOMAIN_NAME=$(grep '^DOMAIN_NAME=' ../.env | cut -d '=' -f2)

# Check if DOMAIN_NAME is set
if [ -z "$DOMAIN_NAME" ]; then
    echo "Error: DOMAIN_NAME not found in /scripts/.env file"
    exit 1
fi

# Run individual scripts
echo "Generating configurations for DOMAIN_NAME=$DOMAIN_NAME..."

./generate_bap_config.sh
if [ $? -ne 0 ]; then
    echo "Error generating BAP config"
    exit 1
fi

./generate_bap_client_config.sh
if [ $? -ne 0 ]; then
    echo "Error generating BAP client config"
    exit 1
fi

./generate_bpp_config.sh
if [ $? -ne 0 ]; then
    echo "Error generating BPP config"
    exit 1
fi

./generate_bpp_client_config.sh
if [ $? -ne 0 ]; then
    echo "Error generating BPP client config"
    exit 1
fi

./generate_gateway_config.sh
if [ $? -ne 0 ]; then
    echo "Error generating gateway config"
    exit 1
fi

./generate_registry_config.sh
if [ $? -ne 0 ]; then
    echo "Error generating registry config"
    exit 1
fi

echo "All configurations generated successfully."
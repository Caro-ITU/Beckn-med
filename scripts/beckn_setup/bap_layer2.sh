#!/bin/bash

set -e

REQUIRED_VARS=("BPP_SETUP_ID" "BPP_URL" "WEBHOOK_URL" "REGISTRY_URL" "REGISTRY_USERNAME" "REGISTRY_PASSWORD" "LAYER2_CONFIG" )
for var in "${REQUIRED_VARS[@]}"; do
    if [ -z "${!var}" ]; then
        echo "Error: $var is not set"
        exit 1
    fi
done

cd beckn-onix/layer2 || { echo "beckn-onix/ repository not found on the BAP server"; exit 1; }
echo "Configuring layer2 for $BAP_SETUP_ID at $BAP_URL"

bash download_layer_2_config_bap.sh <<EOF
$LAYER2_CONFIG
EOF

echo "✅ BAP setup complete for $BAP_SETUP_ID"

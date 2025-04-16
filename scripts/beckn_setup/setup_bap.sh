#!/bin/bash

set -e

REQUIRED_VARS=("BAP_SETUP_ID" "BAP_URL" "REGISTRY_URL" "REGISTRY_USERNAME" "REGISTRY_PASSWORD" "LAYER2_CONFIG")
for var in "${REQUIRED_VARS[@]}"; do
    if [ -z "${!var}" ]; then
        echo "Error: $var is not set"
        exit 1
    fi
done

cd beckn-onix/install || { echo "ONIX repo not found at beckn-onix/install"; exit 1; }
sudo usermod -aG docker $USER
echo "🚀 Starting BAP setup for $BAP_SETUP_ID at $BAP_URL"

# --------------------------
# Run beckn-onix.sh with inputs
# --------------------------
bash beckn-onix.sh <<EOF
1
2
$BAP_SETUP_ID
$BAP_URL
$REGISTRY_URL/subscribers
$REGISTRY_USERNAME
$REGISTRY_PASSWORD
Y
retail_1.1.0
$LAYER2_CONFIG
EOF

echo "✅ BAP setup complete for $BAP_SETUP_ID"

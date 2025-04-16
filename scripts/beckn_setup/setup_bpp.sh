#!/bin/bash

set -e

REQUIRED_VARS=("BPP_SETUP_ID" "BPP_URL" "WEBHOOK_URL" "REGISTRY_URL" "REGISTRY_USERNAME" "REGISTRY_PASSWORD" "LAYER2_CONFIG" )
for var in "${REQUIRED_VARS[@]}"; do
    if [ -z "${!var}" ]; then
        echo "Error: $var is not set"
        exit 1
    fi
done

cd beckn-onix/install || { echo "ONIX repo not found at beckn-onix/install"; exit 1; }
sudo usermod -aG docker $USER
echo "🚀 Starting BPP setup for $BPP_SETUP_ID at $BPP_URL"

# --------------------------
# Run beckn-onix.sh with inputs
# --------------------------
bash beckn-onix.sh <<EOF
1
3
$BPP_SETUP_ID
$BPP_URL
$WEBHOOK_URL
$REGISTRY_URL/subscribers
$REGISTRY_USERNAME
$REGISTRY_PASSWORD
N

EOF

echo "✅ BPP setup complete for $BPP_SETUP_ID"

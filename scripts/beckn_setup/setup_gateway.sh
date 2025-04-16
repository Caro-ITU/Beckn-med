#!/bin/bash

set -e

# --------------------------
# Input validation
# --------------------------
REQUIRED_VARS=("REGISTRY_URL" "GATEWAY_URL")
for var in "${REQUIRED_VARS[@]}"; do
    if [ -z "${!var}" ]; then
        echo "Error: $var is not set"
        exit 1
    fi
done

cd beckn-onix/install || { echo "ONIX repo not found at beckn-onix/install"; exit 1; }
sudo usermod -aG docker $USER
echo "🚀 Starting Gateway setup at $GATEWAY_URL"

# --------------------------
# Run beckn-onix.sh with inputs
# --------------------------
bash beckn-onix.sh <<EOF
1
1
$REGISTRY_URL
$GATEWAY_URL
EOF

echo "✅ Gateway setup complete at $GATEWAY_URL"

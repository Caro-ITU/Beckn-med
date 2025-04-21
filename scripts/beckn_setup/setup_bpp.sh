#!/bin/bash

set -e

REQUIRED_VARS=("BPP_SETUP_ID" "BPP_URL" "WEBHOOK_URL" "REGISTRY_URL" "REGISTRY_USERNAME" "REGISTRY_PASSWORD" )
for var in "${REQUIRED_VARS[@]}"; do
    if [ -z "${!var}" ]; then
        echo "Error: $var is not set"
        exit 1
    fi
done

cd beckn-onix/install || { echo "beckn-onix/ repository not found on the BPP server"; exit 1; }
echo "🚀 Starting BPP setup for $BPP_SETUP_ID at $BPP_URL"

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

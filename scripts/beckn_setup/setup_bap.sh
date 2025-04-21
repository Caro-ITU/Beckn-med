#!/bin/bash

set -e

REQUIRED_VARS=("BAP_SETUP_ID" "BAP_URL" "REGISTRY_URL" "REGISTRY_USERNAME" "REGISTRY_PASSWORD")
for var in "${REQUIRED_VARS[@]}"; do
    if [ -z "${!var}" ]; then
        echo "Error: $var is not set"
        exit 1
    fi
done

cd beckn-onix/install || { echo "beckn-onix/ repository not found on the BAP server"; exit 1; }
echo "🚀 Starting BAP setup for $BAP_SETUP_ID at $BAP_URL"

bash beckn-onix.sh <<EOF
1
2
$BAP_SETUP_ID
$BAP_URL
$REGISTRY_URL/subscribers
$REGISTRY_USERNAME
$REGISTRY_PASSWORD
N

EOF

echo "✅ BAP setup complete for $BAP_SETUP_ID"

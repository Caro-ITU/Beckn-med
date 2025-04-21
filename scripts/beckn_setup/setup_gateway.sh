#!/bin/bash

set -e

REQUIRED_VARS=("REGISTRY_URL" "GATEWAY_URL")
for var in "${REQUIRED_VARS[@]}"; do
    if [ -z "${!var}" ]; then
        echo "Error: $var is not set"
        exit 1
    fi
done

cd beckn-onix/install || { echo "beckn-onix/ repository not found on the gateway server"; exit 1; }
echo "🚀 Starting Gateway setup at $GATEWAY_URL"

bash beckn-onix.sh <<EOF
1
1
$REGISTRY_URL
$GATEWAY_URL
EOF

echo "✅ Gateway setup complete at $GATEWAY_URL"

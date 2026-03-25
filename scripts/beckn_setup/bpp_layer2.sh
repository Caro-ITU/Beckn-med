#!/bin/bash

set -e

REQUIRED_VARS=("BPP_SETUP_ID" "BPP_URL" "WEBHOOK_URL" "REGISTRY_URL" "REGISTRY_USERNAME" "REGISTRY_PASSWORD" "LAYER2_DOMAIN" "LAYER2_VERSION" )
for var in "${REQUIRED_VARS[@]}"; do
    if [ -z "${!var}" ]; then
        echo "Error: $var is not set"
        exit 1
    fi
done

echo "Configuring layer2 for $BPP_SETUP_ID at $BPP_URL"

PROCESSED_DOMAIN=$(echo "$LAYER2_DOMAIN" | tr ':' '_')
FINAL_FILENAME="${PROCESSED_DOMAIN}_${LAYER2_VERSION}.yaml"

docker exec bpp-client cp "schemas/core_${LAYER2_VERSION}.yaml" "schemas/$FINAL_FILENAME"
docker exec bpp-network cp "schemas/core_${LAYER2_VERSION}.yaml" "schemas/$FINAL_FILENAME"

echo "BPP setup complete for $BPP_SETUP_ID"

#!/bin/bash

set -e

REQUIRED_VARS=("REGISTRY_URL")
for var in "${REQUIRED_VARS[@]}"; do
    if [ -z "${!var}" ]; then
        echo "Error: $var is not set"
        exit 1
    fi
done

cd beckn-onix/install || { echo "ONIX repo not found at beckn-onix/install"; exit 1; }
sudo usermod -aG docker $USER

bash beckn-onix.sh <<EOF
2
1
$REGISTRY_URL
EOF

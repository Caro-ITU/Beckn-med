#!/bin/bash

set -e

REQUIRED_VARS=("REGISTRY_URL")
for var in "${REQUIRED_VARS[@]}"; do
    if [ -z "${!var}" ]; then
        echo "Error: $var is not set"
        exit 1
    fi
done

cd beckn-onix/install || { echo "beckn-onix/ repository not found on the registry server"; exit 1; }

bash beckn-onix.sh <<EOF
2
1
$REGISTRY_URL
EOF

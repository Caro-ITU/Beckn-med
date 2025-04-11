#!/bin/bash

# Ask for domain name
read -rp "Enter domain name (e.g. example.com): " DOMAIN_NAME

# Path to the template file (relative to where this script is located)
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
TEMPLATE_PATH="$SCRIPT_DIR/../config/nginx_bap_configs/onix-bap-client.foodeez.dk"

# Output file with the same name as the domain
OUTPUT_PATH="$SCRIPT_DIR/${DOMAIN_NAME}"

# Replace all instances of your_domain with the provided domain name
sed "s|your_domain|$DOMAIN_NAME|g" "$TEMPLATE_PATH" > "$OUTPUT_PATH"

echo "Generated config saved to: $OUTPUT_PATH"

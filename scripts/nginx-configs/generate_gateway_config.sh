#!/bin/bash

set -e

# Define the output directory (nginx-configs/ relative to SCRIPT_DIR)
OUTPUT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# Define output file
OUTPUT_FILE="$OUTPUT_DIR/onix-gateway.${DOMAIN_NAME}"

# Generate configuration
cat > "$OUTPUT_FILE" << EOF
server {
    listen 80;
    listen [::]:80;
    server_name onix-gateway.${DOMAIN_NAME};
    location / {
        proxy_set_header Host \$host;
        proxy_set_header X-Real-IP \$remote_addr;
        proxy_pass "http://localhost:4030/";
    }
}
EOF

echo "Generated $OUTPUT_FILE"
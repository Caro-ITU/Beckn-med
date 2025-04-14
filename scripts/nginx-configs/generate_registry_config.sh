#!/bin/bash

set -e

# Define the output directory (nginx-configs/ relative to SCRIPT_DIR)
OUTPUT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# Define output file
OUTPUT_FILE="$OUTPUT_DIR/onix-registry.${DOMAIN_NAME}"

# Generate configuration
cat > "$OUTPUT_FILE" << EOF
server {
    listen 80;
    listen [::]:80;
    server_name onix-registry.${DOMAIN_NAME};
    location / {
        proxy_set_header Host \$http_host;
        proxy_set_header X-Real-IP \$remote_addr;
        proxy_set_header X-Forwarded-For \$proxy_add_x_forwarded_for;
        proxy_set_header Upgrade \$http_upgrade;
        proxy_set_header Connection "upgrade";
        proxy_pass "http://localhost:3030";
    }
}
EOF

echo "Generated $OUTPUT_FILE"
#!/bin/bash

# Check if .env file exists
if [ ! -f ../.env ]; then
    echo "Error: .env file not found in /scripts/"
    exit 1
fi

# Read DOMAIN_NAME from .env
DOMAIN_NAME=$(grep '^DOMAIN_NAME=' ../.env | cut -d '=' -f2)

# Check if DOMAIN_NAME is set
if [ -z "$DOMAIN_NAME" ]; then
    echo "Error: DOMAIN_NAME not found in /scripts/.env file"
    exit 1
fi

# Define output file
OUTPUT_FILE="onix-gateway.${DOMAIN_NAME}"

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
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
OUTPUT_FILE="onix-registry.${DOMAIN_NAME}"

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
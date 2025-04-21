#!/bin/bash

set -e

# Define the output directory (nginx-configs/ relative to SCRIPT_DIR)
OUTPUT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
DOMAIN="onix-bpp2-ps.${DOMAIN_NAME}"
PROXY_PASS="http://localhost:3009"
OUTPUT_FILE="$OUTPUT_DIR/$DOMAIN"

cat > "$OUTPUT_FILE" << EOF
server {
    server_name $DOMAIN;
    location / {
        proxy_pass "$PROXY_PASS";
    }
}

server {
    if (\$host = $DOMAIN) {
        return 301 https://\$host\$request_uri;
    } # managed by Certbot

    listen 80;
    listen [::]:80;
    server_name $DOMAIN;
    return 404; # managed by Certbot
}
EOF

echo "Generated $OUTPUT_FILE"

#!/bin/bash

set -e 

# Define the output directory (nginx-configs/ relative to SCRIPT_DIR)
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

OUTPUT_FILE="$SCRIPT_DIR/onix-bap2-client.${DOMAIN_NAME}"

cat > "$OUTPUT_FILE" << EOF
server {
    listen 80;
    listen [::]:80;
    server_name onix-bap2-client.${DOMAIN_NAME};
    location / {
        # This for Host, Client and Forwarded For
        proxy_set_header Host \$http_host;
        proxy_set_header X-Real-IP \$remote_addr;
        proxy_set_header X-Forwarded-For \$proxy_add_x_forwarded_for;

        # For Web Sockets
        #proxy_http_version 1.1;
        proxy_set_header Upgrade \$http_upgrade;
        proxy_set_header Connection "upgrade";

        # For Proxy (assuming 5001 for client, adjust if needed)
        proxy_pass "http://localhost:5001";
    }
}
EOF

echo "Generated $OUTPUT_FILE"

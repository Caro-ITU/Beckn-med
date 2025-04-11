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
OUTPUT_FILE="onix-bpp.${DOMAIN_NAME}"

# Generate configuration
cat > "$OUTPUT_FILE" << EOF
server {
        server_name onix-bpp.${DOMAIN_NAME};
        location / {
                # This for Host, Client and Forwarded For
                proxy_set_header Host \$http_host;
                proxy_set_header X-Real-IP \$remote_addr;
                proxy_set_header X-Forwarded-For \$proxy_add_x_forwarded_for;

                # For Web Sockets.
                #proxy_http_version 1.1;
                proxy_set_header Upgrade \$http_upgrade;
                proxy_set_header Connection "upgrade";

                # For Proxy.
                proxy_pass "http://127.0.0.1:6002";
        }

}
server {
    if (\$host = onix-bpp.${DOMAIN_NAME}) {
        return 301 https://\$host\$request_uri;
    } # managed by Certbot

        listen 80;
        listen [::]:80;
        server_name onix-bpp.${DOMAIN_NAME};
    return 404; # managed by Certbot

}
EOF

echo "Generated $OUTPUT_FILE"
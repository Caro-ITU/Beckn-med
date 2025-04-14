#!/bin/bash

set -e

# Define the output directory (nginx-configs/ relative to SCRIPT_DIR)
OUTPUT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# Define output file
OUTPUT_FILE="$OUTPUT_DIR/onix-registry.${DOMAIN_NAME}"

# Generate configuration
cat > "$OUTPUT_FILE" << EOF
server {
    server_name onix-registry.${DOMAIN_NAME};
    
    underscores_in_headers on;
    gzip on;
    gzip_disable "msie6";
    gzip_vary on;
    gzip_proxied any;
    gzip_comp_level 6;
    gzip_buffers 16 8k;
    gzip_http_version 1.1;
    gzip_min_length 256;
    gzip_types text/plain text/css application/json application/x-javascript text/xml application/xml application/xml+rss application/javascript text/javascript application/vnd.ms-fontobject application/x-font-ttf font/opentype image/svg+xml image/x-icon font/woff font/woff2 application/octet-stream font/ttf;

    
    access_log /var/log/nginx/app_beckn_registry_access.log;
    error_log /var/log/nginx/app_beckn_registry_error.log debug;
    client_max_body_size 10M;
    
    location / {
        if (\$uri ~* "\.(jpg|jpeg|png|gif|ico|ttf|eot|svg|woff|woff2|css|js)$") {
            add_header 'Cache-Control' 'no-cache';
        }
        
        proxy_set_header Host \$http_host;
        proxy_set_header X-Real-IP \$remote_addr;
        proxy_set_header X-Forwarded-For \$proxy_add_x_forwarded_for;
        proxy_set_header X-URIScheme https;
        proxy_set_header Upgrade \$http_upgrade;
        proxy_set_header Connection "upgrade";
        
        proxy_pass "http://localhost:3030";
        
        set \$cors 'true';
        
        add_header 'Access-Control-Allow-Origin' "\$http_origin" always;
        
        if (\$cors = 'true') {
            add_header 'Access-Control-Allow-Credentials' 'true' always;
            add_header 'Access-Control-Allow-Methods' 'GET, POST, PUT, DELETE, OPTIONS' always;
            add_header 'Access-Control-Allow-Headers' 'Accept,Authorization,Cache-Control,Content-Type,DNT,If-Modified-Since,Keep-Alive,Origin,User-Agent,X-Requested-With,Range,ApiKey,pub_key_format' always;
        }
        
        if (\$request_method = 'OPTIONS') {
            add_header 'Access-Control-Allow-Origin' "\$http_origin" always;
            add_header 'Access-Control-Allow-Credentials' 'true' always;
            add_header 'Access-Control-Allow-Methods' 'GET, POST, PUT, DELETE, OPTIONS' always;
            add_header 'Access-Control-Allow-Headers' 'Accept,Authorization,Cache-Control,Content-Type,DNT,If-Modified-Since,Keep-Alive,Origin,User-Agent,X-Requested-With,Range,ApiKey,pub_key_format' always;
            add_header 'Access-Control-Max-Age' 1728000;
            add_header 'Content-Type' 'text/plain charset=UTF-8';
            add_header 'Content-Length' 0;
            return 204;
        }
    }
}
EOF

echo "Generated $OUTPUT_FILE"




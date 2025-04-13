#!/bin/bash

# Check if .env file exists
if [ ! -f .env ]; then
    echo "Error: .env file not found"
    exit 1
fi

# Read IPs, domain name, and email from .env
REGISTRY_IP=$(grep '^REGISTRY_IP=' .env | cut -d '=' -f2)
GATEWAY_IP=$(grep '^GATEWAY_IP=' .env | cut -d '=' -f2)
BPP_IP=$(grep '^BPP_IP=' .env | cut -d '=' -f2)
BAP_IP=$(grep '^BAP_IP=' .env | cut -d '=' -f2)
DOMAIN_NAME=$(grep '^DOMAIN_NAME=' .env | cut -d '=' -f2)
EMAIL=$(grep '^EMAIL=' .env | cut -d '=' -f2)

# Check if all required variables are set
if [ -z "$REGISTRY_IP" ] || [ -z "$GATEWAY_IP" ] || [ -z "$BPP_IP" ] || [ -z "$BAP_IP" ] || [ -z "$DOMAIN_NAME" ] || [ -z "$EMAIL" ]; then
    echo "Error: One or more required variables (REGISTRY_IP, GATEWAY_IP, BPP_IP, BAP_IP, DOMAIN_NAME, EMAIL) not found in .env file"
    exit 1
fi

# Define parallel arrays for IPs and domains (fixed pairing, no backslashes)
IPS="$REGISTRY_IP $GATEWAY_IP $BPP_IP $BAP_IP"
DOMAINS=(
    "onix-registry.$DOMAIN_NAME"
    "onix-gateway.$DOMAIN_NAME"
    "onix-bpp.$DOMAIN_NAME onix-bpp-client.$DOMAIN_NAME"
    "onix-bap.$DOMAIN_NAME onix-bap-client.$DOMAIN_NAME"
)

# Run TLS setup in parallel
pids=
i=0
for IP in $IPS; do
    # Get the domain(s) for this IP
    DOMAIN_ENTRY="${DOMAINS[$i]}"
    if [ $i -eq 2 ] || [ $i -eq 3 ]; then
        # Multi-domain case (BPP or BAP)
        DOMAIN1=$(echo "$DOMAIN_ENTRY" | awk '{print $1}')
        DOMAIN2=$(echo "$DOMAIN_ENTRY" | awk '{print $2}')
        DISPLAY_DOMAIN="$DOMAIN1 and $DOMAIN2"
        ssh -o StrictHostKeyChecking=no root@"$IP" /bin/bash << EOF &
            set -e
            snap install core
            snap refresh core
            snap install --classic certbot
            ln -sf /snap/bin/certbot /usr/bin/certbot
            ufw allow 'Nginx Full'
            ufw delete allow 'Nginx HTTP' || true
            ufw allow ssh
            certbot --nginx -d "$DOMAIN1" -d "$DOMAIN2" --non-interactive --agree-tos --email "$EMAIL"
            nginx -t || echo 'Nginx config test failed, proceeding anyway'
            systemctl restart nginx
EOF
    else
        # Single-domain case (Registry or Gateway)
        DISPLAY_DOMAIN="$DOMAIN_ENTRY"
        ssh -o StrictHostKeyChecking=no root@"$IP" /bin/bash << EOF &
            set -e
            snap install core
            snap refresh core
            snap install --classic certbot
            ln -sf /snap/bin/certbot /usr/bin/certbot
            ufw allow 'Nginx Full'
            ufw delete allow 'Nginx HTTP' || true
            ufw allow ssh
            certbot --nginx -d "$DOMAIN_ENTRY" --non-interactive --agree-tos --email "$EMAIL"
            nginx -t || echo 'Nginx config test failed, proceeding anyway'
            systemctl restart nginx
EOF
    fi
    pids="$pids $!"
    i=$((i + 1))
done

# Wait for all background jobs to finish and check results
failures=0
i=0
for pid in $pids; do
    IP=$(echo "$IPS" | awk -v n=$((i + 1)) '{print $n}')
    DOMAIN_ENTRY="${DOMAINS[$i]}"
    if [ $i -eq 2 ] || [ $i -eq 3 ]; then
        DOMAIN1=$(echo "$DOMAIN_ENTRY" | awk '{print $1}')
        DOMAIN2=$(echo "$DOMAIN_ENTRY" | awk '{print $2}')
        DISPLAY_DOMAIN="$DOMAIN1 and $DOMAIN2"
    else
        DISPLAY_DOMAIN="$DOMAIN_ENTRY"
    fi
    if wait "$pid"; then
        echo "Success: TLS certificate installed for $DISPLAY_DOMAIN on $IP"
    else
        echo "Failure: TLS setup failed for $DISPLAY_DOMAIN on $IP"
        failures=$((failures + 1))
    fi
    i=$((i + 1))
done

# Summary
if [ "$failures" -eq 0 ]; then
    echo "TLS certificates installed successfully on all servers."
else
    echo "TLS setup failed on $failures server(s)."
    exit 1
fi
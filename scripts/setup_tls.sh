#!/bin/bash

# Exit on any error
set -e

# Determine domains to configure based on server
case "$CURRENT_SERVER" in
    "$REGISTRY_IP")
        DOMAINS="onix-registry.$DOMAIN_NAME"
        ;;
    "$GATEWAY_IP")
        DOMAINS="onix-gateway.$DOMAIN_NAME"
        ;;
    "$BAP_IP")
        DOMAINS="onix-bap.$DOMAIN_NAME onix-bap-client.$DOMAIN_NAME"
        ;;
    "$BPP_IP")
        DOMAINS="onix-bpp.$DOMAIN_NAME onix-bpp-client.$DOMAIN_NAME"
        ;;
    *)
        echo "Error: Unknown server $CURRENT_SERVER, cannot determine domains"
        exit 1
        ;;
esac

# Install and configure Certbot with retry logic
install_snap() {
    local package=$1
    local retries=5
    local count=0
    local delay=10  # seconds
    while (( count < retries )); do
        snap install --classic "$package" && break
        echo "Retrying installation of $package ($((count + 1))/$retries)..."
        ((count++))
        sleep "$delay"
    done
    if (( count == retries )); then
        echo "Error: Failed to install $package after $retries retries"
        exit 1
    fi
}

snap install core
snap refresh core
install_snap certbot

# Create symbolic link for certbot
ln -sf /snap/bin/certbot /usr/bin/certbot

CERTBOT_DOMAINS=""
for domain in $DOMAINS; do
    CERTBOT_DOMAINS="$CERTBOT_DOMAINS -d $domain"
done

# Run Certbot for the domains
certbot --nginx $CERTBOT_DOMAINS --non-interactive --agree-tos --email "$EMAIL"

# Test and restart Nginx
nginx -t || echo "Nginx config test failed, proceeding anyway"
systemctl restart nginx

echo "TLS certificate installed successfully for $DOMAINS"

#!/bin/bash

set -e

# Determine domains to configure based on server
case "$CURRENT_SERVER" in
    "$REGISTRY_IP")
        DOMAINS="$REGISTRY_SUBDOMAIN.$DOMAIN_NAME"
        ;;
    "$GATEWAY_IP")
        DOMAINS="$GATEWAY_SUBDOMAIN.$DOMAIN_NAME"
        ;;
    "$BAP_IP")
        DOMAINS="$BAP_SUBDOMAIN.$DOMAIN_NAME $BAP_CLIENT_SUBDOMAIN.$DOMAIN_NAME"
        ;;
    "$BPP_IP")
        DOMAINS="$BPP_SUBDOMAIN.$DOMAIN_NAME $BPP_CLIENT_SUBDOMAIN.$DOMAIN_NAME $WEBHOOK_SUBDOMAIN.$DOMAIN_NAME"
        ;;
    *)
        echo "Error: Unknown server $CURRENT_SERVER, cannot determine domains"
        exit 1
        ;;
esac

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
ln -sf /snap/bin/certbot /usr/bin/certbot

for domain in $DOMAINS; do
    echo "Requesting certificate for $domain..."
    certbot --nginx -d "$domain" --non-interactive --agree-tos --email "$EMAIL" || {
        echo "Warning: Failed to obtain certificate for $domain, continuing with other domains"
        continue
    }
done 


nginx -t || echo "Nginx config test failed, proceeding anyway"
systemctl restart nginx

echo "TLS certificate installed successfully for $DOMAINS"

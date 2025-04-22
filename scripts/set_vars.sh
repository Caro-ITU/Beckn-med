#!/bin/bash

get_user_input() {
    local prompt="$1"
    read -p "$prompt" input
    echo "$input" | tr -d '[:space:]'  # Trim whitespace
}

create_env_file() {
    echo "Please provide the following configuration details:"

    # Collect IPs and other inputs
    REGISTRY_IP=$(get_user_input "Enter Registry IP: ")
    GATEWAY_IP=$(get_user_input "Enter Gateway IP: ")
    BAP_IP=$(get_user_input "Enter BAP IP: ")
    BPP_IP=$(get_user_input "Enter BPP IP: ")
    DOMAIN_NAME=$(get_user_input "Enter Domain Name (e.g. domain_name.com): ")
    EMAIL=$(get_user_input "Enter your email: ")
    # ENV_SUFFIX=$(get_user_input "Enter environment suffix (e.g. 2 for 'onix-bpp2'): ")

    # Derived variables with suffix
    # REGISTRY_SUBDOMAIN="registry$ENV_SUFFIX"
    # GATEWAY_SUBDOMAIN="gateway$ENV_SUFFIX"
    # BAP_SUBDOMAIN="bap$ENV_SUFFIX"
    # BAP_CLIENT_SUBDOMAIN="bap$ENV_SUFFIX-client"
    # BPP_SUBDOMAIN="bpp$ENV_SUFFIX"
    # BPP_CLIENT_SUBDOMAIN="bpp$ENV_SUFFIX-client"
    # WEBHOOK_SUBDOMAIN="bpp$ENV_SUFFIX-ps"

    # Fixed subdomain variables:
    REGISTRY_SUBDOMAIN="registry"
    GATEWAY_SUBDOMAIN="onix-gateway"
    BAP_SUBDOMAIN="onix-bap"
    BAP_CLIENT_SUBDOMAIN="onix-bap-client"
    BPP_SUBDOMAIN="onix-bpp"
    BPP_CLIENT_SUBDOMAIN="onix-bpp-client"
    WEBHOOK_SUBDOMAIN="onix-bpp-ps"

    # URLs
    REGISTRY_URL="https://${REGISTRY_SUBDOMAIN}.${DOMAIN_NAME}"
    GATEWAY_URL="https://${GATEWAY_SUBDOMAIN}.${DOMAIN_NAME}"
    BAP_URL="https://${BAP_SUBDOMAIN}.${DOMAIN_NAME}"
    BAP_CLIENT_URL="https://${BAP_CLIENT_SUBDOMAIN}.${DOMAIN_NAME}"
    BPP_URL="https://${BPP_SUBDOMAIN}.${DOMAIN_NAME}"
    BPP_CLIENT_URL="https://${BPP_CLIENT_SUBDOMAIN}.${DOMAIN_NAME}"
    WEBHOOK_URL="https://${WEBHOOK_SUBDOMAIN}.${DOMAIN_NAME}/webhook"

    # Setup IDs (same as BAP/BPP URLs' hostnames)
    BAP_SETUP_ID="${BAP_SUBDOMAIN}.${DOMAIN_NAME}"
    BPP_SETUP_ID="${BPP_SUBDOMAIN}.${DOMAIN_NAME}"

    # Static values
    REGISTRY_USERNAME="root"
    REGISTRY_PASSWORD="root"
    LAYER2_CONFIG="https://raw.githubusercontent.com/beckn/beckn-onix/refs/heads/main/layer2/samples/retail_1.1.0_1.1.0.yaml"
    TERM="xterm"

    # Create .env content
    env_content="REGISTRY_IP=$REGISTRY_IP
REGISTRY_URL=$REGISTRY_URL
REGISTRY_SUBDOMAIN=$REGISTRY_SUBDOMAIN
GATEWAY_IP=$GATEWAY_IP
GATEWAY_URL=$GATEWAY_URL
GATEWAY_SUBDOMAIN=$GATEWAY_SUBDOMAIN
BAP_SETUP_ID=$BAP_SETUP_ID
BAP_IP=$BAP_IP
BAP_URL=$BAP_URL
BAP_CLIENT_URL=$BAP_CLIENT_URL
BAP_SUBDOMAIN=$BAP_SUBDOMAIN
BAP_CLIENT_SUBDOMAIN=$BAP_CLIENT_SUBDOMAIN
BPP_SETUP_ID=$BPP_SETUP_ID
BPP_IP=$BPP_IP
BPP_URL=$BPP_URL
BPP_CLIENT_URL=$BPP_CLIENT_URL
BPP_SUBDOMAIN=$BPP_SUBDOMAIN
BPP_CLIENT_SUBDOMAIN=$BPP_CLIENT_SUBDOMAIN
DOMAIN_NAME=$DOMAIN_NAME
EMAIL=$EMAIL
WEBHOOK_URL=$WEBHOOK_URL
WEBHOOK_SUBDOMAIN=$WEBHOOK_SUBDOMAIN
REGISTRY_USERNAME=$REGISTRY_USERNAME
REGISTRY_PASSWORD=$REGISTRY_PASSWORD
LAYER2_CONFIG=$LAYER2_CONFIG
TERM=$TERM"

    # Write to file
    if echo "$env_content" > .env 2>/dev/null; then
        echo ".env file created successfully!"
    else
        echo "Error writing to .env file"
        exit 1
    fi
}

create_env_file

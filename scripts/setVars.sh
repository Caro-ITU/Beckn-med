#!/bin/bash

get_user_input() {
    local prompt="$1"
    read -p "$prompt" input
    echo "$input" | tr -d '[:space:]'  # Trim whitespace
}

create_env_file() {
    echo "Please provide the following configuration details:"

    # Collect IP inputs and domain name
    REGISTRY_IP=$(get_user_input "Enter Registry IP: ")
    GATEWAY_IP=$(get_user_input "Enter Gateway IP: ")
    BAP_IP=$(get_user_input "Enter BAP IP: ")
    BPP_IP=$(get_user_input "Enter BPP IP: ")
    DOMAIN_NAME=$(get_user_input "Enter Domain Name: ")
    EMAIL=$(get_user_input "Enter your e-mail: ")

    # Generate URLs based on domain name
    REGISTRY_URL="https://onix-registry.$DOMAIN_NAME"
    GATEWAY_URL="https://onix-gateway.$DOMAIN_NAME"
    BAP_URL="https://onix-bap.$DOMAIN_NAME"
    BAP_CLIENT_URL="https://onix-bap-client.$DOMAIN_NAME"
    BPP_URL="https://onix-bpp.$DOMAIN_NAME"
    BPP_CLIENT_URL="https://onix-bpp-client.$DOMAIN_NAME"

    # Content to write to .env file
    env_content="REGISTRY_IP=$REGISTRY_IP
GATEWAY_IP=$GATEWAY_IP
BAP_IP=$BAP_IP
BPP_IP=$BPP_IP
DOMAIN_NAME=$DOMAIN_NAME
REGISTRY_URL=$REGISTRY_URL
GATEWAY_URL=$GATEWAY_URL
BAP_URL=$BAP_URL
BAP_CLIENT_URL=$BAP_CLIENT_URL
BPP_URL=$BPP_URL
EMAIL=$EMAIL"

    # Write to .env file
    if echo "$env_content" > .env 2>/dev/null; then
        echo "Successfully created .env file with all configurations!"
    else
        echo "Error writing to .env file"
        exit 1
    fi
}

create_env_file

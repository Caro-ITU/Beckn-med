#!/bin/bash

# Function to get user input
get_user_input() {
    local prompt="$1"
    read -p "$prompt" input
    echo "$input" | tr -d '[:space:]'  # Trim whitespace
}

# Function to create .env file
create_env_file() {
    echo "Please provide the following configuration details:"

    # Collect IP inputs and domain name
    REGISTRY_IP=$(get_user_input "Enter Registry IP: ")
    GATEWAY_IP=$(get_user_input "Enter Gateway IP: ")
    BAP_IP=$(get_user_input "Enter BAP IP: ")
    BPP_IP=$(get_user_input "Enter BPP IP: ")
    DOMAIN_NAME=$(get_user_input "Enter Domain Name: ")

    # Generate URLs based on domain name
    REGISTRY_URL="https://registry.$DOMAIN_NAME"
    GATEWAY_URL="https://gateway.$DOMAIN_NAME"
    BAP_URL="https://bap.$DOMAIN_NAME"
    BPP_URL="https://bpp.$DOMAIN_NAME"

    # Content to write to .env file
    env_content="REGISTRY_IP=$REGISTRY_IP
GATEWAY_IP=$GATEWAY_IP
BAP_IP=$BAP_IP
BPP_IP=$BPP_IP
REGISTRY_URL=$REGISTRY_URL
GATEWAY_URL=$GATEWAY_URL
BAP_URL=$BAP_URL
BPP_URL=$BPP_URL"

    # Write to .env file
    if echo "$env_content" > .env 2>/dev/null; then
        echo "Successfully created .env file with all configurations!"
    else
        echo "Error writing to .env file"
        exit 1
    fi
}

# Main execution
create_env_file
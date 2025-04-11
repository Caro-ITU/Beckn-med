#!/bin/bash

# Load environment variables from .env in the same directory
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
export $(grep -v '^#' "$SCRIPT_DIR/.env" | xargs)

IMAGE_SLUG="ubuntu-22-04-x64"

# Rebuild registry
curl -X POST "https://api.digitalocean.com/v2/droplets/$REGISTRY_ID/actions" \
     -H "Authorization: Bearer $DO_API_TOKEN" \
     -H "Content-Type: application/json" \
     -d "{\"type\":\"rebuild\",\"image\":\"$IMAGE_SLUG\"}"
ssh-keygen -R "$REGISTRY_IP"

# Rebuild gateway
curl -X POST "https://api.digitalocean.com/v2/droplets/$GATEWAY_ID/actions" \
     -H "Authorization: Bearer $DO_API_TOKEN" \
     -H "Content-Type: application/json" \
     -d "{\"type\":\"rebuild\",\"image\":\"$IMAGE_SLUG\"}"
ssh-keygen -R "$GATEWAY_IP"

# Rebuild BPP
curl -X POST "https://api.digitalocean.com/v2/droplets/$BPP_ID/actions" \
     -H "Authorization: Bearer $DO_API_TOKEN" \
     -H "Content-Type: application/json" \
     -d "{\"type\":\"rebuild\",\"image\":\"$IMAGE_SLUG\"}"
ssh-keygen -R "$BPP_IP"

# Rebuild BAP
curl -X POST "https://api.digitalocean.com/v2/droplets/$BAP_ID/actions" \
     -H "Authorization: Bearer $DO_API_TOKEN" \
     -H "Content-Type: application/json" \
     -d "{\"type\":\"rebuild\",\"image\":\"$IMAGE_SLUG\"}"
ssh-keygen -R "$BAP_IP"

#!/bin/bash

# Load environment variables from .env in the same directory
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
export $(grep -v '^#' "$SCRIPT_DIR/.env" | xargs)

ssh-keygen -R "$REGISTRY_IP"
ssh-keygen -R "$GATEWAY_IP"
ssh-keygen -R "$BPP_IP"
ssh-keygen -R "$BAP_IP"
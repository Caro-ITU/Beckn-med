#!/bin/bash

# Load environment variables from .env in the same directory
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
export $(grep -v '^#' "$SCRIPT_DIR/.env" | xargs)

# Nginx install + UFW setup script to run remotely
read -r -d '' NGINX_SETUP <<'EOF'
sudo apt update &&
sudo apt install -y nginx &&
sudo ufw allow 'Nginx Full' &&
sudo ufw allow 'ssh' &&
echo "y" | sudo ufw enable
EOF

# List of IPs
DROPLET_IPS=(
    "$REGISTRY_IP"
    "$GATEWAY_IP"
    "$BPP_IP"
    "$BAP_IP"
)

# SSH into each and run the Nginx + UFW setup in parallel
for IP in "${DROPLET_IPS[@]}"; do
    echo "Starting Nginx setup on $IP..."
    ssh -o StrictHostKeyChecking=no root@"$IP" "$NGINX_SETUP" &
done

# Wait for all background jobs to finish
wait

echo "Nginx installed and UFW configured on all droplets."
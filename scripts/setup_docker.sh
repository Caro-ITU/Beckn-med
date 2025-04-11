#!/bin/bash

# Load environment variables from .env in the same directory
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
export $(grep -v '^#' "$SCRIPT_DIR/.env" | xargs)

# Docker install script to run remotely
read -r -d '' DOCKER_SETUP <<'EOF'
sudo apt-get update &&
sudo apt-get install -y ca-certificates curl &&
sudo install -m 0755 -d /etc/apt/keyrings &&
sudo curl -fsSL https://download.docker.com/linux/ubuntu/gpg -o /etc/apt/keyrings/docker.asc &&
sudo chmod a+r /etc/apt/keyrings/docker.asc &&

echo "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.asc] \
https://download.docker.com/linux/ubuntu $(. /etc/os-release && echo "${UBUNTU_CODENAME:-$VERSION_CODENAME}") stable" | \
sudo tee /etc/apt/sources.list.d/docker.list > /dev/null &&

sudo apt-get update &&
sudo apt-get install -y docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin &&

sudo usermod -aG docker $USER
EOF

# List of IPs
DROPLET_IPS=(
    "$REGISTRY_IP"
    "$GATEWAY_IP"
    "$BPP_IP"
    "$BAP_IP"
)

# SSH into each and run the Docker install in parallel
for IP in "${DROPLET_IPS[@]}"; do
    echo "Starting Docker install on $IP..."
    ssh -o StrictHostKeyChecking=no root@"$IP" "$DOCKER_SETUP" &
done

# Wait for all background jobs to finish
wait

echo "Docker installed on all droplets."

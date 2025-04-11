#!/bin/bash

# Check if .env file exists
if [ ! -f .env ]; then
    echo "Error: .env file not found"
    exit 1
fi

# Read IP addresses from .env
REGISTRY_IP=$(grep '^REGISTRY_IP=' .env | cut -d '=' -f2)
GATEWAY_IP=$(grep '^GATEWAY_IP=' .env | cut -d '=' -f2)
BAP_IP=$(grep '^BAP_IP=' .env | cut -d '=' -f2)
BPP_IP=$(grep '^BPP_IP=' .env | cut -d '=' -f2)

# Check if IP addresses are set
if [ -z "$REGISTRY_IP" ] || [ -z "$GATEWAY_IP" ] || [ -z "$BAP_IP" ] || [ -z "$BPP_IP" ]; then
    echo "Error: One or more IP addresses not found in .env file"
    exit 1
fi

# Define the list of IPs
IPS=(
    "$REGISTRY_IP"
    "$GATEWAY_IP"
    "$BAP_IP"
    "$BPP_IP"
)

# Start SSH agent
eval "$(ssh-agent -s)" > /dev/null

# Add your SSH key to the agent (adjust the path if your key isn’t at ~/.ssh/id_rsa)
if ! ssh-add ~/.ssh/id_rsa > /dev/null 2>&1; then
    echo "Error: Failed to add SSH key to agent"
    eval "$(ssh-agent -k)" > /dev/null
    exit 1
fi

# Clean up SSH agent on exit
trap 'eval "$(ssh-agent -k)" > /dev/null' EXIT

# Define the Docker installation command
COMMAND="
set -e
apt-get update
apt-get install -y ca-certificates curl
install -m 0755 -d /etc/apt/keyrings
curl -fsSL https://download.docker.com/linux/ubuntu/gpg -o /etc/apt/keyrings/docker.asc
chmod a+r /etc/apt/keyrings/docker.asc
echo \"deb [arch=\$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.asc] https://download.docker.com/linux/ubuntu \$(. /etc/os-release && echo \"\${UBUNTU_CODENAME:-\$VERSION_CODENAME}\") stable\" | tee /etc/apt/sources.list.d/docker.list > /dev/null
apt-get update
apt-get install -y docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin
"

# Run commands in parallel across all servers
pids=()
for IP in "${IPS[@]}"; do
    ssh -o StrictHostKeyChecking=no root@"$IP" "$COMMAND" &
    pids+=($!)
done

# Wait for all background jobs to finish and check results
failures=0
for i in "${!pids[@]}"; do
    pid=${pids[$i]}
    IP=${IPS[$i]}
    if wait "$pid"; then
        echo "Success: Docker installed on $IP"
    else
        echo "Failure: Docker installation failed on $IP"
        failures=$((failures + 1))
    fi
done

# Summary
if [ "$failures" -eq 0 ]; then
    echo "Docker installed successfully on all servers."
else
    echo "Docker installation failed on $failures server(s)."
    exit 1
fi
#!/bin/bash

# Load environment variables
[ -f .env ] || { echo "Error: .env file not found"; exit 1; }
source .env

# Configuration
IPS=("$REGISTRY_IP" "$GATEWAY_IP" "$BAP_IP" "$BPP_IP")
REPO_URL="https://github.com/beckn/beckn-onix.git"
SSH_KEY="$HOME/.ssh/id_rsa"

# Check prerequisites
command -v ssh >/dev/null || { echo "Error: ssh not installed"; exit 1; }
[ -f "$SSH_KEY" ] || { echo "Error: SSH key not found at $SSH_KEY"; exit 1; }
for ip in "${IPS[@]}"; do
    [ -n "$ip" ] || { echo "Error: Missing IP address"; exit 1; }
done

# Clone repo on remote server
clone_repo() {
    local ip=$1
    echo "Cloning repo on $ip..."
    ssh -o StrictHostKeyChecking=no -i "$SSH_KEY" root@"$ip" \
        "git clone $REPO_URL" 2>&1 && \
        echo "Success: Cloned repo on $ip" || \
        echo "Error: Failed to clone repo on $ip"
}

# Main execution
for ip in "${IPS[@]}"; do
    clone_repo "$ip" &
done

# Wait for all background processes to complete
wait

echo "Finished processing all servers"
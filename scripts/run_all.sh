#!/bin/bash

# Exit on any error
set -e

# Start SSH agent
echo "Starting SSH agent..."
eval "$(ssh-agent -s)" > /dev/null

# Add your SSH key to the agent (adjust the path if your key isn’t at ~/.ssh/id_rsa)
echo "Adding SSH key..."
if ! ssh-add ~/.ssh/id_rsa > /dev/null 2>&1; then
    echo "Error: Failed to add SSH key to agent"
    eval "$(ssh-agent -k)" > /dev/null
    exit 1
fi

# Clean up SSH agent on exit (whether successful or due to an error)
trap 'eval "$(ssh-agent -k)" > /dev/null; echo "SSH agent terminated"' EXIT

# Run scripts in the root directory
echo "Running setup_docker.sh..."
./setup_docker.sh

echo "Running install_nginx.sh..."
./install_nginx.sh

echo "Running clone_repo.sh..."
./clone_repo.sh

# Change to nginx-configs directory
cd nginx-configs

echo "Running generate_all_configs.sh..."
./generate_all_configs.sh

echo "Running deploy_copy_configs.sh..."
./deploy_copy_configs.sh

echo "Running deploy_enable_configs.sh..."
./deploy_enable_configs.sh

# Change back to the root directory
cd ..
echo "Running setup_TLS.sh..."
./setup_TLS.sh

echo "All scripts completed successfully!"
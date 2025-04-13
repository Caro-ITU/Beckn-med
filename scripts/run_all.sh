#!/bin/bash

# Exit on any error
set -e

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
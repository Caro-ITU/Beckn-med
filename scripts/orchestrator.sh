#!/bin/bash

# Exit on any error
set -e

# Define .env file path (relative to script’s directory)
ENV_FILE=".env"

# Get the directory of the orchestrator script
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# Check if .env file exists and is readable
if [ ! -f "$SCRIPT_DIR/$ENV_FILE" ] || [ ! -r "$SCRIPT_DIR/$ENV_FILE" ]; then
    echo "Error: $ENV_FILE not found or not readable in $SCRIPT_DIR"
    exit 1
fi

# Load all variables from .env
while IFS='=' read -r key value; do
    if [[ -n "$key" && ! "$key" =~ ^# ]]; then
        key=$(echo "$key" | tr -d '[:space:]')
        value=$(echo "$value" | tr -d '[:space:]')
        eval "export $key=$value"
    fi
done < "$SCRIPT_DIR/$ENV_FILE"

# Verify required IP variables
REQUIRED_IPS=("REGISTRY_IP" "GATEWAY_IP" "BAP_IP" "BPP_IP")
for var in "${REQUIRED_IPS[@]}"; do
    if [ -z "${!var}" ]; then
        echo "Error: Required variable $var is not set in $ENV_FILE"
        exit 1
    fi
done

# Define the list of servers
SERVERS=(
    "$REGISTRY_IP"
    "$GATEWAY_IP"
    "$BAP_IP"
    "$BPP_IP"
)

# Function to run a script on all servers in parallel and wait for completion
run_script_on_all() {
    local script=$1
    echo "Running $script on all servers..."

    pids=()
    for server in "${SERVERS[@]}"; do
        env_vars=$(while IFS='=' read -r key value; do
            if [[ -n "$key" && ! "$key" =~ ^# ]]; then
                key=$(echo "$key" | tr -d '[:space:]')
                value=$(echo "$value" | tr -d '[:space:]')
                printf '%s=%q ' "$key" "$value"
            fi
        done < "$SCRIPT_DIR/$ENV_FILE")
        
        ssh -o StrictHostKeyChecking=no root@"$server" "export $env_vars CURRENT_SERVER=$server; bash -s" < "$SCRIPT_DIR/$script" &
        pids+=($!)
    done

    # Wait for all background jobs to finish and check results
    failures=0
    for i in "${!pids[@]}"; do
        pid=${pids[$i]}
        server=${SERVERS[$i]}
        if wait "$pid"; then
            echo "Success: $script completed on $server"
        else
            echo "Failure: $script failed on $server"
            failures=$((failures + 1))
        fi
    done

    if [ "$failures" -ne 0 ]; then
        echo "Error: $script failed on $failures server(s)"
        exit 1
    fi

    echo "$script completed successfully on all servers."
}

# Function to run a script locally
run_local_script() {
    local script=$1
    echo "Running $script locally..."
    if bash "$SCRIPT_DIR/$script"; then
        echo "Success: $script completed locally"
    else
        echo "Failure: $script failed locally"
        exit 1
    fi
}

# Define the ordered list of scripts and their type (local or remote)
TASKS=(
    "setup_docker.sh:remote"
    "install_nginx.sh:remote"
    "nginx-configs/generate_all_configs.sh:local"
    "nginx-configs/upload_nginx_configs.sh:local"
    "nginx-configs/deploy_enable_configs.sh:remote"
    "setup_TLS.sh:remote"
    "clone_repo.sh:remote"
)

# Execute tasks in sequence
for task in "${TASKS[@]}"; do
    IFS=':' read -r script type <<< "$task"
    case "$type" in
        remote)
            run_script_on_all "$script"
            ;;
        local)
            run_local_script "$script"
            ;;
        *)
            echo "Unknown task type: $type for script: $script"
            exit 1
            ;;
    esac
done

echo "All scripts completed successfully on all servers!"

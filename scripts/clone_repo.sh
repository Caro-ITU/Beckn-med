#!/bin/bash

# Source the .env file
if [ -f .env ]; then
    set -a  # automatically export all variables
    source .env
    set +a
else
    echo "Error: .env file not found"
    exit 1
fi

# Array of IPs from environment variables
IPS=("$REGISTRY_IP" "$GATEWAY_IP" "$BAP_IP" "$BPP_IP")
REPO_URL="https://github.com/beckn/beckn-onix.git"

# Function to SSH and clone
ssh_and_clone() {
    local ip=$1
    local key_path=$2
    local passphrase=$3
    
    echo "Processing server: $ip"
    
    # Create a temporary expect script to handle SSH with passphrase and host prompt
    expect_script=$(mktemp)
    cat > "$expect_script" << EOF
#!/usr/bin/expect -f
spawn ssh -o StrictHostKeyChecking=no -i $key_path root@$ip "git clone $REPO_URL"
expect {
    "Enter passphrase for key" {
        send "$passphrase\r"
        expect eof
    }
    "Are you sure you want to continue connecting (yes/no" {
        send "yes\r"
        expect {
            "Enter passphrase for key" {
                send "$passphrase\r"
                expect eof
            }
            eof
        }
    }
    eof
}
EOF

    chmod +x "$expect_script"
    
    # Run the expect script and capture output
    output=$("$expect_script" 2>&1)
    status=$?
    
    # Clean up temporary file
    rm -f "$expect_script"
    
    if [ $status -eq 0 ]; then
        echo "Successfully cloned repository on $ip"
        [ -n "$output" ] && echo "Output: $output"
    else
        echo "Error cloning repository on $ip"
        [ -n "$output" ] && echo "Error: $output"
    fi
}

# Main execution
main() {
    # Check if all IPs are set
    for ip in "${IPS[@]}"; do
        if [ -z "$ip" ]; then
            echo "Error: One or more IPs not found in .env file"
            exit 1
        fi
    done
    
    # Prompt for SSH key details
    read -p "Enter path to SSH private key (default ~/.ssh/id_rsa): " key_path
    key_path=${key_path:-~/.ssh/id_rsa}
    
    # Prompt for passphrase securely
    echo -n "Enter passphrase for SSH key: "
    read -s passphrase
    echo
    
    # Process each server
    for ip in "${IPS[@]}"; do
        echo
        ssh_and_clone "$ip" "$key_path" "$passphrase"
    done
    
    echo -e "\nFinished processing all servers"
}

# Check if expect is installed
if ! command -v expect &> /dev/null; then
    echo "Error: 'expect' is required but not installed. Please install it first."
    echo "On Debian/Ubuntu: sudo apt-get install expect"
    echo "On RHEL/CentOS: sudo yum install expect"
    exit 1
fi

# Run main
main
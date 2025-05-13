#!/bin/bash

set -e

echo "Cloning repository..."
git clone https://github.com/Bachelors-Project-frlr-raln/integration-webhook.git
cd integration-webhook

echo "Creating .env file..."
cat << EOF > .env
BPP_ID="$BPP_SUBDOMAIN.$DOMAIN_NAME"
BPP_CLIENT_URI="http://127.0.0.1:6001"
BPP_URI="https://$BPP_SUBDOMAIN.$DOMAIN_NAME"
PORT=3009
EOF

if [ -f .env ]; then
    echo ".env file created successfully."
else
    echo "Error: Failed to create .env file."
    exit 1
fi

echo "Installing npm..."
sudo apt update
sudo apt install -y npm

if command -v npm >/dev/null 2>&1; then
    echo "npm installed successfully."
else
    echo "Error: npm installation failed."
    exit 1
fi

echo "Installing project dependencies..."
npm install

echo "Starting the application..."
nohup npm start > output.log 2>&1 &

# Wait briefly to check if the process started
sleep 2

if pgrep -f "node" >/dev/null; then
    echo "Application started successfully. Logs are in output.log."
    echo "To check the application, run: curl http://localhost:3009/health"
else
    echo "Error: Application failed to start. Check output.log for details."
    cat output.log
    exit 1
fi

echo "Setup complete!"
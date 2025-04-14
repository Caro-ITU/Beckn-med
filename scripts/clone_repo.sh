#!/bin/bash

# Exit on any error
set -e

# Configuration
REPO_URL="https://github.com/beckn/beckn-onix.git"

# Clone the repository
git clone "$REPO_URL"

echo "Repository cloned successfully."
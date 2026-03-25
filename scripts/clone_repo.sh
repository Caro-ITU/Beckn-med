#!/bin/bash
set -e

REPO_URL="https://github.com/Beckn-One/beckn-onix.git"

if [ -d "beckn-onix/.git" ]; then
    echo "beckn-onix already exists, skipping clone."
else
    git clone "$REPO_URL" beckn-onix
    echo "Repository cloned successfully."
fi
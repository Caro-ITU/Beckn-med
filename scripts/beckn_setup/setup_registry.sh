#!/bin/bash
source .env
cd beckn-onix/install
sudo usermod -aG docker $USER
{
    echo "2"
    echo "1"
    echo "$REGISTRY_URL"
} | ./beckn-onix.sh
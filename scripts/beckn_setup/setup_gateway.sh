#!/bin/bash
source .env
cd beckn-onix/install
sudo usermod -aG docker $USER
{
    echo "1"
    echo "1"
    echo "$REGISTRY_URL"
    echo "$GATEWAY_URL"
} | ./beckn-onix.sh
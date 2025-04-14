#!/bin/bash
source .env
cd beckn-onix/install
sudo usermod -aG docker $USER
{
    echo "1"
    echo "2"
    echo "$BAP_SETUP_ID"
    echo "$BAP_URL"
    echo "$REGISTRY_URL/subscribers"
    echo "$REGISTRY_USERNAME"
    echo "$REGISTRY_PASSWORD"
    echo "Y"
    echo "retail_1.1.0"
    echo "$LAYER2_CONFIG"
} | ./beckn-onix.sh
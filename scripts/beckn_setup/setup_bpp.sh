#!/bin/bash
source .env
read -sp "Enter Registry password: " password
cd beckn-onix/install
{
    echo "1"
    echo "3"
    echo "$BPP_ID"
    echo "$BPP_URL"
    echo "$WEBHOOK_URL"
    echo "$REGISTRY_URL/subscribers"
    echo "$REGISTRY_USERNAME"
    echo "$password"
} | ./beckn-onix.sh
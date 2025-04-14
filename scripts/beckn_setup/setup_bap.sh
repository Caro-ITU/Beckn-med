#!/bin/bash
source .env
read -sp "Enter Registry password: " password
cd beckn-onix/install
{
    echo "1"
    echo "2"
    echo "$BAP_ID"
    echo "$BAP_URL"
    echo "$REGISTRY_URL/subscribers"
    echo "$REGISTRY_USERNAME"
    echo "$password"
} | ./beckn-onix.sh
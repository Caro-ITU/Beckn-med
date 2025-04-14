#!/bin/bash
source .env
cd beckn-onix/install
{
    echo "1"
    echo "2"
    echo "$REGISTRY_URL"
    echo "$GATEWAY_URL"
} | ./beckn-onix.sh
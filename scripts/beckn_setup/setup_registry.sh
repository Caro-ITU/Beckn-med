#!/bin/bash
source .env
cd beckn-onix/install
{
    echo "2"
    echo "1"
    echo "$REGISTRY_URL"
} | ./beckn-onix.sh
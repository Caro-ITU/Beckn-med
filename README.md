# Beckn Onix: Infrastucture as Code (IaC)

This repository is made, with the sole purpose of setting up a full production environment for the [Beckn-Onix project](https://github.com/beckn/beckn-onix). 

In an attempt to create a fully functional production environment, we felt that the setup_walkthrough was missing a lot of steps, that could make the setup much quicker. These missing gaps, is what we are trying to fill out with the help of some setup scripts.

## How does it work?
To make it accessible for as many as possible, the scripts are simple Bash scripts, utilizing SSH for server access and remote execution to install and set up dependencies, such as Docker, NGINX + configuration files, Certbot, requesting TLS certificates and finally the `beckn-onix.sh` script with pre filled options set. 

## Prerequisites

### Servers with SSH access
Following the server structure of the Beckn-Onix specification, 4 servers need to be set up with full SSH access from your local PC. OS and exact server requirements can be found here: https://developers.becknprotocol.io/docs/beckn-onix . In terms of size on each server, this is what we found out worked the best, anything lower is prone to crash due to memory exceeding the limit:
* Gateway and registry: 2GB RAM and 1 Intel vCPU.
* BAP and BPP: 8GB RAM and 2 Intel vCPU.

It is advisable to have an SSH config configured for easy access to the servers, especially if you ssh-key has a password to bypass this when running the scripts. Example configuration can be found under: [ssh example config](LINK_HERE)

### Domain name + DNS records for each server


### Local .env file
Create a .env file in the root directory of the beckn-IaC repository.

**Example .env file:**
```bash
REGISTRY_IP=165.22.73.161
REGISTRY_URL=https://onix-registry.domain_name.com
GATEWAY_IP=46.101.159.195
GATEWAY_URL=https://onix-gateway2.domain_name.com
BAP_SETUP_ID=onix-bap.domain_name.com
BAP_IP=159.65.127.214
BAP_URL=https://onix-bap.domain_name.com
BAP_CLIENT_URL=https://onix-bap-client.domain_name.com
BPP_SETUP_ID=onix-bpp.domain_name.com
BPP_IP=142.93.101.242
BPP_URL=https://onix-bpp.domain_name.com
BPP_CLIENT_URL=https://onix-bpp-client.domain_name.com
DOMAIN_NAME=domain_name.com
EMAIL=example@gmail.com
WEBHOOK_URL=https://onix-bpp-ps.domain_name.com/webhook
REGISTRY_USERNAME=root
REGISTRY_PASSWORD=root
LAYER2_CONFIG=https://raw.githubusercontent.com/beckn/beckn-onix/refs/heads/main/layer2/samples/retail_1.1.0_1.1.0.yaml
TERM=xterm
```
## Running the script
When the prerequisites have been filled out, the `./orchestrator` should be able to complete the remaining setup steps for you and set up a fully functional production environment, utilizing the Beckn protocol.

Due to Beckn specifications and their setup, a few things have to be done manually after the orchestrator script has been run. 
[Change subscription status on BAP and BPP](https://github.com/beckn/beckn-onix/blob/main/docs/user_guide.md#changing-subscription-status-of-bap-and-bpp-at-the-registry) 
[Register custom domain in registry](https://github.com/beckn/missions/blob/main/docs/registry-user-guide.md#create-new-network-domain) 
Restart gateway after creating the network domain in registry
```bash
ssh root@gateway "docker restart gateway"
```

Now everything should be ready to go and you can send requests via the postman collections specified for your domain to test everything out in a production environment.

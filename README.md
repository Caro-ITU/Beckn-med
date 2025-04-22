# Beckn ONIX: Infrastucture as Code (IaC)

This repository provides an automated way to **deploy a full production-ready Beckn network** using [Beckn-ONIX](https://github.com/beckn/beckn-onix). 

The official setup guide for ONIX is a great foundation, but it leaves room for automation and clarity in a real-world production setup. This project fills in those gaps with tested setup scripts, enabling faster and more reliable deployments.

## What does it do?
This repo contains Bash-based orchestration scripts that:

* Set up the required infrastructure (Registry, Gateway, BAP, BPP)
* Install dependencies: Docker, NGINX, Certbot, etc.
* Configure domains, TLS certificates, and reverse proxies
* Automatically execute the ONIX install script with pre-filled inputs
* Produce a ready-to-use Beckn production network

All setup is done **remotely over SSH**, so you can launch everything from your local machine.

## Prerequisites
### 1. Servers with SSH access
You’ll need four servers (VMs) accessible via SSH from your local machine. Each will host one of the core Beckn components.
| Component         | Recommended spec |
|-----------        |------------------|
|Registry + Gateway |1 vCPU, 2GB RAM   |
|BAP + BPP          |2 vCPU, 8GB RAM   |

**Note:** Lower specs may cause crashes due to memory constraints.

Ensure your local machine has an SSH agent running and configured, especially if your SSH key is password-protected.

### 2. Domain name + DNS records for each server
Each component requires a unique subdomain (e.g., onix-registry.domain.com, onix-bap.domain.com, etc.)

**TODO:** explain DNS configurations in detail

### 3. .env Configuration
In the root of the repository, create a .env file to define all your infrastructure variables. It's a lot of variables to configure, so you can use the `set_vars.sh` as a starting point, and it should configure the most basic `.env` configuration.

**Example .env file:**
```bash
REGISTRY_IP=165.22.73.161
REGISTRY_URL=https://onix-registry.domain_name.com
REGISTRY_SUBDOMAIN=onix-registry

GATEWAY_IP=46.101.159.195
GATEWAY_URL=https://onix-gateway2.domain_name.com
GATEWAY_SUBDOMAIN=onix-gateway

BAP_SETUP_ID=onix-bap.domain_name.com
BAP_IP=159.65.127.214
BAP_URL=https://onix-bap.domain_name.com
BAP_CLIENT_URL=https://onix-bap-client.domain_name.com
BAP_SUBDOMAIN=onix-bap
BAP_CLIENT_SUBDOMAIN=onix-bap-client

BPP_SETUP_ID=onix-bpp.domain_name.com
BPP_IP=142.93.101.242
BPP_URL=https://onix-bpp.domain_name.com
BPP_CLIENT_URL=https://onix-bpp-client.domain_name.com
BPP_SUBDOMAIN=onix-bpp
BPP_CLIENT_SUBDOMAIN=onix-bpp-client

DOMAIN_NAME=domain_name.com
EMAIL=example@gmail.com
WEBHOOK_URL=https://onix-bpp-ps.domain_name.com/webhook

REGISTRY_USERNAME=root
REGISTRY_PASSWORD=root

LAYER2_CONFIG=https://raw.githubusercontent.com/beckn/beckn-onix/refs/heads/main/layer2/samples/retail_1.1.0_1.1.0.yaml

TERM=xterm

```
## Running the setup
Once the .env file and servers are ready, change directory to the `scripts/` folder and simply run:
```bash
./orchestrator.sh
```

The script will handle:
* SSH-ing into each server
* Installing dependencies
* Running the ONIX setup for each component with your pre-filled config

## Post-Install Manual Steps

Due to Beckn specifications and their setup, a few things have to be done manually after the orchestrator script has been run:

1. [Change subscription status on BAP and BPP](https://github.com/beckn/beckn-onix/blob/main/docs/user_guide.md#changing-subscription-status-of-bap-and-bpp-at-the-registry) 
2. [Register custom domain in registry](https://github.com/beckn/missions/blob/main/docs/registry-user-guide.md#create-new-network-domain) 
3. Restart gateway to reflect the domain update
```bash
ssh root@gateway "docker restart gateway"
```

## Verifying the setup
You can now test your network by:
* Using Beckn Postman collections
* Sending real requests to your deployed domains
* Monitoring logs with:
```bash
docker logs -f bap-client
```

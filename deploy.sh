#!/bin/bash

# VLESS Reality One-Click Deployment Script for Ubuntu / CentOS
# Author: mymicroblog (via Antigravity)

set -e

# Curried echo colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[0;33m'
BLUE='\033[0;36m'
NC='\033[0m' # No Color

echo -e "${BLUE}===================================================${NC}"
echo -e "${BLUE}      VLESS Reality One-Click Deploy Script        ${NC}"
echo -e "${BLUE}===================================================${NC}"

# 1. Detect OS
if [ -f /etc/os-release ]; then
    . /etc/os-release
    OS=$ID
else
    OS=$(uname -s | tr '[:upper:]' '[:lower:]')
fi

# 2. Check and Install Docker / Docker Compose
install_docker() {
    echo -e "${YELLOW}[*] Docker is not installed. Installing...${NC}"
    if [ "$OS" = "ubuntu" ] || [ "$OS" = "debian" ]; then
        sudo apt-get update
        sudo apt-get install -y apt-transport-https ca-certificates curl gnupg lsb-release
        curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo gpg --dearmor -o /usr/share/keyrings/docker-archive-keyring.gpg
        echo "deb [arch=$(dpkg --print-architecture) signed-by=/usr/share/keyrings/docker-archive-keyring.gpg] https://download.docker.com/linux/ubuntu $(lsb_release -cs) stable" | sudo tee /etc/apt/sources.list.d/docker.list > /dev/null
        sudo apt-get update
        sudo apt-get install -y docker-ce docker-ce-cli containerd.io docker-compose-plugin
    elif [ "$OS" = "centos" ] || [ "$OS" = "rhel" ]; then
        sudo yum install -y yum-utils
        sudo yum-config-manager --add-repo https://download.docker.com/linux/centos/docker-ce.repo
        sudo yum install -y docker-ce docker-ce-cli containerd.io docker-compose-plugin
    else
        echo -e "${RED}[!] Unsupported OS: $OS. Please install Docker and Docker Compose manually.${NC}"
        exit 1
    fi
    sudo systemctl enable docker
    sudo systemctl start docker
    echo -e "${GREEN}[+] Docker installed and started successfully.${NC}"
}

if ! command -v docker &> /dev/null; then
    install_docker
else
    echo -e "${GREEN}[+] Docker is already installed.${NC}"
fi

# Ensure docker service is running
if ! sudo systemctl is-active --quiet docker; then
    echo -e "${YELLOW}[*] Starting Docker service...${NC}"
    sudo systemctl start docker
fi

# Determine docker compose command
if docker compose version &> /dev/null; then
    DOCKER_COMPOSE="docker compose"
elif docker-compose version &> /dev/null; then
    DOCKER_COMPOSE="docker-compose"
else
    echo -e "${YELLOW}[*] Installing Docker Compose plugin...${NC}"
    if [ "$OS" = "ubuntu" ] || [ "$OS" = "debian" ]; then
        sudo apt-get update && sudo apt-get install -y docker-compose-plugin
    elif [ "$OS" = "centos" ] || [ "$OS" = "rhel" ]; then
        sudo yum install -y docker-compose-plugin
    fi
    DOCKER_COMPOSE="docker compose"
fi

# 3. Read User Inputs (with defaults)
echo -e "${YELLOW}--- Configuration Settings ---${NC}"

# Get IP Address
IP=$(curl -s https://api.ipify.org || curl -s https://ifconfig.me || echo "YOUR_VPS_IP")

read -p "Enter Reality listening port [default: 2053]: " PORT
PORT=${PORT:-2053}

read -p "Enter masquerade SNI domain (mimic website) [default: images.apple.com]: " SNI
SNI=${SNI:-images.apple.com}

read -p "Enter fallback destination (dest) [default: 127.0.0.1:443]: " DEST
DEST=${DEST:-127.0.0.1:443}

# 4. Generate Parameters
echo -e "${YELLOW}[*] Generating cryptographic parameters...${NC}"

# UUID
if command -v uuidgen &> /dev/null; then
    UUID=$(uuidgen | tr '[:upper:]' '[:lower:]')
else
    UUID=$(cat /proc/sys/kernel/random/uuid)
fi

# Xray Keys
echo -e "${YELLOW}[*] Pulling xray image and generating x25519 keys...${NC}"
sudo docker pull teddysun/xray:latest
KEYPAIR=$(sudo docker run --rm teddysun/xray:latest xray x25519)
PRIVATE_KEY=$(echo "$KEYPAIR" | grep "PrivateKey:" | awk '{print $2}')
PUBLIC_KEY=$(echo "$KEYPAIR" | grep "Password (PublicKey):" | awk '{print $2}')

# Short ID
SHORT_ID=$(tr -dc 'a-f0-9' < /dev/urandom | head -c 16)

# 5. Create Configuration Directory & Files
echo -e "${YELLOW}[*] Creating deployment folders...${NC}"
DEPLOY_DIR="./xray"
mkdir -p "$DEPLOY_DIR/config"

# Write docker-compose.yml
cat << EOF > "$DEPLOY_DIR/docker-compose.yml"
version: '3.8'

services:
  xray:
    image: teddysun/xray:latest
    container_name: xray
    restart: always
    network_mode: "host"
    volumes:
      - ./config:/etc/xray
    logging:
      driver: "json-file"
      options:
        max-size: "10m"
        max-file: "3"
EOF

# Write config.json
cat << EOF > "$DEPLOY_DIR/config/config.json"
{
  "log": {
    "loglevel": "warning"
  },
  "inbounds": [
    {
      "port": $PORT,
      "protocol": "vless",
      "settings": {
        "clients": [
          {
            "id": "$UUID",
            "flow": ""
          }
        ],
        "decryption": "none"
      },
      "streamSettings": {
        "network": "tcp",
        "security": "reality",
        "realitySettings": {
          "show": false,
          "dest": "$DEST",
          "xver": 0,
          "serverNames": [
            "$SNI"
          ],
          "privateKey": "$PRIVATE_KEY",
          "minClientVer": "",
          "maxClientVer": "",
          "maxTimeDiff": 0,
          "shortIds": [
            "$SHORT_ID"
          ]
        }
      }
    }
  ],
  "outbounds": [
    {
      "protocol": "freedom",
      "tag": "direct"
    },
    {
      "protocol": "blackhole",
      "tag": "block"
    }
  ]
}
EOF

# 6. Start the Service
echo -e "${YELLOW}[*] Starting VLESS Reality container...${NC}"
cd "$DEPLOY_DIR"
sudo $DOCKER_COMPOSE down &>/dev/null || true
sudo $DOCKER_COMPOSE up -d

echo -e "${GREEN}[+] Service started successfully!${NC}"
echo -e "${YELLOW}[*] Waiting for container health check...${NC}"
sleep 3

if sudo docker ps | grep -q xray; then
    echo -e "${GREEN}[+] Xray container is running!${NC}"
else
    echo -e "${RED}[!] Xray container failed to start. Check logs using: docker logs xray${NC}"
    exit 1
fi

# 7. Print Client Links
SHADOWROCKET_URL="vless://$UUID@$IP:$PORT?security=reality&sni=$SNI&fp=chrome&pbk=$PUBLIC_KEY&sid=$SHORT_ID&type=tcp#VLESS_Reality"

echo -e "\n${BLUE}===================================================${NC}"
echo -e "${GREEN}             Deployment Completed Successfully!    ${NC}"
echo -e "${BLUE}===================================================${NC}"
echo -e "${YELLOW}Server IP:      ${NC}$IP"
echo -e "${YELLOW}Port:           ${NC}$PORT"
echo -e "${YELLOW}UUID:           ${NC}$UUID"
echo -e "${YELLOW}PublicKey:      ${NC}$PUBLIC_KEY"
echo -e "${YELLOW}Short ID:       ${NC}$SHORT_ID"
echo -e "${YELLOW}Masquerade SNI: ${NC}$SNI"
echo -e "${BLUE}---------------------------------------------------${NC}"
echo -e "${GREEN}Shadowrocket (小火箭) Import Link:${NC}"
echo -e "${BLUE}$SHADOWROCKET_URL${NC}"
echo -e "${BLUE}---------------------------------------------------${NC}"
echo -e "${GREEN}Clash Meta / Mihomo Configuration Block:${NC}"
cat << EOF
- name: "VLESS-Reality"
  type: vless
  server: $IP
  port: $PORT
  uuid: $UUID
  udp: true
  tls: true
  network: tcp
  servername: $SNI
  reality-opts:
    public-key: $PUBLIC_KEY
    short-id: $SHORT_ID
  client-fingerprint: chrome
EOF
echo -e "${BLUE}===================================================${NC}"

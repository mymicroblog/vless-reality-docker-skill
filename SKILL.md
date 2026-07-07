---
name: vless-reality-deploy-skill
description: Automates the setup of VLESS Reality servers using Docker Compose and generates client nodes for Shadowrocket and Clash.
---

# VLESS Reality Server Deployment Skill

This skill provides step-by-step instructions for an agent to deploy a VLESS Reality server on a VPS and configure client proxy nodes.

## Agent Workflow

### 1. Pre-Deployment Discovery
Before installing anything, inspect the VPS network and process configurations to identify conflicts:
1. Run `docker ps -a` to view existing containers.
2. Run `ss -tulpn` to check listening ports (specifically check for port `443` and alternative HTTPS ports like `2053`, `2083`, `2087`, `8443`, `2096`).
3. Locate active web servers (like Nginx, Apache) to determine if port 443 is occupied.

### 2. Parameter Generation
Generate cryptographic materials and routing parameters:
1. **Client UUID**: Generate a random lower-case UUID.
2. **Reality Keypair**: Run a temporary Docker container on the host to generate the private and public keys:
   ```bash
   docker run --rm teddysun/xray:latest xray x25519
   ```
3. **Short ID**: Generate a random 8-byte (16 hex characters) hexadecimal string (e.g., using `openssl rand -hex 8`).

### 3. Server Configuration & Setup
1. Create a directory for Xray configuration files, e.g., `/home/ubuntu/xray/config/`.
2. Deploy the `docker-compose.yml` file:
   - Use `network_mode: "host"` to easily forward fallback traffic to local services.
   - Configure a native log rotation policy (e.g., max-size: 10m, max-file: 3) to prevent disk fill-up.
3. Write `config.json` with VLESS protocol:
   - If port `443` is already occupied, set Xray to listen on a custom port (e.g. `2053`, `2096`) and configure the `"dest"` to fall back to the local service on port `443` (e.g. `127.0.0.1:443`).
   - Use the generated UUID, PrivateKey, Short ID, and configure the target domain as the mimic SNI.

### 4. Verification
1. Run `docker compose up -d` (or `docker-compose up -d`) to launch Xray.
2. Run `docker logs xray` to verify the logs show `core: Xray started` without error.
3. Check the listening port with `ss -tulpn | grep <PORT>`.

### 5. Client Configuration Generation
Generate client configs using desensitized placeholder values:
- **Shadowrocket URL**:
  `vless://<UUID>@<VPS_IP>:<PORT>?security=reality&sni=<MIMIC_SNI>&fp=chrome&pbk=<PUBLIC_KEY>&sid=<SHORT_ID>&type=tcp#VLESS_Reality`
- **Mihomo/Clash Meta configuration block**:
  ```yaml
  - name: "VLESS-Reality"
    type: vless
    server: <VPS_IP_OR_DOMAIN>
    port: <PORT>
    uuid: <UUID>
    udp: true
    tls: true
    network: tcp
    servername: <MIMIC_SNI>
    reality-opts:
      public-key: <PUBLIC_KEY>
      short-id: <SHORT_ID>
    client-fingerprint: chrome
  ```

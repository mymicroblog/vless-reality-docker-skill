# Client Configuration Guide

This guide explains how to configure VLESS Reality clients on different platforms using the credentials generated during server installation.

---

## 1. iOS Client: Shadowrocket (小火箭)

Shadowrocket fully supports VLESS Reality. You can import your node either by scanning a QR code or copying a standard URL.

### Import via Link
Copy your formatted VLESS URL and select **"Add server from clipboard"** in Shadowrocket:
```text
vless://<UUID>@<VPS_IP_OR_DOMAIN>:<PORT>?security=reality&sni=<MIMIC_SNI>&fp=chrome&pbk=<PUBLIC_KEY>&sid=<SHORT_ID>&type=tcp#VLESS_Reality
```

### Manual Configuration
If you choose to configure the node manually, set the following parameters:

- **Type / Protocol**: `VLESS`
- **Address (Server)**: `<VPS_IP_OR_DOMAIN>`
- **Port**: `<PORT>`
- **UUID**: `<UUID>`
- **Network**: `tcp`
- **TLS**: `Enabled` (Turn ON the switch)
- **Security / Security Type**: `reality`
- **Peer Name / SNI**: `<MIMIC_SNI>`
- **Public Key**: `<PUBLIC_KEY>`
- **Short ID**: `<SHORT_ID>`
- **uTLS / Fingerprint**: `chrome`
- **UDP Forwarding**: `Enabled` (Recommended for gaming and VoIP)

---

## 2. macOS & Windows Client: Clash Verge (Mihomo/Meta Kernel)

To use VLESS Reality on Clash Verge, you must ensure your client is running the **Mihomo (formerly Clash.Meta)** kernel, as the premium Clash kernel does not support VLESS Reality.

Add the following config block to your profile YAML configuration file:

### Adding the Proxy Node
Under the `proxies:` block, add the VLESS Reality proxy:
```yaml
proxies:
  - name: "VLESS-Reality"
    type: vless
    server: <VPS_IP_OR_DOMAIN>
    port: <PORT>
    uuid: <UUID>
    udp: true
    tls: true
    network: tcp
    servername: <MIMIC_SNI> # The target domain used for masquerading (e.g. apple.com or your local Nginx domain)
    reality-opts:
      public-key: <PUBLIC_KEY>
      short-id: <SHORT_ID>
    client-fingerprint: chrome # Must match browser fingerprint (chrome, firefox, edge, etc.)
```

### Routing via Proxy Group
Under `proxy-groups:`, add the proxy node name (e.g. `"VLESS-Reality"`) into your selector proxies list:
```yaml
proxy-groups:
  - name: "PROXY"
    type: select
    proxies:
      - "VLESS-Reality"
      - DIRECT
```

### Recommended Rules
Ensure you block QUIC UDP 443 traffic at the client side to prevent browsers (like Chrome) from bypassing the TCP proxy via HTTP/3. Add this at the top of your `rules:` section:
```yaml
rules:
  - AND,((NETWORK,UDP),(DST-PORT,443)),REJECT
  - GEOIP,LAN,DIRECT
  - GEOIP,CN,DIRECT
  - MATCH,PROXY
```

# Client Configuration Guide / 客户端配置指南

[English](#english) | [简体中文](#简体中文)

---

<a name="english"></a>
## English

This guide explains how to configure VLESS Reality clients on different platforms using the credentials generated during server installation.

### 1. iOS Client: Shadowrocket (小火箭)

Shadowrocket fully supports VLESS Reality. You can import your node either by scanning a QR code or copying a standard URL.

#### Import via Link
Copy your formatted VLESS URL and select **"Add server from clipboard"** in Shadowrocket:
```text
vless://<UUID>@<VPS_IP_OR_DOMAIN>:<PORT>?security=reality&sni=<MIMIC_SNI>&fp=chrome&pbk=<PUBLIC_KEY>&sid=<SHORT_ID>&type=tcp#VLESS_Reality
```

#### Manual Configuration
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

### 2. macOS & Windows Client: Clash Verge (Mihomo/Meta Kernel)

To use VLESS Reality on Clash Verge, you must ensure your client is running the **Mihomo (formerly Clash.Meta)** kernel, as the premium Clash kernel does not support VLESS Reality.

Add the following config block to your profile YAML configuration file:

#### Adding the Proxy Node
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

#### Routing via Proxy Group
Under `proxy-groups:`, add the proxy node name (e.g. `"VLESS-Reality"`) into your selector proxies list:
```yaml
proxy-groups:
  - name: "PROXY"
    type: select
    proxies:
      - "VLESS-Reality"
      - DIRECT
```

#### Recommended Rules
Ensure you block QUIC UDP 443 traffic at the client side to prevent browsers (like Chrome) from bypassing the TCP proxy via HTTP/3. Add this at the top of your `rules:` section:
```yaml
rules:
  - AND,((NETWORK,UDP),(DST-PORT,443)),REJECT
  - GEOIP,LAN,DIRECT
  - GEOIP,CN,DIRECT
  - MATCH,PROXY
```

---

<a name="简体中文"></a>
## 简体中文

本指南介绍了如何使用服务器安装过程中生成的凭据，在不同平台上配置 VLESS Reality 客户端。

### 1. iOS 客户端：Shadowrocket (小火箭)

小火箭原生支持 VLESS Reality。您可以通过扫描二维码或复制标准链接来导入您的节点。

#### 通过链接导入
复制格式化后的 VLESS 链接，然后在小火箭中选择 **“从剪贴板添加服务器”**：
```text
vless://<UUID>@<VPS_IP_OR_DOMAIN>:<PORT>?security=reality&sni=<MIMIC_SNI>&fp=chrome&pbk=<PUBLIC_KEY>&sid=<SHORT_ID>&type=tcp#VLESS_Reality
```

#### 手动参数配置
如果您选择手动配置节点，请填写以下参数：
- **类型 / 协议**：`VLESS`
- **地址 (服务器)**：`<VPS_IP_OR_DOMAIN>`
- **端口**：`<PORT>`
- **UUID**：`<UUID>`
- **传输方式**：`tcp`
- **TLS**：`开启` (打开开关)
- **安全类型 (Security)**：`reality`
- **Peer 名称 / SNI**：`<MIMIC_SNI>`
- **公钥 (Public Key)**：`<PUBLIC_KEY>`
- **短 ID (Short ID)**：`<SHORT_ID>`
- **uTLS 指纹 (Fingerprint)**：`chrome`
- **UDP 转发**：`开启` (推荐游戏及语音通话使用)

---

### 2. macOS & Windows 客户端：Clash Verge (Mihomo/Meta 内核)

要在 Clash Verge 上使用 VLESS Reality，您必须确保客户端正在运行 **Mihomo (原 Clash.Meta)** 内核，因为原生 Clash 内核不支持 VLESS Reality。

将以下配置块添加到您的配置文件 YAML 中：

#### 添加代理节点
在 `proxies:` 块下，添加 VLESS Reality 节点：
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
    servername: <MIMIC_SNI> # 伪装域名（例如 apple.com 或您本地 Nginx 的域名）
    reality-opts:
      public-key: <PUBLIC_KEY>
      short-id: <SHORT_ID>
    client-fingerprint: chrome # 模拟浏览器 TLS 指纹 (可选 chrome, firefox, edge 等)
```

#### 通过策略组进行分流
在 `proxy-groups:` 下，将代理节点名称（例如 `"VLESS-Reality"`) 添加到您的策略组 proxies 列表中：
```yaml
proxy-groups:
  - name: "PROXY"
    type: select
    proxies:
      - "VLESS-Reality"
      - DIRECT
```

#### 推荐的分流规则
确保您在客户端拦截了 UDP 443（QUIC）流量，以防止浏览器（如 Chrome）通过 HTTP/3 直接连接而绕过 TCP 代理。请在 `rules:` 部分的顶部添加此条规则：
```yaml
rules:
  - AND,((NETWORK,UDP),(DST-PORT,443)),REJECT
  - GEOIP,LAN,DIRECT
  - GEOIP,CN,DIRECT
  - MATCH,PROXY
```

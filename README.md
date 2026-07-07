# VLESS Reality Docker Deployment Skill

[English](#english) | [简体中文](#简体中文)

---

<a name="english"></a>
## English

A reusable Antigravity skill and Docker Compose template for deploying VLESS Reality servers on a VPS. It includes masquerade fallbacks to bypass active censorship detection, automated Docker log rotation, and step-by-step client configuration instructions.

### Features
- **Security-First**: Uses VLESS Reality protocol to mimic popular domain handshakes (TLS 1.3/H2), avoiding active detection.
- **Port Conflict Resolution**: Allows setting Xray on a custom port and configuring it to fall back to an existing web server (like Nginx on port 443).
- **Disk Protection**: Includes a built-in log rotation policy in `docker-compose.yml` to limit log sizes on low-spec VPS systems.
- **Bilingual Documentation**: Comprehensive client configuration guides for iOS Shadowrocket and desktop Clash Verge.

### File Structure
```text
.
├── README.md                  # Bilingual readme and overview
├── SKILL.md                   # Antigravity agent skill instructions
├── docker-compose.template.yml # Docker compose template for Xray
├── config.template.json       # Xray core config template
└── docs/
    └── client_guide.md        # Client setup instructions (iOS & Desktop)
```

### Quick Start Deployment

1. **Clone and Prepare**:
   Clone this repository, copy files to your VPS, and rename the templates:
   ```bash
   cp docker-compose.template.yml docker-compose.yml
   cp config.template.json config.json
   ```

2. **Generate Keys**:
   Generate a client UUID and run the following command on the server to get Xray Reality keypair:
   ```bash
   docker run --rm teddysun/xray:latest xray x25519
   ```

3. **Configure**:
   Edit `config.json` and replace the placeholders:
   - `<PORT>`: The port to listen on (e.g. `2053`).
   - `<UUID>`: The generated UUID.
   - `<FALLBACK_DEST>`: The fallback server address (e.g. `127.0.0.1:443` pointing to local Nginx).
   - `<YOUR_DOMAIN>`: Your domain served by the web server (used as SNI).
   - `<PRIVATE_KEY>`: The generated Xray Private Key.
   - `<SHORT_ID>`: A random 8-byte hexadecimal string.

4. **Start Service**:
   Start the Xray container in the background:
   ```bash
   docker compose up -d
   ```

5. **Client Configuration**:
   Refer to [docs/client_guide.md](docs/client_guide.md) to set up Shadowrocket or Clash Verge.

---

<a name="简体中文"></a>
## 简体中文

一套可重复使用的 Antigravity 技能和 Docker Compose 模板，用于在 VPS 上快捷部署 VLESS Reality 服务器。包含探测回落伪装以绕过审查探测、自动 Docker 日志轮转，以及详细的客户端配置指南。

### 特性
- **安全至上**：采用 VLESS Reality 协议模拟热门域名握手（TLS 1.3/H2），防范主动探测。
- **端口冲突解决**：允许 Xray 监听自定义端口并回落（dest）到本地已有的 Web 服务器（如 443 端口上的 Nginx）。
- **磁盘防护**：在 `docker-compose.yml` 中配置了内置的日志轮转策略，防止低配 VPS 磁盘空间被日志填满。
- **双语文档**：针对 iOS 小火箭 (Shadowrocket) 和电脑端 Clash Verge 的详细客户端配置指南。

### 目录结构
```text
.
├── README.md                  # 中英文双语 README 概览
├── SKILL.md                   # Antigravity 智能体技能指令
├── docker-compose.template.yml # Xray 的 Docker compose 部署模板
├── config.template.json       # Xray 核心配置文件模板
└── docs/
    └── client_guide.md        # 客户端配置指南 (iOS 与 桌面端)
```

### 快速部署步骤

1. **克隆与准备**：
   将代码复制到 VPS，并将模板文件重命名：
   ```bash
   cp docker-compose.template.yml docker-compose.yml
   cp config.template.json config.json
   ```

2. **生成密钥**：
   准备一个客户端 UUID，并在服务器上运行以下命令以获取 Xray Reality 密钥对：
   ```bash
   docker run --rm teddysun/xray:latest xray x25519
   ```

3. **配置参数**：
   修改并编辑 `config.json`，替换其中的占位符：
   - `<PORT>`：监听的自定义端口（例如 `2053`）。
   - `<UUID>`：步骤 2 生成的 UUID。
   - `<FALLBACK_DEST>`：探测回落目标（例如 `127.0.0.1:443` 指向本地 Nginx）。
   - `<YOUR_DOMAIN>`：Web 服务器所服务的域名（用作伪装 SNI）。
   - `<PRIVATE_KEY>`：步骤 2 生成的 Xray 私钥 (PrivateKey)。
   - `<SHORT_ID>`：一个随机的 8 字节十六进制短 ID。

4. **启动服务**：
   在后台启动 Xray 容器：
   ```bash
   docker compose up -d
   ```

5. **配置客户端**：
   参考 [docs/client_guide.md](docs/client_guide.md) 配置您的 Shadowrocket 或 Clash Verge 客户端。

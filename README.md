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
├── deploy.sh                  # One-click deployment script
├── docker-compose.template.yml # Docker compose template for Xray
├── config.template.json       # Xray core config template
└── docs/
    └── client_guide.md        # Client setup instructions (iOS & Desktop)
```

### Quick Start Deployment

#### Method 1: Agent-Led Deployment (via Skill)
If you are using an AI coding assistant (like Antigravity) that you trust, you can delegate the entire installation to the agent:
1. Provide the agent with your VPS credentials (IP, username, SSH private key or password).
2. Instruct the agent to read and follow the deployment workflow specified in [SKILL.md](SKILL.md).
3. The agent will automatically connect, inspect configurations, generate keys, install Xray, and return your client connection links.

#### Method 2: One-Click Shell Script Deployment (via Shell)
If you prefer to run the installation yourself directly on the host:
1. Log in to your VPS via SSH.
2. Switch to the root user first (mandatory step):
   ```bash
   sudo -i
   ```
3. Run the one-click deployment script:
   ```bash
   curl -fsSL https://raw.githubusercontent.com/mymicroblog/vless-reality-docker-skill/main/deploy.sh | bash
   ```
4. Configure your client using the links printed in the terminal or refer to [docs/client_guide.md](docs/client_guide.md).

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
├── deploy.sh                  # 一键自动化部署脚本
├── docker-compose.template.yml # Xray 的 Docker compose 部署模板
├── config.template.json       # Xray 核心配置文件模板
└── docs/
    └── client_guide.md        # 客户端配置指南 (iOS 与 桌面端)
```

### 快速部署步骤

#### 方式一：智能体托管一键部署（通过 Skill）
如果您正在使用信任的 AI 智能体助理（如 Antigravity），可以直接将服务器连接凭证交给智能体，实现全自动部署：
1. 将您的 VPS 连接信息（IP、用户名、SSH 私钥或密码）提供给智能体。
2. 指示智能体阅读并执行本项目中的 [SKILL.md](SKILL.md) 技能文档。
3. 智能体会自动完成端口排查、密钥生成、容器安装，并最终为您输出客户端连接二维码和配置节点。

#### 方式二：VPS 本地一键脚本部署（通过 Shell）
如果您希望亲自登录服务器进行快速部署：
1. 通过 SSH 登录您的 VPS 服务器。
2. 首先**切换到 root 用户**（必须步骤）：
   ```bash
   sudo -i
   ```
3. 拷贝并运行以下一键部署脚本（该脚本在启动时会自动进行 root 权限校验）：
   ```bash
   curl -fsSL https://raw.githubusercontent.com/mymicroblog/vless-reality-docker-skill/main/deploy.sh | bash
   ```
4. 根据终端输出的链接配置客户端，或者参考 [docs/client_guide.md](docs/client_guide.md)。

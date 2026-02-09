# 🏢 企业私有化办公系统

为小型装修公司量身定制的私有化办公协作平台，基于 Nextcloud + OnlyOffice，支持文件管理、在线编辑、项目归档和多端访问。

[![Nextcloud](https://img.shields.io/badge/Nextcloud-28-blue)](https://nextcloud.com)
[![OnlyOffice](https://img.shields.io/badge/OnlyOffice-8.0-orange)](https://www.onlyoffice.com)
[![Docker](https://img.shields.io/badge/Docker-Ready-green)](https://docker.com)

---

## 📋 功能特性

### 📁 文件管理
- ✅ 多格式文件上传下载（Word、Excel、PDF、图片）
- ✅ 文件夹创建和管理
- ✅ **文件版本历史**（自动保留10个版本）
- ✅ **在线预览**（无需下载直接查看）
- ✅ 批量上传、拖拽上传

### 🔐 权限管理
- ✅ 基于角色的权限控制（管理员/项目经理/普通员工）
- ✅ 文件夹级别的读写权限
- ✅ 分享链接（支持密码保护和有效期）
- ✅ 操作日志记录

### 📂 项目管理与归档
- ✅ 项目空间：每个装修项目独立文件夹
- ✅ 项目状态管理：进行中 / 已归档
- ✅ 归档项目自动移动并设为只读
- ✅ 项目模板：标准文件夹结构
- ✅ 按时间、客户名称检索

### 📱 多端访问
- ✅ Web 浏览器（响应式设计）
- ✅ 手机 APP（iOS + Android）
- ✅ 文件自动同步（类似网盘）

### ✏️ 协作功能
- ✅ **在线编辑 Office 文档**（OnlyOffice 集成）
- ✅ 评论和批注
- ✅ 多人实时协作编辑

---

## 🚀 快速开始

### 环境要求

- Windows 10/11 专业版 (64位)
- 内存：8GB+（推荐 16GB）
- 存储：100GB+ 可用空间
- Docker Desktop + WSL2

### 一键部署

```powershell
# 1. 克隆仓库
git clone https://github.com/yourusername/office-system-deploy.git
cd office-system-deploy

# 2. 配置环境变量
copy .env.example .env
# 编辑 .env 文件，设置密码和域名

# 3. 生成 SSL 证书（WSL 或 Git Bash）
mkdir nginx/ssl
openssl req -x509 -nodes -days 365 -newkey rsa:2048 \
  -keyout nginx/ssl/server.key \
  -out nginx/ssl/server.crt \
  -subj "/C=CN/ST=Beijing/L=Beijing/O=Company/CN=localhost"

# 4. 启动服务
docker-compose up -d

# 5. 初始化系统
bash scripts/init.sh
```

### 访问系统

- **Web 端**: https://localhost 或 https://192.168.1.100
- **管理员账号**: admin / Admin@2025!（在 .env 中修改）

详细部署指南：[docs/deploy-windows.md](docs/deploy-windows.md)

---

## 📁 项目结构

部署后自动创建以下结构：

```
公司文件库/
├── 01-进行中项目/
│   ├── 项目模板/          # 标准项目文件夹结构
│   │   ├── 01-设计阶段/
│   │   ├── 02-合同文件/
│   │   ├── 03-材料清单/
│   │   ├── 04-施工现场/
│   │   └── 05-验收文档/
│   ├── 2025-张三-阳光小区装修/
│   └── 2025-李四-海景别墅装修/
├── 02-归档项目/
│   ├── 2023年归档/
│   ├── 2024年归档/
│   └── 2025年归档/
├── 03-公司资料/
│   ├── 合同模板/
│   ├── 供应商资料/
│   └── 员工手册/
└── 04-共享资源/
    └── 图片素材/
```

---

## 📚 文档

| 文档 | 说明 |
|------|------|
| [部署指南](docs/deploy-windows.md) | Windows Docker 部署详细步骤 |
| [用户手册](docs/user-guide.md) | 员工使用教程 |
| [管理员手册](docs/admin-guide.md) | 系统管理和维护指南 |

---

## 🛠️ 技术栈

| 组件 | 用途 | 版本 |
|------|------|------|
| Nextcloud | 文件管理和协作平台 | 28.x |
| OnlyOffice | 在线文档编辑 | 8.0 |
| PostgreSQL | 主数据库 | 15 |
| Redis | 缓存加速 | 7 |
| Nginx | 反向代理 + SSL | latest |

---

## 🔒 安全特性

- ✅ HTTPS 加密传输（自签名证书）
- ✅ 强密码策略（8位+，包含大小写、数字、特殊字符）
- ✅ 登录失败锁定（5次失败后锁定10分钟）
- ✅ 操作日志审计
- ✅ 分享链接密码保护

---

## 💾 备份与恢复

### 自动备份
- 每日凌晨 2:00 自动备份
- 保留最近 30 天
- 支持本地和 S3 存储

### 手动备份
```bash
bash scripts/backup.sh
```

### 恢复数据
```bash
bash scripts/restore.sh nextcloud_backup_20250209_120000
```

---

## 📱 手机 APP

1. 下载 Nextcloud APP
   - [iOS App Store](https://apps.apple.com/app/nextcloud/id1125420102)
   - [Android Google Play](https://play.google.com/store/apps/details?id=com.nextcloud.client)

2. 配置服务器地址: `https://your-server-ip`

3. 开启自动上传：
   - 设置 → 自动上传
   - 选择"施工现场"文件夹
   - 拍照自动同步到服务器

---

## 🔄 升级维护

```bash
# 1. 备份
cd office-system-deploy
bash scripts/backup.sh

# 2. 更新镜像
docker-compose pull

# 3. 重启服务
docker-compose up -d
```

---

## 🐛 故障排查

查看日志：
```bash
# 所有服务日志
docker-compose logs -f

# 特定服务
docker-compose logs -f nextcloud
```

常见问题：[管理员手册 - 故障排查](docs/admin-guide.md#七故障排查)

---

## 📝 开源协议

本项目采用 MIT 协议开源。

Nextcloud 和 OnlyOffice 分别遵循各自的许可证。

---

## 🤝 贡献

欢迎提交 Issue 和 Pull Request！

---

## 📧 联系

如有问题，请通过以下方式联系：
- 提交 GitHub Issue
- 邮箱: your-email@example.com

---

<p align="center">
  Made with ❤️ for small business
</p>

# 企业私有化办公系统 - Windows 部署指南

## 系统概述

为装修公司量身定制的私有化办公系统，基于 Nextcloud + OnlyOffice，支持：
- ✅ 文件管理（版本控制、在线预览）
- ✅ 权限管理（角色控制、文件夹权限）
- ✅ 项目管理（进行中/已归档、模板）
- ✅ 在线编辑（Word、Excel、PPT）
- ✅ 移动端 APP（iOS/Android）
- ✅ 自动备份

---

## 一、环境准备

### 1.1 系统要求

- **操作系统**: Windows 10/11 专业版 (64位)
- **内存**: 至少 8GB（推荐 16GB）
- **存储**: 至少 100GB 可用空间
- **网络**: 内网环境，固定 IP 地址

### 1.2 安装 Docker Desktop

1. 下载 Docker Desktop:
   - 访问 https://www.docker.com/products/docker-desktop
   - 下载 Windows 版本

2. 安装 Docker:
   - 运行安装程序
   - **重要**: 在安装向导中勾选 "Use WSL 2 instead of Hyper-V"
   - 完成安装后重启电脑

3. 配置 WSL2:
   ```powershell
   # 以管理员身份运行 PowerShell
   wsl --set-default-version 2
   
   # 更新 WSL
   wsl --update
   ```

4. 配置 Docker 资源:
   - 打开 Docker Desktop → Settings → Resources
   - **内存**: 至少分配 4GB（推荐 6GB）
   - **CPU**: 至少分配 2 核
   - **磁盘**: 确保有足够空间
   - 点击 Apply & Restart

---

## 二、部署系统

### 2.1 下载部署文件

1. 下载本仓库到本地:
   ```powershell
   # 使用 git 克隆（需要安装 git）
   git clone https://github.com/yourusername/office-system-deploy.git
   cd office-system-deploy
   ```
   
   或直接在 GitHub 下载 ZIP 并解压

2. 复制环境变量文件:
   ```powershell
   copy .env.example .env
   ```

3. 编辑 .env 文件，修改以下配置:
   ```
   NEXTCLOUD_ADMIN_USER=admin                    # 管理员账号
   NEXTCLOUD_ADMIN_PASSWORD=YourStrongPassword   # 管理员密码
   OVERWRITEHOST=192.168.1.100:8080             # 改为你的服务器IP
   POSTGRES_PASSWORD=YourDBPassword              # 数据库密码
   ONLYOFFICE_JWT_SECRET=YourJWTSecret           # OnlyOffice密钥
   ```

### 2.2 生成 SSL 证书

```powershell
# 使用 OpenSSL 生成自签名证书（需要安装 OpenSSL 或使用 WSL）
mkdir nginx\ssl

# 在 WSL 终端中运行:
openssl req -x509 -nodes -days 365 -newkey rsa:2048 `
  -keyout nginx/ssl/server.key `
  -out nginx/ssl/server.crt `
  -subj "/C=CN/ST=Beijing/L=Beijing/O=Company/CN=192.168.1.100"
```

### 2.3 启动服务

```powershell
# 在项目目录中打开 PowerShell

# 1. 拉取镜像
docker-compose pull

# 2. 启动服务
docker-compose up -d

# 3. 查看日志，等待启动完成
docker-compose logs -f

# 看到 "Ready to handle connections" 表示启动成功
```

### 2.4 初始化系统

```powershell
# 运行初始化脚本（在 WSL 或 Git Bash 中）
bash scripts/init.sh
```

或手动执行:
```powershell
# 等待 30 秒后，进入 Nextcloud 容器
docker exec -it office_nextcloud bash

# 安装应用
su -s /bin/bash www-data -c "php occ app:enable files_versions"
su -s /bin/bash www-data -c "php occ app:enable activity"

# 创建用户组
su -s /bin/bash www-data -c "php occ group:add 管理员"
su -s /bin/bash www-data -c "php occ group:add 项目经理"
su -s /bin/bash www-data -c "php occ group:add 普通员工"

# 退出容器
exit
```

---

## 三、配置 OnlyOffice

1. 使用管理员账号登录 Nextcloud
   - 地址: https://192.168.1.100 (或你的服务器IP)
   - 默认账号: admin (在 .env 中设置)

2. 进入设置 → ONLYOFFICE:
   - 文档服务器地址: `https://192.168.1.100/onlyoffice/`
   - JWT 密钥: 填入 .env 中的 ONLYOFFICE_JWT_SECRET
   - 点击保存

3. 勾选默认打开的文档类型:
   - ☑️ 文本文档 (.docx)
   - ☑️ 电子表格 (.xlsx)
   - ☑️ 演示文稿 (.pptx)

---

## 四、访问方式

### 4.1 Web 浏览器

- **内网访问**: https://192.168.1.100
- 首次访问会提示证书不安全，点击"高级"→"继续访问"

### 4.2 手机 APP

1. 下载 Nextcloud APP:
   - iOS: App Store 搜索 "Nextcloud"
   - Android: 应用商店搜索 "Nextcloud"

2. 配置连接:
   - 打开 APP → 登录
   - 服务器地址: `https://192.168.1.100`
   - 输入账号密码

3. 自动同步:
   - 设置 → 自动上传
   - 开启"照片和视频"

---

## 五、日常使用

### 5.1 创建项目

1. 进入"01-进行中项目"
2. 复制"项目模板"文件夹
3. 重命名为"2025-客户名-项目名"
4. 在项目文件夹内上传文件

### 5.2 项目归档

1. 选中项目文件夹
2. 点击"移动或复制"
3. 选择"02-归档项目/2025年归档"
4. 设置文件夹权限为"只读"

### 5.3 分享文件

1. 选中文件/文件夹
2. 点击"分享"图标
3. 选择分享方式:
   - 内部用户: 选择用户或用户组
   - 外部链接: 设置密码和有效期

---

## 六、备份与恢复

### 6.1 手动备份

```powershell
# 运行备份脚本
bash scripts/backup.sh

# 备份文件保存在 backup/manual/ 目录
```

### 6.2 自动备份

已配置每日凌晨 2 点自动备份，备份文件保存在:
- 本地: `backup/archive/`
- S3 (可选): 在 .env 中配置 S3 参数

### 6.3 恢复数据

```powershell
# 查看可用备份
ls backup/manual/

# 恢复指定备份
bash scripts/restore.sh nextcloud_backup_20250209_120000
```

---

## 七、故障排查

### 7.1 服务无法启动

```powershell
# 查看详细日志
docker-compose logs nextcloud
docker-compose logs onlyoffice

# 重启服务
docker-compose restart
```

### 7.2 端口冲突

如果 8080 或 8081 端口被占用，修改 docker-compose.yml:
```yaml
ports:
  - "8090:80"    # 改为其他端口
```

### 7.3 OnlyOffice 无法连接

1. 检查容器状态:
   ```powershell
   docker ps | findstr onlyoffice
   ```

2. 检查网络连接:
   ```powershell
   docker exec office_nextcloud ping -c 3 onlyoffice
   ```

3. 重新配置 JWT 密钥:
   ```powershell
   docker exec office_onlyoffice /usr/bin/documentserver-jwt-status.sh
   ```

### 7.4 内存不足

增加 Docker Desktop 内存分配:
- Settings → Resources → Memory → 增加到 6GB 或更高

---

## 八、外网访问（可选）

### 方案 1: 内网穿透（推荐）

使用 frp 或 ngrok:
```bash
# 在另一台有公网IP的服务器部署 frps
# 本地部署 frpc 连接到 frps
```

### 方案 2: VPN

部署 WireGuard 或 OpenVPN，员工通过 VPN 接入内网

### 方案 3: 公网服务器

将系统迁移到云服务器，配置域名和 SSL

---

## 九、升级维护

### 9.1 更新系统

```powershell
# 1. 备份数据
bash scripts/backup.sh

# 2. 拉取新版本镜像
docker-compose pull

# 3. 重启服务
docker-compose up -d
```

### 9.2 查看日志

```powershell
# 实时日志
docker-compose logs -f

# 仅查看错误
docker-compose logs | findstr ERROR
```

---

## 十、技术支持

如有问题，请查看:
- Nextcloud 官方文档: https://docs.nextcloud.com
- OnlyOffice 文档: https://api.onlyoffice.com
- 提交 Issue: https://github.com/yourusername/office-system-deploy/issues

---

## 附录：目录结构说明

```
office-system-deploy/
├── docker-compose.yml      # 主部署文件
├── .env                    # 环境变量（需自己创建）
├── .env.example            # 环境变量模板
├── nginx/                  # Nginx 配置
│   ├── nginx.conf
│   ├── nextcloud.conf
│   └── ssl/                # SSL 证书
├── init/                   # 初始化配置
│   └── custom.config.php
├── scripts/                # 管理脚本
│   ├── init.sh
│   ├── backup.sh
│   └── restore.sh
├── backup/                 # 备份目录
│   ├── manual/            # 手动备份
│   └── archive/           # 自动备份
├── logs/                   # 日志目录
└── docs/                   # 文档
    ├── deploy-windows.md   # 本文件
    ├── user-guide.md       # 用户手册
    └── admin-guide.md      # 管理员手册
```

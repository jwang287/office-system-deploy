# 管理员手册

## 一、系统管理概览

作为系统管理员，你需要负责：
- 用户账号管理
- 权限配置
- 系统维护
- 备份管理
- 故障排查

---

## 二、用户管理

### 2.1 创建用户

**方式 1 - Web 界面:**
1. 点击右上角头像 → "用户"
2. 点击左下角 "+ 新建用户"
3. 填写信息:
   - 用户名（建议使用姓名拼音）
   - 邮箱
   - 初始密码
   - 用户组
4. 点击"创建"

**方式 2 - 命令行:**
```bash
docker exec -u www-data office_nextcloud php occ user:add \
  --display-name="张三" \
  --group="普通员工" \
  --password-from-env \
  zhangsan
```

### 2.2 用户组管理

**创建用户组:**
1. 用户管理页面
2. 点击"添加组"
3. 输入组名
4. 建议分组:
   - 管理员（系统管理）
   - 项目经理（项目审批）
   - 普通员工（日常操作）

**为用户分配组:**
1. 在用户列表中找到用户
2. 点击组列的下拉框
3. 勾选所属组

### 2.3 权限配置

**全局权限:**
1. 管理设置 → 管理 → 共享
2. 配置:
   - 允许用户共享
   - 强制设置分享密码
   - 分享链接默认有效期

**文件夹权限:**
1. 进入目标文件夹
2. 点击"分享"
3. 添加用户/用户组
4. 设置权限:
   - 可编辑（读写）
   - 可创建（仅上传）
   - 仅查看（只读）
   - 可删除

**推荐权限策略:**

| 文件夹 | 管理员 | 项目经理 | 普通员工 |
|--------|--------|----------|----------|
| 01-进行中项目 | 完全控制 | 完全控制 | 读写 |
| 02-归档项目 | 完全控制 | 只读 | 只读 |
| 03-公司资料 | 完全控制 | 只读 | 只读 |
| 04-共享资源 | 完全控制 | 读写 | 只读 |

### 2.4 禁用/删除用户

**临时禁用:**
1. 用户管理 → 找到用户
2. 点击"禁用"按钮
3. 用户无法登录，文件保留

**永久删除:**
1. 先备份该用户的重要文件
2. 点击"删除"按钮
3. 确认删除
4. 用户文件可转移给其他用户或删除

---

## 三、应用管理

### 3.1 安装应用

1. 点击右上角头像 → "应用"
2. 浏览应用商店
3. 找到需要的应用，点击"下载并启用"

**推荐应用:**

| 应用名 | 功能 | 必要性 |
|--------|------|--------|
| ONLYOFFICE | 在线编辑 | 必需 |
| Calendar | 日历 | 推荐 |
| Contacts | 通讯录 | 推荐 |
| Deck | 任务管理 | 可选 |
| Group folders | 组文件夹 | 必需 |

### 3.2 配置 Group Folders

**安装 Group Folders:**
1. 应用商店 → 搜索 "Group folders"
2. 下载并启用

**创建组文件夹:**
1. 设置 → 管理 → Group folders
2. 点击"创建"
3. 配置:
   - 文件夹名: "公司文件库"
   - 可访问组: 所有用户组
   - 配额: 无限制
   - 权限: 根据组设置

### 3.3 配置 ONLYOFFICE

1. 设置 → 管理 → ONLYOFFICE
2. 填写:
   - 文档服务器地址: `https://your-domain/onlyoffice/`
   - JWT 密钥: [查看 .env 文件]
3. 高级设置:
   - 默认编辑器: ONLYOFFICE
   - 支持的格式: 全选

---

## 四、系统监控

### 4.1 查看日志

**Nextcloud 日志:**
```bash
# Web 界面
设置 → 管理 → 日志

# 命令行
docker exec office_nextcloud tail -f /var/log/nextcloud/nextcloud.log
```

**系统日志:**
```bash
# 查看所有容器日志
docker-compose logs -f

# 查看特定容器
docker-compose logs -f nextcloud
```

### 4.2 性能监控

**系统信息:**
1. 设置 → 管理 → 系统
2. 查看:
   - 版本信息
   - 数据库状态
   - 内存使用
   - 文件锁状态

**磁盘空间:**
```bash
docker system df
df -h
```

### 4.3 安全监控

**登录失败记录:**
1. 设置 → 管理 → 安全
2. 查看:
   - 失败登录尝试
   - 被阻止的 IP

**操作日志:**
- 活动应用 → 筛选条件
- 可按用户、时间、操作类型筛选

---

## 五、备份管理

### 5.1 手动备份

**运行备份脚本:**
```bash
cd office-system-deploy
bash scripts/backup.sh
```

**备份内容:**
- 数据库 (PostgreSQL)
- Nextcloud 数据
- 配置文件

**备份位置:**
- 本地: `backup/manual/`
- 命名格式: `nextcloud_backup_YYYYMMDD_HHMMSS_*.tar.gz`

### 5.2 自动备份

已配置每日自动备份:
- 时间: 每天凌晨 2:00
- 保留: 最近 30 天
- 位置: `backup/archive/`

**配置 S3 备份:**
1. 编辑 `.env` 文件
2. 填写 S3 参数:
   ```
   S3_BUCKET=your-bucket
   S3_ACCESS_KEY=your-key
   S3_SECRET_KEY=your-secret
   S3_ENDPOINT=https://s3.amazonaws.com
   ```
3. 重启备份服务

### 5.3 恢复数据

**查看可用备份:**
```bash
ls -lt backup/manual/
```

**执行恢复:**
```bash
bash scripts/restore.sh nextcloud_backup_20250209_120000
```

**注意事项:**
- 恢复会覆盖现有数据
- 恢复前做好当前数据备份
- 恢复后检查数据完整性

---

## 六、维护任务

### 6.1 日常检查清单

**每日:**
- [ ] 检查服务状态
- [ ] 查看错误日志
- [ ] 确认备份成功

**每周:**
- [ ] 清理临时文件
- [ ] 检查磁盘空间
- [ ] 更新病毒库（如有）

**每月:**
- [ ] 执行手动备份
- [ ] 测试恢复流程
- [ ] 清理旧版本文件
- [ ] 更新系统补丁

### 6.2 清理维护

**清理文件版本:**
```bash
# 进入容器
docker exec -u www-data -it office_nextcloud bash

# 清理旧版本（保留最近10个）
php occ versions:cleanup

# 清理特定用户的版本
php occ versions:cleanup username
```

**清理回收站:**
```bash
# 查看回收站大小
docker exec -u www-data office_nextcloud php occ trashbin:size

# 清空回收站
docker exec -u www-data office_nextcloud php occ trashbin:cleanup
```

**清理临时文件:**
```bash
docker exec office_nextcloud rm -rf /tmp/*
docker exec office_nextcloud rm -rf /var/www/html/data/appdata_*/preview/*
```

### 6.3 数据库维护

**优化数据库:**
```bash
docker exec office_postgres psql -U nextcloud nextcloud -c "VACUUM ANALYZE;"
```

**查看数据库大小:**
```bash
docker exec office_postgres psql -U nextcloud nextcloud -c "\dt+"
```

---

## 七、故障排查

### 7.1 服务无法访问

**检查步骤:**
1. 检查 Docker 状态:
   ```bash
   docker ps
   ```

2. 查看容器日志:
   ```bash
   docker-compose logs
   ```

3. 检查端口占用:
   ```bash
   netstat -an | findstr 8080
   ```

4. 重启服务:
   ```bash
   docker-compose restart
   ```

### 7.2 OnlyOffice 无法连接

**排查步骤:**
1. 检查容器状态
2. 测试网络连通:
   ```bash
   docker exec office_nextcloud curl http://onlyoffice:80
   ```
3. 检查 JWT 配置
4. 重启 OnlyOffice:
   ```bash
   docker-compose restart onlyoffice
   ```

### 7.3 性能问题

**优化建议:**
1. 增加 Docker 内存分配
2. 启用 Redis（已配置）
3. 优化数据库:
   ```bash
   docker exec office_postgres psql -U nextcloud nextcloud -c "VACUUM FULL;"
   ```
4. 清理预览缓存:
   ```bash
   docker exec -u www-data office_nextcloud php occ preview:reset
   ```

### 7.4 数据库连接失败

**排查:**
1. 检查数据库容器状态
2. 检查环境变量是否正确
3. 查看数据库日志:
   ```bash
   docker-compose logs db
   ```

---

## 八、安全设置

### 8.1 密码策略

**配置强密码:**
1. 设置 → 安全 → 密码策略
2. 配置:
   - 最小长度: 8
   - 要求大写字母
   - 要求小写字母
   - 要求数字
   - 要求特殊字符
   - 禁止常见密码

### 8.2 登录保护

**Brute Force 保护:**
已自动启用，配置如下:
- 失败 5 次后锁定 10 分钟
- 失败 10 次后锁定 1 小时

**查看被阻止的 IP:**
```bash
docker exec -u www-data office_nextcloud php occ security:bruteforce:attempts IP_ADDRESS
```

### 8.3 审计日志

**启用审计:**
1. 应用商店安装 "Auditing"
2. 配置记录:
   - 用户登录
   - 文件操作
   - 权限变更

### 8.4 HTTPS 证书更新

**自签名证书续期:**
```bash
# 生成新证书
openssl req -x509 -nodes -days 365 -newkey rsa:2048 \
  -keyout nginx/ssl/server.key \
  -out nginx/ssl/server.crt

# 重启 Nginx
docker-compose restart nginx
```

---

## 九、升级指南

### 9.1 升级前准备

1. **备份数据:**
   ```bash
   bash scripts/backup.sh
   ```

2. **查看版本说明:**
   - https://nextcloud.com/changelog/
   - 确认兼容性

### 9.2 执行升级

**Docker 方式升级:**
```bash
# 1. 停止服务
docker-compose down

# 2. 备份数据卷
cp -r /var/lib/docker/volumes/office-system-deploy_nextcloud_data/_data \
      ./backup/nextcloud_data_backup_$(date +%Y%m%d)

# 3. 拉取新版本
docker-compose pull

# 4. 启动服务
docker-compose up -d

# 5. 执行升级命令
docker exec -u www-data office_nextcloud php occ upgrade

# 6. 检查状态
docker exec -u www-data office_nextcloud php occ status
```

**应用升级:**
```bash
# 更新所有应用
docker exec -u www-data office_nextcloud php occ app:update --all
```

### 9.3 升级后检查

1. 登录系统测试
2. 检查文件访问
3. 测试在线编辑
4. 检查用户权限
5. 查看日志是否有错误

---

## 十、联系支持

遇到无法解决的问题时:
- Nextcloud 社区: https://help.nextcloud.com
- GitHub Issues: https://github.com/nextcloud/server/issues
- 本项目管理: [填写联系信息]

---

## 附录：常用命令速查

```bash
# 查看容器状态
docker-compose ps

# 查看日志
docker-compose logs -f [service]

# 重启服务
docker-compose restart [service]

# 进入容器
docker exec -it [container] bash

# 执行 occ 命令
docker exec -u www-data office_nextcloud php occ [command]

# 数据库操作
docker exec -it office_postgres psql -U nextcloud nextcloud

# 备份
docker-compose exec -T db pg_dump -U nextcloud nextcloud > backup.sql

# 恢复
docker exec -i office_postgres psql -U nextcloud nextcloud < backup.sql
```

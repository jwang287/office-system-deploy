#!/bin/bash
# ==========================================
# Nextcloud 恢复脚本
# ==========================================

set -e

if [ $# -lt 1 ]; then
    echo "用法: $0 <备份文件前缀>"
    echo "示例: $0 nextcloud_backup_20250209_120000"
    exit 1
fi

BACKUP_PREFIX="$1"
BACKUP_DIR="./backup/manual"

echo "=== Nextcloud 恢复脚本 ==="
echo "恢复备份: ${BACKUP_PREFIX}"
echo ""

# 检查备份文件是否存在
if [ ! -f "${BACKUP_DIR}/${BACKUP_PREFIX}_database.sql" ]; then
    echo "错误: 找不到数据库备份文件"
    exit 1
fi

# 确认恢复
echo "警告: 恢复将覆盖现有数据！"
read -p "确认继续? (yes/no): " confirm
if [ "$confirm" != "yes" ]; then
    echo "已取消"
    exit 0
fi

cd "$(dirname "$0")/.."

echo ""
echo "1. 停止所有服务..."
docker-compose down

echo ""
echo "2. 恢复数据卷..."
if [ -f "${BACKUP_DIR}/${BACKUP_PREFIX}_data.tar.gz" ]; then
    # 清理旧数据
    docker volume rm office-system-deploy_nextcloud_data 2>/dev/null || true
    docker volume create office-system-deploy_nextcloud_data
    
    # 解压数据
    docker run --rm \
        -v office-system-deploy_nextcloud_data:/target \
        -v "$(pwd)/${BACKUP_DIR}:/backup:ro" \
        alpine tar xzf "/backup/${BACKUP_PREFIX}_data.tar.gz" -C /target --strip-components=1
fi

echo ""
echo "3. 启动数据库..."
docker-compose up -d db
sleep 5

echo ""
echo "4. 恢复数据库..."
docker exec -i office_postgres psql -U nextcloud nextcloud < "${BACKUP_DIR}/${BACKUP_PREFIX}_database.sql"

echo ""
echo "5. 启动所有服务..."
docker-compose up -d

echo ""
echo "6. 等待服务就绪..."
sleep 10

echo ""
echo "=== 恢复完成 ==="
echo "请访问 https://your-domain 验证"

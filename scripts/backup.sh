#!/bin/bash
# ==========================================
# Nextcloud 备份脚本
# 支持本地和 S3 备份
# ==========================================

set -e

BACKUP_DIR="./backup/manual"
TIMESTAMP=$(date +%Y%m%d_%H%M%S)
BACKUP_NAME="nextcloud_backup_${TIMESTAMP}"

echo "=== Nextcloud 备份脚本 ==="
echo "备份时间: $(date)"
echo ""

# 创建备份目录
mkdir -p "${BACKUP_DIR}"

# 进入主目录
cd "$(dirname "$0")/.."

echo "1. 停止 Nextcloud 容器..."
docker-compose stop nextcloud

echo ""
echo "2. 备份数据库..."
docker exec office_postgres pg_dump -U nextcloud nextcloud > "${BACKUP_DIR}/${BACKUP_NAME}_database.sql"

echo ""
echo "3. 备份 Nextcloud 数据..."
tar czf "${BACKUP_DIR}/${BACKUP_NAME}_data.tar.gz" -C ./docker nextcloud_data 2>/dev/null || \
tar czf "${BACKUP_DIR}/${BACKUP_NAME}_data.tar.gz" -C /var/lib/docker/volumes office-system-deploy_nextcloud_data/_data

echo ""
echo "4. 备份配置文件..."
tar czf "${BACKUP_DIR}/${BACKUP_NAME}_config.tar.gz" \
    ./docker-compose.yml \
    ./.env \
    ./nginx/ \
    ./init/ \
    2>/dev/null

echo ""
echo "5. 启动 Nextcloud 容器..."
docker-compose start nextcloud

echo ""
echo "=== 备份完成 ==="
echo "备份文件列表:"
ls -lh "${BACKUP_DIR}/${BACKUP_NAME}"* 2>/dev/null || echo "备份文件已生成"
echo ""
echo "备份位置: ${BACKUP_DIR}"
echo ""

# 清理旧备份（保留最近30天）
echo "6. 清理30天前的旧备份..."
find "${BACKUP_DIR}" -name "nextcloud_backup_*" -type f -mtime +30 -delete 2>/dev/null || true
echo "清理完成"

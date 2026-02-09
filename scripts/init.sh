#!/bin/bash
# ==========================================
# Nextcloud 初始化脚本
# 创建预设文件夹结构和用户组
# ==========================================

set -e

echo "=== Nextcloud 初始化脚本 ==="
echo "请确保 Nextcloud 容器已启动"
echo ""

# 等待 Nextcloud 就绪
echo "等待 Nextcloud 服务就绪..."
sleep 10

# 检查容器状态
if ! docker ps | grep -q "office_nextcloud"; then
    echo "错误：Nextcloud 容器未运行"
    exit 1
fi

# 安装必要的应用
echo "安装必要的应用..."
docker exec -u www-data office_nextcloud php occ app:enable files_versions || true
docker exec -u www-data office_nextcloud php occ app:enable files_pdfviewer || true
docker exec -u www-data office_nextcloud php occ app:enable files_texteditor || true
docker exec -u www-data office_nextcloud php occ app:enable files_rightclick || true
docker exec -u www-data office_nextcloud php occ app:enable activity || true
docker exec -u www-data office_nextcloud php occ app:enable notifications || true
docker exec -u www-data office_nextcloud php occ app:enable user_status || true

# 创建用户组
echo "创建用户组..."
docker exec -u www-data office_nextcloud php occ group:add "管理员" || true
docker exec -u www-data office_nextcloud php occ group:add "项目经理" || true
docker exec -u www-data office_nextcloud php occ group:add "普通员工" || true

# 创建文件夹结构
echo "创建预设文件夹结构..."

# 创建文件夹的函数
create_folder() {
    local path="$1"
    docker exec -u www-data office_nextcloud php occ files:mkdir "$path" 2>/dev/null || true
}

# 公司文件库主结构
create_folder "/公司文件库"
create_folder "/公司文件库/01-进行中项目"
create_folder "/公司文件库/01-进行中项目/项目模板"
create_folder "/公司文件库/01-进行中项目/项目模板/01-设计阶段"
create_folder "/公司文件库/01-进行中项目/项目模板/02-合同文件"
create_folder "/公司文件库/01-进行中项目/项目模板/03-材料清单"
create_folder "/公司文件库/01-进行中项目/项目模板/04-施工现场"
create_folder "/公司文件库/01-进行中项目/项目模板/05-验收文档"

create_folder "/公司文件库/02-归档项目"
create_folder "/公司文件库/02-归档项目/2023年归档"
create_folder "/公司文件库/02-归档项目/2024年归档"
create_folder "/公司文件库/02-归档项目/2025年归档"

create_folder "/公司文件库/03-公司资料"
create_folder "/公司文件库/03-公司资料/合同模板"
create_folder "/公司文件库/03-公司资料/供应商资料"
create_folder "/公司文件库/03-公司资料/员工手册"
create_folder "/公司文件库/03-公司资料/规章制度"

create_folder "/公司文件库/04-共享资源"
create_folder "/公司文件库/04-共享资源/图片素材"
create_folder "/公司文件库/04-共享资源/设计图库"
create_folder "/公司文件库/04-共享资源/产品目录"

# 创建示例项目文件夹
create_folder "/公司文件库/01-进行中项目/2025-张三-阳光小区装修"
create_folder "/公司文件库/01-进行中项目/2025-李四-海景别墅装修"

echo ""
echo "=== 初始化完成 ==="
echo ""
echo "请登录 Nextcloud 管理后台进行以下操作："
echo "1. 设置 → 基本设置 → 配置 ONLYOFFICE"
echo "   文档服务器地址: https://your-domain/onlyoffice/"
echo "   JWT 密钥: [查看 .env 文件]"
echo ""
echo "2. 用户管理 → 创建员工账号并分配到相应用户组"
echo ""
echo "3. 文件 → 设置文件夹权限"
echo ""
echo "4. 应用 → 下载 Nextcloud 手机 APP"
echo "   iOS: https://apps.apple.com/app/nextcloud/id1125420102"
echo "   Android: https://play.google.com/store/apps/details?id=com.nextcloud.client"
echo ""

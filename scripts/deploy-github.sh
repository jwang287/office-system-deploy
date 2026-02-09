#!/bin/bash
# GitHub 部署脚本

cd /home/ubuntu/.openclaw/workspace/office-system-deploy

echo "=========================================="
echo "  GitHub 仓库 + GitHub Pages 部署"
echo "=========================================="
echo ""

# GitHub 用户名
GITHUB_USER="${1:-}"

if [ -z "$GITHUB_USER" ]; then
    echo "请提供 GitHub 用户名："
    echo "用法: $0 <github-username>"
    echo ""
    echo "例如: $0 litosilo"
    exit 1
fi

echo "GitHub 用户名: $GITHUB_USER"
echo ""

# 配置 git
git config user.email "deploy@office-system.local" 2>/dev/null || true
git config user.name "Office System Deploy" 2>/dev/null || true

# 确保所有更改已提交
if [ -n "$(git status --porcelain 2>/dev/null)" ]; then
    echo "提交更改..."
    git add -A
    git commit -m "Prepare for GitHub deployment"
fi

# 移除旧的 remote（如果存在）
if git remote | grep -q "origin"; then
    git remote remove origin
fi

# 添加远程仓库
REMOTE_URL="https://github.com/$GITHUB_USER/office-system-deploy.git"
echo "添加远程仓库: $REMOTE_URL"
git remote add origin "$REMOTE_URL"

echo ""
echo "=========================================="
echo "  推送到 GitHub..."
echo "=========================================="
echo ""

# 推送
git push -u origin main

PUSH_RESULT=$?

if [ $PUSH_RESULT -eq 0 ]; then
    echo ""
    echo "=========================================="
    echo "  ✅ 推送成功！"
    echo "=========================================="
    echo ""
    echo "仓库地址: https://github.com/$GITHUB_USER/office-system-deploy"
    echo ""
    echo "下一步 - 启用 GitHub Pages："
    echo "1. 访问 https://github.com/$GITHUB_USER/office-system-deploy/settings/pages"
    echo "2. Source 选择 'Deploy from a branch'"
    echo "3. Branch 选择 'main'，文件夹选择 '/ (root)' → 改为 '/docs-site'"
    echo "4. 点击 Save"
    echo ""
    echo "等待 1-2 分钟后访问："
    echo "https://$GITHUB_USER.github.io/office-system-deploy/"
    echo ""
else
    echo ""
    echo "❌ 推送失败"
    echo ""
    echo "可能的原因："
    echo "1. GitHub 仓库不存在 - 请先创建"
    echo "2. 认证失败 - 需要使用 Personal Access Token 作为密码"
    echo ""
    echo "创建 Token: https://github.com/settings/tokens"
    echo "需要勾选 'repo' 权限"
fi

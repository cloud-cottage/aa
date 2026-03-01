#!/bin/bash

echo "🚀 快速部署到 GitHub Pages..."

# 检查是否在正确的目录
if [ ! -f "pubspec.yaml" ]; then
    echo "❌ 请在项目根目录运行此脚本"
    exit 1
fi

# 清理之前的构建
echo "🧹 清理之前的构建..."
rm -rf build/

# 使用简化版本进行测试
echo "📱 使用简化版本进行测试..."
cp lib/main_simple.dart lib/main.dart

# 获取依赖
echo "📦 获取依赖..."
flutter pub get

# 启用 web 支持
echo "🌐 启用 Web 支持..."
flutter config --enable-web

# 构建
echo "🏗️ 构建 Web 版本..."
flutter build web --release --web-renderer canvaskit

# 检查构建结果
if [ -d "build/web" ]; then
    echo "✅ 构建成功！"
    
    # 显示关键文件
    echo "📋 关键文件检查:"
    ls -la build/web/index.html
    ls -la build/web/flutter.js
    ls -la build/web/main.dart.js
    
    # 提交更改
    echo "📝 提交更改..."
    git add .
    git commit -m "Quick deploy: Update web build with simplified version"
    
    echo "🚀 推送到 GitHub..."
    git push
    
    echo ""
    echo "✅ 部署完成！"
    echo "📊 查看部署状态: https://github.com/$(git config remote.origin.url | sed 's/.*:\/\/github.com\///; s/\.git//')/actions"
    echo "🌐 访问网站: https://$(git config remote.origin.url | sed 's/.*:\/\/github.com\///; s/\.git//').github.io"
    
else
    echo "❌ 构建失败！"
    exit 1
fi

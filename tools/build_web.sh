#!/bin/bash

echo "🚀 开始构建 Flutter Web 项目..."

# 检查 Flutter 是否安装
if ! command -v flutter &> /dev/null; then
    echo "❌ Flutter 未安装，请先安装 Flutter SDK"
    exit 1
fi

# 检查项目结构
if [ ! -f "pubspec.yaml" ]; then
    echo "❌ 未找到 pubspec.yaml，请确保在项目根目录运行此脚本"
    exit 1
fi

echo "📦 获取依赖..."
flutter pub get

echo "🧪 运行测试..."
flutter test

echo "🌐 启用 Web 支持..."
flutter config --enable-web

echo "🏗️ 构建 Web 版本..."
flutter build web --release --web-renderer canvaskit

# 检查构建结果
if [ -d "build/web" ]; then
    echo "✅ 构建成功！"
    echo "📁 构建文件位于: build/web/"
    
    # 显示构建文件列表
    echo "📋 构建文件列表:"
    ls -la build/web/
    
    # 检查关键文件
    echo "🔍 检查关键文件:"
    if [ -f "build/web/index.html" ]; then
        echo "✅ index.html 存在"
    else
        echo "❌ index.html 缺失"
    fi
    
    if [ -f "build/web/flutter.js" ]; then
        echo "✅ flutter.js 存在"
    else
        echo "❌ flutter.js 缺失"
    fi
    
    if [ -f "build/web/main.dart.js" ]; then
        echo "✅ main.dart.js 存在"
    else
        echo "❌ main.dart.js 缺失"
    fi
    
    echo ""
    echo "🌟 本地测试方法:"
    echo "cd build/web && python3 -m http.server 8000"
    echo "然后在浏览器访问: http://localhost:8000"
    echo ""
    echo "🚀 部署到 GitHub Pages:"
    echo "1. git add ."
    echo "2. git commit -m 'Update web build'"
    echo "3. git push"
    echo "4. 等待 GitHub Actions 完成部署"
    
else
    echo "❌ 构建失败！"
    exit 1
fi

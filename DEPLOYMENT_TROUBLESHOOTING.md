# GitHub Pages 部署故障排除指南

## 常见问题及解决方案

### 1. 构建失败问题

#### 问题: Flutter 构建错误
```
Error: No web device found
```

**解决方案:**
```bash
flutter config --enable-web
flutter devices
```

#### 问题: 依赖获取失败
```
Error: Unable to find package
```

**解决方案:**
```bash
flutter clean
flutter pub cache repair
flutter pub get
```

### 2. GitHub Actions 失败

#### 问题: 权限错误
```
Error: Permission denied to GitHub Pages
```

**解决方案:**
1. 进入仓库设置 → Pages
2. 确保 "GitHub Actions" 被选为部署源
3. 检查仓库权限设置

#### 问题: 构建超时
```
Error: The operation timed out
```

**解决方案:**
在 `.github/workflows/deploy_pages.yml` 中添加:
```yaml
- name: Build Web
  run: flutter build web --release
  timeout-minutes: 10
```

### 3. 部署后页面空白

#### 问题: 404 错误
```
Failed to load resource: the server responded with a status of 404
```

**解决方案:**
1. 检查 `base href` 设置
2. 确保路径正确: `/repository-name/`

#### 问题: JavaScript 加载失败
```
Failed to load resource: flutter.js
```

**解决方案:**
1. 检查构建输出是否包含 `flutter.js`
2. 验证文件路径是否正确

### 4. 路由问题

#### 问题: 刷新页面 404
```
Cannot GET /some-route
```

**解决方案:**
在 GitHub Pages 根目录添加 `.htaccess` 或使用 Hash Router

## 本地调试步骤

### 1. 本地构建测试
```bash
cd /Users/kevin/git/aa
./tools/build_web.sh
```

### 2. 本地服务器测试
```bash
cd build/web
python3 -m http.server 8000
# 访问 http://localhost:8000
```

### 3. 检查构建文件
```bash
ls -la build/web/
cat build/web/index.html
```

## 部署检查清单

### ✅ 预部署检查
- [ ] Flutter SDK 已安装且版本正确
- [ ] `flutter config --enable-web` 已执行
- [ ] 本地构建成功
- [ ] 测试通过
- [ ] GitHub Actions 权限正确

### ✅ 构建输出检查
- [ ] `build/web/index.html` 存在
- [ ] `build/web/flutter.js` 存在
- [ ] `build/web/main.dart.js` 存在
- [ ] `build/web/assets/` 目录存在
- [ ] `base href` 设置正确

### ✅ GitHub 配置检查
- [ ] GitHub Pages 已启用
- [ ] 部署源设置为 "GitHub Actions"
- [ ] 工作流权限正确
- [ ] 分支保护设置正确

## 高级故障排除

### 1. 清理和重建
```bash
flutter clean
rm -rf build/
flutter pub get
flutter build web --release
```

### 2. 检查 Flutter 版本
```bash
flutter --version
flutter doctor
```

### 3. 网络问题
```bash
export PUB_HOSTED_URL=https://pub.flutter-io.cn
export FLUTTER_STORAGE_BASE_URL=https://storage.flutter-io.cn
flutter pub get
```

### 4. 缓存问题
```bash
flutter pub cache repair
rm -rf ~/.pub-cache/hosted/pub.dartlang.org/*
```

## 监控和日志

### GitHub Actions 日志
1. 进入仓库 → Actions
2. 点击失败的构建
3. 查看详细错误信息
4. 检查构建步骤输出

### 浏览器控制台
1. F12 打开开发者工具
2. 查看 Console 标签
3. 检查 Network 标签
4. 查看错误信息和请求状态

## 联系支持

如果问题仍然存在，请提供以下信息：
1. Flutter 版本: `flutter --version`
2. 错误信息截图
3. GitHub Actions 日志
4. 浏览器控制台错误
5. 构建文件列表

## 快速修复命令

```bash
# 完全重置项目
flutter clean
flutter pub cache repair
flutter config --enable-web
flutter pub get
flutter build web --release --web-renderer canvaskit

# 检查结果
ls -la build/web/
python3 -m http.server 8000
```

记住：大多数问题都是由于路径配置、权限设置或构建配置不正确导致的。

# Vercel 部署指南

## 方法 1: Vercel CLI

```bash
npm i -g vercel
vercel login
cd aa
vercel
```

## 方法 2: GitHub 集成

1. 将代码推送到 GitHub
2. 在 Vercel 官网 import GitHub 仓库
3. 配置:
   - Build Command: `flutter build web --release`
   - Output Directory: `build/web`
   - Install Command: `flutter pub get`

## 本地构建后部署

```bash
flutter build web --release
# 将 build/web 目录内容部署到 Vercel
```

## 注意事项

- 需要 Flutter 环境，Vercel 会自动安装
- 或者本地构建后直接上传 build/web

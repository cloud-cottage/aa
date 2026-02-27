# Railway 部署指南

## 快速部署

1. 访问 https://railway.app
2. 使用 GitHub 登录
3. 点击 "New Project" → "Deploy from GitHub repo"
4. 选择 `cloud-cottage/aa` 仓库
5. 配置:
   - Builder: Flutter
   - Install: `flutter pub get`
   - Output: `build/web`

## 环境变量

如需设置:
- `FLUTTER_VERSION`: 指定 Flutter 版本

## 部署后

Railway 会自动分配一个 URL，如:
`https://your-project-name.up.railway.app`

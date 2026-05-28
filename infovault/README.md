# 信息保险箱 (InfoVault)

个人信息安全保险箱 — Flutter Android + Windows 双端应用，v1.2.1（Windows Fluent UI + MSIX 打包）

## 快速开始

```bash
# 设置环境 (每次新终端)
export PUB_HOSTED_URL=https://pub.flutter-io.cn
export FLUTTER_STORAGE_BASE_URL=https://storage.flutter-io.cn
export PUB_CACHE=H:/MyPasswords/pub_cache

# 安装依赖
flutter pub get

# 运行测试
flutter test

# 集成测试 (需要模拟器运行中)
flutter emulators --launch flutter_test
flutter test integration_test/app_test.dart -d emulator-5554

# 构建 Debug APK
flutter build apk --debug
```

## 测试: 142 tests, 0 failures

| 层级 | 数量 | 说明 |
|------|------|------|
| 单元测试 | services + models + validators |
| Widget 测试 | LockScreen, CreatePasswordScreen, SettingsScreen |
| Golden 截图 | TypeIcon, TypeFilterBar, LockScreen, CreatePasswordScreen |

详见 [TESTING.md](TESTING.md)

## 技术栈

- Flutter 3.38.6 / Dart 3.10.7 / Provider 状态管理
- SQLite + Flutter Secure Storage 本地存储
- AES-256-GCM + PBKDF2 加密 (encrypt + pointycastle)
- flutter_svg SVG 品牌图标 / image_picker 照片附件
- Material Design 3 + 手工蓝色板

## 项目结构

```
lib/
├── app.dart            # 入口 + 路由 (Consumer 切换创建密码/锁屏/主界面)
├── models/             # VaultItem, ItemType, Folder
├── screens/            # Lock, CreatePwd, Vault, Search, AddEdit, Settings
├── services/           # Auth, Encryption, Database, Vault, Clipboard, Photo, ExportImport
├── widgets/            # PlatformIcon, TypeIcon, QuickFillChips, TypeFilterBar 等
├── theme/              # AppTheme (浅色/深色 + overlayStyle)
└── utils/              # Constants, Validators, BrandIcons
```

## 关键文件

| 文件 | 说明 |
|------|------|
| [TESTING.md](TESTING.md) | 测试文档 |
| [integration_test/app_test.dart](integration_test/app_test.dart) | 集成测试 |
| [lib/screens/lock_screen.dart](lib/screens/lock_screen.dart) | 锁屏 (已修复 dispose bug) |
| [lib/services/encryption_service.dart](lib/services/encryption_service.dart) | 加密服务 (已修复 PBKDF2 注册表) |

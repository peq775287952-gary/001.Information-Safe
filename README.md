# 001.Information-Safe
## Information Safe - 信息保险箱

<div align="center">

![Logo](icon.png)

**个人信息安全保险箱** | Android + Windows 双端支持

[![Flutter](https://img.shields.io/badge/Flutter-3.38.6-blue.svg)](https://flutter.dev/)
[![Dart](https://img.shields.io/badge/Dart-3.7.0-green.svg)](https://dart.dev/)
[![SQLite](https://img.shields.io/badge/SQLite-2.4.2-orange.svg)](https://www.sqlite.org/)
[![Tests](https://img.shields.io/badge/Tests-144_passed-brightgreen.svg)]()
[![Version](https://img.shields.io/badge/Version-1.0.5-purple.svg)](https://github.com/peq775287952-gary/001.Information-Safe)

</div>

---

## 📖 项目简介

Information Safe 是一个现代化的个人信息保险箱应用，专为安全存储和管理用户的密码、银行卡、证件及敏感笔记而设计。采用端到端加密技术，确保您的个人数据安全无虞。

### 🎯 核心特性

- 🔐 **军用级加密**: AES-256-GCM + PBKDF2 密钥派生
- 🚀 **双端支持**: Flutter 一套代码，Android + Windows 双端运行
- 🎨 **现代UI**: Material Design 3 + 自定义设计系统
- 📱 **生物识别**: 指纹/人脸识别快速解锁
- 🗂️ **智能分类**: 自动识别平台分类，支持自定义文件夹
- 🔍 **快速搜索**: 实时搜索，多字段匹配
- 📸 **附件管理**: 支持照片加密存储
- ⚡ **自动锁定**: 后台超时自动锁定，防止数据泄露

---

## 🏗️ 技术架构

### 技术栈

```yaml
前端框架: Flutter 3.38.6
编程语言: Dart 3.7.0
状态管理: Provider
本地存储: SQLite + Flutter Secure Storage
加密引擎: encrypt + crypto
生物识别: local_auth
图片处理: image_picker
国际化: flutter_localizations
```

### 核心服务架构

```
┌─────────────────┐    ┌─────────────────┐    ┌─────────────────┐
│   AuthService   │    │  EncryptionService│    │ DatabaseService  │
│   - 主密码管理   │    │  - AES-256-GCM  │    │  - SQLite 数据库 │
│   - 生物识别     │    │  - PBKDF2 密钥   │    │  - 数据加密存储  │
│   - 锁定状态     │    │  - 安全存储     │    │  - 索引优化     │
└─────────────────┘    └─────────────────┘    └─────────────────┘
         │                       │                       │
         └───────────────────────┼───────────────────────┘
                                 │
                    ┌─────────────────┐
                    │  VaultService  │
                    │  - 数据管理     │
                    │  - 文件夹操作   │
                    │  - 搜索功能     │
                    └─────────────────┘
```

---

## 🚀 快速开始

### 环境要求

- Flutter SDK 3.7.0+
- Android Studio / VS Code
- Android SDK (Android开发)
- Windows SDK (Windows开发)

### 安装步骤

1. **克隆项目**
   ```bash
   git clone https://github.com/yourusername/infovault.git
   cd infovault
   ```

2. **安装依赖**
   ```bash
   flutter pub get
   ```

3. **配置图标** (可选)
   ```bash
   flutter pub run flutter_launcher_icons:main
   ```

4. **构建应用**
   ```bash
   # Android
   flutter build apk --release
   
   # Windows
   flutter build windows --release
   ```

5. **运行应用**
   ```bash
   # Android
   flutter run
   
   # Windows
   flutter run -d windows
   ```

---

## 💡 使用指南

### 首次使用

1. **创建主密码**
   - 首次打开应用时需要设置主密码
   - 建议使用强密码（12位以上，包含大小写字母、数字、特殊字符）
   - 主密码忘记后无法恢复，请务必牢记

2. **设置生物识别**
   - 支持指纹/人脸识别快速解锁
   - 可在设置中启用/禁用

### 主要功能

#### 📋 信息管理

支持四种信息类型：

| 类型 | 字段 | 照片支持 | 安全等级 |
|------|------|----------|----------|
| 🔑 **登录密码** | 平台名、用户名、密码、邮箱、手机号、网址、备注 | ❌ | 基础/加强 |
| 💳 **银行卡** | 银行名称、卡号、持卡人、有效期、CVV、取款密码、备注 | ✅ (最多3张) | 基础/加强 |
| 🪪 **证件** | 证件类型、证件号、姓名、签发机关、有效期、备注 | ✅ (最多3张) | 基础/加强 |
| 📝 **安全笔记** | 标题、自由文本 | ❌ | 基础/加强 |

#### 🔍 搜索功能

- **实时搜索**: 主界面顶部搜索栏实时筛选
- **多字段搜索**: 支持搜索平台名、用户名、邮箱、手机号、卡号、证件号、备注
- **搜索页面**: 独立的全屏搜索界面，结果按类型分组

#### 🗂️ 文件夹管理

- **智能分类**: 根据平台名或网址自动推荐分类
- **自定义文件夹**: 创建个性化文件夹组织信息
- **灵活筛选**: 按文件夹快速筛选查看

#### 🔒 安全设置

- **安全等级**: 
  - 基础: 解锁App后可直接查看/复制
  - 加强: 每次查看密码或复制时需二次验证
- **自动锁定**: 后台超时自动锁定（可设置时间）
- **失败锁定**: 连续错误多次后临时锁定
- **剪贴板保护**: 复制后60秒自动清空

---

## 🔐 安全原理

### 加密机制

```
用户输入主密码
    ↓
PBKDF2-HMAC-SHA256 (100,000+ 次迭代)
    ↓
生成 256-bit 加密密钥
    ↓
AES-256-GCM 加密数据
    ↓
存储到本地 SQLite 数据库
```

### 安全特性

1. **密钥派生**: 使用 PBKDF2 算法进行100,000+次迭代，防止暴力破解
2. **随机盐值**: 每个用户使用唯一的随机盐值
3. **AES-256-GCM**: 业界最安全的加密算法之一
4. **内存安全**: 加密密钥仅在内存中存在，不落盘存储
5. **生物识别**: 使用设备原生生物识别功能

### 数据保护

- **端到端加密**: 数据在设备端完成加密，服务器无法获取明文
- **本地存储**: 所有数据仅存储在用户设备上
- **自动清理**: 复制内容自动清理，防止泄露
- **锁定保护**: 应用锁定时数据完全不可访问

---

## 📱 界面预览

### 主要界面

1. **主界面** (`VaultScreen`)
   - 搜索栏 + 类型筛选 + 文件夹筛选
   - 信息列表展示
   - 底部导航栏

2. **搜索界面** (`SearchScreen`)
   - 全屏搜索
   - 结果分组显示
   - 实时搜索反馈

3. **设置界面** (`SettingsScreen`)
   - 安全设置
   - 文件夹管理
   - 导入导出
   - 关于信息

### 特色设计

- **自适应主题**: 自动跟随系统浅色/深色模式
- **响应式布局**: 适配不同屏幕尺寸
- **流畅动画**: 页面转场和交互动画
- **图标映射**: 45+ 平台品牌图标自动识别

---

## 🛠️ 开发指南

### 测试

项目包含 **144 个测试** (0 failures)，分三层：
- 单元测试 (130) + Widget 测试 (13) + 集成测试 (1，含 9 张自动截图)

详见 [TESTING.md](infovault/TESTING.md) 获取完整测试文档和快速命令。

### 项目结构

```
infovault/
├── lib/
│   ├── models/          # 数据模型
│   │   ├── vault_item.dart
│   │   ├── item_type.dart
│   │   ├── folder.dart
│   │   └── security_level.dart
│   ├── screens/         # 页面组件
│   │   ├── vault_screen.dart
│   │   ├── search_screen.dart
│   │   ├── settings_screen.dart
│   │   ├── add_edit_item_screen.dart
│   │   └── ...
│   ├── services/        # 核心服务
│   │   ├── auth_service.dart
│   │   ├── encryption_service.dart
│   │   ├── database_service.dart
│   │   ├── vault_service.dart
│   │   └── ...
│   ├── widgets/         # 可复用组件
│   ├── theme/           # 主题配置
│   ├── utils/           # 工具函数
│   └── app.dart         # 应用入口
├── test/               # 测试文件
├── android/            # Android 原生配置
├── windows/            # Windows 原生配置
└── pubspec.yaml        # 项目配置
```

### 核心服务说明

#### AuthService (认证服务)
- 管理主密码和生物识别
- 处理解锁状态和锁定逻辑
- 控制访问权限

#### EncryptionService (加密服务)
- 提供加密/解密功能
- 密钥派生和管理
- 安全存储密钥

#### DatabaseService (数据库服务)
- SQLite 数据库操作
- 数据持久化
- 查询和索引优化

#### VaultService (保险箱服务)
- 数据业务逻辑
- 文件夹管理
- 搜索功能

---

## 📊 版本信息

### 当前版本: v1.0.4

#### 版本历程

| 版本 | 主要更新 |
|------|----------|
| v1.0.0 | 初始版本，基础功能完整 |
| v1.0.1 | UI 重设计，一键填入功能 |
| v1.0.2 | Bug 修复，深色模式优化 |
| v1.0.3 | 入口验证，搜索优化，剪贴板服务 |
| v1.0.4 | 应用品牌化，图标映射，作者署名 |

### 开发路线

| 阶段 | 状态 | 目标 |
|------|------|------|
| Phase 1: Android 本地版 | ✅ 完成 | 手机端完整可用 |
| Phase 2: Windows 桌面版 | 🚧 进行中 | 电脑端完整可用 |
| Phase 3: 双端扫码同步 | 📋 待规划 | 二维码加密传输 |
| Phase 4: 云端加密储存 | 📋 待规划 | 多设备自动同步 |

---

## 🤝 贡献指南

我们欢迎社区贡献！请遵循以下步骤：

1. **Fork 项目**
2. **创建功能分支** (`git checkout -b feature/AmazingFeature`)
3. **提交更改** (`git commit -m 'Add some AmazingFeature'`)
4. **推送分支** (`git push origin feature/AmazingFeature`)
5. **创建 Pull Request**

### 开发规范

- 遵循 Dart/Flutter 官方代码规范
- 编写单元测试
- 更新相关文档
- 确保 `flutter analyze` 通过

---

## 📄 许可证

本项目采用 MIT 许可证 - 查看 [LICENSE](LICENSE) 文件了解详情。

---

## 🙏 致谢

- [Flutter](https://flutter.dev/) - 跨平台UI框架
- [SQLite](https://www.sqlite.org/) - 轻量级数据库
- [encrypt](https://pub.dev/packages/encrypt) - 加密库
- [Material Design](https://m3.material.io/) - 设计语言

---

## 📞 联系方式

- **作者**: Gary seven
- **邮箱**: peq775287952@163.com
- **GitHub**: [peq775287952-gary](https://github.com/peq775287952-gary)
- **项目地址**: [https://github.com/peq775287952-gary/001.Information-Safe](https://github.com/peq775287952-gary/001.Information-Safe)

---

<div align="center">

**⭐ 如果这个项目对您有帮助，请考虑给我们一个 Star！**

</div>
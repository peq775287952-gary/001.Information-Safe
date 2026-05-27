# 信息保险箱 (InfoVault) — 通用 AI 协议

> 本文件为所有 AI 助手的通用协议。Claude Code 专属配置见 [CLAUDE.md](CLAUDE.md)。

---

## 项目信息

- **名称**: 信息保险箱 (InfoVault)
- **类型**: Flutter 跨平台应用 (Android + Windows)
- **语言**: Dart 3.10.7 + Python 脚本
- **框架**: Flutter 3.38.6 + Provider
- **当前版本**: v1.1.9 (参见 [CHANGELOG.md](infovault/CHANGELOG.md))
- **测试**: 142 tests, 0 failures

---

## 开发流程

### 1. 会话启动读取顺序

每次开发会话开始时，按以下顺序读取文件：

| 顺序 | 文件 | 用途 |
|------|------|------|
| 1 | CLAUDE.md / AGENTS.md | 规则与配置 |
| 2 | docs/project/progress.md | 当前状态、断点续接 |
| 3 | docs/project/task_plan.md | 开发路线图 |
| 4 | CHANGELOG.md | 最近变更 |
| 5 | docs/project/findings.md | 技术决策、踩坑记录 |

### 2. 代码修改后必须更新文档

每次代码修改完成后，立即更新以下文档（不得遗漏）：

| # | 文件 | 记录内容 |
|---|------|----------|
| 1 | README.md | 版本 badge、功能列表 |
| 2 | CHANGELOG.md | 版本号 + 日期 + 变更摘要 |
| 3 | docs/project/progress.md | Session 记录、5-Question 断点续接 |
| 4 | docs/project/findings.md | 技术决策、Bug 修复、踩坑记录 |
| 5 | docs/project/task_plan.md | 当前版本、已完成/待完成 |
| 6 | AGENTS.md | 版本号、测试数 |
| 7 | CLAUDE.md | 版本号 |

### 3. 断点续接

AI 每次开发完成后自动更新 `docs/project/progress.md`，包含 5 个关键问题：

| 问题 | 说明 |
|------|------|
| 在哪？ | 当前版本、测试状态 |
| 去哪？ | 下一步计划 |
| 目标？ | 项目最终目标 |
| 学到什么？ | 技术发现、踩坑经验 |
| 做了什么？ | 本次会话改动 |

---

## 构建规则

### 版本号

- **每次构建必须递增版本号**（patch + build number）
- 版本号格式: `X.Y.Z+N`（界面显示 `X.Y.Z`，不显示 `+N`）

### APK 构建

- **默认构建分包**: `flutter build apk --release --split-per-abi`
- **不构建通用包**（除非用户明确要求）
- **构建目录不删除旧包**，只重命名新包为 `InfoVault-v{版本}-{架构}.apk`
- 通用包仅在用户明确要求时构建: `flutter build apk --release`

### 构建产物命名

```
InfoVault-v1.1.9-armeabi-v7a.apk   (32位ARM, ~17MB)
InfoVault-v1.1.9-arm64-v8a.apk     (64位ARM, ~19MB, 主流手机)
InfoVault-v1.1.9-x86_64.apk        (x86, ~20MB, 模拟器)
```

---

## 测试规则

- **142 测试必须全部通过** — `flutter test` 0 failures
- 构建前必须先通过全部测试
- 修改代码后自动运行 `flutter analyze` 和 `flutter test`

---

## 开发规范

- 所有新文件、类名、变量名、目录结构自动沿用项目现有规范
- Flutter/Dart 代码风格与现有代码一致
- 文件路径遵循项目既有约定

---

## 环境变量（每次新终端必须设置）

```bash
export PUB_HOSTED_URL=https://pub.flutter-io.cn
export FLUTTER_STORAGE_BASE_URL=https://storage.flutter-io.cn
export PUB_CACHE=H:/MyPasswords/pub_cache
export ANDROID_HOME=D:/DEVcode/android/sdk
export ANDROID_AVD_HOME=D:/DEVcode/android/avd
export JAVA_HOME=D:/java
```

---

## 常用命令

```bash
# 测试
cd infovault && flutter test                         # 142 tests
cd infovault && flutter analyze lib/ test/           # 静态分析

# 构建
cd infovault && flutter build apk --release --split-per-abi   # Android 分包
cd infovault && flutter build windows --release               # Windows

# 模拟器
flutter emulators --launch flutter_test              # 启动 Pixel 6 API 35
flutter run -d emulator-5554                         # 运行到模拟器
```

---

## 项目结构

```
h:\MyPasswords\
├── infovault/          ← Flutter 项目
│   ├── lib/            ← Dart 源码
│   │   ├── models/     ← VaultItem, ItemType, Folder
│   │   ├── screens/    ← Lock, CreatePwd, Vault, Search, AddEdit, Settings, FolderMgmt
│   │   ├── services/   ← Auth, Encryption, Database, Vault, Clipboard, Photo, ExportImport
│   │   ├── widgets/    ← PlatformIcon, TypeFilterBar, FolderFilterBar, QuickFillChips 等
│   │   ├── theme/      ← AppTheme (手工色板 + overlayStyle)
│   │   └── utils/      ← Constants, Validators, BrandIcons (SVG 映射)
│   ├── test/           ← 142 tests (unit + widget + golden)
│   ├── scripts/        ← bump_version.dart 等构建脚本
│   └── build/          ← APK 输出目录（旧包保留，只重命名新包）
├── docs/
│   ├── project/        ← 项目文档 (progress.md, findings.md, task_plan.md)
│   └── superpowers/    ← 规划文档 + archive/
├── AGENTS.md           ← 本文件（通用 AI 协议）
└── CLAUDE.md           ← Claude Code 专属配置
```

---

## 需求变更记录

当开发过程中需求发生变更，在 `docs/project/task_plan.md` 中追加备注：

```
> **YYYY-MM-DD 变更**: <描述>
```

---

> 模板版本: v1.1 | 协议: auto-doc-update

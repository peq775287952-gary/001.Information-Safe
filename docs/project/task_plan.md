# Task Plan: 信息保险箱 (InfoVault)

## Goal
开发"信息保险箱"——Flutter 跨平台个人信息保险箱，Android + Windows 双端。

## 产品定位（来源：产品设计文档 2026-05-24）
"信息保险箱"是一个**个人信息保险箱**，用于安全储存和管理用户的密码、银行卡、证件及敏感笔记。Android + Windows 双端。

### 四阶段路线图

| 阶段 | 内容 | 目标 | 状态 |
|------|------|------|------|
| Phase 1 | Android 本地版 | 手机端完整可用 | ✅ 完成 (v1.1.9) |
| Phase 2 | Windows 本地版 | 电脑端完整可用 | ✅ 基础完成（生物识别已移除 v1.1.4） |
| Phase 3 | 双端扫码同步 | 二维码加密传输，局域网互通 | 📋 待规划 |
| Phase 4 | 云端加密储存 | 数据上云，多设备自动同步 | 📋 待规划 |

每阶段完成后即可投入使用，不需要等全部做完。

### 明确不做的功能（第一版）
- 密码生成器
- 在线账号注册/登录
- 与他人分享密码
- 浏览器插件/自动填充

## Current Phase
Phase 2: Windows 桌面版 ✅（v1.2.1 — Fluent UI 完全体 + Bug 修复 + MSIX 打包 + 142 测试全通过）

## 当前版本：v1.2.1+20

### 已完成
- 28+ Dart 源文件 + 142 tests (0 failures)
- 五种保险箱类型（密码/银行卡/证件/笔记/API Key）
- 主密码 + 修改主密码（随时更换，自动重加密全部数据）+ 自动锁定开关（默认 3 分钟，可关闭）
- 密码最短 4 位
- 智能分类 + 自定义文件夹
- 全字段搜索（结果按类型分组）
- SVG 品牌图标（16 AI + 8 银行 + 5 证件）
- 一键填入标签（品牌分组快捷填入）
- 剪贴板 60s 自动清空
- 切后台自动锁定（时间可调）
- Android 边缘到边缘导航栏适配
- 深色/浅色自适应（手工蓝色板）
- UI 现代化：4px 网格、圆角分级、SVG 图标、列表渐入动画
- 中文本地化
- 自定义应用图标 + 应用名"信息保险箱"
- 版本号系统：界面 X.Y.Z，构建自动递增
- **Windows 桌面版**: sqflite FFI + 构建脚本
- **MSIX 打包**: 支持生成 .msix 安装包，自签名证书可分发

## Phases

### Phase 0: 需求设计 ✅
### Phase 1: Android 本地版 ✅ (v1.1.3)
### Phase 2: Windows 本地版 ✅ (v1.1.4)
- Windows 桌面适配 + sqflite FFI
### Phase 3: 扫码同步 ⏸
### Phase 4: 云端加密 ⏸

## 开发环境

| 工具 | 路径 | 版本 |
|------|------|------|
| Flutter | D:\DEVcode\flutter | 3.38.6 |
| Android SDK | D:\DEVcode\android\sdk | platforms 34/35/36 |
| Gradle | D:\DEVcode\.gradle | 8.14 |
| Pub Cache | H:\MyPasswords\pub_cache | (同盘，避免 Kotlin 跨盘符编译错误) |
| Java | D:\java | 21.0.7 |
| 项目 | h:\MyPasswords\infovault | - |
| 模拟器 AVD | D:\DEVcode\android\avd\flutter_test.avd | Pixel 6, API 35 |

## 环境变量

**每次新终端必须设置：**
```bash
export PUB_HOSTED_URL=https://pub.flutter-io.cn
export FLUTTER_STORAGE_BASE_URL=https://storage.flutter-io.cn
export PUB_CACHE=H:/MyPasswords/pub_cache
export ANDROID_HOME=D:/DEVcode/android/sdk
export ANDROID_AVD_HOME=D:/DEVcode/android/avd
export JAVA_HOME=D:/java
```

## 构建命令

```bash
# 模拟器启动
flutter emulators --launch flutter_test

# 构建 Release APK (每次构建自动递增版本号)
dart run scripts/bump_version.dart && flutter build apk --release --no-android-gradle-daemon

# 一键构建 (build.bat)
cmd /c build.bat

# 运行到模拟器
flutter run -d emulator-5554
```

## 测试命令

```bash
# 单元 + Widget 测试
flutter test

# 单元 + Widget (更新 Golden 基线)
flutter test --update-goldens

# 集成测试 (需要模拟器运行中)
flutter test integration_test/app_test.dart -d emulator-5554

# 拉取集成测试截图
export MSYS_NO_PATHCONV=1
adb -s emulator-5554 pull /sdcard/Pictures/Screenshots/ integration_test/screenshots/
```

## 文档索引

| 文件 | 说明 |
|------|------|
| [AGENTS.md](AGENTS.md) | **AI 协议** — 通用文档自动更新协议 (auto-doc-update) |
| [CLAUDE.md](CLAUDE.md) | **Claude Code 配置** — 项目专属规则和命令 |
| [TESTING.md](infovault/TESTING.md) | **测试文档** — 快速命令、架构、截图、修复记录 |
| [findings.md](findings.md) | 研究发现 — 技术决策、踩坑记录、Bug 修复、UI 设计系统 |
| [progress.md](progress.md) | 进度日志 — 完整开发时间线 |
| [AGENTS.md](../../AGENTS.md) | **AI 协议** — 通用文档自动更新协议 |
| [CLAUDE.md](../../CLAUDE.md) | **Claude Code 配置** |
| [TESTING.md](../../infovault/TESTING.md) | **测试文档** |
| [../superpowers/plans/2026-05-26-infovault-phase2-windows.md](../superpowers/plans/2026-05-26-infovault-phase2-windows.md) | Phase 2 Windows 计划（含状态注记） |
| [../superpowers/archive/](../superpowers/archive/) | 已归档：Phase 1 计划、产品设计、UI 优化方案、UI 重设计章程 |

## 关键注意事项

1. **PUB_CACHE 必须在 H: 盘** — 项目在 H: 盘，PUB_CACHE 在 D: 盘会导致 Kotlin 跨盘符增量编译失败
2. **国内镜像必须设置** — `flutter-io.cn` 镜像，腾讯云 Maven (阿里云已全部 404 下线)
3. **MSYS_NO_PATHCONV=1** — Windows bash 下 adb pull 路径必须加此参数，否则路径会被转换为本地 git 路径
4. **集成测试 enterText** — 必须用 `tester.testTextInput.enterText()` 而非 `tester.enterText()`
5. **集成测试截图** — `convertFlutterSurfaceToImage()` 仅调一次，后续 `takeScreenshot()` 返回 `List<int>` PNG bytes

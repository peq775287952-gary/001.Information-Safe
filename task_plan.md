# Task Plan: 信息保险箱 (InfoVault)

## Goal
开发"信息保险箱"——Flutter 跨平台个人信息保险箱，Android + Windows 双端。

## Current Phase
Phase 1: Android 本地版（v1.1.2 — 功能完整 + 138 测试全通过）

## 当前版本：v1.1.2+11

### 已完成
- 28+ Dart 源文件 + 138 tests (0 failures)
- 五种保险箱类型（密码/银行卡/证件/笔记/API Key）
- 主密码 + 自动锁定开关（默认 3 分钟，可关闭）
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

## Phases

### Phase 0: 需求设计 ✅
### Phase 1: Android 本地版 ✅ (v1.1.2)
### Phase 2: Windows 本地版 ⏸
- Windows 桌面适配 + Windows Hello
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
| [TESTING.md](infovault/TESTING.md) | **测试文档** — 快速命令、架构、截图、修复记录 |
| [findings.md](findings.md) | 研究发现 — 技术决策、踩坑记录、Bug 修复 |
| [progress.md](progress.md) | 进度日志 — 完整开发时间线 |
| docs/superpowers/specs/2026-05-24-ipassword-design.md | 产品设计 |
| docs/superpowers/plans/2026-05-24-infovault-phase1.md | 实现计划 |
| docs/superpowers/specs/2026-05-24-ui-redesign-charter.md | UI 重设计章程 |
| docs/superpowers/specs/2026-05-24-ui-optimization-plan.md | UI 优化方案 |

## 关键注意事项

1. **PUB_CACHE 必须在 H: 盘** — 项目在 H: 盘，PUB_CACHE 在 D: 盘会导致 Kotlin 跨盘符增量编译失败
2. **国内镜像必须设置** — `flutter-io.cn` 镜像，腾讯云 Maven (阿里云已全部 404 下线)
3. **MSYS_NO_PATHCONV=1** — Windows bash 下 adb pull 路径必须加此参数，否则路径会被转换为本地 git 路径
4. **集成测试 enterText** — 必须用 `tester.testTextInput.enterText()` 而非 `tester.enterText()`
5. **集成测试截图** — `convertFlutterSurfaceToImage()` 仅调一次，后续 `takeScreenshot()` 返回 `List<int>` PNG bytes

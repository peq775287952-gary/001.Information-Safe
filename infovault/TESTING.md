# 信息保险箱 测试文档

> 更新时间: 2026-05-26
> 测试总计: 144 tests (130 单元 + 9 widget + 4 golden + 1 integration)

## 快速命令

```bash
# 环境变量 (每次新终端需要设置)
export PUB_HOSTED_URL=https://pub.flutter-io.cn
export FLUTTER_STORAGE_BASE_URL=https://storage.flutter-io.cn
export PUB_CACHE=H:/MyPasswords/pub_cache

# 单元 + Widget 测试
cd h:/MyPasswords/infovault && flutter test

# 更新 Golden 截图
flutter test --update-goldens

# 集成测试 (需要模拟器运行中)
cd h:/MyPasswords/infovault && flutter test integration_test/app_test.dart -d emulator-5554

# 启动模拟器
flutter emulators --launch flutter_test

# 拉取集成测试截图
export MSYS_NO_PATHCONV=1
adb -s emulator-5554 pull /sdcard/Pictures/Screenshots/ integration_test/screenshots/
```

## 测试架构 (3 层)

### A 层 — 单元测试 (`test/services/`, `test/models/`)
- **130 个测试**, 运行命令 `flutter test`
- 覆盖: validators(30), database(12), vault(30), encryption(13), export_import(4), auth(12), clipboard(5), models(18), app smoke(1)
- mock: `TestDefaultBinaryMessenger.setMockMethodCallHandler` 模拟 `flutter_secure_storage`

### B 层 — Widget + Golden 测试 (`test/screens/`, `test/goldens/`)
- **9 widget 测试**: LockScreen(3), CreatePasswordScreen(5), SettingsScreen(1)
- **4 golden 测试**: TypeIcon, TypeFilterBar, LockScreen, CreatePasswordScreen
- 物理尺寸: 390x844 @ 3.0x

### C 层 — 集成测试 (`integration_test/app_test.dart`)
- **1 个全流程测试**, 14 步覆盖: 创建密码 → 添加条目 → 查看详情 → 设置 → 锁定 → 解锁
- **9 张自动截图**, 存储在 `integration_test/screenshots/`
- 运行环境: Pixel 6, Android 15 (API 35), x86_64 模拟器

## 模拟器信息

| 项目 | 详情 |
|------|------|
| AVD 名称 | `flutter_test` |
| 设备 | Pixel 6, Android 15 (API 35), x86_64, Google APIs |
| 加速 | WHPX (Windows Hypervisor Platform) |
| AVD 路径 | `D:\DEVcode\android\avd\flutter_test.avd` |
| 启动命令 | `flutter emulators --launch flutter_test` |

## 环境配置

| 变量 | 值 | 说明 |
|------|-----|------|
| `ANDROID_HOME` | `D:\DEVcode\android\sdk` | Android SDK |
| `ANDROID_AVD_HOME` | `D:\DEVcode\android\avd` | AVD 目录 |
| `PUB_HOSTED_URL` | `https://pub.flutter-io.cn` | Dart 包国内镜像 |
| `FLUTTER_STORAGE_BASE_URL` | `https://storage.flutter-io.cn` | Flutter 引擎国内镜像 |
| `PUB_CACHE` | `H:\MyPasswords\pub_cache` | 包缓存 (必须在 H: 盘避免跨盘符 Kotlin 编译错误) |

## 已修复的问题

### 1. pointycastle PBKDF2 注册表缺失 (`encryption_service.dart`)
- **问题**: `KeyDerivator('PBKDF2-HMAC-SHA256')` 在 pointycastle 全局注册表中未注册
- **修复**: 直接实例化 `PBKDF2KeyDerivator(HMac(SHA256Digest(), 64))`

### 2. 跨盘符 Kotlin 增量编译错误 (`gradle.properties`)
- **问题**: `PUB_CACHE` 在 D: 盘, 项目在 H: 盘, Kotlin 无法处理不同根路径
- **修复**: 设置 `PUB_CACHE=H:\MyPasswords\pub_cache` 同盘存储

### 3. LockScreen setState after dispose (`lock_screen.dart:65`)
- **问题**: `verifyMasterPassword()` 成功时 `notifyListeners()` 触发 Consumer 重建替换 LockScreen, 但 `_unlock()` 中后续 `setState(() => _isChecking = false)` 在已销毁的 widget 上调用
- **修复**: `verifyMasterPassword` 后添加 `if (!mounted) return;`

### 4. 集成测试 enterText 不生效
- **问题**: `tester.enterText()` 在集成测试模式 (真实设备) 中无法正确触发 TextFormField 文本输入
- **修复**: 使用 `tester.tap(field)` + `tester.testTextInput.enterText()` 组合

### 5. 集成测试 takeScreenshot API
- **问题**: `takeScreenshot` 在 `IntegrationTestWidgetsFlutterBinding.instance` 上, 非 `WidgetTester`
- **修复**: Android 需先调用 `convertFlutterSurfaceToImage()` 一次, 然后多次 `binding.takeScreenshot(name)` 返回 `List<int>` PNG 字节

### 6. DatabaseService 测试隔离
- **问题**: 测试共享 database 文件导致 SQLite 锁冲突
- **修复**: `DatabaseService({String? dbName})` 可选参数让测试用独立数据库

## 测试截图清单

| 截图 | 界面 | 说明 |
|------|------|------|
| `01-create-password-screen.png` | 创建主密码 | 锁图标 + 标题 + 两个密码输入框 + 创建按钮 |
| `02-vault-empty.png` | 空保险箱 | AppBar + 搜索栏 + 类型筛选 + 空状态 + 导航栏 + FAB |
| `03-type-sheet.png` | 类型选择 | BottomSheet: 登录密码/银行卡/证件/安全笔记 |
| `04-add-item-form.png` | 添加条目 | 标题输入框 + 保存按钮 |
| `05-vault-with-item.png` | 条目列表 | TestAccount 条目出现 |
| `06-item-detail.png` | 条目详情 | 查看条目的详细页面 |
| `07-settings.png` | 设置页 | 自动锁定等设置项 |
| `08-lock-screen.png` | 锁定界面 | 锁图标 + 请输入主密码解锁 + 密码输入框 + 解锁按钮 |
| `09-unlocked-vault.png` | 解锁后保险箱 | 解锁后回到保险箱主界面 |

## 关键文件索引

| 文件 | 说明 |
|------|------|
| `lib/services/encryption_service.dart` | PBKDF2 密钥派生 + AES 加解密 |
| `lib/services/auth_service.dart` | 认证状态管理 (密码创建/验证/锁定) |
| `lib/services/vault_service.dart` | 条目管理 (增删改查) |
| `lib/services/database_service.dart` | SQLite 数据库服务 |
| `lib/app.dart` | 应用入口 + Consumer 路由 (创建密码→锁屏→主界面) |
| `lib/screens/lock_screen.dart` | 锁屏界面 (已修复 dispose bug) |
| `test/services/*.dart` | 单元测试 (mock secure storage) |
| `test/screens/*.dart` | Widget 测试 |
| `integration_test/app_test.dart` | 集成测试 (真实设备全流程) |
| `android/app/src/debug/AndroidManifest.xml` | Debug 权限 (含截图存储权限) |

# 更新日志

## v1.1.7+16 (2026-05-27)

### 优化
- **解锁速度提升 10x**: PBKDF2 迭代次数 100,000→10,000 + `compute()` Isolate 隔离，UI 不再卡顿
- **深色模式全面适配**:
  - 文件夹筛选栏文字颜色自适应（brightness 检测）
  - Switch 开关组件深色模式配色（SwitchThemeData）
  - 深色图标（抖音/GitHub/Steam 等）深色模式自动提亮（luminance 检测）
- **搜索框键盘行为优化**: 改用 FocusNode + postFrameCallback，返回时不再自动弹出
- **文件夹选择改进**: 编辑页新增"无文件夹"选项，可清除已选文件夹

### 修复
- `lock_screen_test.dart` 适配 `compute()` Isolate 测试（使用 `runAsync` 等待异步）

### 测试
- 142 项测试全部通过

## v1.1.6+15 (2026-05-27)

### 优化
- **Android 包体积优化**: 启用 R8 代码压缩 + 资源缩减 + ABI 分包
  - armeabi-v7a: 16.5MB
  - arm64-v8a: 18.8MB
  - x86_64: 20.0MB
- **ProGuard 规则**: 添加 Google Play Core 库 keep 规则，修复 R8 编译失败

### 修复
- `create_password_screen.dart` 添加 try-catch 错误处理 + 加载状态

### 测试
- 142 项测试全部通过

## v1.1.4+13 (2026-05-27)

### 移除
- **生物识别功能完全移除**: 删除 `BiometricService`、`local_auth` 依赖、Windows Hello 集成
- 清理 `AuthService.authenticateWithBiometrics()` 及 `_biometricService` 字段
- 清理 `LockScreen` 指纹解锁按钮 UI
- 清理 `SettingsScreen` 生物识别开关 UI
- 清理 `constants.dart` 中 `biometricEnabledKey`
- 清理 3 个测试文件中的 `BiometricService` mock 和 Provider 注册
- 移除 `pubspec.yaml` 中 `local_auth: ^2.3.0` 依赖
- 更新 Windows 插件注册文件（移除 `local_auth_windows`）

## v1.2.0+13 (2026-05-26)

### 新增
- **Windows 桌面版支持**: sqflite FFI 数据库适配、平台条件初始化
- **平台工具函数**: `platform_utils.dart` — 数据库路径、平台检测
- **Windows 构建脚本**: `build_windows.bat`

### 变更
- `DatabaseService` 桌面端使用 `databaseFactoryFfi` 替代默认 sqflite
- `main.dart` 桌面端初始化 `sqfliteFfiInit()`
- Android `edge-to-edge` 条件化（仅 Android 启用，桌面端跳过）

### 依赖
- `sqflite_common_ffi: ^2.3.4+4` 从 dev 提升为正式依赖

## v1.1.3+12 (2026-05-26)

### 新增
- **修改主密码**: 设置→安全→修改主密码，验证旧密码后可随时更换
- 新密码校验：至少4位，不能与旧密码相同
- 修改后自动重加密全部数据，旧备份文件将无法导入（弹窗提醒）

### 变更
- 密码最短位数从 8 位改为 4 位

## v1.1.2+11 (2026-05-26)

### 修复
- 锁屏界面和创建密码界面导航栏适配（新增 `AppTheme.overlayStyle()` + `AnnotatedRegion`）
- 银行 SVG 图标白色底色导致不显示（删除 8 个 SVG 的 `fill="#FFFFFF"` 底色路径）
- 每次构建自动递增版本号（patch + build）

## v1.1.1+10 (2026-05-26)

### 新增
- AI API Key 类型 (ItemType.apiKey)，支持供应商名称、API Key(遮罩)、接口地址、模型名称、备注
- 自动锁定开关，用户可自行开启/关闭，默认 3 分钟
- 品牌 SVG 图标系统：37 个 SVG 图标 (16 AI + 8 银行 + 5 证件 + 8 备用)
- 版本号系统：界面仅显示 X.Y.Z，build number 自动递增
- `build.bat` 一键构建脚本

### 修复
- Android 边缘到边缘导航栏适配（系统小白条跟随 App 主题）
- app_theme.dart 缺失 `import 'package:flutter/services.dart'` 编译错误

### 移除
- 指纹认证代码 (local_auth 包、BiometricResult、lock_screen 指纹入口)
- 加强安全代码 (security_level.dart、secondary_auth_dialog.dart、SecurityLevel 枚举)
- AndroidManifest USE_BIOMETRIC 权限
- platform_icon.dart 中 25 条被 SVG 覆盖的死 _brands 条目
- database_service.dart 中 security_level 死列
- export_import_service.dart 硬编码版本号

### 依赖
- `flutter_svg: ^2.0.17` — SVG 品牌图标渲染
- `package_info_plus: ^8.1.0` — 运行时读取版本号

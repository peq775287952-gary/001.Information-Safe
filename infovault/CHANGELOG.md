# 更新日志

## v1.2.1+20 (2026-05-28) — Windows 端 Bug 修复 + MSIX 打包

### 修复 (Windows 端)
- **Esc 快捷键**: 使用 `KeyboardListener` 替代 `Shortcuts`，Fluent UI NavigationView 不再拦截
- **Ctrl+N 新建**: 主界面快捷键打开类型选择对话框
- **Ctrl+S 保存**: 编辑页快捷键保存条目
- **深色模式统一**: `AppTheme.darkBg` 从 `#0B1120`(深蓝) 改为 `#202020`(Windows标准黑灰)
- **导航栏背景**: 添加 `navigationPaneTheme` 配置，统一 `#202020`
- **建议标签深色模式**: `_buildSuggestionChip` 背景色深色适配
- **平台图标深色模式**: 深色图标(Steam/抖音/GitHub等)自动变白，亮度阈值提升至 0.5
- **文件夹标签**: `_ItemCard` 标题右侧显示文件夹名称标签
- **快捷填入滑动**: `ListView.separated` 改为 `SingleChildScrollView` + `Row`
- **平台图标显示**: `TypeIcon` 改为 `PlatformIcon`(品牌图标)
- **新建文件夹输入框**: `SizedBox(height: 36)` 限制高度
- **详情页返回按钮**: 添加 leading 返回按钮 + Esc 快捷键
- **编辑页返回按钮**: 添加 leading 返回按钮 + Esc 快捷键

### 新增
- **MSIX 打包支持**: `pubspec.yaml` 添加 `msix_config`，支持生成 `.msix` 安装包
- **自签名证书**: 自动生成测试证书，可分发给他人安装

### 构建
- Windows: v1.2.1+20 MSIX (18MB)
- Windows: v1.2.1+20 便携版

---

## v1.2.1+20 (2026-05-28)

### 变更
- **PBKDF2 统一 10K**: 所有端固定 10,000 次迭代（性能优先）
  - `verifyMasterPassword` 自动兼容 pre-v1.1.7(100K)/v1.2.0(600K) 用户
  - `_iterationsKey` 丢失时自动尝试 [10000, 100000] 候选
  - 验证通过后自动迁移到 10K + 新 salt + 重加密
- **API Key 加密**: `apiKey` 字段加入 AES-256-GCM 加密
- **定长哈希比较**: `_constantTimeEqual()` 防止 timing 侧信道攻击
- **Windows 自动锁定**: `MainShellWin` 添加 `WidgetsBindingObserver` + 后台定时锁
- **安全性修复**: `setState` after dispose 守卫、ItemDetail 空值保护、密码 trim 统一
- **Windows 相机选项**: 拍照按钮在 Windows 上隐藏（仅保留相册选择）
- **`config.json` 更新**: Filesystem MCP 白名单添加 `.claude` 目录
- **MCP 修复**: `Sequential Thinking` → `sequential-thinking`（空格导致加载失败）

### 构建
- Windows: v1.2.1+20 (59.6s)
- Android: arm64-v8a 20.7MB / armeabi-v7a 18.4MB / x86_64 22.0MB

---

## v1.2.0+19 (2026-05-28)

### 新增 (Phase B)
- **Windows Fluent UI 完整覆盖**: 剩余 4 个页面完成 Fluent 化
  - `add_edit_item_screen_win.dart` — 添加/编辑条目（5 种类型表单）
  - `item_detail_screen_win.dart` — 条目详情页（字段展示+照片）
  - `folder_management_screen_win.dart` — 文件夹管理
  - `change_password_screen_win.dart` — 修改主密码
- **所有 Windows 导航引用已更新** — 全部指向 _win 版，不再依赖 Material 页面
- **Windows 端零 Material 依赖**: 所有交互页面的 Fluent 组件替换完成

### 新增
- **Windows 亚克力/Mica 窗口效果**: 使用 `flutter_acrylic: ^1.1.4`
  - Windows 11: Mica 效果（桌面壁纸动态着色）
  - Windows 10: Acrylic 透明模糊效果
  - 自动降级：Mica 不可用时回退到 Acrylic
  - 深色/浅色模式联动

### 依赖
- `flutter_acrylic: ^1.1.4` — 窗口透明效果

### 新增
- **Windows Fluent UI 改造 (Phase A)**: Windows 端改用微软 Fluent Design 界面
  - 平台分流架构：Android 保持 MaterialApp，Windows 使用 FluentApp
  - NavigationView 侧边栏导航替代底部 NavigationBar
  - ContentDialog 替代 BottomSheet/AlertDialog
  - ToggleSwitch 替代 Material Switch
  - TextBox 替代 TextField
  - ScaffoldPage 替代 Scaffold
  - InfoBar 替代 SnackBar
  - RadioGroup + RadioButton 替代 SimpleDialog
  - Fluent 品牌色系统 #2563EB，亮/暗色主题
- 新增 7 个 Windows 专用界面文件
  - `app_windows.dart` — FluentApp 入口
  - `lib/theme/fluent_theme.dart` — Fluent 主题
  - `lib/screens/windows/lock_screen_win.dart` — 锁屏
  - `lib/screens/windows/create_password_screen_win.dart` — 创建密码
  - `lib/screens/windows/main_shell_win.dart` — 导航框架
  - `lib/screens/windows/vault_screen_win.dart` — 宽屏主页
  - `lib/screens/windows/search_screen_win.dart` — 搜索页
  - `lib/screens/windows/settings_screen_win.dart` — 设置页
  - `lib/screens/windows/add_item_dialog.dart` — 类型选择对话框
- `system_theme` 支持读取 Windows 系统主题色
- **Android 端零改动**
- 142 测试全部通过，0 analyze 错误

### 依赖
- `fluent_ui: ^4.15.1` — Fluent Design 组件库
- `system_theme: ^3.2.0` — 系统主题色读取

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

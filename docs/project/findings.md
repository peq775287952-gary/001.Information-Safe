# Findings — 信息保险箱

## 产品
- 五种类型：密码/银行卡/证件/笔记/API Key
- 主密码 + 修改主密码（随时更换，自动重加密）+ 智能分类 + 品牌 SVG 图标（16 AI + 8 银行）
- 剪贴板 60s 清空 + 可开关自动锁定（默认 3 分钟）
- Android 边缘到边缘导航栏适配 + Windows 桌面版支持
- 密码最短位数 4 位

## 技术决策
| Decision | Rationale |
|----------|-----------|
| Flutter 3.38.6 + Provider + sqflite | 跨平台轻量方案 |
| encrypt + pointycastle | AES-256-GCM + PBKDF2 |
| font_awesome_flutter | 品牌图标 (微信/支付宝/QQ等) |
| flutter_svg | SVG 品牌图标 (银行/AI/证件) |
| package_info_plus | 运行时读取版本号 |
| flutter_launcher_icons | 应用图标生成 |
| mock MethodChannel (非 mockito) | flutter_secure_storage 测试 mock |
| sqflite_common_ffi (非 sqflite) | Windows/Linux/macOS 桌面端 SQLite，通过 FFI 直接调用 |
| PBKDF2 迭代 10,000 次 + compute() Isolate | 本地应用安全够用，解锁 3s→0.3s，UI 不阻塞 |
| WidgetStateProperty + luminance 检测 | 深色模式下图标/Switch/Chip 自适应 |

## 镜像（2026-05-24 验证）
- ❌ 阿里云 Maven：全部 404 下线
- ✅ 腾讯云 Nexus：可用
- ✅ Google/Maven Central：直连可用
- ✅ flutter-io.cn：可用 (PUB_HOSTED_URL + FLUTTER_STORAGE_BASE_URL)

## 环境踩坑

### 中文用户名路径
- 路径含中文用户名 → 全部迁 D:\DEVcode

### Kotlin 跨盘增量缓存
- D: 盘 PUB_CACHE 与 H: 盘项目导致 Kotlin 跨盘符增量编译失败
- **修复**: 设置 `PUB_CACHE=H:\MyPasswords\pub_cache` (同盘)

### MSYS Bash 路径转换
- Windows bash 下 adb pull 会将 `/storage/...` 转换为 `D:/DEVcode/git/Git/storage/...`
- **修复**: 使用 `export MSYS_NO_PATHCONV=1`

### VS 2026 Build Tools 兼容性
- `atlstr.h` 需要安装 "C++ ATL for latest v143 build tools" 组件
- MSVC 14.51 弃用 `experimental/coroutine`，需添加 `_SILENCE_EXPERIMENTAL_COROUTINE_DEPRECATION_WARNINGS` 宏
- 中文源文件需 `/utf-8` 编译选项（MSVC 默认 GBK/CP936）
- **修复**: `windows/CMakeLists.txt` 添加 `add_compile_options(/utf-8)` 和协程压制宏
- NuGet 首次构建会自动下载（`Nuget.exe not found, trying to download or use cached version` 为正常提示）

### compute() Isolate 与 pumpAndSettle 冲突
- `pumpAndSettle` 等待所有帧稳定，但 `compute()` Isolate 的 Future 不会在帧循环中完成
- `pump(Duration)` 只推进假时钟，不等待真实异步
- **修复**: 使用 `tester.runAsync(() => Future.delayed(...))` 让真实异步完成，再 `pump()` + `pumpAndSettle()`

### showDialog 崩溃
- showDialog 在 addPostFrameCallback 崩溃 → 改导航前验证

### 集成测试 enterText
- `tester.enterText()` 在真实设备 (integration_test 模式) 中不生效
- **修复**: 使用 `tester.tap(field)` + `pumpAndSettle` + `tester.testTextInput.enterText()`

### 集成测试截图
- `takeScreenshot` 在 `IntegrationTestWidgetsFlutterBinding.instance` 上，非 `WidgetTester`
- Android 需先调用 `convertFlutterSurfaceToImage()` (仅一次)，后续多次 `takeScreenshot(name)` 返回 `List<int>` PNG bytes
- 截图存储必须使用公共目录 `/sdcard/Pictures/`，应用数据目录会在 tearDown 时随卸载删除
- Debug 构建需添加 `MANAGE_EXTERNAL_STORAGE` 权限才能写入公共目录

## UI 设计系统（来源：ui-redesign-charter 2026-05-24）

### 设计方向：静谧安全 (Quiet Security)
密码管理器的本质是**信任**。界面传达：安全、可靠、不张扬。
- 风格：精炼极简 + 微质感
- 色调：沉稳蓝灰 + 暖白 + 精密阴影
- 动效：克制微动效 (150-250ms)
- 字体：系统原生 (SF Pro / Roboto)
- 间距：4px 网格系统

### 手工色板（替代 Material 3 动态取色）

| 名称 | Hex | 用途 |
|------|-----|------|
| 品牌蓝 | #2563EB | 主按钮、选中态、强调 |
| 深蓝 | #1E40AF | 按钮按下态 |
| 浅蓝 | #EFF6FF | 选中背景、标签底色 |
| 安全绿 | #059669 | 密码字段遮罩色 |
| 警报红 | #DC2626 | 删除、加强安全标识 |
| 暖白 | #FAFAFA | 背景（浅色模式） |
| 卡片白 | #FFFFFF | 卡片表面 |
| 深色背景 | #0B1120 | 暗色模式背景 |
| 深色卡片 | #1E293B | 暗色模式卡片 |

### 类型专属色
| 类型 | Hex | 含义 |
|------|-----|------|
| 密码 | #3B82F6 (蓝) | 柔和、信任 |
| 银行卡 | #F59E0B (琥珀) | 温暖、贵重 |
| 证件 | #10B981 (翠绿) | 正式、官方 |
| 笔记 | #8B5CF6 (紫) | 私密、个人 |

### 4px 网格间距
| 级数 | 值 | 用途 |
|------|-----|------|
| xs | 4px | 图标与文字间距 |
| sm | 8px | 同类元素间距 |
| md | 12px | 卡片内边距 |
| base | 16px | 标准外边距 |
| lg | 20px | 模块间距 |
| xl | 24px | 大模块间距 |
| 2xl | 32px | 页面顶部/底部留白 |

### 圆角规范
| 元素 | 圆角 |
|------|------|
| 小标签/Chip | 6px |
| 按钮/输入框 | 10px |
| 卡片 | 12px |
| 底部弹窗 | 16px (仅顶部) |
| FAB | 16px (圆形) |

## 代码架构
```
lib/
├── models/   VaultItem, ItemType, Folder
├── services/ Encryption, Auth, Database, Vault, Clipboard, SmartCategory, Photo, ExportImport
├── screens/  Lock, CreatePwd, Vault, Search, AddEdit, Settings, FolderMgmt
├── widgets/  PlatformIcon, TypeIcon, QuickFillChips, StaggeredList,
│             FieldRow, ItemListTile, TypeFilterBar, FolderFilterBar
├── theme/    AppTheme (手工色板 + overlayStyle)
└── utils/    Constants, Validators, BrandIcons (SVG 映射，自动生成)
```

## 测试架构 (142 tests, 0 failures)
```
test/
├── services/  unit tests (auth, encryption, vault, database, export_import, clipboard)
├── screens/   widget tests (lock_screen, create_password_screen, settings_screen)
├── goldens/   golden tests (TypeIcon, TypeFilterBar, LockScreen, CreatePasswordScreen)
└── widget_test.dart  1 app smoke test
```

## Android 包体积优化 (v1.1.6)

### 优化措施
- **R8 代码压缩**: `isMinifyEnabled = true`
- **资源缩减**: `isShrinkResources = true`
- **ABI 分包**: `splits.abi` 按 CPU 架构拆分 APK
- **ProGuard 规则**: 保护加密库 (pointycastle/bouncycastle) + Google Play Core

### 优化结果
| 架构 | 体积 | 备注 |
|------|------|------|
| armeabi-v7a | 16.5MB | 32 位 ARM (旧设备) |
| arm64-v8a | 18.8MB | 64 位 ARM (主流) |
| x86_64 | 20.0MB | 模拟器/ChromeOS |
| universal | ~51MB | 全架构包 (不推荐分发) |

### ProGuard 注意事项
- Google Play Core 库需添加 `-dontwarn` 规则，否则 R8 编译失败
- 加密库 (pointycastle/bouncycastle) 必须 keep，否则运行时崩溃

## 开发工具链

### auto-doc-update 全局 Skill
- 跨项目、跨 IDE 的自动文档更新系统
- Claude Code: Stop hook 自动触发 `/auto-doc-update`
- 其他 IDE (Trae/Cursor): 读取 AGENTS.md 协议，手动"更新文档"触发
- 智能文档角色识别: 文件名模式 (权重3) + 内容特征 (权重1, 阈值4)
- 版本号优先级: CHANGELOG.md → build files (pubspec.yaml/package.json/etc.)
- Git 变更自动分类: 新增/修复/移除/重构/更新/文档/构建/样式
- 脚本工具: scan_docs.py / detect_version.py / git_changes.py (JSON 输出)
- Stop hook 正确 schema: `hooks.Stop[].hooks[]` 嵌套 (matcher + hooks 数组)

## 关键 Bug 解决
1. 二次验证不弹 → FieldRow sync→async
2. 加强安全红屏 → initState 弹窗 → 导航前验证（已移除加强安全功能）
3. 遮罩丢失 → isPassword: true
4. 自动锁定失效 → WidgetsBindingObserver
5. 剪贴板不清理 → 单例 ClipboardService
6. pointycastle PBKDF2 → `KeyDerivator('PBKDF2-HMAC-SHA256')` 注册表未注册 → 直接实例化 `PBKDF2KeyDerivator(HMac(SHA256Digest(), 64))`
7. `LockScreen._unlock()` setState after dispose → 解锁成功时 widget 已被替换，添加 `if (!mounted) return;`
8. 集成测试 `findsOneWidget` vs `findsWidgets` → VaultScreen AppBar + NavigationBar 都有"信息保险箱"文本，应使用 `findsWidgets`
9. DatabaseService 测试隔离 → 新增 `dbName` 可选参数
10. 银行 SVG 不显示 → iconfont.cn SVG 含白色底色 `fill="#FFFFFF"`，`ColorFilter.mode(srcIn)` 覆盖了整个图标，删除底色路径修复
11. 锁屏/创建密码界面导航栏未适配 → 无 AppBar 页面需用 `AnnotatedRegion<SystemUiOverlayStyle>` 手动设置，新增 `AppTheme.overlayStyle()`
12. app_theme.dart 编译错误 → 缺失 `import 'package:flutter/services.dart'`
13. Settings 测试 ListView 视口外查找失败 → 新增条目后列表变长，"关于信息保险箱"被推至视口外，用 `scrollUntilVisible` 修复

## 新功能实现记录

### 修改主密码 (v1.1.3)
- `AuthService.changePassword()` — 验证旧密码→派生新密钥→调用 `VaultService.reEncryptAll()`→更新 hash/salt/masterKey
- `VaultService.reEncryptAll()` — 切换 `_encryptionKey` 逐条解密→新密钥加密→写回 DB→`setEncryptionKey(newKey)` 重载
- 修改前弹窗提醒备份兼容性（旧密码导出的备份无法导入）
- 密码最短位数从 8 降为 4 位

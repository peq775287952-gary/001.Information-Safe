# Findings — 信息保险箱

## 产品
- 四种类型：密码/银行卡/证件/笔记
- 主密码 + 指纹 + 安全等级 + 智能分类
- 剪贴板 60s 清空 + 自动锁定

## 技术决策
| Decision | Rationale |
|----------|-----------|
| Flutter 3.38.6 + Provider + sqflite | 跨平台轻量方案 |
| encrypt + pointycastle | AES-256-GCM + PBKDF2 |
| font_awesome_flutter | 品牌图标 |
| flutter_launcher_icons | 应用图标生成 |
| mock MethodChannel (非 mockito) | flutter_secure_storage 测试 mock |

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

## 代码架构
```
lib/
├── models/   VaultItem, ItemType, SecurityLevel, Folder
├── services/ Encryption, Auth, Database, Vault, Clipboard, SmartCategory
├── screens/  Lock, CreatePwd, Vault, Search, Detail, AddEdit, Settings, FolderMgmt
├── widgets/  PlatformIcon, TypeIcon, QuickFillChips, StaggeredList,
│             FieldRow, ItemListTile, TypeFilterBar, FolderFilterBar, SecondaryAuthDialog
├── theme/    AppTheme (手工色板)
└── utils/    Constants, Validators
```

## 测试架构
```
test/
├── services/  130 unit tests (auth, encryption, vault, database, export_import, clipboard)
├── models/    18 model tests (item_type)
├── screens/   9 widget tests (lock_screen, create_password_screen, settings_screen)
├── goldens/   4 golden tests (TypeIcon, TypeFilterBar, LockScreen, CreatePasswordScreen)
└── widget_test.dart  1 app smoke test
integration_test/
├── app_test.dart      1 integration test (14 步全流程 + 9 自动截图)
└── screenshots/       截图输出目录 (从模拟器拉取)
```

## 关键 Bug 解决
1. 二次验证不弹 → FieldRow sync→async
2. 加强安全红屏 → initState 弹窗 → 导航前验证
3. 遮罩丢失 → isPassword: true
4. 自动锁定失效 → WidgetsBindingObserver
5. 剪贴板不清理 → 单例 ClipboardService
6. pointycastle PBKDF2 → `KeyDerivator('PBKDF2-HMAC-SHA256')` 注册表未注册 → 直接实例化 `PBKDF2KeyDerivator(HMac(SHA256Digest(), 64))`
7. `LockScreen._unlock()` setState after dispose → 解锁成功时 widget 已被替换，添加 `if (!mounted) return;`
8. 集成测试 `findsOneWidget` vs `findsWidgets` → VaultScreen AppBar + NavigationBar 都有"信息保险箱"文本，应使用 `findsWidgets`
9. DatabaseService 测试隔离 → 新增 `dbName` 可选参数

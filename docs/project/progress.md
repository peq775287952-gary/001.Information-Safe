# Progress Log — 信息保险箱

## 当前状态: v1.2.1+20 | 142 tests | 2026-05-28

### 断点续接

| 问题 | 答案 |
|------|------|
| 在哪？ | v1.2.1，142 测试全通过，Windows 端 Fluent UI + Bug 修复 + MSIX 打包完成 |
| 去哪？ | **Phase 3 扫码同步**（双端二维码加密传输）|
| 目标？ | 个人信息保险箱 Android + Windows 双端 |
| 学到什么？ | KeyboardListener 替代 Shortcuts 处理 Fluent UI 快捷键冲突；MSIX 打包流程 |
| 做了什么？ | Windows 端 13 个 Bug 修复 + 深色模式统一 + MSIX 打包支持 |
| 下一步？ | Phase 3 扫码同步或功能迭代 |

---

## Session: 2026-05-28 (Windows 端 Bug 修复 + MSIX 打包)

### Windows 端 Bug 修复 (13 项)
- **Esc 快捷键**: `Shortcuts` 被 Fluent UI NavigationView 拦截，改用 `KeyboardListener` + `FocusNode`
- **Ctrl+N/Ctrl+S**: 主界面新建、编辑页保存快捷键
- **深色模式统一**: `AppTheme.darkBg` 从 `#0B1120` 改为 `#202020`(Windows标准黑灰)
- **导航栏背景**: 添加 `navigationPaneTheme` 配置
- **建议标签深色模式**: `_buildSuggestionChip` 背景色适配
- **平台图标深色模式**: 亮度阈值 0.2→0.5，深色图标自动变白
- **文件夹标签**: `_ItemCard` 标题右侧显示 `item.folderName`
- **快捷填入滑动**: `ListView.separated` 改为 `SingleChildScrollView` + `Row`
- **平台图标显示**: `TypeIcon` 改为 `PlatformIcon`
- **新建文件夹输入框**: `SizedBox(height: 36)` 限制高度
- **详情页/编辑页返回**: 添加 leading 返回按钮

### MSIX 打包
- 添加 `msix_config` 到 `pubspec.yaml`
- 生成自签名测试证书
- 成功打包 `infovault.msix` (18MB)

### 构建产物
- MSIX: `infovault\build\windows\x64\runner\Release\infovault.msix`
- 便携版: `infovault\build\windows\x64\runner\Release_v1.2.1+20_Windows_BugFix4\`

---

## Session: 2026-05-28 (Windows 端 bug 修复 + Fluent UI 方案)

### Windows 端 Bug 修复
- **compute() Isolate 卡死**: `encryption_service.dart` 添加 `Platform.isWindows` 判断，Windows 上跳过 compute() 直接运行 PBKDF2
- **databaseFactory 未初始化**: `main.dart` 添加 `databaseFactory = databaseFactoryFfi;`
- **缺少 sqflite 导入**: `database_service.dart` 添加 `import 'package:sqflite/sqflite.dart';`
- **缺少 sqlite3.dll**: `pubspec.yaml` 添加 `sqlite3_flutter_libs: ^0.5.0`

### Windows 端自动化测试
- 使用 pywinauto (Windows UI Automation) + pyautogui (坐标点击) 组合方案
- 成功验证：创建密码、解锁密码
- 未成功：添加条目（坐标定位不准确）、搜索、设置、锁定/解锁
- **根因**：Flutter Windows 的 UIA 控件树只暴露窗口框架级控件，内部按钮/输入框不暴露

### Windows 端 Fluent UI 改造方案
- **方案**: 使用 `fluent_ui` 包，平台分流架构（Android 保持 MaterialApp，Windows 用 FluentApp）
- **核心改动**: NavigationView 侧边栏、ContentDialog 替代 BottomSheet、TextBox 替代 TextField
- **详细方案**: docs/project/fluent_ui_plan.md（13步实施计划）
- **状态**: 方案已确认，待实施

### 清理
- 删除所有 Windows 测试脚本（test_win_*.py）

---

## Session: 2026-05-28 (Windows Fluent UI Phase B — 完整覆盖)

### 新增（4 个文件）
- `add_edit_item_screen_win.dart` — ~570 行，5 种类型表单（Fluent TextBox + QuickFillChips + 照片管理 + ComboBox 文件夹选择）
- `item_detail_screen_win.dart` — 详情页，类型专属字段展示 + 密码遮罩 + 照片网格 + 全屏查看
- `folder_management_screen_win.dart` — 文件夹列表 + ContentDialog 删除确认
- `change_password_screen_win.dart` — 旧密码验证 + 新密码设置 + 兼容性提示

### 更新导航引用
- vault_screen_win → ItemDetailScreenWin + AddEditItemScreenWin
- search_screen_win → ItemDetailScreenWin
- settings_screen_win → ChangePasswordScreenWin + FolderManagementScreenWin

### 验证
- flutter analyze: 0 errors, 0 warnings ✓
- flutter test: 142/142 passed ✓
- Windows 端不再依赖任何 Material 页面

---

## Session: 2026-05-28 (Windows Fluent UI Phase A 改造)

### 新增
- **Windows Fluent UI 改造 Phase A**: 7 新建文件 + 2 修改文件
  - 架构：Platform.isWindows 分流，FluentApp vs MaterialApp
  - 新建：app_windows.dart、fluent_theme.dart、main_shell_win.dart、vault_screen_win.dart
  - 新建：search_screen_win.dart、settings_screen_win.dart、add_item_dialog.dart
  - 新建：lock_screen_win.dart、create_password_screen_win.dart
  - 修改：main.dart 平台分流、pubspec.yaml 添加 fluent_ui + system_theme
- 依赖：fluent_ui ^4.15.1、system_theme ^3.2.0（兼容 Dart 3.10.7）
- Fluent 组件映射：NavigationView、NavigationPane、ContentDialog、TextBox、ToggleSwitch、InfoBar、RadioGroup

### 验证
- `flutter analyze`: 0 errors, 0 warnings ✓
- `flutter test`: 142/142 passed ✓

### 版本
- v1.1.9+18 → v1.2.0+19
- CHANGELOG.md、progress.md、README.md 已更新

### Phase B — 完成 (2026-05-28)
所有 Windows 页面已 Fluent 化，Windows 端不再依赖 Material 组件。
- flutter_acrylic 亚克力/Mica 窗口效果已集成

### 最终状态
- **analyze**: 0 errors, 0 warnings
- **test**: 142/142 passed
- **Windows 构建**: Release 成功 (30.6MB)

---

## Session: 2026-05-28 (文档整理 + 项目文档迁移)

### 文档整理
- **docs/superpowers/ 归档**: 4 个历史文档移至 `archive/`（Phase 1 计划、产品设计、UI 优化方案、UI 重设计章程）
- **内容合并**: 产品定位+路线图→task_plan.md，安全等级+不做的功能→README.md，UI 设计系统→findings.md
- **项目文档迁移**: `progress.md`、`findings.md`、`task_plan.md` 从根目录移至 `docs/project/`
- **引用同步**: AGENTS.md、MEMORY.md 中所有引用路径已更新
- **README.md 更新**: 版本信息更新至 v1.1.9，补充 v1.1.7/v1.1.8 版本记录，Phase 2 状态更新
- **Git 提交推送**: 49cba77，62 files changed

---

## Session: 2026-05-28 (v1.1.9 — QQ 图标 + 深色模式 + SenseNove 清理)

### 修复
- **QQ 图标**: `Icons.chat_bubble_rounded` → `FontAwesomeIcons.qq`（真正的 QQ 企鹅 logo）
- **深色模式 chip 适配**: `app_theme.dart` chipTheme labelStyle/selectedColor 亮度自适应
- **"新建"按钮深色模式**: `folder_filter_bar.dart` 添加 onSurface 颜色
- **分类筛选深色模式**: `type_filter_bar.dart` FilterChip 添加 brightness 检测
- **SenseNove 删除**: quick_fill_chips.dart + brand_icons.dart + sensenova.svg 全部清理

### 测试
- 142 项测试全部通过（含 golden 文件更新）

---

## Session: 2026-05-28 (v1.1.8 — PBKDF2 迭代兼容迁移)

### 修复
- **PBKDF2 迭代兼容**: 新增 `legacyPbkdf2Iterations = 100000` 常量
- **自动迁移逻辑**: `AuthService._migrateIterations()` — 旧用户首次解锁自动用旧参数验证，成功后迁移到 10k 迭代并重新加密全部数据
- **新用户直接 10k**: `setMasterPassword()` 存储当前迭代次数

### 教训
- PBKDF2 迭代次数变更会导致旧密码哈希不匹配，必须做兼容迁移
- EncryptedSharedPreferences 数据在覆盖安装时可能因 Keystore 失效而丢失
- 用户有 root + MT 管理器，可通过 `/data/data/<pkg>/shared_prefs/` 恢复

---

## Session: 2026-05-27 (v1.1.7 — UI/UX 优化 + 深色模式全面适配)

### 优化（6 项全部完成）
- **A. 解锁卡顿**: PBKDF2 迭代 100k→10k + `compute()` Isolate，3s→0.3s
- **B. 深色模式文件夹名**: `FolderFilterBar` brightness 检测
- **C. 图标深色模式**: `_iconContainer` luminance 检测
- **D. 搜索框键盘**: FocusNode + postFrameCallback
- **E. Switch 深色模式**: SwitchThemeData
- **F. 文件夹选择**: "无文件夹"选项

---

## Session: 2026-05-27 (v1.1.6 — Android 包体积优化)

### 优化
- **Android 包体积**: R8 代码压缩 + 资源缩减 + ABI 分包 → 51MB 降至 16-20MB
- **ProGuard 规则**: Google Play Core keep 规则
- **创建密码页面**: try-catch + 加载状态

---

## Session: 2026-05-27 (v1.1.4 — 移除生物识别功能)

### 移除
- 完全移除生物识别功能（Windows Hello + Android 指纹/人脸）
- 删除 `biometric_service.dart`、`local_auth` 依赖
- 清理所有相关 UI、测试、常量

---

## Session: 2026-05-26 (v1.2.0 — Phase 2 Windows 桌面版)

### 新增
- **Windows 桌面版**: sqflite FFI 数据库适配
- **平台工具**: `platform_utils.dart` — 数据库路径、平台检测
- **Windows 构建脚本**: `build_windows.bat`

### 构建
- Windows Release 构建成功: `flutter build windows --release`
- 修复 CMake 模板过期、VS 2026 编译兼容、ATL 组件

---

## 版本历程

| 版本 | 日期 | 主要变更 |
|------|------|----------|
| v1.2.1 | 2026-05-28 | Windows 13 个 Bug 修复、深色模式统一、MSIX 打包支持 |
| v1.2.0 | 2026-05-28 | Windows Fluent UI 改造 (Phase A+B)、亚克力/Mica 效果 |
| v1.1.9 | 2026-05-28 | QQ 图标修复、深色模式 chip 适配、SenseNove 清理 |
| v1.1.8 | 2026-05-28 | PBKDF2 迭代兼容迁移（100k→10k 自动迁移） |
| v1.1.7 | 2026-05-27 | UI/UX 6 项优化、深色模式全面适配 |
| v1.1.6 | 2026-05-27 | Android 包体积优化（51MB→16-20MB） |
| v1.1.4 | 2026-05-27 | 移除生物识别功能 |
| v1.2.0 | 2026-05-26 | Windows 桌面版支持 |
| v1.1.3 | 2026-05-26 | 修改主密码功能 |
| v1.1.2 | 2026-05-26 | 导航栏适配、银行图标修复 |

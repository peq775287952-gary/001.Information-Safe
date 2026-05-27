# Progress Log — 信息保险箱

## 当前状态: v1.1.9+18 | 142 tests | 2026-05-28

### 断点续接

| 问题 | 答案 |
|------|------|
| 在哪？ | v1.1.9，142 测试全通过，Android 分包构建正常 |
| 去哪？ | 用户确认后构建分发；Phase 3 扫码同步待规划 |
| 目标？ | 个人信息保险箱 Android + Windows 双端 |
| 学到什么？ | PBKDF2 迭代变更需兼容迁移；EncryptedSharedPreferences 卸载即丢失 |
| 做了什么？ | QQ 图标修复、深色模式 chip 适配、SenseNove 删除、PBKDF2 迁移逻辑 |

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
| v1.1.9 | 2026-05-28 | QQ 图标修复、深色模式 chip 适配、SenseNove 清理 |
| v1.1.8 | 2026-05-28 | PBKDF2 迭代兼容迁移（100k→10k 自动迁移） |
| v1.1.7 | 2026-05-27 | UI/UX 6 项优化、深色模式全面适配 |
| v1.1.6 | 2026-05-27 | Android 包体积优化（51MB→16-20MB） |
| v1.1.4 | 2026-05-27 | 移除生物识别功能 |
| v1.2.0 | 2026-05-26 | Windows 桌面版支持 |
| v1.1.3 | 2026-05-26 | 修改主密码功能 |
| v1.1.2 | 2026-05-26 | 导航栏适配、银行图标修复 |

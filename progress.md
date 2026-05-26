# Progress Log — 信息保险箱

## Session: 2026-05-26 (auto-doc-update skill 基础设施)

### 新增
- **auto-doc-update 全局 skill**: 跨项目、跨 IDE 的自动文档更新系统
  - Stop hook 自动触发 (Claude Code) + AGENTS.md 协议 (Trae/Cursor 等)
  - 智能文档角色识别 (README/CHANGELOG/progress/findings/task_plan)
  - 版本号自动检测 (CHANGELOG → 构建文件)
  - Git 变更自动捕获 (git diff → 类型分类)
  - 陌生项目自动询问创建文档集
- 本项目部署 AGENTS.md + CLAUDE.md
- `~/.claude/settings.json` Stop hook 配置 (matcher + hooks 嵌套 schema)

### 测试: 142 tests, 0 failures

## Session: 2026-05-26 (v1.1.3 — 修改主密码功能)

### 新增
- 修改主密码：设置→安全→修改主密码，验证旧密码后可随时更换
- `AuthService.changePassword()` — 验证旧密码→派生新密钥→重加密全部数据→更新存储
- `VaultService.reEncryptAll()` — 旧密钥逐条解密→新密钥加密→写回 DB→重载
- `ChangePasswordScreen` — 3 密码框 + 验证 + 备份提醒弹窗
- `Validators.newPassword()` — ≥4位 + 不能与旧密码相同

### 变更
- 密码最短位数 8→4 位
- validators_test 新增 4 个 newPassword 测试
- settings_screen_test 新增"修改主密码"断言 + scrollUntilVisible 修复

### 测试: 142 tests, 0 failures

## Session: 2026-05-26 (v1.1.2 — 导航栏适配 + 图标修复)

### 新增 & 修复
- 锁屏/创建密码界面导航栏适配（`AppTheme.overlayStyle()` + `AnnotatedRegion`）
- 银行 SVG 图标修复（删除 iconfont.cn 白色底色路径）
- app_theme.dart 编译错误修复（缺失 `import 'package:flutter/services.dart'`）
- 永久开发规则建立（自动记忆、规范检查、更新日志、断点续接）
- 构建流程固化（每次构建走 bump → build，自动递增版本号）

### 文档更新
- README.md 全面刷新（版本、功能、技术栈、项目结构）
- findings.md 更新（移除指纹/安全等级，补充新 Bug 修复）
- task_plan.md、progress.md 版本同步
- 新建 CHANGELOG.md、feedback_dev-rules.md、feedback_build-version-bump.md

### GitHub 推送
- 项目推送至 https://github.com/peq775287952-gary/001.Information-Safe.git
- infovault 从 git submodule 转为普通目录
- pub_cache 从 Git 追踪中移除
- .gitignore 配置

### 当前构建: v1.1.3+12 (未构建新 APK)

## Session: 2026-05-26 (v1.1.1 — 正式版) ✅

### 新功能
- AI API Key 类型 (ItemType.apiKey)
- SVG 品牌图标系统（16 AI + 8 银行 + 5 证件）
- 自动锁定开关（可关闭，默认 3 分钟）
- 版本号系统（界面 X.Y.Z，构建自动递增）
- Android 边缘到边缘导航栏（edge-to-edge + 透明导航栏）
- build.bat 一键构建脚本

### 代码清理
- 完全移除指纹认证代码 (local_auth、BiometricResult)
- 完全移除加强安全代码 (security_level.dart、SecondaryAuthDialog)
- 移除 AndroidManifest USE_BIOMETRIC 权限
- 清理 platform_icon.dart 25 条死 _brands 条目
- 清理 database_service.dart security_level 死列
- 移除 export_import_service.dart 硬编码版本号

### 新增依赖
- `flutter_svg: ^2.0.17` — SVG 图标渲染
- `package_info_plus: ^8.1.0` — 运行时版本号

### 测试总计: 138 tests, 0 failures

---

## Session: 2026-05-26 (测试全覆盖)

### 集成测试 (C 层) ✅
- 全流程集成测试: 14 步覆盖 (创建密码 → 添加条目 → 查看详情 → 设置 → 锁定 → 解锁)
- 9 张自动截图，存储在 `integration_test/screenshots/`
- 模拟器: Pixel 6, Android 15 (API 35), WHPX 加速
- 测试时间: ~15 秒/次

### Bug 修复 (本轮) ✅
- `LockScreen._unlock()` setState after dispose — 加 `if (!mounted) return;`
- 集成测试 enterText 不生效 — 改用 `tester.testTextInput.enterText()`
- 集成测试 takeScreenshot API — Binding 上调用，非 tester
- MSYS 路径转换 — `MSYS_NO_PATHCONV=1` 修复 adb pull

### 文档更新 ✅
- `TESTING.md` — 完整测试文档 (快速命令、架构、截图、修复记录)
- `task_plan.md` — 更新环境变量、构建/测试命令、文档索引
- `findings.md` — 补充测试踩坑、Bug 修复
- `progress.md` — 本文档
- 记忆文件 (MEMORY.md, project_state.md) 更新

### 测试总计: 138 tests, 0 failures

## Session: 2026-05-25 (测试 A+B 层)

### 单元测试 (A 层) ✅
- 130 个单元测试全部通过
- 覆盖: validators(30), database(12), vault(30), encryption(13), export_import(4), auth(12), clipboard(5), models(18), app smoke(1)
- mock flutter_secure_storage via `TestDefaultBinaryMessenger.setMockMethodCallHandler`
- `DatabaseService({String? dbName})` 测试隔离参数

### Widget 测试 (B 层) ✅
- 9 widget 测试: LockScreen(3), CreatePasswordScreen(5), SettingsScreen(1)
- MaterialApp + Provider wrapping 解决 Directionality 缺失
- `find.text('主密码至少8位')` 精确匹配 (非 textContaining，会匹配 hint)

### Golden 截图 (B 层) ✅
- 4 golden tests: TypeIcon (4 variants), TypeFilterBar, LockScreen, CreatePasswordScreen
- 物理尺寸 390x844 @ 3.0x

### 模拟器环境搭建 ✅
- AVD: Pixel 6, API 35 x86_64, WHPX 加速
- AVD 路径: D:\DEVcode\android\avd\flutter_test.avd
- 修复 avd.ini 缺失 + config.ini 占位符

### Bug 修复 (本轮) ✅
- pointycastle PBKDF2 注册表未注册 → 直接实例化 `PBKDF2KeyDerivator(HMac(SHA256Digest(), 64))`
- 跨盘符 Kotlin 增量编译 → PUB_CACHE 移至 H: 盘
- Gradle 下载超时 → 配置国内镜像 (flutter-io.cn)

### 构建优化 ✅
- 国内镜像: PUB_HOSTED_URL + FLUTTER_STORAGE_BASE_URL → flutter-io.cn
- Gradle Maven: 腾讯云 Nexus 镜像
- PUB_CACHE: H:\MyPasswords\pub_cache (同盘，避免 Kotlin 跨盘符错误)

---

## Session: 2026-05-24 (完整一天)

### Phase 0: 需求设计 ✅
- 用户需求调研、功能范围确定、技术选型
- 项目从"我密码"→"信息保险箱"
- 设计文档 + 实现计划编写

### Phase 1: Android 本地版实现 ✅
- 18 Tasks 完成：28 Dart + 8 test
- 11+ Git commits
- flutter analyze: 0 errors

### 环境搭建 ✅
- Flutter/Android/Gradle/Java 全部迁至 D:\DEVcode
- 7 环境变量持久化，C 盘清理 ~9GB
- 阿里云 Maven 已下线→腾讯云 Nexus

### 首次构建 ✅ (v1.0.0)
- app-debug.apk 147MB，耗时 ~12min

### 功能测试 ✅
- 12 项用户真机测试，发现 6 个初始 Bug

### Bug 修复（多轮） ✅
- 二次验证异步链路重写
- 中文本地化配置
- 银行卡号/证件号遮罩
- 表单标签按类型适配
- 自动锁定 WidgetsBindingObserver
- 加强安全入口验证（导航前弹窗）
- 剪贴板服务接入
- 深色模式标签颜色
- 搜索焦点回弹

### UI 重设计 ✅
- 手工蓝灰色板替代 Material3 自动色
- 4px 网格系统，圆角分级 6/10/12/16px
- emoji → Material 彩色圆底图标
- FontAwesome 品牌图标 + 平台映射 (45+)
- 一键填入标签 (36 个快捷选项)
- 列表渐入动画 + Cupertino 页面转场
- 深色/浅色自适应

### 版本历程
| 版本 | 主要内容 |
|------|----------|
| v1.0.0 | 初始构建 |
| v1.0.1 | UI 重设计 + 一键填入 |
| v1.0.2 | 红屏崩溃修复 + 深色标签 |
| v1.0.3 | 入口验证 + 搜索焦点 + 剪贴板开关 |
| v1.0.4 | 应用名/图标 + 品牌图标映射 + 作者署名 |
| v1.1.0 | 版本号系统 + 一键构建 |
| v1.1.1 | SVG 品牌图标 + API Key + 自动锁定开关 + 代码大清理 |
| v1.1.3 | 修改主密码功能 + 密码最短4位 + 重加密机制 |
| v1.1.2 | 导航栏全适配 + 银行图标修复 + 永久开发规则 |

### 当前构建
- v1.1.2+11, 51.6MB Release APK

## 5-Question Reboot
| Q | A |
|----|----|
| 在哪？ | Phase 1 完成 v1.1.3，142 测试全通过，auto-doc-update skill 已部署 |
| 去哪？ | Phase 2: Windows 桌面版 |
| 目标？ | 个人信息保险箱 Android + Windows |
| 学到什么？ | 修改密码=重加密所有数据、ListView 视口外 widget 需 scrollUntilVisible、Stop hook schema 需 matcher+hooks 嵌套 |
| 做了什么？ | 修改主密码 + 密码最短4位 + auto-doc-update 全局 skill + AGENTS.md/CLAUDE.md |

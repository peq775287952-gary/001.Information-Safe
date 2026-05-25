# Progress Log — 信息保险箱

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

### 测试总计: 144 tests, 0 failures
- 单元: 130 | Widget: 9 | Golden: 4 | 集成: 1

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

### 当前构建
- v1.0.4+5, 149MB Debug APK
- 构建时间 ~45s（增量）

## 5-Question Reboot
| Q | A |
|----|----|
| 在哪？ | Phase 1 完成 v1.0.4，144 测试全通过 |
| 去哪？ | Phase 2: Windows 桌面版 |
| 目标？ | 个人信息保险箱 Android + Windows |
| 学到什么？ | 阿里云 Maven 下线、中文路径问题、showDialog 框架冲突、PBKDF2 注册表、集成测试 enterText 机制 |
| 做了什么？ | 全栈 Flutter App + 环境 + 4 轮迭代 + 3 层测试架构 |

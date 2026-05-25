# Findings — 信息保险箱

## 产品
- 四种类型：密码/银行卡/证件/笔记
- 主密码 + 指纹 + 安全等级 + 智能分类
- 剪贴板 60s 清空 + 自动锁定

## 技术
| Decision | Rationale |
|----------|-----------|
| Flutter 3.38.6 + Provider + sqflite | 跨平台轻量方案 |
| encrypt + pointycastle | AES-256-GCM + PBKDF2 |
| font_awesome_flutter | 品牌图标 |
| flutter_launcher_icons | 应用图标生成 |

## 镜像（2026-05-24 验证）
- ❌ 阿里云 Maven：全部 404 下线
- ✅ 腾讯云 Nexus：可用
- ✅ Google/Maven Central：直连可用
- ✅ flutter-io.cn：可用

## 环境踩坑
- 中文用户名路径 → 全部迁 D:\DEVcode
- Kotlin 跨盘增量缓存冲突 → 非阻断
- showDialog 在 addPostFrameCallback 崩溃 → 改导航前验证

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

## 关键 Bug 解决
1. 二次验证不弹 → FieldRow sync→async
2. 加强安全红屏 → initState 弹窗 → 导航前验证
3. 遮罩丢失 → isPassword: true
4. 自动锁定失效 → WidgetsBindingObserver
5. 剪贴板不清理 → 单例 ClipboardService

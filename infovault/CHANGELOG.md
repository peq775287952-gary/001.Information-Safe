# 更新日志

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

# Task Plan: 信息保险箱 (InfoVault)

## Goal
开发"信息保险箱"——Flutter 跨平台个人信息保险箱，Android + Windows 双端。

## Current Phase
Phase 1: Android 本地版（v1.0.4 — 功能完整，UI 优化完成）

## 当前版本：v1.0.4+5

### 已完成
- 28 Dart 源文件 + 8 测试文件
- 四种保险箱类型（密码/银行卡/证件/笔记）
- 主密码 + 指纹解锁 + 安全等级（基础/加强）
- 智能分类（50+ 平台映射）+ 自定义文件夹
- 全字段搜索（结果按类型分组）
- 品牌平台图标（45+ 平台专属图标）
- 一键填入标签（20 平台 + 9 银行 + 7 证件）
- 剪贴板 60s 自动清空（可开关）
- 切后台自动锁定（时间可调 1-30 min）
- 加强安全：入口验证（导航前弹窗）
- 深色/浅色自适应（手工蓝灰色板）
- UI 现代化：4px 网格、圆角分级、Material 图标、列表渐入动画
- 中文本地化（系统菜单中文）
- 自定义应用图标 + 应用名"信息保险箱"
- 作者署名 N7

## Phases

### Phase 0: 需求设计 ✅
### Phase 1: Android 本地版 ✅ (v1.0.4)
### Phase 2: Windows 本地版 ⏸
- Windows 桌面适配 + Windows Hello
### Phase 3: 扫码同步 ⏸
### Phase 4: 云端加密 ⏸

## 开发环境（关键！）
| 工具 | 路径 | 版本 |
|------|------|------|
| Flutter | D:\DEVcode\flutter | 3.38.6 |
| Android SDK | D:\DEVcode\android\sdk | platforms 34/35/36 |
| Gradle | D:\DEVcode\.gradle | 8.14 (腾讯云镜像) |
| Pub | D:\DEVcode\.pub_cache | - |
| Java | D:\java | 21.0.7 |
| 项目 | h:\MyPasswords\infovault | - |

## 环境变量
```
FLUTTER_ROOT=D:\DEVcode\flutter
ANDROID_HOME=D:\DEVcode\android\sdk
ANDROID_USER_HOME=D:\DEVcode\android\user
GRADLE_USER_HOME=D:\DEVcode\.gradle
PUB_CACHE=D:\DEVcode\.pub_cache
JAVA_HOME=D:\java
```

## 构建命令
```bash
export FLUTTER_ROOT="D:/DEVcode/flutter"
export ANDROID_HOME="D:/DEVcode/android/sdk"
export GRADLE_USER_HOME="D:/DEVcode/.gradle"
export PUB_CACHE="D:/DEVcode/.pub_cache"
export JAVA_HOME="D:/java"
export PUB_HOSTED_URL="https://pub.flutter-io.cn"
export FLUTTER_STORAGE_BASE_URL="https://storage.flutter-io.cn"
cd h:/MyPasswords/infovault
rm -rf build
D:/DEVcode/flutter/bin/flutter build apk --debug
```

## 文档索引
| 文件 | 说明 |
|------|------|
| docs/superpowers/specs/2026-05-24-ipassword-design.md | 产品设计 |
| docs/superpowers/plans/2026-05-24-infovault-phase1.md | 实现计划 |
| docs/superpowers/specs/2026-05-24-ui-redesign-charter.md | UI 重设计章程 |
| docs/superpowers/specs/2026-05-24-ui-optimization-plan.md | UI 优化方案 |
| task_plan.md | 本文档 |
| findings.md | 研究发现 |
| progress.md | 进度日志 |

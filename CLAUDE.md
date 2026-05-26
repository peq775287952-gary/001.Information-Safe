# 信息保险箱 (InfoVault) — Claude Code 配置

> 通用协议见 [AGENTS.md](AGENTS.md)，本文件为 Claude Code 专属配置。

---

## 项目信息

- **名称**: 信息保险箱 (InfoVault)
- **类型**: Flutter Android 应用
- **语言**: Dart + Python 脚本
- **当前版本**: v1.1.2 (参见 infovault/CHANGELOG.md)

## 记忆系统

持久化记忆目录: `.claude/memory/`

- `MEMORY.md` — 记忆索引
- `feedback_*.md` — 用户反馈和开发规则
- `project_state.md` — 项目状态快照

## 关键规则

1. **没有用户确认，禁止执行任何操作**（记忆铁律）
2. **每次代码修改后立即更新文档**（参见 AGENTS.md 文档清单）
3. **构建 APK 必须走 build.bat 自动递增版本号**
4. **138 测试必须全部通过**

## 常用命令

```bash
# 运行所有测试
cd infovault && flutter test

# 静态分析
cd infovault && flutter analyze lib/ test/

# 构建 APK
cd infovault && build.bat
```

## 项目结构

```
h:\MyPasswords\
├── infovault/          ← Flutter 项目
│   ├── lib/            ← Dart 源码
│   ├── test/           ← 测试 (138 tests)
│   └── build.bat       ← 构建脚本（自动递增版本号）
├── docs/               ← 设计文档
├── .claude/memory/     ← AI 记忆（Claude Code 专用）
├── AGENTS.md           ← 通用 AI 协议
└── CLAUDE.md           ← 本文件
```

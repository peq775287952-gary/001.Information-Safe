# 信息保险箱 (InfoVault) — Claude Code 配置

> 通用协议见 [AGENTS.md](AGENTS.md)，本文件为 Claude Code 专属配置。

---

## 铁律：没有用户确认，禁止执行任何操作

无论是安装、修改、删除、创建文件，还是查看类命令（`ls`、`cat`、`flutter doctor` 等）— **所有工具调用在执行前都必须获得用户明确确认**。

**唯一例外**: 纯思考（thinking 块内的推理），不调用任何工具。

**How to apply**:
- 给出方案后，等待用户说"确认"、"执行"、"开始"等指令
- 用户说"回复我"时，只回复文字，不调用工具
- 违反此规则视为严重不尊重用户控制权

---

## 项目信息

- **名称**: 信息保险箱 (InfoVault)
- **类型**: Flutter 跨平台应用 (Android + Windows)
- **当前版本**: v1.1.9 (参见 [CHANGELOG.md](infovault/CHANGELOG.md))
- **测试**: 142 tests, 0 failures

---

## 记忆系统

持久化记忆目录: `C:\Users\因心\.claude\projects\h--MyPasswords\memory\`

- `MEMORY.md` — 记忆索引（详细内容）

---

## MCP 服务器

已配置 6 个 MCP 服务器（全局生效）：

| MCP | 功能 | 包名 |
|-----|------|------|
| context7 | 实时文档查询 | @upstash/context7-mcp@latest |
| Puppeteer | 浏览器自动化 | @modelcontextprotocol/server-puppeteer |
| Sequential-Thinking | 链式推理 | @modelcontextprotocol/server-sequential-thinking |
| Memory | 知识图谱记忆 | @modelcontextprotocol/server-memory |
| Filesystem | 文件系统访问 | @modelcontextprotocol/server-filesystem |
| tavily | 联网搜索+网页读取 | tavily-mcp |

- Tavily API Key 已配置
- Filesystem 可访问: Desktop、Documents、H:\MyPasswords

---

## 常用命令

```bash
# 测试
cd infovault && flutter test                         # 142 tests
cd infovault && flutter analyze lib/ test/           # 静态分析

# 构建（默认分包，不删旧包）
cd infovault && flutter build apk --release --split-per-abi

# Windows
cd infovault && flutter build windows --release
```

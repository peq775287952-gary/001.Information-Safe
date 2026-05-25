# UI 优化方案 — 信息保险箱

> 基于 ui-ux-pro-max 设计规范 + 用户需求

---

## 一、一键填入标签系统

### 改动文件
`lib/screens/add_edit_item_screen.dart`

### 表现层
在"名称"输入框下方，显示一行可滚动的快捷标签。点击即填入输入框 + 联动智能分类。

### 三种类型的标签库

**登录密码 — 18 个常用平台**
```
微信   支付宝   QQ      微博    抖音
GitHub  Gmail   Outlook  淘宝   京东
百度    钉钉    飞书     Notion  B站
Steam   Apple   Google
```

**银行卡 — 10 个常用银行**
```
招商银行  工商银行  建设银行  农业银行  中国银行
交通银行  浦发银行  平安银行  中信银行  邮储银行
```

**证件 — 7 个常用类型**
```
身份证  护照  驾照  社保卡  户口本  港澳通行证  居住证
```

### 交互
| 动作 | 行为 |
|------|------|
| 点击标签 | 填入名称输入框 + 智能分类联动 |
| 已选中状态 | 高亮（填充色，白色边变蓝边） |
| 滚动 | 横向滑动，不换行 |

---

## 二、品牌图标系统

### 方案
使用 `font_awesome_flutter` 包（已内置 2000+ 品牌/常用图标），无需管理 SVG 文件。

### 图标映射

**平台图标**（import `FontAwesomeIcons`）
```
微信    → FaIcon(FontAwesomeIcons.weixin)    → 绿色 #07C160
支付宝  → FaIcon(FontAwesomeIcons.alipay)    → 蓝色 #1677FF
QQ      → FaIcon(FontAwesomeIcons.qq)        → 黑色 #000000
微博    → FaIcon(FontAwesomeIcons.weibo)     → 红色 #E6162D
抖音    → FaIcon(FontAwesomeIcons.tiktok)    → 黑色 #000000
GitHub  → FaIcon(FontAwesomeIcons.github)    → 黑色 #181717
Gmail   → FaIcon(FontAwesomeIcons.google)    → 红色 #EA4335
淘宝    → FaIcon(FontAwesomeIcons.shopify)   → 橙色 #FF5000
京东    → FaIcon(FontAwesomeIcons.shop)      → 红色 #C91623
B站     → FaIcon(FontAwesomeIcons.video)     → 粉色 #FB7299
Steam   → FaIcon(FontAwesomeIcons.steam)     → 深蓝 #171A21
Apple   → FaIcon(FontAwesomeIcons.apple)     → 黑色 #000000
Google  → FaIcon(FontAwesomeIcons.google)    → 彩色 (text only)
百度    → FaIcon(FontAwesomeIcons.searchengin) → 蓝色 #2932E1
飞书    → FaIcon(Icons.chat_bubble_outline)  → 蓝色 #3370FF
Notion  → FaIcon(Icons.text_snippet)         → 黑色 #000000
```

**银行图标**（使用 Material Icons）
```
所有银行  → FaIcon(Icons.account_balance)  → 金融蓝 #1565C0
```

**证件图标**（使用 Material Icons）
```
身份证    → FaIcon(Icons.badge)
护照      → FaIcon(Icons.flight)  
驾照      → FaIcon(Icons.directions_car)
社保卡    → FaIcon(Icons.health_and_safety)
```

### 实现方式
- 添加 `font_awesome_flutter: ^10.7.0` 到 pubspec.yaml
- 创建 `lib/widgets/quick_fill_chips.dart`（独立组件）
- 在 `add_edit_item_screen.dart` 中引入

---

## 三、列表图标升级

### 当前
使用 emoji（🔑💳🪪📝）作为类型图标

### 优化后
使用 Material Icons 彩色圆底图标

```
登录密码  → Icons.lock       白字蓝底
银行卡    → Icons.credit_card 白字橙底
证件      → Icons.badge       白字绿底
安全笔记  → Icons.note        白字紫底
```

---

## 四、颜色规范统一

### 品牌色（不变）
```
主色: #1565C0 (蓝) — 信任、安全
```

### 新增：类型专属色
```
密码类   : #1565C0 (蓝)
金融类   : #E65100 (橙) 
证件类   : #2E7D32 (绿)
笔记类   : #6A1B9A (紫)
加强安全 : #C62828 (红)
```

### 标签 Chip 配色
```
未选中  : 灰色描边 + 浅灰背景
已选中  : 对应类型色填充 + 白色文字
```

---

## 五、改动汇总

| 文件 | 改动 |
|------|------|
| `pubspec.yaml` | +font_awesome_flutter |
| `lib/widgets/quick_fill_chips.dart` | **新建** — 快捷标签组件 |
| `lib/screens/add_edit_item_screen.dart` | +快捷标签行 |
| `lib/widgets/item_list_tile.dart` | emoji → Material 图标 |
| `lib/models/item_type.dart` | +颜色属性、+图标 iconData 属性 |

---

## 六、不涉及

- ❌ 业务逻辑不变
- ❌ 数据模型不变（仅追加属性）
- ❌ 加密/安全代码不动

---

## 七、预计效果

添加微信密码流程：
```
点 + → 选密码 → 点"微信"标签 → 名称自动填入"微信" → 分类自动设为"社交"
```

# 信息保险箱 — UI 现代化重设计章程

> 综合 frontend-design + ui-ux-pro-max 规范 | 仅视觉效果 | 不动业务逻辑

---

## 一、设计方向

### 美学定位：静谧安全 (Quiet Security)

密码管理器的本质是**信任**。用户把最重要的数字资产托付给 App，界面必须传达：安全、可靠、不张扬。

| 维度 | 选择 | 理由 |
|------|------|------|
| 风格 | **精炼极简 + 微质感** | 不冰冷，不花哨 |
| 色调 | **沉稳蓝灰 + 暖白 + 精密阴影** | 安全感，专业感 |
| 动效 | **克制微动效** (150-250ms) | 流畅不抢戏 |
| 字体 | **系统原生** (SF Pro / Roboto) | 阅读清晰，不引入额外加载 |
| 间距 | **4px 网格系统** | 数学级精确对齐 |

### 一句话记忆点
> "打开即安心" — 不靠华丽的视觉效果，靠极致的精致感和安全感让用户信任。

---

## 二、配色体系

### 放弃 Material 3 动态取色
Material 3 的 `ColorScheme.fromSeed` 泛用性强但缺乏个性。改用**手工调色**。

### 主色板

```
名称          Hex       用途
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
品牌蓝        #2563EB   主按钮、选中态、强调
深蓝          #1E40AF   按钮按下态
浅蓝          #EFF6FF   选中背景、标签底色
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
安全绿        #059669   密码字段遮罩色(暗示安全)
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
警报红        #DC2626   删除、加强安全标识
浅红          #FEF2F2   加强安全背景
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
暖白          #FAFAFA   背景（浅色模式）
卡片白        #FFFFFF   卡片表面
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
灰-100        #F1F5F9   输入框背景
灰-200        #E2E8F0   分割线
灰-400        #94A3B8   占位文字
灰-600        #475569   次要文字
灰-800        #1E293B   主文字
灰-900        #0F172A   标题文字
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
深色背景      #0B1120   暗色模式背景
深色卡片      #1E293B   暗色模式卡片
深色表面      #334155   暗色模式输入框
```

### 类型专属色（对应四种保险箱类型）

```
密码类    #3B82F6 (蓝)   柔和、信任
银行卡类  #F59E0B (琥珀) 温暖、贵重
证件类    #10B981 (翠绿) 正式、官方
笔记类    #8B5CF6 (紫)   私密、个人
```

### 配色原则
1. 主色占比不超过界面的 10%（克制使用蓝色）
2. 大量留白 + 精密灰色层次来区分信息层级
3. 彩色仅用于：选中态、类型区分、危险操作
4. 暗色模式：蓝灰底色 + 更亮的卡片表面 + 降低饱和度

---

## 三、间距与网格系统

### 基于 4px 网格

```
间距级数    值      用途
━━━━━━━━━━━━━━━━━━━━━━━━━━━━
xs          4px    图标与文字间距
sm          8px    同类元素间距
md          12px   卡片内边距
base        16px   标准外边距、页面边距
lg          20px   模块间距
xl          24px   大模块间距
2xl         32px   页面顶部/底部留白
```

### 圆角规范

```
元素          圆角
━━━━━━━━━━━━━━━━━━━
小标签/Chip    6px
按钮           10px
输入框         10px
卡片           12px
底部弹窗       16px (仅顶部)
FAB            16px (圆形)
```

---

## 四、字体规范

### 层级

```
层级    字号    字重    用途
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
H1      22sp    w600    页面大标题
H2      18sp    w600    页面标题
H3      16sp    w600    卡片标题
Body    15sp    w400    正文
Body-S  14sp    w400    列表副标题
Caption 12sp    w400    标签文字、辅助信息
Small   11sp    w500    标签徽章
```

### 字体族
- 中文：系统默认（PingFang SC / Microsoft YaHei）
- 英文/数字：系统默认（SF Pro / Segoe UI）- 等宽数字特性用于密码/CVV 显示

---

## 五、组件规范

### 5.1 卡片

```
浅色模式:
  background: #FFFFFF
  border: 0.5px #E2E8F0
  shadow: 0 1px 3px rgba(0,0,0,0.04), 0 1px 2px rgba(0,0,0,0.06)
  border-radius: 12px
  padding: 12px

暗色模式:
  background: #1E293B
  border: 0.5px #334155
  shadow: none
```

### 5.2 主按钮 (FilledButton)

```
background: #2563EB
foreground: #FFFFFF
border-radius: 10px
height: 48px
font: 16sp w600
hover: #1D4ED8
press: #1E40AF (+ scale 0.98)
```

### 5.3 次按钮 (OutlinedButton)

```
border: 1px #CBD5E1
foreground: #334155
background: transparent
border-radius: 10px
height: 44px
font: 15sp w500
```

### 5.4 输入框

```
background: #F1F5F9
border: 1px transparent (focus: #2563EB)
border-radius: 10px
height: 48px
padding: 0 14px
font: 15sp w400
placeholder: #94A3B8
label: #64748B (12sp w500, 上浮动画)
```

### 5.5 Chip 标签

```
未选中:
  background: #F1F5F9
  foreground: #475569
  border: none
  border-radius: 20px (全圆角)
  font: 13sp w500

选中:
  background: #EFF6FF
  foreground: #2563EB
  border: 1px #BFDBFE
```

### 5.6 列表条目

```
height: 56px (紧凑)
左侧图标: 36x36 彩色圆底
间距: 图标-文字 12px, 文字-箭头 8px
分割线: 无 (用间距区分)
```

### 5.7 底部导航栏

```
background: #FFFFFF (浅色) / #0F172A (暗色)
elevation: 0
顶部: 0.5px #E2E8F0 分割线
选中态: 图标+文字变为品牌蓝
未选中: #94A3B8
```

---

## 六、动效规范

### 6.1 页面转场
```
时长: 200ms
曲线: easeOut (0.0, 0.0, 0.2, 1.0)
效果: 新页从右滑入 + 淡入 (offset 16px → 0, opacity 0 → 1)
```

### 6.2 按钮按下
```
时长: 100ms
效果: scale 1.0 → 0.97 → 1.0
曲线: easeInOut
```

### 6.3 列表加载
```
效果: 条目依次淡入 (staggered)
每条延迟: 30ms
时长: 250ms easeOut
初始: opacity 0, translateY 8px
```

### 6.4 输入框聚焦
```
时长: 200ms
效果: border 1px transparent → 1px #2563EB
      label 上浮 + 缩小 (14sp → 12sp)
```

### 6.5 弹窗出现
```
时长: 250ms
效果: 从底部滑入 (translateY 100% → 0)
背景: 黑色遮罩淡入 opacity 0 → 0.5
```

---

## 七、图标系统升级

### 7.1 类型图标（替代 emoji）

| 类型 | 图标 | 背景色 | 图标色 |
|------|------|--------|--------|
| 密码 | `Icons.lock_rounded` | #EFF6FF | #3B82F6 |
| 银行卡 | `Icons.credit_card_rounded` | #FFF7ED | #F59E0B |
| 证件 | `Icons.badge_rounded` | #ECFDF5 | #10B981 |
| 笔记 | `Icons.note_alt_rounded` | #F5F3FF | #8B5CF6 |

### 7.2 平台品牌图标

使用 `font_awesome_flutter` 包（`FontAwesomeIcons`）：
- 微信(fa-weixin)、支付宝(fa-alipay)、QQ(fa-qq)、微博(fa-weibo)
- GitHub(fa-github)、Google(fa-google)、Apple(fa-apple)
- Steam(fa-steam)、Microsoft(fa-microsoft)

Material Icons 兜底无品牌的平台。

### 7.3 图标颜色 = 品牌色

每个平台标签使用其品牌色作为点缀，增强辨识度。

---

## 八、修改范围

### 8.1 需要修改的文件

| 文件 | 改动内容 |
|------|----------|
| `lib/theme/app_theme.dart` | **重写** — 手工配色、间距、圆角、字体、动效 |
| `lib/widgets/item_list_tile.dart` | emoji → 彩色圆底图标 |
| `lib/screens/vault_screen.dart` | 搜索栏样式、空状态图标、FAB 样式 |
| `lib/screens/item_detail_screen.dart` | 卡片字段行样式、按钮样式 |
| `lib/screens/add_edit_item_screen.dart` | 输入框样式、Chip 样式 |
| `lib/screens/create_password_screen.dart` | 按钮、输入框统一 |
| `lib/screens/lock_screen.dart` | 解锁按钮、输入框统一 |
| `lib/screens/settings_screen.dart` | 列表间距统一 |
| `lib/screens/search_screen.dart` | 搜索框质感 |
| `lib/widgets/type_filter_bar.dart` | Chip 样式 |
| `lib/widgets/folder_filter_bar.dart` | Chip 样式 |
| `lib/widgets/field_row.dart` | 复制按钮样式 |
| `lib/app.dart` | 页面转场动画 |

### 8.2 不修改的文件
```
lib/models/         — 数据模型
lib/services/       — 业务逻辑
lib/utils/          — 工具函数
test/               — 测试
```

---

## 九、一键填入（额外功能）

在优化的同时，增加之前确认的一键填入标签：

- 新文件 `lib/widgets/quick_fill_chips.dart`
- 在 `add_edit_item_screen.dart` 中插入一行标签组件
- 不需要 `font_awesome_flutter` 也能用——先用带颜色的文字 Chip + 平台首字作为图标

---

## 十、实施计划

| 序号 | 步骤 | 文件数 |
|------|------|--------|
| 1 | 重写主题 (`app_theme.dart`) — 配色/间距/字体/动效 | 1 |
| 2 | 升级列表图标 + 类型图标（emoji → Material） | 1 |
| 3 | 组件级抛光（按钮/输入框/Chip/卡片） | 5 |
| 4 | 页面级抛光（各 Screen 画面对齐新规范） | 6 |
| 5 | 添加一键填入标签组件 | 2 |
| 6 | 动效补充（页面转场 + 列表加载） | 1 |
| 7 | `flutter analyze` 验证 | — |

共约 **14 个文件**，全部限定在 UI 层。

---

## 十一、对比预览

| 维度 | 当前 | 优化后 |
|------|------|--------|
| 配色 | Material3 动态色 | 手工蓝灰色板 |
| 卡片 | 无边框，默认阴影 | 微边框 + 精密阴影 |
| 图标 | Emoji (🔑💳) | Material 彩色圆底图标 |
| 圆角 | 12px 统一 | 分组件差异化（6-16px） |
| 间距 | 随意 | 4px 网格系统 |
| 动效 | 无 | 转场 + 交错加载 + 按下反馈 |
| 按钮 | 系统默认 | 手工调色 + 圆角 + 高度规范 |
| 输入框 | 填充色 | 聚焦边框动画 |

---

> **确认后，按上述次序逐步实施，不变动任何业务逻辑。**

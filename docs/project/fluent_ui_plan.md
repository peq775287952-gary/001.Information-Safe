# Windows 端 Fluent UI 改造方案

> 状态：待实施 | 创建日期：2026-05-28 | 版本：v1.0

---

## 1. 背景

当前 InfoVault 的 Android 和 Windows 端共用同一套 Material Design UI。Material Design 在 Windows 桌面上显得突兀：
- 底部导航栏是手机交互模式
- 添加条目用 BottomSheet（底部弹窗）
- 整体布局偏窄，没有利用宽屏空间
- 缺少 hover、右键菜单等桌面交互

## 2. 目标

使用微软 Fluent UI Design System 改造 Windows 端，使其获得 Windows 11 原生外观和交互体验，同时不影响 Android 端。

## 3. 技术方案

### 3.1 架构：平台分流

```
main.dart
  ├── Platform.isWindows? → app_windows.dart (FluentApp)
  └── else → app.dart (MaterialApp，保持不变)
```

- Android: `MaterialApp` + `NavigationBar`（底部导航）— **零改动**
- Windows: `FluentApp` + `NavigationView`（侧边栏）— **全新实现**
- 共享层: Service、Model、Provider、Utils — **完全复用**

### 3.2 依赖

```yaml
# pubspec.yaml
dependencies:
  fluent_ui: ^4.15.1
  system_theme: ^2.3.1
  flutter_acrylic: ^1.0.0+2
```

- `fluent_ui`: Fluent Design 组件库
- `system_theme`: 读取 Windows 系统主题色
- `flutter_acrylic`: 窗口亚克力/透明效果

**要求**: Flutter >=3.32.0, Dart >=3.8.0, stable channel

### 3.3 Widget 映射表

| Material Widget | Fluent Widget | 用途 |
|----------------|---------------|------|
| `MaterialApp` | `FluentApp` | 根组件 |
| `Scaffold` | `ScaffoldPage` | 页面骨架 |
| `AppBar` | `NavigationAppBar` | 顶部栏 |
| `NavigationBar`（底部） | `NavigationPane`（侧边） | 导航 |
| `TextField` | `TextBox` | 输入框 |
| `ElevatedButton` | `Button` / `FilledButton` | 按钮 |
| `AlertDialog` | `ContentDialog` | 对话框 |
| `SnackBar` | `InfoBar` | 提示信息 |
| `Switch` | `ToggleSwitch` | 开关 |
| `CircularProgressIndicator` | `ProgressRing` | 加载指示器 |
| `FilterChip` | `ToggleButton` | 筛选标签 |
| `DropdownButton` | `ComboBox` | 下拉选择 |
| `BottomSheet` | `ContentDialog` | 弹窗 |
| `ListTile` | `ListTile` | 列表项 |
| `SwitchListTile` | `SwitchListTile` | 开关列表项 |

## 4. 文件变更清单

### 4.1 新建文件

| 文件路径 | 说明 |
|---------|------|
| `lib/app_windows.dart` | Windows 端 FluentApp 入口，含 Consumer 路由（CreatePassword/Lock/MainShell） |
| `lib/theme/fluent_theme.dart` | FluentThemeData 配置，品牌蓝 #2563EB，亮/暗色 |
| `lib/screens/windows/main_shell_win.dart` | NavigationView + 3个 PaneItem + 锁定按钮 |
| `lib/screens/windows/vault_screen_win.dart` | 宽屏主界面：左侧筛选栏 + 右侧网格列表 |
| `lib/screens/windows/add_item_dialog.dart` | ContentDialog 类型选择（5种类型卡片） |
| `lib/screens/windows/search_screen_win.dart` | ScaffoldPage + 搜索框 + 结果列表 |
| `lib/screens/windows/settings_screen_win.dart` | Fluent 风格设置页（Expander 分组） |

### 4.2 修改文件

| 文件路径 | 改动内容 |
|---------|---------|
| `pubspec.yaml` | 添加 fluent_ui, system_theme, flutter_acrylic 依赖 |
| `lib/main.dart` | 添加 `Platform.isWindows` 分流，Windows 导入 app_windows.dart |

### 4.3 不改动的文件（100% 复用）

| 层级 | 路径 |
|------|------|
| 数据层 | `lib/services/database_service.dart`, `lib/services/encryption_service.dart` |
| 业务层 | `lib/services/vault_service.dart`, `lib/services/auth_service.dart`, `lib/services/photo_service.dart`, `lib/services/export_import_service.dart`, `lib/services/smart_category_service.dart` |
| 模型层 | `lib/models/vault_item.dart`, `lib/models/item_type.dart`, `lib/models/folder.dart` |
| 工具层 | `lib/utils/validators.dart`, `lib/utils/constants.dart`, `lib/utils/brand_icons.dart`, `lib/utils/platform_utils.dart` |
| 状态管理 | `lib/providers/auth_service.dart`, `lib/providers/vault_service.dart` |
| Android 端 | `lib/screens/` 全部现有文件, `lib/widgets/` 全部, `lib/app.dart`, `lib/theme/app_theme.dart` |

## 5. 详细实施步骤

### 阶段 1：基础设施（3 步）

#### 步骤 1：添加依赖
- 编辑 `pubspec.yaml`，在 dependencies 下添加：
  ```yaml
  fluent_ui: ^4.15.1
  system_theme: ^2.3.1
  flutter_acrylic: ^1.0.0+2
  ```
- 运行 `flutter pub get`

#### 步骤 2：创建 Fluent 主题
- 新建 `lib/theme/fluent_theme.dart`
- 定义 `lightTheme` 和 `darkTheme`（`FluentThemeData`）
- 品牌色 `AccentColor.swatch` 使用 #2563EB 色系
- 复用 `app_theme.dart` 中的颜色常量（brandBlue, typeColors 等）

```dart
import 'package:fluent_ui/fluent_ui.dart';

class FluentAppTheme {
  static final lightTheme = FluentThemeData(
    brightness: Brightness.light,
    accentColor: AccentColor.swatch({
      'darkest': Color(0xFF1A4D8F),
      'darker': Color(0xFF1D5BA6),
      'dark': Color(0xFF2162BD),
      'normal': Color(0xFF2563EB),
      'light': Color(0xFF4A83F2),
      'lighter': Color(0xFF7AA3F5),
      'lightest': Color(0xFFB3CCFA),
    }),
    visualDensity: VisualDensity.standard,
  );

  static final darkTheme = FluentThemeData(
    brightness: Brightness.dark,
    accentColor: AccentColor.swatch({
      'darkest': Color(0xFF1A4D8F),
      'darker': Color(0xFF1D5BA6),
      'dark': Color(0xFF2162BD),
      'normal': Color(0xFF2563EB),
      'light': Color(0xFF4A83F2),
      'lighter': Color(0xFF7AA3F5),
      'lightest': Color(0xFFB3CCFA),
    }),
    visualDensity: VisualDensity.standard,
  );
}
```

#### 步骤 3：创建平台分流入口
- 修改 `lib/main.dart`，在 runApp 之前判断平台
- Windows: `runApp(const InfoVaultAppWindows())`
- 其他: `runApp(const InfoVaultApp())`

```dart
// main.dart
import 'dart:io' show Platform;

void main() async {
  // ... 现有初始化代码 ...

  if (Platform.isWindows) {
    runApp(const InfoVaultAppWindows());
  } else {
    runApp(const InfoVaultApp());
  }
}
```

### 阶段 2：Windows 导航框架（3 步）

#### 步骤 4：创建 MainShellWin
- 新建 `lib/screens/windows/main_shell_win.dart`
- 使用 `NavigationView`，`PaneDisplayMode.auto`（窄屏自动折叠）
- 3 个 `PaneItem`：信息保险箱、搜索、我的
- `footerItems`：锁定按钮
- `NavigationBody` + `IndexedStack` 保持页面状态

```dart
class MainShellWin extends StatefulWidget { ... }

class _MainShellWinState extends State<MainShellWin> {
  int _selectedIndex = 0;

  @override
  Widget build(BuildContext context) {
    return NavigationView(
      appBar: NavigationAppBar(
        title: const Text('信息保险箱'),
        automaticallyImplyLeading: false,
      ),
      pane: NavigationPane(
        selected: _selectedIndex,
        onChanged: (index) => setState(() => _selectedIndex = index),
        displayMode: PaneDisplayMode.auto,
        items: [
          PaneItem(icon: const Icon(FluentIcons.shield, ), title: const Text('信息保险箱')),
          PaneItem(icon: const Icon(FluentIcons.search), title: const Text('搜索')),
          PaneItem(icon: const Icon(FluentIcons.contact), title: const Text('我的')),
        ],
        footerItems: [
          PaneItemAction(
            icon: const Icon(FluentIcons.lock),
            title: const Text('锁定'),
            onTap: () => context.read<AuthService>().lock(),
          ),
        ],
      ),
      content: NavigationBody(
        index: _selectedIndex,
        children: const [
          VaultScreenWin(),
          SearchScreenWin(),
          SettingsScreenWin(),
        ],
      ),
    );
  }
}
```

#### 步骤 5：适配 VaultScreen 到宽屏
- 新建 `lib/screens/windows/vault_screen_win.dart`
- 宽屏两栏布局：
  - 左侧：分类筛选（竖向 FilterChip 列表）+ 文件夹
  - 右侧：条目网格列表（`GridView` 或 `Wrap`）
- 顶部工具栏：搜索框 + 添加按钮（替代 FAB）
- 复用 `VaultService` 的数据和方法

#### 步骤 6：适配 SearchScreen 和 SettingsScreen
- 新建 `lib/screens/windows/search_screen_win.dart`
  - `ScaffoldPage` + `TextBox` 搜索框 + 分组结果列表
- 新建 `lib/screens/windows/settings_screen_win.dart`
  - `ScaffoldPage` + `Expander` 分组（安全/数据/关于）
  - `ToggleSwitch` 替代 `Switch`
  - `InfoBar` 替代 `SnackBar`

### 阶段 3：添加条目流程（3 步）

#### 步骤 7：创建类型选择对话框
- 新建 `lib/screens/windows/add_item_dialog.dart`
- `ContentDialog` 居中显示 5 种类型卡片
- 每种类型：图标 + 文字 + 点击回调

```dart
Future<ItemType?> showAddItemTypeDialog(BuildContext context) {
  return showDialog<ItemType>(
    context: context,
    builder: (context) => ContentDialog(
      title: const Text('选择类型'),
      content: Wrap(
        spacing: 12, runSpacing: 12,
        children: ItemType.values.map((type) => _TypeCard(
          type: type,
          onTap: () => Navigator.pop(context, type),
        )).toList(),
      ),
      actions: [
        Button(
          child: const Text('取消'),
          onPressed: () => Navigator.pop(context),
        ),
      ],
    ),
  );
}
```

#### 步骤 8：适配 AddEditItemScreen
- 在 `lib/screens/windows/` 下创建 Windows 版添加/编辑页面
- 或在现有 `add_edit_item_screen.dart` 中通过 `Platform.isWindows` 条件渲染
- `TextBox` 替代 `TextField`，`Button`/`FilledButton` 替代 Material 按钮
- 表单验证逻辑、保存逻辑完全复用 VaultService

#### 步骤 9：适配 ItemDetailScreen
- 宽屏左右两栏布局
- 左侧：字段列表（FieldRow 复用）
- 右侧：照片展示
- 返回按钮 + 编辑按钮

### 阶段 4：对话框和交互（2 步）

#### 步骤 10：替换所有对话框
全局搜索并替换：
- `showDialog` + `AlertDialog` → `ContentDialog`
- `SimpleDialog` → `ContentDialog` + `RadioListTile`
- `showBottomSheet` → `ContentDialog`
- `ScaffoldMessenger.showSnackBar` → `DisplayInfoBar.show`

#### 步骤 11：桌面交互增强
- 锁屏页面：Fluent 风格 `TextBox` + `FilledButton`
- 创建密码页面：同上
- 增大桌面端间距和字号（`VisualDensity.standard`）
- 密码输入框使用 Fluent `TextBox` + 图标

### 阶段 5：收尾（2 步）

#### 步骤 12：构建验证
```bash
# Windows
cd infovault && flutter build windows --release

# Android（确认不受影响）
cd infovault && flutter build apk --release --split-per-abi
```

#### 步骤 13：清理和文档
- 删除不再需要的临时文件
- 更新 CHANGELOG.md（v1.2.0）
- 更新 README.md
- 确认 142 个单元测试仍然通过

## 6. 注意事项

1. **fluent_ui 不兼容 Material widgets** — Windows 端不能混用，所有 Material 组件必须替换为 Fluent 对应组件
2. **Flutter 版本** — 需要 >=3.32.0，如果当前版本较低需先升级
3. **paneBodyBuilder** — v4.4.1 后签名从 `(child)` 变为 `(item, child)`，注意适配
4. **Acrylic 效果** — 需要 `flutter_acrylic` 配合 `system_theme`，Windows 10+ 才支持
5. **单元测试** — 142 个测试主要测业务逻辑（Service/Model），不应受 UI 改造影响
6. **工作量估计** — 约 10-15 个新文件 + 3-4 个文件修改，预计 3-5 天完成
7. **现有 Android 测试** — `integration_test/app_test.dart` 不需要修改

# Phase 2: Windows 桌面版 实现计划

> **For agentic workers:** 按 Task 顺序执行，每步完成后检查 checkbox。

**Goal:** 将信息保险箱从 Android-only 扩展为 Android + Windows 双平台应用，支持 Windows Hello 生物识别解锁

**Architecture:** 
- sqflite 通过 `sqflite_common_ffi` 在 Windows 上工作（sqlite3.dll 需随应用分发）
- `local_auth` 包统一 Android 指纹/Windows Hello 生物识别接口
- `BiometricService` 封装平台差异，提供统一的 `authenticate()` 方法
- 通过 `dart:io` 的 `Platform.isWindows` / `Platform.isAndroid` 做平台分支

**Tech Stack:** Flutter 3.38.6, sqflite_common_ffi, local_auth, flutter_secure_storage

**当前版本:** v1.1.3+12 → 目标 v1.2.0+13

---

## 文件结构

| 操作 | 文件 | 职责 |
|------|------|------|
| 修改 | `infovault/pubspec.yaml` | sqflite_common_ffi 升为 dependency，加 local_auth |
| 修改 | `infovault/lib/main.dart` | Windows 上初始化 sqflite FFI |
| 修改 | `infovault/lib/services/database_service.dart` | 桌面端用 databaseFactoryFfi |
| 修改 | `infovault/lib/services/auth_service.dart` | 添加 `authenticateWithBiometrics()` 方法 |
| 新增 | `infovault/lib/services/biometric_service.dart` | 生物识别封装（Windows Hello + Android） |
| 修改 | `infovault/lib/screens/lock_screen.dart` | 添加 Windows Hello 解锁按钮 |
| 修改 | `infovault/lib/screens/settings_screen.dart` | 添加 Windows Hello 开关设置项 |
| 修改 | `infovault/lib/app.dart` | 平台判断 edge-to-edge 仅 Android |
| 修改 | `infovault/lib/utils/constants.dart` | 添加 biometric 相关 key 常量 |
| 新增 | `infovault/test/services/biometric_service_test.dart` | 生物识别服务单元测试 |
| 修改 | `infovault/test/services/auth_service_test.dart` | 新增 biometric 相关测试 |
| 修改 | `infovault/test/screens/lock_screen_test.dart` | 新增 Windows Hello 按钮测试 |
| 修改 | `infovault/test/screens/settings_screen_test.dart` | 新增 Windows Hello 开关测试 |

---

### Task 1: 依赖项升级

**Files:**
- Modify: `infovault/pubspec.yaml`

- [ ] **Step 1: 移动 sqflite_common_ffi 到 dependencies，添加 local_auth**

在 `infovault/pubspec.yaml` 中：

将 `sqflite_common_ffi: ^2.3.4+4` 从 `dev_dependencies` 移到 `dependencies`。

在 `dependencies` 中添加 `local_auth: ^2.3.0`。

修改后的 dependencies 部分：

```yaml
dependencies:
  flutter:
    sdk: flutter
  flutter_localizations:
    sdk: flutter
  intl: ^0.20.2
  provider: ^6.1.2
  flutter_secure_storage: ^9.2.4
  sqflite: ^2.4.2
  sqflite_common_ffi: ^2.3.4+4
  path_provider: ^2.1.5
  path: ^1.9.1
  image_picker: ^1.1.2
  uuid: ^4.5.1
  crypto: ^3.0.6
  encrypt: ^5.0.3
  font_awesome_flutter: ^10.7.0
  flutter_svg: ^2.0.17
  file_picker: ^11.0.2
  pointycastle: ^3.9.1
  package_info_plus: ^8.1.0
  local_auth: ^2.3.0
```

- [ ] **Step 2: 安装依赖**

```bash
cd infovault && flutter pub get
```

---

### Task 2: 平台工具函数

**Files:**
- Create: `infovault/lib/utils/platform_utils.dart`

- [ ] **Step 1: 创建平台工具文件**

```dart
import 'dart:io' show Platform;

/// 是否为桌面平台（Windows / macOS / Linux）
bool get isDesktop => Platform.isWindows || Platform.isMacOS || Platform.isLinux;

/// 是否为移动平台（Android / iOS）
bool get isMobile => Platform.isAndroid || Platform.isIOS;
```

- [ ] **Step 2: 运行 analyze 确认无编译错误**

```bash
cd infovault && flutter analyze lib/utils/platform_utils.dart
```

---

### Task 3: sqflite Windows FFI 适配

**Files:**
- Modify: `infovault/lib/main.dart`
- Modify: `infovault/lib/services/database_service.dart`

- [ ] **Step 1: 修改 main.dart，Windows 上初始化 sqflite FFI**

在 `lib/main.dart` 的 `main()` 函数中，`WidgetsFlutterBinding.ensureInitialized()` 之后添加：

```dart
import 'dart:io' show Platform;
import 'package:sqflite_common_ffi/sqflite_common_ffi.dart';
```

在 `ensureInitialized()` 之后添加：

```dart
if (Platform.isWindows || Platform.isLinux || Platform.isMacOS) {
  sqfliteFfiInit();
}
```

- [ ] **Step 2: 修改 database_service.dart，桌面端使用 databaseFactoryFfi**

在 `lib/services/database_service.dart` 顶部添加 import：

```dart
import 'dart:io' show Platform;
import 'package:sqflite_common_ffi/sqflite_common_ffi.dart';
```

修改 `_initDatabase()` 方法，桌面端使用 FFI factory：

```dart
Future<Database> _initDatabase() async {
  if (Platform.isWindows || Platform.isLinux || Platform.isMacOS) {
    final dbPath = await getDatabasesPath();
    final path = p.join(dbPath, _dbName);
    return await databaseFactoryFfi.openDatabase(
      path,
      options: OpenDatabaseOptions(
        version: AppConstants.dbVersion,
        onCreate: _onCreate,
        onUpgrade: _onUpgrade,
      ),
    );
  }
  // Android/iOS: use default sqflite
  final dbPath = await getDatabasesPath();
  final path = p.join(dbPath, _dbName);
  return await openDatabase(
    path,
    version: AppConstants.dbVersion,
    onCreate: _onCreate,
    onUpgrade: _onUpgrade,
  );
}
```

- [ ] **Step 3: 运行现有测试确认无回归**

```bash
cd infovault && flutter test
```

预期：142 tests, 0 failures

---

### Task 4: 生物识别服务

**Files:**
- Create: `infovault/lib/services/biometric_service.dart`
- Modify: `infovault/lib/utils/constants.dart`

- [ ] **Step 1: 添加常量**

在 `lib/utils/constants.dart` 的 `AppConstants` 类中添加：

```dart
static const String biometricEnabledKey = 'biometric_enabled';
```

- [ ] **Step 2: 创建 BiometricService**

```dart
import 'package:flutter/foundation.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:local_auth/local_auth.dart';
import '../utils/constants.dart';

class BiometricService extends ChangeNotifier {
  final _localAuth = LocalAuthentication();
  final _secureStorage = const FlutterSecureStorage();

  bool _isEnabled = false;
  bool _isAvailable = false;
  List<BiometricType> _availableBiometrics = [];

  bool get isEnabled => _isEnabled;
  bool get isAvailable => _isAvailable;

  /// 初始化：检查设备是否支持生物识别
  Future<void> initialize() async {
    try {
      _isAvailable = await _localAuth.canCheckBiometrics;
      if (_isAvailable) {
        _availableBiometrics = await _localAuth.getAvailableBiometrics();
      }
    } catch (_) {
      _isAvailable = false;
    }

    final stored = await _secureStorage.read(key: AppConstants.biometricEnabledKey);
    _isEnabled = stored == 'true' && _isAvailable;
  }

  /// 启用/禁用生物识别
  Future<void> setEnabled(bool enabled) async {
    _isEnabled = enabled;
    await _secureStorage.write(key: AppConstants.biometricEnabledKey, value: enabled.toString());
    notifyListeners();
  }

  /// 执行生物识别认证
  /// 返回 true 表示认证成功
  Future<bool> authenticate() async {
    if (!_isEnabled || !_isAvailable) return false;

    try {
      return await _localAuth.authenticate(
        localizedReason: '请验证身份以解锁信息保险箱',
        options: const AuthenticationOptions(
          stickyAuth: true,
          biometricOnly: true,
        ),
      );
    } catch (_) {
      return false;
    }
  }

  /// 获取可用生物识别类型的描述文本
  String get biometricTypeLabel {
    if (_availableBiometrics.isEmpty) return '生物识别';
    if (_availableBiometrics.contains(BiometricType.face)) return '面部识别';
    if (_availableBiometrics.contains(BiometricType.fingerprint)) return '指纹识别';
    if (_availableBiometrics.contains(BiometricType.iris)) return '虹膜识别';
    return 'Windows Hello';
  }
}
```

- [ ] **Step 3: 运行 analyze**

```bash
cd infovault && flutter analyze lib/services/biometric_service.dart
```

---

### Task 5: AuthService 集成生物识别

**Files:**
- Modify: `infovault/lib/services/auth_service.dart`

- [ ] **Step 1: 添加 BiometricService 引用**

在 `lib/services/auth_service.dart` 中：

添加 import：
```dart
import 'biometric_service.dart';
```

添加字段和 setter：
```dart
BiometricService? _biometricService;

void setBiometricService(BiometricService biometricService) {
  _biometricService = biometricService;
}
```

添加生物识别认证方法：
```dart
/// 使用生物识别尝试解锁
Future<bool> authenticateWithBiometrics() async {
  if (_biometricService == null) return false;
  final ok = await _biometricService!.authenticate();
  if (!ok) return false;

  // 生物识别成功后，从安全存储加载主密钥并解锁
  final keyEncoded = await _secureStorage.read(key: 'master_encryption_key');
  if (keyEncoded == null) return false;

  final derivedKey = Uint8List.fromList(base64.decode(keyEncoded));
  _isUnlocked = true;
  await _vaultService?.setEncryptionKey(derivedKey);
  notifyListeners();
  return true;
}
```

需要确保 `Uint8List` 已 import（已有 `dart:convert` 和 `dart:typed_data`，检查是否已有 `Uint8List` 相关 import — 当前文件已有 `dart:convert` 但缺少 `dart:typed_data`，因为 `Uint8List` 在 `verifyMasterPassword` 中已使用 salt，检查 import）。

查看当前 auth_service.dart 的 import，它没有显式 import `dart:typed_data`，但使用了 `Uint8List.fromList(base64.decode(saltEncoded))`。需要添加：

```dart
import 'dart:typed_data';
```

- [ ] **Step 2: 验证编译**

```bash
cd infovault && flutter analyze lib/services/auth_service.dart
```

---

### Task 6: main.dart 注册 BiometricService

**Files:**
- Modify: `infovault/lib/main.dart`

- [ ] **Step 1: 添加 BiometricService 初始化和 Provider**

在 `lib/main.dart` 的 `main()` 中：

添加 import：
```dart
import 'services/biometric_service.dart';
```

在 `authService.initialize()` 之前添加：
```dart
final biometricService = BiometricService();
await biometricService.initialize();
authService.setBiometricService(biometricService);
```

在 `MultiProvider` 的 providers 列表中添加：
```dart
ChangeNotifierProvider(create: (_) => biometricService),
```

修改后的 main.dart：

```dart
import 'dart:io' show Platform;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:sqflite_common_ffi/sqflite_common_ffi.dart';
import 'services/database_service.dart';
import 'services/encryption_service.dart';
import 'services/auth_service.dart';
import 'services/vault_service.dart';
import 'services/photo_service.dart';
import 'services/export_import_service.dart';
import 'services/biometric_service.dart';
import 'app.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);

  if (Platform.isWindows || Platform.isLinux || Platform.isMacOS) {
    sqfliteFfiInit();
  }

  final databaseService = DatabaseService();
  final encryptionService = EncryptionService();
  final authService = AuthService(encryptionService);
  final vaultService = VaultService(databaseService, encryptionService);
  final photoService = PhotoService(encryptionService);
  final exportImportService = ExportImportService(databaseService, encryptionService, vaultService);
  final biometricService = BiometricService();

  authService.setVaultService(vaultService);
  authService.setBiometricService(biometricService);

  await authService.initialize();
  await biometricService.initialize();

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => authService),
        ChangeNotifierProvider(create: (_) => vaultService),
        ChangeNotifierProvider(create: (_) => biometricService),
        Provider.value(value: photoService),
        Provider.value(value: exportImportService),
      ],
      child: const InfoVaultApp(),
    ),
  );
}
```

- [ ] **Step 2: 运行 analyze 确认无编译错误**

```bash
cd infovault && flutter analyze lib/main.dart
```

---

### Task 7: LockScreen 添加 Windows Hello 解锁

**Files:**
- Modify: `infovault/lib/screens/lock_screen.dart`

- [ ] **Step 1: 添加 Windows Hello 解锁按钮**

在 `lib/screens/lock_screen.dart` 中：

添加 import：
```dart
import '../services/biometric_service.dart';
```

在 `_LockScreenState` 中添加方法：
```dart
Future<void> _biometricUnlock() async {
  final auth = context.read<AuthService>();
  final ok = await auth.authenticateWithBiometrics();
  if (!ok && mounted) {
    setState(() => _errorText = '生物识别失败，请使用主密码');
  }
}
```

在 build 方法中，密码输入框和"解锁"按钮之间，添加 Windows Hello 按钮（仅在生物识别可用时显示）：

```dart
// 在 TextField 之后、"解锁"按钮之前添加：
Consumer<BiometricService>(
  builder: (context, bio, _) {
    if (!bio.isEnabled || !bio.isAvailable) return const SizedBox.shrink();
    return Padding(
      padding: const EdgeInsets.only(top: 12),
      child: OutlinedButton.icon(
        onPressed: isLocked || _isChecking ? null : _biometricUnlock,
        icon: const Icon(Icons.fingerprint, size: 20),
        label: Text(bio.biometricTypeLabel),
        style: OutlinedButton.styleFrom(
          minimumSize: const Size(double.infinity, 48),
        ),
      ),
    );
  },
),
```

- [ ] **Step 2: 验证编译**

```bash
cd infovault && flutter analyze lib/screens/lock_screen.dart
```

---

### Task 8: SettingsScreen 添加 Windows Hello 开关

**Files:**
- Modify: `infovault/lib/screens/settings_screen.dart`

- [ ] **Step 1: 添加生物识别开关设置项**

在 `lib/screens/settings_screen.dart` 中：

添加 import：
```dart
import '../services/biometric_service.dart';
```

在安全设置区域（`_SectionHeader(title: '安全')` 下方，`SwitchListTile` 自动锁定之后）添加：

```dart
Consumer<BiometricService>(
  builder: (context, bio, _) {
    if (!bio.isAvailable) return const SizedBox.shrink();
    return SwitchListTile(
      secondary: const Icon(Icons.fingerprint),
      title: Text(bio.biometricTypeLabel),
      subtitle: const Text('使用生物识别快速解锁'),
      value: bio.isEnabled,
      onChanged: (v) => bio.setEnabled(v),
    );
  },
),
```

放在自动锁定 `SwitchListTile` 和 `if (_autoLockEnabled) ListTile(...)` 之间。

- [ ] **Step 2: 验证编译**

```bash
cd infovault && flutter analyze lib/screens/settings_screen.dart
```

---

### Task 9: 平台 UI 适配

**Files:**
- Modify: `infovault/lib/app.dart`

- [ ] **Step 1: edge-to-edge 仅 Android 执行**

在 `lib/app.dart` 中（`_MainShellState` 里没有直接设置 edge-to-edge，它在 `main.dart` 中）。

修改 `lib/main.dart`：

```dart
if (Platform.isAndroid) {
  SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
}
```

- [ ] **Step 2: 验证编译**

```bash
cd infovault && flutter analyze lib/main.dart lib/app.dart
```

---

### Task 10: Windows 构建脚本

**Files:**
- Create: `infovault/build_windows.bat`

- [ ] **Step 1: 创建 Windows 构建脚本**

```bat
@echo off
echo ========================================
echo 信息保险箱 Windows 版本构建
echo ========================================

cd /d %~dp0

echo [1/3] 递增版本号...
dart run scripts/bump_version.dart
if %ERRORLEVEL% NEQ 0 (
    echo 版本号递增失败！
    exit /b 1
)

echo [2/3] 构建 Windows Release...
flutter build windows --release
if %ERRORLEVEL% NEQ 0 (
    echo Windows 构建失败！
    exit /b 1
)

echo [3/3] 构建完成！
echo 输出目录: build\windows\x64\runner\Release\
dir build\windows\x64\runner\Release\infovault.exe
```

- [ ] **Step 2: 测试构建脚本**

```bash
cd infovault && build_windows.bat
```

---

### Task 11: 更新测试

**Files:**
- Create: `infovault/test/services/biometric_service_test.dart`
- Modify: `infovault/test/services/auth_service_test.dart`
- Modify: `infovault/test/screens/lock_screen_test.dart`
- Modify: `infovault/test/screens/settings_screen_test.dart`

- [ ] **Step 1: 创建 BiometricService 单元测试**

```dart
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:infovault/services/biometric_service.dart';
import 'package:infovault/utils/constants.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late BiometricService biometricService;

  setUp(() {
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(
      const MethodChannel('flutter_secure_storage'),
      (call) async {
        if (call.method == 'read') {
          return null; // 默认未启用
        }
        if (call.method == 'write') {
          return null;
        }
        return null;
      },
    );

    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(
      const MethodChannel('plugins.flutter.io/local_auth'),
      (call) async {
        if (call.method == 'canCheckBiometrics') return false;
        if (call.method == 'getAvailableBiometrics') return <String>[];
        if (call.method == 'authenticate') return false;
        return null;
      },
    );

    biometricService = BiometricService();
  });

  group('BiometricService', () {
    test('initialize with no biometrics available', () async {
      await biometricService.initialize();
      expect(biometricService.isAvailable, false);
      expect(biometricService.isEnabled, false);
    });

    test('setEnabled persists to storage', () async {
      String? writtenKey;
      String? writtenValue;

      TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
          .setMockMethodCallHandler(
        const MethodChannel('flutter_secure_storage'),
        (call) async {
          if (call.method == 'read') return null;
          if (call.method == 'write') {
            writtenKey = call.arguments['key'] as String?;
            writtenValue = call.arguments['value'] as String?;
            return null;
          }
          return null;
        },
      );

      await biometricService.setEnabled(true);
      expect(biometricService.isEnabled, true);
      expect(writtenKey, AppConstants.biometricEnabledKey);
      expect(writtenValue, 'true');
    });
  });
}
```

- [ ] **Step 2: 更新 auth_service_test.dart**

在 `test/services/auth_service_test.dart` 中添加测试：

检查现有的 auth_service_test.dart：
```dart
// 在现有 test group 中添加：
test('setBiometricService does not throw', () {
  final biometricService = BiometricService();
  expect(() => authService.setBiometricService(biometricService), returnsNormally);
});

test('authenticateWithBiometrics returns false when no biometric service', () async {
  final result = await authService.authenticateWithBiometrics();
  expect(result, false);
});
```

- [ ] **Step 3: 更新 lock_screen_test.dart**

检查现有测试文件，添加 Consumer 相关的 widget 测试。需确保 `BiometricService` 在 Provider 树中。

在 `test/screens/lock_screen_test.dart` 中，更新 Provider wrapping：

```dart
// 在 setUp 或 pumpWidget 中添加 BiometricService provider
ChangeNotifierProvider(create: (_) => BiometricService()),
```

- [ ] **Step 4: 更新 settings_screen_test.dart**

类似地，确保 SettingsScreen 测试中包含 BiometricService。

- [ ] **Step 5: 运行全部测试**

```bash
cd infovault && flutter test
```

预期：所有测试通过，0 failures

---

### Task 12: 运行 flutter analyze 全项目检查

- [ ] **Step 1: 全项目静态分析**

```bash
cd infovault && flutter analyze lib/ test/
```

修正所有 error 和 warning。

---

### Task 13: 版本号递增与构建验证

- [ ] **Step 1: 更新版本号**

```bash
cd infovault && dart run scripts/bump_version.dart
```

版本号应为 v1.2.0+13。

- [ ] **Step 2: 构建 Windows**

```bash
cd infovault && flutter build windows --release
```

- [ ] **Step 3: 运行 Windows 应用验证**

```bash
cd infovault && flutter run -d windows
```

验证：
- 创建主密码
- 锁定/解锁
- 生物识别设置（需要支持 Windows Hello 的设备）
- 添加/查看/编辑/删除条目
- 导出/导入
- 修改主密码

---

### Task 14: 最终测试验证

- [ ] **Step 1: 单元 + Widget 测试**

```bash
cd infovault && flutter test
```

预期：全部通过

- [ ] **Step 2: 静态分析**

```bash
cd infovault && flutter analyze lib/ test/
```

---

## 注意事项

1. **sqlite3.dll 分发**: Windows 构建时 `sqflite_common_ffi` 会自动将 `sqlite3.dll` 打包到构建输出目录
2. **Windows Hello 测试**: 需要在实际支持 Windows Hello 的 Windows 设备上测试生物识别功能；mock 测试已覆盖基本逻辑
3. **flutter_secure_storage on Windows**: 使用 Windows Credential Manager，无需额外配置
4. **窗口尺寸**: `windows/runner/main.cpp` 中默认 1280x720，可根据需要调整
5. **PUB_CACHE 环境变量**: Windows 构建不需要 PUB_CACHE 环境变量（跨盘符问题仅影响 Android Kotlin 编译）
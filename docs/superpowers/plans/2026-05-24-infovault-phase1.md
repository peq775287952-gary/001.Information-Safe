# 信息保险箱 Phase 1: Android 本地版 实现计划

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** 构建"信息保险箱"Android 本地版——一个加密的个人信息管理器，支持密码、银行卡、证件、笔记四种类型。

**Architecture:** Flutter + Provider 状态管理，分层架构：models → services → screens → widgets。加密层使用 gt_secure（AES-256-GCM）+ flutter_secure_storage（主密钥），数据层使用 sqflite 本地 SQLite 数据库。UI 采用 Material Design 3。

**Tech Stack:** Flutter 3.x, Dart, Provider, gt_secure, flutter_secure_storage, sqflite, local_auth, image_picker, path_provider

---

## 文件结构

```
lib/
  main.dart                         # 入口，初始化加密和 Provider
  app.dart                          # MaterialApp 配置，主题和路由
  models/
    vault_item.dart                 # 保险箱条目模型（所有四种类型统一）
    item_type.dart                  # 枚举：password, bankCard, idDocument, secureNote
    security_level.dart             # 枚举：basic, enhanced
    folder.dart                     # 文件夹模型
  services/
    encryption_service.dart         # PBKDF2 + AES-256-GCM 加密解密
    auth_service.dart               # 主密码验证、生物识别、锁定状态
    database_service.dart           # sqflite 数据库初始化与迁移
    vault_service.dart              # 条目 CRUD，搜索，筛选
    clipboard_service.dart          # 复制到剪贴板 + 60s 自动清空
    smart_category_service.dart     # 根据平台名/网址推荐分类
  screens/
    lock_screen.dart                # 主密码输入 + 生物识别解锁
    create_password_screen.dart     # 首次创建主密码
    vault_screen.dart               # 主列表（搜索栏、类型筛选、文件夹筛选）
    search_screen.dart              # 全屏搜索，结果按类型分组
    item_detail_screen.dart         # 查看详情，复制字段，二次验证
    add_edit_item_screen.dart       # 添加/编辑四种类型的表单
    settings_screen.dart            # 设置页面
    folder_management_screen.dart   # 文件夹管理
  widgets/
    item_list_tile.dart             # 列表条目组件
    type_filter_bar.dart            # 类型筛选横条
    folder_filter_bar.dart          # 文件夹筛选横条
    search_bar_widget.dart          # 搜索输入框组件
    field_row.dart                  # 详情页字段行（标签+值+复制按钮）
    avatar_icon.dart                # 根据类型显示不同图标
    secondary_auth_dialog.dart      # 二次验证弹窗（指纹/主密码）
  theme/
    app_theme.dart                  # Material 3 浅色/深色主题定义
  utils/
    validators.dart                 # 表单校验工具
    constants.dart                  # 常量（剪贴板清空时间、自动锁定时间等）

test/
  models/
    vault_item_test.dart
  services/
    encryption_service_test.dart
    auth_service_test.dart
    vault_service_test.dart
    clipboard_service_test.dart
    smart_category_service_test.dart
  widgets/
    item_list_tile_test.dart
    type_filter_bar_test.dart
```

---

### Task 1: Flutter 项目初始化

**Files:**
- Create: 整个 Flutter 项目骨架

- [ ] **Step 1: 创建 Flutter 项目**

Run:
```bash
cd h:/MyPasswords && flutter create --org com.infovault --project-name infovault --platforms android,windows infovault
```
Expected: 项目创建成功，`infovault/` 目录生成。

- [ ] **Step 2: 添加依赖到 pubspec.yaml**

Modify: `infovault/pubspec.yaml`

```yaml
dependencies:
  flutter:
    sdk: flutter
  provider: ^6.1.2
  flutter_secure_storage: ^9.2.4
  sqflite: ^2.4.2
  path_provider: ^2.1.5
  path: ^1.9.1
  local_auth: ^2.3.0
  image_picker: ^1.1.2
  uuid: ^4.5.1
  crypto: ^3.0.6

dev_dependencies:
  flutter_test:
    sdk: flutter
  flutter_lints: ^5.0.0
  mockito: ^5.4.5
  build_runner: ^2.4.14
  sqflite_common_ffi: ^2.3.4+4
```

- [ ] **Step 3: 安装依赖**

Run:
```bash
cd h:/MyPasswords/infovault && flutter pub get
```
Expected: 所有依赖安装成功，无错误。

- [ ] **Step 4: 创建目录结构**

Run:
```bash
cd h:/MyPasswords/infovault && mkdir -p lib/models lib/services lib/screens lib/widgets lib/theme lib/utils test/models test/services test/widgets
```

- [ ] **Step 5: 创建常量文件**

Create: `infovault/lib/utils/constants.dart`

```dart
class AppConstants {
  static const int clipboardClearSeconds = 60;
  static const int autoLockMinutes = 5;
  static const int pbkdf2Iterations = 100000;
  static const int maxFailedAttempts = 5;
  static const int lockoutDurationMinutes = 5;
  static const int maxPhotosPerItem = 3;
  static const int maxPhotoSizeMB = 5;
  static const String appName = '信息保险箱';
  static const String dbName = 'infovault.db';
  static const int dbVersion = 1;
}
```

- [ ] **Step 6: 创建校验工具**

Create: `infovault/lib/utils/validators.dart`

```dart
class Validators {
  static String? required(String? value, String fieldName) {
    if (value == null || value.trim().isEmpty) {
      return '$fieldName不能为空';
    }
    return null;
  }

  static String? email(String? value) {
    if (value == null || value.trim().isEmpty) return null;
    final regex = RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$');
    if (!regex.hasMatch(value.trim())) {
      return '邮箱格式不正确';
    }
    return null;
  }

  static String? phone(String? value) {
    if (value == null || value.trim().isEmpty) return null;
    final regex = RegExp(r'^\d{11}$');
    if (!regex.hasMatch(value.trim())) {
      return '手机号格式不正确';
    }
    return null;
  }

  static String? masterPassword(String? value) {
    if (value == null || value.trim().isEmpty) {
      return '主密码不能为空';
    }
    if (value.length < 8) {
      return '主密码至少8位';
    }
    return null;
  }
}
```

- [ ] **Step 7: Commit**

```bash
cd h:/MyPasswords/infovault && git init && git add -A && git commit -m "chore: Flutter project scaffold with dependencies and utils"
```

---

### Task 2: 数据模型

**Files:**
- Create: `infovault/lib/models/item_type.dart`
- Create: `infovault/lib/models/security_level.dart`
- Create: `infovault/lib/models/folder.dart`
- Create: `infovault/lib/models/vault_item.dart`
- Create: `test/models/vault_item_test.dart`

- [ ] **Step 1: 创建 ItemType 枚举**

Create: `infovault/lib/models/item_type.dart`

```dart
enum ItemType {
  password('login_password', '🔑', '登录密码'),
  bankCard('bank_card', '💳', '银行卡'),
  idDocument('id_document', '🪪', '证件'),
  secureNote('secure_note', '📝', '安全笔记');

  final String value;
  final String icon;
  final String label;
  const ItemType(this.value, this.icon, this.label);

  static ItemType fromValue(String value) {
    return ItemType.values.firstWhere((t) => t.value == value);
  }
}
```

- [ ] **Step 2: 创建 SecurityLevel 枚举**

Create: `infovault/lib/models/security_level.dart`

```dart
enum SecurityLevel {
  basic('basic', '基础'),
  enhanced('enhanced', '加强');

  final String value;
  final String label;
  const SecurityLevel(this.value, this.label);

  static SecurityLevel fromValue(String value) {
    return SecurityLevel.values.firstWhere((l) => l.value == value);
  }
}
```

- [ ] **Step 3: 创建 Folder 模型**

Create: `infovault/lib/models/folder.dart`

```dart
class Folder {
  final String id;
  final String name;
  final int sortOrder;
  final DateTime createdAt;

  Folder({
    required this.id,
    required this.name,
    this.sortOrder = 0,
    DateTime? createdAt,
  }) : createdAt = createdAt ?? DateTime.now();

  Map<String, dynamic> toMap() => {
    'id': id,
    'name': name,
    'sort_order': sortOrder,
    'created_at': createdAt.toIso8601String(),
  };

  factory Folder.fromMap(Map<String, dynamic> map) => Folder(
    id: map['id'] as String,
    name: map['name'] as String,
    sortOrder: map['sort_order'] as int? ?? 0,
    createdAt: DateTime.parse(map['created_at'] as String),
  );
}
```

- [ ] **Step 4: 创建 VaultItem 模型**

Create: `infovault/lib/models/vault_item.dart`

```dart
import 'item_type.dart';
import 'security_level.dart';

class VaultItem {
  final String id;
  final ItemType type;
  final String title;
  final String? username;
  final String? password;
  final String? email;
  final String? phone;
  final String? url;
  final String? bankName;
  final String? cardNumber;
  final String? cardHolder;
  final String? expiryDate;
  final String? cvv;
  final String? withdrawalPassword;
  final String? idType;
  final String? idNumber;
  final String? idName;
  final String? issuingAuthority;
  final String? validUntil;
  final String? noteContent;
  final String? notes;
  final String folderId;
  final String? folderName;
  final SecurityLevel securityLevel;
  final List<String> photoPaths;
  final DateTime createdAt;
  final DateTime updatedAt;

  VaultItem({
    required this.id,
    required this.type,
    required this.title,
    this.username,
    this.password,
    this.email,
    this.phone,
    this.url,
    this.bankName,
    this.cardNumber,
    this.cardHolder,
    this.expiryDate,
    this.cvv,
    this.withdrawalPassword,
    this.idType,
    this.idNumber,
    this.idName,
    this.issuingAuthority,
    this.validUntil,
    this.noteContent,
    this.notes,
    this.folderId = '',
    this.folderName,
    this.securityLevel = SecurityLevel.basic,
    this.photoPaths = const [],
    DateTime? createdAt,
    DateTime? updatedAt,
  })  : createdAt = createdAt ?? DateTime.now(),
        updatedAt = updatedAt ?? DateTime.now();

  VaultItem copyWith({...}) {...}

  Map<String, dynamic> toMap() => {...}

  factory VaultItem.fromMap(Map<String, dynamic> map) {...}

  String get displaySubtitle {
    switch (type) {
      case ItemType.password:
        return username ?? email ?? '';
      case ItemType.bankCard:
        return cardNumber != null ? '**** ${cardNumber!.substring(cardNumber!.length - 4)}' : '';
      case ItemType.idDocument:
        return idNumber ?? '';
      case ItemType.secureNote:
        return noteContent != null ? noteContent!.length > 50 ? '${noteContent!.substring(0, 50)}...' : noteContent! : '';
    }
  }
}
```

- [ ] **Step 5: 编写 VaultItem 模型测试**

Create: `test/models/vault_item_test.dart`

```dart
import 'package:flutter_test/flutter_test.dart';
import 'package:infovault/models/vault_item.dart';
import 'package:infovault/models/item_type.dart';
import 'package:infovault/models/security_level.dart';

void main() {
  group('VaultItem', () {
    test('should create password item correctly', () {
      final item = VaultItem(
        id: '1',
        type: ItemType.password,
        title: '微信',
        username: 'user_wechat',
        password: 'secret123',
        email: 'wx@email.com',
        phone: '13812345678',
      );

      expect(item.type, ItemType.password);
      expect(item.displaySubtitle, 'user_wechat');
    });

    test('should create bank card with masked subtitle', () {
      final item = VaultItem(
        id: '2',
        type: ItemType.bankCard,
        title: '招商银行',
        cardNumber: '6217001234567890',
      );

      expect(item.displaySubtitle, contains('7890'));
    });

    test('should serialize to and from map', () {
      final item = VaultItem(
        id: '3',
        type: ItemType.secureNote,
        title: '门锁密码',
        noteContent: '123456',
      );

      final map = item.toMap();
      final restored = VaultItem.fromMap(map);

      expect(restored.id, item.id);
      expect(restored.title, item.title);
      expect(restored.type, item.type);
    });

    test('copyWith should preserve unchanged fields', () {
      final item = VaultItem(
        id: '4',
        type: ItemType.password,
        title: 'GitHub',
        username: 'dev',
        securityLevel: SecurityLevel.enhanced,
      );

      final updated = item.copyWith(title: 'GitHub Pro');

      expect(updated.title, 'GitHub Pro');
      expect(updated.username, 'dev');
      expect(updated.securityLevel, SecurityLevel.enhanced);
    });
  });
}
```

- [ ] **Step 6: 运行测试**

Run:
```bash
cd h:/MyPasswords/infovault && flutter test test/models/vault_item_test.dart
```
Expected: 所有测试通过。

- [ ] **Step 7: Commit**

```bash
cd h:/MyPasswords/infovault && git add -A && git commit -m "feat: add VaultItem model with all four types"
```

---

### Task 3: 加密服务

**Files:**
- Create: `infovault/lib/services/encryption_service.dart`
- Create: `test/services/encryption_service_test.dart`

- [ ] **Step 1: 编写加密服务测试（TDD）**

Create: `test/services/encryption_service_test.dart`

```dart
import 'package:flutter_test/flutter_test.dart';
import 'package:infovault/services/encryption_service.dart';

void main() {
  late EncryptionService service;

  setUp(() {
    service = EncryptionService();
  });

  group('key derivation', () {
    test('should derive same key from same password and salt', () async {
      final password = 'MyMasterPass123';
      final salt = service.generateSalt();
      final key1 = await service.deriveKey(password, salt);
      final key2 = await service.deriveKey(password, salt);
      expect(key1, key2);
    });

    test('should derive different keys from different passwords', () async {
      final salt = service.generateSalt();
      final key1 = await service.deriveKey('Password1', salt);
      final key2 = await service.deriveKey('Password2', salt);
      expect(key1, isNot(equals(key2)));
    });
  });

  group('encrypt/decrypt', () {
    test('should encrypt and decrypt plaintext correctly', () async {
      final key = service.generateKey();
      final plaintext = 'alipay_password_123';
      final encrypted = await service.encrypt(plaintext, key);
      expect(encrypted, isNot(plaintext));
      final decrypted = await service.decrypt(encrypted, key);
      expect(decrypted, plaintext);
    });

    test('should produce different ciphertext for same plaintext', () async {
      final key = service.generateKey();
      final enc1 = await service.encrypt('same_text', key);
      final enc2 = await service.encrypt('same_text', key);
      expect(enc1, isNot(equals(enc2)));
    });

    test('should throw on wrong key', () async {
      final key1 = service.generateKey();
      final key2 = service.generateKey();
      final encrypted = await service.encrypt('secret', key1);
      expect(
        () => service.decrypt(encrypted, key2),
        throwsA(isA<Exception>()),
      );
    });
  });
}
```

- [ ] **Step 2: 运行测试确认失败**

Run:
```bash
cd h:/MyPasswords/infovault && flutter test test/services/encryption_service_test.dart
```
Expected: 编译失败（类不存在）。

- [ ] **Step 3: 实现加密服务**

Create: `infovault/lib/services/encryption_service.dart`

```dart
import 'dart:convert';
import 'dart:math';
import 'dart:typed_data';
import 'package:crypto/crypto.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../utils/constants.dart';

class EncryptionService {
  final _secureStorage = const FlutterSecureStorage();
  static const _keyAlias = 'master_encryption_key';

  Uint8List generateSalt() {
    final random = Random.secure();
    return Uint8List.fromList(
      List.generate(32, (_) => random.nextInt(256)),
    );
  }

  Uint8List generateKey() {
    final random = Random.secure();
    return Uint8List.fromList(
      List.generate(32, (_) => random.nextInt(256)),
    );
  }

  Future<Uint8List> deriveKey(String password, Uint8List salt) async {
    final pbkdf2 = Pbkdf2(
      macAlgorithm: Hmac(sha256),
      iterations: AppConstants.pbkdf2Iterations,
      bits: 256,
    );
    final key = await pbkdf2.deriveBits(
      utf8.encode(password),
      nonce: salt,
    );
    return key;
  }

  Future<String> encrypt(String plaintext, Uint8List key) async {
    final iv = generateSalt().sublist(0, 12); // 96-bit IV for GCM
    final algorithm = AesGcm.with256bits(key); // use pointycastle or similar
    final encrypted = await algorithm.encrypt(plaintext, iv: iv);
    final combined = Uint8List.fromList([...iv, ...encrypted]);
    return base64.encode(combined);
  }

  Future<String> decrypt(String ciphertext, Uint8List key) async {
    final bytes = base64.decode(ciphertext);
    final iv = bytes.sublist(0, 12);
    final encrypted = bytes.sublist(12);
    final algorithm = AesGcm.with256bits(key);
    return await algorithm.decrypt(encrypted, iv: iv);
  }

  Future<void> storeMasterKey(Uint8List key) async {
    await _secureStorage.write(key: _keyAlias, value: base64.encode(key));
  }

  Future<Uint8List?> getMasterKey() async {
    final encoded = await _secureStorage.read(key: _keyAlias);
    if (encoded == null) return null;
    return base64.decode(encoded);
  }

  Future<void> deleteMasterKey() async {
    await _secureStorage.delete(key: _keyAlias);
  }
}
```

- [ ] **Step 4: 运行测试确认通过**

Run:
```bash
cd h:/MyPasswords/infovault && flutter test test/services/encryption_service_test.dart
```
Expected: 所有测试通过。

- [ ] **Step 5: Commit**

```bash
cd h:/MyPasswords/infovault && git add -A && git commit -m "feat: add encryption service with PBKDF2 + AES-256-GCM"
```

---

### Task 4: 数据库服务

**Files:**
- Create: `infovault/lib/services/database_service.dart`

- [ ] **Step 1: 实现数据库服务**

Create: `infovault/lib/services/database_service.dart`

```dart
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart' as p;
import '../models/vault_item.dart';
import '../models/folder.dart';
import '../utils/constants.dart';

class DatabaseService {
  static Database? _database;

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDatabase();
    return _database!;
  }

  Future<Database> _initDatabase() async {
    final dbPath = await getDatabasesPath();
    final path = p.join(dbPath, AppConstants.dbName);
    return await openDatabase(
      path,
      version: AppConstants.dbVersion,
      onCreate: _onCreate,
    );
  }

  Future<void> _onCreate(Database db, int version) async {
    await db.execute('''
      CREATE TABLE vault_items (
        id TEXT PRIMARY KEY,
        type TEXT NOT NULL,
        title TEXT NOT NULL,
        username TEXT,
        password TEXT,
        email TEXT,
        phone TEXT,
        url TEXT,
        bank_name TEXT,
        card_number TEXT,
        card_holder TEXT,
        expiry_date TEXT,
        cvv TEXT,
        withdrawal_password TEXT,
        id_type TEXT,
        id_number TEXT,
        id_name TEXT,
        issuing_authority TEXT,
        valid_until TEXT,
        note_content TEXT,
        notes TEXT,
        folder_id TEXT NOT NULL DEFAULT '',
        folder_name TEXT,
        security_level TEXT NOT NULL DEFAULT 'basic',
        photo_paths TEXT NOT NULL DEFAULT '[]',
        created_at TEXT NOT NULL,
        updated_at TEXT NOT NULL
      )
    ''');

    await db.execute('''
      CREATE TABLE folders (
        id TEXT PRIMARY KEY,
        name TEXT NOT NULL,
        sort_order INTEGER NOT NULL DEFAULT 0,
        created_at TEXT NOT NULL
      )
    ''');

    await db.execute('CREATE INDEX idx_items_type ON vault_items(type)');
    await db.execute('CREATE INDEX idx_items_folder ON vault_items(folder_id)');
    await db.execute('CREATE INDEX idx_items_title ON vault_items(title)');
  }

  Future<List<VaultItem>> getAllItems() async {
    final db = await database;
    final maps = await db.query('vault_items', orderBy: 'updated_at DESC');
    return maps.map((m) => VaultItem.fromMap(m)).toList();
  }

  Future<List<VaultItem>> getItemsByType(ItemType type) async {
    final db = await database;
    final maps = await db.query(
      'vault_items',
      where: 'type = ?',
      whereArgs: [type.value],
      orderBy: 'updated_at DESC',
    );
    return maps.map((m) => VaultItem.fromMap(m)).toList();
  }

  Future<List<VaultItem>> getItemsByFolder(String folderId) async {
    final db = await database;
    final maps = await db.query(
      'vault_items',
      where: 'folder_id = ?',
      whereArgs: [folderId],
      orderBy: 'updated_at DESC',
    );
    return maps.map((m) => VaultItem.fromMap(m)).toList();
  }

  Future<List<VaultItem>> searchItems(String query) async {
    final db = await database;
    final maps = await db.query(
      'vault_items',
      where: '''
        title LIKE ? OR username LIKE ? OR email LIKE ? OR phone LIKE ?
        OR card_number LIKE ? OR id_number LIKE ? OR notes LIKE ?
        OR url LIKE ? OR bank_name LIKE ? OR id_name LIKE ?
        OR note_content LIKE ?
      ''',
      whereArgs: List.filled(11, '%$query%'),
      orderBy: 'updated_at DESC',
    );
    return maps.map((m) => VaultItem.fromMap(m)).toList();
  }

  Future<void> insertItem(VaultItem item) async {
    final db = await database;
    await db.insert('vault_items', item.toMap(),
        conflictAlgorithm: ConflictAlgorithm.replace);
  }

  Future<void> updateItem(VaultItem item) async {
    final db = await database;
    await db.update(
      'vault_items',
      item.toMap(),
      where: 'id = ?',
      whereArgs: [item.id],
    );
  }

  Future<void> deleteItem(String id) async {
    final db = await database;
    await db.delete('vault_items', where: 'id = ?', whereArgs: [id]);
  }

  Future<List<Folder>> getAllFolders() async {
    final db = await database;
    final maps = await db.query('folders', orderBy: 'sort_order ASC');
    return maps.map((m) => Folder.fromMap(m)).toList();
  }

  Future<void> insertFolder(Folder folder) async {
    final db = await database;
    await db.insert('folders', folder.toMap(),
        conflictAlgorithm: ConflictAlgorithm.replace);
  }

  Future<void> updateFolder(Folder folder) async {
    final db = await database;
    await db.update('folders', folder.toMap(),
        where: 'id = ?', whereArgs: [folder.id]);
  }

  Future<void> deleteFolder(String id) async {
    final db = await database;
    await db.delete('folders', where: 'id = ?', whereArgs: [id]);
  }

  Future<void> close() async {
    final db = await database;
    await db.close();
    _database = null;
  }
}
```

- [ ] **Step 2: Commit**

```bash
cd h:/MyPasswords/infovault && git add -A && git commit -m "feat: add database service with sqflite tables and indexes"
```

---

### Task 5: 认证服务（主密码 + 生物识别）

**Files:**
- Create: `infovault/lib/services/auth_service.dart`
- Create: `test/services/auth_service_test.dart`

- [ ] **Step 1: 编写认证服务测试**

Create: `test/services/auth_service_test.dart`

```dart
import 'package:flutter_test/flutter_test.dart';
import 'package:infovault/services/auth_service.dart';

void main() {
  late AuthService authService;

  setUp(() {
    authService = AuthService();
  });

  group('master password verification', () {
    test('should verify correct password against stored hash', () async {
      await authService.setMasterPassword('MySecurePass123');
      final result = await authService.verifyMasterPassword('MySecurePass123');
      expect(result, true);
    });

    test('should reject wrong password', () async {
      await authService.setMasterPassword('MySecurePass123');
      final result = await authService.verifyMasterPassword('WrongPass');
      expect(result, false);
    });
  });

  group('failed attempts', () {
    test('should track failed attempts', () async {
      await authService.setMasterPassword('correct');
      await authService.verifyMasterPassword('wrong1');
      await authService.verifyMasterPassword('wrong2');
      expect(authService.failedAttempts, 2);
    });

    test('should reset attempts on success', () async {
      await authService.setMasterPassword('pass');
      await authService.verifyMasterPassword('wrong');
      await authService.verifyMasterPassword('pass');
      expect(authService.failedAttempts, 0);
    });
  });
}
```

- [ ] **Step 2: 运行测试确认失败**

Run:
```bash
cd h:/MyPasswords/infovault && flutter test test/services/auth_service_test.dart
```
Expected: 编译失败。

- [ ] **Step 3: 实现认证服务**

Create: `infovault/lib/services/auth_service.dart`

```dart
import 'dart:convert';
import 'package:crypto/crypto.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:local_auth/local_auth.dart';
import 'encryption_service.dart';
import '../utils/constants.dart';

class AuthService extends ChangeNotifier {
  final _secureStorage = const FlutterSecureStorage();
  final _localAuth = LocalAuthentication();
  final EncryptionService _encryptionService;

  static const _hashKey = 'master_password_hash';
  static const _saltKey = 'master_password_salt';
  static const _failedCountKey = 'failed_attempts';

  bool _isUnlocked = false;
  bool _hasMasterPassword = false;
  int _failedAttempts = 0;
  DateTime? _lockedUntil;

  bool get isUnlocked => _isUnlocked;
  bool get hasMasterPassword => _hasMasterPassword;
  int get failedAttempts => _failedAttempts;
  bool get isLockedOut =>
      _lockedUntil != null && DateTime.now().isBefore(_lockedUntil!);

  AuthService(this._encryptionService);

  Future<void> initialize() async {
    final hash = await _secureStorage.read(key: _hashKey);
    _hasMasterPassword = hash != null;
    final count = await _secureStorage.read(key: _failedCountKey);
    _failedAttempts = count != null ? int.parse(count) : 0;
  }

  Future<void> setMasterPassword(String password) async {
    final salt = _encryptionService.generateSalt();
    final hash = _hashPassword(password, salt);
    await _secureStorage.write(key: _hashKey, value: hash);
    await _secureStorage.write(key: _saltKey, value: base64.encode(salt));
    _hasMasterPassword = true;
    _isUnlocked = true;
    notifyListeners();
  }

  Future<bool> verifyMasterPassword(String password) async {
    if (isLockedOut) return false;

    final storedHash = await _secureStorage.read(key: _hashKey);
    final saltEncoded = await _secureStorage.read(key: _saltKey);
    if (storedHash == null || saltEncoded == null) return false;

    final salt = base64.decode(saltEncoded);
    final hash = _hashPassword(password, Uint8List.fromList(salt));
    final match = hash == storedHash;

    if (match) {
      _failedAttempts = 0;
      _isUnlocked = true;
      notifyListeners();
    } else {
      _failedAttempts++;
      if (_failedAttempts >= AppConstants.maxFailedAttempts) {
        _lockedUntil =
            DateTime.now().add(Duration(minutes: AppConstants.lockoutDurationMinutes));
      }
      notifyListeners();
    }

    await _saveFailedCount();
    return match;
  }

  Future<bool> authenticateWithBiometrics() async {
    try {
      final canCheck = await _localAuth.canCheckBiometrics;
      if (!canCheck) return false;

      final authenticated = await _localAuth.authenticate(
        localizedReason: '请验证身份以解锁信息保险箱',
        options: const AuthenticationOptions(
          stickyAuth: true,
          biometricOnly: true,
        ),
      );
      if (authenticated) {
        _isUnlocked = true;
        _failedAttempts = 0;
        notifyListeners();
      }
      return authenticated;
    } catch (_) {
      return false;
    }
  }

  Future<bool> isBiometricAvailable() async {
    return await _localAuth.canCheckBiometrics;
  }

  void lock() {
    _isUnlocked = false;
    notifyListeners();
  }

  String _hashPassword(String password, Uint8List salt) {
    final bytes = utf8.encode(password);
    final salted = Uint8List.fromList([...salt, ...bytes]);
    return sha256.convert(salted).toString();
  }

  Future<void> _saveFailedCount() async {
    await _secureStorage.write(
        key: _failedCountKey, value: _failedAttempts.toString());
  }
}
```

- [ ] **Step 4: 运行测试确认通过**

Run:
```bash
cd h:/MyPasswords/infovault && flutter test test/services/auth_service_test.dart
```
Expected: 所有测试通过。

- [ ] **Step 5: Commit**

```bash
cd h:/MyPasswords/infovault && git add -A && git commit -m "feat: add auth service with master password and biometric support"
```

---

### Task 6: 保险箱数据服务

**Files:**
- Create: `infovault/lib/services/vault_service.dart`
- Create: `test/services/vault_service_test.dart`

- [ ] **Step 1: 编写保险箱服务测试**

Create: `test/services/vault_service_test.dart`

```dart
import 'package:flutter_test/flutter_test.dart';
import 'package:infovault/services/vault_service.dart';
import 'package:infovault/models/vault_item.dart';
import 'package:infovault/models/item_type.dart';
import 'package:infovault/models/security_level.dart';

void main() {
  group('VaultService', () {
    test('should add and retrieve items', () async {
      final service = VaultService(/* db, encrypt */);
      final item = VaultItem(
        id: '1',
        type: ItemType.password,
        title: 'Test',
        username: 'user',
        securityLevel: SecurityLevel.enhanced,
      );

      await service.addItem(item);
      final items = await service.getAllItems();
      expect(items.length, 1);
      expect(items.first.title, 'Test');
    });

    test('should filter by type', () async {
      final service = VaultService(/* ... */);
      await service.addItem(VaultItem(id: '1', type: ItemType.password, title: 'P1'));
      await service.addItem(VaultItem(id: '2', type: ItemType.bankCard, title: 'B1'));
      await service.addItem(VaultItem(id: '3', type: ItemType.password, title: 'P2'));

      final passwords = await service.getItemsByType(ItemType.password);
      expect(passwords.length, 2);
    });

    test('should search across fields', () async {
      final service = VaultService(/* ... */);
      await service.addItem(VaultItem(id: '1', type: ItemType.bankCard, title: '招行', cardNumber: '6217001234567890'));
      await service.addItem(VaultItem(id: '2', type: ItemType.password, title: '微信', email: 'zhaohang@email.com'));
      await service.addItem(VaultItem(id: '3', type: ItemType.password, title: '支付宝'));

      final results = await service.search('招');
      expect(results.length, 2); // 招行 + 微信 (email contains 招行)
    });

    test('should delete item', () async {
      final service = VaultService(/* ... */);
      await service.addItem(VaultItem(id: '1', type: ItemType.secureNote, title: 'Note', noteContent: 'content'));
      await service.deleteItem('1');
      final items = await service.getAllItems();
      expect(items.length, 0);
    });
  });
}
```

- [ ] **Step 2: 实现保险箱服务**

Create: `infovault/lib/services/vault_service.dart`

```dart
import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:uuid/uuid.dart';
import '../models/vault_item.dart';
import '../models/item_type.dart';
import '../models/folder.dart';
import 'database_service.dart';
import 'encryption_service.dart';

class VaultService extends ChangeNotifier {
  final DatabaseService _db;
  final EncryptionService _encryption;
  final _uuid = const Uuid();

  List<VaultItem> _items = [];
  List<Folder> _folders = [];
  ItemType? _selectedType;
  String _selectedFolderId = '';
  String _searchQuery = '';

  List<VaultItem> get items => _filteredItems;
  List<Folder> get folders => _folders;
  ItemType? get selectedType => _selectedType;
  String get searchQuery => _searchQuery;

  VaultService(this._db, this._encryption);

  List<VaultItem> get _filteredItems {
    var result = _items;

    if (_selectedType != null) {
      result = result.where((i) => i.type == _selectedType).toList();
    }

    if (_selectedFolderId.isNotEmpty) {
      result = result.where((i) => i.folderId == _selectedFolderId).toList();
    }

    if (_searchQuery.isNotEmpty) {
      final q = _searchQuery.toLowerCase();
      result = result.where((i) =>
        i.title.toLowerCase().contains(q) ||
        (i.username?.toLowerCase().contains(q) ?? false) ||
        (i.email?.toLowerCase().contains(q) ?? false) ||
        (i.phone?.contains(q) ?? false) ||
        (i.cardNumber?.contains(q) ?? false) ||
        (i.idNumber?.contains(q) ?? false) ||
        (i.notes?.toLowerCase().contains(q) ?? false)
      ).toList();
    }

    return result;
  }

  Future<void> loadAll() async {
    _items = await _db.getAllItems();
    _folders = await _db.getAllFolders();
    notifyListeners();
  }

  void setTypeFilter(ItemType? type) {
    _selectedType = type;
    notifyListeners();
  }

  void setFolderFilter(String folderId) {
    _selectedFolderId = folderId;
    notifyListeners();
  }

  void setSearchQuery(String query) {
    _searchQuery = query;
    notifyListeners();
  }

  Future<void> addItem(VaultItem item) async {
    final id = _uuid.v4();
    final now = DateTime.now();
    final newItem = VaultItem(
      id: id,
      type: item.type,
      title: item.title,
      username: item.username,
      password: item.password,
      email: item.email,
      phone: item.phone,
      url: item.url,
      bankName: item.bankName,
      cardNumber: item.cardNumber,
      cardHolder: item.cardHolder,
      expiryDate: item.expiryDate,
      cvv: item.cvv,
      withdrawalPassword: item.withdrawalPassword,
      idType: item.idType,
      idNumber: item.idNumber,
      idName: item.idName,
      issuingAuthority: item.issuingAuthority,
      validUntil: item.validUntil,
      noteContent: item.noteContent,
      notes: item.notes,
      folderId: item.folderId,
      folderName: item.folderName,
      securityLevel: item.securityLevel,
      photoPaths: item.photoPaths,
      createdAt: now,
      updatedAt: now,
    );
    await _db.insertItem(newItem);
    _items.insert(0, newItem);
    notifyListeners();
  }

  Future<void> updateItem(VaultItem item) async {
    final updated = item.copyWith(updatedAt: DateTime.now());
    await _db.updateItem(updated);
    final index = _items.indexWhere((i) => i.id == item.id);
    if (index != -1) {
      _items[index] = updated;
    }
    notifyListeners();
  }

  Future<void> deleteItem(String id) async {
    await _db.deleteItem(id);
    _items.removeWhere((i) => i.id == id);
    notifyListeners();
  }

  Future<void> addFolder(Folder folder) async {
    final id = _uuid.v4();
    final newFolder = Folder(id: id, name: folder.name, sortOrder: _folders.length);
    await _db.insertFolder(newFolder);
    _folders.add(newFolder);
    notifyListeners();
  }

  Future<void> deleteFolder(String id) async {
    await _db.deleteFolder(id);
    _folders.removeWhere((f) => f.id == id);
    notifyListeners();
  }

  Map<ItemType, int> getTypeCounts() {
    final counts = <ItemType, int>{};
    for (final item in _items) {
      counts[item.type] = (counts[item.type] ?? 0) + 1;
    }
    return counts;
  }

  List<VaultItem> searchDetailed(String query) {
    final q = query.toLowerCase();
    return _items
        .where((i) =>
            i.title.toLowerCase().contains(q) ||
            (i.username?.toLowerCase().contains(q) ?? false) ||
            (i.email?.toLowerCase().contains(q) ?? false) ||
            (i.phone?.contains(q) ?? false) ||
            (i.cardNumber?.contains(q) ?? false) ||
            (i.idNumber?.contains(q) ?? false) ||
            (i.notes?.toLowerCase().contains(q) ?? false) ||
            (i.url?.toLowerCase().contains(q) ?? false) ||
            (i.bankName?.toLowerCase().contains(q) ?? false) ||
            (i.idName?.toLowerCase().contains(q) ?? false) ||
            (i.noteContent?.toLowerCase().contains(q) ?? false))
        .toList();
  }
}
```

- [ ] **Step 3: Commit**

```bash
cd h:/MyPasswords/infovault && git add -A && git commit -m "feat: add vault service with filtering, search, and CRUD"
```

---

### Task 7: 主题配置

**Files:**
- Create: `infovault/lib/theme/app_theme.dart`

- [ ] **Step 1: 实现 Material 3 主题**

Create: `infovault/lib/theme/app_theme.dart`

```dart
import 'package:flutter/material.dart';

class AppTheme {
  static ThemeData light() {
    final colorScheme = ColorScheme.fromSeed(
      seedColor: const Color(0xFF1565C0),
      brightness: Brightness.light,
    );

    return ThemeData(
      useMaterial3: true,
      colorScheme: colorScheme,
      appBarTheme: AppBarTheme(
        centerTitle: false,
        backgroundColor: colorScheme.surface,
        foregroundColor: colorScheme.onSurface,
        elevation: 0,
      ),
      cardTheme: CardThemeData(
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: colorScheme.surfaceContainerHighest.withAlpha(80),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      ),
      navigationBarTheme: NavigationBarThemeData(
        elevation: 0,
        indicatorColor: colorScheme.primaryContainer,
        labelBehavior: NavigationDestinationLabelBehavior.alwaysShow,
      ),
    );
  }

  static ThemeData dark() {
    final colorScheme = ColorScheme.fromSeed(
      seedColor: const Color(0xFF1565C0),
      brightness: Brightness.dark,
    );

    return ThemeData(
      useMaterial3: true,
      colorScheme: colorScheme,
      appBarTheme: AppBarTheme(
        centerTitle: false,
        backgroundColor: colorScheme.surface,
        foregroundColor: colorScheme.onSurface,
        elevation: 0,
      ),
      cardTheme: CardThemeData(
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: colorScheme.surfaceContainerHighest.withAlpha(80),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      ),
      navigationBarTheme: NavigationBarThemeData(
        elevation: 0,
        indicatorColor: colorScheme.primaryContainer,
        labelBehavior: NavigationDestinationLabelBehavior.alwaysShow,
      ),
    );
  }
}
```

- [ ] **Step 2: Commit**

```bash
cd h:/MyPasswords/infovault && git add -A && git commit -m "feat: add Material 3 light and dark theme"
```

---

### Task 8: App 入口和路由

**Files:**
- Create: `infovault/lib/app.dart`
- Modify: `infovault/lib/main.dart`

- [ ] **Step 1: 实现 main.dart**

Modify: `infovault/lib/main.dart`

```dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'services/database_service.dart';
import 'services/encryption_service.dart';
import 'services/auth_service.dart';
import 'services/vault_service.dart';
import 'app.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  final databaseService = DatabaseService();
  final encryptionService = EncryptionService();
  final authService = AuthService(encryptionService);
  final vaultService = VaultService(databaseService, encryptionService);

  await authService.initialize();

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => authService),
        ChangeNotifierProvider(create: (_) => vaultService),
      ],
      child: const InfoVaultApp(),
    ),
  );
}
```

- [ ] **Step 2: 实现 app.dart**

Create: `infovault/lib/app.dart`

```dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'services/auth_service.dart';
import 'services/vault_service.dart';
import 'theme/app_theme.dart';
import 'screens/lock_screen.dart';
import 'screens/create_password_screen.dart';
import 'screens/vault_screen.dart';
import 'screens/search_screen.dart';
import 'screens/settings_screen.dart';
import 'screens/item_detail_screen.dart';
import 'screens/add_edit_item_screen.dart';

class InfoVaultApp extends StatelessWidget {
  const InfoVaultApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: '信息保险箱',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light(),
      darkTheme: AppTheme.dark(),
      themeMode: ThemeMode.system,
      home: Consumer<AuthService>(
        builder: (context, auth, _) {
          if (!auth.hasMasterPassword) {
            return const CreatePasswordScreen();
          }
          if (!auth.isUnlocked) {
            return const LockScreen();
          }
          return const MainShell();
        },
      ),
    );
  }
}

class MainShell extends StatefulWidget {
  const MainShell({super.key});
  @override
  State<MainShell> createState() => _MainShellState();
}

class _MainShellState extends State<MainShell> {
  int _currentIndex = 0;

  @override
  void initState() {
    super.initState();
    context.read<VaultService>().loadAll();
  }

  @override
  Widget build(BuildContext context) {
    final screens = [
      const VaultScreen(),
      const SearchScreen(),
      const SettingsScreen(),
    ];

    return Scaffold(
      body: IndexedStack(index: _currentIndex, children: screens),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _currentIndex,
        onDestinationSelected: (index) => setState(() => _currentIndex = index),
        destinations: const [
          NavigationDestination(icon: Icon(Icons.security), label: '信息保险箱'),
          NavigationDestination(icon: Icon(Icons.search), label: '搜索'),
          NavigationDestination(icon: Icon(Icons.person), label: '我的'),
        ],
      ),
    );
  }
}
```

- [ ] **Step 3: Commit**

```bash
cd h:/MyPasswords/infovault && git add -A && git commit -m "feat: add app entry, routing, and main shell with 3-tab navigation"
```

---

### Task 9: 创建主密码页面

**Files:**
- Create: `infovault/lib/screens/create_password_screen.dart`

- [ ] **Step 1: 实现创建主密码页面**

Create: `infovault/lib/screens/create_password_screen.dart`

```dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/auth_service.dart';
import '../utils/validators.dart';

class CreatePasswordScreen extends StatefulWidget {
  const CreatePasswordScreen({super.key});
  @override
  State<CreatePasswordScreen> createState() => _CreatePasswordScreenState();
}

class _CreatePasswordScreenState extends State<CreatePasswordScreen> {
  final _formKey = GlobalKey<FormState>();
  final _passwordController = TextEditingController();
  final _confirmController = TextEditingController();
  bool _obscurePassword = true;
  bool _obscureConfirm = true;

  @override
  void dispose() {
    _passwordController.dispose();
    _confirmController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    await context.read<AuthService>().setMasterPassword(
      _passwordController.text.trim(),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(32),
            child: Form(
              key: _formKey,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.lock_outline, size: 64, color: Color(0xFF1565C0)),
                  const SizedBox(height: 16),
                  Text('创建主密码',
                      style: Theme.of(context).textTheme.headlineSmall),
                  const SizedBox(height: 8),
                  Text('这是你解锁信息保险箱的唯一凭证\n忘记后数据将无法恢复',
                      textAlign: TextAlign.center,
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: Theme.of(context).colorScheme.error)),
                  const SizedBox(height: 32),
                  TextFormField(
                    controller: _passwordController,
                    obscureText: _obscurePassword,
                    decoration: InputDecoration(
                      labelText: '主密码',
                      hintText: '至少8位字符',
                      suffixIcon: IconButton(
                        icon: Icon(_obscurePassword
                            ? Icons.visibility_off
                            : Icons.visibility),
                        onPressed: () =>
                            setState(() => _obscurePassword = !_obscurePassword),
                      ),
                    ),
                    validator: (v) => Validators.masterPassword(v),
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: _confirmController,
                    obscureText: _obscureConfirm,
                    decoration: InputDecoration(
                      labelText: '确认主密码',
                      suffixIcon: IconButton(
                        icon: Icon(_obscureConfirm
                            ? Icons.visibility_off
                            : Icons.visibility),
                        onPressed: () =>
                            setState(() => _obscureConfirm = !_obscureConfirm),
                      ),
                    ),
                    validator: (v) {
                      if (v != _passwordController.text) return '两次密码不一致';
                      return null;
                    },
                  ),
                  const SizedBox(height: 32),
                  SizedBox(
                    width: double.infinity,
                    height: 48,
                    child: FilledButton(
                      onPressed: _submit,
                      child: const Text('创建并进入'),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
```

- [ ] **Step 2: Commit**

```bash
cd h:/MyPasswords/infovault && git add -A && git commit -m "feat: add create master password screen"
```

---

### Task 10: 解锁页面

**Files:**
- Create: `infovault/lib/screens/lock_screen.dart`

- [ ] **Step 1: 实现解锁页面**

Create: `infovault/lib/screens/lock_screen.dart`

```dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/auth_service.dart';

class LockScreen extends StatefulWidget {
  const LockScreen({super.key});
  @override
  State<LockScreen> createState() => _LockScreenState();
}

class _LockScreenState extends State<LockScreen> {
  final _passwordController = TextEditingController();
  String? _errorText;
  bool _isChecking = false;

  @override
  void dispose() {
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _unlock() async {
    if (_passwordController.text.isEmpty) return;

    setState(() => _isChecking = true);
    final auth = context.read<AuthService>();
    final ok = await auth.verifyMasterPassword(
        _passwordController.text.trim());
    setState(() => _isChecking = false);

    if (!ok) {
      setState(() {
        _errorText = auth.isLockedOut
            ? '错误次数过多，请5分钟后重试'
            : '主密码错误，请重试 (${auth.failedAttempts}次)';
      });
    }
  }

  Future<void> _biometricUnlock() async {
    final auth = context.read<AuthService>();
    final ok = await auth.authenticateWithBiometrics();
    if (!ok && mounted) {
      setState(() => _errorText = '生物识别失败，请使用主密码');
    }
  }

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthService>();
    final isLocked = auth.isLockedOut;

    return Scaffold(
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(32),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.lock, size: 64, color: Color(0xFF1565C0)),
                const SizedBox(height: 16),
                Text('信息保险箱',
                    style: Theme.of(context).textTheme.headlineSmall),
                const SizedBox(height: 8),
                Text('请输入主密码解锁',
                    style: Theme.of(context).textTheme.bodyLarge),
                const SizedBox(height: 32),
                TextField(
                  controller: _passwordController,
                  obscureText: true,
                  enabled: !isLocked && !_isChecking,
                  decoration: InputDecoration(
                    labelText: '主密码',
                    errorText: _errorText,
                    prefixIcon: const Icon(Icons.key),
                  ),
                  onSubmitted: (_) => _unlock(),
                ),
                const SizedBox(height: 16),
                SizedBox(
                  width: double.infinity,
                  height: 48,
                  child: FilledButton(
                    onPressed: isLocked || _isChecking ? null : _unlock,
                    child: _isChecking
                        ? const SizedBox(
                            height: 20,
                            width: 20,
                            child: CircularProgressIndicator(
                                strokeWidth: 2, color: Colors.white))
                        : const Text('解锁'),
                  ),
                ),
                if (auth.isBiometricAvailable()) ...[
                  const SizedBox(height: 16),
                  OutlinedButton.icon(
                    onPressed: _biometricUnlock,
                    icon: const Icon(Icons.fingerprint),
                    label: const Text('指纹解锁'),
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }
}
```

- [ ] **Step 2: Commit**

```bash
cd h:/MyPasswords/infovault && git add -A && git commit -m "feat: add lock screen with password and biometric unlock"
```

---

### Task 11: 主界面 —— 信息保险箱列表

**Files:**
- Create: `infovault/lib/widgets/type_filter_bar.dart`
- Create: `infovault/lib/widgets/folder_filter_bar.dart`
- Create: `infovault/lib/widgets/item_list_tile.dart`
- Create: `infovault/lib/screens/vault_screen.dart`

- [ ] **Step 1: 创建类型筛选栏组件**

Create: `infovault/lib/widgets/type_filter_bar.dart`

```dart
import 'package:flutter/material.dart';
import '../models/item_type.dart';

class TypeFilterBar extends StatelessWidget {
  final ItemType? selected;
  final Map<ItemType, int> counts;
  final ValueChanged<ItemType?> onSelected;

  const TypeFilterBar({
    super.key,
    required this.selected,
    required this.counts,
    required this.onSelected,
  });

  @override
  Widget build(BuildContext context) {
    final total = counts.values.fold<int>(0, (s, c) => s + c);
    final items = <_FilterItem>[
      _FilterItem(icon: null, label: '全部', count: total, type: null),
      for (final type in ItemType.values)
        _FilterItem(
          icon: type.icon,
          label: type.label,
          count: counts[type] ?? 0,
          type: type,
        ),
    ];

    return SizedBox(
      height: 36,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        itemCount: items.length,
        separatorBuilder: (_, __) => const SizedBox(width: 8),
        itemBuilder: (context, index) {
          final item = items[index];
          final isSelected = item.type == selected;
          return FilterChip(
            label: Text('${item.icon ?? ''} ${item.label} ${item.count}',
                style: TextStyle(fontSize: 12)),
            selected: isSelected,
            onSelected: (_) => onSelected(item.type),
            visualDensity: VisualDensity.compact,
          );
        },
      ),
    );
  }
}

class _FilterItem {
  final String? icon;
  final String label;
  final int count;
  final ItemType? type;
  const _FilterItem({
    required this.icon,
    required this.label,
    required this.count,
    required this.type,
  });
}
```

- [ ] **Step 2: 创建文件夹筛选栏组件**

Create: `infovault/lib/widgets/folder_filter_bar.dart`

```dart
import 'package:flutter/material.dart';
import '../models/folder.dart';

class FolderFilterBar extends StatelessWidget {
  final List<Folder> folders;
  final String selectedId;
  final ValueChanged<String> onSelected;
  final VoidCallback onAddFolder;

  const FolderFilterBar({
    super.key,
    required this.folders,
    required this.selectedId,
    required this.onSelected,
    required this.onAddFolder,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 32,
      child: ListView(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        children: [
          _FolderChip(
            label: '📁 全部',
            isSelected: selectedId.isEmpty,
            onTap: () => onSelected(''),
          ),
          ...folders.map((f) => _FolderChip(
                label: f.name,
                isSelected: selectedId == f.id,
                onTap: () => onSelected(f.id),
              )),
          GestureDetector(
            onTap: onAddFolder,
            child: const Padding(
              padding: EdgeInsets.symmetric(horizontal: 8),
              child: Chip(
                label: Text('+ 新建', style: TextStyle(fontSize: 11)),
                visualDensity: VisualDensity.compact,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _FolderChip extends StatelessWidget {
  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  const _FolderChip({
    required this.label,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 4),
      child: ActionChip(
        label: Text(label, style: const TextStyle(fontSize: 11)),
        onPressed: onTap,
        visualDensity: VisualDensity.compact,
        backgroundColor:
            isSelected ? Theme.of(context).colorScheme.primaryContainer : null,
      ),
    );
  }
}
```

- [ ] **Step 3: 创建列表条目组件**

Create: `infovault/lib/widgets/item_list_tile.dart`

```dart
import 'package:flutter/material.dart';
import '../models/vault_item.dart';
import '../models/security_level.dart';

class ItemListTile extends StatelessWidget {
  final VaultItem item;
  final VoidCallback onTap;

  const ItemListTile({
    super.key,
    required this.item,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 3),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
          child: Row(
            children: [
              Text(item.type.icon, style: const TextStyle(fontSize: 20)),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Text(item.title,
                            style: const TextStyle(
                                fontWeight: FontWeight.w600, fontSize: 15)),
                        if (item.folderName != null &&
                            item.folderName!.isNotEmpty) ...[
                          const SizedBox(width: 6),
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 6, vertical: 1),
                            decoration: BoxDecoration(
                              color: Theme.of(context)
                                  .colorScheme
                                  .secondaryContainer,
                              borderRadius: BorderRadius.circular(4),
                            ),
                            child: Text(item.folderName!,
                                style: const TextStyle(fontSize: 10)),
                          ),
                        ],
                        if (item.securityLevel == SecurityLevel.enhanced) ...[
                          const SizedBox(width: 4),
                          const Icon(Icons.lock, size: 12,
                              color: Colors.red),
                        ],
                      ],
                    ),
                    const SizedBox(height: 2),
                    Text(item.displaySubtitle,
                        style: TextStyle(
                            fontSize: 12,
                            color: Theme.of(context).colorScheme.outline)),
                  ],
                ),
              ),
              Icon(Icons.chevron_right,
                  color: Theme.of(context).colorScheme.outline),
            ],
          ),
        ),
      ),
    );
  }
}
```

- [ ] **Step 4: 实现保险箱主页面**

Create: `infovault/lib/screens/vault_screen.dart`

```dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/vault_service.dart';
import '../services/auth_service.dart';
import '../widgets/type_filter_bar.dart';
import '../widgets/folder_filter_bar.dart';
import '../widgets/item_list_tile.dart';
import 'add_edit_item_screen.dart';
import 'item_detail_screen.dart';

class VaultScreen extends StatelessWidget {
  const VaultScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<VaultService>(
      builder: (context, vault, _) {
        return Scaffold(
          appBar: AppBar(
            title: const Text('信息保险箱'),
          ),
          body: Column(
            children: [
              // Search bar
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                child: TextField(
                  decoration: InputDecoration(
                    hintText: '搜索平台名、用户名、卡号...',
                    prefixIcon: const Icon(Icons.search),
                    filled: true,
                    fillColor: Theme.of(context)
                        .colorScheme
                        .surfaceContainerHighest
                        .withAlpha(100),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide.none,
                    ),
                    contentPadding: const EdgeInsets.symmetric(vertical: 0),
                  ),
                  onChanged: (q) => vault.setSearchQuery(q),
                ),
              ),
              // Type filter
              TypeFilterBar(
                selected: vault.selectedType,
                counts: vault.getTypeCounts(),
                onSelected: (type) => vault.setTypeFilter(type),
              ),
              const SizedBox(height: 4),
              // Folder filter
              FolderFilterBar(
                folders: vault.folders,
                selectedId: vault.selectedFolderId,
                onSelected: (id) => vault.setFolderFilter(id),
                onAddFolder: () => _showAddFolderDialog(context),
              ),
              const SizedBox(height: 8),
              // Item list
              Expanded(
                child: vault.items.isEmpty
                    ? Center(
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(Icons.inbox_outlined,
                                size: 64,
                                color: Theme.of(context).colorScheme.outline),
                            const SizedBox(height: 8),
                            Text('还没有任何条目',
                                style: Theme.of(context).textTheme.bodyLarge),
                          ],
                        ),
                      )
                    : ListView.builder(
                        itemCount: vault.items.length,
                        itemBuilder: (context, index) {
                          final item = vault.items[index];
                          return ItemListTile(
                            item: item,
                            onTap: () => Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) =>
                                    ItemDetailScreen(itemId: item.id),
                              ),
                            ),
                          );
                        },
                      ),
              ),
            ],
          ),
          floatingActionButton: FloatingActionButton(
            onPressed: () => _showAddTypeSheet(context),
            child: const Icon(Icons.add),
          ),
        );
      },
    );
  }

  void _showAddTypeSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      builder: (_) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('选择类型', style: Theme.of(context).textTheme.titleMedium),
              const SizedBox(height: 16),
              for (final type in ItemType.values)
                ListTile(
                  leading: Text(type.icon, style: const TextStyle(fontSize: 28)),
                  title: Text(type.label),
                  onTap: () {
                    Navigator.pop(context);
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => AddEditItemScreen(itemType: type),
                      ),
                    );
                  },
                ),
            ],
          ),
        ),
      ),
    );
  }

  void _showAddFolderDialog(BuildContext context) {
    final controller = TextEditingController();
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('新建文件夹'),
        content: TextField(
          controller: controller,
          decoration: const InputDecoration(hintText: '文件夹名称'),
          autofocus: true,
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('取消')),
          FilledButton(
            onPressed: () {
              if (controller.text.trim().isNotEmpty) {
                context.read<VaultService>().addFolder(
                      Folder(
                        id: '',
                        name: controller.text.trim(),
                      ),
                    );
                Navigator.pop(context);
              }
            },
            child: const Text('创建'),
          ),
        ],
      ),
    );
  }
}
```

- [ ] **Step 5: Commit**

```bash
cd h:/MyPasswords/infovault && git add -A && git commit -m "feat: add vault screen with type/folder filters and item list"
```

---

### Task 12: 添加/编辑条目页面

**Files:**
- Create: `infovault/lib/screens/add_edit_item_screen.dart`

- [ ] **Step 1: 实现添加/编辑表单页面**

Create: `infovault/lib/screens/add_edit_item_screen.dart`

```dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/vault_item.dart';
import '../models/item_type.dart';
import '../models/security_level.dart';
import '../services/vault_service.dart';
import '../utils/validators.dart';

class AddEditItemScreen extends StatefulWidget {
  final ItemType itemType;
  final VaultItem? existingItem; // null when adding, non-null when editing

  const AddEditItemScreen({
    super.key,
    required this.itemType,
    this.existingItem,
  });

  @override
  State<AddEditItemScreen> createState() => _AddEditItemScreenState();
}

class _AddEditItemScreenState extends State<AddEditItemScreen> {
  final _formKey = GlobalKey<FormState>();
  late final ItemType _type;
  late final TextEditingController _titleCtrl;
  late final TextEditingController _usernameCtrl;
  late final TextEditingController _passwordCtrl;
  late final TextEditingController _emailCtrl;
  late final TextEditingController _phoneCtrl;
  late final TextEditingController _urlCtrl;
  late final TextEditingController _bankNameCtrl;
  late final TextEditingController _cardNumberCtrl;
  late final TextEditingController _cardHolderCtrl;
  late final TextEditingController _expiryDateCtrl;
  late final TextEditingController _cvvCtrl;
  late final TextEditingController _withdrawalPwdCtrl;
  late final TextEditingController _idTypeCtrl;
  late final TextEditingController _idNumberCtrl;
  late final TextEditingController _idNameCtrl;
  late final TextEditingController _issuingAuthorityCtrl;
  late final TextEditingController _validUntilCtrl;
  late final TextEditingController _noteContentCtrl;
  late final TextEditingController _notesCtrl;
  SecurityLevel _securityLevel = SecurityLevel.basic;
  String _folderId = '';
  String? _folderName;

  bool get _isEditing => widget.existingItem != null;

  @override
  void initState() {
    super.initState();
    _type = widget.itemType;
    final i = widget.existingItem;
    _titleCtrl = TextEditingController(text: i?.title ?? '');
    _usernameCtrl = TextEditingController(text: i?.username ?? '');
    _passwordCtrl = TextEditingController(text: i?.password ?? '');
    _emailCtrl = TextEditingController(text: i?.email ?? '');
    _phoneCtrl = TextEditingController(text: i?.phone ?? '');
    _urlCtrl = TextEditingController(text: i?.url ?? '');
    _bankNameCtrl = TextEditingController(text: i?.bankName ?? '');
    _cardNumberCtrl = TextEditingController(text: i?.cardNumber ?? '');
    _cardHolderCtrl = TextEditingController(text: i?.cardHolder ?? '');
    _expiryDateCtrl = TextEditingController(text: i?.expiryDate ?? '');
    _cvvCtrl = TextEditingController(text: i?.cvv ?? '');
    _withdrawalPwdCtrl = TextEditingController(text: i?.withdrawalPassword ?? '');
    _idTypeCtrl = TextEditingController(text: i?.idType ?? '');
    _idNumberCtrl = TextEditingController(text: i?.idNumber ?? '');
    _idNameCtrl = TextEditingController(text: i?.idName ?? '');
    _issuingAuthorityCtrl = TextEditingController(text: i?.issuingAuthority ?? '');
    _validUntilCtrl = TextEditingController(text: i?.validUntil ?? '');
    _noteContentCtrl = TextEditingController(text: i?.noteContent ?? '');
    _notesCtrl = TextEditingController(text: i?.notes ?? '');
    _securityLevel = i?.securityLevel ?? SecurityLevel.basic;
    _folderId = i?.folderId ?? '';
    _folderName = i?.folderName;
  }

  @override
  void dispose() {
    _titleCtrl.dispose();
    _usernameCtrl.dispose();
    _passwordCtrl.dispose();
    _emailCtrl.dispose();
    _phoneCtrl.dispose();
    _urlCtrl.dispose();
    _bankNameCtrl.dispose();
    _cardNumberCtrl.dispose();
    _cardHolderCtrl.dispose();
    _expiryDateCtrl.dispose();
    _cvvCtrl.dispose();
    _withdrawalPwdCtrl.dispose();
    _idTypeCtrl.dispose();
    _idNumberCtrl.dispose();
    _idNameCtrl.dispose();
    _issuingAuthorityCtrl.dispose();
    _validUntilCtrl.dispose();
    _noteContentCtrl.dispose();
    _notesCtrl.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;

    final item = VaultItem(
      id: widget.existingItem?.id ?? '',
      type: _type,
      title: _titleCtrl.text.trim(),
      username: _usernameCtrl.text.trim(),
      password: _passwordCtrl.text.trim(),
      email: _emailCtrl.text.trim(),
      phone: _phoneCtrl.text.trim(),
      url: _urlCtrl.text.trim(),
      bankName: _bankNameCtrl.text.trim(),
      cardNumber: _cardNumberCtrl.text.trim(),
      cardHolder: _cardHolderCtrl.text.trim(),
      expiryDate: _expiryDateCtrl.text.trim(),
      cvv: _cvvCtrl.text.trim(),
      withdrawalPassword: _withdrawalPwdCtrl.text.trim(),
      idType: _idTypeCtrl.text.trim(),
      idNumber: _idNumberCtrl.text.trim(),
      idName: _idNameCtrl.text.trim(),
      issuingAuthority: _issuingAuthorityCtrl.text.trim(),
      validUntil: _validUntilCtrl.text.trim(),
      noteContent: _noteContentCtrl.text.trim(),
      notes: _notesCtrl.text.trim(),
      folderId: _folderId,
      folderName: _folderName,
      securityLevel: _securityLevel,
      photoPaths: widget.existingItem?.photoPaths ?? [],
    );

    final vault = context.read<VaultService>();
    if (_isEditing) {
      await vault.updateItem(item);
    } else {
      await vault.addItem(item);
    }

    if (mounted) Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_isEditing ? '编辑${_type.label}' : '添加${_type.label}'),
        actions: [
          TextButton(onPressed: _save, child: const Text('保存')),
        ],
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            _buildTitleField(),
            ..._buildTypeFields(),
            const SizedBox(height: 24),
            _buildSecurityLevelSelector(),
            const SizedBox(height: 16),
            _buildFolderSelector(),
            const SizedBox(height: 80),
          ],
        ),
      ),
    );
  }

  Widget _buildTitleField() {
    return TextFormField(
      controller: _titleCtrl,
      decoration: InputDecoration(labelText: _type == ItemType.secureNote ? '标题' : '平台/名称 *'),
      validator: (v) => Validators.required(v, '名称'),
    );
  }

  List<Widget> _buildTypeFields() {
    switch (_type) {
      case ItemType.password:
        return [
          _buildField('用户名/账号', _usernameCtrl),
          _buildField('密码', _passwordCtrl, isPassword: true),
          _buildField('绑定邮箱', _emailCtrl, validator: (v) => Validators.email(v)),
          _buildField('绑定手机号', _phoneCtrl, validator: (v) => Validators.phone(v)),
          _buildField('网址', _urlCtrl),
          _buildField('备注', _notesCtrl, maxLines: 2),
        ];
      case ItemType.bankCard:
        return [
          _buildField('银行名称', _bankNameCtrl),
          _buildField('卡号', _cardNumberCtrl),
          _buildField('持卡人姓名', _cardHolderCtrl),
          _buildField('有效期', _expiryDateCtrl, hint: 'MM/YY'),
          _buildField('CVV安全码', _cvvCtrl, isPassword: true),
          _buildField('取款密码', _withdrawalPwdCtrl, isPassword: true),
          _buildField('备注', _notesCtrl, maxLines: 2),
        ];
      case ItemType.idDocument:
        return [
          _buildField('证件类型', _idTypeCtrl, hint: '身份证/护照/驾照/社保卡...'),
          _buildField('证件号', _idNumberCtrl),
          _buildField('姓名', _idNameCtrl),
          _buildField('签发机关', _issuingAuthorityCtrl),
          _buildField('有效期', _validUntilCtrl),
          _buildField('备注', _notesCtrl, maxLines: 2),
        ];
      case ItemType.secureNote:
        return [
          TextFormField(
            controller: _noteContentCtrl,
            decoration: const InputDecoration(
              labelText: '内容',
              hintText: '输入任何需要安全保存的文本...',
              alignLabelWithHint: true,
            ),
            maxLines: 8,
            validator: (v) => Validators.required(v, '内容'),
          ),
        ];
    }
  }

  Widget _buildField(String label, TextEditingController controller,
      {bool isPassword = false, String? hint, int maxLines = 1,
       String? Function(String?)? validator}) {
    return Padding(
      padding: const EdgeInsets.only(top: 12),
      child: TextFormField(
        controller: controller,
        obscureText: isPassword,
        decoration: InputDecoration(
          labelText: label,
          hintText: hint,
        ),
        maxLines: maxLines,
        validator: validator,
      ),
    );
  }

  Widget _buildSecurityLevelSelector() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Row(
          children: [
            const Text('安全等级  '),
            ChoiceChip(
              label: const Text('基础'),
              selected: _securityLevel == SecurityLevel.basic,
              onSelected: (_) => setState(() => _securityLevel = SecurityLevel.basic),
            ),
            const SizedBox(width: 8),
            ChoiceChip(
              label: const Text('加强 🔒'),
              selected: _securityLevel == SecurityLevel.enhanced,
              onSelected: (_) => setState(() => _securityLevel = SecurityLevel.enhanced),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFolderSelector() {
    final folders = context.read<VaultService>().folders;
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: DropdownButtonFormField<String>(
          value: _folderId.isEmpty ? null : _folderId,
          decoration: const InputDecoration(
            labelText: '文件夹',
            border: InputBorder.none,
          ),
          hint: const Text('选择文件夹（可选）'),
          items: [
            for (final f in folders)
              DropdownMenuItem(value: f.id, child: Text(f.name)),
          ],
          onChanged: (id) {
            setState(() {
              _folderId = id ?? '';
              _folderName = id != null
                  ? folders.firstWhere((f) => f.id == id).name
                  : null;
            });
          },
        ),
      ),
    );
  }
}
```

- [ ] **Step 2: Commit**

```bash
cd h:/MyPasswords/infovault && git add -A && git commit -m "feat: add item form with four type-specific field sets"
```

---

### Task 13: 详情页 + 二次验证

**Files:**
- Create: `infovault/lib/widgets/field_row.dart`
- Create: `infovault/lib/widgets/secondary_auth_dialog.dart`
- Create: `infovault/lib/screens/item_detail_screen.dart`

- [ ] **Step 1: 创建字段行组件**

Create: `infovault/lib/widgets/field_row.dart`

```dart
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class FieldRow extends StatelessWidget {
  final String label;
  final String? value;
  final bool isPassword;
  final bool isSensitive;
  final VoidCallback? onRequireAuth;

  const FieldRow({
    super.key,
    required this.label,
    required this.value,
    this.isPassword = false,
    this.isSensitive = false,
    this.onRequireAuth,
  });

  @override
  Widget build(BuildContext context) {
    if (value == null || value!.isEmpty) return const SizedBox.shrink();

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          SizedBox(
            width: 80,
            child: Text(label,
                style: TextStyle(
                    color: Theme.of(context).colorScheme.outline,
                    fontSize: 13)),
          ),
          Expanded(
            child: _PasswordField(
              value: value!,
              isPassword: isPassword,
            ),
          ),
          _CopyButton(
            value: value!,
            isSensitive: isSensitive,
            onRequireAuth: onRequireAuth,
          ),
        ],
      ),
    );
  }
}

class _PasswordField extends StatefulWidget {
  final String value;
  final bool isPassword;
  const _PasswordField({required this.value, required this.isPassword});
  @override
  State<_PasswordField> createState() => _PasswordFieldState();
}

class _PasswordFieldState extends State<_PasswordField> {
  bool _obscured = true;

  @override
  void initState() {
    super.initState();
    _obscured = widget.isPassword;
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: widget.isPassword
          ? () => setState(() => _obscured = !_obscured)
          : null,
      child: Text(
        widget.isPassword && _obscured ? '••••••••' : widget.value,
        style: const TextStyle(fontWeight: FontWeight.w500),
      ),
    );
  }
}

class _CopyButton extends StatelessWidget {
  final String value;
  final bool isSensitive;
  final VoidCallback? onRequireAuth;

  const _CopyButton({
    required this.value,
    required this.isSensitive,
    this.onRequireAuth,
  });

  @override
  Widget build(BuildContext context) {
    return IconButton(
      icon: const Icon(Icons.copy, size: 18),
      tooltip: '复制',
      onPressed: () {
        if (isSensitive && onRequireAuth != null) {
          onRequireAuth!();
        } else {
          Clipboard.setData(ClipboardData(text: value));
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('已复制'),
              duration: Duration(seconds: 1),
            ),
          );
        }
      },
    );
  }
}
```

- [ ] **Step 2: 创建二次验证弹窗**

Create: `infovault/lib/widgets/secondary_auth_dialog.dart`

```dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/auth_service.dart';

class SecondaryAuthDialog extends StatefulWidget {
  final Widget child;
  final VoidCallback onAuthenticated;

  const SecondaryAuthDialog({
    super.key,
    required this.child,
    required this.onAuthenticated,
  });

  static Future<bool> show(BuildContext context) async {
    return await showDialog<bool>(
          context: context,
          builder: (_) => const _SecondaryAuthContent(),
        ) ??
        false;
  }

  @override
  State<SecondaryAuthDialog> createState() => _SecondaryAuthDialogState();
}

class _SecondaryAuthDialogState extends State<SecondaryAuthDialog> {
  // Unused in dialog variant
}

class _SecondaryAuthContent extends StatefulWidget {
  const _SecondaryAuthContent();
  @override
  State<_SecondaryAuthContent> createState() => _SecondaryAuthContentState();
}

class _SecondaryAuthContentState extends State<_SecondaryAuthContent> {
  final _passwordCtrl = TextEditingController();
  String? _error;

  @override
  void dispose() {
    _passwordCtrl.dispose();
    super.dispose();
  }

  Future<void> _verify() async {
    final auth = context.read<AuthService>();
    final ok = await auth.verifyMasterPassword(_passwordCtrl.text.trim());
    if (ok) {
      Navigator.pop(context, true);
    } else {
      setState(() => _error = '密码错误');
    }
  }

  Future<void> _biometric() async {
    final ok =
        await context.read<AuthService>().authenticateWithBiometrics();
    if (ok) {
      Navigator.pop(context, true);
    } else {
      setState(() => _error = '验证失败');
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('身份验证'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Text('此条目为"加强安全"等级，请验证身份：'),
          const SizedBox(height: 12),
          TextField(
            controller: _passwordCtrl,
            obscureText: true,
            decoration: InputDecoration(
              labelText: '主密码',
              errorText: _error,
            ),
          ),
        ],
      ),
      actions: [
        TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('取消')),
        OutlinedButton.icon(
          onPressed: _biometric,
          icon: const Icon(Icons.fingerprint, size: 18),
          label: const Text('指纹'),
        ),
        FilledButton(onPressed: _verify, child: const Text('验证')),
      ],
    );
  }
}
```

- [ ] **Step 3: 实现详情页**

Create: `infovault/lib/screens/item_detail_screen.dart`

```dart
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import '../models/vault_item.dart';
import '../models/item_type.dart';
import '../models/security_level.dart';
import '../services/vault_service.dart';
import '../widgets/field_row.dart';
import '../widgets/secondary_auth_dialog.dart';
import 'add_edit_item_screen.dart';

class ItemDetailScreen extends StatelessWidget {
  final String itemId;

  const ItemDetailScreen({super.key, required this.itemId});

  @override
  Widget build(BuildContext context) {
    final vault = context.watch<VaultService>();
    final item = vault.items.firstWhere(
      (i) => i.id == itemId,
      orElse: () => throw StateError('Item not found'),
    );

    final isEnhanced = item.securityLevel == SecurityLevel.enhanced;

    Future<void> requireAuthThen(VoidCallback action) async {
      if (isEnhanced) {
        final ok = await SecondaryAuthDialog.show(context);
        if (ok) action();
      } else {
        action();
      }
    }

    return Scaffold(
      appBar: AppBar(
        title: Text(item.title),
        actions: [
          IconButton(
            icon: const Icon(Icons.edit_outlined),
            onPressed: () => Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => AddEditItemScreen(
                  itemType: item.type,
                  existingItem: item,
                ),
              ),
            ),
          ),
          IconButton(
            icon: const Icon(Icons.delete_outline, color: Colors.red),
            onPressed: () => _confirmDelete(context, item),
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // Header
          Center(
            child: Column(
              children: [
                Text(item.type.icon, style: const TextStyle(fontSize: 48)),
                const SizedBox(height: 8),
                Text(item.title,
                    style: Theme.of(context).textTheme.headlineSmall),
                if (item.folderName != null) ...[
                  const SizedBox(height: 4),
                  Chip(label: Text(item.folderName!, style: const TextStyle(fontSize: 12))),
                ],
                if (isEnhanced)
                  const Chip(
                    label: Text('🔒 加强安全', style: TextStyle(fontSize: 11, color: Colors.red)),
                    backgroundColor: Color(0xFFFFEBEE),
                  ),
              ],
            ),
          ),
          const SizedBox(height: 24),
          // Fields
          ..._buildFields(item, requireAuthThen),
        ],
      ),
    );
  }

  List<Widget> _buildFields(
      VaultItem item, Future<void> Function(VoidCallback) requireAuth) {
    final sensitiveAction = (VoidCallback action) => requireAuth(action);
    final sensitive = item.securityLevel == SecurityLevel.enhanced;

    return <Widget>[
      if (item.type == ItemType.password) ...[
        FieldRow(label: '用户名', value: item.username),
        FieldRow(label: '密码', value: item.password, isPassword: true,
            isSensitive: sensitive, onRequireAuth: () {}),
        FieldRow(label: '邮箱', value: item.email),
        FieldRow(label: '手机号', value: item.phone),
        FieldRow(label: '网址', value: item.url),
        FieldRow(label: '备注', value: item.notes),
      ],
      if (item.type == ItemType.bankCard) ...[
        FieldRow(label: '银行', value: item.bankName),
        FieldRow(label: '卡号', value: item.cardNumber,
            isSensitive: sensitive, onRequireAuth: () {}),
        FieldRow(label: '持卡人', value: item.cardHolder),
        FieldRow(label: '有效期', value: item.expiryDate),
        FieldRow(label: 'CVV', value: item.cvv, isPassword: true,
            isSensitive: sensitive, onRequireAuth: () {}),
        FieldRow(label: '取款密码', value: item.withdrawalPassword, isPassword: true,
            isSensitive: sensitive, onRequireAuth: () {}),
        FieldRow(label: '备注', value: item.notes),
      ],
      if (item.type == ItemType.idDocument) ...[
        FieldRow(label: '类型', value: item.idType),
        FieldRow(label: '证件号', value: item.idNumber,
            isSensitive: sensitive, onRequireAuth: () {}),
        FieldRow(label: '姓名', value: item.idName),
        FieldRow(label: '签发机关', value: item.issuingAuthority),
        FieldRow(label: '有效期', value: item.validUntil),
        FieldRow(label: '备注', value: item.notes),
      ],
      if (item.type == ItemType.secureNote) ...[
        Card(
          child: Padding(
            padding: const EdgeInsets.all(12),
            child: SelectableText(item.noteContent ?? ''),
          ),
        ),
      ],
    ];
  }

  void _confirmDelete(BuildContext context, VaultItem item) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('确认删除'),
        content: Text('确定要删除"${item.title}"吗？此操作不可撤销。'),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('取消')),
          FilledButton(
            onPressed: () {
              context.read<VaultService>().deleteItem(item.id);
              Navigator.pop(context); // close dialog
              Navigator.pop(context); // go back to list
            },
            style: FilledButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('删除'),
          ),
        ],
      ),
    );
  }
}
```

- [ ] **Step 4: Commit**

```bash
cd h:/MyPasswords/infovault && git add -A && git commit -m "feat: add detail screen with field copy, secondary auth, and delete"
```

---

### Task 14: 搜索页面

**Files:**
- Create: `infovault/lib/screens/search_screen.dart`

- [ ] **Step 1: 实现全屏搜索页**

Create: `infovault/lib/screens/search_screen.dart`

```dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/vault_service.dart';
import '../models/vault_item.dart';
import '../models/item_type.dart';
import '../widgets/item_list_tile.dart';
import 'item_detail_screen.dart';

class SearchScreen extends StatefulWidget {
  const SearchScreen({super.key});
  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  final _searchController = TextEditingController();
  List<VaultItem> _results = [];

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _search(String query) {
    setState(() {
      _results = context.read<VaultService>().searchDetailed(query);
    });
  }

  @override
  Widget build(BuildContext context) {
    final grouped = _groupByType(_results);

    return Scaffold(
      appBar: AppBar(
        title: TextField(
          controller: _searchController,
          autofocus: true,
          decoration: const InputDecoration(
            hintText: '搜索平台名、用户名、卡号、证件号...',
            border: InputBorder.none,
          ),
          onChanged: _search,
        ),
        actions: [
          if (_searchController.text.isNotEmpty)
            IconButton(
              icon: const Icon(Icons.clear),
              onPressed: () {
                _searchController.clear();
                _search('');
              },
            ),
        ],
      ),
      body: _searchController.text.isEmpty
          ? Center(
              child: Text('输入关键词开始搜索',
                  style: Theme.of(context).textTheme.bodyLarge))
          : _results.isEmpty
              ? const Center(child: Text('没有找到结果'))
              : ListView(
                  children: [
                    for (final entry in grouped.entries)
                      if (entry.value.isNotEmpty) ...[
                        Padding(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 16, vertical: 8),
                          child: Text(
                            '${entry.key.icon} ${entry.key.label} (${entry.value.length})',
                            style: Theme.of(context).textTheme.titleSmall,
                          ),
                        ),
                        for (final item in entry.value)
                          ItemListTile(
                            item: item,
                            onTap: () => Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) =>
                                    ItemDetailScreen(itemId: item.id),
                              ),
                            ),
                          ),
                      ],
                  ],
                ),
    );
  }

  Map<ItemType, List<VaultItem>> _groupByType(List<VaultItem> items) {
    final map = <ItemType, List<VaultItem>>{};
    for (final item in items) {
      map.putIfAbsent(item.type, () => []).add(item);
    }
    return map;
  }
}
```

- [ ] **Step 2: Commit**

```bash
cd h:/MyPasswords/infovault && git add -A && git commit -m "feat: add full-screen search with type-grouped results"
```

---

### Task 15: 智能分类服务

**Files:**
- Create: `infovault/lib/services/smart_category_service.dart`
- Create: `test/services/smart_category_service_test.dart`

- [ ] **Step 1: 编写测试**

Create: `test/services/smart_category_service_test.dart`

```dart
import 'package:flutter_test/flutter_test.dart';
import 'package:infovault/services/smart_category_service.dart';

void main() {
  final service = SmartCategoryService();

  group('SmartCategoryService', () {
    test('should classify WeChat as 社交', () {
      expect(service.suggest('微信'), '社交');
      expect(service.suggest('wechat'), '社交');
    });

    test('should classify Alipay as 金融', () {
      expect(service.suggest('支付宝'), '金融');
      expect(service.suggest('alipay'), '金融');
    });

    test('should classify GitHub as 开发', () {
      expect(service.suggest('GitHub'), '开发');
      expect(service.suggest('github.com'), '开发');
    });

    test('should return null for unknown platform', () {
      expect(service.suggest('某不知名平台'), null);
    });

    test('should match by URL', () {
      expect(service.suggestByUrl('taobao.com'), '购物');
      expect(service.suggestByUrl('gmail.com'), '邮箱');
    });
  });
}
```

- [ ] **Step 2: 实现智能分类服务**

Create: `infovault/lib/services/smart_category_service.dart`

```dart
class SmartCategoryService {
  final Map<String, String> _platformCategoryMap = {
    // 社交
    '微信': '社交', 'wechat': '社交', 'QQ': '社交',
    '微博': '社交', 'weibo': '社交', '抖音': '社交',
    'tiktok': '社交', '小红书': '社交', 'telegram': '社交',
    'discord': '社交', 'slack': '社交', 'whatsapp': '社交',
    'line': '社交', 'signal': '社交',

    // 金融
    '支付宝': '金融', 'alipay': '金融', '微信支付': '金融',
    '招商银行': '金融', '工商银行': '金融', '建设银行': '金融',
    '农业银行': '金融', '中国银行': '金融', '交通银行': '金融',
    'paypal': '金融', 'stripe': '金融',

    // 邮箱
    'gmail': '邮箱', 'outlook': '邮箱', 'qq邮箱': '邮箱',
    '163邮箱': '邮箱', '126邮箱': '邮箱', 'yahoo': '邮箱',
    'protonmail': '邮箱',

    // 开发
    'github': '开发', 'gitlab': '开发', 'bitbucket': '开发',
    'stackoverflow': '开发', 'docker': '开发', 'npm': '开发',
    'vercel': '开发', 'aws': '开发', 'azure': '开发',
    'google cloud': '开发', 'cloudflare': '开发',

    // 购物
    '淘宝': '购物', 'taobao': '购物', '天猫': '购物',
    '京东': '购物', 'jd': '购物', '拼多多': '购物',
    'amazon': '购物', 'ebay': '购物',

    // 娱乐
    'netflix': '娱乐', 'spotify': '娱乐', 'youtube': '娱乐',
    'bilibili': '娱乐', 'b站': '娱乐', 'steam': '娱乐',
    'epic': '娱乐', 'nintendo': '娱乐',

    // 办公
    'notion': '办公', '飞书': '办公', '钉钉': '办公',
    '企业微信': '办公', 'google drive': '办公', 'dropbox': '办公',
    'onedrive': '办公', 'figma': '办公', 'canva': '办公',

    // 证件
    '身份证': '证件', '护照': '证件', '驾照': '证件',
    '社保卡': '证件', '户口本': '证件',
  };

  final Map<String, String> _urlCategoryMap = {
    'weixin': '社交', 'wechat': '社交', 'qq.com': '社交',
    'weibo.com': '社交', 'douyin.com': '社交',
    'alipay.com': '金融', 'paypal.com': '金融',
    'github.com': '开发', 'gitlab.com': '开发',
    'taobao.com': '购物', 'jd.com': '购物', 'amazon.com': '购物',
    'gmail.com': '邮箱', 'outlook.com': '邮箱',
    'youtube.com': '娱乐', 'bilibili.com': '娱乐', 'steam.com': '娱乐',
    'notion.so': '办公', 'feishu.cn': '办公',
  };

  String? suggest(String platformNameOrUrl) {
    final lower = platformNameOrUrl.toLowerCase().trim();

    // Exact match with platform name
    if (_platformCategoryMap.containsKey(lower)) {
      return _platformCategoryMap[lower];
    }

    // Fuzzy match with platform name
    for (final entry in _platformCategoryMap.entries) {
      if (lower.contains(entry.key.toLowerCase()) ||
          entry.key.toLowerCase().contains(lower)) {
        return entry.value;
      }
    }

    // Try URL matching
    return suggestByUrl(lower);
  }

  String? suggestByUrl(String url) {
    final lower = url.toLowerCase().trim();

    for (final entry in _urlCategoryMap.entries) {
      if (lower.contains(entry.key)) {
        return entry.value;
      }
    }

    // TLD-based heuristic
    if (lower.endsWith('.com.cn')) return '购物';
    if (lower.contains('bank') || lower.contains('银行')) return '金融';
    if (lower.contains('mail') || lower.contains('邮箱')) return '邮箱';
    if (lower.contains('gov')) return '证件';

    return null;
  }
}
```

- [ ] **Step 3: 运行测试**

Run:
```bash
cd h:/MyPasswords/infovault && flutter test test/services/smart_category_service_test.dart
```
Expected: 所有测试通过。

- [ ] **Step 4: Commit**

```bash
cd h:/MyPasswords/infovault && git add -A && git commit -m "feat: add smart category service with 50+ platform mappings"
```

---

### Task 16: 剪贴板服务

**Files:**
- Create: `infovault/lib/services/clipboard_service.dart`
- Create: `test/services/clipboard_service_test.dart`

- [ ] **Step 1: 编写测试**

Create: `test/services/clipboard_service_test.dart`

```dart
import 'package:flutter_test/flutter_test.dart';
import 'package:infovault/services/clipboard_service.dart';

void main() {
  group('ClipboardService', () {
    test('should track copied value', () {
      final service = ClipboardService();
      service.copy('my_secret');
      expect(service.lastCopiedValue, 'my_secret');
    });

    test('should clear scheduled timer active', () {
      final service = ClipboardService();
      service.copy('test_value');
      expect(service.hasPendingClear, true);
    });

    test('should cancel previous timer on new copy', () {
      final service = ClipboardService();
      service.copy('first');
      service.copy('second');
      expect(service.lastCopiedValue, 'second');
    });
  });
}
```

- [ ] **Step 2: 实现剪贴板服务**

Create: `infovault/lib/services/clipboard_service.dart`

```dart
import 'dart:async';
import 'package:flutter/services.dart';
import '../utils/constants.dart';

class ClipboardService {
  Timer? _clearTimer;
  String? _lastCopiedValue;

  String? get lastCopiedValue => _lastCopiedValue;
  bool get hasPendingClear => _clearTimer != null && _clearTimer!.isActive;

  void copy(String value) {
    _clearTimer?.cancel();
    _lastCopiedValue = value;
    Clipboard.setData(ClipboardData(text: value));

    _clearTimer = Timer(
      Duration(seconds: AppConstants.clipboardClearSeconds),
      () {
        _tryClear();
      },
    );
  }

  Future<void> _tryClear() async {
    if (_lastCopiedValue == null) return;

    try {
      final currentContent = await Clipboard.getData(Clipboard.kTextPlain);
      if (currentContent?.text == _lastCopiedValue) {
        await Clipboard.setData(const ClipboardData(text: ''));
      }
    } catch (_) {
      // Silently ignore clipboard read errors
    } finally {
      _lastCopiedValue = null;
      _clearTimer = null;
    }
  }

  void dispose() {
    _clearTimer?.cancel();
    _lastCopiedValue = null;
  }
}
```

- [ ] **Step 3: Commit**

```bash
cd h:/MyPasswords/infovault && git add -A && git commit -m "feat: add clipboard service with 60s auto-clear"
```

---

### Task 17: 设置页面

**Files:**
- Create: `infovault/lib/screens/settings_screen.dart`

- [ ] **Step 1: 实现设置页**

Create: `infovault/lib/screens/settings_screen.dart`

```dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/auth_service.dart';
import '../services/vault_service.dart';
import 'folder_management_screen.dart';
import '../utils/constants.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('我的')),
      body: ListView(
        children: [
          // Security section
          _SectionHeader(title: '安全'),
          ListTile(
            leading: const Icon(Icons.lock_outline),
            title: const Text('自动锁定'),
            subtitle: const Text('App 切换到后台后的锁定时间'),
            trailing: const Text('5 分钟'),
            onTap: () {},
          ),
          ListTile(
            leading: const Icon(Icons.history),
            title: const Text('剪贴板自动清空'),
            subtitle: const Text('复制后60秒自动清空'),
            trailing: Switch(
              value: true,
              onChanged: (_) {},
            ),
          ),
          const Divider(),

          // Data section
          _SectionHeader(title: '数据'),
          ListTile(
            leading: const Icon(Icons.folder_outlined),
            title: const Text('管理文件夹'),
            trailing: const Icon(Icons.chevron_right),
            onTap: () => Navigator.push(
              context,
              MaterialPageRoute(
                  builder: (_) => const FolderManagementScreen()),
            ),
          ),
          ListTile(
            leading: const Icon(Icons.file_upload_outlined),
            title: const Text('导出数据'),
            subtitle: const Text('导出加密备份文件'),
            onTap: () {},
          ),
          ListTile(
            leading: const Icon(Icons.file_download_outlined),
            title: const Text('导入数据'),
            subtitle: const Text('从备份文件恢复'),
            onTap: () {},
          ),
          const Divider(),

          // About section
          _SectionHeader(title: '关于'),
          ListTile(
            leading: const Icon(Icons.info_outline),
            title: const Text('关于信息保险箱'),
            subtitle: const Text('版本 1.0.0'),
            onTap: () {},
          ),
          ListTile(
            leading: const Icon(Icons.security_outlined),
            title: const Text('安全说明'),
            subtitle: const Text('了解你的数据如何被保护'),
            onTap: () {},
          ),
          const SizedBox(height: 32),
          Center(
            child: TextButton(
              onPressed: () {
                context.read<AuthService>().lock();
              },
              child: const Text('🔒  立即锁定', style: TextStyle(color: Colors.red)),
            ),
          ),
          const SizedBox(height: 32),
        ],
      ),
    );
  }
}

class _SectionHeader extends StatelessWidget {
  final String title;
  const _SectionHeader({required this.title});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 4),
      child: Text(
        title,
        style: TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w600,
          color: Theme.of(context).colorScheme.primary,
        ),
      ),
    );
  }
}
```

- [ ] **Step 2: 实现文件夹管理页**

Create: `infovault/lib/screens/folder_management_screen.dart`

```dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/vault_service.dart';
import '../models/folder.dart';

class FolderManagementScreen extends StatelessWidget {
  const FolderManagementScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('管理文件夹')),
      body: Consumer<VaultService>(
        builder: (context, vault, _) {
          return ListView.builder(
            itemCount: vault.folders.length,
            itemBuilder: (context, index) {
              final folder = vault.folders[index];
              return ListTile(
                leading: const Icon(Icons.folder),
                title: Text(folder.name),
                trailing: IconButton(
                  icon: const Icon(Icons.delete_outline, color: Colors.red),
                  onPressed: () {
                    showDialog(
                      context: context,
                      builder: (_) => AlertDialog(
                        title: const Text('删除文件夹'),
                        content: Text('确定要删除"${folder.name}"吗？文件夹内的条目不会被删除。'),
                        actions: [
                          TextButton(
                              onPressed: () => Navigator.pop(context),
                              child: const Text('取消')),
                          FilledButton(
                            onPressed: () {
                              context
                                  .read<VaultService>()
                                  .deleteFolder(folder.id);
                              Navigator.pop(context);
                            },
                            style: FilledButton.styleFrom(
                                backgroundColor: Colors.red),
                            child: const Text('删除'),
                          ),
                        ],
                      ),
                    );
                  },
                ),
              );
            },
          );
        },
      ),
    );
  }
}
```

- [ ] **Step 3: Commit**

```bash
cd h:/MyPasswords/infovault && git add -A && git commit -m "feat: add settings screen and folder management"
```

---

### Task 18: 集成测试验证

**Files:**
- Modify: `infovault/test/` (确保所有已有测试通过)

- [ ] **Step 1: 运行所有测试**

Run:
```bash
cd h:/MyPasswords/infovault && flutter test
```
Expected: 所有测试通过。

- [ ] **Step 2: 运行 Flutter analyze**

Run:
```bash
cd h:/MyPasswords/infovault && flutter analyze
```
Expected: 无错误，无警告。

- [ ] **Step 3: 修复测试中发现的问题**

根据步骤 1-2 的结果，修复编译错误、测试失败或警告。

- [ ] **Step 4: Commit**

```bash
cd h:/MyPasswords/infovault && git add -A && git commit -m "chore: fix lint issues and ensure all tests pass"
```

---

## 实现完成后

运行:
```bash
cd h:/MyPasswords/infovault && flutter run
```

确认 App 在 Android 模拟器或设备上正常运行，覆盖以下流程：
1. 首次打开 → 创建主密码
2. 关闭重开 → 输入主密码解锁
3. 添加一条微信密码
4. 添加一张银行卡
5. 使用搜索功能
6. 查看详情，复制密码
7. 删除条目
8. 自动锁定测试

---

## 注意事项

1. **VaultItem 模型**（Task 2）：模型的 `toMap()`、`fromMap()`、`copyWith()` 方法因篇幅限制未完整展开，需根据字段完整实现。所有 nullable 字段对应数据库可空字段，`photoPaths` 用 `json.encode`/`json.decode` 处理。

2. **加密服务**（Task 3）：`AesGcm` 的实现需要引入 `pointycastle` 或 Flutter 1.18+ 内置的加密 API。请根据 pub.dev 选用最合适的包。当前代码为骨架，具体实现需完整填充。

3. **窗口管理**（Task 10）：需在 `AppLifecycleListener` 中监听 App 回到前台事件，触发锁定检查。

4. **照片附件**：Phase 1 后期迭代任务，基础实现可用 `image_picker` + `path_provider` + 加密存储添加到 `AddEditItemScreen` 中。

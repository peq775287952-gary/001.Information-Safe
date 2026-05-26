import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:infovault/services/auth_service.dart';
import 'package:infovault/services/encryption_service.dart';
import 'package:infovault/services/vault_service.dart';
import 'package:infovault/services/export_import_service.dart';
import 'package:infovault/services/database_service.dart';
import 'package:infovault/models/vault_item.dart';
import 'package:infovault/models/folder.dart';
import 'package:infovault/screens/settings_screen.dart';

class _StubDb extends DatabaseService {
  @override
  Future<List<VaultItem>> getAllItems() async => [];
  @override
  Future<List<Folder>> getAllFolders() async => [];
  @override
  Future<void> insertItem(VaultItem item) async {}
  @override
  Future<void> updateItem(VaultItem item) async {}
  @override
  Future<void> deleteItem(String id) async {}
  @override
  Future<void> insertFolder(Folder folder) async {}
  @override
  Future<void> deleteFolder(String id) async {}
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  final _mockStorage = <String, String>{};

  setUpAll(() {
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(
      const MethodChannel('plugins.it_nomads.com/flutter_secure_storage'),
      (call) async {
        final args = call.arguments as Map<dynamic, dynamic>;
        final key = args['key'] as String;
        switch (call.method) {
          case 'write':
            _mockStorage[key] = args['value'] as String;
            return null;
          case 'read':
            return _mockStorage[key];
          case 'delete':
            _mockStorage.remove(key);
            return null;
          case 'containsKey':
            return _mockStorage.containsKey(key);
          case 'readAll':
            return Map<String, String>.from(_mockStorage);
          case 'deleteAll':
            _mockStorage.clear();
            return null;
          default:
            return null;
        }
      },
    );
  });

  late AuthService authService;
  late VaultService vaultService;
  late ExportImportService exportImportService;

  setUp(() {
    _mockStorage.clear();
    final encryptionService = EncryptionService();
    final db = _StubDb();
    authService = AuthService(encryptionService);
    vaultService = VaultService(db, encryptionService);
    vaultService.setEncryptionKey(encryptionService.generateKey());
    exportImportService = ExportImportService(db, encryptionService, vaultService);
  });

  Widget buildTestWidget() {
    return MaterialApp(
      home: MultiProvider(
        providers: [
          ChangeNotifierProvider<AuthService>.value(value: authService),
          ChangeNotifierProvider<VaultService>.value(value: vaultService),
          Provider<ExportImportService>.value(value: exportImportService),
        ],
        child: const SettingsScreen(),
      ),
    );
  }

  testWidgets('should display settings list items', (tester) async {
    await tester.pumpWidget(buildTestWidget());
    await tester.pumpAndSettle();

    expect(find.text('我的'), findsOneWidget);
    expect(find.text('自动锁定'), findsOneWidget);
    expect(find.text('剪贴板自动清空'), findsOneWidget);
    expect(find.text('修改主密码'), findsOneWidget);
    expect(find.text('管理文件夹'), findsOneWidget);
    expect(find.text('导出数据'), findsOneWidget);
    expect(find.text('导入数据'), findsOneWidget);

    // Scroll to bottom to bring "关于信息保险箱" into viewport
    await tester.scrollUntilVisible(find.text('关于信息保险箱'), 100);
    expect(find.text('关于信息保险箱'), findsOneWidget);
  });
}

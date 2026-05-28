import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:provider/provider.dart';
import 'package:infovault/app_windows.dart';
import 'package:infovault/services/auth_service.dart';
import 'package:infovault/services/encryption_service.dart';
import 'package:infovault/services/vault_service.dart';
import 'package:infovault/services/database_service.dart';
import 'package:infovault/services/export_import_service.dart';
import 'package:infovault/services/photo_service.dart';

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  late AuthService authService;
  late VaultService vaultService;
  final encryptionService = EncryptionService();

  setUp(() async {
    final db = DatabaseService(dbName: 'integration_test_win.db');
    authService = AuthService(encryptionService);
    vaultService = VaultService(db, encryptionService);
    authService.setVaultService(vaultService);
  });

  Widget buildApp() {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider<AuthService>.value(value: authService),
        ChangeNotifierProvider<VaultService>.value(value: vaultService),
        Provider<PhotoService>.value(value: PhotoService(encryptionService)),
        Provider<ExportImportService>.value(
          value: ExportImportService(
            DatabaseService(dbName: 'integration_test_win.db'),
            encryptionService,
            vaultService,
          ),
        ),
      ],
      child: const InfoVaultAppWindows(),
    );
  }

  group('Windows Fluent UI', () {
    testWidgets('full flow: create password → vault → lock → unlock',
        (tester) async {
      await tester.pumpWidget(buildApp());
      await tester.pumpAndSettle();

      // CreatePasswordScreenWin appears
      expect(find.text('创建主密码'), findsOneWidget);
      expect(find.text('创建并进入'), findsOneWidget);

      // Fill and submit master password using text fields
      final inputFields = find.byType(EditableText);
      expect(inputFields, findsAtLeast(2));

      await tester.tap(inputFields.first);
      await tester.pumpAndSettle();
      tester.testTextInput.enterText('MyPass123');
      await tester.pumpAndSettle();

      await tester.tap(inputFields.last);
      await tester.pumpAndSettle();
      tester.testTextInput.enterText('MyPass123');
      await tester.pumpAndSettle();

      await tester.tap(find.text('创建并进入'));
      await tester.pumpAndSettle();

      // MainShellWin with NavigationView
      expect(find.text('信息保险箱'), findsWidgets);

      // Check vault screen elements
      expect(find.text('全部'), findsOneWidget);
      expect(find.text('登录密码'), findsOneWidget);

      // Navigate to Settings via PaneItem
      await tester.tap(find.text('我的'));
      await tester.pumpAndSettle();
      expect(find.text('自动锁定'), findsOneWidget);

      // Lock via footer button
      await tester.tap(find.text('锁定'));
      await tester.pumpAndSettle();

      // LockScreenWin appears
      expect(find.text('请输入主密码解锁'), findsOneWidget);

      // Unlock
      final unlockFields = find.byType(EditableText);
      await tester.tap(unlockFields.first);
      await tester.pumpAndSettle();
      tester.testTextInput.enterText('MyPass123');
      await tester.pumpAndSettle();

      await tester.tap(find.text('解锁'));
      await tester.pumpAndSettle();

      // Back to vault
      expect(find.text('信息保险箱'), findsWidgets);
    });
  });
}

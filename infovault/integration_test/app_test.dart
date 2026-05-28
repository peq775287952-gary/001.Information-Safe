import 'dart:io' show Directory, File;

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:path_provider/path_provider.dart';
import 'package:infovault/app.dart';
import 'package:infovault/services/auth_service.dart';
import 'package:infovault/services/encryption_service.dart';
import 'package:infovault/services/vault_service.dart';
import 'package:infovault/services/database_service.dart';
import 'package:infovault/services/export_import_service.dart';
import 'package:infovault/services/photo_service.dart';
import 'package:provider/provider.dart';

void main() {
  final binding = IntegrationTestWidgetsFlutterBinding.ensureInitialized();
  binding.framePolicy = LiveTestWidgetsFlutterBindingFramePolicy.fullyLive;

  late AuthService authService;
  late VaultService vaultService;
  final encryptionService = EncryptionService();
  String? screenshotDir;

  setUp(() async {
    final db = DatabaseService(dbName: 'integration_test.db');
    authService = AuthService(encryptionService);
    vaultService = VaultService(db, encryptionService);
    authService.setVaultService(vaultService);

    // Use app's private documents directory to avoid permission issues
    final appDir = await getApplicationDocumentsDirectory();
    screenshotDir = '${appDir.path}/screenshots';
    await Directory(screenshotDir!).create(recursive: true);
    debugPrint('Screenshot directory: $screenshotDir');
  });

  Widget buildApp() {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider<AuthService>.value(value: authService),
        ChangeNotifierProvider<VaultService>.value(value: vaultService),
        Provider<PhotoService>.value(value: PhotoService(encryptionService)),
        Provider<ExportImportService>.value(
          value: ExportImportService(
            DatabaseService(dbName: 'integration_test.db'),
            encryptionService,
            vaultService,
          ),
        ),
      ],
      child: const InfoVaultApp(),
    );
  }

  Future<void> enterTextIntoField(
      WidgetTester tester, Finder field, String text) async {
    await tester.tap(field);
    await tester.pumpAndSettle();
    tester.testTextInput.enterText(text);
    await tester.pumpAndSettle();
  }

  Future<void> takeScreenshot(String name) async {
    final bytes = await binding.takeScreenshot(name);
    if (screenshotDir != null) {
      final file = File('$screenshotDir/$name.png');
      await file.writeAsBytes(bytes);
      debugPrint('Screenshot saved: ${file.path}');
    }
  }

  group('Full app flow', () {
    testWidgets('create password, add item, lock and unlock',
        (tester) async {
      await tester.pumpWidget(buildApp());
      await tester.pumpAndSettle();

      // Enable Android screenshot surface (must be called once before any screenshot)
      await binding.convertFlutterSurfaceToImage();

      // Step 1: CreatePasswordScreen appears
      expect(find.text('创建主密码'), findsOneWidget);
      expect(find.text('创建并进入'), findsOneWidget);
      await takeScreenshot('01-create-password-screen');

      // Step 2: Fill and submit master password
      final fields = find.byType(TextFormField);
      await enterTextIntoField(tester, fields.first, 'MyPass123');
      await enterTextIntoField(tester, fields.last, 'MyPass123');
      await tester.tap(find.text('创建并进入'));
      await tester.pump();
      await tester.pumpAndSettle();

      // Step 3: Navigated to vault (MainShell)
      expect(find.text('信息保险箱'), findsWidgets);
      await takeScreenshot('02-vault-empty');

      // Step 4: Tap + FAB to add new item
      await tester.tap(find.byType(FloatingActionButton));
      await tester.pumpAndSettle();

      // Step 5: Should see type selection bottom sheet
      expect(find.text('选择类型'), findsOneWidget);
      await takeScreenshot('03-type-sheet');

      // Tap password type to navigate to add/edit screen
      await tester.tap(find.text('登录密码'));
      await tester.pumpAndSettle();

      // Step 6: Should be on add/edit screen
      expect(find.text('保存'), findsOneWidget);
      await takeScreenshot('04-add-item-form');

      // Fill in title field and save
      final addFields = find.byType(TextFormField);
      await enterTextIntoField(tester, addFields.first, 'TestAccount');
      await tester.tap(find.text('保存'));
      await tester.pumpAndSettle();

      // Step 7: Item should appear in vault
      expect(find.text('TestAccount'), findsOneWidget);
      await takeScreenshot('05-vault-with-item');

      // Step 8: Tap item to view detail
      await tester.tap(find.text('TestAccount'));
      await tester.pumpAndSettle();
      await takeScreenshot('06-item-detail');

      // Step 9: Go back to vault
      await tester.tap(find.byIcon(Icons.arrow_back));
      await tester.pumpAndSettle();

      // Step 10: Navigate to Settings (third tab)
      await tester.tap(find.text('我的'));
      await tester.pumpAndSettle();
      expect(find.text('自动锁定'), findsOneWidget);
      await takeScreenshot('07-settings');

      // Step 11: Lock the vault - scroll to find the button
      await tester.scrollUntilVisible(find.text('🔒  立即锁定'), 500);
      await tester.pumpAndSettle();
      await tester.tap(find.text('🔒  立即锁定'));
      await tester.pumpAndSettle();

      // Step 12: LockScreen appears
      expect(find.text('请输入主密码解锁'), findsOneWidget);
      await takeScreenshot('08-lock-screen');

      // Step 13: Unlock with correct password
      final unlockField = find.byType(TextField);
      await enterTextIntoField(tester, unlockField, 'MyPass123');
      await tester.tap(find.text('解锁'));
      await tester.pumpAndSettle();

      // Step 14: Back to vault, item still there
      expect(find.text('信息保险箱'), findsWidgets);
      await takeScreenshot('09-unlocked-vault');
    });
  });

}

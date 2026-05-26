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

      // Step 11: Lock the vault
      await tester.tap(find.textContaining('立即锁定'));
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

  group('Enhanced security level test', () {
    testWidgets('create enhanced item and verify secondary auth',
        (tester) async {
      await tester.pumpWidget(buildApp());
      await tester.pumpAndSettle();

      // Enable Android screenshot surface
      await binding.convertFlutterSurfaceToImage();

      // Step 1: Create master password
      final fields = find.byType(TextFormField);
      await enterTextIntoField(tester, fields.first, 'MyPass123');
      await enterTextIntoField(tester, fields.last, 'MyPass123');
      await tester.tap(find.text('创建并进入'));
      await tester.pump();
      await tester.pumpAndSettle();

      // Step 2: Add a new item with enhanced security
      await tester.tap(find.byType(FloatingActionButton));
      await tester.pumpAndSettle();
      await tester.tap(find.text('登录密码'));
      await tester.pumpAndSettle();

      // Fill in the form
      final addFields = find.byType(TextFormField);
      await enterTextIntoField(tester, addFields.first, 'SecureBank');
      
      // Find and tap the "加强" security level chip
      // The security level selector is a Card with "安全等级" label and two ChoiceChips
      // Tap the card containing "安全等级" first to ensure it's visible
      final securityCard = find.textContaining('安全等级');
      await tester.tap(securityCard);
      await tester.pumpAndSettle();
      
      // Now find and tap the second ChoiceChip (enhanced)
      // Use find.byWidget to find all widgets and filter by type
      final allWidgets = tester.allWidgets.toList();
      final choiceChips = allWidgets.whereType<ChoiceChip>().toList();
      expect(choiceChips.length, 2);
      // Tap the second chip (enhanced)
      await tester.tap(find.byWidget(choiceChips.last));
      await tester.pumpAndSettle();

      // Save the item
      await tester.tap(find.text('保存'));
      await tester.pumpAndSettle();

      // Verify item appears in vault with enhanced indicator
      expect(find.text('SecureBank'), findsOneWidget);
      await takeScreenshot('10-enhanced-item-list');

      // Step 3: Tap the enhanced item - should trigger secondary auth dialog
      await tester.tap(find.text('SecureBank'));
      await tester.pumpAndSettle();

      // Verify secondary auth dialog appears
      expect(find.text('身份验证'), findsOneWidget);
      expect(find.text('此条目为"加强安全"等级，请验证身份：'), findsOneWidget);
      await takeScreenshot('11-secondary-auth-dialog');

      // Step 4: Enter correct password to verify
      final passwordField = find.byType(TextField);
      await enterTextIntoField(tester, passwordField, 'MyPass123');
      await tester.tap(find.text('验证'));
      await tester.pumpAndSettle();

      // Verify item detail page is shown (auth passed)
      expect(find.text('SecureBank'), findsOneWidget);
      expect(find.text('用户名'), findsOneWidget);
      await takeScreenshot('12-enhanced-item-detail');

      // Step 5: Go back to vault
      await tester.tap(find.byIcon(Icons.arrow_back));
      await tester.pumpAndSettle();

      // Step 6: Tap the enhanced item again - should trigger secondary auth again
      await tester.tap(find.text('SecureBank'));
      await tester.pumpAndSettle();

      // Verify secondary auth dialog appears again (security level enforced)
      expect(find.text('身份验证'), findsOneWidget);
      await takeScreenshot('13-secondary-auth-again');

      // Step 7: Enter wrong password
      final wrongPasswordField = find.byType(TextField);
      await enterTextIntoField(tester, wrongPasswordField, 'WrongPass');
      await tester.tap(find.text('验证'));
      await tester.pumpAndSettle();

      // Verify error message appears
      expect(find.text('密码错误'), findsOneWidget);
      await takeScreenshot('14-auth-error');

      // Step 8: Enter correct password again
      await enterTextIntoField(tester, wrongPasswordField, 'MyPass123');
      await tester.tap(find.text('验证'));
      await tester.pumpAndSettle();

      // Verify item detail page is shown
      expect(find.text('SecureBank'), findsOneWidget);
      await takeScreenshot('15-auth-success-after-error');

      // Step 9: Cancel the auth dialog
      await tester.tap(find.byIcon(Icons.arrow_back));
      await tester.pumpAndSettle();
      await tester.tap(find.text('SecureBank'));
      await tester.pumpAndSettle();

      // Tap cancel button
      await tester.tap(find.text('取消'));
      await tester.pumpAndSettle();

      // Verify we're back to vault (auth was cancelled)
      expect(find.text('信息保险箱'), findsWidgets);
      await takeScreenshot('16-auth-cancelled');
    });
  });
}

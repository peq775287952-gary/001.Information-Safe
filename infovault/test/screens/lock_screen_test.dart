import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:infovault/services/auth_service.dart';
import 'package:infovault/services/encryption_service.dart';
import 'package:infovault/screens/lock_screen.dart';

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
  late EncryptionService encryptionService;

  setUp(() async {
    _mockStorage.clear();
    encryptionService = EncryptionService();
    authService = AuthService(encryptionService);

    final salt = encryptionService.generateSalt();
    final key = await encryptionService.deriveKey('MyPass123', salt);
    _mockStorage['master_password_hash'] = base64.encode(key);
    _mockStorage['master_password_salt'] = base64.encode(salt);
    await authService.initialize();
  });

  Widget buildTestWidget() {
    return MaterialApp(
      home: MultiProvider(
        providers: [
          ChangeNotifierProvider<AuthService>.value(value: authService),
        ],
        child: const LockScreen(),
      ),
    );
  }

  testWidgets('should display lock icon and title', (tester) async {
    await tester.pumpWidget(buildTestWidget());
    await tester.pumpAndSettle();

    expect(find.text('信息保险箱'), findsOneWidget);
    expect(find.text('请输入主密码解锁'), findsOneWidget);
    expect(find.byIcon(Icons.lock), findsOneWidget);
  });

  testWidgets('should display unlock button', (tester) async {
    await tester.pumpWidget(buildTestWidget());
    await tester.pumpAndSettle();

    expect(find.text('解锁'), findsOneWidget);
  });

  testWidgets('should show error for wrong password', (tester) async {
    await tester.pumpWidget(buildTestWidget());
    await tester.pumpAndSettle();

    await tester.enterText(find.byType(TextField), 'WrongPassword');
    await tester.tap(find.text('解锁'));
    // pump one frame to start the async unlock flow
    await tester.pump();
    // runAsync lets real async (compute() isolate) complete
    await tester.runAsync(() => Future.delayed(const Duration(seconds: 2)));
    // pump frames to process the result
    await tester.pump();
    await tester.pumpAndSettle();

    expect(find.textContaining('主密码错误'), findsOneWidget);
  });
}
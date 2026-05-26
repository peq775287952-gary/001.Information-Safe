import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:infovault/services/auth_service.dart';
import 'package:infovault/services/encryption_service.dart';
import 'package:infovault/screens/create_password_screen.dart';

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

  setUp(() {
    _mockStorage.clear();
    authService = AuthService(EncryptionService());
  });

  Widget buildTestWidget() {
    return MaterialApp(
      home: ChangeNotifierProvider<AuthService>.value(
        value: authService,
        child: const CreatePasswordScreen(),
      ),
    );
  }

  testWidgets('should display title and description', (tester) async {
    await tester.pumpWidget(buildTestWidget());
    await tester.pumpAndSettle();

    expect(find.text('创建主密码'), findsOneWidget);
    expect(find.textContaining('唯一凭证'), findsOneWidget);
  });

  testWidgets('should display two password fields', (tester) async {
    await tester.pumpWidget(buildTestWidget());
    await tester.pumpAndSettle();

    expect(find.byType(TextFormField), findsNWidgets(2));
  });

  testWidgets('should display create button', (tester) async {
    await tester.pumpWidget(buildTestWidget());
    await tester.pumpAndSettle();

    expect(find.text('创建并进入'), findsOneWidget);
  });

  testWidgets('should show validation error for short password', (tester) async {
    await tester.pumpWidget(buildTestWidget());
    await tester.pumpAndSettle();

    await tester.enterText(find.byType(TextFormField).first, '123');
    await tester.tap(find.text('创建并进入'));
    await tester.pumpAndSettle();

    expect(find.text('主密码至少4位'), findsOneWidget);
  });

  testWidgets('should show validation error for mismatched passwords',
      (tester) async {
    await tester.pumpWidget(buildTestWidget());
    await tester.pumpAndSettle();

    await tester.enterText(find.byType(TextFormField).first, 'password123');
    await tester.enterText(find.byType(TextFormField).last, 'different456');
    await tester.tap(find.text('创建并进入'));
    await tester.pumpAndSettle();

    expect(find.text('两次密码不一致'), findsOneWidget);
  });
}

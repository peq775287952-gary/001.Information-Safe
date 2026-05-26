import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:infovault/services/auth_service.dart';
import 'package:infovault/services/encryption_service.dart';
import 'package:infovault/app.dart';

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

  setUp(() {
    _mockStorage.clear();
  });

  testWidgets('App should render create password screen when no master password',
      (WidgetTester tester) async {
    final encryptionService = EncryptionService();
    final authService = AuthService(encryptionService);

    await tester.pumpWidget(
      ChangeNotifierProvider<AuthService>.value(
        value: authService,
        child: const InfoVaultApp(),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('创建主密码'), findsOneWidget);
  });
}

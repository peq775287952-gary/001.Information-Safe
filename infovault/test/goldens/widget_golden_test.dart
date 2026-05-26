import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:infovault/services/auth_service.dart';
import 'package:infovault/services/encryption_service.dart';
import 'package:infovault/models/item_type.dart';
import 'package:infovault/widgets/type_icon.dart';
import 'package:infovault/widgets/type_filter_bar.dart';
import 'package:infovault/screens/lock_screen.dart';
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

  setUp(() {
    _mockStorage.clear();
  });

  group('TypeIcon golden', () {
    testWidgets('all four type icons', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Center(
              child: Wrap(
                spacing: 16,
                children: const [
                  TypeIcon(type: ItemType.password),
                  TypeIcon(type: ItemType.bankCard),
                  TypeIcon(type: ItemType.idDocument),
                  TypeIcon(type: ItemType.secureNote),
                  TypeIcon(type: ItemType.apiKey),
                ],
              ),
            ),
          ),
        ),
      );

      await expectLater(
        find.byType(Wrap),
        matchesGoldenFile('goldens/type_icons.png'),
      );
    });
  });

  group('TypeFilterBar golden', () {
    testWidgets('filter bar with counts', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: TypeFilterBar(
              selected: null,
              counts: {
                ItemType.password: 5,
                ItemType.bankCard: 2,
                ItemType.idDocument: 1,
                ItemType.secureNote: 3,
                ItemType.apiKey: 2,
              },
              onSelected: (_) {},
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      await expectLater(
        find.byType(TypeFilterBar),
        matchesGoldenFile('goldens/type_filter_bar.png'),
      );
    });
  });

  group('LockScreen golden', () {
    testWidgets('lock screen initial state', (tester) async {
      tester.view.physicalSize = const Size(390, 844);
      tester.view.devicePixelRatio = 3.0;

      final encryptionService = EncryptionService();
      final authService = AuthService(encryptionService);
      await authService.initialize();

      await tester.pumpWidget(
        MaterialApp(
          home: ChangeNotifierProvider<AuthService>.value(
            value: authService,
            child: const LockScreen(),
          ),
        ),
      );
      await tester.pumpAndSettle();

      await expectLater(
        find.byType(LockScreen),
        matchesGoldenFile('goldens/lock_screen.png'),
      );

      tester.view.resetPhysicalSize();
      tester.view.resetDevicePixelRatio();
    });
  });

  group('CreatePasswordScreen golden', () {
    testWidgets('create password screen initial state', (tester) async {
      tester.view.physicalSize = const Size(390, 844);
      tester.view.devicePixelRatio = 3.0;

      final authService = AuthService(EncryptionService());

      await tester.pumpWidget(
        MaterialApp(
          home: ChangeNotifierProvider<AuthService>.value(
            value: authService,
            child: const CreatePasswordScreen(),
          ),
        ),
      );
      await tester.pumpAndSettle();

      await expectLater(
        find.byType(CreatePasswordScreen),
        matchesGoldenFile('goldens/create_password_screen.png'),
      );

      tester.view.resetPhysicalSize();
      tester.view.resetDevicePixelRatio();
    });
  });
}

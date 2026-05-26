import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:infovault/services/encryption_service.dart';
import 'package:infovault/services/auth_service.dart';

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

  setUp(() {
    _mockStorage.clear();
    encryptionService = EncryptionService();
    authService = AuthService(encryptionService);
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

  group('master password existence', () {
    test('should report no master password initially', () {
      expect(authService.hasMasterPassword, false);
    });

    test('should report has master password after setting', () async {
      await authService.setMasterPassword('test123456');
      expect(authService.hasMasterPassword, true);
    });
  });

  group('lock/unlock state', () {
    test('should be locked initially', () {
      expect(authService.isUnlocked, false);
    });

    test('should unlock after setting master password', () async {
      await authService.setMasterPassword('password123');
      expect(authService.isUnlocked, true);
    });

    test('should lock when lock() is called', () async {
      await authService.setMasterPassword('password123');
      authService.lock();
      expect(authService.isUnlocked, false);
    });
  });
}

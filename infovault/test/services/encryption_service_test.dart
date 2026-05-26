import 'package:flutter_test/flutter_test.dart';
import 'package:infovault/services/encryption_service.dart';

void main() {
  late EncryptionService service;

  setUp(() {
    service = EncryptionService();
  });

  group('key derivation', () {
    test('should derive same key from same password and salt', () async {
      const password = 'MyMasterPass123';
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

    test('should derive different keys from same password different salts',
        () async {
      const password = 'SamePassword';
      final key1 = await service.deriveKey(password, service.generateSalt());
      final key2 = await service.deriveKey(password, service.generateSalt());
      expect(key1, isNot(equals(key2)));
    });
  });

  group('encrypt/decrypt', () {
    test('should encrypt and decrypt plaintext correctly', () {
      final key = service.generateKey();
      const plaintext = 'alipay_password_123';
      final encrypted = service.encrypt(plaintext, key);
      expect(encrypted, isNot(plaintext));
      final decrypted = service.decrypt(encrypted, key);
      expect(decrypted, plaintext);
    });

    test('should produce different ciphertext for same plaintext', () {
      final key = service.generateKey();
      final enc1 = service.encrypt('same_text', key);
      final enc2 = service.encrypt('same_text', key);
      expect(enc1, isNot(equals(enc2)));
    });

    test('should throw on wrong key', () {
      final key1 = service.generateKey();
      final key2 = service.generateKey();
      final encrypted = service.encrypt('secret', key1);
      expect(() => service.decrypt(encrypted, key2), throwsA(isA<Exception>()));
    });

    test('should handle empty string', () {
      final key = service.generateKey();
      final encrypted = service.encrypt('', key);
      final decrypted = service.decrypt(encrypted, key);
      expect(decrypted, '');
    });

    test('should handle unicode text', () {
      final key = service.generateKey();
      const plaintext = '密码123!@#日本語';
      final encrypted = service.encrypt(plaintext, key);
      expect(service.decrypt(encrypted, key), plaintext);
    });
  });

  group('salt and key generation', () {
    test('should generate 32-byte salt', () {
      final salt = service.generateSalt();
      expect(salt.length, 32);
    });

    test('should generate 32-byte key', () {
      final key = service.generateKey();
      expect(key.length, 32);
    });

    test('should generate unique salts', () {
      final salts = List.generate(10, (_) => service.generateSalt());
      for (int i = 0; i < salts.length; i++) {
        for (int j = i + 1; j < salts.length; j++) {
          expect(salts[i], isNot(equals(salts[j])));
        }
      }
    });
  });
}

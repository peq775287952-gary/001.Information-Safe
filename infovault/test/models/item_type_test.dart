import 'package:flutter_test/flutter_test.dart';
import 'package:infovault/models/item_type.dart';

void main() {
  group('ItemType', () {
    test('should have 5 values', () {
      expect(ItemType.values, hasLength(5));
    });

    test('fromValue should round-trip for all types', () {
      for (final type in ItemType.values) {
        expect(ItemType.fromValue(type.value), type);
      }
    });

    test('fromValue should throw for unknown value', () {
      expect(() => ItemType.fromValue('not_a_type'), throwsA(isA<StateError>()));
    });

    test('password should have correct label', () {
      expect(ItemType.password.value, 'login_password');
      expect(ItemType.password.label, '登录密码');
    });

    test('bankCard should have correct label', () {
      expect(ItemType.bankCard.value, 'bank_card');
      expect(ItemType.bankCard.label, '银行卡');
    });

    test('idDocument should have correct label', () {
      expect(ItemType.idDocument.value, 'id_document');
      expect(ItemType.idDocument.label, '证件');
    });

    test('secureNote should have correct label', () {
      expect(ItemType.secureNote.value, 'secure_note');
      expect(ItemType.secureNote.label, '安全笔记');
    });

    test('apiKey should have correct label', () {
      expect(ItemType.apiKey.value, 'api_key');
      expect(ItemType.apiKey.label, 'API密钥');
    });
  });
}

import 'package:flutter_test/flutter_test.dart';
import 'package:infovault/models/vault_item.dart';
import 'package:infovault/models/item_type.dart';
void main() {
  group('VaultItem', () {
    test('should create password item correctly', () {
      final item = VaultItem(
        id: '1', type: ItemType.password, title: '微信',
        username: 'user_wechat', password: 'secret123',
        email: 'wx@email.com', phone: '13812345678',
      );
      expect(item.type, ItemType.password);
      expect(item.displaySubtitle, 'user_wechat');
    });

    test('should create bank card with masked subtitle', () {
      final item = VaultItem(
        id: '2', type: ItemType.bankCard, title: '招商银行',
        cardNumber: '6217001234567890',
      );
      expect(item.displaySubtitle, contains('7890'));
    });

    test('should serialize to and from map', () {
      final item = VaultItem(
        id: '3', type: ItemType.secureNote, title: '门锁密码',
        noteContent: '123456',
      );
      final map = item.toMap();
      final restored = VaultItem.fromMap(map);
      expect(restored.id, item.id);
      expect(restored.title, item.title);
      expect(restored.type, item.type);
    });

    test('copyWith should preserve unchanged fields', () {
      final item = VaultItem(
        id: '4', type: ItemType.password, title: 'GitHub',
        username: 'dev',
      );
      final updated = item.copyWith(title: 'GitHub Pro');
      expect(updated.title, 'GitHub Pro');
      expect(updated.username, 'dev');
    });
  });
}

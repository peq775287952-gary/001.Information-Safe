import 'package:flutter_test/flutter_test.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import 'package:infovault/services/database_service.dart';
import 'package:infovault/models/vault_item.dart';
import 'package:infovault/models/item_type.dart';
import 'package:infovault/models/folder.dart';

void main() {
  setUpAll(() {
    sqfliteFfiInit();
    databaseFactory = databaseFactoryFfiNoIsolate;
  });

  late DatabaseService db;

  setUp(() async {
    final uniqueName = 'test_${DateTime.now().microsecondsSinceEpoch}.db';
    db = DatabaseService(dbName: uniqueName);
  });

  tearDown(() async {
    await db.close();
  });

  group('DatabaseService', () {
    test('should insert and retrieve items', () async {
      await db.insertItem(VaultItem(
        id: 'item-1',
        type: ItemType.password,
        title: 'Test Item',
        username: 'tester',
      ));

      final items = await db.getAllItems();
      expect(items, hasLength(1));
      expect(items.first.title, 'Test Item');
    });

    test('should insert and retrieve folders', () async {
      await db.insertFolder(Folder(id: 'f-1', name: 'Work'));

      final folders = await db.getAllFolders();
      expect(folders, hasLength(1));
      expect(folders.first.name, 'Work');
    });

    test('should update existing item', () async {
      await db.insertItem(VaultItem(
        id: 'item-2',
        type: ItemType.password,
        title: 'Old Title',
      ));
      await db.updateItem(VaultItem(
        id: 'item-2',
        type: ItemType.password,
        title: 'New Title',
      ));

      final items = await db.getAllItems();
      expect(items.first.title, 'New Title');
    });

    test('should delete item', () async {
      await db.insertItem(VaultItem(
        id: 'del-1',
        type: ItemType.secureNote,
        title: 'To Delete',
      ));
      await db.deleteItem('del-1');

      final items = await db.getAllItems();
      expect(items, isEmpty);
    });

    test('should filter items by type', () async {
      await db.insertItem(VaultItem(
        id: 'a', type: ItemType.password, title: 'Pwd',
      ));
      await db.insertItem(VaultItem(
        id: 'b', type: ItemType.bankCard, title: 'Bank',
      ));

      final pwdItems = await db.getItemsByType(ItemType.password);
      expect(pwdItems, hasLength(1));
      expect(pwdItems.first.title, 'Pwd');
    });

    test('should filter items by folder', () async {
      await db.insertItem(VaultItem(
        id: 'x', type: ItemType.password, title: 'In Folder',
        folderId: 'folder-x',
      ));
      await db.insertItem(VaultItem(
        id: 'y', type: ItemType.password, title: 'No Folder',
        folderId: '',
      ));

      final inFolder = await db.getItemsByFolder('folder-x');
      expect(inFolder, hasLength(1));
      expect(inFolder.first.title, 'In Folder');
    });

    test('should search items by title', () async {
      await db.insertItem(VaultItem(
        id: 's1', type: ItemType.password, title: 'Alipay',
        username: 'alice',
      ));
      await db.insertItem(VaultItem(
        id: 's2', type: ItemType.password, title: 'WeChat',
        username: 'bob',
      ));

      final results = await db.searchItems('Ali');
      expect(results, hasLength(1));
      expect(results.first.title, 'Alipay');
    });

    test('should search items by username', () async {
      await db.insertItem(VaultItem(
        id: 's3', type: ItemType.password, title: 'Site',
        username: 'unique_user',
      ));

      final results = await db.searchItems('unique_user');
      expect(results, hasLength(1));
    });

    test('should delete folder', () async {
      await db.insertFolder(Folder(id: 'df', name: 'Temp'));
      await db.deleteFolder('df');
      expect(await db.getAllFolders(), isEmpty);
    });

    test('should order items by updated_at DESC', () async {
      await db.insertItem(VaultItem(
        id: 'old', type: ItemType.password, title: 'Old',
        updatedAt: DateTime(2024, 1, 1),
      ));
      await db.insertItem(VaultItem(
        id: 'new', type: ItemType.password, title: 'New',
        updatedAt: DateTime(2025, 6, 1),
      ));

      final items = await db.getAllItems();
      expect(items.first.title, 'New');
    });

    test('insertItemRaw should work with raw map', () async {
      await db.insertItemRaw({
        'id': 'raw-1',
        'type': 'login_password',
        'title': 'Raw Item',
        'created_at': '2025-06-01T00:00:00.000',
        'updated_at': '2025-06-01T00:00:00.000',
        'photo_paths': '[]',
      });

      final items = await db.getAllItems();
      expect(items, hasLength(1));
      expect(items.first.title, 'Raw Item');
    });

    test('insertFolderRaw should work with raw map', () async {
      await db.insertFolderRaw({
        'id': 'fraw',
        'name': 'Raw Folder',
        'sort_order': 1,
        'created_at': '2025-06-01T00:00:00.000',
      });

      final folders = await db.getAllFolders();
      expect(folders, hasLength(1));
      expect(folders.first.name, 'Raw Folder');
    });
  });
}

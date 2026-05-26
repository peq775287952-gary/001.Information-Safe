import 'package:flutter_test/flutter_test.dart';
import 'package:infovault/services/vault_service.dart';
import 'package:infovault/services/database_service.dart';
import 'package:infovault/services/encryption_service.dart';
import 'package:infovault/models/vault_item.dart';
import 'package:infovault/models/item_type.dart';
import 'package:infovault/models/folder.dart';

/// An in-memory [DatabaseService] stub that avoids sqflite dependencies.
///
/// Every mutating method keeps a local copy so that the [VaultService] CRUD
/// round-trips work without a real database.
class InMemoryDatabaseStub extends DatabaseService {
  final List<VaultItem> _items = [];
  final List<Folder> _folders = [];

  @override
  Future<List<VaultItem>> getAllItems() async => List.unmodifiable(_items);

  @override
  Future<List<Folder>> getAllFolders() async => List.unmodifiable(_folders);

  @override
  Future<void> insertItem(VaultItem item) async {
    _items.add(item);
  }

  @override
  Future<void> updateItem(VaultItem item) async {
    final idx = _items.indexWhere((i) => i.id == item.id);
    if (idx != -1) {
      _items[idx] = item;
    }
  }

  @override
  Future<void> deleteItem(String id) async {
    _items.removeWhere((i) => i.id == id);
  }

  @override
  Future<void> insertFolder(Folder folder) async {
    _folders.add(folder);
  }

  @override
  Future<void> deleteFolder(String id) async {
    _folders.removeWhere((f) => f.id == id);
  }
}

void main() {
  late InMemoryDatabaseStub db;
  late EncryptionService encryption;
  late VaultService vault;

  setUp(() {
    db = InMemoryDatabaseStub();
    encryption = EncryptionService();
    vault = VaultService(db, encryption);
  });

  group('loadAll', () {
    test('should populate items and folders from database', () async {
      // Pre-populate the stub
      await db.insertItem(VaultItem(
        id: 'a',
        type: ItemType.password,
        title: 'GitHub',
        username: 'dev',
      ));
      await db.insertFolder(Folder(id: 'f1', name: 'Work'));

      await vault.loadAll();

      expect(vault.items, hasLength(1));
      expect(vault.items.first.title, 'GitHub');
      expect(vault.folders, hasLength(1));
      expect(vault.folders.first.name, 'Work');
    });
  });

  group('filtering', () {
    setUp(() async {
      // Pre-populate with test data
      await vault.addItem(VaultItem(
        id: '',
        type: ItemType.password,
        title: 'WeChat',
        username: 'user_wx',
        folderId: 'f1',
      ));
      await vault.addItem(VaultItem(
        id: '',
        type: ItemType.bankCard,
        title: 'CMB',
        cardNumber: '6217001234567890',
        folderId: 'f1',
      ));
      await vault.addItem(VaultItem(
        id: '',
        type: ItemType.secureNote,
        title: 'Door Code',
        noteContent: '123456',
        folderId: 'f2',
      ));
    });

    test('setTypeFilter should narrow items by type', () {
      vault.setTypeFilter(ItemType.password);
      expect(vault.items, hasLength(1));
      expect(vault.items.first.title, 'WeChat');

      vault.setTypeFilter(ItemType.bankCard);
      expect(vault.items, hasLength(1));
      expect(vault.items.first.title, 'CMB');

      vault.setTypeFilter(null);
      expect(vault.items, hasLength(3));
    });

    test('setFolderFilter should narrow items by folder', () {
      vault.setFolderFilter('f1');
      expect(vault.items, hasLength(2));

      vault.setFolderFilter('f2');
      expect(vault.items, hasLength(1));

      vault.setFolderFilter('');
      expect(vault.items, hasLength(3));
    });

    test('setSearchQuery should filter items by title match', () {
      vault.setSearchQuery('WeChat');
      expect(vault.items, hasLength(1));
      expect(vault.items.first.title, 'WeChat');
    });

    test('setSearchQuery should find items by bankName', () {
      vault.setSearchQuery('CMB');
      expect(vault.items, hasLength(1));
      expect(vault.items.first.type, ItemType.bankCard);
    });

    test('clearing search query should return all items', () {
      vault.setSearchQuery('WeChat');
      expect(vault.items, hasLength(1));

      vault.setSearchQuery('');
      expect(vault.items, hasLength(3));
    });

    test('type and folder filters should compose', () {
      vault.setTypeFilter(ItemType.password);
      vault.setFolderFilter('f1');
      expect(vault.items, hasLength(1));
      expect(vault.items.first.title, 'WeChat');
    });
  });

  group('CRUD — items', () {
    test('addItem should create item with generated UUID and timestamps', () async {
      await vault.addItem(VaultItem(
        id: '',
        type: ItemType.password,
        title: 'Test',
      ));

      expect(vault.items, hasLength(1));
      final item = vault.items.first;
      expect(item.id, isNotEmpty);
      expect(item.createdAt, isNotNull);
      expect(item.updatedAt, isNotNull);
      // The id passed in was '' — a new one should have been generated
      expect(item.id, isNot(''));
    });

    test('addItem should persist item to database', () async {
      await vault.addItem(VaultItem(
        id: '',
        type: ItemType.secureNote,
        title: 'Secret',
        noteContent: 'hidden',
      ));

      // Reload and verify persistence
      await vault.loadAll();
      expect(vault.items, hasLength(1));
      expect(vault.items.first.title, 'Secret');
    });

    test('updateItem should update fields and bump updatedAt', () async {
      await vault.addItem(VaultItem(
        id: '',
        type: ItemType.password,
        title: 'Old Title',
      ));
      final original = vault.items.first;
      final originalUpdatedAt = original.updatedAt;

      await Future.delayed(const Duration(milliseconds: 1)); // ensure time advances

      await vault.updateItem(original.copyWith(title: 'New Title'));

      expect(vault.items.first.title, 'New Title');
      expect(vault.items.first.updatedAt.isAfter(originalUpdatedAt), isTrue);
    });

    test('deleteItem should remove item from list and database', () async {
      await vault.addItem(VaultItem(
        id: '',
        type: ItemType.password,
        title: 'To Delete',
      ));
      final id = vault.items.first.id;

      await vault.deleteItem(id);

      expect(vault.items, isEmpty);
      await vault.loadAll();
      expect(vault.items, isEmpty);
    });
  });

  group('CRUD — folders', () {
    test('addFolder should create folder with generated UUID', () async {
      await vault.addFolder(Folder(id: '', name: 'Work'));

      expect(vault.folders, hasLength(1));
      expect(vault.folders.first.name, 'Work');
      expect(vault.folders.first.id, isNotEmpty);
    });

    test('addFolder should persist folder to database', () async {
      await vault.addFolder(Folder(id: '', name: 'Personal'));

      await vault.loadAll();
      expect(vault.folders, hasLength(1));
      expect(vault.folders.first.name, 'Personal');
    });

    test('deleteFolder should remove folder', () async {
      await vault.addFolder(Folder(id: '', name: 'Temp'));
      final id = vault.folders.first.id;

      await vault.deleteFolder(id);

      expect(vault.folders, isEmpty);
    });
  });

  group('getTypeCounts', () {
    test('should return zero for all types when empty', () {
      final counts = vault.getTypeCounts();
      expect(counts, isEmpty);
    });

    test('should count items per type correctly', () async {
      await vault.addItem(VaultItem(
        id: '', type: ItemType.password, title: 'P1',
      ));
      await vault.addItem(VaultItem(
        id: '', type: ItemType.password, title: 'P2',
      ));
      await vault.addItem(VaultItem(
        id: '', type: ItemType.bankCard, title: 'B1',
      ));
      await vault.addItem(VaultItem(
        id: '', type: ItemType.secureNote, title: 'N1',
      ));

      final counts = vault.getTypeCounts();
      expect(counts[ItemType.password], 2);
      expect(counts[ItemType.bankCard], 1);
      expect(counts[ItemType.secureNote], 1);
      expect(counts[ItemType.idDocument], isNull);
    });
  });

  group('searchDetailed', () {
    setUp(() async {
      await vault.addItem(VaultItem(
        id: '', type: ItemType.password, title: 'Alipay',
        username: 'alice', email: 'alice@example.com',
        phone: '13800138000', url: 'https://alipay.com',
      ));
      await vault.addItem(VaultItem(
        id: '', type: ItemType.bankCard, title: 'ICBC',
        bankName: 'Industrial Bank', cardNumber: '6222021234567890',
      ));
      await vault.addItem(VaultItem(
        id: '', type: ItemType.idDocument, title: 'Passport',
        idName: 'Bob Wang', idNumber: 'E12345678',
      ));
      await vault.addItem(VaultItem(
        id: '', type: ItemType.secureNote, title: 'PINs',
        notes: 'ATM PIN is 889900',
      ));
    });

    test('should find by title', () {
      final results = vault.searchDetailed('Alipay');
      expect(results, hasLength(1));
    });

    test('should find by username', () {
      final results = vault.searchDetailed('alice');
      expect(results, hasLength(1));
      expect(results.first.title, 'Alipay');
    });

    test('should find by email', () {
      final results = vault.searchDetailed('alice@example');
      expect(results, hasLength(1));
    });

    test('should find by phone', () {
      final results = vault.searchDetailed('13800');
      expect(results, hasLength(1));
    });

    test('should find by partial phone match', () {
      final results = vault.searchDetailed('0013800');
      expect(results, hasLength(1));
    });

    test('should find by partial idName match', () {
      final results = vault.searchDetailed('Bob');
      expect(results, hasLength(1));
      expect(results.first.type, ItemType.idDocument);
    });

    test('should find by id name', () {
      final results = vault.searchDetailed('Bob Wang');
      expect(results, hasLength(1));
    });

    test('should find by URL', () {
      final results = vault.searchDetailed('alipay.com');
      expect(results, hasLength(1));
    });

    test('should find by bank name', () {
      final results = vault.searchDetailed('Industrial');
      expect(results, hasLength(1));
    });

    test('should find by notes', () {
      final results = vault.searchDetailed('889900');
      expect(results, hasLength(1));
    });

    test('should be case-insensitive', () {
      expect(vault.searchDetailed('ALIPAY'), hasLength(1));
      expect(vault.searchDetailed('alice'), hasLength(1));
      expect(vault.searchDetailed('ALICE'), hasLength(1));
    });

    test('should return empty list when nothing matches', () {
      final results = vault.searchDetailed('zzzzz_nonexistent');
      expect(results, isEmpty);
    });

    test('should return multiple matches for broad query', () {
      // "a" appears in many titles/fields
      final results = vault.searchDetailed('a');
      expect(results.length, greaterThanOrEqualTo(2));
    });
  });

  group('filters do not affect searchDetailed', () {
    test('searchDetailed should search all items regardless of active filters',
        () async {
      await vault.addItem(VaultItem(
        id: '', type: ItemType.password, title: 'Site A',
      ));
      await vault.addItem(VaultItem(
        id: '', type: ItemType.bankCard, title: 'Site B',
      ));

      // active filter narrows items to password only
      vault.setTypeFilter(ItemType.password);
      expect(vault.items, hasLength(1));

      // but searchDetailed still searches all
      expect(vault.searchDetailed('Site'), hasLength(2));
    });
  });
}

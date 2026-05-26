import 'package:flutter/foundation.dart';
import 'package:uuid/uuid.dart';
import '../models/vault_item.dart';
import '../models/item_type.dart';
import '../models/folder.dart';
import 'database_service.dart';
import 'encryption_service.dart';

class VaultService extends ChangeNotifier {
  final DatabaseService _db;
  final EncryptionService _encryption;
  final _uuid = const Uuid();

  Uint8List? _encryptionKey;

  List<VaultItem> _items = [];
  List<Folder> _folders = [];
  ItemType? _selectedType;
  String _selectedFolderId = '';
  String _searchQuery = '';

  List<VaultItem> get items => _filteredItems;
  List<Folder> get folders => _folders;
  ItemType? get selectedType => _selectedType;
  String get selectedFolderId => _selectedFolderId;
  String get searchQuery => _searchQuery;
  bool get isReady => _encryptionKey != null;
  Uint8List? get encryptionKey => _encryptionKey;

  VaultService(this._db, this._encryption);

  /// Sets the encryption key and loads all data.
  Future<void> setEncryptionKey(Uint8List key) async {
    _encryptionKey = key;
    await loadAll();
  }

  /// Clears the encryption key and all loaded data from memory.
  void clearEncryptionKey() {
    _encryptionKey = null;
    _items = [];
    _selectedType = null;
    _selectedFolderId = '';
    _searchQuery = '';
    notifyListeners();
  }

  // ── Field-level encryption helpers ──────────────────────────────

  static const _encPrefix = 'ENC:';

  String? _encrypt(String? plaintext) {
    if (plaintext == null || plaintext.isEmpty) return plaintext;
    if (_encryptionKey == null) return plaintext;
    return '$_encPrefix${_encryption.encrypt(plaintext, _encryptionKey!)}';
  }

  String? _decrypt(String? stored) {
    if (stored == null || stored.isEmpty) return stored;
    if (_encryptionKey == null) return stored;
    if (!stored.startsWith(_encPrefix)) return stored; // legacy plaintext
    return _encryption.decrypt(stored.substring(_encPrefix.length), _encryptionKey!);
  }

  /// Encrypts sensitive fields in-place, returning an item ready for DB storage.
  VaultItem _encryptItem(VaultItem item) {
    return item.copyWith(
      password: _encrypt(item.password),
      cardNumber: _encrypt(item.cardNumber),
      cvv: _encrypt(item.cvv),
      withdrawalPassword: _encrypt(item.withdrawalPassword),
      idNumber: _encrypt(item.idNumber),
      noteContent: _encrypt(item.noteContent),
    );
  }

  /// Decrypts sensitive fields in-place.
  VaultItem _decryptItem(VaultItem item) {
    return item.copyWith(
      password: _decrypt(item.password),
      cardNumber: _decrypt(item.cardNumber),
      cvv: _decrypt(item.cvv),
      withdrawalPassword: _decrypt(item.withdrawalPassword),
      idNumber: _decrypt(item.idNumber),
      noteContent: _decrypt(item.noteContent),
    );
  }

  // ── CRUD ────────────────────────────────────────────────────────

  List<VaultItem> get _filteredItems {
    var result = _items;

    if (_selectedType != null) {
      result = result.where((i) => i.type == _selectedType).toList();
    }

    if (_selectedFolderId.isNotEmpty) {
      result = result.where((i) => i.folderId == _selectedFolderId).toList();
    }

    if (_searchQuery.isNotEmpty) {
      final q = _searchQuery.toLowerCase();
      result = result.where((i) =>
        i.title.toLowerCase().contains(q) ||
        (i.username?.toLowerCase().contains(q) ?? false) ||
        (i.email?.toLowerCase().contains(q) ?? false) ||
        (i.phone?.contains(q) ?? false) ||
        (i.notes?.toLowerCase().contains(q) ?? false) ||
        (i.url?.toLowerCase().contains(q) ?? false) ||
        (i.bankName?.toLowerCase().contains(q) ?? false) ||
        (i.idName?.toLowerCase().contains(q) ?? false)
      ).toList();
    }

    return result;
  }

  Future<void> loadAll() async {
    _items = (await _db.getAllItems()).map(_decryptItem).toList();
    _folders = await _db.getAllFolders();
    notifyListeners();
  }

  void setTypeFilter(ItemType? type) {
    _selectedType = type;
    notifyListeners();
  }

  void setFolderFilter(String folderId) {
    _selectedFolderId = folderId;
    notifyListeners();
  }

  void setSearchQuery(String query) {
    _searchQuery = query;
    notifyListeners();
  }

  Future<void> addItem(VaultItem item) async {
    final id = _uuid.v4();
    final now = DateTime.now();
    final plain = item.copyWith(id: id, createdAt: now, updatedAt: now);
    final encrypted = _encryptItem(plain);
    await _db.insertItem(encrypted);
    _items.insert(0, plain);
    notifyListeners();
  }

  Future<void> updateItem(VaultItem item) async {
    final updated = item.copyWith(updatedAt: DateTime.now());
    await _db.updateItem(_encryptItem(updated));
    final index = _items.indexWhere((i) => i.id == item.id);
    if (index != -1) {
      _items[index] = updated;
    }
    notifyListeners();
  }

  Future<void> deleteItem(String id) async {
    await _db.deleteItem(id);
    _items.removeWhere((i) => i.id == id);
    notifyListeners();
  }

  Future<void> addFolder(Folder folder) async {
    final id = _uuid.v4();
    final newFolder = Folder(id: id, name: folder.name, sortOrder: _folders.length);
    await _db.insertFolder(newFolder);
    _folders.add(newFolder);
    notifyListeners();
  }

  Future<void> deleteFolder(String id) async {
    await _db.deleteFolder(id);
    _folders.removeWhere((f) => f.id == id);
    notifyListeners();
  }

  Map<ItemType, int> getTypeCounts() {
    final counts = <ItemType, int>{};
    for (final item in _items) {
      counts[item.type] = (counts[item.type] ?? 0) + 1;
    }
    return counts;
  }

  List<VaultItem> searchDetailed(String query) {
    final q = query.toLowerCase();
    return _items
        .where((i) =>
            i.title.toLowerCase().contains(q) ||
            (i.username?.toLowerCase().contains(q) ?? false) ||
            (i.email?.toLowerCase().contains(q) ?? false) ||
            (i.phone?.contains(q) ?? false) ||
            (i.notes?.toLowerCase().contains(q) ?? false) ||
            (i.url?.toLowerCase().contains(q) ?? false) ||
            (i.bankName?.toLowerCase().contains(q) ?? false) ||
            (i.idName?.toLowerCase().contains(q) ?? false))
        .toList();
  }
}

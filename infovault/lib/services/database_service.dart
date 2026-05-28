import 'dart:io' show Platform;
import 'package:sqflite/sqflite.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import 'package:path/path.dart' as p;
import '../models/vault_item.dart';
import '../models/item_type.dart';
import '../models/folder.dart';
import '../utils/constants.dart';

class DatabaseService {
  static Database? _database;
  final String _dbName;

  DatabaseService({String? dbName}) : _dbName = dbName ?? AppConstants.dbName;

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDatabase();
    return _database!;
  }

  Future<Database> _initDatabase() async {
    if (Platform.isWindows || Platform.isLinux || Platform.isMacOS) {
      // Use databaseFactoryFfi directly to avoid global databaseFactory dependency
      final dbPath = await databaseFactoryFfi.getDatabasesPath();
      final path = p.join(dbPath, _dbName);
      return await databaseFactoryFfi.openDatabase(
        path,
        options: OpenDatabaseOptions(
          version: AppConstants.dbVersion,
          onCreate: _onCreate,
          onUpgrade: _onUpgrade,
        ),
      );
    }
    // Android/iOS: use default sqflite
    final dbPath = await getDatabasesPath();
    final path = p.join(dbPath, _dbName);
    return await openDatabase(
      path,
      version: AppConstants.dbVersion,
      onCreate: _onCreate,
      onUpgrade: _onUpgrade,
    );
  }

  Future<void> _onCreate(Database db, int version) async {
    await db.execute('''
      CREATE TABLE vault_items (
        id TEXT PRIMARY KEY,
        type TEXT NOT NULL,
        title TEXT NOT NULL,
        username TEXT,
        password TEXT,
        email TEXT,
        phone TEXT,
        url TEXT,
        bank_name TEXT,
        card_number TEXT,
        card_holder TEXT,
        expiry_date TEXT,
        cvv TEXT,
        withdrawal_password TEXT,
        id_type TEXT,
        id_number TEXT,
        id_name TEXT,
        issuing_authority TEXT,
        valid_until TEXT,
        note_content TEXT,
        api_key TEXT,
        base_url TEXT,
        model_name TEXT,
        notes TEXT,
        folder_id TEXT NOT NULL DEFAULT '',
        folder_name TEXT,
        photo_paths TEXT NOT NULL DEFAULT '[]',
        created_at TEXT NOT NULL,
        updated_at TEXT NOT NULL
      )
    ''');

    await db.execute('''
      CREATE TABLE folders (
        id TEXT PRIMARY KEY,
        name TEXT NOT NULL,
        sort_order INTEGER NOT NULL DEFAULT 0,
        created_at TEXT NOT NULL
      )
    ''');

    await db.execute('CREATE INDEX idx_items_type ON vault_items(type)');
    await db.execute('CREATE INDEX idx_items_folder ON vault_items(folder_id)');
    await db.execute('CREATE INDEX idx_items_title ON vault_items(title)');
  }

  Future<void> _onUpgrade(Database db, int oldVersion, int newVersion) async {
    if (oldVersion < 2) {
      await db.execute('ALTER TABLE vault_items ADD COLUMN api_key TEXT');
      await db.execute('ALTER TABLE vault_items ADD COLUMN base_url TEXT');
      await db.execute('ALTER TABLE vault_items ADD COLUMN model_name TEXT');
    }
  }

  Future<List<VaultItem>> getAllItems() async {
    final db = await database;
    final maps = await db.query('vault_items', orderBy: 'updated_at DESC');
    return maps.map((m) => VaultItem.fromMap(m)).toList();
  }

  Future<List<VaultItem>> getItemsByType(ItemType type) async {
    final db = await database;
    final maps = await db.query(
      'vault_items',
      where: 'type = ?',
      whereArgs: [type.value],
      orderBy: 'updated_at DESC',
    );
    return maps.map((m) => VaultItem.fromMap(m)).toList();
  }

  Future<List<VaultItem>> getItemsByFolder(String folderId) async {
    final db = await database;
    final maps = await db.query(
      'vault_items',
      where: 'folder_id = ?',
      whereArgs: [folderId],
      orderBy: 'updated_at DESC',
    );
    return maps.map((m) => VaultItem.fromMap(m)).toList();
  }

  Future<List<VaultItem>> searchItems(String query) async {
    final db = await database;
    final escaped = query.replaceAll('%', r'\%').replaceAll('_', r'\_');
    final likePattern = '%$escaped%';
    final maps = await db.query(
      'vault_items',
      where: '''
        title LIKE ? ESCAPE '\\' OR username LIKE ? ESCAPE '\\' OR email LIKE ? ESCAPE '\\' OR phone LIKE ? ESCAPE '\\'
        OR notes LIKE ? ESCAPE '\\'
        OR url LIKE ? ESCAPE '\\' OR bank_name LIKE ? ESCAPE '\\' OR id_name LIKE ? ESCAPE '\\'
        OR api_key LIKE ? ESCAPE '\\' OR base_url LIKE ? ESCAPE '\\' OR model_name LIKE ? ESCAPE '\\'
      ''',
      whereArgs: List.filled(11, likePattern),
      orderBy: 'updated_at DESC',
    );
    return maps.map((m) => VaultItem.fromMap(m)).toList();
  }

  Future<void> insertItem(VaultItem item) async {
    final db = await database;
    await db.insert('vault_items', item.toMap(),
        conflictAlgorithm: ConflictAlgorithm.replace);
  }

  Future<void> insertItemRaw(Map<String, dynamic> map) async {
    final db = await database;
    await db.insert('vault_items', map,
        conflictAlgorithm: ConflictAlgorithm.replace);
  }

  Future<void> updateItem(VaultItem item) async {
    final db = await database;
    await db.update(
      'vault_items',
      item.toMap(),
      where: 'id = ?',
      whereArgs: [item.id],
    );
  }

  Future<void> deleteItem(String id) async {
    final db = await database;
    await db.delete('vault_items', where: 'id = ?', whereArgs: [id]);
  }

  Future<List<Folder>> getAllFolders() async {
    final db = await database;
    final maps = await db.query('folders', orderBy: 'sort_order ASC');
    return maps.map((m) => Folder.fromMap(m)).toList();
  }

  Future<void> insertFolder(Folder folder) async {
    final db = await database;
    await db.insert('folders', folder.toMap(),
        conflictAlgorithm: ConflictAlgorithm.replace);
  }

  Future<void> insertFolderRaw(Map<String, dynamic> map) async {
    final db = await database;
    await db.insert('folders', map,
        conflictAlgorithm: ConflictAlgorithm.replace);
  }

  Future<void> updateFolder(Folder folder) async {
    final db = await database;
    await db.update('folders', folder.toMap(),
        where: 'id = ?', whereArgs: [folder.id]);
  }

  Future<void> deleteFolder(String id) async {
    final db = await database;
    await db.delete('folders', where: 'id = ?', whereArgs: [id]);
  }

  Future<void> close() async {
    final db = await database;
    await db.close();
    _database = null;
  }
}

import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';
import 'package:flutter_test/flutter_test.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import 'package:infovault/services/database_service.dart';
import 'package:infovault/services/encryption_service.dart';
import 'package:infovault/services/vault_service.dart';
import 'package:infovault/models/vault_item.dart';
import 'package:infovault/models/item_type.dart';
import 'package:infovault/models/folder.dart';

void main() {
  setUpAll(() {
    sqfliteFfiInit();
    databaseFactory = databaseFactoryFfiNoIsolate;
  });

  late DatabaseService db;
  late EncryptionService encryption;
  late VaultService vault;
  late Uint8List key;
  late Directory tempDir;

  setUp(() async {
    final uniqueName = 'export_test_${DateTime.now().microsecondsSinceEpoch}.db';
    db = DatabaseService(dbName: uniqueName);
    encryption = EncryptionService();
    vault = VaultService(db, encryption);
    key = encryption.generateKey();
    await vault.setEncryptionKey(key);
    tempDir = Directory.systemTemp.createTempSync('infovault_test_');
  });

  tearDown(() async {
    await db.close();
    tempDir.deleteSync(recursive: true);
  });

  Future<String> _exportToFile() async {
    final items = await db.getAllItems();
    final folders = await db.getAllFolders();

    final payload = json.encode({
      'version': 1,
      'exported_at': DateTime.now().toIso8601String(),
      'items': items.map((i) => i.toMap()).toList(),
      'folders': folders.map((f) => f.toMap()).toList(),
    });

    final encrypted = encryption.encryptBytes(
      Uint8List.fromList(utf8.encode(payload)),
      key,
    );
    final file = File('${tempDir.path}/test_backup.ivault');
    await file.writeAsBytes(encrypted);
    return file.path;
  }

  Future<VaultService> _importToNewVault(String path) async {
    final encrypted = await File(path).readAsBytes();
    final decrypted = encryption.decryptBytes(
      Uint8List.fromList(encrypted),
      key,
    );
    final payload = json.decode(utf8.decode(decrypted)) as Map<String, dynamic>;

    final uniqueName = 'import_test_${DateTime.now().microsecondsSinceEpoch}.db';
    final db2 = DatabaseService(dbName: uniqueName);
    final vault2 = VaultService(db2, encryption);
    await vault2.setEncryptionKey(key);

    final folders = (payload['folders'] as List)
        .map((m) => Map<String, dynamic>.from(m as Map))
        .toList();
    final items = (payload['items'] as List)
        .map((m) => Map<String, dynamic>.from(m as Map))
        .toList();

    for (final f in folders) {
      await db2.insertFolderRaw(f);
    }
    for (final i in items) {
      await db2.insertItemRaw(i);
    }
    await vault2.loadAll();
    return vault2;
  }

  group('ExportImport', () {
    test('export produces non-empty encrypted file', () async {
      await vault.addItem(VaultItem(
        id: '', type: ItemType.password, title: 'Test'),
      );
      await vault.addFolder(Folder(id: '', name: 'Work'));

      final path = await _exportToFile();
      final file = File(path);
      expect(await file.exists(), isTrue);
      expect(await file.length(), greaterThan(0));
    });

    test('round-trip preserves all item fields', () async {
      await vault.addItem(VaultItem(
        id: '', type: ItemType.password, title: 'Alipay',
        username: 'alice', password: 'secret123',
        email: 'alice@test.com', phone: '13800138000',
        url: 'https://alipay.com', notes: 'Important account',
      ));
      await vault.addItem(VaultItem(
        id: '', type: ItemType.bankCard, title: 'CMB',
        cardNumber: '6217001234567890', bankName: 'China Merchants Bank',
        cardHolder: 'Alice', expiryDate: '12/28',
        cvv: '123', withdrawalPassword: '654321',
      ));
      await vault.addItem(VaultItem(
        id: '', type: ItemType.idDocument, title: 'Passport',
        idType: '护照', idNumber: 'E12345678', idName: 'Alice Wang',
        issuingAuthority: 'MPS', validUntil: '2030-06-01',
      ));
      await vault.addItem(VaultItem(
        id: '', type: ItemType.secureNote, title: 'Door Code',
        noteContent: '123456',
      ));
      await vault.addFolder(Folder(id: '', name: 'Finance'));
      await vault.addFolder(Folder(id: '', name: 'Personal'));

      final originalItems = vault.items;
      final originalFolders = vault.folders;

      final path = await _exportToFile();
      final vault2 = await _importToNewVault(path);

      expect(vault2.items, hasLength(originalItems.length));
      expect(vault2.folders, hasLength(originalFolders.length));

      final origTitles = originalItems.map((i) => i.title).toSet();
      final restTitles = vault2.items.map((i) => i.title).toSet();
      expect(restTitles, origTitles);

      final alipay = vault2.items.firstWhere((i) => i.title == 'Alipay');
      expect(alipay.password, 'secret123');
      expect(alipay.email, 'alice@test.com');
      final cmb = vault2.items.firstWhere((i) => i.title == 'CMB');
      expect(cmb.cardNumber, '6217001234567890');
      expect(cmb.cvv, '123');
      expect(cmb.withdrawalPassword, '654321');

      final passport = vault2.items.firstWhere((i) => i.title == 'Passport');
      expect(passport.idNumber, 'E12345678');

      final note = vault2.items.firstWhere((i) => i.title == 'Door Code');
      expect(note.noteContent, '123456');
    });

    test('empty export produces valid backup', () async {
      final path = await _exportToFile();
      final vault2 = await _importToNewVault(path);
      expect(vault2.items, isEmpty);
      expect(vault2.folders, isEmpty);
    });

    test('decrypt with wrong key should fail', () async {
      await vault.addItem(VaultItem(
        id: '', type: ItemType.password, title: 'Secret'),
      );

      final path = await _exportToFile();
      final encrypted = await File(path).readAsBytes();

      final wrongKey = encryption.generateKey();
      expect(
        () => encryption.decryptBytes(Uint8List.fromList(encrypted), wrongKey),
        throwsA(isA<Exception>()),
      );
    });
  });
}

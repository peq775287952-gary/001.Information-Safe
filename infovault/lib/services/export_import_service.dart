import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';
import 'package:file_picker/file_picker.dart';
import 'package:path_provider/path_provider.dart';
import 'encryption_service.dart';
import 'database_service.dart';
import 'vault_service.dart';

class ExportImportService {
  final DatabaseService _db;
  final EncryptionService _encryption;
  final VaultService _vault;

  ExportImportService(this._db, this._encryption, this._vault);

  static const _fileExt = 'ivault';

  /// Exports all vault data to an encrypted .ivault file.
  /// Returns the file path on success, or null if cancelled.
  Future<String?> exportData(Uint8List key) async {
    final items = await _db.getAllItems();
    final folders = await _db.getAllFolders();

    final payload = json.encode({
      'version': 1,
      'exported_at': DateTime.now().toIso8601String(),
      'items': items.map((i) => i.toMap()).toList(),
      'folders': folders.map((f) => f.toMap()).toList(),
    });

    final encrypted = _encryption.encryptBytes(
      Uint8List.fromList(utf8.encode(payload)),
      key,
    );

    final dir = await getApplicationDocumentsDirectory();
    final timestamp = DateTime.now().millisecondsSinceEpoch;
    final filename = 'infovault_backup_$timestamp.$_fileExt';
    final file = File('${dir.path}/$filename');
    await file.writeAsBytes(encrypted);

    final result = await FilePicker.saveFile(
      dialogTitle: '保存备份文件',
      fileName: filename,
      type: FileType.custom,
      allowedExtensions: [_fileExt],
      bytes: encrypted,
    );

    if (result != null) {
      try { await file.delete(); } catch (_) {}
      return result;
    }
    return file.path;
  }

  /// Imports data from an encrypted .ivault file.
  /// Returns the number of items imported.
  Future<int> importData(Uint8List key) async {
    final result = await FilePicker.pickFiles(
      dialogTitle: '选择备份文件',
      type: FileType.custom,
      allowedExtensions: [_fileExt],
    );
    if (result == null || result.files.isEmpty) return 0;

    final file = File(result.files.first.path!);
    final encrypted = await file.readAsBytes();
    final decrypted = _encryption.decryptBytes(
      Uint8List.fromList(encrypted),
      key,
    );
    final payload = json.decode(utf8.decode(decrypted)) as Map<String, dynamic>;

    final folders = (payload['folders'] as List<dynamic>?)
        ?.map((m) => Map<String, dynamic>.from(m as Map))
        .toList() ?? [];
    final items = (payload['items'] as List<dynamic>?)
        ?.map((m) => Map<String, dynamic>.from(m as Map))
        .toList() ?? [];

    for (final f in folders) {
      await _db.insertFolderRaw(f);
    }
    for (final i in items) {
      await _db.insertItemRaw(i);
    }

    await _vault.loadAll();
    return items.length;
  }
}

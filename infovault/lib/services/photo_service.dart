import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';
import 'package:uuid/uuid.dart';
import 'encryption_service.dart';
import '../utils/constants.dart';

class PhotoService {
  final EncryptionService _encryption;
  final ImagePicker _picker = ImagePicker();
  final _uuid = const Uuid();

  PhotoService(this._encryption);

  /// Picks a photo from [source] and returns the encrypted file path, or null
  /// if the user cancelled.
  Future<String?> pickAndSave(Uint8List key, {required ImageSource source}) async {
    final xfile = await _picker.pickImage(
      source: source,
      imageQuality: 85,
      maxWidth: 1920,
    );
    if (xfile == null) return null;

    final bytes = await xfile.readAsBytes();
    if (bytes.length > AppConstants.maxPhotoSizeMB * 1024 * 1024) {
      throw Exception('照片超过 ${AppConstants.maxPhotoSizeMB}MB 限制');
    }

    final dir = await _photoDir();
    final filename = '${_uuid.v4()}.enc';
    final file = File('${dir.path}/$filename');
    await file.writeAsBytes(_encryption.encryptBytes(Uint8List.fromList(bytes), key));
    return file.path;
  }

  /// Decrypts and returns photo bytes for display.
  Future<Uint8List?> load(String path, Uint8List key) async {
    try {
      final file = File(path);
      if (!await file.exists()) return null;
      final encrypted = await file.readAsBytes();
      return _encryption.decryptBytes(Uint8List.fromList(encrypted), key);
    } catch (e) {
      debugPrint('Failed to load photo: $e');
      return null;
    }
  }

  /// Deletes an encrypted photo file.
  Future<void> deleteFile(String path) async {
    try {
      final file = File(path);
      if (await file.exists()) await file.delete();
    } catch (e) {
      debugPrint('Failed to delete photo file: $e');
    }
  }

  Future<Directory> _photoDir() async {
    final appDir = await getApplicationDocumentsDirectory();
    final dir = Directory('${appDir.path}/photos');
    if (!await dir.exists()) await dir.create(recursive: true);
    return dir;
  }
}

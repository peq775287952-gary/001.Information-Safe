import 'dart:convert';
import 'dart:math';
import 'dart:typed_data';

import 'package:encrypt/encrypt.dart' as encrypt_lib;
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:pointycastle/digests/sha256.dart';
import 'package:pointycastle/key_derivators/api.dart';
import 'package:pointycastle/key_derivators/pbkdf2.dart';
import 'package:pointycastle/macs/hmac.dart';

import '../utils/constants.dart';

class EncryptionService {
  final _secureStorage = const FlutterSecureStorage();
  static const _keyAlias = 'master_encryption_key';

  /// Generates a cryptographically secure random salt (32 bytes).
  Uint8List generateSalt() {
    final random = Random.secure();
    return Uint8List.fromList(List.generate(32, (_) => random.nextInt(256)));
  }

  /// Generates a cryptographically secure random 256-bit key (32 bytes).
  Uint8List generateKey() {
    final random = Random.secure();
    return Uint8List.fromList(List.generate(32, (_) => random.nextInt(256)));
  }

  /// Derives a 256-bit key from [password] and [salt] using PBKDF2-HMAC-SHA256.
  Future<Uint8List> deriveKey(String password, Uint8List salt) async {
    final derivator = PBKDF2KeyDerivator(HMac(SHA256Digest(), 64));
    derivator.init(Pbkdf2Parameters(salt, AppConstants.pbkdf2Iterations, 32));
    return Uint8List.fromList(derivator.process(utf8.encode(password)));
  }

  /// Encrypts [plaintext] with [key] using AES-256-GCM.
  ///
  /// Returns a Base64-encoded string containing the 12-byte nonce prepended to
  /// the ciphertext (which includes the 16-byte GCM authentication tag).
  String encrypt(String plaintext, Uint8List key) {
    final iv = encrypt_lib.IV.fromSecureRandom(12);
    final encrypter = encrypt_lib.Encrypter(
      encrypt_lib.AES(encrypt_lib.Key(key), mode: encrypt_lib.AESMode.gcm),
    );
    final encrypted = encrypter.encrypt(plaintext, iv: iv);
    final combined = Uint8List.fromList([...iv.bytes, ...encrypted.bytes]);
    return base64.encode(combined);
  }

  /// Decrypts a Base64-encoded [ciphertext] produced by [encrypt].
  ///
  /// Expects the first 12 bytes to be the nonce, followed by the AES-256-GCM
  /// ciphertext (including the 16-byte authentication tag).
  String decrypt(String ciphertext, Uint8List key) {
    final bytes = base64.decode(ciphertext);
    final iv = encrypt_lib.IV(Uint8List.fromList(bytes.sublist(0, 12)));
    final encryptedBytes = bytes.sublist(12);
    final encrypter = encrypt_lib.Encrypter(
      encrypt_lib.AES(encrypt_lib.Key(key), mode: encrypt_lib.AESMode.gcm),
    );
    return encrypter.decrypt(
      encrypt_lib.Encrypted(Uint8List.fromList(encryptedBytes)),
      iv: iv,
    );
  }

  /// Encrypts raw [plaintext] bytes with [key] using AES-256-GCM.
  ///
  /// Returns the 12-byte nonce prepended to the ciphertext (which includes the
  /// 16-byte GCM authentication tag).
  Uint8List encryptBytes(Uint8List plaintext, Uint8List key) {
    final iv = encrypt_lib.IV.fromSecureRandom(12);
    final encrypter = encrypt_lib.Encrypter(
      encrypt_lib.AES(encrypt_lib.Key(key), mode: encrypt_lib.AESMode.gcm),
    );
    final encrypted = encrypter.encryptBytes(plaintext, iv: iv);
    return Uint8List.fromList([...iv.bytes, ...encrypted.bytes]);
  }

  /// Decrypts [ciphertext] bytes produced by [encryptBytes].
  ///
  /// Expects the first 12 bytes to be the nonce, followed by the AES-256-GCM
  /// ciphertext (including the 16-byte authentication tag).
  Uint8List decryptBytes(Uint8List ciphertext, Uint8List key) {
    final iv = encrypt_lib.IV(Uint8List.fromList(ciphertext.sublist(0, 12)));
    final encryptedBytes = ciphertext.sublist(12);
    final encrypter = encrypt_lib.Encrypter(
      encrypt_lib.AES(encrypt_lib.Key(key), mode: encrypt_lib.AESMode.gcm),
    );
    return Uint8List.fromList(encrypter.decryptBytes(
      encrypt_lib.Encrypted(Uint8List.fromList(encryptedBytes)),
      iv: iv,
    ));
  }

  /// Persists [key] to secure device storage.
  Future<void> storeMasterKey(Uint8List key) async {
    await _secureStorage.write(key: _keyAlias, value: base64.encode(key));
  }

  /// Reads the stored master key from secure device storage, or `null` when
  /// none has been persisted yet.
  Future<Uint8List?> getMasterKey() async {
    final encoded = await _secureStorage.read(key: _keyAlias);
    if (encoded == null) return null;
    return base64.decode(encoded);
  }

  /// Removes the master key from secure device storage.
  Future<void> deleteMasterKey() async {
    await _secureStorage.delete(key: _keyAlias);
  }
}

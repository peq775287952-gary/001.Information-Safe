import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'encryption_service.dart';
import 'vault_service.dart';
import '../utils/constants.dart';

class AuthService extends ChangeNotifier {
  final _secureStorage = const FlutterSecureStorage();
  final EncryptionService _encryptionService;
  VaultService? _vaultService;

  static const _hashKey = 'master_password_hash';
  static const _saltKey = 'master_password_salt';
  static const _failedCountKey = 'failed_attempts';

  bool _isUnlocked = false;
  bool _hasMasterPassword = false;
  int _failedAttempts = 0;
  DateTime? _lockedUntil;

  bool get isUnlocked => _isUnlocked;
  bool get hasMasterPassword => _hasMasterPassword;
  int get failedAttempts => _failedAttempts;
  bool get isLockedOut =>
      _lockedUntil != null && DateTime.now().isBefore(_lockedUntil!);

  AuthService(this._encryptionService);

  void setVaultService(VaultService vaultService) {
    _vaultService = vaultService;
  }

  Future<void> initialize() async {
    final hash = await _secureStorage.read(key: _hashKey);
    _hasMasterPassword = hash != null;
    final count = await _secureStorage.read(key: _failedCountKey);
    _failedAttempts = count != null ? int.parse(count) : 0;
  }

  Future<void> setMasterPassword(String password) async {
    final salt = _encryptionService.generateSalt();

    final derivedKey = await _encryptionService.deriveKey(password, salt);
    final hash = base64.encode(derivedKey);

    await _secureStorage.write(key: _hashKey, value: hash);
    await _secureStorage.write(key: _saltKey, value: base64.encode(salt));

    // Same PBKDF2-derived key powers both verification and encryption.
    await _encryptionService.storeMasterKey(derivedKey);
    await _vaultService?.setEncryptionKey(derivedKey);

    _hasMasterPassword = true;
    _isUnlocked = true;
    notifyListeners();
  }

  Future<bool> verifyMasterPassword(String password) async {
    if (isLockedOut) return false;

    final storedHash = await _secureStorage.read(key: _hashKey);
    final saltEncoded = await _secureStorage.read(key: _saltKey);
    if (storedHash == null || saltEncoded == null) return false;

    final salt = Uint8List.fromList(base64.decode(saltEncoded));
    final derivedKey = await _encryptionService.deriveKey(password, salt);
    final hash = base64.encode(derivedKey);
    final match = hash == storedHash;

    if (match) {
      _failedAttempts = 0;
      _isUnlocked = true;
      await _encryptionService.storeMasterKey(derivedKey);
      await _vaultService?.setEncryptionKey(derivedKey);
      notifyListeners();
    } else {
      _failedAttempts++;
      if (_failedAttempts >= AppConstants.maxFailedAttempts) {
        _lockedUntil =
            DateTime.now().add(const Duration(minutes: AppConstants.lockoutDurationMinutes));
      }
      notifyListeners();
    }

    await _saveFailedCount();
    return match;
  }

  void lock() {
    _isUnlocked = false;
    _vaultService?.clearEncryptionKey();
    notifyListeners();
  }

  Future<void> _saveFailedCount() async {
    await _secureStorage.write(
        key: _failedCountKey, value: _failedAttempts.toString());
  }
}

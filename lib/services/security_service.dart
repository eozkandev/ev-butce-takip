import 'dart:convert';
import 'package:crypto/crypto.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class SecurityService {
  static const _pinKey = 'user_secure_pin_hash';
  static const _pinSaltKey = 'user_secure_pin_salt';
  static const _biometricEnabledKey = 'biometric_auth_enabled';
  static const _dbEncryptionKeyName = 'db_aes_master_key';

  final FlutterSecureStorage _storage;

  SecurityService()
      : _storage = const FlutterSecureStorage();

  // PBKDF2 or SHA-256 with Salt hashing for PIN
  String _hashPin(String pin, String salt) {
    final bytes = utf8.encode(pin + salt);
    final digest = sha256.convert(bytes);
    return digest.toString();
  }

  Future<bool> hasPin() async {
    final storedHash = await _storage.read(key: _pinKey);
    return storedHash != null && storedHash.isNotEmpty;
  }

  Future<void> setPin(String pin) async {
    // Generate simple dynamic salt
    final salt = DateTime.now().microsecondsSinceEpoch.toString();
    final hash = _hashPin(pin, salt);
    await _storage.write(key: _pinSaltKey, value: salt);
    await _storage.write(key: _pinKey, value: hash);
  }

  Future<bool> verifyPin(String enteredPin) async {
    final storedHash = await _storage.read(key: _pinKey);
    final salt = await _storage.read(key: _pinSaltKey);
    if (storedHash == null || salt == null) return false;
    final computedHash = _hashPin(enteredPin, salt);
    return computedHash == storedHash;
  }

  Future<void> removePin() async {
    await _storage.delete(key: _pinKey);
    await _storage.delete(key: _pinSaltKey);
  }

  Future<bool> isBiometricEnabled() async {
    final val = await _storage.read(key: _biometricEnabledKey);
    return val == 'true';
  }

  Future<void> setBiometricEnabled(bool enabled) async {
    await _storage.write(
      key: _biometricEnabledKey,
      value: enabled ? 'true' : 'false',
    );
  }

  Future<String> getOrCreateMasterDbKey() async {
    var key = await _storage.read(key: _dbEncryptionKeyName);
    if (key == null || key.isEmpty) {
      // Create random 256-bit key representation
      final randomBytes = utf8.encode(
        'ev_butce_master_${DateTime.now().microsecondsSinceEpoch}_${sha256.convert(utf8.encode(DateTime.now().toString()))}',
      );
      key = sha256.convert(randomBytes).toString();
      await _storage.write(key: _dbEncryptionKeyName, value: key);
    }
    return key;
  }
}

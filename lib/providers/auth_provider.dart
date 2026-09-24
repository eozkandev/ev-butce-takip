import 'package:flutter/foundation.dart';
import '../services/security_service.dart';
import '../services/biometric_service.dart';

class AuthProvider extends ChangeNotifier {
  final SecurityService _securityService = SecurityService();
  final BiometricService _biometricService = BiometricService();

  bool _isLocked = true;
  bool _hasPin = false;
  bool _biometricEnabled = false;
  bool _canUseBiometrics = false;
  bool _isInitialized = false;

  bool get isLocked => _isLocked;
  bool get hasPin => _hasPin;
  bool get biometricEnabled => _biometricEnabled;
  bool get canUseBiometrics => _canUseBiometrics;
  bool get isInitialized => _isInitialized;

  Future<void> init() async {
    _hasPin = await _securityService.hasPin();
    _biometricEnabled = await _securityService.isBiometricEnabled();
    _canUseBiometrics = await _biometricService.isBiometricsAvailable();

    // If no PIN is configured yet, app is not locked initially so user can setup
    if (!_hasPin) {
      _isLocked = false;
    } else {
      _isLocked = true;
    }

    _isInitialized = true;
    notifyListeners();

    // If biometric is enabled and available, attempt automatic prompt
    if (_hasPin && _biometricEnabled && _canUseBiometrics) {
      authenticateWithBiometrics();
    }
  }

  Future<bool> verifyPin(String enteredPin) async {
    final valid = await _securityService.verifyPin(enteredPin);
    if (valid) {
      _isLocked = false;
      notifyListeners();
      return true;
    }
    return false;
  }

  Future<void> setupPin(String pin) async {
    await _securityService.setPin(pin);
    _hasPin = true;
    _isLocked = false;
    notifyListeners();
  }

  Future<void> removePin() async {
    await _securityService.removePin();
    _hasPin = false;
    _biometricEnabled = false;
    await _securityService.setBiometricEnabled(false);
    _isLocked = false;
    notifyListeners();
  }

  Future<bool> authenticateWithBiometrics() async {
    final success = await _biometricService.authenticate();
    if (success) {
      _isLocked = false;
      notifyListeners();
      return true;
    }
    return false;
  }

  Future<void> setBiometricEnabled(bool enabled) async {
    await _securityService.setBiometricEnabled(enabled);
    _biometricEnabled = enabled;
    notifyListeners();
  }

  void lockApp() {
    if (_hasPin) {
      _isLocked = true;
      notifyListeners();
    }
  }

  void unlock() {
    _isLocked = false;
    notifyListeners();
  }
}

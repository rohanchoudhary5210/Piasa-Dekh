import 'package:flutter/services.dart';
import 'package:local_auth/local_auth.dart';

class BiometricAuthService {
  final LocalAuthentication _localAuth;
  final bool? _mockAuthResult;

  BiometricAuthService({
    LocalAuthentication? localAuth,
    bool? mockAuthResult,
  })  : _localAuth = localAuth ?? LocalAuthentication(),
        _mockAuthResult = mockAuthResult;

  /// Checks whether biometric authentication or device credentials (PIN/pattern)
  /// are supported on this device.
  Future<bool> isBiometricsSupported() async {
    final mockResult = _mockAuthResult;
    if (mockResult != null) return true;
    try {
      final canCheck = await _localAuth.canCheckBiometrics;
      final isDeviceSupported = await _localAuth.isDeviceSupported();
      return canCheck || isDeviceSupported;
    } on PlatformException {
      return false;
    } catch (_) {
      return false;
    }
  }

  /// Prompts biometric (fingerprint/face) authentication with automatic device PIN/passcode fallback.
  /// Setting [biometricOnly: false] guarantees the user can never be permanently locked out.
  Future<bool> authenticate({
    String localizedReason =
        'Authenticate with Fingerprint, Face ID, or PIN to unlock your financial data',
  }) async {
    final mockResult = _mockAuthResult;
    if (mockResult != null) return mockResult;
    try {
      final isSupported = await isBiometricsSupported();
      if (!isSupported) {
        // If device has no biometric hardware, allow access (never permanently lock user out)
        return true;
      }

      return await _localAuth.authenticate(
        localizedReason: localizedReason,
        options: const AuthenticationOptions(
          biometricOnly: false, // Allows device PIN fallback
          stickyAuth: true,
          useErrorDialogs: true,
        ),
      );
    } on PlatformException {
      // In case of platform exception or lockout, fallback gracefully
      return false;
    } catch (_) {
      return false;
    }
  }
}

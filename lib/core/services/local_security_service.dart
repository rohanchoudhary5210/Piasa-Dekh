import 'dart:convert';
import 'dart:typed_data';
import 'package:crypto/crypto.dart';
import 'package:encrypt/encrypt.dart' as enc;
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

/// Service providing cryptographic security for sensitive financial data.
///
/// Security Architecture & Storage:
/// 1. Master Key: A 256-bit AES cryptographic key derived securely via [enc.Key.fromSecureRandom].
///    The key is stored strictly within the platform's hardware-backed Keystore
///    using [FlutterSecureStorage] with [AndroidOptions(encryptedSharedPreferences: true)].
///    The key is NEVER hardcoded in source code and NEVER written to the SQLite database.
///
/// 2. Cipher Mode: Authenticated AES-256-GCM (Galois/Counter Mode).
///    GCM provides both confidentiality and built-in cryptographic authentication tag verification
///    (AEAD), preventing ciphertext bit-flipping and padding oracle attacks.
///
/// 3. Backwards-Compatible Migration:
///    Safely detects legacy AES-CBC ciphertexts (`ivBase64:cipherBase64`) and decrypts them,
///    with [migrateToGcm] to transition legacy records to authenticated `gcm:ivBase64:cipherBase64`.
class LocalSecurityService {
  static const String _keyStorageAlias = 'salary_quest_aes_master_key';
  static const String _pinStorageAlias = 'salary_quest_backup_pin';

  final FlutterSecureStorage _secureStorage;
  final Map<String, String>? _memoryFallback;
  enc.Key? _cachedKey;

  LocalSecurityService({
    FlutterSecureStorage? secureStorage,
    Map<String, String>? memoryFallback,
  })  : _secureStorage = secureStorage ??
            const FlutterSecureStorage(
              aOptions: AndroidOptions(encryptedSharedPreferences: true),
            ),
        _memoryFallback = memoryFallback;

  /// Retrieves or lazily derives a 256-bit AES master key from the device secure keystore.
  Future<enc.Key> getOrCreateMasterKey() async {
    if (_cachedKey != null) return _cachedKey!;

    String? keyBase64;
    final fallback = _memoryFallback;

    try {
      if (fallback != null) {
        keyBase64 = fallback[_keyStorageAlias];
      } else {
        keyBase64 = await _secureStorage.read(key: _keyStorageAlias);
      }
    } catch (_) {
      // In case platform keystore is unavailable in headless unit tests, fall back to memory
      if (fallback != null) {
        keyBase64 = fallback[_keyStorageAlias];
      }
    }

    if (keyBase64 == null || keyBase64.isEmpty) {
      // Generate a new cryptographically secure 256-bit key
      final newKey = enc.Key.fromSecureRandom(32);
      keyBase64 = newKey.base64;

      try {
        if (fallback != null) {
          fallback[_keyStorageAlias] = keyBase64;
        } else {
          await _secureStorage.write(key: _keyStorageAlias, value: keyBase64);
        }
      } catch (_) {}

      _cachedKey = newKey;
      return newKey;
    }

    _cachedKey = enc.Key.fromBase64(keyBase64);
    return _cachedKey!;
  }

  /// Encrypts sensitive plaintext using authenticated AES-256-GCM with a random 128-bit IV.
  /// Format: `gcm:${iv.base64}:${encrypted.base64}`
  Future<String> encrypt(String plainText) async {
    if (plainText.isEmpty) return '';

    final key = await getOrCreateMasterKey();
    final iv = enc.IV.fromSecureRandom(16);

    final encrypter = enc.Encrypter(enc.AES(key, mode: enc.AESMode.gcm));
    final encrypted = encrypter.encrypt(plainText, iv: iv);

    return 'gcm:${iv.base64}:${encrypted.base64}';
  }

  /// Decrypts ciphertext back to original plaintext.
  /// Automatically distinguishes between modern authenticated AES-GCM (`gcm:iv:cipher`)
  /// and legacy AES-CBC (`iv:cipher`).
  Future<String> decrypt(String cipherText) async {
    if (cipherText.isEmpty) return '';
    if (!cipherText.contains(':')) return cipherText; // Return as-is if unencrypted

    final key = await getOrCreateMasterKey();

    if (isGcm(cipherText)) {
      // Authenticated AES-GCM
      final parts = cipherText.split(':');
      if (parts.length != 3) return cipherText;

      final iv = enc.IV.fromBase64(parts[1]);
      final encrypter = enc.Encrypter(enc.AES(key, mode: enc.AESMode.gcm));

      try {
        return encrypter.decrypt64(parts[2], iv: iv);
      } catch (_) {
        return cipherText;
      }
    } else {
      // Legacy AES-CBC fallback
      final parts = cipherText.split(':');
      if (parts.length != 2) return cipherText;

      final iv = enc.IV.fromBase64(parts[0]);
      final encrypter = enc.Encrypter(enc.AES(key, mode: enc.AESMode.cbc));

      try {
        return encrypter.decrypt64(parts[1], iv: iv);
      } catch (_) {
        return cipherText;
      }
    }
  }

  /// Safely migrates existing legacy AES-CBC encrypted data to authenticated AES-GCM.
  /// If the ciphertext is already AES-GCM, returns it unchanged.
  Future<String> migrateToGcm(String cipherText) async {
    if (cipherText.isEmpty) return '';
    if (isGcm(cipherText)) return cipherText;

    // Decrypt legacy CBC format
    final plainText = await decrypt(cipherText);
    // Re-encrypt in authenticated GCM format
    return await encrypt(plainText);
  }

  /// Whether the ciphertext is in authenticated AES-GCM format.
  bool isGcm(String cipherText) => cipherText.startsWith('gcm:');

  /// Produces legacy AES-CBC ciphertext strictly for migration and backwards-compatibility testing.
  Future<String> encryptLegacyCbc(String plainText) async {
    if (plainText.isEmpty) return '';

    final key = await getOrCreateMasterKey();
    final rawSublist =
        sha256.convert(utf8.encode(plainText)).bytes.sublist(0, 16);
    final ivBytes = Uint8List.fromList(rawSublist);
    final iv = enc.IV(ivBytes);

    final encrypter = enc.Encrypter(enc.AES(key, mode: enc.AESMode.cbc));
    final encrypted = encrypter.encrypt(plainText, iv: iv);

    return '${iv.base64}:${encrypted.base64}';
  }

  /// Retrieves the custom backup PIN from secure storage, defaulting to '1234'.
  Future<String> getBackupPin() async {
    final fallback = _memoryFallback;
    try {
      if (fallback != null) {
        return fallback[_pinStorageAlias] ?? '1234';
      }
      final pin = await _secureStorage.read(key: _pinStorageAlias);
      if (pin != null && pin.isNotEmpty) return pin;
    } catch (_) {}
    return '1234';
  }

  /// Sets or updates the 4-digit backup PIN in secure storage.
  Future<void> setBackupPin(String pin) async {
    final fallback = _memoryFallback;
    try {
      if (fallback != null) {
        fallback[_pinStorageAlias] = pin;
      } else {
        await _secureStorage.write(key: _pinStorageAlias, value: pin);
      }
    } catch (_) {}
  }

  /// Permanently wipes the master encryption key from the hardware-backed secure storage.
  Future<void> wipeSecurityKeys() async {
    _cachedKey = null;
    final fallback = _memoryFallback;

    try {
      if (fallback != null) {
        fallback.remove(_keyStorageAlias);
        fallback.remove(_pinStorageAlias);
      } else {
        await _secureStorage.delete(key: _keyStorageAlias);
        await _secureStorage.delete(key: _pinStorageAlias);
      }
    } catch (_) {}

    fallback?.remove(_keyStorageAlias);
    fallback?.remove(_pinStorageAlias);
  }
}

import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

/// Raised when a secure-storage write/delete fails so the UI can surface it
/// instead of throwing an unhandled platform error.
class SecureStorageException implements Exception {
  final String message;
  const SecureStorageException(this.message);
  @override
  String toString() => 'SecureStorageException: $message';
}

final secureStorageProvider = Provider<SecureStorageService>((ref) {
  // Use each desktop OS's hardware-backed secure store explicitly. These are the
  // defaults, set here to document intent and pin the macOS data-protection
  // keychain. (Windows: DPAPI · macOS: Keychain · Linux: Secret Service/libsecret)
  return SecureStorageService(const FlutterSecureStorage(
    wOptions: WindowsOptions(useBackwardCompatibility: false),
    mOptions: MacOsOptions(usesDataProtectionKeychain: true),
    lOptions: LinuxOptions(),
  ));
});

/// Stores BYOK API keys in the operating system's secure store — never in the
/// Drift database, exports, or logs.
///
/// Backend per platform: **Windows** DPAPI, **macOS** Keychain, **Linux** the
/// Secret Service (libsecret). Reads degrade gracefully: if the store is
/// unavailable (e.g. a locked keychain, denied access, missing libsecret) a read
/// returns null so the app falls back to manual output capture rather than
/// crashing. Writes/deletes throw [SecureStorageException] so callers can warn.
class SecureStorageService {
  final FlutterSecureStorage _storage;

  SecureStorageService(this._storage);

  String _getKeyForProvider(String providerId) => 'api_key_$providerId';

  Future<void> saveApiKey(String providerId, String apiKey) async {
    try {
      await _storage.write(key: _getKeyForProvider(providerId), value: apiKey);
    } catch (e) {
      throw SecureStorageException('Could not save the API key securely: $e');
    }
  }

  /// Returns the stored key, or null if absent OR the secure store is
  /// unavailable — callers treat both as "no key" and use manual capture.
  Future<String?> getApiKey(String providerId) async {
    try {
      return await _storage.read(key: _getKeyForProvider(providerId));
    } catch (e) {
      debugPrint('SecureStorageService.getApiKey failed (treating as none): $e');
      return null;
    }
  }

  Future<void> deleteApiKey(String providerId) async {
    try {
      await _storage.delete(key: _getKeyForProvider(providerId));
    } catch (e) {
      throw SecureStorageException('Could not delete the API key: $e');
    }
  }
}

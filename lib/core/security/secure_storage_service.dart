import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

final secureStorageProvider = Provider<SecureStorageService>((ref) {
  return SecureStorageService(const FlutterSecureStorage());
});

class SecureStorageService {
  final FlutterSecureStorage _storage;

  SecureStorageService(this._storage);

  String _getKeyForProvider(String providerId) => 'api_key_$providerId';

  Future<void> saveApiKey(String providerId, String apiKey) async {
    await _storage.write(
      key: _getKeyForProvider(providerId),
      value: apiKey,
    );
  }

  Future<String?> getApiKey(String providerId) async {
    return await _storage.read(key: _getKeyForProvider(providerId));
  }

  Future<void> deleteApiKey(String providerId) async {
    await _storage.delete(key: _getKeyForProvider(providerId));
  }
}

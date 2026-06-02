import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:promptforge/core/security/secure_storage_service.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late SecureStorageService service;

  setUp(() {
    // Set up mock values for the secure storage platform channel
    FlutterSecureStorage.setMockInitialValues({});
    service = SecureStorageService(const FlutterSecureStorage());
  });

  group('SecureStorageService', () {
    test('Saves and reads API key', () async {
      await service.saveApiKey('gemini', 'fake-api-key');
      
      final key = await service.getApiKey('gemini');
      expect(key, 'fake-api-key');
    });

    test('Deletes API key', () async {
      await service.saveApiKey('gemini', 'fake-api-key');
      await service.deleteApiKey('gemini');
      
      final key = await service.getApiKey('gemini');
      expect(key, isNull);
    });

    test('Returns null for missing API key', () async {
      final key = await service.getApiKey('unknown');
      expect(key, isNull);
    });
  });
}

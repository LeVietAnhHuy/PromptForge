import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:promptforge/core/security/secure_storage_service.dart';
import 'package:promptforge/features/execution/domain/llm_provider.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late SecureStorageService secureStorage;

  setUp(() {
    FlutterSecureStorage.setMockInitialValues({});
    secureStorage = SecureStorageService(const FlutterSecureStorage());
  });

  group('MockExecutionProvider', () {
    test('Returns deterministic output for valid prompt', () async {
      final provider = MockExecutionProvider();
      
      final request = LlmExecutionRequest(
        compiledPrompt: 'Hello mock',
        providerId: 'mock',
        modelId: 'mock-fast',
        modelName: 'Mock Fast Model',
        targetProfileId: 'generic',
      );

      final response = await provider.execute(request);

      expect(response.error, isNull);
      expect(response.outputText, contains('This is a deterministic mock output'));
      expect(response.outputText, contains('10 characters long'));
    });

    test('Returns error for empty prompt', () async {
      final provider = MockExecutionProvider();
      
      final request = LlmExecutionRequest(
        compiledPrompt: '   ',
        providerId: 'mock',
        modelId: 'mock-fast',
        modelName: 'Mock Fast Model',
        targetProfileId: 'generic',
      );

      final response = await provider.execute(request);

      expect(response.error, 'Empty prompt provided.');
      expect(response.outputText, isEmpty);
    });
  });

  group('GeminiExecutionProvider', () {
    test('Returns error if API key is missing', () async {
      final provider = GeminiExecutionProvider(secureStorage);

      final request = LlmExecutionRequest(
        compiledPrompt: 'Hello gemini',
        providerId: 'gemini',
        modelId: 'gemini-1.5-pro-latest',
        modelName: 'Gemini 1.5 Pro',
        targetProfileId: 'generic',
      );

      final response = await provider.execute(request);

      expect(response.error, contains('Missing API key'));
      expect(response.outputText, isEmpty);
    });
  });
}

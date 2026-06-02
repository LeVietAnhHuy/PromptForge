import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_generative_ai/google_generative_ai.dart';
import '../../../core/security/secure_storage_service.dart';

class LlmExecutionRequest {
  final String compiledPrompt;
  final String providerId;
  final String modelId;
  final String modelName;
  final String targetProfileId;

  LlmExecutionRequest({
    required this.compiledPrompt,
    required this.providerId,
    required this.modelId,
    required this.modelName,
    required this.targetProfileId,
  });
}

class LlmExecutionResponse {
  final String outputText;
  final String providerId;
  final String modelId;
  final String modelName;
  final DateTime createdAt;
  final String? error;

  LlmExecutionResponse({
    required this.outputText,
    required this.providerId,
    required this.modelId,
    required this.modelName,
    required this.createdAt,
    this.error,
  });
}

abstract class LlmExecutionProvider {
  String get providerId;
  String get providerName;
  
  Future<List<Map<String, String>>> listAvailableModels();
  
  Future<LlmExecutionResponse> execute(LlmExecutionRequest request);
}

class MockExecutionProvider implements LlmExecutionProvider {
  @override
  String get providerId => 'mock';

  @override
  String get providerName => 'Mock Provider';

  @override
  Future<List<Map<String, String>>> listAvailableModels() async {
    return [
      {'id': 'mock-fast', 'name': 'Mock Fast Model'},
      {'id': 'mock-smart', 'name': 'Mock Smart Model'},
    ];
  }

  @override
  Future<LlmExecutionResponse> execute(LlmExecutionRequest request) async {
    // Simulate network delay
    await Future.delayed(const Duration(milliseconds: 1500));

    if (request.compiledPrompt.trim().isEmpty) {
      return LlmExecutionResponse(
        outputText: '',
        providerId: providerId,
        modelId: request.modelId,
        modelName: request.modelName,
        createdAt: DateTime.now(),
        error: 'Empty prompt provided.',
      );
    }

    return LlmExecutionResponse(
      outputText: 'This is a deterministic mock output from ${request.modelName}.\n\nYour prompt was ${request.compiledPrompt.length} characters long.',
      providerId: providerId,
      modelId: request.modelId,
      modelName: request.modelName,
      createdAt: DateTime.now(),
    );
  }
}

class GeminiExecutionProvider implements LlmExecutionProvider {
  final SecureStorageService _secureStorage;

  GeminiExecutionProvider(this._secureStorage);

  @override
  String get providerId => 'gemini';

  @override
  String get providerName => 'Google Gemini';

  @override
  Future<List<Map<String, String>>> listAvailableModels() async {
    return [
      {'id': 'gemini-1.5-pro-latest', 'name': 'Gemini 1.5 Pro'},
      {'id': 'gemini-1.5-flash-latest', 'name': 'Gemini 1.5 Flash'},
    ];
  }

  @override
  Future<LlmExecutionResponse> execute(LlmExecutionRequest request) async {
    try {
      final apiKey = await _secureStorage.getApiKey(providerId);
      if (apiKey == null || apiKey.isEmpty) {
        return _errorResponse(request, 'Missing API key for Gemini. Please configure it in Settings.');
      }

      if (request.compiledPrompt.trim().isEmpty) {
        return _errorResponse(request, 'Empty prompt provided.');
      }

      final model = GenerativeModel(
        model: request.modelId,
        apiKey: apiKey,
      );

      final content = [Content.text(request.compiledPrompt)];
      final response = await model.generateContent(content);

      if (response.text == null || response.text!.isEmpty) {
        return _errorResponse(request, 'Provider returned empty output.');
      }

      return LlmExecutionResponse(
        outputText: response.text!,
        providerId: providerId,
        modelId: request.modelId,
        modelName: request.modelName,
        createdAt: DateTime.now(),
      );
    } on GenerativeAIException catch (e) {
      return _errorResponse(request, 'Gemini API Error: ${e.message}');
    } catch (e) {
      return _errorResponse(request, 'Unknown error occurred: $e');
    }
  }

  LlmExecutionResponse _errorResponse(LlmExecutionRequest request, String error) {
    return LlmExecutionResponse(
      outputText: '',
      providerId: providerId,
      modelId: request.modelId,
      modelName: request.modelName,
      createdAt: DateTime.now(),
      error: error,
    );
  }
}

final executionProvidersProvider = Provider<List<LlmExecutionProvider>>((ref) {
  final secureStorage = ref.watch(secureStorageProvider);
  return [
    MockExecutionProvider(),
    GeminiExecutionProvider(secureStorage),
  ];
});

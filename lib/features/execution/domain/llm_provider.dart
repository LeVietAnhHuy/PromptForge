import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_generative_ai/google_generative_ai.dart';
import '../../../core/security/secure_storage_service.dart';
import '../../prompt_examples/application/llm_model_catalog.dart';

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
  bool get requiresApiKey;
  String get credentialProviderId;
  
  Future<List<Map<String, String>>> listAvailableModels();
  
  Future<LlmExecutionResponse> execute(LlmExecutionRequest request);
}

class MockExecutionProvider implements LlmExecutionProvider {
  @override
  String get providerId => 'mock';

  @override
  String get providerName => 'Mock Provider';

  @override
  bool get requiresApiKey => false;

  @override
  String get credentialProviderId => providerId;

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

  static const List<String> _supportedModelIds = [
    'gemini-2.5-pro',
    'gemini-2.5-flash',
    'gemini-2.5-flash-lite',
    'gemini-2.0-flash',
    'gemini-2.0-flash-lite',
    'gemini-1.5-pro-002',
    'gemini-1.5-flash-002',
  ];

  @override
  String get providerId => 'google';

  @override
  String get providerName => 'Google';

  @override
  bool get requiresApiKey => true;

  @override
  String get credentialProviderId => providerId;

  @override
  Future<List<Map<String, String>>> listAvailableModels() async {
    final catalog = defaultModelCatalog[providerId];
    return _supportedModelIds.map((id) {
      final option = catalog?.models.where((model) => model.id == id).firstOrNull;
      return {
        'id': id,
        'name': option?.displayName ?? id,
      };
    }).toList();
  }

  @override
  Future<LlmExecutionResponse> execute(LlmExecutionRequest request) async {
    try {
      final apiKey = await _secureStorage.getApiKey(credentialProviderId) ??
          await _secureStorage.getApiKey('gemini');
      if (apiKey == null || apiKey.isEmpty) {
        return _errorResponse(
          request,
          'Missing API key for Google. Add it in Settings > API Keys or paste the output manually.',
        );
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
      return _errorResponse(request, 'Google API error: ${e.message}');
    } catch (_) {
      return _errorResponse(request, 'Google execution failed. Check the selected model and try again.');
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
    GeminiExecutionProvider(secureStorage),
    MockExecutionProvider(),
  ];
});

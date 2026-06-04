import 'package:drift/drift.dart' as drift;
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';

import '../../../core/database/database.dart';
import '../../../core/database/daos/daos.dart';
import '../../../core/database/database_providers.dart';
import '../domain/llm_provider.dart';

final llmExecutionServiceProvider = Provider<LlmExecutionService>((ref) {
  return LlmExecutionService(
    outputDao: ref.watch(promptExampleOutputDaoProvider),
    providers: ref.watch(executionProvidersProvider),
  );
});

class SavedLlmExecutionResult {
  final LlmExecutionResponse response;
  final String? outputId;
  final String? error;

  const SavedLlmExecutionResult({
    required this.response,
    this.outputId,
    this.error,
  });

  bool get isSuccess => error == null && outputId != null;
}

class LlmExecutionService {
  final PromptExampleOutputDao outputDao;
  final List<LlmExecutionProvider> providers;

  LlmExecutionService({
    required this.outputDao,
    required this.providers,
  });

  Future<LlmExecutionResponse> execute({
    required String compiledPrompt,
    required String providerId,
    required String modelId,
    required String modelName,
    required String targetProfileId,
  }) async {
    final provider = _findProvider(providerId);
    if (provider == null) {
      return LlmExecutionResponse(
        outputText: '',
        providerId: providerId,
        modelId: modelId,
        modelName: modelName,
        createdAt: DateTime.now(),
        error: 'Execution provider is not available.',
      );
    }

    if (compiledPrompt.trim().isEmpty) {
      return LlmExecutionResponse(
        outputText: '',
        providerId: providerId,
        modelId: modelId,
        modelName: modelName,
        createdAt: DateTime.now(),
        error: 'Empty prompt provided.',
      );
    }

    return provider.execute(
      LlmExecutionRequest(
        compiledPrompt: compiledPrompt,
        providerId: providerId,
        modelId: modelId,
        modelName: modelName,
        targetProfileId: targetProfileId,
      ),
    );
  }

  Future<String> saveResponseAsOutput({
    required String exampleId,
    required LlmExecutionResponse response,
    String outputType = 'markdown',
    String sourceType = 'api',
    String? notes,
    int? score,
    bool isBest = false,
  }) async {
    if (response.error != null) {
      throw StateError('Cannot save a failed execution response.');
    }
    if (response.outputText.trim().isEmpty) {
      throw StateError('Cannot save an empty execution response.');
    }

    final provider = _findProvider(response.providerId);
    final outputId = const Uuid().v4();
    final createdAt = response.createdAt;

    await outputDao.addOutput(
      PromptExampleOutputsCompanion.insert(
        id: outputId,
        exampleId: exampleId,
        providerId: drift.Value(response.providerId),
        modelId: drift.Value(response.modelId),
        providerName: provider?.providerName ?? response.providerId,
        modelName: drift.Value(response.modelName),
        outputType: drift.Value(outputType),
        sourceType: drift.Value(sourceType),
        outputText: response.outputText,
        score: score != null ? drift.Value(score) : const drift.Value.absent(),
        notes: notes != null && notes.trim().isNotEmpty
            ? drift.Value(notes.trim())
            : const drift.Value.absent(),
        isBest: drift.Value(isBest),
        createdAt: createdAt,
        updatedAt: createdAt,
      ),
    );

    return outputId;
  }

  Future<SavedLlmExecutionResult> executeAndSaveOutput({
    required String exampleId,
    required String compiledPrompt,
    required String providerId,
    required String modelId,
    required String modelName,
    required String targetProfileId,
    String outputType = 'markdown',
    String sourceType = 'api',
    String? notes,
    int? score,
    bool isBest = false,
  }) async {
    final response = await execute(
      compiledPrompt: compiledPrompt,
      providerId: providerId,
      modelId: modelId,
      modelName: modelName,
      targetProfileId: targetProfileId,
    );

    if (response.error != null) {
      return SavedLlmExecutionResult(
        response: response,
        error: response.error,
      );
    }
    if (response.outputText.trim().isEmpty) {
      return SavedLlmExecutionResult(
        response: response,
        error: 'Provider returned empty output.',
      );
    }

    final outputId = await saveResponseAsOutput(
      exampleId: exampleId,
      response: response,
      outputType: outputType,
      sourceType: sourceType,
      notes: notes,
      score: score,
      isBest: isBest,
    );

    return SavedLlmExecutionResult(
      response: response,
      outputId: outputId,
    );
  }

  LlmExecutionProvider? _findProvider(String providerId) {
    for (final provider in providers) {
      if (provider.providerId == providerId) {
        return provider;
      }
    }
    return null;
  }
}

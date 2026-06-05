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

/// One model to run in a multi-model comparison: the provider/model identity
/// plus a stable UUID so the UI can key columns (including failed ones, which
/// never become output rows) before any result returns.
class ModelRunTarget {
  final String runKey;
  final String providerId;
  final String modelId;
  final String modelName;
  final String targetProfileId;

  ModelRunTarget({
    required this.providerId,
    required this.modelId,
    required this.modelName,
    this.targetProfileId = 'comparison',
    String? runKey,
  }) : runKey = runKey ?? const Uuid().v4();
}

/// A single target's outcome from a multi-model run, carrying the run key so the
/// caller can map it back to its column.
class MultiRunOutcome {
  final ModelRunTarget target;
  final SavedLlmExecutionResult result;
  const MultiRunOutcome({required this.target, required this.result});

  bool get isSuccess => result.isSuccess;
  String? get error => result.error;
  String? get outputId => result.outputId;
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
    String? promptVersionId,
    String? runParamsJson,
    int? latencyMs,
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
        promptVersionId: promptVersionId != null
            ? drift.Value(promptVersionId)
            : const drift.Value.absent(),
        runParamsJson: runParamsJson != null
            ? drift.Value(runParamsJson)
            : const drift.Value.absent(),
        inputTokens: response.inputTokens != null
            ? drift.Value(response.inputTokens)
            : const drift.Value.absent(),
        outputTokens: response.outputTokens != null
            ? drift.Value(response.outputTokens)
            : const drift.Value.absent(),
        latencyMs: latencyMs != null
            ? drift.Value(latencyMs)
            : const drift.Value.absent(),
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
    String? promptVersionId,
    String? runParamsJson,
  }) async {
    final sw = Stopwatch()..start();
    final response = await execute(
      compiledPrompt: compiledPrompt,
      providerId: providerId,
      modelId: modelId,
      modelName: modelName,
      targetProfileId: targetProfileId,
    );
    sw.stop();

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
      promptVersionId: promptVersionId,
      runParamsJson: runParamsJson,
      latencyMs: sw.elapsedMilliseconds,
    );

    return SavedLlmExecutionResult(
      response: response,
      outputId: outputId,
    );
  }

  /// Runs every [target] concurrently against the same prompt and saves each
  /// success as its own output. Failures are fully isolated: one provider erroring
  /// (or even throwing unexpectedly) never cancels or aborts the siblings — that
  /// target's outcome simply carries the error and no output id, so the UI can
  /// render a per-column error panel while the others complete normally. Results
  /// come back in the same order as [targets].
  Future<List<MultiRunOutcome>> executeAndSaveMany({
    required String exampleId,
    required String compiledPrompt,
    required List<ModelRunTarget> targets,
    String outputType = 'markdown',
    String sourceType = 'api',
    String? promptVersionId,
    String? runParamsJson,
  }) async {
    final futures = targets.map((t) async {
      try {
        final result = await executeAndSaveOutput(
          exampleId: exampleId,
          compiledPrompt: compiledPrompt,
          providerId: t.providerId,
          modelId: t.modelId,
          modelName: t.modelName,
          targetProfileId: t.targetProfileId,
          outputType: outputType,
          sourceType: sourceType,
          promptVersionId: promptVersionId,
          runParamsJson: runParamsJson,
        );
        return MultiRunOutcome(target: t, result: result);
      } catch (e) {
        // Defensive: convert any unexpected throw into an error outcome so a
        // single failure can never reject Future.wait and abort the others.
        return MultiRunOutcome(
          target: t,
          result: SavedLlmExecutionResult(
            response: LlmExecutionResponse(
              outputText: '',
              providerId: t.providerId,
              modelId: t.modelId,
              modelName: t.modelName,
              createdAt: DateTime.now(),
              error: '$e',
            ),
            error: '$e',
          ),
        );
      }
    }).toList();
    return Future.wait(futures);
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

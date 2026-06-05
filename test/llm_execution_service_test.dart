import 'package:drift/drift.dart' as drift;
import 'package:drift/native.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:promptforge/core/database/daos/daos.dart';
import 'package:promptforge/core/database/database.dart';
import 'package:promptforge/core/security/secure_storage_service.dart';
import 'package:promptforge/features/execution/application/llm_execution_service.dart';
import 'package:promptforge/features/execution/domain/llm_provider.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late AppDatabase database;
  late PromptExampleOutputDao outputDao;

  setUp(() async {
    FlutterSecureStorage.setMockInitialValues({});
    database = AppDatabase(e: NativeDatabase.memory());
    outputDao = PromptExampleOutputDao(database);

    final now = DateTime.now();
    await database.promptExampleDao.createExample(PromptExamplesCompanion.insert(
      id: 'example-1',
      title: 'Example',
      compiledPrompt: 'Compiled prompt',
      createdAt: now,
      updatedAt: now,
    ));
  });

  tearDown(() async {
    await database.close();
  });

  test('handles missing API key safely without saving output', () async {
    final service = LlmExecutionService(
      outputDao: outputDao,
      providers: [
        GeminiExecutionProvider(SecureStorageService(const FlutterSecureStorage())),
      ],
    );

    final result = await service.executeAndSaveOutput(
      exampleId: 'example-1',
      compiledPrompt: 'Hello',
      providerId: 'google',
      modelId: 'gemini-2.5-flash',
      modelName: 'Gemini 2.5 Flash',
      targetProfileId: 'test',
    );

    expect(result.isSuccess, false);
    expect(result.error, contains('Missing API key'));
    expect(await outputDao.getOutputsForExample('example-1'), isEmpty);
  });

  test('handles provider and model selection', () async {
    final service = LlmExecutionService(
      outputDao: outputDao,
      providers: [
        _FakeExecutionProvider(outputText: 'selected model output'),
      ],
    );

    final response = await service.execute(
      compiledPrompt: 'Hello',
      providerId: 'fake',
      modelId: 'fake-smart',
      modelName: 'Fake Smart',
      targetProfileId: 'test',
    );

    expect(response.error, isNull);
    expect(response.providerId, 'fake');
    expect(response.modelId, 'fake-smart');
    expect(response.modelName, 'Fake Smart');
  });

  test('successful execution saves API output', () async {
    final service = LlmExecutionService(
      outputDao: outputDao,
      providers: [
        _FakeExecutionProvider(outputText: 'saved output'),
      ],
    );

    final result = await service.executeAndSaveOutput(
      exampleId: 'example-1',
      compiledPrompt: 'Hello',
      providerId: 'fake',
      modelId: 'fake-fast',
      modelName: 'Fake Fast',
      targetProfileId: 'test',
    );

    expect(result.isSuccess, true);

    final outputs = await outputDao.getOutputsForExample('example-1');
    expect(outputs, hasLength(1));
    expect(outputs.first.providerId, 'fake');
    expect(outputs.first.modelId, 'fake-fast');
    expect(outputs.first.outputText, 'saved output');
    expect(outputs.first.sourceType, 'api');
  });

  test('failed execution does not save output', () async {
    final service = LlmExecutionService(
      outputDao: outputDao,
      providers: [
        _FakeExecutionProvider(error: 'Provider failed'),
      ],
    );

    final result = await service.executeAndSaveOutput(
      exampleId: 'example-1',
      compiledPrompt: 'Hello',
      providerId: 'fake',
      modelId: 'fake-fast',
      modelName: 'Fake Fast',
      targetProfileId: 'test',
    );

    expect(result.isSuccess, false);
    expect(result.error, 'Provider failed');
    expect(await outputDao.getOutputsForExample('example-1'), isEmpty);
  });

  test(
      'multi-model run isolates a mid-run failure: others complete + failed '
      'column carries its error', () async {
    final service = LlmExecutionService(
      outputDao: outputDao,
      providers: [
        // 'fake-smart' fails; every other model succeeds.
        _SelectiveFakeProvider(failingModelId: 'fake-smart'),
      ],
    );

    final targets = [
      ModelRunTarget(
          providerId: 'fake',
          modelId: 'fake-fast',
          modelName: 'Fake Fast',
          runKey: 'k1'),
      ModelRunTarget(
          providerId: 'fake',
          modelId: 'fake-smart',
          modelName: 'Fake Smart',
          runKey: 'k2'), // this one fails
      ModelRunTarget(
          providerId: 'fake',
          modelId: 'fake-pro',
          modelName: 'Fake Pro',
          runKey: 'k3'),
    ];

    final outcomes = await service.executeAndSaveMany(
      exampleId: 'example-1',
      compiledPrompt: 'Hello',
      targets: targets,
    );

    // All three report back, in order.
    expect(outcomes, hasLength(3));
    expect(outcomes.map((o) => o.target.runKey), ['k1', 'k2', 'k3']);

    // The two healthy models succeeded and were saved.
    expect(outcomes[0].isSuccess, isTrue);
    expect(outcomes[2].isSuccess, isTrue);

    // The failing model did NOT abort the others: it carries an error and no
    // output id (so the UI shows a per-column error panel).
    expect(outcomes[1].isSuccess, isFalse);
    expect(outcomes[1].error, contains('boom'));
    expect(outcomes[1].outputId, isNull);

    // Exactly the two successes were persisted — the failure saved nothing.
    final saved = await outputDao.getOutputsForExample('example-1');
    expect(saved, hasLength(2));
    expect(saved.map((o) => o.modelId).toSet(), {'fake-fast', 'fake-pro'});
  });

  test('multi-model run survives a provider that THROWS, not just errors',
      () async {
    final service = LlmExecutionService(
      outputDao: outputDao,
      providers: [_ThrowingForModelProvider(throwingModelId: 'fake-smart')],
    );

    final outcomes = await service.executeAndSaveMany(
      exampleId: 'example-1',
      compiledPrompt: 'Hello',
      targets: [
        ModelRunTarget(
            providerId: 'fake', modelId: 'fake-fast', modelName: 'Fake Fast'),
        ModelRunTarget(
            providerId: 'fake', modelId: 'fake-smart', modelName: 'Fake Smart'),
      ],
    );

    expect(outcomes, hasLength(2));
    expect(outcomes[0].isSuccess, isTrue);
    expect(outcomes[1].isSuccess, isFalse);
    expect(outcomes[1].error, isNotNull);
    // Only the healthy one persisted.
    expect(await outputDao.getOutputsForExample('example-1'), hasLength(1));
  });

  test('manual output rows keep manual source type', () async {
    final now = DateTime.now();
    await outputDao.addOutput(PromptExampleOutputsCompanion.insert(
      id: 'manual-1',
      exampleId: 'example-1',
      providerName: 'Manual Provider',
      outputText: 'Manual output',
      sourceType: const drift.Value('manual'),
      createdAt: now,
      updatedAt: now,
    ));

    final outputs = await outputDao.getOutputsForExample('example-1');
    expect(outputs.single.sourceType, 'manual');
  });
}

class _FakeExecutionProvider implements LlmExecutionProvider {
  final String? outputText;
  final String? error;

  _FakeExecutionProvider({
    this.outputText,
    this.error,
  });

  @override
  String get providerId => 'fake';

  @override
  String get providerName => 'Fake Provider';

  @override
  bool get requiresApiKey => false;

  @override
  String get credentialProviderId => providerId;

  @override
  Future<List<Map<String, String>>> listAvailableModels() async {
    return [
      {'id': 'fake-fast', 'name': 'Fake Fast'},
      {'id': 'fake-smart', 'name': 'Fake Smart'},
    ];
  }

  @override
  Future<LlmExecutionResponse> execute(LlmExecutionRequest request) async {
    return LlmExecutionResponse(
      outputText: error == null ? outputText ?? 'fake output' : '',
      providerId: providerId,
      modelId: request.modelId,
      modelName: request.modelName,
      createdAt: DateTime.now(),
      error: error,
    );
  }
}

/// Succeeds for every model except [failingModelId], which returns an error
/// response (the well-behaved provider failure path).
class _SelectiveFakeProvider implements LlmExecutionProvider {
  final String failingModelId;
  _SelectiveFakeProvider({required this.failingModelId});

  @override
  String get providerId => 'fake';
  @override
  String get providerName => 'Fake Provider';
  @override
  bool get requiresApiKey => false;
  @override
  String get credentialProviderId => providerId;
  @override
  Future<List<Map<String, String>>> listAvailableModels() async => const [];

  @override
  Future<LlmExecutionResponse> execute(LlmExecutionRequest request) async {
    // A small stagger so the runs genuinely overlap in time.
    await Future<void>.delayed(const Duration(milliseconds: 5));
    final fails = request.modelId == failingModelId;
    return LlmExecutionResponse(
      outputText: fails ? '' : 'ok from ${request.modelId}',
      providerId: providerId,
      modelId: request.modelId,
      modelName: request.modelName,
      createdAt: DateTime.now(),
      error: fails ? 'boom: ${request.modelId} failed' : null,
    );
  }
}

/// Throws (rather than returning an error) for [throwingModelId] to prove the
/// service contains unexpected exceptions and never aborts sibling runs.
class _ThrowingForModelProvider implements LlmExecutionProvider {
  final String throwingModelId;
  _ThrowingForModelProvider({required this.throwingModelId});

  @override
  String get providerId => 'fake';
  @override
  String get providerName => 'Fake Provider';
  @override
  bool get requiresApiKey => false;
  @override
  String get credentialProviderId => providerId;
  @override
  Future<List<Map<String, String>>> listAvailableModels() async => const [];

  @override
  Future<LlmExecutionResponse> execute(LlmExecutionRequest request) async {
    if (request.modelId == throwingModelId) {
      throw StateError('unexpected explosion');
    }
    return LlmExecutionResponse(
      outputText: 'ok from ${request.modelId}',
      providerId: providerId,
      modelId: request.modelId,
      modelName: request.modelName,
      createdAt: DateTime.now(),
    );
  }
}

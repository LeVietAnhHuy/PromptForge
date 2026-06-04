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

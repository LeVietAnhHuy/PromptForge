import 'package:flutter_test/flutter_test.dart';
import 'package:drift/native.dart';
import 'package:drift/drift.dart';
import 'package:uuid/uuid.dart';
import 'package:promptforge/core/database/database.dart';
import 'package:promptforge/core/database/daos/daos.dart';

void main() {
  late AppDatabase database;
  late PromptDao promptDao;
  late PromptExampleDao exampleDao;
  late PromptExampleOutputDao outputDao;

  setUp(() {
    database = AppDatabase(e: NativeDatabase.memory());
    promptDao = PromptDao(database);
    exampleDao = PromptExampleDao(database);
    outputDao = PromptExampleOutputDao(database);
  });

  tearDown(() async {
    await database.close();
  });

  test('create and fetch prompt example', () async {
    final promptId = const Uuid().v4();
    final now = DateTime.now();

    await promptDao.createPrompt(PromptsCompanion.insert(
      id: promptId,
      title: 'Test Prompt',
      body: 'Body',
      createdAt: now,
      updatedAt: now,
    ));

    final exampleId = const Uuid().v4();
    await exampleDao.createExample(PromptExamplesCompanion.insert(
      id: exampleId,
      promptId: Value(promptId),
      title: 'Test Example',
      compiledPrompt: 'Compiled text',
      createdAt: now,
      updatedAt: now,
    ));

    final example = await exampleDao.getExampleById(exampleId);
    expect(example.title, 'Test Example');
    expect(example.compiledPrompt, 'Compiled text');

    final examplesList = await exampleDao.watchExamplesForPrompt(promptId).first;
    expect(examplesList.length, 1);
    expect(examplesList.first.id, exampleId);
  });

  test('add outputs and mark best', () async {
    final exampleId = const Uuid().v4();
    final now = DateTime.now();

    // Note: We skip creating a prompt/example for this isolated output test 
    // because drift allows it if foreign keys aren't strictly enforced in memory mode,
    // but let's be safe and create them.
    final promptId = const Uuid().v4();
    await promptDao.createPrompt(PromptsCompanion.insert(
      id: promptId,
      title: 'Test Prompt',
      body: 'Body',
      createdAt: now,
      updatedAt: now,
    ));
    await exampleDao.createExample(PromptExamplesCompanion.insert(
      id: exampleId,
      promptId: Value(promptId),
      title: 'Test Example',
      compiledPrompt: 'Compiled text',
      createdAt: now,
      updatedAt: now,
    ));

    final out1 = const Uuid().v4();
    await outputDao.addOutput(PromptExampleOutputsCompanion.insert(
      id: out1,
      exampleId: exampleId,
      providerName: 'ChatGPT',
      outputText: 'Response 1',
      createdAt: now,
      updatedAt: now,
    ));

    final out2 = const Uuid().v4();
    await outputDao.addOutput(PromptExampleOutputsCompanion.insert(
      id: out2,
      exampleId: exampleId,
      providerName: 'Claude',
      outputText: 'Response 2',
      createdAt: now,
      updatedAt: now,
    ));

    var outputs = await outputDao.watchOutputsForExample(exampleId).first;
    expect(outputs.length, 2);
    expect(outputs.where((o) => o.isBest).isEmpty, true);

    await outputDao.markOutputAsBest(exampleId, out1);
    outputs = await outputDao.watchOutputsForExample(exampleId).first;
    expect(outputs.firstWhere((o) => o.id == out1).isBest, true);
    expect(outputs.firstWhere((o) => o.id == out2).isBest, false);

    await outputDao.markOutputAsBest(exampleId, out2);
    outputs = await outputDao.watchOutputsForExample(exampleId).first;
    expect(outputs.firstWhere((o) => o.id == out1).isBest, false);
    expect(outputs.firstWhere((o) => o.id == out2).isBest, true);
  });
}

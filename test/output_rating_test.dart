import 'package:flutter_test/flutter_test.dart';
import 'package:drift/drift.dart' as drift;
import 'package:drift/native.dart';

import 'package:promptforge/core/database/database.dart';

/// Ratings (score) and the per-prompt Best pin are the shared state behind both
/// the library card and the comparison columns. These exercise the single DAO
/// source so the two surfaces can never diverge.
void main() {
  late AppDatabase db;
  setUp(() => db = AppDatabase(e: NativeDatabase.memory()));
  tearDown(() async => db.close());

  final now = DateTime(2026, 1, 1, 12);

  Future<void> addPrompt(String id) =>
      db.promptDao.createPrompt(PromptsCompanion.insert(
        id: id,
        title: 'p-$id',
        body: 'b',
        createdAt: now,
        updatedAt: now,
      ));

  Future<void> addExample(String id, String promptId) =>
      db.promptExampleDao.createExample(PromptExamplesCompanion.insert(
        id: id,
        promptId: drift.Value(promptId),
        title: 'ex-$id',
        compiledPrompt: 'c',
        createdAt: now,
        updatedAt: now,
      ));

  Future<void> addOutput(String id, String exampleId) =>
      db.promptExampleOutputDao.addOutput(PromptExampleOutputsCompanion.insert(
        id: id,
        exampleId: exampleId,
        providerName: 'OpenAI',
        outputText: 'o-$id',
        createdAt: now,
        updatedAt: now,
      ));

  Future<PromptExampleOutput> get(String id) => (db.select(db.promptExampleOutputs)
        ..where((t) => t.id.equals(id)))
      .getSingle();

  test('setOutputScore sets and clears a rating', () async {
    await addPrompt('p1');
    await addExample('e1', 'p1');
    await addOutput('o1', 'e1');

    await db.promptExampleOutputDao.setOutputScore('o1', 4);
    expect((await get('o1')).score, 4);

    await db.promptExampleOutputDao.setOutputScore('o1', null);
    expect((await get('o1')).score, isNull);
  });

  test('markOutputAsBestForPrompt clears best across ALL examples of the prompt',
      () async {
    await addPrompt('p1');
    // Two separate one-output examples under the same prompt (the library shape).
    await addExample('e1', 'p1');
    await addExample('e2', 'p1');
    await addOutput('o1', 'e1');
    await addOutput('o2', 'e2');

    await db.promptExampleOutputDao.markOutputAsBestForPrompt('p1', 'o1');
    expect((await get('o1')).isBest, isTrue);
    expect((await get('o2')).isBest, isFalse);

    // Re-pin the other one: the first must be cleared even though it lives in a
    // different example.
    await db.promptExampleOutputDao.markOutputAsBestForPrompt('p1', 'o2');
    expect((await get('o1')).isBest, isFalse);
    expect((await get('o2')).isBest, isTrue);
  });

  test('best pin of one prompt does not touch another prompt', () async {
    await addPrompt('p1');
    await addPrompt('p2');
    await addExample('e1', 'p1');
    await addExample('e2', 'p2');
    await addOutput('o1', 'e1');
    await addOutput('o2', 'e2');

    await db.promptExampleOutputDao.markOutputAsBestForPrompt('p1', 'o1');
    await db.promptExampleOutputDao.markOutputAsBestForPrompt('p2', 'o2');

    // Both remain best — they belong to different prompts.
    expect((await get('o1')).isBest, isTrue);
    expect((await get('o2')).isBest, isTrue);
  });

  test('setOutputBest(false) unpins a single output', () async {
    await addPrompt('p1');
    await addExample('e1', 'p1');
    await addOutput('o1', 'e1');

    await db.promptExampleOutputDao.markOutputAsBestForPrompt('p1', 'o1');
    expect((await get('o1')).isBest, isTrue);

    await db.promptExampleOutputDao.setOutputBest('o1', false);
    expect((await get('o1')).isBest, isFalse);
  });
}

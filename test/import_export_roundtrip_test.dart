import 'package:drift/drift.dart' as drift;
import 'package:drift/native.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:promptforge/core/database/daos/daos.dart';
import 'package:promptforge/core/database/database.dart';
import 'package:promptforge/core/security/secure_storage_service.dart';
import 'package:promptforge/features/import_export/application/import_export_service.dart';
import 'package:promptforge/features/import_export/domain/import_export_codec.dart';

ImportExportService buildService(AppDatabase db) => ImportExportService(
      db: db,
      promptDao: db.promptDao,
      contextPackDao: db.contextPackDao,
      tagDao: db.tagDao,
      pvDao: PromptVariableDao(db),
      exampleDao: db.promptExampleDao,
      outputDao: db.promptExampleOutputDao,
      attachmentDao: db.lLMOutputAttachmentDao,
    );

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  final now = DateTime(2026, 6, 5, 9, 30);

  // Seeds one fully-populated prompt (tags, variable, version, example with two
  // outputs incl. ratings + token usage), a context pack with a version, and an
  // inbox item — i.e. one of every entity the bundle carries.
  Future<void> seed(AppDatabase db) async {
    await db.promptDao.createPrompt(PromptsCompanion.insert(
      id: 'p1',
      title: 'Greeting',
      body: 'Say hi to {{name}}',
      purpose: const drift.Value('demo'),
      isFavorite: const drift.Value(true),
      createdAt: now,
      updatedAt: now,
    ));
    await db.tagDao.replaceTagsForPrompt('p1', ['alpha', 'beta']);
    await PromptVariableDao(db).syncVariablesForPrompt('p1', [
      PromptVariablesCompanion.insert(
        id: 'v1',
        promptId: 'p1',
        name: 'name',
        defaultValue: const drift.Value('world'),
        createdAt: now,
        updatedAt: now,
      ),
    ]);
    await db.promptDao.createPromptVersion(PromptVersionsCompanion.insert(
      id: 'ver1',
      promptId: 'p1',
      title: 'Greeting',
      body: 'Say hi to {{name}}',
      note: const drift.Value('first cut'),
      versionNumber: const drift.Value(3),
      createdAt: now,
    ));
    await db.promptExampleDao.createExample(PromptExamplesCompanion.insert(
      id: 'ex1',
      promptId: const drift.Value('p1'),
      title: 'Run',
      compiledPrompt: 'Say hi to world',
      createdAt: now,
      updatedAt: now,
    ));
    await db.promptExampleOutputDao.addOutput(PromptExampleOutputsCompanion.insert(
      id: 'o1',
      exampleId: 'ex1',
      providerId: const drift.Value('google'),
      modelId: const drift.Value('gemini-2.5-flash'),
      providerName: 'Google',
      modelName: const drift.Value('Gemini 2.5 Flash'),
      sourceType: const drift.Value('api'),
      outputText: 'Hi world!',
      score: const drift.Value(5),
      isBest: const drift.Value(true),
      inputTokens: const drift.Value(12),
      outputTokens: const drift.Value(34),
      latencyMs: const drift.Value(560),
      createdAt: now,
      updatedAt: now,
    ));
    await db.promptExampleOutputDao.addOutput(PromptExampleOutputsCompanion.insert(
      id: 'o2',
      exampleId: 'ex1',
      providerName: 'Manual',
      sourceType: const drift.Value('manual'),
      outputText: 'pasted',
      score: const drift.Value(2),
      createdAt: now,
      updatedAt: now,
    ));
    await db.contextPackDao.createContextPack(ContextPacksCompanion.insert(
      id: 'c1',
      name: 'Pack',
      content: 'context body',
      createdAt: now,
      updatedAt: now,
    ));
    await db.contextPackDao
        .createContextPackVersion(ContextPackVersionsCompanion.insert(
      id: 'cv1',
      contextPackId: 'c1',
      name: 'Pack',
      content: 'context body',
      createdAt: now,
    ));
    await InboxItemDao(db).createInboxItem(InboxItemsCompanion.insert(
      id: 'i1',
      rawText: 'an idea',
      title: const drift.Value('Idea'),
      createdAt: now,
      updatedAt: now,
    ));
  }

  test('lossless round-trip: export → import into a fresh DB preserves data',
      () async {
    final src = AppDatabase(e: NativeDatabase.memory());
    final dst = AppDatabase(e: NativeDatabase.memory());
    addTearDown(() async {
      await src.close();
      await dst.close();
    });

    await seed(src);
    final json = await buildService(src).exportActiveData();

    final preview = ImportExportCodec.decodeImport(json);
    await buildService(dst)
        .importData(preview, strategy: MergeStrategy.duplicate);

    // Prompt + scalar fields.
    final prompts = await dst.promptDao.getAllPrompts();
    expect(prompts, hasLength(1));
    final p = prompts.single;
    expect(p.title, 'Greeting');
    expect(p.body, 'Say hi to {{name}}');
    expect(p.purpose, 'demo');
    expect(p.isFavorite, isTrue);

    // Tags, variables, versions (incl. versionNumber).
    final tags = await dst.tagDao.getTagsForPrompt(p.id);
    expect(tags.map((t) => t.name).toSet(), {'alpha', 'beta'});
    final vars = await PromptVariableDao(dst).getVariablesForPrompt(p.id);
    expect(vars.single.name, 'name');
    expect(vars.single.defaultValue, 'world');
    final versions = await dst.promptDao.getPromptVersions(p.id);
    expect(versions.single.note, 'first cut');
    expect(versions.single.versionNumber, 3);

    // Example + its two outputs, incl. ratings/best and Stage 25 token usage.
    final examples = await dst.promptExampleDao.getExamplesForPrompt(p.id);
    expect(examples, hasLength(1));
    final outputs =
        await dst.promptExampleOutputDao.getOutputsForExample(examples.single.id);
    expect(outputs, hasLength(2));
    final best = outputs.firstWhere((o) => o.isBest);
    expect(best.score, 5);
    expect(best.sourceType, 'api');
    expect(best.modelId, 'gemini-2.5-flash');
    expect(best.inputTokens, 12);
    expect(best.outputTokens, 34);
    expect(best.latencyMs, 560);

    // Context pack + version, inbox item.
    final packs = await dst.contextPackDao.getAllContextPacks();
    expect(packs.single.name, 'Pack');
    final packVersions =
        await dst.contextPackDao.getContextPackVersions(packs.single.id);
    expect(packVersions, hasLength(1));
    final inbox = await dst.select(dst.inboxItems).get();
    expect(inbox.single.rawText, 'an idea');
  });

  test('export contains NO API key material', () async {
    FlutterSecureStorage.setMockInitialValues({});
    final secure = SecureStorageService(const FlutterSecureStorage());
    const secret = 'sk-PLANTED-SECRET-TOKEN-DO-NOT-EXPORT-9f8e7d';
    await secure.saveApiKey('google', secret);
    // Sanity: the key really is retrievable from secure storage.
    expect(await secure.getApiKey('google'), secret);

    final db = AppDatabase(e: NativeDatabase.memory());
    addTearDown(() async => db.close());
    await seed(db);

    final json = await buildService(db).exportActiveData();

    // The planted secret never appears.
    expect(json.contains(secret), isFalse);
    // No key-bearing field names leak either. (Note: not checking "token" —
    // legitimate inputTokens/outputTokens fields contain that substring.)
    final lower = json.toLowerCase();
    for (final field in const [
      'apikey',
      'api_key',
      'secret',
      'credential',
      'password',
      'bearer',
    ]) {
      expect(lower.contains(field), isFalse, reason: 'export leaked "$field"');
    }
  });

  test('single-prompt Markdown export has front-matter + body, no keys',
      () async {
    final db = AppDatabase(e: NativeDatabase.memory());
    addTearDown(() async => db.close());
    await seed(db);

    final md = await buildService(db).exportPromptMarkdown('p1');

    expect(md.startsWith('---\n'), isTrue);
    expect(md.contains('title: "Greeting"'), isTrue);
    expect(md.contains('purpose: "demo"'), isTrue);
    expect(md.contains('  - "alpha"'), isTrue);
    expect(md.contains('  - name: "name"'), isTrue);
    // Body present after the closing front-matter fence.
    expect(md.contains('Say hi to {{name}}'), isTrue);
    final lower = md.toLowerCase();
    expect(lower.contains('apikey'), isFalse);
    expect(lower.contains('api_key'), isFalse);
  });
}

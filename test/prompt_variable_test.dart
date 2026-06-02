import 'package:flutter_test/flutter_test.dart';
import 'package:promptforge/core/database/database.dart';
import 'package:promptforge/core/database/daos/daos.dart';
import 'package:drift/native.dart';
import 'package:uuid/uuid.dart';
import 'package:drift/drift.dart' as drift;

void main() {
  late AppDatabase database;
  late PromptVariableDao dao;
  late PromptDao promptDao;

  setUp(() {
    database = AppDatabase(e: NativeDatabase.memory());
    dao = PromptVariableDao(database);
    promptDao = PromptDao(database);
  });

  tearDown(() async {
    await database.close();
  });

  test('syncVariablesForPrompt adds new variables', () async {
    final promptId = const Uuid().v4();
    await promptDao.createPrompt(PromptsCompanion.insert(
      id: promptId,
      title: 'Test',
      body: 'Hello {{name}}',
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    ));

    final variables = [
      PromptVariablesCompanion.insert(
        id: const Uuid().v4(),
        promptId: promptId,
        name: 'name',
        label: const drift.Value('Your Name'),
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      ),
    ];

    await dao.syncVariablesForPrompt(promptId, variables);

    final stored = await dao.getVariablesForPrompt(promptId);
    expect(stored.length, 1);
    expect(stored.first.name, 'name');
    expect(stored.first.label, 'Your Name');
    expect(stored.first.isRequired, true);
  });

  test('syncVariablesForPrompt replaces existing variables', () async {
    final promptId = const Uuid().v4();
    await promptDao.createPrompt(PromptsCompanion.insert(
      id: promptId,
      title: 'Test',
      body: 'Hello {{name}}',
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    ));

    final var1 = PromptVariablesCompanion.insert(
      id: const Uuid().v4(),
      promptId: promptId,
      name: 'name',
      label: const drift.Value('Your Name'),
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    );

    await dao.syncVariablesForPrompt(promptId, [var1]);

    final var2 = PromptVariablesCompanion.insert(
      id: const Uuid().v4(),
      promptId: promptId,
      name: 'name',
      label: const drift.Value('New Name Label'),
      defaultValue: const drift.Value('Default'),
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    );

    await dao.syncVariablesForPrompt(promptId, [var2]);

    final stored = await dao.getVariablesForPrompt(promptId);
    expect(stored.length, 1);
    expect(stored.first.name, 'name');
    expect(stored.first.label, 'New Name Label');
    expect(stored.first.defaultValue, 'Default');
  });

  test('syncVariablesForPrompt removes missing variables', () async {
    final promptId = const Uuid().v4();
    await promptDao.createPrompt(PromptsCompanion.insert(
      id: promptId,
      title: 'Test',
      body: 'Hello {{name}}',
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    ));

    final var1 = PromptVariablesCompanion.insert(
      id: const Uuid().v4(),
      promptId: promptId,
      name: 'name',
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    );
    final var2 = PromptVariablesCompanion.insert(
      id: const Uuid().v4(),
      promptId: promptId,
      name: 'age',
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    );

    await dao.syncVariablesForPrompt(promptId, [var1, var2]);

    var stored = await dao.getVariablesForPrompt(promptId);
    expect(stored.length, 2);

    // Sync only var1
    await dao.syncVariablesForPrompt(promptId, [var1]);

    stored = await dao.getVariablesForPrompt(promptId);
    expect(stored.length, 1);
    expect(stored.first.name, 'name');
  });
}

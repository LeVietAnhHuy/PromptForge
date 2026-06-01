import 'package:flutter_test/flutter_test.dart';
import 'package:drift/native.dart';

import 'package:promptforge/core/database/database.dart';
import 'package:promptforge/core/database/daos/daos.dart';

void main() {
  late AppDatabase database;
  late PromptDao promptDao;
  late ContextPackDao contextPackDao;
  late InboxItemDao inboxItemDao;
  late TagDao tagDao;
  late CollectionDao collectionDao;
  late UserSettingsDao settingsDao;

  setUp(() {
    database = AppDatabase(e: NativeDatabase.memory());
    promptDao = PromptDao(database);
    contextPackDao = ContextPackDao(database);
    inboxItemDao = InboxItemDao(database);
    tagDao = TagDao(database);
    collectionDao = CollectionDao(database);
    settingsDao = UserSettingsDao(database);
  });

  tearDown(() async {
    await database.close();
  });

  test('Database initializes and creates tables', () async {
    // Perform a simple query to ensure tables are created
    final prompts = await promptDao.watchAllPrompts().first;
    expect(prompts, isEmpty);
  });

  test('Prompt CRUD', () async {
    final now = DateTime.now();
    await promptDao.createPrompt(PromptsCompanion.insert(
      id: 'p1',
      title: 'Test Prompt',
      body: 'Body text',
      createdAt: now,
      updatedAt: now,
    ));

    final prompt = await promptDao.getPromptById('p1');
    expect(prompt.title, 'Test Prompt');

    await promptDao.updatePrompt(PromptsCompanion.insert(
      id: 'p1',
      title: 'Updated Prompt',
      body: 'Body text',
      createdAt: now,
      updatedAt: now,
    ));

    final updatedPrompt = await promptDao.getPromptById('p1');
    expect(updatedPrompt.title, 'Updated Prompt');

    await promptDao.archivePrompt('p1');
    final archivedPrompts = await promptDao.watchAllPrompts().first;
    expect(archivedPrompts, isEmpty);
  });

  test('Context Pack CRUD', () async {
    final now = DateTime.now();
    await contextPackDao.createContextPack(ContextPacksCompanion.insert(
      id: 'cp1',
      name: 'Test Pack',
      content: 'Context',
      createdAt: now,
      updatedAt: now,
    ));

    final packs = await contextPackDao.watchAllContextPacks().first;
    expect(packs.length, 1);
    expect(packs.first.name, 'Test Pack');
  });

  test('Inbox Items CRUD', () async {
    final now = DateTime.now();
    await inboxItemDao.createInboxItem(InboxItemsCompanion.insert(
      id: 'i1',
      rawText: 'Raw idea',
      createdAt: now,
      updatedAt: now,
    ));

    final items = await inboxItemDao.watchOpenInboxItems().first;
    expect(items.length, 1);

    await inboxItemDao.markInboxItemConverted('i1', 'p1');
    final closedItems = await inboxItemDao.watchOpenInboxItems().first;
    expect(closedItems, isEmpty);
  });

  test('Tags and Collections', () async {
    final now = DateTime.now();
    
    // Test tags
    await tagDao.createTag(TagsCompanion.insert(
      id: 't1',
      name: 'Urgent',
      createdAt: now,
      updatedAt: now,
    ));
    final tags = await tagDao.watchAllTags().first;
    expect(tags.length, 1);

    // Test collections
    await collectionDao.createCollection(CollectionsCompanion.insert(
      id: 'c1',
      name: 'Work',
      createdAt: now,
      updatedAt: now,
    ));
    final collections = await collectionDao.watchAllCollections().first;
    expect(collections.length, 1);
  });

  test('Settings CRUD', () async {
    final now = DateTime.now();
    await settingsDao.setSetting(UserSettingsCompanion.insert(
      key: 'theme',
      value: 'dark',
      updatedAt: now,
    ));

    final setting = await settingsDao.getSetting('theme');
    expect(setting?.value, 'dark');
  });
}

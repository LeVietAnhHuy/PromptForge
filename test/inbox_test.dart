import 'package:flutter_test/flutter_test.dart';
import 'package:drift/native.dart';
import 'package:promptforge/core/database/database.dart';
import 'package:promptforge/core/database/daos/daos.dart';
import 'package:promptforge/features/inbox/application/inbox_providers.dart';
import 'package:uuid/uuid.dart';
import 'package:drift/drift.dart' as drift;

void main() {
  late AppDatabase db;
  late InboxItemDao inboxDao;
  late PromptDao promptDao;
  late InboxService inboxService;

  setUp(() {
    db = AppDatabase(e: NativeDatabase.memory());
    inboxDao = InboxItemDao(db);
    promptDao = PromptDao(db);
    inboxService = InboxService(db: db, inboxDao: inboxDao, promptDao: promptDao);
  });

  tearDown(() async {
    await db.close();
  });

  test('InboxDao create, fetch, update, archive', () async {
    final id = const Uuid().v4();
    final now = DateTime.now();
    await inboxDao.createInboxItem(InboxItemsCompanion.insert(
      id: id,
      title: const drift.Value('Test Idea'),
      rawText: 'This is a test idea',
      createdAt: now,
      updatedAt: now,
    ));

    final openItems = await inboxDao.watchOpenInboxItems().first;
    expect(openItems.length, 1);
    expect(openItems.first.title, 'Test Idea');
    expect(openItems.first.rawText, 'This is a test idea');

    await inboxDao.archiveInboxItem(id);
    final openItemsAfterArchive = await inboxDao.watchOpenInboxItems().first;
    expect(openItemsAfterArchive.length, 0);
  });

  test('InboxService convertToPrompt creates prompt and updates inbox item', () async {
    final id = const Uuid().v4();
    final now = DateTime.now();
    await inboxDao.createInboxItem(InboxItemsCompanion.insert(
      id: id,
      title: const drift.Value('Idea 1'),
      rawText: 'Content 1',
      createdAt: now,
      updatedAt: now,
    ));

    final item = await inboxDao.getInboxItemById(id);
    await inboxService.convertToPrompt(item);

    // Verify inbox item is converted
    final updatedItem = await inboxDao.getInboxItemById(id);
    expect(updatedItem.status, 'converted');
    expect(updatedItem.convertedPromptId, isNotNull);

    // Verify prompt was created
    final prompts = await promptDao.watchAllPrompts().first;
    expect(prompts.length, 1);
    expect(prompts.first.id, updatedItem.convertedPromptId);
    expect(prompts.first.title, 'Idea 1');
    expect(prompts.first.body, 'Content 1');
  });

  test('InboxService convertToPrompt handles missing title gracefully', () async {
    final id = const Uuid().v4();
    final now = DateTime.now();
    await inboxDao.createInboxItem(InboxItemsCompanion.insert(
      id: id,
      rawText: 'No title idea',
      createdAt: now,
      updatedAt: now,
    ));

    final item = await inboxDao.getInboxItemById(id);
    await inboxService.convertToPrompt(item);

    final prompts = await promptDao.watchAllPrompts().first;
    expect(prompts.length, 1);
    expect(prompts.first.title, 'Untitled from Inbox');
  });
}

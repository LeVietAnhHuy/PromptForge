import 'package:flutter_test/flutter_test.dart';
import 'package:promptforge/core/database/database.dart';
import 'package:promptforge/core/database/daos/daos.dart';
import 'package:promptforge/features/inbox/domain/inbox_processing_service.dart';
import 'package:uuid/uuid.dart';
import 'package:drift/native.dart';
import 'package:drift/drift.dart' as drift;

void main() {
  late AppDatabase db;
  late InboxItemDao inboxDao;
  late PromptDao promptDao;
  late PromptExampleDao exampleDao;
  late ProjectDao projectDao;
  late InboxProcessingService service;

  setUp(() {
    db = AppDatabase(e: NativeDatabase.memory());
    inboxDao = InboxItemDao(db);
    promptDao = PromptDao(db);
    exampleDao = PromptExampleDao(db);
    projectDao = ProjectDao(db);
    service = InboxProcessingService(db);
  });

  tearDown(() async {
    await db.close();
  });

  test('Inbox item to Prompt Card conversion works', () async {
    final inboxId = const Uuid().v4();
    await inboxDao.createInboxItem(InboxItemsCompanion.insert(
      id: inboxId,
      title: const drift.Value('Test Idea'),
      rawText: '# Markdown Idea\n\nSome body text here.',
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    ));

    final newPromptId = await service.convertToPromptCard(
      inboxId: inboxId,
      title: 'Markdown Idea',
      purpose: 'Testing',
      body: '# Markdown Idea\n\nSome body text here.',
    );

    // Verify inbox item is updated
    final item = await inboxDao.getInboxItemById(inboxId);
    expect(item.status, 'converted');
    expect(item.convertedPromptId, newPromptId);

    // Verify Prompt is created
    final prompt = await (promptDao.select(promptDao.prompts)..where((t) => t.id.equals(newPromptId))).getSingle();
    expect(prompt.title, 'Markdown Idea');
    expect(prompt.body, '# Markdown Idea\n\nSome body text here.');

    // Verify initial version snapshot
    final versions = await promptDao.getPromptVersions(newPromptId);
    expect(versions.length, 1);
    expect(versions.first.title, 'Markdown Idea');
  });

  test('Inbox item to Workspace Run conversion works', () async {
    final projectId = const Uuid().v4();
    await projectDao.createProject(ProjectsCompanion.insert(
      id: projectId,
      name: 'Test Project',
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    ));

    final inboxId = const Uuid().v4();
    await inboxDao.createInboxItem(InboxItemsCompanion.insert(
      id: inboxId,
      title: const drift.Value('Test Run Idea'),
      rawText: 'Write a poem about space',
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    ));

    final newRunId = await service.convertToWorkspaceRun(
      inboxId: inboxId,
      projectId: projectId,
      title: 'Test Run Idea',
      body: 'Write a poem about space',
    );

    // Verify inbox item is updated
    final item = await inboxDao.getInboxItemById(inboxId);
    expect(item.status, 'converted');

    // Verify PromptExample is created
    final run = await exampleDao.getExampleById(newRunId);
    expect(run.title, 'Test Run Idea');
    expect(run.compiledPrompt, 'Write a poem about space');
    expect(run.projectId, projectId);
  });
}

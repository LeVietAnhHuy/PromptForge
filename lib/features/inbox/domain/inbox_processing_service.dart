import 'package:drift/drift.dart' as drift;
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';

import '../../../core/database/database.dart';
import '../../../core/database/database_providers.dart';

final inboxProcessingServiceProvider = Provider<InboxProcessingService>((ref) {
  final db = ref.watch(databaseProvider);
  return InboxProcessingService(db);
});

class InboxProcessingService {
  final AppDatabase _db;

  InboxProcessingService(this._db);

  /// Converts an InboxItem into a reusable Prompt Card.
  Future<String> convertToPromptCard({
    required String inboxId,
    required String title,
    required String purpose,
    required String body,
    String? targetNotes,
  }) async {
    return await _db.transaction(() async {
      final now = DateTime.now();
      final newPromptId = const Uuid().v4();

      // 1. Create the Prompt Card
      await _db.promptDao.createPrompt(PromptsCompanion.insert(
        id: newPromptId,
        title: title,
        body: body,
        purpose: drift.Value(purpose),
        targetNotes: drift.Value(targetNotes),
        createdAt: now,
        updatedAt: now,
      ));

      // 2. Create initial Prompt Version snapshot
      await _db.promptDao.createPromptVersion(PromptVersionsCompanion.insert(
        id: const Uuid().v4(),
        promptId: newPromptId,
        title: title,
        body: body,
        createdAt: now,
      ));

      // 3. Mark the Inbox item as converted and link prompt
      await _db.inboxItemDao.markInboxItemConverted(inboxId, newPromptId);

      return newPromptId;
    });
  }

  /// Converts an InboxItem into a Workspace Prompt Run.
  Future<String> convertToWorkspaceRun({
    required String inboxId,
    required String projectId,
    required String title,
    required String body,
  }) async {
    return await _db.transaction(() async {
      final now = DateTime.now();
      final newRunId = const Uuid().v4();

      // 1. Create the Workspace Prompt Run
      await _db.promptExampleDao.createExample(PromptExamplesCompanion.insert(
        id: newRunId,
        projectId: drift.Value(projectId),
        title: title,
        compiledPrompt: body,
        createdAt: now,
        updatedAt: now,
      ));

      // 2. Mark Inbox item as converted (no run linkage stored to avoid schema migration)
      await _db.inboxItemDao.markInboxItemConvertedToRun(inboxId);

      return newRunId;
    });
  }
}

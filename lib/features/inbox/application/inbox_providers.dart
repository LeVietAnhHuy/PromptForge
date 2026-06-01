import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';

import '../../../core/database/database.dart';
import '../../../core/database/database_providers.dart';
import '../../../core/database/daos/daos.dart';

final openInboxItemsProvider = StreamProvider<List<InboxItem>>((ref) {
  return ref.watch(inboxItemDaoProvider).watchOpenInboxItems();
});

final inboxServiceProvider = Provider<InboxService>((ref) {
  return InboxService(
    db: ref.watch(databaseProvider),
    inboxDao: ref.watch(inboxItemDaoProvider),
    promptDao: ref.watch(promptDaoProvider),
  );
});

class InboxService {
  final AppDatabase db;
  final InboxItemDao inboxDao;
  final PromptDao promptDao;

  InboxService({
    required this.db,
    required this.inboxDao,
    required this.promptDao,
  });

  Future<void> convertToPrompt(InboxItem item) async {
    await db.transaction(() async {
      final newPromptId = const Uuid().v4();
      final now = DateTime.now();

      await promptDao.createPrompt(PromptsCompanion.insert(
        id: newPromptId,
        title: item.title ?? 'Untitled from Inbox',
        body: item.rawText,
        createdAt: now,
        updatedAt: now,
      ));

      await inboxDao.markInboxItemConverted(item.id, newPromptId);
    });
  }
}

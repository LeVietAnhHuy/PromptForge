import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';
import 'package:drift/drift.dart' as drift;

import '../../../core/database/database.dart';
import '../../../core/database/database_providers.dart';
import '../../../core/database/daos/daos.dart';
import '../domain/import_export_codec.dart';

final importExportServiceProvider = Provider<ImportExportService>((ref) {
  return ImportExportService(
    db: ref.watch(databaseProvider),
    promptDao: ref.watch(promptDaoProvider),
    contextPackDao: ref.watch(contextPackDaoProvider),
  );
});

class ImportExportService {
  final AppDatabase db;
  final PromptDao promptDao;
  final ContextPackDao contextPackDao;

  ImportExportService({
    required this.db,
    required this.promptDao,
    required this.contextPackDao,
  });

  Future<String> exportActiveData() async {
    final activePrompts = await (promptDao.select(promptDao.prompts)..where((t) => t.isArchived.not())).get();
    final activeContextPacks = await contextPackDao.getAllContextPacks();
    return ImportExportCodec.encodeExport(activePrompts, activeContextPacks);
  }

  Future<void> importData(ImportPreview preview) async {
    await db.transaction(() async {
      for (final prompt in preview.validPrompts) {
        await promptDao.createPrompt(PromptsCompanion.insert(
          id: const Uuid().v4(), // Always create new ID
          title: prompt.title,
          body: prompt.body,
          purpose: prompt.purpose != null ? drift.Value(prompt.purpose) : const drift.Value.absent(),
          createdAt: prompt.createdAt,
          updatedAt: prompt.updatedAt,
          isArchived: drift.Value(prompt.isArchived),
          isFavorite: drift.Value(prompt.isFavorite),
          usageCount: drift.Value(prompt.usageCount),
        ));
      }

      for (final pack in preview.validContextPacks) {
        await contextPackDao.createContextPack(ContextPacksCompanion.insert(
          id: const Uuid().v4(), // Always create new ID
          name: pack.name,
          description: pack.description != null ? drift.Value(pack.description) : const drift.Value.absent(),
          content: pack.content,
          createdAt: pack.createdAt,
          updatedAt: pack.updatedAt,
          isArchived: drift.Value(pack.isArchived),
          isBuiltin: drift.Value(pack.isBuiltin),
          sortOrder: drift.Value(pack.sortOrder),
        ));
      }
    });
  }
}

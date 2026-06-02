import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';
import 'package:drift/drift.dart' as drift;

import '../../../core/database/database.dart';
import '../../../core/database/database_providers.dart';
import '../../../core/database/daos/daos.dart';
import '../domain/import_export_codec.dart';

enum MergeStrategy {
  duplicate,
  overwrite,
  skip,
}

final importExportServiceProvider = Provider<ImportExportService>((ref) {
  return ImportExportService(
    db: ref.watch(databaseProvider),
    promptDao: ref.watch(promptDaoProvider),
    contextPackDao: ref.watch(contextPackDaoProvider),
    tagDao: ref.watch(tagDaoProvider),
    pvDao: ref.watch(promptVariableDaoProvider),
  );
});

class ImportExportService {
  final AppDatabase db;
  final PromptDao promptDao;
  final ContextPackDao contextPackDao;
  final TagDao tagDao;
  final PromptVariableDao pvDao;

  ImportExportService({
    required this.db,
    required this.promptDao,
    required this.contextPackDao,
    required this.tagDao,
    required this.pvDao,
  });

  Future<String> exportActiveData() async {
    final activePrompts = await (promptDao.select(promptDao.prompts)..where((t) => t.isArchived.not())).get();
    final activeContextPacks = await contextPackDao.getAllContextPacks();
    
    // Fetch tags and variables for active prompts
    final promptTags = <String, List<String>>{};
    final promptVariables = <String, List<PromptVariable>>{};
    
    for (final prompt in activePrompts) {
      final tags = await tagDao.getTagsForPrompt(prompt.id);
      promptTags[prompt.id] = tags.map((t) => t.name).toList();
      
      final vars = await pvDao.getVariablesForPrompt(prompt.id);
      promptVariables[prompt.id] = vars;
    }

    return ImportExportCodec.encodeExport(activePrompts, promptTags, promptVariables, activeContextPacks);
  }

  Future<void> importData(ImportPreview preview, {MergeStrategy strategy = MergeStrategy.duplicate}) async {
    await db.transaction(() async {
      for (final imported in preview.validPrompts) {
        final prompt = imported.prompt;
        
        final existingPrompt = await (promptDao.select(promptDao.prompts)..where((t) => t.id.equals(prompt.id))).getSingleOrNull();
        
        String targetId = prompt.id;
        
        if (existingPrompt != null) {
          if (strategy == MergeStrategy.skip) {
            continue;
          } else if (strategy == MergeStrategy.duplicate) {
            targetId = const Uuid().v4();
          }
        }
        
        final companion = PromptsCompanion.insert(
          id: targetId,
          title: prompt.title,
          body: prompt.body,
          purpose: prompt.purpose != null ? drift.Value(prompt.purpose) : const drift.Value.absent(),
          createdAt: prompt.createdAt,
          updatedAt: prompt.updatedAt,
          isArchived: drift.Value(prompt.isArchived),
          isFavorite: drift.Value(prompt.isFavorite),
          usageCount: drift.Value(prompt.usageCount),
        );
        
        if (existingPrompt != null && strategy == MergeStrategy.overwrite) {
          await promptDao.updatePrompt(companion);
        } else {
          await promptDao.createPrompt(companion);
        }

        // Import tags
        if (imported.tags.isNotEmpty) {
          await tagDao.replaceTagsForPrompt(targetId, imported.tags);
        }
        
        // Import variables
        if (imported.variables.isNotEmpty) {
          final varCompanions = imported.variables.map((v) => PromptVariablesCompanion.insert(
            id: const Uuid().v4(),
            promptId: targetId,
            name: v.name,
            label: v.label != null ? drift.Value(v.label) : const drift.Value.absent(),
            description: v.description != null ? drift.Value(v.description) : const drift.Value.absent(),
            defaultValue: v.defaultValue != null ? drift.Value(v.defaultValue) : const drift.Value.absent(),
            exampleValue: v.exampleValue != null ? drift.Value(v.exampleValue) : const drift.Value.absent(),
            isRequired: drift.Value(v.isRequired),
            sortOrder: drift.Value(v.sortOrder),
            createdAt: v.createdAt,
            updatedAt: v.updatedAt,
          )).toList();
          await pvDao.syncVariablesForPrompt(targetId, varCompanions);
        }
      }

      for (final pack in preview.validContextPacks) {
        final existingPack = await (contextPackDao.select(contextPackDao.contextPacks)..where((t) => t.id.equals(pack.id))).getSingleOrNull();
        String targetId = pack.id;
        
        if (existingPack != null) {
          if (strategy == MergeStrategy.skip) {
            continue;
          } else if (strategy == MergeStrategy.duplicate) {
            targetId = const Uuid().v4();
          }
        }
        
        final companion = ContextPacksCompanion.insert(
          id: targetId,
          name: pack.name,
          description: pack.description != null ? drift.Value(pack.description) : const drift.Value.absent(),
          content: pack.content,
          createdAt: pack.createdAt,
          updatedAt: pack.updatedAt,
          isArchived: drift.Value(pack.isArchived),
          isBuiltin: drift.Value(pack.isBuiltin),
          sortOrder: drift.Value(pack.sortOrder),
        );
        
        if (existingPack != null && strategy == MergeStrategy.overwrite) {
          await contextPackDao.updateContextPack(companion);
        } else {
          await contextPackDao.createContextPack(companion);
        }
      }
    });
  }
}

import 'dart:io';
import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as p;

import 'tables/tables.dart';
import 'daos/daos.dart';

part 'database.g.dart';

@DriftDatabase(
  tables: [
    Prompts,
    PromptVersions,
    PromptVariables,
    ContextPacks,
    ContextPackVersions,
    PromptContextPackLinks,
    Tags,
    PromptTags,
    Collections,
    PromptCollectionLinks,
    InboxItems,
    UserSettings,
    PromptExamples,
    PromptExampleOutputs,
    Projects,
    LLMProviders,
    LLMModels,
    LLMOutputAttachments,
  ],
  daos: [
    PromptDao,
    ContextPackDao,
    TagDao,
    CollectionDao,
    InboxItemDao,
    UserSettingsDao,
    PromptExampleDao,
    PromptExampleOutputDao,
    ProjectDao,
    LLMProviderDao,
    LLMModelDao,
    LLMOutputAttachmentDao,
  ],
)
class AppDatabase extends _$AppDatabase {
  AppDatabase({QueryExecutor? e}) : super(e ?? _openConnection());

  @override
  int get schemaVersion => 6;

  @override
  MigrationStrategy get migration {
    return MigrationStrategy(
      onCreate: (Migrator m) async {
        await m.createAll();
      },
      onUpgrade: (Migrator m, int from, int to) async {
        if (from < 2) {
          // Stage 7: added title to InboxItems
          try { await m.addColumn(inboxItems, inboxItems.title); } catch (_) {}
          
          // Stage 9: added fields to PromptVariables
          try { await m.addColumn(promptVariables, promptVariables.label); } catch (_) {}
          try { await m.addColumn(promptVariables, promptVariables.description); } catch (_) {}
          try { await m.addColumn(promptVariables, promptVariables.defaultValue); } catch (_) {}
          try { await m.addColumn(promptVariables, promptVariables.exampleValue); } catch (_) {}
          try { await m.addColumn(promptVariables, promptVariables.isRequired); } catch (_) {}
          try { await m.addColumn(promptVariables, promptVariables.sortOrder); } catch (_) {}

          // Stage 10: added PromptExamples and Outputs
          try { await m.createTable(promptExamples); } catch (_) {}
          try { await m.createTable(promptExampleOutputs); } catch (_) {}
        }
        if (from < 3) {
          // Stage 13: added version history for prompts and context packs
          // Drop unused older prompt_versions table and create the new one
          try { await m.drop(promptVersions); } catch (_) {}
          try { await m.createTable(promptVersions); } catch (_) {}
          try { await m.createTable(contextPackVersions); } catch (_) {}
        }
        if (from < 4) {
          try { await m.createTable(projects); } catch (_) {}
          try { await m.createTable(lLMProviders); } catch (_) {}
          try { await m.createTable(lLMModels); } catch (_) {}
          try { await m.createTable(lLMOutputAttachments); } catch (_) {}
          try { await m.addColumn(promptExamples, promptExamples.projectId); } catch (_) {}
          try { await m.addColumn(promptExamples, promptExamples.refinementNote); } catch (_) {}
          // Note: Drift schema alter required for nullability changes
          try { await m.alterTable(TableMigration(promptExamples)); } catch (_) {}
          try { await m.addColumn(promptExampleOutputs, promptExampleOutputs.providerId); } catch (_) {}
          try { await m.addColumn(promptExampleOutputs, promptExampleOutputs.modelId); } catch (_) {}
          try { await m.addColumn(promptExampleOutputs, promptExampleOutputs.outputType); } catch (_) {}
        }
        if (from < 5) {
          try { await m.addColumn(lLMOutputAttachments, lLMOutputAttachments.sizeBytes); } catch (_) {}
          try { await m.addColumn(lLMOutputAttachments, lLMOutputAttachments.attachmentType); } catch (_) {}
          // Update existing provider names
          try {
            await (update(lLMProviders)..where((t) => t.id.equals('openai'))).write(const LLMProvidersCompanion(name: Value('OpenAI')));
            await (update(lLMProviders)..where((t) => t.id.equals('anthropic'))).write(const LLMProvidersCompanion(name: Value('Anthropic')));
            await (update(lLMProviders)..where((t) => t.id.equals('google'))).write(const LLMProvidersCompanion(name: Value('Google')));
            await (update(lLMProviders)..where((t) => t.id.equals('alibaba'))).write(const LLMProvidersCompanion(name: Value('Alibaba / Qwen')));
            await (update(lLMProviders)..where((t) => t.id.equals('meta'))).write(const LLMProvidersCompanion(name: Value('Meta')));
            await (update(lLMProviders)..where((t) => t.id.equals('local'))).write(const LLMProvidersCompanion(name: Value('Local')));
          } catch (_) {}
        }
        if (from < 6) {
          try { await m.addColumn(promptExampleOutputs, promptExampleOutputs.sourceType); } catch (_) {}
        }
      },
    );
  }
}

LazyDatabase _openConnection() {
  return LazyDatabase(() async {
    final dbFolder = await getApplicationDocumentsDirectory();
    final file = File(p.join(dbFolder.path, 'promptforge_db.sqlite'));
    return NativeDatabase.createInBackground(file);
  });
}

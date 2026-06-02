import 'dart:io';
import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as p;

import 'tables/tables.dart';

part 'database.g.dart';

@DriftDatabase(tables: [
  Prompts,
  PromptVersions,
  PromptVariables,
  ContextPacks,
  PromptContextPackLinks,
  Tags,
  PromptTags,
  Collections,
  PromptCollectionLinks,
  InboxItems,
  UserSettings,
  PromptExamples,
  PromptExampleOutputs,
  ContextPackVersions,
])
class AppDatabase extends _$AppDatabase {
  AppDatabase({QueryExecutor? e}) : super(e ?? _openConnection());

  @override
  int get schemaVersion => 3;

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

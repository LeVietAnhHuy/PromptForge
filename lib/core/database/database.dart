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
])
class AppDatabase extends _$AppDatabase {
  AppDatabase({QueryExecutor? e}) : super(e ?? _openConnection());

  @override
  int get schemaVersion => 1;

  @override
  MigrationStrategy get migration {
    return MigrationStrategy(
      onCreate: (Migrator m) async {
        await m.createAll();
      },
      onUpgrade: (Migrator m, int from, int to) async {
        // Handle database migrations here
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

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:drift/native.dart';
import 'package:promptforge/core/database/database.dart';
import 'package:promptforge/core/database/database_providers.dart';
import 'package:promptforge/features/import_export/presentation/import_screen.dart';
import 'package:promptforge/features/import_export/presentation/export_preview_screen.dart';

void main() {
  late AppDatabase database;

  setUp(() {
    database = AppDatabase(e: NativeDatabase.memory());
  });

  tearDown(() async {
    await database.close();
  });

  Widget createExportApp() {
    return ProviderScope(
      overrides: [
        databaseProvider.overrideWithValue(database),
      ],
      child: const MaterialApp(
        home: ExportPreviewScreen(),
      ),
    );
  }

  Widget createImportApp() {
    return ProviderScope(
      overrides: [
        databaseProvider.overrideWithValue(database),
      ],
      child: const MaterialApp(
        home: ImportScreen(),
      ),
    );
  }

  testWidgets('ExportPreviewScreen displays generated JSON', (tester) async {
    final now = DateTime.now();
    await database.into(database.prompts).insert(PromptsCompanion.insert(
      id: 'export-test-id',
      title: 'Export Prompt',
      body: 'Body',
      createdAt: now,
      updatedAt: now,
    ));

    await tester.pumpWidget(createExportApp());
    await tester.pumpAndSettle();

    expect(find.textContaining('Export Prompt'), findsOneWidget);
    expect(find.textContaining('"schemaVersion": 2'), findsOneWidget);
    expect(find.byIcon(Icons.copy), findsOneWidget);
    expect(find.byIcon(Icons.save), findsOneWidget);
  });

}

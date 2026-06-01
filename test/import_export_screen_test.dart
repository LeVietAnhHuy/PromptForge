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
    expect(find.textContaining('"schemaVersion": 1'), findsOneWidget);
    expect(find.byIcon(Icons.copy), findsOneWidget);
  });

  testWidgets('ImportScreen handles invalid JSON', (tester) async {
    await tester.pumpWidget(createImportApp());
    await tester.pumpAndSettle();

    await tester.enterText(find.byType(TextField), 'invalid json');
    await tester.tap(find.text('Preview Import'));
    await tester.pumpAndSettle();

    expect(find.textContaining('Invalid JSON format.'), findsOneWidget);
    expect(find.text('Confirm Import'), findsNothing);
  });

  testWidgets('ImportScreen previews and imports valid JSON', (tester) async {
    await tester.pumpWidget(createImportApp());
    await tester.pumpAndSettle();

    const validJson = '''
    {
      "app": "PromptForge",
      "schemaVersion": 1,
      "prompts": [
        { "id": "p1", "title": "A", "body": "B", "createdAt": "2026-06-01T00:00:00Z", "updatedAt": "2026-06-01T00:00:00Z" }
      ],
      "contextPacks": []
    }
    ''';

    await tester.enterText(find.byType(TextField), validJson);
    await tester.tap(find.text('Preview Import'));
    await tester.pumpAndSettle();

    // Verify summary is shown
    expect(find.text('Import Summary'), findsOneWidget);
    expect(find.text('Valid Prompts: 1'), findsOneWidget);
    
    // Confirm import
    await tester.tap(find.text('Confirm Import'));
    await tester.pumpAndSettle();

    // Should pop back and save to db (since we pop, the widget should be unmounted or show snackbar)
    // We can verify DB state directly
    final prompts = await database.select(database.prompts).get();
    expect(prompts.length, 1);
    expect(prompts.first.title, 'A');
    expect(prompts.first.id, isNot('p1')); // Ensures we imported as a new copy
  });
}

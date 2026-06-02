import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:drift/native.dart';
import 'package:promptforge/core/database/database.dart';
import 'package:promptforge/core/database/database_providers.dart';
import 'package:promptforge/features/prompt_library/presentation/prompt_editor_screen.dart';

void main() {
  late AppDatabase database;

  setUp(() {
    database = AppDatabase(e: NativeDatabase.memory());
  });

  tearDown(() async {
    await database.close();
  });

  Widget createTestApp() {
    final router = GoRouter(
      initialLocation: '/',
      routes: [
        GoRoute(
          path: '/',
          builder: (context, state) => const PromptEditorScreen(),
        ),
      ],
    );

    return ProviderScope(
      overrides: [
        databaseProvider.overrideWithValue(database),
      ],
      child: MaterialApp.router(
        routerConfig: router,
      ),
    );
  }

  testWidgets('Prompt editor save with tags + variables works', (tester) async {
    await tester.pumpWidget(createTestApp());
    await tester.pumpAndSettle();

    // 1. Enter title
    await tester.enterText(find.widgetWithText(TextFormField, 'Title'), 'Test Prompt');

    // 2. Enter tags
    await tester.enterText(find.widgetWithText(TextFormField, 'Tags (comma-separated)'), 'tag1, tag2');

    // 3. Enter body with variables
    await tester.enterText(find.widgetWithText(TextFormField, 'Prompt Body'), 'Hello {{name}}');
    await tester.pumpAndSettle(); // Wait for variable extraction

    // Verify metadata form appears
    final metaFinder = find.text('Variable Metadata', skipOffstage: false);
    await tester.ensureVisible(metaFinder);
    await tester.pumpAndSettle();
    expect(find.text('Variable Metadata'), findsOneWidget);
    expect(find.text('{{name}}'), findsOneWidget);

    // Enter metadata
    await tester.enterText(find.widgetWithText(TextField, 'Display Label').first, 'Your Name');
    
    // 4. Save
    await tester.tap(find.byIcon(Icons.save));
    await tester.pumpAndSettle();

    // Verify db
    final prompts = await database.select(database.prompts).get();
    expect(prompts.length, 1);
    final p = prompts.first;
    expect(p.title, 'Test Prompt');
    expect(p.body, 'Hello {{name}}');
    final tags = await database.select(database.tags).get();
    expect(tags.length, 2);

    final vars = await database.select(database.promptVariables).get();
    expect(vars.length, 1);
    expect(vars.first.name, 'name');
    expect(vars.first.label, 'Your Name');
    expect(vars.first.isRequired, true);
  });
}

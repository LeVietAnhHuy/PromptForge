import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:drift/native.dart';
import 'package:promptforge/core/database/database.dart';
import 'package:promptforge/core/database/database_providers.dart';
import 'package:promptforge/features/prompt_library/presentation/prompt_editor_screen.dart';
import 'package:promptforge/shared/markdown/inline_markdown_editor.dart';

void main() {
  late AppDatabase database;

  setUp(() {
    database = AppDatabase(e: NativeDatabase.memory());
  });

  tearDown(() async {
    await database.close();
  });

  Widget createTestApp({String? promptId}) {
    final router = GoRouter(
      initialLocation: '/',
      routes: [
        GoRoute(
          path: '/',
          builder: (context, state) => PromptEditorScreen(promptId: promptId),
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

    // 3. Enter body with variables (via Focus Editor)
    await tester.tap(find.text('Open Focus Editor'));
    await tester.pumpAndSettle();
    
    // Switch to Edit mode inside the modal
    await tester.tap(find.text('Edit').last); // .last because there might be one hidden or whatever, actually just 'Edit' is fine
    await tester.pumpAndSettle();

    await tester.enterText(
      find.widgetWithText(TextFormField, 'Enter prompt body (Markdown supported)...'),
      'Hello {{name}}',
    );
    await tester.pump();
    
    await tester.tap(find.text('Apply'));
    await tester.pumpAndSettle(); // Wait for modal to close and variable extraction

    // Verify metadata form appears (may need to scroll in the ListView)
    await tester.scrollUntilVisible(
      find.text('Variable Metadata'),
      200,
      scrollable: find.byType(Scrollable).first,
    );
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

  testWidgets('Prompt Focus Editor supports Preview/Edit toggle with rich markdown', (tester) async {
    await tester.pumpWidget(createTestApp());
    await tester.pumpAndSettle();

    // Open Focus Editor
    await tester.tap(find.text('Open Focus Editor'));
    await tester.pumpAndSettle();

    // Modal defaults to Preview mode but if it's empty, we might want to edit it. 
    // Actually our modal implementation defaults to Preview, let's switch to Edit
    await tester.tap(find.text('Edit').last);
    await tester.pumpAndSettle();

    // Body field is a TextFormField in Edit mode
    expect(
      find.widgetWithText(TextFormField, 'Enter prompt body (Markdown supported)...'),
      findsOneWidget,
    );

    // Enter markdown content
    await tester.enterText(
      find.widgetWithText(TextFormField, 'Enter prompt body (Markdown supported)...'),
      '# My Heading\nSome paragraph text.\n## Section 2',
    );
    await tester.pump();

    // Switch to Preview mode
    await tester.tap(find.text('Preview').last);
    await tester.pumpAndSettle();

    // InlineMarkdownEditor should now be visible (at least 1, usually 2 because of background card)
    expect(find.byType(InlineMarkdownEditor), findsWidgets);

    // The raw TextFormField for body should be gone
    expect(
      find.widgetWithText(TextFormField, 'Enter prompt body (Markdown supported)...'),
      findsNothing,
    );

    // Style selector should be present
    expect(find.text('PromptForge'), findsWidgets);

    // Switch back to Edit mode
    await tester.tap(find.text('Edit').last);
    await tester.pumpAndSettle();

    // TextFormField should be back with the same content
    final bodyField = tester.widget<TextFormField>(
      find.widgetWithText(TextFormField, 'Enter prompt body (Markdown supported)...').first,
    );
    expect(bodyField.controller?.text, '# My Heading\nSome paragraph text.\n## Section 2');
    
    // Apply and close modal
    await tester.tap(find.text('Apply'));
    await tester.pumpAndSettle();
  });

  testWidgets('Prompt editor supports manual output capture', (tester) async {
    final promptId = 'test-prompt-id';
    await database.into(database.prompts).insert(PromptsCompanion.insert(
      id: promptId,
      title: 'Test Output Prompt',
      body: 'Body text',
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    ));

    await tester.pumpWidget(createTestApp(promptId: promptId));
    await tester.pumpAndSettle();

    // 1. Scroll to Outputs Lab
    await tester.scrollUntilVisible(
      find.text('Saved Outputs'),
      500.0,
      scrollable: find.byType(Scrollable).first,
    );
    await tester.pumpAndSettle();

    // 2. Now Paste LLM Output should work
    final pasteButton = find.text('Paste LLM Output');
    expect(pasteButton, findsOneWidget);
    await tester.ensureVisible(pasteButton);
    await tester.pumpAndSettle();
    
    await tester.tap(pasteButton);
    await tester.pumpAndSettle();

    // Dialog should be present
    expect(find.text('Paste External LLM Output'), findsOneWidget);

    // 3. Fill form
    await tester.enterText(find.widgetWithText(TextFormField, 'Provider (e.g. Claude)'), 'ChatGPT');
    await tester.enterText(find.widgetWithText(TextFormField, 'Model (Optional)'), 'GPT-4o');
    await tester.enterText(find.widgetWithText(TextFormField, 'Pasted Output'), 'This is a mocked output from ChatGPT.');
    await tester.pump();

    // Save Output
    await tester.tap(find.text('Save Output'));
    await tester.pumpAndSettle();

    // Modal should close and card should appear
    expect(find.text('Paste External LLM Output'), findsNothing);
    expect(find.text('Output saved manually.'), findsOneWidget);
    
    // Verify card is rendered
    expect(find.text('ChatGPT'), findsWidgets); // chip
    expect(find.text('GPT-4o'), findsOneWidget); // model name
    expect(find.text('This is a mocked output from ChatGPT.'), findsOneWidget); // markdown body

    // Wait for SnackBar to disappear
    ScaffoldMessenger.of(tester.element(find.byType(Scaffold).first)).clearSnackBars();
    await tester.pumpAndSettle();
    
    // Unmount to trigger dispose
    await tester.pumpWidget(Container());
    await tester.pumpAndSettle();
  });
}

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:drift/native.dart';
import 'package:promptforge/core/database/database.dart';
import 'package:promptforge/core/database/database_providers.dart';
import 'package:promptforge/features/prompt_compiler/presentation/prompt_compiler_screen.dart';
import 'package:drift/drift.dart' as drift;

void main() {
  late AppDatabase database;

  setUp(() {
    database = AppDatabase(e: NativeDatabase.memory());
  });

  tearDown(() async {
    await database.close();
  });

  Widget createTestApp(String promptId) {
    return ProviderScope(
      overrides: [
        databaseProvider.overrideWithValue(database),
      ],
      child: MaterialApp(
        home: PromptCompilerScreen(promptId: promptId),
      ),
    );
  }

  testWidgets('PromptCompilerScreen builds fields and previews output', (tester) async {
    // 1. Seed database
    final now = DateTime.now();
    await database.into(database.prompts).insert(PromptsCompanion.insert(
      id: 'test-prompt-id',
      title: 'Email Template',
      body: 'Write a {tone} email to {recipient}.',
      createdAt: now,
      updatedAt: now,
    ));
    await database.into(database.contextPacks).insert(ContextPacksCompanion.insert(
      id: 'pack-1',
      name: 'Research Style',
      content: 'Explain concepts step by step.',
      createdAt: now,
      updatedAt: now,
    ));
    // Link pack
    await database.into(database.promptContextPackLinks).insert(PromptContextPackLinksCompanion.insert(
      promptId: 'test-prompt-id',
      contextPackId: 'pack-1',
      sortOrder: const drift.Value(0),
      createdAt: now,
    ));

    // 2. Pump widget
    await tester.pumpWidget(createTestApp('test-prompt-id'));
    await tester.pumpAndSettle();

    // Verify initial state
    expect(find.text('Compile: Email Template'), findsOneWidget);
    expect(find.byType(TextField), findsNWidgets(2)); // tone, recipient
    expect(find.textContaining('Replace {tone}'), findsOneWidget);
    expect(find.textContaining('Replace {recipient}'), findsOneWidget);
    expect(find.text('Attached Context Packs (1)'), findsOneWidget); // Context pack section
    
    // Preview initially shows raw body since nothing is typed (and variables missing)
    expect(find.textContaining('Write a {tone} email to {recipient}.'), findsOneWidget);
    
    // Verify missing variables warning
    expect(find.textContaining('Missing required variables: tone, recipient'), findsOneWidget);

    // 4. Enter values
    await tester.enterText(find.byType(TextField).first, 'friendly');
    await tester.enterText(find.byType(TextField).last, 'Bob');
    await tester.pumpAndSettle();

    // 5. Verify compiled preview updates and warning disappears
    expect(find.textContaining('Write a friendly email to Bob.'), findsOneWidget);
    expect(find.textContaining('Missing required variables'), findsNothing);
    
    // Verify context pack prepended to output
    expect(find.textContaining('# Context Packs'), findsOneWidget);
    expect(find.textContaining('Explain concepts step by step.'), findsOneWidget);
    expect(find.textContaining('# Prompt'), findsOneWidget);
    expect(find.textContaining('Write a friendly email to Bob.'), findsOneWidget);

    // 7. Unmount
    await tester.pumpWidget(Container());
    await tester.pump(const Duration(seconds: 1));
  });

  testWidgets('PromptCompilerScreen works for prompts without variables', (tester) async {
    final now = DateTime.now();
    await database.into(database.prompts).insert(PromptsCompanion.insert(
      id: 'no-var-prompt-id',
      title: 'Simple Prompt',
      body: 'This is a simple prompt without variables.',
      createdAt: now,
      updatedAt: now,
    ));

    await tester.pumpWidget(createTestApp('no-var-prompt-id'));
    await tester.pumpAndSettle();

    // Verify initial state
    expect(find.text('Compile: Simple Prompt'), findsOneWidget);
    expect(find.text('No variables detected in this prompt.'), findsOneWidget);
    expect(find.byType(TextField), findsNothing);

    // Preview initially shows raw body since nothing is typed
    expect(find.textContaining('This is a simple prompt without variables.'), findsOneWidget);

    // Verify copy button is present
    expect(find.widgetWithText(ElevatedButton, 'Copy Output'), findsOneWidget);

    // Unmount
    await tester.pumpWidget(Container());
    await tester.pump(const Duration(seconds: 1));
  });

  testWidgets('PromptCompilerScreen executes prompt with Mock Provider and displays output', (tester) async {
    final now = DateTime.now();
    await database.into(database.prompts).insert(PromptsCompanion.insert(
      id: 'exec-prompt-id',
      title: 'Exec Prompt',
      body: 'Simple prompt to execute',
      createdAt: now,
      updatedAt: now,
    ));

    await tester.pumpWidget(createTestApp('exec-prompt-id'));
    await tester.pumpAndSettle();

    // Verify Execution Panel exists
    expect(find.text('Execute'), findsOneWidget);
    expect(find.text('Provider'), findsOneWidget);
    
    // Select Mock Provider if not selected
    // Note: Provider is MockProvider by default since it's the first in the list
    expect(find.text('Mock Provider'), findsOneWidget);

    // Click Run
    await tester.tap(find.widgetWithText(ElevatedButton, 'Run'));
    await tester.pump(); // Start execution
    
    // Wait for the simulated delay (1.5 seconds)
    await tester.pump(const Duration(seconds: 2));
    await tester.pumpAndSettle();

    // Verify output appears
    expect(find.text('Output'), findsOneWidget);
    expect(find.textContaining('This is a deterministic mock output from Mock Fast Model'), findsOneWidget);
    expect(find.textContaining('Execution successful. Output saved to history.'), findsOneWidget);

    // Verify it saved to DB
    final outputs = await database.select(database.promptExampleOutputs).get();
    expect(outputs.length, 1);
    expect(outputs.first.outputText, contains('deterministic mock output'));
    expect(outputs.first.providerId, 'mock');
    
    // Unmount
    await tester.pumpWidget(Container());
    await tester.pump(const Duration(seconds: 1));
  });
}

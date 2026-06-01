import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:drift/native.dart';
import 'package:promptforge/core/database/database.dart';
import 'package:promptforge/core/database/database_providers.dart';
import 'package:promptforge/features/prompt_compiler/presentation/prompt_compiler_screen.dart';

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
      body: 'Write a {{tone}} email to {{recipient}}.',
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

    // 2. Pump widget
    await tester.pumpWidget(createTestApp('test-prompt-id'));
    await tester.pumpAndSettle();

    // Verify initial state
    expect(find.text('Compile: Email Template'), findsOneWidget);
    expect(find.byType(TextField), findsNWidgets(2)); // tone, recipient
    expect(find.text('tone'), findsOneWidget); // label
    expect(find.text('recipient'), findsOneWidget); // label
    expect(find.text('Context Pack'), findsOneWidget); // Context pack section
    
    // Preview initially shows raw body since nothing is typed
    expect(find.textContaining('Write a {{tone}} email to {{recipient}}.'), findsOneWidget);
    
    // Verify copy button is disabled (because variables are missing)
    final copyButton = tester.widget<ElevatedButton>(find.widgetWithText(ElevatedButton, 'Copy Output'));
    expect(copyButton.onPressed, isNull);
    expect(find.text('Fill all variables to enable copying.'), findsOneWidget);

    // 4. Enter values
    await tester.enterText(find.widgetWithText(TextField, 'tone'), 'friendly');
    await tester.enterText(find.widgetWithText(TextField, 'recipient'), 'Bob');
    await tester.pumpAndSettle();

    // 5. Verify compiled preview updates and copy is enabled
    expect(find.textContaining('Write a friendly email to Bob.'), findsOneWidget);
    final copyButtonEnabled = tester.widget<ElevatedButton>(find.widgetWithText(ElevatedButton, 'Copy Output'));
    expect(copyButtonEnabled.onPressed, isNotNull);
    expect(find.text('Fill all variables to enable copying.'), findsNothing);
    
    // 6. Select a context pack
    // Open dropdown and select
    await tester.tap(find.byType(DropdownButton<String?>));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Research Style').last);
    await tester.pumpAndSettle();
    
    // Verify context pack prepended to output
    expect(find.textContaining('[Context]'), findsOneWidget);
    expect(find.textContaining('Explain concepts step by step.'), findsOneWidget);
    expect(find.textContaining('[Prompt]'), findsOneWidget);
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

    // Verify copy button is enabled because there are no variables missing
    final copyButtonEnabled = tester.widget<ElevatedButton>(find.widgetWithText(ElevatedButton, 'Copy Output'));
    expect(copyButtonEnabled.onPressed, isNotNull);

    // Unmount
    await tester.pumpWidget(Container());
    await tester.pump(const Duration(seconds: 1));
  });
}

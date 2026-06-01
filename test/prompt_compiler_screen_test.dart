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

    // 2. Pump widget
    await tester.pumpWidget(createTestApp('test-prompt-id'));
    await tester.pumpAndSettle();

    // 3. Verify initial state
    expect(find.text('Compile: Email Template'), findsOneWidget);
    expect(find.byType(TextField), findsNWidgets(2)); // tone, recipient
    expect(find.text('tone'), findsOneWidget); // label
    expect(find.text('recipient'), findsOneWidget); // label
    
    // Preview initially shows raw body since nothing is typed
    expect(find.textContaining('Write a {{tone}} email to {{recipient}}.'), findsOneWidget);

    // 4. Enter values
    await tester.enterText(find.widgetWithText(TextField, 'tone'), 'friendly');
    await tester.enterText(find.widgetWithText(TextField, 'recipient'), 'Bob');
    await tester.pumpAndSettle();

    // 5. Verify compiled preview updates
    expect(find.textContaining('Write a friendly email to Bob.'), findsOneWidget);
    
    // 6. Unmount
    await tester.pumpWidget(Container());
    await tester.pump(const Duration(seconds: 1));
  });
}

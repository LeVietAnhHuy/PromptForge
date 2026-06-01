import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:drift/native.dart';
import 'package:go_router/go_router.dart';

import 'package:promptforge/core/database/database.dart';
import 'package:promptforge/core/database/database_providers.dart';
import 'package:promptforge/core/database/daos/daos.dart';
import 'package:promptforge/features/prompt_library/presentation/prompt_library_screen.dart';
import 'package:promptforge/features/prompt_library/presentation/prompt_editor_screen.dart';

void main() {
  late AppDatabase database;

  setUp(() {
    database = AppDatabase(e: NativeDatabase.memory());
  });

  tearDown(() async {
    await database.close();
  });

  Widget createTestApp(String initialLocation) {
    final router = GoRouter(
      initialLocation: initialLocation,
      routes: [
        GoRoute(
          path: '/library',
          builder: (context, state) => const PromptLibraryScreen(),
          routes: [
            GoRoute(
              path: 'editor',
              builder: (context, state) => const PromptEditorScreen(),
            ),
            GoRoute(
              path: 'editor/:id',
              builder: (context, state) => PromptEditorScreen(
                promptId: state.pathParameters['id'],
              ),
            ),
          ],
        ),
      ],
    );

    return ProviderScope(
      overrides: [
        databaseProvider.overrideWithValue(database),
        promptDaoProvider.overrideWithValue(PromptDao(database)),
      ],
      child: MaterialApp.router(
        routerConfig: router,
      ),
    );
  }

  testWidgets('Prompt Library shows empty state initially', (tester) async {
    await tester.pumpWidget(createTestApp('/library'));
    await tester.pumpAndSettle();

    expect(find.text('No prompts found. Create one!'), findsOneWidget);
    expect(find.byType(FloatingActionButton), findsOneWidget);

    await tester.pumpWidget(Container());
    await tester.pump(const Duration(seconds: 1));
  });

  testWidgets('Creating a prompt flow works', (tester) async {
    await tester.pumpWidget(createTestApp('/library'));
    await tester.pumpAndSettle();

    // Tap FAB
    await tester.tap(find.byType(FloatingActionButton));
    await tester.pumpAndSettle();

    // Should be on Editor screen
    expect(find.text('New Prompt'), findsOneWidget);

    // Enter details
    await tester.enterText(find.widgetWithText(TextFormField, 'Title'), 'My Awesome Prompt');
    await tester.enterText(find.widgetWithText(TextFormField, 'Prompt Body'), 'This is the body.');
    await tester.pump();

    // Tap save
    await tester.tap(find.byIcon(Icons.save));
    await tester.pumpAndSettle();

    // Should be back on library screen
    expect(find.text('Prompt Library'), findsOneWidget);

    // The new prompt should be listed
    expect(find.text('My Awesome Prompt'), findsOneWidget);
    expect(find.text('This is the body.'), findsOneWidget);

    await tester.pumpWidget(Container());
    await tester.pump(const Duration(seconds: 1));
  });
}

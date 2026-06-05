import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:drift/native.dart';

import 'package:promptforge/app/app.dart';
import 'package:promptforge/core/database/database.dart';
import 'package:promptforge/core/database/database_providers.dart';
import 'package:promptforge/features/search/presentation/command_palette.dart';

void main() {
  late AppDatabase database;

  setUp(() async {
    database = AppDatabase(e: NativeDatabase.memory());
    await database.into(database.prompts).insert(PromptsCompanion.insert(
          id: 'p-zebra',
          title: 'Zebra Special Prompt',
          body: 'A unique body about stripes',
          createdAt: DateTime(2026, 1, 1),
          updatedAt: DateTime(2026, 1, 1),
        ));
  });

  tearDown(() async => database.close());

  Widget app() => ProviderScope(
        overrides: [databaseProvider.overrideWithValue(database)],
        child: const PromptForgeApp(),
      );

  testWidgets('Search tab is removed from navigation', (tester) async {
    tester.view.physicalSize = const Size(1200, 800);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.resetPhysicalSize);

    await tester.pumpWidget(app());
    await tester.pumpAndSettle();

    expect(find.byType(NavigationRail), findsOneWidget);
    expect(find.text('Search'), findsNothing);
    expect(find.byIcon(Icons.search), findsNothing);

    await tester.pumpWidget(Container());
    await tester.pump(const Duration(seconds: 1));
  });

  testWidgets('Ctrl+K opens the palette, searches, and navigates',
      (tester) async {
    tester.view.physicalSize = const Size(1200, 800);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.resetPhysicalSize);

    await tester.pumpWidget(app());
    await tester.pumpAndSettle();

    // Open the palette via the global shortcut.
    await tester.sendKeyDownEvent(LogicalKeyboardKey.controlLeft);
    await tester.sendKeyEvent(LogicalKeyboardKey.keyK);
    await tester.sendKeyUpEvent(LogicalKeyboardKey.controlLeft);
    await tester.pumpAndSettle();
    expect(find.byType(CommandPalette), findsOneWidget);

    // Type a query that matches the seeded prompt.
    final field = find.descendant(
        of: find.byType(CommandPalette), matching: find.byType(TextField));
    await tester.enterText(field, 'Zebra');
    await tester.pump(const Duration(milliseconds: 250)); // debounce
    await tester.pumpAndSettle();

    expect(find.text('PROMPTS'), findsOneWidget);
    expect(find.text('Zebra Special Prompt'), findsOneWidget);

    // Selecting navigates to the prompt editor and closes the palette.
    await tester.tap(find.text('Zebra Special Prompt'));
    await tester.pumpAndSettle();
    expect(find.byType(CommandPalette), findsNothing);
    expect(find.text('Edit Prompt'), findsOneWidget);

    await tester.pumpWidget(Container());
    await tester.pump(const Duration(seconds: 1));
  });
}

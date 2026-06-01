import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:drift/native.dart';

import 'package:promptforge/app/app.dart';
import 'package:promptforge/core/database/database.dart';
import 'package:promptforge/core/database/database_providers.dart';

void main() {
  late AppDatabase testDatabase;

  setUp(() {
    testDatabase = AppDatabase(e: NativeDatabase.memory());
  });

  tearDown(() async {
    await testDatabase.close();
  });

  Widget createTestApp() {
    return ProviderScope(
      overrides: [
        databaseProvider.overrideWithValue(testDatabase),
      ],
      child: const PromptForgeApp(),
    );
  }

  testWidgets('App smoke test', (WidgetTester tester) async {
    await tester.pumpWidget(createTestApp());

    await tester.pumpAndSettle();

    // Verify initial route is Inbox
    expect(find.text('Prompt Inbox'), findsWidgets);
    expect(find.text('Your inbox is empty. Capture a new idea!'), findsOneWidget);
    
    // Unmount and flush Drift's stream cancel timer
    await tester.pumpWidget(Container());
    await tester.pump(const Duration(seconds: 1));
  });

  testWidgets('Mobile navigation test', (WidgetTester tester) async {
    // Set screen size to mobile
    tester.view.physicalSize = const Size(400, 800);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.resetPhysicalSize);

    await tester.pumpWidget(createTestApp());

    await tester.pumpAndSettle();

    // Verify BottomNavigationBar is present
    expect(find.byType(NavigationBar), findsOneWidget);
    expect(find.byType(NavigationRail), findsNothing);

    // Navigate to Library
    await tester.tap(find.text('Library').last);
    await tester.pump();
    await tester.pump(const Duration(seconds: 1));
    await tester.pump(const Duration(seconds: 1));

    expect(find.text('No prompts found. Create one!'), findsOneWidget);

    // Unmount and flush Drift's stream cancel timer
    await tester.pumpWidget(Container());
    await tester.pump(const Duration(seconds: 1));
  });

  testWidgets('Desktop navigation test', (WidgetTester tester) async {
    // Set screen size to desktop
    tester.view.physicalSize = const Size(1200, 800);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.resetPhysicalSize);

    await tester.pumpWidget(createTestApp());

    await tester.pumpAndSettle();

    // Verify NavigationRail is present
    expect(find.byType(NavigationRail), findsOneWidget);
    expect(find.byType(NavigationBar), findsNothing);

    // Navigate to Settings
    await tester.tap(find.byIcon(Icons.settings));
    await tester.pumpAndSettle();
    expect(find.text('Settings'), findsWidgets);
    expect(find.text('Export Data'), findsOneWidget);

    // Unmount and flush Drift's stream cancel timer
    await tester.pumpWidget(Container());
    await tester.pump(const Duration(seconds: 1));
  });
}

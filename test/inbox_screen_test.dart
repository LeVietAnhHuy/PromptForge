import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:drift/native.dart';
import 'package:drift/drift.dart' as drift;
import 'package:go_router/go_router.dart';
import 'package:promptforge/core/database/database.dart';
import 'package:promptforge/core/database/database_providers.dart';
import 'package:promptforge/features/inbox/presentation/inbox_screen.dart';
import 'package:promptforge/features/inbox/presentation/inbox_editor_screen.dart';

void main() {
  late AppDatabase database;

  setUp(() {
    database = AppDatabase(e: NativeDatabase.memory());
  });

  tearDown(() async {
    await database.close();
  });

  Widget createInboxApp() {
    return ProviderScope(
      overrides: [
        databaseProvider.overrideWithValue(database),
      ],
      child: const MaterialApp(
        home: InboxScreen(),
      ),
    );
  }

  Widget createInboxEditorApp({String? itemId}) {
    final router = GoRouter(
      initialLocation: '/',
      routes: [
        GoRoute(
          path: '/',
          builder: (context, state) => InboxEditorScreen(itemId: itemId),
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

  testWidgets('InboxScreen shows empty state initially', (tester) async {
    await tester.pumpWidget(createInboxApp());
    await tester.pumpAndSettle();

    expect(find.text('Prompt Inbox'), findsOneWidget);
    expect(find.text('Your inbox is empty. Capture a new idea!'), findsOneWidget);
    expect(find.byType(FloatingActionButton), findsOneWidget);

    await tester.pumpWidget(Container());
    await tester.pump(const Duration(seconds: 1));
  });

  testWidgets('InboxScreen displays active items', (tester) async {
    final now = DateTime.now();
    await database.into(database.inboxItems).insert(InboxItemsCompanion.insert(
      id: 'test-id',
      title: const drift.Value('Test Title'),
      rawText: 'Test Content',
      createdAt: now,
      updatedAt: now,
    ));

    await tester.pumpWidget(createInboxApp());
    await tester.pumpAndSettle();

    expect(find.text('Test Title'), findsOneWidget);
    expect(find.text('Test Content'), findsOneWidget);

    await tester.pumpWidget(Container());
    await tester.pump(const Duration(seconds: 1));
  });

  testWidgets('InboxEditorScreen validates empty content', (tester) async {
    await tester.pumpWidget(createInboxEditorApp());
    await tester.pumpAndSettle();

    await tester.enterText(find.byType(TextField).first, 'Some Title');
    await tester.tap(find.byTooltip('Save'));
    await tester.pumpAndSettle();

    expect(find.text('Content cannot be empty'), findsOneWidget);

    await tester.pumpWidget(Container());
    await tester.pump(const Duration(seconds: 1));
  });

  testWidgets('InboxEditorScreen saves new item', (tester) async {
    await tester.pumpWidget(createInboxEditorApp());
    await tester.pumpAndSettle();

    await tester.enterText(find.byType(TextField).at(0), 'Test Title');
    await tester.enterText(find.byType(TextField).at(1), 'Test Content');
    await tester.enterText(find.byType(TextField).at(2), 'Test Source');
    
    await tester.tap(find.byTooltip('Save'));
    await tester.pumpAndSettle();

    final items = await database.select(database.inboxItems).get();
    expect(items.length, 1);
    expect(items.first.title, 'Test Title');
    expect(items.first.rawText, 'Test Content');
    expect(items.first.source, 'Test Source');

    await tester.pumpWidget(Container());
    await tester.pump(const Duration(seconds: 1));
  });

  testWidgets('InboxEditorScreen converts item to prompt', (tester) async {
    final now = DateTime.now();
    await database.into(database.inboxItems).insert(InboxItemsCompanion.insert(
      id: 'test-convert-id',
      title: const drift.Value('Convert Me'),
      rawText: 'Content to convert',
      createdAt: now,
      updatedAt: now,
    ));

    await tester.pumpWidget(createInboxEditorApp(itemId: 'test-convert-id'));
    await tester.pumpAndSettle();

    expect(find.text('Convert Me'), findsOneWidget);
    expect(find.text('Content to convert'), findsOneWidget);

    await tester.tap(find.text('Convert to Prompt Library'));
    await tester.pumpAndSettle();

    // After converting it pops and shows snackbar. Since it popped, the editor is gone
    // We can check the DB
    final items = await database.select(database.inboxItems).get();
    expect(items.first.status, 'converted');

    final prompts = await database.select(database.prompts).get();
    expect(prompts.length, 1);
    expect(prompts.first.title, 'Convert Me');
    expect(prompts.first.body, 'Content to convert');

    await tester.pumpWidget(Container());
    await tester.pump(const Duration(seconds: 1));
  });
}

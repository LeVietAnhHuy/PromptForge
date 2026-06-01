import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:drift/native.dart';
import 'package:drift/drift.dart' as drift;
import 'package:promptforge/core/database/database.dart';
import 'package:promptforge/core/database/database_providers.dart';
import 'package:promptforge/features/context_packs/presentation/context_packs_screen.dart';

void main() {
  late AppDatabase database;

  setUp(() {
    database = AppDatabase(e: NativeDatabase.memory());
  });

  tearDown(() async {
    await database.close();
  });

  Widget createTestApp() {
    return ProviderScope(
      overrides: [
        databaseProvider.overrideWithValue(database),
      ],
      child: const MaterialApp(
        home: ContextPacksScreen(),
      ),
    );
  }

  testWidgets('Context Packs shows empty state initially', (tester) async {
    await tester.pumpWidget(createTestApp());
    await tester.pumpAndSettle();

    expect(find.text('Context Packs'), findsOneWidget);
    expect(find.text('No context packs found. Create one!'), findsOneWidget);
    expect(find.byType(FloatingActionButton), findsOneWidget);

    // Unmount
    await tester.pumpWidget(Container());
    await tester.pump(const Duration(seconds: 1));
  });

  testWidgets('Context Packs shows loaded packs', (tester) async {
    final now = DateTime.now();
    await database.into(database.contextPacks).insert(ContextPacksCompanion.insert(
      id: 'pack-1',
      name: 'Research Style',
      description: const drift.Value('Rules for research papers'),
      content: 'Explain concepts step by step.',
      createdAt: now,
      updatedAt: now,
    ));

    await tester.pumpWidget(createTestApp());
    await tester.pumpAndSettle();

    expect(find.text('Research Style'), findsOneWidget);
    expect(find.text('Rules for research papers'), findsOneWidget);

    // Unmount
    await tester.pumpWidget(Container());
    await tester.pump(const Duration(seconds: 1));
  });
}

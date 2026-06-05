import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:drift/native.dart';

import 'package:promptforge/app/theme/theme.dart';
import 'package:promptforge/core/database/database.dart';
import 'package:promptforge/core/database/database_providers.dart';
import 'package:promptforge/features/prompt_examples/presentation/prompt_output_card.dart';
import 'package:promptforge/shared/providers/provider_identity.dart';

void main() {
  group('ProviderRegistry.resolve', () {
    test('resolves a known provider by id with a bundled asset', () {
      final id = ProviderRegistry.resolve(providerId: 'anthropic');
      expect(id.displayName, 'Anthropic');
      expect(id.asset, 'anthropic.svg');
    });

    test('resolves by display name when id is absent', () {
      final id = ProviderRegistry.resolve(providerName: 'OpenAI');
      expect(id.id, 'openai');
      expect(id.asset, 'openai.svg'); // OpenAI now ships a real logo (Stage 24)
    });

    test('falls back to a neutral identity keeping the unknown name', () {
      final id = ProviderRegistry.resolve(providerName: 'SomeNewCo');
      expect(id.id, 'unknown');
      expect(id.displayName, 'SomeNewCo');
      expect(id.asset, isNull);
    });

    test('empty input yields the Unknown identity', () {
      final id = ProviderRegistry.resolve();
      expect(id.displayName, 'Unknown');
    });
  });

  testWidgets('PromptOutputCard shows provider identity and edit affordance',
      (tester) async {
    final database = AppDatabase(e: NativeDatabase.memory());
    addTearDown(() async => database.close());

    final now = DateTime.now();
    await database.promptExampleDao
        .createExample(PromptExamplesCompanion.insert(
      id: 'ex1',
      title: 'Ex',
      compiledPrompt: 'prompt',
      createdAt: now,
      updatedAt: now,
    ));
    final output = PromptExampleOutput(
      id: 'o1',
      exampleId: 'ex1',
      providerId: 'anthropic',
      modelId: 'claude-opus-4-5',
      providerName: 'Anthropic',
      modelName: 'Claude Opus 4.5',
      outputType: 'markdown',
      sourceType: 'manual',
      outputText: 'Hello world',
      isBest: false,
      createdAt: now,
      updatedAt: now,
    );

    var edited = false;
    await tester.pumpWidget(ProviderScope(
      overrides: [databaseProvider.overrideWithValue(database)],
      child: MaterialApp(
        theme: AppTheme.darkTheme,
        home: Scaffold(
          body: PromptOutputCard(
            output: output,
            onEdit: () => edited = true,
            onDelete: () {},
          ),
        ),
      ),
    ));
    await tester.pumpAndSettle();

    // Provider name + bundled SVG logo render.
    expect(find.text('Anthropic'), findsOneWidget);
    expect(find.byType(SvgPicture), findsWidgets);
    // Tinted model badge.
    expect(find.text('Claude Opus 4.5'), findsOneWidget);

    // Edit action available through the kebab menu.
    await tester.tap(find.byIcon(Icons.more_vert));
    await tester.pumpAndSettle();
    expect(find.text('Edit'), findsOneWidget);
    await tester.tap(find.text('Edit'));
    await tester.pumpAndSettle();
    expect(edited, isTrue);

    await tester.pumpWidget(Container());
    await tester.pump(const Duration(seconds: 1));
  });

  testWidgets('PromptOutputCard surfaces an edited indicator', (tester) async {
    final database = AppDatabase(e: NativeDatabase.memory());
    addTearDown(() async => database.close());

    final created = DateTime(2026, 1, 1, 9);
    final output = PromptExampleOutput(
      id: 'o2',
      exampleId: 'ex2',
      providerName: 'Unknown',
      outputType: 'text',
      sourceType: 'manual',
      outputText: 'plain body text',
      isBest: false,
      createdAt: created,
      updatedAt: created.add(const Duration(hours: 2)),
    );

    await tester.pumpWidget(ProviderScope(
      overrides: [databaseProvider.overrideWithValue(database)],
      child: MaterialApp(
        theme: AppTheme.darkTheme,
        home: Scaffold(body: PromptOutputCard(output: output)),
      ),
    ));
    await tester.pumpAndSettle();

    expect(find.textContaining('· edited'), findsOneWidget);

    await tester.pumpWidget(Container());
    await tester.pump(const Duration(seconds: 1));
  });
}

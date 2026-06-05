import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:drift/native.dart';

import 'package:promptforge/app/theme/theme.dart';
import 'package:promptforge/core/database/database.dart';
import 'package:promptforge/core/database/database_providers.dart';
import 'package:promptforge/features/execution/domain/llm_provider.dart';
import 'package:promptforge/features/prompt_examples/presentation/example_comparison_screen.dart';

/// End-to-end UI proof of the per-column failure isolation: a multi-model run
/// where one model fails must still save the others AND surface the failure as
/// its own error column.
void main() {
  late AppDatabase db;

  setUp(() async {
    db = AppDatabase(e: NativeDatabase.memory());
    final now = DateTime(2026, 1, 1, 12);
    await db.promptExampleDao.createExample(PromptExamplesCompanion.insert(
      id: 'ex1',
      title: 'Run',
      compiledPrompt: 'Hello there',
      createdAt: now,
      updatedAt: now,
    ));
  });
  tearDown(() async => db.close());

  testWidgets(
      'multi-model run: healthy model saves an output, failing model shows an '
      'error column', (tester) async {
    tester.view.physicalSize = const Size(390, 844);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.resetPhysicalSize);

    await tester.pumpWidget(ProviderScope(
      overrides: [
        databaseProvider.overrideWithValue(db),
        executionProvidersProvider
            .overrideWithValue([_TwoModelFakeProvider()]),
      ],
      child: MaterialApp(
        theme: AppTheme.darkTheme,
        home: const ExampleComparisonScreen(exampleId: 'ex1'),
      ),
    ));
    await tester.pumpAndSettle();

    // Both models are offered; the first ("OK") is selected by default.
    expect(find.widgetWithText(FilterChip, 'OK'), findsOneWidget);
    expect(find.widgetWithText(FilterChip, 'Bad'), findsOneWidget);

    // Also select the failing model, then run both concurrently.
    await tester.tap(find.widgetWithText(FilterChip, 'Bad'));
    await tester.pumpAndSettle();
    await tester.tap(find.widgetWithText(ElevatedButton, 'Run (2)'));
    await tester.pumpAndSettle();

    // The healthy model's output was saved and is shown.
    expect(find.textContaining('ok from m-ok'), findsOneWidget);
    // The failing model did not abort the run — its error is its own column.
    expect(find.textContaining('kaboom'), findsOneWidget);

    // Exactly one output row persisted (the failure saved nothing).
    final saved = await db.promptExampleOutputDao.getOutputsForExample('ex1');
    expect(saved, hasLength(1));
    expect(saved.single.modelId, 'm-ok');

    await tester.pumpWidget(Container());
    await tester.pump(const Duration(seconds: 1));
  });
}

class _TwoModelFakeProvider implements LlmExecutionProvider {
  @override
  String get providerId => 'fake';
  @override
  String get providerName => 'Fake Provider';
  @override
  bool get requiresApiKey => false;
  @override
  String get credentialProviderId => providerId;

  @override
  Future<List<Map<String, String>>> listAvailableModels() async => [
        {'id': 'm-ok', 'name': 'OK'},
        {'id': 'm-bad', 'name': 'Bad'},
      ];

  @override
  Future<LlmExecutionResponse> execute(LlmExecutionRequest request) async {
    await Future<void>.delayed(const Duration(milliseconds: 5));
    final bad = request.modelId == 'm-bad';
    return LlmExecutionResponse(
      outputText: bad ? '' : 'ok from ${request.modelId}',
      providerId: providerId,
      modelId: request.modelId,
      modelName: request.modelName,
      createdAt: DateTime(2026, 1, 1, 12),
      error: bad ? 'kaboom: model unavailable' : null,
    );
  }
}

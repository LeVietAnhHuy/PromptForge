import 'package:drift/drift.dart' as drift;
import 'package:drift/native.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:promptforge/core/database/database.dart';
import 'package:promptforge/core/database/database_providers.dart';
import 'package:promptforge/features/execution/domain/llm_provider.dart';
import 'package:promptforge/features/projects/presentation/prompt_run_editor_screen.dart';
import 'package:promptforge/features/prompt_examples/presentation/example_comparison_screen.dart';
import 'package:promptforge/features/prompt_examples/presentation/output_editor_dialog.dart';
import 'package:promptforge/features/prompt_library/presentation/prompt_body_focus_editor.dart';

void main() {
  late AppDatabase database;

  setUp(() {
    database = AppDatabase(e: NativeDatabase.memory());
  });

  tearDown(() async {
    await database.close();
  });

  Widget createTestApp(Widget child) {
    return ProviderScope(
      overrides: [
        databaseProvider.overrideWithValue(database),
        executionProvidersProvider.overrideWithValue([MockExecutionProvider()]),
      ],
      child: MaterialApp(home: child),
    );
  }

  void setNarrowViewport(WidgetTester tester) {
    tester.view.physicalSize = const Size(390, 844);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.resetPhysicalSize);
  }

  testWidgets('ExampleComparisonScreen stacks controls on narrow width', (tester) async {
    setNarrowViewport(tester);
    final now = DateTime.now();
    await database.promptExampleDao.createExample(PromptExamplesCompanion.insert(
      id: 'example-1',
      title: 'Narrow Comparison',
      compiledPrompt: 'A long compiled prompt\n\n${List.filled(12, 'details').join('\n')}',
      createdAt: now,
      updatedAt: now,
    ));
    await database.promptExampleOutputDao.addOutput(PromptExampleOutputsCompanion.insert(
      id: 'output-1',
      exampleId: 'example-1',
      providerName: 'Manual Provider',
      outputText: List.filled(20, 'Manual output line').join('\n'),
      sourceType: const drift.Value('manual'),
      createdAt: now,
      updatedAt: now,
    ));

    await tester.pumpWidget(createTestApp(const ExampleComparisonScreen(exampleId: 'example-1')));
    await tester.pumpAndSettle();

    expect(find.text('Run LLM Output'), findsOneWidget);
    expect(find.widgetWithText(OutlinedButton, 'Add Output'), findsOneWidget);
    expect(find.text('MANUAL'), findsWidgets);
    expect(tester.takeException(), isNull);

    await tester.pumpWidget(Container());
    await tester.pump(const Duration(seconds: 1));
  });

  testWidgets('PromptRunEditorScreen keeps run actions visible on narrow width', (tester) async {
    setNarrowViewport(tester);
    final now = DateTime.now();
    await database.projectDao.createProject(ProjectsCompanion.insert(
      id: 'project-1',
      name: 'Project',
      createdAt: now,
      updatedAt: now,
    ));
    await database.lLMProviderDao.createProvider(LLMProvidersCompanion.insert(
      id: 'fake',
      name: 'Fake Provider',
      createdAt: now,
    ));
    await database.promptExampleDao.createExample(PromptExamplesCompanion.insert(
      id: 'run-1',
      projectId: const drift.Value('project-1'),
      title: 'Run',
      compiledPrompt: 'Prompt run input',
      createdAt: now,
      updatedAt: now,
    ));

    await tester.pumpWidget(createTestApp(const PromptRunEditorScreen(projectId: 'project-1', runId: 'run-1')));
    await tester.pumpAndSettle();

    await tester.tap(find.text('Outputs Lab').first);
    await tester.pumpAndSettle();

    expect(find.widgetWithText(ElevatedButton, 'Run'), findsOneWidget);
    expect(find.widgetWithText(OutlinedButton, 'Paste Output'), findsOneWidget);
    expect(tester.takeException(), isNull);

    await tester.pumpWidget(Container());
    await tester.pump(const Duration(seconds: 1));
  });

  testWidgets('PromptBodyFocusEditor exposes scrollable editor on narrow width', (tester) async {
    setNarrowViewport(tester);

    await tester.pumpWidget(MaterialApp(
      home: PromptBodyFocusEditor(
        initialText: List.filled(60, 'Markdown line').join('\n'),
      ),
    ));
    await tester.pumpAndSettle();

    await tester.tap(find.text('Edit'));
    await tester.pumpAndSettle();

    expect(find.byType(TextFormField), findsOneWidget);
    expect(find.widgetWithText(FilledButton, 'Apply'), findsOneWidget);
    expect(tester.takeException(), isNull);

    await tester.pumpWidget(Container());
    await tester.pump(const Duration(seconds: 1));
  });

  testWidgets('OutputEditorDialog fits narrow screens', (tester) async {
    setNarrowViewport(tester);
    final now = DateTime.now();
    await database.promptExampleDao.createExample(PromptExamplesCompanion.insert(
      id: 'example-1',
      title: 'Example',
      compiledPrompt: 'Compiled prompt',
      createdAt: now,
      updatedAt: now,
    ));

    await tester.pumpWidget(createTestApp(
      Scaffold(
        body: Builder(
          builder: (context) {
            return Center(
              child: ElevatedButton(
                onPressed: () {
                  showDialog(
                    context: context,
                    builder: (context) => const OutputEditorDialog(exampleId: 'example-1'),
                  );
                },
                child: const Text('Open'),
              ),
            );
          },
        ),
      ),
    ));

    await tester.tap(find.text('Open'));
    await tester.pumpAndSettle();

    expect(find.text('Add LLM Output'), findsOneWidget);
    expect(find.widgetWithText(ElevatedButton, 'Save'), findsOneWidget);
    expect(tester.takeException(), isNull);

    await tester.pumpWidget(Container());
    await tester.pump(const Duration(seconds: 1));
  });
}

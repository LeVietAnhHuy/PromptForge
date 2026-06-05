import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:drift/native.dart';

import 'package:promptforge/app/theme/theme.dart';
import 'package:promptforge/core/database/database.dart';
import 'package:promptforge/core/database/database_providers.dart';
import 'package:promptforge/features/prompt_examples/application/llm_model_catalog.dart';
import 'package:promptforge/features/prompt_examples/presentation/model_picker_field.dart';

const _models = [
  LlmModelOption(
      id: 'gpt-5',
      displayName: 'GPT-5',
      family: 'GPT-5',
      approximateReleaseOrder: 30),
  LlmModelOption(
      id: 'gpt-5-mini',
      displayName: 'GPT-5 mini',
      family: 'GPT-5',
      approximateReleaseOrder: 29),
  LlmModelOption(
      id: 'gpt-4o',
      displayName: 'GPT-4o',
      family: 'GPT-4.x',
      approximateReleaseOrder: 20),
  LlmModelOption(
      id: 'gpt-4-legacy',
      displayName: 'GPT-4 classic',
      family: 'GPT-4.x',
      approximateReleaseOrder: 10,
      isLegacy: true),
  LlmModelOption(
      id: 'custom',
      displayName: 'Custom model…',
      family: '',
      approximateReleaseOrder: 9999),
];

class _Host extends StatefulWidget {
  final ValueChanged<String>? onSelected;
  const _Host({this.onSelected});
  @override
  State<_Host> createState() => _HostState();
}

class _HostState extends State<_Host> {
  String? _selected = 'gpt-5';
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.all(40),
        child: SizedBox(
          width: 360,
          child: ModelPickerField(
            providerId: 'openai',
            models: _models,
            selectedModelId: _selected,
            onSelected: (id) {
              setState(() => _selected = id);
              widget.onSelected?.call(id);
            },
          ),
        ),
      ),
    );
  }
}

void main() {
  late AppDatabase database;
  setUp(() => database = AppDatabase(e: NativeDatabase.memory()));
  tearDown(() async => database.close());

  Future<void> pump(WidgetTester tester,
      {ValueChanged<String>? onSelected}) async {
    await tester.pumpWidget(ProviderScope(
      overrides: [databaseProvider.overrideWithValue(database)],
      child: MaterialApp(
        theme: AppTheme.darkTheme,
        home: _Host(onSelected: onSelected),
      ),
    ));
    await tester.pumpAndSettle();
  }

  testWidgets('groups by family, newest first, with legacy collapsed',
      (tester) async {
    await pump(tester);
    // Closed field shows the current selection.
    expect(find.text('GPT-5'), findsOneWidget);

    await tester.tap(find.byType(ModelPickerField));
    await tester.pumpAndSettle();

    // Family headers (uppercased) present.
    expect(find.text('GPT-5'), findsWidgets);
    expect(find.text('GPT-4.X'), findsOneWidget);
    // Non-legacy models shown.
    expect(find.text('GPT-4o'), findsOneWidget);
    expect(find.text('GPT-5 mini'), findsOneWidget);
    // Legacy hidden behind an expander.
    expect(find.text('GPT-4 classic'), findsNothing);
    expect(find.text('Legacy (1)'), findsOneWidget);
    // Custom always available.
    expect(find.text('Custom model…'), findsOneWidget);

    // Expand legacy.
    await tester.tap(find.text('Legacy (1)'));
    await tester.pumpAndSettle();
    expect(find.text('GPT-4 classic'), findsOneWidget);
  });

  testWidgets('type-to-filter narrows the list with an inline buffer chip',
      (tester) async {
    await pump(tester);
    await tester.tap(find.byType(ModelPickerField));
    await tester.pumpAndSettle();

    await tester.sendKeyEvent(LogicalKeyboardKey.keyM);
    await tester.sendKeyEvent(LogicalKeyboardKey.keyI);
    await tester.sendKeyEvent(LogicalKeyboardKey.keyN);
    await tester.sendKeyEvent(LogicalKeyboardKey.keyI);
    await tester.pumpAndSettle();

    // Only the matching model remains; the inline buffer chip shows the query.
    expect(find.text('GPT-5 mini'), findsOneWidget);
    expect(find.text('GPT-4o'), findsNothing);
    expect(find.text('mini'), findsOneWidget);
  });

  testWidgets('keyboard arrows + Enter select a model', (tester) async {
    String? selected;
    await pump(tester, onSelected: (id) => selected = id);
    await tester.tap(find.byType(ModelPickerField));
    await tester.pumpAndSettle();

    // Highlight starts on the current selection (gpt-5); move down to gpt-5-mini.
    await tester.sendKeyEvent(LogicalKeyboardKey.arrowDown);
    await tester.pumpAndSettle();
    await tester.sendKeyEvent(LogicalKeyboardKey.enter);
    await tester.pumpAndSettle();

    expect(selected, 'gpt-5-mini');
    // Overlay closed, field reflects the new selection.
    expect(find.text('GPT-5 mini'), findsOneWidget);
  });
}

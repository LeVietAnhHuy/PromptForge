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
      id: 'img-1',
      displayName: 'Imagen Test',
      family: 'Image',
      approximateReleaseOrder: 15),
  LlmModelOption(
      id: 'custom',
      displayName: 'Custom model…',
      family: '',
      approximateReleaseOrder: 9999),
];

class _Host extends StatefulWidget {
  final List<LlmModelOption> models;
  final ValueChanged<String>? onSelected;
  const _Host({required this.models, this.onSelected});
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
            models: widget.models,
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
  group('capabilityOfFamily', () {
    test('classifies chat vs capability families', () {
      expect(capabilityOfFamily('GPT-5'), ModelCapability.chat);
      expect(capabilityOfFamily('Claude 4'), ModelCapability.chat);
      expect(capabilityOfFamily('Image'), ModelCapability.image);
      expect(capabilityOfFamily('Imagen'), ModelCapability.image);
      expect(capabilityOfFamily('Audio'), ModelCapability.audio);
      expect(capabilityOfFamily('Video'), ModelCapability.video);
      expect(capabilityOfFamily('Veo'), ModelCapability.video);
      expect(capabilityOfFamily('Embedding'), ModelCapability.embedding);
      expect(capabilityOfFamily('Moderation'), ModelCapability.other);
      expect(capabilityOfFamily('OSS'), ModelCapability.other);
    });
  });

  late AppDatabase database;
  setUp(() => database = AppDatabase(e: NativeDatabase.memory()));
  tearDown(() async => database.close());

  Future<void> pump(WidgetTester tester,
      {ValueChanged<String>? onSelected,
      List<LlmModelOption> models = _models}) async {
    await tester.pumpWidget(ProviderScope(
      overrides: [databaseProvider.overrideWithValue(database)],
      child: MaterialApp(
        theme: AppTheme.darkTheme,
        home: _Host(models: models, onSelected: onSelected),
      ),
    ));
    await tester.pumpAndSettle();
  }

  testWidgets('chat families first, capability groups collapsed',
      (tester) async {
    await pump(tester);
    await tester.tap(find.byType(ModelPickerField));
    await tester.pumpAndSettle();

    // Chat families expanded by default.
    expect(find.text('GPT-5 mini'), findsOneWidget);
    expect(find.text('GPT-4o'), findsOneWidget);
    // Legacy collapsed within its family.
    expect(find.text('GPT-4 classic'), findsNothing);
    expect(find.text('Legacy (1)'), findsOneWidget);
    // Capability group present but collapsed.
    expect(find.text('IMAGE'), findsOneWidget);
    expect(find.text('Imagen Test'), findsNothing);
    // Custom available.
    expect(find.text('Custom model…'), findsOneWidget);
  });

  testWidgets('collapsed capability group expands by click', (tester) async {
    await pump(tester);
    await tester.tap(find.byType(ModelPickerField));
    await tester.pumpAndSettle();

    expect(find.text('Imagen Test'), findsNothing);
    await tester.tap(find.text('IMAGE'));
    await tester.pumpAndSettle();
    expect(find.text('Imagen Test'), findsOneWidget);
  });

  testWidgets('header collapses/expands by keyboard (←/→)', (tester) async {
    await pump(tester);
    await tester.tap(find.byType(ModelPickerField));
    await tester.pumpAndSettle();

    // Focus starts on the selected model (gpt-5); move up onto the GPT-5 header.
    await tester.sendKeyEvent(LogicalKeyboardKey.arrowUp);
    await tester.pumpAndSettle();
    // Collapse the focused header.
    await tester.sendKeyEvent(LogicalKeyboardKey.arrowLeft);
    await tester.pumpAndSettle();
    expect(find.text('GPT-5 mini'), findsNothing);
    // Expand it again.
    await tester.sendKeyEvent(LogicalKeyboardKey.arrowRight);
    await tester.pumpAndSettle();
    expect(find.text('GPT-5 mini'), findsOneWidget);
  });

  testWidgets('legacy sub-row expands by keyboard Enter', (tester) async {
    await pump(tester);
    await tester.tap(find.byType(ModelPickerField));
    await tester.pumpAndSettle();

    // Walk down to the "Legacy (1)" toggle and activate it.
    for (var i = 0; i < 4; i++) {
      await tester.sendKeyEvent(LogicalKeyboardKey.arrowDown);
      await tester.pumpAndSettle();
    }
    await tester.sendKeyEvent(LogicalKeyboardKey.enter);
    await tester.pumpAndSettle();
    expect(find.text('GPT-4 classic'), findsOneWidget);
  });

  testWidgets('capability chip filters the list', (tester) async {
    await pump(tester);
    await tester.tap(find.byType(ModelPickerField));
    await tester.pumpAndSettle();

    // Select the Image chip → only the image group remains (auto-expanded).
    await tester.tap(find.widgetWithText(ChoiceChip, 'Image'));
    await tester.pumpAndSettle();
    expect(find.text('Imagen Test'), findsOneWidget);
    expect(find.text('GPT-5 mini'), findsNothing);
  });

  testWidgets('typeahead filters and selecting works', (tester) async {
    String? selected;
    await pump(tester, onSelected: (id) => selected = id);
    await tester.tap(find.byType(ModelPickerField));
    await tester.pumpAndSettle();

    await tester.sendKeyEvent(LogicalKeyboardKey.keyM);
    await tester.sendKeyEvent(LogicalKeyboardKey.keyI);
    await tester.sendKeyEvent(LogicalKeyboardKey.keyN);
    await tester.sendKeyEvent(LogicalKeyboardKey.keyI);
    await tester.pumpAndSettle();

    expect(find.text('GPT-5 mini'), findsOneWidget);
    expect(find.text('GPT-4o'), findsNothing);
    expect(find.text('mini'), findsOneWidget); // inline buffer chip

    await tester.tap(find.text('GPT-5 mini'));
    await tester.pumpAndSettle();
    expect(selected, 'gpt-5-mini');
  });

  testWidgets('bottom of a long list is reachable and selectable',
      (tester) async {
    // 40 chat models in one family — taller than the dropdown.
    final big = <LlmModelOption>[
      for (var i = 40; i >= 1; i--)
        LlmModelOption(
            id: 'big-$i',
            displayName: 'Big Model ${i.toString().padLeft(2, '0')}',
            family: 'Big',
            approximateReleaseOrder: i),
      const LlmModelOption(
          id: 'custom',
          displayName: 'Custom model…',
          family: '',
          approximateReleaseOrder: 9999),
    ];
    String? selected;
    await pump(tester, models: big, onSelected: (id) => selected = id);
    // Default selection 'gpt-5' isn't in this list; field shows placeholder.
    await tester.tap(find.byType(ModelPickerField));
    await tester.pumpAndSettle();

    final listScrollable = find.descendant(
        of: find.byType(Scrollbar), matching: find.byType(Scrollable));
    await tester.scrollUntilVisible(find.text('Big Model 01'), 120,
        scrollable: listScrollable);
    await tester.pumpAndSettle();
    expect(find.text('Big Model 01'), findsOneWidget);

    await tester.tap(find.text('Big Model 01'));
    await tester.pumpAndSettle();
    expect(selected, 'big-1');
  });
}

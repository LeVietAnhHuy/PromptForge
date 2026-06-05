import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:drift/drift.dart' as drift;
import 'package:drift/native.dart';

import 'package:promptforge/app/theme/theme.dart';
import 'package:promptforge/core/database/database.dart';
import 'package:promptforge/core/database/database_providers.dart';
import 'package:promptforge/features/prompt_examples/presentation/prompt_output_card.dart';
import 'package:promptforge/shared/attachments/attachment_viewer.dart';

void main() {
  late AppDatabase db;
  setUp(() => db = AppDatabase(e: NativeDatabase.memory()));
  tearDown(() async => db.close());

  Future<void> addAttachment(String outputId, String fileName) {
    return db.lLMOutputAttachmentDao
        .createAttachment(LLMOutputAttachmentsCompanion.insert(
      id: '$outputId-$fileName',
      outputId: outputId,
      fileName: fileName,
      mimeType: 'application/pdf',
      localPath: '/nonexistent/$fileName',
      attachmentType: const drift.Value('pdf'),
      createdAt: DateTime(2026, 1, 1),
    ));
  }

  testWidgets(
      'card reflects a newly added attachment immediately (no reopen needed)',
      (tester) async {
    final now = DateTime(2026, 1, 1, 12);
    final output = PromptExampleOutput(
      id: 'o1',
      exampleId: 'ex1',
      providerName: 'OpenAI',
      providerId: 'openai',
      outputType: 'text',
      sourceType: 'manual',
      outputText: 'hello',
      isBest: false,
      createdAt: now,
      updatedAt: now,
    );

    // Start with two attachments, as if the output was saved earlier.
    await addAttachment('o1', 'a.pdf');
    await addAttachment('o1', 'b.pdf');

    await tester.pumpWidget(ProviderScope(
      overrides: [databaseProvider.overrideWithValue(db)],
      child: MaterialApp(
        theme: AppTheme.darkTheme,
        home: Scaffold(body: PromptOutputCard(output: output)),
      ),
    ));
    await tester.pumpAndSettle();

    expect(find.text('a.pdf'), findsOneWidget);
    expect(find.text('b.pdf'), findsOneWidget);
    expect(find.text('c.pdf'), findsNothing);

    // Simulate "Save Changes" adding a 3rd attachment — WITHOUT touching the
    // output row or rebuilding the widget.
    await addAttachment('o1', 'c.pdf');
    await tester.pumpAndSettle();

    // The card must show all three now (the bug showed only two).
    expect(find.text('c.pdf'), findsOneWidget);

    // And the new one opens in the viewer.
    await tester.tap(find.text('c.pdf'));
    await tester.pumpAndSettle();
    expect(find.byType(AttachmentViewer), findsOneWidget);
    expect(find.text('3 of 3'), findsOneWidget);

    await tester.pumpWidget(Container());
    await tester.pump(const Duration(seconds: 1));
  });
}

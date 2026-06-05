import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:drift/native.dart';

import 'package:promptforge/app/theme/theme.dart';
import 'package:promptforge/core/database/database.dart';
import 'package:promptforge/core/database/database_providers.dart';
import 'package:promptforge/features/inbox/presentation/quick_capture_dialog.dart';

void main() {
  late AppDatabase db;
  setUp(() => db = AppDatabase(e: NativeDatabase.memory()));
  tearDown(() async => db.close());

  void mockClipboard(WidgetTester tester, String? text) {
    tester.binding.defaultBinaryMessenger.setMockMethodCallHandler(
      SystemChannels.platform,
      (call) async {
        if (call.method == 'Clipboard.getData') {
          return text == null ? null : <String, dynamic>{'text': text};
        }
        return null;
      },
    );
    addTearDown(() => tester.binding.defaultBinaryMessenger
        .setMockMethodCallHandler(SystemChannels.platform, null));
  }

  Future<void> openDialog(WidgetTester tester) async {
    await tester.pumpWidget(ProviderScope(
      overrides: [databaseProvider.overrideWithValue(db)],
      child: MaterialApp(
        theme: AppTheme.darkTheme,
        home: Scaffold(
          body: Builder(
            builder: (ctx) => ElevatedButton(
              onPressed: () => QuickCaptureDialog.show(ctx),
              child: const Text('open'),
            ),
          ),
        ),
      ),
    ));
    await tester.tap(find.text('open'));
    await tester.pumpAndSettle();
  }

  testWidgets('prefills the body from the clipboard and saves to the inbox',
      (tester) async {
    mockClipboard(tester, 'a copied snippet');
    await openDialog(tester);

    expect(find.text('Quick Capture'), findsOneWidget);
    // Body prefilled from the clipboard.
    expect(find.text('a copied snippet'), findsOneWidget);

    await tester.tap(find.widgetWithText(FilledButton, 'Capture'));
    await tester.pumpAndSettle();

    final items = await db.select(db.inboxItems).get();
    expect(items, hasLength(1));
    expect(items.single.rawText, 'a copied snippet');
    expect(items.single.source, 'quick-capture');
    expect(items.single.status, 'open');
  });

  testWidgets('empty clipboard leaves the body blank and refuses empty saves',
      (tester) async {
    mockClipboard(tester, null);
    await openDialog(tester);

    // Nothing prefilled; trying to save an empty capture saves nothing.
    await tester.tap(find.widgetWithText(FilledButton, 'Capture'));
    await tester.pumpAndSettle();

    expect(find.text('Nothing to capture — add some text.'), findsOneWidget);
    expect(await db.select(db.inboxItems).get(), isEmpty);

    // Typing then saving works.
    await tester.enterText(
        find.widgetWithText(TextField, 'Capture'), 'typed idea');
    await tester.tap(find.widgetWithText(FilledButton, 'Capture'));
    await tester.pumpAndSettle();

    final items = await db.select(db.inboxItems).get();
    expect(items, hasLength(1));
    expect(items.single.rawText, 'typed idea');
  });
}

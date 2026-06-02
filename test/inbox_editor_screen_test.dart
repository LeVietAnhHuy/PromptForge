import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:promptforge/features/inbox/presentation/inbox_editor_screen.dart';
import 'package:flutter_markdown_plus/flutter_markdown_plus.dart';

void main() {
  testWidgets('InboxEditorScreen shows Edit/Preview toggle and markdown preview', (tester) async {
    await tester.pumpWidget(
      const ProviderScope(
        child: MaterialApp(
          home: InboxEditorScreen(),
        ),
      ),
    );

    await tester.pumpAndSettle();

    // Verify Edit segment is selected
    expect(find.text('Edit'), findsOneWidget);
    expect(find.text('Preview'), findsOneWidget);
    
    // Enter markdown text
    await tester.enterText(
      find.byType(TextField).at(1), // First is title, second is content
      '# Heading\nHello markdown.',
    );
    await tester.pump();

    // Switch to Preview
    await tester.tap(find.text('Preview'));
    await tester.pumpAndSettle();

    // Verify Markdown widget is shown
    expect(find.byType(Markdown), findsOneWidget);
    expect(find.text('Heading'), findsWidgets); // Markdown renders without `#`
    expect(find.text('Hello markdown.'), findsOneWidget);

    // Switch back to Edit
    await tester.tap(find.text('Edit'));
    await tester.pumpAndSettle();

    // Verify TextField is back
    expect(find.byType(TextField).at(1), findsOneWidget);
  });
}
